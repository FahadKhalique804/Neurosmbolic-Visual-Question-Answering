# from Models.config import Database

# class CFGModel:
#     def __init__(self):
#         self.db = Database()

#     def get_all_rules(self):
#         return self.db.execute("SELECT id, lhs, rhs FROM cfg_rules ORDER BY id").fetchall()

#     def insert_rule(self, lhs, rhs):
#         self.db.execute("INSERT INTO cfg_rules (lhs, rhs) VALUES (?, ?)", (lhs, rhs))
#         self.db.commit()

#     def rule_exists(self, rhs):
#         result = self.db.execute("SELECT COUNT(*) FROM cfg_rules WHERE lhs = 'S' AND rhs = ?", (rhs,)).fetchone()
#         return result[0] > 0

#     def find_rule_by_rhs(self, rhs):
#         return self.db.execute("SELECT id FROM cfg_rules WHERE lhs = 'S' AND rhs = ?", (rhs,)).fetchone()

#     def update_rule(self, rule_id, new_rhs):
#         self.db.execute("UPDATE cfg_rules SET rhs = ? WHERE id = ?", (new_rhs, rule_id))
#         self.db.commit()

#     def delete_rule(self, rule_id):
#         self.db.execute("DELETE FROM cfg_rules WHERE id = ?", (rule_id,))
#         self.db.commit()

#     def insert_vocab(self, pos_tag, word):
#         self.db.execute("INSERT INTO vocabulary (pos_tag, word) VALUES (?, ?)", (pos_tag, word))
#         self.db.commit()

#     def vocab_exists(self, pos_tag, word):
#         result = self.db.execute("SELECT COUNT(*) FROM vocabulary WHERE pos_tag = ? AND word = ?", (pos_tag, word)).fetchone()
#         return result[0] > 0

#     def get_all_vocabulary(self):
#         return self.db.execute("SELECT pos_tag, word FROM vocabulary ORDER BY pos_tag, word").fetchall()

#     def delete_vocab(self, pos_tag, word):
#         self.db.execute("DELETE FROM vocabulary WHERE pos_tag = ? AND word = ?", (pos_tag, word))
#         self.db.commit()

#     def update_vocab(self, pos_tag, old_word, new_word):
#         self.db.execute("UPDATE vocabulary SET word = ? WHERE word = ? AND pos_tag = ?", (new_word, old_word, pos_tag))
#         self.db.commit()

from Models.config import Database


class CFGModel:
    def __init__(self):
        self.db = Database()

    # ===== Rules Methods =====
    def get_all_rules(self):
        return self.db.execute("SELECT id, lhs, rhs FROM CFG ORDER BY id").fetchall()

    def insert_rule(self, lhs, rhs):
        self.db.execute("INSERT INTO CFG (lhs, rhs) VALUES (?, ?)", (lhs, rhs))
        self.db.commit()

    def rule_exists(self, rhs):
        result = self.db.execute("SELECT COUNT(*) FROM CFG WHERE lhs = 'S' AND rhs = ?", (rhs,)).fetchone()
        return result[0] > 0

    def find_rule_by_rhs(self, rhs):
        return self.db.execute("SELECT id FROM CFG WHERE lhs = 'S' AND rhs = ?", (rhs,)).fetchone()

    def update_rule(self, rule_id, new_rhs):
        self.db.execute("UPDATE CFG SET rhs = ? WHERE id = ?", (new_rhs, rule_id))
        self.db.commit()

    def delete_rule(self, rule_id):
        self.db.execute("DELETE FROM CFG WHERE id = ?", (rule_id,))
        self.db.commit()

    def insert_vocab(self, postag, word):
        self.db.execute(
            "INSERT INTO Vocabulary (pos_tag, word) VALUES (?, ?)",
            (postag, word)
        )
        self.db.commit()

    def vocab_exists(self, postag, word):
        result = self.db.execute(
            "SELECT COUNT(*) FROM Vocabulary WHERE pos_tag = ? AND word = ?",
            (postag, word)
        ).fetchone()
        return result[0] > 0

    def get_all_vocabulary(self):
        return self.db.execute(
            "SELECT id, postag, word FROM Vocabulary ORDER BY pos_tag, word"
        ).fetchall()

    def delete_vocab(self, vocab_id):
        self.db.execute("DELETE FROM Vocabulary WHERE id = ?", (vocab_id,))
        self.db.commit()

    def update_vocab(self, vocab_id, new_word):
        self.db.execute(
            "UPDATE Vocabulary SET word = ? WHERE id = ?",
            (new_word, vocab_id)
        )
        self.db.commit()
