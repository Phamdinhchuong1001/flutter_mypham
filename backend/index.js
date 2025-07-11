const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const mysql = require('mysql2');
const multer = require('multer');
const path = require('path');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Kết nối MySQL
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '', // thêm nếu bạn có
  database: 'mypham'
});

db.connect(err => {
  if (err) console.error('❌ Kết nối MySQL thất bại:', err);
  else console.log('✅ Kết nối MySQL thành công');
});

// ⚙️ Cấu hình lưu file upload (avatar)
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, 'user_' + Date.now() + ext);
  }
});
const upload = multer({ storage });
app.use('/uploads', express.static('uploads')); // truy cập ảnh

// 📌 Đăng ký
app.post('/api/register', (req, res) => {
  const { name, email, password } = req.body;
  const hashed = bcrypt.hashSync(password, 8);
  db.query(
    'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
    [name, email, hashed],
    (err) => {
      if (err) return res.status(400).json({ message: 'Email đã tồn tại hoặc lỗi' });
      res.json({ message: 'Đăng ký thành công' });
    }
  );
});

// 🔐 Đăng nhập
app.post('/api/login', (req, res) => {
  const { email, password } = req.body;
  db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
    if (err || results.length === 0)
      return res.status(401).json({ message: 'Email không tồn tại' });

    const user = results[0];
    const isMatch = bcrypt.compareSync(password, user.password);
    if (!isMatch) return res.status(401).json({ message: 'Sai mật khẩu' });

    res.json({
      message: 'Đăng nhập thành công',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        location: user.location,
        avatar: user.avatar ? `/uploads/${user.avatar}` : null
      }
    });
  });
});

// 📝 Cập nhật thông tin người dùng
app.put('/api/users/:id', (req, res) => {
  const userId = req.params.id;
  const { name, email, phone, location, oldPassword, newPassword } = req.body;

  db.query('SELECT * FROM users WHERE id = ?', [userId], (err, results) => {
    if (err || results.length === 0)
      return res.status(404).json({ message: 'User không tồn tại' });

    const user = results[0];

    if (newPassword) {
      const isMatch = bcrypt.compareSync(oldPassword, user.password);
      if (!isMatch) return res.status(400).json({ message: 'Mật khẩu cũ không đúng' });

      const hashed = bcrypt.hashSync(newPassword, 8);
      db.query(
        'UPDATE users SET name = ?, email = ?, phone = ?, location = ?, password = ? WHERE id = ?',
        [name, email, phone, location, hashed, userId],
        (err) => {
          if (err) return res.status(500).json({ message: 'Lỗi khi cập nhật' });
          res.json({ message: 'Cập nhật thành công (có đổi mật khẩu)' });
        }
      );
    } else {
      db.query(
        'UPDATE users SET name = ?, email = ?, phone = ?, location = ? WHERE id = ?',
        [name, email, phone, location, userId],
        (err) => {
          if (err) return res.status(500).json({ message: 'Lỗi khi cập nhật' });
          res.json({ message: 'Cập nhật thành công' });
        }
      );
    }
  });
});

// 🖼️ API cập nhật avatar
app.post('/api/users/:id/avatar', upload.single('avatar'), (req, res) => {
  const userId = req.params.id;
  const fileName = req.file.filename;
  const imagePath = `/uploads/${fileName}`;

  db.query('UPDATE users SET avatar = ? WHERE id = ?', [fileName, userId], (err) => {
    if (err) return res.status(500).json({ message: 'Lỗi khi cập nhật avatar' });
    res.json({ message: 'Cập nhật avatar thành công', avatar: imagePath });
  });
});

// Khởi động server
app.listen(3000, () => console.log('🚀 Server chạy tại http://localhost:3000'));
