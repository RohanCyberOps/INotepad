import UIKit

class FileBrowserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    var files: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFiles()
    }

    func setupUI() {
        title = "Files"
        view.backgroundColor = .white

        // Add "New File" button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewFile))

        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func loadFiles() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            files = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            tableView.reloadData()
        } catch {
            print("Failed to load files: \(error.localizedDescription)")
        }
    }

    @objc func createNewFile() {
        let alert = UIAlertController(title: "New File", message: "Enter file name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "File name"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            if let fileName = alert.textFields?.first?.text, !fileName.isEmpty {
                self.openFile(fileName: fileName)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func openFile(fileName: String) {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        let editorVC = EditorViewController(fileURL: fileURL)
        navigationController?.pushViewController(editorVC, animated: true)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = files[indexPath.row].lastPathComponent
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileURL = files[indexPath.row]
        let editorVC = EditorViewController(fileURL: fileURL)
        navigationController?.pushViewController(editorVC, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fileURL = files[indexPath.row]
            do {
                try FileManager.default.removeItem(at: fileURL)
                files.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Failed to delete file: \(error.localizedDescription)")
            }
        }
    }
}
