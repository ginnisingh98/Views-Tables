--------------------------------------------------------
--  DDL for Package Body PON_BID_DEFAULTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_BID_DEFAULTING_PKG" AS
--$Header: PONBDDFB.pls 120.52.12010000.29 2014/03/25 04:30:11 vinnaray ship $

g_pkg_name CONSTANT VARCHAR2(30) := 'PON_BID_DEFAULTING_PKG';
g_debug_mode    CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_module_prefix CONSTANT VARCHAR2(35) := 'pon.plsql.bidDefaultingPkg.';
g_bid_rate                   PON_BID_HEADERS.RATE%TYPE;
g_curr_prec                  FND_CURRENCIES.PRECISION%TYPE;
g_advance_negotiable         PON_AUCTION_HEADERS_ALL.ADVANCE_NEGOTIABLE_FLAG%TYPE;
g_recoupment_negotiable      PON_AUCTION_HEADERS_ALL.RECOUPMENT_NEGOTIABLE_FLAG%TYPE;
g_prog_pymt_negotiable       PON_AUCTION_HEADERS_ALL.PROGRESS_PYMT_NEGOTIABLE_FLAG%TYPE;
g_max_rtng_negotiable        PON_AUCTION_HEADERS_ALL.MAX_RETAINAGE_NEGOTIABLE_FLAG%TYPE;
g_rtng_negotiable            PON_AUCTION_HEADERS_ALL.RETAINAGE_NEGOTIABLE_FLAG%TYPE;
g_copy_only_from_auc          VARCHAR2(1);


-- ======================================================================
-- PROCEDURE:	LOG_MESSAGE		PRIVATE
--  PARAMETERS:
--  p_module   			IN Pass the module name
--  p_message  			IN the string to be logged
--
--  COMMENT: Common procedure to log messages in FND_LOG.
-- ======================================================================
PROCEDURE log_message
(
	p_module 			IN VARCHAR2,
	p_message 			IN VARCHAR2
) IS
BEGIN
  IF (g_debug_mode = 'Y') THEN
      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string(log_level => FND_LOG.level_statement,
                         module    => g_module_prefix || p_module,
                         message   => p_message);
      END IF;
   END IF;
END log_message;

-- ======================================================================
-- PROCEDURE:	POPULATE_DISPLAY_PF_FLAG  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction_header_id of negotiation
--  	p_bid_number   		IN bid number to populate pf flags for
--	p_supp_seq_number	IN sequence number of current supplier
--
--  COMMENT: populate line and header display_price_factors_flag
-- ======================================================================
PROCEDURE populate_display_pf_flag
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_supp_seq_number	IN pon_bidding_parties.sequence%TYPE,
	p_batch_start		IN pon_bid_item_prices.line_number%TYPE,
	p_batch_end		IN pon_bid_item_prices.line_number%TYPE,
	x_skip_pf_for_batch	OUT NOCOPY VARCHAR2
) IS
	l_supplier_view		pon_auction_headers_all.supplier_view_type%TYPE;
	l_pf_type		pon_auction_headers_all.pf_type_allowed%TYPE;
	l_has_pfs		pon_auction_headers_all.has_price_elements%TYPE;
BEGIN


	-- Get the price factor type info
	SELECT 	ah.supplier_view_type,
		ah.pf_type_allowed,
		ah.has_price_elements
	INTO 	l_supplier_view,
		l_pf_type,
		l_has_pfs
	FROM 	pon_auction_headers_all ah
	WHERE 	ah.auction_header_id = p_auc_header_id;

	-- blindly set to N if pf type is NONE, there are no price factors
	-- or the view is untransformed (BUYER pf only)
	IF (l_pf_type = 'NONE' OR l_has_pfs = 'N'
		OR l_supplier_view = 'UNTRANSFORMED') THEN

		UPDATE pon_bid_item_prices
		SET display_price_factors_flag = 'N'
		WHERE bid_number = p_bid_number
		AND line_number BETWEEN p_batch_start AND p_batch_end;

		x_skip_pf_for_batch := 'Y';

		RETURN;
	END IF;

	-- Populate line level display_price_factors_flag
	-- Y if there is a supplier price factor (besides line price)
	-- N if not (buyer price factors handled by next sql)
	UPDATE pon_bid_item_prices bl
	SET bl.display_price_factors_flag =
		nvl((SELECT 'Y'
		FROM pon_price_elements apf
		WHERE apf.auction_header_id = p_auc_header_id
			AND apf.line_number = bl.line_number
			AND apf.pf_type = 'SUPPLIER'
			AND apf.price_element_type_id <> -10
			AND rownum = 1), 'N')
	WHERE bl.bid_number = p_bid_number
		AND bl.line_number BETWEEN p_batch_start AND p_batch_end;

	-- The display_price_factors_flag is also set if the line
	-- has a buyer price factor with a value, regardless of
	-- whether it is to be displayed to the supplier
	-- Buyer price factors will not apply in the following cases:
	-- 1. Supplier/site not on invitation list
	-- 2. The negotiation only allows SUPPLIER price factors
	IF (p_supp_seq_number IS NOT null
		AND l_pf_type <> 'SUPPLIER') THEN

		UPDATE pon_bid_item_prices bl
		SET bl.display_price_factors_flag =
			nvl((SELECT 'Y'
			FROM pon_pf_supplier_values pfv
			WHERE pfv.auction_header_id = p_auc_header_id
				AND pfv.line_number = bl.line_number
				AND pfv.supplier_seq_number = p_supp_seq_number
				AND nvl(pfv.value, 0) <> 0
				AND rownum = 1), 'N')
		WHERE bl.bid_number = p_bid_number
			-- no need to update lines with supplier price factors
			AND bl.display_price_factors_flag = 'N'
			AND bl.line_number BETWEEN p_batch_start AND p_batch_end;
	END IF;

	-- Determine if there are price factors in this batch
	SELECT decode(count(bl.bid_number), 0, 'Y', 'N')
	INTO x_skip_pf_for_batch
	FROM pon_bid_item_prices bl
	WHERE bl.bid_number = p_bid_number
		AND bl.display_price_factors_flag = 'Y'
		AND bl.line_number BETWEEN p_batch_start AND p_batch_end
		AND rownum = 1;

EXCEPTION
	WHEN OTHERS THEN
		x_skip_pf_for_batch := 'N';
END populate_display_pf_flag;

-- ======================================================================
-- PROCEDURE:	INSERT_AUCTION_LINES	PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--	p_bid_number		IN new bid number
--	p_userid			IN userid of bid creator
--	p_auctpid			IN auction creators trading partner id
--	p_tpid				IN trading partner id of supplier
--	p_has_pe_flag		IN flag to indicate of auction has price elements
--	p_supp_seq_number	IN sequence number of supplier for price elements
--	p_rate				IN rate for bid to auction currency
--	p_price_prec		IN auction bid currency precision
--	p_curr_prec			IN bid currency precision
--
--  COMMENT: Insert missing auction side lines into a draft bid
-- ======================================================================
PROCEDURE insert_auction_lines
(
	p_auc_header_id		IN pon_bid_headers.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_userid		IN pon_bid_headers.created_by%TYPE,
	p_auctpid		IN pon_auction_headers_all.trading_partner_id%TYPE,
	p_tpid			IN pon_bid_headers.trading_partner_id%TYPE,
	p_vensid		IN pon_bid_headers.vendor_site_id%TYPE,
	p_has_pe_flag		IN VARCHAR2,
	p_blanket		IN VARCHAR2,
	p_full_qty		IN VARCHAR2,
	p_supp_seq_number	IN pon_bidding_parties.sequence%TYPE,
	p_rate			IN pon_bid_headers.rate%TYPE,
	p_price_prec		IN pon_bid_headers.number_price_decimals%TYPE,
	p_curr_prec		IN fnd_currencies.precision%TYPE,
	p_batch_start		IN pon_bid_item_prices.line_number%TYPE,
	p_batch_end		IN pon_bid_item_prices.line_number%TYPE
) IS
	l_skip_pf_for_batch VARCHAR2(1);
	l_restricted_flag	VARCHAR2(1);
	l_supp_seq_number	pon_bidding_parties.sequence%TYPE;
BEGIN


	/************************************************************
	 * STEP 1: For lines with negotiable shipments, insert all the
	** missing bid shipments for only those lines that the supplier
	** never attempted to bid on. We need to insert these shipments
	** before we actually insert the bid lines so that the "not
	** exists" clause doesn't cause data corruption.
	*************************************************************/

	-- Insert missing shipments for all non-negotiable shipments
	INSERT INTO pon_bid_shipments
	(
		BID_NUMBER,
		LINE_NUMBER,
		SHIPMENT_NUMBER,
		AUCTION_HEADER_ID,
		AUCTION_LINE_NUMBER,
		AUCTION_SHIPMENT_NUMBER,
		SHIPMENT_TYPE,
		SHIP_TO_ORGANIZATION_ID,
		SHIP_TO_LOCATION_ID,
		QUANTITY,
		MAX_QUANTITY,
		PRICE_TYPE,
		PRICE,
		EFFECTIVE_START_DATE,
		EFFECTIVE_END_DATE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		HAS_PRICE_DIFFERENTIALS_FLAG
	)
	(SELECT
		p_bid_number,			-- BID_NUMBER
		apb.line_number,		-- LINE_NUMBER
		apb.shipment_number+1,		-- SHIPMENT_NUMBER
		p_auc_header_id,		-- AUCTION_HEADER_ID
		apb.line_number,		-- AUCTION_LINE_NUMBER
		apb.shipment_number,		-- AUCTION_SHIPMENT_NUMBER
		apb.shipment_type,		-- SHIPMENT_TYPE
		apb.ship_to_organization_id, 	-- SHIP_TO_ORGANIZATION_ID
		apb.ship_to_location_id, 	-- SHIP_TO_LOCATION_ID
		apb.quantity, 			-- QUANTITY
		apb.max_quantity,               -- MAX_QUANTITY
		'PRICE', 			-- PRICE_TYPE
		apb.price, 			-- PRICE
		apb.effective_start_date, 	-- EFFECTIVE_START_DATE
		apb.effective_end_date, 	-- EFFECTIVE_END_DATE
		sysdate,			-- CREATION_DATE
		p_userid,			-- CREATED_BY
		sysdate,			-- LAST_UPDATE_DATE
		p_userid,			-- LAST_UPDATED_BY
		null,				-- LAST_UPDATE_LOGIN
		apb.has_price_differentials_flag -- HAS_PRICE_DIFFERENTIALS_FLAG
	FROM 	pon_auction_shipments_all apb, pon_auction_item_prices_all aip
	WHERE 	apb.auction_header_id = p_auc_header_id
	AND     aip.auction_header_id = apb.auction_header_id
	AND 	apb.line_number BETWEEN p_batch_start AND p_batch_end
	AND     aip.line_number = apb.line_number
	AND 	nvl(aip.price_break_neg_flag, 'N') = 'Y'
	AND 	NOT EXISTS
			(SELECT pbip.line_number
			 FROM   pon_bid_item_prices pbip
			 WHERE  pbip.bid_number = p_bid_number
			 AND    pbip.line_number = apb.line_number));


	/************************************************************
	 * STEP 2: Check whether the current supplier was excluded from
	** bidding oncertain lines. Set the flags in local variables.
	** Logic used is to blindly insert all the lines and then
	** delete the lines that the current supplier was excluded from.
	*************************************************************/

	BEGIN
		-- Check if the supplier has restricted lines, and get sequence number
		SELECT decode(bp.access_type, 'RESTRICTED', 'Y', 'N'), bp.sequence
		INTO l_restricted_flag, l_supp_seq_number
		FROM pon_bidding_parties bp
		WHERE bp.auction_header_id = p_auc_header_id
			AND bp.trading_partner_id = p_tpid
			AND nvl(bp.vendor_site_id, -1) = p_vensid;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			l_restricted_flag := 'N';
			l_supp_seq_number := null;
	END;


	/************************************************************
	 * STEP 3: Insert missing auction lines.  pon_bid_item_prices
	** has an index on (bid_number, line_number) so the EXISTS
	** clause does not result in a full table scan.
	*************************************************************/

	INSERT INTO pon_bid_item_prices
	(
		AUCTION_HEADER_ID,
		AUCTION_LINE_NUMBER,
		BID_NUMBER,
		LINE_NUMBER,
		ITEM_DESCRIPTION,
		CATEGORY_ID,
		CATEGORY_NAME,
		UOM,
		QUANTITY,
		LANGUAGE_CODE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		AUCTION_CREATION_DATE,
		SHIP_TO_LOCATION_ID,
		PROXY_BID_FLAG,
		UNIT_OF_MEASURE,
		HAS_ATTRIBUTES_FLAG,
		FREIGHT_TERMS_CODE,
		TBD_PRICING_FLAG,
		AUC_TRADING_PARTNER_ID,
		BID_TRADING_PARTNER_ID,
		PRICE_BREAK_TYPE,
		HAS_SHIPMENTS_FLAG,
		IS_CHANGED_LINE_FLAG,
		HAS_PRICE_DIFFERENTIALS_FLAG,
		PRICE_DIFF_SHIPMENT_NUMBER,
		HAS_BID_FLAG,
        HAS_BID_PAYMENTS_FLAG,
        BID_START_PRICE,
        HAS_QUANTITY_TIERS

	)
	(SELECT
		al.auction_header_id,		-- AUCTION_HEADER_ID
		al.line_number,			-- AUCTION_LINE_NUMBER
		p_bid_number,			-- BID_NUMBER
		al.line_number,			-- LINE_NUMBER
		al.item_description,		-- ITEM_DESCRIPTION
		al.category_id,			-- CATEGORY_ID
		al.category_name,		-- CATEGORY_NAME
		al.uom_code,			-- UOM
		decode(p_blanket, 'Y', null,
			decode(p_full_qty, 'Y', al.quantity,
				decode(al.group_type, 'LOT_LINE', al.quantity,
					decode(al.order_type_lookup_code, 'AMOUNT',
					al.quantity, null)))), -- QUANTITY
		userenv('LANG'),			-- LANGUAGE_CODE
		SYSDATE,					-- CREATION_DATE
		p_userid,					-- CREATED_BY
		SYSDATE,					-- LAST_UPDATE_DATE
		p_userid,					-- LAST_UPDATED_BY
		al.auction_creation_date,	-- AUCTION_CREATION_DATE
		al.ship_to_location_id,		-- SHIP_TO_LOCATION_ID
		'N',				-- PROXY_BID_FLAG
		al.unit_of_measure,		-- UNIT_OF_MEASURE
		al.has_attributes_flag,		-- HAS_ATTRIBUTES_FLAG
		al.freight_terms_code,		-- FREIGHT_TERMS_CODE
		'N',				-- TBD_PRICING_FLAG
		p_auctpid,			-- AUC_TRADING_PARTNER_ID
		p_tpid,				-- BID_TRADING_PARTNER_ID
		al.price_break_type,		-- PRICE_BREAK_TYPE
		al.has_shipments_flag, 		-- HAS_SHIPMENTS_FLAG
		'N',				-- IS_CHANGED_LINE_FLAG
		al.has_price_differentials_flag,-- HAS_PRICE_DIFFERENTIALS_FLAG
		al.price_diff_shipment_number,	-- PRICE_DIFF_SHIPMENT_NUMBER *
		'N',				-- HAS_BID_FLAG
        	'N',				-- HAS_BID_PAYMENTS_FLAG
		al.bid_start_price,		-- BID_START_PRICE
		al.has_quantity_tiers 		-- HAS_QUANTITY_TIERS
	FROM pon_auction_item_prices_all al
	WHERE al.auction_header_id = p_auc_header_id
		AND al.line_number BETWEEN p_batch_start AND p_batch_end
		AND NOT EXISTS
			(SELECT bl.line_number
			FROM pon_bid_item_prices bl
			WHERE bl.bid_number = p_bid_number
				AND bl.line_number = al.line_number));

	/************************************************************
	** STEP 4: Delete all the excluded lines.
	*************************************************************/

	IF (l_restricted_flag = 'Y') THEN

		DELETE FROM pon_bid_item_prices bl
		WHERE bl.bid_number = p_bid_number
			AND bl.line_number BETWEEN p_batch_start AND p_batch_end
			AND EXISTS
				(SELECT le.line_number
				FROM pon_party_line_exclusions le, pon_auction_item_prices_all al
				WHERE al.auction_header_id = p_auc_header_id
					AND al.line_number = bl.line_number
					AND le.auction_header_id = al.auction_header_id
					AND le.line_number = nvl(al.parent_line_number, al.line_number)
					AND le.trading_partner_id = p_tpid
					AND le.vendor_site_id = p_vensid);
	END IF;


	/************************************************************
	** STEP 5: Insert missing line attributes
	*************************************************************/

	INSERT INTO pon_bid_attribute_values
	(
		AUCTION_HEADER_ID,
		AUCTION_LINE_NUMBER,
		BID_NUMBER,
		LINE_NUMBER,
		ATTRIBUTE_NAME,
		DATATYPE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		SEQUENCE_NUMBER,
		ATTR_LEVEL,
		ATTR_GROUP_SEQ_NUMBER,
		ATTR_DISP_SEQ_NUMBER
	)
	(SELECT
		aa.auction_header_id,		-- AUCTION_HEADER_ID
		aa.line_number,				-- AUCTION_LINE_NUMBER
		p_bid_number,				-- BID_NUMBER
		aa.line_number,				-- LINE_NUMBER
		aa.attribute_name,			-- ATTRIBUTE_NAME
		aa.datatype,				-- DATATYPE
		sysdate,					-- CREATION_DATE
		p_userid,					-- CREATED_BY
		sysdate,					-- LAST_UPDATE_DATE
		p_userid,					-- LAST_UPDATED_BY
		aa.sequence_number,			-- SEQUENCE_NUMBER
		aa.attr_level,				-- ATTR_LEVEL
		aa.attr_group_seq_number,	-- ATTR_GROUP_SEQ_NUMBER
		aa.attr_disp_seq_number		-- ATTR_DISP_SEQ_NUMBER
	FROM pon_auction_attributes aa
	WHERE aa.auction_header_id = p_auc_header_id
		AND aa.line_number BETWEEN p_batch_start AND p_batch_end
		AND NOT EXISTS
			(SELECT pbav.attribute_name
			 FROM 	pon_bid_attribute_values pbav
			 WHERE  pbav.bid_number = p_bid_number
			 AND    pbav.line_number = aa.line_number
			 AND    pbav.sequence_number = aa.sequence_number));

	/************************************************************
	** STEP 6: Insert missing bid cost factors or price elements
	** or price factors
	*************************************************************/

	/************************************************************
	** STEP 6a: Populate display_price_factors flag as it is a
	** rel12 column
	*************************************************************/

	populate_display_pf_flag (p_auc_header_id,
		 		  p_bid_number,
		 		  p_supp_seq_number,
		 		  p_batch_start,
		 		  p_batch_end,
		 		  l_skip_pf_for_batch);

	/************************************************************
	** STEP 6b: Batching enabled inserts - if we are not supposed to
	** skip this set of lines in the batch, then go ahead with
	** inserts
	*************************************************************/

	IF (l_skip_pf_for_batch = 'N') THEN

		-- Insert missing SUPPLIER price factors only if they exist
		IF (p_has_pe_flag = 'Y') THEN
			INSERT INTO pon_bid_price_elements
			(
				BID_NUMBER,
				LINE_NUMBER,
				PRICE_ELEMENT_TYPE_ID,
				AUCTION_HEADER_ID,
				PRICING_BASIS,
				SEQUENCE_NUMBER,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				PF_TYPE
			)
			(SELECT
				p_bid_number,				-- BID_NUMBER
				apf.line_number,			-- LINE_NUMBER
				apf.price_element_type_id,	-- PRICE_ELEMENT_TYPE_ID
				p_auc_header_id,			-- AUCTION_HEADER_ID
				apf.pricing_basis,			-- PRICING_BASIS
				apf.sequence_number,		-- SEQUENCE_NUMBER
				sysdate,					-- CREATION_DATE
				p_userid,					-- CREATED_BY
				sysdate,					-- LAST_UPDATE_DATE
				p_userid,					-- LAST_UPDATED_BY
				apf.pf_type					-- PF_TYPE
			FROM pon_price_elements apf
			WHERE apf.auction_header_id = p_auc_header_id
				AND apf.pf_type = 'SUPPLIER'			-- only supplier price factors
				AND apf.line_number BETWEEN p_batch_start AND p_batch_end
				AND NOT EXISTS
                                       (SELECT 	pbpe.price_element_type_id
                                       	FROM 	pon_bid_price_elements pbpe
                                       	WHERE 	pbpe.bid_number = p_bid_number
                                       	AND   	pbpe.line_number = apf.line_number
					AND  	pbpe.price_element_type_id = apf.price_element_type_id));


		END IF;



	/************************************************************
	** STEP 6c: Check for buyer price factors - if this supplier
	** is invited to the negotiation.
	*************************************************************/

		-- Insert missing BUYER price factors if applicable
		IF (p_supp_seq_number IS NOT null) THEN

			INSERT INTO pon_bid_price_elements
			(
				BID_NUMBER,
				LINE_NUMBER,
				PRICE_ELEMENT_TYPE_ID,
				AUCTION_HEADER_ID,
				PRICING_BASIS,
				AUCTION_CURRENCY_VALUE,
				BID_CURRENCY_VALUE,
				SEQUENCE_NUMBER,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				PF_TYPE
			)
			(SELECT
				p_bid_number,				-- BID_NUMBER
				apf.line_number,			-- LINE_NUMBER
				apf.price_element_type_id,	-- PRICE_ELEMENT_TYPE_ID
				p_auc_header_id,			-- AUCTION_HEADER_ID
				apf.pricing_basis,			-- PRICING_BASIS
				pf.value,					-- AUCTION_CURRENCY_VALUE
				decode(apf.pricing_basis,
					'PER_UNIT', round(pf.value * p_rate, p_price_prec),
					'FIXED_AMOUNT', round(pf.value * p_rate, p_curr_prec),
					'PERCENTAGE', pf.value), -- BID_CURRENCY_VALUE
				apf.sequence_number,		-- SEQUENCE_NUMBER
				sysdate,					-- CREATION_DATE
				p_userid,					-- CREATED_BY
				sysdate,					-- LAST_UPDATE_DATE
				p_userid,					-- LAST_UPDATED_BY
				apf.pf_type					-- PF_TYPE
			FROM pon_price_elements apf,
				pon_pf_supplier_values pf,
				pon_bid_item_prices bl
			WHERE apf.auction_header_id = p_auc_header_id
				AND apf.pf_type = 'BUYER'		-- only buyer pf that are to be displayed
				AND apf.display_to_suppliers_flag = 'Y'
				AND bl.bid_number = p_bid_number
				AND bl.line_number = apf.line_number
				AND bl.display_price_factors_flag = 'Y'
				AND pf.auction_header_id = apf.auction_header_id
				AND pf.line_number = apf.line_number
				AND pf.pf_seq_number = apf.sequence_number
				AND pf.supplier_seq_number = p_supp_seq_number
				AND nvl(pf.value, 0) <> 0
				AND apf.line_number BETWEEN p_batch_start AND p_batch_end
				AND NOT EXISTS
					(SELECT pbpe.price_element_type_id
					 FROM 	pon_bid_price_elements pbpe
					 WHERE  pbpe.bid_number = p_bid_number
					 AND    pbpe.line_number = apf.line_number
					 AND    pbpe.price_element_type_id = apf.price_element_type_id));

		END IF;
	END IF;

	-- Insert missing shipments for all non-negotiable shipments


	/************************************************************
	** STEP 7: Insert all the missing non-negotiable or required
	** or mandatory shipments/price breaks.
	*************************************************************/

    /*
     * Price Tiers Enhancements
     * Quantity tiers are negotiable shipments so no need to copy the max_quantity field here
     */

	INSERT INTO pon_bid_shipments
	(
		BID_NUMBER,
		LINE_NUMBER,
		SHIPMENT_NUMBER,
		AUCTION_HEADER_ID,
		AUCTION_LINE_NUMBER,
		AUCTION_SHIPMENT_NUMBER,
		SHIPMENT_TYPE,
		SHIP_TO_ORGANIZATION_ID,
		SHIP_TO_LOCATION_ID,
		QUANTITY,
		PRICE_TYPE,
		PRICE,
		EFFECTIVE_START_DATE,
		EFFECTIVE_END_DATE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		HAS_PRICE_DIFFERENTIALS_FLAG
	)
	(SELECT
		p_bid_number,			-- BID_NUMBER
		apb.line_number,		-- LINE_NUMBER
		apb.shipment_number+1,		-- SHIPMENT_NUMBER
		p_auc_header_id,		-- AUCTION_HEADER_ID
		apb.line_number,		-- AUCTION_LINE_NUMBER
		apb.shipment_number,		-- AUCTION_SHIPMENT_NUMBER
		apb.shipment_type,		-- SHIPMENT_TYPE
		apb.ship_to_organization_id, 	-- SHIP_TO_ORGANIZATION_ID
		apb.ship_to_location_id, 	-- SHIP_TO_LOCATION_ID
		apb.quantity, 			-- QUANTITY
		'PRICE', 			-- PRICE_TYPE
		apb.price, 			-- PRICE
		apb.effective_start_date, 	-- EFFECTIVE_START_DATE
		apb.effective_end_date, 	-- EFFECTIVE_END_DATE
		sysdate,			-- CREATION_DATE
		p_userid,			-- CREATED_BY
		sysdate,			-- LAST_UPDATE_DATE
		p_userid,			-- LAST_UPDATED_BY
		null,				-- LAST_UPDATE_LOGIN
		apb.has_price_differentials_flag -- HAS_PRICE_DIFFERENTIALS_FLAG
	FROM 	pon_auction_shipments_all apb, pon_auction_item_prices_all aip
	WHERE 	apb.auction_header_id = p_auc_header_id
	AND 	apb.line_number BETWEEN p_batch_start AND p_batch_end
	AND	aip.auction_header_id = apb.auction_header_id
	AND	aip.line_number = apb.line_number
	AND 	nvl(aip.price_break_neg_flag, 'Y') = 'N'
	AND 	NOT EXISTS
			(SELECT pbs.auction_shipment_number
			 FROM   pon_bid_shipments pbs
			 WHERE  pbs.bid_number = p_bid_number
			 AND    pbs.line_number = apb.line_number
			 AND    pbs.auction_shipment_number = apb.shipment_number));

	/************************************************************
	** STEP 8: Insert all the missing line-level as well as shipment
	** level price breaks in a single insert statement.
	*************************************************************/

	INSERT INTO pon_bid_price_differentials
	(
		AUCTION_HEADER_ID,
		BID_NUMBER,
		LINE_NUMBER,
		SHIPMENT_NUMBER,
		PRICE_DIFFERENTIAL_NUMBER,
		PRICE_TYPE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN
	)
	(SELECT
		p_auc_header_id,			-- AUCTION_HEADER_ID
		p_bid_number,				-- BID_NUMBER
		apd.line_number,			-- LINE_NUMBER
		decode(apd.shipment_number, -1, -1, apd.shipment_number+1),	-- SHIPMENT_NUMBER
		apd.price_differential_number, 		-- PRICE_DIFFERENTIAL_NUMBER
		apd.price_type,				-- PRICE_TYPE
		sysdate,				-- CREATION_DATE
		p_userid,				-- CREATED_BY
		sysdate,				-- LAST_UPDATE_DATE
		p_userid,				-- LAST_UPDATED_BY
		null					-- LAST_UPDATE_LOGIN
	FROM pon_price_differentials apd
	WHERE apd.auction_header_id = p_auc_header_id
		AND apd.line_number BETWEEN p_batch_start AND p_batch_end
		AND NOT EXISTS
			(SELECT pbpd.price_differential_number
			 FROM   pon_bid_price_differentials pbpd
			 WHERE  pbpd.bid_number = p_bid_number
			 AND    pbpd.line_number = apd.line_number
			 AND    pbpd.price_differential_number = apd.price_differential_number));

END insert_auction_lines;

-- ======================================================================
-- PROCEDURE:	POPULATE_OLD_VALUE_COLUMNS	PRIVATE
--  PARAMETERS:
--	p_bid_number		IN new bid number
--	p_source_bid_num	IN source bid number
--
--  COMMENT: Populate old value columns for a bid
-- ======================================================================
PROCEDURE populate_old_value_columns
(
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_source_bid_num	IN pon_bid_headers.bid_number%TYPE,
	p_batch_start		IN pon_bid_item_prices.line_number%TYPE,
	p_batch_end			IN pon_bid_item_prices.line_number%TYPE
) IS
BEGIN

	-- Update line level old value columns
	UPDATE pon_bid_item_prices bl
	SET (bl.old_price,
		bl.old_bid_currency_unit_price,
		bl.old_bid_currency_price,
		bl.old_bid_currency_limit_price,
		bl.old_po_bid_min_rel_amount,
		bl.old_quantity,
		bl.old_publish_date,
		bl.old_promised_date,
		bl.old_note_to_auction_owner,
		bl.old_bid_curr_advance_amount,
		bl.old_recoupment_rate_percent,
		bl.old_progress_pymt_rate_percent,
		bl.old_retainage_rate_percent,
		bl.old_bid_curr_max_retainage_amt) =
		(SELECT
			old_bl.price,
			old_bl.bid_currency_unit_price,
			old_bl.bid_currency_price,
			old_bl.bid_currency_limit_price,
			old_bl.po_bid_min_rel_amount,
			old_bl.quantity,
			old_bl.publish_date,
			old_bl.promised_date,
			old_bl.note_to_auction_owner,
			old_bl.bid_curr_advance_amount,
			old_bl.recoupment_rate_percent,
			old_bl.progress_pymt_rate_percent,
			old_bl.retainage_rate_percent,
			old_bl.bid_curr_max_retainage_amt
		FROM pon_bid_item_prices old_bl
		WHERE old_bl.bid_number = p_source_bid_num
			AND old_bl.line_number = bl.line_number)
	WHERE bl.bid_number = p_bid_number
		AND bl.line_number BETWEEN p_batch_start AND p_batch_end;

	-- Update attribute old value columns
	UPDATE pon_bid_attribute_values ba
	SET	ba.old_value =
		(SELECT old_ba.value
		FROM pon_bid_attribute_values old_ba
		WHERE old_ba.bid_number = p_source_bid_num
			AND old_ba.line_number = ba.line_number
			AND old_ba.attribute_name = ba.attribute_name)
	WHERE ba.bid_number = p_bid_number
		AND ba.line_number BETWEEN p_batch_start AND p_batch_end;

	-- Update SUPPLIER price factor old value columns
	UPDATE pon_bid_price_elements bpf
	SET	bpf.old_bid_currency_value =
		(SELECT old_bpf.bid_currency_value
		FROM pon_bid_price_elements old_bpf
		WHERE old_bpf.bid_number = p_source_bid_num
			AND old_bpf.line_number = bpf.line_number
			AND old_bpf.price_element_type_id = bpf.price_element_type_id)
	WHERE bpf.bid_number = p_bid_number
		AND bpf.pf_type = 'SUPPLIER'
		AND bpf.line_number BETWEEN p_batch_start AND p_batch_end;

	-- Update price break old value columns
	UPDATE pon_bid_shipments bpb
	SET	(bpb.old_bid_currency_unit_price,
		bpb.old_bid_currency_price,
		bpb.old_price_discount,
		bpb.old_ship_to_org_id,
		bpb.old_ship_to_loc_id,
		bpb.old_effective_start_date,
		bpb.old_effective_end_date,
		bpb.old_quantity,
		bpb.old_max_quantity,
		bpb.old_price_type) =
		(SELECT
			old_bpb.bid_currency_unit_price,
			old_bpb.bid_currency_price,
			old_bpb.price_discount,
			old_bpb.ship_to_organization_id,
			old_bpb.ship_to_location_id,
			old_bpb.effective_start_date,
			old_bpb.effective_end_date,
			old_bpb.quantity,
			old_bpb.max_quantity,
			old_bpb.price_type
		FROM pon_bid_shipments old_bpb
		WHERE old_bpb.bid_number = p_source_bid_num
			AND old_bpb.line_number = bpb.line_number
			AND old_bpb.shipment_number = bpb.shipment_number)
	WHERE bpb.bid_number = p_bid_number
		AND bpb.line_number BETWEEN p_batch_start AND p_batch_end;

	-- Update price differential old value columns
	UPDATE pon_bid_price_differentials bpd
	SET	bpd.old_multiplier =
		(SELECT old_bpd.multiplier
		FROM pon_bid_price_differentials old_bpd
		WHERE old_bpd.bid_number = p_source_bid_num
			AND old_bpd.line_number = bpd.line_number
			AND old_bpd.shipment_number = bpd.shipment_number
			AND old_bpd.price_differential_number = bpd.price_differential_number)
	WHERE bpd.bid_number = p_bid_number
		AND bpd.line_number BETWEEN p_batch_start AND p_batch_end;

END populate_old_value_columns;

-- ======================================================================
-- PROCEDURE:	HANDLE_PROXY   PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN the auction header id
--  p_draft_bid_num   	IN bid number to update proxy for
--	p_tpid				IN trading partner id of supplier
--	p_tpcid				IN trading partner contact id of supplier
--	p_vensid			IN vendor site bid is placed on
--	p_evaluator_id		IN evaluator user id
--	p_eval_flag		IN flag indicating if the response is an evaluation
--  x_prev_bid_number	OUT returned backing bid number
--  x_rebid_flag		OUT Y/N if the current bid is a rebid/not a rebid
--
--  COMMENT: updates price, limit_price, and copy_price_for_proxy_flag
--			First finds the backing ACTIVE bid, if it exists and determine
--			if the bid was a rebid
-- ======================================================================
PROCEDURE handle_proxy
(
	p_auc_header_id		IN pon_bid_headers.auction_header_id%TYPE,
	p_draft_bid_num		IN pon_bid_headers.bid_number%TYPE,
	p_tpid				IN pon_bid_headers.trading_partner_id%TYPE,
	p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE,
	p_vensid			IN pon_bid_headers.vendor_site_id%TYPE,
	------------ Supplier Management: Supplier Evaluation ------------
	p_evaluator_id		IN pon_bid_headers.evaluator_id%TYPE,
	p_eval_flag		IN pon_bid_headers.evaluation_flag%TYPE,
	------------------------------------------------------------------
	x_prev_bid_number	OUT NOCOPY pon_bid_headers.bid_number%TYPE,
	x_rebid_flag		OUT NOCOPY VARCHAR2
) IS
	l_max_line_number	pon_bid_item_prices.line_number%TYPE;
	l_batch_start		pon_bid_item_prices.line_number%TYPE;
	l_batch_end			pon_bid_item_prices.line_number%TYPE;
BEGIN

	-- Determine the latest ACTIVE bid and set rebid_flag to Y
	-- Since there can only exist a single ACTIVE bid on an amendment for
	-- a particular user on a site, we use the rownum = 1 optimisation

	-- It is possible that another supplier from the same supplier company
	-- is modifying the draft. So we can't use the login in supplier's tpcid,
	-- we should use the tpcid of the user who creates the draft

	------- Supplier Management: Supplier Evaluation -------
	-- Add evaluator_id and evaluation_flag to the query  --
	--------------------------------------------------------
	SELECT bh.bid_number, 'Y'
	INTO x_prev_bid_number, x_rebid_flag
	FROM pon_bid_headers bh
	WHERE bh.auction_header_id = p_auc_header_id
		AND bh.trading_partner_id = p_tpid
		AND bh.trading_partner_contact_id =
			(SELECT trading_partner_contact_id
			FROM pon_bid_headers bh2
			WHERE bh2.bid_number = p_draft_bid_num)
		AND bh.vendor_site_id = p_vensid
		AND bh.bid_status = 'ACTIVE'
		AND nvl(bh.evaluator_id, -1) = nvl(p_evaluator_id, -1)
		AND nvl(bh.evaluation_flag, 'N') = p_eval_flag
		AND rownum = 1
	ORDER BY bh.publish_date DESC;

	-- Update old_bid_number to new source bid
	UPDATE pon_bid_headers bh
	SET bh.old_bid_number = x_prev_bid_number
	WHERE bh.bid_number = p_draft_bid_num;

	-- START BATCHING

	-- Determine the maximum line number for the negotiation
	SELECT ah.max_internal_line_num
	INTO l_max_line_number
	FROM pon_auction_headers_all ah
	WHERE ah.auction_header_id = p_auc_header_id;

	-- Define the initial batch range (line numbers are indexed from 1)
	l_batch_start := 1;
	IF (l_max_line_number < PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE) THEN
		l_batch_end := l_max_line_number;
	ELSE
		l_batch_end := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
	END IF;

	WHILE (l_batch_start <= l_max_line_number) LOOP

		-- Copy over price columns and set copy_price_for_proxy_flag
		-- If the proxy has been exhausted, copy_price_for_proxy flag changed to N
		UPDATE pon_bid_item_prices bl
		SET (bl.price, bl.proxy_bid_limit_price, bl.bid_currency_price,
			bl.bid_currency_limit_price, bl.bid_currency_trans_price,
			bl.unit_price, bl.bid_currency_unit_price, bl.copy_price_for_proxy_flag,
			bl.old_price, bl.old_bid_currency_unit_price, bl.old_bid_currency_price,
			bl.old_bid_currency_limit_price) =
			(SELECT old_bl.price, old_bl.proxy_bid_limit_price, old_bl.bid_currency_price,
				old_bl.bid_currency_limit_price, old_bl.bid_currency_trans_price,
				old_bl.unit_price, old_bl.bid_currency_unit_price,
				decode(sign(old_bl.proxy_bid_limit_price - old_bl.price),
					0, 'N', 'Y'),
				old_bl.price, old_bl.bid_currency_unit_price, old_bl.bid_currency_price, old_bl.bid_currency_limit_price
			FROM pon_bid_item_prices old_bl
			WHERE old_bl.bid_number = x_prev_bid_number
				AND old_bl.line_number = bl.line_number)
		WHERE bl.bid_number = p_draft_bid_num
			AND bl.copy_price_for_proxy_flag = 'Y'
			AND bl.line_number BETWEEN l_batch_start AND l_batch_end;

		-- Copy over the rank for all lines
		UPDATE pon_bid_item_prices bl
		SET rank =
			(SELECT old_bl.rank
			FROM pon_bid_item_prices old_bl
			WHERE old_bl.bid_number = x_prev_bid_number
				AND old_bl.line_number = bl.line_number)
		WHERE bl.bid_number = p_draft_bid_num
			AND bl.line_number BETWEEN l_batch_start AND l_batch_end;

		-- Find the new batch range
		l_batch_start := l_batch_end + 1;
		IF (l_batch_end + PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE > l_max_line_number) THEN
			l_batch_end := l_max_line_number;
		ELSE
			l_batch_end := l_batch_end + PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
		END IF;

	END LOOP;

	-- END BATCHING

EXCEPTION
	-- No ACTIVE bids on the current amendment
	WHEN NO_DATA_FOUND THEN
		SELECT bh.old_bid_number
		INTO x_prev_bid_number
		FROM pon_bid_headers bh
		WHERE bh.bid_number = p_draft_bid_num;
		x_rebid_flag := 'N';

END handle_proxy;

-- ======================================================================
-- PROCEDURE:	INSERT_INTO_BID_HEADER  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction_header_id of negotiation
--	p_source_bid_num	IN source_bid to default from
--	p_tpid				IN trading partner id of supplier
--	p_tpname			IN trading partner name of supplier
--	p_tpcid				IN trading partner contact id of supplier
--	p_tpcname			IN trading partner contact name of supplier
--	p_userid			IN userid of bid creator
--	p_venid				IN vendor id
--	p_vensid			IN vendor site id to place bid for
--	p_venscode			IN vendor site code to place bid for
--	p_auctpid			IN buyers trading partner id
--	p_auctpcid			IN buyers trading partner contact id
--	p_buyer_user		IN flag indicating surrogate bid or not
--	p_evaluator_id		IN evaluator user id
--	p_eval_flag		IN flag indicating if the response is an evaluation
--	p_rebid_flag		IN flag indicating rebid or not
--	x_bid_number		OUT bid number of the new bid
--
--  COMMENT: inserts a bid header for the new bid. Also generates the bid number
-- ======================================================================
PROCEDURE insert_into_bid_header
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_source_bid_num	IN pon_bid_headers.bid_number%TYPE,
	p_tpid				IN pon_bid_headers.trading_partner_id%TYPE,
	p_tpname			IN pon_bid_headers.trading_partner_name%TYPE,
	p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE,
	p_tpcname			IN pon_bid_headers.trading_partner_contact_name%TYPE,
	p_userid			IN pon_bid_headers.created_by%TYPE,
	p_venid				IN pon_bid_headers.vendor_id%TYPE,
	p_vensid			IN pon_bid_headers.vendor_site_id%TYPE,
	p_venscode			IN pon_bid_headers.vendor_site_code%TYPE,
	p_auctpid			IN pon_bid_headers.surrog_bid_created_tp_id%TYPE,
	p_auctpcid			IN pon_bid_headers.surrog_bid_created_contact_id%TYPE,
	p_buyer_user		IN VARCHAR2,
	----------- Supplier Management: Supplier Evaluation -----------
	p_evaluator_id		IN pon_bid_headers.evaluator_id%TYPE,
	p_eval_flag		IN pon_bid_headers.evaluation_flag%TYPE,
	----------------------------------------------------------------
	p_rebid_flag		IN VARCHAR2,
	p_prev_bid_disq		IN VARCHAR2,
	x_bid_number		OUT NOCOPY pon_bid_headers.bid_number%TYPE
) IS
    l_old_min_bid_change_type pon_auction_headers_all.min_bid_change_type%TYPE;
    l_old_min_bid_change pon_auction_headers_all.min_bid_decrement%TYPE;
    -- added by Allen Yang 2009/01/06 for surrogate bid bug 7664486
    ----------------------------------------------------------------
    l_two_part_flag pon_auction_headers_all.TWO_PART_FLAG%TYPE;
    l_technical_evaluation_status pon_auction_headers_all.TECHNICAL_EVALUATION_STATUS%TYPE;
    ----------------------------------------------------------------
BEGIN

    IF p_source_bid_num IS NOT NULL AND p_source_bid_num <> 0 THEN
      SELECT pah.min_bid_change_type,
             pah.min_bid_decrement
             -- added by Allen Yang 2009/01/06 for surrogate bid bug 7664486
             -------------------------------------------------------
             , pah.TWO_PART_FLAG
             , pah.TECHNICAL_EVALUATION_STATUS
             -------------------------------------------------------
      INTO l_old_min_bid_change_type,
           l_old_min_bid_change
           -- added by Allen Yang 2009/01/06 for surrogate bid bug 7664486
           -------------------------------------------------------
           , l_two_part_flag
           , l_technical_evaluation_status
           -------------------------------------------------------
      FROM PON_AUCTION_HEADERS_ALL pah,
           PON_BID_HEADERS pbh
      WHERE pah.auction_header_id = pbh.auction_header_id
      AND pbh.bid_number = p_source_bid_num;
    END IF;

	-- Generate next bid number
	SELECT pon_bid_headers_s.nextval INTO x_bid_number
	FROM dual;

	INSERT INTO pon_bid_headers
	(
		BID_NUMBER,
		AUCTION_HEADER_ID,
		BIDDERS_BID_NUMBER,
		BID_TYPE,
		CONTRACT_TYPE,
		TRADING_PARTNER_CONTACT_NAME,
		TRADING_PARTNER_CONTACT_ID,
		TRADING_PARTNER_NAME,
		TRADING_PARTNER_ID,
		BID_STATUS,
		BID_EFFECTIVE_DATE,
		BID_EXPIRATION_DATE,
		DISQUALIFY_REASON,
		FREIGHT_TERMS_CODE,
		CARRIER_CODE,
		FOB_CODE,
		NOTE_TO_AUCTION_OWNER,
		LANGUAGE_CODE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		AUCTION_CREATION_DATE,
		BID_CURRENCY_CODE,
		RATE,
		MIN_BID_CHANGE ,
		PROXY_BID_FLAG ,
		NUMBER_PRICE_DECIMALS,
		DOCTYPE_ID,
		VENDOR_ID,
		VENDOR_SITE_ID ,
		RATE_DSP,
		INITIATE_APPROVAL,
		DRAFT_LOCKED,
		DRAFT_LOCKED_BY,
		DRAFT_LOCKED_BY_CONTACT_ID,
		DRAFT_LOCKED_DATE,
		VENDOR_SITE_CODE,
		SHORTLIST_FLAG,
		ATTRIBUTE_LINE_NUMBER,
		NOTE_TO_SUPPLIER,
		SURROG_BID_CREATED_TP_ID,
		SURROG_BID_CREATED_CONTACT_ID,
		SURROG_BID_RECEIPT_DATE,
		SURROG_BID_ONLINE_ENTRY_DATE,
		SURROG_BID_FLAG,
		COLOR_SEQUENCE_ID,
		OLD_NOTE_TO_AUCTION_OWNER,
		OLD_BIDDERS_BID_NUMBER,
		OLD_BID_EXPIRATION_DATE,
		OLD_MIN_BID_CHANGE,
		OLD_BID_STATUS,
		OLD_SURROG_BID_RECEIPT_DATE,
		REL12_DRAFT_FLAG,
		OLD_BID_NUMBER
    --added by Allen Yang 2009/01/06 for surrogate bid bug 7664486
    --------------------------------------------------------------
    , SUBMIT_STAGE
    --------------------------------------------------------------
		---- Supplier Management: Supplier Evaluation ----
		,EVALUATOR_ID
		,EVALUATION_FLAG
		--------------------------------------------------
	)
	(SELECT
		x_bid_number,				-- BID_NUMBER
		ah.auction_header_id,		-- AUCTION_HEADER_ID
		bh.bidders_bid_number,		-- BIDDERS_BID_NUMBER
		'REVERSE',					-- BID_TYPE
		ah.contract_type,			-- CONTRACT_TYPE
		p_tpcname,					-- TRADING_PARTNER_CONTACT_NAME
		p_tpcid,					-- TRADING_PARTNER_CONTACT_ID
		p_tpname,					-- TRADING_PARTNER_NAME
		p_tpid,						-- TRADING_PARTNER_ID
		'DRAFT',					-- BID_STATUS
		bh.bid_effective_date,		-- BID_EFFECTIVE_DATE
		bh.bid_expiration_date,		-- BID_EXPIRATION_DATE
		decode(p_prev_bid_disq, 'Y', bh.disqualify_reason, null), -- DISQUALIFY_REASON
		ah.freight_terms_code,		-- FREIGHT_TERMS_CODE
		ah.carrier_code,			-- CARRIER_CODE
		ah.fob_code,				-- FOB_CODE
		bh.note_to_auction_owner,	-- NOTE_TO_AUCTION_OWNER
		userenv('LANG'),			-- LANGUAGE_CODE
		SYSDATE,					-- CREATION_DATE
		p_userid,					-- CREATED_BY
		SYSDATE,					-- LAST_UPDATE_DATE
		p_userid,					-- LAST_UPDATED_BY
		ah.creation_date,			-- AUCTION_CREATION_DATE
		nvl(bh.bid_currency_code, ah.currency_code), -- BID_CURRENCY_CODE
		nvl(bh.rate, 1),			-- RATE
	decode(ah.min_bid_change_type, l_old_min_bid_change_type,
    decode(ah.min_bid_decrement, l_old_min_bid_change, bh.min_bid_change, null), null),			-- MIN_BID_CHANGE
		'N',						-- PROXY_BID_FLAG
		nvl(bh.number_price_decimals, ah.number_price_decimals), -- NUMBER_PRICE_DECIMALS
		ah.doctype_id,				-- DOCTYPE_ID
		p_venid,					-- VENDOR_ID
		p_vensid,					-- VENDOR_SITE_ID
		nvl(bh.rate_dsp, 1),		-- RATE_DSP
		bh.initiate_approval,		-- INITIATE_APPROVAL
		'Y',						-- DRAFT_LOCKED
		decode(p_buyer_user, 'Y', p_auctpid, p_tpid), -- DRAFT_LOCKED_BY
		-- Begin Supplier Management: Supplier Evaluation
		-- Modified the following:
		decode(p_buyer_user, 'Y', p_auctpcid, decode(p_eval_flag, 'Y', p_evaluator_id, p_tpcid)), -- DRAFT_LOCKED_BY_CONTACT_ID
		-- End Supplier Management: Supplier Evaluation
		SYSDATE,					-- DRAFT_LOCKED_DATE
		p_venscode,					-- VENDOR_SITE_CODE
		'N',						-- SHORTLIST_FLAG
		-1,							-- ATTRIBUTE_LINE_NUMBER
		ah.note_to_bidders,			-- NOTE_TO_SUPPLIER
		decode(p_buyer_user, 'Y', p_auctpid, null), -- SURROG_BID_CREATED_TP_ID
		decode(p_buyer_user, 'Y', p_auctpcid, null), -- SURROG_BID_CREATED_CONTACT_ID
		 decode(p_buyer_user, 'Y',
         Decode((SELECT TWO_PART_FLAG FROM pon_auction_headers_all WHERE  AUCTION_HEADER_ID = bh.AUCTION_HEADER_ID),'Y',
         Decode(bh.SUBMIT_STAGE,'COMMERCIAL',bh.surrog_bid_receipt_date, null),NULL),NULL),
		--decode(p_buyer_user, 'Y', bh.surrog_bid_receipt_date, null),	-- SURROG_BID_RECEIPT_DATE
		decode(p_buyer_user, 'Y', sysdate, null), -- SURROG_BID_ONLINE_ENTRY_DATE
		p_buyer_user,				-- SURROG_BID_FLAG
		bh.color_sequence_id,		-- COLOR_SEQUENCE_ID
		decode(p_rebid_flag, 'Y', bh.note_to_auction_owner, null), -- OLD_NOTE_TO_AUCTION_OWNER
		decode(p_rebid_flag, 'Y', bh.bidders_bid_number, null), -- OLD_BIDDERS_BID_NUMBER
		decode(p_rebid_flag, 'Y', bh.bid_expiration_date, null), -- OLD_BID_EXPIRATION_DATE
		decode(p_rebid_flag, 'Y', bh.min_bid_change, null), -- OLD_MIN_BID_CHANGE
		decode(p_rebid_flag, 'Y', bh.bid_status, null),	-- OLD_BID_STATUS
		decode(p_rebid_flag, 'Y', bh.surrog_bid_receipt_date, null), -- OLD_SURROG_BID_RECEIPT_DATE
		'Y',						-- REL12_DRAFT_FLAG
		decode(p_source_bid_num, 0, null, p_source_bid_num)        -- OLD_BID_NUMBER
    -- added by Allen Yang 2009/01/06 for surrogate bid bug 7664486
    -----------------------------------------------------------------------------
    -- set submit_stage to TECHNICAL when requoting in commercial stage
    , decode(p_rebid_flag, 'Y',                                -- SUBMIT_STAGE
             decode(l_two_part_flag, 'Y',
                    decode(p_buyer_user, 'Y',
                           decode(l_technical_evaluation_status, 'COMPLETED', 'TECHNICAL', null), null), null), null)
    -----------------------------------------------------------------------------
		---------------- Supplier Management: Supplier Evaluation ----------------
		,decode(p_eval_flag, 'Y', p_evaluator_id, null)        -- EVALUATOR_ID
		,p_eval_flag                                           -- EVALUATION_FLAG
		--------------------------------------------------------------------------
	FROM pon_auction_headers_all ah, pon_bid_headers bh
	WHERE ah.auction_header_id = p_auc_header_id
		AND	bh.bid_number (+) = p_source_bid_num
		AND ah.auction_header_id >= bh.auction_header_id (+));

END insert_into_bid_header;

-- ======================================================================
-- PROCEDURE:	INSERT_INTO_BID_ITEMS  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction_header_id of negotiation
--	p_bid_number		IN bid number to insert lines for
--	p_source_bid_num	IN source_bid to default from
--	p_tpid				IN trading partner id of supplier
--	p_userid			IN userid of bid creator
--	p_vensid			IN vendor site id to place bid for
--	p_rebid_flag		IN flag indicating rebid or not
--	p_restricted_flag	IN flag indicating whether certain lines may be restricted
--
--  COMMENT: inserts lines for the new bid, defualting as necessary
-- ======================================================================
PROCEDURE insert_into_bid_items
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_source_bid_num	IN pon_bid_headers.bid_number%TYPE,
	p_tpid				IN pon_bid_headers.trading_partner_id%TYPE,
	p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE,
	p_userid			IN pon_bid_headers.created_by%TYPE,
	p_vensid			IN pon_bid_headers.vendor_site_id%TYPE,
	p_rebid_flag		IN VARCHAR2,
	p_restricted_flag	IN VARCHAR2,
	p_batch_start		IN pon_bid_item_prices.line_number%TYPE,
	p_batch_end		IN pon_bid_item_prices.line_number%TYPE,
        p_surrog_bid_flag       IN pon_bid_headers.surrog_bid_flag%TYPE
) IS
	l_auctpid			pon_auction_headers_all.trading_partner_id%TYPE;
	l_blanket			VARCHAR2(1);
	l_full_qty			VARCHAR2(1);
	l_enforce_prevrnd_price_flag  VARCHAR2(1);
	l_prev_rnd_active_bid_number  NUMBER;
	l_auction_header_id_prev_round NUMBER;
	l_unit_price NUMBER;
	l_quantity NUMBER;
        l_is_paused pon_auction_headers_all.is_paused%TYPE;
        l_last_pause_date pon_auction_headers_all.last_pause_date%TYPE;
        l_closed_compare_date DATE;
BEGIN

	log_message ('insert_into_bid_items', 'Entering procedure with params : '||
	        'p_auc_header_id = ' || p_auc_header_id ||
            ', p_bid_number = ' || p_bid_number ||
            ', p_source_bid_num = ' || p_source_bid_num ||
			', p_tpid = ' || p_tpid ||
			', p_tpcid = ' || p_tpcid ||
			', p_userid = ' || p_userid ||
			', p_vensid = ' || p_vensid ||
			', p_rebid_flag = ' || p_rebid_flag ||
			', p_restricted_flag = ' || p_restricted_flag ||
			', p_batch_start = ' || p_batch_start ||
			', p_batch_end = ' || p_batch_end ||
			', p_surrog_bid_flag = ' || p_surrog_bid_flag );

	SELECT ah.trading_partner_id,
		decode(ah.contract_type, 'BLANKET', 'Y', 'CONTRACT', 'Y', 'N'),
		decode(ah.full_quantity_bid_code, 'FULL_QTY_BIDS_REQD', 'Y', 'N'),
		enforce_prevrnd_bid_price_flag,
		auction_header_id_prev_round,
                is_paused,
                last_pause_date
	INTO l_auctpid,
		l_blanket,
		l_full_qty,
		l_enforce_prevrnd_price_flag,
		l_auction_header_id_prev_round,
                l_is_paused,
                l_last_pause_date
	FROM pon_auction_headers_all ah
	WHERE ah.auction_header_id = p_auc_header_id;

	log_message ('insert_into_bid_items',
	        'l_auctpid = ' || l_auctpid ||
            ', l_blanket = ' || l_blanket ||
            ', l_full_qty = ' || l_full_qty ||
			', l_enforce_prevrnd_price_flag = ' || l_enforce_prevrnd_price_flag ||
			', l_auction_header_id_prev_round = ' || l_auction_header_id_prev_round  ||
			', l_is_paused = ' || l_is_paused ||
			', l_last_pause_date = ' || l_last_pause_date );


	INSERT INTO pon_bid_item_prices
	(
		AUCTION_HEADER_ID,
		AUCTION_LINE_NUMBER,
		BID_NUMBER,
		LINE_NUMBER,
		ITEM_DESCRIPTION,
		CATEGORY_ID,
		CATEGORY_NAME,
		UOM,
		QUANTITY,
		PRICE,
		MINIMUM_BID_PRICE,
		PROMISED_DATE,
		NOTE_TO_AUCTION_OWNER,
		LANGUAGE_CODE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		AUCTION_CREATION_DATE,
		SHIP_TO_LOCATION_ID,
		PUBLISH_DATE,
		PROXY_BID_LIMIT_PRICE,
		PROXY_BID_LIMIT_PRICE_DATE,
		BID_CURRENCY_PRICE,
		BID_CURRENCY_LIMIT_PRICE,
		PROXY_BID_FLAG,
		FIRST_BID_PRICE,
		UNIT_OF_MEASURE,
		HAS_ATTRIBUTES_FLAG,
		FREIGHT_TERMS_CODE,
		TBD_PRICING_FLAG,
		AUC_TRADING_PARTNER_ID,
		BID_TRADING_PARTNER_ID,
		TOTAL_WEIGHTED_SCORE,
		RANK,
		PO_MIN_REL_AMOUNT,
		PO_BID_MIN_REL_AMOUNT,
		PRICE_BREAK_TYPE,
		HAS_SHIPMENTS_FLAG,
		IS_CHANGED_LINE_FLAG,
		HAS_PRICE_DIFFERENTIALS_FLAG,
		PRICE_DIFF_SHIPMENT_NUMBER,
		BID_CURRENCY_TRANS_PRICE,
		UNIT_PRICE,
		BID_CURRENCY_UNIT_PRICE,
		GROUP_AMOUNT,
		HAS_BID_PAYMENTS_FLAG,
		ADVANCE_AMOUNT,
		BID_CURR_ADVANCE_AMOUNT,
		RECOUPMENT_RATE_PERCENT,
		PROGRESS_PYMT_RATE_PERCENT,
		RETAINAGE_RATE_PERCENT,
		MAX_RETAINAGE_AMOUNT,
		BID_CURR_MAX_RETAINAGE_AMT,
		OLD_NO_OF_PAYMENTS,
		OLD_PRICE,
		OLD_BID_CURRENCY_UNIT_PRICE,
		OLD_BID_CURRENCY_PRICE,
		OLD_BID_CURRENCY_LIMIT_PRICE,
		OLD_PO_BID_MIN_REL_AMOUNT,
		OLD_QUANTITY,
		OLD_PUBLISH_DATE,
		OLD_PROMISED_DATE,
		OLD_NOTE_TO_AUCTION_OWNER,
		HAS_BID_FLAG,
		OLD_BID_CURR_ADVANCE_AMOUNT,
		OLD_RECOUPMENT_RATE_PERCENT,
		OLD_PROGRESS_PYMT_RATE_PERCENT,
		OLD_RETAINAGE_RATE_PERCENT,
		OLD_BID_CURR_MAX_RETAINAGE_AMT,
		COPY_PRICE_FOR_PROXY_FLAG,
		BID_START_PRICE,
                HAS_QUANTITY_TIERS
	)
	(SELECT
		al.auction_header_id,		-- AUCTION_HEADER_ID
		al.line_number,				-- AUCTION_LINE_NUMBER
		p_bid_number,				-- BID_NUMBER
		al.line_number,				-- LINE_NUMBER
		al.item_description,		-- ITEM_DESCRIPTION
		al.category_id,				-- CATEGORY_ID
		al.category_name,			-- CATEGORY_NAME
		al.uom_code,				-- UOM
		decode(al.modified_date-old_al.modified_date,
			0, bl.quantity, decode(l_blanket, 'Y', null,
				decode(l_full_qty, 'Y', al.quantity,
					decode(al.group_type, 'LOT_LINE', al.quantity,
						decode(al.order_type_lookup_code, 'AMOUNT',
						al.quantity, null))))), -- QUANTITY
		decode(al.modified_date-old_al.modified_date,
			0, bl.price, null), 	-- PRICE
		decode(al.modified_date-old_al.modified_date,
			0, bl.minimum_bid_price, null), -- MINIMUM_BID_PRICE
		decode(al.modified_date-old_al.modified_date,
			0, bl.promised_date, null), -- PROMISED_DATE
		decode(al.modified_date-old_al.modified_date,
			0, bl.note_to_auction_owner, null), -- NOTE_TO_AUCTION_OWNER
		userenv('LANG'),			-- LANGUAGE_CODE
		SYSDATE,					-- CREATION_DATE
		p_userid,					-- CREATED_BY
		SYSDATE,					-- LAST_UPDATE_DATE
		p_userid,					-- LAST_UPDATED_BY
		al.auction_creation_date,	-- AUCTION_CREATION_DATE
		al.ship_to_location_id,		-- SHIP_TO_LOCATION_ID
		decode(al.modified_date-old_al.modified_date,
			0, bl.publish_date, null), -- PUBLISH_DATE
		decode(al.modified_date-old_al.modified_date,
			0, bl.proxy_bid_limit_price, null), -- PROXY_BID_LIMIT_PRICE
		decode(al.modified_date-old_al.modified_date,
			0, bl.proxy_bid_limit_price_date, null), -- PROXY_BID_LIMIT_PRICE_DATE
		decode(al.modified_date-old_al.modified_date,
			0, bl.bid_currency_price, null), -- BID_CURRENCY_PRICE
		decode(al.modified_date-old_al.modified_date,
			0, bl.bid_currency_limit_price, null), -- BID_CURRENCY_LIMIT_PRICE
		'N',						-- PROXY_BID_FLAG
		decode(al.modified_date-old_al.modified_date,
			0, bl.first_bid_price, null), -- FIRST_BID_PRICE
		al.unit_of_measure,			-- UNIT_OF_MEASURE
		al.has_attributes_flag,		-- HAS_ATTRIBUTES_FLAG
		al.freight_terms_code,		-- FREIGHT_TERMS_CODE
		'N',						-- TBD_PRICING_FLAG
		l_auctpid,					-- AUC_TRADING_PARTNER_ID
		p_tpid,						-- BID_TRADING_PARTNER_ID
		decode(al.modified_date-old_al.modified_date,
			0, bl.total_weighted_score, null), -- TOTAL_WEIGHTED_SCORE
		decode(p_rebid_flag, 'Y', bl.rank, null), -- RANK
		decode(al.modified_date-old_al.modified_date,
			0, bl.po_min_rel_amount, null), -- PO_MIN_REL_AMOUNT
		decode(al.modified_date-old_al.modified_date,
			0, bl.po_bid_min_rel_amount, null),	-- PO_BID_MIN_REL_AMOUNT
		al.price_break_type,		-- PRICE_BREAK_TYPE
		decode(al.modified_date-old_al.modified_date,
			0, bl.has_shipments_flag, al.has_shipments_flag), -- HAS_SHIPMENTS_FLAG
		-- Rebid: set changed_line to N
		-- Otherwise it is the same as the has_bid_flag
		decode(p_rebid_flag, 'Y', 'N',
			decode(al.modified_date-old_al.modified_date, 0,
				nvl(bl.has_bid_flag, 'N'), 'N')), -- IS_CHANGED_LINE_FLAG
		al.has_price_differentials_flag,-- HAS_PRICE_DIFFERENTIALS_FLAG
		al.price_diff_shipment_number,	-- PRICE_DIFF_SHIPMENT_NUMBER *
		decode(al.modified_date-old_al.modified_date,
			0, bl.bid_currency_trans_price, null), -- BID_CURRENCY_TRANS_PRICE
		decode(al.modified_date-old_al.modified_date,
			0, bl.unit_price, null), -- UNIT_PRICE
		decode(al.modified_date-old_al.modified_date,
			0, bl.bid_currency_unit_price, null), -- BID_CURRENCY_UNIT_PRICE
		decode(al.modified_date-old_al.modified_date,
			0, bl.group_amount, null), -- GROUP_AMOUNT
		decode(g_copy_only_from_auc, 'Y', al.has_payments_flag,
		           decode(al.modified_date-old_al.modified_date,0,bl.has_bid_payments_flag,al.has_payments_flag
			         )
		       ),--HAS_BID_PAYMENTS_FLAG
		decode(al.modified_date-old_al.modified_date, 0,decode(g_advance_negotiable,'Y',bl.advance_amount,al.advance_amount
		                                                      )
							       , al.advance_amount
		      ),--ADVANCE_AMOUNT
		decode(al.modified_date-old_al.modified_date, 0,decode(g_advance_negotiable,'Y',bl.bid_curr_advance_amount
		                                                         ,round(al.advance_amount * g_bid_rate, g_curr_prec)
		                                                      )
							       , round(al.advance_amount * g_bid_rate, g_curr_prec)
		      ),--BID_CURR_ADVANCE_AMOUNT
		decode(al.modified_date-old_al.modified_date, 0,decode(g_recoupment_negotiable,'Y',bl.recoupment_rate_percent
		                                                                                  ,al.recoupment_rate_percent
								      )
							       , al.recoupment_rate_percent
		      ),--RECOUPMENT_RATE_PERCENT
		decode(al.modified_date-old_al.modified_date, 0,decode(g_prog_pymt_negotiable,'Y',bl.progress_pymt_rate_percent
		                                                                                 ,al.progress_pymt_rate_percent
								      )
							       , al.progress_pymt_rate_percent
		      ),--PROGRESS_PYMT_RATE_PERCENT
		decode(al.modified_date-old_al.modified_date, 0,decode(g_rtng_negotiable,'Y',bl.retainage_rate_percent,al.retainage_rate_percent
		                                                      )
							       , al.retainage_rate_percent
		      ),--RETAINAGE_RATE_PERCENT
		decode(al.modified_date-old_al.modified_date, 0,decode(g_max_rtng_negotiable,'Y',bl.max_retainage_amount,al.max_retainage_amount
		                                                      )
							       , al.max_retainage_amount
		      ),--MAX_RETAINAGE_AMOUNT
		decode(al.modified_date-old_al.modified_date, 0,decode(g_max_rtng_negotiable,'Y',bl.bid_curr_max_retainage_amt
		                                                        , round(al.max_retainage_amount * g_bid_rate, g_curr_prec)
		                                                      )
							       , round(al.max_retainage_amount * g_bid_rate, g_curr_prec)
		),--BID_CURR_MAX_RETAINAGE_AMT
	        decode(p_rebid_flag, 'Y', (select count(1) from pon_bid_payments_shipments
		                          where bid_number=bl.bid_number and bid_line_number=bl.line_number)
		                        ,null
		      ),	--OLD_NO_OF_PAYMENTS
		decode(p_rebid_flag, 'Y', bl.price, null), -- OLD_PRICE
		decode(p_rebid_flag, 'Y', bl.bid_currency_unit_price, null),-- OLD_BID_CURRENCY_UNIT_PRICE
		decode(p_rebid_flag, 'Y', bl.bid_currency_price, null), -- OLD_BID_CURRENCY_PRICE
		decode(p_rebid_flag, 'Y', bl.bid_currency_limit_price, null), -- OLD_BID_CURRENCY_LIMIT_PRICE
		decode(p_rebid_flag, 'Y', bl.po_bid_min_rel_amount, null), -- OLD_PO_BID_MIN_REL_AMOUNT
		decode(p_rebid_flag, 'Y', bl.quantity, null), -- OLD_QUANTITY
		decode(p_rebid_flag, 'Y', bl.publish_Date, null), -- OLD_PUBLISH_DATE
		decode(p_rebid_flag, 'Y', bl.promised_Date, null), -- OLD_PROMISED_DATE
		decode(p_rebid_flag, 'Y', bl.note_to_auction_owner, null), -- OLD_NOTE_TO_AUCTION_OWNER
		-- If the line was modified, set to N, else set to source has_bid_flag
		-- If the source has_bid_flag is null, set to N since there was no source bid
		decode(al.modified_date-old_al.modified_date, 0,
			nvl(bl.has_bid_flag, 'N'), 'N'), -- HAS_BID_FLAG
		decode(p_rebid_flag, 'Y', bl.bid_curr_advance_amount, null), -- OLD_BID_CURR_ADVANCE_AMOUNT
		decode(p_rebid_flag, 'Y', bl.recoupment_rate_percent, null), -- OLD_RECOUPMENT_RATE_PERCENT
		decode(p_rebid_flag, 'Y', bl.progress_pymt_rate_percent, null), -- OLD_PROGRESS_PYMT_RATE_PERCENT
		decode(p_rebid_flag, 'Y', bl.retainage_rate_percent, null), -- OLD_RETAINAGE_RATE_PERCENT
		decode(p_rebid_flag, 'Y', bl.bid_curr_max_retainage_amt, null), -- OLD_BID_CURR_MAX_RETAINAGE_AMT
		decode(p_rebid_flag, 'Y',
			decode(sign(bl.proxy_bid_limit_price-bl.price), -1, 'Y', 'N'), 'N'), 	 -- COPY_PRICE_FOR_PROXY_FLAG
		-- if re bid set the start price as source bid start price
        decode(p_rebid_flag, 'Y', nvl(bl.bid_start_price, al.bid_start_price), al.bid_start_price),
      		decode(al.modified_date-old_al.modified_date,
        		0, bl.has_quantity_tiers, al.has_quantity_tiers) -- HAS_quantity_tiers
	FROM pon_auction_item_prices_all al,
        pon_auction_item_prices_all old_al,
        pon_bid_item_prices bl
	WHERE al.auction_header_id = p_auc_header_id
		AND bl.bid_number(+) = p_source_bid_num
		AND bl.line_number(+) = al.line_number
		AND old_al.auction_header_id (+) = bl.auction_header_id
		AND old_al.line_number (+) = bl.line_number
		AND al.line_number BETWEEN p_batch_start AND p_batch_end);

   -- determine if there exists an active bid in the previous round
   -- for the supplier/contact/site
   -- this will be used to populate the bid_start_price column
 -- added condition for p_rebid_flag to ensure that for a new response only start price will get calculated
   IF (l_enforce_prevrnd_price_flag = 'Y' AND  p_rebid_flag <> 'Y') THEN
        BEGIN
            SELECT MAX(bid_number)
            INTO   l_prev_rnd_active_bid_number
            FROM   pon_bid_headers bh
            WHERE  bh.auction_header_id = l_auction_header_id_prev_round
            AND    bh.trading_partner_id = p_tpid
            AND    bh.trading_partner_contact_id = p_tpcid
            AND    bh.bid_status ='ACTIVE'
            AND    NVL(bh.vendor_site_id, -1) = NVL(p_vensid, -1);

			log_message ('insert_into_bid_items',
	        'l_prev_rnd_active_bid_number = ' || l_prev_rnd_active_bid_number );

            IF l_prev_rnd_active_bid_number IS NOT NULL THEN
            	-- if active bid exists then
            	-- update the bid_start_price for the current bid lines
            	-- using values from the previous round auction/bid

            --Changing this update statement for the bug 13631230.

            UPDATE     pon_bid_item_prices bl
            SET        bid_start_price = nvl((SELECT pon_bid_defaulting_pkg.apply_price_factors(p_auc_header_id, l_prev_rnd_active_bid_number, al.line_number, bl1.unit_price, bl1.quantity)
       	   		            FROM   pon_auction_item_prices_all al, pon_bid_item_prices bl1
             		            WHERE  al.auction_header_id = l_auction_header_id_prev_round
             		            AND    al.line_number = bl.line_number
               		            AND    al.line_number = bl1.line_number
             		            AND    bl1.bid_number = l_prev_rnd_active_bid_number), bid_start_price)
            WHERE      bl.bid_number = p_bid_number
            AND        bl.has_bid_flag = 'Y';

	        END IF;

		EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_enforce_prevrnd_price_flag := 'N';
        END;
	END IF;
   -- end 'start price for multi round negotiations' code

	-- Delete excluded lines
	IF (p_restricted_flag = 'Y') THEN

		DELETE FROM pon_bid_item_prices bl
		WHERE bl.bid_number = p_bid_number
			AND bl.line_number BETWEEN p_batch_start AND p_batch_end
			AND EXISTS
				(SELECT le.line_number
				FROM pon_party_line_exclusions le, pon_auction_item_prices_all al
				WHERE al.auction_header_id = p_auc_header_id
					AND al.line_number = bl.line_number
					AND le.auction_header_id = al.auction_header_id
					AND le.line_number = nvl(al.parent_line_number, al.line_number)
					AND le.trading_partner_id = p_tpid
					AND le.vendor_site_id = p_vensid);
	END IF;


        -- In case of a non-rebid and non surrogate bid do not copy over
        -- closed lines.
        log_message ('insert_into_bid_items', 'p_rebid_flag = ' || p_rebid_flag ||
                             ', p_surrog_bid_flag = ' || p_surrog_bid_flag ||
                             ', l_is_paused = ' || l_is_paused ||
                             ', l_closed_compare_date = ' || to_char (l_closed_compare_date, 'dd-mon-yyyy hh24:mi:ss') ||
                             ', l_last_pause_date = ' || to_char (l_last_pause_date, 'dd-mon-yyyy hh24:mi:ss'));

        IF ( nvl (p_rebid_flag, 'N') = 'N' AND nvl (p_surrog_bid_flag, 'N') = 'N') THEN

          log_message ('insert_into_bid_items', 'This is not a rebid and this is not a surrogate bid.');

          IF (nvl (l_is_paused, 'N') = 'Y') THEN
            l_closed_compare_date := l_last_pause_date;
          ELSE
            l_closed_compare_date := sysdate;
          END IF;

          DELETE FROM pon_bid_item_prices bl
          WHERE bl.bid_number = p_bid_number
          AND bl.line_number BETWEEN p_batch_start AND p_batch_end
          AND EXISTS (SELECT al.line_number
                      FROM pon_auction_item_prices_all al
                      WHERE al.auction_header_id = p_auc_header_id
                      AND al.line_number = bl.line_number
                      AND al.close_bidding_date < l_closed_compare_date);
        END IF;

END insert_into_bid_items;

-- ======================================================================
-- PROCEDURE:	INSERT_INTO_HEADER_ATTRIBUTES  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction_header_id of negotiation
--	p_bid_number		IN bid number to insert attributes for
--	p_source_bid_num	IN source_bid to default from
--	p_userid			IN userid of bid creator
--	p_evaluator_id		IN evaluator user id
--	p_eval_flag		IN flag indicating if the response is an evaluation
--	p_rebid_flag		IN flag indicating rebid or not
--
--  COMMENT: inserts header attributes for the new bid, defualting as necessary
-- ======================================================================
PROCEDURE insert_into_header_attributes
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_source_bid_num	IN pon_bid_headers.bid_number%TYPE,
	p_userid			IN pon_bid_headers.created_by%TYPE,
	----------- Supplier Management: Supplier Evaluation -----------
	p_evaluator_id		IN pon_bid_headers.evaluator_id%TYPE,
	p_eval_flag		IN pon_bid_headers.evaluation_flag%TYPE,
	----------------------------------------------------------------
	p_rebid_flag		IN VARCHAR2
) IS

l_has_scoring_teams_flag     pon_auction_headers_all.has_scoring_teams_flag%TYPE;

BEGIN

-- Bug 5046909 - Determine if team scoring is enabled
-- If team scoring is enabled, we do not copy the score over from the
-- earlier bid. If team scoring is not enabled, we copy the score over
-- for a header attribute only if the attribute has not been modified.
-- In both cases, scores by individual scorers are not copied over -
-- only the final one is
-- Adding this SELECT from auction_headers_all - ideally, this should
-- be combined and only one call made for the entire flow...will log a
-- tracking bug for this


 SELECT has_scoring_teams_flag
   INTO l_has_scoring_teams_flag
   FROM pon_auction_headers_all
  WHERE auction_header_id = p_auc_header_id;
 --Bugs 17607623,17864969 fix
 --scores cannot be copied only in the case of manual requirement when team scoring is enabled.
 --for automatic requirements scores needs to be copied in all cases
	-- Insert header attributes
	INSERT INTO pon_bid_attribute_values
	(
		AUCTION_HEADER_ID,
		AUCTION_LINE_NUMBER,
		BID_NUMBER,
		LINE_NUMBER,
		ATTRIBUTE_NAME,
		DATATYPE,
		VALUE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		SCORE,
		SEQUENCE_NUMBER,
		ATTR_LEVEL,
		WEIGHTED_SCORE,
		ATTR_GROUP_SEQ_NUMBER,
		ATTR_DISP_SEQ_NUMBER,
		OLD_VALUE
	)
	(SELECT
		aa.auction_header_id,		-- AUCTION_HEADER_ID
		aa.line_number,				-- AUCTION_LINE_NUMBER
		p_bid_number,				-- BID_NUMBER
		aa.line_number,				-- LINE_NUMBER
		aa.attribute_name,			-- ATTRIBUTE_NAME
		aa.datatype,				-- DATATYPE
		decode(aa.modified_date-old_aa.modified_date,
			0, ba.value, null), -- VALUE
		sysdate,					-- CREATION_DATE
		p_userid,					-- CREATED_BY
		sysdate,					-- LAST_UPDATE_DATE
		p_userid,					-- LAST_UPDATED_BY
		decode(aa.scoring_method,'MANUAL',decode('Y', 'N', decode(aa.modified_date-old_aa.modified_date,
			0, ba.score, null), 'Y', NULL),
      decode(aa.modified_date-old_aa.modified_date,0, ba.score, null)), -- SCORE
		aa.sequence_number,			-- SEQUENCE_NUMBER
		aa.attr_level,				-- ATTR_LEVEL
		decode(aa.scoring_method,'MANUAL',decode('Y', 'N', decode(aa.modified_date-old_aa.modified_date,
			0, ba.weighted_score, null), 'Y', NULL),
      decode(aa.modified_date-old_aa.modified_date,0, ba.weighted_score, null)),	-- WEIGHTED_SCORE
		aa.attr_group_seq_number,	-- ATTR_GROUP_SEQ_NUMBER
		aa.attr_disp_seq_number,	-- ATTR_DISP_SEQ_NUMBER
		decode(p_rebid_flag, 'Y', ba.value, null) -- OLD_VALUE
	FROM pon_auction_attributes aa,
		pon_bid_attribute_values ba,
		pon_auction_attributes old_aa
	WHERE aa.auction_header_id = p_auc_header_id
		AND aa.line_number= -1
		AND ba.bid_number (+) = p_source_bid_num
		AND ba.line_number (+) = aa.line_number
		AND ba.sequence_number (+) = aa.sequence_number
		AND ba.auction_header_id = old_aa.auction_header_id (+)
		AND ba.line_number = old_aa.line_number (+)
		AND ba.sequence_number = old_aa.sequence_number (+));

	-- Begin Supplier Management: Bug 12369949
	-- For evaluation response, need to clear value and score for sections
	-- not currently assigned to the evaluator
	IF (p_eval_flag = 'Y') THEN
		UPDATE pon_bid_attribute_values
		SET value = NULL,
		    score = NULL,
		    weighted_score = NULL
		WHERE auction_header_id = p_auc_header_id
		  AND line_number = -1
		  AND bid_number = p_bid_number
		  AND attr_group_seq_number NOT IN
		      (SELECT pas.attr_group_seq_number
		       FROM pon_auction_sections pas,
		            pon_evaluation_team_sections pets,
		            pon_evaluation_team_members petm,
		            fnd_user fu
		       WHERE pas.auction_header_id = p_auc_header_id
		         AND pets.auction_header_id = p_auc_header_id
		         AND petm.auction_header_id = p_auc_header_id
		         AND pas.section_id = pets.section_id
		         AND pets.team_id = petm.team_id
		         AND petm.user_id = fu.user_id
		         AND fu.person_party_id = p_evaluator_id
		      );
	END IF;
	-- End Supplier Management: Bug 12369949

END insert_into_header_attributes;

-- ======================================================================
-- PROCEDURE:	INSERT_INTO_LINE_ATTRIBUTES  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction_header_id of negotiation
--	p_bid_number		IN bid number to insert attributes for
--	p_source_bid_num	IN source_bid to default from
--	p_userid			IN userid of bid creator
--	p_rebid_flag		IN flag indicating rebid or not
--
--  COMMENT: inserts line attributes for the new bid, defualting as necessary
-- ======================================================================
PROCEDURE insert_into_line_attributes
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_source_bid_num	IN pon_bid_headers.bid_number%TYPE,
	p_userid			IN pon_bid_headers.created_by%TYPE,
	p_rebid_flag		IN VARCHAR2,
	p_batch_start		IN pon_bid_item_prices.line_number%TYPE,
	p_batch_end			IN pon_bid_item_prices.line_number%TYPE
) IS
BEGIN

	-- Insert line attributes
	INSERT INTO pon_bid_attribute_values
	(
		AUCTION_HEADER_ID,
		AUCTION_LINE_NUMBER,
		BID_NUMBER,
		LINE_NUMBER,
		ATTRIBUTE_NAME,
		DATATYPE,
		VALUE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		SCORE,
		SEQUENCE_NUMBER,
		ATTR_LEVEL,
		WEIGHTED_SCORE,
		ATTR_GROUP_SEQ_NUMBER,
		ATTR_DISP_SEQ_NUMBER,
		OLD_VALUE
	)
	-- NOTE: we check the has_bid_flag because it is 'N' if
	-- the line has been modified since the defaulting happened
	(SELECT
		aa.auction_header_id,		-- AUCTION_HEADER_ID
		aa.line_number,				-- AUCTION_LINE_NUMBER
		p_bid_number,				-- BID_NUMBER
		aa.line_number,				-- LINE_NUMBER
		aa.attribute_name,			-- ATTRIBUTE_NAME
		aa.datatype,				-- DATATYPE
		decode(bl.has_bid_flag, 'Y', ba.value, null), -- VALUE
		sysdate,					-- CREATION_DATE
		p_userid,					-- CREATED_BY
		sysdate,					-- LAST_UPDATE_DATE
		p_userid,					-- LAST_UPDATED_BY
		decode(bl.has_bid_flag, 'Y', ba.score, null), -- SCORE
		aa.sequence_number,			-- SEQUENCE_NUMBER
		aa.attr_level,				-- ATTR_LEVEL
		decode(bl.has_bid_flag, 'Y', ba.weighted_score, null), -- WEIGHTED_SCORE
		aa.attr_group_seq_number,	-- ATTR_GROUP_SEQ_NUMBER
		aa.attr_disp_seq_number,	-- ATTR_DISP_SEQ_NUMBER
		decode(p_rebid_flag, 'Y', ba.value, null) -- OLD_VALUE
	FROM pon_auction_attributes aa,
		pon_bid_attribute_values ba,
		pon_bid_item_prices bl
	WHERE aa.auction_header_id = p_auc_header_id
		AND aa.line_number > 0
		AND bl.bid_number = p_bid_number
		AND bl.line_number = aa.line_number
		AND ba.bid_number (+) = p_source_bid_num
		AND ba.line_number (+) = aa.line_number
		AND ba.sequence_number (+) = aa.sequence_number
		AND bl.line_number BETWEEN p_batch_start AND p_batch_end);

END insert_into_line_attributes;

-- ======================================================================
-- PROCEDURE:	INSERT_INTO_PRICE_FACTORS  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction_header_id of negotiation
--	p_bid_number		IN bid number to insert price factors for
--	p_source_bid_num	IN source_bid to default from
--	p_userid			IN userid of bid creator
--	p_supp_seq_number	IN sequence number if supplier was invited
--	p_rebid_flag		IN flag indicating rebid or not
--
--  COMMENT: insert price factors for the new bid, defualting as necessary
-- ======================================================================
PROCEDURE insert_into_price_factors
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_source_bid_num	IN pon_bid_headers.bid_number%TYPE,
	p_userid			IN pon_bid_headers.created_by%TYPE,
	p_supp_seq_number	IN pon_pf_supplier_values.supplier_seq_number%TYPE,
	p_rebid_flag		IN VARCHAR2,
	p_batch_start		IN pon_bid_item_prices.line_number%TYPE,
	p_batch_end			IN pon_bid_item_prices.line_number%TYPE
) IS
	l_price_prec		pon_bid_headers.number_price_decimals%TYPE;
	l_curr_prec			fnd_currencies.precision%TYPE;
	l_rate				pon_bid_headers.rate%TYPE;
	l_supplier_view		pon_auction_headers_all.supplier_view_type%TYPE;
	l_pf_type			pon_auction_headers_all.pf_type_allowed%TYPE;
BEGIN

	-- Get bid currency precisions and rate
	SELECT bh.number_price_decimals,
		cu.precision,
		bh.rate
	INTO l_price_prec,
		l_curr_prec,
		l_rate
	FROM pon_bid_headers bh,
		fnd_currencies cu
	WHERE bh.bid_number = p_bid_number
		AND cu.currency_code = bh.bid_currency_code;

	-- Get the price factor type info
	SELECT ah.supplier_view_type, ah.pf_type_allowed
	INTO l_supplier_view, l_pf_type
	FROM pon_auction_headers_all ah
	WHERE ah.auction_header_id = p_auc_header_id;

	-- copy over all supplier price factors, including line price
	-- do not copy line price pf for lines with display_price_factors_flag = N
	IF (l_supplier_view <> 'UNTRANSFORMED') THEN

		INSERT INTO pon_bid_price_elements
		(
			BID_NUMBER,
			LINE_NUMBER,
			PRICE_ELEMENT_TYPE_ID,
			AUCTION_HEADER_ID,
			PRICING_BASIS,
			AUCTION_CURRENCY_VALUE,
			BID_CURRENCY_VALUE,
			SEQUENCE_NUMBER,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			PF_TYPE,
			OLD_BID_CURRENCY_VALUE
		)
		(SELECT
			p_bid_number,				-- BID_NUMBER
			apf.line_number,			-- LINE_NUMBER
			apf.price_element_type_id,	-- PRICE_ELEMENT_TYPE_ID
			p_auc_header_id,			-- AUCTION_HEADER_ID
			apf.pricing_basis,			-- PRICING_BASIS
			decode(bl.has_bid_flag, 'Y',
				bpf.auction_currency_value, null), -- AUCTION_CURRENCY_VALUE
			decode(bl.has_bid_flag, 'Y',
				bpf.bid_currency_value, null), -- BID_CURRENCY_VALUE
			apf.sequence_number,		-- SEQUENCE_NUMBER
			sysdate,					-- CREATION_DATE
			p_userid,					-- CREATED_BY
			sysdate,					-- LAST_UPDATE_DATE
			p_userid,					-- LAST_UPDATED_BY
			apf.pf_type,				-- PF_TYPE
			decode(p_rebid_flag, 'Y', bpf.bid_currency_value, null) -- OLD_BID_CURRENCY_VALUE
		FROM pon_price_elements apf,
			pon_bid_price_elements bpf,
			pon_bid_item_prices bl
		WHERE apf.auction_header_id = p_auc_header_id
			AND apf.pf_type = 'SUPPLIER'			-- only for supplier price factors
			AND bl.bid_number = p_bid_number
			AND bl.line_number = apf.line_number
			AND bl.display_price_factors_flag = 'Y' -- only for lines with price factors
			AND bpf.bid_number (+) = p_source_bid_num
			AND bpf.line_number (+) = apf.line_number
			AND bpf.price_element_type_id (+) = apf.price_element_type_id
			AND bl.line_number BETWEEN p_batch_start AND p_batch_end);
	END IF;

	-- copy over all buyer price factors that can be displayed to the supplier
	-- display flag checked and have nonzero value
	-- need to populate bid_currency_value, rounding as necessary
	IF (p_supp_seq_number IS NOT null AND l_pf_type <> 'SUPPLIER') THEN

		INSERT INTO pon_bid_price_elements
		(
			BID_NUMBER,
			LINE_NUMBER,
			PRICE_ELEMENT_TYPE_ID,
			AUCTION_HEADER_ID,
			PRICING_BASIS,
			AUCTION_CURRENCY_VALUE,
			BID_CURRENCY_VALUE,
			SEQUENCE_NUMBER,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			PF_TYPE,
			OLD_BID_CURRENCY_VALUE
		)
		(SELECT
			p_bid_number,				-- BID_NUMBER
			apf.line_number,			-- LINE_NUMBER
			apf.price_element_type_id,	-- PRICE_ELEMENT_TYPE_ID
			p_auc_header_id,			-- AUCTION_HEADER_ID
			apf.pricing_basis,			-- PRICING_BASIS
			pf.value,					-- AUCTION_CURRENCY_VALUE
			decode(apf.pricing_basis,
				'PER_UNIT', round(pf.value * l_rate, l_price_prec),
				'FIXED_AMOUNT', round(pf.value * l_rate, l_curr_prec),
				'PERCENTAGE', pf.value), -- BID_CURRENCY_VALUE
			apf.sequence_number,		-- SEQUENCE_NUMBER
			sysdate,					-- CREATION_DATE
			p_userid,					-- CREATED_BY
			sysdate,					-- LAST_UPDATE_DATE
			p_userid,					-- LAST_UPDATED_BY
			apf.pf_type,				-- PF_TYPE
			null						-- OLD_BID_CURRENCY_VALUE
		FROM pon_price_elements apf,
			pon_pf_supplier_values pf,
			pon_bid_item_prices bl
		WHERE apf.auction_header_id = p_auc_header_id
			AND apf.pf_type = 'BUYER'			-- only buyer pf that are to be displayed
			AND apf.display_to_suppliers_flag = 'Y'
			AND bl.bid_number = p_bid_number
			AND bl.line_number = apf.line_number
			AND bl.display_price_factors_flag = 'Y'
			AND pf.auction_header_id = apf.auction_header_id
			AND pf.line_number = apf.line_number
			AND pf.pf_seq_number = apf.sequence_number
			AND pf.supplier_seq_number = p_supp_seq_number
			AND nvl(pf.value, 0) <> 0
			AND bl.line_number BETWEEN p_batch_start AND p_batch_end);
	END IF;

END	insert_into_price_factors;

-- ======================================================================
-- PROCEDURE:	INSERT_INTO_PRICE_TIERS  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction_header_id of negotiation
--	p_bid_number		IN bid number to insert price breaks for
--	p_source_bid_num	IN source_bid to default from
--	p_userid			IN userid of bid creator
--	p_rebid_flag		IN flag indicating rebid or not
--
--  COMMENT: inserts price tiers for the new bid, defualting as necessary
-- ======================================================================
PROCEDURE insert_into_price_tiers
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_source_bid_num	IN pon_bid_headers.bid_number%TYPE,
	p_userid			IN pon_bid_headers.created_by%TYPE,
	p_rebid_flag		IN VARCHAR2,
	p_batch_start		IN pon_bid_item_prices.line_number%TYPE,
	p_batch_end			IN pon_bid_item_prices.line_number%TYPE
) IS
BEGIN

	-- Get all auction side price breaks for modified lines that had a bid
	-- or for unmodified lines that had no bid
	INSERT INTO pon_bid_shipments
	(
		BID_NUMBER,
		LINE_NUMBER,
		SHIPMENT_NUMBER,
		AUCTION_HEADER_ID,
		AUCTION_LINE_NUMBER,
		AUCTION_SHIPMENT_NUMBER,
		SHIPMENT_TYPE,
		SHIP_TO_ORGANIZATION_ID,
		SHIP_TO_LOCATION_ID,
		QUANTITY,
		MAX_QUANTITY,
		PRICE_TYPE,
		PRICE,
		BID_CURRENCY_PRICE,
		PRICE_DISCOUNT,
		EFFECTIVE_START_DATE,
		EFFECTIVE_END_DATE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		HAS_PRICE_DIFFERENTIALS_FLAG,
		UNIT_PRICE,
		BID_CURRENCY_UNIT_PRICE
	)
	(SELECT
		p_bid_number,				-- BID_NUMBER
		apb.line_number,			-- LINE_NUMBER
		apb.shipment_number+1,		-- SHIPMENT_NUMBER
		p_auc_header_id,			-- AUCTION_HEADER_ID
		apb.line_number,			-- AUCTION_LINE_NUMBER
                apb.shipment_number, -- AUCTION_SHIPMENT_NUMBER
		apb.shipment_type, -- SHIPMENT_TYPE
		apb.ship_to_organization_id, -- SHIP_TO_ORGANIZATION_ID
		apb.ship_to_location_id, -- SHIP_TO_LOCATION_ID
		apb.quantity, -- QUANTITY
                apb.max_quantity,  --- MAX_QUANTITY
		'PRICE', -- PRICE_TYPE
		apb.price, 	-- PRICE
		null,		-- BID_CURRENCY_PRICE
		null,			-- PRICE_DISCOUNT
		apb.effective_start_date, -- EFFECTIVE_START_DATE
		apb.effective_end_date, -- EFFECTIVE_END_DATE
		sysdate,					-- CREATION_DATE
		p_userid,					-- CREATED_BY
		sysdate,					-- LAST_UPDATE_DATE
		p_userid,					-- LAST_UPDATED_BY
		null,						-- LAST_UPDATE_LOGIN
		apb.has_price_differentials_flag, -- HAS_PRICE_DIFFERENTIALS_FLAG
		null,				-- UNIT_PRICE
		null                           -- BID_CURRENCY_UNIT_PRICE
	FROM pon_auction_shipments_all apb,
		pon_bid_item_prices bl
	WHERE apb.auction_header_id = p_auc_header_id
		AND bl.bid_number = p_bid_number
		AND bl.line_number = apb.line_number
		-- we only insert those price breaks for which the line was modified
		-- or had no previosu bid on it - has_bid_flag = N in both cases
		AND bl.has_bid_flag = 'N'
		AND bl.line_number BETWEEN p_batch_start AND p_batch_end);

	-- Get only-bid-side price breaks for unmodified lines
	INSERT INTO pon_bid_shipments
	(
		BID_NUMBER,
		LINE_NUMBER,
		SHIPMENT_NUMBER,
		AUCTION_HEADER_ID,
		AUCTION_LINE_NUMBER,
		AUCTION_SHIPMENT_NUMBER,
		SHIPMENT_TYPE,
		SHIP_TO_ORGANIZATION_ID,
		SHIP_TO_LOCATION_ID,
		QUANTITY,
                MAX_QUANTITY,
		PRICE_TYPE,
		PRICE,
		BID_CURRENCY_PRICE,
		PRICE_DISCOUNT,
		EFFECTIVE_START_DATE,
		EFFECTIVE_END_DATE,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		HAS_PRICE_DIFFERENTIALS_FLAG,
		UNIT_PRICE,
		BID_CURRENCY_UNIT_PRICE,
 		OLD_BID_CURRENCY_UNIT_PRICE,
		OLD_BID_CURRENCY_PRICE,
		OLD_PRICE_DISCOUNT,
		OLD_SHIP_TO_ORG_ID,
		OLD_SHIP_TO_LOC_ID,
		OLD_EFFECTIVE_START_DATE,
		OLD_EFFECTIVE_END_DATE,
		OLD_QUANTITY,
                OLD_MAX_QUANTITY,
		OLD_PRICE_TYPE
	)
	(SELECT
		p_bid_number,				-- BID_NUMBER
		bpb.line_number,			-- LINE_NUMBER
		bpb.shipment_number,		-- SHIPMENT_NUMBER
		p_auc_header_id,			-- AUCTION_HEADER_ID
		bpb.line_number,			-- AUCTION_LINE_NUMBER
		bpb.auction_shipment_number,-- AUCTION_SHIPMENT_NUMBER
		bpb.shipment_type,			-- SHIPMENT_TYPE
		bpb.ship_to_organization_id,-- SHIP_TO_ORGANIZATION_ID
		bpb.ship_to_location_id,	-- SHIP_TO_LOCATION_ID
		bpb.quantity,				-- QUANTITY
                bpb.max_quantity,           -- MAX_QUANTITY
		bpb.price_type,				-- PRICE_TYPE
		bpb.price,					-- PRICE
		bpb.bid_currency_price,		-- BID_CURRENCY_PRICE
		bpb.price_discount,			-- PRICE_DISCOUNT
		bpb.effective_start_date,	-- EFFECTIVE_START_DATE
		bpb.effective_end_date,		-- EFFECTIVE_END_DATE
		sysdate,					-- CREATION_DATE
		p_userid,					-- CREATED_BY
		sysdate,					-- LAST_UPDATE_DATE
		p_userid,					-- LAST_UPDATED_BY
		null,						-- LAST_UPDATE_LOGIN
		bpb.has_price_differentials_flag, -- HAS_PRICE_DIFFERENTIALS_FLAG
		bpb.unit_price,				-- UNIT_PRICE
		bpb.bid_currency_unit_price,-- BID_CURRENCY_UNIT_PRICE
 		decode(p_rebid_flag, 'Y', bpb.bid_currency_unit_price, null), -- OLD_BID_CURRENCY_UNIT_PRICE
		decode(p_rebid_flag, 'Y', bpb.bid_currency_price, null), -- OLD_BID_CURRENCY_PRICE
		decode(p_rebid_flag, 'Y', bpb.price_discount, null), -- OLD_PRICE_DISCOUNT
		decode(p_rebid_flag, 'Y', bpb.ship_to_organization_id, null), -- OLD_SHIP_TO_ORG_ID
		decode(p_rebid_flag, 'Y', bpb.ship_to_location_id, null), -- OLD_SHIP_TO_LOC_ID
		decode(p_rebid_flag, 'Y', bpb.effective_start_date, null), -- OLD_EFFECTIVE_START_DATE
		decode(p_rebid_flag, 'Y', bpb.effective_end_date, null), -- OLD_EFFECTIVE_END_DATE
		decode(p_rebid_flag, 'Y', bpb.quantity, null), -- OLD_QUANTITY
                decode(p_rebid_flag, 'Y', bpb.max_quantity, null), -- OLD_MAX_QUANTITY
		decode(p_rebid_flag, 'Y', bpb.price_type, null) -- OLD_PRICE_TYPE
	FROM pon_bid_shipments bpb,
		pon_bid_item_prices bl
	WHERE bpb.bid_number = p_source_bid_num
		AND bl.bid_number = p_bid_number
		AND bl.line_number = bpb.line_number
		-- only unmodified lines with bids
		AND bl.has_bid_flag = 'Y'
		AND bl.line_number BETWEEN p_batch_start AND p_batch_end);

END insert_into_price_tiers;

-- ======================================================================
-- PROCEDURE:	INSERT_INTO_PRICE_DIFF  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction_header_id of negotiation
--	p_bid_number		IN bid number to insert price differentials for
--	p_source_bid_num	IN source_bid to default from
--	p_userid			IN userid of bid creator
--	p_rebid_flag		IN flag indicating rebid or not
--
--  COMMENT: inserts price differentials for the new bid, defualting as necessary
-- ======================================================================
PROCEDURE insert_into_price_diff
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_source_bid_num	IN pon_bid_headers.bid_number%TYPE,
	p_userid			IN pon_bid_headers.created_by%TYPE,
	p_rebid_flag		IN VARCHAR2,
	p_batch_start		IN pon_bid_item_prices.line_number%TYPE,
	p_batch_end			IN pon_bid_item_prices.line_number%TYPE
) IS
BEGIN

	INSERT INTO pon_bid_price_differentials
	(
		AUCTION_HEADER_ID,
		BID_NUMBER,
		LINE_NUMBER,
		SHIPMENT_NUMBER,
		PRICE_DIFFERENTIAL_NUMBER,
		PRICE_TYPE,
		MULTIPLIER,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		OLD_MULTIPLIER
	)
	(
	-- Insert all line level price differentials
	(SELECT
		p_auc_header_id,			-- AUCTION_HEADER_ID
		p_bid_number,				-- BID_NUMBER
		apd.line_number,			-- LINE_NUMBER
		apd.shipment_number,		-- SHIPMENT_NUMBER
		apd.price_differential_number, -- PRICE_DIFFERENTIAL_NUMBER
		apd.price_type,				-- PRICE_TYPE
		decode(bl.has_bid_flag, 'Y', bpd.multiplier, null), -- MULTIPLIER
		sysdate,					-- CREATION_DATE
		p_userid,					-- CREATED_BY
		sysdate,					-- LAST_UPDATE_DATE
		p_userid,					-- LAST_UPDATED_BY
		null,						-- LAST_UPDATE_LOGIN
		decode(p_rebid_flag, 'Y', bpd.multiplier, null) -- OLD_MULTIPLIER
	FROM pon_price_differentials apd,
		pon_bid_price_differentials bpd,
		pon_bid_item_prices bl
	WHERE apd.auction_header_id = p_auc_header_id
		AND apd.shipment_number = -1				-- only line level differentials
		AND bl.auction_header_id = apd.auction_header_id
                AND bl.bid_number = p_bid_number
		AND bl.line_number = apd.line_number
		AND bpd.bid_number (+) = p_source_bid_num
		AND bpd.line_number (+) = apd.line_number
		AND bpd.shipment_number (+) = apd.shipment_number
		AND bpd.price_differential_number (+) = apd.price_differential_number
		AND bl.line_number BETWEEN p_batch_start AND p_batch_end)

	UNION

	-- Insert shipment level price differentials, but only for
	-- those shipments that got copied over
	(SELECT
		p_auc_header_id,			-- AUCTION_HEADER_ID
		p_bid_number,				-- BID_NUMBER
		apd.line_number,			-- LINE_NUMBER
		apd.shipment_number+1,		-- SHIPMENT_NUMBER
		apd.price_differential_number, -- PRICE_DIFFERENTIAL_NUMBER
		apd.price_type,				-- PRICE_TYPE
		decode(bl.has_bid_flag, 'Y', bpd.multiplier, null), -- MULTIPLIER
		sysdate,					-- CREATION_DATE
		p_userid,					-- CREATED_BY
		sysdate,					-- LAST_UPDATE_DATE
		p_userid,					-- LAST_UPDATED_BY
		null,						-- LAST_UPDATE_LOGIN
		decode(p_rebid_flag, 'Y', bpd.multiplier, null) -- OLD_MULTIPLIER
	FROM pon_price_differentials apd,
		pon_bid_price_differentials bpd,
		pon_bid_shipments bpb,
		pon_bid_item_prices bl
	WHERE apd.auction_header_id = p_auc_header_id
		AND apd.shipment_number <> -1			-- only shipment differentials
		AND bl.bid_number = p_bid_number
		AND bl.line_number = apd.line_number
		AND bpb.bid_number = p_bid_number
		AND bpb.line_number = apd.line_number
                AND bpb.shipment_type = 'PRICE BREAK'
		AND bpb.shipment_number = apd.shipment_number + 1
		AND bpd.bid_number (+) = p_source_bid_num
		AND bpd.line_number (+) = apd.line_number
		AND bpd.shipment_number (+) = apd.shipment_number + 1
		AND bpd.price_differential_number (+) = apd.price_differential_number
		AND bl.line_number BETWEEN p_batch_start AND p_batch_end)
	);

END insert_into_price_diff;

-- ======================================================================
-- PROCEDURE:	insert_into_payments  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction_header_id of negotiation
--	p_bid_number		IN bid number to insert price factors for
--	p_source_bid_num	IN source_bid to default from
--      p_copy_only_from_auc,   IN copy all the payments from negotiation only
--      p_supplier_flag,        IN Flag indication if supplier allowed to enter payments
--	p_userid		IN userid of bid creator
--	p_rebid_flag		IN flag indicating rebid or not
--  p_new_round_or_amended IN flag indicating if defaulting result of amend or new round
--  COMMENT: insert payments for the new bid, defualting as necessary
-- ======================================================================
-- Create and default payments
PROCEDURE insert_into_payments
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_source_bid_num	IN pon_bid_headers.bid_number%TYPE,
	p_copy_only_from_auc	IN VARCHAR2,
    p_supplier_flag         IN pon_auction_headers_all.SUPPLIER_ENTERABLE_PYMT_FLAG%TYPE,
	p_userid		IN pon_bid_headers.created_by%TYPE,
	p_rebid_flag		IN VARCHAR2,
    p_new_round_or_amended  IN VARCHAR2,
	p_batch_start		IN pon_bid_item_prices.line_number%TYPE,
	p_batch_end			IN pon_bid_item_prices.line_number%TYPE
) IS



  CURSOR c_bid_pymnts_attach IS
    SELECT
      DISTINCT
      source_pay.bid_number source_bid_number,
      source_pay.bid_line_number source_bid_line_number,
      source_pay.bid_payment_id source_bid_payment_id,
      dest_pay.bid_number dest_bid_number,
      dest_pay.bid_line_number dest_bid_line_number,
      dest_pay.bid_payment_id dest_bid_payment_id
    FROM
      PON_BID_PAYMENTS_SHIPMENTS source_pay,
      FND_ATTACHED_DOCUMENTS fnd,
      PON_BID_PAYMENTS_SHIPMENTS dest_pay,
      PON_BID_ITEM_PRICES bl
      WHERE   bl.auction_header_id = p_auc_header_id
          AND bl.bid_number = p_bid_number
	  AND bl.has_bid_flag = 'Y'
          AND dest_pay.bid_number = bl.bid_number
          AND dest_pay.bid_line_number = bl.line_number
          AND source_pay.bid_number = p_source_bid_num
          AND dest_pay.bid_line_number = source_pay.bid_line_number
          AND dest_pay.payment_display_number = source_pay.payment_display_number
	  AND fnd.pk1_value = source_pay.bid_number
	  AND fnd.pk2_value = source_pay.bid_line_number
	  AND fnd.pk3_value = source_pay.bid_payment_id
          AND fnd.entity_name = 'PON_BID_PAYMENTS_SHIPMENTS'
  	  AND bl.line_number BETWEEN p_batch_start AND p_batch_end;

     l_module  CONSTANT VARCHAR2(35) := 'Insert_into_payments';
BEGIN
     IF (g_debug_mode = 'Y') THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                                   module    => g_module_prefix || l_module,
                                   message   => 'entering insert_into_payments' );
                       END IF;
      END IF;
      IF (p_copy_only_from_auc = 'Y') THEN
        IF (g_debug_mode = 'Y') THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                                   module    => g_module_prefix || l_module,
                                   message   => 'In if p_copy_only_from_auc is Y' );
                       END IF;
      END IF;
     --copy all the payments from auction payments only as supplier_enterable flag toggled from Y in prev version to N in new round or amend
        INSERT INTO pon_bid_payments_shipments
		(
	        BID_NUMBER,
	        BID_LINE_NUMBER,
	        BID_PAYMENT_ID,
	        AUCTION_HEADER_ID,
	        AUCTION_LINE_NUMBER,
	        CREATION_DATE,
	        CREATED_BY,
        	LAST_UPDATE_DATE,
        	LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
        	PAYMENT_DISPLAY_NUMBER,
           	PAYMENT_DESCRIPTION,
              	AUCTION_PAYMENT_ID,
               	PAYMENT_TYPE_CODE,
                QUANTITY,
                UOM_CODE,
                PROMISED_DATE
		)
		(SELECT
                 p_bid_number,	                        --BID_NUMBER,
                 bl.line_number,		                --BID_LINE_NUMBER,
                 pon_bid_payments_shipments_s1.nextval,	--BID_PAYMENT_ID,
                 p_auc_header_id,                            --AUCTION_HEADER_ID,
                 bl.line_number,	                        --AUCTION_LINE_NUMBER,
                 sysdate,		                        --CREATION_DATE,
                 p_userid,	                                --CREATED_BY,
                 sysdate, 	                                --LAST_UPDATE_DATE,
                 p_userid, 	                                --LAST_UPDATED_BY,
		 fnd_global.login_id,                        --LAST_UPDATE_LOGIN
                 apmt.PAYMENT_DISPLAY_NUMBER,                --PAYMENT_DISPLAY_NUMBER,
                 apmt.PAYMENT_DESCRIPTION,                   --PAYMENT_DESCRIPTION,
                 apmt.PAYMENT_ID,    --AUCTION_PAYMENT_ID,
                 apmt.PAYMENT_TYPE_CODE,    --PAYMENT_TYPE_CODE,
                 apmt.QUANTITY,    --QUANTITY,
                 apmt.UOM_CODE,    --UOM_CODE,
                 bl.promised_date   --PROMISED_DATE,
                 FROM    pon_bid_item_prices bl,pon_auc_payments_shipments apmt
                 WHERE   bl.auction_header_id = p_auc_header_id
                 AND bl.bid_number = p_bid_number
                 AND bl.auction_header_id = apmt.auction_header_id
                 AND bl.line_number = apmt.line_number
                 AND bl.line_number BETWEEN p_batch_start AND p_batch_end);


      ELSE  --the following should execute if rebid/disqualified/new round or amend with supplier-enterable_flag Y/
           -- new round or amend with supplier flag N in this and previous version


        IF (g_debug_mode = 'Y') THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                                   module    => g_module_prefix || l_module,
                                   message   => 'In else of p_copy_only_from_auc is Y' );
                       END IF;
        END IF;

        IF (g_debug_mode = 'Y') THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                                   module    => g_module_prefix || l_module,
                                   message   => 'Insert for lines not bid' );
                       END IF;
        END IF;
        --copy all the payments for the lines from auction payments for lines that have not been bid
        INSERT INTO pon_bid_payments_shipments
		(
                 BID_NUMBER,
                 BID_LINE_NUMBER,
                 BID_PAYMENT_ID,
                 AUCTION_HEADER_ID,
                 AUCTION_LINE_NUMBER,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
		 LAST_UPDATE_LOGIN,
                 PAYMENT_DISPLAY_NUMBER,
                 PAYMENT_DESCRIPTION,
                 AUCTION_PAYMENT_ID,
                 PAYMENT_TYPE_CODE,
                 QUANTITY,
                 UOM_CODE,
                 PROMISED_DATE
		)
		(SELECT
                 p_bid_number,	--BID_NUMBER,
                 bl.line_number,		--BID_LINE_NUMBER,
                 pon_bid_payments_shipments_s1.nextval,	--BID_PAYMENT_ID,
                 p_auc_header_id,  --AUCTION_HEADER_ID,
                 bl.line_number,	--AUCTION_LINE_NUMBER,
                 sysdate,		--CREATION_DATE,
                 p_userid,	--CREATED_BY,
                 sysdate, 	--LAST_UPDATE_DATE,
                 p_userid, 	--LAST_UPDATED_BY,
		 fnd_global.login_id,                        --LAST_UPDATE_LOGIN
                 apmt.PAYMENT_DISPLAY_NUMBER,  --PAYMENT_DISPLAY_NUMBER,
                 apmt.PAYMENT_DESCRIPTION,    --PAYMENT_DESCRIPTION,
                 decode(p_supplier_flag, 'N',apmt.PAYMENT_ID,null),    --AUCTION_PAYMENT_ID,
                 apmt.PAYMENT_TYPE_CODE,    --PAYMENT_TYPE_CODE,
                 apmt.QUANTITY,    --QUANTITY,
                 apmt.UOM_CODE,    --UOM_CODE,
                 bl.promised_date   --PROMISED_DATE,
                 FROM    pon_bid_item_prices bl,
                 pon_auc_payments_shipments apmt
                 WHERE   bl.auction_header_id = p_auc_header_id
                 AND bl.bid_number = p_bid_number
                 AND bl.auction_header_id = apmt.auction_header_id
                 AND bl.line_number = apmt.line_number
                 AND bl.has_bid_flag = 'N'
                 AND bl.line_number BETWEEN p_batch_start AND p_batch_end);

        IF (g_debug_mode = 'Y') THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                                   module    => g_module_prefix || l_module,
                                   message   => 'Insert for lines that were bid' );
                       END IF;
        END IF;
           --copy all the payments for the lines from bid payments for lines that have  been bid
           INSERT INTO pon_bid_payments_shipments
		(
                 BID_NUMBER,
                 BID_LINE_NUMBER,
                 BID_PAYMENT_ID,
                 AUCTION_HEADER_ID,
                 AUCTION_LINE_NUMBER,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
		 LAST_UPDATE_LOGIN,
                 PAYMENT_DISPLAY_NUMBER,
                 PAYMENT_DESCRIPTION,
                 AUCTION_PAYMENT_ID,
                 PAYMENT_TYPE_CODE,
                 QUANTITY,
                 UOM_CODE,
                 PRICE,
                 BID_CURRENCY_PRICE,
                 PROMISED_DATE,
                 OLD_PAYMENT_DISPLAY_NUMBER,
                 OLD_PAYMENT_TYPE_CODE,
                 OLD_PAYMENT_DESCRIPTION,
                 OLD_QUANTITY,
                 OLD_UOM_CODE,
                 OLD_BID_CURRENCY_PRICE,
                 OLD_PROMISED_DATE
		)
		(SELECT
                 p_bid_number,	--BID_NUMBER,
                 bl.line_number,		--BID_LINE_NUMBER,
                 pon_bid_payments_shipments_s1.nextval,	--BID_PAYMENT_ID,
                 p_auc_header_id,  --AUCTION_HEADER_ID,
                 bl.line_number,	--AUCTION_LINE_NUMBER,
                 sysdate,		--CREATION_DATE,
                 p_userid,	--CREATED_BY,
                 sysdate, 	--LAST_UPDATE_DATE,
                 p_userid, 	--LAST_UPDATED_BY,
		 fnd_global.login_id,                        --LAST_UPDATE_LOGIN
                 bpmt.PAYMENT_DISPLAY_NUMBER,  --PAYMENT_DISPLAY_NUMBER,
                 bpmt.PAYMENT_DESCRIPTION,    --PAYMENT_DESCRIPTION,
                 decode(p_new_round_or_amended , 'Y' ,
                             decode(p_supplier_flag ,'N',(select payment_id from pon_auc_payments_shipments
                                              where auction_header_id=p_auc_header_id
                                              AND line_number = bl.line_number
                                               AND payment_display_number= bpmt.PAYMENT_DISPLAY_NUMBER
                                                          )
                                             , null
                                     ),bpmt.AUCTION_PAYMENT_ID
                       ),    --AUCTION_PAYMENT_ID,
                 bpmt.PAYMENT_TYPE_CODE,    --PAYMENT_TYPE_CODE,
                 bpmt.QUANTITY,    --QUANTITY,
                 bpmt.UOM_CODE,    --UOM_CODE,
                 bpmt.PRICE,    --PRICE,
                 bpmt.BID_CURRENCY_PRICE,    --BID_CURRENCY_PRICE,
                 bpmt.promised_date,    --PROMISED_DATE,
                 decode(p_rebid_flag, 'Y',bpmt.PAYMENT_DISPLAY_NUMBER,null),    --OLD_PAYMENT_DISPLAY_NUMBER,
                 decode(p_rebid_flag, 'Y',bpmt.PAYMENT_TYPE_CODE,null),    --OLD_PAYMENT_TYPE_CODE,
                 decode(p_rebid_flag, 'Y',bpmt.PAYMENT_DESCRIPTION,null),    --OLD_PAYMENT_DESCRIPTION,
                 decode(p_rebid_flag, 'Y',bpmt.QUANTITY,null),	--OLD_QUANTITY,
                 decode(p_rebid_flag, 'Y',bpmt.UOM_CODE, null),    --OLD_UOM_CODE,
                 decode(p_rebid_flag, 'Y',bpmt.BID_CURRENCY_PRICE, null),    --OLD_BID_CURRENCY_PRICE,
                 decode(p_rebid_flag, 'Y',bpmt.PROMISED_DATE, null)    --OLD_PROMISED_DATE
                 FROM    pon_bid_item_prices bl,
                 pon_bid_payments_shipments bpmt
                 WHERE   bl.auction_header_id = p_auc_header_id
                 AND bl.bid_number = p_bid_number
                 AND bpmt.bid_number = p_source_bid_num
                 AND bpmt.bid_line_number = bl.line_number
                 AND bl.has_bid_flag = 'Y'
                 AND bl.line_number BETWEEN p_batch_start AND p_batch_end);

        IF (g_debug_mode = 'Y') THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                                   module    => g_module_prefix || l_module,
                                   message   => 'copy attachements from bid' );
                       END IF;
        END IF;
               --copy the attachments for those payments which came from bid
               FOR payment_rec in c_bid_pymnts_attach LOOP
                        FND_ATTACHED_DOCUMENTS2_PKG.COPY_ATTACHMENTS (
                          X_from_entity_name  =>  'PON_BID_PAYMENTS_SHIPMENTS',
                          X_from_pk1_value    =>  to_char(payment_rec.source_bid_number),
                          X_from_pk2_value    =>  to_char(payment_rec.source_bid_line_number),
                          X_from_pk3_value    =>  to_char(payment_rec.source_bid_payment_id),
                          X_to_entity_name    =>  'PON_BID_PAYMENTS_SHIPMENTS',
                          X_to_pk1_value      =>  to_char(payment_rec.dest_bid_number),
                          X_to_pk2_value      =>  to_char(payment_rec.dest_bid_line_number),
                          X_to_pk3_value      =>  to_char(payment_rec.dest_bid_payment_id),
                          X_created_by        =>  p_userid,
                          X_last_update_login =>  fnd_global.login_id);
	       END LOOP;
        END IF; --p_copy_only_from_auc
     IF (g_debug_mode = 'Y') THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                                   module    => g_module_prefix || l_module,
                                   message   => 'exiting insert_into_payments' );
                       END IF;
      END IF;
END	insert_into_payments;

-- ======================================================================
-- PROCEDURE:	COPY_LINE_ATTACHMENTS  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction_header_id of negotiation
--	p_bid_number		IN bid number to copy attachments to
--	p_source_header_id	IN auction_header_id of source bids negotiation
--	p_source_bid_num	IN source_bid to copy attachments from
--	p_userid			IN userid of bid creator
--
--  COMMENT: copies over line attachments from source bid
-- ======================================================================
PROCEDURE copy_line_attachments
(
	p_auc_header_id		IN pon_bid_headers.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_source_header_id	IN pon_bid_headers.auction_header_id%TYPE,
	p_source_bid_num	IN pon_bid_headers.bid_number%TYPE,
	p_userid			IN pon_bid_headers.created_by%TYPE,
	p_batch_start		IN pon_bid_item_prices.line_number%TYPE,
	p_batch_end			IN pon_bid_item_prices.line_number%TYPE,
        p_to_category_id    IN NUMBER,
        p_change_categ_id       IN VARCHAR2
) IS

	CURSOR bid_lines_with_attachments IS
		SELECT DISTINCT ad.pk3_value
		FROM fnd_attached_documents ad, pon_bid_item_prices bl
		WHERE ad.entity_name = 'PON_BID_ITEM_PRICES'
			AND ad.pk1_value = p_source_header_id
			AND ad.pk2_value = p_source_bid_num
			AND ad.pk3_value IS NOT null
			AND bl.bid_number = p_bid_number
			AND bl.line_number = to_number(ad.pk3_value)
			AND bl.has_bid_flag = 'Y'
			AND bl.line_number BETWEEN p_batch_start AND p_batch_end;

BEGIN
        IF p_change_categ_id = 'Y' then
                -- Copy the line's attachments only for unmodified lines, with new target category.
                FOR line IN bid_lines_with_attachments LOOP
                        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments
                                (x_from_entity_name => 'PON_BID_ITEM_PRICES',
                                x_from_pk1_value => p_source_header_id,
                                x_from_pk2_value => p_source_bid_num,
                                x_from_pk3_value => line.pk3_value,
                                x_to_entity_name => 'PON_BID_ITEM_PRICES',
                                x_to_pk1_value => p_auc_header_id,
                                x_to_pk2_value => p_bid_number,
                                x_to_pk3_value => line.pk3_value,
                                x_created_by => p_userid,
                                x_last_update_login => fnd_global.login_id,
                                x_to_category_id => p_to_category_id);
                END LOOP;
        ELSE
                -- Copy the line's attachments only for unmodified lines
                FOR line IN bid_lines_with_attachments LOOP
                        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments
                                (x_from_entity_name => 'PON_BID_ITEM_PRICES',
                                x_from_pk1_value => p_source_header_id,
                                x_from_pk2_value => p_source_bid_num,
                                x_from_pk3_value => line.pk3_value,
                                x_to_entity_name => 'PON_BID_ITEM_PRICES',
                                x_to_pk1_value => p_auc_header_id,
                                x_to_pk2_value => p_bid_number,
                                x_to_pk3_value => line.pk3_value,
                                x_created_by => p_userid,
                                x_last_update_login => fnd_global.login_id);
                END LOOP;
        END IF; -- }

END copy_line_attachments;

-- ======================================================================
-- PROCEDURE:	POPULATE_HAS_BID_FLAG  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction_header_id of negotiation
--	p_bid_number		IN bid number to populate has_bid_flag for
--
--  COMMENT: populates has_bid_flag - used when defualting from pre-release 12 draft
-- ======================================================================
PROCEDURE populate_has_bid_flag
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE
) IS
	l_full_qty_reqd		VARCHAR2(1);
BEGIN

	-- Determine if the auction is full quantity required
	SELECT decode(ah.full_quantity_bid_code, 'FULL_QTY_BIDS_REQD', 'Y', 'N')
	INTO l_full_qty_reqd
	FROM pon_auction_headers_all ah
	WHERE ah.auction_header_id = p_auc_header_id;

	-- First set has_bid_flag to N
	UPDATE pon_bid_item_prices bl
	SET bl.has_bid_flag = 'N'
	WHERE bl.bid_number = p_bid_number;

	-- Then, determine which lines have a bid
	UPDATE pon_bid_item_prices bl
	SET bl.has_bid_flag = 'Y'
	WHERE bl.bid_number = p_bid_number
		AND ((bl.promised_date IS NOT null
			OR bl.price IS NOT null
			OR bl.proxy_bid_limit_price IS NOT null
			OR bl.po_bid_min_rel_amount IS NOT null
			OR bl.note_to_auction_owner IS NOT null)

			OR EXISTS

			-- Check auction side to check quantity
			(SELECT al.line_number
			FROM pon_auction_item_prices_all al
			WHERE al.auction_header_id = bl.auction_header_id
				AND al.line_number = bl.line_number
				AND (l_full_qty_reqd <> 'Y'
						AND al.order_type_lookup_code <> 'AMOUNT'
						AND al.group_type <> 'LOT_LINE'
						AND bl.quantity IS NOT null))

			OR EXISTS

			-- Check attributes
			(SELECT ba.line_number
			FROM pon_bid_attribute_values ba
			WHERE ba.bid_number = bl.bid_number
				AND ba.line_number = bl.line_number
				AND ba.value IS NOT null
				AND rownum = 1)

			OR EXISTS

			-- Check price factors
			(SELECT bpf.line_number
			FROM pon_bid_price_elements bpf
			WHERE bpf.bid_number = bl.bid_number
				AND bpf.line_number = bl.line_number
				AND bpf.pf_type = 'SUPPLIER'
				AND bpf.bid_currency_value IS NOT null
				AND rownum = 1)

			OR EXISTS

			-- Check shipments
			(SELECT bs.line_number
			FROM pon_bid_shipments bs
			WHERE bs.bid_number = bl.bid_number
				AND bs.line_number = bl.line_number
				AND (bs.auction_shipment_number IS null
					OR bs.price_type = 'PRICE' AND bs.bid_currency_unit_price IS NOT null
					OR bs.price_type = 'PRICE DISCOUNT' AND bs.price_discount IS NOT null
					OR bs.bid_currency_price IS NOT null)
				AND rownum = 1)

			OR EXISTS

			-- Check price differentials, including shipment price differentials
			(SELECT bpd.line_number
			FROM pon_bid_price_differentials bpd
			WHERE bpd.bid_number = bl.bid_number
				AND bpd.line_number = bl.line_number
				AND bpd.multiplier IS NOT null
				AND rownum = 1)
			);

END populate_has_bid_flag;

-- ======================================================================
-- PROCEDURE:	CREATE_NEW_DRAFT  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction_header_id of negotiation
--	p_source_bid_num	IN source_bid to default from
--	p_tpid				IN trading partner id of supplier
--	p_tpcid				IN trading partner contact id of supplier
--	p_tpname			IN trading partner name of supplier
--	p_tpcname			IN trading partner contact name of supplier
--	p_userid			IN userid of bid creator
--	p_venid				IN vendor id
--	p_vensid			IN vendor site id to place bid for
--	p_venscode			IN vendor site code to place bid for
--	p_auctpid			IN buyers trading partner id
--	p_auctcpid			IN buyers trading partner contact id
--	p_buyer_user		IN flag indicating surrogate bid or not
--	p_evaluator_id		IN evaluator user id
--	p_eval_flag		IN flag indicating if the response is an evaluation
--  p_new_round_or_amended IN flag indicating, if bid defualt is happening for new round or amend
--	p_rebid_flag		IN flag indicating rebid or not
--	x_bid_number		OUT the bid number of the created bid
--
--  COMMENT: creates a new draft bid for the specified supplier/site
--			combination on the specified site. Inserts values into all bid
--			side tables and copies attachments
-- ======================================================================
PROCEDURE create_new_draft_bid
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_source_bid_num	IN pon_bid_headers.bid_number%TYPE,
	p_tpid				IN pon_bid_headers.trading_partner_id%TYPE,
	p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE,
	p_tpname			IN pon_bid_headers.trading_partner_name%TYPE,
	p_tpcname			IN pon_bid_headers.trading_partner_contact_name%TYPE,
	p_userid			IN pon_bid_headers.created_by%TYPE,
	p_venid				IN pon_bid_headers.vendor_id%TYPE,
	p_vensid			IN pon_bid_headers.vendor_site_id%TYPE,
	p_venscode			IN pon_bid_headers.vendor_site_code%TYPE,
	p_auctpid			IN pon_bid_headers.surrog_bid_created_tp_id%TYPE,
	p_auctpcid			IN pon_bid_headers.surrog_bid_created_contact_id%TYPE,
	p_buyer_user		IN VARCHAR2,
	----------- Supplier Management: Supplier Evaluation -----------
	p_evaluator_id		IN pon_bid_headers.evaluator_id%TYPE,
	p_eval_flag		IN pon_bid_headers.evaluation_flag%TYPE,
	----------------------------------------------------------------
	p_new_round_or_amended IN VARCHAR2,
	p_rebid_flag		IN VARCHAR2,
	p_prev_bid_disq		IN VARCHAR2,
	x_bid_number		OUT NOCOPY pon_bid_headers.bid_number%TYPE,
        x_return_status         OUT NOCOPY NUMBER,
        x_return_code           OUT NOCOPY VARCHAR2
) IS
	l_source_header_id	pon_auction_headers_all.auction_header_id%TYPE;
	l_restricted_flag	VARCHAR2(1);
	l_rel12_draft		VARCHAR2(1);
	l_source_bid_status	pon_bid_headers.bid_status%TYPE;
	l_supp_seq_number	pon_bidding_parties.sequence%TYPE;

	l_max_line_number	pon_bid_item_prices.line_number%TYPE;
	l_batch_start		pon_bid_item_prices.line_number%TYPE;
	l_batch_end			pon_bid_item_prices.line_number%TYPE;
	l_skip_pf_for_batch VARCHAR2(1);
	l_supplier_flag                             pon_auction_headers_all.SUPPLIER_ENTERABLE_PYMT_FLAG%TYPE;
        l_payment_type                              pon_auction_headers_all.PROGRESS_PAYMENT_TYPE%TYPE;
        l_contract_type                             pon_auction_headers_all.CONTRACT_TYPE%TYPE;
        l_module  CONSTANT VARCHAR2(35) := 'create_new_draft_bid';
        l_other_draft_bid_number    pon_bid_headers.bid_number%TYPE;
        l_surrog_bid_flag      pon_bid_headers.surrog_bid_flag%TYPE;
        l_price_tiers_indicator pon_auction_headers_all.price_tiers_indicator%TYPE;


        -- Two-part RFQ related variables
        l_is_new_round  VARCHAR2(1) := 'N';       -- to store Y for new rounds (default N)
        l_to_category_id  NUMBER;       -- to store destination category id
        l_prev_two_part  VARCHAR2(1);   -- Y if previous round was two-part, else N or null
        l_curr_two_part  VARCHAR2(1);   -- Y if current round is two-part, else N or null
        l_categ_id_supp  NUMBER;        -- to store category id of "FromSupplier"
        l_categ_id_supp_tech  NUMBER;        -- to store category id of "FromSupplierTechnical"
        l_change_categ_id VARCHAR2(1) := 'N'; -- change category id ?

		-- Variables for bug 11665610
        l_display_pf_flag pon_bid_item_prices.DISPLAY_PRICE_FACTORS_FLAG%TYPE;
        l_bid_quantity pon_bid_item_prices.quantity%TYPE;
        l_bid_curr_unit_price pon_bid_item_prices.bid_currency_unit_price%TYPE;
        l_line_number pon_bid_item_prices.line_number%TYPE;

        l_order_type_lookup_type pon_auction_item_prices_all.order_type_lookup_code%TYPE;
        l_auc_quantity pon_auction_item_prices_all.quantity%TYPE;

        l_rate PON_BID_HEADERS.RATE%TYPE;
        l_tp_id PON_BID_HEADERS.TRADING_PARTNER_ID%TYPE;
        l_vendor_site_id PON_BID_HEADERS.VENDOR_SITE_ID%TYPE;
        l_precision PON_BID_HEADERS.NUMBER_PRICE_DECIMALS%TYPE;

        l_full_quan_req VARCHAR(1); -- Y is the pon_auction_headers_all.full_quantity_bid_code has code FULL_QTY_BIDS_REQD
        l_supplier_view PON_AUCTION_HEADERS_ALL.supplier_view_type%TYPE;

	      l_unit pon_pf_supplier_formula.unit_price%TYPE;
        l_amount pon_pf_supplier_formula.fixed_amount%TYPE;
        l_percentage pon_pf_supplier_formula.percentage%TYPE;

        l_pf_value NUMBER;
        l_pf_unit_price NUMBER;
        l_total_price  NUMBER; --double in java
        l_unit_pf_amt NUMBER; --double in java
        l_transformed_price NUMBER;
        l_truncated_value NUMBER;
        l_trans_price NUMBER;
        l_bid_curr_trans_price NUMBER;
        l_price NUMBER;

        CURSOR bid_values IS
           SELECT pbip.DISPLAY_PRICE_FACTORS_FLAG, pbip.quantity AS bid_quantity, pbip.bid_currency_unit_price, pbip.line_number, paip.order_type_lookup_code, paip.quantity AS auc_quantity
           FROM PON_BID_ITEM_PRICES pbip, pon_auction_item_prices_all paip
           WHERE paip.auction_header_id = p_auc_header_id
           AND pbip.bid_number = x_bid_number
           AND pbip.line_number(+) = paip.line_number;

        CURSOR supplier_pf_curr(v_line_number pon_bid_item_prices.line_number%TYPE) IS
            SELECT PRICING_BASIS, BID_CURRENCY_VALUE, PRICE_ELEMENT_TYPE_ID
            FROM PON_BID_PRICE_ELEMENTS
            WHERE AUCTION_HEADER_ID = p_auc_header_id
            AND BID_NUMBER = x_bid_number
            AND LINE_NUMBER = v_line_number
            AND PF_TYPE <> 'BUYER';
BEGIN

	BEGIN
		-- Check if the supplier has restricted lines, and get sequence number
		SELECT decode(bp.access_type, 'RESTRICTED', 'Y', 'N'), bp.sequence
		INTO l_restricted_flag, l_supp_seq_number
		FROM pon_bidding_parties bp
		WHERE bp.auction_header_id = p_auc_header_id
			AND bp.trading_partner_id = p_tpid
			AND nvl(bp.vendor_site_id, -1) = p_vensid;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			l_restricted_flag := 'N';
			l_supp_seq_number := null;
	END;

	-- Create and default bid header and get the bid number
	insert_into_bid_header
		(p_auc_header_id,
		p_source_bid_num,
		p_tpid,
		p_tpname,
		p_tpcid,
		p_tpcname,
		p_userid,
		p_venid,
		p_vensid,
		p_venscode,
		p_auctpid,
		p_auctpcid,
		p_buyer_user,
		---- Supplier Management: Supplier Evaluation ----
		p_evaluator_id,
		p_eval_flag,
		--------------------------------------------------
		p_rebid_flag,
		p_prev_bid_disq,
		x_bid_number);

	-- Create header attributes
	insert_into_header_attributes
		(p_auc_header_id,
		x_bid_number,
		p_source_bid_num,
		p_userid,
		---- Supplier Management: Supplier Evaluation ----
		p_evaluator_id,
		p_eval_flag,
		--------------------------------------------------
		p_rebid_flag);

	-- Copy over header attachments
	IF (p_source_bid_num IS NOT null) THEN

		SELECT bh.auction_header_id
		INTO l_source_header_id
		FROM pon_bid_headers bh
		WHERE bh.bid_number = p_source_bid_num;

                -- get value of two-part flags for current and prev rounds
                select  decode(pah.auction_header_id_prev_round, null, 'N', 'Y'),
                        nvl(pah.two_part_flag, 'N'),
                        (select nvl(two_part_flag,'N') from pon_auction_headers_all
                         where auction_header_id = pah.auction_header_id_prev_round)
                into l_is_new_round, l_curr_two_part, l_prev_two_part
                from    pon_auction_headers_all pah
                where auction_header_id = p_auc_header_id;

                log_message(l_module, 'Two-Part related variables: l_is_new_round: ' || l_is_new_round || '; l_curr_two_part: '||l_curr_two_part||'; l_prev_two_part: ' || l_prev_two_part);

                -- if it is a new round, and two-part flag has changed...
                if (l_is_new_round = 'Y' AND (l_curr_two_part <> l_prev_two_part)) THEN -- {
                        -- target category id needs to be changed
                        -- fetch target category ids.
                        select  (select category_id from fnd_document_categories
                                 where name = pon_auction_pkg.g_supplier_attachment),
                                (select category_id from fnd_document_categories
                                 where name = pon_auction_pkg.g_technical_attachment)
                        into    l_categ_id_supp, l_categ_id_supp_tech
                        from    fnd_document_categories
                        where   ROWNUM = 1;

                        -- if prev round was two part, copy attachments to "FromSupplier"
                        if (l_prev_two_part = 'Y') THEN -- {
                                l_to_category_id := l_categ_id_supp;
                                l_change_categ_id := 'Y';
                        -- else copy to "FromSupplierTechnical"
                        else
                                l_to_category_id := l_categ_id_supp_tech;
                                l_change_categ_id := 'Y';
                        end if; -- }

                        log_message(l_module, 'Two-Part related variables: l_to_category_id: ' || l_to_category_id || '; l_categ_id_supp_tech: '||l_categ_id_supp_tech||'; l_categ_id_supp: ' || l_categ_id_supp);

                        -- Copy header attachments to new target category
                        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments
                            (x_from_entity_name => 'PON_BID_HEADERS',
                            x_from_pk1_value => l_source_header_id,
                            x_from_pk2_value => p_source_bid_num,
                            x_to_entity_name => 'PON_BID_HEADERS',
                            x_to_pk1_value => p_auc_header_id,
                            x_to_pk2_value => x_bid_number,
                            x_created_by => p_userid,
                            x_last_update_login => fnd_global.login_id,
                            x_to_category_id => l_to_category_id);

                ELSE
		-- Copy header level attachments without changing categories
		FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments
			(x_from_entity_name => 'PON_BID_HEADERS',
			x_from_pk1_value => l_source_header_id,
			x_from_pk2_value => p_source_bid_num,
			x_to_entity_name => 'PON_BID_HEADERS',
			x_to_pk1_value => p_auc_header_id,
			x_to_pk2_value => x_bid_number,
			x_created_by => p_userid,
			x_last_update_login => fnd_global.login_id);
                END IF; -- }
	END IF;

	--get the one time values needed for complex work here to avoid reexcution of
	--query with every batch
        g_copy_only_from_auc := 'N';
	  IF (g_debug_mode = 'Y') THEN
          IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
              FND_LOG.string(log_level => FND_LOG.level_statement,
                         module    => g_module_prefix || l_module,
                         message   => 'initializing negotiation values for complex work');
         END IF;
     END IF;
         select nvl(ah.SUPPLIER_ENTERABLE_PYMT_FLAG, 'N'), nvl(progress_payment_type,'NONE'), contract_type,
	 nvl(ADVANCE_NEGOTIABLE_FLAG,'N'),nvl(RECOUPMENT_NEGOTIABLE_FLAG,'N'),nvl(PROGRESS_PYMT_NEGOTIABLE_FLAG,'N'),
	 nvl(MAX_RETAINAGE_NEGOTIABLE_FLAG,'N'),nvl(RETAINAGE_NEGOTIABLE_FLAG,'N')
          into l_supplier_flag, l_payment_type, l_contract_type,
	  g_advance_negotiable,g_recoupment_negotiable,g_prog_pymt_negotiable,g_max_rtng_negotiable,g_rtng_negotiable
          FROM pon_auction_headers_all ah where ah.auction_header_id=p_auc_header_id;
     IF (g_debug_mode = 'Y') THEN
          IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
              FND_LOG.string(log_level => FND_LOG.level_statement,
                         module    => g_module_prefix || l_module,
                         message   => 'initializing  currency stuff for complex work');
         END IF;
      END IF;
	   -- Get bid currency precisions and rate and surrogate bid flag
	   SELECT cu.precision,
		bh.rate,
                bh.surrog_bid_flag
	   INTO g_curr_prec,
		g_bid_rate,
                l_surrog_bid_flag
	   FROM pon_bid_headers bh,
		fnd_currencies cu
	   WHERE bh.bid_number = x_bid_number
		AND cu.currency_code = bh.bid_currency_code;

	  --do the following only if complex work neg
            IF (p_new_round_or_amended = 'Y' and l_supplier_flag = 'N'
			        AND l_payment_type <> 'NONE' AND l_contract_type = 'STANDARD') THEN
              IF (g_debug_mode = 'Y') THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                                   module    => g_module_prefix || l_module,
                                   message   => 'within if for complex work');
                       END IF;
              END IF;
              -- check from where should a payment defualt if supplier flag was
              --toggled in new round or amend
              -- Here default payments from previous bid if SUPPLIER_ENTERABLE_PYMT_FLAG for
              -- new negotiation is Y. but if SUPPLIER_ENTERABLE_PYMT_FLAG is N
              -- then if previous neg had SUPPLIER_ENTERABLE_PYMT_FLAG as Y then
              -- we need to default payments from neg and not from bid.
               select decode(oldah.SUPPLIER_ENTERABLE_PYMT_FLAG, 'Y','Y', 'N')
	            into g_copy_only_from_auc
	            FROM pon_auction_headers_all oldah
               WHERE oldah.auction_header_id = l_source_header_id;

               IF (g_debug_mode = 'Y') THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                                   module    => g_module_prefix || l_module,
                                   message   => 'after selecting supplier flag copy only from auc value is' || g_copy_only_from_auc );
                       END IF;
              END IF;

         END IF; --p_new_round... ontract_type STANDARD and payment_type <> NONE
         IF (g_debug_mode = 'Y') THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                                   module    => g_module_prefix || l_module,
                                   message   => 'Finished initializing negotiation values for complex work' );
                       END IF;
        END IF;
	--end values needed for complex work

	-- START BATCHING

	-- Determine the maximum line number for the negotiation
	SELECT ah.max_internal_line_num ,ah.price_tiers_indicator
	INTO l_max_line_number,l_price_tiers_indicator
	FROM pon_auction_headers_all ah
	WHERE ah.auction_header_id = p_auc_header_id;

	-- Define the initial range (line numbers are indexed from 1)
	l_batch_start := 1;
	IF (l_max_line_number < PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE) THEN
		l_batch_end := l_max_line_number;
	ELSE
		l_batch_end := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
	END IF;

	WHILE (l_batch_start <= l_max_line_number) LOOP

		-- Create and default bid lines
		insert_into_bid_items
			(p_auc_header_id,
			x_bid_number,
			p_source_bid_num,
			p_tpid,
			p_tpcid,
			p_userid,
			p_vensid,
			p_rebid_flag,
			l_restricted_flag,
			l_batch_start,
			l_batch_end,
                        l_surrog_bid_flag);

		-- Copy over line attachments
		IF (p_source_bid_num IS NOT null) THEN

			copy_line_attachments
				(p_auc_header_id,
				x_bid_number,
				l_source_header_id,
				p_source_bid_num,
				p_userid,
				l_batch_start,
				l_batch_end,
                                l_to_category_id,
                                l_change_categ_id);
		END IF;

		-- Create and default header and line attributes
		insert_into_line_attributes
			(p_auc_header_id,
			x_bid_number,
			p_source_bid_num,
			p_userid,
			p_rebid_flag,
			l_batch_start,
			l_batch_end);

		-- Populate display_price_factors_flag
		populate_display_pf_flag
			(p_auc_header_id,
			x_bid_number,
			l_supp_seq_number,
			l_batch_start,
			l_batch_end,
			l_skip_pf_for_batch);

		IF (l_skip_pf_for_batch = 'N') THEN

			-- Create and defualt price factors
			insert_into_price_factors
				(p_auc_header_id,
				x_bid_number,
				p_source_bid_num,
				p_userid,
				l_supp_seq_number,
				p_rebid_flag,
				l_batch_start,
				l_batch_end);
		END IF;

       --Create and default price tiers only if the price tiers indicator
       -- is non null and not NONE
       IF (l_price_tiers_indicator  is NOT NULL AND
        l_price_tiers_indicator  <> 'NONE') THEN
            insert_into_price_tiers
                (p_auc_header_id,
                 x_bid_number,
                 p_source_bid_num,
                 p_userid,
                 p_rebid_flag,
                 l_batch_start,
                 l_batch_end);
        END IF;

        -- Create and default price differentials
        insert_into_price_diff
            (p_auc_header_id,
             x_bid_number,
             p_source_bid_num,
             p_userid,
             p_rebid_flag,
             l_batch_start,
             l_batch_end);

       --complex work
       IF (l_payment_type <> 'NONE' AND l_contract_type = 'STANDARD' ) THEN

        IF (g_debug_mode = 'Y') THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                                   module    => g_module_prefix || l_module,
                                   message   => 'before calling insert_into_payments' );
                       END IF;
          END IF;
   	       -- Create and default payments
		insert_into_payments
			(p_auc_header_id,
			x_bid_number,
			p_source_bid_num,
			g_copy_only_from_auc,
			l_supplier_flag,
			p_userid,
			p_rebid_flag,
                        p_new_round_or_amended,
			l_batch_start,
			l_batch_end);
         IF (g_debug_mode = 'Y') THEN
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.level_statement,
                                   module    => g_module_prefix || l_module,
                                   message   => 'after calling insert_into_payments' );
                       END IF;
          END IF;
        END IF; --contract_type STANDARD and payment_type <> NONE

	--Code for cost factors change during bid copy - bug 11665610
    --Need this logic only if the current bid is copied from previous bid
    IF(p_source_bid_num IS NOT NULL) THEN

      SELECT RATE, TRADING_PARTNER_ID, VENDOR_SITE_ID, NUMBER_PRICE_DECIMALS
                INTO l_rate, l_tp_id, l_vendor_site_id, l_precision
            FROM PON_BID_HEADERS
            WHERE BID_NUMBER = x_bid_number
            AND AUCTION_HEADER_ID = p_auc_header_id
            AND BID_STATUS = 'DRAFT';

      SELECT decode(full_quantity_bid_code, 'FULL_QTY_BIDS_REQD', 'Y', 'N'), supplier_view_type
               INTO l_full_quan_req, l_supplier_view
            FROM PON_AUCTION_HEADERS_ALL
            WHERE AUCTION_HEADER_ID = p_auc_header_id;

      --Loop through the bid lines and re calculate the price based on current price factors
      FOR bid_values_rec IN bid_values
      LOOP
        l_display_pf_flag := bid_values_rec.DISPLAY_PRICE_FACTORS_FLAG;
        l_bid_quantity := bid_values_rec.bid_quantity;
        l_bid_curr_unit_price := bid_values_rec.bid_currency_unit_price;
        l_line_number := bid_values_rec.line_number;
        l_order_type_lookup_type := bid_values_rec.order_type_lookup_code;
        l_auc_quantity := bid_values_rec.auc_quantity;

        BEGIN
          SELECT unit_price, fixed_amount, percentage
	            INTO l_unit, l_amount, l_percentage
	        FROM pon_pf_supplier_formula
	        WHERE auction_header_id = p_auc_header_id
		      AND line_number = l_line_number
		      AND (trading_partner_id = l_tp_id AND
                       vendor_site_id = l_vendor_site_id);

        EXCEPTION
          WHEN OTHERS THEN
            l_unit := 0;
            l_amount := 0;
            l_percentage := 1;
        END;

        --Calcualte considering supplier and buyer price factors to display the transformed price
        IF(l_display_pf_flag IS NOT NULL AND l_display_pf_flag = 'Y') THEN
          -- Applying supplier price factors
          FOR supp_pf_rec IN supplier_pf_curr(l_line_number)
          LOOP
            l_total_price := 0;
            l_pf_value := supp_pf_rec.BID_CURRENCY_VALUE;

            IF(supp_pf_rec.PRICING_BASIS = 'PER_UNIT') THEN
              l_pf_unit_price := l_pf_value;
            ELSIF(supp_pf_rec.PRICING_BASIS = 'PERCENTAGE') THEN
              l_pf_unit_price := (l_pf_value * l_bid_curr_unit_price/100);
            ELSIF(supp_pf_rec.PRICING_BASIS = 'FIXED_AMOUNT') THEN
              IF(l_order_type_lookup_type = 'FIXED PRICE') THEN
                 l_pf_unit_price := l_pf_value;
              ELSIF(l_order_type_lookup_type = 'RATE' OR l_order_type_lookup_type = 'AMOUNT') THEN
                 l_pf_unit_price := l_pf_value/l_auc_quantity;
              ELSE
                IF(l_contract_type = 'BLANKET' OR l_contract_type = 'CONTRACT' OR l_full_quan_req = 'Y') THEN
                  l_pf_unit_price := l_pf_value/l_auc_quantity;
                ELSE
                  l_pf_unit_price := l_pf_value/l_bid_quantity;
                END IF;
              END IF;
            END IF;

            --Donot add the price factor if it is unit price
            IF(l_pf_unit_price IS NOT NULL AND supp_pf_rec.PRICE_ELEMENT_TYPE_ID <> -10) THEN
              l_total_price := l_total_price + l_pf_unit_price;
            END IF;
          END LOOP;

          --Calculate with buyer price factors
          IF(l_amount IS NULL OR l_amount = 0) THEN
            l_unit_pf_amt := 0;
          ELSE
            IF(l_order_type_lookup_type = 'FIXED PRICE') THEN
              l_unit_pf_amt := l_amount;
            ELSIF(l_order_type_lookup_type = 'RATE' OR l_order_type_lookup_type = 'AMOUNT') THEN
              l_unit_pf_amt := l_amount/l_auc_quantity;
            ELSE
              IF(l_contract_type = 'BLANKET' OR l_contract_type = 'CONTRACT' OR l_full_quan_req = 'Y') THEN
                l_unit_pf_amt := l_amount/l_auc_quantity;
              ELSE
                l_unit_pf_amt := l_amount/l_bid_quantity;
              END IF;
            END IF;
          END IF;

          l_transformed_price := ((Nvl(l_unit,0)) * l_rate) + (l_unit_pf_amt * l_rate) + (l_percentage * l_bid_curr_unit_price);

          IF(l_transformed_price IS NOT NULL) THEN
            l_total_price := l_total_price + l_transformed_price;
          END IF;

          select ROUND(l_total_price, decode(l_precision, 10000, 10, l_precision)) INTO l_truncated_value FROM dual;

          IF(l_supplier_view = 'UNTRANSFORMED') THEN
            IF(l_amount IS NULL OR l_amount = 0) THEN
              l_unit_pf_amt := 0;
            ELSE
              IF(l_order_type_lookup_type = 'FIXED PRICE') THEN
                l_unit_pf_amt := l_amount;
              ELSIF(l_order_type_lookup_type = 'RATE' OR l_order_type_lookup_type = 'AMOUNT') THEN
                l_unit_pf_amt := l_amount/l_auc_quantity;
              ELSE
                IF(l_contract_type = 'BLANKET' OR l_contract_type = 'CONTRACT' OR l_full_quan_req = 'Y') THEN
                  l_unit_pf_amt := l_amount/l_auc_quantity;
                ELSE
                  l_unit_pf_amt := l_amount/l_bid_quantity;
                END IF;
              END IF;
            END IF;

            l_trans_price := ((Nvl(l_unit,0)) * l_rate) + (l_unit_pf_amt * l_rate) + (l_percentage * l_transformed_price);
          ELSIF(l_supplier_view = 'TRANSFORMED') THEN
            l_trans_price := l_transformed_price;
          END IF;

          SELECT  ROUND(l_trans_price, decode(l_precision, 10000, 10, l_precision)) INTO l_bid_curr_trans_price FROM dual;

          l_price := l_trans_price/l_rate;

          UPDATE PON_BID_ITEM_PRICES
            SET BID_CURRENCY_PRICE = l_truncated_value,
                BID_CURRENCY_TRANS_PRICE = l_bid_curr_trans_price,
                PRICE = l_price
          WHERE AUCTION_HEADER_ID = p_auc_header_id
          AND   BID_NUMBER = x_bid_number
          AND   LINE_NUMBER = l_line_number;

      ELSE -- Calculate transformed price based on buyer price factors
        IF(l_supplier_view = 'UNTRANSFORMED') THEN
          IF(l_amount IS NULL OR l_amount = 0) THEN
            l_unit_pf_amt := 0;
          ELSE
            IF(l_order_type_lookup_type = 'FIXED PRICE') THEN
              l_unit_pf_amt := l_amount;
            ELSIF(l_order_type_lookup_type = 'RATE' OR l_order_type_lookup_type = 'AMOUNT') THEN
              l_unit_pf_amt := l_amount/l_auc_quantity;
            ELSE
              IF(l_contract_type = 'BLANKET' OR l_contract_type = 'CONTRACT' OR l_full_quan_req = 'Y') THEN
                l_unit_pf_amt := l_amount/l_auc_quantity;
              ELSE
                l_unit_pf_amt := l_amount/l_bid_quantity;
              END IF;
            END IF;
          END IF;

          l_trans_price := ((Nvl(l_unit,0)) * l_rate) + (l_unit_pf_amt * l_rate) + (l_percentage * l_bid_curr_unit_price);

        ELSIF(l_supplier_view = 'TRANSFORMED') THEN
          l_trans_price := l_bid_curr_unit_price;
        END IF;

          SELECT  ROUND(l_trans_price, decode(l_precision, 10000, 10, l_precision)) INTO l_bid_curr_trans_price FROM dual;

          l_price := l_trans_price/l_rate;

          UPDATE PON_BID_ITEM_PRICES
            SET BID_CURRENCY_PRICE = l_bid_curr_unit_price,
                BID_CURRENCY_TRANS_PRICE = l_bid_curr_trans_price,
                PRICE = l_price
          WHERE AUCTION_HEADER_ID = p_auc_header_id
          AND   BID_NUMBER = x_bid_number
          AND   LINE_NUMBER = l_line_number;

        END IF;
      END LOOP;
    END IF;
    -- Code for cost factors Ends - bug 11665610


                -- here should commit the batch
                -- before commit, check whether this user already has a draft
                -- created. Maybe from a different session
                BEGIN
                    select bid_number
                    into l_other_draft_bid_number
                    from pon_bid_headers
                    where auction_header_id = p_auc_header_id
                    and bid_number <> x_bid_number
                    and bid_status = 'DRAFT'
                    and trading_partner_id = p_tpid
                    and trading_partner_contact_id = p_tpcid
                    and nvl(vendor_site_id, -1) = nvl(p_vensid, -1);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      l_other_draft_bid_number := null;
                END;

                IF (l_other_draft_bid_number IS NOT null) THEN
                    x_return_status := 1;
                    x_return_code := 'MULTIPLE_REBID';
                    ROLLBACK;
                ELSE
                    x_return_status := 0;
                    x_return_code := 'SUCCESS';
                    COMMIT;
                END IF;

		-- Find the new range
		l_batch_start := l_batch_end + 1;
		IF (l_batch_end + PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE > l_max_line_number) THEN
			l_batch_end := l_max_line_number;
		ELSE
			l_batch_end := l_batch_end + PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
		END IF;

	END LOOP;

	-- END BATCHING

	-- Populate header level display_price_factors_flag
	-- It is 'Y' if any line has the line level flag set
	UPDATE pon_bid_headers bh
	SET bh.display_price_factors_flag =
		nvl((SELECT 'Y'
		FROM pon_bid_item_prices bl
		WHERE bl.bid_number = bh.bid_number
			AND bl.display_price_factors_flag = 'Y'
			AND rownum = 1), 'N')
	WHERE bh.bid_number = x_bid_number;

	-- Handle proxy bidding: done in check_and_load_bid

END create_new_draft_bid;

-- ======================================================================
-- PROCEDURE:	EXPAND_DRAFT  PRIVATE
--  PARAMETERS:
--	p_bid_number		IN bid_number to expand
--	x_rebid_flag		OUT Y if bid expanded is a rebid
--
--  COMMENT: pre-release 12 draft bids do not have lines without bids.
--			As such, they need to be expanded to include them
-- ======================================================================
PROCEDURE expand_draft
(
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	x_rebid_flag		OUT NOCOPY VARCHAR2
) IS
	l_source_bid_num	pon_bid_headers.bid_number%TYPE;

	l_auc_header_id		pon_auction_headers_all.auction_header_id%TYPE;
	l_auctpid			pon_auction_headers_all.trading_partner_id%TYPE;
	l_tpid				pon_bid_headers.trading_partner_id%TYPE;
	l_tpcid				pon_bid_headers.trading_partner_contact_id%TYPE;
	l_userid			pon_bid_headers.created_by%TYPE;
	l_vensid			pon_bid_headers.vendor_site_id%TYPE;
	l_supp_seq_number	pon_bidding_parties.sequence%TYPE;
	l_has_pe_flag		VARCHAR2(1);
	l_blanket			VARCHAR2(1);
	l_full_qty			VARCHAR2(1);
	l_rate				pon_bid_headers.rate%TYPE;
	l_price_prec		pon_bid_headers.number_price_decimals%TYPE;
	l_curr_prec			fnd_currencies.precision%TYPE;

	l_max_line_number	pon_bid_item_prices.line_number%TYPE;
	l_batch_start		pon_bid_item_prices.line_number%TYPE;
	l_batch_end			pon_bid_item_prices.line_number%TYPE;
	l_skip_pf_for_batch VARCHAR2(1);
BEGIN

	-- Need to get auction_header_id and supplier info
	SELECT ah.auction_header_id,
		ah.trading_partner_id,
		decode(ah.has_price_elements, 'Y', 'Y', 'N'),
		decode(ah.contract_type, 'BLANKET', 'Y', 'CONTRACT', 'Y', 'N'),
		decode(ah.full_quantity_bid_code, 'FULL_QTY_BIDS_REQD', 'Y', 'N'),
		bh.trading_partner_id,
		bh.trading_partner_contact_id,
		bh.vendor_site_id,
		bh.created_by,
		bh.rate,
		bh.number_price_decimals,
		cu.precision
	INTO l_auc_header_id,
		l_auctpid,
		l_has_pe_flag,
		l_blanket,
		l_full_qty,
		l_tpid,
		l_tpcid,
		l_vensid,
		l_userid,
		l_rate,
		l_price_prec,
		l_curr_prec
	FROM pon_bid_headers bh, pon_auction_headers_all ah, fnd_currencies cu
	WHERE bh.bid_number = p_bid_number
		AND ah.auction_header_id = bh.auction_header_id
		AND cu.currency_code = bh.bid_currency_code;

	BEGIN
		-- Get the supplier sequence number
		SELECT 	bp.sequence
		INTO 	l_supp_seq_number
		FROM 	pon_bidding_parties bp
		WHERE 	bp.auction_header_id = l_auc_header_id
		AND 	bp.trading_partner_id = l_tpid
		AND 	bp.vendor_site_id = l_vensid;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN

			-- if the current supplier is not invited, then treat this
			-- sequence_number to be null

			l_supp_seq_number := null;
	END;


	BEGIN

		-- Determine the latest ACTIVE bid and set rebid_flag to Y
		-- Since there can only exist a single ACTIVE bid on an amendment for
		-- a particular user on a site, we use the rownum = 1 optimisation
		SELECT bh.bid_number, 'Y'
		INTO l_source_bid_num, x_rebid_flag
		FROM pon_bid_headers bh
		WHERE bh.auction_header_id = l_auc_header_id
			AND bh.trading_partner_id = l_tpid
			AND bh.trading_partner_contact_id = l_tpcid
			AND bh.vendor_site_id = l_vensid
			AND bh.bid_status = 'ACTIVE'
			AND rownum = 1
		ORDER BY bh.publish_date DESC;

	EXCEPTION
		-- there is no old bid to get old value columns
		WHEN NO_DATA_FOUND THEN
			x_rebid_flag := 'N';
	END;

	-- START BATCHING

	-- Determine the maximum line number for the negotiation
	SELECT ah.max_internal_line_num
	INTO l_max_line_number
	FROM pon_auction_headers_all ah
	WHERE ah.auction_header_id = l_auc_header_id;

	-- Define the initial range (line numbers are indexed from 1)
	l_batch_start := 1;
	IF (l_max_line_number < PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE) THEN
		l_batch_end := l_max_line_number;
	ELSE
		l_batch_end := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
	END IF;

	WHILE (l_batch_start <= l_max_line_number) LOOP

		-- We need to insert those auction side lines which haven't recieved bids
		-- line level display pf flag also populated
		insert_auction_lines
			(l_auc_header_id,
			p_bid_number,
			l_userid,
			l_auctpid,
			l_tpid,
			l_vensid,
			l_has_pe_flag,
			l_blanket,
			l_full_qty,
			l_supp_seq_number,
			l_rate,
			l_price_prec,
			l_curr_prec,
			l_batch_start,
			l_batch_end);

		-- If it as a rebid, we need to populate old_value columns
		IF (x_rebid_flag = 'Y') THEN
			-- special case for pre-rel12 draft - check
			populate_old_value_columns
				(p_bid_number,
				l_source_bid_num,
				l_batch_start,
				l_batch_end);
		END IF;

		-- Find the new range
		l_batch_start := l_batch_end + 1;
		IF (l_batch_end + PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE > l_max_line_number) THEN
			l_batch_end := l_max_line_number;
		ELSE
			l_batch_end := l_batch_end + PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
		END IF;

	END LOOP;

	-- END BATCHING

	-- Populate header level display_price_factors_flag
	-- It is 'Y' if any line has the line level flag set
	UPDATE pon_bid_headers bh
	SET bh.display_price_factors_flag =
		nvl((SELECT 'Y'
		FROM pon_bid_item_prices bl
		WHERE bl.bid_number = bh.bid_number
			AND bl.display_price_factors_flag = 'Y'
			AND rownum = 1), 'N')
	WHERE bh.bid_number = p_bid_number;

	-- Populate has_bid_flag as it is a rel12 column
	populate_has_bid_flag
		(l_auc_header_id,
		p_bid_number);

	/* once we have finished upgrading the draft, reset the flag to Y */
	update 	pon_bid_headers
	set	rel12_draft_flag = 'Y'
	where 	bid_number = p_bid_number;

	-- handle_proxy will be called in check_and_load_bid

END expand_draft;

-- ======================================================================
-- PROCEDURE:	LOCK_DRAFT  PRIVATE
--  PARAMETERS:
--	p_bid_number		IN bid number to lock
--	p_tpid				IN trading partner id to lock with
--	p_tpcid				IN trading partner contact id to lock with
--	x_return_status		OUT 0 for success, 1 for error
--	x_return_code		OUT returned error code, or SUCCESS
--
--  COMMENT: If the bid is not locked by another user, it is locked.
-- ======================================================================
PROCEDURE lock_draft
(
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_tpid				IN pon_bid_headers.trading_partner_id%TYPE,
	p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code 		OUT NOCOPY VARCHAR2
) IS
	l_draft_locked		pon_bid_headers.draft_locked%TYPE;
	l_tpid				pon_bid_headers.trading_partner_id%TYPE;
	l_tpcid				pon_bid_headers.trading_partner_contact_id%TYPE;
BEGIN

	-- pull up draft lock info
	SELECT draft_locked, draft_locked_by, draft_locked_by_contact_id
	INTO l_draft_locked, l_tpid, l_tpcid
	FROM pon_bid_headers
	WHERE bid_number = p_bid_number;

	-- If the draft is locked by another user, return an error
	IF (l_draft_locked = 'Y' AND (p_tpid <> l_tpid OR p_tpcid <> l_tpcid)) THEN

		x_return_status := 1;
		x_return_code := 'DRAFT_LOCK_ERR';
		RETURN;

	-- If the draft is not locked, lock it
	ELSIF (l_draft_locked = 'N') THEN

		UPDATE pon_bid_headers
		SET draft_locked = 'Y',
			draft_locked_by = p_tpid,
			draft_locked_by_contact_id = p_tpcid,
			draft_locked_date = sysdate
		WHERE bid_number = p_bid_number;

	END IF;

	x_return_status := 0;
	x_return_code := 'SUCCESS';

END lock_draft;

-- ======================================================================
-- PROCEDURE:	CHECK_AMENDMENTS_ACKED  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--	p_tpid				IN trading partner id of supplier
--	p_tpcid				IN trading partner contact id of supplier
--	x_return_status		OUT 0 for success, 1 for error
--	x_return_code		OUT returned error code, or SUCCESS
--
--  COMMENT: Determines if all amendments on the current round have been acknowledged
-- ======================================================================
PROCEDURE check_amendments_acked
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_tpid				IN pon_auction_headers_all.trading_partner_id%TYPE,
	p_tpcid				IN pon_auction_headers_all.trading_partner_contact_id%TYPE,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code 		OUT NOCOPY VARCHAR2
) IS
	l_orig_amend_id		pon_auction_headers_all.auction_header_id_orig_amend%TYPE;
	l_amend_not_acked	VARCHAR2(1);
BEGIN

	-- Get the original amendments auction header id
	SELECT ah.auction_header_id_orig_amend
	INTO l_orig_amend_id
	FROM pon_auction_headers_all ah
	WHERE ah.auction_header_id = p_auc_header_id;

	-- There must be as many acknowledgements as amendments
	SELECT decode(count(rownum), 0, 'N', 'Y')
	INTO l_amend_not_acked
	FROM pon_auction_headers_all ah, pon_acknowledgements ac
	WHERE ah.auction_header_id_orig_amend = l_orig_amend_id
		AND ah.auction_status IN ('AMENDED', 'ACTIVE')
		-- ignore the original amendment
		AND ah.amendment_number > 0
		AND ac.auction_header_id (+) = ah.auction_header_id
		AND ac.trading_partner_id (+) = p_tpid
		AND ac.trading_partner_contact_id (+)= p_tpcid
		AND ac.acknowledgement_response IS null;

	IF (l_amend_not_acked = 'Y') THEN
		x_return_status := 1;
		x_return_code := 'NEED_ACKNOWLEDGE';
		RETURN;
	END IF;

	x_return_status := 0;
	x_return_code := 'SUCCESS';

END check_amendments_acked;

-- ======================================================================
-- PROCEDURE:	VALIDATE_SITE  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--	p_tpid				IN trading partner id of supplier
--	p_vensid			IN vendor site to place a bid for
--	p_venscode			IN corresponding vendor site code
--	x_return_status		OUT 0 for success, 1 for error
--	x_return_code		OUT returned error code, or SUCCESS
--
--  COMMENT: Determine if the vensid, venscode combination can bid on the negotiation
-- ======================================================================
PROCEDURE validate_site
(
	p_auc_header_id		IN pon_bidding_parties.auction_header_id%TYPE,
	p_tpid				IN pon_bidding_parties.trading_partner_id%TYPE,
	p_vensid			IN pon_bidding_parties.vendor_site_id%TYPE,
	p_venscode			IN pon_bidding_parties.vendor_site_code%TYPE,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY VARCHAR2
) IS
	CURSOR sites IS
		SELECT vendor_site_id id, vendor_site_code code
		FROM pon_bidding_parties
		WHERE auction_header_id = p_auc_header_id
			AND trading_partner_id = p_tpid;

	l_sites_invited		BOOLEAN DEFAULT false;
	l_site_valid		BOOLEAN DEFAULT false;

BEGIN

	-- Look through the invited sites for this auction
	FOR site IN sites LOOP
		IF (site.id > 0) THEN
			l_sites_invited := true;
			IF (p_vensid = site.id /*AND p_venscode = site.code*/) THEN
				l_site_valid := true;
			END IF;
		END IF;
	END LOOP;

	-- If multiple sites were invited then, if a site id was specified,
	-- return an error if it was not invited. Else, indicate that
	-- a site id needs to be specified
	IF (l_sites_invited) THEN
		IF (p_vensid > 0) THEN
			IF (NOT l_site_valid) THEN
				x_return_status := 1;
				x_return_code := 'INVALID_VENDOR_SITE';
				RETURN;
			END IF;
		ELSE
			x_return_status := 1;
			x_return_code := 'PICK_VENDOR_SITE';
			RETURN;
		END IF;
	END IF;

	x_return_status := 0;
	x_return_code := 'SITE_VALID';

END validate_site;

-- ======================================================================
-- PROCEDURE:	IS_BIDDING_ALLOWED  PUBLIC
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--	p_tpid				IN trading partner id of supplier
--	p_tpcid				IN trading partner contact id of supplier
--	p_vensid			IN vendor site to place a bid for
--	p_venscode			IN corresponding vendor site code
--	p_buyer_user		IN determines if surrogate bid
--	p_evaluator_id		IN evaluator user id
--	p_eval_flag		IN flag indicating if the response is an evaluation
--	p_action_code		IN determines if certain validation should be suppressed
--	x_return_status		OUT 0 for success, 1 for error
--	x_return_code		OUT returned error code, or SUCCESS
--
--  COMMENT: Determine if the bidding action specified by action code can
--			be completed at this time.
-- ======================================================================
PROCEDURE is_bidding_allowed
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_tpid				IN pon_bid_headers.trading_partner_id%TYPE,
	p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE,
	p_vensid			IN pon_bid_headers.vendor_site_id%TYPE,
	p_venscode			IN pon_bid_headers.vendor_site_code%TYPE,
	p_buyer_user		IN VARCHAR2,
	---------- Supplier Management: Supplier Evaluation ----------
	p_evaluator_id		IN pon_bid_headers.evaluator_id%TYPE,
	p_eval_flag		IN VARCHAR2,
	--------------------------------------------------------------
	p_action_code		IN VARCHAR2,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY VARCHAR2
) IS
	l_current_date		TIMESTAMP;
    l_bid_number		NUMBER;
	l_view_by_date		pon_auction_headers_all.view_by_date%TYPE;
	l_open_date			pon_auction_headers_all.open_bidding_date%TYPE;
	l_close_date		pon_auction_headers_all.close_bidding_date%TYPE;
	l_auction_status	pon_auction_headers_all.auction_status%TYPE;
	l_award_status		pon_auction_headers_all.award_status%TYPE;
	l_bid_list_type		pon_auction_headers_all.bid_list_type%TYPE;
	l_invited_flag		VARCHAR2(1);
	l_bid_freq_code		pon_auction_headers_all.bid_frequency_code%TYPE;
	l_has_draft_flag	VARCHAR2(1);
	l_has_bid_flag		VARCHAR2(1);
	l_has_surrog_flag	VARCHAR2(1);
	l_auction_paused	VARCHAR2(1);
	l_orig_amend_id		pon_auction_headers_all.auction_header_id%TYPE;
	l_supp_end_date		TIMESTAMP;
	l_eval_flag             pon_bid_headers.evaluation_flag%TYPE := nvl(p_eval_flag,'N');
BEGIN

	----------------------- Supplier Management: Supplier Evaluation -----------------------
	-- Modified the if condition to only do the validate_site for non-evaluation response --
	----------------------------------------------------------------------------------------
	-- Verify that a valid site id has been specified if not loading a bid
	IF (p_action_code <> 'LOAD_BID' AND
	    p_action_code <> 'LOAD_DRAFT' AND
	    l_eval_flag = 'N') THEN
		validate_site(p_auc_header_id, p_tpid, p_vensid, p_venscode, x_return_status, x_return_code);

		IF (x_return_status = 1) THEN
			-- return status and code already set
			RETURN;
		END IF;
	END IF;

	BEGIN
		-- select the various values
		SELECT 	sysdate,
				nvl(ah.view_by_date, ah.open_bidding_date),
				ah.open_bidding_date,
				ah.close_bidding_date,
				ah.auction_status,
				nvl(ah.award_status, 'NO'),
				ah.bid_list_type,
				ah.bid_frequency_code,
				ah.auction_header_id_orig_amend,
				nvl(ah.is_paused, 'N')
		INTO 	l_current_date,
				l_view_by_date,
				l_open_date,
				l_close_date,
				l_auction_status,
				l_award_status,
				l_bid_list_type,
				l_bid_freq_code,
				l_orig_amend_id,
				l_auction_paused
		FROM pon_auction_headers_all ah
		WHERE auction_header_id = p_auc_header_id;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_return_status := 1;
			x_return_code := 'INVALID_HEADER_ID';
			RETURN;
	END;


	-- View by date (or open date if null) should be reached
	IF (l_current_date < l_view_by_date) THEN
		x_return_status := 1;
		x_return_code := 'AUCTION_NOT_VIEW';
		RETURN;
	END IF;

	-- Auction should not be cancelled
	IF (l_auction_status = 'CANCELLED') THEN
		x_return_status := 1;
		x_return_code := 'AUCTION_CANCELLED';
		RETURN;
	END IF;

    -- Auction should not have been deleted
	IF (l_auction_status = 'DELETED') THEN
		x_return_status := 1;
		x_return_code := 'AUCTION_DELETED';
		RETURN;
	END IF;

	-- When saving bid
	IF (p_action_code = 'SAVE_BID') THEN

		-- Auction should be open
		IF (l_current_date < l_open_date) THEN
			x_return_status := 1;
			x_return_code := 'AUCTION_NOT_OPEN';
			RETURN;
		END IF;

		-- Auction should not be paused
		IF (l_auction_status = 'PAUSED') THEN
			x_return_status := 1;
			x_return_code := 'AUCTION_PAUSED';
			RETURN;
		END IF;

		-- make sure there is a draft that we're trying
		-- to publish
		BEGIN
			SELECT bid_number
			INTO l_bid_number
			FROM pon_bid_headers bh
			WHERE bh.auction_header_id = p_auc_header_id
				AND bh.trading_partner_id = p_tpid
				--AND bh.trading_partner_contact_id = p_tpcid    -- Modified for ER: Supplier Management: Supplier Evaluation
				AND ((l_eval_flag = 'N' AND bh.trading_partner_contact_id = p_tpcid) OR
				     (l_eval_flag = 'Y' AND bh.evaluator_id = p_evaluator_id))
				AND bh.vendor_site_id = p_vensid
				AND bh.bid_status = 'DRAFT'
				AND nvl(bh.evaluation_flag, 'N') = l_eval_flag;    -- Added for ER: Supplier Management: Supplier Evaluation

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_return_status := 1;
				x_return_code := 'NO_DRAFT_BID';
				RETURN;
		END;

		-- Supplier should not be invalid
		BEGIN
			SELECT nvl(pov.end_date_active, sysdate)
			INTO l_supp_end_date
			FROM pon_bid_headers bh, po_vendors pov
			WHERE bh.auction_header_id = p_auc_header_id
				AND bh.trading_partner_id = p_tpid
				--AND bh.trading_partner_contact_id = p_tpcid    -- Modified for ER: Supplier Management: Supplier Evaluation
				AND ((l_eval_flag = 'N' AND bh.trading_partner_contact_id = p_tpcid) OR
				     (l_eval_flag = 'Y' AND bh.evaluator_id = p_evaluator_id))
				AND bh.vendor_site_id = p_vensid
				AND bh.bid_status = 'DRAFT'
				AND pov.vendor_id = bh.vendor_id
				AND nvl(bh.evaluation_flag, 'N') = l_eval_flag;    -- Added for ER: Supplier Management: Supplier Evaluation

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				l_supp_end_date := null;
		END;

		------------------------ Supplier Management: Supplier Evaluation ------------------------

		-- If l_supp_end_date is null, bid might be for prospective supplier
		IF (l_supp_end_date IS null) THEN
			BEGIN
				SELECT sysdate
				INTO l_supp_end_date
				FROM pon_bid_headers bh, pos_supplier_registrations psr
				WHERE bh.auction_header_id = p_auc_header_id
				  AND bh.trading_partner_id = p_tpid
				  AND psr.supplier_reg_id = bh.trading_partner_id
				  AND psr.registration_status in ('RIF_SUPPLIER', 'PENDING_APPROVAL') -- Bug 9037236
				  AND ((l_eval_flag = 'N' AND bh.trading_partner_contact_id = p_tpcid) OR
				       (l_eval_flag = 'Y' AND bh.evaluator_id = p_evaluator_id))
				  AND bh.bid_status = 'DRAFT'
				  AND bh.vendor_id = -1
				  AND bh.vendor_site_id = -1
				  AND nvl(bh.evaluation_flag, 'N') = l_eval_flag;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_supp_end_date := null;
			END;
		END IF;
		------------------------------------------------------------------------------------------

		IF (l_supp_end_date IS null OR l_supp_end_date < l_current_date) THEN
			x_return_status := 1;
			x_return_code := 'INACTIVE_SUPPLIER_ERROR';
			RETURN;
		END IF;

	END IF;

	-- Check auction close date (unless the auction is paused)
	IF (l_auction_paused <> 'Y' AND l_close_date < l_current_date) THEN

		-- Auction should not be closed if not a buyer
		-- Bug 8992891: Modify the if condition so that Enter Evaluation is still available after closing RFI
		IF (p_buyer_user = 'N' AND l_eval_flag = 'N') THEN
			x_return_status := 1;
			x_return_code := 'AUCTION_CLOSED';
			RETURN;
		-- Award process should not be started if buyer
		ELSIF (l_award_status <> 'NO') THEN
			x_return_status := 1;
			x_return_code := 'AUCTION_AWARD_STARTED';
			RETURN;
		END IF;
	END IF;

	-- If private auction, check if supplier is invited
	IF (l_bid_list_type = 'PRIVATE_BID_LIST') THEN

		-- Do an existence check
		SELECT decode(count(auction_header_id), 0, 'N', 'Y')
		INTO l_invited_flag
		FROM pon_bidding_parties
		WHERE auction_header_id = p_auc_header_id
			-- AND trading_partner_id = p_tpid;    -- Modified for ER: Supplier Management: Supplier Evaluation
			AND ((trading_partner_id IS NOT NULL AND trading_partner_id = p_tpid) OR
			     (trading_partner_id IS NULL AND requested_supplier_id = p_tpid));

		IF (l_invited_flag = 'N') THEN
			x_return_status := 1;
			x_return_code := 'NOT_INVITED';
			RETURN;
		END IF;
	END IF;

	-- Check if single best bid auction
	IF (l_bid_freq_code = 'SINGLE_BID_ONLY' AND l_eval_flag = 'N') THEN    -- Modified for ER: Supplier Management: Supplier Evaluation

		-- Do an existence check
		SELECT decode(count(auction_header_id), 0, 'N', 'Y')
		INTO l_has_bid_flag
		FROM pon_bid_headers
		WHERE auction_header_id = p_auc_header_id
			AND trading_partner_id = p_tpid
			AND vendor_site_id = p_vensid
			AND bid_status = 'ACTIVE'
			AND nvl(evaluation_flag, 'N') = 'N';    -- Added for ER: Supplier Management: Supplier Evaluation

		IF (l_has_bid_flag = 'Y') THEN
			x_return_status := 1;
			x_return_code := 'SINGLE_BEST_BID';
			RETURN;
		END IF;

		-- Do an existence check
               	-- bug 5041654
               	-- if we are loading a bid, we do not need
               	-- to check whether some other user already has a draft bid
               	-- in case of a single-best bid auction, as it is quite rare occurence
		-- in R12 that 2 users from same company will click 'create bid' at the same
		-- time. We will have this check during submit bid anyways

		SELECT decode(count(auction_header_id), 0, 'N', 'Y')
		INTO l_has_draft_flag
		FROM pon_bid_headers
		WHERE auction_header_id = p_auc_header_id
			AND trading_partner_id = p_tpid
			AND trading_partner_contact_id <> p_tpcid
			AND vendor_site_id = p_vensid
			AND bid_status = 'DRAFT'
			AND nvl(evaluation_flag, 'N') = 'N';    -- Added for ER: Supplier Management: Supplier Evaluation

		IF (l_has_draft_flag = 'Y' AND
		    p_action_code <> 'LOAD_DRAFT') THEN
			x_return_status := 1;
			x_return_code := 'OTHER_USERS_DRAFT_SBB';
			RETURN;
		END IF;
	END IF;

	------------------------- Supplier Management: Supplier Evaluation -------------------------
	-- Added the if condition to only do the following validation for non-evaluation response --
	--------------------------------------------------------------------------------------------
	IF (l_eval_flag = 'N') THEN
		-- Check if a buyer/supplier has already placed a bid on the round
		-- I.e. check for surrog bid if supplier, or a supplier bid if buyer
		SELECT decode(count(bh.auction_header_id), 0, 'N', 'Y')
		INTO l_has_surrog_flag
		FROM pon_bid_headers bh, pon_auction_headers_all ah
		WHERE ah.auction_header_id_orig_amend = l_orig_amend_id
			AND bh.auction_header_id = ah.auction_header_id
			AND bh.trading_partner_id = p_tpid
			AND bh.trading_partner_contact_id = p_tpcid
			AND nvl(bh.surrog_bid_flag, 'N') = decode(p_buyer_user, 'Y', 'N', 'Y')
			AND nvl(bh.evaluation_flag, 'N') = 'N';    -- Added for ER: Supplier Management: Supplier Evaluation

		IF (l_has_surrog_flag = 'Y') THEN
			IF (p_buyer_user = 'Y') THEN
				x_return_status := 1;
				x_return_code := 'SURROG_BID_ERROR_BUYER';
			ELSE
				x_return_status := 1;
				x_return_code := 'SURROG_BID_ERROR_SUPPLIER';
			END IF;
			RETURN;
		END IF;
	END IF;

	x_return_status := 0;
	x_return_code := 'SUCCESS';

END is_bidding_allowed;

-- ======================================================================
-- PROCEDURE:	GET_SOURCE_BID  PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--	p_tpid				IN trading partner id of supplier
--	p_tpcid				IN trading partner contact id of supplier
--	p_vensid			IN vendor site to place a bid for
--	p_evaluator_id		IN evaluator user id
--	p_eval_flag		IN flag indicating if the response is an evaluation
--	p_action_code		IN determines if certain validation should be suppressed
--	x_rebid_flag		OUT flag determining if rebid or not
--	x_bid_number		OUT bid number of exisiting draft on current amendment
--	x_prev_bid_number	OUT source bid number
--	x_amend_bid_def		OUT Y if source bid is on a previous amendment
--	x_round_bid_def		OUT Y if source bid is on a previous round
--	x_prev_bid_disq		OUT Y is source bid was disqualified
--	x_return_status		OUT 0 for success, 1 for error
--	x_return_code		OUT returned error code, or SUCCESS
--
--  COMMENT: Determine if a draft already exists on the current amendment.
--			If not, determines which bid to default from or to create a new draft.
--			Also checks if another user has a draft on the current amendment.
-- ======================================================================
PROCEDURE get_source_bid
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_tpid			IN pon_bid_headers.trading_partner_id%TYPE,
	p_tpcid			IN pon_bid_headers.trading_partner_contact_id%TYPE,
	p_vensid		IN pon_bid_headers.vendor_site_id%TYPE,
	---------- Supplier Management: Supplier Evaluation ----------
	p_evaluator_id		IN pon_bid_headers.evaluator_id%TYPE,
	p_eval_flag		IN VARCHAR2,
	--------------------------------------------------------------
	p_action_code		IN VARCHAR2,

	x_rebid_flag		OUT NOCOPY VARCHAR2,
	x_bid_number		OUT NOCOPY pon_bid_headers.bid_number%TYPE,
	x_prev_bid_number	OUT NOCOPY pon_bid_headers.bid_number%TYPE,
	x_amend_bid_def		OUT NOCOPY VARCHAR2,
	x_round_bid_def		OUT NOCOPY VARCHAR2,
	x_prev_bid_disq		OUT NOCOPY VARCHAR2,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY VARCHAR2
) IS
	l_source_header_id	pon_auction_headers_all.auction_header_id%TYPE;
	l_status_order		NUMBER;
	l_rel12_draft		pon_bid_headers.rel12_draft_flag%TYPE;

	l_prev_round_id		pon_auction_headers_all.auction_header_id%TYPE;
	l_orig_amend_id		pon_auction_headers_all.auction_header_id%TYPE;

	l_terms_cond_apply	VARCHAR2(1);

	l_ignored_return	pon_bid_headers.bid_number%TYPE;
  -- for the bug 14492921
  l_org_contract_status   pon_contracts.contract_status%TYPE;
  l_enabled_flag  pon_contracts.enabled_flag%TYPE;
  l_org_id  pon_auction_headers_all.org_id%TYPE;
  -- for the bug 16276305
  l_trading_partner_id pon_auction_headers_all.trading_partner_id%TYPE;
  l_count_org   NUMBER;

	-- select bids on all amendments/previous round by the current user for the current site
	CURSOR current_users_bids IS
		SELECT bh.bid_number,
			bh.auction_header_id,
			decode(bh.bid_status, 'DRAFT', 1, 'ACTIVE', 2,
				'RESUBMISSION', 3, 'DISQUALIFIED', 4) status_order,
			decode(bh.bid_status, 'ACTIVE',
				decode(bh.auction_header_id, p_auc_header_id, 'Y', 'N'), 'N') rebid_flag,
			decode(ah.auction_header_id_orig_amend, l_orig_amend_id, 'N', 'Y') prev_round_def,
			decode(ah.auction_header_id, p_auc_header_id, 'N',
				decode(ah.auction_header_id_orig_amend, l_orig_amend_id, 'Y', 'N')) prev_amend_def,

			decode(bh.bid_status, 'DISQUALIFIED', 'Y', 'N') prev_bid_disq,
			nvl(bh.rel12_draft_flag, 'N') rel12_draft_flag
		FROM pon_bid_headers bh, pon_auction_headers_all ah
		WHERE
			-- look at all amendments on the current round
			(ah.auction_header_id_orig_amend = l_orig_amend_id
			-- look at all amendments on the previous round
				OR ah.auction_header_id_orig_amend = l_prev_round_id)
			AND bh.auction_header_id = ah.auction_header_id
			AND bh.trading_partner_id = p_tpid
			-- AND bh.trading_partner_contact_id = p_tpcid    -- Modified for ER: Supplier Management: Supplier Evaluation
			AND ((p_eval_flag = 'N' AND bh.trading_partner_contact_id = p_tpcid) OR
			     (p_eval_flag = 'Y' AND bh.evaluator_id = p_evaluator_id))
			AND nvl(bh.vendor_site_id, -1) = p_vensid
			-- we ignore DRAFT bids on previous rounds
			AND ((bh.bid_status = 'DRAFT'
					AND ah.auction_header_id_orig_amend = l_orig_amend_id)
				OR bh.bid_status IN ('ACTIVE', 'RESUBMISSION', 'DISQUALIFIED'))
			AND nvl(bh.evaluation_flag, 'N') = p_eval_flag    -- Added for ER: Supplier Management: Supplier Evaluation
		ORDER BY nvl(ah.auction_round_number, 1) DESC,
			ah.amendment_number DESC, status_order ASC, bh.publish_date DESC;

	-- select bids on the current amendment/previous rounds by the current user for the current site
	CURSOR other_users_bids IS
		SELECT 1 return_status,
			decode(bh.auction_header_id, p_auc_header_id,
				decode(ah.bid_frequency_code, 'SINGLE_BID_ONLY',
					decode(bh.bid_status, 'DRAFT', 'OTHER_USERS_DRAFT_SBB',
						'ACTIVE', 'SINGLE_BEST_BID'),
					decode(bh.bid_status, 'DRAFT', 'OTHER_USERS_DRAFT',
						'ACTIVE', 'OTHER_USERS_ACTIVE')),
				'OTHER_USERS_PREV_ROUND') return_code
		FROM pon_bid_headers bh, pon_auction_headers_all ah
		WHERE
			-- look at the current amendment
			(ah.auction_header_id = p_auc_header_id
				AND bh.bid_status IN ('DRAFT', 'ACTIVE')
			-- look at the previous round
				OR ah.auction_header_id_orig_amend = l_prev_round_id
					AND bh.bid_status = 'ACTIVE')
			AND bh.auction_header_id = ah.auction_header_id
			AND bh.trading_partner_id = p_tpid
			AND bh.trading_partner_contact_id <> p_tpcid
			AND nvl(bh.vendor_site_id, -1) = p_vensid
			AND nvl(bh.evaluation_flag, 'N') = 'N'    -- Added for ER: Supplier Management: Supplier Evaluation
		ORDER BY nvl(ah.auction_round_number, 1) DESC, ah.amendment_number DESC,
			decode(bh.bid_status, 'DRAFT', 1, 'ACTIVE', 2) ASC, bh.publish_date DESC;

BEGIN

	-- Get the original amendment id's for the current and prev rounds.
	-- Also check if contracts have been installed
  -- for the bug 14492921, add org_id column
  -- for the bug 16276305, add trading_partner_id column
	SELECT ah.auction_header_id_orig_amend, ah2.auction_header_id_orig_amend,
		nvl2(ah.contract_id, 'Y', 'N'),ah.org_id,ah.trading_partner_id
	INTO l_orig_amend_id, l_prev_round_id, l_terms_cond_apply,l_org_id,l_trading_partner_id
	FROM pon_auction_headers_all ah, pon_auction_headers_all ah2
	WHERE ah.auction_header_id = p_auc_header_id
		and ah2.auction_header_id (+) = ah.auction_header_id_prev_round;

	-- Retrieve the backing bid info from the cursor
	-- We only need the first such bid
	OPEN current_users_bids;
	FETCH current_users_bids
		INTO x_prev_bid_number, l_source_header_id, l_status_order,
			x_rebid_flag, x_round_bid_def, x_amend_bid_def,
			x_prev_bid_disq, l_rel12_draft;
	CLOSE current_users_bids;

	-- If the current user has a previous bid
	IF (x_prev_bid_number IS NOT null) THEN

		-- had a backing DRAFT bid
		IF (l_status_order = 1) THEN
			-- Check if the draft is on the current amendment
			IF (l_source_header_id = p_auc_header_id) THEN

				-- If it is a pre-release 12 draft, need to insert missing lines
				-- NOTE: expand_draft is batched
				IF (l_rel12_draft <> 'Y') THEN
					expand_draft(x_prev_bid_number, x_rebid_flag);
				END IF;

				-- Set return bid number. No defaulting required
				x_bid_number := x_prev_bid_number;
				x_prev_bid_number := NULL;
				x_return_status := 0;
				x_return_code := 'DRAFT';

			-- draft is on a previous amendment/round
			ELSE
				-- Need to archive the previous amend/round DRAFT bid
				UPDATE pon_bid_headers
				SET bid_status = 'ARCHIVED_DRAFT',
					last_update_date = sysdate
				WHERE bid_number = x_prev_bid_number;

				-- If pre-release 12, call handle_proxy to update price, limit_price
				-- set has_bid_flag
				IF (l_rel12_draft <> 'Y') THEN

					handle_proxy
						(p_auc_header_id,
						x_prev_bid_number,
						p_tpid,
						p_tpcid,
						p_vensid,
						---- Supplier Management: Supplier Evaluation ----
						p_evaluator_id,
						p_eval_flag,
						--------------------------------------------------
						l_ignored_return,
						x_rebid_flag);

					populate_has_bid_flag(p_auc_header_id, x_prev_bid_number);
				END IF;

				-- All flags are set; indicate defaulting is necessary
				x_return_status := 0;
				x_return_code := 'DEFAULT';
			END IF;

		-- Begin Supplier Management: Bug 12369949
		ELSIF (p_eval_flag = 'Y' AND l_status_order = 2) THEN

			IF (l_source_header_id = p_auc_header_id) THEN

				-- Update Evaluation flow

				UPDATE pon_bid_headers
				SET bid_status = 'DRAFT',
				    last_update_date = sysdate
				WHERE bid_number = x_prev_bid_number;

				x_bid_number := x_prev_bid_number;
				x_prev_bid_number := NULL;
				x_return_status := 0;
				x_return_code := 'DRAFT';
			ELSE
				x_return_status := 0;
				x_return_code := 'DEFAULT';
			END IF;

		-- End Supplier Management: Bug 12369949

		-- had a backing ACTIVE, RESUBMISSION, or DISQUALIFIED bid
		ELSE
			-- All flags are set; indicate that defaulting is necessary
			x_return_status := 0;
			x_return_code := 'DEFAULT';
		END IF;
	-- Begin Supplier Management: Supplier Evaluation
	ELSIF (p_eval_flag = 'Y') THEN
		x_return_status := 0;
		x_return_code := 'CREATE_NEW_DRAFT';
	-- End Supplier Management: Supplier Evaluation
	ELSE

		-- Retrieve other users bid info from the cursor
		-- We only need the first bid
		OPEN other_users_bids;
		FETCH other_users_bids
			INTO x_return_status, x_return_code;
		CLOSE other_users_bids;

		IF (x_return_status = 1) THEN
			RETURN;
		END IF;
    -- for the bug 14492921
    -- for the bug 14666805
    -- add NVL condition to org_id and contract_status columns
    SELECT Count(*)
    INTO l_count_org
    FROM pon_contracts
    WHERE NVL(org_id,-1) = l_org_id
    AND authoring_party_id = l_trading_partner_id
    AND internal_name = 'AUC_TAC' ;

    -- if terms and conditions not defined for the current operating unit set l_org_id to global.
    IF(l_count_org = 0) THEN l_org_id := -1;
    ELSE
      -- get the contract status for the current Operating Unit.
      -- for the bug 16276305
      -- add AUTHORING_PARTY_ID and INTERNAL_NAME conditions
      SELECT NVL(contract_status,'ACTIVE')
      INTO l_org_contract_status
      FROM pon_contracts
      WHERE NVL(org_id,-1) = l_org_id
      AND authoring_party_id = l_trading_partner_id
      AND internal_name = 'AUC_TAC'
      AND version_num = (select max(version_num) from pon_contracts where NVL(org_id,-1) = l_org_id and authoring_party_id = l_trading_partner_id and internal_name = 'AUC_TAC');

      -- If the status is not Active set l_org_id global
      IF(l_org_contract_status <> 'ACTIVE') THEN
        l_org_id := -1;
      END IF;
    END IF;

    -- for the bug 14699166
    -- check for any rows existance in pon_contracts table for l_org_id

    SELECT Count(*)
    INTO l_count_org
    FROM pon_contracts
    WHERE NVL(org_id,-1) = l_org_id
    AND authoring_party_id = l_trading_partner_id
    AND internal_name = 'AUC_TAC';

    IF(l_count_org = 0) THEN l_enabled_flag := 'N';
    ELSE
    -- Check the enbled_flag for the Max Version Num of l_org_id
      -- for the bug 16276305
      -- add AUTHORING_PARTY_ID and INTERNAL_NAME conditions
      SELECT enabled_flag
      INTO l_enabled_flag
      FROM pon_contracts pc
      WHERE NVL(org_id,-1) = l_org_id
      AND authoring_party_id = l_trading_partner_id
      AND internal_name = 'AUC_TAC'
      AND version_num = (select max(version_num) from pon_contracts where NVL(org_id,-1) = l_org_id and authoring_party_id = l_trading_partner_id and internal_name = 'AUC_TAC');
    END IF;

    -- Creating fresh bid.
		-- User must accept terms and conditions if contracts installed.
		IF ((l_enabled_flag = 'Y' OR l_enabled_flag = 'X') AND (p_eval_flag='Y' OR is_accepted_terms_cond(p_auc_header_id,l_orig_amend_id,p_tpid,p_tpcid)='N')) THEN
			x_return_status := 1;
			x_return_code := 'TO_TERMS_COND';
		ELSE
			x_return_status := 0;
			x_return_code := 'CREATE_NEW_DRAFT';
		END IF;
	END IF;

END get_source_bid;

-- ======================================================================
-- PROCEDURE:	CREATE_DEFAULTED_BID	PUBLIC
--  PARAMETERS:
--	p_new_header_id		IN auction header id of negotiation
--	p_source_bid		IN the bid to default from
--	x_bid_number		OUT bid number of draft loaded or created
--	x_return_status		OUT 0 for success, 1 for error
--	x_return_code		OUT returned error code, or SUCCESS
--
--  COMMENT: create a new draft on p_auc_header_id, defaulting from
--			p_source_bid
-- ======================================================================
PROCEDURE create_defaulted_draft
(
	p_new_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_source_bid		IN pon_bid_headers.bid_number%TYPE,
	x_bid_number		OUT NOCOPY pon_bid_headers.bid_number%TYPE
) IS
	l_tpid				pon_bid_headers.trading_partner_id%TYPE;
	l_tpcid				pon_bid_headers.trading_partner_contact_id%TYPE;
	l_tpname			pon_bid_headers.trading_partner_name%TYPE;
	l_tpcname			pon_bid_headers.trading_partner_contact_name%TYPE;
	l_userid			pon_bid_headers.created_by%TYPE;
	l_venid				pon_bid_headers.vendor_id%TYPE;
	l_vensid			pon_bid_headers.vendor_site_id%TYPE;
	l_venscode			pon_bid_headers.vendor_site_code%TYPE;
	l_buyer_user		VARCHAR2(1);
	l_auctpid			pon_bid_headers.surrog_bid_created_tp_id%TYPE;
	l_auctpcid			pon_bid_headers.surrog_bid_created_contact_id%TYPE;

	---------- Supplier Management: Supplier Evaluation ----------
	l_evaluator_id		pon_bid_headers.evaluator_id%TYPE;
	l_eval_flag		pon_bid_headers.evaluation_flag%TYPE;
	--------------------------------------------------------------

	l_rebid_flag		VARCHAR2(1);
	l_prev_bid_disq		VARCHAR2(1);
	l_new_round_or_amended  VARCHAR2(1);
        l_return_status         NUMBER;
        l_return_code           VARCHAR2(30);
BEGIN

	-- The bid the user is currently working with has been obsoleted
	-- so create a new draft, defaulting from the previous bid.
	-- Eg. If the user clicks bid by spreadsheet from the manage draft
	-- responses page, but a new amendment has been created.

	l_rebid_flag := 'N';
	l_prev_bid_disq := 'N';

    -- The following flag is needed for payments copy
    -- This sets to y if defaulting is happening because the
    -- negotiation being amended or new round started
    l_new_round_or_amended := 'Y';

	-- Select out the header values from the previous draft
	SELECT bh.trading_partner_id,
		bh.trading_partner_contact_id,
		bh.trading_partner_name,
		bh.trading_partner_contact_name,
		bh.created_by,
		bh.vendor_id,
		bh.vendor_site_id,
		bh.vendor_site_code,
		bh.surrog_bid_created_tp_id,
		bh.surrog_bid_created_contact_id,
		bh.surrog_bid_flag,
		---- Supplier Management: Supplier Evaluation ----
		bh.evaluator_id,
		bh.evaluation_flag
		--------------------------------------------------
	INTO l_tpid,
		l_tpcid,
		l_tpname,
		l_tpcname,
		l_userid,
		l_venid,
		l_vensid,
		l_venscode,
		l_auctpid,
		l_auctpcid,
		l_buyer_user,
		---- Supplier Management: Supplier Evaluation ----
		l_evaluator_id,
		l_eval_flag
		--------------------------------------------------
	FROM pon_bid_headers bh
	WHERE bh.bid_number = p_source_bid;

	-- Create the new bid
	create_new_draft_bid
		(p_new_header_id,
		p_source_bid,
		l_tpid,
		l_tpcid,
		l_tpname,
		l_tpcname,
		l_userid,
		l_venid,
		l_vensid,
		l_venscode,
		l_auctpid,
		l_auctpcid,
		l_buyer_user,
		---- Supplier Management: Supplier Evaluation ----
		l_evaluator_id,
		l_eval_flag,
		--------------------------------------------------
		l_new_round_or_amended,
		l_rebid_flag,
		l_prev_bid_disq,
		x_bid_number,
                l_return_status,
                l_return_code);

	-- Update the status of the previous bid
	-- NOTE: if this procedure is used for cases other than spreadsheet upload
	-- on a DRAFT after an amendment, the status will need to be set correctly
	UPDATE pon_bid_headers bh
	SET bh.bid_status = decode('DRAFT', 'ARCHIVED_DRAFT', bh.bid_status)
	WHERE bh.bid_number = p_source_bid;

END create_defaulted_draft;

-- ======================================================================
-- PROCEDURE:	CHECK_AND_LOAD_BID	PUBLIC
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--	p_draft_number		IN non-null if a specific draft is to be loaded
--						or if the action code is CREATE_NEW_AMEND_DRAFT
--	p_tpid				IN trading partner id of supplier
--	p_tpcid				IN trading partner contact id of supplier
--	p_tpname			IN trading partner name of supplier
--	p_tpcname			IN trading partner contact name of supplier
--	p_userid			IN userid of bid creator
--	p_venid				IN vendor id
--	p_vensid			IN vendor site to place a bid for
--	p_venscode			IN corresponding vendor site code
--	p_buyer_user		IN determines if surrogate bid
--	p_auctpid			IN trading partner id of buyer if surrogate bid
--	p_auctpcid			IN trading partner contact id of buyer if surrogate bid

--	p_evaluator_id		IN evaluator user id
--	p_eval_flag		IN flag indicating if the response is an evaluation

--	x_bid_number		OUT bid number of draft loaded or created
--	x_rebid_flag		OUT flag determining if rebid or not
--	x_prev_bid_number	OUT source bid number
--	x_amend_bid_def		OUT Y if source bid is on a previous amendment
--	x_round_bid_def		OUT Y if source bid is on a previous round
--	x_prev_bid_disq		OUT Y if source bid was disqualified
--	x_edit_draft		OUT Y if we loaded an existing draft

--	p_action_code		IN determine if a special action needs to be taken
--	x_return_status		OUT 0 for success, 1 for error
--	x_return_code		OUT returned error code, or SUCCESS
--
--  COMMENT: Main procedure which determines whether a new or defaulted bid
-- 			is to be created. Or whether a draft already exists
-- ======================================================================
PROCEDURE check_and_load_bid
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_draft_number		IN pon_bid_headers.bid_number%TYPE,
	p_tpid				IN pon_bid_headers.trading_partner_id%TYPE,
	p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE,
	p_tpname			IN pon_bid_headers.trading_partner_name%TYPE,
	p_tpcname			IN pon_bid_headers.trading_partner_contact_name%TYPE,
	p_userid			IN pon_bid_headers.created_by%TYPE,
	p_venid				IN pon_bid_headers.vendor_id%TYPE,
	p_vensid			IN pon_bid_headers.vendor_site_id%TYPE,
	p_venscode			IN pon_bid_headers.vendor_site_code%TYPE,
	p_buyer_user		IN VARCHAR2,
	p_auctpid			IN pon_bid_headers.surrog_bid_created_tp_id%TYPE,
	p_auctpcid			IN pon_bid_headers.surrog_bid_created_contact_id%TYPE,

	----------- Supplier Management: Supplier Evaluation -----------
	p_evaluator_id		IN pon_bid_headers.evaluator_id%TYPE,
	p_eval_flag		IN pon_bid_headers.evaluation_flag%TYPE,
	----------------------------------------------------------------

	x_bid_number		OUT NOCOPY pon_bid_headers.bid_number%TYPE,
	x_rebid_flag		OUT NOCOPY VARCHAR2,
	x_prev_bid_number	OUT NOCOPY pon_bid_headers.bid_number%TYPE,
	x_amend_bid_def		OUT NOCOPY VARCHAR2,
	x_round_bid_def		OUT NOCOPY VARCHAR2,
	x_prev_bid_disq		OUT NOCOPY VARCHAR2,
	x_edit_draft		OUT NOCOPY VARCHAR2,

	p_action_code		IN VARCHAR2,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY VARCHAR2
) IS
	l_rel12_draft		pon_bid_headers.rel12_draft_flag%TYPE;
	l_new_round_or_amended  VARCHAR2(1);

	l_temp_num			NUMBER;
	l_eval_flag             pon_bid_headers.evaluation_flag%TYPE := nvl(p_eval_flag,'N');
BEGIN

	-- The user indicated that they want to create a fresh bid
	IF (p_action_code = 'CREATE_NEW_DRAFT') THEN

		x_rebid_flag := 'N';
		x_prev_bid_number := NULL;
		x_amend_bid_def := 'N';
		x_round_bid_def := 'N';
		x_prev_bid_disq := 'N';
		x_edit_draft := 'N';

        -- The following flag is needed for payments copy
        -- This sets to y if defaulting is happening because the
        -- negotiation being amended or new round started
        l_new_round_or_amended := 'N';

		-- Create the new bid
		create_new_draft_bid
			(p_auc_header_id,
			x_prev_bid_number,
			p_tpid,
			p_tpcid,
			p_tpname,
			p_tpcname,
			p_userid,
			p_venid,
			p_vensid,
			p_venscode,
			p_auctpid,
			p_auctpcid,
			p_buyer_user,
			---- Supplier Management: Supplier Evaluation ----
			p_evaluator_id,
			l_eval_flag,
			--------------------------------------------------
			l_new_round_or_amended,
			x_rebid_flag,
			x_prev_bid_disq,
			x_bid_number,
                        x_return_status,
                        x_return_code);

		RETURN;

	-- If we already know which draft to work with
	ELSIF (p_draft_number IS NOT null AND p_draft_number > 0) THEN

		-- Check that the draft is not locked by another user and lock it
		IF (p_buyer_user = 'Y') THEN
			lock_draft
				(p_draft_number,
				p_auctpid,
				p_auctpcid,
				x_return_status,
				x_return_code);
		-- Begin Supplier Management: Supplier Evaluation
		ELSIF (l_eval_flag = 'Y') THEN
			lock_draft
				(p_draft_number,
				p_tpid,
				p_evaluator_id,
				x_return_status,
				x_return_code);
		-- End Supplier Management: Supplier Evaluation
		ELSE
			lock_draft
				(p_draft_number,
				p_tpid,
				p_tpcid,
				x_return_status,
				x_return_code);
		END IF;

		IF (x_return_status = 1) THEN
			RETURN;
		END IF;

		-- If it is a pre-release 12 draft, we need to expand it
		SELECT nvl(bh.rel12_draft_flag, 'N') rel12_draft_flag
		INTO l_rel12_draft
		FROM pon_bid_headers bh
		WHERE bh.bid_number = p_draft_number;

		-- If the draft is pre-release 12 we need to fill in the missing lines
		IF (l_rel12_draft <> 'Y') THEN
			expand_draft(p_draft_number, x_rebid_flag);
		END IF;

		-- Finally, handle proxy bidding and copy rank
		handle_proxy
			(p_auc_header_id,
			p_draft_number,
			p_tpid,
			p_tpcid,
			p_vensid,
			---- Supplier Management: Supplier Evaluation ----
			p_evaluator_id,
			l_eval_flag,
			--------------------------------------------------
			x_prev_bid_number,
			x_rebid_flag);

		-- set flags and return values before returning
		x_bid_number := p_draft_number;
		x_amend_bid_def := 'N';
		x_round_bid_def := 'N';
		x_prev_bid_disq := 'N';
		x_edit_draft := 'Y';
		x_return_status := 0;
		x_return_code := 'SUCCESS';
		RETURN;
	END IF;

	-- We are unsure whether a draft exists or we're creating a new bid

	-- Check if all amendments have been acknowledged
	-- Bug 10027124 - only do the check if it's not evaluation
	IF (l_eval_flag = 'N') THEN

		-- Supplier Management: Bug 10378806
		--
		-- The trading_partner_contact_id is not applicable for
		-- prospective supplier, and it is populated with the negated
		-- trading_partner_id.

		IF (p_venid = -1) THEN
			check_amendments_acked(p_auc_header_id, p_tpid, -p_tpid,
				x_return_status, x_return_code);
		ELSE
			check_amendments_acked(p_auc_header_id, p_tpid, p_tpcid,
				x_return_status, x_return_code);
		END IF;
	END IF;

	IF (x_return_status = 1) THEN
		RETURN;
	END IF;

	-- Get the source bid number and other flags
	get_source_bid
		(p_auc_header_id,
		p_tpid,
		p_tpcid,
		p_vensid,
		---- Supplier Management: Supplier Evaluation ----
		p_evaluator_id,
		l_eval_flag,
		--------------------------------------------------
		p_action_code,
		x_rebid_flag,
		x_bid_number,
		x_prev_bid_number,
		x_amend_bid_def,
		x_round_bid_def,
		x_prev_bid_disq,
		x_return_status,
		x_return_code);

	IF (x_return_status = 1) THEN
		RETURN;
	END IF;

	-- If a draft exists, check that it is not locked by another user and lock it
	IF (x_return_code = 'DRAFT') THEN
		IF (p_buyer_user = 'Y') THEN
			lock_draft(x_bid_number, p_auctpid, p_auctpcid,
				x_return_status, x_return_code);
		-- Begin Supplier Management: Supplier Evaluation
		ELSIF (l_eval_flag = 'Y') THEN
			lock_draft(x_bid_number, p_tpid, p_evaluator_id,
				x_return_status, x_return_code);
		-- End Supplier Management: Supplier Evaluation
		ELSE
			lock_draft(x_bid_number, p_tpid, p_tpcid,
				x_return_status, x_return_code);
		END IF;

		IF (x_return_status = 1) THEN
			RETURN;
		END IF;

		-- Begin Supplier Management: Bug 12369949
		IF (l_eval_flag = 'Y') THEN
			DELETE FROM pon_mng_eval_bid_sections
			WHERE bid_number = x_bid_number
			  AND status_code = 'A';
		END IF;
		-- End Supplier Management: Bug 12369949

		-- set return status
		x_edit_draft := 'Y';
		x_return_status := 0;
		x_return_code := 'SUCCESS';

	-- Default the bid if necessary
	ELSIF (x_return_code = 'DEFAULT') THEN

	  -- The following flag is needed for payments copy
      -- This sets to y if defaulting is happening because the
      -- negotiation being amended or new round started

      IF (x_amend_bid_def = 'Y'  OR x_round_bid_def = 'Y') THEN
         l_new_round_or_amended := 'Y';
      ELSE
         l_new_round_or_amended := 'N';
      END IF;

		create_new_draft_bid
			(p_auc_header_id,
			x_prev_bid_number,
			p_tpid,
			p_tpcid,
			p_tpname,
			p_tpcname,
			p_userid,
			p_venid,
			p_vensid,
			p_venscode,
			p_auctpid,
			p_auctpcid,
			p_buyer_user,
			---- Supplier Management: Supplier Evaluation ----
			p_evaluator_id,
			l_eval_flag,
			--------------------------------------------------
			l_new_round_or_amended,
			x_rebid_flag,
			x_prev_bid_disq,
			x_bid_number,
                        x_return_status,
                        x_return_code);

		-- set return status
		x_edit_draft := 'N';

                -- There is already a draft created for this user. Maybe
                -- through a different session. In this case, return
                -- error MULTIPLE_REBID
                IF (x_return_status = 1) THEN
                   RETURN;
                END IF;

	-- Create a fresh bid if necessary
	ELSIF (x_return_code = 'CREATE_NEW_DRAFT') THEN

		x_rebid_flag := 'N';
		x_prev_bid_number := NULL;
		x_amend_bid_def := 'N';
		x_round_bid_def := 'N';
		x_prev_bid_disq := 'N';
		x_edit_draft := 'N';

        -- The following flag is needed for payments copy
        -- This sets to y if defaulting is happening because the
        -- negotiation being amended or new round started
        l_new_round_or_amended := 'N';

		-- Create the new bid
		create_new_draft_bid
			(p_auc_header_id,
			x_prev_bid_number,
			p_tpid,
			p_tpcid,
			p_tpname,
			p_tpcname,
			p_userid,
			p_venid,
			p_vensid,
			p_venscode,
			p_auctpid,
			p_auctpcid,
			p_buyer_user,
			---- Supplier Management: Supplier Evaluation ----
			p_evaluator_id,
			l_eval_flag,
			--------------------------------------------------
			l_new_round_or_amended,
			x_rebid_flag,
			x_prev_bid_disq,
			x_bid_number,
            x_return_status,
            x_return_code);
		RETURN;

	END IF;

	-- Finally, handle proxy bidding and copy rank
	handle_proxy
		(p_auc_header_id,
		x_bid_number,
		p_tpid,
		p_tpcid,
		p_vensid,
		---- Supplier Management: Supplier Evaluation ----
		p_evaluator_id,
		l_eval_flag,
		--------------------------------------------------
		l_temp_num,
		x_rebid_flag);

	-- We get the returned bid_number into l_temp_num because it will null
	-- out a x_prev_bid_number if it is not the rebidding case
	IF (x_prev_bid_number IS null) THEN
		x_prev_bid_number := l_temp_num;
	END IF;

END check_and_load_bid;

-- ======================================================================
-- FUNCTION:	GET_SOURCE_BID_FOR_SPREADSHEET
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--  	p_prev_round_auc_header_id  IN auction header id of prev round negotiation
--	p_tpid			IN trading partner id of supplier
--	p_tpcid			IN trading partner contact id of supplier
--  	p_auc_header_id_orig_amend IN auction header id of original amendment
--	p_amendment_number	IN amendment number
--	p_vensid		IN vendor site to place a bid for
--
--  COMMENT: This function is only used in spreadsheet export case.
--           Determine whether there are any bids existing for the current amendment.
--	     If not, determines whether there are any bids in previous amendment
--           of current round; If still not, check whether there is an active bid
--           from previous round
-- ======================================================================
FUNCTION get_source_bid_for_spreadsheet
(
	p_auc_header_id			IN pon_auction_headers_all.auction_header_id%TYPE,
	p_prev_round_auc_header_id 	IN pon_auction_headers_all.auction_header_id_prev_round%TYPE,
	p_tpid				IN pon_bid_headers.trading_partner_id%TYPE,
	p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE,
	p_auc_header_id_orig_amend 	IN pon_auction_headers_all.auction_header_id_orig_amend%TYPE,
	p_amendment_number		IN pon_auction_headers_all.amendment_number%TYPE,
	p_vensid			IN pon_bid_headers.vendor_site_id%TYPE

) RETURN NUMBER IS

     CURSOR current_amendment_bids IS
	select bid_number
		from pon_bid_headers
		where auction_header_id = p_auc_header_id
		and trading_partner_id = p_tpid
		and trading_partner_contact_id = p_tpcid
		and nvl(vendor_site_id, -1) = nvl(p_vensid, -1)
		and bid_status in ('DRAFT', 'ACTIVE', 'DISQUALIFIED')
		order by decode(bid_status, 'DRAFT', 3,
				'ACTIVE', 2,
				'DISQUALIFIED', 1) desc, publish_date desc;

     CURSOR previous_amendments_bids IS
	 select bh.bid_number
		from
		pon_bid_headers bh,
		pon_auction_headers_all ah
		where
		bh.auction_header_id = ah.auction_header_id
		and ah.auction_header_id_orig_amend = p_auc_header_id_orig_amend
		and bh.trading_partner_id = p_tpid
		and bh.trading_partner_contact_id = p_tpcid
		and nvl(bh.vendor_site_id, -1) = nvl(p_vensid, -1)
		and bh.bid_status in ('DRAFT', 'RESUBMISSION', 'DISQUALIFIED')
		order by ah.amendment_number desc,
			decode(bh.bid_status, 'DRAFT', 3,
   				'RESUBMISSION' , 2,
				'DISQUALIFIED', 1) desc,
			bh.publish_date desc;

     x_prev_bid_number  NUMBER := -1;

BEGIN

     OPEN current_amendment_bids;
     FETCH current_amendment_bids into x_prev_bid_number;

     IF (current_amendment_bids%NOTFOUND) THEN

	-- try to find a previous bid from previous amendments in the current round
	IF (p_amendment_number is not null AND p_amendment_number >=1) THEN

		OPEN previous_amendments_bids;
		FETCH previous_amendments_bids into x_prev_bid_number;
		IF (previous_amendments_bids%NOTFOUND) THEN
			x_prev_bid_number := -1;
		END IF;
		CLOSE previous_amendments_bids;

	ELSIF (p_prev_round_auc_header_id is not null) THEN

	  -- try to find an active bid from previous round

		select max(bid_number) prev_round_bid
		into x_prev_bid_number
		from pon_bid_headers bh,
	     	     pon_auction_headers_all ah,
     		     pon_auction_headers_all ah2
		where bh.auction_header_id = ah.auction_header_id
		and ah.auction_header_id_orig_amend = ah2.auction_header_id_orig_amend
		and ah2.auction_header_id = p_prev_round_auc_header_id
		and bh.trading_partner_id = p_tpid
		and bh.trading_partner_contact_id = p_tpcid
		and bh.bid_status in ('ACTIVE', 'RESUBMISSION', 'DISQUALIFIED')
		and nvl(bh.vendor_site_id, -1) = nvl(p_vensid, -1);

	END IF;
     END IF;

     CLOSE current_amendment_bids;

     IF (x_prev_bid_number is null) THEN
	x_prev_bid_number := -1;
     END IF;

     return x_prev_bid_number;

END GET_SOURCE_BID_FOR_SPREADSHEET;

--------------------------------------------------------------------------------
--                      can_supplier_create_payments                         --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: can_supplier_create_payments
--
-- Type    : Private
--
-- Pre-reqs: None
--
-- Function: This API is called by the Response Import Spreadsheet page.
--           It determines if there are any lines in the RFQ that can have payments.
--           If yes, then the "Pay Items" will be one of the option in the Import
--           and Export poplists
--
--
-- Parameters:
--
--              p_auction_header_id       IN      NUMBER
--                   Auction header id - required
--              p_bid_number       IN      NUMBER
--                   Bid Number - required
--              p_po_style_id       IN      NUMBER
--                   PO Style Id - required
--
--
--              x_can_create_payments OUT      VARCHAR2
--                   Returns Y if payments can be created for atleast one of the
--                   line to which supplier has access. Otherwise Returns N
--
--
-- End of Comments
--------------------------------------------------------------------------------
-----
PROCEDURE  can_supplier_create_payments(
				       p_auction_header_id       IN        NUMBER,
				       p_bid_number              IN        NUMBER,
				       x_can_create_payments OUT NOCOPY VARCHAR2) IS
BEGIN
	  x_can_create_payments := 'N';

	    -- Check if there are any lines OTHER THAN GROUP, LOT_LINE and to which supplier does not have access
	    -- If there are lines then l_can_create_payment = 'Y'
	    -- Else l_can_create_payment = 'N';

	    SELECT 'Y'
	      INTO x_can_create_payments
	      FROM dual
	     WHERE EXISTS (SELECT 1
	                     FROM PON_AUCTION_ITEM_PRICES_ALL pai,
	                          PON_BID_ITEM_PRICES pbi,
	                          PON_AUCTION_HEADERS_ALL pah
			        WHERE pai.auction_header_id = p_auction_header_id
	                      AND pai.group_type NOT IN ('GROUP','LOT_LINE')
	                      AND pbi.auction_header_id = pai.auction_header_id
	                      AND pbi.line_number = pai.line_number
	                      AND pbi.bid_number = p_bid_number
	                      AND pah.auction_header_id = pai.auction_header_id
	                      AND pah.progress_payment_type <> 'NONE'
						  AND pah.contract_type = 'STANDARD');
  EXCEPTION
	  WHEN NO_DATA_FOUND
	   THEN
	     x_can_create_payments := 'N';
	  WHEN OTHERS THEN
	       RAISE;
END can_supplier_create_payments;

--------------------------------------------------------------------------------
--                      apply_price_factors                                   --
--------------------------------------------------------------------------------
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
  * p_unit_price - bid line price in auction currency
  * p_quantity - bid quantity for the current line
*/
FUNCTION apply_price_factors(p_auction_header_id	IN NUMBER,
                             p_prev_auc_active_bid_number  IN NUMBER,
                             p_line_number          IN NUMBER,
                             p_unit_price 			IN NUMBER,
                             p_quantity 			IN NUMBER
                             )
RETURN NUMBER IS

  l_api_name CONSTANT VARCHAR2(30) := 'apply_price_factors';
  l_progress VARCHAR2(100) := '0';

  l_total_price NUMBER;
  l_bid_line_pf_unit_price NUMBER;
  l_auc_pf_unit_price NUMBER;

  l_contract_type pon_auction_headers_all.contract_type%TYPE;
  l_supplier_view_type pon_auction_headers_all.supplier_view_type%TYPE;

  l_bid_auction_curr_unit_price pon_bid_item_prices.unit_price%TYPE;
  l_bid_quantity pon_bid_item_prices.quantity%TYPE;

  l_is_spo_transformed VARCHAR2(1);

BEGIN

-- auction information that we need

l_progress := '10: fetch auction information';

SELECT  contract_type,
        supplier_view_type
INTO 	l_contract_type,
	    l_supplier_view_type
FROM	pon_auction_headers_all
WHERE	auction_header_id = p_auction_header_id;



l_progress := '20: perform SPO/TRANSFORMED check';

IF (l_supplier_view_type = 'TRANSFORMED' AND
    l_contract_type = 'STANDARD') THEN
      l_is_spo_transformed := 'Y';
ELSE
      l_is_spo_transformed := 'N';
END IF;

-- calculate the buyer price factors

l_progress := '30: calculate unit price plus buyer price factors';

BEGIN

SELECT  (p_unit_price * ppsf.percentage) +
        ppsf.unit_price +
        ppsf.fixed_amount/decode(l_is_spo_transformed,
                                 'Y', nvl(p_quantity, 1),
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
  	l_auc_pf_unit_price := p_unit_price;

END;

-- calculate the supplier price factors

l_progress := '40: calculate supplier price factors';

SELECT nvl(sum(decode(spf.pricing_basis,
                     'PER_UNIT', spf.auction_currency_value,
                     'PERCENTAGE',  spf.auction_currency_value/100 * p_unit_price,
                     (spf.auction_currency_value / decode(l_is_spo_transformed,
                                                      'Y', nvl(p_quantity, 1),
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

-- total price in auction currency
l_progress := '60: return total price in auction currency';
l_total_price := l_bid_line_pf_unit_price + l_auc_pf_unit_price;

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

         END IF;
      END IF;
      return NULL;
END apply_price_factors;

FUNCTION is_accepted_terms_cond(p_auction_header_id  IN NUMBER,
                                p_auction_header_id_orig_amend  IN NUMBER,
                                p_trading_partner_id number,
                                p_trading_partner_contact_id number
                             )
RETURN VARCHAR2 IS
l_count NUMBER;

BEGIN

SELECT Count(*) INTO l_count
FROM pon_supplier_activities
WHERE auction_header_id_orig_amend = p_auction_header_id_orig_amend
AND last_activity_code = 'ACCEPT_TERMSCOND'
AND  trading_partner_id = p_trading_partner_id
AND trading_partner_contact_id = p_trading_partner_contact_id;

IF (l_count>0) THEN
RETURN 'Y';
ELSE
RETURN 'N';
END IF;

EXCEPTION

WHEN OTHERS THEN
 RETURN 'N';

END is_accepted_terms_cond;

END PON_BID_DEFAULTING_PKG;

/
