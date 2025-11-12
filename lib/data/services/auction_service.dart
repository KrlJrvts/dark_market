import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auction.dart';

class AuctionService {
  // CHANGED: type the collection
  final CollectionReference<Map<String, dynamic>> _col =
  FirebaseFirestore.instance.collection('auctions');

  Stream<List<Auction>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Auction.fromDoc(d.id, d.data())).toList());

  Future<String> add(Auction auction) async {
    final document = await _col.add(auction.toMap());
    return document.id;
  }

  Future<void> update(Auction auction) async =>
      _col.doc(auction.id).update(auction.toMap());

  Future<void> placeBid({
    required String auctionId,
    required String bidderId,
    required int amount,
  }) async {
    // CHANGED: typed doc ref
    final DocumentReference<Map<String, dynamic>> ref = _col.doc(auctionId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snap = await transaction.get(ref);

      // CHANGED: no cast; data() is Map<String,dynamic>?
      final data = snap.data();
      if (data == null) {
        throw Exception('Auction not found');
      }

      // Optional guard: ignore bids if closed
      if (data['isClosed'] == true) return; // CHANGED (optional)

      final int current = (data['highestBid'] as int?) ?? 0;
      final int buyout  = (data['buyout'] as int?) ?? 0;

      if (amount > current) {
        final int newBid = (buyout > 0 && amount >= buyout) ? buyout : amount;

        transaction.update(ref, {
          'highestBid': newBid,
          'highestBidId': bidderId,
          if (buyout > 0 && amount >= buyout) 'isClosed': true,
        });
      }
    });
  }
}
