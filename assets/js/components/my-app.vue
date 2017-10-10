<template>
  <div class="my-app">
    <div class="user-details mt-5" v-if="enterName">
      <div class="row justify-content-center">
        <div class="col-md-4">
          <div class="card mb-3 text-center">
            <div class="card-body">
              <h4 class="card-title">Join The Chat</h4>
              <p class="card-text">Get in on the fun and join the chat with the other user in the fun-chat chat room.</p>
              <div class="form-group">
                <input type="text" v-model="username" placeholder="Username" class="form-control">
              </div>
              <button v-on:click="connectToChat" class="btn btn-primary btn-block">Join Now</button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div id="main-container" v-else>
      <div id="users-list">
        <h3 class="text-white">Online</h3>
        <ul>
          <transition-group name="user-appear">
            <li v-for="user in users" v-bind:key="user.user">
              {{user.user}} ({{user.online_at}})
            </li>
          </transition-group>
        </ul>
      </div>
      <div id="messages-list">
        <h3>Messages</h3>
        <ul>
          <transition-group name="message-appear">
            <li v-for="message in messages" v-bind:key="message">
              <div class="message-metadata">
                <span class="username">{{message.username}}</span>
                <span class="received-at">{{message.received_at}}</span>
              </div>
              {{message.body}}
            </li>
          </transition-group>
        </ul>
      </div>
      <div id="your-message">
        <strong>{{username}}:</strong><br/>
        <input type="text" placeholder="What do you have to say?" v-model="message" v-on:keyup.13="sendMessage">
      </div>
    </div>
  </div>
</template>

<script>
import {Socket, Presence} from "phoenix"

export default {
  data() {
    return {
      socket: null,
      channel: null,
      messages: [],
      message: "",
      username: "",
      enterName: true,
      users: []
    }
  },
  methods: {
    sendMessage() {
      this.channel.push("new_msg", { body: this.message })
      this.message = ''
    },
    connectToChat() {
      let presences = {}
      this.enterName = false
      this.socket = new Socket("/socket", {params: {username: this.username}})
      this.socket.connect()

      this.channel = this.socket.channel("room:lobby", {})
      this.channel.on("new_msg", payload => {
        payload.received_at = Date();
        this.messages.push(payload);
      });

      this.channel.on("presence_state", state => {
        presences = Presence.syncState(presences, state)
        this.assignUsers(presences)
      })

      this.channel.on("presence_diff", diff => {
        presences = Presence.syncDiff(presences, diff)
        this.assignUsers(presences)
      })

      this.channel.join()
        .receive("ok", response => { console.log("Joined successfully", response) })
        .receive("error", response => { console.log("Unable to join", response) })
    },
    assignUsers(presences) {
      let formatTimestamp = (timestamp) => {
        timestamp = parseInt(timestamp)
        let date = new Date(timestamp)
        return date.toLocaleTimeString()
      }
      this.users = Presence.list(presences, (user, {metas: metas}) => {
        return { user: user, online_at: formatTimestamp(metas[0].online_at) }
      })
    },
  }
}
</script>
