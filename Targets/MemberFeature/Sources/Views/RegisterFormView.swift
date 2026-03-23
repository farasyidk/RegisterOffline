import SwiftUI
import Core
import DesignSystem

public struct RegisterFormView: View {
    @StateObject private var viewModel: RegisterViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // State for navigation / presentation
    @State private var showingCamera = false
    @State private var showToast = false
    @State private var toastMessage = "Draft berhasil disimpan"
    @State private var confirmingImage: UIImage? = nil
    
    public init(viewModel: RegisterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Header section with alert
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Data Utama")
                            .font(.headline)
                            .foregroundColor(Color.brandDarkBlue)
                        
                        HStack(alignment: .top) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(Color.brandDarkBlue)
                            Text("Nomor Handphone, NIK, Foto KTP, dan Foto Diri wajib diisi sebelum disimpan / di-upload")
                                .font(.footnote)
                                .foregroundColor(Color.brandDarkBlue)
                        }
                        .padding()
                        .background(Color.brandDarkBlue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    FormTextField(label: "Nomor Handphone", placeholder: "Masukkan nomor handphone", text: $viewModel.phoneNumber, isMandatory: true, keyboardType: .numberPad)
                    
                    FormTextField(label: "NIK", placeholder: "16 digit no KTP", text: $viewModel.nik, isMandatory: true, keyboardType: .numberPad)
                    
                    // KTP Photos Upload
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 2) {
                            Text("Foto KTP")
                                .font(.footnote)
                                .foregroundColor(.darkGrayText)
                            Text("*")
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                        Text("Ambil 2 foto KTP untuk hasil yang lebih baik. Pastikan KTP terlihat jelas dan tidak blur.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            // Slot 1
                            if viewModel.ktpPaths.count > 0 {
                                ImagePreviewSlot(path: viewModel.ktpPaths[0]) {
                                    viewModel.ktpPaths.remove(at: 0)
                                }
                            } else {
                                PhotoUploadBox { showingCamera = true }
                            }
                            
                            // Slot 2
                            if viewModel.ktpPaths.count > 1 {
                                ImagePreviewSlot(path: viewModel.ktpPaths[1]) {
                                    viewModel.ktpPaths.remove(at: 1)
                                }
                            } else {
                                PhotoUploadBox { showingCamera = true }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Informasi Lainnya
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Informasi Lainnya")
                            .font(.headline)
                            .foregroundColor(Color.brandDarkBlue)
                        
                        FormTextField(label: "Nama Lengkap", placeholder: "Masukkan nama sesuai KTP", text: $viewModel.fullName)
                        FormTextField(label: "Tempat Lahir", placeholder: "Masukkan tempat lahir sesuai KTP", text: $viewModel.birthPlace)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tanggal Lahir").font(.footnote).foregroundColor(.darkGrayText)
                            DatePicker("", selection: $viewModel.birthDate, displayedComponents: .date)
                                .labelsHidden()
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(UIColor.systemGray4), lineWidth: 1))
                        }
                        
                        FormDropdown(label: "Jenis Kelamin", placeholder: "Pilih jenis kelamin", selection: $viewModel.gender, options: viewModel.genders)
                        FormDropdown(label: "Status", placeholder: "Pilih status sesuai KTP", selection: $viewModel.status, options: viewModel.maritalStatuses)
                        FormDropdown(label: "Pekerjaan", placeholder: "Pilih pekerjaan sesuai KTP", selection: $viewModel.occupation, options: viewModel.occupations)
                    }
                    
                    Divider()
                    
                    // Informasi Alamat KTP
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Informasi Alamat KTP")
                            .font(.headline)
                            .foregroundColor(Color.brandDarkBlue)
                        
                        FormTextField(label: "Alamat Lengkap", placeholder: "Masukkan alamat sesuai KTP", text: $viewModel.ktpAddress)
                        FormDropdown(label: "Provinsi", placeholder: "Pilih Provinsi", selection: $viewModel.ktpProvince, options: viewModel.provinces)
                        FormDropdown(label: "Kota/Kabupaten", placeholder: "Pilih Kota/Kabupaten", selection: $viewModel.ktpCity, options: viewModel.cities)
                        FormDropdown(label: "Kecamatan", placeholder: "Pilih Kecamatan", selection: $viewModel.ktpDistrict, options: viewModel.districts)
                        FormDropdown(label: "Kelurahan", placeholder: "Pilih Kelurahan", selection: $viewModel.ktpVillage, options: viewModel.villages)
                        FormTextField(label: "Kode Pos", placeholder: "Masukkan Kode Pos", text: $viewModel.ktpPostalCode, keyboardType: .numberPad)
                    }
                    
                    Divider()
                    
                    // Alamat Domisili
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Alamat Domisili")
                            .font(.headline)
                            .foregroundColor(Color.brandDarkBlue)
                        
                        Button(action: {
                            viewModel.isDomicileSameAsKtp.toggle()
                        }) {
                            HStack {
                                Image(systemName: viewModel.isDomicileSameAsKtp ? "checkmark.square.fill" : "square")
                                    .foregroundColor(viewModel.isDomicileSameAsKtp ? Color.brandDarkBlue : .gray)
                                Text("Alamat domisili sama dengan alamat pada KTP")
                                    .font(.footnote)
                                    .foregroundColor(.darkGrayText)
                            }
                        }
                        
                        if !viewModel.isDomicileSameAsKtp {
                            FormTextField(label: "Alamat Lengkap", placeholder: "Masukkan alamat domisili", text: $viewModel.domicileAddress)
                            FormDropdown(label: "Provinsi", placeholder: "Pilih Provinsi", selection: $viewModel.domicileProvince, options: viewModel.provinces)
                            FormDropdown(label: "Kota/Kabupaten", placeholder: "Pilih Kota/Kabupaten", selection: $viewModel.domicileCity, options: viewModel.cities)
                            FormDropdown(label: "Kecamatan", placeholder: "Pilih Kecamatan", selection: $viewModel.domicileDistrict, options: viewModel.districts)
                            FormDropdown(label: "Kelurahan", placeholder: "Pilih Kelurahan", selection: $viewModel.domicileVillage, options: viewModel.villages)
                            FormTextField(label: "Kode Pos", placeholder: "Masukkan Kode Pos", text: $viewModel.domicilePostalCode, keyboardType: .numberPad)
                        }
                    }
                    
                    // Buttons
                    VStack(spacing: 12) {
                        PrimaryButton(title: "Upload", action: {
                            Task { await viewModel.uploadToServer() }
                        }, isDisabled: !viewModel.isFormValid)
                        
                        PrimaryButton(title: "Simpan sebagai Draft", action: {
                            Task { await viewModel.saveDraft() }
                        }, isDisabled: !viewModel.isFormValid, isOutlined: true)
                    }
                    .padding(.vertical, 20)
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            } // Scrollview
            .padding(.top, 60) // Add top padding to account for the custom navigation bar
            
            // Navigation Bar
            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "arrow.left").foregroundColor(.black)
                    }
                    Text("Tambah Data")
                        .font(.headline)
                        .padding(.leading, 8)
                    Spacer()
                }
                .padding()
                .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.top ?? 0)
                .background(Color.white)
                Divider()
            }
            .ignoresSafeArea(edges: .top)
            
            // Toast notification
            if showToast {
                VStack {
                    HStack {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        Text(toastMessage)
                            .font(.footnote)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.top, 100)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }
        } // ZStack
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView { capturedImage in
                showingCamera = false
                confirmingImage = capturedImage
            }
        }
        .fullScreenCover(item: Binding<IdentifiableImage?>(
            get: { confirmingImage.map { IdentifiableImage(image: $0) } },
            set: { confirmingImage = $0?.image }
        )) { wrapper in
            PhotoConfirmationView(
                image: wrapper.image,
                onConfirm: {
                    let filename = UUID().uuidString + ".jpg"
                    if let path = try? LocalImageManager.shared.saveImage(wrapper.image, fileName: filename) {
                        viewModel.addKtpPhotoPath(path)
                    }
                    confirmingImage = nil
                },
                onRetake: {
                    confirmingImage = nil
                    // Slight delay to allow presentation dismissal, then reopen camera
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showingCamera = true
                    }
                }
            )
        }
        .onChange(of: viewModel.isSavedSuccessfully) { _, success in
            if success {
                toastMessage = "Draft berhasil disimpan"
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { showToast = false }
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onChange(of: viewModel.isUploadSuccessfully) { _, success in
            if success {
                toastMessage = "Data berhasil diunggah ke server!"
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { showToast = false }
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

// Helper wrapper for fullScreenCover to use image
struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// Subview for Image preview with delete button
struct ImagePreviewSlot: View {
    let path: String
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = LocalImageManager.shared.loadImage(from: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            } else {
                RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)).frame(height: 100)
            }
            
            Button(action: {
                LocalImageManager.shared.deleteImage(at: path)
                onDelete()
            }) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            .padding(4)
        }
    }
}

extension Color {
    static let darkGrayText = Color(UIColor.darkGray)
}
