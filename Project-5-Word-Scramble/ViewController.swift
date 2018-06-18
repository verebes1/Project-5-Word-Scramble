//
//  ViewController.swift
//  Project-5-Word-Scramble
//
//  Created by verebes on 12/06/2018.
//  Copyright © 2018 A&D Progress. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getWords(file: "start", ext: "txt")
        startGame()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
    }
    //MARK:- Game Methods
    
    func getWords(file: String, ext fileExtension: String) {
        if let startWordsPath = Bundle.main.path(forResource: file, ofType: fileExtension) {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
            } else {
                allWords = ["silkworm"]
            }
        } else {
            allWords = ["silkworm"]
        }
    }
    
    func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        title = allWords[0].uppercased()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
   @objc func promptForAnswer() {
    let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
    ac.addTextField()
    
    let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] _ in //(action: UIAlertAction) same as action in or _ in as we are not using action
        let answer = ac.textFields![0]
        self.submit(answer: answer.text!)
    }
    
    ac.addAction(submitAction)
    
    present(ac, animated: true)

    }
    
    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up, you know!"
                    showErrorMessage(title: errorTitle, message: errorMessage)
                }
            }else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
                showErrorMessage(title: errorTitle, message: errorMessage)
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title!.lowercased()) !"
            showErrorMessage(title: errorTitle, message: errorMessage)
        }
    }
    
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool{
        var tempWord = title!.lowercased()
        
        for letter in word {
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool{
        if word.lowercased() == title!.lowercased() {
            return false
        } else {
            return !usedWords.contains(word)
        }
    }
    
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        if word.count <= 2 {
            return false
        } else {
            return misspelledRange.location == NSNotFound
        }
    }
    
    //MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row].uppercased()
        
        return cell
    }


}

