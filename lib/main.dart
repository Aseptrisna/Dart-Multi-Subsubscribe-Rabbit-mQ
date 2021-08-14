import 'dart:io';
import 'package:dart_amqp/dart_amqp.dart';

void main(List<String> args) async {
  var host = '';
  var username = '';
  var password = '';
  var virtualHost = '';
  var routingKeys = ['app_type.company.role'];

  var client = Client(
      settings: ConnectionSettings(
          host: host,
          authProvider: PlainAuthenticator(username, password),
          virtualHost: virtualHost));

  // Setup a signal handler to cleanly exit if CTRL+C is pressed
  ProcessSignal.sigint.watch().listen((_) async {
    await client.close();
    exit(0);
  });

  var channel = await client.channel();
  var exchange =
      await channel.exchange('amq.topic', ExchangeType.TOPIC, durable: true);
  var consumer = await exchange.bindPrivateQueueConsumer(routingKeys);
  print(
      " [*] Waiting for [${routingKeys.join(', ')}] logs on private queue ${consumer.queue.name}. To exit, press CTRL+C");
  consumer.listen((message) {
    print(
        ' [x] [Exchange: ${message.exchangeName}] [${message.routingKey}] ${message.payloadAsString}');
  });
}
