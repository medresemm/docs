import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import '../theme/poppins.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/plan_item.dart';
import '../widgets/timetable_image.dart';

class TimetableExport {
  static Future<Uint8List> _capture(
    BuildContext context, {
    required List<PlanItem> plans,
    required DateTime weekStart,
    required String userName,
  }) async {
    final key = GlobalKey();
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black.withOpacity(0.55),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Şəkil hazırlanır…',
                  style: poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: FittedBox(
                    child: RepaintBoundary(
                      key: key,
                      child: TimetableImage(
                        plans: plans,
                        weekStart: weekStart,
                        userName: userName,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    overlay.insert(entry);
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null || !boundary.hasSize) {
        throw Exception('Cədvəl şəkli hazırlanmadı');
      }
      if (boundary.debugNeedsPaint) {
        await WidgetsBinding.instance.endOfFrame;
      }
      final image = await boundary.toImage(pixelRatio: 2.2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) throw Exception('Şəkil yazılmadı');
      return bytes.buffer.asUint8List();
    } finally {
      entry.remove();
    }
  }

  static Future<void> showSheet(
    BuildContext context, {
    required List<PlanItem> plans,
    required DateTime weekStart,
    required String userName,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              'Cədvəli şəkil kimi',
              style: poppins(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            ListTile(
              leading: const Icon(Icons.save_alt, color: Color(0xFF6C5CE7)),
              title: Text('Qalereyaya yüklə', style: poppins()),
              subtitle: Text(
                'Telefonun şəkillər qovluğuna saxla',
                style: poppins(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(ctx);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  saveToGallery(
                    context,
                    plans: plans,
                    weekStart: weekStart,
                    userName: userName,
                  );
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: Color(0xFF6C5CE7)),
              title: Text('Paylaş', style: poppins()),
              onTap: () {
                Navigator.pop(ctx);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  share(
                    context,
                    plans: plans,
                    weekStart: weekStart,
                    userName: userName,
                  );
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text('Ləğv', style: poppins()),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> saveToGallery(
    BuildContext context, {
    required List<PlanItem> plans,
    required DateTime weekStart,
    required String userName,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final granted = await Gal.requestAccess(toAlbum: true);
      if (!context.mounted) return;
      if (!granted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Qalereya icazəsi lazımdır')),
        );
        return;
      }
      final bytes = await _capture(
        context,
        plans: plans,
        weekStart: weekStart,
        userName: userName,
      );
      if (!context.mounted) return;
      final name = 'Cedvel_${DateFormat('yyyyMMdd').format(weekStart)}';
      await Gal.putImageBytes(bytes, name: name, album: 'Cedvel');
      messenger.showSnackBar(
        const SnackBar(content: Text('Cədvəl qalereyaya yükləndi')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Saxlanılmadı: $e')),
      );
    }
  }

  static Future<void> share(
    BuildContext context, {
    required List<PlanItem> plans,
    required DateTime weekStart,
    required String userName,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await _capture(
        context,
        plans: plans,
        weekStart: weekStart,
        userName: userName,
      );
      if (!context.mounted) return;
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/cedvel_${DateFormat('yyyyMMdd').format(weekStart)}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Cədvəl · ${DateFormat('d MMM', 'az').format(weekStart)}',
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Paylaşıla bilmədi: $e')),
      );
    }
  }
}
