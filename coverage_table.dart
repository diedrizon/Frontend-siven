import 'dart:io';

void main() async {
  final coverageFile = File('coverage/lcov.info');
  if (!await coverageFile.exists()) {
    print('El archivo coverage/lcov.info no existe. Ejecuta primero flutter test --coverage.');
    return;
  }

  final lines = await coverageFile.readAsLines();
  int totalLines = 0;
  int coveredLines = 0;
  final coverageData = <String, Map<String, int>>{};

  String? currentFile;
  for (var line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      // Filtrar solo el archivo EventoSaludService.dart
      if (!currentFile.endsWith('EventoSaludService.dart')) {
        currentFile = null;
      } else {
        coverageData[currentFile] = {'total': 0, 'covered': 0};
      }
    } else if (line.startsWith('DA:') && currentFile != null) {
      totalLines++;
      if (line.endsWith(',1')) {
        coveredLines++;
        coverageData[currentFile]!['covered'] = coverageData[currentFile]!['covered']! + 1;
      }
      coverageData[currentFile]!['total'] = coverageData[currentFile]!['total']! + 1;
    }
  }

  printCoverageTable(coverageData, totalLines, coveredLines);
}

void printCoverageTable(Map<String, Map<String, int>> coverageData, int totalLines, int coveredLines) {
  final coveragePercentage = (coveredLines / totalLines) * 100;
  print('Cobertura total: ${coveragePercentage.toStringAsFixed(2)}%\n');

  print('| Archivo                          | Líneas cubiertas | Total líneas | Cobertura (%) |');
  print('|----------------------------------|------------------|--------------|---------------|');
  
  coverageData.forEach((file, data) {
    final fileCoverage = (data['covered']! / data['total']!) * 100;
    final color = fileCoverage >= 75 ? '\x1B[32m' : fileCoverage >= 50 ? '\x1B[33m' : '\x1B[31m';
    print('| ${file.padRight(32)} | ${data['covered'].toString().padRight(16)} | ${data['total'].toString().padRight(12)} | ${color}${fileCoverage.toStringAsFixed(2)}%\x1B[0m |');
  });

  print('\nResumen total:');
  print('Líneas cubiertas: $coveredLines de $totalLines');
  print('Cobertura general: ${coveragePercentage.toStringAsFixed(2)}%');
}
