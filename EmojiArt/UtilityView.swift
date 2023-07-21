//
//  UtilityView.swift
//  EmojiArt
//
//  Created by yakir on 2023/7/21.
//

import SwiftUI

struct UtilityView: View {
	var body: some View {
		Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
	}
}

struct AnimatedActionButton: View {
	var title: String? = nil
	var systemImage: String? = nil
	var action: () -> Void
	var body: some View {
		Button {
			withAnimation {
				action()
			}
		} label: {
			if title != nil && systemImage != nil {
				Label(title!, systemImage: systemImage!)
			} else if title != nil {
				Text(title!)
			} else if systemImage != nil {
				Image(systemName: systemImage!)
			}
		}
	}
}
