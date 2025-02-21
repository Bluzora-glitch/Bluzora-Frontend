from flask import Flask, jsonify, request
from flask_cors import CORS  # เปิดใช้งาน CORS
import json  # อย่าลืม import json ด้วย

# โหลดข้อมูลจากไฟล์ vegetables.json
def load_data():
    with open('assets/vegetables.json', 'r', encoding='utf-8') as f:
        return json.load(f)

app = Flask(__name__)
CORS(app)  # เปิดใช้งาน CORS

@app.route('/api/priceforecast', methods=['GET'])
def price_forecast():
    # รับพารามิเตอร์จาก URL Query
    vegetable_name = request.args.get('vegetableName')
    start_date = request.args.get('startDate')
    end_date = request.args.get('endDate')

    # ส่งข้อความธรรมดากลับมา โดยไม่คำนวณหรือดึงข้อมูลจริง ๆ
    return jsonify({"message": "ตารางข้อมูลในอนาคต"})

if __name__ == '__main__':
    app.run(debug=True)
