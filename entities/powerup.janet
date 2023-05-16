(import jaylib)
(import ../v)
(import ../util :as u)
(import /entities/default)
(import ../config)
(use judge)

(def font-size 20)

(defn draw [self]
  (let [{:position [x y] :r r :color color :hp hp :max-hp max-hp :behavior behavior} self]
    (jaylib/draw-circle-gradient (math/round x) (math/round y) (:collision-dist self) :black :gray)
    (let [text-width (jaylib/measure-text behavior font-size)]
      (jaylib/draw-text behavior (math/floor (- x (/ text-width 2))) (math/floor y) font-size :white)))
  # (jaylib/draw-text behavior x y 8 :white)
  )

(def behaviors
  "Values are functions called on state."
  {"aspd up" (fn [state] (update-in state [:player :aspd] (fn [aspd] (max 1
                                                                          (min
                                                                           (- aspd 1)
                                                                           (math/floor (* aspd 0.9)))))))})

(defn update [self state]
  (when (< (-- (self :lifespan)) 0) (:kill self))

  (loop [e :in (u/get-collisions-when |(= "player" ($ :type)) state (self :position))]
    (let [behavior-fn (get behaviors (self :behavior))]
      (behavior-fn state))
    (:kill self)))

(defn collision-dist [{:r r :max-lifespan max-lifespan :lifespan lifespan}]
  (* r (/ lifespan max-lifespan)))

(defn spawn [pos &named behavior]
  (default behavior "aspd up")
  (default pos @[20 20])
  (->
   @{:type "bullet"
     :r 30
     :position pos
     :max-lifespan 400
     :lifespan 400
     :behavior behavior
     :dead false
     :collision-dist collision-dist
     :draw draw
     :update update}
   (table/setproto (default/default))))
