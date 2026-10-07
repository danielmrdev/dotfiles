# QML Implementation Standards

Read when creating or changing hosted QML, process execution, remote data, or asynchronous state. The installed Omarchy shell and the target repository remain the source of truth; apply only rules relevant to the changed path.

## Hosted components and state

- Use the host's QML `Item` or Omarchy UI base component for plugin entry points. Never create a second `ShellRoot` or launch another Quickshell process.
- Inspect the installed host contract before using injected properties, services, lifecycle hooks, or IPC. Host-injected values may arrive after component loading: give them safe initial values and guard access. Use `required` only when the installed host guarantees the property at construction.
- Keep hover, selection, open, and other interaction state local to each widget/monitor instance. Put shared polling and remote/process state in one appropriate service. Give persistent state an explicit owner and removal/reset behavior.
- Reuse `qs.Ui` components and `qs.Commons` semantic theme/layout tokens. Omarchy applies the active theme automatically; never hardcode colors sampled from references or add manual theme-switch logic. Use installed spacing and fitted-sizing helpers for variable text/monitor scales; check the installed API rather than copying implementation details from a different Omarchy release.
- Reuse Omarchy's installed icon providers/fonts rather than emoji or arbitrary Unicode symbols. Keep animation tied to user action or meaningful state change.

## Dynamic content and trust boundaries

- Render external or persisted strings as plain text. Set `textFormat: Text.PlainText` on QML text sinks that display device names, window/app metadata, filenames, clipboard contents, remote fields, helper output, or user-entered values. Shared shell controls may not expose this setting; sanitize and bound values before handing them off.
- Use rich text only when required. Escape every dynamic value for the correct markup context; never concatenate untrusted strings into markup.
- Bound text, arrays, process output, network responses, and IPC/settings input before building models or rendering. Validate types and numeric ranges; keep offline, unauthenticated, unsupported, empty, partial, and failed states distinct when they matter.
- Treat image paths and URLs as data access. Use trusted theme/image providers or validate and bound resources before loading; do not pass arbitrary external values directly to image loaders.
- Keep secrets and credential-bearing command output out of QML properties, logs, notifications, and user-visible errors.

## Processes and asynchronous work

- Prefer the shell's process APIs with an executable and argument list. Avoid building `bash -c` command strings from data. If a shell is essential, isolate the boundary, quote every external value with the supported helper, and explain why the shell is needed.
- Bound process duration and collected output; inspect exit status and stderr. Do not launch duplicate work on every widget instance or poll aggressively without a clear lifecycle.
- Handle completion after close, disable, reload, or a newer request. Cancel work where supported, or reject stale results with a request/generation token. Ensure repeated refreshes and failures cannot create unbounded retries or queues.

## Verification

- Keep pure parsing/model transformations testable separately from QML where practical. Use deterministic fixtures for valid, empty, malformed, partial, and failure outputs.
- For asynchronous behavior, test the relevant race (for example stale completion after reload, repeated refresh, or disable while a helper runs). Do not add a test framework solely for hypothetical future tests; use the repository's existing checks.
- Run `qmllint` against the installed shell imports. Static checks establish syntax/import expectations, not actual host lifecycle or appearance. Report runtime behavior only when observed in Omarchy.
