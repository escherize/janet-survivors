#!/usr/bin/env janet
(import jaylib)
(import /v)
(import /config)
(import /entities/player)
(import /entities/default)
(import /entities/enemy)
(import /entities/spawner)
(use judge)

(math/seedrandom (os/cryptorand 8))

# Reminder: make things mutable or you cannot change them.
(def state @{:game-over false
             :frame-count 0
             :kill-count 0
             :won false
             :entities (array/new 1000)})

(defn draw-text-centered [text &opt font-size]
  (default font-size 64)
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

(var spawn-timer 400)

(defn update-state []
  
  # (when (= 0 (% (state :frame-count) spawn-timer))
  #   (loop [pos :in [@[20 20]
  #                   @[20 (- config/screen-height 20)]
  #                   @[(- config/screen-width 20) 20]
  #                   @[(- config/screen-width 20) (- config/screen-height 20)]]]
  #     (->> (enemy/spawn pos :color :green :speed 2)
  #          (array/push (state :entities))))
  #   (-= spawn-timer 5))

  (loop [entity
         :in (state :entities)
         :when (not (entity :dead))]
    (:update entity state))
  (++ (state :frame-count)))

(var player @{})

(defn draw []
  (jaylib/begin-drawing)
  (jaylib/clear-background :black)

  (loop [entity
         :in (state :entities)
         :when (not (entity :dead))]
    (:draw entity))

  (cond (state :won) (draw-text-centered "you win")
        (player :dead) (draw-text-centered "game over"))

  (jaylib/draw-text (string "fps: " (jaylib/get-fps))  10 10 8 :white)
  (jaylib/draw-text (string "frm: " (state :frame-count)) 10 20 8 :white)
  (jaylib/draw-text (string "kills: " (state :kill-count)) (- config/screen-width 120) 10 8 :white)
  (jaylib/end-drawing))

(defn my-init []
  (set player (player/spawn))
  (put state :player player)
  (array/push (state :entities) player)
  (->> (enemy/spawn @[200 5000] :color :green :speed 0.01)
       (array/push (state :entities)))
  (array/push (state :entities) (spawner/spawn @[300 300] :rate 50)))

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
