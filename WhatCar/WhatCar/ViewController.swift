//
//  ViewController.swift
//  WhatCar
//
//  Created by Chuck Fishman on 29/08/18.
//  Copyright © 2018 Chuck Fishman. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    let WIKI_SEARCH_URL="https://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srlimit=1&srsearch="
    
    let WIKI_BASE_URL="https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro&explaintext&titles="

    var imagePicker = UIImagePickerController()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var carDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureImagePicker()
    }


    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func renderImageView(image: UIImage) {
        imageView.image = image
    }
    
    func renderTitle(name: String) {
        title = name
    }
    
    func renderDescription(text: String?) {
        
        let content = text ?? "No result found on Wiki"
        
        carDescription.text = content
    }
    
    func detect(image: UIImage) {
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("Cant convert image to CIImage")
        }
        
        guard let model = try? VNCoreMLModel(for: CarClassifier2().model) else {
            fatalError("Cant load CoreML Model")
        }
        
        let request = VNCoreMLRequest(model: model) { (req, err) in
            
            if let results = req.results as? [VNClassificationObservation] {
                if let identifier = results.first?.identifier {
                    self.renderTitle(name: identifier)
                    self.fetchDescription(title: identifier)
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([request])
        }
        catch {
            print("Error perform VNImageRequest")
        }
    }
    
    func searchWiki(title: String, completion: @escaping (String) -> ()) {
        
        let searchURL = WIKI_SEARCH_URL + title.replacingOccurrences(of: " ", with: "%20")
        
        Alamofire.request(searchURL)
        .responseJSON {
            
            (res) in
            
            guard let data = res.data else {
                self.renderDescription(text: nil)
                return
            }
            
            guard let term = JSON(data)["query"]["search"][0]["title"].string else {
                self.renderDescription(text: nil)
                return
            }
            
            completion(term)
        }
    }
    
    func findWiki(term: String) {

        let wikiURL = WIKI_BASE_URL + term.replacingOccurrences(of: " ", with: "%20")

        Alamofire.request(wikiURL)
        .responseJSON {
            
            (res) in

            if let data = res.data {
                if let dic = JSON(data)["query"]["pages"].dictionary {
                    if let extract = dic[dic.startIndex].value["extract"].string {

                        self.renderDescription(text: extract)
                        
                        return
                    }
                }
            }
            
            self.renderDescription(text: nil)
        }
        
    }
    
    func fetchDescription(title: String) {
        searchWiki(title: title) { (term) in
            self.findWiki(term: term)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            renderImageView(image: image)
            detect(image: image)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

