const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const path = require('path');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// 📦 Kết nối MySQL
const db = require('./db'); // File db.js kết nối database
const adminRoutes = require('./routes/admin'); // Các route admin khác (nếu có)

// 📂 Cho phép truy cập ảnh
app.use('/uploads', express.static('uploads'));

// ⚙️ Cấu hình multer lưu ảnh
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

/* ------------------------- TÀI KHOẢN NGƯỜI DÙNG ------------------------- */

// ✅ Đăng ký
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

// ✅ Đăng nhập
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
        avatar: user.avatar ? `/uploads/${user.avatar}` : null,
        role: user.role
      }
    });
  });
});

// ✅ Cập nhật thông tin người dùng
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

// ✅ Cập nhật avatar người dùng
app.post('/api/users/:id/avatar', upload.single('avatar'), (req, res) => {
  const userId = req.params.id;
  const fileName = req.file.filename;
  const imagePath = `/uploads/${fileName}`;

  db.query('UPDATE users SET avatar = ? WHERE id = ?', [fileName, userId], (err) => {
    if (err) return res.status(500).json({ message: 'Lỗi khi cập nhật avatar' });
    res.json({ message: 'Cập nhật avatar thành công', avatar: imagePath });
  });
});

/* ------------------------- 📊 DASHBOARD ------------------------- */

// ✅ Đếm tổng số người dùng
app.get('/api/users/count', (req, res) => {
  db.query('SELECT COUNT(*) AS totalUsers FROM users', (err, results) => {
    if (err) return res.status(500).json({ message: 'Lỗi server khi đếm người dùng' });
    res.json(results[0]); // { totalUsers: 5 }
  });
});

// ✅ Lấy danh sách tất cả người dùng
app.get('/api/users', (req, res) => {
  db.query('SELECT * FROM users', (err, results) => {
    if (err) {
      console.error('Lỗi khi truy vấn danh sách users:', err);
      return res.status(500).json({ message: 'Lỗi server khi truy vấn users' });
    }
    res.json(results); // Trả về mảng người dùng
  });
});

/* ------------------------- KHÁC ------------------------- */

// ✅ Gắn router admin
app.use('/api/admin', adminRoutes);

// ✅ Khởi động server
app.listen(3000, () => {
  console.log('🚀 Server đang chạy tại http://localhost:3000');
});
