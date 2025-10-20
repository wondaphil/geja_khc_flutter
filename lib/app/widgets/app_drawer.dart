import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  static const brandCyan = Color(0xFF00ADEF);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            //const DrawerHeader(child: Center(child: Text('ጌጃ ቃ/ሕ ቤ/ክ', style: TextStyle(fontSize: 20)))),
            const DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white),
              child: Center(
				  child: Column(
					mainAxisSize: MainAxisSize.min,
					children: const [
					  Image(
						image: AssetImage('assets/images/logo.png'),
						height: 80,
						fit: BoxFit.contain,
					  ),
					  SizedBox(height: 8),
					  Text(
						'የአባላት መረጃ አስተዳደር',
						style: TextStyle(
						  fontSize: 16,
						  fontWeight: FontWeight.w600,
						),
						textAlign: TextAlign.center,
					  ),
					],
				  ),
				),
            ),
			ListTile(
			  leading: const Icon(Icons.home, color: brandCyan),
			  title: const Text('መነሻ ገጽ'),
			  onTap: () {
				  Navigator.of(context).pop();
				  context.pushReplacement('/');
				},
			),
			const Divider(),
		    ListTile(
				leading: const Icon(Icons.groups, color: brandCyan), 
				title: const Text('ምድብ'), 
				onTap: () => context.push('/midibs')
			),
            ListTile(
				leading: const Icon(Icons.people, color: brandCyan), 
				title: const Text('አባላት'), 
				onTap: () => context.push('/members')
			),
            ListTile(
				leading: const Icon(Icons.edit_note, color: brandCyan), 
				title: const Text('ዝርዝር መረጃ ማስገቢያ'), 
				onTap: () => context.push('/member_data_entry')
			),
            const Divider(),
		    ListTile(
				leading: const Icon(Icons.assignment, color: brandCyan), 
				title: const Text('ሪፖርት'), 
				onTap: () => context.push('/reports/by-midib')
			),
            ListTile(
				leading: const Icon(Icons.show_chart, color: brandCyan), 
				title: const Text('ቻርት'), 
				onTap: () => context.push('/charts')
			),
            const Divider(),
		    ListTile(
				leading: const Icon(Icons.settings, color: brandCyan), 
				title: const Text('መቼቶች'), 
				onTap: () => context.push('/settings')
			),
          ],
        ),
      ),
    );
  }
}
