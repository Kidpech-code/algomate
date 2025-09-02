import 'package:algomate/algomate.dart';

/// Simple example showing custom objects with AlgoMate's generic algorithms
void main() async {
  print('🎯 AlgoMate Generic Algorithms Demo\n');

  await demonstrateBasicUsage();
  print('\n${'=' * 50}\n');
  await demonstrateAdvancedFeatures();
}

/// Basic usage with custom objects
Future<void> demonstrateBasicUsage() async {
  print('📚 BASIC USAGE WITH CUSTOM OBJECTS');
  print('=' * 50);

  // Create some people
  final people = [
    Person('Alice', 28),
    Person('Bob', 35),
    Person('Carol', 22),
    Person('David', 45),
    Person('Eve', 31),
  ];

  print('Original people:');
  for (final person in people) {
    print('  $person');
  }

  // Sort using generic merge sort
  final sorter = GenericMergeSort<Person>();
  final sorted = sorter.execute(people);

  print('\nSorted by age:');
  for (final person in sorted) {
    print('  $person');
  }

  // Search for a specific person
  final searcher = GenericBinarySearch<Person>(Person('Carol', 22));
  final hint = SelectorHint(n: sorted.length, sorted: true);

  if (searcher.canApply(sorted, hint)) {
    final index = searcher.execute(sorted);
    print('\n🔍 Search result for Carol:');
    if (index != null) {
      print('  Found at index $index: ${sorted[index]}');
    } else {
      print('  Not found');
    }
  }

  // Demonstrate with numbers
  print('\n🔢 SORTING NUMBERS:');
  final numbers = [64, 34, 25, 12, 22, 11, 90];
  print('Original: $numbers');

  final numSorter = GenericQuickSort<int>();
  final sortedNumbers = numSorter.execute(numbers);
  print('Sorted: $sortedNumbers');
}

/// Advanced features demonstration
Future<void> demonstrateAdvancedFeatures() async {
  print('🚀 ADVANCED FEATURES');
  print('=' * 50);

  // Demonstrate Priority Queue
  print('📋 Priority Queue Example:');
  final pq = PriorityQueue<Task>();

  final tasks = [
    Task('Fix bug', 1),
    Task('Write docs', 3),
    Task('Deploy', 2),
  ];

  for (final task in tasks) {
    pq.add(task);
    print('  Added: $task');
  }

  print('\nProcessing in priority order:');
  while (!pq.isEmpty) {
    final task = pq.removeMin();
    print('  Processing: $task');
  }

  // Demonstrate custom data structure sorting
  print('\n🌳 Binary Search Tree Sorting:');
  final testData = [45, 25, 75, 15, 35];
  print('Original: $testData');

  final bstSort = BinarySearchTreeSort<int>();
  final bstSorted = bstSort.execute(testData);
  print('BST Sorted: $bstSorted');

  // Demonstrate with custom comparison
  print('\n💰 Products sorted by price:');
  final products = [
    Product('iPhone', 999.99),
    Product('iPad', 599.99),
    Product('MacBook', 1299.99),
    Product('Apple Watch', 399.99),
  ];

  print('Original:');
  for (final product in products) {
    print('  $product');
  }

  final productSorter = GenericMergeSort<Product>();
  final sortedProducts = productSorter.execute(products);

  print('\nSorted by price:');
  for (final product in sortedProducts) {
    print('  $product');
  }
}

// Custom classes that implement Comparable

/// Person class sorted by age, then by name
class Person implements Comparable<Person> {
  Person(this.name, this.age);
  final String name;
  final int age;

  @override
  int compareTo(Person other) {
    final ageComparison = age.compareTo(other.age);
    return ageComparison != 0 ? ageComparison : name.compareTo(other.name);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Person && other.name == name && other.age == age);

  @override
  int get hashCode => Object.hash(name, age);

  @override
  String toString() => 'Person(name: $name, age: $age)';
}

/// Task class sorted by priority (1 = highest)
class Task implements Comparable<Task> {
  Task(this.description, this.priority);
  final String description;
  final int priority;

  @override
  int compareTo(Task other) => priority.compareTo(other.priority);

  @override
  String toString() => 'Task("$description", priority: $priority)';
}

/// Product class sorted by price
class Product implements Comparable<Product> {
  Product(this.name, this.price);
  final String name;
  final double price;

  @override
  int compareTo(Product other) => price.compareTo(other.price);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.name == name);

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() =>
      'Product(name: $name, price: \$${price.toStringAsFixed(2)})';
}
