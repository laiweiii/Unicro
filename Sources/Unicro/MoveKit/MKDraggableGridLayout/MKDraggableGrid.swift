import SwiftUI


public struct MKDraggableGridConfiguration {

    // Appearance / layout
    public var itemSize: CGFloat
    public var columns: Int
    public var spacing: CGFloat

    // Drag appearance
    public var isDraggingScale: CGFloat
    public var isDraggingShadowColor: Color
    public var isDraggingShadowRadius: CGFloat

    // MARK: - Standard configuration
    public static let standard = MKDraggableGridConfiguration(
        itemSize: 100,
        columns: 3,
        spacing: 10,
        isDraggingScale: 1.1,
        isDraggingShadowColor: Color.black.opacity(0.3),
        isDraggingShadowRadius: 8
    )

    // MARK: - Public override initializer
    public init(
        itemSize: CGFloat? = nil,
        columns: Int? = nil,
        spacing: CGFloat? = nil,
        isDraggingScale: CGFloat? = nil,
        isDraggingShadowColor: Color? = nil,
        isDraggingShadowRadius: CGFloat? = nil
    ) {
        let standard = MKDraggableGridConfiguration.standard

        self.itemSize = itemSize ?? standard.itemSize
        self.columns = columns ?? standard.columns
        self.spacing = spacing ?? standard.spacing
        self.isDraggingScale = isDraggingScale ?? standard.isDraggingScale
        self.isDraggingShadowColor = isDraggingShadowColor ?? standard.isDraggingShadowColor
        self.isDraggingShadowRadius = isDraggingShadowRadius ?? standard.isDraggingShadowRadius
    }

    // MARK: - Internal full initializer
    private init(
        itemSize: CGFloat,
        columns: Int,
        spacing: CGFloat,
        isDraggingScale: CGFloat,
        isDraggingShadowColor: Color,
        isDraggingShadowRadius: CGFloat
    ) {
        self.itemSize = itemSize
        self.columns = columns
        self.spacing = spacing
        self.isDraggingScale = isDraggingScale
        self.isDraggingShadowColor = isDraggingShadowColor
        self.isDraggingShadowRadius = isDraggingShadowRadius
    }
}



public struct MKDraggableGrid<Content: View>: View {
    @State private var items :[Int]
    @State private var draggingItem: Int? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var dragStartPosition: CGPoint = .zero
    @State private var itemPositions: [Int: CGPoint] = [:]
    public var gridItemContent: (Int) -> Content
    public let config: MKDraggableGridConfiguration

    public init(
        itemCount: Int,
        config: MKDraggableGridConfiguration = .standard,
        @ViewBuilder gridItemContent: @escaping (Int) -> Content
    ) {
        self._items = State(initialValue: Array(0..<max(0, itemCount)))
        self.config = config
        self.gridItemContent = gridItemContent
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(items, id: \.self) { item in
                    let currentIndex = items.firstIndex(of: item)!
                    let isDragging = draggingItem == item
                    
                    gridItemContent(item)
                    .frame(width: config.itemSize, height: config.itemSize, alignment: .center)
                    .scaleEffect(isDragging ? config.isDraggingScale : 1.0)
                    .shadow(color: isDragging ? config.isDraggingShadowColor : .clear, radius: config.isDraggingShadowRadius)
                    .position(getItemPosition(for: item, in: geometry))
                    .zIndex(isDragging ? 1000 : Double(currentIndex))
                    .animation(
                        isDragging ? nil : .spring(response: 0.4, dampingFraction: 0.8),
                        value: items
                    )
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { value in
                                handleDragChanged(item: item, value: value, geometry: geometry)
                            }
                            .onEnded { value in
                                handleDragEnded(item: item, value: value, geometry: geometry)
                            }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                initializePositions(in: geometry)
            }
        }
        .padding()
    }
    
    // MARK: - position calculation
    private func getItemPosition(for item: Int, in geometry: GeometryProxy) -> CGPoint {
        if draggingItem == item {
            // dragging element：start position + finger drag offset
            return CGPoint(
                x: dragStartPosition.x + dragOffset.width,
                y: dragStartPosition.y + dragOffset.height
            )
        } else {
            // non-dragging element: use cached position or recalculate the position
            return itemPositions[item] ?? getGridPosition(for: item, in: geometry)
        }
    }
    
    private func getGridPosition(for item: Int, in geometry: GeometryProxy) -> CGPoint {
        guard let index = items.firstIndex(of: item) else { return .zero }
        
        let row = index / Int(config.columns)
        let col = index % Int(config.columns)
        
        let totalWidth = CGFloat(config.columns) * config.itemSize + CGFloat(config.columns - 1) * config.spacing
        let startX = (geometry.size.width - totalWidth) / 2 + config.itemSize / 2
        let startY = config.itemSize / 2
        
        return CGPoint(
            x: startX + CGFloat(col) * (config.itemSize + config.spacing),
            y: startY + CGFloat(row) * (config.itemSize + config.spacing)
        )
    }
    
    // MARK: - drag handling
    private func handleDragChanged(item: Int, value: DragGesture.Value, geometry: GeometryProxy) {
        if draggingItem == nil {
            draggingItem = item
            dragStartPosition = getGridPosition(for: item, in: geometry)
            updateAllPositions(in: geometry)
        }
        
        // update the dragoffset
        dragOffset = value.translation
        
        // check if reorder need
        checkForReordering(draggedItem: item, geometry: geometry)
    }
    
    private func handleDragEnded(item: Int, value: DragGesture.Value, geometry: GeometryProxy) {
        // reset drag status
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            dragOffset = .zero
            draggingItem = nil
            dragStartPosition = .zero
            updateAllPositions(in: geometry)
        }
    }
    
    // MARK: - check reorder
    private func checkForReordering(draggedItem: Int, geometry: GeometryProxy) {
        guard let currentIndex = items.firstIndex(of: draggedItem) else { return }
        
        let currentDragPosition = CGPoint(
            x: dragStartPosition.x + dragOffset.width,
            y: dragStartPosition.y + dragOffset.height
        )
        
        // get the index of the dragged item
        if let targetIndex = getGridIndex(at: currentDragPosition, in: geometry),
           targetIndex != currentIndex,
           targetIndex >= 0,
           targetIndex < items.count {

            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                let item = items.remove(at: currentIndex)
                items.insert(item, at: targetIndex)
                updateAllPositions(in: geometry)
            }
        }
    }
    
    private func getGridIndex(at point: CGPoint, in geometry: GeometryProxy) -> Int? {
        let totalWidth = CGFloat(config.columns) * config.itemSize + CGFloat(config.columns - 1) * config.spacing
        let startX = (geometry.size.width - totalWidth) / 2
        let startY = 0.0
        
        let relativeX = point.x - startX
        let relativeY = point.y - startY
        
        if relativeX < 0 || relativeY < 0 { return nil }
        
        let col = Int(relativeX / (config.itemSize + config.spacing))
        let row = Int(relativeY / (config.itemSize + config.spacing))
        
        if col >= Int(config.columns) || col < 0 || row < 0 { return nil }
        
        let index = row * Int(config.columns) + col
        return index < items.count ? index : nil
    }
    
    // MARK: - position management
    private func initializePositions(in geometry: GeometryProxy) {
        for item in items {
            itemPositions[item] = getGridPosition(for: item, in: geometry)
        }
    }
    
    private func updateAllPositions(in geometry: GeometryProxy) {
        for item in items {
            if item != draggingItem {
                itemPositions[item] = getGridPosition(for: item, in: geometry)
            }
        }
    }
}

struct SimpleView: View {
    @State private var userSelectedColors: [Color] = [.red, .green, .blue, .orange, .purple,.black,.green, .blue, .orange]
    var body: some View {
        MKDraggableGrid(itemCount: userSelectedColors.count) { item in
            Circle()
                .fill(userSelectedColors[item % userSelectedColors.count])
                .frame(width: 60, height: 60)
                .overlay(Text("\(item)").foregroundColor(.white))
        }
    }
}


#Preview {
    SimpleView()
}
