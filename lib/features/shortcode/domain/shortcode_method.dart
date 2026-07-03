import 'package:flutter/material.dart';

enum ShortcodeMethod {
  agentToAgent(
    key: 'agent_to_agent',
    title: 'Agent to Agent',
    subtitle: 'Send float to an agent',
    menuCode: '3',
    baseCode: '*153*3#',
    numberLabel: 'Agent code',
    numberHint: 'e.g. 12345',
    amountLabel: 'USD amount',
    needsAgentCode: true,
    stripLeadingZero: false,
    icon: Icons.swap_horiz_rounded,
  ),
  cashIn(
    key: 'cash_in',
    title: 'Cash In',
    subtitle: 'Customer cash-in',
    menuCode: '1',
    baseCode: '*153*1*1#',
    numberLabel: 'Customer number',
    numberHint: 'e.g. 0772123456',
    amountLabel: 'USD amount',
    needsAgentCode: false,
    stripLeadingZero: true,
    icon: Icons.south_west_rounded,
  ),
  airtime(
    key: 'airtime',
    title: 'Buy Airtime',
    subtitle: 'Top up a mobile number',
    menuCode: '4',
    baseCode: '*153*4#',
    numberLabel: 'Phone number',
    numberHint: 'e.g. 0772123456',
    amountLabel: 'USD amount',
    needsAgentCode: false,
    stripLeadingZero: false,
    icon: Icons.bolt_rounded,
  ),
  cashDeposit(
    key: 'cash_deposit',
    title: 'Cash Deposit',
    subtitle: 'Deposit to another wallet',
    menuCode: '6',
    baseCode: '*153*6#',
    numberLabel: 'Recipient number',
    numberHint: 'e.g. 0772123456',
    amountLabel: 'USD amount',
    needsAgentCode: false,
    stripLeadingZero: true,
    icon: Icons.account_balance_wallet_rounded,
  );

  const ShortcodeMethod({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.menuCode,
    required this.baseCode,
    required this.numberLabel,
    required this.numberHint,
    required this.amountLabel,
    required this.needsAgentCode,
    required this.stripLeadingZero,
    required this.icon,
  });

  final String key;
  final String title;
  final String subtitle;
  final String menuCode;
  final String baseCode;
  final String numberLabel;
  final String numberHint;
  final String amountLabel;
  final bool needsAgentCode;
  final bool stripLeadingZero;
  final IconData icon;

  String build(String target, String amount) {
    return switch (this) {
      ShortcodeMethod.agentToAgent => '*153*3*$target*$amount#',
      ShortcodeMethod.cashIn => '*153*1*1*$target*$amount#',
      ShortcodeMethod.airtime => '*153*4*$target*$amount#',
      ShortcodeMethod.cashDeposit => '*153*6*$target*$amount#',
    };
  }
}
