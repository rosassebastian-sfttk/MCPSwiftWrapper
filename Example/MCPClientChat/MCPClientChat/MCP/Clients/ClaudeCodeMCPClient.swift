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
      print("🏃 Running ClaudeCodeMCPClient")
      initializeClient()
   }
   
   private func initializeClient() {
      initializationTask = Task {
         do {
            print("🟡 Starting Claude Code MCP client initialization...")
            self.client = try await MCPClient(
               info: .init(name: "ClaudeCodeMCPClient", version: "1.0.0"),
               transport: .stdioProcess(
                  "claude",
                  args: ["mcp", "serve"],
                  verbose: true),
               capabilities: .init())
            clientInitialized.continuation.yield(self.client)
            clientInitialized.continuation.finish()
            print("☺️ Initialized MCP Client: ClaudeCodeMCPClient")
         } catch {
            print("❌ Failed to initialize ClaudeCodeMCPClient: \(error)")
            clientInitialized.continuation.yield(nil)
            clientInitialized.continuation.finish()
            
            // Retry initialization after a delay
            print("🔄 Retrying Claude Code MCP client initialization in 3 seconds...")
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled {
               initializeClient()
            }
         }
      }
   }
   
   // MARK: Internal
   
   /// Modern async/await approach with timeout
   func getClientAsync() async throws -> MCPClient? {
      // First check if we already have a client
      if let client = client {
         print("🟡 Using existing Claude Code client")
         return client
      }
      
      // Wait for client initialization
      print("🟡 Waiting for Claude Code client initialization...")
      for await client in clientInitialized.stream {
         return client
      }
      return nil // Stream completed without a client
   }
   
   /// Check if client is ready without waiting
   func isClientReady() -> Bool {
      return client != nil
   }
   
   /// Cancel initialization if needed
   func cancelInitialization() {
      print("🟡 Cancelling Claude Code MCP client initialization")
      initializationTask?.cancel()
   }
   
   // MARK: Private
   
   private var client: MCPClient?
   private let clientInitialized = AsyncStream.makeStream(of: MCPClient?.self)
   private var initializationTask: Task<Void, Never>?
}
