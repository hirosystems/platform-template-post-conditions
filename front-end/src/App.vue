<script setup lang="ts">
import { Router, WalletMinimal, PlugZap } from "lucide-vue-next"
import { onBeforeMount, onUnmounted, provide, ref, type Ref } from "vue"
import { isConnected, disconnect } from "@stacks/connect"
import Instructions from "./components/Instructions.vue"
import ConnectMethods from "./components/ConnectMethods.vue"

let isWalletConnected = ref(false)
let checkStacksWalletInterval: number | null = null
let isStacksWalletInjected = ref(false)
let checkDevnetConnectionInterval: number | null = null
let devnetStatus: Ref<{
  connected: boolean
  origin: string
  url: string
}> = ref({
  connected: false,
  origin: "",
  url: ""
})

provide("isWalletConnected", isWalletConnected)

const PLATFORM_DEVNET_STACKS_NETWORK_API_URL = `https://api.platform.hiro.so/v1/ext/${
  import.meta.env.VITE_PLATFORM_HIRO_API_KEY
}/stacks-blockchain-api`
const LOCAL_DEVNET_STACKS_NETWORK_API_URL = "http://localhost:3999"

const handleDevnetConnectionStatus = async () => {
  const checkDevnetStatus = async (url: string) => {
    try {
      const response = await fetch(`${url}/extended`)
      if (response.ok) {
        const status = await response.json()
        return status
      }
    } catch (error) {
      console.error(`[Platform Template] Error fetching devnet status from ${url}:`, error)
    }
    return null
  }

  try {
    // Check Hiro Platform Devnet first
    const platformDevnetStatus = await checkDevnetStatus(
      PLATFORM_DEVNET_STACKS_NETWORK_API_URL
    )
    if (platformDevnetStatus?.status === "ready") {
      devnetStatus.value.connected = true
      devnetStatus.value.origin = "Platform"
      devnetStatus.value.url = PLATFORM_DEVNET_STACKS_NETWORK_API_URL
      return
    }

    // Fallback to local Clarinet Devnet
    const localDevnetStatus = await checkDevnetStatus(LOCAL_DEVNET_STACKS_NETWORK_API_URL)
    if (localDevnetStatus?.status === "ready") {
      devnetStatus.value.connected = true
      devnetStatus.value.origin = "Local"
      devnetStatus.value.url = LOCAL_DEVNET_STACKS_NETWORK_API_URL

      return
    }

    // If neither devnet is ready
    devnetStatus.value.connected = false
    devnetStatus.value.origin = ""
    devnetStatus.value.url = ""
  } catch (error) {
    devnetStatus.value.connected = false
    devnetStatus.value.origin = ""
    devnetStatus.value.url = ""
  }
}

onBeforeMount(async () => {
  checkStacksWalletInterval = window.setInterval(() => {
    // @ts-ignore
    if (window.LeatherProvider.isLeather) {
      isStacksWalletInjected.value = true
      clearInterval(checkStacksWalletInterval!)
      checkStacksWalletInterval = null

      if (isConnected()) {
        isWalletConnected.value = true
      } else {
        isWalletConnected.value = false
      }
    }
  }, 100)

  await handleDevnetConnectionStatus()
  checkDevnetConnectionInterval = window.setInterval(handleDevnetConnectionStatus, 30000)
})

onUnmounted(() => {
  clearInterval(checkDevnetConnectionInterval!)
})

function handleDisconnect() {
  disconnect()
  isWalletConnected.value = false
}
</script>

<template>
  <small
    ><Router :size="13" /> Devnet Status [{{ devnetStatus.origin }}]:
    <span :style="{ color: '#C2EBC4' }">{{
      devnetStatus.connected ? "Connected" : "Disconnected"
    }}</span></small
  >

  <small
    ><WalletMinimal :size="13" /> Leather Extension:
    <span :style="{ color: '#C2EBC4' }">{{
      isStacksWalletInjected ? "Enabled" : "Disabled"
    }}</span></small
  >

  <small @click="handleDisconnect"
    ><PlugZap :size="13" /> Leather Connection:
    <span :style="{ color: '#C2EBC4' }">{{
      isWalletConnected ? "Connected" : "Disconnected"
    }}</span></small
  >
  <div class="main-container">
    <h2>Post-Conditions Template</h2>
    <template v-if="!isStacksWalletInjected || !devnetStatus.connected">
      <Instructions />
    </template>

    <template v-else>
      <ConnectMethods />
    </template>
  </div>
</template>

<style scoped>
.main-container {
  width: 600px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  row-gap: 10px;
  margin: 10px 0px;
}
</style>
