//
//  env.swift
//  Search Plus
//
//  Created by McCoy Zhu on 11/20/20.
//

import SwiftUI

class ENV: ObservableObject {
    @Published var username = "mccoy_appleseed"
    @Published var lastSavedUsername = ""
    
    @Published var bio = "Simplicity is the ultimate sophistication."
    @Published var lastSavedBio = ""
    
    @Published var email = "mccoy.zhu@nyu.edu"
    @Published var lastSavedEmail = ""
    
    @Published var phone = "2124439999"
    @Published var lastSavedPhone = ""
    
    @Published var autoLogin = false
    
    @Published var contactSyncing = false
    
    @Published var isAccountPrivate = true
    
    @Published var allowComments = PrivacyOptions.followerOnly
    
    @Published var allowMentions = PrivacyOptions.everyOne
    
    @Published var allowMessages = PrivacyOptions.followingAndFollower
}

let env = ENV()
