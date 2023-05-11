(use judge)

(defn v+ [[x1 y1] [x2 y2]] [(+ x1 x2) (+ y1 y2)])
(test (v+ [-5 0] [0 5]) [-5 5])

(defn v- [[x1 y1] [x2 y2]] [(- x1 x2) (- y1 y2)])
(test (v- [10 10] [10 10]) [0 0])

(defn v* [[x1 y1] [x2 y2]] [(* x1 x2) (* y1 y2)])
(test (v* [0 0] [10 10]) [0 0])
(test (v* [1 1] [10 10]) [10 10])
(test (v* [1 0] [10 10]) [10 0])

(defn v/ [[x1 y1] [x2 y2]] [(/ x1 x2) (/ y1 y2)])
(test (v/ [1 2] [10 10]) [0.1 0.2])

# (defn v+= [v1 v2] (set v1 (v+ v1 v2)))
(defn v+ [[x1 y1] [x2 y2]] [(+ x1 x2) (+ y1 y2)])

(defn v+= "Sets the array a1 to be (v+ a1 t2)"
  [a1 t2]
  (set (a1 0) (+ (a1 0) (t2 0)))
  (set (a1 1) (+ (a1 1) (t2 1))))

(defn v-= "Sets the array a1 to be (v- a1 t2)"
  [a1 t2]
  (set (a1 0) (- (a1 0) (t2 0)))
  (set (a1 1) (- (a1 1) (t2 1))))

(defn v*= "Sets the array a1 to be (v* a1 t2)"
  [a1 t2]
  (set (a1 0) (* (a1 0) (t2 0)))
  (set (a1 1) (* (a1 1) (t2 1))))

(defn clamp [lo hi x] (min (max lo x) hi))

(defn v-clamp-=
  [a1 v-lo v-hi]
  (set (a1 0) (clamp (v-lo 0) (v-hi 0) (a1 0)))
  (set (a1 1) (clamp (v-lo 1) (v-hi 1) (a1 1))))

(defn normalize [[x y]]
  (let [mag (math/sqrt (+ (* x x) (* y y)))]
    @[(/ x mag) (/ y mag)]))

(test
 (do (var arr @[1 1])
     (v+= arr [10 10])
     arr)
 @[11 11])

(defn vdist [[x1 y1] [x2 y2]] (math/sqrt
                               (+ (math/pow (- x1 x2) 2)
                                  (math/pow (- y1 y2) 2))))
(test (vdist [0 0] [3 4]) 5)
(test (vdist [0 0] [0 40]) 40)
(test (vdist [0 0] [0 40]) 40)

(defn vector-to [[x1 y1] [x2 y2] speed]
  (let [y-diff (- y1 y2)
        x-diff (- x1 x2)
        d (math/sqrt (+ (* y-diff y-diff) (* x-diff x-diff)))
        # if you want proportional to distance, like gravity: speed-multiplier (/ speed d)
       ]
    (array/insert (array/new 2) 0
                  ;(v* (normalize [x-diff y-diff]) [speed speed]))))

(test
 (vector-to [0 0] [1 1] 1) @[-0.707107 -0.707107])
