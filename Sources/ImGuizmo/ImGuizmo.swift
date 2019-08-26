import SwiftMath
import ImGui
import CImGuizmo

extension ImGui {
    public static func beginImGuizmoFrame() {
        ImGuizmo_BeginFrame()
    }
}

public enum TransformOperation : ImGuizmoOperation.RawValue {
    case translate = 0
    case rotate = 1
    case scale = 2
    case select
}

public enum CoordinateMode : ImGuizmoMode.RawValue {
    case local
    case world
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
    
    public static func setDrawList() {
        ImGuizmo_SetDrawList()
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
    
    public static func setRect(_ rect: Rect) {
        ImGuizmo_SetRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
    }
    
    public static func setOrthographic(_ isOrthographic: Bool) {
        ImGuizmo_SetOrthographic(isOrthographic)
    }
    
    /// Render a cube with face color corresponding to face normal. Useful for debug/tests
    public static func drawCube(view: Matrix4x4f, projection: Matrix4x4f, object: Matrix4x4f) {
        withUnsafeBytes(of: view) { view in
            withUnsafeBytes(of: projection) { projection in
                withUnsafeBytes(of: object) { object in
                    ImGuizmo_DrawCube(
                        view.baseAddress!.assumingMemoryBound(to: Float.self),
                        projection.baseAddress!.assumingMemoryBound(to: Float.self),
                        object.baseAddress!.assumingMemoryBound(to: Float.self)
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
    public static func manipulate(view: Matrix4x4f, projection: Matrix4x4f, operation: TransformOperation, mode: CoordinateMode, object: inout Matrix4x4f, snap: Vector3f? = nil, localBounds: AxisAlignedBoundingBox? = nil, boundsSnap: Vector3f? = nil) -> Matrix4x4f {
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
}
