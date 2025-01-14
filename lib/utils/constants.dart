class LegoConstants {
  // Service UUIDs (lowercase to match BLE standard)
  static const String legoHubService = "00001623-1212-efde-1623-785feabcd123";
  static const String characteristicUuid = "00001624-1212-efde-1623-785feabcd123";

  // Port definitions
  static const int portA = 0x00;
  static const int portB = 0x01;
  static const int portC = 0x02;
  static const int portD = 0x03;

  // Command types
  static const int motorCommand = 0x81;
  static const int powerCommand = 0x11;

  // Protocol constants
  static const int messageHeaderSize = 3;
  static const int checksumIndex = 7;

  // Message types
  static const motorOutputCommand = 0x81;
  static const motorStartPowerCommand = 0x11;
  static const motorStartSpeedCommand = 0x07;
  static const motorStartSpeedForDegreesCommand = 0x0B;
  static const motorStartSpeedForTimeCommand = 0x09;
  static const motorStopCommand = 0x51;

  // Battery status
  static const batteryStatusRequestType = 0x01;
  static const batteryLevelCommand = 0x06;
}