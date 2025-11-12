class Auction {
  final String id;
  final String title;
  final String sellerId;
  final int? highestBid;
  final String? highestBidId; // who made the highest bid
  final int buyout;
  final String? imageUrl;
  final DateTime createdAt;

  Auction({
    required this.id,
    required this.title,
    required this.sellerId,
    required this.buyout,
    required this.createdAt,
    this.highestBid,
    this.highestBidId,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'sellerId': sellerId,
    'highestBid': highestBid,
    'highestBidId': highestBidId,
    'buyout': buyout,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Auction.fromDoc(String id, Map<String, dynamic> data) => Auction(
    id: id,
    title: data['title'] ?? '',
    sellerId: data['sellerId'] ?? '',
    highestBid: data['highestBid'] != null ? data['highestBid'] as int : null,
    highestBidId: data['highestBidId'] != null ? data['highestBidId'] as String : null,
    buyout: data['buyout'] ?? 0,
    imageUrl: data['imageUrl'] as String?,
    createdAt:
    DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
  );
}
