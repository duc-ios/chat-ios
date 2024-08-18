//
//  CircleAvatar.swift
//  StrapiChat
//
//  Created by Duc on 19/8/24.
//

import Kingfisher
import SwiftUI

struct CircleAvatar: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url, content: { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        }, placeholder: {
            Rectangle().foregroundStyle(Color.separator)
        })
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }
}

#Preview {
    CircleAvatar(url: UserSettings.baseUrl.appending(path: "uploads/thumbnail_pexels_maksim_goncharenok_4757976_4882351252.jpeg"))
}

extension Color {
    static var separator = Color(hex: "EBEDF0")
}
