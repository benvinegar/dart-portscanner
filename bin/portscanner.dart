import 'package:args/args.dart';
import '../lib/portscanner.dart';

void main(List<String> args) {
  var parser = new ArgParser()
      ..addOption('port', abbr: 'p', defaultsTo: '0-65535');

  ArgResults result = parser.parse(args);

  String ipRangeArg = result.rest.isEmpty ?
      '0.0.0.0/32' :
      result.rest[0];

  List portRanges = getPortRangesFromArg(result['port']);

  Scanner scanner = new Scanner();
  scanner.scanIpAndPortRange(ipRangeArg, portRanges).then((Map foundPortsByIp) {
    // Print out everything we found.
    // TODO: Format this so it doesn't look god-awful
    print(foundPortsByIp);
  });
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
