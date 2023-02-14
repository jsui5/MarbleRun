//
//  WavefrontLoader.hpp
//  greencube
//
//  Created by Max Korchagov on 2023-02-09.
//

#ifndef WavefrontLoader_hpp
#define WavefrontLoader_hpp

#include <stdio.h>
#include <cstdint>
#include <vector>
#include <string>
#include <fstream>
#include <iostream>
#include <sstream>
#include <stdlib.h>
#include "GeometryObject.h"

/// <summary>
/// For importing .obj file. Must be triangulated - this importer CANNOT handle ngons.
/// </summary>
class WavefrontLoader
{
public:
    static GeometryObject ReadFile(const std::string& path);
};

#endif /* WavefrontLoader_hpp */
