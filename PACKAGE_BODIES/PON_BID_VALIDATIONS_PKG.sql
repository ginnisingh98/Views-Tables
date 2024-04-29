--------------------------------------------------------
--  DDL for Package Body PON_BID_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_BID_VALIDATIONS_PKG" AS
--$Header: PONBDVLB.pls 120.58.12010000.26 2015/08/25 08:55:20 irasoolm ship $

g_fnd_debug     CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_module_prefix CONSTANT VARCHAR2(35) := 'pon.plsql.bidValidationsPkg.';

g_exp_date			TIMESTAMP;
g_exp_days_offset	CONSTANT NUMBER := 7;

g_null_int        CONSTANT NUMBER	:= -9999;

g_number_mask       CONSTANT VARCHAR2(255) := '9999999999999999999999999999999999999999999999D9999999999999999';


PROCEDURE print_log
  (
    p_message IN VARCHAR2 )
IS

BEGIN
  IF(g_fnd_debug                = 'Y') THEN
    IF(FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level  => FND_LOG.level_statement, module => g_module_prefix, MESSAGE => p_message);
    END IF;
  END IF;
END print_log;

PROCEDURE check_and_correct_rate
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
        x_return_code   OUT NOCOPY VARCHAR2);

----------------------------------------------------------------
-- Formats the number based on the precision pased. If the    --
-- precision is passed as any then no formatting is done.     --
----------------------------------------------------------------
FUNCTION GET_MASK(p_precision in NUMBER) return VARCHAR2 is
    l_mask               varchar2(80);

BEGIN
	print_log('get_mask Start');
    -- precision is ANY
    if (p_precision = 10000) then
        l_mask := 'FM999G999G999G999G999G999G999G990D0999999999'; -- consider a big mask to accomodate big numbers
        return l_mask;
    elsif (p_precision = 0) then
        -- For 0 precision we need to hide the decimal seperator
        l_mask := 'FM999G999G999G999G999G999G999G999'; -- consider a big mask to accomodate big numbers
        return l_mask;
    else
        l_mask := 'FM999G999G999G999G999G999G999G990D'; -- consider a big mask to accomodate big numbers
        l_mask := rpad(l_mask, (length(l_mask) + p_precision), '0');
        return l_mask;
    end if;
END;

----------------------------------------------------------------
-- Formats the price passed based on the format passed.       --
-- If the price does have a decimal part then the decimal     --
-- separator will not be displayed. If the price is less      --
-- that 0 then 0 will be displayed before the decimal         --
-- separator                                                  --
----------------------------------------------------------------
FUNCTION FORMAT_PRICE
(     p_price in NUMBER,
      p_format_mask in VARCHAR2,
      p_precision IN NUMBER
) return VARCHAR2 is
      l_mask                     varchar2(80);
BEGIN
	print_log('FORMAT_PRICE Start');
    if (p_price is null) then
        return null;
    elsif ((ceil(p_price) - p_price) =0 and p_precision = 10000) then
        -- if price does not have decimal seperator and precision is 'Any' then
        --  the decimal will not be displayed
        l_mask := 'FM999G999G999G999G999G999G999G999'; -- consider a big mask to accomodate big numbers
     else
        l_mask := p_format_mask; -- consider the original mask
    end if;
	print_log('FORMAT_PRICE End: '||l_mask);
    return to_char(p_price,l_mask);

END;


-- ======================================================================
-- PROCEDURE:	VALIDATE_PRICE_PRECISION   PUBLIC
--  PARAMETERS:
--  p_number   			IN number to validate
--	p_precision			IN desired precision
--
--	RETURN: T if number's precision is within p_precision decimals. F if not
--
--  COMMENT: determines if number's precision is withint p_precision decimals
-- ======================================================================
FUNCTION validate_price_precision
(
	p_number			IN NUMBER,
	p_precision			IN NUMBER
) RETURN VARCHAR2 IS
BEGIN
	print_log('validate_price_precision Start');

	IF (p_number IS null) THEN
		RETURN 'T';
	END IF;

	IF p_precision = 10000
		OR (MOD(MOD(ABS(p_number), 1) * POWER(10, p_precision), 1) = 0) THEN
		RETURN 'T';
	ELSE
		RETURN 'F';
	END IF;

END validate_price_precision;

-- ======================================================================
-- PROCEDURE:	VALIDATE_CURRENCY_PRECISION   PUBLIC
--  PARAMETERS:
--  p_number   			IN number to validate
--	p_precision			IN desired precision
--
--	RETURN: T if number's precision is within p_precision decimals. F if not
--
--  COMMENT: determines if number's precision is withint p_precision decimals
-- ======================================================================
FUNCTION validate_currency_precision
(
	p_number			IN NUMBER,
	p_precision			IN NUMBER
) RETURN VARCHAR2 IS
BEGIN
	print_log('validate_currency_precision Start');
	IF (p_number IS null) THEN
		RETURN 'T';
	END IF;

	IF (MOD(MOD(ABS(p_number), 1) * POWER(10, p_precision), 1) = 0) THEN
		RETURN 'T';
	ELSE
		RETURN 'F';
	END IF;

END validate_currency_precision;




PROCEDURE populate_has_bid_changed_line
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_source_bid		IN pon_bid_item_prices.bid_number%TYPE,
	p_batch_id			IN pon_bid_item_prices.batch_id%TYPE,
    p_batch_start       IN NUMBER,
    p_batch_end         IN NUMBER,
	p_rebid_flag		IN VARCHAR2,
	p_blanket			IN VARCHAR2,
    p_use_batch_id      IN VARCHAR2,
	p_spreadsheet 		IN VARCHAR
) IS
BEGIN

    -- spreadsheet case:
	-- Blindly set has_bid_flag to Y for all bidded lines in the spreadsheet
	-- (any line with batch_id = p_batch_id will have a bid.)
	-- If rebid, then is_changed line logic will be run, so initialize
    -- it to 'N' for all lines
    -- If not rebid, then we won't be running the is_changed_line logic below
    -- so set the flag to 'Y' for all lines
    --
    -- online case:
    -- for power bidding, don't mess with has_bid_flag.
    -- since power bidding is always a rebid, we will always be
    -- initializing all is_changed_line_flag to 'N' and then selectively
    -- setting them to 'Y' with the is_changed_line logic below
	print_log('populate_has_bid_changed_line Start');
	print_log('	p_auc_header_id	= '||p_auc_header_id);
	print_log('p_bid_number	= '||p_bid_number);
	print_log('p_source_bid		= '||p_source_bid);
	print_log('p_batch_id		= '||p_batch_id);
    print_log('p_batch_start 	= '||p_batch_start);
    print_log('p_batch_end  	= '||p_batch_end);
	print_log('p_rebid_flag	= '||p_rebid_flag);
	print_log('p_blanket	= '||p_blanket);
    print_log('p_use_batch_id	= '||p_use_batch_id);
	print_log('p_spreadsheet	= '||p_spreadsheet);

    UPDATE pon_bid_item_prices bl
    SET bl.has_bid_flag = decode(p_use_batch_id, 'Y', 'Y', bl.has_bid_flag),
        bl.is_changed_line_flag = decode(p_rebid_flag, 'N', 'Y', 'N')
    WHERE bl.bid_number = p_bid_number
      AND ((p_use_batch_id = 'Y' AND bl.batch_id = p_batch_id)
           OR (p_use_batch_id = 'N'
               AND bl.line_number >= p_batch_start
               AND bl.line_number <= p_batch_end));

    -- no need to run the is_changed_line logic below
    -- if we're doing spreadsheet upload and this is not a rebid
	print_log('the is_changed_line logic below');
    IF (p_use_batch_id = 'Y' AND p_rebid_flag = 'N') THEN
      RETURN;
    END IF;

	UPDATE pon_bid_item_prices bl
	SET bl.is_changed_line_flag = 'Y'
	WHERE bl.bid_number = p_bid_number
		AND ((p_use_batch_id = 'Y' AND bl.batch_id = p_batch_id)
             OR (p_use_batch_id = 'N'
                 AND bl.line_number >= p_batch_start
                 AND bl.line_number <= p_batch_end))
		AND ((NVL(bl.bid_currency_unit_price, g_null_int) <> NVL(bl.old_bid_currency_unit_price, g_null_int)
			OR NVL(bl.bid_currency_price, g_null_int) <> NVL(bl.old_bid_currency_price, g_null_int)
			OR bl.proxy_bid_limit_price IS NOT NULL
				AND NVL(bl.bid_currency_limit_price, g_null_int) <> NVL(bl.old_bid_currency_limit_price, g_null_int)
      OR bl.promised_date IS NULL AND bl.old_promised_date IS NOT NULL
      OR bl.promised_date IS NOT NULL AND bl.old_promised_date IS NULL
      OR bl.promised_date <> bl.old_promised_date
			OR NVL(bl.po_bid_min_rel_amount, g_null_int) <> NVL(bl.old_po_bid_min_rel_amount, g_null_int)
			OR bl.note_to_auction_owner IS NULL AND bl.old_note_to_auction_owner IS NOT NULL
			OR bl.note_to_auction_owner IS NOT NULL AND bl.old_note_to_auction_owner IS NULL
			OR bl.note_to_auction_owner <> bl.old_note_to_auction_owner
			OR bl.old_quantity IS NOT NULL AND NVL(bl.quantity, g_null_int) <> bl.old_quantity
			OR NVL(bl.bid_curr_advance_amount, g_null_int)  <> NVL(bl.old_bid_curr_advance_amount, g_null_int)
			OR NVL(bl.recoupment_rate_percent, g_null_int)  <> NVL(bl.old_recoupment_rate_percent, g_null_int)
			OR NVL(bl.progress_pymt_rate_percent, g_null_int)  <> NVL(bl.old_progress_pymt_rate_percent, g_null_int)
			OR NVL(bl.retainage_rate_percent, g_null_int)  <> NVL(bl.old_retainage_rate_percent, g_null_int)
			OR NVL(bl.bid_curr_max_retainage_amt, g_null_int)  <> NVL(bl.old_bid_curr_max_retainage_amt, g_null_int)
			)

		OR (bl.has_attributes_flag = 'Y'
			AND EXISTS

			-- Check attributes
			(SELECT ba.line_number
			FROM pon_bid_attribute_values ba
			WHERE ba.bid_number = bl.bid_number
				AND ba.line_number = bl.line_number
        AND (ba.value IS NULL AND ba.old_value IS NOT NULL OR
             ba.value IS NOT NULL AND ba.old_value IS NULL OR
             ba.value <> ba.old_value)
				AND rownum = 1))

		OR EXISTS

			-- Check price factors
			(SELECT bpf.line_number
			FROM pon_bid_price_elements bpf
			WHERE bpf.bid_number = bl.bid_number
				AND bpf.line_number = bl.line_number
				AND bpf.pf_type = 'SUPPLIER'
				AND NVL(bpf.bid_currency_value, g_null_int) <> NVL(old_bid_currency_value, g_null_int)
				AND rownum = 1)
		OR EXISTS

			-- Check payments for xml spreadsheet upload case
			(SELECT bps.bid_line_number
			FROM pon_bid_payments_shipments bps
			WHERE p_spreadsheet = g_xml_upload_mode
			    AND bps.bid_number = bl.bid_number
				AND bps.bid_line_number = bl.line_number
				AND (NVL(bps.payment_display_number, g_null_int) <> NVL(old_payment_display_number, g_null_int)
    			OR bps.payment_type_code IS NULL AND bps.old_payment_type_code IS NOT NULL
	    		OR bps.payment_type_code IS NOT NULL AND bps.old_payment_type_code IS NULL
		    	OR bps.payment_type_code <> bps.old_payment_type_code
    			OR bps.payment_description IS NULL AND bps.old_payment_description IS NOT NULL
	    		OR bps.payment_description IS NOT NULL AND bps.old_payment_description IS NULL
		    	OR bps.payment_description <> bps.old_payment_description
				OR NVL(bps.quantity, g_null_int) <> NVL(old_quantity, g_null_int)
				OR NVL(bps.uom_code, g_null_int) <> NVL(old_uom_code, g_null_int)
				OR NVL(bps.bid_currency_price, g_null_int) <> NVL(old_bid_currency_price, g_null_int)
                OR bps.promised_date IS NULL AND bps.old_promised_date IS NOT NULL
                OR bps.promised_date IS NOT NULL AND bps.old_promised_date IS NULL
                OR bps.promised_date <> bps.old_promised_date)
				AND rownum = 1)

			-- Check if any payments were deleted
		OR (nvl(bl.old_no_of_payments,0) <> (select count(payment_display_number)
                                      from pon_bid_payments_shipments bps
                                      where bps.bid_number = bl.bid_number
                                      and bps.bid_line_number = bl.line_number))

		OR ( (bl.has_shipments_flag = 'Y' or bl.has_quantity_tiers = 'Y')
			AND EXISTS

			-- Check shipments
			-- If auction_shipment_number is null then it is user defined
			-- so we must check all possible values that can be changed
			(SELECT bpb.line_number
			FROM pon_bid_shipments bpb
			WHERE bpb.bid_number = bl.bid_number
				AND bpb.line_number = bl.line_number
				AND (bpb.auction_shipment_number IS null
					AND (NVL(bpb.ship_to_organization_id, g_null_int) <> NVL(bpb.old_ship_to_org_id, g_null_int)
						OR NVL(bpb.ship_to_location_id, g_null_int) <> NVL(bpb.old_ship_to_loc_id, g_null_int)
						OR bpb.effective_start_date IS NULL AND bpb.old_effective_start_date IS NOT NULL
						OR bpb.effective_start_date IS NOT NULL AND bpb.old_effective_start_date IS NULL
						OR bpb.effective_start_date <> bpb.old_effective_start_date
						OR bpb.effective_end_date IS NULL AND bpb.old_effective_end_date IS NOT NULL
						OR bpb.effective_end_date IS NOT NULL AND bpb.old_effective_end_date IS NULL
						OR bpb.effective_end_date <> bpb.old_effective_end_date
						OR NVL(bpb.quantity, g_null_int) <> NVL(bpb.old_quantity, g_null_int)
						OR NVL(bpb.max_quantity, g_null_int) <> NVL(bpb.old_max_quantity, g_null_int)
						OR bpb.price_type IS NULL AND bpb.old_price_type IS NOT NULL
						OR bpb.price_type IS NOT NULL AND bpb.old_price_type IS NULL
						OR bpb.price_type <> bpb.old_price_type)
					OR bpb.price_type = 'PRICE' AND NVL(bpb.bid_currency_unit_price, g_null_int) <> NVL(bpb.old_bid_currency_unit_price, g_null_int)
					OR bpb.price_type = 'PRICE DISCOUNT' AND NVL(bpb.price_discount, g_null_int) <> NVL(bpb.old_price_discount, g_null_int)
					OR NVL(bpb.bid_currency_price, g_null_int) <> NVL(bpb.old_bid_currency_price, g_null_int))
				AND rownum = 1))

		OR (bl.has_price_differentials_flag = 'Y'
			AND EXISTS

			-- Check price differentials, including shipment price differentials
			(SELECT bpd.line_number
			FROM pon_bid_price_differentials bpd
			WHERE bpd.bid_number = bl.bid_number
				AND bpd.line_number = bl.line_number
				AND NVL(bpd.multiplier, g_null_int) <> NVL(bpd.old_multiplier, g_null_int)
				AND rownum = 1))
			);


    -- process groups
    -- when a group line has been changed, change the group too.
    UPDATE pon_bid_item_prices pbip
    SET pbip.is_changed_line_flag = 'Y'
    WHERE pbip.bid_number = p_bid_number
      AND pbip.line_number IN
                         (SELECT al.parent_line_number
                          FROM pon_bid_item_prices bl,
                               pon_auction_item_prices_all al
                          WHERE bl.bid_number = p_bid_number
                            AND bl.auction_header_id = al.auction_header_id
                            AND bl.line_number = al.line_number
                            AND al.group_type = 'GROUP_LINE'
                            AND bl.is_changed_line_flag = 'Y'
                            AND ((p_use_batch_id = 'Y' AND bl.batch_id = p_batch_id)
                                 OR (p_use_batch_id = 'N'
                                     AND bl.line_number >= p_batch_start
                                     AND bl.line_number <= p_batch_end)));





	-- We need some special checks for price breaks because
	-- a user could have added or removed them.
	-- Only consider the case of a rebid where the line had a previous bid
	-- and only for blanket agreements.

	-- Check all unmodified lines against source_bid if the source_bid is valid
	IF (p_spreadsheet = g_xml_upload_mode and p_blanket = 'Y' AND p_rebid_flag = 'Y' AND p_source_bid > 0) THEN

		UPDATE pon_bid_item_prices bl
		SET bl.is_changed_line_flag = 'Y'
		WHERE bl.bid_number = p_bid_number
			AND bl.batch_id = p_batch_id
			AND (EXISTS

				-- Check if a shipment was deleted
				(SELECT old_bpb.line_number
				FROM pon_bid_shipments bpb, pon_bid_shipments old_bpb
				WHERE old_bpb.bid_number = p_source_bid
					AND old_bpb.line_number = bl.line_number
					AND bpb.bid_number (+) = p_bid_number
					AND bpb.line_number (+) = old_bpb.line_number
					AND bpb.shipment_number (+) = old_bpb.shipment_number
					AND bpb.shipment_number IS null
					AND rownum = 1)

				OR EXISTS

				-- Check if a shipment was added
				(SELECT bpb.line_number
				FROM pon_bid_shipments bpb, pon_bid_shipments old_bpb
				WHERE bpb.bid_number = p_bid_number
					AND bpb.line_number = bl.line_number
					AND old_bpb.bid_number (+) = p_source_bid
					AND old_bpb.line_number (+) = bpb.line_number
					AND old_bpb.shipment_number (+) = bpb.shipment_number
					AND old_bpb.shipment_number IS null
					AND rownum = 1)
				);
	END IF;
	print_log('populate_has_bid_changed_line End');

END populate_has_bid_changed_line;

-- wrapper for spreadsheet case
PROCEDURE populate_has_bid_changed_line
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_source_bid		IN pon_bid_item_prices.bid_number%TYPE,
	p_batch_id			IN pon_bid_item_prices.batch_id%TYPE,
	p_rebid_flag		VARCHAR2,
	p_blanket			VARCHAR2,
	p_spreadsheet		IN VARCHAR2
)
IS
BEGIN
  print_log('populate_has_bid_changed_line Start');
  populate_has_bid_changed_line(p_auc_header_id, p_bid_number, p_source_bid,
                                p_batch_id, -1, -1, p_rebid_flag, p_blanket,
                                'Y', p_spreadsheet);
  print_log('populate_has_bid_changed_line End');
END populate_has_bid_changed_line;


-- wrapper for online case
PROCEDURE populate_has_bid_changed_line
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_source_bid		IN pon_bid_item_prices.bid_number%TYPE,
    p_batch_start       IN NUMBER,
    p_batch_end         IN NUMBER,
	p_rebid_flag		IN VARCHAR2,
	p_blanket			IN VARCHAR2,
    p_use_batch_id      IN VARCHAR2
) IS
BEGIN
  print_log('populate_has_bid_changed_line Start');
  populate_has_bid_changed_line(p_auc_header_id, p_bid_number, p_source_bid,
                                -1, p_batch_start, p_batch_end, p_rebid_flag,
                                p_blanket, 'N', g_online_mode);
  print_log('populate_has_bid_changed_line End');
END populate_has_bid_changed_line;



PROCEDURE calc_total_weighted_score
(
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_batch_id			IN pon_bid_item_prices.batch_id%TYPE
) IS
BEGIN
  print_log('calc_total_weighted_score Start');
	-- First populate the score for each attribute
	-- The match we make is dependent on the attributes datatype
	--   TXT - we match value against value
	--   NUM - we check value between from_range and to_range,
	--         converting varchar to number first
	--   DAT - we check value between from_range and to_range,
	--         converting varchar to date first (timestamp for need_by_date)
	UPDATE pon_bid_attribute_values ba
	SET ba.score =
		nvl((SELECT s.score
		FROM pon_attribute_scores s
		WHERE s.auction_header_id = ba.auction_header_id
			AND s.line_number = ba.line_number
			AND s.attribute_sequence_number = ba.sequence_number
			AND (datatype = 'TXT' AND ba.value = s.value
				OR datatype = 'NUM' AND to_number(ba.value, g_number_mask, 'NLS_NUMERIC_CHARACTERS=''.,''')
					BETWEEN to_number(nvl(s.from_range, ba.value), g_number_mask, 'NLS_NUMERIC_CHARACTERS=''.,''')
					AND to_number(nvl(s.to_range, ba.value), g_number_mask, 'NLS_NUMERIC_CHARACTERS=''.,''')
				OR datatype = 'DAT'
					AND (ba.sequence_number = -10 AND
						to_date(ba.value, 'dd-mm-yyyy hh24:mi:ss') BETWEEN
							to_date(nvl(s.from_range, ba.value), 'dd-mm-yyyy hh24:mi:ss')
							AND to_date(nvl(s.to_range, ba.value), 'dd-mm-yyyy hh24:mi:ss')
						OR ba.sequence_number <> -10 AND
						to_date(ba.value, 'dd-mm-yyyy') BETWEEN
							to_date(nvl(s.from_range, ba.value), 'dd-mm-yyyy')
							AND to_date(nvl(s.to_range, ba.value), 'dd-mm-yyyy')))),
			nvl2(ba.value, 0, null))
	WHERE ba.bid_number = p_bid_number
		AND EXISTS (SELECT bl.line_number
					FROM pon_bid_item_prices bl
					WHERE bl.bid_number = p_bid_number
						AND bl.line_number = ba.line_number
						AND bl.batch_id = p_batch_id);


        UPDATE pon_bid_attribute_values ba
        SET ba.weighted_score =
                (SELECT decode(nvl(aa.scoring_type, 'NONE'),
                                        'NONE', null,
                                        aa.weight / 100.0 * nvl(ba.score, 0))
                FROM pon_auction_attributes aa
                WHERE aa.auction_header_id = ba.auction_header_id
                        AND aa.line_number = ba.line_number
                        AND aa.sequence_number = ba.sequence_number)
        WHERE ba.bid_number = p_bid_number
                AND EXISTS (SELECT bl.line_number
                                        FROM pon_bid_item_prices bl
                                        WHERE bl.bid_number = p_bid_number
                                                AND bl.line_number = ba.line_number
                                                AND bl.batch_id = p_batch_id);


	-- Conditions to check with total_weighted_score:
	--   If there were no scored attributes, set to 100.
	--   If there was a scored attribute that didn't recieve a bid, set to null
	--   Ignore all unscored (weight not > 0) attributes
	--   LOGIC: decode(# scored attr,
	--				null, if line has bid then 100 else null,
	--				0, if line has bid then 100 else null,
	--				# scored attr with bids,
	--				score, null)

	UPDATE pon_bid_item_prices bl
	SET bl.total_weighted_score =
		(SELECT decode(sum(sign(aa.weight)),
					null, decode(bl.has_bid_flag, 'Y', 100, null),
					0, decode(bl.has_bid_flag, 'Y', 100, null),
					sum(decode(sign(aa.weight), 1, nvl2(ba.value, 1, 0), 0)),
					sum(aa.weight / 100.0 * nvl(ba.score, 0)), null)
		FROM pon_bid_attribute_values ba, pon_auction_attributes aa
		WHERE ba.bid_number = bl.bid_number
			AND ba.line_number = bl.line_number
			AND aa.auction_header_id = ba.auction_header_id
			AND aa.line_number = ba.line_number
			AND aa.sequence_number = ba.sequence_number)
	WHERE bl.bid_number = p_bid_number
		AND bl.batch_id = p_batch_id;
  print_log('calc_total_weighted_score End');
END calc_total_weighted_score;

PROCEDURE validate_bids_placed
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_rebid				IN VARCHAR2,
	p_bid_all_lines		IN VARCHAR2,
	p_auc_has_items		IN VARCHAR2,
	p_evaluation_flag		IN VARCHAR2,    -- Added for ER: Supplier Management: Supplier Evaluation
	p_suffix			IN VARCHAR2,
	p_batch_id			IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE
) IS
	l_header_modified	VARCHAR2(1);
BEGIN
  print_log('validate_bids_placed Start');
	-- Determine if the bid header was modified
	SELECT decode(count(bh.bid_number), 0, 'N', 'Y')
	INTO l_header_modified
	FROM pon_bid_headers bh
	WHERE bh.bid_number = p_bid_number
		AND ((bh.old_note_to_auction_owner IS null
					AND bh.note_to_auction_owner IS NOT null
				OR bh.old_note_to_auction_owner IS NOT null
					AND bh.note_to_auction_owner IS null
				OR bh.old_note_to_auction_owner <> bh.note_to_auction_owner)
			OR nvl(bh.old_bidders_bid_number, -1) <> nvl(bh.bidders_bid_number, -1)
			OR (bh.old_bid_expiration_date IS null
					AND bh.bid_expiration_date IS NOT null
				OR bh.old_bid_expiration_date IS NOT null
					AND bh.bid_expiration_date IS null
				OR bh.old_bid_expiration_date <> bh.bid_expiration_date)
			OR nvl(bh.old_min_bid_change, -1) <> nvl(bh.min_bid_change, -1)
			-- surrog bid receipt date must be non-null if surrogate bid
			OR bh.surrog_bid_flag = 'Y'
				AND bh.old_surrog_bid_receipt_date <> bh.surrog_bid_receipt_date
			-- Check if a header attribute was modified
			OR EXISTS
				(SELECT null
				FROM pon_bid_attribute_values ba
				WHERE ba.bid_number = p_bid_number
					AND ba.line_number = -1
					AND (ba.old_value <> ba.value
						OR ba.old_value IS null AND ba.value IS NOT null
						OR ba.value IS null AND ba.old_value IS NOT null)));

	INSERT FIRST

		-- When rebidding, the header or one line must be changed
		WHEN p_rebid = 'Y' AND l_header_modified = 'N' AND s_changed_line_count = 0 THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				EXPIRATION_DATE)
			VALUES
				(p_interface_type,
				'PON_BID_HEADERS',
				p_batch_id,
				'PON_BID_NO_CHANGES',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				p_auc_header_id,
				p_bid_number,
				g_exp_date)

		-- All lines must have recieved a bid if that is a requirement
		-- Added the p_evaluation_flag condition for ER: Supplier Management: Supplier Evaluation
		WHEN p_bid_all_lines = 'Y' AND s_avail_bidded_lines <> s_bidded_lines AND p_evaluation_flag = 'N' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				EXPIRATION_DATE)
			VALUES
				(p_interface_type,
				'PON_BID_HEADERS',
				p_batch_id,
				'PON_MUST_BIDALL_ITEMS' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				p_auc_header_id,
				p_bid_number,
				g_exp_date)

		-- At least one line must have recieved a bid if the auction has lines
		-- Added the p_evaluation_flag condition for ER: Supplier Management: Supplier Evaluation
                /* modified for bug#12920874 : As this is a generic validation that should be fired at any stage of
                   rounds of bidding, removing bidding flag(p_rebid) from the condition */
		-- WHEN p_rebid = 'N' AND p_auc_has_items = 'Y' AND s_has_bid_count = 0 AND p_evaluation_flag = 'N' THEN
                WHEN p_auc_has_items = 'Y' AND s_has_bid_count = 0 AND p_evaluation_flag = 'N' THEN
                /* modified for bug#12920874 */
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				EXPIRATION_DATE)
			VALUES
				(p_interface_type,
				'PON_BID_HEADERS',
				p_batch_id,
				'PON_MUST_BID_ATLEAST_ONE' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				p_auc_header_id,
				p_bid_number,
				g_exp_date)

	SELECT
		count(bl.line_number) s_line_count,
    -- modified by Allen Yang for surrogate bid bug #7703665, #8220778 2009/02/03
    ----------------------------------------------------------------------------
		---sum(decode(bl.has_bid_flag, 'Y', 1, 0)) s_has_bid_count,
    /* bug#10221791 changes for two part RFQ surrogate bid*/
	sum(decode(bl.has_bid_flag, 'Y', 1,
            decode(NVL(paha.Two_Part_Flag, 'N'), 'Y',
            decode(NVL(paha.TECHNICAL_EVALUATION_STATUS, 'NOT_COMPLETED'), 'NOT_COMPLETED',
            decode(NVL(pbh.surrog_bid_flag, 'N'), 'Y',
            decode(NVL(paha.FULL_QUANTITY_BID_CODE, 'FULL_QTY_BIDS_REQD'), 'FULL_QTY_BIDS_REQD', 1,
            Decode( Decode(paip.order_type_lookup_code,'QUANTITY','Y','N'),'N',1,
            Decode( Decode(paha.contract_type,'STANDARD','Y','N'),'N',1,
             0))), 0), 0), 0))) s_has_bid_count,
		sum(decode(bl.is_changed_line_flag, 'Y', 1, 0)) s_changed_line_count,
    sum(decode(paip.group_type, 'LINE', 1, 'LOT', 1, 'GROUP_LINE', 1, 0)) s_avail_bidded_lines,
    --sum(decode(bl.has_bid_flag, 'Y', decode(paip.group_type, 'LINE', 1, 'LOT', 1, 'GROUP_LINE', 1, 0), 0)) s_bidded_lines
    /* bug#10221791 changes for two part RFQ surrogate bid*/
	sum(decode(bl.has_bid_flag, 'Y',
                      decode(paip.group_type, 'LINE', 1, 'LOT', 1, 'GROUP_LINE', 1, 0),

                         decode(NVL(paha.Two_Part_Flag, 'N'), 'Y',
                         decode(NVL(paha.TECHNICAL_EVALUATION_STATUS, 'NOT_COMPLETED'), 'NOT_COMPLETED',
                         decode(NVL(pbh.surrog_bid_flag, 'N'), 'Y',
                         decode(NVL(paha.FULL_QUANTITY_BID_CODE, 'FULL_QTY_BIDS_REQD'), 'FULL_QTY_BIDS_REQD',1,
                         Decode( Decode(paip.order_type_lookup_code,'QUANTITY','Y','N'),'N',1,
                         Decode( Decode(paha.contract_type,'STANDARD','Y','N'),'N',1,
                         0))), 0), 0), 0))) s_bidded_lines
    ----------------------------------------------------------------------------
        FROM pon_bid_item_prices bl,
             pon_auction_item_prices_all paip
             -- added by Allen Yang for surrogate bid bug 7703665, #8220778 2009/02/03
             ---------------------------------------------------------------
             , pon_auction_headers_all paha,
               pon_bid_headers pbh
             ---------------------------------------------------------------
	WHERE bl.bid_number = p_bid_number and
              bl.auction_header_id = paip.auction_header_id and
              bl.line_number = paip.line_number
              -- added by Allen Yang for surrogate bid bug 7703665, #8220778 2009/02/03
             ---------------------------------------------------------------
              and bl.bid_number = pbh.bid_number
              and pbh.auction_header_id = paha.auction_header_id
             ---------------------------------------------------------------
              ;
  print_log('validate_bids_placed End');
END validate_bids_placed;

PROCEDURE validate_lots_and_groups
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_spreadsheet		IN VARCHAR2,
	p_batch_id			IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE
) IS
BEGIN
  print_log('validate_lots_and_groups Start');
	INSERT ALL

		-- All lines in a GROUP must be bid on simultaneously
		WHEN s_group_type = 'GROUP' AND
			(SELECT decode(sum(decode(bl.has_bid_flag, 'Y', 1, 0)), 0, 'OK',
				count(bl.bid_number), 'OK', 'N')
			FROM pon_bid_item_prices bl, pon_auction_item_prices_all al
			WHERE bl.bid_number = p_bid_number
				AND al.auction_header_id = bl.auction_header_id
				AND al.line_number = bl.line_number
				AND al.auction_header_id = p_auc_header_id
				AND al.parent_line_number = s_line_number) = 'N' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_GROUP_PARTIAL_BID_ERR',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- If a lot has no bid, none of it's children can be bid on
		WHEN s_group_type = 'LOT' AND s_has_bid_flag = 'N' AND EXISTS
			(SELECT bl.bid_number
			FROM pon_bid_item_prices bl, pon_auction_item_prices_all al
			WHERE bl.bid_number = p_bid_number
				AND al.auction_header_id = bl.auction_header_id
				AND al.line_number = bl.line_number
				AND al.auction_header_id = p_auc_header_id
				AND al.parent_line_number = s_line_number
				AND bl.has_bid_flag = 'Y'
				AND rownum = 1) THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_LOT_NOT_BID_ERR',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)
	SELECT
		bl.line_number s_line_number,
		bl.has_bid_flag s_has_bid_flag,
		decode(p_spreadsheet, 	g_txt_upload_mode, bl.interface_line_id,
					g_xml_upload_mode, bl.interface_line_id,
					to_number(null)) s_interface_line_id,
		al.group_type s_group_type,
		al.document_disp_line_number s_document_disp_line_number,
		decode(p_spreadsheet, 	g_xml_upload_mode, bl.worksheet_name,
					to_char(null)) s_worksheet_name,
		decode(p_spreadsheet, 	g_xml_upload_mode, bl.worksheet_sequence_number,
					to_number(null)) s_worksheet_sequence_number,
		decode(p_spreadsheet, g_xml_upload_mode, 'PON_AUC_ITEMS', to_char(null)) s_entity_message_code
	FROM pon_bid_item_prices bl
             , pon_auction_item_prices_all al
             , pon_bid_headers pbh
	WHERE bl.bid_number = p_bid_number
		AND al.auction_header_id = bl.auction_header_id
		AND al.line_number = bl.line_number
		AND al.auction_header_id = p_auc_header_id
		AND al.group_type IN ('GROUP', 'LOT')
		AND (p_spreadsheet = g_online_mode OR bl.batch_id = p_batch_id)
                AND pbh.bid_number = bl.bid_number
                AND (pbh.SURROG_BID_FLAG = 'Y' OR nvl(al.close_bidding_date, sysdate+1) > sysdate);
  print_log('validate_lots_and_groups End');
END validate_lots_and_groups;

PROCEDURE validate_lines
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_tpid				IN pon_bid_headers.trading_partner_id%TYPE,
	p_vensid			IN pon_bid_headers.vendor_site_id%TYPE,
	p_spreadsheet		IN VARCHAR2,
	p_blanket			IN VARCHAR2,
	p_global			IN VARCHAR2,
	p_trans_view		IN VARCHAR2,
	p_rebid				IN VARCHAR2,
	p_full_qty_reqd		IN VARCHAR2,
	p_header_disp_pf	IN VARCHAR2,
	p_price_driven		IN VARCHAR2,
	p_percent_decr		IN VARCHAR2,
    p_bid_decr_method   IN pon_auction_headers_all.bid_decrement_method%TYPE,
	p_min_bid_decr		IN pon_auction_headers_all.min_bid_decrement%TYPE,
	p_min_bid_change	IN pon_bid_headers.min_bid_change%TYPE,
    p_rate              IN pon_bid_headers.rate%TYPE,
	p_price_precision	IN pon_bid_headers.number_price_decimals%TYPE,
	p_amt_precision		IN fnd_currencies.precision%TYPE,
	p_bid_curr_code  	IN pon_bid_headers.bid_currency_code%TYPE,
	p_suffix			IN VARCHAR2,
	p_batch_id			IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE
  --added by Allen Yang for Surrogate Bid 2008/09/03
  --------------------------------------------------
  , p_two_part_tech_surrogate_flag IN VARCHAR2
  --------------------------------------------------
) IS

    l_price_mask        VARCHAR2(80);
BEGIN
	  print_log('validate_lines Start');
  	  print_log('p_auc_header_id '||p_auc_header_id);
	  print_log('p_bid_number '||p_bid_number);
	  print_log('p_interface_type '||p_interface_type);
	  print_log('p_userid '||p_userid);
	  print_log('p_tpid	 '||p_tpid);
	  print_log('p_vensid '||p_vensid);
	  print_log('p_spreadsheet '||p_spreadsheet);
	  print_log('p_blanket '||p_blanket);
	  print_log('p_global '||p_global);
	  print_log('p_trans_view '||p_trans_view);
	  print_log('p_rebid '||p_rebid);
	  print_log('p_full_qty_reqd '||p_full_qty_reqd);
	  print_log('p_header_disp_pf '||p_header_disp_pf);
	  print_log('p_price_driven '||p_price_driven);
	  print_log('p_percent_decr	 '||p_percent_decr);
      print_log('p_bid_decr_method  '||p_bid_decr_method);
	  print_log('p_min_bid_decr '||p_min_bid_decr);
	  print_log('p_min_bid_change '||p_min_bid_change);
      print_log('p_rate  '||p_rate);
	  print_log('p_price_precision '||p_price_precision);
	  print_log('p_amt_precision '||p_amt_precision);
	  print_log('p_bid_curr_code  '||p_bid_curr_code);
	  print_log('p_suffix '||p_suffix);
	  print_log('p_batch_id	 '||p_batch_id);
	  print_log('p_request_id '||p_request_id);
    -- get the price mask according to price precision
    l_price_mask := get_mask(p_price_precision);

	-- STEP 1: pre-release 12 validations.
    -- currently 26 validations. This statement has 1-13.
	INSERT ALL

		-- Header level field min_bid_change is required if there is a proxy line
		WHEN p_min_bid_change IS null AND s_proxy_bid_limit_price IS NOT null THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				decode(p_spreadsheet, g_xml_upload_mode,
					fnd_message.get_string('PON', 'PON_AUCTS_MIN_BID_DEC' || p_suffix),
					fnd_message.get_string('PON', 'PON_AUCTS_MIN_BID_PRICE')),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_AUCTS_MIN_DEC_NULL' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'ProxyBidLimitPrice',
				s_proxy_bid_limit_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)
		-- Price and quantity are required fields if they are editable
		WHEN p_blanket = 'N' AND s_price_editable = 'Y' AND s_price IS null
			AND s_qty_editable = 'Y' AND s_bid_quantity IS null
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_BID_PRICE_QTY_REQD' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'Price',
				'TXT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- Price is a required field if it is editable
		WHEN s_price_editable = 'Y' AND s_price IS null
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_ITEM_PRICES',
				fnd_message.get_string('PON', 'PON_AUCTS_BID_PRICE' || p_suffix),
				p_batch_id,
				s_interface_line_id,
				'PON_BID_PRICE_REQUIRED' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'Price',
				'TXT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- Quantity is a required field if it is editable
		WHEN p_blanket = 'N' AND s_qty_editable = 'Y' AND s_bid_quantity IS null THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_ITEM_PRICES',
				fnd_message.get_string('PON', 'PON_AUCTS_BID_QTY' || p_suffix),
				p_batch_id,
				s_interface_line_id,
				'PON_BID_QUANTITY_REQUIRED' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'Quantity',
				'TXT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- Bug 7460446 Bid cannot be zero or negative
		-- Doesn't apply for blanket agreements
		WHEN p_blanket = 'N' AND s_bid_quantity <= 0 THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_BID_QTY' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_BIDQTY_NEG' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'Quantity',
				s_bid_quantity,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- Bid quantity should not exceed auction quantity
		-- Does not apply for blanket agreements
		WHEN p_blanket = 'N' AND s_bid_quantity > s_auc_quantity THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_BID_QTY' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_INVALID_BID_QTY' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'Quantity',
				s_bid_quantity,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- If the need_by_date is scored, then promised date is required
		-- Does not apply for blanket agreements
		WHEN p_blanket = 'N' AND s_need_by_date_scored = 'Y'
			AND s_promised_date IS null
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_PROMISED_DATE'),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PROMISED_DATE_REQ',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'PromisedDate',
				'TXT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- The promised date cannot be earlier than the current date
		-- Does not apply to blanket agreements
		WHEN p_blanket = 'N' AND s_promised_date < s_current_date
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_PROMISED_DATE'),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PDATE_TOO_EARLY',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'PromisedDate',
				s_promised_date,
				'DAT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- po_bid_min_rel_amount should not be negative
		WHEN p_blanket = 'Y' AND s_po_bid_min_rel_amount < 0 THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUC_BID_MIN_REL_AMOUNT' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_MINREL_POS_ZERO' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'PoBidMinRelAmount',
				s_po_bid_min_rel_amount,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- po_bid_min_rel_amount should not exceed currency precision
		WHEN p_blanket = 'Y' AND validate_currency_precision(
			s_po_bid_min_rel_amount, p_amt_precision) = 'F' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUC_BID_MIN_REL_AMOUNT' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_MINREL_MIN_PREC' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'PoBidMinRelAmount',
				s_po_bid_min_rel_amount,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- bid_currency_unit_price should be positive
		-- bid_currency_unit_price only validated when header disp_pf_flag is Y
		-- Suppress error if spreadsheet case and no price factors
		WHEN p_header_disp_pf = 'Y' AND s_bid_currency_unit_price <= 0
			AND (p_spreadsheet = g_online_mode OR s_display_price_factors_flag = 'Y')
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTION_ITEM_PRICE' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_LINEPRICE_MUST_BE_POS',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'BidCurrencyUnitPrice',
				s_bid_currency_unit_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- bid_currency_unit_price precision should not exceed price precision
		-- as part of bug 14657112, removed the condition checking
		-- whether price factors are displayed.
		-- Precision should be checked in any case
		WHEN  validate_price_precision(
			s_bid_currency_unit_price, p_price_precision) = 'F'
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTION_ITEM_PRICE' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_LINEPRICE_MIN_PREC' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'BidCurrencyUnitPrice',
				s_bid_currency_unit_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- If the line has price factors, the line price is required
		WHEN s_display_price_factors_flag = 'Y'
			AND s_bid_currency_unit_price IS null
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_BID_PRICE' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_BID_PRICE_REQUIRED' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'BidCurrencyUnitPrice',
				'TXT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)
    SELECT
		sysdate s_current_date,
		decode(al.price_disabled_flag, 'Y', 'N',
			decode(bl.display_price_factors_flag, 'Y', 'N',
				decode(al.group_type, 'GROUP', 'N', 'Y'))) s_price_editable,
		decode(p_full_qty_reqd, 'Y', 'N',
			decode(al.quantity_disabled_flag, 'Y', 'N',
				decode(al.group_type, 'GROUP', 'N',
					decode(al.order_type_lookup_code, 'AMOUNT', 'N',
						'RATE', 'N', 'FIXED PRICE', 'N', 'Y')))) s_qty_editable,
		bl.quantity s_bid_quantity,
		bl.promised_date s_promised_date,
		bl.bid_currency_unit_price s_bid_currency_unit_price,
		bl.price s_price,
		bl.po_bid_min_rel_amount s_po_bid_min_rel_amount,
		bl.proxy_bid_limit_price s_proxy_bid_limit_price,
		bl.display_price_factors_flag s_display_price_factors_flag,
		al.is_need_by_date_scored s_need_by_date_scored,
		al.quantity s_auc_quantity,
		bl.line_number s_line_number,
		decode(p_spreadsheet, g_xml_upload_mode, bl.interface_line_id,
				      g_txt_upload_mode, bl.interface_line_id,
				      to_number(null)) s_interface_line_id,
		al.document_disp_line_number s_document_disp_line_number,
		decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_name, to_char(null)) s_worksheet_name,
		decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_sequence_number, to_number(null))	s_worksheet_sequence_number,
		decode(p_spreadsheet, g_xml_upload_mode, 'PON_AUC_ITEMS', to_char(null)) s_entity_message_code
	FROM pon_auction_item_prices_all al
             , pon_bid_item_prices bl
             , pon_bid_headers pbh
	WHERE al.auction_header_id = p_auc_header_id
		AND bl.bid_number = p_bid_number
		AND al.line_number = bl.line_number
		AND bl.is_changed_line_flag = 'Y'
		AND (p_spreadsheet = g_online_mode OR bl.batch_id = p_batch_id)
                AND pbh.bid_number = bl.bid_number
                AND (pbh.SURROG_BID_FLAG = 'Y' OR nvl(al.close_bidding_date, sysdate+1) > sysdate);


    -- STEP 2: pre-release 12 validations 14-26
    INSERT ALL

		-- bid_currency_price should be positive
		WHEN s_bid_currency_price <= 0
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_BID_PRICE' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				decode(p_trans_view, 'N',
					'PON_AUC_BIDPRICE_MUST_BE_POS' || p_suffix,
					decode(s_display_price_factors_flag, 'Y',
						'PON_LINE_BIDPRICE_INVALID_2' || p_suffix,
						'PON_AUC_BIDPRICE_MUST_BE_POS' || p_suffix)),
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'BidCurrencyPrice',
				s_bid_currency_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- bid_currency_price precision should not exceed price precision
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      validate_price_precision(s_bid_currency_price, p_price_precision) = 'F'
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_BID_PRICE' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_AUCTS_BIDPRICE_MIN_PREC' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'BidCurrencyPrice',
				s_bid_currency_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- In untransformed view, bid_currency_trans_price should be positive
		-- since bid_currency_price is the same as bid_currency_unit_price
		-- Do not report the error if one will be reported for bid_currency_price
		WHEN p_trans_view = 'Y' AND s_bid_currency_price > 0
			AND s_bid_currency_trans_price <= 0
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_BID_PRICE' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_LINE_BIDPRICE_INVALID_1' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'BidCurrencyTransPrice',
				s_bid_currency_trans_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- bid_currency_limit_price should be positive
		WHEN s_bid_currency_limit_price <= 0
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				decode(p_spreadsheet,
					g_xml_upload_mode,
						fnd_message.get_string('PON', 'PON_AUCTS_PROXY_MIN'),
						fnd_message.get_string('PON', 'PON_AUCTS_MIN_BID_PRICE')),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_LIMPRICE_MUST_BE_POS',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'BidCurrencyLimitPrice',
				s_bid_currency_limit_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- bid_currency_limit_price precision should not exceed price precision
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      validate_price_precision(s_bid_currency_limit_price, p_price_precision) = 'F' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				decode(p_spreadsheet,
					g_xml_upload_mode,
						fnd_message.get_string('PON', 'PON_AUCTS_PROXY_MIN'),
						fnd_message.get_string('PON', 'PON_AUCTS_MIN_BID_PRICE')),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_AUCTS_LIMIT_MIN_PREC' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'BidCurrencyLimitPrice',
				s_bid_currency_limit_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- price should be lower then the line start price.
		-- Will not apply if price is disabled for this line
                -- bug 5701482
                -- need use the bid currency price and do round up
                -- to precision to avoid the small gap caused by
                -- currency conversion
                -- If the precision is ANY, round up to 10 decimal points

				-- bug 12546024
				-- using cost factors to transform s_enforced_bid_start_price inaddition to applying rate for currency conversion before validation
		WHEN s_price_disabled_flag = 'N' AND
                     s_bid_currency_price > ROUND(decode(p_trans_view, 'Y', s_enforced_bid_start_price,
														 PON_TRANSFORM_BIDDING_PKG.untransform_one_price(p_auc_header_id,
																										 s_line_number,
																										 s_enforced_bid_start_price,
																										 s_auc_quantity,
																										 p_tpid,
																										 p_vensid
																										)
														)*s_rate, decode(s_precision, 10000, 10, s_precision)
												 )
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				TOKEN3_NAME,
				TOKEN3_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_BID_PRICE' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_BP_LTE_BIDSTARTPRICE' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'BidCurrencyPrice',
				s_bid_currency_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'BIDPRICE',
				format_price(s_bid_currency_price, l_price_mask, p_price_precision),
				'STARTPRICE',
				format_price(decode(p_trans_view, 'Y',
                                               s_enforced_bid_start_price,
					       PON_TRANSFORM_BIDDING_PKG.untransform_one_price(                                               p_auc_header_id,
						s_line_number,
						s_enforced_bid_start_price,
						s_auc_quantity,
						p_tpid,
						p_vensid)) * p_rate, l_price_mask, p_price_precision),
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- When rebidding, the new price must be lower than the old_price
		-- by the specified minimum bid decrement, if it was changed.
		-- Does not apply to LOT_LINEs
		-- Will not apply if price is disabled for this line, or negotiation
		-- is not price driver
		WHEN s_price_disabled_flag = 'N' AND p_rebid = 'Y' AND p_price_driven = 'Y'
		    AND p_bid_decr_method <> 'BEST_PRICE'
			AND s_price <> s_old_price AND s_group_type <> 'LOT_LINE'
			AND s_price + (nvl(s_min_bid_decr,0)/p_rate) > s_old_price
			AND s_min_bid_decr IS NOT NULL
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
                                COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE
				)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_BID_PRICE' || p_suffix),
                                'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_MIN_BID_DECREMENT' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'Price',
				s_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'BIDDECREMENT',
				format_price(s_min_bid_decr, l_price_mask, p_price_precision) || ' '||p_bid_curr_code,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code
				)

		-- When rebidding, the new price must be lower than the best_bid_price
		-- by the specified minimum bid decrement, if suppliers are
		-- supposed to reduce by best response price
		-- Does not apply to LOT_LINEs
		-- Will not apply if price is disabled for this line, or negotiation
		-- is not price driven
		WHEN s_price_disabled_flag = 'N' AND p_bid_decr_method = 'BEST_PRICE' AND p_price_driven = 'Y'
			AND s_group_type <> 'LOT_LINE'
			AND p_rebid = 'Y'
			AND s_auc_best_bid_price IS NOT NULL
			AND s_price <> s_old_price
			AND s_price + (nvl(s_min_bid_decr,0)/p_rate) > s_best_bid_price
			AND s_min_bid_decr IS NOT NULL
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
                                COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE
				)
			VALUES
				(p_interface_type,
                                fnd_message.get_string('PON', 'PON_AUCTS_BID_PRICE' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_MIN_BESTBID_DECREMENT' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'Price',
				s_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'BIDDECREMENT',
				format_price(s_min_bid_decr, l_price_mask, p_price_precision) || ' '||p_bid_curr_code,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code
				)

		-- When rebidding, the new price must be <= old_price, if changed
		-- Does not apply to LOT_LINEs
		-- Will not apply if price is disabled for this line, or negotiation
		-- is not price driver
		WHEN s_price_disabled_flag = 'N' AND p_rebid = 'Y' AND p_price_driven = 'Y'
			AND s_price <> s_old_price AND s_group_type <> 'LOT_LINE'
			AND s_price > decode(p_bid_decr_method,'BEST_PRICE',s_best_bid_price,s_old_price)
			AND s_min_bid_decr IS NULL
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
                                COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
                                fnd_message.get_string('PON', 'PON_AUCTS_BID_PRICE' || p_suffix),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
                		decode(p_bid_decr_method,'BEST_PRICE','PON_BESTBID_PRICE_LOWER','PON_BID_PRICE_LOWER') || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'Price',
				s_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- proxy_bid_limit_price must be lower than price by the bid minimum
		-- bid change (or auction minimum bid change if that is null)
                -- Don't do this validation when buyer tries to place a
                -- surrogate bid after auction is closed
		WHEN (NOT (s_surrog_bid_flag = 'Y' AND
                           s_close_bidding_date < s_current_date) AND
                          (s_proxy_bid_limit_price + s_min_bid_change > s_price))
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				decode(p_spreadsheet,
					g_xml_upload_mode,
						fnd_message.get_string('PON', 'PON_AUCTS_PROXY_MIN'),
						fnd_message.get_string('PON', 'PON_AUCTS_MIN_BID_PRICE')),
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_AUCTS_LIMIT_MIN_LESS_PRI' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'BidCurrencyLimitPrice',
				s_proxy_bid_limit_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- There was a previous bid on this line which was deleted
		-- Not allowed to unbid when rebidding.
		WHEN p_rebid = 'Y' AND s_is_changed_line_flag = 'Y'
			AND s_has_bid_flag = 'N' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_CANNOT_UNBID' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- CUMULATIVE price breaks not allowed in blanket agreements
		WHEN p_blanket = 'Y' AND p_global = 'Y'
			AND s_price_break_type = 'CUMULATIVE'
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N'
      ---------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_BAD_PBTYPE_GLOBAL',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'PriceBreakType',
				s_price_break_type,
				'TXT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- The line is not allowed to have shipments if price_break_type is NONE
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      s_price_break_type = 'NONE' AND
			EXISTS (SELECT bpb.shipment_number
					FROM pon_bid_shipments bpb
					WHERE bpb.bid_number = p_bid_number
						AND bpb.line_number = s_line_number
                                                AND bpb.shipment_type = 'PRICE BREAK')
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_ITEM_PRICES',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_BAD_PBTYPE_SHIPS',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_ITEMS',
				'PriceBreakType',
				s_price_break_type,
				'TXT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)
	SELECT
		decode(p_percent_decr, 'Y',
-- Bug 12931253
-- Modified the Bid decrement price for both the Controls Best Price checked and unchecked
			p_min_bid_decr * (decode(p_bid_decr_method,'BEST_PRICE',nvl(al.best_bid_price,0),bl.old_price))/100,				--bug 7601028:calculating the minimum decrement amount on the basis of previous bid
		    p_min_bid_decr) s_min_bid_decr,
		decode(p_percent_decr, 'Y',
			nvl(p_min_bid_change, p_min_bid_decr) * bl.price/100,		--bug 7601028:calculating the minimum change amount on the basis of previous bid
			nvl(p_min_bid_change, p_min_bid_decr)) s_min_bid_change,
		al.group_type s_group_type,
		bl.bid_currency_price s_bid_currency_price,
		bl.bid_currency_trans_price s_bid_currency_trans_price,
		bl.bid_currency_limit_price s_bid_currency_limit_price,
		bl.price s_price,
		bl.proxy_bid_limit_price s_proxy_bid_limit_price,
		bl.price_break_type s_price_break_type,
		bl.display_price_factors_flag s_display_price_factors_flag,
		bl.old_price s_old_price,
		bl.has_bid_flag s_has_bid_flag,
		bl.is_changed_line_flag s_is_changed_line_flag,
		al.quantity s_auc_quantity,
		al.bid_start_price s_bid_start_price,
		nvl(al.price_disabled_flag, 'N') s_price_disabled_flag,
		bl.line_number s_line_number,
		decode(p_spreadsheet, g_txt_upload_mode, bl.interface_line_id,
				      g_xml_upload_mode, bl.interface_line_id,
				      to_number(null)) s_interface_line_id,
		al.document_disp_line_number s_document_disp_line_number,
		nvl(al.best_bid_price,0) s_best_bid_price,
		al.best_bid_price s_auc_best_bid_price,
   	        bl.bid_start_price s_enforced_bid_start_price,
                bh.surrog_bid_flag s_surrog_bid_flag,
                al.close_bidding_date s_close_bidding_date,
                sysdate s_current_date,
		decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_name, to_char(null)) s_worksheet_name,
		decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_sequence_number, to_number(null))	s_worksheet_sequence_number,
		decode(p_spreadsheet, g_xml_upload_mode, 'PON_AUC_ITEMS', to_char(null))	s_entity_message_code,
                bh.rate s_rate,
                bh.number_price_decimals s_precision
	FROM pon_auction_item_prices_all al, pon_bid_item_prices bl,
             pon_bid_headers bh
	WHERE al.auction_header_id = p_auc_header_id
                AND bh.bid_number = p_bid_number
		AND bl.bid_number = p_bid_number
		AND al.line_number = bl.line_number
		AND bl.is_changed_line_flag = 'Y'
		AND (p_spreadsheet = g_online_mode OR bl.batch_id = p_batch_id)
                AND bh.bid_number = bl.bid_number
                AND (bh.SURROG_BID_FLAG = 'Y' OR nvl(al.close_bidding_date, sysdate+1) > sysdate);

	-- STEP 3: perform rel 12 and post rel 12 validations.
    -- Validations 1-10 in this statement
    INSERT ALL

		-- Retainage rate should be between 0 and 100
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      retainage_rate_percent IS NOT NULL AND (retainage_rate_percent < 0 OR retainage_rate_percent > 100) THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,  		ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 EXPIRATION_DATE,				TOKEN1_NAME,                TOKEN1_VALUE,
				WORKSHEET_NAME,					WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --7
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_RETAINAGE_RATE'),      'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,       'PON_RTNG_RATE_WRONG_L',         --2
				 p_userid,				        sysdate,				   p_userid,                      --3
				 sysdate,				        p_request_id,			   'BID_ITEMS',                   --4
				 'RetainageRatePercent',	    retainage_rate_percent,	   'NUM',                         --5
				 p_auc_header_id,				p_bid_number,			   s_line_number,                 --6
				 g_exp_date,			       	'LINENUM',                 s_document_disp_line_number,
				s_worksheet_name, 			s_worksheet_sequence_number, s_entity_message_code)   --7
		-- bid_curr_max_retainage_amt should be greater than equal to 0
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      bid_curr_max_retainage_amt IS NOT NULL AND bid_curr_max_retainage_amt < 0 THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,			ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 EXPIRATION_DATE,				TOKEN1_NAME,                TOKEN1_VALUE,
				WORKSHEET_NAME,					WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --7
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_MAX_RETAINAGE_AMOUNT'),	'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_MAX_RTNG_WRONG_L',        --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 'BidCurrMaxRetainageAmt',      bid_curr_max_retainage_amt,	'NUM',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 g_exp_date,			       	'LINENUM',                  s_document_disp_line_number,
				s_worksheet_name,			s_worksheet_sequence_number, s_entity_message_code)   --7
		-- bid_curr_advance_amount should be greater than equal to 0
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      bid_curr_advance_amount IS NOT NULL AND bid_curr_advance_amount < 0 THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,			ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 EXPIRATION_DATE,				TOKEN1_NAME,                TOKEN1_VALUE,
				WORKSHEET_NAME,					WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --7
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_ADVANCE_AMOUNT_FLAG'),	'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_ADV_AMT_WRONG_L',         --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 'BidCurrAdvanceAmount',        bid_curr_advance_amount,	'NUM',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 g_exp_date,			       	'LINENUM',                  s_document_disp_line_number,
				s_worksheet_name,			s_worksheet_sequence_number, s_entity_message_code)   --7
		-- progress_pymt_rate_percent should be between 0 and 100
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      progress_pymt_rate_percent IS NOT NULL AND
            (progress_pymt_rate_percent < 0 OR progress_pymt_rate_percent > 100) THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,			ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 EXPIRATION_DATE,				TOKEN1_NAME,                TOKEN1_VALUE,
				WORKSHEET_NAME,					WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --7
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_PROGRESS_PYMT_RATE'),	'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_PROG_PYMT_RATE_WRONG_L',  --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 'ProgressPymtRatePercent',     progress_pymt_rate_percent, 'NUM',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 g_exp_date,			       	'LINENUM',                  s_document_disp_line_number,
				s_worksheet_name,			s_worksheet_sequence_number, s_entity_message_code)   --7
		-- recoupment_rate_percent should be between 0 and 100
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      recoupment_rate_percent IS NOT NULL AND
            (recoupment_rate_percent < 0 OR recoupment_rate_percent > 100) THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,			ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 EXPIRATION_DATE,				TOKEN1_NAME,                TOKEN1_VALUE,
				WORKSHEET_NAME,					WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --7
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_RECOUPMENT_RATE'),	    'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_RECOUP_RATE_WRONG',       --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 'RecoupmentRatePercent',       recoupment_rate_percent,    'NUM',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 g_exp_date,			       	'LINENUM',                  s_document_disp_line_number,
				s_worksheet_name,			s_worksheet_sequence_number, s_entity_message_code)   --7
		-- progress_pymt_rate_percent is mandatory for progress_payment_type = FINANCE
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      progress_payment_type = 'FINANCE' AND contract_type='STANDARD'
		  AND s_group_type NOT IN ('GROUP','LOT_LINE') AND progress_pymt_rate_percent IS NULL THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE,				ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 BID_PAYMENT_ID,				EXPIRATION_DATE,            TOKEN1_NAME,          --7
                 		 TOKEN1_VALUE,                  TOKEN2_NAME,                TOKEN2_VALUE,
				 WORKSHEET_NAME, WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_PROGRESS_PYMT_RATE'),	'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_PROG_PYMT_NEEDED_L',    --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 'ProgressPymtRatePercent',     progress_pymt_rate_percent, 'TXT',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 NULL,				            g_exp_date,                 'LINENUM',                  --7
				 s_document_disp_line_number,   null,                       null,
				s_worksheet_name, 			s_worksheet_sequence_number, s_entity_message_code)                          --8

		-- retainage_rate_percent is mandatory if retainage is negotiable
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      retainage_negotiable_flag = 'Y'
		  AND s_group_type NOT IN ('GROUP','LOT_LINE') AND retainage_rate_percent IS NULL THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE,				ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 BID_PAYMENT_ID,				EXPIRATION_DATE,            TOKEN1_NAME,          --7
                 TOKEN1_VALUE,                  TOKEN2_NAME,                TOKEN2_VALUE, WORKSHEET_NAME, WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_RETAINAGE_RATE'),	    'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_RETAINAGE_NEEDED_L',    --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 'RetainageRatePercent',        retainage_rate_percent,     'TXT',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 NULL,				            g_exp_date,                 'LINENUM',                  --7
				 s_document_disp_line_number,   null,                       null,
				s_worksheet_name, s_worksheet_sequence_number, s_entity_message_code)                          --8
		-- bid_curr_max_retainage_amount is mandatory if maximum retainage amount is negotiable
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      max_retainage_negotiable_flag = 'Y'
		  AND s_group_type NOT IN ('GROUP','LOT_LINE') AND bid_curr_max_retainage_amt IS NULL THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE,				ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 BID_PAYMENT_ID,				EXPIRATION_DATE,            TOKEN1_NAME,          --7
                 		TOKEN1_VALUE,                  TOKEN2_NAME,                TOKEN2_VALUE,
				WORKSHEET_NAME, WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_MAX_RETAINAGE_AMOUNT'),	'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_MAX_RETAINAGE_NEEDED_L',    --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 'BidCurrMaxRetainageAmt',      bid_curr_max_retainage_amt, 'TXT',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 NULL,				            g_exp_date,                 'LINENUM',                  --7
				 s_document_disp_line_number,   null,                       null,
				 s_worksheet_name, s_worksheet_sequence_number, s_entity_message_code)                          --8

		-- recoupment_rate_percent is mandatory if recoupment rate is negotiable
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      (s_group_type NOT IN ('GROUP','LOT_LINE') AND
		((recoupment_negotiable_flag = 'Y' AND recoupment_rate_percent IS NULL) OR
		((progress_pymt_rate_percent IS NOT NULL OR bid_curr_advance_amount IS NOT NULL) AND
		  recoupment_rate_percent IS NULL)))
		THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE,				ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 BID_PAYMENT_ID,				EXPIRATION_DATE,            TOKEN1_NAME,          --7
                 TOKEN1_VALUE,                  TOKEN2_NAME,                TOKEN2_VALUE, WORKSHEET_NAME, WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_RECOUPMENT_RATE'),  	'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_RECUP_RATE_NEEDED_L',    --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 'RecoupmentRatePercent',       recoupment_rate_percent,    'TXT',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 NULL,				            g_exp_date,                 'LINENUM',                  --7
				 s_document_disp_line_number,   null,                       null,
				 s_worksheet_name, s_worksheet_sequence_number, s_entity_message_code)                          --8
		-- bid_curr_advance_amount is mandatory if advance amount is negotiable
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      advance_negotiable_flag = 'Y'
		  AND s_group_type NOT IN ('GROUP','LOT_LINE')
		  AND bid_curr_advance_amount IS NULL THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE,				ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 BID_PAYMENT_ID,				EXPIRATION_DATE,            TOKEN1_NAME,          --7
                 TOKEN1_VALUE,                  TOKEN2_NAME,                TOKEN2_VALUE, WORKSHEET_NAME, WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_ADVANCE_AMOUNT_FLAG'), 	'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_ADVANCE_AMT_NEEDED_L',    --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 'BidCurrAdvanceAmount',        bid_curr_advance_amount,    'TXT',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 NULL,				            g_exp_date,                 'LINENUM',                  --7
				 s_document_disp_line_number,   null,                       null, s_worksheet_name, s_worksheet_sequence_number, s_entity_message_code)                          --8

	SELECT
		al.group_type s_group_type,
		bl.quantity s_bid_quantity,
		bl.bid_currency_unit_price s_bid_currency_unit_price,
		bl.bid_curr_advance_amount,
		bl.bid_curr_max_retainage_amt,
		bl.recoupment_rate_percent,
		bl.retainage_rate_percent,
		bl.progress_pymt_rate_percent,
		bl.has_bid_payments_flag,
		bl.line_number s_line_number,
		decode(p_spreadsheet, g_txt_upload_mode, bl.interface_line_id,
				      g_xml_upload_mode, bl.interface_line_id,
				      to_number(null)) s_interface_line_id,
		al.document_disp_line_number s_document_disp_line_number,
		al.order_type_lookup_code s_order_type_lookup_code,
		al.quantity s_auc_quantity,
		pah.progress_payment_type,
		pah.advance_negotiable_flag,
		pah.retainage_negotiable_flag,
		pah.max_retainage_negotiable_flag,
		pah.recoupment_negotiable_flag,
	    	pah.progress_pymt_negotiable_flag,
	    	pah.contract_type,
		decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_name, to_char(null)) s_worksheet_name,
		decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_sequence_number, to_number(null))	s_worksheet_sequence_number,
		decode(p_spreadsheet, g_xml_upload_mode, 'PON_AUC_ITEMS', to_char(null))	s_entity_message_code
	FROM pon_auction_item_prices_all al, pon_bid_item_prices bl, pon_auction_headers_all pah
	WHERE al.auction_header_id = p_auc_header_id
		AND bl.bid_number = p_bid_number
		AND pah.auction_header_id = p_auc_header_id
		AND al.line_number = bl.line_number
		AND bl.is_changed_line_flag = 'Y'
		AND (p_spreadsheet = g_online_mode OR bl.batch_id = p_batch_id);

    -- STEP 4: rel 12 and post rel 12 validations
    -- validations 11-20
    INSERT ALL

		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      bid_curr_advance_amount IS NOT NULL AND s_bid_currency_unit_price IS NOT NULL AND
		     (bid_curr_advance_amount >  (NVL(s_bid_quantity,1) * s_bid_currency_unit_price)) THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    	CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,			ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				LINE_NUMBER,          --6
				 EXPIRATION_DATE,				TOKEN1_NAME,                		TOKEN1_VALUE,	      --7
				WORKSHEET_NAME,					WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_ADVANCE_AMOUNT_FLAG'),   'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_ADV_AMT_MORE_L',            --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 NULL,                          bid_curr_advance_amount,    'NUM',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 g_exp_date,			       	'LINENUM',                  s_document_disp_line_number, --7
				 s_worksheet_name,			s_worksheet_sequence_number, s_entity_message_code)   --8
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      (p_spreadsheet = g_online_mode OR p_spreadsheet = g_xml_upload_mode) AND progress_payment_type = 'FINANCE' AND
		     recoupment_rate_percent IS NOT NULL AND progress_pymt_rate_percent IS NOT NULL AND
			 s_bid_currency_unit_price IS NOT NULL AND
			 recoupment_rate_percent < (((((progress_pymt_rate_percent/100) * (SELECT nvl(sum(nvl(bid_currency_price,0)*nvl(quantity,nvl(s_bid_quantity,1))),0)
			                                                                   FROM PON_BID_PAYMENTS_SHIPMENTS p_bps
																			   WHERE p_bps.auction_header_id=p_auc_header_id
																			   AND p_bps.bid_line_number=s_line_number
																			   AND p_bps.bid_number=p_bid_number))
			                          + nvl(bid_curr_advance_amount,0)) * 100)/((nvl(s_bid_quantity, 1) * s_bid_currency_unit_price)))  THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,			ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 EXPIRATION_DATE,				TOKEN1_NAME,                TOKEN1_VALUE,--7
				WORKSHEET_NAME,					WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_RECOUPMENT_RATE'),   'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_RECOUP_LESS_THAN_PYMT_L',   --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 NULL,                          recoupment_rate_percent,     'NUM',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 g_exp_date,			       	'LINENUM',                  s_document_disp_line_number,--7
				 s_worksheet_name,			s_worksheet_sequence_number, s_entity_message_code)   --8
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      (p_spreadsheet = g_online_mode OR p_spreadsheet = g_xml_upload_mode) AND progress_payment_type = 'ACTUAL' AND
		     recoupment_rate_percent IS NOT NULL AND bid_curr_advance_amount IS NOT NULL AND
			 s_bid_currency_unit_price IS NOT NULL AND
			 recoupment_rate_percent <((bid_curr_advance_amount * 100)/(nvl(s_bid_quantity,1) * s_bid_currency_unit_price)) THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,			ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 EXPIRATION_DATE,				TOKEN1_NAME,                TOKEN1_VALUE,--7
				WORKSHEET_NAME,					WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_RECOUPMENT_RATE'),   'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_RECOUP_LESS_THAN_ADV_L',    --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 NULL,                          recoupment_rate_percent,    'NUM',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 g_exp_date,			       	'LINENUM',                  s_document_disp_line_number,--7
				s_worksheet_name,			s_worksheet_sequence_number, s_entity_message_code)   --8
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      --bug 14657112: Rounding the amounts based on GL precision and
      -- adding tokens in message for more information.
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      (p_spreadsheet = g_online_mode OR p_spreadsheet = g_xml_upload_mode) AND progress_payment_type = 'ACTUAL' AND
		     s_group_type NOT IN ('GROUP','LOT_LINE') AND
		     has_bid_payments_flag = 'Y' AND
		     s_bid_currency_unit_price IS NOT NULL AND
			 round(nvl(s_bid_quantity,1)* s_bid_currency_unit_price,p_amt_precision) <> s_sum_pymt_amt THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE,				ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 EXPIRATION_DATE,
         TOKEN1_NAME,                TOKEN1_VALUE,
         TOKEN2_NAME,                TOKEN2_VALUE,
         TOKEN3_NAME,                TOKEN3_VALUE,
				WORKSHEET_NAME,					WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --7
			VALUES
				(p_interface_type,				NULL, 	                    'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_PYMNT_AMT_MORE_ACTUAL',   --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 NULL,                    NULL ,                       'TXT',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 g_exp_date,
         'LINEAMT', round(nvl(s_bid_quantity,1)* s_bid_currency_unit_price,p_amt_precision),
         'PYMTAMT', s_sum_pymt_amt,
         'LINENUM',                  s_document_disp_line_number,
				s_worksheet_name,			s_worksheet_sequence_number, s_entity_message_code)   --7

		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      (p_spreadsheet = g_online_mode OR p_spreadsheet = g_xml_upload_mode ) AND progress_payment_type = 'FINANCE' AND
		     has_bid_payments_flag = 'Y' AND
		     s_group_type NOT IN ('GROUP','LOT_LINE') AND
		     s_bid_currency_unit_price IS NOT NULL AND
			 (nvl(s_bid_quantity,1)* s_bid_currency_unit_price)- nvl(bid_curr_advance_amount,0) < (SELECT nvl(sum(nvl(bid_currency_price,0) * DECODE(s_order_type_lookup_code,'GOODS',NVL(s_auc_quantity,1),NVL(quantity,1))),0)
			                                           FROM   pon_bid_payments_shipments
													   WHERE  auction_header_id = p_auc_header_id
													   AND    bid_number = p_bid_number
													   AND    bid_line_number = s_line_number) THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE,				ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 EXPIRATION_DATE,				TOKEN1_NAME,                TOKEN1_VALUE,
				WORKSHEET_NAME,					WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --7
			VALUES
				(p_interface_type,				NULL, 	                    'PON_BID_ITEM_PRICES',  --1
				 p_batch_id,				    s_interface_line_id,        'PON_PYMNT_AMT_MORE_FINANCE',  --2
				 p_userid,				        sysdate,				    p_userid,                      --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                   --4
				 NULL,                          NULL,                       'TXT',                         --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                 --6
				 g_exp_date,			       	'LINENUM',                  s_document_disp_line_number,
				s_worksheet_name,			s_worksheet_sequence_number, s_entity_message_code)   --7
		-- bid_curr_advance_amount should not exceed currency precision
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      bid_curr_advance_amount IS NOT NULL AND
		    validate_currency_precision(bid_curr_advance_amount, p_amt_precision) = 'F' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,			ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 BID_PAYMENT_ID,				EXPIRATION_DATE,            TOKEN1_NAME,          --7
                 TOKEN1_VALUE,                  TOKEN2_NAME,                TOKEN2_VALUE,
		 		WORKSHEET_NAME,				WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_ADVANCE_AMOUNT_FLAG'),	'PON_BID_ITEM_PRICES',       --1
				 p_batch_id,				    s_interface_line_id,        'PON_LINEAMT_INVALID_PRECISION',    --2
				 p_userid,				        sysdate,				    p_userid,                           --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                        --4
				 'BidCurrAdvanceAmount',        bid_curr_advance_amount,    'NUM',                              --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                      --6
				 NULL,				            g_exp_date,                 'LINENUM',                          --7
				 s_document_disp_line_number,     'ATTRIBUTENAME',          fnd_message.get_string('PON','PON_ADVANCE_AMOUNT_FLAG'),
				s_worksheet_name,	s_worksheet_sequence_number, s_entity_message_code) --8
		-- bid_curr_max_retainage_amt should not exceed currency precision
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      bid_curr_max_retainage_amt IS NOT NULL AND
		     validate_currency_precision(bid_curr_max_retainage_amt, p_amt_precision) = 'F' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,			ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 BID_PAYMENT_ID,				EXPIRATION_DATE,            TOKEN1_NAME,          --7
                 TOKEN1_VALUE,                  TOKEN2_NAME,                TOKEN2_VALUE, WORKSHEET_NAME, WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_MAX_RETAINAGE_AMOUNT'),	'PON_BID_ITEM_PRICES',       --1
				 p_batch_id,				    s_interface_line_id,        'PON_LINEAMT_INVALID_PRECISION',    --2
				 p_userid,				        sysdate,				    p_userid,                           --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                        --4
				 'BidCurrMaxRetainageAmt',      bid_curr_max_retainage_amt, 'NUM',                              --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                      --6
				 NULL,				            g_exp_date,                 'LINENUM',                          --7
				 s_document_disp_line_number,   'ATTRIBUTENAME',            fnd_message.get_string('PON','PON_MAX_RETAINAGE_AMOUNT'),
				s_worksheet_name, s_worksheet_sequence_number, s_entity_message_code) --8
		-- progress_pymt_rate_percent should not exceed currency precision
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      progress_pymt_rate_percent IS NOT NULL AND
		     validate_currency_precision(progress_pymt_rate_percent, 2) = 'F' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,			ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 BID_PAYMENT_ID,				EXPIRATION_DATE,            TOKEN1_NAME,          --7
                 TOKEN1_VALUE,                  TOKEN2_NAME,                TOKEN2_VALUE, WORKSHEET_NAME, WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_PROGRESS_PYMT_RATE'),	'PON_BID_ITEM_PRICES',       --1
				 p_batch_id,				    s_interface_line_id,        'PON_INVALID_RATE_PRECISION_L',    --2
				 p_userid,				        sysdate,				    p_userid,                           --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                        --4
				 'ProgressPymtRatePercent',     progress_pymt_rate_percent, 'NUM',                              --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                      --6
				 NULL,				            g_exp_date,                 'LINENUM',                          --7
				 s_document_disp_line_number,   'ATTRIBUTENAME',            fnd_message.get_string('PON','PON_PROGRESS_PYMT_RATE'),
				s_worksheet_name, s_worksheet_sequence_number, s_entity_message_code) --8
		-- retainage_rate_percent should not exceed currency precision
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      retainage_rate_percent IS NOT NULL AND
		     validate_currency_precision(retainage_rate_percent, 2) = 'F' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,			ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 BID_PAYMENT_ID,				EXPIRATION_DATE,            TOKEN1_NAME,          --7
                 TOKEN1_VALUE,                  TOKEN2_NAME,                TOKEN2_VALUE, WORKSHEET_NAME, WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_RETAINAGE_RATE'),   	'PON_BID_ITEM_PRICES',       --1
				 p_batch_id,				    s_interface_line_id,        'PON_INVALID_RATE_PRECISION_L',    --2
				 p_userid,				        sysdate,				    p_userid,                           --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                        --4
				 'RetainageRatePercent',        retainage_rate_percent,     'NUM',                              --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                      --6
				 NULL,				            g_exp_date,                 'LINENUM',                          --7
				 s_document_disp_line_number,   'ATTRIBUTENAME',            fnd_message.get_string('PON','PON_RETAINAGE_RATE'),
				s_worksheet_name, 		s_worksheet_sequence_number, s_entity_message_code) --8
		-- recoupment_rate_percent should not exceed currency precision
		WHEN
      -- added by Allen Yang for Surrogate Bid 2008/09/03
      ---------------------------------------------------
      p_two_part_tech_surrogate_flag = 'N' AND
      ---------------------------------------------------
      recoupment_rate_percent IS NOT NULL AND
		     validate_currency_precision(recoupment_rate_percent, 2) = 'F' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,				COLUMN_NAME,				TABLE_NAME,           --1
				 BATCH_ID,				        INTERFACE_LINE_ID,			ERROR_MESSAGE_NAME,   --2
				 CREATED_BY,				    CREATION_DATE,				LAST_UPDATED_BY,      --3
				 LAST_UPDATE_DATE,				REQUEST_ID,				    ENTITY_TYPE,          --4
				 ENTITY_ATTR_NAME,				ERROR_VALUE_NUMBER,			ERROR_VALUE_DATATYPE, --5
				 AUCTION_HEADER_ID,				BID_NUMBER,				    LINE_NUMBER,          --6
				 BID_PAYMENT_ID,				EXPIRATION_DATE,            TOKEN1_NAME,          --7
                 TOKEN1_VALUE,                  TOKEN2_NAME,                TOKEN2_VALUE, WORKSHEET_NAME,WORKSHEET_SEQUENCE_NUMBER, ENTITY_MESSAGE_CODE)         --8
			VALUES
				(p_interface_type,				fnd_message.get_string('PON','PON_RECOUPMENT_RATE'),   	'PON_BID_ITEM_PRICES',       --1
				 p_batch_id,				    s_interface_line_id,        'PON_INVALID_RATE_PRECISION_L',    --2
				 p_userid,				        sysdate,				    p_userid,                           --3
				 sysdate,				        p_request_id,			    'BID_ITEMS',                        --4
				 'RecoupmentRatePercent',       recoupment_rate_percent,     'NUM',                              --5
				 p_auc_header_id,				p_bid_number,			    s_line_number,                      --6
				 NULL,				            g_exp_date,                 'LINENUM',                          --7
				 s_document_disp_line_number,   'ATTRIBUTENAME',            fnd_message.get_string('PON','PON_RECOUPMENT_RATE'),
				s_worksheet_name, s_worksheet_sequence_number, s_entity_message_code) --8
	SELECT
		al.group_type s_group_type,
		bl.quantity s_bid_quantity,
		bl.bid_currency_unit_price s_bid_currency_unit_price,
		bl.bid_curr_advance_amount,
		bl.bid_curr_max_retainage_amt,
		bl.recoupment_rate_percent,
		bl.retainage_rate_percent,
		bl.progress_pymt_rate_percent,
		bl.has_bid_payments_flag,
		bl.line_number s_line_number,
		decode(p_spreadsheet,   g_txt_upload_mode, bl.interface_line_id,
					g_xml_upload_mode, bl.interface_line_id,
					to_number(null)) s_interface_line_id,
		al.document_disp_line_number s_document_disp_line_number,
		al.order_type_lookup_code s_order_type_lookup_code,
		al.quantity s_auc_quantity,
		pah.progress_payment_type,
		pah.advance_negotiable_flag,
		pah.retainage_negotiable_flag,
		pah.max_retainage_negotiable_flag,
		pah.recoupment_negotiable_flag,
	    	pah.progress_pymt_negotiable_flag,
	    	pah.contract_type,
		decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_name, to_char(null)) s_worksheet_name,
		decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_sequence_number, to_number(null))	s_worksheet_sequence_number,
		decode(p_spreadsheet, g_xml_upload_mode, 'PON_AUC_ITEMS', to_char(null))	s_entity_message_code,
      		(SELECT nvl(Sum  (round(NVL(pbps.bid_currency_price,0) * NVL(pbps.quantity,nvl(bl.quantity,1)),p_amt_precision)),0)
			FROM   pon_bid_payments_shipments pbps
			WHERE  pbps.auction_header_id = p_auc_header_id
			AND    pbps.bid_number = p_bid_number
			AND    pbps.bid_line_number = bl.line_number) s_sum_pymt_amt  --bug 14657112
	FROM pon_auction_item_prices_all al, pon_bid_item_prices bl, pon_auction_headers_all pah
	WHERE al.auction_header_id = p_auc_header_id
		AND bl.bid_number = p_bid_number
		AND pah.auction_header_id = p_auc_header_id
		AND al.line_number = bl.line_number
		AND bl.is_changed_line_flag = 'Y'
		AND (p_spreadsheet = g_online_mode OR bl.batch_id = p_batch_id);
  print_log('validate_lines End');
END validate_lines;

PROCEDURE validate_requirements
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid		IN pon_interface_errors.created_by%TYPE,
	p_spreadsheet		IN VARCHAR2,
	p_suffix		IN VARCHAR2,
	p_batch_id		IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE
  -- added by Allen Yang for Surrogate Bid 2008/09/03
  ---------------------------------------------------
  , p_two_part_tech_surrogate_flag IN VARCHAR2
  ---------------------------------------------------
) IS
BEGIN
  print_log('validate_requirements Start');
  	  print_log('p_auc_header_id '||p_auc_header_id);
	  print_log('p_bid_number '||p_bid_number);
	  print_log('p_interface_type '||p_interface_type);
	  print_log('p_userid '||p_userid);
	  print_log('p_spreadsheet '||	p_spreadsheet);
	  print_log('p_suffix	 '||p_suffix);
	  print_log('p_batch_id	 '||p_batch_id);
	  print_log('p_request_id '||p_request_id);

	INSERT FIRST

		-- value must be entered if it is a required requirement
		-- added the s_evaluation_flag condition for ER: Supplier Management: Supplier Evaluation
		-- bug#16233503: Mandating Internal Requirement Enhancement.
		WHEN ((s_mandatory_flag = 'Y' AND s_internal_attr_flag = 'N' AND s_value IS null AND s_evaluation_flag = 'N'
      --added by Allen Yang for Surrogate Bid 2008/09/03
      -------------------------------------------------------------------
      AND p_two_part_tech_surrogate_flag = 'N' )


           OR (s_mandatory_flag = 'Y' AND s_internal_attr_flag = 'N'
      AND s_value IS null AND p_two_part_tech_surrogate_flag = 'Y'
      AND s_two_part_section_type = 'TECHNICAL') OR
	 (s_evaluation_flag = 'Y' AND s_mandatory_flag = 'Y' AND s_internal_attr_flag = 'Y' AND s_value IS null)
     -------------------------------------------------------------------
      )
      -------------------------------------------------------------------
      -- bug 20886338  and bug 20872754
      AND
      (s_parent_req_id IS NULL
          OR
  EXISTS (SELECT 1 FROM pon_bid_attribute_values pba, pon_attributes_rules rules1
          WHERE pba.bid_number = s_bid_number
          AND PBA.attr_level= 'HEADER'
          AND rules1.auction_header_id = pba.auction_Header_id
          AND rules1.dependent_requirement_id = s_sequence_number
          and pba.sequence_number = rules1.parent_requirement_id
          --AND pba.Value = response_value\n" +
            AND ((OPERATOR = 'IS' AND rules1.response_value = pba.Value)
        OR (OPERATOR = 'IS_NOT' AND Nvl2(pba.Value,rules1.response_value,-1) <> Nvl(pba.Value,-1))
        OR (OPERATOR = 'LESSER_THAN' AND
            ((pba.datatype = 'NUM' and to_number(pba.value) < to_number(response_value))
            or (pba.datatype = 'DAT' AND to_date(pba.value,'dd-mm-yyyy') < to_date(rules1.response_value,'dd-mm-yyyy'))))

        OR (OPERATOR = 'GREATER_THAN' AND
            ((pba.datatype = 'NUM' and to_number(pba.value) > to_number(response_value))
            or (pba.datatype = 'DAT' AND to_date(pba.value,'dd-mm-yyyy') > to_date(rules1.response_value,'dd-mm-yyyy'))))
        OR (OPERATOR = 'BETWEEN' AND
        ((pba.datatype = 'NUM' and to_number(pba.value) > to_number(response_value))
            or (pba.datatype = 'DAT' AND to_date(pba.value,'dd-mm-yyyy') > to_date(rules1.response_value,'dd-mm-yyyy')))
        and ((pba.datatype = 'NUM' and to_number(pba.value) < to_number(response_value_upper_limit))
            or (pba.datatype = 'DAT' AND to_date(pba.value,'dd-mm-yyyy') < to_date(rules1.response_value_upper_limit,'dd-mm-yyyy'))))
        ))
          )

      -------------------------------------------------------------------
    THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
                                 COLUMN_NAME,
				 TABLE_NAME,
				 BATCH_ID,
                                 INTERFACE_LINE_ID,
				 ERROR_MESSAGE_NAME,
				 CREATED_BY,
				 CREATION_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_DATE,
				 REQUEST_ID,
				 ENTITY_TYPE,
				 ENTITY_ATTR_NAME,
				 ERROR_VALUE_DATATYPE,
				 AUCTION_HEADER_ID,
				 BID_NUMBER,
				 ATTRIBUTE_NAME,
				 EXPIRATION_DATE,
				 TOKEN1_NAME,
				 TOKEN1_VALUE,
                                 WORKSHEET_NAME,
                                 WORKSHEET_SEQUENCE_NUMBER,
                                 ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
                                 fnd_message.get_string('PON', 'PON_AUCTS_BID_VALUE' || p_suffix),
				 'PON_BID_ATTRIBUTE_VALUES',
				 p_batch_id,
                                 s_interface_line_id,
				 'PON_AUC_HDR_ATTR_REQ' || p_suffix,
				 p_userid,
				 sysdate,
				 p_userid,
				 sysdate,
				 p_request_id,
				 'BID_ATTRS',
				 'Value',
				 'TXT',
				 p_auc_header_id,
				 p_bid_number,
				 s_attribute_name,
				 g_exp_date,
				 'ATTRIBUTENAME',
                                 s_trunc_attr_name,
                                 s_worksheet_name,
                                 s_worksheet_sequence_number,
                                 s_entity_message_code)

		-- value must be among buyer specified values if type is LOV
		WHEN p_spreadsheet in (g_txt_upload_mode, g_xml_upload_mode) AND s_scoring_type = 'LOV' AND s_value is not NULL AND NOT EXISTS
			(SELECT bs.score
			FROM pon_attribute_scores bs
			WHERE bs.auction_header_id = p_auc_header_id
				AND bs.line_number = s_line_number
				AND bs.attribute_sequence_number = s_sequence_number
				AND bs.value = s_value) THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				 COLUMN_NAME,
				 TABLE_NAME,
				 BATCH_ID,
				 INTERFACE_LINE_ID,
				 ERROR_MESSAGE_NAME,
				 CREATED_BY,
				 CREATION_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_DATE,
				 REQUEST_ID,
				 ENTITY_TYPE,
				 ENTITY_ATTR_NAME,
				 ERROR_VALUE,
				 ERROR_VALUE_DATATYPE,
				 AUCTION_HEADER_ID,
				 BID_NUMBER,
				 LINE_NUMBER,
				 ATTRIBUTE_NAME,
				 EXPIRATION_DATE,
                                 WORKSHEET_NAME,
                                 WORKSHEET_SEQUENCE_NUMBER,
                                 ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
			 	 fnd_message.get_string('PON', 'PON_AUCTS_BID_VALUE' || p_suffix),
				 'PON_BID_ATTRIBUTE_VALUES',
				 p_batch_id,
				 s_interface_line_id,
				 'PON_AUC_INVALID_ATTR_VALUE'  || p_suffix,
				 p_userid,
				 sysdate,
				 p_userid,
				 sysdate,
				 p_request_id,
				 'BID_ATTRS',
				 'Value',
				 s_value,
				 'TXT',
				 p_auc_header_id,
				 p_bid_number,
				 s_line_number,
				 s_attribute_name,
				 g_exp_date,
                                 s_worksheet_name,
                                 s_worksheet_sequence_number,
                                 s_entity_message_code)

        SELECT
                ba.value s_value,
                ba.line_number s_line_number,
                ba.sequence_number s_sequence_number,
                ba.attribute_name s_attribute_name,
		-- bug 8411749 using SUBSTRB instead of SUBSTR
                -- to calculate the length of the string in bytes
                substrb(ba.attribute_name, 0, 2000) s_trunc_attr_name,
                aa.mandatory_flag s_mandatory_flag,
				aa.internal_attr_flag  s_internal_attr_flag,
                aa.scoring_type s_scoring_type,
                decode(p_spreadsheet, g_xml_upload_mode, ba.interface_line_id, null) s_interface_line_id,
                decode(p_spreadsheet, g_xml_upload_mode, ba.worksheet_name, null) s_worksheet_name,
                decode(p_spreadsheet, g_xml_upload_mode, ba.worksheet_sequence_number, null) s_worksheet_sequence_number,
                decode(p_spreadsheet, g_xml_upload_mode,
                Decode(PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(p_auc_header_id), 'Y','PON_SLM_QUESTIONAIRE', 'PON_AUC_REQUIREMENTS'), null) s_entity_message_code
                --added by Allen Yang for Surrogate Bid 2008/09/03
                ---------------------------------------------------
                , pas.two_part_section_type s_two_part_section_type
                ---------------------------------------------------
                ---- Supplier Management: Supplier Evaluation -----
                , nvl(pbh.evaluation_flag, 'N') s_evaluation_flag
                ---------------------------------------------------
		, rules.parent_requirement_id s_parent_req_id
                , rules.response_value s_parent_resp_value
                , rules.response_value_upper_limit s_parent_resp_value_to
                , rules.OPERATOR s_rules_operator
                , ba.bid_number s_bid_number
        FROM pon_bid_attribute_values ba, pon_auction_attributes aa
             --added by Allen Yang for Surrogate Bid 2008/09/03
             ---------------------------------------------------
             , pon_auction_sections pas
             ---------------------------------------------------
             ---- Supplier Management: Supplier Evaluation -----
             , pon_bid_headers pbh
             ---------------------------------------------------
	     , pon_attributes_rules rules
        WHERE ba.bid_number = p_bid_number
                AND ba.line_number = -1
                AND aa.auction_header_id = ba.auction_header_id
                AND aa.line_number = ba.line_number
                AND aa.sequence_number = ba.sequence_number
                AND (p_spreadsheet = g_online_mode OR ba.batch_id = p_batch_id)
                --added by Allen Yang for Surrogate Bid 2008/09/03
                ---------------------------------------------------
                AND pas.auction_header_id = aa.auction_header_id
                AND pas.section_name = aa.section_name
                ---------------------------------------------------
                ---- Supplier Management: Supplier Evaluation -----
                AND pbh.auction_header_id = ba.auction_header_id
                AND pbh.bid_number = ba.bid_number
                ---------------------------------------------------
                AND (nvl(PBH.EVALUATION_FLAG, 'N') = 'N' OR
                     PAS.SECTION_ID IN (SELECT pets.section_id
                            FROM pon_evaluation_team_sections pets,
                                 pon_evaluation_team_members petm
                            WHERE pets.auction_header_id = AA.AUCTION_HEADER_ID
                              AND pets.auction_header_id = petm.auction_header_id
                              AND pets.team_id = petm.team_id
                              AND petm.user_id = fnd_global.user_id))
		AND ba.auction_header_id = rules.auction_Header_id(+)
                and ba.sequence_number = rules.dependent_requirement_Id(+)		;
  print_log('validate_requirements End');
END validate_requirements;


PROCEDURE validate_attributes
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid		IN pon_interface_errors.created_by%TYPE,
	p_spreadsheet		IN VARCHAR2,
	p_suffix		IN VARCHAR2,
	p_batch_id		IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE,
        p_tech_sur_flag         IN VARCHAR2
) IS
BEGIN
  print_log('validate_attributes Start');
  	  print_log('p_auc_header_id '||p_auc_header_id);
	  print_log('p_bid_number '||p_bid_number);
	  print_log('p_interface_type '||p_interface_type);
	  print_log('p_userid '||p_userid);
	  print_log('p_spreadsheet '||	p_spreadsheet);
	  print_log('p_suffix	 '||p_suffix);
	  print_log('p_batch_id	 '||p_batch_id);
	  print_log('p_request_id '||p_request_id);
	  print_log('p_tech_sur_flag '||p_tech_sur_flag);
	INSERT FIRST

		-- value must be entered if it is a required attribute
		WHEN s_mandatory_flag = 'Y' AND s_value IS null THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				 COLUMN_NAME,
				 TABLE_NAME,
				 BATCH_ID,
				 INTERFACE_LINE_ID,
				 ERROR_MESSAGE_NAME,
				 CREATED_BY,
				 CREATION_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_DATE,
				 REQUEST_ID,
				 ENTITY_TYPE,
				 ENTITY_ATTR_NAME,
				 ERROR_VALUE_DATATYPE,
				 AUCTION_HEADER_ID,
				 BID_NUMBER,
				 LINE_NUMBER,
				 ATTRIBUTE_NAME,
				 EXPIRATION_DATE,
				 TOKEN1_NAME,
				 TOKEN1_VALUE,
				 TOKEN2_NAME,
				 TOKEN2_VALUE,
                                 WORKSHEET_NAME,
                                 WORKSHEET_SEQUENCE_NUMBER,
                                 ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				 fnd_message.get_string('PON', 'PON_AUCTS_BID_VALUE' || p_suffix),
				 'PON_BID_ATTRIBUTE_VALUES',
				 p_batch_id,
				 s_interface_line_id,
				 'PON_AUC_ATTR_VALUE_REQ' || p_suffix,
				 p_userid,
				 sysdate,
				 p_userid,
				 sysdate,
				 p_request_id,
				 'BID_ATTRS',
				 'Value',
				 'TXT',
				 p_auc_header_id,
				 p_bid_number,
				 s_line_number,
				 s_attribute_name,
				 g_exp_date,
				 'LINENUMBER',
				 s_document_disp_line_number,
				 'ATTRIBUTENAME',
				 s_trunc_attr_name,
                                 s_worksheet_name,
                                 s_worksheet_sequence_number,
                                 s_entity_message_code)

		-- value must be among buyer specified values if type is LOV
		WHEN p_spreadsheet in (g_txt_upload_mode, g_xml_upload_mode) AND s_scoring_type = 'LOV' AND s_value is not NULL AND NOT EXISTS
			(SELECT bs.score
			FROM pon_attribute_scores bs
			WHERE bs.auction_header_id = p_auc_header_id
				AND bs.line_number = s_line_number
				AND bs.attribute_sequence_number = s_sequence_number
				AND bs.value = s_value) THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				 COLUMN_NAME,
				 TABLE_NAME,
				 BATCH_ID,
				 INTERFACE_LINE_ID,
				 ERROR_MESSAGE_NAME,
				 CREATED_BY,
				 CREATION_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_DATE,
				 REQUEST_ID,
				 ENTITY_TYPE,
				 ENTITY_ATTR_NAME,
				 ERROR_VALUE,
				 ERROR_VALUE_DATATYPE,
				 AUCTION_HEADER_ID,
				 BID_NUMBER,
				 LINE_NUMBER,
				 ATTRIBUTE_NAME,
				 EXPIRATION_DATE,
                                 WORKSHEET_NAME,
                                 WORKSHEET_SEQUENCE_NUMBER,
                                 ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				 fnd_message.get_string('PON', 'PON_AUCTS_BID_VALUE' || p_suffix),
				 'PON_BID_ATTRIBUTE_VALUES',
				 p_batch_id,
				 s_interface_line_id,
				 'PON_AUC_INVALID_ATTR_VALUE'  || p_suffix,
				 p_userid,
				 sysdate,
				 p_userid,
				 sysdate,
				 p_request_id,
				 'BID_ATTRS',
				 'Value',
				 s_value,
				 'TXT',
				 p_auc_header_id,
				 p_bid_number,
				 s_line_number,
				 s_attribute_name,
				 g_exp_date,
                                 s_worksheet_name,
                                 s_worksheet_sequence_number,
                                 s_entity_message_code)

	SELECT
		ba.value s_value,
		ba.line_number s_line_number,
		ba.sequence_number s_sequence_number,
		ba.attribute_name s_attribute_name,
                substr(ba.attribute_name, 0, 2000) s_trunc_attr_name,
		aa.mandatory_flag s_mandatory_flag,
		aa.scoring_type s_scoring_type,
		al.document_disp_line_number s_document_disp_line_number,
		decode(p_spreadsheet, g_xml_upload_mode, ba.interface_line_id, g_txt_upload_mode, bl.interface_line_id, null) s_interface_line_id,
                decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_name, null) s_worksheet_name,
                decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_sequence_number, null) s_worksheet_sequence_number,
                decode(p_spreadsheet, g_xml_upload_mode, 'PON_AUC_ATTRIBUTES', null) s_entity_message_code
	FROM pon_bid_attribute_values ba
             , pon_auction_attributes aa
             , pon_auction_item_prices_all al
             , pon_bid_item_prices bl
             , pon_bid_headers pbh
	WHERE ba.bid_number = p_bid_number
                AND ba.line_number <> -1
		AND aa.auction_header_id = ba.auction_header_id
		AND aa.line_number = ba.line_number
		AND aa.sequence_number = ba.sequence_number
		AND al.auction_header_id = ba.auction_header_id
		AND al.line_number = ba.line_number
		AND bl.bid_number = ba.bid_number
		AND bl.line_number = ba.line_number
		AND (nvl(bl.is_changed_line_flag, 'Y') = 'Y' OR p_tech_sur_flag = 'Y')
		AND (p_spreadsheet = g_online_mode OR bl.batch_id = p_batch_id)
                AND pbh.bid_number = bl.bid_number
                AND (pbh.SURROG_BID_FLAG = 'Y' OR nvl(al.close_bidding_date, sysdate+1) > sysdate);
	print_log('Numner of errors inserted = '||SQL%ROWCOUNT);
  print_log('validate_attributes End');
END validate_attributes;

PROCEDURE validate_cost_factors
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_spreadsheet		IN VARCHAR2,
	p_price_precision	IN pon_bid_headers.number_price_decimals%TYPE,
	p_amt_precision		IN fnd_currencies.precision%TYPE,
	p_suffix			IN VARCHAR2,
	p_batch_id			IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE
) IS
BEGIN
  print_log('validate_cost_factors Start');
  	  print_log('p_auc_header_id '||p_auc_header_id);
	  print_log('p_bid_number '||p_bid_number);
	  print_log('p_interface_type '||p_interface_type);
	  print_log('p_userid '||p_userid);
	  print_log('p_spreadsheet '||	p_spreadsheet);
	  print_log('p_price_precision '||	p_price_precision);
	  print_log('p_amt_precision '||	p_amt_precision);
	  print_log('p_suffix	 '||p_suffix);
	  print_log('p_batch_id	 '||p_batch_id);
	  print_log('p_request_id '||p_request_id);
	-- The following validations are performed only for SUPPLIER cost factors
	INSERT FIRST

		-- bid_currency_value must recieve a bid
		WHEN s_bid_currency_value IS null THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				PRICE_ELEMENT_TYPE_ID,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				s_column_name,
				'PON_BID_PRICE_ELEMENTS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PE_VALUE_REQ' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PFS',
				'BidCurrencyValue',
				'TXT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_price_element_type_id,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'PRICEELEMENTNAME',
				s_name,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- Line price cost factor must be positive
		WHEN s_sequence_number = -10 AND s_bid_currency_value <= 0 THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				PRICE_ELEMENT_TYPE_ID,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				entity_message_code)
			VALUES
				(p_interface_type,
				s_column_name,
				'PON_BID_PRICE_ELEMENTS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PE_MUST_BE_POS' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PFS',
				'BidCurrencyValue',
				s_bid_currency_value,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_price_element_type_id,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'PRICEELEMENTNAME',
				s_name,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- Cost factor value must be postive or zero if not line price
		WHEN s_sequence_number <> -10 AND s_bid_currency_value < 0 THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				PRICE_ELEMENT_TYPE_ID,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				s_column_name,
				'PON_BID_PRICE_ELEMENTS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PE_MUST_BE_POS_ZERO' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PFS',
				'BidCurrencyValue',
				s_bid_currency_value,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_price_element_type_id,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'PRICEELEMENTNAME',
				s_name,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- bid_currency_precision must not exceed price precision for PER_UNIT cf
		WHEN s_pricing_basis = 'PER_UNIT'
			AND validate_price_precision(s_bid_currency_value,
				p_price_precision) = 'F' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				PRICE_ELEMENT_TYPE_ID,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				s_column_name,
				'PON_BID_PRICE_ELEMENTS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PE_INVALID_BID_PREC' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PFS',
				'BidCurrencyValue',
				s_bid_currency_value,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_price_element_type_id,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'PRICEELEMENTNAME',
				s_name,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)

		-- bid_currency_precision must not exceed currency precision for FIXED_AMOUNT cf
		WHEN s_pricing_basis = 'FIXED_AMOUNT'
			AND validate_currency_precision(s_bid_currency_value,
				p_amt_precision) = 'F' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				PRICE_ELEMENT_TYPE_ID,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				entity_message_code)
			VALUES
				(p_interface_type,
				s_column_name,
				'PON_BID_PRICE_ELEMENTS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PE_INVALID_CURR_PREC' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PFS',
				'BidCurrencyValue',
				s_bid_currency_value,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_price_element_type_id,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'PRICEELEMENTNAME',
				s_name,
				s_worksheet_name,
				s_worksheet_sequence_number,
				s_entity_message_code)
	SELECT
		bpf.bid_currency_value s_bid_currency_value,
		bpf.sequence_number s_sequence_number,
		bpf.pricing_basis s_pricing_basis,
		bpf.line_number s_line_number,
		bpf.price_element_type_id s_price_element_type_id,
		al.document_disp_line_number s_document_disp_line_number,
		decode(p_spreadsheet, g_txt_upload_mode, bl.interface_line_id,
				      g_xml_upload_mode, bpf.interface_line_id,
				      to_number(null)) s_interface_line_id,
		pft.name s_name,
		decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_name, to_char(null)) s_worksheet_name,
		decode(p_spreadsheet, g_xml_upload_mode, 'PON_AUC_PRICE_ELEMENTS', to_char(null))	s_entity_message_code,
		decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_sequence_number, to_number(null))	s_worksheet_sequence_number,
		decode(p_spreadsheet, g_xml_upload_mode,
				fnd_message.get_string('PON', 'PON_AUCTS_ATTR_BID_VALUE' || p_suffix),
				fnd_message.get_string('PON', 'PON_AUC_PE_BID_VALUE_REQ' || p_suffix)) s_column_name
	FROM pon_bid_price_elements bpf
             , pon_auction_item_prices_all al
             , pon_bid_item_prices bl
             , pon_price_element_types_tl pft
             , pon_bid_headers pbh
	WHERE bpf.bid_number = p_bid_number
		AND bpf.pf_type = 'SUPPLIER'			-- only validate SUPPLIER cost factors
		AND al.auction_header_id = bpf.auction_header_id
		AND al.line_number = bpf.line_number
		AND bl.bid_number = bpf.bid_number
		AND bl.line_number= bpf.line_number
		AND pft.price_element_type_id = bpf.price_element_type_id
		AND pft.language = userenv('LANG')
		AND bl.is_changed_line_flag = 'Y'
		AND (p_spreadsheet = g_online_mode OR bl.batch_id = p_batch_id)
                AND pbh.bid_number = bl.bid_number
                AND (pbh.SURROG_BID_FLAG = 'Y' OR nvl(al.close_bidding_date, sysdate+1) > sysdate);
  print_log('validate_cost_factors End');
END validate_cost_factors;

PROCEDURE validate_price_breaks
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_spreadsheet		IN VARCHAR2,
	p_price_precision	IN pon_bid_headers.number_price_decimals%TYPE,
	p_trans_view		IN VARCHAR2,
	p_blanket			IN VARCHAR2,
	p_header_disp_pf	IN VARCHAR2,
	p_po_start_date		IN pon_auction_headers_all.po_start_date%TYPE,
	p_po_end_date		IN pon_auction_headers_all.po_end_date%TYPE,
	p_auc_close_date	IN pon_auction_headers_all.close_bidding_date%TYPE,
	p_suffix			IN VARCHAR2,
	p_batch_id			IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE
) IS
BEGIN
  print_log('validate_price_breaks Start');
  	  print_log('p_auc_header_id '||p_auc_header_id);
	  print_log('p_bid_number '||p_bid_number);
	  print_log('p_interface_type '||p_interface_type);
	  print_log('p_userid '||p_userid);
	  print_log('p_spreadsheet '||	p_spreadsheet);
	  print_log('p_price_precision '||	p_price_precision);
	  print_log('p_trans_view '||	p_trans_view);
	  print_log('p_blanket '||	p_blanket);
	  print_log('p_header_disp_pf '||	p_header_disp_pf);
	  print_log('p_po_start_date '||	p_po_start_date);
	  print_log('p_po_end_date '||	p_po_end_date);
	  print_log('p_auc_close_date '||	p_auc_close_date);
	  print_log('p_suffix	 '||p_suffix);
	  print_log('p_batch_id	 '||p_batch_id);
	  print_log('p_request_id '||p_request_id);

	INSERT ALL

		-- quantity must be positive or zero
		WHEN s_quantity < 0 THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_QUANTITY'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUCTS_PB_QUANTITY_POSITIVE',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'Quantity',
				s_quantity,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUM',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- bid_currency_unit_price must be positive
		-- Only applier if price_type is PRICE
		WHEN s_price_type = 'PRICE' AND s_bid_currency_unit_price < 0 THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_PRICE'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PB_POS_OR_ZERO',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'BidCurrencyUnitPrice',
				s_bid_currency_unit_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- bid_currency_unit_price precision must not exceed price precision
		-- Only applier if price_type is PRICE
		WHEN s_price_type = 'PRICE' AND validate_price_precision(
			s_bid_currency_unit_price, p_price_precision) = 'F' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_PRICE'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PB_INVALID_BID_PREC' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'BidCurrencyUnitPrice',
				s_bid_currency_unit_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- The transformed price should be positive
		-- Since bid_currency_price is the same as bid_currency_unit_price
		-- in untransformed view, we can use s_price (which is the
		-- transformed price in auction currency)
		-- NOTE: rate conversion is unneccessary since we only check sign
		WHEN p_trans_view = 'N' AND s_price < 0 THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				p_batch_id,
				s_interface_line_id,
				'PON_PB_BIDPRICE_INVALID_1',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'BidCurrencyPrice',
				s_bid_currency_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- bid_currency_price must be positive
		WHEN p_trans_view = 'Y' AND s_bid_currency_price < 0 THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				p_batch_id,
				s_interface_line_id,
				decode(p_header_disp_pf, 'Y',
					'PON_PB_BIDPRICE_INVALID_2' || p_suffix,
					'PON_AUC_PB_POS_OR_ZERO'),
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'BidCurrencyPrice',
				s_bid_currency_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- bid_currency_price precision must not exceed price precision
		WHEN validate_price_precision(
			s_bid_currency_price, p_price_precision) = 'F' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PB_INVALID_BID_PREC' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'BidCurrencyPrice',
				s_bid_currency_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- price_discount must be 0 to 100
		-- Only applies if price_type is PRICE DISCOUNT
		WHEN s_price_type = 'PRICE DISCOUNT'
			AND (s_price_discount < 0 OR s_price_discount > 100) THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_PRICE'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_INVALID_PRICE_DISCOUNT',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'PriceDiscount',
				s_price_discount,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- effective_start_date must be past the current date
		WHEN s_effective_start_date < s_current_date THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_AUCTS_EFFECTIVE_FROM'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_FROMDATE_AFTER_CURDATE',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'EffectiveStartDate',
				s_effective_start_date,
				'DAT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)
		-- effective_start_date must be after po start date
		WHEN s_effective_start_date < p_po_start_date THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_AUCTS_EFFECTIVE_FROM'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_BAD_PB_EFF_FDATE_2',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'EffectiveStartDate',
				s_effective_start_date,
				'DAT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- effective_start_date must be before po end date
		WHEN s_effective_start_date > p_po_end_date THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_AUCTS_EFFECTIVE_FROM'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_BAD_PB_EFF_FDATE_3',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'EffectiveStartDate',
				s_effective_start_date,
				'DAT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- effective start date must be after auction close date
		WHEN s_effective_start_date < p_auc_close_date THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_AUCTS_EFFECTIVE_FROM'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_BAD_PB_EFF_FDATE_1',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'EffectiveStartDate',
				s_effective_start_date,
				'DAT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)
		-- effective_end_date must be after current date
		WHEN s_effective_end_date < s_current_date THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_AUCTS_EFFECTIVE_TO'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_TODATE_AFTER_CURDATE',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'EffectiveEndDate',
				s_effective_end_date,
				'DAT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- effective_end_date must be after po start date
		WHEN s_effective_end_date < p_po_start_date THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_AUCTS_EFFECTIVE_TO'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_BAD_PB_EFF_TDATE_2',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'EffectiveEndDate',
				s_effective_end_date,
				'DAT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- effective_end_date must be before po end date
		WHEN s_effective_end_date > p_po_end_date THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_AUCTS_EFFECTIVE_TO'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_BAD_PB_EFF_TDATE_3',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'EffectiveEndDate',
				s_effective_end_date,
				'DAT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- effective_end_date must be after auction close date
		WHEN s_effective_end_date < p_auc_close_date THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_AUCTS_EFFECTIVE_TO'), null ),
				p_batch_id,
				s_interface_line_id ,
				'PON_AUC_BAD_PB_EFF_TDATE_1',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'EffectiveEndDate',
				s_effective_end_date,
				'DAT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)
		-- To be considered valid, the price break must have one of the following:
		-- ship_to_organization_id, ship_location_id, quantity,
		-- effective_start_date, effective_end_date
		WHEN s_ship_to_organization_id IS null
			AND s_ship_to_location_id IS null
			AND s_quantity IS null
			AND s_effective_start_date IS null
			AND s_effective_end_date IS null THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				ERROR_VALUE_DATATYPE,
				ERROR_VALUE,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUCTS_PB_MUST_BE_ENTERED',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				'TXT',
				'',
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)
		-- effective_start_date must be before effective_end_date
		WHEN s_effective_start_date > s_effective_end_date THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_AUCTS_EFFECTIVE_TO'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_INVALID_EFF_DATES',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				'EffectiveEndDate',
				s_effective_end_date,
				'DAT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- Either bid_currency_unit_price or price_discount must have a value
		WHEN s_bid_currency_unit_price IS null AND s_price_discount IS null THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				ERROR_VALUE_DATATYPE,
				ERROR_VALUE,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_PRICE'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PB_PRICE_REQ',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				'TXT',
				'',
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- CUMULATIVE price breaks cannot have start and end dates
		WHEN s_price_break_type = 'CUMULATIVE'
			AND (s_effective_start_date IS NOT null
			OR s_effective_end_date IS NOT null) THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUCTS_PB_CUMM_EFF_DATES',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PBS',
				nvl2(s_effective_start_date, 'EffectiveEndDate',
					'EffectiveStartDate'),
				nvl(s_effective_end_date, s_effective_end_date),
				'DAT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

	SELECT
		sysdate s_current_date,
		bpb.ship_to_organization_id s_ship_to_organization_id,
		bpb.ship_to_location_id s_ship_to_location_id,
		bpb.quantity s_quantity,
		bpb.price s_price,
		bpb.price_type s_price_type,
		bpb.bid_currency_price s_bid_currency_price,
		bpb.bid_currency_unit_price s_bid_currency_unit_price,
		bpb.price_discount s_price_discount,
		bpb.effective_start_date s_effective_start_date,
		bpb.effective_end_date s_effective_end_date,
		bpb.line_number s_line_number,
		bpb.shipment_number s_shipment_number,
		decode(p_spreadsheet, g_xml_upload_mode,
							  bpb.interface_line_id,
							  bl.interface_line_id
			  ) s_interface_line_id,
		al.document_disp_line_number s_document_disp_line_number,
		al.price_break_type s_price_break_type,
		decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_name, null) s_worksheet_name,
        decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_sequence_number, null) s_worksheet_seq_num,
		decode(p_spreadsheet, g_xml_upload_mode,
					  'PON_AUCTS_PRICE_BREAKS',
					  null
			  ) s_entity_name
	FROM pon_bid_shipments bpb
             , pon_bid_item_prices bl
             , pon_auction_item_prices_all al
             , pon_bid_headers pbh
	WHERE bpb.bid_number = p_bid_number
		AND bl.bid_number = bpb.bid_number
		AND bl.line_number = bpb.line_number
		AND al.auction_header_id = bpb.auction_header_id
		AND al.line_number = bpb.line_number
		AND bl.is_changed_line_flag = 'Y'
		AND (p_spreadsheet = g_online_mode OR bl.batch_id = p_batch_id)
                AND pbh.bid_number = bl.bid_number
                AND (pbh.SURROG_BID_FLAG = 'Y' OR nvl(al.close_bidding_date, sysdate+1) > sysdate);

  print_log('validate_price_breaks End');
END validate_price_breaks;



/*========================================================*
 * The following validations are performed
 * 1. Min Quantity should not be null or negative
 * 2. Max Quantity should not be null or negative
 * 3. Max quantity should be greater or equal to the min quantity
 * 4. The ranges of min-max quantities should not overlap across tiers for a given line
 * 5. The price tier price should not be null and negative
 * 6. Precision of the price entered should be less than the auction currency precision
 *.7. In case of an SPO the quantity entered at the line level must be equal to the
 *    maximum quantity of all the price tiers.
 *.8. In case of an SPO the price entered at the line level must be equal to the price
 *    corresponding to the maximum quantity of all the price tiers.
 * =======================================================*/

PROCEDURE VALIDATE_QTY_BASED_PRICE_TIERS
(
    p_auc_header_id     IN pon_bid_item_prices.auction_header_id%TYPE,
    p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
    p_interface_type	IN pon_interface_errors.interface_type%TYPE,
    p_userid			IN pon_interface_errors.created_by%TYPE,
    p_spreadsheet		IN VARCHAR2,
    p_price_precision	IN pon_bid_headers.number_price_decimals%TYPE,
    p_batch_id			IN pon_interface_errors.batch_id%TYPE,
    p_request_id		IN pon_interface_errors.request_id%TYPE,
    p_contract_type     IN pon_bid_headers.contract_type%TYPE
) IS

BEGIN

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VALIDATE_QTY_BASED_PRICE_TIERS',
      message  => 'Entering Procedure' || ', p_auc_header_id = ' || p_auc_header_id || ' , p_bid_number = ' ||p_bid_number ||' , p_interface_type = '
                  ||p_interface_type || ' , p_userid = '||p_userid||' ,p_spreadsheet = '||p_spreadsheet||' ,p_price_precision = '||p_price_precision
                  ||' ,p_batch_id = '||p_batch_id||' ,p_request_id = '||p_request_id || ' , p_contract_type = ' || p_contract_type );
  END IF; --}


    INSERT ALL

          -- The min quantity is a required field. If the min quantity is null,
          -- we insert rows into the interface errors table.

            WHEN
            (
              s_min_quantity IS NULL
              OR
              s_min_quantity = g_null_int
            )
            THEN
            INTO pon_interface_errors
                (INTERFACE_TYPE,
                TABLE_NAME,
                COLUMN_NAME,
                BATCH_ID,
                INTERFACE_LINE_ID,
                ERROR_MESSAGE_NAME,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                REQUEST_ID,
                ENTITY_TYPE,
                ENTITY_ATTR_NAME,
                ERROR_VALUE_NUMBER,
                ERROR_VALUE_DATATYPE,
                AUCTION_HEADER_ID,
                BID_NUMBER,
                LINE_NUMBER,
                SHIPMENT_NUMBER,
                EXPIRATION_DATE,
                TOKEN1_NAME,
                TOKEN1_VALUE,
                WORKSHEET_NAME,
		WORKSHEET_SEQUENCE_NUMBER,
		ENTITY_MESSAGE_CODE)
            VALUES
                (p_interface_type,
                'PON_BID_SHIPMENTS',
                decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_MIN_QUANTITY'), null ),
                p_batch_id,
                s_interface_line_id,
                'PON_AUCTS_PT_MIN_QUANTITY_REQ',
                p_userid,
                sysdate,
                p_userid,
                sysdate,
                p_request_id,
                'BID_PTS',
                'Quantity',
                s_min_quantity,
                'NUM',
                p_auc_header_id,
                p_bid_number,
                s_line_number,
                s_shipment_number,
                g_exp_date,
                'LINENUM',
                s_document_disp_line_number,
		s_worksheet_name,
		s_worksheet_seq_num,
		s_entity_name
                )

              -- The max quantity is a required field. If the min quantity is null,
              -- we insert rows into the interface errors table.

            WHEN
            (
               s_max_quantity IS NULL
               OR
               s_max_quantity = g_null_int
            )
            THEN
            INTO pon_interface_errors
                (INTERFACE_TYPE,
                TABLE_NAME,
                COLUMN_NAME,
                BATCH_ID,
                INTERFACE_LINE_ID,
                ERROR_MESSAGE_NAME,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                REQUEST_ID,
                ENTITY_TYPE,
                ENTITY_ATTR_NAME,
                ERROR_VALUE_NUMBER,
                ERROR_VALUE_DATATYPE,
                AUCTION_HEADER_ID,
                BID_NUMBER,
                LINE_NUMBER,
                SHIPMENT_NUMBER,
                EXPIRATION_DATE,
                TOKEN1_NAME,
                TOKEN1_VALUE,
		WORKSHEET_NAME,
		WORKSHEET_SEQUENCE_NUMBER,
		ENTITY_MESSAGE_CODE
                )
            VALUES
                (p_interface_type,
                'PON_BID_SHIPMENTS',
                decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_MAX_QUANTITY'), null ),
                p_batch_id,
                s_interface_line_id,
                'PON_AUCTS_PT_MAX_QUANTITY_REQ',
                p_userid,
                sysdate,
                p_userid,
                sysdate,
                p_request_id,
                'BID_PTS',
                'MaxQuantity',
                s_max_quantity,
                'NUM',
                p_auc_header_id,
                p_bid_number,
                s_line_number,
                s_shipment_number,
                g_exp_date,
                'LINENUM',
                s_document_disp_line_number,
		s_worksheet_name,
		s_worksheet_seq_num,
		s_entity_name
                )

            -- The min quantity should be a positive number. i.e. strictly greater than zero.

            WHEN
            (
                (s_min_quantity IS NOT NULL AND
                 s_min_quantity <= 0 AND
                 s_min_quantity <> g_null_int)
            )
            THEN
            INTO pon_interface_errors
                (INTERFACE_TYPE,
                TABLE_NAME,
                COLUMN_NAME,
                BATCH_ID,
                INTERFACE_LINE_ID,
                ERROR_MESSAGE_NAME,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                REQUEST_ID,
                ENTITY_TYPE,
                ENTITY_ATTR_NAME,
                ERROR_VALUE_NUMBER,
                ERROR_VALUE_DATATYPE,
                AUCTION_HEADER_ID,
                BID_NUMBER,
                LINE_NUMBER,
                SHIPMENT_NUMBER,
                EXPIRATION_DATE,
                TOKEN1_NAME,
                TOKEN1_VALUE,
		WORKSHEET_NAME,
		WORKSHEET_SEQUENCE_NUMBER,
		ENTITY_MESSAGE_CODE
                )
            VALUES
                (p_interface_type,
                'PON_BID_SHIPMENTS',
                decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_MIN_QUANTITY'), null ),
                p_batch_id,
                s_interface_line_id,
                'PON_AUCTS_PT_QUANTITY_POSITIVE',
                p_userid,
                sysdate,
                p_userid,
                sysdate,
                p_request_id,
                'BID_PTS',
                'Quantity',
                s_min_quantity,
                'NUM',
                p_auc_header_id,
                p_bid_number,
                s_line_number,
                s_shipment_number,
                g_exp_date,
                'LINENUM',
                s_document_disp_line_number,
		s_worksheet_name,
		s_worksheet_seq_num,
		s_entity_name
                )

            -- The max quantity should be a positive number. i.e. strictly greater than zero.

            WHEN
            (
                (s_max_quantity IS NOT NULL AND
                 s_max_quantity <= 0 AND
                 s_max_quantity <> g_null_int)
            )
            THEN
            INTO pon_interface_errors
                (INTERFACE_TYPE,
                TABLE_NAME,
                COLUMN_NAME,
                BATCH_ID,
                INTERFACE_LINE_ID,
                ERROR_MESSAGE_NAME,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                REQUEST_ID,
                ENTITY_TYPE,
                ENTITY_ATTR_NAME,
                ERROR_VALUE_NUMBER,
                ERROR_VALUE_DATATYPE,
                AUCTION_HEADER_ID,
                BID_NUMBER,
                LINE_NUMBER,
                SHIPMENT_NUMBER,
                EXPIRATION_DATE,
                TOKEN1_NAME,
                TOKEN1_VALUE,
		WORKSHEET_NAME,
		WORKSHEET_SEQUENCE_NUMBER,
		ENTITY_MESSAGE_CODE
                )
            VALUES
                (p_interface_type,
                'PON_BID_SHIPMENTS',
                decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_MAX_QUANTITY'), null ),
                p_batch_id,
                s_interface_line_id,
                'PON_AUCTS_PT_QUANTITY_POSITIVE',
                p_userid,
                sysdate,
                p_userid,
                sysdate,
                p_request_id,
                'BID_PTS',
                'MaxQuantity',
                s_max_quantity,
                'NUM',
                p_auc_header_id,
                p_bid_number,
                s_line_number,
                s_shipment_number,
                g_exp_date,
                'LINENUM',
                s_document_disp_line_number,
		s_worksheet_name,
		s_worksheet_seq_num,
		s_entity_name
                )

          -- max quantity should be greater or equal to the min quantity. i.e if min quantity should not
          -- be greater than max quantity

          WHEN
          (
               s_min_quantity > s_max_quantity
          )
          THEN
          INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE
                )
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_MAX_QUANTITY'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_QT_MAX_MIN_QTY_ERR',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PTS',
				'MaxQuantity',
				s_max_quantity,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUM',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name
                )

                WHEN (
                  p_spreadsheet = g_xml_upload_mode  AND
                  EXISTS (
                          SELECT 'Y' FROM pon_bid_shipments bpb1 WHERE
                            bpb1.auction_header_id = p_auc_header_id AND
                            bpb1.bid_number = p_bid_number AND
                            bpb1.line_number = s_line_number AND
                             bpb1.SHIPMENT_NUMBER <> s_shipment_number AND
                            (bpb1.quantity <= s_min_quantity AND
                              s_min_quantity <= bpb1.max_quantity)
                          )
                      )

                  THEN
                    INTO pon_interface_errors
                    (INTERFACE_TYPE,
                    TABLE_NAME,
                    COLUMN_NAME,
                    BATCH_ID,
                    INTERFACE_LINE_ID,
                    ERROR_MESSAGE_NAME,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    REQUEST_ID,
                    ENTITY_TYPE,
                    ENTITY_ATTR_NAME,
                    ERROR_VALUE_NUMBER,
                    ERROR_VALUE_DATATYPE,
                    AUCTION_HEADER_ID,
                    BID_NUMBER,
                    LINE_NUMBER,
                    SHIPMENT_NUMBER,
                    EXPIRATION_DATE,
                    TOKEN1_NAME,
                    TOKEN1_VALUE,
				    WORKSHEET_NAME,
				    WORKSHEET_SEQUENCE_NUMBER,
				    ENTITY_MESSAGE_CODE)
                  VALUES
                    (p_interface_type,
                    'PON_BID_SHIPMENTS',
                    decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_MIN_QUANTITY'), null ),
                    p_batch_id,
                    s_interface_line_id,
                    'PON_AUC_OVERLAP_RANGES_QT',
                    p_userid,
                    sysdate,
                    p_userid,
                    sysdate,
                    p_request_id,
                    'BID_PTS',
                    'Quantity',
                    s_min_quantity,
                    'NUM',
                    p_auc_header_id,
                    p_bid_number,
                    s_line_number,
                    s_shipment_number,
                    g_exp_date,
                    'LINENUM',
                    s_document_disp_line_number,
			    	s_worksheet_name,
			    	s_worksheet_seq_num,
				    s_entity_name)

            --when max quantity is in some other range
            --but min quantity is not in some other range
            --For case like: row1 is 5-10, row2 is 1-100
            --The error message only show up once.
                WHEN (
                  p_spreadsheet = g_xml_upload_mode  AND
                  EXISTS (
                          SELECT 'Y' FROM pon_bid_shipments bpb1 WHERE
                            bpb1.auction_header_id = p_auc_header_id AND
                            bpb1.bid_number = p_bid_number AND
                            bpb1.line_number = s_line_number AND
                             bpb1.SHIPMENT_NUMBER <> s_shipment_number AND
                            ( NOT(bpb1.quantity <= s_min_quantity AND
                              s_min_quantity <= bpb1.max_quantity)
                            AND
                            (bpb1.quantity <= s_max_quantity AND
                              s_max_quantity <= bpb1.max_quantity))
                          )
                      )

                  THEN
                    INTO pon_interface_errors
                    (INTERFACE_TYPE,
                    TABLE_NAME,
                    COLUMN_NAME,
                    BATCH_ID,
                    INTERFACE_LINE_ID,
                    ERROR_MESSAGE_NAME,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    REQUEST_ID,
                    ENTITY_TYPE,
                    ENTITY_ATTR_NAME,
                    ERROR_VALUE_NUMBER,
                    ERROR_VALUE_DATATYPE,
                    AUCTION_HEADER_ID,
                    BID_NUMBER,
                    LINE_NUMBER,
                    SHIPMENT_NUMBER,
                    EXPIRATION_DATE,
                    TOKEN1_NAME,
                    TOKEN1_VALUE,
		    WORKSHEET_NAME,
		    WORKSHEET_SEQUENCE_NUMBER,
		    ENTITY_MESSAGE_CODE)
                  VALUES
                    (p_interface_type,
                    'PON_BID_SHIPMENTS',
                    decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_MAX_QUANTITY'), null ),
                    p_batch_id,
                    s_interface_line_id,
                    'PON_AUC_OVERLAP_RANGES_QT',
                    p_userid,
                    sysdate,
                    p_userid,
                    sysdate,
                    p_request_id,
                    'BID_PTS',
                    'MaxQuantity',
                    s_max_quantity,
                    'NUM',
                    p_auc_header_id,
                    p_bid_number,
                    s_line_number,
                    s_shipment_number,
                    g_exp_date,
                    'LINENUM',
                    s_document_disp_line_number,
			    	s_worksheet_name,
			    	s_worksheet_seq_num,
				    s_entity_name)

          -- bid_currency_unit_price must not be null
          WHEN (s_bid_currency_unit_price IS NULL
                OR
                s_bid_currency_unit_price = g_null_int) THEN

			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE
                )
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_PRICE'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PT_PRICE_REQ',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PTS',
				'BidCurrencyUnitPrice',
				s_bid_currency_unit_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUM',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name
                )

        -- bid_currency_unit_price must be positive

		    WHEN
                (s_bid_currency_unit_price IS NOT NULL AND
                 s_bid_currency_unit_price <> g_null_int AND
                 s_bid_currency_unit_price <= 0)
            THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE
                )
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_PRICE'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUCTS_QT_PRICE_POSITIVE',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PTS',
				'BidCurrencyUnitPrice',
				s_bid_currency_unit_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUM',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name
                )

		-- bid_currency_unit_price precision must not exceed price precision

		WHEN validate_price_precision(s_bid_currency_unit_price, p_price_precision) = 'F' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE
                )
			VALUES
				(p_interface_type,
				'PON_BID_SHIPMENTS',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_PRICE'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_QT_INVALID_BID_PREC',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PTS',
				'BidCurrencyUnitPrice',
				s_bid_currency_unit_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name
                )

            -- in case of an SPO the quantity entered at the line level must be equal to the
            -- maximum quantity of all the price tiers.

            WHEN
            (
                p_contract_type = 'STANDARD'
                and s_max_ship_qty = s_max_quantity
                and s_max_ship_qty <> s_bid_quantity
            )
            THEN
            INTO pon_interface_errors
                (INTERFACE_TYPE,
                TABLE_NAME,
                COLUMN_NAME,
                BATCH_ID,
                INTERFACE_LINE_ID,
                ERROR_MESSAGE_NAME,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                REQUEST_ID,
                ENTITY_TYPE,
                ENTITY_ATTR_NAME,
                ERROR_VALUE_NUMBER,
                ERROR_VALUE_DATATYPE,
                AUCTION_HEADER_ID,
                BID_NUMBER,
                LINE_NUMBER,
                SHIPMENT_NUMBER,
                EXPIRATION_DATE,
                TOKEN1_NAME,
                TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE
                )
            VALUES
                (p_interface_type,
                'PON_BID_ITEM_PRICES',
                decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_MAX_QUANTITY'), null ),
                p_batch_id,
                s_interface_line_id,
                'PON_BID_QTY_NOT_WITHIN_TIERS',
                p_userid,
                sysdate,
                p_userid,
                sysdate,
                p_request_id,
                'BID_PTS',
                'MaxQuantity',
                s_max_quantity,
                'NUM',
                p_auc_header_id,
                p_bid_number,
                s_line_number,
                s_shipment_number,
                g_exp_date,
                'LINENUM',
                s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name
                )


          -- in case of an SPO the price entered at the line level must be equal to the price
          -- corresponding to the maximum quantity of all the price tiers.
          WHEN (p_contract_type = 'STANDARD'
                and s_max_ship_qty = s_bid_quantity
                and s_max_ship_qty = s_max_quantity
                and s_bid_price <> s_shipments_price) THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE
                )
			VALUES
				(p_interface_type,
				'PON_BID_ITEM_PRICES',
				decode(p_spreadsheet, g_xml_upload_mode, fnd_message.get_string('PON', 'PON_BIDS_PRICE'), null ),
				p_batch_id,
				s_interface_line_id,
				'PON_BID_PRICE_NOT_WITHIN_TIERS',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PTS',
				'BidCurrencyUnitPrice',
				s_bid_currency_unit_price,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUM',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name
                )

        SELECT bpb.quantity s_min_quantity,
              bpb.max_quantity s_max_quantity,
              bpb.price s_shipments_price,
              bl.quantity s_bid_quantity,
              bl.price s_bid_price,
              bpb.bid_currency_unit_price s_bid_currency_unit_price,
              bpb.line_number s_line_number,
              bpb.shipment_number s_shipment_number,
              decode(p_spreadsheet,   g_xml_upload_mode,   bpb.interface_line_id,   bl.interface_line_id) s_interface_line_id,
              al.document_disp_line_number s_document_disp_line_number,
              max_bid_shipments.max_quantity s_max_ship_qty,
              decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_name, null) s_worksheet_name,
              decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_sequence_number, null) s_worksheet_seq_num,
		      decode(p_spreadsheet, g_xml_upload_mode,
					  'PON_AUCTS_PRICE_TIERS',
					  null
			  ) s_entity_name
        FROM pon_bid_shipments bpb,
              pon_bid_item_prices bl,
              pon_auction_item_prices_all al,
                (SELECT MAX(shipments.max_quantity) max_quantity,
                     shipments.bid_number,
                     shipments.line_number
                 FROM pon_bid_shipments shipments
                      WHERE shipments.bid_number = p_bid_number
                 GROUP BY shipments.bid_number,
                     shipments.line_number) max_bid_shipments
                 , pon_bid_headers pbh
        WHERE bpb.bid_number = p_bid_number
         AND bpb.bid_number = max_bid_shipments.bid_number
         AND bpb.line_number = max_bid_shipments.line_number
         AND bl.bid_number = bpb.bid_number
         AND bl.line_number = bpb.line_number
         AND al.auction_header_id = bpb.auction_header_id
         AND al.line_number = bpb.line_number
         AND bl.is_changed_line_flag = 'Y'
         AND(p_spreadsheet = g_online_mode OR bl.batch_id = p_batch_id)
         AND pbh.bid_number = bl.bid_number
         AND (pbh.SURROG_BID_FLAG = 'Y' OR nvl(al.close_bidding_date, sysdate+1) > sysdate);


  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VALIDATE_QTY_BASED_PRICE_TIERS',
      message  => 'Performing overlapping tiers validation for online bidding flow.');
  END IF; --}


                  Insert INTO pon_interface_errors
                    (INTERFACE_TYPE,
                    TABLE_NAME,
                    BATCH_ID,
                    INTERFACE_LINE_ID,
                    ERROR_MESSAGE_NAME,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    REQUEST_ID,
                    ENTITY_TYPE,
                    ENTITY_ATTR_NAME,
                    ERROR_VALUE_DATATYPE,
                    AUCTION_HEADER_ID,
                    BID_NUMBER,
                    LINE_NUMBER,
                    EXPIRATION_DATE,
                    TOKEN1_NAME,
                    TOKEN1_VALUE)
                  SELECT
                    p_interface_type,
                    'PON_BID_SHIPMENTS',
                    p_batch_id,
                    bl.interface_line_id,
                    'PON_AUC_OVERLAP_RANGES_QT',
                    p_userid,
                    sysdate,
                    p_userid,
                    sysdate,
                    p_request_id,
                    'BID_PTS',
                    'Quantity',
                    'NUM',
                    p_auc_header_id,
                    p_bid_number,
                    bl.line_number,
                    g_exp_date,
                    'LINENUM',
                    al.document_disp_line_number
                  From pon_bid_item_prices bl
                       , pon_auction_item_prices_all al
                       , pon_bid_headers pbh
                  where bl.bid_number = p_bid_number
                    AND al.auction_header_id = bl.auction_header_id
                    AND al.line_number = bl.line_number
                    AND bl.is_changed_line_flag = 'Y'
                    AND p_spreadsheet = g_online_mode
                    and bl.line_number in
                    ( Select distinct pbs.line_number
                      FROM pon_bid_shipments pbs,
                      pon_bid_shipments pbs1
                       WHERE pbs.bid_number = p_bid_number
                       and pbs1.bid_number = p_bid_number
                       AND pbs.line_number = pbs1.line_number
                       AND pbs.shipment_number <> pbs1.shipment_number
                       AND pbs1.quantity <= pbs.quantity
                       AND pbs.quantity <= pbs1.max_quantity)
                       AND pbh.bid_number = bl.bid_number
                       AND (pbh.SURROG_BID_FLAG = 'Y' OR nvl(al.close_bidding_date, sysdate+1) > sysdate);

  IF (FND_LOG.level_procedure>= FND_LOG.g_current_runtime_level) THEN --{
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'VALIDATE_QTY_BASED_PRICE_TIERS',
      message  => 'All the validations are performed. Exiting the method');
  END IF; --}

END VALIDATE_QTY_BASED_PRICE_TIERS;

PROCEDURE validate_price_differentials
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_spreadsheet		IN VARCHAR2,
	p_suffix			IN VARCHAR2,
	p_batch_id			IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE
) IS
BEGIN
  print_log('validate_price_differentials Start');
  	  print_log('p_auc_header_id '||p_auc_header_id);
	  print_log('p_bid_number '||p_bid_number);
	  print_log('p_interface_type '||p_interface_type);
	  print_log('p_userid '||p_userid);
	  print_log('p_spreadsheet '||	p_spreadsheet);
	  print_log('p_suffix	 '||p_suffix);
	  print_log('p_batch_id	 '||p_batch_id);
	  print_log('p_request_id '||p_request_id);
	INSERT FIRST

		-- Line price differential validation:
		-- multiplier should be entered for REQUIRED price differentials
		WHEN s_shipment_number = -1 AND s_multiplier IS null
			AND s_differential_response_type = 'REQUIRED' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				PRICE_DIFFERENTIAL_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUC_RESP_MULTIPLIER' || p_suffix),
				'PON_BID_PRICE_DIFFERENTIALS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PD_VALUE_REQ' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PDS',
				'Multiplier',
				'TXT',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				s_price_differential_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'PRICEDIFFERENTIALNAME',
				s_price_differential_name,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- Line price differential validation:
		-- multiplier should not be entered for DISPLAY_ONLY price differentials
		WHEN s_shipment_number = -1 AND s_multiplier IS NOT null
			AND s_differential_response_type = 'DISPLAY_ONLY' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				PRICE_DIFFERENTIAL_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUC_RESP_MULTIPLIER' || p_suffix),
				'PON_BID_PRICE_DIFFERENTIALS',
				p_batch_id,
				s_interface_line_id ,
				'PON_AUC_PD_VAL_NONENTERABLE',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PDS',
				'Multiplier',
				s_multiplier,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				s_price_differential_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'PRICEDIFFERENTIALNAME',
				s_price_differential_name,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)

		-- Line price differential validation:
		-- multiplier should be greater than the target multiplier
		WHEN s_shipment_number = -1 AND s_multiplier < s_target_multiplier THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				PRICE_DIFFERENTIAL_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUC_RESP_MULTIPLIER' || p_suffix),
				'PON_BID_PRICE_DIFFERENTIALS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PD_INVALID_MULT' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PDS',
				'Multiplier',
				s_multiplier,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				s_price_differential_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'PRICEDIFFERENTIALNAME',
				s_price_differential_name,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name
)

		-- Shipment price differential validation:
		-- multiplier should be entered for REQUIRED price differentials
		WHEN  ( p_spreadsheet = g_online_mode or p_spreadsheet = g_xml_upload_mode )
		        and  s_shipment_number <> -1 AND s_multiplier IS null
			AND s_differential_response_type = 'REQUIRED' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				PRICE_DIFFERENTIAL_NUMBER,
				ERROR_VALUE_DATATYPE,
				ERROR_VALUE,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUC_RESP_MULTIPLIER'||p_suffix),
				'PON_BID_PRICE_DIFFERENTIALS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PB_PD_VALUE_REQ' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PDS',
				'Multiplier',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				s_price_differential_number,
				'TXT',
				'',
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'PRICEDIFFERENTIALNAME',
				s_price_differential_name,
			    s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name
)
		-- Shipment price differential validation:
		-- multiplier should not be entered for DISPLAY_ONLY price differentials
		WHEN  ( p_spreadsheet = g_online_mode or p_spreadsheet = g_xml_upload_mode )
		      and  s_shipment_number <> -1 AND s_multiplier IS NOT null
			AND s_differential_response_type = 'DISPLAY_ONLY' THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				PRICE_DIFFERENTIAL_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUC_RESP_MULTIPLIER'||p_suffix),
				'PON_BID_PRICE_DIFFERENTIALS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PB_PD_VAL_NONENTERABLE',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PDS',
				'Multiplier',
				s_multiplier,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				s_price_differential_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'PRICEDIFFERENTIALNAME',
				s_price_differential_name,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name
)

		-- Shipment price differential validation:
		-- multiplier should be greater than target multiplier
		WHEN  ( p_spreadsheet = g_online_mode or p_spreadsheet = g_xml_upload_mode )
                                and s_shipment_number <> -1
				AND s_multiplier < s_target_multiplier THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				PRICE_DIFFERENTIAL_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE
			)
			VALUES
				(p_interface_type,
				fnd_message.get_string('PON', 'PON_AUC_RESP_MULTIPLIER'||p_suffix),
				'PON_BID_PRICE_DIFFERENTIALS',
				p_batch_id,
				s_interface_line_id,
				'PON_AUC_PB_PD_INVALID_MULT' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'BID_PDS',
				'Multiplier',
				s_multiplier,
				'NUM',
				p_auc_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				s_price_differential_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				'PRICEDIFFERENTIALNAME',
				s_price_differential_name,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name
)
	SELECT
		bpd.multiplier s_multiplier,
		apd.multiplier s_target_multiplier,
		nvl(apb.differential_response_type, al.differential_response_type)
			s_differential_response_type,
		bpd.line_number s_line_number,
		bpd.shipment_number s_shipment_number,
		bpd.price_differential_number s_price_differential_number,
		al.document_disp_line_number s_document_disp_line_number,
		decode(p_spreadsheet, g_xml_upload_mode,
							  bpd.interface_line_id,
							  bl.interface_line_id
			  ) s_interface_line_id,
		pdl.price_differential_dsp s_price_differential_name,
		decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_name, null) s_worksheet_name,
        decode(p_spreadsheet, g_xml_upload_mode, bl.worksheet_sequence_number, null) s_worksheet_seq_num,
		decode(p_spreadsheet, g_xml_upload_mode,
					  'PON_PRICE_DIFFERENTIALS',
					  null
			  ) s_entity_name
	FROM pon_bid_price_differentials bpd
             , pon_bid_item_prices bl
             , pon_auction_item_prices_all al
             , pon_price_differentials apd
             , pon_auction_shipments_all apb
             , po_price_diff_lookups_v pdl
             , pon_bid_headers pbh
	WHERE bpd.bid_number = p_bid_number
		AND bl.bid_number = bpd.bid_number
		AND bl.line_number = bpd.line_number
		AND al.auction_header_id = bpd.auction_header_id
		AND al.line_number = bpd.line_number
		AND apd.auction_header_id = bpd.auction_header_id
		AND apd.line_number = bpd.line_number
		AND apd.shipment_number = decode(bpd.shipment_number, -1, -1, bpd.shipment_number - 1)
		AND apd.price_differential_number = bpd.price_differential_number
		AND apb.auction_header_id (+) = bpd.auction_header_id
		AND apb.line_number (+) = bpd.line_number
		AND apb.shipment_number (+) = decode(bpd.shipment_number, -1, -1, bpd.shipment_number - 1)
		AND pdl.price_differential_type = bpd.price_type
		AND bl.is_changed_line_flag = 'Y'
		AND (p_spreadsheet = g_online_mode OR bl.batch_id = p_batch_id)
                AND pbh.bid_number = bl.bid_number
                AND (pbh.SURROG_BID_FLAG = 'Y' OR nvl(al.close_bidding_date, sysdate+1) > sysdate);
  print_log('validate_price_differentials Start');
END validate_price_differentials;



PROCEDURE validate_payments
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_price_precision	IN pon_bid_headers.number_price_decimals%TYPE,
	p_batch_id			IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE
) IS
l_loginid NUMBER;
l_exp_date DATE;
l_module CONSTANT VARCHAR2(32) := 'VALIDATE_PAYMENTS';
l_progress              varchar2(200);
BEGIN

l_loginid := fnd_global.login_id;
l_exp_date := SYSDATE + 7;

/*    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'VALIDATE_PAYMENTS  START p_batch_id = '||p_batch_id);
    END IF;
*/
  print_log('validate_payments Start');
  	  print_log('p_auc_header_id '||p_auc_header_id);
	  print_log('p_bid_number '||p_bid_number);
	  print_log('p_interface_type '||p_interface_type);
	  print_log('p_userid '||p_userid);
	  print_log('p_price_precision '||	p_price_precision);
	  print_log('p_batch_id	 '||p_batch_id);
	  print_log('p_request_id '||p_request_id);

  BEGIN
       --To check for duplicate pay item number
    	INSERT	INTO pon_interface_errors
		 (INTERFACE_TYPE,
		  COLUMN_NAME,
		  TABLE_NAME,
		  BATCH_ID,
		  ERROR_MESSAGE_NAME,
		  CREATED_BY,
		  CREATION_DATE,
		  LAST_UPDATED_BY,
		  LAST_UPDATE_DATE,
		  REQUEST_ID,
		  ENTITY_TYPE,
		  ERROR_VALUE_NUMBER,
		  ERROR_VALUE_DATATYPE,
		  AUCTION_HEADER_ID,
		  BID_NUMBER,
		  LINE_NUMBER,
		  EXPIRATION_DATE,
		  TOKEN1_NAME,
		  TOKEN1_VALUE,
          TOKEN2_NAME,
		  TOKEN2_VALUE)
        SELECT
         p_interface_type,
         fnd_message.get_string('PON','PON_AUCTS_PAYITEM_NUMBER'),
         'PON_BID_ITEM_PRICES',
         p_batch_id,
         'PON_PYMT_NUM_NOT_UNQ',
         p_userid,
         sysdate,
         p_userid,
         sysdate,
         p_request_id,
         'BID_ITEMS',
         NULL,
         'TXT',
		 p_auc_header_id,
         p_bid_number,
         pbps.bid_line_number,
		 g_exp_date,
         'LINENUM',
         pai.document_disp_line_number,
         'PAYITEMNUM',
         pbps.payment_display_number
              FROM PON_BID_PAYMENTS_SHIPMENTS pbps,
              PON_AUCTION_ITEM_PRICES_ALL pai
              WHERE pbps.auction_header_id= pai.auction_header_id
              AND pbps.auction_header_id=p_auc_header_id
			  AND pbps.bid_line_number = pai.line_number
			  AND pbps.bid_number = p_bid_number
			  GROUP BY pbps.bid_number, pbps.bid_line_number,
                       pbps.payment_display_number, pai.document_disp_line_number
			  HAVING count(*) > 1;
    EXCEPTION
	WHEN OTHERS THEN
	Raise;

	END;


INSERT ALL
WHEN payment_display_number < 1 OR payment_display_number<> ROUND(payment_display_number) THEN
 INTO pon_interface_errors
 (
  request_id,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  p_request_id,                         'PaymentDisplayNumber',       'PON_PYMT_NUM_WRONG',              -- 1
  'NUM',                        payment_display_number,              NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       p_interface_type,             'PON_BID_PAYMENTS_SHIPMENTS',  -- 4
  p_batch_id,                   NULL,                         'BID_PYMTS',                   -- 5
  auction_header_id,            document_disp_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   p_userid,                     SYSDATE,                       -- 7
  p_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN payment_type_code = 'RATE' AND quantity < 0 THEN
 INTO pon_interface_errors
 (
  request_id,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  p_request_id,                         'Quantity',                   'PON_PYMT_QTY_WRONG',              -- 1
  'NUM',                        quantity,                     NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       p_interface_type,             'PON_BID_PAYMENTS_SHIPMENTS',  -- 4
  p_batch_id,                   NULL,                         'BID_PYMTS',                   -- 5
  auction_header_id,            document_disp_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   p_userid,                     SYSDATE,                       -- 7
  p_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN bid_currency_price IS NOT NULL AND bid_currency_price < 0 THEN
 INTO pon_interface_errors
 (
  request_id,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  p_request_id,                         'BidCurrencyPrice',           'PON_PYMT_PRICE_WRONG',              -- 1
  'NUM',                        bid_currency_price,              NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       p_interface_type,             'PON_BID_PAYMENTS_SHIPMENTS',  -- 4
  p_batch_id,                   NULL,                         'BID_PYMTS',                   -- 5
  auction_header_id,            document_disp_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   p_userid,                     SYSDATE,                       -- 7
  p_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN payment_display_number IS NULL THEN
 INTO pon_interface_errors
 (
  request_id,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                 error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  p_request_id,                         'PaymentDisplayNumber',       'PON_PYMT_NUM_MISSING',              -- 1
  'TXT',                        payment_display_number,           NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    NULL,                  -- 3
  NULL,                         p_interface_type,             'PON_BID_PAYMENTS_SHIPMENTS',  -- 4
  p_batch_id,                   NULL,                         'BID_PYMTS',                   -- 5
  auction_header_id,            document_disp_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   p_userid,                     SYSDATE,                       -- 7
  p_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN payment_type_code IS NULL THEN
 INTO pon_interface_errors
 (
  request_id,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  p_request_id,                         'PaymentTypeCode',           'PON_PYMT_TYPE_NULL',              -- 1
  'TXT',                        NULL,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       p_interface_type,             'PON_BID_PAYMENTS_SHIPMENTS',  -- 4
  p_batch_id,                   NULL,                         'BID_PYMTS',                   -- 5
  auction_header_id,            document_disp_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   p_userid,                     SYSDATE,                       -- 7
  p_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN payment_description IS NULL THEN
 INTO pon_interface_errors
 (
  request_id,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  p_request_id,                         'PaymentDescription',           'PON_PYMT_DESC_NULL',              -- 1
  'TXT',                        NULL,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       p_interface_type,             'PON_BID_PAYMENTS_SHIPMENTS',  -- 4
  p_batch_id,                   NULL,                         'BID_PYMTS',                   -- 5
  auction_header_id,            document_disp_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   p_userid,                     SYSDATE,                       -- 7
  p_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN payment_type_code = 'RATE' AND quantity IS NULL THEN
 INTO pon_interface_errors
 (
  request_id,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  p_request_id,                 'Quantity',                   'PON_PYMT_QTY_NULL',              -- 1
  'TXT',                        NULL,                           NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       p_interface_type,             'PON_BID_PAYMENTS_SHIPMENTS',  -- 4
  p_batch_id,                   NULL,                         'BID_PYMTS',                   -- 5
  auction_header_id,            document_disp_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   p_userid,                     SYSDATE,                       -- 7
  p_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN payment_type_code = 'RATE' AND uom_code IS NULL THEN
 INTO pon_interface_errors
 (
  request_id,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                 error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  p_request_id,                         'UomCode',                   'PON_PYMT_UOM_NULL',              -- 1
  'TXT',                        NULL,                         NULL,                          -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       p_interface_type,             'PON_BID_PAYMENTS_SHIPMENTS',  -- 4
  p_batch_id,                   NULL,                         'BID_PYMTS',                   -- 5
  auction_header_id,            document_disp_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   p_userid,                     SYSDATE,                       -- 7
  p_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN bid_currency_price IS NULL THEN
 INTO pon_interface_errors
 (
  request_id,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value,                 error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  p_request_id,                         'BidCurrencyPrice',           'PON_PYMT_BID_PRICE_NULL',     -- 1
  'TXT',                        bid_currency_price,              NULL,                       -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       p_interface_type,             'PON_BID_PAYMENTS_SHIPMENTS',  -- 4
  p_batch_id,                   NULL,                         'BID_PYMTS',                   -- 5
  auction_header_id,            document_disp_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   p_userid,                     SYSDATE,                       -- 7
  p_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN promised_date IS NOT NULL AND promised_date <= close_bidding_date THEN
 INTO pon_interface_errors
 (
  request_id,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  p_request_id,                         'PromisedDate',           'PON_PYMT_PDATE_LESS_CDATE',     -- 1
  'DAT',                        NULL,                      promised_date,                       -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       p_interface_type,             'PON_BID_PAYMENTS_SHIPMENTS',  -- 4
  p_batch_id,                   NULL,                         'BID_PYMTS',                   -- 5
  auction_header_id,            document_disp_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   p_userid,                     SYSDATE,                       -- 7
  p_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
WHEN bid_currency_price IS NOT NULL
AND validate_price_precision(bid_currency_price, p_price_precision) = 'F' THEN
 INTO pon_interface_errors
 (
  request_id,                  entity_attr_name,             error_message_name,            -- 1
  error_value_datatype,         error_value_number,           error_value_date,              -- 2
  token1_name,                  token1_value,                 token2_name,                   -- 3
  token2_value,                 interface_type,               table_name,                    -- 4
  batch_id,                     interface_line_id,            entity_type,                   -- 5
  auction_header_id,            line_number,                  bid_payment_id,                -- 6
  expiration_date,              created_by,                   creation_date,                 -- 7
  last_updated_by,              last_update_date,             last_update_login              -- 8
 )
VALUES
 (
  p_request_id,                         'BidCurrencyPrice',           'PON_QUOTEPRICE_INVALID_PREC_P',     -- 1
  'NUM',                        bid_currency_price,              NULL,                       -- 2
  'LINENUM',                    document_disp_line_number,    'PAYITEMNUM',                  -- 3
  payment_display_number,       p_interface_type,             'PON_BID_PAYMENTS_SHIPMENTS',  -- 4
  p_batch_id,                   NULL,                         'BID_PYMTS',                   -- 5
  auction_header_id,            document_disp_line_number,    bid_payment_id,                -- 6
  l_exp_date,                   p_userid,                     SYSDATE,                       -- 7
  p_userid,                     SYSDATE,                      l_loginid                      -- 8
 )
 SELECT
  pbp.payment_display_number,
  pbp.payment_type_code,
  pbp.uom_code,
  pbp.payment_description,
  pbp.auction_header_id auction_header_id,
  pai.document_disp_line_number,
  pbp.bid_currency_price,
  pbp.quantity,
  pbp.promised_date,
  pai.line_number auction_line_number,
  pai.close_bidding_date,
  pbp.bid_payment_id,
  pbi.line_number bid_line_number
FROM PON_BID_PAYMENTS_SHIPMENTS pbp,
      PON_AUCTION_ITEM_PRICES_ALL pai,
      PON_BID_ITEM_PRICES pbi
 WHERE pbp.auction_header_id = pai.auction_header_id
 AND   pbp.auction_line_number = pai.line_number
 AND   pbi.auction_header_id = pai.auction_header_id
 AND   pbi.line_number = pai.line_number
 AND   pbp.bid_number = p_bid_number
 AND   pbi.bid_number = pbp.bid_number
 AND   nvl(pbi.has_bid_flag,'N') = 'Y';

/*    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'After Insert all for validate_payments p_batch_id = '||p_batch_id);
    END IF;
*/
  print_log('validate_payments End');
EXCEPTION
    WHEN OTHERS THEN
/*
       IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            print_error_log(l_module, 'EXCEPTION -  l_progress='||l_progress||' Error Code=' || SQLCODE || ' SQLERRM=' || SQLERRM);
        END if;
*/
        RAISE;
END validate_payments;
-----------------------------------------------------------------*\
--Yao Zhang add  11/12/2008
--Chaoqun modify 08/01/2009                                     |
--PROCEDURE NAME:Validate_EMD_STATUS                              |
--This procedure is used to check EMD Status                      |
--The bid can be published only when emd_status is 'RECEIVED'     |
--or 'EEXEMPTED'                                      |
-----------------------------------------------------------------*/
PROCEDURE validate_emd_status
(
  p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_price_precision	IN pon_bid_headers.number_price_decimals%TYPE,
	p_batch_id			IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE
  )
  IS
  l_emd_status   varchar2(20) :=null;
  l_emd_enable_flag   varchar2(2) :='N'; -- Added by Chaoqun on Jan-8-2009
  l_nopaid_exception exception;
  begin
  print_log('validate_emd_status Start');
  	  print_log('p_auc_header_id '||p_auc_header_id);
	  print_log('p_bid_number '||p_bid_number);
	  print_log('p_interface_type '||p_interface_type);
	  print_log('p_userid '||p_userid);
	  print_log('p_price_precision '||	p_price_precision);
	  print_log('p_batch_id	 '||p_batch_id);
	  print_log('p_request_id '||p_request_id);
    --Added by Chaoqun on Jan-8-2009 begin
    select pah.emd_enable_flag
      into l_emd_enable_flag
      from pon_auction_headers_all pah
     where pah.auction_header_id = p_auc_header_id;

    IF l_emd_enable_flag = 'Y' then
   --Added by Chaoqun on Jan-8-2009 end

    select  decode(petr.status_lookup_code,
                          null,
                          decode(pbp.exempt_flag,
                                  null, 'NOT_PAID',
                                  'N',  'NOT_PAID',
                                  'Y',  'EXEMPTED'),
                   'RECEIVING', 'NOT_PAID',
                   'RECEIVE_ERROR', 'NOT_PAID',
                petr.status_lookup_code)
     into l_emd_status
    from pon_emd_transactions  petr,
         pon_bid_headers       pbh,
         pon_bidding_parties   pbp
    where    pbh.bid_number = p_bid_number
         and pbh.auction_header_id=p_auc_header_id
         and pbp.trading_partner_id = pbh.trading_partner_id
         and pbh.vendor_site_id = pbp.vendor_site_id  --Modify by Chaoqun on 17-Mar-2009
         and pbp.auction_header_id= p_auc_header_id
         and petr.auction_header_id(+) = pbp.auction_header_id
         and petr.supplier_sequence(+) = pbp.sequence
         and decode(petr.current_row_flag,null,'Y',petr.current_row_flag) = 'Y';

  IF l_emd_status='NOT_PAID' then
  raise l_nopaid_exception;
  end if;
END IF;--Added by Chaoqun
exception when no_data_found or l_nopaid_exception then
       INSERT	INTO pon_interface_errors
		 (INTERFACE_TYPE,
		  COLUMN_NAME,
		  TABLE_NAME,
		  BATCH_ID,
		  ERROR_MESSAGE_NAME,
		  CREATED_BY,
		  CREATION_DATE,
		  LAST_UPDATED_BY,
		  LAST_UPDATE_DATE,
		  REQUEST_ID,
		  AUCTION_HEADER_ID,
		  BID_NUMBER,
		  LINE_NUMBER,
		  EXPIRATION_DATE)
      values(
      p_interface_type,
      fnd_message.get_string('PON', 'PON_EMD_STATUS_VALUE'),
      'PON_EMD_TRANSACTIONS',
       p_batch_id,
      'PON_EMD_STATUS_VALUE',
       p_userid,
       sysdate,
       p_userid,
       sysdate,
       p_request_id,
       p_auc_header_id,
       p_bid_number,
       1,
       g_exp_date
      );
      commit;
  print_log('validate_emd_status End');
END validate_emd_status;
-----------------------------------Yao Zhang add end---------------------------------------

PROCEDURE perform_all_validations
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_batch_id			IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE,
	p_spreadsheet		IN VARCHAR2,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY VARCHAR2
) IS
    l_rate              pon_bid_headers.rate%TYPE;
	l_price_precision	pon_bid_headers.number_price_decimals%TYPE;
	l_amt_precision		fnd_currencies.precision%TYPE;

	l_source_bid		pon_bid_headers.bid_number%TYPE;
	l_min_bid_change	pon_bid_headers.min_bid_change%TYPE;
	l_min_bid_decr		pon_auction_headers_all.min_bid_decrement%TYPE;
	l_percent_decr		VARCHAR2(1);
    l_bid_decr_method   pon_auction_headers_all.bid_decrement_method%TYPE;

	l_po_start_date		pon_auction_headers_all.po_start_date%TYPE;
	l_po_end_date		pon_auction_headers_all.po_end_date%TYPE;
	l_auc_close_date	pon_auction_headers_all.close_bidding_date%TYPE;
	l_progress_payment_type pon_auction_headers_all.progress_payment_type%TYPE;
	l_contract_type     pon_auction_headers_all.contract_type%TYPE;

	l_tpid				pon_bid_headers.trading_partner_id%TYPE;
	l_vensid			pon_bid_headers.vendor_site_id%TYPE;
	l_bid_curr_code		pon_bid_headers.bid_currency_code%TYPE;

	l_mas				VARCHAR2(1);
	l_blanket			VARCHAR2(1);
	l_global			VARCHAR2(1);
	l_trans_view		VARCHAR2(1);
	l_header_disp_pf	VARCHAR2(1);
	l_full_qty_reqd		VARCHAR2(1);
	l_spo_trans_view	VARCHAR2(1);
	l_price_driven		VARCHAR2(1);
	l_rebid				VARCHAR2(1);
	l_bid_all_lines		VARCHAR2(1);
	l_auc_has_items		VARCHAR2(1);
	l_suffix			VARCHAR2(2);

	l_has_errors		VARCHAR2(1);
	l_return_code		VARCHAR2(1);
  l_price_tiers_indicator  pon_auction_headers_all.PRICE_TIERS_INDICATOR%TYPE;
  --added by Allen Yang for Surrogate Bid 2008/09/03
  --------------------------------------------------------------------------------------
  l_two_part_flag               pon_auction_headers_all.two_part_flag%TYPE;
  l_technical_evaluation_status pon_auction_headers_all.TECHNICAL_EVALUATION_STATUS%TYPE;
  l_surrogate_bid_flag          pon_bid_headers.SURROG_BID_FLAG%TYPE;
  l_two_part_tech_surrogate_flag VARCHAR2(1);
  --------------------------------------------------------------------------------------
  l_evaluation_flag             VARCHAR2(1);    -- Added for ER: Supplier Management: Supplier Evaluation
BEGIN
          print_log('perform_all_validations Start');
  	  print_log('p_auc_header_id '||p_auc_header_id);
	  print_log('p_bid_number '||p_bid_number);
	  print_log('p_interface_type '||p_interface_type);
	  print_log('p_userid '||p_userid);
	  print_log('p_spreadsheet '||	p_spreadsheet);
	  print_log('p_batch_id	 '||p_batch_id);
	  print_log('p_request_id '||p_request_id);
	-- Select auction data


	SELECT sysdate + g_exp_days_offset,
        bh.rate,
		bh.number_price_decimals,
		fc.precision,
		decode(ah.bid_ranking, 'MULTI_ATTRIBUTE_SCORING', 'Y', 'N'),
		decode(ah.contract_type, 'STANDARD',
			decode(ah.supplier_view_type, 'TRANSFORMED', 'Y', 'N'), 'N'),
		decode(ah.contract_type, 'BLANKET', 'Y', 'CONTRACT', 'Y', 'N'),
		nvl(ah.global_agreement_flag, 'N'),
		decode(ah.supplier_view_type, 'TRANSFORMED', 'Y', 'N'),
		bh.display_price_factors_flag,
		decode(ah.full_quantity_bid_code, 'FULL_QTY_BIDS_REQD', 'Y', 'N'),
		nvl(ah.price_driven_auction_flag, 'Y'),
		bh.min_bid_change,
		ah.min_bid_decrement * bh.rate, -- convert to bid currency
		decode(ah.min_bid_change_type, 'PERCENTAGE', 'Y', 'N'),
        nvl(ah.bid_decrement_method, 'PREVIOUS_PRICE'),
		ah.po_start_date,
		ah.po_end_date,
		ah.close_bidding_date,
		decode(ah.bid_scope_code, 'MUST_BID_ALL_ITEMS', 'Y', 'N'),
		ah.has_items_flag,
		bh.trading_partner_id,
		bh.vendor_site_id,
		bh.bid_currency_code,
		decode(old_bh.bid_status, 'ACTIVE', 'Y', 'N'),
		nvl(old_bh.bid_number, 0),
		ah.contract_type,
		ah.progress_payment_type,
    ah.price_tiers_indicator
    --added by Allen Yang for Surrogate Bid 2008/09/03
    --------------------------------------------------
    , ah.TWO_PART_FLAG,
    ah.TECHNICAL_EVALUATION_STATUS,
    bh.SURROG_BID_FLAG,
    --------------------------------------------------
    nvl(bh.evaluation_flag, 'N')    -- Added for ER: Supplier Management: Supplier Evaluation
	INTO g_exp_date,
        l_rate,
		l_price_precision,
		l_amt_precision,
		l_mas,
		l_spo_trans_view,
		l_blanket,
		l_global,
		l_trans_view,
		l_header_disp_pf,
		l_full_qty_reqd,
		l_price_driven,
		l_min_bid_change,
		l_min_bid_decr,
		l_percent_decr,
        l_bid_decr_method,
		l_po_start_date,
		l_po_end_date,
		l_auc_close_date,
		l_bid_all_lines,
		l_auc_has_items,
		l_tpid,
		l_vensid,
		l_bid_curr_code,
		l_rebid,
		l_source_bid,
		l_contract_type,
		l_progress_payment_type,
    l_price_tiers_indicator
    --added by Allen Yang for Surrogate Bid 2008/09/03
    --------------------------------------------------
    , l_two_part_flag,
    l_technical_evaluation_status,
    l_surrogate_bid_flag,
    --------------------------------------------------
    l_evaluation_flag    -- Added for ER: Supplier Management: Supplier Evaluation
 	FROM pon_auction_headers_all ah, pon_bid_headers bh,
		fnd_currencies fc, pon_bid_headers old_bh
	WHERE ah.auction_header_id = p_auc_header_id
		AND ah.auction_header_id = bh.auction_header_id
		AND bh.bid_number = p_bid_number
		AND fc.currency_code = bh.bid_currency_code
		AND old_bh.bid_number (+) = bh.old_bid_number;

	l_suffix := PON_LARGE_AUCTION_UTIL_PKG.get_doctype_suffix(p_auc_header_id);
  --added by Allen Yang for Surrogate Bid 2008/09/03
  --------------------------------------------------
    print_log('g_exp_date'|| g_exp_date);
    print_log('l_rate'||l_rate );
    print_log('l_price_precision'||l_price_precision );
    print_log('l_amt_precision'||l_amt_precision );
    print_log('l_mas'|| l_mas);
    print_log('l_spo_trans_view'||l_spo_trans_view );
    print_log('l_blanket'||l_blanket );
    print_log('l_global'||l_global );
    print_log('l_trans_view'||l_trans_view );
    print_log('l_header_disp_pf'||l_header_disp_pf );
    print_log('l_full_qty_reqd'||l_full_qty_reqd );
    print_log('l_price_driven'|| l_price_driven);
    print_log('l_min_bid_change'||l_min_bid_change );
    print_log('l_min_bid_decr'||l_min_bid_decr );
    print_log('l_percent_decr'||l_percent_decr );
    print_log('l_bid_decr_method'||l_bid_decr_method );
    print_log('l_po_start_date'||l_po_start_date );
    print_log('l_po_end_date'|| l_po_end_date);
    print_log('l_auc_close_date'||l_auc_close_date );
    print_log('l_bid_all_lines'||l_bid_all_lines );
    print_log('l_auc_has_items'||l_auc_has_items );
    print_log('l_tpid'|| l_tpid);
    print_log('l_vensid'||l_vensid );
    print_log('l_bid_curr_code'|| l_bid_curr_code);
    print_log('l_rebid'|| l_rebid);
    print_log('l_source_bid'||l_source_bid );
    print_log('l_contract_type'||l_contract_type );
    print_log('l_progress_payment_type'||l_progress_payment_type );
    print_log('l_price_tiers_indicator'||l_price_tiers_indicator );
    print_log('l_two_part_flag'||l_two_part_flag );
    print_log('l_technical_evaluation_status'||l_technical_evaluation_status );
    print_log('l_surrogate_bid_flag'|| l_surrogate_bid_flag);
    print_log('l_evaluation_flag'  || l_evaluation_flag);

  l_two_part_tech_surrogate_flag := 'N';
  IF (l_two_part_flag = 'Y' AND l_technical_evaluation_status = 'NOT_COMPLETED' AND l_surrogate_bid_flag = 'Y')
  THEN
	    l_two_part_tech_surrogate_flag := 'Y';
  END IF;
  --------------------------------------------------
    print_log('l_two_part_tech_surrogate_flag'  || l_two_part_tech_surrogate_flag);

	IF (p_spreadsheet = g_online_mode) THEN
		print_log('Calling validate_bids_placed');

		validate_bids_placed
			(p_auc_header_id,
			p_bid_number,
			p_interface_type,
			p_userid,
			l_rebid,
			l_bid_all_lines,
			l_auc_has_items,
			l_evaluation_flag,    -- Added for ER: Supplier Management: Supplier Evaluation
			l_suffix,
			p_batch_id,
			p_request_id);

		-- Check if there were any errors
		SELECT decode(count(auction_header_id), 0, 'N', 'Y')
		INTO l_has_errors
		FROM pon_interface_errors
		WHERE (batch_id = p_batch_id OR request_id = p_request_id)
			AND rownum = 1;

		print_log('has errors = '||l_has_errors);
		IF (l_has_errors = 'Y') THEN
			x_return_status := 1;
			x_return_code := 'ERROR';
			RETURN;
		END IF;
	ELSE
		print_log('Calling populate_has_bid_changed_line');
		-- For spreadsheet upload, we need to first populate has bid
		-- and changed lines flags before performing validations.
		populate_has_bid_changed_line
			(p_auc_header_id,
			p_bid_number,
			l_source_bid,
			p_batch_id,
			l_rebid,
			l_blanket,
			p_spreadsheet);
	END IF;

	print_log('Calling check_and_correct_rate');
        check_and_correct_rate(p_auc_header_id, p_bid_number,l_return_code );
        IF l_return_code = 'E' THEN
            INSERT
            INTO pon_interface_errors
                    (INTERFACE_TYPE,
                    TABLE_NAME,
                    BATCH_ID,
                    ERROR_MESSAGE_NAME,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    REQUEST_ID,
                    AUCTION_HEADER_ID,
                    BID_NUMBER,
                    EXPIRATION_DATE)
            VALUES
                    (p_interface_type,
                    'PON_BID_HEADERS',
                    p_batch_id,
                    'PON_BID_RATENOTFOUND',
                    p_userid,
                    sysdate,
                    p_userid,
                    sysdate,
                    p_request_id,
                    p_auc_header_id,
                    p_bid_number,
                    g_exp_date);

        END IF;
	print_log('Calling validate_lots_and_groups');
	validate_lots_and_groups
		(p_auc_header_id,
		p_bid_number,
		p_interface_type,
		p_userid,
		p_spreadsheet,
		p_batch_id,
		p_request_id);

	print_log('Calling validate_lines');
	validate_lines
		(p_auc_header_id,
		p_bid_number,
		p_interface_type,
		p_userid,
		l_tpid,
		l_vensid,
		p_spreadsheet,
		l_blanket,
		l_global,
		l_trans_view,
		l_rebid,
		l_full_qty_reqd,
		l_header_disp_pf,
		l_price_driven,
		l_percent_decr,
        l_bid_decr_method,
		l_min_bid_decr,
		l_min_bid_change,
        l_rate,
		l_price_precision,
		l_amt_precision,
		l_bid_curr_code,
		l_suffix,
		p_batch_id,
		p_request_id
    --added by Allen Yang for Surrogate Bid 2008/09/03
    --------------------------------------------------
    ,l_two_part_tech_surrogate_flag
    --------------------------------------------------
    );


        IF (p_spreadsheet in (g_online_mode, g_xml_upload_mode)) THEN
	  print_log('Calling validate_requirements');
          validate_requirements
                  (p_auc_header_id,
                   p_bid_number,
                   p_interface_type,
                   p_userid,
                   p_spreadsheet,
                   l_suffix,
                   p_batch_id,
                   p_request_id
                   --added by Allen Yang for Surrogate Bid 2008/09/03
                   --------------------------------------------------
                   , l_two_part_tech_surrogate_flag
                   --------------------------------------------------
                   );
        END IF;

	-- If spreadsheet upload, calculate the total weighted score for MAS negotiations
	IF (p_spreadsheet in (g_txt_upload_mode, g_xml_upload_mode) AND l_mas = 'Y') THEN
		print_log('Calling calc_total_weighted_score');
		calc_total_weighted_score(p_bid_number, p_batch_id);
	END IF;

	print_log('Calling validate_attributes');
	validate_attributes
		(p_auc_header_id,
		 p_bid_number,
		 p_interface_type,
		 p_userid,
		 p_spreadsheet,
		 l_suffix,
		 p_batch_id,
		 p_request_id
    ,l_two_part_tech_surrogate_flag);

	IF (l_header_disp_pf = 'Y')
    --added by Allen Yang for Surrogate Bid 2008/09/03
    --------------------------------------------------
    AND l_two_part_tech_surrogate_flag = 'N'
    --------------------------------------------------
  THEN
		print_log('Calling validate_cost_factors');
		validate_cost_factors
			(p_auc_header_id,
			p_bid_number,
			p_interface_type,
			p_userid,
			p_spreadsheet,
			l_price_precision,
			l_amt_precision,
			l_suffix,
			p_batch_id,
			p_request_id);
	END IF;

	IF (p_spreadsheet in ( g_online_mode, g_xml_upload_mode)) THEN
                IF( l_price_tiers_indicator = 'PRICE_BREAKS')
                  --added by Allen Yang for Surrogate Bid 2008/09/03
                  --------------------------------------------------
                  AND l_two_part_tech_surrogate_flag = 'N'
                  --------------------------------------------------
                THEN

		    print_log('Calling validate_price_breaks');
                    validate_price_breaks
                        (p_auc_header_id,
                        p_bid_number,
                        p_interface_type,
                        p_userid,
                        p_spreadsheet,
                        l_price_precision,
                        l_trans_view,
                        l_blanket,
                        l_header_disp_pf,
                        l_po_start_date,
                        l_po_end_date,
                        l_auc_close_date,
                        l_suffix,
                        p_batch_id,
                        p_request_id);

                ELSIF( l_price_tiers_indicator = 'QUANTITY_BASED')
                  --added by Allen Yang for Surrogate Bid 2008/09/03
                  --------------------------------------------------
                  AND l_two_part_tech_surrogate_flag = 'N'
                  --------------------------------------------------
                THEN

	            print_log('Calling validate_qty_based_price_tiers');
                    validate_qty_based_price_tiers
                        (p_auc_header_id,
                        p_bid_number,
                        p_interface_type,
                        p_userid,
                        p_spreadsheet,
                        l_price_precision,
                        p_batch_id,
                        p_request_id,
                        l_contract_type);

                END IF;
	END IF;

	--modified by Allen Yang for Surrogate Bid 2008/09/03
  -----------------------------------------------------
  --validate_price_differentials
	--	(p_auc_header_id,
	--	p_bid_number,
	--	p_interface_type,
	--	p_userid,
	--	p_spreadsheet,
	--	l_suffix,
	--	p_batch_id,
	--	p_request_id);
  IF (l_two_part_tech_surrogate_flag = 'N') THEN
	print_log('Calling validate_price_differentials');
    validate_price_differentials
		  (p_auc_header_id,
		  p_bid_number,
		  p_interface_type,
		  p_userid,
		  p_spreadsheet,
		  l_suffix,
		  p_batch_id,
		  p_request_id);
  END IF;
  -----------------------------------------------------

    IF
      --added by Allen Yang for Surrogate Bid 2009/09/03
      --------------------------------------------------
      l_two_part_tech_surrogate_flag = 'N' AND
      --------------------------------------------------
      l_progress_payment_type <> 'NONE' AND l_contract_type = 'STANDARD' AND NVL(p_spreadsheet,g_online_mode) = g_online_mode
    THEN
        print_log('Calling validate_payments');
      validate_payments
      (
  	    p_auc_header_id		=> p_auc_header_id,
	    p_bid_number		=> p_bid_number,
	    p_interface_type	=> p_interface_type,
	    p_userid			=> p_userid,
	    p_price_precision	=> l_price_precision,
	    p_batch_id			=> p_batch_id,
	    p_request_id		=> p_request_id);
    END IF;

---------------add by Yao Zhang to check emd status------------------------

   print_log('Calling validate_emd_status');
   validate_emd_status( p_auc_header_id		=> p_auc_header_id,
	    p_bid_number		=> p_bid_number,
	    p_interface_type	=> p_interface_type,
	    p_userid			=> p_userid,
	    p_price_precision	=> l_price_precision,
	    p_batch_id			=> p_batch_id,
	    p_request_id		=> p_request_id
       );

------------------Yao Zhang add end-------------------------------------------------

	-- Check if any errors were present
	SELECT decode(count(auction_header_id), 0, 'N', 'Y')
	INTO l_has_errors
	FROM pon_interface_errors
	WHERE (batch_id = p_batch_id OR request_id = p_request_id)
		AND rownum = 1;

	IF (l_has_errors = 'Y') THEN
		x_return_status := 1;
		x_return_code := 'ERRORS';
	ELSE
		x_return_status := 0;
		x_return_code := 'SUCCESS';
	END IF;
        print_log('Perform_all_validations End ..'||x_return_code);
END perform_all_validations;

PROCEDURE validate_bid
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_batch_id			IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY VARCHAR2
) IS
BEGIN
  print_log('validate_bid Start');
  	  print_log('p_auc_header_id '||p_auc_header_id);
	  print_log('p_bid_number '||p_bid_number);
	  print_log('p_interface_type '||p_interface_type);
	  print_log('p_userid '||p_userid);
	  print_log('p_batch_id	 '||p_batch_id);
	  print_log('p_request_id '||p_request_id);
	perform_all_validations(p_auc_header_id, p_bid_number, p_interface_type,
		p_userid, p_batch_id, p_request_id, g_online_mode, x_return_status, x_return_code);
  print_log('validate_bid End');
END validate_bid;

PROCEDURE validate_spreadsheet_upload
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
        p_spreadsheet_type      IN VARCHAR2,
	p_userid		IN pon_interface_errors.created_by%TYPE,
	p_batch_id		IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY VARCHAR2
) IS
BEGIN
  print_log('validate_spreadsheet_upload Start');
  	  print_log('p_auc_header_id '||p_auc_header_id);
	  print_log('p_bid_number '||p_bid_number);
	  print_log('p_interface_type '||p_interface_type);
	  print_log('p_spreadsheet_type '||p_spreadsheet_type);
	  print_log('p_userid '||p_userid);
	  print_log('p_batch_id	 '||p_batch_id);
	  print_log('p_request_id '||p_request_id);
	perform_all_validations(p_auc_header_id, p_bid_number, p_interface_type,
		p_userid, p_batch_id, p_request_id, p_spreadsheet_type, x_return_status, x_return_code);
  print_log('validate_spreadsheet_upload End');
END validate_spreadsheet_upload;

FUNCTION GET_VENDOR_SITE_CODE(p_vendor_site_id IN NUMBER) RETURN VARCHAR2 IS
  l_vendor_site_code PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE;
BEGIN
  print_log('GET_VENDOR_SITE_CODE Start');
	IF (p_vendor_site_id = -1) THEN
		RETURN '';
    ELSE
	    BEGIN
		SELECT vendor_site_code
		  INTO l_vendor_site_code
		  FROM PO_VENDOR_SITES_ALL
		 WHERE vendor_site_id = p_vendor_site_id;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
		    l_vendor_site_code := '';
       END;
	END IF;
  print_log('GET_VENDOR_SITE_CODE End');
	return l_vendor_site_code;

END GET_VENDOR_SITE_CODE;

PROCEDURE check_and_correct_rate
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
        x_return_code   OUT NOCOPY VARCHAR2)
IS
    i_auc_curr_code pon_auction_headers_all.currency_code%TYPE;
    i_bid_curr_code pon_bid_headers.bid_currency_code%TYPE;
    i_rate_type pon_auction_headers_all.rate_type%TYPE;
    i_derive_type pon_auction_headers_all.derive_type%TYPE;
    i_rate_desc gl_daily_conversion_types.description%TYPE;
    i_rate_date DATE;
    i_bid_rate pon_bid_headers.rate%TYPE;
    i_num_price_decimals pon_bid_headers.number_price_decimals%TYPE;
    l_new_rate pon_bid_headers.rate%TYPE;
    l_new_num_price_decimals pon_bid_headers.number_price_decimals%TYPE;
    l_rate_dsp pon_auction_currency_rates.rate_dsp%TYPE;

BEGIN
    x_return_code := 'S';
    print_log('check_and_correct_rate Start..');
    print_log('auction_headerid '||p_auc_header_id||' bid_number '||p_bid_number);
    select ah.currency_code, ah.rate_type, ah.derive_type, nvl(gl.description, gl.USER_CONVERSION_TYPE), ah.rate_date,
           bh.bid_currency_code, nvl(bh.rate, 0), bh.number_price_decimals
    into   i_auc_curr_code, i_rate_type, i_derive_type, i_rate_desc, i_rate_date,
           i_bid_curr_code, i_bid_rate, i_num_price_decimals
    from pon_auction_headers_all ah, pon_bid_headers bh, gl_daily_conversion_types gl
    where ah.auction_header_id = bh.auction_header_id
    and   ah.currency_code <> bh.bid_currency_code
    and   gl.conversion_type = ah.rate_type
    and   bh.bid_number = p_bid_number
    and   (nvl(bh.rate, 0) = 1 OR nvl(bh.rate, 0) = 0);

    print_log('Auction currency '||i_auc_curr_code);
    print_log('Bid currency ' ||i_bid_curr_code);
    print_log('Rate type ' ||i_rate_type);
    print_log('Rate type desc '||i_rate_desc);
    print_log('Rate date '||i_rate_date);
    print_log('Bid Rate '||i_bid_rate);
    print_log('Bid Price decimals '||i_num_price_decimals);
    if i_rate_type = 'User' then
        print_log('Getting the rate from Auction currency rates');
        Begin
        select  RATE, NUMBER_PRICE_DECIMALS, RATE_DSP
        into    l_new_rate, l_new_num_price_decimals, l_rate_dsp
        from pon_auction_currency_rates
        where auction_header_id = p_auc_header_id
        and   auction_currency_code = i_auc_curr_code
        and   bid_currency_code = i_bid_curr_code;
        exception
            when others then x_return_code := 'E';
        end;
    else
        print_log('Getting the rate from GL currency rates');
        begin

            l_new_rate := GL_CURRENCY_API.get_rate(i_auc_curr_code,
                                    i_bid_curr_code,
                                    i_rate_date,
                                    i_rate_type);

            select precision
            into l_new_num_price_decimals
            from fnd_currencies
            where currency_code = i_bid_curr_code
            and rownum < 2;

        exception
        when others then x_return_code := 'E';
        end;
    end if;

    print_log('New rate = '||l_new_rate);
    print_log('New Num. of decimals = '||l_new_num_price_decimals);
    print_log('New rate dsp ='||l_rate_dsp);

    print_log('Currency rates fetching status '||x_return_code);
    IF x_return_code = 'S' THEN
        print_log('Update bid_header with the new rate');
        UPDATE  pon_bid_headers
        SET     rate = l_new_rate,
                number_price_decimals = l_new_num_price_decimals,
                rate_dsp = to_char(round(l_new_rate,3))
        WHERE   bid_number = p_bid_number;

        print_log('Number of records updated '||sql%rowcount);
    END IF;
    print_log('check_and_correct_rate End..');

EXCEPTION
    WHEN OTHERS THEN NULL;
        print_log('rates are all fine');
END check_and_correct_rate;

function get_new_rate(p_bid_number IN NUMBER) return number is
    i_auction_header_id NUMBER;
    i_auc_curr_code pon_auction_headers_all.currency_code%TYPE;
    i_bid_curr_code pon_bid_headers.bid_currency_code%TYPE;
    i_rate_type pon_auction_headers_all.rate_type%TYPE;
    i_derive_type pon_auction_headers_all.derive_type%TYPE;
    i_rate_desc gl_daily_conversion_types.description%TYPE;
    i_rate_date DATE;
    i_bid_rate pon_bid_headers.rate%TYPE;
    i_num_price_decimals pon_bid_headers.number_price_decimals%TYPE;
    l_new_rate pon_bid_headers.rate%TYPE;
    l_new_num_price_decimals pon_bid_headers.number_price_decimals%TYPE;
    l_rate_dsp pon_auction_currency_rates.rate_dsp%TYPE;

BEGIN
    select ah.currency_code, ah.rate_type, ah.derive_type, nvl(gl.description, gl.USER_CONVERSION_TYPE), ah.rate_date,
           bh.bid_currency_code, nvl(bh.rate, 0), bh.number_price_decimals, bh.auction_header_id
    into   i_auc_curr_code, i_rate_type, i_derive_type, i_rate_desc, i_rate_date,
           i_bid_curr_code, i_bid_rate, i_num_price_decimals, i_auction_header_id
    from pon_auction_headers_all ah, pon_bid_headers bh, gl_daily_conversion_types gl
    where ah.auction_header_id = bh.auction_header_id
    and   ah.currency_code <> bh.bid_currency_code
    and   gl.conversion_type = ah.rate_type
    and   bh.bid_number = p_bid_number;
    print_log('Auction currency '||i_auc_curr_code);
    print_log('Bid currency ' ||i_bid_curr_code);
    print_log('Rate type ' ||i_rate_type);
    print_log('Rate type desc '||i_rate_desc);
    print_log('Rate date '||i_rate_date);
    print_log('Bid Rate '||i_bid_rate);
    print_log('Bid Price decimals '||i_num_price_decimals);
    if i_rate_type = 'User' then
        Begin
        select  RATE, NUMBER_PRICE_DECIMALS, RATE_DSP
        into    l_new_rate, l_new_num_price_decimals, l_rate_dsp
        from pon_auction_currency_rates
        where auction_header_id = i_auction_header_id
        and   auction_currency_code = i_auc_curr_code
        and   bid_currency_code = i_bid_curr_code;
        exception
            when others then l_new_rate := -1;
        end;
    else
        begin
        l_new_rate := GL_CURRENCY_API.get_rate(i_auc_curr_code, i_bid_curr_code, i_rate_date, i_rate_type);
        exception
        when others then l_new_rate := -1;
        end;
    end if;
    return l_new_rate;
exception
    when others then return -2;
end;

END PON_BID_VALIDATIONS_PKG;

/
