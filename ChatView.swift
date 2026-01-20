//
//  ChatView.swift
//  FamSphere
//
//  Created by Vinays Mac on 12/30/25.
//

import SwiftUI
import SwiftData
import MessageUI

struct ChatView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \ChatMessage.timestamp, order: .forward)
    private var allMessages: [ChatMessage]
    
    @State private var newMessageText: String = ""
    @State private var showingMessageComposer = false
    @State private var messageToShare: ChatMessage?
    @State private var searchText: String = ""
    @State private var messageFilter: MessageFilter = .all
    @State private var showingPrivacyPolicy = false
    @FocusState private var isTextFieldFocused: Bool
    @StateObject private var notificationManager = NotificationManager.shared
    
    // Computed properties for filtered messages
    private var pinnedMessages: [ChatMessage] {
        allMessages.filter { $0.isPinned }
    }
    
    private var filteredMessages: [ChatMessage] {
        var messages = allMessages.filter { !$0.isPinned }
        
        // Apply message type filter
        switch messageFilter {
        case .all:
            break
        case .system:
            messages = messages.filter { $0.isSystemMessage }
        case .family:
            messages = messages.filter { !$0.isSystemMessage }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            messages = messages.filter { message in
                matchesSearch(message: message, searchText: searchText)
            }
        }
        
        return messages
    }
    
    private var hasActiveFilters: Bool {
        !searchText.isEmpty || messageFilter != .all
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Picker (if not searching)
                if searchText.isEmpty {
                    filterPicker
                }
                
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if allMessages.isEmpty {
                                emptyStateView
                            } else if filteredMessages.isEmpty && hasActiveFilters {
                                searchEmptyStateView
                            } else {
                                // Pinned Messages Section
                                if !pinnedMessages.isEmpty && messageFilter == .all {
                                    pinnedMessagesSection
                                    
                                    // Divider between pinned and regular messages
                                    if !filteredMessages.isEmpty {
                                        HStack {
                                            Rectangle()
                                                .fill(Color.secondary.opacity(0.3))
                                                .frame(height: 1)
                                            
                                            Text("Messages")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .padding(.horizontal, 8)
                                            
                                            Rectangle()
                                                .fill(Color.secondary.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                        .padding(.vertical, 8)
                                    }
                                }
                                
                                // Regular Messages
                                ForEach(filteredMessages) { message in
                                    MessageBubbleView(
                                        message: message,
                                        currentUserName: appSettings.currentUserName,
                                        searchText: searchText
                                    )
                                    .id(message.persistentModelID)
                                    .contextMenu {
                                        contextMenuButtons(for: message)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: allMessages.count) { _, _ in
                        if let lastMessage = allMessages.last, searchText.isEmpty {
                            withAnimation {
                                proxy.scrollTo(lastMessage.persistentModelID, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Message Input
                HStack(spacing: 12) {
                    TextField("Message", text: $newMessageText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                        .focused($isTextFieldFocused)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.gray
                                : Color.blue
                            )
                    }
                    .disabled(newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(uiColor: .systemBackground))
            }
            .navigationTitle("Family Chat")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search messages")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingPrivacyPolicy = true
                    } label: {
                        Image(systemName: "lock.shield.fill")
                            .font(.body)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingMessageComposer) {
                if let message = messageToShare {
                    MessageComposeView(messageText: message.content)
                }
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
    }
    
    // MARK: - View Components
    
    private var filterPicker: some View {
        Picker("Message Filter", selection: $messageFilter) {
            ForEach(MessageFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    private var pinnedMessagesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "pin.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                
                Text("Pinned Messages")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
            .padding(.horizontal, 4)
            
            ForEach(pinnedMessages) { message in
                MessageBubbleView(
                    message: message,
                    currentUserName: appSettings.currentUserName,
                    searchText: searchText,
                    showPinnedIndicator: true
                )
                .id(message.persistentModelID)
                .contextMenu {
                    contextMenuButtons(for: message)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Start a conversation")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Chat, decisions, and memories — searchable in one place")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var searchEmptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No messages match")
                .font(.title2)
                .fontWeight(.medium)
            
            if !searchText.isEmpty {
                Text("'\(searchText)'")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Context Menu
    
    @ViewBuilder
    private func contextMenuButtons(for message: ChatMessage) -> some View {
        Button {
            togglePin(message)
        } label: {
            Label(
                message.isPinned ? "Unpin Message" : "Pin Message",
                systemImage: message.isPinned ? "pin.slash" : "pin.fill"
            )
        }
        
        Button {
            toggleImportant(message)
        } label: {
            Label(
                message.isImportant ? "Unmark Important" : "Mark Important",
                systemImage: message.isImportant ? "star.slash" : "star.fill"
            )
        }
        
        if appSettings.iMessageSharingEnabled {
            Button {
                messageToShare = message
                showingMessageComposer = true
            } label: {
                Label("Send via iMessage", systemImage: "message.fill")
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func matchesSearch(message: ChatMessage, searchText: String) -> Bool {
        let lowercasedSearch = searchText.lowercased()
        
        // Search in message content
        if message.content.lowercased().contains(lowercasedSearch) {
            return true
        }
        
        // Search in author name
        if message.authorName.lowercased().contains(lowercasedSearch) {
            return true
        }
        
        return false
    }
    
    private func sendMessage() {
        let trimmed = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let message = ChatMessage(content: trimmed, authorName: appSettings.currentUserName)
        modelContext.insert(message)
        
        // Schedule notification for other family members if enabled
        if appSettings.notificationsEnabled {
            let messageIdString = message.persistentModelID.hashValue.description
            Task {
                try? await notificationManager.scheduleMessageNotification(
                    messageId: messageIdString,
                    authorName: appSettings.currentUserName,
                    content: trimmed,
                    currentUserName: appSettings.currentUserName
                )
            }
        }
        
        newMessageText = ""
        isTextFieldFocused = false
    }
    
    private func toggleImportant(_ message: ChatMessage) {
        message.isImportant.toggle()
    }
    
    private func togglePin(_ message: ChatMessage) {
        message.isPinned.toggle()
    }
}

// MARK: - Message Filter Enum

enum MessageFilter: String, CaseIterable {
    case all = "All"
    case system = "System"
    case family = "Family"
}

// MARK: - Message Bubble View

struct MessageBubbleView: View {
    let message: ChatMessage
    let currentUserName: String
    var searchText: String = ""
    var showPinnedIndicator: Bool = false
    
    private var isCurrentUser: Bool {
        message.authorName == currentUserName
    }
    
    private var isSystemMessage: Bool {
        message.isSystemMessage
    }
    
    var body: some View {
        HStack {
            if isCurrentUser && !isSystemMessage {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isSystemMessage ? .center : (isCurrentUser ? .trailing : .leading), spacing: 4) {
                // System messages show centered with distinct styling
                if isSystemMessage {
                    systemMessageView
                } else {
                    userMessageView
                }
            }
            
            if !isCurrentUser && !isSystemMessage {
                Spacer(minLength: 60)
            }
        }
    }
    
    // MARK: - System Message View
    
    private var systemMessageView: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "app.badge.fill")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                
                Text("FamSphere")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }
            
            HStack(spacing: 6) {
                if message.isPinned && showPinnedIndicator {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                
                if message.isImportant {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
                
                highlightedText(message.content)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.blue.opacity(0.3), lineWidth: 1)
            )
            
            Text(message.timestamp, style: .time)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - User Message View
    
    private var userMessageView: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
            if !isCurrentUser {
                Text(message.authorName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 6) {
                if message.isPinned && showPinnedIndicator {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(isCurrentUser ? .white.opacity(0.9) : .orange)
                }
                
                if message.isImportant {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(isCurrentUser ? .white.opacity(0.9) : .yellow)
                }
                
                highlightedText(message.content)
                    .font(.body)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isCurrentUser ? Color.blue : Color(uiColor: .systemGray5))
            .foregroundStyle(isCurrentUser ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text(message.timestamp, style: .time)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Highlighted Text
    
    @ViewBuilder
    private func highlightedText(_ text: String) -> some View {
        if searchText.isEmpty {
            Text(text)
        } else {
            // Highlight matching search terms
            let attributedString = highlightMatches(in: text, searchText: searchText)
            Text(attributedString)
        }
    }
    
    private func highlightMatches(in text: String, searchText: String) -> AttributedString {
        var attributedString = AttributedString(text)
        let lowercasedText = text.lowercased()
        let lowercasedSearch = searchText.lowercased()
        
        var searchStartIndex = lowercasedText.startIndex
        
        while let range = lowercasedText.range(of: lowercasedSearch, range: searchStartIndex..<lowercasedText.endIndex) {
            // Convert String.Index to AttributedString.Index
            if let attributedRange = Range<AttributedString.Index>(range, in: attributedString) {
                attributedString[attributedRange].backgroundColor = .yellow.opacity(0.4)
                attributedString[attributedRange].foregroundColor = .primary
            }
            
            searchStartIndex = range.upperBound
        }
        
        return attributedString
    }
}

// MARK: - Message Composer (iMessage Integration)

struct MessageComposeView: UIViewControllerRepresentable {
    let messageText: String
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.body = messageText
        controller.messageComposeDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            dismiss()
        }
    }
}

#Preview {
    ChatView()
        .environment(AppSettings())
        .modelContainer(for: [FamilyMember.self, ChatMessage.self, CalendarEvent.self, Goal.self])
}
