import 'package:flutter/material.dart';

class PriceForecastComponent extends StatelessWidget {
  const PriceForecastComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        bool isMobile = screenWidth < 600; // กำหนดเงื่อนไขสำหรับมือถือ

        return Container(
          padding: EdgeInsets.all(isMobile ? 20 : 50), // ปรับขนาด Padding ตามจอ
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildImageSection(isMobile),
                    const SizedBox(height: 16),
                    _buildTextSection(isMobile),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 2, child: _buildImageSection(isMobile)),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: _buildTextSection(isMobile)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildImageSection(bool isMobile) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: 0.75,
          child: Image.asset(
            'assets/vegetables_forecast.jpg',
            height: isMobile ? 180 : 200, // ปรับขนาดภาพ
            width:
                isMobile ? double.infinity : null, // ทำให้เต็มพื้นที่ในมือถือ
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection(bool isMobile) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: const [
        FeatureList(features: [
          'เลือกสินค้าพยากรณ์ตามช่วงราคาที่ต้องการ',
          'กำหนดช่วงเวลาเพื่อดูการพยากรณ์',
          'นำข้อมูลมาเปรียบเทียบในแผนการตัดสินใจ',
        ]),
      ],
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
