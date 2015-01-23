part of portscanner;

class Scanner {

  /// Scans the given ip (in CIDR notation) and port ranges, returning a future
  /// with a list of found open ports at each address
  
  Future scanIpAndPortRange(String ipCidr, List<List<int>> portRanges) {
    
    // Convert ip string to integer because easier to iterate
    // through ranges
    List ipRange = ipStringToIntegerRange(ipCidr);
    
    var ipIterable = new Iterable.generate(
     ipRange[1] - ipRange[0] + 1,
     (i) => i + ipRange[0]
    );
    
    Map foundPortsByIp = {};
    
    List<Future> scanFutures = ipIterable.map((int ip) {
      String ipString = ipv4IntegerToString(ip);
    
      return this.scanPortRange(ipString, portRanges).then((List foundPorts) {
        if (foundPorts.length > 0)
          foundPortsByIp[ipString] = foundPorts;
      });
    
    }).toList();
    
    Completer completer = new Completer();
    Future.wait(scanFutures).then((List results) {
      completer.complete(foundPortsByIp);
    });
    
    return completer.future;
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
      completer.complete(foundPorts);
    });
  
    return completer.future;
  }
}