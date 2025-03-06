# MCPSwiftWrapper

[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
[![swift-package-manager](https://img.shields.io/badge/package%20manager-compatible-brightgreen.svg?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iNjJweCIgaGVpZ2h0PSI0OXB4IiB2aWV3Qm94PSIwIDAgNjIgNDkiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+CiAgICA8IS0tIEdlbmVyYXRvcjogU2tldGNoIDYzLjEgKDkyNDUyKSAtIGh0dHBzOi8vc2tldGNoLmNvbSAtLT4KICAgIDx0aXRsZT5Hcm91cDwvdGl0bGU+CiAgICA8ZGVzYz5DcmVhdGVkIHdpdGggU2tldGNoLjwvZGVzYz4KICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgICAgIDxnIGlkPSJHcm91cCIgZmlsbC1ydWxlPSJub256ZXJvIj4KICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGw9IiNEQkI1NTEiIHBvaW50cz0iNTEuMzEwMzQ0OCAwIDEwLjY4OTY1NTIgMCAwIDEzLjUxNzI0MTQgMCA0OSA2MiA0OSA2MiAxMy41MTcyNDE0Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDI1IDMxIDI1IDM1IDI1IDM3IDI1IDM3IDE0IDI1IDE0IDI1IDI1Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRUZDNzVFIiBwb2ludHM9IjEwLjY4OTY1NTIgMCAwIDE0IDYyIDE0IDUxLjMxMDM0NDggMCI+PC9wb2x5Z29uPgogICAgICAgICAgICA8cG9seWdvbiBpZD0iUmVjdGFuZ2xlIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDAgMzUgMCAzNyAxNCAyNSAxNCI+PC9wb2x5Z29uPgogICAgICAgIDwvZz4KICAgIDwvZz4KPC9zdmc+)](https://github.com/apple/swift-package-manager)
[![Buy me a coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-048754?logo=buymeacoffee)](https://buymeacoffee.com/jamesrochabrun)

A lightweight wrapper around [mcp-swift-sdk](https://github.com/gsabran/mcp-swift-sdk) that integrates with LLM Swift libraries such as [SwiftOpenAI](https://github.com/jamesrochabrun/SwiftOpenAI) and [SwiftAnthropic](https://github.com/jamesrochabrun/SwiftAnthropic) to easily create your own MCP Clients in macOS applications.

## What is MCP?

[The Model Context Protocol](https://github.com/modelcontextprotocol) (MCP) is an open protocol that enables AI models to securely interact with local and remote resources through standardized server implementations. MCP allows AI models to:

- Discover available tools
- Call these tools with parameters
- Receive responses in a standardized format

By using MCP, developers can create applications that give AI models controlled access to functionality like accessing files, making API calls, or running code.

## Requirements

- macOS 14.0+
- Swift 6.0+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/jamesrochabrun/MCPSwiftWrapper", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File > Add Package Dependencies
2. Enter the GitHub URL: `https://github.com/jamesrochabrun/MCPSwiftWrapper`
3. Click Add Package

## Getting Started

### Initializing a Client

To use MCP tools, you need to initialize an MCP client that connects to a tool provider. The example below shows how to create a GitHub MCP client:

```swift
import MCPSwiftWrapper
import Foundation
import SwiftUI

final class GithubMCPClient {
    init() {
        Task {
            do {
                self.client = try await MCPClient(
                    info: .init(name: "GithubMCPClient", version: "1.0.0"),
                    transport: .stdioProcess(
                        "npx",
                        args: ["-y", "@modelcontextprotocol/server-github"],
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
    
    /// Get the initialized client using Swift async/await
    func getClientAsync() async throws -> MCPClient? {
        for await client in clientInitialized.stream {
            return client
        }
        return nil // Stream completed without a client
    }
    
    private var client: MCPClient?
    private let clientInitialized = AsyncStream.makeStream(of: MCPClient?.self)
}
```

## Usage with Anthropic

### Getting Tools for Anthropic

```swift
// Create an Anthropic service
let service = AnthropicServiceFactory.service(
    apiKey: "your-api-key", 
    betaHeaders: nil, 
    debugEnabled: true
)

// Initialize the chat manager
let chatManager = AnthropicNonStreamManager(service: service)

// Initialize an MCP client
let githubClient = GithubMCPClient()

// Get the MCP client
if let client = try await githubClient.getClientAsync() {
    // Get available tools from MCP and convert them to Anthropic format
    let tools = try await client.anthropicTools()
    
    // Now you can use these tools with Anthropic API
    let parameters = AnthropicParameters(
        model: .claude37Sonnet,
        messages: messages,
        maxTokens: 10000,
        tools: tools
    )
    
    // Make the request to Claude
    let response = try await service.createMessage(parameters)
}
```

### Handling Tool Calls for Anthropic

When Claude requests to use a tool, you can handle it like this:

```swift
// When a tool use is detected in the response content
case .toolUse(let tool):
    print("Tool use detected - Name: \(tool.name), ID: \(tool.id)")
    
    // Call the tool via MCP
    let toolResponse = await mcpClient?.anthropicCallTool(
        name: tool.name, 
        input: tool.input, 
        debug: true
    )
    
    // Add tool result to conversation
    if let toolResult = toolResponse {
        // Add the tool result to the conversation
        anthropicMessages.append(AnthropicMessage(
            role: .user,
            content: .list([.toolResult(tool.id, toolResult)])
        ))
        
        // Continue the conversation with the tool result
        try await continueConversation(tools: tools)
    }
```

## Usage with OpenAI

### Getting Tools for OpenAI

```swift
// Create an OpenAI service
let openAIService = OpenAIServiceFactory.service(
    apiKey: "your-api-key", 
    debugEnabled: true
)

// Initialize the chat manager
let chatManager = OpenAIChatNonStreamManager(service: openAIService)

// Initialize an MCP client
let githubClient = GithubMCPClient()

// Get the MCP client
if let client = try await githubClient.getClientAsync() {
    // Get available tools from MCP and convert them to OpenAI format
    let tools = try await client.openAITools()
    
    // Now you can use these tools with OpenAI API
    let parameters = OpenAIParameters(
        messages: messages,
        model: .gpt4o,
        toolChoice: .auto,
        tools: tools
    )
    
    // Make the request to OpenAI
    let response = try await service.startChat(parameters: parameters)
}
```

### Handling Tool Calls for OpenAI

When GPT requests to use a tool, you can handle it like this:

```swift
// Process tool calls if any
if let toolCalls = message.toolCalls, !toolCalls.isEmpty {
    for toolCall in toolCalls {
        let function = toolCall.function
        guard
            let id = toolCall.id,
            let name = function.name,
            let argumentsData = function.arguments.data(using: .utf8)
        else {
            continue
        }

        // Parse arguments from string to dictionary
        let arguments: [String: Any]
        do {
            guard let parsedArgs = try JSONSerialization.jsonObject(with: argumentsData) as? [String: Any] else {
                continue
            }
            arguments = parsedArgs
        } catch {
            print("Error parsing tool arguments: \(error)")
            continue
        }

        // Call tool via MCP
        let toolResponse = await mcpClient.openAICallTool(
            name: name, 
            input: arguments, 
            debug: true
        )
        
        // Add tool result to conversation
        if let toolResult = toolResponse {
            // Add the tool result as a tool message
            openAIMessages.append(OpenAIMessage(
                role: .tool,
                content: .text(toolResult),
                toolCallID: id
            ))
            
            // Continue the conversation with the tool result
            try await continueConversation(tools: tools)
        }
    }
}
```

## Complete Example

Check out the included example application in the `Example/MCPClientChat` directory for a full implementation of a chat application using MCP with both Anthropic and OpenAI models.

## License

This project is available under the MIT license. See the LICENSE file for more info.
