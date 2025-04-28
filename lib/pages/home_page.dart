import 'package:flutter/material.dart';
import 'vegetable_card_screen.dart';
import 'vegetable_screen.dart';
import 'component_comparison.dart';
import 'component_price_forecast.dart';
import 'component_quarterly_prices.dart';

class HomePage extends StatefulWidget {
  final bool scrollToHistoricalPrice;
  const HomePage({Key? key, this.scrollToHistoricalPrice = false})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _newVegetablesKey = GlobalKey();
  final GlobalKey _priceForecastKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.scrollToHistoricalPrice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_newVegetablesKey.currentContext != null) {
          Scrollable.ensureVisible(
            _newVegetablesKey.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Breakpoints
    final bool isDesktop = width >= 1024;
    final bool isTablet = width >= 600 && width < 1024;

    // Header height
    final double headerHeight = height *
        (isDesktop
            ? 0.6
            : isTablet
                ? 0.5
                : 0.4);

    // Padding values
    final double headerHPadding = isDesktop || isTablet ? width * 0.1 : 16;
    final double sectionHPadding = isDesktop
        ? 150
        : isTablet
            ? 80
            : 16;
    final double newVegHPadding = isDesktop
        ? 80
        : isTablet
            ? 40
            : 8;

    // Font sizes
    final double titleFontSize = isDesktop
        ? 36
        : isTablet
            ? 32
            : 24;
    final double bodyFontSize = isDesktop || isTablet ? 16 : 14;
    final double sectionHeaderSize = isDesktop
        ? 25
        : isTablet
            ? 22
            : 20;

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
                  height: headerHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: headerHPadding,
                    vertical: 80,
                  ),
                  child: Row(
                    children: [
                      // Left text
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'การพยากรณ์ล่วงหน้า\nเพียง 1 เดียว',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'วางแผนอนาคตอย่างมั่นใจด้วยระบบพยากรณ์ '
                              'ที่ช่วยให้คุณก้าวสู่ตลาดพร้อมข้อมูลเชิงลึกแบบเรียลไทม์',
                              style: TextStyle(
                                fontSize: bodyFontSize,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/price_forecast'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                  child: const Text('คำนวณการพยากรณ์'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_priceForecastKey.currentContext !=
                                        null) {
                                      Scrollable.ensureVisible(
                                        _priceForecastKey.currentContext!,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    side: const BorderSide(
                                        color: Colors.white, width: 1.5),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
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
                      if (isDesktop) const SizedBox(width: 50),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price Forecast Section
            Center(
              key: _priceForecastKey,
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/price_forecast'),
                splashColor: Colors.green.withOpacity(0.3),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sectionHPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'พยากรณ์ราคาผัก',
                        fontSize: sectionHeaderSize,
                      ),
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
                onTap: () => Navigator.pushNamed(context, '/comparison'),
                splashColor: Colors.green.withOpacity(0.3),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sectionHPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'การเปรียบเทียบ',
                        fontSize: sectionHeaderSize,
                      ),
                      const ComparisonComponent(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Quarterly Prices Section
            Center(
              child: InkWell(
                onTap: () {
                  if (_newVegetablesKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      _newVegetablesKey.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                splashColor: Colors.green.withOpacity(0.3),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sectionHPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'ข้อมูลราคาย้อนหลัง',
                        fontSize: sectionHeaderSize,
                      ),
                      const QuarterlyPricesComponent(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // New Vegetables Section
            Center(
              key: _newVegetablesKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: newVegHPadding,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ข้อมูลราคาย้อนหลัง',
                      style: TextStyle(
                        fontSize: sectionHeaderSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: isDesktop
                          ? 320
                          : isTablet
                              ? 300
                              : 280,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: const [VegetableCardScreen()]),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // Vegetable Table Section
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sectionHPadding,
                  vertical: 5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: height *
                          (isDesktop
                              ? 0.8
                              : isTablet
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

// Reusable section header
class SectionHeader extends StatelessWidget {
  final String title;
  final double fontSize;
  const SectionHeader({required this.title, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      ),
    );
  }
}
