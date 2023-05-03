//
//  ViewController.swift
//  Project002
//
//  Created by Георгий Евсеев on 22.05.22.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!

    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var maxScore = Int()
    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        registerLocal()
        scheduleLocal()

        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1

        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0).cgColor

        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        askQuestion()

        let defaults = UserDefaults.standard

        if let savedPeople = defaults.object(forKey: "maxScore") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? Int {
                maxScore = decodedPeople
            }
        }
    }

    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                print("Yay")
            } else {
                print("D'oh!")
            }
        }
    }

    @IBAction func showScore(_ sender: Any) {
        let ac = UIAlertController(title: "Warning!", message: "Your score is \(score).", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default))
        present(ac, animated: true)
    }

    @objc func scheduleLocal() {
        registerCategories()

        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Hello"
        content.body = "Go Game!!!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let centerSecond = UNUserNotificationCenter.current()
        centerSecond.delegate = self

        let show = UNNotificationAction(identifier: "show", title: "Remind me later", options: .destructive)

        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])

        center.setNotificationCategories([category])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")

            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock

                print("Default identifier")

            case "show":

                print("remind...")
                let ac = UIAlertController(title: "Well", message: "See you tomorrow", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                scheduleLocal()

            default:
                break
            }
        }

        completionHandler()
    }

    func askQuestion(action: UIAlertAction! = nil) {
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        // найти флаг этой страны
        correctAnswer = Int.random(in: 0 ... 2)

        // делаем заголовок с вопросом найти флаг этой страны с большими буквами буквы
        title = "\(countries[correctAnswer].uppercased()). Score is \(score)."
        count += 1
        if count == 11 {
            title = "THE END"

            let ac = UIAlertController(title: title, message: "Your score is \(score).", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "GoodBuy", style: .default, handler: askQuestion))
            present(ac, animated: true)
            scheduleLocal()
        }
        button1.transform = CGAffineTransform(scaleX: 1, y: 1)
        button2.transform = CGAffineTransform(scaleX: 1, y: 1)
        button3.transform = CGAffineTransform(scaleX: 1, y: 1)
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String

        sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
            if score > maxScore {
                maxScore = score
                title = "Correct! You have \(maxScore) point. It is a new record!"
                save()
            }

        } else {
            title = "Wrong! This counry is \(countries[sender.tag].uppercased())"
            score -= 1
        }
        countries.shuffle()
        let ac = UIAlertController(title: title, message: "Your score is \(score).", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        present(ac, animated: true)
    }

    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: maxScore, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "maxScore")
        }
        print("OK")
    }

//    @IBAction func showScore(_ sender: UIButton) {
//        let ac = UIAlertController(title: "Warning!", message: "Your score is \(score).", preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "Continue", style: .default))
//        present(ac, animated: true)
//    }
}
