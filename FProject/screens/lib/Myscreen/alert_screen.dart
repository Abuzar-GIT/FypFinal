import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:screens/Api/Api.dart';
import 'package:screens/Model/AlertModel.dart';
import 'package:screens/Myscreen/Log_in.dart';
import 'package:screens/Services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertScreen extends StatefulWidget {
  final bool isRescue;
  final String? uid;
  final int? rid;

  const AlertScreen({super.key, required this.isRescue, this.uid, this.rid});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  List<AlertModel> _alerts = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _pollingTimer;
  Position? _currentPosition;
  final Set<int> _readAlertIds = {};
  final Set<int> _markingSeenAlertIds = {};

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _fetchAlerts();

    // Auto-refresh alerts every 7 seconds for live emergency response
    _pollingTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      _fetchAlerts(isBackground: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (mounted && pos != null) {
      setState(() {
        _currentPosition = pos;
      });

      // If Rescue team, update location in DB
      if (widget.isRescue && widget.rid != null) {
        final locStr = LocationService.formatPosition(pos);
        ApiInterface.rescueUpdateLocation(rid: widget.rid!, location: locStr);
      }
    }
  }

  Future<void> _fetchAlerts({bool isBackground = false}) async {
    if (!isBackground) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final alerts = await ApiInterface.getUnreadAlerts(
        uid: widget.uid,
        rid: widget.rid,
      );

      if (mounted) {
        setState(() {
          // Filter out locally read alerts.
          // DEFENSE-IN-DEPTH: Ensure that when user is viewing as family/guardian,
          // they strictly never see their own vehicle accident alerts.
          _alerts = alerts.where((a) {
            if (_readAlertIds.contains(a.alertId)) return false;
            if (!widget.isRescue &&
                widget.uid != null &&
                widget.uid!.trim().isNotEmpty) {
              final myUid = widget.uid!.trim().toLowerCase();
              final victim = a.victimUid.trim().toLowerCase();
              if (victim == myUid) {
                return false;
              }
            }
            return true;
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !isBackground) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to fetch alerts: $e";
        });
      }
    }
  }

  Future<void> _handleMarkSeen(AlertModel alert) async {
    if (_markingSeenAlertIds.contains(alert.alertId)) return;

    setState(() {
      _markingSeenAlertIds.add(alert.alertId);
    });

    final success = await ApiInterface.markAlertAsSeen(alert.alertId);

    if (mounted) {
      setState(() {
        _markingSeenAlertIds.remove(alert.alertId);
        if (success) {
          _readAlertIds.add(alert.alertId);
          _alerts.removeWhere((a) => a.alertId == alert.alertId);
        }
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Alert #${alert.accidentId} marked as seen."),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to mark alert as seen. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return "$y-$m-$d $h:$min:$s";
  }

  String _formatLocationCityOrCoords(String location) {
    if (location.toLowerCase().contains("islamabad")) return "Islamabad";
    if (location.toLowerCase().contains("rawalpindi")) return "Rawalpindi";
    final coords = LocationService.parseCoordinates(location);
    if (coords != null) {
      if (coords.lat >= 33.4 &&
          coords.lat <= 33.8 &&
          coords.lng >= 72.8 &&
          coords.lng <= 73.3) {
        return "Islamabad";
      }
      return "${coords.lat.toStringAsFixed(4)}, ${coords.lng.toStringAsFixed(4)}";
    }
    return location.trim().isNotEmpty && location != "Unknown"
        ? location.trim()
        : "Islamabad";
  }

  String _cleanDisplayName(String name, String uid) {
    if (name.isNotEmpty && name != "Victim" && name != "Unknown") {
      return name;
    }
    final clean = uid.replaceAll("@gmail.com", "").replaceAll("@yahoo.com", "");
    if (clean.isNotEmpty) {
      return clean[0].toUpperCase() + clean.substring(1);
    }
    return "Family Member";
  }

  void _showAccidentDetailsSheet(AlertModel alert) {
    final coords = LocationService.parseCoordinates(alert.location);
    final displayName = _cleanDisplayName(alert.victimName, alert.victimUid);
    final relationship = widget.isRescue
        ? "Rescue Dispatch"
        : alert.relationship;
    double? distKm;
    if (coords != null && _currentPosition != null) {
      distKm = LocationService.calculateDistanceKm(
        lat1: _currentPosition!.latitude,
        lon1: _currentPosition!.longitude,
        lat2: coords.lat,
        lon2: coords.lng,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modal Top Bar: Title and Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48), // balance header
                      const Text(
                        "Accident Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Close",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Emergency Report Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFDEDE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "🚨",
                                  style: TextStyle(fontSize: 13),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "EMERGENCY REPORT",
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              _formatDateTime(alert.time),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Relationship: $relationship • Vehicle: ${alert.vehicleMake} (${alert.registrationNo})",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Driver Contact row
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Driver Contact",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      alert.victimContact.isNotEmpty
                                          ? alert.victimContact
                                          : "03546119810",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () {
                                  final tel = alert.victimContact.isNotEmpty
                                      ? alert.victimContact
                                      : "03546119810";
                                  launchUrl(Uri.parse("tel:$tel"));
                                },
                                child: const Text(
                                  "Call Now",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Telemetry & Impact Metrics Heading
                  const Text(
                    "Telemetry & Impact Metrics",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Metrics rows
                  _buildMetricRow("Severity", alert.severity),
                  _buildMetricRow("Impact Direction", alert.impactSide),
                  _buildMetricRow(
                    "Impact Force",
                    "${alert.impactForce.toStringAsFixed(1)} N",
                  ),
                  _buildMetricRow(
                    "Cabin Damage",
                    "${alert.cabinForce.toStringAsFixed(1)}%",
                  ),
                  if (distKm != null)
                    _buildMetricRow(
                      "Distance to Incident",
                      "${distKm.toStringAsFixed(2)} km",
                    ),
                  _buildMetricRow(
                    "GPS Location",
                    coords != null
                        ? "${coords.lat},${coords.lng}"
                        : alert.location,
                  ),

                  const SizedBox(height: 24),

                  // Button: See Location on Map & Track
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.near_me_rounded, size: 20),
                      label: const Text(
                        "See Location on Map & Track",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        LocationService.openGoogleMapsWithLocation(
                          alert.location,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Button: Acknowledge & Mark as Seen
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      label: const Text(
                        "Acknowledge & Mark as Seen",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleMarkSeen(alert);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(AlertModel alert) {
    final displayName = _cleanDisplayName(alert.victimName, alert.victimUid);
    final relationship = widget.isRescue
        ? "Rescue Dispatch"
        : alert.relationship;
    final cityOrLoc = _formatLocationCityOrCoords(alert.location);
    final coords = LocationService.parseCoordinates(alert.location);
    double? distKm;
    if (widget.isRescue && coords != null && _currentPosition != null) {
      distKm = LocationService.calculateDistanceKm(
        lat1: _currentPosition!.latitude,
        lon1: _currentPosition!.longitude,
        lat2: coords.lat,
        lon2: coords.lng,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Severity Badge + Timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDADA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      alert.severity.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDateTime(alert.time),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Person & Vehicle Profile Row
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEAEA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isRescue
                      ? Icons.local_hospital_rounded
                      : Icons.favorite,
                  color: const Color(0xFFEF4444),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: displayName,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: " • $relationship",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${alert.vehicleMake} • ${alert.registrationNo}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Metrics chips: Damage, Impact, Location
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Damage: ${alert.cabinForce.toStringAsFixed(0)}%",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Impact: ${alert.impactSide}",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (distKm != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${distKm.toStringAsFixed(1)} km away",
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.near_me_rounded,
                    color: Color(0xFF007AFF),
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    cityOrLoc,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons: [See Location], [Details], [✓]
          Row(
            children: [
              // Blue See Location button
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    icon: const Icon(Icons.map_rounded, size: 16),
                    label: const Text(
                      "See Location",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      LocationService.openGoogleMapsWithLocation(
                        alert.location,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // White Outline Details button
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Colors.black87,
                    ),
                    label: const Text(
                      "Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    onPressed: () => _showAccidentDetailsSheet(alert),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Light Green Mark Seen button
              SizedBox(
                height: 42,
                width: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDCFCE7),
                    foregroundColor: const Color(0xFF16A34A),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _markingSeenAlertIds.contains(alert.alertId)
                      ? null
                      : () => _handleMarkSeen(alert),
                  child: _markingSeenAlertIds.contains(alert.alertId)
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF16A34A),
                          ),
                        )
                      : const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF16A34A),
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isRescue ? "Rescue Emergency" : "Guardian Emergency";
    final subtitle = widget.isRescue
        ? "Emergency notifications for active\nrescue dispatches"
        : "Emergency notifications for your family\n& loved ones";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Clean Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$title\nAlerts",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right actions: Refresh & Exit
                  InkWell(
                    onTap: () {
                      _fetchCurrentLocation();
                      _fetchAlerts();
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF007AFF),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LogIn()),
                        (route) => false,
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFDEDE)),
                      ),
                      child: const Icon(
                        Icons.exit_to_app_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Banner: Active Emergency Alerts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _alerts.isNotEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEAEA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_rounded,
                            color: Color(0xFFDC2626),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${_alerts.length} ACTIVE EMERGENCY ALERT${_alerts.length > 1 ? 'S' : ''}",
                                  style: const TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Immediate attention and response recommended",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF16A34A),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isRescue
                                      ? "NO PENDING DISPATCHES"
                                      : "ALL FAMILY MEMBERS ARE SAFE",
                                  style: const TextStyle(
                                    color: Color(0xFF16A34A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.isRescue
                                      ? "You will be alerted if an accident occurs nearby."
                                      : "No active accident alerts reported for your loved ones.",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 12),

            // Content List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 50,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 10),
                            Text(_errorMessage!, textAlign: TextAlign.center),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () => _fetchAlerts(),
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _alerts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDCFCE7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              size: 55,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.isRescue
                                ? "No Pending Rescue Dispatches"
                                : "All Family Members Are Safe",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.isRescue
                                ? "System is actively monitoring for incidents."
                                : "Your loved ones haven't reported any accidents.",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _fetchCurrentLocation();
                        await _fetchAlerts();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _alerts.length,
                        itemBuilder: (ctx, i) => _buildAlertCard(_alerts[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
