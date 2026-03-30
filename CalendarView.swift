//
//  CalendarView.swift
//  FamSphere
//
//  Created by Vinays Mac on 12/30/25.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \CalendarEvent.eventDate, order: .forward)
    private var allEvents: [CalendarEvent]
    
    @Query(sort: \FamilyMember.name)
    private var familyMembers: [FamilyMember]
    
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    @State private var showingAddGoal = false
    @State private var viewMode: CalendarViewMode = .week
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedTab: CalendarDayTab = .events // Track selected tab
    
    // MARK: - Single-Child Detection (Reused from Dashboard)
    
    private var children: [FamilyMember] {
        familyMembers.filter { $0.role == .child }
    }
    
    private var isSingleChild: Bool {
        children.count == 1
    }
    
    private var eventsForSelectedWeek: [CalendarEvent] {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? selectedDate
        
        return allEvents.filter { event in
            event.eventDate >= weekStart && event.eventDate < weekEnd
        }
    }
    
    private var searchResults: [CalendarEvent] {
        guard !searchText.isEmpty else { return [] }
        
        return allEvents.filter { event in
            // Case-insensitive contains search
            event.title.localizedCaseInsensitiveContains(searchText) ||
            event.notes.localizedCaseInsensitiveContains(searchText) ||
            event.eventType.rawValue.localizedCaseInsensitiveContains(searchText)
        }
        .sorted { $0.eventDate < $1.eventDate }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        TextField("Search events...", text: $searchText)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                if !searchText.isEmpty {
                                    isSearching = true
                                }
                            }
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                isSearching = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    if !searchText.isEmpty && !isSearching {
                        Button("Search") {
                            isSearching = true
                        }
                        .fontWeight(.medium)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                if isSearching && !searchText.isEmpty {
                    // Search Results
                    searchResultsView
                } else {
                    // View Mode Picker
                    Picker("View Mode", selection: $viewMode) {
                        Text("Week").tag(CalendarViewMode.week)
                        Text("Month").tag(CalendarViewMode.month)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Calendar Content
                    if viewMode == .week {
                        WeekCalendarView(
                            selectedDate: $selectedDate,
                            selectedTab: $selectedTab,
                            events: eventsForSelectedWeek,
                            isSingleChild: isSingleChild
                        )
                    } else {
                        MonthCalendarView(
                            selectedDate: $selectedDate,
                            selectedTab: $selectedTab,
                            events: allEvents,
                            isSingleChild: isSingleChild
                        )
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Responsibility Timeline")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if selectedTab == .deadlines {
                            print("🔵 Add Deadline (Goal) button tapped")
                            showingAddGoal = true
                        } else {
                            print("🔵 Add Event button tapped")
                            showingAddEvent = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
                
                if !isSearching {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            print("🔵 Today button tapped")
                            selectedDate = Date()
                        } label: {
                            Text("Today")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(selectedDate: selectedDate, initialTab: selectedTab)
                    .onAppear {
                        print("🔵 Presenting AddEventView sheet with tab: \(selectedTab)")
                    }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
                    .onAppear {
                        print("🔵 Presenting AddGoalView sheet for deadline")
                    }
            }
        }
    }
    
    // MARK: - Search Results View
    
    private var searchResultsView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(searchResults.count) result\(searchResults.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    isSearching = false
                } label: {
                    Text("Cancel")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            if searchResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundStyle(.secondary)
                    
                    Text("No events found")
                        .font(.headline)
                    
                    Text("Try searching for '\(searchText)'")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(searchResults) { event in
                            SearchResultRow(event: event) {
                                // Navigate to that date
                                selectedDate = event.eventDate
                                isSearching = false
                                searchText = ""
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct SearchResultRow: View {
    let event: CalendarEvent
    let onTap: () -> Void
    
    private var dateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: event.eventDate)
    }
    
    private var timeDisplay: String {
        let start = event.eventDate.formatted(date: .omitted, time: .shortened)
        if let end = event.endDate {
            let endFormatted = end.formatted(date: .omitted, time: .shortened)
            return "\(start) - \(endFormatted)"
        }
        return start
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Event Type Icon
                Image(systemName: event.eventType.icon)
                    .font(.title2)
                    .foregroundStyle(Color(hex: event.colorHex) ?? .blue)
                    .frame(width: 44, height: 44)
                    .background(Color(hex: event.colorHex)?.opacity(0.2) ?? Color.blue.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 8) {
                        Text(dateDisplay)
                            .font(.caption)
                        
                        Text("•")
                        
                        Text(timeDisplay)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    
                    if !event.notes.isEmpty {
                        Text(event.notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                    if event.isRecurring {
                        HStack(spacing: 4) {
                            Image(systemName: "repeat")
                                .font(.caption2)
                            Text("Recurring")
                                .font(.caption2)
                        }
                        .foregroundStyle(.blue)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

enum CalendarViewMode {
    case week
    case month
}

// MARK: - Week Calendar View

struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var selectedTab: CalendarDayTab
    let events: [CalendarEvent]
    let isSingleChild: Bool
    
    @Query(sort: \FamilyMember.name)
    private var familyMembers: [FamilyMember]
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Week Navigation
            HStack {
                Button(action: previousWeek) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }
                
                Spacer()
                
                Text(weekRange)
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextWeek) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            
            // Week Days
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { day in
                    WeekDayView(
                        date: day,
                        events: eventsForDay(day),
                        familyMembers: familyMembers,
                        isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate)
                    )
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        selectedDate = day
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Day Tabs View
            CalendarDayTabsView(
                selectedDate: selectedDate,
                selectedTab: $selectedTab,
                isSingleChild: isSingleChild
            )
        }
    }
    
    private var weekRange: String {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? selectedDate
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }
    
    private func eventsForDay(_ date: Date) -> [CalendarEvent] {
        events.filter { Calendar.current.isDate($0.eventDate, inSameDayAs: date) }
    }
    
    private func previousWeek() {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextWeek() {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
    }
}

struct WeekDayView: View {
    let date: Date
    let events: [CalendarEvent]
    let familyMembers: [FamilyMember]
    let isSelected: Bool
    
    @Query(sort: \Goal.targetDate, order: .forward)
    private var allGoals: [Goal]
    
    private var hasDeadline: Bool {
        allGoals.contains { goal in
            guard let targetDate = goal.targetDate else { return false }
            return Calendar.current.isDate(targetDate, inSameDayAs: date) && goal.status != .completed
        }
    }
    
    private var hasAnyActivity: Bool {
        !events.isEmpty || hasDeadline
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(date, format: .dateTime.weekday(.abbreviated))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ZStack {
                Text(date, format: .dateTime.day())
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : .primary)
                    .frame(width: 36, height: 36)
                    .background(isSelected ? Color.blue : Color.clear)
                    .clipShape(Circle())
            }
            
            // Activity indicator - blue dot below date
            if hasAnyActivity {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 4, height: 4)
            } else {
                // Empty space to maintain consistent height
                Color.clear
                    .frame(width: 4, height: 4)
            }
        }
    }
}

// MARK: - Month Calendar View

struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var selectedTab: CalendarDayTab
    let events: [CalendarEvent]
    let isSingleChild: Bool
    
    @Query(sort: \FamilyMember.name)
    private var familyMembers: [FamilyMember]
    
    private var monthDays: [Date?] {
        let calendar = Calendar.current
        let month = calendar.dateInterval(of: .month, for: selectedDate)
        guard let monthStart = month?.start, let monthEnd = month?.end else { return [] }
        
        var days: [Date?] = []
        
        // Add leading empty days
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        days.append(contentsOf: Array(repeating: nil, count: firstWeekday - 1))
        
        // Add month days
        var current = monthStart
        while current < monthEnd {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }
                
                Spacer()
                
                Text(selectedDate, format: .dateTime.month(.wide).year())
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            
            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(Calendar.current.veryShortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(monthDays.indices, id: \.self) { index in
                    if let day = monthDays[index] {
                        MonthDayView(
                            date: day,
                            events: eventsForDay(day),
                            familyMembers: familyMembers,
                            isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate)
                        )
                        .onTapGesture {
                            selectedDate = day
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Day Tabs View
            CalendarDayTabsView(
                selectedDate: selectedDate,
                selectedTab: $selectedTab,
                isSingleChild: isSingleChild
            )
        }
    }
    
    private func eventsForDay(_ date: Date) -> [CalendarEvent] {
        events.filter { Calendar.current.isDate($0.eventDate, inSameDayAs: date) }
    }
    
    private func previousMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextMonth() {
        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
    }
}

struct MonthDayView: View {
    let date: Date
    let events: [CalendarEvent]
    let familyMembers: [FamilyMember]
    let isSelected: Bool
    
    @Query(sort: \Goal.targetDate, order: .forward)
    private var allGoals: [Goal]
    
    private var hasDeadline: Bool {
        allGoals.contains { goal in
            guard let targetDate = goal.targetDate else { return false }
            return Calendar.current.isDate(targetDate, inSameDayAs: date) && goal.status != .completed
        }
    }
    
    private var hasAnyActivity: Bool {
        !events.isEmpty || hasDeadline
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(date, format: .dateTime.day())
                .font(.subheadline)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(width: 36, height: 36)
                .background(isSelected ? Color.blue : Color.clear)
                .clipShape(Circle())
            
            // Activity indicator - blue dot below date
            if hasAnyActivity {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 4, height: 4)
            } else {
                // Empty space to maintain consistent height
                Color.clear
                    .frame(width: 4, height: 4)
            }
        }
    }
}

// MARK: - Event Row View

struct EventRowView: View {
    let event: CalendarEvent
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query private var allEvents: [CalendarEvent]
    
    @State private var showingDeleteAlert = false
    @State private var showingRecurringDeleteOptions = false
    
    private var canDelete: Bool {
        appSettings.currentUserRole == .parent || event.createdByName == appSettings.currentUserName
    }
    
    private var timeDisplay: String {
        let start = event.eventDate.formatted(date: .omitted, time: .shortened)
        if let end = event.endDate {
            let endFormatted = end.formatted(date: .omitted, time: .shortened)
            return "\(start) - \(endFormatted)"
        }
        return start
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Event Type Icon
            Image(systemName: event.eventType.icon)
                .font(.title3)
                .foregroundStyle(Color(hex: event.colorHex) ?? .blue)
                .frame(width: 40, height: 40)
                .background(Color(hex: event.colorHex)?.opacity(0.2) ?? Color.blue.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Text(timeDisplay)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(event.eventType.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if event.isRecurring {
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: "repeat")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if !event.notes.isEmpty {
                    Text(event.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contextMenu {
            if canDelete {
                Button(role: .destructive) {
                    if event.isRecurring {
                        showingRecurringDeleteOptions = true
                    } else {
                        showingDeleteAlert = true
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .alert("Delete Event?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteEvent()
            }
        } message: {
            Text("Are you sure you want to delete this event?")
        }
        .confirmationDialog("Delete Recurring Event", isPresented: $showingRecurringDeleteOptions) {
            Button("Delete This Event Only") {
                deleteEvent()
            }
            
            Button("Delete All Future Events", role: .destructive) {
                deleteAllFutureEvents()
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This is a recurring event")
        }
    }
    
    private func deleteEvent() {
        modelContext.delete(event)
        print("🗑️ Deleted event: \(event.title)")
    }
    
    private func deleteAllFutureEvents() {
        guard let groupId = event.recurrenceGroupId else {
            deleteEvent()
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        let futureEvents = allEvents.filter {
            $0.recurrenceGroupId == groupId &&
            Calendar.current.startOfDay(for: $0.eventDate) >= today
        }
        
        futureEvents.forEach { modelContext.delete($0) }
        
        print("🗑️ Deleted \(futureEvents.count) future events from recurring series")
    }
}

// MARK: - Add Event View

struct AddEventView: View {
    let selectedDate: Date
    let initialTab: CalendarDayTab
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    
    @Query(sort: \FamilyMember.name)
    private var familyMembers: [FamilyMember]
    
    @State private var title = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var notes = ""
    @State private var selectedEventType: EventType
    @State private var selectedFormTab: CalendarDayTab
    
    // Recurrence
    @State private var isRecurring = false
    @State private var selectedDays: Set<Int> = []
    @State private var recurrenceEndDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    // Reminder
    @State private var hasReminder = false
    @State private var selectedReminder: ReminderOption = .fifteenMinutes
    @StateObject private var notificationManager = NotificationManager.shared
    
    init(selectedDate: Date, initialTab: CalendarDayTab) {
        self.selectedDate = selectedDate
        self.initialTab = initialTab
        
        // Set default dates to selected date
        let roundedStart = selectedDate.roundedToNearest15Minutes()
        _startDate = State(initialValue: roundedStart)
        _endDate = State(initialValue: roundedStart.addingTimeInterval(3600))
        
        // Set default type and tab based on initial tab
        switch initialTab {
        case .pickups:
            _selectedEventType = State(initialValue: .school)
            _selectedFormTab = State(initialValue: .pickups)
        case .events:
            _selectedEventType = State(initialValue: .personal)
            _selectedFormTab = State(initialValue: .events)
        case .deadlines:
            // Deadlines are goals, not events, but default to events tab
            _selectedEventType = State(initialValue: .personal)
            _selectedFormTab = State(initialValue: .events)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Event Title", text: $title)
                    
                    DatePicker("Starts", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    
                    DatePicker("Ends", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Type", selection: $selectedEventType) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }
                
                // Category Tab Selection
                Section {
                    Picker("Add to", selection: $selectedFormTab) {
                        ForEach([CalendarDayTab.pickups, CalendarDayTab.events], id: \.self) { tab in
                            Label(tab.rawValue, systemImage: tab == .pickups ? "car.fill" : "calendar")
                                .tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Category")
                } footer: {
                    Text(selectedFormTab == .pickups ? 
                        "This event will appear in the Pickups tab" : 
                        "This event will appear in the Events tab")
                }
                
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Toggle("Repeat", isOn: $isRecurring)
                    
                    if isRecurring {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Repeat On")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 8) {
                                ForEach(1...7, id: \.self) { day in
                                    DayButton(
                                        day: day,
                                        isSelected: selectedDays.contains(day)
                                    ) {
                                        if selectedDays.contains(day) {
                                            selectedDays.remove(day)
                                        } else {
                                            selectedDays.insert(day)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        
                        DatePicker("Until", selection: $recurrenceEndDate, in: startDate..., displayedComponents: .date)
                    }
                } header: {
                    Text("Recurrence")
                } footer: {
                    if isRecurring {
                        if selectedDays.isEmpty {
                            Text("Select at least one day to repeat")
                                .foregroundStyle(.red)
                        } else {
                            Text("Event will repeat on selected days until \(recurrenceEndDate, style: .date)")
                        }
                    }
                }
                
                // Reminder Section
                Section {
                    Toggle("Set Reminder", isOn: $hasReminder)
                    
                    if hasReminder {
                        Picker("Remind me", selection: $selectedReminder) {
                            ForEach(ReminderOption.allCases) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                    }
                } header: {
                    Text("Reminder")
                } footer: {
                    if hasReminder {
                        Text("You'll receive a notification \(selectedReminder.displayName.lowercased())")
                    } else {
                        Text("Get notified before this event starts")
                    }
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addEvent()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (isRecurring && selectedDays.isEmpty))
                }
            }
            .onChange(of: startDate) { oldValue, newValue in
                startDate = newValue.roundedToNearest15Minutes()
                // Auto-adjust end date to maintain duration
                if endDate <= startDate {
                    endDate = startDate.addingTimeInterval(3600)
                }
            }
            .onChange(of: endDate) { oldValue, newValue in
                endDate = newValue.roundedToNearest15Minutes()
                // Ensure end is after start
                if endDate <= startDate {
                    endDate = startDate.addingTimeInterval(900) // 15 minutes
                }
            }
        }
    }
    
    private func addEvent() {
        let currentMember = familyMembers.first { $0.name == appSettings.currentUserName }
        let colorHex = currentMember?.colorHex ?? "#4A90E2"
        
        if isRecurring && !selectedDays.isEmpty {
            createRecurringEvents(colorHex: colorHex)
        } else {
            createSingleEvent(colorHex: colorHex)
        }
        
        dismiss()
    }
    
    private func createSingleEvent(colorHex: String) {
        // If categorized as pickup, ensure it's school type or contains pickup keyword
        let finalTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        var finalEventType = selectedEventType
        
        if selectedFormTab == .pickups {
            finalEventType = .school
            // If title doesn't contain pickup keywords, suggest it's a pickup in notes if empty
            let hasPickupKeyword = finalTitle.lowercased().contains("pickup") ||
                                    finalTitle.lowercased().contains("pick up") ||
                                    finalTitle.lowercased().contains("dropoff") ||
                                    finalTitle.lowercased().contains("drop off")
            if !hasPickupKeyword && notes.isEmpty {
                // Title should naturally indicate it's a pickup, no need to force
            }
        }
        
        let event = CalendarEvent(
            title: finalTitle,
            eventDate: startDate,
            endDate: endDate,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            eventType: finalEventType,
            createdByName: appSettings.currentUserName,
            colorHex: colorHex,
            reminderMinutesBefore: hasReminder ? selectedReminder.rawValue : nil
        )
        
        modelContext.insert(event)
        
        // Schedule notification if reminder is set
        if hasReminder {
            let eventIdString = event.persistentModelID.hashValue.description
            Task {
                try? await notificationManager.scheduleEventReminder(
                    eventId: eventIdString,
                    title: finalTitle,
                    eventDate: startDate,
                    minutesBefore: selectedReminder.rawValue
                )
            }
        }
    }
    
    private func createRecurringEvents(colorHex: String) {
        let groupId = UUID().uuidString
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: recurrenceEndDate)
        
        // If categorized as pickup, ensure it's school type
        var finalEventType = selectedEventType
        if selectedFormTab == .pickups {
            finalEventType = .school
        }
        
        // Get time components from startDate and endDate
        let startComponents = calendar.dateComponents([.hour, .minute], from: startDate)
        let duration = endDate.timeIntervalSince(startDate)
        
        while currentDate <= endDay {
            let weekday = calendar.component(.weekday, from: currentDate)
            
            if selectedDays.contains(weekday) {
                // Apply time from original startDate
                if let eventTime = calendar.date(bySettingHour: startComponents.hour ?? 0,
                                                  minute: startComponents.minute ?? 0,
                                                  second: 0,
                                                  of: currentDate) {
                    let eventEndTime = eventTime.addingTimeInterval(duration)
                    
                    let event = CalendarEvent(
                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                        eventDate: eventTime,
                        endDate: eventEndTime,
                        notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                        eventType: finalEventType,
                        createdByName: appSettings.currentUserName,
                        colorHex: colorHex,
                        isRecurring: true,
                        recurrenceDays: Array(selectedDays),
                        recurrenceEndDate: recurrenceEndDate,
                        recurrenceGroupId: groupId,
                        reminderMinutesBefore: hasReminder ? selectedReminder.rawValue : nil
                    )
                    
                    modelContext.insert(event)
                    
                    // Schedule notification for each recurring event if reminder is set
                    if hasReminder {
                        let eventIdString = event.persistentModelID.hashValue.description
                        Task {
                            try? await notificationManager.scheduleEventReminder(
                                eventId: eventIdString,
                                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                eventDate: eventTime,
                                minutesBefore: selectedReminder.rawValue
                            )
                        }
                    }
                }
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        print("✅ Created recurring event: \(selectedDays.count) days, \(calendar.dateComponents([.day], from: startDate, to: recurrenceEndDate).day ?? 0) total events")
    }
}

// MARK: - Day Button

struct DayButton: View {
    let day: Int
    let isSelected: Bool
    let action: () -> Void
    
    private var dayName: String {
        ["S", "M", "T", "W", "T", "F", "S"][day - 1]
    }
    
    var body: some View {
        Button(action: action) {
            Text(dayName)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(width: 36, height: 36)
                .background(isSelected ? Color.blue : Color(.secondarySystemGroupedBackground))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Date Extension

extension Date {
    func roundedToNearest15Minutes() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        let minute = components.minute ?? 0
        let roundedMinute = (minute / 15) * 15
        
        return calendar.date(from: DateComponents(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: components.hour,
            minute: roundedMinute
        )) ?? self
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}

// MARK: - Calendar Day Tabs View

enum CalendarDayTab: String, CaseIterable {
    case pickups = "Pickups"
    case events = "Events"
    case deadlines = "Deadlines"
}

struct CalendarDayTabsView: View {
    let selectedDate: Date
    @Binding var selectedTab: CalendarDayTab
    let isSingleChild: Bool
    
    @Query(sort: \CalendarEvent.eventDate, order: .forward)
    private var allEvents: [CalendarEvent]
    
    @Query(sort: \Goal.targetDate, order: .forward)
    private var allGoals: [Goal]
    
    private var pickupEvents: [CalendarEvent] {
        allEvents.filter { event in
            Calendar.current.isDate(event.eventDate, inSameDayAs: selectedDate) &&
            (event.eventType == .school ||
             event.title.lowercased().contains("pickup") ||
             event.title.lowercased().contains("pick up") ||
             event.title.lowercased().contains("dropoff") ||
             event.title.lowercased().contains("drop off"))
        }
    }
    
    private var regularEvents: [CalendarEvent] {
        allEvents.filter { event in
            Calendar.current.isDate(event.eventDate, inSameDayAs: selectedDate) &&
            !pickupEvents.contains(where: { $0.id == event.id })
        }
    }
    
    private var deadlineGoals: [Goal] {
        allGoals.filter { goal in
            guard let targetDate = goal.targetDate else { return false }
            return Calendar.current.isDate(targetDate, inSameDayAs: selectedDate) &&
                   goal.status != .completed
        }
    }
    
    private var pickupCount: Int { pickupEvents.count }
    private var eventCount: Int { regularEvents.count }
    private var deadlineCount: Int { deadlineGoals.count }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker with Badge Counts
            VStack(spacing: 8) {
                Picker("Tab", selection: $selectedTab.animation()) {
                    ForEach(CalendarDayTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                
                // Badge Count Row
                HStack(spacing: 0) {
                    ForEach(CalendarDayTab.allCases, id: \.self) { tab in
                        let count = count(for: tab)
                        Text(count > 0 ? "(\(count))" : " ")
                            .font(.caption)
                            .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider()
            
            // Tab Content
            ScrollView {
                LazyVStack(spacing: 12) {
                    switch selectedTab {
                    case .pickups:
                        pickupsContent
                    case .events:
                        eventsContent
                    case .deadlines:
                        deadlinesContent
                    }
                }
                .padding()
            }
        }
    }
    
    private func count(for tab: CalendarDayTab) -> Int {
        switch tab {
        case .pickups: return pickupCount
        case .events: return eventCount
        case .deadlines: return deadlineCount
        }
    }
    
    @ViewBuilder
    private var pickupsContent: some View {
        if pickupEvents.isEmpty {
            emptyStateView(
                icon: "car.fill",
                message: "No pickups scheduled for today 🚗"
            )
        } else {
            ForEach(pickupEvents) { event in
                PickupRowView(event: event)
            }
        }
    }
    
    @ViewBuilder
    private var eventsContent: some View {
        if regularEvents.isEmpty {
            emptyStateView(
                icon: "calendar",
                message: "No events today"
            )
        } else {
            ForEach(regularEvents) { event in
                EventCardView(event: event)
            }
        }
    }
    
    @ViewBuilder
    private var deadlinesContent: some View {
        if deadlineGoals.isEmpty {
            emptyStateView(
                icon: "target",
                message: "No deadlines today 🎯"
            )
        } else {
            ForEach(deadlineGoals) { goal in
                DeadlineCardView(goal: goal, isSingleChild: isSingleChild)
            }
        }
    }
    
    private func emptyStateView(icon: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text(message)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}

// MARK: - Pickup Row View

struct PickupRowView: View {
    let event: CalendarEvent
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    private var canDelete: Bool {
        appSettings.currentUserRole == .parent || event.createdByName == appSettings.currentUserName
    }
    
    private var canEdit: Bool {
        appSettings.currentUserRole == .parent || event.createdByName == appSettings.currentUserName
    }
    
    // MARK: - Missed Pickup Detection
    
    private var isMissed: Bool {
        event.eventDate < Date()
    }
    
    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            HStack(spacing: 16) {
                // Car Icon (Red if missed)
                Image(systemName: "car.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(
                            colors: isMissed ? [.red, .red.opacity(0.7)] : [.blue, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 6) {
                    // Missed Badge (if applicable)
                    if isMissed {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                            Text("Missed")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .clipShape(Capsule())
                    }
                    
                    // Time - Large and Bold
                    Text(event.eventDate, style: .time)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(isMissed ? .red : .primary)
                    
                    // Title
                    Text(event.title)
                        .font(.headline)
                    
                    // OWNERSHIP: Handled By
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill.checkmark")
                            .font(.caption2)
                        Text("Handled by \(event.createdByName)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.blue)
                    
                    // Location (if in notes)
                    if !event.notes.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text(event.notes)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                // Red border if missed
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isMissed ? Color.red.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            if canEdit {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            
            if canDelete {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditEventView(event: event)
        }
        .alert("Delete Pickup", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(event)
            }
        } message: {
            Text("Are you sure you want to delete this pickup?")
        }
    }
}

// MARK: - Event Card View

struct EventCardView: View {
    let event: CalendarEvent
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    private var canDelete: Bool {
        appSettings.currentUserRole == .parent || event.createdByName == appSettings.currentUserName
    }
    
    private var canEdit: Bool {
        appSettings.currentUserRole == .parent || event.createdByName == appSettings.currentUserName
    }
    
    private var eventColor: Color {
        Color(hex: event.colorHex) ?? typeColor
    }
    
    private var typeColor: Color {
        switch event.eventType {
        case .school: return .blue
        case .sports: return .orange
        case .family: return .purple
        case .personal: return .green
        }
    }
    
    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            HStack(spacing: 12) {
                // Event Type Icon
                Image(systemName: event.eventType.icon)
                    .font(.title3)
                    .foregroundStyle(eventColor)
                    .frame(width: 44, height: 44)
                    .background(eventColor.opacity(0.15))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(event.title)
                        .font(.headline)
                    
                    // Time Range
                    Text(event.eventDate, style: .time)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Event Type Badge & OWNERSHIP
                    HStack(spacing: 8) {
                        Text(event.eventType.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(eventColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(eventColor.opacity(0.15))
                            .clipShape(Capsule())
                        
                        // OWNERSHIP: Added by
                        HStack(spacing: 3) {
                            Image(systemName: "person.circle.fill")
                                .font(.caption2)
                            Text("Added by \(event.createdByName)")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    // Notes
                    if !event.notes.isEmpty {
                        Text(event.notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .contextMenu {
            if canEdit {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            
            if canDelete {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditEventView(event: event)
        }
        .alert("Delete Event", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(event)
            }
        } message: {
            Text("Are you sure you want to delete this event?")
        }
    }
}

// MARK: - Deadline Card View

struct DeadlineCardView: View {
    let goal: Goal
    let isSingleChild: Bool
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingStreakCelebration = false
    @State private var celebrationMessage = ""
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    private var canMarkComplete: Bool {
        // Children can mark their own approved goals complete
        goal.createdByChildName == appSettings.currentUserName && 
        goal.status == .approved && 
        goal.hasHabit
    }
    
    private var canEdit: Bool {
        // Parents can edit any goal, children can edit their own
        appSettings.currentUserRole == .parent || goal.createdByChildName == appSettings.currentUserName
    }
    
    private var canDelete: Bool {
        // Parents can delete any goal, children can delete their own
        appSettings.currentUserRole == .parent || goal.createdByChildName == appSettings.currentUserName
    }
    
    private var urgencyInfo: (color: Color, icon: String, text: String) {
        guard let daysRemaining = goal.daysUntilDeadline else {
            return (.gray, "clock", "No deadline")
        }
        
        if daysRemaining < 0 {
            return (.red, "exclamationmark.triangle.fill", "Overdue by \(abs(daysRemaining))d")
        } else if daysRemaining == 0 {
            return (.red, "exclamationmark.circle.fill", "Due today!")
        } else if daysRemaining == 1 {
            return (.orange, "clock.badge.exclamationmark", "Due tomorrow")
        } else if daysRemaining <= 2 {
            return (.red, "clock.badge.exclamationmark", "\(daysRemaining) days left")
        } else if daysRemaining <= 7 {
            return (.orange, "clock", "\(daysRemaining) days left")
        } else {
            return (.green, "clock", "\(daysRemaining) days left")
        }
    }
    
    // MARK: - Consequence Awareness
    
    private var consequenceText: String? {
        guard let daysRemaining = goal.daysUntilDeadline else { return nil }
        
        // Only show consequences for urgent deadlines
        if daysRemaining < 0 {
            return "Overdue – progress impacted"
        } else if daysRemaining <= 2 && goal.currentStreak > 0 {
            return "Streak at risk"
        } else if daysRemaining <= 7 && goal.pointValue > 0 {
            return "Points on the line: ⭐ \(goal.pointValue)"
        }
        
        return nil
    }
    
    // MARK: - Role-Aware Messaging
    
    private var motivationalHint: String? {
        guard let daysRemaining = goal.daysUntilDeadline else { return nil }
        
        // Only show for upcoming deadlines (not overdue)
        guard daysRemaining >= 0 && daysRemaining <= 7 else { return nil }
        
        if isSingleChild {
            // Single-child: Self-progress focus
            if goal.currentStreak > 0 {
                return "Chance to extend your streak"
            } else {
                return "Finish strong today"
            }
        } else {
            // Multi-child: Light comparison
            if goal.currentStreak > 0 {
                return "Keep your streak alive"
            } else {
                return "Stay on track"
            }
        }
    }
    
    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    // Urgency Icon
                    Image(systemName: urgencyInfo.icon)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(urgencyInfo.color)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Goal Title
                        Text(goal.title)
                            .font(.headline)
                        
                        // OWNERSHIP: Owned by
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill.checkmark")
                                .font(.caption2)
                            Text("Owned by \(goal.createdByChildName)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.blue)
                    }
                    
                    Spacer()
                    
                    // Completion Checkbox (if child can mark complete)
                    if canMarkComplete {
                        Button {
                            toggleCompletion()
                        } label: {
                            Image(systemName: goal.isCompletedToday() ? "checkmark.circle.fill" : "circle")
                                .font(.title)
                                .foregroundStyle(goal.isCompletedToday() ? .green : .gray)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Divider()
                
                // Urgency Badge & Points
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(urgencyInfo.text)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(urgencyInfo.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(urgencyInfo.color.opacity(0.15))
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Points Badge
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("\(goal.pointValue) pts")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.15))
                    .clipShape(Capsule())
                }
                
                // CONSEQUENCE AWARENESS
                if let consequence = consequenceText {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                        Text(consequence)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(urgencyInfo.color)
                    .clipShape(Capsule())
                }
                
                // ROLE-AWARE MOTIVATIONAL HINT
                if let hint = motivationalHint {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption2)
                        Text(hint)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Capsule())
                }
                
                // Status Badge (if not approved)
                if goal.status != .approved {
                    HStack(spacing: 6) {
                        Image(systemName: goal.status.icon)
                            .font(.caption2)
                        Text(goal.status.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(urgencyInfo.color.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            if canEdit {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit Goal", systemImage: "pencil")
                }
            }
            
            if canDelete {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete Goal", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                EditGoalView(goal: goal)
            }
        }
        .alert("Delete Goal?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(goal)
            }
        } message: {
            Text("This will permanently delete '\(goal.title)' and all its progress.")
        }
        .alert("Streak Milestone! 🔥", isPresented: $showingStreakCelebration) {
            Button("Awesome!", role: .cancel) {}
        } message: {
            Text(celebrationMessage)
        }
    }
    
    private func toggleCompletion() {
        if goal.isCompletedToday() {
            // Remove today's completion
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            goal.completedDates.removeAll { calendar.isDate($0, inSameDayAs: today) }
            
            // Recalculate streak after removal
            goal.recalculateStreak()
        } else {
            // Store previous streak to check for milestones
            let previousStreak = goal.currentStreak
            
            // Mark complete
            goal.markCompleted()
            
            // Check for streak milestones
            checkStreakMilestone(previousStreak: previousStreak, newStreak: goal.currentStreak)
            
            // Share to chat if enabled
            if goal.shareCompletionToChat {
                var messageContent = "🎉 \(appSettings.currentUserName) completed: \(goal.title)"
                
                // Add streak info to message if there's an active streak
                if goal.currentStreak > 1 {
                    messageContent += " (🔥 \(goal.currentStreak) day streak!)"
                }
                
                let message = ChatMessage(
                    content: messageContent,
                    authorName: "FamSphere",
                    isImportant: false
                )
                modelContext.insert(message)
            }
        }
    }
    
    private func checkStreakMilestone(previousStreak: Int, newStreak: Int) {
        let milestones = [3, 7, 14, 30, 50, 100]
        
        // Check if we just crossed a milestone
        for milestone in milestones {
            if previousStreak < milestone && newStreak >= milestone {
                celebrationMessage = "You've reached a \(milestone)-day streak on '\(goal.title)'! Keep it up! 🔥🎉"
                showingStreakCelebration = true
                
                // Also share milestone to chat
                let message = ChatMessage(
                    content: "🔥 \(appSettings.currentUserName) reached a \(milestone)-day streak on '\(goal.title)'! Amazing!",
                    authorName: "FamSphere",
                    isImportant: true
                )
                modelContext.insert(message)
                
                break // Only show one milestone at a time
            }
        }
    }
    
    private var statusColor: Color {
        switch goal.status {
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        case .completed: return .blue
        }
    }
}

// MARK: - Edit Event View

struct EditEventView: View {
    let event: CalendarEvent
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var notes: String
    @State private var selectedEventType: EventType
    
    // Reminder
    @State private var hasReminder: Bool
    @State private var selectedReminder: ReminderOption
    @StateObject private var notificationManager = NotificationManager.shared
    
    init(event: CalendarEvent) {
        self.event = event
        _title = State(initialValue: event.title)
        _startDate = State(initialValue: event.eventDate)
        _endDate = State(initialValue: event.endDate ?? event.eventDate.addingTimeInterval(3600))
        _notes = State(initialValue: event.notes)
        _selectedEventType = State(initialValue: event.eventType)
        _hasReminder = State(initialValue: event.reminderMinutesBefore != nil)
        _selectedReminder = State(initialValue: ReminderOption(rawValue: event.reminderMinutesBefore ?? 15) ?? .fifteenMinutes)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Event Title", text: $title)
                    
                    DatePicker("Starts", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    
                    DatePicker("Ends", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Type", selection: $selectedEventType) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Reminder Section
                Section {
                    Toggle("Set Reminder", isOn: $hasReminder)
                    
                    if hasReminder {
                        Picker("Remind me", selection: $selectedReminder) {
                            ForEach(ReminderOption.allCases) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                    }
                } header: {
                    Text("Reminder")
                } footer: {
                    if hasReminder {
                        Text("You'll receive a notification \(selectedReminder.displayName.lowercased())")
                    }
                }
                
                // Show if recurring
                if event.isRecurring {
                    Section {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.blue)
                            Text("This is a recurring event")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: startDate) { oldValue, newValue in
                startDate = newValue.roundedToNearest15Minutes()
                // Auto-adjust end date to maintain duration
                if endDate <= startDate {
                    endDate = startDate.addingTimeInterval(3600)
                }
            }
            .onChange(of: endDate) { oldValue, newValue in
                endDate = newValue.roundedToNearest15Minutes()
                // Ensure end is after start
                if endDate <= startDate {
                    endDate = startDate.addingTimeInterval(900) // 15 minutes
                }
            }
        }
    }
    
    private func saveChanges() {
        // Update event properties
        event.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        event.eventDate = startDate
        event.endDate = endDate
        event.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        event.eventType = selectedEventType
        event.reminderMinutesBefore = hasReminder ? selectedReminder.rawValue : nil
        
        // Update notification
        if hasReminder {
            let eventIdString = event.persistentModelID.hashValue.description
            
            // Remove old notification
            notificationManager.removeEventReminder(eventId: eventIdString)
            
            // Schedule new notification
            Task {
                try? await notificationManager.scheduleEventReminder(
                    eventId: eventIdString,
                    title: event.title,
                    eventDate: startDate,
                    minutesBefore: selectedReminder.rawValue
                )
            }
        } else {
            // Remove notification if turned off
            let eventIdString = event.persistentModelID.hashValue.description
            notificationManager.removeEventReminder(eventId: eventIdString)
        }
        
        dismiss()
    }
}

#Preview("Calendar Day Tabs") {
    NavigationStack {
        CalendarDayTabsView(
            selectedDate: Date(),
            selectedTab: .constant(.events),
            isSingleChild: false
        )
    }
    .environment(AppSettings())
    .modelContainer(for: [CalendarEvent.self, Goal.self])
}

#Preview {
    CalendarView()
        .environment(AppSettings())
        .modelContainer(for: [FamilyMember.self, ChatMessage.self, CalendarEvent.self, Goal.self])
}
