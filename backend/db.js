const mysql = require('mysql2');
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '', // Nếu có thì thêm vào
  database: 'mypham'
});
connection.connect(err => {
  if (err) console.error('❌ Kết nối MySQL thất bại:', err);
  else console.log('✅ Kết nối MySQL thành công');
});
module.exports = connection;
