import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/widgets/app_drawer.dart';
import '../../midibs/data/midib.dart';
import '../../midibs/data/midib_api.dart';
import '../data/member.dart';
import '../data/members_api.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});
  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  final membersApi = MembersApi();
  final midibApi = MidibApi();

  // search mode
  final _searchCtl = TextEditingController();
  final _searchFocus = FocusNode();
  List<Member>? _allMembers;
  bool _loadingAll = false;

  // list mode
  bool _listMode = false;
  List<Midib> _midibs = [];
  String? _selectedMidibId;
  Future<List<Member>>? _futureList;
  String _listFilter = '';

  @override
  void dispose() {
    _searchCtl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Midib? _findMidibById(String? id) {
    if (id == null) return null;
    for (final m in _midibs) {
      if (m.id == id) return m;
    }
    return null;
  }

  // ===== shared helpers =====
  Future<void> _createNew() async {
    final ok = await context.push('/members/new');
    if (ok == true && mounted) {
      if (_listMode && _selectedMidibId != null) {
        final midib = _findMidibById(_selectedMidibId);
        setState(() {
          _futureList = (midib == null) ? null : membersApi.listMembersByMidib(midib);
        });
      }
    }
  }

  Future<void> _ensureAllMembers() async {
    if (_allMembers != null || _loadingAll) return;
    setState(() => _loadingAll = true);
    try {
      _allMembers = await membersApi.listAll();
    } finally {
      if (mounted) setState(() => _loadingAll = false);
    }
  }

  Future<void> _enterListMode() async {
    if (_midibs.isEmpty) {
      final mids = await midibApi.listMidibs();
      _midibs = mids..sort((a, b) => a.name.compareTo(b.name));
      _selectedMidibId = null; // do NOT auto-select
      _futureList = null;      // nothing shown until user picks one
    }
    setState(() {
      _listMode = true;
      _listFilter = '';
    });
  }

  void _onMidibChanged(String? id) {
    final midib = _findMidibById(id);
    setState(() {
      _selectedMidibId = id;
      _listFilter = '';
      _futureList = (midib == null) ? null : membersApi.listMembersByMidib(midib);
    });
  }

  Future<void> _refreshCurrentList() async {
    if (_listMode && _selectedMidibId != null) {
      final midib = _findMidibById(_selectedMidibId);
      if (midib != null) {
        setState(() {
          _futureList = membersApi.listMembersByMidib(midib);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('አባላት'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'list') await _enterListMode();
            },
            itemBuilder: (c) => const [
              PopupMenuItem(value: 'list', child: Text('የአባላት ዝርዝር')),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNew,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('አዲስ አባል'),
      ),

      body: _listMode ? _buildListMode(context) : _buildSearchMode(context),
    );
  }

  // ===== SEARCH MODE (global) =====
  Widget _buildSearchMode(BuildContext context) {
    final q = _searchCtl.text.trim().toLowerCase();
    final showResults = q.length >= 2;
    final results = (_allMembers ?? [])
        .where((m) => m.name.toLowerCase().contains(q))
        .toList();

    return GestureDetector(
      onTap: () => _searchFocus.unfocus(),
      
child: Column(
  children: [
    Padding(
	  padding: const EdgeInsets.all(16),
	  child: Column(
		crossAxisAlignment: CrossAxisAlignment.stretch,
		children: [
		  // 🔍 Simple, flat search field (no heavy container)
		  TextField(
			controller: _searchCtl,
			focusNode: _searchFocus,
			decoration: InputDecoration(
			  labelText: 'አባል ፈልግ…',
			  prefixIcon: const Icon(Icons.search, color: Colors.indigo),
			  border: OutlineInputBorder(
				borderRadius: BorderRadius.circular(12),
			  ),
			  contentPadding:
				  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
			),
			onChanged: (v) async {
			  if (v.trim().length >= 2) {
				await _ensureAllMembers();
				setState(() {});
			  } else {
				setState(() {});
			  }
			},
		  ),

		  const SizedBox(height: 16),

		  // 🟦 Keep the modern quick card style (matches data-entry pages)
		  _quickCard(
			context,
			'የአባላት ዝርዝር በምድብ',
			Icons.view_list_rounded,
			null,
			onTap: _enterListMode,
		  ),
		],
	  ),
	),
          if (!showResults)
            const Expanded(
              child: Center(child: Text('ምንም መረጃ የለም')),
            )
          else if (_loadingAll && _allMembers == null)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: Material(
                elevation: 2,
                child: ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final m = results[i];
                    final code = m.memberCode;
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(m.name),
                      subtitle: Text(code, overflow: TextOverflow.ellipsis),
                      onTap: () async {
                        final changed =
                            await context.push('/members/${Uri.encodeComponent(m.id)}');
                        if (changed == true && mounted) {
                          await _refreshCurrentList();
                        }
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===== LIST MODE (by midib) =====
  Widget _buildListMode(BuildContext context) {
    return Column(
      children: [
        Container(
		  margin: const EdgeInsets.all(16),
		  padding: const EdgeInsets.all(20),
		  decoration: BoxDecoration(
			color: Theme.of(context).colorScheme.surface,
			borderRadius: BorderRadius.circular(16),
			boxShadow: [
			  BoxShadow(
				color: Colors.black.withOpacity(0.1),
				blurRadius: 8,
				offset: const Offset(0, 2),
			  ),
			],
		  ),
		  child: Column(
			children: [
			  // Dropdown
			  InputDecorator(
				decoration: InputDecoration(
				  border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(16),
					borderSide: BorderSide.none,
				  ),
				  focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(16),
					borderSide: BorderSide(
					  color: Theme.of(context).colorScheme.primary,
					  width: 2,
					),
				  ),
				  filled: true,
				  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
				  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
				),
				child: DropdownButtonHideUnderline(
				  child: DropdownButton<String>(
					isExpanded: true,
					value: _selectedMidibId,
					hint: const Text('ምድብ ይምረጡ'),
					icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
					style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
					items: _midibs
						.map((m) => DropdownMenuItem(
							  value: m.id,
							  child: Text(
								m.name,
								style: const TextStyle(fontSize: 16),
							  ),
							))
						.toList(),
					onChanged: _onMidibChanged,
				  ),
				),
			  ),
			  
			  // Animated search field
			  AnimatedSwitcher(
				duration: const Duration(milliseconds: 300),
				child: _selectedMidibId != null
					? Column(
						children: [
						  const SizedBox(height: 16),
						  TextField(
							key: ValueKey(_selectedMidibId), // Important for animation
							decoration: InputDecoration(
							  hintText: 'ፈልግ…',
							  prefixIcon: Container(
								margin: const EdgeInsets.all(12),
								child: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.primary),
							  ),
							  border: OutlineInputBorder(
								borderRadius: BorderRadius.circular(16),
								borderSide: BorderSide.none,
							  ),
							  focusedBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(16),
								borderSide: BorderSide(
								  color: Theme.of(context).colorScheme.primary,
								  width: 2,
								),
							  ),
							  filled: true,
							  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
							  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
							),
							onChanged: (v) => setState(() => _listFilter = v.trim().toLowerCase()),
						  ),
						],
					  )
					: const SizedBox.shrink(),
			  ),
			],
		  ),
		),

        Expanded(
          child: _selectedMidibId == null
              ? const Center(child: Text('ምድብ አልተመረጠም'))
              : (_futureList == null
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<Member>>(
                      future: _futureList,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snap.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Error: ${snap.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        }
                        final items = (snap.data ?? [])
                            .where((m) =>
                                _listFilter.isEmpty ||
                                m.name.toLowerCase().contains(_listFilter))
                            .toList();
                        if (items.isEmpty) {
                          return const Center(child: Text('ምንም አባል አልተገኘም'));
                        }
                        return RefreshIndicator(
                          onRefresh: _refreshCurrentList,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final m = items[i];
                              final code = m.memberCode;
                              return ListTile(
                                title: Text(m.name, style: const TextStyle(fontSize: 18)),
                                subtitle: Text(code, overflow: TextOverflow.ellipsis),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  final changed = await context
                                      .push('/members/${Uri.encodeComponent(m.id)}');
                                  if (changed == true && mounted) {
                                    await _refreshCurrentList();
                                  }
                                },
                              );
                            },
                          ),
                        );
                      },
                    )),
        ),
      ],
    );
  }
  
  Widget _quickCard(
	  BuildContext context, String title, IconData icon, String? route, 
	  { VoidCallback? onTap,}) {
	  return Card(
		elevation: 3,
		margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
		child: InkWell(
		  borderRadius: BorderRadius.circular(12),
		  onTap: onTap ??
			  () {
				if (route != null) Navigator.pushNamed(context, route);
			  },
		  child: Padding(
			padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
			child: Row(
			  children: [
				Icon(icon, color: Theme.of(context).primaryColor, size: 28),
				const SizedBox(width: 14),
				Expanded(
				  child: Text(
					title,
					style: const TextStyle(
					  fontSize: 18,
					  fontWeight: FontWeight.bold,
					),
				  ),
				),
				const Icon(Icons.arrow_forward_ios_rounded,
					size: 18, color: Colors.indigo),
			  ],
			),
		  ),
		),
	  );
	}
}
