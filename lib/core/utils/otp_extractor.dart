/// OTP Extractor Utility
/// Implements a robust, context-aware algorithm to extract 4-8 digit OTPs
/// from email content while avoiding false positives.
library;

class OtpExtractor {
  // Regex for purely numeric candidates of 4-8 digits
  static final RegExp _candidateRegex = RegExp(r'\b\d{4,8}\b');

  // Exclusion patterns
  static final RegExp _yearPattern = RegExp(r'^(19|20)\d{2}$');
  
  // Keywords that boost confidence
  static const List<String> _keywords = [
    'otp',
    'verification',
    'verify',
    'code',
    'security code',
    'authentication',
    'login',
    'passcode',
    'one time password',
    'secret',
    'pin',
  ];

  static String? extract(String content) {
    if (content.isEmpty) return null;

    // 1. Normalize Content
    final normalized = _normalize(content);

    // 2. Candidate Extraction
    final candidates = _extractCandidates(normalized);

    if (candidates.isEmpty) return null;

    // 3. Hard Exclusion Filters & 4. Contextual Scoring
    final scoredCandidates = <_ScoredCandidate>[];

    for (final candidate in candidates) {
      if (!_isExcluded(candidate, normalized)) {
        scoredCandidates.add(_scoreCandidate(candidate, normalized));
      }
    }

    if (scoredCandidates.isEmpty) return null;

    // 5. Final Selection
    scoredCandidates.sort((a, b) {
      // Sort by score descending
      final scoreDiff = b.score.compareTo(a.score);
      if (scoreDiff != 0) return scoreDiff;

      // If tie, prefer closer distance to keyword
      final distanceDiff = a.distance.compareTo(b.distance);
      if (distanceDiff != 0) return distanceDiff;

      // If tie, prefer 6 digits
      if (a.value.length == 6 && b.value.length != 6) return -1;
      if (b.value.length == 6 && a.value.length != 6) return 1;

      return 0;
    });

    // Return the best candidate if score is above threshold (optional, but good for safety)
    if (scoredCandidates.isNotEmpty && scoredCandidates.first.score > 0) {
      return scoredCandidates.first.value;
    }

    return null;
  }

  static String _normalize(String content) {
    // Remove HTML tags (simple approximation)
    var text = content.replaceAll(RegExp(r'<[^>]*>'), ' ');
    // Lowercase
    text = text.toLowerCase();
    // Replace newlines with spaces
    text = text.replaceAll(RegExp(r'[\r\n]+'), ' ');
    // Collapse spaces
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    return text.trim();
  }

  static List<_Candidate> _extractCandidates(String text) {
    final matches = _candidateRegex.allMatches(text);
    return matches.map((m) => _Candidate(m.group(0)!, m.start)).toList();
  }

  static bool _isExcluded(_Candidate candidate, String text) {
    final val = candidate.value;
    
    // Year check (1900-2099)
    if (_yearPattern.hasMatch(val)) return true;

    // Adjacent to time separator (:) or date separators
    final start = candidate.index;
    final end = start + val.length;
    
    // Check 1 char before and after
    if (start > 0) {
      final char = text[start - 1];
      if (char == ':' || char == '-' || char == '/') return true;
      // Currency check (simple)
      if (['\$', '€', '£', '₹', '¥'].contains(char)) return true;
    }
    if (end < text.length) {
      final char = text[end];
      if (char == ':' || char == '-' || char == '/') return true;
    }

    return false;
  }

  static _ScoredCandidate _scoreCandidate(_Candidate candidate, String text) {
    double score = 0;
    
    // Base Length Score
    if (candidate.value.length == 6) score += 10;
    else if (candidate.value.length == 4) score += 5;
    else score += 2;

    // Context Boost
    int minDistance = 999999;
    
    for (final keyword in _keywords) {
      int startIndex = 0;
      while (true) {
        final index = text.indexOf(keyword, startIndex);
        if (index == -1) break;

        int dist;
        // If keyword is before candidate
        if (index + keyword.length <= candidate.index) {
          dist = candidate.index - (index + keyword.length);
        } 
        // If keyword is after candidate
        else if (index >= candidate.index + candidate.value.length) {
          dist = index - (candidate.index + candidate.value.length);
        } else {
          dist = 0; // Overlap
        }

        if (dist < minDistance) minDistance = dist;
        startIndex = index + 1;
      }
    }

    if (minDistance <= 30) {
      score += 20; // High boost for close proximity
    } else if (minDistance <= 100) {
      score += 5; // Slight boost
    }

    return _ScoredCandidate(candidate.value, score, minDistance);
  }
}

class _Candidate {
  final String value;
  final int index;

  _Candidate(this.value, this.index);
}

class _ScoredCandidate {
  final String value;
  final double score;
  final int distance;

  _ScoredCandidate(this.value, this.score, this.distance);
}
