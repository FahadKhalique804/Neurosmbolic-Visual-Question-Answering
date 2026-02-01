from flask import Blueprint, request, jsonify
from Models.BlindHistory_models import BlindHistoryModel

blind_routes = Blueprint("blind_routes", __name__)
blind_model = BlindHistoryModel()

@blind_routes.route('', methods=['GET'])
def get_blindqueries():
    queries = blind_model.get_all_queries()
    return jsonify([
        {'id': r[0], 'question': r[1], 'answer': r[2], 'image_path': r[3], 'user_id': r[4]}
        for r in queries
    ])

#imp
@blind_routes.route('/getHistory/<int:assistant_id>',methods=['POST'])
def gethistorybyAssistant(assistant_id):
    print(" In the function == Assitant ID ==> " , 1)
    queries=blind_model.HistoryOnAssistantID(assistant_id)
    return jsonify(
        [{
            'id':r[0],
            'question': r[1],
            'answer': r[2],
            'image_path': r[3],
            'created_at': r[4]
        } for r in queries]
    )




@blind_routes.route('', methods=['POST'])
def create_blindquery():
    data = request.json
    blind_model.create_query(data['question'], data['answer'], data['image_path'], data['user_id'])
    return jsonify({'message': 'Blindquery created'}), 201

@blind_routes.route('/<int:query_id>', methods=['PUT'])
def update_blindquery(query_id):
    data = request.json
    blind_model.update_query(query_id, data['question'], data['answer'], data['image_path'], data['user_id'])
    return jsonify({'message': 'Blindquery updated'})


@blind_routes.route('/<int:query_id>', methods=['DELETE'])
def delete_blindquery(query_id):
    blind_model.delete_query(query_id)
    return jsonify({'message': 'Blindquery deleted'})

@blind_routes.route('/user/<int:user_id>', methods=['GET'])
def queries_by_user(user_id):
    queries = blind_model.get_queries_by_user(user_id)
    return jsonify([
        {'id': r[0], 'question': r[1], 'answer': r[2], 'image_path': r[3]}
        for r in queries
    ])


