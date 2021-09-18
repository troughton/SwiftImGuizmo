#ifndef CImGuizmo_h
#define CImGuizmo_h

#include "CImGui.h"

_Pragma("clang assume_nonnull begin")

CIMGUI_API void ImGuizmo_SetDrawList(ImDrawList *_Nullable drawList);

// call BeginFrame right after ImGui_XXXX_NewFrame();
CIMGUI_API void ImGuizmo_BeginFrame();

// this is necessary because when imguizmo is compiled into a dll, and imgui into another
// globals are not shared between them.
// More details at https://stackoverflow.com/questions/19373061/what-happens-to-global-and-static-variables-in-a-shared-library-when-it-is-dynam
// expose method to set imgui context
CIMGUI_API void ImGuizmo_SetImGuiContext(ImGuiContext *_Nonnull ctx);

// return true if mouse cursor is over any gizmo control (axis, plan or screen component)
CIMGUI_API bool ImGuizmo_IsOver();

// return true if mouse IsOver or if the gizmo is in moving state
CIMGUI_API bool ImGuizmo_IsUsing();

// enable/disable the gizmo. Stay in the state until next call to Enable.
// gizmo is rendered with gray half transparent color when disabled
CIMGUI_API void ImGuizmo_Enable(bool enable);

// helper functions for manualy editing translation/rotation/scale with an input float
// translation, rotation and scale float points to 3 floats each
// Angles are in degrees (more suitable for human editing)
// example:
// float matrixTranslation[3], matrixRotation[3], matrixScale[3];
// ImGuizmo::DecomposeMatrixToComponents(gizmoMatrix.m16, matrixTranslation, matrixRotation, matrixScale);
// ImGui::InputFloat3("Tr", matrixTranslation, 3);
// ImGui::InputFloat3("Rt", matrixRotation, 3);
// ImGui::InputFloat3("Sc", matrixScale, 3);
// ImGuizmo::RecomposeMatrixFromComponents(matrixTranslation, matrixRotation, matrixScale, gizmoMatrix.m16);
//
// These functions have some numerical stability issues for now. Use with caution.
CIMGUI_API void ImGuizmo_DecomposeMatrixToComponents(const float *matrix, float *translation, float *rotation, float *scale);
CIMGUI_API void ImGuizmo_RecomposeMatrixFromComponents(const float *translation, const float *rotation, const float *scale, float *matrix);

CIMGUI_API void ImGuizmo_SetRect(float x, float y, float width, float height);

CIMGUI_API void ImGuizmo_SetOrthographic(bool isOrthographic);

// Render a cube with face color corresponding to face normal. Usefull for debug/tests
CIMGUI_API void ImGuizmo_DrawCubes(const float *view, const float *projection, const float* matrices, size_t matrixCount);

CIMGUI_API void ImGuizmo_DrawGrid(const float *view, const float *projection, const float *matrix, const float gridSize);

// call it when you want a gizmo
// Needs view and projection matrices.
// matrix parameter is the source matrix (where will be gizmo be drawn) and might be transformed by the function. Return deltaMatrix is optional
// translation is applied in world space
typedef enum ImGuizmoOperation {
    ImGuizmoOperationTranslateX      = (1u << 0),
    ImGuizmoOperationTranslateY      = (1u << 1),
    ImGuizmoOperationTranslateZ      = (1u << 2),
    ImGuizmoOperationRotateX         = (1u << 3),
    ImGuizmoOperationRotateY         = (1u << 4),
    ImGuizmoOperationRotateZ         = (1u << 5),
    ImGuizmoOperationRotateScreen    = (1u << 6),
    ImGuizmoOperationScaleX          = (1u << 7),
    ImGuizmoOperationScaleY          = (1u << 8),
    ImGuizmoOperationScaleZ          = (1u << 9),
    ImGuizmoOperationBounds           = (1u << 10),
    ImGuizmoOperationScaleXU         = (1u << 11),
    ImGuizmoOperationScaleYU         = (1u << 12),
    ImGuizmoOperationScaleZU         = (1u << 13),

    ImGuizmoOperationTranslate = ImGuizmoOperationTranslateX | ImGuizmoOperationTranslateY | ImGuizmoOperationTranslateZ,
    ImGuizmoOperationRotate = ImGuizmoOperationRotateX | ImGuizmoOperationRotateY | ImGuizmoOperationRotateZ | ImGuizmoOperationRotateScreen,
    ImGuizmoOperationScale = ImGuizmoOperationScaleX | ImGuizmoOperationScaleY | ImGuizmoOperationScaleZ,
    ImGuizmoOperationScaleU = ImGuizmoOperationScaleXU | ImGuizmoOperationScaleYU | ImGuizmoOperationScaleZU, // universal
    ImGuizmoOperationUniversal = ImGuizmoOperationTranslate | ImGuizmoOperationRotate | ImGuizmoOperationScaleU
} ImGuizmoOperation;

typedef enum ImGuizmoMode
{
    ImGuizmoModeLocal,
    ImGuizmoModeWorld
} ImGuizmoMode;

CIMGUI_API void ImGuizmo_Manipulate(const float *view, const float *projection, ImGuizmoOperation operation, ImGuizmoMode mode, float *matrix, float *_Nullable deltaMatrix, const float *_Nullable snap, const float *_Nullable localBounds, const float *_Nullable boundsSnap);


CIMGUI_API void ImGuizmo_ViewManipulate(float* view, float length, ImVec2 position, ImVec2 size, ImU32 backgroundColor);

CIMGUI_API void ImGuizmo_SetID(int id);

// return true if the cursor is over the operation's gizmo
CIMGUI_API bool ImGuizmo_IsOverOperation(ImGuizmoOperation op);
CIMGUI_API void ImGuizmo_SetGizmoSizeClipSpace(float value);

// Allow axis to flip
// When true (default), the guizmo axis flip for better visibility
// When false, they always stay along the positive world/local axis
CIMGUI_API void ImGuizmo_AllowAxisFlip(bool value);

_Pragma("clang assume_nonnull end")

#endif /* CImGuizmo_h */
