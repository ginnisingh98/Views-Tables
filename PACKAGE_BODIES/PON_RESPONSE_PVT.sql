--------------------------------------------------------
--  DDL for Package Body PON_RESPONSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_RESPONSE_PVT" AS
-- $Header: PONRESPB.pls 120.34.12010000.10 2014/05/30 11:43:14 spapana ship $


g_return_success      CONSTANT NUMBER := 0;
g_return_error        CONSTANT NUMBER := 1;
g_return_warning      CONSTANT NUMBER := 2;

g_price_breaks CONSTANT VARCHAR2(30) := 'PRICE_BREAKS';
g_quantity_based CONSTANT VARCHAR2(30) := 'QUANTITY_BASED';

--
-- LOGGING FEATURE
--
-- global variables used for logging
--
g_fnd_debug     CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name      CONSTANT VARCHAR2(50) := 'pon_response_pvt';
g_module_prefix CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';
--
--private helper procedure for logging
PROCEDURE print_log(p_module   IN    VARCHAR2,
                   p_message  IN    VARCHAR2)
IS
BEGIN

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
  FND_LOG.string(log_level => FND_LOG.level_statement,
                 module  =>  g_module_prefix || p_module,
                 message  => p_message);
  END IF;
END;



-- -------------------------------------------------------------------------
-- get_header_close_bidding_date
-- get_line_close_bidding_date
--
-- called from BidHeaderVO query, this function will take bid_number and
-- auction_header_id and return the adjusted close bidding date, which
-- takes into account the pause duration in case the auction was
-- paused
-- -------------------------------------------------------------------------

FUNCTION get_header_close_bidding_date
         (p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE)
         RETURN DATE
IS
   v_auc_close_bidding_date  pon_auction_headers_all.close_bidding_date%TYPE;
   v_pause_date              pon_auction_headers_all.last_pause_date%TYPE;
   v_is_paused               pon_auction_headers_all.is_paused%TYPE;

   l_api_name CONSTANT VARCHAR2(30) := 'get_header_close_bidding_date';

BEGIN

   SELECT a.close_bidding_date, a.last_pause_date, a.is_paused
   INTO v_auc_close_bidding_date, v_pause_date, v_is_paused
   FROM pon_auction_headers_all a
   WHERE a.auction_header_id = p_auction_header_id;

   IF v_is_paused = 'Y' THEN
      RETURN (sysdate + (v_auc_close_bidding_date - v_pause_date));
   ELSE
      RETURN v_auc_close_bidding_date;
   END IF;

END get_header_close_bidding_date;

FUNCTION get_line_close_bidding_date
         (p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
          p_line_number       IN pon_bid_item_prices.line_number%TYPE,
          p_is_paused         IN pon_auction_headers_all.is_paused%TYPE,
          p_pause_date        IN pon_auction_headers_all.last_pause_date%TYPE)
	     RETURN DATE
IS
   v_line_close_bidding_date  pon_auction_item_prices_all.close_bidding_date%TYPE;
   l_api_name CONSTANT VARCHAR2(30) := 'get_line_close_bidding_date';

BEGIN

   SELECT a.close_bidding_date
   INTO v_line_close_bidding_date
   FROM pon_auction_item_prices_all a
   WHERE a.auction_header_id = p_auction_header_id
     AND a.line_number = p_line_number;

   IF p_is_paused = 'Y' AND v_line_close_bidding_date > p_pause_date THEN
      RETURN (sysdate + (v_line_close_bidding_date - p_pause_date));
   ELSE
      RETURN v_line_close_bidding_date;
   END IF;

END get_line_close_bidding_date;



-- -------------------------------------------------------------------------
-- calculate_group_amounts
--
-- called from BidItemPricesEO, this function will calculate the group amount.
-- we have two variations of this procedure:
-- 1) calculate group amount for the given line
-- 2) calculate group amount for all lines in the given bid
-- -------------------------------------------------------------------------
PROCEDURE calculate_group_amounts(p_bid_number IN pon_bid_item_prices.bid_number%TYPE,
                                  p_is_supplier IN VARCHAR)
IS
BEGIN
	calculate_group_amounts(p_bid_number, p_is_supplier, 'Y', -1);
END calculate_group_amounts;

PROCEDURE calculate_group_amounts(p_bid_number IN pon_bid_item_prices.bid_number%TYPE,
                                  p_is_supplier IN VARCHAR,
                                  p_do_all_lines IN VARCHAR,
                                  p_batch_id IN pon_bid_item_prices.batch_id%TYPE)
IS

   l_api_name CONSTANT VARCHAR2(30) := 'calculate_group_amounts';
   v_supplier_view_type pon_auction_headers_all.supplier_view_type%TYPE;
   v_contract_type pon_auction_headers_all.contract_type%TYPE;
   v_doctype VARCHAR2(7);

BEGIN

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, p_bid_number || ' - BEGIN calculate_group_amounts');
    print_log(l_api_name, p_bid_number || ' - p_is_supplier='||p_is_supplier);
    print_log(l_api_name, p_bid_number || ' - p_do_all_lines='||p_do_all_lines);
    print_log(l_api_name, p_bid_number || ' - p_batch_id='||p_batch_id);
  END IF;

  -- select some variables we need
  SELECT  paha.supplier_view_type,
          paha.contract_type,
          DECODE(paha.doctype_id, 21, 'RFI', 5, 'RFQ', 1, 'AUCTION') document_type
  INTO  v_supplier_view_type,
        v_contract_type,
        v_doctype
  FROM pon_bid_headers pbh,
       pon_auction_headers_all paha
  WHERE pbh.bid_number = p_bid_number
    AND paha.auction_header_id = pbh.auction_header_id;

  -- if the negotiation is an RFI or is UNtransformed, then
  -- we do not allow group amounts to be calculated.
  -- simply return.
  IF (v_supplier_view_type = 'UNTRANSFORMED' OR
      v_doctype = 'RFI') THEN
    RETURN;
  END IF;

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, p_bid_number || ' - v_supplier_view_type=' || v_supplier_view_type);
    print_log(l_api_name, p_bid_number || ' - v_doctype=' || v_doctype);
    print_log(l_api_name, p_bid_number || ' - v_contract_type=' || v_contract_type);
  END IF;

  UPDATE pon_bid_item_prices p1
  SET p1.group_amount =
      (SELECT SUM(decode(p_is_supplier,
                         'Y', p2.bid_currency_price,
                         p2.price) *
                  decode(a1.order_type_lookup_code,
                         'FIXED PRICE', 1,
                         decode(v_contract_type,
                                'STANDARD', p2.quantity,
                                nvl(p2.quantity, a1.quantity))))
       FROM pon_bid_item_prices p2,
            pon_auction_item_prices_all a1
       WHERE p2.bid_number = p_bid_number
         AND a1.auction_header_id = p2.auction_header_id
         AND p2.line_number = a1.line_number
         AND a1.parent_line_number = p1.line_number)
  WHERE p1.bid_number = p_bid_number
    AND (p_do_all_lines = 'Y'
        OR p1.batch_id = p_batch_id)
    AND (SELECT a2.group_type
         FROM pon_auction_item_prices_all a2
         WHERE a2.auction_header_id = p1.auction_header_id
           AND a2.line_number = p1.line_number) = 'GROUP';

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, p_bid_number || ' - END calculate_group_amounts');
  END IF;

END calculate_group_amounts;

PROCEDURE calculate_group_amounts(p_bid_number IN pon_bid_item_prices.bid_number%TYPE,
                                  p_line_number IN pon_bid_item_prices.line_number%TYPE,
                                  p_is_supplier IN VARCHAR,
                                  p_group_amount OUT NOCOPY NUMBER)
IS

   l_api_name CONSTANT VARCHAR2(50) := 'calculate_group_amounts (single-line)';
   v_supplier_view_type pon_auction_headers_all.supplier_view_type%TYPE;
   v_contract_type pon_auction_headers_all.contract_type%TYPE;
   v_doctype VARCHAR2(7);

BEGIN

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, p_bid_number || ' - BEGIN calculate_group_amounts');
    print_log(l_api_name, p_bid_number || ' - p_line_number='||p_line_number);
    print_log(l_api_name, p_bid_number || ' - p_is_supplier='||p_is_supplier);
  END IF;

  -- select some variables we need
  SELECT  paha.supplier_view_type,
          paha.contract_type,
          DECODE(paha.doctype_id, 21, 'RFI', 5, 'RFQ', 1, 'AUCTION')
  INTO  v_supplier_view_type,
        v_contract_type,
        v_doctype
  FROM pon_bid_headers pbh,
       pon_auction_headers_all paha
  WHERE pbh.bid_number = p_bid_number
    AND paha.auction_header_id = pbh.auction_header_id;

  -- if the negotiation is an RFI or is UNtransformed, then
  -- we do not allow group amounts to be calculated.
  -- simply return.
  IF (v_supplier_view_type = 'UNTRANSFORMED' OR
      v_doctype = 'RFI') THEN
    RETURN;
  END IF;

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, p_bid_number || ' - v_supplier_view_type=' || v_supplier_view_type);
    print_log(l_api_name, p_bid_number || ' - v_doctype=' || v_doctype);
    print_log(l_api_name, p_bid_number || ' - v_contract_type=' || v_contract_type);
  END IF;




  SELECT SUM(decode(p_is_supplier,
                    'Y', group_line.bid_currency_price,
                    group_line.price) *
             decode(auc_line.order_type_lookup_code,
                    'FIXED PRICE', 1,
                    decode(v_contract_type,
                           'STANDARD', group_line.quantity,
                           nvl(group_line.quantity, auc_line.quantity))))
  INTO p_group_amount
  FROM pon_bid_item_prices groups,
       pon_bid_item_prices group_line,
       pon_auction_item_prices_all auc_line
  WHERE groups.bid_number = p_bid_number
    AND group_line.bid_number = groups.bid_number
    AND groups.line_number = p_line_number
    AND group_line.auction_header_id = auc_line.auction_header_id
    AND group_line.line_number = auc_line.line_number
    AND auc_line.parent_line_number = groups.line_number;

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, p_bid_number || ' - END calculate_group_amounts');
  END IF;

END calculate_group_amounts;

PROCEDURE calculate_group_amounts_auto(p_bid_number IN pon_bid_item_prices.bid_number%TYPE,
                                       p_is_supplier IN VARCHAR)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_name CONSTANT VARCHAR2(30) := 'calculate_group_amounts_auto';

BEGIN

    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - BEGIN calculate_group_amount AUTONOMOUS');
    END IF;

    calculate_group_amounts(p_bid_number, p_is_supplier);
    commit;

    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - calculate_group_amount: committed!');
      print_log(l_api_name, p_bid_number || ' - END calculate_group_amount AUTONOMOUS');
    END IF;
END calculate_group_amounts_auto;


-- -------------------------------------------------------------------------
-- change_bid_by_percentage
--
-- called from ResponseAMImpl's handler for power bidding
-- (changeBidByPercentage), this method will perform power bidding on the
-- specified bid by the specified percentage.
-- -------------------------------------------------------------------------

PROCEDURE change_bid_by_percentage
          (p_bid_number          IN pon_bid_item_prices.bid_number%TYPE,
           p_power_percentage    IN NUMBER,
           p_powerbidlosinglines IN VARCHAR2,
           p_previous_bid_number IN pon_bid_headers.old_bid_number%TYPE)
IS

v_precision NUMBER;
v_rate NUMBER;
v_is_paused VARCHAR2(1);
v_paused_date DATE;
v_surrog_bid_flag VARCHAR2(1);
v_auction_header_id pon_auction_headers_all.auction_header_id%TYPE;
v_is_blanket VARCHAR2(1);
v_source_bid pon_bid_headers.old_bid_number%TYPE;
v_price_tiers_indicator PON_AUCTION_HEADERS_ALL.price_tiers_indicator%TYPE;

v_batch_start NUMBER;
v_batch_end NUMBER;
v_batch_size NUMBER;
v_max_line_number NUMBER;

l_api_name CONSTANT VARCHAR2(30) := 'change_bid_by_percentage';

BEGIN

  SELECT number_price_decimals, rate, auction_header_id, surrog_bid_flag, old_bid_number
  INTO v_precision, v_rate, v_auction_header_id, v_surrog_bid_flag, v_source_bid
  FROM pon_bid_headers
  WHERE bid_number=p_bid_number;

  SELECT a.is_paused, a.last_pause_date, a.max_internal_line_num,
         decode(a.contract_type, 'BLANKET', 'Y', 'CONTRACT', 'Y', 'N'),
         a.price_tiers_indicator
  INTO v_is_paused, v_paused_date, v_max_line_number,
       v_is_blanket,v_price_tiers_indicator
  FROM pon_auction_headers_all a
  WHERE a.auction_header_id = v_auction_header_id;

  v_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
  v_batch_start := 1;
  IF (v_max_line_number < v_batch_size) THEN
    v_batch_end := v_max_line_number;
  ELSE
    v_batch_end := v_batch_size;
  END IF;

  WHILE (v_batch_start <= v_max_line_number) LOOP

    UPDATE pon_bid_item_prices pbip
    SET pbip.bid_currency_price = round(pbip.bid_currency_price * (1 - p_power_percentage / 100), v_precision),
        pbip.bid_currency_unit_price = round(pbip.bid_currency_price * (1 - p_power_percentage / 100), v_precision),
        pbip.bid_currency_trans_price = round(pbip.bid_currency_price * (1 - p_power_percentage / 100), v_precision),
        pbip.price = (round(pbip.bid_currency_price * (1 - p_power_percentage / 100), v_precision)) / v_rate,
        pbip.unit_price =  (round(pbip.bid_currency_price * (1 - p_power_percentage / 100), v_precision)) / v_rate
    WHERE pbip.bid_number = p_bid_number
      AND (get_line_close_bidding_date(pbip.auction_header_id, pbip.line_number, v_is_paused, v_paused_date)  > sysdate
           OR v_surrog_bid_flag = 'Y')
      AND pbip.copy_price_for_proxy_flag = 'N'
      AND ((nvl(p_powerbidlosinglines,'N') = 'Y'
      AND pbip.line_number IN (SELECT line_number
                                       FROM   PON_AUCTION_ITEM_PRICES_ALL paip,
									          PON_AUCTION_HEADERS_ALL pah
    								   WHERE  pah.auction_header_id = paip.auction_header_id
									   AND    DECODE(pah.bid_ranking, 'MULTI_ATTRIBUTE_SCORING',paip.best_bid_bid_number,paip.best_bid_number) <> p_previous_bid_number
        							   AND    paip.auction_header_id = pbip.auction_header_id
									   AND    paip.line_number = pbip.line_number))
           OR
           (nvl(p_powerbidlosinglines,'N') = 'N'))
      AND pbip.line_number >= v_batch_start
      AND pbip.line_number <= v_batch_end ;

    -- if price tiers indicator is not equal to either price breaks
    -- or price tiers we don't have to proceed with the shipments
    IF(v_price_tiers_indicator = g_price_breaks or v_price_tiers_indicator = g_quantity_based) THEN

      UPDATE pon_bid_shipments pbs
      SET pbs.bid_currency_unit_price =
               DECODE(pbs.price_type,
                      'PRICE', round(pbs.bid_currency_price * (1 - p_power_percentage/100), v_precision),
                       round((SELECT pbip.bid_currency_unit_price
                              FROM pon_bid_item_prices pbip
                              WHERE pbip.bid_number = pbs.bid_number
                                AND pbip.line_number = pbs.line_number) *
                              (1 - pbs.price_discount/100), v_precision))
      WHERE pbs.bid_number = p_bid_number
        AND pbs.line_number IN (SELECT pbip.line_number
                                FROM pon_bid_item_prices pbip
                                WHERE pbip.bid_number = pbs.bid_number
                                  AND ((get_line_close_bidding_date(pbip.auction_header_id, pbip.line_number, v_is_paused, v_paused_date) > sysdate) OR (v_surrog_bid_flag = 'Y'))
                                  AND pbip.copy_price_for_proxy_flag = 'N')
        AND ((nvl(p_powerbidlosinglines,'N') = 'Y'
        AND pbs.line_number IN (SELECT line_number
                                FROM   PON_AUCTION_ITEM_PRICES_ALL paip,
                                       PON_AUCTION_HEADERS_ALL pah
                                WHERE  pah.auction_header_id = paip.auction_header_id
								AND    DECODE(pah.bid_ranking, 'MULTI_ATTRIBUTE_SCORING',paip.best_bid_bid_number,paip.best_bid_number) <> p_previous_bid_number
                                AND    paip.auction_header_id = pbs.auction_header_id
                                AND    paip.line_number = pbs.line_number))
            OR
            (nvl(p_powerbidlosinglines,'N') = 'N'))
        AND pbs.line_number >= v_batch_start
        AND pbs.line_number <= v_batch_end;
--        AND pbs.shipment_type = 'PRICE BREAK';

      UPDATE pon_bid_shipments pbs
      SET pbs.bid_currency_price = pbs.bid_currency_unit_price,
          pbs.unit_price = pbs.bid_currency_unit_price / v_rate,
          pbs.price = pbs.bid_currency_unit_price / v_rate
      WHERE pbs.bid_number = p_bid_number
        AND pbs.line_number IN (SELECT pbip.line_number
                                FROM pon_bid_item_prices pbip
                                WHERE pbip.bid_number = pbs.bid_number
                                  AND ((get_line_close_bidding_date(pbip.auction_header_id, pbip.line_number, v_is_paused, v_paused_date) > sysdate) OR (v_surrog_bid_flag = 'Y'))
                                  AND pbip.copy_price_for_proxy_flag = 'N')
        AND ((nvl(p_powerbidlosinglines,'N') = 'Y'
        AND pbs.line_number IN (SELECT line_number
                                FROM   PON_AUCTION_ITEM_PRICES_ALL paip,
								       PON_AUCTION_HEADERS_ALL pah
                                WHERE  pah.auction_header_id = paip.auction_header_id
								AND    DECODE(pah.bid_ranking, 'MULTI_ATTRIBUTE_SCORING',paip.best_bid_bid_number,paip.best_bid_number) <> p_previous_bid_number
                                AND    paip.auction_header_id = pbs.auction_header_id
                                AND    paip.line_number = pbs.line_number))
           OR
           (nvl(p_powerbidlosinglines,'N') = 'N'))
        AND pbs.line_number >= v_batch_start
        AND pbs.line_number <= v_batch_end;
  --      AND pbs.shipment_type = 'PRICE BREAK';

    END IF;

    PON_BID_VALIDATIONS_PKG.populate_has_bid_changed_line(
                                       v_auction_header_id,
                                       p_bid_number,
                                       v_source_bid,
                                       v_batch_start,
                                       v_batch_end,
                                       'Y',
                                       v_is_blanket,
                                       'N');

    v_batch_start := v_batch_end + 1;
    IF (v_batch_end + v_batch_size > v_max_line_number) THEN
      v_batch_end := v_max_line_number;
    ELSE
      v_batch_end := v_batch_end + v_batch_size;
    END IF;

    COMMIT;
  END LOOP;

END change_bid_by_percentage;



-- -------------------------------------------------------------------------
-- recalculate_auction_currency_prices
--
-- called from ResponseAMImpl.recalculateAuctionCurrencyPrices, this
-- procedure will recalculate the auction-currency bid prices for all
-- lines and children
-- -------------------------------------------------------------------------

PROCEDURE recalculate_auc_curr_prices
(
	p_bid_number 	IN pon_bid_item_prices.bid_number%TYPE,
	p_curr_changed	IN VARCHAR2,
	p_batch_id		IN pon_bid_item_prices.batch_id%TYPE
)
IS

v_rate NUMBER;
v_precision NUMBER;
v_fnd_precision NUMBER;
v_display_price_factors_flag pon_bid_item_prices.display_price_factors_flag%TYPE;
v_supplier_view_type pon_auction_headers_all.supplier_view_type%TYPE;
v_contract_type pon_auction_headers_all.contract_type%TYPE;
v_is_spo_transformed VARCHAR(1);
v_auction_header_id NUMBER;
v_progress_payment_type pon_auction_headers_all.progress_payment_type%TYPE;
v_advance_negotiable    PON_AUCTION_HEADERS_ALL.ADVANCE_NEGOTIABLE_FLAG%TYPE;
v_max_rtng_negotiable   PON_AUCTION_HEADERS_ALL.MAX_RETAINAGE_NEGOTIABLE_FLAG%TYPE;
v_batch_start NUMBER;
v_batch_end NUMBER;
v_batch_size NUMBER;
v_max_line_number NUMBER;
l_api_name CONSTANT VARCHAR2(30) := 'recalculate_auc_curr_prices';

BEGIN

  -- select some variables we need
  SELECT  pbh.rate,
          pbh.number_price_decimals,
          fnd.precision,
          pbh.display_price_factors_flag,
          paha.supplier_view_type,
          paha.contract_type,
          paha.auction_header_id,
          paha.max_internal_line_num,
          nvl(paha.progress_payment_type,'NONE'),
          nvl(paha.ADVANCE_NEGOTIABLE_FLAG,'N'),
          nvl(paha.MAX_RETAINAGE_NEGOTIABLE_FLAG,'N')

  INTO  v_rate,
        v_precision,
        v_fnd_precision,
        v_display_price_factors_flag,
        v_supplier_view_type,
        v_contract_type,
        v_auction_header_id,
        v_max_line_number,
        v_progress_payment_type,
        v_advance_negotiable,
        v_max_rtng_negotiable
  FROM pon_bid_headers pbh,
       fnd_currencies fnd,
       pon_auction_headers_all paha
  WHERE pbh.bid_number = p_bid_number
    AND paha.auction_header_id = pbh.auction_header_id
    AND fnd.currency_code = pbh.bid_currency_code;

  v_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
  v_batch_start := 1;
  IF (v_max_line_number < v_batch_size) THEN
    v_batch_end := v_max_line_number;
  ELSE
    v_batch_end := v_batch_size;
  END IF;

  -- If we are recalculating auction currency prices for a subset
  -- of the lines (only those lines with p_batch_id) then batching
  -- this procedure is redundant so set the batch_end as the
  -- max_line_number so that the loop is only executed once
  IF (p_curr_changed = 'N') THEN
    v_batch_end := v_max_line_number;
  END IF;

  WHILE (v_batch_start <= v_max_line_number) LOOP

    -- RECALCULATE SPF/BPF VALUES
    -- All BPF and SPF values that are stored in the pon_bid_price_elements
    -- table need to be recalculated.  There are two parts to this task:
    -- (1) recalculate BPF values from auction-currency prices
    --     to bid-currency
    -- (2) recalculate SPF values from bid-currency prices to
    --     auction-currency

    -- (1) For BPF values in the pon_bid_price_elements table,
    -- we need to recalculate the bid-currency values from
    -- the auction-currency values.

	-- NOTE: does not apply for spreadsheet upload, only if currency_changed
    IF ((v_display_price_factors_flag = 'Y' OR v_supplier_view_type = 'UNTRANSFORMED')
       AND p_curr_changed = 'Y') THEN

        -- recalculate bid-currency BPF values from auction-currency values.
        -- Bid-currency BPF value should be rounded.
        UPDATE pon_bid_price_elements pbpe
        SET pbpe.bid_currency_value =
                DECODE(pbpe.pricing_basis,
                       'PER_UNIT', round(pbpe.auction_currency_value*v_rate, v_precision),
                       'FIXED_AMOUNT', round(pbpe.auction_currency_value*v_rate, v_fnd_precision),
                       pbpe.auction_currency_value)
        WHERE pbpe.bid_number = p_bid_number
          AND pbpe.pf_type = 'BUYER'
          AND pbpe.line_number >= v_batch_start
          AND pbpe.line_number <= v_batch_end;
    END IF;


    -- (2) For the SPF values, recalculate auction_currency values from
    -- bid-currency SPF values. The auction-currency SPF value should not
    -- be rounded.

    IF(v_display_price_factors_flag = 'Y') THEN

	  UPDATE pon_bid_price_elements pbpe
	  SET pbpe.auction_currency_value = pbpe.bid_currency_value / decode(pbpe.pricing_basis, 'PERCENTAGE', 1, v_rate)
	  WHERE pbpe.bid_number = p_bid_number
	    AND pbpe.pf_type = 'SUPPLIER'
		-- process only batch, or all SUPPLIER price elements if currency changed
	    AND ((p_curr_changed = 'Y' AND
              pbpe.line_number >= v_batch_start AND
              pbpe.line_number <= v_batch_end)
             OR pbpe.batch_id = p_batch_id);
	END IF;


    -- RECALCULATE LINE-LEVEL PRICES
    -- there are two steps to recalculating auction-currency transformed
    -- bid price:
    -- (1) apply BPF values by using pon_pf_supplier_formula
    -- (2) apply SPF values by summing up all applicable SPF values from
    --     pon_bid_price_elements table and adding to the result of (1)

    -- first, calculate v_is_spo_transformed flag
    IF (v_supplier_view_type = 'TRANSFORMED' AND
        v_contract_type = 'STANDARD') THEN
        v_is_spo_transformed := 'Y';
    ELSE
        v_is_spo_transformed := 'N';
    END IF;

    -- (1) apply BPF formula
    UPDATE pon_bid_item_prices pbip
    SET pbip.bid_currency_trans_price = nvl(
        (SELECT (pbip.bid_currency_unit_price * ppsf.percentage) +
                ppsf.unit_price*v_rate +
                (ppsf.fixed_amount*v_rate / decode(v_is_spo_transformed,
                                            'Y', nvl(pbip.quantity, 1),
                                            nvl(aip.quantity, 1)))
         FROM pon_pf_supplier_formula ppsf,
              pon_bid_headers pbh,
              pon_auction_item_prices_all aip
         WHERE ppsf.auction_header_id = pbip.auction_header_id
           AND ppsf.line_number = pbip.line_number
           AND pbip.bid_number = pbh.bid_number
           AND ppsf.trading_partner_id = pbh.trading_partner_id
           AND ppsf.vendor_site_id = pbh.vendor_site_id
           AND aip.auction_header_id = pbip.auction_header_id
           AND aip.line_number = pbip.line_number),
        pbip.bid_currency_unit_price)
    WHERE pbip.bid_number = p_bid_number
		-- process only batch, or all lines if currency change
	    AND ((p_curr_changed = 'Y' AND
              pbip.line_number >= v_batch_start AND
              pbip.line_number <= v_batch_end)
             OR pbip.batch_id = p_batch_id);

    -- (2) apply SPF values
    UPDATE pon_bid_item_prices pbip
    SET pbip.bid_currency_trans_price =
        (SELECT pbip.bid_currency_trans_price +
                nvl(sum(decode(spf.pricing_basis,
                           'PER_UNIT', spf.bid_currency_value,
                           'PERCENTAGE',  spf.bid_currency_value/100 * pbip.bid_currency_unit_price,
                           (spf.bid_currency_value / decode(v_is_spo_transformed,
                                                           'Y', nvl(pbip.quantity, 1),
                                                           nvl(aip.quantity, 1))))),
                    0)
        FROM pon_bid_price_elements spf,
             pon_auction_item_prices_all aip
        WHERE spf.bid_number = p_bid_number
          AND spf.line_number = pbip.line_number
          AND spf.sequence_number <> -10
          AND aip.auction_header_id = spf.auction_header_id
          AND aip.line_number = spf.line_number
          AND spf.pf_type = 'SUPPLIER')
    WHERE pbip.bid_number = p_bid_number
		-- process only batch, or all lines if currency change
	    AND ((p_curr_changed = 'Y' AND
              pbip.line_number >= v_batch_start AND
              pbip.line_number <= v_batch_end)
             OR pbip.batch_id = p_batch_id);

    -- once we have the untruncated transformed bid-currency price
    -- in bid_currency_trans_price column, copy that value over
    -- to the other columns.
   	--   * unit_price: recalculate from untruncated
    --                 bid_currency_unit_price. (not rounded)
    --   * bid_currency_unit_price: leave it as-is. (not rounded)
	--   * price: recalculate from untruncated
    --            bid_currency_trans_price. (not rounded)
    --   * bid_currency_trans_price: truncate the untruncated
    --            bid_currency_trans_price
    --   * bid_currency_price: TRANSFORMED - bid_currency_trans_price truncated.
    --            UNTRUNCATED - bid_currency_unit_price untruncated.
	--   * Complex Work- For details on how bid_currency_advance_amount and Bid_currency_max_retainage
	--   are calculated please look at ECO#4549930 for details. Here the logic is that bid currency values for
	--   advance_amount and max_reatinage be converted into Bid currency if these are non negotaible
	--    or have not been changed from buyer suggested values in negotiation. But if Supplier has touched
	--   these values, they are left as it is and not converted. CAUTION- The logic for all the 4 complex
	--   work fields is almost same. So, if you change one, also consider impact on others.

    IF p_curr_changed = 'Y' THEN

  	  UPDATE pon_bid_item_prices pbip
	  SET pbip.unit_price = pbip.bid_currency_unit_price / v_rate,
	       pbip.price = pbip.bid_currency_trans_price / v_rate,
	       pbip.bid_currency_price = DECODE(v_supplier_view_type,
                                            'TRANSFORMED', round(pbip.bid_currency_trans_price, v_precision),
                                            'UNTRANSFORMED', pbip.bid_currency_unit_price),
	       pbip.bid_currency_trans_price = round(pbip.bid_currency_trans_price, v_precision),
	       pbip.proxy_bid_limit_price = pbip.bid_currency_limit_price / v_rate,
	       pbip.po_min_rel_amount = pbip.po_bid_min_rel_amount / v_rate,
  	       (pbip.bid_curr_advance_amount,
		    pbip.bid_curr_max_retainage_amt,
		    pbip.advance_amount,
		    pbip.max_retainage_amount)
           = (SELECT nvl2(pbip.bid_curr_advance_amount,
                       decode(v_advance_negotiable, 'Y',
                              decode( pbip.advance_amount-paip.advance_amount, 0, round(pbip.advance_amount* v_rate,v_fnd_precision),pbip.bid_curr_advance_amount),
                              round(pbip.advance_amount* v_rate,v_fnd_precision)
                        ), pbip.bid_curr_advance_amount),

                  nvl2(pbip.bid_curr_max_retainage_amt,
                       decode(v_max_rtng_negotiable, 'Y',
                              decode( pbip.max_retainage_amount-paip.max_retainage_amount, 0, round(pbip.max_retainage_amount* v_rate,v_fnd_precision),pbip.bid_curr_max_retainage_amt),
                              round(pbip.max_retainage_amount* v_rate,v_fnd_precision)
                        ), pbip.bid_curr_max_retainage_amt),

                  nvl2(pbip.advance_amount,
                       decode(v_advance_negotiable, 'Y',
                              decode( pbip.advance_amount-paip.advance_amount, 0, pbip.advance_amount,pbip.bid_curr_advance_amount/v_rate),
                              pbip.advance_amount
                        ), pbip.advance_amount),

                  nvl2(pbip.max_retainage_amount,
                       decode(v_max_rtng_negotiable, 'Y',
                              decode( pbip.max_retainage_amount-paip.max_retainage_amount, 0, pbip.max_retainage_amount,pbip.bid_curr_max_retainage_amt/v_rate),
                              pbip.max_retainage_amount
                        ), pbip.max_retainage_amount)
	                                    FROM pon_auction_item_prices_all paip
	                                    WHERE paip.auction_header_id=pbip.auction_header_id
	                                    AND paip.line_number=pbip.line_number)
	  WHERE pbip.bid_number = p_bid_number
		-- process only batch, or all lines if currency change
	    AND ((p_curr_changed = 'Y' AND
              pbip.line_number >= v_batch_start AND
              pbip.line_number <= v_batch_end)
             OR pbip.batch_id = p_batch_id);
    ELSE

  	  UPDATE pon_bid_item_prices pbip
	  SET pbip.unit_price = pbip.bid_currency_unit_price / v_rate,
	       pbip.price = pbip.bid_currency_trans_price / v_rate,
	       pbip.bid_currency_price = DECODE(v_supplier_view_type,
                                            'TRANSFORMED', round(pbip.bid_currency_trans_price, v_precision),
                                            'UNTRANSFORMED', pbip.bid_currency_unit_price),
	       pbip.bid_currency_trans_price = round(pbip.bid_currency_trans_price, v_precision),
	       pbip.proxy_bid_limit_price = pbip.bid_currency_limit_price / v_rate,
	       pbip.po_min_rel_amount = pbip.po_bid_min_rel_amount / v_rate,
	       pbip.advance_amount = pbip.bid_curr_advance_amount/ v_rate,
	       pbip.max_retainage_amount = pbip.bid_curr_max_retainage_amt/v_rate
	  WHERE pbip.bid_number = p_bid_number
		-- process only batch, or all lines if currency change
	    AND ((p_curr_changed = 'Y' AND
              pbip.line_number >= v_batch_start AND
              pbip.line_number <= v_batch_end)
             OR pbip.batch_id = p_batch_id);
    END IF;

    -- RECALCULATE SHIPMENT-LEVEL PRICES
    -- there are two steps to recalculating auction-currency transformed
    -- shipment price:
    -- (1) apply BPF values by using pon_pf_supplier_formula
    -- (2) apply SPF values by summing up all applicable SPF values from
    --     pon_bid_price_elements table and adding to the result of (1)

	-- NOTE: does not apply for spreadsheet upload, only if currency changed
	--comment this out for price tier: IF (v_contract_type <> 'STANDARD') THEN

	    -- (1) apply BPF formula
	    UPDATE pon_bid_shipments pbs
	    SET pbs.bid_currency_price = nvl(
	        (SELECT (pbs.bid_currency_unit_price * ppsf.percentage) +
	                ppsf.unit_price*v_rate +
	                (ppsf.fixed_amount*v_rate / decode(v_is_spo_transformed,
	                                            'Y', nvl(pbip.quantity, 1),
	                                            nvl(aip.quantity, 1)))
	         FROM pon_pf_supplier_formula ppsf,
	              pon_bid_headers pbh,
	              pon_auction_item_prices_all aip,
	              pon_bid_item_prices pbip
	         WHERE pbip.bid_number = pbs.bid_number
	           AND pbip.line_number = pbs.line_number
	           AND ppsf.auction_header_id = pbip.auction_header_id
	           AND ppsf.line_number = pbip.line_number
	           AND pbip.bid_number = pbh.bid_number
	           AND ppsf.trading_partner_id = pbh.trading_partner_id
	           AND ppsf.vendor_site_id = pbh.vendor_site_id
	           AND aip.auction_header_id = pbip.auction_header_id
	           AND aip.line_number = pbip.line_number),
	        pbs.bid_currency_unit_price)
	    WHERE pbs.bid_number = p_bid_number
	      AND pbs.line_number >= v_batch_start
          AND pbs.line_number <= v_batch_end;


	    -- (2) apply SPF values
	    UPDATE pon_bid_shipments pbs
	    SET pbs.bid_currency_price =
	        (SELECT pbs.bid_currency_price +
	                nvl(sum(decode(spf.pricing_basis,
	                              'PER_UNIT', spf.bid_currency_value,
	                              'PERCENTAGE',  spf.bid_currency_value/100 * pbs.bid_currency_unit_price,
	                              (spf.bid_currency_value / decode(v_is_spo_transformed,
	                                                               'Y', nvl(pbip.quantity, 1),
	                                                               nvl(aip.quantity, 1))))),
	                    0)
	        FROM pon_bid_price_elements spf,
	             pon_auction_item_prices_all aip,
	             pon_bid_item_prices pbip
	        WHERE pbip.bid_number = pbs.bid_number
	          AND pbip.line_number = pbs.line_number
	          AND spf.bid_number = p_bid_number
	          AND spf.line_number = pbip.line_number
	          AND spf.sequence_number <> -10
	          AND aip.auction_header_id = spf.auction_header_id
	          AND aip.line_number = spf.line_number
	          AND spf.pf_type = 'SUPPLIER')
	    WHERE pbs.bid_number = p_bid_number
	      AND pbs.line_number >= v_batch_start
          AND pbs.line_number <= v_batch_end;

	    -- once we have the untruncated transformed bid-currency price
	    -- in bid_currency_price column, copy that value over
	    -- to the other columns.
	   	--   * unit_price: recalculate from untruncated
	    --                 bid_currency_unit_price. (not rounded)
	    --   * bid_currency_unit_price: leave it as-is. (not rounded)
		--   * price: recalculate from untruncated
	    --            bid_currency_price. (not rounded)
	    --   * bid_currency_price: truncate the untruncated
	    --            bid_currency_price
	    UPDATE pon_bid_shipments pbs
	    SET pbs.unit_price = pbs.bid_currency_unit_price / v_rate,
	        pbs.price = pbs.bid_currency_price / v_rate,
	        pbs.bid_currency_price = DECODE(v_supplier_view_type,
                                            'TRANSFORMED', round(pbs.bid_currency_price, v_precision),
                                            'UNTRANSFORMED', pbs.bid_currency_unit_price)
	    WHERE pbs.bid_number = p_bid_number
	      AND pbs.line_number >= v_batch_start
          AND pbs.line_number <= v_batch_end;

	--END IF;

	 -- RECALCULATE PAYMENT PRICES
     -- Since Payments values are not tranformed ever, we can directly multiply by rate

	IF (p_curr_changed = 'Y' AND v_contract_type = 'STANDARD' AND v_progress_payment_type <> 'NONE' ) THEN

	    UPDATE pon_bid_payments_shipments pbps
	    SET pbps.price = pbps.bid_currency_price / v_rate

	    WHERE pbps.bid_number = p_bid_number
	      AND pbps.bid_line_number >= v_batch_start
          AND pbps.bid_line_number <= v_batch_end;

	END IF;

    v_batch_start := v_batch_end + 1;
    IF (v_batch_end + v_batch_size > v_max_line_number) THEN
      v_batch_end := v_max_line_number;
    ELSE
      v_batch_end := v_batch_end + v_batch_size;
    END IF;

	-- If we are recalculating after a currency change then we need
    -- to commit because the procedure was executed in batches
    -- In the other case(s), we do NOT want to commit because
    -- the procedure was executed in a single batch only for lines
    -- with p_batch_id and the calling procedure will do the commit (or rollback)
    IF (p_curr_changed = 'Y') THEN
	  COMMIT;
    END IF;

  END LOOP;
END;



-- -------------------------------------------------------------------------
-- publish
--
-- called from BidHeadersEO.publish or the concurrent publish program, this
-- procedure will publish the draft
-- -------------------------------------------------------------------------

PROCEDURE publish(p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
                  p_bid_number IN pon_bid_headers.bid_number%TYPE,
                  p_rebid_flag IN VARCHAR,
                  p_publish_date IN pon_bid_headers.publish_date%TYPE,
                  p_tp_id IN pon_bid_headers.trading_partner_id%TYPE,
                  p_tpc_id IN pon_bid_headers.trading_partner_contact_id%TYPE,
                  p_user_id IN NUMBER,
                  p_batch_id IN NUMBER,
                  p_request_id IN NUMBER,
                  p_hdr_validation_failed IN VARCHAR,
                  x_return_status OUT NOCOPY NUMBER,
                  x_return_code OUT NOCOPY VARCHAR)
IS

    v_auc_close_bidding_date pon_auction_headers_all.close_bidding_date%TYPE;
    v_group_enabled_flag pon_auction_headers_all.group_enabled_flag%TYPE;
    v_is_paused pon_auction_headers_all.is_paused%TYPE;
    v_surrog_bid_receipt_date pon_bid_headers.surrog_bid_receipt_date%TYPE;
    v_publish_date DATE;
    v_auc_tp_id pon_auction_headers_all.trading_partner_id%TYPE;
    v_two_part_flag pon_auction_headers_all.two_part_flag%TYPE;
    v_sealed_auction_status pon_auction_headers_all.sealed_auction_status%TYPE;
    --added by Allen Yang for Surrogate Bid 2008/09/08
    --------------------------------------------------
    l_two_part_flag pon_auction_headers_all.TWO_PART_FLAG%TYPE;
    l_technical_evaluation_status pon_auction_headers_all.TECHNICAL_EVALUATION_STATUS%TYPE;
    l_surrogate_bid_flag pon_bid_headers.SURROG_BID_FLAG%TYPE;
    l_submit_stage pon_bid_headers.SUBMIT_STAGE%TYPE;
    --------------------------------------------------
    v_vendor_site_id pon_bid_headers.vendor_site_id%TYPE;
    v_prev_bid_number pon_bid_headers.old_bid_number%TYPE;
    v_surrog_bid_flag pon_bid_headers.surrog_bid_flag%TYPE;
    v_evaluation_flag pon_bid_headers.evaluation_flag%TYPE;
    v_tpc_name pon_bid_headers.trading_partner_contact_name%TYPE;

    v_wf_item_key pon_bidding_parties.wf_item_key%TYPE;
    v_user_added_to_role VARCHAR2(1);
    v_price_changed VARCHAR2(1);

    v_subroutine_return_status NUMBER;
    v_subroutine_return_code VARCHAR2(30);

    v_biz_return_status VARCHAR2(240);
    v_biz_msg_count NUMBER;
    v_biz_msg_data_value VARCHAR2(240);

    --batching-related variables
    v_maxLineNumber NUMBER;
    v_batchSize NUMBER;
    v_batchingRequired BOOLEAN;
    l_isEvalResubmitted CHAR;

    l_api_name CONSTANT VARCHAR2(30) := 'publish';

BEGIN

    x_return_status := 0;
    x_return_code := '';
    v_price_changed := 'N';
    v_user_added_to_role := 'Y';
    v_subroutine_return_status := 0;
    v_subroutine_return_code := '';
    v_is_paused := 'N';

    --added by Allen Yang for Surrogate Bid 2008/09/08
    --------------------------------------------------
    --get the two-part stage of submitting quote
    SELECT
      paha.TWO_PART_FLAG
    , paha.TECHNICAL_EVALUATION_STATUS
    , pbh.SURROG_BID_FLAG
    INTO
      l_two_part_flag
    , l_technical_evaluation_status
    , l_surrogate_bid_flag
    FROM
      PON_AUCTION_HEADERS_ALL paha
    , PON_BID_HEADERS pbh
    WHERE paha.auction_header_id = pbh.auction_header_id
      AND pbh.bid_number = p_bid_number;

    IF ((nvl(l_two_part_flag, 'N') = 'Y') AND (nvl(l_surrogate_bid_flag, 'N') = 'Y'))
    THEN
      IF (nvl(l_technical_evaluation_status, 'NOT_COMPLETED') = 'NOT_COMPLETED')
      THEN
        l_submit_stage := 'TECHNICAL';
      ELSIF l_technical_evaluation_status = 'COMPLETED'
      THEN
        l_submit_stage := 'COMMERCIAL';
      END IF;
    END IF;
    --------------------------------------------------

    -- (1) perform line-level validation.
    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' -  performing pre-publish validation for draft bid ' || p_bid_number);
    END IF;

    pon_bid_validations_pkg.validate_bid(p_auction_header_id, p_bid_number, 'PUBLISHBID', p_user_id, p_batch_id, p_request_id,
                                         v_subroutine_return_status, v_subroutine_return_code);

    -- quit out if we have errors from the validation.  return code will be VALIDATION_ERROR
    IF v_subroutine_return_status = g_return_error THEN
       x_return_status := g_return_error;
       x_return_code := 'VALIDATION_ERROR';

       IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
         print_log(l_api_name, p_bid_number || ' - validation returned with errors; exiting publish');
       END IF;
       RETURN;
    END IF;

    -- if p_hdr_validation_failed, it means that the Java-layer header-level
    -- validation of this bid failed.  We still want to process this publish
    -- to find any line-level validation errors, but we do not want to proceed
    -- with the actual publish.  x_return_status for the publish routine
    -- is set to 0 if no line-level validations are found; set to 1 if found (see above).
    IF p_hdr_validation_failed = 'Y' THEN
       x_return_status := g_return_success;

       IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
         print_log(l_api_name, p_bid_number || ' - validation returned with no errors, but exiting publish because there are header-level validation errors');
       END IF;
       RETURN;
    END IF;


    -- lock the auction header
    SELECT close_bidding_date, group_enabled_flag,
           max_internal_line_num, trading_partner_id, sealed_auction_status, two_part_flag
    INTO v_auc_close_bidding_date, v_group_enabled_flag,
           v_maxLineNumber, v_auc_tp_id, v_sealed_auction_status, v_two_part_flag
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auction_header_id
    FOR UPDATE OF CLOSE_BIDDING_DATE;

    SELECT vendor_site_id, old_bid_number, surrog_bid_flag, trading_partner_contact_name, evaluation_flag, nvl2(publish_date,'Y','N')
    INTO v_vendor_site_id, v_prev_bid_number, v_surrog_bid_flag, v_tpc_name, v_evaluation_flag, l_isEvalResubmitted
    FROM pon_bid_headers
    WHERE bid_number = p_bid_number;

    -- (woojin) first do the validations to make sure that this
    -- bid is allowed to go through.
    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - checking is bid valid ');
    END IF;
    PON_AUCTION_HEADERS_PKG.check_is_bid_valid(p_auction_header_id,
                                               p_bid_number,
                                               v_vendor_site_id,
                                               v_prev_bid_number,
                                               p_rebid_flag,
                                               'N',
                                               v_surrog_bid_flag,
                                               p_publish_date,
                                               v_subroutine_return_status,
                                               v_subroutine_return_code);

    -- if we have errors, then quit out of is_bidding_allowed
    -- and in turn, quit out of save draft or publish.
    IF v_subroutine_return_status = g_return_error THEN
       x_return_status := g_return_error;
       x_return_code := v_subroutine_return_code;

       IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
         print_log(l_api_name, p_bid_number || ' - check_is_bid_valid failed with error: ' || v_subroutine_return_code || '; exiting publish.');
       END IF;
       RETURN;
    END IF;

    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - after check is bid valid ');
    END IF;


    --------------------------------------------------------------------------------
    -- END OF VALIDATION.  BELOW, WE PROCEED WITH PUBLISH
    --------------------------------------------------------------------------------

    v_batchSize := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
    v_batchingRequired := (v_maxLineNumber > v_batchSize);
    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - batching required? batch size=' || v_batchSize || '; numOfLines=' || v_maxLineNumber);
    END IF;

    -- (2) remove empty rows (lines, children)
    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - remove empty rows');
    END IF;
    -- modified by Allen Yang for surrogate bid bug 7702461 2009/01/22
    --------------------------------------------------------------------
    -- only for those quotes not submitted on technical stage, remove empty rows.
    IF ( l_submit_stage IS NULL OR l_submit_stage <> 'TECHNICAL')
    THEN
      IF (v_batchingRequired) THEN
        remove_empty_rows_auto(p_bid_number, v_maxLineNumber, v_batchSize);
      ELSE
        remove_empty_rows(p_bid_number, 1, v_maxLineNumber);
      END IF;
    END IF;
    /*
    IF (v_batchingRequired) THEN
      remove_empty_rows_auto(p_bid_number, v_maxLineNumber, v_batchSize);
    ELSE
      remove_empty_rows(p_bid_number, 1, v_maxLineNumber);
    END IF;
    */
    ---------------------------------------------------------------------

    -- (3) calculate group amounts
    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - calculate group amounts? ' || v_group_enabled_flag);
    END IF;

    -- (woojin) commented out this portion because group amount
    -- is calculated in update_auction_info/update_proxy_bids after
    -- proxies are calculated. The calculation here is not only
    -- useless, but sometimes may yield in wrong results.
    --
    -- (jingche) Bug6491853: uncomment this part of code, because update_group_amounts() is not called for all cases in update_auction_info(), group_amount becomes null in RFQ
    -- use 'N' instead of 'Y' when calling calculate_group_amounts_auto()
    -- to use buyer currency in gourp_amount
    IF v_group_enabled_flag = 'Y' THEN
       IF (v_batchingRequired) THEN
         calculate_group_amounts_auto(p_bid_number, 'N');
       ELSE
         calculate_group_amounts(p_bid_number, 'N');
       END IF ;
    END IF;

    -- (4) set miscellaneous header-level attributes
    -- - close_bidding_date = sysdate if auction is still open
    --                        surrog bid receipt date if closed
    -- - shortlist_flag = default to 'Y'
    -- - surrog_bid_online_entry_date = sysdate

    IF (v_surrog_bid_flag = 'Y') THEN
       SELECT surrog_bid_receipt_date
       INTO v_surrog_bid_receipt_date
       FROM pon_bid_headers
       WHERE bid_number = p_bid_number;
       v_publish_date := v_surrog_bid_receipt_date;
    ELSE
       v_publish_date := p_publish_date;
    END IF;

    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - set header-level attributes');
    END IF;
    IF (v_batchingRequired) THEN
      update_bid_header_fields_auto(p_bid_number, v_publish_date, p_publish_date, v_surrog_bid_flag, v_two_part_flag, v_sealed_auction_status);
    ELSE
      update_bid_header_fields(p_bid_number, v_publish_date, p_publish_date, v_surrog_bid_flag, v_two_part_flag, v_sealed_auction_status);
    END IF;

    -- (5) set miscellaneous line-level attributes
    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - publish lines');
    END IF;
    IF (v_batchingRequired) THEN
      publish_lines_auto(p_auction_header_id, p_bid_number, v_publish_date,
                         p_tp_id, v_auc_tp_id, v_surrog_bid_flag, p_rebid_flag, v_maxLineNumber, v_batchSize);
    ELSE
      publish_lines(p_auction_header_id, p_bid_number, v_publish_date,
                    p_tp_id, v_auc_tp_id, v_surrog_bid_flag, p_rebid_flag, 1, v_maxLineNumber);
    END IF;

    -- (7) perform the things that used to be in BidHeadersEO.beforeCommit()
    -- check_auction_bidder
    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - check auction bidder');
    END IF;
    PON_AUCTION_PKG.CHECK_AUCTION_BIDDER(p_tpc_id, p_auction_header_id, v_subroutine_return_status);
    IF v_subroutine_return_status = 1 THEN
       IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
         print_log(l_api_name, p_bid_number || ' - check auction bidder; user not added to role');
       END IF;
       v_user_added_to_role := 'N';
    END IF;


    -- update_auction_info
    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - update auction info');
    END IF;
    PON_AUCTION_HEADERS_PKG.UPDATE_AUCTION_INFO(p_auction_header_id, p_bid_number, v_vendor_site_id, p_rebid_flag, v_prev_bid_number, 'N', v_surrog_bid_flag, p_user_id, v_subroutine_return_status, v_subroutine_return_code);

    IF v_subroutine_return_status = g_return_error THEN
       x_return_code := v_subroutine_return_code;
       x_return_status := g_return_error;
       IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
         print_log(l_api_name, p_bid_number || ' - update auction info; error code=' || x_return_code);
       END IF;
       RETURN;
    ELSIF v_subroutine_return_status = g_return_warning THEN
       IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
         print_log(l_api_name, p_bid_number || ' - update auction info; price changed');
       END IF;
       v_price_changed := 'Y';
    END IF;

    -- ackResponse stuff -- only perform when this is not a rebid
    IF p_rebid_flag = 'N' THEN
       BEGIN
          SELECT wf_item_key
          INTO v_wf_item_key
          FROM pon_bidding_parties
          WHERE auction_header_id = p_auction_header_id
            AND trading_partner_id = p_tp_id
            AND nvl(supp_acknowledgement, 'N') = 'N'
            AND rownum=1;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             v_wf_item_key := NULL;
       END;

       IF v_wf_item_key IS NOT NULL THEN
         IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
           print_log(l_api_name, p_bid_number || ' - ack notif response');
         END IF;
         PON_AUCTION_PKG.ACK_NOTIF_RESPONSE(v_wf_item_key, v_tpc_name, 'Y','', v_subroutine_return_status);

         IF v_subroutine_return_status = 1 THEN
           IF (g_fnd_debug = 'Y') THEN
             IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
		       FND_LOG.string(log_level => FND_LOG.level_exception,
                         module    => g_module_prefix || l_api_name,
                         message   => 'Response acknowledge notification cannot be sent for bid ' || p_bid_number);
             END IF;
           END IF;
         END IF;
       END IF;
    END IF;

    IF v_user_added_to_role = 'N' THEN
      IF v_price_changed = 'Y' THEN
          x_return_status := g_return_warning;
          x_return_code := 'PRICE_CHANGED_AND_USER_NOT_ADDED_TO_ROLE';
       ELSE
          x_return_status := g_return_warning;
          x_return_code := 'USER_NOT_ADDED_TO_ROLE';
       END IF;
    ELSIF v_price_changed = 'Y' THEN
        x_return_status := g_return_warning;
        x_return_code := 'PRICE_CHANGED';
    ELSE
        x_return_status := g_return_success;
    END IF;

    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - return status: ' || x_return_status || '; return code: ' || x_return_code);
      print_log(l_api_name, p_bid_number || ' - call send_resp_notif');
    END IF;

    --Call the Workflow. Don not raise any error even if is not successful
    PON_AUCTION_PKG.SEND_RESP_NOTIF(p_bid_number => p_bid_number,
                                    x_return_status =>v_subroutine_return_code);

    -- raise response publish business event (uday's code)
    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - call raise response publish business event');
    END IF;
    PON_BIZ_EVENTS_PVT.RAISE_RESPNSE_PUB_EVENT(1.0, 'F', 'F', p_bid_number, v_biz_return_status, v_biz_msg_count, v_biz_msg_data_value);

    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, 'v_biz_return_status=' || v_biz_return_status);
      print_log(l_api_name, 'v_biz_msg_count=' || v_biz_msg_count);
      print_log(l_api_name, 'v_biz_msg_data_value=' || v_biz_msg_data_value);
      print_log(l_api_name, p_bid_number || ' - finally PUBLISH the bid by setting bid_status to ACTIVE!!');
    END IF;

    -- Begin Supplier Management: Bug 12369949
    IF (v_evaluation_flag = 'Y') THEN
      PON_EVAL_TEAM_UTIL_PVT.send_eval_update_scorer_notif(p_bid_number||':'|| l_isEvalResubmitted);
    END IF;
    -- End Supplier Management: Bug 12369949

    -- unlock and publish
    -- if this is a draft bid then need to release lock
    UPDATE pon_bid_headers
    SET draft_locked = 'N',
        draft_unlocked_by = p_tp_id,
        draft_unlocked_by_contact_id = p_tpc_id,
        draft_unlocked_date = sysdate,
        bid_status = 'ACTIVE'
        --added by Allen Yang for Surrogate Bid 2008/09/08
        --------------------------------------------------
        , submit_stage = l_submit_stage
        --------------------------------------------------
    WHERE bid_number = p_bid_number;

    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - exiting publish successfully');
    END IF;


END publish;




-- -------------------------------------------------------------------------
-- remove_empty_rows
--
-- called from publish_bid above, this method will remove empty lines and
-- children so that we only commit lines with bids to the database upon
-- publish
-- -------------------------------------------------------------------------

PROCEDURE remove_empty_rows
          (p_bid_number IN pon_bid_headers.bid_number%TYPE,
           p_batch_start IN NUMBER,
           p_batch_end IN NUMBER)

IS

    l_api_name CONSTANT VARCHAR2(30) := 'remove_empty_rows';

BEGIN

    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - begin remove empty rows for batch range ' || p_batch_start || ' ~ ' || p_batch_end || ' inclusive');
    END IF;

    -- 1) empty attributes (including header attributes)
    -- 2) display only attributes (including header attributes)
    -- 3) attributes on lines that have hasBid = N
    DELETE FROM pon_bid_attribute_values pbav
    WHERE pbav.bid_number = p_bid_number
      AND (EXISTS (SELECT null
                   FROM pon_auction_attributes paa
                   WHERE pbav.auction_header_id = paa.auction_header_id
                     AND pbav.line_number = paa.line_number
                     AND pbav.attribute_name = paa.attribute_name
                     AND paa.display_only_flag = 'Y')
           OR pbav.value IS NULL
           OR EXISTS (SELECT null
                   FROM pon_bid_item_prices pbip
                   WHERE pbip.bid_number = pbav.bid_number
                     AND pbip.line_number = pbav.line_number
                     AND pbip.has_bid_flag = 'N'))
      AND pbav.line_number >= p_batch_start
      AND pbav.line_number <= p_batch_end;

    -- remove:
    -- 1) empty price elements
    -- 2) price elements for lines with hasBid=N
    DELETE FROM pon_bid_price_elements pbpe
    WHERE pbpe.bid_number = p_bid_number
      AND EXISTS (SELECT null
                  FROM pon_bid_item_prices pbip
                  WHERE pbip.bid_number = pbpe.bid_number
                    AND pbip.line_number = pbpe.line_number
	                AND pbip.has_bid_flag = 'N')
      AND pbpe.line_number >= p_batch_start
      AND pbpe.line_number <= p_batch_end;

    -- remove:
    -- 1) empty price_differentials (line-level, shipment-level)
    -- 2) price differentials for lines with hasBid=N (line-level, shipment-level)
    DELETE FROM pon_bid_price_differentials pbpd
    WHERE pbpd.bid_number = p_bid_number
      AND EXISTS (SELECT null
                  FROM pon_bid_item_prices pbip
                  WHERE pbip.bid_number = pbpd.bid_number
                    AND pbip.line_number = pbpd.line_number
                    AND pbip.has_bid_flag = 'N')
      AND pbpd.line_number >= p_batch_start
      AND pbpd.line_number <= p_batch_end;


    -- remove:
    -- 1) shipments for lines with hasBid=N
    DELETE FROM pon_bid_shipments pbs
    WHERE pbs.bid_number = p_bid_number
      AND EXISTS (SELECT null
                  FROM pon_bid_item_prices pbip
                  WHERE pbip.bid_number = pbs.bid_number
                    AND pbip.line_number = pbs.line_number
	                AND pbip.has_bid_flag = 'N')
      AND pbs.line_number >= p_batch_start
      AND pbs.line_number <= p_batch_end;

    -- remove:
    -- 1) Payments for lines with hasBid=N
    DELETE FROM pon_bid_payments_shipments pbps
    WHERE pbps.bid_number = p_bid_number
      AND EXISTS (SELECT null
                  FROM pon_bid_item_prices pbip
                  WHERE pbip.bid_number = pbps.bid_number
                    AND pbip.line_number = pbps.bid_line_number
	                AND pbip.has_bid_flag = 'N')
      AND pbps.bid_line_number >= p_batch_start
      AND pbps.bid_line_number <= p_batch_end;

    -- remove empty lines finally
    DELETE FROM pon_bid_item_prices
    WHERE bid_number = p_bid_number
      AND has_bid_flag = 'N'
      AND line_number >= p_batch_start
      AND line_number <= p_batch_end;

    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - end remove empty rows for batch range ' || p_batch_start || ' ~ ' || p_batch_end || ' inclusive');
    END IF;
END remove_empty_rows;


PROCEDURE remove_empty_rows_auto
          (p_bid_number IN pon_bid_headers.bid_number%TYPE,
           p_max_line_number IN NUMBER,
           p_batch_size IN NUMBER)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name CONSTANT VARCHAR2(30) := 'remove_empty_rows_auto';
    v_batch_start NUMBER;
    v_batch_end NUMBER;

BEGIN

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, p_bid_number || ' - BEGIN remove empty rows AUTONOMOUS');
  END IF;

  v_batch_start := 1;
  IF (p_max_line_number < p_batch_size) THEN
    v_batch_end := p_max_line_number;
  ELSE
    v_batch_end := p_batch_size;
  END IF;

  WHILE (v_batch_start <= p_max_line_number) LOOP

    remove_empty_rows(p_bid_number, v_batch_start, v_batch_end);
    commit;

    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - remove empty rows: batch committed');
    END IF;

    v_batch_start := v_batch_end + 1;
    IF (v_batch_end + p_batch_size > p_max_line_number) THEN
      v_batch_end := p_max_line_number;
    ELSE
      v_batch_end := v_batch_end + p_batch_size;
    END IF;
  END LOOP;

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, p_bid_number || ' - END remove empty rows AUTONOMOUS');
  END IF;
END remove_empty_rows_auto;



-- -------------------------------------------------------------------------
-- update_bid_header_fields
--
-- called from publish above, this method will update a few fields in
-- bid header
-- -------------------------------------------------------------------------

PROCEDURE update_bid_header_fields
    (p_bid_number IN pon_bid_headers.bid_number%TYPE,
     p_publish_date IN pon_bid_headers.publish_date%TYPE,
     p_bid_entry_date IN pon_bid_headers.publish_date%TYPE,
     p_surrog_bid_flag IN pon_bid_headers.surrog_bid_flag%TYPE,
     p_two_part_flag IN pon_auction_headers_all.two_part_flag%TYPE,
     p_sealed_auction_status IN pon_auction_headers_all.sealed_auction_status%TYPE)
IS

    l_api_name CONSTANT VARCHAR2(30) := 'update_bid_header_fields';
    l_tech_shortlist_flag VARCHAR2(1) := null;

BEGIN

    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - begin update bid header fields');
      print_log(l_api_name, p_bid_number || ' - update bid header fields: p_publish_date=' || p_publish_date);
    END IF;

    IF (p_surrog_bid_flag = 'Y' AND p_two_part_flag = 'Y' AND p_sealed_auction_status <> 'LOCKED') THEN
    	l_tech_shortlist_flag := 'Y';
    END IF;


    UPDATE pon_bid_headers
    SET publish_date = p_publish_date,
        shortlist_flag = 'Y',
        surrog_bid_online_entry_date = p_bid_entry_date,
	technical_shortlist_flag = l_tech_shortlist_flag
        --,bid_status = 'ACTIVE'
    WHERE bid_number = p_bid_number;

    IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
      print_log(l_api_name, p_bid_number || ' - end update bid header fields');
    END IF;
END update_bid_header_fields;


PROCEDURE update_bid_header_fields_auto
    (p_bid_number IN pon_bid_headers.bid_number%TYPE,
     p_publish_date IN pon_bid_headers.publish_date%TYPE,
     p_bid_entry_date IN pon_bid_headers.publish_date%TYPE,
     p_surrog_bid_flag IN pon_bid_headers.surrog_bid_flag%TYPE,
     p_two_part_flag IN pon_auction_headers_all.two_part_flag%TYPE,
     p_sealed_auction_status IN pon_auction_headers_all.sealed_auction_status%TYPE)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

    l_api_name CONSTANT VARCHAR2(30) := 'update_bid_header_fields_auto';
BEGIN
  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, p_bid_number || ' - BEGIN update bid header fields AUTONOMOUS');
  END IF;

  update_bid_header_fields(p_bid_number, p_publish_date, p_bid_entry_date, p_surrog_bid_flag, p_two_part_flag, p_sealed_auction_status);
  commit;

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, p_bid_number || ' - update bid header fields: committed!');
    print_log(l_api_name, p_bid_number || ' - END update bid header fields AUTONOMOUS');
  END IF;

END update_bid_header_fields_auto;


-- -------------------------------------------------------------------------
-- publish_lines
--
-- called from publish_bid above, this method will perform line-level
-- publish processing, such as setting line-level publish date.
-- -------------------------------------------------------------------------

PROCEDURE publish_lines
   (p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
    p_bid_number IN pon_bid_headers.bid_number%TYPE,
    p_publish_date IN DATE,
    p_tp_id IN pon_bid_headers.trading_partner_id%TYPE,
    p_auc_tp_id IN pon_auction_headers_all.trading_partner_id%TYPE,
    p_surrog_bid_flag IN pon_bid_headers.surrog_bid_flag%TYPE,
    p_rebid_flag IN VARCHAR,
    p_batch_start IN NUMBER,
    p_batch_end IN NUMBER)

IS

    v_full_quantity_bid_code pon_auction_headers_all.full_quantity_bid_code%TYPE;
    v_surrog_bid_flag pon_bid_headers.surrog_bid_flag%TYPE;
    v_auc_tp_id pon_auction_headers_all.trading_partner_id%TYPE;
    v_auction_header_id NUMBER;
    l_api_name CONSTANT VARCHAR2(30) := 'publish_lines';

BEGIN

   IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
     print_log(l_api_name, p_bid_number || ' - begin publish lines for batch range: ' || p_batch_start || ' ~ ' || p_batch_end || ' inclusive');
   END IF;

      IF p_rebid_flag = 'N' THEN

         UPDATE pon_bid_item_prices
         SET publish_date = p_publish_date,
             proxy_bid_flag = 'N',
             award_price = price,
             first_bid_price = price,  --(woojin) do we really need this?
             bid_trading_partner_id = decode(p_surrog_bid_flag,
                                             'Y', p_auc_tp_id, p_tp_id)
         WHERE bid_number = p_bid_number
           AND line_number >= p_batch_start
           AND line_number <= p_batch_end;

      ELSE

         -- then set publish date to current time for isPublishedLines
         -- also, set proxy_bid_flag to 'N'
         -- Please note that the is_changed_line_flag is used in the procedure
         -- PONAUCHB.check_is_bid_valid to determine the newly added/modified
         -- lines. In case this logic is changed do ensure that the check_is_bid_valid
         -- procedure is also modified
         UPDATE pon_bid_item_prices
         SET publish_date = p_publish_date,
             proxy_bid_flag = 'N',
             award_price = price,
             first_bid_price = nvl(first_bid_price, price),    --(woojin) do we really need this?
             bid_trading_partner_id = decode(p_surrog_bid_flag,
                                             'Y', p_auc_tp_id, p_tp_id)
         WHERE bid_number = p_bid_number
           AND is_changed_line_flag = 'Y'
           AND line_number >= p_batch_start
           AND line_number <= p_batch_end;

		--Bug 10169313
		UPDATE pon_bid_item_prices
 	            SET award_price = price
 	          WHERE bid_number = p_bid_number
 	            AND is_changed_line_flag <> 'Y'
 	            AND line_number >= p_batch_start
 	            AND line_number <= p_batch_end;

      END IF;

   IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
     print_log(l_api_name, p_bid_number || ' - end publish lines for batch range: ' || p_batch_start || ' ~ ' || p_batch_end || ' inclusive');
   END IF;

END;


PROCEDURE publish_lines_auto
   (p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
    p_bid_number IN pon_bid_headers.bid_number%TYPE,
    p_publish_date IN DATE,
    p_tp_id IN pon_bid_headers.trading_partner_id%TYPE,
    p_auc_tp_id IN pon_auction_headers_all.trading_partner_id%TYPE,
    p_surrog_bid_flag IN pon_bid_headers.surrog_bid_flag%TYPE,
    p_rebid_flag IN VARCHAR,
    p_max_line_number IN NUMBER,
    p_batch_size IN NUMBER)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

    v_batch_start NUMBER;
    v_batch_end NUMBER;
    l_api_name CONSTANT VARCHAR2(30) := 'publish_lines_auto';

BEGIN

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, p_bid_number || ' - BEGIN publish lines AUTONOMOUS');
  END IF;

  v_batch_start := 1;
  IF (p_max_line_number < p_batch_size) THEN
    v_batch_end := p_max_line_number;
  ELSE
    v_batch_end := p_batch_size;
  END IF;

  WHILE (v_batch_start <= p_max_line_number) LOOP

      publish_lines(p_auction_header_id, p_bid_number, p_publish_date, p_tp_id,
                    p_auc_tp_id, p_surrog_bid_flag, p_rebid_flag, v_batch_start, v_batch_end);
      commit;

      IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
        print_log(l_api_name, p_bid_number || ' - publish lines: batch committed!');
      END IF;

      v_batch_start := v_batch_end + 1;
      IF (v_batch_end + p_batch_size > p_max_line_number) THEN
        v_batch_end := p_max_line_number;
      ELSE
        v_batch_end := v_batch_end + p_batch_size;
      END IF;
  END LOOP;

  IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
    print_log(l_api_name, p_bid_number || ' - END publish lines AUTONOMOUS');
  END IF;

END publish_lines_auto;

-- -------------------------------------------------------------------------
-- publish_cp
--
-- this is the concurrent program that will be called for super-large
-- negotiations.
-- -------------------------------------------------------------------------

PROCEDURE publish_cp
          (errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY VARCHAR2,
           p_auction_header_id IN NUMBER,
           p_bid_number IN NUMBER,
           p_rebid_flag IN VARCHAR2,
           p_publish_date IN VARCHAR2,
           p_date_mask IN VARCHAR2,
           p_tp_id IN NUMBER,
           p_tpc_id IN NUMBER,
           p_user_type IN VARCHAR2,
           p_user_id IN NUMBER)
IS
    v_request_id NUMBER;
    v_error_msg_name VARCHAR2(200);
    v_return_status NUMBER;
    v_return_code VARCHAR2(50);
    v_publish_date DATE;
    v_user_name VARCHAR2(50);

    l_api_name CONSTANT VARCHAR2(30) := 'publish_cp';

BEGIN

    retcode := '0';
    errbuf := '';
    v_request_id := FND_GLOBAL.CONC_REQUEST_ID();
    v_publish_date := to_date(p_publish_date, p_date_mask);

    SELECT user_name
    INTO v_user_name
    FROM fnd_user
    WHERE user_id = p_user_id;

    publish(p_auction_header_id, p_bid_number, p_rebid_flag,
            v_publish_date, p_tp_id, p_tpc_id, p_user_id, null,
            v_request_id, 'N', v_return_status, v_return_code);


    IF v_return_status = 0 OR v_return_status = 2 THEN
	    errbuf := 'PUBLISH_CP exited successfully';
        retcode := '0';

        -- clear out the request_id once this CP exits successfully.
        UPDATE pon_bid_headers
        SET request_id = null
        WHERE bid_number = p_bid_number;

        PON_WF_UTL_PKG.ReportConcProgramStatus (
            p_request_id => v_request_id,
            p_messagetype => 'S',
            p_RecepientUsername => v_user_name,
            p_recepientType =>p_user_type,
            p_auction_header_id => p_auction_header_id,
            p_ProgramTypeCode => 'BID_PUBLISH',
            p_DestinationPageCode => 'PONRESENQ_VIEWBID',
            p_bid_number => p_bid_number);

    -- if we have an error, then check
    -- what kind of errors they are.
    ELSIF v_return_status = g_return_error THEN

        -- if they're validation errors, the errors
        -- have been put into pon_interface_errors already
        IF v_return_code = 'VALIDATION_ERROR' THEN
            errbuf := 'PUBLISH_CP exited with validation errors';
            retcode := '2';

        -- if the error thrown is non-validation, we need to push
        -- that error into pon_interface_errors.  This error is most
        -- likely something updateAuctionInfo-related
        ELSE
            errbuf := 'PUBLISH_CP exited with publish errors';
            retcode := '2';

            -- insert the publish error into pon_interface_errors table
            get_message_name(v_return_code, p_auction_header_id, v_error_msg_name);

            INSERT INTO pon_interface_errors
            (bid_number, auction_header_id, interface_type, request_id,
             error_message_name, expiration_date)
            VALUES
            (p_bid_number, p_auction_header_id, 'PUBLISHBID', v_request_id,
             v_error_msg_name, sysdate+7);

        END IF;

        PON_WF_UTL_PKG.ReportConcProgramStatus (
            p_request_id => v_request_id,
            p_messagetype => 'E',
            p_RecepientUsername => v_user_name,
            p_recepientType =>p_user_type,
            p_auction_header_id => p_auction_header_id,
            p_ProgramTypeCode => 'BID_PUBLISH',
            p_DestinationPageCode => 'PON_CONCURRENT_ERRORS',
            p_bid_number => p_bid_number);

    END IF;

    commit;

EXCEPTION
    WHEN others THEN

      -- insert an error into the FND LOG as well
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
		  FND_LOG.string(log_level => FND_LOG.level_exception,
                         module    => g_module_prefix || l_api_name,
                         message   => 'SQL error code: ' || sqlcode || ', error message: ' || substr(sqlerrm,1,512));
		END IF;
      END IF;

      -- rollback anything that we can
      rollback;

      -- report error to the user through workflow notifications
      PON_WF_UTL_PKG.ReportConcProgramStatus (
        p_request_id => v_request_id,
        p_messagetype => 'E',
        p_RecepientUsername => v_user_name,
        p_recepientType =>p_user_type,
        p_auction_header_id => p_auction_header_id,
        p_ProgramTypeCode => 'BID_PUBLISH',
        p_DestinationPageCode => 'PON_CONCURRENT_ERRORS',
        p_bid_number => p_bid_number);

      IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
        print_log(l_api_name, 'Generating WF notif: ' || v_request_id || ' ' || v_user_name || ' ' || p_user_type || ' '||p_auction_header_id|| ' ' );
      END IF;

      -- insert an error indicating that a fatal error in the
      -- publish CP has occurred.
      get_message_name('FATAL_PUBLISH_ERROR', p_auction_header_id, v_error_msg_name);

      INSERT INTO pon_interface_errors
      (bid_number, auction_header_id, interface_type, request_id,
      error_message_name, expiration_date)
      VALUES
      (p_bid_number, p_auction_header_id, 'PUBLISHBID', v_request_id,
      v_error_msg_name, sysdate+7);

      -- insert an error into the FND LOG as well
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
		  FND_LOG.string(log_level => FND_LOG.level_exception,
                         module    => g_module_prefix || l_api_name,
                         message   => 'A fatal error has occurred during the concurrent processing of response publish for response number ' || p_bid_number);
		END IF;
      END IF;

      -- set bid header's bid_status to DRAFT
      UPDATE pon_bid_headers
      SET bid_status = 'DRAFT'
      WHERE bid_number = p_bid_number;

      -- commit the changes made here in the exception block
      commit;

END publish_cp;



-- -------------------------------------------------------------------------
-- validate_cp
--
-- this is the concurrent program that will be called for super-large
-- negotiations.
-- -------------------------------------------------------------------------


PROCEDURE validate_cp
          (errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY VARCHAR2,
           p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
           p_bid_number IN pon_bid_headers.bid_number%TYPE,
           p_user_type IN VARCHAR2,
           p_user_id IN NUMBER)
IS

    v_request_id NUMBER;
    v_subroutine_return_status NUMBER;
    v_subroutine_return_code VARCHAR2(30);
    v_user_name VARCHAR2(50);
    v_error_msg_name VARCHAR2(200);
    v_success_destination VARCHAR2(500);

    l_api_name CONSTANT VARCHAR2(30) := 'validate_cp';

BEGIN

    retcode := '0';
    errbuf := '';
    v_request_id := FND_GLOBAL.CONC_REQUEST_ID();

    SELECT user_name
    INTO v_user_name
    FROM fnd_user
    WHERE user_id = p_user_id;

    SELECT decode (nvl (surrog_bid_flag, 'N'), 'Y', 'PONENQMGDR_MANAGEDRAFT_SURROG', 'PONENQMGDR_MANAGEDRAFT')
    INTO v_success_destination
    FROM pon_bid_headers
    WHERE bid_number = p_bid_number;

    -- perform line-level validation.
    pon_bid_validations_pkg.validate_bid(p_auction_header_id, p_bid_number, 'VALIDATEBID', p_user_id, null, v_request_id, v_subroutine_return_status, v_subroutine_return_code);

    IF v_subroutine_return_status = g_return_success THEN
       -- according to ECO 4517992, we don't clear out the request_id
       -- except for publish bid

       PON_WF_UTL_PKG.ReportConcProgramStatus (
            p_request_id => v_request_id,
            p_messagetype => 'S',
            p_RecepientUsername => v_user_name,
            p_recepientType =>p_user_type,
            p_auction_header_id => p_auction_header_id,
            p_ProgramTypeCode => 'BID_VALIDATE',
            p_DestinationPageCode => v_success_destination,
            p_bid_number => p_bid_number);

       errbuf := 'VALIDATE_CP exited successfully';
       retcode := '0';
    ELSE

       PON_WF_UTL_PKG.ReportConcProgramStatus (
            p_request_id => v_request_id,
            p_messagetype => 'E',
            p_RecepientUsername => v_user_name,
            p_recepientType =>p_user_type,
            p_auction_header_id => p_auction_header_id,
            p_ProgramTypeCode => 'BID_VALIDATE',
            p_DestinationPageCode => 'PON_CONCURRENT_ERRORS',
            p_bid_number => p_bid_number);

       errbuf := 'VALIDATE_CP returned validation errors';
       retcode := '2';
    END IF;

    commit;


EXCEPTION
    WHEN others THEN

      -- insert an error into the FND LOG as well
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
		  FND_LOG.string(log_level => FND_LOG.level_exception,
                         module    => g_module_prefix || l_api_name,
                         message   => 'SQL error code: ' || sqlcode || ', error message: ' || substr(sqlerrm,1,512));
		END IF;
      END IF;


      -- rollback anything that we can
      rollback;

      -- report error to the user through workflow notifications
      PON_WF_UTL_PKG.ReportConcProgramStatus (
        p_request_id => v_request_id,
        p_messagetype => 'E',
        p_RecepientUsername => v_user_name,
        p_recepientType =>p_user_type,
        p_auction_header_id => p_auction_header_id,
        p_ProgramTypeCode => 'BID_VALIDATE',
        p_DestinationPageCode => 'PON_CONCURRENT_ERRORS',
        p_bid_number => p_bid_number);

      IF ((g_fnd_debug = 'Y') AND (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level)) THEN
        print_log(l_api_name, 'Generating WF notif: ' || v_request_id || ' ' || v_user_name || ' ' || p_user_type || ' '||p_auction_header_id|| ' ' );
      END IF;

      -- insert an error indicating that a fatal error in the
      -- publish CP has occurred.
      get_message_name('FATAL_VALIDATE_ERROR', p_auction_header_id, v_error_msg_name);

      INSERT INTO pon_interface_errors
      (bid_number, auction_header_id, interface_type, request_id,
      error_message_name, expiration_date)
      VALUES
      (p_bid_number, p_auction_header_id, 'VALIDATEBID', v_request_id,
      v_error_msg_name, sysdate+7);

      -- insert an error into the FND LOG as well
      IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
		  FND_LOG.string(log_level => FND_LOG.level_exception,
                         module    => g_module_prefix || l_api_name,
                         message   => 'A fatal error has occurred during the concurrent processing of response validation for response number ' || p_bid_number || '. See above for error details');
		END IF;
      END IF;

      -- commit the changes made here in the exception block
      commit;

END validate_cp;


-- -------------------------------------------------------------------------
-- get_message_name
--
-- called by publish_cp, this will return the message name to be inserted
-- into pon_interface_errors table
-- -------------------------------------------------------------------------

PROCEDURE get_message_name(p_msg_code IN VARCHAR2,
                           p_auction_header_id IN NUMBER,
                           x_msg_name OUT NOCOPY VARCHAR2)
IS

   v_suffix VARCHAR2(1);

   l_api_name CONSTANT VARCHAR2(30) := 'get_message_name';

BEGIN

   SELECT message_suffix
   INTO v_suffix
   FROM pon_auc_doctypes
   WHERE doctype_id = (SELECT doctype_id
                       FROM pon_auction_headers_all
                       WHERE auction_header_id = p_auction_header_id);

   IF p_msg_code = 'DISQ_REBID' THEN
      x_msg_name := 'PON_BID_DISQUALIFIED_REBID_' || v_suffix;
   ELSIF p_msg_code = 'MULTIPLE_REBID' THEN
      x_msg_name := 'PON_BID_MULTIPLE_REBID_' || v_suffix;
   ELSIF p_msg_code = 'MULTIPLE_DRAFTS' THEN
      x_msg_name := 'PON_BID_MULTIPLE_DRAFTS_' || v_suffix;
   ELSIF p_msg_code = 'SINGLE_BEST_BID' THEN
      x_msg_name := 'PON_AUC_BIDERROR_1_' || v_suffix;
   ELSIF p_msg_code = 'SINGLE_BEST_DRAFT' THEN
      x_msg_name := 'PON_AUC_BIDERROR_1_' || v_suffix;
   ELSIF p_msg_code = 'AUCTION_PAUSED' THEN
      x_msg_name := 'PON_AUC_PAUSED_DRAFT_' || v_suffix;
   ELSIF p_msg_code = 'BID_ON_CLOSED_LINE' THEN
      x_msg_name := 'PON_AUCTION_LINE_CLOSED_ERR_' || v_suffix;
   ELSIF p_msg_code = 'FATAL_PUBLISH_ERROR' THEN
      x_msg_name := 'PON_AUC_FATAL_BID_CP_PUB_ERR_' || v_suffix;
   ELSIF p_msg_code = 'FATAL_VALIDATE_ERROR' THEN
      x_msg_name := 'PON_AUC_FATAL_BID_CP_VAL_ERR_' || v_suffix;
   ELSE x_msg_name := '';
   END IF;

END get_message_name;

PROCEDURE get_user_lang_message (p_tpc_id IN NUMBER,
                                 p_message_name IN VARCHAR2,
                                 p_message_token1_name IN VARCHAR2,
                                 p_message_token1_value IN VARCHAR2,
                                 p_message_token2_name IN VARCHAR2,
                                 p_message_token2_value IN VARCHAR2,
                                 x_message_text OUT NOCOPY VARCHAR2)
IS

l_language_code FND_LANGUAGES.LANGUAGE_CODE%TYPE;
l_api_name CONSTANT VARCHAR2(30) := 'get_user_lang_message';
l_user_id FND_USER.USER_ID%TYPE;
BEGIN

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_procedure,
                   module    => g_module_prefix || l_api_name,
                   message   => 'Entered with p_tpc_id = ' || p_tpc_id ||
                                ', p_message_name = ' || p_message_name ||
                                ', p_message_token1_name = ' || p_message_token1_name ||
                                ', p_message_token1_value = ' || p_message_token1_value ||
                                ', p_message_token2_name = ' || p_message_token2_name ||
                                ', p_message_token2_value = ' || p_message_token2_value);
  END IF;

  SELECT
    FND_USER.user_id
  INTO
    l_user_id
  FROM
    FND_USER
  WHERE
    FND_USER.PERSON_PARTY_ID = p_tpc_id
    AND ROWNUM=1;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
                   module    => g_module_prefix || l_api_name,
                   message   => 'l_user_id = ' || l_user_id);
  END IF;

  PON_PROFILE_UTIL_PKG.GET_WF_LANGUAGE (l_user_id, l_language_code);

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
                   module    => g_module_prefix || l_api_name,
                   message   => 'l_language_code = ' || l_language_code);
  END IF;

  PON_AUCTION_PKG.SET_SESSION_LANGUAGE (null, l_language_code);
  x_message_text := PON_AUCTION_PKG.getMessage (
                                  msg => p_message_name,
                                  msg_suffix => '',
                                  token1 => p_message_token1_name,
                                  token1_value => p_message_token1_value,
                                  token2 => p_message_token2_name,
                                  token2_value => p_message_token2_value);

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
                   module    => g_module_prefix || l_api_name,
                   message   => 'x_message_text = ' || x_message_text);
  END IF;

  PON_AUCTION_PKG.UNSET_SESSION_LANGUAGE;

EXCEPTION WHEN OTHERS THEN
  x_message_text := '';
  PON_AUCTION_PKG.UNSET_SESSION_LANGUAGE;

END get_user_lang_message;

-- Begin Supplier Management: Supplier Evaluation

PROCEDURE calculate_avg_eval_scores(p_auction_header_id IN pon_auction_headers_all.auction_header_id%TYPE)
IS
BEGIN

IF (p_auction_header_id IS NOT NULL) THEN

  -- pbav1 - supplier response scores
  -- pbav2 - evaluation scores
  -- pbh1  - bid header for supplier response
  -- pbh2  - bid header for evaluation

  UPDATE pon_bid_attribute_values pbav1
  SET (pbav1.score, pbav1.weighted_score) =
      (SELECT AVG(pbav2.score) score,
              AVG(pbav2.score)*paa2.weight/paa2.attr_max_score weighted_score
       FROM pon_bid_attribute_values pbav2,
            pon_auction_attributes paa2
       WHERE pbav2.auction_header_id = p_auction_header_id
         AND pbav2.bid_number IN
             (SELECT pbh2.bid_number
              FROM pon_bid_headers pbh2, pon_bid_headers pbh3
              WHERE NVL(pbh2.evaluation_flag, 'N') = 'Y'
                AND pbh2.auction_header_id = p_auction_header_id
                AND pbh3.auction_header_id = p_auction_header_id
                AND pbh2.trading_partner_id = pbh3.trading_partner_id
                AND pbh2.bid_status = 'ACTIVE'
                AND pbh3.bid_number = pbav1.bid_number
             )
         AND pbav2.attribute_name = pbav1.attribute_name
         AND pbav2.auction_line_number = -1
         AND paa2.auction_header_id = p_auction_header_id
         AND paa2.attribute_name = pbav2.attribute_name
         AND paa2.internal_attr_flag = 'Y'
         AND paa2.line_number = -1
       GROUP BY paa2.weight,
                paa2.attr_max_score
      )
  WHERE pbav1.auction_header_id = p_auction_header_id
    AND pbav1.bid_number IN
        (SELECT pbh1.bid_number
         FROM pon_bid_headers pbh1
         WHERE pbh1.auction_header_id = p_auction_header_id
           AND NVL(pbh1.evaluation_flag, 'N') = 'N'
           AND pbh1.bid_status = 'ACTIVE'
           AND EXISTS (SELECT NULL
                       FROM pon_bid_headers pbh4
                       WHERE NVL(pbh4.evaluation_flag, 'N') = 'Y'
                         AND pbh4.auction_header_id = p_auction_header_id
                         AND pbh4.trading_partner_id = pbh1.trading_partner_id
                         AND pbh4.bid_status = 'ACTIVE'
                      )
        )
    AND pbav1.attribute_name IN
        (SELECT paa1.attribute_name
         FROM pon_auction_attributes paa1
         WHERE paa1.auction_header_id = p_auction_header_id
           AND paa1.internal_attr_flag = 'Y'
           AND paa1.line_number = -1
        )
    AND pbav1.auction_line_number = -1;

END IF;

END calculate_avg_eval_scores;

-- End Supplier Management: Supplier Evaluation

END PON_RESPONSE_PVT;

/
