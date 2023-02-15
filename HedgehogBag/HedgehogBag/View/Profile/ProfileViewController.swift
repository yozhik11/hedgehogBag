import UIKit

class ProfileViewController: UIViewController {
    
    private var profileViewModel: ProfileViewModelProtocol = ProfileViewModel()
    private let pieChartView = PieChartView()
    private var isInternet = true
    
    private lazy var noInternetLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemRed
        label.text = Constants.Texts.labelNoInternet
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var exitAccountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(Constants.Colors.greyColor, for: .normal)
        button.setTitleColor(Constants.Colors.lightGreyColor, for: .highlighted)
        button.setTitle(Constants.Texts.buttonLogout, for: .normal)
        button.addTarget(self, action: #selector(exitAccountButtonTarget), for: .touchUpInside)
        return button
    }()
    
    private lazy var publicFilesButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.Texts.buttonPublic, for: .normal)
        button.setTitleColor(Constants.Colors.blackColor, for: .highlighted)
        button.setTitleColor(Constants.Colors.greyColor, for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = Constants.Colors.greyColor.cgColor
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(publicFilesButtonTarget), for: .touchUpInside)
        return button
    }()
    
    private func spaceLabel() -> UILabel {
        let label = UILabel()
        label.font = Constants.Fonts.textFont
        label.textColor = Constants.Colors.blackColor
        return label
    }
    
    private lazy var freeSpaceLabel = spaceLabel()
    private lazy var usedSpaceLabel = spaceLabel()
    private lazy var trashSpaceLabel = spaceLabel()
    
    private func newCircle (color: UIColor) -> UIView {
        let view = UILabel()
        view.backgroundColor = color
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        return view
    }
    private lazy var usedCircle  = newCircle(color: Constants.Colors.spaceUsedColor)
    private lazy var trashCircle = newCircle(color: Constants.Colors.spaceTrashColor)
    private lazy var freeCircle  = newCircle(color: Constants.Colors.spaceFreeColor)
    
    private lazy var totalCircleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.textFont
        label.textColor = Constants.Colors.blackColor
        label.textAlignment = .center
        label.backgroundColor = .white
        label.layer.masksToBounds = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        
        profileViewModel.profileInfo.bind { [weak self] info in
            guard let info = info else {
                self?.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertNoHrefFile)
                return
            }
            self?.setUIData(info: info)
        }
        
        profileViewModel.profileInfoCoreData.bind { [weak self] info in
            guard let info = info else {
                self?.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertNoHrefFile)
                return
            }
            self?.setUICoreData(info: info)
        }
        
        self.navigationController?.navigationBar.topItem?.title = Constants.Texts.navProfile
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let tok = KeychainManager().tryReadToken() else {
            self.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertNoSaveToken)
            return
        }
        profileViewModel.getProfileInfo(token: tok) { result in
            switch result {
            case true:
                self.isInternet = true
                DispatchQueue.main.async {
                    self.noInternetLabel.isHidden = true
                }
            case false:
                self.isInternet = false
                DispatchQueue.main.async {
                    self.noInternetLabel.isHidden = false
                }
                self.profileViewModel.getProfileInfoFromCoreData { result in
                    switch result {
                    case true:
                        print("no inet, yes cordata")
                    case false: self.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertNoHrefFile)
                    }
                }
            }
        }
    }
    
    @objc func exitAccountButtonTarget() {
        if isInternet {
            self.alertWithCancel(title: Constants.Texts.alertLogout,
                                 message: Constants.Texts.alertLogoutQuest) {
                do {
                    try KeychainManager().deleteToken()
                    self.navigationController?.popToRootViewController(animated: true)
                } catch {
                    print("delete Token error: ", error)
                }
            }
        } else {
            self.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertNoConnect)
        }
    }
    
    @objc func publicFilesButtonTarget() {
        guard let tok = KeychainManager().tryReadToken() else {
            return
        }
        
        let publicViewController = PublicViewController()
        publicViewController.viewModel.titleNavBar = Constants.Texts.buttonPublic
        publicViewController.viewModel.getPublicFiles(token: tok, path: "disk:/"){ [weak self] result in
            guard let self = self else { return }
            switch result {
            case .none:
                DispatchQueue.main.async {
                    self.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertNoPublicFiles)
                }
            case .some(let yesOrNo):
                if yesOrNo {
                    self.isInternet = true
                } else {
                    self.isInternet = false
                }
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(publicViewController, animated: true)
                }
            }
        }
    }
    
    private func setUIData(info: ProfileModel) {
        DispatchQueue.main.async {
            self.setUI(total: info.totalSpace ?? 0, used: info.usedSpace ?? 0, trash: info.trash ?? 0)
        }
    }
    
    private func setUICoreData(info: ProfileData) {
        DispatchQueue.main.async {
            self.setUI(total: info.totalSpace, used: info.usedSpace, trash: info.trash)
        }
    }
    
    private func setUI(total: Int64, used: Int64, trash: Int64) {
        self.pieChartView.segments = [
            Segment(color: Constants.Colors.spaceFreeColor,
                    value: CGFloat(total - used - trash)),
            Segment(color: Constants.Colors.spaceUsedColor,
                    value: CGFloat(used)),
            Segment(color: Constants.Colors.spaceTrashColor,
                    value: CGFloat(trash)),
        ]
        self.setupPieViews()
        self.setupPieConstraints()
        
        self.totalCircleLabel.text = Constants.Texts.textTotal + Functions().spaceInString(size: total)
        self.usedSpaceLabel.text = Constants.Texts.textUsed + Functions().spaceInString(size: used)
        self.trashSpaceLabel.text = Constants.Texts.textTrash + Functions().spaceInString(size: trash)
        self.freeSpaceLabel.text = Constants.Texts.textFree + Functions().spaceInString(size: total - used - trash)
    }
    
    private func setupPieViews() {
        view.addSubview(pieChartView)
        view.addSubview(totalCircleLabel)
    }
    
    private func setupPieConstraints() {
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        totalCircleLabel.translatesAutoresizingMaskIntoConstraints = false
        totalCircleLabel.layer.cornerRadius = 100
        
        NSLayoutConstraint.activate([
        pieChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        pieChartView.topAnchor.constraint(equalTo: view.topAnchor, constant: 270),
        pieChartView.widthAnchor.constraint(equalToConstant: 300),
        pieChartView.heightAnchor.constraint(equalToConstant: 300),
        
        totalCircleLabel.centerXAnchor.constraint(equalTo: pieChartView.centerXAnchor),
        totalCircleLabel.centerYAnchor.constraint(equalTo: pieChartView.centerYAnchor),
        totalCircleLabel.heightAnchor.constraint(equalToConstant: 200),
        totalCircleLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(noInternetLabel)
        view.addSubview(exitAccountButton)
        view.addSubview(publicFilesButton)
        view.addSubview(usedSpaceLabel)
        view.addSubview(trashSpaceLabel)
        view.addSubview(freeSpaceLabel)
        
        view.addSubview(usedCircle)
        view.addSubview(trashCircle)
        view.addSubview(freeCircle)
    }

    private func setupConstraints() {
        publicFilesButton.translatesAutoresizingMaskIntoConstraints = false
        exitAccountButton.translatesAutoresizingMaskIntoConstraints = false
        usedSpaceLabel.translatesAutoresizingMaskIntoConstraints = false
        trashSpaceLabel.translatesAutoresizingMaskIntoConstraints = false
        freeSpaceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        usedCircle.translatesAutoresizingMaskIntoConstraints = false
        trashCircle.translatesAutoresizingMaskIntoConstraints = false
        freeCircle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noInternetLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 98),
            noInternetLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noInternetLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            noInternetLabel.heightAnchor.constraint(equalToConstant: 30),
                        
            usedCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            usedCircle.topAnchor.constraint(equalTo: noInternetLabel.bottomAnchor, constant: 16),
            usedCircle.widthAnchor.constraint(equalToConstant: 20),
            usedCircle.heightAnchor.constraint(equalToConstant: 20),
            
            usedSpaceLabel.centerYAnchor.constraint(equalTo: usedCircle.centerYAnchor),
            usedSpaceLabel.leadingAnchor.constraint(equalTo: usedCircle.trailingAnchor, constant: 8),
            
            trashCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trashCircle.topAnchor.constraint(equalTo: usedCircle.bottomAnchor, constant: 8),
            trashCircle.widthAnchor.constraint(equalToConstant: 20),
            trashCircle.heightAnchor.constraint(equalToConstant: 20),
            
            trashSpaceLabel.centerYAnchor.constraint(equalTo: trashCircle.centerYAnchor),
            trashSpaceLabel.leadingAnchor.constraint(equalTo: trashCircle.trailingAnchor, constant: 8),
            
            freeCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            freeCircle.topAnchor.constraint(equalTo: trashCircle.bottomAnchor, constant: 8),
            freeCircle.widthAnchor.constraint(equalToConstant: 20),
            freeCircle.heightAnchor.constraint(equalToConstant: 20),
            
            freeSpaceLabel.centerYAnchor.constraint(equalTo: freeCircle.centerYAnchor),
            freeSpaceLabel.leadingAnchor.constraint(equalTo: freeCircle.trailingAnchor, constant: 8),
                        
            publicFilesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            publicFilesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            publicFilesButton.widthAnchor.constraint(equalToConstant: 300),
            publicFilesButton.heightAnchor.constraint(equalToConstant: 50),
            
            exitAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exitAccountButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }
}
