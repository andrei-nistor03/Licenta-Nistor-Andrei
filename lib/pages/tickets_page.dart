import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ticket.dart';
import 'card_payment_page.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({Key? key}) : super(key: key);

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  List<Ticket> tickets = [];
  late Timer _uiTimer;

  @override
  void initState() {
    super.initState();
    _loadTickets();

    _uiTimer = Timer.periodic(Duration(seconds: 1), (_) {
      bool updated = false;
      for (var ticket in tickets) {
        final wasExpired = ticket.isExpired;
        ticket.checkIfExpired();
        if (!wasExpired && ticket.isExpired) {
          updated = true;
        }
      }
      if (updated) {
        _saveTickets();
      }
      setState(() {}); // actualizează UI-ul la fiecare secundă
    });
  }

  @override
  void dispose() {
    _uiTimer.cancel();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTickets = prefs.getStringList('tickets') ?? [];

    List<Ticket> loadedTickets = [];

    for (var jsonStr in storedTickets) {
      final Map<String, dynamic> jsonData = json.decode(jsonStr);
      final ticket = Ticket.fromJson(jsonData);
      loadedTickets.add(ticket);
    }

    setState(() {
      tickets = loadedTickets;
    });
  }

  Future<void> _saveTickets() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList =
        tickets.map((t) => json.encode(t.toJson())).toList();
    await prefs.setStringList('tickets', jsonList);
  }

  void _addTicket(String type, String line) {
    final newTicket = Ticket(
      type: type,
      line: line,
      remainingSeconds: 7200, // sau 7200 pentru 2 ore
    );

    setState(() {
      tickets.add(newTicket);
    });

    _saveTickets();

    // Afișează notificarea SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bilet achiziționat!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showPurchaseDialog() {
    String? selectedType;
    String? selectedLine;

    Map<String, List<String>> linesByType = {
      'Tramvai': ['1', '2', '4', '5', '6a', '6b', '7', '8', '9'],
      'Autobuz': [
        '13',
        '21',
        '24',
        '28',
        '32',
        '33',
        '33B',
        '40',
        '46',
        'E1',
        'E2',
        'E3',
        'E4',
        'E4B',
        'E6',
        'E7',
        'E8',
        'M22',
        'M23',
        'M24',
        'M27',
        'M29',
        'M30',
        'M35',
        'M36',
        'M37',
        'M38',
        'M39',
        'M41',
        'M42',
        'M43',
        'M44',
        'M45',
        'M46',
        'M47',
        'M48',
        'M49',
        'M50',
        'M51',
      ],
      'Troleibuz': ['11', '14', '15', '16', '17', '18', 'M11', 'M14'],
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              contentPadding: const EdgeInsets.only(
                top: 16,
                left: 24,
                right: 24,
                bottom: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: null,
              content: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selectează Linie',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 28),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              selectedType = 'Tramvai';
                              selectedLine = null;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border:
                                  selectedType == 'Tramvai'
                                      ? Border.all(color: Colors.blue, width: 3)
                                      : null,
                            ),
                            child: Image.asset(
                              'assets/images/tramvai.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              selectedType = 'Autobuz';
                              selectedLine = null;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border:
                                  selectedType == 'Autobuz'
                                      ? Border.all(color: Colors.blue, width: 3)
                                      : null,
                            ),
                            child: Image.asset(
                              'assets/images/autobuz.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              selectedType = 'Troleibuz';
                              selectedLine = null;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border:
                                  selectedType == 'Troleibuz'
                                      ? Border.all(color: Colors.blue, width: 3)
                                      : null,
                            ),
                            child: Image.asset(
                              'assets/images/troleibuz.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (selectedType != null)
                      DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Selectează linia'),
                        value: selectedLine,
                        items:
                            linesByType[selectedType]!
                                .map(
                                  (line) => DropdownMenuItem(
                                    value: line,
                                    child: Text(line),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedLine = value;
                          });
                        },
                      ),

                    if (selectedLine != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Preț: 4 lei',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 12),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed:
                      (selectedType != null && selectedLine != null)
                          ? () async {
                            Navigator.of(context).pop();
                            final result = await Navigator.of(
                              context,
                            ).push<bool>(
                              MaterialPageRoute(
                                builder:
                                    (context) => CardPaymentPage(
                                      type: selectedType!,
                                      line: selectedLine!,
                                    ),
                              ),
                            );

                            if (result == true) {
                              _addTicket(selectedType!, selectedLine!);
                            }
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (selectedType != null && selectedLine != null)
                            ? Colors.green
                            : Colors.grey,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('Achiziționează'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    return '${duration.inHours.toString().padLeft(2, '0')}:'
        '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bilete"),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _showPurchaseDialog,
                child: const Text('Achiziționează bilet'),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                final expired = ticket.isExpired;

                return Card(
                  color:
                      expired
                          ? const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ).withOpacity(0.5)
                          : Colors.white,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  child: ListTile(
                    title: Text('Bilet ${ticket.type} - Linia ${ticket.line}'),
                    subtitle:
                        expired
                            ? const Text(
                              'Bilet expirat',
                              style: TextStyle(color: Colors.red),
                            )
                            : Text(
                              'Expiră în: ${_formatDuration(ticket.remainingSeconds)}',
                            ),
                    trailing:
                        expired
                            ? IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  tickets.removeAt(index);
                                });
                                _saveTickets();
                              },
                            )
                            : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
