//
//  Updater.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 27/3/2566 BE.
//

import UIKit

public class Updater: NSObject {
    public static let shared = Updater()
    
    public class func versionAndDownloadUrl() -> (version: String, downloadUrl: String)? {
        guard let identifier = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String, let url = URL(string: "http://itunes.apple.com/th/lookup?bundleId=\(identifier)") else { return nil
        }
        
        guard
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            results.count > 0,
            let version = results[0]["version"] as? String,
            let downLoadUrl = results[0]["trackViewUrl"] as? String
            else {
                return nil
        }
        
        return (version, downLoadUrl)
    }
    
    public class func showUpdateAlert(isForce:Bool = false) {
        guard let applicationName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String, let data = versionAndDownloadUrl() else { return }
        
        var alert: UIAlertController?
        
        if compare(appstoreVersion: data.version) {
            alert = UIAlertController(title: applicationName, message: "Version \(data.version) is available on the AppStore", preferredStyle: UIAlertController.Style.alert)
            alert?.addAction(UIAlertAction(title: "Update", style: UIAlertAction.Style.destructive, handler: { action in
                guard let url = URL(string: data.downloadUrl) else { return }
                UIApplication.shared.open(url)
            }))
            
            if !isForce {
                alert?.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            }
        } 
        
        guard let _alert = alert else { return }
        UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .present(_alert, animated: true, completion: {
            
        })
//        UIApplication.shared.keyWindow?.rootViewController?.present(_alert, animated: true, completion: {
//
//        })
    }
    
    private class func normalizeVersion(_ version: String, toLength length: Int) -> String {
        var components = version.split(separator: ".").map(String.init)
        while components.count < length {
            components.append("0")
        }
        return components.joined(separator: ".")
    }

    private class func compareVersions(_ current: String, _ appStore: String) -> ComparisonResult {
        let currentComponents = current.split(separator: ".").map(String.init)
        let appStoreComponents = appStore.split(separator: ".").map(String.init)
        let maxLength = max(currentComponents.count, appStoreComponents.count)
        
        let normalizedCurrent = normalizeVersion(current, toLength: maxLength)
        let normalizedAppStore = normalizeVersion(appStore, toLength: maxLength)
        
        return normalizedCurrent.compare(normalizedAppStore, options: .numeric)
    }
    
    private class func compare(appstoreVersion: String) -> Bool {
        guard let deviceVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return false }
        
        print(deviceVersion)
        print(appstoreVersion)
        
        let versionCompare = compareVersions(deviceVersion, appstoreVersion)
        
        if versionCompare == .orderedSame {
            print("Same version")
            return false
        } else if versionCompare == .orderedAscending {
            print("Ask user to update")
            return true
        } else { //if versionCompare == .orderedDescending {
            print("Don't expect happen...")
            return false
        }
        
//        if appstoreVersion.compare(deviceVersion, options: .numeric) == .orderedDescending {
//            return true
//        } else {
//            return false
//        }
    }
}
