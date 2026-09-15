const express = require('express');
const router = express.Router();
const db = require('../config/db');
const auth = require('../middleware/auth');

// Monthly report breakdown
router.get('/monthly', auth, async (req, res) => {
  try {
    const month = req.query.month || new Date().toISOString().slice(0, 7); // e.g. "2026-05"

    const [rows] = await db.query(
      `SELECT 
         c.category_name, 
         COUNT(e.expense_id) AS transaction_count, 
         SUM(e.amount) AS total_amount
       FROM expenses e
       JOIN categories c ON e.category_id = c.category_id
       WHERE e.user_id = ? AND DATE_FORMAT(e.expense_date, '%Y-%m') = ?
       GROUP BY c.category_id, c.category_name`,
      [req.user.user_id, month]
    );

    const totalSum = rows.reduce((acc, curr) => acc + Number(curr.total_amount), 0);
    const report = rows.map(r => ({
      category_name: r.category_name,
      transaction_count: r.transaction_count,
      total_amount: Number(r.total_amount),
      share_percentage: totalSum > 0 ? ((Number(r.total_amount) / totalSum) * 100).toFixed(1) : 0
    }));

    res.json({ month, totalSum, breakdown: report });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;