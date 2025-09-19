# Clinique Paie - Regenerated Project

Ce projet est généré d'après les annexes fournies (cas d'utilisation dans Sythèse.docx). 
Il contient:
- backend/ : Node.js + Express + MongoDB (personnel CRUD, auth, payment stub for Airtel)
- frontend/ : Flutter app (registration, login, manage personnel, initiate payment)
- README.md (this file) and .env.example for backend

Important notes:
- Airtel Money integration is simulated. Replace payment route in backend/routes/payment.js with real Airtel API calls and secure credentials.
- For Android emulator use `10.0.2.2` to reach localhost backend. For real device change backend URLs to your server.
- The app includes account creation (register endpoint) and personnel management matching the annex 'Cas d'utilisation'.
