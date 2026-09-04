import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:farm_buddy/core/theme/app_colors.dart';
import 'package:farm_buddy/core/theme/app_spacing.dart';
import 'package:farm_buddy/core/theme/app_typography.dart';
import 'package:farm_buddy/models/farm_location.dart';
import 'package:farm_buddy/providers/location_providers.dart';
import 'package:farm_buddy/widgets/common/map_preview.dart';

/// A place on the map, described both ways.
///
/// [latitude]/[longitude] drive the real Google map; [x]/[y] drive the drawn
/// one, which knows nothing about geography. Carrying both is what lets the
/// app switch between them without any caller caring which is on screen.
class FbMapMarker {
  const FbMapMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.x,
    required this.y,
    required this.label,
    this.isPrimary = false,
    this.rank,
    this.emoji,
  });

  final String id;
  final double latitude;
  final double longitude;
  final double x;
  final double y;
  final String label;
  final bool isPrimary;
  final int? rank;
  final String? emoji;
}

/// The map, whichever kind is switched on.
///
/// Defaults to the drawn map. The live Google map is opt-in via
/// [liveMapProvider] because it needs an API key, a billing account and a
/// signal — and a demo should never be one expired key away from a blank
/// rectangle. Both render the same markers.
class FbMap extends ConsumerWidget {
  const FbMap({
    super.key,
    this.height = 190,
    this.markers = const <FbMapMarker>[],
    this.showRoute = false,
    this.centerLabel,
    this.onMarkerTap,
  });

  final double height;
  final List<FbMapMarker> markers;
  final bool showRoute;
  final String? centerLabel;
  final void Function(int index)? onMarkerTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool live = ref.watch(liveMapProvider);

    if (!live) {
      return MapPreview(
        height: height,
        showRoute: showRoute,
        centerLabel: centerLabel,
        onMarkerTap: onMarkerTap,
        markers: <MapMarker>[
          for (final FbMapMarker m in markers)
            MapMarker(
              x: m.x,
              y: m.y,
              label: m.label,
              isPrimary: m.isPrimary,
              rank: m.rank,
              emoji: m.emoji,
            ),
        ],
      );
    }

    return _LiveMap(
      height: height,
      markers: markers,
      onMarkerTap: onMarkerTap,
    );
  }
}

class _LiveMap extends ConsumerStatefulWidget {
  const _LiveMap({
    required this.height,
    required this.markers,
    this.onMarkerTap,
  });

  final double height;
  final List<FbMapMarker> markers;
  final void Function(int index)? onMarkerTap;

  @override
  ConsumerState<_LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends ConsumerState<_LiveMap> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FarmLocation here = ref.watch(farmLocationProvider);

    final Set<Marker> pins = <Marker>{
      for (int i = 0; i < widget.markers.length; i++)
        Marker(
          markerId: MarkerId(widget.markers[i].id),
          position: LatLng(
            widget.markers[i].latitude,
            widget.markers[i].longitude,
          ),
          infoWindow: InfoWindow(title: widget.markers[i].label),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            widget.markers[i].isPrimary
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueOrange,
          ),
          onTap: widget.onMarkerTap == null
              ? null
              : () => widget.onMarkerTap!(i),
        ),
    };

    return ClipRRect(
      borderRadius: AppRadius.rLg,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(here.latitude, here.longitude),
                zoom: 10.5,
              ),
              markers: pins,
              myLocationEnabled: here.isFromDevice,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              onMapCreated: (GoogleMapController c) => _controller = c,
            ),
            Positioned(
              left: AppSpacing.xs,
              bottom: AppSpacing.xs,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.88),
                  borderRadius: AppRadius.rPill,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Live map',
                  style: AppText.caption.copyWith(fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
