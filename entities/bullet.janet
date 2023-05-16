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
    (:kill self))

  # damage enemies
  (loop [e :in (u/get-collisions-when |(let [t ($ :type)]
                                         (or (= "enemy" t)
                                             (= "spawner" t)))
                                      state
                                      (self :position))]
    (:apply-damage e (self :damage))
    (:kill self))

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
     :lifespan 150
     :dead false
     :collision-dist (fn [self] (self :r))
     :draw draw
     :update update}
   (table/setproto (default/default))))
