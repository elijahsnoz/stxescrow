(define-map escrow
  ((id uint))
  ((buyer principal) (seller principal) (amount uint) (status int)))

(define-public (create-escrow (escrow-id uint) (seller principal) (amount uint))
  (begin
    (asserts! (> amount u0) (err u100))
    (map-insert escrow escrow-id
      {
        buyer: tx-sender,
        seller: seller,
        amount: amount,
        status: 0
      })
    (ok "Escrow created successfully")))

(define-public (confirm-receipt (escrow-id uint))
  (let ((escrow-data (map-get? escrow escrow-id)))
    (match escrow-data
      escrow-info
      (begin
        (asserts! (is-eq tx-sender (get buyer escrow-info)) (err u101))
        (asserts! (is-eq (get status escrow-info) 0) (err u102))
        (map-set escrow escrow-id (merge escrow-info {status: 1}))
        (ok "Receipt confirmed, funds ready for release")))
      (err u103))))

(define-public (release-funds (escrow-id uint))
  (let ((escrow-data (map-get? escrow escrow-id)))
    (match escrow-data
      escrow-info
      (begin
        (asserts! (is-eq tx-sender (get seller escrow-info)) (err u104))
        (asserts! (is-eq (get status escrow-info) 1) (err u105))
        (map-delete escrow escrow-id)
        (ok "Funds released successfully")))
      (err u106))))

