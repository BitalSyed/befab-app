import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaticBarcodeScannerWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? barcodeColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  const StaticBarcodeScannerWidget({
    Key? key,
    this.text = 'Scan the barcode to your food item',
    this.textStyle,
    this.borderColor,
    this.backgroundColor,
    this.barcodeColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: height ?? 120,
              width: width ?? double.infinity,
              padding: padding ?? EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: backgroundColor ?? Color(0xFFFFFFFF),
                border: Border.all(
                  color: borderColor ?? Color((0xFF862633)),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
              ),
              child: Center(
                child: _buildBarcode(),
              ),
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                text,
                style: textStyle ?? GoogleFonts.inter(
                  fontSize: 16,
                  color: Color(0xFF862633),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcode() {
    return Container(
      height: 50,
      width: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBarcodeBar(width: 4, height: 45),
          SizedBox(width: 2),
          _buildBarcodeBar(width: 2, height: 50),
          SizedBox(width: 3),
          _buildBarcodeBar(width: 6, height: 40),
          SizedBox(width: 2),
          _buildBarcodeBar(width: 3, height: 50),
          SizedBox(width: 1),
          _buildBarcodeBar(width: 2, height: 45),
          SizedBox(width: 4),
          _buildBarcodeBar(width: 5, height: 50),
          SizedBox(width: 2),
          _buildBarcodeBar(width: 3, height: 40),
          SizedBox(width: 1),
          _buildBarcodeBar(width: 2, height: 50),
          SizedBox(width: 3),
          _buildBarcodeBar(width: 4, height: 45),
        ],
      ),
    );
  }

  Widget _buildBarcodeBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: barcodeColor ?? Color(0xFF862633),
        borderRadius: BorderRadius.circular(0.5),
      ),
    );
  }
}