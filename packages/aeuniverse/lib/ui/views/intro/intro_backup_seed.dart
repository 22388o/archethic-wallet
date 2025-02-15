// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:aeuniverse/appstate_container.dart';
import 'package:aeuniverse/ui/util/styles.dart';
import 'package:aeuniverse/ui/views/mnemonic_display.dart';
import 'package:aeuniverse/ui/widgets/components/buttons.dart';
import 'package:aeuniverse/ui/widgets/components/icon_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:core/localization.dart';
import 'package:core/model/data/appdb.dart';
import 'package:core/model/data/hive_db.dart';
import 'package:core/util/get_it_instance.dart';
import 'package:core/util/mnemonics.dart';
import 'package:core/util/seeds.dart';
import 'package:core/util/vault.dart';
import 'package:core_ui/ui/util/dimens.dart';
import 'package:core_ui/util/app_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IntroBackupSeedPage extends StatefulWidget {
  const IntroBackupSeedPage({Key? key}) : super(key: key);

  @override
  _IntroBackupSeedState createState() => _IntroBackupSeedState();
}

class _IntroBackupSeedState extends State<IntroBackupSeedPage> {
  List<String>? _mnemonic;

  @override
  void initState() {
    super.initState();

    Vault.getInstance().then((Vault _vault) {
      setState(() {
        _mnemonic = AppMnemomics.seedToMnemonic(_vault.getSeed()!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: StateContainer.of(context).curTheme.backgroundDarkest,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  StateContainer.of(context).curTheme.backgroundDark!,
                  StateContainer.of(context).curTheme.background!
                ],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                SafeArea(
              minimum: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.035,
                  top: MediaQuery.of(context).size.height * 0.075),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsetsDirectional.only(
                                  start: smallScreen(context) ? 15 : 20),
                              height: 50,
                              width: 50,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: FaIcon(FontAwesomeIcons.chevronLeft,
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      size: 24)),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsetsDirectional.only(
                            start: smallScreen(context) ? 30 : 40,
                            top: 15,
                          ),
                          child: buildIconWidget(
                              context,
                              'packages/aeuniverse/assets/icons/key-word.png',
                              90,
                              90),
                        ),
                        Container(
                          margin: EdgeInsetsDirectional.only(
                            start: smallScreen(context) ? 30 : 40,
                            end: smallScreen(context) ? 30 : 40,
                            top: 10,
                          ),
                          alignment: const AlignmentDirectional(-1, 0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width -
                                            (smallScreen(context) ? 120 : 140)),
                                child: AutoSizeText(
                                  AppLocalization.of(context)!.recoveryPhrase,
                                  style: AppStyles.textStyleSize20W700Primary(
                                      context),
                                  stepGranularity: 0.1,
                                  minFontSize: 12.0,
                                  maxLines: 1,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                color: StateContainer.of(context)
                                    .curTheme
                                    .backgroundDarkest,
                                onPressed: () async {
                                  Vault.getInstance().then((Vault _vault) {
                                    final String _seed =
                                        AppSeeds.generateSeed();
                                    _vault.setSeed(_seed);
                                    AppUtil()
                                        .loginAccount(_seed, context,
                                            forceNewAccount: true)
                                        .then((Account selectedAcct) {
                                      StateContainer.of(context)
                                          .requestUpdate(account: selectedAcct);
                                      _mnemonic = AppMnemomics.seedToMnemonic(
                                          _vault.getSeed()!);
                                    });
                                  });

                                  setState(() {});
                                },
                              )
                            ],
                          ),
                        ),
                        if (_mnemonic != null)
                          Expanded(
                            child: SingleChildScrollView(
                              child: MnemonicDisplay(wordList: _mnemonic!),
                            ),
                          )
                        else
                          const Text('')
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AppButton.buildAppButton(
                        const Key('iveBackedItUp'),
                        context,
                        AppButtonType.primary,
                        AppLocalization.of(context)!.iveBackedItUp,
                        Dimens.buttonBottomDimens,
                        onPressed: () {
                          sl.get<DBHelper>().dropAccounts().then((_) {
                            StateContainer.of(context)
                                .getSeed()
                                .then((String seed) {
                              AppUtil()
                                  .loginAccount(seed, context)
                                  .then((Account selectedAcct) {
                                StateContainer.of(context)
                                    .requestUpdate(account: selectedAcct);
                                StateContainer.of(context).requestUpdate(
                                  account: StateContainer.of(context)
                                      .selectedAccount,
                                );
                                Navigator.of(context)
                                    .pushNamed('/intro_backup_confirm');
                              });
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
