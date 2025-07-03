const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '', // nếu có password thì điền
  database: 'mypham'
});

connection.connect((err) => {
  if (err) {
    console.error('❌ Kết nối MySQL thất bại:', err);
  } else {
    console.log('✅ Kết nối MySQL thành công');
  }
});

module.exports = connection;
