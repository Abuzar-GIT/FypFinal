import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sensors_plus/sensors_plus.dart';

import 'package:screens/Api/Api.dart';
import 'package:screens/Myscreen/Log_in.dart';

// ============================================================
// IMPACT ZONES ENUM
// ============================================================
enum CarImpactZone {
  none('Safe'),
  front('Front'),
  frontLeft('Front-Left'),
  frontRight('Front-Right'),
  left('Left Side'),
  right('Right Side'),
  rear('Rear'),
  rearLeft('Rear-Left'),
  rearRight('Rear-Right'),
  rollover('Rollover / Roof');

  final String displayName;
  const CarImpactZone(this.displayName);
}

// ============================================================
// CAR ASSET & ZONE RESOLUTION (EXACT BLUEPRINT MAPPING)
// ============================================================

String getCarAssetPath({
  required String make,
  required int categoryId,
  String? carType,
}) {
  final makeLower = make.toLowerCase().trim();
  final typeLower = (carType ?? '').toLowerCase().trim();

  if (categoryId == 2 ||
      typeLower.contains('suv') ||
      makeLower.contains('suv') ||
      makeLower.contains('fortuner') ||
      makeLower.contains('prado') ||
      makeLower.contains('cr-v') ||
      makeLower.contains('crv') ||
      makeLower.contains('sportage')) {
    return 'assets/images/Suv.png';
  } else if (categoryId == 3 ||
      typeLower.contains('hatchback') ||
      makeLower.contains('hatchback') ||
      makeLower.contains('alto') ||
      makeLower.contains('swift') ||
      makeLower.contains('picanto') ||
      makeLower.contains('vitz')) {
    return 'assets/images/Hatchback.png';
  } else if (categoryId == 1 ||
      typeLower.contains('sedan') ||
      makeLower.contains('sedan') ||
      makeLower.contains('civic') ||
      makeLower.contains('corolla') ||
      makeLower.contains('elantra')) {
    return 'assets/images/wireframe.png';
  }
  return 'assets/images/wireframe.png';
}

String getCarImageKey({
  required String make,
  required int categoryId,
  String? carType,
}) {
  final asset = getCarAssetPath(
    make: make,
    categoryId: categoryId,
    carType: carType,
  );
  if (asset.contains('Suv.png')) return 'suv';
  if (asset.contains('Hatchback.png')) return 'hatchback';
  return 'sedan';
}

double getCarAspectRatio(String imageKey) {
  switch (imageKey) {
    case 'suv':
      return 624.0 / 1024.0;
    case 'hatchback':
      return 878.0 / 1024.0;
    default:
      return 948.0 / 1659.0;
  }
}

CarImpactZone detectImpactZone(String? impactSide, bool isAccident) {
  if (!isAccident || impactSide == null || impactSide.isEmpty) {
    return CarImpactZone.none;
  }

  final side = impactSide.toLowerCase().trim();

  if (side.contains('rollover') || side.contains('fall')) {
    return CarImpactZone.rollover;
  } else if (side.contains('front') && side.contains('left')) {
    return CarImpactZone.frontLeft;
  } else if (side.contains('front') && side.contains('right')) {
    return CarImpactZone.frontRight;
  } else if ((side.contains('rear') || side.contains('back')) &&
      side.contains('left')) {
    return CarImpactZone.rearLeft;
  } else if ((side.contains('rear') || side.contains('back')) &&
      side.contains('right')) {
    return CarImpactZone.rearRight;
  } else if (side.contains('front')) {
    return CarImpactZone.front;
  } else if (side.contains('rear') || side.contains('back')) {
    return CarImpactZone.rear;
  } else if (side.contains('left')) {
    return CarImpactZone.left;
  } else if (side.contains('right')) {
    return CarImpactZone.right;
  }

  return CarImpactZone.front;
}

Widget makeCarImpactVisualizer({
  required String make,
  required String plate,
  int categoryId = 1,
  String? carType,
  required bool isAccident,
  required String impactSide,
  double cabinDamage = 0,
}) {
  return CarImpactVisualizerView(
    make: make,
    plate: plate,
    categoryId: categoryId,
    carType: carType,
    isAccident: isAccident,
    impactSide: impactSide,
    cabinDamage: cabinDamage,
  );
}

// ============================================================
// CAR IMPACT VISUALIZER VIEW (ANIMATED BLUEPRINT)
// ============================================================
class CarImpactVisualizerView extends StatefulWidget {
  final String make;
  final String plate;
  final int categoryId;
  final String? carType;
  final bool isAccident;
  final String impactSide;
  final double cabinDamage;

  const CarImpactVisualizerView({
    super.key,
    required this.make,
    required this.plate,
    this.categoryId = 1,
    this.carType,
    required this.isAccident,
    required this.impactSide,
    this.cabinDamage = 0,
  });

  @override
  State<CarImpactVisualizerView> createState() =>
      _CarImpactVisualizerViewState();
}

class _CarImpactVisualizerViewState extends State<CarImpactVisualizerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _imageKey => getCarImageKey(
    make: widget.make,
    categoryId: widget.categoryId,
    carType: widget.carType,
  );

  String get _assetPath => getCarAssetPath(
    make: widget.make,
    categoryId: widget.categoryId,
    carType: widget.carType,
  );

  double get _aspectRatio => getCarAspectRatio(_imageKey);
  CarImpactZone get _zone =>
      detectImpactZone(widget.impactSide, widget.isAccident);

  Offset _getZoneCenter(CarImpactZone zone, double width, double height) {
    switch (zone) {
      case CarImpactZone.front:
        return Offset(width * 0.50, height * 0.08);
      case CarImpactZone.frontLeft:
        return Offset(width * 0.22, height * 0.10);
      case CarImpactZone.frontRight:
        return Offset(width * 0.78, height * 0.10);
      case CarImpactZone.left:
        return Offset(width * 0.15, height * 0.50);
      case CarImpactZone.right:
        return Offset(width * 0.85, height * 0.50);
      case CarImpactZone.rear:
        return Offset(width * 0.50, height * 0.92);
      case CarImpactZone.rearLeft:
        return Offset(width * 0.22, height * 0.90);
      case CarImpactZone.rearRight:
        return Offset(width * 0.78, height * 0.90);
      case CarImpactZone.rollover:
      case CarImpactZone.none:
        return Offset(width * 0.50, height * 0.50);
    }
  }

  Widget _buildHighlightOverlay(
    CarImpactZone zone,
    double width,
    double height,
  ) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final t = _pulseAnimation.value;

        if (zone == CarImpactZone.rollover) {
          final scale = 0.95 + 0.10 * t;
          return Center(
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: width * 0.75,
                height: height * 0.65,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.red, width: 4),
                ),
                child: const Center(
                  child: Icon(Icons.sync_problem, color: Colors.red, size: 36),
                ),
              ),
            ),
          );
        }

        final coords = _getZoneCenter(zone, width, height);
        final ripple1Scale = 0.85 + 0.40 * t;
        final ripple1Opacity = 0.15 + 0.20 * t;
        final ripple2Scale = 0.90 + 0.25 * t;

        return Stack(
          children: [
            Positioned(
              left: coords.dx - 30 * ripple1Scale,
              top: coords.dy - 30 * ripple1Scale,
              child: Container(
                width: 60 * ripple1Scale,
                height: 60 * ripple1Scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(ripple1Opacity),
                ),
              ),
            ),
            Positioned(
              left: coords.dx - 22 * ripple2Scale,
              top: coords.dy - 22 * ripple2Scale,
              child: Container(
                width: 44 * ripple2Scale,
                height: 44 * ripple2Scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withOpacity(0.8),
                    width: 2,
                  ),
                ),
              ),
            ),
            Positioned(
              left: coords.dx - 13,
              top: coords.dy - 13,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Colors.yellow, Colors.red],
                    center: Alignment.center,
                    radius: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.bolt, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double displayHeight = 230;
    final double displayWidth = displayHeight * _aspectRatio;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 12),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car,
                  size: 20,
                  color: widget.isAccident ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.make.isEmpty ? 'Selected Car' : widget.make,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.plate.isNotEmpty && widget.plate != '-') ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${widget.plate})',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final scale = widget.isAccident
                        ? 1.0 + 0.35 * _pulseAnimation.value
                        : 1.0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isAccident
                            ? Colors.red.withOpacity(0.12)
                            : Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.isAccident
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.isAccident
                                ? '${_zone.displayName.toUpperCase()} IMPACT'
                                : 'ALL ZONES OK',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: widget.isAccident
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              height: displayHeight + 20,
              decoration: BoxDecoration(
                color: const Color(0xfff7f7f7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: SizedBox(
                  width: displayWidth,
                  height: displayHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: widget.isAccident ? 0.90 : 1.0,
                          child: Image.asset(
                            _assetPath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.directions_car,
                                  size: 110,
                                  color: Colors.blueGrey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (widget.isAccident && _zone != CarImpactZone.none)
                        Positioned.fill(
                          child: _buildHighlightOverlay(
                            _zone,
                            displayWidth,
                            displayHeight,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.isAccident) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Affected Area: ${_zone.displayName}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.cabinDamage > 0
                                ? 'Structural Damage: ${widget.cabinDamage.toStringAsFixed(0)}%'
                                : 'Impact detected on this side',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// OCCUPANT INJURY CARD (ACTIVE & UNCOMMENTED)
// ============================================================
class OccupantInjuryCard extends StatelessWidget {
  final String steeringSide;
  final String passengerSeverity;
  final String passengerInjury;
  final String driverSeverity;
  final String driverInjury;
  final String occupantSummary;
  final bool isAccident;

  const OccupantInjuryCard({
    super.key,
    required this.steeringSide,
    required this.passengerSeverity,
    required this.passengerInjury,
    required this.driverSeverity,
    required this.driverInjury,
    required this.occupantSummary,
    required this.isAccident,
  });

  Color _badgeColor(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('fatal') ||
        lower.contains('critical') ||
        lower.contains('5') ||
        lower.contains('6')) {
      return Colors.purple;
    } else if (lower.contains('severe') ||
        lower.contains('serious') ||
        lower.contains('3') ||
        lower.contains('4')) {
      return Colors.red;
    } else if (lower.contains('moderate') || lower.contains('2')) {
      return Colors.orange;
    } else if (lower.contains('minor') || lower.contains('1')) {
      return Colors.amber.shade700;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLHD = steeringSide.toLowerCase().contains('left');
    final pColor = _badgeColor(passengerSeverity);
    final dColor = _badgeColor(driverSeverity);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                color: isAccident ? Colors.red : Colors.blue,
                size: 18,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Passenger & Occupant Injury Analysis',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  steeringSide,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Passenger Section
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xfff8f9fa),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.orange, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      isLHD
                          ? 'Passenger (Right Seat)'
                          : 'Passenger (Left Seat)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: pColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        passengerSeverity,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: pColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  passengerInjury.isEmpty
                      ? 'Normal driving safe baseline / no trauma.'
                      : passengerInjury,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Driver Section
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xfff8f9fa),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.drive_eta, color: Colors.blue, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      isLHD ? 'Driver (Left Seat)' : 'Driver (Right Seat)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: dColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        driverSeverity,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: dColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  driverInjury.isEmpty
                      ? 'Normal driving safe baseline / no trauma.'
                      : driverInjury,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          if (isAccident &&
              occupantSummary.isNotEmpty &&
              occupantSummary != '-') ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: Colors.red, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    occupantSummary,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// DASHBOARD METRIC CARDS
// ============================================================
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final bool highlight;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.sub,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? Colors.red : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: highlight
                  ? Colors.white.withOpacity(0.85)
                  : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: highlight ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11,
              color: highlight
                  ? Colors.white.withOpacity(0.75)
                  : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DamageCard extends StatelessWidget {
  final double damage;

  const DamageCard({super.key, required this.damage});

  @override
  Widget build(BuildContext context) {
    final safeDamage = damage.isNaN ? 0.0 : damage.clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Cabin Impact',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '${safeDamage.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            'Damage',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: safeDamage / 100.0,
              backgroundColor: const Color(0xffdddddd),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xff3498db),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class SensorRow extends StatelessWidget {
  final String label;
  final double x;
  final double y;
  final double z;

  const SensorRow({
    super.key,
    required this.label,
    required this.x,
    required this.y,
    required this.z,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SensorVal(axis: 'X', val: x),
            SensorVal(axis: 'Y', val: y),
            SensorVal(axis: 'Z', val: z),
          ],
        ),
      ],
    );
  }
}

class SensorVal extends StatelessWidget {
  final String axis;
  final double val;

  const SensorVal({super.key, required this.axis, required this.val});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          axis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          val.toStringAsFixed(3),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DATA MODEL
// ============================================================
class SensorData {
  final String accidentType;
  final String? rawSide;
  final String impactSide;
  final String force;
  final double cabinDamage;
  final String? severity;
  final String? aisLevel;
  final String? passengerSeverity;
  final String? passengerInjury;
  final String? driverSeverity;
  final String? driverInjury;
  final String? occupantSummary;
  final String? steeringSide;
  final String lastEvent;
  final String status;
  final double? realWorldSpeedKmh;
  final double? toyImpactSpeedMs;

  const SensorData({
    required this.accidentType,
    this.rawSide,
    required this.impactSide,
    required this.force,
    required this.cabinDamage,
    this.severity,
    this.aisLevel,
    this.passengerSeverity,
    this.passengerInjury,
    this.driverSeverity,
    this.driverInjury,
    this.occupantSummary,
    this.steeringSide,
    required this.lastEvent,
    required this.status,
    this.realWorldSpeedKmh,
    this.toyImpactSpeedMs,
  });
}

class DrivingTelemetrySample {
  final DateTime timestamp;
  final double ax;
  final double ay;
  final double az;
  final double dynMagnitude;
  final double totalMagG;
  final double gyroMagDegS;

  DrivingTelemetrySample({
    required this.timestamp,
    required this.ax,
    required this.ay,
    required this.az,
    required this.dynMagnitude,
    required this.totalMagG,
    required this.gyroMagDegS,
  });
}

class IMUReading {
  final DateTime timestamp;
  final double totalAccelG;
  final double ax;
  final double ay;
  final double az;
  final double userAx;
  final double userAy;
  final double userAz;
  final double gyroMagDegS;
  final double rotX;
  final double rotY;
  final double rotZ;

  const IMUReading({
    required this.timestamp,
    required this.totalAccelG,
    required this.ax,
    required this.ay,
    required this.az,
    required this.userAx,
    required this.userAy,
    required this.userAz,
    required this.gyroMagDegS,
    required this.rotX,
    required this.rotY,
    required this.rotZ,
  });
}

// ============================================================
// MAIN MONITORING SCREEN (USER DASHBOARD & MONITORING VIEW)
// ============================================================
class MonitoringScreen extends StatefulWidget {
  final String email;
  final int? carId;
  final String? uid;
  final String make;
  final String plate;
  final String carType;
  final int categoryId;
  final String? driverSide;
  final VoidCallback? onShowCarSelection;
  final VoidCallback? onManageFamily;
  final VoidCallback? onLogout;

  const MonitoringScreen({
    super.key,
    required this.email,
    this.carType = 'Sedan',
    this.carId,
    this.uid,
    this.make = 'Vehicle',
    this.plate = '-',
    this.categoryId = 1,
    this.driverSide,
    this.onShowCarSelection,
    this.onManageFamily,
    this.onLogout,
  });

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  static const int debounceMs = 800;
  static const int warmupReads = 10;

  // =========================================================================
  // REQUIRED PRIORITIZED STATE MACHINE STATE VARIABLES & CONSTANTS
  // =========================================================================
  // 1. Architectural Required State Variables & Persistent Free-Fall Latch
  bool is_freefall_locked = false;
  DateTime freefall_lockout_until = DateTime.fromMillisecondsSinceEpoch(0);
  bool is_freefall_latched = false;
  DateTime freefall_latch_expiration = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? impact_timestamp;
  String? primary_event;
  bool in_phase_2 = false;

  // 2. Calibrated Architectural Thresholds & Constants (Persistent Free-Fall Latch)
  static const double FREEFALL_ACC_THRESHOLD_G = 0.40;
  static const int FREEFALL_MIN_SAMPLES = 5;
  static const double FREEFALL_WINDOW_MS = 200.0;
  static const double FREEFALL_MIN_DURATION_MS = 50.0;
  static const double FREEFALL_LOCKOUT_MS = 3000.0;
  static const double ROTATIONAL_NOISE_THRESHOLD_DEG_S = 600.0;
  static const double IMPACT_COLLISION_THRESHOLD_G = 4.0;
  static const double PHASE2_SETTLED_GYRO_DEG_S = 30.0;
  static const double PHASE2_MIN_SETTLED_MS = 150.0;
  static const double PHASE2_MAX_TIMEOUT_MS = 500.0;
  static const double ROLLOVER_POSTURE_ANGLE_DEG = 35.0;

  // 3. Dynamic Motion Settlement & Posture Tracking Variables (Phase 2 & Standalone)
  double phase2_peak_acc = 0.0;
  double phase2_peak_ax = 0.0;
  double phase2_peak_ay = 0.0;
  double phase2_peak_az = 0.0;
  DateTime? phase2_settled_start_time;

  // Standalone / Handheld Rollover Tracking (Screen Orientation Matrix)
  static const double STANDALONE_ROLLOVER_REST_GYRO_DEG_S = 45.0;
  static const double STANDALONE_ROLLOVER_MIN_REST_MS = 150.0;
  static const double STANDALONE_ROLLOVER_MAX_POSTURE_MS = 250.0;
  DateTime? standalone_rollover_posture_start_time;
  DateTime? standalone_rollover_rest_start_time;

  // 4. 100 Hz IMU Rolling Buffer (stores last ~350ms of readings prior to impact)
  final List<IMUReading> imuBuffer = [];

  // 5. Continuous Free-Fall Streak Tracking
  DateTime? freefallStreakStartTime;
  double lastQualifiedFreefallDurationMs = 0.0;
  DateTime lastQualifiedFreefallEndTime = DateTime.fromMillisecondsSinceEpoch(0);

  // 6. Tier 3 Driving Dynamic Edge Cases Tracking Variables
  final List<({DateTime timestamp, double ay})> hardBrakingWindow = [];
  DateTime? driftStreakStartTime;
  DateTime? speedBumpFirstPeakTime;
  DateTime lastEdgeCaseSent = DateTime.fromMillisecondsSinceEpoch(0);
  static const double EDGE_CASE_DEBOUNCE_MS = 1500.0;

  static const double lengthScaleFactor = 0.10;
  static double get forceScale => pow(lengthScaleFactor, 3).toDouble();
  static const double testRigMassKg = 2.0;
  static const double baselineReferenceMassKg = 1500.0;
  static const double vehicleCabinYieldStrengthN = 65000.0;

  StreamSubscription<UserAccelerometerEvent>? _userAccelSub;
  StreamSubscription<AccelerometerEvent>? _rawAccelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<Position>? _gpsSub;

  Timer? _liveLocationTimer;

  SensorData? _sensorData;

  double _accelX = 0;
  double _accelY = 0;
  double _accelZ = 0;

  double _gyroX = 0;
  double _gyroY = 0;
  double _gyroZ = 0;

  double _latestRawX = 0;
  double _latestRawY = 0;
  double _latestRawZ = 9.81;

  double _latitude = 0;
  double _longitude = 0;

  double _shakeLevel = 0;
  String _debugStatus = 'Initializing sensors…';

  int _readCount = 0;
  int _userAccelRecentUpdates = 0;
  DateTime _lastSent = DateTime.fromMillisecondsSinceEpoch(0);

  double _gravityX = 0.0;
  double _gravityY = -0.7;
  double _gravityZ = -0.7;

  int? _activeAccidentId;
  bool _isLiveTrackingActive = false;
  Position? _lastBroadcastedLocation;
  DateTime _lastBroadcastTime = DateTime.fromMillisecondsSinceEpoch(0);
  Position? _currentLocation;

  // =========================================================================
  // DUAL-SCENARIO MODE (STATIONARY MODE VS. ACTIVE DRIVING / RUNNING MODE)
  // =========================================================================
  bool isDrivingMode = false;
  bool isTrackRunActive = false;
  double trackDistanceMeters = 4.0;
  String trackDistanceInput = "4.0";
  late TextEditingController _distanceController;
  DateTime? trackRunStartTime;
  double? lastTrackElapsedTime;
  String liveTrackElapsedString = "0.000s";
  double liveTrackEstimatedSpeed = 0.0;
  double liveTrackEstimatedAccel = 0.0;
  double liveRealWorldSpeedKmh = 0.0;
  double? lastToySpeedMs;
  double? lastRealWorldSpeedKmh;
  double? lastTrackAccel;
  double? lastTrackGForce;
  Timer? _trackRunTimer;

  final List<DrivingTelemetrySample> _recentDrivingSamples = [];
  DateTime? _lastHardBrakingTimestamp;
  bool hadHardBrakingDuringRun = false;
  DateTime? runHardBrakingTimestamp;
  double runPeakHardBrakingG = 0.0;
  double runIntegratedBrakingDecel = 0.0;

  String get _serverIp => ApiInterface.ip.trim();

  String get _baseUrl {
    final configured = _serverIp;
    if (configured.isEmpty) return '';
    var url =
        configured.startsWith('http://') || configured.startsWith('https://')
        ? configured
        : 'http://$configured';
    url = url.replaceAll(RegExp(r'/+$'), '');
    if (url.endsWith('/api')) return url;
    if (url.contains('/api/')) {
      return url.substring(0, url.indexOf('/api/') + 4);
    }
    if (Uri.parse(url).path.isEmpty || Uri.parse(url).path == '/') {
      return '$url/AccidentDetectionApi/api';
    }
    return '$url/api';
  }

  int get _effectiveCarId =>
      (widget.carId != null && widget.carId! > 0) ? widget.carId! : 1;

  int get _effectiveCategoryId {
    final cat = widget.carType.toLowerCase().trim();
    final make = widget.make.toLowerCase().trim();

    if (widget.categoryId == 2 ||
        cat.contains('suv') ||
        make.contains('suv') ||
        make.contains('fortuner') ||
        make.contains('prado')) {
      return 2;
    }
    if (widget.categoryId == 3 ||
        cat.contains('hatchback') ||
        make.contains('hatchback') ||
        make.contains('alto')) {
      return 3;
    }
    return 1;
  }

  String get _steeringSide => widget.driverSide?.trim().isNotEmpty == true
      ? widget.driverSide!.trim()
      : 'Right-Hand';

  String get _displayName =>
      widget.email.trim().isEmpty ? 'User' : widget.email.split('@').first;

  String get _firstLetter => widget.uid?.trim().isNotEmpty == true
      ? widget.uid!.trim()[0].toUpperCase()
      : (_displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U');

  @override
  void initState() {
    super.initState();
    _distanceController = TextEditingController(text: trackDistanceInput);
    _startSensors();
    _startGps();
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _trackRunTimer?.cancel();
    _stopSensors();
    super.dispose();
  }

  // =========================================================================
  // DUAL-SCENARIO MODE CONTROLS
  // =========================================================================
  void updateTrackDistance(String newDistanceStr) {
    setState(() {
      trackDistanceInput = newDistanceStr;
      _distanceController.text = newDistanceStr;
      final clean = newDistanceStr.replaceAll(',', '.').trim();
      final val = double.tryParse(clean);
      if (val != null && val > 0) {
        trackDistanceMeters = val;
        if (lastTrackElapsedTime != null && lastTrackElapsedTime! > 0.05) {
          liveTrackEstimatedSpeed = (2.0 * val) / lastTrackElapsedTime!;
          liveTrackEstimatedAccel =
              (2.0 * val) / (lastTrackElapsedTime! * lastTrackElapsedTime!);
        }
      }
    });
  }

  void startDriveRun() {
    setState(() {
      isDrivingMode = true;
      isTrackRunActive = true;
      final clean = trackDistanceInput.replaceAll(',', '.').trim();
      final val = double.tryParse(clean);
      if (val != null && val > 0) {
        trackDistanceMeters = val;
      } else {
        trackDistanceMeters = 4.0;
        trackDistanceInput = '4.0';
        _distanceController.text = '4.0';
      }

      trackRunStartTime = DateTime.now();
      hadHardBrakingDuringRun = false;
      runHardBrakingTimestamp = null;
      runPeakHardBrakingG = 0.0;
      runIntegratedBrakingDecel = 0.0;
      _lastHardBrakingTimestamp = null;
      _recentDrivingSamples.clear();
      lastTrackElapsedTime = null;
      lastTrackAccel = null;
      lastTrackGForce = null;
      liveTrackElapsedString = "0.000s";
      liveTrackEstimatedSpeed = 0.0;
      liveTrackEstimatedAccel = 0.0;
      liveRealWorldSpeedKmh = 0.0;
      _debugStatus =
          '🏎️ Active Driving Mode Started (${trackDistanceMeters.toStringAsFixed(1)}m Track)! Accelerating towards barrier...';
    });

    _trackRunTimer?.cancel();
    _trackRunTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (!isDrivingMode || trackRunStartTime == null) return;
      final elapsed =
          DateTime.now().difference(trackRunStartTime!).inMilliseconds / 1000.0;
      if (!mounted) return;
      setState(() {
        liveTrackElapsedString = '${elapsed.toStringAsFixed(3)}s';
        if (elapsed > 0.05) {
          final v = (2.0 * trackDistanceMeters) / elapsed;
          final a = (2.0 * trackDistanceMeters) / (elapsed * elapsed);
          liveTrackEstimatedSpeed = v;
          liveTrackEstimatedAccel = a;
          final vBase = v / sqrt(0.10);
          liveRealWorldSpeedKmh = vBase * 3.6;
        }
      });
    });
  }

  ({bool hadImpact, bool hadHardBrake, double peakDynG, double integratedDecel})
  checkRecentBrakingAndImpact() {
    final now = DateTime.now();
    final recent = _recentDrivingSamples
        .where((s) => now.difference(s.timestamp).inMilliseconds <= 1500)
        .toList();
    if (recent.isEmpty) {
      final wasRecentBrake = hadHardBrakingDuringRun || _lastHardBrakingTimestamp != null;
      return (
        hadImpact: false,
        hadHardBrake: wasRecentBrake,
        peakDynG: 0.0,
        integratedDecel: 0.0,
      );
    }

    final peakDynG = recent.map((s) => s.dynMagnitude).fold(0.0, max);
    final peakTotalG = recent.map((s) => s.totalMagG).fold(0.0, max);
    final peakLongitudinalG = recent.map((s) => s.ay.abs()).fold(0.0, max);
    final peakLateralG = recent.map((s) => s.ax.abs()).fold(0.0, max);
    final peakGyro = recent.map((s) => s.gyroMagDegS).fold(0.0, max);

    // Differentiate true collision impact shock from clean linear braking:
    // Collision impact shock involves:
    // 1. Violent dynamic shock (peakDynG >= 2.5 || peakTotalG >= 2.5) OR
    // 2. Barrier shock recoil vibration (peakGyro >= 90.0 deg/s) accompanied by deceleration (>= 1.5G) OR
    // 3. Significant lateral deflection (peakLateralG >= 0.7G && peakDynG >= 1.5G)
    final hasImpactShock = peakDynG >= 2.5 ||
        peakTotalG >= 2.5 ||
        ((peakGyro >= 90.0 || peakLateralG >= 0.7) &&
            (peakDynG >= 1.5 || peakLongitudinalG >= 1.5));

    double integratedDecel = 0.0;
    for (final item in recent) {
      integratedDecel += item.ay.abs() * 9.81 * 0.01;
    }
    final wasRecentFlag = _lastHardBrakingTimestamp != null &&
        now.difference(_lastHardBrakingTimestamp!).inMilliseconds <= 1500;

    // Controlled hard braking without barrier impact shock:
    final hadHardBrake = !hasImpactShock &&
        (hadHardBrakingDuringRun ||
            wasRecentFlag ||
            ((integratedDecel >= 2.0 || peakLongitudinalG >= 0.6) &&
                peakGyro < 90.0 &&
                peakLateralG < 0.7));

    final hadImpact = hasImpactShock;

    return (
      hadImpact: hadImpact,
      hadHardBrake: hadHardBrake,
      peakDynG: peakDynG,
      integratedDecel: integratedDecel,
    );
  }

  void stopDriveAtDestination() {
    if (!isDrivingMode || trackRunStartTime == null) return;
    final elapsed =
        DateTime.now().difference(trackRunStartTime!).inMilliseconds / 1000.0;
    _trackRunTimer?.cancel();
    _trackRunTimer = null;
    setState(() {
      isDrivingMode = false;
      isTrackRunActive = false;
      lastTrackElapsedTime = elapsed;
    });

    final check = checkRecentBrakingAndImpact();
    final decelAccel =
        (2.0 * trackDistanceMeters) / max(elapsed * elapsed, 0.01);

    final gravZNorm = -(_gravityZ / 9.81);
    final gravXNorm = _gravityX / 9.81;
    final gravYNorm = _gravityY / 9.81;

    if (check.hadImpact) {
      setState(() {
        liveTrackElapsedString = '${elapsed.toStringAsFixed(3)}s (Impact Shock)';
        _debugStatus =
            '💥 Barrier Hit: ${elapsed.toStringAsFixed(3)}s across ${trackDistanceMeters.toStringAsFixed(1)}m (G=${check.peakDynG.toStringAsFixed(2)}) — Calculating Force from Speed!';
      });
      _sendImpact(
        acceleration: max(decelAccel, check.peakDynG * 9.81),
        detectedSide: _determineExactSide(
          dynX: _accelX,
          dynY: _accelY,
          dynZ: _accelZ,
          gravZ: gravZNorm,
          gyroMag: sqrt(_gyroX * _gyroX + _gyroY * _gyroY + _gyroZ * _gyroZ),
        ),
        dynX: _accelX,
        dynY: _accelY,
        dynZ: _accelZ,
        gravX: gravXNorm,
        gravY: gravYNorm,
        gravZ: gravZNorm,
        durationMs: 40.0,
        elapsedTimeSeconds: elapsed,
        trackDistanceMeters: trackDistanceMeters,
        isDrivingMode: true,
        isManualHardBrake: false,
      );
    } else if (check.hadHardBrake || hadHardBrakingDuringRun) {
      final effectiveBrakeG = max(runPeakHardBrakingG, decelAccel / 9.81);
      setState(() {
        liveTrackElapsedString = '${elapsed.toStringAsFixed(3)}s (Hard Brake)';
        _debugStatus =
            '🛑 Hard Braking at ${elapsed.toStringAsFixed(2)}s across ${trackDistanceMeters.toStringAsFixed(1)}m (Vehicle Safe)';
      });
      _sendImpact(
        acceleration: max(decelAccel, effectiveBrakeG * 9.81),
        detectedSide: 'Hard Braking',
        dynX: _accelX,
        dynY: _accelY,
        dynZ: _accelZ,
        gravX: gravXNorm,
        gravY: gravYNorm,
        gravZ: gravZNorm,
        durationMs: max(elapsed * 1000.0, 40.0),
        elapsedTimeSeconds: elapsed,
        trackDistanceMeters: trackDistanceMeters,
        isDrivingMode: true,
        isManualHardBrake: true,
      );
    } else {
      setState(() {
        liveTrackElapsedString = '${elapsed.toStringAsFixed(3)}s (Safe Stop)';
        _debugStatus =
            '✅ Safe Run Completed: ${elapsed.toStringAsFixed(2)}s across ${trackDistanceMeters.toStringAsFixed(1)}m (No Accident)';
      });
      _sendImpact(
        acceleration: decelAccel,
        detectedSide: 'No Accident',
        dynX: _accelX,
        dynY: _accelY,
        dynZ: _accelZ,
        gravX: gravXNorm,
        gravY: gravYNorm,
        gravZ: gravZNorm,
        durationMs: max(elapsed * 1000.0, 40.0),
        elapsedTimeSeconds: elapsed,
        trackDistanceMeters: trackDistanceMeters,
        isDrivingMode: true,
        isManualHardBrake: false,
      );
    }
  }

  // =========================================================================
  // STATE MACHINE HELPER FUNCTIONS & LOGGING
  // =========================================================================

  /// Phase 1: Classify primary impact direction based solely on theta = atan2(a_y, a_x)
  /// Ignores gyro orientation angles and resting tilt (a_z) at this exact millisecond.
  ({String direction, double thetaDeg}) classifyImpactDirection({
    required double ax,
    required double ay,
  }) {
    // Physical vehicle hull impact point:
    // When the vehicle hits an obstacle in Front: vehicle decelerates => ay < 0.
    // Therefore, the impact point on the hull is at the Front: fb = -ay > 0.
    // When hit from behind: vehicle accelerates forward => ay > 0 => fb = -ay < 0 (Rear).
    // When hit on the Right side: vehicle is pushed Left => ax < 0 => lr = -ax > 0 (Right).
    // When hit on the Left side: vehicle is pushed Right => ax > 0 => lr = -ax < 0 (Left).
    final lr = -ax; // Left/Right vehicle impact axis
    final fb = -ay; // Front/Back vehicle impact axis
    final absLR = lr.abs();
    final absFB = fb.abs();
    final thetaRad = atan2(fb, lr);
    final thetaDeg = thetaRad * (180.0 / pi);

    final String direction;
    if (absLR < 0.3 && absFB < 0.3) {
      direction = "Minor";
    } else if (absFB > absLR) {
      if (fb > 0) {
        direction = (absLR > 0.3) ? (lr > 0 ? "Front-Right" : "Front-Left") : "Front";
      } else {
        direction = (absLR > 0.3) ? (lr > 0 ? "Rear-Right" : "Rear-Left") : "Rear";
      }
    } else {
      direction = lr > 0 ? "Right" : "Left";
    }
    return (direction: direction, thetaDeg: thetaDeg);
  }

  /// Top Priority: Evaluates pre-impact rolling buffer for zero-g state (|a_total| < 0.40g for >= 50ms in the last 200ms buffer)
  /// Physics Principle: Airborne free-fall causes sensor weightlessness (< 0.40g). Ground vehicle impacts are never preceded by weightlessness.
  /// If AT LEAST 5 samples within the last 200ms buffer read |a_total| < 0.40g, returns isFreefall = true.
  ({bool isFreefall, int lowGSampleCount, int totalSamplesInWindow, double durationMs})
  checkWindowedFreefall(DateTime spikeTime) {
    final windowReadings = imuBuffer.where((reading) {
      final delta = spikeTime.difference(reading.timestamp).inMilliseconds;
      return delta >= 0 && delta <= FREEFALL_WINDOW_MS;
    }).toList();

    final lowGSamples = windowReadings.where((r) => r.totalAccelG < FREEFALL_ACC_THRESHOLD_G).toList();
    final lowGCount = lowGSamples.length;
    final totalCount = windowReadings.length;

    double durationMs = 0.0;
    if (lowGSamples.isNotEmpty) {
      DateTime earliest = lowGSamples.first.timestamp;
      DateTime latest = lowGSamples.first.timestamp;
      for (final s in lowGSamples) {
        if (s.timestamp.isBefore(earliest)) earliest = s.timestamp;
        if (s.timestamp.isAfter(latest)) latest = s.timestamp;
      }
      durationMs = latest.difference(earliest).inMilliseconds.abs().toDouble() + 10.0;
    }

    final isFreefall = lowGCount >= FREEFALL_MIN_SAMPLES;
    return (
      isFreefall: isFreefall,
      lowGSampleCount: lowGCount,
      totalSamplesInWindow: totalCount,
      durationMs: max(durationMs, lowGCount * 10.0),
    );
  }

  /// Phase 2: Dynamic Motion Settlement & Rollover Verification
  /// Resolves settlement and evaluates static posture angle relative to gravity: phi = acos(|a_z| / |a_total|)
  void finalizePhase2({
    required String currentPrimary,
    required double settledMs,
    required double totalElapsedMs,
    required bool isTimeout,
    required double totalMagG,
    required double totZ,
    required double gravX,
    required double gravY,
    required double gravZ,
    required double dynX,
    required double dynY,
    required double dynZ,
    required double gyroX,
    required double gyroY,
    required double gyroZ,
  }) {
    final now = DateTime.now();

    // ---------------------------------------------------------------------
    // STRICT PHASE 2 ROLLOVER BLOCK (PERSISTENT FREE-FALL LATCH)
    // ---------------------------------------------------------------------
    if ((is_freefall_latched && now.isBefore(freefall_latch_expiration)) ||
        (is_freefall_locked && now.isBefore(freefall_lockout_until))) {
      final ratio = (totZ.abs() / max(totalMagG, 0.0001)).clamp(0.0, 1.0);
      final phiDeg = acos(ratio) * (180.0 / pi);
      debugPrint("🛡️ [FREE-FALL LATCH ACTIVE] Suppressing post-landing rollover check (a_total spike: ${totalMagG.toStringAsFixed(1)}g, tilt: ${phiDeg.toStringAsFixed(0)}° ignored).");
      in_phase_2 = false;
      primary_event = null;
      impact_timestamp = null;
      phase2_settled_start_time = null;
      return;
    }

    if (isTimeout) {
      debugPrint("⏱️ [PHASE 2 TIMING] Motion settlement reached max timeout limit (${totalElapsedMs.toStringAsFixed(0)}ms). Evaluating static posture angle.");
    } else {
      debugPrint("✅ [PHASE 2 TIMING] Physical motion settled dynamically (||w|| < 30 deg/s for ${settledMs.toStringAsFixed(0)}ms, total duration: ${totalElapsedMs.toStringAsFixed(0)}ms).");
    }

    // Calculate static posture angle relative to gravity: phi = acos(|a_z| / |a_total|)
    final ratio = (totZ.abs() / max(totalMagG, 0.0001)).clamp(0.0, 1.0);
    final phiRad = acos(ratio);
    final phiDeg = phiRad * (180.0 / pi);

    // Check if vehicle orientation landed upside down on roof (Gz > 0.20 in CoreMotion convention)
    final isRoofInverted = gravZ > 0.20;
    final String finalEvent;

    if (phiDeg > ROLLOVER_POSTURE_ANGLE_DEG || isRoofInverted) {
      finalEvent = "$currentPrimary WITH ROLLOVER";
      debugPrint("🔄 [PHASE 2 RESOLVED] Reclassified event as: [$finalEvent] (Post-impact angle phi = ${phiDeg.toStringAsFixed(1)}° > 35° [ROLLOVER CONFIRMED]).");
    } else {
      finalEvent = currentPrimary;
      debugPrint("🛡️ [PHASE 2 RESOLVED] Retained Pure Primary Event: [$finalEvent] (Post-impact angle phi = ${phiDeg.toStringAsFixed(1)}° <= 35° [TRANSIENT WOBBLE CLEARED]).");
    }

    _confirmAccident(
      dynX: phase2_peak_ax,
      dynY: phase2_peak_ay,
      dynZ: phase2_peak_az,
      gravX: gravX,
      gravY: gravY,
      gravZ: gravZ,
      gyroX: gyroX,
      gyroY: gyroY,
      gyroZ: gyroZ,
      acc: phase2_peak_acc,
      durationMs: max(totalElapsedMs, 35.0),
      isPhoneFall: false,
      freeFallMs: 0.0,
      classifiedSide: finalEvent,
    );

    // Reset Phase 2 State
    in_phase_2 = false;
    primary_event = null;
    impact_timestamp = null;
    phase2_settled_start_time = null;
  }

  void _startSensors() {
    _readCount = 0;
    _userAccelRecentUpdates = 0;
    is_freefall_locked = false;
    freefall_lockout_until = DateTime.fromMillisecondsSinceEpoch(0);
    is_freefall_latched = false;
    freefall_latch_expiration = DateTime.fromMillisecondsSinceEpoch(0);
    impact_timestamp = null;
    primary_event = null;
    in_phase_2 = false;
    phase2_settled_start_time = null;
    standalone_rollover_posture_start_time = null;
    standalone_rollover_rest_start_time = null;
    imuBuffer.clear();
    freefallStreakStartTime = null;
    lastQualifiedFreefallDurationMs = 0.0;
    lastQualifiedFreefallEndTime = DateTime.fromMillisecondsSinceEpoch(0);
    hardBrakingWindow.clear();
    driftStreakStartTime = null;
    speedBumpFirstPeakTime = null;
    lastEdgeCaseSent = DateTime.fromMillisecondsSinceEpoch(0);
    _debugStatus = 'Calibrating sensors (100 Hz)…';

    _gyroSub = gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen((GyroscopeEvent event) {
      _gyroX = event.x;
      _gyroY = event.y;
      _gyroZ = event.z;
    });

    _rawAccelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((AccelerometerEvent event) {
      const alpha = 0.88;
      _gravityX = alpha * _gravityX + (1.0 - alpha) * event.x;
      _gravityY = alpha * _gravityY + (1.0 - alpha) * event.y;
      _gravityZ = alpha * _gravityZ + (1.0 - alpha) * event.z;

      _latestRawX = event.x;
      _latestRawY = event.y;
      _latestRawZ = event.z;

      // If separate user accelerometer callbacks are not active, drive pipeline from raw stream
      if (_userAccelRecentUpdates == 0) {
        final uX = (event.x - _gravityX) / 9.81;
        final uY = (event.y - _gravityY) / 9.81;
        final uZ = (event.z - _gravityZ) / 9.81;
        _dispatchSensorPipeline(uX: uX, uY: uY, uZ: uZ);
      }
    });

    _userAccelSub = userAccelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((UserAccelerometerEvent event) {
      _userAccelRecentUpdates++;
      final uX = event.x / 9.81;
      final uY = event.y / 9.81;
      final uZ = event.z / 9.81;
      _dispatchSensorPipeline(uX: uX, uY: uY, uZ: uZ);
    });
  }

  void _dispatchSensorPipeline({
    required double uX,
    required double uY,
    required double uZ,
  }) {
    // Total acceleration in G
    final totX = _latestRawX / 9.81;
    final totY = _latestRawY / 9.81;
    final totZ = _latestRawZ / 9.81;

    // Gravity in CoreMotion normalized coordinates (upright flat face-up is -1.0G, inverted roof is +1.0G)
    final gravX = _gravityX / 9.81;
    final gravY = _gravityY / 9.81;
    final gravZ = -(_gravityZ / 9.81);

    _processSensorUpdate(
      uX: uX,
      uY: uY,
      uZ: uZ,
      totX: totX,
      totY: totY,
      totZ: totZ,
      gravX: gravX,
      gravY: gravY,
      gravZ: gravZ,
      rX: _gyroX,
      rY: _gyroY,
      rZ: _gyroZ,
    );
  }

  void _processSensorUpdate({
    required double uX,
    required double uY,
    required double uZ,
    required double totX,
    required double totY,
    required double totZ,
    required double gravX,
    required double gravY,
    required double gravZ,
    required double rX,
    required double rY,
    required double rZ,
  }) {
    final now = DateTime.now();

    final totalMagG = sqrt(totX * totX + totY * totY + totZ * totZ);
    final gyroMagDegS = sqrt(rX * rX + rY * rY + rZ * rZ) * (180.0 / pi);
    final dynMagnitude = sqrt(uX * uX + uY * uY + uZ * uZ);

    if (mounted) {
      setState(() {
        _accelX = uX;
        _accelY = uY;
        _accelZ = uZ;
        _gyroX = rX;
        _gyroY = rY;
        _gyroZ = rZ;
        _shakeLevel = dynMagnitude;
      });
    }

    // Track driving telemetry samples during active driving mode
    if (isDrivingMode || isTrackRunActive) {
      _recentDrivingSamples.add(
        DrivingTelemetrySample(
          timestamp: now,
          ax: uX,
          ay: uY,
          az: uZ,
          dynMagnitude: dynMagnitude,
          totalMagG: totalMagG,
          gyroMagDegS: gyroMagDegS,
        ),
      );
      _recentDrivingSamples.removeWhere(
        (s) => now.difference(s.timestamp).inMilliseconds > 1500,
      );
    }

    // 2. Rolling Buffer Maintenance (last ~350ms)
    final reading = IMUReading(
      timestamp: now,
      totalAccelG: totalMagG,
      ax: totX,
      ay: totY,
      az: totZ,
      userAx: uX,
      userAy: uY,
      userAz: uZ,
      gyroMagDegS: gyroMagDegS,
      rotX: rX,
      rotY: rY,
      rotZ: rZ,
    );
    imuBuffer.add(reading);
    imuBuffer.removeWhere(
      (r) => now.difference(r.timestamp).inMilliseconds > 350,
    );

    // 3. Continuous Free-fall Weightlessness Streak Tracking
    if (totalMagG < FREEFALL_ACC_THRESHOLD_G) {
      freefallStreakStartTime ??= now;
      final streakMs = now.difference(freefallStreakStartTime!).inMilliseconds.toDouble();
      if (streakMs >= FREEFALL_MIN_DURATION_MS) {
        lastQualifiedFreefallDurationMs = streakMs;
        lastQualifiedFreefallEndTime = now;
      }
    } else {
      freefallStreakStartTime = null;
    }

    // 4. Warmup reads check
    _readCount++;
    if (_readCount < warmupReads) {
      if (mounted) {
        setState(() {
          _debugStatus = 'Calibrating sensors ($_readCount/$warmupReads)…';
        });
      }
      return;
    }

    // =========================================================================
    // 1. PERSISTENT FREE-FALL LATCH INTERLOCK (LOCKOUT ACTIVE CHECK)
    // =========================================================================
    if (is_freefall_latched || is_freefall_locked) {
      standalone_rollover_posture_start_time = null;
      standalone_rollover_rest_start_time = null;
      if (now.isBefore(freefall_latch_expiration)) {
        final ratio = (totZ.abs() / max(totalMagG, 0.0001)).clamp(0.0, 1.0);
        final phiDeg = acos(ratio) * (180.0 / pi);

        if (totalMagG >= IMPACT_COLLISION_THRESHOLD_G || gyroMagDegS > 150.0) {
          debugPrint("🛡️ [FREE-FALL LATCH ACTIVE] Suppressing post-landing rollover check (a_total spike: ${totalMagG.toStringAsFixed(1)}g, tilt: ${phiDeg.toStringAsFixed(0)}° ignored).");
        }

        final remainingMs = freefall_latch_expiration.difference(now).inMilliseconds;
        if (mounted) {
          setState(() {
            _debugStatus = '🔒 Free-Fall Latch Active: ${remainingMs}ms remaining (Drop Noise Filtered)';
          });
        }
        return; // Exit immediately — do not evaluate collision or rollover
      } else {
        is_freefall_latched = false;
        is_freefall_locked = false;
        debugPrint("🔓 [FREE-FALL LATCH EXPIRED] 3.0s free-fall lockout completed. Vehicle crash detection re-armed.");
      }
    }

    // =========================================================================
    // 2. PRE-IMPACT ROLLING BUFFER ZERO-G CHECK & PERSISTENT LATCH TRIGGER
    // =========================================================================
    final freefallCheck = checkWindowedFreefall(now);
    if (freefallCheck.isFreefall && (!is_freefall_latched || now.isAfter(freefall_latch_expiration))) {
      is_freefall_latched = true;
      freefall_latch_expiration =
          now.add(Duration(milliseconds: FREEFALL_LOCKOUT_MS.toInt()));
      is_freefall_locked = true;
      freefall_lockout_until = freefall_latch_expiration;

      in_phase_2 = false;
      primary_event = null;
      impact_timestamp = null;
      phase2_settled_start_time = null;
      standalone_rollover_posture_start_time = null;
      standalone_rollover_rest_start_time = null;

      debugPrint("⚠️ [PHONE DROP / FALL DETECTED] Pre-impact zero-g verified (${freefallCheck.lowGSampleCount}/${freefallCheck.totalSamplesInWindow} samples [${freefallCheck.durationMs.toStringAsFixed(0)}ms], spike: ${totalMagG.toStringAsFixed(1)}g). Persistent Free-Fall Latch set for 3.0s.");
      if (mounted) {
        setState(() {
          _debugStatus = '📱 PHONE DROP / FALL DETECTED (${freefallCheck.lowGSampleCount}/${freefallCheck.totalSamplesInWindow} low-g samples) — Latch 3.0s';
        });
      }

      _sendImpact(
        acceleration: max(totalMagG * 9.81, 9.81),
        detectedSide: "PHONE DROP / FALL DETECTED",
        dynX: uX,
        dynY: uY,
        dynZ: uZ,
        gravX: gravX,
        gravY: gravY,
        gravZ: gravZ,
        durationMs: max(freefallCheck.durationMs, 30.0),
        isPhoneFall: true,
        freeFallMs: freefallCheck.durationMs,
      );
      return;
    }

    // =========================================================================
    // PHASE 2: DYNAMIC MOTION SETTLEMENT & ROLLOVER VERIFICATION
    // =========================================================================
    if (in_phase_2) {
      if ((is_freefall_latched && now.isBefore(freefall_latch_expiration)) ||
          (is_freefall_locked && now.isBefore(freefall_lockout_until))) {
        final ratio = (totZ.abs() / max(totalMagG, 0.0001)).clamp(0.0, 1.0);
        final phiDeg = acos(ratio) * (180.0 / pi);
        debugPrint("🛡️ [FREE-FALL LATCH ACTIVE] Suppressing post-landing rollover check (a_total spike: ${totalMagG.toStringAsFixed(1)}g, tilt: ${phiDeg.toStringAsFixed(0)}° ignored).");
        in_phase_2 = false;
        primary_event = null;
        impact_timestamp = null;
        phase2_settled_start_time = null;
        return;
      }

      final impactTime = impact_timestamp;
      final currentPrimary = primary_event;
      if (impactTime == null || currentPrimary == null) {
        in_phase_2 = false;
        return;
      }

      final timeSinceImpactMs = now.difference(impactTime).inMilliseconds.toDouble();
      final currentLinearAcc = totalMagG * 9.81;
      if (currentLinearAcc > phase2_peak_acc) {
        phase2_peak_acc = currentLinearAcc;
      }

      final isSettled = gyroMagDegS < PHASE2_SETTLED_GYRO_DEG_S;
      if (isSettled) {
        phase2_settled_start_time ??= now;
        final settledMs = now.difference(phase2_settled_start_time!).inMilliseconds.toDouble();

        if (settledMs >= PHASE2_MIN_SETTLED_MS || timeSinceImpactMs >= PHASE2_MAX_TIMEOUT_MS) {
          finalizePhase2(
            currentPrimary: currentPrimary,
            settledMs: settledMs,
            totalElapsedMs: timeSinceImpactMs,
            isTimeout: false,
            totalMagG: totalMagG,
            totZ: totZ,
            gravX: gravX,
            gravY: gravY,
            gravZ: gravZ,
            dynX: uX,
            dynY: uY,
            dynZ: uZ,
            gyroX: rX,
            gyroY: rY,
            gyroZ: rZ,
          );
          return;
        }
      } else {
        phase2_settled_start_time = null;

        if (timeSinceImpactMs >= PHASE2_MAX_TIMEOUT_MS) {
          finalizePhase2(
            currentPrimary: currentPrimary,
            settledMs: 0.0,
            totalElapsedMs: timeSinceImpactMs,
            isTimeout: true,
            totalMagG: totalMagG,
            totZ: totZ,
            gravX: gravX,
            gravY: gravY,
            gravZ: gravZ,
            dynX: uX,
            dynY: uY,
            dynZ: uZ,
            gyroX: rX,
            gyroY: rY,
            gyroZ: rZ,
          );
          return;
        }
      }

      if (mounted) {
        setState(() {
          _debugStatus = '⏳ Phase 2: $currentPrimary (||w||=${gyroMagDegS.toStringAsFixed(0)}°/s | ${timeSinceImpactMs.toStringAsFixed(0)}ms)';
        });
      }
      return; // Suppress conflicting triggers while resolving Phase 2
    }

    // =========================================================================
    // VEHICLE COLLISION IMPACT SPIKE EVALUATION: PRIORITIES 2 & PHASE 1
    // =========================================================================
    final isTrackRunning = isDrivingMode || isTrackRunActive;
    final totalGyroRadS = sqrt(rX * rX + rY * rY + rZ * rZ);

    // Differentiation between Hard Braking and Crash Collision during Active Driving:
    // Pure straight-line hard braking produces strong longitudinal deceleration (|uY| >= 1.0G),
    // with low lateral force (|uX| < 0.6G), calm rotational angular velocity (totalGyroRadS < 1.5 rad/s <=> gyroMagDegS < 86°/s),
    // and moderate dynamic magnitude (< 2.5G).
    // In contrast, a collision barrier hit produces sudden violent shock (dynMagnitude >= 2.5G or totalMagG >= 2.8G),
    // OR barrier rotational recoil / vibration shock (gyroMagDegS >= 90°/s or totalGyroRadS >= 1.5 rad/s),
    // OR significant lateral deflection (|uX| >= 0.6G).
    final isPureLinearBrakingDynamics = isTrackRunning &&
        uX.abs() < 0.6 &&
        totalGyroRadS < 1.5 &&
        dynMagnitude < 2.5;

    final collisionThreshold = isTrackRunning ? 2.5 : 2.5;
    final totalThreshold = isTrackRunning ? 2.8 : IMPACT_COLLISION_THRESHOLD_G;
    final isDirectionalTrackSpike = isTrackRunning &&
        !isPureLinearBrakingDynamics &&
        (uY.abs() >= 1.6 || uX.abs() >= 1.4);

    final isCollisionSpike = !isPureLinearBrakingDynamics &&
        (totalMagG >= totalThreshold || dynMagnitude >= collisionThreshold || isDirectionalTrackSpike);

    if (isCollisionSpike) {
      if ((is_freefall_latched && now.isBefore(freefall_latch_expiration)) ||
          (is_freefall_locked && now.isBefore(freefall_lockout_until))) {
        return;
      }

      if (now.difference(_lastSent).inMilliseconds < debounceMs) return;

      // SECOND PRIORITY: ROTATIONAL NOISE / HAND SLAP FILTER
      if (gyroMagDegS > ROTATIONAL_NOISE_THRESHOLD_DEG_S) {
        debugPrint("✋ [SECOND PRIORITY: ROTATIONAL NOISE FILTER] HAND SLAP / MANUAL HANDLING REJECTED. Total angular velocity ||w|| = ${gyroMagDegS.toStringAsFixed(1)} deg/s > 600 deg/s at peak impact (|a_total| = ${totalMagG.toStringAsFixed(2)}g). Rejecting as vehicle collision.");
        if (mounted) {
          setState(() {
            _debugStatus = '✋ Hand Slap / Rotational Noise Rejected (${gyroMagDegS.toStringAsFixed(0)}°/s)';
          });
        }
        return;
      }

      // PHASE 1 (AT T = 0ms IMPACT MOMENT): IMPACT DIRECTION CLASSIFICATION
      // theta = atan2(a_y, a_x)
      // Ignores gyro orientation angles and resting tilt (a_z) at this exact millisecond!
      final classified = classifyImpactDirection(ax: uX, ay: uY);

      primary_event = classified.direction;
      impact_timestamp = now;
      in_phase_2 = true;
      phase2_peak_acc = totalMagG * 9.81;
      phase2_peak_ax = uX;
      phase2_peak_ay = uY;
      phase2_peak_az = uZ;
      phase2_settled_start_time = null;

      debugPrint("💥 [PHASE 1: IMPACT DIRECTION CLASSIFIED] Primary Event: [${classified.direction}] | theta = ${classified.thetaDeg.toStringAsFixed(1)}° | |a_total| = ${totalMagG.toStringAsFixed(2)}g | ||w|| = ${gyroMagDegS.toStringAsFixed(1)} deg/s. Transitioning into Phase 2 Dynamic Settlement & Rollover Verification.");

      if (mounted) {
        setState(() {
          _debugStatus = '💥 Phase 1: ${classified.direction} (Settling motion…)';
        });
      }
      return;
    }

    // =========================================================================
    // STANDALONE / SCREEN ORIENTATION MATRIX ROLLOVER DETECTION (HANDHELD)
    // =========================================================================
    if (!is_freefall_latched && !is_freefall_locked && !in_phase_2) {
      final gx = gravX;
      final gy = gravY;
      final gz = gravZ; // Normalized CoreMotion: upright is -1.0, inverted roof is +1.0

      final isSideRolled = gx.abs() > 0.85 || gy.abs() > 0.85;
      final isTiltedOrFlipped = gz > 0.20;
      final isRolledOverState = isSideRolled || isTiltedOrFlipped;

      final safeGz = gz.abs().clamp(0.0, 1.0);
      final phiDeg = acos(safeGz) * (180.0 / pi);

      if (isRolledOverState) {
        standalone_rollover_posture_start_time ??= now;
        final postureDurationMs = now.difference(standalone_rollover_posture_start_time!).inMilliseconds.toDouble();

        final isQuietRest = gyroMagDegS < STANDALONE_ROLLOVER_REST_GYRO_DEG_S;
        if (isQuietRest) {
          standalone_rollover_rest_start_time ??= now;
        } else {
          standalone_rollover_rest_start_time = null;
        }

        final restDurationMs = standalone_rollover_rest_start_time != null
            ? now.difference(standalone_rollover_rest_start_time!).inMilliseconds.toDouble()
            : 0.0;

        final hasSettledAtRest = isQuietRest && (restDurationMs >= STANDALONE_ROLLOVER_MIN_REST_MS);
        final hasSustainedPosture = postureDurationMs >= STANDALONE_ROLLOVER_MAX_POSTURE_MS;

        if (hasSettledAtRest || hasSustainedPosture) {
          if (now.difference(_lastSent).inMilliseconds >= debounceMs) {
            debugPrint("🔄 [HANDHELD ROLLOVER DETECTED] Posture phi = ${phiDeg.toStringAsFixed(1)}° | gx = ${gx.toStringAsFixed(2)}g | gy = ${gy.toStringAsFixed(2)}g | gz = ${gz.toStringAsFixed(2)}g (Settled for ${(hasSettledAtRest ? restDurationMs : postureDurationMs).toStringAsFixed(0)}ms).");
            if (mounted) {
              setState(() {
                _debugStatus = '🔄 ROLLOVER DETECTED (STATIC / SLOW TIPPED) | phi=${phiDeg.toStringAsFixed(0)}°';
              });
            }

            _confirmAccident(
              dynX: uX,
              dynY: uY,
              dynZ: uZ,
              gravX: gx,
              gravY: gy,
              gravZ: gz,
              gyroX: rX,
              gyroY: rY,
              gyroZ: rZ,
              acc: max(totalMagG * 9.81, 9.81),
              durationMs: max(hasSettledAtRest ? restDurationMs : postureDurationMs, 150.0),
              isPhoneFall: false,
              freeFallMs: 0.0,
              classifiedSide: "ROLLOVER DETECTED (STATIC / SLOW TIPPED)",
            );
          }
          standalone_rollover_posture_start_time = null;
          standalone_rollover_rest_start_time = null;
          return;
        } else {
          if (mounted) {
            setState(() {
              if (isQuietRest) {
                _debugStatus = '🔄 Rollover Settling: phi=${phiDeg.toStringAsFixed(0)}° (rest=${restDurationMs.toStringAsFixed(0)}/150ms)';
              } else {
                _debugStatus = '🔄 Rollover Motion: phi=${phiDeg.toStringAsFixed(0)}° (||w||=${gyroMagDegS.toStringAsFixed(0)}°/s | ${postureDurationMs.toStringAsFixed(0)}/250ms)';
              }
            });
          }
        }
      } else {
        standalone_rollover_posture_start_time = null;
        standalone_rollover_rest_start_time = null;
      }
    } else {
      standalone_rollover_posture_start_time = null;
      standalone_rollover_rest_start_time = null;
    }

    // =========================================================================
    // [TIER 3: DRIVING DYNAMIC EDGE CASES — SECONDARY FILTER]
    // =========================================================================
    if (!in_phase_2 && !is_freefall_locked && dynMagnitude < 2.5 && totalGyroRadS < 50.0) {
      // 3A. HARD BRAKING:
      hardBrakingWindow.add((timestamp: now, ay: uY));
      hardBrakingWindow.removeWhere((item) => now.difference(item.timestamp).inMilliseconds > 500);

      double integratedDecel = 0.0;
      for (final item in hardBrakingWindow) {
        integratedDecel += item.ay.abs() * 9.81 * 0.01;
      }

      final isHardBraking = (isDrivingMode || isTrackRunActive) &&
          (integratedDecel >= 2.0 || uY.abs() >= 0.8) &&
          uX.abs() < 0.6 &&
          totalGyroRadS < 1.5;

      if (isHardBraking) {
        _lastHardBrakingTimestamp = now;
        hadHardBrakingDuringRun = true;
        runHardBrakingTimestamp = now;
        runPeakHardBrakingG = max(runPeakHardBrakingG, uY.abs());
        runIntegratedBrakingDecel = max(runIntegratedBrakingDecel, integratedDecel);

        if (isDrivingMode || isTrackRunActive) {
          // ACTIVE DRIVING / TRACK RUN MODE:
          // The timer DOES NOT STOP!
          // Stored hard braking will be reported upon destination stop!
          debugPrint("🛑 [DRIVING MODE: HARD BRAKING STORED] Decel = ${uY.abs().toStringAsFixed(2)}G (int=${integratedDecel.toStringAsFixed(2)} m/s). Timer continues running to destination!");
          if (mounted) {
            setState(() {
              _debugStatus = '🛑 Hard Braking Applied (${runPeakHardBrakingG.toStringAsFixed(1)}G) — Driving Continues to Destination…';
            });
          }
        } else {
          // Stationary / standalone testing
          if (now.difference(lastEdgeCaseSent).inMilliseconds >= EDGE_CASE_DEBOUNCE_MS) {
            lastEdgeCaseSent = now;
            debugPrint("🛑 [TIER 3: HARD BRAKING] Integrated decel = ${integratedDecel.toStringAsFixed(2)} m/s >= 2.0 m/s, lateral |ax| = ${uX.abs().toStringAsFixed(2)}g < 0.6g, gyro = ${totalGyroRadS.toStringAsFixed(2)} rad/s < 1.5 rad/s.");
            if (mounted) {
              setState(() {
                _debugStatus = '🛑 Hard Braking Edge Case (int=${integratedDecel.toStringAsFixed(1)}m/s)';
              });
            }
            _sendImpact(
              acceleration: max(uY.abs() * 9.81, 9.81),
              detectedSide: "Hard Braking",
              dynX: uX,
              dynY: uY,
              dynZ: uZ,
              gravX: gravX,
              gravY: gravY,
              gravZ: gravZ,
              durationMs: 250.0,
              isPhoneFall: false,
              isManualHardBrake: true,
            );
          }
        }
        hardBrakingWindow.clear();
        return;
      }

      // 3B. DRIFT / SHARP CORNERING:
      final isDriftDynamics = uX.abs() >= 1.2 && uY.abs() >= 0.3 && rZ.abs() >= 0.8;
      if (isDriftDynamics) {
        driftStreakStartTime ??= now;
        final driftDurationMs = now.difference(driftStreakStartTime!).inMilliseconds.toDouble();
        if (driftDurationMs >= 300.0 && now.difference(lastEdgeCaseSent).inMilliseconds >= EDGE_CASE_DEBOUNCE_MS) {
          lastEdgeCaseSent = now;
          debugPrint("🔄 [TIER 3: DRIFT / CORNERING] Sustained lateral |ax| = ${uX.abs().toStringAsFixed(2)}g >= 1.2g for ${driftDurationMs.toStringAsFixed(0)}ms >= 300ms, yaw |rZ| = ${rZ.abs().toStringAsFixed(2)} rad/s >= 0.8 rad/s.");
          if (mounted) {
            setState(() {
              _debugStatus = '🔄 Drift / Cornering Edge Case (${uX.abs().toStringAsFixed(1)}g | ${driftDurationMs.toStringAsFixed(0)}ms)';
            });
          }
          _sendImpact(
            acceleration: max(uX.abs() * 9.81, 9.81),
            detectedSide: "Drift / Cornering",
            dynX: uX,
            dynY: uY,
            dynZ: uZ,
            gravX: gravX,
            gravY: gravY,
            gravZ: gravZ,
            durationMs: driftDurationMs,
            isPhoneFall: false,
          );
          driftStreakStartTime = null;
          return;
        }
      } else {
        driftStreakStartTime = null;
      }

      // 3C. SPEED BUMP:
      final isLowHorizontalForBump = uX.abs() < 0.8 && uY.abs() < 0.8;
      if (isLowHorizontalForBump) {
        if (uZ >= 1.2) {
          speedBumpFirstPeakTime = now;
        } else if (speedBumpFirstPeakTime != null) {
          final elapsedMs = now.difference(speedBumpFirstPeakTime!).inMilliseconds.toDouble();
          if (elapsedMs >= 80.0 && elapsedMs <= 200.0 && uZ >= 0.8) {
            if (now.difference(lastEdgeCaseSent).inMilliseconds >= EDGE_CASE_DEBOUNCE_MS) {
              lastEdgeCaseSent = now;
              debugPrint("🚧 [TIER 3: SPEED BUMP] Vertical dynamic dual-peak wave confirmed (+Z peak 1 >= 1.2g, peak 2 = ${uZ.toStringAsFixed(2)}g at ${elapsedMs.toStringAsFixed(0)}ms).");
              if (mounted) {
                setState(() {
                  _debugStatus = '🚧 Speed Bump Edge Case (az=${uZ.toStringAsFixed(1)}g | ${elapsedMs.toStringAsFixed(0)}ms)';
                });
              }
              _sendImpact(
                acceleration: max(uZ.abs() * 9.81, 9.81),
                detectedSide: "Speed Bump",
                dynX: uX,
                dynY: uY,
                dynZ: uZ,
                gravX: gravX,
                gravY: gravY,
                gravZ: gravZ,
                durationMs: elapsedMs,
                isPhoneFall: false,
              );
              speedBumpFirstPeakTime = null;
              return;
            }
          } else if (elapsedMs > 200.0) {
            speedBumpFirstPeakTime = null;
          }
        }
      } else {
        speedBumpFirstPeakTime = null;
      }
    }

    // Normal monitoring status update
    if (!in_phase_2 && !is_freefall_locked && now.difference(_lastSent).inMilliseconds > debounceMs) {
      if (mounted) {
        setState(() {
          _debugStatus = 'Monitoring: |a_total|=${totalMagG.toStringAsFixed(2)}g (dyn=${dynMagnitude.toStringAsFixed(2)}g)';
        });
      }
    }
  }

  void _stopSensors() {
    _stopLiveLocationBroadcast();
    _rawAccelSub?.cancel();
    _userAccelSub?.cancel();
    _gyroSub?.cancel();
    _gpsSub?.cancel();
  }

  Future<void> _startGps() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      _gpsSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 2,
            ),
          ).listen((Position pos) {
            if (!mounted) return;
            setState(() {
              _currentLocation = pos;
              _latitude = pos.latitude;
              _longitude = pos.longitude;
            });
            if (_isLiveTrackingActive) {
              _broadcastCurrentLocationIfNeeded(newLocation: pos);
            }
          });

      final current = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 5),
      );
      if (mounted) {
        setState(() {
          _currentLocation = current;
          _latitude = current.latitude;
          _longitude = current.longitude;
        });
      }
    } catch (e) {
      debugPrint('GPS error: $e');
    }
  }

  String _normalizeImpact(String? side) {
    if (side == null || side.isEmpty) return 'NONE';
    final s = side.toLowerCase();
    if (s.contains('fall') || s.contains('drop')) return 'Phone Fall';
    if (s.contains('rollover')) return 'Rollover';
    if (s.contains('front') && s.contains('left')) return 'Front-Left';
    if (s.contains('front') && s.contains('right')) return 'Front-Right';
    if ((s.contains('rear') || s.contains('back')) && s.contains('left')) {
      return 'Rear-Left';
    }
    if ((s.contains('rear') || s.contains('back')) && s.contains('right')) {
      return 'Rear-Right';
    }
    if (s.contains('front')) return 'Front';
    if (s.contains('rear') || s.contains('back')) return 'Rear';
    if (s.contains('left')) return 'Left';
    if (s.contains('right')) return 'Right';
    return 'NONE';
  }

  String _determineExactSide({
    required double dynX,
    required double dynY,
    required double dynZ,
    required double gravZ,
    required double gyroMag,
    bool isPhoneFall = false,
    bool rotatedPast90Deg = false,
  }) {
    // 1. Phone Fall Edge Case: Gated first so drops do not trigger collision or rollover
    if (isPhoneFall) {
      return 'Phone Fall';
    }

    // 2. Rollover Check: Inversion past 90 degrees with sustained tumble
    // CoreMotion-normalized: gravZ > 0.20 indicates roof inversion
    if (rotatedPast90Deg || (gravZ > 0.20 && gyroMag >= 3.0)) {
      return 'Rollover';
    }

    // 3. Directional Vector Analysis (Impact Side)
    // Physical vehicle hull impact coordinates:
    // Deceleration on impact is opposite to impact location on vehicle hull
    final lr = -dynX; // Left/Right axis
    final fb = -dynY; // Front/Back axis

    final absLR = lr.abs();
    final absFB = fb.abs();

    if (absLR < 0.3 && absFB < 0.3) {
      return 'Front'; // Fallback / Minor
    }

    if (absFB > absLR) {
      if (fb > 0) {
        return (absLR > 0.3) ? (lr > 0 ? 'Front-Right' : 'Front-Left') : 'Front';
      } else {
        return (absLR > 0.3) ? (lr > 0 ? 'Rear-Right' : 'Rear-Left') : 'Rear';
      }
    } else {
      return lr > 0 ? 'Right' : 'Left';
    }
  }

  void _confirmAccident({
    required double dynX,
    required double dynY,
    required double dynZ,
    double gravX = 0.0,
    double gravY = 0.0,
    double gravZ = 0.0,
    required double gyroX,
    required double gyroY,
    required double gyroZ,
    required double acc,
    double durationMs = 40.0,
    bool isPhoneFall = false,
    double freeFallMs = 0.0,
    bool rotatedPast90Deg = false,
    String? classifiedSide,
    String? forceType,
  }) {
    final now = DateTime.now();
    if (now.difference(_lastSent).inMilliseconds < debounceMs) return;

    // Filter out extreme sensor resets (> 350 m/s²)
    if (acc > 350) return;

    final gyroMagnitude = sqrt(gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ);
    final detectedSide = forceType ??
        classifiedSide ??
        _determineExactSide(
          dynX: dynX,
          dynY: dynY,
          dynZ: dynZ,
          gravZ: gravZ,
          gyroMag: gyroMagnitude,
          isPhoneFall: isPhoneFall,
          rotatedPast90Deg: rotatedPast90Deg,
        );

    final isActuallyFall = isPhoneFall ||
        detectedSide.contains('Fall') ||
        detectedSide.contains('FALL') ||
        detectedSide.contains('DROP');
    final isDrivingEdgeCase = detectedSide.contains('Bump') ||
        detectedSide.contains('Breaker') ||
        detectedSide.contains('Braking') ||
        detectedSide.contains('Drift') ||
        detectedSide.contains('Cornering');
    final isRealAccident = !isActuallyFall && !isDrivingEdgeCase;

    // CRITICAL TIMER STOP POLICY:
    // The timer will stop after starting ONLY IF a verified accident happens!
    // If there is no accident (phone drop, speed bump, drift, normal driving),
    // the timer should NEVER stop on its own.
    double? capturedElapsed = lastTrackElapsedTime;
    final wasDrivingMode = isDrivingMode || isTrackRunActive;

    if (isRealAccident && wasDrivingMode) {
      if (trackRunStartTime != null) {
        final impactMoment = impact_timestamp ?? now;
        final elapsed = max(
          0.01,
          impactMoment.difference(trackRunStartTime!).inMilliseconds / 1000.0,
        );
        capturedElapsed = elapsed;
        lastTrackElapsedTime = elapsed;
        liveTrackElapsedString = '${elapsed.toStringAsFixed(3)}s (Accident Stopped)';
      }
      isDrivingMode = false;
      isTrackRunActive = false;
      _trackRunTimer?.cancel();
      _trackRunTimer = null;
      debugPrint("💥 [ACCIDENT CONFIRMED - TIMER STOPPED] Track run stopped at ${capturedElapsed?.toStringAsFixed(3)}s across ${trackDistanceMeters.toStringAsFixed(1)}m for [$detectedSide]");
    }

    if (isActuallyFall) {
      _debugStatus = '📱 Phone Fall Edge Case: Acc=${acc.toStringAsFixed(1)} m/s² (FF=${freeFallMs.toStringAsFixed(0)}ms)';
    } else {
      _debugStatus = '🚨 Verified $detectedSide! Acc=${acc.toStringAsFixed(1)} m/s² (${durationMs.toStringAsFixed(0)}ms)';
    }

    _sendImpact(
      acceleration: acc,
      detectedSide: detectedSide,
      dynX: dynX,
      dynY: dynY,
      dynZ: dynZ,
      gravX: gravX,
      gravY: gravY,
      gravZ: gravZ,
      durationMs: durationMs,
      isPhoneFall: isActuallyFall,
      freeFallMs: isActuallyFall ? freeFallMs : 0.0,
      elapsedTimeSeconds: capturedElapsed,
      trackDistanceMeters: trackDistanceMeters,
      isDrivingMode: wasDrivingMode,
      isManualHardBrake: false,
    );
  }

  Future<void> _sendImpact({
    required double acceleration,
    required String detectedSide,
    double dynX = 0,
    double dynY = 0,
    double dynZ = 0,
    double gravX = 0,
    double gravY = 0,
    double gravZ = 0,
    double durationMs = 40.0,
    bool isPhoneFall = false,
    double freeFallMs = 0.0,
    double? elapsedTimeSeconds,
    double? trackDistanceMeters,
    bool? isDrivingMode,
    bool isManualHardBrake = false,
  }) async {
    final now = DateTime.now();
    if (now.difference(_lastSent).inMilliseconds < debounceMs) return;
    _lastSent = now;

    final bool isRollover = detectedSide.toLowerCase().contains('rollover');
    final bool isFall = isPhoneFall ||
        (!isRollover &&
            (detectedSide.toLowerCase().contains('fall') ||
                detectedSide.toLowerCase().contains('drop')));
    final bool isDrivingEdgeCase = !isRollover &&
        !isFall &&
        (isManualHardBrake ||
            detectedSide.contains('Bump') ||
            detectedSide.contains('Breaker') ||
            detectedSide.contains('Braking') ||
            detectedSide.contains('Drift') ||
            detectedSide.contains('Cornering'));

    setState(() {
      if (isFall) {
        _debugStatus = '📱 Sending Phone Fall Edge Case…';
      } else if (isManualHardBrake) {
        _debugStatus = '🛑 Transmitting Manual Hard Brake…';
      } else if (isDrivingEdgeCase) {
        _debugStatus = '🛡️ Sending $detectedSide Edge Case…';
      } else if (isRollover) {
        _debugStatus = '🔄 Sending Rollover Crash…';
      } else {
        _debugStatus = '📡 Sending to API…';
      }
    });

    final gForce = acceleration / 9.81;
    final clientSeverity = gForce > 7.0
        ? 'High'
        : (gForce > 4.0 ? 'Medium' : 'Low');
    final timeIso = now.toUtc().toIso8601String();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    final bool isNoAccident = detectedSide.contains('No Accident');
    String apiAccidentType;
    if (isRollover) {
      apiAccidentType = 'Rollover';
    } else if (isFall) {
      apiAccidentType = 'Phone Fall';
    } else if (isManualHardBrake) {
      apiAccidentType = 'Hard Braking';
    } else if (isNoAccident) {
      apiAccidentType = 'No Accident';
    } else if (isDrivingEdgeCase) {
      apiAccidentType = detectedSide;
    } else {
      apiAccidentType = 'Impact';
    }

    final effectiveDrivingMode = isDrivingMode ?? this.isDrivingMode;
    final effectiveTrackDistance =
        trackDistanceMeters ?? this.trackDistanceMeters;
    final effectiveElapsed =
        elapsedTimeSeconds ??
        (effectiveDrivingMode ? lastTrackElapsedTime : null);

    final effectiveGravX = gravX != 0 ? gravX : _gravityX / 9.81;
    final effectiveGravY = gravY != 0 ? gravY : _gravityY / 9.81;
    final effectiveGravZ = gravZ != 0 ? gravZ : -(_gravityZ / 9.81);

    final body = <String, dynamic>{
      'CarId': _effectiveCarId,
      'Car_Id': _effectiveCarId,
      'AccidentType': apiAccidentType,
      'Acceleration': acceleration,
      'GForce': gForce,
      'ImpactDurationMs': durationMs,
      'ImpactSide': detectedSide,
      'SteeringSide': _steeringSide,
      'FreeFallDurationMs': isFall ? freeFallMs : 0.0,
      'IsFreeFall': isFall,
      'AccelX': dynX,
      'AccelY': dynY,
      'AccelZ': dynZ,
      'GravityX': effectiveGravX,
      'GravityY': effectiveGravY,
      'GravityZ': effectiveGravZ,
      'GyroX': _gyroX,
      'GyroY': _gyroY,
      'GyroZ': _gyroZ,
      'Latitude': _latitude,
      'Longitude': _longitude,
      'Severity': isNoAccident
          ? 'Safe (No Accident)'
          : ((isFall || isDrivingEdgeCase || isManualHardBrake)
              ? 'Safe (Edge Case)'
              : (isRollover ? 'High' : clientSeverity)),
      'Time': timeIso,
      'IsDrivingMode': effectiveDrivingMode,
      'Is_Driving_Mode': effectiveDrivingMode,
      'IsManualHardBrake': isManualHardBrake,
      'Is_Manual_Hard_Brake': isManualHardBrake,
    };

    if (effectiveDrivingMode &&
        effectiveElapsed != null &&
        effectiveElapsed > 0) {
      body['ElapsedTimeSeconds'] = effectiveElapsed;
      body['TrackDistanceMeters'] = effectiveTrackDistance;
    }

    try {
      final endpoint = '$_baseUrl/DetectAccident/ImpactCalculation';
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        final accidentType =
            (json['accidentType'] ?? json['AccidentType'] ?? apiAccidentType)
                .toString();
        final rawSide =
            (json['impactSide'] ?? json['ImpactSide'] ?? detectedSide)
                .toString();
        final impactForce = (json['impactForce'] as num?)?.toDouble() ?? 0.0;
        final cabinDamage = (json['cabinDamage'] as num?)?.toDouble() ?? 0.0;
        final apiStatus = (json['status'] ?? json['Status'] ?? 'SAFE')
            .toString()
            .toUpperCase();
        final serverTime = (json['time'] ?? json['Time'] ?? timeStr).toString();

        final aisLevel = (json['aisLevel'] ?? json['AisLevel'] ?? 'AIS 0')
            .toString();
        final passengerSeverity =
            (json['passengerSeverity'] ??
                    json['PassengerSeverity'] ??
                    json['severity'] ??
                    clientSeverity)
                .toString();
        final passengerInjury =
            (json['passengerInjury'] ??
                    json['PassengerInjury'] ??
                    'No significant injuries detected.')
                .toString();
        final driverSeverity =
            (json['driverSeverity'] ??
                    json['DriverSeverity'] ??
                    passengerSeverity)
                .toString();
        final driverInjury =
            (json['driverInjury'] ??
                    json['DriverInjury'] ??
                    'Normal driving safe baseline.')
                .toString();
        final occupantSummary =
            (json['occupantSummary'] ?? json['OccupantSummary'] ?? '')
                .toString();
        final steeringSideRet =
            (json['steeringSide'] ?? json['SteeringSide'] ?? _steeringSide)
                .toString();

        final toyImpactSpeedMs =
            (json['toyImpactSpeedMs'] as num?)?.toDouble();
        final realWorldSpeedKmh =
            (json['realWorldSpeedKmh'] as num?)?.toDouble();
        final calculatedTrackAccel =
            (json['calculatedTrackAccel'] as num?)?.toDouble();

        setState(() {
          if (realWorldSpeedKmh != null && realWorldSpeedKmh > 0) {
            lastRealWorldSpeedKmh = realWorldSpeedKmh;
            lastToySpeedMs = toyImpactSpeedMs;
            lastTrackAccel = calculatedTrackAccel;
          }

          if (apiStatus == 'PHONE_FALL') {
            _debugStatus = '📱 Edge Case: Phone Drop Isolated (0% Damage)';
          } else if (isManualHardBrake || accidentType.contains('Braking') || rawSide.contains('Braking')) {
            _debugStatus = '🛑 Hard Braking at Destination: $rawSide (Vehicle Safe | 0% Damage)';
          } else if (apiStatus == 'EDGE_CASE' || isDrivingEdgeCase) {
            _debugStatus = '🛡️ Edge Case: $accidentType Isolated (0% Damage)';
          } else if (apiStatus == 'ACCIDENT') {
            _debugStatus =
                '🚨 ${accidentType.toUpperCase()} [$passengerSeverity]! Force=${impactForce.toStringAsFixed(0)}N Damage=${cabinDamage.toStringAsFixed(0)}%';
          } else if (accidentType.contains('No Accident')) {
            _debugStatus = '✅ Safe Run Completed: No Accident (0% Damage)';
          } else {
            _debugStatus = '✅ Safe / Normal: $rawSide';
          }

          _sensorData = SensorData(
            accidentType: accidentType,
            rawSide: rawSide,
            impactSide: _normalizeImpact(rawSide),
            force: impactForce > 0
                ? '${impactForce.toStringAsFixed(0)} N'
                : 'LOW',
            cabinDamage: cabinDamage,
            severity: passengerSeverity,
            aisLevel: aisLevel,
            passengerSeverity: passengerSeverity,
            passengerInjury: passengerInjury,
            driverSeverity: driverSeverity,
            driverInjury: driverInjury,
            occupantSummary: occupantSummary,
            steeringSide: steeringSideRet,
            lastEvent: serverTime,
            status: apiStatus,
            realWorldSpeedKmh: realWorldSpeedKmh,
            toyImpactSpeedMs: toyImpactSpeedMs,
          );
        });

        final accId =
            (json['accidentId'] as num?)?.toInt() ??
            (json['AccidentId'] as num?)?.toInt();
        if (apiStatus == 'ACCIDENT' && accId != null && accId > 0) {
          _startLiveLocationBroadcast(accId);
        }
      } else {
        _applyClientSideScalingFallback(
          gForce: gForce,
          detectedSide: detectedSide,
          clientSeverity: clientSeverity,
          timeStr: timeStr,
        );
      }
    } catch (e) {
      debugPrint('API Error: $e');
      _applyClientSideScalingFallback(
        gForce: gForce,
        detectedSide: detectedSide,
        clientSeverity: clientSeverity,
        timeStr: timeStr,
        errorMessage: e.toString(),
      );
    }
  }

  void _applyClientSideScalingFallback({
    required double gForce,
    required String detectedSide,
    required String clientSeverity,
    required String timeStr,
    String? errorMessage,
  }) {
    final toyForce = testRigMassKg * (gForce * 9.81);
    final vehicleMass = _effectiveCategoryId == 2
        ? 2150.0
        : (_effectiveCategoryId == 3 ? 850.0 : 1500.0);
    final realForce =
        (toyForce / forceScale) * (vehicleMass / baselineReferenceMassKg);

    final bool isRollover = detectedSide.contains('Rollover');
    final String accidentType = isRollover
        ? 'Rollover'
        : (detectedSide.contains('Front')
              ? 'Frontal Collision'
              : (detectedSide.contains('Rear')
                    ? 'Rear Collision'
                    : 'Side Impact'));

    double cabinForceEst = realForce * 0.35 * (isRollover ? 1.45 : 1.0);
    double physicalRatio = cabinForceEst / vehicleCabinYieldStrengthN;
    double gSeverityFactor = 1.0 + (gForce > 1.0 ? log(gForce) / ln10 : 0.0);
    double rawDamage = pow(physicalRatio, 1.25) * 100.0 * gSeverityFactor;
    if (isRollover) rawDamage *= 1.30;
    double cabinDamage = rawDamage.clamp(1.0, 100.0);

    final bool isRHD = !_steeringSide.toLowerCase().contains('left');
    double passengerMultiplier = 1.0;
    double driverMultiplier = 1.0;
    String occupantSummary = '';

    if (isRollover) {
      passengerMultiplier = 1.45;
      driverMultiplier = 1.45;
      occupantSummary =
          'Rollover Hazard: Severe multi-axis roof crush danger for all occupants.';
    } else if (detectedSide.contains('Right')) {
      if (isRHD) {
        driverMultiplier = 1.25;
        passengerMultiplier = 0.55;
        occupantSummary =
            'RHD Vehicle: Driver in direct right-side impact zone. Passenger has crumple buffer.';
      } else {
        passengerMultiplier = 1.25;
        driverMultiplier = 0.55;
        occupantSummary =
            'LHD Vehicle: Passenger in direct right-side impact zone! High passenger intrusion risk.';
      }
    } else if (detectedSide.contains('Left')) {
      if (isRHD) {
        passengerMultiplier = 1.25;
        driverMultiplier = 0.55;
        occupantSummary =
            'RHD Vehicle: Passenger in direct left-side impact zone! High passenger intrusion risk.';
      } else {
        driverMultiplier = 1.25;
        passengerMultiplier = 0.55;
        occupantSummary =
            'LHD Vehicle: Driver in direct left-side impact zone. Passenger has crumple buffer.';
      }
    } else if (detectedSide.contains('Front')) {
      occupantSummary =
          'Frontal Impact: Symmetric forward deceleration, seatbelt & airbag engagement.';
    } else {
      occupantSummary =
          'Rear Collision: Rearward seatback rebound and whiplash on occupants.';
    }

    final pG = gForce * passengerMultiplier;
    final dG = gForce * driverMultiplier;

    String aisOf(double g) => g >= 40.0
        ? 'AIS 5-6'
        : (g >= 20.0
              ? 'AIS 3-4'
              : (g >= 10.0 ? 'AIS 2' : (g >= 4.0 ? 'AIS 1' : 'AIS 0')));
    String sevOf(double g) => g >= 40.0
        ? 'Critical / Fatal'
        : (g >= 20.0
              ? 'Serious to Severe'
              : (g >= 10.0 ? 'Moderate' : (g >= 4.0 ? 'Minor' : 'None')));

    final pSev = sevOf(pG);
    final pAis = aisOf(pG);
    final dSev = sevOf(dG);

    setState(() {
      _debugStatus = errorMessage != null
          ? '🚨 OFFLINE VERIFIED $detectedSide! Force=${realForce.toStringAsFixed(0)}N Damage=${cabinDamage.toStringAsFixed(0)}%'
          : '🚨 $detectedSide [$pSev]! Force=${realForce.toStringAsFixed(0)}N';

      _sensorData = SensorData(
        accidentType: accidentType,
        rawSide: detectedSide,
        impactSide: _normalizeImpact(detectedSide),
        force: '${realForce.toStringAsFixed(0)} N',
        cabinDamage: cabinDamage,
        severity: pSev,
        aisLevel: pAis,
        passengerSeverity: pSev,
        passengerInjury: '$pSev: Biomechanical occupant load.',
        driverSeverity: dSev,
        driverInjury: '$dSev: Biomechanical occupant load.',
        occupantSummary: occupantSummary,
        steeringSide: _steeringSide,
        lastEvent: timeStr,
        status: 'ACCIDENT',
      );
    });
  }

  void _startLiveLocationBroadcast(int accidentId) {
    _activeAccidentId = accidentId;
    _isLiveTrackingActive = true;

    if (_currentLocation != null) {
      _sendLiveLocationUpdate(accidentId, _currentLocation!);
    }

    _liveLocationTimer?.cancel();
    _liveLocationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _broadcastCurrentLocationIfNeeded();
    });
  }

  void _broadcastCurrentLocationIfNeeded({Position? newLocation}) {
    final accId = _activeAccidentId;
    if (accId == null || !_isLiveTrackingActive) return;
    final pos = newLocation ?? _currentLocation;
    if (pos == null) return;

    final now = DateTime.now();
    if (now.difference(_lastBroadcastTime).inSeconds < 2) return;

    if (_lastBroadcastedLocation != null) {
      final distance = Geolocator.distanceBetween(
        _lastBroadcastedLocation!.latitude,
        _lastBroadcastedLocation!.longitude,
        pos.latitude,
        pos.longitude,
      );
      if (distance < 1.5 && now.difference(_lastBroadcastTime).inSeconds < 15) {
        return;
      }
    }

    _sendLiveLocationUpdate(accId, pos);
  }

  Future<void> _sendLiveLocationUpdate(int accidentId, Position pos) async {
    _lastBroadcastTime = DateTime.now();
    _lastBroadcastedLocation = pos;

    final body = {
      'AccidentId': accidentId,
      'accidentId': accidentId,
      'CarId': _effectiveCarId,
      'Latitude': pos.latitude,
      'Longitude': pos.longitude,
      'Timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final url = '$_baseUrl/DetectAccident/UpdateLiveLocation';
      await http
          .post(
            Uri.parse(url),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Live location update note: $e');
    }
  }

  void _stopLiveLocationBroadcast() {
    _liveLocationTimer?.cancel();
    _liveLocationTimer = null;
    _isLiveTrackingActive = false;
    _activeAccidentId = null;
    _lastBroadcastedLocation = null;
  }

  void _showIpDialog() {
    final controller = TextEditingController(text: _serverIp);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configure Server IP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the backend IP:Port (e.g. 192.168.1.5:5000 or full URL)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '192.168.1.100:5000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newIp = controller.text.trim();
              if (newIp.isNotEmpty) {
                ApiInterface.ip = newIp;
                setState(() {});
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCrashTestSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      '⚡ Crash Test Simulator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Text(
                  'Simulate vehicle crash scenarios & edge cases to verify highlights, telemetry & injury matrices:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _testCrashButton(
                      label: '💥 Front Impact',
                      sub: '16.5 m/s²',
                      color: Colors.red.shade700,
                      onTap: () {
                        Navigator.pop(ctx);
                        _confirmAccident(
                          dynX: 0.1,
                          dynY: 1.6,
                          dynZ: -0.2,
                          gravZ: -0.7,
                          gyroX: 0.1,
                          gyroY: 0.2,
                          gyroZ: 0.1,
                          acc: 16.5,
                          durationMs: 45.0,
                          forceType: 'Front',
                        );
                      },
                    ),
                    _testCrashButton(
                      label: '💥 Right Side Impact',
                      sub: '15.5 m/s²',
                      color: Colors.orange.shade800,
                      onTap: () {
                        Navigator.pop(ctx);
                        _confirmAccident(
                          dynX: 1.5,
                          dynY: 0.1,
                          dynZ: 0.0,
                          gravZ: -0.7,
                          gyroX: 0.3,
                          gyroY: 0.1,
                          gyroZ: 0.4,
                          acc: 15.5,
                          durationMs: 40.0,
                          forceType: 'Right',
                        );
                      },
                    ),
                    _testCrashButton(
                      label: '💥 Left Side Impact',
                      sub: '15.5 m/s²',
                      color: Colors.amber.shade900,
                      onTap: () {
                        Navigator.pop(ctx);
                        _confirmAccident(
                          dynX: -1.5,
                          dynY: 0.1,
                          dynZ: 0.0,
                          gravZ: -0.7,
                          gyroX: -0.3,
                          gyroY: 0.1,
                          gyroZ: -0.4,
                          acc: 15.5,
                          durationMs: 40.0,
                          forceType: 'Left',
                        );
                      },
                    ),
                    _testCrashButton(
                      label: '💥 Rear Collision',
                      sub: '14.8 m/s²',
                      color: Colors.purple.shade700,
                      onTap: () {
                        Navigator.pop(ctx);
                        _confirmAccident(
                          dynX: 0.0,
                          dynY: -1.5,
                          dynZ: 0.1,
                          gravZ: -0.7,
                          gyroX: 0.1,
                          gyroY: -0.3,
                          gyroZ: 0.0,
                          acc: 14.8,
                          durationMs: 45.0,
                          forceType: 'Rear',
                        );
                      },
                    ),
                    _testCrashButton(
                      label: '🔄 Rollover / Roof',
                      sub: '5.2 rad/s Gyro',
                      color: Colors.red.shade900,
                      onTap: () {
                        Navigator.pop(ctx);
                        _confirmAccident(
                          dynX: 0.4,
                          dynY: 0.5,
                          dynZ: 1.2,
                          gravZ: 0.85,
                          gyroX: 5.2,
                          gyroY: 2.1,
                          gyroZ: 4.8,
                          acc: 17.0,
                          durationMs: 65.0,
                          forceType: 'Rollover',
                        );
                      },
                    ),
                    _testCrashButton(
                      label: '📱 Phone Fall (Drop)',
                      sub: '0% Vehicle Damage',
                      color: Colors.orange.shade700,
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendImpact(
                          acceleration: 15.0,
                          detectedSide: 'Phone Fall',
                          dynX: 0.1,
                          dynY: 0.1,
                          dynZ: 1.5,
                          durationMs: 30.0,
                        );
                      },
                    ),
                    _testCrashButton(
                      label: '🛑 Hard Braking',
                      sub: '0% Cabin Damage',
                      color: Colors.teal.shade700,
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendImpact(
                          acceleration: 9.81,
                          detectedSide: 'Hard Braking',
                          dynX: 0.1,
                          dynY: -1.0,
                          dynZ: 0.0,
                          durationMs: 250.0,
                          isDrivingMode: true,
                          isManualHardBrake: true,
                        );
                      },
                    ),
                    _testCrashButton(
                      label: '🚧 Speed Bump',
                      sub: '0% Cabin Damage',
                      color: Colors.blueGrey.shade700,
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendImpact(
                          acceleration: 11.0,
                          detectedSide: 'Speed Bump',
                          dynX: 0.1,
                          dynY: 0.1,
                          dynZ: 1.2,
                          durationMs: 120.0,
                        );
                      },
                    ),
                    _testCrashButton(
                      label: '✅ Reset to Safe',
                      sub: 'Clear State',
                      color: Colors.green.shade700,
                      onTap: () {
                        Navigator.pop(ctx);
                        _stopLiveLocationBroadcast();
                        setState(() {
                          _sensorData = null;
                          lastRealWorldSpeedKmh = null;
                          _debugStatus = 'Live: All systems safe & monitoring';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _testCrashButton({
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sd = _sensorData;
    final isAccident = sd?.status == 'ACCIDENT';
    final isPhoneFall = sd?.status == 'PHONE_FALL' || (sd?.accidentType.contains('Fall') ?? false);
    final isSpeedBump = sd?.accidentType.contains('Bump') ?? false;
    final isHardBraking = sd?.accidentType.contains('Braking') ?? (sd?.accidentType.contains('Brake') ?? false);
    final isDrift = (sd?.accidentType.contains('Drift') ?? false) || (sd?.accidentType.contains('Cornering') ?? false);
    final isDrivingEdgeCase = isSpeedBump || isHardBraking || isDrift;
    final isAnyEdgeCase = isPhoneFall || isDrivingEdgeCase || sd?.status == 'EDGE_CASE';

    final String bannerTitle = () {
      if (isAccident) return '🚨 ${(sd?.accidentType ?? "ACCIDENT").toUpperCase()} DETECTED';
      if (isPhoneFall) return '📱 PHONE FALL DETECTED (EDGE CASE)';
      if (isSpeedBump) return '🚧 SPEED BUMP DETECTED (EDGE CASE)';
      if (isHardBraking) return '🛑 HARD BRAKING DETECTED (EDGE CASE)';
      if (isDrift) return '🔄 DRIFT / SHARP TURN (EDGE CASE)';
      if (isAnyEdgeCase) return '🛡️ ${(sd?.accidentType ?? "EDGE CASE").toUpperCase()} (EDGE CASE)';
      return '✅ Safe — No Accident';
    }();

    final String bannerSubtitle = () {
      if (isPhoneFall) return 'Non-collision phone drop filtered with zero vehicle damage.';
      if (isSpeedBump) return 'Vertical road hump pitch rotation isolated with zero vehicle damage.';
      if (isHardBraking) return 'Normal emergency ABS stopping dynamics isolated with zero vehicle damage.';
      if (isDrift) return 'Lateral cornering dynamics isolated with zero vehicle damage.';
      if (isAnyEdgeCase) return 'Non-collision driving dynamic isolated with zero vehicle damage.';
      return '';
    }();

    final IconData bannerIcon = () {
      if (isAccident) return Icons.warning_rounded;
      if (isPhoneFall) return Icons.phone_android;
      if (isSpeedBump) return Icons.height;
      if (isHardBraking) return Icons.pan_tool_rounded;
      if (isDrift) return Icons.swap_calls_rounded;
      if (isAnyEdgeCase) return Icons.shield_rounded;
      return Icons.verified_user_rounded;
    }();

    return Scaffold(
      backgroundColor: const Color(0xfff2f2f4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Header Row
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.orange,
                      child: Text(
                        _firstLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isAccident
                                    ? Colors.red
                                    : (isAnyEdgeCase
                                          ? Colors.amber
                                          : Colors.green),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAccident
                                  ? 'Active Alert'
                                  : (isAnyEdgeCase
                                        ? 'Edge Case Isolated'
                                        : 'Accident Detection Active'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.flash_on,
                        size: 24,
                        color: Colors.orange,
                      ),
                      onPressed: _showCrashTestSheet,
                      tooltip: '⚡ Test Collision / Simulator',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings_ethernet,
                        size: 22,
                        color: Colors.blueGrey,
                      ),
                      onPressed: _showIpDialog,
                      tooltip: 'Server IP: $_serverIp',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        size: 22,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _stopSensors();
                        if (widget.onLogout != null) {
                          widget.onLogout!();
                        } else {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LogIn()),
                            (_) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // =========================================================================
              // TOP DASHBOARD CONTROLS: DUAL-SCENARIO MODE (STATIONARY VS DRIVING)
              // =========================================================================
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Scenario Mode Status Header & Running Timer Badge
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDrivingMode ? Colors.green : Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isDrivingMode
                              ? 'ACTIVE DRIVING MODE'
                              : 'STATIONARY / PARKED MODE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isDrivingMode ? Colors.green : Colors.blue,
                          ),
                        ),
                        const Spacer(),
                        if (isDrivingMode) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer,
                                  size: 11,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  liveTrackElapsedString,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (liveRealWorldSpeedKmh > 0) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade800,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.speed,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${liveRealWorldSpeedKmh.toStringAsFixed(1)} km/h',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ] else if (lastRealWorldSpeedKmh != null) ...[
                          if (lastTrackElapsedTime != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.flag,
                                    size: 10,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${lastTrackElapsedTime!.toStringAsFixed(2)}s',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.speed,
                                  size: 10,
                                  color: Colors.purple,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${lastRealWorldSpeedKmh!.toStringAsFixed(1)} km/h',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'IMU Sensor Mode',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Fixed Prominent Action Buttons (Side by Side)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isDrivingMode ? null : startDriveRun,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff2eb450),
                              disabledBackgroundColor: Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: isDrivingMode ? 0 : 3,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_circle_fill, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Start Drive (${trackDistanceMeters.toStringAsFixed(1)}m)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                isDrivingMode ? stopDriveAtDestination : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffe12d2d),
                              disabledBackgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: isDrivingMode ? 3 : 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.stop_circle, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Stop Drive Run',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Track Distance Input Box & Quick Presets
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.straighten, size: 14, color: Colors.blue),
                          const SizedBox(width: 5),
                          const Text(
                            'Track Distance:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 50,
                            height: 26,
                            child: TextField(
                              controller: _distanceController,
                              enabled: !isDrivingMode,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: updateTrackDistance,
                            ),
                          ),
                          const Text(
                            ' m',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: ['2.0', '4.0', '6.0'].map((preset) {
                              final isSelected =
                                  trackDistanceInput == preset;
                              return Padding(
                                padding: const EdgeInsets.only(left: 3),
                                child: InkWell(
                                  onTap: isDrivingMode
                                      ? null
                                      : () => updateTrackDistance(preset),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${preset}m',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Selected Car Picture & Highlight
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: makeCarImpactVisualizer(
                  make: widget.make,
                  plate: widget.plate,
                  categoryId: _effectiveCategoryId,
                  carType: widget.carType,
                  isAccident: isAccident,
                  impactSide: sd?.impactSide ?? (sd?.rawSide ?? '-'),
                  cabinDamage: sd?.cabinDamage ?? 0,
                ),
              ),

              // Status Banner
              if (sd != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAccident
                        ? Colors.red
                        : (isAnyEdgeCase
                              ? Colors.orange.shade800
                              : const Color(0xff1ab34c)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(bannerIcon, size: 26, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bannerTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            if (isAccident || isAnyEdgeCase) ...[
                              const SizedBox(height: 3),
                              Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isAnyEdgeCase
                                          ? 'Edge Case: 0% Damage'
                                          : 'Severity: ${sd.passengerSeverity ?? sd.severity}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Time: ${sd.lastEvent}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.95),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (bannerSubtitle.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                bannerSubtitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                            if (_isLiveTrackingActive) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Broadcasting Live Location',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 2x2 Grid + DamageCard + Real Vehicle Speed Card
              const SizedBox(height: 10),
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
                          value: sd?.accidentType ?? '-',
                          sub: 'Classification',
                          highlight: isAccident,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: InfoCard(
                          title: 'Passenger Severity',
                          value: sd?.passengerSeverity ?? (sd?.severity ?? '-'),
                          sub: sd?.aisLevel ?? 'Impact Matrix',
                          highlight: isAccident,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: InfoCard(
                          title: 'Impact Side',
                          value: sd?.impactSide ?? '-',
                          sub: sd?.rawSide ?? 'Waiting…',
                          highlight: isAccident,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: InfoCard(
                          title: 'Force Impact',
                          value: sd?.force ?? 'OFF',
                          sub: 'Newtons',
                          highlight: isAccident,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: DamageCard(damage: sd?.cabinDamage ?? 0),
                      ),
                      if (lastRealWorldSpeedKmh != null &&
                          lastRealWorldSpeedKmh! > 0)
                        SizedBox(
                          width: itemWidth,
                          child: InfoCard(
                            title: 'Real Vehicle Speed',
                            value:
                                '${lastRealWorldSpeedKmh!.toStringAsFixed(1)} km/h',
                            sub:
                                'Toy: ${(lastToySpeedMs ?? 0.0).toStringAsFixed(1)}m/s (Froude 1:10)',
                            highlight: isAccident,
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Occupant Biomechanical Injury Assessment
              const SizedBox(height: 10),
              OccupantInjuryCard(
                steeringSide: sd?.steeringSide ?? _steeringSide,
                passengerSeverity: sd?.passengerSeverity ?? 'None (AIS 0)',
                passengerInjury:
                    sd?.passengerInjury ??
                    'Normal driving safe baseline / no trauma.',
                driverSeverity: sd?.driverSeverity ?? 'None (AIS 0)',
                driverInjury:
                    sd?.driverInjury ??
                    'Normal driving safe baseline / no trauma.',
                occupantSummary: sd?.occupantSummary ?? '',
                isAccident: isAccident,
              ),

              // Real-time Sensors Section
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Real-time Sensors (50Hz / 20ms)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SensorRow(
                      label: 'Accelerometer Dynamic (G)',
                      x: _accelX,
                      y: _accelY,
                      z: _accelZ,
                    ),
                    const Divider(height: 16),
                    SensorRow(
                      label: 'Gyroscope (rad/s)',
                      x: _gyroX,
                      y: _gyroY,
                      z: _gyroZ,
                    ),
                    const Divider(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GPS Coordinates',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lat: ${_latitude.toStringAsFixed(6)}, Lon: ${_longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detection Status',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _debugStatus,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'monospace',
                            color:
                                (_debugStatus.contains('✅') ||
                                    _debugStatus.contains('🚨'))
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 6),
                        LayoutBuilder(
                          builder: (context, box) {
                            final pct = (_shakeLevel / 2.0).clamp(0.0, 1.0);
                            return Stack(
                              children: [
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffdedede),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Container(
                                  height: 6,
                                  width: box.maxWidth * pct,
                                  decoration: BoxDecoration(
                                    color: pct > 0.3
                                        ? Colors.red
                                        : Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // =========================================================================
              // 4-METER / CUSTOM TEST TRACK RUN CONTROLS (BOTTOM SUMMARY & CONTROLS)
              // =========================================================================
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isTrackRunActive
                                ? Colors.green.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.15),
                          ),
                          child: Icon(
                            isTrackRunActive
                                ? Icons.timer
                                : Icons.flag_circle,
                            size: 14,
                            color: isTrackRunActive
                                ? Colors.green
                                : Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'TEST TRACK ACCELERATION RUN',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'd = ${trackDistanceMeters.toStringAsFixed(1)}m',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Track Time',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              liveTrackElapsedString,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Toy Impact Speed',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              '${liveTrackEstimatedSpeed.toStringAsFixed(2)} m/s',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Scaled Speed',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              '${liveRealWorldSpeedKmh.toStringAsFixed(1)} km/h',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
