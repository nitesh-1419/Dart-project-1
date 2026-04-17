import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:latlong2/latlong.dart' as latlong2;

import '../services/web_map_tile_config.dart';
import '../viewmodels/map_viewmodel.dart';

class AdaptiveRideMap extends StatefulWidget {
  const AdaptiveRideMap({
    super.key,
    required this.model,
    this.padding = EdgeInsets.zero,
  });

  final MapViewModel model;
  final EdgeInsets padding;

  @override
  State<AdaptiveRideMap> createState() => _AdaptiveRideMapState();
}

class _AdaptiveRideMapState extends State<AdaptiveRideMap> {
  final osm.MapController _webMapController = osm.MapController();
  bool _ownsMapCallbacks = false;

  @override
  void initState() {
    super.initState();
    _scheduleWebCallbacks();
  }

  @override
  void didUpdateWidget(covariant AdaptiveRideMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      _scheduleWebCallbacks();
    }
  }

  void _scheduleWebCallbacks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      widget.model.attachMapCallbacks(
        moveCameraTo: (target, zoom) {
          _webMapController.move(target, zoom);
        },
        fitBounds: (bounds, padding) {
          // Prevent fitting bounds if the bounds are degenerate (point-like)
          if (bounds.south == bounds.north && bounds.west == bounds.east) {
            return;
          }
          _webMapController.fitCamera(
            osm.CameraFit.bounds(
              bounds: bounds,
              padding: EdgeInsets.all(padding),
            ),
          );
        },
      );
      _ownsMapCallbacks = true;
    });
  }

  @override
  void dispose() {
    if (_ownsMapCallbacks) {
      widget.model.detachMapCallbacks();
    }
    _webMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.model.initialMapTarget;
    return _buildMap(center);
  }

  Widget _buildMap(latlong2.LatLng center) {
    return Stack(
      children: <Widget>[
        osm.FlutterMap(
          mapController: _webMapController,
          options: osm.MapOptions(
            initialCenter: center,
            initialZoom: widget.model.currentLocation == null ? 11 : 15,
            onMapReady: () {
              widget.model.onMapCreated();
            },
          ),
          children: <Widget>[
            osm.TileLayer(
              urlTemplate: WebMapTileConfig.urlTemplate,
              fallbackUrl: WebMapTileConfig.hasFallbackUrl
                  ? WebMapTileConfig.fallbackUrl
                  : null,
              additionalOptions: WebMapTileConfig.additionalOptions,
              subdomains: WebMapTileConfig.subdomains,
              maxNativeZoom: WebMapTileConfig.maxNativeZoom,
              userAgentPackageName: WebMapTileConfig.userAgentPackageName,
            ),
            if (widget.model.polylines.isNotEmpty)
              osm.PolylineLayer(polylines: widget.model.polylines),
            if (widget.model.circles.isNotEmpty)
              osm.CircleLayer(circles: widget.model.circles),
            if (widget.model.markers.isNotEmpty)
              osm.MarkerLayer(markers: widget.model.markers),
          ],
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              WebMapTileConfig.attributionLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF32403C),
              ),
            ),
          ),
        ),
        if (WebMapTileConfig.isUsingDevelopmentFallback)
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF101514).withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                WebMapTileConfig.statusMessage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ),
      ],
    );
  }

}
