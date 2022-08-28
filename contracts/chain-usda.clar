;; SIP010 trait on mainnet
;; (impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-constant CONTRACT_OWNER tx-sender)

;; honesty is limitless!
(define-fungible-token chain-works)

(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))

;; #[allow(unchecked_data)]
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
	(begin
		(asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR_OWNER_ONLY)
		(ft-transfer? chain-works amount sender recipient)
	)
)
(define-read-only (get-name)
	(ok "Chain Works")
)

(define-read-only (get-symbol)
	(ok "CW")
)

(define-read-only (get-decimals)
	(ok u18) ;; same as stx
)

(define-read-only (get-balance (who principal))
	(ok (ft-get-balance chain-works who))
)

(define-read-only (get-total-supply)
	(ok (ft-get-supply chain-works))
)

(define-read-only (get-token-uri)
	(ok none)
)

;; #[allow(unchecked_data)]
(define-public (mint (account principal) (amount uint))
	(begin
		;; (asserts! (is-eq contract-caller .challange-me) ERR_OWNER_ONLY)
        (unwrap-panic (ft-mint? chain-works amount account))
		;; (ft-mint? reputation-coin amount recipient)
      (ok amount)
    )
)



;;#[allow(unchecked_data)]
(define-public (burn (amount uint) (sender principal))
	(begin
		(asserts! (> amount u0) (err u1))
		(asserts! (is-eq tx-sender sender) ERR_OWNER_ONLY)
		(ft-burn? chain-works amount sender)
	)
)


;; Initialize the contract
(begin
  (mint 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.hatch u10000000000000))

