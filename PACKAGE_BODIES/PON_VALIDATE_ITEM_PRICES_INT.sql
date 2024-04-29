--------------------------------------------------------
--  DDL for Package Body PON_VALIDATE_ITEM_PRICES_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_VALIDATE_ITEM_PRICES_INT" as
-- $Header: PONVAIPB.pls 120.31.12010000.6 2013/03/27 18:57:57 pamaniko ship $

g_module_prefix        CONSTANT VARCHAR2(50) := 'pon.plsql.PON_VALIDATE_ITEM_PRICES_INT.';

PROCEDURE validateAwardBid(p_batch_Id         IN      NUMBER,
                           p_spreadsheet_type IN VARCHAR2);

PROCEDURE validateAwardBidXML(p_batch_id NUMBER,
        x_return_status         OUT NOCOPY NUMBER,
        x_return_code           OUT NOCOPY VARCHAR2) IS

l_has_errors VARCHAR2(1);
l_num_of_award_lines NUMBER;

BEGIN

  select count(*)
  into   l_num_of_award_lines
  from   pon_award_items_interface
  where  batch_id = p_batch_id
  and    rownum = 1;

  IF (l_num_of_award_lines = 0) THEN

    x_return_status := 0;
    x_return_code := 'SUCCESS';

    RETURN;

  END IF;

  validateAwardBid(p_batch_id, PON_AWARD_PKG.g_xml_upload_mode);

  -- Check if any errors were present
  SELECT decode(count(interface_type), 0, 'N', 'Y')
  INTO l_has_errors
  FROM pon_interface_errors
  WHERE batch_id = p_batch_id
     AND rownum = 1;

  IF (l_has_errors = 'Y') THEN
     x_return_status := 1;
     x_return_code := 'ERRORS';
  ELSE
     x_return_status := 0;
     x_return_code := 'SUCCESS';
  END IF;


END validateAwardBidXML;


PROCEDURE validate_bids (p_source VARCHAR2, p_batch_Id NUMBER, p_trading_partner_id number) IS
--
BEGIN
 null;
END validate_bids;

--

Function getDoctypeMessageSuffix(p_auction_id number) return varchar2 is
l_suffix	varchar2(2);
begin

	SELECT  '_' || dt.message_suffix
	INTO 	l_suffix
	FROM 	pon_auc_doctypes dt,
		pon_auction_headers_all ah
	WHERE 	dt.doctype_id 	     = ah.doctype_id
	AND	ah.auction_header_id = p_auction_id
	AND	rownum =1;

	return l_suffix;

end getDoctypeMessageSuffix;



FUNCTION is_valid_rule( p_doctype_Id NUMBER
                      , p_bizrule_name VARCHAR2
                      )
RETURN BOOLEAN IS
--
  l_valid_flag pon_auc_doctype_rules.VALIDITY_FLAG%TYPE;
--
BEGIN
--
  SELECT pon_auc_doctype_rules.VALIDITY_FLAG
  INTO l_valid_flag
  FROM
    PON_AUC_DOCTYPE_RULES pon_auc_doctype_rules
  , PON_AUC_BIZRULES pon_auc_bizrules
  WHERE pon_auc_doctype_rules.BIZRULE_ID = pon_auc_bizrules.BIZRULE_ID
    AND pon_auc_doctype_rules.DOCTYPE_ID = p_doctype_Id
    AND pon_auc_bizrules.NAME = p_bizrule_name;

	IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
             module  =>  g_module_prefix || 'is_valid_rule',
             message  => 'In procedure is_valid_rule,  Doc Type id  = '
			 || p_doctype_Id || ' ; Biz Rule Name = '|| p_bizrule_name);
    END IF;

  IF (l_valid_flag = 'Y') THEN
    RETURN TRUE;
  END IF;
--
  RETURN FALSE;
--
END is_valid_rule;
--
--
FUNCTION is_required_rule( p_doctype_Id NUMBER
                      , p_bizrule_name VARCHAR2
                      )
RETURN BOOLEAN IS
--
  l_required_flag pon_auc_doctype_rules.REQUIRED_FLAG%TYPE;
--
BEGIN
--
  SELECT pon_auc_doctype_rules.REQUIRED_FLAG
  INTO l_required_flag
  FROM
    PON_AUC_DOCTYPE_RULES pon_auc_doctype_rules
  , PON_AUC_BIZRULES pon_auc_bizrules
  WHERE pon_auc_doctype_rules.BIZRULE_ID = pon_auc_bizrules.BIZRULE_ID
    AND pon_auc_doctype_rules.DOCTYPE_ID = p_doctype_Id
    AND pon_auc_bizrules.NAME = p_bizrule_name;

	IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
             module  =>  g_module_prefix || 'is_required_rule',
             message  => 'In procedure is_required_rule,  Doc Type id  = '
			 || p_doctype_Id || ' ; Biz Rule Name = '|| p_bizrule_name);
    END IF;
--
  IF (l_required_flag = 'Y') THEN
    RETURN TRUE;
  END IF;
--
  RETURN FALSE;
--
END is_required_rule;
--
--


PROCEDURE get_default_uom(p_language VARCHAR2
                         ,p_trading_partner_id NUMBER
                         ,p_amount_based_uom OUT NOCOPY	VARCHAR2
                         ,p_amount_based_unit_of_measure OUT NOCOPY VARCHAR2
                        ) AS
BEGIN
    SELECT
         m.uom_code, m.unit_of_measure_tl
    INTO
         p_amount_based_uom,
         p_amount_based_unit_of_measure
    FROM
         mtl_units_of_measure_tl m
        ,pon_party_preferences p
    WHERE
         p.PARTY_ID = p_trading_partner_id
         and PREFERENCE_NAME = 'AMOUNT_BASED_UOM'
         and m.language = p_language
         and m.uom_code = p.PREFERENCE_VALUE;
	IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
             module  =>  g_module_prefix || 'get_default_uom',
             message  => 'In procedure get_default_uom,  Language  = ' || p_language
			 || ' ; Trading Partener Id = '|| p_trading_partner_id
			 || ' ; p_amount_based_uom = '|| p_amount_based_uom
			 || ' ; p_amount_based_unit_of_measure = '
			 || p_amount_based_unit_of_measure);
    END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           p_amount_based_uom := '';
           p_amount_based_unit_of_measure := '';
END get_default_uom;
--
--
PROCEDURE get_inventory_org_id(p_org_id NUMBER
                              ,p_inventory_org OUT NOCOPY NUMBER) AS

BEGIN

    SELECT inventory_organization_id
    INTO   p_inventory_org
    FROM   financials_system_params_all
    WHERE  nvl(org_id, -9999) = nvl(p_org_id, -9999);


    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           p_inventory_org := p_org_id;

END get_inventory_org_id;
--

PROCEDURE validateAwardBid(p_batch_Id         IN      NUMBER,
                           p_spreadsheet_type IN VARCHAR2) IS
--
l_auction_id PON_AUCTION_HEADERS_ALL.auction_header_id%TYPE;
l_request_id PON_AUCTION_HEADERS_ALL.request_id%TYPE;
l_contract_type PON_AUCTION_HEADERS_ALL.contract_type%TYPE;
l_price_tiers_indicator PON_AUCTION_HEADERS_ALL.price_tiers_indicator%TYPE;
l_suffix     VARCHAR2(3);
l_user_id    NUMBER;
l_login_id   NUMBER;
l_exp_date   DATE;
l_num_of_award_lines NUMBER;

BEGIN

        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN --{
            FND_LOG.string(log_level => FND_LOG.level_statement,
             module  =>  g_module_prefix || 'validateAwardBid',
             message  => 'Entering the procedure for  batch id  = '
			 || p_batch_id || ' ; p_spreadsheet_type = '|| p_spreadsheet_type);
        END IF; --}

        select count(*)
        into   l_num_of_award_lines
        from   pon_award_items_interface
        where  batch_id = p_batch_id
        and    rownum = 1;

        IF (l_num_of_award_lines = 0) THEN

          RETURN;

        END IF;

	l_user_id  := fnd_global.user_id;
	l_login_id := fnd_global.login_id;
	l_exp_date := SYSDATE+7;

	select 	paha.auction_header_id , paha.request_id, paha.contract_type, paha.price_tiers_indicator
	into   	l_auction_id, l_request_id, l_contract_type, l_price_tiers_indicator
	from   	pon_auction_headers_all paha,
		pon_award_items_interface paii
	where	paii.auction_header_id 	= paha.auction_header_id
	and	paii.batch_id		= p_batch_id
	and 	rownum 			= 1;

	l_suffix := getDoctypeMessageSuffix(l_auction_id);

	--
	-- For Quantity Tiers
        -- Setting the award_shipment_number = -1 by default.
        -- Then updating it to the shipment number as per the award quantity
	--

	IF (p_spreadsheet_type = g_txt_upload_mode) THEN --{

            IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN --{
                FND_LOG.string(log_level => FND_LOG.level_statement,
                 module  =>  g_module_prefix || 'validateAwardBid',
                 message  => 'updating the award shipment number PON_AWARD_ITEMS_INTERFACE for  batch id  = '
				 || p_batch_id || ' ; p_spreadsheet_type = '|| p_spreadsheet_type);
            END IF; --}

            UPDATE PON_AWARD_ITEMS_INTERFACE PAII
            set AWARD_SHIPMENT_NUMBER = ( select -1
                                          from pon_bid_item_prices pbip
                                          where pbip.bid_number = PAII.bid_number
                                          and pbip.auction_line_number = PAII.auction_line_number
                                          and pbip.has_quantity_tiers = 'Y'
                                         )
            WHERE PAII.batch_id = p_batch_id
            AND PAII.award_status = 'Y';

            UPDATE PON_AWARD_ITEMS_INTERFACE PAII
            set AWARD_SHIPMENT_NUMBER = (select nvl(( select shipment_number
                                                     from pon_bid_shipments pbs
                                                     where pbs.bid_number = PAII.bid_number
                                                     and pbs.auction_line_number = PAII.AUCTION_LINE_NUMBER
                                                     and PAII.award_quantity >= pbs.quantity
                                                     and PAII.award_quantity <= pbs.max_quantity ),-1)
                                        from dual)
            WHERE PAII.batch_id = p_batch_id
            AND PAII.award_status = 'Y'
            AND PAII.AWARD_SHIPMENT_NUMBER = -1;

	END IF;--}


 	INSERT ALL
	-- VALIDATION #1:
	-- Check that the bid number is valid for this auction and this line number
	WHEN NOT EXISTS (SELECT 'Y'
                     FROM pon_bid_item_prices bp
                     WHERE 	s_auction_header_id   = bp.auction_header_id
                     AND 	s_auction_line_number = bp.line_number
                     AND 	s_bid_number   = bp.bid_number)
	THEN
	INTO	PON_INTERFACE_ERRORS
		( interface_type
               	, column_name
               	, error_message_name
                , error_value
               	, table_name
               	, batch_id
                , worksheet_name
                , worksheet_sequence_number
                , entity_message_code
               	, interface_line_id
		, request_id
		, expiration_date
		, created_by
		, creation_date
		, last_updated_by
    		, last_update_date
		, last_update_login
               	)
	VALUES (  'AWARDBID'
            	, fnd_message.get_string('PON','PON_INTEL_BID_NUMBER' || l_suffix)
	        , 'PON_AUC_BID_NUMBER_INVALID' || l_suffix
                , s_bid_number
            	, 'PON_AWARD_ITEMS_INTERFACE'
            	, s_batch_id
                , s_worksheet_name
                , s_worksheet_sequence_number
                , s_entity_message_code
            	, s_interface_line_id
		, l_request_id
		, l_exp_date
		, l_user_id
		, sysdate
		, l_user_id
    		, sysdate
		, l_login_id
		)
	-- VALIDATION #2:
	-- Check that there is no award decision made on this auction and this line number
        WHEN    (s_bid_line_award_status = 'Y' OR
                 s_award_quantity > 0 OR
                 s_awardreject_reason is not null)
	AND 	s_line_award_status = 'COMPLETED'
	THEN
	INTO	PON_INTERFACE_ERRORS
		( interface_type
               	, column_name
               	, error_message_name
               	, table_name
               	, batch_id
                , worksheet_name
                , worksheet_sequence_number
                , entity_message_code
               	, interface_line_id
		, request_id
		, expiration_date
		, created_by
		, creation_date
		, last_updated_by
    		, last_update_date
		, last_update_login
               	)
	VALUES (  'AWARDBID'
            	, fnd_message.get_string('PON','PON_INTEL_BID_NUMBER' || l_suffix)
	        , 'PON_AUC_ITEM_AWARDED'
            	, 'PON_AWARD_ITEMS_INTERFACE'
            	, s_batch_id
                , s_worksheet_name
                , s_worksheet_sequence_number
                , s_entity_message_code
            	, s_interface_line_id
		, l_request_id
		, l_exp_date
		, l_user_id
		, sysdate
		, l_user_id
    		, sysdate
		, l_login_id
		)
	-- VALIDATION #3
	-- Check if any award reco made for NOT shortlisted bids
        WHEN    (s_bid_line_award_status = 'Y' OR
                 s_award_quantity > 0 OR
                 s_awardreject_reason is not null)
	AND	s_shortlist_flag	  = 'N'
	THEN
	INTO	PON_INTERFACE_ERRORS
		( interface_type
               	, column_name
               	, error_message_name
		, error_value
               	, table_name
               	, batch_id
                , worksheet_name
                , worksheet_sequence_number
                , entity_message_code
               	, interface_line_id
		, request_id
		, expiration_date
		, created_by
		, creation_date
		, last_updated_by
    		, last_update_date
		, last_update_login
               	)
	VALUES (  'AWARDBID'
            	, fnd_message.get_string('PON','PON_INTEL_BID_NUMBER' || l_suffix)
	        , 'PON_AWARD_EXCLUDE_SHLIST_ERR' || l_suffix
		, s_bid_number
            	, 'PON_AWARD_ITEMS_INTERFACE'
            	, s_batch_id
                , s_worksheet_name
                , s_worksheet_sequence_number
                , s_entity_message_code
            	, s_interface_line_id
		, l_request_id
		, l_exp_date
		, l_user_id
		, sysdate
		, l_user_id
    		, sysdate
		, l_login_id
		)
        -- VALIDATION #4
        -- Check if bid is active
        WHEN    (s_bid_line_award_status = 'Y' OR
                 s_award_quantity > 0 OR
                 s_awardreject_reason is not null)
        AND     s_bid_status  <> 'ACTIVE'
        THEN
        INTO    PON_INTERFACE_ERRORS
                ( interface_type
                , column_name
                , error_message_name
                , error_value
                , table_name
                , batch_id
                , worksheet_name
                , worksheet_sequence_number
                , entity_message_code
                , interface_line_id
                , request_id
                , expiration_date
                , created_by
                , creation_date
                , last_updated_by
                , last_update_date
                , last_update_login
                )
        VALUES (  'AWARDBID'
                , fnd_message.get_string('PON','PON_INTEL_BID_NUMBER' || l_suffix)
                , 'PON_AWARD_BID_NOT_ACTIVE' || l_suffix
                , s_bid_number
                , 'PON_AWARD_ITEMS_INTERFACE'
                , s_batch_id
                , s_worksheet_name
                , s_worksheet_sequence_number
                , s_entity_message_code
                , s_interface_line_id
                , l_request_id
                , l_exp_date
                , l_user_id
                , sysdate
                , l_user_id
                , sysdate
                , l_login_id
                )
        -- VALIDATION #5
        -- Check if supplier is active
        WHEN    (s_bid_line_award_status = 'Y' OR
                 s_award_quantity > 0 OR
                 s_awardreject_reason is not null)
        AND     s_end_date_active is not null and s_end_date_active <= trunc(sysdate)
        THEN
        INTO    PON_INTERFACE_ERRORS
                ( interface_type
                , column_name
                , error_message_name
                , error_value
                , table_name
                , batch_id
                , worksheet_name
                , worksheet_sequence_number
                , entity_message_code
                , interface_line_id
                , request_id
                , expiration_date
                , created_by
                , creation_date
                , last_updated_by
                , last_update_date
                , last_update_login
                )
        VALUES (  'AWARDBID'
                , decode(p_spreadsheet_type, PON_AWARD_PKG.g_xml_upload_mode, fnd_message.get_string('PON','PON_ACCTS_SUPPLIER'), fnd_message.get_string('PON','PON_BIDS_BIDDER' || l_suffix))
                , 'PON_AWARD_INACTIVE_SUPPLIER'
                , s_trading_partner_name
                , 'PON_AWARD_ITEMS_INTERFACE'
                , s_batch_id
                , s_worksheet_name
                , s_worksheet_sequence_number
                , s_entity_message_code
                , s_interface_line_id
                , l_request_id
                , l_exp_date
                , l_user_id
                , sysdate
                , l_user_id
                , sysdate
                , l_login_id
                )
        -- VALIDATION #6
        -- Check if award quantity is > 0 when uploading an XML file
        WHEN    p_spreadsheet_type = PON_AWARD_PKG.g_xml_upload_mode
        AND     s_award_quantity < 0
        THEN
        INTO    PON_INTERFACE_ERRORS
                ( interface_type
                , column_name
                , error_message_name
                , error_value_number
                , error_value_datatype
                , table_name
                , batch_id
                , worksheet_name
                , worksheet_sequence_number
                , entity_message_code
                , interface_line_id
                , request_id
                , expiration_date
                , created_by
                , creation_date
                , last_updated_by
                , last_update_date
                , last_update_login
                )
        VALUES (  'AWARDBID'
                , decode(l_contract_type, 'STANDARD', fnd_message.get_string('PON','PON_AUCTION_AWARD_QTY'), fnd_message.get_string('PON','PON_AUCTS_AGREED_QUANTITY'))
                , decode(l_contract_type, 'STANDARD', 'PON_AUC_AWARD_QTY_COL_NEG', 'PON_AUC_QTY_AGREED_COL_NEG')
                , s_award_quantity
                , 'NUM'
                , 'PON_AWARD_ITEMS_INTERFACE'
                , s_batch_id
                , s_worksheet_name
                , s_worksheet_sequence_number
                , s_entity_message_code
                , s_interface_line_id
                , l_request_id
                , l_exp_date
                , l_user_id
                , sysdate
                , l_user_id
                , sysdate
                , l_login_id
                )
        -- VALIDATION #7
        -- Check if award quantity is entered when document is of type SPO, award status is Y and
        -- an XML file is being uploaded
        WHEN    p_spreadsheet_type = PON_AWARD_PKG.g_xml_upload_mode
        AND     l_contract_type = 'STANDARD'
        AND     s_order_type_lookup_code = 'QUANTITY'
        AND     s_bid_line_award_status = 'Y'
        AND     s_award_quantity is null
        THEN
        INTO    PON_INTERFACE_ERRORS
                ( interface_type
                , column_name
                , error_message_name
                , table_name
                , batch_id
                , worksheet_name
                , worksheet_sequence_number
                , entity_message_code
                , interface_line_id
                , request_id
                , expiration_date
                , created_by
                , creation_date
                , last_updated_by
                , last_update_date
                , last_update_login
                )
        VALUES (  'AWARDBID'
                , fnd_message.get_string('PON','PON_AUCTION_AWARD_QTY')
                , 'PON_AUCTS_MUST_AWARD'
                , 'PON_AWARD_ITEMS_INTERFACE'
                , s_batch_id
                , s_worksheet_name
                , s_worksheet_sequence_number
                , s_entity_message_code
                , s_interface_line_id
                , l_request_id
                , l_exp_date
                , l_user_id
                , sysdate
                , l_user_id
                , sysdate
                , l_login_id
                )

        -- VALIDATION #8
        -- Awarded Qty should fall within Qty tiers provided on the bid, by supplier
        -- for tab-delimited spreasheet

        WHEN    l_price_tiers_indicator = 'QUANTITY_BASED'
        AND     s_bid_line_award_status = 'Y'
        AND     s_award_shipment_number = -1
        AND     p_spreadsheet_type = g_txt_upload_mode
        AND     nvl(s_award_quantity , 0) > 0
        THEN
        INTO    PON_INTERFACE_ERRORS
                ( interface_type
                , column_name
                , error_message_name
                , table_name
                , error_value
                , batch_id
                , worksheet_name
                , worksheet_sequence_number
                , entity_message_code
                , interface_line_id
                , request_id
                , expiration_date
                , created_by
                , creation_date
                , last_updated_by
                , last_update_date
                , last_update_login
                , TOKEN1_NAME
                , TOKEN1_VALUE
                )
        VALUES (  'AWARDBID'
                , fnd_message.get_string('PON','PON_AUCTION_AWARD_QTY')
                , 'PON_QUANTITY_TIER_VIOLATION' || l_suffix
                , 'PON_AWARD_ITEMS_INTERFACE'
                , s_award_quantity
                , s_batch_id
                , s_worksheet_name
                , s_worksheet_sequence_number
                , s_entity_message_code
                , s_interface_line_id
                , l_request_id
                , l_exp_date
                , l_user_id
                , sysdate
                , l_user_id
                , sysdate
                , l_login_id
                , 'BID_NUM'
                , s_bid_number
                )

	SELECT
		  ap.batch_id AS s_batch_id
		, ap.auction_header_id AS s_auction_header_id
		, ap.bid_number AS s_bid_number
		, ap.auction_line_number AS s_auction_line_number
                , ap.worksheet_name AS s_worksheet_name
                , ap.worksheet_sequence_number AS s_worksheet_sequence_number
                , 'PON_AUC_ITEMS' AS s_entity_message_code
                , ap.interface_line_id AS s_interface_line_id
                , ap.award_status AS s_bid_line_award_status
                , ap.award_quantity AS s_award_quantity
                , ap.awardreject_reason AS s_awardreject_reason
		, ai.award_status AS s_line_award_status
                , ai.order_type_lookup_code AS s_order_type_lookup_code
                , bh.trading_partner_name AS s_trading_partner_name
		, bh.shortlist_flag AS s_shortlist_flag
                , bh.bid_status AS s_bid_status
                , pv.end_date_active AS s_end_date_active
                , ap.award_shipment_number as s_award_shipment_number
	FROM	  pon_award_items_interface 	ap
		, pon_auction_item_prices_all 	ai
		, pon_bid_headers		bh
                , po_vendors                    pv
	WHERE	ap.batch_id 		= p_batch_id
	AND 	ap.auction_header_id 	= ai.auction_header_id
	AND 	ap.auction_line_number 	= ai.line_number
	AND	ap.bid_number		= bh.bid_number (+)
        AND     bh.vendor_id            = pv.vendor_id (+);


--
	INSERT INTO PON_INTERFACE_ERRORS
               ( interface_type
               , column_name
               , error_message_name
               , error_value
               , table_name
               , batch_id
               , worksheet_name
               , worksheet_sequence_number
               , entity_message_code
               , interface_line_id
	       , request_id
	       , expiration_date
	       , created_by
	       , creation_date
	       , last_updated_by
    	       , last_update_date
	       , last_update_login
               , TOKEN1_NAME
               , TOKEN1_VALUE
               )
     	SELECT
                 'AWARDBID'
	       , fnd_message.get_string('PON','PON_AUC_LINE_TYPE')
               , 'PON_AWARD_FIXED_PRICE'|| l_suffix
               , pltt.line_type
               , 'PON_AWARD_ITEMS_INTERFACE'
               , paii.BATCH_ID
               , paii.worksheet_name
               , paii.worksheet_sequence_number
               , 'PON_AUC_ITEMS' entity_message_code
               , to_number(null) interface_line_id
	       , l_request_id
	       , l_exp_date
	       , l_user_id
	       , sysdate
	       , l_user_id
    	       , sysdate
	       , l_login_id
               , 'LINE_NUMBER'
               , ai.document_disp_line_number
	FROM  PON_AWARD_ITEMS_INTERFACE paii,
	      pon_auction_item_prices_all ai,
	      pon_auction_headers_all ah,
              po_line_types_tl pltt
     WHERE   paii.batch_id = p_batch_id
	 AND paii.award_status = 'Y'
	 AND ah.auction_header_id = paii.auction_header_id
	 AND ah.contract_type = 'STANDARD'
	 AND ai.line_number = paii.auction_line_number
	 AND ai.auction_header_id = paii.auction_header_id
	 AND ai.order_type_lookup_code = 'FIXED PRICE'
         AND ai.line_type_id = pltt.line_type_id (+)
         AND pltt.language (+) = userenv('LANG')
	 GROUP BY paii.batch_id,
                  paii.worksheet_name,
                  paii.worksheet_sequence_number,
		  ai.document_disp_line_number,
                  pltt.line_type
	 HAVING count(paii.award_status) >1;


END validateAwardBid;
--

PROCEDURE validate_complexwork(p_batch_id              IN NUMBER
                              ,p_progress_payment_type IN VARCHAR2
                              ,p_contract_type         IN VARCHAR2
                              ,p_advance_negotiable_flag         IN VARCHAR2
                              ,p_recoupment_negotiable_flag         IN VARCHAR2
                        )
IS
l_userid NUMBER;
l_loginid NUMBER;
l_exp_date DATE;
CURSOR l_proj_cursor IS
  SELECT pipi.interface_line_id, pipi.document_disp_line_number, pipi.auction_line_number,
         pipi.project_id, pipi.project_task_id, pipi.project_expenditure_type,
		 pipi.project_exp_organization_id, pipi.project_expenditure_item_date,
		 pipi.auction_header_id, pipi.interface_type
  FROM PON_ITEM_PRICES_INTERFACE pipi
  WHERE pipi.batch_id=p_batch_id
  AND pipi.project_id IS NOT NULL
  AND pipi.project_task_id IS NOT NULL
  AND pipi.project_expenditure_type IS NOT NULL
  AND pipi.project_exp_organization_id IS NOT NULL
  AND pipi.project_expenditure_item_date IS NOT NULL;

BEGIN
l_userid := fnd_global.user_id;
l_loginid := fnd_global.login_id;
l_exp_date := SYSDATE+7;


IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
             module  =>  g_module_prefix || 'validate_complexwork',
             message  => 'Entering the procedure validate_complexwork for  batch id  = '
			 || p_batch_id || ' ; p_progress_payment_type = '|| p_progress_payment_type
			 || ' ; p_contract_type = '|| p_contract_type|| ' ; p_advance_negotiable_flag = '
			 || p_advance_negotiable_flag|| ' ; p_recoupment_negotiable_flag = '|| p_recoupment_negotiable_flag);
END IF;


IF p_contract_type = 'CONTRACT' THEN
  INSERT ALL
  WHEN (p_progress_payment_type <> 'NONE' AND
  line_type_id IS NOT NULL AND
  NOT ((order_type_lookup_code = 'FIXED PRICE' AND purchase_basis = 'SERVICES') OR
   (order_type_lookup_code = 'QUANTITY' AND purchase_basis = 'GOODS')))
   OR po_outside_operation_flag = 'Y' THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_AUC_LINE_TYPE'),         'PON_ITEM_PRICES_INTERFACE',    -- 1
    line_type,                    'PON_INVALID_STYLE_LINETYPE',                                    batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )
  SELECT
       pipi.BATCH_ID,
       pipi.INTERFACE_LINE_ID,
       pipi.INTERFACE_TYPE,
       pipi.AUCTION_HEADER_ID,
       pipi.DOCUMENT_DISP_LINE_NUMBER,
       pipi.PURCHASE_BASIS,
       pipi.ORDER_TYPE_LOOKUP_CODE,
       pipi.auction_line_number s_line_number,
       plt.outside_operation_flag po_outside_operation_flag,
       plt.line_type_id,
	   plt.line_type
  FROM PON_ITEM_PRICES_INTERFACE pipi,
       PO_LINE_TYPES plt
  WHERE batch_id = p_batch_id
  AND   pipi.line_type_id = plt.line_type_id (+)
  AND   pipi.group_type NOT IN ('GROUP','LOT_LINE');

ELSIF p_contract_type = 'STANDARD' THEN

  INSERT ALL
  WHEN retainage_rate_percent IS NOT NULL AND (retainage_rate_percent < 0 OR retainage_rate_percent > 100) THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_RETAINAGE_RATE'),         'PON_ITEM_PRICES_INTERFACE',    -- 1
    retainage_rate_percent,       'PON_RTNG_RATE_WRONG',                                       batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                           s_line_number,     -- 3
    NULL,                         NULL,                                                        l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                     l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                    -- 6
   )

  WHEN max_retainage_amount IS NOT NULL AND max_retainage_amount < 0 THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
    )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_MAX_RETAINAGE_AMOUNT'),  'PON_ITEM_PRICES_INTERFACE',    -- 1
    max_retainage_amount  ,       'PON_MAX_RTNG_WRONG',                                       batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN advance_amount IS NOT NULL AND advance_amount < 0 THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_ADVANCE_AMOUNT_FLAG'),   'PON_ITEM_PRICES_INTERFACE',    -- 1
    advance_amount,               'PON_ADV_AMT_WRONG',                                        batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN progress_pymt_rate_percent IS NOT NULL AND (progress_pymt_rate_percent < 0 OR progress_pymt_rate_percent > 100) then
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_PROGRESS_PYMT_RATE'),   'PON_ITEM_PRICES_INTERFACE',    -- 1
    progress_pymt_rate_percent,   'PON_PROG_PYMT_RATE_WRONG',                                 batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )
  WHEN recoupment_rate_percent IS NOT NULL AND (recoupment_rate_percent < 0 OR recoupment_rate_percent > 100) THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_RECOUPMENT_RATE'),        'PON_ITEM_PRICES_INTERFACE',    -- 1
    recoupment_rate_percent,      'PON_RECOUP_RATE_WRONG',                                    batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN p_progress_payment_type = 'FINANCE' AND progress_pymt_rate_percent IS NULL THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_PROGRESS_PYMT_RATE'),    'PON_ITEM_PRICES_INTERFACE',    -- 1
    progress_pymt_rate_percent,   'PON_FIELD_MUST_BE_ENTERED',                                 batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                   l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )


  WHEN progress_pymt_rate_percent IS NOT NULL AND
       recoupment_rate_percent IS NULL AND
       p_recoupment_negotiable_flag = 'N' THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_RECOUPMENT_RATE'),    'PON_ITEM_PRICES_INTERFACE',    -- 1
    recoupment_rate_percent,      'PON_RECUP_NEEDED_WITH_PPRATE',                                 batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                   l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN ((advance_amount IS NOT NULL OR p_advance_negotiable_flag = 'Y') AND
        (recoupment_rate_percent IS NULL AND p_recoupment_negotiable_flag = 'N')) THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_RECOUPMENT_RATE'),    'PON_ITEM_PRICES_INTERFACE',    -- 1
    recoupment_rate_percent,   'PON_RECUP_NEEDED_WITH_ADVAMT',                                 batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                   l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN target_price IS NOT NULL AND advance_amount IS NOT NULL
     AND (advance_amount > nvl(s_quantity,1) * target_price) THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_ADVANCE_AMOUNT_FLAG'),    'PON_ITEM_PRICES_INTERFACE',    -- 1
    advance_amount,               'PON_ADV_AMT_MORE',                                 batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                   l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN p_progress_payment_type <> 'NONE' AND recoupment_rate_percent IS NOT NULL
     AND advance_amount IS NOT NULL AND target_price IS NOT NULL
     AND (recoupment_rate_percent < (advance_amount * 100)/(nvl(s_quantity,1) * target_price)) THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_RECOUPMENT_RATE'),    'PON_ITEM_PRICES_INTERFACE',    -- 1
    recoupment_rate_percent,     'PON_RECOUP_LESS_THAN_ADV',                                 batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                   l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN (p_progress_payment_type <> 'NONE' AND
  line_type_id IS NOT NULL AND
  NOT ((order_type_lookup_code = 'FIXED PRICE' AND purchase_basis = 'SERVICES') OR
   (order_type_lookup_code = 'QUANTITY' AND purchase_basis = 'GOODS')))
      OR po_outside_operation_flag = 'Y' THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_AUC_LINE_TYPE'),         'PON_ITEM_PRICES_INTERFACE',    -- 1
    line_type,                   'PON_INVALID_STYLE_LINETYPE',                                    batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN line_origination_code <> 'REQUISITION' AND project_number IS NOT NULL AND pro_project_id IS NULL THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_AUCTS_PROJECT'),         'PON_ITEM_PRICES_INTERFACE',    -- 1
    project_number,               'PON_PROJ_NUM_INVALID',                                     batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN line_origination_code <> 'REQUISITION'
  AND pro_project_id IS NOT NULL
  AND project_task_number IS NOT NULL
  AND NOT EXISTS (SELECT 1
                    FROM PA_TASKS_EXPEND_V task
                   WHERE task.project_id = pro_project_id AND task.task_number = project_task_number) THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_AUCTS_TASK'),            'PON_ITEM_PRICES_INTERFACE',    -- 1
    project_task_number,          'PON_PROJ_TASK_INVALID',                                    batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN line_origination_code <> 'REQUISITION'
  AND pro_project_id IS NOT NULL
  AND project_task_number IS NOT NULL
  AND project_award_number IS NOT NULL
  AND NOT EXISTS (SELECT 1
                    FROM GMS_AWARDS_BASIC_V award,
                         PA_TASKS_EXPEND_V task
                   WHERE award.project_id = pro_project_id
                     AND task.task_number = project_task_number
                     AND award.task_id = task.task_id
                     AND task.project_id = pro_project_id) THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_AUCTS_PROJECT_AWARD'),   'PON_ITEM_PRICES_INTERFACE',    -- 1
    project_award_number,         'PON_PROJ_AWARD_INVALID',                                   batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN line_origination_code <> 'REQUISITION' AND project_exp_organization_name IS NOT NULL
  AND porg_proj_exp_organization_id IS NULL THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_AUCTS_EXPENDITUE_ORG'),  'PON_ITEM_PRICES_INTERFACE',    -- 1
    project_exp_organization_name,'PON_PROJ_EXPORG_INVALID',                                  batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )
WHEN s_project_exp_type IS NOT NULL
AND NOT EXISTS (SELECT 1
                FROM pa_expenditure_types_expend_v exptype
                WHERE system_linkage_function = 'VI'
                AND exptype.expenditure_type = s_project_exp_type
                AND  trunc(sysdate) BETWEEN nvl(exptype.expnd_typ_start_date_active, trunc(sysdate))
                                    AND  nvl(exptype.expnd_typ_end_date_Active, trunc(sysdate))
                AND trunc(sysdate) BETWEEN nvl(exptype.sys_link_start_date_active, trunc(sysdate))
                                    AND  nvl(exptype.sys_link_end_date_Active, trunc(sysdate))) THEN

   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_AUCTS_EXPENDITUE_TYPE'),  'PON_ITEM_PRICES_INTERFACE',    -- 1
    s_project_exp_type,           'PON_PROJ_EXPTYPE_INVALID',                                  batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN pro_project_id IS NOT NULL
  AND project_award_number IS NULL
  AND PON_NEGOTIATION_PUBLISH_PVT.IS_PROJECT_SPONSORED(pro_project_id) = 'Y' THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_AUCTS_PROJECT_AWARD'),   'PON_ITEM_PRICES_INTERFACE',    -- 1
    project_award_number,         'PON_PROJ_AWARD_NULL',                                   batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )
  WHEN line_origination_code <> 'REQUISITION' AND
  ((project_number IS NULL OR project_task_number IS NULL  OR s_project_exp_type IS NULL
    OR project_exp_organization_name IS NULL OR project_expenditure_item_date IS NULL) AND
  (project_number IS NOT NULL OR project_task_number IS NOT NULL  OR s_project_exp_type IS NOT NULL
   OR project_exp_organization_name IS NOT NULL OR project_expenditure_item_date IS NOT NULL)) THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_AUCTS_PROJECT'),         'PON_ITEM_PRICES_INTERFACE',    -- 1
    NULL,                         'PON_PROJ_INFO_INCOMPLETE',                                    batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )

  WHEN work_approver_user_name IS NOT NULL
  AND NOT EXISTS (SELECT 1
                    FROM PER_WORKFORCE_CURRENT_X peo,
                         FND_USER fu
                   WHERE fu.user_name = work_approver_user_name
                     AND fu.employee_id = peo.person_id
    			     AND SYSDATE >= nvl(fu.start_date, SYSDATE)
				     AND SYSDATE <= nvl(fu.end_date, SYSDATE) )
  THEN
   INTO pon_interface_errors
   (
    interface_type,               column_name,                                                table_name,             -- 1
    error_value,                  error_message_name,                                         batch_id,               -- 2
    interface_line_id,            auction_header_id,                                          line_number,            -- 3
    token1_name,                  token1_value,                                               expiration_date,        -- 4
    created_by,                   creation_date,                                              last_updated_by,        -- 5
    last_update_date,             last_update_login                                                                   -- 6
   )
  VALUES
   (
    interface_type,               fnd_message.get_string('PON','PON_DEFAULT_OWNER'),         'PON_ITEM_PRICES_INTERFACE',    -- 1
    NULL,                         'PON_LIN_OWNER_INVALID',                                    batch_id,                      -- 2
    interface_line_id,            auction_header_id,                                          s_line_number,     -- 3
    NULL,                         NULL,                                                       l_exp_date,                    -- 4
    l_userid,                     SYSDATE,                                                    l_userid,                      -- 5
    SYSDATE,                      l_loginid                                                                                   -- 6
   )
  SELECT
       pipi.BATCH_ID,
       pipi.INTERFACE_LINE_ID,
       pipi.INTERFACE_TYPE,
       pipi.AUCTION_HEADER_ID,
       pipi.DOCUMENT_DISP_LINE_NUMBER,
       pipi.ADVANCE_AMOUNT,
       pipi.RECOUPMENT_RATE_PERCENT,
       pipi.PROGRESS_PYMT_RATE_PERCENT,
       pipi.RETAINAGE_RATE_PERCENT,
       pipi.MAX_RETAINAGE_AMOUNT,
       pipi.WORK_APPROVER_USER_NAME,
       pipi.PROJECT_NUMBER,
       pipi.PROJECT_TASK_NUMBER,
       pipi.PROJECT_AWARD_NUMBER,
       pipi.PROJECT_EXPENDITURE_TYPE s_project_exp_type,
       pipi.PROJECT_EXP_ORGANIZATION_NAME,
       pipi.PROJECT_EXPENDITURE_ITEM_DATE,
       pipi.PURCHASE_BASIS,
       pipi.ORDER_TYPE_LOOKUP_CODE,
       NVL(pipi.LINE_ORIGINATION_CODE,'-9997') LINE_ORIGINATION_CODE,
       pipi.auction_line_number s_line_number,
       pipi.target_price,
       pipi.quantity s_quantity,
       pro.project_id pro_project_id,
       porg.organization_id porg_proj_exp_organization_id,
	   plt.outside_operation_flag po_outside_operation_flag,
       plt.line_type_id,
  	   plt.line_type
  FROM PON_ITEM_PRICES_INTERFACE pipi,
       PA_PROJECTS_EXPEND_V pro,
       PA_ORGANIZATIONS_EXPEND_V porg,
       PO_LINE_TYPES plt
  WHERE batch_id = p_batch_id
  AND  pipi.project_number = pro.project_number (+)
  AND  pipi.project_exp_organization_name = porg.name(+)
  AND  pipi.line_type_id = plt.line_type_id (+)
  AND  pipi.group_type NOT IN ('GROUP','LOT_LINE');

  --Derive id columns and update the interface table
  UPDATE PON_ITEM_PRICES_INTERFACE pipi1
  SET (PROJECT_ID, PROJECT_TASK_ID, PROJECT_AWARD_ID, PROJECT_EXP_ORGANIZATION_ID) =
  (SELECT pro.project_id, task.task_id, award.award_id, porg.organization_id
   FROM   PA_PROJECTS_ALL pro,
          PA_TASKS task,
          GMS_AWARDS_ALL award,
          HR_ALL_ORGANIZATION_UNITS porg,
          PON_ITEM_PRICES_INTERFACE pipi
   WHERE  pipi.project_number = pro.segment1
   AND    pipi.project_task_number = task.task_number
   AND    pro.project_id = task.project_id
   AND    pipi.project_award_number = award.award_number(+)
   AND    pipi.project_exp_organization_name = porg.name
   AND    pipi.batch_id = pipi1.batch_id
   AND    pipi.interface_line_id = pipi1.interface_line_id)
  WHERE pipi1.batch_id = p_batch_id;

  UPDATE PON_ITEM_PRICES_INTERFACE pipi
  SET (WORK_APPROVER_USER_ID) =
  (SELECT fu.user_id
   FROM FND_USER fu
   WHERE  pipi.work_approver_user_name = fu.user_name)
  WHERE batch_id = p_batch_id;

END IF; -- End of if p_contract_type = 'STANDARD'

  --Validate project fields with PATC
    FOR l_proj_record IN l_proj_cursor LOOP
        PON_NEGOTIATION_PUBLISH_PVT.VALIDATE_PROJECTS_DETAILS (
            p_project_id                => l_proj_record.project_id,
            p_task_id                   => l_proj_record.project_task_id,
            p_expenditure_date          => l_proj_record.project_expenditure_item_date,
            p_expenditure_type          => l_proj_record.project_expenditure_type,
            p_expenditure_org           => l_proj_record.project_exp_organization_id,
            p_person_id                 => null,
            p_auction_header_id         => l_proj_record.auction_header_id,
            p_line_number               => l_proj_record.auction_line_number,
            p_document_disp_line_number => l_proj_record.document_disp_line_number,
            p_payment_id                => null,
            p_interface_line_id         => l_proj_record.interface_line_id,
            p_payment_display_number    => null,
            p_batch_id                  => p_batch_id,
            p_table_name                => 'PON_ITEM_PRICES_INTERFACE',
            p_interface_type            => l_proj_record.interface_type,
            p_entity_type               => null,
            p_called_from               => 'LINES_SP');
    END LOOP;


END validate_complexwork;


-- The procedure loads necessary po style settings for validation.
-- Current usage including line type validation in line upload.

-- Params: p_batch_id     batch id (used to get auction header id)
--         x_po_style_id  po style id for the negotiation
--         x_line_type_restriction   the associated po style setting (line type)

PROCEDURE get_po_style_settings (p_batch_id                IN   NUMBER,
                                 x_po_style_id             OUT NOCOPY NUMBER,
                                 x_line_type_restriction   OUT NOCOPY VARCHAR2) IS
l_dummy1     VARCHAR2(240);
l_dummy2     VARCHAR2(240);
l_dummy3     VARCHAR2(30);
l_dummy4     VARCHAR2(30);
l_dummy5     VARCHAR2(1);
l_dummy6     VARCHAR2(1);
l_dummy7     VARCHAR2(1);
l_dummy8     VARCHAR2(1);
l_dummy9     VARCHAR2(1);
l_dummy10    VARCHAR2(1);


BEGIN

      BEGIN

         select ah.po_style_id
           into x_po_style_id
           from pon_auction_headers_all ah,
                pon_item_prices_interface  ipi
          where ipi.batch_id = p_batch_id
            and ipi.auction_header_id = ah.auction_header_id
            and rownum = 1;

      EXCEPTION
                WHEN OTHERS THEN
                    x_po_style_id := NULL;
      END;


      -- invoke po api to get settings for the po style
      IF ( x_po_style_id is not null)  THEN  -- RFI has no po style, so add the check

         BEGIN
                PO_DOC_STYLE_GRP.GET_DOCUMENT_STYLE_SETTINGS(
                                                   P_API_VERSION => '1.0',
                                                   P_STYLE_ID    => x_po_style_id,
                                                   X_STYLE_NAME  => l_dummy1,
                                                   X_STYLE_DESCRIPTION => l_dummy2,
                                                   X_STYLE_TYPE	=> l_dummy3,
                                                   X_STATUS => l_dummy4,
                                                   X_ADVANCES_FLAG => l_dummy5,
                                                   X_RETAINAGE_FLAG => l_dummy6,
                                                   X_PRICE_BREAKS_FLAG => l_dummy7,
                                                   X_PRICE_DIFFERENTIALS_FLAG => l_dummy8,
                                                   X_PROGRESS_PAYMENT_FLAG=> l_dummy9,
                                                   X_CONTRACT_FINANCING_FLAG=> l_dummy10,
                                                   X_LINE_TYPE_ALLOWED	=> x_line_type_restriction);

         EXCEPTION
                WHEN OTHERS THEN
                    x_line_type_restriction := 'ALL';  -- no restriction
         END;

      END IF;

END get_po_style_settings;

--
PROCEDURE validate (p_source 		IN	VARCHAR2,
                    p_batch_Id 		IN	NUMBER,
                    p_doctype_Id 	IN	NUMBER,
		    p_user_Id 		IN	NUMBER,
                    p_trading_partner_id IN	NUMBER,
  		    p_trading_partner_contact_id IN	NUMBER,
		    p_language 		IN	VARCHAR2,
                    p_contract_type 	IN	VARCHAR2,
		    p_global_flag 	IN	VARCHAR2,
                    p_org_id 		IN	NUMBER) IS
--
  CURSOR C_ship_to (c_batch_id NUMBER) IS
  SELECT
    INTERFACE_LINE_ID
  , SHIP_TO_LOCATION_ID
  FROM PON_ITEM_PRICES_INTERFACE
  WHERE BATCH_ID = c_batch_id
    AND SHIP_TO_LOCATION_ID <> -1
    AND SHIP_TO_LOCATION <> 'SHIP_NONE_ENTERED';
--
 l_country	 VARCHAR2(60);
 l_address1	 VARCHAR2(240);
 l_address2	 VARCHAR2(240);
 l_address3	 VARCHAR2(240);
 l_address4	 VARCHAR2(240);
 l_city		 VARCHAR2(60);
 l_postal_code	 VARCHAR2(60);
 l_state	 VARCHAR2(60);
 l_province	 VARCHAR2(60);
 l_ship_site_use_type_id NUMBER;
 l_transaction_type VARCHAR2(25);
--
 -- params to projects api
 --l_project_number VARCHAR2(25);
 --l_project_name   VARCHAR2(100);
 --l_project_id     NUMBER;
 --l_task_number    VARCHAR2(25);
 --l_task_name      VARCHAR2(100);
 --l_task_id        NUMBER;
 l_return_status  VARCHAR2(10);
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(100);
 l_return_status2 VARCHAR2(10);
 l_line_type_id   NUMBER;
 l_line_type      VARCHAR2(25);
 l_line_lookup_code   VARCHAR2(25);
 l_deafult_line_type_category   VARCHAR2(122);
 l_default_line_type_uom   VARCHAR2(25);
 l_amount_based_uom   VARCHAR2(25);
 l_amount_based_unit_of_measure   VARCHAR2(25);
 l_item_number_delimiter varchar2(1);
 l_inventory_org_id number;
 l_progress_payment_type      PON_AUCTION_HEADERS_ALL.progress_payment_type%TYPE;
 l_advance_negotiable_flag    PON_AUCTION_HEADERS_ALL.advance_negotiable_flag%TYPE;
 l_recoupment_negotiable_flag PON_AUCTION_HEADERS_ALL.recoupment_negotiable_flag%TYPE;
 l_po_style_id    PON_AUCTION_HEADERS_ALL.po_style_id%TYPE;
 l_line_type_restriction  VARCHAR2(30);
 l_auction_header_id NUMBER;
 l_auction_round_number NUMBER;
--
BEGIN

	IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
             module  =>  g_module_prefix || 'validateAwardBid',
             message  => 'Entering the procedure validate for  batch id  = ' ||
			 p_batch_id || ' ; p_source = '|| p_source|| ' ; p_doctype_Id = '|| p_doctype_Id
			 || ' ; p_user_Id = '|| p_user_Id|| ' ; p_trading_partner_id = '|| p_trading_partner_id
			 || ' ; p_trading_partner_contact_id = '|| p_trading_partner_contact_id|| ' ; p_language = '
			 || p_language|| ' ; p_contract_type = '|| p_contract_type
			 || ' ; p_global_flag = '|| p_global_flag|| ' ; p_org_id = '|| p_org_id);
END IF;
  -- DBMS_OUTPUT.PUT_LINE('> validate()');
--
-- AWARDBID specific validation
  IF p_source = 'AWARDBID' THEN
    validateAwardBid(p_batch_id, g_txt_upload_mode);
    RETURN;
  END IF;
--
--
--
  -- the rest of the validation only for importItems not for importBids
  IF p_source <> 'SBID' THEN
--
  -- Category name has reference to category id --
  -- AUCTION and BID --
--
  -- First of all get the default UOM for the amount based line type.
    get_default_uom(p_language,p_trading_partner_id,l_amount_based_uom,l_amount_based_unit_of_measure);

  -- Retrive the inventory org id
    get_inventory_org_id(p_org_id, l_inventory_org_id);

    -- load po style settings
    get_po_style_settings(p_batch_id, l_po_style_id, l_line_type_restriction);

	IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
             module  =>  g_module_prefix || 'validate',
             message  => 'In procedure validate  l_amount_based_uom  = ' || l_amount_based_uom
			 || ' ; l_amount_based_unit_of_measure = '|| l_amount_based_unit_of_measure
			 || ' ; l_inventory_org_id = '|| l_inventory_org_id|| ' ; l_po_style_id = '
			 || l_po_style_id|| ' ; l_line_type_restriction = '|| l_line_type_restriction);
	END IF;


    -- If a negotiation document allows a buyer to select whether price and quantity are applicable for a line,
    -- and the buyer specifies that it is NOT applicable, but still enters a quantity and price(s), we need to
    -- report these errors


    select auction_header_id
    into l_auction_header_id
    from pon_item_prices_interface
    where batch_id = p_batch_id
    and auction_header_id is not null
    and rownum =1;

    SELECT nvl(auction_round_number,0),
           progress_payment_type,
           advance_negotiable_flag,
           recoupment_negotiable_flag
    INTO   l_auction_round_number,
           l_progress_payment_type,
           l_advance_negotiable_flag,
           l_recoupment_negotiable_flag
    FROM
        pon_auction_headers_all
    WHERE
    auction_header_id = l_auction_header_id;

	IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
             module  =>  g_module_prefix || 'validate',
             message  => 'In procedure validate  l_auction_round_number  = '
			 || l_auction_round_number || ' ; l_progress_payment_type = '
			 || l_progress_payment_type|| ' ; l_advance_negotiable_flag = '
			 || l_advance_negotiable_flag|| ' ; l_recoupment_negotiable_flag = '
			 || l_recoupment_negotiable_flag);
	END IF;

    if(l_auction_round_number > 1) then
        pon_cp_intrfac_to_transaction.default_prev_round_amend_lines(l_auction_header_id,p_batch_id);
    END if;

    IF (is_valid_rule(p_doctype_Id, 'NO_PRICE_QUANTITY_ITEMS')) THEN

       IF (is_valid_rule(p_doctype_Id, 'QUANTITY')) THEN
          -- Quantity should be empty
          insert into PON_INTERFACE_ERRORS
                (interface_type,
                 column_name,
		 error_value,
                 error_message_name,
                 table_name,
                 batch_id,
                 interface_line_id)
          select interface_type,
                 fnd_message.get_string('PON','PON_AUCTS_QUANTITY'),
		 quantity,
                 'PON_AUCTS_PR_QT_NOT_APPLY',
                 'PON_ITEM_PRICES_INTERFACE',
                 batch_id,
                 interface_line_id
          from   pon_item_prices_interface
          where  nvl(price_and_quantity_apply, 'Y') = 'N' and
                 quantity is not null and
                 batch_id = p_batch_id;
       END IF;

       IF (is_valid_rule(p_doctype_Id, 'UNIT_OF_MEASURE')) THEN
          -- UOM should be empty
          insert into PON_INTERFACE_ERRORS
                (interface_type,
                 column_name,
		 error_value,
                 error_message_name,
                 table_name,
                 batch_id,
                 interface_line_id)
          select interface_type,
                 fnd_message.get_string('PON','PON_AUCTION_UOM'),
		 unit_of_measure,
                 'PON_AUCTS_PR_QT_NOT_APPLY',
                 'PON_ITEM_PRICES_INTERFACE',
                 batch_id,
                 interface_line_id
          from   pon_item_prices_interface
          where  nvl(price_and_quantity_apply, 'Y') = 'N' and
                 (unit_of_measure is not null and unit_of_measure <> 'UOM_NONE_ENTERED') and
                 batch_id = p_batch_id;
       END IF;

       IF (is_valid_rule(p_doctype_Id, 'TARGET_PRICE')) THEN
          -- Target Price should be empty
          insert into PON_INTERFACE_ERRORS
                (interface_type,
                 column_name,
		 error_value,
                 error_message_name,
                 table_name,
                 batch_id,
                 interface_line_id)
          select interface_type,
                 fnd_message.get_string('PON','PON_AUCTS_TARGET_PRICE'),
		 target_price,
                 'PON_AUCTS_PR_QT_NOT_APPLY',
                 'PON_ITEM_PRICES_INTERFACE',
                 batch_id,
                 interface_line_id
          from   pon_item_prices_interface
          where  nvl(price_and_quantity_apply, 'Y') = 'N' and
                 target_price is not null and
                 batch_id = p_batch_id;
       END IF;

       IF (is_valid_rule(p_doctype_Id, 'CURRENT_PRICE')) THEN
          -- Current Price should be empty
          insert into PON_INTERFACE_ERRORS
                (interface_type,
                 column_name,
		 error_value,
                 error_message_name,
                 table_name,
                 batch_id,
                 interface_line_id)
          select interface_type,
                 fnd_message.get_string('PON','PON_AUCTS_CURRENT_PRICE'),
                 current_price,
                 'PON_AUCTS_PR_QT_NOT_APPLY',
                 'PON_ITEM_PRICES_INTERFACE',
                  batch_id,
                 interface_line_id
          from   pon_item_prices_interface
          where  nvl(price_and_quantity_apply, 'Y') = 'N' and
                 current_price is not null and
                 batch_id = p_batch_id;
       END IF;

    END IF;

    -- For Line Type Check.
    insert into PON_INTERFACE_ERRORS
  	(interface_type,
  	 column_name,
  	 error_message_name,
  	 table_name,
  	 batch_id,
  	 interface_line_id)
   select interface_type,
  	 fnd_message.get_string('PON','PON_AUC_LINE_TYPE'),
  	 'PON_FIELD_MUST_BE_ENTERED',
  	 'PON_ITEM_PRICES_INTERFACE',
  	 batch_id,
  	 interface_line_id
   from	 pon_item_prices_interface
   where line_type = 'LINE_TYPE_NONE_ENTERED'
   and   batch_id = p_batch_id
   and   group_type <> 'GROUP';

--update the pon_item_prices_interface table

   update pon_item_prices_interface p1
   set (line_type_id,order_type_lookup_code,purchase_basis,outside_operation_flag) =
   (select  nvl(po2.line_type_id,-9999), po2.order_type_lookup_code,po2.purchase_basis,po2.outside_operation_flag
         FROM po_line_types_vl po2 WHERE upper(p1.line_type) = upper(po2.line_type(+))
	 and (po2.inactive_date is null or po2.inactive_date > sysdate))
   where batch_id = p_batch_id
   and line_type <> 'LINE_TYPE_NONE_ENTERED'
   and line_type is not null;


    insert into PON_INTERFACE_ERRORS
  	(interface_type,
  	 column_name,
	 error_value,
  	 error_message_name,
  	 table_name,
  	 batch_id,
  	 interface_line_id)
   select interface_type,
  	 fnd_message.get_string('PON','PON_AUC_LINE_TYPE'),
	 line_type,
  	 'PON_AUC_LINE_TYPE_ERR',
  	 'PON_ITEM_PRICES_INTERFACE',
  	 batch_id,
  	 interface_line_id
   from	 pon_item_prices_interface
   where line_type_id is null
   and line_type <> 'LINE_TYPE_NONE_ENTERED'
   and   batch_id = p_batch_id;


   -- perform the following check if po style has restricted line types
   if (l_line_type_restriction = 'SPECIFIED') then
     insert into PON_INTERFACE_ERRORS
  	(interface_type,
  	 column_name,
	 error_value,
  	 error_message_name,
  	 table_name,
  	 batch_id,
  	 interface_line_id)
     select interface_type,
  	 fnd_message.get_string('PON','PON_AUC_LINE_TYPE'),
	 line_type,
  	 'PON_AUC_LINE_TYPE_ERR',
  	 'PON_ITEM_PRICES_INTERFACE',
  	 batch_id,
  	 interface_line_id
     from	 pon_item_prices_interface
     where line_type_id not in ( select line_type_id
                                   from po_style_enabled_line_types
                                  where style_id = l_po_style_id)
     and line_type_id is not null
     and line_type <> 'LINE_TYPE_NONE_ENTERED'
     and   batch_id = p_batch_id;
   end if;

   -- Bug 4722286.
   -- perform the following check if po style has restricted purchase basis

   if (l_line_type_restriction = 'ALL') then
     insert into PON_INTERFACE_ERRORS
  	(interface_type,
  	 column_name,
	 error_value,
  	 error_message_name,
  	 table_name,
  	 batch_id,
  	 interface_line_id)
     select interface_type,
  	 fnd_message.get_string('PON','PON_AUC_LINE_TYPE'),
	 line_type,
  	 'PON_AUC_LINE_TYPE_ERR',
  	 'PON_ITEM_PRICES_INTERFACE',
  	 batch_id,
  	 interface_line_id
     from pon_item_prices_interface
     where purchase_basis not in ( select purchase_basis
                                   from po_style_enabled_pur_bases
                                  where style_id = l_po_style_id)
     and line_type_id is not null
     and line_type <> 'LINE_TYPE_NONE_ENTERED'
     and   batch_id = p_batch_id;
   end if;

   --
   -- Begin major services lines validation
   --
   -- First, make sure no services lines
   -- are on a standard outcome document
   --
   IF(p_contract_type = 'STANDARD') THEN
      --
      INSERT INTO pon_interface_errors
	(interface_type,
	 column_name,
	 error_value,
	 error_message_name,
	 table_name,
	 batch_id,
	 interface_line_id)
      SELECT interface_type,
	     fnd_message.get_string('PON','PON_AUC_LINE_TYPE'),
	     line_type,
	     'PON_STANDARD_LINE_TYPES',
	     'PON_ITEM_PRICES_INTERFACE',
	     batch_id,
	     interface_line_id
      FROM   pon_item_prices_interface
      WHERE  line_type <> 'LINE_TYPE_NONE_ENTERED'
	AND  batch_id = p_batch_id
	AND  purchase_basis = 'TEMP LABOR';
   END IF;
   --
   IF(p_contract_type = 'BLANKET' OR p_contract_type = 'CONTRACT') AND
     (p_global_flag = 'N') THEN
      INSERT INTO pon_interface_errors
	(interface_type,
	 column_name,
	 error_value,
	 error_message_name,
	 table_name,
	 batch_id,
	 interface_line_id)
      SELECT interface_type,
	     fnd_message.get_string('PON','PON_AUC_LINE_TYPE'),
	     line_type,
	     'PON_GLOBAL_LINE_TYPES',
	     'PON_ITEM_PRICES_INTERFACE',
	     batch_id,
	     interface_line_id
      FROM   pon_item_prices_interface
      WHERE  line_type <> 'LINE_TYPE_NONE_ENTERED'
	AND  batch_id = p_batch_id
	AND  purchase_basis = 'TEMP LABOR';
   END IF;
   --
   -- Do not allow Outside Processing lines for Global Agreements
   --
   IF(p_contract_type = 'BLANKET' and p_global_flag = 'Y') THEN
     insert into pon_interface_errors
              (interface_type,
       column_name,
       error_value,
       error_message_name,
       table_name,
       batch_id,
       interface_line_id)
      SELECT interface_type,
           fnd_message.get_string('PON','PON_AUC_LINE_TYPE'),
           line_type,
           'PON_AUC_GLOBAL_OP_LINE',
           'PON_ITEM_PRICES_INTERFACE',
           batch_id,
           interface_line_id
      FROM   pon_item_prices_interface
      WHERE  line_type <> 'LINE_TYPE_NONE_ENTERED'
      AND  batch_id = p_batch_id
      AND  outside_operation_flag = 'Y';
   END IF;
   --
   -- For Outside Processing lines, the Item is required
   --
   insert into pon_interface_errors
      (interface_type,
       column_name,
       error_value,
       error_message_name,
       table_name,
       batch_id,
       interface_line_id)
   SELECT interface_type,
        fnd_message.get_string('PON','PON_AUCTS_ITEM'),
        null,
        'PON_AUC_OPL_ITEM_REQ',
        'PON_ITEM_PRICES_INTERFACE',
        batch_id,
        interface_line_id
   FROM  pon_item_prices_interface
   WHERE line_type <> 'LINE_TYPE_NONE_ENTERED'
     AND item_number = 'ITEM_NUMBER_NONE_ENTERED'
     AND batch_id = p_batch_id
     AND outside_operation_flag = 'Y';
   --
   -- For temp labor lines, the job is required
   --
   INSERT INTO PON_INTERFACE_ERRORS
	   (interface_type,
	    column_name,
	    error_value,
	    error_message_name,
	    table_name,
	    batch_id,
	    interface_line_id)
    SELECT interface_type,
	   fnd_message.get_string('PON','PON_ITEM_JOB'),
	   '',
	   'PON_LINE_TYPE_JOB_REQ',
	   'PON_ITEM_PRICES_INTERFACE',
	   batch_id,
	   interface_line_id
    FROM   pon_item_prices_interface
    WHERE batch_id = p_batch_id
    AND purchase_basis = 'TEMP LABOR'
    AND item_number = 'ITEM_NUMBER_NONE_ENTERED';
   --
   -- Get job information for Services lines for valid jobs
   -- We are ignoring whatever the user entered for the description and category columns
   -- because there are not enterable on the UI.
   --
   -- First just get the job_id...
   --
   UPDATE pon_item_prices_interface p1
      SET job_id =
	   (SELECT nvl(max(poj.job_id),-1)
	      FROM po_job_associations poj,
		   per_jobs pj,
		   per_jobs_vl pjvl
	     WHERE pjvl.name = p1.item_number AND
                   pjvl.job_id = pj.job_id AND
	           pj.job_id = poj.job_id AND
		   sysdate < nvl(poj.inactive_date, sysdate + 1) AND
		   sysdate between pj.date_from and nvl(pj.date_to, sysdate + 1))
    WHERE batch_id = p_batch_id AND
	  purchase_basis = 'TEMP LABOR' AND
          item_number <> 'ITEM_NUMBER_NONE_ENTERED';
   --
   -- Update the rest of the information for the service lines with job id's
   --
   UPDATE pon_item_prices_interface p1
      SET (item_description, category_name) =
	   (SELECT poj.job_long_description,
       -- for the bug 14771004
       -- Replacing 'FND_FLEX_EXT.get_segs' method call with CONCATENATED_SEGMENTS
		   --FND_FLEX_EXT.get_segs('INV', 'MCAT', CAT.STRUCTURE_ID, CAT.CATEGORY_ID)
	      cat.concatenated_segments
        FROM po_job_associations poj,
		   mtl_categories_kfv cat
	     WHERE cat.category_id = poj.category_id AND
		   poj.job_id = p1.job_id)
    WHERE batch_id = p_batch_id AND
	  purchase_basis = 'TEMP LABOR' AND
          item_number <> 'ITEM_NUMBER_NONE_ENTERED' AND
	  job_id <> -1;
    --
    -- Validate the job
    --
    INSERT INTO  PON_INTERFACE_ERRORS (
	   interface_type,
           column_name,
	   error_value,
	   error_message_name,
	   table_name,
	   batch_id,
	   interface_line_id)
    SELECT interface_type,
	   fnd_message.get_string('PON','PON_ITEM_JOB'),
	   item_number,
	   'PON_JOB_INVALID',
	   'PON_ITEM_PRICES_INTERFACE',
	   batch_id,
	   interface_line_id
    FROM   pon_item_prices_interface p1
    WHERE  batch_id = p_batch_id AND
	   purchase_basis = 'TEMP LABOR' AND
	   item_number <> 'ITEM_NUMBER_NONE_ENTERED' AND
	   job_id = -1;
    --
    -- Set quantity to null for general services lines
    --
    UPDATE pon_item_prices_interface p1
       SET quantity = NULL,
           unit_of_measure = NULL
     WHERE batch_id = p_batch_id
       AND order_type_lookup_code = 'FIXED PRICE'
       AND purchase_basis = 'SERVICES';
    --
    -- Set quantity to null for fixed price temp labor lines
    --
    UPDATE pon_item_prices_interface p1
       SET quantity = null
     WHERE batch_id = p_batch_id
       AND order_type_lookup_code = 'FIXED PRICE'
       AND purchase_basis = 'TEMP LABOR';
    --
    -- Default category, job_description,
    -- additional_job_details for temp labor lines
    --
    UPDATE pon_item_prices_interface p1
       SET (item_description, additional_job_details, category_id, category_name) =
           (SELECT poj.job_description,
	           decode(nvl(p1.additional_job_details,'JOB_DETAILS_NONE_ENTERED'),'JOB_DETAILS_NONE_ENTERED',poj.job_long_description, p1.additional_job_details),
		   cat.category_id,
       -- for the bug 14771004
       -- Replacing 'FND_FLEX_EXT.get_segs' method call with CONCATENATED_SEGMENTS
		   --FND_FLEX_EXT.get_segs('INV', 'MCAT', CAT.STRUCTURE_ID, CAT.CATEGORY_ID)
	     cat.concatenated_segments
      FROM po_job_associations poj,
		   mtl_categories_kfv cat
	      WHERE poj.job_id = p1.job_id
	        AND cat.category_id = poj.category_id)
      WHERE batch_id = p_batch_id AND
	    purchase_basis = 'TEMP LABOR' AND
	    job_id <> -1;
    --
    -- Validate differential response type
    --
    insert into PON_INTERFACE_ERRORS
        (interface_type,
         column_name,
	 error_value,
         error_message_name,
         table_name,
         batch_id,
         interface_line_id)
   select interface_type,
         fnd_message.get_string('PON','PON_PRICE_DIFF_RESPONSE'),
	 differential_response_type,
         'PON_INVALID_DIFF_RESPONSE',
         'PON_ITEM_PRICES_INTERFACE',
         batch_id,
         interface_line_id
   from  pon_item_prices_interface p1
   where batch_id = p_batch_id and
         purchase_basis = 'TEMP LABOR' and
         differential_response_type not in ('DIFF_NONE_ENTERED',
					    fnd_message.get_string('PON','PON_AUCTS_REQUIRED'),
		  		            fnd_message.get_string('PON','PON_AUCTS_OPTIONAL'),
					    fnd_message.get_string('PON','PON_AUCTS_DISPLAY_ONLY'));
    --
    -- clear out the differential response type
    -- if it does not apply
    update pon_item_prices_interface
       set differential_response_type = null
     where batch_id = p_batch_id and
           (purchase_basis = 'TEMP LABOR' and
	    differential_response_type not in (fnd_message.get_string('PON','PON_AUCTS_REQUIRED'),
					      fnd_message.get_string('PON','PON_AUCTS_OPTIONAL'),
					      fnd_message.get_string('PON','PON_AUCTS_DISPLAY_ONLY'))) or
	   (purchase_basis <> 'TEMP LABOR');
    --
    -- End major services validation
    --
   -- checks for invalid item numbers
   -- ignore inventory item related fields for amount based lines

   l_item_number_delimiter := '.';

   insert into PON_INTERFACE_ERRORS
        (interface_type,
         column_name,
	 error_value,
         error_message_name,
         table_name,
         batch_id,
         interface_line_id)
   select interface_type,
         fnd_message.get_string('PON','PON_AUCTS_ITEM'),
	 item_number,
         'PON_AUCTS_SS_INVALID_INV_NUM',
         'PON_ITEM_PRICES_INTERFACE',
         batch_id,
         interface_line_id
   from  pon_item_prices_interface p1
   where batch_id = p_batch_id and
         item_number <> 'ITEM_NUMBER_NONE_ENTERED' and
         upper(order_type_lookup_code) <> upper('AMOUNT') and
         purchase_basis <> 'TEMP LABOR' and
	 order_type_lookup_code <> 'FIXED PRICE' and
         not exists (SELECT '1'
                     FROM   mtl_system_items_kfv msi,
                            mtl_default_sets_view mdsv,
                            mtl_item_categories mic,
                            mtl_categories_kfv mck
                     WHERE  msi.concatenated_segments  = p1.item_number and
                            msi.organization_id = l_inventory_org_id and
                            nvl(msi.outside_operation_flag, 'N') = nvl(p1.outside_operation_flag, 'N') and
                            msi.purchasing_enabled_flag = 'Y' and
                            mdsv.functional_area_id = 2 and
                            mic.inventory_item_id = msi.inventory_item_id and
                            mic.organization_id = msi.organization_id and
                            mic.category_set_id = mdsv.category_set_id and
                            mck.category_id = mic.category_id
                            and mck.enabled_flag = 'Y'
                            and sysdate between nvl(mck.start_date_active, sysdate) and
                                                nvl(mck.end_date_active, sysdate)
                            and nvl(mck.disable_date, sysdate + 1) > sysdate
                            and (mdsv.validate_flag='Y' and mck.category_id in (select mcsv.category_id from mtl_category_set_valid_cats mcsv where mcsv.category_set_id = mdsv.category_set_id) or mdsv.validate_flag <> 'Y'));

   -- set item number and revision to null if this is a group
   update pon_item_prices_interface p1
   set item_number = null,
       item_revision = null
   where batch_id = p_batch_id and
     item_number = 'ITEM_NUMBER_NONE_ENTERED' and
     group_type = 'GROUP';

   -- sets item number and revision to null if item number is invalid or line type is amount based
   -- by setting the item number to null, sourcing one-time item validation will occur for
   -- unit of measure, category, etc..

   update pon_item_prices_interface p1
   set item_number = null,
       item_revision = null
   where batch_id = p_batch_id AND
         purchase_basis = 'SERVICES' or
         (purchase_basis = 'GOODS' AND
          (item_number = 'ITEM_NUMBER_NONE_ENTERED') OR
	  (item_number <> 'ITEM_NUMBER_NONE_ENTERED' and
	   not exists (select '1'
                      from   mtl_system_items_kfv msi,
                             mtl_default_sets_view mdsv,
                             mtl_item_categories mic,
                             mtl_categories_kfv mck
                      where  msi.concatenated_segments  = p1.item_number and
                             msi.organization_id = l_inventory_org_id and
                             nvl(msi.outside_operation_flag, 'N') = nvl(p1.outside_operation_flag, 'N') and
                             msi.purchasing_enabled_flag = 'Y' and
                             mdsv.functional_area_id = 2 and
                             mic.inventory_item_id = msi.inventory_item_id and
                             mic.organization_id = msi.organization_id and
                             mic.category_set_id = mdsv.category_set_id and
                             mck.category_id = mic.category_id
                             and mck.enabled_flag = 'Y'
                             and sysdate between nvl(mck.start_date_active, sysdate) and
                                                 nvl(mck.end_date_active, sysdate)
                             and nvl(mck.disable_date, sysdate + 1) > sysdate
                             and (mdsv.validate_flag='Y' and mck.category_id in (select mcsv.category_id from mtl_category_set_valid_cats mcsv where mcsv.category_set_id = mdsv.category_set_id) or mdsv.validate_flag <> 'Y'))));


   -- set inventory item id, the description update flag, and default the description and unit of measure
   -- it not entered for inventory items

   update pon_item_prices_interface p1
   set (item_id, item_description, allow_item_desc_update_flag, unit_of_measure) =
   (select msi.inventory_item_id,
           decode(p1.item_description, 'ITEM_NONE_ENTERED', msitl.description, p1.item_description),
           msi.allow_item_desc_update_flag,
           decode(p1.unit_of_measure, 'UOM_NONE_ENTERED', uom.unit_of_measure_tl, p1.unit_of_measure)
    from   mtl_system_items_kfv msi,
           mtl_system_items_tl msitl,
           mtl_units_of_measure_tl uom
    where  msi.concatenated_segments  = p1.item_number and
           msi.organization_id = l_inventory_org_id and
           nvl(msi.outside_operation_flag, 'N') = nvl(p1.outside_operation_flag, 'N') and
           msi.purchasing_enabled_flag = 'Y' and
           msi.inventory_item_id = msitl.inventory_item_id and
	   msi.organization_id = msitl.organization_id and
	   msitl.language = p_language and
           msi.primary_uom_code = uom.uom_code and
           uom.language = p_language)
   where batch_id = p_batch_id and
         item_number is not NULL and
         purchase_basis = 'GOODS';

   -- default the category if not entered for valid item numbers

   update pon_item_prices_interface p1
   set category_name = (select
                              -- for the bug 14771004
                              -- Replacing 'FND_FLEX_EXT.get_segs' method call with CONCATENATED_SEGMENTS
                              --FND_FLEX_EXT.get_segs('INV', 'MCAT', MCK.STRUCTURE_ID, MCK.CATEGORY_ID) concatenated_segments
                               mck.concatenated_segments concatenated_segments
                        from   mtl_default_sets_view mdsv,
                               mtl_item_categories mic,
                               mtl_categories_kfv mck
                        where  mdsv.functional_area_id = 2 and
                               mic.inventory_item_id = p1.item_id and
                               mic.organization_id = l_inventory_org_id and
                               mic.category_set_id = mdsv.category_set_id and
                               mck.category_id = mic.category_id)
   where batch_id = p_batch_id and
         purchase_basis <> 'TEMP LABOR' and
         item_number is not null and
         (category_name = 'CAT_NONE_ENTERED' or category_name is null);

   -- validate description for inventory items where the modified flag is set to false

   insert into PON_INTERFACE_ERRORS
        (interface_type,
         column_name,
	 error_value,
         error_message_name,
         table_name,
         batch_id,
         interface_line_id)
   select interface_type,
         fnd_message.get_string('PON','PON_AUCTS_ITEM_DESC'),
	 item_description,
         'PON_AUCTS_INVALID_INV_DESC',
         'PON_ITEM_PRICES_INTERFACE',
         batch_id,
         interface_line_id
   from  pon_item_prices_interface p1
   where batch_id = p_batch_id and
         purchase_basis <> 'TEMP LABOR' and
         item_number is not null and
         allow_item_desc_update_flag = 'N' and
         item_description <> (select msitl.description
                              from   mtl_system_items_kfv msi,
			             mtl_system_items_tl msitl
                              where  msi.inventory_item_id = p1.item_id and
                                     msi.organization_id = l_inventory_org_id and
                                     msi.inventory_item_id = msitl.inventory_item_id and
				     msi.organization_id = msitl.organization_id and
                                     msitl.language = p_language);

   -- validate revision for inventory items

   insert into PON_INTERFACE_ERRORS
        (interface_type,
         column_name,
	 error_value,
         error_message_name,
         table_name,
         batch_id,
         interface_line_id)
   select interface_type,
         fnd_message.get_string('PON','PON_AUCTS_REVISION'),
	 item_revision,
         'PON_AUCTS_INVALID_INV_REV',
         'PON_ITEM_PRICES_INTERFACE',
         batch_id,
         interface_line_id
   from  pon_item_prices_interface p1
   where batch_id = p_batch_id and
         purchase_basis <> 'TEMP LABOR' and
         item_number is not null and
         item_revision not in (select   revision
                                 from   mtl_item_revisions_all_v
                                 where  inventory_item_id = p1.item_id and
                                        organization_id = l_inventory_org_id);


   update pon_item_prices_interface p1
   set CATEGORY_NAME =  (select
                               -- for the bug 14771004
                               -- Replacing 'FND_FLEX_EXT.get_segs' method call with CONCATENATED_SEGMENTS
                               --FND_FLEX_EXT.get_segs('INV', 'MCAT', MCK.STRUCTURE_ID, MCK.CATEGORY_ID) concatenated_segments
                                mck.concatenated_segments concatenated_segments
                         from
                              MTL_CATEGORIES_KFV mck
                              ,PO_LINE_TYPES plt
                         where
                             plt.line_type_id = p1.line_type_id
                             and plt.category_id = mck.category_id)
   where batch_id = p_batch_id
   and ((CATEGORY_NAME = 'CAT_NONE_ENTERED') or (CATEGORY_NAME is null));

   update pon_item_prices_interface p1
   set UNIT_OF_MEASURE =  nvl(l_amount_based_unit_of_measure,'UOM_NONE_ENTERED')
   where batch_id = p_batch_id
   and ((UNIT_OF_MEASURE = 'UOM_NONE_ENTERED') or (UNIT_OF_MEASURE is null))
   and ( upper(order_type_lookup_code) = upper('AMOUNT'));

   update pon_item_prices_interface p1
   set UNIT_OF_MEASURE = (select plt.unit_of_measure
                           from
                               PO_LINE_TYPES plt
                           where
                               plt.line_type_id = p1.line_type_id)
   where batch_id = p_batch_id
   and ((UNIT_OF_MEASURE = 'UOM_NONE_ENTERED') or (UNIT_OF_MEASURE is null));


   INSERT INTO PON_INTERFACE_ERRORS
           ( interface_type
           , column_name
	   , error_value
           , error_message_name
           , table_name
           , batch_id
           , interface_line_id
           )
   SELECT INTERFACE_TYPE
          , fnd_message.get_string('PON','PON_AUCTION_UOM')
	  , unit_of_measure
          , 'PON_AUC_LINE_UOM_ERR'
          , 'PON_ITEM_PRICES_INTERFACE'
          , BATCH_ID
          , INTERFACE_LINE_ID
   FROM pon_item_prices_interface
   where batch_id = p_batch_id
   and   nvl(price_and_quantity_apply, 'Y') = 'Y'
   and   order_type_lookup_code = 'AMOUNT'
   and NOT((upper(UNIT_OF_MEASURE) =  UPPER(l_amount_based_uom) ) or
         (upper(UNIT_OF_MEASURE) =  UPPER(l_amount_based_unit_of_measure) )) ;

   INSERT INTO PON_INTERFACE_ERRORS
           ( interface_type
           , column_name
	   , error_value
           , error_message_name
           , table_name
           , batch_id
           , interface_line_id
           )
   SELECT
          INTERFACE_TYPE
          , fnd_message.get_string('PON',decode(p_contract_type,'STANDARD','PON_AUCTS_QUANTITY','PON_AUCTS_EST_QUANTITY'))
	  , quantity
          , 'PON_AUC_LINE_QUAN_ERR'
          , 'PON_ITEM_PRICES_INTERFACE'
          , BATCH_ID
          , INTERFACE_LINE_ID
   FROM pon_item_prices_interface
   where batch_id = p_batch_id
   and nvl(price_and_quantity_apply, 'Y') = 'Y'
   and ( upper(order_type_lookup_code) = upper('AMOUNT'))
   and ( NOT(nvl(quantity,-1) = 1)) ;

   -- END Line Type Check

    IF (is_valid_rule(p_doctype_Id, 'CATEGORY')) THEN
  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select	 interface_type,
  		 fnd_message.get_string('PON','PON_AUCTS_CATEGORY'),
  		 'PON_FIELD_MUST_BE_ENTERED',
  		 'PON_ITEM_PRICES_INTERFACE',
  		 batch_id,
  		 interface_line_id
  	from 	 pon_item_prices_interface
  	where	 ((category_name = 'CAT_NONE_ENTERED') or (category_name is null))
  	AND   batch_id = p_batch_id
        and   group_type <> 'GROUP';

        -- First we do case insensitive to avoid full table scan on MTL_CATEGORIES_KFV
  	update pon_item_prices_interface p
  	set category_id = (select Nvl(MAX(MCK.category_id),-1)
                           FROM (select category_id,
                                        -- for the bug 14771004
                                        -- Replacing 'FND_FLEX_EXT.get_segs' method call with CONCATENATED_SEGMENTS
                                        --FND_FLEX_EXT.get_segs('INV', 'MCAT', STRUCTURE_ID, CATEGORY_ID) CONCATENATED_SEGMENTS,
                                        CONCATENATED_SEGMENTS CONCATENATED_SEGMENTS,
                                        ENABLED_FLAG,
                                        START_DATE_ACTIVE,
                                        END_DATE_ACTIVE,
                                        STRUCTURE_ID,
                                        DISABLE_DATE
                                 from   MTL_CATEGORIES_KFV) MCK,
                           MTL_CATEGORY_SETS MCS,
                           MTL_DEFAULT_CATEGORY_SETS MDCS,
                           MTL_CATEGORIES MC
                           WHERE MCK.CONCATENATED_SEGMENTS = p.category_name
                           AND MCK.ENABLED_FLAG = 'Y'
                           AND SYSDATE BETWEEN NVL(MCK.START_DATE_ACTIVE, SYSDATE) AND
                           NVL(MCK.END_DATE_ACTIVE, SYSDATE) AND
                           MCS.CATEGORY_SET_id=MDCS.CATEGORY_SET_ID AND
                           MDCS.FUNCTIONAL_AREA_ID=2 AND MCK.STRUCTURE_ID=MCS.STRUCTURE_ID
                           AND NVL(mck.DISABLE_DATE, SYSDATE + 1) > SYSDATE
                           AND (MCS.VALIDATE_FLAG='Y' AND mck.CATEGORY_ID IN
                           (SELECT MCSV.CATEGORY_ID FROM MTL_CATEGORY_SET_VALID_CATS MCSV WHERE
                           MCSV.CATEGORY_SET_ID=MCS.CATEGORY_SET_ID) OR MCS.VALIDATE_FLAG <> 'Y')
                           AND MC.CATEGORY_ID = MCK.CATEGORY_ID)
        where batch_id = p_batch_id
        and category_name <> 'CAT_NON_ENTERED';

        -- For those which were not caught in the previous SQL
  	update pon_item_prices_interface p
  	set category_id = (select Nvl(MAX(MCK.category_id),-1)
                           FROM (select category_id,
                                        -- for the bug 14771004
                                        -- Replacing 'FND_FLEX_EXT.get_segs' method call with CONCATENATED_SEGMENTS
                                        --FND_FLEX_EXT.get_segs('INV', 'MCAT', STRUCTURE_ID, CATEGORY_ID) CONCATENATED_SEGMENTS,
                                        CONCATENATED_SEGMENTS CONCATENATED_SEGMENTS,
                                        ENABLED_FLAG,
                                        START_DATE_ACTIVE,
                                        END_DATE_ACTIVE,
                                        STRUCTURE_ID,
                                        DISABLE_DATE
                                 from   MTL_CATEGORIES_KFV) MCK,
                           MTL_CATEGORY_SETS MCS,
                           MTL_DEFAULT_CATEGORY_SETS MDCS,
                           MTL_CATEGORIES MC
                           WHERE UPPER(MCK.CONCATENATED_SEGMENTS) = UPPER(p.category_name)
                           AND MCK.ENABLED_FLAG = 'Y'
                           AND SYSDATE BETWEEN NVL(MCK.START_DATE_ACTIVE, SYSDATE) AND
                           NVL(MCK.END_DATE_ACTIVE, SYSDATE) AND
                           MCS.CATEGORY_SET_id=MDCS.CATEGORY_SET_ID AND
                           MDCS.FUNCTIONAL_AREA_ID=2 AND MCK.STRUCTURE_ID=MCS.STRUCTURE_ID
                           AND NVL(mck.DISABLE_DATE, SYSDATE + 1) > SYSDATE
                           AND (MCS.VALIDATE_FLAG='Y' AND mck.CATEGORY_ID IN
                           (SELECT MCSV.CATEGORY_ID FROM MTL_CATEGORY_SET_VALID_CATS MCSV WHERE
                           MCSV.CATEGORY_SET_ID=MCS.CATEGORY_SET_ID) OR MCS.VALIDATE_FLAG <> 'Y')
                           AND MC.CATEGORY_ID = MCK.CATEGORY_ID)
        where batch_id = p_batch_id
        and category_name <> 'CAT_NON_ENTERED'
        and ( category_id is null or category_id = -1 );
--
	-- Because we do case insensitive validation for category_name,
	-- we need to update all valid user entered category names to the
	-- actual case sensitive value
        /*
	update pon_item_prices_interface p
	  set category_name = (select Nvl(MAX(category_name),p.category_name)
			       from icx_por_categories_tl i
			       where i.rt_category_id = p.category_id
			       and type=2 and i.language= p_language)
	  where batch_id = p_batch_id
	  and category_name <> 'CAT_NON_ENTERED'
	  AND category_id <> -1;
        */
	update pon_item_prices_interface p
	  set category_name = (select
                                -- for the bug 14771004
                                -- Replacing 'FND_FLEX_EXT.get_segs' method call with CONCATENATED_SEGMENTS
                                --Nvl(MAX(FND_FLEX_EXT.get_segs('INV', 'MCAT', i.STRUCTURE_ID, i.CATEGORY_ID)),p.category_name)
                                Nvl(MAX(i.CONCATENATED_SEGMENTS),p.category_name)
			       from mtl_categories_kfv i
			       where i.category_id = p.category_id)
	  where batch_id = p_batch_id
	  and category_name <> 'CAT_NON_ENTERED'
	  AND category_id <> -1;

  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
		 error_value,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
    	select 	interface_type,
  		fnd_message.get_string('PON','PON_AUCTS_CATEGORY'),
		category_name,
		decode(purchase_basis,'TEMP LABOR','PON_INVALID_TEMP_LABOR_CAT','PON_CATEGORY_ID_NOT_FOUND'),
  		'PON_ITEM_PRICES_INTERFACE',
  		batch_id,
  		interface_line_id
  	from	pon_item_prices_interface
  	where 	category_id = -1
  	  AND   batch_id = p_batch_id
  	  AND   category_name <> 'CAT_NON_ENTERED';

        -- validate category name for inventory items

        insert into PON_INTERFACE_ERRORS
             (interface_type,
              column_name,
	      error_value,
              error_message_name,
              table_name,
              batch_id,
              interface_line_id)
        select interface_type,
              fnd_message.get_string('PON','PON_AUCTS_CATEGORY'),
	      category_name,
              'PON_AUCTS_INVALID_INV_CAT',
              'PON_ITEM_PRICES_INTERFACE',
              batch_id,
              interface_line_id
        from  pon_item_prices_interface p1
        where category_id <> -1 and
              batch_id = p_batch_id and
              purchase_basis <> 'TEMP LABOR' and
	      order_type_lookup_code <> 'FIXED PRICE' and
              item_number is not null and
              category_name <> (select
                                       -- for the bug 14771004
                                       -- Replacing 'FND_FLEX_EXT.get_segs' method call with CONCATENATED_SEGMENTS
                                       --FND_FLEX_EXT.get_segs('INV', 'MCAT', MCK.STRUCTURE_ID, MCK.CATEGORY_ID) concatenated_segments
                                       MCK.CONCATENATED_SEGMENTS concatenated_segments
                                from   mtl_default_sets_view mdsv,
                                       mtl_item_categories mic,
                                       mtl_categories_kfv mck
                                where  mdsv.functional_area_id = 2 and
                                       mic.inventory_item_id = p1.item_id and
                                       mic.organization_id = l_inventory_org_id and
                                       mic.category_set_id = mdsv.category_set_id and
                                       mck.category_id = mic.category_id);



    END IF;


    IF (p_contract_type in ('BLANKET', 'CONTRACT')) THEN

      -- default shopping category (ip category) using purchasing-iP category mappings
      -- when shopping category is missing...only for new lines since shopping category
      -- is optional
      IF (NVL(l_progress_payment_type,'NONE') = 'NONE') THEN
        update pon_item_prices_interface p1
        set    ip_category_name = (select category_name
                                   from   icx_cat_categories_v
                                   where  rt_category_id = decode(pon_auction_pkg.get_mapped_ip_category(p1.category_id), -2, null, pon_auction_pkg.get_mapped_ip_category(p1.category_id))   and
                                          language = p_language)
        where  batch_id = p_batch_id and
               (action is null or action = '+') and
               p1.category_id <> -1 and
               (p1.ip_category_name is null or p1.ip_category_name = 'IP_CAT_NONE_ENTERED');

        -- iP category needs to be valid

        insert into PON_INTERFACE_ERRORS
                (interface_type,
                 column_name,
                 error_message_name,
                 table_name,
                 batch_id,
                 interface_line_id)
        select  interface_type,
                fnd_message.get_string('PON','PON_SHOPPING_CAT'),
                'PON_SHOP_CAT_NOT_VALID',
                'PON_ITEM_PRICES_INTERFACE',
                batch_id,
                interface_line_id
        from    pon_item_prices_interface p1
        where   p1.batch_id = p_batch_id and
                p1.ip_category_name is not null and
                p1.ip_category_name <> 'IP_CAT_NONE_ENTERED' and
                not exists (select null
                            from   icx_cat_categories_v icx
                            where  icx.category_name = p1.ip_category_name and
                                   icx.language = p_language);

        -- set ip category name to null if ip cateogry is invalid

        update pon_item_prices_interface p1
        set    ip_category_name = null
        where  p1.batch_id = p_batch_id and
               p1.ip_category_name is not null and
               p1.ip_category_name <> 'IP_CAT_NONE_ENTERED' and
               not exists (select null
                           from   icx_cat_categories_v icx
                           where  icx.category_name = p1.ip_category_name and
                                  icx.language = p_language);

        -- set ip category id
        update pon_item_prices_interface p1
        set    ip_category_id = (select rt_category_id
                                 from   icx_cat_categories_v icx
                                 where  icx.category_name = p1.ip_category_name and
                                        language = p_language  and rownum=1)
        where  p1.batch_id = p_batch_id and
               p1.ip_category_name is not null and
               p1.ip_category_name <> 'IP_CAT_NONE_ENTERED';
      END IF; -- If progress payment type is NONE(i.e non complex work style)
    END IF;

--
  -- Item description can't be null
--
  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
    	select 	interface_type,
  		fnd_message.get_string('PON','PON_AUCTS_ITEM_DESC'),
  		'PON_FIELD_MUST_BE_ENTERED',
  		'PON_ITEM_PRICES_INTERFACE',
  		batch_id,
  		interface_line_id
  	from	pon_item_prices_interface
  	where 	item_description = 'ITEM_NONE_ENTERED'
  	  AND   batch_id = p_batch_id
          and   nvl(purchase_basis,'NULL') <> 'TEMP LABOR';

        update pon_item_prices_interface p1
        set    item_description = null
        where batch_id = p_batch_id and
              item_description = 'ITEM_NONE_ENTERED';

--
--
  -- Unit of Measure
  -- AUCTION and BID --
--
    IF (is_valid_rule(p_doctype_Id, 'UNIT_OF_MEASURE')) THEN
  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select	 interface_type,
  		 fnd_message.get_string('PON','PON_ORDER_UNIT_H'),
  		 'PON_FIELD_MUST_BE_ENTERED',
  		 'PON_ITEM_PRICES_INTERFACE',
  		 batch_id,
  		 interface_line_id
  	from 	 pon_item_prices_interface
  	where	 ((unit_of_measure = 'UOM_NONE_ENTERED') or (unit_of_measure is null))
          AND   nvl(price_and_quantity_apply, 'Y') = 'Y'
          AND   order_type_lookup_code <> 'FIXED PRICE'
  	  AND   batch_id = p_batch_id
          and   group_type <> 'GROUP';
--
  -- Unit of Measure must be valid in mtl_units_of_measure_tl
--
        -- Some modifications to avoid full table scan and more imp
        -- to incorporate the new demand in bug 2319969
  	update pon_item_prices_interface p
  	   set uom_code = (select nvl(max(uom_code),'XXX') from
  			     mtl_units_of_measure_tl m
  			     where language = p_language
  			     and unit_of_measure_tl = p.unit_of_measure
                             and (p.purchase_basis <> 'TEMP LABOR' or
                                  (p.purchase_basis = 'TEMP LABOR' and
                                    exists (select 1 from mtl_uom_conversions_val_v where
                                     m.unit_of_measure = unit_of_measure and
                                     uom_class = FND_PROFILE.VALUE('PO_RATE_UOM_CLASS')))))
        where batch_id = p_batch_id
        and unit_of_measure <> 'UOM_NONE_ENTERED';
--
  	update pon_item_prices_interface p
  	   set uom_code = (select nvl(max(uom_code),'XXX') from
  			     mtl_units_of_measure_tl m
  			     where language = p_language
  			     and upper(unit_of_measure_tl) = upper(p.unit_of_measure)
                             and (p.purchase_basis <> 'TEMP LABOR' or
                                  (p.purchase_basis = 'TEMP LABOR' and
                                    exists (select 1 from mtl_uom_conversions_val_v where
                                     m.unit_of_measure = unit_of_measure and
                                     uom_class = FND_PROFILE.VALUE('PO_RATE_UOM_CLASS')))))
        where batch_id = p_batch_id
        and unit_of_measure <> 'UOM_NONE_ENTERED'
        and uom_code = 'XXX';
--
  	update pon_item_prices_interface p
  	   set uom_code = (select nvl(max(uom_code),'XXX') from
  			     mtl_units_of_measure_tl m
  			     where language = p_language
  			     and uom_code = p.unit_of_measure
                             and (p.purchase_basis <> 'TEMP LABOR' or
                                  (p.purchase_basis = 'TEMP LABOR' and
                                    exists (select 1 from mtl_uom_conversions_val_v where
                                     m.unit_of_measure = unit_of_measure and
                                     uom_class = FND_PROFILE.VALUE('PO_RATE_UOM_CLASS')))))
        where batch_id = p_batch_id
        and unit_of_measure <> 'UOM_NONE_ENTERED'
        and uom_code = 'XXX';
--
  	update pon_item_prices_interface p
  	   set uom_code = (select nvl(max(uom_code),'XXX') from
  			     mtl_units_of_measure_tl m
  			     where language = p_language
  			     and upper(uom_code) = upper(p.unit_of_measure)
                             and (p.purchase_basis <> 'TEMP LABOR' or
                                  (p.purchase_basis = 'TEMP LABOR' and
                                    exists (select 1 from mtl_uom_conversions_val_v where
                                     m.unit_of_measure = unit_of_measure and
                                     uom_class = FND_PROFILE.VALUE('PO_RATE_UOM_CLASS')))))
        where batch_id = p_batch_id
        and unit_of_measure <> 'UOM_NONE_ENTERED'
        and uom_code = 'XXX';

--

	-- Because we do case insensitive validation for uom_code,
	-- we need to update all valid user entered unit of measures to the
	-- actual case sensitive value
	update pon_item_prices_interface p
	   set unit_of_measure = (select nvl(max(unit_of_measure_tl),p.unit_of_measure) from
				  mtl_units_of_measure_tl m
				  where language = p_language
				  and uom_code = p.uom_code)
          where batch_id = p_batch_id
	  and unit_of_measure <> 'UOM_NONE_ENTERED'
	  AND uom_code <> 'XXX';

  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
		 error_value,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select	 interface_type,
  		 fnd_message.get_string('PON','PON_AUCTION_UOM'),
		 unit_of_measure,
  		 decode(purchase_basis,'TEMP LABOR','PON_INVALID_TEMP_LABOR_UOM','PON_INVALID_UOM'),
  		 'PON_ITEM_PRICES_INTERFACE',
  		 batch_id,
  		 interface_line_id
  	from 	 pon_item_prices_interface p
  	where	unit_of_measure <> 'UOM_NONE_ENTERED'
  	  AND   batch_id = p_batch_id
  	  AND   uom_code = 'XXX'
          AND   nvl(price_and_quantity_apply, 'Y') = 'Y';

        -- validate unit of measure for inventory items

        insert into PON_INTERFACE_ERRORS
             (interface_type,
              column_name,
	      error_value,
              error_message_name,
              table_name,
              batch_id,
              interface_line_id)
        select interface_type,
              fnd_message.get_string('PON','PON_AUCTION_UOM'),
	      unit_of_measure,
              'PON_AUCTS_INVALID_INV_UOM',
              'PON_ITEM_PRICES_INTERFACE',
              batch_id,
              interface_line_id
        from  pon_item_prices_interface p1
        where batch_id = p_batch_id and
	      purchase_basis <> 'TEMP LABOR' and
              item_number is not null and
              uom_code not in (select uom_code
                               from   mtl_item_uoms_view
                               where  inventory_item_id = p1.item_id and
                                      organization_id = l_inventory_org_id) and
              nvl(price_and_quantity_apply, 'Y') = 'Y';

        -- Defaulting of Unit of Measure still occurs for lines where quantity and price don't apply
        -- For these lines, we will reset the unit of measure fields
        IF (is_valid_rule(p_doctype_Id, 'NO_PRICE_QUANTITY_ITEMS')) THEN
            update pon_item_prices_interface p1
            set    unit_of_measure = null,
                   uom_code = null
            where  batch_id = p_batch_id and
                   nvl(price_and_quantity_apply, 'Y') = 'N';
        END IF;

    END IF;

--
  -- bug 3353248
  -- check quantity can't be null under certain conditions.
  --
--
   if (p_contract_type = 'STANDARD' or p_contract_type is null) then
        insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
    	select 	interface_type,
  		fnd_message.get_string('PON','PON_AUCTS_QUANTITY'),
  		'PON_FIELD_MUST_BE_ENTERED',
  		'PON_ITEM_PRICES_INTERFACE',
  		batch_id,
  		interface_line_id
  	from	pon_item_prices_interface
  	where 	quantity is null
          and   nvl(price_and_quantity_apply, 'Y') = 'Y'
  	  and   batch_id = p_batch_id
          and   purchase_basis <> 'TEMP LABOR'
          and   order_type_lookup_code <> 'AMOUNT'
          and   order_type_lookup_code <> 'FIXED PRICE'
          and   group_type <> 'GROUP';
    end if;

    -- quantity cannot also be null if line is neither fixed-price based nor amount-based and it has a fixed amount price factor
    IF (p_contract_type IN ('BLANKET', 'CONTRACT')) THEN
      INSERT INTO pon_interface_errors
        (interface_type,
         column_name,
         error_value,
         error_message_name,
         token1_name,
         token1_value,
         table_name,
         batch_id,
         interface_line_id)
      SELECT
        interface_type,
        fnd_message.get_string('PON', 'PON_AUCTS_EST_QUANTITY'),
        quantity,
        'PON_AUC_QUAN_FIXED_AMT',
        'LINENUM',
        interface_line_id,
        'PON_ITEM_PRICES_INTERFACE',
        batch_id,
        interface_line_id
      FROM pon_item_prices_interface
      WHERE
            quantity IS NULL
        AND order_type_lookup_code <> 'FIXED PRICE'
        AND order_type_lookup_code <> 'AMOUNT'
        AND nvl(price_and_quantity_apply, 'Y') = 'Y'
        AND	batch_id = p_batch_id
        AND EXISTS (SELECT 1
                    FROM
                      pon_auc_price_elements_int pfs,
                      fnd_lookup_values lookups
                    WHERE
                          pfs.batch_id = pon_item_prices_interface.batch_id
                      AND pfs.auction_header_id = pon_item_prices_interface.auction_header_id
                      AND pfs.interface_line_id = pon_item_prices_interface.interface_line_id
                      AND lookups.lookup_type = 'PON_PRICING_BASIS'
                      AND lookups.lookup_code = 'FIXED_AMOUNT'
                      AND lookups.view_application_id = 0
                      AND lookups.security_group_id = 0
                      AND lookups.meaning = pfs.pricing_basis_name
                      AND lookups.language = USERENV('LANG'));
    END IF;

  -- Quantity > 0 --
  -- AUCTION and BID --
--
    IF (is_valid_rule(p_doctype_Id, 'QUANTITY')) THEN
  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
		 error_value,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select 	interface_type,
  		decode(p_contract_type, 'BLANKET','PON_AUCTS_EST_QUANTITY', 'CONTRACT', 'PON_AUCTS_EST_QUANTITY', 'PON_AUCTS_QUANTITY'),
		quantity,
  		'PON_MUST_BE_POSITIVE_NUMBER',
  		'PON_ITEM_PRICES_INTERFACE',
  		batch_id,
  		interface_line_id
  	from 	pon_item_prices_interface
  	where 	quantity <= 0
	  AND   order_type_lookup_code <> 'FIXED PRICE'
          AND   nvl(price_and_quantity_apply, 'Y') = 'Y'
  	  AND	batch_id = p_batch_id;

    END IF;
--
--
  -- Need by date > sysdate --
  -- AUCTION only --
--
    IF (is_valid_rule(p_doctype_Id, 'NEED_BY_DATE')) THEN
        -- NEED_BY_FROM_DATE
        insert into PON_INTERFACE_ERRORS
                (interface_type,
                 column_name,
		 error_value,
                 error_message_name,
                 table_name,
                 batch_id,
                 interface_line_id)
        select  interface_type,
                fnd_message.get_string('PON','PON_AUC_NEED_BY_FROM_DATE'),
		need_by_start_date,
                'PON_DATE_MUST_BE_GT_TODAY',
                'PON_ITEM_PRICES_INTERFACE',
                batch_id,
                interface_line_id
        from    pon_item_prices_interface
        where   need_by_start_date < sysdate
         and    batch_id = p_batch_id;
        --
        -- NEED_BY_TO_DATE
        insert into PON_INTERFACE_ERRORS
                (interface_type,
                 column_name,
		 error_value,
                 error_message_name,
                 table_name,
                 batch_id,
                 interface_line_id)
        select  interface_type,
                fnd_message.get_string('PON','PON_AUC_NEED_BY_TO_DATE'),
		need_by_date,
                'PON_DATE_MUST_BE_GT_TODAY',
                'PON_ITEM_PRICES_INTERFACE',
                batch_id,
                interface_line_id
        from    pon_item_prices_interface
        where   need_by_date < sysdate
         and    batch_id = p_batch_id;
        --
        -- NEED_BY_TO_DATE vs NEED_BY_FROM_DATE
        insert into PON_INTERFACE_ERRORS
                (interface_type,
                 column_name,
		 error_value,
                 error_message_name,
                 table_name,
                 batch_id,
                 interface_line_id)
        select  interface_type,
                fnd_message.get_string('PON','PON_AUC_NEED_BY_TO_DATE'),
		        need_by_date,
                'PON_AUC_NEEDBY_BEFORE_FROM_SS',
                'PON_ITEM_PRICES_INTERFACE',
                batch_id,
                interface_line_id
        from    pon_item_prices_interface
        where   need_by_date < need_by_start_date
         and    batch_id = p_batch_id;
        --
        -- need by required for planned inventory items for SPO
      IF(p_contract_type = 'STANDARD') THEN
        insert into PON_INTERFACE_ERRORS
                (interface_type,
                 column_name,
		 error_value,
                 error_message_name,
                 table_name,
                 batch_id,
                 interface_line_id)
        select  ip.interface_type,
                fnd_message.get_string('PON','PON_AUCTS_NEEDBY'),
		null,
                'PON_NEED_BY_DATE_REQ_SPD',
                'PON_ITEM_PRICES_INTERFACE',
                ip.batch_id,
                ip.interface_line_id
        from    pon_item_prices_interface ip
        where   ip.batch_id = p_batch_id
         and    ip.need_by_date is null
         and    ip.need_by_start_date is null
         and    ip.item_id is not null
         and    exists ( SELECT 'x'
                           FROM mtl_system_items_kfv msi,
                                financials_system_params_all fsp
                          WHERE nvl(fsp.org_id, -9999) = nvl(p_org_id,-9999)
                            and msi.organization_id = fsp.inventory_organization_id
                            and msi.inventory_item_id = ip.item_id
                            and (msi.INVENTORY_PLANNING_CODE in (1, 2) or msi.MRP_PLANNING_CODE in
                                  (3, 4, 7, 8, 9))
                       );
      END IF;
    END IF;
--
  -- Ship to location, validating non null, auction only --
  -- The validation is needed for standard po only as ship-to location is
  -- removed for blanket/contract purchase  agreement.
--
    IF (is_valid_rule(p_doctype_Id, 'SHIP_TO_LOCATION') and (p_contract_type is null or p_contract_type = 'STANDARD')) THEN

       IF (is_required_rule(p_doctype_Id, 'SHIP_TO_LOCATION')) THEN
          insert into PON_INTERFACE_ERRORS
                 ( interface_type
                 , column_name
                 , error_message_name
                 , table_name
                 , batch_id
                 , interface_line_id
                 )
          select   interface_type
                 , fnd_message.get_string('PON','PON_AUCTS_SHIP_TO_LOC')
                 , 'PON_FIELD_MUST_BE_ENTERED'
                 , 'PON_ITEM_PRICES_INTERFACE'
                 , batch_id
                 , interface_line_id
          from  pon_item_prices_interface
          where batch_id = p_batch_id
          AND ship_to_location = 'SHIP_NONE_ENTERED'
          and group_type <> 'GROUP';
       END IF;
-- fph
        -- again to avoid some full table scan
  	update pon_item_prices_interface p
  	set ship_to_location_id = (select (nvl(max(location_id), -1))
				     from po_ship_to_loc_org_v po_v
				     where po_v.location_code = p.ship_to_location)
  	  where batch_id = p_batch_id
              and ship_to_location <> 'SHIP_NONE_ENTERED';
--
  	update pon_item_prices_interface p
  	set ship_to_location_id = (select (nvl(max(location_id), -1))
				     from po_ship_to_loc_org_v po_v
				     where upper(po_v.location_code) = upper(p.ship_to_location))
  	  where batch_id = p_batch_id
              and ship_to_location <> 'SHIP_NONE_ENTERED'
              and ship_to_location_id = -1;
--
	-- Because we do case insensitive validation for ship_to_location,
	-- we need to update all valid user entered shipping locations to the
	-- actual case sensitive value fph
	update pon_item_prices_interface p
	set ship_to_location = (select (nvl(max(location_code), -1))
				     from po_ship_to_loc_org_v po_v
				     where po_v.location_id = p.ship_to_location_id)
	  where batch_id = p_batch_id
	  and ship_to_location <> 'SHIP_NONE_ENTERED'
	  AND ship_to_location_id <> -1;
--
--

  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
		 error_value,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select	 interface_type,
  		 fnd_message.get_string('PON','PON_AUCTS_SHIP_TO_LOC'),
		 ship_to_location,
  		 'PON_CAT_INVALID_VALUE',
  		 'PON_ITEM_PRICES_INTERFACE',
  		 batch_id,
  		 interface_line_id
  	from 	 pon_item_prices_interface
  	where ship_to_location_id = -1
  	  AND ship_to_location <> 'SHIP_NONE_ENTERED'
  	  AND batch_id = p_batch_id;

   END IF;
--
  -- Target price NOT <=0 --
  -- AUCTION only --
--
    IF (is_valid_rule(p_doctype_Id, 'TARGET_PRICE')) THEN
  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
		 error_value,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select 	interface_type,
  		fnd_message.get_string('PON','PON_AUCTS_TARGET_PRICE'),
		target_price,
  		'PON_MUST_BE_POSITIVE_NUMBER',
  		'PON_ITEM_PRICES_INTERFACE',
  		batch_id,
  		interface_line_id
  	from 	pon_item_prices_interface
  	where	TARGET_PRICE <= 0
         and    nvl(price_and_quantity_apply, 'Y') = 'Y'
  	 and    batch_id = p_batch_id;
    END IF;
--
  -- Bid start price NOT <=0 --
  -- AUCTION only --
--
    IF (is_valid_rule(p_doctype_Id, 'START_PRICE')) THEN
  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
		 error_value,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select 	interface_type,
  		fnd_message.get_string('PON','PON_AUCTION_BID_START_PRICE'),
		bid_start_price,
  		'PON_MUST_BE_POSITIVE_NUMBER',
  		'PON_ITEM_PRICES_INTERFACE',
  		batch_id,
  		interface_line_id
  	from 	pon_item_prices_interface
  	where 	bid_start_price <= 0
            and   batch_id = p_batch_id;
    END IF;
--
  -- Current price NOT <=0 --
  -- AUCTION/RFQs/Offers --
--
    IF (is_valid_rule(p_doctype_Id, 'CURRENT_PRICE')) THEN
  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
		 error_value,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select 	interface_type,
  		fnd_message.get_string('PON','PON_AUCTS_CURRENT_PRICE'),
		current_price,
  		'PON_MUST_BE_POSITIVE_NUMBER',
  		'PON_ITEM_PRICES_INTERFACE',
  		batch_id,
  		interface_line_id
  	from 	pon_item_prices_interface
  	where 	current_price <= 0
            and   nvl(price_and_quantity_apply, 'Y') = 'Y'
            and   batch_id = p_batch_id;
    END IF;
--
  -- reserve price NOT <=0 --
  -- AUCTION only --
--
    IF (is_valid_rule(p_doctype_Id, 'RESERVE_PRICE')) THEN
  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
		 error_value,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select 	interface_type,
  		fnd_message.get_string('PON','PON_AUCTS_RESERVE_PRICE'),
		reserve_price,
  		'PON_MUST_BE_POSITIVE_NUMBER',
  		'PON_ITEM_PRICES_INTERFACE',
  		batch_id,
  		interface_line_id
  	from 	pon_item_prices_interface
  	where 	reserve_price <= 0 AND
  		batch_id = p_batch_id;
    END IF;
--
--
  -- get the transaction type
     SELECT TRANSACTION_TYPE
     INTO l_transaction_type
     FROM PON_AUC_DOCTYPES
     WHERE DOCTYPE_ID = p_doctype_Id;
--
    -- DBMS_OUTPUT.PUT_LINE('l_transaction_type = ' || l_transaction_type);
     IF(l_transaction_type = 'REVERSE') THEN
--
       -- Bid start price > TARGET PRICE --
       -- Buyer AUCTION only --
--

        IF (is_valid_rule(p_doctype_Id, 'TARGET_PRICE') AND is_valid_rule(p_doctype_Id, 'START_PRICE')) THEN
  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
		 error_value,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select 	interface_type,
  		fnd_message.get_string('PON','PON_AUCTION_BID_START_PRICE'),
		bid_start_price,
  		'PON_TARGET_GTR_BID_START',
  		'PON_ITEM_PRICES_INTERFACE',
  		batch_id,
  		interface_line_id
  	from 	pon_item_prices_interface
  	where 	bid_start_price <= target_price AND
  		batch_id = p_batch_id;
        END IF;
--
     ELSIF(l_transaction_type = 'FORWARD') THEN
--
       -- Bid start price < TARGET PRICE --
       -- Seller AUCTION only --
--
  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
		 error_value,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select 	interface_type,
  		fnd_message.get_string('PON','PON_AUCTION_BID_START_PRICE'),
		bid_start_price,
  		'PON_AUCTS_START_LT_TARGET',
  		'PON_ITEM_PRICES_INTERFACE',
  		batch_id,
  		interface_line_id
  	from 	pon_item_prices_interface
  	where 	bid_start_price >= target_price AND
  		batch_id = p_batch_id;
--
       -- bid start price < reserve price
       -- Seller AUCTION only --
--
  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
		 error_value,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select 	interface_type,
  		fnd_message.get_string('PON','PON_AUCTION_BID_START_PRICE'),
		bid_start_price,
  		'PON_AUCTS_START_LT_RESERVE',
  		'PON_ITEM_PRICES_INTERFACE',
  		batch_id,
  		interface_line_id
  	from 	pon_item_prices_interface
  	where 	reserve_price < bid_start_price AND
  		batch_id = p_batch_id;
--
       -- reserve price < target price
       -- Seller AUCTION only --
--
  	insert into PON_INTERFACE_ERRORS
  		(interface_type,
  		 column_name,
		 error_value,
  		 error_message_name,
  		 table_name,
  		 batch_id,
  		 interface_line_id)
  	select 	interface_type,
  		fnd_message.get_string('PON','PON_AUCTS_RESERVE_PRICE'),
		reserve_price,
  		'PON_AUCTS_RESERVE_LT_TARGET',
  		'PON_ITEM_PRICES_INTERFACE',
  		batch_id,
  		interface_line_id
  	from 	pon_item_prices_interface
  	where 	reserve_price > target_price AND
  		batch_id = p_batch_id;
--
     END IF;
--

     -- unit target price NOT < 0
     -- AUCTION only

     insert into PON_INTERFACE_ERRORS
           (interface_type,
            column_name,
            error_value,
            error_message_name,
            table_name,
            batch_id,
            interface_line_id)
  	select 	interface_type,
           fnd_message.get_string('PON','PON_ITEM_PRICE_TARGET_VALUE'),
           unit_target_price,
           'PON_AUC_POSITIVE_OR_ZERO',
           'PON_ITEM_PRICES_INTERFACE',
           batch_id,
           interface_line_id
     from 	pon_item_prices_interface
    where  UNIT_TARGET_PRICE < 0
      and  nvl(price_and_quantity_apply, 'Y') = 'Y'
      and  batch_id = p_batch_id;

      --R12 - Added for Complex work
     IF p_contract_type IN ('STANDARD','CONTRACT') AND l_progress_payment_type <> 'NONE' THEN
        -- Call complex work validations only if progress_payment_type
        -- is NOT NONE
        validate_complexwork(p_batch_id, l_progress_payment_type, p_contract_type, l_advance_negotiable_flag, l_recoupment_negotiable_flag);
	 END IF;


  END IF; -- end of if p_source <> 'SBID'
--
  -- DBMS_OUTPUT.PUT_LINE('< validate()');
END validate;
--

END pon_validate_item_prices_int;

/
