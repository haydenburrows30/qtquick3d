import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick3D

Window {
    id: window
    width: 800
    height: 800
    visible: true
    title: qsTr("3D Cube Demo")
    color: "#f0f0f0"

    View3D {
        id: view
        anchors.top: parent.top
        anchors.bottom: controlPanel.top
        anchors.left: parent.left
        anchors.right: parent.right

        // Environment for lighting
        environment: SceneEnvironment {
            clearColor: window.color
            backgroundMode: SceneEnvironment.Color
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        // Camera to view the cube
        PerspectiveCamera {
            id: camera
            z: 350
            clipFar: 2000
            clipNear: 1
            fieldOfView: 45
        }

        DirectionalLight {
            id: directionalLight
            color: Qt.rgba(1.0, 1.0, 1.0, 1.0)
            position: Qt.vector3d(0, 100, 200)
            eulerRotation.x: -30
            eulerRotation.y: -70
            ambientColor: Qt.rgba(0.3, 0.3, 0.3, 1.0)
            brightness: 1.0
        }

        PointLight {
            position: Qt.vector3d(0, 100, 100)
            color: Qt.rgba(0.9, 0.9, 1.0, 1.0)
            brightness: 1.0
            quadraticFade: 0
        }

        PrincipledMaterial {
            id: principledMaterial
            objectName: "New Material"
        }

        Node {
            id: cubeNode

            Model {
                id: cubeModel
                source: "#Cube"
                materials: principledMaterial
                eulerRotation.y: 45
                eulerRotation.x: 30
            }
            
            // update rotation
            function updateRotation() {
                eulerRotation = Qt.vector3d(cubeRotationX.value, cubeRotationY.value, cubeRotationZ.value);
            }
            
            // slider changes
            Connections {
                target: cubeRotationX
                function onValueChanged() { cubeNode.updateRotation() }
            }
            
            Connections {
                target: cubeRotationY
                function onValueChanged() { cubeNode.updateRotation() }
            }
            
            Connections {
                target: cubeRotationZ
                function onValueChanged() { cubeNode.updateRotation() }
            }

            // Animate cube's rotation
            ParallelAnimation {
                id: cubeAnimation
                running: autoRotateCheckBox.checked
                loops: Animation.Infinite
                
                // Y-axis rotation (main rotation)
                NumberAnimation {
                    target: cubeNode
                    property: "eulerRotation.y"
                    from: 0
                    to: 360
                    duration: 8000
                    easing.type: Easing.InOutQuad
                }
                
                // X-axis gentle wobble
                SequentialAnimation {
                    loops: Animation.Infinite
                    NumberAnimation {
                        target: cubeNode
                        property: "eulerRotation.x"
                        from: -5
                        to: 5
                        duration: 3000
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        target: cubeNode
                        property: "eulerRotation.x"
                        from: 5
                        to: -5
                        duration: 3000
                        easing.type: Easing.InOutSine
                    }
                }
            }

            Component.onCompleted: {
                // Initialize rotation
                updateRotation()
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            property point lastPosition
            property bool dragging: false
            
            acceptedButtons: Qt.LeftButton

            onWheel: (wheel)=> {
                const zoomSpeed = 20;
                const zoomFactor = (wheel.angleDelta.y / 120) * zoomSpeed;
                zoom(-zoomFactor);  // Negative because wheel up should zoom in
            }
            
            onPressed: {
                lastPosition = Qt.point(mouseX, mouseY)
                dragging = true
                autoRotateCheckBox.checked = false // Stop auto-rotation when manual rotation starts
            }
            
            onPositionChanged: {
                if (dragging) {
                    var deltaX = mouseX - lastPosition.x
                    var deltaY = mouseY - lastPosition.y
                    
                    // Adjust sensitivity for smoother rotation
                    var sensitivity = 0.3
                    cubeRotationY.value = (cubeRotationY.value + deltaX * sensitivity) % 360
                    cubeRotationX.value = Math.max(-90, Math.min(90, cubeRotationX.value + deltaY * sensitivity))
                    
                    lastPosition = Qt.point(mouseX, mouseY)
                }
            }
            
            onReleased: {
                dragging = false
            }
        }
    }

    // Control panel
    Rectangle {
        id: controlPanel
        width: parent.width
        height: 150
        color: "#e0e0e0"
        anchors.bottom: parent.bottom
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            
            // X-axis rotation
            RowLayout {
                Text { text: "X Rotation: " + cubeRotationX.value.toFixed(1) + "°"; width: 120 }
                Slider {
                    id: cubeRotationX
                    from: -90
                    to: 90
                    value: 0
                    Layout.fillWidth: true
                }
            }
            
            // Y-axis rotation
            RowLayout {
                Text { text: "Y Rotation: " + cubeRotationY.value.toFixed(1) + "°"; width: 120 }
                Slider {
                    id: cubeRotationY
                    from: 0
                    to: 360
                    value: 0
                    Layout.fillWidth: true
                }
            }
            
            // Camera distance slider
            RowLayout {
                Text { text: "Camera Distance: " + cameraDistanceSlider.value.toFixed(0); width: 120 }
                Slider {
                    id: cameraDistanceSlider
                    from: 100
                    to: 800
                    value: 400  // Default value matching the initial camera position
                    Layout.fillWidth: true
                    onValueChanged: {
                        camera.position = Qt.vector3d(0, 0, value)
                    }
                }
            }
            
            // Bottom controls
            RowLayout {
                CheckBox {
                    id: autoRotateCheckBox
                    text: "Auto-rotate"
                    checked: true
                    onCheckedChanged: {
                        if (checked) {
                            // Start animation
                            cubeAnimation.restart()
                        } else {
                            // Stop animation and update rotation from sliders
                            cubeAnimation.stop()
                            cubeNode.updateRotation()
                        }
                    }
                }
                
                Button {
                    text: "Reset View"
                    onClicked: {
                        cubeRotationX.value = 0
                        cubeRotationY.value = 0
                        cubeRotationZ.value = 0
                        
                        // rotation updated
                        cubeNode.updateRotation()
                    }
                }
            }
        }
    }
    
    // Z value for rotation
    QtObject {
        id: cubeRotationZ
        property real value: 0
    }


    // Function to zoom the camera
    function zoom(factor) {
        // Adjust z position to zoom in/out
        var newZ = camera.position.z + factor;
        // Limit how close/far we can zoom
        newZ = Math.max(100, Math.min(800, newZ)); 
        camera.position = Qt.vector3d(camera.position.x, camera.position.y, newZ);
        
        // Update the camera distance slider
        cameraDistanceSlider.value = newZ;
    }
}