# 🎮 Gotcha - O'zbekcha Random Shartlar va Tanlov O'yini

Ushbu loyiha mashhur **Gotcha / Chwazi (Finger Chooser)** o'yini asosida Flutter va zamonaviy neon dizaynda ishlab chiqilgan.

---

## 🌟 O'yin qoidalari va imkoniyatlari

1. **Kirish ekrani (Savollar sonini tanlash):**
   - O'yinga kirishda **"O'yin nechta savolli bo'lsin?"** deb so'raladi.
   - 4 ta tanlov tugmasi: **20 ta**, **30 ta**, **50 ta** va **Boshqa...**
   - **Boshqa...** tugmasi bosilganda foydalanuvchi o'zi xohlagan ixtiyoriy sonni (masalan: 10, 15, 40 va h.k.) kiritadi.
   - Tanlangan son bo'yicha `assets/questions.json` bazasidan **bir xil bo'lmagan (takrorlanmas)** random savollar saralanadi.

2. **Gotcha multi-touch ekrani:**
   - 2 yoki undan ortiq odam barmog'ini smartfon ekraniga bosib turadi.
   - Har bir barmoq tekkanda o'zining yorqin neon rangi, kengayuvchi to'lqinlar va pulsatsiyalar paydo bo'ladi.
   - Kamida 2 ta barmoq tekkanda 2.4 soniyalik aylanma taymer ishga tushadi.
   - Taymer to'lgach, tasodifiy **bitta g'olib / shart bajaruvchi** tanlanadi (neon portlash effekti, haptic vibratsiya va tovush bilan).

3. **Shart / Savol ekrani:**
   - Tanlangan odamga saralangan ro'yxatdan navbatdagi random shart ochiladi.
   - Toifalar: *Tezkor fikrlash ⚡, Kulgili shartlar 😂, Savol-javob 💬, Taqlid va aktyorlik 🎭, Do'stlar va davra 🤝, Kreativ topshiriqlar 💡*.
   - **Agar shart vaqtli bo'lsa:**
     - **"Shartni boshlash (X soniya)"** tugmasi turadi.
     - Tugma bosilgach, aylanma taymer orqaga hisoblaydi.
     - Taymer ostida **"Tugatdim"** (yashil) va **"Yutqazdim"** (qizil) tugmalari bo'ladi.
     - Vaqt 0 ga yetganda shart avtomatik tugatilgan hisoblanadi.
   - **Agar shart vaqtsiz bo'lsa:**
     - To'g'ridan-to'g'ri "Tugatdim" va "Yutqazdim" tugmalari chiqadi.
   - **"O'yinga qaytish"** tugmasi orqali yana Gotcha ekraniga qaytiladi va keyingi raund boshlanadi.

4. **O'yin yakunlanishi:**
   - Barcha N ta savol tugagach, yakuniy statistika ekrani (nechta shart bajarildi, nechta yutqazildi) va qaytadan o'ynash tugmalari chiqadi.

---

## 📁 Loyiha tuzilmasi

```
Gotcha Game/
├── assets/
│   └── questions.json            # O'zbek tilidagi barcha toifadagi savollar bazasi
├── lib/
│   ├── main.dart                 # Flutter ilovaning kirish nuqtasi
│   ├── models/
│   │   └── question.dart         # Savol va Toifalar modeli
│   ├── services/
│   │   ├── question_service.dart # Savollarni random saralash va o'yin holati
│   │   └── sound_service.dart    # Vibratsiya (Haptics) va tovushlar
│   ├── screens/
│   │   ├── start_screen.dart     # 20, 30, 50, Boshqa... sonini tanlash
│   │   ├── gotcha_game_screen.dart # Multi-touch sensor Gotcha o'yin maydoni
│   │   ├── challenge_screen.dart # Shart kartasi, taymer va tugmalar
│   │   └── game_over_screen.dart # Natijalar va yakuniy statistika
│   └── widgets/
│       ├── neon_button.dart      # Zamonaviy neon tugma vidjeti
│       └── touch_canvas.dart     # Barmoqlar aylanasi va zarrachalar CustomPainter
├── pubspec.yaml                  # Flutter kutubxonalari va aktivlar
├── index.html                    # Brauzerda tezkor sinab ko'rish uchun veb-versiya
└── README.md
```

---

## 🚀 Ilovani ishga tushirish

### 1. Flutter orqali (Android / iOS / Web):
```bash
flutter pub get
flutter run
```

### 2. Brauzerda to'g'ridan-to'g'ri sinab ko'rish:
Loyihaning ildiz papkasidagi `index.html` faylini istalgan brauzerda (Chrome, Edge, Safari) ochishingiz mumkin. Unda multi-touch, neon animatsiyalar, sintetik tovushlar va to'liq o'zbekcha shartlar bazasi darhol ishlaydi!

