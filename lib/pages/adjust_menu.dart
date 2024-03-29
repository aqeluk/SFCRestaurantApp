import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:socket_io_example/main.dart';

final _logger = Logger('AdjustMenuPage');

class AdjustMenuPage extends StatefulWidget {
  final VoidCallback onBack;

  const AdjustMenuPage({super.key, required this.onBack});

  @override
  State<AdjustMenuPage> createState() => _AdjustMenuPageState();
}

class _AdjustMenuPageState extends State<AdjustMenuPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<MenuCategory>? categories;

  @override
  void initState() {
    super.initState();
    categories = [];
    _fetchCategories();
  }

  Future<dynamic> _fetchCategories() async {
    var kebabs = await _fetchKebabs();
    var periPeriChicken = await _fetchPeriPeriChicken();
    var southernFriedChicken = await _fetchSouthernFriedChicken();
    var wraps = await _fetchWraps();
    var burgers = await _fetchBurgers();
    var pizzas = await _fetchPizzas();
    var potatoesAndRibs = await _fetchPotatoesAndRibs();
    var sides = await _fetchSides();
    var desserts = await _fetchDesserts();
    var softDrinks = await _fetchSoftDrinks();
    var alcoholicDrinks = await _fetchAlcoholicDrinks();
    var mealDeals = await _fetchMealDeals();
    var genericMeals = await _fetchGenericMeals();
    var pizzaToppings = await _fetchPizzaToppings();
    var salads = await _fetchSalads();
    var sauces = await _fetchSauces();
    var extras = await _fetchExtras();
    var specificMeals = await _fetchSpecificMeals();

    setState(() {
      categories = [
        MenuCategory(name: 'Kebabs', items: kebabs),
        MenuCategory(name: 'Peri Peri Chicken', items: periPeriChicken),
        MenuCategory(
            name: 'Southern Fried Chicken', items: southernFriedChicken),
        MenuCategory(name: 'Wraps', items: wraps),
        MenuCategory(name: 'Burgers', items: burgers),
        MenuCategory(name: 'Pizzas', items: pizzas),
        MenuCategory(name: 'Potatoes and Ribs', items: potatoesAndRibs),
        MenuCategory(name: 'Sides', items: sides),
        MenuCategory(name: 'Desserts', items: desserts),
        MenuCategory(name: 'Soft Drinks', items: softDrinks),
        MenuCategory(name: 'Alcoholic Drinks', items: alcoholicDrinks),
        MenuCategory(name: 'Meal Deals', items: mealDeals),
        MenuCategory(name: 'Pizza Toppings', items: pizzaToppings),
        MenuCategory(name: 'Salads', items: salads),
        MenuCategory(name: 'Sauces', items: sauces),
        MenuCategory(name: 'Extras', items: extras),
        MenuCategory(name: 'Meal Types', items: specificMeals),
        MenuCategory(name: 'Generic Meal Deals', items: genericMeals),
      ];
      _tabController = TabController(length: categories!.length, vsync: this);
    });
  }

  Future<List<MenuItem>> _fetchKebabs() async {
    try {
      var response =
          await supabase.from('Product').select().eq('catSlug', 'kebabs');
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Product',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchPeriPeriChicken() async {
    try {
      var response =
          await supabase.from('Product').select().eq('catSlug', 'peri-peri');
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Product',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchSouthernFriedChicken() async {
    try {
      var response =
          await supabase.from('Product').select().eq('catSlug', 'chicken');
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Product',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchWraps() async {
    try {
      var response =
          await supabase.from('Product').select().eq('catSlug', 'wraps');
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Product',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchBurgers() async {
    try {
      var response =
          await supabase.from('Product').select().eq('catSlug', 'burgers');
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Product',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchPizzas() async {
    try {
      var response =
          await supabase.from('Product').select().eq('catSlug', 'pizzas');
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Product',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchPotatoesAndRibs() async {
    try {
      var response = await supabase
          .from('Product')
          .select()
          .eq('catSlug', 'potatoes-ribs');
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Product',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchSides() async {
    try {
      var response =
          await supabase.from('Product').select().eq('catSlug', 'sides');
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Product',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchDesserts() async {
    try {
      var response =
          await supabase.from('Product').select().eq('catSlug', 'desserts');
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Product',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchSoftDrinks() async {
    try {
      var response =
          await supabase.from('Product').select().eq('catSlug', 'drinks');
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Product',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchAlcoholicDrinks() async {
    try {
      var response = await supabase
          .from('Product')
          .select()
          .eq('catSlug', 'alcoholic-drinks');
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Product',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchMealDeals() async {
    try {
      var response =
          await supabase.from('Product').select().eq('catSlug', 'meal-deals');
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Product',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchGenericMeals() async {
    try {
      var response = await supabase.from('GenericMeal').select();
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'GenericMeal',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchPizzaToppings() async {
    try {
      var response = await supabase.from('PizzaToppings').select();
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'PizzaToppings',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchSalads() async {
    try {
      var response = await supabase.from('Salad').select();
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Salad',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchSauces() async {
    try {
      var response = await supabase.from('Sauce').select();
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'Sauce',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchExtras() async {
    try {
      var response = await supabase.from('SpecificExtra').select();
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'SpecificExtra',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  Future<List<MenuItem>> _fetchSpecificMeals() async {
    try {
      var response = await supabase.from('SpecificMeal').select();
      return response.map((productMap) {
        return MenuItem(
          id: productMap['id'],
          name: productMap['title'],
          table: 'SpecificMeal',
          isAvailable: productMap['isAvailable'],
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  void onBack() {
    widget.onBack();
  }

  void _toggleMenuItem(MenuItem item) async {
    try {
      // Update in the database
      await _updateItemAvailability(item);

      // Toggle the availability
      setState(() {
        item.isAvailable = !item.isAvailable;
      });
    } catch (error) {
      _logger.severe("Error updating item availability: $error");
    }
  }

  Future<void> _updateItemAvailability(MenuItem item) async {
    try {
      await supabase
          .from(item.table)
          .update({'isAvailable': !item.isAvailable}).eq('id', item.id);
    } catch (error) {
      // Handle any errors here
      _logger.severe("Error updating item: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adjust Menu"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        bottom: _tabController == null || categories == null
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: categories!
                    .map((category) => Tab(
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 100),
                            child: Center(child: Text(category.name)),
                          ),
                        ))
                    .toList(),
              ),
      ),
      body: _tabController == null || categories == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: categories!.map((category) {
                return ListView.builder(
                  itemCount: category.items.length,
                  itemBuilder: (context, index) {
                    final item = category.items[index];
                    return ListTile(
                      title: Text(item.name),
                      trailing: Switch(
                        value: item.isAvailable,
                        onChanged: (_) => _toggleMenuItem(item),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}

class MenuCategory {
  final String name;
  final List<MenuItem> items;

  MenuCategory({required this.name, required this.items});
}

class MenuItem {
  final String id;
  final String name;
  final String table;
  bool isAvailable;

  MenuItem(
      {required this.id,
      required this.name,
      required this.table,
      this.isAvailable = true});
}
