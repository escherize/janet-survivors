(import jaylib)
(import ../v)
(import ../util :as u)
(import /entities/default)
(import ../config)
(use judge)

(defn draw [{:position [x y] :r r :color color :hp hp :max-hp max-hp}]
  (jaylib/draw-circle (math/round x) (math/round y) r color))



(defn update [self state]
  (when (< (-- (self :lifespan)) 0)
    (set (self :dead) true))

  # damage enemies
  (loop [e :in (u/get-collisions-for-type "enemy"
                                          state
                                          (self :position)
                                          (fn [e] (+ (self :r) (e :r))))]
    (set (self :dead) true)
    (:apply-damage e (self :damage)))

  # move
  (v/v+= (self :position) (self :velocity)))

(defn spawn [pos &named velocity &named damage]
  (assert velocity)
  (default damage 1)
  (default pos @[20 20])
  (->
   @{:type "bullet"
     :r 3
     :damage damage
     :position pos
     :color :gray
     :velocity velocity
     :lifespan 30
     :dead false
     :jitter 5
     :draw draw
     :update update}
   (table/setproto (default/default))))
