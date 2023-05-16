(import jaylib)
(import ../v)
(import ../util :as u)
(import /entities/default)
(import /entities/bullet)
(import /entities/floating_num)
(import ../config)
(use judge)

(var closest-enemy nil)

## Player

(defn draw [player]
  (let [{:width w :height h
         :position [x y]
         :velocity velocity
         :max-hp max-hp
         :hp hp} player]
    (jaylib/draw-rectangle
     (math/round (- x (/ w 2)))
     (math/round (- y (/ h 2)))
     w
     h
     :blue)

    (when closest-enemy
      (jaylib/draw-line
       (math/round (+ x (/ w 2)))
       (math/round (+ y (/ h 2)))
       ;(map math/round (closest-enemy :position))
       :blue))

    (when (not= max-hp hp)
      (jaylib/draw-rectangle
       (- (math/round (- x w)) 1)
       (- (math/round (- y (* 1.7 w))) 1)
       (math/round (* 2 w))
       4
       :gray)
      (jaylib/draw-rectangle
       (math/round (- x w))
       (math/round (- y (* 1.7 w)))
       (math/round (* w 2 (- 1 (u/pct-diff max-hp hp))))
       2
       :green))

    ))

(defn get-closest-enemy [player state]
  (var least-distance math/int-max)
  (set closest-enemy nil)
  (loop [enemy
         :in (state :entities)
         :when (or
                 (= "enemy" (enemy :type))
                 (= "spawner" (enemy :type)))
         #:let [_ (pp (enemy :type))]
         :let [distance (v/d (player :position) (enemy :position))]
         :when (< distance least-distance)]
    (set least-distance distance)
    (set closest-enemy enemy))
  [least-distance closest-enemy])

(defn fire-weapons!
  "Updates state with bullets, if it should."
  [player state]
  (when (= 0 (% (state :frame-count) (player :aspd)))
    (when-let [[_d closest] (get-closest-enemy player state)]
      (when closest
        (let [direction (v/vector-to (player :position) (closest :position) 1)]
          (array/push (state :entities)
                      (bullet/spawn
                       (u/->array (v/v+ (player :position) [0 (math/round (* (player :height) -0.25))]))
                       :velocity (u/->array (v/v* direction (player :bullet-speed))))))))))

(defn update [self state]
  (when (jaylib/key-down? :up   ) (v/v-= (self :velocity) [0 (self :accel)]))
  (when (jaylib/key-down? :down ) (v/v+= (self :velocity) [0 (self :accel)]))
  (when (jaylib/key-down? :left ) (v/v-= (self :velocity) [(self :accel) 0]))
  (when (jaylib/key-down? :right) (v/v+= (self :velocity) [(self :accel) 0]))

  (fire-weapons! self state)

  (let [[d e] (get-closest-enemy self state)]
    (when e
      (when (> (+ (:collision-dist self) (:collision-dist e)) d)
        (let [attack (or (e :attack) 1)]
          (-= (self :hp) attack)
          (array/push (state :entities)
                      (floating_num/spawn (u/->array (v/v- (self :position) [0 (:collision-dist self)]))
                                          (string attack)
                                          :red
                         20)))
        (when (< (self :hp) 0)
          (put self :dead true)))))

  # enforce max velocity
  (v/v-clamp-=
   (self :velocity)
   (v/v* [-1 -1] (self :max-velocity))
   (self :max-velocity))

  # friction
  (v/v*= (self :velocity) (self :friction))

  # move
  (v/v+= (self :position) (self :velocity))

  # stay in bounds?
  (v/v-clamp-= (self :position)
               [(/ (self :width) 2) (/ (self :height) 2)]
               [(- config/screen-width (/ (self :width) 2))
                (- config/screen-height (/ (self :height) 2))]))

(defn spawn []
  (-> @{:type "player"
        :width 20
        :height 34
        :accel 0.45
        :aspd 20
        :max-hp 100
        :hp 100
        :dead false
        :bullet-speed @[4 4]
        :max-velocity @[3 3.5]
        :friction @[0.95 0.95]
        :position @[(/ config/screen-width 2) (/ config/screen-height 2)]
        :velocity @[1.0 1.0]
        :collision-dist (fn [self] (/ (+
                                       (self :width)
                                       (self :height)) 2))
        :draw draw
        :update update}
      (table/setproto (default/default))))
