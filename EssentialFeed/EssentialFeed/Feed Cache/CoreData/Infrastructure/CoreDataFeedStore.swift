//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Kamran on 27.03.25.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    public func retrieve(completion: @escaping RetreivalCompletion) {

        perform { context in
                    do {
                        if let cache = try ManagedCache.find(in: context) {
                            completion(.success(.found(feed: cache.localFeed, timestamp: cache.timestamp)))
                        } else {
                            completion(.success(.empty))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
                    do {
                        try ManagedCache.find(in: context).map(context.delete).map(context.save)
                        completion(nil)
                    } catch {
                        completion(error)
                    }
                }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
            let context = self.context
            context.perform { action(context) }
        }
}
//
//public final class CoreDataFeedStore {
//    private static let modelName = "FeedStore"
//    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
//    
//    private let container: NSPersistentContainer
//    let context: NSManagedObjectContext
//    
//    enum StoreError: Error {
//        case modelNotFound
//        case failedToLoadPersistentContainer(Error)
//    }
//    
//    public enum ContextQueue {
//        case main
//        case background
//    }
//    
//    public var contextQueue: ContextQueue {
//        context == container.viewContext ? .main : .background
//    }
//    
////    public init(storeURL: URL, contextQueue: ContextQueue = .background) throws {
////        guard let model = CoreDataFeedStore.model else {
////            throw StoreError.modelNotFound
////        }
////        
////        do {
////            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
////            context = contextQueue == .main ? container.viewContext : container.newBackgroundContext()
////        } catch {
////            throw StoreError.failedToLoadPersistentContainer(error)
////        }
////    }
//    
//    public init(storeURL: URL, bundle: Bundle = .main) throws {
//            container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
//            context = container.newBackgroundContext()
//        }
//    
//    public func perform(_ action: @escaping () -> Void) {
//        context.perform(action)
//    }
//    
//    private func cleanUpReferencesToPersistentStores() {
//        context.performAndWait {
//            let coordinator = self.container.persistentStoreCoordinator
//            try? coordinator.persistentStores.forEach(coordinator.remove)
//        }
//    }
//    
//    deinit {
//        cleanUpReferencesToPersistentStores()
//    }
//}
