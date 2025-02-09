import UIKit

class EditorViewController: UIViewController {

    let textView = UITextView()
    let fileURL: URL
    let undoButton = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.backward"), style: .plain, target: nil, action: nil)
    let redoButton = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.forward"), style: .plain, target: nil, action: nil)

    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFile()
    }

    func setupUI() {
        title = fileURL.lastPathComponent
        view.backgroundColor = .white

        // Configure text view
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add formatting toolbar
        let boldButton = UIBarButtonItem(image: UIImage(systemName: "bold"), style: .plain, target: self, action: #selector(applyBold))
        let italicButton = UIBarButtonItem(image: UIImage(systemName: "italic"), style: .plain, target: self, action: #selector(applyItalic))
        let underlineButton = UIBarButtonItem(image: UIImage(systemName: "underline"), style: .plain, target: self, action: #selector(applyUnderline))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        undoButton.target = textView.undoManager
        undoButton.action = #selector(UndoManager.undo)
        redoButton.target = textView.undoManager
        redoButton.action = #selector(UndoManager.redo)

        toolbarItems = [undoButton, redoButton, flexibleSpace, boldButton, italicButton, underlineButton]
        navigationController?.setToolbarHidden(false, animated: true)

        // Save button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveFile))
    }

    func loadFile() {
        do {
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            textView.text = text
        } catch {
            print("Failed to load file: \(error.localizedDescription)")
        }
    }

    @objc func saveFile() {
        do {
            try textView.text.write(to: fileURL, atomically: true, encoding: .utf8)
            showAlert(message: "File saved successfully!")
        } catch {
            showAlert(message: "Failed to save file: \(error.localizedDescription)")
        }
    }

    @objc func applyBold() {
        let range = textView.selectedRange
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 16)]
        applyAttributes(attributes, range: range)
    }

    @objc func applyItalic() {
        let range = textView.selectedRange
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.italicSystemFont(ofSize: 16)]
        applyAttributes(attributes, range: range)
    }

    @objc func applyUnderline() {
        let range = textView.selectedRange
        let attributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]
        applyAttributes(attributes, range: range)
    }

    func applyAttributes(_ attributes: [NSAttributedString.Key: Any], range: NSRange) {
        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        attributedText.addAttributes(attributes, range: range)
        textView.attributedText = attributedText
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Notepad", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
