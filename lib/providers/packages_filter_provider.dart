import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/package_model.dart';
import 'packages_provider.dart';

class PackageFilterState {
  final double maxPrice;
  final String? packageType; // hajj, umrah, air_ticket, or null for all
  final String? badge;
  final int? maxDurationDays;
  final String sortBy; // price_asc, price_desc, duration_desc

  PackageFilterState({
    this.maxPrice = 700000.0,
    this.packageType,
    this.badge,
    this.maxDurationDays,
    this.sortBy = 'price_asc',
  });

  PackageFilterState copyWith({
    double? maxPrice,
    String? packageType,
    String? badge,
    int? maxDurationDays,
    String? sortBy,
  }) {
    return PackageFilterState(
      maxPrice: maxPrice ?? this.maxPrice,
      packageType: packageType != null ? (packageType == 'all' ? null : packageType) : this.packageType,
      badge: badge != null ? (badge == 'all' ? null : badge) : this.badge,
      maxDurationDays: maxDurationDays,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  PackageFilterState reset() {
    return PackageFilterState();
  }
}

class PackageFilterNotifier extends StateNotifier<PackageFilterState> {
  PackageFilterNotifier() : super(PackageFilterState());

  void setPackageType(String? type) {
    state = state.copyWith(packageType: type ?? 'all');
  }

  void setMaxPrice(double price) {
    state = state.copyWith(maxPrice: price);
  }

  void setMaxDuration(int? days) {
    state = PackageFilterState(
      maxPrice: state.maxPrice,
      packageType: state.packageType,
      badge: state.badge,
      maxDurationDays: days,
      sortBy: state.sortBy,
    );
  }

  void setBadge(String? badge) {
    state = state.copyWith(badge: badge ?? 'all');
  }

  void setSortBy(String sort) {
    state = state.copyWith(sortBy: sort);
  }

  void resetFilters() {
    state = state.reset();
  }
}

final packageFilterProvider =
    StateNotifierProvider<PackageFilterNotifier, PackageFilterState>((ref) {
  return PackageFilterNotifier();
});

final filteredPackagesProvider = Provider<List<PackageModel>>((ref) {
  final filter = ref.watch(packageFilterProvider);
  final asyncPackages = ref.watch(packagesProvider);

  return asyncPackages.maybeWhen(
    data: (packages) {
      var list = packages.where((p) {
        if (p.priceInr > filter.maxPrice) return false;
        if (filter.packageType != null && filter.packageType!.isNotEmpty) {
          if (p.type.toLowerCase() != filter.packageType!.toLowerCase()) return false;
        }
        if (filter.badge != null && filter.badge!.isNotEmpty) {
          if (p.badge == null || !p.badge!.toLowerCase().contains(filter.badge!.toLowerCase())) {
            return false;
          }
        }
        if (filter.maxDurationDays != null && filter.maxDurationDays! > 0) {
          if (p.durationDays > filter.maxDurationDays!) return false;
        }
        return true;
      }).toList();

      if (filter.sortBy == 'price_asc') {
        list.sort((a, b) => a.priceInr.compareTo(b.priceInr));
      } else if (filter.sortBy == 'price_desc') {
        list.sort((a, b) => b.priceInr.compareTo(a.priceInr));
      } else if (filter.sortBy == 'duration_desc') {
        list.sort((a, b) => b.durationDays.compareTo(a.durationDays));
      }

      return list;
    },
    orElse: () => [],
  );
});
