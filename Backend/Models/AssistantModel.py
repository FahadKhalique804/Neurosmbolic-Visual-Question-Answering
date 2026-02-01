from Models.config import Database
import datetime


class AssistantModel:
    def __init__(self):
        self.db = Database()

    def check_username_exists(self, username):
        row = self.db.execute("SELECT id FROM Assistant WHERE username = ?", (username,)).fetchone()
        return row is not None

    # Get all assistants
    def getAllAssistants(self):
        query = "SELECT id, name, age, gender, pic, username, password, created_at FROM Assistant"
        return self.db.execute(query).fetchall()

    # Get assistant by ID
    def getAssistantById(self, assistant_id):
        query = "SELECT id, name, age, gender, pic, username, password, created_at FROM Assistant WHERE id=?"
        return self.db.execute(query, (assistant_id,)).fetchone()

    # Create new assistant
    def createAssistant(self, name, age, gender, pic, username, password):
        created_at = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        query = """
                INSERT INTO Assistant(name, age, gender, pic, username, password, created_at)
                OUTPUT INSERTED.id
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """

        print("Executing query:", query)
        assistant_id = self.db.execute(query, (name, age, gender, pic, username, password, created_at)).fetchone()[0]
        print(assistant_id)
        self.db.commit()
        return assistant_id  # Return the ID of the newly created assistant

    # Update all assistant details
    def updateAssistantAllDetails(self, assistant_id, name, age, gender, pic, username, password):
        query = """
            UPDATE Assistant
            SET name = ?, age = ?, gender = ?, pic = ?, username = ?, password = ?
            WHERE id = ?;
        """
        values = (name, age, gender, pic, username, password, assistant_id)
        self.db.execute(query, values)
        self.db.commit()

    def updateAssistant(self, assistant_id, **kwargs):
        if not kwargs:
            return  # nothing to update

        set_clause = ", ".join([f"{col}=?" for col in kwargs.keys()])
        values = list(kwargs.values())
        values.append(assistant_id)

        query = f"UPDATE Assistant SET {set_clause} WHERE id=?"
        self.db.execute(query, tuple(values))
        self.db.commit()

    # Get assistant by username
    def getAssistantByUsername(self, username):
        query = "SELECT id, name, age, gender, pic, username, password, created_at FROM Assistant WHERE username=?"
        return self.db.execute(query, (username,)).fetchone()

    # Delete assistant
    def deleteAssistant(self, assistant_id):
        query = "DELETE FROM Assistant WHERE id=?"
        self.db.execute(query, (assistant_id,))
        self.db.commit()
