#!/usr/bin/env janet
(import jaylib)
(import /v)
(import /config)
(import /entities/player)
(import /entities/enemy)
(use judge)

(math/seedrandom (os/cryptorand 8))

# Reminder: make things mutable or you cannot change them.
(def state @{:game-over false :entities (array/new 1000)})

# The entire game is built on entities. Player / enemies / bullets and even damage numbers are entities.
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
    (pp ["Update |" entity])
    (:update entity state)))

(defn draw []
  (jaylib/begin-drawing)
  (jaylib/clear-background :black)

  (loop [entity :in (state :entities)]
    (:draw entity))

  # TODO
  # (cond (state :won) (draw-text-centered "you win")
  #       (not (state :alive)) (draw-text-centered "game over"))
  (jaylib/end-drawing))

(var player @{})

(defn my-init []
  (set player (player/spawn))
  (put state :player player)
  (add-entity player)

  (add-entity (enemy/spawn @[20 20]))
  (add-entity (enemy/spawn @[20 20]))
  (add-entity (enemy/spawn @[20 20]))
  (add-entity (enemy/spawn @[20 20]))
  (add-entity (enemy/spawn @[20 20]))
  (add-entity (enemy/spawn @[20 20]))
  (add-entity (enemy/spawn @[20 20]))
  (add-entity (enemy/spawn @[20 20]))
  (add-entity (enemy/spawn @[120 520] :color :red)))

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
