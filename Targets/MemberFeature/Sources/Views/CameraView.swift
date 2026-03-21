import SwiftUI
import AVFoundation
import UIKit

public struct CameraPreviewView: UIViewRepresentable {
    public let session: AVCaptureSession
    
    public init(session: AVCaptureSession) {
        self.session = session
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        #if targetEnvironment(simulator)
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let image = UIImage(named: "dummy_ktp.jpg") {
            imageView.image = image
        } else {
            imageView.backgroundColor = .systemGray
        }
        view.addSubview(imageView)
        #else
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        #endif
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {}
}

public class CameraController: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published public var session = AVCaptureSession()
    @Published public var capturedImage: UIImage? = nil
    @Published public var isSessionRunning = false
    
    private let output = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    public override init() {
        super.init()
        checkPermissions()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.setupCamera()
                }
            }
        default:
            break
        }
    }
    
    private func setupCamera() {
        #if targetEnvironment(simulator)
        return
        #else
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                return
            }
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
        }
        #endif
    }
    
    public func start() {
        #if targetEnvironment(simulator)
        DispatchQueue.main.async { self.isSessionRunning = true }
        #else
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
                DispatchQueue.main.async { self.isSessionRunning = true }
            }
        }
        #endif
    }
    
    public func stop() {
        #if targetEnvironment(simulator)
        DispatchQueue.main.async { self.isSessionRunning = false }
        #else
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async { self.isSessionRunning = false }
            }
        }
        #endif
    }
    
    public func capturePhoto() {
        #if targetEnvironment(simulator)
        DispatchQueue.main.async {
            let image = UIImage(named: "dummy_ktp.jpg") ?? UIImage()
            self.capturedImage = image
            self.stop()
        }
        #else
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
        #endif
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
        DispatchQueue.main.async {
            self.capturedImage = image
            self.stop()
        }
    }
}

public struct CameraView: View {
    @StateObject private var controller = CameraController()
    @Environment(\.presentationMode) var presentationMode
    public let onCaptured: (UIImage) -> Void
    
    public init(onCaptured: @escaping (UIImage) -> Void) {
        self.onCaptured = onCaptured
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            CameraPreviewView(session: controller.session)
                .ignoresSafeArea()
            
            // UI Overlay
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.horizontal, 20)
                
                // Push cutout frame up
                Spacer()
                    .frame(height: 60)
                
                // Cutout frame guide
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                        .frame(height: 220)
                        .background(Color.white.opacity(0.1))
                    
                    Text("Letakkan KTP di dalam kotak\nAtur pencahayaan dan pastikan teks terbaca jelas")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 280) // positioned below the box
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Capture Button
                Button(action: {
                    controller.capturePhoto()
                }) {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                        )
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            controller.start()
        }
        .onDisappear {
            controller.stop()
        }
        // When image is captured, we navigate to confirmation or call callback and dismiss
        .onChange(of: controller.capturedImage) { image in
            if let img = image {
                onCaptured(img)
            }
        }
        .navigationBarHidden(true)
    }
}
