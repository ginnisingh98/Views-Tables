--------------------------------------------------------
--  DDL for Package Body ZX_PRD_OPTIONS_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_PRD_OPTIONS_MIGRATE_PKG" AS
/* $Header: zxprdoptmigpkgb.pls 120.19.12010000.1 2008/07/28 13:35:36 appldev ship $ */

G_PKG_NAME              CONSTANT VARCHAR2(50) := 'ZX_PRD_OPTIONS_MIGRATE_PKG';
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(250):= 'ZX.PLSQL.ZX_PRD_OPTIONS_MIGRATE_PKG.';

L_MULTI_ORG_FLAG       FND_PRODUCT_GROUPS.MULTI_ORG_FLAG%TYPE;
L_ORG_ID	       NUMBER(15);

TYPE NUMBER_tbl_type            IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE DATE_tbl_type              IS TABLE OF DATE           INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_1_tbl_type        IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_2_tbl_type        IS TABLE OF VARCHAR2(2)    INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_15_tbl_type       IS TABLE OF VARCHAR2(15)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_20_tbl_type       IS TABLE OF VARCHAR2(20)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_30_tbl_type       IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_50_tbl_type       IS TABLE OF VARCHAR2(50)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_80_tbl_type       IS TABLE OF VARCHAR2(80)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_150_tbl_type      IS TABLE OF VARCHAR2(150)  INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_240_tbl_type      IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_250_tbl_type      IS TABLE OF VARCHAR2(250)  INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_2000_tbl_type     IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

TYPE system_options_rec IS RECORD
(
  org_id                        NUMBER_tbl_type,
  tax_hier_site_exc_rate        NUMBER_tbl_type,
  tax_hier_cust_exc_rate        NUMBER_tbl_type,
  tax_hier_prod_exc_rate        NUMBER_tbl_type,
  tax_hier_account_exc_rate     NUMBER_tbl_type,
  tax_hier_system_exc_rate      NUMBER_tbl_type,
  tax_hier_po_shipment          NUMBER_tbl_type,
  tax_hier_vendor_site          NUMBER_tbl_type,
  tax_hier_vendor               NUMBER_tbl_type,
  tax_hier_account              NUMBER_tbl_type,
  tax_hier_system               NUMBER_tbl_type,
  tax_hier_invoice              NUMBER_tbl_type,
  tax_hier_template             NUMBER_tbl_type,
  tax_hier_ship_to_loc          NUMBER_tbl_type,
  tax_hier_item                 NUMBER_tbl_type,
  output_tax_hier_site          NUMBER_tbl_type,
  output_tax_hier_cust          NUMBER_tbl_type,
  output_tax_hier_project       NUMBER_tbl_type,
  output_tax_hier_exp_ev        NUMBER_tbl_type,
  output_tax_hier_extn          NUMBER_tbl_type,
  output_tax_hier_ar_param      NUMBER_tbl_type,
  max_value                     NUMBER_tbl_type,
  min_value                     NUMBER_tbl_type,
  default_hierarchy1            VARCHAR2_30_tbl_type,
  default_hierarchy2            VARCHAR2_30_tbl_type,
  default_hierarchy3            VARCHAR2_30_tbl_type,
  default_hierarchy4            VARCHAR2_30_tbl_type,
  default_hierarchy5            VARCHAR2_30_tbl_type,
  default_hierarchy6            VARCHAR2_30_tbl_type,
  default_hierarchy7            VARCHAR2_30_tbl_type,
  tax_code                      VARCHAR2_30_tbl_type,
  tax_method_code               VARCHAR2_30_tbl_type,
  --inclusive_tax_used_flag       VARCHAR2_1_tbl_type,
  tax_use_customer_exempt_flag  VARCHAR2_1_tbl_type,
  tax_use_loc_exc_rate_flag     VARCHAR2_1_tbl_type,
  --tax_allow_compound_flag       VARCHAR2_1_tbl_type,
  tax_use_product_exempt_flag   VARCHAR2_1_tbl_type,
  tax_rounding_rule             VARCHAR2_30_tbl_type,
  tax_precision  		NUMBER_tbl_type,
  tax_minimum_accountable_unit  NUMBER_tbl_type,
  use_tax_classification_flag   VARCHAR2_1_tbl_type,
  home_country_default_flag     VARCHAR2_1_tbl_type,
  sales_tax_geocode             VARCHAR2_30_tbl_type
  );

FUNCTION get_location_tax (
  p_org_id           IN NUMBER,
  p_set_of_books_id  IN NUMBER
) RETURN VARCHAR2
IS
 l_tax_code      VARCHAR2(30);

 BEGIN

   SELECT vat.tax_code
     INTO l_tax_code
    FROM AR_VAT_TAX_ALL vat
    WHERE vat.tax_type = 'LOCATION'
      AND vat.set_of_books_id = p_set_of_books_id
      AND sysdate between vat.start_date and nvl(vat.end_date, sysdate)
      AND nvl(vat.enabled_flag, 'Y') = 'Y'
      AND nvl(vat.tax_class, 'O') = 'O'
      AND decode(l_multi_org_flag,'N',l_org_id,vat.org_id) = p_org_id;

   RETURN l_tax_code;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN null;
 END get_location_tax;


PROCEDURE AP_PRD_OPTIONS_MIGRATE (x_return_status OUT NOCOPY VARCHAR2) IS
  ap_system_options    system_options_rec;
  l_api_name           VARCHAR2(30) := 'AP_TAX_OPTIONS_MIGRATE';

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT decode(l_multi_org_flag,'N',l_org_id, sys.org_id),                   --org_id
           tax_hier_po_shipment,
           tax_hier_vendor_site,
           tax_hier_vendor,
           tax_hier_account,
           tax_hier_system,
           tax_hier_invoice,
           tax_hier_template,
	   greatest(nvl(tax_hier_po_shipment,-1),nvl(tax_hier_vendor_site,-1),
	            nvl(tax_hier_vendor,-1),nvl(tax_hier_account,-1),
	   	    nvl(tax_hier_system,-1),nvl(tax_hier_invoice,-1),
		    nvl(tax_hier_template,-1)),
	   least(nvl(tax_hier_po_shipment,999),nvl(tax_hier_vendor_site,999),
		 nvl(tax_hier_vendor,999),nvl(tax_hier_account,999),
		 nvl(tax_hier_system,999),nvl(tax_hier_invoice,999),
		 nvl(tax_hier_template,999)),
           null,                                                                --default_hierarchy1
           null,                                                                --default_hierarchy2
           null,                                                                --default_hierarchy3
           null,                                                                --default_hierarchy4
           null,                                                                --default_hierarchy5
           null,                                                                --default_hierarchy6
           null,                                                                --default_hierarchy7
           fin.VAT_CODE,                                                        --tax_classification_code
           null,                                                                --tax_method_code
         --null,                                                                --inclusive_tax_used_flag
           null,                                                                --tax_use_customer_exempt_flag,
           null,                                                                --tax_use_product_exempt_flag
           null,                                                                --tax_use_loc_exc_rate_flag
         --null,                                                                --tax_allow_compound_flag
           null,                                                                --tax_rounding_rule
           null,                                                                --tax_precision
           null,                                                                --tax_minimum_accountable_unit
           decode (sys.tax_hier_template||sys.tax_hier_vendor_site||
                   sys.tax_hier_vendor||sys.tax_hier_account||
		   sys.tax_hier_system||sys.tax_hier_invoice,null, 'N','Y'),    --use_tax_classification_flag
	   null                                                                 --home_country_default_flag
     BULK COLLECT INTO
           ap_system_options.org_id,
   	   ap_system_options.tax_hier_po_shipment,
           ap_system_options.tax_hier_vendor_site,
           ap_system_options.tax_hier_vendor,
           ap_system_options.tax_hier_account,
           ap_system_options.tax_hier_system,
           ap_system_options.tax_hier_invoice,
           ap_system_options.tax_hier_template,
	   ap_system_options.max_value,
	   ap_system_options.min_value ,
           ap_system_options.default_hierarchy1,
           ap_system_options.default_hierarchy2,
           ap_system_options.default_hierarchy3,
           ap_system_options.default_hierarchy4,
           ap_system_options.default_hierarchy5,
           ap_system_options.default_hierarchy6,
           ap_system_options.default_hierarchy7,
           ap_system_options.tax_code,
           ap_system_options.tax_method_code,
           --ap_system_options.inclusive_tax_used_flag,
           ap_system_options.tax_use_customer_exempt_flag,
           ap_system_options.tax_use_product_exempt_flag,
           ap_system_options.tax_use_loc_exc_rate_flag,
           --ap_system_options.tax_allow_compound_flag,
           ap_system_options.tax_rounding_rule,
           ap_system_options.tax_precision,
           ap_system_options.tax_minimum_accountable_unit,
           ap_system_options.use_tax_classification_flag,
           ap_system_options.home_country_default_flag
      FROM AP_SYSTEM_PARAMETERS_ALL sys,
           FINANCIALS_SYSTEM_PARAMS_ALL fin
     WHERE decode(l_multi_org_flag,'N',l_org_id,fin.org_id(+)) = decode(l_multi_org_flag,'N',l_org_id,sys.org_id)
       AND NOT EXISTS (SELECT 1
                         FROM ZX_PRODUCT_OPTIONS_ALL prd
      	                WHERE prd.ORG_ID = decode(l_multi_org_flag,'N',l_org_id,sys.org_id)
                          AND prd.APPLICATION_ID = 200
                       );

     FOR i in 1..nvl(ap_system_options.org_id.LAST,0)  LOOP
       FOR j in ap_system_options.min_value(i)..ap_system_options.max_value(i) LOOP
         IF ap_system_options.DEFAULT_HIERARCHY1(i) is null THEN
           IF ap_system_options.tax_hier_po_shipment(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY1(i) := 'REFERENCE_DOCUMENT';
           ELSIF ap_system_options.tax_hier_vendor_site(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY1(i) := 'SHIP_FROM_PARTY_SITE';
           ELSIF ap_system_options.tax_hier_vendor(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY1(i) := 'SHIP_FROM_PARTY';
           ELSIF ap_system_options.tax_hier_account(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY1(i) := 'NATURAL_ACCOUNT';
           ELSIF ap_system_options.tax_hier_system(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY1(i) := 'FINANCIAL_OPTIONS';
           ELSIF ap_system_options.tax_hier_invoice(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY1(i) := 'INVOICE_HEADER';
           ELSIF ap_system_options.tax_hier_template(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY1(i) := 'TEMPLATE';
           END IF;
         ELSIF ap_system_options.DEFAULT_HIERARCHY2(i) is null THEN
           IF ap_system_options.tax_hier_po_shipment(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY2(i) := 'REFERENCE_DOCUMENT';
           ELSIF ap_system_options.tax_hier_vendor_site(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY2(i) := 'SHIP_FROM_PARTY_SITE';
           ELSIF ap_system_options.tax_hier_vendor(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY2(i) := 'SHIP_FROM_PARTY';
           ELSIF ap_system_options.tax_hier_account(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY2(i) := 'NATURAL_ACCOUNT';
           ELSIF ap_system_options.tax_hier_system(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY2(i) := 'FINANCIAL_OPTIONS';
           ELSIF ap_system_options.tax_hier_invoice(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY2(i) := 'INVOICE_HEADER';
           ELSIF ap_system_options.tax_hier_template(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY2(i) := 'TEMPLATE';
           END IF;
         ELSIF ap_system_options.DEFAULT_HIERARCHY3(i) is null THEN
           IF ap_system_options.tax_hier_po_shipment(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY3(i) := 'REFERENCE_DOCUMENT';
           ELSIF ap_system_options.tax_hier_vendor_site(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY3(i) := 'SHIP_FROM_PARTY_SITE';
           ELSIF ap_system_options.tax_hier_vendor(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY3(i) := 'SHIP_FROM_PARTY';
           ELSIF ap_system_options.tax_hier_account(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY3(i) := 'NATURAL_ACCOUNT';
           ELSIF ap_system_options.tax_hier_system(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY3(i) := 'FINANCIAL_OPTIONS';
           ELSIF ap_system_options.tax_hier_invoice(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY3(i) := 'INVOICE_HEADER';
           ELSIF ap_system_options.tax_hier_template(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY3(i) := 'TEMPLATE';
           END IF;
         ELSIF  ap_system_options.DEFAULT_HIERARCHY4(i) is null THEN
           IF ap_system_options.tax_hier_po_shipment(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY4(i) := 'REFERENCE_DOCUMENT';
           ELSIF ap_system_options.tax_hier_vendor_site(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY4(i) := 'SHIP_FROM_PARTY_SITE';
           ELSIF ap_system_options.tax_hier_vendor(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY4(i) := 'SHIP_FROM_PARTY';
           ELSIF ap_system_options.tax_hier_account(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY4(i) := 'NATURAL_ACCOUNT';
           ELSIF ap_system_options.tax_hier_system(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY4(i) := 'FINANCIAL_OPTIONS';
           ELSIF ap_system_options.tax_hier_invoice(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY4(i) := 'INVOICE_HEADER';
           ELSIF ap_system_options.tax_hier_template(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY4(i) := 'TEMPLATE';
           END IF;
         ELSIF  ap_system_options.DEFAULT_HIERARCHY5(i) is null THEN
           IF ap_system_options.tax_hier_po_shipment(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY5(i) := 'REFERENCE_DOCUMENT';
           ELSIF ap_system_options.tax_hier_vendor_site(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY5(i) := 'SHIP_FROM_PARTY_SITE';
           ELSIF ap_system_options.tax_hier_vendor(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY5(i) := 'SHIP_FROM_PARTY';
           ELSIF ap_system_options.tax_hier_account(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY5(i) := 'NATURAL_ACCOUNT';
           ELSIF ap_system_options.tax_hier_system(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY5(i) := 'FINANCIAL_OPTIONS';
           ELSIF ap_system_options.tax_hier_invoice(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY5(i) := 'INVOICE_HEADER';
           ELSIF ap_system_options.tax_hier_template(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY5(i) := 'TEMPLATE';
           END IF;
         ELSIF  ap_system_options.DEFAULT_HIERARCHY6(i) is null THEN
           IF ap_system_options.tax_hier_po_shipment(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY6(i) := 'REFERENCE_DOCUMENT';
           ELSIF ap_system_options.tax_hier_vendor_site(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY6(i) := 'SHIP_FROM_PARTY_SITE';
           ELSIF ap_system_options.tax_hier_vendor(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY6(i) := 'SHIP_FROM_PARTY';
           ELSIF ap_system_options.tax_hier_account(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY6(i) := 'NATURAL_ACCOUNT';
           ELSIF ap_system_options.tax_hier_system(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY6(i) := 'FINANCIAL_OPTIONS';
           ELSIF ap_system_options.tax_hier_invoice(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY6(i) := 'INVOICE_HEADER';
           ELSIF ap_system_options.tax_hier_template(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY6(i) := 'TEMPLATE';
           END IF;
         ELSIF  ap_system_options.DEFAULT_HIERARCHY7(i) is null THEN
           IF ap_system_options.tax_hier_po_shipment(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY7(i) := 'REFERENCE_DOCUMENT';
           ELSIF ap_system_options.tax_hier_vendor_site(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY7(i) := 'SHIP_FROM_PARTY_SITE';
           ELSIF ap_system_options.tax_hier_vendor(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY7(i) := 'SHIP_FROM_PARTY';
           ELSIF ap_system_options.tax_hier_account(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY7(i) := 'NATURAL_ACCOUNT';
           ELSIF ap_system_options.tax_hier_system(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY7(i) := 'FINANCIAL_OPTIONS';
           ELSIF ap_system_options.tax_hier_invoice(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY7(i) := 'INVOICE_HEADER';
           ELSIF ap_system_options.tax_hier_template(i) = j THEN
              ap_system_options.DEFAULT_HIERARCHY7(i) := 'TEMPLATE';
           END IF;
         END IF;
       END LOOP;
     END LOOP;

     FORALL i in 1..nvl(ap_system_options.org_id.LAST,0)
     INSERT INTO ZX_PRODUCT_OPTIONS_ALL (
                PRODUCT_OPTIONS_ID,
                ORG_ID,
                APPLICATION_ID,
                DEF_OPTION_HIER_1_CODE,
                DEF_OPTION_HIER_2_CODE,
                DEF_OPTION_HIER_3_CODE,
                DEF_OPTION_HIER_4_CODE,
                DEF_OPTION_HIER_5_CODE,
                DEF_OPTION_HIER_6_CODE,
                DEF_OPTION_HIER_7_CODE,
                TAX_CLASSIFICATION_CODE,
                TAX_METHOD_CODE,
		--INCLUSIVE_TAX_USED_FLAG,
                TAX_USE_CUSTOMER_EXEMPT_FLAG,
                TAX_USE_PRODUCT_EXEMPT_FLAG,
                TAX_USE_LOC_EXC_RATE_FLAG,
		--TAX_ALLOW_COMPOUND_FLAG,
                TAX_ROUNDING_RULE,
                TAX_PRECISION,
                TAX_MINIMUM_ACCOUNTABLE_UNIT,
                USE_TAX_CLASSIFICATION_FLAG,
                HOME_COUNTRY_DEFAULT_FLAG,
                OBJECT_VERSION_NUMBER,
                RECORD_TYPE_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
       	values (ZX_PRODUCT_OPTIONS_ALL_S.nextval,
               ap_system_options.ORG_ID(i),
	       200,                                                             --application_id
               ap_system_options.DEFAULT_HIERARCHY1(i),
               ap_system_options.DEFAULT_HIERARCHY2(i),
               ap_system_options.DEFAULT_HIERARCHY3(i),
               ap_system_options.DEFAULT_HIERARCHY4(i),
               ap_system_options.DEFAULT_HIERARCHY5(i),
               ap_system_options.DEFAULT_HIERARCHY6(i),
               ap_system_options.DEFAULT_HIERARCHY7(i),
               ap_system_options.TAX_CODE(i),
               ap_system_options.TAX_METHOD_CODE(i),
               --ap_system_options.INCLUSIVE_TAX_USED_FLAG(i),
               ap_system_options.TAX_USE_CUSTOMER_EXEMPT_FLAG(i),               --tax_use_customer_exempt_flag
               ap_system_options.TAX_USE_PRODUCT_EXEMPT_FLAG(i),                --tax_use_product_exempt_flag
               ap_system_options.TAX_USE_LOC_EXC_RATE_FLAG(i),                  --tax_use_loc_exc_rate_flag
               --ap_system_options.TAX_ALLOW_COMPOUND_FLAG(i),                    --tax_allow_compound_flag
               ap_system_options.TAX_ROUNDING_RULE(i),                          --tax_rounding_rule
               ap_system_options.TAX_PRECISION(i),                              --tax_precision
               ap_system_options.TAX_MINIMUM_ACCOUNTABLE_UNIT(i),               --tax_minimum_accountable_unit
               ap_system_options.USE_TAX_CLASSIFICATION_FLAG(i),
               ap_system_options.HOME_COUNTRY_DEFAULT_FLAG(i),
               1,                                                               --object_version_number
               'MIGRATED',                                                      --record_type_code
               sysdate,                                                         --creation_date
               fnd_global.user_Id,                                              --created_by
               sysdate,                                                         --last_updated_by
               fnd_global.user_id,                                              --last_updated_by
               fnd_global.conc_login_id                                         --last_update_login
               );


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT',' AP Tax Options Migration : '||SQLERRM);
     FND_MSG_PUB.Add;
     IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
     END IF;
END AP_PRD_OPTIONS_MIGRATE;


/* For AR/PA System Options: when 'System Options' is enabled and there is no Tax
   Code available in AR/PA System Parameters, consider Tax of 'LOCATION'
   tax type from AR_VAT_TAX for migrating as Tax Classification Code. This needs
   to be considered only if the Tax Method is 'SALES_TAX'. */
PROCEDURE AR_PRD_OPTIONS_MIGRATE (x_return_status OUT NOCOPY VARCHAR2) IS
  ar_system_options    system_options_rec;
  l_api_name           VARCHAR2(30) := 'AR_TAX_OPTIONS_MIGRATE';

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT decode(l_multi_org_flag,'N',l_org_id, sys.org_id),                  --org_id
	   tax_hier_site_exc_rate,
           tax_hier_cust_exc_rate,
           tax_hier_prod_exc_rate,
           tax_hier_account_exc_rate,
           tax_hier_system_exc_rate,
	   greatest(nvl(tax_hier_site_exc_rate,-1),nvl(tax_hier_cust_exc_rate,-1),
	            nvl(tax_hier_prod_exc_rate,-1),nvl(tax_hier_account_exc_rate,-1),
	            nvl(tax_hier_system_exc_rate,-1)),
	   least(nvl(tax_hier_site_exc_rate,999),nvl(tax_hier_cust_exc_rate,999),
		 nvl(tax_hier_prod_exc_rate,999),nvl(tax_hier_account_exc_rate,999),
		 nvl(tax_hier_system_exc_rate,999)),
           null,                                                               --default_hierarchy1
           null,                                                               --default_hierarchy2
           null,                                                               --default_hierarchy3
           null,                                                               --default_hierarchy4
           null,                                                               --default_hieararchy5
           null,                                                               --default_hierarchy6
           null,                                                               --default_hierarchy7
           decode(sys.tax_use_system_exc_rate_flag,'Y',                        --tax_classification
             decode(sys.TAX_CODE, null, decode(sys.TAX_METHOD,'SALES_TAX',
	                                                       get_location_tax(decode(l_multi_org_flag,'N',l_org_id,sys.org_id),
                                                               sys.set_of_books_id),null),sys.tax_code),null),
           decode(sys.TAX_METHOD,'LATIN', 'LTE', 'EBTAX'),                      --tax_method_code
--           decode(sys.TAX_METHOD,'LATIN',sys.INCLUSIVE_TAX_USED,null),          --inclusive_tax_used_flag
           decode(sys.TAX_METHOD,'LATIN',null,sys.TAX_USE_CUSTOMER_EXEMPT_FLAG),--tax_use_customer_exempt_flag
           decode(sys.TAX_METHOD,'LATIN',null,sys.TAX_USE_PRODUCT_EXEMPT_FLAG), --tax_use_product_exempt_flag
           decode(sys.TAX_METHOD,'LATIN',null,sys.TAX_USE_LOC_EXC_RATE_FLAG),   --tax_use_loc_exc_rate_flag
--           decode(sys.TAX_METHOD,'LATIN',sys.TAX_ALLOW_COMPOUND_FLAG,null),     --tax_allow_compound_flag
           decode(sys.TAX_METHOD,'LATIN',                                       --tax_rounding_rule
	     decode(sys.TAX_ROUNDING_RULE, null, fin.TAX_ROUNDING_RULE,sys.TAX_ROUNDING_RULE),null),
	   decode(sys.TAX_METHOD,'LATIN',                                       --tax_precision
	     decode(sys.TAX_PRECISION, null, fin.PRECISION,sys.TAX_PRECISION),null),
	   decode(sys.TAX_METHOD,'LATIN',                                       --tax_minimum_accountable_unit
	     decode(sys.TAX_MINIMUM_ACCOUNTABLE_UNIT,null,fin.MINIMUM_ACCOUNTABLE_UNIT,sys.TAX_MINIMUM_ACCOUNTABLE_UNIT),null),
           decode (sys.tax_use_site_exc_rate_flag||sys.tax_use_cust_exc_rate_flag|| --use_tax_classification_flag
		   sys.tax_use_prod_exc_rate_flag||sys.tax_use_account_exc_rate_flag||
		   sys.tax_use_system_exc_rate_flag, null, 'N', 'Y'),
           decode(sys.TAX_CODE, null,
	     decode(sys.TAX_METHOD,'SALES_TAX', 'Y', 'N'),'N'),--home_country_default_flag
           sys.SALES_TAX_GEOCODE
     BULK COLLECT INTO
           ar_system_options.org_id,
   	   ar_system_options.tax_hier_site_exc_rate,
           ar_system_options.tax_hier_cust_exc_rate,
           ar_system_options.tax_hier_prod_exc_rate,
           ar_system_options.tax_hier_account_exc_rate,
           ar_system_options.tax_hier_system_exc_rate,
	   ar_system_options.max_value,
	   ar_system_options.min_value ,
           ar_system_options.default_hierarchy1,
           ar_system_options.default_hierarchy2,
           ar_system_options.default_hierarchy3,
           ar_system_options.default_hierarchy4,
           ar_system_options.default_hierarchy5,
           ar_system_options.default_hierarchy6,
           ar_system_options.default_hierarchy7,
           ar_system_options.tax_code,
           ar_system_options.tax_method_code,
           --ar_system_options.inclusive_tax_used_flag,
           ar_system_options.tax_use_customer_exempt_flag,
           ar_system_options.tax_use_product_exempt_flag,
           ar_system_options.tax_use_loc_exc_rate_flag,
           --ar_system_options.tax_allow_compound_flag,
           ar_system_options.tax_rounding_rule,
           ar_system_options.tax_precision,
           ar_system_options.tax_minimum_accountable_unit,
           ar_system_options.use_tax_classification_flag,
           ar_system_options.home_country_default_flag,
           ar_system_options.sales_tax_geocode
      FROM AR_SYSTEM_PARAMETERS_ALL sys,
           FINANCIALS_SYSTEM_PARAMS_ALL fin
     WHERE decode(l_multi_org_flag,'N',l_org_id,fin.org_id(+)) = decode(l_multi_org_flag,'N',l_org_id,sys.org_id)
       AND NOT EXISTS (SELECT 1
                         FROM ZX_PRODUCT_OPTIONS_ALL prd
    	                WHERE prd.ORG_ID = decode(l_multi_org_flag,'N',l_org_id,sys.org_id)
                          AND prd.APPLICATION_ID   = 222
                       );

     FOR i in 1..nvl(ar_system_options.org_id.LAST,0)  LOOP
       FOR j in ar_system_options.min_value(i)..ar_system_options.max_value(i) LOOP
         IF ar_system_options.DEFAULT_HIERARCHY1(i) is null THEN
           IF ar_system_options.tax_hier_site_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY1(i) := 'SHIP_TO_PARTY_SITE';
           ELSIF ar_system_options.tax_hier_cust_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY1(i) := 'SHIP_TO_PARTY';
           ELSIF ar_system_options.tax_hier_prod_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY1(i) := 'PRODUCT';
           ELSIF ar_system_options.tax_hier_account_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY1(i) := 'REVENUE_ACCOUNT';
           ELSIF ar_system_options.tax_hier_system_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY1(i) := 'SYSTEM_OPTIONS';
           END IF;
         ELSIF  ar_system_options.DEFAULT_HIERARCHY2(i) is null THEN
           IF ar_system_options.tax_hier_site_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY2(i) := 'SHIP_TO_PARTY_SITE';
           ELSIF ar_system_options.tax_hier_cust_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY2(i) := 'SHIP_TO_PARTY';
           ELSIF ar_system_options.tax_hier_prod_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY2(i) := 'PRODUCT';
           ELSIF ar_system_options.tax_hier_account_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY2(i) := 'REVENUE_ACCOUNT';
           ELSIF ar_system_options.tax_hier_system_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY2(i) := 'SYSTEM_OPTIONS';
           END IF;
         ELSIF  ar_system_options.DEFAULT_HIERARCHY3(i) is null THEN
           IF ar_system_options.tax_hier_site_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY3(i) := 'SHIP_TO_PARTY_SITE';
           ELSIF ar_system_options.tax_hier_cust_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY3(i) := 'SHIP_TO_PARTY';
           ELSIF ar_system_options.tax_hier_prod_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY3(i) := 'PRODUCT';
           ELSIF ar_system_options.tax_hier_account_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY3(i) := 'REVENUE_ACCOUNT';
           ELSIF ar_system_options.tax_hier_system_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY3(i) := 'SYSTEM_OPTIONS';
           END IF;
         ELSIF  ar_system_options.DEFAULT_HIERARCHY4(i) is null THEN
           IF ar_system_options.tax_hier_site_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY4(i) := 'SHIP_TO_PARTY_SITE';
           ELSIF ar_system_options.tax_hier_cust_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY4(i) := 'SHIP_TO_PARTY';
           ELSIF ar_system_options.tax_hier_prod_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY4(i) := 'PRODUCT';
           ELSIF ar_system_options.tax_hier_account_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY4(i) := 'REVENUE_ACCOUNT';
           ELSIF ar_system_options.tax_hier_system_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY4(i) := 'SYSTEM_OPTIONS';
           END IF;
         ELSIF  ar_system_options.DEFAULT_HIERARCHY5(i) is null THEN
           IF ar_system_options.tax_hier_site_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY5(i) := 'SHIP_TO_PARTY_SITE';
           ELSIF ar_system_options.tax_hier_cust_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY5(i) := 'SHIP_TO_PARTY';
           ELSIF ar_system_options.tax_hier_prod_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY5(i) := 'PRODUCT';
           ELSIF ar_system_options.tax_hier_account_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY5(i) := 'REVENUE_ACCOUNT';
           ELSIF ar_system_options.tax_hier_system_exc_rate(i) = j THEN
              ar_system_options.DEFAULT_HIERARCHY5(i) := 'SYSTEM_OPTIONS';
           END IF;
         END IF;
       END LOOP;
     END LOOP;

     FORALL i in 1..nvl(ar_system_options.org_id.LAST,0)
     INSERT INTO ZX_PRODUCT_OPTIONS_ALL (
                PRODUCT_OPTIONS_ID,
        	ORG_ID,
                APPLICATION_ID,
                DEF_OPTION_HIER_1_CODE,
                DEF_OPTION_HIER_2_CODE,
                DEF_OPTION_HIER_3_CODE,
                DEF_OPTION_HIER_4_CODE,
                DEF_OPTION_HIER_5_CODE,
                DEF_OPTION_HIER_6_CODE,
                DEF_OPTION_HIER_7_CODE,
                TAX_CLASSIFICATION_CODE,
                TAX_METHOD_CODE,
                --INCLUSIVE_TAX_USED_FLAG,
                TAX_USE_CUSTOMER_EXEMPT_FLAG,
                TAX_USE_PRODUCT_EXEMPT_FLAG,
                TAX_USE_LOC_EXC_RATE_FLAG,
                --TAX_ALLOW_COMPOUND_FLAG,
                TAX_ROUNDING_RULE,
                TAX_PRECISION,
                TAX_MINIMUM_ACCOUNTABLE_UNIT,
                USE_TAX_CLASSIFICATION_FLAG,
                HOME_COUNTRY_DEFAULT_FLAG,
                SALES_TAX_GEOCODE,
                OBJECT_VERSION_NUMBER,
                RECORD_TYPE_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
       	values (ZX_PRODUCT_OPTIONS_ALL_S.nextval,
               ar_system_options.ORG_ID(i),
	       222,                                                             --application_id
               ar_system_options.DEFAULT_HIERARCHY1(i),
               ar_system_options.DEFAULT_HIERARCHY2(i),
               ar_system_options.DEFAULT_HIERARCHY3(i),
               ar_system_options.DEFAULT_HIERARCHY4(i),
               ar_system_options.DEFAULT_HIERARCHY5(i),
    	       ar_system_options.DEFAULT_HIERARCHY6(i),
    	       ar_system_options.DEFAULT_HIERARCHY7(i),
               ar_system_options.TAX_CODE(i),
               ar_system_options.TAX_METHOD_CODE(i),
               --ar_system_options.INCLUSIVE_TAX_USED_FLAG(i),
               ar_system_options.TAX_USE_CUSTOMER_EXEMPT_FLAG(i),               --tax_use_customer_exempt_flag
               ar_system_options.TAX_USE_PRODUCT_EXEMPT_FLAG(i),                --tax_use_product_exempt_flag
               ar_system_options.TAX_USE_LOC_EXC_RATE_FLAG(i),                  --tax_use_loc_exc_rate_flag
               --ar_system_options.TAX_ALLOW_COMPOUND_FLAG(i),                    --tax_allow_compound_flag
               ar_system_options.TAX_ROUNDING_RULE(i),                          --tax_rounding_rule
               ar_system_options.TAX_PRECISION(i),                              --tax_precision
               ar_system_options.TAX_MINIMUM_ACCOUNTABLE_UNIT(i),               --tax_minimum_accountable_unit
               ar_system_options.USE_TAX_CLASSIFICATION_FLAG(i),
               ar_system_options.HOME_COUNTRY_DEFAULT_FLAG(i),
               ar_system_options.SALES_TAX_GEOCODE(i),
               1,                                                               --object_version_number
               'MIGRATED',                                                      --record_type_code
               sysdate,                                                         --creation_date
               fnd_global.user_Id,                                              --created_by
               sysdate,                                                         --last_updated_by
               fnd_global.user_id,                                              --last_updated_by
               fnd_global.conc_login_id                                         --last_update_login
               );

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','AR Tax Options Migration : '||SQLERRM);
     FND_MSG_PUB.Add;
     IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
     END IF;
END AR_PRD_OPTIONS_MIGRATE;


PROCEDURE PO_PRD_OPTIONS_MIGRATE (x_return_status OUT NOCOPY VARCHAR2) IS
    po_system_options    system_options_rec;
    l_api_name           VARCHAR2(30) := 'PO_TAX_OPTIONS_MIGRATE';

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT decode(l_multi_org_flag,'N',l_org_id, sys.org_id),                   --org_id
           sys.tax_hier_ship_to_loc,
	   sys.tax_hier_item,
	   sys.tax_hier_vendor_site,
	   sys.tax_hier_vendor,
	   sys.tax_hier_system,
	   greatest(nvl(sys.tax_hier_ship_to_loc,-1),nvl(sys.tax_hier_item,-1),
	            nvl(sys.tax_hier_vendor_site,-1),nvl(sys.tax_hier_vendor,-1),
	            nvl(sys.tax_hier_system,-1)),
	   least(nvl(sys.tax_hier_ship_to_loc,999),nvl(sys.tax_hier_item,999),
	         nvl(sys.tax_hier_vendor_site,999),nvl(sys.tax_hier_vendor,999),
	         nvl(sys.tax_hier_system,999)),
           null,                                                                --default_hierarchy1
           null,                                                                --default_hierarchy2
           null,                                                                --default_hierarchy3
           null,                                                                --default_hierarchy4
           null,                                                                --default_hierarchy5
           null,                                                                --default_hierarchy6
           null,                                                                --default_hierarchy7
           fin.VAT_CODE,                                                        --tax_classification_code
           null,                                                                --tax_method_code
           --null,                                                                --inclusive_tax_used_flag
           null,                                                                --tax_use_customer_exempt_flag,
           null,                                                                --tax_use_product_exempt_flag
           null,                                                                --tax_use_loc_exc_rate_flag
           --null,                                                                --tax_allow_compound_flag
           null,                                                                --tax_rounding_rule
           null,                                                                --tax_precision
           null,                                                                --tax_minimum_accountable_unit
           decode (sys.tax_hier_ship_to_loc||sys.tax_hier_item||
                   sys.tax_hier_vendor_site||sys.tax_hier_vendor||
	           sys.tax_hier_system,null, 'N','Y'),                          --use_tax_classification_flag
	   null                                                                 --home_country_default_flag
     BULK COLLECT INTO
           po_system_options.org_id,
   	   po_system_options.tax_hier_ship_to_loc,
           po_system_options.tax_hier_item,
           po_system_options.tax_hier_vendor_site,
           po_system_options.tax_hier_vendor,
           po_system_options.tax_hier_system,
	   po_system_options.max_value,
	   po_system_options.min_value ,
           po_system_options.default_hierarchy1,
           po_system_options.default_hierarchy2,
           po_system_options.default_hierarchy3,
           po_system_options.default_hierarchy4,
           po_system_options.default_hierarchy5,
           po_system_options.default_hierarchy6,
           po_system_options.default_hierarchy7,
           po_system_options.tax_code,
           po_system_options.tax_method_code,
           --po_system_options.inclusive_tax_used_flag,
           po_system_options.tax_use_customer_exempt_flag,
           po_system_options.tax_use_product_exempt_flag,
           po_system_options.tax_use_loc_exc_rate_flag,
           --po_system_options.tax_allow_compound_flag,
           po_system_options.tax_rounding_rule,
           po_system_options.tax_precision,
           po_system_options.tax_minimum_accountable_unit,
           po_system_options.use_tax_classification_flag,
           po_system_options.home_country_default_flag
     FROM  PO_SYSTEM_PARAMETERS_ALL sys,
           FINANCIALS_SYSTEM_PARAMS_ALL fin
     WHERE decode(l_multi_org_flag,'N',l_org_id,fin.org_id(+))= decode(l_multi_org_flag,'N',l_org_id,sys.org_id)
       AND NOT EXISTS (SELECT 1
                         FROM ZX_PRODUCT_OPTIONS_ALL prd
    	                WHERE prd.ORG_ID = decode(l_multi_org_flag,'N',l_org_id,sys.org_id)
                          AND prd.APPLICATION_ID   = 201
                       );

     FOR i in 1..nvl(po_system_options.org_id.LAST,0)  LOOP
       FOR j in po_system_options.min_value(i)..po_system_options.max_value(i) LOOP
         IF po_system_options.DEFAULT_HIERARCHY1(i) is null THEN
           IF po_system_options.tax_hier_ship_to_loc(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY1(i) := 'SHIP_TO_LOCATION';
           ELSIF po_system_options.tax_hier_item(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY1(i) := 'ITEM';
           ELSIF po_system_options.tax_hier_vendor_site(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY1(i) := 'SHIP_FROM_PARTY_SITE';
           ELSIF po_system_options.tax_hier_vendor(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY1(i) := 'SHIP_FROM_PARTY';
           ELSIF po_system_options.tax_hier_system(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY1(i) := 'FINANCIAL_OPTIONS';
           END IF;
         ELSIF po_system_options.DEFAULT_HIERARCHY2(i) is null THEN
           IF po_system_options.tax_hier_ship_to_loc(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY2(i) := 'SHIP_TO_LOCATION';
           ELSIF po_system_options.tax_hier_item(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY2(i) := 'ITEM';
           ELSIF po_system_options.tax_hier_vendor_site(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY2(i) := 'SHIP_FROM_PARTY_SITE';
           ELSIF po_system_options.tax_hier_vendor(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY2(i) := 'SHIP_FROM_PARTY';
           ELSIF po_system_options.tax_hier_system(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY2(i) := 'FINANCIAL_OPTIONS';
           END IF;
         ELSIF po_system_options.DEFAULT_HIERARCHY3(i) is null THEN
           IF po_system_options.tax_hier_ship_to_loc(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY3(i) := 'SHIP_TO_LOCATION';
           ELSIF po_system_options.tax_hier_item(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY3(i) := 'ITEM';
           ELSIF po_system_options.tax_hier_vendor_site(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY3(i) := 'SHIP_FROM_PARTY_SITE';
           ELSIF po_system_options.tax_hier_vendor(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY3(i) := 'SHIP_FROM_PARTY';
           ELSIF po_system_options.tax_hier_system(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY3(i) := 'FINANCIAL_OPTIONS';
           END IF;
         ELSIF  po_system_options.DEFAULT_HIERARCHY4(i) is null THEN
           IF po_system_options.tax_hier_ship_to_loc(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY4(i) := 'SHIP_TO_LOCATION';
           ELSIF po_system_options.tax_hier_item(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY4(i) := 'ITEM';
           ELSIF po_system_options.tax_hier_vendor_site(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY4(i) := 'SHIP_FROM_PARTY_SITE';
           ELSIF po_system_options.tax_hier_vendor(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY4(i) := 'SHIP_FROM_PARTY';
           ELSIF po_system_options.tax_hier_system(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY4(i) := 'FINANCIAL_OPTIONS';
           END IF;
         ELSIF  po_system_options.DEFAULT_HIERARCHY5(i) is null THEN
           IF po_system_options.tax_hier_ship_to_loc(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY5(i) := 'SHIP_TO_LOCATION';
           ELSIF po_system_options.tax_hier_item(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY5(i) := 'ITEM';
           ELSIF po_system_options.tax_hier_vendor_site(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY5(i) := 'SHIP_FROM_PARTY_SITE';
           ELSIF po_system_options.tax_hier_vendor(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY5(i) := 'SHIP_FROM_PARTY';
           ELSIF po_system_options.tax_hier_system(i) = j THEN
              po_system_options.DEFAULT_HIERARCHY5(i) := 'FINANCIAL_OPTIONS';
           END IF;
         END IF;
       END LOOP;
     END LOOP;

     FORALL i in 1..nvl(po_system_options.org_id.LAST,0)
     INSERT INTO ZX_PRODUCT_OPTIONS_ALL (
                PRODUCT_OPTIONS_ID,
                ORG_ID,
                APPLICATION_ID,
                DEF_OPTION_HIER_1_CODE,
                DEF_OPTION_HIER_2_CODE,
                DEF_OPTION_HIER_3_CODE,
                DEF_OPTION_HIER_4_CODE,
                DEF_OPTION_HIER_5_CODE,
                TAX_CLASSIFICATION_CODE,
                TAX_METHOD_CODE,
                --INCLUSIVE_TAX_USED_FLAG,
                TAX_USE_CUSTOMER_EXEMPT_FLAG,
                TAX_USE_PRODUCT_EXEMPT_FLAG,
                TAX_USE_LOC_EXC_RATE_FLAG,
                --TAX_ALLOW_COMPOUND_FLAG,
                TAX_ROUNDING_RULE,
                TAX_PRECISION,
                TAX_MINIMUM_ACCOUNTABLE_UNIT,
                USE_TAX_CLASSIFICATION_FLAG,
                HOME_COUNTRY_DEFAULT_FLAG,
                OBJECT_VERSION_NUMBER,
                RECORD_TYPE_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
       	values (ZX_PRODUCT_OPTIONS_ALL_S.nextval,
               po_system_options.ORG_ID(i),
	       201,                                                             --application_id
               po_system_options.DEFAULT_HIERARCHY1(i),
               po_system_options.DEFAULT_HIERARCHY2(i),
               po_system_options.DEFAULT_HIERARCHY3(i),
               po_system_options.DEFAULT_HIERARCHY4(i),
               po_system_options.DEFAULT_HIERARCHY5(i),
               po_system_options.TAX_CODE(i),
               po_system_options.TAX_METHOD_CODE(i),
               --po_system_options.INCLUSIVE_TAX_USED_FLAG(i),
               po_system_options.TAX_USE_CUSTOMER_EXEMPT_FLAG(i),               --tax_use_customer_exempt_flag
               po_system_options.TAX_USE_PRODUCT_EXEMPT_FLAG(i),                --tax_use_product_exempt_flag
               po_system_options.TAX_USE_LOC_EXC_RATE_FLAG(i),                  --tax_use_loc_exc_rate_flag
               --po_system_options.TAX_ALLOW_COMPOUND_FLAG(i),                    --tax_allow_compound_flag
               po_system_options.TAX_ROUNDING_RULE(i),                          --tax_rounding_rule
               po_system_options.TAX_PRECISION(i),                              --tax_precision
               po_system_options.TAX_MINIMUM_ACCOUNTABLE_UNIT(i),               --tax_minimum_accountable_unit
               po_system_options.USE_TAX_CLASSIFICATION_FLAG(i),
               po_system_options.HOME_COUNTRY_DEFAULT_FLAG(i),
               1,                                                               --object_version_number
               'MIGRATED',                                                      --record_type_code
               sysdate,                                                         --creation_date
               fnd_global.user_Id,                                              --created_by
               sysdate,                                                         --last_updated_by
               fnd_global.user_id,                                              --last_updated_by
               fnd_global.conc_login_id                                         --last_update_login
               );

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','PO Tax Options Migration : '||SQLERRM);
     FND_MSG_PUB.Add;
     IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
     END IF;
END PO_PRD_OPTIONS_MIGRATE;

PROCEDURE PA_PRD_OPTIONS_MIGRATE (x_return_status OUT NOCOPY VARCHAR2) IS
    pa_system_options    system_options_rec;
    l_api_name           VARCHAR2(30) := 'PA_TAX_OPTIONS_MIGRATE';

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT decode(l_multi_org_flag,'N',l_org_id, sys.org_id),                   --org_id
           output_tax_hier_site,
	   output_tax_hier_cust,
	   output_tax_hier_project,
	   output_tax_hier_exp_ev,
	   output_tax_hier_extn,
	   output_tax_hier_ar_param,
	   greatest(nvl(output_tax_hier_site,-1),nvl(output_tax_hier_cust,-1),
	            nvl(output_tax_hier_project,-1),nvl(output_tax_hier_exp_ev,-1),
	            nvl(output_tax_hier_extn,-1),nvl(output_tax_hier_ar_param,-1)),
	   least(nvl(output_tax_hier_site,999),nvl(output_tax_hier_cust,999),
	         nvl(output_tax_hier_project,999),nvl(output_tax_hier_exp_ev,999),
	         nvl(output_tax_hier_extn,999),nvl(output_tax_hier_ar_param,999)),
           null,                                                                --default_hierarchy1
           null,                                                                --default_hierarchy2
           null,                                                                --default_hierarchy3
           null,                                                                --default_hierarchy4
           null,                                                                --default_hierarchy5
           null,                                                                --default_hierarchy6
           null,                                                                --default_hierarchy7
	   /*If AR system options enabled, get the tax code from AR.
	     If AR tax code is null and tax method is 'SALES_TAX, retrieve tax from location*/
           decode(sys.output_tax_use_ar_param_flag,'Y',                             --tax_code Bug 5753907
             decode(receivable.tax_code,null,
		decode (receivable.TAX_METHOD,'SALES_TAX',
		                              get_location_tax(decode(l_multi_org_flag,'N',l_org_id,receivable.org_id), receivable.set_of_books_id),null),receivable.tax_code),null),
           null,                                                                --tax_method_code
           --null,                                                                --inclusive_tax_used_flag
           null,                                                                --tax_use_customer_exempt_flag
           null,                                                                --tax_use_product_exempt_flag
           null,                                                                --tax_use_loc_exc_rate_flag
           --null,                                                                --tax_allow_compound_flag
           null,                                                                --tax_rounding_rule
           null,                                                                --tax_precision
           null,                                                                --tax_minimum_accountable_unit
           decode (sys.output_tax_hier_site||sys.output_tax_hier_cust||         --use_tax_classification_flag
 		   sys.output_tax_hier_project||sys.output_tax_hier_exp_ev||
		   sys.output_tax_hier_extn||sys.output_tax_hier_ar_param,null, 'N','Y'),
           decode(sys.output_tax_hier_ar_param,'Y',                             --home_country_default_flag
	     decode(receivable.tax_code,null,
	       decode (receivable.TAX_METHOD,'SALES_TAX','Y','N'),'N'),'N')
     BULK COLLECT INTO
           pa_system_options.org_id,
   	   pa_system_options.output_tax_hier_site,
           pa_system_options.output_tax_hier_cust,
           pa_system_options.output_tax_hier_project,
           pa_system_options.output_tax_hier_exp_ev,
           pa_system_options.output_tax_hier_extn,
           pa_system_options.output_tax_hier_ar_param,
	   pa_system_options.max_value,
	   pa_system_options.min_value ,
           pa_system_options.default_hierarchy1,
           pa_system_options.default_hierarchy2,
           pa_system_options.default_hierarchy3,
           pa_system_options.default_hierarchy4,
           pa_system_options.default_hierarchy5,
           pa_system_options.default_hierarchy6,
           pa_system_options.default_hierarchy7,
           pa_system_options.tax_code,
           pa_system_options.tax_method_code,
           --pa_system_options.inclusive_tax_used_flag,
           pa_system_options.tax_use_customer_exempt_flag,
           pa_system_options.tax_use_product_exempt_flag,
           pa_system_options.tax_use_loc_exc_rate_flag,
           --pa_system_options.tax_allow_compound_flag,
           pa_system_options.tax_rounding_rule,
           pa_system_options.tax_precision,
           pa_system_options.tax_minimum_accountable_unit,
           pa_system_options.use_tax_classification_flag,
           pa_system_options.home_country_default_flag
     FROM  PA_IMPLEMENTATIONS_ALL sys,
           AR_SYSTEM_PARAMETERS_ALL receivable
     WHERE decode(l_multi_org_flag,'N',l_org_id,receivable.ORG_ID(+))   = decode(l_multi_org_flag,'N',l_org_id,sys.ORG_ID)
       AND NOT EXISTS (SELECT 1
         	         FROM ZX_PRODUCT_OPTIONS_ALL prd
    	                WHERE prd.ORG_ID = decode(l_multi_org_flag,'N',l_org_id,sys.org_id)
                         AND  prd.APPLICATION_ID   = 275
                       );

     FOR i in 1..nvl(pa_system_options.org_id.LAST,0)  LOOP
       FOR j in pa_system_options.min_value(i)..pa_system_options.max_value(i) LOOP
         IF pa_system_options.DEFAULT_HIERARCHY1(i) is null THEN
           IF pa_system_options.output_tax_hier_site(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY1(i) := 'SHIP_TO_PARTY_SITE';
           ELSIF pa_system_options.output_tax_hier_cust(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY1(i) := 'SHIP_TO_PARTY';
           ELSIF pa_system_options.output_tax_hier_project(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY1(i) := 'PROJECT';
           ELSIF pa_system_options.output_tax_hier_exp_ev(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY1(i) := 'TYPE';
           ELSIF pa_system_options.output_tax_hier_extn(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY1(i) := 'CLIENT_EXTENSION';
           ELSIF pa_system_options.output_tax_hier_ar_param(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY1(i) := 'SYSTEM_OPTIONS';
           END IF;
         ELSIF pa_system_options.DEFAULT_HIERARCHY2(i) is null THEN
           IF pa_system_options.output_tax_hier_site(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY2(i) := 'SHIP_TO_PARTY_SITE';
           ELSIF pa_system_options.output_tax_hier_cust(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY2(i) := 'SHIP_TO_PARTY';
           ELSIF pa_system_options.output_tax_hier_project(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY2(i) := 'PROJECT';
           ELSIF pa_system_options.output_tax_hier_exp_ev(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY2(i) := 'TYPE';
           ELSIF pa_system_options.output_tax_hier_extn(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY2(i) := 'CLIENT_EXTENSION';
           ELSIF pa_system_options.output_tax_hier_ar_param(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY2(i) := 'SYSTEM_OPTIONS';
           END IF;
         ELSIF pa_system_options.DEFAULT_HIERARCHY3(i) is null THEN
           IF pa_system_options.output_tax_hier_site(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY3(i) := 'SHIP_TO_PARTY_SITE';
           ELSIF pa_system_options.output_tax_hier_cust(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY3(i) := 'SHIP_TO_PARTY';
           ELSIF pa_system_options.output_tax_hier_project(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY3(i) := 'PROJECT';
           ELSIF pa_system_options.output_tax_hier_exp_ev(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY3(i) := 'TYPE';
           ELSIF pa_system_options.output_tax_hier_extn(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY3(i) := 'CLIENT_EXTENSION';
           ELSIF pa_system_options.output_tax_hier_ar_param(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY3(i) := 'SYSTEM_OPTIONS';
           END IF;
         ELSIF  pa_system_options.DEFAULT_HIERARCHY4(i) is null THEN
           IF pa_system_options.output_tax_hier_site(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY4(i) := 'SHIP_TO_PARTY_SITE';
           ELSIF pa_system_options.output_tax_hier_cust(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY4(i) := 'SHIP_TO_PARTY';
           ELSIF pa_system_options.output_tax_hier_project(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY4(i) := 'PROJECT';
           ELSIF pa_system_options.output_tax_hier_exp_ev(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY4(i) := 'TYPE';
           ELSIF pa_system_options.output_tax_hier_extn(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY4(i) := 'CLIENT_EXTENSION';
           ELSIF pa_system_options.output_tax_hier_ar_param(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY4(i) := 'SYSTEM_OPTIONS';
           END IF;
         ELSIF  pa_system_options.DEFAULT_HIERARCHY5(i) is null THEN
           IF pa_system_options.output_tax_hier_site(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY5(i) := 'SHIP_TO_PARTY_SITE';
           ELSIF pa_system_options.output_tax_hier_cust(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY5(i) := 'SHIP_TO_PARTY';
           ELSIF pa_system_options.output_tax_hier_project(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY5(i) := 'PROJECT';
           ELSIF pa_system_options.output_tax_hier_exp_ev(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY5(i) := 'TYPE';
           ELSIF pa_system_options.output_tax_hier_extn(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY5(i) := 'CLIENT_EXTENSION';
           ELSIF pa_system_options.output_tax_hier_ar_param(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY5(i) := 'SYSTEM_OPTIONS';
           END IF;
         ELSIF  pa_system_options.DEFAULT_HIERARCHY6(i) is null THEN
           IF pa_system_options.output_tax_hier_site(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY6(i) := 'SHIP_TO_PARTY_SITE';
           ELSIF pa_system_options.output_tax_hier_cust(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY6(i) := 'SHIP_TO_PARTY';
           ELSIF pa_system_options.output_tax_hier_project(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY6(i) := 'PROJECT';
           ELSIF pa_system_options.output_tax_hier_exp_ev(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY6(i) := 'TYPE';
           ELSIF pa_system_options.output_tax_hier_extn(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY6(i) := 'CLIENT_EXTENSION';
           ELSIF pa_system_options.output_tax_hier_ar_param(i) = j THEN
              pa_system_options.DEFAULT_HIERARCHY6(i) := 'SYSTEM_OPTIONS';
           END IF;
         END IF;
       END LOOP;
     END LOOP;

     FORALL i in 1..nvl(pa_system_options.org_id.LAST,0)
     INSERT INTO ZX_PRODUCT_OPTIONS_ALL (
                PRODUCT_OPTIONS_ID,
                ORG_ID,
                APPLICATION_ID,
                DEF_OPTION_HIER_1_CODE,
                DEF_OPTION_HIER_2_CODE,
                DEF_OPTION_HIER_3_CODE,
                DEF_OPTION_HIER_4_CODE,
                DEF_OPTION_HIER_5_CODE,
                DEF_OPTION_HIER_6_CODE,
                TAX_CLASSIFICATION_CODE,
                TAX_METHOD_CODE,
                --INCLUSIVE_TAX_USED_FLAG,
                TAX_USE_CUSTOMER_EXEMPT_FLAG,
                TAX_USE_PRODUCT_EXEMPT_FLAG,
                TAX_USE_LOC_EXC_RATE_FLAG,
                --TAX_ALLOW_COMPOUND_FLAG,
                TAX_ROUNDING_RULE,
                TAX_PRECISION,
                TAX_MINIMUM_ACCOUNTABLE_UNIT,
                USE_TAX_CLASSIFICATION_FLAG,
                HOME_COUNTRY_DEFAULT_FLAG,
                OBJECT_VERSION_NUMBER,
                RECORD_TYPE_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
       	values (ZX_PRODUCT_OPTIONS_ALL_S.nextval,
               pa_system_options.org_id(i),
	       275,                                                             --application_id
               pa_system_options.DEFAULT_HIERARCHY1(i),
               pa_system_options.DEFAULT_HIERARCHY2(i),
               pa_system_options.DEFAULT_HIERARCHY3(i),
               pa_system_options.DEFAULT_HIERARCHY4(i),
               pa_system_options.DEFAULT_HIERARCHY5(i),
               pa_system_options.DEFAULT_HIERARCHY6(i),
               pa_system_options.TAX_CODE(i),
               pa_system_options.TAX_METHOD_CODE(i),
               --pa_system_options.INCLUSIVE_TAX_USED_FLAG(i),
               pa_system_options.TAX_USE_CUSTOMER_EXEMPT_FLAG(i),               --tax_use_customer_exempt_flag
               pa_system_options.TAX_USE_PRODUCT_EXEMPT_FLAG(i),                --tax_use_product_exempt_flag
               pa_system_options.TAX_USE_LOC_EXC_RATE_FLAG(i),                  --tax_use_loc_exc_rate_flag
               --pa_system_options.TAX_ALLOW_COMPOUND_FLAG(i),                    --tax_allow_compound_flag
               pa_system_options.TAX_ROUNDING_RULE(i),                          --tax_rounding_rule
               pa_system_options.TAX_PRECISION(i),                              --tax_precision
               pa_system_options.TAX_MINIMUM_ACCOUNTABLE_UNIT(i),               --tax_minimum_accountable_unit
               pa_system_options.USE_TAX_CLASSIFICATION_FLAG(i),
               pa_system_options.HOME_COUNTRY_DEFAULT_FLAG(i),
               1,                                                               --object_version_number
               'MIGRATED',                                                      --record_type_code
               sysdate,                                                         --creation_date
               fnd_global.user_Id,                                              --created_by
               sysdate,                                                         --last_updated_by
               fnd_global.user_id,                                              --last_updated_by
               fnd_global.conc_login_id                                         --last_update_login
               );



   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','PA Tax Options Migration : '||SQLERRM);
     FND_MSG_PUB.Add;
     IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
     END IF;
END PA_PRD_OPTIONS_MIGRATE;


PROCEDURE OIE_PRD_OPTIONS_MIGRATE (x_return_status OUT NOCOPY VARCHAR2) IS

    l_api_name           VARCHAR2(30) := 'OIE_TAX_OPTIONS_MIGRATE';

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

     INSERT INTO ZX_PRODUCT_OPTIONS_ALL (
                PRODUCT_OPTIONS_ID,
                ORG_ID,
                APPLICATION_ID,
                EVENT_CLASS_MAPPING_ID,
                DEF_OPTION_HIER_1_CODE,
                DEF_OPTION_HIER_2_CODE,
                DEF_OPTION_HIER_3_CODE,
                DEF_OPTION_HIER_4_CODE,
                DEF_OPTION_HIER_5_CODE,
                DEF_OPTION_HIER_6_CODE,
                DEF_OPTION_HIER_7_CODE,
                TAX_CLASSIFICATION_CODE,
                TAX_METHOD_CODE,
                --INCLUSIVE_TAX_USED_FLAG,
                TAX_USE_CUSTOMER_EXEMPT_FLAG,
                TAX_USE_PRODUCT_EXEMPT_FLAG,
                TAX_USE_LOC_EXC_RATE_FLAG,
                --TAX_ALLOW_COMPOUND_FLAG,
                TAX_ROUNDING_RULE,
                TAX_PRECISION,
                TAX_MINIMUM_ACCOUNTABLE_UNIT,
                USE_TAX_CLASSIFICATION_FLAG,
                HOME_COUNTRY_DEFAULT_FLAG,
                OBJECT_VERSION_NUMBER,
                RECORD_TYPE_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
       	SELECT ZX_PRODUCT_OPTIONS_ALL_S.nextval,
	       decode(l_multi_org_flag,'N',l_org_id,prd.org_id),
	       prd.application_id,
               mapp.event_class_mapping_id,
               prd.def_option_hier_1_code,
               prd.def_option_hier_2_code,
               prd.def_option_hier_3_code,
               prd.def_option_hier_4_code,
               prd.def_option_hier_5_code,
               prd.def_option_hier_6_code,
               prd.def_option_hier_7_code,
               prd.tax_classification_code,
               prd.tax_method_code,
               --prd.inclusive_tax_used_flag,
               prd.tax_use_customer_exempt_flag,
               prd.tax_use_product_exempt_flag,
               prd.tax_use_loc_exc_rate_flag,
               --prd.tax_allow_compound_flag,
               prd.tax_rounding_rule,
               prd.tax_precision,
               prd.tax_minimum_accountable_unit,
               prd.use_tax_classification_flag,
               prd.home_country_default_flag,
               prd.object_version_number,
               prd.record_type_code,
               prd.creation_date,
               prd.created_by,
               prd.last_update_date,
               prd.last_updated_by,
               prd.last_update_login
    	FROM  ZX_PRODUCT_OPTIONS_ALL prd,
    	      ZX_EVNT_CLS_MAPPINGS mapp
    	WHERE prd.application_id   = 200
    	  AND prd.event_class_mapping_id is null
    	  AND mapp.application_id = prd.application_id
    	  AND mapp.entity_code = 'AP_INVOICES'
    	  AND mapp.event_class_code = 'EXPENSE REPORTS'
          AND NOT EXISTS (SELECT 1
        	            FROM ZX_PRODUCT_OPTIONS_ALL prd1
    	                   WHERE prd1.ORG_ID = decode(l_multi_org_flag,'N',l_org_id,prd.org_id)
                             AND prd1.APPLICATION_ID   = 200
                             AND prd1.event_class_mapping_id = (SELECT event_class_mapping_id
                                                                  FROM zx_evnt_cls_mappings
                                                                 WHERE application_id = 200
                                                               	   AND entity_code = 'AP_INVOICES'
                                                              	   AND event_class_code = 'EXPENSE REPORTS')
                          );


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','PA Tax Options Migration : '||SQLERRM);
     FND_MSG_PUB.Add;
     IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
     END IF;
END OIE_PRD_OPTIONS_MIGRATE;


PROCEDURE MIGRATE_PRODUCT_OPTIONS(x_return_status OUT NOCOPY VARCHAR2)
IS
  l_api_name           VARCHAR2(30) := 'MIGRATE_PRODUCT_OPTIONS';
  l_return_status      VARCHAR2(1);

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*-----------------------------------------------------+
    |   Process records from AR                           |
    +-----------------------------------------------------*/
    AR_PRD_OPTIONS_MIGRATE(l_return_status);


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','Product Tax Options Migration : '||SQLERRM);
      FND_MSG_PUB.Add;
      RETURN;
    END IF;


   /*-----------------------------------------------------+
    |   Process records from AP                           |
    +-----------------------------------------------------*/
    AP_PRD_OPTIONS_MIGRATE (l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','Product Tax Options Migration : '||SQLERRM);
      FND_MSG_PUB.Add;
      RETURN;
    END IF;


   /*-----------------------------------------------------+
    |   Process records from PO                           |
    +-----------------------------------------------------*/
    PO_PRD_OPTIONS_MIGRATE (l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','Product Tax Options Migration : '||SQLERRM);
      FND_MSG_PUB.Add;
      RETURN;
    END IF;


   /*-----------------------------------------------------+
    |   Process records from PA                           |
    +-----------------------------------------------------*/
    PA_PRD_OPTIONS_MIGRATE (l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','Product Tax Options Migration : '||SQLERRM);
      FND_MSG_PUB.Add;
      RETURN;
    END IF;

   /*-----------------------------------------------------+
    |   Process records from OIE                          |
    +-----------------------------------------------------*/
    OIE_PRD_OPTIONS_MIGRATE (l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','Product Tax Options Migration : '||SQLERRM);
      FND_MSG_PUB.Add;
      RETURN;
    END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

 END MIGRATE_PRODUCT_OPTIONS;

BEGIN

   SELECT NVL(MULTI_ORG_FLAG,'N')
     INTO L_MULTI_ORG_FLAG
	 FROM FND_PRODUCT_GROUPS;

    IF L_MULTI_ORG_FLAG  = 'N' THEN
       FND_PROFILE.GET('ORG_ID',L_ORG_ID);
       IF L_ORG_ID IS NULL THEN
          arp_util_tax.debug('MO: Operating Units site level profile option value not set , resulted in Null Org Id');
       END IF;
    ELSE
         L_ORG_ID := NULL;
    END IF;
EXCEPTION
WHEN OTHERS THEN
    arp_util_tax.debug('Exception in Migrate Product Options Constructor : '||sqlerrm);

END ZX_PRD_OPTIONS_MIGRATE_PKG;

/
