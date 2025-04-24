// swift-tools-version: 5.9

// Copyright 2025 Anton Ustinoff<a.a.ustinoff@gmail.com>. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "contactos_ios",
  platforms: [
    .iOS("12.0"),
    .macOS("10.14"),
  ],
  products: [
    .library(name: "contactos-ios", targets: ["contactos_ios"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "contactos_ios",
      dependencies: [],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
