--------------------------------------------------------
--  DDL for Package Body PON_AUCTION_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_AUCTION_INTERFACE_PKG" AS
/* $Header: PONAUCIB.pls 120.21.12010000.3 2012/10/19 09:47:35 svalampa ship $ */

  g_pkg_name CONSTANT VARCHAR2(30) := 'PON_AUCTION_INTERFACE_PKG';
  g_progress_payment_type pon_auction_headers_all.progress_payment_type%TYPE := 'NONE';

  -- global variables added for header price break default project
  g_price_break_type        pon_auction_item_prices_all.price_break_type%type;
  g_price_break_neg_flag    pon_auction_item_prices_all.price_break_neg_flag%type;

/*
===================
    PROCEDURES
===================
========================================================================
 PROCEDURE : Create_Draft_Negotiation     PUBLIC
 PARAMETERS:
  P_DOCUMENT_TITLE	IN	Title of negotiation
  P_DOCUMENT_TYPE	IN	'BUYER_AUCTION' or 'REQUEST_FOR_QUOTE'
  P_CONTRACT_TYPE	IN	'STANDARD' or 'BLANKET'
  P_ORIGINATION_CODE	IN	'REQUISITION' or caller product name
  P_ORG_ID		IN	Organization id of creator
  P_BUYER_ID		IN	FND_USER_ID of creator
  P_NEG_STYLE_ID	IN	negotiation style id
  P_PO_STYLE_ID		IN	po style id
  P_DOCUMENT_NUMBER	OUT	Created Document number
  P_DOCUMENT_URL	OUT	Additional parameters to PON_AUC_EDIT_DRAFT_B
				form function for editing draft
  P_RESULT              OUT     One of (error, success)
  P_ERROR_CODE		OUT	Internal code for error
  P_ERROR_MESSAGE	OUT	Displayable error
 COMMENT   : Creates a draft auction
======================================================================*/
PROCEDURE Create_Draft_Negotiation(
 P_DOCUMENT_TITLE	IN	VARCHAR2,
 P_DOCUMENT_TYPE	IN	VARCHAR2,
 P_CONTRACT_TYPE	IN	VARCHAR2,
 P_ORIGINATION_CODE	IN	VARCHAR2,
 P_ORG_ID		IN	NUMBER,
 P_BUYER_ID		IN	NUMBER,
 P_NEG_STYLE_ID		IN	NUMBER,
 P_PO_STYLE_ID		IN	NUMBER,
 P_DOCUMENT_NUMBER	OUT	NOCOPY	NUMBER,
 P_DOCUMENT_URL		OUT	NOCOPY	VARCHAR2,
 P_RESULT		OUT	NOCOPY	NUMBER,
 P_ERROR_CODE		OUT	NOCOPY	VARCHAR2,
 P_ERROR_MESSAGE	OUT	NOCOPY	VARCHAR2) IS

v_debug_status		VARCHAR2(100);
v_doctype_id		pon_auc_doctypes.doctype_id%TYPE;
v_transaction_type 	pon_auc_doctypes.transaction_type%TYPE;
v_site_id 		pon_auction_headers_all.trading_partner_id%TYPE;
v_site_name 		pon_auction_headers_all.trading_partner_name%TYPE;
v_multi_org		fnd_product_groups.multi_org_flag%TYPE := 'Y';
v_price_tiers_indicator pon_auction_headers_all.price_tiers_indicator%type;

l_price_break_response                pon_auction_headers_all.price_break_response%type;

l_style_name                         po_doc_style_headers.style_name%TYPE;
l_style_description                  po_doc_style_headers.style_description%TYPE;
l_style_type                         po_doc_style_headers.style_type%TYPE;
l_status                             po_doc_style_headers.status%TYPE;
l_advances_flag                      po_doc_style_headers.advances_flag%TYPE;
l_retainage_flag                     po_doc_style_headers.retainage_flag%TYPE;
l_price_breaks_flag                  po_doc_style_headers.price_breaks_flag%TYPE;
l_price_differentials_flag           po_doc_style_headers.price_differentials_flag%TYPE;
l_progress_payment_flag              po_doc_style_headers.progress_payment_flag%TYPE;
l_contract_financing_flag            po_doc_style_headers.contract_financing_flag%TYPE;
l_line_type_allowed                  po_doc_style_headers.line_type_allowed%TYPE;

l_line_attribute_enabled_flag  pon_negotiation_styles.line_attribute_enabled_flag%TYPE;
l_line_mas_enabled_flag        pon_negotiation_styles.line_mas_enabled_flag%TYPE;
l_price_element_enabled_flag   pon_negotiation_styles.price_element_enabled_flag%TYPE;
l_rfi_line_enabled_flag        pon_negotiation_styles.rfi_line_enabled_flag%TYPE;
l_lot_enabled_flag             pon_negotiation_styles.lot_enabled_flag%TYPE;
l_group_enabled_flag           pon_negotiation_styles.group_enabled_flag%TYPE;
l_large_neg_enabled_flag       pon_negotiation_styles.large_neg_enabled_flag%TYPE;
l_hdr_attribute_enabled_flag   pon_negotiation_styles.hdr_attribute_enabled_flag%TYPE;
l_neg_team_enabled_flag        pon_negotiation_styles.neg_team_enabled_flag%TYPE;
l_proxy_bidding_enabled_flag   pon_negotiation_styles.proxy_bidding_enabled_flag%TYPE;
l_power_bidding_enabled_flag   pon_negotiation_styles.power_bidding_enabled_flag%TYPE;
l_auto_extend_enabled_flag     pon_negotiation_styles.auto_extend_enabled_flag%TYPE;
l_team_scoring_enabled_flag    pon_negotiation_styles.team_scoring_enabled_flag%TYPE;
l_qty_price_tier_enabled_flag  pon_negotiation_styles.qty_price_tiers_enabled_flag%TYPE;

-- Begin Supplier Management: Bug 14087712
l_supp_reg_qual_flag           pon_negotiation_styles.supp_reg_qual_flag%TYPE;
l_supp_eval_flag               pon_negotiation_styles.supp_eval_flag%TYPE;
l_hide_terms_flag              pon_negotiation_styles.hide_terms_flag%TYPE;
l_hide_abstract_forms_flag     pon_negotiation_styles.hide_abstract_forms_flag%TYPE;
l_hide_attachments_flag        pon_negotiation_styles.hide_attachments_flag%TYPE;
l_internal_eval_flag           pon_negotiation_styles.internal_eval_flag%TYPE;
l_hdr_supp_attr_enabled_flag   pon_negotiation_styles.hdr_supp_attr_enabled_flag%TYPE;
l_intgr_hdr_attr_flag          pon_negotiation_styles.intgr_hdr_attr_flag%TYPE;
l_intgr_hdr_attach_flag        pon_negotiation_styles.intgr_hdr_attach_flag%TYPE;
l_line_supp_attr_enabled_flag  pon_negotiation_styles.line_supp_attr_enabled_flag%TYPE;
l_item_supp_attr_enabled_flag  pon_negotiation_styles.item_supp_attr_enabled_flag%TYPE;
l_intgr_cat_line_attr_flag     pon_negotiation_styles.intgr_cat_line_attr_flag%TYPE;
l_intgr_item_line_attr_flag    pon_negotiation_styles.intgr_item_line_attr_flag%TYPE;
l_intgr_cat_line_asl_flag      pon_negotiation_styles.intgr_cat_line_asl_flag%TYPE;
-- End Supplier Management: Bug 14087712

BEGIN
  IF (P_DOCUMENT_TYPE NOT IN ('BUYER_AUCTION', 'REQUEST_FOR_QUOTE')) THEN
    P_RESULT := error;
    P_ERROR_CODE := 'CREATE_DRAFT:INVALID_DOC_TYPE';
    P_ERROR_MESSAGE := 'Invalid Document Type ' || P_DOCUMENT_TYPE;
    RETURN;
  END IF;

  IF (P_CONTRACT_TYPE NOT IN ('BLANKET', 'STANDARD')) THEN
    P_RESULT := error;
    P_ERROR_CODE := 'CREATE_DRAFT:INVALID_CONTRACT_TYPE';
    P_ERROR_MESSAGE := 'Invalid Contract Type ' || P_CONTRACT_TYPE;
    RETURN;
  END IF;

  IF (P_ORIGINATION_CODE <> 'REQUISITION') THEN
    P_RESULT := error;
    P_ERROR_CODE := 'CREATE_DRAFT:UNKNOWN_ORIGINATION';
    P_ERROR_MESSAGE := 'Invalid Origination Code ' || P_ORIGINATION_CODE;
    RETURN;
  END IF;

  IF (P_BUYER_ID IS NULL) THEN
    P_RESULT := error;
    P_ERROR_CODE := 'CREATE_DRAFT:NULL_BUYER_ID';
    P_ERROR_MESSAGE := 'Please specify a BUYER_ID';
    RETURN;
  END IF;

  -- Is this multiorg?
  v_debug_status := 'MULTIORG';
  BEGIN
    SELECT multi_org_flag
    INTO v_multi_org
    FROM fnd_product_groups;
  EXCEPTION
    WHEN no_data_found THEN
      P_RESULT := error;
      P_ERROR_CODE := 'CREATE_DRAFT:MULTI_ORG_QUERY';
      fnd_message.set_name('PON', 'PON_AUC_PLSQL_ERR');
      fnd_message.set_token('PACKAGE','pon_auction_interface_pkg');
      fnd_message.set_token('PROCEDURE','Create_Draft_Negotiation');
      fnd_message.set_token('ERROR','Multi-Org Query Failed [' || SQLERRM || ']');
      fnd_message.retrieve(P_ERROR_MESSAGE);
      RETURN;
  END;

  IF (P_ORG_ID IS NULL AND v_multi_org = 'Y') THEN
    P_RESULT := error;
    P_ERROR_CODE := 'CREATE_DRAFT:NULL_ORG_ID';
    P_ERROR_MESSAGE := 'Please specify an ORG_ID';
    RETURN;
  END IF;

  -- Get site ID for the enterprise
  v_debug_status := 'SITE_ID';
  pos_enterprise_util_pkg.get_enterprise_partyId(v_site_id,
					         P_ERROR_CODE,
					         P_ERROR_MESSAGE);
  IF (P_ERROR_CODE IS NOT NULL OR v_site_id IS NULL) THEN
   P_RESULT := error;
   P_ERROR_CODE := 'CREATE_DRAFT:GET_ENTERPRISE_ID';
   P_ERROR_MESSAGE := 'Could not get the Enterprise ID';
   RETURN;
  END IF;

  -- Get site name for the enterprise
  v_debug_status := 'SITE_NAME';
  pos_enterprise_util_pkg.get_enterprise_party_name(v_site_name,
					            P_ERROR_CODE,
					            P_ERROR_MESSAGE);
  IF (P_ERROR_CODE IS NOT NULL) THEN
   P_RESULT := error;
   P_ERROR_CODE := 'CREATE_DRAFT:GET_ENTERPRISE_NAME';
   P_ERROR_MESSAGE := 'Could not get the Enterprise Name';
   RETURN;
  END IF;

   IF ( p_po_style_id IS NOT NULL) THEN
	   PO_DOC_STYLE_GRP.GET_DOCUMENT_STYLE_SETTINGS(
                     p_api_version           => 1.0
                    , p_style_id             => p_po_style_id
                    , x_style_name           => l_style_name
                    , x_style_description    => l_style_description
                    , x_style_type           => l_style_type
                    , x_status               => l_status
                    , x_advances_flag        => l_advances_flag
                    , x_retainage_flag       => l_retainage_flag
                    , x_price_breaks_flag    => l_price_breaks_flag
                    , x_price_differentials_flag => l_price_differentials_flag
                    , x_progress_payment_flag    => l_progress_payment_flag
                    , x_contract_financing_flag  => l_contract_financing_flag
                    , x_line_type_allowed       =>  l_line_type_allowed);

      IF l_progress_Payment_flag = 'Y' THEN
	     IF (P_DOCUMENT_TYPE  <> 'REQUEST_FOR_QUOTE') THEN
	        P_RESULT := error;
	        P_ERROR_CODE := 'CREATE_DRAFT:INVALID_DOC_TYPE';
	        P_ERROR_MESSAGE := 'Invalid Document Type For Complex Work Style ' || P_CONTRACT_TYPE;
	        RETURN;
	     END IF;
	     IF   (p_Contract_type  <>  'STANDARD') then
	       P_RESULT := error;
	       P_ERROR_CODE := 'CREATE_DRAFT:INVALID_CONTRACT_TYPE';
	       P_ERROR_MESSAGE := 'Invalid Contract Type For Complex Work Style ' || P_CONTRACT_TYPE;
	       RETURN;
	     END IF;
	     --Set the following attribute on negotiation-
	     IF  (l_contract_financing_flag = 'Y') THEN
	        g_progress_payment_type := 'FINANCE';
	     ELSE
	        g_progress_payment_type := 'ACTUAL';
	     END IF;

	  END IF;
  END IF;
  -- Get doctypeID
  v_debug_status := 'DOCTYPE_ID';
  SELECT doctype_id, transaction_type
  INTO v_doctype_id, v_transaction_type
  FROM pon_auc_doctypes
    WHERE internal_name = P_DOCUMENT_TYPE;


  -- price break header setting
  PON_AUCTION_PKG.get_default_hdr_pb_settings (
                                       v_doctype_id,
                                       v_site_id,
                                       l_price_break_response);

  -- Insert a row into PON_AUCTION_HEADERS_ALL
  -- See NegotiationDoc.java for the majority of defaulting - setDefaults()

  -- Get all the style related columns from PON_NEGOTIATION_STYLES table for the style id.
  -- Populate all the style related columns in PON_AUCTION_HEADERS_ALL table.
  -- This procedure is invoked from two flows.
  --   1. HTML Autocreate : We select the syle id from the UI and the style id is passed as an arugment here.
  --   2. Forms based Autocreate : We will not have any option to select style from the forms and the style id wil be null here.
  IF P_NEG_STYLE_ID IS NOT NULL THEN
      BEGIN
          SELECT
              LINE_ATTRIBUTE_ENABLED_FLAG, LINE_MAS_ENABLED_FLAG, PRICE_ELEMENT_ENABLED_FLAG,
              RFI_LINE_ENABLED_FLAG, LOT_ENABLED_FLAG, GROUP_ENABLED_FLAG, LARGE_NEG_ENABLED_FLAG,
              HDR_ATTRIBUTE_ENABLED_FLAG, NEG_TEAM_ENABLED_FLAG, PROXY_BIDDING_ENABLED_FLAG,
              POWER_BIDDING_ENABLED_FLAG, AUTO_EXTEND_ENABLED_FLAG, TEAM_SCORING_ENABLED_FLAG , QTY_PRICE_TIERS_ENABLED_FLAG,
              -- Begin Supplier Management: Bug 14087712
              SUPP_REG_QUAL_FLAG, SUPP_EVAL_FLAG, HIDE_TERMS_FLAG, HIDE_ABSTRACT_FORMS_FLAG,
              HIDE_ATTACHMENTS_FLAG, INTERNAL_EVAL_FLAG, HDR_SUPP_ATTR_ENABLED_FLAG,
              INTGR_HDR_ATTR_FLAG, INTGR_HDR_ATTACH_FLAG,
              LINE_SUPP_ATTR_ENABLED_FLAG, ITEM_SUPP_ATTR_ENABLED_FLAG, INTGR_CAT_LINE_ATTR_FLAG,
              INTGR_ITEM_LINE_ATTR_FLAG, INTGR_CAT_LINE_ASL_FLAG
              -- End Supplier Management: Bug 14087712
          INTO
              l_line_attribute_enabled_flag, l_line_mas_enabled_flag, l_price_element_enabled_flag,
              l_rfi_line_enabled_flag, l_lot_enabled_flag, l_group_enabled_flag, l_large_neg_enabled_flag,
              l_hdr_attribute_enabled_flag, l_neg_team_enabled_flag, l_proxy_bidding_enabled_flag,
              l_power_bidding_enabled_flag, l_auto_extend_enabled_flag, l_team_scoring_enabled_flag, l_qty_price_tier_enabled_flag,
              -- Begin Supplier Management: Bug 14087712
              l_supp_reg_qual_flag, l_supp_eval_flag, l_hide_terms_flag, l_hide_abstract_forms_flag,
              l_hide_attachments_flag, l_internal_eval_flag, l_hdr_supp_attr_enabled_flag,
              l_intgr_hdr_attr_flag, l_intgr_hdr_attach_flag,
              l_line_supp_attr_enabled_flag, l_item_supp_attr_enabled_flag, l_intgr_cat_line_attr_flag,
              l_intgr_item_line_attr_flag, l_intgr_cat_line_asl_flag
              -- End Supplier Management: Bug 14087712
          FROM
              PON_NEGOTIATION_STYLES WHERE STYLE_ID = P_NEG_STYLE_ID;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
	      l_line_attribute_enabled_flag  := NULL;
	      l_line_mas_enabled_flag        := NULL;
	      l_price_element_enabled_flag   := NULL;
	      l_rfi_line_enabled_flag        := NULL;
	      l_lot_enabled_flag             := NULL;
	      l_group_enabled_flag           := NULL;
	      l_large_neg_enabled_flag       := NULL;
	      l_hdr_attribute_enabled_flag   := NULL;
	      l_neg_team_enabled_flag        := NULL;
	      l_proxy_bidding_enabled_flag   := NULL;
	      l_power_bidding_enabled_flag   := NULL;
	      l_auto_extend_enabled_flag     := NULL;
	      l_team_scoring_enabled_flag    := NULL;
	      l_qty_price_tier_enabled_flag  := 'Y';
      END;
  END IF;

  -- R12.1 Price tiers Project
  -- Get Default price tiers indicator

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN --{
    fnd_log.string(fnd_log.level_statement,
           'pon.plsql.pon_auction_interface_pkg.Create_Draft_Negotiation',
            'Calling the PON_AUCTION_PKG.GET_DEFAULT_TIERS_INDICATOR API to get the' ||
            ' default price tiers indicator value.');
  END IF;

  v_debug_status := 'PRICE_TIERS_INDICATOR';
  PON_AUCTION_PKG.GET_DEFAULT_TIERS_INDICATOR(
                                p_contract_type             =>  P_CONTRACT_TYPE,
                                p_price_breaks_enabled      =>  l_price_breaks_flag,
                                p_qty_price_tiers_enabled   =>  l_qty_price_tier_enabled_flag,
                                p_doctype_id                =>  v_doctype_id,
                                x_price_tiers_indicator     =>  v_price_tiers_indicator);

  v_debug_status := 'INSERT-PAH';
  INSERT INTO PON_AUCTION_HEADERS_ALL (
    AUCTION_HEADER_ID,
    DOCUMENT_NUMBER,
    AUCTION_HEADER_ID_ORIG_AMEND,
    AUCTION_HEADER_ID_ORIG_ROUND,
    AMENDMENT_NUMBER,
    AUCTION_TITLE,
    AUCTION_STATUS,
    AWARD_STATUS,
    AUCTION_TYPE,
    CONTRACT_TYPE,
    TRADING_PARTNER_NAME,
    TRADING_PARTNER_NAME_UPPER,
    TRADING_PARTNER_ID,
    LANGUAGE_CODE,
    BID_VISIBILITY_CODE,
    ATTACHMENT_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    AUCTION_ORIGINATION_CODE,
    DOCTYPE_ID,
    ORG_ID,
    BUYER_ID,
    MANUAL_EDIT_FLAG,
    SHARE_AWARD_DECISION,
    APPROVAL_STATUS,
    GLOBAL_AGREEMENT_FLAG,
    ATTRIBUTE_LINE_NUMBER,
    HAS_HDR_ATTR_FLAG,
    HAS_ITEMS_FLAG,
    STYLE_ID,
    PO_STYLE_ID,
    PRICE_BREAK_RESPONSE,
    NUMBER_OF_LINES,
    ADVANCE_NEGOTIABLE_FLAG,
    RECOUPMENT_NEGOTIABLE_FLAG,
    PROGRESS_PYMT_NEGOTIABLE_FLAG,
    RETAINAGE_NEGOTIABLE_FLAG,
    MAX_RETAINAGE_NEGOTIABLE_FLAG,
    SUPPLIER_ENTERABLE_PYMT_FLAG,
    PROGRESS_PAYMENT_TYPE,
    LINE_ATTRIBUTE_ENABLED_FLAG,
    LINE_MAS_ENABLED_FLAG,
    PRICE_ELEMENT_ENABLED_FLAG,
    RFI_LINE_ENABLED_FLAG,
    LOT_ENABLED_FLAG,
    GROUP_ENABLED_FLAG,
    LARGE_NEG_ENABLED_FLAG,
    HDR_ATTRIBUTE_ENABLED_FLAG,
    NEG_TEAM_ENABLED_FLAG,
    PROXY_BIDDING_ENABLED_FLAG,
    POWER_BIDDING_ENABLED_FLAG,
    AUTO_EXTEND_ENABLED_FLAG,
    TEAM_SCORING_ENABLED_FLAG,
    PRICE_TIERS_INDICATOR,
    QTY_PRICE_TIERS_ENABLED_FLAG,
    -- Begin Supplier Management: Bug 14087712
    SUPP_REG_QUAL_FLAG,
    SUPP_EVAL_FLAG,
    HIDE_TERMS_FLAG,
    HIDE_ABSTRACT_FORMS_FLAG,
    HIDE_ATTACHMENTS_FLAG,
    INTERNAL_EVAL_FLAG,
    HDR_SUPP_ATTR_ENABLED_FLAG,
    INTGR_HDR_ATTR_FLAG,
    INTGR_HDR_ATTACH_FLAG,
    LINE_SUPP_ATTR_ENABLED_FLAG,
    ITEM_SUPP_ATTR_ENABLED_FLAG,
    INTGR_CAT_LINE_ATTR_FLAG,
    INTGR_ITEM_LINE_ATTR_FLAG,
    INTGR_CAT_LINE_ASL_FLAG,
    INTERNAL_ONLY_FLAG
    -- End Supplier Management: Bug 14087712
  ) VALUES (
    pon_auction_headers_all_s.nextval,	-- AUCTION_HEADER_ID
    pon_auction_headers_all_s.currval, -- DOCUMENT_NUMBER
    pon_auction_headers_all_s.currval, -- AUCTION_HEADER_ID_ORIG_AMEND,
    pon_auction_headers_all_s.currval, -- AUCTION_HEADER_ID_ORIG_ROUND,
    0,                  -- AMENDMENT_NUMBER
    P_DOCUMENT_TITLE,	-- AUCTION_TITLE
    'DRAFT',		-- AUCTION_STATUS
    'NO',		-- AWARD_STATUS
    v_transaction_type,	-- AUCTION_TYPE
    P_CONTRACT_TYPE,	-- CONTRACT_TYPE
    v_site_name,	-- TRADING_PARTNER_NAME
    upper(v_site_name),	-- TRADING_PARTNER_NAME_UPPER
    v_site_id,		-- TRADING_PARTNER_ID
    userenv('LANG'),    -- LANGUAGE_CODE
    'OPEN_BIDDING',	-- BID_VISIBILITY_CODE
    'N',		-- ATTACHMENT_FLAG
    sysdate,		-- CREATION_DATE
    P_BUYER_ID,		-- CREATED_BY
    sysdate,		-- LAST_UPDATE_DATE
    P_BUYER_ID,		-- LAST_UPDATED_BY
    P_ORIGINATION_CODE,	-- AUCTION_ORIGINATION_CODE
    v_doctype_id,	-- DOCTYPE_ID
    P_ORG_ID,		-- ORG_ID
    P_BUYER_ID,		-- BUYER_ID
    'N',		-- MANUAL_EDIT_FLAG
    'N',		-- SHARE_AWARD_DECISION
    'NOT_REQUIRED',	-- APPROVAL_STATUS
    'N',		-- GLOBAL_AGREEMENT_FLAG
     -1,                -- ATTRIBUTE_LINE_NUMBER
    'N',                -- HAS_HDR_ATTR_FLAG
    'Y',                -- HAS_ITEMS_FLAG
    P_NEG_STYLE_ID,     -- STYLE_ID
    P_PO_STYLE_ID,      -- PO_STYLE_ID
    l_price_break_response,      -- PRICE_BREAK_RESPONSE,
    0, -- NUMBER_OF_LINES
    'N',  --ADVANCE_NEGOTIABLE_FLAG
    'N',   --RECOUPMENT_NEGOTIABLE_FLAG
    'N',  --PROGRESS_PYMT_NEGOTIABLE_FLAG
    'N',  --RETAINAGE_NEGOTIABLE_FLAG
    'N',  --MAX_RETAINAGE_NEGOTIABLE_FLAG
    'N',  --SUPPLIER_ENTERABLE_PYMT_FLAG
    g_progress_payment_type,  --PROGRESS_PAYMENT_TYPE
    l_line_attribute_enabled_flag,
    l_line_mas_enabled_flag,
    l_price_element_enabled_flag,
    l_rfi_line_enabled_flag,
    l_lot_enabled_flag,
    l_group_enabled_flag,
    l_large_neg_enabled_flag,
    l_hdr_attribute_enabled_flag,
    l_neg_team_enabled_flag,
    l_proxy_bidding_enabled_flag,
    l_power_bidding_enabled_flag,
    l_auto_extend_enabled_flag,
    l_team_scoring_enabled_flag,
    v_price_tiers_indicator,
    l_qty_price_tier_enabled_flag,
    -- Begin Supplier Management: Bug 14087712
    l_supp_reg_qual_flag,
    l_supp_eval_flag,
    l_hide_terms_flag,
    l_hide_abstract_forms_flag,
    l_hide_attachments_flag,
    l_internal_eval_flag,
    l_hdr_supp_attr_enabled_flag,
    l_intgr_hdr_attr_flag,
    l_intgr_hdr_attach_flag,
    l_line_supp_attr_enabled_flag,
    l_item_supp_attr_enabled_flag,
    l_intgr_cat_line_attr_flag,
    l_intgr_item_line_attr_flag,
    l_intgr_cat_line_asl_flag,
    'N'
    -- End Supplier Management: Bug 14087712
  )
  RETURNING auction_header_id INTO P_DOCUMENT_NUMBER;

  -- price break line setting
  PON_AUCTION_PKG.get_default_pb_settings (p_document_number,
                                           g_price_break_type,
                                           g_price_break_neg_flag);


  -- Construct URL to Edit Document
  v_debug_status := 'DOC_URL';
  P_DOCUMENT_URL := '&' || 'auctionID=' || P_DOCUMENT_NUMBER;

  P_RESULT := success;
  P_ERROR_CODE := NULL;
  P_ERROR_MESSAGE := NULL;
EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('PON', 'PON_AUC_PLSQL_ERR');
    fnd_message.set_token('PACKAGE','pon_auction_interface_pkg');
    fnd_message.set_token('PROCEDURE','Create_Draft_Negotiation');
    fnd_message.set_token('ERROR',v_debug_status || ' [' || SQLERRM || ']');
    APP_EXCEPTION.RAISE_EXCEPTION;
END;

/*======================================================================
 PROCEDURE : Add_Negotiation_Line
 PARAMETERS:
  P_DOCUMENT_NUMBER	IN	Document number to add line
  P_CONTRACT_TYPE	IN	'STANDARD' or 'BLANKET'
  P_ORIGINATION_CODE	IN	'REQUISITION' or caller product name
  P_ORG_ID		IN	Organization id of creator
  P_BUYER_ID		IN	FND_USER_ID of creator
  P_GROUPING_TYPE	IN	'DEFAULT' or 'NONE' grouping
  P_REQUISITION_HEADER_ID  IN	Requisition header
  P_REQUISITION_NUMBER  IN	Requisition header formatted for display
  P_REQUISITION_LINE_ID IN	Requisition line
  P_LINE_TYPE_ID	IN	Line type
  P_CATEGORY_ID		IN	Line category
  P_ITEM_DESCRIPTION	IN	Item Desription
  P_ITEM_ID		IN	Item Id
  P_ITEM_NUMBER		IN      Item Number formatted for display
  P_ITEM_REVISION	IN	Item Revision
  P_UOM_CODE		IN	UOM_CODE from MTL_UNITS_OF_MEASURE
  P_QUANTITY		IN	Quantity
  P_NEED_BY_DATE	IN	Item Need-By
  P_SHIP_TO_LOCATION_ID IN	Ship To
  P_NOTE_TO_VENDOR	IN	Note to Supplier
  P_PRICE		IN	Start price for line
  P_JOB_ID		IN      Job_id for the services job
  P_JOB_DETAILS	        IN      job details if any
  P_PO_AGREED_AMOUNT	IN	PO Agreed Amount
  P_HAS_PRICE_DIFF_FLAG IN      If the line has any price differentials flag
  P_LINE_NUMBER		OUT	Line number to which the demand was added
  P_RESULT      	OUT     One of (error, success)
  P_ERROR_CODE		OUT	Internal Error Code
  P_ERROR_MESSAGE	OUT	Displayable error
 COMMENT   : Creates a line in a draft auction
======================================================================*/
PROCEDURE Add_Negotiation_Line(
 P_DOCUMENT_NUMBER	IN	NUMBER,
 P_CONTRACT_TYPE        IN      VARCHAR2,
 P_ORIGINATION_CODE	IN	VARCHAR2,
 P_ORG_ID		IN	NUMBER,
 P_BUYER_ID		IN	NUMBER,
 P_GROUPING_TYPE	IN	VARCHAR2,
 P_REQUISITION_HEADER_ID   IN	NUMBER,
 P_REQUISITION_NUMBER	IN	VARCHAR2,
 P_REQUISITION_LINE_ID	IN	NUMBER,
 P_LINE_TYPE_ID		IN	NUMBER,
 P_CATEGORY_ID		IN	NUMBER,
 P_ITEM_DESCRIPTION	IN	VARCHAR2,
 P_ITEM_ID		IN	NUMBER,
 P_ITEM_NUMBER		IN      VARCHAR2,
 P_ITEM_REVISION	IN	VARCHAR2,
 P_UOM_CODE		IN	VARCHAR2,
 P_QUANTITY		IN	NUMBER,
 P_NEED_BY_DATE		IN	DATE,
 P_SHIP_TO_LOCATION_ID	IN	NUMBER,
 P_NOTE_TO_VENDOR	IN	VARCHAR2,
 P_PRICE		IN	NUMBER,
 P_JOB_ID		IN      NUMBER, -- ADDED FOR SERVICES PROCUREMENT PROJECT
 P_JOB_DETAILS	        IN      VARCHAR2,-- ADDED FOR SERVICES PROCUREMENT PROJECT
 P_PO_AGREED_AMOUNT	IN	NUMBER,-- ADDED FOR SERVICES PROCUREMENT PROJECT
 P_HAS_PRICE_DIFF_FLAG	IN	VARCHAR2,-- ADDED FOR SERVICES PROCUREMENT PROJECT
 P_LINE_NUMBER		OUT	NOCOPY	NUMBER,
 P_RESULT		OUT	NOCOPY	NUMBER,
 P_ERROR_CODE		OUT	NOCOPY	VARCHAR2,
 P_ERROR_MESSAGE	OUT	NOCOPY	VARCHAR2) IS

v_debug_status VARCHAR2(100);
v_was_grouped VARCHAR2(1);
v_header_attach_count NUMBER;
v_item_attach_count NUMBER;
v_site_id 		pon_auction_headers_all.trading_partner_id%TYPE :=NULL;
v_org_id		pon_auction_headers_all.org_id%TYPE;
v_seq_num		fnd_attached_documents.seq_num%TYPE;
v_price			pon_auction_item_prices_all.current_price%TYPE;
v_category_name		pon_auction_item_prices_all.category_name%TYPE;
v_ip_category_id        pon_auction_item_prices_all.ip_category_id%TYPE;
v_quantity		pon_auction_item_prices_all.quantity%TYPE;
v_uom_code		pon_auction_item_prices_all.uom_code%TYPE;
v_has_attachments 	pon_auction_item_prices_all.attachment_flag%TYPE:= 'N';
v_multi_org		fnd_product_groups.multi_org_flag%TYPE := 'Y';
v_order_type_lookup_code  po_line_types_b.order_type_lookup_code%TYPE;
v_purchase_basis        po_line_types_b.purchase_basis%TYPE;
v_att_category_id	fnd_document_categories.category_id%TYPE;
v_service_based_line    VARCHAR2(1);
v_from_ip_catalog       VARCHAR2(1);

v_blanket_po_header_id po_requisition_lines_all.blanket_po_header_id%TYPE;
v_blanket_po_line_num  po_requisition_lines_all.blanket_po_line_num%TYPE;

BEGIN
  IF (P_DOCUMENT_NUMBER IS NULL) THEN
    P_RESULT := error;
    P_ERROR_CODE := 'ADD_NEG_LINE:DOCUMENT_NUMBER';
    P_ERROR_MESSAGE := 'Please provide a DOCUMENT_NUMBER';
    RETURN;
  END IF;

  IF (P_CONTRACT_TYPE NOT IN ('BLANKET', 'STANDARD')) THEN
    P_RESULT := error;
    P_ERROR_CODE := 'ADD_NEG_LINE:INVALID_CONTRACT_TYPE';
    P_ERROR_MESSAGE := 'Invalid Contract Type ' || P_CONTRACT_TYPE;
    RETURN;
  END IF;

  IF (P_ORIGINATION_CODE <> 'REQUISITION') THEN
    P_RESULT := error;
    P_ERROR_CODE := 'ADD_NEG_LINE:UNKNOWN_ORIGINATION';
    P_ERROR_MESSAGE := 'Invalid Origination Code ' || P_ORIGINATION_CODE;
    RETURN;
  END IF;

  IF (P_BUYER_ID IS NULL) THEN
    P_RESULT := error;
    P_ERROR_CODE := 'ADD_NEG_LINE:NULL_BUYER_ID';
    P_ERROR_MESSAGE := 'Please specify a BUYER_ID';
    RETURN;
  END IF;

  IF (P_CATEGORY_ID IS NULL) THEN
    P_RESULT := error;
    P_ERROR_CODE := 'ADD_NEG_LINE:NULL_CATEGORY_ID';
    P_ERROR_MESSAGE := 'Please specify a CATEGORY_ID';
    RETURN;
  END IF;

    -- Amount based line?
  v_debug_status := 'ORDER_TYPE_LOOKUP';
  BEGIN
    SELECT order_type_lookup_code
    INTO v_order_type_lookup_code
    FROM po_line_types_b
    WHERE P_LINE_TYPE_ID = line_type_id;
  EXCEPTION
    WHEN no_data_found THEN
      P_RESULT := error;
      P_ERROR_CODE := 'ADD_NEG_LINE:ORDER_TYPE_LOOKUP';
      P_ERROR_MESSAGE := 'An order_type_lookup_code could not be found for line_type_id ' || P_LINE_TYPE_ID;
      RETURN;
  END;

  -- Get the purchase basis for this line type
   BEGIN
    SELECT purchase_basis
    INTO v_purchase_basis
    FROM po_line_types_b
    WHERE P_LINE_TYPE_ID = line_type_id;
  EXCEPTION
    WHEN no_data_found THEN
      P_RESULT := error;
      P_ERROR_CODE := 'ADD_NEG_LINE:PURCHASE_BASIS_LOOKUP';
      P_ERROR_MESSAGE := 'A purchase basis could not be found for line_type_id ' || P_LINE_TYPE_ID;
      RETURN;
   END;

  IF ((P_UOM_CODE IS NULL) AND (v_order_type_lookup_code <> 'FIXED PRICE')) THEN
    P_RESULT := error;
    P_ERROR_CODE := 'ADD_NEG_LINE:NULL_UOM_CODE';
    P_ERROR_MESSAGE := 'Please specify a UOM_CODE';
    RETURN;
  END IF;

  IF (P_QUANTITY IS NULL AND ((v_purchase_basis <> 'SERVICES') AND (v_purchase_basis <> 'TEMP LABOR'))) THEN
    P_RESULT := error;
    P_ERROR_CODE := 'ADD_NEG_LINE:NULL_QUANTITY';
    P_ERROR_MESSAGE := 'Please specify a QUANTITY';
    RETURN;
  END IF;

  --check if only valid line types for complex work
  	IF g_progress_payment_type in ('FINANCE', 'ACTUAL') THEN
	   IF NOT ((V_PURCHASE_BASIS = 'GOODS' AND  V_ORDER_TYPE_LOOKUP_CODE = 'QUANTITY') OR
	           (V_PURCHASE_BASIS = 'SERVICES' AND V_ORDER_TYPE_LOOKUP_CODE = 'FIXED PRICE')
	          ) THEN
	        P_RESULT := error;
	        P_ERROR_CODE := 'ADD_NEG_LINE:INVALID_LINE_TYPE';
	        P_ERROR_MESSAGE := 'The line_type_id is invalid for Complex work Style' || P_LINE_TYPE_ID;
	        RETURN;
	   END IF;

  END IF;


  IF (P_SHIP_TO_LOCATION_ID IS NULL) THEN
    P_RESULT := error;
    P_ERROR_CODE := 'ADD_NEG_LINE:NULL_SHIP_TO';
    P_ERROR_MESSAGE := 'Please specify a SHIP_TO';
    RETURN;
  END IF;

  -- Is this multiorg?
  v_debug_status := 'MULTIORG';
  BEGIN
    SELECT multi_org_flag
    INTO v_multi_org
    FROM fnd_product_groups;
  EXCEPTION
    WHEN no_data_found THEN
      P_RESULT := error;
      P_ERROR_CODE := 'ADD_NEG_LINE:MULTI_ORG_QUERY';
      fnd_message.set_name('PON', 'PON_AUC_PLSQL_ERR');
      fnd_message.set_token('PACKAGE','pon_auction_interface_pkg');
      fnd_message.set_token('PROCEDURE','Add_Negotiation_Line');
      fnd_message.set_token('ERROR','Multi-Org Query Failed [' || SQLERRM || ']');
      fnd_message.retrieve(P_ERROR_MESSAGE);
      RETURN;
  END;

  IF (P_ORG_ID IS NULL AND v_multi_org = 'Y') THEN
    P_RESULT := error;
    P_ERROR_CODE := 'ADD_NEG_LINE:NULL_ORG_ID';
    P_ERROR_MESSAGE := 'Please specify an ORG_ID';
    RETURN;
  END IF;

  -- Does P_ORG_ID match that of the auction header?
  v_debug_status := 'ORG_ID_MATCH';
  BEGIN
    SELECT org_id
    INTO v_org_id
    FROM pon_auction_headers_all
    WHERE auction_header_id = P_DOCUMENT_NUMBER
      AND nvl(org_id, -9999) = nvl(P_ORG_ID, -9999);
  EXCEPTION
    WHEN no_data_found THEN
      P_RESULT := error;
      P_ERROR_CODE := 'ADD_NEG_LINE:ORG_ID_CONFLICT';
      P_ERROR_MESSAGE := 'You cannot add lines to another organization''s Negotiation';
      RETURN;
  END;

  -- get category id for VENDOR attachments
  v_debug_status := 'ATTACHMENT_CATEGORY_ID';
  BEGIN
    SELECT category_id
    INTO v_att_category_id
    FROM fnd_document_categories
    WHERE upper(name) = 'VENDOR';
  EXCEPTION
    WHEN no_data_found THEN
      P_RESULT := error;
      P_ERROR_CODE := 'ADD_NEG_LINE:ATTACHMENT_CATEGORY_ID';
      P_ERROR_MESSAGE := 'The attachment category id for name=VENDOR could not be found';
      RETURN;
  END;

  -- Does this requisition line have any attachments?
  SELECT count(*)
  INTO v_header_attach_count
  FROM fnd_attached_documents ad, fnd_documents doc
  WHERE ad.entity_name = 'REQ_HEADERS'
    AND ad.pk1_value = to_char(p_requisition_header_id)
    AND ad.document_id = doc.document_id
    AND doc.category_id = v_att_category_id;

  SELECT count(*)
  INTO v_item_attach_count
  FROM fnd_attached_documents ad, fnd_documents doc
  WHERE ad.entity_name = 'REQ_LINES'
    AND ad.pk1_value = to_char(p_requisition_line_id)
    AND ad.document_id = doc.document_id
    AND doc.category_id = v_att_category_id;

  IF (v_header_attach_count > 0 OR v_item_attach_count > 0) THEN
    v_has_attachments := 'Y';
  END IF;

  -- Check to see if this is a services based line type
  -- ie one of - temp labor or fixed price services
  -- if it is then donot group the lines, since you cannot
  -- group services based line types. Even if the p_grouping_type
  -- is set to 'DEFAULT', overwrite it
  --Complex work- Requisitions should not be grouped if complex work neg
  v_service_based_line := 'N';
  IF ((v_order_type_lookup_code = 'FIXED PRICE') OR (v_purchase_basis = 'TEMP LABOR')
  	 OR(g_progress_payment_type in('FINANCE', 'ACTUAL'))) THEN
     v_service_based_line := 'Y';
  END IF;

  -- check to see if this line type is TEMP LABOR RATE or fixed price temp labor based
  -- in which case we want to update the global agreement flag at the
  -- header level, since temp labor line types can exist only on
  -- global agreements
  IF (v_purchase_basis = 'TEMP LABOR' AND p_contract_type = 'BLANKET' ) THEN
     UPDATE pon_auction_headers_all
       SET global_agreement_flag = 'Y'
       WHERE auction_header_id = p_document_number;
  END IF;


  -- Get the shopping category (ip_category_id) when creating a blanket line
  -- Two cases:
  -- 1) If the requisition is tied to a catalog, get the shopping category from the
  --    category line
  -- 2) Else use the po category to ip category mappings

  v_ip_category_id := null;
  v_from_ip_catalog := 'N';

  IF (p_contract_type = 'BLANKET') THEN

    SELECT blanket_po_header_id, blanket_po_line_num
    INTO   v_blanket_po_header_id, v_blanket_po_line_num
    FROM   po_requisition_lines_all
    WHERE  requisition_header_id = p_requisition_header_id and
           requisition_line_id = p_requisition_line_id;

    IF (v_blanket_po_header_id is not null and v_blanket_po_line_num is not null) THEN

      -- get the ip category from the catalog

      v_from_ip_catalog := 'Y';

      SELECT ip_category_id
      INTO   v_ip_category_id
      FROM   po_lines_all
      WHERE  po_header_id = v_blanket_po_header_id and
             line_num = v_blanket_po_line_num;

    ELSE

      -- get the ip ccategory from the category mappings

      v_ip_category_id := PON_AUCTION_PKG.get_mapped_ip_category(p_category_id);

      if (v_ip_category_id = -2) then
        v_ip_category_id := null;
      end if;

    END IF;


  END IF;



  -- Insert or Update row in PON_AUCTION_ITEM_PRICES
  P_LINE_NUMBER := NULL;
  IF (P_GROUPING_TYPE = 'DEFAULT' AND v_service_based_line <> 'Y') THEN

    v_debug_status := 'GROUPING_QUERY';

    IF (P_CONTRACT_TYPE = 'STANDARD') THEN

      SELECT max(line_number)
      INTO P_LINE_NUMBER
      FROM pon_auction_item_prices_all
      WHERE auction_header_id = P_DOCUMENT_NUMBER
        AND line_type_id = P_LINE_TYPE_ID
        AND nvl(p_item_id, -1) = nvl(item_id, -1)
        AND nvl(p_item_revision, -1) = nvl(item_revision, -1)
        AND nvl(p_item_description, 'NULL') = nvl(item_description, 'NULL')
        AND p_category_id = category_id
        AND p_ship_to_location_id = ship_to_location_id
        -- Ignore UOM code for amount based lines
        AND decode(v_order_type_lookup_code, 'AMOUNT', '1', p_uom_code) = decode(v_order_type_lookup_code, 'AMOUNT', '1', uom_code);

    ELSE

      SELECT max(paip.line_number)
      INTO P_LINE_NUMBER
      FROM pon_auction_item_prices_all paip,
           pon_backing_requisitions pbr,
           po_requisition_lines_all prl
      WHERE paip.auction_header_id = P_DOCUMENT_NUMBER
        AND paip.line_type_id = P_LINE_TYPE_ID
        AND nvl(p_item_id, -1) = nvl(paip.item_id, -1)
        AND nvl(p_item_revision, -1) = nvl(paip.item_revision, -1)
        AND nvl(p_item_description, 'NULL') = nvl(paip.item_description, 'NULL')
        AND p_category_id = paip.category_id
        AND nvl(v_ip_category_id, -1) = nvl(paip.ip_category_id, -1)
        -- Ignore UOM code for amount based lines
        AND decode(v_order_type_lookup_code, 'AMOUNT', '1', p_uom_code) = decode(v_order_type_lookup_code, 'AMOUNT', '1', paip.uom_code)
        AND paip.auction_header_id = pbr.auction_header_id
        AND paip.line_number = pbr.line_number
        AND pbr.requisition_header_id = prl.requisition_header_id
        AND pbr.requisition_line_id = prl.requisition_line_id
        AND nvl(prl.blanket_po_header_id, -1) = nvl(v_blanket_po_header_id, -1)
        AND nvl(prl.blanket_po_line_num, -1) = nvl(v_blanket_po_line_num, -1);

    END IF;

  END IF;

  -- Update if we're grouping
  IF (P_LINE_NUMBER IS NOT NULL) THEN
    v_was_grouped := 'Y';

    IF (v_order_type_lookup_code = 'AMOUNT') THEN
      -- Update row in PON_AUCTION_ITEM_PRICES
      v_debug_status := 'UPDATE_PAIP_1';
      UPDATE pon_auction_item_prices_all
      SET requisition_number = 'MULTIPLE',
        -- problem: least() and greater() return NULL if any argument is NULL
        -- need_by_start := NULL if P_NEED_BY_DATE and need_by_start == NULL
        need_by_start_date = decode(P_CONTRACT_TYPE, 'BLANKET', to_date(NULL), least(nvl(need_by_start_date,P_NEED_BY_DATE), nvl(P_NEED_BY_DATE,need_by_start_date))),
        -- if P_NEED_BY_DATE is NULL, keep existing need_by_date
        need_by_date = decode(P_CONTRACT_TYPE, 'BLANKET', to_date(NULL), greatest(nvl(need_by_date,P_NEED_BY_DATE), nvl(P_NEED_BY_DATE,need_by_date))),
        attachment_flag = decode(attachment_flag, 'Y', 'Y', v_has_attachments),
        -- if P_PRICE is NULL, keep existing current_price
        current_price = nvl(current_price,0) + P_QUANTITY
      WHERE auction_header_id = P_DOCUMENT_NUMBER
        AND line_number = P_LINE_NUMBER;
    ELSE
      -- Update row in PON_AUCTION_ITEM_PRICES
      v_debug_status := 'UPDATE_PAIP_2';
      UPDATE pon_auction_item_prices_all
      SET quantity = quantity + P_QUANTITY,
        residual_quantity = residual_quantity + P_QUANTITY,
        requisition_number = 'MULTIPLE',
        -- problem: least() and greater() return NULL if any argument is NULL
        -- set need_by_start to NULL if P_NEED_BY_DATE and need_by_start == NULL
        need_by_start_date = decode(P_CONTRACT_TYPE, 'BLANKET', to_date(NULL), least(nvl(need_by_start_date,P_NEED_BY_DATE), nvl(P_NEED_BY_DATE,need_by_start_date))),
        -- if P_NEED_BY_DATE is NULL, keep existing need_by_date
        need_by_date = decode(P_CONTRACT_TYPE, 'BLANKET', to_date(NULL), greatest(nvl(need_by_date,P_NEED_BY_DATE), nvl(P_NEED_BY_DATE,need_by_date))),
        attachment_flag = decode(attachment_flag, 'Y', 'Y', v_has_attachments),
        -- if P_PRICE is NULL, keep existing current_price
        current_price = decode(P_PRICE, 0, to_number(NULL), decode(current_price, NULL, NULL, least(current_price, P_PRICE)))
      WHERE auction_header_id = P_DOCUMENT_NUMBER
        AND line_number = P_LINE_NUMBER;
    END IF;
  ELSE
    v_was_grouped := 'N';

    IF (v_order_type_lookup_code = 'AMOUNT') THEN
      v_price    := P_QUANTITY;
      v_quantity := 1;

      -- Find the UOM Code
      -- Get site ID for the enterprise
      v_debug_status := 'SITE_ID';
      pos_enterprise_util_pkg.get_enterprise_partyId(v_site_id,
						     P_ERROR_CODE,
						     P_ERROR_MESSAGE);
      IF (v_site_id IS NULL OR P_ERROR_CODE IS NOT NULL) THEN
        P_RESULT := error;
        P_ERROR_CODE := 'ADD_NEG_LINE:GET_ENTERPRISE_ID';
        P_ERROR_MESSAGE := 'Could not get the Enterprise ID';
        RETURN;
      END IF;

      v_debug_status := 'UOM_SELECT';
      BEGIN
        SELECT preference_value
        INTO v_uom_code
        FROM pon_party_preferences
        WHERE preference_name = 'AMOUNT_BASED_UOM'
          AND app_short_name = 'PON'
          AND party_id = v_site_id;
      EXCEPTION
        WHEN others THEN
	  -- Don't fail!  Use 'Each' and let the user change it later
          v_debug_status := 'UOM_SELECT_EACH';
          SELECT uom_code
          INTO v_uom_code
          FROM mtl_units_of_measure
          WHERE unit_of_measure = 'Each';
      END;
    ELSE
      -- bug 4677078 set price to null if requisition price is 0
      IF (P_PRICE = 0) THEN
        v_price := to_number(NULL);
      ELSE
        v_price    := P_PRICE;
      END IF;

      -- if its services line type you donot want to carry over the quantity column
      -- For 11i10+ we WILL carry over the quantity as is done by iP for the
      -- rate based line type
      IF (v_order_type_lookup_code = 'FIXED PRICE') THEN
        v_quantity := NULL;
      ELSE
        v_quantity := P_QUANTITY;
      END IF;
      v_uom_code := P_UOM_CODE;
    END IF;

    -- Get category name from category_id
    v_debug_status := 'GET_CATEGORY_NAME';
    BEGIN
      -- for the bug 14778209
      -- Replacing 'FND_FLEX_EXT.get_segs' method call with CONCATENATED_SEGMENTS
     -- SELECT FND_FLEX_EXT.get_segs('INV', 'MCAT', STRUCTURE_ID, CATEGORY_ID)
      SELECT CONCATENATED_SEGMENTS
      INTO v_category_name
      FROM mtl_categories_kfv
      WHERE category_id = P_CATEGORY_ID;
    EXCEPTION
      WHEN no_data_found THEN
        -- Don't fail!  The user can assign this later
	v_category_name := NULL;
    END;

    -- Insert row in PON_AUCTION_ITEM_PRICES
    v_debug_status := 'GET_LINE_NUMBER';

    -- The value that is calculated here for p_line_number is used
    -- for setting the number_of_lines and last_line_number fields
    -- also.
    SELECT nvl(max(line_number),0)+1
    INTO P_LINE_NUMBER
    FROM pon_auction_item_prices_all
    WHERE auction_header_id = P_DOCUMENT_NUMBER;

    v_debug_status := 'INSERT_PAIP';
    INSERT INTO PON_AUCTION_ITEM_PRICES_ALL (
	AUCTION_HEADER_ID,
	LINE_NUMBER,
        DISP_LINE_NUMBER,
        LAST_AMENDMENT_UPDATE,
        MODIFIED_DATE,
	ITEM_DESCRIPTION,
	CATEGORY_ID,
	CATEGORY_NAME,
        IP_CATEGORY_ID,
	UOM_CODE,
	QUANTITY,
	RESIDUAL_QUANTITY,
	NEED_BY_START_DATE,
	NEED_BY_DATE,
	SHIP_TO_LOCATION_ID,
	NUMBER_OF_BIDS,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CURRENT_PRICE,
	NOTE_TO_BIDDERS,
	ATTACHMENT_FLAG,
	HAS_ATTRIBUTES_FLAG,
	ORG_ID,
	LINE_TYPE_ID,
	ORDER_TYPE_LOOKUP_CODE,
	PURCHASE_BASIS,
	ITEM_ID,
	ITEM_NUMBER,
	ITEM_REVISION,
	LINE_ORIGINATION_CODE,
	REQUISITION_NUMBER,
        PRICE_BREAK_TYPE,
        PRICE_BREAK_NEG_FLAG,
        HAS_SHIPMENTS_FLAG,
        HAS_QUANTITY_TIERS,
        PRICE_DISABLED_FLAG,
	quantity_disabled_flag,
	JOB_ID,
	ADDITIONAL_JOB_DETAILS,
	PO_AGREED_AMOUNT,
	HAS_PRICE_DIFFERENTIALS_FLAG,
	PRICE_DIFF_SHIPMENT_NUMBER,
	DIFFERENTIAL_RESPONSE_TYPE,
        GROUP_TYPE,
	DOCUMENT_DISP_LINE_NUMBER,
	SUB_LINE_SEQUENCE_NUMBER,
        HAS_PAYMENTS_FLAG,
        PROGRESS_PYMT_RATE_PERCENT
      ) VALUES (
	P_DOCUMENT_NUMBER,	-- AUCTION_HEADER_ID
	P_LINE_NUMBER,
        P_LINE_NUMBER,          -- DISP_LINE_NUMBER
        0,                      -- LAST_AMENDMENT_UPDATE
        sysdate,                -- MODIFIED_DATE
	P_ITEM_DESCRIPTION,
	P_CATEGORY_ID,
	v_category_name,	-- CATEGORY_NAME
        v_ip_category_id,       -- IP_CATEGORY_ID
	v_uom_code,		-- UOM_CODE
	v_quantity,             -- QUANTITY
	v_quantity,             -- RESIDUAL_QUANTITY,
	decode(P_CONTRACT_TYPE, 'BLANKET', to_date(NULL), P_NEED_BY_DATE),		-- NEED_BY_START_DATE
	decode(P_CONTRACT_TYPE, 'BLANKET', to_date(NULL), P_NEED_BY_DATE),		-- NEED_BY_DATE
	decode(P_CONTRACT_TYPE, 'BLANKET', NULL, p_ship_to_location_id),	-- SHIP_TO_LOCATION_ID
	0,			-- NUMBER_OF_BIDS
	sysdate,		-- CREATION_DATE
	P_BUYER_ID,		-- CREATED_BY
	sysdate,		-- LAST_UPDATE_DATE
	P_BUYER_ID,		-- LAST_UPDATED_BY
	v_price,		-- CURRENT_PRICE
	P_NOTE_TO_VENDOR,	-- NOTE_TO_BIDDERS
	v_has_attachments,	-- ATTACHMENT_FLAG
	'N',			-- HAS_ATTRIBUTE_FLAG
	P_ORG_ID,		-- ORG_ID
	P_LINE_TYPE_ID,
	v_order_type_lookup_code, -- ORDER_TYPE_LOOKUP_CODE
	v_purchase_basis,       -- Purchase Basis
	P_ITEM_ID,
	P_ITEM_NUMBER,
	P_ITEM_REVISION,
	P_ORIGINATION_CODE,	-- LINE_ORIGINATION_CODE
	P_REQUISITION_NUMBER,
        decode(v_order_type_lookup_code,'AMOUNT', 'NONE', 'FIXED PRICE', 'NONE', g_price_break_type), -- PRICE_BREAK_TYPE
        g_price_break_neg_flag, -- PRICE_BREAK_NEG_FLAG
        'N',                    -- HAS_SHIPMENTS_FLAG
        'N',                    -- HAS_QUANTITY_TIERS
        'N',                    -- PRICE_DISABLED_FLAG
        'N',                     -- QUANTITY_DISABLED_FLAG
        P_JOB_ID,               -- JOB ID - ADDED FOR SERVICES PROCUREMENT PROJECT
        P_JOB_DETAILS,          -- ADDITIONAL JOB DETAILS -ADDED FOR SERVICES PROCUREMENT PROJECT
        P_PO_AGREED_AMOUNT,     -- PO AGREED AMOUNT -ADDED FOR SERVICES PROCUREMENT PROJECT
        p_has_price_diff_flag,  -- LINE HAS PRICE DIFFERENTIALS ADDED FOR SERVICES PROCUREMENT PROJECT-
      -1,                      --price diff shipment number is -1 by default
      Decode(p_has_price_diff_flag,'Y','OPTIONAL', NULL),
        'LINE',                 -- GROUP_TYPE
	P_LINE_NUMBER,          -- DOCUMENT_DISP_LINE_NUMBER
        P_LINE_NUMBER,           -- SUB_LINE_SEQUENCE_NUMBER
        'N',                      --has_payments_flag
        decode(g_progress_payment_type, 'FINANCE', 100,null) --PROGRESS_PYMT_RATE_PERCENT
     );

     -- We already do an nvl(max(line_number),0)+1 to find the line number of
     -- the newly added line. So this value can be used for the fields
     -- number_of_lines and last_line_number.
     -- The number of lines will be equal to the line number of the new line added
     -- The last line number will be equal to the line number of the newly added line
     UPDATE PON_AUCTION_HEADERS_ALL
     SET
       NUMBER_OF_LINES = P_LINE_NUMBER,
       LAST_LINE_NUMBER = P_LINE_NUMBER
     WHERE
       AUCTION_HEADER_ID = P_DOCUMENT_NUMBER;

  END IF;

  -- Insert row into PON_BACKING_REQUISITIONS
  v_debug_status := 'INSERT_PBR_YUMMY';
  INSERT INTO PON_BACKING_REQUISITIONS (
	AUCTION_HEADER_ID,
	LINE_NUMBER,
	REQUISITION_HEADER_ID,
	REQUISITION_LINE_ID,
	REQUISITION_QUANTITY,
	REQUISITION_NUMBER
  ) VALUES (
	P_DOCUMENT_NUMBER,
	P_LINE_NUMBER,
	P_REQUISITION_HEADER_ID,
	P_REQUISITION_LINE_ID,
	P_QUANTITY,
	P_REQUISITION_NUMBER
  );

  -- Copy attachments from requisition (header, item and line)
  IF (v_has_attachments = 'Y') THEN
    -- Copy requisition header attachments
    v_debug_status := 'INSERT_HEADER_ATTACHMENT';
    fnd_attached_documents2_pkg.COPY_ATTACHMENTS (
      'REQ_HEADERS',                    --from_entity_name
      to_char(p_requisition_header_id), -- from_pk1_value
      NULL,                             -- from_pk2_value
      NULL,                             -- from_pk3_value
      NULL,                             -- from_pk4_value
      NULL,                             -- from_pk5_value
      'PON_AUCTION_ITEM_PRICES_ALL',    -- entity_name
      to_char(P_DOCUMENT_NUMBER),       -- PK1_VALUE
      to_char(P_LINE_NUMBER),		-- PK2_VALUE
      NULL,				-- PK3_VALUE
      NULL,				-- PK4_VALUE
      NULL,				-- PK5_VALUE
      p_buyer_id,			-- CREATED_BY
      p_buyer_id,                       -- LAST_UPDATE_LOGIN
      NULL,                             -- program_application_id
      NULL,                             -- program_id
      NULL,                             -- request_id
      NULL,                             -- automatically_added_flag
      33,                               -- from_category_id (Vendor)
      33);                              -- to_category_id (Vendor)

    -- Copy requisition line attachments
    v_debug_status := 'INSERT_LINE_ATTACHMENT';
    fnd_attached_documents2_pkg.COPY_ATTACHMENTS (
      'REQ_LINES',                      --from_entity_name
      to_char(p_requisition_line_id),   -- from_pk1_value
      NULL,                             -- from_pk2_value
      NULL,                             -- from_pk3_value
      NULL,                             -- from_pk4_value
      NULL,                             -- from_pk5_value
      'PON_AUCTION_ITEM_PRICES_ALL',    -- entity_name
      to_char(P_DOCUMENT_NUMBER),       -- PK1_VALUE
      to_char(P_LINE_NUMBER),		-- PK2_VALUE
      NULL,				-- PK3_VALUE
      NULL,				-- PK4_VALUE
      NULL,				-- PK5_VALUE
      p_buyer_id,			-- CREATED_BY
      p_buyer_id,                       -- LAST_UPDATE_LOGIN
      NULL,                             -- program_application_id
      NULL,                             -- program_id
      NULL,                             -- request_id
      NULL,                             -- automatically_added_flag
      33,                               -- from_category_id (Vendor)
      33);                              -- to_category_id (Vendor)

  END IF; -- v_has_attachments

  P_RESULT := success;
  P_ERROR_CODE := NULL;
  P_ERROR_MESSAGE := NULL;
EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('PON', 'PON_AUC_PLSQL_ERR');
    fnd_message.set_token('PACKAGE','pon_auction_interface_pkg');
    fnd_message.set_token('PROCEDURE','Add_Negotiation_Line');
    fnd_message.set_token('ERROR',v_debug_status || ' [' || SQLERRM || ']');
    APP_EXCEPTION.RAISE_EXCEPTION;
END;

/*============ADDED FOR UNIFIED CATALOG PROJECT=====================
 PROCEDURE : Add_Catalog_Descriptors
 PARAMETERS:
  P_API_VERSION                 IN       NUMBER
  P_DOCUMENT_NUMBER             IN       NUMBER
  X_RETURN_STATUS               OUT      NOCOPY  VARCHAR2
  X_MSG_COUNT                   OUT      NOCOPY  NUMBER
  X_MSG_DATA                    OUT      NOCOPY  VARCHAR2
 COMMENT   : Adds ip descriptors to a draft auction
======================================================================*/

PROCEDURE Add_Catalog_Descriptors (
 P_API_VERSION                 IN       NUMBER,
 P_DOCUMENT_NUMBER             IN       NUMBER,
 X_RETURN_STATUS               OUT      NOCOPY  VARCHAR2,
 X_MSG_COUNT                   OUT      NOCOPY  NUMBER,
 X_MSG_DATA                    OUT      NOCOPY  VARCHAR2) IS
v_contract_type pon_auction_headers_all.contract_type%TYPE;
v_buyer_id NUMBER;
v_ip_attr_default_option VARCHAR2(10);
v_default_attr_group pon_auction_attributes.attr_group%TYPE;
v_attr_group_name      fnd_lookup_values.meaning%TYPE;
v_max_seq_number       NUMBER;
v_line_number NUMBER;
v_ip_category_id NUMBER;
v_debug_status          VARCHAR2(100);

v_return_status        VARCHAR2(1);
v_msg_count            NUMBER;
v_msg_data             VARCHAR2(400);

CURSOR catalogLines IS
  SELECT distinct interface_line_number
  FROM   pon_attributes_interface
  WHERE  interface_auction_header_id = p_document_number;


CURSOR nonCatalogLines IS
  SELECT distinct paip.line_number, paip.ip_category_id
  FROM   pon_auction_item_prices_all paip,
         pon_backing_requisitions pbr,
         po_requisition_lines_all prl
  WHERE  paip.auction_header_id = p_document_number and
         paip.auction_header_id = pbr.auction_header_id and
         paip.line_number = pbr.line_number and
         pbr.requisition_header_id = prl.requisition_header_id and
         pbr.requisition_line_id = prl.requisition_line_id and
         prl.blanket_po_header_id is null and
         prl.blanket_po_line_num is null;

BEGIN

  SELECT contract_type, created_by
  INTO   v_contract_type, v_buyer_id
  FROM   pon_auction_headers_all
  WHERE  auction_header_id = p_document_number;

  v_ip_attr_default_option := fnd_profile.value('PON_IP_ATTR_DEFAULT_OPTION');

  IF (v_contract_type <> 'BLANKET' or v_ip_attr_default_option is null or v_ip_attr_default_option = 'NONE') THEN
    RETURN;
  END IF;

  select nvl(ppp.preference_value,'GENERAL'),
         flv.meaning
  into   v_default_attr_group,
         v_attr_group_name
  from pon_party_preferences ppp,
       fnd_lookup_values flv
  where ppp.app_short_name = 'PON' and
        ppp.preference_name = 'LINE_ATTR_DEFAULT_GROUP' and
        ppp.party_id = (select trading_partner_id from pon_auction_headers_all where auction_header_id = p_document_number) and
        flv.lookup_type = 'PON_LINE_ATTRIBUTE_GROUPS' and
        nvl(ppp.preference_value,'GENERAL') = flv.lookup_code and
        flv.view_application_id = 0 and
        flv.security_group_id = 0 and
        flv.language = userenv('LANG');

  v_max_seq_number := 9999999999999;


  PO_NEGOTIATIONS4_GRP.insert_attributes(
             p_api_version               => 1.0,
             p_commit                    => fnd_api.g_false,
             p_init_msg_list             => fnd_api.g_false,
             p_validation_level          => fnd_api.g_valid_level_full,
             p_auction_header_id         => p_document_number,
             x_return_status             => v_return_status,
             x_msg_count                 => v_msg_count,
             x_msg_data                  => v_msg_data);

  FOR catalogLine in catalogLines
  LOOP

    v_line_number := catalogLine.interface_line_number;

    INSERT INTO PON_AUCTION_ATTRIBUTES (
       AUCTION_HEADER_ID,
       LINE_NUMBER,
       ATTRIBUTE_NAME,
       DESCRIPTION,
       DATATYPE,
       MANDATORY_FLAG,
       VALUE,
       DISPLAY_PROMPT,
       HELP_TEXT,
       DISPLAY_TARGET_FLAG,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       ATTRIBUTE_LIST_ID,
       DISPLAY_ONLY_FLAG,
       SEQUENCE_NUMBER,
       COPIED_FROM_CAT_FLAG,
       WEIGHT,
       SCORING_TYPE,
       ATTR_LEVEL,
       ATTR_GROUP,
       SECTION_NAME,
       ATTR_MAX_SCORE,
       INTERNAL_ATTR_FLAG,
       ATTR_GROUP_SEQ_NUMBER,
       ATTR_DISP_SEQ_NUMBER,
       MODIFIED_FLAG,
       MODIFIED_DATE,
       LAST_AMENDMENT_UPDATE,
       IP_CATEGORY_ID,
       IP_DESCRIPTOR_ID
    )
    SELECT
       P_DOCUMENT_NUMBER,      -- AUCTION_HEADER_ID
       INTERFACE_LINE_NUMBER,  -- LINE_NUMBER
       ATTRIBUTE_NAME,         -- ATTRIBUTE_NAME
       null,                   -- DESCRIPTION
       DATATYPE,               -- DATATYPE
       'N',                    -- MANDATORY_FLAG
       VALUE,                  -- VALUE
       null,                   -- DISPLAY_PROMPT
       null,                   -- HELP_TEXT
       'N',                    -- DISPLAY_TARGET_FLAG
       SYSDATE,                -- CREATION_DATE
       v_buyer_id,             -- CREATED_BY
       SYSDATE,                -- LAST_UPDATE_DATE
       v_buyer_id,             -- LAST_UPDATED_BY
       -1,                     -- ATTRIBUTE_LIST_ID
       'N',                    -- DISPLAY_ONLY_FLAG
       (ROWNUM*10),            -- SEQUENCE_NUMBER
       null,                   -- COPIED_FROM_CAT_FLAG
       null,                   -- WEIGHT
       null,                   -- SCORING_TYPE
       'LINE',                 -- ATTR_LEVEL
       v_default_attr_group,   -- ATTR_GROUP
       v_attr_group_name,      -- SECTION_NAME
       null,                   -- ATTR_MAX_SCORE
       'N',                    -- INTERNAL_ATTR_FLAG
       10,                     -- ATTR_GROUP_SEQ_NUMBER
       (ROWNUM*10),            -- ATTR_DISP_SEQ_NUMBER
       null,                   -- MODIFIED_FLAG
       null,                   -- MODIFIED_DATE
       null,                   -- LAST_AMENDMENT_UPDATE
       IP_CATEGORY_ID,         -- IP_CATEGORY_ID
       IP_DESCRIPTOR_ID        -- IP_DESCRIPTOR_ID
    FROM
       (SELECT interface_line_number, attribute_name, datatype,
               value, ip_category_id, ip_descriptor_id
        FROM   pon_attributes_interface
        WHERE  interface_auction_header_id = P_DOCUMENT_NUMBER AND
               interface_line_number = v_line_number AND
               ((ip_category_id = 0 and v_ip_attr_default_option in ('ALL', 'BASE')) or
                (ip_category_id <> 0 and v_ip_attr_default_option in ('ALL', 'CATEGORY')))
        ORDER BY nvl(interface_sequence_number, v_max_seq_number) asc);

  END LOOP;

  DELETE FROM PON_ATTRIBUTES_INTERFACE
  WHERE  interface_auction_header_id  = P_DOCUMENT_NUMBER;


  FOR nonCatalogLine in nonCatalogLines
  LOOP

    v_line_number := nonCatalogLine.line_number;
    v_ip_category_id := nonCatalogLine.ip_category_id;

    INSERT INTO PON_AUCTION_ATTRIBUTES (
       AUCTION_HEADER_ID,
       LINE_NUMBER,
       ATTRIBUTE_NAME,
       DESCRIPTION,
       DATATYPE,
       MANDATORY_FLAG,
       VALUE,
       DISPLAY_PROMPT,
       HELP_TEXT,
       DISPLAY_TARGET_FLAG,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       ATTRIBUTE_LIST_ID,
       DISPLAY_ONLY_FLAG,
       SEQUENCE_NUMBER,
       COPIED_FROM_CAT_FLAG,
       WEIGHT,
       SCORING_TYPE,
       ATTR_LEVEL,
       ATTR_GROUP,
       SECTION_NAME,
       ATTR_MAX_SCORE,
       INTERNAL_ATTR_FLAG,
       ATTR_GROUP_SEQ_NUMBER,
       ATTR_DISP_SEQ_NUMBER,
       MODIFIED_FLAG,
       MODIFIED_DATE,
       LAST_AMENDMENT_UPDATE,
       IP_CATEGORY_ID,
       IP_DESCRIPTOR_ID
    )
    SELECT
       P_DOCUMENT_NUMBER,                   -- AUCTION_HEADER_ID
       v_line_number,                       -- LINE_NUMBER
       DESCRIPTOR_NAME,                     -- ATTRIBUTE_NAME
       null,                                -- DESCRIPTION
       DATATYPE,                            -- DATATYPE
       'N',                                 -- MANDATORY_FLAG
       null,                                -- VALUE
       null,                                -- DISPLAY_PROMPT
       null,                                -- HELP_TEXT
       'N',                                 -- DISPLAY_TARGET_FLAG
       SYSDATE,                             -- CREATION_DATE
       v_buyer_id,                          -- CREATED_BY
       SYSDATE,                             -- LAST_UPDATE_DATE
       v_buyer_id,                          -- LAST_UPDATED_BY
       -1,                                  -- ATTRIBUTE_LIST_ID
       'N',                                 -- DISPLAY_ONLY_FLAG
       (ROWNUM*10),                         -- SEQUENCE_NUMBER
       null,                                -- COPIED_FROM_CAT_FLAG
       null,                                -- WEIGHT
       null,                                -- SCORING_TYPE
       'LINE',                              -- ATTR_LEVEL
       v_default_attr_group,                -- ATTR_GROUP
       v_attr_group_name,                   -- SECTION_NAME
       null,                                -- ATTR_MAX_SCORE
       'N',                                 -- INTERNAL_ATTR_FLAG
       10,                                  -- ATTR_GROUP_SEQ_NUMBER
       (ROWNUM*10),                         -- ATTR_DISP_SEQ_NUMBER
       null,                                -- MODIFIED_FLAG
       null,                                -- MODIFIED_DATE
       null,                                -- LAST_AMENDMENT_UPDATE
       IP_CATEGORY_ID,                      -- IP_CATEGORY_ID
       IP_DESCRIPTOR_ID                     -- IP_DESCRIPTOR_ID
    FROM
         (SELECT attribute_name descriptor_name, decode(type, 1, 'NUM', 'TXT') datatype,
                 rt_category_id ip_category_id, attribute_id ip_descriptor_id
          FROM   icx_cat_agreement_attrs_v
          WHERE  ((rt_category_id = 0 and v_ip_attr_default_option in ('ALL', 'BASE')) or
        (rt_category_id = v_ip_category_id and v_ip_attr_default_option in ('ALL', 'CATEGORY'))) and language = userenv('LANG')
          ORDER BY nvl(sequence, v_max_seq_number) asc);

  END LOOP;

  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  X_MSG_COUNT := 0;
  X_MSG_DATA := NULL;

EXCEPTION
  WHEN OTHERS THEN
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR ;
    X_MSG_COUNT := 1;
    fnd_message.set_name('PON', 'PON_AUC_PLSQL_ERR');
    fnd_message.set_token('PACKAGE','pon_auction_interface_pkg');
    fnd_message.set_token('PROCEDURE','Add_Catalog_Descriptors');
    fnd_message.set_token('ERROR',v_debug_status || ' [' || SQLERRM || ']');
    fnd_message.retrieve(X_MSG_DATA);
    RETURN;
END Add_Catalog_Descriptors;

/*============ADDED FOR SERVICES PROCUREMENT PROJECT=====================
 PROCEDURE : Add_Price_Differential
 PARAMETERS:
  P_DOCUMENT_NUMBER	        IN	Document number to add line
  P_LINE_NUMBER                 IN      Line number
  P_SHIPMENT_NUMBER             IN      Shipment number
  P_PRICE_TYPE                  IN      Price Type
  P_MULTIPLIER                  IN      Multiplier
  P_BUYER_ID                    IN      FND_USER_ID of the creator
  P_PRICE_DIFFERENTIAL_NUMBER 	OUT	Price Differential Number

  P_RESULT      	        OUT     One of (error, success)
  P_ERROR_CODE		        OUT	Internal Error Code
  P_ERROR_MESSAGE	        OUT	Displayable error
 COMMENT   : Creates a price differential in a draft auction
======================================================================*/

PROCEDURE Add_Price_Differential (
 P_DOCUMENT_NUMBER	       IN	NUMBER,
 P_LINE_NUMBER                 IN       NUMBER,
 P_SHIPMENT_NUMBER             IN       NUMBER,
 P_PRICE_TYPE                  IN       VARCHAR2,
 P_MULTIPLIER                  IN       NUMBER,
 P_BUYER_ID                    IN       NUMBER,
 P_PRICE_DIFFERENTIAL_NUMBER   OUT NOCOPY     NUMBER,
 P_RESULT		       OUT	NOCOPY	NUMBER,
 P_ERROR_CODE		       OUT	NOCOPY	VARCHAR2,
 P_ERROR_MESSAGE	       OUT	NOCOPY	VARCHAR2)IS

    v_debug_status VARCHAR2(100);

BEGIN



   -- Find the max price_diff_line number for this line and save it
   SELECT nvl(max(price_differential_number),0)+1
    INTO p_price_differential_number
     FROM pon_price_differentials
     WHERE auction_header_id = p_document_number AND
     line_number = p_line_number AND
     shipment_number = p_shipment_number;

   IF (p_document_number IS NULL) THEN
      p_result := error;
      p_error_code := 'ADD_PRICE_DIFFERENTIAL:DOCUMENT_NUMBER';
      p_error_message := 'Please provide a valid document number';
      RETURN;
   END IF;

   IF (p_line_number  IS NULL OR p_line_number < 0) THEN
      p_result := error;
      p_error_code := 'ADD_PRICE_DIFFERENTIAL:LINE_NUMBER';
      p_error_message := 'Line Number cannot be null. Its either a valid positive number or -1.';
      RETURN;
   END IF ;

   IF (p_shipment_number  IS NULL) THEN
      p_result := error;
      p_error_code := 'ADD_PRICE_DIFFERENTIAL:SHIPMENT_NUMBER';
      p_error_message := 'Shipment Number cannot be null. Its either a valid positive number or -1.';
      RETURN;
   END IF ;

   IF ((p_line_number = -1) AND (p_shipment_number = -1)) THEN
      p_result := error;
      p_error_code := 'ADD_PRICE_DIFFERENTIAL:INVALID_VALUES';
      p_error_message := 'Both Line Number and Shipment Number cannot be -1';
      RETURN;
   END IF;


   v_debug_status := 'INSERT_PRICE_DIFFERENTIALS';

   INSERT INTO pon_price_differentials
      (
      auction_header_id,
      line_number,
      shipment_number,
      price_differential_number,
      price_type,
      multiplier,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by
       )VALUES(
	       p_document_number,           -- Auction Header Id
	       p_line_number,               -- Line Number
	       p_shipment_number,           -- Shipment Number
	       p_price_differential_number, -- Price Differentials Number
	       p_price_type,                -- Price Type
	       p_multiplier,                -- Multiplier
	       Sysdate,                     -- creation date
	       p_buyer_id,                  -- created by
	       Sysdate,                     -- last update date
	       p_buyer_id                   -- last updated by
	       );

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('PON', 'PON_AUC_PLSQL_ERR');
    fnd_message.set_token('PACKAGE','pon_auction_interface_pkg');
    fnd_message.set_token('PROCEDURE','Add_Price_Differential');
    fnd_message.set_token('ERROR',v_debug_status || ' [' || SQLERRM || ']');
    APP_EXCEPTION.RAISE_EXCEPTION;
END;


/*========================================================================
 PROCEDURE : Get_Negotiation_Owner
 PARAMETERS:
  P_DOCUMENT_NUMBER	IN	Document Id
  P_OWNER_NAME		OUT	FND_USER.USER_NAME of document owner
  P_RESULT      	OUT     One of (error, success)
  P_ERROR_CODE		OUT	Internal Error Code
  P_ERROR_MESSAGE	OUT	Displayable error
 COMMENT   : Returns the owner name for a negotiation document
--======================================================================*/
PROCEDURE Get_Negotiation_Owner(
 P_DOCUMENT_NUMBER	IN	NUMBER,
 P_OWNER_NAME		OUT	NOCOPY	VARCHAR2,
 P_RESULT		OUT	NOCOPY	NUMBER,
 P_ERROR_CODE		OUT	NOCOPY	VARCHAR2,
 P_ERROR_MESSAGE	OUT	NOCOPY	VARCHAR2) IS

v_buyer_name  fnd_user.user_name%TYPE := NULL;

BEGIN
  BEGIN
    SELECT u1.user_name, u2.user_name
    INTO P_OWNER_NAME, v_buyer_name
    FROM fnd_user u1, fnd_user u2, pon_auction_headers_all ah
    WHERE ah.auction_header_id = P_DOCUMENT_NUMBER
      AND ah.trading_partner_contact_id = u1.person_party_id(+)
      AND ah.buyer_id = u2.user_id(+);
  EXCEPTION
    WHEN no_data_found THEN
      -- No owner found for a Document is not an error.
      P_OWNER_NAME := NULL;
  END;

  IF (P_OWNER_NAME IS NULL) THEN
    P_OWNER_NAME := v_buyer_name;
  END IF;

  P_RESULT := success;
  P_ERROR_CODE := NULL;
  P_ERROR_MESSAGE := NULL;
EXCEPTION
  WHEN OTHERS THEN
    P_RESULT := error;
    P_ERROR_CODE := 'GET_NEG_OWNER';
    fnd_message.set_name('PON', 'PON_AUC_PLSQL_ERR');
    fnd_message.set_token('PACKAGE','pon_auction_interface_pkg');
    fnd_message.set_token('PROCEDURE','Get_Negotiation_Owner');
    fnd_message.set_token('ERROR','Document ' || P_DOCUMENT_NUMBER || ' [' || SQLERRM || ']');
    fnd_message.retrieve(P_ERROR_MESSAGE);
END;

/*========================================================================
 PROCEDURE : Get_PO_Negotiation_Link     PUBLIC
 PARAMETERS:
  P_PO_HEADER_ID        IN      PO Header Id
  P_DOCUMENT_ID         OUT     Negotiation document id
  P_DOCUMENT_NUMBER     OUT     Negotiation Document number display
  P_DOCUMENT_URL        OUT     URL to view negotiation document
  P_RESULT              OUT     One of (error, success)
  P_ERROR_CODE          OUT     Internal code for error
  P_ERROR_MESSAGE       OUT     Displayable error message
 COMMENT   : Returns the Negotiation Document number and Sourcing URL
   for viewing the Negotiation Document.  The Negotiation Document number
   returned is formatted for display and may not be the same as the
   pon_auction_headers.auction_header_id.  The Document Number should not
   be used in subsequent calls to this API.
   FPJ: As we migrated to OA, this API is also updated. Because we cannot
        encrypt id at pl/sql, we return id as an out parameter. The caller
        needs to encrypt the id, and append to the url.
======================================================================*/
PROCEDURE Get_PO_Negotiation_Link(
 P_PO_HEADER_ID        IN      NUMBER,
 P_DOCUMENT_ID         OUT     NOCOPY   NUMBER,
 P_DOCUMENT_NUMBER     OUT     NOCOPY	VARCHAR2,
 P_DOCUMENT_URL        OUT     NOCOPY	VARCHAR2,
 P_RESULT              OUT     NOCOPY	NUMBER,
 P_ERROR_CODE          OUT     NOCOPY	VARCHAR2,
 P_ERROR_MESSAGE       OUT     NOCOPY	VARCHAR2) IS

v_debug_status      VARCHAR2(60);

BEGIN
  BEGIN
    SELECT ah.auction_header_id, ah.document_number
    INTO P_DOCUMENT_ID, P_DOCUMENT_NUMBER
    FROM pon_bid_headers bh, pon_auction_headers_all ah
    WHERE bh.po_header_id = P_PO_HEADER_ID
      AND bh.auction_header_id = ah.auction_header_id;
  EXCEPTION
    WHEN no_data_found THEN
      -- No negotiation found for a PO is not an error
      P_DOCUMENT_ID := NULL;
      P_DOCUMENT_NUMBER := NULL;
      P_DOCUMENT_URL := NULL;
      P_RESULT := success;
      P_ERROR_CODE := NULL;
      P_ERROR_MESSAGE := NULL;
      RETURN;
  END;

  -- Construct URL to View Negotation
  v_debug_status := 'DOC_URL';
  P_DOCUMENT_URL := 'OA.jsp?OAFunc=PON_NEG_SUMMARY';
  P_RESULT := success;
  P_ERROR_CODE := NULL;
  P_ERROR_MESSAGE := NULL;
EXCEPTION
  WHEN OTHERS THEN
    P_RESULT := error;
    P_ERROR_CODE := 'GET_NEG_OWNER';
    fnd_message.set_name('PON', 'PON_AUC_PLSQL_ERR');
    fnd_message.set_token('PACKAGE','pon_auction_interface_pkg');
    fnd_message.set_token('PROCEDURE','Get_PO_Negotiation_Link');
    fnd_message.set_token('ERROR','PO Header ' || P_PO_HEADER_ID || ' [' || SQLERRM || ']');
    fnd_message.retrieve(P_ERROR_MESSAGE);
END;
--
/*===================================================================
 PROCEDURE: add_negotiation_invitees    PUBLIC
 PARAMETERS:
  p_api_version          IN      version of the api
  x_return_status        OUT     FND_API.G_RET_STS_SUCCESS or FND_API.G_RET_STS_ERROR
  x_msg_count            OUT     Internal code for error
  x_msg_data             OUT     Displayable error message
  P_DOCUMENT_NUMBER      IN      Negotiation Document number
  P_BUYER_ID             IN      FND_USER_ID of the creator
 COMMENT: Gets distinct vendor_ids and vendor sites
   across all the requisition lines that are part of the
   negotiation and adds (bulk inserts ) them as invitees. We do not check
   for inactive suppliers/ sites in the autocreate process; these
   will be validated at publish time.
=====================================================================*/
PROCEDURE add_negotiation_invitees(
 p_api_version          IN              NUMBER,
 x_return_status        OUT     NOCOPY  VARCHAR2,
 x_msg_count            OUT     NOCOPY  NUMBER,
 x_msg_data             OUT     NOCOPY  VARCHAR2,
 P_DOCUMENT_NUMBER      IN              NUMBER,
 P_BUYER_ID             IN              NUMBER) IS
 l_api_version CONSTANT NUMBER := 1.0;
 l_api_name CONSTANT VARCHAR2(50):= 'add_negotiation_invitees';

BEGIN

 -- Check for call compatibility.
 IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
	                             l_api_name, g_pkg_name)
 THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 IF (P_DOCUMENT_NUMBER IS NULL) THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := 'Please provide a DOCUMENT_NUMBER';
    RETURN;
  END IF;


   IF (P_BUYER_ID IS NULL) THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := 'Please specify a BUYER_ID';
    RETURN;
  END IF;

  INSERT INTO PON_BIDDING_PARTIES
     (
         AUCTION_HEADER_ID,
         List_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         SEQUENCE,
         TRADING_PARTNER_NAME,
         TRADING_PARTNER_ID,
         TRADING_PARTNER_CONTACT_NAME,
         TRADING_PARTNER_CONTACT_ID,
         CREATION_DATE,
         CREATED_BY,
         NUMBER_PRICE_DECIMALS,
         ROUND_NUMBER,
         LAST_AMENDMENT_UPDATE,
         VENDOR_SITE_ID,
         VENDOR_SITE_CODE,
         ACCESS_TYPE
      )
  SELECT
         P_DOCUMENT_NUMBER,                   --AUCTION_HEADER_ID
         -1,                                  -- List_ID
         sysdate,                             --  LAST_UPDATE_DATE
         p_buyer_id,                          --  LAST_UPDATED_BY
         rownum * 10,                         -- SEQUENCE
         vendor_name,                         --  TRADING_PARTNER_NAME
         party_id,                            -- TRADING_PARTNER_ID
         null,                                --  TRADING_PARTNER_CONTACT_NAME
         null,                                --  TRADING_PARTNER_CONTACT_ID
         sysdate,                             --  CREATION_DATE
         p_buyer_id,                          --  CREATED_BY
         NUMBER_PRICE_DECIMALS,               -- NUMBER_PRICE_DECIMALS
         1,                                   -- ROUND_NUMBER
         0,                                   -- LAST_AMENDMENT_UPDATE
         vendor_site_id,                      -- VENDOR_SITE_ID
         vendor_site_code,                    -- VENDOR_SITE_CODE
         'FULL'                               -- ACCESS_TYPE
  FROM
     (SELECT DISTINCT
         pv.vendor_name vendor_name,
         pv.party_id party_id,
         ponah.number_price_decimals number_price_decimals,
         nvl(prl.vendor_site_id, -1) vendor_site_id,
         nvl(ps.vendor_site_code, -1) vendor_site_code
 FROM    po_requisition_lines_all prl,
         pon_backing_requisitions ponbr,
         pon_auction_headers_all ponah,
         po_vendors pv,
         po_vendor_sites_all ps
 WHERE  ponah.auction_header_id = p_document_number
    and ponbr.auction_header_id = ponah.auction_header_id
    and ponbr.requisition_header_id = prl.requisition_header_id
    and ponbr.requisition_line_id = prl.requisition_line_id
    and prl.vendor_id is not null
    and prl.vendor_id = pv.vendor_id
    and nvl(pv.start_date_active, sysdate) <= sysdate
    and nvl(pv.end_date_active,  sysdate) >= sysdate
    and ps.vendor_id(+) = prl.vendor_id
    and ps.vendor_site_id(+) = prl.vendor_site_id )
 ORDER BY vendor_name;


  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_count := 0;
      x_msg_data := NULL;
      RETURN;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := 1;
      fnd_message.set_name('PON', 'PON_AUC_PLSQL_ERR');
      fnd_message.set_token('PACKAGE','pon_auction_interface_pkg');
      fnd_message.set_token('PROCEDURE','add_negotiation_invitees');
      fnd_message.set_token('ERROR', ' [' || SQLERRM || ']');
      fnd_message.retrieve(x_msg_data);
      RETURN;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_msg_count := 1;
      fnd_message.set_name('PON', 'PON_AUC_PLSQL_ERR');
      fnd_message.set_token('PACKAGE','pon_auction_interface_pkg');
      fnd_message.set_token('PROCEDURE','add_negotiation_invitees');
      fnd_message.set_token('ERROR', ' [' || SQLERRM || ']');
      --APP_EXCEPTION.RAISE_EXCEPTION;
      fnd_message.retrieve(x_msg_data);
      RETURN;
END;

-- API used by html autocreation for default negotiation style
PROCEDURE get_default_negotiation_style(
                   x_style_id        OUT     NOCOPY  NUMBER,
                   x_style_name      OUT     NOCOPY  VARCHAR2) IS

BEGIN

    select style_id, style_name
      into x_style_id, x_style_name
      from pon_negotiation_styles_tl
     where style_id = 1
       and language = userenv('LANG');

  EXCEPTION
    WHEN OTHERS THEN
       x_style_id := 1;
END;

--
END PON_AUCTION_INTERFACE_PKG;

/
