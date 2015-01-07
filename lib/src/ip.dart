part of portscanner;

/// Takes an ip range string in CIDR notation and converts
/// it to a tuple of integer values of the format [from, to].
///
/// e.g. 128.0.0.0/8 => [2147483648, 4294967296]

List ipStringToIntegerRange(String ipCidr) {
  List parts = ipCidr.split('/');

  InternetAddress addr = new InternetAddress(parts[0]);
  int ip = internetAddressToInteger(addr);

  int defaultMask, maxInt;

  switch(addr.type.name) {
    case 'IP_V4':
      defaultMask = 32;
      maxInt = 0xFFFFFFFF;
      break;
    case 'IP_V6':
      defaultMask = 128;
      maxInt = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      break;
  }

  int mask = parts.length > 1 ?
      int.parse(parts[1]) : defaultMask;

  return [ip, ip + (maxInt >> mask)];
}

/// Converts a string representation of an IP address (either IPv4 or
/// IPv6) to an integer

int internetAddressToInteger(InternetAddress addr) {

  var shift = 0;
  return addr.rawAddress.reversed.reduce((prev, elem) {
    shift += 8;
    return prev |= elem << shift;
  });
}

/// Converts an integer representation of an IPv4 IP address
/// to a string

String ipv4IntegerToString(int ip) {
  // 4 sets of 8-bit integer values
  return [
    ip >> 24,
    (ip & 0x00FF0000) >> 16,
    (ip & 0x0000FF00) >> 8,
    (ip & 0x000000FF)
  ].map((int x) => x.toString()).join('.');
}

/// Converts an integer representation of an IPv6 IP address
/// to a string

String ipv6IntegerToString(int ip) {
  List parts = [];

  // 8 sets of 16-bit hex values
  for (int i = 0; i < 8; i++) {
    parts.add((ip & 0xFFFF).toRadixString(16));
    ip >>= 16;
  }

  String ipStr = parts.reversed.join(':');

  // Convert 0s to double-colon shorthand (::)
  ipStr = ipStr.replaceAll(new RegExp(r'(^|:)(0:)+'), '::');

  return ipStr;
}