import { View, div, image, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { theme, run, props, updates, layout, window, nextCommand } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// The sidebar shows either Spaces and Agents, or the focus list (bh-focus): a stack in the layout.
const focusing = () => find(layout(), "sidebar-lists")?.active === "focus";
const switchSidebar = () => run("layout.select", { stack: "sidebar-lists", child: focusing() ? "lists" : "focus" });

export default class WorkspaceChrome extends View {
  init(_props, cx) {
    // Only the brand bar's copy takes `bh-chrome.sidebar`; the footer's has nothing to switch.
    if (props()?.footer) return;
    cx.spawn(async (cx) => {
      for (;;) {
        if (await nextCommand() === "sidebar") switchSidebar();
        cx.notify();
      }
    });
  }

  render() {
    const t = theme();
    if (props()?.footer) {
      const row = (id, icon, label, action) => h_flex().id(id).relative().h(30).px(8).gap(8).items_center().rounded(8)
        .role("button").accessibility_label(label)
        .text_color(t.muted).hover(s => s.bg(t.hover).text_color(t.foreground))
        .on_click(action).child(h_flex().size(18).flex_none().items_center().justify_center()
          .child(svg(`mods/bh-chrome/${icon}.svg`).size(16)))
        .child(div().flex_1().min_w(0).truncate().child(label));
      return v_flex().size_full().bg(t.chrome).border_t(1).border_color(t.border).px(8).pt(4).pb(6).text_size(13)
        .child(row("settings", "settings", "Settings", () => run("app.settings"))
          .when(Boolean(updates().app.ready), el => el.child(div().size(6).rounded_full().bg(t.accent))));
    }
    // Keep the logo visible, leaving room for macOS window buttons and the controls at the right.
    const focus = focusing();
    return h_flex().id("brand").size_full().bg(t.chrome).pl(14).pr(10).gap(2).items_center().justify_end()
      .when(window()?.platform === "macos", el => el.pl(76))
      .child(h_flex().flex_1().gap(8).items_center()
        .child(image("frame/welcome/herdr.png").size(20).rounded(5))
        .child(div().font_semibold().text_color(t.foreground).child("Herdr")))
      .child(div().id("sidebar-mode").size(26).flex_none().flex().items_center().justify_center().rounded(6)
        .text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
        .role("button").accessibility_label(focus ? "Show spaces and agents" : "Show focus list")
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .on_click(switchSidebar)
        .child(svg(`mods/workspace-chrome/${focus ? "layers" : "circle-check"}.svg`).size(14)))
      .child(div().id("sidebar-toggle").size(26).flex_none().flex().items_center().justify_center().rounded(6)
        .text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
        .role("button").accessibility_label("Hide sidebar")
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .on_click(() => run("layout.toggle", { id: "sidebar" }))
        .child(svg("mods/workspace-chrome/sidebar.svg").size(14)));
  }
}
