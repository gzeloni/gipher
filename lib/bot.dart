import 'package:gipher/config/config.dart';
import 'package:gipher/data/urls_list.dart';
import 'package:gipher/functions.dart/gifs.dart';
import 'package:gipher/functions.dart/log_function.dart';
import 'package:nyxx/nyxx.dart';

void bot() {
  // Create Nyxx bot instance with necessary intents
  final bot = NyxxFactory.createNyxxWebsocket(
      Config.getToken(),
      GatewayIntents.allUnprivileged |
          GatewayIntents.allPrivileged |
          GatewayIntents.messageContent)
    ..registerPlugin(Logging());

  // Listener for when the bot is ready
  bot.eventsWs.onReady.listen((event) {
    print("Ready!");
  });

  // Listener for when a message is received
  bot.eventsWs.onMessageReceived.listen((event) async {
    final content = event.message.content;
    final words = content.split(' ');

    if (event.message.author.bot) {
      // Ignore messages sent by bots
      return;
    }

    // Check if the message starts with the "&make" command
    if (content.startsWith('<gif') && content.length >= 7) {
      // If there's not exactly one link, send an error message and return
      if (words.length < 2) {
        try {
          await event.message.channel.sendMessage(MessageBuilder.content(
              'Por favor, insira o termo da pesquisa após o comando " <gif " !'));
        } catch (e) {
          sendEmbedMessageErrorHandler(e, event, bot);
        }
        return;
      } else {
        try {
          String termos = words.sublist(1).join(' ');
          await getBartGifs(termos);
          var randomItem = (gifUrls..shuffle()).first;
          await event.message.channel
              .sendMessage(MessageBuilder.content(randomItem.toString()));
          gifUrls.clear();
        } catch (e) {
          sendEmbedMessageErrorHandler(e, event, bot);
        }
      }
    }
  });

  bot.eventsWs.onSelfMention.listen((event) async {
    try {
      await event.message.channel
          .sendMessage(MessageBuilder.content('Digite "<gif termo"'));
    } catch (e) {
      sendEmbedMessageErrorHandler(e, event, bot);
    }
  });

  bot.connect();
}
