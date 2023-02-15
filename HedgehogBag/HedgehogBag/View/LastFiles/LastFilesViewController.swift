import UIKit
import CoreData

class LastFilesViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    private var isFirst = true
    private var isInternet = true
    private var countOfRow = 0
    private var isPagination = false
    //    private var token: String = "y0_AgAAAAAAUD6AAAhe5gAAAADPBqjBiirnJCdTTNeJ4WANLxKNtHkxD74"
    private var token: String = ""
    private let fileCellId = "FileTableViewCell"
    
    private var viewModel: LastFilesViewModelProtocol = LastFilesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        self.refrechControl(action: #selector(self.updateData))
        
        viewModel.lastFiles.bindAndFire { [weak self] files in
            if files.isEmpty {
                self?.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertNoFiles)
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.lastFilesCoreData.bindAndFire { [weak self] files in
            if files.isEmpty {
                self?.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertNoConnect)
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser() {
            let onboard = OnboardingViewController()
            onboard.modalPresentationStyle = .fullScreen
            present(onboard, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = Constants.Texts.navLastFiles
        
//        updateData()
    }
    
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            if isFirst {
                updateData()
            }
            isFirst = false
        }
    
    @objc func updateData() {
        guard let tok = KeychainManager().tryReadToken() else {
            let requestAuthViewController = AuthViewController()
            requestAuthViewController.delegate = self
            present(requestAuthViewController, animated: false, completion: nil)
            return
        }
        self.token = tok
        let _ = ActivityIndicator.shared.customActivityIndicatory(self.tableView, startAnimate: true)
        
        viewModel.getLastFilesFromYa(token: self.token) { success in
            switch success {
            case true:
                DispatchQueue.main.async {
                    self.tableView.tableHeaderView = nil
                }
                
                self.countOfRow = self.viewModel.lastFiles.value.count <= 15 ? self.viewModel.lastFiles.value.count : 10
                self.isInternet = true
                DispatchQueue.main.async {
                    let _ = ActivityIndicator.shared.customActivityIndicatory(self.tableView, startAnimate: false)
                    self.tableView.refreshControl?.endRefreshing()
                }
            case false:
                //                DispatchQueue.main.async {
                //                    self.tableView.tableHeaderView = self.noInternetView()
                //                }
                
                self.isInternet = false
                self.loadDataFromCoreData()
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isPagination else { return }
        
        let position = scrollView.contentOffset.y
        if position > tableView.contentSize.height-50 - scrollView.frame.size.height {
            
            self.tableView.tableFooterView = self.spinnerFooterView()
            
            pagination(pagination: true) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.tableView.tableFooterView = nil
                }
                switch result{
                case .success(let newCount):
                    self.countOfRow = newCount
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print("error", error)
                }
            }
        }
    }

    // MARK: - Table
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        66
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countOfRow
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: fileCellId, for: indexPath)
        
        if self.isInternet {
            let file = viewModel.lastFiles.value[indexPath.row]
            if let fileCell = cell as? FileTableViewCell {
                fileCell.configure(file, token: token)
            }
        } else {
            let file = viewModel.lastFilesCoreData.value[indexPath.row]
            if let fileCell = cell as? FileTableViewCell {
                fileCell.configureCoreData(file)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailFileViewController = DetailFileViewController()
        if self.isInternet {
            let file = viewModel.lastFiles.value[indexPath.row]
            detailFileViewController.delegate = self
            detailFileViewController.detailViewModel.getFileDetail(token: token, file: file)
            navigationController?.pushViewController(detailFileViewController, animated: true)
        } else {
            self.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertUnableView)
        }
    }
}

extension LastFilesViewController: AuthViewControllerDelegate {
    func trySaveToken(token: String) {
        do {
            try KeychainManager.saveToken(token: token)
            updateData()
        } catch {
            print("Auth KeychainManager error", error)
        }
    }
}

extension LastFilesViewController: DetailFileViewControllerDelegate {
    func makeReloadData() {
        updateData()
    }
}

extension LastFilesViewController {
    private func setupViews() {
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .white
        tableView.register(FileTableViewCell.self, forCellReuseIdentifier: fileCellId)
    }
    
    private func refrechControl(action: Selector) {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: action, for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func loadDataFromCoreData() {
        viewModel.getLastFilesFromCoreData() { success in
            switch success {
            case true:
                self.countOfRow = self.viewModel.lastFilesCoreData.value.count <= 15 ? self.viewModel.lastFilesCoreData.value.count : 10
            case false:
                DispatchQueue.main.async {
                    self.alertOk(title: Constants.Texts.alertError,
                                 message: Constants.Texts.alertNoConnect)
                }
            }
            DispatchQueue.main.async {
                let _ = ActivityIndicator.shared.customActivityIndicatory(self.tableView, startAnimate: false)
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.tableHeaderView = self.noInternetView()
            }
        }
    }
    
    private func noInternetView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        headerView.backgroundColor = .systemRed
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        label.text = Constants.Texts.labelNoInternet
        label.textAlignment = .center
        label.textColor = .white
        headerView.addSubview(label)
        return headerView
    }
    
    private func spinnerFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    private func pagination(pagination: Bool = false, completion: @escaping (Result<Int, Error>) -> Void) {
        if pagination, !isPagination {
            isPagination = true
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
            var modelMinusCount = 0
            if self.isInternet {
                modelMinusCount = self.viewModel.lastFiles.value.count - self.countOfRow
            } else {
                modelMinusCount = self.viewModel.lastFilesCoreData.value.count - self.countOfRow
            }
            
            completion(.success(pagination ?
                                (self.countOfRow + (modelMinusCount >= 10 ? 10 : modelMinusCount)) : self.countOfRow))
            
            if pagination {
                self.isPagination = false
            }
        })
    }
}
