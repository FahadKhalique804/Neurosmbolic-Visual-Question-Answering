from Models.config import Database
import datetime


class BlindModel:
    def __init__(self):
        self.db = Database()

    def getAllblinds(self):
        query = "Select id,name,age,gender,assistant_id from Blind"
        return self.db.execute(query).fetchall()

    def getBlindById(self, blind_id):
        query = "Select id,name,age,gender,assistant_id from Blind where id=?"
        return self.db.execute(query, (blind_id)).fetchone()

    def createBlind(self, name, age, gender, assistant_id, pic):
        created_at = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        query = "Insert into Blind(name,age,gender,assistant_id,pic,created_at) values(?,?,?,?,?,?)"
        self.db.execute(query, (name, age, gender, assistant_id, pic, created_at))
        self.db.commit()

    def updateBlindAllDetails(self, blind_id, name, age, gender, assistant_id, pic):
        query = """
            UPDATE Blind 
            SET name = ?, age = ?, gender = ?, assistant_id = ?, pic = ?
            WHERE id = ?;
            """
        values = (name, age, gender, assistant_id, pic, blind_id)
        self.db.execute(query, values)
        self.db.commit()

    def getBlindDetailsOnName(self, name):
        query = "Select id,name,age,gender,assistant_id from Blind where name=?"
        return self.db.execute(query, (name,)).fetchone()

    def validate_assistant_available(self, assistant_id):
        """Check if the assistant is already assigned to a blind."""
        query = "SELECT id FROM Blind WHERE assistant_id=?"
        assigned = self.db.execute(query, (assistant_id,)).fetchone()
        if assigned:
            raise ValueError(f"Assistant with ID {assistant_id} is already assigned to another blind.")

    def deleteBlind(self, blind_id):
        query = "Delete from Blind where id=?"
        self.db.execute(query, (blind_id,))
        self.db.commit()

    def updateBlind(self, blind_id, **kwargs):
        if not kwargs:
            return  # nothing to update

        # Build SET clause dynamically
        set_clause = ", ".join([f"{col}=?" for col in kwargs.keys()])
        values = list(kwargs.values())
        values.append(blind_id)  # last param for WHERE id=?

        query = f"UPDATE Blind SET {set_clause} WHERE id=?"
        self.db.execute(query, tuple(values))
        self.db.commit()
