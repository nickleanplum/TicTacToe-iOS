//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var matrix = Array(repeating: Array(repeating: Int(0), count: 3), count: 3)

print(matrix)
for row in 0...3-1
{
    for col in 0...3-1
    {
        matrix[row][col] = 1
    }
}
print(matrix)

var size = 2
for row in 0...3-1
{
    for col in 0...3-1
    {
        if size - row >= 0 {
            matrix[row][size - row] = 0
        }
    }
}
print(matrix)
