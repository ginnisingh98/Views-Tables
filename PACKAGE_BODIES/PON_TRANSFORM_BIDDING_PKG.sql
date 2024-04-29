--------------------------------------------------------
--  DDL for Package Body PON_TRANSFORM_BIDDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_TRANSFORM_BIDDING_PKG" AS
-- $Header: PONTFBDB.pls 120.4 2006/08/02 10:46:35 rpatel noship $
--

--
-- BID TOTAL ERROR CODES
--
BID_TOTAL_WARNING NUMBER := -1;
--
--

-- LOGGING FEATURE
--
-- global variables used for logging
--
g_fnd_debug     CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_module_prefix CONSTANT VARCHAR2(35) := 'pon.plsql.transformBiddingPkg.';
--
--private helper procedure for logging
PROCEDURE print_log(p_module   IN    VARCHAR2,
                   p_message  IN    VARCHAR2)
IS
BEGIN
   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string(log_level => FND_LOG.level_statement,
                        module  =>  g_module_prefix || p_module,
                        message  => p_message);
      END IF;
   END IF;
END;


-- ------------------------------------------------------------------------
-- find_user_site
--
-- given auction_header_id, tpid, tpcid, this will find the site
-- to use for transformation.
--
-- question: what if this supplier was not invited to the negotiation?
-- he will not have any price factor values to use...
-- ------------------------------------------------------------------------

FUNCTION find_user_site
	(p_auction_header_id 	IN pon_bid_headers.auction_header_id%TYPE,
	 p_tpid 				IN pon_bid_headers.trading_partner_id%TYPE,
	 p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE)
	RETURN NUMBER
IS
	v_site_id				pon_bid_headers.vendor_site_id%TYPE;
	v_num_invited_sites		NUMBER;
BEGIN

	SELECT vendor_site_id
	INTO v_site_id
	FROM (SELECT vendor_site_id
		  FROM pon_bidding_parties
		  WHERE auction_header_id = p_auction_header_id
			AND trading_partner_id = p_tpid
		  ORDER BY vendor_site_code)
	WHERE rownum=1;

	RETURN v_site_id;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN NULL;

END find_user_site;


-- -----------------------------------------------------
-- check_est_qty_on_all_bid_lines
--
-- Indirectly used to check whether bid total can be computed for blanket negotiations
--
-- Estimated quantity needs to be set for all lines that were bidded on to
-- compute the bid total
-- ----------------------------------------------------------------

FUNCTION check_est_qty_on_all_bid_lines
               (p_auction_header_id IN NUMBER,
                p_bid_number        IN NUMBER) RETURN VARCHAR2

IS

  v_has_est_qty_on_all_bid_lines VARCHAR2(1);

BEGIN

  v_has_est_qty_on_all_bid_lines := 'Y';

  SELECT 'N'
  INTO   v_has_est_qty_on_all_bid_lines
  FROM   dual
  WHERE  EXISTS (SELECT null
                 FROM   pon_bid_item_prices pbip,
                        pon_auction_item_prices_all paip
                 WHERE  pbip.auction_header_id = p_auction_header_id AND
                        pbip.bid_number = p_bid_number AND
                        nvl(pbip.has_bid_flag, 'N') = 'Y' AND
                        pbip.auction_header_id = paip.auction_header_id AND
                        pbip.line_number = paip.line_number AND
                        paip.group_type in ('LOT', 'LINE', 'GROUP_LINE') AND
                        paip.order_type_lookup_code <> 'FIXED PRICE' AND
                        paip.quantity is null);

  RETURN v_has_est_qty_on_all_bid_lines;

EXCEPTION

     WHEN NO_DATA_FOUND THEN
             RETURN 'Y';


END check_est_qty_on_all_bid_lines;

-- --------------------------------------------------------------
--
-- calculate_supplier_bid_total
--
-- Calculates the bid total in the buyer's currency for a supplier's view
--
-- The buyer_bid_total can be used when a bid has been submitted for a
-- TRANSFORMED auction
--
-- -------------------------------------------------------------

FUNCTION calculate_supplier_bid_total
             (p_auction_header_id    IN NUMBER,
              p_bid_number           IN NUMBER,
              p_outcome              IN pon_auction_headers_all.contract_type%TYPE,
              p_supplier_view_type   IN pon_auction_headers_all.supplier_view_type%TYPE,
              p_tpid                 IN NUMBER,
              p_site                 IN NUMBER) RETURN NUMBER

IS

  v_bid_total NUMBER;

BEGIN

  IF (p_supplier_view_type = 'TRANSFORMED') THEN

    SELECT sum(decode(paip.order_type_lookup_code, 'FIXED PRICE', 1,
                      decode(p_outcome, 'STANDARD', nvl(pbip.quantity, 0), paip.quantity)) *
               nvl(pbip.price,0)) bid_total
    INTO   v_bid_total
    FROM   pon_bid_item_prices pbip,
           pon_auction_item_prices_all paip
    WHERE  pbip.auction_header_id = p_auction_header_id AND
           pbip.bid_number = p_bid_number AND
           nvl(pbip.has_bid_flag, 'N') = 'Y' AND
           pbip.auction_header_id = paip.auction_header_id AND
           pbip.line_number = paip.line_number AND
           paip.group_type in ('LOT', 'LINE', 'GROUP_LINE');

  ELSE -- UNTRANSFORMED

    SELECT sum(decode(paip.order_type_lookup_code, 'FIXED PRICE', 1,
                      decode(p_outcome, 'STANDARD', nvl(pbip.quantity, 0), paip.quantity)) *
               nvl(untransform_one_price(paip.auction_header_id, paip.line_number, pbip.price,
                                         paip.quantity, p_tpid, p_site),0)) bid_total
    INTO   v_bid_total
    FROM   pon_bid_item_prices pbip,
           pon_auction_item_prices_all paip
    WHERE  pbip.auction_header_id = p_auction_header_id AND
           pbip.bid_number = p_bid_number AND
           nvl(pbip.has_bid_flag, 'N') = 'Y' AND
           pbip.auction_header_id = paip.auction_header_id AND
           pbip.line_number = paip.line_number AND
           paip.group_type in ('LOT', 'LINE', 'GROUP_LINE');

  END IF;

  RETURN v_bid_total;

END calculate_supplier_bid_total;

--------------------------------------------
--
-- returns the bid total in the buyer's currency
--
-------------------------------------------


FUNCTION calculate_bid_total
              (p_auction_header_id IN NUMBER,
               p_bid_number        IN NUMBER,
               p_tpid              IN NUMBER,
               p_site              IN NUMBER) RETURN NUMBER

IS

  v_buyer_tpid                     NUMBER;
  v_outcome                        pon_auction_headers_all.contract_type%TYPE;
  v_supplier_view_type             pon_auction_headers_all.supplier_view_type%TYPE;
  v_bid_status                     pon_bid_headers.bid_status%TYPE;
  v_buyer_bid_total                NUMBER;
  v_has_est_qty_on_all_bid_lines   VARCHAR2(1);
  v_doctype_group_name        VARCHAR2(80);

BEGIN

  IF (p_bid_number is NULL) THEN
    RETURN NULL;
  END IF;

  SELECT auh.trading_partner_id, auh.contract_type, auh.supplier_view_type,dt.doctype_group_name
    INTO v_buyer_tpid, v_outcome, v_supplier_view_type,v_doctype_group_name
    FROM pon_auction_headers_all auh, pon_auc_doctypes dt
   WHERE auction_header_id = p_auction_header_id
     AND auh.doctype_id = dt.doctype_id;


  SELECT bid_status, buyer_bid_total
  INTO   v_bid_status, v_buyer_bid_total
  FROM   pon_bid_headers
  WHERE  auction_header_id = p_auction_header_id AND
         bid_number = p_bid_number;

  -- Check to see if we can use buyer_bid_total
  -- 1) The buyer_bid_total column is set at publish time...
  --    and thus is only useful after publish time
  -- 2) buyer_bid_total is the bid's total in the buyer's view
  -- 3) A buyer and supplier will see the same total whe the supplier view is TRANSFORMED
  -- 4) A buyer can only see the total for non-draft bids

  IF ( (p_tpid = v_buyer_tpid) OR
       (v_bid_status <> 'DRAFT' AND v_supplier_view_type = 'TRANSFORMED') ) THEN

      IF (v_buyer_bid_total is NULL) THEN
        RETURN BID_TOTAL_WARNING;
      ELSE
        RETURN v_buyer_bid_total;
      END IF;

  END IF;


  IF (v_bid_status = 'DRAFT') THEN

    IF ((v_doctype_group_name = 'REQUEST_FOR_INFORMATION') OR (v_outcome = 'BLANKET' OR v_outcome = 'CONTRACT')) THEN

      v_has_est_qty_on_all_bid_lines := check_est_qty_on_all_bid_lines(p_auction_header_id, p_bid_number);

      IF (v_has_est_qty_on_all_bid_lines = 'N') THEN
        RETURN BID_TOTAL_WARNING;
      END IF;

    END IF;


    RETURN calculate_supplier_bid_total(p_auction_header_id,
                                        p_bid_number,
                                        v_outcome,
                                        v_supplier_view_type,
                                        p_tpid,
                                        p_site);

  ELSE -- Submitted bid in an UNTRANSFORMED auction

    IF (v_buyer_bid_total is NULL) THEN
      RETURN BID_TOTAL_WARNING;
    ELSE
      RETURN calculate_supplier_bid_total(p_auction_header_id,
                                          p_bid_number,
                                          v_outcome,
                                          v_supplier_view_type,
                                          p_tpid,
                                          p_site);
    END IF;

  END IF;

END calculate_bid_total;

-- ------------------------------------------------------------------------
-- calculate_price
--
-- called from the VO sql query itself, this will takes one price
-- and transforms it if necessary.
-- ------------------------------------------------------------------------
FUNCTION calculate_price
	(p_auction_header_id 	IN NUMBER,
	 p_line_number			IN NUMBER,
	 p_price				IN NUMBER,
	 p_quantity				IN NUMBER,
	 p_tpid 				IN NUMBER,
	 p_site					IN NUMBER)
	RETURN NUMBER
IS
BEGIN
	return calculate_price(p_auction_header_id, p_line_number, p_price,
						   p_quantity, p_tpid, -1, p_site, null);
END calculate_price;


FUNCTION calculate_price
	(p_auction_header_id 	IN NUMBER,
	 p_line_number			IN NUMBER,
	 p_price				IN NUMBER,
	 p_quantity				IN NUMBER,
	 p_tpid 				IN NUMBER,
	 p_tpcid				IN NUMBER,
	 p_site					IN NUMBER)
	RETURN NUMBER
IS
BEGIN
  return calculate_price(p_auction_header_id, p_line_number, p_price,
                         p_quantity, p_tpid, p_tpcid, p_site, null);
END calculate_price;


FUNCTION calculate_price
	(p_auction_header_id 	IN NUMBER,
	 p_line_number			IN NUMBER,
	 p_price				IN NUMBER,
	 p_quantity				IN NUMBER,
	 p_tpid 				IN NUMBER,
	 p_tpcid				IN NUMBER,
	 p_site					IN NUMBER,
         p_requested_supplier_id                IN NUMBER)
	RETURN NUMBER
IS
	v_supplier_view_type	pon_auction_headers_all.supplier_view_type%TYPE;
	v_buyer_tpid			pon_auction_headers_all.trading_partner_id %TYPE;

BEGIN

	-- QUESTION: do I have to worry about the case where the following query
	-- returns NO rows??

	SELECT supplier_view_type, trading_partner_id
	INTO v_supplier_view_type, v_buyer_tpid
	FROM pon_auction_headers_all
	WHERE auction_header_id = p_auction_header_id;

	IF v_supplier_view_type = 'TRANSFORMED' OR
		v_buyer_tpid = p_tpid OR
		p_site IS NULL THEN
		RETURN p_price;

	ELSE
		RETURN untransform_one_price(p_auction_header_id, p_line_number,
									p_price, p_quantity, p_tpid, p_site, p_requested_supplier_id);
	END IF;

END calculate_price;


-- ------------------------------------------------------------------------
-- untransform_one_price
--
-- this utility function just transforms one price
-- ------------------------------------------------------------------------

FUNCTION untransform_one_price
	(p_auction_header_id 	IN NUMBER,
	 p_line_number			IN NUMBER,
	 p_price				IN NUMBER,
	 p_quantity 			IN NUMBER,
	 p_tpid 				IN NUMBER,
	 p_site_id				IN NUMBER)
	RETURN NUMBER
IS
BEGIN
  return untransform_one_price(p_auction_header_id, p_line_number, p_price,
                               p_quantity, p_tpid, p_site_id, null);
END untransform_one_price;


FUNCTION untransform_one_price
	(p_auction_header_id 	IN NUMBER,
	 p_line_number			IN NUMBER,
	 p_price				IN NUMBER,
	 p_quantity 			IN NUMBER,
	 p_tpid 				IN NUMBER,
	 p_site_id				IN NUMBER,
         p_requested_supplier_id                IN NUMBER)
	RETURN NUMBER
IS
	v_percentage			pon_pf_supplier_formula.percentage%TYPE;
	v_unit					pon_pf_supplier_formula.unit_price%TYPE;
	v_amount				pon_pf_supplier_formula.fixed_amount%TYPE;
	v_quantity				NUMBER;

BEGIN

	SELECT unit_price, fixed_amount, percentage
	INTO v_unit, v_amount, v_percentage
	FROM pon_pf_supplier_formula
	WHERE auction_header_id = p_auction_header_id
		AND line_number = p_line_number
		AND ((trading_partner_id = p_tpid AND
                      vendor_site_id = p_site_id)
                     OR requested_supplier_id = p_requested_supplier_id);

	v_quantity := p_quantity;
	IF v_quantity IS NULL OR
		v_quantity = 0 THEN
		v_quantity := 1;
	END IF;

	RETURN ((p_price - v_unit - v_amount/v_quantity) / v_percentage);

EXCEPTION

	WHEN NO_DATA_FOUND THEN
		RETURN p_price;

END untransform_one_price;
--
--
-- ------------------------------------------------------------------------
-- calculate_quote_amount
-- In case of Regular line, lot, group line, lot line:
-- calculated as sum of line totals, which are quantity * bid price for each line
-- In case of GROUP:
-- calculated as sum of all group line totals,
-- which are group line quantity * group line bid price for each group lineline
-- ------------------------------------------------------------------------

FUNCTION calculate_quote_amount
	(p_auction_header_id 	IN pon_bid_headers.auction_header_id%TYPE,
 	 p_line_number			IN pon_auction_item_prices_all.line_number%TYPE,
	 p_bid_number			IN pon_bid_headers.bid_number%TYPE,
	 p_supplier_view_type	IN pon_auction_headers_all.supplier_view_type%TYPE,
	 p_buyer_tpid			IN pon_auction_headers_all.trading_partner_id%TYPE,
	 p_tpid 				IN pon_bid_headers.trading_partner_id%TYPE,
	 p_site					IN pon_bid_headers.vendor_site_id%TYPE)
	RETURN NUMBER
IS
    v_quote_amount             NUMBER;
    v_group_type                    pon_auction_item_prices_all.group_type%TYPE;
BEGIN
     SELECT group_type
	 INTO v_group_type
     FROM pon_auction_item_prices_all
     WHERE auction_header_id = p_auction_header_id
           AND line_number = p_line_number;

	-- Transformed View: no need to reverse-transform prices
	IF (p_supplier_view_type = 'TRANSFORMED' OR
		p_buyer_tpid = p_tpid OR
		p_site IS NULL) THEN


           SELECT DECODE (al.group_type, 'GROUP', bl.group_amount,
                      nvl(bl.quantity, decode(al.ORDER_TYPE_LOOKUP_CODE, 'FIXED PRICE', 1, al.quantity)) * bl.price)
           INTO v_quote_amount
           FROM pon_bid_item_prices bl, pon_auction_item_prices_all al
           WHERE bl.bid_number = p_bid_number
           AND bl.line_number = p_line_number
           AND bl.auction_header_id = al.auction_header_id
           AND bl.line_number = al.line_number;

	-- Untransformed View: we must reverse-transform prices
	ELSE

	   -- Untransformed View and GROUP Line Type
	   IF (v_group_type = 'GROUP') THEN
              -- Supplier does not see group amount in untransformed view
              v_quote_amount := NULL;
           -- Untransformed View and LOT or LINE Line Type
           ELSE
			SELECT
                         nvl(bl.quantity, decode(al.ORDER_TYPE_LOOKUP_CODE, 'FIXED PRICE', 1, al.quantity))
		       * nvl(PON_TRANSFORM_BIDDING_PKG.untransform_one_price(p_auction_header_id,
bl.line_number, bl.price, al.quantity, p_tpid, p_site), 0)
        		INTO v_quote_amount
        		FROM pon_bid_item_prices bl, pon_auction_item_prices_all al
        		WHERE bl.bid_number = p_bid_number
        		AND bl.line_number = p_line_number
        		AND al.auction_header_id = bl.auction_header_id
			AND al.line_number = bl.line_number;

	   END IF;
     END IF;

     RETURN v_quote_amount;

END calculate_quote_amount;
--
--
-- -----------------------------------------------------------------------
-- has_pf_values_defined
--
-- given a buyer price factor, determines if values have been entered for this trading partner/site
--
-- ----------------------------------------------------------------------

FUNCTION has_pf_values_defined
         (p_auction_header_id    IN NUMBER,
          p_line_number          IN NUMBER,
          p_pf_seq_number        IN NUMBER,
          p_trading_partner_id   IN NUMBER,
          p_vendor_site_id       IN NUMBER) RETURN VARCHAR2
IS
BEGIN
  return  has_pf_values_defined(p_auction_header_id, p_line_number,
                p_pf_seq_number, p_trading_partner_id, p_vendor_site_id, null);
END has_pf_values_defined;


FUNCTION has_pf_values_defined
         (p_auction_header_id    IN NUMBER,
          p_line_number          IN NUMBER,
          p_pf_seq_number        IN NUMBER,
          p_trading_partner_id   IN NUMBER,
          p_vendor_site_id       IN NUMBER,
          p_requested_supplier_id IN NUMBER) RETURN VARCHAR2
IS
   v_supplier_seq_number NUMBER;
   v_has_pf_values_defined VARCHAR2(1);

BEGIN

   select sequence
   into   v_supplier_seq_number
   from   pon_bidding_parties
   where  auction_header_id = p_auction_header_id and
          ((trading_partner_id = p_trading_partner_id and
            vendor_site_id = p_vendor_site_id) OR
           requested_supplier_id = p_requested_supplier_id);

   select 'Y'
   into   v_has_pf_values_defined
   from   pon_pf_supplier_values
   where  auction_header_id = p_auction_header_id and
          line_number = p_line_number and
          pf_seq_number = p_pf_seq_number and
          supplier_seq_number = v_supplier_seq_number;


   RETURN v_has_pf_values_defined;

EXCEPTION

        WHEN NO_DATA_FOUND THEN
                RETURN 'N';

END has_pf_values_defined;
--
--
PROCEDURE GET_DISPLAY_CURRENCY_INFO (p_auction_header_id            IN  NUMBER,
                                     p_trading_partner_id           IN  NUMBER,
                                     p_vendor_site_id               IN  NUMBER,
                                     p_trading_partner_contact_id   IN  NUMBER,
                                     p_is_buyer                     IN  VARCHAR2,
                                     x_currency                     OUT NOCOPY VARCHAR2,
                                     x_rate                         OUT NOCOPY NUMBER,
                                     x_precision                    OUT NOCOPY NUMBER,
                                     x_currency_precision           OUT NOCOPY NUMBER,
                                     x_site_id                      OUT NOCOPY NUMBER,
                                     x_bid_number                   OUT NOCOPY NUMBER,
                                     x_bid_status                   OUT NOCOPY VARCHAR2) IS

BEGIN


  --
  -- Default currency information from negotiation
  --


  select ah.currency_code, 1 rate, ah.number_price_decimals, fc.precision, -1 site_id, -1 bid_number, null
  into   x_currency, x_rate, x_precision, x_currency_precision, x_site_id, x_bid_number, x_bid_status
  from   pon_auction_headers_all ah,
         fnd_currencies fc
  where  ah.auction_header_id = p_auction_header_id and
         ah.currency_code = fc.currency_code;


  --
  -- For suppliers, check if we can get currency information from a bid (query goes across all amendments)
  --


  IF (p_is_buyer = 'N') THEN


    BEGIN

       select vendor_site_id, bid_currency_code, rate, number_price_decimals, precision
       into   x_site_id, x_currency, x_rate, x_precision, x_currency_precision
       from (select   bh.vendor_site_id, bh.bid_currency_code, bh.rate, bh.number_price_decimals, fc.precision
             from     pon_bid_headers bh,
                      pon_auction_headers_all ah,
                      fnd_currencies fc
             where    ah.auction_header_id_orig_amend = (select auction_header_id_orig_amend
                                                         from   pon_auction_headers_all
                                                         where  auction_header_id = p_auction_header_id) and
                      bh.auction_header_id = ah.auction_header_id and
                      bh.trading_partner_id = p_trading_partner_id and
                      bh.vendor_site_id like nvl(to_char(p_vendor_site_id), '%') and
                      bh.trading_partner_contact_id = p_trading_partner_contact_id and
                      bh.bid_currency_code = fc.currency_code
             order by ah.amendment_number desc,
                      decode(bh.bid_status, 'DRAFT', 9, 'ACTIVE', 8, 'RESUBMISSION' , 7, 'DISQUALIFIED', 6, 'ARCHIVED', 4, 'ARCHIVED_DRAFT', 3) desc,
                      bh.publish_date desc)
       where rownum = 1;

    EXCEPTION

            --
            -- If there is no bid for a supplier, the negotiation's currency will be used
            -- Also, we will select the default site
            --
            WHEN NO_DATA_FOUND THEN

                if (p_vendor_site_id is null) then -- look in invitees table, if there is a site
                  x_site_id := PON_TRANSFORM_BIDDING_PKG.FIND_USER_SITE(p_auction_header_id, p_trading_partner_id, p_trading_partner_contact_id);

                else
                  x_site_id := p_vendor_site_id;

                end if;

                if (x_site_id is null) then -- if still null (can happen when supplier was not invited)
                  x_site_id := -1;
                 end if;

    END;


    BEGIN

       select bid_number, bid_status
       into   x_bid_number, x_bid_status
       from (select   bh.bid_number, bh.bid_status
             from     pon_bid_headers bh,
                      pon_auction_headers_all ah
             where    ah.auction_header_id_orig_amend = (select auction_header_id_orig_amend
                                                         from   pon_auction_headers_all
                                                         where  auction_header_id = p_auction_header_id) and
                      bh.auction_header_id = ah.auction_header_id and
                      bh.trading_partner_id = p_trading_partner_id and
                      bh.vendor_site_id = x_site_id
             order by ah.amendment_number desc,
                      decode(bh.bid_status, 'DRAFT', 9, 'ACTIVE', 8, 'RESUBMISSION' , 7, 'DISQUALIFIED', 6, 'ARCHIVED', 4, 'ARCHIVED_DRAFT', 3) desc,
                      bh.publish_date desc)
       where rownum = 1;

    EXCEPTION

            WHEN NO_DATA_FOUND THEN
                x_bid_number := -1;
                x_bid_status := null;
     END;



  END IF;

END GET_DISPLAY_CURRENCY_INFO;
--
--
--
END  PON_TRANSFORM_BIDDING_PKG;

/
