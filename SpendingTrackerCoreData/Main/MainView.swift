//
//  MainView.swift
//  SpendingTrackerCoreData
//
//  Created by Алексей Азаренков on 12.02.2024.
//

import SwiftUI

struct MainView: View {
    
    @State private var shouldPresentAddCardForm = false
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    @State private var cardSelectionIndex = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                if !cards.isEmpty {
                    TabView(selection: $cardSelectionIndex) {
                        ForEach(0..<cards.count, id: \.self) { i in
                            let card = cards[i]
                            CreditCardView(card: card)
                                .padding(.bottom, 50)
                                .tag(i)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 280)
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    
                    if cards[cardSelectionIndex] != nil {
                        let selectedCard = cards[cardSelectionIndex]
//                        Text(selectedCard.name ?? "")
                        TransactionsListView(card: selectedCard)
                    }
                       
                    
                    
//                    TabView {
//                        ForEach(cards) { card in
//                            CreditCardView(card: card)
//                                .padding(.bottom, 50)
//                        }
//                    }
                    
                    
                    
                } else {
                    EmptyPromptMessage
                }
            }
            .navigationTitle("Credit Cards")
            .navigationBarItems(trailing: addCardButton)
            .fullScreenCover(isPresented: $shouldPresentAddCardForm, onDismiss: nil) {
                AddCardForm()
            }
        }
    }
    
    private var EmptyPromptMessage: some View {
        VStack {
            
            Text("You currently have no cards in the application")
                .padding(.horizontal, 48)
                .padding(.vertical)
                .multilineTextAlignment(.center)
            
            Button {
                shouldPresentAddCardForm.toggle()
            } label: {
                Text("+ Add Your First Card")
            }
            .buttonStyle(.borderedProminent)
        }
        .font(.system(size: 22, weight: .semibold))
    }
    
    struct CreditCardView: View {
        
        let card: Card
        
        init(card: Card) {
            self.card = card
            
            fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [
                .init(key: "timestamp", ascending: false)
            ], predicate: .init(format: "card == %@", self.card))
        }
        
        @Environment(\.managedObjectContext) private var viewContext

        var fetchRequest: FetchRequest<CardTransaction>
        
        @State private var shouldShowActionSheet = false
        @State private var shouldShowEditForm = false
        
        @State var refreshId = UUID()

        private func handleDelete() {
            let viewContext = PersistenceController.shared.container.viewContext
            
            viewContext.delete(card)
            
            do {
                try viewContext.save()
            } catch {
                
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(card.name ?? "")
                        .font(.system(size: 24, weight: .semibold))
                    Spacer()
                    Button {
                        shouldShowActionSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 26, weight: .bold))
                    }
                    .actionSheet(isPresented: $shouldShowActionSheet) {
                        .init(title: Text(card.name ?? ""), message: Text("Options"), buttons: [
                            .default(Text("Edit"), action: {
                                shouldShowEditForm.toggle()
                            }),
                            .destructive(Text("Delete Card"), action: handleDelete),
                            .cancel()
                        ])
                    }
                }
                
                HStack {
                    let imageName = card.type?.lowercased() ?? ""
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                        .clipped()
                    Spacer()
                    
                    let balance = fetchRequest.wrappedValue.reduce(0, { $0 + $1.amount })
                    
                    if balance != nil {
                        Text("Balance: $\(String(format: "%.2f", balance))")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                                    
                Text(card.number ?? "")
                
                HStack {
                    Text("Credit Limit: $\(card.limit)")
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Valid Thru")
                        Text("\(String(format: "%02d", card.expMonth))/\(String(card.expYear % 2000))")
                    }
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(
                
                VStack {
                    if let colorData = card.color,
                       let uiColor = UIColor.color(data: colorData) {
                        LinearGradient(colors: [Color(uiColor).opacity(0.6), Color(uiColor)], startPoint: .center, endPoint: .bottom)
                    } else {
                        Color.purple
                    }
                      
                    
                }
            )
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(.black.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(8)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top, 8)
            
            .fullScreenCover(isPresented: $shouldShowEditForm) {
                AddCardForm(card: self.card)
            }
        }
    }
    
    var addCardButton: some View {
        Button(action: {
            shouldPresentAddCardForm.toggle()
        }, label: {
            Text("+ Card")
        })
        .buttonStyle(.borderedProminent)
    }
}

//#Preview {
//    let viewContext = PersistenceController.shared.container.viewContext
//    MainView()
//        .environment(\.managedObjectContext, viewContext)
////    AddCardForm()
//}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, viewContext)
    }
}

