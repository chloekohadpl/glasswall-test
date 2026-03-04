class GlasswallFileTypes {
  /// Mapping of numeric enum value to human-readable name
  static const Map<int, String> names = {
    // PDF
    0x10: 'PDF',

    // Microsoft Office / Office-like
    0x11: 'DOC',
    0x12: 'DOCX',
    0x13: 'PPT',
    0x14: 'PPTX',
    0x15: 'XLS',
    0x16: 'XLSX',
    0x1c: 'RTF',
    0x29: 'VBAMacros',

    // Images
    0x17: 'PNG',
    0x18: 'JPEG',
    0x19: 'GIF',
    0x1d: 'BMP',
    0x1e: 'TIFF',
    0x2a: 'SVG',
    0x2b: 'WEBP',
    0x1a: 'EMF',
    0x1b: 'WMF',

    // Media / Audio / Video
    0x22: 'MP4',
    0x23: 'MP3',
    0x24: 'MP2',
    0x25: 'WAV',
    0x26: 'MPG',

    // Text / Code / structured text
    0x28: 'JSON',
    0x2d: 'UTF8',
    0x2e: 'ASCII',

    // Archives
    0x100: 'ZIP',
    0x101: 'GZIP',
    0x102: 'BZIP2',
    0x103: '7ZIP',
    0x104: 'RAR',
    0x105: 'TAR',
    0x106: 'XZ',
  };
  static String getName(int type) => names[type] ?? GlasswallError.getMessage(type);
}

class GlasswallError {
  static const Map<int, String> messages = {
    0x00: 'Unknown file type',
    0x01: 'File issues detected',
    0x02: 'Buffer issues detected',
    0x03: 'Internal issues',
    0x04: 'License expired',
    0x05: 'Password protected OPC file',
    0x06: 'Null pointer argument',
    0x07: 'Unsupported file type',
    0x08: 'File too large',
    0x0F: 'End of file type errors',
  };
  static String getMessage(int code) => messages[code] ?? 'Unknown error code';
}