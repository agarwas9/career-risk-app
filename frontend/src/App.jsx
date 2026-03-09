import { useEffect, useState } from "react";

function App() {
  const [records, setRecords] = useState([]);
  const [form, setForm] = useState({
    company: "",
    position: "",
    learned: "",
    status: ""
  });

  const API_URL = "/api/records";

  // Fetch records from backend
  useEffect(() => {
    fetch(API_URL)
      .then(res => res.json())
      .then(data => setRecords(data))
      .catch(err => console.error(err));
  }, []);

  // Handle form change
  const handleChange = (e) => {
    setForm({
      ...form,
      [e.target.name]: e.target.value
    });
  };

  // Submit new record
  const handleSubmit = async (e) => {
    e.preventDefault();

    const response = await fetch(API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(form)
    });

    const newRecord = await response.json();

    setRecords([...records, {
      ...newRecord,
      riskScore: newRecord.riskScore
    }]);

    setForm({
      company: "",
      position: "",
      learned: "",
      status: ""
    });
  };

  return (
    <div style={{ padding: "20px" }}>
      <h1>Career Risk Tracker</h1>

      <form onSubmit={handleSubmit} style={{ marginBottom: "20px" }}>
        <input name="company" placeholder="Company" value={form.company} onChange={handleChange} />
        <input name="position" placeholder="Position" value={form.position} onChange={handleChange} />
        <input name="learned" placeholder="What I Learned" value={form.learned} onChange={handleChange} />
        <input name="status" placeholder="Status" value={form.status} onChange={handleChange} />
        <button type="submit">Add</button>
      </form>

      <table border="1" cellPadding="8">
        <thead>
          <tr>
            <th>Company</th>
            <th>Position</th>
            <th>What I Learned</th>
            <th>Status</th>
            <th>Risk Score</th>
          </tr>
        </thead>
        <tbody>
          {records.map((r) => (
            <tr key={r.id}>
              <td>{r.company}</td>
              <td>{r.position}</td>
              <td>{r.learned}</td>
              <td>{r.status}</td>
              <td>{r.riskScore}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default App;