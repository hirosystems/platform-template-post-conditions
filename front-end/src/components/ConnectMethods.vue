<script setup lang="ts">
import { inject, onBeforeMount, type Ref, ref } from "vue"
import { connect, disconnect, getLocalStorage, isConnected, request } from "@stacks/connect"
import ButtonWithCode from "./ui/ButtonWithCode.vue"
import { Cl, type NonFungiblePostCondition, type StxPostCondition } from "@stacks/transactions"

const userStxAddress = ref("")
const nftIdNonce = ref(30)

onBeforeMount(() => {
  userStxAddress.value = getLocalStorage()?.addresses.stx[0].address!
})

let isWalletConnected = inject("isWalletConnected") as Ref<boolean>

async function handleConnect() {
  const authRequest = await connect({
    enableLocalStorage: true
  })

  if (authRequest) {
    isWalletConnected.value = true
    userStxAddress.value = getLocalStorage()?.addresses.stx[0].address!
  }
}

function handleGetLocalStorage() {
  const response = getLocalStorage()

  if (response) {
    console.log(response)
  } else {
    console.log("No wallet data found in local storage.")
  }
}

function handleIsConnected() {
  const response = isConnected()
  console.log(response)
}

function handleDisconnect() {
  disconnect()
  isWalletConnected.value = false
}

async function noTransfers(): Promise<string> {
  const response = await request("stx_callContract", {
    contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
    functionName: "no-transfers",
    functionArgs: [],
    postConditionMode: "deny",
    postConditions: [],
    network: "devnet"
  })

  return response.txid!
}

async function singleStxTransfer(): Promise<string> {
  const stxPostCondition: StxPostCondition = {
    type: "stx-postcondition",
    address: userStxAddress.value,
    condition: "eq",
    amount: "10000000"
  }

  const response = await request("stx_callContract", {
    contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
    functionName: "single-stx-transfer",
    functionArgs: [],
    postConditionMode: "deny",
    postConditions: [stxPostCondition],
    network: "devnet"
  })

  return response.txid!
}

async function multipleStxTransfers(): Promise<string> {
  const stxPostCondition: StxPostCondition = {
    type: "stx-postcondition",
    address: userStxAddress.value,
    condition: "lte",
    amount: "30000000"
  }

  const response = await request("stx_callContract", {
    contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
    functionName: "multiple-stx-transfers",
    functionArgs: [],
    postConditionMode: "deny",
    postConditions: [stxPostCondition],
    network: "devnet"
  })

  return response.txid!
}

async function mintAndBurnEvents(): Promise<string> {
  const stxPostCondition: StxPostCondition = {
    type: "stx-postcondition",
    address: userStxAddress.value,
    condition: "eq",
    amount: "10000000"
  }

  const response = await request("stx_callContract", {
    contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
    functionName: "mint-and-burn-events",
    functionArgs: [],
    postConditionMode: "deny",
    postConditions: [stxPostCondition],
    network: "devnet"
  })

  return response.txid!
}

async function uncertainAssetAmount(): Promise<string> {
  const stxPostCondition: StxPostCondition = {
    type: "stx-postcondition",
    address: userStxAddress.value,
    condition: "gte",
    amount: "0"
  }

  const stxPostCondition1: StxPostCondition = {
    type: "stx-postcondition",
    address: userStxAddress.value,
    condition: "lte",
    amount: "1000000"
  }

  const response = await request("stx_callContract", {
    contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
    functionName: "uncertain-asset-amount",
    functionArgs: [],
    postConditionMode: "deny",
    postConditions: [stxPostCondition, stxPostCondition1],
    network: "devnet"
  })

  return response.txid!
}

async function hiddenAssetTransfers(): Promise<string> {
  const stxPostCondition: StxPostCondition = {
    type: "stx-postcondition",
    address: userStxAddress.value,
    condition: "lte",
    amount: "2000000"
  }

  const nftPostCondition1: NonFungiblePostCondition = {
    address: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
    asset: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.cool-nft::cool-nft",
    assetId: Cl.uint(nftIdNonce.value),
    condition: "sent",
    type: "nft-postcondition"
  }

  const response = await request("stx_callContract", {
    contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
    functionName: "hidden-asset-transfers",
    functionArgs: [],
    postConditionMode: "deny",
    postConditions: [stxPostCondition, nftPostCondition1],
    network: "devnet"
  })

  nftIdNonce.value = nftIdNonce.value - 1

  return response.txid!
}

let postConditionScenarios = [
  {
    method: "no-transfers",
    clarity: `
;; A simple function with no asset transfers specified.
;; This should be set to a postConditionMode of "deny",
;; without needing a specific post-condition statement.

(define-public (no-transfers)
  (ok "no transfer events executed.")
)`,
    stacksjs: `
// We will specify the postConditionMode to deny.
// No other post-condition statements are needed.
// postConditions can be set to an empty array.

const response = await request("stx_callContract", {
  contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
  functionName: "no-transfers",
  network: "devnet",
  postConditions: [],
  postConditionMode: "deny"
})   
    `,
    function: noTransfers,
    expectation: "Deny any asset transfers.",
    outcome: "Confirming...",
    link: ""
  },
  {
    method: "single-stx-transfer",
    clarity: `
;; A function that contains a single asset transfer
;; of STX from the tx-sender to the contract. Your 
;; post-condition should include this in a single post-condition
;; statement.

(define-public (single-stx-transfer)
  (stx-transfer? u10000000 tx-sender (as-contract tx-sender))
)  
    `,
    stacksjs: `
// A StxPostCondition will be set with the origin/user address,
// and how much the user expects to be sending out.
// The postConditionMode is set to "deny" to prevent any
// other unexpected transfers to happen. 

const stxPostCondition: StxPostCondition = {
  type: 'stx-postcondition',
  address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  condition: 'eq',
  amount: '10000000',
};

const response = await request("stx_callContract", {
  contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
  functionName: "single-stx-transfer",
  functionArgs: [],
  postConditionMode: "deny",
  postConditions: [stxPostCondition],
  network: "devnet"
})  
    `,
    function: singleStxTransfer,
    expectation: "Allow only 10 STX to be transferred.",
    outcome: "Confirming...",
    link: ""
  },
  {
    method: "multiple-stx-transfer",
    clarity: `
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
    `,
    stacksjs: `
// As the dev, you should notice that a total of 3 STX will be
// transferred from the user to the contract. This total amount should
// be accounted for as a single StxPostCondition since it's on the same
// asset and same principal. The postConditionMode is set to "deny".

const stxPostCondition: StxPostCondition = {
  type: 'stx-postcondition',
  address: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  condition: 'lte',
  amount: '30000000',
};

const response = await request("stx_callContract", {
  contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
  functionName: "multiple-stx-transfers",
  functionArgs: [],
  postConditionMode: "deny",
  postConditions: [stxPostCondition],
  network: "devnet"
})
    `,
    function: multipleStxTransfers,
    expectation: "Allow less than 30 STX to be transferred.",
    outcome: "Confirming...",
    link: ""
  },
  {
    method: "mint-and-burn-events",
    clarity: `
;; A post-condition statement is needed for burn events,
;; but not needed for mint events.

(define-public (mint-and-burn-events)
  (begin
    (try! (stx-burn? u10000000 tx-sender))
    (contract-call? .good-token mint u5000000)
  )
)
    `,
    stacksjs: `
// A post-condition for the mint event will only be needed.
// Mint events are not considered a transfer and are treated
// differently.

const stxPostCondition: StxPostCondition = {
  type: "stx-postcondition",
  address: userStxAddress.value,
  condition: "eq",
  amount: "10000000"
}

const response = await request("stx_callContract", {
  contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
  functionName: "mint-and-burn-events",
  functionArgs: [],
  postConditionMode: "deny",
  postConditions: [stxPostCondition],
  network: "devnet"
})
    `,
    function: mintAndBurnEvents,
    expectation: "Allow exactly 10 STX to be transferred for burning.",
    outcome: "Confirming...",
    link: ""
  },
  {
    method: "uncertain-asset-amount",
    clarity: `
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
    `,
    stacksjs: `
// We're able to setup an amount range using post-conditions.
// We'll have one post-condition specifying that the user will
// transfer greater than or equal 0 STX, and another specifying 
// that the user will transfer less than or equal to 1 STX.

const stxPostCondition: StxPostCondition = {
  type: "stx-postcondition",
  address: userStxAddress.value,
  condition: "gte",
  amount: "0"
}

const stxPostCondition1: StxPostCondition = {
  type: "stx-postcondition",
  address: userStxAddress.value,
  condition: "lte",
  amount: "1000000"
}

const response = await request("stx_callContract", {
  contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
  functionName: "uncertain-asset-amount",
  functionArgs: [],
  postConditionMode: "deny",
  postConditions: [stxPostCondition, stxPostCondition1],
  network: "devnet"
})
    `,
    function: uncertainAssetAmount,
    expectation: "Allow between 0 STX and 1 STX to be transferred from the user.",
    outcome: "Confirming...",
    link: ""
  },
  {
    method: "hidden-asset-transfers",
    clarity: `
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
    `,
    stacksjs: `
// In this scenario, we'll simulate a failed transaction as a way
// to demonstrate a scenario where the dev and the user are both
// unaware of a few underlying transfers happening. Currently, the
// user assumes they will transfer 2 STX to receive a cool-nft asset.
// We'll specify those 2 corresponding post-conditions with the 
// post-condition mode set to deny. But when the transaction is executed
// and evaluated, it will fail because other previously unknown transfer events 
// tried to execute saving our user from malicious activity.

const stxPostCondition: StxPostCondition = {
  type: "stx-postcondition",
  address: userStxAddress.value,
  condition: "lte",
  amount: "2000000"
}

const nftPostCondition1: NonFungiblePostCondition = {
  address: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
  asset: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.cool-nft::cool-nft",
  assetId: Cl.uint(nftIdNonce.value),
  condition: "sent",
  type: "nft-postcondition"
}

const response = await request("stx_callContract", {
  contract: "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.post-conditions",
  functionName: "hidden-asset-transfers",
  functionArgs: [],
  postConditionMode: "deny",
  postConditions: [stxPostCondition, nftPostCondition1],
  network: "devnet"
})
    `,
    function: hiddenAssetTransfers,
    expectation: "Allow the transfer of 2 STX for a cool-nft asset.",
    outcome: "Confirming...",
    link: ""
  }
]
</script>

<template>
  <template v-if="!isWalletConnected">
    <p>
      Awesome! Both the Platform-hosted Devnet and Leather extension are enabled. Follow the
      steps below to proceed.
    </p>
    <ol>
      <li>
        Create a new wallet in the Leather extension by importing this specific devnet provided
        seed phrase which can be also found in <code>Devnet.toml</code>:
        <code
          >twice kind fence tip hidden tilt action fragile skin nothing glory cousin green
          tomorrow spring wrist shed math olympic multiply hip blue scout claw</code
        >
      </li>
      <li>
        Change your Leather extension's network to the Platform hosted devnet environment.
        You'll need to add a network and paste in the provided Platform-hosted devnet API URL
        under the Stacks API URL field.
      </li>

      <li>
        Go ahead and click 'connect' below to see Leather appear as an option in the
        @stacks/connect modal UI. Choose Leather.
      </li>
    </ol>
    <br />
    <button @click="handleConnect" v-if="!isWalletConnected">connect</button>
  </template>
  <template v-else>
    <p>- Your Leather Wallet extension is now connected with this app.</p>
    <p>
      - Be sure to have deployed your contracts to the Platform
      <a
        href="https://docs.hiro.so/stacks/platform/guides/devnet"
        target="_blank"
        class="inline-link"
        >hosted</a
      >
      devnet in order to interact with the functions below.
    </p>
    <p>
      - Each function below corresponds to a Clarity function provided in the
      <code>post-conditions.clar</code> file. Each function will show you a preview of the
      exact Clarity function and what post-conditions should be applied using Stacks.js.
    </p>
    <p>
      - You'll also see what the user expects from calling the function with the final
      evaluation outcome being the transaction state after confirmation.
    </p>
    <br />
    <ButtonWithCode
      v-for="(scenario, index) in postConditionScenarios"
      :method="scenario.method"
      :clarity="scenario.clarity"
      :stacksjs="scenario.stacksjs"
      :function="scenario.function"
      :expectation="scenario.expectation"
      :outcome="scenario.outcome"
      :link="scenario.link"
    />
  </template>
</template>

<style scoped></style>
