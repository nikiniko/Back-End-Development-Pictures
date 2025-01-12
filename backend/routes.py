from . import app
import os
import json
from flask import jsonify, request, make_response, abort, url_for  # type: ignore # noqa; F401

SITE_ROOT = os.path.realpath(os.path.dirname(__file__))
json_url = os.path.join(SITE_ROOT, "data", "pictures.json")
data: list = json.load(open(json_url))

######################################################################
# RETURN HEALTH OF THE APP
######################################################################


@app.route("/health")
def health():
    return jsonify(dict(status="OK")), 200

######################################################################
# COUNT THE NUMBER OF PICTURES
######################################################################


@app.route("/count")
def count():
    """return length of data"""
    if data:
        return jsonify(length=len(data)), 200

    return {"message": "Internal server error"}, 500


######################################################################
# GET ALL PICTURES
######################################################################
@app.route("/picture", methods=["GET"])
def get_pictures():
    return jsonify(data), 200

######################################################################
# GET A PICTURE
######################################################################


@app.route("/picture/<int:id>", methods=["GET"])
def get_picture_by_id(id):
    for picture in data:
        if picture['id'] == id:
            return picture, 200
    return {"message": "Picture not found"}, 404


######################################################################
# CREATE A PICTURE
######################################################################
@app.route("/picture", methods=["POST"])
def create_picture():
    new_picture = request.get_json()

    if not new_picture:
        return {"message": "Invalid input parameter"}, 422
    
    try:

        for picture in data:
            if picture['id'] == new_picture['id']:
                return {"message": f"Picture with id {new_picture['id']} already present"}, 302
        
        data.append(new_picture)
        return new_picture, 201
    
    except NameError:
        return {"message": "data not defined"}, 500

######################################################################
# UPDATE A PICTURE
######################################################################


@app.route("/picture/<int:id>", methods=["PUT"])
def update_picture(id):
    change_picture = request.get_json()

    if not change_picture:
        return {"message": "Invalid input parameter"}, 422
    
    try:

        for i, picture in enumerate(data):
            if picture['id'] == change_picture['id']:
                data[i] = change_picture
                return {"message": f"picture with id {change_picture['id']} updated successfully"}, 200
            
        return {"message": f"picture with id {change_picture['id']} not found"}, 404
    
    except NameError:
        return {"message": "data not defined"}, 500


######################################################################
# DELETE A PICTURE
######################################################################
@app.route("/picture/<int:id>", methods=["DELETE"])
def delete_picture(id):
    try:

        for picture in data:
            if picture['id'] == id:
                data.remove(picture)
                return {"message": f"picture with id {picture['id']} deleted successfully"}, 204
            
        return {"message": "picture not found"}, 404
    
    except NameError:
        return {"message": "data not defined"}, 500