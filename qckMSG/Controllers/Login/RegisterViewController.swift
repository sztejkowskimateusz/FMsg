//
//  RegisterViewController.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import UIKit

class RegisterViewController: UIViewController {

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
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.square.fill")
        imageView.contentMode = .scaleAspectFit
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
        title = "Log In"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Rejestracja", style: .done, target: self, action: #selector(didTapRegister))
        
        registerButton.addTarget(self, action: #selector(tryToSignIn), for: .touchUpInside)
        
        emailField.delegate = self
        password.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ustawZdjProfilowe))
        gesture.numberOfTapsRequired = 1
        logoImageView.addGestureRecognizer(gesture)
        logoImageView.isUserInteractionEnabled = true;
        
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(nazwiskoPole)
        scrollView.addSubview(imiePole)
        
        scrollView.addSubview(emailField)
        scrollView.addSubview(password)
        scrollView.addSubview(registerButton)
    }
    
    @objc private func ustawZdjProfilowe() {
        
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
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            logoImageView.widthAnchor.constraint(equalToConstant: view.frame.size.width/2),
            logoImageView.heightAnchor.constraint(equalToConstant: view.frame.size.width/2),
        ])
        
        //imie
        imiePole.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imiePole.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imiePole.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 35),
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
    
    @objc private func tryToSignIn() {
        
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
            alertSignInError()
            return
        }
        
    }
    
    private func alertSignInError() {
        let alert = UIAlertController(title: "Błąd!", message: "Wprowadź poprawne dane wymagane do rejestracji", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ponów", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let registerVC = RegisterViewController()
        registerVC.title = "Utwórz konto"
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            password.becomeFirstResponder()
        } else if textField == password {
            tryToSignIn()
        }
        
        return true
    }
}
