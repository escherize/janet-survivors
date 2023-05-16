(import jaylib)
(import ../v)
(import ../util :as u)
(import /entities/default)
(import ../config)
(use judge)




(defn draw [{:position [x y] :r r :color color :hp hp :max-hp max-hp}]
  (jaylib/draw-circle (math/round x) (math/round y) r color)
  # TODO un copy paste this into spawner...
  # TODO should spawner just be an enemy with "behavior"?
  (when (not= max-hp hp)
    (jaylib/draw-rectangle
     (- (math/round (- x r)) 1)
     (- (math/round (- y (* 1.7 r))) 1)
     (math/round (* 2 r))
     4
     :gray)
    (jaylib/draw-rectangle
     (math/round (- x r))
     (math/round (- y (* 1.7 r)))
     (math/round (* r 2 (- 1 (u/pct-diff max-hp hp))))
     2
     :red))
  #(jaylib/draw-text (string hp) (math/round (+ 10 x)) (math/round (+ 10 y)) 10 :white)
  )

(defn update [e state]
  (when (<= (e :hp) 0) (:kill e) (++ (state :kill-count)))

  # go towards player
  (put e :velocity
       (u/->array (v/vector-to (e :position)
                               ((state :player) :position)
                               (e :speed))))

  
  # go away from some enemies
  # (loop [enemy :in (u/entities-for-type state "enemy")]
  #   (let [new-vel (v/vector-to (enemy :position) (e :position) (/ (e :speed) 100))]
  #     (put e :velocity (u/->array new-vel))))

  # # jitter velocity
  # (v/v+= (e :velocity)
  #        [(* (- (math/random) 0.5) (e :jitter))
  #         (* (- (math/random) 0.5) (e :jitter))])

  # move
  (v/v+= (e :position) (e :velocity)))

(defn spawn [pos &named color &named speed]
  (default color :orange)
  (default pos @[20 20])
  (->
   @{:type "enemy"
     :r 10
     :position pos
     :color color
     :velocity @[1.0 1.0]
     :jitter 0.5
     :speed speed
     :max-hp 10
     :hp 10
     :dead false
     :collision-dist (fn [self] (self :r))
     :draw draw
     :update update
     :apply-damage (fn [self amount] (-= (self :hp) amount))}
   (table/setproto (default/default))))
