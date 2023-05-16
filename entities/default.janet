(import jaylib)
(import ../v)
(use judge)

(var id 0)

(defn default []
  @{:type "base"
    :id (++ id)
    :position @[10 10]
    :velocity @[1.0 0.1]
    :dead false
    :draw (fn [self] (jaylib/draw-text (self :type) ;(map math/round (self :position)) 12 :green))
    :update (fn [self state] (v/v+= (self :position) (self :velocity)))
    :collision-dist (fn [self] 3)
    :kill (fn [self]
            (update self :type |(string "dead_" $))
            (put self :dead true))})
