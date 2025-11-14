// lib/core/widgets/insect_image.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/image_service.dart';

class InsectImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const InsectImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final imageService = ImageService.instance;
    // Try cache-busted URL first
    String? fullUrl = imageService.getImageUrlWithCache(imageUrl) ??
        imageService.getImageUrl(imageUrl);

    if (fullUrl == null || fullUrl.isEmpty) {
      return _buildErrorWidget(context);
    }

    final isSupabase =
        fullUrl.contains('supabase') || fullUrl.contains('/storage/v1/');
    final isPinterest = fullUrl.contains('pinterest') || fullUrl.contains('pinimg');

    Widget imageWidget;

    if (isSupabase) {
      imageWidget = Image.network(
        fullUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(context, loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Erreur chargement image: $error');
          return _buildErrorWidget(context);
        },
      );
    } else {
      // Pour Pinterest et autres URLs externes, utiliser CachedNetworkImage avec headers
      imageWidget = CachedNetworkImage(
        imageUrl: fullUrl,
        width: width,
        height: height,
        fit: fit,
        httpHeaders: isPinterest ? {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Referer': 'https://www.pinterest.com/',
          'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
        } : null,
        placeholder: (context, url) => _buildPlaceholder(context, null),
        errorWidget: (context, url, error) {
          debugPrint('❌ Erreur chargement image cached: $error');
          debugPrint('❌ URL: $url');
          return _buildErrorWidget(context);
        },
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
        // Timeout pour éviter les loaders infinis
        // ✅ Vérifier que width/height ne sont pas infinity
        memCacheWidth: (width != null && width!.isFinite) ? width!.toInt() : null,
        memCacheHeight: (height != null && height!.isFinite) ? height!.toInt() : null,
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildPlaceholder(
      BuildContext context, ImageChunkEvent? loadingProgress) {
    if (placeholder != null) return placeholder!;

    final color = Theme.of(context).colorScheme.primary;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bug_report_outlined,
              size: 48,
              color: color.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidget != null) return errorWidget!;

    final color = Theme.of(context).colorScheme.primary;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bug_report,
              size: 56,
              color: color.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Icon(
              Icons.image_not_supported_outlined,
              size: 24,
              color: color.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
