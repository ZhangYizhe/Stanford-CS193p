//
//  Array+Only.swift
//  Memorize
//
//  Created by 张艺哲 on 2020/12/6.
//

import Foundation

extension Array {
    var only : Element? {
        count == 1 ? first : nil
    }
}
