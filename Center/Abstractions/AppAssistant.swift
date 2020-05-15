//
//  AppAssistant.swift
//  MetCenter
//
//  Created by CavanSu on 2019/7/7.
//  Copyright © 2019 Agora. All rights reserved.
//
#if os(iOS)
import UIKit
#endif
import Foundation

class AppAssistant: NSObject {
    func checkMinVersion(success: Completion = nil) {
        let client = ALCenter.shared().centerProvideRequestHelper()
        let url = URLGroup.appVersion
        let event = RequestEvent(name: "app-version")
        let parameters: StringAnyDic = ["appCode": "ent-super",
                                        "osType": 1,
                                        "terminalType": 1,
                                        "version": AppAssistant.version]
        
        let task = RequestTask(event: event, type: .http(.get, url: url), timeout: .low, parameters: parameters)
        let successCallback: DicEXCompletion = { (json: ([String: Any])) throws in
            let data = try json.getDataObject()
            let config = try data.getDictionaryValue(of: "config")
            let appId = try config.getStringValue(of: "appId")
            ALKeys.AgoraAppId = appId
            
            if let success = success {
                success()
            }
        }
        let response = AGEResponse.json(successCallback)
        
        let retry: ErrorRetryCompletion = { (error: AGEError) -> RetryOptions in
            return .retry(after: 0.5, newTask: nil)
        }
        
        client.request(task: task, success: response, failRetry: retry)
    }
}

extension AppAssistant {
    static var name: String {
        return "Metroon"
    }

    static var version: String {
        guard let dic = Bundle.main.infoDictionary,
            let tVersion = dic["CFBundleShortVersionString"],
            let version = try? Convert.force(instance: tVersion, to: String.self) else {
                return "0"
        }
        return version
    }

    static var buildNumber: String {
        guard let dic = Bundle.main.infoDictionary,
            let tNumber = dic["CFBundleVersion"],
            let number = try? Convert.force(instance: tNumber, to: String.self) else {
            return "0"
        }
        return number
    }
}
