(set-logic NIA)

(synth-inv inv_fun ((a Int) (j Int) (m Int)))

(declare-primed-var a Int)
(declare-primed-var j Int)
(declare-primed-var m Int)

(define-fun pre_fun ((a Int) (j Int) (m Int)) Bool
(and (= a 0) (> m 0) (= j 1)))

(define-fun trans_fun ((a Int) (j Int) (m Int) (a! Int) (j! Int) (m! Int)) Bool
(or (and (> j m) (= a! a) (= j! j) (= m! m))
(and (<= j m) (= j! (+ j 1)) (= a! (+ a 1)) (= m! m)) 
(and (<= j m) (= j! (+ j 1)) (= a! (- a 1)) (= m! m)) 
))

(define-fun post_fun ((a Int) (j Int) (m Int)) Bool
(=> (not (<= j m)) (and (>= a (- 0 m)) (<= a m))))

(inv-constraint inv_fun pre_fun trans_fun post_fun)

(check-synth)
