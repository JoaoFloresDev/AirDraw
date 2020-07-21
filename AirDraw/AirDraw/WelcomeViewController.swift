//
//  WelcomeViewController.swift
//  Truco Marcador
//
//  Created by Joao Flores on 15/06/20.
//  Copyright © 2020 Gustavo Lima. All rights reserved.
//

import UIKit
import StoreKit

class WelcomeViewController: UIViewController {
    
    //    MARK: - Variables
    var products: [SKProduct] = []
    var timerLoad: Timer!
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    //    MARK: - IBOutlets
    
    //        @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    //        @IBOutlet weak var titlePurchase: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak var viewPro: UIView!
    @IBOutlet weak var viewTest: UIView!
    
    //    MARK: - IBAction
    
    @IBAction func buyPressed(_ sender: Any) {
        RazeFaceProducts.store.buyProduct(self.products[0])
        startLoading()
        timerLoad = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.loadingPlaying), userInfo: nil, repeats: false)
        
        confirmCheckmark()
    }
    
    @IBAction func restorePressed(_ sender: Any) {
        RazeFaceProducts.store.restorePurchases()
        startLoading()
        timerLoad = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.loadingPlaying), userInfo: nil, repeats: false)
        confirmCheckmark()
    }
    
    //    MARK: - UI
    @objc func loadingPlaying() {
        stopLoading()
    }
    
    func confirmCheckmark() {
        DispatchQueue.main.async {
            if(RazeFaceProducts.store.isProductPurchased("NoAds.DIA") || (UserDefaults.standard.object(forKey: "NoAds.DIA") != nil)) {
                self.stopLoading()
                UserDefaults.standard.set(true, forKey:"NoAds.DIA")
                self.showController()
            }
        }
    }
    
    func showController() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let newViewController = storyBoard.instantiateViewController(withIdentifier: "newViewController") as! UITableViewController
//        self.present(newViewController, animated: true, completion: nil)
        performSegue(withIdentifier: "showGame", sender: nil)
    }
    
    //    MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewPro.layer.cornerRadius = 20
        viewTest.layer.cornerRadius = 20
        
        NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
        
        confirmCheckmark()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
        confirmCheckmark()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
        confirmCheckmark()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reload()
        confirmCheckmark()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard
            let productID = notification.object as? String,
            let _ = products.firstIndex(where: { product -> Bool in
                product.productIdentifier == productID
            })
            else { return }
        
        confirmCheckmark()
    }
    //    MARK: - UI
    func startLoading() {
        loadingView.alpha = 1
        loadingView.startAnimating()
    }
    
    func stopLoading() {
        loadingView.alpha = 0
        loadingView.stopAnimating()
    }
    
    //    MARK: - Data Management
    @objc func reload() {
        products = []
        
        RazeFaceProducts.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products!
                
                DispatchQueue.main.async {
                    
                    self.descriptionLabel.text = self.products[0].localizedDescription
                    
                    MasterViewController.self.priceFormatter.locale = self.products[0].priceLocale
                    self.priceLabel.text = MasterViewController.self.priceFormatter.string(from: self.products[0].price)!
                    
                }
            }
            else {
                if products?[0] != nil {
                    self.descriptionLabel.text = self.products[0].localizedDescription
                    
                    MasterViewController.self.priceFormatter.locale = self.products[0].priceLocale
                    self.priceLabel.text = MasterViewController.self.priceFormatter.string(from: self.products[0].price)!
                }
            }
        }
        
        confirmCheckmark()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
