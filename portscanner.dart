import 'dart:io';
import 'dart:async';
import 'dart:core';

import 'package:args/args.dart';

void main(List<String> args) {
  var parser = new ArgParser()
      ..addOption('port', abbr: 'p', defaultsTo: '0-65535');

  ArgResults result = parser.parse(args);

  String ipRangeArg = result.rest.isEmpty ?
      '0.0.0.0/32' :
      result.rest[0];

  List ipRange = getIpRangeFromArg(ipRangeArg);
  List portRanges = getPortRangesFromArg(result['port']);

  scanIpAndPortRange(ipRange, portRanges).then((List foundPortsByIp) {
    // Remove IPs where no ports were found
    //
    // NOTE: foundPortsByIp is "non-growable", so converting to a new list
    // before filtering. I'm sure there's a better way to do this.

    var filteredIps = foundPortsByIp.toList()
        ..removeWhere((List x) => x[1].length == 0);

    // Print out everything we found.
    // TODO: Format this so it doesn't look god-awful
    print(filteredIps);
  });
}

/// Takes an ip range argument string and converts it to a
/// tuple of integer values.
///
/// e.g. 128.0.0.0/8 => [2147483648, 4294967296]

List getIpRangeFromArg(String ipArg) {
  List split = ipArg.split('/');

  int ip = ipStringToInteger(split[0]);

  int mask = split.length > 1 ?
      int.parse(split[1]) :
      32; // if absent, assume fully masked

  return [ip, ip + (0xFFFFFFFF >> mask)];
}

/// Converts a string representation of an IPv4 IP address
/// to an integer

int ipStringToInteger(String ip) {
  var parts = ip.split('.').map((x) => int.parse(x)).toList();

  return
      parts[0] << 24 |
      parts[1] << 16 |
      parts[2] << 8 |
      parts[3];
}

/// Converts an integer represenation of an IPv4 IP address
/// to a string

String ipIntegerToString(int ip) {
  return [
    ip >> 24,
    (ip & 0x00FF0000) >> 16,
    (ip & 0x0000FF00) >> 8,
    (ip & 0x000000FF)
  ].map((int x) => x.toString()).join('.');
}

/// Takes a --port argument string, and converts it to a list
/// of port ranges of the form [to, from].

List getPortRangesFromArg(String portArg) {
  var rangeStrings = portArg.split(',');

  List rangeTuples = [];
  for (String range in rangeStrings) {
    var split = range.split('-').map((p) => int.parse(p)).toList();

    if (split.length > 1) {
      rangeTuples.add(split);
    } else {
      rangeTuples.add([split[0], split[0]]);
    }
  }
  return rangeTuples;
}

/// Scans the given ip and port ranges, returning a future with a list of found
/// open ports at each address

Future scanIpAndPortRange(List<int> ipRange, List<List<int>> portRanges) {
  var ipIterable = new Iterable.generate(
   ipRange[1] - ipRange[0] + 1,
   (i) => i + ipRange[0]
  );

  List<Future> scanFutures = ipIterable.map((int ip) {
    return scanPortRange(ipIntegerToString(ip), portRanges);
  }).toList();

  return Future.wait(scanFutures);
}

/// Scans every port at the given ip address, returning a future with a list
/// of found open ports

Future scanPortRange(String ip, List<List<int>> portRanges) {

  List<int> foundPorts = [];
  List<Future> connectionFutures = [];
  List<int> range;

  // NOTE: This may be spawning an untold # of connections. Uh, look into that.

  for (int rangeIndex = 0; rangeIndex < portRanges.length; rangeIndex++) {
    range = portRanges[rangeIndex];
    for (int port = range[0]; port <= range[1]; port++) {
      connectionFutures.add(Socket.connect(ip, port).then((socket) {
        foundPorts.add(socket.remotePort);
        socket.destroy();
      }).catchError((error) {
        // ignore errors
      }));
    }
  }

  Completer completer = new Completer();
  Future.wait(connectionFutures).then((allSockets) {
    completer.complete([ip, foundPorts]);
  });

  return completer.future;
}

