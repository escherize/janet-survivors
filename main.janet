#!/usr/bin/env janet
(import jaylib)
(import /v)
(import /config)
(import /entities/player)
(import /entities/default)
(import /entities/enemy)
(use judge)

(math/seedrandom (os/cryptorand 8))

# Reminder: make things mutable or you cannot change them.
(def state @{:game-over false
             :frame-count 0
             :entities (array/new 1000)})

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

(var spawn-timer 1000)

(defn update-state []

  (when (= 0 (% spawn-timer (state :frame-count)))
    (loop [pos :in [@[20 20]
                    @[20 (- config/screen-height 20)]
                    @[(- config/screen-width 20) 20]
                    @[(- config/screen-width 20) (- config/screen-height 20)]]]
      (->> (enemy/spawn pos :color :green :speed 1)
           (array/push (state :entities))))
    (-- spawn-timer))

  (loop [entity
         :in (state :entities)
         :when (not (entity :dead))]
    #(pp ["Update |" entity])
    (:update entity state))
  (++ (state :frame-count)))

(defn draw []
  (jaylib/begin-drawing)
  (jaylib/clear-background :black)

  (loop [entity
         :in (state :entities)
         :when (not (entity :dead))]
    (:draw entity))

  (loop [entity
         :in (state :entities)
         :when (entity :dead)]
    (put entity :type "dead"))

  # TODO
  # (cond (state :won) (draw-text-centered "you win")
  #       (not (state :alive)) (draw-text-centered "game over"))



  (jaylib/draw-text (string "fps: " (jaylib/get-fps))  10 10 8 :white)
  (jaylib/draw-text (string "frm: " (state :frame-count)) 10 20 8 :white)
  (jaylib/end-drawing))

(var player @{})

(defn my-init []
  (set player (player/spawn))
  (put state :player player)
  (array/push (state :entities) player)
  (->> (enemy/spawn @[200 5000] :color :green :speed 1)
       (array/push (state :entities))))

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
