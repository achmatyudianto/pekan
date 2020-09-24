class PekanModel {
  final int id;
  final int userID;
  final String type;
  final double amount;
  final String description;
  final String created;

  PekanModel(
    this.id,
    this.userID,
    this.amount,
    this.type,
    this.description,
    this.created,
  );
}
