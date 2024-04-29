--------------------------------------------------------
--  DDL for Package Body PON_BUYER_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_BUYER_SUMMARY_PKG" AS
-- $Header: PONBUSUB.pls 120.1 2005/07/27 09:05:28 rpatel noship $

PROCEDURE calculate_summary
(
 P_AUCTION_ID in NUMBER,
 P_BATCH_ID OUT NOCOPY	NUMBER
)
IS
-- select only awardable group types for autoaward selection
 CURSOR c_auction_item (v_auction_header_id number) IS
    SELECT line_number, nvl(quantity,1) quantity, current_price
     FROM pon_auction_item_prices_all
     WHERE auction_header_id =  v_auction_header_id
     AND group_type IN ('LOT', 'LINE', 'GROUP_LINE');
--
 CURSOR c_bid_item (v_auction_header_id number, v_auction_line_number number) IS
 SELECT bl.price,
	   bl.quantity quantity,
	   bh.bid_number,
	   bh.trading_partner_name,
	   bh.trading_partner_id,
	   bh.trading_partner_contact_id,
	   bl.rank
      FROM pon_bid_headers bh,
           pon_bid_item_prices bl,
           pon_auction_headers_all ah,
           po_vendors pv,
           hz_parties hp
     WHERE ah.auction_header_id = bh.auction_header_id and
       bh.auction_header_id = bl.auction_header_id
       and bh.bid_number = bl.bid_number
       and bh.bid_status = 'ACTIVE'
       and bh.auction_header_id = v_auction_header_id
       and bl.auction_line_number = v_auction_line_number
       and nvl(bh.SHORTLIST_FLAG, 'Y') = 'Y'
       and bh.trading_partner_id = hp.party_id
       and hp.party_type = 'ORGANIZATION'
       and hp.party_id = pv.party_id
       and (pv.end_date_active IS NULL OR pv.end_date_active > SYSDATE)
     ORDER BY decode(ah.bid_ranking, 'PRICE_ONLY', 1/bl.price, nvl(bl.total_weighted_score,0)/bl.price) desc ,bl.publish_date asc;

v_qty_remaining NUMBER;
v_price         NUMBER;
v_quantity      NUMBER;
v_tp_id         NUMBER;
v_tp_name       VARCHAR2(255);
v_auction_type VARCHAR2(25);

v_bid_number	NUMBER;
v_qty_award     NUMBER;
v_batch_id	NUMBER;

v_tp_contact_id NUMBER;
v_rank          NUMBER;
--
BEGIN
--
    select pon_auction_summary_s.nextval
    into   v_batch_id
    from   dual;
--
    SELECT nvl(auction_type, 'REVERSE') INTO v_auction_type
    FROM pon_auction_headers_all
    WHERE auction_header_id = P_AUCTION_ID;
--
--
   FOR auction_item IN c_auction_item (p_auction_id) LOOP
      v_qty_remaining := auction_item.quantity;

	  OPEN c_bid_item (p_auction_id, auction_item.line_number);

        fetch c_bid_item into
		  v_price,
		  v_quantity,
		  v_bid_number,
		  v_tp_name,
		  v_tp_id,
                  v_tp_contact_id,
                  v_rank;
--
	  while (c_bid_item%FOUND) loop

	   if (v_qty_remaining > v_quantity ) then
		v_qty_award := nvl(v_quantity,1);
	   else
		v_qty_award := v_qty_remaining;
       end if;
--
        insert into pon_auction_summary
		(batch_id,
	 	 auction_id,
		 line_number,
                 bid_number,
		 trading_partner_name,
		 trading_partner_id,
		 trading_partner_contact_id,
		 award_quantity,
		 bid_price,
		 auction_price,
		 response_quantity,
		 rank)
           values (v_batch_id,
	 	   p_auction_id,
		   auction_item.line_number,
                   v_bid_number,
		   v_tp_name,
		   v_tp_id,
		   v_tp_contact_id,
		   v_qty_award,
		   v_price,
		   auction_item.current_price,
		   v_quantity,
		   v_rank);
--
	   v_qty_remaining := v_qty_remaining - v_qty_award;
--
           fetch c_bid_item into v_price,
			      v_quantity,
			      v_bid_number,
			      v_tp_name,
			      v_tp_id,
			      v_tp_contact_id,
			      v_rank;
--
        end loop;
--
	close c_bid_item;
--
    END LOOP;
--
    insert into pon_auction_summary
          (batch_id,
	   auction_id,
           line_number,
           bid_number,
	   trading_partner_name,
	   trading_partner_id,
	   trading_partner_contact_id,
	   award_quantity,
           bid_price,
	   auction_price,
	   response_quantity)
    select v_batch_id,
	   p_auction_id,
           0,
           0,
           nvl(bp.trading_partner_name,bp.new_supplier_name),
           bp.trading_partner_id,
	   bp.trading_partner_contact_id,
	   0,
	   0,
	   0,
	   0
      from pon_bidding_parties bp
     where auction_header_id = p_auction_id and
       not exists (select 'exist' from pon_auction_summary where
                       trading_partner_id = bp.trading_partner_id and
		       batch_id = v_batch_id and
		       auction_header_id = p_auction_id);
--
    commit;
--
    P_BATCH_ID := v_batch_id;
END;

PROCEDURE bid_count_info (P_AUCTION_ID 		IN 	NUMBER,
			  P_NO_BID_OPEN		OUT	NOCOPY	NUMBER,
			  P_NO_BID_CLOSED	OUT  	NOCOPY	NUMBER,
			  P_PART_BID_OPEN	OUT	NOCOPY	NUMBER,
			  P_PART_BID_CLOSED	OUT  	NOCOPY	NUMBER,
			  P_FULL_BID_OPEN	OUT	NOCOPY	NUMBER,
			  P_FULL_BID_CLOSED	OUT  	NOCOPY	NUMBER) IS


BEGIN

    select count(*)
      into p_no_bid_open
      from pon_auction_item_prices_all poi, pon_auction_headers_all poh
     where poi.auction_header_id = p_auction_id
       and poh.auction_header_id = poi.auction_header_id
       and poh.open_bidding_date < sysdate
       and nvl(poi.close_bidding_date, poh.close_bidding_date) > sysdate
       and nvl(poi.number_of_bids,0) = 0 ;

    select count(*)
      into p_no_bid_closed
      from pon_auction_item_prices_all poi, pon_auction_headers_all poh
     where poi.auction_header_id = p_auction_id
       and poh.auction_header_id = poi.auction_header_id
       and poh.open_bidding_date < sysdate
       and nvl(poi.close_bidding_date, poh.close_bidding_date) <= sysdate
       and nvl(poi.number_of_bids,0) = 0 ;

    select count(*)
      into p_part_bid_open
      from pon_auction_item_prices_all poi, pon_auction_headers_all poh
     where poi.auction_header_id = p_auction_id
       and poh.auction_header_id = poi.auction_header_id
       and poh.open_bidding_date < sysdate
       and nvl(poi.close_bidding_date, poh.close_bidding_date) > sysdate
       and nvl(poi.number_of_bids,0) > 0
       and poi.quantity >
             (select sum(pbi.quantity)
                from pon_bid_item_prices pbi
               where pbi.auction_header_id = p_auction_id
                 and pbi.line_number = poi.line_number);

    select count(*)
      into p_part_bid_closed
      from pon_auction_item_prices_all poi, pon_auction_headers_all poh
     where poi.auction_header_id = p_auction_id
       and poh.auction_header_id = poi.auction_header_id
       and poh.open_bidding_date < sysdate
       and nvl(poi.close_bidding_date, poh.close_bidding_date) <= sysdate
       and nvl(poi.number_of_bids,0) > 0
       and poi.quantity >
             (select sum(pbi.quantity)
                from pon_bid_item_prices pbi
               where pbi.auction_header_id = p_auction_id
                 and pbi.line_number = poi.line_number);

    select count(*)
      into p_full_bid_open
      from pon_auction_item_prices_all poi, pon_auction_headers_all poh
     where poi.auction_header_id = p_auction_id
       and poh.auction_header_id = poi.auction_header_id
       and poh.open_bidding_date < sysdate
       and nvl(poi.close_bidding_date, poh.close_bidding_date) > sysdate
       and nvl(poi.number_of_bids,0) > 0
       and poi.quantity <=
             (select sum(pbi.quantity)
                from pon_bid_item_prices pbi
               where pbi.auction_header_id = p_auction_id
                 and pbi.line_number = poi.line_number);



    select count(*)
      into p_full_bid_closed
      from pon_auction_item_prices_all poi, pon_auction_headers_all poh
     where poi.auction_header_id = p_auction_id
       and poh.open_bidding_date < sysdate
       and poh.auction_header_id = poi.auction_header_id
       and nvl(poi.close_bidding_date, poh.close_bidding_date) <= sysdate
       and nvl(poi.number_of_bids,0) > 0
       and poi.quantity <=
             (select sum(pbi.quantity)
                from pon_bid_item_prices pbi
               where pbi.auction_header_id = p_auction_id
                 and pbi.line_number = poi.line_number);

END;
--
END PON_BUYER_SUMMARY_PKG;

/
