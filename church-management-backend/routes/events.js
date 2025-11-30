// church-management-backend/routes/events.js
const express = require('express');
const router = express.Router();
const db = require('../config/database');

router.get('/', async (req, res) => {
  try {
    const { priest_id, church_id } = req.query;
    
    let query = `
      SELECT e.*, et.name as entity_type, ev.name as visibility
      FROM events e
      JOIN entity_types et ON e.entity_type_id = et.entity_type_id
      JOIN event_visibility ev ON e.visibility_id = ev.event_visibility_id
      WHERE 1=1
    `;
    
    const params = [];
    
    if (priest_id) {
      query += ` AND e.entity_type_id = (SELECT entity_type_id FROM entity_types WHERE name = 'PRIEST')
                 AND e.entity_id = ?`;
      params.push(priest_id);
    }
    
    if (church_id) {
      query += ` AND e.entity_type_id = (SELECT entity_type_id FROM entity_types WHERE name = 'CHURCH')
                 AND e.entity_id = ?`;
      params.push(church_id);
    }
    
    query += ` ORDER BY e.start_time`;
    
    const [events] = await db.query(query, params);
    
    res.json({ success: true, data: events });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const [events] = await db.query(`
      SELECT e.*, et.name as entity_type, ev.name as visibility
      FROM events e
      JOIN entity_types et ON e.entity_type_id = et.entity_type_id
      JOIN event_visibility ev ON e.visibility_id = ev.event_visibility_id
      WHERE e.event_id = ?
    `, [req.params.id]);
    
    if (events.length === 0) {
      return res.status(404).json({ success: false, error: 'Event not found' });
    }
    
    res.json({ success: true, data: events[0] });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const {
      entity_type,
      entity_id,
      title,
      description,
      start_time,
      end_time,
      visibility,
      created_by
    } = req.body;
    
    // Get type IDs
    const [entityType] = await db.query(
      'SELECT entity_type_id FROM entity_types WHERE name = ?',
      [entity_type]
    );
    
    const [visibilityType] = await db.query(
      'SELECT event_visibility_id FROM event_visibility WHERE name = ?',
      [visibility]
    );
    
    const [result] = await db.query(
      `INSERT INTO events 
       (entity_type_id, entity_id, title, description, start_time, end_time, visibility_id, created_by)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [entityType[0].entity_type_id, entity_id, title, description, 
       start_time, end_time, visibilityType[0].event_visibility_id, created_by]
    );
    
    res.status(201).json({
      success: true,
      event_id: result.insertId
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, start_time, end_time, visibility } = req.body;
    
    let query = 'UPDATE events SET ';
    const params = [];
    const updates = [];
    
    if (title !== undefined) {
      updates.push('title = ?');
      params.push(title);
    }
    if (description !== undefined) {
      updates.push('description = ?');
      params.push(description);
    }
    if (start_time !== undefined) {
      updates.push('start_time = ?');
      params.push(start_time);
    }
    if (end_time !== undefined) {
      updates.push('end_time = ?');
      params.push(end_time);
    }
    if (visibility !== undefined) {
      const [visibilityType] = await db.query(
        'SELECT event_visibility_id FROM event_visibility WHERE name = ?',
        [visibility]
      );
      updates.push('visibility_id = ?');
      params.push(visibilityType[0].event_visibility_id);
    }
    
    if (updates.length === 0) {
      return res.status(400).json({ success: false, error: 'No fields to update' });
    }
    
    query += updates.join(', ') + ' WHERE event_id = ?';
    params.push(id);
    
    const [result] = await db.query(query, params);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Event not found' });
    }
    
    res.json({ success: true, message: 'Event updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const [result] = await db.query(
      'DELETE FROM events WHERE event_id = ?',
      [req.params.id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: 'Event not found' });
    }
    
    res.json({ success: true, message: 'Event deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.get('/priest/:priestId', async (req, res) => {
  try {
    const [events] = await db.query(`
      SELECT e.*, et.name as entity_type, ev.name as visibility
      FROM events e
      JOIN entity_types et ON e.entity_type_id = et.entity_type_id
      JOIN event_visibility ev ON e.visibility_id = ev.event_visibility_id
      WHERE e.entity_type_id = (SELECT entity_type_id FROM entity_types WHERE name = 'PRIEST')
        AND e.entity_id = ?
      ORDER BY e.start_time
    `, [req.params.priestId]);
    
    res.json({ success: true, data: events });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.get('/church/:churchId', async (req, res) => {
  try {
    const [events] = await db.query(`
      SELECT e.*, et.name as entity_type, ev.name as visibility
      FROM events e
      JOIN entity_types et ON e.entity_type_id = et.entity_type_id
      JOIN event_visibility ev ON e.visibility_id = ev.event_visibility_id
      WHERE e.entity_type_id = (SELECT entity_type_id FROM entity_types WHERE name = 'CHURCH')
        AND e.entity_id = ?
      ORDER BY e.start_time
    `, [req.params.churchId]);
    
    res.json({ success: true, data: events });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;