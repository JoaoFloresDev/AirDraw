////
////  RegisterViewController.swift
////  CampusSelvagem
////
////  Created by Felipe Semissatto on 19/08/19.
////  Copyright © 2019 Felipe Semissatto. All rights reserved.
////
//
//import UIKit
//import Photos
//import Foundation
//import Photos
//
//class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
//
//    var imagePicker: UIImagePickerController!
//    var imageViewInUse = 0
//    var timerAdv: Timer! = nil
//    @IBOutlet var imagesGalery: [UIImageView]!
//    @IBOutlet var imageAddButtons: [UIButton]!
//    @IBOutlet var imageDelButtons: [UIButton]!
//    @IBOutlet weak var clearAllButton: UIButton!
//    @IBOutlet weak var submitButton: UIButton!
//
//    @IBOutlet weak var constrainTextBox: UIView!
//    @IBOutlet weak var nameTextBox: UITextField!
//    @IBOutlet weak var locationTextBox: UITextField!
//    @IBAction func confirmButton(_ sender: Any) {
//
//        if(imageViewInUse < 1) {
//            if(timerAdv != nil) {
//                timerAdv.invalidate()
//            }
//            imagesGalery[0].backgroundColor = imagesGalery[1].backgroundColor
//            imagesGalery[0].alpha = 1
//            advertence()
//        }
//
//        else {
//            let refreshAlert = UIAlertController(title: "Deseja enviar os dados?", message: nil, preferredStyle: UIAlertController.Style.alert)
//
//            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
//                self.updateImg()
//                self.clearAll()
//            }))
//
//            refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
//                print("Cancel Logic pressed")
//            }))
//
//            present(refreshAlert, animated: true, completion: nil)
//        }
//    }
//
//    @IBAction func deleteButton(_ sender: UIButton) {
//        if(imageViewInUse > 0) {
//            for n in sender.tag...2 {
//                imagesGalery[n].image = imagesGalery[n+1].image
//            }
//
//            imageViewInUse -= 1
//            imageAddButtons[imageViewInUse].alpha = 0.4
//            imageDelButtons[imageViewInUse].alpha = 0
//        }
//    }
//
//    @IBAction func TakePhoto(_ sender: Any) {
//
//        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        let deleteAction = UIAlertAction(title: "Abrir Câmera", style: .default, handler: { (action) -> Void in
//            self.openCamera()
//        })
//        let saveAction = UIAlertAction(title: "Abrir Galeria", style: .default, handler: { (action) -> Void in
//            self.openGalery()
//        })
//
//        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
//
//        optionMenu.addAction(deleteAction)
//        optionMenu.addAction(saveAction)
//        optionMenu.addAction(cancelAction)
//
//        self.present(optionMenu, animated: true, completion: nil)
//    }
//
//     func clearAll() {
//
//        for n in 0...3 {
//            imagesGalery[n].image = nil
//        }
//
//        for n in 0...3 {
//            imageAddButtons[n].alpha = 0.4
//        }
//
//        for n in 0...3 {
//            imageDelButtons[n].alpha = 0
//        }
//        imageViewInUse = 0
//
//        nameTextBox.text = ""
//        locationTextBox.text = ""
//    }
//
//    @IBAction func clearInformations(_ sender: Any) {
//        let refreshAlert = UIAlertController(title: "Deseja apagar tudo?", message: "Todos os dados serão perdidos", preferredStyle: UIAlertController.Style.alert)
//
//        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
//            self.clearAll()
//        }))
//
//        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
//            print("Cancel Logic pressed")
//        }))
//
//        present(refreshAlert, animated: true, completion: nil)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        clearAllButton.layer.cornerRadius = 15
//        submitButton.layer.cornerRadius = 15
//
////        KeyboardAvoiding.avoidingView = self.constrainTextBox
//
//        for n in 0...3 {
//            imagesGalery[n].image = nil
//        }
//
//        for n in 0...3 {
//            imageDelButtons[n].alpha = 0
//        }
//    }
//
////    Galery and camera functions
//    func openCamera() {
//
//        imagePicker =  UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .camera
//
//        present(imagePicker, animated: true, completion: nil)
//    }
//
//    func openGalery() {
//        imagePicker =  UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
//
//        present(imagePicker, animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        print("aqui")
//        imagesGalery[imageViewInUse].image = info[.originalImage]
//        var portraitOrientation = false
//
//        if(Int((imagesGalery[imageViewInUse].image?.size.width)!) > Int((imagesGalery[imageViewInUse].image?.size.height)!)) {
//            portraitOrientation = true
//        }
//
//        print(imagesGalery[imageViewInUse].frame)
//
//        imagesGalery[imageViewInUse].image = cropToBounds(image: imagesGalery[imageViewInUse].image!, portraitOrientation: portraitOrientation)
//
//
//        imageAddButtons[imageViewInUse].alpha = 0
//        imageDelButtons[imageViewInUse].alpha = 0.4
//        imageViewInUse += 1
//        imagePicker.dismiss(animated: true, completion: nil)
//    }
//
//    func cropToBounds(image: UIImage, portraitOrientation: Bool) -> UIImage {
//
//        let cgimage = image.cgImage!
//        let contextImage: UIImage = UIImage(cgImage: cgimage)
//        let contextSize: CGSize = contextImage.size
//        var posX: CGFloat = 0.0
//        var posY: CGFloat = 0.0
//        var cgwidth: CGFloat = 0
//        var cgheight: CGFloat = 0
//
//        if (portraitOrientation) { // if portrate
//            posX = ((contextSize.width - contextSize.height) / 2)
//            posY = 0
//            // hard coded
//            cgwidth = 2350
//            cgheight = 3000
//        } else { // if landscape
//            posX = 0
//            posY = ((contextSize.height - contextSize.width) / 2)
//            // hard coded
//            cgwidth = 3000
//            cgheight = 2850
//        }
//
//        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
//
//        // Create bitmap image from context using the rect
//        let imageRef: CGImage = cgimage.cropping(to: rect)!
//
//        // Create a new image based on the imageRef and rotate back to the original orientation
//        let image: UIImage = UIImage(cgImage: imageRef, scale: 1, orientation: image.imageOrientation)
//        return image
//    }
//
////    keyboard functions
////    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
////        if textField == self.nameTextBox {
////            KeyboardAvoiding.avoidingView = self.constrainTextBox
////        }
////        else if textField == self.locationTextBox {
////            KeyboardAvoiding.avoidingView = self.constrainTextBox
////        }
////        return true
////    }
////
////    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
////        if textField == self.nameTextBox {
////            self.locationTextBox.becomeFirstResponder()
////        }
////        else if textField == self.locationTextBox {
////            textField.resignFirstResponder()
////        }
////        return true
////    }
////
////    override func didReceiveMemoryWarning() {
////        super.didReceiveMemoryWarning()
////    }
////
////    func updateImg() {
////        var AnimalSaved = false
////
////            let location = locationTextBox.text == nil || locationTextBox.text!.isEmpty ? "not found" : locationTextBox.text!
////
////            let name = nameTextBox.text == nil || nameTextBox.text!.isEmpty ? "not found" : nameTextBox.text!
////
////            let storageRef = Storage.storage().reference()
////
////            for n in 0 ... imageViewInUse - 1 {
////
////                if let image = imagesGalery[n].image,
////                   let data = image.pngData()
////                {
////                    let rand = Int.random(in: 0 ... 10000)
////                    let imageRef = storageRef.child("Name: \(String(describing: name)) - Location: \(String(describing: location)) /image\(n+1).\(rand).png")
////
////                    _ = imageRef.putData(data, metadata: nil, completion: { (metadata, error) in
////                        guard metadata != nil else{
////                            print(error ?? "unknown error")
////                            AnimalSaved = false
////                            return
////                        }
////                    })
////                    AnimalSaved = true
////                }
////            }
////
////            if(AnimalSaved) {
////                showAlert(title: "Dados salvos", message: "Dados em fase de analise")
////            } else {
////                showAlert(title: "Erro", message: "Verifique sua conexão")
////            }
////    }
//
//    func advertence() {
//        let colorBase = imagesGalery[0].backgroundColor
//        var contTimer = 0
//
//        timerAdv = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { (timer) in
//            if(contTimer%2 == 0) {
//                self.imagesGalery[0].alpha = 0.3
//                self.imagesGalery[0].backgroundColor = UIColor.red
//            } else {
//                self.imagesGalery[0].alpha = 1
//                self.imagesGalery[0].backgroundColor = colorBase
//            }
//
//            contTimer += 1
//
//            if(contTimer == 4) {
//                self.timerAdv.invalidate()
//                self.timerAdv = nil
//            }
//        }
//    }
//
//    func showAlert(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message:
//            message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default))
//
//        self.present(alertController, animated: true, completion: nil)
//    }
//}
