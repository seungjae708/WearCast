//
//  DbFirebase.swift
//  ch11-최승재-2071321-CityFirebase
//
//  Created by 최승재 on 5/11/25.
//
import Foundation
import FirebaseFirestore

class DbFirebase: Database{
    // 데이터를 저장할 위치 설정
    var reference: CollectionReference = Firestore.firestore().collection("recommendations")
    
    // 데이터의 변화가 생기면 알려쥐 위한 클로즈
    var parentNotification: (([String: Any]?, DbAction?) -> Void)?
    var existQuery: ListenerRegistration?     // 이미 설정한 Query의 존재여부
    
    required init(parentNotification: (([String : Any]?, DbAction?) -> Void)?) {
        // 클로저를 보관
        self.parentNotification = parentNotification
    }
    
    func saveChange(key: String, object: [String: Any], action: DbAction) {
        // 이러한 key에 대하여 데이터를 add, modify, delete를 하라는 것임
        if action == .detete {
            reference.document(key).delete()
            return
        }
        // key에 대한 데이터가 이미 있으면 overwrite, 없으면 insert
        reference.document(key).setData(object)
    }

    func setQuery(from: Any, to: Any) {
        // 아래에서 볼 수 있지만 쿼리는 add된다. 따라서 쿼리는 누적될 수 있다.
        if let query = existQuery {  // 이미 쿼리가 있으면 삭제한다
            query.remove()
        }
        // 새로운 쿼리를 설정한다. 원하는 필드, 원하는 데이터를 적절히 설정하면 된다
        let query = reference.whereField("id", isGreaterThanOrEqualTo: 0).whereField("id", isLessThanOrEqualTo: 10000)
        // 쿼리를 set하는 것이 아니라 add한다는 것을 알아야 한다.
        // query를 만족하는 데이터가 발생하면 onChangingData()함수를 호출하라는 것임
        existQuery = query.addSnapshotListener(onChangingData)
    }
    
    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?) {
        // 이것은 setQuery의 결과로 호출된다.
        // 당연히 스레드로 실행되므로 GUI를 변경하면 안된다.
        
        guard let querySnapshot = querySnapshot else { return }  // 이 경우는 발생하지 않음
        // setQuery의 쿼리를 만족하는 데이터가 없는 경우 count가 0이다.
        if (querySnapshot.documentChanges.count == 0) {
            return
        }
        
        // 쿼리를 만족하는 데이터가 많은 경우 속도 문제로 한꺼번에 여러 데이터가 온다
        for documentChange in querySnapshot.documentChanges {
            let dict = documentChange.document.data()  // 데이터를 가져옴
            var action: DbAction?
            
            switch(documentChange.type) {  // 단순히 DbAction으로 변환
            case .added: action = .add
            case .modified: action = .modify
            case .removed: action = .detete
            }
            
            // 부모에게 알림
            if let parentNotification = parentNotification {
                parentNotification(dict, action)
            }
        }
    }
}

import FirebaseStorage
extension DbFirebase{

  func uploadImage(imageName: String, image: UIImage){
    // uiimage를 jpeg 파일에 맞게 변형, png도 가능
    guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }

    // 파이어베이스내에 스토리지의 레퍼런스를 만든다
    let reference = Storage.storage().reference().child("recommendations").child(imageName)
    let metaData = StorageMetadata()  // 보내고자 하는 데이터에 대한 메타정보
    metaData.contentType = "image/jpeg" // 이것은 jpeg 데이터임을 표시
   
    // 여기서 업로드하여 저장한다
    reference.putData(imageData, metadata: metaData, completion: nil /* 할일이 없음*/)
  }

  func downloadImage(imageName: String, completion: @escaping (UIImage?) -> Void) {
    // completion 함수는 이미지 로딩이 다 이루어지면 알려 달라는 함수
    let reference = Storage.storage().reference().child("recommendations").child(imageName)
    let megaByte = Int64(10 * 1024 * 1024) // 충분히 크야한다.
    reference.getData(maxSize: megaByte) { data, error in

      // 스레드에 의하여 실행된다.
      completion( data != nil ? UIImage(data: data!): nil)
    }
  }
}
