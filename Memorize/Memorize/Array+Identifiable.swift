//
//  Array+Identifiable.swift
//  Memorize
//
//  Created by 张艺哲 on 2020/12/5.
//

import Foundation


extension Array where Element : Identifiable {
    
    func firstIndex(matching: Element) -> Int {
        for index in 0..<self.count {
            if self[index].id == matching.id {
                return index
            }
        }
        return 0
    }
    
}
