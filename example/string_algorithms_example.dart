import 'package:algomate/algomate.dart';

/// Example demonstrating String algorithms in AlgoMate
///
/// This example shows how to use various string algorithms for text processing
void main() {
  print('🔤 AlgoMate String Algorithms Demo');
  print('====================================\n');

  demonstrateKMP();
  demonstrateRabinKarp();
  demonstrateZAlgorithm();
  demonstrateLongestPalindrome();
  demonstrateManacher();
  demonstrateSuffixArray();
  demonstrateTrie();
  demonstrateAhoCorasick();
  demonstrateStringCompression();

  print('\n✅ All String algorithms demonstrations completed!');
}

/// Demonstrate Knuth-Morris-Pratt Algorithm
void demonstrateKMP() {
  print('🔍 Knuth-Morris-Pratt (KMP) Pattern Matching');
  print('---------------------------------------------');

  const text = 'ABABDABACDABABCABCABCABCABC';
  const pattern = 'ABABCAB';

  print('Text: "$text"');
  print('Pattern: "$pattern"');

  final kmpAlgorithm = KnuthMorrisPrattAlgorithm();
  const input = KMPInput(text, pattern);

  if (kmpAlgorithm.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = kmpAlgorithm.execute(input);
    stopwatch.stop();

    print('✓ Pattern found: ${result.found}');
    print('✓ Occurrences: ${result.occurrences}');
    print('✓ Count: ${result.count}');
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${kmpAlgorithm.meta.description}');

    // Show each occurrence
    for (final pos in result.occurrences) {
      final highlighted =
          '${text.substring(0, pos)}[${text.substring(pos, pos + pattern.length)}]${text.substring(pos + pattern.length)}';
      print('  - At position $pos: "$highlighted"');
    }
    print('');
  }
}

/// Demonstrate Rabin-Karp Algorithm
void demonstrateRabinKarp() {
  print('🎲 Rabin-Karp Rolling Hash Algorithm');
  print('-------------------------------------');

  const text = 'GEEKS FOR GEEKS';
  const pattern = 'GEEKS';

  print('Text: "$text"');
  print('Pattern: "$pattern"');

  final rabinKarpAlgorithm = RabinKarpAlgorithm();
  const input = RabinKarpInput(text, pattern);

  if (rabinKarpAlgorithm.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = rabinKarpAlgorithm.execute(input);
    stopwatch.stop();

    print('✓ Pattern found: ${result.found}');
    print('✓ Occurrences: ${result.occurrences}');
    print('✓ Hash collisions: ${result.hashCollisions}');
    print('✓ Count: ${result.count}');
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${rabinKarpAlgorithm.meta.description}');
    print('');
  }
}

/// Demonstrate Z-Algorithm
void demonstrateZAlgorithm() {
  print('⚡ Z-Algorithm for String Analysis');
  print('----------------------------------');

  const text = 'AABAACAADAABAABA';

  print('Text: "$text"');

  final zAlgorithm = ZAlgorithm();
  const input = ZAlgorithmInput(text);

  if (zAlgorithm.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = zAlgorithm.execute(input);
    stopwatch.stop();

    print('✓ Z-Array: ${result.zArray}');
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${zAlgorithm.meta.description}');

    // Use Z-algorithm to find pattern
    const pattern = 'AABA';
    final occurrences = result.findPattern(pattern);
    print('✓ Pattern "$pattern" found at: $occurrences');
    print('');
  }
}

/// Demonstrate Longest Palindromic Substring
void demonstrateLongestPalindrome() {
  print('🔄 Longest Palindromic Substring');
  print('---------------------------------');

  const text = 'BABAD';

  print('Text: "$text"');

  final palindromeAlgorithm = LongestPalindromicSubstringAlgorithm();
  const input = LongestPalindromicSubstringInput(text);

  if (palindromeAlgorithm.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = palindromeAlgorithm.execute(input);
    stopwatch.stop();

    print('✓ Longest palindrome: "${result.palindrome}"');
    print('✓ Start index: ${result.startIndex}');
    print('✓ Length: ${result.length}');
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${palindromeAlgorithm.meta.description}');
    print('');
  }
}

/// Demonstrate Manacher's Algorithm
void demonstrateManacher() {
  print('🚀 Manacher\'s Algorithm (Linear Palindromes)');
  print('----------------------------------------------');

  const text = 'ABACABAD';

  print('Text: "$text"');

  final manacherAlgorithm = ManacherAlgorithm();
  const input = ManacherInput(text);

  if (manacherAlgorithm.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = manacherAlgorithm.execute(input);
    stopwatch.stop();

    print('✓ Longest palindrome: "${result.longestPalindrome}"');
    print('✓ Start index: ${result.startIndex}');
    print('✓ Length: ${result.length}');
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${manacherAlgorithm.meta.description}');

    // Show all palindromes
    final allPalindromes = result.getAllPalindromes(text);
    print('✓ All palindromes (by length):');
    for (final palindrome in allPalindromes.take(5)) {
      print('  - "$palindrome" (${palindrome.length} chars)');
    }
    print('');
  }
}

/// Demonstrate Suffix Array
void demonstrateSuffixArray() {
  print('📚 Suffix Array Construction');
  print('-----------------------------');

  const text = 'BANANA';

  print('Text: "$text"');

  final suffixArrayAlgorithm = SuffixArrayAlgorithm();
  const input = SuffixArrayInput(text);

  if (suffixArrayAlgorithm.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = suffixArrayAlgorithm.execute(input);
    stopwatch.stop();

    print('✓ Suffix array: ${result.suffixArray}');
    print('✓ LCP array: ${result.lcp}');
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${suffixArrayAlgorithm.meta.description}');

    print('✓ Suffixes in sorted order:');
    for (int i = 0; i < result.suffixArray.length; i++) {
      final suffix = result.getSuffix(i);
      print('  $i: "$suffix" (starts at ${result.suffixArray[i]})');
    }

    // Use suffix array to search
    const pattern = 'ANA';
    final occurrences = result.findPattern(pattern);
    print('✓ Pattern "$pattern" found at: $occurrences');
    print('');
  }
}

/// Demonstrate Trie (Prefix Tree)
void demonstrateTrie() {
  print('🌳 Trie (Prefix Tree) Construction');
  print('------------------------------------');

  final words = [
    'THE',
    'THESE',
    'THEIR',
    'ANSWER',
    'ANY',
    'BY',
    'BYE',
    'THEIR',
  ];

  print('Words: $words');

  final trieAlgorithm = TrieAlgorithm();
  final input = TrieInput(words);

  if (trieAlgorithm.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = trieAlgorithm.execute(input);
    stopwatch.stop();

    print('✓ Trie constructed with ${result.words.length} words');
    print('✓ Root has ${result.root.children.length} child branches');
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${trieAlgorithm.meta.description}');

    // Test searches
    final testWords = ['THE', 'THESE', 'THEM', 'ANSWER', 'ANS'];
    print('✓ Search results:');
    for (final word in testWords) {
      final found = result.search(word);
      print('  - "$word": ${found ? "FOUND" : "NOT FOUND"}');
    }

    // Test prefix search
    final prefixes = ['THE', 'AN', 'BY'];
    print('✓ Prefix search results:');
    for (final prefix in prefixes) {
      final words = result.getWordsWithPrefix(prefix);
      print('  - Words with prefix "$prefix": $words');
    }
    print('');
  }
}

/// Demonstrate Aho-Corasick Algorithm
void demonstrateAhoCorasick() {
  print('🎯 Aho-Corasick Multiple Pattern Matching');
  print('------------------------------------------');

  const text = 'USHERS LIVE IN BUSHES BY THE SHORE';
  final patterns = ['HE', 'SHE', 'HIS', 'HERS', 'SHORE'];

  print('Text: "$text"');
  print('Patterns: $patterns');

  final ahoCorasickAlgorithm = AhoCorasickAlgorithm();
  final input = AhoCorasickInput(text, patterns);

  if (ahoCorasickAlgorithm.canApply(input, const SelectorHint())) {
    final stopwatch = Stopwatch()..start();
    final result = ahoCorasickAlgorithm.execute(input);
    stopwatch.stop();

    print('✓ Total matches: ${result.totalMatches}');
    print('✓ Found patterns: ${result.foundPatterns.length}');
    print('✓ Time: ${stopwatch.elapsedMicroseconds}μs');
    print('✓ Algorithm: ${ahoCorasickAlgorithm.meta.description}');

    print('✓ Pattern occurrences:');
    for (final entry in result.patternOccurrences.entries) {
      if (entry.value.isNotEmpty) {
        print('  - "${entry.key}": found at positions ${entry.value}');
      }
    }
    print('');
  }
}

/// Demonstrate String Compression
void demonstrateStringCompression() {
  print('🗜️  String Compression Algorithms');
  print('----------------------------------');

  final testStrings = [
    'AAAABBBBCCCCDDDD',
    'ABCDEFGHIJKLMNOP',
    'AABCAABCABC',
  ];

  final compressionAlgorithm = StringCompressionAlgorithm();

  for (final text in testStrings) {
    print('\\nText: "$text" (${text.length} chars)');

    // Run Length Encoding
    final rleInput =
        StringCompressionInput(text, type: CompressionType.runLength);
    if (compressionAlgorithm.canApply(rleInput, const SelectorHint())) {
      final stopwatch = Stopwatch()..start();
      final rleResult = compressionAlgorithm.execute(rleInput);
      stopwatch.stop();

      print('  📦 Run Length Encoding:');
      print('     Compressed: "${rleResult.compressedText}"');
      print(
          '     Ratio: ${(rleResult.compressionRatio * 100).toStringAsFixed(1)}%',);
      print(
          '     Space savings: ${rleResult.spaceSavings.toStringAsFixed(1)}%',);
      print('     Time: ${stopwatch.elapsedMicroseconds}μs');
    }

    // LZ77 Compression
    final lz77Input = StringCompressionInput(text, type: CompressionType.lz77);
    if (compressionAlgorithm.canApply(lz77Input, const SelectorHint())) {
      final stopwatch = Stopwatch()..start();
      final lz77Result = compressionAlgorithm.execute(lz77Input);
      stopwatch.stop();

      print('  🔧 LZ77 Compression:');
      print('     Tokens: ${lz77Result.metadata?['tokens'] ?? 'N/A'}');
      print(
          '     Ratio: ${(lz77Result.compressionRatio * 100).toStringAsFixed(1)}%',);
      print(
          '     Space savings: ${lz77Result.spaceSavings.toStringAsFixed(1)}%',);
      print('     Time: ${stopwatch.elapsedMicroseconds}μs');
    }

    // Huffman Compression (estimated)
    final huffmanInput =
        StringCompressionInput(text, type: CompressionType.huffman);
    if (compressionAlgorithm.canApply(huffmanInput, const SelectorHint())) {
      final stopwatch = Stopwatch()..start();
      final huffmanResult = compressionAlgorithm.execute(huffmanInput);
      stopwatch.stop();

      print('  🌳 Huffman Compression (estimated):');
      print(
          '     Entropy: ${huffmanResult.metadata?['entropy']?.toStringAsFixed(2) ?? 'N/A'} bits/char',);
      print(
          '     Unique chars: ${huffmanResult.metadata?['uniqueChars'] ?? 'N/A'}',);
      print(
          '     Ratio: ${(huffmanResult.compressionRatio * 100).toStringAsFixed(1)}%',);
      print(
          '     Space savings: ${huffmanResult.spaceSavings.toStringAsFixed(1)}%',);
      print('     Time: ${stopwatch.elapsedMicroseconds}μs');
    }
  }

  print(
      '\\n💡 Note: Different compression algorithms work better on different types of text.',);
  print('   Run Length Encoding excels with repeated characters.');
  print('   LZ77 works well with repeated patterns.');
  print(
      '   Huffman coding is effective for texts with non-uniform character frequency.',);
}
