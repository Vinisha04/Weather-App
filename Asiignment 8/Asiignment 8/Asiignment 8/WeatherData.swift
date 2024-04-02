//
//  WeatherData.swift
//  Asiignment 8
//
//  Created by user240738 on 4/1/24.
//

import Foundation
struct WeatherData: Codable {
    let name: String
    let weather: [Weather]
    let main: Main
    let wind: Wind
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}

struct Wind: Codable {
    let speed: Double
}

