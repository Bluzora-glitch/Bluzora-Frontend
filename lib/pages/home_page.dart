import 'package:flutter/material.dart';
import 'vegetable_card_screen.dart';
import 'vegetable_screen.dart';
import 'component_comparison.dart';
import 'component_price_forecast.dart';
import 'component_quarterly_prices.dart';

// import 'carousel_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
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
                // CarouselHeader(), // <-- เรียกใช้ Widget ที่แยกออกไป
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
                                      duration: const Duration(
                                          milliseconds:
                                              500), // ✅ ความเร็วในการเลื่อน
                                      curve: Curves
                                          .easeInOut, // ✅ ความนุ่มนวลของการเลื่อน
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(
                                        0.2), // ✅ พื้นหลังโปร่งใส 20%
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    side: const BorderSide(
                                      color: Colors.white, // ✅ กรอบสีขาว
                                      width: 1.5, // ✅ ความหนาของกรอบ
                                    ),
                                    elevation:
                                        0, // ✅ ไม่มีเงา (ดูโปร่งใสมากขึ้น)
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
// Placeholder สำหรับวิดีโอ
                      // Container(
                      //   width: 400,
                      //   height: 300,
                      //   decoration: BoxDecoration(
                      //     color: Colors.white.withOpacity(0.9),
                      //     borderRadius: BorderRadius.circular(12),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.black26,
                      //         blurRadius: 10,
                      //         offset: Offset(0, 4),
                      //       ),
                      //     ],
                      //   ),
                      //   child: Center(
                      //     child: Icon(
                      //       Icons.play_circle_fill,
                      //       size: 100,
                      //       color: Colors.grey,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

// Content Section

// Price Forecast Section
            Center(
              key: _priceForecastKey, // ✅ ใส่ GlobalKey ตรงนี้
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
                        ? 150.0 // เดสก์ท็อป
                        : MediaQuery.of(context).size.width > 600
                            ? 80.0 // แท็บเล็ต
                            : 16.0, // มือถือ
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

// Price Monitoring Section
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/quarterly_avg');
                },
                splashColor: Colors.green.withOpacity(0.3),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width > 1024
                        ? 150.0 // เดสก์ท็อป
                        : MediaQuery.of(context).size.width > 600
                            ? 80.0 // แท็บเล็ต
                            : 16.0, // มือถือ
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'ราคาเฉลี่ยรายไตรมาส'),
                      const QuarterlyPricesComponent(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

// ผักใหม่ Section
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 1024
                      ? 80.0 // เดสก์ท็อป
                      : MediaQuery.of(context).size.width > 600
                          ? 40.0 // แท็บเล็ต
                          : 8.0, // มือถือ
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ราคาเฉลี่ยรายไตรมาส',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width > 1024
                          ? 320 // เดสก์ท็อป
                          : MediaQuery.of(context).size.width > 600
                              ? 300 // แท็บเล็ต
                              : 280, // มือถือ
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
            // ตารางผัก Section
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width > 1024
                      ? 150.0 // เดสก์ท็อป
                      : MediaQuery.of(context).size.width > 600
                          ? 80.0 // แท็บเล็ต
                          : 16.0, // มือถือ
                  vertical: 5.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height *
                          (MediaQuery.of(context).size.width > 1024
                              ? 0.8 // เดสก์ท็อป
                              : MediaQuery.of(context).size.width > 600
                                  ? 0.7 // แท็บเล็ต
                                  : 0.6), // มือถือ
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
                      child: const VegetableScreen(), // ใส่ VegetableScreen
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

@override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(50.0),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Opacity(
              opacity: 0.75,
              child: Image.asset(
                'assets/quarterly_prices.jpg',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'ติดตามราคาเฉลี่ยรายไตรมาสแบบครบจบในที่เดียว',
                style: TextStyle(
                  fontSize: 20, // ทำให้ตัวใหญ่
                  fontWeight: FontWeight.bold, // ทำให้ตัวหนา
                ),
              ),
              Text(
                'อัปเดตข้อมูลราคาเฉลี่ยผลผลิตรายไตรมาส เพื่อช่วยคุณวางแผนธุรกิจและตัดสินใจได้อย่างมั่นใจ ด้วยข้อมูลเชิงลึกที่แม่นยำและเชื่อถือได้',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
              FeatureList(
                features: [
                  'วิเคราะห์ราคาผลผลิตรายไตรมาส',
                  'แนวโน้มตลาดที่ชัดเจน',
                  'ข้อมูลเพื่อการวางแผนระยะยาว',
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

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
