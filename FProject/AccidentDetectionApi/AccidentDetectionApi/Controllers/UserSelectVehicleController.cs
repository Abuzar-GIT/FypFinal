using AccidentDetectionApi;
using AccidentDetectionApi.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Cryptography;
using System.Web.Http;

namespace AccidentDetectionApi.Controllers
{
   
    public class UserSelectVehicleController : ApiController
    {
        AccidentDetectionDBEntities db = new AccidentDetectionDBEntities();

        //     [HttpGet]
        //[Route("api/UserSelectVehicle/showVehicle")]
        //[Route("showVehicle")]
        //public HttpResponseMessage showVehicle(string email)
        //{
        //    try
        //    {
        //        if (string.IsNullOrWhiteSpace(email))
        //        {
        //            return Request.CreateResponse(
        //                HttpStatusCode.BadRequest,
        //                "Email is required"
        //            );
        //        }

        //        string normalizedEmail = email.Trim().ToLower();

        //        var user = db.Users.FirstOrDefault(
        //            u => u.Uid.ToLower() == normalizedEmail
        //        );

        //        if (user == null)
        //        {
        //            return Request.CreateResponse(
        //                HttpStatusCode.NotFound,
        //                "User not found"
        //            );
        //        }

        //        var data = db.Cars
        //            .Include("User")
        //            .Include("Category")
        //            .Where(c => c.Uid.ToLower() == normalizedEmail)
        //            .Select(c => new
        //            {
        //                c.Car_Id,
        //                c.Registration_No,
        //                c.Make,
        //                UName = c.User.Uid,
        //                CName = c.Category.Name,

        //                // FETCHED FROM DATABASE
        //                Steering_Side = c.Steering_Side
        //            })
        //            .ToList();

        //        return Request.CreateResponse(
        //            HttpStatusCode.OK,
        //            data
        //        );
        //    }
        //    catch (Exception ex)
        //    {
        //        return Request.CreateResponse(
        //            HttpStatusCode.InternalServerError,
        //            ex.Message
        //        );
        //    }
        //}        
        [HttpGet]
        [Route("api/UserSelectVehicle/showVehicle")]
        [Route("showVehicle")]
        public HttpResponseMessage showVehicle(string email)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(email))
                {
                    return Request.CreateResponse(
                        HttpStatusCode.BadRequest,
                        "Email is required"
                    );
                }

                string normalizedEmail = email.Trim().ToLower();

                var user = db.Users.FirstOrDefault(
                    u => u.Uid.ToLower() == normalizedEmail
                );

                if (user == null)
                {
                    return Request.CreateResponse(
                        HttpStatusCode.NotFound,
                        "User not found"
                    );
                }

                var data = db.Cars
                    .Include("User")
                    .Include("Category")
                    .Where(c => c.Uid.ToLower() == normalizedEmail)
                    .Select(c => new
                    {
                        c.Car_Id,
                        c.Registration_No,
                        c.Make,
                        UName = c.User.Uid,
                        CName = c.Category.Name,

                        // FETCHED FROM DATABASE
                        Steering_Side = c.Steering_Side
                    })
                    .ToList();

                return Request.CreateResponse(
                    HttpStatusCode.OK,
                    data
                );
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(
                    HttpStatusCode.InternalServerError,
                    ex.Message
                );
            }
        }

        // ================= GET CATEGORIES =================
        [HttpGet]
        [Route("api/UserSelectVehicle/GetCategories")]
        [Route("GetCategories")]
        public HttpResponseMessage GetCategories()
        {
            try
            {
                var categories = db.Categories.Select(c => new
                {
                    c.Category_Id,
                    c.Name,
                    c.Weight
                }).ToList();

                return Request.CreateResponse(HttpStatusCode.OK, categories);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex.Message);
            }
        }

        // ================= ADD VEHICLE =================

        [HttpPost]
        [Route("api/UserSelectVehicle/AddVehicle")]
        [Route("AddVehicle")]
        public HttpResponseMessage AddVehicle([FromBody] Car car)
        {
            try
            {
                // Check request body
                if (car == null)
                {
                    return Request.CreateResponse(
                        HttpStatusCode.BadRequest,
                        "Vehicle data is null"
                    );
                }

                // Check registration number
                if (string.IsNullOrWhiteSpace(car.Registration_No))
                {
                    return Request.CreateResponse(
                        HttpStatusCode.BadRequest,
                        "Registration number is required"
                    );
                }

                // Check user ID / email
                if (string.IsNullOrWhiteSpace(car.Uid))
                {
                    return Request.CreateResponse(
                        HttpStatusCode.BadRequest,
                        "User ID is required"
                    );
                }

                string regNo = car.Registration_No.Trim().ToUpper();
                string uid = car.Uid.Trim().ToLower();
                string steeringSide = car.Steering_Side?.Trim().ToLower();

                // =====================================================
                // CHECK USER
                // =====================================================

                var user = db.Users.FirstOrDefault(
                    u => u.Uid.ToLower() == uid
                );

                if (user == null)
                {
                    return Request.CreateResponse(
                        HttpStatusCode.NotFound,
                        "User not found: " + car.Uid
                    );
                }

                // =====================================================
                // CHECK CATEGORY
                // =====================================================

                var category = db.Categories.FirstOrDefault(
                    c => c.Category_Id == car.Category_Id
                );

                if (category == null)
                {
                    return Request.CreateResponse(
                        HttpStatusCode.NotFound,
                        "Category not found"
                    );
                }

                // =====================================================
                // CHECK DUPLICATE REGISTRATION
                // =====================================================

                bool vehicleExists = db.Cars.Any(
                    c => c.Registration_No.ToUpper() == regNo
                );

                if (vehicleExists)
                {
                    return Request.CreateResponse(
                        HttpStatusCode.Conflict,
                        "Vehicle with this registration number already exists"
                    );
                }

                // =====================================================
                // ADD VEHICLE
                // =====================================================

                car.Registration_No = regNo;
                car.Uid = user.Uid;
                car.Steering_Side = steeringSide;
                if (car.Make != null)
                {
                    car.Make = car.Make.Trim();
                }

                db.Cars.Add(car);

                // =====================================================
                // SAVE TO DATABASE
                // =====================================================

                db.SaveChanges();

                return Request.CreateResponse(
                    HttpStatusCode.OK,
                    new
                    {
                        message = "Vehicle added successfully",
                        carId = car.Car_Id
                    }
                );
            }
            catch (Exception ex)
            {
                // Get the real inner exception
                string errorMessage = ex.Message;

                if (ex.InnerException != null)
                {
                    errorMessage +=
                        " | Inner: " +
                        ex.InnerException.Message;
                }

                return Request.CreateResponse(
                    HttpStatusCode.InternalServerError,
                    errorMessage
                );
            }
        }

        // ================= REMOVE VEHICLE =================
        // ✅ URL: api/UserSelectVehicle/deleteVehicle?carId=1
        [HttpDelete]
        [Route("api/UserSelectVehicle/DeleteVehicle")]
        [Route("DeleteVehicle")]
        public HttpResponseMessage DeleteVehicle(int carId)
        {
            try
            {
                var car = db.Cars.FirstOrDefault(c => c.Car_Id == carId);

                if (car == null)
                {
                    return Request.CreateResponse(HttpStatusCode.NotFound, "Vehicle not found");
                }

                db.Cars.Remove(car);
                db.SaveChanges();

                return Request.CreateResponse(HttpStatusCode.OK, "Vehicle removed successfully");
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex.Message);
            }
        }


       
    }
}
