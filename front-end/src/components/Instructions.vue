<script setup lang="ts">
const openReadmeInEditor = () => fetch("/__open-in-editor?file=../README.md")
</script>

<template>
  <div>
    This is a full-stack demo specifically designed to understand the usage of Stacks' unique
    security mechanism, post-conditions.
    <br />
    <br />
    Steps to run this demo:
    <ol>
      <li>
        Start the Platform hosted devnet environment to deploy the provided Clarity contracts
        located in the <code>`/clarity/contracts`</code> folder.
      </li>
      <li>
        Ensure front-end <code>`.env`</code> variables are pointed towards the Platform hosted
        devnet environment and that you've populated the
        <code>`VITE_PLATFORM_HIRO_API_KEY`</code>.
      </li>
      <li>
        Ensure the Leather wallet extension is enabled and pinned as an active browser
        extension.
      </li>
      <li>Attempt to refresh this page in the event these instructions still appear.</li>
    </ol>
    <br />
    Refer to the
    <a href="javascript:void(0)" @click="openReadmeInEditor" class="inline-link"
      ><code>README.md</code></a
    >
    for more detailed information.
  </div>
</template>

<style scoped></style>
