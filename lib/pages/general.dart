import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sfuser/ui/click_tooltip.dart';
import 'package:sfuser/ui/section_card.dart';
import 'package:sfuser/logic/record.dart';
import 'package:sfuser/logic/records_manager.dart';

class GeneralPage extends StatefulWidget {
  const GeneralPage({super.key});

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class Field {
  final String iconPath;
  final String name;
  final String? tooltip;
  final bool numeric;
  final TextEditingController controller;
  final void Function(String) callback;

  Field(this.iconPath, this.name, this.controller, this.callback,
      {this.tooltip, this.numeric = true});
}

const _bigValueTooltip = "Setting a value higher that 999 999 999 is not recommended";

class _GeneralPageState extends State<GeneralPage> {
  late final List<Field> currencies;
  late final List<Field> progression;
  late final List<Field> profile;
  late final List<Field> inventory;
  late final List<List<Field>> sections;

  Field _numberField(String icon, String name, int value,
      void Function(String) onSave, {String? tooltip}) {
    return Field(icon, name, TextEditingController(text: value.toString()),
        onSave,
        tooltip: tooltip);
  }

  @override
  void initState() {
    super.initState();
    final record = RecordsManager.activeRecord!;

    currencies = [
      _numberField("assets/images/coin.png", "Coins",
          record.getCurrency(Currency.coins), (value) {
        RecordsManager.activeRecord!
            .setCurrency(Currency.coins, int.tryParse(value) ?? 0);
      }),
      _numberField("assets/images/ruby.png", "Gems",
          record.getCurrency(Currency.gems), (value) {
        RecordsManager.activeRecord!
            .setCurrency(Currency.gems, int.tryParse(value) ?? 0);
      }, tooltip: _bigValueTooltip),
      _numberField("assets/images/forge_green.png", "Green orbs",
          record.getCurrency(Currency.greenOrbs), (value) {
        RecordsManager.activeRecord!
            .setCurrency(Currency.greenOrbs, int.tryParse(value) ?? 0);
      }, tooltip: _bigValueTooltip),
      _numberField("assets/images/forge_red.png", "Red orbs",
          record.getCurrency(Currency.redOrbs), (value) {
        RecordsManager.activeRecord!
            .setCurrency(Currency.redOrbs, int.tryParse(value) ?? 0);
      }, tooltip: _bigValueTooltip),
      _numberField("assets/images/forge_purple.png", "Purple orbs",
          record.getCurrency(Currency.purpleOrbs), (value) {
        RecordsManager.activeRecord!
            .setCurrency(Currency.purpleOrbs, int.tryParse(value) ?? 0);
      }, tooltip: _bigValueTooltip),
    ];

    progression = [
      _numberField("assets/images/shuriken.png", "Level", record.level,
          (value) {
        RecordsManager.activeRecord!.level = int.tryParse(value) ?? 1;
      }),
      _numberField("assets/images/shuriken.png", "Experience",
          record.experience, (value) {
        RecordsManager.activeRecord!.experience = int.tryParse(value) ?? 0;
      }),
    ];

    profile = [
      Field("assets/images/file.png", "First name",
          TextEditingController(text: record.firstName), (value) {
        RecordsManager.activeRecord!.firstName = value.trim();
      }, numeric: false),
      Field("assets/images/file.png", "Avatar",
          TextEditingController(text: record.avatar), (value) {
        RecordsManager.activeRecord!.avatar = value.trim();
      }, tooltip: "Avatar ID, for example avatar_hero", numeric: false),
    ];

    inventory = [
      _numberField("assets/images/dojo.png", "Ascension Ticket",
          record.ascensionTickets, (value) {
        RecordsManager.activeRecord!.ascensionTickets =
            int.tryParse(value) ?? 0;
      }),
    ];

    sections = [currencies, progression, profile, inventory];
  }

  Widget _fieldRow(Field field) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Image.asset(field.iconPath, width: 28, height: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(field.name, style: theme.textTheme.bodyLarge),
          ),
          SizedBox(
            width: 150,
            child: TextField(
              controller: field.controller,
              keyboardType:
                  field.numeric ? TextInputType.number : TextInputType.text,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (field.tooltip != null) ...[
            const SizedBox(width: 4),
            ClickTooltip(
              message: field.tooltip,
              decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(16),
                  color: theme.canvasColor),
              textStyle: theme.textTheme.bodyMedium,
              child: const Icon(Icons.info_outline, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _section(String title, String description, Widget icon,
      List<Field> fields,
      {bool initiallyExpanded = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: IconTile(child: icon),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(description),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: fields.map(_fieldRow).toList(),
        ),
      ),
    );
  }

  Widget _toggle(String name, String iconPath, bool value,
      void Function(bool) onChanged) {
    return SwitchListTile(
      secondary: Image.asset(iconPath, width: 28, height: 28),
      title: Text(name),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _optionsSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: const IconTile(child: Icon(Icons.tune)),
          title: Text("Options",
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: const Text("Toggles for the active save"),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          children: [
            _toggle("Dojo Disciple", "assets/images/dojo.png",
                RecordsManager.activeRecord!.isDiscipleEnabled, (value) {
              setState(() {
                RecordsManager.activeRecord!.isDiscipleEnabled = value;
              });
            }),
            _toggle("Unlimited Energy", "assets/images/lighting.png",
                RecordsManager.activeRecord!.isEnergyUnlimited, (value) {
              setState(() {
                RecordsManager.activeRecord!.isEnergyUnlimited = value;
              });
            }),
            _toggle("Show Forge", "assets/images/anvil.png",
                RecordsManager.activeRecord!.showForge, (value) {
              setState(() {
                RecordsManager.activeRecord!.showForge = value;
              });
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _section(
              "Currencies",
              "Coins, gems and forge materials",
              Image.asset("assets/images/treasure-chest.png",
                  width: 26, height: 26),
              currencies,
              initiallyExpanded: true),
          _section(
              "Progression",
              "Level and experience",
              const Icon(Icons.arrow_upward, color: Colors.lightGreen),
              progression),
          _section(
              "Profile",
              "First name and avatar",
              const Icon(Icons.person, color: Colors.blue),
              profile),
          _section(
              "Items",
              "Ascension Ticket count",
              Image.asset("assets/images/dojo.png", width: 26, height: 26),
              inventory),
          _optionsSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: save,
        icon: const Icon(Icons.save),
        label: const Text("Save"),
      ),
    );
  }

  void save() {
    for (var section in sections) {
      for (var field in section) {
        field.callback(field.controller.text);
      }
    }

    RecordsManager.saveRecord(RecordsManager.activeRecord!).then((_) {
      Fluttertoast.showToast(msg: "Saved successfully");
    });
  }
}
