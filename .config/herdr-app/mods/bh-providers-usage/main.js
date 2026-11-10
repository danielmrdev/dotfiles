import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, theme, run, window, keys, exec, appHome } from "herdr";

const USAGE_POLL_MS = 5 * 60 * 1000;
const USAGE_CLOCK_MS = 60 * 1000;
const USAGE_BAR_WIDTH = 54;
const USAGE_BAR_HEIGHT = 3;

export default class WorkspaceStatus extends View {
  init(_props, cx) {
    this.codexUsage = null;
    this.codexUsageLoading = false;
    this.openCodeGoUsage = null;
    this.openCodeGoUsageLoading = false;
    this.refreshCodexUsage(cx);
    this.refreshOpenCodeGoUsage(cx);
    cx.timer.every(USAGE_POLL_MS, cx => {
      this.refreshCodexUsage(cx);
      this.refreshOpenCodeGoUsage(cx);
    });
    cx.timer.every(USAGE_CLOCK_MS, cx => cx.notify());
  }

  resetCountdown(resetsAt) {
    if (!Number.isFinite(resetsAt)) return null;
    const totalMinutes = Math.max(0, Math.ceil((resetsAt * 1000 - Date.now()) / 60000));
    if (totalMinutes === 0) return "now";
    const days = Math.floor(totalMinutes / 1440);
    const hours = Math.floor((totalMinutes % 1440) / 60);
    const minutes = totalMinutes % 60;
    return [
      days > 0 ? `${days}d` : null,
      hours > 0 ? `${hours}h` : null,
      days === 0 && minutes > 0 ? `${minutes}m` : null,
    ].filter(Boolean).join("");
  }

  refreshCodexUsage(cx) {
    if (this.codexUsageLoading) return;
    this.codexUsageLoading = true;
    cx.spawn(async cx => {
      try {
        const result = await exec("python3", [`${appHome()}/mods/bh-providers-usage/codex-usage.py`]);
        if (result.code !== 0) throw new Error("Codex usage unavailable");
        this.codexUsage = JSON.parse(result.stdout);
      } catch {
        this.codexUsage = null;
      } finally {
        this.codexUsageLoading = false;
        cx.notify();
      }
    });
  }

  refreshOpenCodeGoUsage(cx) {
    if (this.openCodeGoUsageLoading) return;
    this.openCodeGoUsageLoading = true;
    cx.spawn(async cx => {
      try {
        const result = await exec("python3", [`${appHome()}/mods/bh-providers-usage/opencode-go-usage.py`]);
        if (result.code !== 0) throw new Error("OpenCode Go usage unavailable");
        this.openCodeGoUsage = JSON.parse(result.stdout);
      } catch {
        this.openCodeGoUsage = null;
      } finally {
        this.openCodeGoUsageLoading = false;
        cx.notify();
      }
    });
  }

  usageBar(t, label, usage) {
    if (!usage) return null;
    const used = Math.max(0, Math.min(100, usage.usedPercent));
    const durationMs = usage.windowDurationMins * 60 * 1000;
    const resetsAtMs = usage.resetsAt * 1000;
    const pace = durationMs > 0 && Number.isFinite(usage.resetsAt) && Number.isFinite(resetsAtMs)
      ? Math.max(0, Math.min(100, (durationMs - (resetsAtMs - Date.now())) / durationMs * 100))
      : null;
    const markerLeft = pace === null ? 0 : Math.max(0, Math.min(USAGE_BAR_WIDTH - 1, USAGE_BAR_WIDTH * pace / 100 - 0.5));
    const resetIn = this.resetCountdown(usage.resetsAt);
    const description = pace === null
      ? `${label}: ${Math.round(used)}% used`
      : `${label}: ${Math.round(used)}% used; pace marker at ${Math.round(pace)}%`;
    const resetDescription = resetIn === null ? "" : `; resets in ${resetIn}`;
    const paceNote = usage.windowDurationMins === 43200
      ? "marker estimates pace over a 30-day window; monthly reset duration is not specified"
      : "marker shows expected usage at this point in the window";
    return h_flex().gap(5).items_center().accessibility_label(`${description}${resetDescription}`)
      .tooltip(`${description}${resetDescription}. Fill shows usage; ${paceNote}.`)
      .child(div().text_color(t.dim).child(label))
      .child(div().relative().w(USAGE_BAR_WIDTH).h(USAGE_BAR_HEIGHT).rounded(2).bg(t.border)
        .child(div().absolute().left(0).top(0).w(USAGE_BAR_WIDTH * used / 100).h(USAGE_BAR_HEIGHT).rounded(2).bg(t.accent))
        .when(pace !== null, el => el.child(div().absolute().left(markerLeft).top(-1).w(1).h(5).rounded(1).bg(t.dim))))
      .child(`${Math.round(used)}%`)
      .when(resetIn !== null, el => el.child(div().text_color(t.dim).child(resetIn)));
  }
  // The palette key as actually bound, not a hardcoded one; without a
  // binding the hint stays useful ("commands") instead of lying.
  hint(t) {
    const mac = window()?.platform === "macos";
    const mod = { cmd: mac ? "⌘" : "Ctrl+", ctrl: mac ? "⌃" : "Ctrl+", shift: mac ? "⇧" : "Shift+", alt: mac ? "⌥" : "Alt+", option: mac ? "⌥" : "Alt+" };
    const b = keys().find((k) => k.section === "global" && k.action === "app.palette");
    const parts = b && b.keys.endsWith("--") ? [...b.keys.slice(0, -2).split("-"), "-"] : b?.keys.split("-");
    const key = parts && parts.map((p) => mod[p.toLowerCase()] ?? p.toUpperCase()).join("");
    return key ? `${key}  commands` : "commands";
  }

  render() {
    const t = theme();
    const space = spaces().find(s => s.active);
    const list = agents();
    const needs = list.filter(a => a.status === "blocked").length;
    const label = (icon, text) => h_flex().gap(6).items_center().child(svg(`mods/workspace-chrome/${icon}.svg`).size(13)).child(text);
    return h_flex().size_full().px(14).gap(16).items_center().bg(t.chrome).border_t(1).border_color(t.border).text_size(11.8).text_color(t.muted)
      .child(label(space?.machine ? "server" : "monitor", space?.machine ?? "This computer"))
      .when(Boolean(space?.branch), el => el.child(label("branch", space.branch)))
      .child(h_flex().gap(6).items_center().child(div().size(6).rounded(3).bg(t.dim)).child(`${list.length} agents`)
        .when(needs > 0, el => el.child(div().text_color(t.blocked).child(`· ${needs} needs you`))))
      .child(div().flex_1())
      .when(Boolean(this.codexUsage?.fiveHour || this.codexUsage?.sevenDay), el => el.child(h_flex().gap(8).items_center()
        .child(div().accessibility_label("OpenAI Codex").child(svg("mods/bh-providers-usage/openai.svg").size(14)))
        .child(this.usageBar(t, "5h", this.codexUsage.fiveHour))
        .child(this.usageBar(t, "7d", this.codexUsage.sevenDay))))
      .when(Boolean(this.openCodeGoUsage?.fiveHour || this.openCodeGoUsage?.sevenDay || this.openCodeGoUsage?.thirtyDay), el => el.child(h_flex().gap(8).items_center()
        .child(div().accessibility_label("OpenCode Go").child(svg("mods/bh-providers-usage/opencode.svg").size(14)))
        .child(this.usageBar(t, "5h", this.openCodeGoUsage.fiveHour))
        .child(this.usageBar(t, "7d", this.openCodeGoUsage.sevenDay))
        .child(this.usageBar(t, "30d", this.openCodeGoUsage.thirtyDay))))
      .child(div().id("palette").text_color(t.dim).on_click(() => run("app.palette")).child(this.hint(t)));
  }
}
