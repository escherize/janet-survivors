(import ../util :as u)
(import ../v)
(import /entities/default)
(import /entities/floating_num)
(import /entities/enemy)
(import jaylib)
(use judge)

(var id 0)

(defn spawn? [self state]
  (= 0 (% (state :frame-count) (self :rate))))

(defn draw [{:width w :height h :position [x y] :hp hp :max-hp max-hp}]
  (let [hh (/ h 2)]
    #(jaylib/draw-circle w h 50 :white)
    (jaylib/draw-triangle
     # bottom left
     (v/v+ [x y] [(- w) (- hh)])
     (v/v+ [x y] [0        hh])
     (v/v+ [x y] [w     (- hh)])
     :white))
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
     :red)))

(defn update [self state]
  # kill when dead
  (when (<= (self :hp) 0) (:kill self) (++ (state :kill-count)))

  (if (spawn? self state)
    (->> (enemy/spawn
          (u/->array (self :position))
          :color :white
          :speed 2)
         (array/push (state :entities)))))

(defn spawn [pos &named rate]
  (default rate 30)
  (default pos @[200 200])
  (->
   @{:type "spawner"
     :width 10
     :height 20
     :position pos
     :color :gray
     :velocity @[0.0 0.0]
     :rate rate
     :max-hp 10
     :hp 10
     :attack 10
     :dead false
     :collision-dist (fn [self] (self :width))
     :apply-damage (fn [self amount state]
                     (-= (self :hp) amount)
                     (array/push (state :entities)
                                 (floating_num/spawn (u/->array
                                                      (v/v- (self :position) [0 (:collision-dist self)]))
                                                     (string amount)
                                                     :white)))
     :draw draw
     :update update}
   (table/setproto (default/default))))
