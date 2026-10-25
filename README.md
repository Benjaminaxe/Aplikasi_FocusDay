# FocusDay - Aplikasi Jadwal Harian Terikat Kalender (Calendar-Bound)

Aplikasi Flutter produktivitas modern yang dirancang khusus untuk mencatat jadwal harian yang **terikat sepenuhnya dengan fitur Kalender**. Dilengkapi dengan 3 Kolom Kanban ("Harus Dikerjakan", "Sedang Dikerjakan", "Telah Selesai"), input suara cepat menggunakan `speech_to_text`, sistem notifikasi pengingat berbasis waktu lokal `flutter_local_notifications`, dan optimasi visual untuk layar 120Hz AMOLED POCO F7.

---

## 🌟 Fitur Utama

### 1. Integrasi Kalender Harian (Calendar-Bound)
- **Table Calendar Terintegrasi:** Kalender berada di bagian atas beranda dengan tampilan ringkas mingguan (*weekly view*) yang dapat di-*expand* menjadi bulanan (*monthly view*) secara mulus.
- **Normalisasi Tanggal 00:00:00:** Struktur data state dipetakan berdasarkan `DateTime` tanpa komponen jam (`normalizeDate(DateTime)`), menghasilkan pemetaan instan `Map<DateTime, List<TaskModel>>`.
- **Reaktivitas Otomatis Riverpod:** Setiap pergantian tanggal di kalender secara otomatis memicu pembaruan UI untuk menampilkan 3 kolom Kanban khusus tanggal terpilih.
- **Penanda Visual Soft (Event Dots):** Titik kecil lembut (*sage green* / *sand*) di bawah tanggal menandakan adanya tugas terjadwal di hari tersebut.

### 2. Manajemen Tugas & Input Suara (CRUD + Voice)
- **3 Kolom Kanban Dinamis:**
  - 📋 **Harus Dikerjakan** (*To Do*) - Aksen Slate Soft
  - ⏳ **Sedang Dikerjakan** (*In Progress*) - Aksen Sand / Warm Beige
  - ✅ **Telah Selesai** (*Done*) - Aksen Sage Green
- **Drag & Drop Antar Kolom:** Pindahkan tugas dengan menahan kartu (*long press drag*) dan menjatuhkannya ke kolom target dengan animasi responsif.
- **CRUD Lengkap:** Tambah tugas baru, edit teks judul & deskripsi, hapus tugas, dan atur prioritas (*Rendah, Sedang, Tinggi*).
- **Input Suara (Speech to Text):** Tombol mikrofon interaktif dengan animasi denyut (*pulsing ripple*) untuk mendiktekan rencana tugas secara langsung lewat suara bahasa Indonesia (`id_ID`).

### 3. Sistem Notifikasi & Optimasi POCO F7 (120Hz AMOLED)
- **Notifikasi Lokal Presisi:** Menggunakan `flutter_local_notifications` dan `timezone` untuk menjadwalkan alarm pengingat waktu lokal.
- **120Hz Smooth Scrolling:** Menggunakan `BouncingScrollPhysics`, `RepaintBoundary` pada kartu dan kalender, serta animasi *curve* ringan tanpa *jank*.
- **AMOLED Dark Mode:** Tema gelap pekat (*true deep charcoal* / `#0F1215`) yang hemat daya di layar AMOLED POCO F7 dan memanjakan mata.

### 4. Desain Visual Soft & Muted
- **Skema Warna Tenang:**
  - Latar belakang: *Soft grey* (`#F6F8F9`) / *AMOLED Dark* (`#0F1215`)
  - Tanggal aktif kalender: Lingkaran *soft sage green* (`#6B8F71`)
  - Hari libur / akhir pekan: *Muted red/pink pastel* (`#CF7B7B`) yang tidak menyilaukan mata
  - Progress bar kemajuan harian terintegrasi di papan Kanban.

---

## 🏗️ Struktur Arsitektur & Direktori

```
lib/
├── core/
│   ├── services/
│   │   ├── notification_service.dart   # FlutterLocalNotifications & Timezone scheduler
│   │   ├── speech_service.dart         # SpeechToText wrapper & locale handler
│   │   └── storage_service.dart        # SharedPreferences persistence & initial seed
│   ├── theme/
│   │   └── app_theme.dart              # Soft & muted color palette (Light + AMOLED Dark)
│   └── utils/
│       └── date_utils.dart             # Date normalization & Indonesian formatters
├── models/
│   └── task_model.dart                 # TaskModel, TaskStatus, TaskPriority, JSON encoders
├── providers/
│   ├── calendar_provider.dart          # Riverpod Notifier untuk tanggal & format kalender
│   ├── task_provider.dart              # Riverpod Notifier untuk Map<DateTime, List<TaskModel>>
│   └── theme_provider.dart             # Riverpod Notifier untuk tema (Light / Dark)
├── screens/
│   └── home_screen.dart                # Beranda utama menggabungkan Kalender & Kanban
├── widgets/
│   ├── calendar_header_widget.dart     # Widget kalender TableCalendar dengan custom soft builders
│   ├── kanban_board_widget.dart        # Papan 3 kolom dengan mode Tab & Board horizontal
│   ├── kanban_column_widget.dart       # Komponen kolom dengan DragTarget & list kartu
│   ├── task_card_widget.dart           # Kartu tugas interaktif, chip pengingat, & menu
│   └── task_form_dialog.dart           # Modal input/edit tugas & tombol mikrofon
└── main.dart                           # Entrypoint aplikasi dengan ProviderScope
```

---

## 🚀 Cara Menjalankan

### Menjalankan di Smartphone Android (POCO F7):
1. Hubungkan POCO F7 via USB Debugging.
2. Jalankan perintah:
   ```bash
   flutter run -d <device-id>
   ```

### Menjalankan di Desktop / Web:
```bash
flutter run -d windows
# atau
flutter run -d chrome
```

### Menjalankan Pengujian (Unit & Widget Tests):
```bash
flutter test
```
Semua test pengujian normalisasi tanggal, serialisasi model, dan *smoke test* widget telah divalidasi dan lulus 100%.
