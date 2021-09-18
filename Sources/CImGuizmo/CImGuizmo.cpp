//
//  CImGuizmo.cpp
//
//  Created by Thomas Roughton on 18/05/17.

#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS

#include <stdio.h>
//#include <cimgui.h>

#include "CImGuizmo.h"
#include "ImGuizmo.h"

// call inside your own window and before Manipulate() in order to draw gizmo to that window.
CIMGUI_API void ImGuizmo_SetDrawList(ImDrawList *_Nullable drawList) {
    ImGuizmo::SetDrawlist(drawList);
}

// call BeginFrame right after ImGui_XXXX_NewFrame();
CIMGUI_API void ImGuizmo_BeginFrame() {
    ImGuizmo::BeginFrame();
}

CIMGUI_API void ImGuizmo_SetImGuiContext(ImGuiContext *_Nonnull ctx) {
    ImGuizmo::SetImGuiContext(ctx);
}

// return true if mouse cursor is over any gizmo control (axis, plan or screen component)
CIMGUI_API bool ImGuizmo_IsOver() {
    return ImGuizmo::IsOver();
}

// return true if mouse IsOver or if the gizmo is in moving state
CIMGUI_API bool ImGuizmo_IsUsing() {
    return ImGuizmo::IsUsing();
}

// enable/disable the gizmo. Stay in the state until next call to Enable.
// gizmo is rendered with gray half transparent color when disabled
CIMGUI_API void ImGuizmo_Enable(bool enable) {
    ImGuizmo::Enable(enable);
}


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
CIMGUI_API void ImGuizmo_DecomposeMatrixToComponents(const float *matrix, float *translation, float *rotation, float *scale) {
    ImGuizmo::DecomposeMatrixToComponents(matrix, translation, rotation, scale);
}
CIMGUI_API void ImGuizmo_RecomposeMatrixFromComponents(const float *translation, const float *rotation, const float *scale, float *matrix) {
    ImGuizmo::RecomposeMatrixFromComponents(translation, rotation, scale, matrix);
}

CIMGUI_API void ImGuizmo_SetRect(float x, float y, float width, float height) {
    ImGuizmo::SetRect(x, y, width, height);
}

// enable/disable the gizmo. Stay in the state until next call to Enable.
// gizmo is rendered with gray half transparent color when disabled
CIMGUI_API void ImGuizmo_SetOrthographic(bool isOrthographic) {
    ImGuizmo::SetOrthographic(isOrthographic);
}

// Render a cube with face color corresponding to face normal. Usefull for debug/tests
CIMGUI_API void ImGuizmo_DrawCubes(const float *view, const float *projection, const float* matrices, size_t matrixCount) {
    ImGuizmo::DrawCubes(view, projection, matrices, matrixCount);
}

// Render a cube with face color corresponding to face normal. Usefull for debug/tests
CIMGUI_API void ImGuizmo_DrawGrid(const float *view, const float *projection, const float *matrix, const float gridSize) {
    ImGuizmo::DrawGrid(view, projection, matrix, gridSize);
}

CIMGUI_API void ImGuizmo_Manipulate(const float *view, const float *projection, ImGuizmoOperation operation, ImGuizmoMode mode, float *matrix, float *deltaMatrix, const float *snap, const float *localBounds, const float *boundsSnap) {
    ImGuizmo::Manipulate(view, projection, static_cast<ImGuizmo::OPERATION>(operation), static_cast<ImGuizmo::MODE>(mode), matrix, deltaMatrix, snap, localBounds, boundsSnap);
}

CIMGUI_API void ImGuizmo_ViewManipulate(float* view, float length, ImVec2 position, ImVec2 size, ImU32 backgroundColor) {
    ImGuizmo::ViewManipulate(view, length, position, size, backgroundColor);
}

CIMGUI_API void ImGuizmo_SetID(int id) {
    ImGuizmo::SetID(id);
}

// return true if the cursor is over the operation's gizmo
CIMGUI_API bool ImGuizmo_IsOverOperation(ImGuizmoOperation op) {
    return ImGuizmo::IsOver(static_cast<ImGuizmo::OPERATION>(op));
}

CIMGUI_API void ImGuizmo_SetGizmoSizeClipSpace(float value) {
    return ImGuizmo::SetGizmoSizeClipSpace(value);
}

CIMGUI_API void ImGuizmo_AllowAxisFlip(bool value) {
    return ImGuizmo::AllowAxisFlip(value);
}
