import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
          
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        

        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(url)

    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            return
        }
        
        guard let adresEmail = user.profile.email,
              let imieUzytkownika = user.profile.givenName,
              let nazwiskoUzytkownika = user.profile.familyName else {
                return
        }
        
        guard let uzytkownik = user else {
            return
        }
        
        print("Zalogowano dla \(uzytkownik )")
        
        DatabaseService.shared.czyUzytkownikIstnieje(with: adresEmail) { istnieje in
            if !istnieje {
                DatabaseService.shared.utworzUzytkownika(with: ObiektUzytkownika(imie: imieUzytkownika,
                                                                                 nazwisko: nazwiskoUzytkownika,
                                                                                 adresEmail: adresEmail))
            }
        }
        
        guard let authentication = user.authentication else {
            return
        }
        let daneLogowania = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: daneLogowania) { (authResult, error) in
            guard authResult != nil, error == nil else {
                print("Nie udało się zalogować kontem GOOGLe")
                return
            }
            
            print("Zalogowano kontem Google")
            NotificationCenter.default.post(name: .zalogowanoPowiadomienie, object: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Konto Google wylogowane")
    }
    

}
    
