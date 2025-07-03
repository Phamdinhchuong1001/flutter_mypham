const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('./db');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Đăng ký
app.post('/api/register', (req, res) => {
  const { name, email, password } = req.body;
  const hashed = bcrypt.hashSync(password, 8);

  db.query('INSERT INTO users (name, email, password) VALUES (?, ?, ?)', [name, email, hashed], (err, result) => {
    if (err) {
      return res.status(400).json({ message: 'Email đã tồn tại hoặc lỗi server' });
    }
    res.json({ message: 'Đăng ký thành công' });
  });
});

// Đăng nhập
app.post('/api/login', (req, res) => {
  const { email, password } = req.body;

  db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
    if (err || results.length === 0) {
      return res.status(401).json({ message: 'Email không tồn tại' });
    }

    const user = results[0];
    const isMatch = bcrypt.compareSync(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Sai mật khẩu' });
    }

    const token = jwt.sign({ id: user.id }, 'secretkey', { expiresIn: '1d' });
    res.json({ message: 'Đăng nhập thành công', token, user: { id: user.id, name: user.name, email: user.email } });
  });
});

// Chạy server
app.listen(3000, () => {
  console.log('🚀 Server chạy tại http://localhost:3000');
});
