//
//  ContentView.swift
//  Example
//
//  Created by Daniil Manin on 27.09.2021.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI
import FloatingButton

struct ContentView: View {
    var body: some View {
        ScreenIconsAndText()
    }
}

struct ScreenIconsAndText: View {
    
    @State var isOpen = false
    
    var body: some View {
        let mainButton1 = MainButton(imageName: "star.fill", colorHex: "f7b731", width: 60)
        let mainButton2 = MainButton(imageName: "heart.fill", colorHex: "eb3b5a", width: 60)
        let textButtons = MockData.iconAndTextTitles.enumerated().map { index, value in
            IconAndTextButton(imageName: MockData.iconAndTextImageNames[index], buttonText: value)
                .onTapGesture { isOpen.toggle() }
        }
            
        let menu1 = FloatingButton(mainButtonView: mainButton1, buttons: textButtons, isOpen: $isOpen)
            .straight()
            .direction(.top)
            .alignment(.left)
            .spacing(10)
            .initialOffset(x: -1000)
            .animation(.spring())
        
        let menu2 = FloatingButton(mainButtonView: mainButton2, buttons: textButtons)
            .straight()
            .direction(.top)
            .alignment(.right)
            .spacing(10)
            .initialOpacity(0)
        
        return NavigationView {
            VStack {
                HStack {
                    menu1
                    Spacer().layoutPriority(10)
                    menu2
                }
            }
            .padding(20)
            .navigationBarItems(
                trailing:
                    NavigationLink(destination: ScreenStraight()) {
                        Image(systemName: "arrow.right.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(.trailing, 10)
                    }
                    .isDetailLink(false)
            )
        }
    }
}

struct ScreenStraight: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        let mainButton1 = MainButton(imageName: "thermometer", colorHex: "f7b731")
        let mainButton2 = MainButton(imageName: "cloud.fill", colorHex: "eb3b5a")
        let buttonsImage = MockData.iconImageNames.enumerated().map { index, value in
            IconButton(imageName: value, color: MockData.colors[index])
        }
        
        let menu1 = FloatingButton(mainButtonView: mainButton1, buttons: buttonsImage)
            .straight()
            .direction(.right)
            .delays(delayDelta: 0.1)
        
        let menu2 = FloatingButton(mainButtonView: mainButton2, buttons: buttonsImage)
            .straight()
            .direction(.top)
            .delays(delayDelta: 0.1)
        
        return VStack {
            Spacer()
            HStack {
                menu1
                Spacer()
                menu2
            }
            .padding(20)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "arrow.left.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading, 10)
                },
            trailing:
                NavigationLink(destination: ScreenCircle()) {
                    Image(systemName: "arrow.right.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 10)
                }
                .isDetailLink(false)
        )
    }
}

struct ScreenCircle: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        let mainButton1 = MainButton(imageName: "message.fill", colorHex: "f7b731")
        let mainButton2 = MainButton(imageName: "umbrella.fill", colorHex: "eb3b5a")
        let buttonsImage = MockData.iconImageNames.enumerated().map { index, value in
            IconButton(imageName: value, color: MockData.colors[index])
        }
        
        let menu1 = FloatingButton(mainButtonView: mainButton2, buttons: buttonsImage.dropLast())
            .circle()
            .startAngle(3/2 * .pi)
            .endAngle(2 * .pi)
            .radius(70)
        let menu2 = FloatingButton(mainButtonView: mainButton1, buttons: buttonsImage)
            .circle()
            .delays(delayDelta: 0.1)
        
        return VStack {
            Spacer()
            HStack {
                menu1
                Spacer()
                menu2
                Spacer()
            }
            .padding(20)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "arrow.left.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading, 10)
                }
        )
    }
}

struct MainButton: View {
    
    var imageName: String
    var colorHex: String
    var width: CGFloat = 50
    
    var body: some View {
        ZStack {
            Color(hex: colorHex)
                .frame(width: width, height: width)
                .cornerRadius(width / 2)
                .shadow(color: Color(hex: colorHex).opacity(0.3), radius: 15, x: 0, y: 15)
            Image(systemName: imageName)
                .foregroundColor(.white)
        }
    }
}

struct IconButton: View {
    
    var imageName: String
    var color: Color
    let imageWidth: CGFloat = 20
    let buttonWidth: CGFloat = 45
    
    var body: some View {
        ZStack {
            color
            Image(systemName: imageName)
                .frame(width: imageWidth, height: imageWidth)
                .foregroundColor(.white)
        }
        .frame(width: buttonWidth, height: buttonWidth)
        .cornerRadius(buttonWidth / 2)
    }
}

struct IconAndTextButton: View {
    
    var imageName: String
    var buttonText: String
    let imageWidth: CGFloat = 22
    
    var body: some View {
        ZStack {
            Color.white
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .foregroundColor(Color(hex: "778ca3"))
                    .frame(width: imageWidth, height: imageWidth)
                    .clipped()
                Spacer()
                Text(buttonText)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(Color(hex: "4b6584"))
                Spacer()
            }
            .padding(.horizontal, 15)
        }
        .frame(width: 160, height: 45)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "F4F4F4"), lineWidth: 1)
        )
    }
}

struct MockData {
    
    static let colors = [
        "e84393",
        "0984e3",
        "6c5ce7",
        "00b894"
    ].map { Color(hex: $0) }
    
    static let iconImageNames = [
        "sun.max.fill",
        "cloud.fill",
        "cloud.rain.fill",
        "cloud.snow.fill"
    ]
    
    static let iconAndTextImageNames = [
        "plus.circle.fill",
        "minus.circle.fill",
        "pencil.circle.fill"
    ]
    
    static let iconAndTextTitles = [
        "Add New",
        "Remove",
        "Rename"
    ]
}

extension Color {
    
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
