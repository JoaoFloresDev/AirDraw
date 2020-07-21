/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import StoreKit

class MasterViewController: UIViewController {
    
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
    
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var teste: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buttonBuy: UIButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    //    MARK: - IBAction
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
            if(RazeFaceProducts.store.isProductPurchased("NoAds") || (UserDefaults.standard.object(forKey: "NoAds") != nil)) {
                self.stopLoading()
                self.buyLabel.text = "   ✓✓✓"
                UserDefaults.standard.set(true, forKey:"NoAds")
            }
        }
    }
    
    //    MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    self.teste.text = self.products[0].localizedTitle
                    self.teste.textColor = UIColor.black
                    
                    self.descriptionLabel.text = self.products[0].localizedDescription
                    self.descriptionLabel.textColor = UIColor.black
                    
                    MasterViewController.self.priceFormatter.locale = self.products[0].priceLocale
                    self.priceLabel.text = MasterViewController.self.priceFormatter.string(from: self.products[0].price)!
                    
                }
            }
            else {
                if products?[0] != nil {
                    self.teste.text = self.products[0].localizedTitle
                    self.teste.textColor = UIColor.black
                    
                    self.descriptionLabel.text = self.products[0].localizedDescription
                    self.descriptionLabel.textColor = UIColor.black
                    
                    MasterViewController.self.priceFormatter.locale = self.products[0].priceLocale
                    self.priceLabel.text = MasterViewController.self.priceFormatter.string(from: self.products[0].price)!
                }
            }
        }
        
        confirmCheckmark()
    }
}
