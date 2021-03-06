//
//  Command.swift
//  Search Plus
//
//  Created by McCoy Zhu on 11/20/20.
//

import SwiftUI

class Command: Identifiable {
    let name: String
    private let directory: [String]
    private var keywords: Set<String> = []
    var isSuggested: Bool
    private var destinationView: (ENV) -> [(AnyView, String, String)]
    private var reset: (ENV) -> ()
    private var resetDisabled: (ENV) -> Bool
    
    init(name: String, directory: [String] = [], keywords: Set<String> = [], additionalKeywords: Set<String> = [], isSuggested: Bool = true, destinationView: @escaping (ENV) -> [(AnyView, String, String)], reset: @escaping (ENV) -> (), resetDisabled: @escaping (ENV) -> Bool) {
        self.name = name
        self.directory = directory
        self.isSuggested = isSuggested
        self.destinationView = destinationView
        self.reset = reset
        self.resetDisabled = resetDisabled
        
        if keywords.isEmpty {
            for word in name.split(separator: " ") {
                self.keywords.insert(word.lowercased())
            }
            
            for path in directory {
                for word in path.split(separator: " ") {
                    self.keywords.insert(word.lowercased())
                }
            }
            
            for keyword in additionalKeywords {
                self.keywords.insert(keyword.lowercased())
            }
        } else {
            self.keywords = keywords
        }
    }
    
    func pathName(level: Int? = nil) -> String {
        if let level = level, level > 0 {
            return self.directory.prefix(level).joined(separator: " → ")
        }
        return self.directory.joined(separator: " → ")
    }
    
    func isMatch(of searchTerms: String) -> Bool {
        return searchTerms.split(separator: " ").allSatisfy { word in
            return self.keywords.contains(where: {$0.lowercased().starts(with: word.lowercased())})
        }
    }
    
    func destinationView(onDismiss: @escaping () -> ()) -> some View {
        return CommandDestinationViewWrapper(destination: self.destinationView, reset: self.reset, resetDisabled: self.resetDisabled, onDismiss: onDismiss).navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate func composeView<Content: View>(env: ENV, content: (ENV) -> Content, header: (ENV) -> String = {_ in ""}, footer: (ENV) -> String = {_ in ""}) -> (AnyView, String, String) {
    return (AnyView(content(env)), header(env), footer(env))
}

let commands = [
    // MARK: - Edit Username
    Command(name: "Edit Username",
            directory: ["Profile"],
            additionalKeywords: ["Change", "Modify"],
            isSuggested: false,
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        HStack {
                            Text("Username")
                            
                            Divider()
                            
                            TextField("john_appleseed", text: .init(get: { env.username }, set: { env.username = $0 }))
                                .textContentType(.username)
                                .autocapitalization(.none)
                            
                        }.onAppear {
                            env.lastSavedUsername = env.username
                        }.navigationBarTitle("Edit Username")
                    }, footer: { env in
                        env.username == env.lastSavedUsername ? "You can only edit your username once every 14 days." : "You will need to use your new username \"\(env.username)\" next time you log in."
                    })
                ]
            },
            reset: { env in
                env.username = env.lastSavedUsername
            },
            resetDisabled: { env in
                env.username == env.lastSavedUsername
            }
    ),
    
    // MARK: - Edit Website
    Command(name: "Edit Homepage",
            directory: ["Profile"],
            additionalKeywords: ["Change", "Modify", "URL", "Webpage", "Website"],
            isSuggested: false,
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        HStack {
                            Text("Homepage")
                            
                            Divider()
                            
                            TextField("instagram.com/\(env.username)", text: .init(get: { env.homepage }, set: { env.homepage = $0 }))
                                .textContentType(.URL)
                                .autocapitalization(.none)
                                .keyboardType(.URL)
                            
                        }.onAppear {
                            env.lastSavedHomepage = env.homepage
                        }.navigationBarTitle("Edit Homepage")
                    }, footer: { env in
                        "Your homepage is visible to everyone."
                    })
                ]
            },
            reset: { env in
                env.homepage = env.lastSavedHomepage
            },
            resetDisabled: { env in
                env.homepage == env.lastSavedHomepage
            }
    ),
    
    // MARK: - Edit Bio
    Command(name: "Edit Bio",
            directory: ["Profile"],
            additionalKeywords: ["Change", "Modify", "Biography"],
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        TextEditor(text: .init(get: { env.bio }, set: { env.bio = $0 }))
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                            .background(Color(UIColor.systemBackground))
                            .frame(minHeight: 100, maxHeight: .infinity)
                            .navigationBarTitle("Edit Bio")
                            .onAppear {
                                env.lastSavedBio = env.bio
                            }
                    }, footer: { _ in
                        "Your bio is visible to everyone."
                    })
                ]
            },
            reset: { env in
                env.bio = env.lastSavedBio
            },
            resetDisabled: { env in
                env.bio == env.lastSavedBio
            }
    ),
    
    // MARK: - Notifications
    Command(name: "Notifications",
            directory: ["Settings"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Alerts", "Likes", "Comments", "Messages", "Direct", "Live", "Videos", "New", "Followers"],
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        Group {
                            Toggle("Likes from People I Follow", isOn: .init(get: { env.likeNotification.following }, set: { env.likeNotification.following = $0 }))
                            
                            Toggle("Likes from My Followers", isOn: .init(get: { env.likeNotification.follower }, set: { env.likeNotification.follower = $0 }))
                            
                            Toggle("Likes from Others", isOn: .init(get: { env.likeNotification.others }, set: { env.likeNotification.others = $0 }))
                        }.navigationBarTitle("Notifications")
                    }, header: { _ in
                        "Likes"
                    }, footer: { env in
                        "Choose when to notify you when someone liked your posts."
                    }),
                    
                    composeView(env: env, content: { env in
                        Group {
                            Toggle("Comments from People I Follow", isOn: .init(get: { env.commentNotification.following }, set: { env.commentNotification.following = $0 }))
                            
                            Toggle("Comments from My Followers", isOn: .init(get: { env.commentNotification.follower }, set: { env.commentNotification.follower = $0 }))
                            
                            Toggle("Comments from Others", isOn: .init(get: { env.commentNotification.others }, set: { env.commentNotification.others = $0 }))
                        }.navigationBarTitle("Notifications")
                    }, header: { _ in
                        "Comments"
                    }, footer: { _ in
                        "Choose when to notify you when someone commented under your posts."
                    }),
                    
                    composeView(env: env, content: { env in
                        Toggle("Live Videos", isOn: .init(get: { env.liveVideoNotification }, set: { env.liveVideoNotification = $0 }))
                            .navigationBarTitle("Notifications")
                    }, footer: { _ in
                        "Choose whether to notify you when someone you follow started a live video."
                    }),
                    
                    composeView(env: env, content: { env in
                        Toggle("New Followers", isOn: .init(get: { env.newFollowerNotification }, set: { env.newFollowerNotification = $0 }))
                            .navigationBarTitle("Notifications")
                    }, footer: { _ in
                        "Choose whether to notify you when someone started following you."
                    }),
                    
                    composeView(env: env, content: { env in
                        Toggle("Direct Messages", isOn: .init(get: { env.directMessageNotification }, set: { env.directMessageNotification = $0 }))
                            .navigationBarTitle("Notifications")
                    }, footer: { _ in
                        "Choose whether to notify you when someone sent you a direct message."
                    })
                ]
            },
            reset: { env in
                env.likeNotification = (following: true, follower: true, others: true)
                env.commentNotification = (following: true, follower: true, others: true)
                env.liveVideoNotification = true
                env.newFollowerNotification = true
                env.directMessageNotification = true
            },
            resetDisabled: { env in
                env.likeNotification == (following: true, follower: true, others: true) && env.commentNotification == (following: true, follower: true, others: true) && env.liveVideoNotification == true && env.newFollowerNotification == true && env.directMessageNotification == true
            }
    ),
    
    // MARK: - Likes Notification
    Command(name: "Likes Notification",
            directory: ["Settings", "Notifications"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Alerts", "Likes", "New"],
            isSuggested: false,
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        Group {
                            Toggle("Likes from People I Follow", isOn: .init(get: { env.likeNotification.following }, set: { env.likeNotification.following = $0 }))
                            
                            Toggle("Likes from My Followers", isOn: .init(get: { env.likeNotification.follower }, set: { env.likeNotification.follower = $0 }))
                            
                            Toggle("Likes from Others", isOn: .init(get: { env.likeNotification.others }, set: { env.likeNotification.others = $0 }))
                        }.navigationBarTitle("Likes Notification")
                    }, footer: { env in
                        "Choose when to notify you when someone liked your posts."
                    })
                ]
            },
            reset: { env in
                env.likeNotification = (following: true, follower: true, others: true)
            },
            resetDisabled: { env in
                env.likeNotification == (following: true, follower: true, others: true)
            }
    ),
    
    // MARK: - Comments Notification
    Command(name: "Comments Notification",
            directory: ["Settings", "Notifications"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Alerts", "Comments", "New"],
            isSuggested: false,
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        Group {
                            Toggle("Comments from People I Follow", isOn: .init(get: { env.commentNotification.following }, set: { env.commentNotification.following = $0 }))
                            
                            Toggle("Comments from My Followers", isOn: .init(get: { env.commentNotification.follower }, set: { env.commentNotification.follower = $0 }))
                            
                            Toggle("Comments from Others", isOn: .init(get: { env.commentNotification.others }, set: { env.commentNotification.others = $0 }))
                        }.navigationBarTitle("Comments Notification")
                    }, footer: { _ in
                        "Choose when to notify you when someone commented under your posts."
                    })
                ]
            },
            reset: { env in
                env.commentNotification = (following: true, follower: true, others: true)
            },
            resetDisabled: { env in
                env.commentNotification == (following: true, follower: true, others: true)
            }
    ),
    
    // MARK: - Live Videos Notification
    Command(name: "Live Videos Notification",
            directory: ["Settings", "Notifications"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Alerts", "Live", "Videos", "New"],
            isSuggested: false,
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        Toggle("Live Videos", isOn: .init(get: { env.liveVideoNotification }, set: { env.liveVideoNotification = $0 }))
                            .navigationBarTitle("Live Videos Notification")
                    }, footer: { _ in
                        "Choose whether to notify you when someone you follow started a live video."
                    })
                ]
            },
            reset: { env in
                env.liveVideoNotification = true
            },
            resetDisabled: { env in
                env.liveVideoNotification == true
            }
    ),
    
    // MARK: - New Follower Notification
    Command(name: "New Follower Notification",
            directory: ["Settings", "Notifications"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Alerts", "New", "Followers"],
            isSuggested: false,
            destinationView: { env in
                [   
                    composeView(env: env, content: { env in
                        Toggle("New Followers", isOn: .init(get: { env.newFollowerNotification }, set: { env.newFollowerNotification = $0 }))
                            .navigationBarTitle("New Follower Notification")
                    }, footer: { _ in
                        "Choose whether to notify you when someone started following you."
                    })
                ]
            },
            reset: { env in
                env.newFollowerNotification = true
            },
            resetDisabled: { env in
                env.newFollowerNotification == true
            }
    ),
    
    // MARK: - Message Notification
    Command(name: "Message Notification",
            directory: ["Settings", "Notifications"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Alerts", "Messages", "Direct", "New"],
            isSuggested: false,
            destinationView: { env in
                [   
                    composeView(env: env, content: { env in
                        Toggle("Direct Messages", isOn: .init(get: { env.directMessageNotification }, set: { env.directMessageNotification = $0 }))
                            .navigationBarTitle("Message Notification")
                    }, footer: { _ in
                        "Choose whether to notify you when someone sent you a direct message."
                    })
                ]
            },
            reset: { env in
                env.directMessageNotification = true
            },
            resetDisabled: { env in
                env.directMessageNotification == true
            }
    ),
    
    // MARK: - Contacts Syncing
    Command(name: "Contacts Syncing",
            directory: ["Settings", "Account"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Automatically", "Friends"],
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        Toggle("Sync Contacts", isOn: .init(get: { env.contactSyncing }, set: { env.contactSyncing = $0 }))
                            .navigationBarTitle("Contacts Syncing")
                    }, footer: { _ in
                        "Choose whether to automatically find your friends in your contacts."
                    })
                ]
            },
            reset: { env in
                env.contactSyncing = false
            },
            resetDisabled: { env in
                env.contactSyncing == false
            }
    ),
    
    // MARK: - Change Email
    Command(name: "Change Email",
            directory: ["Settings", "Account", "Personal Info"],
            additionalKeywords: ["Edit", "Modify", "Address"],
            isSuggested: false,
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        HStack {
                            Text("Email")
                            
                            Divider()
                            
                            TextField("mccoy_appleseed@ins.com", text: .init(get: { env.email }, set: { env.email = $0 }))
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                            
                        }.onAppear {
                            env.lastSavedEmail = env.email
                        }.navigationBarTitle("Change Email")
                    }, footer: { _ in
                        "Your email address is only visible to yourself."
                    })
                ]
            },
            reset: { env in
                env.email = env.lastSavedEmail
            },
            resetDisabled: { env in
                env.email == env.lastSavedEmail
            }
    ),
    
    // MARK: - Change Number
    Command(name: "Change Number",
            directory: ["Settings", "Account", "Personal Info"],
            additionalKeywords: ["Edit", "Modify", "Telephone"],
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        HStack {
                            Text("Phone")
                            
                            Divider()
                            
                            TextField("123456789", text: .init(get: { env.phone }, set: { env.phone = $0 }))
                                .textContentType(.telephoneNumber)
                                .autocapitalization(.none)
                                .keyboardType(.phonePad)
                            
                        }.onAppear {
                            env.lastSavedPhone = env.phone
                        }.navigationBarTitle("Change Phone Number")
                    }, footer: { _ in
                        "Your phone number is only visible to yourself."
                    })
                ]
            },
            reset: { env in
                env.phone = env.lastSavedPhone
            },
            resetDisabled: { env in
                env.phone == env.lastSavedPhone
            }
    ),
    
    // MARK: - Auto Login
    Command(name: "Auto Login",
            directory: ["Settings", "Security"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Automatically", "Username", "Password", "Devices"],
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        Toggle("Log in Automatically", isOn: .init(get: { env.autoLogin }, set: { env.autoLogin = $0 }))
                            .navigationBarTitle("Auto Login")
                    }, footer: { _ in
                        "Choose whether to save your username and password and log in automatically on all your devices."
                    })
                ]
            },
            reset: { env in
                env.autoLogin = false
            },
            resetDisabled: { env in
                env.autoLogin == false
            }
    ),
    
    // MARK: - Account Privacy
    Command(name: "Account Privacy",
            directory: ["Settings", "Privacy"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Private", "Allowed", "Visible", "Visibility"],
            isSuggested: false,
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        Toggle("Private Account", isOn: .init(get: { env.isAccountPrivate }, set: { env.isAccountPrivate = $0 }))
                            .navigationBarTitle("Account Privacy")
                    }, footer: { _ in
                        "Set your account to private to make your account visible to your followers only."
                    })
                ]
            },
            reset: { env in
                env.isAccountPrivate = false
            },
            resetDisabled: { env in
                env.isAccountPrivate == false
            }
    ),
    
    // MARK: - Interaction Privacy
    Command(name: "Interaction Privacy",
            directory: ["Settings", "Privacy"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Private", "Allowed", "Comments", "Posts", "Mentions", "Messages"],
            isSuggested: false,
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        Picker(env.allowComments.rawValue, selection: .init(get: { env.allowComments }, set: { env.allowComments = $0 })) {
                            ForEach(PrivacyOptions.allCases, id: \.rawValue) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }.pickerStyle(MenuPickerStyle())
                        .animation(nil)
                        .navigationBarTitle("Interaction Privacy")
                    }, header: { _ in
                        "Allow Comments From"
                    }, footer: { _ in
                        "Choose who can comment under your posts."
                    }),
                    
                    composeView(env: env, content: { env in
                        Picker(env.allowMentions.rawValue, selection: .init(get: { env.allowMentions }, set: { env.allowMentions = $0 })) {
                            ForEach(PrivacyOptions.allCases, id: \.rawValue) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }.pickerStyle(MenuPickerStyle())
                        .animation(nil)
                        .navigationBarTitle("Interaction Privacy")
                    }, header: { _ in
                        "Allow Mentions From"
                    }, footer: { _ in
                        "Choose who can @mention you under their posts."
                    }),
                    
                    composeView(env: env, content: { env in
                        Picker(env.allowMessages.rawValue, selection: .init(get: { env.allowMessages }, set: { env.allowMessages = $0 })) {
                            ForEach(PrivacyOptions.allCases, id: \.rawValue) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }.pickerStyle(MenuPickerStyle())
                        .animation(nil)
                        .navigationBarTitle("Interaction Privacy")
                    }, header: { _ in
                        "Allow Direct Messages From"
                    }, footer: { _ in
                        "Choose who can send you direct messages."
                    })
                ]
            },
            reset: { env in
                env.allowComments = PrivacyOptions.everyOne
                env.allowMentions = PrivacyOptions.everyOne
                env.allowMessages = PrivacyOptions.followingOnly
            },
            resetDisabled: { env in
                env.allowComments == .everyOne && env.allowMentions == PrivacyOptions.everyOne && env.allowMessages == PrivacyOptions.followingOnly
            }
    ),
    
    // MARK: - Comment Privacy
    Command(name: "Comment Privacy",
            directory: ["Settings", "Privacy", "Interactions"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Private", "Allowed", "Comments", "Posts"],
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        Picker(env.allowComments.rawValue, selection: .init(get: { env.allowComments }, set: { env.allowComments = $0 })) {
                            ForEach(PrivacyOptions.allCases, id: \.rawValue) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }.pickerStyle(MenuPickerStyle())
                        .animation(nil)
                        .navigationBarTitle("Comment Privacy")
                    }, header: { _ in
                        "Allow Comments From"
                    }, footer: { _ in
                        "Choose who can comment under your posts."
                    })
                ]
            },
            reset: { env in
                env.allowComments = PrivacyOptions.everyOne
            },
            resetDisabled: { env in
                env.allowComments == PrivacyOptions.everyOne
            }
    ),
    
    // MARK: - Mentions Privacy
    Command(name: "Mentions Privacy",
            directory: ["Settings", "Privacy", "Interactions"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Private", "Allowed", "Posts"],
            isSuggested: false,
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        Picker(env.allowMentions.rawValue, selection: .init(get: { env.allowMentions }, set: { env.allowMentions = $0 })) {
                            ForEach(PrivacyOptions.allCases, id: \.rawValue) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }.pickerStyle(MenuPickerStyle())
                        .animation(nil)
                        .navigationBarTitle("Mentions Privacy")
                    }, header: { _ in
                        "Allow Mentions From"
                    }, footer: { _ in
                        "Choose who can @mention you under their posts."
                    })
                ]
            },
            reset: { env in
                env.allowMentions = PrivacyOptions.everyOne
            },
            resetDisabled: { env in
                env.allowMentions == PrivacyOptions.everyOne
            }
    ),
    
    // MARK: - Message Privacy
    Command(name: "Message Privacy",
            directory: ["Settings", "Privacy", "Interactions"],
            additionalKeywords: ["Set", "Edit", "Modify", "Change", "Private", "Allowed", "Messages", "Direct"],
            isSuggested: false,
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        Picker(env.allowMessages.rawValue, selection: .init(get: { env.allowMessages }, set: { env.allowMessages = $0 })) {
                            ForEach(PrivacyOptions.allCases, id: \.rawValue) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }.pickerStyle(MenuPickerStyle())
                        .animation(nil)
                        .navigationBarTitle("Message Privacy")
                    }, header: { _ in
                        "Allow Direct Messages From"
                    }, footer: { _ in
                        "Choose who can send you direct messages."
                    })
                ]
            },
            reset: { env in
                env.allowMessages = PrivacyOptions.followingOnly
            },
            resetDisabled: { env in
                env.allowMessages == PrivacyOptions.followingOnly
            }
    )
]
