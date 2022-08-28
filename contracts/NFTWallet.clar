

;; FUNDIND WALLET MANAGEMENT
(define-constant ERR_UNAUTHORIZED u1000)

;; initial value for city wallet, set to this contract until initialized
(define-data-var NFTWallet principal (as-contract tx-sender))

;; returns city wallet principal
(define-read-only (get-nft-wallet)
  (ok (var-get NFTWallet))
)

(define-private (is-authorized-auth-nft)
  (is-eq contract-caller (var-get NFTWallet))
)

;; protected function to update city wallet variable
(define-public (set-nft-wallet (newNFTWallet principal))
     ;; #[allow(unchecked_data)]
  (begin
       ;; #[allow(unchecked_data)]
    (asserts! (is-authorized-auth-nft) (err ERR_UNAUTHORIZED))
    (ok (var-set NFTWallet newNFTWallet))
  )
)