import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:farm_buddy/core/constants/app_config.dart';
import 'package:farm_buddy/core/l10n/app_strings.dart';
import 'package:farm_buddy/core/router/app_router.dart';
import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/core/utils/formatters.dart';
import 'package:farm_buddy/core/utils/responsive.dart';
import 'package:farm_buddy/models/crop.dart';
import 'package:farm_buddy/providers/app_providers.dart';
import 'package:farm_buddy/providers/crop_providers.dart';
import 'package:farm_buddy/widgets/buttons/primary_button.dart';
import 'package:farm_buddy/widgets/buttons/secondary_button.dart';
import 'package:farm_buddy/widgets/cards/crop_card.dart';
import 'package:farm_buddy/widgets/cards/location_card.dart';
import 'package:farm_buddy/widgets/common/app_header.dart';
import 'package:farm_buddy/widgets/common/crop_photo.dart';
import 'package:farm_buddy/widgets/common/emoji_text.dart';

/// Crop + Quantity + Photo + Location. That is the whole product input.
///
/// Everything on this screen exists to make those four things fast: a picker
/// instead of typing, quantity shortcuts instead of a keypad, one photo
/// button, and a location that is already filled in.
class AddCropScreen extends ConsumerStatefulWidget {
  const AddCropScreen({super.key});

  @override
  ConsumerState<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends ConsumerState<AddCropScreen> {
  final TextEditingController _quantityController =
      TextEditingController(text: '500');

  Crop? _crop;
  String? _photoPath;
  String _location = AppConfig.defaultLocation;
  bool _detectingLocation = false;
  String? _cropError;
  String? _quantityError;

  static const List<double> _quickQuantities = <double>[100, 250, 500, 1000];

  @override
  void initState() {
    super.initState();
    // Carry over whatever the farmer already told us.
    final CropListing? existing = ref.read(currentListingProvider);
    if (existing != null) {
      _crop = existing.crop;
      _photoPath = existing.photoPath;
      _location = existing.locationName;
      if (existing.quantityKg > 0) {
        _quantityController.text = existing.quantityKg.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  double get _quantity =>
      double.tryParse(_quantityController.text.trim()) ?? 0;

  int get _completedSteps {
    int steps = 0;
    if (_crop != null) steps++;
    if (_quantity > 0) steps++;
    if (_photoPath != null) steps++;
    if (_location.isNotEmpty) steps++;
    return steps;
  }

  // ------------------------------------------------------------ actions

  Future<void> _pickCrop(AppStrings s) async {
    final List<Crop> crops = ref.read(allCropsProvider);
    final Crop? chosen = await showModalBottomSheet<Crop>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(s('addCrop.selectCropTitle'), style: AppText.h2),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        for (final Crop crop in crops)
                          CropCard(
                            crop: crop,
                            displayName: s(crop.nameKey),
                            selected: crop.id == _crop?.id,
                            onTap: () => Navigator.of(context).pop(crop),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (chosen != null && mounted) {
      setState(() {
        _crop = chosen;
        _cropError = null;
      });
    }
  }

  Future<void> _pickPhoto(AppStrings s) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(s('addCrop.photoLabel'), style: AppText.h2),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: s('addCrop.takePhoto'),
                  icon: Icons.photo_camera_rounded,
                  onPressed: () =>
                      Navigator.of(context).pop(ImageSource.camera),
                ),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(
                  label: s('addCrop.chooseGallery'),
                  icon: Icons.photo_library_outlined,
                  onPressed: () =>
                      Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null || !mounted) return;

    try {
      final XFile? file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (file != null) {
        setState(() => _photoPath = file.path);
      }
    } catch (_) {
      // No camera, no permission, emulator without a gallery — the demo must
      // keep moving, so fall back to the built-in sample and say so.
      if (!mounted) return;
      setState(() => _photoPath = CropPhoto.demoPath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s('addCrop.cameraUnavailable'))),
      );
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _detectingLocation = true);
    await Future<void>.delayed(AppConfig.shortLatency);
    if (!mounted) return;
    setState(() {
      _detectingLocation = false;
      _location = AppConfig.defaultLocation;
    });
  }

  void _submit(AppStrings s) {
    FocusScope.of(context).unfocus();

    setState(() {
      _cropError = _crop == null ? s('addCrop.errorCrop') : null;
      _quantityError = _quantity > 0 ? null : s('addCrop.errorQuantity');
    });
    if (_cropError != null || _quantityError != null) return;

    final CropListing listing = CropListing(
      id: 'listing-${DateTime.now().microsecondsSinceEpoch}',
      crop: _crop!,
      quantityKg: _quantity,
      photoPath: _photoPath,
      locationName: _location,
      createdAt: DateTime.now(),
    );
    ref.read(currentListingProvider.notifier).replace(listing);

    // With a photo we can check the crop first; without one we go straight to
    // the money question.
    if (listing.hasPhoto) {
      context.push(AppRoutes.cropHealth);
    } else {
      context.go(AppRoutes.markets);
    }
  }

  // ------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final AppStrings s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: s('addCrop.title'),
        subtitle: s('addCrop.subtitle'),
        onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: <Widget>[
            ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // ------------------------------------------ progress
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _completedSteps / CropListing.totalSteps,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceAlt,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        s.withArgs('addCrop.step', <String, String>{
                          'current': '$_completedSteps',
                          'total': '${CropListing.totalSteps}',
                        }),
                        style: AppText.caption,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ---------------------------------------------- crop
                  _Label(text: s('addCrop.cropLabel')),
                  _SelectField(
                    hint: s('addCrop.cropHint'),
                    value: _crop == null ? null : s(_crop!.nameKey),
                    leading: _crop?.emoji,
                    error: _cropError,
                    onTap: () => _pickCrop(s),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ------------------------------------------ quantity
                  _Label(text: s('addCrop.quantityLabel')),
                  TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: AppText.priceSm,
                    onChanged: (_) => setState(() => _quantityError = null),
                    decoration: InputDecoration(
                      hintText: s('addCrop.quantityHint'),
                      errorText: _quantityError,
                      prefixIcon: const Icon(Icons.scale_outlined),
                      suffixText: 'kg',
                      suffixStyle: AppText.bodyStrong,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: <Widget>[
                      for (final double q in _quickQuantities)
                        _QuantityChip(
                          label: Fmt.kilos(q),
                          selected: _quantity == q,
                          onTap: () {
                            setState(() {
                              _quantityController.text = q.toStringAsFixed(0);
                              _quantityError = null;
                            });
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // --------------------------------------------- photo
                  _Label(text: s('addCrop.photoLabel')),
                  if (_photoPath == null)
                    _PhotoDropZone(
                      takeLabel: s('addCrop.takePhoto'),
                      galleryLabel: s('addCrop.chooseGallery'),
                      orLabel: s('addCrop.or'),
                      hint: s('addCrop.photoHint'),
                      onTap: () => _pickPhoto(s),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CropPhoto(path: _photoPath, height: 190),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                s('addCrop.photoAdded'),
                                style: AppText.bodySmStrong
                                    .copyWith(color: AppColors.success),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _pickPhoto(s),
                              child: Text(s('addCrop.retake')),
                            ),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _photoPath = null),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                              ),
                              child: Text(s('addCrop.remove')),
                            ),
                          ],
                        ),
                      ],
                    ),

                  const SizedBox(height: AppSpacing.lg),

                  // ------------------------------------------ location
                  _Label(text: s('addCrop.locationLabel')),
                  LocationCard(
                    title: s('addCrop.currentLocation'),
                    address: _detectingLocation ? s('addCrop.detecting') : _location,
                    isDetecting: _detectingLocation,
                    changeLabel: s('common.change'),
                    onChange: _detectingLocation ? null : _detectLocation,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  PrimaryButton(
                    label: s('addCrop.cta'),
                    icon: Icons.auto_awesome_rounded,
                    onPressed: () => _submit(s),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    s('addCrop.photoOptional'),
                    style: AppText.caption,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- pieces

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, left: 2),
      child: Text(text, style: AppText.titleLg),
    );
  }
}

/// A tap-to-choose field that looks like an input but opens a sheet — no
/// dropdown menus, which are fiddly on a small screen with wet hands.
class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.hint,
    required this.value,
    required this.onTap,
    this.leading,
    this.error,
  });

  final String hint;
  final String? value;
  final VoidCallback onTap;
  final String? leading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Material(
          color: AppColors.surface,
          borderRadius: AppRadius.rMd,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.rMd,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: AppRadius.rMd,
                border: Border.all(
                  color: error != null ? AppColors.danger : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: <Widget>[
                  if (leading != null) ...<Widget>[
                    EmojiText(leading!, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      value ?? hint,
                      style: hasValue
                          ? AppText.bodyStrong
                          : AppText.body.copyWith(color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: AppSpacing.sm),
            child: Text(
              error!,
              style: AppText.bodySm.copyWith(color: AppColors.danger),
            ),
          ),
      ],
    );
  }
}

class _QuantityChip extends StatelessWidget {
  const _QuantityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
    );
  }
}

/// The big friendly "add a photo" target.
class _PhotoDropZone extends StatelessWidget {
  const _PhotoDropZone({
    required this.takeLabel,
    required this.galleryLabel,
    required this.orLabel,
    required this.hint,
    required this.onTap,
  });

  final String takeLabel;
  final String galleryLabel;
  final String orLabel;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: takeLabel,
      child: Material(
        color: AppColors.primarySofter,
        borderRadius: AppRadius.rLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.rLg,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.rLg,
              border: Border.all(
                color: AppColors.primaryLight,
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    size: 29,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  takeLabel,
                  style: AppText.titleLg.copyWith(color: AppColors.primaryDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(orLabel, style: AppText.caption),
                const SizedBox(height: 2),
                Text(
                  galleryLabel,
                  style: AppText.bodySmStrong.copyWith(color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  hint,
                  style: AppText.caption,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
