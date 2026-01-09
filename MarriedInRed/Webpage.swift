import Foundation
import WebKit
import SpriteKit
import Cocoa

class Webpage: NSObject, WKNavigationDelegate {
    
//    Change webpage so it can scale more than it does 

    private var webView: WKWebView?
    private var containerView: ClickableContainer?
    private var loadingSpinner: NSProgressIndicator?
    
    var onClose: (() -> Void)?

    private let browserWidth: CGFloat = 1000
    private let browserHeight: CGFloat = 800
    
    var isOpen: Bool {
        return containerView != nil
    }
    
    func open(url: String, in parentView: NSView) {
        if isOpen { return }

        // 1. Create Custom Container
        let container = ClickableContainer()
        container.wantsLayer = true
        container.translatesAutoresizingMaskIntoConstraints = false
        // Semi-transparent background
        container.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.8).cgColor
        container.layer?.cornerRadius = 12
        
        // Setup Double Click Action
        container.onDoubleClick = { [weak self] in
            self?.close()
        }
        
        parentView.addSubview(container)
        self.containerView = container
        
        // 2. Setup Constraints for Container (Center in Window)
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: browserWidth),
            container.heightAnchor.constraint(equalToConstant: browserHeight),
            container.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
        ])
        
        // 3. Create WebView
        let config = WKWebViewConfiguration()
        let newWebView = WKWebView(frame: .zero, configuration: config)
        newWebView.navigationDelegate = self
        newWebView.wantsLayer = true
        newWebView.layer?.cornerRadius = 10.0
        newWebView.layer?.masksToBounds = true
        newWebView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(newWebView)
        self.webView = newWebView
        
        // 4. Create Loading Spinner
        let spinner = NSProgressIndicator()
        spinner.style = .spinning
        spinner.controlSize = .large
        spinner.isIndeterminate = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.isHidden = true
        
        container.addSubview(spinner, positioned: .above, relativeTo: newWebView)
        self.loadingSpinner = spinner
        
        // 5. Create Close Button (Red Circle with X)
        let closeButton = NSButton(title: "", target: self, action: #selector(handleCloseButton))
        closeButton.bezelStyle = .circular
        closeButton.image = NSImage(named: NSImage.stopProgressTemplateName)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(closeButton, positioned: .above, relativeTo: spinner)
        
        // 6. Setup Internal Constraints
        NSLayoutConstraint.activate([
            // Pin WebView to Container with PADDING so you can click the edge
            newWebView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            newWebView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            newWebView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            newWebView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            // Center Spinner
            spinner.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            // Pin Close Button to Top-Right
            closeButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -5),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        load(link: url, in: newWebView)
    }
    
    @objc func handleCloseButton() {
        self.close()
    }
    
    func close() {
        containerView?.removeFromSuperview()
        containerView = nil
        webView = nil
        loadingSpinner = nil
        
        // IMPORTANT: Tell MapScene to unpause!
        onClose?()
    }
    
    private func load(link: String, in view: WKWebView) {
        if let url = URL(string: link) {
            let request = URLRequest(url: url)
            view.load(request)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingSpinner?.isHidden = false
        loadingSpinner?.startAnimation(nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingSpinner?.stopAnimation(nil)
        loadingSpinner?.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingSpinner?.stopAnimation(nil)
        loadingSpinner?.isHidden = true
        print("Webpage error: \(error.localizedDescription)")
    }
}

// Corrected Class Definition
class ClickableContainer: NSView {
    var onDoubleClick: (() -> Void)?
    
    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            onDoubleClick?()
        }
        super.mouseDown(with: event)
    }
}
