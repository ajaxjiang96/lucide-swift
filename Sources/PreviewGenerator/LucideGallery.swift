//
//  LucideGallery.swift
//  PreviewGenerator
//
//  Debug gallery view for generating preview screenshots.
//  This lives in PreviewGenerator, not the runtime library,
//  because it exists solely to produce docs/preview.png.
//

import SwiftUI
import LucideSwift

/// A debug view that showcases all Lucide icon features.
/// Used exclusively by PreviewGenerator to render docs/preview.png.
public struct LucideGallery: View {
    public init() {}
    public var body: some View {
        VStack(spacing: 40) {
            // 1. Stroke Width Scaling (Default)
                VStack(spacing: 12) {
                    Text("Proportional Stroke (Default)").font(.headline)
                    Text("Stroke width scales with icon size (2px at 24pt)").font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 20) {
                        ForEach([16, 24, 32, 48, 64], id: \.self) { size in
                            VStack {
                                LucideIcon(.heart, size: CGFloat(size), color: .red)
                                Text("\(size)pt").font(.system(size: 8, design: .monospaced))
                            }
                        }
                    }
                }

                // 2. Absolute Stroke Width
                VStack(spacing: 12) {
                    Text("Absolute Stroke Width").font(.headline)
                    Text("Stroke width stays constant at 2px regardless of size").font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 20) {
                        ForEach([16, 24, 32, 48, 64], id: \.self) { size in
                            VStack {
                                LucideIcon(.heart, size: CGFloat(size), color: .blue, absoluteStrokeWidth: true)
                                Text("\(size)pt").font(.system(size: 8, design: .monospaced))
                            }
                        }
                    }
                }

                // 3. Custom Stroke Widths
                VStack(spacing: 12) {
                    Text("Custom Stroke Widths").font(.headline)
                    Text("Adjusting the strokeWidth parameter (at 48pt size)").font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 30) {
                        VStack {
                            LucideIcon(.heart, size: 48, color: .green, strokeWidth: 0.5)
                            Text("0.5").font(.caption2)
                        }
                        VStack {
                            LucideIcon(.heart, size: 48, color: .green, strokeWidth: 1.0)
                            Text("1.0").font(.caption2)
                        }
                        VStack {
                            LucideIcon(.heart, size: 48, color: .green, strokeWidth: 2.0)
                            Text("2.0 (Def)").font(.caption2)
                        }
                        VStack {
                            LucideIcon(.heart, size: 48, color: .green, strokeWidth: 3.0)
                            Text("3.0").font(.caption2)
                        }
                    }
                }

                // 4. Initialization Methods & Colors
                VStack(spacing: 12) {
                    Text("Initialization & Colors").font(.headline)
                    HStack(spacing: 25) {
                        VStack {
                            LucideIcon(.house, size: 32, color: .blue)
                            Text("Enum").font(.caption2)
                        }
                        VStack {
                            LucideIcon(name: "settings", size: 32, color: .orange)
                            Text("String").font(.caption2)
                        }
                        VStack {
                            LucideIcon(Lucide.star, size: 32, color: .yellow)
                            Text("Shape").font(.caption2)
                        }
                    }
                }

                // 5. Filled Icons
                VStack(spacing: 12) {
                    Text("Filled Icons").font(.headline)
                    HStack(spacing: 25) {
                        LucideIconFill(.star, size: 32, color: .yellow)
                        LucideIconFill(.heart, size: 32, color: .red)
                        LucideIconFill(.bell, size: 32, color: .blue)
                        LucideIconFill(name: "circleCheck", size: 32, color: .green)
                    }
                }

                // 6. Label Integration
                VStack(spacing: 12) {
                    Text("Label Integration").font(.headline)
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Default Label", lucide: .info)
                        Label("Lab Label", lucideLab: .broom)
                            .foregroundColor(.purple)

                        Button(action: {}) {
                            HStack {
                                LucideIcon(.trash)
                                Text("System Button")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                // 7. Lab Icons Integration (Experimental)
                VStack(spacing: 12) {
                    Text("Lucide Lab (Experimental)").font(.headline)
                    Text("Experimental icons from the lab repository").font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 20) {
                        VStack {
                            LucideLabIcon(.broom, size: 32, color: .purple)
                            Text("broom").font(.caption2)
                        }
                        VStack {
                            LucideLabIcon(.avocado, size: 32, color: .green)
                            Text("avocado").font(.caption2)
                        }
                        VStack {
                            LucideLabIcon(.cactus, size: 32, color: .green)
                            Text("cactus").font(.caption2)
                        }
                        VStack {
                            LucideLabIcon(.burger, size: 32, color: .orange)
                            Text("burger").font(.caption2)
                        }
                    }
                }

                // 8. SwiftUI Image Extension
                VStack(spacing: 12) {
                    Text("SwiftUI Image Extension").font(.headline)
                    Text("Directly use as Image for modifiers like .resizable()").font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 20) {
                        Image(lucide: .house, size: CGSize(width: 32, height: 32))
                            .foregroundColor(.blue)

                        Image(lucideFill: .heart, size: CGSize(width: 32, height: 32))
                            .foregroundColor(.red)

                        Image(lucide: .settings, size: CGSize(width: 32, height: 32))
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .frame(width: 600) // Fixed width for screenshot
            .background(Color.white)
    }
}

#if DEBUG
#Preview {
    LucideGallery()
}
#endif
