(import jaylib)
(import ../v)
(import ../util :as u)
(import /entities/default)
(import /entities/bullet)
(import ../config)
(use judge)

(var closest-enemy nil)

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
     :blue)

    # (jaylib/draw-line
    #  (math/round (+ (position 0) (/ width 2)))
    #  (math/round (+ (position 1) (/ height 2)))
    #  ;(map math/round (closest-enemy :position))
    #  :blue)

    ))

(defn enemy-collides? [player state]
  (first (u/get-collisions-for-type "enemy"
                                    state
                                    (player :position)
                                    (fn [e] (+ (e :r) (player :width))))))

(defn get-closest-enemy [player state]
  (var least-distance math/int-max)
  (loop [enemy
         :in (state :entities)
         :when (= "enemy" (enemy :type))
         #:let [_ (pp (enemy :type))]
         :let [distance (v/d (player :position) (enemy :position))]
         :when (< distance least-distance)]
    (set least-distance distance)
    (set closest-enemy enemy))
  closest-enemy)

(defn fire-weapons!
  "Updates state with bullets, if it should."
  [player state]
  (when (= 0 (% (state :frame-count) (player :aspd)))
    (let [closest (get-closest-enemy player state)
          direction (v/vector-to (closest :position) (player :position) 1)]
      (array/push (state :entities)
                  (bullet/spawn
                   (u/->array (player :position))
                   :velocity (u/->array direction))))))

(defn update [player state]
  (when (jaylib/key-down? :up   ) (v/v-= (player :velocity) [0 (player :accel)]))
  (when (jaylib/key-down? :down ) (v/v+= (player :velocity) [0 (player :accel)]))
  (when (jaylib/key-down? :left ) (v/v-= (player :velocity) [(player :accel) 0]))
  (when (jaylib/key-down? :right) (v/v+= (player :velocity) [(player :accel) 0]))

  (fire-weapons! player state)

  (when (enemy-collides? player state)
    (pp "ouch")
    (-- (player :hp)))

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
               [(/ (player :width) 2) (/ (player :height) 2)]
               [(- config/screen-width (/ (player :width) 2))
                (- config/screen-height (/ (player :height) 2))]))

(defn spawn []
  (-> @{:type "player"
        :width 20
        :height 34
        :accel 0.45
        :aspd 20
        :max-hp 50
        :hp 50
        :dead false
        :max-velocity @[3 3.5]
        :friction @[0.95 0.95]
        :position @[(/ config/screen-width 2)
                    (/ config/screen-height 2)]
        :velocity @[1.0 1.0]
        :draw draw
        :update update}
      (table/setproto (default/default))))
