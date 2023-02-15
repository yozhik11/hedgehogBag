import UIKit

class PublicViewController: UITableViewController {
    
    private var isFirst = true
    private var isInternet = true
    private var countOfRow = 0
    private var isPagination = false
    private var token: String = ""
    private let fileCellId = "PublicFileViewCell"
        
    var viewModel: PublicViewModelProtocol = ProfileViewModel()
    private var modelForPagination: FilesModelJSON?
    private var titleNavBar = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        self.refrechControl(action: #selector(self.updateData))
        
        viewModel.publicFiles.bindAndFire { [weak self] files in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.navigationController?.navigationBar.topItem?.title = self?.viewModel.titleNavBar
            }
        }
        
//        viewModel.allFilesCoreData.bindAndFire { [weak self] files in
//            print("lastFilesCoreData", files.count)
//            if files.isEmpty {
//                self?.alertOk(title: "Ups", message: "Error with file")
//            }
//            DispatchQueue.main.async {
//                self?.tableView.reloadData()
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        updateData()
    }
    
    private func setupViews() {
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .white
        tableView.register(PublicFileViewCell.self, forCellReuseIdentifier: fileCellId)
    }
    
    func refrechControl(action: Selector) {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: action, for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func updateData() {
        let isRootDir = viewModel.isRootDir
        isRootDir.isEmpty ? loadData(path: "") : loadData(path: isRootDir)
    }
    
    private func loadData(path: String) {
        guard let tok = KeychainManager().tryReadToken() else {
            let requestAuthViewController = AuthViewController()
            requestAuthViewController.delegate = self
            present(requestAuthViewController, animated: false, completion: nil)
            return
        }
        self.token = tok
        let _ = ActivityIndicator.shared.customActivityIndicatory(self.tableView, startAnimate: true)
        viewModel.getPublicFiles(token: self.token, path: path) { success in
            switch success {
            case .none:
                self.isInternet = true
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    let _ = ActivityIndicator.shared.customActivityIndicatory(self.tableView, startAnimate: false)
                    self.tableView.refreshControl?.endRefreshing()
                }
            case .some(let yesOrNo):
                if yesOrNo {
                    self.countOfRow = self.viewModel.publicFiles.value.count <= 15 ? self.viewModel.publicFiles.value.count : 10
                    self.isInternet = true
                    DispatchQueue.main.async {
                        self.tableView.tableHeaderView = nil
                        let _ = ActivityIndicator.shared.customActivityIndicatory(self.tableView, startAnimate: false)
                        self.tableView.refreshControl?.endRefreshing()
                    }
                } else {
                    print("Public: нет сети, тянем из кордаты")
                    self.isInternet = false
                    self.loadDataFromCoreData(path: path)
                }
            }
        }
    }
    
    private func loadDataFromCoreData(path: String) {
        viewModel.getPublicFilesFromCoreData(path: path) { success in
            switch success {
            case true:
                print("All: в кордата че-то есть, показываем")
                self.countOfRow = self.viewModel.publicFilesCoreData.value.count <= 15 ? self.viewModel.publicFilesCoreData.value.count : 10
            case false:
                DispatchQueue.main.async {
                    self.alertOk(title: Constants.Texts.alertError,
                                 message: Constants.Texts.alertNoPublicFiles)
                }
                print("All: а кордата тоже пустая, упс")
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > tableView.contentSize.height-50 - scrollView.frame.size.height {
            guard !self.isPagination else{
                return
            }
            
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
                    print("All: error", error)
                }
            }
        }
    }
    
    private func pagination(pagination: Bool = false, completion: @escaping (Result<Int, Error>) -> Void) {
        if pagination {
            isPagination = true
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
            var modelMinusCount = 0
            
            if self.isInternet {
                modelMinusCount = self.viewModel.publicFiles.value.count - self.countOfRow
            } else {
                modelMinusCount = self.viewModel.publicFilesCoreData.value.count - self.countOfRow
            }
            
            completion(.success(pagination ?
                                (self.countOfRow + (modelMinusCount >= 10 ? 10 : modelMinusCount)) : self.countOfRow))
            
            if pagination {
                self.isPagination = false
            }
        })
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        66
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countOfRow
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: fileCellId, for: indexPath)
        if self.isInternet {
            let file = viewModel.publicFiles.value[indexPath.row]
            if let fileCell = cell as? PublicFileViewCell {
                fileCell.delegate = self
                fileCell.configure(file, token: token)
            }
        } else {
            let file = viewModel.publicFilesCoreData.value[indexPath.row]
            if let fileCell = cell as? PublicFileViewCell {
//                fileCell.configureCoreData(file)
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailPublicViewController = DetailFileViewController()
        if self.isInternet {
            let file = viewModel.publicFiles.value[indexPath.row]
            if file.type == "dir" {
                guard let pathFile = file.path else { return }
                let newFolderViewController = AllFilesViewController()
                newFolderViewController.viewModel.titleNavBar = file.name ?? ""
                newFolderViewController.viewModel.getAllFilesFromYa(token: token, path: pathFile){ [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case true:
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(newFolderViewController, animated: true)
                        }
                    case false: print("NOOOOOOOOOOOOOO")
                    }
                }
            } else {
                detailPublicViewController.detailViewModel.getFileDetail(token: token, file: file)
                navigationController?.pushViewController(detailPublicViewController, animated: true)
            }
        } else {
            self.alertOk(title: "Ой!", message: "Тут будет подгрузка файла из кэша")
        }
    }
}

extension PublicViewController: AuthViewControllerDelegate {
    
    func trySaveToken(token: String) {
        do {
            try KeychainManager.saveToken(token: token)
            updateData()
        } catch {
            print("Auth KeychainManager error", error)
        }
    }
}

extension PublicViewController: PublicFileViewCellDelegate {
    func makeReloadData() {
        updateData()
    }
}
