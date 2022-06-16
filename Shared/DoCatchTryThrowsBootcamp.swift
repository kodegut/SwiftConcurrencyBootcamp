//
//  DoCatchTryThrowsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Tim Musil on 07.06.22.
//

import SwiftUI

// do-catch
// try
// catch

class DoCatchTryThrowsBootcampDataManager {
    
    let isActive: Bool = true
    
    //hard to read
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("NEW Text!", nil)
        } else {
            return (nil, URLError(.badURL))
        }
        
    }
    //improved: You get a result with a string and an Error, you can switch on it later
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("New Text!")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    //improved further: You get either a success or a failure
    func getTitle3() throws -> String {
        if isActive {
            return "New Text!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
    // this was just to show that the catch block is triggered already by the first throwing function in the do block
    func getTitle4() throws -> String {
        if isActive {
            return "Final Text!"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

class DoCatchTryThrowsBootcampViewModel: ObservableObject {
    
    @Published var text: String = "Starting text."
    let manager = DoCatchTryThrowsBootcampDataManager()
    
    func fetchTitle() {
        /*
        let returnedValue = manager.getTitle()
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedDescription
        }
     */
        /*let result = manager.getTitle2()
    
    switch result {
    case .success(let newTitle):
        self.text = newTitle
    case .failure(let error):
        self.text = error.localizedDescription
    }
        */
        
        let newTitle = try? manager.getTitle3()
        if let newTitle = newTitle {
        self.text = newTitle
        }
        
        do {
            let newTitle = try manager.getTitle3()
            self.text = newTitle

            let finalTitle = try manager.getTitle4()
            self.text = finalTitle
        } catch let error {
            self.text = error.localizedDescription
        }
    }
                
                
                
}

struct DoCatchTryThrowsBootcamp: View {
    @StateObject private var viewModel = DoCatchTryThrowsBootcampViewModel()
    var body: some View {
        
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

struct DoCatchTryThrowsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrowsBootcamp()
    }
}
