import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

/// =============================
/// Native Type Definitions
/// =============================

/// Session_Handle GW2OpenSession(void);
typedef _GW2OpenSessionNative = Pointer<Void> Function();
typedef _GW2OpenSessionDart = Pointer<Void> Function();

/// int GW2CloseSession(Session_Handle session);
typedef _GW2CloseSessionNative = Int32 Function(Pointer<Void>);
typedef _GW2CloseSessionDart = int Function(Pointer<Void>);

///int GW2DetermineFileTypeFromFile(const char *path);
typedef _GW2DetermineFileTypeFromFileNative = Int32 Function(Pointer<Utf8>);
typedef _GW2DetermineFileTypeFromFileDart = int Function(Pointer<Utf8>);

/// int GW2RegisterLicenceFile(Session_Handle session, const char *filename);
typedef _GW2RegisterLicenceFileNative = Int32 Function(
  Pointer<Void>,
  Pointer<Utf8>,
);
typedef _GW2RegisterLicenceFileDart = int Function(
  Pointer<Void>,
  Pointer<Utf8>,
);

/// int GW2RegisterInputFile(Session_Handle session, const char *inputFilePath);
typedef _GW2RegisterInputFileNative = Int32 Function(
  Pointer<Void>,
  Pointer<Utf8>,
);
typedef _GW2RegisterInputFileDart = int Function(
  Pointer<Void>,
  Pointer<Utf8>,
);

/// int GW2RegisterOutFile(Session_Handle session, const char *outputFilePath);
typedef _GW2RegisterOutFileNative = Int32 Function(
  Pointer<Void>,
  Pointer<Utf8>,
);
typedef _GW2RegisterOutFileDart = int Function(
  Pointer<Void>,
  Pointer<Utf8>,
);

/// int GW2RegisterAnalysisFile(Session_Handle session, const char *analysisFilePathName, Analysis_Format format);
typedef _GW2RegisterAnalysisFileNative = Int32 Function(
  Pointer<Void>,
  Pointer<Utf8>,
  Int32,
);
typedef _GW2RegisterAnalysisFileDart = int Function(
  Pointer<Void>,
  Pointer<Utf8>,
  int,
);

/// int GW2RunSession(Session_Handle session);
typedef _GW2RunSessionNative = Int32 Function(Pointer<Void>);
typedef _GW2RunSessionDart = int Function(Pointer<Void>);

/// const char* GW2RetStatusErrorMsg(int retStatus);
typedef _GW2RetStatusErrorMsgNative = Pointer<Utf8> Function(Int32);
typedef _GW2RetStatusErrorMsgDart = Pointer<Utf8> Function(int);

/// int GW2FileErrorMsg(Session_Handle session,
///                     char **errorMsgBuffer,
///                     size_t *errorMsgBufferLength);
typedef _GW2FileErrorMsgNative = Int32 Function(
  Pointer<Void>,
  Pointer<Pointer<Utf8>>,
  Pointer<Uint64>, // size_t on Windows x64
);
typedef _GW2FileErrorMsgDart = int Function(
  Pointer<Void>,
  Pointer<Pointer<Utf8>>,
  Pointer<Uint64>,
);

/// =============================
/// Glasswall Wrapper
/// =============================

class Glasswall {
  late final DynamicLibrary _lib;

  late final _GW2OpenSessionDart _openSession;
  late final _GW2CloseSessionDart _closeSession;
  late final _GW2DetermineFileTypeFromFileDart _determineFileTypeFromFile;
  late final _GW2RegisterLicenceFileDart _registerLicenceFile;
  late final _GW2RegisterInputFileDart _registerInputFile;
  late final _GW2RegisterOutFileDart _registerOutFile;
  late final _GW2RegisterAnalysisFileDart _registerAnalysisFile;
  late final _GW2RunSessionDart _runSession;
  late final _GW2RetStatusErrorMsgDart _retStatusErrorMsg;
  late final _GW2FileErrorMsgDart _fileErrorMsg;

  Glasswall({required String dllPath}) {
    _lib = DynamicLibrary.open(dllPath);

    _determineFileTypeFromFile = _lib
        .lookup<NativeFunction<_GW2DetermineFileTypeFromFileNative>>(
            'GW2DetermineFileTypeFromFile')
        .asFunction();

    _openSession = _lib
        .lookup<NativeFunction<_GW2OpenSessionNative>>('GW2OpenSession')
        .asFunction();

    _closeSession = _lib
        .lookup<NativeFunction<_GW2CloseSessionNative>>('GW2CloseSession')
        .asFunction();

    _registerLicenceFile = _lib
        .lookup<NativeFunction<_GW2RegisterLicenceFileNative>>(
            'GW2RegisterLicenceFile')
        .asFunction();

    _registerInputFile = _lib
        .lookup<NativeFunction<_GW2RegisterInputFileNative>>(
            'GW2RegisterInputFile')
        .asFunction();

    _registerOutFile = _lib
        .lookup<NativeFunction<_GW2RegisterOutFileNative>>(
            'GW2RegisterOutFile')
        .asFunction();

      _registerAnalysisFile = _lib
        .lookup<NativeFunction<_GW2RegisterAnalysisFileNative>>(
            'GW2RegisterAnalysisFile')
        .asFunction();

    _runSession = _lib
        .lookup<NativeFunction<_GW2RunSessionNative>>('GW2RunSession')
        .asFunction();

    _retStatusErrorMsg = _lib
    .lookup<NativeFunction<_GW2RetStatusErrorMsgNative>>(
        'GW2RetStatusErrorMsg')
    .asFunction();

    _fileErrorMsg = _lib
        .lookup<NativeFunction<_GW2FileErrorMsgNative>>(
            'GW2FileErrorMsg')
        .asFunction();
  }


  /// High-level Protect Mode wrapper
  void protectFile({
    required String licencePath,
    required String inputPath,
    required String outputPath,
  }) {
    final session = _openSession();
    print('Session opened: $session');
    if (session == nullptr) {
      throw Exception('GW2OpenSession failed: returned NULL');
    }

    try {
      final licencePtr = licencePath.toNativeUtf8();
      final inputPtr = inputPath.toNativeUtf8();
      final outputPtr = outputPath.toNativeUtf8();

      try {
        _check(
          _registerLicenceFile(session, licencePtr),
          'GW2RegisterLicenceFile', null
        );

        _check(
          _registerInputFile(session, inputPtr),
          'GW2RegisterInputFile', null
        );

        _check(
          _registerOutFile(session, outputPtr),
          'GW2RegisterOutFile', null
        );

        _check(
          _runSession(session),
          'GW2RunSession', session
        );
      } finally {
        calloc.free(licencePtr);
        calloc.free(inputPtr);
        calloc.free(outputPtr);
      }
    } finally {
      _check(
        _closeSession(session),
        'GW2CloseSession', session
      );
    }
  }

  void _check(int result, String functionName, Pointer<Void>? session) {
    print('Result of $functionName: $result');

    if (result < 0) {
      String sdkMessage = '';
      String sessionMessage = '';

      try {
        // Global SDK error message
        final msgPtr = _retStatusErrorMsg(result);
        if (msgPtr != nullptr) {
          sdkMessage = msgPtr.toDartString();
        }
      } catch (_) {}

      try {
        // Session-specific error message
        if (session != null && session != nullptr) {
          final errorBufferPtr = calloc<Pointer<Utf8>>();
          final lengthPtr = calloc<Uint64>();

          final errResult =
              _fileErrorMsg(session, errorBufferPtr, lengthPtr);

          if (errResult == 0 && errorBufferPtr.value != nullptr) {
            sessionMessage =
                errorBufferPtr.value.toDartString();
          }

          calloc.free(errorBufferPtr);
          calloc.free(lengthPtr);
        }
      } catch (_) {}

      throw Exception(
        '''
  Glasswall error in $functionName
  Return code: $result
  SDK message: $sdkMessage
  Session message: $sessionMessage
  ''',
      );
    }
  }

}
