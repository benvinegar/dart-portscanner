part of portscanner;

/// Scans the given ip (in CIDR notation) and port ranges, returning a future
/// with a list of found open ports at each address

Future scanIpAndPortRange(String ipCidr, List<List<int>> portRanges) {
  List ipRange = ipStringToIntegerRange(ipCidr);

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