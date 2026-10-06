using AccidentDetectionApi;
using AccidentDetectionApi.Models;
using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AccidentDetectionApi.Controllers
{
    [RoutePrefix("api/FamilyMembers")]
    public class FamilyMembersController : ApiController
    {
        private AccidentDetectionDBEntities db = new AccidentDetectionDBEntities();

        //public class AddFamilyMemberRequest
        //{
        //    public string Uid { get; set; }
        //    public string Guardian_Id { get; set; }
        //    public string Relationship { get; set; }
        //}

        // =========================================================================
        // FEATURE 3 API: POST /api/FamilyMembers/Add
        // =========================================================================
        /// <summary>
        /// Saves a new guardian relationship in the FamilyMembers table for a user.
        /// </summary>
        [HttpPost]
        [Route("Add")]
        public HttpResponseMessage AddFamilyMember([FromBody]FamilyMember request)
        {
            try
            {
                if (request == null || string.IsNullOrWhiteSpace(request.Uid) || string.IsNullOrWhiteSpace(request.Guardian_Id))
                {
                    return Request.CreateResponse(HttpStatusCode.BadRequest, new { Message = "User ID and Guardian ID are required." });
                }

                if (request.Uid.Equals(request.Guardian_Id, StringComparison.OrdinalIgnoreCase))
                {
                    return Request.CreateResponse(HttpStatusCode.BadRequest, new { Message = "User cannot be their own guardian." });
                }

                // Check if user exists
                var userExists = db.Users.Any(u => u.Uid == request.Uid);
                if (!userExists)
                {
                    return Request.CreateResponse(HttpStatusCode.NotFound, new { Message = "User ID not found." });
                }

                // Check if guardian exists in User table
                var guardianUser = db.Users.FirstOrDefault(u => u.Uid == request.Guardian_Id);
                if (guardianUser == null)
                {
                    return Request.CreateResponse(HttpStatusCode.NotFound, new { Message = "Guardian User ID does not exist in the system." });
                }

                // Check for duplicate relation
                var existingRelation = db.FamilyMembers.FirstOrDefault(f => f.Uid == request.Uid && f.Guardian_Id == request.Guardian_Id);
                if (existingRelation != null)
                {
                    return Request.CreateResponse(HttpStatusCode.Conflict, new { Message = "This guardian is already added to your family members." });
                }

                // Create new FamilyMember record
                var newMember = new FamilyMember
                {
                    Uid = request.Uid,
                    Guardian_Id = request.Guardian_Id,
                    Relationship = string.IsNullOrWhiteSpace(request.Relationship) ? "Guardian" : request.Relationship
                };

                db.FamilyMembers.Add(newMember);
                db.SaveChanges();

                return Request.CreateResponse(HttpStatusCode.OK, new
                {
                    Status = "SUCCESS",
                    Message = "Family guardian added successfully.",
                    Data = new
                    {
                        newMember.Family_Id,
                        newMember.Uid,
                        newMember.Guardian_Id,
                        newMember.Relationship
                    }
                });
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, new { Message = "Server error: " + ex.Message });
            }
        }

        // =========================================================================
        // GET /api/FamilyMembers/GetGuardians?uid={uid}
        // =========================================================================
        [HttpGet]
        [Route("GetGuardians")]
        public HttpResponseMessage GetGuardians(string uid)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(uid))
                {
                    return Request.CreateResponse(HttpStatusCode.BadRequest, new { Message = "UID parameter required." });
                }

                var guardians = db.FamilyMembers
                    .Where(f => f.Uid == uid)
                    .Select(f => new
                    {
                        f.Family_Id,
                        f.Uid,
                        f.Guardian_Id,
                        f.Relationship,
                        GuardianName = f.User1 != null ? f.User1.Name : f.Guardian_Id,
                        GuardianContact = f.User1 != null ? f.User1.Contact_No : ""
                    })
                    .ToList();

                return Request.CreateResponse(HttpStatusCode.OK, guardians);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, new { Message = ex.Message });
            }
        }
    }
}
