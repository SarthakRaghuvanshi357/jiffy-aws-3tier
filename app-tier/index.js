const express = require('express'), cors = require('cors'), mysql = require('mysql2/promise');
const app = express();
app.use(cors()); app.use(express.json());
const pool = mysql.createPool({
  host: process.env.DB_HOST, user: process.env.DB_USER, password: process.env.DB_PASS,
  database: process.env.DB_NAME || 'jiffy', waitForConnections: true, connectionLimit: 10
});
const FREE_DELIVERY_ABOVE = 199, DELIVERY_FEE = 25;
const wrap = fn => (req, res) => fn(req, res).catch(e => { console.error(e); res.status(500).json({ error: 'Server error' }); });

app.get('/health', (_, res) => res.send('ok'));
app.get('/api/products', wrap(async (_, res) => res.json((await pool.query('SELECT * FROM products ORDER BY category, name'))[0])));

app.post('/api/orders', wrap(async (req, res) => {
  const { customer, phone, address, items } = req.body || {};
  if (!customer || !phone || !address || !Array.isArray(items) || !items.length)
    return res.status(400).json({ error: 'Name, phone, address and at least one item are required.' });
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const rows = []; let subtotal = 0;
    for (const it of items) {                       // prices always come from the DB, never the browser
      const [[p]] = await conn.query('SELECT id,name,price FROM products WHERE id=?', [it.id]);
      if (!p) throw new Error('Unknown item');
      const qty = Math.max(1, Math.min(20, parseInt(it.qty) || 1));
      subtotal += p.price * qty; rows.push([p.id, p.name, p.price, qty]);
    }
    const fee = subtotal >= FREE_DELIVERY_ABOVE ? 0 : DELIVERY_FEE, total = subtotal + fee;
    const [o] = await conn.query('INSERT INTO orders (customer,phone,address,subtotal,delivery_fee,total) VALUES (?,?,?,?,?,?)', [customer, phone, address, subtotal, fee, total]);
    for (const r of rows) await conn.query('INSERT INTO order_items (order_id,product_id,name,price,qty) VALUES (?,?,?,?,?)', [o.insertId, ...r]);
    await conn.commit();
    res.status(201).json({ orderId: o.insertId, total, etaMinutes: 10 });
  } catch (e) { await conn.rollback(); console.error(e); res.status(400).json({ error: 'Could not place order.' }); }
  finally { conn.release(); }
}));

app.listen(4000, () => console.log('Jiffy API on :4000'));
