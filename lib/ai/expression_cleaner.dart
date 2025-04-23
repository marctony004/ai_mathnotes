class ExpressionCleaner {
  static String clean(String input) {
    // 🧹 Remove leading phrases like "solve", "what is", etc.
    final phrasesToRemove = [
      'solve', 'evaluate', 'find', 'compute', 'answer',
      'what is', 'calculate', 'result of',
    ];
    for (final phrase in phrasesToRemove) {
      input = input.replaceAll(RegExp(RegExp.escape(phrase), caseSensitive: false), '');
    }

    // 🧠 Fix OCR-specific issues and math formatting
    return input
        // Normalize x^2 from OCR misreads like "X ²", "Y₂", "X^2"
        .replaceAllMapped(RegExp(r'(X|x)\s*[\^]?\s*2'), (_) => 'x^2')
        .replaceAll('Y₂', 'x^2')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('⁴', '^4')

        // Normalize multiplication and division
        .replaceAll('×', '*')      // math cross
        .replaceAll('∗', '*')      // fancy asterisk
        .replaceAll('x', '*')      // x as multiplication (careful with context!)
        .replaceAll('X', '*')
        .replaceAll('÷', '/')

        // Normalize dashes and symbols
        .replaceAll('–', '-')      // en dash
        .replaceAll('—', '-')      // em dash
        .replaceAll('−', '-')      // minus sign
        .replaceAll('＝', '=')     // full-width equals

        // Normalize brackets
        .replaceAll('[', '(')
        .replaceAll(']', ')')
        .replaceAll('{', '(')
        .replaceAll('}', ')')

        // Remove punctuation noise
        .replaceAll(RegExp(r'[=:\?,]'), '')

        // Remove all whitespace
        .replaceAll(RegExp(r'\s+'), '')
        .trim();
  }
}
