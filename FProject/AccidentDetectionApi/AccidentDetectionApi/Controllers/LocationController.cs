using AccidentDetectionApi;
using AccidentDetectionApi.Models;
using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AccidentDetectionApi.Controllers
{
    [RoutePrefix("api/Location")]
    public class LocationController : ApiController
    {
        AccidentDetectionDBEntities db = new AccidentDetectionDBEntities();

        // ================= ADD ACCIDENT (NO FAKE CALCULATION) =================
       

        // ================= GET LATEST =================
        [HttpGet]
        [Route("latest")]
        public HttpResponseMessage Latest()
        {
            try
            {
                var last = db.Accidents
                    .OrderByDescending(a => a.Accident_Id)
                    .FirstOrDefault();
                if (last == null)
                {
                    return Request.CreateResponse(HttpStatusCode.OK, new
                    {
                        impactSide = "-",
                        force = "OFF",
                        cabinDamage = 0,
                        lastEvent = "-"
                    });
                }

                return Request.CreateResponse(HttpStatusCode.OK, new
                {
                    impactSide = last.Impact_Side,
                    force = (last.ImpactForce.HasValue && last.ImpactForce > 0) ? "ON" : "OFF",
                    cabinDamage = last.CabinForce ?? 0,
                    lastEvent = last.Accident_Id
                });
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex.Message);
            }
        }
    }
}