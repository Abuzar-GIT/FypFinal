import 'package:flutter/material.dart';
import 'package:screens/Model/Node.dart';

void main() => runApp(const MaterialApp(home: CarNodeScreen()));

// ─── Data Models ────────────────────────────────────────────────────────────

// class Node {
//   int id;
//   double x;
//   double y;
//   Node({required this.id, required this.x, required this.y});
// }

class CarModel {
  String name;
  List<Node> nodes;
  CarModel({required this.name, required this.nodes});
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class CarNodeScreen extends StatefulWidget {
  const CarNodeScreen({super.key});
  @override
  State<CarNodeScreen> createState() => _CarNodeScreenState();
}

class _CarNodeScreenState extends State<CarNodeScreen> {
  late List<CarModel> cars;
  CarModel? selectedCar;

  // Canvas size — keep in sync with the Container below
  static const double W = 300;
  static const double H = 560;

  @override
  void initState() {
    super.initState();

    cars = [
      CarModel(
        name: "Sedan",
        nodes: [
          //  id   x      y        — region
          Node(id: 1, x: 150, y: 28), // front-center top
          Node(id: 2, x: 68, y: 58), // front-left corner
          Node(id: 3, x: 232, y: 58), // front-right corner
          Node(id: 4, x: 88, y: 96), // hood left
          Node(id: 5, x: 212, y: 96), // hood right
          Node(id: 6, x: 102, y: 136), // A-pillar left
          Node(id: 7, x: 150, y: 128), // windshield center
          Node(id: 8, x: 198, y: 136), // A-pillar right (was 5 in image)
          Node(id: 9, x: 150, y: 172), // cabin center top
          Node(id: 10, x: 18, y: 148), // left outer – mirror zone
          Node(id: 11, x: 18, y: 210), // left outer – front door top
          Node(id: 12, x: 18, y: 278), // left outer – front door bottom
          Node(id: 13, x: 18, y: 340), // left outer – rear door
          Node(id: 14, x: 18, y: 410), // left outer – rear quarter
          Node(id: 15, x: 282, y: 148), // right outer – mirror zone
          Node(id: 16, x: 282, y: 210), // right outer – front door top
          Node(id: 17, x: 282, y: 278), // right outer – front door bottom
          Node(id: 18, x: 282, y: 340), // right outer – rear door
          Node(id: 19, x: 282, y: 410), // right outer – rear quarter
          Node(id: 20, x: 96, y: 240), // B-pillar left
          Node(id: 21, x: 204, y: 240), // B-pillar right
          Node(id: 22, x: 96, y: 320), // C-pillar left
          Node(id: 23, x: 204, y: 320), // C-pillar right
          Node(id: 24, x: 150, y: 358), // rear windshield center
          Node(id: 25, x: 88, y: 420), // trunk left
          Node(id: 26, x: 150, y: 416), // trunk center
          Node(id: 27, x: 212, y: 420), // trunk right
          Node(id: 28, x: 150, y: 464), // rear bumper center
          Node(id: 29, x: 78, y: 484), // rear-left corner
          Node(id: 30, x: 222, y: 484), // rear-right corner
        ],
      ),
    ];

    selectedCar = cars[0];
  }

  void _printNodes() {
    for (var n in selectedCar!.nodes) {
      debugPrint(
        'Node ${n.id}: x=${n.x.toStringAsFixed(1)}, y=${n.y.toStringAsFixed(1)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Car Node Editor',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined, color: Color(0xFF2979FF)),
            tooltip: 'Print node coords',
            onPressed: _printNodes,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Dropdown ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: DropdownButtonFormField<CarModel>(
              initialValue: selectedCar,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              items: cars
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCar = v),
            ),
          ),

          // ── Canvas ─────────────────────────────────────────────────────
          Expanded(
            child: Center(
              child: SizedBox(
                width: W,
                height: H,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Car drawing
                    Positioned.fill(
                      child: CustomPaint(painter: _TopDownCarPainter()),
                    ),

                    // Nodes
                    ...selectedCar!.nodes.map((node) {
                      return Positioned(
                        // node.x/y is the CENTER of the circle
                        left: node.x - 13,
                        top: node.y - 13,
                        child: GestureDetector(
                          onPanUpdate: (d) {
                            setState(() {
                              node.x = (node.x + d.delta.dx).clamp(13, W - 13);
                              node.y = (node.y + d.delta.dy).clamp(13, H - 13);
                            });
                          },
                          child: _NodeBubble(id: node.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Node Bubble ────────────────────────────────────────────────────────────

class _NodeBubble extends StatelessWidget {
  final int id;
  const _NodeBubble({required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2979FF),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x552979FF), blurRadius: 6, spreadRadius: 1),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$id',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}

// ─── Painter ────────────────────────────────────────────────────────────────

class _TopDownCarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width; // 300
    final double cx = w / 2; // 150

    // ── Paints ────────────────────────────────────────────────────
    final bodyFill = Paint()
      ..color = const Color(0xFFECEFF1)
      ..style = PaintingStyle.fill;
    final bodyStroke = Paint()
      ..color = const Color(0xFF546E7A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;
    final glassFill = Paint()
      ..color = const Color(0xFFB3D1F5)
      ..style = PaintingStyle.fill;
    final glassStroke = Paint()
      ..color = const Color(0xFF5B8DB8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final roofFill = Paint()
      ..color = const Color(0xFFD7DDE1)
      ..style = PaintingStyle.fill;
    final detailStroke = Paint()
      ..color = const Color(0xFF78909C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final wheelFill = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.fill;
    final wheelRim = Paint()
      ..color = const Color(0xFF78909C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final headlight = Paint()
      ..color = const Color(0xFFFFF9C4)
      ..style = PaintingStyle.fill;
    final taillight = Paint()
      ..color = const Color(0xFFFFCDD2)
      ..style = PaintingStyle.fill;
    final lightStroke = Paint()
      ..color = const Color(0xFF546E7A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // ══════════════════════════════════════════════════════════════
    // 1. WHEELS  (drawn first → behind body)
    // ══════════════════════════════════════════════════════════════
    void drawWheel(double ex, double ey) {
      final r = Rect.fromCenter(center: Offset(ex, ey), width: 28, height: 46);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(6)),
        wheelFill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(6)),
        wheelRim,
      );
      // Rim inner
      final r2 = Rect.fromCenter(center: Offset(ex, ey), width: 16, height: 30);
      canvas.drawOval(
        r2,
        Paint()
          ..color = const Color(0xFF455A64)
          ..style = PaintingStyle.fill,
      );
    }

    drawWheel(cx - 74, 110); // front-left
    drawWheel(cx + 74, 110); // front-right
    drawWheel(cx - 74, 420); // rear-left
    drawWheel(cx + 74, 420); // rear-right

    // ══════════════════════════════════════════════════════════════
    // 2. MAIN BODY
    // ══════════════════════════════════════════════════════════════
    // Reference image shows:
    //   • narrow rounded front bumper
    //   • wide middle (doors)
    //   • narrow rounded rear bumper
    //   • overall silhouette like a top-down sedan

    final body = Path();
    // Front bumper – narrow, rounded
    body.moveTo(cx, 18);
    body.cubicTo(cx + 55, 18, cx + 70, 36, cx + 70, 60); // front-right curve
    // Right side – slight taper mid
    body.cubicTo(cx + 72, 90, cx + 72, 380, cx + 70, 460);
    // Rear bumper – narrow, rounded
    body.cubicTo(cx + 70, 490, cx + 50, 502, cx, 502);
    body.cubicTo(cx - 50, 502, cx - 70, 490, cx - 70, 460);
    // Left side
    body.cubicTo(cx - 72, 380, cx - 72, 90, cx - 70, 60);
    body.cubicTo(cx - 70, 36, cx - 55, 18, cx, 18);
    body.close();

    canvas.drawPath(body, bodyFill);
    canvas.drawPath(body, bodyStroke);

    // ══════════════════════════════════════════════════════════════
    // 3. HOOD (front area detail lines)
    // ══════════════════════════════════════════════════════════════
    // Center ridge line
    canvas.drawLine(Offset(cx, 22), Offset(cx, 118), detailStroke);
    // Left hood edge
    final hoodL = Path()
      ..moveTo(cx - 58, 42)
      ..cubicTo(cx - 48, 52, cx - 38, 90, cx - 36, 118);
    canvas.drawPath(hoodL, detailStroke);
    // Right hood edge
    final hoodR = Path()
      ..moveTo(cx + 58, 42)
      ..cubicTo(cx + 48, 52, cx + 38, 90, cx + 36, 118);
    canvas.drawPath(hoodR, detailStroke);

    // ══════════════════════════════════════════════════════════════
    // 4. HEADLIGHTS
    // ══════════════════════════════════════════════════════════════
    void drawLight(double lx, double ly, double lw, double lh, Paint fill) {
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(lx, ly, lw, lh),
        const Radius.circular(4),
      );
      canvas.drawRRect(rr, fill);
      canvas.drawRRect(rr, lightStroke);
    }

    drawLight(cx - 66, 28, 28, 12, headlight); // left headlight
    drawLight(cx + 38, 28, 28, 12, headlight); // right headlight

    // ══════════════════════════════════════════════════════════════
    // 5. FRONT WINDSHIELD
    // ══════════════════════════════════════════════════════════════
    final frontWS = Path();
    frontWS.moveTo(cx - 46, 118);
    frontWS.cubicTo(cx - 40, 112, cx + 40, 112, cx + 46, 118);
    frontWS.lineTo(cx + 42, 162);
    frontWS.cubicTo(cx + 30, 168, cx - 30, 168, cx - 42, 162);
    frontWS.close();
    canvas.drawPath(frontWS, glassFill);
    canvas.drawPath(frontWS, glassStroke);

    // Wiper line
    canvas.drawLine(Offset(cx - 14, 132), Offset(cx + 18, 128), detailStroke);

    // ══════════════════════════════════════════════════════════════
    // 6. ROOF / CABIN
    // ══════════════════════════════════════════════════════════════
    final roof = Path();
    roof.moveTo(cx - 42, 162);
    roof.cubicTo(cx - 30, 168, cx + 30, 168, cx + 42, 162);
    roof.lineTo(cx + 42, 320);
    roof.cubicTo(cx + 30, 326, cx - 30, 326, cx - 42, 320);
    roof.close();
    canvas.drawPath(roof, roofFill);
    canvas.drawPath(roof, glassStroke);

    // ── Seat / headrest hints inside cabin ──
    // Front seats
    _roundRect(canvas, detailStroke, cx - 34, 182, 24, 32, 6);
    _roundRect(canvas, detailStroke, cx + 10, 182, 24, 32, 6);
    // Rear seats
    _roundRect(canvas, detailStroke, cx - 34, 252, 24, 30, 6);
    _roundRect(canvas, detailStroke, cx + 10, 252, 24, 30, 6);
    // Center console front
    canvas.drawLine(Offset(cx - 4, 190), Offset(cx + 4, 190), detailStroke);
    canvas.drawLine(Offset(cx, 182), Offset(cx, 214), detailStroke);

    // ══════════════════════════════════════════════════════════════
    // 7. MIRRORS (side)
    // ══════════════════════════════════════════════════════════════
    final mirrorFill = Paint()
      ..color = const Color(0xFFCFD8DC)
      ..style = PaintingStyle.fill;

    Path mirrorPath(bool left) {
      final sign = left ? -1 : 1;
      final mx = cx + sign * 70.0;
      final p = Path();
      p.moveTo(mx, 128);
      p.lineTo(mx + sign * 18, 134);
      p.lineTo(mx + sign * 16, 158);
      p.lineTo(mx, 160);
      p.close();
      return p;
    }

    canvas.drawPath(mirrorPath(true), mirrorFill);
    canvas.drawPath(mirrorPath(true), bodyStroke..strokeWidth = 1.2);
    canvas.drawPath(mirrorPath(false), mirrorFill);
    canvas.drawPath(mirrorPath(false), bodyStroke..strokeWidth = 1.2);
    bodyStroke.strokeWidth = 2.2; // restore

    // ══════════════════════════════════════════════════════════════
    // 8. DOOR LINES
    // ══════════════════════════════════════════════════════════════
    // B-pillar horizontal
    canvas.drawLine(Offset(cx - 68, 240), Offset(cx + 68, 240), detailStroke);
    // Left door vertical lines
    canvas.drawLine(Offset(cx - 66, 162), Offset(cx - 66, 320), detailStroke);
    // Right door vertical lines
    canvas.drawLine(Offset(cx + 66, 162), Offset(cx + 66, 320), detailStroke);
    // Door handles
    _roundRect(canvas, detailStroke, cx - 68, 210, 10, 4, 2); // front-left
    _roundRect(canvas, detailStroke, cx + 58, 210, 10, 4, 2); // front-right
    _roundRect(canvas, detailStroke, cx - 68, 274, 10, 4, 2); // rear-left
    _roundRect(canvas, detailStroke, cx + 58, 274, 10, 4, 2); // rear-right

    // ══════════════════════════════════════════════════════════════
    // 9. REAR WINDSHIELD
    // ══════════════════════════════════════════════════════════════
    final rearWS = Path();
    rearWS.moveTo(cx - 42, 320);
    rearWS.cubicTo(cx - 30, 326, cx + 30, 326, cx + 42, 320);
    rearWS.lineTo(cx + 38, 372);
    rearWS.cubicTo(cx + 26, 378, cx - 26, 378, cx - 38, 372);
    rearWS.close();
    canvas.drawPath(rearWS, glassFill);
    canvas.drawPath(rearWS, glassStroke);

    // Rear wiper
    canvas.drawLine(Offset(cx + 10, 340), Offset(cx - 14, 355), detailStroke);

    // ══════════════════════════════════════════════════════════════
    // 10. TRUNK
    // ══════════════════════════════════════════════════════════════
    final trunk = Path();
    trunk.moveTo(cx - 38, 372);
    trunk.cubicTo(cx - 26, 378, cx + 26, 378, cx + 38, 372);
    trunk.lineTo(cx + 44, 450);
    trunk.cubicTo(cx + 30, 456, cx - 30, 456, cx - 44, 450);
    trunk.close();
    canvas.drawPath(
      trunk,
      Paint()
        ..color = const Color(0xFFDDE2E6)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(trunk, detailStroke);

    // Trunk keyhole / handle
    canvas.drawCircle(Offset(cx, 412), 5, detailStroke);
    canvas.drawLine(Offset(cx - 18, 434), Offset(cx + 18, 434), detailStroke);

    // ══════════════════════════════════════════════════════════════
    // 11. TAILLIGHTS
    // ══════════════════════════════════════════════════════════════
    drawLight(cx - 62, 456, 30, 14, taillight); // left taillight
    drawLight(cx + 32, 456, 30, 14, taillight); // right taillight

    // ══════════════════════════════════════════════════════════════
    // 12. REAR BUMPER detail
    // ══════════════════════════════════════════════════════════════
    canvas.drawLine(Offset(cx - 50, 488), Offset(cx + 50, 488), detailStroke);
  }

  static void _roundRect(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double w,
    double h,
    double r,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
