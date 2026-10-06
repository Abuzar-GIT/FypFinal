using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using Newtonsoft.Json;

namespace AccidentDetectionApi.Models
{
    public class AccidentRequest
    {
        public int Car_Id { get; set; }
        public int? CarId
        {
            get => Car_Id;
            set { if (value.HasValue && value.Value > 0) Car_Id = value.Value; }
        }
        public double Acceleration { get; set; }
        public double? GForce { get; set; }
        public double? ImpactDurationMs { get; set; }
        public string SteeringSide { get; set; }
        public string Steering_Side
        {
            get => SteeringSide;
            set { if (!string.IsNullOrWhiteSpace(value)) SteeringSide = value; }
        }
        public double AccelX { get; set; }
        public double AccelY { get; set; }
        public double AccelZ { get; set; }
        public double GyroX { get; set; }
        public double GyroY { get; set; }
        public double GyroZ { get; set; }
        public double? GravityX { get; set; }
        public double? GravX
        {
            get => GravityX;
            set { if (value.HasValue) GravityX = value.Value; }
        }
        public double? GravityY { get; set; }
        public double? GravY
        {
            get => GravityY;
            set { if (value.HasValue) GravityY = value.Value; }
        }
        public double? GravityZ { get; set; }
        public double? GravZ
        {
            get => GravityZ;
            set { if (value.HasValue) GravityZ = value.Value; }
        }
        public bool? IsFreeFall { get; set; }
        public double? FreeFallDurationMs { get; set; }
        public string AccidentType { get; set; }
        public string ImpactSide { get; set; }
        public string Impact_Side { get => ImpactSide; set => ImpactSide = value; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public string Location { get; set; }
        public string Severity { get; set; }

        [JsonConverter(typeof(FlexibleDateTimeConverter))]
        public DateTime? Time { get; set; }

        public double? ToyMassKg { get; set; }
        public double? VehicleMassKg { get; set; }

        // 4-Meter Test Track Distance/Time Calibration (Committee Demo Feature)
        public double? ElapsedTimeSeconds { get; set; }
        public double? Elapsed_Time_Seconds
        {
            get => ElapsedTimeSeconds;
            set { if (value.HasValue) ElapsedTimeSeconds = value.Value; }
        }
        public double? TrackDistanceMeters { get; set; } = 4.0;
        public double? Track_Distance_Meters
        {
            get => TrackDistanceMeters;
            set { if (value.HasValue) TrackDistanceMeters = value.Value; }
        }

        // Dual-Scenario Mode Telemetry (Stationary Mode vs. Active Driving Mode)
        public bool IsDrivingMode { get; set; } = false;
        public bool? Is_Driving_Mode
        {
            get => IsDrivingMode;
            set { if (value.HasValue) IsDrivingMode = value.Value; }
        }

        public bool IsManualHardBrake { get; set; } = false;
        public bool? Is_Manual_Hard_Brake
        {
            get => IsManualHardBrake;
            set { if (value.HasValue) IsManualHardBrake = value.Value; }
        }
    }

    public class UpdateLiveLocationRequest
    {
        public int AccidentId { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
    }

    public class LiveLocationRequest
    {
        public int AccidentId { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
    }

    public class TelemetryPayload
    {
        public int? CarId { get; set; }
        public string UserId { get; set; }
        public double AccelX { get; set; }
        public double AccelY { get; set; }
        public double AccelZ { get; set; }
        public double ImpactDurationMs { get; set; }
        public int ImpactNode { get; set; }
    }

    /// <summary>
    /// Robust converter handling ISO strings, standard formatted strings, and empty values gracefully.
    /// </summary>
    public class FlexibleDateTimeConverter : JsonConverter
    {
        public override bool CanConvert(Type objectType) => objectType == typeof(DateTime) || objectType == typeof(DateTime?);

        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            if (reader.TokenType == JsonToken.Null) return null;
            if (reader.TokenType == JsonToken.Date) return reader.Value;
            if (reader.TokenType == JsonToken.String)
            {
                string str = reader.Value as string;
                if (string.IsNullOrWhiteSpace(str)) return null;
                if (DateTime.TryParse(str, CultureInfo.InvariantCulture, DateTimeStyles.None, out var dt))
                    return dt;
                if (DateTime.TryParse(str, out var dt2))
                    return dt2;
            }
            return null;
        }

        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            if (value is DateTime dt)
                writer.WriteValue(dt.ToString("yyyy-MM-dd HH:mm:ss"));
            else
                writer.WriteNull();
        }
    }
}