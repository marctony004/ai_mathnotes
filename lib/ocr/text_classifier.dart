import 'ocr_result_model.dart';




class TextClassifier {
  static OCRCategory classifyLine(String line) {
    final lower = line.toLowerCase().trim();

    // Enhanced priority check order
    
    if (_isDueDate(lower)) return OCRCategory.dueDate;
    if (_isMathProblem(lower)) return OCRCategory.mathProblem;
    if (_isMathDefinition(lower)) return OCRCategory.mathDefinition;
    if (_isExampleSolution(lower)) return OCRCategory.exampleSolution;

    return OCRCategory.syllabusText;
  }

  static bool _isMathProblem(String line) {
    if (line.contains('=') && line.contains(RegExp(r'[a-zA-Z]'))) {
  return true; // likely a solvable equation
}




    // Expanded math symbol coverage
    final mathSymbols = [
      '+', '-', '*', '/', '=', '^', '∫', '√', '∑', '≠', '≈', '≤', '≥',
      '→', '←', 'Δ', '∞', '|', 'x²', 'x^2'
    ];

    final mathKeywords = [
      'solve', 'factor', 'simplify', 'evaluate', 'find x', 'derivative', 'integral',
      'differentiate', 'roots', 'zeroes', 'intercepts', 'expand', 'reduce', 'graph',
      'domain', 'range', 'function', 'expression', 'identity', 'quadratic', 'polynomial',
      'inequality', 'limit', 'asymptote', 'hole', 'discontinuity', 'vertex', 'axis'
    ];

    final containsSymbols = mathSymbols.any((symbol) => line.contains(symbol));
    final containsKeywords = mathKeywords.any((kw) => line.contains(kw));
    final basicEquationPattern = RegExp(r'^[\d\sxX\^\*\+/=().-]+$');

    return containsSymbols || containsKeywords || basicEquationPattern.hasMatch(line);
  }

  static bool _isDueDate(String line) {
    final datePatterns = [
      RegExp(r'\b\d{1,2}/\d{1,2}/\d{2,4}\b'),       // e.g., 04/21/2025
      RegExp(r'\b\d{1,2}-\d{1,2}-\d{2,4}\b'),       // e.g., 04-21-2025
      RegExp(r'\b(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+\d{1,2}(st|nd|rd|th)?\b', caseSensitive: false),
      RegExp(r'\bdue\b|\bdeadline\b|\bsubmit\b|\bby\b', caseSensitive: false),
      RegExp(r'\bnext\s+(mon|tue|wed|thu|fri|sat|sun)', caseSensitive: false),
    ];

    return datePatterns.any((pattern) => pattern.hasMatch(line));
  }

  static bool _isMathDefinition(String line) {
    return RegExp(r'\bdefinition\b|\bmeans\b|\bis called\b|\bis defined as\b', caseSensitive: false).hasMatch(line);
  }

  static bool _isExampleSolution(String line) {
    return RegExp(r'\bexample\b|\bex\.?\b|\be\.g\.\b|\bfor instance\b|\btry\b', caseSensitive: false).hasMatch(line);
  }
}
