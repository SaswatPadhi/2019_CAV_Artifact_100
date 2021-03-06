(set-logic NIA)

(synth-inv inv_fun ((p Int) (c Int) (cl Int)))

(declare-primed-var p Int)
(declare-primed-var c Int)
(declare-primed-var cl Int)

(define-fun pre_fun ((p Int) (c Int) (cl Int)) Bool
  (and (= p 0) (= c cl)))

(define-fun trans_fun ((p Int) (c Int) (cl Int)
                       (p! Int) (c! Int) (cl! Int)) Bool
  (and (and (< p 4) (> cl 0))
       (and (= cl! (- cl 1))
            (= p! (+ p 1))
            (= c! c))))

(define-fun post_fun ((p Int) (c Int) (cl Int)) Bool
  (or (and (< p 4) (> cl 0))
      (or (< c 4) (= p 4))))

(inv-constraint inv_fun pre_fun trans_fun post_fun)

(check-synth)
