//
//  Utility.cpp
//  WantToCryEngine
//
//  Created by Alex on 2023-03-01.
//

#include "Utility.hpp"

GLKVector3 rotToDir(const GLKVector3& rot){
    GLKMatrix3 rotor = GLKMatrix3MakeYRotation(rot.y);
    rotor = GLKMatrix3RotateX(rotor, rot.x);
    rotor = GLKMatrix3RotateZ(rotor, rot.z);
    
    return GLKMatrix3MultiplyVector3(rotor, GLKVector3{0, 0, 1});
}
