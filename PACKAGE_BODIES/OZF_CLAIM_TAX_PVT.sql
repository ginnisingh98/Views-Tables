--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_TAX_PVT" AS
/* $Header: ozfvtaxb.pls 120.10 2006/05/02 00:40:49 sshivali ship $ */

G_PKG_NAME	     CONSTANT VARCHAR2(30) := 'OZF_CLAIM_TAX_PVT';
G_FILE_NAME	     CONSTANT VARCHAR2(12) := 'ozfvtaxb.pls';

OZF_DEBUG_HIGH_ON    CONSTANT BOOLEAN	   := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON     CONSTANT BOOLEAN	   := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

/*=======================================================================*
 | PROCEDURE
 |   Validate_Claim_For_Tax
 |
 | NOTES
 |    This API default claim line recored against different settlement method.
 |
 | HISTORY
 *=======================================================================*/
PROCEDURE Validate_Claim_For_Tax(
    p_api_version	    IN	NUMBER
   ,p_init_msg_list	    IN	VARCHAR2 := FND_API.g_false
   ,p_validation_level	    IN	NUMBER	 := FND_API.g_valid_level_full

   ,x_return_status	  OUT NOCOPY VARCHAR2
   ,x_msg_data		  OUT NOCOPY VARCHAR2
   ,x_msg_count		  OUT NOCOPY NUMBER

   ,p_claim_rec		   IN  OZF_CLAIM_PVT.claim_rec_type
)  IS
l_api_version	       CONSTANT	NUMBER	     :=	1.0;
l_api_name	       CONSTANT	VARCHAR2(30) :=	'Validate_Claim_For_Tax';
l_full_name	       CONSTANT	VARCHAR2(60) :=	g_pkg_name ||'.'|| l_api_name;

BEGIN
   IF OZF_DEBUG_HIGH_ON	THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   --  Do Header Level Validation
   IF p_claim_rec.payment_method  IN ( 'EFT','WIRE','CHECK','AP_DEBIT',	'AP_DEFAULT')  AND
       p_claim_rec.vendor_id IS	NULL AND p_claim_rec.vendor_site_id IS NULL THEN
	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	      FND_MESSAGE.set_name('OZF', 'OZF_VENDOR_INFO_MISSING');
	      FND_MSG_PUB.add;
	   END IF;
	   RAISE FND_API.g_exc_error;
   END IF;

   IF OZF_DEBUG_HIGH_ON	THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;

EXCEPTION
   WHEN	FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN	OTHERS THEN
     x_return_status :=	FND_API.g_ret_sts_unexp_error;
     IF	FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	 FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

END Validate_Claim_For_Tax;



/*=======================================================================*
 | PROCEDURE
 |    Calculate_Claim_Line_Tax
 |
 | NOTES
 |    This API default claim line recored against different settlement method.
 |
 | HISTORY
 |    14-NOV-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Calculate_Claim_Line_Tax(
    p_api_version	    IN	NUMBER
   ,p_init_msg_list	    IN	VARCHAR2 := FND_API.g_false
   ,p_validation_level	    IN	NUMBER	 := FND_API.g_valid_level_full

   ,x_return_status	    OUT	NOCOPY VARCHAR2
   ,x_msg_data		    OUT	NOCOPY VARCHAR2
   ,x_msg_count		    OUT	NOCOPY NUMBER

   ,p_x_claim_line_rec	    IN OUT NOCOPY OZF_CLAIM_LINE_PVT.claim_line_rec_type
)
IS
l_api_version	       CONSTANT	NUMBER	     :=	1.0;
l_api_name	       CONSTANT	VARCHAR2(30) :=	'Calculate_Claim_Line_Tax';
l_full_name	       CONSTANT	VARCHAR2(60) :=	g_pkg_name ||'.'|| l_api_name;
l_return_status			VARCHAR2(1);
---

CURSOR csr_claim(cv_claim_id IN	NUMBER)	IS
  SELECT
	 oc.set_of_books_id
  ,	 oc.claim_class
  ,	 oc.currency_code
  ,	 fc.precision
  ,	 oc.payment_method
  ,	 oc.exchange_rate_type
  ,	 oc.exchange_rate_date
  ,	 oc.exchange_rate
  ,	 oc.org_id
  FROM ozf_claims oc
  ,    fnd_currencies fc
  WHERE	oc.currency_code = fc.currency_code
  AND	  oc.claim_id	   = cv_claim_id;
l_claim_header	     OZF_CLAIM_PVT.claim_rec_type;

CURSOR	csr_stlmnt_tax_type(p_claim_id IN NUMBER) IS
 SELECT	 tax_for
   FROM	  ozf_claim_sttlmnt_methods_all	 ssm
	     , ozf_claims_all oc
WHERE	ssm.settlement_method =	oc.payment_method
    AND	   ssm.claim_class = oc.claim_class
    AND	   NVL(ssm.source_object_class,	'_NULL_') = NVL(oc.source_object_class,	'_NULL_')
    AND	   ssm.org_id =	oc.org_id
    AND	   oc.claim_id	= p_claim_id;
l_tax_type   VARCHAR2(30);

-- fix for bug 5042046
CURSOR csr_function_currency IS
  SELECT  gs.currency_code
  FROM	   gl_sets_of_books gs
  ,		ozf_sys_parameters org
  WHERE	 org.set_of_books_id = gs.set_of_books_id
  AND	 org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

l_function_currency    VARCHAR2(15);

CURSOR	 csr_curr_details(p_curr_code IN VARCHAR2)  IS
  SELECT  minimum_accountable_unit,
		precision
    FROM  fnd_currencies
  WHERE	currency_code =	p_curr_code
      AND  NVL(enabled_flag,'N') = 'Y';

CURSOR	  csr_cm_dm_trx_id(p_claim_type_id IN NUMBER) IS
   SELECT  cm_trx_type_id,
		 dm_trx_type_id
      FROM  ozf_claim_types_all_b
    WHERE  claim_type_id = p_claim_type_id;
 l_cm_trx_type_id   NUMBER;
 l_dm_trx_type_id   NUMBER;


 CURSOR	 csr_cust_party_details(p_cust_acct_site_use_id	IN NUMBER) IS
    SELECT  party_site.party_site_id,
		  party_site.location_id
      FROM   hz_cust_site_uses_all   cust_site_use,
		  hz_cust_acct_sites_all  cust_site,
		  hz_party_sites	  party_site
    WHERE  site_use_id = p_cust_acct_site_use_id
	AND   cust_site.cust_acct_site_id = cust_site_use.cust_acct_site_id
	AND   cust_site.party_site_id	  = party_site.party_site_id;

CURSOR	  csr_vendor_site_details(p_vendor_site_id IN NUMBER) IS
   SELECT  party_site_id,
		 location_id
     FROM   po_vendor_sites
  WHERE	   vendor_site_id = p_vendor_site_id;

CURSOR	csr_ap_ship_to_location	IS
 SELECT	 ship_to_location_id
    FROM  ap_supplier_sites_all
  WHERE	 vendor_site_id	= l_claim_header.vendor_site_id;

l_transaction_rec  zx_api_pub.transaction_rec_type;

--bug 5138121
CURSOR csr_zx_tax_details(p_org_id IN NUMBER, p_application_id IN NUMBER,
                          p_entity_code IN VARCHAR2, p_event_class_code IN VARCHAR2,
                          p_claim_id IN	NUMBER, p_claim_line_id IN NUMBER) IS
 SELECT	 SUM(DECODE(tax_amt_included_flag, 'Y',0, tax_amt_tax_curr)),
	       SUM(DECODE(tax_amt_included_flag, 'Y',0,	tax_amt_funcl_curr))
   FROM	  zx_detail_tax_lines_gt
  WHERE	 internal_organization_id = p_org_id
    AND	 application_id	= p_application_id
    AND	 entity_code = p_entity_code
    AND	 event_class_code = p_event_class_code
    AND	 trx_id	= p_claim_id
    AND	 trx_line_id = p_claim_line_id;

l_tax_amount	      NUMBER;
l_tax_acctd_amount    NUMBER;

l_return_exc_rate      NUMBER;

l_dummy	  VARCHAR2(30);
l_calc_tax_rate	 NUMBER;
l_calc_incl_tax_amt  NUMBER;
BEGIN
   IF OZF_DEBUG_HIGH_ON	THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   OZF_AR_PAYMENT_PVT.Query_Claim(
	  p_claim_id	 =>  p_x_claim_line_rec.claim_id
	  ,x_claim_rec	 =>  l_claim_header
	  ,x_return_status    => l_return_status);
   IF l_return_status =	FND_API.g_ret_sts_error	THEN
	  RAISE	FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
	 RAISE FND_API.g_exc_unexpected_error;
   END IF;


   --  Step 1: Validate	(Stage 1)---------------------------------------
   IF l_claim_header.payment_method = 'RMA' THEN
	IF p_x_claim_line_rec.item_id IS NULL OR p_x_claim_line_rec.quantity IS	NULL OR
		  p_x_claim_line_rec.rate IS NULL
       THEN
	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	      FND_MESSAGE.set_name('OZF', 'OZF_PROD_QTY_PRICE_MISSING');
	      FND_MSG_PUB.add;
	   END IF;
	   RAISE FND_API.g_exc_error;
	END IF;
   END IF;

   IF l_claim_header.payment_method = 'REG_CREDIT_MEMO'	THEN
	IF p_x_claim_line_rec.source_object_class IS NULL OR p_x_claim_line_rec.source_object_id IS NULL
	    AND	p_x_claim_line_rec.source_object_id NOT	IN ( 'INVOICE',	'CB', 'DM' ) THEN
		 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		      FND_MESSAGE.set_name('OZF', 'OZF_INV_INFO_MISSING');
		      FND_MSG_PUB.add;
		 END IF;
		 RAISE FND_API.g_exc_error;
	 END IF;
	IF p_x_claim_line_rec. credit_to IS NOT	NULL OR	p_x_claim_line_rec. source_object_line_id IS NULL THEN
		 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		      FND_MESSAGE.set_name('OZF', 'OZF_REGCM_TAXCALC_ERR');
		      FND_MSG_PUB.add;
		 END IF;
		 RAISE FND_API.g_exc_error;
	END IF;
  END IF;

 -- Step2: Init	and Populate the global	stucture
   IF OZF_DEBUG_HIGH_ON	THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : Populating	the Global Structure');
   END IF;

   zx_global_structures_pkg.init_trx_line_dist_tbl(1);

    -- Populate	the common values in the structure
    zx_global_structures_pkg.trx_line_dist_tbl.internal_organization_id(1) := l_claim_header.org_id;
    zx_global_structures_pkg.trx_line_dist_tbl.trx_id(1)		   := l_claim_header.claim_id;
    zx_global_structures_pkg.trx_line_dist_tbl.trx_date(1)		 := NVL(l_claim_header.effective_date, SYSDATE);
    zx_global_structures_pkg.trx_line_dist_tbl.trx_line_date(1)	       := NVL(l_claim_header.effective_date, SYSDATE);
    zx_global_structures_pkg.trx_line_dist_tbl.ledger_id(1)		  := l_claim_header.set_of_books_id;
    zx_global_structures_pkg.trx_line_dist_tbl.trx_currency_code(1)  :=	 l_claim_header.currency_code;
    zx_global_structures_pkg.trx_line_dist_tbl.legal_entity_id(1)	  :=  l_claim_header.legal_entity_id;
    zx_global_structures_pkg.trx_line_dist_tbl.trx_level_type(1)	  := 'LINE';
    zx_global_structures_pkg.trx_line_dist_tbl.line_level_action(1)	  := 'CREATE';
    zx_global_structures_pkg.trx_line_dist_tbl.quote_flag(1)		    := 'Y';

    OPEN    csr_curr_details(l_claim_header.currency_code);
    FETCH  csr_curr_details  INTO zx_global_structures_pkg.trx_line_dist_tbl.minimum_accountable_unit(1)
						    , zx_global_structures_pkg.trx_line_dist_tbl.precision(1);
    CLOSE  csr_curr_details;

   zx_global_structures_pkg.trx_line_dist_tbl.line_amt_includes_tax_flag(1) := 'N';


  OPEN	    csr_stlmnt_tax_type(l_claim_header.claim_id);
  FETCH	   csr_stlmnt_tax_type	INTO l_tax_type;
  CLOSE	   csr_stlmnt_tax_type;

  IF  l_tax_type = 'AP'	THEN

      zx_global_structures_pkg.trx_line_dist_tbl.application_id(1)		       := 200;
      zx_global_structures_pkg.trx_line_dist_tbl.entity_code(1)				:= 'AP_INVOICES';
      zx_global_structures_pkg.trx_line_dist_tbl.event_class_code(1)		    := 'STANDARD INVOICES';
      zx_global_structures_pkg.trx_line_dist_tbl.source_application_id(1)	   := 682;
      zx_global_structures_pkg.trx_line_dist_tbl.source_entity_code(1)		   := 'OZF_CLAIMS';
      zx_global_structures_pkg.trx_line_dist_tbl.source_event_class_code(1)    := 'TRADE_MGT_PAYABLES';
      zx_global_structures_pkg.trx_line_dist_tbl.event_type_code(1)		    := 'STANDARD CREATED';

	-- Ship	From Information. Bill From Info not Required
	OPEN	csr_vendor_site_details(l_claim_header.vendor_site_id);
	FETCH  csr_vendor_site_details	INTO  zx_global_structures_pkg.trx_line_dist_tbl.ship_from_party_site_id(1),
								      zx_global_structures_pkg.trx_line_dist_tbl.ship_from_location_id(1);
	CLOSE  csr_vendor_site_details;

	-- Bill	To Information?
	-- zx_global_structures_pkg.trx_line_dist_tbl.bill_to_location_id(1)	:=  ??

       -- Ship To Information
       OPEN csr_ap_ship_to_location;
       FETCH csr_ap_ship_to_location INTO zx_global_structures_pkg.trx_line_dist_tbl.ship_to_location_id(1);
       CLOSE csr_ap_ship_to_location;

   ELSE

      zx_global_structures_pkg.trx_line_dist_tbl.application_id(1)	     :=	222;
      zx_global_structures_pkg.trx_line_dist_tbl.entity_code(1)		     :=	'TRANSACTIONS';

      IF  l_claim_header.payment_method = 'RMA' THEN
	 zx_global_structures_pkg.trx_line_dist_tbl.event_class_code(1)	 := 'SALES_TRANSACTION_TAX_QUOTE';
	 zx_global_structures_pkg.trx_line_dist_tbl.event_type_code(1)	 := 'CREATE';

      ELSIF l_claim_header.payment_method = 'REG_CREDIT_MEMO' THEN
	 zx_global_structures_pkg.trx_line_dist_tbl.event_class_code(1)	 := 'CREDIT_MEMO';
	 zx_global_structures_pkg.trx_line_dist_tbl.event_type_code(1)	 := 'CM_CREATE';

      ELSE
	IF l_claim_header.payment_method =	'CREDIT_MEMO' THEN
	     zx_global_structures_pkg.trx_line_dist_tbl.event_class_code(1)  :=	'CREDIT_MEMO';
	     zx_global_structures_pkg.trx_line_dist_tbl.event_type_code(1)   :=	'CM_CREATE';
	 ELSIF l_claim_header.payment_method = 'DEBIT_MEMO' THEN
	     zx_global_structures_pkg.trx_line_dist_tbl.event_class_code(1)  :=	'DEBIT_MEMO';
	     zx_global_structures_pkg.trx_line_dist_tbl.event_type_code(1)   :=	'DM_CREATE';
	 END IF;

	 zx_global_structures_pkg.trx_line_dist_tbl.source_application_id(1)	       := 682;
	 zx_global_structures_pkg.trx_line_dist_tbl.source_entity_code(1)	       := 'OZF_CLAIMS';
	 zx_global_structures_pkg.trx_line_dist_tbl.source_event_class_code(1)	:= 'TRADE_MGT_RECEIVABLES';

      END IF;

      --  Ship From Information	? Bill From Info not required.
      --   zx_global_structures_pkg.trx_line_dist_tbl.ship_from_party_id(1) :=	??;
      --  zx_global_structures_pkg.trx_line_dist_tbl.ship_from_location_id(1)	 := ??
      --  zx_global_structures_pkg.trx_line_dist_tbl.bill_from_party_id(1) :=  ??;
      --  zx_global_structures_pkg.trx_line_dist_tbl.bill_from_location_id(1)	 := ??


       -- Bill To Information
      zx_global_structures_pkg.trx_line_dist_tbl.bill_to_cust_acct_site_use_id(1) := NVL(l_claim_header.related_site_use_id,  l_claim_header.cust_billto_acct_site_id);
      OPEN    csr_cust_party_details(zx_global_structures_pkg.trx_line_dist_tbl.bill_to_cust_acct_site_use_id(1));
      FETCH  csr_cust_party_details INTO zx_global_structures_pkg.trx_line_dist_tbl.bill_to_party_site_id(1),
								   zx_global_structures_pkg.trx_line_dist_tbl.bill_to_location_id(1);
       CLOSE  csr_cust_party_details ;

	-- Ship	To Information
	IF l_claim_header.cust_shipto_acct_site_id IS NOT NULL THEN
	       zx_global_structures_pkg.trx_line_dist_tbl.ship_to_cust_acct_site_use_id(1) := l_claim_header.cust_shipto_acct_site_id;
	       OPEN    csr_cust_party_details(l_claim_header.cust_shipto_acct_site_id);
	       FETCH  csr_cust_party_details INTO zx_global_structures_pkg.trx_line_dist_tbl.ship_to_party_site_id(1),
									  zx_global_structures_pkg.trx_line_dist_tbl.ship_to_location_id(1);
	       CLOSE  csr_cust_party_details ;
	END IF;

  END IF;

  IF l_claim_header.payment_method  IN ( 'CREDIT_MEMO',	'DEBIT_MEMO') THEN
      OPEN    csr_cm_dm_trx_id(l_claim_header.claim_type_id);
      FETCH  csr_cm_dm_trx_id  INTO l_cm_trx_type_id, l_dm_trx_type_id;
      CLOSE  csr_cm_dm_trx_id;

      IF l_claim_header.payment_method	=  'CREDIT_MEMO' THEN
	    zx_global_structures_pkg.trx_line_dist_tbl.receivables_trx_type_id(1) := l_cm_trx_type_id;
      ELSE
	    zx_global_structures_pkg.trx_line_dist_tbl.receivables_trx_type_id(1) :=  l_dm_trx_type_id;
      END IF;
   END IF;

   OPEN    csr_function_currency;
   FETCH csr_function_currency INTO l_function_currency;
   CLOSE csr_function_currency;

   IF l_claim_header.currency_code <> l_function_currency THEN
      zx_global_structures_pkg.trx_line_dist_tbl.currency_conversion_date(1) :=	l_claim_header.exchange_rate_date;
      zx_global_structures_pkg.trx_line_dist_tbl.currency_conversion_rate(1) :=	l_claim_header.exchange_rate;
      zx_global_structures_pkg.trx_line_dist_tbl.currency_conversion_type(1) :=	l_claim_header.exchange_rate_type;
   END IF;


 zx_global_structures_pkg.trx_line_dist_tbl.input_tax_classification_code(1)   := NULL;
 zx_global_structures_pkg.trx_line_dist_tbl.output_tax_classification_code(1)  := NULL;
 zx_global_structures_pkg.trx_line_dist_tbl.product_id(1)		       := NULL;
 zx_global_structures_pkg.trx_line_dist_tbl.uom_code(1)			       := NULL;
 zx_global_structures_pkg.trx_line_dist_tbl.product_type(1)		       := NULL;
 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_application_id(1)     := NULL;
 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_entity_code(1)	       := NULL;
 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_event_class_code(1)   := NULL;
 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_trx_id(1)	       := NULL;
 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_trx_level_type(1)     := NULL;
 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_line_id(1)	       := NULL;
 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_number(1)	       := NULL;
 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_date(1)	       := NULL;

 zx_global_structures_pkg.trx_line_dist_tbl.trx_line_id(1)     := p_x_claim_line_rec.claim_line_id;

  OPEN	    csr_stlmnt_tax_type(p_x_claim_line_rec.claim_id);
  FETCH	   csr_stlmnt_tax_type	INTO l_tax_type;
  CLOSE	   csr_stlmnt_tax_type;

  -- Switch Signs
  IF  l_tax_type = 'AP'	THEN
    zx_global_structures_pkg.trx_line_dist_tbl.input_tax_classification_code(1)
				      := p_x_claim_line_rec.tax_code;
   IF l_claim_header.payment_method = 'AP_DEBIT'  AND  l_claim_header.claim_class = 'CLAIM' THEN
       zx_global_structures_pkg.trx_line_dist_tbl.line_amt(1)  := p_x_claim_line_rec.amount * -1 ;
   ELSE
       zx_global_structures_pkg.trx_line_dist_tbl.line_amt(1)  := p_x_claim_line_rec.amount ;
   END IF;

 ELSE
   zx_global_structures_pkg.trx_line_dist_tbl.output_tax_classification_code(1)
				       := p_x_claim_line_rec.tax_code;
   zx_global_structures_pkg.trx_line_dist_tbl.line_amt(1)  := p_x_claim_line_rec.amount	* -1 ;

 END IF;


 IF  l_tax_type	= 'AR'	AND  p_x_claim_line_rec.item_id	IS NOT NULL THEN
       IF p_x_claim_line_rec. item_type	= 'PRODUCT' THEN
		 zx_global_structures_pkg.trx_line_dist_tbl.product_id(1)    :=	p_x_claim_line_rec.item_id;
		 zx_global_structures_pkg.trx_line_dist_tbl.uom_code(1)	     :=	p_x_claim_line_rec.quantity_uom;
		 --bug5193067
		 --zx_global_structures_pkg.trx_line_dist_tbl.product_type(1)  :=	'GOOD';
       ELSIF p_x_claim_line_rec. item_type = 'MEMO_LINE' THEN
		 zx_global_structures_pkg.trx_line_dist_tbl.product_id(1)    :=	p_x_claim_line_rec.item_id;
		 zx_global_structures_pkg.trx_line_dist_tbl.uom_code(1)	     :=	p_x_claim_line_rec.quantity_uom;
		 --bug5193067
		 --zx_global_structures_pkg.trx_line_dist_tbl.product_type(1)  :=	'MEMO';
       END IF;
 END IF;

 IF  l_claim_header.payment_method IN ('REG_CREDIT_MEMO','RMA')	AND
      p_x_claim_line_rec.source_object_id IS NOT NULL
 THEN
       IF  p_x_claim_line_rec.source_object_class = 'ORDER' THEN
		 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_application_id(1)     := 660;
		 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_entity_code(1)	       := 'OE_ORDER_HEADERS_ALL';
		 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_event_class_code(1)   := 'SALES_TRANSACTION_TAX_QUOTE';
		 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_trx_id(1)	       := p_x_claim_line_rec.source_object_id;
		 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_line_id(1)	       := p_x_claim_line_rec.source_object_line_id;
		 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_trx_level_type(1) := 'LINE';
     ELSE
		 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_application_id(1)     := 222;
		 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_entity_code(1)	       :=  'TRANSACTIONS';
		 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_event_class_code(1)   := 'INVOICE';
		 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_trx_id(1)	       := p_x_claim_line_rec.source_object_id;
		 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_line_id(1)	       := p_x_claim_line_rec.source_object_line_id;
		 zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_trx_level_type(1) := 'LINE';
     END IF;
END IF;

 -- Step 3: Make Call to Calculate Tax
   IF OZF_DEBUG_HIGH_ON	THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : Calling the tax engine');
   END IF;

 l_transaction_rec.internal_organization_id := zx_global_structures_pkg.trx_line_dist_tbl.internal_organization_id(1);
 l_transaction_rec.application_id	    := zx_global_structures_pkg.trx_line_dist_tbl.application_id(1);
 l_transaction_rec.entity_code		    := zx_global_structures_pkg.trx_line_dist_tbl.entity_code(1);
 l_transaction_rec.event_class_code	    := zx_global_structures_pkg.trx_line_dist_tbl.event_class_code(1);
 l_transaction_rec.event_type_code	    := zx_global_structures_pkg.trx_line_dist_tbl.event_type_code(1);
 l_transaction_rec.trx_id		    := zx_global_structures_pkg.trx_line_dist_tbl.trx_id(1);


 ZX_API_PUB.calculate_tax(  p_api_version    =>	 1.0,
			    p_init_msg_list  =>	 p_init_msg_list,
			    p_commit	     =>	  FND_API.g_false,
			    p_validation_level	=> p_validation_level,
			    x_return_status	=> l_return_status,
			    x_msg_count		=> x_msg_count,
			    x_msg_data		=> x_msg_data,
			    p_transaction_rec	=>  l_transaction_rec,
			    p_quote_flag	=>  'Y',
			    p_data_transfer_mode     =>	 'PLS',
			    x_doc_level_recalc_flag  =>	l_dummy
					   );
   IF l_return_status =	FND_API.g_ret_sts_error	THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

  -- Step 4:  Retrieve Data from eTax
  OPEN	 csr_zx_tax_details(l_claim_header.org_id, l_transaction_rec.application_id,
                            l_transaction_rec.entity_code, l_transaction_rec.event_class_code,
                            p_x_claim_line_rec.claim_id,  p_x_claim_line_rec.claim_line_id);
  FETCH	 csr_zx_tax_details  INTO l_tax_amount,	l_tax_acctd_amount;
  CLOSE	 csr_zx_tax_details;

    IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : Retrieving	Tax Details');
      ozf_utility_pvt.debug_message('tax Amount' || l_tax_amount);
   END IF;


   -- Step 5: Populate into Claim Line Rec
   -- Switch Signs Again
  l_tax_amount := NVL(l_tax_amount,0);
  l_tax_acctd_amount :=	NVL(l_tax_acctd_amount,0);
  IF  l_tax_type = 'AP'	THEN
   IF l_claim_header.payment_method = 'AP_DEBIT'  AND  l_claim_header.claim_class = 'CLAIM' THEN
       l_tax_amount := l_tax_amount  * -1 ;
       l_tax_acctd_amount := l_tax_acctd_amount	 * -1 ;
   ELSE
	NULL;
   END IF;

 ELSE
       l_tax_amount := l_tax_amount  * -1 ;
       l_tax_acctd_amount := l_tax_acctd_amount	 * -1 ;
 END IF;


   p_x_claim_line_rec.claim_curr_tax_amount := l_tax_amount ;
   p_x_claim_line_rec.acctd_tax_amount := l_tax_acctd_amount ;

   IF	p_x_claim_line_rec.tax_action =	'TAX_ADJ_LINE' AND l_tax_amount	<> 0  THEN

      -- Calculate the approx tax rate for inclusive tax calculation
      l_calc_tax_rate :=  ROUND( p_x_claim_line_rec.claim_curr_tax_amount / p_x_claim_line_rec.claim_currency_amount, 2);
      l_calc_incl_tax_amt  :=	(p_x_claim_line_rec.claim_currency_amount * l_calc_tax_rate) / ( 1 + l_calc_tax_rate);

      p_x_claim_line_rec.claim_curr_tax_amount := OZF_UTILITY_PVT.CurrRound(l_calc_incl_tax_amt,  l_claim_header.currency_code);
      p_x_claim_line_rec.claim_currency_amount	:=  p_x_claim_line_rec.claim_currency_amount  -	p_x_claim_line_rec.claim_curr_tax_amount;

      -- Convert ACCTD_AMOUNT
      OZF_UTILITY_PVT.Convert_Currency(
	   P_SET_OF_BOOKS_ID  => l_claim_header.set_of_books_id,
	   P_FROM_CURRENCY    => l_claim_header.currency_code,
	   P_CONVERSION_DATE  => l_claim_header.exchange_rate_date,
	   P_CONVERSION_TYPE  => l_claim_header.exchange_rate_type,
	   P_CONVERSION_RATE  => l_claim_header.exchange_rate,
	   P_AMOUNT	      => p_x_claim_line_rec.claim_currency_amount,
	   X_RETURN_STATUS    => l_return_status,
	   X_ACC_AMOUNT	      => p_x_claim_line_rec.acctd_amount,
	   X_RATE	      => l_return_exc_rate
	    );
	IF l_return_status = FND_API.g_ret_sts_error THEN
	      RAISE FND_API.g_exc_error;
	ELSIF l_return_status =	FND_API.g_ret_sts_unexp_error THEN
	      RAISE FND_API.g_exc_unexpected_error;
	END IF;

      OZF_UTILITY_PVT.Convert_Currency(
	   P_SET_OF_BOOKS_ID  => l_claim_header.set_of_books_id,
	   P_FROM_CURRENCY    => l_claim_header.currency_code,
	   P_CONVERSION_DATE  => l_claim_header.exchange_rate_date,
	   P_CONVERSION_TYPE  => l_claim_header.exchange_rate_type,
	   P_CONVERSION_RATE  => l_claim_header.exchange_rate,
	   P_AMOUNT	      =>  p_x_claim_line_rec.claim_curr_tax_amount,
	   X_RETURN_STATUS    => l_return_status,
	   X_ACC_AMOUNT	      => p_x_claim_line_rec.acctd_tax_amount,
	   X_RATE	      => l_return_exc_rate
	    );
	IF l_return_status = FND_API.g_ret_sts_error THEN
	      RAISE FND_API.g_exc_error;
	ELSIF l_return_status =	FND_API.g_ret_sts_unexp_error THEN
	      RAISE FND_API.g_exc_unexpected_error;
	END IF;

   END IF;


   IF l_claim_header.currency_code = p_x_claim_line_rec.currency_code
   THEN

      p_x_claim_line_rec.tax_amount := p_x_claim_line_rec.claim_curr_tax_amount;

     IF	p_x_claim_line_rec.tax_action =	'TAX_ADJ_LINE'	THEN
       p_x_claim_line_rec.amount := p_x_claim_line_rec.claim_currency_amount;
     END IF;

   ELSE

      -- Convert Acctd Tax Amount into Line Currency Tax Amount
      OZF_UTILITY_PVT.Convert_Currency(
	 p_from_currency  => l_function_currency
	,p_to_currency	  => p_x_claim_line_rec.currency_code
	,p_conv_type	  => p_x_claim_line_rec.exchange_rate_type
	,p_conv_rate	  => p_x_claim_line_rec.exchange_rate
	,p_conv_date	  => p_x_claim_line_rec.exchange_rate_date
	,p_from_amount	  => p_x_claim_line_rec.acctd_tax_amount
	,x_return_status  => l_return_status
	,x_to_amount	  => p_x_claim_line_rec.tax_amount
	,x_rate		  => l_return_exc_rate
	);
      IF l_return_status = FND_API.g_ret_sts_error THEN
	  RAISE	FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
	  RAISE	FND_API.g_exc_unexpected_error;
      END IF;

     --	Convert	Acctd Amount into Line Currency	Amount
     IF	p_x_claim_line_rec.tax_action =	'TAX_ADJ_LINE'	 THEN
	      OZF_UTILITY_PVT.Convert_Currency(
		 p_from_currency   => l_function_currency
		,p_to_currency	   => p_x_claim_line_rec.currency_code
		,p_conv_type	   => p_x_claim_line_rec.exchange_rate_type
		,p_conv_rate	   => p_x_claim_line_rec.exchange_rate
		,p_conv_date	   => p_x_claim_line_rec.exchange_rate_date
		,p_from_amount	   => p_x_claim_line_rec.acctd_amount
		,x_return_status   => l_return_status
		,x_to_amount	   => p_x_claim_line_rec.amount
		,x_rate		   => l_return_exc_rate
		);
	      IF l_return_status = FND_API.g_ret_sts_error THEN
		  RAISE	FND_API.g_exc_error;
	      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
		  RAISE	FND_API.g_exc_unexpected_error;
	      END IF;
      END IF;

   END IF;

  -- Step 6:  Validate (Stage 2)
  IF p_x_claim_line_rec.tax_action = 'TAX_ADJ_LINE' AND	l_tax_amount <>	0 THEN
	IF p_x_claim_line_rec.earnings_associated_flag = 'T'  OR
	    (  p_x_claim_line_rec.quantity IS NOT NULL AND  p_x_claim_line_rec.rate IS NOT NULL)
       THEN
	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
	      FND_MESSAGE.set_name('OZF', 'OZF_ADJLINE_ERR');
	      FND_MESSAGE.set_token('LINE_AMOUNT' , p_x_claim_line_rec.claim_currency_amount );
	      FND_MSG_PUB.add;
	   END IF;
	   RAISE FND_API.g_exc_error;
	END IF;
   END IF;

   ------------------------ finish ------------------------

   IF OZF_DEBUG_HIGH_ON	THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;

EXCEPTION
   WHEN	FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.count_and_get(
	 p_encoded => FND_API.g_false,
	 p_count   => x_msg_count,
	 p_data	   => x_msg_data
   );
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.count_and_get(
	 p_encoded => FND_API.g_false,
	 p_count   => x_msg_count,
	 p_data	   => x_msg_data
   );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN	OTHERS THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	 FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
     END IF;
      FND_MSG_PUB.count_and_get(
	 p_encoded => FND_API.g_false,
	 p_count   => x_msg_count,
	 p_data	   => x_msg_data
   );
     x_return_status :=	FND_API.g_ret_sts_unexp_error;


END Calculate_Claim_Line_Tax;


END OZF_CLAIM_TAX_PVT;

/
