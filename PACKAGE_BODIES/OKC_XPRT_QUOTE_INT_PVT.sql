--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_QUOTE_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_QUOTE_INT_PVT" AS
/* $Header: OKCVXQUOTEINTB.pls 120.11 2006/02/15 01:42:28 arsundar noship $ */

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------


  G_FALSE                       CONSTANT VARCHAR2(1)    := FND_API.G_FALSE;
  G_TRUE                        CONSTANT VARCHAR2(1)    := FND_API.G_TRUE;

  G_RET_STS_SUCCESS             CONSTANT VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR               CONSTANT VARCHAR2(1)    := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR         CONSTANT VARCHAR2(1)    := FND_API.G_RET_STS_UNEXP_ERROR;

  G_PKG_NAME                    CONSTANT VARCHAR2(30)   := 'OKC_XPRT_QUOTE_INT_PVT';
  G_APP_NAME                    CONSTANT VARCHAR2(30)   := OKC_API.G_APP_NAME;
  G_STMT_LEVEL                  CONSTANT NUMBER         := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                 CONSTANT VARCHAR2(250)  := 'OKC.PLSQL.'||G_PKG_NAME||'.';

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
  G_CUST_PO_EXIST_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_PO_EXIST';
  G_PRICE_LIST_CODE             CONSTANT VARCHAR2(30)   := 'OKC$S_PRICE_LIST';
  G_TAX_HANDL_CODE              CONSTANT VARCHAR2(30)   := 'OKC$S_TAX_HANDL';
  G_ORDER_TYPE_CODE             CONSTANT VARCHAR2(30)   := 'OKC$S_ORDER_TYPE';
  G_FOB_CODE                    CONSTANT VARCHAR2(30)   := 'OKC$S_FOB';
  G_PAYMENT_TYPE_CODE           CONSTANT VARCHAR2(30)   := 'OKC$S_PAYMENT_TYPE';
  G_SALES_CHANNEL_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_SALES_CHANNEL';
  G_TOTAL_CODE                  CONSTANT VARCHAR2(30)   := 'OKC$S_TOTAL';
  G_TOTAL_ADJUST_AMT_CODE       CONSTANT VARCHAR2(30)   := 'OKC$S_ADJUST_AMOUNT';
  G_TOTAL_ADJUST_PCT_CODE       CONSTANT VARCHAR2(30)   := 'OKC$S_ADJUST_PERCENT';
  G_BILLTO_CUST_NAME_CODE       CONSTANT VARCHAR2(30)   := 'OKC$S_BILLTO_CUST_NAME';
  G_SHIPTO_CUST_NAME_CODE       CONSTANT VARCHAR2(30)   := 'OKC$S_SHIPTO_CUST_NAME';
  G_SALES_DOC_TYPE_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_SALES_DOC_TYPE';
  G_CUST_CATEGORY_CODE          CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_CAT';
  G_CUST_CLASS_CODE             CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_CLASS';
  G_CUST_PROF_CLASS_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_PROF_CLASS';
  G_CUST_CRDT_RATE_CODE         CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_CRDT_RATE';
  G_CUST_CRDT_CLASS_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_CRDT_CLASS';
  G_CUST_RISK_CODE              CONSTANT VARCHAR2(30)   := 'OKC$S_CUST_RISK_CODE';

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

  G_SHIPMENT_PRIORITY_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_SHIPMENT_PRIORITY';
  G_SITE_ID_CODE                  CONSTANT VARCHAR2(30)   := 'OKC$S_SITE_ID';

  -- Added for Agreement type support
  G_PA_TYPE_CODE                  CONSTANT VARCHAR2(30)   := 'OKC$S_PA_TYPE';

  -- Added for line level variables
  G_LINE_PAYMENT_TERM_CODE        CONSTANT VARCHAR2(30)   := 'OKC$S_LINE_PAYMENT_TERM';
  G_LINE_FOB_CODE                 CONSTANT VARCHAR2(30)   := 'OKC$S_LINE_FOB';


PROCEDURE Get_clause_Variable_Values (
    p_api_version               IN            NUMBER,
    p_init_msg_list             IN            VARCHAR2,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2,
    p_doc_id                    IN            NUMBER,
    p_sys_var_value_tbl         IN OUT NOCOPY OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type )
IS

l_api_name          VARCHAR2(30) := 'get_clause_variable_values';
l_package_procedure VARCHAR2(60);
l_api_version 		CONSTANT NUMBER := 1;
l_debug             Boolean;
l_party_id		HZ_PARTIES.party_id%type;
l_module            VARCHAR2(250)   := G_MODULE_NAME||l_api_name;
l_expert_yes		FND_FLEX_VALUES.FLEX_VALUE_ID%type;
l_expert_no		FND_FLEX_VALUES.FLEX_VALUE_ID%type;

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
-- Cursor to fetch the header attributes for the quote
--
CURSOR c_get_quote_header_variables IS
SELECT
      quote.cust_account_id,
      quote.currency_code,
      quote.contract_id price_agreement_id,
--      decode(nvl(to_char(quote.contract_id),'X'),'X','N','Y') price_agreement_exist,
      decode(nvl(to_char(quote.contract_id),'X'),'X',l_expert_no,l_expert_yes) price_agreement_exist,
      quote.total_adjusted_percent,
      quote.total_adjusted_amount,
      quote.total_quote_price,
      quote.order_type_id,
      quote.party_id,
      quote.invoice_to_cust_account_id,
      quote.invoice_to_party_site_id,
      quote.sold_to_party_site_id,
      quote.price_list_id,
      quote.sales_channel_code,
--      decode(nvl(payments.cust_po_number,'X'),'X','N','Y') cust_po_num_exist,
      decode(nvl(payments.cust_po_number,'X'),'X',l_expert_no,l_expert_yes) cust_po_num_exist,
      payments.payment_term_id,
      payments.payment_type_code,
      nvl(tax.tax_exempt_flag,'S') tax_exempt_flag,
      shipments.freight_terms_code,
      shipments.ship_method_code,
      shipments.fob_code,
      shipments.ship_to_cust_account_id,
      shipments.ship_to_party_site_id,
-- XY
	 quote.quote_number,
--	 quote.cust_party_id,
	 quote.quote_version,
	 quote.resource_id,
	 quote.org_id,
	 payments.cust_po_number,
	 shipments.shipment_priority_code,
	 quote.minisite_id
-- XY
FROM
      aso_payments payments,
      aso_tax_details tax,
      aso_shipments shipments,
      aso_quote_headers_all quote
WHERE
      quote.quote_header_id = payments.quote_header_id(+)
 AND  payments.quote_line_id(+) IS NULL
 AND  quote.quote_header_id = tax.quote_header_id(+)
 AND  tax.quote_line_id(+) IS NULL
 AND  quote.quote_header_id = shipments.quote_header_id(+)
 AND  shipments.quote_line_id(+) IS NULL
 AND  quote.quote_header_id = p_doc_id;


--
-- Cursor to fetch the customer information
--

CURSOR c_get_cust_info_var(p_sold_to_org_id NUMBER) IS
SELECT
     hzp.category_code,
	hzp.party_id,
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
AND  hzcp.site_use_id is null
AND  hzc.party_id = hzcp.party_id
AND  hzc.party_id = hzp.party_id
AND  hzc.cust_account_id = p_sold_to_org_id;


--
-- Cursor to get the bill to, ship to and sold to countries
-- for a Quote
--

CURSOR c_get_country_quote(p_party_site_id NUMBER) IS
SELECT
     loc.country
FROM
     hz_locations loc,
     hz_party_sites ps
WHERE
     ps.location_id = loc.location_id
AND  ps.party_site_id = p_party_site_id;

 --
 -- AK: Cursor to get Agreement type for
 -- Quoted Order and Sales Order
 --

 CURSOR c_get_pa_type(p_agreement_id NUMBER) IS
 SELECT
     pc.agreement_type_code
 FROM
     --oe_pricing_contracts_v pc -- Commented for Perf Bug 5027295
     oe_agreements_b pc          -- Added for Perf Bug 5027295
 WHERE
     pc.agreement_id = p_agreement_id;

l_quote_header_variables  c_get_quote_header_variables%ROWTYPE;
l_cust_info_variables	 c_get_cust_info_var%ROWTYPE;
l_customer_category		 hz_parties.category_code%TYPE;


BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_package_procedure := G_PKG_NAME || '.' || l_api_name;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     l_debug := true;
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'10: Entered ' || l_package_procedure);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'20: p_doc_id: ' || p_doc_id);
   END IF;

   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    			l_api_name,
    		    	    	    			G_PKG_NAME) THEN
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

  IF p_sys_var_value_tbl.FIRST IS NOT NULL THEN

     OPEN c_get_quote_header_variables;
     FETCH c_get_quote_header_variables INTO l_quote_header_variables;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'30:c_get_quote_header_variables%ROWCOUNT:  ' || c_get_quote_header_variables%ROWCOUNT);
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'40:Values from l_quote_header_variables are:');
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,' ');
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'************************ ');
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'50: cust_account_id =        '||l_quote_header_variables.cust_account_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'60: currency_code =          '||l_quote_header_variables.currency_code );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'70: price_agreement_id =     '||l_quote_header_variables.price_agreement_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'80: price_agreement_exist =  '||l_quote_header_variables.price_agreement_exist );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'90: total_adjusted_percent = '||l_quote_header_variables.total_adjusted_percent );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'100: total_adjusted_amount = '||l_quote_header_variables.total_adjusted_amount );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'110: total_quote_price =     '||l_quote_header_variables.total_quote_price );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'120: order_type_id =         '||l_quote_header_variables.order_type_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'130: party_id =              '||l_quote_header_variables.party_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'140: invoice_to_cust_account_id = '||l_quote_header_variables.invoice_to_cust_account_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'150: invoice_to_party_site_id = '||l_quote_header_variables.invoice_to_party_site_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'160: sold_to_party_site_id = '||l_quote_header_variables.sold_to_party_site_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'170: price_list_id =         '||l_quote_header_variables.price_list_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'180: sales_channel_code =    '||l_quote_header_variables.sales_channel_code );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'190: cust_po_num_exist =     '||l_quote_header_variables.cust_po_num_exist );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'200: payment_term_id =       '||l_quote_header_variables.payment_term_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'210: payment_type_code =     '||l_quote_header_variables.payment_type_code );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'220: tax_exempt_flag =       '||l_quote_header_variables.tax_exempt_flag );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'230: freight_terms_code =    '||l_quote_header_variables.freight_terms_code );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'240: ship_method_code =      '||l_quote_header_variables.ship_method_code );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'250: fob_code =              '||l_quote_header_variables.fob_code );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'260: ship_to_cust_account_id = '||l_quote_header_variables.ship_to_cust_account_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'270: ship_to_party_site_id = '||l_quote_header_variables.ship_to_party_site_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'272: quote_number =          '||l_quote_header_variables.quote_number );
--	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'273: cust_party_id =         '||l_quote_header_variables.cust_party_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'274: quote_version =         '||l_quote_header_variables.quote_version );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'275: resource_id, =          '||l_quote_header_variables.resource_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'276: org_id =                '||l_quote_header_variables.org_id );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'277: cust_po_number =        '||l_quote_header_variables.cust_po_number );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'278: shipment_priority_code =        '||l_quote_header_variables.shipment_priority_code );
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'279: minisite_id =        '||l_quote_header_variables.minisite_id );


	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'************************ ');
	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,' ');

     END IF;
     CLOSE c_get_quote_header_variables;

  --  Get the customer info

     IF l_quote_header_variables.cust_account_id IS NOT NULL THEN
    	   OPEN c_get_cust_info_var(l_quote_header_variables.cust_account_id);
    	   FETCH c_get_cust_info_var INTO l_cust_info_variables;
    	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'280: c_get_cust_info_var%ROWCOUNT:  ' || c_get_cust_info_var%ROWCOUNT);
             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'290: Values from l_cust_info_variables are:');
	        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,' ');
	        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'************************ ');
	        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'300: category_code =         '||l_cust_info_variables.category_code );
	        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'310: customer_class_code =   '||l_cust_info_variables.customer_class_code );
	        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'320: profile_class_id =      '||l_cust_info_variables.profile_class_id );
	        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'330: credit_rating =         '||l_cust_info_variables.credit_rating );
	        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'340: credit_classification = '||l_cust_info_variables.credit_classification );
	        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'350: risk_code =             '||l_cust_info_variables.risk_code );
	        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'362: party_id =              '||l_cust_info_variables.party_id );
	        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,' ');

    	   END IF;
	      l_party_id := l_cust_info_variables.party_id;
    	   CLOSE c_get_cust_info_var;
     ELSE   -- Customer Category is the only variable considered for prospects
        BEGIN
	      SELECT category_code
		 INTO l_customer_category
		 FROM hz_parties
		 WHERE party_id = l_quote_header_variables.party_id;
    	         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	             fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'360: category_code =      '||l_customer_category );
	        	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,' ');
	        	   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'************************ ');
    	         END IF;
	   EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		   NULL;
    	        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'370: Customer Category does not exist' );
	        	 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,' ');
	        	 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'************************ ');
    	        END IF;
	   END;
     END IF;

     FOR i IN p_sys_var_value_tbl.FIRST..p_sys_var_value_tbl.LAST LOOP

        IF p_sys_var_value_tbl(i).variable_code = G_CUST_CATEGORY_CODE     THEN
           IF l_quote_header_variables.cust_account_id IS NOT NULL THEN
               p_sys_var_value_tbl(i).variable_value_id := l_cust_info_variables.category_code;
		 ELSE
		    p_sys_var_value_tbl(i).variable_value_id := l_customer_category;
		 END IF;
	   END IF;

        IF p_sys_var_value_tbl(i).variable_code = G_CUST_CLASS_CODE
		 AND l_quote_header_variables.cust_account_id IS NOT NULL THEN
           p_sys_var_value_tbl(i).variable_value_id := l_cust_info_variables.customer_class_code;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_PROF_CLASS_CODE
		 AND l_quote_header_variables.cust_account_id IS NOT NULL THEN
           p_sys_var_value_tbl(i).variable_value_id := l_cust_info_variables.profile_class_id;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_CRDT_RATE_CODE
		 AND l_quote_header_variables.cust_account_id IS NOT NULL THEN
           p_sys_var_value_tbl(i).variable_value_id := l_cust_info_variables.credit_rating;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_CRDT_CLASS_CODE
		 AND l_quote_header_variables.cust_account_id IS NOT NULL THEN
           p_sys_var_value_tbl(i).variable_value_id := l_cust_info_variables.credit_classification;

	   ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_RISK_CODE
		 AND l_quote_header_variables.cust_account_id IS NOT NULL THEN
           p_sys_var_value_tbl(i).variable_value_id := l_cust_info_variables.risk_code;
	   END IF;


        IF p_sys_var_value_tbl(i).variable_code = G_SOLDTO_COUNTRY_CODE THEN
           IF l_quote_header_variables.sold_to_party_site_id IS NOT NULL THEN
		    OPEN c_get_country_quote(l_quote_header_variables.sold_to_party_site_id);
		    FETCH c_get_country_quote INTO p_sys_var_value_tbl(i).variable_value_id;
		    CLOSE c_get_country_quote;
    	         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	            fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'380: Sold to country = '||p_sys_var_value_tbl(i).variable_value_id);
    	         END IF;
	      END IF;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SHIPTO_COUNTRY_CODE THEN
           IF l_quote_header_variables.ship_to_party_site_id IS NOT NULL THEN
              OPEN c_get_country_quote(l_quote_header_variables.ship_to_party_site_id);
              FETCH c_get_country_quote INTO p_sys_var_value_tbl(i).variable_value_id;
              CLOSE c_get_country_quote;
    	         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	            fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'390: Ship to country = '||p_sys_var_value_tbl(i).variable_value_id);
    	         END IF;
	      END IF;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_BILLTO_COUNTRY_CODE THEN
           IF l_quote_header_variables.invoice_to_party_site_id IS NOT NULL THEN
              OPEN c_get_country_quote(l_quote_header_variables.invoice_to_party_site_id);
              FETCH c_get_country_quote INTO p_sys_var_value_tbl(i).variable_value_id;
              CLOSE c_get_country_quote;
    	         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	            fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'400: Invoice to country = '||p_sys_var_value_tbl(i).variable_value_id);
    	         END IF;
	      END IF;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUSTOMER_NAME_CODE     THEN
           p_sys_var_value_tbl(i).variable_value_id := nvl(l_quote_header_variables.cust_account_id, l_party_id);

        ELSIF p_sys_var_value_tbl(i).variable_code = G_BILLTO_CUST_NAME_CODE    THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.invoice_to_cust_account_id;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SHIPTO_CUST_NAME_CODE      THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.ship_to_cust_account_id;

   	   ELSIF p_sys_var_value_tbl(i).variable_code = G_SALES_DOC_TYPE_CODE     THEN
           p_sys_var_value_tbl(i).variable_value_id := G_QUOTE_DOC_TYPE;

    	   ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_PO_EXIST_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.cust_po_num_exist;

    	   ELSIF p_sys_var_value_tbl(i).variable_code = G_PRICE_LIST_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.price_list_id;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CURRENCY_CODE    THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.currency_code;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_FREIGHT_TERMS_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.freight_terms_code;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SHIPPING_METHOD_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.ship_method_code;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_PAYMENT_TERM_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.payment_term_id;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_PA_NAME_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.price_agreement_id;

--AK
        ELSIF p_sys_var_value_tbl(i).variable_code = G_PA_TYPE_CODE     THEN
           BEGIN
	      IF l_quote_header_variables.price_agreement_id IS NOT NULL THEN
	         OPEN c_get_pa_type(l_quote_header_variables.price_agreement_id);
	         FETCH c_get_pa_type INTO p_sys_var_value_tbl(i).variable_value_id;
	         CLOSE c_get_pa_type;
	      END IF;
	   END;
--AK

        ELSIF p_sys_var_value_tbl(i).variable_code = G_PA_NAME_EXIST_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.price_agreement_exist;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_PAYMENT_TYPE_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.payment_type_code;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_FOB_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.fob_code;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SALES_CHANNEL_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.sales_channel_code;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_TAX_HANDL_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.tax_exempt_flag;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_ORDER_TYPE_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.order_type_id;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_TOTAL_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.total_quote_price;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_TOTAL_ADJUST_AMT_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.total_adjusted_amount;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_TOTAL_ADJUST_PCT_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.total_adjusted_percent;
-- XY

        ELSIF p_sys_var_value_tbl(i).variable_code = G_QUOTE_NUMBER_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.quote_number;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_PO_NUMBER_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.cust_po_number;
        -- Added for iStore
        ELSIF p_sys_var_value_tbl(i).variable_code = G_SHIPMENT_PRIORITY_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.shipment_priority_code;
        ELSIF p_sys_var_value_tbl(i).variable_code = G_SITE_ID_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.minisite_id;
        --
        ELSIF p_sys_var_value_tbl(i).variable_code = G_VERSION_NUMBER_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.quote_version;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUST_CONTACT_NAME_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.party_id;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SALESREP_NAME_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.resource_id;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_SUPPLIER_NAME_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.org_id;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CURRENCY_NAME_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.currency_code;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CURRENCY_SYMBOL_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.currency_code;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_PA_NUMBER_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.price_agreement_id;

        ELSIF p_sys_var_value_tbl(i).variable_code = G_CUSTOMER_NUMBER_CODE   THEN
           p_sys_var_value_tbl(i).variable_value_id := l_quote_header_variables.cust_account_id;

-- XY

        END IF;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,' ');
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'410: p_sys_var_value_tbl('||i||').variable_code     : '||p_sys_var_value_tbl(i).variable_code);
           fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'415: p_sys_var_value_tbl('||i||').variable_value_id : '||p_sys_var_value_tbl(i).variable_value_id);
        END IF;

     END LOOP;

  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,' ');
	 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'************************ ');
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'420: End of '||l_package_procedure||' for header level variables, x_return_status ' || x_return_status);
  END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	IF c_get_quote_header_variables%ISOPEN THEN
	   CLOSE c_get_quote_header_variables;
	END IF;

	IF c_get_cust_info_var%ISOPEN THEN
	   CLOSE c_get_cust_info_var;
	END IF;

     IF c_get_country_quote%ISOPEN THEN
        CLOSE c_get_country_quote;
     END IF;

     IF c_get_expert_yes_no%ISOPEN THEN
        CLOSE c_get_expert_yes_no;
     END IF;

	x_return_status := FND_API.G_RET_STS_ERROR ;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'430: '||l_package_procedure||' In the FND_API.G_RET_STS_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'440: x_return_status = '||x_return_status);
     END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF c_get_quote_header_variables%ISOPEN THEN
           CLOSE c_get_quote_header_variables;
        END IF;

        IF c_get_cust_info_var%ISOPEN THEN
           CLOSE c_get_cust_info_var;
        END IF;

        IF c_get_country_quote%ISOPEN THEN
           CLOSE c_get_country_quote;
        END IF;

        IF c_get_expert_yes_no%ISOPEN THEN
           CLOSE c_get_expert_yes_no;
        END IF;

  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'450: '||l_package_procedure||' In the FND_API.G_EXC_UNEXPECTED_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'460: x_return_status = '||x_return_status);
     END IF;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

   WHEN OTHERS THEN

     IF c_get_quote_header_variables%ISOPEN THEN
        CLOSE c_get_quote_header_variables;
     END IF;

     IF c_get_cust_info_var%ISOPEN THEN
        CLOSE c_get_cust_info_var;
     END IF;

     IF c_get_country_quote%ISOPEN THEN
        CLOSE c_get_country_quote;
     END IF;

     IF c_get_expert_yes_no%ISOPEN THEN
        CLOSE c_get_expert_yes_no;
     END IF;

  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'470: '||l_package_procedure||' In the FND_API.G_RET_STS_UNEXP_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'480: x_return_status = '||x_return_status);
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
  PROCEDURE Get_clause_Variable_Values (
    p_api_version               IN         NUMBER,
    p_init_msg_list             IN         VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_doc_id                    IN         NUMBER,
    p_variables_tbl             IN         OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type,
    x_line_var_value_tbl        OUT NOCOPY OKC_TERMS_UTIL_GRP.item_dtl_tbl
  ) IS

l_api_name          VARCHAR2(30) := 'get_clause_variable_values - 2';
l_package_procedure VARCHAR2(60);
l_api_version       CONSTANT NUMBER := 1;
l_index             BINARY_INTEGER;
l_debug             Boolean;
l_module            VARCHAR2(250) := G_MODULE_NAME||l_api_name;

BEGIN

   l_package_procedure := G_PKG_NAME || '.' || l_api_name;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_debug := true;
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,' ');
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'10: Start '||l_package_procedure);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'20: Entered ' || l_package_procedure);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'30: p_doc_id: ' || p_doc_id);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'40: p_variables_tbl.COUNT: ' || p_variables_tbl.COUNT);
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

	l_index := p_variables_tbl.FIRST;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'50: l_index = '||l_index);
     END IF;

	WHILE l_index IS NOT NULL
	LOOP
	   IF p_variables_tbl(l_index).Variable_code = G_ITEM_CODE THEN
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'60: variable code = '||p_variables_tbl(l_index).Variable_code);
           END IF;
	      SELECT
		    items.concatenated_segments
           BULK COLLECT INTO x_line_var_value_tbl.item
           FROM
		    Mtl_System_Items_vl items,
		    Aso_Quote_Lines_all lines
           WHERE
	         lines.inventory_item_id = items.INVENTORY_ITEM_ID
             AND lines.organization_id = items.organization_id
             AND lines.LINE_CATEGORY_CODE = 'ORDER'
             AND lines.quote_header_id = p_doc_id;

	   ELSIF p_variables_tbl(l_index).Variable_code = G_ITEM_CATEGORY_CODE THEN
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'70: variable code = '||p_variables_tbl(l_index).Variable_code);
           END IF;

	      SELECT
		      cats.category_concat_segs
           BULK COLLECT INTO x_line_var_value_tbl.category
        	 FROM
		    Mtl_Item_Categories mic,
		    Aso_Quote_Lines_all lines,
		    Mtl_Categories_V cats
        	 WHERE
		    lines.inventory_item_id = mic.INVENTORY_ITEM_ID
             AND mic.category_id = cats.category_id
             AND mic.organization_id = lines.organization_id
             AND mic.category_set_id = (
					SELECT nvl(FND_PROFILE.VALUE('ASO_CATEGORY_SET'), sets.category_set_id )
              			FROM Mtl_Default_Category_Sets sets
              			WHERE functional_area_id = 7
				     )
             AND lines.LINE_CATEGORY_CODE = 'ORDER'
         	   AND lines.quote_header_id = p_doc_id;
	   END IF;

	      l_index := p_variables_tbl.next(l_index);
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'80: l_index = '||l_index);
           END IF;

	END LOOP;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      IF x_line_var_value_tbl.item.COUNT > 0 THEN
	    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'90: Item Count = '||x_line_var_value_tbl.item.COUNT);
         FOR i IN x_line_var_value_tbl.item.FIRST..x_line_var_value_tbl.item.LAST LOOP
	       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'100: Item : '||x_line_var_value_tbl.item(i));
	    END LOOP;
	 END IF;
      IF x_line_var_value_tbl.category.COUNT > 0 THEN
	    fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'110: Item category Count = '||x_line_var_value_tbl.category.COUNT);
         FOR i IN x_line_var_value_tbl.category.FIRST..x_line_var_value_tbl.category.LAST LOOP
	       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'120: Item category: '||x_line_var_value_tbl.category(i));
	    END LOOP;
	 END IF;
	 fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'130:End of '||l_package_procedure||' for header level variables, x_return_status ' || x_return_status);
  END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	x_return_status := FND_API.G_RET_STS_ERROR ;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'130: '||l_package_procedure||' In the FND_API.G_EXC_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'140: x_return_status = '||x_return_status);
     END IF;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'150: '||l_package_procedure||' In the FND_API.G_EXC_UNEXPECTED_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'160: x_return_status = '||x_return_status);
     END IF;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

   WHEN OTHERS THEN

  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'170: '||l_package_procedure||' In the OTHERS section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'180: x_return_status = '||x_return_status);
     END IF;

    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         	   FND_MSG_PUB.Add_Exc_Msg(
          	        G_PKG_NAME ,
          	        l_api_name );
  	END IF;

  	FND_MSG_PUB.Count_And_Get(
  	     p_count => x_msg_count,
       	 p_data => x_msg_data );

END Get_clause_Variable_Values;

-- This procedure will be called from contract expert to get
-- line level system variables
PROCEDURE Get_Line_Variable_Values (
    p_api_version               IN            NUMBER,
    p_init_msg_list             IN            VARCHAR2 DEFAULT FND_API.G_FALSE,
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
--l_index             BINARY_INTEGER;
l_debug             Boolean;
l_module            VARCHAR2(250) := G_MODULE_NAME||l_api_name;

--
-- Cursor to fetch the line attributes for the quote
--
CURSOR c_get_quote_line_variables IS
SELECT
      quote.quote_line_id,
      ASO_LINE_NUM_INT.Get_UI_Line_Number(quote.quote_line_id) line_number, -- Changed for Bug 4768964
      nvl(payments.payment_term_id,'-99999') payment_term_id,
      nvl(shipments.fob_code,'NO_VALUE') fob_code,
      quote.inventory_item_id,
      quote.org_id
FROM
      aso_payments payments,
      aso_shipments shipments,
      aso_quote_lines_all quote
WHERE
      quote.quote_line_id = payments.quote_line_id(+)
 AND  quote.quote_line_id = shipments.quote_line_id(+)
 AND  quote.quote_header_id = p_doc_id;

l_quote_line_variables  c_get_quote_line_variables%ROWTYPE;
l_line_count	NUMBER := 0;
l_line_number   VARCHAR2(250); --NUMBER; For Bug 4768964
l_index	  NUMBER := 0;

--AK
CURSOR c_get_quote_item (p_quote_line_id NUMBER) IS
SELECT
    items.concatenated_segments item
FROM
    Mtl_System_Items_vl items,
    Aso_Quote_Lines_all lines
WHERE
 lines.inventory_item_id = items.INVENTORY_ITEM_ID
AND lines.organization_id = items.organization_id
--AND lines.LINE_CATEGORY_CODE = 'ORDER'
AND lines.quote_header_id = p_doc_id
AND lines.quote_line_id = p_quote_line_id;

CURSOR c_get_quote_item_category (p_quote_line_id NUMBER) IS
SELECT
      cats.category_concat_segs item_category
 FROM
    Mtl_Item_Categories mic,
    Aso_Quote_Lines_all lines,
    Mtl_Categories_V cats
 WHERE
    lines.inventory_item_id = mic.INVENTORY_ITEM_ID
AND mic.category_id = cats.category_id
AND mic.organization_id = lines.organization_id
AND mic.category_set_id = (
			SELECT nvl(FND_PROFILE.VALUE('ASO_CATEGORY_SET'), sets.category_set_id )
		FROM Mtl_Default_Category_Sets sets
		WHERE functional_area_id = 7
		     )
AND lines.LINE_CATEGORY_CODE = 'ORDER'
AND lines.quote_header_id = p_doc_id
AND lines.quote_line_id = p_quote_line_id;

--AK

-- New Line Number
l_in_qte_line_number_tbl ASO_LINE_NUM_INT.In_Line_Number_Tbl_Type;
l_out_qte_line_number_tbl ASO_LINE_NUM_INT.Out_Line_Number_Tbl_Type;
i NUMBER := 1;
l_quote_org_id NUMBER;
CURSOR c_get_quote_org_id IS
SELECT
      quote.org_id
FROM
      aso_quote_headers_all quote
WHERE
      quote.quote_header_id = p_doc_id;
-- New Line Number

BEGIN

   l_package_procedure := G_PKG_NAME || '.' || l_api_name;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      l_debug := true;
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,' ');
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'10: Start '||l_package_procedure);
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'20: Entered ' || l_package_procedure);
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

   OPEN c_get_quote_org_id;
   FETCH c_get_quote_org_id INTO l_quote_org_id;
   CLOSE c_get_quote_org_id;

   MO_GLOBAL.INIT('ASO');
   MO_GLOBAL.SET_POLICY_CONTEXT('S',l_quote_org_id);

   OPEN c_get_quote_line_variables;
   LOOP
     FETCH c_get_quote_line_variables INTO l_quote_line_variables;
     EXIT WHEN c_get_quote_line_variables%NOTFOUND;

     --l_line_number := l_quote_line_variables.line_number;

     -- Begin
     aso_line_num_int.reset_line_num;
     l_in_qte_line_number_tbl(i).quote_line_id := l_quote_line_variables.quote_line_id;
     aso_line_num_int.aso_ui_line_number( p_in_Line_number_tbl   => l_in_qte_line_number_tbl,
                                          x_out_line_number_tbl  => l_out_qte_line_number_tbl);
     l_line_number := l_out_qte_line_number_tbl(l_in_qte_line_number_tbl(i).quote_line_id);
     i := i + 1;
     -- End

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'40: line_number =        '||l_quote_line_variables.line_number );
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'50: payment_term_id =        '||l_quote_line_variables.payment_term_id );
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'60: item_id =        '||l_quote_line_variables.inventory_item_id );
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'70: org_id =        '||l_quote_line_variables.org_id );
     END IF;


	l_line_count := l_line_count+1;

     IF l_quote_line_variables.payment_term_id IS NOT NULL THEN
       l_index      := l_index+1;
       x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
       x_line_sys_var_value_tbl(l_index).variable_code := G_LINE_PAYMENT_TERM_CODE;
       x_line_sys_var_value_tbl(l_index).variable_value := l_quote_line_variables.payment_term_id;
       x_line_sys_var_value_tbl(l_index).item_id := l_quote_line_variables.inventory_item_id;
       x_line_sys_var_value_tbl(l_index).org_id := l_quote_line_variables.org_id;
     END IF;

     IF l_quote_line_variables.fob_code IS NOT NULL THEN
       l_index      := l_index+1;
       x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
       x_line_sys_var_value_tbl(l_index).variable_code := G_LINE_FOB_CODE;
       x_line_sys_var_value_tbl(l_index).variable_value := l_quote_line_variables.fob_code;
       x_line_sys_var_value_tbl(l_index).item_id := l_quote_line_variables.inventory_item_id;
       x_line_sys_var_value_tbl(l_index).org_id := l_quote_line_variables.org_id;
     END IF;

    IF l_quote_line_variables.inventory_item_id IS NOT NULL THEN
      FOR c_get_quote_item_rec IN c_get_quote_item(l_quote_line_variables.quote_line_id) LOOP
       l_index      := l_index+1;
       x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
       x_line_sys_var_value_tbl(l_index).variable_code := G_ITEM_CODE;
       x_line_sys_var_value_tbl(l_index).variable_value := c_get_quote_item_rec.item;
       x_line_sys_var_value_tbl(l_index).item_id := l_quote_line_variables.inventory_item_id;
       x_line_sys_var_value_tbl(l_index).org_id := l_quote_line_variables.org_id;
      END LOOP;
    END IF;

    IF l_quote_line_variables.inventory_item_id IS NOT NULL THEN
      FOR c_get_quote_item_category_rec IN c_get_quote_item_category(l_quote_line_variables.quote_line_id) LOOP
       l_index      := l_index+1;
       x_line_sys_var_value_tbl(l_index).line_number :=  l_line_number;
       x_line_sys_var_value_tbl(l_index).variable_code := G_ITEM_CATEGORY_CODE;
       x_line_sys_var_value_tbl(l_index).variable_value := c_get_quote_item_category_rec.item_category;
       x_line_sys_var_value_tbl(l_index).item_id := l_quote_line_variables.inventory_item_id;
       x_line_sys_var_value_tbl(l_index).org_id := l_quote_line_variables.org_id;
      END LOOP;
    END IF;

   END LOOP;

   CLOSE c_get_quote_line_variables;

   x_line_count := l_line_count;
   -- Fix for 4768964 to show line number
   x_line_variables_count := 4; --Item, Item Category, Payment term, FOB

  IF l_line_count = 0 THEN
      x_line_count := 1; -- Since no Lines, need to set line count to 1 for the CX Java code
      x_line_variables_count := 0; -- Since no Lines, need to set line variables count to 0 for the CX Java code
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'130:End of '||l_package_procedure||' for line level variables, x_return_status ' || x_return_status);
  END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

     IF c_get_quote_line_variables%ISOPEN THEN
     	CLOSE c_get_quote_line_variables;
     END IF;


	x_return_status := FND_API.G_RET_STS_ERROR ;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'130: '||l_package_procedure||' In the FND_API.G_EXC_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'140: x_return_status = '||x_return_status);
     END IF;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF c_get_quote_line_variables%ISOPEN THEN
     	CLOSE c_get_quote_line_variables;
     END IF;


  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'150: '||l_package_procedure||' In the FND_API.G_EXC_UNEXPECTED_ERROR section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'160: x_return_status = '||x_return_status);
     END IF;

  	FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          	    p_data => x_msg_data  );

   WHEN OTHERS THEN
     IF c_get_quote_line_variables%ISOPEN THEN
     	CLOSE c_get_quote_line_variables;
     END IF;

  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'170: '||l_package_procedure||' In the OTHERS section');
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,l_module,'180: x_return_status = '||x_return_status);
     END IF;

    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         	   FND_MSG_PUB.Add_Exc_Msg(
          	        G_PKG_NAME ,
          	        l_api_name );
  	END IF;

  	FND_MSG_PUB.Count_And_Get(
  	     p_count => x_msg_count,
       	 p_data => x_msg_data );

END Get_Line_Variable_Values;




END OKC_XPRT_QUOTE_INT_PVT;

/
