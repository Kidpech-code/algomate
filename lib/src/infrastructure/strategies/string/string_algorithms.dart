import 'dart:math';
import '../../../domain/entities/strategy.dart';
import '../../../domain/value_objects/algo_metadata.dart';
import '../../../domain/value_objects/selector_hint.dart';
import '../../../domain/value_objects/time_complexity.dart';

// =====================================================================
// INPUT/OUTPUT CLASSES FOR STRING ALGORITHMS
// =====================================================================

// Knuth-Morris-Pratt (KMP) Algorithm
class KMPInput {
  const KMPInput(this.text, this.pattern);
  final String text;
  final String pattern;

  @override
  String toString() => 'KMPInput(text: "$text", pattern: "$pattern")';
}

class KMPResult {
  const KMPResult(this.occurrences, this.pattern);
  final List<int> occurrences;
  final String pattern;

  bool get found => occurrences.isNotEmpty;
  int get count => occurrences.length;

  @override
  String toString() =>
      'KMPResult(found: $found, occurrences: $occurrences, count: $count)';
}

// Rabin-Karp Algorithm
class RabinKarpInput {
  const RabinKarpInput(
    this.text,
    this.pattern, {
    this.base = 256,
    this.prime = 101,
  });
  final String text;
  final String pattern;
  final int base;
  final int prime;

  @override
  String toString() =>
      'RabinKarpInput(text: "$text", pattern: "$pattern", base: $base, prime: $prime)';
}

class RabinKarpResult {
  const RabinKarpResult(this.occurrences, this.pattern, this.hashCollisions);
  final List<int> occurrences;
  final String pattern;
  final int hashCollisions;

  bool get found => occurrences.isNotEmpty;
  int get count => occurrences.length;

  @override
  String toString() =>
      'RabinKarpResult(found: $found, occurrences: $occurrences, collisions: $hashCollisions)';
}

// Z-Algorithm
class ZAlgorithmInput {
  const ZAlgorithmInput(this.text);
  final String text;

  @override
  String toString() => 'ZAlgorithmInput(text: "$text")';
}

class ZAlgorithmResult {
  const ZAlgorithmResult(this.zArray, this.text);
  final List<int> zArray;
  final String text;

  // Find pattern occurrences using Z-array
  List<int> findPattern(String pattern) {
    if (text.length < pattern.length) return [];

    final combined = '$pattern\$$text';
    final zCombined = _computeZArray(combined);
    final occurrences = <int>[];

    for (int i = pattern.length + 1; i < zCombined.length; i++) {
      if (zCombined[i] == pattern.length) {
        occurrences.add(i - pattern.length - 1);
      }
    }

    return occurrences;
  }

  List<int> _computeZArray(String s) {
    final n = s.length;
    final z = List.filled(n, 0);
    int l = 0, r = 0;

    for (int i = 1; i < n; i++) {
      if (i <= r) {
        z[i] = min(r - i + 1, z[i - l]);
      }

      while (i + z[i] < n && s[z[i]] == s[i + z[i]]) {
        z[i]++;
      }

      if (i + z[i] - 1 > r) {
        l = i;
        r = i + z[i] - 1;
      }
    }

    return z;
  }

  @override
  String toString() => 'ZAlgorithmResult(zArray: $zArray)';
}

// Longest Palindromic Substring
class LongestPalindromicSubstringInput {
  const LongestPalindromicSubstringInput(this.text);
  final String text;

  @override
  String toString() => 'LongestPalindromicSubstringInput(text: "$text")';
}

class LongestPalindromicSubstringResult {
  const LongestPalindromicSubstringResult(
    this.palindrome,
    this.startIndex,
    this.length,
  );
  final String palindrome;
  final int startIndex;
  final int length;

  int get endIndex => startIndex + length - 1;

  @override
  String toString() =>
      'LongestPalindromicSubstringResult(palindrome: "$palindrome", start: $startIndex, length: $length)';
}

// Manacher's Algorithm
class ManacherInput {
  const ManacherInput(this.text);
  final String text;

  @override
  String toString() => 'ManacherInput(text: "$text")';
}

class ManacherResult {
  const ManacherResult(
    this.longestPalindrome,
    this.startIndex,
    this.length,
    this.palindromeLengths,
  );
  final String longestPalindrome;
  final int startIndex;
  final int length;
  final List<int> palindromeLengths;

  List<String> getAllPalindromes(String originalText) {
    final palindromes = <String>{};

    for (int i = 0; i < palindromeLengths.length; i++) {
      if (palindromeLengths[i] > 1) {
        final center = i ~/ 2;
        final radius = palindromeLengths[i] ~/ 2;

        if (i % 2 == 0) {
          // Even center (between characters)
          final start = center - radius;
          final end = center + radius;
          if (start >= 0 && end < originalText.length) {
            palindromes.add(originalText.substring(start, end));
          }
        } else {
          // Odd center (on character)
          final start = center - radius;
          final end = center + radius + 1;
          if (start >= 0 && end <= originalText.length) {
            palindromes.add(originalText.substring(start, end));
          }
        }
      }
    }

    return palindromes.toList()..sort((a, b) => b.length.compareTo(a.length));
  }

  @override
  String toString() =>
      'ManacherResult(palindrome: "$longestPalindrome", start: $startIndex, length: $length)';
}

// Suffix Array
class SuffixArrayInput {
  const SuffixArrayInput(this.text);
  final String text;

  @override
  String toString() => 'SuffixArrayInput(text: "$text")';
}

class SuffixArrayResult {
  // Longest Common Prefix array (optional)

  const SuffixArrayResult(this.suffixArray, this.text, [this.lcp]);
  final List<int> suffixArray;
  final String text;
  final List<int>? lcp;

  // Get suffix at specific rank
  String getSuffix(int rank) {
    if (rank < 0 || rank >= suffixArray.length) return '';
    return text.substring(suffixArray[rank]);
  }

  // Find pattern using binary search on suffix array
  List<int> findPattern(String pattern) {
    final occurrences = <int>[];
    int left = 0, right = suffixArray.length - 1;

    // Find leftmost occurrence
    int leftBound = -1;
    while (left <= right) {
      final mid = (left + right) ~/ 2;
      final suffix = getSuffix(mid);

      if (suffix.startsWith(pattern)) {
        leftBound = mid;
        right = mid - 1;
      } else if (suffix.compareTo(pattern) < 0) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    if (leftBound == -1) return occurrences;

    // Find rightmost occurrence
    left = leftBound;
    right = suffixArray.length - 1;
    int rightBound = leftBound;

    while (left <= right) {
      final mid = (left + right) ~/ 2;
      final suffix = getSuffix(mid);

      if (suffix.startsWith(pattern)) {
        rightBound = mid;
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    // Collect all occurrences
    for (int i = leftBound; i <= rightBound; i++) {
      occurrences.add(suffixArray[i]);
    }

    return occurrences..sort();
  }

  @override
  String toString() =>
      'SuffixArrayResult(suffixArray: $suffixArray, hasLCP: ${lcp != null})';
}

// Trie (Prefix Tree)
class TrieInput {
  const TrieInput(this.words);
  final List<String> words;

  @override
  String toString() => 'TrieInput(words: $words)';
}

class TrieNode {
  final Map<String, TrieNode> children = {};
  bool isEndOfWord = false;
  String? word;
}

class TrieResult {
  TrieResult(this.root, this.words);
  final TrieNode root;
  final List<String> words;

  // Search for a word
  bool search(String word) {
    var node = root;
    for (int i = 0; i < word.length; i++) {
      final char = word[i];
      if (!node.children.containsKey(char)) return false;
      node = node.children[char]!;
    }
    return node.isEndOfWord;
  }

  // Check if any word starts with prefix
  bool startsWith(String prefix) {
    var node = root;
    for (int i = 0; i < prefix.length; i++) {
      final char = prefix[i];
      if (!node.children.containsKey(char)) return false;
      node = node.children[char]!;
    }
    return true;
  }

  // Get all words with given prefix
  List<String> getWordsWithPrefix(String prefix) {
    final result = <String>[];
    var node = root;

    // Navigate to prefix node
    for (int i = 0; i < prefix.length; i++) {
      final char = prefix[i];
      if (!node.children.containsKey(char)) return result;
      node = node.children[char]!;
    }

    // DFS to collect all words from this node
    _dfsCollectWords(node, prefix, result);
    return result;
  }

  void _dfsCollectWords(TrieNode node, String current, List<String> result) {
    if (node.isEndOfWord) {
      result.add(current);
    }

    for (final entry in node.children.entries) {
      _dfsCollectWords(entry.value, current + entry.key, result);
    }
  }

  @override
  String toString() =>
      'TrieResult(wordCount: ${words.length}, rootChildren: ${root.children.length})';
}

// Aho-Corasick Algorithm
class AhoCorasickInput {
  const AhoCorasickInput(this.text, this.patterns);
  final String text;
  final List<String> patterns;

  @override
  String toString() => 'AhoCorasickInput(text: "$text", patterns: $patterns)';
}

class AhoCorasickResult {
  const AhoCorasickResult(this.patternOccurrences, this.text);
  final Map<String, List<int>> patternOccurrences;
  final String text;

  int get totalMatches =>
      patternOccurrences.values.fold(0, (sum, list) => sum + list.length);
  List<String> get foundPatterns => patternOccurrences.keys
      .where((p) => patternOccurrences[p]!.isNotEmpty)
      .toList();

  @override
  String toString() =>
      'AhoCorasickResult(totalMatches: $totalMatches, foundPatterns: ${foundPatterns.length})';
}

// String Compression
class StringCompressionInput {
  const StringCompressionInput(
    this.text, {
    this.type = CompressionType.runLength,
  });
  final String text;
  final CompressionType type;

  @override
  String toString() => 'StringCompressionInput(text: "$text", type: $type)';
}

enum CompressionType {
  runLength,
  lz77,
  huffman,
}

class StringCompressionResult {
  const StringCompressionResult(
    this.compressedText,
    this.originalText,
    this.compressionRatio,
    this.type, [
    this.metadata,
  ]);
  final String compressedText;
  final String originalText;
  final double compressionRatio;
  final CompressionType type;
  final Map<String, dynamic>? metadata;

  double get spaceSavings => (1 - compressionRatio) * 100;

  @override
  String toString() =>
      'StringCompressionResult(ratio: ${compressionRatio.toStringAsFixed(3)}, savings: ${spaceSavings.toStringAsFixed(1)}%)';
}

// =====================================================================
// STRING ALGORITHM STRATEGIES
// =====================================================================

// Knuth-Morris-Pratt Algorithm
class KnuthMorrisPrattAlgorithm extends Strategy<KMPInput, KMPResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'knuth_morris_pratt',
        description: 'Knuth-Morris-Pratt pattern matching algorithm',
        timeComplexity: TimeComplexity.oN, // O(n + m)
        spaceComplexity: TimeComplexity.oN, // O(m) for failure function,
      );

  @override
  bool canApply(KMPInput input, SelectorHint hint) {
    return input.text.isNotEmpty && input.pattern.isNotEmpty;
  }

  @override
  KMPResult execute(KMPInput input) {
    final text = input.text;
    final pattern = input.pattern;

    if (pattern.isEmpty) return KMPResult([], pattern);

    // Build failure function
    final failure = _buildFailureFunction(pattern);

    final occurrences = <int>[];
    int i = 0; // text index
    int j = 0; // pattern index

    while (i < text.length) {
      if (text[i] == pattern[j]) {
        i++;
        j++;

        if (j == pattern.length) {
          occurrences.add(i - j);
          j = failure[j - 1];
        }
      } else if (j > 0) {
        j = failure[j - 1];
      } else {
        i++;
      }
    }

    return KMPResult(occurrences, pattern);
  }

  List<int> _buildFailureFunction(String pattern) {
    final failure = List.filled(pattern.length, 0);
    int i = 1, j = 0;

    while (i < pattern.length) {
      if (pattern[i] == pattern[j]) {
        failure[i] = j + 1;
        i++;
        j++;
      } else if (j > 0) {
        j = failure[j - 1];
      } else {
        failure[i] = 0;
        i++;
      }
    }

    return failure;
  }
}

// Rabin-Karp Algorithm
class RabinKarpAlgorithm extends Strategy<RabinKarpInput, RabinKarpResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'rabin_karp',
        description: 'Rabin-Karp rolling hash pattern matching algorithm',
        timeComplexity: TimeComplexity.oN, // O(n + m) average case
        spaceComplexity: TimeComplexity.o1, // O(1),
      );

  @override
  bool canApply(RabinKarpInput input, SelectorHint hint) {
    return input.text.isNotEmpty && input.pattern.isNotEmpty;
  }

  @override
  RabinKarpResult execute(RabinKarpInput input) {
    final text = input.text;
    final pattern = input.pattern;
    final base = input.base;
    final prime = input.prime;

    if (pattern.isEmpty || pattern.length > text.length) {
      return RabinKarpResult([], pattern, 0);
    }

    final m = pattern.length;
    final n = text.length;

    // Calculate pattern hash and first window hash
    int patternHash = 0;
    int windowHash = 0;
    int h = 1; // base^(m-1) % prime
    int collisions = 0;

    // Calculate h = base^(m-1) % prime
    for (int i = 0; i < m - 1; i++) {
      h = (h * base) % prime;
    }

    // Calculate hash for pattern and first window
    for (int i = 0; i < m; i++) {
      patternHash = (base * patternHash + pattern.codeUnitAt(i)) % prime;
      windowHash = (base * windowHash + text.codeUnitAt(i)) % prime;
    }

    final occurrences = <int>[];

    // Slide the pattern over text
    for (int i = 0; i <= n - m; i++) {
      if (patternHash == windowHash) {
        // Hash match - verify character by character
        if (_checkMatch(text, pattern, i)) {
          occurrences.add(i);
        } else {
          collisions++;
        }
      }

      // Calculate hash for next window
      if (i < n - m) {
        windowHash = (base * (windowHash - text.codeUnitAt(i) * h) +
                text.codeUnitAt(i + m)) %
            prime;
        if (windowHash < 0) windowHash += prime;
      }
    }

    return RabinKarpResult(occurrences, pattern, collisions);
  }

  bool _checkMatch(String text, String pattern, int start) {
    for (int i = 0; i < pattern.length; i++) {
      if (text[start + i] != pattern[i]) return false;
    }
    return true;
  }
}

// Z-Algorithm
class ZAlgorithm extends Strategy<ZAlgorithmInput, ZAlgorithmResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'z_algorithm',
        description: 'Z-Algorithm for string matching and analysis',
        timeComplexity: TimeComplexity.oN, // O(n)
        spaceComplexity: TimeComplexity.oN, // O(n),
      );

  @override
  bool canApply(ZAlgorithmInput input, SelectorHint hint) {
    return input.text.isNotEmpty;
  }

  @override
  ZAlgorithmResult execute(ZAlgorithmInput input) {
    final text = input.text;
    final zArray = _computeZArray(text);
    return ZAlgorithmResult(zArray, text);
  }

  List<int> _computeZArray(String s) {
    final n = s.length;
    final z = List.filled(n, 0);
    int l = 0, r = 0;

    for (int i = 1; i < n; i++) {
      if (i <= r) {
        z[i] = min(r - i + 1, z[i - l]);
      }

      while (i + z[i] < n && s[z[i]] == s[i + z[i]]) {
        z[i]++;
      }

      if (i + z[i] - 1 > r) {
        l = i;
        r = i + z[i] - 1;
      }
    }

    return z;
  }
}

// Longest Palindromic Substring (Expand Around Centers)
class LongestPalindromicSubstringAlgorithm extends Strategy<
    LongestPalindromicSubstringInput, LongestPalindromicSubstringResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'longest_palindromic_substring',
        description:
            'Find longest palindromic substring using expand around centers',
        timeComplexity: TimeComplexity.oN2, // O(n²)
        spaceComplexity: TimeComplexity.o1, // O(1),
      );

  @override
  bool canApply(LongestPalindromicSubstringInput input, SelectorHint hint) {
    return input.text.isNotEmpty;
  }

  @override
  LongestPalindromicSubstringResult execute(
    LongestPalindromicSubstringInput input,
  ) {
    final text = input.text;
    if (text.isEmpty) return const LongestPalindromicSubstringResult('', 0, 0);

    int start = 0;
    int maxLen = 1;

    for (int i = 0; i < text.length; i++) {
      // Check for odd length palindromes (centered at i)
      final len1 = _expandAroundCenter(text, i, i);

      // Check for even length palindromes (centered between i and i+1)
      final len2 = _expandAroundCenter(text, i, i + 1);

      final currentMax = max(len1, len2);

      if (currentMax > maxLen) {
        maxLen = currentMax;
        start = i - (currentMax - 1) ~/ 2;
      }
    }

    final palindrome = text.substring(start, start + maxLen);
    return LongestPalindromicSubstringResult(palindrome, start, maxLen);
  }

  int _expandAroundCenter(String s, int left, int right) {
    while (left >= 0 && right < s.length && s[left] == s[right]) {
      left--;
      right++;
    }
    return right - left - 1;
  }
}

// Manacher's Algorithm
class ManacherAlgorithm extends Strategy<ManacherInput, ManacherResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'manacher_algorithm',
        description:
            'Manacher\'s algorithm for finding all palindromic substrings',
        timeComplexity: TimeComplexity.oN, // O(n)
        spaceComplexity: TimeComplexity.oN, // O(n),
      );

  @override
  bool canApply(ManacherInput input, SelectorHint hint) {
    return input.text.isNotEmpty;
  }

  @override
  ManacherResult execute(ManacherInput input) {
    final originalText = input.text;
    if (originalText.isEmpty) return const ManacherResult('', 0, 0, []);

    // Transform string: "abc" -> "^#a#b#c#$"
    final text = '^#${originalText.split('').join('#')}#\$';
    final n = text.length;
    final palindromeLengths = List.filled(n, 0);

    int center = 0;
    int rightBoundary = 0;
    int maxLen = 0;
    int centerIndex = 0;

    for (int i = 1; i < n - 1; i++) {
      final mirror = 2 * center - i;

      if (i < rightBoundary) {
        palindromeLengths[i] =
            min(rightBoundary - i, palindromeLengths[mirror]);
      }

      // Try to expand palindrome centered at i
      while (text[i + palindromeLengths[i] + 1] ==
          text[i - palindromeLengths[i] - 1]) {
        palindromeLengths[i]++;
      }

      // If palindrome centered at i extends past rightBoundary, adjust center and rightBoundary
      if (i + palindromeLengths[i] > rightBoundary) {
        center = i;
        rightBoundary = i + palindromeLengths[i];
      }

      // Update maximum length palindrome
      if (palindromeLengths[i] > maxLen) {
        maxLen = palindromeLengths[i];
        centerIndex = i;
      }
    }

    // Extract the longest palindrome
    final start = (centerIndex - maxLen) ~/ 2;
    final longestPalindrome = originalText.substring(start, start + maxLen);

    return ManacherResult(longestPalindrome, start, maxLen, palindromeLengths);
  }
}

// Suffix Array Construction
class SuffixArrayAlgorithm
    extends Strategy<SuffixArrayInput, SuffixArrayResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'suffix_array',
        description: 'Suffix array construction for string analysis',
        timeComplexity: TimeComplexity.oNLogN, // O(n log n)
        spaceComplexity: TimeComplexity.oN, // O(n),
      );

  @override
  bool canApply(SuffixArrayInput input, SelectorHint hint) {
    return input.text.isNotEmpty;
  }

  @override
  SuffixArrayResult execute(SuffixArrayInput input) {
    final text = input.text;
    final n = text.length;

    // Create list of suffixes with their indices
    final suffixes = List.generate(n, (i) => (i, text.substring(i)));

    // Sort suffixes lexicographically
    suffixes.sort((a, b) => a.$2.compareTo(b.$2));

    // Extract suffix array (indices only)
    final suffixArray = suffixes.map((s) => s.$1).toList();

    // Optionally compute LCP array
    final lcp = _computeLCPArray(text, suffixArray);

    return SuffixArrayResult(suffixArray, text, lcp);
  }

  List<int> _computeLCPArray(String text, List<int> suffixArray) {
    final n = text.length;
    final lcp = List.filled(n, 0);
    final invSuffix = List.filled(n, 0);

    // Create inverse suffix array
    for (int i = 0; i < n; i++) {
      invSuffix[suffixArray[i]] = i;
    }

    int k = 0;

    for (int i = 0; i < n; i++) {
      if (invSuffix[i] == n - 1) {
        k = 0;
        continue;
      }

      final int j = suffixArray[invSuffix[i] + 1];

      while (i + k < n && j + k < n && text[i + k] == text[j + k]) {
        k++;
      }

      lcp[invSuffix[i]] = k;

      if (k > 0) k--;
    }

    return lcp;
  }
}

// Trie Construction and Operations
class TrieAlgorithm extends Strategy<TrieInput, TrieResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'trie_prefix_tree',
        description: 'Trie (prefix tree) construction and operations',
        timeComplexity: TimeComplexity.oN, // O(total length of all words)
        spaceComplexity: TimeComplexity.oN, // O(total length of all words),
      );

  @override
  bool canApply(TrieInput input, SelectorHint hint) {
    return input.words.isNotEmpty;
  }

  @override
  TrieResult execute(TrieInput input) {
    final root = TrieNode();

    for (final word in input.words) {
      _insert(root, word);
    }

    return TrieResult(root, input.words);
  }

  void _insert(TrieNode root, String word) {
    var node = root;

    for (int i = 0; i < word.length; i++) {
      final char = word[i];
      if (!node.children.containsKey(char)) {
        node.children[char] = TrieNode();
      }
      node = node.children[char]!;
    }

    node.isEndOfWord = true;
    node.word = word;
  }
}

// Aho-Corasick Algorithm
class AhoCorasickAlgorithm
    extends Strategy<AhoCorasickInput, AhoCorasickResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'aho_corasick',
        description: 'Aho-Corasick algorithm for multiple pattern matching',
        timeComplexity:
            TimeComplexity.oN, // O(n + m + z) where z is number of matches
        spaceComplexity: TimeComplexity.oN, // O(sum of pattern lengths),
      );

  @override
  bool canApply(AhoCorasickInput input, SelectorHint hint) {
    return input.text.isNotEmpty && input.patterns.isNotEmpty;
  }

  @override
  AhoCorasickResult execute(AhoCorasickInput input) {
    final text = input.text;
    final patterns = input.patterns.where((p) => p.isNotEmpty).toList();

    if (patterns.isEmpty) {
      return AhoCorasickResult({}, text);
    }

    // Build trie
    final root = TrieNode();
    for (final pattern in patterns) {
      _insertPattern(root, pattern);
    }

    // Build failure links
    _buildFailureLinks(root);

    // Search for patterns
    final result = <String, List<int>>{};
    for (final pattern in patterns) {
      result[pattern] = [];
    }

    var currentNode = root;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      // Follow failure links until we find a match or reach root
      while (currentNode != root && !currentNode.children.containsKey(char)) {
        currentNode = currentNode.children['failure'] ?? root;
      }

      if (currentNode.children.containsKey(char)) {
        currentNode = currentNode.children[char]!;
      }

      // Check for matches at current node and all its suffix nodes
      var temp = currentNode;
      while (temp != root) {
        if (temp.isEndOfWord && temp.word != null) {
          final pattern = temp.word!;
          result[pattern]!.add(i - pattern.length + 1);
        }
        temp = temp.children['failure'] ?? root;
      }
    }

    return AhoCorasickResult(result, text);
  }

  void _insertPattern(TrieNode root, String pattern) {
    var node = root;

    for (int i = 0; i < pattern.length; i++) {
      final char = pattern[i];
      if (!node.children.containsKey(char)) {
        node.children[char] = TrieNode();
      }
      node = node.children[char]!;
    }

    node.isEndOfWord = true;
    node.word = pattern;
  }

  void _buildFailureLinks(TrieNode root) {
    final queue = <TrieNode>[];

    // Initialize failure links for level 1
    for (final child in root.children.values) {
      if (child != root.children['failure']) {
        child.children['failure'] = root;
        queue.add(child);
      }
    }

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      for (final entry in current.children.entries) {
        if (entry.key == 'failure') continue;

        final child = entry.value;
        final char = entry.key;
        queue.add(child);

        var failure = current.children['failure'] ?? root;

        while (failure != root && !failure.children.containsKey(char)) {
          failure = failure.children['failure'] ?? root;
        }

        if (failure.children.containsKey(char) &&
            failure.children[char] != child) {
          child.children['failure'] = failure.children[char]!;
        } else {
          child.children['failure'] = root;
        }
      }
    }
  }
}

// String Compression (Run Length Encoding)
class StringCompressionAlgorithm
    extends Strategy<StringCompressionInput, StringCompressionResult> {
  @override
  AlgoMetadata get meta => const AlgoMetadata(
        name: 'string_compression',
        description: 'String compression using Run Length Encoding',
        timeComplexity: TimeComplexity.oN, // O(n)
        spaceComplexity: TimeComplexity.oN, // O(n) for result,
      );

  @override
  bool canApply(StringCompressionInput input, SelectorHint hint) {
    return input.text.isNotEmpty;
  }

  @override
  StringCompressionResult execute(StringCompressionInput input) {
    switch (input.type) {
      case CompressionType.runLength:
        return _runLengthEncoding(input.text);
      case CompressionType.lz77:
        return _lz77Compression(input.text);
      case CompressionType.huffman:
        return _huffmanCompression(input.text);
    }
  }

  StringCompressionResult _runLengthEncoding(String text) {
    if (text.isEmpty) {
      return StringCompressionResult('', text, 0.0, CompressionType.runLength);
    }

    final result = StringBuffer();
    int count = 1;
    String current = text[0];

    for (int i = 1; i < text.length; i++) {
      if (text[i] == current) {
        count++;
      } else {
        result.write('$current$count');
        current = text[i];
        count = 1;
      }
    }

    result.write('$current$count');

    final compressed = result.toString();
    final ratio = compressed.length / text.length;

    return StringCompressionResult(
      compressed,
      text,
      ratio,
      CompressionType.runLength,
    );
  }

  StringCompressionResult _lz77Compression(String text) {
    // Simplified LZ77 implementation
    final result = <String>[];
    int i = 0;

    while (i < text.length) {
      final (offset, length, nextChar) = _findLongestMatch(text, i);

      if (length > 0) {
        result.add('($offset,$length,${nextChar ?? ''})');
        i += length + (nextChar != null ? 1 : 0);
      } else {
        result.add(text[i]);
        i++;
      }
    }

    final compressed = result.join('');
    final ratio = compressed.length / text.length;

    return StringCompressionResult(
      compressed,
      text,
      ratio,
      CompressionType.lz77,
      {'tokens': result.length},
    );
  }

  (int, int, String?) _findLongestMatch(String text, int current) {
    int maxLength = 0;
    int bestOffset = 0;
    String? nextChar;

    final windowStart = max(0, current - 255); // Sliding window

    for (int i = windowStart; i < current; i++) {
      int length = 0;

      while (current + length < text.length &&
          i + length < current &&
          text[i + length] == text[current + length]) {
        length++;
      }

      if (length > maxLength) {
        maxLength = length;
        bestOffset = current - i;
        nextChar =
            current + length < text.length ? text[current + length] : null;
      }
    }

    return (bestOffset, maxLength, nextChar);
  }

  StringCompressionResult _huffmanCompression(String text) {
    // Simplified Huffman encoding representation
    final frequency = <String, int>{};

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      frequency[char] = (frequency[char] ?? 0) + 1;
    }

    // For demonstration, assume average bit reduction based on frequency distribution
    final entropy = _calculateEntropy(frequency, text.length);
    final estimatedBits = (text.length * entropy).ceil();
    final originalBits = text.length * 8; // Assuming ASCII

    final ratio = estimatedBits / originalBits;
    final compressed = 'HUFFMAN_COMPRESSED_${text.length}_CHARS';

    return StringCompressionResult(
      compressed,
      text,
      ratio,
      CompressionType.huffman,
      {'entropy': entropy, 'uniqueChars': frequency.length},
    );
  }

  double _calculateEntropy(Map<String, int> frequency, int total) {
    double entropy = 0.0;

    for (final count in frequency.values) {
      final probability = count / total;
      entropy -= probability * (log(probability) / log(2));
    }

    return entropy;
  }
}
