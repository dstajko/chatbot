import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="chat"
export default class extends Controller {
  static targets = ["prompt", "conversation"];

  generateResponse(event) {
    console.log("Am I here????");
    event.preventDefault();

    const message = this.promptTarget.value;

    // Print to the console before the form submission
    console.log("Form is about to be submitted!");
    console.log("User input:", this.promptTarget.value);

    this.#createLabel("You");
    this.#createMessage(this.promptTarget.value);
    this.#createLabel("ChatGPT");
    this.currentPre = this.#createMessage("");
    this.#setupEventSource();
    this.promptTarget.value = "";
  }

  #createLabel(text) {
    const label = document.createElement("strong");
    label.innerHTML = `${text}:`;
    this.conversationTarget.appendChild(label);
  }

  #createMessage(text) {
    const preElement = document.createElement("pre");
    preElement.innerHTML = text;
    this.conversationTarget.appendChild(preElement);
    return preElement;
  }

  #setupEventSource() {
    this.eventSource = new EventSource(
      `/chat_responses?prompt=${this.promptTarget.value}`
    );
    this.eventSource.addEventListener(
      "message",
      this.#handleMessage.bind(this)
    );

    this.eventSource.addEventListener("error", this.#handleError.bind(this));
  }

  #handleMessage(event) {
    const parsedData = JSON.parse(event.data);
    this.currentPre.innerHTML += parsedData.message;

    // Scroll to bottom of conversation
    this.conversationTarget.scrollTop = this.conversationTarget.scrollHeight;
  }

  #handleError(event) {
    if (event.eventPhase === EventSource.CLOSED) {
      this.eventSource.close();
    }
  }

  disconnect() {
    if (this.eventSource) {
      this.eventSource.close();
    }
  }
}
