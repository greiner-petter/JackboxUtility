import 'package:fluent_ui/fluent_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jackbox_patcher/model/patchserver.dart';
import 'package:jackbox_patcher/services/user/userdata.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/api/api_service.dart';

class ServerInfoWidget extends StatefulWidget {
  ServerInfoWidget({Key? key}) : super(key: key);

  @override
  State<ServerInfoWidget> createState() => _ServerInfoWidgetState();
}

class _ServerInfoWidgetState extends State<ServerInfoWidget> {
  double calculatePadding() {
    if (MediaQuery.of(context).size.width > 1000) {
      return (MediaQuery.of(context).size.width - 880) / 2;
    } else {
      return 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    Typography typography = FluentTheme.of(context).typography;
    return Padding(
        padding:
            EdgeInsets.symmetric(vertical: 24, horizontal: calculatePadding()),
        child: ListView(children: [
          Column(children: [
            Row(children: [
              Text(AppLocalizations.of(context)!.selected_server,
                  style: typography.titleLarge),
              Spacer(),
              FilledButton(
                  child: Text(AppLocalizations.of(context)!.change_server),
                  onPressed: () async {
                    UserData().setSelectedServer(null);
                    UserData().packs = [];
                    APIService().resetCache();
                    Navigator.of(context).pop();
                  })
            ]),
            SizedBox(height: 50),
            ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                    APIService()
                        .assetLink(APIService().cachedSelectedServer!.image),
                    height: 100)),
            Text(APIService().cachedSelectedServer!.name,
                style: FluentTheme.of(context).typography.titleLarge),
            SizedBox(
              height: 8,
            ),
            Text(APIService().cachedSelectedServer!.description,
                style: FluentTheme.of(context).typography.body),
            SizedBox(
              height: 36,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(FluentIcons.package),
              SizedBox(
                width: 12,
              ),
              Text(AppLocalizations.of(context)!
                  .games_available(UserData().packs.length))
            ]),
            SizedBox(
              height: 12,
            ),
            // if (APIService().cachedSelectedServer!.controllerUrl != null)
            //   HyperlinkButton(
            //       child:
            //           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            //         Icon(FluentIcons.cell_phone),
            //         SizedBox(
            //           width: 12,
            //         ),
            //         Text(APIService().cachedSelectedServer!.controllerUrl!)
            //       ]),
            //       onPressed: () {
            //         launchUrl(Uri.http(
            //             APIService().cachedSelectedServer!.controllerUrl!));
            //       }),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _buildLinks())
          ]),
          if (APIService().cachedConfigurations!.getConfiguration(
                  "SERVER_INFORMATION", "SHOW_PATREONS_SUBSCRIBERS") ==
              true)
            _buildPatreonSubscribers()
        ]));
  }

  _buildLinks() {
    List<Row> links = [];

    for (int i = 0; i < APIService().cachedSelectedServer!.links.length; i++) {
      PatchServerLink e = APIService().cachedSelectedServer!.links[i];
      if (i % 2 == 0) {
        links.add(
            Row(mainAxisAlignment: MainAxisAlignment.center, children: []));
      }
      links.last.children.add(HyperlinkButton(
          child: Container(
              width: 150,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(_buildIcon(e.icon)),
                SizedBox(
                  width: 12,
                ),
                Text(e.text)
              ])),
          onPressed: () {
            launchUrl(Uri.parse(e.url));
          }));
    }
    return links;
  }

  _buildPatreonSubscribers() {
    List<dynamic> patreonsSubscribers = APIService().cachedConfigurations!
        .getConfiguration("SERVER_INFORMATION", "PATREONS_SUBSCRIBERS") as List<dynamic>;
    return Container(
      margin: EdgeInsets.only(top:24),
        decoration: BoxDecoration(
          color: FluentTheme.of(context).menuColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              
              children: [
                Row(
                  children: [
                    Icon(FontAwesomeIcons.patreon),
                    SizedBox(width: 12),
                    Text("Patreon subscribers", style: FluentTheme.of(context).typography.subtitle),
                  ],
                ),
                SizedBox(height: 12),
                 Text(
                        patreonsSubscribers.join(", "),
                      )
              ],
            )));
  }

  _buildIcon(String icon) {
    switch (icon) {
      case "discord":
        return FontAwesomeIcons.discord;
      case "reddit":
        return FontAwesomeIcons.reddit;
      case "twitter":
        return FontAwesomeIcons.twitter;

      case "facebook":
        return FontAwesomeIcons.facebook;

      case "youtube":
        return FontAwesomeIcons.youtube;

      case "twitch":
        return FontAwesomeIcons.twitch;

      case "globe":
        return FontAwesomeIcons.globe;

      case "paypal":
        return FontAwesomeIcons.paypal;

      case "cc-paypal":
        return FontAwesomeIcons.ccPaypal;

      case "patreon":
        return FontAwesomeIcons.patreon;

      case "cellphone":
        return FluentIcons.cell_phone;

      default:
        return FontAwesomeIcons.link;
    }
  }
}
