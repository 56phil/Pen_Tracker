import Foundation
import SwiftData
import SwiftUI

struct DashboardView: View {
 @Query(sort: \Pen.brand) private var pens: [Pen]
 @Query(sort: \Ink.brand) private var inks: [Ink]
 @Query(sort: \Paper.brand) private var papers: [Paper]
 @Query(sort: \Swatch.dateTested, order: .reverse) private var swatches: [Swatch]

 private let columns = [GridItem(.adaptive(minimum: 240), spacing: 16)]

 private var totalVolumeML: Double {
  inks.reduce(0) { $0 + ($1.volumeML ?? 0) * Double($1.quantity) }
 }

 private var trackedValue: Decimal {
  pens.reduce(0) { $0 + ($1.price ?? 0) }
   + inks.reduce(0) { $0 + ($1.price ?? 0) * Decimal($1.quantity) }
   + papers.reduce(0) { $0 + ($1.price ?? 0) * Decimal($1.quantity) }
 }

 private var inkedPens: [Pen] {
  pens.filter { $0.currentInking != nil }
 }

 var body: some View {
  ScrollView {
   VStack(alignment: .leading, spacing: 20) {
    LazyVGrid(columns: columns, spacing: 12) {
     StatCard(
      label: "Pens", value: "\(pens.count)", systemImage: "pencil",
      tint: .blue)
     StatCard(
      label: "Inks", value: "\(inks.count)", systemImage: "drop",
      tint: .purple)
     StatCard(
      label: "Paper", value: "\(papers.count)", systemImage: "doc.plaintext",
      tint: .teal)
     StatCard(
      label: "Swatches", value: "\(swatches.count)", systemImage: "paintpalette",
      tint: .orange)
     StatCard(
      label: "Ink on Hand", value: formattedVolume, systemImage: "cylinder.split.1x2",
      tint: .indigo)
     StatCard(
      label: "Tracked Value", value: trackedValue.priceText,
      systemImage: "dollarsign.circle", tint: .green)
    }

    if !inkedPens.isEmpty {
     VStack(alignment: .leading, spacing: 10) {
      Text("Currently Inked")
       .font(.headline)
      LazyVGrid(columns: columns, spacing: 12) {
       ForEach(inkedPens) { pen in
        if let inking = pen.currentInking, let ink = inking.ink {
         InkedPenCard(pen: pen, inking: inking, ink: ink)
        }
       }
      }
     }
    }
   }
   .padding()
  }
  .navigationTitle("Dashboard")
 }

 private var formattedVolume: String {
  let formatter = MeasurementFormatter()
  formatter.unitOptions = .providedUnit
  return formatter.string(from: Measurement(value: totalVolumeML, unit: UnitVolume.milliliters))
 }
}

private struct StatCard: View {
 let label: String
 let value: String
 let systemImage: String
 let tint: Color

 var body: some View {
  HStack(spacing: 10) {
   Image(systemName: systemImage)
    .font(.title3)
    .foregroundStyle(tint)
    .frame(width: 32)
   VStack(alignment: .leading, spacing: 2) {
    Text(value)
     .font(.title3)
     .fontWeight(.semibold)
     .lineLimit(1)
     .minimumScaleFactor(0.6)
    Text(label)
     .font(.caption)
     .foregroundStyle(.secondary)
   }
   Spacer(minLength: 0)
  }
  .padding(12)
  .background(.quaternary.opacity(0.3))
  .clipShape(RoundedRectangle(cornerRadius: 10))
 }
}

private struct InkedPenCard: View {
 let pen: Pen
 let inking: Inking
 let ink: Ink

 var body: some View {
  VStack(alignment: .leading, spacing: 8) {
   HStack {
    ColorSwatchView(hex: ink.colorHex, size: 20)
    VStack(alignment: .leading) {
     Text("\(pen.brand) \(pen.model)").fontWeight(.medium)
     Text("\(ink.brand) \(ink.colorName)")
      .font(.caption)
      .foregroundStyle(.secondary)
    }
    Spacer()
   }
   Text("Filled \(inking.filledDate.abbreviated)")
    .font(.caption2)
    .foregroundStyle(.secondary)
   Button("Empty") {
    inking.emptiedDate = .now
   }
   .font(.caption)
  }
  .padding()
  .background(.quaternary.opacity(0.3))
  .clipShape(RoundedRectangle(cornerRadius: 10))
 }
}
