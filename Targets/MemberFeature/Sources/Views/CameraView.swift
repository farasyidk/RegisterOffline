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
    private var isConfigured = false
    
    private var guideFrame: CGRect?
    private var screenSize: CGSize?
    
    public override init() {
        super.init()
    }
    
    /// Call this instead of init-time setup. Pass `completion` to start session after config done.
    public func configure(completion: (() -> Void)? = nil) {
        checkPermissions(completion: completion)
    }
    
    private func checkPermissions(completion: (() -> Void)? = nil) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera(completion: completion)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.setupCamera(completion: completion)
                }
            }
        default:
            break
        }
    }
    
    private func setupCamera(completion: (() -> Void)? = nil) {
        #if targetEnvironment(simulator)
        isConfigured = true
        completion?()
        return
        #else
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            var configSuccess = false
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
               let input = try? AVCaptureDeviceInput(device: device) {
                
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
                if self.session.canAddOutput(self.output) {
                    self.session.addOutput(self.output)
                }
                configSuccess = true
            }
            
            // Always commit, even on failure, to avoid broken session state
            self.session.commitConfiguration()
            self.isConfigured = configSuccess
            
            // Notify caller that configuration is done
            completion?()
        }
        #endif
    }
    
    public func start() {
        #if targetEnvironment(simulator)
        DispatchQueue.main.async { self.isSessionRunning = true }
        #else
        sessionQueue.async {
            guard self.isConfigured, !self.session.isRunning else { return }
            self.session.startRunning()
            DispatchQueue.main.async { self.isSessionRunning = true }
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
    
    public func capturePhoto(guideFrame: CGRect? = nil, screenSize: CGSize? = nil) {
        self.guideFrame = guideFrame
        self.screenSize = screenSize
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
        guard let data = photo.fileDataRepresentation(), var image = UIImage(data: data) else { return }
        
        if let guideFrame = self.guideFrame, let screenSize = self.screenSize {
            image = cropImage(image, to: guideFrame, on: screenSize)
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
            self.stop()
        }
    }
    
    private func cropImage(_ image: UIImage, to guideFrame: CGRect, on screenSize: CGSize) -> UIImage {
        let imageSize = image.size
        
        // Calculate the scale used in AspectFill
        let scale = max(screenSize.width / imageSize.width, screenSize.height / imageSize.height)
        
        // Calculate the visible area of the image on screen (centrally aligned)
        let visibleWidth = screenSize.width / scale
        let visibleHeight = screenSize.height / scale
        
        let xOffset = (imageSize.width - visibleWidth) / 2
        let yOffset = (imageSize.height - visibleHeight) / 2
        
        // Map screen coordinates to image coordinates
        let cropX = xOffset + (guideFrame.origin.x / screenSize.width) * visibleWidth
        let cropY = yOffset + (guideFrame.origin.y / screenSize.height) * visibleHeight
        let cropW = (guideFrame.width / screenSize.width) * visibleWidth
        let cropH = (guideFrame.height / screenSize.height) * visibleHeight
        
        let cropRect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
        
        // Perform crop using renderer to handle orientation correctly
        let renderer = UIGraphicsImageRenderer(size: cropRect.size)
        return renderer.image { context in
            image.draw(at: CGPoint(x: -cropX, y: -cropY))
        }
    }
}

public struct CameraView: View {
    @StateObject private var controller = CameraController()
    @Environment(\.presentationMode) var presentationMode
    @State private var guideBoxFrame: CGRect = .zero
    
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
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                self.guideBoxFrame = geo.frame(in: .global)
                            }
                            .onChange(of: geo.frame(in: .global)) { _, newFrame in
                                self.guideBoxFrame = newFrame
                            }
                    }
                )
                
                Spacer()
                
                // Capture Button
                Button(action: {
                    controller.capturePhoto(
                        guideFrame: guideBoxFrame,
                        screenSize: UIScreen.main.bounds.size
                    )
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
            // Configure first, then start — prevents XPC race condition
            controller.configure {
                controller.start()
            }
        }
        .onDisappear {
            controller.stop()
        }
        // When image is captured, we navigate to confirmation or call callback and dismiss
        .onChange(of: controller.capturedImage) { _, image in
            if let img = image {
                onCaptured(img)
            }
        }
        .navigationBarHidden(true)
    }
}
