import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quarterly_avg.dart';
import 'package:flutter/foundation.dart';

class VegetableCardScreen extends StatefulWidget {
  const VegetableCardScreen({super.key});

  @override
  _VegetableCardScreenState createState() => _VegetableCardScreenState();
}

class _VegetableCardScreenState extends State<VegetableCardScreen> {
  List<Map<String, dynamic>> vegetables = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadVegetables();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ฟังก์ชันที่ให้ API Base URL แตกต่างกันระหว่าง development และ production
  String getApiBaseUrl() {
    if (kReleaseMode) {
      // ใน production (Render)
      return 'https://bluzora-backend.onrender.com/api/';
    } else {
      // ใน development (localhost)
      return 'http://127.0.0.1:8000/api/';
    }
  }

  Future<void> _loadVegetables() async {
    final url =
        '${getApiBaseUrl()}crop-info-list/'; // ใช้ String Interpolation ที่นี่
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<Map<String, dynamic>> resultList = [];
        if (jsonData == null) {
          resultList = [];
        } else if (jsonData is List) {
          resultList = List<Map<String, dynamic>>.from(jsonData);
        } else if (jsonData is Map && jsonData.containsKey("results")) {
          resultList = List<Map<String, dynamic>>.from(jsonData["results"]);
        } else {
          resultList = [];
        }
        setState(() {
          vegetables = resultList;
        });
        print("Vegetable data loaded from API: $vegetables");
      } else {
        print('Error loading vegetables: ${response.statusCode}');
        setState(() {
          vegetables = [];
        });
      }
    } catch (e) {
      print('Exception loading vegetables: $e');
      setState(() {
        vegetables = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        bool isMobile = screenWidth < 600;

        return vegetables.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: isMobile ? _buildMobileListView() : _buildDesktopView(),
              );
      },
    );
  }

  Widget _buildDesktopView() {
    double containerWidth = MediaQuery.of(context).size.width * 0.8;
    double containerHeight = 300;

    return Center(
      child: SizedBox(
        width: containerWidth,
        height: containerHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: vegetables.map((vegetable) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildVegetableCard(vegetable),
                  );
                }).toList(),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildCircleButton(
                  icon: Icons.arrow_back_ios,
                  onTap: () {
                    _scrollController.animateTo(
                      _scrollController.offset - 600,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildCircleButton(
                  icon: Icons.arrow_forward_ios,
                  onTap: () {
                    _scrollController.animateTo(
                      _scrollController.offset + 600,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: vegetables.length,
      itemBuilder: (context, index) {
        return _buildVegetableCard(vegetables[index]);
      },
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.7),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildVegetableCard(Map<String, dynamic> vegetable) {
    double screenWidth = MediaQuery.of(context).size.width;

    double cardWidth = screenWidth > 1024
        ? 200
        : screenWidth > 600
            ? 160
            : 120;

    double cardHeight = screenWidth > 1024
        ? 300
        : screenWidth > 600
            ? 260
            : 220;

    double imageHeight = screenWidth > 1024
        ? 150
        : screenWidth > 600
            ? 110
            : 70;

    double verticalMargin = screenWidth > 1024
        ? 8.0
        : screenWidth > 600
            ? 6.0
            : 4.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuarterlyAvgPage(vegetable: vegetable),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: verticalMargin),
        color: Colors.white,
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  // แปลง http → https เผื่อต้องโหลดผ่าน HTTPS เท่านั้น
                  (vegetable['image'] as String? ?? '')
                      .replaceFirst('http:', 'https:'),
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // แสดงตัวชี้วัดระหว่างโหลดภาพ
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  // ถ้าโหลดไม่สำเร็จ fallback เป็น asset เหมือนเดิม
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/vegetables.png',
                      height: imageHeight,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  vegetable["name"] ?? "ไม่ระบุชื่อ",
                  style: TextStyle(
                    fontSize: screenWidth > 600 ? 18.0 : 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6.0),
                Text(
                  vegetable["price"]?.toString() ?? "-",
                  style: TextStyle(fontSize: screenWidth > 600 ? 16.0 : 14.0),
                ),
                const SizedBox(height: 6.0),
                Text(
                  vegetable["change"]?.toString() ?? "-",
                  style: TextStyle(
                    fontSize: screenWidth > 600 ? 14.0 : 12.0,
                    color:
                        (vegetable["status"]?.toString().toLowerCase() == "up")
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
