(import jaylib)
(import ../v)
(import /entities/default)
(import ../config)
(use judge)

## Player

(defn draw [player]
  (let [{:width width :height height
         :position position
         :velocity velocity} player]
    (jaylib/draw-rectangle
     (math/round (- (position 0) (/ width 2)))
     (math/round (- (position 1) (/ height 2)))
     width
     height
     :blue)))

(defn update [player]
  (when (jaylib/key-down? :up   ) (v/v-= (player :velocity) [0 (player :accel)]))
  (when (jaylib/key-down? :down ) (v/v+= (player :velocity) [0 (player :accel)]))
  (when (jaylib/key-down? :left ) (v/v-= (player :velocity) [(player :accel) 0]))
  (when (jaylib/key-down? :right) (v/v+= (player :velocity) [(player :accel) 0]))

  # enforce max velocity
  (v/v-clamp-=
   (player :velocity)
   (v/v* [-1 -1] (player :max-velocity))
   (player :max-velocity))

  # friction
  (v/v*= (player :velocity) (player :friction))

  # move
  (v/v+= (player :position) (player :velocity))

  # stay in bounds?
  (v/v-clamp-= (player :position)
               [(/ (player :width) 2)                   (/ (player :height) 2)]
               [(- config/screen-width
                   (/ (player :width) 2))
                (- config/screen-height
                   (/ (player :height) 2))]))

(defn spawn []
  (-> @{:type "player"
        :width 20
        :height 34
        :accel 0.5
        :max-velocity @[3 3.5]
        :friction @[0.95 0.95]
        :position @[(/ config/screen-width 2)
                    (/ config/screen-height 2)]
        :velocity @[1.0 1.0]
        :draw draw
        :update update}
      (table/setproto (default/default))))
