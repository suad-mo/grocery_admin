import 'package:flutter/material.dart';
import 'package:grocery_admin/responsive.dart';
import 'package:grocery_admin/widgets/grid_products.dart';
import 'package:grocery_admin/widgets/orders_list.dart';
import 'package:grocery_admin/widgets/products_widget.dart';
import 'package:provider/provider.dart';

import '../consts/constants.dart';
import '../controllers/MenuController.dart';
import '../services/utils.dart';
import '../widgets/header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    return SafeArea(
      child: SingleChildScrollView(
        controller: ScrollController(),
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              fct: () {
                context.read<MenuController>().controlDashboarkMenu();
              },
            ),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  // flex: 5,
                  child: Column(
                    children: [
                      Responsive(
                        mobile: ProductGridWidget(
                          crossAxisCount: size.width < 650 ? 2 : 4,
                          childAspectRatio:
                              size.width < 650 && size.width > 350 ? 1.1 : 0.8,
                        ),
                        desktop: ProductGridWidget(
                          childAspectRatio: size.width < 1400 ? 0.8 : 1.05,
                        ),
                      ),
                      const OrdersList(),
                      // MyProductsHome(),
                      // SizedBox(height: defaultPadding),
                      // OrdersScreen(),
                      // ProductWidget(),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
