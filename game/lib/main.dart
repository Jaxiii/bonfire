import 'dart:io';

import 'package:bonfire/bonfire.dart';
import 'package:example/shared/enemy/goblin_controller.dart';
import 'package:example/shared/interface/bar_life_controller.dart';
import 'package:example/shared/npc/critter/critter_controller.dart';
import 'package:example/shared/other/other_player_controller.dart';
import 'package:example/shared/player/knight_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'network/message.dart';
import 'network/message_service.dart';
import 'network/websocket_service.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';

import 'tiled_map/multi_scenario.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }
  final WebsocketService websocket = WebsocketService();
  BonfireInjector().putFactory((i) => GameController());

  BonfireInjector().putFactory((i) => GoblinController());
  BonfireInjector().putFactory((i) => CritterController());
  BonfireInjector().put((i) => BarLifeController());
  BonfireInjector.instance.put((i) => websocket);
  BonfireInjector.instance.put(
    (i) => MessageService(
      websocket: i.get<WebsocketService>(),
    ),
  );
  BonfireInjector.instance.put(
    (i) => PlayerController(messageService: i.get()),
  );

  BonfireInjector.instance.putFactory(
    (i) => OtherPlayerController(messageService: i.get()),
  );

  runApp(
    const MaterialApp(
      home: Menu(),
    ),
  );
}

// 1. Create instance of [SolanaWalletAdapter].
final adapter = SolanaWalletAdapter(
  const AppIdentity(),
  // NOTE: CONNECT THE WALLET APPLICATION
  //       TO THE SAME NETWORK.
  cluster: Cluster.devnet,
);

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[900],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            kIsWeb
                ? Column(
                    children: [
                      Center(
                        child: RichText(
                          text: const TextSpan(
                            text: 'Jaxi Solana Central',
                            style: TextStyle(fontSize: 30, color: Colors.white),
                            children: [
                              TextSpan(
                                text: '  v0.0.1a',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const AuthorizeButton(),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  )
                : const SizedBox(),
            SizedBox(
              height: MediaQuery.of(context).size.height * (kIsWeb ? 0.8 : 1),
              width: MediaQuery.of(context).size.width * (kIsWeb ? 0.8 : 1),
              child: const MultiScenario2(),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthorizeButton extends StatefulWidget {
  const AuthorizeButton({Key? key}) : super(key: key);
  @override
  State<AuthorizeButton> createState() => _AuthorizeButtonState();
}

class _AuthorizeButtonState extends State<AuthorizeButton> {
  Object? _output;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            // 2. Authorize application with wallet.
            adapter
                .authorize()
                .then((result) => setState(() => _output = result.toJson()))
                .catchError((error) => setState(() => _output = error));
          },
          child: const Text('Authorize'),
        ),
        if (_output != null) Text(_output.toString()),
      ],
    );
  }
}
