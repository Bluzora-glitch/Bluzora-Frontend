import 'package:flutter/material.dart';

class VegetableForecastCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;

  const VegetableForecastCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // คอลัมน์ที่ 1: รูปภาพและข้อมูล (เล็กลง)
            Expanded(
              flex: 1,
              child: Container(
                height: 220, // ปรับให้เล็กลง
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            price,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // คอลัมน์ที่ 2: แดชบอร์ด 1
            Expanded(
              flex: 2,
              child: Container(
                height: 220, // เท่ากับคอลัมน์รูป
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                ),
                child: const Center(child: Text('แดชบอร์ด 1')),
              ),
            ),
            const SizedBox(width: 10),
            // คอลัมน์ที่ 3: แดชบอร์ด 2
            Expanded(
              flex: 1,
              child: Container(
                height: 220, // เท่ากับคอลัมน์รูป
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                ),
                child: const Center(child: Text('แดชบอร์ด 2')),
              ),
            ),
            const SizedBox(width: 10),
            // คอลัมน์ที่ 4: แดชบอร์ด 3
            Expanded(
              flex: 1,
              child: Container(
                height: 220, // เท่ากับคอลัมน์รูป
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                ),
                child: const Center(child: Text('แดชบอร์ด 3')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
