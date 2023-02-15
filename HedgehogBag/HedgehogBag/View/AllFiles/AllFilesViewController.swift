import UIKit

class AllFilesViewController: UITableViewController {
    
    private var isFirst = true
    private var isInternet = true
    private var countOfRow = 0
    private var isPagination = false
    private var token: String = ""
    private let fileCellId = "FileTableViewCell"
    
    var viewModel: AllFilesViewModelProtocol = AllFilesViewModel()
    private var modelForPagination: FilesModelJSON?
    private var titleNavBar = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        self.refrechControl(action: #selector(self.updateData))
        
        viewModel.allFiles.bindAndFire { [weak self] files in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.navigationController?.navigationBar.topItem?.title = self?.viewModel.titleNavBar
            }
        }
        
        viewModel.allFilesCoreData.bindAndFire { [weak self] files in
            print("allFilesCoreData", files.count)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            updateData()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if isFirst {
//            updateData()
//        }
//        isFirst = false
//    }
    
    private func setupViews() {
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .white
        tableView.register(FileTableViewCell.self, forCellReuseIdentifier: fileCellId)
    }
    
    func refrechControl(action: Selector) {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: action, for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func updateData() {
        let isRootDir = viewModel.isRootDir
        isRootDir.isEmpty ? loadData(path: "disk:/") : loadData(path: isRootDir)
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
        viewModel.getAllFilesFromYa(token: self.token, path: path) { success in
            switch success {
            case true:
                DispatchQueue.main.async {
                    self.tableView.tableHeaderView = nil
                }

                self.countOfRow = self.viewModel.allFiles.value.count <= 15 ? self.viewModel.allFiles.value.count : 10
                self.isInternet = true
                DispatchQueue.main.async {
                    let _ = ActivityIndicator.shared.customActivityIndicatory(self.tableView, startAnimate: false)
                    self.tableView.refreshControl?.endRefreshing()
                }
            case false:
                print("All: нет сети, тянем из кордаты")
                self.isInternet = false
                self.loadDataFromCoreData(path: path)
            }
        }
    }
    
    private func loadDataFromCoreData(path: String) {
        viewModel.getAllFilesFromCoreData(path: path) { success in
            switch success {
            case true:
                print("All: в кордата че-то есть, показываем ", self.viewModel.allFilesCoreData.value.count)
                self.countOfRow = self.viewModel.allFilesCoreData.value.count <= 15 ? self.viewModel.allFilesCoreData.value.count : 10
            case false:
                DispatchQueue.main.async {
                    self.alertOk(title: Constants.Texts.alertError,
                                 message: Constants.Texts.alertNoFiles)
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
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            var modelMinusCount = 0
            
            if self.isInternet {
                modelMinusCount = self.viewModel.allFiles.value.count - self.countOfRow
            } else {
                modelMinusCount = self.viewModel.allFilesCoreData.value.count - self.countOfRow
            }
            
            let resultCountsOfRows = pagination ?
            (self.countOfRow + (modelMinusCount >= 10 ? 10 : modelMinusCount)) : self.countOfRow
            
            completion(.success(resultCountsOfRows))
            
            if pagination {
                self.isPagination = false
            }
        }
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
        
        if isInternet {
            let file = viewModel.allFiles.value[indexPath.row]
            if let fileCell = cell as? FileTableViewCell {
                fileCell.configure(file, token: token)
            }
        } else {
            let file = viewModel.allFilesCoreData.value[indexPath.row]
            if let fileCell = cell as? FileTableViewCell {
                fileCell.configureAllCoreData(file)
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailFileViewController = DetailFileViewController()
        if isInternet {
            let file = viewModel.allFiles.value[indexPath.row]
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
                detailFileViewController.detailViewModel.getFileDetail(token: token, file: file)
                navigationController?.pushViewController(detailFileViewController, animated: true)
            }
        } else {
            let file = viewModel.allFilesCoreData.value[indexPath.row]
            if file.type == "dir" {
                guard let pathDir = file.path else { return }
                print("AVC 245 pathDir", pathDir)
                let newFolderViewController = AllFilesViewController()
                newFolderViewController.viewModel.titleNavBar = file.name ?? ""
                newFolderViewController.viewModel.getAllFilesFromCoreData(path: pathDir){ [weak self] result in
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
//                detailFileViewController.detailViewModel.getFileDetail(token: token, file: file)
//                navigationController?.pushViewController(detailFileViewController, animated: true)
                self.alertOk(title: "Ой!", message: "Тут будет подгрузка файла из кэша")
            }
            
        }
    }
}

extension AllFilesViewController: AuthViewControllerDelegate {
    
    func trySaveToken(token: String) {
        do {
            try KeychainManager.saveToken(token: token)
            updateData()
        } catch {
            print("Auth KeychainManager error", error)
        }
    }
}
