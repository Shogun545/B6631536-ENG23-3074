FROM nginx:alpine

# ลบไฟล์ default ของ nginx ออกก่อนเพื่อความสะอาด
RUN rm -rf /usr/share/nginx/html/*

# Copy ทุกอย่างในโฟลเดอร์ปัจจุบัน (ที่มี index.html และโฟลเดอร์ css/js) ไปที่ nginx
COPY . /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]