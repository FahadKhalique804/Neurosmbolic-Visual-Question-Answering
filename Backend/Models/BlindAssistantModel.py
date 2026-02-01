from Models.config import Database


class BlindAssistantModel:
    def __init__(self):
        self.db = Database()

    def getAssistantWithBlind(self, assistant_id):
        query = """
            SELECT 
                a.id AS assistant_id, a.name AS assistant_name, a.age AS assistant_age, a.gender AS assistant_gender, 
                a.pic AS assistant_pic, a.username, a.created_at,
                b.id AS blind_id, b.name AS blind_name, b.age AS blind_age, b.gender AS blind_gender, b.pic AS blind_pic
            FROM Assistant a
            LEFT JOIN Blind b ON a.id = b.assistant_id
            WHERE a.id = ?
        """
        return self.db.execute(query, (assistant_id,)).fetchone()

    def loginAssistant(self, username, password):
        query = "SELECT id,name,age,gender,pic FROM Assistant WHERE username=? AND password=?"
        return self.db.execute(query, (username, password)).fetchone()

    def getBlindByAssistantId(self, assistant_id):
        query = "SELECT id,name, age, gender, assistant_id, pic FROM Blind WHERE assistant_id=?"
        return self.db.execute(query, (assistant_id,)).fetchall()

    def get_blinds_with_assistants(self):
        query = """
            SELECT 
                b.id, 
                b.name AS BlindName, 
                b.age AS BlindAge, 
                b.gender AS BlindGender,
                a.id AS AssistantID,
                a.name AS AssistantName
            FROM Blind b
            JOIN Assistant a ON a.id = b.assistant_id
        """
        return self.db.execute(query).fetchall()



