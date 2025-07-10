import 'package:dan_xi/generated/l10n.dart';
import 'package:dan_xi/provider/settings_provider.dart';
import 'package:dan_xi/common/constant.dart';
import 'package:dan_xi/util/browser_util.dart';
import 'package:dan_xi/util/master_detail_view.dart';
import 'package:dan_xi/widget/dialogs/login_dialog.dart';
import 'package:flutter/material.dart';
import 'package:dan_xi/provider/state_provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool _uisLoggedIn;

  @override
  void initState() {
    super.initState();
    _uisLoggedIn = StateProvider.personInfo.value != null;
    StateProvider.personInfo.addListener(_onPersonInfoChanged);
  }

  void _onPersonInfoChanged() {
    setState(() {
      _uisLoggedIn = StateProvider.personInfo.value != null;
    });
  }

  @override
  void dispose() {
    StateProvider.personInfo.removeListener(_onPersonInfoChanged);
    super.dispose();
  }

  final Color _primary = const Color(0xFF5660C9);
  final Color _tint = const Color(0xFFE7E9FC);

  @override
  Widget build(BuildContext context) {
    final bool forumLoggedIn =
        context.watch<SettingsProvider>().forumToken != null;
    bool canEnter = _uisLoggedIn || forumLoggedIn;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _loginCard(
                    title: '复旦 UIS 登录',
                    subtitle: '统一身份认证服务',
                    logged: _uisLoggedIn,
                    buttons: [
                      _gradientBtn(
                        label: '本科生登录',
                        tint: _primary,
                        enabled: !_uisLoggedIn,
                        onTap: () => LoginDialog.showLoginDialog(
                            context,
                            SettingsProvider.getInstance().preferences,
                            StateProvider.personInfo,
                            true,
                            showFullOptions: false),
                      ),
                      _gradientBtn(
                        label: '研究生登录',
                        tint: _primary,
                        enabled: !_uisLoggedIn,
                        onTap: () => LoginDialog.showLoginDialog(
                            context,
                            SettingsProvider.getInstance().preferences,
                            StateProvider.personInfo,
                            true,
                            showFullOptions: false,
                            isGraduate: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _loginCard(
                    title: '旦挞帐号登录',
                    subtitle: '旦挞社区与服务',
                    logged: forumLoggedIn,
                    buttons: [
                      _gradientBtn(
                        label: '使用邮箱登录',
                        tint: _primary,
                        enabled: !forumLoggedIn,
                        onTap: () async {
                          await smartNavigatorPush(context, "/bbs/login",
                              arguments: {
                                "info": StateProvider.personInfo.value
                              });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.center,
                child: Text.rich(
                  TextSpan(
                    text: '登录即代表您同意',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: GestureDetector(
                          onTap: () {
                            BrowserUtil.openUrl(
                                Constant.TERMS_AND_CONDITIONS_URL, context);
                          },
                          child: Text(
                            '服务条款和隐私政策',
                            style: const TextStyle(
                              fontSize: 12,
                              // color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: FilledButton(
                onPressed: canEnter
                    ? () {
                        SettingsProvider.getInstance().isLoggedIn = true;
                        StateProvider.isLoggedIn.value = true;
                        showFAQ();
                      }
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: canEnter ? _primary : _tint,
                  foregroundColor: canEnter ? Colors.white : Colors.black38,
                  disabledBackgroundColor: _tint,
                ),
                child: const Text('进入应用', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginCard({
    required String title,
    required String subtitle,
    required List<Widget> buttons,
    required bool logged,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
                if (logged) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle, color: Colors.green, size: 22),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              logged ? '已登录' : subtitle,
              style: TextStyle(
                color: logged ? Colors.green : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ..._interleave(buttons, const SizedBox(height: 14)),
          ],
        ),
      ),
    );
  }

  Widget _gradientBtn({
    required String label,
    required VoidCallback? onTap,
    required bool enabled,
    Color? tint,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Ink(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: enabled
              ? LinearGradient(
                  colors: [
                    tint ?? _tint,
                    tint != null ? tint.withOpacity(0.8) : _tint,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: enabled ? null : _tint,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.black38,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _interleave(List<Widget> children, Widget separator) {
    if (children.isEmpty) return [];
    final List<Widget> output = [];
    for (var i = 0; i < children.length; i++) {
      output.add(children[i]);
      if (i != children.length - 1) output.add(separator);
    }
    return output;
  }

  Future<bool?> showFAQ() {
    return showPlatformDialog(
        context: context,
        builder: (BuildContext context) => PlatformAlertDialog(
              title: PlatformText(
                S.of(context).welcome_feature,
                textAlign: TextAlign.center,
              ),
              content: PlatformText(
                S.of(context).welcome_prompt,
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                PlatformDialogAction(
                    child: PlatformText(S.of(context).skip),
                    onPressed: () => Navigator.pop(context)),
                PlatformDialogAction(
                    child: PlatformText(S.of(context).i_see),
                    onPressed: () {
                      BrowserUtil.openUrl(Constant.FAQ_URL, context);
                    }),
              ],
            ));
  }
}
