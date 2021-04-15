//
//  LoginViewController.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import UIKit

class LoginViewController: UIViewController {
    
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
        pole.textColor = .white
        pole.layer.borderWidth = 1
        pole.layer.borderColor = UIColor(red: 0.35, green: 0.35, blue: 0.41, alpha: 0.5).cgColor
        pole.placeholder = "Adres e-mail "
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
        pole.textColor = .white
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
        imageView.image = UIImage(named: "appIcon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Zaloguj", for: .normal)
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
        
        loginButton.addTarget(self, action: #selector(tryToSignIn), for: .touchUpInside)
        
        emailField.delegate = self
        password.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(password)
        scrollView.addSubview(loginButton)
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
            logoImageView.widthAnchor.constraint(equalToConstant: view.frame.size.width/2.5),
            logoImageView.heightAnchor.constraint(equalToConstant: view.frame.size.width/2),
        ])
        
        //email
        emailField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 35),
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
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 15),
            loginButton.widthAnchor.constraint(equalToConstant: view.width - 60),
            loginButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    @objc private func tryToSignIn() {
        
        emailField.resignFirstResponder()
        password.resignFirstResponder()
        
        guard let email = emailField.text, let pswd = password.text, !email.isEmpty, !pswd.isEmpty, pswd.count >= 6 else {
            alertSignInError()
            return
        }
        
    }
    
    private func alertSignInError() {
        let alert = UIAlertController(title: "Błąd!", message: "Wprowadź poprawne dane", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ponów", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let registerVC = RegisterViewController()
        registerVC.title = "Utwórz konto"
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            password.becomeFirstResponder()
        } else if textField == password {
            tryToSignIn()
        }
        
        return true
    }
}
