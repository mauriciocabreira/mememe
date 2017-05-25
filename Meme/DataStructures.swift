//
//  MemeMeStruct.swift
//  Meme
//
//  Created by Mauricio A Cabreira on 24/05/17.
//  Copyright © 2017 Mauricio A Cabreira. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    var topText: String!
    var bottomText: String!
    var originalImage: UIImage!
    var memedImage: UIImage
}

enum ImageSource: Int {
    case camera = 0, photoLibrary
}

enum Field: Int {
    case topField = 0, bottomField
}
