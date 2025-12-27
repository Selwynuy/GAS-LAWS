/// Unit conversion utilities for volume, pressure, and temperature.

enum VolumeUnit {
  liters('L'),
  milliliters('mL'),
  cubicMeters('m³'),
  cubicCentimeters('cm³');

  const VolumeUnit(this.symbol);
  final String symbol;
}

enum PressureUnit {
  atmosphere('atm'),
  kilopascal('kPa'),
  millimetersMercury('mmHg');

  const PressureUnit(this.symbol);
  final String symbol;
}

enum TemperatureUnit {
  celsius('°C'),
  fahrenheit('°F'),
  kelvin('K');

  const TemperatureUnit(this.symbol);
  final String symbol;
}

class UnitConverter {
  // Volume conversions (base unit: liters)
  static double convertVolume(double value, VolumeUnit from, VolumeUnit to) {
    if (from == to) return value;
    
    // Convert to liters first
    double inLiters = value;
    switch (from) {
      case VolumeUnit.liters:
        inLiters = value;
        break;
      case VolumeUnit.milliliters:
        inLiters = value / 1000.0;
        break;
      case VolumeUnit.cubicMeters:
        inLiters = value * 1000.0;
        break;
      case VolumeUnit.cubicCentimeters:
        inLiters = value / 1000.0;
        break;
    }
    
    // Convert from liters to target unit
    switch (to) {
      case VolumeUnit.liters:
        return inLiters;
      case VolumeUnit.milliliters:
        return inLiters * 1000.0;
      case VolumeUnit.cubicMeters:
        return inLiters / 1000.0;
      case VolumeUnit.cubicCentimeters:
        return inLiters * 1000.0;
    }
  }

  // Pressure conversions (base unit: atm)
  static double convertPressure(double value, PressureUnit from, PressureUnit to) {
    if (from == to) return value;
    
    // Convert to atm first
    double inAtm = value;
    switch (from) {
      case PressureUnit.atmosphere:
        inAtm = value;
        break;
      case PressureUnit.kilopascal:
        inAtm = value / 101.325;
        break;
      case PressureUnit.millimetersMercury:
        inAtm = value / 760.0;
        break;
    }
    
    // Convert from atm to target unit
    switch (to) {
      case PressureUnit.atmosphere:
        return inAtm;
      case PressureUnit.kilopascal:
        return inAtm * 101.325;
      case PressureUnit.millimetersMercury:
        return inAtm * 760.0;
    }
  }

  // Temperature conversions (base unit: Kelvin)
  static double convertTemperature(double value, TemperatureUnit from, TemperatureUnit to) {
    if (from == to) return value;
    
    // Convert to Kelvin first
    double inKelvin = value;
    switch (from) {
      case TemperatureUnit.kelvin:
        inKelvin = value;
        break;
      case TemperatureUnit.celsius:
        inKelvin = value + 273.15;
        break;
      case TemperatureUnit.fahrenheit:
        inKelvin = (value - 32.0) * 5.0 / 9.0 + 273.15;
        break;
    }
    
    // Convert from Kelvin to target unit
    switch (to) {
      case TemperatureUnit.kelvin:
        return inKelvin;
      case TemperatureUnit.celsius:
        return inKelvin - 273.15;
      case TemperatureUnit.fahrenheit:
        return (inKelvin - 273.15) * 9.0 / 5.0 + 32.0;
    }
  }
}
