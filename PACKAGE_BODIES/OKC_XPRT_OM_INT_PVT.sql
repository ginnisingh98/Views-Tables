--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_OM_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_OM_INT_PVT" AS
/* $Header: OKCVXOMINTB.pls 120.8.12010000.3 2009/08/10 10:51:06 nvvaidya ship $ */

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------

  G_FALSE                       CONSTANT VARCHAR2(1)    := FND_API.G_FALSE;
  G_TRUE                        CONSTANT VARCHAR2(1)    := FND_API.G_TRUE;

  G_RET_STS_SUCCESS             CONSTANT VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR               CONSTANT VARCHAR2(1)    := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR         CONSTANT VARCHAR2(1)    := FND_API.G_RET_STS_UNEXP_ERROR;

  G_PKG_NAME                    CONSTANT VARCHAR2(30)   := 'OKC_XPRT_OM_INT_PVT';
  G_MODULE_NAME			  CONSTANT VARCHAR2(250)  := 'OKC.PLSQL.'||G_PKG_NAME||'.';
  G_STMT_LEVEL				  CONSTANT NUMBER 		 := FND_LOG.LEVEL_STATEMENT;
  G_APP_NAME				  CONSTANT VARCHAR2(3)    := OKC_API.G_APP_NAME;

  G_ITEM_CODE                   CONSTANT VARCHAR2(30)   := 'OKC$S_ITEM';
  G_ITEM_CATEGORY_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_ITEM_CATEGORY';
  G_PA_NAME_CODE                CONSTANT VARCHAR2(30)   := 'OKC$S_PA_NAME';
  G_PA_NAME_EXIST_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_PRC_AGR_EXIST';
  G_CUSTOMER_NAME_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_CUSTOMER_NAME';
  G_CURRENCY_CODE               CONSTANT VARCHAR2(30)   := 'OKC$S_CURRENCY_CODE';
  G_FREIGHT_TERMS_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_FREIGHT_TERMS';
  G_SHIPPING_METHOD_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_SHIPPING_METHOD';
  G_PAYMENT_TERM_CODE           CONSTANT VARCHAR2(30)   := 'OKC$S_PAYMENT_TERM';
  G_BILLTO_COUNTRY_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_BILLTO_COUNTRY';
  G_SHIPTO_COUNTRY_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_SHIPTO_COUNTRY';
  G_SOLDTO_COUNTRY_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_SOLDTO_COUNTRY';
  G_BLKT_AGR_TYPE_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_BLANKET_AGREEMENT_TYPE';
  G_CUST_PO_EXIST_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_PO_EXIST';
  G_INVOICING_RULE_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_INVOICING_RULE';
  G_PRICE_LIST_CODE             CONSTANT VARCHAR2(30)   := 'OKC$S_PRICE_LIST';
  G_MIN_AMT_AGREED_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_MIN_AMOUNT_AGREED';
  G_MAX_AMT_AGREED_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_MAX_AMOUNT_AGREED';
  G_TAX_HANDL_CODE			  CONSTANT VARCHAR2(30)   := 'OKC$S_TAX_HANDL';
  G_ORDER_TYPE_CODE         	  CONSTANT VARCHAR2(30)   := 'OKC$S_ORDER_TYPE';
  G_FOB_CODE				  CONSTANT VARCHAR2(30)   := 'OKC$S_FOB';
  G_PAYMENT_TYPE_CODE           CONSTANT VARCHAR2(30)   := 'OKC$S_PAYMENT_TYPE';
  G_SALES_CHANNEL_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_SALES_CHANNEL';
  G_END_CUST_CODE			  CONSTANT VARCHAR2(30)   := 'OKC$S_END_CUST';
  G_END_CUST_EXIST_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_END_CUST_EXIST';
  G_TOTAL_CODE				  CONSTANT VARCHAR2(30)   := 'OKC$S_TOTAL';
  G_TOTAL_ADJUST_AMT_CODE       CONSTANT VARCHAR2(30)   := 'OKC$S_ADJUST_AMOUNT';
  G_TOTAL_ADJUST_PCT_CODE       CONSTANT VARCHAR2(30)   := 'OKC$S_ADJUST_PERCENT';
  G_BLKT_NUM_EXIST_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_BLKT_NUM_EXIST';
  G_BILLTO_CUST_NAME_CODE       CONSTANT VARCHAR2(30)   := 'OKC$S_BILLTO_CUST_NAME';
  G_SHIPTO_CUST_NAME_CODE       CONSTANT VARCHAR2(30)   := 'OKC$S_SHIPTO_CUST_NAME';
  G_SALES_DOC_TYPE_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_SALES_DOC_TYPE';
  G_CUST_CATEGORY_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_CAT';
  G_CUST_CLASS_CODE             CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_CLASS';
  G_CUST_PROF_CLASS_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_PROF_CLASS';
  G_CUST_CRDT_RATE_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_CRDT_RATE';
  G_CUST_CRDT_CLASS_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_CRDT_CLASS';
  G_CUST_RISK_CODE              CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_RISK_CODE';

  ---6899074: New bill to ship to and deliver to system variables
   G_BILL_TO_CITY_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_BILL_TO_CITY';
 G_DELIVER_TO_CITY_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_DELIVER_TO_CITY';
 G_SHIP_TO_LOCATION_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_SHIP_TO_LOCATION';
 G_SHIP_TO_ADDRESS1_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_SHIP_TO_ADDRESS1';
 G_SHIP_TO_ADDRESS2_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_SHIP_TO_ADDRESS2';
 G_SHIP_TO_ADDRESS3_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_SHIP_TO_ADDRESS3';
 G_SHIP_TO_ADDRESS4_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_SHIP_TO_ADDRESS4';
 G_SHIP_TO_CITY_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_SHIP_TO_CITY';
 G_SHIP_TO_COUNTY_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_SHIP_TO_COUNTY';
 G_SHIP_TO_STATE_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_SHIP_TO_STATE';
 G_SHIP_TO_PROVINCE_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_SHIP_TO_PROVINCE';
 G_SHIP_TO_POSTAL_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_SHIP_TO_POSTAL_CODE';
 G_BILL_TO_LOCATION_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_BILL_TO_LOCATION';
 G_BILL_TO_ADDRESS1_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_BILL_TO_ADDRESS1';
 G_BILL_TO_ADDRESS2_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_BILL_TO_ADDRESS2';
 G_BILL_TO_ADDRESS3_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_BILL_TO_ADDRESS3';
 G_BILL_TO_ADDRESS4_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_BILL_TO_ADDRESS4';
 G_BILL_TO_COUNTY_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_BILL_TO_COUNTY';
 G_BILL_TO_STATE_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_BILL_TO_STATE';
 G_BILL_TO_PROVINCE_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_BILL_TO_PROVINCE';
 G_BILL_TO_POSTAL_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_BILL_TO_POSTAL_CODE';
 G_DELIVER_TO_LOCATION_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_DELIVER_TO_LOCATION';
 G_DELIVER_TO_ADDRESS1_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_DELIVER_TO_ADDRESS1';
 G_DELIVER_TO_ADDRESS2_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_DELIVER_TO_ADDRESS2';
 G_DELIVER_TO_ADDRESS3_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_DELIVER_TO_ADDRESS3';
 G_DELIVER_TO_ADDRESS4_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_DELIVER_TO_ADDRESS4';
 G_DELIVER_TO_COUNTY_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_DELIVER_TO_COUNTY';
 G_DELIVER_TO_STATE_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_DELIVER_TO_STATE';
 G_DELIVER_TO_PROVINCE_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_DELIVER_TO_PROVINCE';
 G_DELIVER_TO_POSTAL_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_DELIVER_TO_POSTAL_CODE';
 G_DELIVER_TO_COUNTRY_CODE	CONSTANT	VARCHAR2(30) :=		 'OKC$S_DELIVER_TO_COUNTRY';
G_PRICE_LIST_NAME_CODE	CONSTANT	VARCHAR2(30) :=	'OKC$S_PRICE_LIST_NAME';

---end- 6899074: New bill to ship to and deliver to system variables



-- XY
  G_ORDER_NUMBER_CODE             CONSTANT VARCHAR2(30)   := 'OKC$S_ORDER_NUMBER';
  G_BLANKET_NUMBER_CODE           CONSTANT VARCHAR2(30)   := 'OKC$S_BLANKET_NUMBER';
  G_PA_NUMBER_CODE                CONSTANT VARCHAR2(30)   := 'OKC$S_PA_NUMBER';
  G_QUOTE_NUMBER_CODE             CONSTANT VARCHAR2(30)   := 'OKC$S_QUOTE_NUMBER';
  G_CUSTOMER_NUMBER_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_CUSTOMER_NUMBER';
  G_CUST_PO_NUMBER_CODE           CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_PO_NUMBER';
  G_VERSION_NUMBER_CODE           CONSTANT VARCHAR2(30)   := 'OKC$S_VERSION_NUMBER';
  G_CUST_CONTACT_NAME_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_CONTACT_NAME';
  G_SALESREP_NAME_CODE            CONSTANT VARCHAR2(30)   := 'OKC$S_SALESREP_NAME';
  G_CURRENCY_NAME_CODE            CONSTANT VARCHAR2(30)   := 'OKC$S_CURRENCY_NAME';
  G_CURRENCY_SYMBOL_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_CURRENCY_SYMBOL';
  G_SUPPLIER_NAME_CODE            CONSTANT VARCHAR2(30)   := 'OKC$S_SUPPLIER_NAME';
  G_ACTIVATION_DATE_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_ACTIVATION_DATE';
  G_EXPIRATION_DATE_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_EXPIRATION_DATE';
-- XY
  G_PA_TYPE_CODE                  CONSTANT VARCHAR2(30)   := 'OKC$S_PA_TYPE';

  -- Added for line level variables
  G_LINE_PAYMENT_TERM_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_LINE_PAYMENT_TERM';
  G_LINE_PA_NAME_CODE             CONSTANT VARCHAR2(30)   := 'OKC$S_LINE_PA_NAME';
  G_LINE_INVOICING_RULE_CODE      CONSTANT VARCHAR2(30)   := 'OKC$S_LINE_INVOICING_RULE';

  -- Added ro resolve bugs 5300044 and 5299978
  G_SHIPMENT_PRIORITY_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_SHIPMENT_PRIORITY';
  G_SITE_ID_CODE                  CONSTANT VARCHAR2(30)   := 'OKC$S_SITE_ID';

PROCEDURE get_clause_variable_values
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_sys_var_value_tbl          IN OUT NOCOPY OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)

IS

l_api_name 		VARCHAR2(30) := 'get_clause_variable_values';
l_package_procedure VARCHAR2(60);
l_api_version 		CONSTANT NUMBER := 1;
l_debug			Boolean;
l_module			VARCHAR2(250)   := G_MODULE_NAME||l_api_name;

l_sold_to_site_use_id 	NUMBER := NULL;
l_sold_to_org_id 		NUMBER := NULL;
l_invoice_to_site_use_id	NUMBER := NULL;
l_ship_to_site_use_id	NUMBER := NULL;
l_deliver_to_site_use_id        NUMBER := NULL;    --- bug 6899074
l_expert_yes        FND_FLEX_VALUES.FLEX_VALUE_ID%type;
l_expert_no         FND_FLEX_VALUES.FLEX_VALUE_ID%type;


--
-- Cursor to fetch the flex value id for Yes and No from the OKC_XPRT_YES_NO value set
--
CURSOR c_get_expert_yes_no(p_yes_no VARCHAR2) IS
select a.FLEX_VALUE_ID
from fnd_flex_values a, fnd_flex_value_sets b
where b.flex_value_set_name = 'OKC_XPRT_YES_NO'
and a.FLEX_VALUE_SET_ID = b.FLEX_VALUE_SET_ID
and a.FLEX_VALUE = p_yes_no;


  --
  --cursor to fetch value of header level variables such as OKC$S_BLANKET_NUMBER etc. for blankets
  --
  CURSOR c_get_bsa_header_variables IS
  SELECT
	    bh.agreement_id,
--	    decode(nvl(to_char(bh.agreement_id),'X'),'X','N','Y') price_agr_exist,
	    decode(nvl(to_char(bh.agreement_id),'X'),'X',l_expert_no,l_expert_yes) price_agr_exist,
         bh.sold_to_org_id,
         bh.invoice_to_org_id,
         bh.ship_to_org_id,
         bh.deliver_to_org_id,
	    bh.sold_to_site_use_id,
         bh.order_type_id,
--	    decode(nvl(bh.cust_po_number,'X'),'X','N','Y') cust_po_num_exist,
	    decode(nvl(bh.cust_po_number,'X'),'X',l_expert_no,l_expert_yes) cust_po_num_exist,
         bh.transactional_curr_code,
         bh.freight_terms_code,
         bh.shipping_method_code,
         bh.payment_term_id,
         bh.invoicing_rule_id,
	    bh.tax_exempt_flag,
	    bh.price_list_id,
         bh.org_id,
         bhe.blanket_min_amount,
         bhe.blanket_max_amount,
-- XY
	    bh.order_number,
	    bh.cust_po_number,
	    bh.version_number,
	    bh.sold_to_contact_id,
	    bh.salesrep_id,
	    bhe.start_date_active,
	    bhe.end_date_active
-- XY
  FROM
            oe_blanket_headers_ext bhe,
	    oe_blanket_headers_all bh
  WHERE
    	    bh.order_number = bhe.order_number
    AND     bh.header_id = p_doc_id;

  --
  --cursor to fetch value of header level variables such as OKC$S_ORDER_NUMBER etc. for sales orders
  --
  CURSOR c_get_so_header_variables IS
  SELECT
	    oh.blanket_number,
--	    decode(nvl(to_char(oh.blanket_number),'X'),'X','N','Y') blanket_number_exist,
	    decode(nvl(to_char(oh.blanket_number),'X'),'X',l_expert_no,l_expert_yes) blanket_number_exist,
         oh.agreement_id,
--	    decode(nvl(to_char(oh.agreement_id),'X'),'X','N','Y') price_agr_exist,
	    decode(nvl(to_char(oh.agreement_id),'X'),'X',l_expert_no,l_expert_yes) price_agr_exist,
         oh.sold_to_org_id,
         oh.invoice_to_org_id,
         oh.ship_to_org_id,
         oh.deliver_to_org_id,
         oh.sold_to_site_use_id,
--	    decode(nvl(oh.cust_po_number,'X'),'X','N','Y') cust_po_num_exist,
	    decode(nvl(oh.cust_po_number,'X'),'X',l_expert_no,l_expert_yes) cust_po_num_exist,
         oh.transactional_curr_code,
         oh.freight_terms_code,
         oh.shipping_method_code,
         oh.payment_term_id,
         oh.invoicing_rule_id,
         oh.org_id,
	    oh.order_type_id,
	    oh.fob_point_code,
         oh.payment_type_code,
	    oh.end_customer_id,
--	    decode(nvl(to_char(oh.end_customer_id),'X'),'X','N','Y') end_cust_exist,
	    decode(nvl(to_char(oh.end_customer_id),'X'),'X',l_expert_no,l_expert_yes) end_cust_exist,
	    oh.price_list_id,
	    oh.tax_exempt_flag,
	    oh.sales_channel_code,
	    oe_oe_totals_summary.prt_order_total(oh.header_id) total,
	    oe_oe_totals_summary.price_adjustments(oh.header_id) total_adjusted_amount,
	    oe_oe_totals_summary.get_order_amount(oh.header_id) total_list_price,
	    bh.header_id blanket_header_id,
-- XY
	    oh.order_number,
	    oh.quote_number,
	    oh.cust_po_number,
	    oh.version_number,
	    oh.sold_to_contact_id,
	    oh.salesrep_id,
-- XY

-- Begin: Added for resolving bug 5300044 and 5299978
	    oh.shipment_priority_code,
	    oh.minisite_id ,
 -- End: Added for resolving bug 5300044 and 5299978
      pl.name price_list_name                --6899074
   FROM
	    oe_blanket_headers_all bh,
  	    oe_order_headers_all oh,
        qp_list_headers_tl pl
  WHERE
         oh.blanket_number = bh.order_number(+)
  AND    bh.sales_document_type_code(+) = 'B'
  AND    oh.header_id = p_doc_id
  AND  oh.price_list_id = pl.list_header_id(+)
  AND  pl.language(+) = USERENV('LANG');

 --
 -- Cursor to fetch the customer information
 --

  CURSOR c_get_cust_info_var(p_sold_to_org_id NUMBER) IS
  SELECT
	    hzp.category_code,
	    hzc.customer_class_code,
	    hzcp.profile_class_id,
	    hzcp.credit_rating,
	    hzcp.credit_classification,
	    hzcp.risk_code
  FROM
	    hz_customer_profiles hzcp,
    	    hz_cust_accounts hzc,
    	    hz_parties hzp
  WHERE
    	    hzc.cust_account_id = hzcp.cust_account_id
  AND    hzcp.site_use_id is null
  AND    hzc.party_id = hzcp.party_id
  AND    hzc.party_id = hzp.party_id
  AND    hzc.cust_account_id = p_sold_to_org_id;


 --
 -- Cursor to get the bill to, ship to and sold to countries
 -- Blanket sales agreement, Quoted Order and Sales Order
 --
  CURSOR c_get_country(p_site_use_id NUMBER) IS
  SELECT
    	   loc.country
  FROM
        hz_locations loc,
        hz_party_sites ps,
        hz_cust_acct_sites cas,
        hz_cust_site_uses su
  WHERE
        ps.location_id = loc.location_id
    and cas.party_site_id = ps.party_site_id
    and su.cust_acct_site_id = cas.cust_acct_site_id
    and su.site_use_id = p_site_use_id;

 --
  --bug 6899074
 -- Cursor to get the bill to, ship to and sold to address
 -- Blanket sales agreement and Sales Order. Not modifed the existing usage for country

 CURSOR c_get_address_info(p_site_use_id NUMBER) IS

	SELECT
			 su.location,
			 loc.province,
	   	     loc.address1,
			 loc.address2,
			 loc.address3,
			 loc.address4,
			 loc.city,
			 loc.postal_code,
			 loc.state,
			 loc.county
  FROM
        hz_locations loc,
        hz_party_sites ps,
        hz_cust_acct_sites cas,
        hz_cust_site_uses su
  WHERE
        ps.location_id = loc.location_id
    and cas.party_site_id = ps.party_site_id
    and su.cust_acct_site_id = cas.cust_acct_site_id
    and su.site_use_id = p_site_use_id;
 --
 -- Cursor to get the bill to and ship to customer account for
 -- Blanket sales agreement, Quoted Order and Sales Order
 --
  CURSOR c_get_cust_account(p_site_use_id NUMBER) IS
  SELECT
     	cas.cust_account_id
  FROM
        hz_cust_acct_sites cas,
        hz_cust_site_uses su
  WHERE
    	su.cust_acct_site_id = cas.cust_acct_site_id
    and su.site_use_id = p_site_use_id;

 --
 -- AK: Cursor to get Agreement type for
 -- Quoted Order and Sales Order
 --
  CURSOR c_get_pa_type(p_agreement_id NUMBER) IS
  SELECT
     	pc.agreement_type_code
  FROM
        oe_pricing_contracts_v pc
  WHERE
    	pc.agreement_id = p_agreement_id;


  l_bsa_header_variables c_get_bsa_header_variables%ROWTYPE;
  l_so_header_variables  c_get_so_header_variables%ROWTYPE;
  l_cust_info_variables  c_get_cust_info_var%ROWTYPE;
  -- bug 6899074
  l_ship_to_address_var  c_get_address_info%ROWTYPE;
	l_deliver_to_address_var c_get_address_info%ROWTYPE;
	l_bill_to_address_var c_get_address_info%ROWTYPE;

BEGIN

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_debug := true;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_package_procedure := G_PKG_NAME || '.' || l_api_name;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'10: Entered ' || l_package_procedure);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'20: p_doc_type: ' || p_doc_type);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'30: p_doc_id: ' || p_doc_id);
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
   THEN
   	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
  	FND_MSG_PUB.initialize;
   END IF;


   OPEN c_get_expert_yes_no('Yes');
   FETCH c_get_expert_yes_no INTO l_expert_yes;
   CLOSE c_get_expert_yes_no;

   OPEN c_get_expert_yes_no('No');
   FETCH c_get_expert_yes_no INTO l_expert_no;
   CLOSE c_get_expert_yes_no;

  -- Query OM tables to retrieve values against variable codes sent in by calling contract expert API.

  IF p_sys_var_value_tbl.FIRST IS NOT NULL THEN

     IF p_doc_type = G_BSA_DOC_TYPE THEN

        OPEN c_get_bsa_header_variables;
        FETCH c_get_bsa_header_variables INTO l_bsa_header_variables;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'40: c_get_bsa_header_variables%ROWCOUNT:  ' || c_get_bsa_header_variables%ROWCOUNT);
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'50: Values from l_bsa_header_variables: ');
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'55: ************************************');
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'60: Agreement_id             = '||l_bsa_header_variables.agreement_id);
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'70: price_agr_exist          = '||l_bsa_header_variables.price_agr_exist );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'80: sold_to_org_id           = '||l_bsa_header_variables.sold_to_org_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'90: invoice_to_org_id        = '||l_bsa_header_variables.invoice_to_org_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'100: ship_to_org_id          = '||l_bsa_header_variables.ship_to_org_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'105: deliver_to_org_id          = '||l_bsa_header_variables.deliver_to_org_id );
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'110: sold_to_site_use_id     = '||l_bsa_header_variables.sold_to_site_use_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'120: order_type_id           = '||l_bsa_header_variables.order_type_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'130: cust_po_num_exist       = '||l_bsa_header_variables.cust_po_num_exist );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'140: transactional_curr_code = '||l_bsa_header_variables.transactional_curr_code );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'150: freight_terms_code      = '||l_bsa_header_variables.freight_terms_code );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'160: shipping_method_code    = '||l_bsa_header_variables.shipping_method_code );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'170: payment_term_id         = '||l_bsa_header_variables.payment_term_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'180: invoicing_rule_id       = '||l_bsa_header_variables.invoicing_rule_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'190: tax_exempt_flag         = '||l_bsa_header_variables.tax_exempt_flag );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'200: price_list_id           = '||l_bsa_header_variables.price_list_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'210: org_id                  = '||l_bsa_header_variables.org_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'220: blanket_min_amount      = '||l_bsa_header_variables.blanket_min_amount );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'230: blanket_max_amount      = '||l_bsa_header_variables.blanket_max_amount );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'240: order_number            = '||l_bsa_header_variables.order_number );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'250: cust_po_number          = '||l_bsa_header_variables.cust_po_number );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'260: version_number          = '||l_bsa_header_variables.version_number );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'270: sold_to_contact_id      = '||l_bsa_header_variables.sold_to_contact_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'280: salesrep_id             = '||l_bsa_header_variables.salesrep_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'290: start_date_active       = '||l_bsa_header_variables.start_date_active );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'300: end_date_active         = '||l_bsa_header_variables.end_date_active );
        END IF;
        CLOSE c_get_bsa_header_variables;

    ELSIF p_doc_type = G_SO_DOC_TYPE THEN

        OPEN c_get_so_header_variables;
        FETCH c_get_so_header_variables INTO l_so_header_variables;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'40: c_get_so_header_variables%ROWCOUNT:  ' || c_get_so_header_variables%ROWCOUNT);
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'50: Values from l_so_header_variables: ');
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'55: ************************************');
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'60: blanket_number           = '||l_so_header_variables.blanket_number );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'70: blanket_number_exist     = '||l_so_header_variables.blanket_number_exist );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'80: agreement_id             = '||l_so_header_variables.agreement_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'90: price_agr_exist          = '||l_so_header_variables.price_agr_exist );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'100: sold_to_org_id          = '||l_so_header_variables.sold_to_org_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'110: invoice_to_org_id       = '||l_so_header_variables.invoice_to_org_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'120: ship_to_org_id          = '||l_so_header_variables.ship_to_org_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'125: deliver_to_org_id       = '||l_so_header_variables.deliver_to_org_id );
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'130: sold_to_site_use_id     = '||l_so_header_variables.sold_to_site_use_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'140: cust_po_num_exist       = '||l_so_header_variables.cust_po_num_exist );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'150: transactional_curr_code = '||l_so_header_variables.transactional_curr_code );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'160: freight_terms_code      = '||l_so_header_variables.freight_terms_code );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'170: shipping_method_code    = '||l_so_header_variables.shipping_method_code );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'180: payment_term_id         = '||l_so_header_variables.payment_term_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'190: invoicing_rule_id       = '||l_so_header_variables.invoicing_rule_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'200: org_id                  = '||l_so_header_variables.org_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'210: order_type_id           = '||l_so_header_variables.order_type_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'220: fob_point_code          = '||l_so_header_variables.fob_point_code );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'230: payment_type_code       = '||l_so_header_variables.payment_type_code );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'240: end_customer_id         = '||l_so_header_variables.end_customer_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'250: end_cust_exist          = '||l_so_header_variables.end_cust_exist );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'260: price_list_id           = '||l_so_header_variables.price_list_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'270: tax_exempt_flag         = '||l_so_header_variables.tax_exempt_flag );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'280: sales_channel_code      = '||l_so_header_variables.sales_channel_code );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'290: total                   = '||l_so_header_variables.total );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'300: total_adjusted_amount   = '||l_so_header_variables.total_adjusted_amount );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'310: total_list_price        = '||l_so_header_variables.total_list_price );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'320: blanket_header_id       = '||l_so_header_variables.blanket_header_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'330: order_number            = '||l_so_header_variables.order_number );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'340: quote_number            = '||l_so_header_variables.quote_number );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'350: cust_po_number          = '||l_so_header_variables.cust_po_number );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'360: version_number          = '||l_so_header_variables.version_number );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'370: sold_to_contact_id      = '||l_so_header_variables.sold_to_contact_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'380: salesrep_id             = '||l_so_header_variables.salesrep_id );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'381: shipment_priority_code  = '||l_so_header_variables.shipment_priority_code );
		 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'382: minisite_id             = '||l_so_header_variables.minisite_id );
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'390: Price_list_name         = '||l_so_header_variables.price_list_name );
        END IF;
        CLOSE c_get_so_header_variables;

    END IF;


 -- Get the customer info

    IF G_BSA_DOC_TYPE = p_doc_type THEN
		l_sold_to_org_id := l_bsa_header_variables.sold_to_org_id;
    ELSIF G_SO_DOC_TYPE = p_doc_type THEN
		l_sold_to_org_id := l_so_header_variables.sold_to_org_id;
    END IF;

    IF l_sold_to_org_id IS NOT NULL THEN
    OPEN c_get_cust_info_var(l_sold_to_org_id);
    FETCH c_get_cust_info_var INTO l_cust_info_variables;
    	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'330: c_get_cust_info_var%ROWCOUNT:  ' || c_get_cust_info_var%ROWCOUNT);
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'340: Values from l_cust_info_variables: ');
		fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'350: sold_to_org_id used =   '||l_sold_to_org_id );
		fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'360: category_code =         '||l_cust_info_variables.category_code );
		fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'370: customer_class_code =   '||l_cust_info_variables.customer_class_code );
		fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'380: profile_class_id =      '||l_cust_info_variables.profile_class_id );
		fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'390: credit_rating =         '||l_cust_info_variables.credit_rating );
		fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'400: credit_classification = '||l_cust_info_variables.credit_classification );
		fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'410: risk_code =             '||l_cust_info_variables.risk_code );
    	  END IF;
    CLOSE c_get_cust_info_var;
    END IF;

 -- Depending on the doc type, assign the sold to, bill to and ship to
 -- to be used for retrieving the sold to, bill to and ship to country for
 -- Blanket sales agreement, Quoted Order and Sales Order

    IF G_BSA_DOC_TYPE = p_doc_type THEN
                l_sold_to_site_use_id := l_bsa_header_variables.sold_to_site_use_id;
    ELSIF G_SO_DOC_TYPE = p_doc_type THEN
                l_sold_to_site_use_id := l_so_header_variables.sold_to_site_use_id;
    END IF;


    IF G_BSA_DOC_TYPE = p_doc_type THEN
                l_invoice_to_site_use_id := l_bsa_header_variables.invoice_to_org_id;
    ELSIF G_SO_DOC_TYPE = p_doc_type THEN
                l_invoice_to_site_use_id := l_so_header_variables.invoice_to_org_id;
    END IF;


    IF G_BSA_DOC_TYPE = p_doc_type THEN
                l_ship_to_site_use_id := l_bsa_header_variables.ship_to_org_id;
    ELSIF G_SO_DOC_TYPE = p_doc_type THEN
                l_ship_to_site_use_id := l_so_header_variables.ship_to_org_id;
    END IF;
 -----bug 6899074:   for DELIVER_TO_ORG_ID
 	  IF G_BSA_DOC_TYPE = p_doc_type THEN
 	                 l_deliver_to_site_use_id := l_bsa_header_variables.deliver_to_org_id;
 	  ELSIF G_SO_DOC_TYPE = p_doc_type THEN
 	                 l_deliver_to_site_use_id := l_so_header_variables.deliver_to_org_id;
 	  END IF;

 	   --bug 6899074 get Address Info
 	  IF l_invoice_to_site_use_id IS NOT NULL THEN
 	             OPEN c_get_address_info(l_invoice_to_site_use_id);
 	             FETCH c_get_address_info INTO l_bill_to_address_var;
 	             CLOSE c_get_address_info;
 	             IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'411: Bill to Location = '|| l_bill_to_address_var.location );
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'412: Bill to Address1 = '||  l_bill_to_address_var.address1);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'413: Bill to Address2 = '||  l_bill_to_address_var.address2);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'414: Bill to Address3= '||  l_bill_to_address_var.address3);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'415: Bill to Address4 ='||  l_bill_to_address_var.address4);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'416: Bill to City = '|| l_bill_to_address_var.city );
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'417: Bill to = County'||  l_bill_to_address_var.county);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'418: Bill to = State'|| l_bill_to_address_var.state);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'419: Bill to = Province'|| l_bill_to_address_var.province);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'420: Bill to = Postal Code'|| l_bill_to_address_var.postal_code );
 	             END IF;
 	  END IF;

    IF l_deliver_to_site_use_id  IS NOT NULL THEN
 	             OPEN c_get_address_info(l_invoice_to_site_use_id);
 	             FETCH c_get_address_info INTO l_deliver_to_address_var;
 	             CLOSE c_get_address_info;
 	             IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'421: Deliver to Location = '|| l_deliver_to_address_var.location );
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'422: Deliver to Address1 = '||  l_deliver_to_address_var.address1);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'423: Deliver to Address2 = '||  l_deliver_to_address_var.address2);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'424: Deliver to Address3= '||  l_deliver_to_address_var.address3);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'425: Deliver to Address4 ='||  l_deliver_to_address_var.address4);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'426: Deliver to City = '|| l_deliver_to_address_var.city );
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'427: Deliver to = County'||  l_deliver_to_address_var.county);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'428: Deliver to = State'|| l_deliver_to_address_var.state);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'429: Deliver to = Province'|| l_deliver_to_address_var.province);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'431: Deliver to = Postal Code'|| l_deliver_to_address_var.postal_code );
 	             END IF;
 	  END IF;

 	  IF  l_ship_to_site_use_id  IS NOT NULL THEN
 	            OPEN c_get_address_info(l_ship_to_site_use_id);
 	            FETCH c_get_address_info INTO l_ship_to_address_var;
 	            CLOSE c_get_address_info;
 	            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'432: ship to Location = '|| l_ship_to_address_var.location );
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'433: ship to Address1 = '||  l_ship_to_address_var.address1);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'434: ship to Address2 = '||  l_ship_to_address_var.address2);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'435: ship to Address3= '||  l_ship_to_address_var.address3);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'436: ship to Address4 ='||  l_ship_to_address_var.address4);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'437: ship to City = '|| l_ship_to_address_var.city );
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'438: ship to = County'||  l_ship_to_address_var.county);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'439: ship to = State'|| l_ship_to_address_var.state);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'441: ship to = Province'|| l_ship_to_address_var.province);
 	                          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'442: ship to = Postal Code'|| l_ship_to_address_var.postal_code );
 	            END IF;
 	  END IF;

    FOR i IN p_sys_var_value_tbl.FIRST..p_sys_var_value_tbl.LAST LOOP

        IF p_sys_var_value_tbl(i).variable_code = G_CUST_CATEGORY_CODE     THEN
           p_sys_var_value_tbl(i).variable_value_id := l_cust_info_variables.category_code;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_CLASS_CODE     THEN
           p_sys_var_value_tbl(i).variable_value_id := l_cust_info_variables.customer_class_code;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_PROF_CLASS_CODE     THEN
           p_sys_var_value_tbl(i).variable_value_id := l_cust_info_variables.profile_class_id;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_CRDT_RATE_CODE     THEN
           p_sys_var_value_tbl(i).variable_value_id := l_cust_info_variables.credit_rating;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_CRDT_CLASS_CODE THEN
           p_sys_var_value_tbl(i).variable_value_id := l_cust_info_variables.credit_classification;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_RISK_CODE     THEN
           p_sys_var_value_tbl(i).variable_value_id := l_cust_info_variables.risk_code;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SOLDTO_COUNTRY_CODE THEN
       	 BEGIN
              IF l_sold_to_site_use_id IS NOT NULL THEN
		      OPEN c_get_country(l_sold_to_site_use_id);
		      FETCH c_get_country INTO p_sys_var_value_tbl(i).variable_value_id;
		      CLOSE c_get_country;
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'430: Sold to country = '||p_sys_var_value_tbl(i).variable_value_id);
			 END IF;
              END IF;
       	 END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SHIPTO_COUNTRY_CODE THEN
           BEGIN
              IF l_ship_to_site_use_id IS NOT NULL THEN
                OPEN c_get_country(l_ship_to_site_use_id);
                FETCH c_get_country INTO p_sys_var_value_tbl(i).variable_value_id;
                CLOSE c_get_country;
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'440: Ship to country = '||p_sys_var_value_tbl(i).variable_value_id);
			 END IF;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_BILLTO_COUNTRY_CODE THEN
           BEGIN
              IF l_invoice_to_site_use_id IS NOT NULL THEN
                OPEN c_get_country(l_invoice_to_site_use_id);
                FETCH c_get_country INTO p_sys_var_value_tbl(i).variable_value_id;
                CLOSE c_get_country;
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'450: Invoice to country = '||p_sys_var_value_tbl(i).variable_value_id);
			 END IF;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUSTOMER_NAME_CODE     THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.sold_to_org_id;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.sold_to_org_id;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_BILLTO_CUST_NAME_CODE     THEN
           BEGIN
              IF l_invoice_to_site_use_id IS NOT NULL THEN
                OPEN c_get_cust_account(l_invoice_to_site_use_id);
                FETCH c_get_cust_account INTO p_sys_var_value_tbl(i).variable_value_id;
                CLOSE c_get_cust_account;
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'460: Invoice to Customer = '||p_sys_var_value_tbl(i).variable_value_id);
			 END IF;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SHIPTO_CUST_NAME_CODE     THEN
           BEGIN
              IF l_ship_to_site_use_id IS NOT NULL THEN
                OPEN c_get_cust_account(l_ship_to_site_use_id);
                FETCH c_get_cust_account INTO p_sys_var_value_tbl(i).variable_value_id;
                CLOSE c_get_cust_account;
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'470: Ship to Customer = '||p_sys_var_value_tbl(i).variable_value_id);
			 END IF;
              END IF;
           END;

   	   ELSIF p_sys_var_value_tbl(i).variable_code = G_SALES_DOC_TYPE_CODE     THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := p_doc_type;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := p_doc_type;
              END IF;
           END;

    	   ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_PO_EXIST_CODE   THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.cust_po_num_exist;
              ELSIF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.cust_po_num_exist;
              END IF;
           END;

    	   ELSIF p_sys_var_value_tbl(i).variable_code = G_PRICE_LIST_CODE   THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.price_list_id;
              ELSIF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.price_list_id;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CURRENCY_CODE   THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.transactional_curr_code;
              ELSIF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.transactional_curr_code;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_FREIGHT_TERMS_CODE   THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.freight_terms_code;
              ELSIF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.freight_terms_code;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SHIPPING_METHOD_CODE   THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.shipping_method_code;
              ELSIF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.shipping_method_code;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_PAYMENT_TERM_CODE   THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.payment_term_id;
              ELSIF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.payment_term_id;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_PA_NAME_CODE   THEN
           BEGIN
-- XY
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.agreement_id;
-- XY
              ELSIF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.agreement_id;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_PA_NAME_EXIST_CODE   THEN
           BEGIN
              IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.price_agr_exist;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_PAYMENT_TYPE_CODE    THEN
           BEGIN
              IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.payment_type_code;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_FOB_CODE   THEN
           BEGIN
              IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.fob_point_code;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SALES_CHANNEL_CODE   THEN
           BEGIN
              IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.sales_channel_code;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_TAX_HANDL_CODE   THEN
           BEGIN
              IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.tax_exempt_flag;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_ORDER_TYPE_CODE   THEN
           BEGIN
              IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.order_type_id;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_TOTAL_CODE   THEN
           BEGIN
              IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.total;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_TOTAL_ADJUST_AMT_CODE    THEN
           BEGIN
              IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.total_adjusted_amount;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_TOTAL_ADJUST_PCT_CODE   THEN
           BEGIN
              IF p_doc_type = G_SO_DOC_TYPE AND l_so_header_variables.total_list_price IS NOT NULL
                                            AND l_so_header_variables.total_list_price <> 0 THEN
                 p_sys_var_value_tbl(i).variable_value_id :=
				(l_so_header_variables.total_adjusted_amount / l_so_header_variables.total_list_price) * 100;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_INVOICING_RULE_CODE   THEN
           BEGIN
              IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.invoicing_rule_id;
              ELSIF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.invoicing_rule_id;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_BLKT_AGR_TYPE_CODE THEN
           BEGIN
	      IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.order_type_id;
	      END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_MIN_AMT_AGREED_CODE   THEN
           BEGIN
	      IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.blanket_min_amount;
	      END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_MAX_AMT_AGREED_CODE   THEN
           BEGIN
	      IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.blanket_max_amount;
	      END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_END_CUST_CODE     THEN
           BEGIN
	      IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.end_customer_id;
	      END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_END_CUST_EXIST_CODE   THEN
           BEGIN
	      IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.end_cust_exist;
	      END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_BLKT_NUM_EXIST_CODE   THEN
           BEGIN
	      IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.blanket_number_exist;
	      END IF;
           END;
-- XY
        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUSTOMER_NUMBER_CODE     THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.sold_to_org_id;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.sold_to_org_id;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_PA_NUMBER_CODE     THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.agreement_id;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.agreement_id;
              END IF;
           END;

--AK
        ELSIF p_sys_var_value_tbl(i).variable_code = G_PA_TYPE_CODE     THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := NULL;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 IF l_so_header_variables.agreement_id IS NOT NULL THEN
		    OPEN c_get_pa_type(l_so_header_variables.agreement_id);
                    FETCH c_get_pa_type INTO p_sys_var_value_tbl(i).variable_value_id;
                    CLOSE c_get_pa_type;
                 END IF;
              END IF;
           END;
--AK
        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_PO_NUMBER_CODE      THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.cust_po_number;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.cust_po_number;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_VERSION_NUMBER_CODE      THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.version_number;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.version_number;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_CONTACT_NAME_CODE      THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.sold_to_contact_id;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.sold_to_contact_id;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SALESREP_NAME_CODE      THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.salesrep_id;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.salesrep_id;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CURRENCY_NAME_CODE      THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.transactional_curr_code;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.transactional_curr_code;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CURRENCY_SYMBOL_CODE      THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.transactional_curr_code;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.transactional_curr_code;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SUPPLIER_NAME_CODE      THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.org_id;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.org_id;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_BLANKET_NUMBER_CODE      THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.order_number;
              ELSIF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.blanket_number;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_ORDER_NUMBER_CODE      THEN
           BEGIN
              IF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.order_number;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_QUOTE_NUMBER_CODE      THEN
           BEGIN
              IF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.quote_number;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_ACTIVATION_DATE_CODE      THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.start_date_active;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_EXPIRATION_DATE_CODE      THEN
           BEGIN
              IF p_doc_type = G_BSA_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.end_date_active;
              END IF;
           END;

-- XY

--  Begin: Added for resolving bug 5300044 and 5299978

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SHIPMENT_PRIORITY_CODE      THEN
           BEGIN
              IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.shipment_priority_code;
              END IF;
           END;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SITE_ID_CODE      THEN
           BEGIN
              IF p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.minisite_id;
              END IF;
           END;

-- End: Added for resolving bug 5300044 and 5299978
 -- XY
 --Begin: Bug 66899074: New Variables

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_DELIVER_TO_CITY_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_deliver_to_address_var.city;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_SHIP_TO_LOCATION_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_ship_to_address_var.location;

		ELSIF p_sys_var_value_tbl(i).variable_code = G_SHIP_TO_ADDRESS1_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_ship_to_address_var.address1;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_SHIP_TO_ADDRESS2_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_ship_to_address_var.address2;

		ELSIF p_sys_var_value_tbl(i).variable_code = G_SHIP_TO_ADDRESS3_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_ship_to_address_var.address3;

		ELSIF p_sys_var_value_tbl(i).variable_code = G_SHIP_TO_ADDRESS4_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_ship_to_address_var.address4;

		ELSIF p_sys_var_value_tbl(i).variable_code = G_SHIP_TO_CITY_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_ship_to_address_var.city;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_SHIP_TO_COUNTY_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_ship_to_address_var.county;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_SHIP_TO_STATE_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_ship_to_address_var.state;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_SHIP_TO_PROVINCE_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_ship_to_address_var.province;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_SHIP_TO_POSTAL_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_ship_to_address_var.postal_code;

		ELSIF p_sys_var_value_tbl(i).variable_code = G_BILL_TO_CITY_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_bill_to_address_var.city;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_BILL_TO_LOCATION_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_bill_to_address_var.location;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_BILL_TO_ADDRESS1_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_bill_to_address_var.address1;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_BILL_TO_ADDRESS2_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_bill_to_address_var.address2;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_BILL_TO_ADDRESS3_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_bill_to_address_var.address3;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_BILL_TO_ADDRESS4_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_bill_to_address_var.address4;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_BILL_TO_COUNTY_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_bill_to_address_var.county;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_BILL_TO_STATE_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_bill_to_address_var.state;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_BILL_TO_PROVINCE_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_bill_to_address_var.province;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_BILL_TO_POSTAL_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_bill_to_address_var.postal_code;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_DELIVER_TO_LOCATION_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_deliver_to_address_var.location;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_DELIVER_TO_ADDRESS1_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_deliver_to_address_var.address1;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_DELIVER_TO_ADDRESS2_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_deliver_to_address_var.address2;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_DELIVER_TO_ADDRESS3_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_deliver_to_address_var.address3;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_DELIVER_TO_ADDRESS4_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_deliver_to_address_var.address4;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_DELIVER_TO_COUNTY_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_deliver_to_address_var.county;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_DELIVER_TO_STATE_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_deliver_to_address_var.state;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_DELIVER_TO_PROVINCE_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_deliver_to_address_var.province;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_DELIVER_TO_POSTAL_CODE THEN
			p_sys_var_value_tbl(i).variable_value_id := l_deliver_to_address_var.postal_code;

		ELSIF p_sys_var_value_tbl(i).variable_code =  G_DELIVER_TO_COUNTRY_CODE THEN
		  BEGIN
              IF l_ship_to_site_use_id IS NOT NULL THEN
                OPEN c_get_country(l_deliver_to_site_use_id);
                FETCH c_get_country INTO p_sys_var_value_tbl(i).variable_value_id;
                CLOSE c_get_country;
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'440: deliver to country = '||p_sys_var_value_tbl(i).variable_value_id);
			 END IF;
              END IF;
           END;

		 ELSIF p_sys_var_value_tbl(i).variable_code = G_PRICE_LIST_NAME_CODE THEN
		 	BEGIN
              IF  p_doc_type = G_SO_DOC_TYPE THEN
                 p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.price_list_name;
              END IF;
           END;
--END- Bug 6899074

        END IF;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'480: p_sys_var_value_tbl('||i||').variable_code     : '||p_sys_var_value_tbl(i).variable_code);
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'485: p_sys_var_value_tbl('||i||').variable_value_id : '||p_sys_var_value_tbl(i).variable_value_id);
     END IF;


     END LOOP;

  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'490: End of '||l_package_procedure||' for header level variables, x_return_status ' || x_return_status);
  END IF;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	IF c_get_bsa_header_variables%ISOPEN THEN
	   CLOSE c_get_bsa_header_variables;
	END IF;

	IF c_get_so_header_variables%ISOPEN THEN
	   CLOSE c_get_so_header_variables;
	END IF;

	IF c_get_cust_info_var%ISOPEN THEN
	   CLOSE c_get_cust_info_var;
	END IF;

     IF c_get_country%ISOPEN THEN
        CLOSE c_get_country;
     END IF;

     IF c_get_cust_account%ISOPEN THEN
        CLOSE c_get_cust_account;
     END IF;

     IF c_get_expert_yes_no%ISOPEN THEN
	   CLOSE c_get_expert_yes_no;
	END IF;
  --Bug 6899074
  IF c_get_address_info%ISOPEN THEN
		CLOSE c_get_address_info;
	END IF;

	x_return_status := FND_API.G_RET_STS_ERROR ;
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'500: '||l_package_procedure||' In the FND_API.G_EXC_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'510: x_return_status = '||x_return_status);
	END IF;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF c_get_bsa_header_variables%ISOPEN THEN
           CLOSE c_get_bsa_header_variables;
        END IF;

        IF c_get_so_header_variables%ISOPEN THEN
           CLOSE c_get_so_header_variables;
        END IF;

        IF c_get_cust_info_var%ISOPEN THEN
           CLOSE c_get_cust_info_var;
        END IF;

        IF c_get_country%ISOPEN THEN
           CLOSE c_get_country;
        END IF;

        IF c_get_cust_account%ISOPEN THEN
           CLOSE c_get_cust_account;
        END IF;

        IF c_get_expert_yes_no%ISOPEN THEN
	      CLOSE c_get_expert_yes_no;
	      END IF;
 --Bug 6899074
      	IF c_get_address_info%ISOPEN THEN
	     	CLOSE c_get_address_info;
     	END IF;

  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'520: '||l_package_procedure||' In the FND_API.G_RET_STS_UNEXP_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'530: x_return_status = '||x_return_status);
	END IF;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

   WHEN OTHERS THEN

        IF c_get_bsa_header_variables%ISOPEN THEN
           CLOSE c_get_bsa_header_variables;
        END IF;

        IF c_get_so_header_variables%ISOPEN THEN
           CLOSE c_get_so_header_variables;
        END IF;

        IF c_get_cust_info_var%ISOPEN THEN
           CLOSE c_get_cust_info_var;
        END IF;

        IF c_get_country%ISOPEN THEN
           CLOSE c_get_country;
        END IF;

        IF c_get_cust_account%ISOPEN THEN
           CLOSE c_get_cust_account;
        END IF;

        IF c_get_expert_yes_no%ISOPEN THEN
	      CLOSE c_get_expert_yes_no;
	      END IF;
--Bug 6711319
	      IF c_get_address_info%ISOPEN THEN
		    CLOSE c_get_address_info;
	   END IF;

  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'540: '||l_package_procedure||' In the OTHERS section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'550: x_return_status = '||x_return_status);
	END IF;

    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         	   FND_MSG_PUB.Add_Exc_Msg(
          	        G_PKG_NAME ,
          	        l_api_name );
  	END IF;

  	FND_MSG_PUB.Count_And_Get(
  	     p_count => x_msg_count,
       	 p_data => x_msg_data );

END get_clause_variable_values;




--this overloaded signature is called from the contract expert
PROCEDURE get_clause_variable_values
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_line_var_tbl               IN  line_var_tbl_type,

   x_line_var_value_tbl         OUT NOCOPY OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
) IS

l_api_name          VARCHAR2(30) := 'get_clause_variable_values';
l_package_procedure VARCHAR2(60);
l_api_version       CONSTANT NUMBER := 1;
l_debug             Boolean;
l_module            VARCHAR2(250)   := G_MODULE_NAME||l_api_name;



  -- Cursor to get all the items of the BSA i.e. internal (INT) customer (CUST) etc.
  -- Returns non-translatable code eg. AS54888
  --
  CURSOR c_get_items IS
  SELECT item_identifier_type,   --eg. INT
         ordered_item,           --eg. AS54888
         ordered_item_id,
         org_id,
         inventory_item_id,
         sold_to_org_id
  FROM   oe_blanket_lines_all
  WHERE  header_id            =  p_doc_id
    AND  p_doc_type           = G_BSA_DOC_TYPE
    AND  item_identifier_type <> 'CAT'
    AND  line_category_code = 'ORDER'

UNION ALL

  -- Get all the items of the Sales Order i.e. internal (INT) customer (CUST) etc.
  -- Returns non-translatable code eg. AS54888
  --
  SELECT item_identifier_type,   --eg. INT
         ordered_item,           --eg. AS54888
         ordered_item_id,
         org_id,
         inventory_item_id,
         sold_to_org_id
  FROM   oe_order_lines_all
  WHERE  header_id            =  p_doc_id
    AND  p_doc_type           = G_SO_DOC_TYPE
    AND  item_identifier_type <> 'CAT'
    AND  line_category_code = 'ORDER'
  ORDER BY ordered_item;


  -- Cursor to retrieve the item categories (CATs) in the BSA
  -- Returns non-translatable code eg. 208.05
  --
  CURSOR c_get_item_categories IS
  SELECT ordered_item
  FROM   oe_blanket_lines_all
  WHERE  header_id            =  p_doc_id
    AND  p_doc_type           = G_BSA_DOC_TYPE
    AND  item_identifier_type = 'CAT'
    AND  line_category_code = 'ORDER'
  ORDER BY ordered_item;


  -- Cursor to retrieve categories to which the INT (internal) and non-INT
  -- items in the BSA or Sales Order belong
  -- Note: the inventory_item_id stored in  oe_blanket_lines_all and oe_order_lines_all
  -- against the non-INT item is that of the mapped INT item so we can use it
  -- directly to get the item category
  --
  -- Returns non-translatable code eg. HOSPITAL.MISC
  --
  CURSOR c_get_derived_item_category (cp_org_id             NUMBER,
                                      cp_inventory_item_id  NUMBER) IS
  SELECT category_concat_segs
  FROM   mtl_item_categories_v
  WHERE  inventory_item_id  =  cp_inventory_item_id
    AND  organization_id    =  cp_org_id  -- should be inventory master org
    AND  structure_id       =  101;       -- hardcoded to 101 i.e. Item Categories(Inv.Items) for OM


  l_bsa_derived_item_category    c_get_derived_item_category%ROWTYPE;

  j                              BINARY_INTEGER := 1;
  l_master_org_id                NUMBER;
  lx_ordered_item                VARCHAR2(2000);
  lx_inventory_item              VARCHAR2(2000);

  l_current_org_id		 NUMBER;

  CURSOR c_get_doc_org_id IS
  SELECT org_id
  FROM   oe_blanket_headers_all
  WHERE  header_id            =  p_doc_id
    AND  p_doc_type           = G_BSA_DOC_TYPE

  UNION ALL

  SELECT org_id
  FROM   oe_order_headers_all
  WHERE  header_id            =  p_doc_id
    AND  p_doc_type           = G_SO_DOC_TYPE;

BEGIN

   l_package_procedure := G_PKG_NAME || '.' || l_api_name || ' - 2';

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_debug := true;
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'10: Entered ' || l_package_procedure);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'20: p_doc_type: ' || p_doc_type);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'30: p_doc_id: ' || p_doc_id);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'40: p_line_var_tbl.COUNT: ' || p_line_var_tbl.COUNT);
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
   END IF;


   --Get Current Org Id from context
   OPEN c_get_doc_org_id;
   FETCH c_get_doc_org_id INTO l_current_org_id;
   CLOSE c_get_doc_org_id;

   --Get inventory master org

   l_master_org_id := TO_NUMBER(oe_sys_parameters.value (
                           param_name   => 'MASTER_ORGANIZATION_ID',p_org_id => l_current_org_id ));

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'45: l_master_org_id:  ' || l_master_org_id);
   END IF;

  -- Query OM tables oe_blanket_headers_all and oe_blanket_lines_all to retrieve values
  -- against variable codes sent in by calling contrtact expert API

  IF p_line_var_tbl.FIRST IS NOT NULL THEN
     FOR i IN p_line_var_tbl.FIRST..p_line_var_tbl.LAST LOOP

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'50: Processing for ' || p_line_var_tbl(i));
        END IF;

        IF p_line_var_tbl(i) = G_ITEM_CODE THEN

           FOR c_get_items_rec IN c_get_items LOOP
              --loop thru all the items for internal INT items
              IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'60: c_get_items_rec.item_identifier_type:  '||c_get_items_rec.item_identifier_type);
              END IF;

              IF c_get_items_rec.item_identifier_type = 'INT' THEN
                 x_line_var_value_tbl(j).variable_code     := p_line_var_tbl(i); --i.e. OKC$S_ITEM
                 x_line_var_value_tbl(j).variable_value_id := c_get_items_rec.ordered_item; --eg. AS54888

                 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'70: x_line_var_value_tbl('||j||').variable_code:     ' || p_line_var_tbl(i));
                    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'80: x_line_var_value_tbl('||j||').variable_value_id: ' || c_get_items_rec.ordered_item);
                 END IF;

              ELSIF c_get_items_rec.item_identifier_type <> 'INT' THEN
                 --map the non-INT items to INT items

                 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'90: Mapping non-INT item to INT item, Calling OE_Id_To_Value.Ordered_Item ');
                 END IF;

                 -- Map non-INT item to INT item
                 OE_Id_To_Value.Ordered_Item (
                    p_item_identifier_type  => c_get_items_rec.item_identifier_type,
                    p_inventory_item_id     => c_get_items_rec.inventory_item_id,
                    p_organization_id       => l_master_org_id,
                    p_ordered_item_id       => c_get_items_rec.ordered_item_id,
                    p_sold_to_org_id        => c_get_items_rec.sold_to_org_id,
                    p_ordered_item          => c_get_items_rec.ordered_item,
                    x_ordered_item          => lx_ordered_item,
                    x_inventory_item        => lx_inventory_item
                  );

                  x_line_var_value_tbl(j).variable_code     := p_line_var_tbl(i); --i.e. OKC$S_ITEM
                  x_line_var_value_tbl(j).variable_value_id := lx_inventory_item;

                  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'100: x_line_var_value_tbl('||j||').variable_code:     ' || p_line_var_tbl(i));
                     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'110: x_line_var_value_tbl('||j||').variable_value_id: ' || lx_inventory_item);
                  END IF;
              END IF;

              j := j + 1;

           END LOOP;


        ELSIF p_line_var_tbl(i) = G_ITEM_CATEGORY_CODE THEN


           --get all the item categories in the BSA
           FOR c_get_item_categories_rec IN c_get_item_categories LOOP

              x_line_var_value_tbl(j).variable_code     := p_line_var_tbl(i); --i.e. OKC$S_ITEM_CATEGORY
              x_line_var_value_tbl(j).variable_value_id := c_get_item_categories_rec.ordered_item;

              IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'120: x_line_var_value_tbl('||j||').variable_code:     '||p_line_var_tbl(i));
                 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'130: x_line_var_value_tbl('||j||').variable_value_id: '||c_get_item_categories_rec.ordered_item);
              END IF;

              j := j + 1;

           END LOOP;

           -- Get the item categories to which the INT and non-INT items in the BSA belong to
           -- NOTE: the inventory_item_id stored in oe_blanket_lines_all against the non-INT
		 -- items is actually that of the mapped INT item so we can use it directly to get the
		 -- item category

           FOR c_get_items_rec IN c_get_items LOOP

               IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'140: get the item categories to which the INT and non-INT items in the BSA belong to');
               END IF;

               l_bsa_derived_item_category := null;  --initialize

               OPEN c_get_derived_item_category(l_master_org_id, c_get_items_rec.inventory_item_id);
               FETCH c_get_derived_item_category INTO l_bsa_derived_item_category;
               CLOSE c_get_derived_item_category;

               x_line_var_value_tbl(j).variable_code     := p_line_var_tbl(i); --i.e. OKC$S_ITEM_CATEGORY
               x_line_var_value_tbl(j).variable_value_id := l_bsa_derived_item_category.category_concat_segs;

               IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'150: x_line_var_value_tbl('||j||').variable_code:     '||p_line_var_tbl(i));
                 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'160: x_line_var_value_tbl('||j||').variable_value_id: '||l_bsa_derived_item_category.category_concat_segs);
               END IF;

               j := j + 1;

           END LOOP;

        END IF;

     END LOOP;
  END IF;   ----IF p_line_var_tbl.FIRST IS NOT NULL THEN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'170: End of '||l_package_procedure||'for line level variables, x_return_status:  '|| x_return_status);
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	IF c_get_items%ISOPEN THEN
	   CLOSE c_get_items;
	END IF;

	IF c_get_item_categories%ISOPEN THEN
	   CLOSE c_get_item_categories;
	END IF;

	IF c_get_derived_item_category%ISOPEN THEN
	   CLOSE c_get_derived_item_category;
	END IF;

	x_return_status := FND_API.G_RET_STS_ERROR ;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'180: '||l_package_procedure||' In the FND_API.G_EXC_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'190: x_return_status = '||x_return_status);
     END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	IF c_get_items%ISOPEN THEN
	   CLOSE c_get_items;
	END IF;

	IF c_get_item_categories%ISOPEN THEN
	   CLOSE c_get_item_categories;
	END IF;

     IF c_get_derived_item_category%ISOPEN THEN
        CLOSE c_get_derived_item_category;
     END IF;

  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'200: '||l_package_procedure||' In the FND_API.G_EXC_UNEXPECTED_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'210: x_return_status = '||x_return_status);
     END IF;

   WHEN OTHERS THEN

	IF c_get_items%ISOPEN THEN
	   CLOSE c_get_items;
	END IF;

	IF c_get_item_categories%ISOPEN THEN
	   CLOSE c_get_item_categories;
	END IF;

     IF c_get_derived_item_category%ISOPEN THEN
        CLOSE c_get_derived_item_category;
     END IF;

  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         	   FND_MSG_PUB.Add_Exc_Msg(
          	        G_PKG_NAME ,
          	        l_api_name );
  	END IF;

  	FND_MSG_PUB.Count_And_Get(
  	     	p_count => x_msg_count,
       	      p_data => x_msg_data );

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'220: '||l_package_procedure||' In the OTHERS section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'230: x_return_status = '||x_return_status);
     END IF;

END get_clause_variable_values;

--
-- This procedure will be called from contract expert to get
-- line level system variables
--
PROCEDURE Get_Line_Variable_Values (
   p_api_version               IN            NUMBER,
   p_init_msg_list             IN            VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_doc_type                  IN            VARCHAR2,
   p_doc_id                    IN            NUMBER,
   x_return_status             OUT  NOCOPY   VARCHAR2,
   x_msg_count                 OUT  NOCOPY   NUMBER,
   x_msg_data                  OUT  NOCOPY   VARCHAR2,
   x_line_sys_var_value_tbl    OUT  NOCOPY   OKC_XPRT_XRULE_VALUES_PVT.line_sys_var_value_tbl_type,
   x_line_count                OUT  NOCOPY   NUMBER,
   x_line_variables_count      OUT  NOCOPY   NUMBER
  ) IS

l_api_name          VARCHAR2(30) := 'get_line_variable_values';
l_package_procedure VARCHAR2(60);
l_api_version       CONSTANT NUMBER := 1;
l_debug             Boolean;
l_module            VARCHAR2(250)   := G_MODULE_NAME||l_api_name;

--
--cursor to fetch value of line level variables for blankets
--
CURSOR c_get_bsa_line_variables IS
  SELECT
         bl.line_number,
         NVL(bl.payment_term_id,'-99999') payment_term_id,
         NVL(bl.invoicing_rule_id,'-99999') invoicing_rule_id,
         bl.inventory_item_id,
         bl.org_id,
         --AK
         bl.item_identifier_type,   --eg. INT
	 bl.ordered_item,           --eg. AS54888
	 bl.ordered_item_id,
         bl.sold_to_org_id
         --AK
  FROM
	 oe_blanket_lines_all bl
  WHERE
         bl.header_id = p_doc_id;

  --
  --cursor to fetch value of line level variables for sales orders
  --
  CURSOR c_get_so_line_variables IS
  SELECT
         ol.line_number,
         NVL(ol.payment_term_id,'-99999') payment_term_id,
         NVL(ol.invoicing_rule_id,'-99999') invoicing_rule_id,
         NVL(ol.agreement_id,'-99999') agreement_id,
         ol.inventory_item_id,
         ol.org_id,
         --AK
         ol.item_identifier_type,   --eg. INT
	 ol.ordered_item,           --eg. AS54888
	 ol.ordered_item_id,
         ol.sold_to_org_id,
         --AK
         --Bug 4768964
         ol.service_number,
         ol.option_number,
         ol.component_number,
         ol.shipment_number
         --Bug 4768964
  FROM
	 oe_order_lines_all ol
  WHERE  ol.header_id = p_doc_id;

  l_bsa_line_variables c_get_bsa_line_variables%ROWTYPE;
  l_so_line_variables  c_get_so_line_variables%ROWTYPE;
  l_line_count    NUMBER := 0;
  l_line_number   VARCHAR2(250); --NUMBER; Changed for bug 4768964
  l_index	  NUMBER := 0;


--AK
  -- Cursor to retrieve the item categories (CATs) in the BSA
  -- Returns non-translatable code eg. 208.05
  --
  CURSOR c_get_item_categories IS
  SELECT ordered_item
  FROM   oe_blanket_lines_all
  WHERE  header_id            =  p_doc_id
    AND  p_doc_type           = G_BSA_DOC_TYPE
    AND  item_identifier_type = 'CAT'
    AND  line_category_code = 'ORDER'
  ORDER BY ordered_item;


  -- Cursor to retrieve categories to which the INT (internal) and non-INT
  -- items in the BSA or Sales Order belong
  -- Note: the inventory_item_id stored in  oe_blanket_lines_all and oe_order_lines_all
  -- against the non-INT item is that of the mapped INT item so we can use it
  -- directly to get the item category
  --
  -- Returns non-translatable code eg. HOSPITAL.MISC
  --
  CURSOR c_get_derived_item_category (cp_org_id             NUMBER,
                                      cp_inventory_item_id  NUMBER) IS
  SELECT category_concat_segs
  FROM   mtl_item_categories_v
  WHERE  inventory_item_id  =  cp_inventory_item_id
    AND  organization_id    =  cp_org_id  -- should be inventory master org
    AND  structure_id       =  101;       -- hardcoded to 101 i.e. Item Categories(Inv.Items) for OM


  l_bsa_derived_item_category    VARCHAR2(2500); --c_get_derived_item_category%ROWTYPE;
  l_so_derived_item_category     VARCHAR2(2500); --c_get_derived_item_category%ROWTYPE;

  j                              BINARY_INTEGER := 1;
  l_master_org_id                NUMBER;
  lx_ordered_item                VARCHAR2(2000);
  lx_inventory_item              VARCHAR2(2000);
  l_current_org_id		 NUMBER;

  CURSOR c_get_doc_org_id IS
  SELECT org_id
  FROM   oe_blanket_headers_all
  WHERE  header_id            =  p_doc_id
    AND  p_doc_type           = G_BSA_DOC_TYPE

  UNION ALL

  SELECT org_id
  FROM   oe_order_headers_all
  WHERE  header_id            =  p_doc_id
    AND  p_doc_type           = G_SO_DOC_TYPE;

--AK

BEGIN

   l_package_procedure := G_PKG_NAME || '.' || l_api_name;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_debug := true;
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'10: Entered ' || l_package_procedure);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'20: p_doc_id: ' || p_doc_id);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'30: p_doc_type: ' || p_doc_type);
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
   END IF;

--AK
--Get Current Org Id from context
   OPEN c_get_doc_org_id;
   FETCH c_get_doc_org_id INTO l_current_org_id;
   CLOSE c_get_doc_org_id;

   --Get inventory master org

   l_master_org_id := TO_NUMBER(oe_sys_parameters.value (
                           param_name   => 'MASTER_ORGANIZATION_ID',p_org_id => l_current_org_id ));

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'35: l_master_org_id:  ' || l_master_org_id);
   END IF;
--AK

   IF p_doc_type = G_BSA_DOC_TYPE THEN
      OPEN c_get_bsa_line_variables;
      LOOP
         FETCH c_get_bsa_line_variables INTO l_bsa_line_variables;
         EXIT WHEN c_get_bsa_line_variables%NOTFOUND;

         l_line_number := to_char(l_bsa_line_variables.line_number);

         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'40: line_number =        '||l_bsa_line_variables.line_number );
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'50: payment_term_id =        '||l_bsa_line_variables.payment_term_id );
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'60: item_id =        '||l_bsa_line_variables.inventory_item_id );
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'70: org_id =        '||l_bsa_line_variables.org_id );
         END IF;


         l_line_count := l_line_count+1;

         IF l_bsa_line_variables.payment_term_id IS NOT NULL THEN
            l_index      := l_index+1;
            x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
            x_line_sys_var_value_tbl(l_index).variable_code := G_LINE_PAYMENT_TERM_CODE;
            x_line_sys_var_value_tbl(l_index).variable_value := l_bsa_line_variables.payment_term_id;
            x_line_sys_var_value_tbl(l_index).item_id := l_bsa_line_variables.inventory_item_id;
            x_line_sys_var_value_tbl(l_index).org_id := l_bsa_line_variables.org_id;
         END IF;

         IF l_bsa_line_variables.invoicing_rule_id IS NOT NULL THEN
            l_index      := l_index+1;
            x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
            x_line_sys_var_value_tbl(l_index).variable_code := G_LINE_INVOICING_RULE_CODE;
            x_line_sys_var_value_tbl(l_index).variable_value := l_bsa_line_variables.invoicing_rule_id;
            x_line_sys_var_value_tbl(l_index).item_id := l_bsa_line_variables.inventory_item_id;
            x_line_sys_var_value_tbl(l_index).org_id := l_bsa_line_variables.org_id;
         END IF;

         --AK
         IF l_bsa_line_variables.item_identifier_type = 'INT' THEN
            l_index      := l_index+1;
            x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
            x_line_sys_var_value_tbl(l_index).variable_code := G_ITEM_CODE;
            x_line_sys_var_value_tbl(l_index).variable_value := l_bsa_line_variables.ordered_item;
            x_line_sys_var_value_tbl(l_index).item_id := l_bsa_line_variables.inventory_item_id;
            x_line_sys_var_value_tbl(l_index).org_id := l_bsa_line_variables.org_id;
	 ELSIF l_bsa_line_variables.item_identifier_type <> 'INT' THEN
	  --map the non-INT items to INT items

	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'71: Mapping non-INT item to INT item, Calling OE_Id_To_Value.Ordered_Item ');
	  END IF;

	   -- Map non-INT item to INT item
	   OE_Id_To_Value.Ordered_Item (
	     p_item_identifier_type  => l_bsa_line_variables.item_identifier_type,
	     p_inventory_item_id     => l_bsa_line_variables.inventory_item_id,
	     p_organization_id       => l_master_org_id,
	     p_ordered_item_id       => l_bsa_line_variables.ordered_item_id,
	     p_sold_to_org_id        => l_bsa_line_variables.sold_to_org_id,
	     p_ordered_item          => l_bsa_line_variables.ordered_item,
	     x_ordered_item          => lx_ordered_item,
	     x_inventory_item        => lx_inventory_item
	    );
            l_index      := l_index+1;
            x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
            x_line_sys_var_value_tbl(l_index).variable_code := G_ITEM_CODE;
            x_line_sys_var_value_tbl(l_index).variable_value := lx_inventory_item;
            x_line_sys_var_value_tbl(l_index).item_id := l_bsa_line_variables.inventory_item_id;
            x_line_sys_var_value_tbl(l_index).org_id := l_bsa_line_variables.org_id;

	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'72: x_line_var_value_tbl('||j||').variable_code:     ' || G_ITEM_CODE);
	      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'73: x_line_var_value_tbl('||j||').variable_value_id: ' || lx_inventory_item);
	   END IF;
         END IF;

         IF l_bsa_line_variables.inventory_item_id IS NOT NULL THEN

           FOR c_get_item_categories_rec IN c_get_item_categories LOOP
            l_index      := l_index+1;
            x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
            x_line_sys_var_value_tbl(l_index).variable_code := G_ITEM_CATEGORY_CODE;
            x_line_sys_var_value_tbl(l_index).variable_value := c_get_item_categories_rec.ordered_item;
            x_line_sys_var_value_tbl(l_index).item_id := l_bsa_line_variables.inventory_item_id;
            x_line_sys_var_value_tbl(l_index).org_id := l_bsa_line_variables.org_id;
           END LOOP;

            OPEN c_get_derived_item_category(l_master_org_id, l_bsa_line_variables.inventory_item_id);
            FETCH c_get_derived_item_category INTO l_bsa_derived_item_category;
            CLOSE c_get_derived_item_category;

            l_index      := l_index+1;
            x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
            x_line_sys_var_value_tbl(l_index).variable_code := G_ITEM_CATEGORY_CODE;
            x_line_sys_var_value_tbl(l_index).variable_value := l_bsa_derived_item_category;
            x_line_sys_var_value_tbl(l_index).item_id := l_bsa_line_variables.inventory_item_id;
            x_line_sys_var_value_tbl(l_index).org_id := l_bsa_line_variables.org_id;

            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'74: x_line_var_value_tbl('||j||').variable_code:     '||G_ITEM_CATEGORY_CODE);
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'75: x_line_var_value_tbl('||j||').variable_value_id: '||l_bsa_derived_item_category);
            END IF;
         END IF;

         --AK
       END LOOP;

       CLOSE c_get_bsa_line_variables;

   ELSIF p_doc_type = G_SO_DOC_TYPE THEN
      OPEN c_get_so_line_variables;
      LOOP

          FETCH c_get_so_line_variables INTO l_so_line_variables;
          EXIT WHEN c_get_so_line_variables%NOTFOUND;

          --l_line_number := l_so_line_variables.line_number;

	  -- Bug 4768964 Logic provided by OM
	  IF l_so_line_variables.service_number is not null then
	     IF l_so_line_variables.option_number is not null then
	        IF l_so_line_variables.component_number is not null then
	  	 l_line_number := l_so_line_variables.line_number||'.'||l_so_line_variables.shipment_number||'.'||
	  			  l_so_line_variables.option_number||'.'||l_so_line_variables.component_number||'.'||
	  			  l_so_line_variables.service_number;
	     ELSE
	  	 l_line_number := l_so_line_variables.line_number||'.'||l_so_line_variables.shipment_number||'.'||
				  l_so_line_variables.option_number||'..'||l_so_line_variables.service_number;
	     END IF;

	      --- if a option is not attached
	   ELSE
	      IF l_so_line_variables.component_number is not null then
		 l_line_number := l_so_line_variables.line_number||'.'||l_so_line_variables.shipment_number||'..'||
				  l_so_line_variables.component_number||'.'||l_so_line_variables.service_number;
	      ELSE
		 l_line_number := l_so_line_variables.line_number||'.'||l_so_line_variables.shipment_number||'...'||
				  l_so_line_variables.service_number;
	      END IF;

	   END IF; /* if option number is not null */

	    -- if the service number is null
	  ELSE
	   IF l_so_line_variables.option_number is not null then
	      IF l_so_line_variables.component_number is not null then
		 l_line_number := l_so_line_variables.line_number||'.'||l_so_line_variables.shipment_number||'.'||
				  l_so_line_variables.option_number||'.'||l_so_line_variables.component_number;
	      ELSE
		 l_line_number := l_so_line_variables.line_number||'.'||l_so_line_variables.shipment_number||'.'||
				  l_so_line_variables.option_number;
	      END IF;
	      --- if a option is not attached
	   ELSE
	      IF l_so_line_variables.component_number is not null then
		 l_line_number := l_so_line_variables.line_number||'.'||l_so_line_variables.shipment_number||'..'||
				  l_so_line_variables.component_number;
	      ELSE
		 IF (l_so_line_variables.line_number is NULL and l_so_line_variables.shipment_number is NULL ) THEN
		    l_line_number := NULL;
		 ELSE
		    l_line_number := l_so_line_variables.line_number||'.'||l_so_line_variables.shipment_number;
		 END IF;
	      END IF;

	   END IF; /* if option number is not null */

	  END IF; /* if service number is not null */
	  -- Bug 4768964 Logic provided by OM

          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'80: line_number =        '||l_so_line_variables.line_number );
               fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'90: payment_term_id =        '||l_so_line_variables.payment_term_id );
               fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'100: invoicing_rule_id =        '||l_so_line_variables.invoicing_rule_id );
               fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'110: agreement_id =        '||l_so_line_variables.agreement_id );
               fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'120: item_id =        '||l_so_line_variables.inventory_item_id );
               fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'130: org_id =        '||l_so_line_variables.org_id );
          END IF;


	  l_line_count := l_line_count+1;

          IF l_so_line_variables.payment_term_id IS NOT NULL THEN
            l_index      := l_index+1;
            x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
            x_line_sys_var_value_tbl(l_index).variable_code := G_LINE_PAYMENT_TERM_CODE;
            x_line_sys_var_value_tbl(l_index).variable_value := l_so_line_variables.payment_term_id;
            x_line_sys_var_value_tbl(l_index).item_id := l_so_line_variables.inventory_item_id;
            x_line_sys_var_value_tbl(l_index).org_id := l_so_line_variables.org_id;
          END IF;

          IF l_so_line_variables.invoicing_rule_id IS NOT NULL THEN
            l_index      := l_index+1;
            x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
            x_line_sys_var_value_tbl(l_index).variable_code := G_LINE_INVOICING_RULE_CODE;
            x_line_sys_var_value_tbl(l_index).variable_value := l_so_line_variables.invoicing_rule_id;
            x_line_sys_var_value_tbl(l_index).item_id := l_so_line_variables.inventory_item_id;
            x_line_sys_var_value_tbl(l_index).org_id := l_so_line_variables.org_id;
          END IF;

          IF l_so_line_variables.agreement_id IS NOT NULL THEN
            l_index      := l_index+1;
            x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
            x_line_sys_var_value_tbl(l_index).variable_code := G_LINE_PA_NAME_CODE;
            x_line_sys_var_value_tbl(l_index).variable_value := l_so_line_variables.agreement_id;
            x_line_sys_var_value_tbl(l_index).item_id := l_so_line_variables.inventory_item_id;
            x_line_sys_var_value_tbl(l_index).org_id := l_so_line_variables.org_id;
          END IF;

          --AK
	  IF l_so_line_variables.item_identifier_type = 'INT' THEN
	      l_index      := l_index+1;
	      x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
	      x_line_sys_var_value_tbl(l_index).variable_code := G_ITEM_CODE;
	      x_line_sys_var_value_tbl(l_index).variable_value := l_so_line_variables.ordered_item;
	      x_line_sys_var_value_tbl(l_index).item_id := l_so_line_variables.inventory_item_id;
	      x_line_sys_var_value_tbl(l_index).org_id := l_so_line_variables.org_id;
	  ELSIF l_so_line_variables.item_identifier_type <> 'INT' THEN
	  --map the non-INT items to INT items

	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'90: Mapping non-INT item to INT item, Calling OE_Id_To_Value.Ordered_Item ');
	   END IF;

	   -- Map non-INT item to INT item
	   OE_Id_To_Value.Ordered_Item (
	     p_item_identifier_type  => l_so_line_variables.item_identifier_type,
	     p_inventory_item_id     => l_so_line_variables.inventory_item_id,
	     p_organization_id       => l_master_org_id,
	     p_ordered_item_id       => l_so_line_variables.ordered_item_id,
	     p_sold_to_org_id        => l_so_line_variables.sold_to_org_id,
	     p_ordered_item          => l_so_line_variables.ordered_item,
	     x_ordered_item          => lx_ordered_item,
	     x_inventory_item        => lx_inventory_item
	    );
	      l_index      := l_index+1;
	      x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
	      x_line_sys_var_value_tbl(l_index).variable_code := G_ITEM_CODE;
	      x_line_sys_var_value_tbl(l_index).variable_value := lx_inventory_item;
	      x_line_sys_var_value_tbl(l_index).item_id := l_so_line_variables.inventory_item_id;
	      x_line_sys_var_value_tbl(l_index).org_id := l_so_line_variables.org_id;

	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'100: x_line_var_value_tbl('||j||').variable_code:     ' || G_ITEM_CODE);
	      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'110: x_line_var_value_tbl('||j||').variable_value_id: ' || lx_inventory_item);
	   END IF;
	END IF;

         IF l_so_line_variables.inventory_item_id IS NOT NULL THEN

           FOR c_get_item_categories_rec IN c_get_item_categories LOOP
            l_index      := l_index+1;
            x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
            x_line_sys_var_value_tbl(l_index).variable_code := G_ITEM_CATEGORY_CODE;
            x_line_sys_var_value_tbl(l_index).variable_value := c_get_item_categories_rec.ordered_item;
            x_line_sys_var_value_tbl(l_index).item_id := l_so_line_variables.inventory_item_id;
            x_line_sys_var_value_tbl(l_index).org_id := l_so_line_variables.org_id;
           END LOOP;


            OPEN c_get_derived_item_category(l_master_org_id, l_so_line_variables.inventory_item_id);
            FETCH c_get_derived_item_category INTO l_so_derived_item_category;
            CLOSE c_get_derived_item_category;

            l_index      := l_index+1;
            x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
            x_line_sys_var_value_tbl(l_index).variable_code := G_ITEM_CATEGORY_CODE;
            x_line_sys_var_value_tbl(l_index).variable_value := l_so_derived_item_category;
            x_line_sys_var_value_tbl(l_index).item_id := l_so_line_variables.inventory_item_id;
            x_line_sys_var_value_tbl(l_index).org_id := l_so_line_variables.org_id;


            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'74: x_line_var_value_tbl('||j||').variable_code:     '||G_ITEM_CATEGORY_CODE);
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'75: x_line_var_value_tbl('||j||').variable_value_id: '||l_so_derived_item_category);
            END IF;
         END IF;

         --AK
       END LOOP;

       CLOSE c_get_so_line_variables;

   END IF;

   x_line_count := l_line_count;

   -- Fix for 4768964 to show line number
   IF p_doc_type = G_BSA_DOC_TYPE THEN
      x_line_variables_count := 4; --Item, Item Category, Payment term, Invoicing rule
   ELSIF p_doc_type = G_SO_DOC_TYPE THEN
      x_line_variables_count := 5; --Item, Item Category, Payment term, Invoicing rule, Price Agreement
   END IF;

  IF l_line_count = 0 THEN
      x_line_count := 1; -- Since no Lines, need to set line count to 1 for the CX Java code
      x_line_variables_count := 0; -- Since no Lines, need to set line variables count to 0 for the CX Java code
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'170: End of '||l_package_procedure||'for line level variables, x_return_status:  '|| x_return_status);
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     IF c_get_bsa_line_variables%ISOPEN THEN
     	CLOSE c_get_bsa_line_variables;
     END IF;

     IF c_get_so_line_variables%ISOPEN THEN
     	CLOSE c_get_so_line_variables;
     END IF;


	x_return_status := FND_API.G_RET_STS_ERROR ;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'180: '||l_package_procedure||' In the FND_API.G_EXC_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'190: x_return_status = '||x_return_status);
     END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF c_get_bsa_line_variables%ISOPEN THEN
     	CLOSE c_get_bsa_line_variables;
     END IF;

     IF c_get_so_line_variables%ISOPEN THEN
     	CLOSE c_get_so_line_variables;
     END IF;

  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'200: '||l_package_procedure||' In the FND_API.G_EXC_UNEXPECTED_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'210: x_return_status = '||x_return_status);
     END IF;

   WHEN OTHERS THEN
     IF c_get_bsa_line_variables%ISOPEN THEN
     	CLOSE c_get_bsa_line_variables;
     END IF;

     IF c_get_so_line_variables%ISOPEN THEN
     	CLOSE c_get_so_line_variables;
     END IF;

  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         	   FND_MSG_PUB.Add_Exc_Msg(
          	        G_PKG_NAME ,
          	        l_api_name );
  	END IF;

  	FND_MSG_PUB.Count_And_Get(
  	     	p_count => x_msg_count,
       	      p_data => x_msg_data );

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'220: '||l_package_procedure||' In the OTHERS section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'230: x_return_status = '||x_return_status);
     END IF;

END get_line_variable_values;


END OKC_XPRT_OM_INT_PVT;

/
