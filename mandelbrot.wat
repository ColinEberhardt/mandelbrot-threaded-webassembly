;; (memory (export "mem") 80 80) ;; todo size properly
(import "env" "memory" (memory 80 80 shared))


(func $run (param $cx f64) (param $cy f64) (param $diameter f64)  (param $thread i32)
  (local $x i32)
  (local $y i32)
  (local $loc i32)

  (block $myblock
    (loop 

      (set_local $loc
        (i32.atomic.rmw.add
          (i32.const 0)
          (i32.const 1)
        )
      )

      ;; loop for 1200 * 800
      (br_if $myblock (i32.ge_u (get_local $loc) (i32.const 960000)))
      
      ;; convert to coordinates
      (set_local $y
        (i32.div_u
          (get_local $loc)
          (i32.const 1200)
        )
      )
      (set_local $x
        (i32.rem_u
          (get_local $loc)
          (i32.const 1200)
        )
      )

      ;; compute the next mandelbrot step and store
      (i32.store
        (call $offsetFromCoordinate
          (get_local $x)
          (get_local $y)
        )
        (call $colour
          (call $executeStep
            (get_local $cx)
            (get_local $cy)
            (get_local $diameter)
            (get_local $x)
            (get_local $y)
          )
        )
      )

      (br 0)
    )
  )
)


(func $colour  (param $p0 i32) (result i32)
    (local $l0 i32) (local $l1 i32)
    block $B0
      get_local $p0
      i32.const 2
      i32.shl
      i32.const 1023
      i32.and
      tee_local $l0
      i32.const 256
      i32.lt_u
      br_if $B0
      get_local $l0
      i32.const 512
      i32.lt_u
      if $I1
        i32.const 510
        get_local $l0
        i32.sub
        set_local $l0
        br $B0
      end
      i32.const 0
      set_local $l0
    end
    get_local $l0
    set_local $l1
    block $B2
      get_local $p0
      i32.const 2
      i32.shl
      i32.const 128
      i32.add
      i32.const 1023
      i32.and
      tee_local $l0
      i32.const 256
      i32.lt_u
      br_if $B2
      get_local $l0
      i32.const 512
      i32.lt_u
      if $I3
        i32.const 510
        get_local $l0
        i32.sub
        set_local $l0
        br $B2
      end
      i32.const 0
      set_local $l0
    end
    get_local $l0
    i32.const 8
    i32.shl
    get_local $l1
    i32.or
    set_local $l0
    block $B4
      get_local $p0
      i32.const 2
      i32.shl
      i32.const 356
      i32.add
      i32.const 1023
      i32.and
      tee_local $p0
      i32.const 256
      i32.lt_u
      br_if $B4
      get_local $p0
      i32.const 512
      i32.lt_u
      if $I5
        i32.const 510
        get_local $p0
        i32.sub
        set_local $p0
        br $B4
      end
      i32.const 0
      set_local $p0
    end
    get_local $p0
    i32.const 16
    i32.shl
    get_local $l0
    i32.or
    i32.const -16777216
    i32.or)


(func $offsetFromCoordinate (param $x i32) (param $y i32) (result i32)
  (i32.add
    (i32.const 4)
    (i32.add
      (i32.mul
        (i32.const 4800) ;; 1200 * 4
        (get_local $y))
      (i32.mul
        (i32.const 4)
        (get_local $x))
    )
  )
)

;; const WIDTH:  i32 = 1200;
;; const HEIGHT: i32 = 800;
;;
;; @inline
;; function scale(domainStart: f64, domainLength: f64, screenLength: f64, step: f64): f64 {
;;   return domainStart + domainLength * ((step - screenLength) / screenLength);
;; }
;;
;; function executeStep(cx: f64, cy: f64, x: i32, y: i32, diameter: f64): i32 {
;;   let verticalDiameter = diameter * HEIGHT / WIDTH;
;;   let rx = scale(cx, diameter, WIDTH, x);
;;   let ry = scale(cy, verticalDiameter, HEIGHT, y);
;;   return iterateEquation(rx, ry, 10000);
;; }
(func $executeStep  (param $cx f64) (param $cy f64) (param $d f64) (param $x i32) (param $y i32) (result i32)
  get_local $cx
  get_local $d
  get_local $x
  f64.convert_s/i32
  f64.const 0x1.2cp+10 (;=1200;)
  f64.sub
  f64.const 0x1.2cp+10 (;=1200;)
  f64.div
  f64.mul
  f64.add
  get_local $cy
  get_local $d
  f64.const 0x1.9p+9 (;=800;)
  f64.mul
  f64.const 0x1.2cp+10 (;=1200;)
  f64.div
  get_local $y
  f64.convert_s/i32
  f64.const 0x1.9p+9 (;=800;)
  f64.sub
  f64.const 0x1.9p+9 (;=800;)
  f64.div
  f64.mul
  f64.add
  i32.const 10100 ;; max iterations
  call $iterateEquation
)

;; function iterateEquation(x0: f64, y0: f64, maxiterations: u32): u32 {
;;   let a = 0.0, b = 0.0, rx = 0.0, ry = 0.0, ab: f64;
;;   let iterations: u32 = 0;
;;   while (iterations < maxiterations && (rx * rx + ry * ry <= 4)) {
;;     rx = a * a - b * b + x0;
;;     ab = a * b;
;;     ry = ab + ab + y0;
;;     a = rx;
;;     b = ry;
;;     iterations++;
;;   }
;;   return iterations;
;; }
(func $iterateEquation  (param $p0 f64) (param $p1 f64) (param $p2 i32) (result i32)
  (local $l0 i32)
  (local $l1 f64)
  (local $l2 f64)
  (local $l3 f64)
  (local $l4 f64)
  loop $L0
    get_local $l4
    get_local $l4
    f64.mul
    get_local $l1
    get_local $l1
    f64.mul
    f64.add
    f64.const 0x1p+2 (;=4;)
    f64.le
    i32.const 0
    get_local $l0
    get_local $p2
    i32.lt_u
    select
    if $I1
      get_local $l2
      get_local $l3
      f64.mul
      set_local $l1
      get_local $l2
      get_local $l2
      f64.mul
      get_local $l3
      get_local $l3
      f64.mul
      f64.sub
      get_local $p0
      f64.add
      tee_local $l4
      set_local $l2
      get_local $l1
      get_local $l1
      f64.add
      get_local $p1
      f64.add
      tee_local $l1
      set_local $l3
      get_local $l0
      i32.const 1
      i32.add
      set_local $l0
      br $L0
    end
  end
  get_local $l0
)

(export "iterateEquation" (func $iterateEquation))
(export "run" (func $run))
(export "executeStep" (func $executeStep))
(export "offsetFromCoordinate" (func $offsetFromCoordinate))

