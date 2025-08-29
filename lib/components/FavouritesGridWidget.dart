import 'package:flutter/material.dart';

class FavouritesGridWidget extends StatelessWidget {
  final String title;
  final String? viewAllText;
  final List<FavouriteCategory> categories;
  final VoidCallback? onViewAllTap;
  final Function(FavouriteCategory)? onCategoryTap;
  final TextStyle? titleStyle;
  final TextStyle? viewAllStyle;
  final TextStyle? categoryTextStyle;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? spacing;
  final Color? categoryBackgroundColor;
  final Color? categoryBorderColor;
  final double? categoryBorderRadius;
  final int crossAxisCount;

  const FavouritesGridWidget({
    Key? key,
    this.title = 'My Favourites',
    this.viewAllText = 'view all',
    required this.categories,
    this.onViewAllTap,
    this.onCategoryTap,
    this.titleStyle,
    this.viewAllStyle,
    this.categoryTextStyle,
    this.padding,
    this.margin,
    this.spacing,
    this.categoryBackgroundColor,
    this.categoryBorderColor,
    this.categoryBorderRadius,
    this.crossAxisCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.all(16.0),
      padding: padding ?? EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryItem(category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(FavouriteCategory category) {
    return GestureDetector(
      onTap: () {
        if (onCategoryTap != null) {
          onCategoryTap!(category);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: category.backgroundColor ?? 
                 categoryBackgroundColor ?? 
                 Color(0xFFFAFBFB),
          border: Border.all(
            color: category.borderColor ?? 
                   categoryBorderColor ?? 
                   Color(0xFFFAFBFB),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(
            category.borderRadius ?? 
            categoryBorderRadius ?? 
            12.0
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.name,
              style: category.textStyle ?? 
                     categoryTextStyle ?? 
                     TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.w600,
                       color: Color(0xFF862633),
                     ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class FavouriteCategory {
  final String name;
  final IconData? icon;
  final String? imagePath;
  final Widget? imageWidget;
  final Color? iconColor;
  final double? iconSize;
  final double? imageSize;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final TextStyle? textStyle;

  FavouriteCategory({
    required this.name,
    this.icon,
    this.imagePath,
    this.imageWidget,
    this.iconColor,
    this.iconSize,
    this.imageSize,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.textStyle,
  });

  // Factory constructor for icon-based categories
  factory FavouriteCategory.withIcon({
    required String name,
    required IconData icon,
    Color? iconColor,
    double? iconSize,
    Color? backgroundColor,
    Color? borderColor,
    TextStyle? textStyle,
  }) {
    return FavouriteCategory(
      name: name,
      icon: icon,
      iconColor: iconColor,
      iconSize: iconSize,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      textStyle: textStyle,
    );
  }

  // Factory constructor for image-based categories
  factory FavouriteCategory.withImage({
    required String name,
    required String imagePath,
    double? imageSize,
    Color? backgroundColor,
    Color? borderColor,
    TextStyle? textStyle,
  }) {
    return FavouriteCategory(
      name: name,
      imagePath: imagePath,
      imageSize: imageSize,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      textStyle: textStyle,
    );
  }

  // Factory constructor for custom widget
  factory FavouriteCategory.withWidget({
    required String name,
    required Widget widget,
    Color? backgroundColor,
    Color? borderColor,
    TextStyle? textStyle,
  }) {
    return FavouriteCategory(
      name: name,
      imageWidget: widget,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      textStyle: textStyle,
    );
  }
}
