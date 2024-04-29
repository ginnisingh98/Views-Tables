--------------------------------------------------------
--  DDL for Package Body PON_AUCTION_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_AUCTION_HEADERS_PKG" AS
-- $Header: PONAUCHB.pls 120.48.12010000.14 2014/04/02 06:56:54 gkuncham ship $
--

FUNCTION validate_price_precision(p_number IN NUMBER, p_precision IN NUMBER) RETURN BOOLEAN;
FUNCTION validate_currency_precision(p_number IN NUMBER, p_precision IN NUMBER) RETURN BOOLEAN;

--
-- LOGGING FEATURE
--
-- global variables used for logging
--
g_fnd_debug     CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name      CONSTANT VARCHAR2(50) := 'auctionHeadersPkg';
g_module_prefix CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';

-- (Raja) global variables used to store the bid numbers generated per publish
g_bidsGenerated fnd_table_of_number;
g_bidsGeneratedCount NUMBER;
--
--private helper procedure for logging
PROCEDURE print_log(p_module   IN    VARCHAR2,
                   p_message  IN    VARCHAR2)
IS
BEGIN

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string(log_level => FND_LOG.level_statement,
                        module  =>  g_module_prefix || p_module,
                        message  => p_message);
      END IF;


END;

-- FUNCTION BETTER_PRICE
--
-- this function returns whether x_price1 is better than x_price2
-- i.e. in reverse auction if (x_price1 < x_price2)
-- i.e. in forward auction if (x_price1 > x_price2)
--
FUNCTION better_price(x_auction_type VARCHAR2,
		      x_price1 IN NUMBER,
		      x_price2 IN NUMBER)
RETURN BOOLEAN IS
BEGIN

   if (x_auction_type = 'REVERSE') then
      return x_price1 < x_price2;
   else
      return x_price1 > x_price2;
   end if;
END;


--========================================================================
-- PROCEDURE : set_pf_price_components        PRIVATE
--             set_pf_price_components_auto   PRIVATE
-- PARAMETERS:
-- VERSION   : current version         1.x
--             initial version         1.0
-- COMMENT   :
--             This procedure will be used to populate columns that store
--             components of a response price on a line and on its price
--             breaks based on the price factors that apply to the line.
--========================================================================
PROCEDURE set_pf_price_components (p_bid_number      IN NUMBER,
                                   p_pf_type_allowed IN VARCHAR2,
                                   p_price_tiers_indicator IN VARCHAR2) IS
  l_api_name CONSTANT VARCHAR2(30) := 'add_hidden_price_factors';
BEGIN

  print_log (l_api_name, 'p_bid_number = ' || p_bid_number ||
               ', p_pf_type_allowed = ' || p_pf_type_allowed ||
               ', p_price_tiers_indicator = ' || p_price_tiers_indicator);

  IF (p_pf_type_allowed = 'NONE') THEN
    UPDATE
      pon_bid_item_prices pbip
    SET
      pbip.per_unit_price_component = pbip.unit_price,
      pbip.fixed_amount_component = 0
    WHERE
      pbip.bid_number = p_bid_number;

  ELSE
    UPDATE
      pon_bid_item_prices pbip
    SET
      pbip.per_unit_price_component = pbip.unit_price +
        nvl((
             SELECT
               SUM(
                 DECODE (pbpe.pricing_basis,
                   'PER_UNIT',
                     pbpe.auction_currency_value,
                   'PERCENTAGE',
                     pbpe.auction_currency_value / 100 * pbip.unit_price, 0))
             FROM
               pon_bid_price_elements pbpe
             WHERE
               pbpe.bid_number = pbip.bid_number
               AND pbpe.line_number = pbip.line_number
               AND pbpe.pricing_basis IN ('PER_UNIT', 'PERCENTAGE')
               AND pbpe.sequence_number <> -10), 0),
      pbip.fixed_amount_component =
        nvl((
            SELECT
              SUM(pbpe.auction_currency_value)
            FROM
              pon_bid_price_elements pbpe
            WHERE
              pbpe.bid_number = pbip.bid_number
              AND pbpe.line_number = pbip.line_number
              AND pbpe.pricing_basis = 'FIXED_AMOUNT'
              AND pbpe.sequence_number <> -10), 0)
    WHERE
      pbip.bid_number = p_bid_number;
  END IF;

  print_log (l_api_name, 'Done updating pon_bid_item_prices, now updating pon_bid_shipments');

  IF (p_price_tiers_indicator = 'QUANTITY_BASED') THEN
    UPDATE
      pon_bid_shipments pbs
    SET
      pbs.per_unit_price_component = pbs.unit_price +
        nvl((
          SELECT SUM(DECODE(pbpe.pricing_basis,
                              'PER_UNIT', pbpe.auction_currency_value,
                              'PERCENTAGE', pbpe.auction_currency_value / 100 * pbs.unit_price, 0))
          FROM
            pon_bid_price_elements pbpe
          WHERE
            pbpe.bid_number = pbs.bid_number
            AND pbpe.line_number = pbs.line_number
            AND pbpe.pricing_basis IN ('PER_UNIT', 'PERCENTAGE')
            AND pbpe.sequence_number <> -10), 0)
    WHERE
      pbs.bid_number = p_bid_number;
  END IF;

  print_log (l_api_name, 'END PROCEDURE');
END;

--========================================================================
-- PROCEDURE : set_pf_price_components        PRIVATE
--             set_pf_price_components_auto   PRIVATE
-- PARAMETERS:
-- VERSION   : current version         1.x
--             initial version         1.0
-- COMMENT   :
--             This procedure will be used to populate columns that store
--             components of a response price on a line and on its price
--             breaks based on the price factors that apply to the line.
--========================================================================
PROCEDURE set_pf_price_components_auto(p_bidNumber IN NUMBER,
                                       p_pfTypeAllowed IN VARCHAR2,
                                       p_priceTiersIndicator IN VARCHAR2)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_name CONSTANT VARCHAR2(30) := 'set_pf_price_components_auto';
BEGIN

  print_log(l_api_name, p_bidNumber || ' - BEGIN set_pf_price_components_auto AUTONOMOUS');

  set_pf_price_components(p_bidNumber,
                          p_pfTypeAllowed,
                          p_priceTiersIndicator);

  commit;
  print_log(l_api_name, p_bidNumber || ' - set_pf_price_components_auto: committed!');
  print_log(l_api_name, p_bidNumber || ' - END set_pf_price_components_auto AUTONOMOUS');

END set_pf_price_components_auto;

--========================================================================
-- PROCEDURE : add_hidden_price_factors       PRIVATE
--             add_hidden_price_factors_auto  PRIVATE
-- PARAMETERS:
-- VERSION   : current version         1.x
--             initial version         1.0
-- COMMENT   : copies any price factors that are applicable to a supplier/site
-- but cannot be displayed to the supplier/site
-- from the negotiation lines to the response lines
--
-- the only types of price factors that may not be displayed to a supplier/site
-- are buyer price factors and the Line Price price factor
-- as a result, those are the only price factors considered in the procedure below
--========================================================================

PROCEDURE add_hidden_price_factors(p_bid_number         IN NUMBER,
                                   p_auction_header_id  IN NUMBER,
                                   p_supplier_view_type IN VARCHAR2,
                                   p_trading_partner_id IN NUMBER,
                                   p_vendor_site_id     IN NUMBER,
                                   p_login_user_id      IN NUMBER) IS
  l_supplier_sequence_number NUMBER;
  l_currency_rate NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'add_hidden_price_factors';
BEGIN

  print_log(l_api_name, p_bid_number || ' - BEGIN add_hidden_price_factors');

  -- determine the sequence number for the supplier/site
  BEGIN
    SELECT sequence
    INTO l_supplier_sequence_number
    FROM pon_bidding_parties
    WHERE
          auction_header_id = p_auction_header_id
      AND trading_partner_id = p_trading_partner_id
      AND vendor_site_id = p_vendor_site_id;
  EXCEPTION
    WHEN no_data_found THEN
      l_supplier_sequence_number := -1;
  END;

  -- if the sequence number cannot be determined for the supplier/site
  -- it means that the supplier/site was not invited to respond to the negotiation
  -- as a result, there will be no buyer price factors applicable to the supplier/site
  IF l_supplier_sequence_number <> -1 THEN
    -- determine the currency rate for the response
    SELECT rate
    INTO l_currency_rate
    FROM pon_bid_headers
    WHERE bid_number = p_bid_number;

    -- 1) add the Line Price price factor to each bid line that has an applicable buyer factor
    --    if the supplier view type of the auction is UNTRANSFORMED
    IF p_supplier_view_type = 'UNTRANSFORMED' THEN
      INSERT INTO
        pon_bid_price_elements (
          bid_number,
          line_number,
          price_element_type_id,
          auction_header_id,
          pricing_basis,
          auction_currency_value,
          bid_currency_value,
          sequence_number,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          pf_type
        )
      SELECT
        p_bid_number,
        pfs.line_number,
        pfs.price_element_type_id,
        pfs.auction_header_id,
        pfs.pricing_basis,
        bid_lines.unit_price,
        bid_lines.bid_currency_unit_price,
        pfs.sequence_number,
        SYSDATE,
        p_login_user_id,
        SYSDATE,
        p_login_user_id,
        pfs.pf_type
      FROM
        pon_price_elements pfs,
        pon_bid_item_prices bid_lines
      WHERE
            pfs.auction_header_id = p_auction_header_id
        AND bid_lines.bid_number = p_bid_number
        AND bid_lines.line_number = pfs.line_number
        AND pfs.price_element_type_id = -10
        AND EXISTS (SELECT NULL
                    FROM pon_pf_supplier_values pf_values
                    WHERE
                          pf_values.auction_header_id = bid_lines.auction_header_id
                      AND pf_values.line_number = bid_lines.line_number
                      AND pf_values.supplier_seq_number = l_supplier_sequence_number
                      AND NVL(pf_values.value, 0) <> 0);
    END IF;

    -- 2) add those buyer price factors that have not been added yet to pon_bid_price_elements
    --    (these will end up being the price factors hidden from the bidding UI by the buyer)
    INSERT INTO
      pon_bid_price_elements (
        bid_number,
        line_number,
        price_element_type_id,
        auction_header_id,
        pricing_basis,
        auction_currency_value,
        bid_currency_value,
        sequence_number,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        pf_type
      )
    SELECT
      p_bid_number,
      pfs.line_number,
      pfs.price_element_type_id,
      pfs.auction_header_id,
      pfs.pricing_basis,
      pf_values.value,
      DECODE('PERCENTAGE', pfs.pricing_basis, pf_values.value,
             pf_values.value * l_currency_rate),
      pfs.sequence_number,
      SYSDATE,
      p_login_user_id,
      SYSDATE,
      p_login_user_id,
      pfs.pf_type
    FROM
      pon_price_elements pfs,
      pon_pf_supplier_values pf_values
    WHERE
          pfs.auction_header_id = p_auction_header_id
      AND pf_values.auction_header_id = pfs.auction_header_id
      AND pf_values.line_number = pfs.line_number
      AND pf_values.pf_seq_number = pfs.sequence_number
      AND pfs.pf_type = 'BUYER'
      AND pf_values.supplier_seq_number = l_supplier_sequence_number
      AND NVL(pf_values.value, 0) <> 0
      AND NOT EXISTS (SELECT NULL
                      FROM pon_bid_price_elements bid_pfs
                      WHERE
                            bid_pfs.bid_number = p_bid_number
                        AND bid_pfs.line_number = pfs.line_number
                        AND bid_pfs.price_element_type_id = pfs.price_element_type_id);

  END IF;

  print_log(l_api_name, p_bid_number || ' - END add_hidden_price_factors');

END add_hidden_price_factors;


PROCEDURE add_hidden_price_factors_auto(p_bid_number    IN NUMBER,
                                   p_auction_header_id  IN NUMBER,
                                   p_supplier_view_type IN VARCHAR2,
                                   p_trading_partner_id IN NUMBER,
                                   p_vendor_site_id     IN NUMBER,
                                   p_login_user_id      IN NUMBER)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_name CONSTANT VARCHAR2(30) := 'add_hidden_price_factors_auto';
BEGIN

  print_log(l_api_name, p_bid_number || ' - BEGIN add_hidden_price_factors AUTONOMOUS');

  add_hidden_price_factors(p_bid_number, p_auction_header_id,
                           p_supplier_view_type, p_trading_partner_id,
                           p_vendor_site_id, p_login_user_id);

  commit;
  print_log(l_api_name, p_bid_number || ' - add_hidden_price_factors: committed!');
  print_log(l_api_name, p_bid_number || ' - END add_hidden_price_factors AUTONOMOUS');

END  add_hidden_price_factors_auto;


--========================================================================
-- PROCEDURE : archive_prev_active_bids       PRIVATE
--             archive_prev_active_bids_auto  PRIVATE
-- PARAMETERS:
-- VERSION   : current version         1.x
--             initial version         1.0
-- COMMENT   : called by update_auction_info, this procedure archives all
-- past active bids
--========================================================================

PROCEDURE archive_prev_active_bids(p_auctionHeaderId IN NUMBER,
                                   p_bidNumber IN NUMBER,
                                   p_vendorSiteId IN NUMBER,
                                   p_oldBidNumber IN NUMBER)
IS
    v_doctypeId                  pon_auction_headers_all.doctype_id%TYPE;
    v_bidTradingPartnerId        pon_bid_headers.trading_partner_id%TYPE;
    v_bidTradingPartnerContactId pon_bid_headers.trading_partner_contact_id%TYPE;
    v_fixedValue                 pon_auc_doctype_rules.fixed_value%TYPE;
    v_amendmentNumber            NUMBER;
    v_auctionHeaderIdOrigAmend   NUMBER;

    l_api_name CONSTANT VARCHAR2(30) := 'archive_prev_active_bids';
BEGIN

    print_log(l_api_name, p_bidNumber || ' - begin archive prev active bids');

    SELECT trading_partner_id,
           trading_partner_contact_id
    INTO v_bidTradingPartnerId,
         v_bidTradingPartnerContactId
    FROM pon_bid_headers
    WHERE bid_number = p_bidNumber;

    SELECT doctype_id,
           nvl(amendment_number, 0),
           auction_header_id_orig_amend
    INTO v_doctypeId,
         v_amendmentNumber,
         v_auctionHeaderIdOrigAmend
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auctionheaderid;

    SELECT fixed_value
    INTO v_fixedValue
    FROM pon_auc_bizrules pab,
         pon_auc_doctype_rules padr
    WHERE pab.name = 'AWARD_TYPE'
      AND pab.bizrule_id = padr.bizrule_id
      AND padr.doctype_id = v_doctypeId;

      IF (v_fixedValue IS NOT NULL) THEN
        IF (v_fixedValue <> 'COMMIT') THEN

            -- Update the previous active bid to archived for current auction
            IF (p_oldBidNumber is not null) THEN
               UPDATE PON_BID_HEADERS
               SET    BID_STATUS = 'ARCHIVED',
                      LAST_UPDATE_DATE = SYSDATE
               WHERE  AUCTION_HEADER_ID = p_auctionHeaderId
               AND    BID_NUMBER = p_oldBidNumber
               AND    BID_STATUS = 'ACTIVE';
            END IF;


            -- Go back to previous amendments, update all the active or
            -- resubmission one to archived
            IF (v_amendmentNumber > 0) THEN
               UPDATE PON_BID_HEADERS
               SET    BID_STATUS = 'ARCHIVED',
                      LAST_UPDATE_DATE = SYSDATE
               WHERE  AUCTION_HEADER_ID in (
                      SELECT AUCTION_HEADER_ID
                      FROM PON_AUCTION_HEADERS_ALL
                      WHERE AUCTION_HEADER_ID_ORIG_AMEND = v_auctionHeaderIdOrigAmend)
               AND    BID_NUMBER <> p_bidNumber
	       AND    NVL(VENDOR_SITE_ID, -1) = NVL(p_vendorSiteId, -1)
               AND    TRADING_PARTNER_ID = v_bidTradingPartnerId
               AND    TRADING_PARTNER_CONTACT_ID = v_bidtradingpartnercontactid
               AND    BID_STATUS in ('ACTIVE', 'RESUBMISSION');
            END IF;
         END IF;

      END IF;

  print_log(l_api_name, p_bidNumber || ' - end archive prev active bids');
END archive_prev_active_bids;

PROCEDURE archive_prev_active_bids_auto(p_auctionHeaderId IN NUMBER,
                                        p_bidNumber IN NUMBER,
                                        p_vendorSiteId IN NUMBER,
                                        p_oldBidNumber IN NUMBER)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_name CONSTANT VARCHAR2(30) := 'archive_prev_active_bids_auto';
BEGIN
  print_log(l_api_name, p_bidNumber || ' - BEGIN archive prev active bids AUTONOMOUS');

  archive_prev_active_bids(p_auctionHeaderId, p_bidNumber, p_vendorSiteId, p_oldBidNumber);
  commit;

 print_log(l_api_name, p_bidNumber || ' - archive prev active bids: committed!');
 print_log(l_api_name, p_bidNumber || ' - END archive prev active bids AUTONOMOUS');

END;


--========================================================================
-- PROCEDURE : set_partial_response_flag PRIVATE
-- PARAMETERS:
-- VERSION   : current version         1.x
--             initial version         1.0
-- COMMENT   : called by update_auction_info, this procedure calculates
-- the partial response flag and sets it in pon_bid_headers
--========================================================================

PROCEDURE set_partial_response_flag(p_bidNumber IN NUMBER)
IS
 l_api_name            CONSTANT VARCHAR2(30) := 'set_partial_response_flag';
BEGIN

	print_log(l_api_name || '.BEGIN', p_bidNumber ||' Begin - set_partial_response_flag');
    UPDATE pon_bid_headers bh
    SET partial_response_flag = 'N'
    WHERE bh.bid_number = p_bidNumber;

    UPDATE pon_bid_headers bh
    SET partial_response_flag = 'Y'
    WHERE bh.bid_number = p_bidNumber
      AND (EXISTS (select 'x'
                   from pon_bid_item_prices bl,
                        pon_auction_item_prices_all al
                   where bl.bid_number = bh.bid_number
                     and bl.auction_header_id = al.auction_header_id
                     and bl.line_number = al.line_number
                     and al.group_type <> 'GROUP'
                     and al.group_type <> 'LOT_LINE'
                     and al.quantity <> bl.quantity
                     and al.quantity is not null
                     and bl.quantity is not null)
           OR
           EXISTS (select 'x'
                   from pon_bid_item_prices bl,
                        pon_auction_item_prices_all al
                   where bl.bid_number(+) = bh.bid_number
                     and al.auction_header_id = bh.auction_header_id
                     and bl.auction_header_id(+) = al.auction_header_id
                     and bl.line_number(+) = al.line_number
                     and al.group_type <> 'GROUP'
                     and al.group_type <> 'LOT_LINE'
                     and bl.line_number is null));
	print_log(l_api_name || '.END', p_bidNumber ||' End - set_partial_response_flag');
END set_partial_response_flag;




--
-- update pon_bid_item_prices.group_amount
-- needed whenever bid price is changed for any group lines

PROCEDURE update_group_amount (p_bidNumber  IN NUMBER )

IS
 l_api_name            CONSTANT VARCHAR2(30) := 'update_group_amount';
BEGIN
	 	  print_log(l_api_name || '.BEGIN', p_bidNumber ||' Begin - update_group_amount');
          update pon_bid_item_prices bl
             set group_amount = (select sum(nvl(bl2.quantity, decode(al.ORDER_TYPE_LOOKUP_CODE, 'FIXED PRICE', 1, al.quantity))*bl2.price)
                                   from pon_bid_item_prices bl2,
                                        pon_auction_item_prices_all al
                                  where bl2.auction_header_id = al.auction_header_id
                                    and bl2.line_number = al.line_number
                                    and bl2.bid_number = bl.bid_number
                                    and al.parent_line_number = bl.line_number)
           where bl.bid_number = p_bidNumber
                 and (select a2.group_type
                    from pon_auction_item_prices_all a2
                    where a2.auction_header_id = bl.auction_header_id
                      and a2.line_number = bl.line_number) = 'GROUP';

	print_log(l_api_name || '.END', p_bidNumber ||' End - update_group_amount');

END update_group_amount;




--PROCEDURE CALCULATE_PRICES
--
--
procedure calculate_prices
(
 p_auctionType	    IN VARCHAR2,
 p_currentPrice     IN NUMBER,
 p_currentLimit	    IN NUMBER,
 p_currentBidChange IN NUMBER,
 p_bestPrice	    IN NUMBER,
 p_bestLimit	    IN NUMBER,
 p_bestBidChange    IN NUMBER,
 p_newPrice	    OUT NOCOPY NUMBER,
 p_newBestPrice	    OUT NOCOPY NUMBER
) IS
     -- this function returns whether x_price1 is better than x_price2
     -- i.e. in reverse auction if (x_price1 < x_price2)
     -- i.e. in forward auction if (x_price1 > x_price2)
--
     l_api_name            CONSTANT VARCHAR2(30) := 'calculate_prices';


     FUNCTION is_better_price(x_price1 IN NUMBER,
			      x_price2 IN NUMBER)
     RETURN BOOLEAN IS
     BEGIN
	return better_price(p_auctionType, x_price1,x_price2);
     END;
--
     FUNCTION is_between(x_price  IN NUMBER,
		        x_price1 IN NUMBER,
			x_price2 IN NUMBER)
     RETURN BOOLEAN IS
     BEGIN
	if (p_auctionType = 'REVERSE') then
	   return ((x_price1 <= x_price) AND (x_price <= x_price2));
        else
           return ((x_price1 >= x_price) AND (x_price >= x_price2));
        end if;
     END;
--
     FUNCTION change_bid (x_price IN NUMBER,
			  x_delta IN NUMBER,
			  x_limit IN NUMBER)
     RETURN NUMBER IS
     BEGIN
        if (p_auctionType = 'REVERSE') then
	    if ((x_price - x_delta) > x_limit) then
	       return (x_price - x_delta);
	    else
	       return x_limit;
	    end if;
        else
	    if ((x_price + x_delta) < x_limit) then
	       return (x_price + x_delta);
	    else
	       return x_limit;
	    end if;
        end if;
     END;
BEGIN
--
   -- logging
   print_log(l_api_name || '.BEGIN', ' ');
   print_log(l_api_name, 'p_auctionType=' || p_auctionType);
   print_log(l_api_name, 'p_currentPrice=' || p_currentPrice);
   print_log(l_api_name, 'p_currentLimit=' || p_currentLimit);
   print_log(l_api_name, 'p_currentBidChange=' || p_currentBidChange);
   print_log(l_api_name, 'p_bestPrice=' || p_bestPrice);
   print_log(l_api_name, 'p_bestLimit=' || p_bestLimit);
   print_log(l_api_name, 'p_bestBidChange=' || p_bestBidChange);

   -- the first two cases will be true if the best bid price range
   -- and the current bid price range do not intersect
   -- OR part is fix for BUG #1787086
--
   IF (is_better_price(p_bestPrice, p_currentLimit) OR
       (p_currentLimit = p_bestPrice)) THEN
--
      -- dbms_output.put_line(' best price better than current limit');
      p_newPrice := p_currentLimit;
      p_newBestPrice := p_bestPrice;
      print_log(l_api_name || '.END', ' ');
      RETURN;
   ELSIF (is_better_price(p_currentPrice, p_bestLimit)) THEN
      -- dbms_output.put_line(' current price better than best limit');
      p_newPrice := p_currentPrice;
      p_newBestPrice := p_bestLimit;
      print_log(l_api_name || '.END', ' ');
      RETURN;
--
   -- the follow will be true if the best bid price range and
   -- the current bid price range intersect
--
   ELSIF ((is_between(p_bestPrice, p_currentLimit, p_currentPrice)) OR
          (is_between(p_currentPrice, p_bestLimit, p_bestPrice))) THEN
--
      -- dbms_output.put_line(' between case');
      IF (is_better_price(p_currentLimit,p_bestLimit)) THEN
--
         -- dbms_output.put_line(' between case1');
	 p_newPrice := change_bid(p_bestLimit, p_currentBidChange, p_currentLimit);
         p_newBestPrice := p_bestLimit;
--
      ELSIF (is_better_price(p_bestLimit,p_currentLimit)) THEN
         -- dbms_output.put_line(' between case2');
	 p_newPrice := p_currentLimit;
         p_newBestPrice := change_bid(p_currentLimit, p_bestBidChange, p_bestLimit);
      ELSIF (p_currentLimit = p_bestLimit) THEN
         --  dbms_output.put_line(' between case3');
	 p_newPrice := p_currentLimit;
         p_newBestPrice := p_bestLimit;
      END IF;
--
   END IF;
--
   print_log(l_api_name || '.END', ' ');
END calculate_prices;
--
PROCEDURE copy_attachments
(
 p_auctionHeaderId  IN NUMBER,
 p_oldBidNum	    IN NUMBER,
 p_newBidNum	    IN NUMBER)
IS
--

--Added for bug 10008711
--pk1_value,pk2_value are of VARCHAR2 datatype whereas
--p_auctionHeaderId,p_oldBidNum are of NUMBER datatype
CURSOR bid_attachments IS
   SELECT fndat.entity_name entity, fndat.attached_document_id attached_document_id,
	  fndat.seq_num seq_num, dc.datatype_id datatype_id,
	  dt.description description, dt.file_name file_name, dc.media_id media_id,
	  fndat.pk3_value pk3,
	  fndat.pk4_value pk4
    FROM  fnd_documents dc, fnd_documents_tl dt, fnd_attached_documents fndat
    WHERE fndat.document_id = dt.document_id
      AND dt.document_id = dc.document_id
      AND dt.language = userenv('LANG')
      AND fndat.entity_name IN ('PON_BID_ITEM_PRICES', 'PON_BID_HEADERS')
      AND fndat.pk1_value = to_char(p_auctionHeaderId)
      AND fndat.pk2_value = to_char(p_oldBidNum);
--
SHORT_TEXT    number := 1;
WEB_PAGE      number := 5;
EXTERNAL_FILE number := 6;
ACCESS_URL    VARCHAR2(255) := '/jsp/pon/attachments/get_attachment.jsp?sequence_num=';
v_text        fnd_documents_short_text.short_text%TYPE;
v_url	      VARCHAR2(255);
v_document_id NUMBER := NULL;
v_file_id     NUMBER := NULL;
v_attachment_cat_id NUMBER := NULL;

l_api_name            CONSTANT VARCHAR2(30) := 'copy_attachments';

--
--
BEGIN
--

  -- logging
  print_log(l_api_name || '.BEGIN', ' ');
  print_log(l_api_name, 'p_auctionHeaderId=' || p_auctionHeaderId);
  print_log(l_api_name, 'p_oldBidNum=' || p_oldBidNum);
  print_log(l_api_name, 'p_newBidNum=' || p_newBidNum);

  FOR bid_att IN bid_attachments LOOP
--
       print_log(l_api_name, 'cursor=' || bid_att.attached_document_id);

       IF (bid_att.datatype_id = SHORT_TEXT) THEN
           SELECT short_text
	   INTO   v_text
	   FROM   fnd_documents_short_text
	   WHERE  media_id = bid_att.media_id;
--
       ELSE
           v_text := null;
       END IF;
--
       IF ((bid_att.datatype_id = SHORT_TEXT) OR
           (bid_att.datatype_id = EXTERNAL_FILE)) THEN
	  v_url := ACCESS_URL || to_char(bid_att.seq_num);
       ELSIF (bid_att.datatype_id = WEB_PAGE) THEN
	  v_url := bid_att.file_name;
       END IF;
--
       SELECT category_id
       INTO   v_attachment_cat_id
       FROM fnd_document_categories
       WHERE name = 'Vendor';


       PON_ATTACHMENTS.add_attachment(
          bid_att.seq_num,
	  v_attachment_cat_id,
	  bid_att.description,
	  bid_att.datatype_id,
	  v_text,
	  bid_att.file_name,
	  v_url,
	  bid_att.entity,
	  p_auctionHeaderId,
	  p_newBidNum,
	  bid_att.pk3,
	  bid_att.pk4,
	  null,
	  bid_att.media_id,
	  -1,
	  v_document_id,
	  v_file_id);
--
   END LOOP;
--
   print_log(l_api_name || '.END', ' ');
--
END COPY_ATTACHMENTS;
--
--
-- this function returns the new bid number
--
FUNCTION clone_update_bid
( p_auctionHeaderId IN NUMBER,
  p_bidNumber	    IN NUMBER,
  p_new_publish_date IN DATE,
  p_triggerBidNumber IN NUMBER
) RETURN NUMBER IS
--
v_nextBid   NUMBER;
l_msg_data                  VARCHAR2(250);
l_msg_count                 NUMBER;
l_return_status             VARCHAR2(1);
v_contermsExist VARCHAR2(1);
l_api_name            CONSTANT VARCHAR2(30) := 'clone_update_bid';

BEGIN
--

  -- logging
  print_log(l_api_name || '.BEGIN', ' ');
  print_log(l_api_name, 'p_auctionHeaderId=' || p_auctionHeaderId);
  print_log(l_api_name, 'p_bidNumber=' || p_bidNumber);
  print_log(l_api_name, 'p_new_publish_date=' || p_new_publish_date);
  print_log(l_api_name, 'p_triggerBidNumber=' || p_triggerBidNumber);

      SELECT pon_bid_headers_s.nextval
        INTO v_nextBid
        FROM dual;
--

-- need to activate deliverables for the new bid triggered due to proxy
-- xxx
--
      INSERT INTO pon_bid_headers (
				    bid_status,
				    bid_status_name,
			    bid_number,
                                    shortlist_flag,
				    proxy_bid_flag,
				    auction_header_id,
				    bidders_bid_number,
				    bid_type,
				    contract_type,
				    trading_partner_contact_name,
				    trading_partner_contact_id,
				    trading_partner_name,
				    trading_partner_id,
				    bid_effective_date,
				    bid_expiration_date,
				    publish_date,
				    cancelled_date,
				    payment_terms_id,
				    freight_terms_code,
				    carrier_code,
				    fob_code,
				    note_to_auction_owner,
				    creation_date,
				    created_by,
				    last_update_date,
				    last_updated_by,
				    auction_creation_date,
				    attachments_flag,
				    disqualify_reason,
				    language_code,
				    award_status,
				    award_status_name,
				    phone,
				    fax,
				    email,
				    --operator_id,
				    bid_currency_code,
				    rate,
				    rate_type,
				    rate_date,
	                            min_bid_change,
	                            number_price_decimals,
	                            doctype_id,
	                            vendor_id,
	                            vendor_site_id,
				    vendor_site_code,
	                            agent_id,
	                            create_sourcing_rules,
	                            update_sourcing_rules,
                                    release_method,
	                            po_header_id,
	                            po_error_code,
	                            po_wf_creation_rnd,
				    surrog_bid_flag,
				    surrog_bid_created_tp_id,
				    SURROG_BID_CREATED_CONTACT_ID,
				    SURROG_BID_RECEIPT_DATE,
				    SURROG_BID_ONLINE_ENTRY_DATE,
                                    ATTRIBUTE_LINE_NUMBER,
                                    partial_response_flag,
                                    color_sequence_id,
                    old_bid_number)
	SELECT  bid_status,
	bid_status_name,
	v_nextBid,
        'Y',
	'Y',
	auction_header_id,
	bidders_bid_number,
	bid_type,
	contract_type,
	trading_partner_contact_name,
	trading_partner_contact_id,
	trading_partner_name,
	trading_partner_id,
	bid_effective_date,
	bid_expiration_date,
	p_new_publish_date,
	cancelled_date,
	payment_terms_id,
	freight_terms_code,
	carrier_code,
	fob_code,
	note_to_auction_owner,
	sysdate,
	created_by,
	sysdate,
	last_updated_by,
	auction_creation_date,
	attachments_flag,
	disqualify_reason,
	language_code,
	award_status,
	award_status_name,
	phone,
	fax,
	email,
	--operator_id,
	bid_currency_code,
	rate,
	rate_type,
	rate_date,
	min_bid_change,
	number_price_decimals,
	doctype_id,
	vendor_id,
	vendor_site_id,
	vendor_site_code,
	agent_id,
	create_sourcing_rules,
	update_sourcing_rules,
	release_method,
	po_header_id,
	po_error_code,
	po_wf_creation_rnd,
	surrog_bid_flag,
	surrog_bid_created_tp_id,
	surrog_bid_created_contact_id,
	surrog_bid_receipt_date,
	sysdate,
        -1,
        partial_response_flag,
        color_sequence_id,
    old_bid_number
	FROM  PON_BID_HEADERS
	WHERE  auction_header_id= p_auctionHeaderId
	AND  bid_number = p_bidNumber;
      --
      INSERT INTO pon_bid_item_prices (
		   auction_header_id,
		   auction_line_number,
		   bid_number,
		   line_number,
		   item_description,
		   category_id,
		   UOM,
		   unit_of_measure,
		   quantity,
		   price,
       unit_price,
		   minimum_bid_price,
		   promised_date,
		   award_status,
		   award_date,
		   note_to_auction_owner,
		   last_update_date,
		   creation_date,
		   created_by,
		   last_updated_by,
		   auction_creation_date,
		   attachments_flag,
		   order_number,
		   award_status_name,
		   category_name,
		   language_code,
		   ship_to_location_id,
		   --operator_id,
		   publish_date,
		   bid_currency_price,
       bid_currency_unit_price,
       bid_currency_trans_price,
		   proxy_bid_limit_price,
		   bid_currency_limit_price,
		   proxy_bid_flag,
		   first_bid_price,
                   has_attributes_flag,
                   total_weighted_score,
                   rank,
                   trigger_bid_number,
                   group_amount,
		   HAS_BID_PAYMENTS_FLAG,
		   RETAINAGE_RATE_PERCENT,
		   MAX_RETAINAGE_AMOUNT,
		   BID_CURR_MAX_RETAINAGE_AMT,
           has_bid_flag,
	   per_unit_price_component,  --bug 7673590
	   fixed_amount_component)
           SELECT  auction_header_id,
		   auction_line_number,
		   v_nextBid,
		   line_number,
		   item_description,
		   category_id,
		   UOM,
		   unit_of_measure,
		   quantity,
		   price,
       unit_price,
		   minimum_bid_price,
		   promised_date,
		   award_status,
		   award_date,
		   note_to_auction_owner,
		   sysdate,
		   sysdate,
		   created_by,
		   last_updated_by,
		   auction_creation_date,
		   attachments_flag,
		   order_number,
		   award_status_name,
		   category_name,
		   language_code,
		   ship_to_location_id,
		   --operator_id,
		   publish_date,
		   bid_currency_price,
       bid_currency_unit_price,
       bid_currency_trans_price,
		   proxy_bid_limit_price,
	           bid_currency_limit_price,
	           proxy_bid_flag,
		   first_bid_price,
                   has_attributes_flag,
                   total_weighted_score,
                   rank,
                   p_triggerBidNumber,
                   group_amount,
		   HAS_BID_PAYMENTS_FLAG,
		   RETAINAGE_RATE_PERCENT,
		   MAX_RETAINAGE_AMOUNT,
		   BID_CURR_MAX_RETAINAGE_AMT,
           has_bid_flag,
	   per_unit_price_component,
	   fixed_amount_component
	     FROM  pon_bid_item_prices
	    WHERE  auction_header_id = p_auctionHeaderId
	      AND  bid_number = p_bidNumber;
--
      INSERT INTO pon_bid_attribute_values (
		   auction_header_id,
		   auction_line_number,
		   bid_number,
		   line_number,
		   attribute_name,
                   attr_level,
		   datatype,
		   value,
		   creation_date,
		   created_by,
		   last_update_date,
		   last_updated_by,
		   score,
                   weighted_score,
		   sequence_number,
                   attr_group_seq_number,
                   attr_disp_seq_number)
	   SELECT  auction_header_id,
		   auction_line_number,
		   v_nextBid,
		   line_number,
		   attribute_name,
                   attr_level,
		   datatype,
		   value,
		   sysdate,
		   created_by,
		   sysdate,
		   last_updated_by,
		   score,
                   weighted_score,
		   sequence_number,
                   attr_group_seq_number,
                   attr_disp_seq_number
             FROM  pon_bid_attribute_values
	    WHERE  auction_header_id = p_auctionHeaderId
	      AND  bid_number = p_bidNumber;
--
      INSERT INTO pon_bid_price_elements (
		   bid_number,
		   line_number,
		   price_element_type_id,
		   auction_header_id,
		   pricing_basis,
		   auction_currency_value,
		   bid_currency_value,
		   sequence_number,
		   creation_date,
		   created_by,
		   last_update_date,
		   last_updated_by,
       pf_type)
	   SELECT  v_nextBid,
		   line_number,
		   price_element_type_id,
		   auction_header_id,
		   pricing_basis,
		   auction_currency_value,
		   bid_currency_value,
		   sequence_number,
		   sysdate,
		   created_by,
		   sysdate,
		   last_updated_by,
       pf_type
      FROM  pon_bid_price_elements
	    WHERE  auction_header_id = p_auctionHeaderId
	      AND  bid_number = p_bidNumber;


      -- TODO, still need to copy attachments
--
      print_log(l_api_name, 'calling subroutine copy_attachments');
      copy_attachments(p_auctionHeaderId, p_bidNumber, v_nextBid);
--
      UPDATE pon_bid_headers
        SET bid_status = 'ARCHIVED',
            bid_status_name = (SELECT meaning
                                 FROM fnd_lookups
                                WHERE lookup_type='PON_BID_STATUS'
                                  AND lookup_code = 'ARCHIVED')
        WHERE auction_header_id = p_auctionHeaderId
          AND bid_number = p_bidNumber;
--
--
      UPDATE pon_auction_item_prices_all
         SET best_bid_number = v_nextBid,
	     lowest_bid_number = decode(lowest_bid_number, null, null,
				        v_nextBid)
       WHERE auction_header_id = p_auctionHeaderId
         AND best_bid_number = p_bidNumber;

      UPDATE pon_auction_item_prices_all
         SET best_bid_bid_number = v_nextBid
       WHERE auction_header_id = p_auctionHeaderId
         AND best_bid_bid_number = p_bidNumber;

	-- finally, we need to copy all the TandCs and deliverables
	-- from the p_bidNumber to v_nextBid
	-- since this bid has been triggered by a proxy
	-- we will maintain the statuses on the deliverables
	-- rrkulkar

      if (PON_CONTERMS_UTL_PVT.is_contracts_installed() = FND_API.G_TRUE) then

        begin
		select conterms_exist_flag into v_contermsExist
		from pon_auction_headers_all
		where auction_header_id = p_auctionHeaderId;

		if(v_contermsExist = 'Y') then

			-- first copy the response document from old bid
			-- to the new bid
                        print_log(l_api_name, 'calling subroutine PON_CONTERMS_UTL_PVT.copyResponseDoc');
			PON_CONTERMS_UTL_PVT.copyResponseDoc(p_bidNumber , v_nextBid);

			-- and then activate deliverables for the newly created bid
  		    	print_log(l_api_name, 'calling subroutine PON_CONTERMS_UTL_PVT.activateDeliverables');
                        PON_CONTERMS_UTL_PVT.activateDeliverables(p_auctionHeaderId,
						  		v_nextBid,
						  		p_bidNumber,
						  		l_msg_data,
						  		l_msg_count,
					  	  		l_return_status);

   			 if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
			      fnd_log.string(fnd_log.level_statement,
			     'pon_auction_headers_pkg',
			     'clone_update_bid failed for auction_id=' ||  p_auctionHeaderId || ':'  || v_nextBid || ':' || p_bidNumber || ', msg_data=' || l_msg_data);
			    end if;
		end if;
        exception
         when others then
          null;
        end;
      end if;




--
      print_log(l_api_name || '.END', ' ');
--
      RETURN v_nextBid;
--
END CLONE_UPDATE_BID;
--
PROCEDURE get_auc_header_id_orig_round
( p_auctionHeaderId           IN NUMBER,
  p_auctionHeaderIdOrigRound  OUT NOCOPY NUMBER)
IS
--
l_api_name            CONSTANT VARCHAR2(30) := 'get_auc_header_id_orig_round';

BEGIN
  print_log(l_api_name || '.BEGIN', ' ');
  print_log(l_api_name, 'p_auctionHeaderId=' || p_auctionHeaderId);
  print_log(l_api_name, 'p_auctionHeaderIdOrigRound=' || p_auctionHeaderIdOrigRound);

  SELECT nvl(auction_header_id_orig_round, auction_header_id)
  INTO  p_auctionHeaderIdOrigRound
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_auctionHeaderId;

  print_log(l_api_name || '.END', ' ');
END get_auc_header_id_orig_round;
--
--
PROCEDURE update_new_bid_line
( p_auctionHeaderId IN NUMBER,
  p_bidNum	    IN NUMBER,
  p_line	    IN NUMBER,
  p_price	    IN NUMBER,
  p_bid_curr_price  IN NUMBER,
  p_publish_date    IN DATE)
IS
--
l_api_name            CONSTANT VARCHAR2(30) := 'update_new_bid_line';

BEGIN

  print_log(l_api_name || '.BEGIN', ' ');
  print_log(l_api_name, 'p_auctionHeaderId='||p_auctionHeaderId);
  print_log(l_api_name, 'p_bidNum=' || p_bidNum);
  print_log(l_api_name, 'p_line=' || p_line);
  print_log(l_api_name, 'p_price=' || p_price);
  print_log(l_api_name, 'p_bid_curr_price=' || p_bid_curr_price);
  print_log(l_api_name, 'p_publish_date=' || p_publish_date);


   UPDATE pon_bid_item_prices
      SET price = p_price,
          bid_currency_trans_price = p_bid_curr_price,
	  bid_currency_price = p_bid_curr_price,
	  --bug 18437645
	  --For Proxy Bidding case using the Current bid price in unit_price column instead of price
          unit_price = Decode(PROXY_BID_FLAG,'Y',p_bid_curr_price,p_price),
          bid_currency_unit_price = p_bid_curr_price,
	  publish_date = p_publish_date,
	  proxy_bid_flag = 'Y'
    WHERE auction_header_id = p_auctionHeaderId
      AND bid_number = p_bidNum
      AND line_number = p_line;

--
   UPDATE pon_auction_item_prices_all
      SET best_bid_price = p_price,
          best_bid_currency_price = p_bid_curr_price,
          lowest_bid_price = decode (lowest_bid_price, null,null,
				     p_price)
    WHERE auction_header_id = p_auctionHeaderId
      AND line_number = p_line
      AND best_bid_number = p_bidNum;

   UPDATE pon_auction_item_prices_all
     SET best_bid_bid_price = p_price,
         best_bid_bid_currency_price = p_bid_curr_price
    WHERE auction_header_id = p_auctionHeaderId
      AND line_number = p_line
      AND best_bid_bid_number = p_bidNum;


--
   print_log(l_api_name || '.END', ' ');
--
END update_new_bid_line;
--
--


PROCEDURE get_previous_bid( p_auctionHeaderId	IN NUMBER,
			    p_bidNumber		IN NUMBER,
			    v_oldBidNumber      OUT NOCOPY NUMBER) IS

  v_tpcid		pon_bid_headers.trading_partner_contact_id%TYPE;
  v_tpid		pon_bid_headers.trading_partner_id%TYPE;
  v_vendorSiteId        pon_bid_headers.vendor_site_id%TYPE;

  l_api_name            CONSTANT VARCHAR2(30) := 'get_previous_bid';

BEGIN

   -- logging
   print_log(l_api_name || '.BEGIN', ' ');
   print_log(l_api_name, 'p_auctionHeaderI=' || p_auctionHeaderId);
   print_log(l_api_name, 'p_bidNumber=' || p_bidNumber);

   --
   -- Get the current bid information
   -- Get the owner of the current bid
   --
   SELECT trading_partner_id,
   	  trading_partner_contact_id,
	  vendor_site_id
     INTO v_tpid,
	  v_tpcid,
	  v_vendorSiteId
     FROM pon_bid_headers
    WHERE auction_header_id = p_auctionHeaderId
      AND bid_number = p_bidNumber;


     --
     -- Get the user's most recent bid
     -- Is it possible that taking the
     -- max bid number will not yield correct result ?
     -- due to draft bid project ?

     SELECT max(bid_number)
       INTO v_oldBidNumber
       FROM pon_bid_headers
       WHERE auction_header_id = p_auctionHeaderId
       AND trading_partner_id = v_tpid
       AND trading_partner_contact_id = v_tpcid
       AND nvl(vendor_site_id,-1) = nvl(v_vendorSiteId, -1)
       AND bid_number <> p_bidNumber
       AND nvl(award_status, 'NONE') <> 'COMMITTED'
       AND bid_status <> 'DRAFT'
       AND bid_status <> 'ARCHIVED';

   print_log(l_api_name || '.END', ' ');

END get_previous_bid;

PROCEDURE get_previous_nonproxy_bid( p_auctionHeaderId          IN NUMBER,
                                     p_bidNumber                IN NUMBER,
				     p_vendorSiteId             IN NUMBER,
                                     v_oldNonProxyBidNumber     OUT NOCOPY NUMBER) IS

  v_tpcid               pon_bid_headers.trading_partner_contact_id%TYPE;
  v_tpid                pon_bid_headers.trading_partner_id%TYPE;
  l_api_name            CONSTANT VARCHAR2(30) := 'get_previous_nonproxy_bid';

  --------- Supplier Management: Supplier Evaluation ---------
  v_evaluator_id        pon_bid_headers.evaluator_id%TYPE;
  v_eval_flag           pon_bid_headers.evaluation_flag%TYPE;
  ------------------------------------------------------------

BEGIN

   -- logging
   print_log(l_api_name || '.BEGIN', ' ');
   print_log(l_api_name, 'p_auctionHeaderId=' || p_auctionHeaderId);
   print_log(l_api_name, 'p_bidNumber=' || p_bidNumber);
   print_log(l_api_name, 'p_vendorSiteId=' || p_vendorSiteId);

   --
   -- Get the current bid information
   --
   ------- Supplier Management: Supplier Evaluation -------
   -- Add evaluator_id and evaluation_flag to the query  --
   --------------------------------------------------------
   SELECT trading_partner_id,
          trading_partner_contact_id,
          nvl(evaluator_id, -1),
          nvl(evaluation_flag, 'N')
     INTO v_tpid,
          v_tpcid,
          v_evaluator_id,
          v_eval_flag
     FROM pon_bid_headers
    WHERE auction_header_id = p_auctionHeaderId
     AND bid_number = p_bidnumber;


     --
     -- Get the user's most recent hard (non proxy) bid
     --
     -- Is it possible that taking the
     -- max bid number will not yield correct result ?
     -- due to draft bid project ?

     -- by mxfang
     -- to fix the following bug
     -- supplier has an active bid which has been disqualified. Then supplier resubmits
     -- his bid and saves as a draft. When he tries to resubmit his draft, he gets rebid_error
     -- due to the validation logic in update_auction_info
     -- the fix here is to exclude the disqualifed bid

     ------- Supplier Management: Supplier Evaluation -------
     -- Add evaluator_id and evaluation_flag to the query  --
     --------------------------------------------------------
     SELECT max(bid_number)
       INTO v_oldNonProxyBidNumber
       FROM pon_bid_headers
       WHERE auction_header_id = p_auctionHeaderId
       AND trading_partner_id = v_tpid
       AND trading_partner_contact_id = v_tpcid
       AND nvl(vendor_site_id, -1) = nvl(p_vendorSiteId, -1)
       AND ((proxy_bid_flag IS null) OR (proxy_bid_flag <> 'Y'))
       AND bid_number <> p_bidnumber
       AND nvl(award_status, 'NONE') <> 'COMMITTED'
       AND bid_status <> 'DISQUALIFIED'
       AND nvl(evaluator_id, -1) = v_evaluator_id
       AND nvl(evaluation_flag, 'N') = v_eval_flag
       -- Bug 14348208
       AND NOT (EXISTS (select 1 FROM pon_auction_headers_all ah WHERE ah.auction_header_id = p_auctionHeaderId
 	                                                            AND  Nvl(ah.two_part_flag, 'N') = 'Y'
 	                                                            AND Nvl(ah.technical_evaluation_status, 'N') ='COMPLETED')
                AND Nvl(surrog_bid_flag, 'N') = 'Y'

                AND submit_stage IS NULL);

    print_log(l_api_name || '.END', ' ');

END get_previous_nonproxy_bid;


PROCEDURE get_most_recent_active_bid( p_auctionHeaderId         IN NUMBER,
                                     p_bidNumber                IN NUMBER,
                                     v_activeBidNumber     	OUT NOCOPY NUMBER,
				     v_recentBidStatus		OUT NOCOPY VARCHAR2) IS

  v_tpcid               pon_bid_headers.trading_partner_contact_id%TYPE;
  v_tpid                pon_bid_headers.trading_partner_id%TYPE;
  l_api_name            CONSTANT VARCHAR2(30) := 'get_most_recent_active_bid';

BEGIN
   --
   -- Get the current bid information
   --
   -- logging
   print_log(l_api_name || '.BEGIN', ' ');
   print_log(l_api_name, 'p_auctionHeaderId=' || p_auctionHeaderId);
   print_log(l_api_name, 'p_bidNumber=' || p_bidNumber);

   SELECT trading_partner_id,
          trading_partner_contact_id
     INTO v_tpid,
          v_tpcid
     FROM pon_bid_headers
    WHERE auction_header_id = p_auctionHeaderId
     AND bid_number = p_bidnumber;

     --
     -- Get the user's most recent hard (non proxy) bid
     -- Donot need to check whether the most recent active
     -- bid is not the current bid that user is trying to place
     -- remember in case of draft bids, the bid number does not
     -- change
     --
     -- Is it possible that taking the
     -- max bid number will not yield correct result ?
     -- due to draft bid project ?

     BEGIN

     SELECT max(bid_number)
       INTO v_activeBidNumber
       FROM pon_bid_headers
       WHERE auction_header_id = p_auctionHeaderId
       AND trading_partner_id = v_tpid
       AND trading_partner_contact_id = v_tpcid
       AND ((proxy_bid_flag IS null) OR (proxy_bid_flag <> 'Y'))
       AND nvl(award_status, 'NONE') <> 'COMMITTED';

     SELECT bid_status
       INTO v_recentBidStatus
       FROM pon_bid_headers
       WHERE bid_number = v_activeBidNumber;

     EXCEPTION

       --
       -- If the user does not have a previous bid then do nothing...
       --
	WHEN NO_DATA_FOUND THEN null;

     END;

     print_log(l_api_name || '.END', ' ');

END get_most_recent_active_bid;


-----------------------------------------------------------------
-- Added the following for Bug 2149531                         --
--                                                             --
-- Procedure to update the user's current rank                 --
-- based on the database's latest rank from the                --
-- user's previous active, non-disqualified bid.               --
--                                                             --
-- The rank that is inserted with the bid is the               --
-- middle tier rank, which is cached, and can be out           --
-- of sync with the database if another user submits a bid     --
-- that changes the current user's rank while in the           --
-- processes of bidding.                                       --
-----------------------------------------------------------------
PROCEDURE update_unchanged_rank( p_auctionHeaderId  IN NUMBER,
                                 p_bidNumber        IN NUMBER,
                                 p_vendorSiteId IN NUMBER,
                                 p_batchStart IN NUMBER,
                                 p_batchEnd IN NUMBER,
                                 p_discard_tech_nonshort IN VARCHAR2) IS

  v_publish_date DATE;
  v_oldBid	         NUMBER;
  v_rank         NUMBER;
  v_tpcid        pon_bid_headers.trading_partner_contact_id%TYPE;
  v_tpid         pon_bid_headers.trading_partner_id%TYPE;

  l_api_name            CONSTANT VARCHAR2(30) := 'update_unchanged_rank';

BEGIN

   -- logging
   print_log(l_api_name || '.BEGIN', ' ');
   print_log(l_api_name, 'p_auctionHeaderId=' || p_auctionHeaderId);
   print_log(l_api_name, 'p_bidNumber=' || p_bidNumber);

   --
   -- Get the current bid information
   --
   SELECT publish_date,
          trading_partner_id,
          trading_partner_contact_id
   INTO v_publish_date,
        v_tpid,
        v_tpcid
   FROM pon_bid_headers
   WHERE bid_number = p_bidNumber;


   -- Get the user's most recent non-disqualified bid...if it exists
   SELECT max(bid_number)
   INTO v_oldBid
   FROM pon_bid_headers
   WHERE auction_header_id = p_auctionHeaderId
     AND trading_partner_id = v_tpid
     AND trading_partner_contact_id = v_tpcid
     AND bid_status <> 'DISQUALIFIED'
     AND decode (p_discard_tech_nonshort, 'Y', technical_shortlist_flag, 'Y') = 'Y'
     AND bid_number <> p_bidNumber
     AND vendor_site_id = p_vendorSiteId
     AND bid_status <> 'DRAFT';

   IF (v_oldBid IS NOT NULL) THEN
     UPDATE pon_bid_item_prices bidline
     SET rank = (SELECT oldbidline.rank
                 FROM pon_bid_item_prices oldbidline
                 WHERE oldbidline.bid_number = v_oldBid
                   AND oldbidline.line_number= bidline.line_number)
     WHERE bidline.bid_number = p_bidNumber
       AND bidline.publish_date <> v_publish_date
       AND bidline.line_number >= p_batchStart
       AND bidline.line_number <= p_batchEnd;
   END IF;

   print_log(l_api_name || '.END', ' ');

EXCEPTION
  -- If the user does not have a previous bid then do nothing...
  WHEN NO_DATA_FOUND THEN null;

END update_unchanged_rank;



-- This function checks that PE have not changed in the ReBid Scenario ....
     FUNCTION is_PE_Changed(x_oldBidNumber IN NUMBER,
                            x_newBidNumber IN NUMBER,
                            x_lineNumber   IN NUMBER)
     RETURN BOOLEAN IS
          return_value NUMBER := 0;
          l_api_name            CONSTANT VARCHAR2(30) := 'is_PE_Changed';
     BEGIN
             -- logging
             print_log(l_api_name || '.BEGIN', ' ');
             print_log(l_api_name, 'x_oldBidNumber=' || x_oldBidNumber);
             print_log(l_api_name, 'x_newBidNumber=' || x_newBidNumber);
             print_log(l_api_name, 'x_lineNumber=' || x_lineNumber );

             select count(*)
             into return_value
             from PON_BID_PRICE_ELEMENTS b1,PON_BID_PRICE_ELEMENTS b2
             where b1.bid_number = x_oldBidNumber
             and b1.line_number = x_lineNumber
             and b2.bid_number = x_newBidNumber
             and b2.line_number = b1.line_number
             and b2.SEQUENCE_NUMBER = b1.SEQUENCE_NUMBER
             and b2.BID_CURRENCY_VALUE <> b1.BID_CURRENCY_VALUE;

             if ( return_value = 0 ) then
                 print_log(l_api_name || '.END', ' ');
                 return FALSE;
             else
                 print_log(l_api_name || '.END', ' ');
                 return TRUE;
             end if;

             print_log(l_api_name || '.END', ' ');
             return FALSE;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
             print_log(l_api_name || '.END', ' ');
             return FALSE;
     END;

-- This function checks that MAS have not changed in the ReBid Scenario ....
     FUNCTION is_MAS_Changed(x_oldBidNumber IN NUMBER,
                            x_newBidNumber IN NUMBER,
                            x_lineNumber   IN NUMBER)
     RETURN BOOLEAN IS
          l_api_name            CONSTANT VARCHAR2(30) := 'is_MAS_Changed';
          return_value NUMBER := 0;
     BEGIN
             -- logging
             print_log(l_api_name || '.BEGIN', ' ');
             print_log(l_api_name, 'x_oldBidNumber=' || x_oldBidNumber);
             print_log(l_api_name, 'x_newBidNumber=' || x_newBidNumber);
             print_log(l_api_name, 'x_lineNumber=' || x_lineNumber);

             select count(*)
             into return_value
             from PON_BID_ATTRIBUTE_VALUES b1,PON_BID_ATTRIBUTE_VALUES b2
             where b1.bid_number = x_oldBidNumber
             and b1.line_number = x_lineNumber
             and b2.bid_number = x_newBidNumber
             and b2.line_number = b1.line_number
             and b2.SEQUENCE_NUMBER = b1.SEQUENCE_NUMBER
             --and b2.SCORE <> b1.SCORE;
             and b2.value <> b1.value;

             if ( return_value = 0 ) then
                 print_log(l_api_name || '.END', ' ');
                 return  FALSE;
             else
                 print_log(l_api_name || '.END', ' ');
                 return TRUE;
             end if;

             print_log(l_api_name || '.END', ' ');
             return FALSE;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
             print_log(l_api_name || '.END', ' ');
             return FALSE;
     END;


     FUNCTION get_most_recent_bid_number(x_auction_header_id IN NUMBER,
				       x_trading_partner_id IN NUMBER,
				       x_trading_partner_contact_id IN NUMBER)
       RETURN NUMBER IS

          l_api_name            CONSTANT VARCHAR2(30) := 'get_most_recent_bid_number';
	  x_bid_number NUMBER := NULL;

	  CURSOR bid_number IS
	     SELECT bid_number
	       FROM pon_bid_headers
	       WHERE auction_header_id = x_auction_header_id
	       AND trading_partner_id = x_trading_partner_id
	       AND trading_partner_contact_id = x_trading_partner_contact_id
	       AND bid_status IN ('ACTIVE', 'DRAFT', 'DISQUALIFIED')
	       AND Nvl(award_status, 'NONE') <> 'COMMITTED'
	       ORDER BY decode(bid_status, 'DRAFT', 1, 'ACTIVE', 2, 'DISQUALIFIED', 3) ASC;

     BEGIN

        -- logging
        print_log(l_api_name || '.BEGIN', ' ');
        print_log(l_api_name, 'x_auction_header_id=' || x_auction_header_id);
        print_log(l_api_name, 'x_trading_partner_id=' || x_trading_partner_id);
        print_log(l_api_name, 'x_trading_partner_contact_id=' || x_trading_partner_contact_id);

	OPEN bid_number;
	FETCH bid_number INTO x_bid_number;
	CLOSE bid_number;

        print_log(l_api_name || '.END', ' ');
	RETURN (x_bid_number);

     END get_most_recent_bid_number;


     -- this function returns whether x_price1 is better than x_price2
     -- in case they are equal, x_price1 will be better only if price2 is
     -- a proxy bid and x_price1 is not
--
     FUNCTION is_better_proxy_price(x_price1 IN NUMBER,
                                    x_bidNumber IN NUMBER,
                                    x_proxy1 IN VARCHAR2,
                                    x_date1  IN DATE,
                                    x_price2 IN NUMBER,
                                    x_triggerNumber IN NUMBER,
                                    x_date2  IN DATE)
     RETURN VARCHAR2 IS
     --
     t1 VARCHAR2(10) := 'TRUE';
     t2 VARCHAR2(10) := 'FALSE';
     --
     BEGIN
	   --added null check for bug 18194203 fix
       IF x_price2 is null THEN
		 RETURN t1;
       END IF;

       IF (x_price1 = x_price2) THEN
         --IF (abs(x_date1 - x_date2) < 3 ) THEN
         IF (x_date1  =  x_date2 ) THEN
           IF (( x_bidNumber = x_triggerNumber ) AND (not (x_proxy1 = 'Y'))) THEN
             RETURN t1;
           END IF;
           --
           RETURN t2;
         ELSIF (x_date1 > x_date2) THEN
            RETURN t2;
         END IF;
         --
         RETURN t1;
       END IF;
       --
       IF (x_price1 < x_price2) THEN
         RETURN t1;
       END IF;
       --
       RETURN t2;
     END;
--
     -- This will be the MAS equivalent of is_better_proxy_price
     FUNCTION is_better_proxy_price_by_score(x_price1 IN NUMBER,
                                             x_score1 IN NUMBER,
                                             x_proxy1 IN VARCHAR2,
                                             x_bidNumber IN NUMBER,
                                             x_date1  IN DATE,
                                             x_price2 IN NUMBER,
                                             x_score2 IN NUMBER,
                                             x_triggerNumber IN NUMBER,
                                             x_date2  IN DATE)
     RETURN VARCHAR2 IS
     --
     t1 VARCHAR2(10) := 'TRUE';
     t2 VARCHAR2(10) := 'FALSE';
     --
     BEGIN

	   --added null check for bug 18194203 fix
	   IF x_price2 is null THEN
		 RETURN t1;
       END IF;
       IF (x_score1/x_price1 = x_score2/x_price2) THEN
         IF (x_date1 = x_date2) THEN
           IF (( x_bidNumber = x_triggerNumber ) AND (not (x_proxy1 = 'Y'))) THEN
             RETURN t1;
           END IF;
           --
           RETURN t2;
         ELSIF (x_date1 > x_date2) THEN
            RETURN t2;
         END IF;
         --
         RETURN t1;
       END IF;
       --
       IF ((x_score1/x_price1) > (x_score2/x_price2)) THEN
         RETURN t1;
       END IF;
       --
       RETURN t2;
     END;
--
--
--
--===================
-- PROCEDURES
--===================
PROCEDURE get_active_bid(p_auctionHeaderId         IN  NUMBER,
                         p_tradingPartnerId        IN  NUMBER,
                         p_tradingPartnerContactId IN  NUMBER,
                         x_bidNumber               OUT NOCOPY NUMBER)
IS
l_api_name            CONSTANT VARCHAR2(30) := 'get_active_bid';
BEGIN

  -- logging
  print_log(l_api_name || '.BEGIN', ' ');
  print_log(l_api_name, 'p_auctionHeaderId=' ||p_auctionHeaderId );
  print_log(l_api_name, 'p_tradingPartnerId=' || p_tradingPartnerId);
  print_log(l_api_name, 'p_tradingPartnerContactId=' || p_tradingPartnerContactId);

  SELECT bid_number
  INTO x_bidNumber
  FROM pon_bid_headers
  WHERE auction_header_id = p_auctionHeaderId
  AND trading_partner_id = p_tradingPartnerId
  AND trading_partner_contact_id = p_tradingPartnerContactId
  AND bid_status = 'ACTIVE';

  print_log(l_api_name || '.END', ' ');
END get_active_bid;



PROCEDURE cancel_line_proxy
( p_auctionHeaderId         IN  NUMBER
, p_bidRanking              IN  VARCHAR2
, p_lineNumber              IN  NUMBER
, p_bidNumber               IN  NUMBER
, p_price                   IN  NUMBER
, p_proxyBidLimitPrice      IN  NUMBER
, x_status                  OUT NOCOPY VARCHAR2
)
IS
l_api_name            CONSTANT VARCHAR2(30) := 'cancel_line_proxy';
BEGIN

  -- logging
  print_log(l_api_name || '.BEGIN', ' ');
  print_log(l_api_name, 'p_auctionHeaderId=' ||p_auctionHeaderId );
  print_log(l_api_name, 'p_bidRanking=' || p_bidRanking);
  print_log(l_api_name, 'p_lineNumber=' || p_lineNumber);
  print_log(l_api_name, 'p_bidNumber=' || p_bidNumber );
  print_log(l_api_name, 'p_price=' ||  p_price);
  print_log(l_api_name, 'p_proxyBidLimitPrice=' || p_proxyBidLimitPrice);

  -- if line is proxying
  IF p_proxyBidLimitPrice IS NOT NULL AND p_price <> p_proxyBidLimitPrice THEN
    -- cancel proxy bid for line
    UPDATE pon_bid_item_prices
    SET proxy_bid_limit_price = price,
        bid_currency_limit_price = bid_currency_price,
        cancelled_limit_price = p_proxyBidLimitPrice,
        publish_date = sysdate,
        last_update_date = sysdate
    WHERE bid_number = p_bidNumber
    AND line_number = p_lineNumber;
    --
    -- if current bid is the winner, reset proxy limit price in item
    UPDATE pon_auction_item_prices_all
    SET best_bid_proxy_limit_price = best_bid_price
    WHERE auction_header_id = p_auctionHeaderId
    AND line_number = p_lineNumber
    AND best_bid_number = p_bidNumber;

    x_status := 'PROXY_CANCELLED';
  ELSE
    x_status := 'NO_ACTIVE_PROXY_BID';
  END IF;
  print_log(l_api_name || '.END', ' ');
END cancel_line_proxy;
--
--
PROCEDURE cancel_all_proxy_bid_lines
( p_auctionHeaderId         IN  NUMBER
, p_tradingPartnerId        IN  NUMBER
, p_tradingPartnerContactId IN  NUMBER
, x_status                  OUT NOCOPY VARCHAR2
)
IS
--
  l_api_name            CONSTANT VARCHAR2(30) := 'cancel_all_proxy_bid_lines';

  l_auctionHeaderId pon_auction_headers_all.auction_header_id%TYPE;
  l_bidRanking pon_auction_headers_all.bid_ranking%TYPE;
  l_auctionStatus pon_auction_headers_all.auction_status%TYPE;
  l_closeBiddingDate pon_auction_headers_all.close_bidding_date%TYPE;
  l_bidNumber pon_bid_item_prices.bid_number%TYPE;
  l_price pon_bid_item_prices.price%TYPE;
  l_proxyBidLimitPrice pon_bid_item_prices.proxy_bid_limit_price%TYPE;
  --
  no_active_bid_error EXCEPTION;
  --
  CURSOR c_proxyBids (p_bidNumber NUMBER) IS
  SELECT
    pbip.line_number,
    pbip.price,
    pbip.proxy_bid_limit_price
  FROM
    pon_bid_item_prices pbip,
    pon_auction_item_prices_all paip,
    pon_auction_headers_all paha
  WHERE
    pbip.bid_number = p_bidNumber
    AND paip.auction_header_id = p_auctionHeaderId
    AND paha.auction_header_id = p_auctionHeaderId
    AND paip.line_number = pbip.line_number
    AND pbip.proxy_bid_limit_price IS NOT NULL
    AND pbip.price <> pbip.proxy_bid_limit_price
    AND nvl(paip.close_bidding_date, paha.close_bidding_date) >= decode (nvl (paha.is_paused, 'N'), 'Y', paha.last_pause_date, sysdate);
--
BEGIN

  -- logging
  print_log(l_api_name || '.BEGIN', ' ');
  print_log(l_api_name, 'p_auctionHeaderId=' || p_auctionHeaderId);
  print_log(l_api_name, 'p_tradingPartnerId=' ||  p_tradingPartnerId);
  print_log(l_api_name, 'p_tradingPartnerContactId=' || p_tradingPartnerContactId);

  -- get the lock on the header row
  SELECT auction_header_id, bid_ranking, auction_status, DECODE ( NVL( is_paused, 'N'), 'Y', ( sysdate + ( close_bidding_date - last_pause_date ) ), close_bidding_date )
  INTO l_auctionHeaderId, l_bidRanking, l_auctionStatus, l_closeBiddingDate
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_auctionHeaderId
  FOR UPDATE OF CLOSE_BIDDING_DATE;
  --
  BEGIN
    -- verify if auction is closed/cancelled etc.
    IF SYSDATE > l_closeBiddingDate THEN
      x_status := 'AUCTION_CLOSED';
      print_log(l_api_name || '.END', ' ');
      RETURN;
    ELSIF l_auctionStatus = 'CANCELLED' THEN
      x_status := 'AUCTION_CANCELLED';
      print_log(l_api_name || '.END', ' ');
      RETURN;
    END IF;
    -- get the latest active bid
    print_log(l_api_name, 'calling subroutine get_active_bid');
    get_active_bid(p_auctionHeaderId, p_tradingPartnerId, p_tradingPartnerContactId, l_bidNumber);
    --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    x_status := 'NO_ACTIVE_BID';
    print_log(l_api_name || '.END', ' ');
    RETURN;
  END;
  --
  FOR cur in c_proxyBids(l_bidNumber) LOOP
    print_log(l_api_name, 'cursor=' || cur.line_number);
    -- cancel proxy on line
    print_log(l_api_name, 'calling subroutine cancel_line_proxy');
    cancel_line_proxy(p_auctionHeaderId, l_bidRanking, cur.line_Number, l_bidNumber, cur.price, cur.proxy_bid_limit_price, x_status);
  END LOOP;
  --
  x_status := 'ALL_PROXIES_CANCELLED';
  --
  print_log(l_api_name || '.END', ' ');
  --
END cancel_all_proxy_bid_lines;
--
--
PROCEDURE cancel_proxy_bid_line
( p_auctionHeaderId         IN  NUMBER
, p_lineNumber              IN  NUMBER
, p_bidNumber               IN  NUMBER
, p_tradingPartnerId        IN  NUMBER
, p_tradingPartnerContactId IN  NUMBER
, x_bidNumber               OUT NOCOPY NUMBER
, x_status                  OUT NOCOPY VARCHAR2
)
IS
--
  l_api_name            CONSTANT VARCHAR2(30) := 'cancel_proxy_bid_line';

  l_auctionHeaderId pon_auction_headers_all.auction_header_id%TYPE;
  l_bidRanking pon_auction_headers_all.bid_ranking%TYPE;
  l_auctionStatus pon_auction_headers_all.auction_status%TYPE;
  l_closeBiddingDate pon_auction_headers_all.close_bidding_date%TYPE;
  l_bidNumber pon_bid_item_prices.bid_number%TYPE;
  l_price pon_bid_item_prices.price%TYPE;
  l_proxyBidLimitPrice pon_bid_item_prices.proxy_bid_limit_price%TYPE;
  --
  no_active_bid_error EXCEPTION;
--
BEGIN

  -- logging
  print_log(l_api_name || '.BEGIN', ' ');
  print_log(l_api_name, 'p_auctionHeaderId=' || p_auctionHeaderId);
  print_log(l_api_name, 'p_lineNumber=' || p_lineNumber);
  print_log(l_api_name, 'p_bidNumber=' || p_bidNumber);
  print_log(l_api_name, 'p_tradingPartnerId=' || p_tradingPartnerId);
  print_log(l_api_name, 'p_tradingPartnerContactId=' || p_tradingPartnerContactId);

  -- if this is the first run of the procedure, bid number will be 0
  IF p_bidNumber = 0 THEN
    -- get the lock on the header row
    SELECT auction_header_id, bid_ranking, auction_status, DECODE ( NVL( is_paused, 'N'), 'Y', ( sysdate + ( close_bidding_date - last_pause_date ) ), close_bidding_date )
    INTO l_auctionHeaderId, l_bidRanking, l_auctionStatus, l_closeBiddingDate
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auctionHeaderId
    FOR UPDATE OF CLOSE_BIDDING_DATE;
    --
    BEGIN
      -- verify if auction is closed/cancelled etc.
      IF SYSDATE > l_closeBiddingDate THEN
        x_status := 'AUCTION_CLOSED';
        print_log(l_api_name || '.END', ' ');
        RETURN;
      ELSIF l_auctionStatus = 'CANCELLED' THEN
        x_status := 'AUCTION_CANCELLED';
        print_log(l_api_name || '.END', ' ');
        RETURN;
      END IF;
      -- get the latest active bid
      print_log(l_api_name, 'calling subroutine get_active_bid');
      get_active_bid(p_auctionHeaderId, p_tradingPartnerId, p_tradingPartnerContactId, l_bidNumber);
      --
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      x_status := 'NO_ACTIVE_BID';
      print_log(l_api_name || '.END', ' ');
      RETURN;
    END;
  ELSE
    l_bidNumber := p_bidNumber;
  END IF;
  x_bidNumber := l_bidNumber;
  --
  -- get proxy info
  SELECT price, proxy_bid_limit_price
  INTO l_price, l_proxyBidLimitPrice
  FROM pon_bid_item_prices
  WHERE bid_number = l_bidNumber
  AND line_number = p_lineNumber;
  --
  -- cancel proxy on line
  print_log(l_api_name, 'calling subroutine cancel_line_proxy');
  cancel_line_proxy(p_auctionHeaderId, l_bidRanking, p_lineNumber, l_bidNumber, l_price, l_proxyBidLimitPrice, x_status);
  --
  print_log(l_api_name || '.END', ' ');
  --
END cancel_proxy_bid_line;
--
--
--
--========================================================================
-- PROCEDURE : check_is_bid_valid      PUBLIC
-- PARAMETERS:
-- VERSION   : current version         1.x
--             initial version         1.0
-- COMMENT   : this will be used by Save Draft routine to validate
--             simple things.  This is also called by update_auction_info
--========================================================================

PROCEDURE check_is_bid_valid ( p_auctionHeaderId IN NUMBER,
                               p_bidNumber IN NUMBER,
                               p_vendorSiteId IN NUMBER,
                               p_prevBidNumber IN NUMBER,
                               p_isRebid IN VARCHAR2,
                               p_isSavingDraft IN VARCHAR2,
                               p_surrogBidFlag IN VARCHAR2,
                               p_publishDate IN DATE,
                               x_return_status OUT NOCOPY NUMBER,
                               x_return_code OUT NOCOPY VARCHAR2)

IS
  v_oldBidNumber pon_bid_headers.bid_number%TYPE;
  v_bidStatus pon_bid_headers.bid_status%TYPE;
  v_oldNonProxyBidNumber pon_bid_headers.bid_number%TYPE;
  v_recentActiveBidNumber pon_bid_headers.bid_number%TYPE;
  v_recentBidStatus pon_bid_headers.bid_status%TYPE;
  v_is_paused pon_auction_headers_all.is_paused%TYPE;

  v_bidTradingPartnerId pon_bid_headers.trading_partner_id%TYPE;
  v_sameCompanyBids NUMBER;
  v_sameCompanyDrafts NUMBER;
  v_bidFrequencyCode pon_auction_headers_all.bid_frequency_code%TYPE;
  v_negotiation_closed_line_num NUMBER;

  l_api_name VARCHAR2(40) := 'check_is_bid_valid';

BEGIN

  print_log(l_api_name, p_bidNumber || ': begin check_is_bid_valid ' ||
    'p_auctionHeaderId = ' || p_auctionHeaderId ||
    ', p_bidNumber =' || p_bidNumber ||
    ', p_vendorSiteId = ' || p_vendorSiteId ||
    ', p_prevBidNumber = ' || p_prevBidNumber ||
    ', p_isRebid = ' || p_isRebid ||
    ', p_isSavingDraft = ' || p_isSavingDraft ||
    ', p_surrogBidFlag = ' || p_surrogBidFlag ||
    ', p_publishDate = ' || to_char (p_publishDate, 'dd-mon-yyyy hh24:mi:ss'));
  --
  -- Get the user's most recent bid
  -- (in R12, we use p_prevBidNumber)
  --get_previous_bid(p_auctionHeaderId, p_bidNumber, v_oldBidNumber);
  v_oldBidNumber := p_prevBidNumber;

  -- IS BID ON CLOSED LINES
  -- If any negotiation lines have closed while bidding
  -- we need to throw an error asking the user to delete
  -- the draft
  print_log(l_api_name, p_bidNumber || 'Checking if this is nonsurrogate and bid on closed lines.');
  IF (p_isSavingDraft = 'N' AND nvl (p_surrogBidFlag, 'N') = 'N') THEN

    print_log(l_api_name, p_bidNumber || 'Executing query to find closed lines');

    BEGIN
      -- To determine if a line is newly added/modified in this bid we use the
      -- column is_changed_line_flag. This follows the logic in publish_lines
      -- where we set the publish_date on the lines based on this flag.
      SELECT paip.line_number
      INTO v_negotiation_closed_line_num
      FROM pon_bid_item_prices pbip,
           pon_auction_item_prices_all paip,
           pon_auction_headers_all paha
      WHERE paip.auction_header_id = p_auctionHeaderId
      AND pbip.auction_header_id = p_auctionHeaderId
      AND paha.auction_header_id = p_auctionHeaderId
      AND pbip.bid_number = p_bidNumber
      AND paip.line_number = pbip.auction_line_number
      AND pbip.is_changed_line_flag = 'Y' -- bug#9850962
      AND p_publishDate > nvl (paip.close_bidding_date, paha.close_bidding_date)
      AND rownum = 1;

      print_log(l_api_name, p_bidNumber || 'Found one line that is closed.');

      x_return_code := 'BID_ON_CLOSED_LINE';
      x_return_status := 1;
      RETURN;

      EXCEPTION WHEN NO_DATA_FOUND THEN
        print_log(l_api_name, p_bidNumber || 'Cound not find any line.');
    END;
  END IF;

  --
  -- First check to see if the user's old bid was
  -- disqualified by the auctioneer
  --
  IF (v_oldBidNumber is not null) THEN
    SELECT bid_status
    INTO v_bidStatus
    FROM pon_bid_headers
    WHERE bid_number = v_oldBidNumber;

    IF(nvl(p_isRebid,'N') = 'Y') THEN

      IF(v_bidStatus = 'DISQUALIFIED') THEN
        x_return_code := 'DISQ_REBID';
        x_return_status := 1;
        RETURN;
      END IF;
    ELSE
      IF(v_bidStatus = 'DISQUALIFIED') THEN
        v_oldBidNumber := NULL;
      END IF;
    END IF;
  END IF;


  get_previous_nonproxy_bid(p_auctionHeaderId,p_bidNumber,p_vendorSiteId, v_oldNonProxyBidNumber);

  get_most_recent_active_bid(p_auctionHeaderId,p_bidNumber,v_recentActiveBidNumber, v_recentBidStatus);


  --
  -- First check to see if the user's old bid is superseeded by
  -- another bid from the same user (by using a different session)
  --
  -- need to raise a rebid_error in case a draft is submitted as a bid in one session
  -- and the same draft is tried to be updated in the second session at the same time
  --
  -- condition 1 is satisfied when
  -- the user is bidding on an auction (fresh bid)
  -- but in some other session, a bid has been placed (manual bid)
  -- which is not placed due to proxy got kicked in

  -- new condition (due to draft bid project)
  -- prevBidNumber is null (fresh_bid)
  -- user is editing a draft (in 2 separate sessions)
  -- session one : the user saves the draft as a bid
  -- session two : the user tries to save the draft as a draft
  -- this condition will be trapped in the 1st condition above

  -- condition 2 is satisfied when
  -- when user is re-bidding on an auction
  -- but in some other session, the same user did re-bid
  -- hence got a new non-proxied bid number

  IF ((p_prevBidNumber is null) AND
      (v_oldNonProxyBidNumber is not null) ) THEN
    x_return_code := 'MULTIPLE_REBID';
    x_return_status := 1;
    RETURN;
  ELSE
    IF ((p_prevBidNumber is not null) AND
        (v_oldNonProxyBidNumber is not null)) THEN
      IF (v_oldNonProxyBidNumber > p_prevBidNumber) THEN
        x_return_code := 'MULTIPLE_REBID';
        x_return_status := 1;
        RETURN;
      END IF;
    END IF;
  END IF;



  -- need to check the bid status has changed or not
  -- since while saving a draft bid as an active bid
  -- the bid number does not change

  -- check whether following conditions are satisfied:
  -- 1. user is editing a draft (in 2 separate sessions)
  -- 2. prevBidNumber is not null (re-bid)
  -- 3. Draft bid number is same as the most recent active bid from the same user
  -- session one : the user saves the draft as an active bid - an active bid exists in the database
  -- session two : the user tried to save the draft as a draft
  -- the user in session two gets an error

  IF(p_isSavingDraft = 'Y' AND
	v_recentActiveBidNumber is not null AND
	p_bidNumber = v_recentActiveBidNumber AND
	v_recentBidStatus = 'ACTIVE') THEN
      x_return_code := 'MULTIPLE_DRAFTS';
      x_return_status := 1;
      RETURN;
  END IF;

  --  if the auction is a single bid auction and another user
  --  from the same company has already bid then throw exception
  SELECT bid_frequency_code
  INTO v_bidFrequencyCode
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_auctionHeaderId;

  IF v_bidFrequencyCode = 'SINGLE_BID_ONLY' THEN
    -- get a hold of company's tp id
    SELECT TRADING_PARTNER_ID
      INTO v_bidTradingPartnerId
    FROM PON_BID_HEADERS
    WHERE AUCTION_HEADER_ID = p_auctionHeaderId
      AND BID_NUMBER = p_bidNumber;
    --
    -- check if there is more than one row in pon_bid_headers
    -- one from previous user's bid, one ours

    SELECT COUNT(bid_number)
      INTO v_sameCompanyBids
    FROM PON_BID_HEADERS
    WHERE AUCTION_HEADER_ID = p_auctionHeaderId
      AND BID_STATUS = 'ACTIVE'
      AND TRADING_PARTNER_ID = v_bidTradingPartnerId
      AND NVL(VENDOR_SITE_ID, -1) = NVL(p_vendorSiteId, -1)
      AND NVL(EVALUATION_FLAG, 'N') = 'N';    -- Added for ER: Supplier Management: Supplier Evaluation
    --
    IF v_sameCompanyBids > 1 THEN
      x_return_code := 'SINGLE_BEST_BID';
      x_return_status := 1;
      RETURN;
    END IF;

    -- also check whether there is another draft
    -- created in the meanwhile

    SELECT COUNT(bid_number)
      INTO v_sameCompanyDrafts
    FROM PON_BID_HEADERS
    WHERE AUCTION_HEADER_ID = p_auctionHeaderId
      AND (BID_STATUS = 'ACTIVE' OR BID_STATUS = 'DRAFT')
      AND TRADING_PARTNER_ID = v_bidTradingPartnerId
      AND NVL(VENDOR_SITE_ID, -1) = NVL(p_vendorSiteId, -1)
      AND NVL(EVALUATION_FLAG, 'N') = 'N';    -- Added for ER: Supplier Management: Supplier Evaluation
    --
    IF v_sameCompanyDrafts > 1 THEN
      x_return_code := 'SINGLE_BEST_DRAFT';
      x_return_status := 1;
      RETURN;
    END IF;

  END IF;


  -- IS PAUSED
  -- if the negotiation is paused and we're trying
  -- to publish the bid, then return with an error code.
  -- bug 4523484: do this check only for publish; not for savedraft
  IF(p_isSavingDraft = 'N') THEN
    SELECT nvl(is_paused, 'N')
    INTO v_is_paused
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auctionHeaderId;

    IF (v_is_paused = 'Y') THEN
      x_return_code := 'AUCTION_PAUSED';
      x_return_status := 1;
      RETURN;
    END IF;
  END IF;

  x_return_status := 0;

END check_is_bid_valid;






PROCEDURE update_disq_lines
( p_auctionHeaderId     IN NUMBER,
  p_bidNumber           IN NUMBER,
  p_rankIndicator       IN pon_auction_headers_all.rank_indicator%TYPE,
  p_bidRanking          IN pon_auction_headers_all.bid_ranking%TYPE,
  p_tpId                IN pon_bid_headers.trading_partner_id%TYPE,
  p_tpcId               IN pon_bid_headers.trading_partner_contact_id%TYPE,
  p_batchStart          IN NUMBER,
  p_batchEnd            IN NUMBER,
  p_ignore_tech_nonshortlist IN VARCHAR2)
IS

    l_api_name          CONSTANT VARCHAR2(30) := 'update_disq_lines';

    v_bestBidNumber     pon_auction_item_prices_all.lowest_bid_number%TYPE;
    v_bestBidBidNumber  pon_auction_item_prices_all.best_bid_bid_number%TYPE;

    TYPE t_tbl_number IS TABLE OF NUMBER
      INDEX BY PLS_INTEGER;

    TYPE t_tbl_date IS TABLE OF DATE
      INDEX BY PLS_INTEGER;

    TYPE t_tbl_varchar IS TABLE OF VARCHAR2(15)
      INDEX BY PLS_INTEGER;

    t_line_number t_tbl_number;
    t_price t_tbl_number;
    t_quantity t_tbl_number;
    t_promised_date t_tbl_date;
    t_bid_number t_tbl_number;
    t_bid_currency_price t_tbl_number;
    t_bid_currency_code t_tbl_varchar;
    t_first_bid_price t_tbl_number;
    t_proxy_bid_limit_price t_tbl_number;
    t_score t_tbl_number;
    t_number_of_bids t_tbl_number;
    v_counter PLS_INTEGER;


    CURSOR all_lines_cursor IS
       SELECT pbip.line_number, pbip.rank, pbh.technical_shortlist_flag
       FROM pon_bid_item_prices pbip, pon_bid_headers pbh
       WHERE pbh.auction_header_id = p_auctionHeaderId
         AND pbip.auction_header_id = pbh.auction_header_id
         AND pbh.bid_number = p_bidNumber
         AND pbip.bid_number = pbh.bid_number
         AND pbip.line_number >= p_batchStart
         AND pbip.line_number <= p_batchEnd
       ORDER BY pbip.line_number;

    CURSOR best_bid_lines_cursor IS
       SELECT line_number
       FROM pon_auction_item_prices_all
       WHERE auction_header_id = p_auctionHeaderId
         AND best_bid_number = p_bidNumber
         AND line_number >= p_batchStart
         AND line_number <= p_batchEnd
       ORDER BY line_number;

    CURSOR best_bid_bid_lines_cursor IS
       SELECT line_number
       FROM pon_auction_item_prices_all
       WHERE auction_header_id = p_auctionHeaderId
         AND best_bid_bid_number = p_bidNumber
         AND line_number >= p_batchStart
         AND line_number <= p_batchEnd
       ORDER BY line_number;

BEGIN


    print_log(l_api_name, p_bidNumber || ': begin update_disq_lines');

    -- UPDATE BEST_BID INFO
    -- The disqualified bid has the best bid for the current item line.
    -- We need to get a new best bid.
    t_line_number.DELETE;
    t_price.DELETE;
    t_quantity.DELETE;
    t_promised_date.DELETE;
    t_bid_number.DELETE;
    t_bid_currency_price.DELETE;
    t_bid_currency_code.DELETE;
    t_first_bid_price.DELETE;
    t_proxy_bid_limit_price.DELETE;
    v_counter := 1;

    print_log(l_api_name, p_bidNumber || ': update best bid lines');
    FOR best_bid_item_record IN best_bid_lines_cursor LOOP -- {

        -- Get auction item price information corresponding to this bid item
        SELECT best_bid_number
        INTO v_bestBidNumber
        FROM pon_auction_item_prices_all
        WHERE auction_header_id = p_auctionHeaderId
          AND line_number = best_bid_item_record.line_number;

        IF (v_bestBidNumber = p_bidNumber) THEN -- {

          print_log(l_api_name, 'line ' || best_bid_item_record.line_number
            || ': need to update best_bid info');

          BEGIN  -- {
            SELECT line_number,
                   price,
                   quantity,
                   promised_date,
                   bid_number,
                   bid_currency_price,
                   bid_currency_code,
                   first_bid_price,
                   proxy_bid_limit_price
            INTO t_line_number(v_counter),
                 t_price(v_counter),
                 t_quantity(v_counter),
                 t_promised_date(v_counter),
                 t_bid_number(v_counter),
                 t_bid_currency_price(v_counter),
                 t_bid_currency_code(v_counter),
                 t_first_bid_price(v_counter),
                 t_proxy_bid_limit_price(v_counter)
            FROM (SELECT bidline.line_number,
                         bidline.price,
                         bidline.quantity,
                         bidline.promised_date,
                         bidline.bid_number,
                         bidline.bid_currency_price,
                         bidheader.bid_currency_code,
                         bidline.first_bid_price,
                         bidline.proxy_bid_limit_price
                  FROM pon_bid_item_prices bidline,
                       pon_bid_headers bidheader
                  WHERE bidline.auction_header_id = p_auctionHeaderId
                    AND bidheader.auction_header_id = bidline.auction_header_id
                    AND bidheader.bid_number = bidline.bid_number
                    AND bidheader.bid_status = 'ACTIVE'
                    AND (
                         (p_ignore_tech_nonshortlist = 'Y' AND bidheader.technical_shortlist_flag = 'Y')
                         OR
                         (p_ignore_tech_nonshortlist = 'N')
                        )
                    AND bidheader.bid_number <> p_bidNumber
                    AND bidline.line_number = best_bid_item_record.line_number
                  ORDER BY decode(group_amount,null,bidline.price, group_amount), bidline.publish_date asc)
            WHERE rownum = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              print_log(l_api_name, '    line ' || best_bid_item_record.line_number || ': no replacement best bid was found; nulling out best bid info');
              t_line_number(v_counter) := best_bid_item_record.line_number;
              t_price(v_counter) := null;
              t_quantity(v_counter) := null;
              t_promised_date(v_counter) := null;
              t_bid_number(v_counter) := null;
              t_bid_currency_price(v_counter) := null;
              t_bid_currency_code(v_counter) := null;
              t_first_bid_price(v_counter) := null;
              t_proxy_bid_limit_price(v_counter) := null;
          END; -- }

            v_counter := v_counter + 1;

        END IF; -- }
    END LOOP; -- }

    print_log(l_api_name, p_bidNumber || ': updating best bid info with data structs');
    FORALL x IN 1..t_line_number.COUNT
      UPDATE pon_auction_item_prices_all
      SET best_bid_price = t_price(x),
          best_bid_quantity = t_quantity(x),
          best_bid_promised_date = t_promised_date(x),
          best_bid_number = t_bid_number(x),
          best_bid_currency_price = t_bid_currency_price(x),
          best_bid_currency_code = t_bid_currency_code(x),
          best_bid_first_bid_price = t_first_bid_price(x),
          best_bid_proxy_limit_price = t_proxy_bid_limit_price(x)
      WHERE auction_header_id = p_auctionHeaderId
        AND line_number = t_line_number(x);


    -- UPDATE BEST_BID_BID_INFO
    -- The disqualified bid has the best bid for the current item line.
    -- We need to get a new best bid.
    IF(p_bidRanking = 'MULTI_ATTRIBUTE_SCORING') THEN
        print_log(l_api_name, p_bidNumber || ': updating best bid bid information');
        t_line_number.DELETE;
        t_price.DELETE;
        t_bid_number.DELETE;
        t_bid_currency_price.DELETE;
        t_bid_currency_code.DELETE;
        t_score.DELETE;
        v_counter := 1;
        FOR best_bid_bid_item_record IN best_bid_bid_lines_cursor LOOP

            SELECT best_bid_bid_number
            INTO v_bestBidBidNumber
            FROM pon_auction_item_prices_all
            WHERE auction_header_id = p_auctionHeaderId
              AND line_number = best_bid_bid_item_record.line_number;

            IF (v_bestBidBidNumber = p_bidNumber) THEN

              BEGIN
                SELECT line_number,
                       price,
                       total_weighted_score,
                       bid_number,
                       bid_currency_price,
                       bid_currency_code
                INTO t_line_number(v_counter),
                     t_price(v_counter),
                     t_score(v_counter),
                     t_bid_number(v_counter),
                     t_bid_currency_price(v_counter),
                     t_bid_currency_code(v_counter)
                FROM (SELECT bidline.line_number,
                             bidline.price,
                             bidline.total_weighted_score,
                             bidline.bid_number,
                             bidline.bid_currency_price,
                             bidheader.bid_currency_code
                      FROM pon_bid_item_prices bidline,
                           pon_bid_headers bidheader
                      WHERE bidline.auction_header_id = p_auctionHeaderId
                        AND bidheader.auction_header_id = bidline.auction_header_id
                        AND bidheader.bid_number = bidline.bid_number
                        AND bidheader.bid_status = 'ACTIVE'
                        AND (
                             (p_ignore_tech_nonshortlist = 'Y' AND bidheader.technical_shortlist_flag = 'Y')
                             OR
                             (p_ignore_tech_nonshortlist = 'N')
                            )
                        AND bidheader.bid_number <> p_bidNumber
                        AND bidline.line_number = best_bid_bid_item_record.line_number
                      ORDER BY decode(bidline.group_amount, null, bidline.total_weighted_score/bidline.price, -bidline.group_amount) desc,
                               bidline.publish_date asc)
                WHERE rownum = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                print_log(l_api_name, '    line ' || best_bid_bid_item_record.line_number || ': no replacement best bid was found; nulling out best bid info');
                t_line_number(v_counter) := best_bid_bid_item_record.line_number;
                t_price(v_counter) := null;
                t_score(v_counter) := null;
                t_bid_number(v_counter) := null;
                t_bid_currency_price(v_counter) := null;
                t_bid_currency_code(v_counter) := null;
              END;

              v_counter := v_counter + 1;

            END IF;
        END LOOP;

        print_log(l_api_name, p_bidNumber || ': updating best bid bid info with data structs');
        FORALL x IN 1..t_line_number.COUNT
        UPDATE pon_auction_item_prices_all
        SET best_bid_bid_price = t_price(x),
            best_bid_score = t_score(x),
            best_bid_bid_number = t_bid_number(x),
            best_bid_bid_currency_price = t_bid_currency_price(x),
            best_bid_bid_currency_code = t_bid_currency_code(x)
        WHERE auction_header_id = p_auctionHeaderId
          AND line_number = t_line_number(x);

    END IF;

    -- For each item line in the bid, update the best price and rank
    print_log(l_api_name, p_bidNumber || ': for each line, update the numOfBids and rank');
    t_line_number.DELETE;
    t_number_of_bids.DELETE;
    v_counter := 1;
    FOR bid_item_record IN all_lines_cursor LOOP -- {

        SELECT number_of_bids - (SELECT COUNT(bh.bid_number)
                                 FROM pon_bid_headers bh,
                                      pon_bid_item_prices bip
                                 WHERE bh.auction_header_id = p_auctionHeaderId
                                   AND bh.trading_partner_contact_id = p_tpcId
                                   AND bh.trading_partner_id = p_tpId
                                   AND (bh.bid_status = 'ARCHIVED' OR bh.bid_number = p_bidNumber)
                                   AND bh.bid_number = bip.bid_number
                                   AND bh.publish_date = bip.publish_date
                                   AND bip.line_number = bid_item_record.line_number),
               line_number
        INTO t_number_of_bids(v_counter),
             t_line_number(v_counter)
        FROM pon_auction_item_prices_all
        WHERE auction_header_id = p_auctionHeaderId
          AND line_number = bid_item_record.line_number;

        -- UPDATE RANK FOR BIDS LOWER THAN THE DISQ BID
        -- (uday) If the bid getting disqualified is a technically non-shortlisted bid
        -- then this update should not happen provided the RFQ is already commercially
        -- unlocked
        IF (p_rankIndicator = 'NUMBERING' AND (p_ignore_tech_nonshortlist = 'N'
          OR (p_ignore_tech_nonshortlist = 'Y' AND
            bid_item_record.technical_shortlist_flag = 'Y'))) THEN -- {

            UPDATE pon_bid_item_prices bip
            SET rank = rank - 1
            WHERE auction_header_id = p_auctionHeaderId
              AND line_number = bid_item_record.line_number
              AND EXISTS (SELECT 1
                          FROM pon_bid_headers h
                          WHERE h.bid_number = bip.bid_number
                            AND h.bid_status = 'ACTIVE')
              AND rank > bid_item_record.rank;

        END IF; -- }

        v_counter := v_counter + 1;
    END LOOP; -- }

    print_log(l_api_name, p_bidNumber || ': for each line, update the numOfBids and rank using structs');
    FORALL x IN 1..t_line_number.COUNT
    UPDATE pon_auction_item_prices_all
    SET number_of_bids = t_number_of_bids(x)
    WHERE auction_header_id = p_auctionHeaderId
      AND line_number = t_line_number(x);

    print_log(l_api_name, p_bidNumber || ': END update_disq_lines');
END update_disq_lines;

PROCEDURE update_disq_lines_batched
( p_auctionHeaderId     IN NUMBER,
  p_bidNumber           IN NUMBER,
  p_rankIndicator       IN pon_auction_headers_all.rank_indicator%TYPE,
  p_bidRanking          IN pon_auction_headers_all.bid_ranking%TYPE,
  p_tpId                IN pon_bid_headers.trading_partner_id%TYPE,
  p_tpcId               IN pon_bid_headers.trading_partner_contact_id%TYPE,
  p_maxLineNumber       IN NUMBER,
  p_batchSize           IN NUMBER,
  p_ignore_tech_nonshortlist IN VARCHAR2)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  v_batchStart NUMBER;
  v_batchEnd NUMBER;
 l_api_name          CONSTANT VARCHAR2(30) := 'update_disq_lines_batched';
BEGIN
  print_log(l_api_name, p_bidNumber || ': BEGIN update_disq_lines_batched');
  v_batchStart := 1;
  v_batchEnd := p_batchSize;

  WHILE (v_batchStart <= p_maxLineNumber) LOOP

    update_disq_lines(p_auctionHeaderId, p_bidNumber, p_rankIndicator, p_bidRanking,
                      p_tpId, p_tpcId, v_batchStart, v_batchEnd, p_ignore_tech_nonshortlist);
    commit;

    v_batchStart := v_batchEnd + 1;
    IF (v_batchEnd + p_batchSize > p_maxLineNumber) THEN
      v_batchEnd := p_maxLineNumber;
    ELSE
      v_batchEnd := v_batchEnd + p_batchSize;
    END IF;
  END LOOP;
 print_log(l_api_name, p_bidNumber || ': END update_disq_lines_batched');

END update_disq_lines_batched;



PROCEDURE update_auction_info_disqualify
( p_auctionHeaderId     IN NUMBER,
  p_bidNumber           IN NUMBER)
IS

    l_api_name          CONSTANT VARCHAR2(30) := 'update_auction_info_disqualify';

    v_tpcId             pon_bid_headers.trading_partner_contact_id%TYPE;
    v_tpId              pon_bid_headers.trading_partner_id%TYPE;
    v_rankIndicator     pon_auction_headers_all.rank_indicator%TYPE;
    v_bidRanking        pon_auction_headers_all.bid_ranking%TYPE;
    v_maxLineNumber     NUMBER;
    v_batchSize         NUMBER;
    v_batchingRequired  BOOLEAN;

    v_numOfBids NUMBER;

  v_two_part_flag pon_auction_headers_all.two_part_flag%TYPE;
  v_sealed_auction_status pon_auction_headers_all.sealed_auction_status%TYPE;
  v_ignore_tech_nonshortlist VARCHAR2(1);
BEGIN


    -- logging
    print_log(l_api_name || '.BEGIN', ' ');
    print_log(l_api_name, 'p_auctionHeaderId=' || p_auctionHeaderId);
    print_log(l_api_name, 'p_bidNumber=' || p_bidNumber);

    print_log(l_api_name, 'BEGIN update_auction_info_disqualify for p_bidNumber=' || p_bidNumber);

    -- Retrieve information from auction header
    SELECT rank_indicator,
           bid_ranking,
           max_internal_line_num,
           nvl (two_part_flag, 'N'),
           sealed_auction_status
      INTO v_rankIndicator,
           v_bidRanking,
           v_maxLineNumber,
           v_two_part_flag,
           v_sealed_auction_status
      FROM pon_auction_headers_all
     WHERE auction_header_id = p_auctionHeaderId
       FOR UPDATE OF CLOSE_BIDDING_DATE;

    print_log(l_api_name, 'rank_indicator = ' || v_rankIndicator ||
                          ', bid_ranking = ' || v_bidRanking ||
                          ', max_internal_line_num = ' || v_maxLineNumber ||
                          ', two_part_flag = ' || v_two_part_flag ||
                          ', sealed_auction_status = ' || v_sealed_auction_status);

    v_ignore_tech_nonshortlist := 'N';

    -- (uday) If a quote is getting disqualified after commercial unlock
    -- has happened then during re-ranking the technically non-shortlisted
    -- quotes should be ignored. (Two-Part RFQ Project)
    IF (v_two_part_flag = 'Y' AND v_sealed_auction_status <> 'LOCKED') THEN --{
      v_ignore_tech_nonshortlist := 'Y';
    END IF; --}

    SELECT trading_partner_contact_id,
           trading_partner_id
    INTO v_tpcId,
         v_tpId
    FROM pon_bid_headers
    WHERE bid_number = p_bidNumber;

    -- UPDATE AUCTION'S NUMBER OF BIDS
    -- BUG: 1540882
    -- Actually all archived bids are disqualified as well.
    -- +1 is for the currect active bid that is being disqualified.
    SELECT number_of_bids
    INTO v_numOfBids
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auctionHeaderId;
    print_log(l_api_name, p_bidNumber || ': original numOfBids=' || v_numOfBids);

    UPDATE pon_auction_headers_all
    SET last_update_date = sysdate,
      	number_of_bids = (number_of_bids -
                          (SELECT count(*)+1
                           FROM pon_bid_headers
                           WHERE auction_header_id = p_auctionHeaderId
                             AND trading_partner_contact_id = v_tpcId
                             AND bid_status = 'ARCHIVED'))
    WHERE auction_header_id = p_auctionHeaderId;

    SELECT number_of_bids
    INTO v_numOfBids
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auctionHeaderId;
    print_log(l_api_name, p_bidNumber || ': new numOfBids=' || v_numOfBids);

    -- for batching, we need to find out the max line number of
    -- this neg
    v_batchSize := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
    v_batchingRequired := (v_maxLineNumber > v_batchSize);

    IF (v_batchingRequired) THEN
      print_log(l_api_name, p_bidNumber || ': calling update_disq_lines_batched');
      update_disq_lines_batched(p_auctionHeaderId, p_bidNumber, v_rankIndicator, v_bidRanking,
                           v_tpId, v_tpcId, v_maxLineNumber, v_batchSize, v_ignore_tech_nonshortlist);
    ELSE
      print_log(l_api_name, p_bidNumber || ': calling update_disq_lines');
      update_disq_lines(p_auctionHeaderId, p_bidNumber, v_rankIndicator, v_bidRanking,
                             v_tpId, v_tpcId, 1, v_maxLineNumber, v_ignore_tech_nonshortlist);
    END IF;

    -- DISQ ALL PREVIOUS ARCHIVED BIDS
    print_log(l_api_name, p_bidNumber || ': disqualifying previous archived bids');
    UPDATE pon_bid_headers
    SET bid_status = 'DISQUALIFIED'
    WHERE auction_header_id = p_auctionHeaderId
      AND trading_partner_contact_id = v_tpcId
      AND bid_status = 'ARCHIVED';

    -- DELIVERABLES INTEGRATION
    -- Contracts - fpj project
    -- once the current bid is disqualified,
    -- we need to cancel all the deliverables on the bid
    -- rrkulkar
    IF(PON_CONTERMS_UTL_PVT.is_contracts_installed = FND_API.G_TRUE) then
        PON_CONTERMS_UTL_PVT.disqualifyDeliverables(p_bidNumber);
    END IF;

    print_log(l_api_name, p_bidNumber || ': END disqualify');
    print_log(l_api_name || '.END', ' ');

END  update_auction_info_disqualify;


procedure update_rank
(
  p_auctionHeaderId IN NUMBER,
  p_bidNumber       IN NUMBER,
  p_lineNumber      IN NUMBER,
  p_scoring_method  IN VARCHAR2,
  p_auction_type    IN VARCHAR2,
  p_oldRank	    IN NUMBER,
  p_price	    IN NUMBER,
  p_score	    IN NUMBER,
  p_proxy           IN VARCHAR2,
  p_date            IN DATE
)
IS
   v_new_rank NUMBER;
   l_api_name            CONSTANT VARCHAR2(30) := 'update_rank';
BEGIN
--
   -- logging
   print_log(l_api_name || '.BEGIN', ' ');
   print_log(l_api_name, 'p_auctionHeaderId=' || p_auctionHeaderId);
   print_log(l_api_name, 'p_bidNumber=' || p_bidNumber);
   print_log(l_api_name, 'p_lineNumber=' || p_lineNumber);
   print_log(l_api_name, 'p_scoring_method=' || p_scoring_method);
   print_log(l_api_name, 'p_auction_type=' || p_auction_type);
   print_log(l_api_name, 'p_oldRank=' || p_oldRank);
   print_log(l_api_name, 'p_price=' || p_price);
   print_log(l_api_name, 'p_score=' ||  p_score);
   print_log(l_api_name, 'p_proxy=' || p_proxy);
   print_log(l_api_name, 'p_date=' || p_date);

--
   print_log(l_api_name, 'calling subroutine is_better_proxy_price_by_score');
    select count(*) + 1
      into v_new_rank
      from pon_bid_item_prices ip, pon_bid_headers h
     where ip.auction_header_id = h.auction_header_id
       and h.auction_header_id = p_auctionHeaderId
       and h.bid_number = ip.bid_number
       and ip.line_number = p_lineNumber
       and h.bid_status = 'ACTIVE'
       and h.bid_number <> p_bidNumber
       and decode(p_scoring_method, 'MULTI_ATTRIBUTE_SCORING',
                         is_better_proxy_price_by_score(p_price,
                                            p_score,
                                            p_proxy,
                                            p_bidNumber,
                                            p_date,
                                            nvl(ip.group_amount,ip.price),
                                            ip.total_weighted_score,
                                            ip.trigger_bid_number,
                                            ip.publish_date)
                      ,
                         is_better_proxy_price(p_price,
                                            p_bidNumber,
                                            p_proxy,
                                            p_date,
                                            nvl(ip.group_amount,ip.price),
                                            ip.trigger_bid_number,
                                            ip.publish_date)
                 ) = 'FALSE';
--
       -- and decode (p_scoring_method, 'MULTI_ATTRIBUTE_SCORING', p_score / p_price , DECODE(p_auction_type, 'REVERSE', ip.price, p_price)) <=
       --     decode (p_scoring_method, 'MULTI_ATTRIBUTE_SCORING', ip.total_weighted_score / ip.price , DECODE(p_auction_type, 'REVERSE', p_price, ip.price));
--
    if (v_new_rank < p_oldRank) then
--
       update pon_bid_item_prices ip
          set rank = rank + 1
        where auction_header_id = p_auctionHeaderId
          and line_number = p_lineNumber
	  and exists (select 1
			from pon_bid_headers h
		       where h.bid_number = ip.bid_number
			 and h.bid_status = 'ACTIVE')
	  and rank between v_new_rank and p_oldRank;
--
    elsif (v_new_rank > p_oldRank) then
--
       update pon_bid_item_prices ip
          set rank = rank - 1
        where auction_header_id = p_auctionHeaderId
          and line_number = p_lineNumber
	  and exists (select 1
			from pon_bid_headers h
		       where h.bid_number = ip.bid_number
			 and h.bid_status = 'ACTIVE')
	  and rank between p_oldRank and v_new_rank ;
--
    end if;
--
    update pon_bid_item_prices
       set rank = v_new_rank
     where auction_header_id = p_auctionHeaderId
       and bid_number = p_bidNumber
       and line_number = p_lineNumber;
--

    print_log(l_api_name || '.END', ' ');
--
END;


FUNCTION get_bid_break_price(p_bid_number IN NUMBER,
			 p_line_number IN NUMBER,
			 p_ship_to_org IN NUMBER,
			 p_ship_to_loc IN NUMBER,
			 p_quantity IN NUMBER,
			 p_need_by_date IN DATE)
  RETURN NUMBER IS
     l_api_name            CONSTANT VARCHAR2(30) := 'get_bid_break_price';
     x_price NUMBER := NULL;

     CURSOR break_price IS
      SELECT pbs.unit_price
      FROM   pon_bid_shipments pbs
      WHERE  pbs.shipment_type  = 'PRICE BREAK'
      AND    pbs.bid_number = p_bid_number
      AND    pbs.line_number = p_line_number
      AND    nvl(pbs.quantity, 0) <= nvl(p_quantity, 0)
      AND   ((p_ship_to_org = pbs.ship_to_organization_id) OR
             (pbs.ship_to_organization_id is null))
      AND   ((p_ship_to_loc = pbs.ship_to_location_id) OR
	     (pbs.ship_to_location_id is null))
      AND   (p_need_by_date IS NULL OR
	     ((trunc(p_need_by_date)  >= pbs.effective_start_date OR
               pbs.effective_start_date is null)
	      AND
	      (trunc(p_need_by_date)  <= pbs.effective_end_date OR
               pbs.effective_end_date is null)))
      ORDER BY pbs.ship_to_organization_id ASC, pbs.ship_to_location_id ASC,
               NVL(pbs.quantity,-1) DESC,
               pbs.price ASC;

BEGIN
   -- logging
   print_log(l_api_name || '.BEGIN', ' ');
   print_log(l_api_name, 'p_bid_number=' || p_bid_number);
   print_log(l_api_name, 'p_line_number=' || p_line_number);
   print_log(l_api_name, 'p_ship_to_org=' || p_ship_to_org);
   print_log(l_api_name, 'p_ship_to_loc=' || p_ship_to_loc);
   print_log(l_api_name, 'p_quantity=' || p_quantity);
   print_log(l_api_name, 'p_need_by_date=' ||p_need_by_date );

   OPEN break_price;
   FETCH break_price INTO x_price;
   CLOSE break_price;

   print_log(l_api_name || '.END', ' ');

   RETURN (x_price);


END get_bid_break_price;


FUNCTION get_bid_break_price_with_pe(p_bid_number IN NUMBER,
			 p_line_number IN NUMBER,
			 p_ship_to_org IN NUMBER,
			 p_ship_to_loc IN NUMBER,
			 p_quantity IN NUMBER,
			 p_need_by_date IN DATE)
  RETURN NUMBER IS
     l_api_name            CONSTANT VARCHAR2(30) := 'get_bid_break_price_with_pe';
     x_price NUMBER := NULL;

     CURSOR break_price IS
      SELECT pbs.price
      FROM   pon_bid_shipments pbs
      WHERE  pbs.shipment_type  = 'PRICE BREAK'
      AND    pbs.bid_number = p_bid_number
      AND    pbs.line_number = p_line_number
      AND    nvl(pbs.quantity, 0) <= nvl(p_quantity, 0)
      AND   ((p_ship_to_org = pbs.ship_to_organization_id) OR
             (pbs.ship_to_organization_id is null))
      AND   ((p_ship_to_loc = pbs.ship_to_location_id) OR
	     (pbs.ship_to_location_id is null))
      AND   (p_need_by_date IS NULL OR
	     ((trunc(p_need_by_date)  >= pbs.effective_start_date OR
               pbs.effective_start_date is null)
	      AND
	      (trunc(p_need_by_date)  <= pbs.effective_end_date OR
               pbs.effective_end_date is null)))
      ORDER BY pbs.ship_to_organization_id ASC, pbs.ship_to_location_id ASC,
               NVL(pbs.quantity,-1) DESC,
               pbs.price ASC;

BEGIN
   -- logging
   print_log(l_api_name || '.BEGIN', ' ');
   print_log(l_api_name, 'p_bid_number=' || p_bid_number);
   print_log(l_api_name, 'p_line_number=' || p_line_number);
   print_log(l_api_name, 'p_ship_to_org=' || p_ship_to_org);
   print_log(l_api_name, 'p_ship_to_loc=' || p_ship_to_loc);
   print_log(l_api_name, 'p_quantity=' || p_quantity);
   print_log(l_api_name, 'p_need_by_date=' ||p_need_by_date );

   OPEN break_price;
   FETCH break_price INTO x_price;
   CLOSE break_price;

   print_log(l_api_name || '.END', ' ');

   RETURN (x_price);


END get_bid_break_price_with_pe;


/*
 * Procedure to validate the price precision of a number.
 */
FUNCTION validate_price_precision(p_number IN NUMBER, p_precision IN NUMBER) RETURN BOOLEAN IS
BEGIN

  IF p_precision = 10000 THEN
    RETURN TRUE;
  ELSE
    RETURN MOD(MOD(ABS(p_number), 1) * POWER(10, p_precision), 1) = 0;
  END IF;

END validate_price_precision;

/*
 * Procedure to validate the currency precision of a number.
 */
FUNCTION validate_currency_precision(p_number IN NUMBER, p_precision IN NUMBER) RETURN BOOLEAN IS
BEGIN

  RETURN MOD(MOD(ABS(p_number), 1) * POWER(10, p_precision), 1) = 0;

END validate_currency_precision;

/*
 * Procedure to apply a bid line's price factors to a price for a given entity level.
 * Entity level can either be LINE or SHIPMENT.
 *
 * Return the total price resulting from the application of the bid line's price factors to the price.
 *
 * see also BidItemPricesEOImpl.applyPriceFactors() and BidItemPricesEOImpl.transformPrice()
 */
FUNCTION apply_price_factors(p_auction_header_id        IN NUMBER,
                             p_line_number              IN NUMBER,
                             p_bid_number               IN NUMBER,
                             p_price                    IN NUMBER,
                             p_bid_quantity             IN NUMBER,
                             p_trading_partner_id       IN NUMBER,
                             p_vendor_site_id           IN NUMBER,
                             p_rate                     IN NUMBER,
                             p_price_precision          IN NUMBER,
                             p_currency_precision       IN NUMBER,
                             p_entity_level             IN VARCHAR2)
RETURN NUMBER IS
  l_api_name CONSTANT VARCHAR2(30) := 'apply_price_factors';
  l_total_price NUMBER;
  l_bid_pf_unit_price NUMBER;
  l_unit_auc_pf_fixed_amount NUMBER;

  l_contract_type VARCHAR2(25);
  l_full_quantity_bid_code VARCHAR2(25);
  l_order_type_lookup_code VARCHAR2(25);
  l_auction_quantity NUMBER;
  l_auc_pf_unit_price_formula NUMBER;
  l_auc_pf_fixed_amount_formula NUMBER;
  l_auc_pf_percentage_formula NUMBER;

  bid_quantity_required BOOLEAN;
  valid_bid_quantity_specified BOOLEAN;

  -- cursor to select the values of the supplier price factors (other than Line Price) on the bid
  -- buyer price factors will be accounted for separately using the buyer pf formulas on the line-level
  CURSOR l_price_element_list IS
    SELECT
      price_element_type_id,
      pricing_basis,
      bid_currency_value
    FROM pon_bid_price_elements bid_pfs
    WHERE
          bid_pfs.bid_number = p_bid_number
      AND bid_pfs.line_number = p_line_number
      AND bid_pfs.price_element_type_id <> -10
      AND bid_pfs.pf_type = 'SUPPLIER';
BEGIN

  -- logging
  print_log(l_api_name || '.BEGIN', ' ');
  print_log(l_api_name, 'p_auction_header_id=' || p_auction_header_id);
  print_log(l_api_name, 'p_line_number=' || p_line_number);
  print_log(l_api_name, 'p_bid_number=' || p_bid_number);
  print_log(l_api_name, 'p_price=' || p_price);
  print_log(l_api_name, 'p_bid_quantity=' || p_bid_quantity);
  print_log(l_api_name, 'p_trading_partner_id=' || p_trading_partner_id);
  print_log(l_api_name, 'p_vendor_site_id=' || p_vendor_site_id);
  print_log(l_api_name, 'p_rate=' || p_rate);
  print_log(l_api_name, 'p_price_precision=' || p_price_precision);
  print_log(l_api_name, 'p_currency_precision=' || p_currency_precision);
  print_log(l_api_name, 'p_entity_level=' || p_entity_level);

  IF p_entity_level = 'SHIPMENT' THEN
    -- if the price argument is null or is negative or has an invalid precision
    -- cannot apply price factors to calculate total price
    IF p_price IS NULL OR p_price < 0 OR NOT(validate_price_precision(p_price, p_price_precision)) THEN
      RETURN NULL;
    END IF;
  ELSE
    -- if the price argument is null or is non-positive or has an invalid precision
    -- cannot apply price factors to calculate total price
    IF p_price IS NULL OR p_price <= 0 OR NOT(validate_price_precision(p_price, p_price_precision)) THEN
      RETURN NULL;
    END IF;
  END IF;

  -- get auction header/line information
  SELECT
    auctions.contract_type,
    auctions.full_quantity_bid_code,
    items.order_type_lookup_code,
    items.quantity,
    NVL(pf_formula.unit_price, 0) pf_unit_price,
    NVL(pf_formula.fixed_amount, 0) pf_fixed_amount,
    NVL(pf_formula.percentage, 1) pf_percentage
  INTO
    l_contract_type,
    l_full_quantity_bid_code,
    l_order_type_lookup_code,
    l_auction_quantity,
    l_auc_pf_unit_price_formula,
    l_auc_pf_fixed_amount_formula,
    l_auc_pf_percentage_formula
  FROM
    pon_auction_headers_all auctions,
    pon_auction_item_prices_all items,
    pon_pf_supplier_formula pf_formula
  WHERE
        auctions.auction_header_id = p_auction_header_id
    AND items.line_number = p_line_number
    AND auctions.auction_header_id = items.auction_header_id
    AND pf_formula.auction_header_id(+) = items.auction_header_id
    AND pf_formula.line_number(+) = items.line_number
    AND pf_formula.trading_partner_id(+) = p_trading_partner_id
    AND pf_formula.vendor_site_id(+) = p_vendor_site_id;

  -- if bid quantity is required and it cannot be determined
  -- cannot apply price factors to calculate total price
  IF l_contract_type NOT IN ('BLANKET', 'CONTRACT') AND
     l_full_quantity_bid_code <> 'FULL_QTY_BIDS_REQD' AND
     l_order_type_lookup_code NOT IN ('FIXED PRICE', 'RATE', 'AMOUNT') THEN
    IF p_bid_quantity IS NULL OR p_bid_quantity <= 0 THEN
      RETURN NULL;
    END IF;
  END IF;

  -- determine whether bid quantity is required
  IF l_contract_type NOT IN ('BLANKET', 'CONTRACT') AND
     l_full_quantity_bid_code <> 'FULL_QTY_BIDS_REQD' AND
     l_order_type_lookup_code NOT IN ('FIXED PRICE', 'RATE', 'AMOUNT') THEN
    bid_quantity_required := TRUE;
  ELSE
    bid_quantity_required := FALSE;
  END IF;

  -- determine whether a valid bid quantity is specified
  valid_bid_quantity_specified := p_bid_quantity IS NOT NULL AND p_bid_quantity > 0;

  -- if there exists a supplier price factor other than Line Price:
  -- 1) for which a value is not specified
  -- 2) whose value is negative
  -- 3) of pricing basis PER_UNIT or FIXED_AMOUNT whose value has an invalid precision
  -- 4) of pricing basis FIXED_AMOUNT for which a bid quantity is required but is not specified
  -- cannot apply price factors to calculate total price
  FOR l_price_element IN l_price_element_list LOOP

    IF l_price_element.bid_currency_value IS NULL OR l_price_element.bid_currency_value < 0 THEN
      RETURN NULL;
    END IF;

    IF (l_price_element.pricing_basis = 'PER_UNIT' AND
        NOT(validate_price_precision(l_price_element.bid_currency_value, p_price_precision))) OR
       (l_price_element.pricing_basis = 'FIXED_AMOUNT' AND
        NOT(validate_currency_precision(l_price_element.bid_currency_value, p_currency_precision))) THEN
      RETURN NULL;
    END IF;

    IF bid_quantity_required AND NOT(valid_bid_quantity_specified) THEN
      IF l_price_element.pricing_basis = 'FIXED_AMOUNT' THEN
        RETURN NULL;
      END IF;
    END IF;

  END LOOP;

  l_total_price := 0;

  -- STEP 1: account for supplier price factors (except Line Price)

  FOR l_price_element IN l_price_element_list LOOP

    -- PER_UNIT pricing basis
    IF l_price_element.pricing_basis = 'PER_UNIT' THEN
      l_bid_pf_unit_price := l_price_element.bid_currency_value;
    -- PERCENTAGE pricing basis
    ELSIF l_price_element.pricing_basis = 'PERCENTAGE' THEN
      l_bid_pf_unit_price := l_price_element.bid_currency_value * p_price / 100;
    -- FIXED_AMOUNT pricing basis
    ELSIF l_price_element.pricing_basis = 'FIXED_AMOUNT' THEN
      -- FIXED PRICE based line type
      IF l_order_type_lookup_code = 'FIXED PRICE' THEN
        l_bid_pf_unit_price := l_price_element.bid_currency_value;
      -- RATE based line type
      ELSIF l_order_type_lookup_code = 'RATE' THEN
        l_bid_pf_unit_price := l_price_element.bid_currency_value / l_auction_quantity;
      -- AMOUNT based line type
      ELSIF l_order_type_lookup_code = 'AMOUNT' THEN
        l_bid_pf_unit_price := l_price_element.bid_currency_value / l_auction_quantity;
      -- other line types
      ELSE
        -- if negotiation is either a BPA or CPA or requires full bid quantity
        -- use the auction quantity
        IF l_contract_type IN ('BLANKET', 'CONTRACT') OR
           l_full_quantity_bid_code = 'FULL_QTY_BIDS_REQD' THEN
          l_bid_pf_unit_price := l_price_element.bid_currency_value / l_auction_quantity;
        -- otherwise, use the bid quantity
        ELSE
          l_bid_pf_unit_price := l_price_element.bid_currency_value / p_bid_quantity;
        END IF;
      END IF;
    END IF;

    -- add the pf bid unit price to the total price
    l_total_price := l_total_price + l_bid_pf_unit_price;

  END LOOP;

  -- STEP 2: account for price argument and buyer price factors
  -- in this step, we will make use of the buyer price factor transform values for the line

  -- for the FIXED_AMOUNT transform value
  -- we have to calculate its unit value based on the line type
  -- before we can account for it in the total price

  IF l_auc_pf_fixed_amount_formula IS NULL OR l_auc_pf_fixed_amount_formula = 0 THEN
    -- if there is no fixed amount formula, the unit fixed amount is simply 0
    l_unit_auc_pf_fixed_amount := 0;
  ELSE
    -- there is a fixed amount formula, check if bid quantity is required
    -- if bid quantity is required and it is null
    -- the price cannot be transformed
    IF bid_quantity_required AND NOT(valid_bid_quantity_specified) THEN
      RETURN NULL;
    END IF;

    -- FIXED PRICE based line type
    IF l_order_type_lookup_code = 'FIXED PRICE' THEN
      l_unit_auc_pf_fixed_amount := l_auc_pf_fixed_amount_formula;
    -- RATE based line type
    ELSIF l_order_type_lookup_code = 'RATE' THEN
      l_unit_auc_pf_fixed_amount := l_auc_pf_fixed_amount_formula / l_auction_quantity;
    -- AMOUNT based line type
    ELSIF l_order_type_lookup_code = 'AMOUNT' THEN
      l_unit_auc_pf_fixed_amount := l_auc_pf_fixed_amount_formula / l_auction_quantity;
    -- other line types
    ELSE
      -- if negotiation is either a BPA or CPA or requires full bid quantity
      -- use the auction quantity
      IF l_contract_type IN ('BLANKET', 'CONTRACT') OR
         l_full_quantity_bid_code = 'FULL_QTY_BIDS_REQD' THEN
        l_unit_auc_pf_fixed_amount := l_auc_pf_fixed_amount_formula / l_auction_quantity;
      -- otherwise, use the bid quantity
      ELSE
        l_unit_auc_pf_fixed_amount := l_auc_pf_fixed_amount_formula / p_bid_quantity;
      END IF;
    END IF;
  END IF;

  l_total_price := l_total_price + (l_auc_pf_unit_price_formula * p_rate) + (l_unit_auc_pf_fixed_amount * p_rate) + (l_auc_pf_percentage_formula * p_price);

  -- do not round total price to precision before returning
  print_log(l_api_name || '.END', l_total_price || ': END l_total_price');
  RETURN l_total_price;

END apply_price_factors;

FUNCTION GET_FND_USER_ID (p_person_party_id IN NUMBER)
RETURN NUMBER
IS
	x_user_id number;
begin
	begin
		select user_id into x_user_id from fnd_user where person_party_id = p_person_party_id;
	exception
	   when others then
	   x_user_id := p_person_party_id;
	end;
--
	return x_user_id;
end;
--


/**
  * This procedure recovers the archived draft bid, if any,
  * on the most recent previous amendment for which the supplier entered bid values.
  * It sets the bid status on the most recent bid across all previous amendments to DRAFT
  * only if that most recent bid has a bid status of ARCHIVED_DRAFT
  *
  p_auction_header_id_orig_amend - the original auction
  p_trading_partner_id           - the tp id of the supplier
  p_trading_partner_contact_id   - the tp contact id of the supplier
  p_vendor_site_id               - the site id of the supplier
*/
PROCEDURE recover_prev_amend_draft (
  p_auction_header_id_orig_amend IN NUMBER,
  p_trading_partner_id           IN NUMBER,
  p_trading_partner_contact_id   IN NUMBER,
  p_vendor_site_id               IN NUMBER,
  p_login_user_id                IN NUMBER
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'recover_prev_amend_draft';
BEGIN
  print_log(l_api_name,  ' BEGIN recover_prev_amend_draft');
  UPDATE pon_bid_headers
  SET
    bid_status = 'DRAFT',
    last_update_date = SYSDATE,
    last_updated_by = p_login_user_id
  WHERE
        bid_number = (
          SELECT bid_number
          FROM
            (SELECT
               bh.bid_number,
               bh.bid_status,
               decode(bh.bid_status,
                      'ARCHIVED_DRAFT', 3,
                      'RESUBMISSION' , 2,
                      'DISQUALIFIED', 1) bid_status_order,
               nvl(ah.amendment_number, 0) amendment_number,
               bh.publish_date
             FROM
               pon_bid_headers bh,
               pon_auction_headers_all ah
             WHERE
                   bh.auction_header_id = ah.auction_header_id
               AND ah.auction_header_id_orig_amend = p_auction_header_id_orig_amend
               AND bh.trading_partner_id = p_trading_partner_id
               AND bh.trading_partner_contact_id = p_trading_partner_contact_id
               AND nvl(bh.vendor_site_id, -1) = nvl(p_vendor_site_id, -1)
               AND bh.bid_status in ('ARCHIVED_DRAFT', 'RESUBMISSION', 'DISQUALIFIED')
             ORDER BY amendment_number DESC, bid_status_order DESC, bh.publish_date DESC
          )
          WHERE ROWNUM = 1
        )
    AND bid_status = 'ARCHIVED_DRAFT';

	print_log(l_api_name,  ' END recover_prev_amend_draft');
END recover_prev_amend_draft;


PROCEDURE set_buyer_bid_total
              (p_auction_header_id   IN NUMBER,
               p_bid_number          IN NUMBER)

IS
l_api_name CONSTANT VARCHAR2(30) := 'set_buyer_bid_total';
BEGIN
  print_log(l_api_name,  p_bid_number||': BEGIN set_buyer_bid_total');
  UPDATE pon_bid_headers pbh
  SET    buyer_bid_total = (SELECT sum(decode(paip.order_type_lookup_code, 'FIXED PRICE', 1, nvl(pbip.quantity, paip.quantity)) *
                                           pbip.price)
                                       -- hack to set bid total to null if at least one line has a quantity of null
                                       + decode(min(decode(paip.order_type_lookup_code, 'FIXED PRICE', 1, nvl(paip.quantity, -9999))), -9999, NULL, 0) bid_total
                            FROM   pon_bid_item_prices pbip,
                                   pon_auction_item_prices_all paip
                            WHERE  pbip.auction_header_id = pbh.auction_header_id AND
                                   pbip.bid_number = pbh.bid_number AND
                                   pbip.auction_header_id = paip.auction_header_id AND
                                   pbip.line_number = paip.line_number AND
                                   paip.group_type in ('LOT', 'LINE', 'GROUP_LINE'))
  WHERE  pbh.auction_header_id = p_auction_header_id AND
         pbh.bid_number = p_bid_number;

  print_log(l_api_name,  p_bid_number||': END set_buyer_bid_total');

END set_buyer_bid_total;






















--==============================================================
--==============================================================
--
--   BATCHING
--
--==============================================================
--==============================================================






FUNCTION new_best_price   (x_auction_type         IN VARCHAR2,
			   x_current_price        IN NUMBER,
		      	   x_current_limit_price  IN NUMBER,
			   x_best_bid_price       IN NUMBER,
		      	   x_best_bid_limit_price IN NUMBER)
RETURN VARCHAR2 IS
   v_newBestPrice NUMBER;
   v_newPrice     NUMBER;
   l_api_name            CONSTANT VARCHAR2(30) := 'new_best_price';
BEGIN
     -- logging
     print_log(l_api_name || '.BEGIN', ' ');
     print_log(l_api_name, 'x_auction_type=' || x_auction_type);
     print_log(l_api_name, 'x_current_price=' || x_current_price);
     print_log(l_api_name, 'x_current_limit_price=' || x_current_limit_price);
     print_log(l_api_name, 'x_best_bid_price=' ||  x_best_bid_price);
     print_log(l_api_name, 'x_best_bid_limit_price=' || x_best_bid_limit_price);

     print_log(l_api_name, 'calling calculate_prices' );
     calculate_prices(x_auction_type,
                      x_current_price,
                      NVL(x_current_limit_price,x_current_price),
                      1,
                      x_best_bid_price,
                      NVL(x_best_bid_limit_price,x_best_bid_price),
                      1,
                      v_newPrice,
                      v_newBestPrice);

     print_log(l_api_name || '.END', ' ');

     IF ((v_newBestPrice <> x_best_bid_price) OR (better_price(x_auction_type, v_newPrice, x_best_bid_price))) THEN
       RETURN 'Y';
     ELSE
       RETURN 'N';
     END IF;

END;


FUNCTION new_best_mas_price( p_auction_type         IN VARCHAR2
                           , p_current_price        IN NUMBER
                           , p_total_weighted_score IN NUMBER
                           , p_current_limit_price  IN NUMBER
                           , p_best_bid_bid_price   IN NUMBER
                           , p_best_bid_score       IN NUMBER
                           , p_best_bid_limit_price IN NUMBER
                           )
RETURN VARCHAR2 IS
--
   v_newBestPrice NUMBER;
   v_newPrice     NUMBER;
   v_currentLimit NUMBER;
   v_bestLimit    NUMBER;
   l_api_name            CONSTANT VARCHAR2(30) := 'new_best_mas_price';
--
BEGIN
--

  -- logging
  print_log(l_api_name || '.BEGIN', ' ');
  print_log(l_api_name, 'p_auction_type=' || p_auction_type);
  print_log(l_api_name, 'p_current_price=' || p_current_price);
  print_log(l_api_name, 'p_total_weighted_score=' || p_total_weighted_score);
  print_log(l_api_name, 'p_current_limit_price=' || p_current_limit_price);
  print_log(l_api_name, 'p_best_bid_bid_price=' || p_best_bid_bid_price);
  print_log(l_api_name, 'p_best_bid_score=' || p_best_bid_score);
  print_log(l_api_name, 'p_best_bid_limit_price=' || p_best_bid_limit_price);

  v_currentLimit := NVL(p_current_limit_price, p_current_price);
  v_bestLimit    := NVL(p_best_bid_limit_price, p_best_bid_bid_price);
--
  IF (p_best_bid_score/p_best_bid_bid_price) >= (p_total_weighted_score/v_currentLimit) THEN
    -- best price is better than current limit
--
    v_newBestPrice := p_best_bid_bid_price;
    v_newPrice     := v_currentLimit;
--
  ELSIF (p_total_weighted_score/p_current_price) > (p_best_bid_score/v_bestLimit) THEN
    -- current price is better than best limit
--
    v_newBestPrice := v_bestLimit;
    v_newPrice     := p_current_price;
--
  ELSIF (
         ((p_best_bid_score/p_best_bid_bid_price) >= (p_total_weighted_score/p_current_price)
          AND
          (p_total_weighted_score/v_currentLimit) >= (p_best_bid_score/p_best_bid_bid_price)
         )
         OR
         ((p_total_weighted_score/p_current_price) >= (p_best_bid_score/p_best_bid_bid_price)
          AND
          (p_best_bid_score/v_bestLimit) >= (p_total_weighted_score/p_current_price)
         )
        ) THEN
    -- best bid price range and current bid price range intersect
--
    IF (p_total_weighted_score/v_currentLimit) > (p_best_bid_score/v_bestLimit) THEN
--
      -- current bid when taken to limit is better than best bid taken to its limit
      v_newBestPrice := v_bestLimit;
--
      IF (v_bestLimit - 1) > v_currentLimit THEN
        v_newPrice := v_bestLimit - 1;
      ELSE
        v_newPrice := v_currentLimit;
      END IF;
--
    ELSIF (p_best_bid_score/v_bestLimit) > (p_total_weighted_score/v_currentLimit) THEN
--
      -- best bid taken to its limit is better than current bid when taken to limit
      IF (v_currentLimit - 1) > v_bestLimit THEN
        v_newBestPrice := v_currentLimit - 1;
      ELSE
        v_newBestPrice := v_bestLimit;
      END IF;
--
      v_newPrice := v_currentLimit;
--
    ELSIF (p_total_weighted_score/v_currentLimit) = (p_best_bid_score/v_bestLimit) THEN
--
      -- current bid when taken to limit is equal to best bid taken to its limit
      v_newBestPrice := v_bestLimit;
      v_newPrice     := v_currentLimit;
--
    END IF;
--
  END IF;
--
  IF ((v_newBestPrice <> p_best_bid_bid_price)
      OR (p_total_weighted_score/v_newPrice) > (p_best_bid_score/p_best_bid_bid_price)) THEN
    print_log(l_api_name || '.END', ' ');
    RETURN 'Y';
  END IF;
--
  print_log(l_api_name || '.END', ' ');
  RETURN 'N';
--
END;

--========================================================================
-- PROCEDURE : auto_extend_lines
-- PARAMETERS:
-- VERSION   : current version         1.x
--             initial version         1.0
-- COMMENT   : encapsulates the auto-extension logic.  used in
-- update_auction_info
--========================================================================

PROCEDURE auto_extend_lines
( p_auctionHeaderId IN NUMBER,
  p_bidNumber IN NUMBER,
  p_batchStart IN NUMBER,
  p_batchEnd IN NUMBER,
  p_extensionInterval IN NUMBER, -- This is the calculated exten interval
  p_hdrExtensionTime IN NUMBER, -- THis is the one specified by the buyer
  p_bidPublishDate IN DATE,
  p_autoExtendAllLinesFlag IN VARCHAR2,
  p_hdrCloseBiddingDate IN DATE,
  p_autoExtendNumber IN NUMBER,
  p_hdrNumberOfExtensions IN NUMBER,
  p_autoExtendMinTriggerRank IN NUMBER,
  p_autoExtendTypeFlag IN VARCHAR2,
  p_bidRanking IN VARCHAR2,
  p_rankIndicator IN VARCHAR2
)
IS

  l_api_name CONSTANT VARCHAR2(30) := 'auto_extend_lines';

BEGIN

  print_log(l_api_name, p_bidNumber || ' - begin auto extend lines for batch ranges: ' ||
    p_batchStart || ' ~ ' || p_batchEnd || ' inclusive');

  -- extend all lines
  IF (p_autoExtendAllLinesFlag ='Y') THEN

    update
      pon_auction_item_prices_all
    SET
      number_of_extensions = nvl(number_of_extensions,0) + 1,
      close_bidding_date = close_bidding_date + p_extensionInterval
    WHERE
      auction_header_id = p_auctionHeaderId
      AND close_bidding_date >= p_bidPublishDate
      AND line_number >= p_batchStart
      AND line_number <= p_batchEnd;

  ELSE
    -- extend only the lines with new bids
    UPDATE pon_auction_item_prices_all
    SET number_of_extensions = nvl(number_of_extensions, 0) + 1,
        close_bidding_date = decode(p_autoExtendTypeFlag, 'FROM_AUCTION_CLOSE_DATE',
                                       nvl(close_bidding_date, p_hdrCloseBiddingDate) + p_hdrExtensionTime,
                                       p_bidPublishDate + p_hdrExtensionTime)
    WHERE auction_header_id = p_auctionHeaderId
        AND line_number IN
            (SELECT al.line_number
             FROM pon_bid_headers bh,
                 pon_bid_item_prices bl,
                 pon_auction_item_prices_all al
             WHERE bh.bid_number IN (SELECT * FROM TABLE(CAST (g_bidsGenerated AS fnd_table_of_number)))
                 AND bl.bid_number = bh.bid_number
                 AND al.auction_header_id = bh.auction_header_id
                 AND bl.line_number = al.line_number

                 -- consider only lines changed during this publish
                 AND bl.publish_date = bh.publish_date

                 -- consider only lines with bids placed within the AutoExtend period
                 AND bl.publish_date > (nvl(al.close_bidding_date, p_hdrCloseBiddingDate) - p_hdrExtensionTime)

                 -- consider only lines which have extensions left
                 AND nvl(al.number_of_extensions, p_hdrNumberOfExtensions) < p_autoExtendNumber

                 -- We extend when any bid will trigger AutoExtend
                 -- or we extend when the top bid is placed
                 -- or, if ranking is numbered, we extend when the bid placed is within the top rank specified
                 AND (p_autoExtendMinTriggerRank = 10000
                     OR decode(p_bidRanking, 'MULTI_ATTRIBUTE_SCORING',
                               al.best_bid_bid_number, al.best_bid_number) = bl.bid_number
                     OR (p_rankIndicator = 'NUMBERING' AND bl.rank <= p_autoExtendMinTriggerRank))

                 -- consider only lines in the current batch
                 AND al.line_number >= p_batchStart
                 AND al.line_number <= p_batchEnd);
  END IF;

  -- auto extend all group lines which had at least one
  -- other line in the group extended

  UPDATE pon_auction_item_prices_all al
  SET (number_of_extensions,
       close_bidding_date) =
      (SELECT max(number_of_extensions),
              max(close_bidding_date)
       FROM pon_auction_item_prices_all al2
       WHERE al2.auction_header_id = al.auction_header_id
         AND nvl(al2.parent_line_number, al2.line_number) =
             nvl(al.parent_line_number, al.line_number))
  WHERE auction_header_id = p_auctionHeaderId
    AND group_type in ('LOT', 'LOT_LINE', 'GROUP', 'GROUP_LINE')
    AND line_number >= p_batchStart
    AND line_number <= p_batchEnd;

  print_log(l_api_name, p_bidNumber || ' - end auto extend lines for batch ranges: ' || p_batchStart || ' ~ ' || p_batchEnd || ' inclusive');

END auto_extend_lines;

PROCEDURE auto_extend_lines_batch
( p_auctionHeaderId IN NUMBER,
  p_bidNumber IN NUMBER,
  p_maxLineNumber IN NUMBER,
  p_batchSize IN NUMBER,
  p_extensionInterval IN NUMBER,
  p_hdrExtensionTime IN NUMBER,
  p_bidPublishDate IN DATE,
  p_autoExtendAllLinesFlag IN VARCHAR2,
  p_hdrCloseBiddingDate IN DATE,
  p_autoExtendNumber IN NUMBER,
  p_hdrNumberOfExtensions IN NUMBER,
  p_autoExtendMinTriggerRank IN NUMBER,
  p_autoExtendTypeFlag IN VARCHAR2,
  p_bidRanking IN VARCHAR2,
  p_rankIndicator IN VARCHAR2
)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  v_batchStart NUMBER;
  v_batchEnd NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'auto_extend_lines_batch';
BEGIN

  print_log(l_api_name, p_bidNumber || ' - BEGIN auto extend lines AUTONOMOUS');

  v_batchStart := 1;
  v_batchEnd := p_batchSize;

  WHILE (v_batchStart <= p_maxLineNumber) LOOP

    -- auto extend all lines
    auto_extend_lines (
      p_auctionHeaderId => p_auctionHeaderId,
      p_bidNumber => p_bidNumber,
      p_batchStart => v_batchStart,
      p_batchEnd => v_batchEnd,
      p_extensionInterval => p_extensionInterval,
      p_hdrExtensionTime => p_hdrExtensionTime,
      p_bidPublishDate => p_bidPublishDate,
      p_autoExtendAllLinesFlag => p_autoExtendAllLinesFlag,
      p_hdrCloseBiddingDate => p_hdrCloseBiddingDate,
      p_autoExtendNumber => p_autoExtendNumber,
      p_hdrNumberOfExtensions => p_hdrNumberOfExtensions,
      p_autoExtendMinTriggerRank => p_autoExtendMinTriggerRank,
      p_autoExtendTypeFlag => p_autoExtendTypeFlag,
      p_bidRanking => p_bidRanking,
      p_rankIndicator => p_rankIndicator);
    commit;

    print_log(l_api_name, p_bidNumber || ' - auto extend lines: committed!');

    v_batchStart := v_batchEnd + 1;
    IF (v_batchEnd + p_batchSize > p_maxLineNumber) THEN
      v_batchEnd := p_maxLineNumber;
    ELSE
      v_batchEnd := v_batchEnd + p_batchSize;
    END IF;
  END LOOP;

  print_log(l_api_name, p_bidNumber || ' - END auto extend lines AUTONOMOUS');

END auto_extend_lines_batch;

procedure auto_extend_negotiation
( p_auctionHeaderId IN NUMBER,
  p_bidNumber       IN NUMBER,
  p_maxLineNumber   IN NUMBER,
  p_batchSize       IN NUMBER,
  p_batchingRequired IN BOOLEAN)
IS
  v_auctionType pon_auction_headers_all.auction_type%TYPE;
  v_bidRanking pon_auction_headers_all.bid_ranking%TYPE;
  v_rankIndicator pon_auction_headers_all.rank_indicator%TYPE;
  v_autoExtendAllLinesFlag pon_auction_headers_all.auto_extend_all_lines_flag%TYPE;
  v_autoExtendNumber pon_auction_headers_all.auto_extend_number%TYPE;
  v_autoExtendDuration pon_auction_headers_all.auto_extend_duration%TYPE;
  v_autoExtendTypeFlag pon_auction_headers_all.auto_extend_type_flag%TYPE;
  v_autoExtendMinTriggerRank pon_auction_headers_all.auto_extend_min_trigger_rank%TYPE;
  v_staggeredClosingInterval pon_auction_headers_all.staggered_closing_interval%TYPE;
  v_hdrCloseBiddingDate pon_auction_headers_all.close_bidding_date%TYPE;
  v_hdrNumberOfExtensions pon_auction_headers_all.number_of_extensions%TYPE;

  v_triggerLineCloseBiddingDate pon_auction_item_prices_all.close_bidding_date%TYPE;
  v_bidPublishDate pon_bid_item_prices.publish_date%TYPE;

  v_extensionInterval NUMBER;

  l_api_name CONSTANT VARCHAR2(30) := 'auto_extend_negotiation';
  v_hdrExtensionTime NUMBER;

BEGIN


  print_log(l_api_name, p_bidNumber || ' - begin auto extend lines :' ||
    'p_auctionHeaderId = ' || p_auctionHeaderId ||
    ', p_bidNumber = ' || p_bidNumber ||
    ', p_maxLineNumber = ' || p_maxLineNumber ||
    ', p_batchSize = ' || p_batchSize);

  --Get the auction details
  select
    pah.auction_type,
    pah.bid_ranking,
    pah.rank_indicator,
    nvl(pah.auto_extend_all_lines_flag,'Y'),
    pah.auto_extend_type_flag,
    pah.auto_extend_number,
    pah.auto_extend_duration,
    pah.close_bidding_date,
    nvl(pah.number_of_extensions,0),
    pah.auto_extend_min_trigger_rank,
    pah.staggered_closing_interval,
    bh.publish_date
  into
    v_auctionType,
    v_bidRanking,
    v_rankIndicator,
    v_autoExtendAllLinesFlag,
    v_autoExtendTypeFlag,
    v_autoExtendNumber,
    v_autoExtendDuration,
    v_hdrCloseBiddingDate,
    v_hdrNumberOfExtensions,
    v_autoExtendMinTriggerRank,
    v_staggeredClosingInterval,
    v_bidPublishDate
  from
    pon_bid_headers bh,
    pon_auction_headers_all pah
  where bh.bid_number = p_bidNumber
    AND pah.auction_header_id = bh.auction_header_id;

  v_hdrExtensionTime := (1 / (24 * 60)) *  v_autoExtendDuration;

  print_log(l_api_name, 'Queried data from headers_all' ||
    'v_auctionType = ' || v_auctionType ||
    ', v_bidRanking = ' || v_bidRanking ||
    ', v_rankIndicator = ' || v_rankIndicator ||
    ', v_autoExtendAllLinesFlag = ' || v_autoExtendAllLinesFlag ||
    ', v_autoExtendTypeFlag = ' || v_autoExtendTypeFlag ||
    ', v_autoExtendNumber = ' || v_autoExtendNumber ||
    ', v_autoExtendDuration = ' || v_autoExtendDuration ||
    ', v_hdrCloseBiddingDate = ' || to_char(v_hdrCloseBiddingDate, 'dd-mon-yyyy hh24:mi:ss') ||
    ', v_hdrNumberOfExtensions = ' || v_hdrNumberOfExtensions ||
    ', v_autoExtendMinTriggerRank = ' || v_autoExtendMinTriggerRank ||
    ', v_staggeredClosingInterval = ' || v_staggeredClosingInterval);

  --If EXTEND_ALL_LINES Then
  if (v_autoExtendAllLinesFlag ='Y') then -- {
    begin -- {

      -- If any bid can trigger AutoExtend, and not staggered closing.
      IF (v_autoExtendMinTriggerRank =  10000
          AND NVL(v_staggeredClosingInterval, 0) = 0) THEN
        IF (v_hdrNumberOfExtensions < v_autoExtendNumber
            AND v_bidPublishDate > (v_hdrCloseBiddingDate - v_hdrExtensionTime)) THEN
          v_triggerLineCloseBiddingDate := v_hdrCloseBiddingDate;
        ELSE
            -- No AutoExtension will take place because we are not within the AutoExtension window
            print_log(l_api_name, 'No AutoExtension took place');
            RETURN;
        END IF;

      --Fire SQL to determine if any extensions
      ELSE
        select
          nvl(a.close_bidding_date, v_hdrCloseBiddingDate),
          b.publish_date
        into
          v_triggerLineCloseBiddingDate,
          v_bidPublishDate
        from
          pon_auction_item_prices_all a,
          pon_bid_item_prices b
        where
          -- We need to consider every bid generated during this publish - the current bid + all proxy bids
          b.bid_number IN (SELECT * FROM TABLE(CAST (g_bidsGenerated AS fnd_table_of_number)))
          and a.auction_header_id = p_auctionHeaderId
          and a.line_number = b.line_number

          -- We extend when any bid will trigger AutoExtend
          -- or we extend when the top bid is placed
          -- or, if ranking is numbered, we extend when the bid placed is within the top rank specified
          and (v_autoExtendMinTriggerRank =  10000
               OR decode(v_bidRanking, 'MULTI_ATTRIBUTE_SCORING',
                         a.best_bid_bid_number, a.best_bid_number) = b.bid_number
               OR (v_rankIndicator = 'NUMBERING' AND b.rank <= v_autoExtendMinTriggerRank))

          and nvl(a.number_of_extensions, v_hdrNumberOfExtensions) < v_autoExtendNumber
          and b.publish_date > (nvl(a.close_bidding_date, v_hdrCloseBiddingDate) - v_hdrExtensionTime)
          and v_bidPublishDate <= nvl (a.close_bidding_date, v_hdrCloseBiddingDate)
          and rownum = 1;
      END IF;

      --If any lines found, then determine the extension interval
      IF (v_autoExtendTypeFlag = 'FROM_AUCTION_CLOSE_DATE') then --{
        v_extensionInterval := v_hdrExtensionTime;

      ELSE
        v_extensionInterval := (v_bidPublishDate + v_hdrExtensionTime) - v_triggerLineCloseBiddingDate;

      END IF; --}

      print_log(l_api_name, 'Found a line that autoextends v_extensionInterval = ' || v_extensionInterval);
      exception
        when no_data_found then
        --If no lines found, then return without doing anything
          print_log(l_api_name, 'Cound not find a line that autoextends');
          return;
    end; --}
  end if; --}

  -- The reason we have a wrapper procedure auto_extend_negotiation
  -- is that auto_extend_lines_batch has PRAGMA AUTONOMOUS.

  --Call in batches
  if (p_batchingRequired) then --{
    auto_extend_lines_batch (
      p_auctionHeaderId => p_auctionHeaderId,
      p_bidNumber => p_bidNumber,
      p_maxLineNumber => p_maxLineNumber,
      p_batchSize => p_batchSize,
      p_extensionInterval => v_extensionInterval,
      p_hdrExtensionTime => v_hdrExtensionTime,
      p_bidPublishDate => v_bidPublishDate,
      p_autoExtendAllLinesFlag => v_autoExtendAllLinesFlag,
      p_hdrCloseBiddingDate => v_hdrCloseBiddingDate,
      p_autoExtendNumber => v_autoExtendNumber,
      p_hdrNumberOfExtensions => v_hdrNumberOfExtensions,
      p_autoExtendMinTriggerRank => v_autoExtendMinTriggerRank,
      p_autoExtendTypeFlag => v_autoExtendTypeFlag,
      p_bidRanking => v_bidRanking,
      p_rankIndicator => v_rankIndicator);
  else
    auto_extend_lines (
      p_auctionHeaderId => p_auctionHeaderId,
      p_bidNumber => p_bidNumber,
      p_batchStart => 1,
      p_batchEnd => p_maxLineNumber,
      p_extensionInterval => v_extensionInterval,
      p_hdrExtensionTime => v_hdrExtensionTime,
      p_bidPublishDate => v_bidPublishDate,
      p_autoExtendAllLinesFlag => v_autoExtendAllLinesFlag,
      p_hdrCloseBiddingDate => v_hdrCloseBiddingDate,
      p_autoExtendNumber => v_autoExtendNumber,
      p_hdrNumberOfExtensions => v_hdrNumberOfExtensions,
      p_autoExtendMinTriggerRank => v_autoExtendMinTriggerRank,
      p_autoExtendTypeFlag => v_autoExtendTypeFlag,
      p_bidRanking => v_bidRanking,
      p_rankIndicator => v_rankIndicator);
  end if; --}
  print_log(l_api_name, p_bidNumber || ' - End auto extend lines.');
END;

--========================================================================
-- PROCEDURE : update_proxy_bid
--             update_proxy_bid_auto
-- PARAMETERS:
-- VERSION   : current version         1.x
--             initial version         1.0
-- COMMENT   : encapsulates the proxy bid logic.  used in
-- update_auction_info
--========================================================================

PROCEDURE update_proxy_bid
( p_auctionHeaderId IN NUMBER,
  p_bidNumber       IN NUMBER,
  p_oldBidNumber    IN NUMBER,
  p_isSurrogateBid  IN VARCHAR2,
  p_isAuctionClosed IN VARCHAR2,
  x_isPriceChanged  OUT NOCOPY VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30) := 'update_proxy_bid';
--
  -- v_proxyBidList stores the new bid prices for proxy bids after
  -- all proxy has been performed
  TYPE t_proxyBidItem IS RECORD
  ( bid_number    NUMBER,
    line_number   NUMBER,
    bid_price     NUMBER,
    bid_currency_price  NUMBER);

  TYPE t_proxyBidList IS TABLE OF t_proxyBidItem
    INDEX BY BINARY_INTEGER;

  v_proxyBidList 		t_proxyBidList;
  v_emptyProxyBidList 		t_proxyBidList;

  -- v_reBidList stores the list of bids that need to be "cloned"
  -- as a result of proxy bidding
  TYPE t_reBidList IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  v_reBidList 			t_reBidList;
  v_emptyReBidList 		t_reBidList;

  -- t_itm_* records contain information about a bid's
  -- number_of_bids and best_bid_proxy_limit_prc
  TYPE t_tbl_number IS TABLE OF NUMBER
    INDEX BY PLS_INTEGER;

  t_itm_index Number := 0;
  t_itm_line_number 		t_tbl_number;
  t_itm_number_of_bids 		t_tbl_number;
  t_itm_best_bid_proxy_limit_prc t_tbl_number;
--
  -- other variables used in the procedure
  v_best_bid_proxy_limit_price 	NUMBER;
  v_proxy_bid_limit_price 	NUMBER;
  v_best_bid_min_change 	NUMBER;
  v_bid_min_change 		NUMBER;
  v_oldBidNum 			NUMBER;
  v_newBidNum 			NUMBER;
  v_idx 			NUMBER;
  v_tpid 			pon_bid_headers.trading_partner_id%TYPE;
  v_tpcid 			pon_bid_headers.trading_partner_contact_id%TYPE;
  v_bestTpid 			pon_bid_headers.trading_partner_id%TYPE;
  v_bestTpcid 			pon_bid_headers.trading_partner_contact_id%TYPE;
  v_rate 			pon_bid_headers.rate%TYPE;
  v_best_bid_rate 		pon_bid_headers.rate%TYPE;
  v_best_bid_decimals		pon_bid_headers.number_price_decimals%TYPE;
  v_auction_type		pon_auction_headers_all.auction_type%TYPE;
  v_bid_change_type		pon_auction_headers_all.min_bid_change_type%TYPE;
  v_trading_partner_id		pon_auction_headers_all.trading_partner_id%TYPE;
  v_auction_decimals		NUMBER;
  v_publish_date		DATE;
  v_count			NUMBER;
  v_bid_decimals		NUMBER;
  v_number_of_bids		NUMBER;
  v_revision_number		NUMBER;
  v_bid_min_change_save		Number;
  v_new_bid_price  		Number;
  v_new_best_bid_price 		Number;

  v_proxy_publish_date DATE;
--
  -- this cursor selects all lines for which this
  -- bid has a new bid on AND can has proxy enabled.
  -- functionally, this is the group of lines that need to
  -- be examined for possible proxy activity.
  CURSOR c_proxy_bid_candidates is
    select biditem.line_number,
           biditem.price,
           biditem.proxy_bid_limit_price,
           biditem.first_bid_price,
           item.best_bid_number,
           item.best_bid_price,
           item.best_bid_proxy_limit_price,
           item.best_bid_first_bid_price,
           NVL(item.number_of_bids, 0) as number_of_bids,
           bestbid.trading_partner_id as best_bid_tp_id,
           bestbid.trading_partner_contact_id as best_bid_tpc_id,
           NVL(bestbid.min_bid_change,0) as best_bid_min_change,
           NVL(bestbid.rate,1.0) as best_bid_rate,
           NVL(bestbid.number_price_decimals,10) as best_bid_decimals
    from pon_bid_headers bestbid,
         pon_bid_item_prices biditem,
         pon_auction_item_prices_all item
    where bestbid.bid_number = item.best_bid_number
      and item.auction_header_id = biditem.auction_header_id
      and item.line_number = biditem.line_number
      and biditem.auction_header_id= p_auctionHeaderId
      and biditem.bid_number = p_bidNumber
      and biditem.publish_date = v_publish_date
      and (item.best_bid_proxy_limit_price is not null
           or biditem.proxy_bid_limit_price is not null);
--
   -- this function returns whether x_price1 is better than x_price2
   -- i.e. if (x_price1 < x_price2)
  FUNCTION is_better_price(x_price1 IN NUMBER,
                           x_price2 IN NUMBER)
  RETURN BOOLEAN IS
  BEGIN
    return better_price(v_auction_type, x_price1,x_price2);
  END;
--

BEGIN

  -- logging
  print_log(l_api_name || '.BEGIN', ' ');
  print_log(l_api_name, 'p_auctionHeaderId=' || p_auctionHeaderId);
  print_log(l_api_name, 'p_bidNumber=' || p_bidNumber);
  print_log(l_api_name, 'p_oldBidNumber=' || p_oldBidNumber);
  print_log(l_api_name, 'p_isSurrogateBid=' || p_isSurrogateBid);
  print_log(l_api_name, 'p_isAuctionClosed=' || p_isAuctionClosed);

  print_log(l_api_name, p_bidNumber || ': beginning update_proxy_bid');

  SELECT auc.auction_type,
         auc.trading_partner_id,
         auc.number_price_decimals,
         auc.min_bid_change_type,
         NVL(bid.min_bid_change,0),
         bid.trading_partner_id,
         bid.trading_partner_contact_id,
         NVL(bid.rate, 1.0),
         bid.publish_date,
         NVL(bid.number_price_decimals,10),
         NVL(bid.bid_revision_number,1)
  INTO v_auction_type,
       v_trading_partner_id,
       v_auction_decimals,
       v_bid_change_type,
       v_bid_min_change,
       v_tpid,
       v_tpcid,
       v_rate,
       v_publish_date,
       v_bid_decimals,
       v_revision_number
   FROM pon_bid_headers bid,pon_auction_headers_all auc
   WHERE auc.auction_header_id = bid.auction_header_id
     AND bid.bid_number = p_bidNumber;

  -- initialize this price changed flag to not changed
  x_isPriceChanged := 'N';

  -- Save this for PERCENTAGE calculation
  v_bid_min_change_save := v_bid_min_change;


  -- bug #2470367
  -- here we want to copy over any proxy bid lines that could have
  -- changed since the time the user loaded the previous bid into
  -- the response flow.
  -- only the proxy bid lines could have changed
  -- if p_oldBidNumber is null, no active bid exists, hence no need to copy anything over.
  -- for all the lines supposedly under proxy in the current bid, copy over the bid info
  -- from the previous bid if the previous bid line has a later publish date than the
  -- current bid line's publish date.  this will happen if there was another bid placed
  -- before the current bid - either thru proxy or otherwise thru another session.
  print_log(l_api_name, p_bidNumber || ': update_proxy point 1');

  IF (p_oldBidNumber IS NOT NULL) THEN
    UPDATE pon_bid_item_prices newbid
    SET (price,
         bid_currency_price ,
         proxy_bid_limit_price ,
         bid_currency_limit_price ,
         publish_date) =
        (SELECT price,
                bid_currency_price,
                proxy_bid_limit_price,
                bid_currency_limit_price,
                publish_date
         FROM pon_bid_item_prices prevbid
         WHERE prevbid.auction_header_id = newbid.auction_header_id
           AND prevbid.bid_number = p_oldBidNumber
           AND prevbid.line_number = newbid.line_number)
    WHERE newbid.auction_header_id = p_auctionHeaderId
      AND newbid.bid_number = p_bidNumber
      AND newbid.proxy_bid_limit_price IS NOT NULL
      AND newbid.publish_date <> v_publish_date;

  END IF; -- end if 	(p_oldBidNumber IS NOT NULL)

  print_log(l_api_name, p_bidNumber || ': update_proxy point 2');

  -- initialize these
  t_itm_line_number.DELETE;
  t_itm_number_of_bids.DELETE;
  t_itm_best_bid_proxy_limit_prc.DELETE;


  -- MAIN PROXY LOOP
  -- Loop through all proxy bid candidate lines and determine
  -- which lines will need new proxy bids and also determine
  -- at what price the proxy stops, etc.  Store all the details
  -- of any necessary proxy activity in the table of records.
  print_log(l_api_name, p_bidNumber || ': update_proxy before main loop (3)');
  FOR bidlist IN c_proxy_bid_candidates LOOP

    v_number_of_bids := bidlist.number_of_bids;
    print_log(l_api_name, 'cursor=' || bidlist.line_number);

    -- Reset to the original value for v_bid_min_change,
    -- as PERCENTAGE calculation might have changed the value
    v_bid_min_change := v_bid_min_change_save;
    IF (NOT (bidlist.best_bid_tpc_id = v_tpcid)) THEN


      -- if the proxy limit price(s) for the current bid or the best
      -- bid is(are) null, then copy over the bid price into proxy limit price.
      IF (bidlist.best_bid_proxy_limit_price IS NULL) THEN
        v_best_bid_proxy_limit_price := bidlist.best_bid_price;
      ELSE
        v_best_bid_proxy_limit_price := bidlist.best_bid_proxy_limit_price;
      END IF;
      IF (bidlist.proxy_bid_limit_price IS NULL) THEN
        v_proxy_bid_limit_price := bidlist.price;
      ELSE
        v_proxy_bid_limit_price := bidlist.proxy_bid_limit_price;
      END IF;


      IF (v_bid_change_type = 'PERCENTAGE') THEN
        -- first bid from the bidder where do we set this(ssthakur)
        v_bid_min_change := bidlist.first_bid_price * v_bid_min_change / 100;
        v_best_bid_min_change := bidlist.best_bid_first_bid_price * bidlist.best_bid_min_change / 100;
      ELSE
        v_best_bid_min_change := bidlist.best_bid_min_change;
      END IF;

      calculate_prices(v_auction_type,
                       bidlist.price,
                       v_proxy_bid_limit_price,
                       v_bid_min_change,
                       bidlist.best_bid_price,
                       v_best_bid_proxy_limit_price,
                       v_best_bid_min_change,
                       v_new_bid_price,
                       v_new_best_bid_price);

      IF (bidlist.best_bid_price <> v_new_best_bid_price) THEN
        v_proxyBidList(bidlist.line_number).bid_number := bidlist.best_bid_number;
        v_proxyBidList(bidlist.line_number).line_number:= bidlist.line_number;
        v_proxyBidList(bidlist.line_number).bid_price  := v_new_best_bid_price;

        -- (ssthakur) need to ask why are we setting the bid price as the v_new_best_bid_price,
        -- i thougtht we need to set the price as the limit price ie the limit price exhausted for this bid

        -- (ssthakur) also when can be clear the best bid proxy limit price
        v_proxyBidList(bidlist.line_number).bid_currency_price :=
           round(v_proxyBidList(bidlist.line_number).bid_price * bidlist.best_bid_rate,bidlist.best_bid_decimals);

        -- Because of Proxy Bid, increase the number of bids by 1
        v_number_of_bids := v_number_of_bids + 1;

        IF (NOT v_reBidList.EXISTS(bidlist.best_bid_number)) THEN
	  v_reBidList(bidlist.best_bid_number) := -1;
	END IF;

        -- add this line, bidlist.best_bid_number,
        -- v_new_best_bid_price, to the rebid list
      END IF;

      IF (bidlist.price <> v_new_bid_price) THEN
        -- added the decode to handle the case when the limit has been reached
        -- the original bid becomes a proxy bid because the system has
        -- changed the bidder's bid price

        UPDATE pon_bid_item_prices
        SET price = v_new_bid_price,
	    --bug 18437645
	    --Using new bid price in unit_price column instead of price
            unit_price = v_new_bid_price,
            bid_currency_price = decode(v_new_bid_price,v_proxy_bid_limit_price,bid_currency_limit_price,
                                        round(v_new_bid_price * v_rate,v_bid_decimals)),
            bid_currency_unit_price = decode(v_new_bid_price,v_proxy_bid_limit_price,bid_currency_limit_price,
                                             round(v_new_bid_price * v_rate,v_bid_decimals)),
            bid_currency_trans_price = decode(v_new_bid_price,v_proxy_bid_limit_price,bid_currency_limit_price,
                                              round(v_new_bid_price * v_rate,v_bid_decimals)),
            proxy_bid_flag = 'Y'
        WHERE auction_header_id = p_auctionHeaderId
          AND bid_number = p_bidNumber
          AND line_number = bidlist.line_number;

        -- the bid price has been changed due to the proxy bidding,
        -- set the isPriceChanged flag to be true
        x_isPriceChanged := 'Y';

      END IF;

    ELSE

      -- Determine the new best_proxy_bid_limit_price
      -- Same bidder might have changed the proxy_bid_limit_price only
      IF ((bidlist.proxy_bid_limit_price IS NOT NULL) AND
          (NOT (bidlist.proxy_bid_limit_price = NVL(v_best_bid_proxy_limit_price, -1)))) THEN
        v_best_bid_proxy_limit_price := bidlist.proxy_bid_limit_price;
      END IF;

    END IF;

    -- update auction item's number of bids and best_bid_proxy_limit_price --
    -- should we consider forall loop here -- ssthakur

    t_itm_index := t_itm_index +1;
    t_itm_line_number(t_itm_index) := bidlist.line_number;
    t_itm_number_of_bids(t_itm_index) := v_number_of_bids;
    t_itm_best_bid_proxy_limit_prc(t_itm_index) := v_best_bid_proxy_limit_price;


  END LOOP;

  print_log(l_api_name, p_bidNumber || ': (proxy) after proxy loop');
  print_log(l_api_name, p_bidNumber || ': (proxy) we have ' || t_itm_line_number.COUNT || ' lines');

  -- Update pon auction item prices, setting the no of bids and the new proxy limit price
  FORALL x IN 1..t_itm_line_number.COUNT
    UPDATE pon_auction_item_prices_all
    SET number_of_bids = t_itm_number_of_bids(x),
        best_bid_proxy_limit_price = t_itm_best_bid_proxy_limit_prc(x)
    WHERE auction_header_id = p_auctionHeaderId
      AND line_number = t_itm_line_number(x);

  print_log(l_api_name, p_bidNumber || ': (proxy) after mass update');


  -- Update group_amount and buyer_bid_total for the bid here after all of its bid lines are updated.
  -- (woojin) can I just check x_isPriceChanged here?
  update_group_amount(p_bidNumber);

  print_log(l_api_name, p_bidNumber || ': (proxy) after group total ');

  -------------------------------------------------------------------------------
  -- ssthakur no changes are done below this line
  --------------------------------------------------------

  IF (v_reBidList.COUNT > 0) THEN


  print_log(l_api_name, p_bidNumber || ': (proxy) rebid list is not empty');



    v_oldBidNum := v_reBidList.FIRST;

    -- proxy bids will be published a millisecond before the publish
    -- date to give the proxy bid a slight advantage if prices are tied.
    v_proxy_publish_date := v_publish_date - 1/(24*60*60);

    LOOP

      print_log(l_api_name, 'calling subroutine clone_update_bid');

      v_newBidNum := clone_update_bid(p_auctionHeaderId, v_oldBidNum, v_proxy_publish_date,p_bidNumber);

      -- (Raja) add the new proxy bid to the list of bids generated during this publish
      g_bidsGenerated.extend(1);
      g_bidsGeneratedCount := g_bidsGeneratedCount + 1;
      g_bidsGenerated(g_bidsGeneratedCount) := v_newBidNum;

      v_idx := v_proxyBidList.FIRST;

      LOOP
        IF (v_proxyBidList(v_idx).bid_number = v_oldBidNum) THEN
          print_log(l_api_name, 'calling subroutine update_new_bid_line');
          update_new_bid_line(p_auctionHeaderId,
                              v_newBidNum,
                              v_proxyBidList(v_idx).line_number,
                              v_proxyBidList(v_idx).bid_price,
                              v_proxyBidList(v_idx).bid_currency_price,
                              v_proxy_publish_date);
        END IF;

        EXIT WHEN v_idx = v_proxyBidList.LAST;
          v_idx := v_proxyBidList.NEXT(v_idx);
      END LOOP;

      -- Update group_amount and buyer_bid_total for the new proxy bid here.
      update_group_amount(v_newBidNum);
      set_buyer_bid_total(p_auctionHeaderId, v_newBidNum);

      EXIT WHEN v_oldBidNum = v_reBidList.LAST;
      v_oldBidNum := v_reBidList.NEXT(v_oldBidNum);

    END LOOP;

    -- need to explicitly empty the bid list;
    v_proxyBidList := v_emptyProxyBidList;
    v_reBidList    := v_emptyReBidList;

    print_log(l_api_name || '.END', ' ');
    print_log(l_api_name, p_bidNumber || ': ending update_proxy_bid');



  END IF;
END UPDATE_PROXY_BID;


PROCEDURE update_proxy_bid_auto
( p_auctionHeaderId IN NUMBER,
  p_bidNumber       IN NUMBER,
  p_oldBidNumber    IN NUMBER,
  p_isSurrogateBid  IN VARCHAR2,
  p_isAuctionClosed IN VARCHAR2,
  x_isPriceChanged  OUT NOCOPY VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30) := 'update_proxy_bid_auto';
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  print_log(l_api_name, p_bidNumber || ': beginning update_proxy_bid_auto');

  update_proxy_bid(p_auctionHeaderId, p_bidNumber, p_oldBidNumber,
                   p_isSurrogateBid, p_isAuctionClosed, x_isPriceChanged);
  commit;
  print_log(l_api_name, p_bidNumber || ': ending update_proxy_bid_auto');

END update_proxy_bid_auto;



--========================================================================
--========================================================================
--========================================================================
--========================================================================





PROCEDURE update_and_rerank_group_lines
 (p_auctionHeaderId 	NUMBER,
  p_bidNumber			NUMBER,
  p_publishDate 		DATE,
  p_rankIndicator		VARCHAR2,
  p_bidRanking			VARCHAR2,
  p_discard_tech_nonshort       VARCHAR2)

IS
  l_api_name            CONSTANT VARCHAR2(30) := 'update_and_rerank_group_lines';
  CURSOR groups_to_be_reranked(v_publish_date DATE) IS
    SELECT groupline.line_number
    FROM pon_bid_item_prices groupline,
         pon_auction_item_prices_all auctionline
    WHERE groupline.bid_number = p_bidNumber
      AND groupline.publish_date = v_publish_date
      AND auctionline.auction_header_id = groupline.auction_header_id
      AND auctionline.line_number = groupline.line_number
      AND auctionline.group_type = 'GROUP'
      AND groupline.group_amount IS NOT NULL;

  CURSOR bid_group_cursor(v_line_number NUMBER) IS
    SELECT groupline.bid_number
    FROM pon_bid_item_prices groupline,
         pon_bid_headers groupheader
    WHERE groupline.auction_header_id = p_auctionHeaderId
      AND groupline.bid_number = groupheader.bid_number
      AND (groupheader.bid_status = 'ACTIVE'
           OR groupheader.bid_number = p_bidNumber)
      AND groupline.line_number = v_line_number
      AND (
            (
              groupheader.bid_status = 'ACTIVE'
              AND
              decode (p_discard_tech_nonshort, 'Y', groupheader.technical_shortlist_flag, 'Y') = 'Y'
            )
            OR
            groupheader.bid_number = p_bidNumber
          )
    ORDER BY groupline.group_amount, groupline.publish_date ASC;


  TYPE t_tbl_number IS TABLE OF NUMBER
    INDEX BY PLS_INTEGER;

  t_itm_line_number 		t_tbl_number;
  t_itm_bid_number	 		t_tbl_number;
  t_itm_rank				t_tbl_number;

  v_counter PLS_INTEGER;
  v_bestGroupBidNumber NUMBER;
  v_group_rank NUMBER;

BEGIN

  print_log(l_api_name, p_bidNumber || ': BEGIN update_and_rerank_group_lines');
  t_itm_line_number.DELETE;
  t_itm_bid_number.DELETE;
  t_itm_rank.DELETE;

  v_counter := 1;
  FOR rerank_group IN groups_to_be_reranked(p_publishDate) LOOP

    IF (p_rankIndicator = 'NUMBERING') THEN

      v_group_rank := 1;

      FOR bid_group IN bid_group_cursor(rerank_group.line_number) LOOP
        t_itm_bid_number(v_counter) := bid_group.bid_number;
        t_itm_line_number(v_counter) := rerank_group.line_number;
        t_itm_rank(v_counter) := v_group_rank;

        v_group_rank := v_group_rank + 1;
        v_counter := v_counter + 1;
      END LOOP;

    ELSE

      OPEN bid_group_cursor(rerank_group.line_number);
      BEGIN
        FETCH bid_group_cursor into v_bestGroupBidNumber;
      EXCEPTION
        WHEN no_data_found THEN
          v_bestGroupBidNumber := NULL;
      END;
      CLOSE bid_group_cursor;

      IF (v_bestGroupBidNumber IS NOT NULL) THEN
        t_itm_bid_number(v_counter) := v_bestGroupBidNumber;
        t_itm_line_number(v_counter) := rerank_group.line_number;
        t_itm_rank(v_counter) := 1;
        v_counter := v_counter + 1;
      END IF;

    END IF; -- end if (p_rankIndicator = 'NUMBERING')

  END LOOP;

  -- set the pon_auction_item_prices_all.best_bid* attributes
  -- using rank #1 bid
  FORALL x in 1..t_itm_bid_number.COUNT
    UPDATE pon_auction_item_prices_all
    SET best_bid_number = t_itm_bid_number(x),
        best_bid_bid_number = decode(p_bidRanking,
                                     'MULTI_ATTRIBUTE_SCORING',
                                     t_itm_bid_number(x),
                                     null)
    WHERE auction_header_id = p_auctionHeaderId
      AND line_number = t_itm_line_number(x)
      AND t_itm_rank(x) = 1;

  -- if the ranking type is NUMBERING, then we need to also
  -- set pon_bid_item_prices.rank with the appropriate value
  -- we calculated for all group-bids in the above double
  -- FOR loops.
  IF (p_rankIndicator = 'NUMBERING') THEN

    FORALL x in 1..t_itm_bid_number.COUNT
      UPDATE pon_bid_item_prices
      SET rank = t_itm_rank(x)
      WHERE bid_number = t_itm_bid_number(x)
        AND line_number = t_itm_line_number(x);

  END IF;
 print_log(l_api_name, p_bidNumber || ': END update_and_rerank_group_lines');
END update_and_rerank_group_lines;



PROCEDURE update_worsened_lines
 (p_auctionHeaderId 	NUMBER,
  p_bidNumber			NUMBER,
  p_publishDate 		DATE,
  p_bidRanking			VARCHAR2,
  p_discard_tech_nonshort       VARCHAR2)
IS

  l_api_name CONSTANT VARCHAR2(30) := 'update_worsened_lines';

  CURSOR bid_items_to_be_reranked(v_publish_date DATE) IS
    SELECT bidline.line_number
    FROM pon_bid_item_prices bidline,
         pon_bid_headers bidheader,
         pon_bid_headers bestbidheader,
         pon_auction_item_prices_all auctionline
    WHERE auctionline.auction_header_id = bidline.auction_header_id
      AND bidline.bid_number = p_bidNumber
      AND bidline.line_number = auctionline.line_number
      AND bidheader.bid_number = bidline.bid_number
      AND bestbidheader.bid_number = auctionline.best_bid_number
      AND bestbidheader.auction_header_id = bidheader.auction_header_id
      AND bidheader.trading_partner_id = bestbidheader.trading_partner_id
      AND bidheader.trading_partner_contact_id = bestbidheader.trading_partner_contact_id
      AND bidline.publish_date = v_publish_date
      AND bidline.price >= auctionline.best_bid_price;

  CURSOR mas_bid_items_to_be_reranked(v_publish_date DATE) IS
    SELECT bidline.line_number
    FROM pon_bid_item_prices bidline,
         pon_bid_headers bidheader,
         pon_bid_headers bestbidheader,
         pon_auction_item_prices_all auctionline
    WHERE auctionline.auction_header_id = bidline.auction_header_id
      AND bidline.bid_number = p_bidNumber
      AND bidline.line_number = auctionline.line_number
      AND bidheader.bid_number = bidline.bid_number
      AND bestbidheader.bid_number = auctionline.best_bid_bid_number
      AND bestbidheader.auction_header_id = bidheader.auction_header_id
      AND bidheader.trading_partner_id = bestbidheader.trading_partner_id
      AND bidheader.trading_partner_contact_id = bestbidheader.trading_partner_contact_id
      AND bidline.publish_date = v_publish_date
      AND (bidline.total_weighted_score / bidline.price) <=
          (auctionline.best_bid_score / auctionline.best_bid_bid_price);

  TYPE t_tbl_number IS TABLE OF NUMBER
    INDEX BY PLS_INTEGER;

  TYPE t_tbl_date IS TABLE OF DATE
    INDEX BY PLS_INTEGER;

  TYPE t_tbl_varchar IS TABLE OF VARCHAR2(15)
    INDEX BY PLS_INTEGER;

  t_line_number t_tbl_number;
  t_price t_tbl_number;
  t_quantity t_tbl_number;
  t_promised_date t_tbl_date;
  t_bid_number t_tbl_number;
  t_bid_currency_price t_tbl_number;
  t_bid_currency_code t_tbl_varchar;
  t_first_bid_price t_tbl_number;
  t_proxy_bid_limit_price t_tbl_number;
  t_score t_tbl_number;
  v_counter PLS_INTEGER;

BEGIN

  print_log(l_api_name, p_bidNumber || ' - BEGIN update worsened lines');

  t_line_number.DELETE;
  t_price.DELETE;
  t_quantity.DELETE;
  t_promised_date.DELETE;
  t_bid_number.DELETE;
  t_bid_currency_price.DELETE;
  t_bid_currency_code.DELETE;
  t_first_bid_price.DELETE;
  t_proxy_bid_limit_price.DELETE;
  t_score.DELETE;
  v_counter := 1;

  print_log(l_api_name, p_bidNumber || ' - iterating through all non-MAS lines that were worsened');
  FOR rerank_line IN bid_items_to_be_reranked(p_publishDate) LOOP

    print_log(l_api_name, p_bidNumber || ' -    line ' || rerank_line.line_number || ' worsened');

    SELECT line_number,
           price,
           quantity,
           promised_date,
           bid_number,
           bid_currency_price,
           bid_currency_code,
           first_bid_price,
           proxy_bid_limit_price
    INTO t_line_number(v_counter),
         t_price(v_counter),
         t_quantity(v_counter),
         t_promised_date(v_counter),
         t_bid_number(v_counter),
         t_bid_currency_price(v_counter),
         t_bid_currency_code(v_counter),
         t_first_bid_price(v_counter),
         t_proxy_bid_limit_price(v_counter)
    FROM (SELECT bidline.line_number,
                 bidline.price,
                 bidline.quantity,
                 bidline.promised_date,
                 bidline.bid_number,
                 bidline.bid_currency_price,
                 bidheader.bid_currency_code,
                 bidline.first_bid_price,
                 bidline.proxy_bid_limit_price
          FROM pon_bid_item_prices bidline,
               pon_bid_headers bidheader
          WHERE bidline.auction_header_id = p_auctionHeaderId
            AND bidheader.auction_header_id = bidline.auction_header_id
            AND bidheader.bid_number = bidline.bid_number
            AND (
                  (
                    bidheader.bid_status = 'ACTIVE'
                    AND
                    decode (p_discard_tech_nonshort, 'Y', bidheader.technical_shortlist_flag, 'Y') = 'Y'
                  )
                  OR
                  bidheader.bid_number = p_bidNumber
                )
            AND bidline.line_number = rerank_line.line_number
          ORDER BY bidline.price, bidline.publish_date asc)
    WHERE rownum = 1;

    v_counter := v_counter + 1;

  END LOOP;

  FORALL x IN 1..t_line_number.COUNT
    UPDATE pon_auction_item_prices_all
    SET best_bid_price = t_price(x),
        best_bid_quantity = t_quantity(x),
        best_bid_promised_date = t_promised_date(x),
        best_bid_number = t_bid_number(x),
        best_bid_currency_price = t_bid_currency_price(x),
        best_bid_currency_code = t_bid_currency_code(x),
        best_bid_first_bid_price = t_first_bid_price(x),
        best_bid_proxy_limit_price = t_proxy_bid_limit_price(x)
    WHERE auction_header_id = p_auctionHeaderId
      AND line_number = t_line_number(x);

  print_log(l_api_name, p_bidNumber || ' - finished non-MAS lines');


  IF (p_bidRanking = 'MULTI_ATTRIBUTE_SCORING') THEN
    t_line_number.DELETE;
    t_price.DELETE;
    t_score.DELETE;
    t_bid_number.DELETE;
    t_bid_currency_price.DELETE;
    t_bid_currency_code.DELETE;
    v_counter := 1;

    print_log(l_api_name, p_bidNumber || ' - iterating through all MAS worsened lines');
    FOR mas_rerank_line IN mas_bid_items_to_be_reranked(p_publishDate) LOOP

      print_log(l_api_name, p_bidNumber || ' -    line ' || mas_rerank_line.line_number || ' worsened');

      SELECT line_number,
             price,
             total_weighted_score,
             bid_number,
             bid_currency_price,
             bid_currency_code
      INTO t_line_number(v_counter),
           t_price(v_counter),
           t_score(v_counter),
           t_bid_number(v_counter),
           t_bid_currency_price(v_counter),
           t_bid_currency_code(v_counter)
      FROM (SELECT bidline.line_number,
                   bidline.price,
                   bidline.total_weighted_score,
                   bidline.bid_number,
                   bidline.bid_currency_price,
                   bidheader.bid_currency_code
            FROM pon_bid_item_prices bidline,
                 pon_bid_headers bidheader
            WHERE bidline.auction_header_id = p_auctionHeaderId
              AND bidheader.auction_header_id = bidline.auction_header_id
              AND bidheader.bid_number = bidline.bid_number
              AND (
                    (
                      bidheader.bid_status = 'ACTIVE'
                      AND
                      decode (p_discard_tech_nonshort, 'Y', bidheader.technical_shortlist_flag, 'Y') = 'Y'
                    )
                    OR
                    bidheader.bid_number = p_bidNumber
                  )
              AND bidline.line_number = mas_rerank_line.line_number
           ORDER BY bidline.total_weighted_score/bidline.price desc,
                    bidline.publish_date asc)
      WHERE rownum = 1;

      v_counter := v_counter + 1;

    END LOOP;

    FORALL x IN 1..t_line_number.COUNT
    UPDATE pon_auction_item_prices_all
    SET best_bid_bid_price = t_price(x),
        best_bid_score = t_score(x),
        best_bid_bid_number = t_bid_number(x),
        best_bid_bid_currency_price = t_bid_currency_price(x),
        best_bid_bid_currency_code = t_bid_currency_code(x)
    WHERE auction_header_id = p_auctionHeaderId
      AND line_number = t_line_number(x);

  print_log(l_api_name, p_bidNumber || ' - finished MAS lines');
  END IF;

  print_log(l_api_name, p_bidNumber || ' - END update_worsened_lines');

END update_worsened_lines;



PROCEDURE update_new_best_lines
 (p_auctionHeaderId 	NUMBER,
  p_bidNumber			NUMBER,
  p_publishDate 		DATE,
  p_bidRanking			VARCHAR2,
  p_bidCurrencyCode		VARCHAR2,
  p_batchStart          NUMBER,
  p_batchEnd            NUMBER)

IS

BEGIN

  UPDATE pon_auction_item_prices_all auctionline
  SET (auctionline.best_bid_number,
       auctionline.best_bid_price,
       auctionline.best_bid_quantity,
       auctionline.best_bid_promised_date,
       auctionline.best_bid_proxy_limit_price,
       auctionline.best_bid_currency_price,
       auctionline.best_bid_currency_code,
       auctionline.best_bid_first_bid_price)  =
      (SELECT bidline.bid_number,
              bidline.price,
              bidline.quantity,
              bidline.promised_date,
              bidline.proxy_bid_limit_price,
              bidline.bid_currency_price,
              p_bidCurrencyCode,
              bidline.first_bid_price
       FROM pon_bid_item_prices bidline
       WHERE bidline.bid_number = p_bidNumber
         AND bidline.line_number = auctionline.line_number)
  WHERE auctionline.auction_header_id = p_auctionHeaderId
    AND auctionline.group_type <> 'GROUP'
    AND EXISTS (SELECT 'x'
                FROM pon_bid_item_prices bidline
                WHERE bidline.bid_number = p_bidNumber
                  AND bidline.line_number = auctionline.line_number
                  AND bidline.publish_date = p_publishDate)
    AND (auctionline.best_bid_number IS NULL
         OR
         NVL((SELECT is_better_proxy_price(bidline.price,
                                           bidline.bid_number,
                                           bidline.proxy_bid_flag,
                                           bidline.publish_date,
                                           bestbidline.price,
                                           bestbidline.trigger_bid_number,
                                           bestbidline.publish_date)
              FROM pon_bid_item_prices bidline,
                   pon_bid_item_prices bestbidline
              WHERE bidline.bid_number = p_bidNumber
                AND bestbidline.bid_number = auctionline.best_bid_number
                AND bidline.line_number = auctionline.line_number
                AND bestbidline.line_number = auctionline.line_number),
             'FALSE') = 'TRUE')
    AND auctionline.line_number >= p_batchStart
    AND auctionline.line_number <= p_batchEnd;


  IF (p_bidRanking = 'MULTI_ATTRIBUTE_SCORING') THEN

    UPDATE pon_auction_item_prices_all auctionline
    SET (auctionline.best_bid_bid_number,
         auctionline.best_bid_bid_price,
         auctionline.best_bid_score,
         auctionline.best_bid_bid_currency_price,
         auctionline.best_bid_bid_currency_code)  =
        (SELECT bidline.bid_number,
                bidline.price,
                bidline.total_weighted_score,
                bidline.bid_currency_price,
                p_bidCurrencyCode
         FROM pon_bid_item_prices bidline
         WHERE bidline.bid_number = p_bidNumber
           AND bidline.line_number = auctionline.line_number)
    WHERE auctionline.auction_header_id = p_auctionHeaderId
      AND auctionline.group_type <> 'GROUP'
      AND EXISTS (SELECT 'x'
                  FROM pon_bid_item_prices bidline
                  WHERE bidline.bid_number = p_bidNumber
                    AND bidline.line_number = auctionline.line_number
                    AND bidline.publish_date = p_publishDate)
      AND (auctionline.best_bid_bid_number IS NULL
           OR
           NVL((SELECT is_better_proxy_price_by_score(bidline.price,
                                             bidline.total_weighted_score,
                                             bidline.proxy_bid_flag,
                                             bidline.bid_number,
                                             bidline.publish_date,
                                             bestbidline.price,
                                             bestbidline.total_weighted_score,
                                             bestbidline.trigger_bid_number,
                                             bestbidline.publish_date)
                FROM pon_bid_item_prices bidline,
                     pon_bid_item_prices bestbidline
                WHERE bidline.bid_number = p_bidNumber
                  AND bestbidline.bid_number = auctionline.best_bid_bid_number
                  AND bidline.line_number = auctionline.line_number
                  AND bestbidline.line_number = auctionline.line_number),
               'FALSE') = 'TRUE')
    AND auctionline.line_number >= p_batchStart
    AND auctionline.line_number <= p_batchEnd;

  END IF;

END update_new_best_lines;




PROCEDURE rerank_non_group_lines
 (p_auctionHeaderId IN NUMBER,
  p_bidNumber       IN NUMBER,
  p_publishDate     IN DATE,
  p_oldBidNumber    IN NUMBER,
  p_bidRanking      IN VARCHAR2,
  p_batchStart      IN NUMBER,
  p_batchEnd        IN NUMBER,
  p_discard_tech_nonshort IN VARCHAR2)
IS

  -- do not change this!
  DEAD_LAST CONSTANT      NUMBER := 999999;

CURSOR lines_to_be_reranked(v_publish_date DATE) IS
   SELECT bidline.line_number,
   		  bidline.price,
		  bidline.total_weighted_score,
		  bidline.proxy_bid_flag,
   		  NVL(oldBidline.rank, DEAD_LAST) as old_rank
   FROM pon_bid_item_prices bidline,
   		pon_auction_item_prices_all auctionline,
		pon_bid_item_prices oldBidline
   WHERE bidline.bid_number = p_bidNumber
   		 AND bidline.publish_date = v_publish_date
		 AND auctionline.auction_header_id = bidline.auction_header_id
		 AND auctionline.line_number = bidline.line_number
		 AND auctionline.group_type <> 'GROUP'
		 AND auctionline.line_number >= p_batchStart
		 AND auctionline.line_number <= p_batchEnd
		 AND bidline.line_number = oldBidline.line_number(+)
		 and oldBidline.bid_number(+) = NVL(P_oldBidNumber, -1);

  CURSOR bidlines_to_be_reranked(v_line_number NUMBER,
                                 v_new_rank NUMBER,
                                 v_old_rank NUMBER) IS
    SELECT bid_number,
           rank
    FROM pon_bid_item_prices bidline
    WHERE auction_header_id = p_auctionHeaderId
      AND bid_number <> p_bidNumber
      AND line_number = v_line_number
      AND EXISTS (SELECT 'x'
                  FROM pon_bid_headers bidheader
                  WHERE bidheader.bid_number = bidline.bid_number
                    AND bidheader.bid_status = 'ACTIVE'
                    AND decode (p_discard_tech_nonshort, 'Y', bidheader.technical_shortlist_flag, 'Y') = 'Y')
      AND rank BETWEEN DECODE(sign(v_new_rank - v_old_rank), 1, v_old_rank, v_new_rank)
                   AND DECODE(sign(v_new_rank - v_old_rank), 1, v_new_rank, v_old_rank);


  TYPE t_tbl_number IS TABLE OF NUMBER
    INDEX BY PLS_INTEGER;

  t_itm_line_number 		t_tbl_number;
  t_itm_bid_number	 		t_tbl_number;
  t_itm_rank				t_tbl_number;

  v_counter PLS_INTEGER;
  v_newRank NUMBER;
  v_oldRank NUMBER;
  v_price pon_bid_item_prices.price%TYPE;
  v_score pon_bid_item_prices.total_weighted_score%TYPE;
  v_proxyFlag pon_bid_item_prices.proxy_bid_flag%TYPE;


BEGIN

  t_itm_line_number.DELETE;
  t_itm_bid_number.DELETE;
  t_itm_rank.DELETE;

  v_counter := 1;
  FOR rerank_line IN lines_to_be_reranked(p_publishDate) LOOP

  	v_price := rerank_line.price;
	v_score := rerank_line.total_weighted_score;
    v_proxyFlag := rerank_line.proxy_bid_flag;
	v_oldRank := rerank_line.old_rank;

    SELECT count(*) + 1
      INTO v_newRank
      FROM pon_bid_item_prices bidline,
           pon_bid_headers bidheader
     WHERE bidline.auction_header_id = bidheader.auction_header_id
       AND bidheader.auction_header_id = p_auctionHeaderId
       AND bidheader.bid_number = bidline.bid_number
       AND bidline.line_number = rerank_line.line_number
       AND bidheader.bid_status = 'ACTIVE'
       AND decode (p_discard_tech_nonshort, 'Y', bidheader.technical_shortlist_flag, 'Y') = 'Y'
       AND bidheader.bid_number <> p_bidNumber
       AND decode(p_bidRanking, 'MULTI_ATTRIBUTE_SCORING',
                  is_better_proxy_price_by_score(v_price,
                                                 v_score,
                                                 v_proxyFlag,
                                                 p_bidNumber,
                                                 p_publishDate,
                                                 nvl(bidline.group_amount, bidline.price),
                                                 bidline.total_weighted_score,
                                                 bidline.trigger_bid_number,
                                                 bidline.publish_date),
                  is_better_proxy_price(v_price,
                                        p_bidNumber,
                                        v_proxyFlag,
                                        p_publishDate,
                                        nvl(bidline.group_amount, bidline.price),
                                        bidline.trigger_bid_number,
                                        bidline.publish_date)) = 'FALSE';

    t_itm_bid_number(v_counter) := p_bidNumber;
    t_itm_line_number(v_counter) := rerank_line.line_number;
    t_itm_rank(v_counter) := v_newRank;
    v_counter := v_counter + 1;

    IF (v_newRank < v_oldRank) THEN

      FOR rerank_bidline IN bidlines_to_be_reranked(rerank_line.line_number,
                                                    v_newRank, v_oldRank) LOOP
        t_itm_bid_number(v_counter) := rerank_bidline.bid_number;
        t_itm_line_number(v_counter) := rerank_line.line_number;
        t_itm_rank(v_counter) := rerank_bidline.rank + 1;
        v_counter := v_counter + 1;
      END LOOP;

    ELSIF (v_newRank > v_oldRank) THEN

      FOR rerank_bidline IN bidlines_to_be_reranked(rerank_line.line_number,
                                                    v_newRank, v_oldRank) LOOP
        t_itm_bid_number(v_counter) := rerank_bidline.bid_number;
        t_itm_line_number(v_counter) := rerank_line.line_number;
        t_itm_rank(v_counter) := rerank_bidline.rank - 1;
        v_counter := v_counter + 1;
      END LOOP;

    END IF;

  END LOOP;

  FORALL x in 1..t_itm_bid_number.COUNT
    UPDATE pon_bid_item_prices
    SET rank = t_itm_rank(x)
    WHERE bid_number = t_itm_bid_number(x)
      AND line_number = t_itm_line_number(x);

END rerank_non_group_lines;


PROCEDURE update_old_best_bid_number
  (p_auctionHeaderId IN NUMBER,
   p_oldBidNumber IN NUMBER,
   p_bidNumber IN NUMBER,
   p_batchStart IN NUMBER,
   p_batchEnd IN NUMBER)
IS
BEGIN

        UPDATE pon_auction_item_prices_all
        SET best_bid_number = p_bidNumber
        WHERE auction_header_id = p_auctionHeaderId
          AND best_bid_number = p_oldBidNumber
          AND line_number >= p_batchStart
          AND line_number <= p_batchEnd;

        UPDATE pon_auction_item_prices_all
        SET best_bid_bid_number = p_bidNumber
        WHERE auction_header_id = p_auctionHeaderId
          AND best_bid_bid_number = p_oldBidNumber
          AND line_number >= p_batchStart
          AND line_number <= p_batchEnd;

END update_old_best_bid_number;


PROCEDURE update_non_batched_part
 (p_auctionHeaderId 	NUMBER,
  p_bidNumber			NUMBER,
  p_publishDate 		DATE,
  p_rankIndicator		VARCHAR2,
  p_bidRanking			VARCHAR2,
  p_discard_tech_nonshort    VARCHAR2)
IS
BEGIN

  -- UPDATE GROUPS
  -- applies to lines: GROUP lines that were affected by this bid
  -- action performed: (1) re-set best_bid* attributes in pon_auction_item_prices_all
  --                   (2) if ranking is NUMBERING, rerank all bids for each GROUP
  update_and_rerank_group_lines(p_auctionHeaderId, p_bidNumber, p_publishDate,
                                p_rankIndicator, p_bidRanking, p_discard_tech_nonshort);


  -- UPDATE WORSENED LINES
  -- applies to lines: non-GROUP lines where this supplier user previously held the
  --                   best bid, but on this bid, he worsened his bid.
  -- action performed: (1) re-set best_bid* attributes for price-only and MAS negs
  --                   (2) re-set best_bid_bid* attributes for MAS negs
  update_worsened_lines(p_auctionHeaderId, p_bidNumber, p_publishDate, p_bidRanking, p_discard_tech_nonshort);

END update_non_batched_part;


PROCEDURE update_non_batched_part_auto
 (p_auctionHeaderId 	NUMBER,
  p_bidNumber			NUMBER,
  p_publishDate 		DATE,
  p_rankIndicator		VARCHAR2,
  p_bidRanking			VARCHAR2,
  p_discard_tech_nonshort  VARCHAR2)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  update_non_batched_part(p_auctionHeaderId, p_bidNumber, p_publishDate,
                            p_rankIndicator, p_bidRanking, p_discard_tech_nonshort);
  commit;
END update_non_batched_part_auto;


PROCEDURE update_batched_part
 (p_auctionHeaderId 	NUMBER,
  p_bidNumber			NUMBER,
  p_publishDate 		DATE,
  p_oldBidNumber        NUMBER,
  p_vendorSiteId        NUMBER,
  p_bidCurrencyCode     VARCHAR2,
  p_bidRanking			VARCHAR2,
  p_rankIndicator    VARCHAR2,
  p_batchStart          NUMBER,
  p_batchEnd            NUMBER,
  p_discard_tech_nonshort VARCHAR2)
IS
BEGIN

  -- 1) UPDATE NEW BEST LINES
  -- applies to lines: non-GROUP lines where this supplier user has submitted a bid
  --                   that is better than the existing best_bid.
  -- action performed: (1) re-set best_bid* attributes for price-only and MAS negs
  --                   (2) re-set best_bid_bid* attributes for MAS negs
  update_new_best_lines(p_auctionHeaderId, p_bidNumber, p_publishDate,
                        p_bidRanking, p_bidCurrencyCode, p_batchStart, p_batchEnd);


  -- 2) RERANK ALL NON GROUP LINES
  -- applies to lines: all non-GROUP lines
  -- action performed: reranks all the bids for each of these lines
  IF (p_rankIndicator = 'NUMBERING') THEN
    rerank_non_group_lines(p_auctionHeaderId, p_bidNumber, p_publishDate,
                           p_oldBidNumber, p_bidRanking, p_batchStart, p_batchEnd, p_discard_tech_nonshort);
   update_unchanged_rank(p_auctionHeaderId,p_bidNumber,p_vendorSiteId, p_batchStart, p_batchEnd, p_discard_tech_nonshort);
  END IF;


  -- 3) UPDATE UNCHANGED LINES
  -- will go in and replace old active bid number with current bid number
  -- for those lines that did not change
  update_old_best_bid_number(p_auctionHeaderId, p_oldBidNumber, p_bidNumber, p_batchStart, p_batchEnd);

  -- 4) UPDATE NUMBER_OF_BIDS
  -- for all lines on which this bid has a new bid on, we must
  -- increment the pon_auction_item_prices_all.number_of_bids
  -- by 1.
  UPDATE pon_auction_item_prices_all
  SET number_of_bids = nvl(number_of_bids,0) + 1
  WHERE auction_header_id = p_auctionHeaderId
    AND line_number IN (SELECT line_number
                        FROM pon_bid_item_prices
                        WHERE bid_number = p_bidNumber
                          AND publish_date = p_publishDate
                          AND line_number >= p_batchStart
                          AND line_number <= p_batchEnd);

END update_batched_part;

PROCEDURE update_batched_part_batch
 (p_auctionHeaderId 	NUMBER,
  p_bidNumber			NUMBER,
  p_publishDate 		DATE,
  p_oldBidNumber        NUMBER,
  p_vendorSiteId        NUMBER,
  p_bidCurrencyCode     VARCHAR2,
  p_bidRanking			VARCHAR2,
  p_rankIndicator    VARCHAR2,
  p_maxLineNumber       NUMBER,
  p_batchSize           NUMBER,
  p_discard_tech_nonshort VARCHAR2)

IS PRAGMA AUTONOMOUS_TRANSACTION;

  v_batchStart NUMBER;
  v_batchEnd NUMBER;
BEGIN

  v_batchStart := 1;
  v_batchEnd := p_batchSize;

  WHILE (v_batchStart <= p_maxLineNumber) LOOP


    update_batched_part(p_auctionHeaderId, p_bidNumber, p_publishDate,
                        p_oldBidNumber, p_vendorSiteId, p_bidCurrencyCode,
                        p_bidRanking, p_rankIndicator, v_batchStart, v_batchEnd, p_discard_tech_nonshort);
    commit;

    v_batchStart := v_batchEnd + 1;
    IF (v_batchEnd + p_batchSize > p_maxLineNumber) THEN
      v_batchEnd := p_maxLineNumber;
    ELSE
      v_batchEnd := v_batchEnd + p_batchSize;
    END IF;
  END LOOP;

END update_batched_part_batch;




--========================================================================
-- PROCEDURE : update_all_ranks
-- PARAMETERS:
-- VERSION   : current version         1.x
--             initial version         1.0
-- COMMENT   : updates all rank information for all lines and bids
--========================================================================

PROCEDURE update_all_ranks
(p_auctionHeaderId NUMBER,
 p_bidNumber NUMBER,
 p_vendorSiteId NUMBER,
 p_oldBidNumber NUMBER,
 p_maxLineNumber NUMBER,
 p_batchSize NUMBER,
 p_discard_tech_nonshort VARCHAR2)
IS

  v_publishDate pon_bid_headers.publish_date%TYPE;
  v_bidCurrencyCode pon_bid_headers.bid_currency_code%TYPE;

  v_bidRanking  pon_auction_headers_all.bid_ranking%TYPE;
  v_rankIndicator pon_auction_headers_all.rank_indicator%TYPE;

  v_batchingRequired BOOLEAN;

  l_api_name CONSTANT VARCHAR2(30) := 'update_all_ranks';
BEGIN

  SELECT publish_date,
         bid_currency_code
  INTO v_publishDate,
       v_bidCurrencyCode
  FROM pon_bid_headers
  WHERE bid_number = p_bidNumber;

  SELECT pah.bid_ranking,
         pah.rank_indicator
  INTO v_bidRanking,
       v_rankIndicator
  FROM pon_auction_headers_all pah
  WHERE pah.auction_header_id = p_auctionHeaderId;

  v_batchingRequired := (p_maxLineNumber > p_batchSize);

  print_log(l_api_name, p_bidNumber || ' - BEGIN update all ranks');
  print_log(l_api_name, p_bidNumber || ' - batching required? batch size=' || p_batchSize || '; numOfLines=' || p_maxLineNumber);
  print_log(l_api_name, p_bidNumber || ' -     p_auctionHeaderId=' ||  p_auctionHeaderId);
  print_log(l_api_name, p_bidNumber || ' -     p_bidNumber=' || p_bidNumber );
  print_log(l_api_name, p_bidNumber || ' -     p_vendorSiteId=' ||  p_vendorSiteId);
  print_log(l_api_name, p_bidNumber || ' -     p_oldBidNumber=' ||  p_oldBidNumber);
  print_log(l_api_name, p_bidNumber || ' -     p_maxLineNumber=' || p_maxLineNumber );

  -- UPDATE NON BATCHED PART
  -- This procedure performs two tasks:
  --
  -- 1) UPDATE GROUPS
  -- applies to lines: GROUP lines that were affected by this bid
  -- action performed: (1) re-set best_bid* attributes in pon_auction_item_prices_all
  --                   (2) if ranking is NUMBERING, rerank all bids for each GROUP
  -- 2) UPDATE WORSENED LINES
  -- applies to lines: non-GROUP lines where this supplier user previously held the
  --                   best bid, but on this bid, he worsened his bid.
  -- action performed: (1) re-set best_bid* attributes for price-only and MAS negs
  --                   (2) re-set best_bid_bid* attributes for MAS negs
  print_log(l_api_name, p_bidNumber || ' - do unbatched part first');
  IF (v_batchingRequired) THEN
    update_non_batched_part_auto(p_auctionHeaderId, p_bidNumber, v_publishDate,
                                  v_rankIndicator, v_bidRanking, p_discard_tech_nonshort);
  ELSE
    update_non_batched_part(p_auctionHeaderId, p_bidNumber, v_publishDate,
                                  v_rankIndicator, v_bidRanking, p_discard_tech_nonshort);
  END IF;

  -- UPDATE BATCHED PART
  -- This procedure performs these tasks:
  --
  -- 1) UPDATE NEW BEST LINES
  -- applies to lines: non-GROUP lines where this supplier user has submitted a bid
  --                   that is better than the existing best_bid.
  -- action performed: (1) re-set best_bid* attributes for price-only and MAS negs
  --                   (2) re-set best_bid_bid* attributes for MAS negs
  -- 2) RERANK ALL NON GROUP LINES
  -- applies to lines: all non-GROUP lines
  -- action performed: reranks all the bids for each of these lines
  --
  -- 3) UPDATE NUMBER_OF_BIDS
  -- for all lines on which this bid has a new bid on, we must
  -- increment the pon_auction_item_prices_all.number_of_bids
  -- by 1.
  print_log(l_api_name, p_bidNumber || ' - do batched part second');
  IF (v_batchingRequired) THEN
    update_batched_part_batch(p_auctionHeaderId, p_bidNumber, v_publishDate,
                           p_oldBidNumber, p_vendorSiteId, v_bidCurrencyCode,
                           v_bidRanking, v_rankIndicator, p_maxLineNumber, p_batchSize, p_discard_tech_nonshort);
  ELSE
    update_batched_part(p_auctionHeaderId, p_bidNumber, v_publishDate,
                           p_oldBidNumber, p_vendorSiteId, v_bidCurrencyCode,
                           v_bidRanking, v_rankIndicator, 1, p_maxLineNumber, p_discard_tech_nonshort);
  END IF;

  print_log(l_api_name, p_bidNumber || ' - END update all ranks');
END update_all_ranks;




--========================================================================
-- PROCEDURE : update_auction_info     PUBLIC
-- PARAMETERS:
-- VERSION   : current version         1.x
--             initial version         1.0
-- COMMENT   : Updating auction information
--========================================================================

PROCEDURE UPDATE_AUCTION_INFO
( p_auctionHeaderId IN NUMBER,
  p_bidNumber IN NUMBER,
  p_vendorSiteId IN NUMBER,
  p_isRebid IN VARCHAR2,
  p_prevBidNumber IN NUMBER,
  p_isSavingDraft IN VARCHAR2,
  p_isSurrogateBid IN VARCHAR2,
  p_loginUserId IN NUMBER,
  x_return_status OUT NOCOPY NUMBER,
  x_return_code OUT NOCOPY VARCHAR2
)

IS
--

    l_api_name            CONSTANT VARCHAR2(30) := 'update_auction_info';

    -- auto extension variables
    v_autoExtendFlag	pon_auction_headers_all.auto_extend_flag%TYPE;
    v_autoExtendAllLinesFlag pon_auction_headers_all.auto_extend_all_lines_flag%TYPE;
    v_proxyEnabled pon_auc_doctype_rules.display_flag%TYPE;
    v_tradingPartnerId	pon_auction_headers_all.trading_partner_id%TYPE;
    v_is_paused		pon_auction_headers_all.is_paused%TYPE;
    v_supplierViewType	pon_auction_headers_all.supplier_view_type%TYPE;
    v_max_bid_color_sequence_id pon_auction_headers_all.max_bid_color_sequence_id%TYPE; -- Added for Live Cosnole
    v_closeBiddingDateH	pon_auction_item_prices_all.close_bidding_date%TYPE;
    v_closeBiddingDate_old	pon_auction_item_prices_all.close_bidding_date%TYPE;
    v_color_sequence_id pon_bid_headers.color_sequence_id%TYPE; --Added for Live Console
	v_publishDate		DATE;
    v_bidTradingPartnerId      pon_bid_headers.trading_partner_id%TYPE;
	v_rankIndicator		pon_auction_headers_all.rank_indicator%TYPE;
    v_doctypeId             pon_auction_headers_all.doctype_id%TYPE;
	v_oldBidNumber          pon_bid_headers.bid_number%TYPE;
	v_prevActiveBidNumber   pon_bid_headers.bid_number%TYPE;
    v_oldBidStatus          pon_bid_headers.bid_status%TYPE;
	v_hasCloseDateReached 	VARCHAR2(1);
    v_ispricechanged VARCHAR2(1);

    v_pfTypeAllowed pon_auction_headers_all.pf_type_allowed%TYPE;
    v_priceTiersIndicator pon_auction_headers_all.price_tiers_indicator%TYPE;

    v_maxLineNumber NUMBER;
    v_batchSize NUMBER;
    v_batchingRequired BOOLEAN;

    v_max_close_bidding_date pon_auction_headers_all.close_bidding_date%TYPE;
    v_max_num_of_extensions pon_auction_headers_all.number_of_extensions%TYPE;

    l_msg_data                  VARCHAR2(250);
    l_msg_count                 NUMBER;
    l_return_status             VARCHAR2(1);
	v_contermsExist VARCHAR2(1);

    v_extendInterval NUMBER;
    --for staggered closing
    v_orig_close_bidding_date pon_auction_headers_all.close_bidding_date%TYPE;
    v_first_line_close_date pon_auction_headers_all.first_line_close_date%TYPE;
    v_is_staggered_auction varchar2(1);
    v_sealed_auction_status pon_auction_headers_all.sealed_auction_status%TYPE;
    v_two_part_flag pon_auction_headers_all.two_part_flag%TYPE;
    v_discard_tech_nonshort varchar2(1);

    --added by Allen Yang for Surrogate Bid 2008/10/07
    v_technical_evaluation_status pon_auction_headers_all.technical_evaluation_status%TYPE;

BEGIN
--
    -- logging
    print_log(l_api_name, p_bidNumber || ' - beginning of update auction info');
    print_log(l_api_name, '   p_auctionHeaderId=' || p_auctionHeaderId);
    print_log(l_api_name, '   p_bidNumber =' || p_bidNumber );
    print_log(l_api_name, '   p_vendorSiteId=' || p_vendorSiteId);
    print_log(l_api_name, '   p_isRebid=' || p_isRebid);
    print_log(l_api_name, '   p_prevBidNumber=' || p_prevBidNumber);
    print_log(l_api_name, '   p_isSavingDraft=' ||p_isSavingDraft );
    print_log(l_api_name, '   p_isSurrogateBid=' || p_isSurrogateBid);

    v_ispricechanged := 'N';

 --
    -- First check to see if the user's old bid was
    -- disqualified by the auctioneer
    v_oldBidNumber := p_prevBidNumber;

    IF (v_oldBidNumber is not null) THEN
      SELECT bid_status
      INTO v_oldBidStatus
      FROM pon_bid_headers
      WHERE bid_number = v_oldBidNumber;

      IF(v_oldBidStatus = 'DISQUALIFIED') THEN
        v_oldBidNumber := NULL;
      END IF;
    END IF;

    -- (woojin) select the variables we need and at the
    -- same time, lock auction headers to avoid concurrent
    -- access by other bids
    SELECT auto_extend_flag,
	   nvl(auto_extend_all_lines_flag,'Y'),
	   close_bidding_date,
	   trading_partner_id,
	   rank_indicator,
       doctype_id,
	   nvl(is_paused, 'N'),
       supplier_view_type,
       max_internal_line_num,
       DECODE(nvl(max_bid_color_sequence_id,-99),-99,-1, max_bid_color_sequence_id), --Added for Live Console
       pf_type_allowed,
       price_tiers_indicator,
       sealed_auction_status,
       two_part_flag
       -- added by Allen Yang for Surrogate Bid 2008/10/07
       ---------------------------------------------------
       , technical_evaluation_status
       ---------------------------------------------------
    INTO v_autoExtendFlag,
         v_autoExtendAllLinesFlag,
         v_closeBiddingDate_old,
         v_tradingPartnerId,
         v_rankIndicator,
         v_doctypeid,
         v_is_paused,
         v_supplierViewType,
         v_maxLineNumber,
         v_max_bid_color_sequence_id, --Added for Live Console
         v_pfTypeAllowed,
         v_priceTiersIndicator,
         v_sealed_auction_status,
         v_two_part_flag
         -- added by Allen Yang for Surrogate Bid 2008/10/07
         ---------------------------------------------------
         , v_technical_evaluation_status
         ---------------------------------------------------
    FROM pon_auction_headers_all pah
    WHERE auction_header_id = p_auctionHeaderId;

    SELECT publish_date,
           trading_partner_id,
           color_sequence_id --Added for Live Console
    INTO v_publishDate,
         v_bidTradingPartnerId,
         v_color_sequence_id --Added for Live Console
    FROM pon_bid_headers
    WHERE bid_number = p_bidNumber;

    -- check whether this bid is being placed
    -- after close date has been reached, note that
    -- only surrogate bids created by a buyer user can be
    -- placed after close bidding date is reached
    if(v_closeBiddingDate_old < sysdate) then
      v_hasCloseDateReached := 'Y';
    else
      v_hasCloseDateReached := 'N';
    end if;

    -- for batching, we need to find out the max line number of
    -- this neg
    v_batchSize := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
    v_batchingRequired := (v_maxLineNumber > v_batchSize);


    -- ADD HIDDEN PRICE FACTORS
    -- add all price factors hidden to this supplier/site
    -- that are applicable to the supplier/site
	print_log(l_api_name, p_bidNumber || ' - adding hidden price factors');
    IF (v_batchingRequired) THEN
      add_hidden_price_factors_auto(p_bidNumber,
                                     p_auctionHeaderId,
                                     v_supplierViewType,
                                     v_bidTradingPartnerId,
                                     p_vendorSiteId,
                                     p_loginUserId);
    ELSE
      add_hidden_price_factors(p_bidNumber,
                               p_auctionHeaderId,
                               v_supplierViewType,
                               v_bidTradingPartnerId,
                               p_vendorSiteId,
                               p_loginUserId);
    END IF;

    --
    -- Populate the values for per_unit_price_component and
    -- fixed_amount_component in pon_bid_item_prices
    --
    IF (v_batchingRequired) THEN
      set_pf_price_components_auto (p_bidNumber,
                                    v_pfTypeAllowed,
                                    v_priceTiersIndicator);
    ELSE
      set_pf_price_components (p_bidNumber,
                               v_pfTypeAllowed,
                               v_priceTiersIndicator);
    END IF;

    -- ARCHIVE PAST BIDS
    -- (bug 2227167) this used to be done in preSave() in NegotiationResponse
    -- but this caused deadlocks as the archiving was done w/o a lock
    -- on pon_auction_headers.
    --
    -- (amendment) previously, we took care of archiving previous amendment's
    -- and previous round's draft bids here.  however, with LAS project
    -- we have moved archiving those draft bids to the PL/SQL bid defaulting
    -- logic.
	print_log(l_api_name, p_bidNumber || ' - archiving past bids');
    IF (v_batchingRequired) THEN
      archive_prev_active_bids_auto(p_auctionHeaderId, p_bidNumber,
                                    p_vendorSiteId, v_oldBidNumber);
    ELSE
      archive_prev_active_bids(p_auctionHeaderId, p_bidNumber,
                               p_vendorSiteId, v_oldBidNumber);
    END IF;

    -- (Raja) initialise the global variables that track the bids generated during this publish
    g_bidsGenerated := fnd_table_of_number(1);
    g_bidsGeneratedCount := 1;
    g_bidsGenerated(g_bidsGeneratedCount) := p_bidNumber;

    -- AUTO EXTENSION AND PROXY BIDDING
    IF (nvl(p_isSurrogateBid, 'Y') = 'N' OR
        (nvl(p_isSurrogateBid, 'N') = 'Y' AND
         nvl(v_hasCloseDateReached, 'Y') = 'N')) THEN

      -- PROXY BIDDING
      -- the procedure here will calculate and place any proxy bids as
      -- necessary.  If the auction has already closed (surrog bidding)
      -- then don't bother with proxy bidding.  Also, we only allow
      -- proxy bidding for AUCTION doctypes.

      SELECT display_flag
      INTO v_proxyEnabled
      FROM pon_auc_doctype_rules rules,
           pon_auc_bizrules bizrules
      WHERE rules.doctype_id = v_doctypeid
        AND rules.bizrule_id = bizrules.bizrule_id
        AND bizrules.name = 'ALLOW_PROXYBID';

      IF (v_proxyEnabled = 'Y') THEN
        print_log(l_api_name, p_bidNumber || ' - calling subroutine update_proxy_bid');

        IF (v_batchingRequired) THEN
          update_proxy_bid_auto(p_auctionHeaderId, p_bidNumber, v_oldBidNumber,
                                p_isSurrogateBid, v_hasCloseDateReached,v_isPriceChanged);
        ELSE
          update_proxy_bid(p_auctionHeaderId, p_bidNumber, v_oldBidNumber,
	                       p_isSurrogateBid, v_hasCloseDateReached,v_isPriceChanged);
        END IF;
      END IF;

    END IF; -- if ((nvl(p_isSurrogateBid, 'N') = 'Y' AND ...

    -- UPDATE RANK
    -- the following procedure will update the ranking information for all bids
    print_log(l_api_name, p_bidNumber || ' - updating ranking');

    -- For update ranking, we only care about the previous active bid
    -- We can not always use the source bid. For example, in the
    -- amendment case, if the source bid is a bid in the previous
    -- amendment, then its rank should not be used as a reference
    -- to update new ranks
    IF (p_isRebid = 'Y') THEN
       v_prevActiveBidNumber := v_oldBidNumber;
    ELSE
       v_prevActiveBidNumber := NULL;
    END IF;

    --
    -- (uday) For a surrogate bid that is submitted after the commercial unlock in a
    -- two part bid the technical nonshortlisted bids should not be considered
    -- during ranking
    --
    IF ( nvl (p_isSurrogateBid, 'N') = 'Y' AND v_sealed_auction_status <> 'LOCKED'
         AND nvl (v_two_part_flag, 'N') = 'Y') THEN
      v_discard_tech_nonshort := 'Y';
    ELSE
      v_discard_tech_nonshort := 'N';
    END IF;

    -- modified by Allen Yang for Surrogate Bid 2008/10/07
    -------------------------------------------------------
    -- for those surrogate bids submitted in technical stage, we don't update their ranks for auction.
    -- update_all_ranks(p_auctionHeaderId, p_bidNumber, p_vendorSiteId, v_prevActiveBidNumber, v_maxLineNumber, v_batchSize, v_discard_tech_nonshort);
    -- bug 8283481
    IF (Nvl(v_two_part_flag,'N') <> 'Y' OR v_technical_evaluation_status <> 'NOT_COMPLETED' OR p_isSurrogateBid <> 'Y') THEN
      update_all_ranks(p_auctionHeaderId, p_bidNumber, p_vendorSiteId, v_prevActiveBidNumber, v_maxLineNumber, v_batchSize, v_discard_tech_nonshort);
    END IF;
    -------------------------------------------------------

    IF (nvl(p_isSurrogateBid, 'Y') = 'N' OR
        (nvl(p_isSurrogateBid, 'N') = 'Y' AND
         nvl(v_hasCloseDateReached, 'Y') = 'N')) THEN
      -- AUTO EXTENSION
      -- the below procedure takes care of auto-extending any necessary
      -- lines if auto_extend is turned on.

      IF (v_autoExtendFlag = 'Y' OR v_autoExtendFlag = 'y') THEN
        print_log(l_api_name, p_bidNumber || ' - calling subroutine auto_extend_negotiation');

        auto_extend_negotiation (
          p_auctionHeaderId => p_auctionHeaderId,
          p_bidNumber => p_bidNumber,
          p_maxLineNumber => v_maxLineNumber,
          p_batchSize => v_batchSize,
          p_batchingRequired => v_batchingRequired);

      END IF;
    END IF; -- if ((nvl(p_isSurrogateBid, 'N') = 'Y' AND ...

    -- (Raja) delete the global variables that track the bids generated during this publish
    g_bidsGenerated.DELETE;

    -- COLOR SEQUENCE FOR LIVE CONSOLE
    -- For live console, each bid is assigned a color for display
    -- on the bid monitor charts.  If this bid does not have
    -- a color yet, assign one.
    IF (v_color_sequence_id IS NULL) THEN
      print_log(l_api_name, p_bidNumber || ' - updating color sequences');
      UPDATE PON_BID_HEADERS
      SET Color_Sequence_Id = v_max_bid_color_sequence_id +1
      WHERE bid_number = p_bidNumber;

      v_max_bid_color_sequence_id :=  v_max_bid_color_sequence_id +1;
    END IF;  -- end if (v_color_sequence_id IS NULL)
	print_log(l_api_name, p_bidNumber || ' - after color sequencing');

    -- PARTIAL RESPONSE FLAG
    -- calculate and set the partial response flag
	print_log(l_api_name, p_bidNumber || ' - setting partial response flag if necessary');
    set_partial_response_flag(p_bidNumber);

    -- update the best bid number from the archive bid to the new bid
    IF (v_oldBidNumber is not null) THEN

    	print_log(l_api_name, p_bidNumber || ' - updating aution_item_prices by replacing old_bid_number with bid_number in best_bid_number');

-- (woojin) may need to add batching here

        UPDATE pon_auction_item_prices_all
        SET best_bid_number = p_bidNumber
        WHERE auction_header_id = p_auctionHeaderId
          AND best_bid_number = v_oldBidNumber;

        UPDATE pon_auction_item_prices_all
        SET best_bid_bid_number = p_bidNumber
        WHERE auction_header_id = p_auctionHeaderId
          AND best_bid_bid_number = v_oldBidNumber;

----------------------------------------

    END IF;

	print_log(l_api_name, p_bidNumber || ' - after setting best bid number');

    -- UPDATE AUCTION HEADER
    -- here we update fields in the auction header
	print_log(l_api_name, p_bidNumber || ' - updating auction header');
    UPDATE pon_auction_headers_all
    SET max_bid_color_sequence_id = v_max_bid_color_sequence_id, --Added for Live Console
        last_update_date = sysdate,
        number_of_bids = (SELECT COUNT(auction_header_id)
                          FROM pon_bid_headers
                          WHERE auction_header_id = p_auctionHeaderId
                            AND (bid_status in ('ACTIVE', 'ARCHIVED')
                                 OR bid_number = p_bidNumber))
    WHERE auction_header_id = p_auctionHeaderId;

    IF (v_autoExtendFlag = 'Y' OR v_autoExtendFlag = 'y') THEN
      SELECT max(close_bidding_date),
             max(number_of_extensions)
      INTO v_max_close_bidding_date,
           v_max_num_of_extensions
      FROM pon_auction_item_prices_all al
      WHERE al.auction_header_id = p_auctionHeaderId;

      IF (v_max_close_bidding_date IS NOT NULL AND
          v_max_num_of_extensions IS NOT NULL) THEN

        SELECT first_line_close_date,
        close_bidding_date,
        nvl2(staggered_closing_interval,'Y','N')
        INTO v_first_line_close_date,
        v_orig_close_bidding_date,
        v_is_staggered_auction
        FROM pon_auction_headers_all
        WHERE auction_header_id = p_auctionHeaderId;

       	print_log(l_api_name, p_bidNumber ||
                  'v_first_line_close_date : ' || to_char(v_first_line_close_date,'dd:mm:yy hh:mi:ss' ) ||
                  'v_orig_close_bidding_date : ' || to_char(v_orig_close_bidding_date,'dd:mm:yy hh:mi:ss' ) ||
                  'v_max_close_bidding_date : ' || to_char(v_max_close_bidding_date,'dd:mm:yy hh:mi:ss' )||
                  'v_is_staggered_auction : ' || v_is_staggered_auction);

        if(v_is_staggered_auction = 'Y' AND sysdate <= v_first_line_close_date)
        then
          v_first_line_close_date := v_first_line_close_date + (v_max_close_bidding_date -v_orig_close_bidding_date);
        end if;
       	print_log(l_api_name, p_bidNumber || ' New first_line_close_date : ' || to_char(v_first_line_close_date,'dd:mm:yy hh:mi:ss' ));

        UPDATE pon_auction_headers_all
        SET close_bidding_date = v_max_close_bidding_date,
  	        number_of_extensions = v_max_num_of_extensions,
            first_line_close_date = v_first_line_close_date
        WHERE auction_header_id = p_auctionHeaderId;
      END IF;
    END IF;

	print_log(l_api_name, p_bidNumber || ' - after updating auction header');

    -- SET BUYER BID TOTAL
    -- set the bid total in the buyer's view
	print_log(l_api_name, p_bidNumber || ' - setting buyer bid total');
    set_buyer_bid_total(p_auctionHeaderId, p_bidNumber);
	print_log(l_api_name, p_bidNumber || ' - after setting buyer bid total');

    -- DELIVERABLES INTEGRATION
    -- need to also check whether the current auction has
    -- contract terms associated with it

      if (PON_CONTERMS_UTL_PVT.is_contracts_installed() = FND_API.G_TRUE) then

        begin
		select conterms_exist_flag into v_contermsExist
		from pon_auction_headers_all
		where auction_header_id = p_auctionHeaderId;

		if(v_contermsExist = 'Y') then
                    print_log(l_api_name, p_bidNumber || ': ' ||'calling subroutine PON_CONTERMS_UTL_PVT.activateDeliverables');
  		    PON_CONTERMS_UTL_PVT.activateDeliverables(p_auctionHeaderId,
						  	p_bidNumber,
						  	v_oldBidNumber,
						  	l_msg_data,
						  	l_msg_count,
					  	  	l_return_status);

		   if(v_autoExtendFlag = 'Y' OR v_autoExtendFlag = 'y' OR
	 	      v_autoExtendAllLinesFlag ='Y' OR v_autoExtendAllLinesFlag = 'y') then


             -- Get the old close bidding date, number of extensions in the header.
             v_closeBiddingDateH := v_closeBiddingDate_old;

             select max(close_bidding_date)
             into v_closeBiddingDateH
             from pon_auction_item_prices_all
             where auction_header_id = p_auctionHeaderId;

             -- we need to update all the deliverables
             -- if and only if this bid has caused auto-extension
                   print_log(l_api_name, p_bidNumber || ': ' ||'calling subroutine PON_CONTERMS_UTL_PVT.updateDeliverables');
         	   PON_CONTERMS_UTL_PVT.updateDeliverables(p_auctionHeaderId,
							v_doctypeid,
							v_closeBiddingDateH,
							l_msg_data,
							l_msg_count,
							l_return_status);
  		   end if;
		end if;
--        exception
--         when others then
--          null;
        end;
      end if;


  IF v_isPriceChanged = 'Y' THEN
    x_return_code := 'IS_PRICE_CHANGED';
    x_return_status := 2;
  print_log(l_api_name, p_bidNumber || ' - update auction info returns with price change=Y');
  END IF;

  print_log(l_api_name, p_bidNumber || ' - END update auction info');

END  update_auction_info;


--

/**
  * This function calculates the total price on a line including the
  * buyer and the supplier price factors in auction currency.
  *
  * This function will be used in view objects to display supplier's
  * previous round price as the start price for this line instead of the
  * auction line start price.
  *
  * This is as per Cendant requirement to enforce upon suppliers to
  * bid lower than their bid on the previous round of the negotiation
  *
  * Currently anticipated usage of this function are on View Bid Page
  * (ViewBidItemsVO), Negotiation Summary page (AuctionItemPricesAllVO)
  * and bid creation page (ResponseAMImpl)
  *
  * p_auction_header_id - current round auction header id
  * p_prev_auc_active_bid_number - bid number on the previous round
  * p_line_number  - current line number
  * p_contract_type  - negotiation contract type
  * p_supplier_vuiew_type  - supplier view TRANSFORMED/UNTRANSFORMED
  * p_pf_type_allowed - allowed price factors BOTH/BUYER/SUPPLIER/NONE
  * p_reverse_transform_flag - a flag indicating if buyer price factors should be
  *                            applied even if suppplier view is untransformed
  *                            The price is reverse transformed during the display
  *                            time therefore VOs using this funtion expect a
  *                            transformed price. However, the printing pkg
  *                            expects untransformed price if so defined by the
  *                            supplier view.
*/


FUNCTION APPLY_PRICE_FACTORS(
							 p_auction_header_id			IN NUMBER,
                             p_prev_auc_active_bid_number  	IN NUMBER,
                             p_line_number           		IN NUMBER,
                             p_contract_type        		IN VARCHAR2,
                             p_supplier_view_type   		IN VARCHAR2,
                             p_pf_type_allowed      		IN VARCHAR2,
                             p_reverse_transform_flag		IN VARCHAR2
                             )
RETURN NUMBER IS

  l_api_name CONSTANT VARCHAR2(30) := 'apply_price_factors';
  l_progress VARCHAR2(100) := '0';

  l_total_price NUMBER;
  l_bid_line_pf_unit_price NUMBER;
  l_auc_pf_unit_price NUMBER;

  l_contract_type pon_auction_headers_all.contract_type%TYPE;
  l_supplier_view_type pon_auction_headers_all.supplier_view_type%TYPE;
  l_pf_type_allowed pon_auction_headers_all.pf_type_allowed%TYPE;

  l_bid_auction_curr_unit_price pon_bid_item_prices.unit_price%TYPE;
  l_bid_quantity pon_bid_item_prices.quantity%TYPE;

  l_is_spo_transformed VARCHAR2(1);


BEGIN

-- auction information that we need
-- Query auction headers only if the required information is available
print_log(l_api_name, ' - BEGIN apply_price_factors');
IF (p_contract_type IS NULL OR
    p_supplier_view_type IS NULL OR
    p_pf_type_allowed IS NULL) THEN

    l_progress := '10: fetch auction information';

    SELECT  contract_type,
            supplier_view_type,
            pf_type_allowed
    INTO    l_contract_type,
    	    l_supplier_view_type,
    	    l_pf_type_allowed
    FROM	pon_auction_headers_all
    WHERE	auction_header_id = p_auction_header_id;
ELSE
    -- assign the input parameters to the local variables.
    l_contract_type := p_contract_type;
    l_supplier_view_type := p_supplier_view_type;
    l_pf_type_allowed := p_pf_type_allowed;
END IF;

l_progress := '20: perform SPO/TRANSFORMED check';

IF (l_supplier_view_type = 'TRANSFORMED' AND
    l_contract_type = 'STANDARD') THEN
      l_is_spo_transformed := 'Y';
ELSE
      l_is_spo_transformed := 'N';
END IF;

-- bid information that we need

l_progress := '30: fetch previous round active bid information';

SELECT unit_price,
       quantity
INTO   l_bid_auction_curr_unit_price,
       l_bid_quantity
FROM   pon_bid_item_prices
WHERE  bid_number = p_prev_auc_active_bid_number
AND	   line_number = p_line_number;

-- assign values to the buyer and supplier pf values
-- in case the following query is not executed or has no rows.
l_auc_pf_unit_price := l_bid_auction_curr_unit_price;
l_bid_line_pf_unit_price := 0;

-- calculate the buyer price factors if
-- 1. Buyer price factors are allowed
-- 2. supplier view type is transformed
-- 3. reverse transformed value is not required

IF (l_pf_type_allowed = 'BUYER' OR l_pf_type_allowed = 'BOTH') THEN
	IF (l_supplier_view_type = 'TRANSFORMED' OR
		p_reverse_transform_flag = 'N') THEN
		l_progress := '40: calculate buyer price factors';

		BEGIN

		SELECT  (l_bid_auction_curr_unit_price * ppsf.percentage) +
        		ppsf.unit_price +
        		ppsf.fixed_amount/decode(l_is_spo_transformed,
                		                 'Y', nvl(l_bid_quantity, 1),
                        		         nvl(aip.quantity, 1)
                                		 )
		INTO    l_auc_pf_unit_price
		FROM	pon_pf_supplier_formula ppsf,
       			pon_auction_item_prices_all aip,
		       	pon_bid_headers pbh
		WHERE 	ppsf.auction_header_id = p_auction_header_id
		AND   	ppsf.line_number = p_line_number
		AND   	ppsf.trading_partner_id = pbh.trading_partner_id
		AND   	ppsf.vendor_site_id = pbh.vendor_site_id
		AND 	pbh.bid_number = p_prev_auc_active_bid_number
		AND     aip.auction_header_id = ppsf.auction_header_id
		AND   	aip.line_number = ppsf.line_number;

		EXCEPTION

  			WHEN NO_DATA_FOUND THEN
  				l_auc_pf_unit_price := l_bid_auction_curr_unit_price;

		END;

	END IF; -- supplier view is 'TRANSFORMED'
END IF; -- buyer price factors are allowed.

-- calculate the supplier price factors
-- 1. supplier price factors are allowed

l_progress := '50: calculate supplier price factors';
IF (l_pf_type_allowed = 'SUPPLIER' OR l_pf_type_allowed = 'BOTH') THEN
	SELECT nvl(sum(decode(spf.pricing_basis,
    	                 'PER_UNIT', spf.auction_currency_value,
        	             'PERCENTAGE',  spf.auction_currency_value/100 * l_bid_auction_curr_unit_price,
            	         (spf.auction_currency_value / decode(l_is_spo_transformed,
                	                                      'Y', nvl(l_bid_quantity, 1),
                    	                                   nvl(aip.quantity, 1)
                        	                              )
	                     )
    	                 )
	        	       )
    	       ,0)
	INTO l_bid_line_pf_unit_price
	FROM pon_bid_price_elements spf,
    	 pon_auction_item_prices_all aip
	WHERE spf.bid_number = p_prev_auc_active_bid_number
	AND spf.line_number  = p_line_number
	AND spf.sequence_number <> -10
	AND spf.pf_type = 'SUPPLIER'
	AND aip.auction_header_id = spf.auction_header_id
	AND aip.line_number = spf.line_number;

END IF;

-- total price in auction currency
l_progress := '60: return total price in auction currency';
l_total_price := l_bid_line_pf_unit_price + l_auc_pf_unit_price;

print_log(l_api_name, 'returned l_total_price=' || l_total_price|| ' - END apply_price_factors');
RETURN l_total_price;

EXCEPTION

     WHEN OTHERS THEN
	  IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)THEN
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name, SQLERRM);
	     IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
		   fnd_log.string(log_level => fnd_log.level_unexpected
		                  ,module    => g_pkg_name||'.'||l_api_name
                          ,message   => l_progress || ': ' || SQLERRM);
	       fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'Input parameter list: ' );
           fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'Auction Header Id = ' ||  p_auction_header_id);
           fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'Previous Round Active Bid Number = ' || p_prev_auc_active_bid_number);
           fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'Line Number = ' || p_line_number);
           fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'contract type = ' || p_contract_type);
           fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'supplier view type = ' || p_supplier_view_type);
           fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'pf type allowed = ' || p_pf_type_allowed);
           fnd_log.string(log_level=>fnd_log.level_unexpected,
                                module   =>g_pkg_name ||'.'||l_api_name,
                                message  => 'reverse tranform flag = ' || p_reverse_transform_flag);
         END IF;
      END IF;

      RETURN NULL;
END   apply_price_factors;

--========================================================================
-- PROCEDURE : updt_tech_short_lines
-- PARAMETERS: x_result             : Standard Error OUT parameter
--             x_error_code         : Standard Error OUT parameter
--             x_error_msg          : Standard Error OUT parameter
--             p_auction_header_id  : Auction Header Id
--             p_bid_ranking        : Bid ranking (price only/MAS)
--             p_rank_indicator     : Rank Indicator (Numbering/Win-Lose/None)
--             p_batch_start        : line_number of first line in batch
--             p_batch_end          : line_number of last line in batch
-- COMMENT   : This procedure will process each of the lines between
--             p_batch_start and p_batch_end. It will do the following
--
--             1. Check to see if any bid on this line has been left out
--             2. If there is no such bid then we can go ahead with the next
--                line.
--             3. If there is atleast one bid then check to see if this is the
--                best bid for this line.
--             4. If this is the best bid then ignoring this bid line find out
--                the best bid for this line and update pon_auction_item_prices_all
--             5. If this is not the best bid then proceed to next step.
--             6. Re-order all the bid lines (ranks) ignoring the bids that have
--                not been shortlisted.
--========================================================================
PROCEDURE updt_tech_short_lines ( -- {
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_msg OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  p_bid_ranking IN VARCHAR2,
  p_rank_indicator IN VARCHAR2,
  p_batch_start IN NUMBER,
  p_batch_end IN NUMBER
)
IS

l_module_name VARCHAR2(40) := 'updt_tech_short_lines';

v_bid_number pon_bid_headers.bid_number%TYPE;
v_best_bid_number pon_auction_item_prices_all.best_bid_number%TYPE;
v_best_bid_bid_number pon_auction_item_prices_all.best_bid_bid_number%TYPE;
v_bestbid_shortlist_flag pon_bid_headers.shortlist_flag%TYPE;
v_currentline_group_type pon_auction_item_prices_all.group_type%TYPE;
t_price pon_bid_item_prices.price%TYPE;
t_quantity pon_bid_item_prices.quantity%TYPE;
t_promised_date pon_bid_item_prices.promised_date%TYPE;
t_bid_number pon_bid_item_prices.bid_number%TYPE;
t_bid_currency_price pon_bid_item_prices.bid_currency_price%TYPE;
t_bid_currency_code pon_bid_headers.bid_currency_code%TYPE;
t_first_bid_price pon_bid_item_prices.first_bid_price%TYPE;
t_proxy_bid_limit_price pon_bid_item_prices.proxy_bid_limit_price%TYPE;
t_score pon_bid_item_prices.total_weighted_score%TYPE;

v_bid_numbers_bulk PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
v_rank_bulk PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;

CURSOR all_lines_cursor IS
  SELECT line_number
  FROM  pon_auction_item_prices_all
  WHERE auction_header_id = p_auction_header_id
  AND line_number >= p_batch_start
  AND line_number <= p_batch_end
  ORDER BY line_number;

BEGIN
  x_result := FND_API.G_RET_STS_SUCCESS;

  -- For each line do the following
  FOR auction_item_record IN all_lines_cursor LOOP -- {

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Processing line: ' || auction_item_record.line_number);
    END IF; --}

    -- Check if any bid on this line has been removed from the shortlist
    BEGIN  -- {
      SELECT
        pbh.bid_number
      INTO
        v_bid_number
      FROM
        pon_bid_item_prices pbip,
        pon_bid_headers pbh
      WHERE
        pbh.auction_header_id = p_auction_header_id
        AND pbip.bid_number = pbh.bid_number
        AND nvl (pbh.shortlist_flag, 'Y') = 'N'
        AND pbh.bid_status = 'ACTIVE'
        AND pbip.line_number = auction_item_record.line_number
        AND ROWNUM = 1;

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || l_module_name,
          message  => 'Got a bid ' || v_bid_number || ' that was removed from the shortlist.');
      END IF; --}

      EXCEPTION WHEN NO_DATA_FOUND THEN

        v_bid_number := null;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module  =>  g_module_prefix || l_module_name,
            message  => 'Could not find any bid that was removed from the shortlist.');
        END IF; --}

    END; -- }

    -- If all are shortlisted then nothing to do for this line
    IF (v_bid_number IS NOT null) THEN -- {

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || l_module_name,
          message  => 'v_bid_number is not null, there is one bid to be removed.');
      END IF; --}

      -- Get the best bid_number for this line
      SELECT
        paip.best_bid_number,
        paip.best_bid_bid_number,
        paip.group_type
      INTO
        v_best_bid_number,
        v_best_bid_bid_number,
        v_currentline_group_type
      FROM
        pon_auction_item_prices_all paip
      WHERE
        paip.auction_header_id = p_auction_header_id
        AND paip.line_number = auction_item_record.line_number;

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || l_module_name,
          message  => 'Got the best bid_number. v_best_bid_number = ' ||
                     v_best_bid_number || ', v_best_bid_bid_number = ' ||
                      v_best_bid_bid_number || ', v_currentline_group_type = ' ||
                      v_currentline_group_type);
      END IF; --}

      IF (v_best_bid_number IS NOT NULL) THEN -- {

        -- Check the shortlist flag for this best bid
        SELECT
          nvl (pbh.shortlist_flag, 'Y')
        INTO
          v_bestbid_shortlist_flag
        FROM
          pon_bid_headers pbh
        WHERE
          pbh.bid_number = v_best_bid_number;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module  =>  g_module_prefix || l_module_name,
            message  => 'Got the best bid_number. ' || ', v_bestbid_shortlist_flag = ' ||
                        v_bestbid_shortlist_flag);
        END IF; --}

        IF (v_bestbid_shortlist_flag = 'Y' AND p_bid_ranking =
		'MULTI_ATTRIBUTE_SCORING') THEN -- {

          IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || l_module_name,
              message  => 'This is an MAS and the best_bid_number has been shortlisted');
          END IF; --}

          SELECT
            nvl (pbh.shortlist_flag, 'Y')
          INTO
            v_bestbid_shortlist_flag
          FROM
            pon_bid_headers pbh
          WHERE
            pbh.bid_number = v_best_bid_bid_number;

        END IF; -- }

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module  =>  g_module_prefix || l_module_name,
            message  => 'After MAS check. Got the best bid_number. ' || ', v_bestbid_shortlist_flag = ' ||
                        v_bestbid_shortlist_flag);
        END IF; --}

        -- If this bid has not been shortlisted then
        IF (v_bestbid_shortlist_flag = 'N') THEN -- {

          IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || l_module_name,
              message  => 'The best bid has not been shortlisted.');
          END IF; --}

          BEGIN -- {
            -- Update the columns in pon_auction_item_prices corresponding to
            --    the best_bid after ignoring the non-shortlisted bids
            SELECT
              price,
              quantity,
              promised_date,
              bid_number,
              bid_currency_price,
              bid_currency_code,
              first_bid_price,
              proxy_bid_limit_price
            INTO
              t_price,
              t_quantity,
              t_promised_date,
              t_bid_number,
              t_bid_currency_price,
              t_bid_currency_code,
              t_first_bid_price,
              t_proxy_bid_limit_price
            FROM
               (SELECT
                  bidline.line_number,
                  bidline.price,
                  bidline.quantity,
                  bidline.promised_date,
                  bidline.bid_number,
                  bidline.bid_currency_price,
                  bidheader.bid_currency_code,
                  bidline.first_bid_price,
                  bidline.proxy_bid_limit_price
                FROM
                  pon_bid_item_prices bidline,
                  pon_bid_headers bidheader
                WHERE
                  bidline.auction_header_id = p_auction_header_id
                  AND bidheader.auction_header_id = bidline.auction_header_id
                  AND bidheader.bid_number = bidline.bid_number
                  AND bidheader.bid_status = 'ACTIVE'
                  AND nvl (bidheader.shortlist_flag, 'Y') = 'Y'
                  AND bidline.line_number = auction_item_record.line_number
                ORDER BY
                  decode (v_currentline_group_type, 'GROUP', bidline.group_amount, bidline.price),
                  bidline.publish_date asc)
            WHERE
              rownum = 1;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
              FND_LOG.string(log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || l_module_name,
                message  => 'Found another best bid.');
            END IF; --}

          EXCEPTION WHEN NO_DATA_FOUND THEN

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
              FND_LOG.string(log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || l_module_name,
                message  => 'Could not find another best bid.');
            END IF; --}

            t_price := null;
            t_quantity := null;
            t_promised_date := null;
            t_bid_number := null;
            t_bid_currency_price := null;
            t_bid_currency_code := null;
            t_first_bid_price := null;
            t_proxy_bid_limit_price := null;
          END; -- }

          IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || l_module_name,
              message  => 'Queries values from best bid: t_price = ' || t_price
                          || ', t_quantity = ' || t_quantity || ', t_promised_date = ' ||
                          t_promised_date || ', t_bid_number = ' || t_bid_number
                          || ', t_bid_currency_price = ' || t_bid_currency_price
                          || ', t_bid_currency_code = ' || t_bid_currency_code ||
  			', t_first_bid_price = ' || t_first_bid_price ||
  			', t_proxy_bid_limit_price = ' || t_proxy_bid_limit_price);
          END IF; --}

          IF (v_currentline_group_type = 'GROUP') THEN -- {

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
              FND_LOG.string(log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || l_module_name,
                message  => 'Current line is a group no need to set all columns, '
                            || 'just best_bid_number and best_bid_bid_number');
            END IF; --}

            UPDATE
              pon_auction_item_prices_all
            SET
              best_bid_number = t_bid_number
            WHERE
              auction_header_id = p_auction_header_id
              AND line_number = auction_item_record.line_number;

          ELSE -- } {

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
              FND_LOG.string(log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || l_module_name,
                message  => 'This is not a GROUP line.');
            END IF; --}

            UPDATE
              pon_auction_item_prices_all
            SET
              best_bid_price = t_price,
              best_bid_quantity = t_quantity,
              best_bid_promised_date = t_promised_date,
              best_bid_number = t_bid_number,
              best_bid_currency_price = t_bid_currency_price,
              best_bid_currency_code = t_bid_currency_code,
              best_bid_first_bid_price = t_first_bid_price,
              best_bid_proxy_limit_price = t_proxy_bid_limit_price
            WHERE
              auction_header_id = p_auction_header_id
              AND line_number = auction_item_record.line_number;

          END IF; -- }

          IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || l_module_name,
              message  => 'Updated pon_auction_item_prices_all');
          END IF; --}

          IF (p_bid_ranking = 'MULTI_ATTRIBUTE_SCORING') THEN -- {

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
              FND_LOG.string(log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || l_module_name,
                message  => 'This is an MAS auction.');
            END IF; --}

            IF (v_currentline_group_type = 'GROUP') THEN -- {

              UPDATE
                pon_auction_item_prices_all
              SET
                best_bid_bid_number = decode (p_bid_ranking,
                                        'MULTI_ATTRIBUTE_SCORING', t_bid_number,
                                        null)
              WHERE
                auction_header_id = p_auction_header_id
                AND line_number = auction_item_record.line_number;

            ELSE -- } {

              BEGIN -- {
                SELECT
                  price,
                  total_weighted_score,
                  bid_number,
                  bid_currency_price,
                  bid_currency_code
                INTO
                  t_price,
                  t_score,
                  t_bid_number,
                  t_bid_currency_price,
                  t_bid_currency_code
                FROM
                  (SELECT
                     bidline.line_number,
                     bidline.price,
                     bidline.total_weighted_score,
                     bidline.bid_number,
                     bidline.bid_currency_price,
                     bidheader.bid_currency_code
                   FROM
                     pon_bid_item_prices bidline,
                     pon_bid_headers bidheader
                   WHERE
                     bidline.auction_header_id = p_auction_header_id
                     AND bidheader.auction_header_id = bidline.auction_header_id
                     AND bidheader.bid_number = bidline.bid_number
                     AND bidheader.bid_status = 'ACTIVE'
                     AND nvl (bidheader.shortlist_flag, 'Y') = 'Y'
                     AND bidline.line_number = auction_item_record.line_number
                   ORDER BY
                     bidline.total_weighted_score/bidline.price desc,
                     bidline.publish_date asc)
                WHERE
                  rownum = 1;
              EXCEPTION WHEN NO_DATA_FOUND THEN
                t_price := null;
                t_score := null;
                t_bid_number := null;
                t_bid_currency_price := null;
                t_bid_currency_code := null;
              END; -- }

              IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
                FND_LOG.string(log_level => FND_LOG.level_statement,
                  module  =>  g_module_prefix || l_module_name,
                  message  => 'Queries best MAS bid values: t_price = ' || t_price
                              || 't_score = ' || t_score || ', t_bid_number = ' ||
  	                    t_bid_number || ', t_bid_currency_price = ' ||
  		            t_bid_currency_price || ', t_bid_currency_code = ' ||
  		            t_bid_currency_code);
              END IF; --}

              UPDATE
                pon_auction_item_prices_all
              SET
                best_bid_bid_price = t_price,
                best_bid_score = t_score,
                best_bid_bid_number = t_bid_number,
                best_bid_bid_currency_price = t_bid_currency_price,
                best_bid_bid_currency_code = t_bid_currency_code
              WHERE
                auction_header_id = p_auction_header_id
                AND line_number = auction_item_record.line_number;

              IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
                FND_LOG.string(log_level => FND_LOG.level_statement,
                  module  =>  g_module_prefix || l_module_name,
                  message  => 'Updated pon_auction_item_prices_all');
              END IF; --}

            END IF; -- }

          END IF; -- }

        END IF; -- }

        -- Do the resetting of ranks only if the rank indicator is numbering
        IF (p_rank_indicator = 'NUMBERING') THEN -- {

          IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || l_module_name,
              message  => 'The rank indicator for this auction is NUMBERING.');
          END IF; --}

          -- Empty out the table of numbers before using them
          v_bid_numbers_bulk.DELETE;
          v_rank_bulk.DELETE;

          -- Bulk collect all the bid numbers, rank, status of bids that are
          -- active and shortlisted ordered by rank
          SELECT
            pbh.bid_number,
            pbip.rank
          BULK COLLECT INTO
            v_bid_numbers_bulk,
            v_rank_bulk
          FROM
            pon_bid_headers pbh,
            pon_bid_item_prices pbip
          WHERE
            pbh.auction_header_id = p_auction_header_id
            AND pbh.bid_number = pbip.bid_number
            AND pbh.bid_status = 'ACTIVE'
            AND pbip.line_number = auction_item_record.line_number
            AND nvl (pbh.shortlist_flag, 'Y') = 'Y'
          ORDER BY
            pbip.rank;

          IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || l_module_name,
              message  => 'Bulk collected the ranks and bid numbers.');
          END IF; --}

          -- Loop over and set the rank starting from 1
          FOR x IN 1..v_bid_numbers_bulk.COUNT LOOP -- {
            v_rank_bulk (x) := x;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
              FND_LOG.string(log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || l_module_name,
                message  => 'Setting rank as ' || v_rank_bulk (x) || ' for bid '
                            || v_bid_numbers_bulk (x));
            END IF; --}
          END LOOP; -- }

          -- Update pon_bid_item_prices with the new rank
          FORALL x IN 1..v_bid_numbers_bulk.COUNT
          UPDATE pon_bid_item_prices pbip
          SET rank = v_rank_bulk (x)
          WHERE bid_number = v_bid_numbers_bulk (x)
          AND line_number = auction_item_record.line_number;

          IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || l_module_name,
              message  => 'Done updating the ranks for all the bid items.');
          END IF; --}

        END IF; -- }

      END IF; --}

    END IF; --}

  END LOOP; -- }

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_msg := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' || x_error_code ||
                   ', error_message = ' || x_error_msg);
    END IF;

END; --}

--========================================================================
-- PROCEDURE : updt_tech_short_lines_batched
-- PARAMETERS: x_result             : Standard Error OUT parameter
--             x_error_code         : Standard Error OUT parameter
--             x_error_msg          : Standard Error OUT parameter
--             p_auction_header_id  : Auction Header Id
--             p_bid_ranking        : Bid ranking (price only/MAS)
--             p_rank_indicator     : Rank Indicator (Numbering/Win-Lose/None)
--             p_max_line_number    : The max line number in this auction
--             p_batch_size         : Batch size (in case of super large)
-- COMMENT   : This method is a wrapper over updt_tech_short_lines to call
--             that method multiple times in case of batching.
--
--========================================================================
PROCEDURE updt_tech_short_lines_batched ( -- {
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_msg OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  p_bid_ranking IN VARCHAR2,
  p_rank_indicator IN VARCHAR2,
  p_max_line_number IN NUMBER,
  p_batch_size IN NUMBER
)
IS

PRAGMA AUTONOMOUS_TRANSACTION;

v_batch_start NUMBER;
v_batch_end NUMBER;
l_module_name CONSTANT VARCHAR2 (40) := 'updt_tech_short_lines_batched';

BEGIN

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Entering procedure with p_auction_header_id: ' || p_auction_header_id || '; p_bid_ranking: ' || p_bid_ranking || '; p_max_line_number: '
                        || p_max_line_number || '; p_batch_size: ' || p_batch_size);
  END IF; --}

  x_result := FND_API.G_RET_STS_SUCCESS;

  v_batch_start := 1;
  v_batch_end := p_batch_size;

  WHILE (v_batch_start <= p_max_line_number) LOOP -- {

    updt_tech_short_lines (x_result, x_error_code, x_error_msg,
      p_auction_header_id, p_bid_ranking, p_rank_indicator, v_batch_start,
      v_batch_end);
    commit;

    v_batch_start := v_batch_end + 1;
    IF (v_batch_end + p_batch_size > p_max_line_number) THEN -- {
      v_batch_end := p_max_line_number;
    ELSE
      v_batch_end := v_batch_end + p_batch_size;
    END IF; -- }

  END LOOP; -- }
  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Leaving procedure');
  END IF; --}

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_msg := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' || x_error_code ||
                   ', error_message = ' || x_error_msg);
    END IF;

END; -- }

-- (uday)
--========================================================================
-- PROCEDURE : update_auction_info_tech_short
-- PARAMETERS: x_result             : Standard Error OUT parameter
--             x_error_code         : Standard Error OUT parameter
--             x_error_msg          : Standard Error OUT parameter
--             p_auction_header_id  : Auction Header Id
--             p_user_id            : The user requesting the unlock commercial
-- COMMENT   : This method will take care of commercially unlocking the
--             RFQ. It will re-rank the bids after excluding the non-shortlisted
--             bids.
--========================================================================
PROCEDURE update_auction_info_tech_short ( -- {
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_msg OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  p_user_id IN NUMBER
)
IS

l_module_name VARCHAR2(40) := 'update_auction_info_tech_short';
l_reranking_required VARCHAR2(1) := 'Y';

v_rank_indicator PON_AUCTION_HEADERS_ALL.RANK_INDICATOR%TYPE;
v_bid_ranking PON_AUCTION_HEADERS_ALL.BID_RANKING%TYPE;
v_max_internal_line_num PON_AUCTION_HEADERS_ALL.MAX_INTERNAL_LINE_NUM%TYPE;
v_bid_number PON_BID_HEADERS.BID_NUMBER%TYPE;

v_batch_size NUMBER;
v_batching_required BOOLEAN;

BEGIN

  x_result := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Entered procedure with p_auction_header_id = ' ||
                   p_auction_header_id || ', p_user_id = ' ||
                   p_user_id);
  END IF; --}

  -- Check if there is any bid that has been removed from the shortlist
  BEGIN --{

    SELECT
      bid_number
    INTO
      v_bid_number
    FROM
      pon_bid_headers
    WHERE
      auction_header_id = p_auction_header_id
      AND nvl (shortlist_flag, 'Y') = 'N'
      AND bid_status = 'ACTIVE'
      AND ROWNUM = 1;

    l_reranking_required := 'Y';

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'Found a bid that was not shortlisted.');
    END IF; --}

    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_reranking_required := 'N';

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || l_module_name,
          message  => 'Could not find a bid that was not shortlisted.');
      END IF; --}

  END; --}

  -- Take lock on auction headers all
  SELECT
    rank_indicator,
    bid_ranking,
    max_internal_line_num
  INTO
    v_rank_indicator,
    v_bid_ranking,
    v_max_internal_line_num
  FROM
    pon_auction_headers_all
  WHERE
    auction_header_id = p_auction_header_id
  FOR
    UPDATE OF close_bidding_date;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'rank_indicator = ' || v_rank_indicator ||
                  ', bid_ranking = ' || v_bid_ranking ||
                  ', max_internal_line_num = ' || v_max_internal_line_num);
  END IF; --}

  -- Copy over the shortlist flag into technical_short_flag in pon_bid_headers
  UPDATE
    pon_bid_headers pbh
  SET
    pbh.last_update_date = sysdate,
    pbh.last_updated_by = fnd_global.user_id,
    pbh.technical_shortlist_flag = decode (pbh.bid_status, 'ACTIVE', nvl (pbh.shortlist_flag, 'Y'), 'N')
  WHERE
    pbh.auction_header_id = p_auction_header_id;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Done with updating pon_bid_headers.');
  END IF; --}

  --While commercial unlocking the 2 part RFQ, reset the scores to 'not entered'
  -- so that user will enter scores for commercial stage.
  UPDATE pon_team_member_bid_scores
  SET SCORE_STATUS = 'NA'
  WHERE
  SCORE_STATUS = 'SUBMIT'
  AND auction_header_id = p_auction_header_id;

  -- Re-ranking is required only if we have atleast one non-shortlisted bid
  -- in this RFQ.
  IF (l_reranking_required = 'Y') THEN -- {

    -- for batching, we need to find out the max line number of
    -- this negotiation
    v_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
    v_batching_required := (v_max_internal_line_num > v_batch_size);

    IF (v_batching_required) THEN -- {
      updt_tech_short_lines_batched (x_result, x_error_code, x_error_msg,
        p_auction_header_id, v_bid_ranking, v_rank_indicator,
        v_max_internal_line_num, v_batch_size);
    ELSE
      updt_tech_short_lines (x_result, x_error_code, x_error_msg,
        p_auction_header_id, v_bid_ranking, v_rank_indicator, 1, v_max_internal_line_num);
    END IF; -- }

  END IF; -- }

  -- Unlock the commercial part of the auction
  UPDATE
    pon_auction_headers_all paha
  SET
    paha.last_update_date = sysdate,
    paha.last_updated_by = fnd_global.user_id,
    paha.scoring_lock_date = null,
    paha.scoring_lock_tp_contact_id = p_user_id,
    paha.sealed_auction_status = 'UNLOCKED',
    paha.sealed_actual_unlock_date = sysdate,
    paha.sealed_unlock_tp_contact_id = p_user_id
  WHERE
    paha.auction_header_id = p_auction_header_id;

  --Bug 14348208 make the draft bids of technical stage as Archived
  UPDATE pon_bid_headers bh
  SET bh.bid_status='ARCHIVED_DRAFT'
  WHERE
  bh.auction_header_id = p_auction_header_id
  AND (EXISTS (select 1 FROM pon_auction_headers_all ah WHERE ah.auction_header_id = bh.auction_header_id
                                                          AND  Nvl(ah.two_part_flag, 'N') = 'Y'
                                                          AND Nvl(ah.technical_evaluation_status, 'N') ='COMPLETED')
          AND Nvl(bh.surrog_bid_flag, 'N') = 'Y'
          AND bh.bid_status = 'DRAFT'
            AND bh.submit_stage IS NULL);


  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Leaving procedure');
  END IF; --}

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_msg := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' || x_error_code ||
                   ', error_message = ' || x_error_msg);
    END IF;

END update_auction_info_tech_short; --}

END  PON_AUCTION_HEADERS_PKG;

/
