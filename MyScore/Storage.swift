//
//  Storage.swift
//  MyScore
//
//  Created by Samuel on 2019-06-12.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import Foundation

enum Type: String {
    case team = "MyTeams"
    case leagues = "MyLeagues"
    case fixtures = "MyFixtures"
}

public class Storage {
    
    fileprivate init() { }
    
    enum Directory {
        
        case documents
        
        case caches
    }
    
    /// Returns URL constructed from specified directory
    static fileprivate func getURL(for directory: Directory) -> URL {
        var searchPathDirectory: FileManager.SearchPathDirectory
        
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }
        
        if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for specified directory!")
        }
    }
    
    static func store<T: Encodable>(_ object: T, to directory: Directory, as fileName: Type) {
        
        let url = getURL(for: directory).appendingPathComponent(fileName.rawValue, isDirectory: false)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                //print(url.path)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func retrieve<T: Decodable>(_ fileName: Type, from directory: Directory, as type: T.Type) -> T {
        let url = getURL(for: directory).appendingPathComponent(fileName.rawValue, isDirectory: false)
        
        if !FileManager.default.fileExists(atPath: url.path) {
//            _ = getURL(for: directory).appendingPathComponent(fileName.rawValue, isDirectory: false)
            fatalError("File at path \(url.path) does not exist!")
        }
        //print(url.path)
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("No data at \(url.path)!")
        }
    }
    
    /// Remove all files at specified directory
    static func clear(_ directory: Directory) {
        let url = getURL(for: directory)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Remove specified file from specified directory
    static func remove(_ fileName: Type, from directory: Directory) {
        let url = getURL(for: directory).appendingPathComponent(fileName.rawValue, isDirectory: false)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    /// Returns BOOL indicating whether file exists at specified directory with specified file name
    static func fileExists(_ fileName: Type, in directory: Directory) -> Bool {
        
        let url = getURL(for: directory).appendingPathComponent(fileName.rawValue, isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path)
    }
}
