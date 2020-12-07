
import Foundation

enum NetworkError: Error {
    case networkError
    case invalidResponse
    case imageError
}

import Foundation

final class NetworkService {
    private let session: URLSession
    
    private var baseURL: URL {
        return URL(string: "https://polar-peak-71928.herokuapp.com/api/user/")!
    }
    
    private var uploadURL: URL {
        return URL(string: "\(baseURL)upload")!
    }
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    
    func uploadImage(with image: UIImage,  onSuccess: @escaping () -> (Void), onError: @escaping (Error) -> Void) {
        makeUploadRequest(with: image, onSuccess: onSuccess, onError: onError)
    }
    
    private func makeUploadRequest(with image: UIImage, onSuccess: @escaping () -> (Void), onError: @escaping (Error) -> Void) {

        let fileName = "fileName.png"
        let paramName = "upload"

        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString

        let session = URLSession.shared

        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: uploadURL)
        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if error == nil {
                let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                if let json = jsonData as? [String: Any] {
                    print(json)
                    onSuccess()
                }
            } else {
                onError(error!)
            }
        }).resume()
    }

}
