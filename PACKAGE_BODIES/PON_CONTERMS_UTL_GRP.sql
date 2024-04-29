--------------------------------------------------------
--  DDL for Package Body PON_CONTERMS_UTL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_CONTERMS_UTL_GRP" as
/* $Header: PONCTDVB.pls 120.6 2006/04/17 15:31:42 rrkulkar noship $ */

g_package_name VARCHAR2(30) := 'pon_conterms_utl_grp';

FUNCTION is_contracts_installed RETURN VARCHAR2 IS

BEGIN

	return PON_CONTERMS_UTL_PVT.is_contracts_installed();

EXCEPTION
	WHEN OTHERS THEN
	    RAISE;
END is_contracts_installed;


FUNCTION get_contracts_document_type(
		p_doctype_id	IN	NUMBER,
		p_is_response	IN	VARCHAR2)
RETURN VARCHAR2 IS

BEGIN
  IF (p_is_response = 'Y') THEN
    return  pon_conterms_utl_pvt.get_response_doc_type(p_doctype_id);
  ELSE
    return  pon_conterms_utl_pvt.get_negotiation_doc_type(p_doctype_id);
  END IF;
END get_contracts_document_type;


PROCEDURE ok_to_commit(
		p_api_version            IN NUMBER,
		p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_doctype_id		 IN VARCHAR2,
		p_doc_id                 IN NUMBER,
		x_update_allowed         OUT NOCOPY VARCHAR2,
		x_return_status          OUT NOCOPY VARCHAR2,
		x_msg_data               OUT NOCOPY VARCHAR2,
		x_msg_count              OUT NOCOPY NUMBER
) IS
  l_api_version NUMBER := 1;
  l_api_name 	VARCHAR2(30) := 'IS_OK_TO_COMMIT';
  l_auction_header_id	pon_auction_headers_all.auction_header_id%type;
  l_auction_status	pon_auction_headers_all.auction_status%type;
BEGIN
  --  Initialize API return status to unexpected error
  x_update_allowed := fnd_api.g_false;
  x_return_status := fnd_api.g_ret_sts_unexp_error;
  x_msg_data := 'pon_conterms_utl_grp.ok_to_commit() unexpected error';
  x_msg_count := 1;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;

  -- get auction_header_id
  pon_conterms_utl_pvt.get_auction_header_id(p_doctype_id,
					     p_doc_id,
					     l_auction_header_id,
					     x_return_status,
					     x_msg_data,
					     x_msg_count);
  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
    return ;
  END IF;

  -- check whether the current user holds the lock on the draft
  BEGIN
    -- this is just an existance test but we have to select x into y
    -- to pass the pl/sql compiler so...
    select
      auction.auction_status
    into
      l_auction_status
    from
      fnd_user,
      hz_parties user_parties,
      hz_parties company_parties,
      hz_relationships,
      hz_code_assignments,
      pon_auction_headers_all auction
    where
      fnd_user.user_id = fnd_global.user_id()
      and fnd_user.person_party_id = user_parties.party_id
      and hz_relationships.object_id = company_parties.party_id
      and hz_relationships.subject_id = user_parties.party_id
      and hz_relationships.relationship_type = 'POS_EMPLOYMENT'
      and hz_relationships.relationship_code = 'EMPLOYEE_OF'
      and hz_relationships.start_date <= SYSDATE
      and hz_relationships.end_date >= SYSDATE
      and hz_code_assignments.owner_table_id = company_parties.party_id
      and hz_code_assignments.owner_table_name = 'HZ_PARTIES'
      and hz_code_assignments.class_category = 'POS_PARTICIPANT_TYPE'
      and hz_code_assignments.class_code = 'ENTERPRISE'
      and auction.auction_header_id = l_auction_header_id
      and auction.draft_locked = 'Y'
      and auction.draft_locked_by_contact_id = user_parties.party_id
      and auction.trading_partner_id = company_parties.party_id
      and auction.auction_status = 'DRAFT';
  EXCEPTION
    WHEN no_data_found THEN
      x_update_allowed := fnd_api.g_false;
      x_return_status := fnd_api.g_ret_sts_success;
      x_msg_data := 'pon_conterms_utl_grp.ok_to_commit() - user doesn''t have lock for draft: ' || l_auction_header_id;
      x_msg_count := 1;
      return;
  END;

  x_update_allowed := fnd_api.g_true;
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_data := 'Success!';
  x_msg_count := 1;
END ok_to_commit;

/*
 * Procedure:
 *  get_article_variable_values
 *
 * Purpose:
 *  This API will be called by Contracts to get values of system variables
 * used in Contract terms configurator rules.
 *
 * Parameters:
 * IN:
 *  p_api_version
 *   API version number expected by the caller
 *  p_init_msg_list
 *   Initialize message list
 *  p_doctype_id
 *   Contracts Doc Type; one of 'RFQ', 'RFQ_RESPONSE', etc
 *  p_doc_id
 *   pon_auction_headers_all.auction_header_id
 * IN OUT:
 *  p_sys_var_value_tbl
 *   A table of records to hold the system variable codes and values
 * OUT:
 *  x_msg_count
 *   message count
 *  x_msg_data
 *   message data
 *  x_return_status
 *   Status Returned to calling API. Possible values are following
 *   FND_API.G_RET_STS_ERROR - for expected error
 *   FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
 *   FND_API.G_RET_STS_SUCCESS - for success
 */
PROCEDURE get_article_variable_values(
		p_api_version            IN NUMBER,
		p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_doctype_id		 IN VARCHAR2,
		p_doc_id                 IN NUMBER,
		p_sys_var_value_tbl	 IN OUT NOCOPY OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type,
		x_return_status          OUT NOCOPY VARCHAR2,
		x_msg_data               OUT NOCOPY VARCHAR2,
		x_msg_count              OUT NOCOPY NUMBER
) IS
 l_api_name             VARCHAR2(60) := g_package_name || '.get_article_variable_values';
 l_api_version          NUMBER := 1.0;
 l_pon_sys_vars         OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type;
 l_sys_var_index        BINARY_INTEGER;
 l_pon_var_index        BINARY_INTEGER;
 l_progress             NUMBER := 0;
 l_dummy_value          VARCHAR2(10) := 'NOT_NULL';
BEGIN
  --  Initialize API return status to unexpected error
  x_return_status := fnd_api.g_ret_sts_unexp_error;
  x_msg_data := 'pon_conterms_utl_grp.get_article_variable_values() unexpected error';
  x_msg_count := 1;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := 50;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;

  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
    fnd_log.string(fnd_log.level_statement,
                   l_api_name,
		   'called ' || l_api_name);
  end if;

  -- bug 3264980
  -- if we're not passed and variables, then return immediately
  if (p_sys_var_value_tbl is null OR
      p_sys_var_value_tbl.count <= 0) then
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_data := null;
    x_msg_count := 0;
    return ;
  end if;

  -- determine which query to execute depending on the doctype
  if (p_doctype_id = PON_CONTERMS_UTL_PVT.BID or
      p_doctype_id = PON_CONTERMS_UTL_PVT.QUOTE or
      p_doctype_id = PON_CONTERMS_UTL_PVT.RESPONSE) then

    -- this is a response

    l_progress := 101;

    l_pon_sys_vars( 1).variable_code:= 'OKC$B_AGREEMENT_AMOUNT_FUNC';
    l_pon_sys_vars( 2).variable_code:= 'OKC$B_AGREEMENT_AMOUNT_TXN';
    l_pon_sys_vars( 3).variable_code:= 'OKC$B_AGREEMENT_END_DATE';
    l_pon_sys_vars( 4).variable_code:= 'OKC$B_AGREEMENT_START_DATE';
    l_pon_sys_vars( 5).variable_code:= 'OKC$B_AMENDMENT_DESCRIPTION';
    l_pon_sys_vars( 6).variable_code:= 'OKC$B_AUTO_EXTEND_ALLOWED_FLAG';
    l_pon_sys_vars( 7).variable_code:= 'OKC$B_BILL_TO_ADDRESS';
    l_pon_sys_vars( 8).variable_code:= 'OKC$B_BUYER';
    l_pon_sys_vars( 9).variable_code:= 'OKC$B_CARRIER';
    l_pon_sys_vars(10).variable_code:= 'OKC$B_CLOSE_RESPONSE_DATE';
    l_pon_sys_vars(11).variable_code:= 'OKC$B_CURRNCY_RESPONSE_FLAG';
    l_pon_sys_vars(12).variable_code:= 'OKC$B_DISPLAY_SCORING_CRITERIA';
    l_pon_sys_vars(13).variable_code:= 'OKC$B_DOCUMENT_TYPE';
    l_pon_sys_vars(14).variable_code:= 'OKC$B_ENTERPRISE_NAME';
    l_pon_sys_vars(15).variable_code:= 'OKC$B_FOB';
    l_pon_sys_vars(16).variable_code:= 'OKC$B_FREIGHT_TERMS';
    l_pon_sys_vars(17).variable_code:= 'OKC$B_FULL_QTY_RSPONS_FLAG';
    l_pon_sys_vars(18).variable_code:= 'OKC$B_INVITATION_ONLY_FLAG';
    l_pon_sys_vars(19).variable_code:= 'OKC$B_LEGAL_ENTITY';
    l_pon_sys_vars(20).variable_code:= 'OKC$B_MANU_CLOSE_ALLOWED_FLAG';
    l_pon_sys_vars(21).variable_code:= 'OKC$B_MANU_EXTEND_ALLOWED_FLAG';
    l_pon_sys_vars(22).variable_code:= 'OKC$B_MINIMUM_RELEASE_AMT_FUNC';
    l_pon_sys_vars(23).variable_code:= 'OKC$B_MINIMUM_RELEASE_AMT_TXN';
    l_pon_sys_vars(24).variable_code:= 'OKC$B_MUTI_ROUNDS_ALLOWED_FLAG';
    l_pon_sys_vars(25).variable_code:= 'OKC$B_MUTI_RSP_ALLOWED_FLAG';
    l_pon_sys_vars(26).variable_code:= 'OKC$B_OPEN_RESPONSE_DATE';
    l_pon_sys_vars(27).variable_code:= 'OKC$B_ORGANIZATION';
    l_pon_sys_vars(28).variable_code:= 'OKC$B_OUTCOME';
    l_pon_sys_vars(29).variable_code:= 'OKC$B_PAYMENT_TERMS';
    l_pon_sys_vars(30).variable_code:= 'OKC$B_PREVIEW_DATE';
    l_pon_sys_vars(31).variable_code:= 'OKC$B_RESPONSE_CURRENCY';
    l_pon_sys_vars(32).variable_code:= 'OKC$B_RESPONSE_NUMBER';
    l_pon_sys_vars(33).variable_code:= 'OKC$B_RESPONSE_RANKING';
    l_pon_sys_vars(34).variable_code:= 'OKC$B_RSPONS_PRICE_MUST_DEC';
    l_pon_sys_vars(35).variable_code:= 'OKC$B_SCHEDULED_AWARD_DATE';
    l_pon_sys_vars(36).variable_code:= 'OKC$B_SEE_OTHER_RESPONSE_FLAG';
    l_pon_sys_vars(37).variable_code:= 'OKC$B_SELECTIVE_RESPONSE_FLAG';
    l_pon_sys_vars(38).variable_code:= 'OKC$B_SHIP_TO_ADDRESS';
    l_pon_sys_vars(39).variable_code:= 'OKC$B_SOURCING_DOC_NUMBER';
    l_pon_sys_vars(40).variable_code:= 'OKC$B_STYLE';
    l_pon_sys_vars(41).variable_code:= 'OKC$B_SUPPLIER_CONTACT';
    l_pon_sys_vars(42).variable_code:= 'OKC$B_SUPPLIER_NAME';
    l_pon_sys_vars(43).variable_code:= 'OKC$B_TITLE';
    l_pon_sys_vars(44).variable_code:= 'OKC$B_TXN_CURRENCY';

    --------------------------------------------------------------------
    -- BUG 3250745 (3240942)
    --  Return dummy values for values not in PON tables.
    --  Otherwise, errors are generated in qa_doc()
    --------------------------------------------------------------------

    l_pon_sys_vars(45).variable_code:= 'OKC$B_BILL_TO_ADDR_STYLE';
    l_pon_sys_vars(45).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(46).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR';
    l_pon_sys_vars(46).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(47).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR_LINE_1';
    l_pon_sys_vars(47).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(48).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR_LINE_2';
    l_pon_sys_vars(48).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(49).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR_LINE_3';
    l_pon_sys_vars(49).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(50).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR_STYLE';
    l_pon_sys_vars(50).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(51).variable_code:= 'OKC$B_LEGAL_ENTITY_CITY';
    l_pon_sys_vars(51).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(52).variable_code:= 'OKC$B_LEGAL_ENTITY_COUNTRY';
    l_pon_sys_vars(52).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(53).variable_code:= 'OKC$B_LEGAL_ENTITY_REGION1';
    l_pon_sys_vars(53).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(54).variable_code:= 'OKC$B_LEGAL_ENTITY_REGION2';
    l_pon_sys_vars(54).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(55).variable_code:= 'OKC$B_LEGAL_ENTITY_REGION3';
    l_pon_sys_vars(55).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(56).variable_code:= 'OKC$B_LEGAL_ENTITY_ZIP';
    l_pon_sys_vars(56).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(57).variable_code:= 'OKC$B_ORGANIZATION_ADDR';
    l_pon_sys_vars(57).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(58).variable_code:= 'OKC$B_ORGANIZATION_ADDR_LINE_1';
    l_pon_sys_vars(58).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(59).variable_code:= 'OKC$B_ORGANIZATION_ADDR_LINE_2';
    l_pon_sys_vars(59).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(60).variable_code:= 'OKC$B_ORGANIZATION_ADDR_LINE_3';
    l_pon_sys_vars(60).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(61).variable_code:= 'OKC$B_ORGANIZATION_ADDR_STYLE';
    l_pon_sys_vars(61).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(62).variable_code:= 'OKC$B_ORGANIZATION_CITY';
    l_pon_sys_vars(62).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(63).variable_code:= 'OKC$B_ORGANIZATION_COUNTRY';
    l_pon_sys_vars(63).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(64).variable_code:= 'OKC$B_ORGANIZATION_REGION1';
    l_pon_sys_vars(64).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(65).variable_code:= 'OKC$B_ORGANIZATION_REGION2';
    l_pon_sys_vars(65).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(66).variable_code:= 'OKC$B_ORGANIZATION_REGION3';
    l_pon_sys_vars(66).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(67).variable_code:= 'OKC$B_ORGANIZATION_ZIP';
    l_pon_sys_vars(67).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(68).variable_code:= 'OKC$B_SHIP_TO_ADDR_STYLE';
    l_pon_sys_vars(68).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(69).variable_code:= 'OKC$B_SUPPLIER_CLASSIFICATION';
    l_pon_sys_vars(69).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(70).variable_code:= 'OKC$B_SUPPLIER_MINORITY_TYPE';
    l_pon_sys_vars(70).variable_value_id:= l_dummy_value;

    -- Bug 4102993
    l_pon_sys_vars(71).variable_code := 'OKC$B_FUNC_CURRENCY';

    -- ECO 4241852
    l_pon_sys_vars(72).variable_code := 'OKC$B_OUTCOME_PO_STYLE';

    begin
      select
        pah.org_id	organization,
        pon_conterms_utl_pvt.get_legal_entity_id(pah.org_id) entity,
	-- Bug 4099936
	-- Decode the doctype_id to the internal name as in PO valueset for the variable POC_XPRT_DOC_TYPE
	-- Note that this piece of code may not be used as of today since Contract expert is not used for
	-- response documents
        DECODE(pah.doctype_id, 21, 'SOURCING RFI', 5, 'SOURCING RFQ', 1, 'BUYER AUCTION') document_type,
        pah.document_number		document_number,
        pah.ship_to_location_id         ship_to_address,
        pah.bill_to_location_id         bill_to_address,
        pah.currency_code		currency,
        pah.trading_partner_contact_id  buyer,
        pah.trading_partner_name	enterprise_name,
        pah.po_agreed_amount * nvl(pah.rate, 1)
                                        agreement_amount1,
        pah.po_agreed_amount * nvl(pah.rate, 1)
                                        agreement_amount2,
        pah.payment_terms_id            payment_terms,
        pah.freight_terms_code          freight_terms,
        pah.carrier_code                carrier,
        pah.fob_code                    fob,
        pah.po_start_date               agreement_start_date,
        pah.po_end_date                 agreement_end_date,
        pah.po_min_rel_amount * nvl(pah.rate, 1)
			                minimum_release_amount1,
        pah.po_min_rel_amount * nvl(pah.rate, 1)
			                minimum_release_amount1,
        pah.contract_type               outcome,
        pah.auction_title	        title,
        pah.bid_visibility_code         style,
        pah.bid_ranking                 response_ranking,
        pah.hdr_attr_display_score          display_criteria,
        pah.open_bidding_date           open_response_date,
        pah.close_bidding_date          close_response_date,
        pah.view_by_date                preview_date,
        pah.award_by_date               award_date,
        pah.allow_other_bid_currency_flag
			                currency_response_flag,
        decode(pah.bid_list_type,'PRIVATE_BID_LIST','Y','N')
                                        invitation_only_flag,
        pah.show_bidder_notes           supplier_response_flag,
	-- Bug 4099936
	-- decode control settings to Y/N to match the valueset
        DECODE(pah.bid_scope_code, 'MUST_BID_ALL_ITEMS', 'N', 'Y')
	                                selective_response_flag,
        decode(pah.full_quantity_bid_code,'FULL_QTY_BIDS_REQD','Y','N')
			                full_quantity_response_flag,
        decode(pah.bid_frequency_code,'MULTIPLE_BIDS_ALLOWED','Y','N')
			                multiple_responses_flag,
        pah.multiple_rounds_flag	multiple_rounds_flag,
        pah.manual_close_flag		manual_close_flag,
        pah.manual_extend_flag          manual_extend_flag,
        pah.auto_extend_flag		auto_extend_flag,
        pah.price_driven_auction_flag   prices_decrease_flag,
        pah.amendment_description	amendment_description,
        pbh.trading_partner_name        supplier_name,
        pbh.trading_partner_contact_id  supplier_contact,
        pbh.bid_number                  response_number,
        pbh.bid_currency_code           response_currency,
	pah.currency_code               func_currency,
        -- ECO 4241852 -- BUG 5087598
        pah.po_style_id  || '-' || pah.contract_type style_id
      into
        l_pon_sys_vars(27).variable_value_id,
        l_pon_sys_vars(19).variable_value_id,
        l_pon_sys_vars(13).variable_value_id,
        l_pon_sys_vars(39).variable_value_id,
        l_pon_sys_vars(38).variable_value_id,
        l_pon_sys_vars( 7).variable_value_id,
        l_pon_sys_vars(44).variable_value_id,
        l_pon_sys_vars( 8).variable_value_id,
        l_pon_sys_vars(14).variable_value_id,
        l_pon_sys_vars( 1).variable_value_id,
        l_pon_sys_vars( 2).variable_value_id,
        l_pon_sys_vars(29).variable_value_id,
        l_pon_sys_vars(16).variable_value_id,
        l_pon_sys_vars( 9).variable_value_id,
        l_pon_sys_vars(15).variable_value_id,
        l_pon_sys_vars( 4).variable_value_id,
        l_pon_sys_vars( 3).variable_value_id,
        l_pon_sys_vars(22).variable_value_id,
        l_pon_sys_vars(23).variable_value_id,
        l_pon_sys_vars(28).variable_value_id,
        l_pon_sys_vars(43).variable_value_id,
        l_pon_sys_vars(40).variable_value_id,
        l_pon_sys_vars(33).variable_value_id,
        l_pon_sys_vars(12).variable_value_id,
        l_pon_sys_vars(26).variable_value_id,
        l_pon_sys_vars(10).variable_value_id,
        l_pon_sys_vars(30).variable_value_id,
        l_pon_sys_vars(35).variable_value_id,
        l_pon_sys_vars(11).variable_value_id,
        l_pon_sys_vars(18).variable_value_id,
        l_pon_sys_vars(36).variable_value_id,
        l_pon_sys_vars(37).variable_value_id,
        l_pon_sys_vars(17).variable_value_id,
        l_pon_sys_vars(25).variable_value_id,
        l_pon_sys_vars(24).variable_value_id,
        l_pon_sys_vars(20).variable_value_id,
        l_pon_sys_vars(21).variable_value_id,
        l_pon_sys_vars( 6).variable_value_id,
        l_pon_sys_vars(34).variable_value_id,
        l_pon_sys_vars( 5).variable_value_id,
        l_pon_sys_vars(42).variable_value_id,
        l_pon_sys_vars(41).variable_value_id,
        l_pon_sys_vars(32).variable_value_id,
        l_pon_sys_vars(31).variable_value_id,
	    l_pon_sys_vars(71).variable_value_id,
        -- ECO 4241852
	    l_pon_sys_vars(72).variable_value_id
      from
        pon_auction_headers_all pah,
        pon_bid_headers pbh,
	hr_all_organization_units ou
      where
        pbh.bid_number = p_doc_id and
        pbh.auction_header_id = pah.auction_header_id and
        pah.org_id = ou.organization_id(+) and
        nvl(ou.date_from(+),sysdate-1) < sysdate and
        nvl(ou.date_to(+),sysdate+1) > sysdate ;
    exception
      when no_data_found then
        if (fnd_log.level_exception >= fnd_log.g_current_runtime_level) then
          fnd_log.string(fnd_log.level_exception,
                         l_api_name,
                         'no data found for ' || p_doc_id);
        end if;

        x_msg_data := 'no data found for ' || p_doc_id;
        x_return_status := fnd_api.g_ret_sts_error;
        return;
    end;
  elsif (p_doctype_id = PON_CONTERMS_UTL_PVT.AUCTION or
         p_doctype_id = PON_CONTERMS_UTL_PVT.REQUEST_FOR_QUOTE or
         p_doctype_id = PON_CONTERMS_UTL_PVT.REQUEST_FOR_INFORMATION) then

    -- this is an auction

    l_progress := 102;

    l_pon_sys_vars( 1).variable_code:= 'OKC$B_AGREEMENT_AMOUNT_FUNC';
    l_pon_sys_vars( 2).variable_code:= 'OKC$B_AGREEMENT_AMOUNT_TXN';
    l_pon_sys_vars( 3).variable_code:= 'OKC$B_AGREEMENT_END_DATE';
    l_pon_sys_vars( 4).variable_code:= 'OKC$B_AGREEMENT_START_DATE';
    l_pon_sys_vars( 5).variable_code:= 'OKC$B_AMENDMENT_DESCRIPTION';
    l_pon_sys_vars( 6).variable_code:= 'OKC$B_AUTO_EXTEND_ALLOWED_FLAG';
    l_pon_sys_vars( 7).variable_code:= 'OKC$B_BILL_TO_ADDRESS';
    l_pon_sys_vars( 8).variable_code:= 'OKC$B_BUYER';
    l_pon_sys_vars( 9).variable_code:= 'OKC$B_CARRIER';
    l_pon_sys_vars(10).variable_code:= 'OKC$B_CLOSE_RESPONSE_DATE';
    l_pon_sys_vars(11).variable_code:= 'OKC$B_CURRNCY_RESPONSE_FLAG';
    l_pon_sys_vars(12).variable_code:= 'OKC$B_DISPLAY_SCORING_CRITERIA';
    l_pon_sys_vars(13).variable_code:= 'OKC$B_DOCUMENT_TYPE';
    l_pon_sys_vars(14).variable_code:= 'OKC$B_ENTERPRISE_NAME';
    l_pon_sys_vars(15).variable_code:= 'OKC$B_FOB';
    l_pon_sys_vars(16).variable_code:= 'OKC$B_FREIGHT_TERMS';
    l_pon_sys_vars(17).variable_code:= 'OKC$B_FULL_QTY_RSPONS_FLAG';
    l_pon_sys_vars(18).variable_code:= 'OKC$B_GLOBAL_FLAG';
    l_pon_sys_vars(19).variable_code:= 'OKC$B_INVITATION_ONLY_FLAG';
    l_pon_sys_vars(20).variable_code:= 'OKC$B_LEGAL_ENTITY';
    l_pon_sys_vars(21).variable_code:= 'OKC$B_MANU_CLOSE_ALLOWED_FLAG';
    l_pon_sys_vars(22).variable_code:= 'OKC$B_MANU_EXTEND_ALLOWED_FLAG';
    l_pon_sys_vars(23).variable_code:= 'OKC$B_MINIMUM_RELEASE_AMT_FUNC';
    l_pon_sys_vars(24).variable_code:= 'OKC$B_MINIMUM_RELEASE_AMT_TXN';
    l_pon_sys_vars(25).variable_code:= 'OKC$B_MUTI_ROUNDS_ALLOWED_FLAG';
    l_pon_sys_vars(26).variable_code:= 'OKC$B_MUTI_RSP_ALLOWED_FLAG';
    l_pon_sys_vars(27).variable_code:= 'OKC$B_OPEN_RESPONSE_DATE';
    l_pon_sys_vars(28).variable_code:= 'OKC$B_ORGANIZATION';
    l_pon_sys_vars(29).variable_code:= 'OKC$B_OUTCOME';
    l_pon_sys_vars(30).variable_code:= 'OKC$B_PAYMENT_TERMS';
    l_pon_sys_vars(31).variable_code:= 'OKC$B_PREVIEW_DATE';
    l_pon_sys_vars(32).variable_code:= 'OKC$B_RESPONSE_RANKING';
    l_pon_sys_vars(33).variable_code:= 'OKC$B_RSPONS_PRICE_MUST_DEC';
    l_pon_sys_vars(34).variable_code:= 'OKC$B_SCHEDULED_AWARD_DATE';
    l_pon_sys_vars(35).variable_code:= 'OKC$B_SEE_OTHER_RESPONSE_FLAG';
    l_pon_sys_vars(36).variable_code:= 'OKC$B_SELECTIVE_RESPONSE_FLAG';
    l_pon_sys_vars(37).variable_code:= 'OKC$B_SHIP_TO_ADDRESS';
    l_pon_sys_vars(38).variable_code:= 'OKC$B_SOURCING_DOC_NUMBER';
    l_pon_sys_vars(39).variable_code:= 'OKC$B_STYLE';
    l_pon_sys_vars(40).variable_code:= 'OKC$B_TITLE';
    l_pon_sys_vars(41).variable_code:= 'OKC$B_TXN_CURRENCY';

    --------------------------------------------------------------------
    -- BUG 3250745 (3240942)
    --  Return dummy values for values not in PON tables.
    --  Otherwise, errors are generated in qa_doc()
    --------------------------------------------------------------------

    l_pon_sys_vars(42).variable_code:= 'OKC$B_RESPONSE_CURRENCY';
    l_pon_sys_vars(42).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(43).variable_code:= 'OKC$B_RESPONSE_NUMBER';
    l_pon_sys_vars(43).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(44).variable_code:= 'OKC$B_SUPPLIER_CONTACT';
    l_pon_sys_vars(44).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(45).variable_code:= 'OKC$B_SUPPLIER_NAME';
    l_pon_sys_vars(45).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(46).variable_code:= 'OKC$B_BILL_TO_ADDR_STYLE';
    l_pon_sys_vars(46).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(47).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR';
    l_pon_sys_vars(47).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(48).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR_LINE_1';
    l_pon_sys_vars(48).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(49).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR_LINE_2';
    l_pon_sys_vars(49).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(50).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR_LINE_3';
    l_pon_sys_vars(50).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(51).variable_code:= 'OKC$B_LEGAL_ENTITY_ADDR_STYLE';
    l_pon_sys_vars(51).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(52).variable_code:= 'OKC$B_LEGAL_ENTITY_CITY';
    l_pon_sys_vars(52).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(53).variable_code:= 'OKC$B_LEGAL_ENTITY_COUNTRY';
    l_pon_sys_vars(53).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(54).variable_code:= 'OKC$B_LEGAL_ENTITY_REGION1';
    l_pon_sys_vars(54).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(55).variable_code:= 'OKC$B_LEGAL_ENTITY_REGION2';
    l_pon_sys_vars(55).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(56).variable_code:= 'OKC$B_LEGAL_ENTITY_REGION3';
    l_pon_sys_vars(56).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(57).variable_code:= 'OKC$B_LEGAL_ENTITY_ZIP';
    l_pon_sys_vars(57).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(58).variable_code:= 'OKC$B_ORGANIZATION_ADDR';
    l_pon_sys_vars(58).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(59).variable_code:= 'OKC$B_ORGANIZATION_ADDR_LINE_1';
    l_pon_sys_vars(59).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(60).variable_code:= 'OKC$B_ORGANIZATION_ADDR_LINE_2';
    l_pon_sys_vars(60).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(61).variable_code:= 'OKC$B_ORGANIZATION_ADDR_LINE_3';
    l_pon_sys_vars(61).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(62).variable_code:= 'OKC$B_ORGANIZATION_ADDR_STYLE';
    l_pon_sys_vars(62).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(63).variable_code:= 'OKC$B_ORGANIZATION_CITY';
    l_pon_sys_vars(63).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(64).variable_code:= 'OKC$B_ORGANIZATION_COUNTRY';
    l_pon_sys_vars(64).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(65).variable_code:= 'OKC$B_ORGANIZATION_REGION1';
    l_pon_sys_vars(65).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(66).variable_code:= 'OKC$B_ORGANIZATION_REGION2';
    l_pon_sys_vars(66).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(67).variable_code:= 'OKC$B_ORGANIZATION_REGION3';
    l_pon_sys_vars(67).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(68).variable_code:= 'OKC$B_ORGANIZATION_ZIP';
    l_pon_sys_vars(68).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(69).variable_code:= 'OKC$B_SHIP_TO_ADDR_STYLE';
    l_pon_sys_vars(69).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(70).variable_code:= 'OKC$B_SUPPLIER_CLASSIFICATION';
    l_pon_sys_vars(70).variable_value_id:= l_dummy_value;
    l_pon_sys_vars(71).variable_code:= 'OKC$B_SUPPLIER_MINORITY_TYPE';
    l_pon_sys_vars(71).variable_value_id:= l_dummy_value;

    -- Bug 4102993
    -- add the missing functional currency variable
    l_pon_sys_vars(72).variable_code := 'OKC$B_FUNC_CURRENCY';

    -- ECO 4241852
    l_pon_sys_vars(73).variable_code := 'OKC$B_OUTCOME_PO_STYLE';

    begin
      select
        pah.org_id			organization,
        pon_conterms_utl_pvt.get_legal_entity_id(pah.org_id) entity,
	-- Bug 4099936
	-- decode doctype_id to the document type code as per the po value set POC_XPRT_DOC_TYPE associated
	-- with the doc type system variable.
        DECODE(pah.doctype_id, 21, 'SOURCING RFI', 5, 'SOURCING RFQ', 1, 'BUYER AUCTION') document_type,
        pah.document_number		document_number,
        pah.ship_to_location_id         ship_to_address,
        pah.bill_to_location_id         bill_to_address,
        pah.currency_code		currency,
        pah.trading_partner_contact_id  buyer,
        pah.trading_partner_name	enterprise_name,
        pah.po_agreed_amount * nvl(pah.rate, 1)
                                        agreement_amount1,
        pah.po_agreed_amount * nvl(pah.rate, 1)
                                        agreement_amount2,
        pah.global_agreement_flag	global_flag,
        pah.payment_terms_id            payment_terms,
        pah.freight_terms_code          freight_terms,
        pah.carrier_code                carrier,
        pah.fob_code                    fob,
        pah.po_start_date               agreement_start_date,
        pah.po_end_date                 agreement_end_date,
        pah.po_min_rel_amount * nvl(pah.rate, 1)
			                minimum_release_amount1,
        pah.po_min_rel_amount * nvl(pah.rate, 1)
			                minimum_release_amount1,
        pah.contract_type               outcome,
        pah.auction_title	        title,
        pah.bid_visibility_code         style,
        pah.bid_ranking                 response_ranking,
        pah.hdr_attr_display_score          display_criteria,
        pah.open_bidding_date           open_response_date,
        pah.close_bidding_date          close_response_date,
        pah.view_by_date                preview_date,
        pah.award_by_date               award_date,
        pah.allow_other_bid_currency_flag
			                currency_response_flag,
        decode(pah.bid_list_type,'PRIVATE_BID_LIST','Y','N')
                                        invitation_only_flag,
        pah.show_bidder_notes           supplier_response_flag,
	-- Bug 4099936
	-- decode control setting to Y/N as expected by the Contract Expert value set for the sys variable
        DECODE(pah.bid_scope_code, 'MUST_BID_ALL_ITEMS', 'N', 'Y')
	                                selective_response_flag,
        decode(pah.full_quantity_bid_code,'FULL_QTY_BIDS_REQD','Y','N')
			                full_quantity_response_flag,
        decode(pah.bid_frequency_code,'MULTIPLE_BIDS_ALLOWED','Y','N')
			                multiple_responses_flag,
        pah.multiple_rounds_flag	multiple_rounds_flag,
        pah.manual_close_flag		manual_close_flag,
        pah.manual_extend_flag          manual_extend_flag,
        pah.auto_extend_flag		auto_extend_flag,
        pah.price_driven_auction_flag   prices_decrease_flag,
        pah.amendment_description	amendment_description,
	-- Bug 4102993 --> add missing functional currency variable
	pah.currency_code               func_currency,
        -- ECO 4241852 -- BUG 5087598
        pah.po_style_id || '-' || pah.contract_type style_id
      into
        l_pon_sys_vars(28).variable_value_id,
        l_pon_sys_vars(20).variable_value_id,
        l_pon_sys_vars(13).variable_value_id,
        l_pon_sys_vars(38).variable_value_id,
        l_pon_sys_vars(37).variable_value_id,
        l_pon_sys_vars( 7).variable_value_id,
        l_pon_sys_vars(41).variable_value_id,
        l_pon_sys_vars( 8).variable_value_id,
        l_pon_sys_vars(14).variable_value_id,
        l_pon_sys_vars( 1).variable_value_id,
        l_pon_sys_vars( 2).variable_value_id,
        l_pon_sys_vars(18).variable_value_id,
        l_pon_sys_vars(30).variable_value_id,
        l_pon_sys_vars(16).variable_value_id,
        l_pon_sys_vars( 9).variable_value_id,
        l_pon_sys_vars(15).variable_value_id,
        l_pon_sys_vars( 4).variable_value_id,
        l_pon_sys_vars( 3).variable_value_id,
        l_pon_sys_vars(23).variable_value_id,
        l_pon_sys_vars(24).variable_value_id,
        l_pon_sys_vars(29).variable_value_id,
        l_pon_sys_vars(40).variable_value_id,
        l_pon_sys_vars(39).variable_value_id,
        l_pon_sys_vars(32).variable_value_id,
        l_pon_sys_vars(12).variable_value_id,
        l_pon_sys_vars(27).variable_value_id,
        l_pon_sys_vars(10).variable_value_id,
        l_pon_sys_vars(31).variable_value_id,
        l_pon_sys_vars(34).variable_value_id,
        l_pon_sys_vars(11).variable_value_id,
        l_pon_sys_vars(19).variable_value_id,
        l_pon_sys_vars(35).variable_value_id,
        l_pon_sys_vars(36).variable_value_id,
        l_pon_sys_vars(17).variable_value_id,
        l_pon_sys_vars(26).variable_value_id,
        l_pon_sys_vars(25).variable_value_id,
        l_pon_sys_vars(21).variable_value_id,
        l_pon_sys_vars(22).variable_value_id,
        l_pon_sys_vars( 6).variable_value_id,
        l_pon_sys_vars(33).variable_value_id,
        l_pon_sys_vars( 5).variable_value_id,
	    -- Bug 4102993
	    -- add the missing variable value.
	    l_pon_sys_vars(72).variable_value_id,
        -- ECO 4241852
	    l_pon_sys_vars(73).variable_value_id
      from
        pon_auction_headers_all pah,
        hr_all_organization_units ou
      where
        pah.auction_header_id = p_doc_id and
        pah.org_id = ou.organization_id(+) and
        nvl(ou.date_from(+),sysdate-1) < sysdate and
        nvl(ou.date_to(+),sysdate+1) > sysdate ;
    exception
      when no_data_found then
        if (fnd_log.level_exception >= fnd_log.g_current_runtime_level) then
          fnd_log.string(fnd_log.level_exception,
                         l_api_name,
                         'no data found for ' || p_doc_id);
        end if;

        x_msg_data := 'no data found for ' || p_doc_id;
        x_return_status := fnd_api.g_ret_sts_error;
        return;
    end ;
  else
    if (fnd_log.level_exception >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_exception,
                     l_api_name,
		     'unknown doctype ' || p_doctype_id);
    end if;

    x_return_status := fnd_api.g_ret_sts_error;
    x_msg_data := l_api_name || ' unknown doctype ' || p_doctype_id;
    x_msg_count := 1;
    return;
  end if;

  l_progress := 200;

  -- copy values from l_pon_sys_vars to p_sys_var_value_tbl
  -- l_sys_var_index        BINARY_INTEGER;
  -- l_pon_var_index        BINARY_INTEGER;
  for l_sys_var_index in p_sys_var_value_tbl.first..p_sys_var_value_tbl.last loop

    -- assume that we do not find the variable, set it to l_dummy_value
    p_sys_var_value_tbl(l_sys_var_index).variable_value_id := l_dummy_value;

    l_progress := 220;

    if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_statement,
                     l_api_name,
		     'searching for ' || p_sys_var_value_tbl(l_sys_var_index).variable_code);
    end if;

    -- find sys_var(sys_var_index).variable_code in pon_var
    for l_pon_var_index in l_pon_sys_vars.first..l_pon_sys_vars.last loop

      l_progress := 240;

      if (p_sys_var_value_tbl(l_sys_var_index).variable_code =
          l_pon_sys_vars(l_pon_var_index).variable_code) then

        l_progress := 260;

        if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
          fnd_log.string(fnd_log.level_statement,
                         l_api_name,
		         'found ' || p_sys_var_value_tbl(l_sys_var_index).variable_code || ' at l_pon_var_index=' || l_pon_var_index || ' value=' || l_pon_sys_vars(l_pon_var_index).variable_value_id);
        end if;

        -- copy the value to p_sys_var_value_tbl
        p_sys_var_value_tbl(l_sys_var_index).variable_value_id :=
          l_pon_sys_vars(l_pon_var_index).variable_value_id;
        -- break out of loop
        exit;
      end if;
    end loop;
  end loop;

  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_data := null;
  x_msg_count := 0;

EXCEPTION when others then
  if (fnd_log.level_exception >= fnd_log.g_current_runtime_level) then
    fnd_log.string(fnd_log.level_exception,
                   l_api_name,
                   'unknown exception for ' || p_doc_id || ' - progress=' || l_progress);
  end if;

  FND_MSG_PUB.add_exc_msg(
    p_pkg_name        => g_package_name,
    p_procedure_name  => l_api_name || '.' || l_progress
  );
  FND_MSG_PUB.count_and_get(
    p_encoded => 'F',
    p_count   => x_msg_count,
    p_data    => x_msg_data
  );
END get_article_variable_values;

/*
 * Procedure:
 *  get_changed_variables
 *
 * Purpose:
 *  This API will be called by Contracts to determine whether values of
 * system variables changed between the latest revision and the previous.
 *
 * Parameters:
 * IN:
 *  p_api_version
 *   API version number expected by the caller
 *  p_init_msg_list
 *   Initialize message list
 *  p_doctype_id
 *   Contracts Doc Type; one of 'RFQ', 'RFQ_RESPONSE', etc
 *  p_doc_id
 *   pon_auction_headers_all.auction_header_id
 * IN OUT:
 *  p_sys_var_tbl
 *   A table of records to hold the system variable codes which changed
 *  between the two revisions.  Contracts will pass a list of all variables
 *  being used in Contract terms for this document.  This procedure will
 *  filter that list and return only those which changed.
 * OUT:
 *  x_msg_count
 *   message count
 *  x_msg_data
 *   message data
 *  x_return_status
 *   Status Returned to calling API. Possible values are following
 *   FND_API.G_RET_STS_ERROR - for expected error
 *   FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
 *   FND_API.G_RET_STS_SUCCESS - for success
 */
PROCEDURE get_changed_variables(
		p_api_version            IN NUMBER,
		p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_doctype_id		 IN VARCHAR2,
		p_doc_id                 IN NUMBER,
		p_sys_var_tbl	 	 IN OUT NOCOPY OKC_TERMS_UTIL_GRP.variable_code_tbl_type,
		x_return_status          OUT NOCOPY VARCHAR2,
		x_msg_data               OUT NOCOPY VARCHAR2,
		x_msg_count              OUT NOCOPY NUMBER
) IS
 l_api_name             VARCHAR2(60) := g_package_name || '.get_changed_variables';
 l_api_version          NUMBER := 1.0;
 l_prev_header_id       pon_auction_headers_all.auction_header_id%type;
 l_prev_round_id        pon_auction_headers_all.auction_header_id%type;
 l_prev_amend_id        pon_auction_headers_all.auction_header_id%type;
 l_pon_sys_vars         OKC_TERMS_UTIL_GRP.variable_code_tbl_type;
 l_sys_var_index        BINARY_INTEGER;
 l_pon_var_index        BINARY_INTEGER;
 l_progress             NUMBER := 0;
 l_found                BOOLEAN;
BEGIN
  --  Initialize API return status to unexpected error
  x_return_status := fnd_api.g_ret_sts_unexp_error;
  x_msg_data := l_api_name || ' unexpected error';
  x_msg_count := 1;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := 50;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;

  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
    fnd_log.string(fnd_log.level_statement,
                   l_api_name,
		   'called ' || l_api_name);
  end if;

  -- bug 3264980
  -- if we're not passed and variables, then return immediately
  if (p_sys_var_tbl is null OR
      p_sys_var_tbl.count <= 0) then
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_data := null;
    x_msg_count := 0;
    return ;
  end if;

  -- determine which query to execute depending on the doctype
  if (p_doctype_id = PON_CONTERMS_UTL_PVT.BID or
      p_doctype_id = PON_CONTERMS_UTL_PVT.QUOTE or
      p_doctype_id = PON_CONTERMS_UTL_PVT.RESPONSE) then

    l_progress := 101;

    if (fnd_log.level_exception >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_exception,
                     l_api_name,
	             'unexpected call for changes to ' || p_doctype_id || ' ' || p_doc_id);
    end if;

    -- this is a response
    -- since we do not call qa_doc() for responses, we should not have
    -- to implement anything here ... use the nothing changed case and
    -- return error

    for l_sys_var_index in p_sys_var_tbl.first..p_sys_var_tbl.last loop
      p_sys_var_tbl.delete(l_sys_var_index);
    end loop;

    x_return_status := fnd_api.g_ret_sts_error;
    x_msg_data := l_api_name || ' did not expect call with doctype ' || p_doctype_id;
    return;
  elsif (p_doctype_id = PON_CONTERMS_UTL_PVT.AUCTION or
         p_doctype_id = PON_CONTERMS_UTL_PVT.REQUEST_FOR_QUOTE or
         p_doctype_id = PON_CONTERMS_UTL_PVT.REQUEST_FOR_INFORMATION) then

    l_progress := 102;

    -- this is an auction
    -- find the previous auction_header_id (amendment or round?)
    begin
      select
        auction_header_id_prev_round,
        auction_header_id_prev_amend
      into
        l_prev_round_id,
        l_prev_amend_id
      from
        pon_auction_headers_all
      where
        auction_header_id = p_doc_id;
    exception
      when no_data_found then
        if (fnd_log.level_exception >= fnd_log.g_current_runtime_level) then
          fnd_log.string(fnd_log.level_exception,
                         l_api_name,
                         'no data found for ' || p_doc_id);
        end if;

        x_msg_data := 'no data found for ' || p_doc_id;
        x_return_status := fnd_api.g_ret_sts_error;
        return;
    end ;

    l_progress := 132;

    -- determine previous auction_header_id
    if (l_prev_amend_id is not NULL) then
      l_prev_header_id := l_prev_amend_id;
    elsif (l_prev_round_id is not NULL) then
      l_prev_header_id := l_prev_round_id;
    else
      -- no previous revision... so there can be no changes
      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_statement,
                       l_api_name,
	               'no changes possible for document without revision');
      end if;

      -- clear variable list and return
      for l_sys_var_index in p_sys_var_tbl.first..p_sys_var_tbl.last loop
        p_sys_var_tbl.delete(l_sys_var_index);
      end loop;

      x_return_status := fnd_api.g_ret_sts_success;
      x_msg_data := null;
      x_msg_count := 0;
      return ;
    end if;

    l_progress := 162;

    -- select either 'N' or the System Variable code if a value has changed
    select
      decode(pah1.org_id,pah2.org_id,'N','OKC$B_ORGANIZATION'),
      decode(pon_conterms_utl_pvt.get_legal_entity_id(pah1.org_id),
             pon_conterms_utl_pvt.get_legal_entity_id(pah2.org_id),
             'N','OKC$B_LEGAL_ENTITY'),
      decode(pah1.doctype_id,pah2.doctype_id,'N','OKC$B_DOCUMENT_TYPE'),
      decode(pah1.document_number,pah2.document_number,'N','OKC$B_SOURCING_DOC_NUMBER'),
      decode(pah1.ship_to_location_id,pah2.ship_to_location_id,'N','OKC$B_SHIP_TO_ADDRESS'),
      decode(pah1.bill_to_location_id,pah2.bill_to_location_id,'N','OKC$B_BILL_TO_ADDRESS'),
      decode(pah1.currency_code,pah2.currency_code,'N','OKC$B_TXN_CURRENCY'),
      decode(pah1.trading_partner_contact_id,pah2.trading_partner_contact_id,'N','OKC$B_BUYER'),
      decode(pah1.trading_partner_name,pah2.trading_partner_name,'N','OKC$B_ENTERPRISE_NAME'),
      decode(pah1.po_agreed_amount*nvl(pah1.rate,1),pah2.po_agreed_amount*nvl(pah2.rate,1),'N','OKC$B_AGREEMENT_AMOUNT_FUNC'),
      decode(pah1.po_agreed_amount*nvl(pah1.rate,1),pah2.po_agreed_amount*nvl(pah2.rate,1),'N','OKC$B_AGREEMENT_AMOUNT_TXN'),
      decode(pah1.global_agreement_flag,pah2.global_agreement_flag,'N','OKC$B_GLOBAL_FLAG'),
      decode(pah1.payment_terms_id,pah2.payment_terms_id,'N','OKC$B_PAYMENT_TERMS'),
      decode(pah1.freight_terms_code,pah2.freight_terms_code,'N','OKC$B_FREIGHT_TERMS'),
      decode(pah1.carrier_code,pah2.carrier_code,'N','OKC$B_CARRIER'),
      decode(pah1.fob_code,pah2.fob_code,'N','OKC$B_FOB'),
      decode(pah1.po_start_date,pah2.po_start_date,'N','OKC$B_AGREEMENT_START_DATE'),
      decode(pah1.po_end_date,pah2.po_end_date,'N','OKC$B_AGREEMENT_END_DATE'),
      decode(pah1.po_min_rel_amount*nvl(pah1.rate,1),pah2.po_min_rel_amount*nvl(pah2.rate,1),'N','OKC$B_MINIMUM_RELEASE_AMT_FUNC'),
      decode(pah1.po_min_rel_amount*nvl(pah1.rate,1),pah2.po_min_rel_amount*nvl(pah2.rate,1),'N','OKC$B_MINIMUM_RELEASE_AMT_TXN'),
      decode(pah1.contract_type,pah2.contract_type,'N','OKC$B_OUTCOME'),
      decode(pah1.auction_title,pah2.auction_title,'N','OKC$B_TITLE'),
      decode(pah1.bid_visibility_code,pah2.bid_visibility_code,'N','OKC$B_STYLE'),
      decode(pah1.bid_ranking,pah2.bid_ranking,'N','OKC$B_RESPONSE_RANKING'),
      decode(pah1.hdr_attr_display_score,pah2.hdr_attr_display_score,'N','OKC$B_DISPLAY_SCORING_CRITERIA'),
      decode(pah1.open_bidding_date,pah2.open_bidding_date,'N','OKC$B_OPEN_RESPONSE_DATE'),
      decode(pah1.close_bidding_date,pah2.close_bidding_date,'N','OKC$B_CLOSE_RESPONSE_DATE'),
      decode(pah1.view_by_date,pah2.view_by_date,'N','OKC$B_PREVIEW_DATE'),
      decode(pah1.award_by_date,pah2.award_by_date,'N','OKC$B_SCHEDULED_AWARD_DATE'),
      decode(pah1.allow_other_bid_currency_flag,pah2.allow_other_bid_currency_flag,'N','OKC$B_CURRNCY_RESPONSE_FLAG'),
      decode(pah1.bid_list_type,pah2.bid_list_type,'N','OKC$B_INVITATION_ONLY_FLAG'),
      decode(pah1.show_bidder_notes, pah2.show_bidder_notes,'N','OKC$B_SEE_OTHER_RESPONSE_FLAG'),
      decode(pah1.bid_scope_code, pah2.bid_scope_code,'N','OKC$B_SELECTIVE_RESPONSE_FLAG'),
      decode(pah1.full_quantity_bid_code,pah2.full_quantity_bid_code,'N','OKC$B_FULL_QTY_RSPONS_FLAG'),
      decode(pah1.bid_frequency_code,pah2.bid_frequency_code,'N','OKC$B_MUTI_RSP_ALLOWED_FLAG'),
      decode(pah1.multiple_rounds_flag,pah2.multiple_rounds_flag,'N','OKC$B_MUTI_ROUNDS_ALLOWED_FLAG'),
      decode(pah1.manual_close_flag,pah2.manual_close_flag,'N','OKC$B_MANU_CLOSE_ALLOWED_FLAG'),
      decode(pah1.manual_extend_flag,pah2.manual_extend_flag,'N','OKC$B_MANU_EXTEND_ALLOWED_FLAG'),
      decode(pah1.auto_extend_flag,pah2.auto_extend_flag,'N','OKC$B_AUTO_EXTEND_ALLOWED_FLAG'),
      decode(pah1.price_driven_auction_flag,pah2.price_driven_auction_flag,'N','OKC$B_RSPONS_PRICE_MUST_DEC'),
      decode(pah1.amendment_description,pah2.amendment_description,'N','OKC$B_AMENDMENT_DESCRIPTION'),
      decode(pah1.currency_code, pah2.currency_code, 'N', 'OKC$B_FUNC_CURRENCY'),
      -- ECO 4241852 -- BUG 5087598 --> no changes here
      decode(pah1.po_style_id,pah2.po_style_id,'N','OKC$B_OUTCOME_PO_STYLE')
    into
      l_pon_sys_vars( 1),
      l_pon_sys_vars( 2),
      l_pon_sys_vars( 3),
      l_pon_sys_vars( 4),
      l_pon_sys_vars( 5),
      l_pon_sys_vars( 6),
      l_pon_sys_vars( 7),
      l_pon_sys_vars( 8),
      l_pon_sys_vars( 9),
      l_pon_sys_vars(10),
      l_pon_sys_vars(11),
      l_pon_sys_vars(12),
      l_pon_sys_vars(13),
      l_pon_sys_vars(14),
      l_pon_sys_vars(15),
      l_pon_sys_vars(16),
      l_pon_sys_vars(17),
      l_pon_sys_vars(18),
      l_pon_sys_vars(19),
      l_pon_sys_vars(20),
      l_pon_sys_vars(21),
      l_pon_sys_vars(22),
      l_pon_sys_vars(23),
      l_pon_sys_vars(24),
      l_pon_sys_vars(25),
      l_pon_sys_vars(26),
      l_pon_sys_vars(27),
      l_pon_sys_vars(28),
      l_pon_sys_vars(29),
      l_pon_sys_vars(30),
      l_pon_sys_vars(31),
      l_pon_sys_vars(32),
      l_pon_sys_vars(33),
      l_pon_sys_vars(34),
      l_pon_sys_vars(35),
      l_pon_sys_vars(36),
      l_pon_sys_vars(37),
      l_pon_sys_vars(38),
      l_pon_sys_vars(39),
      l_pon_sys_vars(40),
      l_pon_sys_vars(41),
      l_pon_sys_vars(42),
      -- ECO 4241852
      l_pon_sys_vars(43)
    from
      pon_auction_headers_all pah1,
      pon_auction_headers_all pah2,
      hr_all_organization_units ou1,
      hr_all_organization_units ou2
    where
      pah1.auction_header_id = p_doc_id and
      pah1.org_id = ou1.organization_id(+) and
      nvl(ou1.date_from(+),sysdate-1) < sysdate and
      nvl(ou1.date_to(+),sysdate+1) > sysdate and
      pah2.auction_header_id = l_prev_header_id and
      pah2.org_id = ou2.organization_id(+) and
      nvl(ou2.date_from(+),sysdate-1) < sysdate and
      nvl(ou2.date_to(+),sysdate+1) > sysdate ;
  else
    -- this is an unknown doctype

    if (fnd_log.level_exception >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_exception,
                     l_api_name,
		     'unknown doctype ' || p_doctype_id);
    end if;

    x_return_status := fnd_api.g_ret_sts_error;
    x_msg_data := l_api_name || ' unknown doctype ' || p_doctype_id;
    x_msg_count := 1;
    return;
  end if;

  l_progress := 200;

  -- filter p_sys_var_tbl variable
  -- while pruning the 'N' entries from l_pon_sys_vars for performance
  l_sys_var_index := p_sys_var_tbl.first;
  while (l_sys_var_index <= p_sys_var_tbl.last) loop
    if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_statement,
                     l_api_name,
		     'searching for ' || p_sys_var_tbl(l_sys_var_index));
    end if;

    l_progress := 220;

    l_found := false;
    l_pon_var_index := l_pon_sys_vars.first;
    while (l_pon_var_index <= l_pon_sys_vars.last) loop
      if (l_pon_sys_vars(l_pon_var_index)= 'N') then
        -- a value did not change, remove it from the array for performance
        l_progress := 230;

        if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
          fnd_log.string(fnd_log.level_statement,
                         l_api_name,
		         'removing ' || l_pon_var_index);
        end if;

        l_pon_sys_vars.delete(l_pon_var_index);

      elsif (l_pon_sys_vars(l_pon_var_index) =
             p_sys_var_tbl(l_sys_var_index)) then
        -- this value has changed, set found and break the loop
        l_progress := 240;

        if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
          fnd_log.string(fnd_log.level_statement,
                         l_api_name,
		         p_sys_var_tbl(l_sys_var_index) || ' changed');
        end if;

        l_found:=true;
        exit;
      end if;

      l_pon_var_index := l_pon_sys_vars.next(l_pon_var_index);
    end loop;

    l_progress := 250;

    if (not l_found) then
      -- this variable did not change, remove it from p_sys_var_tbl
      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
          fnd_log.string(fnd_log.level_statement,
                         l_api_name,
		         p_sys_var_tbl(l_sys_var_index) || ' did not change');
      end if;

      l_progress := 260;
      p_sys_var_tbl.delete(l_sys_var_index);

    end if;

    l_sys_var_index := p_sys_var_tbl.next(l_sys_var_index);
  end loop;

  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_data := null;
  x_msg_count := 0;

EXCEPTION when others then
  if (fnd_log.level_exception >= fnd_log.g_current_runtime_level) then
    fnd_log.string(fnd_log.level_exception,
                   l_api_name,
                   'unknown exception for ' || p_doc_id || ' - progress=' || l_progress);
  end if;

  FND_MSG_PUB.add_exc_msg(
    p_pkg_name        => g_package_name,
    p_procedure_name  => l_api_name || '.' || l_progress
  );
  FND_MSG_PUB.count_and_get(
    p_encoded => 'F',
    p_count   => x_msg_count,
    p_data    => x_msg_data
  );
END get_changed_variables;


PROCEDURE get_item_category(
		p_api_version            IN NUMBER,
		p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_doctype_id             IN VARCHAR2,
		p_doc_id                 IN NUMBER,
		x_category_tbl           OUT NOCOPY OKC_TERMS_UTIL_GRP.item_tbl_type,
		x_item_tbl               OUT NOCOPY OKC_TERMS_UTIL_GRP.item_tbl_type,
		x_return_status          OUT NOCOPY VARCHAR2,
		x_msg_data               OUT NOCOPY VARCHAR2,
		x_msg_count              OUT NOCOPY NUMBER
) IS
  l_api_version 	NUMBER := 1;
  l_api_name 		VARCHAR2(30) := 'GET_ITEM_CATEGORY';
  l_auction_header_id	pon_auction_headers_all.auction_header_id%type;
  l_index               NUMBER;
  TYPE category_tbl IS TABLE OF pon_auction_item_prices_all.category_name%TYPE;
  l_category_tbl        category_tbl;
  TYPE item_tbl IS TABLE OF pon_auction_item_prices_all.item_number%TYPE;
  l_item_tbl            item_tbl;
BEGIN
  --  Initialize API return status to unexpected error
  x_category_tbl.delete();
  x_item_tbl.delete();
  x_return_status := fnd_api.g_ret_sts_unexp_error;
  x_msg_data := 'pon_conterms_utl_grp.ok_to_commit() unexpected error';
  x_msg_count := 1;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                     l_api_name, l_api_name) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize();
  END IF;

  -- get auction_header_id
  pon_conterms_utl_pvt.get_auction_header_id(p_doctype_id,
					     p_doc_id,
					     l_auction_header_id,
					     x_return_status,
					     x_msg_data,
					     x_msg_count);
  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
    return ;
  END IF;

  -- insert categories
  -- bug 3290394 - type must match exactly for bulk collect in 8i
  begin
    select
      paip.category_name
    bulk collect into
      l_category_tbl
    from
      pon_auction_item_prices_all paip
    where
      paip.auction_header_id = l_auction_header_id
      and paip.category_name is not null;
  exception
    when others then
      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_statement,
		       'pon_conterms_utl_grp.get_item_category',
		       'category query returned no rows');
      end if;
  end ;

  -- now copy to output table
  if (l_category_tbl.count > 0) then
    for l_index in l_category_tbl.first..l_category_tbl.last loop
      x_category_tbl(l_index).name := l_category_tbl(l_index);
    end loop;
  end if;

  -- insert items
  -- bug 3290394 - type must match exactly for bulk collect in 8i
  begin
    select
      paip.item_number
    bulk collect into
      l_item_tbl
    from
      pon_auction_item_prices_all paip
    where
      paip.auction_header_id = l_auction_header_id
      and paip.item_number is not null;
  exception
    when others then
      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_statement,
		       'pon_conterms_utl_grp.get_item_category',
		       'item query returned no rows');
      end if;
  end ;

  -- now copy to output table
  if (l_item_tbl.count > 0) then
    for l_index in l_item_tbl.first..l_item_tbl.last loop
      x_item_tbl(l_index).name := l_item_tbl(l_index);
    end loop;
  end if;

  -- return success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_data := null;
  x_msg_count := 0;

END get_item_category;


END PON_CONTERMS_UTL_GRP;

/
