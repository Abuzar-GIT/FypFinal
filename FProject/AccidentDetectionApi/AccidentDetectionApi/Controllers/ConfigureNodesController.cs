using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using AccidentDetectionApi.Models;

namespace AccidentDetectionApi.Controllers
{
    [RoutePrefix("api/ConfigureNodes")]
    public class ConfigureNodesController : ApiController
    {
        AccidentDetectionDBEntities db = new AccidentDetectionDBEntities();

        // ================= SAVE CONFIGURATION =================
        // ✅ URL: api/ConfigureNodes/SaveConfiguration?weight=1500
        [HttpPost]
        [Route("SaveConfiguration")]
        public HttpResponseMessage SaveConfiguration(
     [FromBody] List<Node> nodes,
     [FromUri] double weight
 )
        {
            try
            {
                if (nodes == null || !nodes.Any())
                {
                    return Request.CreateResponse(HttpStatusCode.BadRequest, "No configuration data provided.");
                }

                int categoryId = nodes.First().Category_Id;

                // ✅ FIXED (DYNAMIC CATEGORY)
                var category = db.Categories.FirstOrDefault(c => c.Category_Id == categoryId);

                if (category != null)
                {
                    category.Weight = (decimal)weight;
                }

                // ================= EXISTING NODES =================
                var existingNodes = db.Nodes
                    .Where(n => n.Category_Id == categoryId)
                    .ToList();

                foreach (var payload in nodes)
                {
                    var node = existingNodes.FirstOrDefault(n =>
                        n.Node_Id == payload.Node_Id &&
                        n.Category_Id == payload.Category_Id);

                    if (node != null)
                    {
                        // 🔁 UPDATE
                        node.Node_Position = payload.Node_Position;
                        node.Force = payload.Force;
                    }
                    else
                    {
                        // 🆕 INSERT
                        db.Nodes.Add(new Node
                        {
                            Node_Id = payload.Node_Id,
                            Category_Id = payload.Category_Id,
                            Node_Position = payload.Node_Position,
                            Force = payload.Force
                        });
                    }
                }

                db.SaveChanges();

                return Request.CreateResponse(HttpStatusCode.OK,
                    "Nodes + Weight saved successfully.");
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex.Message);
            }
        }
        // ================= GET NODES =================
        [HttpGet]
        [Route("GetNodes")]
      
        public HttpResponseMessage GetNodes([FromUri] int categoryId)
        {
            try
            {
                var nodes = db.Nodes
                    .Where(n => n.Category_Id == categoryId)
                    .Select(n => new
                    {
                        n.Node_Id,
                        n.Category_Id,
                        n.Node_Position,
                        n.Force
                    })
                    .ToList();

                // ✅ GET CATEGORY WEIGHT
                var category = db.Categories
                    .FirstOrDefault(c => c.Category_Id == categoryId);

                var result = new
                {
                    Nodes = nodes,
                    Weight = category != null ? category.Weight : 0
                };

                return Request.CreateResponse(HttpStatusCode.OK, result);
            }
            catch (Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex.Message);
            }
        }
    }
}

