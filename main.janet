#!/usr/bin/env janet
(import jaylib)
(import /v)
(import /config)
(import /entities/default)
(import /entities/player)
(use judge)


(math/seedrandom (os/cryptorand 8))

(var player nil)

# Reminder: make things mutable or you cannot change them.
(def state @{:game-over false
             :entities (array/new 1000)})

(defn add-entity [entity &opt id]
  (array/push (state :entities) entity))

(defn draw-text-centered [text &opt font-size]
  (default font-size 48)
  (let [text-width (jaylib/measure-text text font-size)]
    (jaylib/draw-text text
                      (math/floor (- (/ config/screen-width 2) (/ text-width 2)))
                      (math/floor (/ config/screen-height 2))
                      font-size
                      :white)))

# Enemies

(defn draw-enemy [{:position [x y] :r r :color color :hp hp :max-hp max-hp}]
  (jaylib/draw-circle (math/round x) (math/round y) r color))



(defn update-enemy [e]
  (set (e :velocity)
       (vector-to (player :position)
                  (e :position)
                  (e :speed)))

  # jitter velocity
  (v/v+= (e :velocity)
         [(* (- (math/random) 0.5) (e :jitter))
          (* (- (math/random) 0.5) (e :jitter))])

  # move
  (v/v+= (e :position) (e :velocity)))

(defn make-enemy [pos &named color]
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
     :draw draw-enemy
     :update update-enemy}
   (table/setproto (default/default))))

(defn draw-text-centered [text &opt font-size]
  (default font-size 48)
  (let [text-width (jaylib/measure-text text font-size)]
    (jaylib/draw-text text
                      (math/floor (- (/ config/screen-width 2) (/ text-width 2)))
                      (math/floor (/ config/screen-height 2))
                      font-size
                      :white)))

(defn update-state []
  (loop [entity :in (state :entities)]
    (pp entity)
    (:update entity)))

(defn draw []
  # TODO: use a macro for this nonsense
  (jaylib/begin-drawing)
  (jaylib/clear-background :black)
  (loop [entity :in (state :entities)]

    (:draw entity))
  # (cond (state :won) (draw-text-centered "you win")
  #       (not (state :alive)) (draw-text-centered "game over"))
  (jaylib/end-drawing))

(defn my-init []
  (add-entity (default/default))
  (set player (player/spawn))
  (add-entity player)
  (add-entity (make-enemy @[20 20]))
  (add-entity (make-enemy @[120 520] :color :red)))

(defn engine/loop [init-fn update-fn draw-fn width height window-title]
  (jaylib/init-window width height window-title)
  (jaylib/set-target-fps 60)
  (init-fn)
  (while (not (jaylib/window-should-close))
    (update-fn)
    (draw-fn))
  (jaylib/close-window))

(defn main [&]
  (engine/loop my-init update-state draw config/screen-width config/screen-height "Janet Survivor"))
