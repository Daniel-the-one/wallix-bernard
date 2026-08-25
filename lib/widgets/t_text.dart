
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class TText extends StatelessWidget {
  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;



  final Map<String, String>? args;

  const TText(
    this.textKey, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.args,
  });


  static AppLocalizations of(BuildContext context) => AppLocalizations.of(context);

  @override
  Widget build(BuildContext context) {
    String localized = AppLocalizations.of(context).translate(textKey);
    args?.forEach((key, value) {
      localized = localized.replaceAll('{$key}', value);
    });
    return Text(
      localized,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
