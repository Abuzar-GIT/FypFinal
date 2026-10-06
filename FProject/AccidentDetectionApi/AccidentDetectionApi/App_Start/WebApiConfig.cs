using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;

namespace AccidentDetectionApi
{
    public static class WebApiConfig
    {
       
        //
        public static void Register(HttpConfiguration config)
        {
            // Fix self referencing loop
            config.Formatters.JsonFormatter.SerializerSettings.ReferenceLoopHandling
                = Newtonsoft.Json.ReferenceLoopHandling.Ignore;

            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{action}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );
        }
    }
}
