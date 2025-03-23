import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // ใช้ http แทน rootBundle
import 'quarterly_avg.dart';

class VegetableCardScreen extends StatefulWidget {
  const VegetableCardScreen({super.key});

  @override
  _VegetableCardScreenState createState() => _VegetableCardScreenState();
}

class _VegetableCardScreenState extends State<VegetableCardScreen> {
  List<Map<String, dynamic>> vegetables = [];

  @override
  void initState() {
    super.initState();
    _loadVegetables();
  }

  Future<void> _loadVegetables() async {
    // เปลี่ยน URL ให้ตรงกับ Django API endpoint ที่ส่งข้อมูลผัก
    const url = 'http://127.0.0.1:8000/api/crop-info-list/';
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
                child: isMobile
                    ? _buildMobileListView()
                    : _buildDesktopScrollableRow(),
              );
      },
    );
  }

  /// สำหรับเดสก์ท็อป: แสดงเป็นแนวนอนเลื่อน
  Widget _buildDesktopScrollableRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: vegetables.map((vegetable) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildVegetableCard(vegetable),
          );
        }).toList(),
      ),
    );
  }

  /// สำหรับมือถือ: แสดงเป็นรายการแนวตั้ง
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

  /// สร้างการ์ดสำหรับแต่ละรายการผัก
  Widget _buildVegetableCard(Map<String, dynamic> vegetable) {
    double screenWidth = MediaQuery.of(context).size.width;

    // ปรับขนาดการ์ดตามขนาดหน้าจอ
    double cardWidth = screenWidth > 1024
        ? 200 // เดสก์ท็อป
        : screenWidth > 600
            ? 160 // แท็บเล็ต
            : 120; // มือถือ

    double cardHeight = screenWidth > 1024
        ? 300 // เดสก์ท็อป
        : screenWidth > 600
            ? 260 // แท็บเล็ต
            : 220; // มือถือ

    double imageHeight = screenWidth > 1024
        ? 150 // เดสก์ท็อป
        : screenWidth > 600
            ? 110 // แท็บเล็ต
            : 70; // มือถือ

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
                // แสดงรูปจาก asset โดยคาดหวังว่าค่า key 'image' มี path ของ asset รูปภาพ
                Image.network(
                  vegetable['image'] ??
                      'http://127.0.0.1:8000/assets/default.jpg',
                  height: imageHeight,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                const SizedBox(height: 8),
                Text(
                  vegetable["name"] ?? "ไม่ระบุชื่อ",
                  style: TextStyle(
                    fontSize: screenWidth > 600 ? 18.0 : 16.0,
                    fontWeight: FontWeight.bold,
                  ),
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
                    color: Colors.green,
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
