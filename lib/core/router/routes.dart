import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/app_router.dart';
import 'package:hiddify/features/common/adaptive_root_scaffold.dart';
import 'package:hiddify/features/config_option/overview/config_options_page.dart';
import 'package:hiddify/features/config_option/widget/quick_settings_modal.dart';

import 'package:hiddify/features/home/widget/home_page.dart';
import 'package:hiddify/features/intro/widget/intro_page.dart';
import 'package:hiddify/features/log/overview/logs_overview_page.dart';
import 'package:hiddify/features/per_app_proxy/overview/per_app_proxy_page.dart';
import 'package:hiddify/features/profile/add/add_profile_modal.dart';
import 'package:hiddify/features/profile/details/profile_details_page.dart';
import 'package:hiddify/features/profile/overview/profiles_overview_page.dart';
import 'package:hiddify/features/settings/account/account_page.dart';
import 'package:hiddify/features/settings/about/about_page.dart';
import 'package:hiddify/features/settings/overview/settings_overview_page.dart';
import 'package:hiddify/features/settings/protocols/protocols_settings_page.dart';
import 'package:hiddify/utils/utils.dart';

part 'routes.g.dart';

GlobalKey<NavigatorState>? _dynamicRootKey = useMobileRouter ? rootNavigatorKey : null;

@TypedShellRoute<MobileWrapperRoute>(
  routes: [
    TypedGoRoute<HomeRoute>(
      path: "/",
      name: HomeRoute.name,
      routes: [
        TypedGoRoute<AddProfileRoute>(
          path: "add",
          name: AddProfileRoute.name,
        ),
        TypedGoRoute<ProfilesOverviewRoute>(
          path: "profiles",
          name: ProfilesOverviewRoute.name,
        ),
        TypedGoRoute<NewProfileRoute>(
          path: "profiles/new",
          name: NewProfileRoute.name,
        ),
        TypedGoRoute<ProfileDetailsRoute>(
          path: "profiles/:id",
          name: ProfileDetailsRoute.name,
        ),
        TypedGoRoute<ConfigOptionsRoute>(
          path: "config-options",
          name: ConfigOptionsRoute.name,
        ),
        TypedGoRoute<QuickSettingsRoute>(
          path: "quick-settings",
          name: QuickSettingsRoute.name,
        ),
        TypedGoRoute<SettingsRoute>(
          path: "settings",
          name: SettingsRoute.name,
          routes: [
            TypedGoRoute<SettingsProtocolsRoute>(
              path: "protocols",
              name: SettingsProtocolsRoute.name,
            ),
            TypedGoRoute<SettingsConfigOptionsRoute>(
              path: "config-options",
              name: SettingsConfigOptionsRoute.name,
            ),
            TypedGoRoute<SettingsLogsRoute>(
              path: "logs",
              name: SettingsLogsRoute.name,
            ),
            TypedGoRoute<SettingsAboutRoute>(
              path: "about",
              name: SettingsAboutRoute.name,
            ),
            TypedGoRoute<SettingsAccountRoute>(
              path: "account",
              name: SettingsAccountRoute.name,
            ),
            TypedGoRoute<PerAppProxyRoute>(
              path: "per-app-proxy",
              name: PerAppProxyRoute.name,
            ),
          ],
        ),
        TypedGoRoute<LogsOverviewRoute>(
          path: "logs",
          name: LogsOverviewRoute.name,
        ),
        TypedGoRoute<AboutRoute>(
          path: "about",
          name: AboutRoute.name,
        ),
      ],
    ),
    TypedGoRoute<ProxiesRoute>(
      path: "/proxies",
      name: ProxiesRoute.name,
    ),
  ],
)
class MobileWrapperRoute extends ShellRouteData {
  const MobileWrapperRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AdaptiveRootScaffold(navigator);
  }
}

@TypedShellRoute<DesktopWrapperRoute>(
  routes: [
    TypedGoRoute<HomeRoute>(
      path: "/",
      name: HomeRoute.name,
      routes: [
        TypedGoRoute<AddProfileRoute>(
          path: "add",
          name: AddProfileRoute.name,
        ),
        TypedGoRoute<ProfilesOverviewRoute>(
          path: "profiles",
          name: ProfilesOverviewRoute.name,
        ),
        TypedGoRoute<NewProfileRoute>(
          path: "profiles/new",
          name: NewProfileRoute.name,
        ),
        TypedGoRoute<ProfileDetailsRoute>(
          path: "profiles/:id",
          name: ProfileDetailsRoute.name,
        ),
        TypedGoRoute<QuickSettingsRoute>(
          path: "quick-settings",
          name: QuickSettingsRoute.name,
        ),
      ],
    ),
    TypedGoRoute<ProxiesRoute>(
      path: "/proxies",
      name: ProxiesRoute.name,
    ),
    TypedGoRoute<ConfigOptionsRoute>(
      path: "/config-options",
      name: ConfigOptionsRoute.name,
    ),
    TypedGoRoute<SettingsRoute>(
      path: "/settings",
      name: SettingsRoute.name,
      routes: [
        TypedGoRoute<SettingsProtocolsRoute>(
          path: "protocols",
          name: SettingsProtocolsRoute.name,
        ),
        TypedGoRoute<SettingsConfigOptionsRoute>(
          path: "config-options",
          name: SettingsConfigOptionsRoute.name,
        ),
        TypedGoRoute<SettingsLogsRoute>(
          path: "logs",
          name: SettingsLogsRoute.name,
        ),
        TypedGoRoute<SettingsAboutRoute>(
          path: "about",
          name: SettingsAboutRoute.name,
        ),
        TypedGoRoute<SettingsAccountRoute>(
          path: "account",
          name: SettingsAccountRoute.name,
        ),
        TypedGoRoute<PerAppProxyRoute>(
          path: "per-app-proxy",
          name: PerAppProxyRoute.name,
        ),
      ],
    ),
    TypedGoRoute<LogsOverviewRoute>(
      path: "/logs",
      name: LogsOverviewRoute.name,
    ),
    TypedGoRoute<AboutRoute>(
      path: "/about",
      name: AboutRoute.name,
    ),
  ],
)
class DesktopWrapperRoute extends ShellRouteData {
  const DesktopWrapperRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AdaptiveRootScaffold(navigator);
  }
}

@TypedGoRoute<IntroRoute>(path: "/intro", name: IntroRoute.name)
class IntroRoute extends GoRouteData {
  const IntroRoute();
  static const name = "Intro";

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: IntroPage(),
    );
  }
}

class HomeRoute extends GoRouteData {
  const HomeRoute();
  static const name = "Home";

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(
      name: name,
      child: HomePage(),
    );
  }
}

class ProxiesRoute extends GoRouteData {
  const ProxiesRoute();
  static const name = "Proxies";

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return const SettingsProtocolsRoute().location;
  }

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(
      name: name,
      child: SizedBox.shrink(),
    );
  }
}

class AddProfileRoute extends GoRouteData {
  const AddProfileRoute({this.url});

  final String? url;

  static const name = "Add Profile";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return BottomSheetPage(
      fixed: true,
      name: name,
      builder: (controller) => AddProfileModal(
        url: url,
        scrollController: controller,
      ),
    );
  }
}

class ProfilesOverviewRoute extends GoRouteData {
  const ProfilesOverviewRoute();
  static const name = "Profiles";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return BottomSheetPage(
      name: name,
      builder: (controller) => ProfilesOverviewModal(scrollController: controller),
    );
  }
}

class NewProfileRoute extends GoRouteData {
  const NewProfileRoute();
  static const name = "New Profile";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: ProfileDetailsPage("new"),
    );
  }
}

class ProfileDetailsRoute extends GoRouteData {
  const ProfileDetailsRoute(this.id);
  final String id;
  static const name = "Profile Details";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: ProfileDetailsPage(id),
    );
  }
}

class LogsOverviewRoute extends GoRouteData {
  const LogsOverviewRoute();
  static const name = "Logs";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return const SettingsLogsRoute().location;
  }

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: SizedBox.shrink(),
      );
    }
    return const NoTransitionPage(name: name, child: SizedBox.shrink());
  }
}

class QuickSettingsRoute extends GoRouteData {
  const QuickSettingsRoute();
  static const name = "Quick Settings";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return BottomSheetPage(
      fixed: true,
      name: name,
      builder: (controller) => const QuickSettingsModal(),
    );
  }
}

class SettingsRoute extends GoRouteData {
  const SettingsRoute();
  static const name = "Settings";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: SettingsOverviewPage(),
      );
    }
    return const NoTransitionPage(name: name, child: SettingsOverviewPage());
  }
}

class SettingsProtocolsRoute extends GoRouteData {
  const SettingsProtocolsRoute();
  static const name = "Protocols";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: ProtocolsSettingsPage(),
      );
    }
    return const NoTransitionPage(
      name: name,
      child: ProtocolsSettingsPage(),
    );
  }
}

class SettingsConfigOptionsRoute extends GoRouteData {
  const SettingsConfigOptionsRoute({this.section});
  final String? section;

  static const name = "Settings Config Options";
  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return MaterialPage(
        name: name,
        child: ConfigOptionsPage(section: section),
      );
    }
    return NoTransitionPage(
      name: name,
      child: ConfigOptionsPage(section: section),
    );
  }
}

class SettingsLogsRoute extends GoRouteData {
  const SettingsLogsRoute();
  static const name = "Settings Logs";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: LogsOverviewPage(),
      );
    }
    return const NoTransitionPage(
      name: name,
      child: LogsOverviewPage(),
    );
  }
}

class SettingsAboutRoute extends GoRouteData {
  const SettingsAboutRoute();
  static const name = "Settings About";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: AboutPage(),
      );
    }
    return const NoTransitionPage(
      name: name,
      child: AboutPage(),
    );
  }
}

class SettingsAccountRoute extends GoRouteData {
  const SettingsAccountRoute();
  static const name = "Account";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: SettingsAccountPage(),
      );
    }
    return const NoTransitionPage(
      name: name,
      child: SettingsAccountPage(),
    );
  }
}

class ConfigOptionsRoute extends GoRouteData {
  const ConfigOptionsRoute({this.section});
  final String? section;
  static const name = "Config Options";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return SettingsConfigOptionsRoute(section: section).location;
  }

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(name: name, child: SizedBox.shrink());
    }
    return const NoTransitionPage(name: name, child: SizedBox.shrink());
  }
}

class PerAppProxyRoute extends GoRouteData {
  const PerAppProxyRoute();
  static const name = "Per-app Proxy";

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: PerAppProxyPage(),
    );
  }
}

class AboutRoute extends GoRouteData {
  const AboutRoute();
  static const name = "About";

  static final GlobalKey<NavigatorState>? $parentNavigatorKey = _dynamicRootKey;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    return const SettingsAboutRoute().location;
  }

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(name: name, child: SizedBox.shrink());
    }
    return const NoTransitionPage(name: name, child: SizedBox.shrink());
  }
}
