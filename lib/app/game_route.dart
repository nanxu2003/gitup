import 'package:flutter/material.dart';

/// 古风主题页面路由 - 从右侧滑入 + 渐隐效果
class GamePageRoute<T> extends PageRouteBuilder<T> {
  GamePageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 350),
  }) : super(
         settings: settings,
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionDuration: duration,
         reverseTransitionDuration: const Duration(milliseconds: 300),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // 从右侧滑入
           final slideIn =
               Tween<Offset>(
                 begin: const Offset(0.3, 0.0),
                 end: Offset.zero,
               ).animate(
                 CurvedAnimation(
                   parent: animation,
                   curve: Curves.easeOutCubic,
                   reverseCurve: Curves.easeInCubic,
                 ),
               );

           // 渐隐效果
           final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
             CurvedAnimation(
               parent: animation,
               curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
               reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeIn),
             ),
           );

           // 底层页面轻微左移（视差效果）
           final slideOut =
               Tween<Offset>(
                 begin: Offset.zero,
                 end: const Offset(-0.15, 0.0),
               ).animate(
                 CurvedAnimation(
                   parent: secondaryAnimation,
                   curve: Curves.easeInOut,
                 ),
               );

           return SlideTransition(
             position: slideOut,
             child: SlideTransition(
               position: slideIn,
               child: FadeTransition(opacity: fadeIn, child: child),
             ),
           );
         },
       );
}

/// 全屏覆盖路由 - 从底部弹出（用于战斗等全屏页面）
class GameFullScreenRoute<T> extends PageRouteBuilder<T> {
  GameFullScreenRoute({required WidgetBuilder builder, RouteSettings? settings})
    : super(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideUp =
              Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              );

          return SlideTransition(position: slideUp, child: child);
        },
      );
}

/// 淡入淡出路由 - 用于对话框/剧情页面
class GameFadeRoute<T> extends PageRouteBuilder<T> {
  GameFadeRoute({required WidgetBuilder builder, RouteSettings? settings})
    : super(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );
          final scale = Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
          return FadeTransition(
            opacity: fadeIn,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
      );
}
