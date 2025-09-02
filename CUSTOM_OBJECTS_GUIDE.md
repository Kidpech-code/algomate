# 🎯 AlgoMate Custom Objects Guide

สำหรับ AlgoMate v0.1.5 รองรับการทำงานกับ custom objects และ data structures แล้ว!

## 📚 Table of Contents

- [Custom Objects with Comparable](#custom-objects-with-comparable)
- [Generic Algorithms](#generic-algorithms)
- [Custom Data Structures](#custom-data-structures)
- [Best Practices](#best-practices)
- [Performance Tips](#performance-tips)
- [Examples](#examples)

## 🔧 Custom Objects with Comparable

### Basic Implementation

สร้าง custom class ที่ implement `Comparable<T>`:

```dart
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
```

### Using with AlgoMate

```dart
import 'package:algomate/algomate.dart';

void main() async {
  final selector = AlgoSelectorFacade.development();

  final people = [
    Person('Alice', 28, 'Engineering'),
    Person('Bob', 35, 'Marketing'),
    Person('Carol', 22, 'Design'),
  ];

  // Sort using built-in Dart sort (uses compareTo)
  final sortedPeople = List<Person>.from(people);
  sortedPeople.sort();

  print('Sorted people: $sortedPeople');
}
```

## 🧬 Generic Algorithms

AlgoMate v0.1.5+ มี generic algorithms ที่รองรับ custom types:

### Available Generic Algorithms

#### Sorting Algorithms

- `GenericMergeSort<T>` - O(n log n), stable, ใช้สำหรับ datasets ใหญ่
- `GenericQuickSort<T>` - O(n log n) average, in-place, เร็วสำหรับ random data
- `GenericInsertionSort<T>` - O(n²), ดีสำหรับ small datasets
- `GenericHeapSort<T>` - O(n log n), guaranteed performance

#### Search Algorithms

- `GenericBinarySearch<T>` - O(log n), ต้องมี sorted data
- `GenericLinearSearch<T>` - O(n), ใช้ได้กับทุก dataset
- `GenericBinarySearchInsertion<T>` - หา insertion point

### Generic Algorithm Usage

```dart
import 'package:algomate/generic_sort_algorithms.dart';

void sortCustomObjects() {
  final products = [
    Product('Laptop', 999.99, 'Electronics'),
    Product('Book', 19.99, 'Education'),
    Product('Chair', 149.99, 'Furniture'),
  ];

  // ใช้ generic merge sort
  final mergeSorter = GenericMergeSort<Product>();
  final result = mergeSorter.execute(
    input: products,
    hint: SelectorHint(n: products.length),
  );

  result.fold(
    (success) => print('Sorted: ${success.output}'),
    (failure) => print('Error: ${failure.message}'),
  );
}
```

## 🏗️ Custom Data Structures

### Priority Queue

```dart
import 'package:algomate/custom_data_structures.dart';

void usePriorityQueue() {
  final pq = PriorityQueue<Task>();

  pq.insert(Task('High Priority', 1));
  pq.insert(Task('Low Priority', 5));
  pq.insert(Task('Medium Priority', 3));

  while (!pq.isEmpty) {
    final task = pq.extractMin();
    print('Processing: $task');
  }
}
```

### Binary Search Tree

```dart
void useBinarySearchTree() {
  final bst = BinarySearchTree<int>();

  final numbers = [50, 30, 70, 20, 40, 60, 80];
  for (final num in numbers) {
    bst.insert(num);
  }

  print('In-order traversal: ${bst.inOrder()}');
  print('Contains 40: ${bst.contains(40)}');
}
```

### Circular Buffer

```dart
void useCircularBuffer() {
  final buffer = CircularBuffer<String>(capacity: 3);

  buffer.push('First');
  buffer.push('Second');
  buffer.push('Third');
  buffer.push('Fourth'); // overwrites 'First'

  print('Buffer size: ${buffer.size}');
  print('Current items: ${buffer.toList()}');
}
```

## 🎯 Best Practices

### 1. Implement Comparable Correctly

```dart
class Transaction implements Comparable<Transaction> {
  final DateTime timestamp;
  final double amount;

  @override
  int compareTo(Transaction other) {
    // เปรียบเทียบ timestamp ก่อน
    final timeComparison = timestamp.compareTo(other.timestamp);
    if (timeComparison != 0) return timeComparison;

    // ถ้า timestamp เท่ากัน ให้เปรียบเทียบ amount
    return amount.compareTo(other.amount);
  }
}
```

### 2. Override equals และ hashCode

```dart
@override
bool operator ==(Object other) =>
    identical(this, other) ||
    (other is Transaction &&
     other.id == id);

@override
int get hashCode => id.hashCode;
```

### 3. ใช้ SelectorHint อย่างมีประสิทธิภาพ

```dart
// สำหรับ data ที่เรียงแล้ว
final hint = SelectorHint(
  n: data.length,
  sorted: true,
  nearlySorted: true,
);

// สำหรับ memory จำกัด
final hint = SelectorHint(
  n: data.length,
  memoryBudgetBytes: 1024,
);

// สำหรับ stable sorting
final hint = SelectorHint(
  n: data.length,
  preferStable: true,
);
```

## ⚡ Performance Tips

### 1. เลือก Algorithm ให้เหมาะสม

```dart
// Small datasets (< 50 elements)
GenericInsertionSort<T>()

// Medium datasets (50-10000 elements)
GenericMergeSort<T>() // stable
GenericQuickSort<T>()  // faster average case

// Large datasets (> 10000 elements)
GenericQuickSort<T>()
GenericHeapSort<T>()   // guaranteed O(n log n)
```

### 2. ใช้ Memory Budget

```dart
final hint = SelectorHint(
  n: data.length,
  memoryBudgetBytes: 4096, // 4KB limit
);
```

### 3. Algorithm Selection Strategies

```dart
// สำหรับ production
final selector = AlgoSelectorFacade.production();

// สำหรับ development (มี logging)
final selector = AlgoSelectorFacade.development();

// สำหรับ testing
final selector = AlgoSelectorFacade.minimal();
```

## 🎮 Examples

### Example 1: E-commerce Product Sorting

```dart
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
}

void sortProducts() {
  final products = [
    Product('Laptop Pro', 1299.99, 'Electronics'),
    Product('Basic Laptop', 599.99, 'Electronics'),
    Product('Gaming Chair', 299.99, 'Furniture'),
  ];

  // Sort using Dart's built-in sort
  final sortedProducts = List<Product>.from(products);
  sortedProducts.sort();

  print('Products by price:');
  for (final product in sortedProducts) {
    print('  ${product.name}: \$${product.price}');
  }
}
```

### Example 2: Task Management System

```dart
class Task implements Comparable<Task> {
  const Task(this.title, this.priority, this.dueDate);

  final String title;
  final int priority; // 1 = highest, 5 = lowest
  final DateTime dueDate;

  @override
  int compareTo(Task other) {
    // Sort by priority first, then by due date
    final priorityComparison = priority.compareTo(other.priority);
    return priorityComparison != 0
        ? priorityComparison
        : dueDate.compareTo(other.dueDate);
  }
}

void manageTasks() {
  final tasks = [
    Task('Fix critical bug', 1, DateTime.now().add(Duration(days: 1))),
    Task('Write documentation', 3, DateTime.now().add(Duration(days: 7))),
    Task('Code review', 2, DateTime.now().add(Duration(days: 2))),
  ];

  // Using priority queue for task management
  final taskQueue = PriorityQueue<Task>();
  for (final task in tasks) {
    taskQueue.insert(task);
  }

  print('Tasks in priority order:');
  while (!taskQueue.isEmpty) {
    final task = taskQueue.extractMin();
    print('  ${task.title} (Priority: ${task.priority})');
  }
}
```

### Example 3: Financial Transaction Analysis

```dart
class Transaction implements Comparable<Transaction> {
  const Transaction(this.id, this.timestamp, this.amount, this.type);

  final String id;
  final DateTime timestamp;
  final double amount;
  final String type;

  @override
  int compareTo(Transaction other) {
    // Sort by timestamp (most recent first)
    return other.timestamp.compareTo(timestamp);
  }
}

void analyzeTransactions() {
  final transactions = [
    Transaction('T001', DateTime(2024, 1, 15), 100.0, 'credit'),
    Transaction('T002', DateTime(2024, 1, 10), -50.0, 'debit'),
    Transaction('T003', DateTime(2024, 1, 20), 200.0, 'credit'),
  ];

  // Sort transactions by date
  final sortedTransactions = List<Transaction>.from(transactions);
  sortedTransactions.sort();

  print('Recent transactions:');
  for (final tx in sortedTransactions) {
    print('  ${tx.id}: \$${tx.amount} on ${tx.timestamp.day}/${tx.timestamp.month}');
  }

  // Find specific transaction using binary search
  sortedTransactions.sort((a, b) => a.amount.compareTo(b.amount));

  final targetAmount = 100.0;
  final found = sortedTransactions.where((tx) => tx.amount == targetAmount).toList();
  print('Transactions with amount \$${targetAmount}: $found');
}
```

## 🔄 Running Examples

ลองรัน examples:

```bash
# Clone และ setup
git clone <your-repo>
cd algomate

# Run custom objects example
dart run example/working_custom_objects_example.dart

# Run specific examples (เมื่อสร้างแล้ว)
dart run example/ecommerce_example.dart
dart run example/task_management_example.dart
dart run example/financial_analysis_example.dart
```

## 📊 Performance Benchmarks

เมื่อรัน examples คุณจะเห็น performance metrics:

```
📊 BASIC SORTING WITH ALGOMATE
==================================================

🎯 Small dataset (5 elements):
✅ Algorithm used: insertion_sort
⏱️ Time taken: 179μs
📊 Performance: 27,933 elements/sec

🎯 Medium dataset (100 elements):
✅ Algorithm used: merge_sort
⏱️ Time taken: 177μs
📊 Performance: 564,972 elements/sec

🎯 Large dataset (1000 elements):
✅ Algorithm used: merge_sort
⏱️ Time taken: 829μs
📊 Performance: 1,206,273 elements/sec
```

## 🎉 ยินดีด้วย!

ตอนนี้คุณสามารถใช้ AlgoMate กับ custom objects และ data structures ได้แล้ว!

สำหรับการใช้งานเพิ่มเติม ดูได้ที่:

- [AlgoMate Documentation](README.md)
- [API Reference](lib/algomate.dart)
- [More Examples](example/)

Happy coding! 🚀
