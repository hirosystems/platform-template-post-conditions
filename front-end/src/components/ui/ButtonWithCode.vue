<script setup lang="ts">
import { Play, SquareFunction } from "lucide-vue-next"
import { ref } from "vue"

let props = defineProps<{
  method: string
  clarity: string
  stacksjs: string
  function: () => Promise<string>
  expectation: string
  outcome: string
  link: string
}>()

const selectedCode = ref("clarity")
const txId = ref("")

const toggleCode = (codeType: string) => {
  selectedCode.value = codeType
}

const callFunction = async () => {
  let result = await props.function()
  txId.value = result
}

let devnetUrlPrefix = `http://localhost:8000/txid/`
let devnetUrlSuffix = "?chain=testnet&api=http://localhost:3999"
</script>

<template>
  <div class="container">
    <div class="top">
      <span class="method-name"
        ><SquareFunction :stroke-width="1.5" :size="18" />{{ props.method }}</span
      >
      <button class="test" @click="callFunction">
        <Play :stroke-width="1.5" :size="18" />Test
      </button>
    </div>
    <div class="switch">
      <span
        class="tab"
        :class="{ active: selectedCode === 'clarity' }"
        @click="toggleCode('clarity')"
        >Clarity</span
      >
      <span
        class="tab"
        :class="{ active: selectedCode === 'stacks' }"
        @click="toggleCode('stacks')"
        >Stacks.js</span
      >
    </div>
    <div class="middle">
      <pre v-if="selectedCode === 'clarity'">
        <code>
          {{ props.clarity }}
        </code>
      </pre>
      <pre v-else>
        <code>
          {{ props.stacksjs }}
        </code>
      </pre>
    </div>
    <div class="bottom">
      User Expectation: {{ props.expectation }}
      <br />
      <span class="outcome">
        Evaluation:
        <a v-if="txId" :href="devnetUrlPrefix + txId + devnetUrlSuffix" target="_blank">{{
          txId
        }}</a>
        <span v-else>n/a</span>
      </span>
    </div>
  </div>
</template>

<style scoped>
.outcome {
  display: flex;
  justify-content: flex-start;
  align-items: center;
  column-gap: 6px;
}

.container {
  height: 350px;
  width: 100%;
  border: 1px solid rgba(100, 100, 100, 0.27);
  border-radius: 6px;
  display: flex;
  flex-direction: column;
  margin-bottom: 10px;
}

.top {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid rgba(100, 100, 100, 0.27);
  padding: 0px 13px;
}

.middle {
  flex: 4;
  padding: 0px 13px;
  border-bottom: 1px solid rgba(100, 100, 100, 0.27);
  overflow: auto;
}

.switch {
  flex: 0.8;
  display: flex;
  justify-content: flex-start;
  align-items: center;
  column-gap: 10px;
  border-bottom: 1px solid rgba(100, 100, 100, 0.27);
}

.tab {
  width: 100px;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  font-size: 0.8rem;
}

.tab.active {
  border-bottom: 2.5px solid #b3d9ff;
}

.bottom {
  font-size: small;
  flex: 1.3;
  display: flex;
  justify-content: center;
  flex-direction: column;
  align-items: flex-start;
  column-gap: 15px;
  padding: 0px 13px;
  border-top: 5px solid;
}

.method-name {
  height: 33px;
  color: white;
  font-family: monospace;
  padding: 8px 14px;
  border-radius: 5px;
  background-color: #3f3636;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 6px;
}

.test {
  height: 33px;
  padding: 8px 14px;
  border-radius: 5px;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 6px;
}

pre {
  font-size: 0.9rem;
  width: 100%;
  border-radius: 2px;
}

.middle::-webkit-scrollbar {
  height: 2px;
  width: 2px;
}

.middle::-webkit-scrollbar-thumb {
  background-color: darkgray;
  border-radius: 2px;
}

.middle::-webkit-scrollbar-track {
  background-color: transparent;
}
</style>
