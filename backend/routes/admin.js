const express = require('express');
const router = express.Router();
const db = require('../db'); // bạn sẽ tạo file này (nếu chưa có) để kết nối MySQL

// 📊 Tổng số người dùng
router.get('/users/count', async (req, res) => {
  try {
    const [rows] = await db.promise().query('SELECT COUNT(*) AS total FROM users');
    res.json({ totalUsers: rows[0].total });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server khi lấy tổng số người dùng' });
  }
});






module.exports = router;
