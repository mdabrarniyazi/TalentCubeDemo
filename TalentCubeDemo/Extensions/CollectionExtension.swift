//
//  CollectionExtension.swift
//  TalentCubeDemo
//
//  Created by Abrar Niyazi on 03/12/17.
//  Copyright © 2017 Abrar Niyazi. All rights reserved.
//

import Foundation

extension Collection {
    
    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }
    
}
