//
//  ContentView.swift
//  Link
//
//  Created by Eli Zhang on 12/17/20.
//  Copyright © 2020 Eli Zhang. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State var placement: [[String]] = getWordPlacement()
    @State var selected: [[Bool]] = getEmptyGrid()
    @State var selectedCount = 0
    
    let darkColor = Color(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
    let zeroOffset = CGSize(width: 0, height: 0)
    let offset = CGSize(width: -3, height: -3)
//    let selectedColor = Color(UIColor(red: 0.3, green: 0.2, blue: 0.5, alpha: 1))
    
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
    
    static func getWordPlacement() -> [[String]] {
        let keys = [["Cosmopolitan", "W", "Seventeen", "V"], ["Kamikaze", "Nixon", "Vargtass", "Cremat"], ["Harris", "Styles", "Mayer", "Jonas"], ["Joy", "Artichoke", "Nightingale", "Grecian Urn"]]
        var placement: [[String]] = [[String]](repeating: [String](repeating: "", count: 4), count: 4)
        let randomPositions = Array(0..<16).shuffled()
        for (i, j) in randomPositions.enumerated() {
            let row = i / 4
            let col = i - row * 4
            let keyRow = j / 4
            let keyCol = j - keyRow * 4
            placement[row][col] = keys[keyRow][keyCol]
        }
        return placement
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("background2").resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    VStack(spacing: 5) {
                        ForEach((0...3), id: \.self) { row in
                            HStack(spacing: 5) {
                                ForEach((0...3), id: \.self) { col in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                            .fill(self.colorScheme == .light ? Color.white : self.darkColor)
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
                                        self.selected[row][col] = !self.selected[row][col]
                                        if self.selected[row][col] {
                                            self.selectedCount -= 1
                                        } else {
                                            self.selectedCount += 1
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
