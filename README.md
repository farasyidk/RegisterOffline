# RegisterOffline

Aplikasi iOS untuk pendaftaran anggota secara offline dengan kemampuan sinkronisasi otomatis saat koneksi internet tersedia.

Demo application: [video](https://drive.google.com/drive/folders/1PambYbY7CXPF9DIJYb6LZTIizCnuA3Zf?usp=sharing)
---

## Persyaratan

| Kebutuhan | Versi Minimum |
|---|---|
| Xcode | 16.0+ |
| iOS Deployment Target | 17.6+ |
| [Tuist](https://tuist.io) | 4.x |

---

## Setup Awal

### 1. Clone Repositori

```bash
git clone https://github.com/farasyidk/RegisterOffline.git
cd RegisterOffline
```

### 2. Install Tuist

Jika Tuist belum terinstall, jalankan:

```bash
curl -Ls https://install.tuist.io | bash
```

### 3. Konfigurasi Environtment (xcconfig)

Proyek menggunakan file `.xcconfig` untuk memisahkan konfigurasi per environment. Buat file konfigurasi dari template yang tersedia:

```bash
# Untuk environment Test (Debug)
cp Targets/App/example.xcconfig Targets/App/Test.xcconfig
```

Isi file `Targets/App/Test.xcconfig` sesuai environment:

```
BASE_URL = https://api-test.example.com
APP_NAME = Register Offline Test
APP_BUNDLE_ID = com.yourcompany.registeroffline.test
```

Untuk environment Production, buat file `Targets/App/Prod.xcconfig` dengan isi serupa.

> **Catatan:** File `Test.xcconfig` dan `Prod.xcconfig` **tidak di-commit** ke Git. Gunakan `example.xcconfig` sebagai referensi.

### 4. Generate Project Xcode

```bash
tuist generate
```

Perintah ini akan men-generate file `RegisterOffline.xcodeproj` dan `RegisterOffline.xcworkspace` berdasarkan `Project.swift`.

### 5. Buka di Xcode

```bash
open RegisterOffline.xcworkspace
```

---

## Cara Menjalankan

1. Pilih **scheme** yang sesuai di Xcode:
   - **Test** — menggunakan konfigurasi `Debug` / `Test.xcconfig`
   - **Production** — menggunakan konfigurasi `Release` / `Prod.xcconfig`
2. Pilih **simulator** atau **perangkat fisik** sebagai target.
3. Tekan **⌘ + R** untuk build dan menjalankan aplikasi.

> **Kamera:** Fitur kamera (foto KTP) hanya berfungsi di **perangkat fisik**. Simulator tidak mendukung akses kamera.

---

## Struktur Proyek

Proyek ini dikelola menggunakan **[Tuist](https://tuist.io)** dengan arsitektur modular. Setiap modul adalah framework independen yang dikonfigurasi di `Project.swift`.

```
RegisterOffline/
├── Project.swift                  # Definisi proyek & modul (Tuist)
├── Targets/
│   ├── App/                       # 🚀 Entry point aplikasi
│   │   ├── Sources/
│   │   │   ├── App.swift          # Root SwiftUI App & dependency injection
│   │   │   └── Views/
│   │   │       └── SplashView.swift
│   │   ├── Resources/             # Asset app (ikon, launch screen)
│   │   ├── Test.xcconfig          # Konfigurasi environment Test (tidak di-commit)
│   │   ├── Prod.xcconfig          # Konfigurasi environment Production (tidak di-commit)
│   │   └── example.xcconfig       # Template konfigurasi
│   │
│   ├── CoreProtocol/              # 📋 Protokol & kontrak antara modul
│   │   └── Sources/
│   │       ├── AppConfig.swift            # Konfigurasi global (BASE_URL, dll.)
│   │       ├── Models/
│   │       │   ├── AuthModels.swift       # Model data autentikasi
│   │       │   └── MemberEntity.swift     # SwiftData model untuk anggota
│   │       ├── Network/
│   │       │   └── NetworkServiceProtocol.swift
│   │       └── Repositories/
│   │           └── RepositoryProtocols.swift
│   │
│   ├── Core/                      # ⚙️  Implementasi layanan & infrastruktur
│   │   └── Sources/
│   │       ├── Network/
│   │       │   └── NetworkManager.swift   # HTTP client & penanganan request
│   │       ├── Repositories/
│   │       │   ├── AuthRepository.swift   # Implementasi auth (login/logout)
│   │       │   └── MemberRepository.swift # CRUD anggota + upload ke server
│   │       ├── Helpers/
│   │       │   └── String+Masking.swift   # Extension untuk masking string
│   │       ├── Utility/
│   │       │   └── KeychainTokenProvider.swift # Penyimpanan token di Keychain
│   │       └── Utils/
│   │           ├── AuthStateManager.swift # Manajemen state autentikasi global
│   │           └── LocalImageManager.swift # Penyimpanan gambar lokal di disk
│   │
│   ├── DesignSystem/              # 🎨 Komponen UI & token desain bersama
│   │   └── Sources/
│   │       ├── Colors.swift             # Palet warna adaptif (light/dark mode)
│   │       ├── DesignSystemAssets.swift # Akses aset gambar
│   │       ├── FormTextField.swift      # Input teks berstandar
│   │       ├── FormDropdown.swift       # Dropdown/picker berstandar
│   │       ├── PhotoUploadBox.swift     # Komponen upload foto
│   │       └── PrimaryButton.swift      # Tombol utama berstandar
│   │
│   ├── AuthFeature/               # 🔐 Fitur autentikasi (Login)
│   │   └── Sources/
│   │       ├── ViewModels/
│   │       │   └── AuthViewModel.swift
│   │       └── Views/
│   │           └── LoginView.swift
│   │
│   ├── MemberFeature/             # 👥 Fitur utama manajemen anggota
│   │   └── Sources/
│   │       ├── ViewModels/
│   │       │   ├── MemberDashboardViewModel.swift  # Logic dashboard + auto-sync
│   │       │   ├── RegisterViewModel.swift         # Logic form pendaftaran
│   │       │   └── PhotoConfirmationViewModel.swift
│   │       └── Views/
│   │           ├── MemberDashboardView.swift       # Halaman utama dashboard
│   │           ├── MemberDashboardView+Extensions.swift
│   │           ├── RegisterFormView.swift           # Form pendaftaran anggota baru
│   │           ├── CameraView.swift                 # Kamera untuk foto KTP
│   │           ├── PhotoConfirmationView.swift      # Konfirmasi foto KTP
│   │           ├── DraftTabView.swift               # Tab daftar draft
│   │           ├── SyncedTabView.swift              # Tab daftar tersinkronisasi
│   │           └── Components/
│   │               ├── DraftMemberCard.swift
│   │               ├── SyncedMemberCard.swift
│   │               ├── TabButton.swift
│   │               ├── UploadBottomSheet.swift
│   │               └── EmptyStateView.swift
│   │
│   └── ProfileFeature/            # 👤 Fitur profil & logout
       └── Sources/
           ├── ViewModels/
           │   └── ProfileViewModel.swift
           └── Views/
               ├── ProfileView.swift
               └── LogoutBottomSheet.swift

```

---

## Arsitektur

Proyek mengikuti pola **MVVM (Model-View-ViewModel)** dengan pemisahan tanggung jawab antar layer:

```
View  ──►  ViewModel  ──►  Repository  ──►  NetworkManager / SwiftData
 ▲               │
 └───── State ◄──┘
```

| Layer | Tanggung Jawab |
|---|---|
| **View** | Rendering UI, meneruskan aksi ke ViewModel |
| **ViewModel** | Business logic, state management (`@Observable`) |
| **Repository** | Abstraksi akses data (remote API + lokal SwiftData) |
| **Core** | Network, storage, utilities yang dapat digunakan ulang |
| **CoreProtocol** | Protokol & model bersama, memutus ketergantungan siklik |

### Fitur Utama

- **Offline-First:** Data anggota disimpan lokal menggunakan **SwiftData** sebelum disinkronisasi.
- **Auto-Sync:** Menggunakan `NWPathMonitor` untuk mendeteksi koneksi dan memicu sinkronisasi otomatis saat online.
- **Dependency Injection:** Repositori dan service diinjeksikan melalui konstruktor ViewModel.
- **Modular:** Setiap fitur adalah framework independen, mempercepat waktu kompilasi.

---

## Dependency Modul

```
App
 ├── Core ──────────── CoreProtocol
 ├── DesignSystem
 ├── AuthFeature ───── Core, CoreProtocol, DesignSystem
 ├── MemberFeature ─── Core, CoreProtocol, DesignSystem
 └── ProfileFeature ── Core, CoreProtocol, DesignSystem
```

---

## Konfigurasi API

Endpoint API dikontrol melalui `BASE_URL` di file `.xcconfig`. Nilai ini dibaca via `AppConfig` di modul `CoreProtocol`.
