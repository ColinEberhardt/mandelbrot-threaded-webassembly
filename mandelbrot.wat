;; (memory (export "mem") 80 80) ;; todo size properly
(import "env" "memory" (memory 80 80 shared))


(func $run (param $cx f64) (param $cy f64) (param $diameter f64)  (param $thread i32)
  (local $x i32)
  (local $y i32)
  (local $loc i32)

  (block $myblock
    (loop

      (local.set $loc
        (i32.atomic.rmw.add
          (i32.const 0)
          (i32.const 1)
        )
      )

      ;; loop for 1200 * 800
      (br_if $myblock (i32.ge_u (local.get $loc) (i32.const 960000)))

      ;; convert to coordinates
      (local.set $y
        (i32.div_u
          (local.get $loc)
          (i32.const 1200)
        )
      )
      (local.set $x
        (i32.rem_u
          (local.get $loc)
          (i32.const 1200)
        )
      )

      ;; compute the next mandelbrot step and store
      (i32.store
        (call $offsetFromCoordinate
          (local.get $x)
          (local.get $y)
        )
        (call $colour
          (call $executeStep
            (local.get $cx)
            (local.get $cy)
            (local.get $diameter)
            (local.get $x)
            (local.get $y)
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
      local.get $p0
      i32.const 2
      i32.shl
      i32.const 1023
      i32.and
      local.tee $l0
      i32.const 256
      i32.lt_u
      br_if $B0
      local.get $l0
      i32.const 512
      i32.lt_u
      if $I1
        i32.const 510
        local.get $l0
        i32.sub
        local.set $l0
        br $B0
      end
      i32.const 0
      local.set $l0
    end
    local.get $l0
    local.set $l1
    block $B2
      local.get $p0
      i32.const 2
      i32.shl
      i32.const 128
      i32.add
      i32.const 1023
      i32.and
      local.tee $l0
      i32.const 256
      i32.lt_u
      br_if $B2
      local.get $l0
      i32.const 512
      i32.lt_u
      if $I3
        i32.const 510
        local.get $l0
        i32.sub
        local.set $l0
        br $B2
      end
      i32.const 0
      local.set $l0
    end
    local.get $l0
    i32.const 8
    i32.shl
    local.get $l1
    i32.or
    local.set $l0
    block $B4
      local.get $p0
      i32.const 2
      i32.shl
      i32.const 356
      i32.add
      i32.const 1023
      i32.and
      local.tee $p0
      i32.const 256
      i32.lt_u
      br_if $B4
      local.get $p0
      i32.const 512
      i32.lt_u
      if $I5
        i32.const 510
        local.get $p0
        i32.sub
        local.set $p0
        br $B4
      end
      i32.const 0
      local.set $p0
    end
    local.get $p0
    i32.const 16
    i32.shl
    local.get $l0
    i32.or
    i32.const -16777216
    i32.or)


(func $offsetFromCoordinate (param $x i32) (param $y i32) (result i32)
  (i32.add
    (i32.const 4)
    (i32.add
      (i32.mul
        (i32.const 4800) ;; 1200 * 4
        (local.get $y))
      (i32.mul
        (i32.const 4)
        (local.get $x))
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
  local.get $cx
  local.get $d
  local.get $x
  f64.convert_i32_s
  f64.const 0x1.2cp+10 (;=1200;)
  f64.sub
  f64.const 0x1.2cp+10 (;=1200;)
  f64.div
  f64.mul
  f64.add
  local.get $cy
  local.get $d
  f64.const 0x1.9p+9 (;=800;)
  f64.mul
  f64.const 0x1.2cp+10 (;=1200;)
  f64.div
  local.get $y
  f64.convert_i32_s
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
    local.get $l4
    local.get $l4
    f64.mul
    local.get $l1
    local.get $l1
    f64.mul
    f64.add
    f64.const 0x1p+2 (;=4;)
    f64.le
    i32.const 0
    local.get $l0
    local.get $p2
    i32.lt_u
    select
    if $I1
      local.get $l2
      local.get $l3
      f64.mul
      local.set $l1
      local.get $l2
      local.get $l2
      f64.mul
      local.get $l3
      local.get $l3
      f64.mul
      f64.sub
      local.get $p0
      f64.add
      local.tee $l4
      local.set $l2
      local.get $l1
      local.get $l1
      f64.add
      local.get $p1
      f64.add
      local.tee $l1
      local.set $l3
      local.get $l0
      i32.const 1
      i32.add
      local.set $l0
      br $L0
    end
  end
  local.get $l0
)

(export "iterateEquation" (func $iterateEquation))
(export "run" (func $run))
(export "executeStep" (func $executeStep))
(export "offsetFromCoordinate" (func $offsetFromCoordinate))
