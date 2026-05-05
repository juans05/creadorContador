const express = require('express');
const cors = require('cors');
const { errorHandler } = require('./middleware/errorHandler');

const app = express();

app.use(cors());
app.use(express.json());

const authRoutes = require('./routes/authRoutes');
const influencerRoutes = require('./routes/influencerRoutes');
const homeRoutes = require('./routes/homeRoutes');
const subscriptionRoutes = require('./routes/subscriptionRoutes');
const diamondRoutes = require('./routes/diamondRoutes');
const contentRoutes = require('./routes/contentRoutes');
const tipRoutes = require('./routes/tipRoutes');
const interactionsRoutes = require('./routes/interactionsRoutes');
const categoriesRoutes = require('./routes/categoriesRoutes');
const messagesRoutes = require('./routes/messagesRoutes');
const notificationsRoutes = require('./routes/notificationsRoutes');
const reportsRoutes = require('./routes/reportsRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/influencers', influencerRoutes);
app.use('/api/home', homeRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/diamonds', diamondRoutes);
app.use('/api/content', contentRoutes);
app.use('/api/tips', tipRoutes);
app.use('/api/interactions', interactionsRoutes);
app.use('/api/categories', categoriesRoutes);
app.use('/api/messages', messagesRoutes);
app.use('/api/notifications', notificationsRoutes);
app.use('/api/reports', reportsRoutes);

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'Luxor API is running' });
});

app.use(errorHandler);

module.exports = app;
