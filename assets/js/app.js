import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

import topbar from "../vendor/topbar"
import * as hooks from "./hooks"

const COOKIE_KEY = 'mrp_locale'

window.addEventListener('phx:change-locale', e => {
    document.cookie = `${COOKIE_KEY}=${e.detail.locale};path=/;samesite=strict`
    window.location.reload()
})

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks})

topbar.config({barColors: {0: "#818cf8"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

liveSocket.connect()

// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
