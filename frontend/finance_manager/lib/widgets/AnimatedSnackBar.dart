import 'package:flutter/material.dart';

class AnimatedSnackBar extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback? onDismiss;

  const AnimatedSnackBar._internal({

    required this.message,
    required this.duration,
    this.onDismiss,
    
  });

  static void show(BuildContext context, String message, {Duration? duration}) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => AnimatedSnackBar._internal(
        message: message,
        duration: duration ?? const Duration(seconds: 3),
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  @override
  State<AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    Future.delayed(widget.duration, () async {
      await _controller.reverse();
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Positioned(

      top: 50,
      left: 0,
      right: 0,

      child: SlideTransition(

        position: _slideAnimation,

        child: FadeTransition(

          opacity: _fadeAnimation,
          child: Material(

            color: Colors.transparent,

            child: Center(

              child: Container(

                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),

                decoration: BoxDecoration(

                  color: Color.fromARGB(255, 248, 247, 247),
                  borderRadius: BorderRadius.circular(12),

                  boxShadow: const [

                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),

                  ],

                ),

                child: Text(

                  widget.message,

                  style: const TextStyle(

                    color: Color(0xFF90B3E9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),

                ),
              ),
              
            ),

          ),

        ),
        
      ),

    );

  }
  
}