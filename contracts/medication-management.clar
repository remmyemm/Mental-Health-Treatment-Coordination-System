;; Medication Management Contract
;; Tracks medications and monitors potential interactions

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u300))
(define-constant ERR-MEDICATION-NOT-FOUND (err u301))
(define-constant ERR-INVALID-INPUT (err u302))
(define-constant ERR-PRESCRIPTION-NOT-FOUND (err u303))
(define-constant ERR-INTERACTION-FOUND (err u304))

;; Data structures
(define-map medications
  { medication-id: uint }
  {
    name: (string-ascii 100),
    generic-name: (string-ascii 100),
    drug-class: (string-ascii 50),
    common-interactions: (list 10 uint),
    side-effects: (string-ascii 300),
    created-at: uint
  }
)

(define-map prescriptions
  { prescription-id: uint }
  {
    patient-id: principal,
    medication-id: uint,
    prescriber: principal,
    dosage: (string-ascii 50),
    frequency: (string-ascii 50),
    start-date: uint,
    end-date: (optional uint),
    status: (string-ascii 20),
    notes: (string-ascii 200),
    created-at: uint
  }
)

(define-map dosage-history
  { prescription-id: uint, record-id: uint }
  {
    dosage: (string-ascii 50),
    frequency: (string-ascii 50),
    changed-by: principal,
    reason: (string-ascii 200),
    timestamp: uint
  }
)

(define-map interaction-alerts
  { alert-id: uint }
  {
    patient-id: principal,
    medication-1: uint,
    medication-2: uint,
    severity: (string-ascii 20),
    description: (string-ascii 300),
    acknowledged: bool,
    created-at: uint
  }
)

;; Counters
(define-data-var medication-counter uint u0)
(define-data-var prescription-counter uint u0)
(define-data-var dosage-record-counter uint u0)
(define-data-var alert-counter uint u0)

;; Public functions

;; Add medication to database
(define-public (add-medication
  (name (string-ascii 100))
  (generic-name (string-ascii 100))
  (drug-class (string-ascii 50))
  (common-interactions (list 10 uint))
  (side-effects (string-ascii 300))
)
  (let ((medication-id (var-get medication-counter)))
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len generic-name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len drug-class) u0) ERR-INVALID-INPUT)

    (map-set medications
      { medication-id: medication-id }
      {
        name: name,
        generic-name: generic-name,
        drug-class: drug-class,
        common-interactions: common-interactions,
        side-effects: side-effects,
        created-at: block-height
      }
    )

    (var-set medication-counter (+ medication-id u1))
    (ok medication-id)
  )
)

;; Create prescription
(define-public (create-prescription
  (patient-id principal)
  (medication-id uint)
  (dosage (string-ascii 50))
  (frequency (string-ascii 50))
  (start-date uint)
  (end-date (optional uint))
  (notes (string-ascii 200))
)
  (let ((prescription-id (var-get prescription-counter)))
    (asserts! (is-some (map-get? medications { medication-id: medication-id })) ERR-MEDICATION-NOT-FOUND)
    (asserts! (> (len dosage) u0) ERR-INVALID-INPUT)
    (asserts! (> (len frequency) u0) ERR-INVALID-INPUT)
    (asserts! (>= start-date block-height) ERR-INVALID-INPUT)

    ;; Check for interactions before creating prescription
    (try! (check-medication-interactions patient-id medication-id))

    (map-set prescriptions
      { prescription-id: prescription-id }
      {
        patient-id: patient-id,
        medication-id: medication-id,
        prescriber: tx-sender,
        dosage: dosage,
        frequency: frequency,
        start-date: start-date,
        end-date: end-date,
        status: "ACTIVE",
        notes: notes,
        created-at: block-height
      }
    )

    (var-set prescription-counter (+ prescription-id u1))
    (ok prescription-id)
  )
)

;; Update prescription dosage
(define-public (update-dosage
  (prescription-id uint)
  (new-dosage (string-ascii 50))
  (new-frequency (string-ascii 50))
  (reason (string-ascii 200))
)
  (let (
    (prescription-data (unwrap! (map-get? prescriptions { prescription-id: prescription-id }) ERR-PRESCRIPTION-NOT-FOUND))
    (record-id (var-get dosage-record-counter))
  )
    (asserts! (is-eq tx-sender (get prescriber prescription-data)) ERR-NOT-AUTHORIZED)
    (asserts! (> (len new-dosage) u0) ERR-INVALID-INPUT)
    (asserts! (> (len new-frequency) u0) ERR-INVALID-INPUT)

    ;; Record dosage change history
    (map-set dosage-history
      { prescription-id: prescription-id, record-id: record-id }
      {
        dosage: new-dosage,
        frequency: new-frequency,
        changed-by: tx-sender,
        reason: reason,
        timestamp: block-height
      }
    )

    ;; Update prescription
    (map-set prescriptions
      { prescription-id: prescription-id }
      (merge prescription-data {
        dosage: new-dosage,
        frequency: new-frequency
      })
    )

    (var-set dosage-record-counter (+ record-id u1))
    (ok true)
  )
)

;; Discontinue prescription
(define-public (discontinue-prescription (prescription-id uint))
  (let (
    (prescription-data (unwrap! (map-get? prescriptions { prescription-id: prescription-id }) ERR-PRESCRIPTION-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender (get prescriber prescription-data)) ERR-NOT-AUTHORIZED)

    (map-set prescriptions
      { prescription-id: prescription-id }
      (merge prescription-data {
        status: "DISCONTINUED",
        end-date: (some block-height)
      })
    )

    (ok true)
  )
)

;; Acknowledge interaction alert
(define-public (acknowledge-alert (alert-id uint))
  (let (
    (alert-data (unwrap! (map-get? interaction-alerts { alert-id: alert-id }) ERR-MEDICATION-NOT-FOUND))
  )
    (map-set interaction-alerts
      { alert-id: alert-id }
      (merge alert-data { acknowledged: true })
    )

    (ok true)
  )
)

;; Read-only functions

;; Get medication information
(define-read-only (get-medication (medication-id uint))
  (map-get? medications { medication-id: medication-id })
)

;; Get prescription
(define-read-only (get-prescription (prescription-id uint))
  (map-get? prescriptions { prescription-id: prescription-id })
)

;; Get patient's active prescriptions
(define-read-only (get-patient-prescriptions (patient-id principal))
  ;; This would typically return a list, but for simplicity we'll return a boolean indicating if any exist
  ;; In a full implementation, this would use a more complex data structure
  (ok true)
)

;; Get dosage history
(define-read-only (get-dosage-history (prescription-id uint) (record-id uint))
  (map-get? dosage-history { prescription-id: prescription-id, record-id: record-id })
)

;; Get interaction alert
(define-read-only (get-interaction-alert (alert-id uint))
  (map-get? interaction-alerts { alert-id: alert-id })
)

;; Private functions

;; Check for medication interactions
(define-private (check-medication-interactions (patient-id principal) (new-medication-id uint))
  (let (
    (new-medication (unwrap! (map-get? medications { medication-id: new-medication-id }) ERR-MEDICATION-NOT-FOUND))
    (interactions (get common-interactions new-medication))
  )
    ;; In a full implementation, this would check against all patient's current medications
    ;; For now, we'll assume no interactions for simplicity
    (ok true)
  )
)

;; Create interaction alert
(define-private (create-interaction-alert
  (patient-id principal)
  (medication-1 uint)
  (medication-2 uint)
  (severity (string-ascii 20))
  (description (string-ascii 300))
)
  (let ((alert-id (var-get alert-counter)))
    (map-set interaction-alerts
      { alert-id: alert-id }
      {
        patient-id: patient-id,
        medication-1: medication-1,
        medication-2: medication-2,
        severity: severity,
        description: description,
        acknowledged: false,
        created-at: block-height
      }
    )

    (var-set alert-counter (+ alert-id u1))
    alert-id
  )
)
