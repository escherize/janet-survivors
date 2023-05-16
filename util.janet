(use judge)
(import /v)

(defn ->array [t]
  (array/insert (array/new (length t)) 0 ;t))

(defn entities-for-type [state type]
  (filter (fn [e] (= type (e :type))) (state :entities)))

(defn get-collisions-for-type [type state self-position e->min-radius]
  (let [entities (entities-for-type state type)]
    (->> entities
         (filter (fn [e]
                   (< (v/distance self-position (e :position))
                      (e->min-radius e)))))))

(defn get-collisions-when [entity-pred state self-position]
  (filter (fn [e]
            # (pp e)
            # (pp (e :type))
            # (pp (entity-pred e))
            (and (entity-pred e)
                 (< (v/distance self-position (e :position))
                    (:collision-dist e))))
          (state :entities)))

(defn pct-diff [max-hp hp]
  (/ (math/abs (- max-hp hp)) (/ (+ max-hp hp) 2)))

(test (pct-diff 5 15) 1)
