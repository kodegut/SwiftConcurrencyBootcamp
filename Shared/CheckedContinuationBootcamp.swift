//
//  CheckedContinuationBootcamp.swift
//  SwiftConcurrencyBootcamp (iOS)
//
//  Created by Tim Musil on 16.06.22.
//

import SwiftUI

// Continuation is used for apis that aren't updated yet for the async await paradigma

class CheckedContinuationBootcampNetworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch  {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                
                // Note we have to resume exactly ONCE so we have handle every case in ELSE statements to make sure that is resumed once
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }.resume()
        }
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartImageFromDatabaseWithContinuation() async -> UIImage {
       return await withCheckedContinuation { continuation in
           getHeartImageFromDatabase { image in
               continuation.resume(returning: image)
           }
        }
    }
    
}

class CheckedContinuationBootcampViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let networkManager = CheckedContinuationBootcampNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/100") else { return }
        
        do {
            let data = try await networkManager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
            
        } catch {
            print(error)
        }
    }
    
    func getHeartImage() {
        networkManager.getHeartImageFromDatabase { [weak self] image in
            self?.image = image
        }
    }
    
    func getHeartImageContinuation() async {
        self.image = await networkManager.getHeartImageFromDatabaseWithContinuation()
    }
    
}

struct CheckedContinuationBootcamp: View {
    @StateObject private var viewModel = CheckedContinuationBootcampViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
        }
        .task {
            //await viewModel.getImage()
            await viewModel.getHeartImageContinuation()
        }
    }
}

struct CheckedContinuationBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuationBootcamp()
    }
}
