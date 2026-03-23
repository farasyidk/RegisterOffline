import Foundation
import UIKit
@preconcurrency import Vision
import SwiftUI

@MainActor
public class PhotoConfirmationViewModel: ObservableObject {
    @Published public var isGoodQuality: Bool? = nil
    
    public init() {}
    
    public func analyzeImageQuality(image: UIImage) {
        guard let cgImage = image.cgImage else {
            self.isGoodQuality = false
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            
            if let _ = error {
                DispatchQueue.main.async { self.isGoodQuality = false }
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                DispatchQueue.main.async { self.isGoodQuality = false }
                return
            }
            
            // Extract the top candidates from each observation
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: " ")
            
            // Heuristic for KTP: at least 20 alphanumeric characters found with good confidence
            let alphanumericCount = recognizedText.filter { $0.isLetter || $0.isNumber }.count
            
            DispatchQueue.main.async {
                // If it finds at least 20 legible characters, we assume it's good quality / readable
                self.isGoodQuality = alphanumericCount >= 20
            }
        }
        
        // Use an accurate recognition level to enforce quality check
        request.recognitionLevel = .accurate
        
        // Use local handler reference to solve non-Sendable capture in @Sendable closure
        let handler = requestHandler
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.isGoodQuality = false
                }
            }
        }
    }
}
