;; RESERVE WALLET MANAGEMENT
;; --------------------------------------------------------------------------
(define-constant ERR_UNAUTHORIZED u1000)

(define-data-var ReserveWallet principal (as-contract tx-sender))

;; returns city wallet principal
(define-read-only (get-reserve-wallet)
  (ok (var-get ReserveWallet))
)

(define-private (is-authorized-auth-reserve)
  (is-eq contract-caller (var-get ReserveWallet))
)

;; protected function to update city wallet variable
(define-public (set-reserve-wallet (newReserveWallet principal))
     ;; #[allow(unchecked_data)]
  (begin
    (asserts! (is-authorized-auth-reserve) (err ERR_UNAUTHORIZED))
         ;; #[allow(unchecked_data)]
    (ok (var-set ReserveWallet newReserveWallet))
  )
)