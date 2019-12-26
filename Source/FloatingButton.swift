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

public struct FloatingButton: View {

    fileprivate enum MenuType {
        case straight
        case circle
    }

    fileprivate var mainButtonView: AnyView
    fileprivate var buttons: [SubmenuButton]
    fileprivate var menuType: MenuType = .straight

    fileprivate var spacing: CGFloat = 10
    fileprivate var initialScaling: CGFloat = 1
    fileprivate var initialOffset: CGPoint = CGPoint()
    fileprivate var initialOpacity: Double = 1
    fileprivate var animation: Animation = Animation.easeInOut(duration: 0.4)
    fileprivate var delays: [Double] = []

    // straight
    fileprivate var direction: Direction = .left
    fileprivate var alignment: Alignment = .center

    // circle
    fileprivate var startAngle: Double = .pi
    fileprivate var endAngle: Double = 2 * .pi
    fileprivate var radius: Double?

    @State private var isOpen = false
    @State private var coords: [CGPoint] = []
    @State private var alignmentOffsets: [CGSize] = []
    @State private var initialPositions: [CGPoint] = [] // if there is initial offset
    @State private var sizes: [CGSize] = []
    @State private var mainButtonFrame = CGRect()

    fileprivate init(mainButtonView: AnyView, buttons: [SubmenuButton]) {
        self.mainButtonView = mainButtonView
        self.buttons = buttons
    }

    public init(mainButtonView: AnyView, buttons: [AnyView]) {
        self.mainButtonView = mainButtonView
        self.buttons = buttons.map{ SubmenuButton(buttonView: $0) }
    }

    public var body: some View {
        ZStack {
            if self.mainButtonFrame.isEmpty {
                ForEach((0..<buttons.count), id: \.self) { i in
                    self.buttons[i]
                        .position(CGPoint(x: self.mainButtonFrame.midX,
                                          y: self.mainButtonFrame.midY))
                }
            } else {
                ForEach((0..<buttons.count), id: \.self) { i in
                    self.buttons[i]
                        .position(self.buttonCoordinate(at: i))
                        .offset(self.alignmentOffsets.isEmpty ? CGSize.zero : self.alignmentOffsets[i])
                        .scaleEffect(self.isOpen ? CGFloat(1) : self.initialScaling)
                        .opacity(self.isOpen ? Double(1) : self.initialOpacity)
                        .animation(self.buttonAnimation(at: i))
                }
            }

            Button(action: {
                self.isOpen.toggle()
            }) {
                mainButtonView
            }
            .buttonStyle(PlainButtonStyle())
            .background(MenuButtonPreferenceViewSetter())
        }
        .onPreferenceChange(SubmenuButtonPreferenceKey.self) { (sizes) in
            self.sizes = sizes
            self.calculateCoords()
        }
        .onPreferenceChange(MenuButtonPreferenceKey.self) { rect in
            if let r = rect.first {
                self.mainButtonFrame = r
                self.calculateCoords()
            }
        }
        .coordinateSpace(name: "FloatingButtonSpace")
    }

    fileprivate func buttonCoordinate(at i: Int) -> CGPoint {
        return self.isOpen
        ? CGPoint(x: self.mainButtonFrame.midX + self.coords[i].x,
                  y: self.mainButtonFrame.midY + self.coords[i].y)
        : CGPoint(x: self.mainButtonFrame.midX +
            (self.initialPositions.isEmpty ? 0 : self.initialPositions[i].x),
                  y: self.mainButtonFrame.midY +
            (self.initialPositions.isEmpty ? 0 : self.initialPositions[i].y))
    }

    fileprivate func buttonAnimation(at i: Int) -> Animation {
        return self.animation.delay(self.delays.isEmpty ? Double(0) :
            (self.isOpen ? self.delays[self.delays.count - i - 1] : self.delays[i]))
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
                coord = CGPoint(x: coord.x - width - self.spacing, y: coord.y)
            case .right:
                coord = CGPoint(x: coord.x + width + self.spacing, y: coord.y)
            case .top:
                coord = CGPoint(x: coord.x, y: coord.y - height - self.spacing)
            case .bottom:
                coord = CGPoint(x: coord.x, y: coord.y + height + self.spacing)
            }
            return coord
        }

        if initialOffset.x != 0 || initialOffset.y != 0 {
            initialPositions = (0..<sizes.count).map { i -> CGPoint in
                return CGPoint(x: self.coords[i].x + self.initialOffset.x,
                               y: self.coords[i].y + self.initialOffset.y)
            }
        } else {
            initialPositions = Array(repeating: CGPoint(), count: sizes.count)
        }

        alignmentOffsets = (0..<sizes.count).map { i -> CGSize in
            switch alignment {
            case .left:
                return CGSize(width: self.sizes[i].width / 2 - mainButtonFrame.width / 2, height: 0)
            case .right:
                return CGSize(width: -self.sizes[i].width / 2 + mainButtonFrame.width / 2, height: 0)
            case .top:
                return CGSize(width: 0, height: self.sizes[i].height / 2 - mainButtonFrame.height / 2)
            case .bottom:
                return CGSize(width: 0, height: -self.sizes[i].height / 2 + mainButtonFrame.height / 2)
            case .center:
                return CGSize()
            }
        }
    }

    fileprivate func calculateCoordsCircle() {
        let count = self.buttons.count
        var radius: Double = 60
        if let r = self.radius {
            radius = r
        }
        else if let buttonWidth = sizes.first?.width {
            radius = Double((self.mainButtonFrame.width + buttonWidth) / 2 + self.spacing)
        }
        coords = (0..<count).map { i in
            let angle = (self.endAngle - self.startAngle) / Double(count - 1) * Double(i) + startAngle
            return CGPoint(x: radius*cos(angle), y: radius*sin(angle))
        }
    }

    public func copy() -> Self {
        var button = FloatingButton(mainButtonView: self.mainButtonView, buttons: self.buttons)
        button.menuType = self.menuType
        button.spacing = self.spacing
        button.initialScaling = self.initialScaling
        button.initialOffset = self.initialOffset
        button.initialOpacity = self.initialOpacity
        button.animation = self.animation
        button.delays = self.delays
        button.direction = self.direction
        button.alignment = self.alignment
        button.startAngle = self.startAngle
        button.endAngle = self.endAngle
        button.radius = self.radius
        return button
    }
}

public class DefaultFloatingButton { fileprivate init() {} }
public class StraightFloatingButton: DefaultFloatingButton {}
public class CircleFloatingButton: DefaultFloatingButton {}

public struct FloatingButtonGeneric<T : DefaultFloatingButton>: View {
    private var floatingButton: FloatingButton

    fileprivate init(floatingButton: FloatingButton) {
        self.floatingButton = floatingButton
    }

    fileprivate init() {
         fatalError("don't call this method")
    }

    fileprivate func copy() -> Self {
        var copy = FloatingButtonGeneric(floatingButton: self.floatingButton)
        copy.floatingButton = self.floatingButton.copy()
        return copy
    }

    public var body: some View {
        floatingButton
    }
}

public extension FloatingButton {

    func straight() -> FloatingButtonGeneric<StraightFloatingButton> {
        var floatingButton = self.copy()
        floatingButton.menuType = .straight
        return FloatingButtonGeneric<StraightFloatingButton>(floatingButton: floatingButton)
    }

    func circle() -> FloatingButtonGeneric<CircleFloatingButton> {
        var floatingButton = self.copy()
        floatingButton.menuType = .circle
        return FloatingButtonGeneric<CircleFloatingButton>(floatingButton: floatingButton)
    }
}

public extension FloatingButtonGeneric where T : DefaultFloatingButton {

    func spacing(_ spacing: CGFloat) -> FloatingButtonGeneric {
        var copy = self.copy()
        copy.floatingButton.spacing = spacing
        return copy
    }

    func initialScaling(_ initialScaling: CGFloat) -> FloatingButtonGeneric {
        var copy = self.copy()
        copy.floatingButton.initialScaling = initialScaling
        return copy
    }

    func initialOffset(_ initialOffset: CGPoint) -> FloatingButtonGeneric {
        var copy = self.copy()
        copy.floatingButton.initialOffset = initialOffset
        return copy
    }

    func initialOffset(x: CGFloat = 0, y: CGFloat = 0) -> FloatingButtonGeneric {
        var copy = self.copy()
        copy.floatingButton.initialOffset = CGPoint(x: x, y: y)
        return copy
    }

    func initialOpacity(_ initialOpacity: Double) -> FloatingButtonGeneric {
        var copy = self.copy()
        copy.floatingButton.initialOpacity = initialOpacity
        return copy
    }

    func animation(_ animation: Animation) -> FloatingButtonGeneric {
        var copy = self.copy()
        copy.floatingButton.animation = animation
        return copy
    }

    func delays(delayDelta: Double) -> FloatingButtonGeneric {
        var copy = self.copy()
        copy.floatingButton.delays = (0..<self.floatingButton.buttons.count).map { i in
            return delayDelta * Double(i)
        }
        return copy
    }

    func delays(_ delays: [Double]) -> FloatingButtonGeneric {
        var copy = self.copy()
        copy.floatingButton.delays = delays
        return copy
    }
}

public extension FloatingButtonGeneric where T : StraightFloatingButton {

    func direction(_ direction: Direction) -> FloatingButtonGeneric<StraightFloatingButton> {
        var copy = self.copy()
        copy.floatingButton.direction = direction
        return copy as! FloatingButtonGeneric<StraightFloatingButton>
    }

    func alignment(_ alignment: Alignment) -> FloatingButtonGeneric<StraightFloatingButton> {
        var copy = self.copy()
        copy.floatingButton.alignment = alignment
        return copy as! FloatingButtonGeneric<StraightFloatingButton>
    }
}

public extension FloatingButtonGeneric where T : CircleFloatingButton {

    func startAngle(_ startAngle: Double) -> FloatingButtonGeneric<CircleFloatingButton> {
        var copy = self.copy()
        copy.floatingButton.startAngle = startAngle
        return copy as! FloatingButtonGeneric<CircleFloatingButton>
    }

    func endAngle(_ endAngle: Double) -> FloatingButtonGeneric<CircleFloatingButton> {
        var copy = self.copy()
        copy.floatingButton.endAngle = endAngle
        return copy as! FloatingButtonGeneric<CircleFloatingButton>
    }

    func radius(_ radius: Double) -> FloatingButtonGeneric<CircleFloatingButton> {
        var copy = self.copy()
        copy.floatingButton.radius = radius
        return copy as! FloatingButtonGeneric<CircleFloatingButton>
    }
}

struct SubmenuButton: View {

    var buttonView: AnyView
    var action: ()->() = {}

    var body: some View {
        Button(action: self.action) {
            buttonView
        }
        .background(SubmenuButtonPreferenceViewSetter())
        .coordinateSpace(name: "ExampleButtonSpace")
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
