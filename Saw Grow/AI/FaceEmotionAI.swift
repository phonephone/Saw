//
//  FaceEmotionAI.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 12/6/2567 BE.
//

import UIKit
import CoreML
import Vision

class FaceEmotionAI: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var cameraBtn: UIButton!
    
    var classificationResults : [VNClassificationObservation] = []
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        resultLabel.isHidden = true
    }
    
    func detect(image: CIImage) {
        
        // Load the ML model through its generated class
        let config = MLModelConfiguration()
        guard let model = try? VNCoreMLModel(for: Inceptionv3(configuration: config).model) else {
            fatalError("can't load ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first
            else {
                fatalError("unexpected result type from VNCoreMLRequest")
            }
            print(results)
            
            var resultsStr = ""
            for i in 0...4 {
                resultsStr.append(String(format: "%@ : %.2f %%\n", results[i].identifier,results[i].confidence*100))
            }
            //self.resultLabel.text = "\(topResult.identifier) (\(topResult.confidence*100)%)"
            self.resultLabel.text = resultsStr
            self.resultLabel.isHidden = false
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            guard let ciImage = CIImage(image: image) else {
                fatalError("couldn't convert uiimage to CIImage")
            }
            detect(image: ciImage)
        }
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
}
