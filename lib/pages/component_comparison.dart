import 'package:flutter/material.dart';

class ComparisonComponent extends StatelessWidget {
  const ComparisonComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        bool isMobile =
            screenWidth < 600; // ถ้าจอเล็กกว่า 600px ถือว่าเป็นมือถือ

        return Container(
          padding: EdgeInsets.all(isMobile ? 20 : 50), // ปรับ Padding
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isMobile
              ? Column(
                  // 📱 มือถือใช้ Column
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTextSection(isMobile),
                    const SizedBox(height: 16),
                    _buildImageSection(),
                  ],
                )
              : Row(
                  // 💻 เว็บไซต์ใช้ Row
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 3, child: _buildTextSection(isMobile)),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildImageSection()),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTextSection(bool isMobile) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'เปรียบเทียบราคาผลผลิตด้วยการพยากรณ์ที่แม่นยำ',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: isMobile ? 18 : 20, //ปรับขนาดตัวอักษร
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'วิเคราะห์แนวโน้มราคาและข้อมูลผลผลิตแบบมืออาชีพ เพื่อช่วยให้คุณวางแผนการขายและการลงทุนได้อย่างมั่นใจ พร้อมข้อมูลเชิงลึกที่ช่วยเพิ่มโอกาสความสำเร็จในทุกฤดูกาล',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16, //ปรับขนาดตัวอักษร
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: 0.75,
        child: Image.asset(
          'assets/compare_produce.png',
          height: 200,
          width: double.infinity, // ทำให้รูปเต็มพื้นที่
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
