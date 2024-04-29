--------------------------------------------------------
--  DDL for Package Body PON_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_DRT_PKG" AS
/* $Header: PON_DRT_PKG.plb 120.0.12010000.3 2018/04/30 07:21:30 nrayi noship $*/

  /*=======================================================================+
  | FILENAME
  |   PON_DRT_PKG.plb
  |
  | DESCRIPTION
  |   PL/SQL body for package:  PON_DRT_PKG
  |
  | NOTES
  *=======================================================================*/

  -- Custom hook to return the ContractFile URL

     g_module_prefix         CONSTANT VARCHAR2(50) := 'po.plsql.PON_DRT_PKG.';

   procedure print_log(p_module varchar2, p_message varchar2) is
   begin
       if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
           if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
               fnd_log.string(log_level => fnd_log.level_statement,
                   module    => p_module,
                               message   => p_message);
           end if;
       end if;
   end;

PROCEDURE pon_hr_post(
    person_id IN NUMBER )
IS
  l_api_name  VARCHAR2(30) := 'pon_hr_post';
  p_person_id NUMBER       := person_id;
BEGIN
  print_log( g_module_prefix || l_api_name, 'Start');
 /*  UPDATE PON_AUCTION_HEADERS_EXT_B
 SET C_EXT_ATTR5     = NULL, --addressdetails
    C_EXT_ATTR6       = NULL, --contactdetails
    C_EXT_ATTR7       = NULL, --addressdtlsxml
    C_EXT_ATTR8       = NULL, --contactdtlsxml
    C_EXT_ATTR9       = NULL, --hiddenCountry
    C_EXT_ATTR10      = NULL  --hiddenZipCode
  WHERE attr_group_id =
    (SELECT attr_group_id
    FROM ego_attr_groups_v
    WHERE attr_group_type = 'PON_AUC_HDRS_EXT_ATTRS'
    AND attr_group_name   = 'addresses'
    )
  AND C_EXT_ATTR39 IN ('ISSUING_OFFICE','INV_OFFICE','COTR_OFFICE','PRO_ADMIN_OFFICE','REQ_OFFICE')
  AND N_EXT_ATTR3   = p_person_id; */
  print_log( g_module_prefix || l_api_name, 'End');
EXCEPTION
WHEN OTHERS THEN
    print_log( g_module_prefix || l_api_name,
        'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
  raise_application_error( -20001, 'Exception at ' || g_module_prefix ||
    l_api_name || ' : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
END;

PROCEDURE PON_CONSTRAINT_TCA_DRC(
        p_person_id IN NUMBER,
        p_entity_type IN VARCHAR2,
        result_tbl IN OUT nocopy per_drt_pkg.result_tbl_type
    ) IS
    l_index    NUMBER       := 0; -- for process_tbl index
    l_cnt1     NUMBER       := 0;
    l_cnt2     NUMBER       := 0;
    l_cnt3     NUMBER       := 0;
    l_cnt4     NUMBER       := 0;
    l_cnt5     NUMBER       := 0;
    l_cnt6     NUMBER       := 0;
    l_cnt5_1   NUMBER       := 0;
    l_cnt6_1   NUMBER       := 0;
    l_cnt7     NUMBER       := 0;
    l_cnt7_1   NUMBER       := 0;
    l_cnt8   NUMBER       := 0;
    l_cnt8_1   NUMBER       := 0;
    l_api_name VARCHAR2(30) := 'PON_CONSTRAINT_TCA_DRC';


BEGIN
    print_log( g_module_prefix || l_api_name, 'Start');

    print_log( g_module_prefix || l_api_name, ' Check PON_BID_HEADERS');
	print_log( g_module_prefix || l_api_name, ' Check for Suppliers');
    FOR tca_drc_rec in (
        select pad.message_suffix message_suffix,  count(*) count
        from   pon_bid_headers pbh, pon_auction_headers_all pah, pon_auc_doctypes pad
        where  pah.auction_header_id = pbh.auction_header_id
        and    pbh.trading_partner_id = p_person_id
        and    pbh.bid_status = 'ACTIVE'
        and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED')
        and    nvl(pah.is_template_flag , 'N') = 'N'
        and    nvl(pah.SUPP_REG_QUAL_FLAG, 'N') = 'N'
        and    nvl(pah.SUPP_EVAL_FLAG, 'N') = 'N'
        and    pah.doctype_id = pad.doctype_id
        group by pad.message_suffix
        having count(*) > 0)
    LOOP
      l_cnt1 := 1;
      print_log( g_module_prefix || l_api_name, ' Count for PON_BID_HEADERS for: '||
                    tca_drc_rec.message_suffix|| ' is: '||tca_drc_rec.count);
      per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_BID_VEND_'||tca_drc_rec.message_suffix,
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'Active bid / response / quote exist for Vendor . Delete / withdraw this';
    END LOOP;
	print_log( g_module_prefix || l_api_name, ' Check for Supplier contacts');
    FOR tca_drc_rec in (
        select pad.message_suffix message_suffix,  count(*) count
        from   pon_bid_headers pbh, pon_auction_headers_all pah, pon_auc_doctypes pad
        where  pah.auction_header_id = pbh.auction_header_id
        and    pbh.trading_partner_contact_id = p_person_id
        and    pbh.bid_status = 'ACTIVE'
        and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED')
        and    nvl(pah.is_template_flag , 'N') = 'N'
        and    nvl(pah.SUPP_REG_QUAL_FLAG, 'N') = 'N'
        and    nvl(pah.SUPP_EVAL_FLAG, 'N') = 'N'
        and    pah.doctype_id = pad.doctype_id
        group by pad.message_suffix
        having count(*) > 0)
    LOOP
      l_cnt2 := 1;
      print_log( g_module_prefix || l_api_name, ' Count for PON_BID_HEADERS for: '||
                    tca_drc_rec.message_suffix|| ' is: '||tca_drc_rec.count);
      per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_BID_VEND_CONT_'||tca_drc_rec.message_suffix,
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'Active bid / response / quote exist for Vendor contact. Delete / withdraw this';
    END LOOP;

    /*print_log( g_module_prefix || l_api_name, ' Check PON_BIDDING_PARTIES');
	print_log( g_module_prefix || l_api_name, ' Check for Suppliers');
    FOR tca_drc_rec1 in (
        select pad.message_suffix message_suffix,  count(*) count
        from   pon_bidding_parties pbp, pon_auction_headers_all pah, pon_auc_doctypes pad
        where  pah.auction_header_id = pbp.auction_header_id
        and    (pbp.trading_partner_contact_id = p_person_id
                OR pbp.trading_partner_id = p_person_id)
        and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED')
        and    nvl(pah.is_template_flag , 'N') = 'N'
        and    nvl(pah.SUPP_REG_QUAL_FLAG, 'N') = 'N'
        and    nvl(pah.SUPP_EVAL_FLAG, 'N') = 'N'
        and    pah.doctype_id = pad.doctype_id
        group by pad.message_suffix
        having count(*) > 0)
    LOOP
      l_cnt3 := 1;
      print_log( g_module_prefix || l_api_name, ' Count for PON_BIDDING_PARTIES for: '||
                    tca_drc_rec1.message_suffix|| ' is: '||tca_drc_rec1.count);

      per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => 'TCA' ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_INV_VEND_'||tca_drc_rec1.message_suffix,
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
      --'Invitation exist for Vendor contact for an active Negotiation. Delete this';
    END LOOP;  */
	print_log( g_module_prefix || l_api_name, ' Check for Supplier contacts');
    FOR tca_drc_rec1 in (
        select pad.message_suffix message_suffix,  count(*) count
        from   pon_bidding_parties pbp, pon_auction_headers_all pah, pon_auc_doctypes pad
        where  pah.auction_header_id = pbp.auction_header_id
        and    pbp.trading_partner_contact_id = p_person_id
        and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED')
        and    nvl(pah.is_template_flag , 'N') = 'N'
        and    nvl(pah.SUPP_REG_QUAL_FLAG, 'N') = 'N'
        and    nvl(pah.SUPP_EVAL_FLAG, 'N') = 'N'
        and    pah.doctype_id = pad.doctype_id
        group by pad.message_suffix
        having count(*) > 0)
    LOOP
      l_cnt4 := 1;
      print_log( g_module_prefix || l_api_name, ' Count for PON_BIDDING_PARTIES for: '||
                    tca_drc_rec1.message_suffix|| ' is: '||tca_drc_rec1.count);

      per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_INV_VEND_CONT_'||tca_drc_rec1.message_suffix,
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
      --'Invitation exist for Vendor contact for an active Negotiation. Delete this';
    END LOOP;

    print_log( g_module_prefix || l_api_name, ' Check for SLM in PON_BID_HEADERS');
    print_log( g_module_prefix || l_api_name, ' Check for Suppliers in SLM in PON_BID_HEADERS');
      select count(*)
      into   l_cnt5
      from   pon_bid_headers pbh, pon_auction_headers_all pah
      where  pah.auction_header_id = pbh.auction_header_id
      and    pbh.trading_partner_id = p_person_id
      and    pbh.bid_status = 'ACTIVE'
      and    nvl(pah.is_template_flag , 'N') = 'N'
      and    (nvl(pah.SUPP_REG_QUAL_FLAG, 'N') = 'Y' or nvl(pah.SUPP_EVAL_FLAG, 'N') = 'Y')
      and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED');

      print_log( g_module_prefix || l_api_name, ' Count for PON_BID_HEADERS: '||l_cnt5);
      IF(l_cnt5                               > 0) THEN

        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_BID_VEND_Z',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'Active response exist for Vendor contact. Delete this';
      END IF;
    print_log( g_module_prefix || l_api_name, ' Check for Supplier contacts in SLM in PON_BID_HEADERS');
      select count(*)
      into   l_cnt5_1
      from   pon_bid_headers pbh, pon_auction_headers_all pah
      where  pah.auction_header_id = pbh.auction_header_id
      and    pbh.trading_partner_id = p_person_id
      and    pbh.bid_status = 'ACTIVE'
      and    nvl(pah.is_template_flag , 'N') = 'N'
      and    (nvl(pah.SUPP_REG_QUAL_FLAG, 'N') = 'Y' or nvl(pah.SUPP_EVAL_FLAG, 'N') = 'Y')
      and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED');

      print_log( g_module_prefix || l_api_name, ' Count for PON_BID_HEADERS: '||l_cnt5_1);
      IF(l_cnt5_1                               > 0) THEN

        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_BID_VEND_CONT_Z',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'Active response exist for Vendor contact. Delete this';
      END IF;
    print_log( g_module_prefix || l_api_name, ' Check for SLM in PON_BIDDING_PARTIES');
    print_log( g_module_prefix || l_api_name, ' Check for Suppliers in SLM in PON_BIDDING_PARTIES');
      select count(*)
      into   l_cnt6
      from   pon_bidding_parties pbp, pon_auction_headers_all pah
      where  pah.auction_header_id = pbp.auction_header_id
      and    pbp.trading_partner_id = p_person_id
      and    nvl(pah.is_template_flag , 'N') = 'N'
      and    (nvl(pah.SUPP_REG_QUAL_FLAG, 'N') = 'Y' or nvl(pah.SUPP_EVAL_FLAG, 'N') = 'Y')
      and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED');

      print_log( g_module_prefix || l_api_name, ' Count for PON_BIDDING_PARTIES:'||l_cnt6);

      IF(l_cnt6                              > 0) THEN
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_INV_VEND_Z',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'Invitation exist for Vendor contact for an active Assessment. Delete this';
      END IF;
    print_log( g_module_prefix || l_api_name, ' Check for Supplier contacts in SLM in PON_BIDDING_PARTIES');
      select count(*)
      into   l_cnt6_1
      from   pon_bidding_parties pbp, pon_auction_headers_all pah
      where  pah.auction_header_id = pbp.auction_header_id
      and    pbp.trading_partner_contact_id = p_person_id
      and    nvl(pah.is_template_flag , 'N') = 'N'
      and    (nvl(pah.SUPP_REG_QUAL_FLAG, 'N') = 'Y' or nvl(pah.SUPP_EVAL_FLAG, 'N') = 'Y')
      and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED');

      print_log( g_module_prefix || l_api_name, ' Count for PON_BIDDING_PARTIES:'||l_cnt6_1);

      IF(l_cnt6_1                              > 0) THEN
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_INV_VEND_CONT_Z',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'Invitation exist for Vendor contact for an active Assessment. Delete this';
      END IF;
    print_log( g_module_prefix || l_api_name, ' Check for Supplier in Bidding Lists');
      select count(*)
      into   l_cnt7_1
      from   pon_bidding_parties pbp, pon_bidders_lists pah
      where  pah.list_header_id = pbp.list_id
      and    pbp.trading_partner_id = p_person_id
      and    pah.list_status = 'ACTIVE';

      print_log( g_module_prefix || l_api_name, ' Count for PON_BIDDING_PARTIES:'||l_cnt7_1);

      IF(l_cnt7_1                              > 0) THEN
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_LST_VEND',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'List exist for Vendor contact . Delete this';
      END IF;
    print_log( g_module_prefix || l_api_name, ' Check for Supplier contacts in Bidding Lists');
      select count(*)
      into   l_cnt7
      from   pon_bidding_parties pbp, pon_bidders_lists pah
      where  pah.list_header_id = pbp.list_id
      and    pbp.trading_partner_contact_id = p_person_id
      and    pah.list_status = 'ACTIVE';

      print_log( g_module_prefix || l_api_name, ' Count for PON_BIDDING_PARTIES:'||l_cnt7);

      IF(l_cnt7                              > 0) THEN
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_LST_VEND_CONT',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'List exist for Vendor contact . Delete this';
      END IF;
    print_log( g_module_prefix || l_api_name, ' Check for Supplier contacts in Templates');
      select count(*)
      into   l_cnt8
      from   pon_bidding_parties pbp, pon_auction_headers_all pah
      where  pah.auction_header_id = pbp.auction_header_id
      and    pbp.trading_partner_contact_id = p_person_id
      and    nvl(pah.is_template_flag , 'N') = 'Y'
      and    pah.template_status = 'ACTIVE';

      print_log( g_module_prefix || l_api_name, ' Count for PON_BIDDING_PARTIES:'||l_cnt8);

      IF(l_cnt8                              > 0) THEN
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_TMP_VEND_CONT',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'Invitation exist for Vendor contact for an active Template. Delete this';
      END IF;
    print_log( g_module_prefix || l_api_name, ' Check for Supplier in Templates');
      select count(*)
      into   l_cnt8_1
      from   pon_bidding_parties pbp, pon_auction_headers_all pah
      where  pah.auction_header_id = pbp.auction_header_id
      and    pbp.trading_partner_id = p_person_id
      and    nvl(pah.is_template_flag , 'N') = 'Y'
      and    pah.template_status = 'ACTIVE';

      print_log( g_module_prefix || l_api_name, ' Count for PON_BIDDING_PARTIES:'||l_cnt8_1);

      IF(l_cnt8_1                              > 0) THEN
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_TMP_VEND',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'Invitation exist for Vendor for an active Template. Delete this';
      END IF;

    -- if no warning/errors so far, record success to process_tbl
  /*  IF (l_cnt1 < 1 and l_cnt2 < 1 and l_cnt3 < 1 and l_cnt5< 1
		and l_cnt6< 1 and l_cnt7< 1 and l_cnt6_1< 1 and l_cnt7_1< 1
		and l_cnt8< 1 and l_cnt8_1< 1) THEN
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => 'TCA' ,
                                  status => 'S' ,
                                  msgcode => NULL,
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
    END IF;	  */

    print_log( g_module_prefix || l_api_name, ' if supplier present in pon_bidding_parties or pon_bid_headers throw a warning message for PDF');


    IF(l_cnt2 >0 OR l_cnt4 >0 )   THEN
    per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'W' ,
                                  msgcode => 'PON_DRT_PDF_FOR_SUPP_X',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
    END IF;
    print_log( g_module_prefix || l_api_name, 'End');
END PON_CONSTRAINT_TCA_DRC;

PROCEDURE PON_CONSTRAINT_FND_DRC (
        p_person_id IN NUMBER,
        p_entity_type IN VARCHAR2,
        result_tbl IN OUT nocopy per_drt_pkg.result_tbl_type
    ) IS
    l_index    NUMBER       := 0; -- for process_tbl index
    l_cnt      NUMBER       := 0;
    l_cnt1      NUMBER       := 0;
    l_cnt2      NUMBER       := 0;
    l_api_name VARCHAR2(30) := 'PON_CONSTRAINT_FND_DRC';

BEGIN

    print_log( g_module_prefix || l_api_name, 'Start');

    print_log( g_module_prefix || l_api_name, ' Check for PON_NEG_TEAM_MEMBERS');
	FOR fnd_drc_rec in (
        select Decode(pad.message_suffix,'X','X','B') message_suffix,  count(*) count
        from   pon_neg_team_members pnt, pon_auction_headers_all pah, pon_auc_doctypes pad
        where  pah.auction_header_id = pnt.auction_header_id
        and    pnt.user_id = p_person_id
        and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED')
        and    nvl(pah.is_template_flag , 'N') = 'N'
        and    nvl(pah.SUPP_REG_QUAL_FLAG, 'N') = 'N'
        and    nvl(pah.SUPP_EVAL_FLAG, 'N') = 'N'
        and    pah.doctype_id = pad.doctype_id
        group by Decode(pad.message_suffix,'X','X','B')
        having count(*) > 0)
    LOOP
      l_cnt := 1;
      print_log( g_module_prefix || l_api_name, ' Count for PON_NEG_TEAM_MEMBERS for: '||
                    fnd_drc_rec.message_suffix|| ' is: '||fnd_drc_rec.count);
      per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_NEG_TEAM_EXIST_'||fnd_drc_rec.message_suffix,
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'The user exists in the collaboration team for an active Negotiation.  Change the date or delete';
    END LOOP;
    print_log( g_module_prefix || l_api_name, ' Check for SLM in PON_NEG_TEAM_MEMBERS');

      select count(*)
      into   l_cnt1
      from   pon_neg_team_members pnt, pon_auction_headers_all pah
      where  pah.auction_header_id = pnt.auction_header_id
      and    pnt.user_id = p_person_id
      and    nvl(pah.is_template_flag , 'N') = 'N'
      and    (nvl(pah.SUPP_REG_QUAL_FLAG, 'N') = 'Y' or nvl(pah.SUPP_EVAL_FLAG, 'N') = 'Y')
      and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED');

      print_log( g_module_prefix || l_api_name, ' Count for PON_NEG_TEAM_MEMBERS:'||l_cnt1);
	  if l_cnt1 > 1 then
	        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_NEG_TEAM_EXIST_Z',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'The user exists in the collaboration team for an active Negotiation.  Change the date or delete';
	  end if;

    print_log( g_module_prefix || l_api_name, ' Check for Templates in PON_NEG_TEAM_MEMBERS');

      select count(*)
      into   l_cnt2
      from   pon_neg_team_members pnt, pon_auction_headers_all pah
      where  pah.auction_header_id = pnt.auction_header_id
      and    pnt.user_id = p_person_id
      and    nvl(pah.is_template_flag , 'N') = 'Y'
      and    pah.template_status = 'ACTIVE';

      print_log( g_module_prefix || l_api_name, ' Count for PON_NEG_TEAM_MEMBERS:'||l_cnt2);
	  if l_cnt2 > 1 then
	        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_NEG_TEM_EXIST',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'The user exists in the collaboration team for an active Template.  Change the date or delete';
	  end if;
    -- if no warning/errors so far, record success to process_tbl
  /*  IF (l_cnt < 1 and l_cnt1 < 1 and l_cnt2 <1 ) THEN
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => 'FND' ,
                                  status => 'S' ,
                                  msgcode => NULL,
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
    END IF;	*/
    print_log( g_module_prefix || l_api_name, 'End');
END;

PROCEDURE PON_CONSTRAINT_HR_DRC (
        p_person_id IN NUMBER,
        p_entity_type IN VARCHAR2,
        result_tbl IN OUT nocopy per_drt_pkg.result_tbl_type
    ) IS
    l_index    NUMBER       := 0; -- for process_tbl index
    l_cnt      NUMBER       := 0;
    l_cnt2     NUMBER       := 0;
    l_cnt3     NUMBER       := 0;
    l_cnt2_1   NUMBER       := 0;
    l_cnt3_1   NUMBER       := 0;

    l_init_owner_count  NUMBER  := 0;
    l_init_sponsor_count NUMBER := 0;
    l_init_task_count    NUMBER := 0;

    l_init_owner_query  VARCHAR2(4000);
    l_init_sponsor_query VARCHAR2(4000);
    l_init_task_query    VARCHAR2(4000);
	l_count				NUMBER;
    l_api_name VARCHAR2(30) := 'PON_CONSTRAINT_HR_DRC';
    l_init_check_query varchar2(4000);




BEGIN
    print_log( g_module_prefix || l_api_name, 'Start');

    print_log( g_module_prefix || l_api_name, ' Check for PON_AUCTION_HEADERS');
    FOR hr_drc_rec in (
        select pad.message_suffix message_suffix,  count(*) count
        from   pon_auction_headers_all pah, pon_auc_doctypes pad, per_all_people_f p
        where  p.person_id = p_person_id
        and    TRUNC(SYSDATE) BETWEEN P.EFFECTIVE_START_DATE AND P.EFFECTIVE_END_DATE
        and    pah.trading_partner_contact_id = p.party_id
        and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED')
        and    nvl(pah.is_template_flag , 'N') = 'N'
        and    nvl(pah.SUPP_REG_QUAL_FLAG, 'N') = 'N'
        and    nvl(pah.SUPP_EVAL_FLAG, 'N') = 'N'
        and    pah.doctype_id = pad.doctype_id
        group by pad.message_suffix
        having count(*) > 0)
    LOOP
      l_cnt := 1;
      print_log( g_module_prefix || l_api_name, ' Count for PON_AUCTION_HEADERS for: '||
                    hr_drc_rec.message_suffix|| ' is: '||hr_drc_rec.count);
      per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type,
                                  status => 'E',
                                  msgcode => 'PON_DRT_AUC_EXIST_FOR_EMP_'||hr_drc_rec.message_suffix,
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'Active negotiation exist for Employee.  Change the data or delete';
    END LOOP;
    print_log( g_module_prefix || l_api_name, ' Check for SLM in PON_AUCTION_HEADERS');

      select count(*)
      into   l_cnt2
      from   pon_auction_headers_all pah
      where  pah.trading_partner_contact_id = p_person_id
      and    nvl(pah.is_template_flag , 'N') = 'N'
      and    (nvl(pah.SUPP_REG_QUAL_FLAG, 'N') = 'Y' or nvl(pah.SUPP_EVAL_FLAG, 'N') = 'Y')
      and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED');

      print_log( g_module_prefix || l_api_name, ' Count for PON_AUCTION_HEADERS: '||l_cnt2);
      IF(l_cnt2                               > 0) THEN

        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_AUC_EXIST_FOR_EMP_Z',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'Active negotiation exist for Employee.  Change the data or delete';
      END IF;

    print_log( g_module_prefix || l_api_name, ' Check for Template in PON_AUCTION_HEADERS');

      select count(*)
      into   l_cnt2_1
      from   pon_auction_headers_all pah
      where  pah.trading_partner_contact_id = p_person_id
      and    nvl(pah.is_template_flag , 'N') = 'Y'
      and    pah.template_status = 'ACTIVE';

      print_log( g_module_prefix || l_api_name, ' Count for PON_AUCTION_HEADERS: '||l_cnt2_1);
      IF(l_cnt2_1                               > 0) THEN

        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_TMP_EXIST_FOR_EMP',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --'Active Template exist for Employee.  Change the data or delete';
      END IF;

      print_log( g_module_prefix || l_api_name, 'Check the user in addresses of CLM Documents');
     /* SELECT count(*)
      INTO l_cnt3
      FROM PON_AUCTION_HEADERS_EXT_B pahe, PON_AUCTION_HEADERS_ALL pah
      WHERE attr_group_id =
        (SELECT attr_group_id
        FROM ego_attr_groups_v
        WHERE attr_group_type = 'PON_AUC_HDRS_EXT_ATTRS'
        AND attr_group_name   = 'addresses'
        )
      AND pahe.C_EXT_ATTR39 IN ('ISSUING_OFFICE','INV_OFFICE','COTR_OFFICE','PRO_ADMIN_OFFICE','REQ_OFFICE')
      AND pahe.auction_header_id = pah.auction_header_id
      AND pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED')
      AND pahe.N_EXT_ATTR3   = p_person_id;
      print_log( g_module_prefix || l_api_name, ' Count : '||l_cnt3);
      IF(l_cnt3                               > 0) THEN

        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_AUC_ADDR_FOR_EMP_X',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --Has active Awards having details in the UDA addresses attribute group
      END IF;

	  print_log( g_module_prefix || l_api_name, 'Check the user  CLM Documents for warning: PDF');
      SELECT count(*)
      INTO l_cnt3_1
      FROM PON_AUCTION_HEADERS_EXT_B pahe, PON_AUCTION_HEADERS_ALL pah
      WHERE attr_group_id =
        (SELECT attr_group_id
        FROM ego_attr_groups_v
        WHERE attr_group_type = 'PON_AUC_HDRS_EXT_ATTRS'
        AND attr_group_name   = 'addresses'
        )
      AND pahe.C_EXT_ATTR39 IN ('ISSUING_OFFICE','INV_OFFICE','COTR_OFFICE','PRO_ADMIN_OFFICE','REQ_OFFICE')
      AND pahe.auction_header_id = pah.auction_header_id
      AND pah.publish_date is not NULL
      AND pahe.N_EXT_ATTR3   = p_person_id; */
      print_log( g_module_prefix || l_api_name, ' Count : '||l_cnt3_1);
      IF(l_cnt >0) THEN

        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'W' ,
                                  msgcode => 'PON_DRT_PDF_FOR_EMP_X',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
        --PDF Warning
      END IF;

    -- if no warning/errors so far, record success to process_tbl
   /* IF(l_cnt < 1 and l_cnt2 < 1 and l_cnt3 < 1 and l_cnt2_1 < 1 and l_cnt3_1 < 1) THEN
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => 'HR' ,
                                  status => 'S' ,
                                  msgcode => NULL,
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
    END IF;		*/

    --  Has set as Default Addresses Contact Person in CLM Preferences page
  /*  SELECT COUNT(*)
    INTO l_count
    FROM PO_USER_PREFERENCES PO_PREF
    WHERE PO_PREF.preference_type='OFFICE_ADDRESS'
    AND PO_PREF.functional_area  ='SOURCING'
    AND contact_id               =p_person_id;

    IF(l_count >0) THEN

        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_OFCR_X',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
     END IF;
	-- Has set as default Contracing Officer in CLM Preferences page
    SELECT COUNT(*)
    INTO l_count
    FROM PO_USER_PREFERENCES PO_PREF
    WHERE PO_PREF.preference_type='CONTRACT_OFFICER'
    AND PO_PREF.functional_area  ='SOURCING'
    AND CLM_CONTRACT_OFFICER               =p_person_id;

    IF(l_count >0) THEN

        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_CONT_OFCR_X',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
     END IF;

       -- for initiatives
	   -- check id initiative table exists
    l_init_check_query:='select count(*) from sys.all_tables where table_name=''PON_INITIATIVES''';

    EXECUTE IMMEDIATE l_init_check_query INTO l_count;

      IF(l_count>0) THEN

       -- get the active initiatives
   -- no need to check for end_date has initiative will be active even after crossing the end_date
   -- status will be delayed, it will complete only if initiative status is 100

print_log( g_module_prefix || l_api_name, 'checkin for initiative owner');
l_init_owner_query:= 'select count(*) from  pon_initiatives where  owner_id = '|| p_person_id ||
' and    STATUS_CODE not in (''CANCELLED'', ''COMPLETED'', ''INACTIVE'')  and    nvl(template_flag , ''N'') = ''N'' AND    pon_init_util_pkg.GET_INIT_ACTUAL_PROGRESS(initiative_id) <> 100 ';


      EXECUTE IMMEDIATE l_init_owner_query INTO l_init_owner_count;



     IF(l_init_owner_count  > 0) THEN

       per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_INIT_OWNER',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
      END IF;



   -- get the active initiatives
   -- no need to check for end_date has initiative will be active even after crossing the end_date
   -- status will be delayed, it will complete only if initiative status is 100
   print_log( g_module_prefix || l_api_name, 'checkin for initiative sponsor');
   l_init_sponsor_query:= 'select count(*) ' ||
       ' from   pon_initiatives '  ||
       ' where  sponsor_id = '|| p_person_id ||
       ' and    STATUS_CODE not in (''CANCELLED'', ''COMPLETED'', ''INACTIVE'') ' ||
        'and    nvl(template_flag , ''N'') = ''N'' '||
        'AND    pon_init_util_pkg.GET_INIT_ACTUAL_PROGRESS(initiative_id) <> 100 ' ;

      EXECUTE IMMEDIATE l_init_sponsor_query INTO l_init_sponsor_count;

       IF(l_init_sponsor_count  > 0) THEN

       per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_INIT_SPONSOR',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
      END IF;

     -- get active tasks
	 print_log( g_module_prefix || l_api_name, 'checkin for initiative task owner');
    l_init_task_query:=  'select count(*) ' ||
        ' from   pon_init_tasks pot, pon_initiatives poi ' ||
        ' where pot.status_code not in (''CANCELLED'', ''COMPLETED'', ''INACTIVE'') '||
        ' AND   nvl(pot.percentage_completed,0) <> 100 ' ||
        ' AND   poi.initiative_id=pot.initiative_id '  ||
        ' AND   pot.owner_id =   '      ||	 p_person_id ||
        ' AND   nvl(poi.template_flag,''N'') = ''N'' '||
        'and   poi.status_code not in (''CANCELLED'', ''COMPLETED'', ''INACTIVE'') '  ;

        EXECUTE IMMEDIATE l_init_task_query INTO l_init_task_count;

        IF(l_init_task_count  > 0) THEN

       per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => p_entity_type ,
                                  status => 'E' ,
                                  msgcode => 'PON_DRT_INIT_ACT_TASKS',
                                  msgaplid => 396 ,
                                  result_tbl => result_tbl);
      END IF;

      END IF;  */

    print_log( g_module_prefix || l_api_name, 'End');

END;



PROCEDURE PON_TCA_DRC(
        p_person_id IN NUMBER,
        result_tbl OUT nocopy per_drt_pkg.result_tbl_type
    ) IS

l_api_name VARCHAR2(30) := 'PON_TCA_DRC';

    l_person_id NUMBER;
    l_user_id NUMBER;
    l_results_tbl per_drt_pkg.result_tbl_type;
BEGIN
    print_log( g_module_prefix || l_api_name, 'Start');

    -- call TCA constraints procedure
     pon_constraint_tca_drc(p_person_id,'TCA',l_results_tbl);

     -- for employee validate FND and and HR data also
     begin
    SELECT employee_id,user_id INTO l_person_id,l_user_id FROM fnd_user WHERE person_party_id=p_person_id AND ROWNUM=1;
    EXCEPTION
    WHEN OTHERS THEN
     l_person_id:=NULL;
     l_user_id:=NULL;
     END;

     print_log( g_module_prefix || l_api_name, 'for employees validate fnd and HR ');
    IF(l_person_id IS NOT NULL  AND l_user_id IS NOT NULL) THEN
     PON_CONSTRAINT_HR_DRC(l_person_id,'TCA',l_results_tbl);
     PON_CONSTRAINT_FND_DRC(l_user_id,'TCA',l_results_tbl);

     END IF;

     IF(result_tbl.count < 1) THEN
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => 'TCA' ,
                                  status => 'S' ,
                                  msgcode => NULL,
                                  msgaplid => 396 ,
                                  result_tbl => l_results_tbl);
	end if;
	 result_tbl:=l_results_tbl;

    print_log( g_module_prefix || l_api_name, 'End');
END;

PROCEDURE PON_FND_DRC (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy per_drt_pkg.result_tbl_type
    ) IS
    l_api_name VARCHAR2(30) := 'PON_FND_DRC';
    l_person_id NUMBER;
    l_party_id NUMBER;
   l_results_tbl per_drt_pkg.result_tbl_type;
BEGIN

    print_log( g_module_prefix || l_api_name, 'Start');

    -- call FND constraints procedure
    pon_constraint_fnd_drc(p_person_id,'FND',l_results_tbl);

    BEGIN
    SELECT employee_id,person_party_id INTO l_person_id,l_party_id FROM fnd_user WHERE user_id=p_person_id AND ROWNUM=1;
    EXCEPTION
    WHEN OTHERS THEN
     l_person_id:=NULL;
     l_party_id:=NULL;
     END;

     print_log( g_module_prefix || l_api_name, 'for employees validate fnd and HR ');

     -- for employee validate TCA and and HR data also
    IF(l_person_id IS NOT NULL  AND l_party_id IS NOT NULL) THEN
     PON_CONSTRAINT_HR_DRC(l_person_id,'FND',l_results_tbl);
     PON_CONSTRAINT_TCA_DRC(l_party_id,'FND',l_results_tbl);

     END IF;

     -- for supplier validate TCA data also
     IF(l_person_id IS NULL  AND l_party_id IS NOT NULL) THEN
     PON_CONSTRAINT_TCA_DRC(l_party_id,'FND',l_results_tbl);

     END IF;
    IF(l_results_tbl.count < 1) THEN
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => 'FND' ,
                                  status => 'S' ,
                                  msgcode => NULL,
                                  msgaplid => 396 ,
                                  result_tbl => l_results_tbl);
	end if;
	 result_tbl:= l_results_tbl;
    print_log( g_module_prefix || l_api_name, 'End');
END;

PROCEDURE PON_HR_DRC (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy per_drt_pkg.result_tbl_type
    ) IS
    l_index    NUMBER       := 0; -- for process_tbl index
    l_cnt      NUMBER       := 0;
    l_cnt2     NUMBER       := 0;
    l_cnt3     NUMBER       := 0;
    l_cnt2_1   NUMBER       := 0;
    l_cnt3_1   NUMBER       := 0;

    l_init_owner_count  NUMBER  := 0;
    l_init_sponsor_count NUMBER := 0;
    l_init_task_count    NUMBER := 0;

    l_init_owner_query  VARCHAR2(400);
    l_init_sponsor_query VARCHAR2(400);
    l_init_task_query    VARCHAR2(400);
    l_api_name VARCHAR2(30) := 'PON_HR_DRC';

    l_party_id NUMBER;
    l_user_id NUMBER;
    l_results_tbl per_drt_pkg.result_tbl_type;


BEGIN
    print_log( g_module_prefix || l_api_name, 'Start');

    -- call HR constraints procedure
    pon_constraint_hr_drc(p_person_id,'HR',l_results_tbl);

    -- for employee validate TCA and and FND data also

    begin
    SELECT person_party_id,user_id INTO l_party_id,l_user_id FROM fnd_user WHERE employee_id=p_person_id AND ROWNUM=1;
    EXCEPTION
    WHEN OTHERS THEN
     l_party_id:=NULL;
     l_user_id:=NULL;
     END;

     print_log( g_module_prefix || l_api_name, 'for employees validate fnd and HR ');
    IF(l_party_id IS NOT NULL  AND l_user_id IS NOT NULL) THEN
     PON_CONSTRAINT_TCA_DRC(l_party_id,'HR',l_results_tbl);
     PON_CONSTRAINT_FND_DRC(l_user_id,'HR',l_results_tbl);

     END IF;

-- if no warning/errors so far, record success to process_tbl
    IF(l_results_tbl.count < 1) THEN
        per_drt_pkg.add_to_results (person_id => p_person_id ,
                                  entity_type => 'HR' ,
                                  status => 'S' ,
                                  msgcode => NULL,
                                  msgaplid => 396 ,
                                  result_tbl => l_results_tbl);
	end if;
    result_tbl:=l_results_tbl;
    print_log( g_module_prefix || l_api_name, 'End');

END;

END;

/
