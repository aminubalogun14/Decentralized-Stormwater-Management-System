;; Performance Monitoring Contract
;; Tracks effectiveness during storm events

(define-data-var last-event-id uint u0)

(define-map storm-events
  { id: uint }
  {
    start-date: uint,
    end-date: uint,
    rainfall: uint,  ;; in millimeters * 100 (for precision)
    description: (string-utf8 200)
  }
)

(define-map performance-records
  { infrastructure-id: uint, event-id: uint }
  {
    water-flow: uint,  ;; in liters per minute * 100
    capacity-utilization: uint,  ;; percentage * 100
    issues-detected: (string-utf8 200),
    performance-rating: uint  ;; 0-100
  }
)

(define-public (record-storm-event
    (start-date uint)
    (end-date uint)
    (rainfall uint)
    (description (string-utf8 200)))
  (let
    ((new-id (+ (var-get last-event-id) u1)))
    (var-set last-event-id new-id)
    (map-set storm-events
      { id: new-id }
      {
        start-date: start-date,
        end-date: end-date,
        rainfall: rainfall,
        description: description
      }
    )
    (ok new-id)
  )
)

(define-public (record-performance
    (infrastructure-id uint)
    (event-id uint)
    (water-flow uint)
    (capacity-utilization uint)
    (issues-detected (string-utf8 200))
    (performance-rating uint))
  (begin
    (asserts! (<= performance-rating u100) (err u400))
    (map-set performance-records
      { infrastructure-id: infrastructure-id, event-id: event-id }
      {
        water-flow: water-flow,
        capacity-utilization: capacity-utilization,
        issues-detected: issues-detected,
        performance-rating: performance-rating
      }
    )
    (ok true)
  )
)

(define-read-only (get-storm-event (id uint))
  (map-get? storm-events { id: id })
)

(define-read-only (get-performance (infrastructure-id uint) (event-id uint))
  (map-get? performance-records { infrastructure-id: infrastructure-id, event-id: event-id })
)

(define-read-only (get-last-event-id)
  (var-get last-event-id)
)
