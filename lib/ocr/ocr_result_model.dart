enum OCRCategory {
  mathProblem,
  dueDate,
  syllabusText,
  mathDefinition,
  exampleSolution,
  unknown,
}

/// Represents a single line of text extracted by OCR,
/// categorized into a meaningful group.
class OCRLine {
  final String text;
  final OCRCategory category;

  /// Optional block ID used for grouping lines into logical clusters.
  final int blockId;

  OCRLine({
    required this.text,
    required this.category,
    this.blockId = -1, // Default to -1 if block grouping is unused
  });
}
