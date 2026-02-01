from datetime import datetime
from flask import Blueprint, request, jsonify
from Models.ContactModel import ContactModel
from Models.ContactPics import ContactPicsModel
import os
from flask import request, jsonify
from werkzeug.utils import secure_filename
from Services.image_service import ImageService

contact_routes = Blueprint("contact_routes", __name__)
contact_model = ContactModel()
pics_model = ContactPicsModel()


# ====== CONTACTS ======
@contact_routes.route('/', methods=['GET'])
def get_contacts():
    contacts = contact_model.get_all_contacts()
    return jsonify([{'id': r[0], 'name': r[1], 'relation': r[2], 'user_id': r[3]} for r in contacts])


@contact_routes.route('/create', methods=['POST'])
def create_contact():
    try:
        data = request.get_json(force=True)

        # Extract fields from request
        blind_id = data['blind_id']
        name = data['name']
        relation = data['relation']
        age = data['age']
        gender = data['gender']
        created_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        print(f"Creating contact for blind_id: {blind_id}, name: {name}, relation: {relation}")
        # Validate the user is blind
        contact_model.validate_blind_exists(blind_id)

        print(f"validated Creating contact for blind_id: {blind_id}, name: {name}, relation: {relation}")
        # Create contact if validation passes
        contact_model.create_contact(blind_id, name, relation, age, gender, created_at)
        return jsonify({'message': 'Contact created'}), 201

    except ValueError as ve:
        return jsonify({'error': str(ve)}), 400
    except Exception as e:
        print("Error creating contact:", e)
        return jsonify({'error': 'Something went wrong', 'details': str(e)}), 500


@contact_routes.route('/<int:contact_id>', methods=['PUT'])
def update_contact(contact_id):
    data = request.json
    contact_model.update_contact(contact_id, data['name'], data['relation'], data['user_id'])
    return jsonify({'message': 'Contact updated'})


@contact_routes.route('/<int:contact_id>', methods=['DELETE'])
def delete_contact(contact_id):
    contact_model.delete_contact(contact_id)
    return jsonify({'message': 'Contact deleted'})


@contact_routes.route('/user/<int:user_id>', methods=['GET'])
def get_contacts_by_user(user_id):
    contacts = contact_model.get_contacts_by_user(user_id)
    return jsonify([
        {
            'id': r[0],
            'name': r[1],
            'relation': r[2],
            'age': r[3],
            'gender': r[4],
            'created_at': r[5],
            'pic': r[6]
        }
        for r in contacts
    ])


@contact_routes.route('/blind/<blind_name>', methods=['GET'])
def get_contacts_by_blind_name(blind_name):
    contacts = contact_model.get_contacts_by_blind_name(blind_name)
    return jsonify([{'id': r[0], 'name': r[1], 'relation': r[2], 'user_id': r[3]} for r in contacts])


@contact_routes.route('/search', methods=['GET'])
def search_contacts():
    relation = request.args.get('relation')
    results = contact_model.search_contacts_by_relation(relation)
    return jsonify([{'id': r[0], 'name': r[1], 'relation': r[2], 'user_id': r[3]} for r in results])


@contact_routes.route('/count/<int:user_id>', methods=['GET'])
def count_contacts(user_id):
    count = contact_model.count_contacts_for_user(user_id)
    return jsonify({'user_id': user_id, 'contact_count': count})


@contact_routes.route('/relations/<int:user_id>', methods=['GET'])
def get_relations(user_id):
    relations = contact_model.get_distinct_relations_by_user(user_id)
    return jsonify([r[0] for r in relations])


# ===== For all users =====
@contact_routes.route('/relations', methods=['GET'])
def get_relations_by_user():
    relations = contact_model.get_all_distinct_relations()
    return jsonify([r[0] for r in relations])


# ====== CONTACT PICS ======
@contact_routes.route('/contact-pics', methods=['GET'])
def get_all_pics():
    pics = pics_model.get_all_pics()
    return jsonify([{'id': p[0], 'image_path': p[1], 'embedding': p[2], 'contact_id': p[3]} for p in pics])


@contact_routes.route('/contact-pics', methods=['POST'])
def create_pic():
    data = request.form
    image_path = data['image_path']
    contact_id = data['contact_id']
    if not image_path or not contact_id:
        return jsonify({'error': 'image_path and contact_id are required'}), 400
    try:
        pics_model.create_pic(image_path, int(contact_id))
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    return jsonify({'message': 'Picture created'}), 201


@contact_routes.route('/contact-pics/<int:pic_id>', methods=['PUT'])
def update_pic(pic_id):
    data = request.form
    image_path = data.get('image_path')
    embedding = data.get('embedding')
    contact_id = data.get('contact_id')
    try:
        pics_model.update_pic(
            pic_id,
            image_path=image_path,
            embedding=embedding,
            contact_id=int(contact_id) if contact_id else None
        )
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    return jsonify({'message': 'Picture updated'})


@contact_routes.route('/contact-pics/<int:pic_id>', methods=['DELETE'])
def delete_pic(pic_id):
    pics_model.delete_pic(pic_id)
    return jsonify({'message': 'Picture deleted'})


@contact_routes.route('/contact-pics/contact/<int:contact_id>', methods=['GET'])
def get_pics_by_contact(contact_id):
    pics = pics_model.get_pics_by_contact(contact_id)
    return jsonify([{'id': p[0], 'image_path': p[1], 'embedding': p[2]} for p in pics])


# ====== COMBINED ======
@contact_routes.route('/with-pics', methods=['GET'])
def get_contacts_with_pics():
    rows = pics_model.get_contacts_with_pics()
    contacts = {}
    for row in rows:
        contact_id = row[0]
        if contact_id not in contacts:
            contacts[contact_id] = {
                'id': contact_id,
                'name': row[1],
                'relation': row[2],
                'blind_id': row[3],
                'pics': []
            }
        if row[4]:  # pic exists
            contacts[contact_id]['pics'].append({
                'pic_id': row[4],
                'image_path': row[5],
                'embedding': row[6]
            })
    return jsonify(list(contacts.values()))


@contact_routes.route('/with-one-pic', methods=['GET'])
def get_contacts_with_one_pic():
    rows = pics_model.get_contacts_with_pics()
    contacts = {}
    for row in rows:
        contact_id = row[0]
        if contact_id not in contacts:
            contacts[contact_id] = {
                'id': contact_id,
                'name': row[1],
                'relation': row[2],
                'blind_id': row[3],
                'pic': None
            }
        # assign only first pic
        if row[4] and contacts[contact_id]['pic'] is None:
            contacts[contact_id]['pic'] = {
                'pic_id': row[4],
                'image_path': row[5],
                'embedding': row[6]
            }
    return jsonify(list(contacts.values()))


# ====== COMBINED BY BLIND ID ======
@contact_routes.route('/<int:blind_id>/with-pics', methods=['GET'])
def get_contacts_with_pics_by_blind(blind_id):
    rows = pics_model.get_contacts_with_pics_by_blindid(blind_id)
    contacts = {}
    for row in rows:
        contact_id = row[0]  # contact_id
        if contact_id not in contacts:
            contacts[contact_id] = {
                'id': contact_id,
                'name': row[1],
                'relation': row[2],
                'age': row[3],
                'gender': row[4],
                'blind_id': row[5],
                'pics': []
            }
        if row[6]:  # pic exists
            contacts[contact_id]['pics'].append({
                'contact_id': contact_id,  # include contact_id inside each pic
                'pic_id': row[6],
                'pic_path': row[7]
            })
    return jsonify(list(contacts.values()))


@contact_routes.route('/<int:blind_id>/with-one-pic', methods=['GET'])
def get_contacts_with_one_pic_by_blind(blind_id):
    rows = pics_model.get_contacts_with_pics_by_blindid(blind_id)
    contacts = {}
    for row in rows:
        contact_id = row[0]
        if contact_id not in contacts:
            contacts[contact_id] = {
                'id': contact_id,  # contact id at top
                'name': row[1],
                'relation': row[2],
                'age': row[3],
                'gender': row[4],
                'blind_id': row[5],
                'pic': None
            }
        # assign only first pic
        if row[6] and contacts[contact_id]['pic'] is None:
            contacts[contact_id]['pic'] = {
                'pic_id': row[6],
                'pic_path': row[7]
            }
    return jsonify(list(contacts.values()))



@contact_routes.route('/create-with-pics', methods=['POST'])
def create_contact_with_pics():
    blind_id = int(request.form["blind_id"])
    name = request.form["name"].strip()
    relation = request.form["relation"].strip()
    age = int(request.form["age"])
    gender = request.form["gender"].strip()
    created_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    contact_id = contact_model.create_contact(blind_id, name, relation, age, gender, created_at)

    files = request.files.getlist("images")
    saved_files = ImageService.save_contact_images(files, contact_id)

    return jsonify({
        "message": "Contact created",
        "contact_id": contact_id,
        "saved_images": saved_files
    }), 201