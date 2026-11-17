import 'package:flutter/material.dart';

class IconUtils {
  const IconUtils._();

  static const _iconMap = <String, IconData>{
    'restaurant': Icons.restaurant_rounded,
    'directions_bus': Icons.directions_bus_rounded,
    'shopping_bag': Icons.shopping_bag_rounded,
    'shopping_cart': Icons.shopping_cart_rounded,
    'receipt_long': Icons.receipt_long_rounded,
    'sports_esports': Icons.sports_esports_rounded,
    'health_and_safety': Icons.health_and_safety_rounded,
    'school': Icons.school_rounded,
    'local_cafe': Icons.local_cafe_rounded,
    'payments': Icons.payments_rounded,
    'redeem': Icons.redeem_rounded,
    'work': Icons.work_rounded,
    'card_giftcard': Icons.card_giftcard_rounded,
    'account_balance': Icons.account_balance_rounded,
    'account_balance_wallet': Icons.account_balance_wallet_rounded,
    'swap_horiz': Icons.swap_horiz_rounded,
    'savings': Icons.savings_rounded,
    'trending_up': Icons.trending_up_rounded,
    'more_horiz': Icons.more_horiz_rounded,
    'local_grocery_store': Icons.local_grocery_store_rounded,
    'local_gas_station': Icons.local_gas_station_rounded,
    'local_parking': Icons.local_parking_rounded,
    'build': Icons.build_rounded,
    'home': Icons.home_rounded,
    'bolt': Icons.bolt_rounded,
    'wifi': Icons.wifi_rounded,
    'home_repair_service': Icons.home_repair_service_rounded,
    'checkroom': Icons.checkroom_rounded,
    'devices': Icons.devices_rounded,
    'spa': Icons.spa_rounded,
    'local_laundry_service': Icons.local_laundry_service_rounded,
    'phone_android': Icons.phone_android_rounded,
    'subscriptions': Icons.subscriptions_rounded,
    'flight': Icons.flight_rounded,
    'hotel': Icons.hotel_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'palette': Icons.palette_rounded,
    'medical_services': Icons.medical_services_rounded,
    'medication': Icons.medication_rounded,
    'menu_book': Icons.menu_book_rounded,
    'child_care': Icons.child_care_rounded,
    'volunteer_activism': Icons.volunteer_activism_rounded,
    'mosque': Icons.mosque_rounded,
    'pets': Icons.pets_rounded,
    'gavel': Icons.gavel_rounded,
    'credit_card': Icons.credit_card_rounded,
    'store': Icons.store_rounded,
    'construction': Icons.construction_rounded,
    'campaign': Icons.campaign_rounded,
    'warning': Icons.warning_rounded,
    'access_time': Icons.access_time_rounded,
    'schedule': Icons.schedule_rounded,
    'celebration': Icons.celebration_rounded,
    'handshake': Icons.handshake_rounded,
    'support_agent': Icons.support_agent_rounded,
    'code': Icons.code_rounded,
    'edit': Icons.edit_rounded,
    'camera_alt': Icons.camera_alt_rounded,
    'music_note': Icons.music_note_rounded,
    'engineering': Icons.engineering_rounded,
    'apartment': Icons.apartment_rounded,
    'business_center': Icons.business_center_rounded,
    'storefront': Icons.storefront_rounded,
    'grass': Icons.grass_rounded,
    'show_chart': Icons.show_chart_rounded,
    'currency_bitcoin': Icons.currency_bitcoin_rounded,
    'copyright': Icons.copyright_rounded,
    'auto_awesome': Icons.auto_awesome_rounded,
    'send': Icons.send_rounded,
    'real_estate_agent': Icons.real_estate_agent_rounded,
    'replay': Icons.replay_rounded,
    'request_quote': Icons.request_quote_rounded,
  };

  static IconData resolveIcon(String? iconName) {
    if (iconName == null) return Icons.receipt_rounded;
    return _iconMap[iconName] ?? Icons.category_rounded;
  }

  static List<Map<String, dynamic>> get availableIcons =>
      _iconMap.entries
          .map((e) => {
                'name': e.key,
                'icon': e.value,
                'label': e.key.replaceAll('_', ' '),
              })
          .toList();
}
