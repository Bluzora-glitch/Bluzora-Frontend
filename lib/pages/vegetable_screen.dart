import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'quarterly_avg.dart';

class VegetableScreen extends StatefulWidget {
  const VegetableScreen({Key? key}) : super(key: key);

  @override
  _VegetableScreenState createState() => _VegetableScreenState();
}

class _VegetableScreenState extends State<VegetableScreen> {
  List<Map<String, dynamic>> vegetables = [];
  List<Map<String, dynamic>> filteredVegetables = [];
  TextEditingController searchController = TextEditingController();
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadVegetables();
  }

  Future<void> _loadVegetables() async {
    final String response =
        await rootBundle.loadString('assets/vegetables.json');
    final List<dynamic> data = jsonDecode(response);
    setState(() {
      vegetables = List<Map<String, dynamic>>.from(data);
      filteredVegetables = vegetables;
    });
  }

  void _filterVegetables() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredVegetables = vegetables.where((veg) {
        final name = veg['name'].toLowerCase();
        final status = veg['status'];

        bool matchesQuery = name.contains(query);
        bool matchesStatus = selectedStatus == null || status == selectedStatus;

        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile
              ? 16.0
              : isTablet
                  ? 30.0
                  : 50.20,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: isMobile ? 3 : 2,
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => _filterVegetables(),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'ค้นหา',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isMobile ? 8 : 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Dropdown สำหรับเลือกสถานะราคาขึ้น/ลง
                Expanded(
                  flex: isMobile ? 2 : 1,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isMobile ? 8 : 12,
                        horizontal: 10,
                      ),
                    ),
                    hint: const Text('สถานะ'),
                    value: selectedStatus,
                    items: const [
                      DropdownMenuItem(value: 'up', child: Text('ราคาขึ้น')),
                      DropdownMenuItem(value: 'down', child: Text('ราคาลง')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                        _filterVegetables();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  // Header Row
                  Container(
                    color: Colors.grey[200],
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile
                            ? 10
                            : isTablet
                                ? 20
                                : 30),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'PRODUCT',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'PRICE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'หน่วย',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'ราคาเฉลี่ย',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'ดูข้อมูลย้อนหลัง',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero, // ✅ เอา Padding ออก
                      itemCount: filteredVegetables.length,
                      itemBuilder: (context, index) {
                        final vegetable = filteredVegetables[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal:
                                0, // ✅ ลด Padding ซ้ายขวาให้เท่ากับ Header
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 10 : 20, // ✅ ปรับให้เล็กลง
                              vertical: isMobile ? 5 : 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    vegetable['name'],
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    vegetable['price'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    vegetable['unit'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '"${vegetable['dailyPrices'].last['price']}" บาท/หน่วย',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: vegetable['status'] == 'up'
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    height:
                                        isMobile ? 30 : 40, // ลดความสูงบนมือถือ
                                    width: isMobile
                                        ? 80
                                        : 100, // ลดความกว้างบนมือถือ
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical:
                                              isMobile ? 4 : 8, // ลด Padding
                                          horizontal: isMobile ? 6 : 12,
                                        ),
                                        textStyle: TextStyle(
                                          fontSize:
                                              isMobile ? 12 : 14, // ลดขนาดฟอนต์
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                QuarterlyAvgPage(
                                                    vegetable: vegetable),
                                          ),
                                        );
                                      },
                                      child: const Text('ดูข้อมูล'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
