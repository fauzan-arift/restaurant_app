enum NavigationRoute {
  mainRoute("/main"),
  detailRoute("/detail"),
  favoriteRoute("/favorite");

  const NavigationRoute(this.name);
  final String name;
}
