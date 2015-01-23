# dart-portscanner

This is a port scanner written in Dart; it scans a given list of IP and port ranges for open sockets, and reports back.

## Usage (command line)

Scan a single IP:

```bash
dart bin/portscanner.dart -p80,8000-8080 127.0.0.1
```

This will scan 127.0.0.1 for open ports on port 80, and 8000 through 8080.

Scan an IP range (using [CIDR notation](http://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation)):

```bash
dart bin/portscanner.dart -p22 10.0.0.0/24
```

This will scan IPs from 10.0.0.0 through 10.0.0.255 for an open port 22 (SSH).

Scan an IPv6 address:

```bash
dart bin/portscanner.dart -p3306,5432 ::4a7d:ef80
```

## Usage (as Dart package)

```dart
import 'package:portscanner/portscanner.dart';

// Scan a single IP
var scanner = new Scanner();
scanner.scanPortRange('127.0.0.1', [[0,200]]).then((result) {
  print(result); // => [22, 111]
});

// Scan an IP range (using CIDR notation)
scanner.scanIpAndPortRange('10.0.1.0/28', [[22,22]]).then((result) {
  // Only IPs with found ports are returned
  print(result); // => {10.0.1.3: [22], 10.0.1.8: [22]}
});
```

See [API Documentation on pub.dartlang.org](http://www.dartdocs.org/documentation/portscanner/0.0.1/index.html#portscanner/portscanner) for more.

## FAQ

**Uh, why Dart?**

I wrote this utility as an exercise to help learn Dart and the Dart ecosystem (unit testing, pub, etc). The code I've written is probably terrible.

**Should I actually use this?**

As a Dart library to help find local open ports? Maybe.

For anything else? No. This is because dart:io's `Socket.connect` doesn't accept a timeout argument, falling back to a 2 minute default. This means that any host/port combination that fails to return a response will hold a socket open for 2 minutes, making any non-trivial scan useless. There is an open issue (#[1920](https://code.google.com/p/dart/issues/detail?id=19120)) on the Dart issue tracker.

Try [masscan](https://github.com/robertdavidgraham/masscan) instead.