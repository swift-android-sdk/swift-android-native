//
//  Error.swift
//  swift-android-native
//
//  Created by Alsey Coleman Miller on 3/21/26.
//

public enum AndroidContextError: Error {
    
    case classNotFound(String)
    case methodNotFound(String)
    case nullValueForMethod(String)
    case invalidJavaSignature(String)
}
