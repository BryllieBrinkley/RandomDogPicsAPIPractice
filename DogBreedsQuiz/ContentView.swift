//
//  ContentView.swift
//  DogBreedsQuiz
//
//  Created by Jibryll Brinkley on 10/2/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var dogPic: DogPicture?
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                Text("Enjoy your Random Dog Pic! :)")
                    .font(.title)
                    .foregroundColor(.black)
                
                Spacer()
                
                if let dogURL = URL(string: dogPic?.message ?? "") {
                    AsyncImage(url: dogURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.white
                    }
                } else {
                    Color.white
                }
                Spacer()
                
                Button(action: {
                    Task {
                        await fetchDogPicture()
                    }
                }, label: {
                    ZStack {
                        Capsule()
                            .frame(width: 250, height: 50)
                            .foregroundColor(.blue)
                        Text("Generate")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                })
            }
        }
        .task {
            do {
                await fetchDogPicture()
            } catch {
                print("error fetching dog pic")
            }
        }
    }
    
    struct DogPicture: Codable {
        var message: String
        let status: String
    }
    
    
    // creating a custom error object - to handle each erorr specifically
    enum DPError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
    }
    
    
    func fetchDogPicture() async {
        do {
            let dogPicture = try await getDogPicture()
            dogPic = dogPicture
        } catch {
            print("failed to fetch dog picture")
        }
    }
    
    
    
    
    // api call
    func getDogPicture() async throws -> DogPicture {
        
        // api endpoint
        let apiUrl = "https://dog.ceo/api/breeds/image/random"
        
        // converts the url from string (above) to a URL, so that it can be used in the URLSession
        guard let url = URL(string: apiUrl) else { throw DPError.invalidURL }
        
        
        //URLSession: how you make network calls
        let (data, response) = try await URLSession.shared.data(from: url)
        
        
        // Handles error if the response status code != 200
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw DPError.invalidResponse
        }
        
        // If response status code == 200, now we work with the data we receive.
        // use the data to convert the json into a DogPicture object
        do {
            let decoder = JSONDecoder()
            
            // when decoding, we tell it what type we are decoding into (DogPicture.self)
            return try decoder.decode(DogPicture.self, from: data)
        } catch {
            throw DPError.invalidData
        }
    }
}


#Preview {
    ContentView()
}
