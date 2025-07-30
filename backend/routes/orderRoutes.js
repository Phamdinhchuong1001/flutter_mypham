const express = require('express');
const router = express.Router();
const db = require('../db'); // File kết nối MySQL

// 📦 [GET] /api/orders/count – Tổng số đơn hàng
router.get('/count', async (req, res) => {
  try {
    const [rows] = await db.promise().query('SELECT COUNT(*) AS total FROM orders');
    res.json({ totalOrders: rows[0].total });
  } catch (err) {
    console.error('❌ Lỗi lấy tổng đơn hàng:', err);
    res.status(500).json({ message: 'Lỗi server khi lấy tổng đơn hàng' });
  }
});


// 💰 [GET] /api/orders/revenue – Lấy tổng doanh thu (không cần status)
router.get('/revenue', async (req, res) => {
  try {
    const [rows] = await db.promise().query(`
      SELECT SUM(total_price) AS totalRevenue
      FROM orders
    `);
    res.json({ totalRevenue: rows[0].totalRevenue || 0 });
  } catch (err) {
    console.error('❌ Lỗi lấy tổng doanh thu:', err.message);
    res.status(500).json({ message: 'Lỗi server khi lấy tổng doanh thu' });
  }
});

// ✅ [PUT] /api/orders/:id/status – Cập nhật trạng thái đơn hàng
router.put('/:id/status', async (req, res) => {
  const orderId = req.params.id;
  const { status } = req.body;

  if (!status) {
    return res.status(400).json({ message: 'Thiếu trạng thái cần cập nhật' });
  }

  try {
    const [result] = await db.promise().execute(
      'UPDATE orders SET status = ? WHERE id = ?',
      [status, orderId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Không tìm thấy đơn hàng' });
    }

    res.json({ message: 'Cập nhật trạng thái thành công' });
  } catch (err) {
    console.error('❌ Lỗi cập nhật trạng thái:', err);
    res.status(500).json({ message: 'Lỗi server khi cập nhật trạng thái' });
  }
});




// 🛒 [POST] /api/orders – Tạo đơn hàng mới
router.post('/', async (req, res) => {
  const { userId, totalPrice, items } = req.body;

  try {
    const [orderResult] = await db.promise().execute(
      'INSERT INTO orders (user_id, total_price) VALUES (?, ?)',
      [userId, totalPrice]
    );

    const orderId = orderResult.insertId;

    for (const item of items) {
      await db.promise().execute(
        'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
        [orderId, item.productId, item.quantity, item.price]
      );
    }

    res.status(201).json({ message: 'Đặt hàng thành công!' });
  } catch (error) {
    console.error('❌ Lỗi lưu đơn hàng:', error);
    res.status(500).json({ message: 'Lỗi khi lưu đơn hàng.' });
  }
});

// 📋 [GET] /api/orders – Lấy danh sách đơn hàng (full chi tiết)
router.get('/', async (req, res) => {
  try {
    const [orders] = await db.promise().query(`
      SELECT 
        o.id AS orderId,
        o.user_id AS userId,
        u.name AS nameCustomer,
        o.total_price AS totalPrice,
        o.created_at AS createdAt
      FROM orders o
      JOIN users u ON o.user_id = u.id
      ORDER BY o.created_at DESC
    `);

    const [items] = await db.promise().query(`
      SELECT 
        oi.order_id AS orderId,
        p.id AS productId,
        p.name AS title,
        p.image AS images,
        p.description,
        oi.quantity,
        oi.price
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
    `);

    const fullOrders = orders.map(order => {
      const orderItems = items
        .filter(item => item.orderId === order.orderId)
        .map(item => ({
          id: item.productId,
          title: item.title,
          description: item.description,
          images: item.images,
          quantity: item.quantity,
          price: item.price,
        }));

      return {
        ...order,
        listCartItem: orderItems,
        status: 'Chờ xác nhận',
        address: 'Địa chỉ demo',
        payment: 'Thanh toán khi nhận',
        deliveryFee: 0,
        orderDiscount: 0,
        note: '',
      };
    });

    res.json(fullOrders);
  } catch (err) {
    console.error('❌ Lỗi lấy danh sách đơn hàng:', err);
    res.status(500).json({ message: 'Lỗi server khi lấy đơn hàng' });
  }
});

module.exports = router;
