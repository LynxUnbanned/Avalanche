/// Server location model with coordinates for world map display
class ServerLocation {
  const ServerLocation({
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });

  final String countryCode;
  final double latitude;
  final double longitude;
  final String displayName;

  /// Convert latitude/longitude to normalized coordinates (0-1 range)
  /// for use with world map widget
  ({double x, double y}) toMapPosition() {
    // Mercator projection approximation
    // Longitude: -180 to 180 -> 0 to 1
    final x = (longitude + 180) / 360;
    
    // Latitude: 90 to -90 -> 0 to 1 (inverted for screen coordinates)
    // Using Mercator projection for better visual distribution
    final latRad = latitude * 3.14159265359 / 180;
    final mercN = -0.5 * (1 - (latRad.sin()) / (1 + latRad.sin())).abs().log();
    final y = (1 - ((mercN / 3.14159265359) + 0.5)).clamp(0.0, 1.0);
    
    return (x: x, y: y);
  }
}

extension on double {
  double sin() => _sin(this);
  double log() => _log(this);
  double abs() => this < 0 ? -this : this;
}

double _sin(double x) {
  // Taylor series approximation for sin
  final x2 = x * x;
  return x * (1 - x2 / 6 * (1 - x2 / 20 * (1 - x2 / 42)));
}

double _log(double x) {
  if (x <= 0) return double.negativeInfinity;
  // Natural log approximation using Newton's method
  double result = 0;
  while (x > 2) {
    x /= 2.718281828;
    result++;
  }
  while (x < 0.5) {
    x *= 2.718281828;
    result--;
  }
  x -= 1;
  double term = x;
  double sum = x;
  for (int i = 2; i < 20; i++) {
    term *= -x;
    sum += term / i;
  }
  return result + sum;
}

/// Comprehensive mapping of country codes to their approximate center coordinates
const Map<String, ServerLocation> countryCoordinates = {
  // North America
  'US': ServerLocation(countryCode: 'US', latitude: 39.8283, longitude: -98.5795, displayName: 'United States'),
  'CA': ServerLocation(countryCode: 'CA', latitude: 56.1304, longitude: -106.3468, displayName: 'Canada'),
  'MX': ServerLocation(countryCode: 'MX', latitude: 23.6345, longitude: -102.5528, displayName: 'Mexico'),
  
  // Europe
  'GB': ServerLocation(countryCode: 'GB', latitude: 55.3781, longitude: -3.4360, displayName: 'United Kingdom'),
  'DE': ServerLocation(countryCode: 'DE', latitude: 51.1657, longitude: 10.4515, displayName: 'Germany'),
  'FR': ServerLocation(countryCode: 'FR', latitude: 46.2276, longitude: 2.2137, displayName: 'France'),
  'NL': ServerLocation(countryCode: 'NL', latitude: 52.1326, longitude: 5.2913, displayName: 'Netherlands'),
  'SE': ServerLocation(countryCode: 'SE', latitude: 60.1282, longitude: 18.6435, displayName: 'Sweden'),
  'NO': ServerLocation(countryCode: 'NO', latitude: 60.4720, longitude: 8.4689, displayName: 'Norway'),
  'FI': ServerLocation(countryCode: 'FI', latitude: 61.9241, longitude: 25.7482, displayName: 'Finland'),
  'DK': ServerLocation(countryCode: 'DK', latitude: 56.2639, longitude: 9.5018, displayName: 'Denmark'),
  'CH': ServerLocation(countryCode: 'CH', latitude: 46.8182, longitude: 8.2275, displayName: 'Switzerland'),
  'AT': ServerLocation(countryCode: 'AT', latitude: 47.5162, longitude: 14.5501, displayName: 'Austria'),
  'BE': ServerLocation(countryCode: 'BE', latitude: 50.5039, longitude: 4.4699, displayName: 'Belgium'),
  'IT': ServerLocation(countryCode: 'IT', latitude: 41.8719, longitude: 12.5674, displayName: 'Italy'),
  'ES': ServerLocation(countryCode: 'ES', latitude: 40.4637, longitude: -3.7492, displayName: 'Spain'),
  'PT': ServerLocation(countryCode: 'PT', latitude: 39.3999, longitude: -8.2245, displayName: 'Portugal'),
  'PL': ServerLocation(countryCode: 'PL', latitude: 51.9194, longitude: 19.1451, displayName: 'Poland'),
  'CZ': ServerLocation(countryCode: 'CZ', latitude: 49.8175, longitude: 15.4730, displayName: 'Czech Republic'),
  'RO': ServerLocation(countryCode: 'RO', latitude: 45.9432, longitude: 24.9668, displayName: 'Romania'),
  'UA': ServerLocation(countryCode: 'UA', latitude: 48.3794, longitude: 31.1656, displayName: 'Ukraine'),
  'GR': ServerLocation(countryCode: 'GR', latitude: 39.0742, longitude: 21.8243, displayName: 'Greece'),
  'IE': ServerLocation(countryCode: 'IE', latitude: 53.4129, longitude: -8.2439, displayName: 'Ireland'),
  'HU': ServerLocation(countryCode: 'HU', latitude: 47.1625, longitude: 19.5033, displayName: 'Hungary'),
  'BG': ServerLocation(countryCode: 'BG', latitude: 42.7339, longitude: 25.4858, displayName: 'Bulgaria'),
  'RS': ServerLocation(countryCode: 'RS', latitude: 44.0165, longitude: 21.0059, displayName: 'Serbia'),
  'HR': ServerLocation(countryCode: 'HR', latitude: 45.1000, longitude: 15.2000, displayName: 'Croatia'),
  'SK': ServerLocation(countryCode: 'SK', latitude: 48.6690, longitude: 19.6990, displayName: 'Slovakia'),
  'LU': ServerLocation(countryCode: 'LU', latitude: 49.8153, longitude: 6.1296, displayName: 'Luxembourg'),
  'IS': ServerLocation(countryCode: 'IS', latitude: 64.9631, longitude: -19.0208, displayName: 'Iceland'),
  'EE': ServerLocation(countryCode: 'EE', latitude: 58.5953, longitude: 25.0136, displayName: 'Estonia'),
  'LV': ServerLocation(countryCode: 'LV', latitude: 56.8796, longitude: 24.6032, displayName: 'Latvia'),
  'LT': ServerLocation(countryCode: 'LT', latitude: 55.1694, longitude: 23.8813, displayName: 'Lithuania'),
  'MD': ServerLocation(countryCode: 'MD', latitude: 47.4116, longitude: 28.3699, displayName: 'Moldova'),
  'SI': ServerLocation(countryCode: 'SI', latitude: 46.1512, longitude: 14.9955, displayName: 'Slovenia'),
  'AL': ServerLocation(countryCode: 'AL', latitude: 41.1533, longitude: 20.1683, displayName: 'Albania'),
  'MK': ServerLocation(countryCode: 'MK', latitude: 41.5124, longitude: 21.4473, displayName: 'North Macedonia'),
  
  // Asia
  'JP': ServerLocation(countryCode: 'JP', latitude: 36.2048, longitude: 138.2529, displayName: 'Japan'),
  'KR': ServerLocation(countryCode: 'KR', latitude: 35.9078, longitude: 127.7669, displayName: 'South Korea'),
  'CN': ServerLocation(countryCode: 'CN', latitude: 35.8617, longitude: 104.1954, displayName: 'China'),
  'HK': ServerLocation(countryCode: 'HK', latitude: 22.3193, longitude: 114.1694, displayName: 'Hong Kong'),
  'TW': ServerLocation(countryCode: 'TW', latitude: 23.6978, longitude: 120.9605, displayName: 'Taiwan'),
  'SG': ServerLocation(countryCode: 'SG', latitude: 1.3521, longitude: 103.8198, displayName: 'Singapore'),
  'MY': ServerLocation(countryCode: 'MY', latitude: 4.2105, longitude: 101.9758, displayName: 'Malaysia'),
  'TH': ServerLocation(countryCode: 'TH', latitude: 15.8700, longitude: 100.9925, displayName: 'Thailand'),
  'VN': ServerLocation(countryCode: 'VN', latitude: 14.0583, longitude: 108.2772, displayName: 'Vietnam'),
  'ID': ServerLocation(countryCode: 'ID', latitude: -0.7893, longitude: 113.9213, displayName: 'Indonesia'),
  'PH': ServerLocation(countryCode: 'PH', latitude: 12.8797, longitude: 121.7740, displayName: 'Philippines'),
  'IN': ServerLocation(countryCode: 'IN', latitude: 20.5937, longitude: 78.9629, displayName: 'India'),
  'PK': ServerLocation(countryCode: 'PK', latitude: 30.3753, longitude: 69.3451, displayName: 'Pakistan'),
  'BD': ServerLocation(countryCode: 'BD', latitude: 23.6850, longitude: 90.3563, displayName: 'Bangladesh'),
  'KZ': ServerLocation(countryCode: 'KZ', latitude: 48.0196, longitude: 66.9237, displayName: 'Kazakhstan'),
  'UZ': ServerLocation(countryCode: 'UZ', latitude: 41.3775, longitude: 64.5853, displayName: 'Uzbekistan'),
  
  // Middle East
  'AE': ServerLocation(countryCode: 'AE', latitude: 23.4241, longitude: 53.8478, displayName: 'UAE'),
  'SA': ServerLocation(countryCode: 'SA', latitude: 23.8859, longitude: 45.0792, displayName: 'Saudi Arabia'),
  'IL': ServerLocation(countryCode: 'IL', latitude: 31.0461, longitude: 34.8516, displayName: 'Israel'),
  'TR': ServerLocation(countryCode: 'TR', latitude: 38.9637, longitude: 35.2433, displayName: 'Turkey'),
  'IR': ServerLocation(countryCode: 'IR', latitude: 32.4279, longitude: 53.6880, displayName: 'Iran'),
  
  // Russia
  'RU': ServerLocation(countryCode: 'RU', latitude: 61.5240, longitude: 105.3188, displayName: 'Russia'),
  
  // Oceania
  'AU': ServerLocation(countryCode: 'AU', latitude: -25.2744, longitude: 133.7751, displayName: 'Australia'),
  'NZ': ServerLocation(countryCode: 'NZ', latitude: -40.9006, longitude: 174.8860, displayName: 'New Zealand'),
  
  // South America
  'BR': ServerLocation(countryCode: 'BR', latitude: -14.2350, longitude: -51.9253, displayName: 'Brazil'),
  'AR': ServerLocation(countryCode: 'AR', latitude: -38.4161, longitude: -63.6167, displayName: 'Argentina'),
  'CL': ServerLocation(countryCode: 'CL', latitude: -35.6751, longitude: -71.5430, displayName: 'Chile'),
  'CO': ServerLocation(countryCode: 'CO', latitude: 4.5709, longitude: -74.2973, displayName: 'Colombia'),
  'PE': ServerLocation(countryCode: 'PE', latitude: -9.1900, longitude: -75.0152, displayName: 'Peru'),
  
  // Africa
  'ZA': ServerLocation(countryCode: 'ZA', latitude: -30.5595, longitude: 22.9375, displayName: 'South Africa'),
  'EG': ServerLocation(countryCode: 'EG', latitude: 26.8206, longitude: 30.8025, displayName: 'Egypt'),
  'NG': ServerLocation(countryCode: 'NG', latitude: 9.0820, longitude: 8.6753, displayName: 'Nigeria'),
  'KE': ServerLocation(countryCode: 'KE', latitude: -0.0236, longitude: 37.9062, displayName: 'Kenya'),
  'MA': ServerLocation(countryCode: 'MA', latitude: 31.7917, longitude: -7.0926, displayName: 'Morocco'),
};

/// Get server location from country code
ServerLocation? getServerLocation(String? countryCode) {
  if (countryCode == null) return null;
  return countryCoordinates[countryCode.toUpperCase()];
}
