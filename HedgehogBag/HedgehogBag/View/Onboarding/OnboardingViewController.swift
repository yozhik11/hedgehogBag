import UIKit

class OnboardingViewController: UIViewController{

    private let scrollView = UIScrollView()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 3
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        scrollView.delegate = self
        pageControl.addTarget(self,
                              action: #selector(pageControlDidChange),
                              for: .valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configure()
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let current = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: CGFloat(current) * view.frame.size.width, y: 0), animated: true)
    }
    
    func configure() {
        scrollView.frame = view.bounds
        scrollView.isPagingEnabled = true
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        
        pageControl.frame = CGRect(x: 10,
                                   y: view.frame.size.height - 250,
                                   width: view.frame.size.width - 40,
                                   height: 70)
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .brown
        
        let titles = [Constants.Texts.onboarding1,
                      Constants.Texts.onboarding2,
                      Constants.Texts.onboarding3]
        
        for pageNumber in 0...2 {
            let pageView = UIView(frame: CGRect(x: CGFloat(pageNumber) * view.frame.size.width,
                                                y: 0,
                                                width: view.frame.size.width,
                                                height: view.frame.size.height))
            scrollView.addSubview(pageView)
            
            let label = UILabel(frame: CGRect(x: 10,
                                              y: 340,
                                              width: pageView.frame.size.width - 20,
                                              height: 120))

            let imageView = UIImageView(frame: CGRect(x: CGFloat(view.frame.size.width / 2 - 100),
                                                      y: 140,
                                                      width: 200,
                                                      height: 200))

            let button = UIButton(frame: CGRect(x: 10,
                                                y: pageView.frame.size.height - 150,
                                                width: pageView.frame.size.width - 20,
                                                height: 50))
            label.textAlignment = .center
            label.numberOfLines = 2
            label.font = Constants.Fonts.headerFont
            pageView.addSubview(label)
            label.text = titles[pageNumber]
            
            imageView.contentMode = .scaleAspectFit
            switch pageNumber {
            case 0: imageView.image = Constants.Images.allFiles
            case 1: imageView.image = Constants.Images.download
            default: imageView.image = Constants.Images.share
            }
            pageView.addSubview(imageView)
            
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .brown
            button.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
            button.tag = pageNumber + 1
            if pageNumber == 2 {
                button.setTitle(NSLocalizedString("Login", comment: ""), for: .normal)
            }
            
            button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
            pageView.addSubview(button)
        }
        scrollView.contentSize = CGSize(width: view.frame.size.width * 3, height: 300)
    }
    
    @objc func didTapButton(_ button: UIButton) {
        guard button.tag < 3 else {
            Core.shared.setIsNotNewUser()
            dismiss(animated: true, completion: nil)
            return
        }
        scrollView.setContentOffset(CGPoint(x: Int(view.frame.size.width) * button.tag, y: 0), animated: true)
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floorf(Float(scrollView.contentOffset.x / scrollView.frame.size.width)))
    }
}
