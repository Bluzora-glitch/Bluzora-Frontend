import 'package:flutter/material.dart';

class CropRecommendationWidget extends StatelessWidget {
  final String cropName;
  final String unit;
  final int minGrowthDuration;
  final int maxGrowthDuration;
  final String idealSoil;
  final String optimalSeason;
  final String cultivationMethod;
  final String careTips;
  final int forecastDuration; // จำนวนวันในช่วงที่ผู้ใช้เลือก
  final String startDate; // รูปแบบวันที่เป็น string (เช่น "2023-07-01")
  final String endDate;
  final double overallAverage;
  final double overallMin;
  final double overallMax;
  final double volatilityPercent;
  final double priceChangePercent;
  final VoidCallback onDownloadPressed;
  final VoidCallback onClearPressed;

  const CropRecommendationWidget({
    super.key,
    required this.cropName,
    required this.unit,
    required this.minGrowthDuration,
    required this.maxGrowthDuration,
    required this.idealSoil,
    required this.optimalSeason,
    required this.cultivationMethod,
    required this.careTips,
    required this.forecastDuration,
    required this.startDate,
    required this.endDate,
    required this.overallAverage,
    required this.overallMin,
    required this.overallMax,
    required this.volatilityPercent,
    required this.priceChangePercent,
    required this.onDownloadPressed,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    // หัวข้อหลัก: "คำแนะนำการปลูก {CROPNAME} ({UNIT})"
    final header = Text(
      "คำแนะนำการปลูก ${cropName.toUpperCase()} ($unit)",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: Colors.lightGreen,
      ),
    );

    // คอลัมน์ซ้าย: ข้อมูลการปลูก
    final plantingInfoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ข้อมูลการปลูก:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        _buildBulletItem(context, "ระยะเวลาเก็บเกี่ยวที่แนะนำ:",
            "$minGrowthDuration-$maxGrowthDuration วัน"),
        _buildBulletItem(context, "ดินที่เหมาะสม:", idealSoil),
        _buildBulletItem(context, "ฤดูที่เหมาะสม:", optimalSeason),
        _buildBulletItem(context, "วิธีการปลูก:", cultivationMethod),
        _buildBulletItem(context, "คำแนะนำการดูแล:", careTips),
      ],
    );

    // คอลัมน์ขวา: การวิเคราะห์จากข้อมูลราคาและคำแนะนำ/คำเตือน
    final priceAnalysisColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "การวิเคราะห์จากข้อมูลราคา:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        _buildBulletItem(context, "ช่วงเวลาพยากรณ์:",
            "$forecastDuration วัน ตั้งแต่วันที่ $startDate ถึงวันที่ $endDate"),
        _buildBulletItem(context, "ราคาเฉลี่ยรวม:", "$overallAverage บาท",
            infoDetail:
                "หมายถึง ราคากลางที่บันทึกไว้ในช่วงเวลาที่ผู้ใช้เลือก ช่วยให้เห็นภาพระดับราคากลางของสินทรัพย์ในช่วงเวลานั้น ซึ่งเป็นตัวชี้วัดเบื้องต้นในการประเมินระดับราคาที่ตลาดมักมีการเคลื่อนไหว มาจากการนำราคาทั้งหมดในช่วงเวลาที่กำหนดมารวมกัน แล้วหารด้วยจำนวนรายการที่มีอยู่ เพื่อให้ได้ค่าราคาเฉลี่ยของสินค้าหรือบริการนั้น ๆ โดยเบื้องต้นจะคำนวณจากราคาในอดีต หากช่วงเวลาที่ผู้ใช้เลือกไม่มีข้อมูล จะคำนวณจากราคาพยากรณ์"),
        _buildBulletItem(
            context, "ราคารวมต่ำสุด-สูงสุด:", "$overallMin - $overallMax บาท",
            infoDetail:
                "หมายถึง ช่วงของราคาที่เกิดขึ้น โดยพิจารณาระหว่างราคาที่ต่ำที่สุดและราคาที่สูงที่สุด ที่พบในข้อมูลราคาในอดีต หากช่วงเวลาที่ผู้ใช้เลือกไม่มีข้อมูล จะพิจารณาจากราคาพยากรณ์ เพื่อให้ข้อมูลเกี่ยวกับช่วงการแกว่งตัวของราคาและช่วยในการประเมินความเสี่ยงที่อาจเกิดขึ้นจากการเปลี่ยนแปลงของราคา"),
        _buildBulletItem(context, "ความผันผวนราคา:", "$volatilityPercent%",
            infoDetail:
                "หมายถึง ความผันผวนราคาเป็นตัวชี้วัดการแกว่งตัวของราคาในช่วงเวลาที่เลือก หากราคามีความผันผวนสูง จะส่งผลต่อความเสี่ยงในการเลือกปลูกสินค้าและโอกาสที่ราคาจะเหวี่ยงมากหรือน้อย โดยวัดจากส่วนเบี่ยงเบนมาตรฐาน (Standard Deviation) ของผลตอบแทนรายวัน (Daily Returns) แปลงเป็นเปอร์เซ็นต์"),
        _buildTrendItem(context, "แนวโน้มราคา:", priceChangePercent,
            infoDetail:
                "การวัดการเปลี่ยนแปลงของราคาในช่วงเวลาที่เลือก โดยเปรียบเทียบราคาที่ ณ วันที่เริ่มต้นและวันที่สิ้นสุดเทียบเป็น% เพื่อบ่งชี้ว่าในช่วงเวลาที่เลือก ราคามีแนวโน้มเพิ่มขึ้นหรือลดลงเพียงใด"),
        if (forecastDuration < minGrowthDuration)
          _buildBulletItem(context, "คำแนะนำ:",
              "ช่วงเวลาพยากรณ์ที่คุณเลือกสั้นเกินไป เนื่องจากข้อมูลพยากรณ์มีจำกัดเพียง $forecastDuration วัน ซึ่งน้อยกว่าระยะเวลาการเติบโตขั้นต่ำที่แนะนำสำหรับพืชชนิดนี้ ($minGrowthDuration วัน) ข้อมูลอาจไม่เพียงพอสำหรับการวิเคราะห์ที่ถูกต้อง ผู้ใช้ควรเลือกช่วงเวลาที่กว้างขึ้นเพื่อให้ได้ผลวิเคราะห์ที่น่าเชื่อถือมากขึ้น และใช้ข้อมูลเพิ่มเติมจากแหล่งอื่นในการตัดสินใจ"),
        _buildBulletItem(context, "คำเตือน:",
            "ข้อมูลที่นำเสนอเป็นเพียงการคาดการณ์ตามแบบจำลองทางสถิติและปัจจัยที่มีอยู่ในขณะนั้น อาจมีความคลาดเคลื่อนจากสภาพการณ์จริง ผู้ใช้ควรศึกษาข้อมูลเพิ่มเติมจากแหล่งข้อมูลอื่น ๆ และพิจารณาปัจจัยแวดล้อม การลงทุนทางการเกษตรมีความเสี่ยง โปรดใช้วิจารณญาณในการตัดสินใจวางแผนการเพาะปลูก"),
      ],
    );

    // ปุ่มดาวน์โหลดและล้างข้อมูล จัดให้อยู่ตรงกลางด้านล่าง
    final buttonRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onDownloadPressed,
          child: const Text("ดาวน์โหลด Excel"),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: onClearPressed,
          child: const Text("ล้างข้อมูล"),
        ),
      ],
    );

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: plantingInfoColumn),
                const SizedBox(width: 16),
                Expanded(child: priceAnalysisColumn),
              ],
            ),
            const SizedBox(height: 16),
            buttonRow,
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างรายการ bullet item
  Widget _buildBulletItem(
    BuildContext context,
    String title,
    String content, {
    String? infoDetail,
  }) {
    // ตรวจสอบว่ามี infoDetail หรือไม่
    final bool hasInfo = infoDetail != null && infoDetail.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            // Bullet "• "
            const TextSpan(
              text: "• ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            // Title + space (ตัวหนา)
            TextSpan(
              text: "$title ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            // Content (ตัวปกติ)
            TextSpan(
              text: content,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
            // ถ้ามี infoDetail ให้แสดงไอคอน info เล็ก ๆ ต่อท้าย
            if (hasInfo)
              WidgetSpan(
                // จัดให้อยู่กลางบรรทัด
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  onTap: () {
                    // แสดง Dialog อธิบายเพิ่มเติม
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text(title),
                          content: Text(infoDetail!),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("ปิด"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  // ไอคอน info ขนาดเล็ก (size: 14)
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสำหรับแนวโน้มราคา พร้อมลูกศรชี้ขึ้น/ลง
  Widget _buildTrendItem(
      BuildContext context, String title, double priceChangePercent,
      {String? infoDetail}) {
    final bool isPositive = priceChangePercent >= 0;
    final Icon arrowIcon = isPositive
        ? const Icon(Icons.arrow_upward, color: Colors.green, size: 20)
        : const Icon(Icons.arrow_downward, color: Colors.red, size: 20);
    final String content = " ${priceChangePercent.abs().toStringAsFixed(1)} %";

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            const TextSpan(
              text: "• ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: "$title ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            WidgetSpan(child: arrowIcon),
            TextSpan(
              text: content,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            if (infoDetail != null && infoDetail.isNotEmpty)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text(title),
                          content: Text(infoDetail),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("ปิด"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child:
                        Icon(Icons.info_outline, size: 14, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
