// lib/widgets/tooth_picker.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

typedef ToothChanged = void Function(String toothNumber);

/// FDI order (18-11, 21-28) and (48-41, 31-38)
const List<String> _upperFDI = [
  '18',
  '17',
  '16',
  '15',
  '14',
  '13',
  '12',
  '11',
  '21',
  '22',
  '23',
  '24',
  '25',
  '26',
  '27',
  '28',
];
const List<String> _lowerFDI = [
  '48',
  '47',
  '46',
  '45',
  '44',
  '43',
  '42',
  '41',
  '31',
  '32',
  '33',
  '34',
  '35',
  '36',
  '37',
  '38',
];

/// UTN (Universal Tooth Numbering) order for reference.
const List<String> _upperUTN = [
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
];
const List<String> _lowerUTN = [
  '32',
  '31',
  '30',
  '29',
  '28',
  '27',
  '26',
  '25',
  '24',
  '23',
  '22',
  '21',
  '20',
  '19',
  '18',
  '17',
];

/// Classes -> which icon size to use
enum _ToothClass { incisor, canine, premolar, molar }

/// Supported numbering systems for display.
enum ToothNumberingSystem { fdi, utn }

_ToothClass _classForFDI(String number) {
  final digit = (int.tryParse(number) ?? 0) % 10;
  if (digit == 1 || digit == 2) return _ToothClass.incisor;
  if (digit == 3) return _ToothClass.canine;
  if (digit == 4 || digit == 5) return _ToothClass.premolar;
  return _ToothClass.molar;
}

double _iconSizeFor(_ToothClass type, {required bool isUpper}) {
  switch (type) {
    case _ToothClass.molar:
      return isUpper ? 48 : 44;
    case _ToothClass.premolar:
      return isUpper ? 44 : 40;
    case _ToothClass.canine:
      return isUpper ? 42 : 38;
    case _ToothClass.incisor:
      return isUpper ? 40 : 36;
  }
}

List<String> _displayNumbers(bool isUpper, ToothNumberingSystem system) {
  if (system == ToothNumberingSystem.utn) {
    return isUpper ? _upperUTN : _lowerUTN;
  }
  return isUpper ? _upperFDI : _lowerFDI;
}

String _systemTitle(ToothNumberingSystem system) =>
    system == ToothNumberingSystem.fdi ? 'FDI numbering' : 'UTN numbering';

/// Tooth picker showing two dental arches with Font Awesome icons.
class ToothPicker extends StatelessWidget {
  const ToothPicker({
    super.key,
    required this.selectedTooth,
    required this.onChanged,
    this.showLabels = true,
    this.archDepth = 36,
    this.slotCount = 16,
    this.minSlotWidth = 42,
    this.maxSlotWidth = 72,
    this.height = 340,
    this.enableHaptics = false,
    this.numberingSystem = ToothNumberingSystem.fdi,
  });

  final String? selectedTooth;
  final ToothChanged onChanged;
  final bool showLabels;
  final double archDepth;
  final int slotCount;
  final double minSlotWidth;
  final double maxSlotWidth;
  final double height;
  final bool enableHaptics;
  final ToothNumberingSystem numberingSystem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lightSurface =
        theme.brightness == Brightness.dark
            ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.35)
            : const Color(0xFFF8FAFC);
    final lineColor = const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: lightSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final slotWidth = (width / (slotCount + 2)).clamp(
            minSlotWidth,
            maxSlotWidth,
          );
          final contentWidth = slotWidth * slotCount;
          final horizontalOffset = (width - contentWidth) / 2;

          final upperBaseline = height * 0.28;
          final lowerBaseline = height * 0.68;

          final upperNumbersTop = upperBaseline - archDepth - 32;
          final lowerNumbersTop = lowerBaseline + archDepth + 12;

          final maxUpperIcon = _iconSizeFor(_ToothClass.molar, isUpper: true);
          final maxLowerIcon = _iconSizeFor(_ToothClass.molar, isUpper: false);
          const rowPadding = 12.0;

          final upperRowTop = upperBaseline - archDepth - rowPadding;
          final upperRowHeight = archDepth + maxUpperIcon + rowPadding * 2;
          final lowerRowTop = lowerBaseline - maxLowerIcon - rowPadding;
          final lowerRowHeight = archDepth + maxLowerIcon + rowPadding * 2;

          final quadrantWidth = contentWidth / 2;
          final verticalLineLeft = horizontalOffset + quadrantWidth - 0.5;
          final horizontalLineTop = (upperBaseline + lowerBaseline) / 2;

          final numberingTitle = _systemTitle(numberingSystem);

          return SizedBox(
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: upperNumbersTop - 22,
                  left: 0,
                  right: 0,
                  child: Text(
                    numberingTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Stack(
                    children: [
                      Positioned(
                        left: verticalLineLeft,
                        top: 0,
                        width: 1,
                        height: height,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: lineColor),
                        ),
                      ),
                      Positioned(
                        left: horizontalOffset,
                        top: horizontalLineTop - 0.5,
                        width: contentWidth,
                        height: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: lineColor),
                        ),
                      ),
                      _quadrantLabel(
                        left: horizontalOffset,
                        top: upperNumbersTop - 28,
                        width: quadrantWidth,
                        label: 'Q1 - Upper Right',
                      ),
                      _quadrantLabel(
                        left: horizontalOffset + quadrantWidth,
                        top: upperNumbersTop - 28,
                        width: quadrantWidth,
                        label: 'Q2 - Upper Left',
                      ),
                      _quadrantLabel(
                        left: horizontalOffset,
                        top: lowerNumbersTop + 18,
                        width: quadrantWidth,
                        label: 'Q4 - Lower Right',
                      ),
                      _quadrantLabel(
                        left: horizontalOffset + quadrantWidth,
                        top: lowerNumbersTop + 18,
                        width: quadrantWidth,
                        label: 'Q3 - Lower Left',
                      ),
                    ],
                  ),
                ),
                if (showLabels)
                  _numbersRow(
                    numbers: _displayNumbers(true, numberingSystem),
                    top: upperNumbersTop,
                    left: horizontalOffset,
                    slotWidth: slotWidth,
                    contentWidth: contentWidth,
                  ),
                _archedRow(
                  context,
                  numbers: _upperFDI,
                  isUpper: true,
                  slotWidth: slotWidth,
                  contentWidth: contentWidth,
                  top: upperRowTop,
                  rowHeight: upperRowHeight,
                  depth: archDepth,
                  left: horizontalOffset,
                ),
                _archedRow(
                  context,
                  numbers: _lowerFDI,
                  isUpper: false,
                  slotWidth: slotWidth,
                  contentWidth: contentWidth,
                  top: lowerRowTop,
                  rowHeight: lowerRowHeight,
                  depth: archDepth,
                  left: horizontalOffset,
                ),
                if (showLabels)
                  _numbersRow(
                    numbers: _displayNumbers(false, numberingSystem),
                    top: lowerNumbersTop,
                    left: horizontalOffset,
                    slotWidth: slotWidth,
                    contentWidth: contentWidth,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Positioned _quadrantLabel({
    required double left,
    required double top,
    required double width,
    required String label,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _numbersRow({
    required List<String> numbers,
    required double top,
    required double left,
    required double slotWidth,
    required double contentWidth,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: contentWidth,
      child: Row(
        children:
            numbers
                .map(
                  (number) => SizedBox(
                    width: slotWidth,
                    child: Text(
                      number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _archedRow(
    BuildContext context, {
    required List<String> numbers,
    required bool isUpper,
    required double slotWidth,
    required double contentWidth,
    required double top,
    required double rowHeight,
    required double depth,
    required double left,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    const iconShadows = [
      Shadow(color: Color(0x220F172A), offset: Offset(0, -1), blurRadius: 2),
      Shadow(color: Color(0x33000000), offset: Offset(0, 4), blurRadius: 8),
      Shadow(color: Color(0x1F000000), offset: Offset(0, 12), blurRadius: 18),
    ];

    return Positioned(
      left: left,
      top: top,
      width: contentWidth,
      height: rowHeight,
      child: Row(
        children: List.generate(slotCount, (index) {
          final toothNumber = numbers[index];
          final toothClass = _classForFDI(toothNumber);
          final iconSize = _iconSizeFor(toothClass, isUpper: isUpper);
          final selected = toothNumber == selectedTooth;

          final normalized = index / (slotCount - 1);
          final curve = math.sin(normalized * math.pi);
          final translatedY = (isUpper ? 1 : -1) * curve * depth;

          return SizedBox(
            width: slotWidth,
            child: Semantics(
              button: true,
              selected: selected,
              label: 'Tooth $toothNumber',
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  onChanged(toothNumber);
                  // if (enableHaptics) HapticFeedback.lightImpact();
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        selected
                            ? primaryColor.withOpacity(0.12)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Transform.translate(
                    offset: Offset(0, translatedY),
                    child: Transform.rotate(
                      angle: isUpper ? math.pi : 0,
                      child: FaIcon(
                        FontAwesomeIcons.tooth,
                        size: iconSize,
                        color: selected ? primaryColor : Colors.white,
                        shadows: selected ? null : iconShadows,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
