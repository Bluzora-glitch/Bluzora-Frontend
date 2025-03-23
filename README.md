# bluzora

flutter doctor
flutter config --enable-web
flutter devices
flutter pub get
flutter run -d chrome

git
git status
git branch
git remote -v
git add .
git commit -m "แก้ปัญหาเรียกapiโหลดช้า"
git push -f origin main
git push origin frontend_with_api
git pull origin frontend_edit_price_forecast

## Page Price_Forecast
1. แก้รับวันที่จากเดิม Dropdown เป็น DatePicker และแก้ขนาดตัวเลือกให้กว้างเท่าเลือกชนิดพืช
2.  แก้เรียกชื่อพืชจาก api แทนที่ static json เดิม
3.  ทำให้กราฟแสดงผลได้โดยลบ json and flask api เดิม เปลี่ยนเป็น django api endpoint ของโปรเจค 
4. ChartData Class:
  เพิ่มฟิลด์ minPrice, maxPrice, avgPrice, และ predictedPrice ในส่วน backend เพื่อรวมข้อมูลอดีต+ทำนาย สำหรับเรียกใช้ api ในหน้านี้
  เปลี่ยน date เป็น DateTime จากวันที่ตัวเลขกรอกเองเป็นค่าDateTime
4.ในฟังก์ชัน fetchData() ของ GraphPlaceholder:
  แยกข้อมูล historical และ predicted ไม่ให้ซ้ำซ้อน 
  สำหรับ historical ให้ parse ค่า min_price, max_price และ price (ซึ่งเป็นค่าเฉลี่ย)
  เรียงลำดับข้อมูลด้วย DateTime.parse ลดความซ้ำซ้อน แก้ conflict แสดงเวลาไม่ตามไทม์ไลน์
  กำหนดค่าให้กับ historicalData และ predictedData
5. ใน SfCartesianChart:
  ใช้ DateTimeAxis โดยกำหนด dateFormat: DateFormat('d MMM') แก้ให้แกน X เพื่อแสดงตัวเลขวันพร้อมชื่อเดือน
  RangeAreaSeries สำหรับ historical range (แสดงพื้นที่สีระหว่าง minPrice และ maxPrice)
    -กำหนด enableTooltip: false เพื่อไม่แสดง tooltip
  LineSeries สำหรับ historical average (ชื่อ "ราคาจริง")
    -มี marker และ tooltip ที่แสดงรายละเอียด (รวมช่วงราคาต่ำสุด-สูงสุด)
  LineSeries สำหรับ predicted price (ชื่อ "ราคาพยากรณ์")
    -มี marker เพิ่มจุดในแต่ละค่า และ tooltip ที่แสดงรายละเอียดเป็น ชื่อข้อมูล วันที่ ราคาเฉลี่ย ราคาสูงต่ำ ราคาพยากรณ์
6. Tooltip Behavior:
   ลบ tooltipText ให้ไม่ต้องแสดงเลยในเส้น max-min price
  กำหนด _tooltipBehavior ด้วย custom builder เพื่อแสดง tooltip เฉพาะใน LineSeries ที่มีชื่อ "ราคาจริง" และ "ราคาพยากรณ์"
  Tooltip สำหรับ RangeAreaSeries ถูกปิดด้วย enableTooltip: false
7. การเปลี่ยนข้อมูลใหม่:
  เมื่อกดปุ่ม "พยากรณ์" จะ rebuild GraphPlaceholder ด้วย key ที่เปลี่ยนแปลงโดยอัตโนมัติ (ทำให้แสดงข้อมูลใหม่ทันทีไม่ต้องรอกดล้างข้อมูลก่อนถึงแสดงกราฟ)

need to edit
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
