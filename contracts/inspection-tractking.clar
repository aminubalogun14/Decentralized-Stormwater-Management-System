;; Inspection Tracking Contract
;; Manages regular assessment of functionality

(define-data-var last-inspection-id uint u0)

(define-map inspections
  { id: uint }
  {
    infrastructure-id: uint,
    inspector: principal,
    date: uint,
    status: (string-utf8 20),
    findings: (string-utf8 500),
    next-inspection: uint
  }
)

(define-map infrastructure-inspections
  { infrastructure-id: uint }
  { inspection-ids: (list 100 uint) }
)

(define-public (record-inspection
    (infrastructure-id uint)
    (date uint)
    (status (string-utf8 20))
    (findings (string-utf8 500))
    (next-inspection uint))
  (let
    ((new-id (+ (var-get last-inspection-id) u1))
     (current-inspections (default-to { inspection-ids: (list) }
                          (map-get? infrastructure-inspections { infrastructure-id: infrastructure-id }))))
    (var-set last-inspection-id new-id)
    (map-set inspections
      { id: new-id }
      {
        infrastructure-id: infrastructure-id,
        inspector: tx-sender,
        date: date,
        status: status,
        findings: findings,
        next-inspection: next-inspection
      }
    )
    (map-set infrastructure-inspections
      { infrastructure-id: infrastructure-id }
      { inspection-ids: (unwrap! (as-max-len?
                                  (append (get inspection-ids current-inspections) new-id)
                                  u100)
                                (err u500)) }
    )
    (ok new-id)
  )
)

(define-read-only (get-inspection (id uint))
  (map-get? inspections { id: id })
)

(define-read-only (get-infrastructure-inspections (infrastructure-id uint))
  (map-get? infrastructure-inspections { infrastructure-id: infrastructure-id })
)

(define-read-only (get-last-inspection-id)
  (var-get last-inspection-id)
)
