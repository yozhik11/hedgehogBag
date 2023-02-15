import UIKit

protocol PublicFileViewCellDelegate: AnyObject {
    func makeReloadData()
}

final class PublicFileViewCell: UITableViewCell {
    
    private var viewModel: LastFilesViewModelProtocol = LastFilesViewModel()
    private var publicViewModel: PublicViewModelProtocol = ProfileViewModel()
    weak var delegate: PublicFileViewCellDelegate?
    
    private var token = ""
    private var path = ""
    private let photoImageView = UIImageView(image: Constants.Images.file)
    private let fileNameLabel = UILabel()
    private let fileSizeLabel = UILabel()
    private let fileDateLabel = UILabel()
    private lazy var deletePublicLink: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "link"), for: .normal)
        button.layer.cornerRadius = 12
        button.backgroundColor = .black
        button.tintColor = .white
        button.addTarget(self, action: #selector(deletePublicLinkButtonTarget), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deletePublicLinkButtonTarget() {
        let _ = ActivityIndicator.shared.customActivityIndicatory(self.contentView, startAnimate: true)
        publicViewModel.deleteFileFromPublic(token: token, path: path) { flag in
            DispatchQueue.main.async {
                switch flag {
                case true:
                    print("true")
                    self.delegate?.makeReloadData()
                case false: print("false")
                }
                
                let _ = ActivityIndicator.shared.customActivityIndicatory(self.contentView, startAnimate: false)
            }
        }
    }
    
    func configure(_ model: FilesModelJSON, token: String) {
        self.token = token
        guard let createdRes = model.created else { return }
        fileDateLabel.text = createdRes.toDate().toString(dateFormat: "dd.MM.yyyy")
        fileNameLabel.text = model.name
        path = model.path ?? ""
        
        if model.type == "dir" {
            fileSizeLabel.text = "--"
            photoImageView.image = Constants.Images.folder
        } else {
            guard let sizeFile = model.size else { return }
            sizeFile <= 10000 ? (fileSizeLabel.text = String(format: "%.2f", (Double(sizeFile) / 1024.0)) + " КБ") : (fileSizeLabel.text = String(format: "%.2f", (Double(sizeFile) / 1024.0 / 1024.0)) + " МБ")
            
            if let previewFile = model.preview {
                let _ = ActivityIndicator.shared.customActivityIndicatory(self.photoImageView, startAnimate: true)
                viewModel.getImage(token: token, stringUrl: previewFile, completion: { [weak self] image in
                    guard let self = self else { return }
                    self.photoImageView.image = image
                    let _ = ActivityIndicator.shared.customActivityIndicatory(self.photoImageView, startAnimate: false)
                })
            } else {
                photoImageView.image = Constants.Images.file
            }
        }
    }
    
    func configureCoreData(_ model: FilesModel) {
        guard let createdRes = model.created else { return }
        fileDateLabel.text = createdRes.toDate().toString(dateFormat: "dd.MM.yyyy")
        fileNameLabel.text = model.name

        if model.type == "dir" {
            fileSizeLabel.text = "--"
            photoImageView.image = Constants.Images.folder
        } else {
            model.size <= 10000 ? (fileSizeLabel.text = String(format: "%.2f", (Double(model.size) / 1024.0)) + " КБ") : (fileSizeLabel.text = String(format: "%.2f", (Double(model.size) / 1024.0 / 1024.0)) + " МБ")

            if let image = model.preview {
                photoImageView.image = UIImage(data: image)
            } else {
                photoImageView.image = Constants.Images.file
            }
        }
    }
    
    override func prepareForReuse() {
        photoImageView.image = nil
        super.prepareForReuse()
    }
    
    // MARK: Private
    private func setupViews() {
        addSubview(photoImageView)
        addSubview(fileNameLabel)
        addSubview(fileSizeLabel)
        addSubview(fileDateLabel)
        //        addSubview(deletePublicLink)
        contentView.addSubview(deletePublicLink)
        
        fileSizeLabel.font = UIFont.systemFont(ofSize: 11)
        fileDateLabel.font = UIFont.systemFont(ofSize: 11)
        fileSizeLabel.textColor = Constants.Colors.greyColor
        fileDateLabel.textColor = Constants.Colors.greyColor
        fileNameLabel.textColor = Constants.Colors.blackColor
        
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        fileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        fileSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        fileDateLabel.translatesAutoresizingMaskIntoConstraints = false
        deletePublicLink.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            photoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            photoImageView.widthAnchor.constraint(equalToConstant: 50),
            photoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            fileDateLabel.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            fileDateLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 16),
            
            fileNameLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 16),
            fileNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -33),
            fileNameLabel.topAnchor.constraint(equalTo: fileDateLabel.bottomAnchor, constant: 8),
            
            fileSizeLabel.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            fileSizeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -41),
            
            deletePublicLink.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor),
            deletePublicLink.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            deletePublicLink.widthAnchor.constraint(equalToConstant: 25),
            deletePublicLink.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
}
