import 'package:flutter/material.dart';
import 'package:screens/Myscreen/newscreen.dart';

/// Displays a confirmed accident reported by the backend.
/// Uses the exact CarImpactVisualizer and OccupantInjuryCard components.
class AfterAccidentMonitoring extends StatelessWidget {
  final String email, make, plate, carType, impactSide, severity, eventTime;
  final String? driverSide;
  final int carId;
  final double impactForce, cabinDamage;
  final double? latitude, longitude;
  final String? passengerSeverity;
  final String? passengerInjury;
  final String? driverSeverity;
  final String? driverInjury;
  final String? occupantSummary;

  const AfterAccidentMonitoring({
    super.key,
    required this.email,
    required this.carId,
    required this.make,
    required this.plate,
    required this.carType,
    this.driverSide,
    required this.impactSide,
    required this.impactForce,
    required this.cabinDamage,
    required this.severity,
    required this.eventTime,
    this.latitude,
    this.longitude,
    this.passengerSeverity,
    this.passengerInjury,
    this.driverSeverity,
    this.driverInjury,
    this.occupantSummary,
  });

  int get _categoryId {
    final cat = carType.toLowerCase().trim();
    if (cat.contains('suv')) return 2;
    if (cat.contains('hatchback')) return 3;
    return 1;
  }

  String get _steeringSide => (driverSide != null && driverSide!.trim().isNotEmpty) ? driverSide!.trim() : 'Right-Hand';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f4),
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f2f4),
        title: const Text('Accident Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accident Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded, size: 28, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🚨 ${impactSide.toUpperCase()} COLLISION DETECTED',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Severity: $severity  •  Time: $eventTime',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Selected Car Picture & Affected Impact Area Highlight
                makeCarImpactVisualizer(
                  make: make,
                  plate: plate,
                  categoryId: _categoryId,
                  isAccident: true,
                  impactSide: impactSide,
                  cabinDamage: cabinDamage,
                ),

                const SizedBox(height: 10),

                // Grid Metrics
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 10) / 2;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: InfoCard(
                            title: 'Accident Type',
                            value: impactSide.contains('Rollover') ? 'Rollover' : 'Impact',
                            sub: 'Classification',
                            highlight: true,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: InfoCard(
                            title: 'Passenger Severity',
                            value: passengerSeverity ?? severity,
                            sub: 'Impact Matrix',
                            highlight: true,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: InfoCard(
                            title: 'Impact Side',
                            value: impactSide,
                            sub: 'Detected Area',
                            highlight: true,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: InfoCard(
                            title: 'Force Impact',
                            value: '${impactForce.toStringAsFixed(0)} N',
                            sub: 'Newtons',
                            highlight: true,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: DamageCard(damage: cabinDamage),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Occupant Biomechanical Injury Assessment
                OccupantInjuryCard(
                  steeringSide: _steeringSide,
                  passengerSeverity: passengerSeverity ?? severity,
                  passengerInjury: passengerInjury ?? 'Evaluation based on crash telemetry.',
                  driverSeverity: driverSeverity ?? severity,
                  driverInjury: driverInjury ?? 'Evaluation based on crash telemetry.',
                  occupantSummary: occupantSummary ?? '',
                  isAccident: true,
                ),

                const SizedBox(height: 10),

                // Details Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Telemetry Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text('Vehicle: $make ($plate) • ID #$carId'),
                      Text('Time: $eventTime'),
                      Text('GPS: ${latitude == null || longitude == null ? 'Unavailable' : '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}'}'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text('DISMISS / RESUME MONITORING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
