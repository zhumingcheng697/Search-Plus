//
//  Command.swift
//  Search Plus
//
//  Created by McCoy Zhu on 11/20/20.
//

import SwiftUI

class Command: Identifiable {
    let name: String
    let pathName: String
    var keywords: Set<String> = []
    var isSuggested: Bool
    private var destinationView: (ENV) -> [(AnyView, String, String)]
    private var reset: (ENV) -> ()
    private var resetDisabled: (ENV) -> Bool
    
    init(name: String, directory: [String] = [], keywords: Set<String> = [], additionalKeywords: Set<String> = [], isSuggested: Bool = true, destinationView: @escaping (ENV) -> [(AnyView, String, String)], reset: @escaping (ENV) -> (), resetDisabled: @escaping (ENV) -> Bool) {
        self.name = name
        self.pathName = directory.joined(separator: " → ")
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
    
    func isMatch(of searchTerms: String) -> Bool {
        return searchTerms.split(separator: " ").allSatisfy { word in
            return self.keywords.contains(where: {$0.lowercased().contains(word.lowercased())})
        }
    }
    
    func destinationView(onDismiss: @escaping () -> ()) -> some View {
        return CommandDestinationViewWrapper(destination: self.destinationView, reset: self.reset, resetDisabled: self.resetDisabled, onDismiss: onDismiss)
    }
}

fileprivate func composeView<Content: View>(env: ENV, content: (ENV) -> Content, header: (ENV) -> String = {_ in ""}, footer: (ENV) -> String = {_ in ""}) -> (AnyView, String, String) {
    return (AnyView(content(env)), header(env), footer(env))
}

let commands = [
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
    Command(name: "Edit Bio",
            directory: ["Profile"],
            additionalKeywords: ["Change", "Modify", "Biography"],
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        TextEditor(text: .init(get: { env.bio }, set: { env.bio = $0 }))
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
    Command(name: "Auto Login",
            directory: ["Settings", "Security"],
            additionalKeywords: ["Edit", "Modify", "Change", "Automatically", "Username", "Password", "Devices"],
            destinationView: { env in
                [
                    composeView(env: env, content: { env in
                        Toggle("Log in Automatically", isOn: .init(get: { env.autoLogin }, set: { env.autoLogin = $0 }))
                            .navigationBarTitle("Auto Login")
                    }, footer: { _ in
                        "Choose whether to save your username and password and login automatically on all your devices."
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
    Command(name: "Contacts Syncing",
            directory: ["Settings", "Account"],
            additionalKeywords: ["Edit", "Modify", "Change", "Automatically", "Friends"],
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
    Command(name: "Change Email",
            directory: ["Settings", "Account", "Personal Info"],
            additionalKeywords: ["Edit", "Modify"],
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
    Command(name: "Change Number",
            directory: ["Settings", "Account", "Personal Info"],
            additionalKeywords: ["Edit", "Modify"],
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
    Command(name: "Account Privacy",
            directory: ["Settings", "Privacy"],
            additionalKeywords: ["Edit", "Modify", "Change", "Private", "Allow", "Visible", "Visibility"],
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
    Command(name: "Interaction Privacy",
            directory: ["Settings", "Privacy"],
            additionalKeywords: ["Edit", "Modify", "Change", "Private", "Allow", "Visible", "Visibility", "Comments", "Posts", "Mentions", "Messages"],
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
                        "Choose who send you direct messages."
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
    Command(name: "Comment Privacy",
            directory: ["Settings", "Privacy", "Interactions"],
            additionalKeywords: ["Edit", "Modify", "Change", "Private", "Allow", "Comments", "Posts"],
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
    Command(name: "Mentions Privacy",
            directory: ["Settings", "Privacy", "Interactions"],
            additionalKeywords: ["Edit", "Modify", "Change", "Private", "Allow", "Posts"],
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
    Command(name: "Message Privacy",
            directory: ["Settings", "Privacy", "Interactions"],
            additionalKeywords: ["Edit", "Modify", "Change", "Private", "Allow", "Messages", "Direct"],
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
                        "Choose who send you direct messages."
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
