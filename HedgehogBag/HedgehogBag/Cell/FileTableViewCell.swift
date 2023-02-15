import UIKit

final class FileTableViewCell: UITableViewCell {
    
    private var viewModel: LastFilesViewModelProtocol = LastFilesViewModel()
    
    private let photoImageView = UIImageView(image: Constants.Images.file)
    private let fileNameLabel = UILabel()
    private let fileSizeLabel = UILabel()
    private let fileDateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ model: FilesModelJSON, token: String) {
        guard let createdRes = model.created else { return }
        fileDateLabel.text = createdRes.toDate().toString(dateFormat: "dd.MM.yyyy")
        fileNameLabel.text = model.name
        
        if model.type == "dir" {
            fileSizeLabel.text = "--"
            photoImageView.image = Constants.Images.folder
        } else {
            guard let sizeFile = model.size else { return }
            fileSizeLabel.text = Functions().spaceInString(size: sizeFile)
            
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
    
    func configureAllCoreData(_ model: AllFilesModel) {
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
        
        fileSizeLabel.font = UIFont.systemFont(ofSize: 11)
        fileDateLabel.font = UIFont.systemFont(ofSize: 11)
        fileSizeLabel.textColor = Constants.Colors.greyColor
        fileDateLabel.textColor = Constants.Colors.greyColor
        fileNameLabel.textColor = Constants.Colors.blackColor
        
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        fileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        fileSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        fileDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            photoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            photoImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            photoImageView.widthAnchor.constraint(equalToConstant: 50),
            photoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            fileDateLabel.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            fileDateLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 16),
            
            fileNameLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 16),
            fileNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            fileNameLabel.topAnchor.constraint(equalTo: fileDateLabel.bottomAnchor, constant: 8),
            
            fileSizeLabel.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            fileSizeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
    }
}
