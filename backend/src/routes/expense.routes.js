const express = require('express');
const router = express.Router();
const db = require('../config/db');
const auth = require('../middleware/auth');

// Get all expenses for authenticated user
router.get('/', auth, async (req, res) => {
  try {
    const [expenses] = await db.query(
      `SELECT e.*, c.category_name, c.icon 
       FROM expenses e 
       JOIN categories c ON e.category_id = c.category_id 
       WHERE e.user_id = ? 
       ORDER BY e.expense_date DESC, e.created_at DESC`,
      [req.user.user_id]
    );
    res.json(expenses);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Add new expense
router.post('/', auth, async (req, res) => {
  try {
    const { amount, expense_date, payment_mode, notes, category_id } = req.body;
    if (!amount || !expense_date || !payment_mode || !category_id) {
      return res.status(400).json({ message: 'Missing required expense fields' });
    }

    const [result] = await db.query(
      'INSERT INTO expenses (amount, expense_date, payment_mode, notes, user_id, category_id) VALUES (?, ?, ?, ?, ?, ?)',
      [amount, expense_date, payment_mode, notes || null, req.user.user_id, category_id]
    );

    res.status(201).json({
      expense_id: result.insertId,
      amount,
      expense_date,
      payment_mode,
      notes,
      category_id,
      user_id: req.user.user_id
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update expense
router.put('/:id', auth, async (req, res) => {
  try {
    const { amount, expense_date, payment_mode, notes, category_id } = req.body;
    const expenseId = req.params.id;

    await db.query(
      `UPDATE expenses 
       SET amount = ?, expense_date = ?, payment_mode = ?, notes = ?, category_id = ? 
       WHERE expense_id = ? AND user_id = ?`,
      [amount, expense_date, payment_mode, notes, category_id, expenseId, req.user.user_id]
    );

    res.json({ message: 'Expense updated successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete expense
router.delete('/:id', auth, async (req, res) => {
  try {
    const expenseId = req.params.id;
    await db.query('DELETE FROM expenses WHERE expense_id = ? AND user_id = ?', [expenseId, req.user.user_id]);
    res.json({ message: 'Expense deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;