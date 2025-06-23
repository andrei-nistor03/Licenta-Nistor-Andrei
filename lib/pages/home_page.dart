import 'package:flutter/material.dart';
import 'map_page.dart';
import 'tickets_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundal gradient pe tot ecranul
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.blueAccent, // poți ajusta nuanța albastră aici
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // centru orizontal
              children: [
                // Logo sus, centrat
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),

                // Spațiu între logo și butoane
                const SizedBox(height: 40),

                // Butonul către harta
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 8,
                  ),
                  child: SizedBox(
                    width: double.infinity, // ocupă tot spațiul disponibil
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapPage(),
                          ),
                        );
                      },
                      child: const Text('Vezi Harta Stații'),
                    ),
                  ),
                ),

                // Butonul către pagina de bilete
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TicketsPage(),
                          ),
                        );
                      },
                      child: const Text('Achiziționează Bilet'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
