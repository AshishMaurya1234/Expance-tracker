const express = require('express');
const router = express.Router();
const db = require('../config/db');
const auth = require('../middleware/auth');

// Get all categories (default + user's custom)
router.get('/', auth, async (req, res) => {
  try {
    const [categories] = await db.query(
      'SELECT * FROM categories WHERE user_id IS NULL OR user_id = ? ORDER BY category_name ASC',
      [req.user.user_id]
    );
    res.json(categories);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create custom category
router.post('/', auth, async (req, res) => {
  try {
    const { category_name, icon } = req.body;
    if (!category_name) {
      return res.status(400).json({ message: 'Category name is required' });
    }

    const [result] = await db.query(
      'INSERT INTO categories (category_name, icon, user_id) VALUES (?, ?, ?)',
      [category_name, icon || 'category', req.user.user_id]
    );

    res.status(201).json({
      category_id: result.insertId,
      category_name,
      icon: icon || 'category',
      user_id: req.user.user_id
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;