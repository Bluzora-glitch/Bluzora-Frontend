import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
// ignore: unused_import
import '/pages/quarterly_avg.dart';

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
    final String response =
        await rootBundle.loadString('assets/vegetables.json');
    final List<dynamic> data = jsonDecode(response);
    setState(() {
      vegetables = List<Map<String, dynamic>>.from(data);
    });
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
              _buildNavItem(
                  context, 'Quarterly Average', '/quarterly_avg', textSize),

            // ✅ จัดให้ Comparison อยู่ใกล้ช่องค้นหามากขึ้น
            if (screenWidth > 600)
              Padding(
                padding: const EdgeInsets.only(right: 8.0), // ขยับให้ชิดขึ้น
                child: _buildNavItem(
                    context, 'Comparison', '/comparison', textSize),
              ),
          ],
        ),

        // ✅ ช่องค้นหาแบบ Responsive
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: screenWidth * 0.15, // ✅ ปรับให้เล็กลง
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
                      orElse: () => {});
                  if (selectedVegetable.isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      '/quarterly_avg',
                      arguments:
                          selectedVegetable, // ✅ ส่งข้อมูลไปที่หน้า QuarterlyAvgPage
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
                    style:
                        const TextStyle(fontSize: 14), // ✅ ทำให้ตัวอักษรเล็กลง
                  );
                },
              ),
            ),
          ),
        ),

        TextButton(
          onPressed: () {},
          child: Text('TH/EN',
              style: TextStyle(color: Colors.black, fontSize: textSize)),
        ),
      ],
    );
  }

  Widget _buildNavItem(
      BuildContext context, String label, String route, double textSize) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, route);
      },
      child: Text(label,
          style: TextStyle(color: Colors.black, fontSize: textSize)),
    );
  }
}
