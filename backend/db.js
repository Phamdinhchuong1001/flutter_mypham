const mysql = require('mysql2');

// Tạo pool kết nối cho phép nhiều truy vấn song song, hỗ trợ .promise()
const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '', // Nếu có thì điền vào
  database: 'mypham',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// ✅ Export pool để dùng cho cả callback-style lẫn async/await
module.exports = pool;
