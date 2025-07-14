//
//  MCPClientChatApp.swift
//  MCPClientChat
//
//  Created by James Rochabrun on 3/3/25.
//

import MCPSwiftWrapper
import SwiftUI

@main
struct MCPClientChatApp: App {

  // MARK: Lifecycle

  init() {
    let service = AnthropicServiceFactory.service(apiKey: "", betaHeaders: nil, debugEnabled: true)

    // Use streaming manager for better real-time experience
    let initialManager = AnthropicStreamManager(service: service)

    _chatManager = State(initialValue: initialManager)

    // Uncomment this and comment the above for OpenAI Streaming Demo

    //      let openAIService = OpenAIServiceFactory.service(apiKey: "", debugEnabled: true)
    //
    //      let openAIStreamManager = OpenAIChatStreamManager(service: openAIService)
    //
    //      _chatManager = State(initialValue: openAIStreamManager)
    
    // Non-streaming versions (for comparison):
    // let nonStreamManager = AnthropicNonStreamManager(service: service)
    // let openAINonStreamManager = OpenAIChatNonStreamManager(service: openAIService)
  }

  // MARK: Internal

  var body: some Scene {
    WindowGroup {
      ChatView(chatManager: chatManager)
        .toolbar(removing: .title)
        .containerBackground(
          .thinMaterial, for: .window)
        .toolbarBackgroundVisibility(
          .hidden, for: .windowToolbar)
        .task {
          if let client = try? await githubClient.getClientAsync() {
            chatManager.updateClient(client)
          }
        }
    }
    .windowStyle(.hiddenTitleBar)
  }

  // MARK: Private

  @State private var chatManager: ChatManager
  private let githubClient = GIthubMCPClient()
}
