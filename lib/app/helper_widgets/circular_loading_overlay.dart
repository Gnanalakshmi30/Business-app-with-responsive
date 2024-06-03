import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import 'config.dart';

class CircularLoadingOverlay extends StatelessWidget {
  const CircularLoadingOverlay({super.key});


  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
        style: const TextStyle(color: Colors.black),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                // color: Colors.white.withOpacity(.8),
                color: AppColors.highlight.withOpacity(.7),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(15),
                        child: CircularProgressIndicator(
                            backgroundColor: AppColors.main)),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Text(
                          'Please wait ...',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.main),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}

class CenteredLoadingIndicator extends StatelessWidget {
  const CenteredLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: const Center(child: CircularProgressIndicator()));
  }
}

OverlaySupportEntry showLoadingOverlay() {
  return showOverlay((context, t) {
    return const CircularLoadingOverlay();
  }, duration: const Duration(seconds: 3), key: const Key('profileLoadingOverlay'));
}
