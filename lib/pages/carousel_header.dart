import 'package:flutter/material.dart';

class CarouselHeader extends StatefulWidget {
  @override
  _CarouselHeaderState createState() => _CarouselHeaderState();
}

class _CarouselHeaderState extends State<CarouselHeader> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      "title": "การพยากรณ์ล่วงหน้า\nเพียง 1 เดียว",
      "description":
          "วางแผนอนาคตอย่างมั่นใจด้วยระบบพยากรณ์ราคาผักล่วงหน้า\nที่ช่วยให้คุณก้าวสู่ตลาดพร้อมข้อมูลเชิงลึกแบบเรียลไทม์",
      "image": "assets/background.jpg",
      "buttonText": "คำนวณการพยากรณ์",
      "buttonAction": () => print("ไปที่หน้าคำนวณ"),
    },
    {
      "title": "เทคโนโลยีช่วยคุณ\nให้ตัดสินใจได้ดีขึ้น",
      "description":
          "ใช้ AI และข้อมูลสถิติเพื่อให้คุณได้รับข้อมูลที่แม่นยำ\nและสามารถวางแผนการขายล่วงหน้าได้อย่างมั่นใจ",
      "image": "assets/background2.jpg",
      "buttonText": "ดูรายละเอียด",
      "buttonAction": () => print("ไปที่หน้ารายละเอียด"),
    },
    {
      "title": "เข้าถึงตลาด\nก่อนใคร",
      "description":
          "ใช้ระบบของเราสำหรับวางแผนและขยายตลาดของคุณ\nเพื่อให้คุณมีความได้เปรียบเหนือคู่แข่ง",
      "image": "assets/background3.jpg",
      "buttonText": "สมัครใช้งาน",
      "buttonAction": () => print("ไปที่หน้าสมัคร"),
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), _autoSlide);
  }

  void _autoSlide() {
    if (mounted) {
      int nextIndex = (_currentIndex + 1) % _slides.length;
      _pageController.animateToPage(
        nextIndex,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      Future.delayed(Duration(seconds: 5), _autoSlide);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _slides.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          itemBuilder: (context, index) {
            return Image.asset(
              _slides[index]['image'],
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              fit: BoxFit.cover,
            );
          },
        ),
        Positioned(
          left: 100,
          right: 100,
          top: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                child: Column(
                  key: ValueKey<int>(_currentIndex),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _slides[_currentIndex]["title"],
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _slides[_currentIndex]["description"],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _slides[_currentIndex]["buttonAction"],
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(_slides[_currentIndex]["buttonText"]),
                        ),
                        SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: () {
                            print("ไปที่หน้ารายละเอียดเพิ่มเติม");
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'รายละเอียดเพิ่มเติม',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 400,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 5),
                width: _currentIndex == index ? 12 : 8,
                height: _currentIndex == index ? 12 : 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index ? Colors.white : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
