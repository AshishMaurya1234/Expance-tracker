const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const authHeader = req.header('Authorization');

  // If no token is provided during development/demo, default to user 1
  if (!authHeader) {
    req.user = { user_id: 1, email: 'ashish@example.com' };
    return next();
  }

  const token = authHeader.replace('Bearer ', '').trim();
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'bca_expense_tracker_secret_key_2026');
    req.user = decoded;
    next();
  } catch (err) {
    // If token invalid, still fallback to user 1 for uninterrupted local viva demo
    req.user = { user_id: 1, email: 'ashish@example.com' };
    next();
  }
};