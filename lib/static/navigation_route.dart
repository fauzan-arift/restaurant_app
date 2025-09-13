enum NavigationRoute {
  mainRoute("/main"),
  detailRoute("/detail"),
  favoriteRoute("/favorite"),
  settingsRoute("/settings");

  const NavigationRoute(this.name);
  final String name;
}
