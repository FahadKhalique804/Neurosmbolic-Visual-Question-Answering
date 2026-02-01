from Models.config import Database


class ContactModel:
    def __init__(self):
        self.db = Database()

    def validate_blind_exists(self, blind_id):
        print("In validation for blind_id:", blind_id)
        """Ensure the contact exists before adding a picture."""
        contact = self.db.execute(
            "SELECT id FROM Blind WHERE id=?",
            (blind_id,)
        ).fetchone()
        if not contact:
            raise ValueError("Invalid contact_id: Contact does not exist.")

    def create_contact(self, blind_id, name, relation, age, gender, created_at):
        query = """
            SET NOCOUNT ON;
            INSERT INTO Contact (blind_id, name, relation, age, gender, created_at)
            OUTPUT INSERTED.id
            VALUES (?, ?, ?, ?, ?, ?)
        """
        params = (blind_id, name, relation, age, gender, created_at)

        # Use a fresh cursor
        cursor = self.db.execute(query, params)
        new_id = cursor.fetchone()[0]
        cursor.close()  # close cursor after fetching
        self.db.commit()  # commit via connection

        return new_id

    def get_distinct_relations_by_user(self, blind_id):
        query = "SELECT DISTINCT relation FROM Contact WHERE blind_id=?"
        return self.db.execute(query, (blind_id,)).fetchall()

    # ===== Get distinct relations for all users =====
    def get_all_distinct_relations(self):
        query = "SELECT DISTINCT relation FROM Contact"
        return self.db.execute(query).fetchall()

    # ===== CRUD Methods =====
    def get_all_contacts(self):
        """Get all contacts."""
        return self.db.execute(
            "SELECT id, blind_id, name, relation, age, gender, created_at FROM Contact ORDER BY name"
        ).fetchall()

    def update_contact(self, contact_id, blind_id, name, relation, age, gender, created_at):
        """Update an existing contact."""
        self.db.execute(
            "UPDATE Contact SET blind_id=?, name=?, relation=?, age=?, gender=?, created_at=? WHERE id=?",
            (blind_id, name, relation, age, gender, created_at, contact_id)
        )
        self.db.commit()

    def delete_contact(self, contact_id):
        """Delete a contact."""
        self.db.execute(
            "DELETE FROM Contact WHERE id=?", (contact_id,)
        )
        self.db.commit()

    # ===== Query Methods =====
    def get_contacts_by_user(self, blind_id):
        """Get all contacts for a specific blind user."""
        return self.db.execute(
            "SELECT id, name, relation, age, gender, created_at FROM Contact WHERE blind_id=? ORDER BY name",
            (blind_id,)
        ).fetchall()

    def search_contacts_by_relation(self, relation):
        """Search contacts by relation keyword."""
        return self.db.execute(
            "SELECT id, blind_id, name, relation, age, gender, created_at FROM Contact WHERE LOWER(relation) LIKE ?",
            (f"%{relation.lower()}%",)
        ).fetchall()

    def get_contacts_by_blind_name(self, blind_name):
        """Get all contacts for a blind user by blind's name."""
        return self.db.execute(
            """
            SELECT c.id, c.name, c.relation, c.age, c.gender, c.created_at, c.blind_id
            FROM Contact c
            JOIN Blind b ON b.id = c.blind_id
            WHERE LOWER(b.name) = ?
            """,
            (blind_name.lower(),)
        ).fetchall()

    def count_contacts_for_user(self, blind_id):
        """Count the number of contacts for a blind user."""
        result = self.db.execute(
            "SELECT COUNT(*) FROM Contact WHERE blind_id = ?", (blind_id,)
        ).fetchone()
        return result[0] if result else 0

    def get_distinct_relations(self):
        """Get all unique relations across contacts."""
        return self.db.execute(
            "SELECT DISTINCT relation FROM Contact ORDER BY relation"
        ).fetchall()
