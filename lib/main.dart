import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';


import 'in_app_purchase_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  InAppPurchaseService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("In app purchase demo"),
      ),
      body: ValueListenableBuilder<List<ProductDetails>>(
        valueListenable: InAppPurchaseService.instance.productsNotifier,
        builder: (context, products, child) {
          if (products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ValueListenableBuilder<Set<String>>(
            valueListenable: InAppPurchaseService.instance.purchasedProductIds,
            // ✅ Listen for purchases
            builder: (context, purchasedProductIds, child) {
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  ProductDetails productDetails = products[index];
                  bool isPurchased = purchasedProductIds
                      .contains(productDetails.id); // ✅ Check if purchased
                  return ListTile(
                    title: Text(productDetails.title),
                    subtitle: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(productDetails.description),
                            Text(productDetails.price),
                          ],
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () => InAppPurchaseService.instance
                              .buySubscription(productDetails),
                          child: isPurchased
                              ? Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.green,
                            ),
                            child: const Text(
                              'Subscribed',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          )
                              : Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.blueAccent,
                            ),
                            child: const Text(
                              'Buy',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

