using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using AccidentDetectionApi.Models;

namespace AccidentDetectionApi.Controllers
{
    public class AuthController : ApiController
    {
        AccidentDetectionDBEntities db = new AccidentDetectionDBEntities();

        // ================= LOGIN =================
        [HttpPost]
        public HttpResponseMessage Login(string email, string pas)
        {
            try
            {
                if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(pas))
                {
                    return Request.CreateResponse(HttpStatusCode.BadRequest, "Email and password required");
                }

                var user = db.Users.FirstOrDefault(u => u.Uid == email);

                if (user == null)
                {
                    return Request.CreateResponse(HttpStatusCode.NotFound, "User not found");
                }

                if (user.Password != pas)
                {
                    return Request.CreateResponse(HttpStatusCode.Unauthorized, "Incorrect password");
                }

                return Request.CreateResponse(HttpStatusCode.OK, new
                {
                    Uid = user.Uid,
                    Name = user.Name,
                    Role = user.Role,
                    //ContactNo = user.Contact_No
                });
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex.Message);
            }
        }

        // ================= SIGNUP =================
        [HttpPost]
        public HttpResponseMessage CreateUser(User u)
        {
            try
            {
                if (u == null ||
                    string.IsNullOrEmpty(u.Uid) ||
                    string.IsNullOrEmpty(u.Password) ||
                    string.IsNullOrEmpty(u.Name) ||
                    string.IsNullOrEmpty(u.Contact_No))
                {
                    return Request.CreateResponse(HttpStatusCode.BadRequest, "All fields are required");
                }

                if (db.Users.Any(x => x.Uid == u.Uid))
                {
                    return Request.CreateResponse(HttpStatusCode.Conflict, "User already exists");
                }

                db.Users.Add(u);
                db.SaveChanges();

                return Request.CreateResponse(HttpStatusCode.OK, "User Registered Successfully");
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex.Message);
            }
        }

        // ================= FORGOT PASSWORD =================
        [HttpPost]
        public HttpResponseMessage ForgotPassword(string email, string newPassword, string confirmPassword)
        {
            try
            {
                if (string.IsNullOrEmpty(email) ||
                    string.IsNullOrEmpty(newPassword) ||
                    string.IsNullOrEmpty(confirmPassword))
                {
                    return Request.CreateResponse(HttpStatusCode.BadRequest, "All fields are required");
                }

                if (newPassword != confirmPassword)
                {
                    return Request.CreateResponse(HttpStatusCode.BadRequest, "Passwords do not match");
                }

                var user = db.Users.FirstOrDefault(x => x.Uid == email);

                if (user == null)
                {
                    return Request.CreateResponse(HttpStatusCode.NotFound, "User not found");
                }

                user.Password = newPassword;
                db.SaveChanges();

                return Request.CreateResponse(HttpStatusCode.OK, "Password updated successfully");
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex.Message);
            }
        }
    }
}

