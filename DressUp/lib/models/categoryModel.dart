class Category {
  String? title;
  String? image;

  Category({required this.title, this.image});
}

List<Category> categories = [
  Category(title: "T-Shirts", image: 'assets/c_images/grocery.png'),
  Category(title: "Dress", image: 'assets/c_images/electronics.png'),
  Category(title: "Shoes", image: 'assets/c_images/cosmatics.png'),
  Category(title: "Accessories", image: 'assets/c_images/pharmacy.png'),
  Category(title: "Trousers", image: 'assets/c_images/garments.png'),
];
