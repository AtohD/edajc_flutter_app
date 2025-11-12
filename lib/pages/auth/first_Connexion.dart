import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class FirstConnexion extends StatefulWidget {
  const FirstConnexion({super.key});

  @override
  State<FirstConnexion> createState() => _FirstConnexionState();
}

class _FirstConnexionState extends State<FirstConnexion>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late AnimationController _buttonsController;
  late AnimationController _imageController;

  final List<Map<String, dynamic>> regions = [
    {'name': 'ABIDJAN', 'color': const Color(0xFFE43C0B)}, // Orange rouge
    {'name': 'ABENGOUROU', 'color': const Color(0xFFF9B233)}, // Jaune
    {'name': 'DAOUKRO', 'color': const Color(0xFF002B7F)}, // Bleu foncé
    {'name': 'YAMOUSSOUKRO', 'color': const Color(0xFFE43C0B)}, // Orange rouge
    {'name': 'DALOA', 'color': const Color(0xFFF9B233)}, // Jaune clair
  ];

  @override
  void initState() {
    super.initState();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addListener(() => setState(() {}));

    _buttonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(() => setState(() {}));

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() => setState(() {}));

    Future.delayed(const Duration(milliseconds: 200), () {
      _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _buttonsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _imageController.forward();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _buttonsController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBuilder(
        builder: (context, sizingInfo) {
          final bool isMobile =
              sizingInfo.deviceScreenType == DeviceScreenType.mobile;

          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE6F0FB), Color(0xFFFFFFFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // HEADER -----------------------------------------------------
                    if (!isMobile)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "images/EDLog.png",
                            height: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "MINISTÈRE DE L’ÉTERNEL DIEU DES ARMÉES ET DE JÉSUS-CHRIST",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF004AAD),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 40),

                    // BODY ---------------------------------------------------------
                    Expanded(
                      child: SingleChildScrollView(
                        child: Flex(
                          direction: isMobile ? Axis.vertical : Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Texte + Boutons
                            Expanded(
                              flex: isMobile ? 0 : 1,
                              child: AnimatedSlide(
                                offset: _textController.isCompleted
                                    ? Offset.zero
                                    : const Offset(0, 0.2),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOut,
                                child: AnimatedOpacity(
                                  opacity: _textController.isCompleted ? 1 : 0,
                                  duration: const Duration(milliseconds: 700),
                                  child: Column(
                                    crossAxisAlignment: isMobile
                                        ? CrossAxisAlignment.center
                                        : CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Sélectionnez votre région",
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Choisissez votre région pour continuer.\n"
                                        "Créez ou explorez selon votre zone d’activité.",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 0),

                                      // Boutons région
                                      AnimatedOpacity(
                                        opacity: _buttonsController.isCompleted ? 1 : 0,
                                        duration: const Duration(milliseconds: 900),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Image de fond semi-transparente
                                            Opacity(
                                              opacity: 0.12, // transparence (ajuste entre 0.05 et 0.2)
                                              child: Image.asset(
                                                "images/cotinent.png",
                                                fit: BoxFit.contain,
                                                width: isMobile
                                                    ? MediaQuery.of(context).size.width * 0.9
                                                    : MediaQuery.of(context).size.width * 0.5,
                                              ),
                                            ),

                                            // Boutons régions par-dessus
                                            Column(
                                              children: regions.map((region) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.pushNamed(context, '/signIn');
                                                    },
                                                    child: Container(
                                                      width: isMobile
                                                          ? MediaQuery.of(context).size.width * 0.85
                                                          : MediaQuery.of(context).size.width * 0.35, // ← largeur réduite
                                                      height: 60,
                                                      decoration: BoxDecoration(
                                                        color: region['color'],
                                                        borderRadius: const BorderRadius.horizontal(
                                                          right: Radius.circular(30),
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.1),
                                                            offset: const Offset(0, 3),
                                                            blurRadius: 6,
                                                          ),
                                                        ],
                                                      ),
                                                      alignment: Alignment.centerLeft,
                                                      padding: const EdgeInsets.symmetric(horizontal: 30),
                                                      child: Text(
                                                        region['name'],
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40, width: 60),

                            // Image droite (fade in)
                            if (!isMobile)
                              Expanded(
                                flex: 1,
                                child: AnimatedSlide(
                                  offset: _imageController.isCompleted
                                      ? Offset.zero
                                      : const Offset(0.3, 0),
                                  duration:
                                      const Duration(milliseconds: 900),
                                  curve: Curves.easeOut,
                                  child: AnimatedOpacity(
                                    opacity:
                                        _imageController.isCompleted ? 1 : 0,
                                    duration:
                                        const Duration(milliseconds: 900),
                                    child: Image.asset(
                                      "images/edt.jpg",
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          height: 200,
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // FOOTER -------------------------------------------------------
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF002B7F),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "SCANNER LE CODE QR & REJOINS-NOUS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "@EDAJC.TV",
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "INFOLINE",
                                  style: TextStyle(
                                    color: Color(0xFF00FFD4),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "01 01 38 98 72\n01 72 33 25 25\n07 09 64 25 24",
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "SCANNER LE CODE QR & REJOINS-NOUS",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "@EDAJC.TV",
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: const [
                                    Text(
                                      "INFOLINE",
                                      style: TextStyle(
                                        color: Color(0xFF00FFD4),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "01 01 38 98 72\n01 72 33 25 25\n07 09 64 25 24",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
