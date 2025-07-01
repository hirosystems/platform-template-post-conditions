;; A simple function with no asset transfers specified.
;; This should be set to a postConditionMode of "deny",
;; without needing a specific post-condition statement.
(define-public (no-transfers)
  (ok "no transfer events executed.")
)

;; A function that contains a single asset transfer
;; of STX from the tx-sender to the contract. Your 
;; post-condition should include this in a single post-condition
;; statement.
(define-public (single-stx-transfer)
  (stx-transfer? u10000000 tx-sender (as-contract tx-sender))
)

;; When multiple transfer events happen for the same asset on the same address,
;; your post-condition statement should aggregate the net total amount of that asset
;; being transferred during the execution of the entire function.
(define-public (multiple-stx-transfers)
  (begin
    (try! (stx-transfer? u20000000 tx-sender (as-contract tx-sender)))
    (unwrap! (get-burn-block-info? header-hash burn-block-height) (err u1001))
    (stx-transfer? u10000000 tx-sender (as-contract tx-sender))
  )
)

;; A post-condition statement is needed for burn events,
;; but not needed for mint events.
(define-public (mint-and-burn-events)
  (begin
    (try! (stx-burn? u10000000 tx-sender))
    (contract-call? .good-token mint u5000000)
  )
)

;; The function below demonstrates a scenario where
;; the amount of STX to send is dynamic. Having two
;; post-condition statements that capture a range
;; would be appropriate.
(define-public (uncertain-asset-amount)
  (let ((amount-to-send (mod (unwrap-panic (get-stacks-block-info? time (- stacks-block-height u1)))
      u21
    )))
    (try! (stx-transfer? amount-to-send tx-sender (as-contract tx-sender)))
    (ok (print amount-to-send))
  )
)

;; The function below contains a bunch of asset transfer events
;; that are obfiscated in a way where it may not be noticeable at first glance.
;; It's setup for the tx-sender to pay for a cool-nft for 2 STX, but unbeknownst
;; to the user, the function will attempt to transfer out a few of the user's 
;; good tokens AND send the users some evil tokens.
(define-data-var nft-ids-sent uint u0)

(define-public (hidden-asset-transfers)
  (let ((nft-id (- (unwrap-panic (contract-call? .cool-nft get-last-token-id))
      (var-get nft-ids-sent)
    )))
    (try! (stx-transfer? u2000000 tx-sender (as-contract tx-sender)))
    (try! (drain-attempt))
    (try! (contract-call? .cool-nft transfer nft-id (as-contract tx-sender) tx-sender))
    (ok (var-set nft-ids-sent (+ u1 (var-get nft-ids-sent))))
  )
)

(define-private (drain-attempt)
  (let ((amount-to-drain (unwrap-panic (contract-call? .good-token get-balance tx-sender))))
    (try! (contract-call? .good-token transfer
      (- amount-to-drain (- amount-to-drain u10)) tx-sender
      (as-contract tx-sender) none
    ))
    (contract-call? .evil-token transfer u100000000 (as-contract tx-sender)
      tx-sender none
    )
  )
)
