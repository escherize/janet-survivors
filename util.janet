(use judge)
(import /v)

(defn ->array [t]
  (array/insert (array/new (length t)) 0 ;t))

(defn get-collisions-for-type [type state self-position e->min-radius]
  (let [entities (filter (fn [e] (= type (e :type))) (state :entities))]
    (->> entities
         (filter (fn [e]
                   (< (v/distance self-position (e :position))
                      (e->min-radius e)))))))
