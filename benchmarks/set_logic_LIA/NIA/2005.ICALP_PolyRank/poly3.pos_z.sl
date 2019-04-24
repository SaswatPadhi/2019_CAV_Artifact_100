(set-logic LIA)

(synth-inv inv_fun ((c Int) (x Int) (y Int) (z Int) (x0 Int) (y0 Int) (z0 Int)))

(declare-primed-var c Int)
(declare-primed-var x Int)
(declare-primed-var y Int)
(declare-primed-var z Int)
(declare-primed-var x0 Int)
(declare-primed-var y0 Int)
(declare-primed-var z0 Int)

(define-fun pre_fun ((c Int) (x Int) (y Int) (z Int) (x0 Int) (y0 Int) (z0 Int)) Bool
  (and (= c 0) (= x x0) (= y y0) (>= x0 y0) (= z z0) (>= z0 0)))

(define-fun trans_fun ((c Int) (x Int) (y Int) (z Int) (x0 Int) (y0 Int) (z0 Int)
                       (c! Int) (x! Int) (y! Int) (z! Int) (x0! Int) (y0! Int) (z0! Int)) Bool
  (and (= x0! x0) (= y0! y0) (= z0! z0)
       (or (and (or (< x y) (< z 0))
                (= c! c) (= x! x) (= y! y) (= z! z))
           (and (>= x y) (>= z 0)
                (= c! (+ c 1)) (= x! (+ x z)) (= z! (- z 1)) (= y! y))
           (and (>= x y) (>= z 0)
                (= c! (+ c 1)) (>= y! (+ y 1)) (= x! x) (= z! z)))
  ))

(define-fun post_fun ((c Int) (x Int) (y Int) (z Int) (x0 Int) (y0 Int) (z0 Int)) Bool
  (=> (and (>= x y) (>= z 0))
      (=> (and (>= z0 0) (>= x0 y0))
           (<= (* 2 c) (+ z0 (* 2 (- x0 y0))
                             (* 2 z0)
                             (* z0 z0)))
           )))

(inv-constraint inv_fun pre_fun trans_fun post_fun)

(check-synth)
