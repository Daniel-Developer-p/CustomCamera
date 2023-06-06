//
//  ViewController.swift
//  specialforRoma
//
//  Created by Даниил Тчанников on 01.06.2023.
//

import AVFoundation
import UIKit

// Final обязательно!!!!
final class ViewController: UIViewController {
    
    // capture session
    private var session: AVCaptureSession? // Should mark private
    // photo output
    private let output = AVCapturePhotoOutput()
    // video preview
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    private let photoSettings = AVCapturePhotoSettings()
    
    private let imageView = UIImageView()
    
    // shutter button
    private let shutterButton: UIButton = {
        let button = UIButton(frame: .init(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupView()
        checkCameraPermissions()
        
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
    }
    
    private func setupView() {
        view.backgroundColor = .black
        
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        view.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFill
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer.frame = view.bounds
        imageView.frame = view.bounds
        
        shutterButton.center = .init(x: view.frame.size.width / 2,
                                     y: view.frame.size.height - shutterButton.frame.height)
    }

    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            // request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
            } catch {
                print(error)
            }
        }
    }
    
    @objc
    private func didTapTakePhoto() {
        output.capturePhoto(with: photoSettings,
                            delegate: self)
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, 
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        
        imageView.image = UIImage(data: data)
        session?.stopRunning()       
    }
}
