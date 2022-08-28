(use-trait ft-trait .sip010-ft-trait.sip010-ft-trait)


(define-constant Token_Manager tx-sender)
(define-constant UPDATE_FORMULA_ROLE tx-sender)
(define-constant UPDATE_FEES_ROLE tx-sender)
(define-constant MANAGE_COLLATERAL_TOKEN_ROLE tx-sender)
(define-constant MAKE_BUY_ORDER_ROLE tx-sender)
(define-constant MAKE_SELL_ORDER_ROLE tx-sender)


(define-constant PCT_BASE (pow 10 18))
(define-constant PPM 1000000)

(define-constant ERROR_CONTRACT_IS_EOA u1000)
(define-constant ERROR_INVALID_BENEFICIARY u1001)
(define-constant ERROR_INVALID_PERCENTAGE u1002)
(define-constant ERROR_INVALID_RESERVE_RATIO u1003)
(define-constant ERROR_INVALID_TM_SETTING u1004)
(define-constant ERROR_INVALID_COLLATERAL u1005)
(define-constant ERROR_INVALID_COLLATERAL_VALUE u1006)
(define-constant ERROR_INVALID_BOND_AMOUNT u1007)
(define-constant ERROR_COLLATERAL_ALREADY_WHITELISTED u1008)
(define-constant ERROR_COLLATERAL_NOT_WHITELISTED u1009)
(define-constant ERROR_SLIPPAGE_EXCEEDS_LIMIT u1010)
(define-constant ERROR_TRANSFER_FAILED u1011)
(define-constant ERROR_NOT_BUY_FUNCTION u1012)
(define-constant ERROR_BUYER_NOT_FROM u1013)
(define-constant ERROR_COLLATERAL_NOT_SENDER u1014)
(define-constant ERROR_DEPOSIT_NOT_AMOUNT u1015)
(define-constant ERROR_NO_PERMISSION u1016)
(define-constant ERROR_TOKEN_NOT_SENDER u1017)
(define-constant ERROR_INVALID_BUY_ORDER_DATA u1018)
(define-constant ERR-NOT-AUTHORIZED u3403001)


;; ------------------------------------------
;; Constants
;; ------------------------------------------

(define-constant ERR-WRONG-TOKEN u3402001)

(define-constant ERR-NO-CLAIMABLE-TOKENS u3400001)
(define-constant ERR-AUCTION-NOT-OPEN u3400002)
(define-constant ERR-AUCTION-NOT-ENDED u3400003)
(define-constant ERR-AUCTION-SUCCESSFUL u3400004)
(define-constant ERR-START-BLOCK u3400005)
(define-constant ERR-END-BLOCK u3400006)
(define-constant ERR-TOTAL-TOKENS u3400007)
(define-constant ERR-MIN-PRICE u3400008)
(define-constant ERR-START-PRICE u3400009)

;; ------------------------------------------
;; Variables
;; ------------------------------------------

;; CHAIN WORKS WALLET MANAGEMENT

;; initial value for CHAIN WORKS WALLET, set to this contract until initialized

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
    (asserts! (is-authorized-auth-reserve)  (err ERROR_CONTRACT_IS_EOA))
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
    (asserts! (is-authorized-auth-nft) (err ERROR_CONTRACT_IS_EOA))
    (ok (var-set NFTWallet newNFTWallet))
  )
)



(define-data-var buyFeePct uint u3)
(define-data-var sellFeePct uint u3)
(define-data-var beneficiary principal 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5)
(define-data-var formula uint u0)
(define-data-var auction-counter uint u0)


;; ------------------------------------------
;; Maps
;; ------------------------------------------

;; ------------------------------------------
;; Maps auction-info
;; ------------------------------------------
(define-map auction-info
  { auction-id: uint }
  {
    ;; Info
    payment-token: principal,     ;; token to accept as payment
    start-block: uint,            ;; auction start block
    end-block: uint,              ;; auction end block
    total-tokens: uint,           ;; total number of tokens to sell in auction
    start-price: uint,            ;; start price auction
    min-price: uint,              ;; min price auction
    reserveRatio: uint,           ;; reserve ratio price 
    virtualBalance: uint,
    virtualSupply: uint,
    whitelisted: bool,
    ;; Status
    total-committed: uint        ;; total committed tokens
  }
)

(define-read-only (get-auction-info (auction-id uint))
  (map-get? auction-info { auction-id: auction-id })
)

;; ------------------------------------------
;; Maps commitments
;; ------------------------------------------

(define-map commitments
  { 
    user: principal,
    auction-id: uint 
  }
  {
    committed: uint,
    claimed: uint,
  }
)

(define-read-only (get-commitments (user principal) (auction-id uint))
  (default-to
    {
      committed: u0,
      claimed: u0,
    }
    (map-get? commitments { user: user, auction-id: auction-id })
  )
)

;; ------------------------------------------
;; Maps UpdateBeneficiary
;; ------------------------------------------
(define-map UpdateBeneficiary uint
  {
    beneficiary: principal, ;; e.g. 'STSTW15D618BSZQB85R058DS46THH86YQQY6XCB7
    auction-id: uint 
  }
)

(define-read-only (Update-Beneficiary (beneficiary principal) (auction-id uint))
  (map-get? UpdateBeneficiary {beneficiary: beneficiary, auction-id: auction-id})
)
;; ------------------------------------------
;; Maps UpdateReserve
;; ------------------------------------------

(define-map UpdateReserve uint
  {
    reserve: principal, ;; e.g. 'STSTW15D618BSZQB85R058DS46THH86YQQY6XCB7
    auction-id: uint 
  }
)

(define-read-only (Update-reserve (beneficiary principal) (auction-id uint))
  (map-get? UpdateReserve {reserve: reserve, auction-id: auction-id})
)

;; ------------------------------------------
;; Maps UpdateFunding
;; ------------------------------------------
(define-map UpdateFunding uint
  {
    funding: principal, ;; e.g. 'STSTW15D618BSZQB85R058DS46THH86YQQY6XCB7
    auction-id: uint 
  }
)

(define-read-only (Update-funding (funding principal) (auction-id uint))
  (map-get? UpdateFunding {funding: funding, auction-id: auction-id})
)

;; ------------------------------------------
;; Maps UpdateNftree
;; ------------------------------------------

(define-map UpdateNftree uint
  {
    nftree: principal, ;; e.g. 'STSTW15D618BSZQB85R058DS46THH86YQQY6XCB7
    auction-id: uint 

  }
)

(define-read-only (Update-Nftree (nftree principal) (auction-id uint))
  (map-get? UpdateNftree {nftree: nftree, auction-id: auction-id})
)

;; ------------------------------------------
;; Maps UpdateFormula
;; ------------------------------------------

(define-map UpdateFormula uint
  {
    formula: principal, ;; e.g. 'STSTW15D618BSZQB85R058DS46THH86YQQY6XCB7
    auction-id: uint 

  }
)

(define-read-only (Update-formula (formula principal) (auction-id uint))
  (map-get? UpdateFormula {formula: formula, auction-id: auction-id})
)

;; ------------------------------------------
;; Maps UpdateFees
;; ------------------------------------------

(define-map UpdateFees uint
  { buyFeePct: uint,
    sellFeePct: uint,
    auction-id: uint 

   }
)

(define-read-only (Update-fees (buyFeePct principal) (sellFeePct uint))
  (map-get? UpdateFees {buyFeePct: buyFeePct, sellFeePct: sellFeePct, auction-id: auction-id})
)

;; ------------------------------------------
;; Maps AddCollateralToken
;; ------------------------------------------


(define-map AddCollateralToken uint
  { collateral: principal,
    virtualSupply: uint,
    virtualBalance: uint,
    reserveRatio: uint,
    auction-id: uint 
   }
)

(define-read-only (Update-fees (formula principal) (auction-id uint))
  (map-get? UpdateFees {buyFeePct: buyFeePct, sellFeePct: sellFeePct, auction-id: auction-id})
)

(define-map RemoveCollateralToken uint
  { 
    collateral: principal,
    auction-id: uint 

  }
)
(define-map UpdateCollateralToken uint
  { collateral: principal,
    virtualSupply: uint,
    virtualBalance: uint,
    reserveRatio: uint,
    auction-id: uint 
   }
)

(define-map MakeBuyOrder uint
  { buyer: principal,
    onBehalfOf: principal,
    collateral: principal,
    fee: uint,
    purchaseAmount: uint,
    returnedAmount: uint,
    reserveRatio: uint,
    feePct: uint,
    auction-id: uint

   }
)
(define-map MakeSellOrder uint
  { seller: principal,
    onBehalfOf: principal,
    collateral: principal,
    fee: uint,
    sellAmount: uint,
    returnedAmount: uint,
    reserveRatio: uint,
    feePct: uint,
    auction-id: uint
   }
)

;; ------------------------------------------
;; Var & Map Helpers
;; ------------------------------------------

(define-read-only (get-auction-counter)
  (var-get auction-counter)
)
;; ------------------------------------------
;; Price
;; ------------------------------------------

(define-read-only (token-price (auction-id uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
    (total-committed (get total-committed auction))
    (total-tokens (get total-tokens auction))
  )
    (/ (* total-committed PPM) total-tokens)
  )
)

;; current-price if auction open
(define-read-only (price-function (auction-id uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
  )
    (if (<= block-height (get start-block auction))
      (get start-price auction)
      (if (>= block-height (get end-block auction))
        (get min-price auction)
        (current-price auction-id)
      )
    )
  )
)

;; from start-price at start-block, to min-price at end-block
(define-read-only (current-price (auction-id uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
    (start-block (get start-block auction))
    (end-block (get end-block auction))
    (start-price (get start-price auction))
    (min-price (get min-price auction))

    (price-diff-nominator (* (- block-height start-block) (- start-price min-price)))
    (price-diff-denominator (- end-block start-block))
    (price-diff (/ price-diff-nominator price-diff-denominator))
  )
    (- start-price price-diff)
  )
)

;; max of token price or current-price
(define-read-only (clearing-price (auction-id uint))
  (let (
    (current-token-price (token-price auction-id))
    (price (price-function auction-id))
  )
    (if (> current-token-price price)
      current-token-price
      price
    )
  )
)

;; ------------------------------------------
;; Auction end
;; ------------------------------------------

(define-read-only (auction-successful (auction-id uint))
  (let (
    (clearing (clearing-price auction-id))
    (token (token-price auction-id))
  )
    (if (>= token clearing)
      true
      false
    )
  )
)

(define-read-only (auction-ended (auction-id uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
  )
    (if (> block-height (get end-block auction))
      true
      false
    )
  )
)

(define-read-only (auction-open (auction-id uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
  )
    (if (and (>= block-height (get start-block auction)) (<= block-height (get end-block auction)))
      true
      false
    )
  )
)
;; ------------------------------------------
;; Commit
;; ------------------------------------------

(define-public (commit-tokens (token <ft-trait>) (auction-id uint) (amount uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
    (tokens-to-transfer (calculate-commitment auction-id amount))
  )
    (asserts! (auction-open auction-id) (err ERR-AUCTION-NOT-OPEN))
    (asserts! (is-eq (contract-of token) (get payment-token auction)) (err ERR-WRONG-TOKEN))

    (if (> tokens-to-transfer u0)
      (begin
        ;; Transfer from user
        (try! (contract-call? token transfer tokens-to-transfer tx-sender (as-contract tx-sender) none))

        ;; Add commitment
        (add-commitment auction-id tx-sender tokens-to-transfer)
      )
      (ok u0)
    )
  )
)

(define-private (add-commitment (auction-id uint) (user principal) (commitment uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
    (current-total (get total-committed auction))

    (user-committed (get-commitments user auction-id))
    (current-committed (get committed user-committed))
  )
    ;; Update auction
    (map-set auction-info
      { auction-id: auction-id }
      (merge auction { total-committed: (+ current-total commitment) })
    )

    ;; Update user
    (map-set commitments
      { user: user, auction-id: auction-id }
      (merge user-committed { committed: (+ current-committed commitment) })
    )
  
    (ok commitment)
  )
)

(define-read-only (calculate-commitment (auction-id uint) (commitment uint))
  (let (
    (auction (unwrap-panic (get-auction-info auction-id)))
    (max-commitment (/ (* (get total-tokens auction) (clearing-price auction-id)) u1000000))
    (new-commitment (+ commitment (get total-committed auction)))
  )
    (if (> new-commitment max-commitment)
      (- max-commitment (get total-committed auction))
      commitment
    )
  )
)
