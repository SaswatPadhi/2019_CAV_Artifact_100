(set-logic NIA)

(synth-inv inv_fun ((x Int) (y Int) (z1 Int) (z2 Int) (z3 Int)))

(declare-primed-var x Int)
(declare-primed-var y Int)
(declare-primed-var z1 Int)
(declare-primed-var z2 Int)
(declare-primed-var z3 Int)

(define-fun pre_fun ((x Int) (y Int) (z1 Int) (z2 Int) (z3 Int)) Bool
(and (= x 0) (= y 0)))


(define-fun trans_fun ((x Int) (y Int) (z1 Int) (z2 Int) (z3 Int) (x! Int) (y! Int) (z1! Int) (z2! Int) (z3! Int) ) Bool
(and (= x! x) (and (<= 0 y) (= y! (+ x y)))))

(define-fun post_fun ((x Int) (y Int) (z1 Int) (z2 Int) (z3 Int)) Bool
(>= y 0))

(inv-constraint inv_fun pre_fun trans_fun post_fun)

(check-synth)