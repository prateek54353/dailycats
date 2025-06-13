import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/image_service.dart';
import '../widgets/cat_image_viewer.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catUrl = useState<String?>(null);
    final caption = useState<String?>(null);

    useEffect(() {
      () async {
        final cat = await ImageService.getTodayCat();
        catUrl.value = cat.url;
        // caption
        try {
          final res = await http.get(Uri.parse('https://catfact.ninja/fact'));
          caption.value = jsonDecode(res.body)['fact'];
        } catch (_) {}
      }();
      return null;
    }, []);

    if (catUrl.value == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: PageView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          // First page today, others history
          if (index == 0) {
            return CatImageViewer(imageUrl: catUrl.value!, caption: caption.value);
          }
          return FutureBuilder(
            future: ImageService.getLast7Cats(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = snapshot.data!;
              if (index >= list.length) {
                return const Center(child: Text('No cat'));
              }
              return CatImageViewer(imageUrl: list[index].url);
            },
          );
        },
      ),
    );
  }
}
