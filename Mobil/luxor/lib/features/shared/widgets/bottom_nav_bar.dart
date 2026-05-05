import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 68 + bottom,
      padding: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: LuxorColors.background.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: LuxorColors.surfaceElevated, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Feed', index: 0, current: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.explore_outlined, label: 'Discover', index: 1, current: currentIndex, onTap: onTap),
          _PostButton(onTap: () => onTap(2)),
          _NavItem(icon: Icons.notifications_outlined, label: 'Alerts', index: 3, current: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.person_outline_rounded, label: 'Profile', index: 4, current: currentIndex, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final Function(int) onTap;

  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? LuxorColors.primary : LuxorColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? LuxorColors.primary : LuxorColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PostButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LuxorColors.gradientPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: LuxorColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
