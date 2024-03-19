class UnbordingContent {
  String image;
  String title;
  String description;
  UnbordingContent(
      {required this.image, required this.title, required this.description});
}

List<UnbordingContent> contents = [
  UnbordingContent(
      image: "images/screen1.png",
      title: "Select Your Favourite Food\nBest Quality",
      description: "Pick your food from our menu"),
  UnbordingContent(
      image: "images/screen2.png",
      title: "Cash on delivery is available\nOnline payment is also available",
      description: "Easy and Online Payment"),
  UnbordingContent(
      image: "images/screen3.png",
      title: "Quick Delivery at Your\n             Doorstep",
      description: "Deliver your food at your Doorstep"),
];
