const express = require('express');
const router = express.Router();
const db = require('../db'); // bạn sẽ tạo file này (nếu chưa có) để kết nối MySQL

// 📊 Tổng số người dùng
router.get('/users/count', (req, res) => {
  db.query('SELECT COUNT(*) AS total FROM users', (err, results) => {
    if (err) return res.status(500).json({ message: 'Lỗi server' });
    res.json({ totalUsers: results[0].total });
  });
});

// 📦 Thống kê đơn hàng và doanh thu
router.get('/orders/analytics', async (req, res) => {
  try {
    const [orders] = await db.promise().query('SELECT COUNT(*) AS totalOrders, SUM(total_price) AS totalRevenue FROM orders');

    const [productSales] = await db.promise().query(`
      SELECT p.id AS productId, p.name AS productName, SUM(od.quantity) AS salesCount
      FROM order_details od
      JOIN products p ON od.product_id = p.id
      GROUP BY od.product_id
      ORDER BY salesCount DESC
      LIMIT 5
    `);

    res.json({
      totalOrders: orders[0].totalOrders,
      totalRevenue: orders[0].totalRevenue || 0,
      productSales,
    });
  } catch (err) {
    res.status(500).json({ message: 'Lỗi server khi phân tích đơn hàng' });
  }
});

// 🔝 Sản phẩm bán chạy
router.get('/products/top-selling', async (req, res) => {
  try {
    const [rows] = await db.promise().query(`
      SELECT id AS productId, name AS productName
      FROM products
      ORDER BY id DESC
      LIMIT 5
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi khi lấy sản phẩm bán chạy' });
  }
});

// 🧾 Đơn hàng gần đây
router.get('/orders/recent', async (req, res) => {
  try {
    const [rows] = await db.promise().query(`
      SELECT o.id AS orderId, o.total_price AS totalPrice, o.created_at AS createdAt,
             u.name AS nameCustomer, o.status
      FROM orders o
      JOIN users u ON o.user_id = u.id
      ORDER BY o.created_at DESC
      LIMIT 5
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: 'Lỗi khi lấy đơn hàng gần đây' });
  }
});

module.exports = router;
