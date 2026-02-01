# from Models.config import Database

# class BlindModel:
#     def __init__(self):
#         self.db = Database()

#     def get_all_queries(self):
#         return self.db.execute(
#             "SELECT id, question, answer, image_path, user_id FROM Blindqueries"
#         ).fetchall()

#     def create_query(self, question, answer, image_path, user_id):
#         self.db.execute(
#             "INSERT INTO Blindqueries (question, answer, image_path, user_id) VALUES (?, ?, ?, ?)",
#             (question, answer, image_path, user_id)
#         )
#         self.db.commit()

#     def update_query(self, query_id, question, answer, image_path, user_id):
#         self.db.execute(
#             "UPDATE Blindqueries SET question=?, answer=?, image_path=?, user_id=? WHERE id=?",
#             (question, answer, image_path, user_id, query_id)
#         )
#         self.db.commit()

#     def delete_query(self, query_id):
#         self.db.execute(
#             "DELETE FROM Blindqueries WHERE id=?", (query_id,)
#         )
#         self.db.commit()

#     def get_queries_by_user(self, user_id):
#         return self.db.execute(
#             "SELECT id, question, answer, image_path FROM Blindqueries WHERE user_id=?",
#             (user_id,)
#         ).fetchall()


from Models.config import Database


class BlindHistoryModel:
    def __init__(self):
        self.db = Database()

    def get_all_queries(self):
        return self.db.execute(
            "SELECT id, question, answer, image_path, blind_id, created_at FROM BlindHistory"
        ).fetchall()

    def create_query(self, question, answer, image_path, blind_id, created_at):
        self.db.execute(
            "INSERT INTO BlindHistory (question, answer, image_path, blind_id, created_at) VALUES (?, ?, ?, ?, ?)",
            (question, answer, image_path, blind_id, created_at)
        )
        self.db.commit()

    def update_query(self, query_id, question, answer, image_path, blind_id, created_at):
        self.db.execute(
            "UPDATE BlindHistory SET question=?, answer=?, image_path=?, blind_id=?, created_at=? WHERE id=?",
            (question, answer, image_path, blind_id, created_at, query_id)
        )
        self.db.commit()

    def delete_query(self, query_id):
        self.db.execute(
            "DELETE FROM BlindHistory WHERE id=?", (query_id,)
        )
        self.db.commit()

    def get_queries_by_user(self, blind_id):
        return self.db.execute(
            "SELECT id, question, answer, image_path, created_at FROM BlindHistory WHERE blind_id=?",
            (blind_id,)
        ).fetchall()

    def HistoryOnAssistantID(self, assistant_id):
        q = """
            SELECT
            BH.id,
            Bh.question,
                Bh.answer,
                Bh.image_path,
                Bh.created_at
            FROM BlindHistory AS Bh
            JOIN Blind B ON B.id = Bh.blind_id
            JOIN Assistant A ON A.id = B.assistant_id
            WHERE B.assistant_id = ?
        """
        print("Executing the query:", q, "with assistant_id =", assistant_id)
        return self.db.execute(q, (assistant_id,)).fetchall()

    def get_query_by_id(self, query_id):
        return self.db.execute(
            "SELECT id, question, answer, image_path, blind_id, created_at FROM BlindHistory WHERE id=?",
            (query_id,)
        ).fetchone()