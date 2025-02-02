const express = require('express');
const cors = require('cors');
const fs = require('fs');
const app = express();
const PORT = 5000;

app.use(cors({ origin: 'http://localhost:3000' }));
app.use(express.json());

const dbFile = './db.json';
const getDB = () => JSON.parse(fs.readFileSync(dbFile));
const saveDB = (data) => fs.writeFileSync(dbFile, JSON.stringify(data, null, 2));

// Pobierz wszystkie produkty
app.get('/products', (req, res) => {
    const db = getDB();
    res.json(db.products);
});

// Pobierz wszystkie kategorie
app.get('/categories', (req, res) => {
    const db = getDB();
    res.json(db.categories);
});

// Pobierz wszystkie transakcje
app.get('/transactions', (req, res) => {
    const db = getDB();
    res.json(db.transactions || []);
});

// Dodaj produkt
app.post('/products', (req, res) => {
    const db = getDB();
    const newProduct = { id: Date.now(), ...req.body };
    db.products.push(newProduct);
    saveDB(db);
    res.status(201).json(newProduct);
});

// Dodaj kategorię
app.post('/categories', (req, res) => {
    const db = getDB();
    const newCategory = { id: Date.now(), ...req.body };
    db.categories.push(newCategory);
    saveDB(db);
    res.status(201).json(newCategory);
});

// Zapisz transakcję
app.post('/transactions', (req, res) => {
    const db = getDB();
    const newTransaction = { id: Date.now(), products: req.body.products, total: req.body.total };
    db.transactions = db.transactions || [];
    db.transactions.push(newTransaction);
    saveDB(db);
    res.status(201).json(newTransaction);
});

app.listen(PORT, () => console.log(`Serwer działa na http://localhost:${PORT}`));