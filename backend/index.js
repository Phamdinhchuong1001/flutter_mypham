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
const orderRoutes = require('./routes/orderRoutes');
// 📂 Cho phép truy cập ảnh
app.use('/uploads', express.static('uploads'));

// ⚙️ Cấu hình multer lưu ảnh
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, 'user_' + Date.now() + ext);
  }
});
const upload = multer({ storage });

/* ------------------------- 🧑‍💼 TÀI KHOẢN NGƯỜI DÙNG ------------------------- */

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

// ✅ Lấy thông tin người dùng theo ID (API BỊ THIẾU – đã thêm)
app.get('/api/users/:id', (req, res) => {
  const userId = req.params.id;
  db.query('SELECT * FROM users WHERE id = ?', [userId], (err, results) => {
    if (err || results.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy user' });
    }
    res.json(results[0]);
  });
});

// ✅ Tạo người dùng mới (API BỊ THIẾU – đã thêm)
app.post('/api/users', (req, res) => {
  const { name, email, phone, location, password } = req.body;
  const hashed = bcrypt.hashSync(password, 8);

  db.query(
    'INSERT INTO users (name, email, phone, location, password) VALUES (?, ?, ?, ?, ?)',
    [name, email, phone, location, hashed],
    (err, result) => {
      if (err) return res.status(400).json({ message: 'Lỗi tạo user' });
      res.status(200).json({ message: 'Tạo người dùng thành công', id: result.insertId });
    }
  );
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

// ✅ Cập nhật avatar
app.post('/api/users/:id/avatar', upload.single('avatar'), (req, res) => {
  const userId = req.params.id;
  const fileName = req.file.filename;
  const imagePath = `/uploads/${fileName}`;

  db.query('UPDATE users SET avatar = ? WHERE id = ?', [fileName, userId], (err) => {
    if (err) return res.status(500).json({ message: 'Lỗi khi cập nhật avatar' });
    res.json({ message: 'Cập nhật avatar thành công', avatar: imagePath });
  });
});

// ✅ Xoá người dùng
app.delete('/api/users/:id', (req, res) => {
  const userId = req.params.id;
  db.query('DELETE FROM users WHERE id = ?', [userId], (err, result) => {
    if (err) return res.status(500).json({ message: 'Lỗi khi xoá người dùng' });
    if (result.affectedRows === 0)
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    res.json({ message: 'Xoá người dùng thành công' });
  });
});

// ✅ Đếm tổng số người dùng
app.get('/api/users/count', (req, res) => {
  db.query('SELECT COUNT(*) AS totalUsers FROM users', (err, results) => {
    if (err) return res.status(500).json({ message: 'Lỗi server khi đếm người dùng' });
    res.json(results[0]);
  });
});

// ✅ Lấy danh sách tất cả người dùng
app.get('/api/users', (req, res) => {
  db.query('SELECT * FROM users', (err, results) => {
    if (err) return res.status(500).json({ message: 'Lỗi khi truy vấn users' });
    res.json(results);
  });
});

/* ------------------------- 🔔 THÔNG BÁO ------------------------- */

// ✅ Gửi thông báo từ user
app.post('/api/notifications', (req, res) => {
  const { user_id, title, content } = req.body;
  const createdAt = new Date();
  db.query(
    'INSERT INTO notifications (user_id, title, content, is_read, created_at) VALUES (?, ?, ?, 0, ?)',
    [user_id, title, content, createdAt],
    (err) => {
      if (err) return res.status(500).json({ message: 'Lỗi khi gửi thông báo' });
      res.json({ message: 'Gửi thông báo thành công' });
    }
  );
});

// ✅ Gửi thông báo từ Flutter Admin
app.post('/send-notification', (req, res) => {
  const { userId, title, body } = req.body;
  const createdAt = new Date();

  if (!userId || !title || !body)
    return res.status(400).json({ message: 'Thiếu dữ liệu' });

  db.query(
    'INSERT INTO notifications (user_id, title, content, is_read, created_at) VALUES (?, ?, ?, 0, ?)',
    [userId, title, body, createdAt],
    (err) => {
      if (err) return res.status(500).json({ message: 'Lỗi khi gửi thông báo' });
      res.status(200).json({ message: 'Gửi thông báo thành công' });
    }
  );
});

// ✅ Lấy danh sách thông báo theo user
app.get('/api/notifications/:userId', (req, res) => {
  const userId = req.params.userId;
  db.query(
    'SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC',
    [userId],
    (err, results) => {
      if (err) return res.status(500).json({ message: 'Lỗi khi lấy thông báo' });
      res.json(results);
    }
  );
});

// ✅ Đếm số thông báo chưa đọc
app.get('/api/notifications/:userId/unread-count', (req, res) => {
  const userId = req.params.userId;
  db.query(
    'SELECT COUNT(*) AS unreadCount FROM notifications WHERE user_id = ? AND is_read = 0',
    [userId],
    (err, results) => {
      if (err) return res.status(500).json({ message: 'Lỗi khi đếm thông báo chưa đọc' });
      res.json({ unreadCount: results[0].unreadCount });
    }
  );
});

// ✅ Đánh dấu đã đọc tất cả thông báo
app.put('/api/notifications/:userId/mark-as-read', (req, res) => {
  const userId = req.params.userId;
  db.query(
    'UPDATE notifications SET is_read = 1 WHERE user_id = ?',
    [userId],
    (err) => {
      if (err) return res.status(500).json({ message: 'Lỗi khi đánh dấu đã đọc' });
      res.json({ message: 'Tất cả thông báo đã được đánh dấu đã đọc' });
    }
  );
});

/* ------------------------- PRODUCT ------------------------- */
// ✅ Thêm sản phẩm mới
app.post('/api/products', (req, res) => {
  const { name, image, description, price } = req.body;
  console.log('📥 Dữ liệu nhận từ Flutter:', req.body);
  if (!name || !image || !description || !price) {
    return res.status(400).json({ message: 'Thiếu thông tin sản phẩm' });
  }

  const sql = 'INSERT INTO products (name, image, description, price) VALUES (?, ?, ?, ?)';
  db.query(sql, [name, image, description, price], (err, result) => {
    if (err) {
      console.error('Lỗi khi thêm sản phẩm:', err);
      return res.status(500).json({ message: 'Lỗi server' });
    }
    res.status(201).json({ message: 'Thêm sản phẩm thành công', id: result.insertId });
  });
});

// ✅ Lấy danh sách sản phẩm
app.get('/api/products', (req, res) => {
  const sql = 'SELECT * FROM products';
  db.query(sql, (err, results) => {
    if (err) {
      console.error('Lỗi khi lấy danh sách sản phẩm:', err);
      return res.status(500).json({ message: 'Lỗi server' });
    }
    res.json(results);
  });
});

// ✅ Cập nhật sản phẩm
app.put('/api/products/:id', (req, res) => {
  const { name, image, description, price } = req.body;
  const { id } = req.params;

  console.log('📥 Nhận PUT:', req.params, req.body); // 👈 THÊM LOG NÀY

  if (!name || !image || !description || !price) {
    return res.status(400).json({ message: 'Thiếu thông tin sản phẩm' });
  }

  const sql = 'UPDATE products SET name = ?, image = ?, description = ?, price = ? WHERE id = ?';
  db.query(sql, [name, image, description, price, id], (err, result) => {
    if (err) {
      console.error('❌ Lỗi khi cập nhật sản phẩm:', err);
      return res.status(500).json({ message: 'Lỗi server' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Không tìm thấy sản phẩm để cập nhật' });
    }

    console.log('✅ Cập nhật thành công sản phẩm ID:', id); // 👈 THÊM LOG NÀY
    res.status(200).json({ message: '✅ Cập nhật sản phẩm thành công' });
  });
});

// ✅ Xóa sản phẩm
app.delete('/api/products/:id', (req, res) => {
  const { id } = req.params;

  const sql = 'DELETE FROM products WHERE id = ?';
  db.query(sql, [id], (err, result) => {
    if (err) {
      console.error('❌ Lỗi khi xoá sản phẩm:', err);
      return res.status(500).json({ message: 'Lỗi server khi xoá sản phẩm' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Không tìm thấy sản phẩm để xoá' });
    }

    console.log(`🗑️ Đã xoá sản phẩm ID ${id}`);
    res.status(200).json({ message: '✅ Xoá sản phẩm thành công' });
  });
});

// ✅ Đếm tổng số sản phẩm
app.get('/api/products/count', (req, res) => {
  const sql = 'SELECT COUNT(*) AS totalProducts FROM products';
  db.query(sql, (err, results) => {
    if (err) {
      console.error('❌ Lỗi khi đếm sản phẩm:', err);
      return res.status(500).json({ message: 'Lỗi server khi đếm sản phẩm' });
    }
    res.json({ totalProducts: results[0].totalProducts });
  });
});



/* ------------------------- 🔗 ROUTER ADMIN & SERVER ------------------------- */

app.use('/api/orders', orderRoutes);
app.use('/api/admin', adminRoutes);
app.listen(3000, '0.0.0.0', () => {
  console.log('🚀 Server đang chạy tại http://0.0.0.0:3000');
});