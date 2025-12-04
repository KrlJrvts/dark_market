class Auction {
  final String id;
  final String title;
  final String sellerId;
  final String? sellerName;  // <-- ADD THIS
  final int? highestBid;
  final String? highestBidId;
  final int buyout;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isClosed;

  Auction({
    required this.id,
    required this.title,
    required this.sellerId,
    this.sellerName,  // <-- ADD THIS
    required this.buyout,
    required this.createdAt,
    this.highestBid,
    this.highestBidId,
    this.imageUrl,
    this.isClosed = false,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'sellerId': sellerId,
    'sellerName': sellerName,  // <-- ADD THIS
    'highestBid': highestBid,
    'highestBidId': highestBidId,
    'buyout': buyout,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
    'isClosed': isClosed,
  };

  factory Auction.fromDoc(String id, Map<String, dynamic> data) => Auction(
    id: id,
    title: data['title'] ?? '',
    sellerId: data['sellerId'] ?? '',
    sellerName: data['sellerName'] as String?,  // <-- ADD THIS
    highestBid: data['highestBid'] != null ? data['highestBid'] as int : null,
    highestBidId: data['highestBidId'] != null ? data['highestBidId'] as String : null,
    buyout: data['buyout'] ?? 0,
    imageUrl: data['imageUrl'] as String?,
    createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    isClosed: (data['isClosed'] as bool?) ?? false,
  );
}