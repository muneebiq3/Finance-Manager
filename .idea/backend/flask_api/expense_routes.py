from flask import Flask, request, jsonify
import torch
from transformers import BertTokenizer, BertForSequenceClassification
import pickle
from firebase_admin import credentials, initialize_app, firestore

app = Flask(__name__)

# Initialize Firebase
cred = credentials.Certificate("firebase_key.json")
initialize_app(cred)
db = firestore.client()

# Load Model and Tokenizer
model_path = "../saved_models/bert_model.pth"
category_map_path = "../saved_models/category_map.pkl"

# Load category map
with open(category_map_path, "rb") as f:
    category_map = pickle.load(f)
reverse_category_map = {v: k for k, v in category_map.items()}

# Load model with correct label size
model = BertForSequenceClassification.from_pretrained("bert-base-uncased", num_labels=len(category_map))
model.load_state_dict(torch.load(model_path, map_location=torch.device("cpu")))
model.eval()
tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")

@app.route("/categorize_expense", methods=["POST"])
def categorize_expense():
    data = request.json
    expense_text = data.get("expense")
    if not expense_text:
        return jsonify({"error": "Expense text is required"}), 400

    encoding = tokenizer(expense_text, padding="max_length", truncation=True, max_length=32, return_tensors="pt")
    with torch.no_grad():
        outputs = model(input_ids=encoding["input_ids"], attention_mask=encoding["attention_mask"])
        probs = torch.nn.functional.softmax(outputs.logits, dim=1)  # Convert to probabilities
        predicted_label = torch.argmax(probs).item()
        confidence = probs[0, predicted_label].item()  # Get confidence score

    category = reverse_category_map.get(predicted_label, "Unknown")
    return jsonify({"expense": expense_text, "category": category, "confidence": round(confidence, 2)})


@app.route("/track_goal_progress", methods=["GET"])
def track_goal_progress():
    user_id = request.args.get("user_id")
    goal_id = request.args.get("goal_id")
    current_month = request.args.get("current_month")  # Get the current month from the request

    if not user_id or not goal_id or not current_month:
        return jsonify({"error": "User ID, Goal ID, and Current Month are required"}), 400

    # Fetch the goal progress data from Firestore
    goal_ref = db.collection('users').document(user_id).collection('records').document(current_month).collection('savings_goals').document(goal_id)
    goal = goal_ref.get()

    if not goal.exists:
        return jsonify({"error": "Goal not found"}), 404

    goal_data = goal.to_dict()

    target_amount = goal_data.get("target_amount")
    amount_saved = goal_data.get("amount_saved")
    progress_percentage = (amount_saved / target_amount) * 100 if target_amount != 0 else 0

    # Add progress suggestion
    suggestion = ""
    if progress_percentage >= 100:
        suggestion = "Congratulations, you've reached your goal!"
    elif progress_percentage >= 75:
        suggestion = "You're almost there! Keep it up!"
    elif progress_percentage >= 50:
        suggestion = "You're halfway to your goal. Keep going!"
    else:
        suggestion = "You can do it! Stay focused!"

    return jsonify({
        "goal_name": goal_data.get("goal_name"),
        "target_amount": target_amount,
        "amount_saved": amount_saved,
        "progress_percentage": round(progress_percentage, 2),
        "suggestion": suggestion
    })



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
