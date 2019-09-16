//
//  NetworkError.swift
//  DDRouter
//
//  Created by Rigney, Will (AU - Sydney) on 16/9/19.
//  Copyright © 2019 Will Rigney. All rights reserved.
//

import Foundation

public enum NetworkError: String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}
