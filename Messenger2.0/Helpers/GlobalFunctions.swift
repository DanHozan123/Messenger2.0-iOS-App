//
//  GlobalFunctions.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 07.02.2024.
//

import Foundation


func fileNameFrom(fileUrl: String) -> String {
    return ((fileUrl.components(separatedBy: "_").last)!.components(separatedBy: "?").first!).components(separatedBy: ".").first!
}
