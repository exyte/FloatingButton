//
//  FloatingButton.swift
//  FloatingButton
//
//  Created by Alisa Mylnikova on 27/11/2019.
//  Copyright © 2019 Exyte. All rights reserved.
//

import SwiftUI

public enum Direction {
    case left, right, top, bottom
}

public enum Alignment {
    case left, right, top, bottom, center
}

public struct FloatingButton<MainView, ButtonView>: View where MainView: View, ButtonView: View {

    fileprivate enum MenuType {
        case straight
        case circle
    }
    
    fileprivate var mainButtonView: MainView
    fileprivate var buttons: [SubmenuButton<ButtonView>]
    
    fileprivate var menuType: MenuType = .straight
    fileprivate var spacing: CGFloat = 10
    fileprivate var initialScaling: CGFloat = 1
    fileprivate var initialOffset: CGPoint = CGPoint()
    fileprivate var initialOpacity: Double = 1
    fileprivate var animation: Animation = .easeInOut(duration: 0.4)
    fileprivate var delays: [Double] = []
    
    // straight
    fileprivate var direction: Direction = .left
    fileprivate var alignment: Alignment = .center
    
    // circle
    fileprivate var startAngle: Double = .pi
    fileprivate var endAngle: Double = 2 * .pi
    fileprivate var radius: Double?
    
    @State private var privateIsOpen: Bool = false
    var isOpenBinding: Binding<Bool>?
    var isOpen: Bool {
        get { isOpenBinding?.wrappedValue ?? privateIsOpen }
    }
    
    @State private var coords: [CGPoint] = []
    @State private var alignmentOffsets: [CGSize] = []
    @State private var initialPositions: [CGPoint] = [] // if there is initial offset
    @State private var sizes: [CGSize] = []
    @State private var mainButtonFrame = CGRect()
    
    private init(mainButtonView: MainView, buttons: [SubmenuButton<ButtonView>], isOpenBinding: Binding<Bool>?) {
        self.mainButtonView = mainButtonView
        self.buttons = buttons
        self.isOpenBinding = isOpenBinding
    }
    
    public init(mainButtonView: MainView, buttons: [ButtonView]) {
        self.mainButtonView = mainButtonView
        self.buttons = buttons.map { SubmenuButton(buttonView: $0) }
    }
    
    public init(mainButtonView: MainView, buttons: [ButtonView], isOpen: Binding<Bool>) {
        self.mainButtonView = mainButtonView
        self.buttons = buttons.map { SubmenuButton(buttonView: $0) }
        self.isOpenBinding = isOpen
    }
    
    public var body: some View {
        ZStack {
            if mainButtonFrame.isEmpty {
                ForEach((0..<buttons.count), id: \.self) { i in
                    buttons[i]
                        .position(CGPoint(x: mainButtonFrame.midX,
                                          y: mainButtonFrame.midY))
                }
            } else {
                ForEach((0..<buttons.count), id: \.self) { i in
                    buttons[i]
                        .background(SubmenuButtonPreferenceViewSetter())
                        .position(buttonCoordinate(at: i))
                        .offset(alignmentOffsets.isEmpty ? .zero : alignmentOffsets[i])
                        .scaleEffect(isOpen ? 1 : initialScaling)
                        .opacity(isOpen ? 1 : initialOpacity)
                        .animation(buttonAnimation(at: i))
                }
            }
            
            MainButtonViewInternal(isOpen: isOpenBinding ?? $privateIsOpen, mainButtonView: mainButtonView)
                .buttonStyle(PlainButtonStyle())
                .background(MenuButtonPreferenceViewSetter())
                .coordinateSpace(name: "ExampleButtonSpace")
        }
        .onPreferenceChange(SubmenuButtonPreferenceKey.self) { (sizes) in
            self.sizes = sizes
            calculateCoords()
        }
        .onPreferenceChange(MenuButtonPreferenceKey.self) { rect in
            if let r = rect.first {
                mainButtonFrame = r
                calculateCoords()
            }
        }
        .coordinateSpace(name: "FloatingButtonSpace")
    }
    
    fileprivate func buttonCoordinate(at i: Int) -> CGPoint {
        return isOpen
        ? CGPoint(x: mainButtonFrame.midX + coords[i].x,
                  y: mainButtonFrame.midY + coords[i].y)
        : CGPoint(x: mainButtonFrame.midX +
                  (initialPositions.isEmpty ? 0 : initialPositions[i].x),
                  y: mainButtonFrame.midY +
                  (initialPositions.isEmpty ? 0 : initialPositions[i].y))
    }
    
    fileprivate func buttonAnimation(at i: Int) -> Animation {
        return animation.delay(delays.isEmpty ? Double(0) :
                                (isOpen ? delays[delays.count - i - 1] : delays[i]))
    }
    
    fileprivate func calculateCoords() {
        switch menuType {
        case .straight:
            calculateCoordsStraight()
        case .circle:
            calculateCoordsCircle()
        }
    }
    
    fileprivate func calculateCoordsStraight() {
        guard sizes.count > 0, !mainButtonFrame.isEmpty else {
            return
        }
        
        var allSizes = [mainButtonFrame.size]
        allSizes.append(contentsOf: sizes)
        
        var coord = CGPoint.zero
        coords = (0..<sizes.count).map { i -> CGPoint in
            let width = allSizes[i].width / 2 + allSizes[i+1].width / 2
            let height = allSizes[i].height / 2 + allSizes[i+1].height / 2
            switch direction {
            case .left:
                coord = CGPoint(x: coord.x - width - spacing, y: coord.y)
            case .right:
                coord = CGPoint(x: coord.x + width + spacing, y: coord.y)
            case .top:
                coord = CGPoint(x: coord.x, y: coord.y - height - spacing)
            case .bottom:
                coord = CGPoint(x: coord.x, y: coord.y + height + spacing)
            }
            return coord
        }
        
        if initialOffset.x != 0 || initialOffset.y != 0 {
            initialPositions = (0..<sizes.count).map { i -> CGPoint in
                return CGPoint(x: coords[i].x + initialOffset.x,
                               y: coords[i].y + initialOffset.y)
            }
        } else {
            initialPositions = Array(repeating: .zero, count: sizes.count)
        }
        
        alignmentOffsets = (0..<sizes.count).map { i -> CGSize in
            switch alignment {
            case .left:
                return CGSize(width: sizes[i].width / 2 - mainButtonFrame.width / 2, height: 0)
            case .right:
                return CGSize(width: -sizes[i].width / 2 + mainButtonFrame.width / 2, height: 0)
            case .top:
                return CGSize(width: 0, height: sizes[i].height / 2 - mainButtonFrame.height / 2)
            case .bottom:
                return CGSize(width: 0, height: -sizes[i].height / 2 + mainButtonFrame.height / 2)
            case .center:
                return CGSize()
            }
        }
    }
    
    fileprivate func calculateCoordsCircle() {
        let count = buttons.count
        var radius: Double = 60
        if let r = self.radius {
            radius = r
        } else if let buttonWidth = sizes.first?.width {
            radius = Double((mainButtonFrame.width + buttonWidth) / 2 + spacing)
        }
        coords = (0..<count).map { i in
            let angle = (endAngle - startAngle) / Double(count - 1) * Double(i) + startAngle
            return CGPoint(x: radius*cos(angle), y: radius*sin(angle))
        }
    }
}

public class DefaultFloatingButton { fileprivate init() {} }
public class StraightFloatingButton: DefaultFloatingButton {}
public class CircleFloatingButton: DefaultFloatingButton {}

public struct FloatingButtonGeneric<T: DefaultFloatingButton, MainView: View, ButtonView: View>: View {
    private var floatingButton: FloatingButton<MainView, ButtonView>
    
    fileprivate init(floatingButton: FloatingButton<MainView, ButtonView>) {
        self.floatingButton = floatingButton
    }
    
    fileprivate init() {
        fatalError("don't call this method")
    }
    
    public var body: some View {
        floatingButton
    }
}

public extension FloatingButton {
    
    func straight() -> FloatingButtonGeneric<StraightFloatingButton, MainView, ButtonView> {
        var copy = self
        copy.menuType = .straight
        return FloatingButtonGeneric(floatingButton: copy)
    }
    
    func circle() -> FloatingButtonGeneric<CircleFloatingButton, MainView, ButtonView> {
        var copy = self
        copy.menuType = .circle
        return FloatingButtonGeneric(floatingButton: copy)
    }
}

public extension FloatingButtonGeneric where T : DefaultFloatingButton {
    
    func spacing(_ spacing: CGFloat) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.spacing = spacing
        return copy
    }
    
    func initialScaling(_ initialScaling: CGFloat) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.initialScaling = initialScaling
        return copy
    }
    
    func initialOffset(_ initialOffset: CGPoint) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.initialOffset = initialOffset
        return copy
    }
    
    func initialOffset(x: CGFloat = 0, y: CGFloat = 0) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.initialOffset = CGPoint(x: x, y: y)
        return copy
    }
    
    func initialOpacity(_ initialOpacity: Double) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.initialOpacity = initialOpacity
        return copy
    }
    
    func animation(_ animation: Animation) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.animation = animation
        return copy
    }
    
    func delays(delayDelta: Double) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.delays = (0..<self.floatingButton.buttons.count).map { i in
            return delayDelta * Double(i)
        }
        return copy
    }
    
    func delays(_ delays: [Double]) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.delays = delays
        return copy
    }
}

public extension FloatingButtonGeneric where T: StraightFloatingButton {
    
    func direction(_ direction: Direction) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.direction = direction
        return copy
    }
    
    func alignment(_ alignment: Alignment) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.alignment = alignment
        return copy
    }
}

public extension FloatingButtonGeneric where T: CircleFloatingButton {
    
    func startAngle(_ startAngle: Double) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.startAngle = startAngle
        return copy
    }
    
    func endAngle(_ endAngle: Double) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.endAngle = endAngle
        return copy
    }
    
    func radius(_ radius: Double) -> FloatingButtonGeneric {
        var copy = self
        copy.floatingButton.radius = radius
        return copy
    }
}

struct SubmenuButton<ButtonView: View>: View {
    
    var buttonView: ButtonView
    var action: () -> Void = { }
    
    var body: some View {
        Button(action: { action() }) {
            buttonView
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SubmenuButtonPreferenceKey: PreferenceKey {
    typealias Value = [CGSize]
    
    static var defaultValue: Value = []
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

struct SubmenuButtonPreferenceViewSetter: View {
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(key: SubmenuButtonPreferenceKey.self,
                            value: [geometry.frame(in: .named("ExampleButtonSpace")).size])
        }
    }
}

struct MenuButtonPreferenceKey: PreferenceKey {
    typealias Value = [CGRect]
    
    static var defaultValue: Value = []
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

struct MenuButtonPreferenceViewSetter: View {
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(key: MenuButtonPreferenceKey.self,
                            value: [geometry.frame(in: .named("FloatingButtonSpace"))])
        }
    }
}

private struct MainButtonViewInternal<MainView: View>: View {
    
    @Binding public var isOpen: Bool
    fileprivate var mainButtonView: MainView
    
    public var body: some View {
        Button(action: { isOpen.toggle() }) {
            mainButtonView
        }
    }
}
