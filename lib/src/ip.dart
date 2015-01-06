part of portscanner;

/// Takes an ip range string in CIDR notation and converts
/// it to a tuple of integer values of the format [from, to].
///
/// e.g. 128.0.0.0/8 => [2147483648, 4294967296]

List ipStringToIntegerRange(String ipCidr) {
  List split = ipCidr.split('/');

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
