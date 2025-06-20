//
//  MemberService.swift
//  TermProject-이주연-2191047
//
//  Created by 이주연 on 6/20/25.
//

import Foundation
import FirebaseFirestore

final class MemberService {
    private let db = Firestore.firestore()
    private let collection = "members"

//    func createMember(member: Member, completion: ((Error?) -> Void)? = nil) {
//        let data = Member.toDict(member)
//        db.collection(collection).document(member.id).setData(data) { error in
//            completion?(error)
//        }
//    }
}
