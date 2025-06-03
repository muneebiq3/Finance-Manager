import torch
import pandas as pd
import pickle
from transformers import BertTokenizer, BertForSequenceClassification
from torch.utils.data import DataLoader, Dataset, random_split
from torch.optim import AdamW
import torch.nn.functional as F
from sklearn.utils.class_weight import compute_class_weight
import numpy as np

# 🚀 Load the expanded dataset
df = pd.read_csv("C:/Users/Abid computers/Desktop/finance_manager_backend/expenses_dataset.csv")

# 🔄 Map categories to numeric labels
category_map = {category: idx for idx, category in enumerate(df["Category"].unique())}
df["Label"] = df["Category"].map(category_map)

# ✅ Save category mapping for Flask API
with open("../saved_models/category_map.pkl", "wb") as f:
    pickle.dump(category_map, f)

# 🔥 Tokenizer (BERT-base)
tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")

# 📌 Custom Dataset Class
class ExpenseDataset(Dataset):
    def __init__(self, texts, labels):
        self.texts = texts
        self.labels = labels

    def __len__(self):
        return len(self.texts)

    def __getitem__(self, idx):
        encoding = tokenizer(
            self.texts[idx], 
            padding="max_length", 
            truncation=True, 
            max_length=64,  # Increased max_length for better understanding
            return_tensors="pt"
        )
        return {
            "input_ids": encoding["input_ids"].squeeze(),
            "attention_mask": encoding["attention_mask"].squeeze(),
            "labels": torch.tensor(self.labels[idx], dtype=torch.long)
        }

# 🎯 Create dataset
dataset = ExpenseDataset(df["Expense"].tolist(), df["Label"].tolist())

# 📊 Compute class weights for imbalanced categories
class_weights = compute_class_weight(
    class_weight="balanced",
    classes=np.unique(df["Label"]),
    y=df["Label"]
)
class_weights = torch.tensor(class_weights, dtype=torch.float)

# 🏋️ Split into train & validation sets
train_size = int(0.85 * len(dataset))  # 85% Train, 15% Validation
train_dataset, val_dataset = random_split(dataset, [train_size, len(dataset) - train_size])

# 🚚 DataLoaders
train_loader = DataLoader(train_dataset, batch_size=16, shuffle=True)  # Batch increased to 16
val_loader = DataLoader(val_dataset, batch_size=16, shuffle=False)

# 🧠 Load BERT Model (Fine-tuned for Classification)
model = BertForSequenceClassification.from_pretrained("bert-base-uncased", num_labels=len(category_map))

# 🛠️ Define Optimizer & Loss Function
optimizer = AdamW(model.parameters(), lr=3e-5, eps=1e-8)  # Improved optimizer
loss_fn = torch.nn.CrossEntropyLoss(weight=class_weights)  # Handles category imbalance

# 🚀 Training Function
def train_model(epochs=25):  # Increased to 25 epochs for better learning
    model.train()
    for epoch in range(epochs):
        total_loss = 0
        correct, total = 0, 0
        
        for batch in train_loader:
            optimizer.zero_grad()
            outputs = model(
                input_ids=batch["input_ids"],
                attention_mask=batch["attention_mask"],
                labels=batch["labels"]
            )
            loss = loss_fn(outputs.logits, batch["labels"])
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
            
            # 🔄 Compute training accuracy
            predicted = torch.argmax(outputs.logits, dim=1)
            correct += (predicted == batch["labels"]).sum().item()
            total += batch["labels"].size(0)

        train_accuracy = correct / total * 100
        avg_loss = total_loss / len(train_loader)
        print(f"Epoch {epoch+1} | Loss: {avg_loss:.4f} | Training Accuracy: {train_accuracy:.2f}%")

        # 🏆 Validation Step
        model.eval()
        correct, total = 0, 0
        with torch.no_grad():
            for batch in val_loader:
                outputs = model(
                    input_ids=batch["input_ids"], 
                    attention_mask=batch["attention_mask"]
                )
                predicted = torch.argmax(outputs.logits, dim=1)
                correct += (predicted == batch["labels"]).sum().item()
                total += batch["labels"].size(0)

        accuracy = correct / total * 100
        print(f"✅ Validation Accuracy: {accuracy:.2f}%\n")
        model.train()

# 🚀 Train the model
train_model()

# 💾 Save Model
torch.save(model.state_dict(), "../saved_models/bert_model.pth")
print("🎉 Model training complete and saved!")
