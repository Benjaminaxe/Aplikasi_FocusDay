# Aturan Pengembangan - Integrasi Kalender Terikat

## Dependencies & Packages
- `table_calendar` (Untuk UI kalender yang fleksibel dan minimalis).
- `riverpod` & `flutter_riverpod` (State Management).
- `speech_to_text` (Input suara).
- `flutter_local_notifications` (Notifikasi pengingat).

## Arsitektur Data (Calendar Binding)
- Struktur data state/database harus dipetakan berdasarkan tanggal tanpa waktu (di-normalize ke jam 00:00:00), misalnya: `Map<DateTime, List<TaskModel>>`.
- Pastikan saat pengguna mengganti tanggal di kalender, Riverpod secara otomatis memicu pembaruan UI untuk menampilkan daftar tugas yang sesuai dengan tanggal tersebut.

## Desain Kalender & UI Constraints
- Kalender harus menggunakan skema warna soft: Tanggal aktif diwarnai bulat soft sage green tipis, tanggal biasa berwarna slate dark, dan hari libur tidak menggunakan warna merah menyala (gunakan warna muted red/pink pastel).
- Navigasi antar minggu/bulan harus menggunakan animasi geser horizontal yang sangat ringan dan responsif untuk mendukung layar 120Hz POCO F7.
