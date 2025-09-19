import SwiftUI
import VisionKit
import UIKit

@available(iOS 13.0, *)
struct scanNotesView: View {
    @State private var scannedImages: [UIImage] = []
    @State private var showScanner = false
    @State private var showSimulatorAlert = false
    @State private var showUnavailableAlert = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 138/255, green: 102/255, blue: 232/255),
                    Color(red: 255/255, green: 182/255, blue: 193/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer(minLength: 60)

                VStack(spacing: 20) {
                    Image(systemName: "doc.text.viewfinder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 138/255, green: 102/255, blue: 232/255),
                                    Color(red: 255/255, green: 182/255, blue: 193/255)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Scan Your Notes")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Quickly scan, save, and organize your study notes with ease.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 30)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.15))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal)

                Button(action: startScanning) {
                    Text("Start Scanning")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 138/255, green: 102/255, blue: 232/255),
                                    Color(red: 255/255, green: 182/255, blue: 193/255)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(radius: 6)
                }
                .padding(.horizontal, 40)
                .sheet(isPresented: $showScanner) {
                    DocumentScannerView(scannedImages: $scannedImages)
                        .ignoresSafeArea()
                }
                .alert("Scanner not available in Simulator",
                       isPresented: $showSimulatorAlert,
                       actions: { Button("OK", role: .cancel) {} },
                       message: { Text("Run on a physical device to use the camera and document scanner.") })
                .alert("Document scanner unavailable",
                       isPresented: $showUnavailableAlert,
                       actions: { Button("OK", role: .cancel) {} },
                       message: { Text("This device or iOS version doesn’t support VisionKit scanning.") })

                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 12) {
                        ForEach(scannedImages.indices, id: \.self) { idx in
                            Image(uiImage: scannedImages[idx])
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                                .padding(.vertical, 8)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Scan Notes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func startScanning() {
        #if targetEnvironment(simulator)
        showSimulatorAlert = true
        return
        #endif

        if #available(iOS 13.0, *), VNDocumentCameraViewController.isSupported {
            showScanner = true
        } else {
            showUnavailableAlert = true
        }
    }
}

@available(iOS 13.0, *)
struct DocumentScannerView: UIViewControllerRepresentable {
    @Binding var scannedImages: [UIImage]

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentScannerView

        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var images: [UIImage] = []
            for i in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: i))
            }
            DispatchQueue.main.async {
                self.parent.scannedImages.append(contentsOf: images)
            }
            controller.dismiss(animated: true)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Scanning failed: \(error.localizedDescription)")
            controller.dismiss(animated: true)
        }
    }
}
