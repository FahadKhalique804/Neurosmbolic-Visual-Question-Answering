from Models.config import Database


class ContactPicsModel:
    def __init__(self):
        self.db = Database()

    # ===== Helper =====
    def _validate_contact_exists(self, contact_id):
        """Ensure the contact exists before adding a picture."""
        contact = self.db.execute(
            "SELECT id FROM Contact WHERE id=?",
            (contact_id,)
        ).fetchone()
        if not contact:
            raise ValueError("Invalid contact_id: Contact does not exist.")

    def get_all_pics(self):
        return self.db.execute(
            "SELECT id, contact_id, pic_path, created_at FROM ContactPics ORDER BY id"
        ).fetchall()

    def create_pic(self, contact_id, pic_path, created_at):
        self._validate_contact_exists(contact_id)
        self.db.execute(
            "INSERT INTO ContactPics (contact_id, pic_path, created_at) VALUES (?, ?, ?)",
            (contact_id, pic_path, created_at)
        )
        self.db.commit()

    def update_pic(self, pic_id, contact_id=None, pic_path=None, created_at=None):
        if contact_id is not None:
            self._validate_contact_exists(contact_id)

        fields = []
        values = []

        if contact_id is not None:
            fields.append("contact_id=?")
            values.append(contact_id)
        if pic_path is not None:
            fields.append("pic_path=?")
            values.append(pic_path)
        if created_at is not None:
            fields.append("created_at=?")
            values.append(created_at)

        values.append(pic_id)
        if fields:
            query = f"UPDATE ContactPics SET {', '.join(fields)} WHERE id=?"
            self.db.execute(query, tuple(values))
            self.db.commit()

    def delete_pic(self, pic_id):
        self.db.execute("DELETE FROM ContactPics WHERE id=?", (pic_id,))
        self.db.commit()

    def get_pics_by_contact(self, contact_id):
        return self.db.execute(
            "SELECT id, pic_path, created_at FROM ContactPics WHERE contact_id=? ORDER BY created_at DESC",
            (contact_id,)
        ).fetchall()

    def get_contacts_with_pics(self):
        query = """
            SELECT c.id AS contact_id,
                   c.name AS contact_name,
                   c.relation,
                   c.age,
                   c.gender,
                   c.blind_id,
                   p.id AS pic_id,
                   p.pic_path
            FROM Contact c
            LEFT JOIN ContactPics p ON c.id = p.contact_id
            ORDER BY c.name
        """
        return self.db.execute(query).fetchall()

    def get_contacts_with_pics_by_blindid(self, blind_id):
        query = """
            SELECT c.id AS contact_id,
                c.name AS contact_name,
                c.relation,
                c.age,
                c.gender,
                c.blind_id,
                p.id AS pic_id,
                p.pic_path
            FROM Contact c
            LEFT JOIN ContactPics p ON c.id = p.contact_id
            WHERE c.blind_id = ?
            ORDER BY c.name
        """
        return self.db.execute(query, (blind_id,)).fetchall()


