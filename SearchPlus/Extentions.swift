//
//  Extentions.swift
//  SearchPlus
//
//  Created by McCoy Zhu on 11/21/20.
//

extension Array {
    func count(where predicate: (Element) -> Bool) -> Int {
        return reduce(0, {$0 + (predicate($1) ? 1 : 0)})
    }
}
