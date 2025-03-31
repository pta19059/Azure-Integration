const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Endpoint di esempio
app.get('/api/users/:id', (req, res) => {
  const userId = req.params.id;
  res.json({
    id: userId,
    name: 'Mario Rossi',
    email: 'mario.rossi@contoso.com'
  });
});

// Avvia il server
app.listen(port, () => {
  console.log(`API simulata in ascolto alla porta ${port}`);
});