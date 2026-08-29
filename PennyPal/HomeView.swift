//
//  HomeView.swift
//  PennyPal
//

import SwiftUI
import UIKit

struct HomeView: View {
    let user: UserProfile
    let budgets: [Budget]

    @EnvironmentObject private var appSession: AppSession
    @State private var selectedTab: DashboardTab = .home
    @State private var selectedStatistic: StatisticMode = .expenses
    @State private var transactions: [Transaction]
    @State private var categories: [Category]

    init(
        user: UserProfile,
        transactions: [Transaction] = SampleFinanceData.transactions,
        budgets: [Budget] = SampleFinanceData.budgets,
        categories: [Category] = SampleFinanceData.categories
    ) {
        self.user = user
        self.budgets = budgets
        _transactions = State(initialValue: transactions.sorted { $0.date > $1.date })
        _categories = State(initialValue: categories)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            dashboardBackground

            Group {
                switch selectedTab {
                case .home:
                    HomeDashboardScreen(
                        user: user,
                        transactions: transactions,
                        categories: categories
                    )
                case .overview:
                    OverviewDashboardScreen(
                        transactions: transactions,
                        budgets: budgets,
                        categories: categories,
                        currencySymbol: user.preferredCurrency,
                        selectedStatistic: $selectedStatistic
                    )
                case .add:
                    AddEntryScreen(
                        transactions: transactions,
                        categories: categories,
                        currencySymbol: user.preferredCurrency,
                        onAddCategory: { category in
                            categories.append(category)
                        },
                        onSave: { transaction in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            transactions.insert(transaction, at: 0)
                            selectedTab = .home
                        }
                    })
                case .wallet:
                    BudgetDashboardScreen(
                        budgets: budgets,
                        categories: categories,
                        transactions: transactions,
                        currencySymbol: user.preferredCurrency
                    )
                case .profile:
                    ProfileDashboardScreen(
                        user: user,
                        transactions: transactions,
                        currencySymbol: user.preferredCurrency
                    ) {
                        appSession.signOut()
                    }
                }
            }
            .safeAreaPadding(.bottom, 110)

            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 22)
                .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden(true)
    }

    private var dashboardBackground: some View {
        LinearGradient(
            colors: [
                Color.white,
                Color.whiteMint,
                Color.lightMint.opacity(0.45)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

private struct HomeDashboardScreen: View {
    let user: UserProfile
    let transactions: [Transaction]
    let categories: [Category]

    private var balance: Double {
        transactions.reduce(0) { $0 + $1.signedAmount }
    }

    private var monthlyIncome: Double {
        transactions.filter(\.isIncome).reduce(0) { $0 + $1.amount }
    }

    private var monthlyExpenses: Double {
        transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                dashboardHeader(
                    title: "Home",
                    subtitle: "Welcome back, \(user.firstName)"
                )

                BalanceCard(
                    balance: balance,
                    income: monthlyIncome,
                    expenses: monthlyExpenses,
                    currencySymbol: user.preferredCurrency
                )

                VStack(alignment: .leading, spacing: 14) {
                    sectionHeader(title: "Recent Transactions", trailingText: "\(transactions.count) total")

                    ForEach(transactions.prefix(5)) { transaction in
                        TransactionRow(
                            transaction: transaction,
                            category: categories.first(where: { $0.id == transaction.categoryId }),
                            currencySymbol: user.preferredCurrency
                        )
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
        }
    }
}

private struct OverviewDashboardScreen: View {
    let transactions: [Transaction]
    let budgets: [Budget]
    let categories: [Category]
    let currencySymbol: String
    @Binding var selectedStatistic: StatisticMode
    @State private var selectedRange: StatisticsRange = .weekly

    private var filteredTransactions: [Transaction] {
        selectedRange.filteredTransactions(from: transactions)
    }

    private var totalIncome: Double {
        filteredTransactions.filter(\.isIncome).reduce(0) { $0 + $1.amount }
    }

    private var totalExpenses: Double {
        filteredTransactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    private var topBudgets: [BudgetSummary] {
        budgets.compactMap { budget in
            guard let category = categories.first(where: { $0.id == budget.categoryId }) else {
                return nil
            }

            let spent = filteredTransactions
                .filter { !$0.isIncome && $0.categoryId == budget.categoryId }
                .reduce(0) { $0 + $1.amount }

            return BudgetSummary(category: category, spent: spent, limit: budget.limit)
        }
        .sorted { $0.spent > $1.spent }
    }

    private var chartPoints: [ChartPoint] {
        selectedRange.chartPoints(from: filteredTransactions)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                dashboardHeader(
                    title: "Overview",
                    subtitle: "Your spending trends at a glance"
                )

                HStack(spacing: 14) {
                    MetricCard(
                        title: "Total Income",
                        value: totalIncome.currencyText(symbol: currencySymbol),
                        tint: .mediumMint,
                        systemImage: "arrow.down.circle.fill"
                    )

                    MetricCard(
                        title: "Total Expenses",
                        value: totalExpenses.currencyText(symbol: currencySymbol),
                        tint: Color(red: 0.97, green: 0.55, blue: 0.47),
                        systemImage: "arrow.up.circle.fill"
                    )
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Summary")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(Color.charcoal)
                            Text(selectedRange.summaryLabel)
                                .font(.subheadline)
                                .foregroundStyle(Color.charcoal.opacity(0.55))
                        }

                        Spacer()

                        Menu {
                            ForEach(StatisticsRange.allCases) { range in
                                Button(range.title) {
                                    selectedRange = range
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(selectedRange.title)
                                Image(systemName: "chevron.down")
                                    .font(.caption.weight(.bold))
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.charcoal)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.95), in: Capsule())
                        }
                    }

                    StatisticsBarChart(
                        data: chartPoints,
                        currencySymbol: currencySymbol,
                        selectedStatistic: selectedStatistic
                    )

                    StatisticToggle(selectedStatistic: $selectedStatistic)

                    VStack(spacing: 12) {
                        ForEach(topBudgets) { item in
                            BudgetRow(summary: item, currencySymbol: currencySymbol)
                        }
                    }
                }
                .dashboardCard()
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
        }
    }
}

private struct AddEntryScreen: View {
    let transactions: [Transaction]
    let categories: [Category]
    let currencySymbol: String
    let onAddCategory: (Category) -> Void
    let onSave: (Transaction) -> Void

    @State private var entryType: TransactionType = .expense
    @State private var title = ""
    @State private var amountText = ""
    @State private var selectedCategoryID: UUID?
    @State private var note = ""
    @State private var errorMessage: String?
    @State private var isAddingCustomCategory = false
    @State private var customCategoryName = ""

    private var validAmount: Double? {
        Double(amountText.filter { "0123456789.".contains($0) })
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Add Entry")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Color.charcoal)
                        Text("Log spending or income in a few taps.")
                            .font(.subheadline)
                            .foregroundStyle(Color.charcoal.opacity(0.55))
                    }

                    Spacer()
                }

                EntryTypePicker(entryType: $entryType)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Amount")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.charcoal)

                    HStack(spacing: 10) {
                        Text(currencySymbol)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.charcoal)

                        NumericAmountField(text: $amountText, placeholder: "0.00")
                            .frame(height: 40)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 18)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                    AuthTextField(
                        title: entryType == .income ? "Source" : "Expense Name",
                        text: $title,
                        prompt: entryType == .income ? "Campus job" : "Trader Joe's",
                        systemImage: entryType == .income ? "banknote.fill" : "cart.fill",
                        validationMessage: nil
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Category")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.charcoal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(filteredCategories) { category in
                                    CategoryChoiceChip(
                                        category: category,
                                        isSelected: selectedCategoryID == category.id
                                    ) {
                                        selectedCategoryID = category.id
                                    }
                                }

                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isAddingCustomCategory.toggle()
                                    }
                                } label: {
                                    CustomCategoryChip(isActive: isAddingCustomCategory)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 2)
                        }

                        if isAddingCustomCategory {
                            VStack(alignment: .leading, spacing: 12) {
                                AuthTextField(
                                    title: "Custom Category",
                                    text: $customCategoryName,
                                    prompt: entryType == .income ? "Scholarship" : "Coffee",
                                    systemImage: "tag.fill",
                                    validationMessage: nil
                                )

                                Button {
                                    addCustomCategory()
                                } label: {
                                    Text("Add Category")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(Color.charcoal)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color.lightMint.opacity(0.55), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                    }

                    AuthTextField(
                        title: "Note",
                        text: $note,
                        prompt: "Optional note",
                        systemImage: "text.justify.left",
                        validationMessage: nil
                    )

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.red)
                    }

                    Button {
                        saveEntry()
                    } label: {
                        Text(entryType == .income ? "Add Income" : "Add Expense")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.charcoal)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.mediumMint, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .dashboardCard()

                VStack(alignment: .leading, spacing: 14) {
                    Text("Last Added")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color.charcoal)

                    ForEach(transactions.prefix(4)) { transaction in
                        TransactionRow(
                            transaction: transaction,
                            category: categories.first(where: { $0.id == transaction.categoryId }),
                            currencySymbol: currencySymbol
                        )
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
        }
    }

    private var filteredCategories: [Category] {
        categories.filter { category in
            switch entryType {
            case .income:
                return category.kind == .income
            case .expense:
                return category.kind == .expense
            }
        }
    }

    private func saveEntry() {
        errorMessage = nil

        guard let categoryID = selectedCategoryID else {
            errorMessage = "Choose a category first."
            return
        }

        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Add a title so you can spot this entry later."
            return
        }

        guard let amount = validAmount, amount > 0 else {
            errorMessage = "Enter a valid amount greater than zero."
            return
        }

        onSave(
            Transaction(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: amount,
                date: .now,
                categoryId: categoryID,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                type: entryType
            )
        )

        title = ""
        amountText = ""
        note = ""
        selectedCategoryID = nil
    }

    private func addCustomCategory() {
        let trimmedName = customCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorMessage = "Give your custom category a name first."
            return
        }

        let newCategory = Category(
            name: trimmedName,
            iconName: entryType == .income ? "sparkles" : "tag.fill",
            colorHex: entryType == .income ? "#6FB7A7" : "#89CFC0",
            kind: entryType == .expense ? .expense : .income
        )

        onAddCategory(newCategory)
        selectedCategoryID = newCategory.id
        customCategoryName = ""
        errorMessage = nil

        withAnimation(.easeInOut(duration: 0.2)) {
            isAddingCustomCategory = false
        }
    }
}

private struct BudgetDashboardScreen: View {
    let budgets: [Budget]
    let categories: [Category]
    let transactions: [Transaction]
    let currencySymbol: String

    private var budgetSummaries: [BudgetSummary] {
        budgets.compactMap { budget in
            guard let category = categories.first(where: { $0.id == budget.categoryId }) else {
                return nil
            }

            let spent = transactions
                .filter { !$0.isIncome && $0.categoryId == budget.categoryId }
                .reduce(0) { $0 + $1.amount }

            return BudgetSummary(category: category, spent: spent, limit: budget.limit)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                dashboardHeader(
                    title: "Budgets",
                    subtitle: "Stay ahead of where your money is going"
                )

                ForEach(budgetSummaries) { summary in
                    VStack(alignment: .leading, spacing: 14) {
                        BudgetRow(summary: summary, currencySymbol: currencySymbol)

                        GeometryReader { geometry in
                            let progress = min(summary.spent / max(summary.limit, 1), 1)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.lightMint.opacity(0.6))
                                .overlay(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(summary.remaining >= 0 ? Color.mediumMint : Color.red.opacity(0.85))
                                        .frame(width: geometry.size.width * progress)
                                }
                        }
                        .frame(height: 12)
                    }
                    .dashboardCard()
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
        }
    }
}

private struct ProfileDashboardScreen: View {
    let user: UserProfile
    let transactions: [Transaction]
    let currencySymbol: String
    let onSignOut: () -> Void

    private var totalSaved: Double {
        max(0, transactions.reduce(0) { $0 + $1.signedAmount })
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                dashboardHeader(
                    title: "Profile",
                    subtitle: "A quick look at your personal setup"
                )

                VStack(spacing: 18) {
                    Circle()
                        .fill(Color.mediumMint.opacity(0.5))
                        .frame(width: 86, height: 86)
                        .overlay {
                            Text(user.initials)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(Color.charcoal)
                        }

                    VStack(spacing: 6) {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.charcoal)
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundStyle(Color.charcoal.opacity(0.55))
                    }
                }
                .frame(maxWidth: .infinity)
                .dashboardCard()

                VStack(spacing: 12) {
                    ProfileInfoRow(title: "Current Balance", value: totalSaved.currencyText(symbol: currencySymbol))
                    ProfileInfoRow(title: "Entries Logged", value: "\(transactions.count)")
                    ProfileInfoRow(title: "Preferred Currency", value: user.preferredCurrency)
                    ProfileInfoRow(title: "Joined PennyPal", value: user.joinedDate.profileDateText)
                }
                .dashboardCard()

                Button {
                    onSignOut()
                } label: {
                    Text("Sign Out")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.charcoal, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
        }
    }
}

private struct BalanceCard: View {
    let balance: Double
    let income: Double
    let expenses: Double
    let currencySymbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total Balance")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.9))

                    Text(balance.currencyText(symbol: currencySymbol))
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundStyle(Color.white)
                }

                Spacer()

                Image(systemName: "ellipsis")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.white.opacity(0.85))
            }

            HStack(spacing: 14) {
                BalancePill(
                    title: "Income",
                    amount: income.currencyText(symbol: currencySymbol),
                    icon: "arrow.down",
                    tint: Color.white.opacity(0.30)
                )

                BalancePill(
                    title: "Expenses",
                    amount: expenses.currencyText(symbol: currencySymbol),
                    icon: "arrow.up",
                    tint: Color.white.opacity(0.30)
                )
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, minHeight: 215, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [
                    Color.mediumMint.opacity(0.9),
                    Color(red: 0.35, green: 0.75, blue: 0.65),
                    Color.mediumMint

                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .shadow(color: Color.mediumMint.opacity(0.22), radius: 24, y: 18)
    }
}

private struct BalancePill: View {
    let title: String
    let amount: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.white)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.30), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white)
                Text(amount)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(tint, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let tint: Color
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.charcoal.opacity(0.55))
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.charcoal)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(tint.opacity(0.12))
        )
    }
}

private struct StatisticsBarChart: View {
    let data: [ChartPoint]
    let currencySymbol: String
    let selectedStatistic: StatisticMode

    var body: some View {
        GeometryReader { geometry in
            let maxValue = max(
                data.flatMap { [$0.income, $0.expense] }.max() ?? 1,
                1
            )
            let tickValues = stride(from: maxValue, through: 0, by: -(maxValue / 4 == 0 ? 1 : maxValue / 4)).map { $0 }

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(tickValues.enumerated()), id: \.offset) { _, value in
                        Text(value.currencyText(symbol: currencySymbol))
                            .font(.footnote)
                            .foregroundStyle(Color.charcoal.opacity(0.45))
                            .frame(height: geometry.size.height / CGFloat(max(tickValues.count - 1, 1)), alignment: .topLeading)
                    }
                }

                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                        ForEach(Array(tickValues.enumerated()), id: \.offset) { index, _ in
                            Rectangle()
                                .fill(index == tickValues.count - 1 ? Color.clear : Color.charcoal.opacity(0.2))
                                .frame(height: 1)
                            if index != tickValues.count - 1 {
                                Spacer()
                            }
                        }
                    }

                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(data) { point in
                            VStack(spacing: 10) {
                                Spacer(minLength: 0)
                                HStack(alignment: .bottom, spacing: 6) {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.mediumMint.opacity(selectedStatistic == .expenses ? 0.45 : 1))
                                        .frame(
                                            width: 16,
                                            height: max(6, CGFloat(point.income / maxValue) * (geometry.size.height - 28))
                                        )

                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.charcoal.opacity(selectedStatistic == .income ? 0.25 : 0.9))
                                        .frame(
                                            width: 16,
                                            height: max(6, CGFloat(point.expense / maxValue) * (geometry.size.height - 28))
                                        )
                                }
                                Text(point.label)
                                    .font(.caption)
                                    .foregroundStyle(Color.charcoal.opacity(0.55))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 230)
    }
}

private struct StatisticToggle: View {
    @Binding var selectedStatistic: StatisticMode

    var body: some View {
        HStack(spacing: 10) {
            statisticButton(title: "Income", mode: .income)
            statisticButton(title: "Expenses", mode: .expenses)
        }
    }

    private func statisticButton(title: String, mode: StatisticMode) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedStatistic = mode
            }
        } label: {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(selectedStatistic == mode ? Color.white : Color.charcoal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(selectedStatistic == mode ? Color.mediumMint : Color.white)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct BudgetRow: View {
    let summary: BudgetSummary
    let currencySymbol: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: summary.category.iconName)
                .font(.headline)
                .foregroundStyle(summary.category.swiftUIColor)
                .frame(width: 46, height: 46)
                .background(summary.category.swiftUIColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(summary.category.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.charcoal)
                Text("Spent \(summary.spent.currencyText(symbol: currencySymbol)) of \(summary.limit.currencyText(symbol: currencySymbol))")
                    .font(.subheadline)
                    .foregroundStyle(Color.charcoal.opacity(0.5))
            }

            Spacer()

            Text(summary.remaining.currencyText(symbol: currencySymbol))
                .font(.headline.weight(.bold))
                .foregroundStyle(summary.remaining >= 0 ? Color.mediumMint : Color.red)
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct EntryTypePicker: View {
    @Binding var entryType: TransactionType

    var body: some View {
        HStack(spacing: 12) {
            entryButton(title: "Income", type: .income)
            entryButton(title: "Expense", type: .expense)
        }
    }

    private func entryButton(title: String, type: TransactionType) -> some View {
        Button {
            entryType = type
        } label: {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(entryType == type ? Color.white : Color.charcoal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(entryType == type ? Color.mediumMint : Color.white)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct CategoryChoiceChip: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: category.iconName)
                    .foregroundStyle(category.swiftUIColor)
                    .frame(width: 32, height: 32)
                    .background(category.swiftUIColor.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))

                Text(category.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.charcoal)
            }
            .lineLimit(1)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.mediumMint : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct CustomCategoryChip: View {
    let isActive: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
                .foregroundStyle(Color.mediumMint)
                .frame(width: 32, height: 32)
                .background(Color.mediumMint.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))

            Text("Custom")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.charcoal)
        }
        .lineLimit(1)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white, in: Capsule())
        .overlay(
            Capsule()
                .stroke(isActive ? Color.mediumMint : Color.mediumMint.opacity(0.35), lineWidth: isActive ? 2 : 1.5)
        )
    }
}

private struct NumericAmountField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = .decimalPad
        textField.textColor = UIColor(Color.charcoal)
        textField.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        @objc func textDidChange(_ textField: UITextField) {
            text = textField.text ?? ""
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if string.isEmpty {
                return true
            }

            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            guard string.rangeOfCharacter(from: allowedCharacters.inverted) == nil else {
                return false
            }

            let currentText = textField.text ?? ""
            guard let textRange = Range(range, in: currentText) else {
                return false
            }

            let updatedText = currentText.replacingCharacters(in: textRange, with: string)

            if updatedText.filter({ $0 == "." }).count > 1 {
                return false
            }

            return true
        }
    }
}

private struct TransactionRow: View {
    let transaction: Transaction
    let category: Category?
    let currencySymbol: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: category?.iconName ?? "creditcard.fill")
                .font(.headline)
                .foregroundStyle((category?.swiftUIColor ?? Color.mediumMint))
                .frame(width: 48, height: 48)
                .background((category?.swiftUIColor ?? Color.mediumMint).opacity(0.14), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.charcoal)
                Text(transaction.date.transactionRowText)
                    .font(.subheadline)
                    .foregroundStyle(Color.charcoal.opacity(0.5))
            }

            Spacer()

            Text(transaction.amountText(symbol: currencySymbol))
                .font(.headline.weight(.bold))
                .foregroundStyle(transaction.isIncome ? Color.mediumMint : Color.red)
        }
        .padding(16)
        .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct ProfileInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.charcoal.opacity(0.6))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(Color.charcoal)
        }
    }
}

private struct CustomTabBar: View {
    @Binding var selectedTab: DashboardTab

    var body: some View {
        HStack(spacing: 0) {
            tabButton(for: .home, systemImage: "house.fill")
            tabButton(for: .overview, systemImage: "chart.bar.fill")

            Button {
                selectedTab = .add
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 66, height: 66)
                    .background(Color.mediumMint, in: Circle())
                    .shadow(color: Color.mediumMint.opacity(0.28), radius: 18, y: 12)
            }
            .frame(maxWidth: .infinity)

            tabButton(for: .wallet, systemImage: "wallet.pass.fill")
            tabButton(for: .profile, systemImage: "person.fill")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
    }

    private func tabButton(for tab: DashboardTab, systemImage: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(selectedTab == tab ? Color.mediumMint : Color.charcoal.opacity(0.35))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

private func dashboardHeader(title: String, subtitle: String) -> some View {
    HStack {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color.charcoal)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.charcoal.opacity(0.55))
        }

        Spacer()

        Image(systemName: "magnifyingglass")
            .font(.title3.weight(.bold))
            .foregroundStyle(Color.charcoal)
            .frame(width: 44, height: 44)
            .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 16))
    }
}

private func sectionHeader(title: String, trailingText: String) -> some View {
    HStack {
        Text(title)
            .font(.system(size: 30, weight: .bold))
            .foregroundStyle(Color.charcoal)
        Spacer()
        Text(trailingText)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.charcoal.opacity(0.55))
    }
}

private enum DashboardTab {
    case home
    case overview
    case add
    case wallet
    case profile
}

private enum StatisticMode {
    case income
    case expenses
}

private struct ChartPoint: Identifiable {
    let id = UUID()
    let label: String
    let income: Double
    let expense: Double
}

private enum StatisticsRange: String, CaseIterable, Identifiable {
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }

    var summaryLabel: String {
        let now = Date.now
        switch self {
        case .weekly:
            return now.weekSummaryText
        case .monthly:
            return now.monthSummaryText
        case .yearly:
            return "Last year"
        }
    }

    func filteredTransactions(from transactions: [Transaction]) -> [Transaction] {
        let calendar = Calendar.current
        let now = Date.now

        switch self {
        case .weekly:
            // Past 7 days (excluding future), inclusive of today
            guard let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else { return transactions }
            let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
            return transactions.filter { $0.date >= start && $0.date <= end }

        case .monthly:
            // Past 30 days
            guard let start = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: now)) else { return transactions }
            let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
            return transactions.filter { $0.date >= start && $0.date <= end }

        case .yearly:
            // Past 12 months
            guard let start = calendar.date(byAdding: .year, value: -1, to: now) else { return transactions }
            return transactions.filter { $0.date >= start && $0.date <= now }
        }
    }

    func chartPoints(from transactions: [Transaction]) -> [ChartPoint] {
        let calendar = Calendar.current
        let now = Date.now

        switch self {
        case .weekly:
            // Last 7 days, label with short weekday symbols
            let startOfToday = calendar.startOfDay(for: now)
            let days = (0..<7).reversed().map { offset -> Date in
                calendar.date(byAdding: .day, value: -offset, to: startOfToday) ?? now
            }
            return days.map { day in
                let dayTx = transactions.filter { calendar.isDate($0.date, inSameDayAs: day) }
                let income = dayTx.filter(\.isIncome).reduce(0) { $0 + $1.amount }
                let expense = dayTx.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
                let label = day.formatted(.dateTime.weekday(.abbreviated))
                return ChartPoint(label: label, income: income, expense: expense)
            }

        case .monthly:
            // Last 30 days grouped into calendar weeks (max 5 buckets), labels W1..W5 relative to the 30-day window
            let start = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -29, to: now) ?? now)
            let end = now
            // Build 5 equal sequential week ranges within the 30-day window
            var buckets: [(start: Date, end: Date)] = []
            var cursor = start
            for _ in 0..<5 {
                let next = calendar.date(byAdding: .day, value: 6, to: cursor) ?? cursor
                buckets.append((start: cursor, end: min(next, end)))
                cursor = calendar.date(byAdding: .day, value: 7, to: cursor) ?? cursor
                if cursor > end { break }
            }
            return buckets.enumerated().map { index, range in
                let tx = transactions.filter { $0.date >= range.start && $0.date <= range.end }
                let income = tx.filter(\.isIncome).reduce(0) { $0 + $1.amount }
                let expense = tx.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
                return ChartPoint(label: "W\(index + 1)", income: income, expense: expense)
            }

        case .yearly:
            // Last 12 months ending this month, label with short month symbols
            let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let months = (0..<12).reversed().map { offset -> Date in
                calendar.date(byAdding: .month, value: -offset, to: currentMonthStart) ?? now
            }
            return months.map { monthStart in
                let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) ?? monthStart
                let tx = transactions.filter { $0.date >= monthStart && $0.date <= monthEnd }
                let income = tx.filter(\.isIncome).reduce(0) { $0 + $1.amount }
                let expense = tx.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
                let label = monthStart.formatted(.dateTime.month(.abbreviated))
                return ChartPoint(label: label, income: income, expense: expense)
            }
        }
    }
}

private struct BudgetSummary: Identifiable {
    let id = UUID()
    let category: Category
    let spent: Double
    let limit: Double

    var remaining: Double {
        limit - spent
    }
}

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var date: Date
    var categoryId: UUID
    var note: String?
    var type: TransactionType

    var isIncome: Bool {
        type == .income
    }

    var signedAmount: Double {
        isIncome ? amount : -amount
    }

    func amountText(symbol: String) -> String {
        "\(isIncome ? "+" : "-")\(amount.currencyText(symbol: symbol))"
    }
}

struct Budget: Identifiable, Codable {
    var id = UUID()
    var limit: Double
    var categoryId: UUID
    var period: String
}

struct UserProfile: Codable {
    var firstName: String
    var lastName: String
    var email: String
    var preferredCurrency: String
    var joinedDate: Date

    var initials: String {
        let first = firstName.first.map(String.init) ?? ""
        let last = lastName.first.map(String.init) ?? ""
        return first + last
    }
}

enum TransactionType: String, Codable {
    case income
    case expense
}

private enum SampleFinanceData {
    static let groceries = Category(name: "Groceries", iconName: "cart.fill", colorHex: "#A1DCCF", kind: .expense)
    static let transport = Category(name: "Transport", iconName: "car.fill", colorHex: "#A1DCCF", kind: .expense)
    static let shopping = Category(name: "Shopping", iconName: "hanger", colorHex: "#A1DCCF", kind: .expense)
    static let food = Category(name: "Food", iconName: "fork.knife", colorHex: "#A1DCCF", kind: .expense)
    static let pay = Category(name: "Paycheck", iconName: "banknote.fill", colorHex: "#A1DCCF", kind: .income)
    static let freelance = Category(name: "Freelance", iconName: "laptopcomputer", colorHex: "#A1DCCF", kind: .income)
    static let gifts = Category(name: "Gift", iconName: "gift.fill", colorHex: "#A1DCCF", kind: .income)

    static let categories: [Category] = [
        groceries,
        food,
        transport,
        shopping,
        pay,
        freelance,
        gifts
    ]

    static let transactions: [Transaction] = [
        Transaction(
            title: "Campus Job",
            amount: 620,
            date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now,
            categoryId: pay.id,
            note: "Weekly shift payout",
            type: .income
        ),
        Transaction(
            title: "Trader Joe's",
            amount: 84,
            date: Calendar.current.date(byAdding: .day, value: -2, to: .now) ?? .now,
            categoryId: groceries.id,
            note: "Groceries",
            type: .expense
        ),
        Transaction(
            title: "Gas Refill",
            amount: 42,
            date: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now,
            categoryId: transport.id,
            note: nil,
            type: .expense
        ),
        Transaction(
            title: "Tutoring Session",
            amount: 140,
            date: Calendar.current.date(byAdding: .day, value: -5, to: .now) ?? .now,
            categoryId: freelance.id,
            note: "Chemistry help",
            type: .income
        ),
        Transaction(
            title: "Sephora Run",
            amount: 63,
            date: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now,
            categoryId: shopping.id,
            note: nil,
            type: .expense
        ),
        Transaction(
            title: "Dining Hall Top-Up",
            amount: 38,
            date: Calendar.current.date(byAdding: .day, value: -8, to: .now) ?? .now,
            categoryId: food.id,
            note: "Late-night swipe money",
            type: .expense
        )
    ]

    static let budgets: [Budget] = [
        Budget(limit: 250, categoryId: groceries.id, period: "Monthly"),
        Budget(limit: 120, categoryId: transport.id, period: "Monthly"),
        Budget(limit: 150, categoryId: shopping.id, period: "Monthly"),
        Budget(limit: 180, categoryId: food.id, period: "Monthly")
    ]
}

private extension View {
    func dashboardCard() -> some View {
        self
            .padding(20)
            .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.charcoal.opacity(0.08), radius: 18, y: 10)
    }
}

private extension Double {
    func currencyText(symbol: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "\(symbol)\(self)"
    }

    func compactCurrencyText(symbol: String) -> String {
        let absolute = abs(self)

        if absolute >= 1000 {
            let abbreviated = absolute / 1000
            return "\(symbol)\(abbreviated.cleanAbbreviation)k"
        }

        return "\(symbol)\(Int(absolute))"
    }

    private var cleanAbbreviation: String {
        String(format: self.rounded() == self ? "%.0f" : "%.1f", self)
    }
}

private extension Date {
    var transactionRowText: String {
        if Calendar.current.isDateInToday(self) {
            return formatted(date: .omitted, time: .shortened)
        }

        if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        }

        return formatted(.dateTime.month(.abbreviated).day())
    }

    var profileDateText: String {
        formatted(.dateTime.month(.abbreviated).day().year())
    }
    
    var weekSummaryText: String {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: self)?.start ?? self
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: self)?.end.addingTimeInterval(-1) ?? self
        let startText = startOfWeek.formatted(.dateTime.month(.abbreviated).day())
        let endText = endOfWeek.formatted(.dateTime.month(.abbreviated).day())
        return "\(startText) - \(endText)"
    }

    var monthSummaryText: String {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: self)) ?? self
        let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) ?? self
        return "\(start.formatted(.dateTime.month(.abbreviated).day())) - \(end.formatted(.dateTime.month(.abbreviated).day()))"
    }

    var yearSummaryText: String {
        formatted(.dateTime.year())
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

#Preview {
    HomeView(
        user: UserProfile(
            firstName: "Lyla",
            lastName: "Goldman",
            email: "lyla@example.com",
            preferredCurrency: "$",
            joinedDate: .now
        )
    )
    .environmentObject(AppSession())
}

