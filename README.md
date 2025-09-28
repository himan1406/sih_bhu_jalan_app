# 🌊 BHU-JALAN (SIH Project)

Bharat Hydro Underground Jal Analytics Network — a groundwater sustainability analytics platform.

---

## 📂 Project Structure
- `backend/` → FastAPI backend with Supabase + analytics + Docker
- `frontend/` → Flutter mobile app for visualizing groundwater data

---

## 🚀 Backend (FastAPI + Docker)
```bash
cd backend
docker build -t groundwater-api .
docker run -d -p 8000:8000 --env-file .env groundwater-api
