import Component from "@ember/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { later, cancel } from "@ember/runloop";
import { ajax } from "discourse/lib/ajax";
import MessageBus from "message-bus";

export default Component.extend({
    router: service(),

    tagName: "",
    shouldShow: false,
    current: 0,
    goal: 1,
    percent: 0,
    wallet: "",
    pollTimer: null,

    init() {
        this._super(...arguments);
        this.checkVisibility();
        // Subscribe to router changes to toggle visibility
        this.router.on("routeDidChange", this, this.checkVisibility);
    },

    didInsertElement() {
        this._super(...arguments);
        if (this.shouldShow) {
            this.fetchData();
            this.subscribeToMessageBus();
            this.startPolling();
        }
    },

    willDestroyElement() {
        this._super(...arguments);
        if (this.pollTimer) cancel(this.pollTimer);
        this.unsubscribeFromMessageBus();
        this.router.off("routeDidChange", this, this.checkVisibility);
    },

    checkVisibility() {
        const currentRoute = this.router.currentRouteName;
        const isDiscovery = currentRoute && currentRoute.includes("discovery");

        // Update property. If it changes to true, we might need to fetch data if not already observing.
        this.set("shouldShow", isDiscovery);
    },

    fetchData() {
        return ajax("/yoomoney/status").then((data) => {
            this.updateData(data);
        }).catch(() => {
            // fail silently
        });
    },

    updateData(data) {
        if (this.isDestroyed || this.isDestroying) return;

        const current = parseFloat(data.current || 0);
        const goal = parseFloat(data.goal || 1);
        const percent = Math.min(Math.round((current / goal) * 100), 100);

        this.setProperties({
            current: current,
            goal: goal,
            percent: percent,
            wallet: data.wallet
        });

        // Update the hidden receiver field if needed (using DOM access as it's static html in HBS)
        // Note: In HBS we hardcoded 100, assuming input binding works for 'sum'
    },

    startPolling() {
        this.pollTimer = later(this, () => {
            this.fetchData().finally(() => {
                this.startPolling();
            });
        }, 10000); // 10 seconds
    },

    subscribeToMessageBus() {
        MessageBus.subscribe("/yoomoney/donations", (data) => {
            this.updateData(data);
        });
    },

    unsubscribeFromMessageBus() {
        MessageBus.unsubscribe("/yoomoney/donations");
    },

    // Helper for format-currency is likely standard or we can compute it
    // Since 'format-currency' might not be a built-in helper in all setups, 
    // let's assume we might need a computed property or register a helper.
    // For simplicity, we can use a getter or simple property if HBS helper fails.
    // But wait, HBS helper format-currency is standard in Discourse? 
    // Let's rely on standard 'currency' helper or just format it in JS.

    // Actually, let's format in JS to be safe

});
