//
//  ViewController.swift
//  Project5
//
//  Created by Nikola on 7/28/19.
//  Copyright © 2019 Nikola Krstevski. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barButtonItems()
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        startGame()
    }
    
    func barButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac ] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        guard isSameAsTitle(word: lowerAnswer) else {
            return showErrorMessage(errorMessage: "You can't use title as a word!", errorTitle: "Title word used!")
        }
        guard isPossible(word: lowerAnswer) else {
            return showErrorMessage(errorMessage: "Word not possible!", errorTitle: "You can't spell that word from \(title!.lowercased())")
        }
        guard isOriginal(word: lowerAnswer) else {
            return showErrorMessage(errorMessage: "Word allready used!", errorTitle: "Be more original")
        }
        guard isReal(word: lowerAnswer) else {
            return showErrorMessage(errorMessage: "Word not recognized", errorTitle: "You can't just make them up you know!")
        }
        usedWords.insert(answer.lowercased() , at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
//        if isSameAsTitle(word: lowerAnswer) {
//            if isPossible(word: lowerAnswer) {
//                if isOriginal(word: lowerAnswer) {
//                    if isReal(word: lowerAnswer) {
//                        usedWords.insert(answer.lowercased() , at: 0)
//
//                        let indexPath = IndexPath(row: 0, section: 0)
//                        tableView.insertRows(at: [indexPath], with: .automatic)
//                        return
//                    } else {
//                        showErrorMessage(errorMessage: "Word not recognized", errorTitle: "You can't just make them up you know!")
//                    }
//                } else {
//                    showErrorMessage(errorMessage: "Word allready used!", errorTitle: "Be more original")
//                }
//            } else {
//                showErrorMessage(errorMessage: "Word not possible!", errorTitle: "You can't spell that word from \(title!.lowercased())")
//            }
//        } else {
//            showErrorMessage(errorMessage: "You can't use title as a word!", errorTitle: "Title word used!")
//        }
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false;
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        if word.count < 2 {
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func isSameAsTitle(word: String) -> Bool {
        guard let title = title else { return false }
        if word == title {
            return false
        }
        return true
    }
    
    func showErrorMessage(errorMessage: String, errorTitle: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}


