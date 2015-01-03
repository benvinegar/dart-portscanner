import 'package:unittest/unittest.dart';

import '../portscanner.dart';

void main() {
  test('getPortRangesFromArg', () {
    expect(getPortRangesFromArg('80'), [[80, 80]]);
    expect(getPortRangesFromArg('80-81'), [[80, 81]]);
    expect(getPortRangesFromArg('80,8000-8080'), [[80, 80], [8000, 8080]]);
    expect(getPortRangesFromArg('80,90,100'), [[80, 80], [90,90], [100,100]]);
  });

  test('ipStringToInteger', () {
    expect(ipStringToInteger('0.0.0.0'), 0);
    expect(ipStringToInteger('0.0.1.0'), 256);
    expect(ipStringToInteger('0.1.0.0'), 65536);
    expect(ipStringToInteger('1.0.0.0'), 16777216);
    expect(ipStringToInteger('255.0.0.1'), 4278190081);
    expect(ipStringToInteger('192.168.0.1'), 3232235521);
  });

  test('ipIntegerToString', () {
    expect(ipIntegerToString(0), '0.0.0.0');
    expect(ipIntegerToString(256), '0.0.1.0');
    expect(ipIntegerToString(65536), '0.1.0.0');
    expect(ipIntegerToString(16777216), '1.0.0.0');
    expect(ipIntegerToString(4278190081), '255.0.0.1');
    expect(ipIntegerToString(3232235521), '192.168.0.1');
  });

  test('getIpRangeFromArg', () {
    expect(getIpRangeFromArg('0.0.0.0/32'), [0,0]);
    expect(getIpRangeFromArg('0.0.0.0/24'), [0,255]);
    expect(getIpRangeFromArg('0.0.0.0/16'), [0,65535]);
    expect(getIpRangeFromArg('0.0.0.0/8'), [0,16777215]);
    expect(getIpRangeFromArg('0.0.0.0/0'), [0,4294967295]);

    expect(getIpRangeFromArg('10.0.0.0/24'), [167772160,167772415]);
    expect(getIpRangeFromArg('192.168.0.0/16'), [3232235520,3232301055]);
  });
}