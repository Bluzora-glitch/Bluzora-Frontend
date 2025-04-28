import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

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

// เพิ่มฟังก์ชัน getApiBaseUrl() ตรงนี้
  String getApiBaseUrl() {
    if (kReleaseMode) {
      return 'https://bluzora-backend.onrender.com/api/';
    } else {
      return 'http://127.0.0.1:8000/api/';
    }
  }

  Future<void> _loadVegetables() async {
    final url = '${getApiBaseUrl()}crop-info-list/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<Map<String, dynamic>> resultList = [];
        if (jsonData is List) {
          resultList = List<Map<String, dynamic>>.from(jsonData);
        } else if (jsonData is Map && jsonData.containsKey("results")) {
          resultList = List<Map<String, dynamic>>.from(jsonData["results"]);
        }
        setState(() => vegetables = resultList);
      } else {
        setState(() => vegetables = []);
      }
    } catch (e) {
      setState(() => vegetables = []);
    }
  }

  void _openDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Drawer',
      pageBuilder: (_, __, ___) {
        // สร้าง controller ใหม่สำหรับ drawer
        final TextEditingController drawerController = TextEditingController();

        return Align(
          alignment: Alignment.centerLeft,
          child: SafeArea(
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Material(
                  color: Colors.white,
                  child: Container(
                    width: 270,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search field
                        TextField(
                          controller: drawerController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'ค้นหาผัก...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setStateDialog(() {}); // Refresh เฉพาะใน dialog
                          },
                        ),
                        const SizedBox(height: 10),

                        // Search suggestions
                        if (drawerController.text.isNotEmpty)
                          Expanded(
                            child: ListView(
                              children: vegetables
                                  .map((v) => v['name'] as String)
                                  .where((name) => name.toLowerCase().contains(
                                      drawerController.text.toLowerCase()))
                                  .map((name) => ListTile(
                                        title: Text(name),
                                        onTap: () {
                                          final veg = vegetables.firstWhere(
                                            (v) => v['name'] == name,
                                            orElse: () => {},
                                          );
                                          if (veg.isNotEmpty) {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              '/quarterly_avg',
                                              arguments: {
                                                'vegetable': veg,
                                                'showAppBar': false,
                                              },
                                            );
                                          }
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),

                        const Divider(),

                        // Navigation items (เหมือนเดิม)
                        ListTile(
                          leading: const Icon(Icons.home),
                          title: const Text('Home'),
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.show_chart),
                          title: const Text('Price Forecast'),
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/price_forecast');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.history),
                          title: const Text('Historical Price'),
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/',
                              arguments: {'scrollToHistoricalPrice': true},
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.compare),
                          title: const Text('Comparison'),
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, '/comparison');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
              .animate(anim),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildNavItem(
      BuildContext context, String label, String route, double textSize) {
    return TextButton(
      onPressed: () {
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Text(label,
          style: TextStyle(color: Colors.black, fontSize: textSize)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textSize = screenWidth > 800 ? 16.0 : 12.0;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: _openDrawer,
      ),
      title: const Text('Bluzora', style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      actions: [
        // ---- ปุ่มนำทาง ----
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavItem(context, 'Home', '/', textSize),
            _buildNavItem(
                context, 'Price Forecast', '/price_forecast', textSize),
            if (screenWidth > 600)
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/',
                      arguments: {'scrollToHistoricalPrice': true});
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

        // ---- แถบค้นหา (Autocomplete) โผล่ที่มุมขวา ----
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: SizedBox(
            width: screenWidth * 0.15, // ปรับขนาดตามต้องการ
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return vegetables.map((veg) => veg['name'] as String).where(
                    (name) => name
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selectedName) {
                final veg = vegetables.firstWhere(
                  (v) => v['name'] == selectedName,
                  orElse: () => {},
                );
                if (veg.isNotEmpty) {
                  Navigator.pushReplacementNamed(
                    context,
                    '/quarterly_avg',
                    arguments: {
                      'vegetable': veg,
                      'showAppBar': false,
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
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  style: const TextStyle(fontSize: 14),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
