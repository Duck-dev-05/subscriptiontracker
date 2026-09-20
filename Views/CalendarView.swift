import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var manager: SubscriptionManager
    
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    var subscriptionsForSelectedDate: [Subscription] {
        manager.subscriptions.filter { sub in
            calendar.isDate(sub.nextBillingDate, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text(monthString(from: currentMonth))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                        HStack(spacing: 16) {
                            Button(action: previousMonth) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.primary)
                            }
                            Button(action: nextMonth) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // Calendar Grid
                    calendarGrid
                        .padding(.horizontal, 16)
                    
                    Divider()
                        .padding(.top, 16)
                    
                    // Selected Date Info
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Due on \(dateString(from: selectedDate))")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(uiColor: .systemGroupedBackground))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if subscriptionsForSelectedDate.isEmpty {
                            VStack {
                                Spacer()
                                Text("No payments due.")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            List {
                                ForEach(subscriptionsForSelectedDate) { sub in
                                    SubscriptionRowView(subscription: sub)
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationTitle("Calendar")
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        VStack(spacing: 16) {
            // Days of week
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Dates
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        DateCell(date: date,
                                 isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                 hasSubscriptions: hasSubscriptions(on: date))
                            .onTapGesture {
                                withAnimation {
                                    selectedDate = date
                                }
                            }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helpers
    
    private func monthString(from date: Date) -> String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func dateString(from date: Date) -> String {
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func hasSubscriptions(on date: Date) -> Bool {
        manager.subscriptions.contains { calendar.isDate($0.nextBillingDate, inSameDayAs: date) }
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        
        let startDate = monthFirstWeek?.start ?? monthInterval.start
        
        var dates: [Date?] = []
        var currentDate = startDate
        
        while currentDate < monthInterval.end || dates.count % 7 != 0 {
            if calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month) {
                dates.append(currentDate)
            } else {
                dates.append(nil)
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = next
        }
        return dates
    }
}

// MARK: - Date Cell

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let hasSubscriptions: Bool
    
    var body: some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 36, height: 36)
            }
            
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: isSelected || isToday ? .bold : .regular))
                    .foregroundColor(isSelected ? .white : (isToday ? .blue : .primary))
                
                if hasSubscriptions {
                    Circle()
                        .fill(isSelected ? .white : Color.red)
                        .frame(width: 4, height: 4)
                } else {
                    Color.clear.frame(width: 4, height: 4)
                }
            }
        }
        .frame(height: 40)
    }
}
