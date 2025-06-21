//
//  KakaoPayModel.swift
//  TermProject-이주연-2191047
//
//  Created by 이주연 on 6/21/25.
//

import Foundation

struct KakaoPayResponse: Codable {
    let tid: String
    let next_redirect_app_url: String
    let next_redirect_mobile_url: String
    let next_redirect_pc_url: String
    let android_app_scheme: String
    let ios_app_scheme: String
    let created_at: String
}

