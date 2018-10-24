class CardViewModel {
  final String slNo;
  final String question;
  final String optionOne;
  final String optionTwo;
  final String optionThree;
  final String optionFour;
  final String imagePath;

  CardViewModel(
      {
        this.slNo = "0",
        this.question,
      this.optionOne,
      this.optionTwo,
      this.optionThree,
      this.optionFour,
      this.imagePath});
}

class UserRespModel {
  final String question;
  final String optionOne;
  final String optionTwo;
  final String optionThree;
  final String optionFour;
  final int response;

  UserRespModel(
      {this.question,
      this.optionOne,
      this.optionTwo,
      this.optionThree,
      this.optionFour,
      this.response});
}
