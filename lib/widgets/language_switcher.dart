import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final theme = Theme.of(context);

    return PopupMenuButton<Locale>(
      icon: Icon(
        Icons.language,
        color: theme.colorScheme.onSurface,
      ),
      onSelected: (Locale locale) {
        localeProvider.setLocale(locale);
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<Locale>(
          value: Locale('en'),
          child: Row(
            children: [
              Text('English'),
              SizedBox(width: 8),
              Text('🇬🇧', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
        const PopupMenuItem<Locale>(
          value: Locale('hi'),
          child: Row(
            children: [
              Text('हिंदी'),
              SizedBox(width: 8),
              Text('🇮🇳', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ],
    );
  }
}
