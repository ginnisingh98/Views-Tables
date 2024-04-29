--------------------------------------------------------
--  DDL for Package Body OKC_OC_INT_KTQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OC_INT_KTQ_PVT" AS
/* $Header: OKCRKTQB.pls 120.3 2006/02/28 14:50:17 smallya noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--
--  Copyright (c) 1999 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  Created By Matt Connors          01-31-2000
--  Modified By Satish Karumuri      02-14-2000
--  Modified Quote creation around currency AND effectivity rules.
--
--  Modified By Eric TRUSZ		  04-19-2000
--
--  1-Implemented trace mode
--  2-Added conditions on contract validations (Sell AND Issue)
--  3-Added condition on g_rd_billto, g_rd_custacct, g_rd_price and
--  g_rd_invrule rules uniqueness
--  4-Added conditions on contract party validations
--    (2 parties, 2 roles, 1 party <> operunit)
--  5-Completed exception clauses fro trace mode
--  6-Removed conditions on rule groups in the c_rule cursor
--  7-Included Convertion rule
--  8-Removed SUPPORT as candidate line for selecting covered product lines
--  9-Made mandatory the currency code at the contract header.
--    No default value derived from the contract operating unit.
-- 10-Added exception clauses in build_qte_hdr AND build_qte_line procedures
--    AND completed with error message handling
-- 11-Completed global cusrsors with additional columns (currency_code...)
-- 12-Reviewed quote line price calculation
-- 13-Added exchange information for quote
-- 14-Added conditions on org_id AND organization_id when
--    using okx_customer_products_v
-- 15-Added the organization context initialization
-- 16-Ensure that the source of the covered products is OKX_CUSTOMER_PRODUCTS_V
--    instead of testing the JTF Object code
-- 17-Reviewed quote line creation by disregarding the top lines for which
--    an error occurs when calculating the price, AND by printing
--    an appropriate message
-- 18-Reviewed contract line research by disregarding the service AND ext warr.
--    lines having no covered product lines, AND by printing an appropriate
--    message
-- 19-reevaluated the quote line price as unit price
--
--
--  Modified By Eric TRUSZ		  04-19-2000
--
-- 1-Added the quote NUMBER having been created in the contract comments;
--   In case the quote creation failed, a specific error message is added.
-- 2-Relplaced all TABLE_NAME_B reference with the related view TABLE_NAME_V
--   to be compliant with the standards
-- 3-Implemented quote line creation for contract having support top
--   AND sub lines
-- 4-Removed the creation of a dummy quote detail line when we have no
--   subline for a top contract line
-- 5-Added trace file name into the contract's comments
-- 6-Set an error message before each different API called
-- 7-Added update_k_comments_err procedure to update contract in case of quote
--   creation error
--
--  Modified By Eric TRUSZ		  07-11-2000
--
-- 1-Reviewed quote line price calculation (New requirements defined by Mara
--   AND Jorg)
-- 2-Reviewed contract comments update with specific OKC message.
-- 3-Moved trace procedures to the OKC_UTIL package
--
--  Modified By Eric TRUSZ		  07-27-2000
--
-- 1-Removed use of service_ref_line_number in quote creation, used to
--   reference any existing quote line
--
--  Modified By Eric TRUSZ		  08-09-2000
--
-- 1-Replaced all okc_xxx_v references with okc_xxx_b references
--
--  Modified By Eric TRUSZ		  10-20-2000
--
-- 1-Modified c_top_cle cursor for contract top line selection
--      -All the hierarchy of the top line style is considered to find out
--       priced items
--      -Each is printed as well as the exception in case it is not
--       suitable for a quote/order creation
--      -Modified order of contract line processing to ensure that Li. Prod.
--       lines will be handled before Support lines
--
-- 2-Added new features:
--      -rules for renewal (H, L)
--      -ship_to rule (H)
--      -customer_order_enabled_flag
--      -Added flexibility by created new procedures:
--          -is_line_orderable_s
--          -is_line_orderable_i
--          -is_line_with_covered_prod
--          -build_oc_relationships
--          -validate_oc_eligibility
--
--  Modified By Eric TRUSZ		  02-26-2001
--
--    Modified to provide with service reference values
--    in service_ref_line_id instead of service_ref_system_id.
--
-- ===========================================================================
--
--  Modified By Vijay Ramalingam	   30-Jul-2001
--
--      - Added/modified the following new procedures
--		- added update_quote_from_k
--		- added validate_k_eligibility
--		- added build_k_structures
--		- modified build_qte_hdr
--		- modified build_qte_line
--		- added aso_quote_pub.update_quote_from_k procedure
--
--
--      - Added the following new functions
--
--		- is_top_line_style_seeded
--		- is_top_line_with_covered_prod
--		- is_top_line_orderable
--		- is_kl_linked_to_ql
--
--  Modified By Vijay Ramalingam	   13-Aug-2001
--
--	- Added the sales rep information for the quote header rec
--	- Added the sign_by_date for the quote_expiration_date
--	- Added Procedure calls to sales credit
--	- Modified the c_q_k_rel cursor to pick up the quote id
--	- Modified procedures, wherever p_quote_id was passed and
--		replace it with a g_quote_id which was selected
--		instead of being passed.
--	- Fixed a minor bug encountered during unit testing in the
--		is_top_line_orderable_i
--
--
--  Modified By Vijay Ramalingam	   20-Aug-2001
--
--      - Added the call to the quote_line relationship procedure in
--        the OKC_OC_INT_CONFIG_PVT package to create the relationship
--        between the quote lines.
--      - Modified the c_top_cle_init cursor to include the configuration
--        items.
--      - Modified the build_qte_line procedure to handle the configuration
--        items, and to populate the item type code
--
--  Modified By Vijay Ramalingam	   28-Aug-2001
--
--	- Deleted some global constants, variables and cursors that
--	  were not used in the package
--
--  Modified By Vijay Ramalingam	   30-Aug-2001
--
--	- Modified the way the px_k2q_line_tbl is populated in the build_qte_line
--	  procedure.
--
--  Notes AND limitations:
--
-- ===========================================================================
--
-- global constants
--
-- standard api constants
--
G_UNEXPECTED_ERROR             	CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLCODE_TOKEN        	       	CONSTANT VARCHAR2(200) := 'SQLCODE';
G_SQLERRM_TOKEN  	       	CONSTANT VARCHAR2(200) := 'SQLERRM';
G_PKG_NAME		       	CONSTANT VARCHAR2(200) := 'OKC_OC_INT_KTQ_PVT';
G_APP_NAME		       	CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
G_APP_NAME1		       	CONSTANT VARCHAR2(3)   :=  'OKO';

-- other constants
g_okx_system_items_v            CONSTANT VARCHAR2(30)  := 'OKX_SYSTEM_ITEMS_V';
g_okx_product_lines_v           CONSTANT VARCHAR2(50)  := 'OKX_PRODUCT_LINES_V';
g_okx_customer_products_v       CONSTANT VARCHAR2(50)  := 'OKX_CUSTOMER_PRODUCTS_V';
g_okx_operunit                  CONSTANT VARCHAR2(30)  := 'OKX_OPERUNIT';
g_okx_legentity                 CONSTANT VARCHAR2(30)  := 'OKX_LEGAL_ENTITY';
g_okx_service                   CONSTANT VARCHAR2(30)  := 'OKX_SERVICE';

g_sts_entered                   CONSTANT VARCHAR2(30)  := 'ENTERED';
g_sts_terminated                CONSTANT VARCHAR2(30)  := 'TERMINATED';

g_qte_ref_cp                    CONSTANT VARCHAR2(30)  := 'CUSTOMER_PRODUCT';
g_qte_ref_order                 CONSTANT VARCHAR2(30)  := 'ORDER';

g_supplier_ptrol		CONSTANT VARCHAR2(30)  := 'SUPPLIER';
g_salesrep_ctrol		CONSTANT VARCHAR2(30)  := 'SALESPERSON';
g_jtf_okx_salepers		CONSTANT VARCHAR2(30)  := 'OKX_SALEPERS';


--
-- global cursors
--
-- cursor to get the quote header information
--
CURSOR c_qhr(b_qhr_id NUMBER) IS
SELECT quote_number
	,quote_version
FROM   okx_quote_headers_v
WHERE  id1 = b_qhr_id;

--
-- cursor for contract header information
--
CURSOR c_chr (b_chr_id NUMBER) IS SELECT
   object_version_number
  ,authoring_org_id
  ,inv_organization_id
  ,contract_number
  ,contract_number_modifier
  ,currency_code
  ,estimated_amount
  ,date_renewed
  ,scs_code
  ,total_line_list_price
  ,price_list_id
  ,sign_by_date
FROM okc_k_headers_b
WHERE id = b_chr_id;

CURSOR c_k_header(b_chr_id NUMBER) IS
SELECT
	   kh.ID                    ,
	   --kh.STS_CODE	    ,
	   kh.SCS_CODE              ,
	   kh.CONTRACT_NUMBER	    ,
	   kh.CURRENCY_CODE         ,
	   kh.CONTRACT_NUMBER_MODIFIER,
	   kh.TEMPLATE_YN           ,
	   kh.TEMPLATE_USED         ,
	   kh.CHR_TYPE              ,
	   kh.DATE_TERMINATED       ,
	   --
	   kh.DATE_RENEWED          ,
           kh2.contract_number ren_contract_num,
	   --
	   kh.START_DATE            ,
	   kh.END_DATE              ,
	   kh.AUTHORING_ORG_ID      ,
	   kh.INV_ORGANIZATION_ID   ,
           kh.BUY_OR_SELL	    ,
           kh.ISSUE_OR_RECEIVE      ,
	   kh.ESTIMATED_AMOUNT      ,
	   ks.cls_code              ,
	   ks.meaning               ,
           kst.ste_code
FROM okc_statuses_b   kst,
     okc_k_headers_b  kh,
     okc_k_headers_b  kh2,
     okc_subclasses_v ks
WHERE kh.id     = b_chr_id
AND   ks.code   = kh.scs_code
AND   kst.code  = kh.sts_code
AND   kh2.id(+) = kh.chr_id_renewed_to;


--
-- cursor to get covered product information for:
-- service lines, ext warranty lines and support lines
--
CURSOR c_cp (b_chr_id     NUMBER,
		   b_line_id    NUMBER,
		   b_org_id     NUMBER,
		   b_inv_org_id NUMBER) IS
SELECT -- For service and ext warranty lines
   cle.id              cle_id
  ,cle.line_number     line_number
  --,cle.sts_code      sts_code
  ,sts.ste_code        ste_code
  --
  ,NVL(cim.number_of_items, cpt.quantity) quantity
  ,DECODE(cim.number_of_items, NULL,cpt.unit_of_measure_code,
	     cim.uom_code)   uom_code
  ,cim.priced_item_yn        priced_item_yn
  ,cle.price_unit            price_unit
  ,cle.price_negotiated      price_negotiated
  ,cle.currency_code         currency_code
  --
  ,cle.start_date            start_date
  ,cle.end_date              end_date
  --
  ,lse.lse_type              line_style
  ,lse.lty_code              line_type
  ,lss.jtot_object_code      line_source_code
  ,jot.from_table            line_source_table
  --
  --,cpt.id1                 id1
  --,cpt.id2                 id2
  ,cim.object1_id1           id1
  ,cim.object1_id2           id2
  ,cpt.name                  prod_name
  ,cim.jtot_object1_code     item_source_code
  ,jot.from_table            item_source_table
FROM
	jtf_objects_b        jot
    ,okc_k_lines_b           cle
    ,okc_k_items             cim
    ,okc_line_styles_b       lse
    ,okc_line_style_sources  lss
    ,okx_customer_products_v cpt
    ,okc_statuses_b          sts
WHERE
	cim.cle_id          = cle.id
  AND cpt.id1               = cim.object1_id1
  AND cpt.id2               = cim.object1_id2
  AND cpt.org_id            = b_org_id
  AND cpt.organization_id   = b_inv_org_id
  AND jot.object_code       = cim.jtot_object1_code
  AND rtrim(ltrim(jot.from_table)) like g_okx_customer_products_v||'%'||cim.jtot_object1_code
  --
  AND lse.id                = cle.lse_id
  AND lse.lty_code          = g_lt_coverprod  -- must be a covered product
  AND lss.lse_id            = lse.id
  AND lss.jtot_object_code  = cim.jtot_object1_code
  --
  AND sts.code              = cle.sts_code
  AND sts.ste_code          <> g_sts_terminated
  --
  AND cle.cle_id            = b_line_id       -- immediate child of top line
  AND cle.dnz_chr_id        = b_chr_id

UNION

SELECT -- For support lines
   cle.id                     cle_id
  ,cle.line_number            line_number
  --,cle.sts_code             sts_code
  ,sts.ste_code               ste_code
  --
  ,NVL(cim.number_of_items, cpt.quantity) quantity
  ,DECODE(cim.number_of_items, NULL,cpt.unit_of_measure_code,
	     cim.uom_code)    uom_code
  ,cim.priced_item_yn         priced_item_yn
  ,cle.price_unit
  ,cle.price_negotiated
  ,cle.currency_code
  --
  ,cle.start_date
  ,cle.end_date
  --
  ,lse.lse_type               line_style
  ,lse.lty_code               line_type
  ,lss.jtot_object_code       line_source_code
  ,jot.from_table             line_source_table
  --
  --,cpt.inventory_item_id
  --,cpt.organization_id
  ,cim.object1_id1            id1
  ,cim.object1_id2            id2
  ,sit.name                   prod_name
  ,cim.jtot_object1_code
  ,jot.from_table
FROM jtf_objects_b          jot
    ,okc_k_lines_b          cle
    ,okc_k_items            cim
    ,okc_line_styles_b      lse
    ,okc_line_style_sources lss
    ,okx_product_lines_v    cpt
    ,okx_system_items_v     sit
    ,okc_statuses_b         sts
WHERE cim.cle_id            = cle.id
  AND cpt.id1               = cim.object1_id1
  AND cpt.id2               = cim.object1_id2
  AND cpt.dnz_chr_id        = cle.dnz_chr_id
  AND jot.object_code       = cim.jtot_object1_code
  AND rtrim(ltrim(jot.from_table)) like
	 DECODE(lse.lty_code, g_lt_suppline,
		 g_okx_product_lines_v||'%'||cim.jtot_object1_code,
		 g_okx_system_items_v||'%'||cim.jtot_object1_code)
  --
  AND sit.organization_id   = cpt.organization_id
  AND sit.inventory_item_id = cpt.inventory_item_id
  --
  AND lse.id                = cle.lse_id
  AND lse.lty_code          IN (g_lt_suppline,   -- must be a support_line line,
				  g_lt_supp)       -- or support line
  AND lss.lse_id            = lse.id
  AND lss.jtot_object_code  = cim.jtot_object1_code
  --
  AND sts.code              = cle.sts_code
  AND sts.ste_code          <> g_sts_terminated
  --
  AND cle.cle_id            = b_line_id       -- immediate child of top line
  AND cle.dnz_chr_id        = b_chr_id;

--
-- cursor to get customer information
-- header level customers only
-- the customer is the role in the sell contract that is not me
-- this assumption will not hold as more roles get added post 11i
-- IF for a party, this should be party id, not cust account id
--

CURSOR c_cust (b_chr_id NUMBER) IS SELECT
   cpr.id
  ,cpr.jtot_object1_code
  ,cpr.object1_id1
  ,cpr.object1_id2
  ,cpr.rle_code
FROM okc_k_party_roles_b cpr
    ,okc_role_sources  rsc
WHERE
      rsc.buy_or_sell  = 'S'              -- sell contract
  AND rsc.rle_code     = cpr.rle_code     -- role
  AND rsc.start_date   <= sysdate
  AND NVL(rsc.end_date, sysdate) >= sysdate
  AND cpr.cle_id       IS NULL            -- parties
  AND cpr.dnz_chr_id   = b_chr_id;
--   AND cpr.jot.object1_code <> g_okx_legentity;
--and cpr.jot.object1_code <> g_okx_operunit  -- not me


--
-- cursor to see if contract is governed by another contract
--
CURSOR c_hdr_subject_to (b_chr_id NUMBER) IS
SELECT chr_id_referred
FROM okc_governances
WHERE dnz_chr_id = b_chr_id;

--
-- cursor to select contract comments to update with quote/order information
--
CURSOR c_k_header_tl (b_chr_id NUMBER) IS
SELECT
	   khtl.ID,
	   khtl.COMMENTS
FROM okc_k_headers_v  khtl
WHERE khtl.ID = b_chr_id;
--FOR UPDATE OF khtl.COMMENTS;

CURSOR	c_k_top_line_styles(b_scs_code VARCHAR2) IS
select 	distinct(lse.lty_code) lty_code,
	lse.priced_yn,
	lse.item_to_price_yn,
	lse.price_basis_yn,
	lse.id,
	lse.name,
	jot.object_code,
	jot.where_clause,
	jot.from_table
--	stl.seeded_flag
from	okc_subclass_top_line stl,
	okc_line_styles_v 	lse,
	okc_line_style_sources lss,
	jtf_objects_b		jot
where
	jot.object_code = lss.jtot_object_code
and	lss.lse_id = lse.id
and	sysdate between lss.start_date and nvl(lss.end_date,sysdate)
and	lse.id = stl.lse_id
and	sysdate between stl.start_date and nvl(stl.end_date,sysdate)
-- and	stl.seeded_flag = 'Y'
and	stl.scs_code = b_scs_code;


TYPE line_style_rec_type IS RECORD(
	lty_code 	okc_line_styles_v.lty_code%type,
	priced_yn 	okc_line_styles_v.priced_yn%type,
	item_to_price_yn okc_line_styles_v.item_to_price_yn%type,
	price_basis_yn	okc_line_styles_v.price_basis_yn%type,
	lse_id 		okc_line_styles_v.id%type,
	lse_name 	okc_line_styles_v.name%type,
	object_code 	jtf_objects_b.object_code%type,
	where_clause 	jtf_objects_b.where_clause%type,
	from_table 	jtf_objects_b.from_table%type
--	seeded_flag	okc_subclass_top_line.seeded_flag%TYPE
	);

TYPE line_style_tab  IS TABLE OF line_style_rec_type INDEX BY BINARY_INTEGER;
l_line_style_tab line_style_tab;


--
-- cursor to get header rule information related to the customer
--
CURSOR c_rules(b_chr_id NUMBER,
		b_cle_id NUMBER,
		b_cpr_id NUMBER) IS
SELECT
        rgp.chr_id,
        rgp.cle_id,
	rul.object1_id1,
	rul.object1_id2,
	rul.jtot_object1_code,
	rul.object2_id1,
	rul.object2_id2,
	rul.jtot_object2_code,
	rul.object3_id1,
	rul.object3_id2,
	rul.jtot_object3_code,
	rul.rule_information_category
FROM
	okc_rule_groups_b	rgp
	,okc_rules_b		rul
  --	,okc_rg_party_roles 	rpr
WHERE
  -- Since only one party is allowed in a contract, the party who is acting
  -- as the subject or object of a rule group is not handled
  --rpr.cpl_id             = b_cpr_id
  --AND rpr.rgp_id         = rgp.id
  --AND rpr.dnz_chr_id     = rgp.dnz_chr_id
  rgp.dnz_chr_id         = b_chr_id
  AND ((rgp.cle_id IS NULL AND b_cle_id IS NULL) OR
			(b_cle_id IS NOT NULL AND rgp.cle_id = b_cle_id))
 --  AND rgp.rgd_code     in (g_rg_billing, g_rg_service, g_rg_pricing)
  AND rul.rgp_id         = rgp.id
  AND rul.rule_information_category IN (
                                        g_rd_billto,
                                        g_rd_shipto,
					g_rd_shipmtd,
                                        g_rd_custacct,
                                        g_rd_invrule,
                                        g_rd_price,
                                        g_rd_convert);

--
-- Cursor to select the contract to quote relationship object id.
--

CURSOR 	c_q_k_rel(b_kh_id NUMBER, b_kl_id NUMBER, b_qh_id NUMBER,
				b_rlt_code VARCHAR, b_rlt_type VARCHAR) IS
	SELECT
		krel.object1_id1
	FROM
		okc_k_rel_objs krel
	WHERE
		krel.chr_id = b_kh_id
	AND	((krel.cle_id IS NULL AND b_kl_id IS NULL
			AND krel.object1_id1 = DECODE(NVL(b_qh_id,OKC_API.G_MISS_NUM),OKC_API.G_MISS_NUM, krel.object1_id1, b_qh_id))
               	OR (b_kl_id IS NOT NULL AND krel.cle_id = b_kl_id))
	AND	krel.rty_code = b_rlt_code
	AND	krel.jtot_object1_code = b_rlt_type;


--
-- global type declarations
--
TYPE line_info_rec_typ IS RECORD (
    line_id           		okc_k_lines_v.id%TYPE
   ,cle_id            		okc_k_lines_v.cle_id%TYPE
   ,lse_id	      		okc_k_lines_v.lse_id%TYPE
   ,line_number       		okc_k_lines_v.line_number%TYPE
   ,status_code       		okc_statuses_b.ste_code%TYPE
   --
   ,qty               		okc_k_items.number_of_items%TYPE
   ,uom_code          		okc_k_items.uom_code%TYPE
   ,customer_order_enabled_flag VARCHAR2(1)
   ,item_name         		okc_k_lines_v.name%TYPE
   --,item_name         	VARCHAR2(150)
   ,priced_item_yn    		okc_k_items.priced_item_yn%TYPE
   ,price_unit        		okc_k_lines_v.price_unit%TYPE
   ,price_negotiated  		okc_k_lines_v.price_negotiated%TYPE
   ,line_list_price   		okc_k_lines_v.line_list_price%TYPE
   ,price_list_id      		okc_k_lines_v.price_list_id%TYPE
   ,price_list_line_id 		okc_k_lines_v.price_list_line_id%TYPE
   ,currency_code     		okc_k_lines_v.currency_code%TYPE
   --
   ,config_header_id	   	okc_k_lines_v.config_header_id%TYPE
   ,config_revision_number 	okc_k_lines_v.config_revision_number%TYPE
   ,config_complete_yn     	okc_k_lines_v.config_complete_yn%TYPE
   ,config_valid_yn        	okc_k_lines_v.config_valid_yn%TYPE
   ,config_item_id         	okc_k_lines_v.config_item_id%TYPE
   ,config_item_type       	okc_k_lines_v.config_item_type%TYPE
   ,component_code         	okx_config_items_v.component_code%TYPE
   --
   ,start_date        		okc_k_lines_v.start_date%TYPE
   ,end_date          		okc_k_lines_v.end_date%TYPE
   ,k_item_id         		okc_k_items.id%TYPE
   ,object_id1        		okc_k_items.object1_id1%TYPE
   ,object_id2        		okc_k_items.object1_id2%TYPE
   --
   ,line_style        		okc_line_styles_b.lse_type%TYPE
   ,line_type         		okc_line_styles_b.lty_code%TYPE
   ,line_source_code  		okc_line_style_sources.jtot_object_code%TYPE
   ,line_source_table 		jtf_objects_b.from_table%TYPE
   --
   ,item_source_code  		okc_k_items.jtot_object1_code%TYPE
   ,item_source_table 		jtf_objects_b.from_table%TYPE
   );

TYPE line_info_tab_typ IS TABLE OF line_info_rec_typ INDEX BY BINARY_INTEGER;
TYPE line_info_ren_typ_dnr IS TABLE OF okc_k_lines_b.id%TYPE INDEX BY BINARY_INTEGER;


TYPE covlvl_info_rec_typ IS RECORD (
    line_tab_idx      binary_integer
   ,line_id           okc_k_lines_b.id%TYPE
   ,line_number       okc_k_lines_b.line_number%TYPE
   ,status_code       okc_statuses_b.ste_code%TYPE
   --
   ,qty               okc_k_items.number_of_items%TYPE
   ,uom_code          okc_k_items.uom_code%TYPE
   ,priced_item_yn    okc_k_items.priced_item_yn%TYPE
   ,price_unit        okc_k_lines_b.price_unit%TYPE
   ,price_negotiated  okc_k_lines_b.price_negotiated%TYPE
   ,currency_code     okc_k_lines_b.currency_code%TYPE
   --
   ,start_date        okc_k_lines_b.start_date%TYPE
   ,end_date          okc_k_lines_b.end_date%TYPE
   --
   ,line_style        okc_line_styles_b.lse_type%TYPE
   ,line_type         okc_line_styles_b.lty_code%TYPE
   ,line_source_code  jtf_objects_b.object_code%TYPE
   ,line_source_table jtf_objects_b.from_table%TYPE
   --
   ,id1               okc_k_items.object1_id1%TYPE
   ,id2               okc_k_items.object1_id2%TYPE
   ,prod_name         okx_system_items_v.name%TYPE
   ,item_source_code  jtf_objects_b.object_code%TYPE
   ,item_source_table jtf_objects_b.from_table%TYPE
   --
   ,svc_duration      okx_quote_line_detail_v.service_duration%TYPE
   ,svc_period        okx_quote_line_detail_v.service_period%TYPE
   );

TYPE covlvl_info_tab_typ IS TABLE OF covlvl_info_rec_typ INDEX BY BINARY_INTEGER;

--
-- type declaration for table to hold the list of line types that
-- can become lines on a quote or an order with detail lines (covered lines)
--
TYPE line_with_cover_prod_tab_type IS TABLE OF FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE INDEX BY BINARY_INTEGER;

--
-- table to hold the rules at a contract header level
--
TYPE rule_rec_typ IS RECORD
  (
    chr_id                          okc_k_headers_b.id%TYPE,
    cle_id                          okc_k_lines_b.id%TYPE,
    object1_id1                     okc_rules_b.object1_id1%TYPE
   ,object1_id2                     okc_rules_b.object1_id2%TYPE
   ,jtot_object1_code               okc_rules_b.jtot_object1_code%TYPE
   ,object2_id1                     okc_rules_b.object2_id1%TYPE
   ,object2_id2                     okc_rules_b.object2_id2%TYPE
   ,jtot_object2_code               okc_rules_b.jtot_object2_code%TYPE
   ,object3_id1                     okc_rules_b.object3_id1%TYPE
   ,object3_id2                     okc_rules_b.object3_id2%TYPE
   ,jtot_object3_code               okc_rules_b.jtot_object3_code%TYPE
   ,rule_information_category       okc_rules_b.rule_information_category%TYPE
  );

TYPE rule_tbl_typ IS TABLE OF rule_rec_typ INDEX BY BINARY_INTEGER;

l_kh_rule_tab              rule_tbl_typ;	-- Renamed from l_rule_tab (header level rules)
l_kl_rule_tab              rule_tbl_typ;	-- added (line level rules)


TYPE bto_sto_rec_typ IS RECORD
  (
	chr_id                    okc_k_headers_b.id%TYPE,
	cle_id                    okc_k_lines_b.id%TYPE,
      --
	party_site_id      okx_cust_site_uses_v.party_site_id%TYPE,
	cust_acct_id       okx_cust_site_uses_v.cust_account_id%TYPE,
	party_id           okx_cust_site_uses_v.party_id%TYPE,
	address1           okx_cust_site_uses_v.address1%TYPE,
	address2           okx_cust_site_uses_v.address2%TYPE,
	address3           okx_cust_site_uses_v.address3%TYPE,
	address4           okx_cust_site_uses_v.address4%TYPE,
	city               okx_cust_site_uses_v.city%TYPE,
	postal_code        okx_cust_site_uses_v.postal_code%TYPE,
	state              okx_cust_site_uses_v.state%TYPE,
	province           okx_cust_site_uses_v.province%TYPE,
	county             okx_cust_site_uses_v.county%TYPE,
	country            okx_cust_site_uses_v.country%TYPE);


TYPE l_k_bto_sto_data_tab_typ IS TABLE OF bto_sto_rec_typ INDEX BY BINARY_INTEGER;


-- Tables to hold bill to and ship to information at the header level

l_kh_bto_data_tab l_k_bto_sto_data_tab_typ;
l_kh_sto_data_tab l_k_bto_sto_data_tab_typ;


-- Tables to hold bill to and ship to information at the line level

l_kl_bto_data_tab l_k_bto_sto_data_tab_typ;
l_kl_sto_data_tab l_k_bto_sto_data_tab_typ;

--
-- global variables
--
l_chr           c_chr%ROWTYPE;
l_k_nbr         VARCHAR2(2000);        -- contract number plus modifier

l_qhr		c_qhr%ROWTYPE;
l_q_nbr		VARCHAR2(2000);		-- Quote Number with version

--
l_line_with_cover_prod_qc_tab  	line_with_cover_prod_tab_type;
l_line_info_ren_typ_dnr 	line_info_ren_typ_dnr;


l_line_info_tab         line_info_tab_typ;
l_covlvl_info_tab       covlvl_info_tab_typ;

l_ktq_flag VARCHAR2(1) ;

p_rel_code okc_k_rel_objs.rty_code%TYPE ;

--
l_cust                  c_cust%ROWTYPE;
l_customer              c_cust%ROWTYPE;
l_st_cust_acct_id       okx_cust_site_uses_v.cust_account_id%TYPE;  -- cust acct id holder
l_st_party_site_id      okx_cust_site_uses_v.party_site_id%TYPE;    -- bill to site id holder
l_st_party_id           okx_cust_site_uses_v.party_id%TYPE;         -- bill to party id holder
l_st_address1           okx_cust_site_uses_v.address1%TYPE;         -- address
l_st_address2           okx_cust_site_uses_v.address2%TYPE;         -- address
l_st_address3           okx_cust_site_uses_v.address3%TYPE;         -- address
l_st_address4           okx_cust_site_uses_v.address4%TYPE;         -- address
l_st_city               okx_cust_site_uses_v.city%TYPE;             -- city
l_st_postal_code        okx_cust_site_uses_v.postal_code%TYPE;      -- postal_code
l_st_state              okx_cust_site_uses_v.state%TYPE;            -- state
l_st_province           okx_cust_site_uses_v.province%TYPE;         -- province
l_st_county             okx_cust_site_uses_v.county%TYPE;           -- county
l_st_country            okx_cust_site_uses_v.country%TYPE;          -- country
l_bt_cust_acct_id       okx_cust_site_uses_v.cust_account_id%TYPE;  -- cust acct id holder
l_bt_party_site_id      okx_cust_site_uses_v.party_site_id%TYPE;    -- bill to site id holder
l_bt_party_id           okx_cust_site_uses_v.party_id%TYPE;         -- bill to party id holder
l_exchange_type	    	okc_conversion_attribs_v.conversion_type%TYPE;
l_exchange_rate	    	okc_conversion_attribs_v.conversion_rate%TYPE;
l_exchange_date	    	okc_conversion_attribs_v.conversion_date%TYPE;


PROCEDURE create_quote_from_k( p_api_version     IN NUMBER
                              ,p_init_msg_list   IN VARCHAR2
                              ,x_return_status   OUT NOCOPY VARCHAR2
                              ,x_msg_count       OUT NOCOPY NUMBER
                              ,x_msg_data        OUT NOCOPY VARCHAR2
						--
                              ,p_contract_id     IN  okc_k_headers_b.ID%TYPE
			      ,p_rel_type        IN  okc_k_rel_objs.rty_code%TYPE
						--
			      ,p_trace_mode      IN  VARCHAR2
                              ,x_quote_id        OUT NOCOPY okx_quote_headers_v.id1%TYPE
						)
                              IS
BEGIN

  NULL;

END create_quote_from_k;



  -----------------------------------------------------------------------------
  -- Procedure:           print_error
  -- Returns:
  -- Purpose:             Print the last error which occured
  -- In Parameters:       pos    position on the line to print the message
  -- Out Parameters:

PROCEDURE print_error(pos IN NUMBER) IS
       x_msg_count NUMBER;
       x_msg_data  VARCHAR2(1000);
  BEGIN
     IF okc_util.l_trace_flag OR okc_util.l_log_flag THEN
           FND_MSG_PUB.Count_And_Get ( p_count       =>      x_msg_count,
				       p_data          =>         x_msg_data
                                      );
           IF (l_debug = 'Y') THEN
              okc_util.print_trace(pos, '==EXCEPTION=================');
           END IF;
           x_msg_data := fnd_msg_pub.get( p_msg_index => x_msg_count,
                                          p_encoded   => 'F'
				        );
           IF (l_debug = 'Y') THEN
              okc_util.print_trace(pos, 'Message      : '||x_msg_data);
              okc_util.print_trace(pos, '============================');
           END IF;
      END IF;
   END print_error;

------------------------------------------------------------------------------------
-- Procedure:           build_k_rules
-- Purpose:             Builds the header and topline rules by ensuring that
--                      the occurance of any rule doesnot happen more
--			than once per top line.
--
-- In Parameters:       p_chr_id	Contract_header id
-- 			p_cle_id	topline id
--
-- Out Parameters:      x_return_status Return status of the rules check
--			x_rule_tab      Table of rule info except shipto and billto
--			x_bto_data_tab  Table of billto rule info
--			x_sto_data_tab  Table of shipto rule info
--
PROCEDURE build_k_rules( p_chr_id 	 IN okc_k_headers_b.ID%TYPE,
			 p_cle_id 	 IN okc_k_lines_v.id%TYPE,
			 x_rule_tab 	 OUT NOCOPY rule_tbl_typ,
			 x_bto_data_rec  OUT NOCOPY bto_sto_rec_typ,
			 x_sto_data_rec  OUT NOCOPY bto_sto_rec_typ,
			 x_return_status OUT NOCOPY VARCHAR2 ) IS

-- get party site id for a customer account site id
--
CURSOR c_party_site (b_id1 VARCHAR2, b_id2 VARCHAR2) IS
SELECT
	party_site_id
      	,cust_account_id
	,party_id
        ,address1
        ,address2
        ,address3
        ,address4
        ,city
        ,state
        ,province
        ,postal_code
        ,county
        ,country
FROM okx_cust_site_uses_v
WHERE id1 = b_id1
AND   id2 = b_id2;

--
l_party_site	  c_party_site%ROWTYPE;

-- get exchange information
--
CURSOR c_conv_type (b_id1 VARCHAR2, b_id2 VARCHAR2) IS
SELECT conversion_type,
       conversion_rate,
       conversion_date
FROM   okc_conversion_attribs_v
WHERE  conversion_type = b_id1
AND    dnz_chr_id = p_chr_id;

e_exit            EXCEPTION;
l_rd_nb           NUMBER;
l_rd_custacct_nb  NUMBER;
l_rd_price_nb     NUMBER;
l_rd_invrule_nb   NUMBER;
l_rd_billto_nb    NUMBER;
l_rd_shipto_nb    NUMBER;
l_rd_shipmtd_nb   NUMBER;
l_rd_convert_nb   NUMBER;

l_lines           NUMBER;
l_idx		  INTEGER;

l_sto_data_rec	  bto_sto_rec_typ;
l_bto_data_rec	  bto_sto_rec_typ;
l_k_rule_tab	  rule_tbl_typ;

BEGIN

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(3, ' ');
     okc_util.print_trace(3, '------------------- ');
     okc_util.print_trace(3, 'START BUILD_K_RULES');
     okc_util.print_trace(3, '------------------- ');
     okc_util.print_trace(3, ' ');
  END IF;

  l_sto_data_rec := NULL;
  l_bto_data_rec := NULL;
  l_k_rule_tab.delete;

  l_st_party_id      := null;
  l_st_party_site_id := null;
  l_st_cust_acct_id  := null;
  l_bt_party_id      := null;
  l_bt_party_site_id := null;
  l_bt_cust_acct_id  := null;


  IF (l_debug = 'Y') THEN
     okc_util.print_trace(3, '      ');
     okc_util.print_trace(3, 'Rules:');
     okc_util.print_trace(3, '=======');
  END IF;
  l_idx := 0;
  l_rd_nb := 0;
  l_rd_custacct_nb := 0;
  l_rd_price_nb := 0;
  l_rd_invrule_nb := 0;
  l_rd_billto_nb := 0;
  l_rd_shipto_nb := 0;
  l_rd_shipmtd_nb := 0;
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(3, '-->Rule selection');
  END IF;

  FOR r_rule IN c_rules(p_chr_id, p_cle_id, l_cust.id) LOOP
   IF p_cle_id IS NULL THEN
    IF r_rule.rule_information_category = g_rd_custacct THEN
      IF l_rd_custacct_nb = 1 THEN
         OKC_API.set_message(p_app_name   => g_app_name1,
                          p_msg_name      => 'OKO_K2Q_RULEOCC',
                          p_token1        => 'RULE',
                          p_token1_value  => g_rd_custacct,
                          p_token2        => 'KNUMBER',
                          p_token2_value  => l_k_nbr);
         x_return_status := OKC_API.G_RET_STS_ERROR;
	    print_error(4);
         RAISE e_exit;
      ELSE
	    l_rd_custacct_nb := l_rd_custacct_nb + 1;
	    l_rd_nb:=l_rd_nb+1;
         IF (l_debug = 'Y') THEN
            okc_util.print_trace(4, '-->Rule selected: '||g_rd_custacct);
         END IF;
      END IF;
      IF (l_debug = 'Y') THEN
         okc_util.print_trace(5, '   Cust Acct Id: '||r_rule.object1_id1);
      END IF;
    END IF;
   END IF;

    IF r_rule.rule_information_category = g_rd_price THEN
      IF l_rd_price_nb = 1 THEN
         OKC_API.set_message(p_app_name   => g_app_name1,
                          p_msg_name      => 'OKO_K2Q_RULEOCC',
                          p_token1        => 'RULE',
                          p_token1_value  => g_rd_price,
                          p_token2        => 'KNUMBER',
                          p_token2_value  => l_k_nbr);
         x_return_status := OKC_API.G_RET_STS_ERROR;
	    print_error(4);
         RAISE e_exit;
      ELSE
	    l_rd_price_nb := l_rd_price_nb + 1;
	    l_rd_nb:=l_rd_nb+1;
         IF (l_debug = 'Y') THEN
            okc_util.print_trace(4, '-->Rule selected: '||g_rd_price);
         END IF;
      END IF;
      IF (l_debug = 'Y') THEN
         okc_util.print_trace(5, '   Price List Id: '||r_rule.object1_id1);
      END IF;
    END IF;


    IF r_rule.rule_information_category = g_rd_invrule THEN
      IF l_rd_invrule_nb = 1 THEN
         OKC_API.set_message(p_app_name   => g_app_name1,
                          p_msg_name      => 'OKO_K2Q_RULEOCC',
                          p_token1        => 'RULE',
                          p_token1_value  => g_rd_invrule,
                          p_token2        => 'KNUMBER',
                          p_token2_value  => l_k_nbr);
         x_return_status := OKC_API.G_RET_STS_ERROR;
	    print_error(4);
         RAISE e_exit;
      ELSE
	    l_rd_invrule_nb := l_rd_invrule_nb + 1;
	    l_rd_nb:=l_rd_nb+1;
         IF (l_debug = 'Y') THEN
            okc_util.print_trace(4, '-->Rule selected: '||g_rd_invrule);
         END IF;
      END IF;
      IF (l_debug = 'Y') THEN
         okc_util.print_trace(5, '   Inv Rule Id: '||r_rule.object1_id1);
      END IF;
    END IF;

  IF p_cle_id IS NULL THEN
    IF r_rule.rule_information_category = g_rd_convert THEN
      IF l_rd_convert_nb = 1 THEN
         OKC_API.set_message(p_app_name   => g_app_name1,
                          p_msg_name      => 'OKO_K2Q_RULEOCC',
                          p_token1        => 'RULE',
                          p_token1_value  => g_rd_convert,
                          p_token2        => 'KNUMBER',
                          p_token2_value  => l_k_nbr);
         x_return_status := OKC_API.G_RET_STS_ERROR;
	    print_error(4);
         RAISE e_exit;
      ELSE
         OPEN c_conv_type(r_rule.object1_id1, r_rule.object1_id2);
         FETCH c_conv_type INTO l_exchange_type,
                                l_exchange_rate,
                                l_exchange_date;
         CLOSE c_conv_type;

         IF (l_debug = 'Y') THEN
            okc_util.print_trace(4, '-->Rule selected: '||g_rd_convert);
            okc_util.print_trace(5, '   Exchange type code     = '||l_exchange_type);
            okc_util.print_trace(5, '   Exchange rate          = '||l_exchange_rate);
            okc_util.print_trace(5, '   Exchange rate date     = '||l_exchange_date);
         END IF;
	    l_rd_convert_nb := l_rd_convert_nb + 1;
	    l_rd_nb:=l_rd_nb+1;
      END IF;
    END IF;
  END IF;

    IF r_rule.rule_information_category = g_rd_shipto THEN
      IF l_rd_shipto_nb = 1 THEN
         OKC_API.set_message(p_app_name   => g_app_name1,
                          p_msg_name      => 'OKO_K2Q_RULEOCC',
                          p_token1        => 'RULE',
                          p_token1_value  => g_rd_shipto,
                          p_token2        => 'KNUMBER',
                          p_token2_value  => l_k_nbr);
         x_return_status := OKC_API.G_RET_STS_ERROR;
	    print_error(4);
         RAISE e_exit;
      ELSE
         OPEN c_party_site(r_rule.object1_id1, r_rule.object1_id2);
         FETCH c_party_site INTO l_party_site;

	 IF c_party_site%FOUND THEN

		l_sto_data_rec.chr_id 		:= p_chr_id;
		l_sto_data_rec.party_site_id	:= l_party_site.party_site_id;
        	l_sto_data_rec.cust_acct_id 	:= l_party_site.cust_account_id;
        	l_sto_data_rec.party_id  	:= l_party_site.party_id;
        	l_sto_data_rec.address1  	:= l_party_site.address1;
        	l_sto_data_rec.address2  	:= l_party_site.address2;
        	l_sto_data_rec.address3  	:= l_party_site.address3;
        	l_sto_data_rec.address4  	:= l_party_site.address4;
        	l_sto_data_rec.city       	:= l_party_site.city;
        	l_sto_data_rec.state      	:= l_party_site.state;
        	l_sto_data_rec.province   	:= l_party_site.province;
        	l_sto_data_rec.postal_code	:= l_party_site.postal_code;
        	l_sto_data_rec.county     	:= l_party_site.county;
        	l_sto_data_rec.country    	:= l_party_site.country;

                l_st_party_site_id 		:= l_party_site.party_site_id;
                l_st_cust_acct_id  		:= l_party_site.cust_account_id;
                l_st_party_id      		:= l_party_site.party_id;

	     IF p_cle_id IS NULL THEN   -- Header level rule info
		l_sto_data_rec.cle_id := null;
	     ELSE			-- Line  level rule info
		l_sto_data_rec.cle_id := p_cle_id;
	     END IF;

	 END IF;

         CLOSE c_party_site;

         IF (l_debug = 'Y') THEN
            okc_util.print_trace(4, '-->Rule selected: '||g_rd_shipto);
            okc_util.print_trace(5, '   Party_site_id (STO) = '||l_st_party_site_id);
            okc_util.print_trace(5, '   Cust Acct Id  (STO) = '||l_st_cust_acct_id);
            okc_util.print_trace(5, '   Party Id      (STO) = '||l_st_party_id);
         END IF;
	    l_rd_shipto_nb := l_rd_shipto_nb + 1;
	    l_rd_nb:=l_rd_nb+1;
      END IF;
    END IF;

    IF r_rule.rule_information_category = g_rd_shipmtd THEN
      IF l_rd_shipmtd_nb = 1 THEN
         OKC_API.set_message(p_app_name   => g_app_name1,
                          p_msg_name      => 'OKO_K2Q_RULEOCC',
                          p_token1        => 'RULE',
                          p_token1_value  => g_rd_shipmtd,
                          p_token2        => 'KNUMBER',
                          p_token2_value  => l_k_nbr);
         x_return_status := OKC_API.G_RET_STS_ERROR;
	    print_error(4);
         RAISE e_exit;
      ELSE
	    l_rd_shipmtd_nb := l_rd_shipmtd_nb + 1;
	    l_rd_nb:=l_rd_nb+1;
      END IF;
    END IF;

    IF r_rule.rule_information_category = g_rd_billto THEN
      IF l_rd_billto_nb = 1 THEN
         OKC_API.set_message(p_app_name   => g_app_name1,
                          p_msg_name      => 'OKO_K2Q_RULEOCC',
                          p_token1        => 'RULE',
                          p_token1_value  => g_rd_billto,
                          p_token2        => 'KNUMBER',
                          p_token2_value  => l_k_nbr);
         x_return_status := OKC_API.G_RET_STS_ERROR;
	    print_error(4);
         RAISE e_exit;
      ELSE
      -- need to fix bill to, since ASO wants the party site, not customer acct site
         OPEN c_party_site(r_rule.object1_id1, r_rule.object1_id2);
         FETCH c_party_site INTO l_party_site;

	  IF c_party_site%FOUND THEN
		l_bto_data_rec.chr_id 		:= p_chr_id;
		l_bto_data_rec.party_site_id	:= l_party_site.party_site_id;
        	l_bto_data_rec.cust_acct_id 	:= l_party_site.cust_account_id;
--       	l_bto_data_rec.party_id		:= l_party_site.party_id;

		l_bt_party_site_id 		:= l_party_site.party_site_id;
		l_bt_cust_acct_id  		:= l_party_site.cust_account_id;
--		l_bt_party_id	   		:= l_party_site.party_id;

	     IF p_cle_id IS NULL THEN   -- Header level rule info
		l_bto_data_rec.cle_id 	:= null;
	     ELSE
		l_bto_data_rec.cle_id 	:= p_cle_id;
	     END IF;
	  END IF;

         CLOSE c_party_site;

         IF (l_debug = 'Y') THEN
            okc_util.print_trace(4, '-->Rule selected: '||g_rd_billto);
            okc_util.print_trace(5, '   Party_site_id (BTO) = '||l_bt_party_site_id);
            okc_util.print_trace(5, '   Cust Acct Id  (BTO) = '||l_bt_cust_acct_id);
            okc_util.print_trace(5, '   Party Id      (BTO) = '||l_bt_party_id);
         END IF;
         l_rd_billto_nb := l_rd_billto_nb + 1;
	 l_rd_nb:=l_rd_nb+1;
      END IF;
    END IF;

    l_idx := l_idx + 1;
    l_k_rule_tab(l_idx) := r_rule;

  END LOOP;

    x_sto_data_rec := l_sto_data_rec;
    x_bto_data_rec := l_bto_data_rec;
    x_rule_tab	   := l_k_rule_tab;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(3, '-->Rule selection: '||l_rd_nb||' rule(s) selected');
     okc_util.print_trace(3, '-->Return status '||x_return_status );
  END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(3, ' ');
     okc_util.print_trace(3, '------------------- ');
     okc_util.print_trace(3, ' END BUILD_K_RULES');
     okc_util.print_trace(3, '------------------- ');
     okc_util.print_trace(3, ' ');
  END IF;
EXCEPTION
  WHEN e_exit THEN
     IF c_party_site%ISOPEN THEN
        CLOSE c_party_site;
     END IF;

     IF c_conv_type%ISOPEN THEN
        CLOSE c_conv_type;
     END IF;

END build_k_rules;

-------------------------------------------------------------------------------
-- Function:            is_top_line_style_seeded
-- Returns:             Boolean
-- Purpose:             Determines if the contract top line is seeded
--                      To do so, it looks at the l_line_style_tab
--                      compares it to the line style id that is passed
--			and returns the boolean value along with the index
--			value of the l_line_style_tab
-- In Parameters:       p_lse_id  record of line information
-- Out Parameters:      x_index   Index value of the l_line_style_tab rec that
--			matches the line style id that is passed

FUNCTION is_top_line_style_seeded(p_lse_id IN okc_line_styles_b.id%TYPE,
					x_index OUT NOCOPY NUMBER) RETURN VARCHAR IS
l_retval  VARCHAR2(1):= OKC_API.G_FALSE;

BEGIN

  IF l_line_style_tab.first IS NOT NULL THEN
     FOR i in l_line_style_tab.first..l_line_style_tab.last LOOP
        IF l_line_style_tab(i).lse_id = p_lse_id THEN
		x_index := i;
           	l_retval := OKC_API.G_TRUE;
           EXIT;
        END IF;
     END LOOP;
  END IF;
  RETURN l_retval;
END is_top_line_style_seeded;

-------------------------------------------------------------------------------
-- Function:            is_top_line_with_covered_prod
-- Returns:             Boolean
-- Purpose:             Determines IF the contract line can be translated
--                      to a quote or an order line with detail lines.
--			To do so it checks the l_line_style_tab having an
--			object_code of  OKX_SERVICE
-- In Parameters:       p_lse_id
-- Out Parameters:      p_index

FUNCTION is_top_line_with_covered_prod(p_lse_id IN okc_line_styles_b.id%TYPE,
					p_index IN NUMBER DEFAULT OKC_API.G_MISS_NUM )
							 RETURN VARCHAR IS

l_retval  VARCHAR2(1):= OKC_API.G_FALSE;
BEGIN
  -- IF found, set return value to true AND exit loop
  -- IF not found, default value of return value is false

	IF NVL(p_index,OKC_API.G_MISS_NUM) <> OKC_API.G_MISS_NUM THEN
        	IF l_line_style_tab(p_index).object_code = g_okx_service THEN
           		l_retval := OKC_API.G_TRUE;
		END IF;
	ELSE
  	    IF l_line_style_tab.first IS NOT NULL THEN
		FOR i IN l_line_style_tab.first..l_line_style_tab.last LOOP
			IF l_line_style_tab(i).lse_id = p_lse_id AND
				l_line_style_tab(i).object_code = g_okx_service THEN
				l_retval := OKC_API.G_TRUE;
			     EXIT;
			END IF;
		END LOOP;
	    END IF;
  	END IF;
  RETURN l_retval;
END is_top_line_with_covered_prod;

-------------------------------------------------------------------------------
-- Function:            is_top_line_orderable_i
-- Returns:             Boolean
-- Purpose:             Determines if the contract top line can
--                      be translated to a quote or an order line,
--			by checking whether it is an orderable item
-- In Parameters:       	p_cust_ord_enabled_flag
--                      	p_lse_id
--				p_index
--

FUNCTION is_top_line_orderable_i(p_cust_ord_enabled_flag  IN VARCHAR2,
				   p_lse_id IN okc_line_styles_b.id%TYPE,
				   p_index IN NUMBER
				   ) RETURN VARCHAR IS

l_retval    VARCHAR2(1) := OKC_API.G_TRUE;
i	NUMBER;

BEGIN

  i := p_index;


  IF NVL(p_index,OKC_API.G_MISS_NUM) <> OKC_API.G_MISS_NUM THEN
	IF NOT( p_cust_ord_enabled_flag = 'Y' AND l_line_style_tab(i).priced_yn = 'Y'
		AND l_line_style_tab(i).item_to_price_yn = 'Y') THEN

/*			OKC_API.set_message(p_app_name  => g_app_name1,
                                        p_msg_name      => 'OKO_K2Q_TLNOTORDBLITM',
                                        p_token1        => 'CONTRACTNUM',
                                        p_token1_value  => l_k_nbr,
                                        p_token2        => 'LINESTYLEID',
                                        p_token2_value  => p_lse_id);		*/
		l_retval := OKC_API.G_FALSE;
	END IF;
  ELSE
 	FOR i IN l_line_style_tab.first..l_line_style_tab.last LOOP
		 IF l_line_style_tab(i).lse_id = p_lse_id THEN
			IF NOT ( p_cust_ord_enabled_flag = 'Y' AND l_line_style_tab(i).priced_yn = 'Y'
				AND  l_line_style_tab(i).item_to_price_yn = 'Y') THEN

/*			OKC_API.set_message(p_app_name  => g_app_name1,
                                        p_msg_name      => 'OKO_K2Q_TLNOTORDBLITM',
                                        p_token1        => 'CONTRACTNUM',
                                        p_token1_value  => l_k_nbr,
                                        p_token2        => 'LINESTYLEID',
                                        p_token2_value  => p_lse_id);		*/

				l_retval := OKC_API.G_FALSE;
			EXIT;
			END IF;
		END IF;
	END LOOP;
  END IF;
 RETURN l_retval;
END is_top_line_orderable_i;

-------------------------------------------------------------------------------
-- Function:            is_kl_linked_to_ql
-- Returns:             Boolean
-- Purpose:             Determines if the contract line is linked to quote line
-- In Parameters:       	p_chr_id
--                      	p_cle_id
--				p_qh_id
--				p_rlt_code
--				p_rlt_type
--
--
FUNCTION is_kl_linked_to_ql(p_chr_id IN NUMBER,
			   p_cle_id IN okc_k_lines_b.id%TYPE,
			   p_qh_id IN okx_quote_headers_v.id1%TYPE,
			   p_rlt_code IN VARCHAR2,
			   p_rlt_type IN VARCHAR2
			   ) RETURN VARCHAR2 IS

l_retval        VARCHAR2(1) := OKC_API.G_TRUE;
l_object_id1    okc_k_rel_objs.object1_id1%TYPE;

BEGIN
	OPEN c_q_k_rel(p_chr_id,p_cle_id,p_qh_id,p_rlt_code,p_rlt_type);
	FETCH c_q_k_rel INTO l_object_id1;
		IF c_q_k_rel%NOTFOUND THEN
			l_retval := OKC_API.G_FALSE;
		END IF;
	CLOSE c_q_k_rel;
 RETURN l_retval;
END is_kl_linked_to_ql;

-------------------------------------------------------------------------------
-- Procedure:           validate_k_eligibility
-- Purpose:             Check up on specific conditions to ensure the contract
--                      is elligible for a quote updation
--
-- In Parameters:       p_k_header_rec  contract information that has contract
--			id and contract category
--
-- Out Parameters:      x_return_status standard return status

PROCEDURE validate_k_eligibility( p_k_header_rec  IN c_k_header%ROWTYPE
				 ,p_quote_id	  IN okx_quote_headers_v.id1%TYPE
                                 ,x_return_status OUT NOCOPY VARCHAR2
                                 ) IS

--
-- Cursor to select the Quote's expiration date
--

CURSOR	c_qh_expiration(b_qh_id NUMBER) IS
SELECT	quote_expiration_date
FROM	okx_quote_headers_v
WHERE	id1 = b_qh_id;

e_exit           exception;
e_exit2          exception;
l_msg_count      NUMBER := 0;
l_msg_data       VARCHAR2(1000);
l_object_id1     okc_k_rel_objs.object1_id1%TYPE;
l_quot_exp_date  okx_quote_headers_v.quote_expiration_date%TYPE;


BEGIN

 IF (l_debug = 'Y') THEN
    OKC_UTIL.print_trace(1, ' ');
    OKC_UTIL.print_trace(1, '>START - OKC_OC_INT_KTQ_PVT.VALIDATE_K_ELIGIBILITY - Check up on specific contract conditions');
 END IF;

  IF (l_debug = 'Y') THEN
     OKC_UTIL.print_trace(1, ' ');
     OKC_UTIL.print_trace(1, 'The input quote id = '||p_quote_id);
     OKC_UTIL.print_trace(1, ' ');
     OKC_UTIL.print_trace(1, 'First contract validations: common general conditions');
     OKC_UTIL.print_trace(1, '--------------------------------------------------------');
     OKC_UTIL.print_trace(2, 'Checking on : contract category is KFORQUOTE');
  END IF;

  IF p_k_header_rec.scs_code = g_k_kfq_subclass THEN
	IF (l_debug = 'Y') THEN
   	OKC_UTIL.print_trace(2,'  ');
     	OKC_UTIL.print_trace(2, 'Checking on : relationship between contract and quote for which the');
   	OKC_UTIL.print_trace(2, '   code is CONTRACTISTERMSFORQUOTE and type is OKX_QUOTEHEAD');
   	OKC_UTIL.print_trace(2, ' ');
	END IF;

    OPEN c_q_k_rel(p_k_header_rec.id, null, p_quote_id, g_rlt_code_ktq, g_rlt_typ_qh);
    FETCH c_q_k_rel into l_object_id1;
       IF c_q_k_rel%NOTFOUND THEN
	  CLOSE c_q_k_rel;

	IF (l_debug = 'Y') THEN
   	OKC_UTIL.print_trace(2,'  ');
     	OKC_UTIL.print_trace(2, 'Checking on : relationship between contract and quote for which the');
   	OKC_UTIL.print_trace(2, '   code is CONTRACTNEGOTIATESQUOTE and type is OKX_QUOTEHEAD');
   	OKC_UTIL.print_trace(2, ' ');
	END IF;

		 OPEN c_q_k_rel(p_k_header_rec.id, null, p_quote_id, g_rlt_code_knq, g_rlt_typ_qh);
		 FETCH c_q_k_rel into l_object_id1;
		 IF c_q_k_rel%NOTFOUND OR l_object_id1 IS NULL THEN

 		    OKC_API.set_message(p_app_name  => g_app_name1,
               		p_msg_name      => 'OKO_K2Q_NORELBQK',
               		p_token1        => 'KNUMBER',
               		p_token1_value  => l_k_nbr,
               		p_token2        => 'QNUMBER',
               		p_token2_value  => l_q_nbr);

       	            x_return_status := OKC_API.G_RET_STS_ERROR;
  	 	    IF (l_debug = 'Y') THEN
     	 	    OKC_UTIL.print_trace(2, 'No relationship exists between the quote and the contract');
  	 	    END IF;
       	            print_error(3);
       	            RAISE e_exit;
                 ELSE
		    g_quote_id := l_object_id1;
		    IF (l_debug = 'Y') THEN
   		    okc_util.print_trace(2,'The fetched quote id = '||g_quote_id);
		    END IF;
	 	    x_return_status := OKC_API.G_RET_STS_SUCCESS;
		    p_rel_code := g_rlt_code_knq;
       		 END IF;
    		 CLOSE c_q_k_rel;
       ELSE
		IF l_object_id1 IS NULL THEN
                    OKC_API.set_message(p_app_name  => g_app_name1,
                        p_msg_name      => 'OKO_K2Q_NORELBQK',
                        p_token1        => 'KNUMBER',
                        p_token1_value  => l_k_nbr,
                        p_token2        => 'QNUMBER',
                        p_token2_value  => l_q_nbr);

                    x_return_status := OKC_API.G_RET_STS_ERROR;
                    IF (l_debug = 'Y') THEN
                       OKC_UTIL.print_trace(2, '2.No relationship exists between the quote and the contract');
                    END IF;
                    print_error(3);
                    RAISE e_exit;
		END IF;
		g_quote_id := l_object_id1;
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(2,'2.The fetched quote id = '||g_quote_id);
		END IF;
		l_ktq_flag := OKC_API.G_TRUE;
		p_rel_code := g_rlt_code_ktq;
       END IF;
  ELSE
 	OKC_API.set_message(p_app_name  => g_app_name1,
               		p_msg_name      => 'OKO_K2Q_INVCAT');

       	x_return_status := OKC_API.G_RET_STS_ERROR;
  	IF (l_debug = 'Y') THEN
     	OKC_UTIL.print_trace(2, 'The contract category doesnot belong to KFORQUOTE');
  	END IF;
	print_error(3);
	RAISE e_exit;
  END IF;


/*
-- Checking for the quote's expiration date

  IF (l_debug = 'Y') THEN
     OKC_UTIL.print_trace(1, 'Second contract validations: common general conditions');
     OKC_UTIL.print_trace(1, '--------------------------------------------------------');
     OKC_UTIL.print_trace(2, 'Checking on : Quote''s expiration date');
  END IF;

  OPEN c_qh_expiration(g_quote_id);
  FETCH c_qh_expiration INTO l_quot_exp_date;
    IF l_quot_exp_date IS NOT NULL AND TRUNC(SYSDATE) > TRUNC(l_quot_exp_date) THEN

 		OKC_API.set_message(p_app_name  => g_app_name1,
       			p_msg_name      => 'OKO_K2Q_QDATEXP',
       			p_token1        => 'QNUMBER',
               		p_token1_value  => l_q_nbr,
               		p_token2        => 'QUOTEXPDATE',
               		p_token2_value  =>  g_k_kfq_subclass);

       		x_return_status := OKC_API.G_RET_STS_ERROR;
  		IF (l_debug = 'Y') THEN
     		OKC_UTIL.print_trace(2, 'The quote has already expired');
  		END IF;
		print_error(3);
		RAISE e_exit;
    ELSE
	IF (l_debug = 'Y') THEN
   	OKC_UTIL.print_trace(2, 'checked for the quote''s expr date - the quote is still valid');
	END IF;
	x_return_status := OKC_API.G_RET_STS_SUCCESS;
    END IF;
  CLOSE c_qh_expiration;

	*/

EXCEPTION
  WHEN e_exit THEN
  	IF c_q_k_rel%ISOPEN THEN
	 	CLOSE c_q_k_rel;
	END IF;
  WHEN OTHERS THEN
	IF c_q_k_rel%ISOPEN THEN
                CLOSE c_q_k_rel;
        END IF;

     OKC_API.set_message(G_APP_NAME,		-- set the err mesg on the stack to be retrieved
			 G_UNEXPECTED_ERROR,    -- by the calling routine
			 G_SQLCODE_TOKEN,
			 SQLCODE,
			 G_SQLERRM_TOKEN,
			 SQLERRM);
   -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_k_eligibility;

-------------------------------------------------------------------------------
-- Procedure:           build_k_structures
-- Purpose:             Build several records/tables that hold information to be
--                      used to pass to ASO APIs
-- In Parameters:       p_chr_id            contract id
-- Out Parameters:      x_return_status     standard return status

PROCEDURE build_k_structures (p_chr_id  IN  okc_k_headers_b.ID%TYPE
		  --    ,p_quote_id	IN OKX_QUOTE_HEADERS_V.ID1%TYPE
		      ,p_rel_code       IN  okc_k_rel_objs.rty_code%TYPE
		      ,p_k_header_rec   IN c_k_header%ROWTYPE
                      ,x_return_status  OUT NOCOPY VARCHAR2
		       	     ) IS

CURSOR c_top_cle_init(b_chr_id NUMBER) IS
SELECT	cle.id		 line_id
	,cle.line_number line_number
FROM
	okc_k_lines_b cle
WHERE EXISTS ( 	SELECT 1
		FROM okc_statuses_b sts
		WHERE sts.code = cle.sts_code
		AND sts.ste_code <> g_sts_terminated )
AND (
      (cle.cle_id IS NULL AND cle.config_item_type NOT IN (g_okc_model_item,g_okc_base_item,g_okc_config_item))
			OR ( cle.config_item_type IN (g_okc_model_item,g_okc_base_item,g_okc_config_item))
    )
AND cle.dnz_chr_id = b_chr_id
ORDER BY cle.config_item_type DESC,	-- To ensure that top model line,top base line
	 line_id;			-- and config are processed in order


CURSOR c_top_cle(b_chr_id NUMBER,
		b_line_id NUMBER) IS
SELECT
--  b_line_level     	lv
   cle.id          	line_id
  ,cle.cle_id      	cle_id
  ,cle.lse_id		lse_id
  ,cle.line_number 	line_number
  ,sts.ste_code
  --
  ,cim.number_of_items qty
  ,cim.uom_code
  ,'N'                 customer_order_enabled_flag
  ,cle.name            item_name
  ,cim.priced_item_yn
  ,cle.price_unit
  ,cle.price_negotiated
  ,cle.line_list_price
  ,cle.price_list_id
  ,cle.price_list_line_id
  ,cle.currency_code
  --
  --
  ,cle.config_header_id
  ,cle.config_revision_number
  ,cle.config_complete_yn
  ,cle.config_valid_yn
  ,cle.config_item_id
  ,cle.config_item_type
  ,cfg.component_code
  --
  --
  ,cle.start_date
  ,cle.end_date
  ,cim.id cim_id
  ,cim.object1_id1
  ,cim.object1_id2
  --
  ,lse.lse_type         line_style
  ,lse.lty_code         line_type
  ,lss.jtot_object_code line_source_code
  ,jot2.from_table      line_source_table
  --
  ,cim.jtot_object1_code item_source_code
  ,jot.from_table        item_source_table
FROM
	okc_k_lines_v		cle,
	okc_k_items		cim,
	okc_line_styles_b 	lse,
	okc_line_style_sources 	lss,
	jtf_objects_b		jot,
	jtf_objects_b		jot2,
	okc_statuses_b		sts,
--	okx_system_items_v 	sit,
	okx_config_items_v	cfg
WHERE
	cim.cle_id = cle.id
AND	jot.object_code(+) = cim.jtot_object1_code
AND	lse.id = cle.lse_id
AND	lss.lse_id(+) = lse.id
AND	lss.jtot_object_code = jot2.object_code(+)
AND	sts.code = cle.sts_code
AND	cle.dnz_chr_id = b_chr_id
AND	cle.id = b_line_id
AND	cfg.config_hdr_id(+) = cle.config_header_id
AND	cfg.config_rev_nbr(+) = cle.config_revision_number
AND	cfg.config_item_id(+) = cle.config_item_id;


e_exit          exception;
l_idx           binary_integer;           -- generic table index
l_cp_idx        binary_integer;           -- index for cust prod cov lvl table
l_cp_ctr        integer;                  -- NUMBER of cp lines per service line
l_svc_duration  okx_quote_line_detail_v.service_duration%TYPE;
l_svc_period    okx_quote_line_detail_v.service_period%TYPE;
l_party           NUMBER;
l_lines           NUMBER;
l_nb_parties	  NUMBER;
l_nb_roles	  NUMBER;
l_legentity	  NUMBER;
l_prev_rle_code   okc_role_sources.rle_code%TYPE;
l_err_nb          NUMBER;
l_sql             VARCHAR2(2000);
l_item_name       VARCHAR2(150);
l_customer_order_enabled_flag VARCHAR2(1);
r_cle             line_info_rec_typ;
lx_return_status    VARCHAR2(1);
lx_index            NUMBER;
x_msg_count NUMBER;
x_msg_data  VARCHAR2(1000);


lx_kh_rule_tab		rule_tbl_typ;
lx_kl_rule_tab		rule_tbl_typ;

lx_kh_bto_data_rec	bto_sto_rec_typ;
lx_kh_sto_data_rec	bto_sto_rec_typ;

lx_kl_bto_data_rec	bto_sto_rec_typ;
lx_kl_sto_data_rec	bto_sto_rec_typ;


BEGIN


  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, ' ');
     okc_util.print_trace(1, '>START - OKC_OC_INT_KTQ_PVT.BUILD_K_STRUCTURES - Get contract information');
  END IF;

  --
  -- get contract header information
  -- already selected in STEP 1
  --

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(2, 'Contract Header:');
     okc_util.print_trace(2, '================');
     okc_util.print_trace(3, 'Org Id            = '||l_chr.authoring_org_id);
     okc_util.print_trace(3, 'Inv Org Id        = '||l_chr.inv_organization_id);
     okc_util.print_trace(3, 'Contract NUMBER   = '||l_chr.contract_number);
     okc_util.print_trace(3, 'Contract modifier = '||l_chr.contract_number_modifier);
     okc_util.print_trace(3, 'Currency code     = '||l_chr.currency_code);
     okc_util.print_trace(3, 'Estimated amount  = '||LTRIM(TO_CHAR(l_chr.estimated_amount, '9G999G999G990D00')));
  END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(3, ' ');
  END IF;
  --
  -- get customer information
  --

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(3, 'Party:');
     okc_util.print_trace(3, '=======');
  END IF;
  l_nb_parties:=0;
  l_nb_roles:=0;
  l_legentity:=0;
  l_party:=0;
  l_prev_rle_code:=NULL;
  FOR l_cust IN c_cust(p_chr_id) LOOP
     l_nb_parties:=l_nb_parties+1;
	IF l_cust.rle_code <> l_prev_rle_code OR l_prev_rle_code IS NULL THEN
	   l_prev_rle_code:=l_cust.rle_code;
	   l_nb_roles:=l_nb_roles+1;
        END IF;
	IF l_cust.jtot_object1_code <> g_okx_legentity THEN
	   l_party:=l_party+1;
	   l_customer:=l_cust;
        IF (l_debug = 'Y') THEN
           okc_util.print_trace(3, 'Party code        = '||l_cust.jtot_object1_code);
           okc_util.print_trace(3, 'Party_id1         = '||l_cust.object1_id1);
           okc_util.print_trace(3, 'Party_id2         = '||l_cust.object1_id2);
        END IF;
     ELSE
	   l_legentity:=l_legentity+1;
	END IF;
  END LOOP;

  IF l_nb_parties = 0 THEN
     OKC_API.set_message(p_app_name      => g_app_name1,
                         p_msg_name      => 'OKO_K2Q_NOCUSTDEF',
                         p_token1        => 'KNUMBER',
                         p_token1_value  => l_k_nbr);
     x_return_status := OKC_API.G_RET_STS_ERROR;
	print_error(4);
     RAISE e_exit;
  END IF;
  IF l_nb_parties > 2 THEN
     OKC_API.set_message(p_app_name      => g_app_name1,
                         p_msg_name      => 'OKO_K2Q_PARNUMLIMT',
                         p_token1        => 'KNUMBER',
                         p_token1_value  => l_k_nbr);
     x_return_status := OKC_API.G_RET_STS_ERROR;
	print_error(4);
     RAISE e_exit;
  END IF;
  IF l_nb_parties < 2 THEN
     OKC_API.set_message(p_app_name      => g_app_name1,
                         p_msg_name      => 'OKO_K2Q_PARNUMLIMT2',
                         p_token1        => 'KNUMBER',
                         p_token1_value  => l_k_nbr);
     x_return_status := OKC_API.G_RET_STS_ERROR;
	print_error(4);
     RAISE e_exit;
  END IF;
  IF l_nb_roles <> 2 THEN
     OKC_API.set_message(p_app_name      => g_app_name1,
                         p_msg_name      => 'OKO_K2Q_ROLEDEFN',
                         p_token1        => 'KNUMBER',
                         p_token1_value  => l_k_nbr);
     x_return_status := OKC_API.G_RET_STS_ERROR;
	print_error(4);
     RAISE e_exit;
  END IF;
  IF l_party <> 1 OR l_legentity <> 1 THEN
     OKC_API.set_message(p_app_name      => g_app_name1,
                         p_msg_name      => 'OKO_K2Q_PTYTYPE_MIS',
                         p_token1        => 'KNUMBER',
                         p_token1_value  => l_k_nbr);
     x_return_status := OKC_API.G_RET_STS_ERROR;
	print_error(4);
     RAISE e_exit;
  END IF;
  l_cust:=l_customer;

 --
 -- make sure global variables are clear
 --

  l_kh_rule_tab.delete;
  l_kl_rule_tab.delete;

  l_kh_sto_data_tab.delete;
  l_kh_bto_data_tab.delete;

  l_kl_sto_data_tab.delete;
  l_kl_bto_data_tab.delete;

  l_line_info_tab.delete;
  l_covlvl_info_tab.delete;

  --
  -- get header level rules related to this customer
  --

--   Make a call to the build_k_rules procedure to get
--   the header level rules
--
     IF (l_debug = 'Y') THEN
        okc_util.print_trace(3,'====================================');
        okc_util.print_trace(3,'Retrieving the rules at header level');
        okc_util.print_trace(3,'====================================');
     END IF;

	build_k_rules ( p_chr_id 	=> p_chr_id,
			p_cle_id 	=> NULL,
			x_rule_tab 	=> lx_kh_rule_tab,
			x_bto_data_rec 	=> lx_kh_bto_data_rec,
			x_sto_data_rec 	=> lx_kh_sto_data_rec,
			x_return_status => lx_return_status );


      IF lx_return_status = OKC_API.G_RET_STS_SUCCESS THEN

	IF lx_kh_rule_tab.FIRST IS NOT NULL THEN
	  l_kh_rule_tab := lx_kh_rule_tab;
	END IF;

	IF lx_kh_bto_data_rec.chr_id IS NOT NULL THEN
       	  l_kh_bto_data_tab(l_kh_bto_data_tab.COUNT+1):=   lx_kh_bto_data_rec;
	END IF;

	IF lx_kh_sto_data_rec.chr_id IS NOT NULL THEN
       	  l_kh_sto_data_tab(l_kh_sto_data_tab.COUNT+1):=   lx_kh_sto_data_rec;
	END IF;

      ELSE
	  raise e_exit;
      END IF;

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(3,'==============================================');
        okc_util.print_trace(3,'Completed retrieving the rules at header level');
        okc_util.print_trace(3,'==============================================');
     END IF;

  --
  -- get all the top lines in detail
  --

-- Initialize pl/sql table l_line_style_tab with all the valid top line styles

	l_line_style_tab.DELETE;
	l_idx := 1;

	FOR r_line_styles_rec IN c_k_top_line_styles(p_k_header_rec.scs_code) LOOP
		l_line_style_tab(l_idx):= r_line_styles_rec;
		l_idx := l_idx + 1;
	END LOOP;

  l_lines := 0;
  l_idx := 0;
  l_cp_idx := 0;
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(2, '===================');
     okc_util.print_trace(2, 'Contract Top Lines:');
     okc_util.print_trace(2, '===================');
  END IF;

  FOR r_cle_i IN c_top_cle_init(p_chr_id) LOOP
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(2,'>>Select contract line');
    END IF;

    OPEN c_top_cle(p_chr_id, r_cle_i.line_id);
    FETCH c_top_cle INTO r_cle;

    IF c_top_cle%NOTFOUND THEN
       OKC_API.set_message(
                      p_app_name      => g_app_name1,
                      p_msg_name      => 'OKO_K2Q_LINENOTORDBL1',
                      p_token1        => 'LINE_NUM',
                      p_token1_value  => r_cle_i.line_number,
                      p_token2        => 'KNUMBER',
                      p_token2_value  => l_k_nbr);
       print_error(2);
       RAISE e_exit;
    END IF;
    --
    -- select item name
    -- If no item source code, the item name is provided by the contract line
    --
    l_item_name :=r_cle.item_name;
    l_customer_order_enabled_flag := r_cle.customer_order_enabled_flag;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(2, '>>Select contract line product name');
    END IF;

    IF rtrim(ltrim(r_cle.item_source_code)) IS NOT NULL THEN
       IF rtrim(ltrim(r_cle.item_source_table)) NOT LIKE
		g_okx_system_items_v||'%'||r_cle.item_source_code THEN
	 BEGIN
        	l_sql:= 'SELECT name FROM '||r_cle.item_source_table ||' WHERE id1 = :b AND id2 = :c';
         	EXECUTE IMMEDIATE l_sql INTO l_item_name USING r_cle.object_id1, r_cle.object_id2;
         END;
       ELSE
	 BEGIN
             l_sql := 'SELECT name, customer_order_enabled_flag FROM '||r_cle.item_source_table||
						     ' WHERE id1 = :b AND id2 = :c';
             EXECUTE IMMEDIATE l_sql INTO l_item_name, l_customer_order_enabled_flag
		   	USING r_cle.object_id1,r_cle.object_id2;
         END;
       END IF;
    END IF;
    --
    l_lines:=l_lines+1;
    --
    --okc_util.print_trace(2,' ');
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(2,'--------------');
       okc_util.print_trace(2,'> Line_id         = '||r_cle.line_id);
       okc_util.print_trace(2,'Line NUMBER       = '||r_cle.line_number);
       okc_util.print_trace(2,'--------------');
       okc_util.print_trace(2,'Line style        = '||r_cle.line_style);
       okc_util.print_trace(2,'Line type         = '||r_cle.line_type);
       okc_util.print_trace(2,'Line source code  = '||r_cle.line_source_code);
       okc_util.print_trace(2,'Line source table = '||r_cle.line_source_table);
       okc_util.print_trace(2,'Item source code  = '||r_cle.item_source_code);
       okc_util.print_trace(2,'Item source table = '||r_cle.item_source_table);
       okc_util.print_trace(2,'Item id1          = '||r_cle.object_id1);
       okc_util.print_trace(2,'Item id2          = '||r_cle.object_id2);
    END IF;
  --okc_util.print_trace(2,'Item name         = '||r_cle.item_name);
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(2,'Item name         = '||l_item_name);
    END IF;
  --okc_util.print_trace(2,'Item Orderable    = '||r_cle.customer_order_enabled_flag);
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(2,'Item Orderable    = '||l_customer_order_enabled_flag);
       okc_util.print_trace(2,'Item Priced       = '||r_cle.priced_item_yn);
       okc_util.print_trace(2,'Quantity          = '||r_cle.qty);
       okc_util.print_trace(2,'UOM               = '||r_cle.uom_code);
       okc_util.print_trace(2,'Currency code     = '||r_cle.currency_code);
    END IF;
  --okc_util.print_trace(2,'Negot. price      = '||r_cle.price);
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(2,'Unit price        = '||LTRIM(TO_CHAR(r_cle.price_unit, '9G999G999G990D00')));
       okc_util.print_trace(2,'Start date        = '||r_cle.start_date);
       okc_util.print_trace(2,'End date          = '||r_cle.end_date);
    END IF;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(2,'Config header id  = '||r_cle.config_header_id);
       okc_util.print_trace(2,'config rev Num    = '||r_cle.config_revision_number);
       okc_util.print_trace(2,'Config item id    = '||r_cle.config_item_id);
       okc_util.print_trace(2,'Config complet yn = '||r_cle.config_complete_yn);
       okc_util.print_trace(2,'Config valid yn   = '||r_cle.config_valid_yn);
       okc_util.print_trace(2,'Component code    = '||r_cle.component_code);
       okc_util.print_trace(2,'Config item type  = '||r_cle.end_date);
    END IF;



   IF is_top_line_style_seeded(p_lse_id =>r_cle.lse_id,x_index =>lx_index) = OKC_API.G_TRUE THEN

     IF is_top_line_with_covered_prod(r_cle.lse_id,lx_index) = OKC_API.G_TRUE  THEN

	IF is_top_line_orderable_i(l_customer_order_enabled_flag,r_cle.lse_id,lx_index) = OKC_API.G_TRUE THEN

          l_idx := l_idx + 1;

          l_line_info_tab(l_idx) := r_cle;

	--
	-- At this point the line is a serviceable line, and no config_item_type is
	-- provided from the cursor (i.e the value is NULL ). Hence
	-- value of config_item_type is explicitly set to service
	--
	  l_line_info_tab(l_idx).config_item_type := g_okc_service_item;	-- 'SRV'

	  l_line_info_tab(l_idx).item_name := l_item_name;
	  l_line_info_tab(l_idx).customer_order_enabled_flag := l_customer_order_enabled_flag;



            IF (l_debug = 'Y') THEN
               okc_util.print_trace(2,'============================');
               okc_util.print_trace(2,'Contract line idx = '||l_idx);
               okc_util.print_trace(2,'============================');
            END IF;


            IF (l_debug = 'Y') THEN
               okc_util.print_trace(2,'--------------');
               okc_util.print_trace(2,'> Line_id          = '||l_line_info_tab(l_idx).line_id);
               okc_util.print_trace(2,'Line NUMBER        = '||l_line_info_tab(l_idx).line_number);
               okc_util.print_trace(2,'--------------');
               okc_util.print_trace(2,'Line style         = '||l_line_info_tab(l_idx).line_style);
               okc_util.print_trace(2,'Line type          = '||l_line_info_tab(l_idx).line_type);
               okc_util.print_trace(2,'Line source code   = '||l_line_info_tab(l_idx).line_source_code);
               okc_util.print_trace(2,'Line source table  = '||l_line_info_tab(l_idx).line_source_table);
               okc_util.print_trace(2,'Item source code   = '||l_line_info_tab(l_idx).item_source_code);
               okc_util.print_trace(2,'Item source table  = '||l_line_info_tab(l_idx).item_source_table);
               okc_util.print_trace(2,'Item id1           = '||l_line_info_tab(l_idx).object_id1);
               okc_util.print_trace(2,'Item id2           = '||l_line_info_tab(l_idx).object_id2);
               okc_util.print_trace(2,'Item name          = '||l_line_info_tab(l_idx).item_name);
               okc_util.print_trace(2,'Item Orderable     = '||l_line_info_tab(l_idx).customer_order_enabled_flag);
               okc_util.print_trace(2,'Item Priced        = '||l_line_info_tab(l_idx).priced_item_yn);
               okc_util.print_trace(2,'Quantity           = '||l_line_info_tab(l_idx).qty);
               okc_util.print_trace(2,'UOM                = '||l_line_info_tab(l_idx).uom_code);
               okc_util.print_trace(2,'Currency code      = '||l_line_info_tab(l_idx).currency_code);
               okc_util.print_trace(2,'Unit price         = '||LTRIM(TO_CHAR(l_line_info_tab(l_idx).price_unit, '9G999G999G990D00')));
            END IF;
          --okc_util.print_trace(2,'Negot. price       = '||l_line_info_tab(l_idx).price);
            IF (l_debug = 'Y') THEN
               okc_util.print_trace(2,'Start date         = '||l_line_info_tab(l_idx).start_date);
               okc_util.print_trace(2,'End date           = '||l_line_info_tab(l_idx).end_date);
            END IF;

    	    IF (l_debug = 'Y') THEN
       	    okc_util.print_trace(2,'Config header id   = '||l_line_info_tab(l_idx).config_header_id);
       	    okc_util.print_trace(2,'config rev Num     = '||l_line_info_tab(l_idx).config_revision_number);
       	    okc_util.print_trace(2,'Config item id     = '||l_line_info_tab(l_idx).config_item_id);
       	    okc_util.print_trace(2,'Config complet yn  = '||l_line_info_tab(l_idx).config_complete_yn);
       	    okc_util.print_trace(2,'Config valid yn    = '||l_line_info_tab(l_idx).config_valid_yn);
   	    okc_util.print_trace(2,'Component code     = '||l_line_info_tab(l_idx).component_code);
       	    okc_util.print_trace(2,'Config item type   = '||l_line_info_tab(l_idx).end_date);
    	    END IF;


            IF (l_debug = 'Y') THEN
               okc_util.print_trace(2,'============================');
               okc_util.print_trace(2,'Contract line idx = '||l_idx);
               okc_util.print_trace(2,'============================');
            END IF;



 	--
	-- Creating Service Quote Lines with only one detail quote line
       	-- If the line is an extended warranty line, a service line or a
        -- support line that has a customer product coverage level, get the
        -- covered products.
        --

        -- get the duration for the entered start AND end dates
        --
        okc_time_util_pub.get_duration(r_cle.start_date,r_cle.end_date,
					l_svc_duration,l_svc_period,x_return_status);

        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           okc_api.set_message(OKC_API.G_APP_NAME,'OKC_GET_DURATION_ERROR');
	      print_error(3);
           RAISE e_exit;
        END IF;

        -- duration is quantity AND period uom for service line
        l_line_info_tab(l_idx).qty      := rtrim(ltrim(l_svc_duration));
        l_line_info_tab(l_idx).uom_code := rtrim(ltrim(l_svc_period));

        IF (l_debug = 'Y') THEN
           okc_util.print_trace(3,'Duration quantity AND Period uom:');
           okc_util.print_trace(3,'=================================');
           okc_util.print_trace(3,'Quantity     = '||l_line_info_tab(l_idx).qty);
           okc_util.print_trace(3,'UOM          = '||l_line_info_tab(l_idx).uom_code);
           okc_util.print_trace(3,'Duration     = '||l_svc_duration);
           okc_util.print_trace(3,'Period       = '||l_svc_period);
        END IF;


--
--	Check and populate the top lines rules table
--

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(3,'==================================');
        okc_util.print_trace(3,'Retrieving the rules at line level');
     END IF;

        build_k_rules( p_chr_id         => p_chr_id,
                        p_cle_id        => l_line_info_tab(l_idx).line_id,
                        x_rule_tab      => lx_kl_rule_tab,
                        x_bto_data_rec  => lx_kl_bto_data_rec,
                        x_sto_data_rec  => lx_kl_sto_data_rec,
                        x_return_status => lx_return_status );

       IF lx_return_status = OKC_API.G_RET_STS_SUCCESS THEN

    	 IF lx_kl_rule_tab.FIRST IS NOT NULL THEN
	    FOR i IN lx_kl_rule_tab.FIRST..lx_kl_rule_tab.LAST LOOP
	       l_kl_rule_tab(l_kl_rule_tab.COUNT+1) := lx_kl_rule_tab(i);
	    END LOOP;
	 END IF;

	 IF lx_kl_bto_data_rec.cle_id IS NOT NULL THEN
             l_kl_bto_data_tab(l_kl_bto_data_tab.COUNT+1) := lx_kl_bto_data_rec;
	 END IF;

	 IF lx_kl_sto_data_rec.cle_id IS NOT NULL THEN
             l_kl_sto_data_tab(l_kl_sto_data_tab.COUNT+1) := lx_kl_sto_data_rec;
	 END IF;

       ELSE
          raise e_exit;
       END IF;

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(3,'Completed retrieving the rules at line level');
        okc_util.print_trace(3,'==================================');
     END IF;

        --
        -- get covered product information
	--

        l_cp_ctr := 0;  -- counter for customer product (cp) lines per service line
	   FOR r_cp IN c_cp(p_chr_id,
			r_cle.line_id, -- Top line id
		     	l_chr.authoring_org_id,
		     	l_chr.inv_organization_id) LOOP

		l_cp_ctr:=l_cp_ctr+1;

             IF l_cp_ctr > 1 THEN    -- more than one cp line for this service line
             	OKC_API.set_message(		-- Set the error message
                      p_app_name      => g_app_name1,
                      p_msg_name      => 'OKO_K2Q_LINENOTORDBL2',
                      p_token1        => 'LINE_NUM',
                      p_token1_value  => r_cle.line_number,
                      p_token2        => 'LINE_STYLE',
                      p_token2_value  => r_cle.line_type,
                      p_token3        => 'KNUMBER',
                      p_token3_value  => l_k_nbr);

            	print_error(4);

	    	RAISE e_exit;
             END IF;

          -- increment cp line index
          l_cp_idx := l_cp_idx + 1;
          l_covlvl_info_tab(l_cp_idx).line_tab_idx 	:= l_idx; -- Maintain Service line info in covlvl line
		--
          l_covlvl_info_tab(l_cp_idx).line_id      	:= r_cp.cle_id;
          l_covlvl_info_tab(l_cp_idx).line_number  	:= r_cp.line_number;
          l_covlvl_info_tab(l_cp_idx).status_code  	:= r_cp.ste_code;
          l_covlvl_info_tab(l_cp_idx).qty          	:= r_cp.quantity;
          l_covlvl_info_tab(l_cp_idx).uom_code     	:= r_cp.uom_code;
          l_covlvl_info_tab(l_cp_idx).priced_item_yn 	:= r_cp.priced_item_yn;
          l_covlvl_info_tab(l_cp_idx).price_unit   	:= r_cp.price_unit;
          l_covlvl_info_tab(l_cp_idx).currency_code	:= r_cp.currency_code;
          l_covlvl_info_tab(l_cp_idx).start_date   	:= r_cp.start_date;
          l_covlvl_info_tab(l_cp_idx).end_date     	:= r_cp.end_date;
          l_covlvl_info_tab(l_cp_idx).line_style   	:= r_cp.line_style;
          l_covlvl_info_tab(l_cp_idx).line_type    	:= r_cp.line_type;
          l_covlvl_info_tab(l_cp_idx).line_source_code 	:= r_cp.line_source_code;
          l_covlvl_info_tab(l_cp_idx).line_source_table	:= r_cp.line_source_table;
          l_covlvl_info_tab(l_cp_idx).id1          	:= r_cp.id1;
          l_covlvl_info_tab(l_cp_idx).id2          	:= r_cp.id2;
	  l_covlvl_info_tab(l_cp_idx).prod_name    	:= r_cp.prod_name;
          l_covlvl_info_tab(l_cp_idx).item_source_code 	:= r_cp.item_source_code;
          l_covlvl_info_tab(l_cp_idx).item_source_table	:= r_cp.item_source_table;
          l_covlvl_info_tab(l_cp_idx).svc_duration 	:= rtrim(ltrim(l_svc_duration));
          l_covlvl_info_tab(l_cp_idx).svc_period   	:= rtrim(ltrim(l_svc_period));

       IF (l_debug = 'Y') THEN
          okc_util.print_trace(3,'Contract Covered Lines:');
          okc_util.print_trace(3,'=======================');
       END IF;

       IF (l_debug = 'Y') THEN
          okc_util.print_trace(3,'>> Line_id            = '||l_covlvl_info_tab(l_cp_idx).line_id);
          okc_util.print_trace(3,'Line NUMBER           = '||l_covlvl_info_tab(l_cp_idx).line_number);
          okc_util.print_trace(3,'--------------');
          okc_util.print_trace(3,'Top Line idx          = '||l_covlvl_info_tab(l_cp_idx).line_tab_idx);
          okc_util.print_trace(3,'--------------');
          okc_util.print_trace(3,'Line style            = '||l_covlvl_info_tab(l_cp_idx).line_style);
          okc_util.print_trace(3,'Line type             = '||l_covlvl_info_tab(l_cp_idx).line_type);
          okc_util.print_trace(3,'Line source code      = '||l_covlvl_info_tab(l_cp_idx).line_source_code);
          okc_util.print_trace(3,'Line source table     = '||l_covlvl_info_tab(l_cp_idx).line_source_table);
          okc_util.print_trace(3,'Prod source code      = '||l_covlvl_info_tab(l_cp_idx).item_source_code);
          okc_util.print_trace(3,'Prod source table     = '||l_covlvl_info_tab(l_cp_idx).item_source_table);
          okc_util.print_trace(3,'Cust Prod id1/Line id = '||l_covlvl_info_tab(l_cp_idx).id1);
          okc_util.print_trace(3,'Cust Prod id2         = '||l_covlvl_info_tab(l_cp_idx).id2);
          okc_util.print_trace(3,'Cust Prod name        = '||l_covlvl_info_tab(l_cp_idx).prod_name);
          okc_util.print_trace(3,'Prod Priced    	     = '||l_covlvl_info_tab(l_cp_idx).priced_item_yn);
          okc_util.print_trace(3,'Quantity              = '||l_covlvl_info_tab(l_cp_idx).qty);
          okc_util.print_trace(3,'UOM                   = '||l_covlvl_info_tab(l_cp_idx).uom_code);
          okc_util.print_trace(3,'Currency code         = '||l_covlvl_info_tab(l_cp_idx).currency_code);
       END IF;
     --okc_util.print_trace(3,'Negoc. price          = '||l_covlvl_info_tab(l_cp_idx).price);
       IF (l_debug = 'Y') THEN
          okc_util.print_trace(3,'Unit price            = '||LTRIM(TO_CHAR(l_covlvl_info_tab(l_cp_idx).price_unit, '9G999G999G990D00')));
          okc_util.print_trace(3,'Start date            = '||l_covlvl_info_tab(l_cp_idx).start_date);
          okc_util.print_trace(3,'End date              = '||l_covlvl_info_tab(l_cp_idx).end_date);
          okc_util.print_trace(3,'SVC duration          = '||l_covlvl_info_tab(l_cp_idx).svc_duration);
          okc_util.print_trace(3,'SVC period            = '||l_covlvl_info_tab(l_cp_idx).svc_period);
          okc_util.print_trace(3,' ');
       END IF;
          END LOOP;

        ELSE 		-- IF is_top_line_orderable_i(r_cle ...) THEN

          	FND_MSG_PUB.Count_And_Get (
	                   p_count	=> 	x_msg_count,
	                   p_data	=> 	x_msg_data);
	     IF x_msg_count > 0 THEN
		FOR i IN 1..x_msg_count LOOP
             		x_msg_data := fnd_msg_pub.get( p_msg_index => i,
                       		                     p_encoded   => 'F'
                               		            );
             		IF (l_debug = 'Y') THEN
                		okc_util.print_trace(2, '==EXCEPTION=================');
                		okc_util.print_trace(2, 'Message      : '||x_msg_data);
                		okc_util.print_trace(2, '============================');
             		END IF;
                END LOOP;
	     END IF;

    --
    -- Check if this contract line is related to the quote line, if yes raise exception- cannot update
    -- If not, then print error - cannot create and continue with the next topline
    --

       		IF is_kl_linked_to_ql(p_chr_id => p_chr_id,
					p_cle_id => r_cle.line_id,
					p_qh_id => g_quote_id,
					p_rlt_code => p_rel_code,
					p_rlt_type => g_rlt_typ_ql) = OKC_API.G_TRUE THEN

			OKC_API.set_message(            -- Set the error message
                      		p_app_name      => g_app_name1,
                      		p_msg_name      => 'OKO_K2Q_LINENOTORDBL3',
                      		p_token1        => 'LINE_NUM',
                      		p_token1_value  => r_cle.line_number,
                      		p_token2        => 'LINE_STYLE',
                      		p_token2_value  => r_cle.line_type,
                      		p_token3        => 'KNUMBER',
                      		p_token3_value  => l_k_nbr);

                		print_error(4);

                		RAISE e_exit;

		ELSE	-- Contract line not linked to quote line

			 OKC_API.set_message(            -- Set the error message
                                p_app_name      => g_app_name1,
                                p_msg_name      => 'OKO_K2Q_LINENOTORDBL4',
                                p_token1        => 'LINE_NUM',
                                p_token1_value  => r_cle.line_number,
                                p_token2        => 'LINE_STYLE',
                                p_token2_value  => r_cle.line_type,
                                p_token3        => 'KNUMBER',
                                p_token3_value  => l_k_nbr);

				print_error(4);

		END IF;
        END IF;	  -- is_top_line_orderable_i

     ELSE  -- is_top_line_with_covered_prod


        IF is_top_line_orderable_i(l_customer_order_enabled_flag,r_cle.lse_id,lx_index) = OKC_API.G_TRUE THEN

	  l_idx := l_idx + 1;
          l_line_info_tab(l_idx) := r_cle;

	  l_line_info_tab(l_idx).item_name := l_item_name;
	  l_line_info_tab(l_idx).customer_order_enabled_flag := l_customer_order_enabled_flag;

            IF (l_debug = 'Y') THEN
               okc_util.print_trace(2,'============================');
               okc_util.print_trace(2,'Contract line idx - II = '||l_idx);
               okc_util.print_trace(2,'============================');
            END IF;

            IF (l_debug = 'Y') THEN
               okc_util.print_trace(2,'--------------');
               okc_util.print_trace(2,'> Line_id          = '||l_line_info_tab(l_idx).line_id);
               okc_util.print_trace(2,'Line NUMBER        = '||l_line_info_tab(l_idx).line_number);
               okc_util.print_trace(2,'--------------');
               okc_util.print_trace(2,'Line style         = '||l_line_info_tab(l_idx).line_style);
               okc_util.print_trace(2,'Line type          = '||l_line_info_tab(l_idx).line_type);
               okc_util.print_trace(2,'Line source code   = '||l_line_info_tab(l_idx).line_source_code);
               okc_util.print_trace(2,'Line source table  = '||l_line_info_tab(l_idx).line_source_table);
               okc_util.print_trace(2,'Item source code   = '||l_line_info_tab(l_idx).item_source_code);
               okc_util.print_trace(2,'Item source table  = '||l_line_info_tab(l_idx).item_source_table);
               okc_util.print_trace(2,'Item id1           = '||l_line_info_tab(l_idx).object_id1);
               okc_util.print_trace(2,'Item id2           = '||l_line_info_tab(l_idx).object_id2);
               okc_util.print_trace(2,'Item name          = '||l_line_info_tab(l_idx).item_name);
               okc_util.print_trace(2,'Item Orderable     = '||l_line_info_tab(l_idx).customer_order_enabled_flag);
               okc_util.print_trace(2,'Item Priced        = '||l_line_info_tab(l_idx).priced_item_yn);
               okc_util.print_trace(2,'Quantity           = '||l_line_info_tab(l_idx).qty);
               okc_util.print_trace(2,'UOM                = '||l_line_info_tab(l_idx).uom_code);
               okc_util.print_trace(2,'Currency code      = '||l_line_info_tab(l_idx).currency_code);
               okc_util.print_trace(2,'Unit price         = '||LTRIM(TO_CHAR(l_line_info_tab(l_idx).price_unit, '9G999G999G990D00')));
            END IF;
            --okc_util.print_trace(2,'Negot. price     = '||l_line_info_tab(l_idx).price);
            IF (l_debug = 'Y') THEN
               okc_util.print_trace(2,'Start date         = '||l_line_info_tab(l_idx).start_date);
               okc_util.print_trace(2,'End date           = '||l_line_info_tab(l_idx).end_date);
            END IF;

    	    IF (l_debug = 'Y') THEN
       	    okc_util.print_trace(2,'Config header id   = '||l_line_info_tab(l_idx).config_header_id);
       	    okc_util.print_trace(2,'config rev Num     = '||l_line_info_tab(l_idx).config_revision_number);
       	    okc_util.print_trace(2,'Config item id     = '||l_line_info_tab(l_idx).config_item_id);
       	    okc_util.print_trace(2,'Config complet yn  = '||l_line_info_tab(l_idx).config_complete_yn);
       	    okc_util.print_trace(2,'Config valid yn    = '||l_line_info_tab(l_idx).config_valid_yn);
   	    okc_util.print_trace(2,'Component code     = '||l_line_info_tab(l_idx).component_code);
       	    okc_util.print_trace(2,'Config item type   = '||l_line_info_tab(l_idx).end_date);
    	    END IF;

            IF (l_debug = 'Y') THEN
               okc_util.print_trace(2,'============================');
               okc_util.print_trace(2,'Contract line idx  - II = '||l_idx);
               okc_util.print_trace(2,'============================');
            END IF;
--
--	Check and populate the top lines rules table
--

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(3,'==================================');
        okc_util.print_trace(3,'Retrieving the rules at line level - II');
        okc_util.print_trace(3,'==================================');
     END IF;

        build_k_rules( p_chr_id         => p_chr_id,
                        p_cle_id        => l_line_info_tab(l_idx).line_id,
                        x_rule_tab      => lx_kl_rule_tab,
                        x_bto_data_rec  => lx_kl_bto_data_rec,
                        x_sto_data_rec  => lx_kl_sto_data_rec,
                        x_return_status => lx_return_status );

       IF lx_return_status = OKC_API.G_RET_STS_SUCCESS THEN

         IF lx_kl_rule_tab.FIRST IS NOT NULL THEN
            FOR i IN lx_kl_rule_tab.FIRST..lx_kl_rule_tab.LAST LOOP
               l_kl_rule_tab(l_kl_rule_tab.COUNT+1) := lx_kl_rule_tab(i);
            END LOOP;
         END IF;

         IF lx_kl_bto_data_rec.cle_id IS NOT NULL THEN
             l_kl_bto_data_tab(l_kl_bto_data_tab.COUNT+1) := lx_kl_bto_data_rec;
         END IF;

         IF lx_kl_sto_data_rec.cle_id IS NOT NULL THEN
             l_kl_sto_data_tab(l_kl_sto_data_tab.COUNT+1) := lx_kl_sto_data_rec;
         END IF;

       ELSE
          raise e_exit;
       END IF;

     IF (l_debug = 'Y') THEN
        okc_util.print_trace(3,'=================================================');
        okc_util.print_trace(3,'Completed retrieving the rules at line level - II');
        okc_util.print_trace(3,'=================================================');
     END IF;


        ELSE -- IF is_top_line_orderable_i(r_cle ...) THEN

          	FND_MSG_PUB.Count_And_Get (
	                   p_count	=> 	x_msg_count,
	                   p_data	=> 	x_msg_data);
		FOR i IN x_msg_count-1..x_msg_count LOOP
             		x_msg_data := fnd_msg_pub.get( p_msg_index => i,
                       		                     p_encoded   => 'F'
                               		            );
             		IF (l_debug = 'Y') THEN
                		okc_util.print_trace(2, '==EXCEPTION=================');
                		okc_util.print_trace(2, 'Message      : '||x_msg_data);
                		okc_util.print_trace(2, '============================');
             		END IF;
                END LOOP;

    --
    -- Check if this contract line is related to the quote line, if yes raise exception- cannot update
    -- If not, then print error - cannot create and continue with the next topline
    --
                    IF is_kl_linked_to_ql(p_chr_id => p_chr_id,
                                        p_cle_id => r_cle.line_id,
                                        p_qh_id => g_quote_id,
                                        p_rlt_code => p_rel_code,
                                        p_rlt_type => g_rlt_typ_ql) = OKC_API.G_TRUE THEN

			OKC_API.set_message(            -- Set the error message
                      		p_app_name      => g_app_name1,
                      		p_msg_name      => 'OKO_K2Q_LINENOTORDBL5',
                      		p_token1        => 'LINE_NUM',
                      		p_token1_value  => r_cle.line_number,
                      		p_token2        => 'LINE_STYLE',
                      		p_token2_value  => r_cle.line_type,
                      		p_token3        => 'KNUMBER',
                      		p_token3_value  => l_k_nbr);

                		print_error(4);

                		RAISE e_exit;

		ELSE	-- Contract line not linked to quote line

			 OKC_API.set_message(            -- Set the error message
                                p_app_name      => g_app_name1,
                                p_msg_name      => 'OKO_K2Q_LINENOTORDBL6',
                                p_token1        => 'LINE_NUM',
                                p_token1_value  => r_cle.line_number,
                                p_token2        => 'LINE_STYLE',
                                p_token2_value  => r_cle.line_type,
                                p_token3        => 'KNUMBER',
                                p_token3_value  => l_k_nbr);

				print_error(4);

		END IF;
        END IF;	  -- is_top_line_orderable_i

   END IF;	  -- is_top_line_with_covered_prod

ELSE	-- is_top_line_style_seeded

    --
    -- Check if this contract line is related to the quote line, if yes raise exception- cannot update
    -- If not, then print error - cannot create and continue with the next topline
    --
                   IF is_kl_linked_to_ql(p_chr_id => p_chr_id,
                                        p_cle_id => r_cle.line_id,
                                        p_qh_id => g_quote_id,
                                        p_rlt_code => p_rel_code,
                                        p_rlt_type => g_rlt_typ_ql) = OKC_API.G_TRUE THEN

			OKC_API.set_message(            -- Set the error message
                      		p_app_name      => g_app_name1,
                      		p_msg_name      => 'OKO_K2Q_LINENOTORDBL7',
                      		p_token1        => 'LINE_NUM',
                      		p_token1_value  => r_cle.line_number,
                      		p_token2        => 'LINE_STYLE',
                      		p_token2_value  => r_cle.line_type,
                      		p_token3        => 'KNUMBER',
                      		p_token3_value  => l_k_nbr);

                		print_error(4);

                		RAISE e_exit;

		ELSE	-- Contract line not linked to quote line

			 OKC_API.set_message(            -- Set the error message
                                p_app_name      => g_app_name1,
                                p_msg_name      => 'OKO_K2Q_LINENOTORDBL8',
                                p_token1        => 'LINE_NUM',
                                p_token1_value  => r_cle.line_number,
                                p_token2        => 'LINE_STYLE',
                                p_token2_value  => r_cle.line_type,
                                p_token3        => 'KNUMBER',
                                p_token3_value  => l_k_nbr);

				print_error(4);

		END IF;
        END IF;	  -- is_top_line_seeded
    CLOSE c_top_cle;
   END LOOP; -- FOR r_cle_i IN c_top_cle_init(p_chr_id) LOOP

  --
  -- were there any lines, orderable lines?
  -- IF not, set return status to error, as no point in continuing
  --

  IF l_lines = 0 THEN
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(3, ' ');
       okc_util.print_trace(3, '******************************************************************');
       okc_util.print_trace(4, 'NO lines');
       okc_util.print_trace(3, '******************************************************************');
    END IF;
    okc_api.set_message(G_APP_NAME1,
				    'OKO_K2Q_NOLINESFORUPDT',
				    'KNUMBER',
				    l_k_nbr);
    x_return_status := OKC_API.G_RET_STS_ERROR;
    print_error(4);
    RAISE e_exit;
  END IF;
  IF l_idx = 0 THEN
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(3, ' ');
       okc_util.print_trace(3, '******************************************************************');
       okc_util.print_trace(4, 'NO orderable lines');
       okc_util.print_trace(3, '******************************************************************');
    END IF;
    okc_api.set_message(G_APP_NAME1,
				    'OKO_K2Q_NOORDLNFORUPDT',
				    'KNUMBER',
				    l_k_nbr);
    x_return_status := OKC_API.G_RET_STS_ERROR;
    print_error(4);
    RAISE e_exit;
  END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, '<END - OKC_OC_INT_KTQ_PVT.BUILD_K_STRUCTURES -');
  END IF;
EXCEPTION
  WHEN e_exit THEN
	   IF c_chr%ISOPEN THEN
		 CLOSE c_chr;
	   END IF;
	   IF c_cust%ISOPEN THEN
		 CLOSE c_cust;
	   END IF;
	   IF c_rules%ISOPEN THEN
		 CLOSE c_rules;
	   END IF;
	   IF c_top_cle%ISOPEN THEN
		 CLOSE c_top_cle;
	   END IF;
	   IF c_cp%ISOPEN THEN
		 CLOSE c_cp;
	   END IF;
  WHEN OTHERS THEN
	   IF c_chr%ISOPEN THEN
		 CLOSE c_chr;
	   END IF;
	   IF c_cust%ISOPEN THEN
		 CLOSE c_cust;
	   END IF;
	   IF c_rules%ISOPEN THEN
		 CLOSE c_rules;
	   END IF;
	   IF c_top_cle%ISOPEN THEN
		 CLOSE c_top_cle;
	   END IF;
	   IF c_cp%ISOPEN THEN
		 CLOSE c_cp;
	   END IF;
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
	   -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	   --RAISE;
END build_k_structures;


-------------------------------------------------------------------------------
-- Procedure:           build_qte_hdr
-- Purpose:             Build the quote or order header record to pass
--                      to the ASO
--                      APIs
-- In Parameters:
-- Out Parameters:
-- In/Out Parameters:   px_qte_hdr_rec - the record to pass to ASO

PROCEDURE build_qte_hdr(px_qte_hdr_rec      IN OUT NOCOPY ASO_QUOTE_PUB.qte_header_rec_type
                       ,px_hd_shipment_tbl  IN OUT NOCOPY ASO_QUOTE_PUB.shipment_tbl_type
		       ,p_contract_id	    IN OKC_K_HEADERS_B.ID%TYPE
		   --    ,p_quote_id	    IN OKX_QUOTE_HEADERS_V.ID1%TYPE
		       ,p_rel_code          IN OKC_K_REL_OBJS.rty_code%TYPE
                       ,x_return_status     OUT NOCOPY    VARCHAR2
				   ) IS

e_exit          exception;                -- used to exit processing
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(1000);
l_k_ship_found  VARCHAR2(1) := 'N';
l_value    	VARCHAR2(1) := 'N';


-- Cursor to select all existing shipment lines at the quote header level
-- and decide on the operation code.
--

CURSOR c_q_shipment(b_qh_id NUMBER, b_ql_id NUMBER) IS
SELECT 'Y'
FROM
	okx_qte_shipments_v
WHERE
	quote_header_id = b_qh_id
  AND	(( b_ql_id IS NULL AND quote_line_id IS NULL) OR
		(b_ql_id IS NOT NULL AND quote_line_id = b_ql_id));

/*
CURSOR c_qte_hdr(b_qh_id NUMBER) IS
SELECT
	id1  quote_header_id,
	quote_number
--	status,
--	b_status status_code
FROM
	okx_quote_headers_v
WHERE
	id1 = b_qh_id;
*/

CURSOR c_qte_hdr(b_qh_id NUMBER) IS
SELECT
	id1  quote_header_id,
	quote_number,
	last_update_date
FROM
	okx_quote_headers_v
WHERE
	id1=b_qh_id;

l_qte_hdr  c_qte_hdr%ROWTYPE;


CURSOR c_salesrep IS
SELECT
	sr.resource_id
FROM
	okc_contacts ct,
	okc_k_party_roles_b pt,
	okx_salesreps_v sr
WHERE
	pt.jtot_object1_code = g_okx_legentity
AND	pt.rle_code = g_supplier_ptrol		  -- g_supplier_ptrol = SUPPLIER
AND	ct.cpl_id = pt.id			  -- party role id
AND	ct.dnz_chr_id = p_contract_id
AND	ct.contact_sequence = 2
AND	ct.cro_code = g_salesrep_ctrol		  -- g_salesrep_ctrol = SALESPERSON
AND	ct.jtot_object1_code = g_jtf_okx_salepers -- g_jtf_okx_salepers = OKX_SALEPERS
AND	sr.id1 = ct.object1_id1
AND	sr.id2 = ct.object1_id2;

l_salesrep	c_salesrep%ROWTYPE;

BEGIN

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, ' ');
     okc_util.print_trace(1, '>START - OKC_OC_INT_KTQ_PVT.BUILD_QTE_HDR - Get quote header information');
  END IF;

  px_qte_hdr_rec.org_id                    := l_chr.authoring_org_id;
  px_qte_hdr_rec.currency_code             := l_chr.currency_code;  -- add back in when available
  px_qte_hdr_rec.quote_version             := 1;
  px_qte_hdr_rec.party_id                  := l_cust.object1_id1;
  px_qte_hdr_rec.original_system_reference := l_k_nbr;

 OPEN c_qte_hdr(g_quote_id);
 FETCH c_qte_hdr INTO l_qte_hdr;
 IF c_qte_hdr%FOUND THEN

	px_qte_hdr_rec.quote_header_id 	:= l_qte_hdr.quote_header_id;
	px_qte_hdr_rec.quote_number    	:= l_qte_hdr.quote_number;
--	px_qte_hdr_rec.quote_status    	:= l_qte_hdr.status;
--	px_qte_hdr_rec.quote_status_code:= l_qte_hdr.status_code;
	px_qte_hdr_rec.last_update_date := l_qte_hdr.last_update_date;

 END IF;
 CLOSE c_qte_hdr;


 OPEN c_salesrep;
 FETCH c_salesrep INTO l_salesrep;
 IF c_salesrep%FOUND THEN
	px_qte_hdr_rec.resource_id := to_number(l_salesrep.resource_id);
 END IF;
 CLOSE c_salesrep;


  IF l_kh_rule_tab.first IS NOT NULL THEN
    FOR i IN l_kh_rule_tab.first..l_kh_rule_tab.last LOOP
-- get rule information for header

      IF l_kh_rule_tab(i).rule_information_category = g_rd_custacct THEN
-- customer account
        px_qte_hdr_rec.cust_account_id 	:= l_kh_rule_tab(i).object1_id1;

      ELSIF l_kh_rule_tab(i).rule_information_category = g_rd_price THEN
-- price list
        px_qte_hdr_rec.price_list_id 	:= l_kh_rule_tab(i).object1_id1;

      ELSIF l_kh_rule_tab(i).rule_information_category = g_rd_invrule THEN
-- invoice rule
        px_qte_hdr_rec.invoicing_rule_id:= l_kh_rule_tab(i).object1_id1;

      ELSIF l_kh_rule_tab(i).rule_information_category = g_rd_shipmtd THEN
         px_hd_shipment_tbl(i).ship_method_code := l_kh_rule_tab(i).rule_information_category;

-- shipment method
      ELSIF l_kh_rule_tab(i).rule_information_category = g_rd_shipto THEN
         l_k_ship_found  := 'Y';

      END IF;
    END LOOP;
  END IF;


IF l_kh_bto_data_tab.FIRST IS NOT NULL THEN
  FOR i IN l_kh_bto_data_tab.FIRST..l_kh_bto_data_tab.LAST LOOP

    px_qte_hdr_rec.invoice_to_party_site_id := l_kh_bto_data_tab(i).party_site_id;
--  px_qte_hdr_rec.invoice_to_party_id      := NVL(l_kh_bto_data_tab(i).party_id,l_cust.object1_id1);

 END LOOP;
END IF;

--
-- Populate the shipment record

IF l_kh_sto_data_tab.FIRST IS NOT NULL THEN
 FOR i IN l_kh_sto_data_tab.FIRST..l_kh_sto_data_tab.LAST LOOP

  px_hd_shipment_tbl(i).ship_to_party_id 	:= NVL(l_kh_sto_data_tab(i).party_id,l_cust.object1_id1);
  px_hd_shipment_tbl(i).ship_to_party_site_id	:= l_kh_sto_data_tab(i).party_site_id;
  px_hd_shipment_tbl(i).ship_to_cust_account_id	:= l_kh_sto_data_tab(i).cust_acct_id;

  px_hd_shipment_tbl(i).ship_to_address1 	:= l_kh_sto_data_tab(i).address1;
  px_hd_shipment_tbl(i).ship_to_address2 	:= l_kh_sto_data_tab(i).address2;
  px_hd_shipment_tbl(i).ship_to_address3 	:= l_kh_sto_data_tab(i).address3;
  px_hd_shipment_tbl(i).ship_to_address4 	:= l_kh_sto_data_tab(i).address4;
  px_hd_shipment_tbl(i).ship_to_city 		:= l_kh_sto_data_tab(i).city;
  px_hd_shipment_tbl(i).ship_to_state 		:= l_kh_sto_data_tab(i).state;
  px_hd_shipment_tbl(i).ship_to_province 	:= l_kh_sto_data_tab(i).province;
  px_hd_shipment_tbl(i).ship_to_postal_code	:= l_kh_sto_data_tab(i).postal_code;
  px_hd_shipment_tbl(i).ship_to_county 		:= l_kh_sto_data_tab(i).county;
  px_hd_shipment_tbl(i).ship_to_country 	:= l_kh_sto_data_tab(i).country;


  OPEN c_q_shipment(px_qte_hdr_rec.quote_header_id,null);

  FETCH c_q_shipment INTO l_value;

  IF c_q_shipment%NOTFOUND THEN
    IF l_k_ship_found = 'Y' THEN
      px_hd_shipment_tbl(i).operation_code :=   g_aso_op_code_create;
    END IF;
  ELSE
    IF l_k_ship_found = 'Y' THEN
      px_hd_shipment_tbl(i).operation_code :=  g_aso_op_code_update;
    ELSE
      px_hd_shipment_tbl(i).operation_code :=  g_aso_op_code_delete;
    END IF;
  END IF;
  CLOSE c_q_shipment;

 END LOOP;
END IF;

  --
  -- set exchange information
  --
  px_qte_hdr_rec.exchange_type_code := l_exchange_type;
  px_qte_hdr_rec.exchange_rate      := l_exchange_rate;
  px_qte_hdr_rec.exchange_rate_date := l_exchange_date;

  --
  -- check IF we got customer account, set IF not
  --
  IF px_qte_hdr_rec.cust_account_id IS NULL
   OR px_qte_hdr_rec.cust_account_id = FND_API.G_MISS_NUM THEN

    px_qte_hdr_rec.cust_account_id := l_bt_cust_acct_id;

  END IF;

  OPEN c_chr(p_contract_id);
  FETCH c_chr INTO l_chr;
  IF c_chr%FOUND THEN

     px_qte_hdr_rec.total_list_price 	  := l_chr.total_line_list_price;
     px_qte_hdr_rec.total_adjusted_amount := l_chr.total_line_list_price - l_chr.estimated_amount;
     px_qte_hdr_rec.price_list_id 	  := l_chr.price_list_id;

     px_qte_hdr_rec.quote_expiration_date := l_chr.sign_by_date;

  END IF;
  CLOSE c_chr;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, ' ');
     okc_util.print_trace(1, 'INPUT RECORD FOR QUOTE UPDATION - Quote Header:');
     okc_util.print_trace(1, '===============================================');
     okc_util.print_trace(2, 'Org_id               = '||px_qte_hdr_rec.org_id);
     okc_util.print_trace(2, 'Original syst ref (contract num) = '||px_qte_hdr_rec.original_system_reference);
     okc_util.print_trace(2, 'Quote name           = '||px_qte_hdr_rec.quote_name);
     okc_util.print_trace(2, 'Quote version        = '||px_qte_hdr_rec.quote_version);
     okc_util.print_trace(2, 'Quote source code    = '||px_qte_hdr_rec.quote_source_code);
     okc_util.print_trace(2, 'Quote category code  = '||ltrim(rtrim(px_qte_hdr_rec.quote_category_code)));
     okc_util.print_trace(2, 'Quote expiration date= '||px_qte_hdr_rec.quote_expiration_date);
     okc_util.print_trace(2, 'Party_id             = '||px_qte_hdr_rec.party_id);
     okc_util.print_trace(2, 'Cust Acct Id         = '||px_qte_hdr_rec.cust_account_id);
     okc_util.print_trace(2, 'Price List Id        = '||px_qte_hdr_rec.price_list_id);
     okc_util.print_trace(2, 'Inv Rule Id          = '||px_qte_hdr_rec.invoicing_rule_id);
     okc_util.print_trace(2, 'Inv To Party Id      = '||px_qte_hdr_rec.invoice_to_party_id);
     okc_util.print_trace(2, 'Inv To Party Site Id = '||px_qte_hdr_rec.invoice_to_party_site_id);
  END IF;
--okc_util.print_trace(2, 'Ship To Party Id     = '||px_hd_shipment_rec.ship_to_party_id);
--okc_util.print_trace(2, 'Ship To Party Site Id= '||px_hd_shipment_rec.ship_to_party_site_id);
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(2, 'Currency code        = '||px_qte_hdr_rec.currency_code);
  END IF;
--okc_util.print_trace(2, 'Total quote price    = '||LTRIM(TO_CHAR(px_qte_hdr_rec.total_quote_price, '9G999G999G990D00')));
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(2, 'Total list price     = '||LTRIM(TO_CHAR(px_qte_hdr_rec.total_list_price, '9G999G999G990D00')));
     okc_util.print_trace(2, 'Total adjusted amount= '||LTRIM(TO_CHAR(px_qte_hdr_rec.total_adjusted_amount, '9G999G999G990D00')));
     okc_util.print_trace(2, 'Total adjusted amount= '||to_number(px_qte_hdr_rec.total_adjusted_amount));
     okc_util.print_trace(2, 'Exchange type code   = '||px_qte_hdr_rec.exchange_type_code);
     okc_util.print_trace(2, 'Exchange rate        = '||px_qte_hdr_rec.exchange_rate);
     okc_util.print_trace(2, 'Exchange rate date   = '||px_qte_hdr_rec.exchange_rate_date);
     okc_util.print_trace(2, '---------------------------------------');
     okc_util.print_trace(2, 'Quote header Id      = '||px_qte_hdr_rec.quote_header_id);
     okc_util.print_trace(2, 'Quote NUMBER         = '||px_qte_hdr_rec.quote_number);
     okc_util.print_trace(2, 'Quote status Id      = '||px_qte_hdr_rec.quote_status_id);
     okc_util.print_trace(2, 'Quote status code    = '||ltrim(rtrim(px_qte_hdr_rec.quote_status_code)));
     okc_util.print_trace(2, 'Quote status         = '||ltrim(rtrim(px_qte_hdr_rec.quote_status)));
  END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, '<END - OKC_OC_INT_KTQ_PVT.BUILD_QTE_HDR -');
  END IF;
EXCEPTION
  WHEN e_exit THEN
    -- nothing more to do
    null;
  WHEN OTHERS THEN
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
END build_qte_hdr;

-------------------------------------------------------------------------------
-- Procedure:           build_qte_line
-- Purpose:             Build the quote line AND quote detail line records.  To be used
--                      to pass to the ASO quote AND order APIs
-- In Parameters:
-- Out Parameters:
-- In/Out Paramters:    px_qte_line_tbl     -- table of quote lines
--                      px_qte_line_dtl_tbl -- table of quote detail lines
--                      px_k2q_line_tbl     -- holds relationship between contract line
--                                             AND the index in the quote line table
--			px_qte_ln_shipment_tbl contains  the shipment information
--
--
PROCEDURE build_qte_line (
			 p_contract_id       IN      OKC_K_HEADERS_B.ID%TYPE
			 ,px_qte_hdr_rec      IN ASO_QUOTE_PUB.qte_header_rec_type
			 ,px_qte_line_tbl     IN  OUT NOCOPY aso_quote_pub.qte_line_tbl_type
                         ,px_qte_line_dtl_tbl IN  OUT NOCOPY aso_quote_pub.qte_line_dtl_tbl_type
			 ,px_qte_ln_shipment_tbl  IN OUT NOCOPY aso_quote_pub.shipment_tbl_type
                         ,px_k2q_line_tbl     IN  OUT NOCOPY okc_oc_int_config_pvt.line_rel_tab_type
                   --    ,x_total_price       OUT     NUMBER
			 ,x_line_rltship_tab  OUT NOCOPY     ASO_QUOTE_PUB.line_rltship_tbl_type
                         ,x_return_status     OUT NOCOPY     VARCHAR2
                         ) IS

l_ql        	      	binary_integer;  -- table index
i_l_ql        	      	binary_integer;  -- table index
l_dql       	      	binary_integer;  -- table index
i_l_dql       	      	binary_integer;  -- table index
l_cp_found     	 	BOOLEAN;
l_lp_found     	 	BOOLEAN;
l_line_skipped       	BOOLEAN;
l_continue           	BOOLEAN;
l_nb_qte_line_dtl    	NUMBER;
--
l_top_line_unit_price 	okc_k_lines_b.price_unit%TYPE;
l_topln_unit_prc_assgnd VARCHAR2(1);
l_unit_price_assigned 	okc_k_lines_b.price_unit%TYPE;
--
l_previous_line_id   	okc_k_lines_b.id%TYPE;
l_cur_tl             	NUMBER;
l_cur_cl             	NUMBER;
l_id1 			okx_quote_line_detail_v.id1%TYPE;
--
l_k_ship_found  	VARCHAR2(1) := 'N';
l_value         	VARCHAR2(1) := 'N';
l_quote_line_id 	okc_k_rel_objs.object1_id1%TYPE;
l_qt_found  		VARCHAR2(1) := 'N';
l_k2q_found  		VARCHAR2(1) := 'N';
l_qdl_a_found  		VARCHAR2(1) := 'N';
l_qdl_b_found  		VARCHAR2(1) := 'N';

e_exit 		EXCEPTION;

--
k binary_integer;
r binary_integer;
x binary_integer;
y binary_integer;
z binary_integer;


x_msg_count             NUMBER ;
x_msg_data              VARCHAR2(1000);

CURSOR c_quot_detl_line (p_qte_line_id IN NUMBER) IS
  SELECT ID1
  FROM okx_quote_line_detail_v
  WHERE QUOTE_LINE_ID  = p_qte_line_id;


CURSOR c_ql (g_quote_id IN okx_quote_lines_v.quote_header_id%TYPE ) IS
  SELECT id1
  FROM okx_quote_lines_v
  WHERE quote_header_id = g_quote_id;

CURSOR c_sl (id1 IN okx_quote_lines_v.ID1%TYPE ) IS
  SELECT shipment_id
  FROM okx_qte_shipments_v
  WHERE quote_line_id = id1;


CURSOR c_qdl(id1 IN okx_quote_lines_v.ID1%TYPE ) IS
  SELECT id1
  FROM okx_quote_line_detail_v
  WHERE quote_line_id = id1;

-- Cursor to select all existing shipment lines at the quote header level
-- and decide on the operation code.
--
CURSOR c_q_shipment(b_ql_id NUMBER) IS
SELECT 'Y'
FROM
        okx_qte_shipments_v
WHERE quote_line_id = b_ql_id;

BEGIN
   IF (l_debug = 'Y') THEN
      okc_util.print_trace(1, ' ');
      okc_util.print_trace(1, '>START - OKC_OC_INT_KTQ_PVT.BUILD_QTE_LINE - Get quote line AND quote detail line information');
   END IF;

--
-- housekeeping
--
   x_line_rltship_tab.DELETE;


   l_dql := 0;
   l_ql := 0;
   l_previous_line_id := NULL;
--   x_total_price := 0;

  IF l_line_info_tab.first is not NULL THEN
IF (l_debug = 'Y') THEN
   okc_util.print_trace(2,'l_line_info_tab.count '||l_line_info_tab.count);
END IF;
   FOR c IN 1..2 LOOP
	 --
	 -- need to ensure that license product lines are processed before
	 -- support lines, to have the quote line id available when creating
	 -- the quote detail line of the quote line for the support line
	 --
      FOR i IN l_line_info_tab.first..l_line_info_tab.last LOOP
	   l_continue:=TRUE;
	   IF c=1 AND is_top_line_with_covered_prod(l_line_info_tab(i).lse_id) = OKC_API.G_TRUE THEN
	      l_continue:=FALSE;
	   ELSIF c=2 AND NOT is_top_line_with_covered_prod(l_line_info_tab(i).lse_id) = OKC_API.G_TRUE THEN
	      l_continue:=FALSE;
	   END IF;

	   IF l_continue THEN

         IF (l_debug = 'Y') THEN
            okc_util.print_trace(2, ' ');
            okc_util.print_trace(2, '-----------------------------');
            okc_util.print_trace(2, 'Contract line idx    = '||i);
            okc_util.print_trace(2, 'Contract line NUMBER = '||l_line_info_tab(i).line_number);
            okc_util.print_trace(2, '-----------------------------');
         END IF;

	    --
            -- define one quote line
	    --
--	    l_ql := l_ql + 1;
	    --

--	Open the c_q_k_rel cursor to check the existence of the related quote line
--	to create the operation code.(Create,Update or Delete ).

	IF l_ktq_flag = OKC_API.G_TRUE THEN
	   OPEN c_q_k_rel(p_contract_id,l_line_info_tab(i).line_id,g_quote_id,g_rlt_code_ktq,g_rlt_typ_ql);
	ELSE
	   OPEN c_q_k_rel(p_contract_id,l_line_info_tab(i).line_id,g_quote_id,g_rlt_code_knq,g_rlt_typ_ql);
	END IF;

	   FETCH c_q_k_rel INTO l_quote_line_id;
		IF c_q_k_rel%FOUND THEN			-- UPDATE

			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'Quote line: Related quote line found - update ');
			END IF;

			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'l_line_info_tab('||i||') - config_item_type = '||l_line_info_tab(i).config_item_type);
			END IF;
		   IF l_line_info_tab(i).config_item_type IN (g_okc_model_item,g_okc_base_item) THEN
			--
			-- Configurable item
			--
			-- check againt px_qte_line_tbl to retrieve l_quote_line_id
			-- This is necessary to fit the top model line and top base line
			-- into one line


		      IF px_qte_line_tbl.FIRST IS NOT NULL THEN
			 FOR k IN px_qte_line_tbl.FIRST..px_qte_line_tbl.LAST LOOP
			    IF px_qte_line_tbl(k).quote_line_id = l_quote_line_id THEN
				l_qt_found := 'Y';
				l_ql:=k;		-- if found reuse the same entry for update
			   	px_qte_line_tbl(l_ql).operation_code := g_aso_op_code_update;
			   	px_qte_line_tbl(l_ql).quote_line_id  := l_quote_line_id;
			   	px_qte_line_tbl(l_ql).quote_header_id:= g_quote_id;

			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'1a.Found an entry in px_qte_line_tbl with index = '||l_ql);
   			okc_util.print_trace(2,'Operation code = '||px_qte_line_tbl(l_ql).operation_code);
   			okc_util.print_trace(2,'Qte line id    = '||px_qte_line_tbl(l_ql).quote_line_id);
   			okc_util.print_trace(2,'Qte header id  = '||px_qte_line_tbl(l_ql).quote_header_id);
			END IF;

			       EXIT;
			    END IF;
			 END LOOP;	-- FOR k IN px_qte_line_tbl.FIRST
		      END IF;	-- IF px_qte_line_tbl.FIRST IS NOT NULL

	              IF l_qt_found = 'N' THEN  -- Looping thru the px_qte_line_tbl didnot find l_quote_line_id
			   i_l_ql:=i_l_ql+1;
                   	   l_ql:=i_l_ql;
			   px_qte_line_tbl(l_ql).operation_code := g_aso_op_code_update;
			   px_qte_line_tbl(l_ql).quote_line_id  := l_quote_line_id;
			   px_qte_line_tbl(l_ql).quote_header_id:= g_quote_id;

			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'1a.Did not find any entry in px_qte_line_tbl');
   			okc_util.print_trace(2,'Index          = '||l_ql);
   			okc_util.print_trace(2,'Operation code = '||px_qte_line_tbl(l_ql).operation_code);
   			okc_util.print_trace(2,'Qte line id    = '||px_qte_line_tbl(l_ql).quote_line_id);
   			okc_util.print_trace(2,'Qte header id  = '||px_qte_line_tbl(l_ql).quote_header_id);
			END IF;
		      END IF;

		   ELSE	-- l_line_info_tab(i).config_item_type IN

			--
			-- This is the case of a regular quote line other than
			-- the top model line and top base line
			-- Related quote line found, but is not a top model or top base item,
			-- and a regular update

			i_l_ql:=i_l_ql+1;
                   	l_ql:=i_l_ql;
			px_qte_line_tbl(l_ql).operation_code := g_aso_op_code_update;
			px_qte_line_tbl(l_ql).quote_line_id  := l_quote_line_id;
			px_qte_line_tbl(l_ql).quote_header_id:= g_quote_id;

			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'1a.case of a non top model or non top base line - update ');
   			okc_util.print_trace(2,'Index          = '||l_ql);
   			okc_util.print_trace(2,'Operation code = '||px_qte_line_tbl(l_ql).operation_code);
   			okc_util.print_trace(2,'Qte line id    = '||px_qte_line_tbl(l_ql).quote_line_id);
   			okc_util.print_trace(2,'Qte header id  = '||px_qte_line_tbl(l_ql).quote_header_id);
			END IF;

		   END IF;	--l_line_info_tab(i).config_item_type IN

		ELSE	--  c_q_k_rel%FOUND ( i.e. if not found )	-- CREATE
		    --
		    -- Check against px_k2q_line_tbl to find if there is an entry for the
		    -- parent line id, in case of a configurable item
		    --
			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'Quote line: Related quote line not found - create ');
			END IF;

			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'l_line_info_tab('||i||') - config_item_type = '||l_line_info_tab(i).config_item_type);
			END IF;
		     IF l_line_info_tab(i).config_item_type IN (g_okc_model_item,g_okc_base_item) THEN
			 --
			 -- Check against px_k2q_line_tbl
			 --
			 IF px_k2q_line_tbl.FIRST IS NOT NULL THEN
			    FOR k IN px_k2q_line_tbl.FIRST..px_k2q_line_tbl.LAST LOOP
				IF px_k2q_line_tbl(k).k_line_id = l_line_info_tab(i).cle_id THEN
				   l_k2q_found := 'Y';
                                   l_ql:=px_k2q_line_tbl(k).q_line_idx;  -- q_line_idx should be equal to k
							--
						        -- if found reuse the same entry (with oper.code
							-- as CREATE) to be updated
							--
                                   px_qte_line_tbl(l_ql).operation_code := g_aso_op_code_create;
                                   px_qte_line_tbl(l_ql).quote_header_id:= g_quote_id;

			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'2a.Found an entry in px_qte_line_tbl with index = '||l_ql);
   			okc_util.print_trace(2,'Operation code = '||px_qte_line_tbl(l_ql).operation_code);
   			okc_util.print_trace(2,'Qte header id  = '||px_qte_line_tbl(l_ql).quote_header_id);
			END IF;

                                   EXIT;
				END IF;
			    END LOOP;	-- FOR k IN px_k2q_line_tbl.FIRST..
			 END IF;	-- IF px_k2q_line_tbl.FIRST IS NOT NULL

			 IF l_k2q_found = 'N' THEN  -- Looping thru the px_k2q_line_tbl
					            -- didnot find l_line_info_tab(i).cle_id
                           l_ql:=l_ql+1;
                           px_qte_line_tbl(l_ql).operation_code := g_aso_op_code_create;
                           px_qte_line_tbl(l_ql).quote_header_id:= g_quote_id;

			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'2a.Didnot find any entry in px_qte_line_tbl ');
   			okc_util.print_trace(2,'Operation code = '||px_qte_line_tbl(l_ql).operation_code);
   			okc_util.print_trace(2,'Qte header id  = '||px_qte_line_tbl(l_ql).quote_header_id);
			END IF;

                         END IF;
		     ELSE	-- l_line_info_tab(i).config_item_type IN (g_okc_model_item,g_okc_base_item)
			l_ql:=l_ql+1;
			px_qte_line_tbl(l_ql).operation_code := g_aso_op_code_create;
			px_qte_line_tbl(l_ql).quote_header_id:= g_quote_id;

			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'2a.case of a non top model or non top base line - create ');
   			okc_util.print_trace(2,'Index          = '||l_ql);
   			okc_util.print_trace(2,'Operation code = '||px_qte_line_tbl(l_ql).operation_code);
   			okc_util.print_trace(2,'Qte header id  = '||px_qte_line_tbl(l_ql).quote_header_id);
			END IF;

		     END IF;	-- l_line_info_tab(i).config_item_type IN (g_okc_model_item,g_okc_base_item)

		END IF; --  c_q_k_rel%FOUND

 IF (l_debug = 'Y') THEN
    okc_util.print_trace(2, 'Qte line table - operation code '|| px_qte_line_tbl(l_ql).operation_code);
    okc_util.print_trace(2, 'Qte line table - qte hdr id     '|| px_qte_line_tbl(l_ql).quote_header_id);
    okc_util.print_trace(2, 'Qte line table - qte line id    '|| px_qte_line_tbl(l_ql).quote_line_id);
 END IF;

	   CLOSE c_q_k_rel;

         IF (l_debug = 'Y') THEN
            okc_util.print_trace(2, 'Quote line NUMBER    = '||l_ql);
            okc_util.print_trace(2, '-----------------------------');
         END IF;

         IF (l_debug = 'Y') THEN
            okc_util.print_trace(2, '>> Building quote line structures');
         END IF;
         px_qte_line_tbl(l_ql).line_number      := l_ql;
         px_qte_line_tbl(l_ql).org_id           := l_chr.authoring_org_id;
         px_qte_line_tbl(l_ql).inventory_item_id:= l_line_info_tab(i).object_id1;
         px_qte_line_tbl(l_ql).organization_id  := l_line_info_tab(i).object_id2;
         px_qte_line_tbl(l_ql).quantity         := l_line_info_tab(i).qty;
         px_qte_line_tbl(l_ql).uom_code         := l_line_info_tab(i).uom_code;
         px_qte_line_tbl(l_ql).start_date_active:= l_line_info_tab(i).end_date + 1;
         px_qte_line_tbl(l_ql).currency_code    := l_line_info_tab(i).currency_code;


 IF (l_debug = 'Y') THEN
    okc_util.print_trace(2,'Qte line table - line number      '||px_qte_line_tbl(l_ql).line_number);
    okc_util.print_trace(2,'Qte line table - org id           '||px_qte_line_tbl(l_ql).org_id);
    okc_util.print_trace(2,'Qte line table - item id      '||px_qte_line_tbl(l_ql).inventory_item_id);
    okc_util.print_trace(2,'Qte line table - organization id  '||px_qte_line_tbl(l_ql).organization_id);
    okc_util.print_trace(2,'Qte line table - quantity         '||px_qte_line_tbl(l_ql).quantity);
    okc_util.print_trace(2,'Qte line table - uom_code         '||px_qte_line_tbl(l_ql).uom_code);
    okc_util.print_trace(2,'Qte line table - start_date_active'||px_qte_line_tbl(l_ql).start_date_active);
    okc_util.print_trace(2,'Qte line table - currency_code    '||px_qte_line_tbl(l_ql).currency_code);
 END IF;


IF (l_debug = 'Y') THEN
   okc_util.print_trace(2,'Obtaining the rule(s)');
END IF;
-- Obtain the top line rules

	FOR k IN l_kl_rule_tab.FIRST..l_kl_rule_tab.LAST LOOP
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(2,'rule category                '||l_kl_rule_tab(k).rule_information_category);
   		okc_util.print_trace(2,'rule - rule tab cle_id       '||l_kl_rule_tab(k).cle_id);
   		okc_util.print_trace(2,'rule - line info tab line_id '||l_line_info_tab(i).line_id);
		END IF;

	   IF l_kl_rule_tab(k).cle_id = l_line_info_tab(i).line_id THEN

		-- get rule information for line

		      IF l_kl_rule_tab(k).rule_information_category = g_rd_price THEN
		-- price list
       			 px_qte_line_tbl(l_ql).price_list_id := NVL(l_kl_rule_tab(k).object1_id1,px_qte_hdr_rec.price_list_id);
 			IF (l_debug = 'Y') THEN
    			okc_util.print_trace(2,'Qte line table - price list id '|| px_qte_line_tbl(l_ql).price_list_id);
 			END IF;
		      ELSIF l_kl_rule_tab(k).rule_information_category = g_rd_invrule THEN
		-- invoice rule
		        px_qte_line_tbl(l_ql).invoicing_rule_id := NVL(l_kl_rule_tab(k).object1_id1,px_qte_hdr_rec.invoicing_rule_id);
 			IF (l_debug = 'Y') THEN
    			okc_util.print_trace(2,'Qte line table - inv rule id '|| px_qte_line_tbl(l_ql).invoicing_rule_id);
 			END IF;

		      ELSIF l_kl_rule_tab(k).rule_information_category = g_rd_shipmtd THEN
	         	px_qte_ln_shipment_tbl(l_ql).ship_method_code := l_kl_rule_tab(k).rule_information_category;
 			IF (l_debug = 'Y') THEN
    			okc_util.print_trace(2,'Qte line table - ship_method_code '||px_qte_ln_shipment_tbl(l_ql).ship_method_code);
 			END IF;
		-- shipment method
      			ELSIF l_kl_rule_tab(k).rule_information_category = g_rd_shipto THEN
         		l_k_ship_found  := 'Y';
      			END IF;
	   END IF;
	END LOOP;

--
-- obtain the bill to rule
--
IF (l_debug = 'Y') THEN
   okc_util.print_trace(2,'Obtaining the Billto rule');
END IF;
     IF l_kl_bto_data_tab.FIRST IS NOT NULL THEN
	FOR k IN l_kl_bto_data_tab.FIRST..l_kl_bto_data_tab.LAST LOOP
	   IF l_kl_bto_data_tab(k).cle_id = l_line_info_tab(i).line_id THEN

		 px_qte_line_tbl(l_ql).invoice_to_party_site_id := NVL(l_kl_bto_data_tab(k).party_site_id,px_qte_hdr_rec.invoice_to_party_site_id);
		-- px_qte_line_tbl(l_ql).invoice_to_party_id 	:= NVL(l_kl_bto_data_tab(k).party_id,px_qte_hdr_rec.invoice_to_party_id);

 		IF (l_debug = 'Y') THEN
    		okc_util.print_trace(2,'Qte line table - invoice_to_party_site_id '|| px_qte_line_tbl(l_ql).invoice_to_party_site_id);
    		okc_util.print_trace(2,'Qte line table - invoice_to_party_id '|| px_qte_line_tbl(l_ql).invoice_to_party_id);
 		END IF;
	   END IF;
        END LOOP;
     END IF;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(2,'Obtaining the ship to rule and operation code');
END IF;
--
-- obtain the ship to rule and the operation code
--
     IF l_kl_sto_data_tab.FIRST IS NOT NULL THEN

 	FOR k IN l_kl_sto_data_tab.FIRST..l_kl_sto_data_tab.LAST LOOP

IF (l_debug = 'Y') THEN
   OKC_UTIL.PRINT_TRACE(2,'ship to rule at line level found');
END IF;

	   IF l_kl_sto_data_tab(k).cle_id = l_line_info_tab(i).line_id THEN

  		px_qte_ln_shipment_tbl(l_ql).ship_to_party_site_id := l_kl_sto_data_tab(k).party_site_id;
  		px_qte_ln_shipment_tbl(l_ql).ship_to_cust_account_id := l_kl_sto_data_tab(k).cust_acct_id;
  		px_qte_ln_shipment_tbl(l_ql).ship_to_party_id := NVL(l_kl_sto_data_tab(k).party_id,l_cust.object1_id1);
  		px_qte_ln_shipment_tbl(l_ql).ship_to_address1   := l_kl_sto_data_tab(k).address1;
  		px_qte_ln_shipment_tbl(l_ql).ship_to_address2   := l_kl_sto_data_tab(k).address2;
  		px_qte_ln_shipment_tbl(l_ql).ship_to_address3   := l_kl_sto_data_tab(k).address3;
  		px_qte_ln_shipment_tbl(l_ql).ship_to_address4   := l_kl_sto_data_tab(k).address4;
  		px_qte_ln_shipment_tbl(l_ql).ship_to_city       := l_kl_sto_data_tab(k).city;
  		px_qte_ln_shipment_tbl(l_ql).ship_to_state      := l_kl_sto_data_tab(k).state;
  		px_qte_ln_shipment_tbl(l_ql).ship_to_province   := l_kl_sto_data_tab(k).province;
  		px_qte_ln_shipment_tbl(l_ql).ship_to_postal_code:= l_kl_sto_data_tab(k).postal_code;
  		px_qte_ln_shipment_tbl(l_ql).ship_to_county     := l_kl_sto_data_tab(k).county;
  		px_qte_ln_shipment_tbl(l_ql).ship_to_country    := l_kl_sto_data_tab(k).country;
	   END IF;

		  OPEN c_q_shipment(px_qte_line_tbl(l_ql).quote_line_id);

  		  FETCH c_q_shipment INTO l_value;

		  IF c_q_shipment%NOTFOUND THEN
    			IF l_k_ship_found = 'Y' THEN
		          px_qte_ln_shipment_tbl(l_ql).operation_code :=  g_aso_op_code_create;
    		  	END IF;
  		  ELSE
    			IF l_k_ship_found = 'Y' THEN
      			  px_qte_ln_shipment_tbl(l_ql).operation_code :=  g_aso_op_code_update;
    		  	ELSE
      			  px_qte_ln_shipment_tbl(l_ql).operation_code := g_aso_op_code_delete;
    		  	END IF;
  		  END IF;
  		  CLOSE c_q_shipment;

 	END LOOP;
    END IF;

         --
         -- get covered item info if available to define the quote detail line
         -- get calculated quote line price
         --

         l_cp_found := FALSE;
         l_line_skipped := FALSE;

         IF l_covlvl_info_tab.first IS NOT NULL THEN
            FOR j IN l_covlvl_info_tab.first..l_covlvl_info_tab.last LOOP
               l_cp_found := FALSE;

               IF l_covlvl_info_tab(j).line_tab_idx = i THEN
                  l_cp_found := TRUE;

	          --
                  -- define one quote detail line
		  --	   --
                  l_dql := l_dql + 1;
			   --
		  px_qte_line_dtl_tbl(l_dql).qte_line_index    := l_ql;
		  px_qte_line_dtl_tbl(l_dql).service_duration  := l_covlvl_info_tab(j).svc_duration;
                  px_qte_line_dtl_tbl(l_dql).service_period    := l_covlvl_info_tab(j).svc_period;

		IF px_qte_line_tbl(l_ql).operation_code = g_aso_op_code_create THEN

		   px_qte_line_dtl_tbl(l_dql).operation_code := g_aso_op_code_create;
		-- parent line
		-- l_ql = px_qte_line_tbl(l_ql).line_number;
		   px_qte_line_dtl_tbl(l_dql).qte_line_index  := l_ql;

		ELSIF

		   px_qte_line_tbl(l_ql).operation_code = g_aso_op_code_update THEN

                   OPEN  c_quot_detl_line (px_qte_line_tbl(l_ql).quote_line_id);
                   FETCH c_quot_detl_line INTO l_id1;
                    IF c_quot_detl_line%FOUND THEN
                      px_qte_line_dtl_tbl(l_dql).operation_code := g_aso_op_code_update;
		      px_qte_line_dtl_tbl(l_dql).quote_line_detail_id := l_id1;

		      px_qte_line_dtl_tbl(l_dql).config_header_id := NULL;
		      px_qte_line_dtl_tbl(l_dql).config_revision_num := NULL;
		      px_qte_line_dtl_tbl(l_dql).config_item_id := NULL;
		      px_qte_line_dtl_tbl(l_dql).complete_configuration_flag := NULL;
		      px_qte_line_dtl_tbl(l_dql).valid_configuration_flag := NULL;
		      px_qte_line_dtl_tbl(l_dql).component_code := NULL;

		    ELSE
		      px_qte_line_dtl_tbl(l_dql).operation_code := g_aso_op_code_create;
                    END IF;
 		-- parent_line
		      px_qte_line_dtl_tbl(l_dql).quote_line_id := px_qte_line_dtl_tbl(l_dql).quote_line_id;

                END IF;    -- px_qte_line_tbl(l_ql).operation_code = g_aso_op_code_create

		IF l_covlvl_info_tab(i).line_type <> g_lt_suppline THEN
                     px_qte_line_dtl_tbl(l_dql).service_ref_type_code  := g_qte_ref_cp;
				 --
				 -- 02/26/01:Logic change in ASO API.
				 -- service_ref_line_id has to be used instead of
				 -- service_ref_system_id in case of a service line
				 -- with a covered product
                     px_qte_line_dtl_tbl(l_dql).service_ref_line_id  := l_covlvl_info_tab(j).id1;
                ELSE
                     px_qte_line_dtl_tbl(l_dql).service_ref_type_code  := g_qte_ref_quote;
	 	  --
	 	  -- We need to retrieve the quote line NUMBER of the
	 	  -- related License Product line
	 	  --
                     IF (l_debug = 'Y') THEN
                        okc_util.print_trace(3, '>Look for Quote line number of the Lic Prod line');
                     END IF;
		     l_lp_found := FALSE;
		 	 IF px_k2q_line_tbl.first IS NOT NULL THEN

			    FOR k IN px_k2q_line_tbl.first..px_k2q_line_tbl.last LOOP

			       IF px_k2q_line_tbl(k).k_line_id = l_covlvl_info_tab(j).id1 THEN

				  l_lp_found := TRUE;

				     IF l_lp_found THEN

					IF px_qte_line_tbl(k).operation_code = g_aso_op_code_create THEN
		                           px_qte_line_dtl_tbl(l_dql).service_ref_qte_line_index:= px_qte_line_tbl(k).line_number;
					ELSE
					   px_qte_line_dtl_tbl(l_dql).service_ref_line_id := px_qte_line_tbl(k).quote_line_id;
					END IF;  --  px_qte_line_tbl(k).operation_code

				     END IF;  -- IF l_lp_found

				       EXIT;
                               END IF;  --IF px_k2q_line_tbl(k).k_line_id

			    END LOOP;  -- FOR k IN px_k2q_line_tbl

			 END IF;  --IF px_k2q_line_tbl.first IS

		END IF; -- IF l_covlvl_info_tab(i).line_type<>g_lt_suppline THEN

             END IF; -- IF l_covlvl_info_tab(j).line_tab_idx = i THEN

          END LOOP;  -- FOR j IN l_covlvl_info_tab.first..last LOOP

       END IF; -- IF l_covlvl_info_tab.first IS NOT NULL THEN

        IF (l_debug = 'Y') THEN
           okc_util.print_trace(2,' ');
           okc_util.print_trace(2,'QDL  ');
   	okc_util.print_trace(2,'l_line_info_tab('||i||').config_item_type = '||l_line_info_tab(i).config_item_type);
           okc_util.print_trace(2,' ');
        END IF;


      IF NOT l_cp_found AND px_qte_line_tbl(l_ql).operation_code = g_aso_op_code_update AND
          l_line_info_tab(i).config_item_type NOT IN (g_okc_model_item,g_okc_base_item,g_okc_config_item) THEN
	--
	-- This is the case of a Non service, Non configurable item
	-- ie a standard item and no sub lines
	--
	-- Need to ensure that the original quote line had no quote detail line
	-- Need to retrieve the quote detail line of related quote parent line
	-- pointed by px_qte_line_tbl(l_ql).quote_line_id using a cursor on
	-- OKX_QUOTE_LINE_DETAILS_V
	--
		OPEN c_qdl(px_qte_line_tbl(l_ql).quote_line_id) ;
		FETCH c_qdl INTO l_id1;
		IF c_qdl%FOUND THEN
		   l_dql := l_dql + 1;
		   px_qte_line_dtl_tbl(l_dql).operation_code := g_aso_op_code_delete;
		   px_qte_line_dtl_tbl(l_dql).quote_line_detail_id := l_id1;
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(2,'case of a Non service, Non configurable item, deleting a qte dtl line');
		END IF;
		END IF;
		CLOSE c_qdl;
      END IF;


      IF NOT l_cp_found AND px_qte_line_tbl(l_ql).operation_code = g_aso_op_code_update AND
          l_line_info_tab(i).config_item_type IN (g_okc_model_item,g_okc_base_item,g_okc_config_item) THEN
	--
	-- This is the case of a Non service, Configurable item	 -- 'UPDATE'
	--
	-- Need to retrieve if the original quote line has any quote detail line using the c_qdl cursor
	-- ie. against the okx_quote_line_details_v
	--
                OPEN c_qdl(px_qte_line_tbl(l_ql).quote_line_id) ;
                FETCH c_qdl INTO l_id1;
                IF c_qdl%FOUND THEN	-- The Quote detail line needs to be updated.
		   --
		   -- Need to check if there is any quote detail line against
		   -- px_qte_line_dtl_tbl for the quote_line_id
		   -- ie. check against the px_qte_line_dtl_tbl PL/SQL table
		   --
			IF px_qte_line_dtl_tbl.FIRST IS NOT NULL THEN
			   FOR k IN px_qte_line_dtl_tbl.FIRST..px_qte_line_dtl_tbl.LAST LOOP
			      IF px_qte_line_dtl_tbl(k).quote_line_id = px_qte_line_tbl(l_ql).quote_line_id THEN
				 l_qdl_a_found := 'Y';
				 l_dql := k;
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(2,'1a.case of a Non service,Configurable item, updating qte dtl line');
		END IF;
				 EXIT;
			      END IF;
			   END LOOP;
			END IF;
			IF l_qdl_a_found = 'N' THEN  -- The previous check did'nt find any entry in the PL/SQLtable
			   i_l_dql := l_dql + 1;
			   l_dql   := i_l_dql;
		IF (l_debug = 'Y') THEN
   		okc_util.print_trace(2,'1a.case of a Non service,Configurable item, check against qte dtl line PL/SQL table didnot find any QDL');
		END IF;
			END IF;

		   px_qte_line_dtl_tbl(l_dql).operation_code := g_aso_op_code_update;
		   px_qte_line_dtl_tbl(l_dql).quote_line_detail_id := l_id1;
		   px_qte_line_dtl_tbl(l_dql).quote_line_id := px_qte_line_tbl(l_ql).quote_line_id;

		   px_qte_line_dtl_tbl(l_dql).config_header_id := l_line_info_tab(i).config_header_id;
		   px_qte_line_dtl_tbl(l_dql).config_revision_num := l_line_info_tab(i).config_revision_number;
		   px_qte_line_dtl_tbl(l_dql).config_item_id := l_line_info_tab(i).config_item_id;
		   px_qte_line_dtl_tbl(l_dql).complete_configuration_flag := l_line_info_tab(i).config_complete_yn;
		   px_qte_line_dtl_tbl(l_dql).valid_configuration_flag := l_line_info_tab(i).config_valid_yn;
		   px_qte_line_dtl_tbl(l_dql).component_code := l_line_info_tab(i).component_code;

	--	set the rest of the columns to null,since they are not valid anymore


		   px_qte_line_dtl_tbl(l_dql).service_duration := NULL;
		   px_qte_line_dtl_tbl(l_dql).service_period := NULL;
		   px_qte_line_dtl_tbl(l_dql).service_ref_type_code := NULL;
		   px_qte_line_dtl_tbl(l_dql).service_ref_line_number := NULL;


		   IF (l_debug = 'Y') THEN
   		   okc_util.print_trace(2, ' ');
   		   okc_util.print_trace(2, 'Quote detail line values');
   		   okc_util.print_trace(2, ' ');
		   END IF;

		   IF (l_debug = 'Y') THEN
   		   okc_util.print_trace(2,'operation_code     '||px_qte_line_dtl_tbl(l_dql).operation_code);
   		   okc_util.print_trace(2,'qte_line_dtl_id    '||px_qte_line_dtl_tbl(l_dql).quote_line_detail_id);
   		   okc_util.print_trace(2,'quote_line_id      '||px_qte_line_dtl_tbl(l_dql).quote_line_id);
   		   okc_util.print_trace(2,'config_header_id   '||px_qte_line_dtl_tbl(l_dql).config_header_id);
   		   okc_util.print_trace(2,'config_rev_num     '||px_qte_line_dtl_tbl(l_dql).config_revision_num);
   		   okc_util.print_trace(2,'config_item_id     '||px_qte_line_dtl_tbl(l_dql).config_item_id);
   		   okc_util.print_trace(2,'complete conf flag '||px_qte_line_dtl_tbl(l_dql).complete_configuration_flag);
   		   okc_util.print_trace(2,'valid_conf flag    '||px_qte_line_dtl_tbl(l_dql).valid_configuration_flag);
   		   okc_util.print_trace(2,'component_code     '||px_qte_line_dtl_tbl(l_dql).component_code);
		   END IF;


		ELSE 	--  c_qdl%FOUND (i.e. quote detail line not found )

		   --
		   -- Need to check if there is any quote detail line against
		   -- px_qte_line_dtl_tbl for the quote_line_id
		   -- ie. check against the px_qte_line_dtl_tbl PL/SQL table
		   --
			IF px_qte_line_dtl_tbl.FIRST IS NOT NULL THEN
			   FOR k IN px_qte_line_dtl_tbl.FIRST..px_qte_line_dtl_tbl.LAST LOOP
			      IF px_qte_line_dtl_tbl(k).quote_line_id = px_qte_line_tbl(l_ql).quote_line_id THEN
				 l_qdl_a_found := 'Y';
				 l_dql := k;
			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'Case of qdl not found in okx_quote_line_detail_v but found in the PL/SQL table');
			END IF;
				 EXIT;
			      END IF;
			   END LOOP;
			END IF;
			IF l_qdl_a_found = 'N' THEN  -- The previous check did'nt find any entry in the PL/SQLtable
			   i_l_dql := l_dql + 1;
			   l_dql   := i_l_dql;
			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'Case of qdl not found in neither okx_quote_line_detail_v nor the PL/SQL table');
			END IF;
			END IF;

		   px_qte_line_dtl_tbl(l_dql).operation_code := g_aso_op_code_create;
		   px_qte_line_dtl_tbl(l_dql).quote_line_id := px_qte_line_tbl(l_ql).quote_line_id;

		   px_qte_line_dtl_tbl(l_dql).config_header_id := l_line_info_tab(i).config_header_id;
		   px_qte_line_dtl_tbl(l_dql).config_revision_num := l_line_info_tab(i).config_revision_number;
		   px_qte_line_dtl_tbl(l_dql).config_item_id := l_line_info_tab(i).config_item_id;
		   px_qte_line_dtl_tbl(l_dql).complete_configuration_flag := l_line_info_tab(i).config_complete_yn;
		   px_qte_line_dtl_tbl(l_dql).valid_configuration_flag := l_line_info_tab(i).config_valid_yn;
		   px_qte_line_dtl_tbl(l_dql).component_code := l_line_info_tab(i).component_code;


		   IF (l_debug = 'Y') THEN
   		   okc_util.print_trace(2,'operation_code   '||px_qte_line_dtl_tbl(l_dql).operation_code);
   		   okc_util.print_trace(2,'quote_line_id    '||px_qte_line_dtl_tbl(l_dql).quote_line_id);
   		   okc_util.print_trace(2,'config_header_id '||px_qte_line_dtl_tbl(l_dql).config_header_id);
   		   okc_util.print_trace(2,'config_rev num   '||px_qte_line_dtl_tbl(l_dql).config_revision_num);
   		   okc_util.print_trace(2,'config_item_id   '||px_qte_line_dtl_tbl(l_dql).config_item_id);
   		   okc_util.print_trace(2,'comp conf flag   '||px_qte_line_dtl_tbl(l_dql).complete_configuration_flag);
   		   okc_util.print_trace(2,'valid conf flag  '||px_qte_line_dtl_tbl(l_dql).valid_configuration_flag);
   		   okc_util.print_trace(2,'component_code   '||px_qte_line_dtl_tbl(l_dql).component_code);
		   END IF;


		END IF;	-- IF c_qdl%FOUND THEN

      END IF; -- IF NOT l_cp_found AND px_qte_line_tbl(l_ql).operation_code = g_aso_op_code_update
	      -- l_line_info_tab(i).config_item_type IN (g_okc ....



      IF NOT l_cp_found AND px_qte_line_tbl(l_ql).operation_code = g_aso_op_code_create AND
          l_line_info_tab(i).config_item_type IN (g_okc_model_item,g_okc_base_item,g_okc_config_item) THEN
	--
	-- This is the case of a Non service, Configurable item	 -- 'CREATE'
	--
		   --
		   -- Need to retrieve if the quote line has any quote detail line against
		   -- px_qte_line_dtl_tbl for the quote_line_id
		   -- ie. check against the px_qte_line_dtl_tbl PL/SQL table
		   -- for the quote line index = l_ql
		   --
			IF px_qte_line_dtl_tbl.FIRST IS NOT NULL THEN
			   FOR k IN px_qte_line_dtl_tbl.FIRST..px_qte_line_dtl_tbl.LAST LOOP
			      IF px_qte_line_dtl_tbl(k).qte_line_index = l_ql THEN
				 l_qdl_b_found := 'Y';
				 l_dql := k;
			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'Case of  Non service, Configurable item, entry found in PL/SQL table - create QDL ');
			END IF;
		   		 px_qte_line_dtl_tbl(l_dql).operation_code := g_aso_op_code_create;
		   		 px_qte_line_dtl_tbl(l_dql).qte_line_index := l_ql;

		   px_qte_line_dtl_tbl(l_dql).config_header_id := l_line_info_tab(i).config_header_id;
		   px_qte_line_dtl_tbl(l_dql).config_revision_num := l_line_info_tab(i).config_revision_number;
		   px_qte_line_dtl_tbl(l_dql).config_item_id := l_line_info_tab(i).config_item_id;
		   px_qte_line_dtl_tbl(l_dql).complete_configuration_flag := l_line_info_tab(i).config_complete_yn;
		   px_qte_line_dtl_tbl(l_dql).valid_configuration_flag := l_line_info_tab(i).config_valid_yn;
		   px_qte_line_dtl_tbl(l_dql).component_code := l_line_info_tab(i).component_code;

		   IF (l_debug = 'Y') THEN
   		   okc_util.print_trace(2,'operation_code   '||px_qte_line_dtl_tbl(l_dql).operation_code);
   		   okc_util.print_trace(2,'quote_line_idx   '||px_qte_line_dtl_tbl(l_dql).qte_line_index);
   		   okc_util.print_trace(2,'config_header_id '||px_qte_line_dtl_tbl(l_dql).config_header_id);
   		   okc_util.print_trace(2,'config_rev num   '||px_qte_line_dtl_tbl(l_dql).config_revision_num);
   		   okc_util.print_trace(2,'config_item_id   '||px_qte_line_dtl_tbl(l_dql).config_item_id);
   		   okc_util.print_trace(2,'comp conf flag   '||px_qte_line_dtl_tbl(l_dql).complete_configuration_flag);
   		   okc_util.print_trace(2,'valid conf flag  '||px_qte_line_dtl_tbl(l_dql).valid_configuration_flag);
   		   okc_util.print_trace(2,'component_code   '||px_qte_line_dtl_tbl(l_dql).component_code);
		   END IF;

				 EXIT;
			      END IF;
			   END LOOP;
			END IF;
			IF l_qdl_b_found = 'N' THEN  -- The previous check did'nt find any entry in the PL/SQLtable
						-- Need to create a quote detail line
			   i_l_dql := l_dql + 1;
			   l_dql   := i_l_dql;
		   		 px_qte_line_dtl_tbl(l_dql).operation_code := g_aso_op_code_create;
		   		 px_qte_line_dtl_tbl(l_dql).qte_line_index := l_ql;

			IF (l_debug = 'Y') THEN
   			okc_util.print_trace(2,'Case of  Non service, Configurable item,no entry in PL/SQL table - create QDL ');
			END IF;

		   px_qte_line_dtl_tbl(l_dql).config_header_id := l_line_info_tab(i).config_header_id;
		   px_qte_line_dtl_tbl(l_dql).config_revision_num := l_line_info_tab(i).config_revision_number;
		   px_qte_line_dtl_tbl(l_dql).config_item_id := l_line_info_tab(i).config_item_id;
		   px_qte_line_dtl_tbl(l_dql).complete_configuration_flag := l_line_info_tab(i).config_complete_yn;
		   px_qte_line_dtl_tbl(l_dql).valid_configuration_flag := l_line_info_tab(i).config_valid_yn;
		   px_qte_line_dtl_tbl(l_dql).component_code := l_line_info_tab(i).component_code;

		   IF (l_debug = 'Y') THEN
   		   okc_util.print_trace(2,'operation_code   '||px_qte_line_dtl_tbl(l_dql).operation_code);
   		   okc_util.print_trace(2,'quote_line_idx   '||px_qte_line_dtl_tbl(l_dql).qte_line_index);
   		   okc_util.print_trace(2,'config_header_id '||px_qte_line_dtl_tbl(l_dql).config_header_id);
   		   okc_util.print_trace(2,'config_rev num   '||px_qte_line_dtl_tbl(l_dql).config_revision_num);
   		   okc_util.print_trace(2,'config_item_id   '||px_qte_line_dtl_tbl(l_dql).config_item_id);
   		   okc_util.print_trace(2,'comp conf flag   '||px_qte_line_dtl_tbl(l_dql).complete_configuration_flag);
   		   okc_util.print_trace(2,'valid conf flag  '||px_qte_line_dtl_tbl(l_dql).valid_configuration_flag);
   		   okc_util.print_trace(2,'component_code   '||px_qte_line_dtl_tbl(l_dql).component_code);
		   END IF;
			END IF;

      END IF; -- IF NOT l_cp_found AND px_qte_line_tbl(l_ql).operation_code = g_aso_op_code_update
	      -- l_line_info_tab(i).config_item_type IN (g_okc ....

--
--		=========================
--		UPDATE CONFIG INFORMATION
--		=========================
--
	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(2,' ');
   	okc_util.print_trace(2,' UPDATING CONFIG INFORMATION ');
   	okc_util.print_trace(2,' ');
	END IF;

	IF l_line_info_tab(i).config_item_type = g_okc_model_item THEN
	   px_qte_line_tbl(l_ql).item_type_code := g_aso_model_item;	-- 'MDL'

	ELSIF l_line_info_tab(i).config_item_type = g_okc_base_item THEN
	   px_qte_line_tbl(l_ql).item_type_code := g_aso_model_item;    -- 'MDL'

	ELSIF l_line_info_tab(i).config_item_type = g_okc_config_item THEN
	   px_qte_line_tbl(l_ql).item_type_code := g_aso_config_item;    -- 'CFG'

	ELSIF l_line_info_tab(i).config_item_type = g_okc_service_item THEN
	   px_qte_line_tbl(l_ql).item_type_code := g_aso_service_item;   -- 'SRV'

	END IF;



	    l_cur_tl:=i;
	    --
	    -- calculate a quote line price, from the contract
	    -- line(index i=l_cur_tl)
            --
            IF (l_debug = 'Y') THEN
               okc_util.print_trace(3, '--Quantity of the contract top line             = '||l_line_info_tab(l_cur_tl).qty);
               okc_util.print_trace(3, '--Unit of Measure of the contract top line      = '||l_line_info_tab(l_cur_tl).uom_code);
            END IF;

	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(2,' ');
   	okc_util.print_trace(2,' Calculating line list price and line adjusted amount ' );
   	okc_util.print_trace(2,' ');
	END IF;

                     px_qte_line_tbl(l_ql).line_list_price := NVL(l_line_info_tab(l_cur_tl).price_unit,ROUND(l_line_info_tab(l_cur_tl).line_list_price / l_line_info_tab(l_cur_tl).qty, 2));
	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(3,' px_qte_line_tbl(l_ql).line_list_price = '|| px_qte_line_tbl(l_ql).line_list_price);
	END IF;

		     px_qte_line_tbl(l_ql).line_adjusted_amount :=  px_qte_line_tbl(l_ql).line_list_price-ROUND(l_line_info_tab(l_cur_tl).price_negotiated/l_line_info_tab(l_cur_tl).qty,2);
	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(3,' px_qte_line_tbl(l_ql).line_adjusted_amount = '|| px_qte_line_tbl(l_ql).line_adjusted_amount);
	END IF;

	           px_qte_line_tbl(l_ql).price_list_id := l_line_info_tab(l_cur_tl).price_list_id;
	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(3,' px_qte_line_tbl(l_ql).price_list_id = '|| px_qte_line_tbl(l_ql).price_list_id);
	END IF;

	           px_qte_line_tbl(l_ql).price_list_line_id := l_line_info_tab(l_cur_tl).price_list_line_id;
	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(3,' px_qte_line_tbl(l_ql).price_list_line_id = '||px_qte_line_tbl(l_ql).price_list_line_id);
	END IF;


	    --
	    -- record relation in the px_k2q_line_tbl PL/SQL table
	    --
	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(2,' ');
   	okc_util.print_trace(2,' Creating relation in px_k2q_line_tbl PL/SQL table ');
   	okc_util.print_trace(2,' ');
	END IF;

	       	px_k2q_line_tbl(l_ql).k_line_id 	:= l_line_info_tab(l_cur_tl).line_id;
	       	px_k2q_line_tbl(l_ql).q_line_idx   	:= l_ql;

	IF l_line_info_tab(i).config_item_type IN ( g_okc_model_item, g_okc_base_item, g_okc_config_item ) THEN
		px_k2q_line_tbl(l_ql).k_parent_line_id 	:= l_line_info_tab(l_cur_tl).cle_id;
	       	px_k2q_line_tbl(l_ql).q_item_type_code 	:= px_qte_line_tbl(l_ql).item_type_code;
	END IF;

            IF (l_debug = 'Y') THEN
               okc_util.print_trace(5, '-----------------------------');
               okc_util.print_trace(5, 'Quote line NUMBER     = '||px_qte_line_tbl(l_ql).line_number);
               okc_util.print_trace(5, '-----------------------------');
               okc_util.print_trace(6, 'Quote line quantity   = '||px_qte_line_tbl(l_ql).quantity);
               okc_util.print_trace(6, 'Quote line uom        = '||px_qte_line_tbl(l_ql).uom_code);
            END IF;
--            okc_util.print_trace(6, 'Quote line unit price = '||LTRIM(TO_CHAR(px_qte_line_tbl(l_ql).line_quote_price, '9G999G999G990D00')));
 --           okc_util.print_trace(6, 'Quote line price      = '||LTRIM(TO_CHAR(px_qte_line_tbl(l_ql).line_quote_price*px_qte_line_tbl(l_ql).quantity, '9G999G999G990D00')));


	   END IF; -- IF l_continue THEN
      END LOOP;   --qteline
   END LOOP; --FOR c IN 1..2 LOOP
  END IF;

--
-- Call the OKC_OC_INT_CONFIG_PVT.quote_line_relationship by passing the
-- quote line table,quote line detail table and px_k2q_line_tbl
-- to get the l_line_rltship_tbl, that contains information about
-- relationship between quote lines.
--


        IF (l_debug = 'Y') THEN
           okc_util.print_trace(2,' ');
           okc_util.print_trace(2,' Calling the OKC_OC_INT_CONFIG_PVT.quote_line_relationship procedure ');
           okc_util.print_trace(2,' ');
        END IF;


  OKC_OC_INT_CONFIG_PVT.quote_line_relationship(
					px_k2q_line_tbl,
					px_qte_line_tbl,
					px_qte_line_dtl_tbl,
					x_line_rltship_tab,
					x_return_status
						);


 IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

 print_error(3);

 RAISE e_exit;

 END IF;

        IF (l_debug = 'Y') THEN
           okc_util.print_trace(2,' ');
           okc_util.print_trace(2,' Success - Calling the OKC_OC_INT_CONFIG_PVT.quote_line_relationship procedure ');
           okc_util.print_trace(2,' ');
        END IF;

-- Need to identify the quote lines that have to be deleted, for which
-- the contract lines have already been deleted.

 x := px_qte_line_tbl.COUNT;
 y := px_qte_ln_shipment_tbl.COUNT;
 z := px_qte_line_dtl_tbl.COUNT;

 FOR c_ql_rec IN c_ql(g_quote_id) LOOP

  	FOR i IN px_qte_line_tbl.FIRST..px_qte_line_tbl.LAST LOOP
	   IF px_qte_line_tbl(i).quote_line_id = c_ql_rec.id1 THEN
	      EXIT;
	   ELSE

	      x := x + 1;
	      px_qte_line_tbl(x).operation_code := g_aso_op_code_delete;
	      px_qte_line_tbl(x).quote_line_id  := c_ql_rec.id1;
	      px_qte_line_tbl(x).quote_header_id:= g_quote_id;

     	      FOR c_sl_rec IN c_sl(c_ql_rec.id1) LOOP

		 y := y + 1;
		 px_qte_ln_shipment_tbl(y).operation_code := g_aso_op_code_delete;
		 px_qte_ln_shipment_tbl(y).quote_line_id := c_ql_rec.id1;
		 px_qte_ln_shipment_tbl(y).quote_header_id:= g_quote_id;
		 px_qte_ln_shipment_tbl(y).shipment_id := c_sl_rec.shipment_id;
	      END LOOP;

	      FOR c_qdl_rec IN  c_qdl(c_ql_rec.id1) LOOP

		 z := z + 1;
		 px_qte_line_dtl_tbl(z).operation_code := g_aso_op_code_delete;
		 px_qte_line_dtl_tbl(z).quote_line_id := c_ql_rec.id1;
		 px_qte_line_dtl_tbl(z).quote_line_detail_id := c_ql_rec.id1;

	      END LOOP;
	   END IF;
	END LOOP;
 END LOOP;


  IF l_ql = 0 THEN
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(2, ' ');
       okc_util.print_trace(2, '******************************************************************');
       okc_util.print_trace(3, 'NO quote lines: All contract top lines have been discarded');
       okc_util.print_trace(2, '******************************************************************');
    END IF;
    okc_api.set_message(G_APP_NAME1,
		    	'OKO_K2Q_NOORDLINES',
		    	'KNUMBER',
		    	l_chr.contract_number);
    x_return_status := OKC_API.G_RET_STS_ERROR;
    print_error(4);
    --RAISE e_exit;
  ELSE
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
  END IF;

--okc_util.print_trace(2, ' ');
--okc_util.print_trace(2, '=====================================');
--okc_util.print_trace(2, 'Total Quote Price         = '||LTRIM(TO_CHAR(x_total_price, '9G999G999G990D00')));
--okc_util.print_trace(2, '=====================================');
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, ' ');
     okc_util.print_trace(1, 'INPUT RECORD FOR QUOTE CREATION - Quote Lines:');
     okc_util.print_trace(1, '==============================================');
  END IF;
  IF px_qte_line_tbl.first IS NOT NULL THEN
    FOR i IN px_qte_line_tbl.first..px_qte_line_tbl.last LOOP
       IF (l_debug = 'Y') THEN
          okc_util.print_trace(2, '> Org Id                 = '||px_qte_line_tbl(i).org_id);
          okc_util.print_trace(2, 'Quote Line NUMBER        = '||px_qte_line_tbl(i).line_number);
          okc_util.print_trace(2, 'Quote Line category code = '||ltrim(rtrim(px_qte_line_tbl(i).line_category_code)));
          okc_util.print_trace(2, 'Item type code           = '||px_qte_line_tbl(i).item_type_code);
          okc_util.print_trace(2, 'Start date active        = '||px_qte_line_tbl(i).start_date_active);
          okc_util.print_trace(2, 'End date active          = '||px_qte_line_tbl(i).end_date_active);
          okc_util.print_trace(2, 'Price List Id            = '||px_qte_line_tbl(i).price_list_id);
          okc_util.print_trace(2, 'Inv Rule Id              = '||px_qte_line_tbl(i).invoicing_rule_id);
          okc_util.print_trace(2, 'Inv To Party Id          = '||px_qte_line_tbl(i).invoice_to_party_id);
          okc_util.print_trace(2, 'Inv To Party site Id     = '||px_qte_line_tbl(i).invoice_to_party_site_id);
          okc_util.print_trace(2, 'Inv Item Id              = '||px_qte_line_tbl(i).inventory_item_id);
          okc_util.print_trace(2, 'Organization Id          = '||px_qte_line_tbl(i).organization_id);
          okc_util.print_trace(2, 'Quantity                 = '||px_qte_line_tbl(i).quantity);
          okc_util.print_trace(2, 'UOM                      = '||px_qte_line_tbl(i).uom_code);
          okc_util.print_trace(2, 'Currency code            = '||px_qte_line_tbl(i).currency_code);
          okc_util.print_trace(2, 'Quote line unit price    = '||LTRIM(TO_CHAR(px_qte_line_tbl(i).line_quote_price, '9G999G999G990D00')));
          okc_util.print_trace(2, 'Quote line price         = '||LTRIM(TO_CHAR(px_qte_line_tbl(i).line_quote_price*px_qte_line_tbl(i).quantity, '9G999G999G990D99')));
          okc_util.print_trace(2, '---------------------------------------');
          okc_util.print_trace(2, 'Quote Header Id          = '||px_qte_line_tbl(i).quote_header_id);
          okc_util.print_trace(2, 'Quote Line Id            = '||px_qte_line_tbl(i).quote_line_id);
       END IF;

       IF px_qte_line_dtl_tbl.first IS NOT NULL THEN
          IF (l_debug = 'Y') THEN
             okc_util.print_trace(3, ' ');
             okc_util.print_trace(3, 'INPUT RECORD FOR QUOTE CREATION - Quote Detail Lines:');
             okc_util.print_trace(3, '===============================================');
          END IF;
		l_nb_qte_line_dtl:=0;
          FOR j IN px_qte_line_dtl_tbl.first..px_qte_line_dtl_tbl.last LOOP

		   IF px_qte_line_dtl_tbl(j).qte_line_index = px_qte_line_tbl(i).line_number THEN


		   l_nb_qte_line_dtl:=l_nb_qte_line_dtl + 1;

             IF (l_debug = 'Y') THEN
                okc_util.print_trace(4, '>> Quote Line NUMBER      = '||px_qte_line_dtl_tbl(j).qte_line_index);
                okc_util.print_trace(4, 'Service Ref type code     = '||px_qte_line_dtl_tbl(j).service_ref_type_code);
                okc_util.print_trace(4, 'Service Ref Syst Id       = '||px_qte_line_dtl_tbl(j).service_ref_system_id);
                okc_util.print_trace(4, 'Service Ref Line Id       = '||px_qte_line_dtl_tbl(j).service_ref_line_id);
             END IF;
           --okc_util.print_trace(4, 'Service Ref Line Num      = '||px_qte_line_dtl_tbl(j).service_ref_line_number);
             IF (l_debug = 'Y') THEN
                okc_util.print_trace(4, 'Service Ref Line Num      = '||px_qte_line_dtl_tbl(j).service_ref_qte_line_index);
                okc_util.print_trace(4, 'Service Ref Qte Line Idx  = '||px_qte_line_dtl_tbl(j).service_ref_qte_line_index);
                okc_util.print_trace(4, 'Service Ref Order Num     = '||px_qte_line_dtl_tbl(j).service_ref_order_number);
                okc_util.print_trace(4, 'Service duration          = '||px_qte_line_dtl_tbl(j).service_duration);
                okc_util.print_trace(4, 'Service period            = '||px_qte_line_dtl_tbl(j).service_period);
             END IF;

             IF (l_debug = 'Y') THEN
                okc_util.print_trace(4, 'config_header_id          = '||px_qte_line_dtl_tbl(j).config_header_id);
                okc_util.print_trace(4, 'config_rev num            = '||px_qte_line_dtl_tbl(j).config_revision_num);
                okc_util.print_trace(4, 'config_item_id            = '||px_qte_line_dtl_tbl(j).config_item_id);
                okc_util.print_trace(4, 'comp conf flag            = '||px_qte_line_dtl_tbl(j).complete_configuration_flag);
                okc_util.print_trace(4, 'valid conf flag           = '||px_qte_line_dtl_tbl(j).valid_configuration_flag);
                okc_util.print_trace(4, 'component_code            = '||px_qte_line_dtl_tbl(j).component_code);
             END IF;


             IF (l_debug = 'Y') THEN
                okc_util.print_trace(4, '---------------------------------------');
                okc_util.print_trace(4, 'Quote Line Id             = '||px_qte_line_dtl_tbl(j).quote_line_id);
                okc_util.print_trace(4, 'Quote Detail Line Id      = '||px_qte_line_dtl_tbl(j).quote_line_detail_id);
             END IF;

		   END IF;
	     END LOOP;
		IF l_nb_qte_line_dtl = 0 THEN
             IF (l_debug = 'Y') THEN
                okc_util.print_trace(4, 'NO Quote Detail Lines');
             END IF;
		END IF;
       ELSE
          IF (l_debug = 'Y') THEN
             okc_util.print_trace(3, ' ');
             okc_util.print_trace(3, 'INPUT RECORD FOR QUOTE CREATION - Quote Detail Lines:');
             okc_util.print_trace(3, '=====================================================');
             okc_util.print_trace(4, 'NO Quote Detail Lines');
          END IF;
       END IF;

       IF (l_debug = 'Y') THEN
          okc_util.print_trace(5, ' ');
          okc_util.print_trace(5, 'INPUT RECORD FOR RELATIONSHIP CREATION - Contract Line-Quote Line Relationship:');
          okc_util.print_trace(5, '=====================================================');
       END IF;

       IF (l_debug = 'Y') THEN
          okc_util.print_trace(2,'px_k2q_tab_count '||px_k2q_line_tbl.count);
       END IF;

       IF px_k2q_line_tbl.EXISTS(i) THEN
             IF (l_debug = 'Y') THEN
                okc_util.print_trace(6, 'Contract Line Id        = '||px_k2q_line_tbl(i).k_line_id);
                okc_util.print_trace(6, 'Contract Line parent id = '||px_k2q_line_tbl(i).k_parent_line_id);
                okc_util.print_trace(6, 'Quote Line Index        = '||px_k2q_line_tbl(i).q_line_idx);
                okc_util.print_trace(6, 'Quote Item type code    = '||px_k2q_line_tbl(i).q_item_type_code);
             END IF;
       END IF;
       IF (l_debug = 'Y') THEN
          okc_util.print_trace(2, '                                                ');
       END IF;

    END LOOP;
  ELSE
     IF (l_debug = 'Y') THEN
        okc_util.print_trace(2, 'NO Quote Lines');
     END IF;
  END IF;
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(2, '                                                ');
     okc_util.print_trace(1, '<END - OKC_OC_INT_KTQ_PVT.BUILD_QTE_LINE -');
  END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN e_exit THEN
  --   IF c_price%ISOPEN THEN
  --      CLOSE c_price;
  --   END IF;
	null;
  WHEN OTHERS THEN
  -- IF c_price%ISOPEN THEN
  --    CLOSE c_price;
  -- END IF;
    OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
END build_qte_line;

-------------------------------------------------------------------------------
--
-- public procedures
--
-- Procedure:       update_quote_from_k
-- Version:         1.0
-- Purpose:         Update a quote from a contract
--                  to a master contract
--                  Calls aso_quote_pub.CREATE_QUOTE to create the quote
-- In Parameters:   p_contract_id   Contract for which to create quote
--                  p_quote_id      Id of quote to be renewed
--
PROCEDURE update_quote_from_k( p_api_version     IN NUMBER
                              ,p_init_msg_list   IN VARCHAR2
			      ,p_quote_id	 IN OKX_QUOTE_HEADERS_V.ID1%TYPE
			      ,p_contract_id	 IN OKC_K_HEADERS_B.ID%TYPE
			      ,p_trace_mode      IN  VARCHAR2
                              ,x_return_status   OUT NOCOPY VARCHAR2
                              ,x_msg_count       OUT NOCOPY NUMBER
                              ,x_msg_data        OUT NOCOPY VARCHAR2
						)
IS

-- standard api variables
l_api_version           CONSTANT NUMBER := 1;
l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_Q_FROM_K';
l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_return_status2        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count             NUMBER := 0;
l_msg_data              VARCHAR2(1000);

-- miscellaneous variables
l_idx                   BINARY_INTEGER;  -- generic table index
m                   	BINARY_INTEGER;  -- generic table index
l_qte_creation_message  VARCHAR2(1000);
l_nb_qte_line_dtl       NUMBER;
l_aso_api_version       CONSTANT NUMBER := 1;
l_init_msg_count        NUMBER;
--
l_renew_rec             okc_renew_pub.renew_in_parameters_rec;
l_k_header_rec		c_k_header%ROWTYPE;
l_k_header_tl_rec	c_k_header_tl%ROWTYPE;
l_chrv_rec              okc_contract_pub.chrv_rec_type;
lx_chrv_rec             okc_contract_pub.chrv_rec_type;
l_rel_line_idx          BINARY_INTEGER;
l_k2q_line_rel_tab      okc_oc_int_config_pvt.line_rel_tab_type;  -- keeps track of k line to q line relation
l_hdr_price             NUMBER;
x_total_price             NUMBER;

x_line_rltship_tab          ASO_QUOTE_PUB.line_rltship_tbl_type;

-- variables for calling create_quote
l_control_rec               ASO_QUOTE_PUB.control_rec_type;
l_quote_header_rec          ASO_QUOTE_PUB.qte_header_rec_type;
l_quote_line_tab            ASO_QUOTE_PUB.qte_line_tbl_type;
l_quote_line_dtl_tab        ASO_QUOTE_PUB.qte_line_dtl_tbl_type;
l_quote_ln_shipment_tab     ASO_QUOTE_PUB.shipment_tbl_type;
l_hd_payment_tbl            ASO_QUOTE_PUB.payment_tbl_type;
l_quote_hd_shipment_tab     ASO_QUOTE_PUB.shipment_tbl_type;
l_hd_freight_charge_tbl     ASO_QUOTE_PUB.freight_charge_tbl_type;
l_hd_tax_detail_tbl         ASO_QUOTE_PUB.tax_detail_tbl_type;
l_line_attr_ext_tbl         ASO_QUOTE_PUB.line_attribs_ext_tbl_type;
l_line_rltship_tab          ASO_QUOTE_PUB.line_rltship_tbl_type;

--
l_quote_price_adj_tab       	ASO_QUOTE_PUB.price_adj_tbl_type;
l_quote_ln_price_adj_tab       	ASO_QUOTE_PUB.price_adj_tbl_type;

l_quote_price_adj_attr_tab  	ASO_QUOTE_PUB.price_adj_attr_tbl_type;
l_quote_ln_price_adj_attr_tab  	ASO_QUOTE_PUB.price_adj_attr_tbl_type;

l_quote_price_adj_rltship_tab   ASO_QUOTE_PUB.price_adj_rltship_tbl_type;
l_qt_ln_price_adj_rltship_tab   ASO_QUOTE_PUB.price_adj_rltship_tbl_type;

l_quote_ln_price_attr_tab   	ASO_QUOTE_PUB.price_attributes_tbl_type;
l_quote_hd_price_attr_tab   	ASO_QUOTE_PUB.price_attributes_tbl_type;

--

l_ln_payment_tbl            ASO_QUOTE_PUB.payment_tbl_type;
l_ln_tax_detail_tbl         ASO_QUOTE_PUB.tax_detail_tbl_type;

l_hd_attr_ext_tbl	    ASO_QUOTE_PUB.line_attribs_ext_tbl_type;
l_quote_hd_sales_credit_tab ASO_QUOTE_PUB.sales_credit_tbl_type;
l_hd_quote_party_tbl	    ASO_QUOTE_PUB.quote_party_tbl_type;
l_quote_ln_sales_credit_tab ASO_QUOTE_PUB.sales_credit_tbl_type;
l_ln_quote_party_tbl	    ASO_QUOTE_PUB.quote_party_tbl_type;

lx_hd_attr_ext_tbl	    ASO_QUOTE_PUB.line_attribs_ext_tbl_type;
lx_hd_sales_credit_tab 	    ASO_QUOTE_PUB.sales_credit_tbl_type;
lx_hd_quote_party_tbl	    ASO_QUOTE_PUB.quote_party_tbl_type;
lx_ln_sales_credit_tab      ASO_QUOTE_PUB.sales_credit_tbl_type;
lx_ln_quote_party_tbl	    ASO_QUOTE_PUB.quote_party_tbl_type;

lx_qte_header_rec           ASO_QUOTE_PUB.qte_header_rec_type;
lx_qte_line_tbl             ASO_QUOTE_PUB.qte_line_tbl_type;
lx_qte_line_dtl_tbl         ASO_QUOTE_PUB.qte_line_dtl_tbl_type;
lx_hd_price_attributes_tbl  ASO_QUOTE_PUB.price_attributes_tbl_type;
lx_hd_payment_tbl           ASO_QUOTE_PUB.payment_tbl_type;
lx_hd_shipment_tbl          ASO_QUOTE_PUB.shipment_tbl_type;
lx_hd_freight_charge_tbl    ASO_QUOTE_PUB.freight_charge_tbl_type;
lx_hd_tax_detail_tbl        ASO_QUOTE_PUB.tax_detail_tbl_type;
lx_line_attr_ext_tbl        ASO_QUOTE_PUB.line_attribs_ext_tbl_type;
lx_line_rltship_tbl         ASO_QUOTE_PUB.line_rltship_tbl_type;
lx_price_adjustment_tbl     ASO_QUOTE_PUB.price_adj_tbl_type;
lx_price_adj_attr_tbl       ASO_QUOTE_PUB.price_adj_attr_tbl_type;
lx_price_adj_rltship_tbl    ASO_QUOTE_PUB.price_adj_rltship_tbl_type;
lx_ln_price_attributes_tbl  ASO_QUOTE_PUB.price_attributes_tbl_type;
lx_ln_payment_tbl           ASO_QUOTE_PUB.payment_tbl_type;
lx_ln_shipment_tbl          ASO_QUOTE_PUB.shipment_tbl_type;
lx_ln_tax_detail_tbl        ASO_QUOTE_PUB.tax_detail_tbl_type;
lx_ln_freight_charge_tbl    ASO_QUOTE_PUB.freight_charge_tbl_type;



CALCULATE_TAX_FLAG		VARCHAR2(1) := 'Y';
CALCULATE_FREIGHT_CHARGE_FLAG	VARCHAR2(1) := 'Y';


BEGIN

  --
  -- housekeeping
  --

	l_quote_line_tab.DELETE;
	l_quote_line_dtl_tab.DELETE;

	l_quote_hd_shipment_tab.DELETE;
	l_quote_ln_shipment_tab.DELETE;

	l_k2q_line_rel_tab.DELETE;
	l_line_rltship_tab.DELETE;
	x_line_rltship_tab.DELETE;

	l_quote_hd_sales_credit_tab.DELETE;
	l_quote_ln_sales_credit_tab.DELETE;

	l_quote_price_adj_tab.DELETE;
	l_quote_ln_price_adj_tab.DELETE;

	l_quote_price_adj_attr_tab.DELETE;
	l_quote_ln_price_adj_attr_tab.DELETE;

	l_quote_price_adj_rltship_tab.DELETE;
	l_qt_ln_price_adj_rltship_tab.DELETE;

	l_quote_ln_price_attr_tab.DELETE;
	l_quote_hd_price_attr_tab.DELETE;


  IF (l_debug = 'Y') THEN
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, '>START - OKC_OC_INT_KTQ_PVT.CREATE_QUOTE_FROM_K -');
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, '================================================');
     okc_util.print_trace(0, 'STEP 1 : FETCH AND LOCK CONTRACT, AND INITIALIZE CONTEXT');
     okc_util.print_trace(0, '================================================');
     okc_util.print_trace(0, ' ');
  END IF;

  --
  -- housekeeping
  --

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, 'Initialize the message list');
  END IF;
  okc_api.init_msg_list(p_init_msg_list => p_init_msg_list);
  l_init_msg_count:=fnd_msg_pub.count_msg;

  --
  -- fetch the contract
  --
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'The Input contract id is '||p_contract_id);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, 'Fetch the contract');
  END IF;
  OPEN c_chr(p_contract_id);
  FETCH c_chr INTO l_chr;
  IF c_chr%NOTFOUND THEN
    -- no contract header is a fatal error
    okc_api.set_message(G_APP_NAME1,'OKO_K2Q_NOKHDRUPDT');
    CLOSE c_chr;
    x_return_status := OKC_API.G_RET_STS_ERROR;
    print_error(2);
    CLOSE c_chr;
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  CLOSE c_chr;

  -- need this for error messages
  IF l_chr.contract_number_modifier IS NOT NULL THEN
    l_k_nbr := l_chr.contract_number||'-'||l_chr.contract_number_modifier;
  ELSE
    l_k_nbr := l_chr.contract_number;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'The contract number for the given contract id is '||l_k_nbr);
  END IF;

  --
  -- lock the contract
  -- - to avoid a concurrent access to the contract for update, renewal...
  -- - to update contract comments
  --

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, 'Lock the contract');
  END IF;
  l_chrv_rec.id := p_contract_id;
  l_chrv_rec.object_version_number := l_chr.object_version_number;
  okc_contract_pub.lock_contract_header (
	p_api_version   => 1,
	p_init_msg_list => OKC_API.G_FALSE,
	x_return_status => l_return_status,
	x_msg_count     => l_msg_count,
	x_msg_data      => l_msg_data,
	p_chrv_rec      => l_chrv_rec);

  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR
     l_return_status = OKC_API.G_RET_STS_ERROR THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                           p_msg_name      => 'OKC_K2Q_KLOCKED',
                           p_token1        => 'NUMBER',
                           p_token1_value  => l_k_nbr);
       print_error(2);
  END IF; -- IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  --
  -- set organization context
  --

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, 'Set the contract context');
  END IF;
  IF p_contract_id IS NULL THEN
     OKC_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => 'OKC_K2Q_KIDISNULL');
	print_error(2);
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;
  okc_context.set_okc_org_context(p_chr_id => p_contract_id);
  IF p_trace_mode = okc_api.g_true AND okc_util.l_trace_flag THEN
     okc_util.l_complete_trace_file_name2 := '- Trace file = '|| okc_util.l_complete_trace_file_name;
  ELSE
     okc_util.l_complete_trace_file_name2 := '- Request Id = '|| okc_util.l_request_id;
  END IF;
  IF p_trace_mode = okc_api.g_true AND okc_util.l_trace_flag THEN
     OKC_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => 'OKC_K2Q_TRACEFILE',
                         p_token1        => 'TRACEFILE',
                         p_token1_value  => okc_util.l_complete_trace_file_name2);
  END IF;
  --
  -- fetch the contract
  --

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, 'Fetch the contract');
  END IF;
  OPEN c_k_header(p_contract_id);
  FETCH c_k_header INTO l_k_header_rec;
  CLOSE c_k_header;

  --
  --  Check up on contract eligibility for a quote creation
  --

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, '==========================================================');
     okc_util.print_trace(0, 'STEP 2 : CHECK CONTRACT ELIGIBILITY FOR THE QUOTE UPDATION');
     okc_util.print_trace(0, '==========================================================');
     okc_util.print_trace(0, ' ');
  END IF;
  validate_k_eligibility( l_k_header_rec,
			  p_quote_id,
			  l_return_status
			  );

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;


  --
  -- fetch the Quote
  --
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,' ');
     okc_util.print_trace(1,'The Input quote id is '||g_quote_id);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, 'Fetch the Quote');
  END IF;
  OPEN c_qhr(g_quote_id);
  FETCH c_qhr INTO l_qhr;

  IF c_qhr%NOTFOUND THEN
    -- no quote header is a fatal error
    okc_api.set_message(G_APP_NAME1,'OKO_K2Q_NOQHDRUPDT');
    CLOSE c_qhr;
    x_return_status := OKC_API.G_RET_STS_ERROR;
    print_error(2);
    CLOSE c_qhr;
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  CLOSE c_qhr;

  -- need this for error messages
  IF l_qhr.quote_version IS NOT NULL THEN
    l_q_nbr := l_qhr.quote_number||'-'||l_qhr.quote_version;
  ELSE
    l_q_nbr := l_qhr.quote_number;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1,'The quote number for the given quote id is '||l_q_nbr);
  END IF;


  --
  -- get the contract information
  --

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, '================================================');
     okc_util.print_trace(0, 'STEP 3 : BUILD CONTRACT STRUCTURES');
     okc_util.print_trace(0, '================================================');
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, 'The Input contract is '||p_contract_id);
     okc_util.print_trace(0, 'The Input quote is '||g_quote_id);
     okc_util.print_trace(0, 'The Input relationship is '||p_rel_code);
     okc_util.print_trace(0, 'The contract category is '||l_k_header_rec.scs_code);
     okc_util.print_trace(0, ' ');
  END IF;

  build_k_structures(p_contract_id,
	       --     p_quote_id,
		      p_rel_code,
		      l_k_header_rec,
		      l_return_status );

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  --
  -- populate quote header record
  --

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, '================================================');
     okc_util.print_trace(0, 'STEP 4 : BUILD QUOTE HEADER STRUCTURES');
     okc_util.print_trace(0, '================================================');
     okc_util.print_trace(0, ' ');
  END IF;
  build_qte_hdr(l_quote_header_rec,
	        l_quote_hd_shipment_tab,
		p_contract_id,
	--	p_quote_id,
	        p_rel_code,
	        l_return_status);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;


  --
  -- populate quote lines table, line details
  --

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, '================================================');
     okc_util.print_trace(0, 'STEP 5 : BUILD QUOTE LINE AND QUOTE DETAIL LINE STRUCTURES');
     okc_util.print_trace(0, '================================================');
     okc_util.print_trace(0, ' ');
  END IF;

  build_qte_line(
		 p_contract_id
		,l_quote_header_rec
		,l_quote_line_tab
                ,l_quote_line_dtl_tab
		,l_quote_ln_shipment_tab
                ,l_k2q_line_rel_tab
            --  ,x_total_price
		,x_line_rltship_tab
                ,l_return_status);


  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

-- l_quote_header_rec.total_quote_price := x_total_price;

  l_line_rltship_tab := x_line_rltship_tab;

  --
  -- populate pricing information fom the pricing API
  --

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, '=============================================================');
     okc_util.print_trace(0, 'STEP 6 : BUILD PRICING INFORMATION FOR QUOTE HEADER AND LINES');
     okc_util.print_trace(0, '==============================================================');
     okc_util.print_trace(0, ' ');
  END IF;


 -- Displaying the values of relation table, quote line table and
 -- quote line shipment table


 IF l_k2q_line_rel_tab.FIRST IS NOT NULL THEN
    FOR m IN l_k2q_line_rel_tab.FIRST..l_k2q_line_rel_tab.LAST LOOP
       IF (l_debug = 'Y') THEN
          okc_util.print_trace(2,'contract line id '||l_k2q_line_rel_tab(m).k_line_id);
          okc_util.print_trace(2,'K parent line id '||l_k2q_line_rel_tab(m).k_parent_line_id);
          okc_util.print_trace(2,'Quote line index '||l_k2q_line_rel_tab(m).q_line_idx);
          okc_util.print_trace(2,'Quote itm typ cod'||l_k2q_line_rel_tab(m).q_item_type_code);
       END IF;
    END LOOP;
 END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(2, '================================================');
  END IF;

 IF l_quote_line_tab.FIRST IS NOT NULL THEN
    FOR m IN l_quote_line_tab.FIRST..l_quote_line_tab.LAST LOOP
       IF (l_debug = 'Y') THEN
          okc_util.print_trace(2,'quote line id '||l_quote_line_tab(m).quote_line_id);
          okc_util.print_trace(2,'quote hdr id  '||l_quote_line_tab(m).quote_header_id);
          okc_util.print_trace(2,'op code       '||l_quote_line_tab(m).operation_code);
          okc_util.print_trace(2,'quote line #  '||l_quote_line_tab(m).line_number);
          okc_util.print_trace(2,'Inv item id   '||l_quote_line_tab(m).inventory_item_id);
          okc_util.print_trace(2,'quantity      '||l_quote_line_tab(m).quantity);
          okc_util.print_trace(2,'UOM code      '||l_quote_line_tab(m).uom_code);
       END IF;
    END LOOP;
 END IF;

  OKC_OC_INT_PRICING_PVT.build_pricing_from_k(p_chr_id	=>p_contract_id,
				p_kl_rel_tab	=>l_k2q_line_rel_tab,
			     --
				p_q_flag	=>OKC_API.G_TRUE,
				p_qhr_id	=>g_quote_id,
				p_qle_tab	=>l_quote_line_tab,
				p_qle_shipment_tab =>l_quote_ln_shipment_tab,
			     --
				x_hd_price_adj_tab =>l_quote_price_adj_tab,
				x_ln_price_adj_tab =>l_quote_ln_price_adj_tab,
			     --
				x_hd_price_adj_attr_tab =>l_quote_price_adj_attr_tab,
				x_ln_price_adj_attr_tab =>l_quote_ln_price_adj_attr_tab,
			     --
				x_hd_price_attr_tab =>l_quote_hd_price_attr_tab,
				x_ln_price_attr_tab =>l_quote_ln_price_attr_tab,
			     --
				x_hd_price_adj_rltship_tab =>l_quote_price_adj_rltship_tab,
				x_ln_price_adj_rltship_tab =>l_qt_ln_price_adj_rltship_tab,
			     --
				x_return_status		=> l_return_status );

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(0, 'count of l_quote_price_adj_tab = '||l_quote_price_adj_tab.count);
     okc_util.print_trace(0, 'count of l_quote_ln_price_adj_tab = '||l_quote_ln_price_adj_tab.count);
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, 'count of l_quote_price_adj_attr_tab = '||l_quote_price_adj_attr_tab.count);
     okc_util.print_trace(0, 'count of l_quote_ln_price_adj_attr_tab = '||l_quote_ln_price_adj_attr_tab.count);
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, 'count of l_quote_price_adj_rltship_tab = '||l_quote_price_adj_rltship_tab.count);
     okc_util.print_trace(0, 'count of l_quote_ln_price_adj_rltship_tab = '||l_qt_ln_price_adj_rltship_tab.count);
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, 'count of l_quote_head_price_attr_tab = '||l_quote_hd_price_attr_tab.count);
     okc_util.print_trace(0, 'count of l_quote_line_price_attr_tab = '||l_quote_ln_price_attr_tab.count);
  END IF;

  IF l_quote_ln_price_adj_tab.count > 0 THEN
     FOR i IN l_quote_ln_price_adj_tab.FIRST..l_quote_ln_price_adj_tab.LAST LOOP
        l_quote_price_adj_tab(l_quote_price_adj_tab.COUNT+1) := l_quote_ln_price_adj_tab(i);
     END LOOP;
  END IF;

  IF l_quote_ln_price_adj_attr_tab.count > 0 THEN
     FOR i IN l_quote_ln_price_adj_attr_tab.FIRST..l_quote_ln_price_adj_attr_tab.LAST LOOP
        l_quote_price_adj_attr_tab(l_quote_price_adj_attr_tab.COUNT+1) := l_quote_ln_price_adj_attr_tab(i);
     END LOOP;
  END IF;

  IF l_qt_ln_price_adj_rltship_tab.count > 0 THEN
     FOR i IN l_qt_ln_price_adj_rltship_tab.FIRST..l_qt_ln_price_adj_rltship_tab.LAST LOOP
        l_quote_price_adj_rltship_tab(l_quote_price_adj_rltship_tab.COUNT+1) := l_qt_ln_price_adj_rltship_tab(i);
     END LOOP;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(0,'===========================================');
     okc_util.print_trace(0, 'count of l_quote_price_adj_tab = '||l_quote_price_adj_tab.count);
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, 'count of l_quote_price_adj_attr_tab = '||l_quote_price_adj_attr_tab.count);
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, 'count of l_quote_price_adj_rltship_tab = '||l_quote_price_adj_rltship_tab.count);
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, 'count of l_quote_head_price_attr_tab = '||l_quote_hd_price_attr_tab.count);
     okc_util.print_trace(0, 'count of l_quote_line_price_attr_tab = '||l_quote_ln_price_attr_tab.count);
     okc_util.print_trace(0,'===========================================');
  END IF;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'====================================================================');
   okc_util.print_trace(1,'DISPLAYING THE PRICING PL/SQL TABLE INFO BEFORE CALLING UPDATE QUOTE');
   okc_util.print_trace(1,'====================================================================');
   okc_util.print_trace(1,'    ');
END IF;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'VALUES FROM l_quote_price_adj_tab');
   okc_util.print_trace(1,'    ');
END IF;

IF l_quote_price_adj_tab.count > 0 THEN
     FOR i IN l_quote_price_adj_tab.FIRST..l_quote_price_adj_tab.LAST LOOP
        IF (l_debug = 'Y') THEN
           okc_util.print_trace(1,'index value = '||i);
           okc_util.print_trace(1,'oper code   = '||l_quote_price_adj_tab(i).operation_code);
           okc_util.print_trace(1,'Price adj id= '||l_quote_price_adj_tab(i).price_adjustment_id);
           okc_util.print_trace(1,'qte hdr id  = '||l_quote_price_adj_tab(i).quote_header_id);
           okc_util.print_trace(1,'qte line id = '||l_quote_price_adj_tab(i).quote_line_id);
           okc_util.print_trace(1,'--------------------------------------------');
        END IF;
     END LOOP;
  END IF;

IF (l_debug = 'Y') THEN
   okc_util.print_trace(1,'    ');
   okc_util.print_trace(1,'VALUES FROM l_quote_price_adj_attr_tab');
   okc_util.print_trace(1,'    ');
END IF;

  IF l_quote_price_adj_attr_tab.count > 0 THEN
     FOR i IN l_quote_price_adj_attr_tab.FIRST..l_quote_price_adj_attr_tab.LAST LOOP
        IF (l_debug = 'Y') THEN
           okc_util.print_trace(1,'index value = '||i);
           okc_util.print_trace(1,'oper code   = '||l_quote_price_adj_attr_tab(i).operation_code);
           okc_util.print_trace(1,'Price adj id= '||l_quote_price_adj_attr_tab(i).price_adjustment_id);
           okc_util.print_trace(1,'--------------------------------------------');
        END IF;
     END LOOP;
  END IF;



  IF (l_debug = 'Y') THEN
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, '==================================================================');
     okc_util.print_trace(0, 'STEP 7 : BUILD SALES CREDIT INFORMATION FOR QUOTE HEADER AND LINES');
     okc_util.print_trace(0, '==================================================================');
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, ' ');
  END IF;

  OKC_OC_INT_SALESCDT_PVT.build_sales_credit_from_k(p_chr_id	=>p_contract_id,
				p_kl_rel_tab	=>l_k2q_line_rel_tab,
			     --
				p_q_flag	=>OKC_API.G_TRUE,
				p_qhr_id	=>g_quote_id,
				p_qle_tab	=>l_quote_line_tab,
			     --
				x_hd_sales_credit_tab =>l_quote_hd_sales_credit_tab,
				x_ln_sales_credit_tab =>l_quote_ln_sales_credit_tab,
			     --
				x_return_status		=> l_return_status );

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  --
  -- set control record, need to set additional attributes
  --

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(0, ' ');
     okc_util.print_trace(0, 'Initialize control record');
     okc_util.print_trace(1, '--------------------------------------------------------');
  END IF;
  l_control_rec.last_update_date := sysdate;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, '>START - ******* aso_quote_pub.UPDATE_QUOTE -');
  END IF;

  aso_quote_pub.update_quote(p_api_version_number         => l_aso_api_version
                            ,p_init_msg_list              => FND_API.G_FALSE
                            ,p_commit                     => FND_API.G_FALSE
			    ,p_validation_level		  => FND_API.G_VALID_LEVEL_FULL
                            ,p_control_rec                => l_control_rec
			--
                            ,p_qte_header_rec             => l_quote_header_rec
			--
                            ,p_hd_price_attributes_tbl    => l_quote_hd_price_attr_tab
                            ,p_hd_payment_tbl             => l_hd_payment_tbl
                            ,p_hd_shipment_tbl            => l_quote_hd_shipment_tab
                            ,p_hd_freight_charge_tbl      => l_hd_freight_charge_tbl
                            ,p_hd_tax_detail_tbl          => l_hd_tax_detail_tbl
			--
			    ,p_hd_attr_ext_tbl		  => l_hd_attr_ext_tbl
			    ,p_hd_sales_credit_tbl	  => l_quote_hd_sales_credit_tab
			    ,p_hd_quote_party_tbl	  => l_hd_quote_party_tbl
			--
                            ,p_qte_line_tbl               => l_quote_line_tab
                            ,p_qte_line_dtl_tbl           => l_quote_line_dtl_tab
			--
                            ,p_line_attr_ext_tbl          => l_line_attr_ext_tbl
                            ,p_line_rltship_tbl           => l_line_rltship_tab
			--
                            ,p_price_adjustment_tbl       => l_quote_price_adj_tab
                            ,p_price_adj_attr_tbl         => l_quote_price_adj_attr_tab
                            ,p_price_adj_rltship_tbl      => l_quote_price_adj_rltship_tab
                            ,p_ln_price_attributes_tbl    => l_quote_ln_price_attr_tab
			--
                            ,p_ln_payment_tbl             => l_ln_payment_tbl
                            ,p_ln_shipment_tbl            => l_quote_ln_shipment_tab
                            ,p_ln_freight_charge_tbl      => l_hd_freight_charge_tbl
                            ,p_ln_tax_detail_tbl          => l_ln_tax_detail_tbl
			--
			    ,p_ln_sales_credit_tbl	  => l_quote_ln_sales_credit_tab
			    ,p_ln_quote_party_tbl	  => l_ln_quote_party_tbl
			--
                            ,x_qte_header_rec             => lx_qte_header_rec
                            ,x_qte_line_tbl               => lx_qte_line_tbl
                            ,x_qte_line_dtl_tbl           => lx_qte_line_dtl_tbl
			--
                            ,x_hd_price_attributes_tbl    => lx_hd_price_attributes_tbl
                            ,x_hd_payment_tbl             => lx_hd_payment_tbl
                            ,x_hd_shipment_tbl            => lx_hd_shipment_tbl
                            ,x_hd_freight_charge_tbl      => lx_hd_freight_charge_tbl
                            ,x_hd_tax_detail_tbl          => lx_hd_tax_detail_tbl
			--
			    ,x_hd_attr_ext_tbl		  => lx_hd_attr_ext_tbl
			    ,x_hd_sales_credit_tbl	  => lx_hd_sales_credit_tab
			    ,x_hd_quote_party_tbl	  => lx_hd_quote_party_tbl
			--
                            ,x_line_attr_ext_tbl          => lx_line_attr_ext_tbl
                            ,x_line_rltship_tbl           => lx_line_rltship_tbl
			--
                            ,x_price_adjustment_tbl       => lx_price_adjustment_tbl
                            ,x_price_adj_attr_tbl         => lx_price_adj_attr_tbl
                            ,x_price_adj_rltship_tbl      => lx_price_adj_rltship_tbl
			--
                            ,x_ln_price_attributes_tbl    => lx_ln_price_attributes_tbl
			--
                            ,x_ln_payment_tbl             => lx_ln_payment_tbl
                            ,x_ln_shipment_tbl            => lx_ln_shipment_tbl
                            ,x_ln_freight_charge_tbl      => lx_ln_freight_charge_tbl
                            ,x_ln_tax_detail_tbl          => lx_ln_tax_detail_tbl
			--
			    ,x_ln_sales_credit_tbl	  => lx_ln_sales_credit_tab
			    ,x_ln_quote_party_tbl	  => lx_ln_quote_party_tbl
			--
                            ,x_return_status              => l_return_status
                            ,x_msg_count                  => l_msg_count
                            ,x_msg_data                   => l_msg_data
                            );

------------------------------------------------------------------------------------------------
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, '*******************');
  END IF;

IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

  FND_MSG_PUB.Count_And_Get (
                p_count =>      x_msg_count,
                p_data  =>      x_msg_data);

 FOR k in 1..x_msg_count LOOP
        x_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                      p_encoded   => 'F'
                                     );
        IF x_msg_data IS NOT NULL THEN
           IF (l_debug = 'Y') THEN
              okc_util.print_trace(0, 'Message      : '||x_msg_data);
                 okc_util.print_trace(0, ' ');
           END IF;
        END IF;
     END LOOP;
 END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, '*******************');
  END IF;

------------------------------------------------------------------------------------------------
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, '<END - ****** aso_quote_pub.UPDATE_QUOTE -');
     okc_util.print_trace(1, '--------------------------------------------------------');
     okc_util.print_trace(1, ' ');
     okc_util.print_trace(1, 'OUTPUT RECORD - Completion status:');
     okc_util.print_trace(1, '==================================');
     okc_util.print_trace(2, 'Return status        = '||l_return_status);
     okc_util.print_trace(1, ' ');
     okc_util.print_trace(1, 'OUTPUT RECORD - Quote Header:');
     okc_util.print_trace(1, '=============================');
     okc_util.print_trace(2, 'Org_id               = '||lx_qte_header_rec.org_id);
     okc_util.print_trace(2, 'Original syst ref (contract num) = '||ltrim(rtrim(lx_qte_header_rec.original_system_reference)));
     okc_util.print_trace(2, 'Quote name           = '||ltrim(rtrim(lx_qte_header_rec.quote_name)));
     okc_util.print_trace(2, 'Quote version        = '||lx_qte_header_rec.quote_version);
     okc_util.print_trace(2, 'Quote source code    = '||ltrim(rtrim(lx_qte_header_rec.quote_source_code)));
     okc_util.print_trace(2, 'Quote category code  = '||ltrim(rtrim(lx_qte_header_rec.quote_category_code)));
     okc_util.print_trace(2, 'Quote creation   date= '||lx_qte_header_rec.creation_date);
     okc_util.print_trace(2, 'Quote expiration date= '||lx_qte_header_rec.quote_expiration_date);
     okc_util.print_trace(2, 'Party_id             = '||lx_qte_header_rec.party_id);
     okc_util.print_trace(2, 'Cust Acct Id         = '||lx_qte_header_rec.cust_account_id);
     okc_util.print_trace(2, 'Price List Id        = '||lx_qte_header_rec.price_list_id);
     okc_util.print_trace(2, 'Inv Rule Id          = '||lx_qte_header_rec.invoicing_rule_id);
     okc_util.print_trace(2, 'Inv To Party Id      = '||lx_qte_header_rec.invoice_to_party_id);
     okc_util.print_trace(2, 'Inv To Party site Id = '||lx_qte_header_rec.invoice_to_party_site_id);
     okc_util.print_trace(2, 'Currency code        = '||ltrim(rtrim(lx_qte_header_rec.currency_code)));
     okc_util.print_trace(2, 'Total quote price    = '||LTRIM(TO_CHAR(lx_qte_header_rec.total_quote_price, '9G999G999G990D00')));
     okc_util.print_trace(2, 'Exchange type code   = '||ltrim(rtrim(lx_qte_header_rec.exchange_type_code)));
     okc_util.print_trace(2, 'Exchange rate        = '||lx_qte_header_rec.exchange_rate);
     okc_util.print_trace(2, 'Exchange rate date   = '||lx_qte_header_rec.exchange_rate_date);
     okc_util.print_trace(2, '---------------------------------------');
     okc_util.print_trace(2, 'Quote header Id      = '||lx_qte_header_rec.quote_header_id);
     okc_util.print_trace(2, 'Quote NUMBER         = '||lx_qte_header_rec.quote_number);
     okc_util.print_trace(2, 'Quote status Id      = '||lx_qte_header_rec.quote_status_id);
     okc_util.print_trace(2, 'Quote status code    = '||ltrim(rtrim(lx_qte_header_rec.quote_status_code)));
     okc_util.print_trace(2, 'Quote status         = '||ltrim(rtrim(lx_qte_header_rec.quote_status)));
  END IF;

  IF (l_debug = 'Y') THEN
     okc_util.print_trace(1, ' ');
     okc_util.print_trace(1, 'OUTPUT RECORD - Quote Lines: '||lx_qte_line_tbl.count||' line(s)');
     okc_util.print_trace(1, '============================');
  END IF;
  IF lx_qte_line_tbl.first IS NOT NULL THEN
    FOR i IN lx_qte_line_tbl.first..lx_qte_line_tbl.last LOOP
       IF (l_debug = 'Y') THEN
          okc_util.print_trace(2, '> Org Id                 = '||lx_qte_line_tbl(i).org_id);
          okc_util.print_trace(2, 'Quote Line NUMBER        = '||lx_qte_line_tbl(i).line_number);
          okc_util.print_trace(2, 'Quote Line category code = '||ltrim(rtrim(lx_qte_line_tbl(i).line_category_code)));
          okc_util.print_trace(2, 'Start date active        = '||lx_qte_line_tbl(i).start_date_active);
          okc_util.print_trace(2, 'End date active          = '||lx_qte_line_tbl(i).end_date_active);
       END IF;
	  --
       IF (l_debug = 'Y') THEN
          okc_util.print_trace(2, 'Price List Id            = '||lx_qte_line_tbl(i).price_list_id);
          okc_util.print_trace(2, 'Inv Rule Id              = '||lx_qte_line_tbl(i).invoicing_rule_id);
          okc_util.print_trace(2, 'Inv To Party Id          = '||lx_qte_line_tbl(i).invoice_to_party_id);
          okc_util.print_trace(2, 'Inv To Party site Id     = '||lx_qte_line_tbl(i).invoice_to_party_site_id);
       END IF;
	  --
       IF (l_debug = 'Y') THEN
          okc_util.print_trace(2, 'Inv Item Id              = '||lx_qte_line_tbl(i).inventory_item_id);
          okc_util.print_trace(2, 'Organization Id          = '||lx_qte_line_tbl(i).organization_id);
          okc_util.print_trace(2, 'Quantity                 = '||lx_qte_line_tbl(i).quantity);
          okc_util.print_trace(2, 'UOM                      = '||lx_qte_line_tbl(i).uom_code);
          okc_util.print_trace(2, 'Currency code            = '||lx_qte_line_tbl(i).currency_code);
          okc_util.print_trace(2, 'Quote line unit price    = '||LTRIM(TO_CHAR(lx_qte_line_tbl(i).line_quote_price, '9G999G999G990D00')));
          okc_util.print_trace(2, 'Quote line price         = '||LTRIM(TO_CHAR(lx_qte_line_tbl(i).line_quote_price*lx_qte_line_tbl(i).quantity, '9G999G999G990D00')));
          okc_util.print_trace(2, '---------------------------------------');
          okc_util.print_trace(2, 'Quote Header Id          = '||lx_qte_line_tbl(i).quote_header_id);
          okc_util.print_trace(2, 'Quote Line Id            = '||lx_qte_line_tbl(i).quote_line_id);
       END IF;

       IF lx_qte_line_dtl_tbl.first IS NOT NULL THEN
          IF (l_debug = 'Y') THEN
             okc_util.print_trace(1, ' ');
             okc_util.print_trace(3, 'OUTPUT RECORD - Quote Detail Lines:');
             okc_util.print_trace(3, '===================================');
          END IF;
		l_nb_qte_line_dtl:=0;
          FOR j IN lx_qte_line_dtl_tbl.first..lx_qte_line_dtl_tbl.last LOOP
		   IF lx_qte_line_dtl_tbl(j).qte_line_index = lx_qte_line_tbl(i).line_number THEN
		   l_nb_qte_line_dtl:=l_nb_qte_line_dtl+1;
             IF (l_debug = 'Y') THEN
                okc_util.print_trace(4, '>> Quote Line NUMBER      = '||lx_qte_line_dtl_tbl(j).qte_line_index);
                okc_util.print_trace(4, 'Service Ref type code     = '||lx_qte_line_dtl_tbl(j).service_ref_type_code);
                okc_util.print_trace(4, 'Service Ref Syst Id       = '||lx_qte_line_dtl_tbl(j).service_ref_system_id);
                okc_util.print_trace(4, 'Service Ref Line Id       = '||lx_qte_line_dtl_tbl(j).service_ref_line_id);
             END IF;
           --okc_util.print_trace(4, 'Service Ref Line Num      = '||lx_qte_line_dtl_tbl(j).service_ref_line_number);
             IF (l_debug = 'Y') THEN
                okc_util.print_trace(4, 'Service Ref Line Num      = '||lx_qte_line_dtl_tbl(j).service_ref_qte_line_index);
                okc_util.print_trace(4, 'Service Ref Qte Line Idx  = '||lx_qte_line_dtl_tbl(j).service_ref_qte_line_index);
                okc_util.print_trace(4, 'Service Ref Order Num     = '||lx_qte_line_dtl_tbl(j).service_ref_order_number);
                okc_util.print_trace(4, 'Service duration          = '||lx_qte_line_dtl_tbl(j).service_duration);
                okc_util.print_trace(4, 'Service period            = '||lx_qte_line_dtl_tbl(j).service_period);
             END IF;

             IF (l_debug = 'Y') THEN
                okc_util.print_trace(4, 'config_header_id          = '||lx_qte_line_dtl_tbl(j).config_header_id);
                okc_util.print_trace(4, 'config_rev num            = '||lx_qte_line_dtl_tbl(j).config_revision_num);
                okc_util.print_trace(4, 'config_item_id            = '||lx_qte_line_dtl_tbl(j).config_item_id);
                okc_util.print_trace(4, 'comp conf flag            = '||lx_qte_line_dtl_tbl(j).complete_configuration_flag);
                okc_util.print_trace(4, 'valid conf flag           = '||lx_qte_line_dtl_tbl(j).valid_configuration_flag);
                okc_util.print_trace(4, 'component_code            = '||lx_qte_line_dtl_tbl(j).component_code);
             END IF;

             IF (l_debug = 'Y') THEN
                okc_util.print_trace(4, '---------------------------------------');
                okc_util.print_trace(4, 'Quote Line Id             = '||lx_qte_line_dtl_tbl(j).quote_line_id);
                okc_util.print_trace(4, 'Quote Detail Line Id      = '||lx_qte_line_dtl_tbl(j).quote_line_detail_id);
                okc_util.print_trace(4, '                                       ');
             END IF;
		   END IF;
	      END LOOP;
		 IF l_nb_qte_line_dtl=0 THEN
             IF (l_debug = 'Y') THEN
                okc_util.print_trace(4, 'NO Quote Detail Lines');
             END IF;
		 END IF;
       ELSE
          IF (l_debug = 'Y') THEN
             okc_util.print_trace(3, ' ');
             okc_util.print_trace(3, 'OUTPUT RECORD - Quote Detail Lines:');
             okc_util.print_trace(3, '===================================');
             okc_util.print_trace(4, 'NO Quote Detail Lines');
          END IF;
       END IF;
       IF (l_debug = 'Y') THEN
          okc_util.print_trace(2, '                                       ');
       END IF;
    END LOOP qteline;
  ELSE
	IF (l_debug = 'Y') THEN
   	okc_util.print_trace(2, 'NO Quote Lines');
	END IF;
  END IF;
  IF (l_debug = 'Y') THEN
     okc_util.print_trace(2, '                                       ');
  END IF;

  --
  -- Contract updating with quote information waiting for
  -- a specific notification creation
  --

  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR
     l_return_status = OKC_API.G_RET_STS_ERROR THEN
	--l_qte_updation_message :=
     --		 'An Error occurred while updating a quote' || ' ';
     --IF p_trace_mode = okc_api.g_true THEN
	--   l_qte_updation_message := l_qte_updation_message ||
     --      '- Trace file = '|| okc_util.l_complete_trace_file_name;
     --ELSE
	--   l_qte_updation_message := l_qte_updation_message ||
	--	 '- Please try again with trace mode active';
     --END IF;
     lx_qte_header_rec.creation_date:=SYSDATE;
  ELSE
	--SELECT DECODE(lx_qte_header_rec.creation_date, fnd_api.g_miss_date,
	--	  TRUNC(l_control_rec.last_update_date),
	--	  lx_qte_header_rec.creation_date)
     --INTO lx_qte_header_rec.creation_date
	--FROM DUAL;

     OKC_API.set_message(p_app_name      => g_app_name,
                         p_msg_name      => 'OKC_K2Q_K2QCOMMENTS',
                         p_token1        => 'CRDATE',
                         p_token1_value  => lx_qte_header_rec.creation_date,
                         p_token2        => 'NUMBER',
                         p_token2_value  => lx_qte_header_rec.quote_number,
                         p_token3        => 'VERSION',
                         p_token3_value  => lx_qte_header_rec.quote_version,
                         p_token4        => 'EXDATE',
                         p_token4_value  => lx_qte_header_rec.quote_expiration_date,
                         p_token5        => 'TRACEFILE',
                         p_token5_value  => okc_util.l_complete_trace_file_name2
	    			    );
     FND_MSG_PUB.Count_And_Get (
		p_count	=> 	x_msg_count,
		p_data	=> 	x_msg_data);
     x_msg_data := fnd_msg_pub.get(
		p_msg_index => x_msg_count,
          p_encoded   => 'F');

	l_qte_creation_message := x_msg_data;
     FND_MSG_PUB.Delete_Msg ( p_msg_index	=> 	x_msg_count);

END IF;
EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    --update_k_comments_err;
    IF c_k_header%ISOPEN THEN
	     CLOSE c_k_header;
    END IF;
    IF c_k_header_tl%ISOPEN THEN
	     CLOSE c_k_header_tl;
    END IF;
    IF c_hdr_subject_to%ISOPEN THEN
	     CLOSE c_hdr_subject_to;
    END IF;
    x_return_status := OKC_API.G_RET_STS_ERROR;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name
                             ,p_procedure_name => l_api_name
                             ,p_error_text     => 'Encountered error condition'
                             );
    END IF;

    --Error messages for the trace file
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(4, ' ');
       okc_util.print_trace(4, '==================================');
       okc_util.print_trace(5, 'Error while creating quote:');
       okc_util.print_trace(5, 'Return status: '||x_return_status);
       okc_util.print_trace(4, '==================================');
    END IF;
    --Error messages for the output file
    IF okc_util.l_output_flag THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                        p_msg_name      => 'OKC_K2Q_K2QOUTEMSG',
                        p_token1        => 'CRDATE',
                        p_token1_value  => lx_qte_header_rec.creation_date,
                        p_token2        => 'KNUMBER',
                        p_token2_value  => l_chr.contract_number,
                        p_token3        => 'KMODIFIER',
                        p_token3_value  => NVL(l_chr.contract_number_modifier, ' ')
      			    );
       FND_MSG_PUB.Count_And_Get (
		p_count	=> 	x_msg_count,
		p_data	=> 	x_msg_data);
       x_msg_data := fnd_msg_pub.get(
		p_msg_index => x_msg_count,
          p_encoded   => 'F');

       l_qte_creation_message := x_msg_data;
       FND_MSG_PUB.Delete_Msg ( p_msg_index	=> 	x_msg_count);

       okc_util.print_output(0, l_qte_creation_message);
    END IF;
    FND_MSG_PUB.Count_And_Get (
		p_count	=> 	x_msg_count,
		p_data	=> 	x_msg_data);
    FOR k in l_init_msg_count..x_msg_count LOOP
       x_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                      p_encoded   => 'F'
                                     );
       IF x_msg_data IS NOT NULL THEN
          IF (l_debug = 'Y') THEN
             okc_util.print_trace(5, 'Message      : '||x_msg_data);
   	     okc_util.print_trace(5, ' ');
          END IF;
		IF okc_util.l_output_flag THEN
             okc_util.print_output(0, 'Message      : '||x_msg_data);
	        okc_util.print_output(0, ' ');
		END IF;
       END IF;
    END LOOP;
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(4, '==================================');
    END IF;
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF c_k_header%ISOPEN THEN
	     CLOSE c_k_header;
    END IF;
    IF c_k_header_tl%ISOPEN THEN
	     CLOSE c_k_header_tl;
    END IF;
    IF c_hdr_subject_to%ISOPEN THEN
	     CLOSE c_hdr_subject_to;
    END IF;
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name
                             ,p_procedure_name => l_api_name
                             ,p_error_text     => 'Encountered unexpected error'
                             );
    END IF;

    --Error messages for the trace file
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(4, ' ');
       okc_util.print_trace(4, '==================================');
       okc_util.print_trace(5, 'Error while updating quote:');
       okc_util.print_trace(5, 'Return status: '||x_return_status);
       okc_util.print_trace(4, '==================================');
    END IF;
    --Error messages for the output file
    IF okc_util.l_output_flag THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                        p_msg_name      => 'OKC_K2Q_K2QOUTEMSG',
                        p_token1        => 'CRDATE',
                        p_token1_value  => lx_qte_header_rec.creation_date,
                        p_token2        => 'KNUMBER',
                        p_token2_value  => l_chr.contract_number,
                        p_token3        => 'KMODIFIER',
                        p_token3_value  => NVL(l_chr.contract_number_modifier, ' ')
      			    );
       FND_MSG_PUB.Count_And_Get (
		p_count	=> 	x_msg_count,
		p_data	=> 	x_msg_data);
       x_msg_data := fnd_msg_pub.get(
		p_msg_index => x_msg_count,
          p_encoded   => 'F');

       l_qte_creation_message := x_msg_data;
       FND_MSG_PUB.Delete_Msg ( p_msg_index	=> 	x_msg_count);

       okc_util.print_output(0, l_qte_creation_message);
    END IF;
    FND_MSG_PUB.Count_And_Get (
		p_count	=> 	x_msg_count,
		p_data	=> 	x_msg_data);
    FOR k in l_init_msg_count..x_msg_count LOOP
       x_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                      p_encoded   => 'F'
                                     );
       IF x_msg_data IS NOT NULL THEN
          IF (l_debug = 'Y') THEN
             okc_util.print_trace(5, 'Message      : '||x_msg_data);
   	     okc_util.print_trace(5, ' ');
          END IF;
		IF okc_util.l_output_flag THEN
             okc_util.print_output(0, 'Message      : '||x_msg_data);
	        okc_util.print_output(0, ' ');
		END IF;
       END IF;
    END LOOP;
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(4, '==================================');
    END IF;
  WHEN OTHERS THEN
    --update_k_comments_err;
    IF c_k_header%ISOPEN THEN
	     CLOSE c_k_header;
    END IF;
    IF c_k_header_tl%ISOPEN THEN
	     CLOSE c_k_header_tl;
    END IF;
    IF c_hdr_subject_to%ISOPEN THEN
	     CLOSE c_hdr_subject_to;
    END IF;
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME
                       ,G_UNEXPECTED_ERROR
                       ,G_SQLCODE_TOKEN
                       ,SQLCODE
                       ,G_SQLERRM_TOKEN
                       ,SQLERRM);

    --Error messages for the trace file
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(4, ' ');
       okc_util.print_trace(4, '==================================');
       okc_util.print_trace(5, 'Error while updating quote:');
       okc_util.print_trace(5, 'Return status: '||x_return_status);
       okc_util.print_trace(4, '==================================');
    END IF;
    --Error messages for the output file
    IF okc_util.l_output_flag THEN
       OKC_API.set_message(p_app_name      => g_app_name,
                        p_msg_name      => 'OKC_K2Q_K2QOUTEMSG',
                        p_token1        => 'CRDATE',
                        p_token1_value  => lx_qte_header_rec.creation_date,
                        p_token2        => 'KNUMBER',
                        p_token2_value  => l_chr.contract_number,
                        p_token3        => 'KMODIFIER',
                        p_token3_value  => NVL(l_chr.contract_number_modifier, ' ')
      			    );
       FND_MSG_PUB.Count_And_Get (
		p_count	=> 	x_msg_count,
		p_data	=> 	x_msg_data);
       x_msg_data := fnd_msg_pub.get(
		p_msg_index => x_msg_count,
          p_encoded   => 'F');

       l_qte_creation_message := x_msg_data;
       FND_MSG_PUB.Delete_Msg ( p_msg_index	=> 	x_msg_count);

       okc_util.print_output(0, l_qte_creation_message);
    END IF;
    FND_MSG_PUB.Count_And_Get (
		p_count	=> 	x_msg_count,
		p_data	=> 	x_msg_data);
    FOR k in l_init_msg_count..x_msg_count LOOP
       x_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                      p_encoded   => 'F'
                                     );
       IF x_msg_data IS NOT NULL THEN
          IF (l_debug = 'Y') THEN
             okc_util.print_trace(5, 'Message      : '||x_msg_data);
   	     okc_util.print_trace(5, ' ');
          END IF;
		IF okc_util.l_output_flag THEN
             okc_util.print_output(0, 'Message      : '||x_msg_data);
	        okc_util.print_output(0, ' ');
		END IF;
       END IF;
    END LOOP;
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(4, '==================================');
    END IF;

END update_quote_from_k;
--
-- initialization section
--

BEGIN
  --
IF (l_debug = 'Y') THEN
   okc_util.print_trace(0,'Starting OKC_OC_INT_KTQ_PVT Initialization');
   okc_util.print_trace(0,'==========================================');
END IF;

  -- load the table with the line styles that need to be processed
  -- in a specific manner while creating a quote or an order
  --
  l_line_with_cover_prod_qc_tab(1) := g_lt_ext_warr;
  l_line_with_cover_prod_qc_tab(2) := g_lt_service;
  l_line_with_cover_prod_qc_tab(3) := g_lt_support;

END OKC_OC_INT_KTQ_PVT;

/
