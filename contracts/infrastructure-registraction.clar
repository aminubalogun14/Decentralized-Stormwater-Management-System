;; Infrastructure Registration Contract
;; Records details of drainage systems

(define-data-var last-id uint u0)

(define-map infrastructures
  { id: uint }
  {
    location: (string-utf8 100),
    capacity: uint,
    type: (string-utf8 50),
    installation-date: uint,
    owner: principal,
    active: bool
  }
)

(define-public (register-infrastructure
    (location (string-utf8 100))
    (capacity uint)
    (type (string-utf8 50))
    (installation-date uint))
  (let
    ((new-id (+ (var-get last-id) u1)))
    (var-set last-id new-id)
    (map-set infrastructures
      { id: new-id }
      {
        location: location,
        capacity: capacity,
        type: type,
        installation-date: installation-date,
        owner: tx-sender,
        active: true
      }
    )
    (ok new-id)
  )
)

(define-public (update-infrastructure
    (id uint)
    (location (string-utf8 100))
    (capacity uint)
    (type (string-utf8 50)))
  (let
    ((infrastructure (unwrap! (map-get? infrastructures { id: id }) (err u404))))
    (asserts! (is-eq tx-sender (get owner infrastructure)) (err u403))
    (map-set infrastructures
      { id: id }
      (merge infrastructure
        {
          location: location,
          capacity: capacity,
          type: type
        }
      )
    )
    (ok true)
  )
)

(define-public (deactivate-infrastructure (id uint))
  (let
    ((infrastructure (unwrap! (map-get? infrastructures { id: id }) (err u404))))
    (asserts! (is-eq tx-sender (get owner infrastructure)) (err u403))
    (map-set infrastructures
      { id: id }
      (merge infrastructure { active: false })
    )
    (ok true)
  )
)

(define-read-only (get-infrastructure (id uint))
  (map-get? infrastructures { id: id })
)

(define-read-only (get-last-id)
  (var-get last-id)
)
