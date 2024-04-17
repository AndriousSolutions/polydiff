import 'package:fluttery_framework/view.dart';
import 'package:polydiff/components/login_fields.dart';

class HomePage extends StatelessWidget {
  final String appName = 'PolyDiff';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    Container loginFields = Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(20),
      child: const LoginFields(),
    );

    return PopScope(
      canPop: false, // Prevents the user from navigating back
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SizedBox(
            width: screenWidth * 0.4 > 200 ? screenWidth * 0.4 : 200,
            child: ListView(
              shrinkWrap: true,
              children: [
                appTitleDisplay,
                SizedBox(height: 20),
                loginFields,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get appTitleDisplay {
    final smallScreen = App.inSmallScreen;
    final children = [
      Flexible(
        child: Image.asset(
          'assets/images/logo1.png',
          height: 20.h,
        ),
      ),
//        SizedBox(width: 50),
      Flexible(
        child: Text(
          appName,
          style:
              TextStyle(fontSize: smallScreen ? 28 : 64, color: Colors.white),
        ),
      ),
    ];

    return smallScreen
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: children,
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          );
  }
}
