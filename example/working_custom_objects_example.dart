import 'package:algomate/algomate.dart';

/// Working example showing custom objects with AlgoMate
void main() async {
  print('🎯 AlgoMate with Custom Objects Demo\n');

  await demonstrateBasicSorting();
  print('\n${'=' * 50}\n');
  await demonstrateCustomObjects();
  print('\n${'=' * 50}\n');
  await demonstrateAdvancedFeatures();
}

/// Basic sorting with built-in AlgoMate
Future<void> demonstrateBasicSorting() async {
  print('📊 BASIC SORTING WITH ALGOMATE');
  print('=' * 50);

  final selector = AlgoSelectorFacade.development();

  // Test with different data sizes to see algorithm selection
  final testCases = [
    ([12, 11, 13, 5, 6], 'Small dataset'),
    (List.generate(100, (i) => 100 - i), 'Medium dataset (reverse sorted)'),
    (List.generate(1000, (i) => i % 50), 'Large dataset with duplicates'),
  ];

  for (final (data, description) in testCases) {
    print('\n🎯 $description (${data.length} elements):');
    print('Sample: ${data.take(10).toList()}${data.length > 10 ? '...' : ''}');

    final result = selector.sort(
      input: data,
      hint: SelectorHint(n: data.length),
    );

    result.fold(
      (success) {
        print('✅ Algorithm used: ${success.selectedStrategy.name}');
        print('⏱️ Time taken: ${success.executionTimeMicros}μs');
        final timeSeconds = (success.executionTimeMicros ?? 1) / 1000000;
        print(
            '📊 Performance: ${(data.length / timeSeconds).toStringAsFixed(0)} elements/sec',);
        final sortedSample = success.output.take(10).toList();
        print(
            'Result sample: $sortedSample${success.output.length > 10 ? '...' : ''}',);
      },
      (failure) => print('❌ Error: ${failure.message}'),
    );
  }
}

/// Demonstrate working with custom comparable objects
Future<void> demonstrateCustomObjects() async {
  print('👥 CUSTOM OBJECTS WITH COMPARABLE');
  print('=' * 50);

  // Since we can't directly use generic algorithms yet, let's show
  // how to make objects work with Dart's built-in sort
  final people = [
    const Person('Alice Johnson', 28, 'Engineering'),
    const Person('Bob Smith', 35, 'Marketing'),
    const Person('Carol Davis', 22, 'Design'),
    const Person('David Wilson', 45, 'Management'),
    const Person('Eve Brown', 31, 'Engineering'),
  ];

  print('Original people:');
  for (final person in people) {
    print('  $person');
  }

  // Use Dart's built-in sort (which uses the compareTo method)
  final sortedPeople = List<Person>.from(people);
  final stopwatch = Stopwatch()..start();
  sortedPeople.sort(); // Uses Person.compareTo()
  stopwatch.stop();

  print('\nSorted by age (using Comparable interface):');
  for (final person in sortedPeople) {
    print('  $person');
  }
  print(
      '⏱️ Sorted ${people.length} people in ${stopwatch.elapsedMicroseconds}μs',);

  // Demonstrate searching
  print('\n🔍 Searching for specific person:');
  const targetAge = 28;
  final found = sortedPeople.where((p) => p.age == targetAge).toList();
  print('People aged $targetAge: $found');

  // Demonstrate custom sorting criteria
  print('\n📊 Custom sorting by department then name:');
  final byDepartment = List<Person>.from(people);
  byDepartment.sort((a, b) {
    final deptComparison = a.department.compareTo(b.department);
    return deptComparison != 0 ? deptComparison : a.name.compareTo(b.name);
  });

  for (final person in byDepartment) {
    print('  $person');
  }
}

/// Advanced features demonstration
Future<void> demonstrateAdvancedFeatures() async {
  print('🚀 ADVANCED FEATURES');
  print('=' * 50);

  final selector = AlgoSelectorFacade.development();

  // Demonstrate with different hint configurations
  print('🎯 Algorithm selection with different hints:');

  final testData = List.generate(1000, (i) => i);

  final scenarios = [
    (const SelectorHint(n: 1000), 'Default hints'),
    (const SelectorHint(n: 1000, sorted: true), 'Data is sorted'),
    (const SelectorHint(n: 1000, preferStable: true), 'Prefer stable sorting'),
    (
      const SelectorHint(n: 1000, memoryBudgetBytes: 1024),
      'Memory constrained'
    ),
  ];

  for (final (hint, description) in scenarios) {
    print('\n📋 Scenario: $description');

    final result = selector.sort(input: testData, hint: hint);

    result.fold(
      (success) => print('   Selected: ${success.selectedStrategy.name}'),
      (failure) => print('   Error: ${failure.message}'),
    );
  }

  // Demonstrate search operations
  print('\n🔍 Search operations:');
  final sortedData =
      List.generate(10000, (i) => i * 2); // Even numbers 0, 2, 4...

  final searchTargets = [100, 199, 5000, 99999];

  for (final target in searchTargets) {
    final searchResult = selector.search(
      input: sortedData,
      target: target,
      hint: SelectorHint(n: sortedData.length, sorted: true),
    );

    searchResult.fold(
      (success) {
        final found = success.output != null;
        print(
            '  Target $target: ${found ? 'Found at index ${success.output}' : 'Not found'}',);
        print('    Algorithm: ${success.selectedStrategy.name}');
        print('    Time: ${success.executionTimeMicros}μs');
      },
      (failure) => print('  Search for $target failed: ${failure.message}'),
    );
  }

  // Demonstrate performance monitoring
  print('\n📈 Performance comparison:');
  await _performanceComparison(selector);
}

/// Compare performance across different data sizes
Future<void> _performanceComparison(AlgoSelectorFacade selector) async {
  final sizes = [100, 1000, 10000];

  print('Size\t| Algorithm\t\t| Time (μs)\t| Throughput (elem/s)');
  print('-' * 70);

  for (final size in sizes) {
    final data = List.generate(size, (i) => size - i); // Reverse sorted

    final result = selector.sort(
      input: data,
      hint: SelectorHint(n: size),
    );

    result.fold(
      (success) {
        final timeSeconds = (success.executionTimeMicros ?? 1) / 1000000;
        final throughput = (size / timeSeconds).toStringAsFixed(0);
        print(
          '${size.toString().padLeft(4)}\t| ${success.selectedStrategy.name.padRight(15)}\t| ${success.executionTimeMicros.toString().padLeft(6)}\t\t| $throughput',
        );
      },
      (failure) =>
          print('${size.toString().padLeft(4)}\t| Error: ${failure.message}'),
    );
  }
}

// Custom classes demonstrating Comparable implementation

/// Person class that implements Comparable for sorting by age
class Person implements Comparable<Person> {
  const Person(this.name, this.age, this.department);

  final String name;
  final int age;
  final String department;

  @override
  int compareTo(Person other) {
    // Primary sort: age, secondary sort: name
    final ageComparison = age.compareTo(other.age);
    return ageComparison != 0 ? ageComparison : name.compareTo(other.name);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Person &&
          other.name == name &&
          other.age == age &&
          other.department == department);

  @override
  int get hashCode => Object.hash(name, age, department);

  @override
  String toString() => 'Person(name: $name, age: $age, dept: $department)';
}

/// Product class for e-commerce scenarios
class Product implements Comparable<Product> {
  const Product(this.name, this.price, this.category);

  final String name;
  final double price;
  final String category;

  @override
  int compareTo(Product other) {
    // Sort by price, then by name
    final priceComparison = price.compareTo(other.price);
    return priceComparison != 0 ? priceComparison : name.compareTo(other.name);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.name == name);

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() =>
      'Product(name: $name, price: \$${price.toStringAsFixed(2)}, category: $category)';
}

/// Transaction class for financial applications
class Transaction implements Comparable<Transaction> {
  const Transaction(this.id, this.timestamp, this.amount, this.type);

  final String id;
  final DateTime timestamp;
  final double amount;
  final String type; // 'debit' or 'credit'

  @override
  int compareTo(Transaction other) {
    // Sort by timestamp (most recent first)
    return other.timestamp.compareTo(timestamp);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Transaction && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Transaction(id: $id, amount: \$${amount.toStringAsFixed(2)}, type: $type)';
}
