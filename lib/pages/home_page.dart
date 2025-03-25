import 'package:flutter/material.dart';
import 'vegetable_card_screen.dart';
import 'vegetable_screen.dart';
import 'component_comparison.dart';
import 'component_price_forecast.dart';
import 'component_quarterly_prices.dart';

// import 'carousel_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // ประกาศ GlobalKey สำหรับ New Vegetables Section (ใช้แบบ static ภายใน HomePage)
  static final GlobalKey _newVegetablesKey = GlobalKey();
  static final GlobalKey _priceForecastKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEDF0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Stack(
              children: [
                Image.asset(
                  'assets/background.jpg',
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1,
                    vertical: 80,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ข้อความด้านซ้าย
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'การพยากรณ์ล่วงหน้า\nเพียง 1 เดียว',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'วางแผนอนาคตอย่างมั่นใจด้วยระบบพยากรณ์ราคาผักล่วงหน้า\n'
                              'ที่ช่วยให้คุณก้าวสู่ตลาดพร้อมข้อมูลเชิงลึกแบบเรียลไทม์เพื่อสนับสนุนการตัดสินใจที่ดีที่สุด',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 30),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/price_forecast');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('คำนวณการพยากรณ์'),
                                ),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Scrollable.ensureVisible(
                                      _priceForecastKey.currentContext!,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'รายละเอียดเพิ่มเติม',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 50),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Content Section

            // Price Forecast Section
            Center(
              key: _priceForecastKey,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/price_forecast');
                },
                splashColor: Colors.green.withOpacity(0.3),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width > 1024
                        ? 150.0
                        : MediaQuery.of(context).size.width > 600
                            ? 80.0
                            : 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'พยากรณ์ราคาผัก'),
                      const PriceForecastComponent(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Comparison Section
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/comparison');
                },
                splashColor: Colors.green.withOpacity(0.3),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width > 1024
                        ? 150.0
                        : MediaQuery.of(context).size.width > 600
                            ? 80.0
                            : 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'การเปรียบเทียบ'),
                      const ComparisonComponent(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Price Monitoring Section (แก้ไข: ไม่ navigate แต่เลื่อนไปที่ New Vegetables)
            Center(
              child: InkWell(
                onTap: () {
                  Scrollable.ensureVisible(
                    _newVegetablesKey.currentContext!,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                splashColor: Colors.green.withOpacity(0.3),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width > 1024
                        ? 150.0
                        : MediaQuery.of(context).size.width > 600
                            ? 80.0
                            : 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'ข้อมูลราคาย้อนหลัง'),
                      const QuarterlyPricesComponent(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // New Vegetables Section
            Center(
              key: _newVegetablesKey, // ใช้ GlobalKey ที่ประกาศใน HomePage
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 1024
                      ? 80.0
                      : MediaQuery.of(context).size.width > 600
                          ? 40.0
                          : 8.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ข้อมูลราคาย้อนหลัง',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width > 1024
                          ? 320
                          : MediaQuery.of(context).size.width > 600
                              ? 300
                              : 280,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            VegetableCardScreen(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // ตารางผัก Section
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 1024
                      ? 150.0
                      : MediaQuery.of(context).size.width > 600
                          ? 80.0
                          : 16.0,
                  vertical: 5.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height *
                          (MediaQuery.of(context).size.width > 1024
                              ? 0.8
                              : MediaQuery.of(context).size.width > 600
                                  ? 0.7
                                  : 0.6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const VegetableScreen(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// หมดการประกาศ GlobalKey ที่ซ้ำออกแล้ว (ใช้ _newVegetablesKey ที่ประกาศใน HomePage เท่านั้น)

// ตรวจสอบให้แน่ใจว่าไม่มีการประกาศ SectionHeader และ FeatureList ซ้ำในไฟล์นี้
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class FeatureList extends StatelessWidget {
  final List<String> features;
  const FeatureList({required this.features});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: features
            .map((feature) => Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
