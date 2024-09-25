//
//  ContentView.swift
//  WordScramble
//
//  Created by Joshua Rosado Olivencia on 9/24/24.
//


import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    var body: some View {
        NavigationStack{
            List{
                Section {
                    TextField("Enter your word", text: $newWord)
                    
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            
                            Text(word)
                        }
                        
                    }
                    
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            
            // ADDING ALERT ERROR BTN/TITLE/MESSAGE
            .alert(errorTitle, isPresented: $showingError){
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
        
    }
    
    func addNewWord() {
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        // IF WORD IS NOT ORIGINAL USE THE isOriginal Func and return error messages
        guard isOriginal(word: answer) else{
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        // IF WORD IS NOT POSSIBLE USE THE isPossible Func and return error messages
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        // IF WORD IS NOT REAL USE THE isRealWord Func and return error messages
        guard isRealWord(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt")
        {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .ascii) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    
    // ============= VALIDATING WORDS
    
    // CHECK IF WORD IS ORIGINAL
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    // REMOVE LETTER IF ITS FOUND IN THE WORD, SO IT CAN'T BE REPEATED
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word { // loop over the letters of the word
            // if we find this letter in the tempWord
            if let position = tempWord.firstIndex(of: letter){
                // remove that letter so It can NOT be use again
                tempWord.remove(at: position)
            } else {
                // if no letters where found
                return false
            }
        }
        return true
    }
    
    
    // CHECK IF IS A REAL WORD
    func isRealWord(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound

    }
    // RETURNING ERROR
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
        
    }
    

}


#Preview {
    ContentView()
}
