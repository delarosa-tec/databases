//
//  ViewController.swift
//  database
//
//  Created by Jorge De la Rosa Paredes on 19/10/22.
//

import UIKit
import PostgresClientKit
import FirebaseDatabase


class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var firstTableView: UITableView!
    @IBOutlet weak var consultaFireBaseTextField: UITextField!
    @IBOutlet weak var fireBaseTextField: UITextField!
    @IBOutlet weak var resultadoFireBaseLabel: UILabel!
    @IBOutlet weak var consultaTextField: UITextField!
    @IBOutlet weak var resultadoLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        firstTableView.dataSource = self
    }
    
    let resultados = ["VALOR 1", "VALOR 2", "VALOR 3"]
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resutladoAsignacion = resultados[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifiacorCeldaUno", for: indexPath) as! PrimerCelda
        cell.tituloLabel.text = "Titulo \(indexPath.row + 1)"
        cell.resultadoLabel.text = resutladoAsignacion
        let randomRed = CGFloat.random(in: 0..<1)
        let randomBlue = CGFloat.random(in: 0..<1)
        let randomGreen = CGFloat.random(in: 0..<1)
        cell.fondoView.backgroundColor = UIColor(displayP3Red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultados.count;
    }
    
    @IBAction func baseDeDatosFirebase(_ sender: UIButton) {
        //TODO: Deben agregar su archivo GoogleService-Info.plist para poder hacer uso de FireBase
        let componenteBD =  Database.database().reference()
//        componenteBD.childByAutoId().setValue(["userId":1, "username":fireBaseTextField.text, "password":"asdfas1==", "email": "\(fireBaseTextField.text ?? "")@tec.mx"])
        componenteBD.child("user").childByAutoId().setValue(["userId":1, "username":fireBaseTextField.text, "password":"asdfas1==", "email": "\(fireBaseTextField.text ?? "")@tec.mx"])
        
        resultadoFireBaseLabel.text = "Se agregaron los datos de manera exitosa."
    }
    
    @IBAction func consultaFireBase(_ sender: UIButton) {
        //TODO: Deben agregar su archivo GoogleService-Info.plist para poder hacer uso de FireBase
        let componenteBD =  Database.database().reference()
        componenteBD.child(consultaFireBaseTextField.text!).observeSingleEvent(of: .value, with: {
            (valorVariable) in
            //Otra forma de validar la el valor en valorVariable.value
//            let resultado = valorVariable.value as? [String: Any]
//            if resultado != nil
//            {
//                let username = resultado["username"] as? String
//                let password = resultado["password"] as? String
//                let email = resultado["email"] as? String
//                let userId = resultado["userId"] as? Int
//                self.resultadoFireBaseLabel.text = email
//            }
//            else {
//                self.resultadoFireBaseLabel.text = "Valor no encontrado"
//            }
            
            //Codigo previo a crear el child "user"
//            if let resultado = valorVariable.value as? [String: Any]
//            {
//                let username = resultado["username"] as? String
//                let password = resultado["password"] as? String
//                let email = resultado["email"] as? String
//                let userId = resultado["userId"] as? Int
//                self.resultadoFireBaseLabel.text = email
//            }
//            else {
//                self.resultadoFireBaseLabel.text = "Valor no encontrado"
//            }
            
            if let resultado = valorVariable.value as? [String: Any]
            {
                self.resultadoFireBaseLabel.text = ""
                for item in resultado {
                    if let resultadoItem = item.value as? [String: Any]
                    {
                        let username = resultadoItem["username"] as? String
                        let password = resultadoItem["password"] as? String
                        let email = resultadoItem["email"] as? String
                        let userId = resultadoItem["userId"] as? Int
                        self.resultadoFireBaseLabel.text = "\(self.resultadoFireBaseLabel.text ?? "") & \(email ?? "")"
                    }
                }
            }
            else {
                self.resultadoFireBaseLabel.text = "Valor no encontrado"
            }
        })
    }
    @IBAction func consultaPostgres(_ sender: UIButton) {
        do {
            var configuration = PostgresClientKit.ConnectionConfiguration()
            //conexion a localhost
            configuration.host = "127.0.0.1"
            configuration.database = "postgres"
            configuration.user = "postgres"
            configuration.ssl = false
            configuration.port = 5430
            
            //conexion a servidor
//            configuration.host = ""
//            configuration.database = ""
//            configuration.user = ""
//            configuration.ssl = false
//            configuration.credential = .md5Password(password: "")

            let connection = try PostgresClientKit.Connection(configuration: configuration)
            defer { connection.close() }

            let text = consultaTextField.text
//            let text = "SELECT * FROM accounts;"
            let statement = try connection.prepareStatement(text: text!)
            defer { statement.close() }

            let cursor = try statement.execute()
            defer { cursor.close() }

            resultadoLabel.text = ""
            for row in cursor {
                let columns = try row.get().columns
                let userId = try columns[0].int()
                let userName = try columns[1].string()
                let password = try columns[2].string()
                let email = try columns[3].string()
                let created = try columns[4].timestamp()
                let lastLogin = try columns[5].timestamp()
                
                resultadoLabel.text = resultadoLabel.text! + "userid: \(userId) \nusername: \(userName) \npassword: \(password) \nemail: \(email)"
            }
        } catch {
            //ENVIAR EL ERROR A FIREBASE
            print(error)
            resultadoLabel.text = "Ocurrió un error."
        }
    }
    
}

