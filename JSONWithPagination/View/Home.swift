//
//  Home.swift
//  JSONWithPagination
//
//  Created by Azizbek Musurmonov   on 25/03/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct Home: View {
    ///View Properties
    @State private var photos: [Photo] = []
    @State private var page: Int = 1
    @State private var lastFetchedPage: Int = 1
    @State private var isLoading: Bool = false
    @State private var maxPage: Int = 5
    /// Pagination Properties
    @State private var activePhotoId: String?
    @State private var lastPhotoId: String?
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 3), spacing: 10) {
                ForEach(photos) { photo in
                    PhotoCardView(photo: photo)
                }
            }
            .overlay(alignment: .bottom) {
                if isLoading {
                    ProgressView()
                        .offset(y: 30) // Apply offset to the ProgressView
                }
                
            }
            .padding(15)
            .padding(.bottom, 15)
            .scrollTargetLayout()
        }
        .scrollPosition(id: $activePhotoId, anchor: .bottomTrailing)
        .onChange(of: activePhotoId, { oldValue, newValue in
            if newValue == lastPhotoId, !isLoading, page != maxPage {
                page += 1
                fetchPhotos()
            }
        })
        .onAppear {
            if photos.isEmpty { fetchPhotos() }
        }
    }
    
    ///Fetching Photos as per needs
    func fetchPhotos() {
        Task {
            do {
                if let url = URL(string: "https://picsum.photos/v2/list?page=\(page)&limit=30") {
                    isLoading = true
                    let session = URLSession(configuration: .default)
                    let jsonData = try await session.data(from: url).0
                    let photos = try await JSONDecoder().decode([Photo].self, from: jsonData)
                    /// Updating UI in Main Thread
                    await MainActor.run {
                        if photos.isEmpty {
                            ///No More Data
                            page = lastFetchedPage
                        } else {
                            /// Adding To The Array of Photos
                            self.photos.append(contentsOf: photos)
                            lastPhotoId = self.photos.last?.id
                            lastFetchedPage = page
                        }
                        
                        isLoading = false
                    }
                }
            } catch {
                isLoading = false
                print(error.localizedDescription)
            }
        }
    }
}

///Photo Card View
struct PhotoCardView: View {
    var photo: Photo
    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            GeometryReader {
                let size = $0.size
                
                AnimatedImage(url: photo.imageURL) {
                    ProgressView()
                    ///To Place Indicator at center
                        .frame(width: size.width, height: size.height)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipShape(.rect(cornerRadius: 10))
            }
            .frame(height: 120)
            
            ///Author Name
            Text(photo.author)
                .font(.caption)
                .foregroundStyle(.gray)
                .lineLimit(1)
            
            /// You can add other properties, such as link etc.
        })
    }
}

#Preview {
    ContentView()
}
