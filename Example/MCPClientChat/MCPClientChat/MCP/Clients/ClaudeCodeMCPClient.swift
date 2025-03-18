//
//  ClaudeCodeMCPClient.swift
//  MCPClientChat
//
//  Created by James Rochabrun on 3/17/25.
//

import Foundation
import MCPClient
import SwiftUI

/// https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/tutorials#use-claude-code-as-an-mcp-server
final class ClaudeCodeMCPClient {
   
   // MARK: Lifecycle
   
   init() {
      Task {
         do {
            self.client = try await MCPClient(
               info: .init(name: "ClaudeCodeMCPClient", version: "1.0.0"),
               transport: .stdioProcess(
                  "claude",
                  args: ["mcp", "serve"],
                  verbose: true),
               capabilities: .init())
            clientInitialized.continuation.yield(self.client)
            clientInitialized.continuation.finish()
         } catch {
            print("Failed to initialize MCPClient: \(error)")
            clientInitialized.continuation.yield(nil)
            clientInitialized.continuation.finish()
         }
      }
   }
   
   // MARK: Internal
   
   /// Modern async/await approach
   func getClientAsync() async throws -> MCPClient? {
      for await client in clientInitialized.stream {
         return client
      }
      return nil // Stream completed without a client
   }
   
   // MARK: Private
   
   private var client: MCPClient?
   private let clientInitialized = AsyncStream.makeStream(of: MCPClient?.self)
}
