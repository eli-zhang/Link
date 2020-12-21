//
//  ContentView.swift
//  Link
//
//  Created by Eli Zhang on 12/17/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(
      entity: Grid.entity(),
      sortDescriptors: [
        NSSortDescriptor(keyPath: \Grid.correctCount, ascending: true)
      ]
    ) var grids: FetchedResults<Grid>
    
    @State var placement: [[String]]
    @State var selected: [[Bool]] = getEmptyGrid()
    @State var correctness: [[Int]] = [[Int]](repeating: [Int](repeating: 0, count: 4), count: 4)
    @State var selectedCount = 0
    @State var correctCount = 0
    
    init() {
        var placement: [[String]] = [[String]](repeating: [String](repeating: "", count: 4), count: 4)
        let randomPositions = Array(0..<16).shuffled()
        for (i, j) in randomPositions.enumerated() {
            let row = i / 4
            let col = i - row * 4
            let keyRow = j / 4
            let keyCol = j - keyRow * 4
            placement[row][col] = groups[keyRow][keyCol]
        }
        _placement = State(initialValue: placement)
    }
    
    let groups = [["Straw", "Deliver", "Spoons", "Desserts"], ["Patience", "Euchre", "Tressette", "Canasta"], ["Java", "Stata", "Turing", "Haskell"], ["Tabla", "Celesta", "Agung", "Grecian Djembe"]]
    let darkColor = Color(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
    let zeroOffset = CGSize(width: 0, height: 0)
    let offset = CGSize(width: -3, height: -3)
    
    static func getEmptyGrid() -> [[Bool]] {
        var grid: [[Bool]] = []
        for _ in 0..<4 {
            var row: [Bool] = []
            for _ in 0..<4 {
                row.append(false)
            }
            grid.append(row)
        }
        return grid
    }

    func verifyGuesses() {
        var guesses: [String] = []
        var indices: [(Int, Int)] = []
        for (i, row) in selected.enumerated() {
            for (j, entry) in row.enumerated() {
                if entry {
                    guesses.append(placement[i][j])
                    indices.append((i, j))
                }
            }
        }
        guesses.sort()
        // Check if any of the categories contain all the elements
        var correct = false
        for group in groups {
            var sortedGroup = group
            sortedGroup.sort()
            if sortedGroup == guesses {
                correct = true
                correctCount += 4
                break
            }
        }
        
        colorChange(indices: indices, correct: correct)
        
        // Clear grid
        for i in 0..<self.selected.count {
            for j in 0..<self.selected[i].count {
                self.selected[i][j] = false
            }
        }
        self.selectedCount = 0
    }
    
    func colorChange(indices: [(Int, Int)], correct: Bool) {
        for index in indices {
            if correct {
                self.correctness[index.0][index.1] = 1
            }
            else {
                self.correctness[index.0][index.1] = -1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    withAnimation(.easeInOut) {
                        self.correctness[index.0][index.1] = 0
                    }
                })
            }
        }
    }
    
    func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("background").resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    VStack(spacing: 5) {
                        ForEach((0...3), id: \.self) { row in
                            HStack(spacing: 5) {
                                ForEach((0...3), id: \.self) { col in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                            .fill(self.correctness[row][col] == -1 ? Color.red : (self.correctness[row][col] == 1 ? Color.green : (self.colorScheme == .light ? Color.white : self.darkColor)))
                                            .frame(width: (geometry.size.width - 50) / 4, height: (geometry.size.height - 50) / 4)
                                            .shadow(radius: 1,
                                                    x: self.selected[row][col] ? 3: 1,
                                                    y: self.selected[row][col] ? 3 : 1)
                                            .offset(self.selected[row][col] ? self.offset : self.zeroOffset)
                                            .animation(.easeInOut(duration: 0.1))
                                        Text(String(self.placement[row][col])).font(Font.custom("Nunito-Light", size: 18))
                                            .offset(self.selected[row][col] ? self.offset : self.zeroOffset)
                                            .animation(.easeInOut(duration: 0.1))
                                    }.onTapGesture {
                                        if self.correctness[row][col] != 1 {
                                            self.selected[row][col] = !self.selected[row][col]
                                            if self.selected[row][col] {
                                                self.selectedCount += 1
                                                if self.selectedCount >= 4 {
                                                    self.verifyGuesses()
                                                }
                                            } else {
                                                self.selectedCount -= 1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
