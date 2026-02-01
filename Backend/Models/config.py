# import pyodbc
#
# class Database:
#     def __init__(self):
#         self.conn = pyodbc.connect(
#         'DRIVER={ODBC Driver 17 for SQL Server};'
#         'SERVER=DESKTOP-94V1PS4\\SQLEXPRESS;'
#         'DATABASE=NS_VQA;'
#         'Trusted_Connection=yes;'
#     )
#         self.cursor = self.conn.cursor()
#
#     def execute(self, query, params=()):
#         self.cursor.execute(query, params)
#         return self.cursor
#
#     def commit(self):
#         self.conn.commit()
#
#     def close(self):
#         self.cursor.close()
#         self.conn.close()


import pyodbc

class Database:
    def __init__(self):
        self.conn = pyodbc.connect(
            'DRIVER={ODBC Driver 17 for SQL Server};'
            'SERVER=DESKTOP-94V1PS4\\SQLEXPRESS;'
            'DATABASE=NS_VQA;'
            'Trusted_Connection=yes;'
        )

    def execute(self, query, params=()):
        # Create a fresh cursor for every query
        cursor = self.conn.cursor()
        cursor.execute(query, params)
        return cursor  # caller must fetch data and close cursor

    def commit(self):
        self.conn.commit()

    def close(self):
        self.conn.close()
