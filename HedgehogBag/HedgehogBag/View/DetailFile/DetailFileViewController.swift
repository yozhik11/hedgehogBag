import UIKit
import WebKit
import PDFKit


protocol DetailFileViewControllerDelegate: AnyObject {
    func makeReloadData()
}

class DetailFileViewController: UIViewController{
    
    // MARK: - Variables
    var detailViewModel: DetailViewModelProtocol = DetailViewModel()
    private var fileExtension = ""
    private var filePathWithoutName = ""
    private var flagAction = false
    private var mimeType: String?
    weak var delegate: DetailFileViewControllerDelegate?
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var fileView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var createdLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.textFont
        label.textColor = Constants.Colors.blackColor
        return label
    }()
    
    private lazy var shareAppButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrowshape.turn.up.right"), for: .normal)
        button.addTarget(self, action: #selector(shareAppButtonTarget), for: .touchUpInside)
        button.tintColor = Constants.Colors.brownColor
        return button
    }()
    
    private lazy var shareLinkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "link"), for: .normal)
        button.addTarget(self, action: #selector(shareLinkButtonTarget), for: .touchUpInside)
        button.tintColor = Constants.Colors.brownColor
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.addTarget(self, action: #selector(deleteButtonTarget), for: .touchUpInside)
        button.tintColor = Constants.Colors.brownColor
        return button
    }()
    
    private var buttonStackView = UIStackView()
    
    // MARK: - File reader views
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.clipsToBounds = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.scrollView.delegate = nil
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false
        webView.contentMode = .scaleAspectFit
        return webView
    }()

    private lazy var pdfView: PDFView = {
        let pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        pdfView.displayMode = .singlePageContinuous
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        return pdfView
    }()
    
//MARK: - viewDidLoad with bindAndFire
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        
        detailViewModel.file.bindAndFire { [weak self] file in
            guard let file = file else {
                self?.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertNoFiles)
                return
            }
            self?.setFile(file: file)
            self?.mimeType = file.mime_type
        }
        
        detailViewModel.hrefData.bind { [weak self] urlData in
            guard let urlData = urlData else {
                self?.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertNoHrefFile)
                return
            }
            self?.setImage(url: urlData.imgUrl)
        }
        
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.tintColor = Constants.Colors.blackColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(renameButtonAction))
    }

    //MARK: - @objc Actions
    @objc func renameButtonAction() {
        guard !flagAction else { return }
        
        let name = detailViewModel.file.value?.name ?? ""
        let pointIndex = (name.lastIndex(of: ".") ?? name.endIndex)
        let withoutExtension = String(name[..<pointIndex])
        self.fileExtension = String(name[pointIndex...])
        
        let alertController = UIAlertController(title: Constants.Texts.alertRename, message: "", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: Constants.Texts.alertCancel, style: .cancel, handler: nil)
        let okButton = UIAlertAction(title: Constants.Texts.alertOk, style: .default) { [weak self] _ in
            self?.rename(to: alertController.textFields?.first?.text ?? "")
        }
        alertController.addTextField{ textField in
            textField.text = withoutExtension
        }
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func shareAppButtonTarget() {
        guard !flagAction else { return }
        guard let file = imageView.image else { return }
        let shareView = UIActivityViewController(activityItems: [file], applicationActivities: nil)

        self.present(shareView, animated: true)
    }
    
    @objc func shareLinkButtonTarget() {
        guard !flagAction else { return }
        let _ = ActivityIndicator.shared.customActivityIndicatory(self.imageView, startAnimate: true)
        
        detailViewModel.getURLFiles(downloadOrShare: false) { result in
            if result != nil {
                guard let link = result else { return }
                UIPasteboard.general.string = link
                DispatchQueue.main.async {
                    self.alertOk(title: "", message: Constants.Texts.alertLinkCopied)
                }
            } else {
                self.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertLinkNoCopied)
            }

            DispatchQueue.main.async {
                let _ = ActivityIndicator.shared.customActivityIndicatory(self.imageView, startAnimate: false)
            }
        }
    }
    
    @objc func deleteButtonTarget() {
        guard !flagAction else { return }
        flagAction = true
        self.alertWithCancel(title: Constants.Texts.alertDelete, message: Constants.Texts.alertDeleteQuest) {
            self.detailViewModel.deleteFile { flag in
                self.flagAction = false
                switch flag {
                case true :
                    DispatchQueue.main.async {
                        self.alertDismiss(title: Constants.Texts.alertOk, message: Constants.Texts.alertDeleted) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                case false:
                    DispatchQueue.main.async {
                        self.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertUnavailable)
                    }
                }
            }
        }
    }
    
    private func rename (to: String) {
        flagAction = true
        var newName = to.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        guard let temp = newName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              !temp.isEmpty else { return }
        newName += self.fileExtension
        if newName == self.detailViewModel.file.value?.name { return }
        
        let _ = ActivityIndicator.shared.customActivityIndicatory(self.imageView, startAnimate: true)
        detailViewModel.setNewFileName(newName: newName) { [weak self] yesOrNot in
            guard let self = self else { return }
            switch yesOrNot {
            case true:
                DispatchQueue.main.async {
                    self.title = newName
                    self.delegate?.makeReloadData()
                    let _ = ActivityIndicator.shared.customActivityIndicatory(self.imageView, startAnimate: false)
                }
            case false:
                DispatchQueue.main.async {
                    self.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertUnavailable)
                    let _ = ActivityIndicator.shared.customActivityIndicatory(self.imageView, startAnimate: false)
                }
            }
            self.flagAction = false
        }
    }
    
    //MARK: - Save data from model to label
    private func setFile(file: FilesModelJSON) {
        title = file.name
        guard let createdFile = file.created else { return }
        createdLabel.text = createdFile.toDate().toString(dateFormat: "dd.MM.yy HH:mm")
    }
    
    //MARK: - Show differents files
    private func setImage(url: String) {
        if let mime = mimeType {
            let slashIndex = (mime.lastIndex(of: "/") ?? mime.endIndex)
            let fileMimeType = String(mime[...slashIndex])
            
            if fileMimeType == "image/" {
                imageIsImage(url: url)
            } else if mime == "application/pdf" {
                imageIsDoc(url: url)
            } else if fileMimeType == "application/" || fileMimeType ==  "text/" {
                imageIsDoc(url: url, mimeType: mime)
            } else {
                self.alertOk(title: Constants.Texts.alertError, message: Constants.Texts.alertCantReadFile)
            }
        }
    }
    
    private func imageIsImage(url: String) {
        DispatchQueue.main.async {
            let _ = ActivityIndicator.shared.customActivityIndicatory(self.view, startAnimate: true)
        }
        detailViewModel.getDetailImage(stringUrl: url) { [weak self] image in
            guard let self = self else { return }
            self.imageView.image = image
            self.addToFileView(view: self.imageView)
            let _ = ActivityIndicator.shared.customActivityIndicatory(self.view, startAnimate: false)
        }
    }

    private func imageIsDoc(url: String, mimeType: String? = nil) {
        DispatchQueue.main.async {
            let _ = ActivityIndicator.shared.customActivityIndicatory(self.view, startAnimate: true)
        }
        detailViewModel.getDetailFile(stringUrl: url) { [weak self] data in
            guard let self = self, let data = data else { return }
            
            if mimeType != nil {
                guard let mimeType = mimeType else { return }
                DispatchQueue.main.async {
                    self.webView.load(data, mimeType: mimeType, characterEncodingName: "UTF-8", baseURL: Bundle.main.bundleURL)
                    self.addToFileView(view: self.webView)
                }
            } else {
                DispatchQueue.main.async {
                    self.pdfView.document = PDFDocument(data: data)
                    self.addToFileView(view: self.pdfView)
                }
            }
            
            let _ = ActivityIndicator.shared.customActivityIndicatory(self.view, startAnimate: false)
        }
    }
    
    private func addToFileView(view: UIView) {
        fileView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
            view.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor),
            view.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor)
        ])
    }
    
    //MARK: - setupViews
    private func setupViews() {
        buttonStackView = UIStackView(arrangedSubviews:
                                        [deleteButton,
                                         shareLinkButton,
                                         shareAppButton],
                                      axis: .horizontal,
                                      spacing: view.layer.bounds.size.width / 4)
        
        view.addSubview(scrollView)
        scrollView.addSubview(fileView)
        view.addSubview(createdLabel)
        view.addSubview(buttonStackView)
        view.backgroundColor = .white
    }
    
    //MARK: - setupConstraints
    private func setupConstraints() {
        createdLabel.font = UIFont.systemFont(ofSize: 11)
        
        fileView.translatesAutoresizingMaskIntoConstraints = false
        createdLabel.translatesAutoresizingMaskIntoConstraints = false
        shareAppButton.translatesAutoresizingMaskIntoConstraints = false
        shareLinkButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            fileView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            fileView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            fileView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            fileView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            createdLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 85),
            createdLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70)
        ])
    }
}
