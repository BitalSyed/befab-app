import 'package:befab/components/DeepDiveCard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DeepDiveScreen extends StatelessWidget {
  final List<dynamic> deepDives;

  const DeepDiveScreen({super.key, required this.deepDives});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deep Dives"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child:
            deepDives.isEmpty
                ? Center(
                  child: Text(
                    "No deep dive docs available",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Let's Deep Dive?",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Choose one of the deep dive topics\nrelated to this newsletter.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: deepDives.length,
                        itemBuilder: (context, index) {
                          final dd = deepDives[index];

                          return DeepDiveCard(
                            title: dd["title"] ?? "Untitled",
                            subtitle: dd["description"] ?? "",
                            leading: _ThumbIcon(
                              color: primary.withOpacity(0.12),
                              icon: Icons.picture_as_pdf,
                              iconColor: primary,
                            ),
                            onTap: () {
                              final fetchedPdf = dd["pdf"];
                              final pdfUrl = dd["pdf"];
                              if (fetchedPdf != null && fetchedPdf.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => Scaffold(
                                          appBar: AppBar(
                                            title: Text(
                                              dd["title"] ?? "Deep Dive",
                                            ),
                                          ),
                                          body: SfPdfViewer.network(pdfUrl),
                                        ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class _ThumbIcon extends StatelessWidget {
  final Color color;
  final Color iconColor;
  final IconData icon;
  const _ThumbIcon({
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 28),
    );
  }
}
