//
//  RegisterViewController.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let progressBar = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let emailField: UITextField = {
        let pole = UITextField()
        pole.autocapitalizationType = .none
        pole.autocorrectionType = .no
        pole.returnKeyType = .continue
        pole.layer.cornerRadius = 12
        pole.layer.borderWidth = 1
        pole.layer.borderColor = UIColor(red: 0.35, green: 0.35, blue: 0.41, alpha: 0.5).cgColor
        pole.placeholder = "Adres e-mail "
        pole.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        pole.leftViewMode = .always
        pole.backgroundColor = UIColor(red: 0.35, green: 0.35, blue: 0.41, alpha: 0.5)
        return pole
    }()
    
    private let imiePole: UITextField = {
        let pole = UITextField()
        pole.autocapitalizationType = .none
        pole.autocorrectionType = .no
        pole.returnKeyType = .continue
        pole.layer.cornerRadius = 12
        pole.layer.borderWidth = 1
        pole.layer.borderColor = UIColor(red: 0.35, green: 0.35, blue: 0.41, alpha: 0.5).cgColor
        pole.placeholder = "Imię"
        pole.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        pole.leftViewMode = .always
        pole.backgroundColor = UIColor(red: 0.35, green: 0.35, blue: 0.41, alpha: 0.5)
        return pole
    }()
    
    private let nazwiskoPole: UITextField = {
        let pole = UITextField()
        pole.autocapitalizationType = .none
        pole.autocorrectionType = .no
        pole.returnKeyType = .continue
        pole.layer.cornerRadius = 12
        pole.layer.borderWidth = 1
        pole.layer.borderColor = UIColor(red: 0.35, green: 0.35, blue: 0.41, alpha: 0.5).cgColor
        pole.placeholder = "Nazwisko"
        pole.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        pole.leftViewMode = .always
        pole.backgroundColor = UIColor(red: 0.35, green: 0.35, blue: 0.41, alpha: 0.5)
        return pole
    }()
    
    private let password: UITextField = {
        let pole = UITextField()
        pole.autocapitalizationType = .none
        pole.autocorrectionType = .no
        pole.returnKeyType = .continue
        pole.layer.cornerRadius = 12
        pole.layer.borderWidth = 1
        pole.layer.borderColor = UIColor(red: 0.35, green: 0.35, blue: 0.41, alpha: 0.5).cgColor
        pole.placeholder = "Hasło"
        pole.isSecureTextEntry = true
        pole.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        pole.leftViewMode = .always
        pole.backgroundColor = UIColor(red: 0.35, green: 0.35, blue: 0.41, alpha: 0.5)
        return pole
    }()
    
    private let profilePicture: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle.fill.badge.questionmark")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Zarejestruj", for: .normal)
        button.backgroundColor = UIColor(red: 0.255, green: 0.249, blue: 0.55, alpha: 0.7)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        title = "Rejestracja"
        
        registerButton.addTarget(self, action: #selector(tryToRegister), for: .touchUpInside)
        
        emailField.delegate = self
        password.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ustawZdjProfilowe))
        gesture.numberOfTapsRequired = 1
        profilePicture.addGestureRecognizer(gesture)
        profilePicture.isUserInteractionEnabled = true;
        
        view.addSubview(scrollView)
        scrollView.addSubview(profilePicture)
        scrollView.addSubview(nazwiskoPole)
        scrollView.addSubview(imiePole)
        
        scrollView.addSubview(emailField)
        scrollView.addSubview(password)
        scrollView.addSubview(registerButton)
    }
    
    @objc private func ustawZdjProfilowe() {
        wyborZdjProfilowego()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        //logo
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profilePicture.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profilePicture.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            profilePicture.widthAnchor.constraint(equalToConstant: view.frame.size.width/2),
            profilePicture.heightAnchor.constraint(equalToConstant: view.frame.size.width/2),
        ])
        
        //imie
        imiePole.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imiePole.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imiePole.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 35),
            imiePole.widthAnchor.constraint(equalToConstant: view.width - 60),
            imiePole.heightAnchor.constraint(equalToConstant: 52),
        ])
        
        //nazwisko
        nazwiskoPole.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nazwiskoPole.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nazwiskoPole.topAnchor.constraint(equalTo: imiePole.bottomAnchor, constant: 10),
            nazwiskoPole.widthAnchor.constraint(equalToConstant: view.width - 60),
            nazwiskoPole.heightAnchor.constraint(equalToConstant: 52),
        ])
        
        //email
        emailField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailField.topAnchor.constraint(equalTo: nazwiskoPole.bottomAnchor, constant: 10),
            emailField.widthAnchor.constraint(equalToConstant: view.width - 60),
            emailField.heightAnchor.constraint(equalToConstant: 52),
        ])
        
        //password
        password.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            password.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            password.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 10),
            password.widthAnchor.constraint(equalToConstant: view.width - 60),
            password.heightAnchor.constraint(equalToConstant: 52),
        ])
        
        //login btn
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 15),
            registerButton.widthAnchor.constraint(equalToConstant: view.width - 60),
            registerButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    @objc private func tryToRegister() {
        
        emailField.resignFirstResponder()
        password.resignFirstResponder()
        nazwiskoPole.resignFirstResponder()
        imiePole.resignFirstResponder()
        
        guard let imie = imiePole.text,
              let nazwisko = nazwiskoPole.text,
              let email = emailField.text,
              let pswd = password.text,
              !email.isEmpty,
              !pswd.isEmpty,
              !nazwisko.isEmpty,
              !imie.isEmpty,
              pswd.count >= 6 else {
            alertFailedToRegistr()
            return
        }
        
        progressBar.show(in: view)
        
        DatabaseService.shared.czyUzytkownikIstnieje(with: email) { [weak self] uzytkownikIstnieje in
              
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.progressBar.dismiss()
            }
            
            guard !uzytkownikIstnieje else {
                self.alertFailedToRegistr(error: "Konto o podanym adresie email już istnieje!")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: pswd) { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Nie można utworzyć konta")
                    return
                }
                
                let uzytkownik = ObiektUzytkownika(
                    imie: imie,
                    nazwisko: nazwisko,
                    adresEmail: email)
                
                DatabaseService.shared.utworzUzytkownika(with: uzytkownik) { (success) in
                    if success {
                        //upload img
                        guard let image = self.profilePicture.image,
                              let data = image.pngData() else {
                            return
                        }
                        
                        let file = uzytkownik.zdjProfiloweFile
                        StorageService.instance.uploadAvatar(data: data, fileName: file) { (result) in
                            switch result {
                            case .success(let downloadURL):
                                UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                print(downloadURL)
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func alertFailedToRegistr(error: String = "Wprowadź poprawne dane wymagane do rejestracji" ) {
        let alert = UIAlertController(
            title: "Błąd!",
            message: error ,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ponów", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == imiePole {
            nazwiskoPole.becomeFirstResponder()
        } else if textField == nazwiskoPole {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            password.becomeFirstResponder()
        } else if textField == password {
            tryToRegister()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func wyborZdjProfilowego() {
        let kontrolkaWyboru = UIAlertController(title: "Zdjęcie profilowe", message: "W jaki sposób chcesz ustawić zdjęcie profilowe?", preferredStyle: .actionSheet)
        kontrolkaWyboru.addAction(UIAlertAction(
                                    title: "Anuluj",
                                    style: .cancel,
                                    handler: nil))
        kontrolkaWyboru.addAction(UIAlertAction(
                                    title: "Wybierz z galerii",
                                    style: .default,
                                    handler: { [weak self] _ in
                                        guard let self = self else {
                                            return
                                        }
                                        self.wybierzZdjZGalerii()
                                    }))
        kontrolkaWyboru.addAction(UIAlertAction(
                                    title: "Zrób zdjęcie",
                                    style: .default,
                                    handler: { [weak self ] _ in
                                        guard let self = self else {
                                            return
                                        }
                                        self.zrobZdjecieAparatem()
                                    }))
        present(kontrolkaWyboru, animated: true )
    }
    
    private func zrobZdjecieAparatem() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    private func wybierzZdjZGalerii() {
        let vc = UIImagePickerController()
        //        vc.modalPresentationStyle = .overCurrentContext
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.profilePicture.image = selectedImage
        self.profilePicture.layer.borderWidth = 5
        self.profilePicture.layer.borderColor = UIColor(red: 0.35, green: 0.35, blue: 0.41, alpha: 0.5).cgColor
        self.profilePicture.layer.cornerRadius = 90
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
