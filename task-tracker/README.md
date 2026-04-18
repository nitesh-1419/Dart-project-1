# 🚀 Dart CLI Task-Tracker - Professional Deployment Guide

You don&#39;t "deploy" pure Dart CLI projects like Flutter apps—but you **can** package, share, and host them professionally! 

## 📱 About This Project

**Task-Tracker CLI**: Full-featured console todo app built in pure Dart.
- ✅ Add tasks
- 📋 View tasks  
- ✔️ Mark complete
- 🗑️ Delete tasks
- 🔽 Sort by priority (High/Medium/Low)

**Run it:**
```bash
dart run lib/main.dart
```

---

## 🔥 1. Run Locally (Basic)

```bash
dart run lib/main.dart
```

---

## 📦 2. Compile to Executable (.exe / binary) - **BEST FOR DEPLOYMENT**

### Windows (.exe)
```bash
dart compile exe lib/main.dart -o task-tracker.exe
```

### Linux/Mac
```bash
dart compile exe lib/main.dart -o task-tracker
```

**Now share the .exe file - runs **without Dart installed**!**

---

## 📁 3. Package Project

```
dart-task-tracker/
├── lib/main.dart
├── README.md
├── pubspec.yaml
├── task-tracker.exe
└── run.bat
```

**Zip it:**
```bash
zip -r task-tracker.zip dart-task-tracker/
```

---

## 🌐 4. GitHub Deployment (RESUME READY)

Repo: https://github.com/nitesh-1419/Dart-project-1

**Commands executed:**
```bash
git add .
git commit -m "Deploy Dart CLI Task-Tracker with exe"
git push
```

👉 **Portfolio perfect for recruiters!**

---

## 🐳 6. Docker (Pro)

**Dockerfile:**
```dockerfile
FROM dart:stable
COPY . /app
WORKDIR /app
RUN dart compile exe lib/main.dart -o task-tracker
CMD ["./task-tracker"]
```

**Build &amp; Run:**
```bash
docker build -t task-tracker .
docker run task-tracker
```

---

## 💼 run.bat (Windows Easy Run)

```bat
@echo off
task-tracker.exe
pause
```

---

## 🎯 Resume Bullet (Copy-Paste)

> "Developed **Dart CLI Task-Tracker** - full-featured todo app with priority sorting. Compiled to standalone Windows executable (.exe) and deployed to GitHub repository with Docker support."

---

## 📸 Demo

```
==== TO-DO MENU ====
1. Add Task          2. View Tasks
3. Mark Complete     4. Delete Task  
5. Sort by Priority  6. Exit

> Buy groceries (high)  ✅
> Call mom (medium)     ❌  
```

**Deployed &amp; Ready! 🚀**

---

**Next Level?** Say "make portfolio pro" for GitHub workflows/CI/CD.
