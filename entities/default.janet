(import jaylib)
(import ../v)
(use judge)

(var id 0)

(defn default []
  @{:type "base"
    :id (++ id)
    :position @[10 10]
    :velocity @[1.0 0.1]
    :draw (fn [self] (jaylib/draw-text (self :type) ;(map math/round (self :position)) 12 :green))
    :update (fn [self]
              # (pp self)
              # (pp (self :position))
              # (pp (self :velocity))
              (v/v+= (self :position) (self :velocity)))
    # TODO: kill
    # :kill (fn [self] (set (state :entities)
    #                       (filter (state :entities)
    #                               (fn [e] (not= (self :id) (e :id))))))
   })
