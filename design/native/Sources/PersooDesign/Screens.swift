import SwiftUI

enum Screen: String, CaseIterable, Identifiable {
    case language, name, homeEmpty, home, dictation, health, fitness, finance, transactions, savings, school, schedule, plans, context, reminder, settings, life, todo, purchase
    var id: String { rawValue }
    var title: String {
        switch self {
        case .language: "Welcome"; case .name: "Your name"; case .homeEmpty, .home, .purchase: "Home"; case .dictation: "Listening"; case .health: "Health"; case .fitness: "Fitness"; case .finance: "Finance"; case .transactions: "Transactions"; case .savings: "A little perspective"; case .school: "School"; case .schedule: "Today's schedule"; case .plans: "Plans"; case .context: "Personal Context"; case .reminder: "A moment ahead"; case .settings: "Your intelligence"; case .life: "Life"; case .todo: "To-do"
        }
    }
}
struct PersooScreen: View {
    @Environment(\.persoo) var p
    var screen: Screen
    var width: CGFloat = 393
    var height: CGFloat = 852
    var turkish = false
    var navigate: (Screen) -> Void = { _ in }
    var body: some View {
        VStack(spacing: 0) {
            status
            if ![Screen.language, .name, .dictation].contains(screen) { header }
            VStack(alignment: .leading, spacing: 0) { content }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding(.horizontal, 24)
            if [.language,.name,.dictation].contains(screen) { bottomMark.padding(.top, 18) } else { navigation }
        }.frame(width: width, height: height).background(p.canvas).foregroundStyle(p.ink)
    }
    var status: some View {
        HStack { Text("9:41").font(.system(size: 15, weight: .semibold)); Spacer(); HStack(spacing: 6) { Image(systemName: "cellularbars"); Image(systemName: "wifi"); Image(systemName: "battery.100percent") }.font(.system(size: 13, weight: .semibold)) }.padding(.horizontal, 28).frame(height: 54)
    }
    var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Button { navigate(.life) } label: { Text([Screen.home,.homeEmpty,.purchase].contains(screen) ? "PERSOO" : "‹  Life").font(.system(size: 12, weight: .semibold)).tracking(1.3).foregroundStyle(p.accent).frame(minHeight: 32) }.buttonStyle(.plain)
                Spacer()
                Button { navigate(.settings) } label: { Image(systemName: "person.crop.circle").font(.system(size: 24, weight: .regular)).foregroundStyle(p.secondary).frame(width: 44, height: 32) }.buttonStyle(.plain)
            }
            Text([Screen.home,.homeEmpty,.purchase].contains(screen) ? (turkish ? "Merhaba, Deniz." : "Hello, Deniz.") : screen.title).font(.system(size: 32, weight: .bold)).tracking(-0.9)
        }.padding(.horizontal, 24).padding(.bottom, 26)
    }
    var bottomMark: some View { Capsule().fill(p.ink).frame(width: 134, height: 5).padding(.bottom, 9) }
    var navigation: some View {
        VStack(spacing: 15) {
            HStack(spacing: 0) {
                tab("Home", "waveform", .home)
                tab("Life", "square.grid.2x2", .life)
                tab("Plans", "flag", .plans)
            }.padding(.vertical, 10).background(p.surface, in: Capsule()).overlay(Capsule().stroke(p.line.opacity(0.7), lineWidth: 0.5)).padding(.horizontal, 46)
            bottomMark
        }.padding(.top, 14)
    }
    func tab(_ title: String, _ symbol: String, _ target: Screen) -> some View {
        let selected = target == .home ? [.home,.homeEmpty,.purchase,.dictation].contains(screen) : target == .plans ? screen == .plans : ![.home,.homeEmpty,.purchase,.dictation,.plans].contains(screen)
        return Button { navigate(target) } label: {
            VStack(spacing: 4) { Image(systemName: symbol).font(.system(size: 19, weight: selected ? .semibold : .regular)); Text(title).font(.system(size: 10, weight: .semibold)) }.foregroundStyle(selected ? p.accent : p.secondary).frame(maxWidth: .infinity).frame(height: 40)
        }.buttonStyle(.plain)
    }
    @ViewBuilder var content: some View {
        switch screen {
        case .language: onboardingLanguage
        case .name: onboardingName
        case .homeEmpty: emptyHome
        case .home: populatedHome
        case .purchase: purchaseHome
        case .dictation: dictation
        case .health: health
        case .fitness: fitness
        case .finance: finance
        case .transactions: transactions
        case .savings: savings
        case .school: school
        case .schedule: schedule
        case .plans: plans
        case .context: context
        case .reminder: reminder
        case .settings: settings
        case .life: life
        case .todo: todo
        }
    }
    var onboardingLanguage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Persoo").font(.system(size: 25, weight: .semibold)).tracking(-1).padding(.top, 35)
            Spacer()
            Text("What language\nwould you like to\nuse Persoo in?").font(.system(size: 35, weight: .semibold)).tracking(-1.3).lineSpacing(1).fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 0) {
                languageChoice("English", selected: !turkish)
                Rule()
                languageChoice("Türkçe", selected: turkish)
            }.padding(.top, 42)
            Spacer()
            PrimaryAction(title: "Continue", action: { navigate(.name) }).padding(.bottom, 22)
        }
    }
    func languageChoice(_ text: String, selected: Bool) -> some View {
        HStack { Text(text).font(.system(size: 21, weight: .medium)); Spacer(); Image(systemName: selected ? "checkmark.circle.fill" : "circle").foregroundStyle(selected ? p.accent : p.line).font(.system(size: 24)) }.frame(height: 72)
    }
    var onboardingName: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("‹  Back").font(.system(size: 17)).foregroundStyle(p.accent).padding(.top, 16)
            Spacer()
            Text(turkish ? "Persoo sana nasıl\nhitap etsin?" : "What should\nPersoo call you?").font(.system(size: 36, weight: .semibold)).tracking(-1.3)
            Text("Deniz").font(.system(size: 27)).padding(.top, 42).padding(.bottom, 16)
            Rectangle().fill(p.accent).frame(height: 2)
            Spacer()
            PrimaryAction(title: turkish ? "Devam" : "Continue", action: { navigate(.homeEmpty) }).padding(.bottom, 22)
        }
    }
    var emptyHome: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Text(turkish ? "Bugün neler oldu?" : "What happened\ntoday?").font(.system(size: 40, weight: .medium)).tracking(-1.5).lineSpacing(1)
            Text(turkish ? "Sadece anlat. Persoo bir araya getirsin." : "Just tell me.\nI'll put it together.").font(.system(size: 19)).foregroundStyle(p.secondary).lineSpacing(5).padding(.top, 22)
            Spacer()
            dictateButton
            Text(turkish ? "Ya da yazarak anlat" : "Or write it down").font(.system(size: 14, weight: .medium)).foregroundStyle(p.secondary).frame(maxWidth: .infinity).padding(.top, 18).padding(.bottom, 30)
        }
    }
    var dictateButton: some View { PrimaryAction(title: turkish ? "Anlatmaya başla" : "Tell Persoo", symbol: "waveform", action: { navigate(.dictation) }) }
    var populatedHome: some View {
        VStack(alignment: .leading, spacing: 0) {
            LabelText(text: "TODAY · 14:32")
            Text("Spent €34 at Lidl, drank 1.5 litres of water, trained chest and finished my finance assignment.").font(.system(size: 23, weight: .medium)).tracking(-0.4).lineSpacing(4).padding(.top, 15)
            HStack(spacing: 7) { Image(systemName: "checkmark.circle.fill"); Text("4 updates saved") }.font(.system(size: 13, weight: .medium)).foregroundStyle(p.accent).padding(.top, 24).padding(.bottom, 5)
            DetailRow(symbol: "creditcard", title: "Lidl", subtitle: "Finance · Groceries", value: "€34")
            Rule()
            DetailRow(symbol: "drop", title: "Water", subtitle: "Health · Today", value: "1.5 L")
            Rule()
            DetailRow(symbol: "dumbbell", title: "Chest workout", subtitle: "Fitness · Recorded", value: "✓")
            Rule()
            DetailRow(symbol: "checkmark", title: "Finance assignment", subtitle: "School · Completed", value: "✓")
            HStack { Text("Review updates"); Spacer(); Text("Undo") }.font(.system(size: 13, weight: .medium)).foregroundStyle(p.accent).padding(.top, 14)
            Spacer(minLength: 10)
            dictateButton
        }
    }
    var purchaseHome: some View {
        VStack(alignment: .leading, spacing: 0) {
            LabelText(text: "TODAY · 14:32")
            Text("Spent €6.20 on\nan energy drink.").font(.system(size: 30, weight: .medium)).tracking(-0.7).lineSpacing(3).padding(.top, 24)
            HStack(spacing: 7) { Image(systemName: "checkmark.circle.fill"); Text("Saved to Finance") }.font(.system(size: 14, weight: .medium)).foregroundStyle(p.accent).padding(.top, 36)
            Rule().padding(.top, 20)
            LedgerRow(merchant: "Energy drink", category: "Drinks · Today", amount: "€6.20")
            Rule()
            Text("Review  ·  Undo").font(.system(size: 13, weight: .medium)).foregroundStyle(p.accent).padding(.top, 16)
            Spacer()
            dictateButton.padding(.bottom, 16)
        }
    }
    var dictation: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack { Text("Cancel"); Spacer(); Circle().fill(Color(hex: 0xAD3434)).frame(width: 7, height: 7); Text("00:06").monospacedDigit() }.font(.system(size: 15, weight: .medium)).foregroundStyle(p.secondary).padding(.top, 12)
            Spacer()
            LabelText(text: "LISTENING")
            Text("Spent €6.20\non an energy drink.").font(.system(size: 37, weight: .medium)).tracking(-1.2).lineSpacing(3).padding(.top, 23)
            Spacer()
            HStack(alignment: .center, spacing: 5) {
                ForEach(0..<35, id: \.self) { i in Capsule().fill(p.accent.opacity(i < 26 ? 1 : 0.22)).frame(width: 4, height: CGFloat(8 + Int(abs(sin(Double(i)*1.7))*38))) }
            }.frame(maxWidth: .infinity).frame(height: 66).padding(.bottom, 25)
            PrimaryAction(title: "Done", symbol: "checkmark", action: { navigate(.purchase) })
            Text("Transcribed on this device").font(.system(size: 13)).foregroundStyle(p.secondary).frame(maxWidth: .infinity).padding(.top, 18).padding(.bottom, 20)
        }
    }
    var health: some View {
        VStack(alignment: .leading, spacing: 0) {
            LabelText(text: "THIS WEEK")
            Button { navigate(.fitness) } label: {
                VStack(alignment: .leading, spacing: 0) {
                    SectionTitle(title: "Fitness", trailing: "View ›")
                    Metric(value: "3", unit: "of 4 workouts", caption: "One more to reach your weekly target.").padding(.top, 12)
                    WeekBars()
                }
            }.buttonStyle(.plain).padding(.top, 16)
            Rule()
            SectionTitle(title: "Water today")
            Metric(value: "1.5", unit: "L", caption: "Your target is 2 litres.").padding(.top, 12)
            GeometryReader { geo in ZStack(alignment: .leading) { Capsule().fill(p.soft); Capsule().fill(p.accent).frame(width: geo.size.width * 0.75) } }.frame(height: 7).padding(.top, 22)
            Text("Based on what you've recorded.").font(.system(size: 13)).foregroundStyle(p.secondary).padding(.top, 26)
            Spacer(minLength: 0)
        }
    }
    var fitness: some View {
        VStack(alignment: .leading, spacing: 0) {
            LabelText(text: "THIS WEEK")
            Metric(value: "3", unit: "of 4 workouts", caption: "A little consistency goes a long way.").padding(.top, 14)
            WeekBars()
            HStack { VStack(alignment: .leading, spacing: 5) { Text("135 min").font(.system(size: 21, weight: .semibold)); Text("Time recorded").font(.system(size: 12)).foregroundStyle(p.secondary) }; Spacer(); VStack(alignment: .leading, spacing: 5) { Text("3 weeks").font(.system(size: 21, weight: .semibold)); Text("Active each week").font(.system(size: 12)).foregroundStyle(p.secondary) } }.padding(.vertical, 15)
            Rule()
            SectionTitle(title: "Workout history")
            DetailRow(symbol: "dumbbell", title: "Chest", subtitle: "Friday · 4 exercises", value: "45 min")
            Rule()
            DetailRow(symbol: "figure.strengthtraining.traditional", title: "Legs", subtitle: "Wednesday · 5 exercises", value: "48 min")
            Rule()
            DetailRow(symbol: "figure.strengthtraining.traditional", title: "Upper body", subtitle: "Monday · 4 exercises", value: "42 min")
            Spacer(minLength: 0)
        }
    }
    var finance: some View {
        VStack(alignment: .leading, spacing: 0) {
            LabelText(text: "LAST 30 DAYS")
            Metric(value: "€486.40", unit: "", caption: "Recorded spending").padding(.top, 14)
            HStack(spacing: 3) { Rectangle().fill(p.accent).frame(width: 172); Rectangle().fill(p.accent.opacity(0.6)).frame(width: 93); Rectangle().fill(p.soft) }.frame(height: 6).clipShape(Capsule()).padding(.top, 23)
            HStack { Text("Groceries 54%"); Spacer(); Text("Other 46%") }.font(.system(size: 12)).foregroundStyle(p.secondary).padding(.top, 10)
            Button { navigate(.savings) } label: {
                VStack(alignment: .leading, spacing: 12) {
                    HStack { Text("A LITTLE PERSPECTIVE").font(.system(size: 10, weight: .bold)).tracking(1.3); Spacer(); Image(systemName: "arrow.up.right") }
                    Text("Small purchases.\nRoom for bigger plans.").font(.system(size: 24, weight: .medium)).tracking(-0.6)
                    Text("Explore a savings opportunity ›").font(.system(size: 13, weight: .medium))
                }.foregroundStyle(p.accent).padding(22).frame(maxWidth: .infinity, alignment: .leading).background(p.soft, in: RoundedRectangle(cornerRadius: 20))
            }.buttonStyle(.plain).padding(.top, 25)
            SectionTitle(title: "Latest", trailing: "See all ›").padding(.top, 10)
            LedgerRow(merchant: "Lidl", category: "Groceries", amount: "€34.20")
            Rule()
            LedgerRow(merchant: "Coffee", category: "Eating out", amount: "€5.80")
            Spacer(minLength: 0)
        }
    }
    var transactions: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack { Image(systemName: "magnifyingglass"); Text("Search transactions"); Spacer() }.font(.system(size: 16)).foregroundStyle(p.secondary).padding(14).background(p.soft, in: RoundedRectangle(cornerRadius: 12))
            LabelText(text: "TODAY").padding(.top, 30)
            LedgerRow(merchant: "Lidl", category: "Groceries · 16:24", amount: "€34.20"); Rule()
            LedgerRow(merchant: "Coffee", category: "Eating out · 11:05", amount: "€5.80"); Rule()
            LedgerRow(merchant: "Amazon", category: "Shopping · 09:18", amount: "€47.00"); Rule()
            LedgerRow(merchant: "Energy drink", category: "Drinks · 08:42", amount: "€6.20")
            LabelText(text: "YESTERDAY").padding(.top, 24)
            LedgerRow(merchant: "Train ticket", category: "Transport", amount: "€12.00"); Rule()
            LedgerRow(merchant: "Book return", category: "Shopping · Refund", amount: "+€18.00")
            Spacer(minLength: 0)
        }
    }
    var savings: some View {
        VStack(alignment: .leading, spacing: 0) {
            LabelText(text: "ENERGY DRINKS · LAST 30 DAYS")
            Text("€74").font(.system(size: 76, weight: .semibold)).tracking(-3).padding(.top, 10)
            Text("Across 12 recorded purchases.").font(.system(size: 16)).foregroundStyle(p.secondary).padding(.top, 3)
            Text("View the transactions ›").font(.system(size: 13, weight: .medium)).foregroundStyle(p.accent).padding(.top, 13)
            Rule().padding(.vertical, 23)
            Text("If you chose to skip them").font(.system(size: 19, weight: .semibold))
            HStack(alignment: .top) {
                scenario("1 month", "€74"); Spacer(); scenario("6 months", "€444"); Spacer(); scenario("1 year", "€888")
            }.padding(.top, 21)
            Text("If monthly spending stayed the same.\nPotential savings, not a prediction.").font(.system(size: 12)).foregroundStyle(p.secondary).lineSpacing(3).padding(.top, 17)
            Rule().padding(.vertical, 22)
            LabelText(text: "WHAT €888 COULD BECOME")
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "flag").font(.system(size: 22)).foregroundStyle(p.accent).padding(.top, 4)
                VStack(alignment: .leading, spacing: 7) { Text("A weekend\nin Copenhagen").font(.system(size: 23, weight: .semibold)).tracking(-0.4); Text("From your Plans · €900 estimate").font(.system(size: 12)).foregroundStyle(p.secondary) }
            }.padding(.top, 16)
            Spacer(minLength: 10)
            PrimaryAction(title: "Explore my plan", quiet: true, action: { navigate(.plans) })
        }
    }
    func scenario(_ period: String, _ amount: String) -> some View { VStack(alignment: .leading, spacing: 8) { Text(period).font(.system(size: 12)).foregroundStyle(p.secondary); Text(amount).font(.system(size: 29, weight: .semibold)).tracking(-1).monospacedDigit() } }
    var school: some View {
        VStack(alignment: .leading, spacing: 0) {
            LabelText(text: "TOMORROW")
            Text("A clear start\nto your day.").font(.system(size: 30, weight: .medium)).tracking(-0.8).padding(.top, 16)
            AgendaRow(time: "09:00", end: "10:30", title: "Economics", place: "Room B204", current: true).padding(.top, 24)
            Rule()
            Button { navigate(.schedule) } label: { HStack { Text("View your schedule"); Spacer(); Image(systemName: "arrow.right") }.font(.system(size: 15, weight: .medium)).foregroundStyle(p.accent).frame(height: 52) }.buttonStyle(.plain)
            SectionTitle(title: "Coming up").padding(.top, 12)
            DetailRow(symbol: "doc.text", title: "Statistics assignment", subtitle: "Due tomorrow · 18:00", value: "1 day")
            Rule()
            DetailRow(symbol: "pencil", title: "Microeconomics exam", subtitle: "Friday · 10:00", value: "3 days")
            Rule()
            DetailRow(symbol: "checkmark.circle", title: "Finance assignment", subtitle: "Completed today", value: "✓")
            Spacer(minLength: 0)
        }
    }
    var schedule: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack { Text("MON"); Text("TUE").foregroundStyle(p.accent); Text("WED"); Text("THU"); Text("FRI") }.font(.system(size: 12, weight: .semibold)).tracking(1.3).frame(maxWidth: .infinity).padding(.vertical, 15)
            Rule()
            AgendaRow(time: "09:00", end: "10:30", title: "Economics", place: "Room B204", current: true)
            AgendaRow(time: "11:00", end: "12:30", title: "Finance", place: "Lecture hall A")
            AgendaRow(time: "14:00", end: "15:30", title: "Statistics", place: "Room C102")
            Rule().padding(.top, 8)
            Text("Your day ends at 15:30.").font(.system(size: 22, weight: .medium)).tracking(-0.3).padding(.top, 25)
            Text("From your school calendar\nUpdated 10 minutes ago").font(.system(size: 13)).foregroundStyle(p.secondary).lineSpacing(4).padding(.top, 14)
            Spacer(minLength: 0)
        }
    }
    var plans: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Things to look\nforward to.").font(.system(size: 30, weight: .medium)).tracking(-0.8)
            VStack(alignment: .leading, spacing: 18) {
                HStack { LabelText(text: "A LITTLE GETAWAY"); Spacer(); Image(systemName: "flag").foregroundStyle(p.accent) }
                Text("A weekend\nin Copenhagen").font(.system(size: 32, weight: .semibold)).tracking(-1)
                HStack { Text("€900").font(.system(size: 24, weight: .medium)); Spacer(); Text("Your estimate").font(.system(size: 13)).foregroundStyle(p.secondary) }
                Rule()
                Text("Walk by the water.\nFind a café. Take it slowly.").font(.system(size: 16)).foregroundStyle(p.secondary).lineSpacing(3)
            }.padding(24).background(p.soft, in: RoundedRectangle(cornerRadius: 20)).padding(.top, 28)
            SectionTitle(title: "Also on your mind").padding(.top, 16)
            DetailRow(symbol: "book", title: "Read more this year", subtitle: "Personal · Active", value: "›"); Rule()
            DetailRow(symbol: "camera", title: "A camera of my own", subtitle: "Wishlist · Exploring", value: "›")
            Spacer(minLength: 0)
        }
    }
    var context: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("A little about you.\nAlways yours to change.").font(.system(size: 23, weight: .medium)).tracking(-0.5).lineSpacing(3)
            ContextFact(title: "Call me Deniz.", source: "From onboarding · Confirmed").padding(.top, 22)
            Rule()
            ContextFact(title: "I'd like to visit Copenhagen.", source: "From your plan · You added this")
            Rule()
            ContextFact(title: "Evening workouts may suit you.", source: "Based on 6 recorded workouts · Not confirmed", inferred: true)
            Rule()
            Text("An observation is not a fact.\nConfirm it, correct it, or let it go.").font(.system(size: 14)).foregroundStyle(p.secondary).lineSpacing(4).padding(.top, 22)
            Spacer(minLength: 0)
        }
    }
    var reminder: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 0)
            Image(systemName: "sun.horizon").font(.system(size: 43, weight: .light)).foregroundStyle(p.accent)
            Text("Tomorrow starts\nat 09:00.").font(.system(size: 37, weight: .semibold)).tracking(-1.1).padding(.top, 26)
            Text("Economics · Room B204").font(.system(size: 18)).foregroundStyle(p.secondary).padding(.top, 15)
            Rule().padding(.vertical, 28)
            HStack(alignment: .top, spacing: 13) { Image(systemName: "doc.text").foregroundStyle(p.accent); VStack(alignment: .leading, spacing: 7) { Text("Statistics assignment").font(.system(size: 18, weight: .medium)); Text("Due tomorrow at 18:00").font(.system(size: 14)).foregroundStyle(p.secondary) } }
            Text("From your schedule and assignments.").font(.system(size: 12)).foregroundStyle(p.secondary).padding(.top, 24)
            Spacer(minLength: 20)
            PrimaryAction(title: "See tomorrow", quiet: true, action: { navigate(.schedule) })
            Text("Remind me later").font(.system(size: 14, weight: .medium)).foregroundStyle(p.secondary).frame(maxWidth: .infinity).padding(.top, 17).padding(.bottom, 10)
        }
    }
    var settings: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your model. Your choice.").font(.system(size: 29, weight: .medium)).tracking(-0.8)
            Text("Connect your own model endpoint.").font(.system(size: 14)).foregroundStyle(p.secondary).lineSpacing(3).padding(.top, 13)
            field("ENDPOINT", "https://your-server.example/v1").padding(.top, 30)
            field("MODEL", "Choose a model")
            field("API KEY", "••••••••••••••••")
            PrimaryAction(title: "Test connection", quiet: true).padding(.top, 20)
            HStack(alignment: .top, spacing: 10) { Image(systemName: "lock.shield"); Text("Requests go to your endpoint.\nCredentials stay in Keychain.") }.font(.system(size: 13)).foregroundStyle(p.secondary).lineSpacing(3).padding(.top, 24)
            Rule().padding(.top, 22)
            DetailRow(symbol: "waveform", title: "Speech recognition", subtitle: "Local Whisper · On this device", value: "›")
            Spacer(minLength: 0)
        }
    }
    func field(_ label: String, _ value: String) -> some View { VStack(alignment: .leading, spacing: 10) { LabelText(text: label); Text(value).font(.system(size: 15)).foregroundStyle(p.secondary).frame(maxWidth: .infinity, alignment: .leading).padding(15).background(p.soft, in: RoundedRectangle(cornerRadius: 12)) }.padding(.bottom, 16) }
    var life: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Everything has its place.").font(.system(size: 19)).foregroundStyle(p.secondary).padding(.bottom, 25)
            domain("School", "Today's classes and what's due", "graduationcap", .school)
            domain("Finance", "Spending, with perspective", "creditcard", .finance)
            domain("Health", "Movement, water and consistency", "heart", .health)
            domain("Personal", "What Persoo understands about you", "person.crop.circle", .context)
            domain("To-do", "One thing at a time", "checklist", .todo)
            domain("Plans", "Things to look forward to", "flag", .plans)
            Spacer(minLength: 0)
        }
    }
    func domain(_ title: String, _ subtitle: String, _ symbol: String, _ target: Screen) -> some View { VStack(spacing: 0) { Button { navigate(target) } label: { DetailRow(symbol: symbol, title: title, subtitle: subtitle, value: "›") }.buttonStyle(.plain); Rule() } }
    var todo: some View {
        VStack(alignment: .leading, spacing: 0) {
            LabelText(text: "UP NEXT")
            DetailRow(symbol: "circle", title: "Statistics assignment", subtitle: "Tomorrow · 18:00", value: ""); Rule()
            DetailRow(symbol: "circle", title: "Book a dentist visit", subtitle: "No date set", value: ""); Rule()
            DetailRow(symbol: "circle", title: "Return the library books", subtitle: "Friday", value: "")
            LabelText(text: "DONE TODAY").padding(.top, 32)
            DetailRow(symbol: "checkmark.circle.fill", title: "Finance assignment", subtitle: "Completed from your update", value: "")
            Spacer()
            Text("Tell Persoo when something's done.").font(.system(size: 16)).foregroundStyle(p.secondary).padding(.bottom, 18)
            dictateButton
        }
    }
}
