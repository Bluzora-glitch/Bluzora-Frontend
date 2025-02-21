import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'quarterly_avg.dart';

class VegetableCardScreen extends StatefulWidget {
  const VegetableCardScreen({Key? key}) : super(key: key);

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
    final String response =
        await rootBundle.loadString('assets/vegetables.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      vegetables = List<Map<String, dynamic>>.from(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        bool isMobile = screenWidth < 600; // ตรวจสอบว่าหน้าจอเล็กกว่าหรือไม่

        return vegetables.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: isMobile
                    ? _buildMobileListView()
                    : _buildDesktopScrollableRow(), // ใช้แบบเลื่อนแนวนอนแทน GridView
              );
      },
    );
  }

  /// สำหรับเดสก์ท็อป: แสดงเป็นแนวนอนเลื่อน
  Widget _buildDesktopScrollableRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // ให้เลื่อนแนวนอนได้
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
      physics: const ClampingScrollPhysics(), // ป้องกันการล็อค Scroll
      itemCount: vegetables.length,
      itemBuilder: (context, index) {
        return _buildVegetableCard(vegetables[index]);
      },
    );
  }

  /// วิดเจ็ตสร้างการ์ดของแต่ละรายการ
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

    // ✅ ปรับความห่างของขอบบนและล่าง
    double verticalMargin = screenWidth > 1024
        ? 8.0 // เดสก์ท็อป
        : screenWidth > 600
            ? 6.0 // แท็บเล็ต
            : 4.0; // มือถือ

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
        margin: EdgeInsets.symmetric(
            vertical: verticalMargin), // ✅ ใช้ตัวแปรที่ปรับขนาด
        color: Colors.white,
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  vegetable['image']!,
                  height: imageHeight,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                const SizedBox(height: 8),
                Text(
                  vegetable["name"],
                  style: TextStyle(
                    fontSize: screenWidth > 600
                        ? 18.0
                        : 16.0, // ลดขนาดฟอนต์ลงในมือถือ
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  vegetable["price"],
                  style: TextStyle(fontSize: screenWidth > 600 ? 16.0 : 14.0),
                ),
                const SizedBox(height: 6.0),
                Text(
                  vegetable["change"],
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
