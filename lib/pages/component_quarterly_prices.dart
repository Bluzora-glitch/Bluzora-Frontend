import 'package:flutter/material.dart';

class QuarterlyPricesComponent extends StatelessWidget {
  const QuarterlyPricesComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        bool isMobile = screenWidth < 600; // กำหนดเงื่อนไขสำหรับมือถือ

        return Container(
          padding: EdgeInsets.all(isMobile ? 20 : 50), // ปรับขนาด Padding
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
            'assets/quarterly_prices.jpg',
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
        Text(
          'ติดตามข้อมูลราคาย้อนหลังของพืชผักได้อย่างสะดวก',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'เข้าถึงข้อมูลราคาพืชผักทางการเกษตรย้อนหลัง ช่วยให้คุณวิเคราะห์ความเปลี่ยนแปลงของตลาด มองเห็นแนวโน้มในระยะยาว และวางแผนการผลิตหรือการจำหน่ายได้อย่างมั่นใจ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        FeatureList(
          features: [
            'เก็บข้อมูลราคาผักย้อนหลังอย่างละเอียด',
            'วิเคราะห์แนวโน้มจากข้อมูลในอดีต',
            'ใช้ข้อมูลจริงประกอบการวางแผนเกษตรกรรม',
          ],
        ),
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
