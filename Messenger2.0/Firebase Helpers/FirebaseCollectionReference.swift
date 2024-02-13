//
//  FCollectionReference.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 04.02.2024.
//

import Foundation
import FirebaseFirestore

enum FCollectionReferance: String {
    case User
    case Recent
    case Messages
}

func FirebaseReference(collectionReferance: FCollectionReferance) -> CollectionReference {
    return Firestore.firestore().collection(collectionReferance.rawValue)
}
