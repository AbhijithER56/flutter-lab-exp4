{{flutter_js}}
{{flutter_build_config}}

// Load the CanvasKit renderer bundled with the build (build/web/canvaskit/)
// instead of Google's CDN, so the app works offline / behind firewalls and
// on GitHub Pages without any external dependency.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
});
