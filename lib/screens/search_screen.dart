import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/poppins.dart';
import '../services/plan_service.dart';
import '../widgets/plan_card.dart';
import '../l10n/tr.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PlanService>();
    final results = service.search(_query);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: tr(context, 'Plan, dərs və ya məkan axtar...', 'Search a plan, lesson or place...'),
            border: InputBorder.none,
            hintStyle: poppins(color: Colors.grey),
          ),
          style: poppins(),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    tr(context, 'Axtarış etmək üçün yazın', 'Type to search'),
                    style: poppins(color: Colors.grey),
                  ),
                ],
              ),
            )
          : results.isEmpty
              ? Center(
                  child: Text(
                    tr(context, 'Nəticə tapılmadı', 'No results'),
                    style: poppins(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PlanCard(plan: results[index], showDate: true),
                    );
                  },
                ),
    );
  }
}
