import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/price_forecast.dart';
import 'pages/quarterly_avg.dart';
import 'pages/comparison_page.dart';
import 'widgets/navbar.dart';
import 'widgets/footer.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

Future<List<dynamic>> loadVegetableData() async {
  final String response = await rootBundle.loadString('assets/vegetables.json');
  return json.decode(response);
}

void main() {
  runApp(const BluzoraApp());
}

class BluzoraApp extends StatelessWidget {
  const BluzoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bluzora',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/', // ตั้งค่าเส้นทางเริ่มต้น
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            // ตรวจสอบ arguments ว่ามี key scrollToHistoricalPrice หรือไม่
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final scrollToHistoricalPrice =
                args['scrollToHistoricalPrice'] ?? false;
            return MaterialPageRoute(
              builder: (context) => MainLayout(
                child:
                    HomePage(scrollToHistoricalPrice: scrollToHistoricalPrice),
              ),
            );
          case '/price_forecast':
            return MaterialPageRoute(
              builder: (context) =>
                  MainLayout(child: const PriceForecastPage()),
            );
          case '/quarterly_avg':
            final args = settings.arguments as Map<String, dynamic>;
            // ปรับให้รองรับข้อมูลเดิม
            final vegetable =
                args.containsKey('vegetable') ? args['vegetable'] : args;
            final showAppBar =
                args.containsKey('showAppBar') ? args['showAppBar'] : true;
            return MaterialPageRoute(
              builder: (context) => MainLayout(
                child: QuarterlyAvgPage(
                  vegetable: vegetable,
                  showAppBar: showAppBar,
                ),
              ),
            );
          case '/comparison':
            return MaterialPageRoute(
              builder: (context) => MainLayout(child: ComparisonPage()),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => MainLayout(child: const HomePage()),
            );
        }
      },
    );
  }
}

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Navbar(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: child),
          const Footer(),
        ],
      ),
    );
  }
}
