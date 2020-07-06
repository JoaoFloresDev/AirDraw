//
//  ViewController.swift
//  Air Draw
//
//  Created by Joao Flores on 07/04/20.
//  Copyright © 2020 Joao Flores. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import simd
import Photos
import StoreKit
import Foundation

//cool sounds
//var vet = [1003, 1019, 1100, 1103, 1104,1108, 1130, 1163]

var i = 1100
func getRoundyButton(size: CGFloat = 100,
                     imageName : String,
                     _ colorTop : UIColor ,
                     _ colorBottom : UIColor ) -> UIButton {
    
    let button = UIButton(frame: CGRect.init(x: 0, y: 0, width: size, height: size))
    button.clipsToBounds = true
    button.layer.cornerRadius = size / 2
    
    let gradient: CAGradientLayer = CAGradientLayer()
    
    gradient.colors = [colorTop.cgColor, colorBottom.cgColor]
    gradient.startPoint = CGPoint(x: 1.0, y: 1.0)
    gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
    gradient.frame = button.bounds
    gradient.cornerRadius = size / 2
    
    button.layer.insertSublayer(gradient, at: 0)
    
    let image = UIImage.init(named: imageName )
    let imgView = UIImageView.init(image: image)
    imgView.center = CGPoint.init(x: button.bounds.size.width / 2.0, y: button.bounds.size.height / 2.0 )
    button.addSubview(imgView)
    
    return button
    
}

extension URL {
    
    static func documentsDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
        
    }
}

extension String {
    func format(_ args: CVarArg...) -> String {
        return NSString(format: self, arguments: getVaList(args)) as String
    }
    
}

class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    //    MARK: - IBOutlet
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var tutorialAsset: UIButton!
    @IBOutlet weak var tutorialImage: UIImageView!
    
    //    MARK: - Variables
    var timerTutotial: Timer!
    var imagePicker: UIImagePickerController!
    let vertBrush = VertBrush()
    var buttonDown = false
    var imageView: UIImage!
    
    var clearDrawingButton : UIButton!
    var toggleModeButton : UIButton!
    var recordButton : UIButton!
    
    var frameIdx = 0
    var splitLine = false
    var lineRadius : Float = 0.001
    
    var metalLayer: CAMetalLayer! = nil
    var hasSetupPipeline = false
    
    var videoRecorder : MetalVideoRecorder? = nil
    var tempVideoUrl : URL? = nil
    var recordingOrientation : UIInterfaceOrientationMask? = nil
    enum ColorMode : Int {
        case color
        case normal
        case rainbow
        case black
        case light
    }
    
    var currentColor : SCNVector3 = SCNVector3(100,0.5,100)
    var colorMode : ColorMode = .rainbow
    
    var avgPos : SCNVector3! = nil
    
    
    // MARK: - OVERRIDES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        
        sceneView.scene = scene
        metalLayer = self.sceneView.layer as? CAMetalLayer
        metalLayer.framebufferOnly = false
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.minimumPressDuration = 0
        tap.cancelsTouchesInView = false
        tap.delegate = self
        self.sceneView.addGestureRecognizer(tap)
        
        
        PHPhotoLibrary.requestAuthorization { status in
            print(status)
        }
        
        self.timerTutotial = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateGestureTap), userInfo: nil, repeats: true)
    }
    
    @objc func animateGestureTap() {
        if(tutorialImage.image == (UIImage(named: "twoTapImg1"))) {tutorialImage.image = (UIImage(named: "twoTapImg2")) }
        else if (tutorialImage.image == (UIImage(named: "twoTapImg2"))) { tutorialImage.image = (UIImage(named: "twoTapImg3")) }
        else { tutorialImage.image = (UIImage(named: "twoTapImg1")) }
    }
    
    func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let orientation = recordingOrientation {
            return orientation
        } else {
            return .all
        }
    }
    
    //    MARK: - GESTURES
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
    
    var touchLocation : CGPoint = .zero
    
    // called by gesture recognizer
    @objc func tapHandler(gesture: UITapGestureRecognizer) {
        if gesture.state == .began {
            
            self.touchLocation = self.sceneView.center
            buttonTouchDown()
            
        } else if gesture.state == .ended {
            
            buttonTouchUp()
            
        } else if gesture.state == .changed {
            
            if buttonDown {
                self.touchLocation = gesture.location(in: self.sceneView)
            }
        }
    }
    
    @objc func buttonTouchDown() {
        splitLine = true
        buttonDown = true
        avgPos = nil
    }
    
    @objc func buttonTouchUp() {
        buttonDown = false
    }
    
    //    MARK: - LIFE CYCLE
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBAction
    
    @IBAction func changeImage(_ sender: Any) {
        AudioServicesPlaySystemSound(SystemSoundID(1520))
        AudioServicesPlaySystemSound(SystemSoundID(1103))
        openGalery()
    }
    
    @IBAction func changeColor(_ sender: Any) {
        AudioServicesPlaySystemSound(SystemSoundID(1104))
        AudioServicesPlaySystemSound(SystemSoundID(1520))
        self.colorMode = ColorMode(rawValue: (self.colorMode.rawValue + 1) % 5)!
        
        if let button : UIButton = sender as? UIButton
        {
            switch self.colorMode {
            case .rainbow:
                button.setImage(UIImage(named: "color1.png")!, for: .normal)
                
            case .normal:
                //                    rainbow horizontal
                button.setImage(UIImage(named: "color2.png")!, for: .normal)
                
            case .color:
                //                    chiclete
                button.setImage(UIImage(named: "redColor.png")!, for: .normal)
                
            case .black:
                button.setImage(UIImage(named: "blackColor.png")!, for: .normal)
                
            case .light:
            button.setImage(UIImage(named: "yellowLight.png")!, for: .normal)
            }
        }
    }
    
    @IBAction func clearAll(_ sender: Any) {
        AudioServicesPlaySystemSound(1522)
        AudioServicesPlaySystemSound(1520)
        vertBrush.clear()
        
        for x in sceneView.scene.rootNode.childNodes {
            x.removeFromParentNode()
        }
    }
    
    @IBAction func screenShot(_ sender: Any) {
        catchVideo(sender)
    }
    
    @IBAction func tutorial(_ sender: Any) {
        
        timerTutotial.invalidate()
        
        tutorialAsset.removeFromSuperview()
        tutorialImage.removeFromSuperview()
        let tutu = UIImage(named: "tutu")
        self.plotImage (image: tutu!, size: 1, cornerRadius: 0)
    }
    
    //    MARK: - PLOT IMAGE FUNCTIONS
    func openGalery() {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageView = editedImage
            imagePicker.dismiss(animated: true, completion: nil)
            showMenu()
        } else if let originalimage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView = originalimage
            imagePicker.dismiss(animated: true, completion: nil)
            showMenu()
        }
        else {
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            self.dismiss(animated: true, completion: nil)
            
            addTV(url: videoURL)
        }
    }
    
    func addTV(url: NSURL) {
        let video = AVPlayer(url: url as URL)
        
        let scene = SCNScene(named: "art.scnassets/VerticalTV.scn")!
        let tvNode = scene.rootNode.childNode(withName: "tv_node", recursively: true)
        tvNode?.position = SCNVector3(0,0,0)
        
        let tvScreenPlaneNode = tvNode?.childNode(withName: "screen", recursively: true)
        let tvScreenPlaneNodeGeometry = tvScreenPlaneNode?.geometry as! SCNPlane
       
        let tvVideoNode = SKVideoNode(avPlayer: video)
        let videoScene = SKScene(size: .init(width: tvScreenPlaneNodeGeometry.width*1000, height: tvScreenPlaneNodeGeometry.height*1000))
        videoScene.addChild(tvVideoNode)
        
        tvVideoNode.position = CGPoint(x: videoScene.size.width/2, y: videoScene.size.height/2)
        tvVideoNode.size = videoScene.size
        
        let tvScreenMaterial = tvScreenPlaneNodeGeometry.materials.first(where: { $0.name == "video" })
        
        tvScreenMaterial?.diffuse.contents = videoScene
        
        tvVideoNode.play()
        self.sceneView.scene.rootNode.addChildNode(tvNode!)
    }
    
    func cropBounds(viewlayer: CALayer, cornerRadius: Float) {
        
        let imageLayer = viewlayer
        imageLayer.cornerRadius = CGFloat(cornerRadius)
        imageLayer.masksToBounds = true
    }
    
    func showMenu() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let ResetGame = UIAlertAction(title: "x 1", style: .default, handler: { (action) -> Void in
            self.plotImage (image: self.imageView, size: 1, cornerRadius: 1)
        })
        
        let GoOrdemDasCartas = UIAlertAction(title: "x 5", style: .default, handler: { (action) -> Void in
            self.plotImage (image: self.imageView, size: 4, cornerRadius: 1)
        })
        
        let EditAction = UIAlertAction(title: "x 10", style: .default, handler: { (action) -> Void in
            self.plotImage (image: self.imageView, size: 4, cornerRadius: 1)
        })
        
        let EditAction2 = UIAlertAction(title: "x 15", style: .default, handler: { (action) -> Void in
            self.plotImage (image: self.imageView, size: 12, cornerRadius: 1)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("cancel action")
        })
        
        optionMenu.addAction(ResetGame)
        optionMenu.addAction(GoOrdemDasCartas)
        optionMenu.addAction(EditAction)
        optionMenu.addAction(EditAction2)
        optionMenu.addAction(cancel)
        
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
    
    func plotImage (image: UIImage, size: CGFloat, cornerRadius: CGFloat) {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        var imagePlane = SCNPlane(width: image.size.width * size / 4000,
                                  height: image.size.height * size / 4000)
        var angle: Float = 90
        
        switch image.imageOrientation
        {
        case .right:
            imagePlane = SCNPlane(width: image.size.height * size / 4000,
                                  height: image.size.width * size / 4000)
            angle = 0
            
            print("right")
            
        case .down:
            print("down")
            
        case .left:
            imagePlane = SCNPlane(width: image.size.height * size / 4000,
                                  height: image.size.width * size / 4000)
            angle = 0
            print("left")
            
        default:
            print("default")
        }
        
        imagePlane.firstMaterial?.diffuse.contents = image
        imagePlane.firstMaterial?.lightingModel = .constant
        imagePlane.firstMaterial?.isDoubleSided = true
        imagePlane.cornerRadius = CGFloat(image.size.height * size / 100000 * cornerRadius)
        let planeNode = SCNNode(geometry: imagePlane)
        
        var translation = SCNMatrix4Translate(SCNMatrix4Identity, 0, 0, -1)
        
        translation = SCNMatrix4Rotate(translation, GLKMathDegreesToRadians(angle), 0, 0, 1)
        
        var transform = float4x4(translation)
        
        transform = matrix_multiply(currentFrame.camera.transform,transform)
        
        planeNode.simdTransform = transform
        
        sceneView.scene.rootNode.addChildNode(planeNode)
    }
    
    //    MARK: - EXPORT VIDEO AND IMAGES FUNCTIONS
    func exportRecordedVideo() {
        
        guard let videoUrl = self.tempVideoUrl else { return }
        
        PHPhotoLibrary.shared().performChanges({
            
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
            
        }) { saved, error in
            
            if !saved {
                
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Error saving video", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                self.showAlert(title: "Saved!", message: "Your video has been saved to your photos.")
            }
        }
        
    }
    
    func catchVideo(_ sender: Any) {
        if let rec = self.videoRecorder, rec.isRecording {
            
            rec.endRecording {
                
                AudioServicesPlaySystemSound(1518)
                
                DispatchQueue.main.async {
                    self.exportRecordedVideo()
                    self.recordingOrientation = nil
                }
            }
            
            if let button : UIButton = sender as? UIButton {
                button.setImage(UIImage(named: "gravar.png")!, for: .normal)
            }
            
        } else {
            
            if let button : UIButton = sender as? UIButton {
                button.setImage(UIImage(named: "gravando.png")!, for: .normal)
            }
            
            let videoOutUrl = URL.documentsDirectory().appendingPathComponent("temp_video.mp4")
            
            if FileManager.default.fileExists(atPath: videoOutUrl.path) {
                try! FileManager.default.removeItem(at: videoOutUrl)
            }
            
            let size = self.metalLayer.drawableSize
            
            AudioServicesPlaySystemSound(1520)
            
            let rec = MetalVideoRecorder(outputURL: videoOutUrl, size: size)
            rec?.startRecording()
            
            self.videoRecorder = rec
            
            self.tempVideoUrl = videoOutUrl
            
            
            
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:
                self.recordingOrientation = .landscapeLeft
            case .landscapeRight:
                self.recordingOrientation = .landscapeRight
            case .portrait:
                self.recordingOrientation = .portrait
            case .portraitUpsideDown:
                self.recordingOrientation = .portraitUpsideDown
            case .unknown:
                self.recordingOrientation = nil
            }
        }
    }
    // MARK: - ARSCNViewDelegate
    
    func addBall( _ pos : SCNVector3 ) -> SCNNode{
        let b = SCNSphere(radius: 0.01)
        b.firstMaterial?.diffuse.contents = UIColor.red
        let n = SCNNode(geometry: b)
        n.worldPosition = pos
        self.sceneView.scene.rootNode.addChildNode(n)
        return n
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        let pointer = getPointerPosition()
        
        if avgPos == nil {
            avgPos = pointer.pos
        }
        
        avgPos = avgPos - (avgPos - pointer.pos) * 0.4;
        
        if ( buttonDown ) {
            
            if ( pointer.valid ) {
                
                if ( vertBrush.points.count == 0 || (vertBrush.points.last! - pointer.pos).length() > 0.001 ) {
                    
                    var radius : Float = 0.001
                    
                    if ( splitLine || vertBrush.points.count < 2 ) {
                        lineRadius = 0.001
                    } else {
                        
                        let i = vertBrush.points.count-1
                        let p1 = vertBrush.points[i]
                        let p2 = vertBrush.points[i-1]
                        
                        radius = 0.001 + min(0.015, 0.005 * pow( ( p2-p1 ).length() / 0.005, 2))
                        
                    }
                    
                    lineRadius = lineRadius - (lineRadius - radius)*0.075
                    
                    var color : SCNVector3
                    
                    switch colorMode {
                        
                    case .rainbow:
                        
                        let hue : CGFloat = CGFloat(fmodf(Float(vertBrush.points.count) / 30.0, 1.0))
                        let c = UIColor.init(hue: hue, saturation: 0.95, brightness: 1, alpha: 1.0)
                        var red : CGFloat = 0.0; var green : CGFloat = 0.0; var blue : CGFloat = 0.0;
                        c.getRed(&red, green: &green, blue: &blue, alpha: nil)
                        color = SCNVector3(red, green, blue)
                        
                    case .normal:
                        color = SCNVector3(-1, -1, -1)
                        
                    
                    case .light:
                        lineRadius = 0
                        
                        let hue : CGFloat = CGFloat(fmodf(10, 0.5))
                        let c = UIColor.init(hue: hue, saturation: 0.5, brightness: 10, alpha: 0.8)
                        var red : CGFloat = 0.0
                        var green : CGFloat = 0.0
                        var blue : CGFloat = 0.0
                        c.getRed(&red, green: &green, blue: &blue, alpha: nil)
                        color = SCNVector3(red, green, blue)
                        
                        let b = SCNSphere(radius: 0.005)
                        b.firstMaterial?.diffuse.contents = UIColor.white
                        
                        let n = SCNNode(geometry: b)
                        n.worldPosition = avgPos
                        self.sceneView.scene.rootNode.addChildNode(n)
                        
                        self.addGlowTechnique(node: n, sceneView: sceneView)
                        
                        if let path = Bundle.main.path(forResource: "NodeTechnique", ofType: "plist") {
                            if let dict = NSDictionary(contentsOfFile: path)  {
                                let dict2 = dict as! [String : AnyObject]
                                let technique = SCNTechnique(dictionary:dict2)

                                let color = SCNVector3(1.0, 1.0, 0.0)
                                technique?.setValue(NSValue(scnVector3: color), forKeyPath: "glowColorSymbol")
                                self.sceneView.technique = technique
                            }
                        }
                        
                    case .color:
                        lineRadius = 0.003
                        
                        let hue : CGFloat = CGFloat(fmodf(100, 10))
                        let c = UIColor.init(hue: hue, saturation: 10, brightness: 0.5, alpha: 0.8)
                        var red : CGFloat = 0.5
                        var green : CGFloat = 0.0
                        var blue : CGFloat = 0.0
                        c.getRed(&red, green: &green, blue: &blue, alpha: nil)
                        color = SCNVector3(red, green, blue)
                        
                        
                    case .black:
                        lineRadius = 0.001
                        color = SCNVector3(0.1,0.1,0.1)
                    }
                    
                    vertBrush.addPoint(avgPos,
                                       radius: lineRadius,
                                       color: color,
                                       splitLine:splitLine)
                    
                    if ( splitLine ) { splitLine = false }
                }
            }
        }
        
        frameIdx = frameIdx + 1
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        
        if ( !hasSetupPipeline ) {
            hasSetupPipeline = true
            
            vertBrush.setupPipeline(device: sceneView.device!, renderDestination: self.sceneView! )
        }
        
        guard let frame = self.sceneView.session.currentFrame else {
            return
        }
        
        if let commandQueue = self.sceneView?.commandQueue {
            if let encoder = self.sceneView.currentRenderCommandEncoder {
                
                let projMat = float4x4.init((self.sceneView.pointOfView?.camera?.projectionTransform)!)
                let modelViewMat = float4x4.init((self.sceneView.pointOfView?.worldTransform)!).inverse
                
                vertBrush.updateSharedUniforms(frame: frame)
                vertBrush.render(commandQueue, encoder, parentModelViewMatrix: modelViewMat, projectionMatrix: projMat)
            }
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            if let recorder = self.videoRecorder,
                recorder.isRecording {
                
                if let tex = self.metalLayer.nextDrawable()?.texture {
                    recorder.writeFrame(forTexture: tex)
                }
            }
        }
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
    }
    
    // MARK: -
    func getPointerPosition() -> (pos : SCNVector3, valid: Bool, camPos : SCNVector3 ) {
        
        guard let pointOfView = sceneView.pointOfView else { return (SCNVector3Zero, false, SCNVector3Zero) }
        guard let currentFrame = sceneView.session.currentFrame else { return (SCNVector3Zero, false, SCNVector3Zero) }
        
        let cameraPos = SCNVector3(currentFrame.camera.transform.translation)
        
        let touchLocationVec = SCNVector3(x: Float(touchLocation.x), y: Float(touchLocation.y), z: 0.01)
        
        let screenPosOnFarClippingPlane = self.sceneView.unprojectPoint(touchLocationVec)
        
        let dir = (screenPosOnFarClippingPlane - cameraPos).normalized()
        
        let worldTouchPos = cameraPos + dir * 0.12
        
        return (worldTouchPos, true, pointOfView.position)
    }
    
    //    MARK: - Alerts
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
    }
}

extension ViewController {
    public func addGlowTechnique(node:SCNNode ,sceneView:ARSCNView){
        node.categoryBitMask = 2;
        if let path = Bundle.main.path(forResource: "NodeTechnique", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path)  {
                let dict2 = dict as! [String : AnyObject]
                let technique = SCNTechnique(dictionary:dict2)
                sceneView.technique = technique
            }
        }
    }
}
