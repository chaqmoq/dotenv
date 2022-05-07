import Foundation

final class Cache<Key: Hashable, Value> {
    var costLimit: Int {
        get { _cache.totalCostLimit }
        set { _cache.totalCostLimit = newValue }
    }

    var countLimit: Int {
        get { _cache.countLimit }
        set { _cache.countLimit = newValue }
    }

    private var _cache = NSCache<NSNumber, CachedItem<Value>>()

    init(costLimit: Int = 0, countLimit: Int = 0) {
        self.costLimit = costLimit
        self.countLimit = countLimit
    }

    func setValue(_ value: Value, forKey key: Key) {
        let key = NSNumber(value: key.hashValue)
        let item = CachedItem(value: value)
        _cache.setObject(item, forKey: key)
    }

    func setValue(_ value: Value, forKey key: Key, cost: Int) {
        let key = NSNumber(value: key.hashValue)
        let item = CachedItem(value: value)
        _cache.setObject(item, forKey: key, cost: cost)
    }

    func getValue(forKey key: Key) -> Value? {
        let key = NSNumber(value: key.hashValue)
        guard let item = _cache.object(forKey: key) else { return nil }

        return item.value
    }

    func removeValue(forKey key: String) {
        let key = NSNumber(value: key.hashValue)
        _cache.removeObject(forKey: key)
    }

    func clear() {
        _cache.removeAllObjects()
    }
}

extension Cache {
    private final class CachedItem<T> {
        let value: T

        init(value: T) {
            self.value = value
        }
    }
}
