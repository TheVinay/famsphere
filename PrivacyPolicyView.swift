//
//  PrivacyPolicyView.swift
//  FamSphere
//
//  Created by Vinays Mac on 1/19/26.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Privacy & Security")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("Your family's data is protected")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    
                    Divider()
                    
                    // End-to-End Encryption
                    privacySection(
                        icon: "lock.fill",
                        iconColor: .green,
                        title: "256-Bit Encryption",
                        description: "All your family's data is protected with industry-standard 256-bit AES encryption, both in transit and at rest."
                    )
                    
                    // iCloud Private Database
                    privacySection(
                        icon: "icloud.fill",
                        iconColor: .blue,
                        title: "iCloud Private Database",
                        description: "Your data is stored in your personal iCloud account using CloudKit's private database. Apple cannot access your family's messages, events, or goals."
                    )
                    
                    // Apple's Privacy Commitment
                    privacySection(
                        icon: "hand.raised.fill",
                        iconColor: .purple,
                        title: "Apple's Privacy SLA",
                        description: "FamSphere leverages Apple's industry-leading privacy standards and service level agreements. Your data remains private and is never sold or used for advertising."
                    )
                    
                    // Data Ownership
                    privacySection(
                        icon: "person.fill.checkmark",
                        iconColor: .orange,
                        title: "You Own Your Data",
                        description: "All data belongs to you and your family. You can export or delete your information at any time through your iCloud settings."
                    )
                    
                    // Family Sharing
                    privacySection(
                        icon: "person.2.fill",
                        iconColor: .pink,
                        title: "Secure Family Sharing",
                        description: "When you share FamSphere with family members, only invited participants can access shared data. Invitations use Apple ID authentication for maximum security."
                    )
                    
                    // No Third-Party Access
                    privacySection(
                        icon: "shield.checkered",
                        iconColor: .red,
                        title: "No Third-Party Access",
                        description: "FamSphere does not share your data with third parties, advertisers, or analytics companies. Your family's information stays within your family."
                    )
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Additional Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Additional Information")
                            .font(.headline)
                        
                        Text("FamSphere is designed with privacy at its core. We follow Apple's Human Interface Guidelines and privacy best practices to ensure your family's data remains secure.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("For questions about privacy, please review Apple's iCloud Privacy Overview at apple.com/legal/privacy")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func privacySection(icon: String, iconColor: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
