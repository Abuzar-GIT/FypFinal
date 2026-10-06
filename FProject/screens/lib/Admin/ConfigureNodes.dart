import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:screens/Api/AdminApi.dart';
import 'package:screens/Model/NodeConfigModel.dart';
import 'package:screens/Myscreen/Log_in.dart';

class ConfigureNodes extends StatefulWidget {
  final dynamic categoryId;
  final String carName;
  final String carType;

  const ConfigureNodes({
    super.key,
    required this.categoryId,
    required this.carName,
    required this.carType,
  });

  @override
  State<ConfigureNodes> createState() => _ConfigureNodesState();
}

class _ConfigureNodesState extends State<ConfigureNodes> {
  final TextEditingController _weightController = TextEditingController();
  final TransformationController _transformationController =
      TransformationController();
  final ScrollController _listScrollController = ScrollController();
  final GlobalKey _wireframeKey = GlobalKey();

  List<SensorNodeConfig> _nodes = [];
  SensorNodeConfig? _selectedNode;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDragMode = false;
  int? _draggingNodeId;

  // Controllers for each node's force input
  final Map<int, TextEditingController> _forceControllers = {};

  // Custom key to individual node cards for precise scrolling
  final Map<int, GlobalKey> _nodeCardKeys = {};

  double _currentScale = 1.0;

  int get parsedCategoryId {
    if (widget.categoryId is int) return widget.categoryId as int;
    return int.tryParse(widget.categoryId.toString()) ?? 1;
  }

  String get normalizedCarType {
    final t = widget.carType.trim().toLowerCase();
    if (t.contains("suv")) return "suv";
    if (t.contains("hatchback")) return "hatchback";
    return "sedan";
  }

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
    _fetchData();
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _weightController.dispose();
    _listScrollController.dispose();
    for (final controller in _forceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.01) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  // ============================================================
  // FETCH DATA
  // ============================================================
  /* Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final data = await AdminApi.getNodes(parsedCategoryId);
      final rawNodes = (data["Nodes"] ?? data["nodes"] ?? []) as List<dynamic>;

      final count = getNodeCountByCarType(normalizedCarType);
      final typeMaster =
          masterNodesData[normalizedCarType] ?? masterNodesData["sedan"]!;

      final List<SensorNodeConfig> loadedNodes = [];

      for (int i = 1; i <= count; i++) {
        final found = rawNodes.firstWhere(
          (n) => (n["Node_Id"] ?? n["node_Id"]) == i,
          orElse: () => null,
        );

        final preset =
            typeMaster[i] ??
            NodePositionPreset(
              name: "Node $i",
             // force: "Force $i",
              left: 50.0,
              top: 50.0,
            );

        final String forceValue = found != null
            ? (found["Force"] ?? found["force"] ?? preset.force).toString()
            : preset.force;

        // Reuse or create text controller
        if (_forceControllers.containsKey(i)) {
          _forceControllers[i]!.text = forceValue;
        } else {
          _forceControllers[i] = TextEditingController(text: forceValue);
        }

        _nodeCardKeys.putIfAbsent(i, () => GlobalKey());

        loadedNodes.add(
          SensorNodeConfig(
            id: i,
            name: preset.name,
            force: forceValue,
            left: preset.left,
            top: preset.top,
            categoryId: parsedCategoryId,
          ),
        );
      }

      setState(() {
        _nodes = loadedNodes;
        _weightController.text = (data["Weight"] ?? data["weight"] ?? "")
            .toString();
      });
    } catch (err) {
      // If API fails, populate with master dump presets so UI is fully usable
      final count = getNodeCountByCarType(normalizedCarType);
      final typeMaster =
          masterNodesData[normalizedCarType] ?? masterNodesData["sedan"]!;

      final List<SensorNodeConfig> fallbackNodes = [];
      for (int i = 1; i <= count; i++) {
        final preset =
            typeMaster[i] ??
            NodePositionPreset(
              name: "Node $i",
              force: "2.00",
              left: 50.0,
              top: 50.0,
            );

        if (!_forceControllers.containsKey(i)) {
          _forceControllers[i] = TextEditingController(text: preset.force);
        }
        _nodeCardKeys.putIfAbsent(i, () => GlobalKey());

        fallbackNodes.add(
          SensorNodeConfig(
            id: i,
            name: preset.name,
            force: preset.force,
            left: preset.left,
            top: preset.top,
            categoryId: parsedCategoryId,
          ),
        );
      }

      setState(() {
        _nodes = fallbackNodes;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Loaded local preset configuration: $err"),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
*/
  // ============================================================
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final data = await AdminApi.getNodes(parsedCategoryId);

      final rawNodes = (data["Nodes"] ?? data["nodes"] ?? []) as List<dynamic>;

      final count = getNodeCountByCarType(normalizedCarType);

      final typeMaster =
          masterNodesData[normalizedCarType] ?? masterNodesData["sedan"]!;

      final List<SensorNodeConfig> loadedNodes = [];

      for (int i = 1; i <= count; i++) {
        // ---------------------------------------------------------
        // Find node returned by DATABASE
        // ---------------------------------------------------------

        Map<String, dynamic>? found;

        for (final item in rawNodes) {
          if (item is Map<String, dynamic>) {
            final nodeId =
                item["Node_Id"] ??
                item["node_Id"] ??
                item["NodeID"] ??
                item["nodeID"] ??
                item["id"];

            if (nodeId is num && nodeId.toInt() == i) {
              found = item;
              break;
            }

            if (nodeId != null && nodeId.toString() == i.toString()) {
              found = item;
              break;
            }
          }
        }

        // ---------------------------------------------------------
        // Position/name comes from NodePositionPreset
        // Force DOES NOT come from NodePositionPreset
        // ---------------------------------------------------------

        final preset =
            typeMaster[i] ??
            NodePositionPreset(name: "Node $i", left: 50.0, top: 50.0);

        // ---------------------------------------------------------
        // FORCE MUST COME FROM DATABASE
        // ---------------------------------------------------------

        String forceValue = "0";

        if (found != null) {
          final dbForce = found["Force"] ?? found["force"] ?? found["FORCE"];

          if (dbForce != null) {
            forceValue = dbForce.toString();
          }
        }

        // ---------------------------------------------------------
        // Reuse or create force text controller
        // ---------------------------------------------------------

        if (_forceControllers.containsKey(i)) {
          _forceControllers[i]!.text = forceValue;
        } else {
          _forceControllers[i] = TextEditingController(text: forceValue);
        }

        // ---------------------------------------------------------
        // Node card key
        // ---------------------------------------------------------

        _nodeCardKeys.putIfAbsent(i, () => GlobalKey());

        // ---------------------------------------------------------
        // Create SensorNodeConfig
        // ---------------------------------------------------------

        loadedNodes.add(
          SensorNodeConfig(
            id: i,

            // Name comes from preset
            name: preset.name,

            // FORCE COMES FROM DATABASE
            force: forceValue,

            // Position comes from preset
            left: preset.left,
            top: preset.top,

            categoryId: parsedCategoryId,
          ),
        );
      }

      // -----------------------------------------------------------
      // Update UI
      // -----------------------------------------------------------

      if (mounted) {
        setState(() {
          _nodes = loadedNodes;

          _weightController.text = (data["Weight"] ?? data["weight"] ?? "")
              .toString();
        });
      }
    } catch (err) {
      // -----------------------------------------------------------
      // DATABASE/API failed
      //
      // We can still show the node positions so the UI doesn't
      // crash, but we DO NOT create fake force values.
      // -----------------------------------------------------------

      final count = getNodeCountByCarType(normalizedCarType);

      final typeMaster =
          masterNodesData[normalizedCarType] ?? masterNodesData["sedan"]!;

      final List<SensorNodeConfig> fallbackNodes = [];

      for (int i = 1; i <= count; i++) {
        final preset =
            typeMaster[i] ??
            NodePositionPreset(name: "Node $i", left: 50.0, top: 50.0);

        // ---------------------------------------------------------
        // No database available = no force available.
        // Do NOT use preset.force.
        // ---------------------------------------------------------

        const String forceValue = "0";

        if (!_forceControllers.containsKey(i)) {
          _forceControllers[i] = TextEditingController(text: forceValue);
        } else {
          _forceControllers[i]!.text = forceValue;
        }

        _nodeCardKeys.putIfAbsent(i, () => GlobalKey());

        fallbackNodes.add(
          SensorNodeConfig(
            id: i,
            name: preset.name,

            // No fake/hard-coded force
            force: forceValue,

            left: preset.left,
            top: preset.top,

            categoryId: parsedCategoryId,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _nodes = fallbackNodes;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Could not load node force values from database: $err",
            ),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // SAVE CONFIGURATION
  // ============================================================
  Future<void> _saveConfiguration() async {
    final weight = _weightController.text.trim();
    if (weight.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter vehicle weight"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final payload = _nodes.map((n) {
      final currentForce = _forceControllers[n.id]?.text.trim() ?? n.force;
      return {
        "Node_Id": n.id,
        "Category_Id": parsedCategoryId,
        "Node_Position": n.name,
        "Force": double.tryParse(currentForce) ?? 0.0,
      };
    }).toList();

    try {
      final res = await AdminApi.saveConfiguration(
        categoryId: parsedCategoryId,
        weight: weight,
        payload: payload,
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Configuration saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        _fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save configuration: ${res.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Network error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ============================================================
  // ZOOM HELPERS
  // ============================================================
  void _zoomIn() {
    final currentMatrix = _transformationController.value;
    _transformationController.value =
        currentMatrix * Matrix4.diagonal3Values(1.15, 1.15, 1.0);
  }

  void _zoomOut() {
    final currentMatrix = _transformationController.value;
    _transformationController.value =
        currentMatrix * Matrix4.diagonal3Values(0.85, 0.85, 1.0);
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    setState(() {
      _currentScale = 1.0;
    });
  }

  // ============================================================
  // POSITION & DRAG HELPERS
  // ============================================================
  void _updateNodePosition(Offset localPosition, Size boxSize) {
    if (_draggingNodeId == null || boxSize.width == 0 || boxSize.height == 0) {
      return;
    }

    double leftPercent = (localPosition.dx / boxSize.width) * 100.0;
    double topPercent = (localPosition.dy / boxSize.height) * 100.0;

    leftPercent = leftPercent.clamp(0.0, 100.0);
    topPercent = topPercent.clamp(0.0, 100.0);

    setState(() {
      final index = _nodes.indexWhere((n) => n.id == _draggingNodeId);
      if (index != -1) {
        _nodes[index].left = double.parse(leftPercent.toStringAsFixed(2));
        _nodes[index].top = double.parse(topPercent.toStringAsFixed(2));
      }
    });
  }

  void _logCoordinates() {
    final Map<int, Map<String, double>> coords = {};
    for (var n in _nodes) {
      coords[n.id] = {"top": n.top, "left": n.left};
    }
    debugPrint(
      "COORDINATES_FOR_${normalizedCarType.toUpperCase()}: ${jsonEncode(coords)}",
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Coordinates for ${normalizedCarType.toUpperCase()} logged to console!",
        ),
        backgroundColor: const Color(0xFF9A3412),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _scrollToNodeCard(int id) {
    final targetContext = _nodeCardKeys[id]?.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    } else {
      final index = _nodes.indexWhere((n) => n.id == id);
      if (index != -1) {
        _listScrollController.animateTo(
          index * 85.0 + 80.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Widget _getVehicleImage() {
    String assetPath;
    if (normalizedCarType == "suv" || parsedCategoryId == 2) {
      assetPath = "assets/images/Suv.png";
    } else if (normalizedCarType == "hatchback" || parsedCategoryId == 3) {
      assetPath = "assets/images/Hatchback.png";
    } else {
      assetPath = "assets/images/wireframe.png";
    }

    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 4),
              Text(
                "${widget.carName} Wireframe ($assetPath)",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            _buildCarHeader(),
            _buildWireframeSection(),
            Expanded(child: _buildScrollableNodesSection()),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP APP BAR (HEADER)
  // ============================================================
  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B00),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "A",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Admin Dashboard",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    "Configure Sensors",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LogIn()),
                (route) => false,
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(Icons.logout, color: Colors.red, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CAR SUB-HEADER
  // ============================================================
  Widget _buildCarHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.arrow_back, size: 20, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.carName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${normalizedCarType.toUpperCase()} (${_nodes.length} Nodes)",
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: (_isLoading || _isSaving) ? null : _saveConfiguration,
            child: _isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Save",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIXED WIREFRAME SECTION
  // ============================================================
  Widget _buildWireframeSection() {
    final bool canReset =
        (_currentScale - 1.0).abs() > 0.05 ||
        _transformationController.value.row0.w != 0 ||
        _transformationController.value.row1.w != 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header of Wireframe card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Car Wireframe",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Row(
                children: [
                  // Zoom controls
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 1,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _zoomIn,
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.zoom_in,
                              size: 16,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            "${(_currentScale * 100).round()}%",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _zoomOut,
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.zoom_out,
                              size: 16,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        if (canReset)
                          InkWell(
                            onTap: _resetZoom,
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.restore,
                                size: 16,
                                color: Color(0xFFFF3B00),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Adjust Mode Toggle Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isDragMode
                          ? const Color(0xFFFF3B00)
                          : const Color(0xFFE5E7EB),
                      foregroundColor: _isDragMode
                          ? Colors.white
                          : const Color(0xFF374151),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      elevation: 0,
                      minimumSize: const Size(64, 28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.open_with, size: 13),
                    label: Text(
                      _isDragMode ? "Done" : "Adjust",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isDragMode = !_isDragMode;
                        _draggingNodeId = null;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Wireframe Viewport
          ClipRect(
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(50),
                minScale: 0.8,
                maxScale: 2.8,
                panEnabled: !_isDragMode,
                scaleEnabled: !_isDragMode,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: normalizedCarType == "hatchback" ? 0.72 : 0.62,
                    child: LayoutBuilder(
                      key: _wireframeKey,
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final height = constraints.maxHeight;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(child: _getVehicleImage()),

                            // SENSOR NODES OVERLAY
                            ..._nodes.map((node) {
                              final isSelected = _selectedNode?.id == node.id;
                              final isBeingDragged = _draggingNodeId == node.id;

                              final double posX = (node.left / 100.0) * width;
                              final double posY = (node.top / 100.0) * height;

                              return Positioned(
                                left: posX - 6.5,
                                top: posY - 9,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onPanStart: _isDragMode
                                      ? (details) {
                                          setState(
                                            () => _draggingNodeId = node.id,
                                          );
                                        }
                                      : null,
                                  onPanUpdate: _isDragMode
                                      ? (details) {
                                          final renderBox =
                                              _wireframeKey.currentContext
                                                      ?.findRenderObject()
                                                  as RenderBox?;
                                          if (renderBox != null) {
                                            final localPos = renderBox
                                                .globalToLocal(
                                                  details.globalPosition,
                                                );
                                            _updateNodePosition(
                                              localPos,
                                              Size(width, height),
                                            );
                                          }
                                        }
                                      : null,
                                  onPanEnd: _isDragMode
                                      ? (_) {
                                          setState(
                                            () => _draggingNodeId = null,
                                          );
                                        }
                                      : null,
                                  onTap: () {
                                    if (!_isDragMode) {
                                      setState(() => _selectedNode = node);
                                      _scrollToNodeCard(node.id);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: isBeingDragged ? 34 : 20,
                                    height: isBeingDragged ? 34 : 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isBeingDragged
                                          ? const Color(0xFF0070F3)
                                          : _isDragMode
                                          ? const Color(
                                              0xFFFF3B00,
                                            ).withValues(alpha: 0.90)
                                          : isSelected
                                          ? const Color(
                                              0xFF0070F3,
                                            ).withValues(alpha: 0.35)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isBeingDragged
                                            ? Colors.white
                                            : _isDragMode
                                            ? Colors.white
                                            : isSelected
                                            ? const Color.fromARGB(
                                                255,
                                                243,
                                                16,
                                                0,
                                              )
                                            : Colors.transparent,
                                        width: (isSelected || _isDragMode)
                                            ? 2
                                            : 1,
                                      ),
                                      boxShadow: (_isDragMode || isSelected)
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.25,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: _isDragMode
                                        ? Text(
                                            "${node.id}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Adjust Mode Help Banner
          if (_isDragMode)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "💡 Adjusting positions (${_nodes.length} Nodes).",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9A3412),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      minimumSize: const Size(40, 22),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: _logCoordinates,
                    child: const Text(
                      "Log Coordinates",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SCROLLABLE CONFIGURATIONS SECTION
  // ============================================================
  Widget _buildScrollableNodesSection() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFF3B00)),
            SizedBox(height: 10),
            Text(
              "Loading configurations...",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView(
      controller: _listScrollController,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 40),
      children: [
        // VEHICLE WEIGHT CARD
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Vehicle Weight",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 38,
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF3B00),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Ton",
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // SENSOR NODES CARD
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Configure Sensor Nodes (${_nodes.length})",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _nodes.length,
                itemBuilder: (context, index) {
                  final node = _nodes[index];
                  final isSelected = _selectedNode?.id == node.id;

                  return GestureDetector(
                    key: _nodeCardKeys[node.id],
                    onTap: () {
                      setState(() => _selectedNode = node);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFF5F2)
                            : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF3B00)
                              : const Color(0xFFE5E7EB),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // NODE HEADER
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF3B00),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${node.id}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Text(
                                    node.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // FORCE INPUT ROW
                          Row(
                            children: [
                              const Text(
                                "Force: ",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF555555),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 90,
                                height: 34,
                                child: TextField(
                                  controller: _forceControllers[node.id],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 8,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD1D5DB),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFFF3B00),
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    node.force = val;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "N",
                                style: TextStyle(
                                  color: Color(0xFF555555),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
