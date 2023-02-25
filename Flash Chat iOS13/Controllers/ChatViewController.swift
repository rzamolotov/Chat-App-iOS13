//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true // спрятать кнопку назад
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier) // регистрируем кастомную ячейку в тейблвью
        loadMessages()
    }
    
    func loadMessages() {
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField) //упорядовачием сообщения
            .addSnapshotListener() { (querySnapshot, error) in
            
            self.messages = []
            
            
            if let e = error {
                let alert = UIAlertController(title: "Alert", message: e.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                print("Error getting documents: \(e)")
                // если не удалось загрузить сообщение запускаем аллерт с ошибкой
            } else {
                if let snapshotDocumetns = querySnapshot?.documents {
                    for document in snapshotDocumetns {
                        let data = document.data()
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)//добавляем сообщения после обновления
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()//перезагружаем тейбл вью с новыми сообщениями
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0) //номер ячейки к которому будем проеручивать весь список новостей(массив -1), секция - это номер секции
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    } // загружаем сообщения
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [ //сохраняем данные в дата базе фаерстора
                K.FStore.senderField : messageSender, // сохраняем данные имя в базе по ключу отправителя в фаерстор
                K.FStore.bodyField : messageBody, // сохраняем данные сообщение в базе по ключу текста сообщения в фаерстор
                K.FStore.dateField : Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error {
                    let alert = UIAlertController(title: "Alert", message: e.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                        print("There was an issue saving data to firestore,\(e).")
                    }))
                    self.present(alert, animated: true, completion: nil)// если не удалось сохранить сообщение запускаем аллерт с ошибкой
                } else {
                    print("Succesfully saved data.")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = "" //делаем строку отправки сообщения пустой если оно было успешно сохранено и отправлено
                    }
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)// при нажатии на кнопку выхода выходим на главный экран
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    } //нажатие на кнопку logout и выход на главное меню
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    } //считаем количество ячеек в списке
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.lable.text = message.body //отображаем сообщения по номеру ячейки
        
        //Если сообщение прихождит от текущего пользователся(отправителя)
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBuble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.lable.textColor = UIColor(named: K.BrandColors.purple)
        } else {  //Если сообщение прихождит от другого пользователся(получателя)
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBuble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.lable.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        return cell
    } //в какой конкретной ячейке должно отображаться сообщение
}


