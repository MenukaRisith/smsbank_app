const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');

// Initialize Express App
const app = express();
const PORT = 3000;

// Middleware
app.use(bodyParser.json());

// MongoDB Connection
const MONGO_URI = 'MONGO URI';
mongoose
  .connect(MONGO_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch((err) => {
    console.error('Error connecting to MongoDB:', err);
    process.exit(1); 
  });

// Define Mongoose Schema and Model
const messageSchema = new mongoose.Schema(
  {
    bankName: { type: String, required: true },
    amount: { type: Number, required: true },
    accountNumber: { type: String, required: true },
    location: { type: String, default: '' },
    date: { type: String, required: true },
    time: { type: String, required: true },
  },
  { timestamps: true } // Automatically adds createdAt and updatedAt fields
);

const Message = mongoose.model('Message', messageSchema);

// API Endpoints

/**
 * POST /messages
 * Save new SMS messages to the database.
 */
app.post('/messages', async (req, res) => {
  const messages = req.body.messages;

  if (!Array.isArray(messages) || messages.length === 0) {
    return res.status(400).json({ error: 'Invalid or empty messages array' });
  }

  try {
    const insertedMessages = [];
    for (const message of messages) {
      // Check for duplicate (using bankName, amount, accountNumber, and date as unique keys)
      const existingMessage = await Message.findOne({
        bankName: message.bankName,
        amount: message.amount,
        accountNumber: message.accountNumber,
        date: message.date,
      });

      if (!existingMessage) {
        const newMessage = new Message(message);
        const savedMessage = await newMessage.save();
        insertedMessages.push(savedMessage);
      }
    }

    res.status(201).json({
      message: `${insertedMessages.length} new messages added`,
      data: insertedMessages,
    });
  } catch (err) {
    console.error('Error saving messages:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

/**
 * GET /messages
 * Fetch all SMS messages from the database.
 */
app.get('/messages', async (req, res) => {
  try {
    const messages = await Message.find().sort({ createdAt: -1 }); // Sort by latest first
    res.json(messages);
  } catch (err) {
    console.error('Error fetching messages:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Start the Server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
