import 'package:unittest/unittest.dart';

// Probably terrible form importing from /bin?
import '../lib/portscanner.dart';
import '../bin/portscanner.dart';

import 'dart:io';

void main() {
  group('lib', () {
    test('ipStringToInteger', () {
      expect(internetAddressToInteger(new InternetAddress('0.0.0.0')), 0);
      expect(internetAddressToInteger(new InternetAddress('0.0.1.0')), 256);
      expect(internetAddressToInteger(new InternetAddress('0.1.0.0')), 65536);
      expect(internetAddressToInteger(new InternetAddress('1.0.0.0')), 16777216);
      expect(internetAddressToInteger(new InternetAddress('255.0.0.1')), 4278190081);
      expect(internetAddressToInteger(new InternetAddress('192.168.0.1')), 3232235521);

      expect(internetAddressToInteger(new InternetAddress('::0')), 0); // 0.0.0.0
      expect(internetAddressToInteger(new InternetAddress('::1')), 1); // 0.0.0.1
      expect(internetAddressToInteger(new InternetAddress('::ff')), 255); // 0.0.0.255
      expect(internetAddressToInteger(new InternetAddress('::c0a8:1')), 3232235521); // 192.168.0.1

      expect(internetAddressToInteger(new InternetAddress('fe80::2000:aff:fea7:f7c')), 338288524927261089656324751945166688124);
      expect(internetAddressToInteger(new InternetAddress('2001:db8:85a3::8a2e:370:7334')), 42540766452641154071740215577757643572);
    });

    test('ipv4IntegerToString', () {
      expect(ipv4IntegerToString(0), '0.0.0.0');
      expect(ipv4IntegerToString(256), '0.0.1.0');
      expect(ipv4IntegerToString(65536), '0.1.0.0');
      expect(ipv4IntegerToString(16777216), '1.0.0.0');
      expect(ipv4IntegerToString(4278190081), '255.0.0.1');
      expect(ipv4IntegerToString(3232235521), '192.168.0.1');
    });

    test('ipv6IntegerToString', () {
      expect(ipv6IntegerToString(0), '::0');
      expect(ipv6IntegerToString(1), '::1');
      expect(ipv6IntegerToString(255), '::ff');

      expect(ipv6IntegerToString(338288524927261089656324751945166688124), 'fe80::2000:aff:fea7:f7c');
      expect(ipv6IntegerToString(42540766452641154071740215577757643572), '2001:db8:85a3::8a2e:370:7334');
    });

    test('getIpRangeFromArg', () {
      expect(ipStringToIntegerRange('0.0.0.0/32'), [0,0]);
      expect(ipStringToIntegerRange('0.0.0.0/24'), [0,255]);
      expect(ipStringToIntegerRange('0.0.0.0/16'), [0,65535]);
      expect(ipStringToIntegerRange('0.0.0.0/8'), [0,16777215]);
      expect(ipStringToIntegerRange('0.0.0.0/0'), [0,4294967295]);

      expect(ipStringToIntegerRange('10.0.0.0/24'), [167772160,167772415]);
      expect(ipStringToIntegerRange('192.168.0.0/16'), [3232235520,3232301055]);

      expect(ipStringToIntegerRange('::0/128'), [0,0]);
      expect(ipStringToIntegerRange('::0/120'), [0,255]);
      expect(ipStringToIntegerRange('::0/96'), [0,4294967295]);
      expect(ipStringToIntegerRange('::0/48'), [0,1208925819614629174706175]);

      expect(ipStringToIntegerRange('::a00:0/120'), [167772160,167772415]);
      expect(ipStringToIntegerRange('::c0a8:0/112'), [3232235520,3232301055]);
    });
  });

  group('bin', () {
    test('getPortRangesFromArg', () {
      expect(getPortRangesFromArg('80'), [[80, 80]]);
      expect(getPortRangesFromArg('80-81'), [[80, 81]]);
      expect(getPortRangesFromArg('80,8000-8080'), [[80, 80], [8000, 8080]]);
      expect(getPortRangesFromArg('80,90,100'), [[80, 80], [90,90], [100,100]]);
    });
  });
}