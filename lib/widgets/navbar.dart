import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Navbar extends StatefulWidget implements PreferredSizeWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  _NavbarState createState() => _NavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NavbarState extends State<Navbar> {
  List<Map<String, dynamic>> vegetables = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVegetables();
  }

  Future<void> _loadVegetables() async {
    final String url = 'http://127.0.0.1:8000/api/crop-info-list/';
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
    double screenWidth = MediaQuery.of(context).size.width;
    double textSize = screenWidth > 800 ? 16 : 12;

    return AppBar(
      title: const Text('Bluzora'),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavItem(context, 'Home', '/', textSize),
            _buildNavItem(
                context, 'Price Forecast', '/price_forecast', textSize),
            if (screenWidth > 600)
              // เปลี่ยนตรง Historical Price ให้ navigate ไปที่ Home พร้อม arguments
              TextButton(
                onPressed: () {
                  // นำทางกลับไปที่ Home พร้อมส่งค่า scrollToHistoricalPrice ให้ HomePage เลื่อนไปที่ส่วน Historical Price
                  Navigator.pushReplacementNamed(
                    context,
                    '/',
                    arguments: {'scrollToHistoricalPrice': true},
                  );
                },
                child: Text(
                  'Historical Price',
                  style: TextStyle(color: Colors.black, fontSize: textSize),
                ),
              ),
            if (screenWidth > 600)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildNavItem(
                    context, 'Comparison', '/comparison', textSize),
              ),
          ],
        ),
        // ช่องค้นหาแบบ Responsive พร้อม Padding ด้านขวา
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: screenWidth * 0.15,
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return vegetables
                        .map((veg) => veg['name'] as String)
                        .where((name) => name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                        .toList();
                  },
                  onSelected: (String selectedName) {
                    final selectedVegetable = vegetables.firstWhere(
                      (veg) => veg['name'] == selectedName,
                      orElse: () => {},
                    );
                    if (selectedVegetable.isNotEmpty) {
                      // ใช้ pushReplacementNamed เพื่อหลีกเลี่ยงการ stack หน้า
                      Navigator.pushReplacementNamed(
                        context,
                        '/quarterly_avg',
                        arguments: {
                          'vegetable': selectedVegetable,
                          'showAppBar':
                              false, // ส่งค่า false เพื่อไม่ให้แสดง appBar ซ้ำกัน
                        },
                      );
                    }
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    searchController = controller;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, size: 18),
                        hintText: 'ค้นหาผัก...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                      ),
                      style: const TextStyle(fontSize: 14),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        // ปุ่มเปลี่ยนภาษาถูกนำออกแล้ว
      ],
    );
  }

  Widget _buildNavItem(
      BuildContext context, String label, String route, double textSize) {
    return TextButton(
      onPressed: () {
        if (ModalRoute.of(context)?.settings.name == route) {
          return;
        }
        Navigator.pushReplacementNamed(context, route);
      },
      child: Text(
        label,
        style: TextStyle(color: Colors.black, fontSize: textSize),
      ),
    );
  }
}
