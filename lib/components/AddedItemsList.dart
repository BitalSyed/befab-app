
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this import is at the top

class AddedItemsList extends StatefulWidget {
  final List<AddedItem> items;
  final String title;
  final Function(int)? onItemRemoved;
  final Function(int, int)? onQuantityChanged;
  final TextStyle? titleStyle;
  final Color? deleteButtonColor;
  final EdgeInsets? padding;

  const AddedItemsList({
    Key? key,
    required this.items,
    this.title = 'Added Items',
    this.onItemRemoved,
    this.onQuantityChanged,
    this.titleStyle,
    this.deleteButtonColor,
    this.padding,
  }) : super(key: key);

  @override
  _AddedItemsListState createState() => _AddedItemsListState();
}

class _AddedItemsListState extends State<AddedItemsList> {
  late List<AddedItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: widget.titleStyle ?? TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: item.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: item.borderColor != null 
                      ? Border.all(color: item.borderColor!, width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: item.nameColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: item.descriptionColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.showQuantity) ...[
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: item.quantityBackgroundColor,
                          borderRadius: BorderRadius.circular(6),
                          border: item.quantityBorderColor != null
                              ? Border.all(color: item.quantityBorderColor!)
                              : null,
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: item.quantityTextColor,
                          ),
                        ),
                      ),
                    ],
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _items.removeAt(index);
                        });
                        if (widget.onItemRemoved != null) {
                          widget.onItemRemoved!(index);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: SvgPicture.asset("assets/images/bin.svg",color: Color(0xFFFF1919),width: 20,height: 20,)
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AddedItem {
  final String name;
  final String description;
  final int quantity;
  final bool showQuantity;
  final Color nameColor;
  final Color descriptionColor;
  final Color backgroundColor;
  final Color? borderColor;
  final Color quantityTextColor;
  final Color quantityBackgroundColor;
  final Color? quantityBorderColor;

  AddedItem({
    required this.name,
    required this.description,
    this.quantity = 1,
    this.showQuantity = true,
    this.nameColor = const Color(0xFF862633), // Brown color
    this.descriptionColor = const Color(0xFF000000), // Gray color
    this.backgroundColor = const Color(0xFFFAFBFB), // Light gray background
    this.borderColor,
    this.quantityTextColor = const Color(0xFF862633), // Brown color
    this.quantityBackgroundColor = Colors.transparent,
    this.quantityBorderColor,
  });

  // Factory constructor for food items (matching your original design)
  factory AddedItem.food({
    required String name,
    required String servingInfo,
    required int calories,
    int quantity = 1,
  }) {
    return AddedItem(
      name: name,
      description: '$servingInfo, $calories Cal',
      quantity: quantity,
      nameColor: Color(0xFF862633),
      descriptionColor: Color(0xFF000000),
      backgroundColor: Color(0xFFFAFBFB),
      quantityTextColor: Color(0xFF862633),
    );
  }

  // Factory constructor for custom colored items
  factory AddedItem.custom({
    required String name,
    required String description,
    int quantity = 1,
    Color nameColor = Colors.black,
    Color descriptionColor = Colors.grey,
    Color backgroundColor = Colors.white,
    Color? borderColor,
    Color quantityTextColor = Colors.black,
    Color quantityBackgroundColor = Colors.transparent,
  }) {
    return AddedItem(
      name: name,
      description: description,
      quantity: quantity,
      nameColor: nameColor,
      descriptionColor: descriptionColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      quantityTextColor: quantityTextColor,
      quantityBackgroundColor: quantityBackgroundColor,
    );
  }
}
