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
//        NSSortDescriptor(keyPath: \Grid.correctCount, ascending: true)
      ]
    ) var grids: FetchedResults<Grid>
    
    var currentGrid: Grid {
        get {
            if grids.count == 0 {
                initData()
            }
            return grids[currentGridIndex]
        }
    }
    var selected: [[Bool]] {
        get { return currentGrid.selected as! [[Bool]] }
    }
    var placement: [[String]] {
        get { return currentGrid.placement as! [[String]] }
    }
    var correctness: [[Int]] {
        get { return currentGrid.correctness as! [[Int]] }
    }
    var groups: [[String]] {
        get { return currentGrid.groups as! [[String]] }
    }

    @State var currentGridIndex = 0
    @State var dragOffset = CGSize.zero
    @State var peekFlip = 0
    
    func initData() {
        if grids.count == 0 {
            for grouping in GridInfo.groupings {
                let groups: [[String]] = (grouping.map { $0.1 })
                let grid = Grid(context: managedObjectContext)
                grid.groups = groups as NSObject
                grid.correctCount = 0
                grid.selectedCount = 0
                var placement: [[String]] = [[String]](repeating: [String](repeating: "", count: 4), count: 4)
                let randomPositions = Array(0..<16).shuffled()
                for (i, j) in randomPositions.enumerated() {
                    let row = i / 4
                    let col = i - row * 4
                    let keyRow = j / 4
                    let keyCol = j - keyRow * 4
                    placement[row][col] = groups[keyRow][keyCol]
                }
                grid.placement = placement as NSObject
                grid.correctness = [[Int]](repeating: [Int](repeating: 0, count: 4), count: 4) as NSObject
                grid.selected = [[Bool]](repeating: [Bool](repeating: false, count: 4), count: 4) as NSObject
            }
            saveContext()
        }
    }
    
//    init() {
//        loadData()
//    }
    
    let darkColor = Color(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
    let zeroOffset = CGSize(width: 0, height: 0)
    let offset = CGSize(width: -3, height: -3)

    func verifyGuesses() {
        var guesses: [String] = []
        var indices: [(Int, Int)] = []
        for (i, row) in self.selected.enumerated() {
            for (j, entry) in row.enumerated() {
                if entry {
                    guesses.append(self.placement[i][j])
                    indices.append((i, j))
                }
            }
        }
        guesses.sort()
        // Check if any of the categories contain all the elements
        var correct = false
        for group in self.groups {
            var sortedGroup = group
            sortedGroup.sort()
            if sortedGroup == guesses {
                correct = true
                self.currentGrid.correctCount += 4
                break
            }
        }
        
        colorChange(indices: indices, correct: correct)
        
        // Clear guesses
        var selectedTemp = self.selected
        for i in 0..<self.selected.count {
            for j in 0..<self.selected[i].count {
                selectedTemp[i][j] = false
            }
        }
        self.currentGrid.selected = selectedTemp as NSObject
        self.currentGrid.selectedCount = 0
        saveContext()
    }
    
    func colorChange(indices: [(Int, Int)], correct: Bool) {
        var correctnessTemp = self.correctness
        for index in indices {
            if correct {
                correctnessTemp[index.0][index.1] = 1
                self.currentGrid.correctness = correctnessTemp as NSObject
            }
            else {
                correctnessTemp[index.0][index.1] = -1
                self.currentGrid.correctness = correctnessTemp as NSObject
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    withAnimation(.easeInOut) {
                        correctnessTemp[index.0][index.1] = 0
                        self.currentGrid.correctness = correctnessTemp as NSObject
                        saveContext()
                    }
                })
            }
        }
    }
    
    func clearGrid() {
        // Clear selections
        var selectedTemp = self.selected
        for i in 0..<self.selected.count {
            for j in 0..<self.selected[i].count {
                selectedTemp[i][j] = false
            }
        }
        self.currentGrid.selected = selectedTemp as NSObject
        self.currentGrid.selectedCount = 0
        
        // Clear correct guesses
        var correctnessTemp = self.correctness
        for i in 0..<self.correctness.count {
            for j in 0..<self.correctness[i].count {
                correctnessTemp[i][j] = 0
            }
        }
        self.currentGrid.correctness = correctnessTemp as NSObject
        self.currentGrid.correctCount = 0
        saveContext()
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
                                            .rotation3DEffect(self.peekFlip == -1 ? Angle(degrees: 5): (self.peekFlip == 1 ? Angle(degrees: -5) : Angle(degrees: 0)), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                                        Text(String(self.placement[row][col])).font(Font.custom("Nunito-Light", size: 18))
                                            .offset(self.selected[row][col] ? self.offset : self.zeroOffset)
                                            .animation(.easeInOut(duration: 0.1))
                                            
                                    }.onTapGesture {
                                        if self.correctness[row][col] != 1 {
                                            var selectedTemp = self.selected
                                            selectedTemp[row][col] = !selectedTemp[row][col]
                                            self.currentGrid.selected = selectedTemp as NSObject
                                            if self.selected[row][col] {
                                                self.currentGrid.selectedCount += 1
                                                if self.currentGrid.selectedCount >= 4 {
                                                    self.verifyGuesses()
                                                }
                                            } else {
                                                self.currentGrid.selectedCount -= 1
                                                if self.currentGrid.selectedCount < 0 {
                                                    self.currentGrid.selectedCount = 0
                                                }
                                            }
                                            saveContext()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }.gesture(DragGesture()
                .onChanged { value in
                    self.dragOffset = value.translation
                    print(self.dragOffset)
                    if self.dragOffset.height > 200 {
                        self.clearGrid()
                    } else if self.dragOffset.width > 150 {
                        self.peekFlip = -1
                    } else if self.dragOffset.width < -150 {
                        self.peekFlip = 1
                    } else {
                        self.peekFlip = 0
                    }
                }
                .onEnded { value in
                    if self.peekFlip == -1 && self.currentGridIndex > 0 {
                        self.currentGridIndex -= 1
                    } else if self.peekFlip == 1 && self.currentGridIndex < self.grids.count - 1{
                        self.currentGridIndex += 1
                    }
                    self.peekFlip = 0
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
