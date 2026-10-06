using AccidentDetectionApi;
using AccidentDetectionApi.Models;
using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AccidentDetectionApi.Controllers
{
    [RoutePrefix("api/Rescue")]
    public class RescueController : ApiController
    {
        private AccidentDetectionDBEntities db = new AccidentDetectionDBEntities();

        //public class RescueRegisterRequest
        //{
        //    public string Password { get; set; }
        //    public string Location { get; set; }
        //}

        //public class RescueLoginRequest
        //{
        //    public int Rid { get; set; }
        //    public string Password { get; set; }
        //    public string Location { get; set; }
        //}

        //public class LocationUpdateRequest
        //{
        //    public int Rid { get; set; }
        //    public string Location { get; set; }
        //}

        // =========================================================================
        // POST /api/Rescue/Register
        // =========================================================================
        [HttpPost]
        [Route("Register")]
        [ActionName("Register")]
        public HttpResponseMessage Register([FromBody] Rescue request)
        {
            try
            {
                if (request == null || string.IsNullOrWhiteSpace(request.Password))
                {
                    var badReq = new { Status = "ERROR", Message = "Password is required.", message = "Password is required." };
                    return Request != null ? Request.CreateResponse(HttpStatusCode.BadRequest, badReq) : new HttpResponseMessage(HttpStatusCode.BadRequest);
                }

                var rescue = new Rescue
                {
                    Password = request.Password.Trim(),
                    Location = !string.IsNullOrWhiteSpace(request.Location) ? request.Location.Trim() : null
                };

                db.Rescues.Add(rescue);
                db.SaveChanges();

                var successObj = new
                {
                    Status = "SUCCESS",
                    Message = "Rescue registered successfully.",
                    message = "Rescue registered successfully.",
                    Rid = rescue.Rid,
                    Location = rescue.Location
                };

                return Request != null ? Request.CreateResponse(HttpStatusCode.OK, successObj) : new HttpResponseMessage(HttpStatusCode.OK);
            }
            catch (Exception ex)
            {
                var errObj = new { Status = "ERROR", Message = ex.Message, message = ex.Message };
                return Request != null ? Request.CreateResponse(HttpStatusCode.InternalServerError, errObj) : new HttpResponseMessage(HttpStatusCode.InternalServerError);
            }
        }

        // =========================================================================
        // POST /api/Rescue/Login
        // =========================================================================
        [HttpPost]
        [Route("Login")]
        [ActionName("Login")]
        public HttpResponseMessage Login([FromBody] Rescue request)
        {
            try
            {
                if (request == null || request.Rid <= 0 || string.IsNullOrWhiteSpace(request.Password))
                {
                    var badReq = new { Status = "ERROR", Message = "Rescue ID and Password are required.", message = "Rescue ID and Password are required." };
                    return Request != null ? Request.CreateResponse(HttpStatusCode.BadRequest, badReq) : new HttpResponseMessage(HttpStatusCode.BadRequest);
                }

                var rescue = db.Rescues.FirstOrDefault(r => r.Rid == request.Rid);
                if (rescue == null)
                {
                    var notFound = new { Status = "ERROR", Message = "Rescue ID not found.", message = "Rescue ID not found." };
                    return Request != null ? Request.CreateResponse(HttpStatusCode.NotFound, notFound) : new HttpResponseMessage(HttpStatusCode.NotFound);
                }

                if (rescue.Password != request.Password.Trim())
                {
                    var unauth = new { Status = "ERROR", Message = "Incorrect password.", message = "Incorrect password." };
                    return Request != null ? Request.CreateResponse(HttpStatusCode.Unauthorized, unauth) : new HttpResponseMessage(HttpStatusCode.Unauthorized);
                }

                if (!string.IsNullOrWhiteSpace(request.Location))
                {
                    rescue.Location = request.Location.Trim();
                    db.SaveChanges();
                }

                var okObj = new
                {
                    Status = "SUCCESS",
                    Message = "Rescue login successful.",
                    message = "Rescue login successful.",
                    Rid = rescue.Rid,
                    Location = rescue.Location
                };

                return Request != null ? Request.CreateResponse(HttpStatusCode.OK, okObj) : new HttpResponseMessage(HttpStatusCode.OK);
            }
            catch (Exception ex)
            {
                var errObj = new { Status = "ERROR", Message = ex.Message, message = ex.Message };
                return Request != null ? Request.CreateResponse(HttpStatusCode.InternalServerError, errObj) : new HttpResponseMessage(HttpStatusCode.InternalServerError);
            }
        }

        // =========================================================================
        // POST /api/Rescue/UpdateLocation
        // =========================================================================
        [HttpPost]
        [Route("UpdateLocation")]
        [ActionName("UpdateLocation")]
        public HttpResponseMessage UpdateLocation([FromBody] Rescue request)
        {
            try
            {
                if (request == null || request.Rid <= 0 || string.IsNullOrWhiteSpace(request.Location))
                {
                    var badReq = new { Status = "ERROR", Message = "Rid and Location are required.", message = "Rid and Location are required." };
                    return Request != null ? Request.CreateResponse(HttpStatusCode.BadRequest, badReq) : new HttpResponseMessage(HttpStatusCode.BadRequest);
                }

                var rescue = db.Rescues.FirstOrDefault(r => r.Rid == request.Rid);
                if (rescue == null)
                {
                    var notFound = new { Status = "ERROR", Message = "Rescue team not found.", message = "Rescue team not found." };
                    return Request != null ? Request.CreateResponse(HttpStatusCode.NotFound, notFound) : new HttpResponseMessage(HttpStatusCode.NotFound);
                }

                rescue.Location = request.Location.Trim();
                db.SaveChanges();

                var okObj = new { Status = "SUCCESS", Message = "Rescue location updated successfully.", message = "Rescue location updated successfully." };
                return Request != null ? Request.CreateResponse(HttpStatusCode.OK, okObj) : new HttpResponseMessage(HttpStatusCode.OK);
            }
            catch (Exception ex)
            {
                var errObj = new { Status = "ERROR", Message = ex.Message, message = ex.Message };
                return Request != null ? Request.CreateResponse(HttpStatusCode.InternalServerError, errObj) : new HttpResponseMessage(HttpStatusCode.InternalServerError);
            }
        }
    }
}

