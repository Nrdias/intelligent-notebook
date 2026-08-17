import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/design_system/widgets/app_svg_icon.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/calendar_event.dart';
import '../providers/calendar_provider.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.calendar),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              ref
                  .read(calendarProvider.notifier)
                  .setSelectedDate(DateTime.now());
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Month/Week header
            _CalendarHeader(),
            // Events list
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(child: Text('Error: ${state.error}'))
                      : state.events.isEmpty
                          ? Center(child: Text(l10n.noEventsForDay))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.events.length,
                              itemBuilder: (context, index) {
                                final event = state.events[index];
                                return _EventCard(event: event);
                              },
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Create new event
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newEvent),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: AppSvgIcon.chevron(size: 20),
            onPressed: () {},
          ),
          const Text(
            '2026',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: RotatedBox(
              quarterTurns: 2,
              child: AppSvgIcon.chevron(size: 20),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatTime(event.startTime),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.month}/${date.day}, ${_formatHour(date)}';
  }

  String _formatHour(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $amPm';
  }
}
