//
//  ViewController.swift
//  VKApp
//
//  Created by Maxim Safronov on 30.06.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import UIKit
import WebKit

class LoginController: UIViewController, WKUIDelegate {
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let request = loadComponents()
        webView.load(request)
    }
    
    func setupUI() {
        self.view.addSubview(webView)
        webView.pin(to: view)
    }
    
    func loadComponents() -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth.vk.com"
        components.path = "/authorize"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: "7539955"),
            URLQueryItem(name: "scope", value: "wall,photos,offline,friends,stories,status,groups"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: "5.92")
        ]
        let request = URLRequest(url: components.url!)
        return request
    }
    
    func deleteAllCookies() {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookie in
            cookie.forEach { self?.webView.configuration.websiteDataStore.httpCookieStore.delete($0) }
        }
    }
}

extension LoginController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url,
            url.path == "/blank.html",
            let fragment = url.fragment else { decisionHandler(.allow); return }
        
        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
        }
        
        print("params: \(params)")
        
        guard let token = params["access_token"],
            let userIdString = params["user_id"],
            let _ = Int(userIdString) else {
                decisionHandler(.allow)
                return
        }
        
        Session.shared.token = token
        
        let rvc = FriendsController()
        let vc = UINavigationController(rootViewController: rvc)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
  
        decisionHandler(.cancel)
    }
}
