import SubstrateMath
import ImGui
import CImGuizmo

public enum CoordinateMode : ImGuizmoMode.RawValue {
    case local
    case world
}


public struct TransformOperation : OptionSet {
    public let rawValue: ImGuizmoOperation.RawValue
    
    public init(rawValue: ImGuizmoOperation.RawValue) {
        self.rawValue = rawValue
    }
    
    public static var translateX: TransformOperation { TransformOperation(rawValue: 1 << 0) }
    public static var translateY: TransformOperation { TransformOperation(rawValue: 1 << 1) }
    public static var translateZ: TransformOperation { TransformOperation(rawValue: 1 << 2) }
    public static var rotateX: TransformOperation { TransformOperation(rawValue: 1 << 3) }
    public static var rotateY: TransformOperation { TransformOperation(rawValue: 1 << 4) }
    public static var rotateZ: TransformOperation { TransformOperation(rawValue: 1 << 5) }
    public static var rotateScreen: TransformOperation { TransformOperation(rawValue: 1 << 6) }
    public static var scaleX: TransformOperation { TransformOperation(rawValue: 1 << 7) }
    public static var scaleY: TransformOperation { TransformOperation(rawValue: 1 << 8) }
    public static var scaleZ: TransformOperation { TransformOperation(rawValue: 1 << 9) }
    public static var bounds: TransformOperation { TransformOperation(rawValue: 1 << 10) }
    public static var scaleXUniversal: TransformOperation { TransformOperation(rawValue: 1 << 11) }
    public static var scaleYUniversal: TransformOperation { TransformOperation(rawValue: 1 << 12) }
    public static var scaleZUniversal: TransformOperation { TransformOperation(rawValue: 1 << 13) }
    
    public static var translate: TransformOperation { return [.translateX, .translateY, .translateZ] }
    public static var rotate: TransformOperation { return [.rotateX, .rotateY, .rotateZ, .rotateScreen] }
    public static var scale: TransformOperation { return [.scaleX, .scaleY, .scaleZ] }
    public static var scaleUniversal: TransformOperation { return [.scaleXUniversal, .scaleYUniversal, .scaleZUniversal] }
    public static var universal: TransformOperation { return [.translate, .rotate, .scaleUniversal] }
}

fileprivate func withUnsafeOptionalBytes<T>(of value: T?, perform: (UnsafeRawBufferPointer) -> Void) {
    if let val = value {
        withUnsafeBytes(of: val) {
            perform($0)
        }
    } else {
        perform(UnsafeRawBufferPointer(start: nil, count: 0))
    }
}

public enum ImGuizmo {
    
    public static func setDrawList(_ drawList: UnsafeMutablePointer<ImDrawList>? = nil) {
        ImGuizmo_SetDrawList(drawList)
    }
    
    public static func beginFrame() {
        ImGuizmo_BeginFrame()
    }
    
    public static func setImGuiContext(_ context: UnsafeMutablePointer<ImGuiContext>) {
        ImGuizmo_SetImGuiContext(context)
    }
    
    /// return true if mouse cursor is over any gizmo control (axis, plan or screen component)
    public static var cursorIsOverGizmo : Bool {
        return ImGuizmo_IsOver()
    }
    
    /// return true if cursorIsOverGizmo or if the gizmo is in moving state
    public static var isActive : Bool {
        return ImGuizmo_IsUsing()
    }
    
    public static func setEnabled(_ enabled: Bool) {
        ImGuizmo_Enable(enabled)
    }
    
    public static func setRect(_ rect: Rect<Float>) {
        ImGuizmo_SetRect(rect.origin.x, rect.origin.y, rect.size.x, rect.size.y)
    }
    
    public static func setOrthographic(_ isOrthographic: Bool) {
        ImGuizmo_SetOrthographic(isOrthographic)
    }
    
    /// Render a cube with face color corresponding to face normal. Useful for debug/tests
    public static func drawCubes(view: Matrix4x4f, projection: Matrix4x4f, cubeTransforms: [Matrix4x4f]) {
        let objectCount = cubeTransforms.count
        withUnsafeBytes(of: view) { view in
            withUnsafeBytes(of: projection) { projection in
                cubeTransforms.withUnsafeBytes { objects in
                    ImGuizmo_DrawCubes(
                        view.baseAddress!.assumingMemoryBound(to: Float.self),
                        projection.baseAddress!.assumingMemoryBound(to: Float.self),
                        objects.baseAddress!.assumingMemoryBound(to: Float.self),
                        objectCount
                    )
                }
            }
        }
    }
    
    /// Render a cube with face color corresponding to face normal. Useful for debug/tests
    public static func drawGrid(view: Matrix4x4f, projection: Matrix4x4f, object: Matrix4x4f, gridSize: Float) {
        withUnsafeBytes(of: view) { view in
            withUnsafeBytes(of: projection) { projection in
                withUnsafeBytes(of: object) { object in
                    ImGuizmo_DrawGrid(
                        view.baseAddress!.assumingMemoryBound(to: Float.self),
                        projection.baseAddress!.assumingMemoryBound(to: Float.self),
                        object.baseAddress!.assumingMemoryBound(to: Float.self),
                        gridSize
                    )
                }
            }
        }
    }
    
    /// - returns: the delta matrix.
    @discardableResult
    public static func manipulate(view: Matrix4x4f, projection: Matrix4x4f, operation: TransformOperation, mode: CoordinateMode, object: inout Matrix4x4f, snap: Vector3f? = nil, localBounds: AxisAlignedBoundingBox<Float>? = nil, boundsSnap: Vector3f? = nil) -> Matrix4x4f {
        let mode = operation == .scale ? .local : mode
        
        var deltaMatrix = Matrix4x4f()
        
        withUnsafeBytes(of: view) { (view: UnsafeRawBufferPointer) -> Void in
            withUnsafeBytes(of: projection) { (projection: UnsafeRawBufferPointer) -> Void in
                withUnsafeMutableBytes(of: &object) { (object: UnsafeMutableRawBufferPointer) -> Void in
                    withUnsafeMutableBytes(of: &deltaMatrix) { (deltaMatrix: UnsafeMutableRawBufferPointer) -> Void in
                        withUnsafeOptionalBytes(of: snap) { snap -> Void in
                            withUnsafeOptionalBytes(of: localBounds) { localBounds -> Void in
                                withUnsafeOptionalBytes(of: boundsSnap) { boundsSnap -> Void in
                                    ImGuizmo_Manipulate(
                                        view.baseAddress!.assumingMemoryBound(to: Float.self),
                                        projection.baseAddress!.assumingMemoryBound(to: Float.self),
                                        ImGuizmoOperation(operation.rawValue),
                                        ImGuizmoMode(mode.rawValue),
                                        object.baseAddress!.assumingMemoryBound(to: Float.self),
                                        deltaMatrix.baseAddress!.assumingMemoryBound(to: Float.self),
                                        snap.baseAddress?.assumingMemoryBound(to: Float.self),
                                        localBounds.baseAddress?.assumingMemoryBound(to: Float.self),
                                        boundsSnap.baseAddress?.assumingMemoryBound(to: Float.self)
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return deltaMatrix
    }
    
    public static func manipulateView(view: inout Matrix4x4f, pivotDistance: Float, position: SIMD2<Float>, size: SIMD2<Float>, backgroundColor: UInt32) {
        withUnsafeMutableBytes(of: &view) { (view: UnsafeMutableRawBufferPointer) -> Void in
            ImGuizmo_ViewManipulate(
                view.baseAddress!.assumingMemoryBound(to: Float.self),
                pivotDistance,
                ImVec2(x: position.x, y: position.y),
                ImVec2(x: size.x, y: size.y),
                backgroundColor
            )
        }
    }
    
    public static func setID(_ id: Int32) {
        ImGuizmo_SetID(id)
    }
    
    public static func isOver(for operation: TransformOperation) -> Bool{
        return ImGuizmo_IsOverOperation(ImGuizmoOperation(operation.rawValue))
    }
    
    public static func setGizmoSizeClipSpace(to value: Float){
        return ImGuizmo_SetGizmoSizeClipSpace(value)
    }
    
    /// Allow axis to flip
    /// When true (default), the guizmo axis flip for better visibility
    /// When false, they always stay along the positive world/local axis
    public static func setAxisFlipsAllowed(_ axisFlipsAllowed: Bool) {
        ImGuizmo_AllowAxisFlip(axisFlipsAllowed)
    }
}
