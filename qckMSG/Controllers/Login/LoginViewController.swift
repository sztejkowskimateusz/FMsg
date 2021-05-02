//
//  LoginViewController.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
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
    
    private let fbLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    private let googleLogInBtn = GIDSignInButton()
    
    private var obserwatorLogowania: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        title = "Logowanie"
        NotificationCenter.default.addObserver(forName: .zalogowanoPowiadomienie,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            guard let strongSelf = self else {
                print("error zalogowano powiadomienie")
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Rejestracja", style: .done, target: self, action: #selector(didTapRegister))
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        googleLogInBtn.style = .iconOnly
        
        loginButton.addTarget(self, action: #selector(tryToSignIn), for: .touchUpInside)
        
        emailField.delegate = self
        password.delegate = self
        fbLoginButton.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(password)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(fbLoginButton)
        scrollView.addSubview(googleLogInBtn)
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
        
        fbLoginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fbLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fbLoginButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 25),
            fbLoginButton.widthAnchor.constraint(equalToConstant: view.width - 60),
            fbLoginButton.heightAnchor.constraint(equalToConstant: 52),
        ])
        
        googleLogInBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            googleLogInBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleLogInBtn.topAnchor.constraint(equalTo: fbLoginButton.bottomAnchor, constant: 15),
            googleLogInBtn.widthAnchor.constraint(equalToConstant: view.width - 60),
            googleLogInBtn.heightAnchor.constraint(equalToConstant: 52),
        ])
        
    }
    
    deinit {
        if let obserwator = obserwatorLogowania {
            NotificationCenter.default.removeObserver(obserwator)
        }
    }
    
    @objc private func tryToSignIn() {
        
        emailField.resignFirstResponder()
        password.resignFirstResponder()
        
        guard let email = emailField.text, let pswd = password.text, !email.isEmpty, !pswd.isEmpty, pswd.count >= 6 else {
            alertSignInError()
            return
        }
        
        progressBar.show(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: pswd) { [weak self] (authResult, error) in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.progressBar.dismiss() 
            }
            
            guard let result = authResult, error == nil else {
                print("Nie udało się zalogować adresem email \(email)")
                return
            }
            let uzytkownik = result.user
            
            UserDefaults.standard.setValue(email, forKey: "email")
            
            print("Zalogowano użytkownika \(uzytkownik)")
            self.dismiss(animated: true, completion: nil)
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

extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("Nie udało sie zalogować kontem FB")
            return
        }
        
        let fbZapytanie = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                     parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: token,
                                                     version: nil,
                                                     httpMethod: .get)
        
        fbZapytanie.start { (_, result, error) in
            guard let result = result as? [String: Any],
                  error == nil else {
                print(error)
                return
            }
            
            guard let imieUzytkownika = result["first_name"] as? String,
                  let nazwiskoUzytkownika = result["last_name"] as? String,
                  let adresEmail = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String else {
                    return
                }
            
            UserDefaults.standard.setValue(adresEmail, forKey: "email")
            
            DatabaseService.shared.czyUzytkownikIstnieje(with: adresEmail) { istnieje in
                if !istnieje {
                    let uzytkownik = ObiektUzytkownika(imie: imieUzytkownika,
                                                       nazwisko: nazwiskoUzytkownika,
                                                       adresEmail: adresEmail)
                    DatabaseService.shared.utworzUzytkownika(with: uzytkownik) { (success) in
                        if success {
                            guard let url = URL(string: pictureUrl) else { return }
                            
                            URLSession.shared.dataTask(with: url) { (data, _, error) in
                                guard let data = data, error == nil else {
                                    print("failed to get picture from fb")
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
                            }.resume()
                        }
                    }
                }
            }
            
            let daneLogowania = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: daneLogowania) { [weak self] (authResult, error) in
                
                guard let self = self else {
                    return
                }
                guard authResult != nil, error == nil else {
                    print("Nie udało się zalogować kontem FB, uwierzytelnianie dwuskładnikowe może być wymagane! Error: \(error!)")
                    return
                }
                
                print("Udało się zalogować kontem FB")
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
