(import jaylib)
(import ../v)
(import /entities/default)
(import ../config)
(use judge)

(defn draw [{:position [x y] :r r :color color :hp hp :max-hp max-hp}]
  (jaylib/draw-circle (math/round x) (math/round y) r color))

(defn update [e state]
  #(pp ["? " (state :player)])
  (set (e :velocity)
       (v/vector-to ((state :player) :position)
                    (e :position)
                    (e :speed)))

  # jitter velocity
  (v/v+= (e :velocity)
         [(* (- (math/random) 0.5) (e :jitter))
          (* (- (math/random) 0.5) (e :jitter))])

  # move
  (v/v+= (e :position) (e :velocity)))

(defn spawn [pos &named color]
  (default color :orange)
  (default pos @[20 20])
  (->
   @{:type "enemy"
     :r 10
     :position pos
     :color color
     :velocity @[1.0 1.0]
     :jitter 5
     :speed 2
     :max-hp 10
     :hp 10
     :draw draw
     :update update}
   (table/setproto (default/default))))
