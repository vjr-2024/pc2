import '../app/data/models/category_model.dart';
import '../app/data/models/product_model.dart';
import 'constants.dart';

class DummyHelper {
  const DummyHelper._();

  static const _description =
      'Ginger is a flowering plant whose rhizome, ginger root or ginger, is widely used as a spice and a folk medicine.';

  static const _description_prcp =
      'Pureo Chilli powder is made from fine quality sorted chillies ';

  static const _description_pcp =
      'Pureo coriander powder is made from fine quality sorted coriander seeds ';

  static const _description_ptp =
      'Pureo turmeric powder is made from fine quality sorted turmeric bulbs ';

  static List<Map<String, String>> cards = [
    {'icon': Constants.lotus, 'title': '100%', 'subtitle': 'Organic'},
    {'icon': Constants.calendar, 'title': '1 Year', 'subtitle': 'Expiration'},
    {'icon': Constants.favourites, 'title': '4.8 (256)', 'subtitle': 'Reviews'},
    {'icon': Constants.matches, 'title': '80 kcal', 'subtitle': '100 Gram'},
  ];

  static List<CategoryModel> categories = [
    CategoryModel(id: '1', name: 'Fruits', image: Constants.apple),
    CategoryModel(id: '2', name: 'Vegetables', image: Constants.broccoli),
    CategoryModel(id: '3', name: 'Spices', image: Constants.spices),
    CategoryModel(id: '4', name: 'Dairy', image: Constants.dairy),
    CategoryModel(id: '5', name: 'Oils', image: Constants.oils),
    CategoryModel(id: '6', name: 'Rice', image: Constants.rice),
    CategoryModel(id: '7', name: 'Pulses', image: Constants.pulses),
    CategoryModel(id: '8', name: 'Flours', image: Constants.flours),
    CategoryModel(id: '9', name: 'ReadyToEat', image: Constants.noodles),
  ];
/*
  static List<ProductModel> products = [
    ProductModel(
      id: '1',
      image: Constants.bellPepper,
      name: 'Bell Pepper Red',
      ctgry: 'Vegetables',
      pksz: '500g',
      quantity: 0,
      price: 5.99,
      description: _description,
    ),
    ProductModel(
      id: '2',
      image: Constants.lambMeat,
      name: 'Lamb Meat',
      ctgry: 'Vegetables',
      pksz: '500g',
      quantity: 0,
      price: 44.99,
      description: _description,
    ),
    ProductModel(
      id: '3',
      image: Constants.ginger,
      name: 'Arabic Ginger',
      ctgry: 'Vegetables',
      pksz: '500g',
      quantity: 0,
      price: 4.99,
      description: _description,
    ),
    ProductModel(
      id: '4',
      image: Constants.cabbage,
      name: 'Fresh Lettuce',
      ctgry: 'Vegetables',
      pksz: '500g',
      quantity: 0,
      price: 3.99,
      description: _description,
    ),
    ProductModel(
      id: '5',
      image: Constants.pumpkin,
      name: 'Butternut Squash',
      ctgry: 'Vegetables',
      pksz: '500g',
      quantity: 0,
      price: 8.99,
      description: _description,
    ),
    ProductModel(
      id: '6',
      image: Constants.carrot,
      name: 'Organic Carrots',
      ctgry: 'Vegetables',
      pksz: '500g',
      quantity: 0,
      price: 5.99,
      description: _description,
    ),
    ProductModel(
      id: '7',
      image: Constants.cauliflower,
      name: 'Fresh Broccoli',
      ctgry: 'Vegetables',
      pksz: '500g',
      quantity: 0,
      price: 3.99,
      description: _description,
    ),
    ProductModel(
      id: '8',
      image: Constants.tomatoes,
      name: 'Cherry Tomato',
      ctgry: 'Fruits',
      pksz: '500g',
      quantity: 0,
      price: 5.99,
      description: _description,
    ),
    ProductModel(
      id: '9',
      image: Constants.spinach,
      name: 'Fresh Spinach',
      ctgry: 'Vegetables',
      pksz: '500g',
      quantity: 0,
      price: 2.99,
      description: _description,
    ),
    ProductModel(
      id: '10',
      image: Constants.redchillipowder,
      name: 'PureO Red Chilli Powder',
      ctgry: 'Spices',
      pksz: '500g',
      quantity: 0,
      price: 120,
      description: _description_prcp,
    ),
    ProductModel(
      id: '11',
      image: Constants.corianderpowder,
      name: 'PureO Red Chilli Powder',
      ctgry: 'Spices',
      pksz: '500g',
      quantity: 0,
      price: 70,
      description: _description_pcp,
    ),
    ProductModel(
      id: '12',
      image: Constants.turmericpowder,
      name: 'PureO Red Chilli Powder',
      ctgry: 'Spices',
      pksz: '500g',
      quantity: 0,
      price: 100,
      description: _description_ptp,
    ),
    ProductModel(
      id: '13',
      image: Constants.freedomsunfloweroil,
      name: 'Freedom Sunflower Oil',
      ctgry: 'Oils',
      pksz: '1L',
      quantity: 0,
      price: 135,
      description: _description,
    ),
  ];
  */
}
