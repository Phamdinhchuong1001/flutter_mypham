const express = require('express');
const router = express.Router();
const db = require('../db'); // kết nối database

// 👉 API thêm sản phẩm mới
router.post('/', async (req, res) => {
  const { name, price, description, image } = req.body;

  if (!name || !price || !description || !image) {
    return res.status(400).json({ message: 'Thiếu thông tin sản phẩm' });
  }

  try {
    const sql = 'INSERT INTO products (name, price, description, image) VALUES (?, ?, ?, ?)';
    await db.promise().execute(sql, [name, price, description, image]);
    res.status(201).json({ message: 'Thêm sản phẩm thành công' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi server khi thêm sản phẩm' });
  }
});

// 📦 Tổng số sản phẩm
router.get('/count', async (req, res) => {
  try {
    const [rows] = await db.promise().query('SELECT COUNT(*) AS total FROM products');
    res.json({ totalProducts: rows[0].total });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Lỗi khi lấy tổng số sản phẩm' });
  }
});


module.exports = router;
