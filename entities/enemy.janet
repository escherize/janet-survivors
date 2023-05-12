(import jaylib)
(import ../v)
(import ../util :as u)
(import /entities/default)
(import ../config)
(use judge)

(defn pct-diff [max-hp hp]
  (/ (math/abs (- max-hp hp)) (/ (+ max-hp hp) 2)))

(test pct-diff 10 5)

(defn draw [{:position [x y] :r r :color color :hp hp :max-hp max-hp}]
  (jaylib/draw-circle (math/round x) (math/round y) r color)
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
     (math/round (* r 2 (- 1 (pct-diff max-hp hp))))
     2
     :red))
  #(jaylib/draw-text (string hp) (math/round (+ 10 x)) (math/round (+ 10 y)) 10 :white)
  )

(defn update [e state]
  (when (<= (e :hp) 0)
    (set (e :dead) true)
    (++ (state :kill-count)))
  #(pp ["? " (state :player)])
  (set (e :velocity)
       (u/->array (v/vector-to ((state :player) :position)
                               (e :position)
                               (e :speed))))

  # jitter velocity
  (v/v+= (e :velocity)
         [(* (- (math/random) 0.5) (e :jitter))
          (* (- (math/random) 0.5) (e :jitter))])

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
     :draw draw
     :update update
     :apply-damage (fn [self amount] (-= (self :hp) amount))}
   (table/setproto (default/default))))
