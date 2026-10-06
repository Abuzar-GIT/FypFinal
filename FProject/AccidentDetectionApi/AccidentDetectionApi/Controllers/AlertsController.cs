
using AccidentDetectionApi.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AccidentDetectionApi.Controllers
{
    /// <summary>
    /// Controller for handling Emergency Accident Alert Dispatching, Rescue Team Assignment (Minimum Distance),
    /// Unread Alert Queries, and Marking Alerts as Read.
    /// </summary>
    [RoutePrefix("api/Alerts")]
    public class AlertsController : ApiController
    {
        private AccidentDetectionDBEntities db = new AccidentDetectionDBEntities();

        #region DTO Models

        public class DispatchAlertRequest
        {
            public int Accident_Id { get; set; }
            public string VictimUid { get; set; }
            public string Location { get; set; }
        }

        public class MarkAsReadRequest
        {
            public int Alert_Id { get; set; }
        }

        public class UnreadAlertDto
        {
            public int Alert_Id { get; set; }
            public int Accident_Id { get; set; }
            public string VictimUid { get; set; }
            public string VictimName { get; set; }
            public string VictimContact { get; set; }
            public string VehicleMake { get; set; }
            public string RegistrationNo { get; set; }
            public string ImpactSide { get; set; }
            public string Relationship { get; set; }
            public string Location { get; set; }
            public decimal? ImpactForce { get; set; }
            public decimal? CabinForce { get; set; }
            public string Severity { get; set; }
            public DateTime Time { get; set; }
            public bool Status { get; set; }
            public string TargetType { get; set; } // "Guardian" or "Rescue"
        }

        #endregion

        // =========================================================================
        // FEATURE 2 - API 1: POST /api/Alerts/DispatchAccidentAlert
        // =========================================================================
        /// <summary>
        /// Triggered when an accident occurs.
        /// Creates an Alert record for active emergency notifications.
        /// </summary>
        [HttpPost]
        [Route("DispatchAccidentAlert")]
        [ActionName("DispatchAccidentAlert")]
        public HttpResponseMessage DispatchAccidentAlert([FromBody] DispatchAlertRequest request)
        {
            try
            {
                if (request == null || request.Accident_Id <= 0)
                {
                    return Request != null ? Request.CreateResponse(HttpStatusCode.BadRequest, new { message = "Invalid Accident Data" }) : new HttpResponseMessage(HttpStatusCode.BadRequest);
                }

                // 1. Fetch Accident details from DB
                var accident = db.Accidents.FirstOrDefault(a => a.Accident_Id == request.Accident_Id);
                if (accident == null)
                {
                    return Request != null ? Request.CreateResponse(HttpStatusCode.NotFound, new { message = "Accident record not found" }) : new HttpResponseMessage(HttpStatusCode.NotFound);
                }

                // Check if an alert for this accident already exists
                var existingAlert = db.Alerts.FirstOrDefault(a => a.Accident_Id == accident.Accident_Id);
                if (existingAlert == null)
                {
                    var newAlert = new Alert
                    {
                        Accident_Id = accident.Accident_Id,
                        Time = DateTime.Now,
                        Status = false
                    };
                    db.Alerts.Add(newAlert);
                    db.SaveChanges();
                }
                else
                {
                    existingAlert.Time = DateTime.Now;
                    existingAlert.Status = false;
                    db.SaveChanges();
                }

                var responseObj = new
                {
                    status = "SUCCESS",
                    message = "Alert dispatched successfully",
                    accidentId = accident.Accident_Id
                };

                return Request != null ? Request.CreateResponse(HttpStatusCode.OK, responseObj) : new HttpResponseMessage(HttpStatusCode.OK);
            }
            catch (Exception ex)
            {
                return Request != null ? Request.CreateResponse(HttpStatusCode.InternalServerError, new { error = ex.Message }) : new HttpResponseMessage(HttpStatusCode.InternalServerError);
            }
        }

        // =========================================================================
        // FEATURE 2 - API 2: GET /api/Alerts/Unread?uid={uid}&rid={rid}
        // =========================================================================
        /// <summary>
        /// Queries unread alerts for either a Guardian (by uid) or Rescue unit (by rid).
        /// For Rescue units (rid), filters alerts to only show those where this rescue unit is closest (minimum distance).
        /// </summary>
        [HttpGet]
        [Route("Unread")]
        [ActionName("Unread")]
        public HttpResponseMessage GetUnreadAlerts(string uid = null, int? rid = null)
        {
            try
            {
                // Fetch all unread active alerts in DB where Accident record exists
                var allAlerts = db.Alerts
                    .ToList()
                    .Where(a => !a.Status && a.Accident != null)
                    .OrderByDescending(a => a.Time)
                    .ToList();

                List<UnreadAlertDto> resultList = new List<UnreadAlertDto>();
                HashSet<int> processedAccidentIds = new HashSet<int>();

                string cleanUid = !string.IsNullOrWhiteSpace(uid) ? uid.Trim() : null;

                if (!string.IsNullOrWhiteSpace(cleanUid))
                {
                    // 1. GUARDIAN QUERY:
                    // Find all UIDs of protected persons who added cleanUid as their guardian.
                    // This means: cleanUid is the Guardian (f.Guardian_Id == cleanUid).
                    // Strictly EXCLUDE cleanUid itself so users NEVER see their own accident alerts.
                    var protectedVictimUids = db.FamilyMembers
                        .ToList()
                        .Where(f => f.Guardian_Id != null && f.Guardian_Id.Trim().Equals(cleanUid, StringComparison.OrdinalIgnoreCase))
                        .Select(f => f.Uid != null ? f.Uid.Trim() : null)
                        .Where(u => !string.IsNullOrWhiteSpace(u) && !u.Equals(cleanUid, StringComparison.OrdinalIgnoreCase))
                        .Distinct(StringComparer.OrdinalIgnoreCase)
                        .ToList();

                    HashSet<string> targetVictimUids = new HashSet<string>(protectedVictimUids, StringComparer.OrdinalIgnoreCase);

                    foreach (var a in allAlerts)
                    {
                        if (processedAccidentIds.Contains(a.Accident_Id)) continue;

                        string carUid = null;
                        if (a.Accident != null)
                        {
                            var car = db.Cars.FirstOrDefault(c => c.Car_Id == a.Accident.Car_Id) ?? a.Accident.Car;
                            if (car != null && !string.IsNullOrWhiteSpace(car.Uid))
                            {
                                carUid = car.Uid.Trim();
                            }
                        }

                        // STRICT CRITERIA:
                        // 1. Alert must NOT belong to the querying user's own car (driver never sees own accident alert)
                        // 2. Alert must belong to a protected family member who registered cleanUid as guardian
                        if (!string.IsNullOrWhiteSpace(carUid) &&
                            !carUid.Equals(cleanUid, StringComparison.OrdinalIgnoreCase) &&
                            targetVictimUids.Contains(carUid))
                        {
                            resultList.Add(MapToDto(a, "Guardian", cleanUid));
                            processedAccidentIds.Add(a.Accident_Id);
                        }
                    }
                }
                else if (rid.HasValue && rid.Value > 0)
                {
                    // 2. RESCUE TEAM QUERY (NEAREST DISPATCH SELECTION)
                    var allRescueTeams = db.Rescues.ToList();

                    foreach (var a in allAlerts)
                    {
                        if (processedAccidentIds.Contains(a.Accident_Id)) continue;

                        bool isNearestRescue = false;
                        string accidentLoc = a.Accident != null ? a.Accident.Location : null;

                        if (allRescueTeams.Count <= 1)
                        {
                            isNearestRescue = true;
                        }
                        else if (TryExtractCoordinates(accidentLoc, out double accLat, out double accLng))
                        {
                            Rescue closestRescue = null;
                            double minDistanceKm = double.MaxValue;

                            foreach (var rescue in allRescueTeams)
                            {
                                if (TryExtractCoordinates(rescue.Location, out double rLat, out double rLng))
                                {
                                    double dist = CalculateHaversineDistance(accLat, accLng, rLat, rLng);
                                    if (dist < minDistanceKm)
                                    {
                                        minDistanceKm = dist;
                                        closestRescue = rescue;
                                    }
                                }
                            }

                            if (closestRescue == null || closestRescue.Rid == rid.Value)
                            {
                                isNearestRescue = true;
                            }
                        }
                        else
                        {
                            isNearestRescue = true;
                        }

                        if (isNearestRescue)
                        {
                            resultList.Add(MapToDto(a, "Rescue"));
                            processedAccidentIds.Add(a.Accident_Id);
                        }
                    }
                }
                else
                {
                    // Unauthenticated or empty queries receive an empty list (strictly never dump all alerts)
                    return Request != null ? Request.CreateResponse(HttpStatusCode.OK, resultList) : new HttpResponseMessage(HttpStatusCode.OK);
                }

                return Request != null ? Request.CreateResponse(HttpStatusCode.OK, resultList) : new HttpResponseMessage(HttpStatusCode.OK);
            }
            catch (Exception ex)
            {
                return Request != null ? Request.CreateResponse(HttpStatusCode.InternalServerError, new { error = ex.Message }) : new HttpResponseMessage(HttpStatusCode.InternalServerError);
            }
        }

        // =========================================================================
        // FEATURE 2 - API 3: POST /api/Alerts/MarkAsRead
        // =========================================================================
        /// <summary>
        /// Accepts an Alert_Id and removes all active alerts associated with that accident
        /// so seen alerts are never fetched again.
        /// </summary>
        [HttpPost]
        [Route("MarkAsRead")]
        [Route("MarkAsSeen")]
        [ActionName("MarkAsRead")]
        public HttpResponseMessage MarkAsRead([FromBody] MarkAsReadRequest request)
        {
            try
            {
                if (request == null || request.Alert_Id <= 0)
                {
                    return Request != null ? Request.CreateResponse(HttpStatusCode.BadRequest, new { message = "Invalid Alert ID" }) : new HttpResponseMessage(HttpStatusCode.BadRequest);
                }

                var alert = db.Alerts.FirstOrDefault(a => a.Alert_Id == request.Alert_Id);
                if (alert == null)
                {
                    return Request != null ? Request.CreateResponse(HttpStatusCode.NotFound, new { message = "Alert not found" }) : new HttpResponseMessage(HttpStatusCode.NotFound);
                }

                int accidentId = alert.Accident_Id;
                var relatedAlerts = db.Alerts.Where(a => a.Accident_Id == accidentId).ToList();

                foreach (var rAlert in relatedAlerts)
                {
                    rAlert.Status = true;
                }
                db.SaveChanges();

                var responseObj = new
                {
                    status = "SUCCESS",
                    message = $"Alert #{request.Alert_Id} processed and removed successfully."
                };

                return Request != null ? Request.CreateResponse(HttpStatusCode.OK, responseObj) : new HttpResponseMessage(HttpStatusCode.OK);
            }
            catch (Exception ex)
            {
                return Request != null ? Request.CreateResponse(HttpStatusCode.InternalServerError, new { error = ex.Message }) : new HttpResponseMessage(HttpStatusCode.InternalServerError);
            }
        }

        private UnreadAlertDto MapToDto(Alert a, string targetType, string viewerUid = null)
        {
            string victimUid = "Unknown";
            string victimName = "Victim";
            string victimContact = "";
            string vehicleMake = "Vehicle";
            string regNo = "Unknown";
            string impactSide = "Front";
            string relationship = targetType == "Rescue" ? "Rescue Dispatch" : "Family Member";

            if (a.Accident != null)
            {
                impactSide = !string.IsNullOrWhiteSpace(a.Accident.Impact_Side) ? a.Accident.Impact_Side.Trim() : "Front";

                var car = db.Cars.FirstOrDefault(c => c.Car_Id == a.Accident.Car_Id) ?? a.Accident.Car;
                if (car != null)
                {
                    vehicleMake = !string.IsNullOrWhiteSpace(car.Make) ? car.Make.Trim() : "Car";
                    regNo = !string.IsNullOrWhiteSpace(car.Registration_No) ? car.Registration_No.Trim() : "-";
                    if (!string.IsNullOrWhiteSpace(car.Uid))
                    {
                        victimUid = car.Uid.Trim();
                    }

                    // Look up user by car.Uid case-insensitively and trimmed
                    string cleanCarUid = victimUid.ToLower();
                    var user = car.User ?? db.Users.FirstOrDefault(u => u.Uid != null && u.Uid.Trim().ToLower() == cleanCarUid);
                    if (user != null)
                    {
                        if (!string.IsNullOrWhiteSpace(user.Name))
                        {
                            string rawName = user.Name.Trim();
                            if (rawName.Contains("@"))
                            {
                                rawName = rawName.Split('@')[0];
                            }
                            victimName = System.Globalization.CultureInfo.CurrentCulture.TextInfo.ToTitleCase(rawName.ToLower());
                        }
                        else
                        {
                            string rawUid = !string.IsNullOrWhiteSpace(user.Uid) ? user.Uid.Trim() : victimUid;
                            if (rawUid.Contains("@"))
                            {
                                rawUid = rawUid.Split('@')[0];
                            }
                            victimName = System.Globalization.CultureInfo.CurrentCulture.TextInfo.ToTitleCase(rawUid.ToLower());
                        }

                        victimContact = !string.IsNullOrWhiteSpace(user.Contact_No) ? user.Contact_No.Trim() : "";
                    }
                    else if (!string.IsNullOrWhiteSpace(victimUid) && victimUid.Contains("@"))
                    {
                        string clean = victimUid.Split('@')[0];
                        victimName = System.Globalization.CultureInfo.CurrentCulture.TextInfo.ToTitleCase(clean.ToLower());
                    }
                }

                // If queried by a guardian/family member, look up the specific relationship configured by the victim
                if (!string.IsNullOrWhiteSpace(viewerUid) && !string.IsNullOrWhiteSpace(victimUid))
                {
                    string cleanViewer = viewerUid.Trim().ToLower();
                    string cleanVictim = victimUid.Trim().ToLower();

                    // Victim added viewerUid as Guardian: f.Uid == victim && f.Guardian_Id == viewer
                    var fam = db.FamilyMembers.FirstOrDefault(f =>
                        f.Uid != null && f.Uid.Trim().ToLower() == cleanVictim &&
                        f.Guardian_Id != null && f.Guardian_Id.Trim().ToLower() == cleanViewer);

                    if (fam == null)
                    {
                        fam = db.FamilyMembers.FirstOrDefault(f =>
                            f.Guardian_Id != null && f.Guardian_Id.Trim().ToLower() == cleanVictim &&
                            f.Uid != null && f.Uid.Trim().ToLower() == cleanViewer);
                    }

                    if (fam != null && !string.IsNullOrWhiteSpace(fam.Relationship))
                    {
                        relationship = fam.Relationship.Trim();
                    }
                }
            }

            return new UnreadAlertDto
            {
                Alert_Id = a.Alert_Id,
                Accident_Id = a.Accident_Id,
                Location = a.Accident != null ? a.Accident.Location : "Unknown",
                ImpactForce = a.Accident != null ? a.Accident.ImpactForce : 0,
                CabinForce = a.Accident != null ? a.Accident.CabinForce : 0,
                Severity = a.Accident != null ? a.Accident.Severity : "High",
                Time = a.Time,
                Status = false,
                VictimUid = victimUid,
                VictimName = victimName,
                VictimContact = victimContact,
                VehicleMake = vehicleMake,
                RegistrationNo = regNo,
                ImpactSide = impactSide,
                Relationship = relationship,
                TargetType = targetType
            };
        }

        // =========================================================================
        // COORDINATE EXTRACTOR HELPER METHOD
        // Supports plain "lat,lng" as well as Google Maps URLs (e.g. "https://www.google.com/maps?q=33.642,73.079")
        // =========================================================================
        private static bool TryExtractCoordinates(string loc, out double lat, out double lng)
        {
            lat = 0;
            lng = 0;
            if (string.IsNullOrWhiteSpace(loc)) return false;

            string clean = loc.Trim();
            if (clean.Contains("q="))
            {
                clean = clean.Substring(clean.IndexOf("q=") + 2);
                if (clean.Contains("&"))
                {
                    clean = clean.Substring(0, clean.IndexOf("&"));
                }
            }

            var parts = clean.Split(',');
            if (parts.Length >= 2 &&
                double.TryParse(parts[0].Trim(), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out lat) &&
                double.TryParse(parts[1].Trim(), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out lng))
            {
                return true;
            }

            return false;
        }

        // =========================================================================
        // HAVERSINE DISTANCE HELPER METHOD (C#)
        // =========================================================================
        private static double CalculateHaversineDistance(double lat1, double lon1, double lat2, double lon2)
        {
            double R = 6371.0; // Earth radius in kilometers
            double dLat = ToRadians(lat2 - lat1);
            double dLon = ToRadians(lon2 - lon1);

            double a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                       Math.Cos(ToRadians(lat1)) * Math.Cos(ToRadians(lat2)) *
                       Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

            double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            return R * c;
        }

        private static double ToRadians(double angle)
        {
            return (Math.PI / 180.0) * angle;
        }
    }
}


