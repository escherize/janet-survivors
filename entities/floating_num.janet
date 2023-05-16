(import jaylib)
(import ../v)
(import ../util :as u)
(import /entities/default)
(import ../config)
(use judge)

(defn draw [self]
  (let [{:position [x y] :color color :message message :font-size font-size} self]
    (let [text-width (jaylib/measure-text message font-size)]
      (jaylib/draw-text message (math/floor (- x (/ text-width 2))) (math/floor y) font-size color))))

(defn update [self state]
  (when (< (-- (self :lifespan)) 0) (:kill self))

  (v/v+= (self :velocity) [0.003 0.03])

  # move
  (v/v+= (self :position) (self :velocity)))

(defn spawn [pos
             message
             color
             &opt font-size]
  (assert message)
  (default font-size 12)
  (->
   @{:type "floating_num"
     :position pos
     :message message
     :color color
     :font-size font-size
     :velocity @[0 -1.0]
     :lifespan 50
     :dead false
     :collision-dist (fn [self] -1)
     :draw draw
     :update update}
   (table/setproto (default/default))))
