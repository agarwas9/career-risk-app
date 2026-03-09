const express = require('express');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3000;

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});

async function startServer() {
    let retries = 10;

    while (retries) {
        try {
            await pool.query(`
                CREATE TABLE IF NOT EXISTS records (
                    id SERIAL PRIMARY KEY,
                    company TEXT NOT NULL,
                    position TEXT NOT NULL,
                    learned TEXT NOT NULL,
                    status TEXT NOT NULL
                );
            `);

            console.log("Database ready. Table ensured.");
            break;
        } catch (err) {
            console.log("Waiting for database...");
            retries--;
            await new Promise(res => setTimeout(res, 3000));
        }
    }

    if (!retries) {
        console.error("Database not reachable. Exiting.");
        process.exit(1);
    }

    app.listen(PORT, () => {
        console.log("Server running on http://localhost:" + PORT);
    });
}

startServer();

app.use(express.json());

const cors = require('cors');
app.use(cors());

app.get('/health', (req, res) => {
    res.status(200).json({ status: "ok" });
});

app.get('/ready', async (req, res) => {
    try {
        await pool.query('SELECT 1');
        res.status(200).json({ status: "ready" });
    } catch (err) {
        res.status(500).json({ status: "not ready" });
    }
});

function generateRiskScore(company, position) {
    const combined = company + position;
    let hash = 0;

    for (let i = 0; i < combined.length; i++) {
        hash = combined.charCodeAt(i) + ((hash << 5) - hash);
        hash = hash & hash;
    }

    const numeric = Math.abs(hash).toString().padStart(10, '0');
    return numeric.slice(0, 10);
}

app.get('/api/records', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM records');

        const response = result.rows.map(record => {
            return {
                id: record.id,
                company: record.company,
                position: record.position,
                learned: record.learned,
                status: record.status,
                riskScore: generateRiskScore(record.company, record.position)
            };
        });

        res.json(response);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Database error" });
    }
});

app.post('/api/records', async (req, res) => {
    const { company, position, learned, status } = req.body;

    if (!company || !position || !learned || !status) {
        return res.status(400).json({ error: "All fields are required" });
    }

    try {
        const result = await pool.query(
            'INSERT INTO records (company, position, learned, status) VALUES ($1, $2, $3, $4) RETURNING *',
            [company, position, learned, status]
        );

        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Database error" });
    }
});

app.listen(PORT, () => {
    console.log("Server running on http://localhost:" + PORT);
});