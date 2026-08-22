import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "body", "status", "count", "spine", "quote"]
  static values = { delay: { type: Number, default: 900 } }

  connect() {
    this.renderSpine()
    this.renderCount()
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  schedule() {
    if (this.hasStatusTarget) this.statusTarget.textContent = "Unsaved"
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.save(), this.delayValue)
    this.renderSpine()
    this.renderCount()
  }

  save() {
    if (!this.hasFormTarget) return
    if (this.hasStatusTarget) this.statusTarget.textContent = "Saving"
    this.formTarget.requestSubmit()
  }

  saved(event) {
    if (!this.hasStatusTarget) return
    if (!event.detail.success) {
      this.statusTarget.textContent = "Couldn’t save"
      return
    }

    this.statusTarget.textContent = "Saved"
    const version = event.detail.fetchResponse?.response?.headers?.get("X-Piece-Lock-Version")
    if (version) {
      this.element.querySelectorAll('input[name="piece[lock_version]"]').forEach((input) => {
        input.value = version
      })
    }
  }

  captureQuote() {
    if (!this.hasQuoteTarget) return
    const field = this.hasBodyTarget ? this.bodyTarget : null
    if (field && typeof field.selectionStart === "number" && field.selectionStart !== field.selectionEnd) {
      this.quoteTarget.value = field.value.slice(field.selectionStart, field.selectionEnd).trim()
      return
    }
    const selected = window.getSelection()?.toString()?.trim()
    if (selected) this.quoteTarget.value = selected
  }

  renderCount() {
    if (!this.hasCountTarget || !this.hasBodyTarget) return
    const words = this.bodyTarget.value.match(/[\p{L}\p{N}’']+/gu) || []
    this.countTarget.textContent = words.length.toLocaleString()
  }

  renderSpine() {
    if (!this.hasSpineTarget || !this.hasBodyTarget) return
    const headings = this.bodyTarget.value.split("\n").flatMap((line) => {
      const match = line.match(/^(#{1,3})\s+(.+)$/)
      return match ? [{ level: match[1].length, text: match[2] }] : []
    })

    if (!headings.length) {
      this.spineTarget.innerHTML = `<p class="spine-empty">Headings in the copy become the spine.</p>`
      return
    }

    this.spineTarget.innerHTML = headings
      .map((heading) => `<div class="spine-item spine-l${heading.level}">${this.escape(heading.text)}</div>`)
      .join("")
  }

  escape(value) {
    return value
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
  }
}
