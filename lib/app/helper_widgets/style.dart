// import config.dart file
import 'package:aquila_hundi/app/helper_widgets/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

/// App level styles and widgets
class AppStyle {
  /// InputDecoration for App level textFields
  static InputDecoration inputDecoration(
    BuildContext context,
    String placeholder, {
    String? errorText,
    Color borderColor = Colors.black,
    bool isLandscape = false,
    Widget? suffixIcon,
    Widget? prefixIcon,

  }) {
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(isLandscape
            ? AppConfig.landSize(context, 32)
            : AppConfig.size(context, 32)),
        borderSide: BorderSide(
          color: borderColor,
          width:
              1, // Removed border, if you need add border again, you can modify the width
          style: BorderStyle.solid,
        ));
    return InputDecoration(
        fillColor: Colors.white,
        filled: true,
        errorText: errorText,
        errorStyle: const TextStyle(color: AppColors.highlight),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: InputBorder.none,
        labelText: placeholder,
        labelStyle: TextStyle(
            fontSize: isLandscape
                ? AppConfig.landSize(context, 14)
                : AppConfig.size(context, 14),
            color: Colors.grey[700]),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConfig.size(context, 20),
          vertical: AppConfig.size(context, 6),
        ),
        enabledBorder: border,
        disabledBorder: border,
        focusedBorder: border,
        errorBorder: border,
        focusedErrorBorder: border,
        prefixIcon: prefixIcon);
  }

  /// Main style of button ex: rounded yellow color button
  static Widget mainButton(
    BuildContext context,
    String text, {
    Function()? onPressed,
    Color fillColor = AppColors.highlight,
    double left = 30,
    double top = 20,
    double right = 30,
    double bottom = 20,
    double width = double.infinity,
    double height = 50,
    bool isLandscape = false,
    IconData? icon,
    Color? iconColor,
    double fontSize = 18,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isLandscape
            ? AppConfig.landSize(context, left)
            : AppConfig.size(context, left),
        isLandscape
            ? AppConfig.landSize(context, top)
            : AppConfig.size(context, top),
        isLandscape
            ? AppConfig.landSize(context, right)
            : AppConfig.size(context, right),
        isLandscape
            ? AppConfig.landSize(context, bottom)
            : AppConfig.size(context, bottom),
      ),
      child: SizedBox(
        width: width,
        height: AppConfig.size(context, height),
        child: RawMaterialButton(
          fillColor: fillColor,
          elevation: 5.0,
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(isLandscape
                  ? AppConfig.landSize(context, 32)
                  : AppConfig.size(context, 32)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              label(context, text,
                  color: Colors.white,
                  fontSize: isLandscape
                      ? AppConfig.landSize(context, fontSize)
                      : AppConfig.size(context, fontSize),
                  right: isLandscape
                      ? AppConfig.landSize(context, 10)
                      : AppConfig.size(context, 10),
                  left: isLandscape
                      ? AppConfig.landSize(context, 10)
                      : AppConfig.size(context, 10)),
              if (icon != null) Icon(icon, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }

  /// Outline button
  static Widget outlineButton(
    BuildContext context,
    String text, {
    Function()? onPressed,
    Color color = Colors.white,
    double left = 30,
    double top = 0,
    double right = 30,
    double bottom = 30,
    double width = double.infinity,
    double height = 50,
    bool isLandscape = false,
    IconData? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isLandscape
            ? AppConfig.landSize(context, left)
            : AppConfig.size(context, left),
        isLandscape
            ? AppConfig.landSize(context, top)
            : AppConfig.size(context, top),
        isLandscape
            ? AppConfig.landSize(context, right)
            : AppConfig.size(context, right),
        isLandscape
            ? AppConfig.landSize(context, bottom)
            : AppConfig.size(context, bottom),
      ),
      child: SizedBox(
        width: width,
        height: AppConfig.size(context, height),
        child: RawMaterialButton(
          elevation: 5.0,
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: color),
              borderRadius: BorderRadius.all(Radius.circular(isLandscape
                  ? AppConfig.landSize(context, 32)
                  : AppConfig.size(context, 32)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              label(
                context,
                text,
                color: color,
                fontSize: isLandscape
                    ? AppConfig.landSize(context, 18)
                    : AppConfig.size(context, 18),
                right: isLandscape
                    ? AppConfig.landSize(context, 10)
                    : AppConfig.size(context, 10),
                left: isLandscape
                    ? AppConfig.landSize(context, 10)
                    : AppConfig.size(context, 10),
              ),
              if (icon != null) Icon(icon, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }

  static Widget smallButton(
    BuildContext context,
    String text, {
    Function()? onPressed,
    Color fillColor = AppColors.main,
    double left = 5,
    double top = 20,
    double right = 5,
    double bottom = 5,
    double width = 120,
    double height = 30,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: AppConfig.size(context, width),
          height: AppConfig.size(context, height),
          decoration: BoxDecoration(
              color: fillColor, borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: label(context, text,
                color: Colors.white, fontSize: 12, right: 10, left: 10),
          ),
        ),
      ),
    );
  }

  /// App level default app bar with [title], optional [isUnderline]
  static PreferredSizeWidget? appBar(
    String title, {
    bool isUnderline = true,
    List<Widget>? actions,
    bool leadingIcon = true,
    bool centerTitle = false,
    double titleSize = 20,
    Color iconColor = Colors.white,
  }) {
    return AppBar(
      centerTitle: centerTitle,
      backgroundColor: AppColors.main,
      automaticallyImplyLeading: leadingIcon,
      title: Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontFamily: AppConfig.fontName,
            fontSize: titleSize),
      ),
      iconTheme: IconThemeData(color: iconColor),
      bottom: isUnderline
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: Colors.white.withOpacity(0.2),
                height: 1,
              ),
            )
          : null,
      elevation: isUnderline ? 4 : 0,
      actions: actions,
    );
  }

  /// App level default app bar with [title], optional [isUnderline]
  static PreferredSizeWidget? appBarWithIcons(String title,
      {bool isUnderline = true,
      Function()? action1,
      Function()? action2,
      bool isAlert = false}) {
    return appBar(title, isUnderline: isUnderline, actions: [
      InkWell(
        onTap: action1,
        child: const Icon(
          Icons.location_on_outlined,
          size: 26.0,
        ),
      ),
      TextButton(
        onPressed: action2,
        child: Stack(
          children: [
            const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 30,
            ),
            Positioned(
                right: 2,
                top: 1,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 2, color: AppColors.main),
                      color: AppColors.main),
                  child: isAlert
                      ? const Icon(
                          Icons.circle,
                          color: AppColors.highlight,
                          size: 12,
                        )
                      : null,
                ))
          ],
        ),
      )
    ]);
  }

  static Widget textField(
      BuildContext context, TextInputType inputType, String placeholder,
      {bool isSecure = false,
      double left = 30,
      double right = 30,
      double top = 0,
      double bottom = 20,
      double? fontSize,
      String? errorText,
        TextInputAction? textInputAction,
        List<TextInputFormatter>? inputFormatters,
      bool autofocus = false,
      TextEditingController? controller,
      int? maxLines = 1,
      bool revealPassword = false,
      String iconName = '',
      bool enabled = true,
      Color iconColor = Colors.grey,
      Color borderColor = Colors.black,
      Function()? onEditingComplete,
      Function(String)? onSubmitted,
      bool isLandscape = false,
      bool obscureText = false,
      Function()? onChangedEyeIcon}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: StreamBuilder(
        // stream: authBloc.emailStream,
        builder: (context, snapshot) => TextField(
          controller: controller,
          keyboardType: inputType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          autofocus: autofocus,
          inputFormatters: inputFormatters,
          enabled: enabled,
          decoration: inputDecoration(
            borderColor: borderColor,
            context,
            placeholder,
            errorText: errorText,
            isLandscape: isLandscape,
            suffixIcon: isSecure
                ? IconButton(
                    onPressed: () {
                      if (onChangedEyeIcon != null) onChangedEyeIcon();
                    },
                    icon: Icon(revealPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                  )
                : null,
              prefixIcon: Padding(
                      padding: EdgeInsets.only(
                          left: AppConfig.size(context, 20),
                          right: AppConfig.size(context, 10)),
                      child: Icon(
                        // use iconName to change the icon
                        iconName == 'phone' ? Icons.phone : iconName == 'person' ? Icons.person : iconName =='email' ? Icons.email : Icons.lock,
                        color: iconColor,
                      )
          ),
          ),
          onEditingComplete: onEditingComplete,
          onSubmitted: onSubmitted,
          maxLines: maxLines,
          style: TextStyle(fontSize: fontSize),
        ),
        stream: null,
      ),
    );
  }

  static Widget label(BuildContext context, dynamic text,
      {double fontSize = 16,
      TextAlign align = TextAlign.center,
      Color? color = AppColors.main,
      double left = 0,
      double right = 0,
      double top = 0,
      double bottom = 0,
      FontWeight weight = FontWeight.normal,
      FontStyle? fontStyle,
      TextDecoration? decoration,
      int? maxLines,
      TextOverflow? textOverflow,
      double? lineHeight = 1,
      bool isLandscape = false}) {
    return Padding(
      padding: EdgeInsets.only(
          left: isLandscape
              ? AppConfig.landSize(context, left)
              : AppConfig.size(context, left),
          right: isLandscape
              ? AppConfig.landSize(context, right)
              : AppConfig.size(context, right),
          top: isLandscape
              ? AppConfig.landSize(context, top)
              : AppConfig.size(context, top),
          bottom: isLandscape
              ? AppConfig.landSize(context, bottom)
              : AppConfig.size(context, bottom)),
      child: Text(
        text == null ? "" : '$text',
        textAlign: align,
        style: TextStyle(
          fontSize: isLandscape
              ? AppConfig.landSize(context, fontSize)
              : AppConfig.size(context, fontSize),
          fontWeight: weight,
          fontFamily: AppConfig.fontName,
          decoration: decoration,
          color: color,
          height: lineHeight,
          fontStyle: fontStyle,
        ),
        maxLines: maxLines,
        overflow: textOverflow,
      ),
    );
  }

  /// App level default dropdown
  static Widget dropDown(
    BuildContext context,
    dynamic value,
    List<DropdownMenuItem> optionList,
    Function(dynamic) onChanged, {
    double? itemHeight,
    double bottom = 20.0,
    double horizontal = 25,
    double vertical = 5,
    Border? border,
    double borderRadius = 25,
  }) {
    return Padding(
      padding: EdgeInsets.only(
          left: 30, right: 30, bottom: AppConfig.size(context, bottom)),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: AppConfig.size(context, horizontal),
            vertical: AppConfig.size(context, vertical)),
        decoration: BoxDecoration(
            color: Colors.white,
            border: border,
            borderRadius:
                BorderRadius.circular(AppConfig.size(context, borderRadius))),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
              itemHeight: itemHeight,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: AppConfig.size(context, 30),
              ),
              iconSize: AppConfig.size(context, 12),
              items: optionList,
              value: value,
              isExpanded: true,
              onChanged: onChanged,
              style: TextStyle(
                  fontSize: AppConfig.size(context, 14),
                  color: Colors.grey[700],
                  fontFamily: AppConfig.fontName),
              ),
        ),
      ),
    );
  }

  static Widget roundedLabel(BuildContext context, String text,
      {Color fillColor = AppColors.highlight,
      Color color = Colors.white,
      double? width}) {
    return Container(
      height: AppConfig.size(context, 21),
      width: width,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(42)),
        color: fillColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConfig.size(context, 12)),
        child: Center(
          child: AppStyle.label(
            context,
            text,
            fontSize: 7,
            color: color,
          ),
        ),
      ),
    );
  }

  //White rounded board
  static Widget roundedContainer(
    BuildContext context,
    Widget child, {
    double? height,
    double? width,
    Color color = Colors.white,
    double left = 10,
    double right = 10,
    double top = 10,
    double bottom = 10,
    double bottomPadding = 8,
    double cornerRadius = 5,
  }) {
    assert(width != null);
    return Padding(
      padding: EdgeInsets.only(
        left: AppConfig.size(context, left),
        right: AppConfig.size(context, right),
        top: AppConfig.size(context, top),
        bottom: AppConfig.size(context, bottom),
      ),
      child: Container(
        height: height != null ? AppConfig.size(context, height) : null,
        width: width != null ? AppConfig.size(context, width) : null,
        decoration: BoxDecoration(
            color: color,
            border: Border.all(color: color),
            borderRadius: BorderRadius.all(
                Radius.circular(AppConfig.size(context, cornerRadius)))),
        child: Padding(
          padding: EdgeInsets.only(
            left: AppConfig.size(context, 5),
            right: AppConfig.size(context, 5),
            top: AppConfig.size(context, 5),
            bottom: AppConfig.size(context, bottomPadding),
          ),
          child: child,
        ),
      ),
    );
  }

  static final divider = Divider(color: Colors.black.withOpacity(0.2));

  static Widget svgIconButton(
    BuildContext context, {
    required String imgUrl,
    Function()? onTap,
    double? width,
    double? height,
    double left = 10,
    double right = 10,
    double top = 10,
    double bottom = 10,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppConfig.size(context, left),
          right: AppConfig.size(context, right),
          top: AppConfig.size(context, top),
          bottom: AppConfig.size(context, bottom),
        ),
        child: SvgPicture.asset(
          imgUrl,
          width: width != null ? AppConfig.size(context, width) : null,
          height: height != null ? AppConfig.size(context, height) : null,
        ),
      ),
    );
  }

  static Widget iconButton(
    BuildContext context, {
    required IconData icon,
    Function()? onTap,
    double size = 30,
    double left = 10,
    double right = 10,
    double top = 10,
    double bottom = 10,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppConfig.size(context, left),
          right: AppConfig.size(context, right),
          top: AppConfig.size(context, top),
          bottom: AppConfig.size(context, bottom),
        ),
        child: Icon(
          icon,
          color: color,
          size: AppConfig.size(context, size),
        ),
      ),
    );
  }

  static Widget roundedButton(
    BuildContext context, {
    required IconData icon,
    Function()? onTap,
    Color bgColor = const Color(0xff4caf50),
    Color iconColor = Colors.white,
    double size = 30,
    double left = 10,
    double right = 10,
    double top = 10,
    double bottom = 10,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppConfig.size(context, left),
          right: AppConfig.size(context, right),
          top: AppConfig.size(context, top),
          bottom: AppConfig.size(context, bottom),
        ),
        child: CircleAvatar(
          backgroundColor: bgColor,
          radius: AppConfig.size(context, size),
          child: Icon(
            icon,
            size: AppConfig.size(context, size),
            color: iconColor,
          ),
        ),
      ),
    );
  }

  static Widget svgRoundedButton(
    BuildContext context, {
    Color color = Colors.white,
    double? width,
    double? height,
    String? imgUrl,
    Function()? onTap,
  }) {
    return SizedBox(
      width: AppConfig.size(context, 80),
      height: AppConfig.size(context, 80),
      child: RawMaterialButton(
        onPressed: onTap,
        fillColor: AppColors.main,
        //Color(0xffFEB934),
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.size(context, 40))),
        child: SvgPicture.asset(
          imgUrl!,
          width: width != null ? AppConfig.size(context, width) : null,
          height: height != null ? AppConfig.size(context, height) : null,
        ),
      ),
    );
  }

  static Widget svgButtonOne(
    BuildContext context,
    String text, {
    Color color = Colors.white,
    double? width,
    double? height,
    String? imgUrl,
    Function()? onTap,
  }) {
    return SizedBox(
      width: AppConfig.size(context, 350),
      height: AppConfig.size(context, 55),
      child: RawMaterialButton(
        onPressed: onTap,
        fillColor: AppColors.main,
        //Color(0xffFEB934),
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.size(context, 40))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(width: AppConfig.size(context, 60)),
            SvgPicture.asset(
              imgUrl!,
              color: Colors.white,
              width: AppConfig.size(context, width!),
              height: AppConfig.size(context, height!),
            ),
            SizedBox(width: AppConfig.size(context, 10)),
            AppStyle.label(
              context,
              text,
              fontSize: AppConfig.size(context, 16),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  static Widget svgOutLineButton(
    BuildContext context,
    String text, {
    Color color = Colors.white,
    double? width,
    double? height,
    String? imgUrl,
    Color? iconColor = AppColors.main,
    Function()? onTap,
  }) {
    return SizedBox(
      width: AppConfig.size(context, 350),
      height: AppConfig.size(context, 55),
      child: OutlinedButton(
        onPressed: onTap,

        style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0))),
          side: MaterialStateProperty.all(const BorderSide(
              color: AppColors.main, width: 1.0, style: BorderStyle.solid)),
        ),
        // fillColor: AppColors.main, //Color(0xffFEB934),
        // elevation: 5,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(width: AppConfig.size(context, 60)),
            SvgPicture.asset(
              imgUrl!,
                  // ignore: deprecated_member_use
                  color: iconColor,
              width: AppConfig.size(context, width!),
              height: AppConfig.size(context, height!),
            ),
            SizedBox(width: AppConfig.size(context, 30)),
            AppStyle.label(
              context,
              text,
              fontSize: AppConfig.size(context, 18),
              color: AppColors.main,
            ),
          ],
        ),
      ),
    );
  }

  static Widget svgOutLineButtonOne(
    BuildContext context,
    String text, {
    Color color = Colors.white,
    double? width,
    double? height,
    String? imgUrl,
    Function()? onTap,
  }) {
    return SizedBox(
      width: AppConfig.size(context, 350),
      height: AppConfig.size(context, 55),
      child: OutlinedButton(
        onPressed: onTap,

        style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0))),
          side: MaterialStateProperty.all(const BorderSide(
              color: AppColors.main, width: 1.0, style: BorderStyle.solid)),
        ),
        // fillColor: AppColors.main, //Color(0xffFEB934),
        // elevation: 5,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(width: AppConfig.size(context, 60)),
            SvgPicture.asset(
              imgUrl!,
              // ignore: deprecated_member_use
              color: AppColors.main,
              width: AppConfig.size(context, width!),
              height: AppConfig.size(context, height!),
            ),
            SizedBox(width: AppConfig.size(context, 10)),
            AppStyle.label(
              context,
              text,
              fontSize: AppConfig.size(context, 16),
              color: AppColors.main,
            ),
          ],
        ),
      ),
    );
  }
}
