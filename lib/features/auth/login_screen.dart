import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/router/app_router.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/responsive.dart';
import 'package:farm_buddy/models/enums.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/widgets/brand/farm_buddy_logo.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/buttons/secondary_button.dart';
import 'package:farm_buddy/widgets/illustrations/field_scene.dart';

/// Two fields and three buttons. Nothing else.
///
/// The language chooser sits above the form on purpose: a farmer should be
/// able to switch to Tamil or Hindi *before* being asked to read anything.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _idError;
  String? _passwordError;
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate(AppStrings s) {
    final String id = _idController.text.trim();
    final String password = _passwordController.text;

    final bool looksLikePhone = RegExp(r'^[0-9]{10}$').hasMatch(id);
    final bool looksLikeEmail =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(id);

    setState(() {
      _idError = (looksLikePhone || looksLikeEmail) ? null : s('auth.errorMobile');
      _passwordError = password.length >= 4 ? null : s('auth.errorPassword');
    });

    return _idError == null && _passwordError == null;
  }

  Future<void> _continue(AppStrings s) async {
    FocusScope.of(context).unfocus();
    if (!_validate(s)) return;

    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _busy = false);
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings s = ref.watch(stringsProvider);
    final AppLanguage language = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: <Widget>[
          if (!context.isCompactHeight)
            const Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(opacity: 0.55, child: FieldScene(height: 150)),
            ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.huge),
              child: ResponsiveCenter(
                maxWidth: 480,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: AppSpacing.lg),

                    // ------------------------------------- language pills
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        for (final AppLanguage lang in AppLanguage.values)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _LanguagePill(
                              label: lang.nativeName,
                              selected: lang == language,
                              onTap: () => ref
                                  .read(languageProvider.notifier)
                                  .state = lang,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                    const Center(child: FarmBuddyLogo(size: 72)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      s('auth.title'),
                      style: AppText.h1,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      s('auth.subtitle'),
                      style: AppText.bodySm,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ------------------------------------------- identity
                    _FieldLabel(text: s('auth.mobileLabel')),
                    TextField(
                      controller: _idController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      style: AppText.bodyStrong,
                      inputFormatters: <TextInputFormatter>[
                        LengthLimitingTextInputFormatter(60),
                      ],
                      decoration: InputDecoration(
                        hintText: s('auth.mobileHint'),
                        prefixIcon: const Icon(Icons.phone_iphone_rounded),
                        errorText: _idError,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ------------------------------------------- password
                    _FieldLabel(text: s('auth.passwordLabel')),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      style: AppText.bodyStrong,
                      onSubmitted: (_) => _continue(s),
                      decoration: InputDecoration(
                        hintText: s('auth.passwordHint'),
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: s('auth.continue'),
                      isLoading: _busy,
                      onPressed: () => _continue(s),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SecondaryButton(
                      label: s('auth.createAccount'),
                      onPressed: () => _continue(s),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: <Widget>[
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(s('auth.or'), style: AppText.caption),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    SecondaryButton(
                      label: s('auth.google'),
                      icon: Icons.g_mobiledata_rounded,
                      onPressed: () => context.go(AppRoutes.home),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      s('auth.terms'),
                      style: AppText.caption,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, left: 2),
      child: Text(text, style: AppText.bodySmStrong),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: AppRadius.rPill,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rPill,
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.rPill,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppText.bodySmStrong.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
