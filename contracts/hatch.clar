(use-trait ft-trait .sip010-ft-trait.sip010-ft-trait)

;; GENERAL CONFIGURATION

;; (define-constant TokenManager tx-sender)
(define-constant PPM u1000000)
(define-data-var hatch-counter uint u0)

;; ERROR CODES

(define-constant ERR_UNAUTHORIZED u1000)
(define-constant ERR_USER_ALREADY_REGISTERED u1001)
(define-constant ERR_USER_NOT_FOUND u1002)
(define-constant ERR_USER_ID_NOT_FOUND u1003)
(define-constant ERR_ACTIVATION_THRESHOLD_REACHED u1004)
(define-constant ERR_CONTRACT_NOT_ACTIVATED u1005)
(define-constant ERR_USER_ALREADY_MINED u1006)
(define-constant ERR_INSUFFICIENT_COMMITMENT u1007)
(define-constant ERR_INSUFFICIENT_BALANCE u1008)
(define-constant ERR_USER_DID_NOT_MINE_IN_BLOCK u1009)
(define-constant ERR_CLAIMED_BEFORE_MATURITY u1010)
(define-constant ERR_NO_MINERS_AT_BLOCK u1011)
(define-constant ERR_REWARD_ALREADY_CLAIMED u1012)
(define-constant ERR_MINER_DID_NOT_WIN u1013)
(define-constant ERR_NO_VRF_SEED_FOUND u1014)
(define-constant ERR_STACKING_NOT_AVAILABLE u1015)
(define-constant ERR_CANNOT_STACK u1016)
(define-constant ERR_REWARD_CYCLE_NOT_COMPLETED u1017)
(define-constant ERR_NOTHING_TO_REDEEM u1018)
(define-constant ERR_UNABLE_TO_FIND_CITY_WALLET u1019)
(define-constant ERR_CLAIM_IN_WRONG_CONTRACT u1020)

(define-constant ERR_ADDRESS_NOT_FOUND u1001)
(define-constant ERR_ID_NOT_FOUND u1002)
(define-constant ERR_CANNOT_START_ON_PREVIOUS_BLOCK u1003)
(define-constant ERR_POOL_NOT_FOUND u1004)
(define-constant ERR_POOL_STILL_OPEN u1005)
;; (define-constant ERR_INSUFFICIENT_BALANCE u1006)
(define-constant ERR_CONTRIBUTION_BELOW_MINIMUM u1007)
(define-constant ERR_CONTRIBUTION_PERIOD_ENDED u1008)
(define-constant ERR_CONTRIBUTION_PERIOD_NOT_STARTED u1009)
(define-constant ERR_CONTRIBUTION_NOT_FOUND u1010)
(define-constant ERR_CALLER_NOT_AUTHORISED u1011)
(define-constant ERR_MINE_MANY_NOT_FOUND u1012)
(define-constant ERR_BLOCK_NOT_WON u1013)
(define-constant ERR_CLAIMING_UNAVAILABLE u1014)
(define-constant ERR_CLAIMING_ALREADY_ENABLED u1015)
(define-constant ERR_CLAIMING_NOT_ENABLED u1016)
(define-constant ERR_ALREADY_CLAIMED u1017)
(define-constant ERR_CLAIMS_NOT_FOUND u1018)
(define-constant ERR_CANNOT_REMOVE_FEE_ADDRESS u1019)
(define-constant ERR-WRONG-TOKEN u1020)
(define-constant ERR-AUCTION-NOT-ENDED u1021)
(define-constant ERR-AUCTION-SUCCESSFUL u1022)
(define-constant ERR-NO-CLAIMABLE-TOKENS u1023)
(define-constant ERR-NOT-AUTHORIZED u1023)
(define-constant POOL_CONTRACT_ADDRESS (as-contract tx-sender))
(define-constant ERR-AUCTION-NOT-OPEN u3400002)
(define-constant ERR-START-BLOCK u3400005)
(define-constant ERR-END-BLOCK u3400006)
(define-constant ERR-TOTAL-TOKENS u3400007)
(define-constant ERR-MIN-PRICE u3400008)
(define-constant ERR-START-PRICE u3400009)

(define-constant SPLIT_PCT u18)

;; (define-data-var TokenManager principal tx-sender)

;; MANAGER WALLET MANAGEMENT
;; --------------------------------------------------------------------------
(define-constant TokenManager tx-sender)
(define-data-var Token-Manager principal TokenManager)
;; returns city wallet principal
(define-read-only (get-manager-wallet)
  (ok (var-get Token-Manager))
)

(define-private (is-authorized-auth-manager)
  (is-eq contract-caller (var-get Token-Manager))
)

;; protected function to update city wallet variable
(define-public (set-manager-wallet (newTokenManager principal))
     ;; #[allow(unchecked_data)]
  (begin
    (asserts! (is-authorized-auth-manager) (err ERR_UNAUTHORIZED))
         ;; #[allow(unchecked_data)]
    (ok (var-set Token-Manager newTokenManager))
  )
)
;; RESERVE WALLET MANAGEMENT
;; --------------------------------------------------------------------------
(define-data-var ReserveWallet principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.ReserveWallet)

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


;; FUNDIND WALLET MANAGEMENT

;; initial value for city wallet, set to this contract until initialized
(define-data-var NFTWallet principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.NFTWallet)

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

(define-map HatchInfo 
    { hatchId: uint }
    {   
        payment-token: principal,
        total-tokens: uint,
        start-price: uint,
        min-price: uint,
        contributionsStartBlock: uint,
        contributionsEndBlock: uint,
        totalContributed: uint,
    }
)

(define-map VestingInfo 
    { vestingId: uint }
    {   
        vestingCliffPeriod: uint,
        vestingCompletePeriod: uint,
        vestingCliffDate: uint,
        vestingCompleteDate: uint,
    }
)

(define-map commitments
  { 
    user: principal,
    hatchId: uint 
  }
  {
    committed: uint,
    claimed: uint,
  }
)


(define-read-only (get-commitments (user principal) (hatchId uint))
  (default-to
    {
      committed: u0,
      claimed: u0,
    }
    (map-get? commitments { user: user, hatchId: hatchId })
  )
)

(define-read-only (get-hatch-info (hatchId uint))
  (map-get? HatchInfo { hatchId: hatchId })
)

(define-read-only (get-vesting-info (vestingId uint))
  (map-get? VestingInfo { vestingId: vestingId })
)

;; HATCH PRICE ACTION
;; --------------------------------------------------------------------------

(define-read-only (token-price (hatchId uint))
  (let (
    (hatch (unwrap-panic (get-hatch-info hatchId)))
    (totalContributed (get totalContributed hatch))
    (total-tokens (get total-tokens hatch))
  )
    (/ (* totalContributed u100) total-tokens)
  )
)

;; from start-price at contributionsStartBlock, to min-price at end-block
(define-read-only (current-price (hatchId uint))
  (let (
    (hatch (unwrap-panic (get-hatch-info hatchId)))
    (contributionsStartBlock (get contributionsStartBlock hatch))
    (contributionsEndBlock (get contributionsEndBlock hatch))
    (start-price (get start-price hatch))
    (min-price (get min-price hatch))

    (price-diff-nominator (* (- block-height contributionsStartBlock) (- start-price min-price)))
    (price-diff-denominator (- contributionsEndBlock contributionsStartBlock))
    (price-diff (/ price-diff-nominator price-diff-denominator))
  )
    (- start-price price-diff)
  )
)

;; current-price if auction open

(define-read-only (price-function (hatchId uint))
  (let (
    (hatch (unwrap-panic (get-hatch-info hatchId)))
  )
    (if (<= block-height (get contributionsStartBlock hatch))
      (get start-price hatch)
      (if (>= block-height (get contributionsEndBlock hatch))
        (get min-price hatch)
        (current-price hatchId)
      )
    )
  )
)
;; HATCHING OPENS
;; --------------------------------------------------------------------------

(define-public (commit-tokens (hatchId uint) (amount uint))
  (let (
    (hatch (unwrap-panic (get-hatch-info hatchId)))
    (contributionsEndBlock (get contributionsEndBlock hatch))
    (contributionsStartBlock (get contributionsStartBlock hatch))
    (tokens-to-transfer (calculate-commitment hatchId amount))
      (toNft
        (if (and ( > block-height contributionsStartBlock) ( < block-height  contributionsEndBlock))
          (/ (* SPLIT_PCT tokens-to-transfer) u100)
          tokens-to-transfer
        )
      )
      (toReserve (- tokens-to-transfer toNft))
  )
    (asserts! (< block-height contributionsEndBlock) (err ERR_CONTRIBUTION_PERIOD_ENDED))
    (asserts! (>= block-height contributionsStartBlock) (err ERR_CONTRIBUTION_PERIOD_NOT_STARTED))
    (asserts! (>= (stx-get-balance tx-sender) tokens-to-transfer) (err ERR_INSUFFICIENT_BALANCE))

    (if (and ( > block-height contributionsStartBlock) ( < block-height  contributionsEndBlock))
      (begin
        ;; Transfer from user
        (try! (stx-transfer? toReserve tx-sender (var-get ReserveWallet)))

        (try! (stx-transfer? toNft tx-sender (var-get NFTWallet)))
        ;; Add commitment
        (add-commitment hatchId tx-sender tokens-to-transfer)
      )
      (ok u0)
    )
  )
)

(define-private (add-commitment (hatchId uint) (user principal) (commitment uint))
  (let (
    (hatch (unwrap-panic (get-hatch-info hatchId)))
    (current-total (get totalContributed hatch))

    (user-committed (get-commitments user hatchId))
    (current-committed (get committed user-committed))
  )
    ;; Update auction
    (map-set HatchInfo
      { hatchId: hatchId }
      (merge hatch { totalContributed: (+ current-total commitment) })
    )

    ;; Update user
    (map-set commitments
      { user: user, hatchId: hatchId }
      (merge user-committed { committed: (+ current-committed commitment) })
    )
  
    (ok commitment)
  )
)

(define-read-only (calculate-commitment (hatchId uint) (commitment uint))
  (let (
    (hatch (unwrap-panic (get-hatch-info hatchId)))
    (max-commitment (/ (* (get total-tokens hatch) (clearing-price hatchId)) u1000000))
    (new-commitment (+ commitment (get totalContributed hatch)))
  )
    (if (> new-commitment max-commitment)
      (- max-commitment (get totalContributed hatch))
      commitment
    )
  )
)


;; max of token price or current-price
(define-read-only (clearing-price (hatchId uint))
  (let (
    (current-token-price (token-price hatchId))
    (price (price-function hatchId))
  )
    (if (> current-token-price price)
      current-token-price
      price
    )
  )
)
;; HATCHING ENDS
;; --------------------------------------------------------------------------

(define-read-only (hatch-successful (hatchId uint))
  (let (
    (token (token-price hatchId))
  )
    (if (>= token u1)
      true
      false
    )
  )
)

(define-read-only (hatch-ended (hatchId uint))
  (let (
    (hatch (unwrap-panic (get-hatch-info hatchId)))
  )
    (if (> block-height (get contributionsEndBlock hatch))
      true
      false
    )
  )
)

;; HATCHING CLAIM 
;; --------------------------------------------------------------------------

(define-public (withdraw-tokens (hatchId uint))
  (let (
    (user tx-sender)
    (claimable (tokens-claimable hatchId user))

    (user-committed (get-commitments user hatchId))
    (current-claimed (get claimed user-committed))
  )
    (asserts! (> claimable u0) (err ERR-NO-CLAIMABLE-TOKENS))

    (map-set commitments
      { user: user, hatchId: hatchId }
      (merge user-committed { claimed: claimable })
    )
  
    (try! (as-contract (contract-call? .chain-usda transfer claimable (as-contract tx-sender) user none)))

    (ok claimable)
  )
)

(define-read-only (tokens-claimable (hatchId uint) (user principal))
  (let (
    (hatch (unwrap-panic (get-hatch-info hatchId)))
    (user-committed (get committed (get-commitments user hatchId)))
    (user-claimed (get claimed (get-commitments user hatchId)))

    (totalContributed (get totalContributed hatch))
  )
    (if (is-eq totalContributed u0)
      u0
      (let (
        (total-claimable (/ (* user-committed (get total-tokens hatch)) totalContributed))
        (claimable (- total-claimable user-claimed))
      )
        (if (and (hatch-ended hatchId) (hatch-successful hatchId))
          claimable
          u0
        )  
      )
    )
  )
)

(define-public (withdraw-committed (token <ft-trait>) (hatchId uint))
  (let (
    (user tx-sender)
    (hatch (unwrap-panic (get-hatch-info hatchId)))

    (user-committed (get-commitments user hatchId))
    (current-committed (get committed user-committed))
    (current-claimed (get claimed user-committed))
    (claimable (- current-committed current-claimed))
  )
    (asserts! (is-eq (contract-of token) (get payment-token hatch)) (err ERR-WRONG-TOKEN))
    (asserts! (hatch-ended hatchId) (err ERR-AUCTION-NOT-ENDED))
    (asserts! (not (hatch-successful hatchId)) (err ERR-AUCTION-SUCCESSFUL))
    (asserts! (> claimable u0) (err ERR-NO-CLAIMABLE-TOKENS))

    (map-set commitments
      { user: user, hatchId: hatchId }
      (merge user-committed { claimed: claimable })
    )
  
    (try! (as-contract (contract-call? token transfer claimable (as-contract tx-sender) user none)))

    (ok claimable)
  )
)

(define-public (transfer-tokens (token <ft-trait>) (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender .MeaningFullCollections-dao) (err  ERR-NOT-AUTHORIZED))
    ;; #[allow(unchecked_data)]
    (try! (as-contract (contract-call? token transfer amount (as-contract tx-sender) 
    recipient none)))
    (ok true)
  )
)

        ;; #[allow(unchecked_data)]
(define-public (add-auction 
    (payment-token principal) 

    (contributionsStartBlock uint)
    (contributionsEndBlock uint)
    (total-tokens uint)
    (start-price uint)
    (min-price uint)
  )
  (let (
    (hatchId (var-get hatch-counter))
  )
    (asserts! (is-eq tx-sender tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (> contributionsStartBlock block-height) (err ERR-START-BLOCK))
    (asserts! (> contributionsEndBlock contributionsStartBlock) (err ERR-END-BLOCK))
    (asserts! (> total-tokens u0) (err ERR-TOTAL-TOKENS))
    (asserts! (> min-price u0) (err ERR-MIN-PRICE))
    (asserts! (> start-price min-price) (err ERR-START-PRICE))

    (map-set HatchInfo
      { hatchId: hatchId } 
      {             
        payment-token: payment-token,
        total-tokens: total-tokens,
        start-price:  start-price,
        min-price: min-price,
        contributionsStartBlock: contributionsStartBlock,
        contributionsEndBlock: contributionsEndBlock,
        totalContributed: u0
      }
    )
    (var-set hatch-counter (+ hatchId u1))
    (ok hatchId)
  )
)

