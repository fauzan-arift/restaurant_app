# Submission Proyek Aplikasi Restoran

Proyek ini merupakan bagian dari submission dengan tujuan membangun aplikasi daftar restoran yang terhubung ke API, dilengkapi dengan halaman detail, pengaturan tema, indikator loading, dan state management menggunakan **Provider**.

---

##  Fitur Utama

### 1. Halaman Daftar Restoran
- Menampilkan daftar restoran dari API.
- Informasi minimum yang ditampilkan:
  - Nama restoran
  - Gambar
  - Kota
  - Rating

### 2. Halaman Detail Restoran
- Menampilkan detail lengkap restoran berdasarkan pilihan user.
- Informasi yang ditampilkan:
  - Nama restoran
  - Gambar
  - Deskripsi
  - Kota
  - Alamat
  - Rating
  - Menu makanan & minuman

### 3. Tema Aplikasi
- Mendukung **tema terang** dan **tema gelap**.
- Mengganti **default font type**.
- Mengubah skema warna aplikasi selain bawaan default.

### 4. Indikator Loading
- Indikator loading muncul setiap kali ada pemanggilan API.
- Loading dapat berupa:
  - `CircularProgressIndicator`
  - Gambar animasi
  - Animasi Lottie atau Rive

### 5. State Management
- Menggunakan **Provider** sebagai state management.
- Seluruh state aplikasi dikelola oleh satu pendekatan konsisten.
- Mengimplementasikan **sealed class** untuk mengelola response dari Web API.

##  Teknologi yang Digunakan
- **Flutter** (framework utama)
- **Provider** (state management)
- **HTTP** (pemanggilan API)
- **Lottie / Rive** (opsional untuk animasi loading)
- **Google Fonts** (opsional untuk kustomisasi font)
