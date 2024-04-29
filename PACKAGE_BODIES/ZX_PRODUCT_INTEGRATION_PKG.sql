--------------------------------------------------------
--  DDL for Package Body ZX_PRODUCT_INTEGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_PRODUCT_INTEGRATION_PKG" AS
/* $Header: zxdiprodintgpkgb.pls 120.48.12010000.18 2010/03/13 00:23:37 skorrapa ship $ */

-- global variable
  pg_debug   VARCHAR2(1);
  dummy   VARCHAR2(25);

  C_LINES_PER_INSERT      CONSTANT NUMBER :=1000;

  g_current_runtime_level NUMBER;
  g_level_statement            CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure            CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
  g_level_event                CONSTANT  NUMBER   := FND_LOG.LEVEL_EVENT;
  g_level_unexpected           CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;


  pg_application_id            NUMBER;
  pg_application_short_name    FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE;

  pg_old_customer_trx_id       NUMBER;
  pg_cm_type                   VARCHAR2(15);
  pg_bad_lines                 NUMBER;

  -- global variables for arp_tax_calculate
   pg_tax_rate_passed          ar_vat_tax.tax_rate%TYPE;
   pg_adhoc_tax_code           VARCHAR2(1);

   -- Added as a fix for Bug#8231156
   TYPE l_line_level_rec_type IS RECORD(
     trx_id                     NUMBER
   );
   TYPE l_line_level_tbl_type IS TABLE OF l_line_level_rec_type INDEX BY BINARY_INTEGER;
   l_line_level_tbl l_line_level_tbl_type;

  -- Record Type modified as a fix for Bug#7530930
  TYPE tax_line_rec_type is RECORD (
    summary_tax_line_number   zx_import_tax_lines_gt.summary_tax_line_number%TYPE,
    internal_organization_id  zx_import_tax_lines_gt.internal_organization_id%TYPE,
    tax_regime_code           zx_import_tax_lines_gt.tax_regime_code%TYPE,
    tax                       zx_import_tax_lines_gt.tax%TYPE,
    tax_status_code           zx_import_tax_lines_gt.tax_status_code%TYPE,
    tax_rate_code             zx_import_tax_lines_gt.tax_rate_code%TYPE,
    tax_rate                  zx_import_tax_lines_gt.tax_rate%TYPE,
    tax_amt                   zx_import_tax_lines_gt.tax_amt%TYPE,
    tax_jurisdiction_code     zx_import_tax_lines_gt.tax_jurisdiction_code%TYPE,
    tax_amt_included_flag     zx_import_tax_lines_gt.tax_amt_included_flag%TYPE,
    tax_rate_id               zx_import_tax_lines_gt.tax_rate_id%TYPE,
    tax_provider_id           zx_import_tax_lines_gt.tax_provider_id%TYPE,
    tax_exception_id          zx_import_tax_lines_gt.tax_exception_id%TYPE,
    tax_exemption_id          zx_import_tax_lines_gt.tax_exemption_id%TYPE,
    exempt_reason_code        zx_import_tax_lines_gt.exempt_reason_code%TYPE,
    exempt_certificate_number zx_import_tax_lines_gt.exempt_certificate_number%TYPE,
    trx_line_id               zx_transaction_lines_gt.trx_line_id%TYPE,
    line_amt                  zx_transaction_lines_gt.line_amt%TYPE,
    trx_date                  zx_trx_headers_gt.trx_date%TYPE,
    minimum_accountable_unit  zx_trx_headers_gt.minimum_accountable_unit%TYPE,
    precision                 zx_trx_headers_gt.precision%TYPE,
    trx_level_type            zx_transaction_lines_gt.trx_level_type%TYPE,
    trx_line_date             zx_transaction_lines_gt.trx_line_date%TYPE,
    adjusted_doc_date         zx_transaction_lines_gt.adjusted_doc_date%TYPE,
    line_level_action         zx_transaction_lines_gt.line_level_action%TYPE,
    interface_entity_code     zx_import_tax_lines_gt.interface_entity_code%TYPE,
    interface_tax_line_id     zx_import_tax_lines_gt.interface_tax_line_id%TYPE,
    related_doc_date          zx_trx_headers_gt.related_doc_date%TYPE,
    provnl_tax_determination_date zx_trx_headers_gt.provnl_tax_determination_date%TYPE,
    tax_date 		              zx_transaction_lines_gt.tax_date%type,
    tax_determine_date 	      zx_transaction_lines_gt.tax_determine_date%type,
    tax_point_date 	          zx_transaction_lines_gt.tax_point_date%type
    );

-- Private Methods
PROCEDURE  get_vat_tax_rate;

PROCEDURE import_trx_line_with_taxes (
 p_event_class_rec          IN          zx_api_pub.event_class_rec_type,
 p_id_dist_tbl              IN          NUMBER,
 x_return_status            OUT NOCOPY  VARCHAR2);

PROCEDURE calculate_tax_lte (
  p_event_class_rec   IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  p_id_dist_tbl             IN         NUMBER,
  x_return_status    OUT NOCOPY  VARCHAR2
);

PROCEDURE prepare_tax_info_rec(
  p_index   IN NUMBER
);

PROCEDURE process_tax_rec_f_sql_lte (
		p_appl_short_name	 IN VARCHAR2
);

PROCEDURE arp_tax_calculate;

PROCEDURE  prepare_detail_tax_line(
  p_event_class_rec  IN zx_api_pub.event_class_rec_type,
  p_id_dist_tbl      IN NUMBER,
  p_new_row_num      IN NUMBER,
  p_tax_out_rec      IN tax_info_rec_TYPE
);

 PROCEDURE create_detail_tax_line (
  p_event_class_rec         IN 	           zx_api_pub.event_class_rec_type,
  p_tax_line_rec	    IN	    	   tax_line_rec_type,
  p_id_dist_tbl         IN NUMBER,
  p_new_row_num		    IN		   NUMBER,
  x_return_status              OUT NOCOPY  VARCHAR2);

PROCEDURE  get_tax_rate_id (
  p_tax_regime_code	    IN		 VARCHAR2,
  p_tax                     IN	         VARCHAR2,
  p_tax_status_code         IN           VARCHAR2,
  p_tax_rate_code           IN           VARCHAR2,
  p_tax_determine_date      IN		 DATE,
  p_tax_jurisdiction_code   IN           VARCHAR2,  -- bug#5395227
  x_tax_rate_id 	    OUT NOCOPY	 NUMBER,
  x_return_status           OUT NOCOPY   VARCHAR2,
  x_error_buffer            OUT NOCOPY   VARCHAR2); -- bug#5395227

FUNCTION adjust_compound_inclusive return NUMBER;

-- Procedure added to fetch the existing manual tax lines  -- Bug#8256247
PROCEDURE fetch_manual_tax_lines (
  p_event_class_rec      IN  ZX_API_PUB.event_class_rec_type,
  p_index                IN  BINARY_INTEGER,
  x_return_status        OUT NOCOPY  VARCHAR2
);

-- Procedure added to fetch the manual tax                 -- Bug#8776916
-- lines of adjusted doc for the CM creation
PROCEDURE get_manual_tax_lines_for_cm (
  p_event_class_rec     IN  ZX_API_PUB.event_class_rec_type,
  p_index               IN  BINARY_INTEGER,
  x_return_status       OUT NOCOPY  VARCHAR2
);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    initialize                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      Initialize the debug info, cache info. set System and Profile        |
 |      options required by the Tax Entity Handler and other functions in    |
 |      the global records sysinfo and profinfo.                             |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | CALLED FROM                                                               |
 |      calculate_tax                                                        |
 | NOTES                                                                     |
 | MODIFICATION HISTORY                                                      |
 |      30-Dec-2003     Ling Zhang modified from                             |
 |                      arp_tax_crm_integration_pkg.initialize               |
 |      27-Dec-2004	Nilesh Patel created from arp_tax                    |
 +===========================================================================*/

PROCEDURE initialize(
  p_event_class_rec   IN   zx_api_pub.event_class_rec_type,
  x_return_status     OUT NOCOPY  VARCHAR2
) is

  CURSOR c_application_short_name (l_appl_id IN NUMBER) IS
    SELECT application_short_name, application_id
    FROM FND_APPLICATION
    WHERE application_id = l_appl_id;

  l_last_org_id NUMBER;
  l_debug_flag               VARCHAR2(1);
  l_security_profile_id       FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE := NULL;

 l_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%type;
 l_functional_currency   gl_sets_of_books.currency_code%type;
 l_base_precision        fnd_currencies.precision%type;
 l_base_min_acc_unit     fnd_currencies.minimum_accountable_unit%type;
 l_master_org_id         oe_system_parameters_all.master_organization_id%type;
 l_sob_test              gl_sets_of_books.set_of_books_id%type;
 -- bug fix 3142794 l_last_org_id           ar_system_parameters_all.org_id%type;

type l_ar_sys_rec is record(
          DEFAULT_GROUPING_RULE_ID  	AR_SYSTEM_PARAMETERS_ALL.DEFAULT_GROUPING_RULE_ID%TYPE,
          SALESREP_REQUIRED_FLAG    	AR_SYSTEM_PARAMETERS_ALL.SALESREP_REQUIRED_FLAG%TYPE ,
          ATTRIBUTE11    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE11%TYPE,
          ATTRIBUTE12    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE12%TYPE,
          ATTRIBUTE13    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE13%TYPE,
          ATTRIBUTE14    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE14%TYPE,
          ATTRIBUTE15    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE15%TYPE,
          AUTO_REC_INVOICES_PER_COMMIT  AR_SYSTEM_PARAMETERS_ALL.AUTO_REC_INVOICES_PER_COMMIT%type,
          AUTO_REC_RECEIPTS_PER_COMMIT  AR_SYSTEM_PARAMETERS_ALL.AUTO_REC_RECEIPTS_PER_COMMIT%type,
          PAY_UNRELATED_INVOICES_FLAG   AR_SYSTEM_PARAMETERS_ALL.PAY_UNRELATED_INVOICES_FLAG%type,
          PRINT_HOME_COUNTRY_FLAG     	AR_SYSTEM_PARAMETERS_ALL.PRINT_HOME_COUNTRY_FLAG%type,
          LOCATION_TAX_ACCOUNT    	AR_SYSTEM_PARAMETERS_ALL.LOCATION_TAX_ACCOUNT%type,
          FROM_POSTAL_CODE    		AR_SYSTEM_PARAMETERS_ALL.FROM_POSTAL_CODE%type,
          TO_POSTAL_CODE    		AR_SYSTEM_PARAMETERS_ALL.TO_POSTAL_CODE%type,
          TAX_REGISTRATION_NUMBER    	AR_SYSTEM_PARAMETERS_ALL.TAX_REGISTRATION_NUMBER%type,
          POPULATE_GL_SEGMENTS_FLAG     AR_SYSTEM_PARAMETERS_ALL.POPULATE_GL_SEGMENTS_FLAG%type,
          UNALLOCATED_REVENUE_CCID    	AR_SYSTEM_PARAMETERS_ALL. UNALLOCATED_REVENUE_CCID%type,
          ORG_ID    			AR_SYSTEM_PARAMETERS_ALL.ORG_ID%TYPE,
          ATTRIBUTE9    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE9%TYPE,
          ATTRIBUTE10    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE10%TYPE,
          CALC_DISCOUNT_ON_LINES_FLAG   AR_SYSTEM_PARAMETERS_ALL.CALC_DISCOUNT_ON_LINES_FLAG%type,
          CHANGE_PRINTED_INVOICE_FLAG   AR_SYSTEM_PARAMETERS_ALL.CHANGE_PRINTED_INVOICE_FLAG%type,
          CODE_COMBINATION_ID_LOSS      AR_SYSTEM_PARAMETERS_ALL.CODE_COMBINATION_ID_LOSS%type,
           CREATE_RECIPROCAL_FLAG       AR_SYSTEM_PARAMETERS_ALL. CREATE_RECIPROCAL_FLAG%type,
           DEFAULT_COUNTRY    		AR_SYSTEM_PARAMETERS_ALL.DEFAULT_COUNTRY%type,
           DEFAULT_TERRITORY    	AR_SYSTEM_PARAMETERS_ALL.DEFAULT_TERRITORY%type,
           GENERATE_CUSTOMER_NUMBER     AR_SYSTEM_PARAMETERS_ALL.GENERATE_CUSTOMER_NUMBER%type,
           INVOICE_DELETION_FLAG    	AR_SYSTEM_PARAMETERS_ALL.INVOICE_DELETION_FLAG%type,
           LOCATION_STRUCTURE_ID    	AR_SYSTEM_PARAMETERS_ALL.LOCATION_STRUCTURE_ID %type,
           SITE_REQUIRED_FLAG    	AR_SYSTEM_PARAMETERS_ALL.SITE_REQUIRED_FLAG%type,
           TAX_ALLOW_COMPOUND_FLAG      AR_SYSTEM_PARAMETERS_ALL.TAX_ALLOW_COMPOUND_FLAG%type,
           TAX_INVOICE_PRINT    	AR_SYSTEM_PARAMETERS_ALL.TAX_INVOICE_PRINT%type,
           TAX_METHOD    		AR_SYSTEM_PARAMETERS_ALL. TAX_METHOD%type,
           TAX_USE_CUSTOMER_EXEMPT_FLAG AR_SYSTEM_PARAMETERS_ALL.TAX_USE_CUSTOMER_EXEMPT_FLAG%type,
           TAX_USE_CUST_EXC_RATE_FLAG   AR_SYSTEM_PARAMETERS_ALL. TAX_USE_CUST_EXC_RATE_FLAG%type,
           TAX_USE_LOC_EXC_RATE_FLAG    AR_SYSTEM_PARAMETERS_ALL.TAX_USE_LOC_EXC_RATE_FLAG%type,
           TAX_USE_PRODUCT_EXEMPT_FLAG  AR_SYSTEM_PARAMETERS_ALL.TAX_USE_PRODUCT_EXEMPT_FLAG%type,
           TAX_USE_PROD_EXC_RATE_FLAG   AR_SYSTEM_PARAMETERS_ALL. TAX_USE_PROD_EXC_RATE_FLAG%type,
           TAX_USE_SITE_EXC_RATE_FLAG   AR_SYSTEM_PARAMETERS_ALL.TAX_USE_SITE_EXC_RATE_FLAG%type,
           AI_LOG_FILE_MESSAGE_LEVEL    AR_SYSTEM_PARAMETERS_ALL. AI_LOG_FILE_MESSAGE_LEVEL%type,
           AI_MAX_MEMORY_IN_BYTES    	AR_SYSTEM_PARAMETERS_ALL.AI_MAX_MEMORY_IN_BYTES%type,
           AI_ACCT_FLEX_KEY_LEFT_PROMPT AR_SYSTEM_PARAMETERS_ALL. AI_ACCT_FLEX_KEY_LEFT_PROMPT%type,
           AI_MTL_ITEMS_KEY_LEFT_PROMPT AR_SYSTEM_PARAMETERS_ALL.AI_MTL_ITEMS_KEY_LEFT_PROMPT%type,
           AI_TERRITORY_KEY_LEFT_PROMPT AR_SYSTEM_PARAMETERS_ALL.AI_TERRITORY_KEY_LEFT_PROMPT%type,
           AI_PURGE_INTERFACE_TABLES_FLAG  AR_SYSTEM_PARAMETERS_ALL. AI_PURGE_INTERFACE_TABLES_FLAG%type,
           AI_ACTIVATE_SQL_TRACE_FLAG   AR_SYSTEM_PARAMETERS_ALL.AI_ACTIVATE_SQL_TRACE_FLAG %type,
           SET_OF_BOOKS_ID    		AR_SYSTEM_PARAMETERS_ALL.SET_OF_BOOKS_ID%type,
           CREATED_BY    		AR_SYSTEM_PARAMETERS_ALL. CREATED_BY%type,
           CREATION_DATE 		AR_SYSTEM_PARAMETERS_ALL.CREATION_DATE%TYPE,
           LAST_UPDATED_BY 		AR_SYSTEM_PARAMETERS_ALL.LAST_UPDATED_BY%TYPE,
           LAST_UPDATE_DATE    		AR_SYSTEM_PARAMETERS_ALL.LAST_UPDATE_DATE%type,
           LAST_UPDATE_LOGIN    	AR_SYSTEM_PARAMETERS_ALL. LAST_UPDATE_LOGIN%type,
           ACCOUNTING_METHOD    	AR_SYSTEM_PARAMETERS_ALL.ACCOUNTING_METHOD%TYPE,
           ACCRUE_INTEREST    		AR_SYSTEM_PARAMETERS_ALL.ACCRUE_INTEREST%TYPE,
           UNEARNED_DISCOUNT    	AR_SYSTEM_PARAMETERS_ALL.UNEARNED_DISCOUNT%TYPE,
           PARTIAL_DISCOUNT_FLAG    	AR_SYSTEM_PARAMETERS_ALL.PARTIAL_DISCOUNT_FLAG%type,
           PRINT_REMIT_TO    		AR_SYSTEM_PARAMETERS_ALL. PRINT_REMIT_TO%type,
           DEFAULT_CB_DUE_DATE    	AR_SYSTEM_PARAMETERS_ALL. DEFAULT_CB_DUE_DATE%type,
           AUTO_SITE_NUMBERING    	AR_SYSTEM_PARAMETERS_ALL.AUTO_SITE_NUMBERING%type,
           CASH_BASIS_SET_OF_BOOKS_ID   AR_SYSTEM_PARAMETERS_ALL.CASH_BASIS_SET_OF_BOOKS_ID%type,
           CODE_COMBINATION_ID_GAIN     AR_SYSTEM_PARAMETERS_ALL.CODE_COMBINATION_ID_GAIN%type,
           AUTOCASH_HIERARCHY_ID    	AR_SYSTEM_PARAMETERS_ALL. AUTOCASH_HIERARCHY_ID%type,
           RUN_GL_JOURNAL_IMPORT_FLAG   AR_SYSTEM_PARAMETERS_ALL.RUN_GL_JOURNAL_IMPORT_FLAG%type,
           CER_SPLIT_AMOUNT    		AR_SYSTEM_PARAMETERS_ALL. CER_SPLIT_AMOUNT%type,
           CER_DSO_DAYS    		AR_SYSTEM_PARAMETERS_ALL.CER_DSO_DAYS%type,
           POSTING_DAYS_PER_CYCLE    	AR_SYSTEM_PARAMETERS_ALL.POSTING_DAYS_PER_CYCLE%type,
           ADDRESS_VALIDATION    	AR_SYSTEM_PARAMETERS_ALL. ADDRESS_VALIDATION%type,
           ATTRIBUTE1    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE1%type,
           ATTRIBUTE2    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE2%type,
           ATTRIBUTE_CATEGORY    	AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE_CATEGORY%type,
           ATTRIBUTE3    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE3%type,
           ATTRIBUTE4    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE4%type,
           ATTRIBUTE5    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE5%type,
           ATTRIBUTE6    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE6%type,
           ATTRIBUTE7    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE7%type,
           ATTRIBUTE8    		AR_SYSTEM_PARAMETERS_ALL.ATTRIBUTE8%type,
           TAX_CODE    			AR_SYSTEM_PARAMETERS_ALL.TAX_CODE%type,
           TAX_CURRENCY_CODE    	AR_SYSTEM_PARAMETERS_ALL.TAX_CURRENCY_CODE%type,
           TAX_HEADER_LEVEL_FLAG    	AR_SYSTEM_PARAMETERS_ALL.TAX_HEADER_LEVEL_FLAG%type,
           TAX_MINIMUM_ACCOUNTABLE_UNIT AR_SYSTEM_PARAMETERS_ALL.TAX_MINIMUM_ACCOUNTABLE_UNIT%type,
           TAX_PRECISION    		AR_SYSTEM_PARAMETERS_ALL.TAX_PRECISION%type,
           TAX_ROUNDING_RULE    	AR_SYSTEM_PARAMETERS_ALL.TAX_ROUNDING_RULE%type,
           GLOBAL_ATTRIBUTE1    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE1%type,
           GLOBAL_ATTRIBUTE2    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE2%type,
           GLOBAL_ATTRIBUTE3    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE3%type,
           GLOBAL_ATTRIBUTE4    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE4%type,
           GLOBAL_ATTRIBUTE5    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE5%type,
           GLOBAL_ATTRIBUTE6    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE6%type,
           GLOBAL_ATTRIBUTE7    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE7%type,
           GLOBAL_ATTRIBUTE8    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE8%type,
           GLOBAL_ATTRIBUTE9    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE9%type,
           GLOBAL_ATTRIBUTE10    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE10%type,
           GLOBAL_ATTRIBUTE11    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE11%type,
           GLOBAL_ATTRIBUTE12    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE12%type,
           GLOBAL_ATTRIBUTE13    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE13%type,
           GLOBAL_ATTRIBUTE14    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE14%type,
           GLOBAL_ATTRIBUTE15    	AR_SYSTEM_PARAMETERS_ALL. GLOBAL_ATTRIBUTE15%type,
           GLOBAL_ATTRIBUTE16    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE16%type,
           GLOBAL_ATTRIBUTE17    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE17%type,
           GLOBAL_ATTRIBUTE18    	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE18%type,
           GLOBAL_ATTRIBUTE19     	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE19%type,
           GLOBAL_ATTRIBUTE20     	AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE20%type,
           GLOBAL_ATTRIBUTE_CATEGORY    AR_SYSTEM_PARAMETERS_ALL.GLOBAL_ATTRIBUTE_CATEGORY%TYPE,
           TAX_ROUNDING_ALLOW_OVERRIDE  AR_SYSTEM_PARAMETERS_ALL.TAX_ROUNDING_ALLOW_OVERRIDE%TYPE,
           RULE_SET_ID     		 AR_SYSTEM_PARAMETERS_ALL.RULE_SET_ID%type,
           TAX_USE_ACCOUNT_EXC_RATE_FLAG AR_SYSTEM_PARAMETERS_ALL.TAX_USE_ACCOUNT_EXC_RATE_FLAG%type,
           TAX_USE_SYSTEM_EXC_RATE_FLAG  AR_SYSTEM_PARAMETERS_ALL.TAX_USE_SYSTEM_EXC_RATE_FLAG%type,
           TAX_HIER_SITE_EXC_RATE     	AR_SYSTEM_PARAMETERS_ALL.TAX_HIER_SITE_EXC_RATE%type,
           TAX_HIER_CUST_EXC_RATE     	AR_SYSTEM_PARAMETERS_ALL. TAX_HIER_CUST_EXC_RATE%type,
           TAX_HIER_PROD_EXC_RATE     	AR_SYSTEM_PARAMETERS_ALL.TAX_HIER_PROD_EXC_RATE%type,
           TAX_HIER_ACCOUNT_EXC_RATE    AR_SYSTEM_PARAMETERS_ALL.TAX_HIER_ACCOUNT_EXC_RATE%type,
           TAX_HIER_SYSTEM_EXC_RATE     AR_SYSTEM_PARAMETERS_ALL. TAX_HIER_SYSTEM_EXC_RATE%type,
           TAX_DATABASE_VIEW_SET     	AR_SYSTEM_PARAMETERS_ALL. TAX_DATABASE_VIEW_SET%type,
           INCLUSIVE_TAX_USED     	AR_SYSTEM_PARAMETERS_ALL. INCLUSIVE_TAX_USED%type,
           CODE_COMBINATION_ID_ROUND    AR_SYSTEM_PARAMETERS_ALL. CODE_COMBINATION_ID_ROUNd%type,
           TRX_HEADER_LEVEL_ROUNDING    AR_SYSTEM_PARAMETERS_ALL.TRX_HEADER_LEVEL_ROUNDING%type,
           TRX_HEADER_ROUND_CCID     	AR_SYSTEM_PARAMETERS_ALL.TRX_HEADER_ROUND_CCID%type,
           FINCHRG_RECEIVABLES_TRX_ID   AR_SYSTEM_PARAMETERS_ALL.FINCHRG_RECEIVABLES_TRX_ID%type,
           SALES_TAX_GEOCODE     	AR_SYSTEM_PARAMETERS_ALL.SALES_TAX_GEOCODE%type,
           BILLS_RECEIVABLE_ENABLED_FLAG   AR_SYSTEM_PARAMETERS_ALL.BILLS_RECEIVABLE_ENABLED_FLAG%type,
           TA_INSTALLED_FLAG     	AR_SYSTEM_PARAMETERS_ALL.TA_INSTALLED_FLAG%type,
           REV_TRANSFER_CLEAR_CCID 	AR_SYSTEM_PARAMETERS_ALL.REV_TRANSFER_CLEAR_CCID%type,
           SALES_CREDIT_PCT_LIMIT  	AR_SYSTEM_PARAMETERS_ALL.SALES_CREDIT_PCT_LIMIT%TYPE);

 l_ar_sys_param_rec l_ar_sys_rec;

 CURSOR c_product_options (c_org_id         NUMBER,
                           c_application_id NUMBER) IS
 SELECT org_id,
        def_option_hier_1_code,
        def_option_hier_2_code,
        def_option_hier_3_code,
        def_option_hier_4_code,
        def_option_hier_5_code,
        def_option_hier_6_code,
        def_option_hier_7_code,
        home_country_default_flag,
        tax_classification_code,
        tax_method_code,
        inclusive_tax_used_flag,
        tax_use_customer_exempt_flag,
        tax_use_product_exempt_flag,
        tax_use_loc_exc_rate_flag,
        tax_allow_compound_flag,
        tax_rounding_rule,
        tax_precision,
        tax_minimum_accountable_unit,
        use_tax_classification_flag,
        allow_tax_rounding_ovrd_flag
   FROM zx_product_options_all
  WHERE org_id = c_org_id
    AND application_id = c_application_id;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.initialize.BEGIN',
                     'ZX_PRODUCT_INTEGRATION_PKG: initialize (+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
 -- l_debug_flag :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

 -- IF L_DEBUG_FLAG <> PG_DEBUG THEN
 --   FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Calling initialize ....');
 --   PG_DEBUG := l_debug_flag;
 -- END IF;

  ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (p_event_class_rec ,
                                           'HEADER',
                                           x_return_status
                                           );


  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','ZX_TDS_CALC_SERVICES_PUB_PKG.initialize returned errors');
     END IF;
     RETURN;
  END IF;


  IF (g_level_statement >= g_current_runtime_level) THEN
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','pg_application_short_name = '||pg_application_short_name);
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','pg_application_id = '||pg_application_id);
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','p_event_class_rec.application_id = '||p_event_class_rec.application_id);
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',SQLCODE||'  ;  '||SQLERRM);
  END IF;

  IF (pg_application_short_name IS NULL and pg_application_id IS NULL)
   OR p_event_class_rec.application_id <> pg_application_id
  THEN

    IF (g_level_statement >= g_current_runtime_level) THEN
     FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Getting application short name');
    END IF;

    OPEN c_application_short_name(p_event_class_rec.application_id);

    FETCH c_application_short_name into pg_application_short_name, pg_application_id;

    IF c_application_short_name%NOTFOUND THEN

      IF (g_level_event >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_event,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Error: application short name not found');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Application ID is invalid, please fix and try again');
      ZX_API_PUB.add_msg(
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

      IF ( g_level_unexpected >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.initialize',
                      'Application ID is invalid. '||
                      'No application short name found for the application id input.'
                      );
      END IF;
      RETURN;

    ELSE
         IF (g_level_statement >= g_current_runtime_level) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Application short name found. pg_application_short_name = '||pg_application_Short_name);
         END IF;

           IF MO_GLOBAL.is_multi_org_enabled = 'Y' THEN
              IF (g_level_statement >= g_current_runtime_level) THEN
                FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Multi-Org enabled');
              END IF;
           End if;

    END IF;

    CLOSE c_application_short_name;


  END IF;

    IF (g_level_statement >= g_current_runtime_level) THEN
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Calling MO_GLOBAL.is_multi_org_enabled');
    END IF;

  pg_application_short_name := 'AR';

  -- set up MOAC based on the passed in organization ID
  IF MO_GLOBAL.is_multi_org_enabled = 'Y' THEN

    IF (g_level_statement >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Multi-org Enabled');
    END IF;

    l_last_org_id := sysinfo.sysparam.org_id;

    -- Call intialization when no cache available or orgnation context changed
    IF l_last_org_id IS NULL
      OR l_last_org_id <> p_event_class_rec.internal_organization_id
    THEN

      IF (g_level_statement >= g_current_runtime_level) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','New OU. Calling initialize ...');
      END IF;

      --
      -- Get the profile values and call set_org_access API
      --
      fnd_profile.get('XLA_MO_SECURITY_PROFILE_LEVEL', l_security_profile_id);
      IF (g_level_procedure >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_procedure,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.initialize()',
                      'MO: Operating Unit=>'||p_event_class_rec.internal_organization_id||
                      ', MO: Security Profile=>'||l_security_profile_id||
                      ', p_appl_short_name=>'||pg_application_short_name);
      END IF;

      IF (g_level_statement >= g_current_runtime_level) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',' calling MO_GLOBAL.SET_ORG_ACCESS');
      END IF;

     -- Bug 5022934 the call to MO_GLOBAL is internally calling
     -- MO_GLOBAL.SET_POLICY_CONTEXT: p_access_mode=>M,p_org_id
     -- which is causing too many rows within AR. commenting out this call
     -- as org_access should already have been set by calling side.
     /*
      MO_GLOBAL.SET_ORG_ACCESS(
        p_event_class_rec.internal_organization_id,
        l_security_profile_id,
        pg_application_short_name
      );
     */

    END IF;

  --   arp_util_tax.initialize;


  ELSE -- Single Organization
    -- Call initalizations when no cache available

    IF (g_level_statement >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Multi-org NOT Enabled');
    END IF;

    IF sysinfo.sysparam.set_of_books_id IS NULL  THEN
  --     arp_util_tax.initialize;
         NULL;
    END IF;

  END IF; -- multi org is enabled

  --
  -- Get System Info
  --
  BEGIN

    -- bug fix 3142794 l_last_org_id := sysinfo.sysparam.org_id;
    trx_type_tbl.DELETE;

    /* bug fix 3142794 begin*/
    -- if the org_id has not changed, then do nothing, return.
    IF (sysinfo.sysparam.org_id is null and p_event_class_rec.internal_organization_id is NULL)
    THEN
         IF (g_level_statement >= g_current_runtime_level) THEN
           FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','sysinfo.sysparam.org_id is null as well as '||
             'p_event_class_rec.internal_organization_id is NULL ');
         END IF;
         return;
    ELSIF ( (sysinfo.sysparam.org_id is not null)
        and (sysinfo.sysparam.org_id = p_event_class_rec.internal_organization_id))
    THEN
         IF (g_level_statement >= g_current_runtime_level) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','sysinfo.sysparam.org_id is equal to '||
                      'p_event_class_rec.internal_organization_id: '||p_event_class_rec.internal_organization_id||
                      'Hence not performing initialization.');
         END IF;
        return;
    END IF;
    /* bug fix 3142794 end*/

    -- Populate global variable sysparam
    IF (g_level_statement >= g_current_runtime_level) THEN
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','No cache value available, Populate global'||
            ' variable sysparam from ar_system_parameters');
    END IF;

    -- Condition added for Bug#6893532
    -- Adding OM application Ids in the IF statement
    -- as for all OM related applications, AR tax setup (Product Options) are used.
    -- Order Management 660
    -- Order Capture    697
    -- Order Entry      300

    -- IF p_event_class_rec.application_id = 222 THEN
    IF p_event_class_rec.application_id IN (222, 300, 660, 697) THEN
       -- Fetch AR Application Product Options
       OPEN c_product_options (p_event_class_rec.internal_organization_id, 222);
       FETCH c_product_options
        INTO sysinfo.ar_product_options_rec.org_id,
             sysinfo.ar_product_options_rec.def_option_hier_1_code,
             sysinfo.ar_product_options_rec.def_option_hier_2_code,
             sysinfo.ar_product_options_rec.def_option_hier_3_code,
             sysinfo.ar_product_options_rec.def_option_hier_4_code,
             sysinfo.ar_product_options_rec.def_option_hier_5_code,
             sysinfo.ar_product_options_rec.def_option_hier_6_code,
             sysinfo.ar_product_options_rec.def_option_hier_7_code,
             sysinfo.ar_product_options_rec.home_country_default_flag,
             sysinfo.ar_product_options_rec.tax_classification_code,
             sysinfo.ar_product_options_rec.tax_method_code,
             sysinfo.ar_product_options_rec.inclusive_tax_used_flag,
             sysinfo.ar_product_options_rec.tax_use_customer_exempt_flag,
             sysinfo.ar_product_options_rec.tax_use_product_exempt_flag,
             sysinfo.ar_product_options_rec.tax_use_loc_exc_rate_flag,
             sysinfo.ar_product_options_rec.tax_allow_compound_flag,
             sysinfo.ar_product_options_rec.tax_rounding_rule,
             sysinfo.ar_product_options_rec.tax_precision,
             sysinfo.ar_product_options_rec.tax_minimum_accountable_unit,
             sysinfo.ar_product_options_rec.use_tax_classification_flag,
             sysinfo.ar_product_options_rec.allow_tax_rounding_ovrd_flag;
       CLOSE c_product_options;

       sysinfo.sysparam.TAX_METHOD
                    :=sysinfo.ar_product_options_rec.TAX_METHOD_CODE ;
       sysinfo.sysparam.ORG_ID
                    :=sysinfo.ar_product_options_rec.ORG_ID ;
       sysinfo.sysparam.INCLUSIVE_TAX_USED
                    :=sysinfo.ar_product_options_rec.INCLUSIVE_TAX_USED_FLAG ;
       sysinfo.sysparam.TAX_USE_CUSTOMER_EXEMPT_FLAG
                    :=sysinfo.ar_product_options_rec.TAX_USE_CUSTOMER_EXEMPT_FLAG ;
       sysinfo.sysparam.TAX_USE_PRODUCT_EXEMPT_FLAG
                    :=sysinfo.ar_product_options_rec.TAX_USE_PRODUCT_EXEMPT_FLAG ;
       sysinfo.sysparam.TAX_USE_LOC_EXC_RATE_FLAG
                    :=sysinfo.ar_product_options_rec.TAX_USE_LOC_EXC_RATE_FLAG ;
       sysinfo.sysparam.TAX_ALLOW_COMPOUND_FLAG
                    :=sysinfo.ar_product_options_rec.TAX_ALLOW_COMPOUND_FLAG ;
       sysinfo.sysparam.TAX_ROUNDING_RULE
                    :=sysinfo.ar_product_options_rec.TAX_ROUNDING_RULE ;
       sysinfo.sysparam.TAX_MINIMUM_ACCOUNTABLE_UNIT
                    :=sysinfo.ar_product_options_rec.TAX_MINIMUM_ACCOUNTABLE_UNIT ;
       sysinfo.sysparam.TAX_PRECISION
                    :=sysinfo.ar_product_options_rec.TAX_PRECISION ;
       sysinfo.sysparam.TAX_ROUNDING_ALLOW_OVERRIDE
                    := sysinfo.ar_product_options_rec.ALLOW_TAX_ROUNDING_OVRD_FLAG;

    ELSIF p_event_class_rec.application_id = 275 THEN
       -- Fetch PA Application Product Options
       -- OPEN c_product_options (to_number(substrb(userenv('CLIENT_INFO'),1,10)), 275);  -- Commented for Bug#6893532
       OPEN c_product_options (p_event_class_rec.internal_organization_id, 275);  -- Added for Bug#6893532
       FETCH c_product_options
        INTO sysinfo.pa_product_options_rec.org_id,
             sysinfo.pa_product_options_rec.def_option_hier_1_code,
             sysinfo.pa_product_options_rec.def_option_hier_2_code,
             sysinfo.pa_product_options_rec.def_option_hier_3_code,
             sysinfo.pa_product_options_rec.def_option_hier_4_code,
             sysinfo.pa_product_options_rec.def_option_hier_5_code,
             sysinfo.pa_product_options_rec.def_option_hier_6_code,
             sysinfo.pa_product_options_rec.def_option_hier_7_code,
             sysinfo.pa_product_options_rec.home_country_default_flag,
             sysinfo.pa_product_options_rec.tax_classification_code,
             sysinfo.pa_product_options_rec.tax_method_code,
             sysinfo.pa_product_options_rec.inclusive_tax_used_flag,
             sysinfo.pa_product_options_rec.tax_use_customer_exempt_flag,
             sysinfo.pa_product_options_rec.tax_use_product_exempt_flag,
             sysinfo.pa_product_options_rec.tax_use_loc_exc_rate_flag,
             sysinfo.pa_product_options_rec.tax_allow_compound_flag,
             sysinfo.pa_product_options_rec.tax_rounding_rule,
             sysinfo.pa_product_options_rec.tax_precision,
             sysinfo.pa_product_options_rec.tax_minimum_accountable_unit,
             sysinfo.pa_product_options_rec.use_tax_classification_flag,
             sysinfo.pa_product_options_rec.allow_tax_rounding_ovrd_flag;
       CLOSE c_product_options;

       sysinfo.sysparam.TAX_METHOD
                    :=sysinfo.pa_product_options_rec.TAX_METHOD_CODE ;
       sysinfo.sysparam.ORG_ID
                    :=sysinfo.pa_product_options_rec.ORG_ID ;
       sysinfo.sysparam.INCLUSIVE_TAX_USED
                    :=sysinfo.pa_product_options_rec.INCLUSIVE_TAX_USED_FLAG ;
       sysinfo.sysparam.TAX_USE_CUSTOMER_EXEMPT_FLAG
                    :=sysinfo.pa_product_options_rec.TAX_USE_CUSTOMER_EXEMPT_FLAG ;
       sysinfo.sysparam.TAX_USE_PRODUCT_EXEMPT_FLAG
                    :=sysinfo.pa_product_options_rec.TAX_USE_PRODUCT_EXEMPT_FLAG ;
       sysinfo.sysparam.TAX_USE_LOC_EXC_RATE_FLAG
                    :=sysinfo.pa_product_options_rec.TAX_USE_LOC_EXC_RATE_FLAG ;
       sysinfo.sysparam.TAX_ALLOW_COMPOUND_FLAG
                    :=sysinfo.pa_product_options_rec.TAX_ALLOW_COMPOUND_FLAG ;
       sysinfo.sysparam.TAX_ROUNDING_RULE
                    :=sysinfo.pa_product_options_rec.TAX_ROUNDING_RULE ;
       sysinfo.sysparam.TAX_MINIMUM_ACCOUNTABLE_UNIT
                    :=sysinfo.pa_product_options_rec.TAX_MINIMUM_ACCOUNTABLE_UNIT ;
       sysinfo.sysparam.TAX_PRECISION
                    :=sysinfo.pa_product_options_rec.TAX_PRECISION ;
       sysinfo.sysparam.TAX_ROUNDING_ALLOW_OVERRIDE
                    := sysinfo.pa_product_options_rec.ALLOW_TAX_ROUNDING_OVRD_FLAG;

    END IF;  -- End : Condition added for BUg#6893532

   IF (g_level_statement >= g_current_runtime_level) THEN
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','sysinfo.sysparam.TAX_METHOD = '||sysinfo.sysparam.TAX_METHOD);
   END IF;

 /*
sysinfo.sysparam.LOCATION_TAX_ACCOUNT :=sysinfo.ar_product_options_rec.LOCATION_TAX_ACCOUNT ;
sysinfo.sysparam.DEFAULT_COUNTRY :=sysinfo.ar_product_options_rec.DEFAULT_COUNTRY ;
sysinfo.sysparam.TAX_USE_CUST_EXC_RATE_FLAG :=sysinfo.ar_product_options_rec.TAX_USE_CUST_EXC_RATE_FLAG ;
sysinfo.sysparam.TAX_USE_PROD_EXC_RATE_FLAG :=sysinfo.ar_product_options_rec.TAX_USE_PROD_EXC_RATE_FLAG ;
sysinfo.sysparam.TAX_USE_SITE_EXC_RATE_FLAG:=sysinfo.ar_product_options_rec.TAX_USE_SITE_EXC_RATE_FLAG ;
sysinfo.sysparam.SET_OF_BOOKS_ID :=sysinfo.ar_product_options_rec.SET_OF_BOOKS_ID ;
sysinfo.sysparam.TAX_CODE :=sysinfo.ar_product_options_rec.TAX_CODE ;
sysinfo.sysparam.TAX_CURRENCY_CODE :=sysinfo.ar_product_options_rec.TAX_CURRENCY_CODE ;
sysinfo.sysparam.TAX_HEADER_LEVEL_FLAG:=sysinfo.ar_product_options_rec.TAX_HEADER_LEVEL_FLAG ;
sysinfo.sysparam.GLOBAL_ATTRIBUTE10 :=sysinfo.ar_product_options_rec.GLOBAL_ATTRIBUTE10 ;
sysinfo.sysparam.GLOBAL_ATTRIBUTE13 :=sysinfo.ar_product_options_rec.GLOBAL_ATTRIBUTE13 ;
sysinfo.sysparam.GLOBAL_ATTRIBUTE_CATEGORY :=sysinfo.ar_product_options_rec.GLOBAL_ATTRIBUTE_CATEGORY ;
sysinfo.sysparam.TAX_ROUNDING_ALLOW_OVERRIDE :=sysinfo.ar_product_options_rec.TAX_ROUNDING_ALLOW_OVERRIDE ;
sysinfo.sysparam.TAX_USE_ACCOUNT_EXC_RATE_FLAG :=sysinfo.ar_product_options_rec.TAX_USE_ACCOUNT_EXC_RATE_FLAG ;
sysinfo.sysparam.TAX_USE_SYSTEM_EXC_RATE_FLAG :=sysinfo.ar_product_options_rec.TAX_USE_SYSTEM_EXC_RATE_FLAG ;
sysinfo.TAX_HIER_SITE_EXC_RATE :=sysinfo.ar_product_options_rec.TAX_HIER_SITE_EXC_RATE ;
sysinfo.sysparam.TAX_HIER_CUST_EXC_RATE :=sysinfo.ar_product_options_rec.TAX_HIER_CUST_EXC_RATE ;
sysinfo.sysparam.TAX_HIER_PROD_EXC_RATE :=sysinfo.ar_product_options_rec.TAX_HIER_PROD_EXC_RATE ;
sysinfo.TAX_HIER_ACCOUNT_EXC_RATE :=sysinfo.ar_product_options_rec.TAX_HIER_ACCOUNT_EXC_RATE ;
sysinfo.sysparam.TAX_HIER_SYSTEM_EXC_RATE :=sysinfo.ar_product_options_rec.TAX_HIER_SYSTEM_EXC_RATE ;
  */

  /* Take the following columns from Event Class Options:
      Enforce tax from Revenue Account
      Calculation level - 'LINE' for LTE
  */

    begin

       SELECT
           DEFAULT_GROUPING_RULE_ID ,
           SALESREP_REQUIRED_FLAG ,
           ATTRIBUTE11 ,
           ATTRIBUTE12 ,
           ATTRIBUTE13 ,
           ATTRIBUTE14 ,
           ATTRIBUTE15 ,
           AUTO_REC_INVOICES_PER_COMMIT ,
           AUTO_REC_RECEIPTS_PER_COMMIT ,
          PAY_UNRELATED_INVOICES_FLAG, -- TAX_CACHE
          PRINT_HOME_COUNTRY_FLAG ,
          LOCATION_TAX_ACCOUNT ,
          FROM_POSTAL_CODE ,
          TO_POSTAL_CODE ,
          TAX_REGISTRATION_NUMBER ,
          POPULATE_GL_SEGMENTS_FLAG ,
          UNALLOCATED_REVENUE_CCID ,
          ORG_ID ,
          ATTRIBUTE9 ,
          ATTRIBUTE10 ,
          CALC_DISCOUNT_ON_LINES_FLAG ,
           CHANGE_PRINTED_INVOICE_FLAG ,
           CODE_COMBINATION_ID_LOSS ,
           CREATE_RECIPROCAL_FLAG ,
           DEFAULT_COUNTRY ,
           DEFAULT_TERRITORY ,
           GENERATE_CUSTOMER_NUMBER ,
           INVOICE_DELETION_FLAG ,
           LOCATION_STRUCTURE_ID ,
           SITE_REQUIRED_FLAG ,
           TAX_ALLOW_COMPOUND_FLAG ,
           TAX_INVOICE_PRINT ,
           TAX_METHOD ,
           TAX_USE_CUSTOMER_EXEMPT_FLAG ,
           TAX_USE_CUST_EXC_RATE_FLAG ,
           TAX_USE_LOC_EXC_RATE_FLAG ,
           TAX_USE_PRODUCT_EXEMPT_FLAG ,
           TAX_USE_PROD_EXC_RATE_FLAG ,
           TAX_USE_SITE_EXC_RATE_FLAG ,
           AI_LOG_FILE_MESSAGE_LEVEL ,
           AI_MAX_MEMORY_IN_BYTES ,
           AI_ACCT_FLEX_KEY_LEFT_PROMPT ,
           AI_MTL_ITEMS_KEY_LEFT_PROMPT ,
           AI_TERRITORY_KEY_LEFT_PROMPT ,
           AI_PURGE_INTERFACE_TABLES_FLAG ,
           AI_ACTIVATE_SQL_TRACE_FLAG ,
           SET_OF_BOOKS_ID ,
           CREATED_BY ,
           CREATION_DATE ,
           LAST_UPDATED_BY ,
           LAST_UPDATE_DATE ,
           LAST_UPDATE_LOGIN ,
           ACCOUNTING_METHOD ,
           ACCRUE_INTEREST ,
           UNEARNED_DISCOUNT ,
           PARTIAL_DISCOUNT_FLAG ,
           PRINT_REMIT_TO ,
           DEFAULT_CB_DUE_DATE ,
           AUTO_SITE_NUMBERING ,
           CASH_BASIS_SET_OF_BOOKS_ID ,
           CODE_COMBINATION_ID_GAIN ,
           AUTOCASH_HIERARCHY_ID ,
           RUN_GL_JOURNAL_IMPORT_FLAG ,
           CER_SPLIT_AMOUNT ,
           CER_DSO_DAYS ,
           POSTING_DAYS_PER_CYCLE ,
           ADDRESS_VALIDATION ,
           ATTRIBUTE1 ,
           ATTRIBUTE2 ,
           ATTRIBUTE_CATEGORY ,
           ATTRIBUTE3 ,
           ATTRIBUTE4 ,
           ATTRIBUTE5 ,
           ATTRIBUTE6 ,
           ATTRIBUTE7 ,
           ATTRIBUTE8 ,
           TAX_CODE ,
           TAX_CURRENCY_CODE ,
           TAX_HEADER_LEVEL_FLAG ,
           TAX_MINIMUM_ACCOUNTABLE_UNIT ,
           TAX_PRECISION ,
           TAX_ROUNDING_RULE ,
           GLOBAL_ATTRIBUTE1 ,
           GLOBAL_ATTRIBUTE2 ,
           GLOBAL_ATTRIBUTE3 ,
           GLOBAL_ATTRIBUTE4 ,
           GLOBAL_ATTRIBUTE5 ,
           GLOBAL_ATTRIBUTE6 ,
           GLOBAL_ATTRIBUTE7 ,
           GLOBAL_ATTRIBUTE8 ,
           GLOBAL_ATTRIBUTE9 ,
           GLOBAL_ATTRIBUTE10 ,
           GLOBAL_ATTRIBUTE11 ,
           GLOBAL_ATTRIBUTE12 ,
           GLOBAL_ATTRIBUTE13 ,
           GLOBAL_ATTRIBUTE14 ,
           GLOBAL_ATTRIBUTE15 ,
           GLOBAL_ATTRIBUTE16 ,
           GLOBAL_ATTRIBUTE17 ,
           GLOBAL_ATTRIBUTE18 ,
           GLOBAL_ATTRIBUTE19 ,
           GLOBAL_ATTRIBUTE20 ,
           GLOBAL_ATTRIBUTE_CATEGORY ,
           TAX_ROUNDING_ALLOW_OVERRIDE ,
           RULE_SET_ID ,
           TAX_USE_ACCOUNT_EXC_RATE_FLAG ,
           TAX_USE_SYSTEM_EXC_RATE_FLAG ,
           TAX_HIER_SITE_EXC_RATE ,
           TAX_HIER_CUST_EXC_RATE ,
           TAX_HIER_PROD_EXC_RATE ,
           TAX_HIER_ACCOUNT_EXC_RATE ,
           TAX_HIER_SYSTEM_EXC_RATE ,
           TAX_DATABASE_VIEW_SET ,
           INCLUSIVE_TAX_USED ,
           CODE_COMBINATION_ID_ROUND ,
           TRX_HEADER_LEVEL_ROUNDING ,
           TRX_HEADER_ROUND_CCID ,
           FINCHRG_RECEIVABLES_TRX_ID ,
           SALES_TAX_GEOCODE ,
           BILLS_RECEIVABLE_ENABLED_FLAG ,
           TA_INSTALLED_FLAG ,
           REV_TRANSFER_CLEAR_CCID ,
           SALES_CREDIT_PCT_LIMIT
           --MAX_WRTOFF_AMOUNT ,
           --IREC_CC_RECEIPT_METHOD_ID ,
           --SHOW_BILLING_NUMBER_FLAG ,
           --CROSS_CURRENCY_RATE_TYPE ,
           --DOCUMENT_SEQ_GEN_LEVEL ,
           --CALC_TAX_ON_CREDIT_MEMO_FLAG ,
           --IREC_BA_RECEIPT_METHOD_ID
      into l_ar_sys_param_rec from ar_system_parameters_all
      where org_id = p_event_class_rec.internal_organization_id;

--           sysinfo.sysparam.DEFAULT_GROUPING_RULE_ID :=l_ar_sys_param_rec.DEFAULT_GROUPING_RULE_ID ;
--           sysinfo.sysparam.SALESREP_REQUIRED_FLAG :=l_ar_sys_param_rec.SALESREP_REQUIRED_FLAG ;
           sysinfo.sysparam.ATTRIBUTE11	:=l_ar_sys_param_rec.ATTRIBUTE11 ;
           sysinfo.sysparam.ATTRIBUTE12:=l_ar_sys_param_rec.ATTRIBUTE12 ;
           sysinfo.sysparam.ATTRIBUTE13 :=l_ar_sys_param_rec.ATTRIBUTE13 ;
           sysinfo.sysparam.ATTRIBUTE14 :=l_ar_sys_param_rec.ATTRIBUTE14 ;
           sysinfo.sysparam.ATTRIBUTE15 :=l_ar_sys_param_rec.ATTRIBUTE15 ;
--           sysinfo.sysparam.AUTO_REC_INVOICES_PER_COMMIT :=l_ar_sys_param_rec.AUTO_REC_INVOICES_PER_COMMIT ;
--           sysinfo.sysparam.AUTO_REC_RECEIPTS_PER_COMMIT :=l_ar_sys_param_rec.AUTO_REC_RECEIPTS_PER_COMMIT ;
--           sysinfo.sysparam.PAY_UNRELATED_INVOICES_FLAG :=l_ar_sys_param_rec.PAY_UNRELATED_INVOICES_FLAG  ;
--           sysinfo.sysparam.PRINT_HOME_COUNTRY_FLAG :=l_ar_sys_param_rec.PRINT_HOME_COUNTRY_FLAG ;
           sysinfo.sysparam.LOCATION_TAX_ACCOUNT :=l_ar_sys_param_rec.LOCATION_TAX_ACCOUNT ;
           sysinfo.sysparam.FROM_POSTAL_CODE :=l_ar_sys_param_rec.FROM_POSTAL_CODE ;
           sysinfo.sysparam.TO_POSTAL_CODE :=l_ar_sys_param_rec.TO_POSTAL_CODE ;
--           sysinfo.sysparam.TAX_REGISTRATION_NUMBER :=l_ar_sys_param_rec. TAX_REGISTRATION_NUMBER ;
--           sysinfo.sysparam.POPULATE_GL_SEGMENTS_FLAG :=l_ar_sys_param_rec.POPULATE_GL_SEGMENTS_FLAG ;
--           sysinfo.sysparam.UNALLOCATED_REVENUE_CCID :=l_ar_sys_param_rec.UNALLOCATED_REVENUE_CCID ;
           sysinfo.sysparam.ORG_ID :=l_ar_sys_param_rec.ORG_ID ;
           sysinfo.sysparam.ATTRIBUTE9 :=l_ar_sys_param_rec.ATTRIBUTE9 ;
           sysinfo.sysparam.ATTRIBUTE10 :=l_ar_sys_param_rec.ATTRIBUTE10 ;
--           sysinfo.sysparam.CALC_DISCOUNT_ON_LINES_FLAG :=l_ar_sys_param_rec.CALC_DISCOUNT_ON_LINES_FLAG ;
--           sysinfo.sysparam.CHANGE_PRINTED_INVOICE_FLAG :=l_ar_sys_param_rec.CHANGE_PRINTED_INVOICE_FLAG ;
--           sysinfo.sysparam.CODE_COMBINATION_ID_LOSS:=l_ar_sys_param_rec. CODE_COMBINATION_ID_LOSS ;
--          sysinfo.sysparam.CREATE_RECIPROCAL_FLAG :=l_ar_sys_param_rec.CREATE_RECIPROCAL_FLAG ;
           sysinfo.sysparam.DEFAULT_COUNTRY :=l_ar_sys_param_rec.DEFAULT_COUNTRY ;
--           sysinfo.sysparam.DEFAULT_TERRITORY :=l_ar_sys_param_rec.DEFAULT_TERRITORY ;
--           sysinfo.sysparam.GENERATE_CUSTOMER_NUMBER :=l_ar_sys_param_rec.GENERATE_CUSTOMER_NUMBER ;
--           sysinfo.sysparam.INVOICE_DELETION_FLAG :=l_ar_sys_param_rec.INVOICE_DELETION_FLAG ;
           sysinfo.sysparam.LOCATION_STRUCTURE_ID :=l_ar_sys_param_rec.LOCATION_STRUCTURE_ID ;
--           sysinfo.sysparam.SITE_REQUIRED_FLAG :=l_ar_sys_param_rec.SITE_REQUIRED_FLAG ;
--           sysinfo.sysparam.TAX_ALLOW_COMPOUND_FLAG :=l_ar_sys_param_rec.TAX_ALLOW_COMPOUND_FLAG ;
           sysinfo.sysparam. TAX_INVOICE_PRINT:=l_ar_sys_param_rec.TAX_INVOICE_PRINT ;
--           sysinfo.sysparam.TAX_METHOD :=l_ar_sys_param_rec.TAX_METHOD ;
--           sysinfo.sysparam.TAX_USE_CUSTOMER_EXEMPT_FLAG :=l_ar_sys_param_rec.TAX_USE_CUSTOMER_EXEMPT_FLAG ;
--           sysinfo.sysparam.TAX_USE_CUST_EXC_RATE_FLAG :=l_ar_sys_param_rec.TAX_USE_CUST_EXC_RATE_FLAG ;
           sysinfo.sysparam.TAX_USE_LOC_EXC_RATE_FLAG :=l_ar_sys_param_rec.TAX_USE_LOC_EXC_RATE_FLAG ;
--           sysinfo.sysparam.TAX_USE_PRODUCT_EXEMPT_FLAG:=l_ar_sys_param_rec.TAX_USE_PRODUCT_EXEMPT_FLAG ;
           sysinfo.sysparam.TAX_USE_PROD_EXC_RATE_FLAG :=l_ar_sys_param_rec.TAX_USE_PROD_EXC_RATE_FLAG ;
           sysinfo.sysparam.TAX_USE_SITE_EXC_RATE_FLAG:=l_ar_sys_param_rec.TAX_USE_SITE_EXC_RATE_FLAG ;
--           sysinfo.sysparam.AI_LOG_FILE_MESSAGE_LEVEL :=l_ar_sys_param_rec.AI_LOG_FILE_MESSAGE_LEVEL ;
--           sysinfo.sysparam.AI_MAX_MEMORY_IN_BYTES :=l_ar_sys_param_rec.AI_MAX_MEMORY_IN_BYTES ;
--           sysinfo.sysparam.AI_ACCT_FLEX_KEY_LEFT_PROMPT :=l_ar_sys_param_rec.AI_ACCT_FLEX_KEY_LEFT_PROMPT ;
--           sysinfo.sysparam.AI_MTL_ITEMS_KEY_LEFT_PROMPT :=l_ar_sys_param_rec.AI_MTL_ITEMS_KEY_LEFT_PROMPT ;
--           sysinfo.sysparam.AI_TERRITORY_KEY_LEFT_PROMPT :=l_ar_sys_param_rec.AI_TERRITORY_KEY_LEFT_PROMPT ;
--           sysinfo.sysparam.AI_PURGE_INTERFACE_TABLES_FLAG :=l_ar_sys_param_rec.AI_PURGE_INTERFACE_TABLES_FLAG ;
--           sysinfo.sysparam.AI_ACTIVATE_SQL_TRACE_FLAG :=l_ar_sys_param_rec.AI_ACTIVATE_SQL_TRACE_FLAG ;
           sysinfo.sysparam.SET_OF_BOOKS_ID :=l_ar_sys_param_rec.SET_OF_BOOKS_ID ;
--           sysinfo.sysparam.CREATED_BY :=l_ar_sys_param_rec.CREATED_BY ;
--           sysinfo.sysparam.CREATION_DATE :=l_ar_sys_param_rec.CREATION_DATE ;
--           sysinfo.sysparam.LAST_UPDATED_BY :=l_ar_sys_param_rec.LAST_UPDATED_BY ;
--           sysinfo.sysparam.LAST_UPDATE_DATE :=l_ar_sys_param_rec. LAST_UPDATE_DATE ;
--           sysinfo.sysparam.LAST_UPDATE_LOGIN :=l_ar_sys_param_rec.LAST_UPDATE_LOGIN ;
--           sysinfo.sysparam.ACCOUNTING_METHOD :=l_ar_sys_param_rec.ACCOUNTING_METHOD ;
--           sysinfo.sysparam.ACCRUE_INTEREST :=l_ar_sys_param_rec.ACCRUE_INTEREST ;
--           sysinfo.sysparam.UNEARNED_DISCOUNT :=l_ar_sys_param_rec.UNEARNED_DISCOUNT ;
--           sysinfo.sysparam.PARTIAL_DISCOUNT_FLAG :=l_ar_sys_param_rec.PARTIAL_DISCOUNT_FLAG ;
--           sysinfo.sysparam.PRINT_REMIT_TO :=l_ar_sys_param_rec.PRINT_REMIT_TO ;
--           sysinfo.sysparam.DEFAULT_CB_DUE_DATE :=l_ar_sys_param_rec.DEFAULT_CB_DUE_DATE ;
--           sysinfo.sysparam.AUTO_SITE_NUMBERING :=l_ar_sys_param_rec.AUTO_SITE_NUMBERING ;
--           sysinfo.sysparam.CASH_BASIS_SET_OF_BOOKS_ID :=l_ar_sys_param_rec.CASH_BASIS_SET_OF_BOOKS_ID ;
--           sysinfo.sysparam.CODE_COMBINATION_ID_GAIN :=l_ar_sys_param_rec.CODE_COMBINATION_ID_GAIN ;
--           sysinfo.sysparam.AUTOCASH_HIERARCHY_ID :=l_ar_sys_param_rec.AUTOCASH_HIERARCHY_ID ;
--           sysinfo.sysparam.RUN_GL_JOURNAL_IMPORT_FLAG:=l_ar_sys_param_rec.RUN_GL_JOURNAL_IMPORT_FLAG ;
--           sysinfo.sysparam.CER_SPLIT_AMOUNT :=l_ar_sys_param_rec.CER_SPLIT_AMOUNT ;
--           sysinfo.sysparam.CER_DSO_DAYS :=l_ar_sys_param_rec.  CER_DSO_DAYS ;
--           sysinfo.sysparam.POSTING_DAYS_PER_CYCLE :=l_ar_sys_param_rec.POSTING_DAYS_PER_CYCLE ;
           sysinfo.sysparam.ADDRESS_VALIDATION:=l_ar_sys_param_rec.ADDRESS_VALIDATION ;
           sysinfo.sysparam.ATTRIBUTE1 :=l_ar_sys_param_rec.ATTRIBUTE1 ;
           sysinfo.sysparam.ATTRIBUTE2 :=l_ar_sys_param_rec.ATTRIBUTE2 ;
           sysinfo.sysparam.ATTRIBUTE_CATEGORY :=l_ar_sys_param_rec.ATTRIBUTE_CATEGORY ;
           sysinfo.sysparam.ATTRIBUTE3 :=l_ar_sys_param_rec.ATTRIBUTE3 ;
           sysinfo.sysparam.ATTRIBUTE4 :=l_ar_sys_param_rec.ATTRIBUTE4 ;
           sysinfo.sysparam.ATTRIBUTE5  :=l_ar_sys_param_rec.ATTRIBUTE5 ;
           sysinfo.sysparam.ATTRIBUTE6 :=l_ar_sys_param_rec.ATTRIBUTE6 ;
           sysinfo.sysparam.ATTRIBUTE7 :=l_ar_sys_param_rec.ATTRIBUTE7 ;
           sysinfo.sysparam.ATTRIBUTE8 :=l_ar_sys_param_rec.ATTRIBUTE8 ;
           sysinfo.sysparam.TAX_CODE :=l_ar_sys_param_rec.TAX_CODE ;
--           sysinfo.sysparam.TAX_CURRENCY_CODE :=l_ar_sys_param_rec.TAX_CURRENCY_CODE ;
--           sysinfo.sysparam.TAX_HEADER_LEVEL_FLAG:=l_ar_sys_param_rec.TAX_HEADER_LEVEL_FLAG ;
--           sysinfo.sysparam.TAX_MINIMUM_ACCOUNTABLE_UNIT :=l_ar_sys_param_rec.TAX_MINIMUM_ACCOUNTABLE_UNIT ;
--           sysinfo.sysparam.TAX_PRECISION :=l_ar_sys_param_rec.TAX_PRECISION ;
--           sysinfo.sysparam.TAX_ROUNDING_RULE :=l_ar_sys_param_rec.TAX_ROUNDING_RULE ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE1 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE1 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE2 :=l_ar_sys_param_rec. GLOBAL_ATTRIBUTE2 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE3 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE3 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE4 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE4 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE5 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE5 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE6 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE6 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE7 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE7 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE8 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE8 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE9 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE9 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE10 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE10 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE11 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE11 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE12 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE12 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE13 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE13 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE14 :=l_ar_sys_param_rec. GLOBAL_ATTRIBUTE14 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE15 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE15 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE16 :=l_ar_sys_param_rec. GLOBAL_ATTRIBUTE16 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE17 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE17 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE18 :=l_ar_sys_param_rec. GLOBAL_ATTRIBUTE18 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE19 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE19 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE20 :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE20 ;
           sysinfo.sysparam.GLOBAL_ATTRIBUTE_CATEGORY :=l_ar_sys_param_rec.GLOBAL_ATTRIBUTE_CATEGORY ;
           sysinfo.sysparam.TAX_ROUNDING_ALLOW_OVERRIDE :=l_ar_sys_param_rec.TAX_ROUNDING_ALLOW_OVERRIDE ;
           sysinfo.sysparam.RULE_SET_ID :=l_ar_sys_param_rec. RULE_SET_ID ;
           sysinfo.sysparam.TAX_USE_ACCOUNT_EXC_RATE_FLAG :=l_ar_sys_param_rec.TAX_USE_ACCOUNT_EXC_RATE_FLAG ;
           sysinfo.sysparam.TAX_USE_SYSTEM_EXC_RATE_FLAG :=l_ar_sys_param_rec.TAX_USE_SYSTEM_EXC_RATE_FLAG ;
--           sysinfo.sysparam.TAX_HIER_SITE_EXC_RATE :=l_ar_sys_param_rec.TAX_HIER_SITE_EXC_RATE ;
--           sysinfo.sysparam.TAX_HIER_CUST_EXC_RATE :=l_ar_sys_param_rec.TAX_HIER_CUST_EXC_RATE ;
--           sysinfo.sysparam.TAX_HIER_PROD_EXC_RATE :=l_ar_sys_param_rec.TAX_HIER_PROD_EXC_RATE ;
--           sysinfo.sysparam.TAX_HIER_ACCOUNT_EXC_RATE :=l_ar_sys_param_rec.TAX_HIER_ACCOUNT_EXC_RATE ;
--           sysinfo.sysparam.TAX_HIER_SYSTEM_EXC_RATE :=l_ar_sys_param_rec.TAX_HIER_SYSTEM_EXC_RATE ;
           sysinfo.sysparam.TAX_DATABASE_VIEW_SET :=l_ar_sys_param_rec.TAX_DATABASE_VIEW_SET ;
           sysinfo.sysparam.INCLUSIVE_TAX_USED :=l_ar_sys_param_rec.INCLUSIVE_TAX_USED ;
--           sysinfo.sysparam.CODE_COMBINATION_ID_ROUND :=l_ar_sys_param_rec.CODE_COMBINATION_ID_ROUND ;
--           sysinfo.sysparam.TRX_HEADER_LEVEL_ROUNDING :=l_ar_sys_param_rec.TRX_HEADER_LEVEL_ROUNDING ;
--           sysinfo.sysparam.TRX_HEADER_ROUND_CCID :=l_ar_sys_param_rec.  TRX_HEADER_ROUND_CCID ;
--           sysinfo.sysparam.FINCHRG_RECEIVABLES_TRX_ID :=l_ar_sys_param_rec. FINCHRG_RECEIVABLES_TRX_ID ;
--           sysinfo.sysparam.SALES_TAX_GEOCODE :=l_ar_sys_param_rec. SALES_TAX_GEOCODE ;
--           sysinfo.sysparam.BILLS_RECEIVABLE_ENABLED_FLAG :=l_ar_sys_param_rec.  BILLS_RECEIVABLE_ENABLED_FLAG ;
--           sysinfo.sysparam.TA_INSTALLED_FLAG :=l_ar_sys_param_rec.TA_INSTALLED_FLAG ;
--           sysinfo.sysparam.REV_TRANSFER_CLEAR_CCID :=l_ar_sys_param_rec. REV_TRANSFER_CLEAR_CCID ;
--           sysinfo.sysparam.SALES_CREDIT_PCT_LIMIT :=l_ar_sys_param_rec. SALES_CREDIT_PCT_LIMIT;
    exception when no_data_found then
       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','EXCEPTION: NO_DATA_FOUND IN SYSTEM PARAMETERS  ' );
       END IF;
       FND_MESSAGE.set_name('AR','AR_NO_ROW_IN_SYSTEM_PARAMETERS');
       APP_EXCEPTION.raise_exception;
       RAISE;
    end;


   /* bug fix 3142794
    -- if the org_id has not changed, then do nothing, return.
    IF l_last_org_id = sysinfo.sysparam.org_id THEN
        return;
    END IF;
    */

   -- pg_i := 0;

    --tax_info_rec.DELETE;
    --tax_gbl_rec.DELETE;
    --tax_rec_tbl.DELETE;
    --tax_info_rec_tbl.DELETE;
    --old_line_rec.DELETE;
    --new_line_rec.DELETE;

    BEGIN
      SELECT sob.chart_of_accounts_id,
             sob.currency_code,
             c.precision,
             c.minimum_accountable_unit
      INTO   l_chart_of_accounts_id,
             l_functional_currency,
             l_base_precision,
             l_base_min_acc_unit
      FROM   gl_sets_of_books sob, fnd_currencies c
      WHERE  sob.set_of_books_id = sysinfo.sysparam.set_of_books_id
      AND    sob.currency_code = c.currency_code;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       -- test for reasons why failure occured
       begin  --  Test 1: Check row exists in gl sets of books
           select  sob.set_of_books_id
           into    l_sob_test
           from    gl_sets_of_books sob
           where   sob.set_of_books_id = sysinfo.sysparam.set_of_books_id;
       exception when no_data_found then
           IF (g_level_statement >= g_current_runtime_level) THEN
           	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','EXCEPTION: NO_DATA_FOUND IN SET OF BOOKS ' );
           END IF;
           FND_MESSAGE.set_name('AR','AR_NO_ROW_IN_GL_SET_OF_BOOKS');
           APP_EXCEPTION.raise_exception;
           RAISE;
       end;

       -- Test 1 passed therefore currency must not be defined
       IF (g_level_statement >= g_current_runtime_level) THEN
       	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','EXCEPTION: NO_DATA_FOUND IN CURRENCIES ' );
       END IF;
       FND_MESSAGE.set_name('AR','AR_NO_ROW_IN_FND_CURRENCIES');
       APP_EXCEPTION.raise_exception;
       RAISE; --end of WHEN NO DATA FOUND
   END;


	sysinfo.chart_of_accounts_id	:= l_chart_of_accounts_id;
	sysinfo.base_precision		:= l_base_precision;
	sysinfo.min_accountable_unit	:= l_base_min_acc_unit;

	sysinfo.func_precision		:= sysinfo.base_precision;
	sysinfo.base_currency_code      := l_functional_currency;

/*      nipatel added for eTax uptake;
        It is enforced in System Options form that tax currency code should
        be the same as functional currency   */

	If sysinfo.sysparam.tax_precision is not NULL OR
	   sysinfo.sysparam.tax_minimum_accountable_unit is NOT NULL
	then
	   sysinfo.sysparam.tax_currency_code := sysinfo.base_currency_code;
	end if;

/* nipatel sysinfo.tax_view_Set is obsolete after eTax uptake
	IF nvl(sysinfo.sysparam.tax_database_view_set, 'O') = 'O' THEN
		sysinfo.tax_view_set := NULL;	-- Oracle tax views
	ELSE
		sysinfo.tax_view_set := sysinfo.sysparam.tax_database_view_set;
	END IF;
*/

	-- allow multiple inclusive
	-- only for Latin America tax method.
	if (sysinfo.sysparam.tax_method = MTHD_LATIN) then
		sysinfo.allow_multiple_inclusive := 'Y';
	else
		sysinfo.allow_multiple_inclusive := 'N';
	end if;

  EXCEPTION
    WHEN OTHERS THEN
	IF (g_level_statement >= g_current_runtime_level) THEN
		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Error Getting system information');
	END IF;
 	RAISE;
  END; -- Get System info


  --
  -- Get Profile Info
  --
  -- bug 5120920 - use oe_sys_parameters.value();
  l_master_org_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID', p_event_class_rec.internal_organization_id);

  If l_master_org_id is NULL then
           IF (g_level_unexpected  >= g_current_runtime_level ) THEN
           	FND_LOG.STRING(g_level_unexpected,
                               'ZX.PLSQL.ZX_AR_TAX_CLASSIFICATN_DEF_PKG.initialize',
                               'Error Getting OE Profile information');
           END IF;
         -- Bug 2185315 - added fnd_message so error will reflect on the form
           FND_MESSAGE.set_name('AR','AR_NO_OM_MASTER_ORG');  -- Bug 3151551
           APP_EXCEPTION.raise_exception;
  End if;

  profinfo.so_organization_id := l_master_org_id;
  --oe_profile.get('SO_ORGANIZATION_ID', profinfo.so_organization_id);

  BEGIN
	IF ( arp_global.program_application_id IS NULL ) THEN
		profinfo.application_id := -1;
	ELSE
		profinfo.application_id := arp_global.program_application_id;
	END IF;

	IF ( arp_global.user_id IS NULL ) THEN
		profinfo.user_id := -1;
	ELSE
		profinfo.user_id := arp_global.user_id;
	END IF;
  EXCEPTION
    WHEN OTHERS THEN
	IF (g_level_statement >= g_current_runtime_level) THEN
		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Error Getting Profile information');
	END IF;
 	RAISE;
  END;

 /* not needed foir LTE
  --
  -- Location Flex Info
  --
  BEGIN
	tax_gbl_rec.tax_accnt_column := arp_flex.expand(arp_flex.location,
					'TAX_ACCOUNT', ',', '%COLUMN%');
        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','tax_accnt_column: '||tax_gbl_rec.tax_accnt_column);
        END IF;

  EXCEPTION
    WHEN OTHERS THEN
	IF (g_level_statement >= g_current_runtime_level) THEN
		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Error Getting Tax Account Qualifier');
	END IF;
 	RAISE;
  END;

  --
  -- GL Natural Account info
  --
  BEGIN
        tax_gbl_rec.natural_acct_column := arp_flex.expand(arp_flex.gl,
                                            'GL_ACCOUNT', ',', '%COLUMN%');
  EXCEPTION
    WHEN OTHERS THEN
        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Error Getting GL Natural Account Segment');
        END IF;

        RAISE;

  END;
*/



  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','-- Setting Tax processing flags!');
  END IF;
  sysinfo.insert_tax_lines := 'Y';
  sysinfo.call_auto_acctng := 'Y';
  tax_gbl_rec.one_err_msg_flag := 'Y';

--  arp_tax_group.initialize;

  -- Added as a fix for Bug#8231156
  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','-- Initializing l_line_level_tbl');
  END IF;
  l_line_level_tbl.DELETE;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.initialize.END',
                     'ZX_PRODUCT_INTEGRATION_PKG: initialize (-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.initialize',
                   SQLCODE || ' ; ' || SQLERRM);
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.initialize.END',
                     'ZX_PRODUCT_INTEGRATION_PKG: initialize (-)');
    END IF;

END initialize;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    calculate_tax                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    calculate_tax API when transaction come in with no tax                 |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | CALLED FROM                                                               |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
+===========================================================================*/

PROCEDURE calculate_tax (
  p_event_class_rec     IN  zx_api_pub.event_class_rec_type,
  x_return_status       OUT NOCOPY VARCHAR2
) IS

l_tax_calculation_flag    VARCHAR2(1);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax.BEGIN',
                     'ZX_PRODUCT_INTEGRATION_PKG: calculate_tax (+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- adjustment is not supported for LTE tax method
  IF p_event_class_rec.event_class_code = 'ADJUSTMENT' THEN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax',
                     'adjustment is not supported for LTE tax method');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax.END',
                     'ZX_PRODUCT_INTEGRATION_PKG: calculate_tax (-)');
    END IF;
    RETURN;
  END IF;

  --initialize the cache structure.
  initialize (
    p_event_class_rec => p_event_class_rec,
    x_return_status => x_return_status
  );


  IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax',
                    'Incorrect return_status after calling ' ||
                     'ZX_PRODUCT_INTEGRATION_PKG.initialize()');
    END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax.END',
                     'ZX_PRODUCT_INTEGRATION_PKG: calculate_tax (-)');
    END IF;

    RETURN;
  END IF;

  -- error handling mode should already set when reach here
  -- zx_api_pub.G_DATA_TRANSFER_MODE := 'TAB';

  IF (g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Count in zx_global_structures_pkg.trx_line_dist_tbl = '||
                       NVL(zx_global_structures_pkg.trx_line_dist_tbl.internal_organization_id.LAST, 0));
  END IF;


  FOR l_index IN NVL(zx_global_structures_pkg.trx_line_dist_tbl.internal_organization_id.FIRST, 1) ..
                 NVL(zx_global_structures_pkg.trx_line_dist_tbl.internal_organization_id.LAST, 0)
  LOOP

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Calculating Tax for : '||
              ' APPLICATION_ID: '||TO_CHAR(zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_ID(l_index))||
              ', ENTITY_CODE: '||zx_global_structures_pkg.trx_line_dist_tbl.ENTITY_CODE(l_index)||
              ', EVENT_CLASS_CODE: '||zx_global_structures_pkg.trx_line_dist_tbl.EVENT_CLASS_CODE(l_index)||
              ', EVENT_TYPE_CODE: '||zx_global_structures_pkg.trx_line_dist_tbl.EVENT_TYPE_CODE(l_index)||
              ', INTERNAL_ORG_ID: '|| TO_CHAR(zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(l_index))||
              ', TRX_ID: '|| TO_CHAR(zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID(l_index))||
              ', TRX_LINE_ID: '|| TO_CHAR(zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_ID(l_index))||
              ', TRX_LEVEL_TYPE: '|| TO_CHAR(zx_global_structures_pkg.trx_line_dist_tbl.TRX_LEVEL_TYPE(l_index))||
              ', TRX_LINE_TYPE: '|| zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_TYPE(l_index)||
              ', LINE_LEVEL_ACTION: '|| zx_global_structures_pkg.trx_line_dist_tbl.LINE_LEVEL_ACTION(l_index)||
              ', TRX_DATE: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.TRX_DATE(l_index))||
              ', TRX_CURRENCY_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.TRX_CURRENCY_CODE(l_index)||
              ', TRX_NUMBER: '|| zx_global_structures_pkg.trx_line_dist_tbl.TRX_NUMBER(l_index)||
              ', TRX_LINE_NUMBER: '|| zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_NUMBER(l_index)||
              ', TRX_LINE_DESCRIPTION: '|| zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DESCRIPTION(l_index)||
              ', FIRST_PTY_ORG_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.FIRST_PTY_ORG_ID(l_index))||
              ', TAX_EVENT_CLASS_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE(l_index)||
              ', TAX_EVENT_TYPE_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_TYPE_CODE(l_index)||
              ', DOC_EVENT_STATUS: '|| zx_global_structures_pkg.trx_line_dist_tbl.DOC_EVENT_STATUS(l_index)||
              ', TRX_BUSINESS_CATEGORY: '|| zx_global_structures_pkg.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(l_index)||
              ', PRODUCT_FISC_CLASSIFICATION: '|| zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(l_index)||
              ', PRODUCT_CATEGORY: '|| zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CATEGORY(l_index)||
              ', USER_DEFINED_FISC_CLASS: '|| zx_global_structures_pkg.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(l_index)||
              ', LINE_INTENDED_USE: '|| zx_global_structures_pkg.trx_line_dist_tbl.LINE_INTENDED_USE(l_index)||
              ', PRODUCT_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ID(l_index))||
              ', PRODUCT_DESCRIPTION: '|| zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_DESCRIPTION(l_index)||
              ', PRODUCT_ORG_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ORG_ID(l_index))||
              ', UOM_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.UOM_CODE(l_index)||
              ', PRODUCT_TYPE: '|| zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_TYPE(l_index)||
              ', PRODUCT_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CODE(l_index)||
              ', LINE_CLASS: '|| zx_global_structures_pkg.trx_line_dist_tbl.LINE_CLASS(l_index)||
              ', LINE_AMT: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT(l_index))||
              ', TRX_LINE_QUANTITY: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_QUANTITY(l_index))||
              ', UNIT_PRICE: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.UNIT_PRICE(l_index))||
              ', SHIP_TO_LOCATION_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_LOCATION_ID(l_index))||
              ', SHIP_FROM_LOCATION_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID(l_index))||
              ', BILL_TO_LOCATION_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_LOCATION_ID(l_index))||
              ', BILL_FROM_LOCATION_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_LOCATION_ID(l_index))||
              ', ADJUSTED_DOC_APPLICATION_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID(l_index))||
              ', ADJUSTED_DOC_ENTITY_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE(l_index)||
              ', ADJUSTED_DOC_EVENT_CLASS_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(l_index)||
              ', ADJUSTED_DOC_TRX_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID(l_index))||
              ', ADJUSTED_DOC_LINE_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID(l_index))||
              ', ADJUSTED_DOC_NUMBER: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_NUMBER(l_index))||
              ', ADJUSTED_DOC_DATE: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_DATE(l_index))||
              ', ADJUSTED_DOC_TRX_LEVEL_TYPE: '|| zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE(l_index) ||
              ', SHIP_TO_PARTY_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_TAX_PROF_ID(l_index))||
              ', SHIP_FROM_PARTY_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_TAX_PROF_ID(l_index))||
              ', BILL_TO_PARTY_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_TAX_PROF_ID(l_index))||
              ', BILL_FROM_PARTY_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_TAX_PROF_ID(l_index))||
              ', SHIP_TO_SITE_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_SITE_TAX_PROF_ID(l_index))||
              ', SHIP_FROM_SITE_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_SITE_TAX_PROF_ID(l_index))||
              ', BILL_TO_SITE_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_SITE_TAX_PROF_ID(l_index))||
              ', BILL_FROM_SITE_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_SITE_TAX_PROF_ID(l_index))||
              ', DOCUMENT_SUB_TYPE: '|| zx_global_structures_pkg.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(l_index)||
              ', TAX_INVOICE_DATE: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.TAX_INVOICE_DATE(l_index))||
              ', TAX_INVOICE_NUMBER: '|| zx_global_structures_pkg.trx_line_dist_tbl.TAX_INVOICE_NUMBER(l_index)||
              ', LEDGER_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.LEDGER_ID(l_index))||
              ', CURRENCY_CONVERSION_DATE: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(l_index))||
              ', CURRENCY_CONVERSION_RATE: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(l_index))||
              ', CURRENCY_CONVERSION_TYPE: '|| zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(l_index)||
              ', MINIMUM_ACCOUNTABLE_UNIT: '|| zx_global_structures_pkg.trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT(l_index)||
              ', PRECISION: '|| zx_global_structures_pkg.trx_line_dist_tbl.PRECISION(l_index)||
              ', LEGAL_ENTITY_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.LEGAL_ENTITY_ID(l_index))||
              ', ESTABLISHMENT_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.ESTABLISHMENT_ID(l_index))||
              ', LINE_AMT_INCLUDES_TAX_FLAG: '|| zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG(l_index)||
              ', TAX_AMT_INCLUDED_FLAG: '|| zx_global_structures_pkg.trx_line_dist_tbl.TAX_AMT_INCLUDED_FLAG(l_index) ||
              ', HISTORICAL_FLAG: '|| zx_global_structures_pkg.trx_line_dist_tbl.HISTORICAL_FLAG(l_index)||
              ', INTERNAL_ORG_LOCATION_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORG_LOCATION_ID(l_index))||
              ', CTRL_HDR_TX_APPL_FLAG: '|| zx_global_structures_pkg.trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG(l_index)||
              ', CTRL_TOTAL_HDR_TX_AMT: '|| zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(l_index)||
              ', CTRL_TOTAL_LINE_TX_AMT: '|| zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_LINE_TX_AMT(l_index) ||
              ', OUTPUT_TAX_CLASSIFICATION_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(l_index)
              );
    END IF;

    ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (
                                    p_event_class_rec ,
                                    'LINE'          ,
                                    x_return_status   );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax',
                'Incorrect return_status when calling '||
                'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize().');
         FND_LOG.STRING(g_level_procedure,
                'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax.END',
                'ZX_PRODUCT_INTEGRATION_PKG: calculate_tax (-)');
      END IF;
      RETURN;
    END IF;

    -- Skip processing tax applicability for line_level_action
    -- 'RECORD_WITH_NO_TAX' and 'ALLOCATE_LINE_ONLY_ADJUSTMENT'
    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(l_index) IN ('RECORD_WITH_NO_TAX','ALLOCATE_LINE_ONLY_ADJUSTMENT')
    THEN
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax',
                    'Skip processing for Line-Level-Action '||
                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(l_index));
        FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax.END',
                    'ZX_PRODUCT_INTEGRATION_PKG.calculate_tax(-)');
      END IF;
      RETURN;
    END IF;

    -- for UPDATE event fetch the existing tax lines
    -- Added code to fetch the existing manual Tax lines   -- Bug#8256247
    IF ((ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(l_index) = 'UPDATE')
        OR (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(l_index) ='UPDATE'
            AND
            (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(l_index) = 'LINE_INFO_TAX_ONLY'
             OR ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(l_index) = 'CREATE_WITH_TAX')))
    THEN

      fetch_manual_tax_lines (
           p_event_class_rec => p_event_class_rec,
           p_index           => l_index,
           x_return_status   => x_return_status);

      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax',
                 'Incorrect RETURN_STATUS after calling '||
                 'ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines');
           FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax',
                 'RETURN_STATUS = ' || x_return_status);
           FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax.END',
                 'ZX_PRODUCT_INTEGRATION_PKG.calculate_tax(-)');
        END IF;
        RETURN;
      END IF;

    ELSIF (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(l_index) IS NOT NULL) THEN
      get_manual_tax_lines_for_cm(
           p_event_class_rec => p_event_class_rec,
           p_index           => l_index,
           x_return_status   => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax',
             'Incorrect return_status after calling ' ||
             'get_manual_tax_lines_for_cm()');
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax',
             'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax.END',
             'ZX_PRODUCT_INTEGRATION_PKG.calculate_tax(-)');
        END IF;
        RETURN;
      END IF;
    END IF;

   -- getting the tax calculation flag for the org and trx type id to determine if tax needs
   -- to be calculated for each line.
   BEGIN
    SELECT INV_TYPE.TAX_CALCULATION_FLAG
    INTO   l_tax_calculation_flag
    FROM   RA_CUST_TRX_TYPES_ALL INV_TYPE
    WHERE  INV_TYPE.CUST_TRX_TYPE_ID = zx_global_structures_pkg.trx_line_dist_tbl.receivables_trx_type_id(l_index)
    AND  ORG_ID = zx_global_structures_pkg.trx_line_dist_tbl.internal_organization_id(l_index);
   EXCEPTION
    WHEN OTHERS THEN
     l_tax_calculation_flag := NULL;
   END;

   IF NVL(l_tax_calculation_flag,'N') = 'Y' THEN
    calculate_tax_lte (
      p_event_class_rec => p_event_class_rec,
      p_id_dist_tbl => l_index,
      x_return_status => x_return_status
    );

    IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax',
                     'Errored out when calculate tax.');
      END IF;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax.END',
                     'ZX_PRODUCT_INTEGRATION_PKG: calculate_tax (-)');
      END IF;
      RETURN;
    END IF;
   END IF;

  END LOOP;

  -- delete the store data structure
  tax_rec_tbl.delete;
  tax_info_out_rec_tbl.delete;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax.END',
                 'ZX_PRODUCT_INTEGRATION_PKG: calculate_tax (-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax',
                   SQLCODE || ' ; ' || SQLERRM);
    END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax.END',
                   'ZX_PRODUCT_INTEGRATION_PKG: calculate_tax (-)');
    END IF;
END calculate_tax;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    import_document_with_tax                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Provide import service call from eBusiness Suite product,              |
 |    Support transaction line are imported with/without tax lines.          |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | CALLED FROM                                                               |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |     currently assume all passing lines belong to one trx                  |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
+===========================================================================*/

PROCEDURE import_document_with_tax (
  p_event_class_rec     IN OUT NOCOPY zx_api_pub.event_class_rec_type,
  x_return_status       OUT NOCOPY VARCHAR2
) IS

  l_error_buffer			  VARCHAR2(240);
  l_tax_calculation_flag      VARCHAR2(1);
  l_line_level_indx           NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax.BEGIN',
                     'ZX_PRODUCT_INTEGRATION_PKG: import_document_with_tax (+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- adjustment is not supported for LTE tax method
  IF p_event_class_rec.event_class_code = 'ADJUSTMENT' THEN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax',
                     'adjustment is not supported for LTE tax method');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax.END',
                     'ZX_PRODUCT_INTEGRATION_PKG: import_document_with_tax (-)');
    END IF;
    RETURN;
  END IF;

  --initialize the cache structure.
  initialize (
    p_event_class_rec => p_event_class_rec,
    x_return_status => x_return_status
  );
  IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax',
                    'Incorrect return_status after calling ' ||
                     'ZX_PRODUCT_INTEGRATION_PKG.initialize()');
    END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax.END',
                     'ZX_PRODUCT_INTEGRATION_PKG: import_document_with_tax (-)');
    END IF;

    RETURN;
  END IF;

  FOR l_index IN NVL(zx_global_structures_pkg.trx_line_dist_tbl.internal_organization_id.FIRST, 1) ..
                 NVL(zx_global_structures_pkg.trx_line_dist_tbl.internal_organization_id.LAST, 0)
  LOOP

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Importing transaction for : '||
              ' APPLICATION_ID: '||TO_CHAR(zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_ID(l_index))||
              ', ENTITY_CODE: '||zx_global_structures_pkg.trx_line_dist_tbl.ENTITY_CODE(l_index)||
              ', EVENT_CLASS_CODE: '||zx_global_structures_pkg.trx_line_dist_tbl.EVENT_CLASS_CODE(l_index)||
              ', EVENT_TYPE_CODE: '||zx_global_structures_pkg.trx_line_dist_tbl.EVENT_TYPE_CODE(l_index)||
              ', INTERNAL_ORG_ID: '|| TO_CHAR(zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(l_index))||
              ', TRX_ID: '|| TO_CHAR(zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID(l_index))||
              ', TRX_LINE_ID: '|| TO_CHAR(zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_ID(l_index))||
              ', TRX_LEVEL_TYPE: '|| TO_CHAR(zx_global_structures_pkg.trx_line_dist_tbl.TRX_LEVEL_TYPE(l_index))||
              ', TRX_LINE_TYPE: '|| zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_TYPE(l_index)||
              ', LINE_LEVEL_ACTION: '|| zx_global_structures_pkg.trx_line_dist_tbl.LINE_LEVEL_ACTION(l_index)||
              ', TRX_DATE: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.TRX_DATE(l_index))||
              ', TRX_CURRENCY_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.TRX_CURRENCY_CODE(l_index)||
              ', TRX_NUMBER: '|| zx_global_structures_pkg.trx_line_dist_tbl.TRX_NUMBER(l_index)||
              ', TRX_LINE_NUMBER: '|| zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_NUMBER(l_index)||
              ', TRX_LINE_DESCRIPTION: '|| zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DESCRIPTION(l_index)||
              ', FIRST_PTY_ORG_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.FIRST_PTY_ORG_ID(l_index))||
              ', TAX_EVENT_CLASS_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE(l_index)||
              ', TAX_EVENT_TYPE_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_TYPE_CODE(l_index)||
              ', DOC_EVENT_STATUS: '|| zx_global_structures_pkg.trx_line_dist_tbl.DOC_EVENT_STATUS(l_index)||
              ', TRX_BUSINESS_CATEGORY: '|| zx_global_structures_pkg.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(l_index)||
              ', PRODUCT_FISC_CLASSIFICATION: '|| zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(l_index)||
              ', PRODUCT_CATEGORY: '|| zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CATEGORY(l_index)||
              ', USER_DEFINED_FISC_CLASS: '|| zx_global_structures_pkg.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(l_index)||
              ', LINE_INTENDED_USE: '|| zx_global_structures_pkg.trx_line_dist_tbl.LINE_INTENDED_USE(l_index)||
              ', PRODUCT_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ID(l_index))||
              ', PRODUCT_DESCRIPTION: '|| zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_DESCRIPTION(l_index)||
              ', PRODUCT_ORG_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ORG_ID(l_index))||
              ', UOM_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.UOM_CODE(l_index)||
              ', PRODUCT_TYPE: '|| zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_TYPE(l_index)||
              ', PRODUCT_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CODE(l_index)||
              ', LINE_CLASS: '|| zx_global_structures_pkg.trx_line_dist_tbl.LINE_CLASS(l_index)||
              ', LINE_AMT: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT(l_index))||
              ', TRX_LINE_QUANTITY: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_QUANTITY(l_index))||
              ', UNIT_PRICE: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.UNIT_PRICE(l_index))||
              ', SHIP_TO_LOCATION_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_LOCATION_ID(l_index))||
              ', SHIP_FROM_LOCATION_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID(l_index))||
              ', BILL_TO_LOCATION_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_LOCATION_ID(l_index))||
              ', BILL_FROM_LOCATION_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_LOCATION_ID(l_index))||
              ', ADJUSTED_DOC_APPLICATION_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID(l_index))||
              ', ADJUSTED_DOC_ENTITY_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE(l_index)||
              ', ADJUSTED_DOC_EVENT_CLASS_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(l_index)||
              ', ADJUSTED_DOC_TRX_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID(l_index))||
              ', ADJUSTED_DOC_LINE_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID(l_index))||
              ', ADJUSTED_DOC_NUMBER: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_NUMBER(l_index))||
              ', ADJUSTED_DOC_DATE: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_DATE(l_index))||
              ', ADJUSTED_DOC_TRX_LEVEL_TYPE: '|| zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE(l_index) ||
              ', SHIP_TO_PARTY_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_TAX_PROF_ID(l_index))||
              ', SHIP_FROM_PARTY_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_TAX_PROF_ID(l_index))||
              ', BILL_TO_PARTY_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_TAX_PROF_ID(l_index))||
              ', BILL_FROM_PARTY_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_TAX_PROF_ID(l_index))||
              ', SHIP_TO_SITE_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_SITE_TAX_PROF_ID(l_index))||
              ', SHIP_FROM_SITE_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_SITE_TAX_PROF_ID(l_index))||
              ', BILL_TO_SITE_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_SITE_TAX_PROF_ID(l_index))||
              ', BILL_FROM_SITE_TAX_PROF_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_SITE_TAX_PROF_ID(l_index))||
              ', DOCUMENT_SUB_TYPE: '|| zx_global_structures_pkg.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(l_index)||
              ', TAX_INVOICE_DATE: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.TAX_INVOICE_DATE(l_index))||
              ', TAX_INVOICE_NUMBER: '|| zx_global_structures_pkg.trx_line_dist_tbl.TAX_INVOICE_NUMBER(l_index)||
              ', LEDGER_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.LEDGER_ID(l_index))||
              ', CURRENCY_CONVERSION_DATE: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(l_index))||
              ', CURRENCY_CONVERSION_RATE: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(l_index))||
              ', CURRENCY_CONVERSION_TYPE: '|| zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(l_index)||
              ', MINIMUM_ACCOUNTABLE_UNIT: '|| zx_global_structures_pkg.trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT(l_index)||
              ', PRECISION: '|| zx_global_structures_pkg.trx_line_dist_tbl.PRECISION(l_index)||
              ', LEGAL_ENTITY_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.LEGAL_ENTITY_ID(l_index))||
              ', ESTABLISHMENT_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.ESTABLISHMENT_ID(l_index))||
              ', LINE_AMT_INCLUDES_TAX_FLAG: '|| zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG(l_index)||
              ', TAX_AMT_INCLUDED_FLAG: '|| zx_global_structures_pkg.trx_line_dist_tbl.TAX_AMT_INCLUDED_FLAG(l_index) ||
              ', HISTORICAL_FLAG: '|| zx_global_structures_pkg.trx_line_dist_tbl.HISTORICAL_FLAG(l_index)||
              ', INTERNAL_ORG_LOCATION_ID: '|| TO_CHAR( zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORG_LOCATION_ID(l_index))||
              ', CTRL_HDR_TX_APPL_FLAG: '|| zx_global_structures_pkg.trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG(l_index)||
              ', CTRL_TOTAL_HDR_TX_AMT: '|| zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(l_index)||
              ', CTRL_TOTAL_LINE_TX_AMT: '|| zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_LINE_TX_AMT(l_index) ||
              ', OUTPUT_TAX_CLASSIFICATION_CODE: '|| zx_global_structures_pkg.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(l_index)
              );
    END IF;

    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(l_index) IN ('RECORD_WITH_NO_TAX')
    THEN
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax',
                    'Skip processing for Line-Level-Action RECORD_WITH_NO_TAX');
        FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax.END',
                    'ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax(-)');
      END IF;
      RETURN;
    END IF;

    IF zx_global_structures_pkg.trx_line_dist_tbl.line_level_action(l_index) = 'CREATE_WITH_TAX'
    THEN -- for line level action is 'CREATE_WITH_TAX'

       -- IF-Else Condition added as a fix for Bug#8231156
       l_line_level_indx := zx_global_structures_pkg.trx_line_dist_tbl.trx_id(l_index);

       IF l_line_level_tbl.EXISTS(l_line_level_indx) AND
          l_line_level_tbl(l_line_level_indx).trx_id = zx_global_structures_pkg.trx_line_dist_tbl.trx_id(l_index) THEN
          NULL;
       ELSE
          l_line_level_tbl(l_line_level_indx).trx_id := zx_global_structures_pkg.trx_line_dist_tbl.trx_id(l_index);

          ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (
                                    p_event_class_rec ,
                                    'LINE'          ,
                                    x_return_status   );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax',
                     'Incorrect return_status when calling '||
                     'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize().');
            END IF;
            IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax.END',
                       'ZX_PRODUCT_INTEGRATION_PKG: import_document_with_tax (-)');
            END IF;
            RETURN;
          END IF;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level :='LINE';
          -- Check what is the hard coded value for thr party_type
          -- and then assign the correpsonding value for the profile.
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_lvl_party_type := 'BILL_TO_PTY_SITE'; --?
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_rnd_lvl_party_tax_prof_id := p_event_class_rec.rdng_bill_to_pty_tx_p_st_id;

          import_trx_line_with_taxes (
            p_event_class_rec => p_event_class_rec,
            p_id_dist_tbl     => l_index,
            x_return_status   => x_return_status
          );

          IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            IF (g_level_unexpected >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_unexpected,
                        'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax',
                        'Errored out when calling import_trx_line_with_taxes().');
            END IF;
            IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax.END',
                  'ZX_PRODUCT_INTEGRATION_PKG: import_document_with_tax(-)');
            END IF;
            RETURN;
          END IF;
       END IF;


    ELSIF zx_global_structures_pkg.trx_line_dist_tbl.line_level_action(l_index) = 'CREATE'
    THEN
     -- for create line level action
      ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (
                                    p_event_class_rec ,
                                    'LINE'          ,
                                    x_return_status   );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_procedure >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax',
                  'Incorrect return_status when calling '||
                  'ZX_TDS_CALC_SERVICES_PUB_PKG.initialize().');
        END IF;
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax.END',
                    'ZX_PRODUCT_INTEGRATION_PKG: import_document_with_tax (-)');
        END IF;
        RETURN;
      END IF;

      IF (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(l_index) IS NOT NULL) THEN
        get_manual_tax_lines_for_cm(
           p_event_class_rec => p_event_class_rec,
           p_index           => l_index,
           x_return_status   => x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax',
               'Incorrect return_status after calling ' ||
               'get_manual_tax_lines_for_cm()');
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax',
               'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax.END',
               'ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax(-)');
          END IF;
          RETURN;
        END IF;
      END IF;

      BEGIN
        SELECT INV_TYPE.TAX_CALCULATION_FLAG
        INTO   l_tax_calculation_flag
        FROM   RA_CUST_TRX_TYPES_ALL INV_TYPE
        WHERE  INV_TYPE.CUST_TRX_TYPE_ID = zx_global_structures_pkg.trx_line_dist_tbl.receivables_trx_type_id(l_index)
        AND  ORG_ID = zx_global_structures_pkg.trx_line_dist_tbl.internal_organization_id(l_index);
      EXCEPTION
        WHEN OTHERS THEN
          l_tax_calculation_flag := NULL;
      END;

      IF NVL(l_tax_calculation_flag,'N') = 'Y' THEN
        calculate_tax_lte (
             p_event_class_rec => p_event_class_rec,
             p_id_dist_tbl => l_index,
             x_return_status => x_return_status
            );

        IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                         'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax',
                         'Incorrect return_status after calling ' ||
                         'ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte().');
          END IF;
          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax.END',
                   'ZX_PRODUCT_INTEGRATION_PKG: import_document_with_tax(-)');
          END IF;
          RETURN;
        END IF;
      END IF;

    ELSE -- error out for other line level actions than CREATE and CREAT_WITH_TAX

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Transaction line level action is invalid.');
      ZX_API_PUB.add_msg(
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax',
                 'Transaction line level action can only be CREATE or CREATE_WITH_TAX.');
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax',
                 'Current transaction line level action is: ' ||
                 zx_global_structures_pkg.trx_line_dist_tbl.line_level_action(l_index) );
        END IF;
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax.END',
                 'ZX_PRODUCT_INTEGRATION_PKG: import_document_with_tax(-)');
        END IF;
        RETURN;
      END IF;

    END IF;

  END LOOP;

  -- delete the store data structure
  tax_rec_tbl.delete;
  tax_info_out_rec_tbl.delete;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax.END',
                 'ZX_PRODUCT_INTEGRATION_PKG: import_document_with_tax (-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax',
                   SQLCODE || ' ; ' || SQLERRM);
    END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_document_with_tax.END',
                   'ZX_PRODUCT_INTEGRATION_PKG: import_document_with_tax (-)');
    END IF;
END import_document_with_tax;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   import_trx_line_with_taxes                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Assumption: All tax lines imported have allocation record in the        |
 |   Link table.                                                             |
 | MODIFICATION HISTORY                                                      |
 | Procedure modified as a fix for Bug#7530930                               |
 | Modification done : Cursor query changed                                  |
+===========================================================================*/

PROCEDURE import_trx_line_with_taxes (
 p_event_class_rec          IN          zx_api_pub.event_class_rec_type,
 p_id_dist_tbl              IN          NUMBER,
 x_return_status            OUT NOCOPY  VARCHAR2) IS

 CURSOR  get_detail_tax_lines_csr IS
 SELECT /*+ ORDERED
            INDEX(headergt ZX_TRX_HEADERS_GT_U1)
            INDEX(taxgt ZX_IMPORT_TAX_LINES_GT_U1)
            INDEX(linegt ZX_TRANSACTION_LINES_GT_U1)*/
        taxgt.summary_tax_line_number,
        taxgt.internal_organization_id,
        taxgt.tax_regime_code,
        taxgt.tax,
        taxgt.tax_status_code,
        taxgt.tax_rate_code,
        taxgt.tax_rate,
        taxgt.tax_amt,
        taxgt.tax_jurisdiction_code,
        taxgt.tax_amt_included_flag,
        taxgt.tax_rate_id,
        taxgt.tax_provider_id,
        taxgt.tax_exception_id,
        taxgt.tax_exemption_id,
        taxgt.exempt_reason_code,
        taxgt.exempt_certificate_number,
        linegt.trx_line_id,
        linegt.line_amt,
        headergt.trx_date,
        headergt.minimum_accountable_unit,
        headergt.precision,
        linegt.trx_level_type,
        linegt.trx_line_date,
        linegt.adjusted_doc_date,
        linegt.line_level_action,
        taxgt.interface_entity_code,
        taxgt.interface_tax_line_id,
        headergt.related_doc_date,
        headergt.provnl_tax_determination_date,
        linegt.tax_date ,
        linegt.tax_determine_date,
        linegt.tax_point_date
   FROM zx_trx_headers_gt headergt,
        zx_import_tax_lines_gt taxgt,
        zx_transaction_lines_gt linegt
  WHERE headergt.application_id = p_event_class_rec.application_id
    AND headergt.event_class_code = p_event_class_rec.event_class_code
    AND headergt.entity_code = p_event_class_rec.entity_code
    AND headergt.trx_id = p_event_class_rec.trx_id
    AND taxgt.application_id = headergt.application_id
    AND taxgt.entity_code = headergt.entity_code
    AND taxgt.event_class_code = headergt.event_class_code
    AND taxgt.trx_id = headergt.trx_id
    AND taxgt.tax_line_allocation_flag = 'N'
    AND linegt.application_id = taxgt.application_id
    AND linegt.entity_code = taxgt.entity_code
    AND linegt.event_class_code = taxgt.event_class_code
    AND linegt.trx_id = taxgt.trx_id
    AND linegt.trx_line_id = taxgt.trx_line_id
    ORDER BY taxgt.summary_tax_line_number;

 l_new_row_num			  NUMBER;
 l_begin_index			  BINARY_INTEGER;
 l_end_index			    BINARY_INTEGER;
 l_error_buffer			  VARCHAR2(240);
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes.BEGIN',
                  'ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_new_row_num := NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST,0);

  FOR tax_line_rec IN get_detail_tax_lines_csr LOOP

    l_new_row_num := l_new_row_num + 1;

    IF l_begin_index IS NULL THEN
      l_begin_index := l_new_row_num;
    END IF;

    create_detail_tax_line (
                   p_event_class_rec     =>  p_event_class_rec,
                   p_tax_line_rec        =>  tax_line_rec,
                   p_id_dist_tbl         =>  p_id_dist_tbl,
                   p_new_row_num         =>  l_new_row_num,
                   x_return_status       =>  x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes',
               'Incorrect return_status after calling '||
               'create_detail_tax_line()');
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes',
               'RETURN_STATUS = ' || x_return_status);
        END IF;
        IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes.END',
               'ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes(-)');
      END IF;
      RETURN;
    END IF;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).tax_amt := tax_line_rec.tax_amt;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).unrounded_tax_amt := tax_line_rec.tax_amt;


   -- Calculate taxable basis for manual import tax lines --
    IF tax_line_rec.tax_rate <> 0 AND tax_line_rec.tax_rate IS NOT NULL THEN
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                  l_new_row_num).taxable_amt := round(tax_line_rec.tax_amt*100/tax_line_rec.tax_rate,20);
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
              l_new_row_num).unrounded_taxable_amt := round(tax_line_rec.tax_amt*100/tax_line_rec.tax_rate,20);
    ELSE
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).taxable_amt := tax_line_rec.line_amt;
         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                      l_new_row_num).unrounded_taxable_amt := tax_line_rec.line_amt;
    END IF;
  END LOOP;     -- tax_line_rec IN get_alloc_detail_tax_lines_csr

  IF l_begin_index IS NOT NULL THEN
    l_end_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST;
  END IF;

  -- populate WHO columns and tax line id, also
  -- check if all mandatory columns have values
  ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line(
                                                l_begin_index,
                                                l_end_index,
                                                x_return_status,
                                                l_error_buffer);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes',
             'Incorrect return_status after calling ' ||
             'ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line()');
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes',
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes.END',
             'ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
           'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes',
           'Detail tax lines created from imported summary tax lines:');
    FND_LOG.STRING(g_level_event,
           'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes',
           'l_begin_index = ' || l_begin_index);
    FND_LOG.STRING(g_level_event,
           'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes',
           'l_end_index = ' || l_end_index);
    FND_LOG.STRING(g_level_event,
           'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes',
           'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_event,
           'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes.END',
           'ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes(-)');
  END IF;


  IF ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST >= C_LINES_PER_INSERT) THEN

    ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt (x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes',
                      'Incorrect return_status after calling ' ||
                      'dump_detail_tax_lines_into_gt()');
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes',
                      'RETURN_STATUS = ' || x_return_status);
      END IF;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes.END',
                      'ZX_TDS_CALC_SERVICES_PUB_PKG.calculate_tax(-)');
      END IF;
      RETURN;
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes',
                  sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes.END',
                 'ZX_PRODUCT_INTEGRATION_PKG.import_trx_line_with_taxes(-)');
    END IF;

END import_trx_line_with_taxes;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   calculate_tax_lte                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
+===========================================================================*/

PROCEDURE calculate_tax_lte (
  p_event_class_rec   IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  p_id_dist_tbl             IN         NUMBER,
  x_return_status    OUT NOCOPY  VARCHAR2
)IS

  l_tax_value   NUMBER;
  l_tax_out_tbl  tax_info_rec_tbl_type;
  l_new_row_num  NUMBER;

  l_tax_amt_included_flag VARCHAR2(1);
  l_compounding_tax_flag  VARCHAR2(1);
  l_cust_trx_type_id   NUMBER;

  cursor c_inv_trx_lines(c_application_id NUMBER,
                         c_entity_code  VARCHAR2,
                         c_event_class_code  VARCHAR2,
                         c_trx_id  NUMBER,
                         c_trx_line_id  NUMBER)
  is
  select
   trx_business_category,
   product_fisc_classification,
   product_category
  from
   zx_lines_det_factors
  where application_id =  c_application_id
    and entity_code = c_entity_code
    and event_class_code = c_event_class_code
    and trx_id = c_trx_id
    and trx_line_id = c_trx_line_id;


  -- Bug#5439803- get tax currency conversion info
  cursor c_inv_tax_lines(c_application_id NUMBER,
                         c_entity_code  VARCHAR2,
                         c_event_class_code VARCHAR2,
                         c_trx_id IN NUMBER,
                         c_trx_level_type VARCHAR2,
                         c_trx_line_id in NUMBER)
  is
  select
    tax_line_id,
    trx_date,
    tax_regime_code,
    tax,
    tax_status_code,
    tax_rate_code,
    tax_rate_id,
    tax_rate,
    tax_exemption_id,
    tax_exception_id,
    tax_currency_conversion_date,
    tax_currency_conversion_rate,
    tax_currency_conversion_type
  from ZX_LINES
  where application_id =  c_application_id
    and entity_code = c_entity_code
    and event_class_code = c_event_class_code
    and trx_level_type = c_trx_level_type
    and trx_id = c_trx_id
    and trx_line_id = c_trx_line_id
    and NVL(manually_entered_flag,'N') = 'N'         -- Added the manually_entered_flag = N, cancel_flag <> Y
    and NVL(cancel_flag,'N') <> 'Y'                  -- and mrc_tax_line_flag = N to fetch only those tax lines
    and NVL(mrc_tax_line_flag,'N') = 'N';            -- from adjusted doc that are neither manual nor canceled

  CURSOR c_get_tax_categ_id (
             c_group_tax_id NUMBER,
             c_tax          VARCHAR2,
             c_org_id       NUMBER,
             c_trx_date     DATE) IS
    select TXC.tax_category_id
    from   JL_ZZ_AR_TX_GROUPS_ALL TGR ,
           JL_ZZ_AR_TX_CATEG TXC
    where  TGR.group_tax_id = c_group_tax_id
      and  TGR.tax_category_id = TXC.tax_category_id
      and  TXC.tax_category = c_tax
      and  TGR.org_id = c_org_id
      and  TGR.start_date_active <= c_trx_date
      and  TGR.end_date_active >= c_trx_date;


  /* BugFix 2057800: add this cursor to check the trx type.*/
   CURSOR c_chk_trx_type (c_trx_type_id IN NUMBER) IS
          select type
          from ra_cust_trx_types_all
          where cust_trx_type_id = c_trx_type_id
          and   org_id = sysinfo.sysparam.org_id;

  l_tax_info_rec  tax_info_rec_type;
  l_trx_type      ra_cust_trx_types.type%type;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte.BEGIN',
                  'ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte(+)');
  END IF;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  INITIALIZE_TAX_INFO_REC;

  -- Bug#6936808: init exception code returned from LTE
  JL_ZZ_TAX_INTEGRATION_PKG.g_jl_exception_type := 'N';


  -- assign all columns can mapped to tax_info_rec from line_dist_tbl.
  prepare_tax_info_rec ( p_index => p_id_dist_tbl );

  tax_rec_tbl.delete;
  tax_info_out_rec_tbl.delete;
  sysinfo.insert_tax_lines := 'N';
  TAX_GBL_REC.ONE_ERR_MSG_FLAG := 'Y';
  SYSINFO.CALL_AUTO_ACCTNG := 'N';
  -- arp_process_tax.old_customer_trx_id := 0;
  pg_old_customer_trx_id := 0;

  --
  -- Bug#5439803- init tax determine date to trx date
  --
  tax_info_rec.tax_determine_date := tax_info_rec.trx_date;

  IF tax_info_rec.customer_trx_id <> pg_old_customer_trx_id THEN

	pg_cm_type := NULL;
        l_cust_trx_type_id:= tax_info_rec.trx_type_id;

    IF l_cust_trx_type_id is not null THEN
     if trx_type_tbl.exists(l_cust_trx_type_id) then

         l_trx_type:= trx_type_tbl(l_cust_trx_type_id);
         IF (g_level_statement >= g_current_runtime_level) THEN
         	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','trx_type already cached; l_trx_type = ' || l_trx_type);
         END IF;

     else

          OPEN  c_chk_trx_type(l_cust_trx_type_id);
          FETCH c_chk_trx_type INTO l_trx_type;
          CLOSE c_chk_trx_type;

          trx_type_tbl(l_cust_trx_type_id):= l_trx_type;

          IF (g_level_statement >= g_current_runtime_level) THEN
          	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','New trx_type; l_trx_type = ' || l_trx_type);

          END IF;
     end if;
    END IF;

    IF (g_level_statement >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.process_tax_rec_f_sql',
                     'adjusted_doc_line_id : ' ||
                     TO_CHAR(tax_info_rec.adjusted_doc_line_id));
    END IF;

    IF tax_info_rec.adjusted_doc_line_id is NOT NULL THEN
      pg_cm_type := 'Applied';
      tax_info_rec.cm_type:=pg_cm_type;
    END IF;
  END IF;

  IF pg_cm_type IS NULL THEN
  	tax_info_rec.credit_memo_flag := FALSE;
    IF (g_level_statement >= g_current_runtime_level) THEN
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','NOT a credit memo transaction');
    END IF;
  ELSE
  	tax_info_rec.credit_memo_flag := TRUE;
    IF (g_level_statement >= g_current_runtime_level) THEN
    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Credit memo transaction');
    END IF;

  END IF;

  IF pg_cm_type = 'Applied' then

      l_tax_info_rec := tax_info_rec;

      Open c_inv_trx_lines(
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_id_dist_tbl),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(p_id_dist_tbl),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(p_id_dist_tbl),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id(p_id_dist_tbl),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(p_id_dist_tbl)) ;
      fetch c_inv_trx_lines into
            l_tax_info_rec.trx_business_category,
   	    l_tax_info_rec.product_fisc_classification,
            l_tax_info_rec.product_category;
      close c_inv_trx_lines;

         -- populate numeric, char attributes of tax infor rec based on this
         -- populate tax_info_Rec.userf9 with invoice_line.GLOBAL_ATTRIBUTE3
         -- IF Condition added for bug#7257015
         IF l_tax_info_rec.trx_business_category IS NOT NULL THEN
           l_tax_info_rec.userf9 := l_tax_info_rec.trx_business_category;
         END IF;
         -- populate tax_info_rec.previous_trx_number
         -- populate tax_info_rec.previous_customer_trx_line_id,
         -- populate tax_info_rec.previous_customer_trx_id
         -- populate tax_info_rec.usern7 (with hardcoded value 2)
         -- populate tax_info_rec.usern3 eith V.global_attribute12

      -- loop over original invoice's tax lines and call LTE for each tax line
      -- For example, if the invoice has a tax group which resulted in 3 tax lines, then
      -- this cursor will retrieve three racords and call the LTE three times, passing
      -- individual tax categories (in this case the tax group expansion will not take
      -- place inside the latin tax engine)

      Open c_inv_tax_lines(
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_id_dist_tbl),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(p_id_dist_tbl),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(p_id_dist_tbl),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id(p_id_dist_tbl),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(p_id_dist_tbl),

            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(p_id_dist_tbl)) ;
      Loop
         tax_info_rec :=  l_tax_info_rec;

         Fetch c_inv_tax_lines into
           tax_info_rec.adjusted_doc_tax_line_id,
           tax_info_rec.trx_date,
           tax_info_rec.tax_regime_code,
           tax_info_rec.tax,
           tax_info_rec.tax_status_code,
           tax_info_rec.tax_rate_code,
           tax_info_rec.tax_rate_id,
           tax_info_rec.tax_rate,
           tax_info_rec.tax_exemption_id,
           tax_info_rec.item_exception_rate_id,
           tax_info_rec.tax_currency_conversion_date,
           tax_info_rec.tax_currency_conversion_rate,
           tax_info_rec.tax_currency_conversion_type
           ;

         tax_info_rec.tax_code   := tax_info_rec.tax_rate_code;
         tax_info_rec.vat_tax_id := tax_info_rec.tax_rate_id;


         --  get tax_category_id
         open c_get_tax_categ_id (
              tax_info_rec.usern2,
              tax_info_rec.tax,
              sysinfo.sysparam.org_id,
              tax_info_rec.trx_date );
         fetch c_get_tax_categ_id INTO tax_info_rec.usern1;
         close c_get_tax_categ_id;

         --
         -- tax type for credit memo is always 'VAT'
         -- as each tax line info from the original invoice
         -- is passed, not the tax type from transaction line
         --
         tax_info_rec.userf7 := 'VAT';

         exit when c_inv_tax_lines%notfound;

         -- main engine call - one per tax line for credit memo
          process_tax_rec_f_sql_lte(
            p_appl_short_name => pg_application_short_name
          );

      end loop;
      close c_inv_tax_lines;

  ELSE
      process_tax_rec_f_sql_lte(
        p_appl_short_name => pg_application_short_name
      );
  END IF;

  -- arp_etax_integration_pkg.process_tax_rec_f_sql_lte() would have
  -- populated tax_rec_tbl; read this table and assign values to out table.

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte',
                 '#Rows Returned from '||
                 'ZX_PRODUCT_INTEGRATION_PKG.process_tax_rec_f_sql_lte(): '||
                 to_char(nvl(tax_info_out_rec_tbl.count, 0)));
  END IF;

  l_new_row_num := NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);

  l_compounding_tax_flag := 'N';
  l_tax_amt_included_flag := 'N';

 IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte',
                 'tax_info_out_rec_tbl.FIRST = '||NVL(tax_info_out_rec_tbl.FIRST,-1));
       FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte',
                 'tax_info_out_rec_tbl.Last = '||NVL(tax_info_out_rec_tbl.Last,-1));
      FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte',
                 'l_new_rownum = '||l_new_row_num);
 END IF;

  FOR l_out_ind IN NVL(tax_info_out_rec_tbl.FIRST, 1).. NVL(tax_info_out_rec_tbl.LAST, 0) LOOP

--++  nipatel commented out because of dependencies with ARP_TAX. Uncomment out later
--    IF l_tax_out_tbl(l_out_ind).compounding_tax_flag ='Y'
--    THEN
--      l_compounding_tax_flag := 'Y';
--    END IF;

    IF tax_info_out_rec_tbl(l_out_ind).amount_includes_tax_flag ='Y'
    THEN
      l_tax_amt_included_flag := 'Y';
    END IF;
    l_new_row_num := l_new_row_num + 1;

    -- Bug#5402471- populate new column tax_amt_included_flag

    tax_info_out_rec_tbl(l_out_ind).tax_amt_included_flag :=
       tax_info_out_rec_tbl(l_out_ind).amount_includes_tax_flag;

    prepare_detail_tax_line(
      p_event_class_rec => p_event_class_rec,
      p_id_dist_tbl     => p_id_dist_tbl,
      p_new_row_num     => l_new_row_num,
      p_tax_out_rec     => tax_info_out_rec_tbl(l_out_ind)
    );

    IF ( ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST >= C_LINES_PER_INSERT) THEN

      ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt (x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                        'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte',
                        'Incorrect return_status after calling ' ||
                        'ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt()');
          FND_LOG.STRING(g_level_unexpected,
                        'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte',
                        'RETURN_STATUS = ' || x_return_status);
        END IF;
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                        'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte.END',
                        'ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte(-)');
        END IF;
        RETURN;
      END IF;
    END IF;

  END LOOP;

  IF (nvl(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST,0) >= C_LINES_PER_INSERT) THEN

     ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt (x_return_status);


       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                        'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte',
                        'Incorrect return_status after calling ' ||
                        'ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt()');
          FND_LOG.STRING(g_level_unexpected,
                        'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte',
                        'RETURN_STATUS = ' || x_return_status);
        END IF;
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                        'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte.END',
                        'ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte(-)');
        END IF;
        RETURN;
      END IF;
  END IF;

  zx_global_structures_pkg.trx_line_dist_tbl.compounding_tax_flag(
    p_id_dist_tbl) := l_compounding_tax_flag;

  zx_global_structures_pkg.trx_line_dist_tbl.TAX_AMT_INCLUDED_FLAG(
    p_id_dist_tbl) := l_tax_amt_included_flag;

-- column not added to dist tbl defination yet
--  zx_global_structures_pkg.trx_line_dist_tbl.threshold_flag(
--    p_id_dist_tbl) := 'N';

EXCEPTION
  WHEN OTHERS THEN
    -- bug#6936808: check if this is expected error returned from
    -- LTE expand_group_tax_code
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte',
                  sqlcode || ': ' || SUBSTR(SQLERRM, 1, 512));
    END IF;
    IF JL_ZZ_TAX_INTEGRATION_PKG.g_jl_exception_type = 'E' THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
    ELSE
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte.END',
                 'ZX_PRODUCT_INTEGRATION_PKG.calculate_tax_lte(-)');
    END IF;

END calculate_tax_lte;

-- nipatel added for LTE testing.

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   process_tax_rec_f_sql_lte                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
+===========================================================================*/

PROCEDURE process_tax_rec_f_sql_lte (
		p_appl_short_name	 IN VARCHAR2)
  IS

      l_customer_trx_line_id       NUMBER;
      l_errorbuf                   varchar2(200);
      l_result                     number;
      l_ctl_tax_amt                NUMBER := 0;
      l_tax_amount      	   NUMBER := 0;
      l_tax_total		   NUMBER := 0;
      i             	       	   INTEGER;
      l_tax_vendor_return_code 	   VARCHAR2(30);
      l_new_extended_amount        NUMBER;
      l_new_unit_selling_price     NUMBER;
      l_tax_incl_amount_this_line  NUMBER;
      l_incl_amount_this_group     NUMBER;
      l_old_foreign_currency_code  fnd_currencies.currency_code%type;
      l_old_exchange_rate          NUMBER;

      /* BugFix 645089: Added following 4 lines */
      l_ct_id 			Number;
      prev_ctid 		Number;
      prev_ctlid 		Number;

      l_inv_trx_date            Date := Null;
      l_cm_trx_date             Date := Null;

      l_numOfRows		NUMBER := 0;
      l_tax_info_out_rec_tbl_count NUMBER := 0;
      l_complete_flag           VARCHAR2(1);

      l_trx_type               ra_cust_trx_types.type%type;
      l_cust_trx_type_id       ra_cust_trx_types.cust_trx_type_id%type;
      l_tax_calculation_flag   varchar2(1);


    /* BugFix 2057800: add this cursor to check the trx type.*/
       CURSOR c_chk_trx_type (c_trx_type_id IN NUMBER) IS
              select type
              from ra_cust_trx_types_all
              where cust_trx_type_id = c_trx_type_id
              and   org_id = sysinfo.sysparam.org_id;


        cursor calculation_flag_csr(c_cust_trx_type_id in number) is
	       select tax_calculation_flag
	       from ra_cust_trx_types_all ct
	       where ct.cust_trx_type_id = c_cust_trx_type_id
	       and org_id = sysinfo.sysparam.org_id;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.process_tax_rec_f_sql.BEGIN',
               'ZX_PRODUCT_INTEGRATION_PKG.process_tax_rec_f_sql(+)');
  END IF;

   -- arp_tax.set_error_mode('STANDARD',TRUE);

   BEGIN

	tax_info_rec.entered_amount :=
                        tax_info_rec.extended_amount;

        /*--------------------------------------------------------------+
	 | Initialize internal variables and flags			 |
         +--------------------------------------------------------------*/

      	tax_info_rec.tax_control :=
			NVL(tax_info_rec.tax_control, 'S');


    -- POO is not required for LTE

	  sysinfo.appl_short_name := p_appl_short_name;

	IF (tax_info_rec.amount_includes_tax_flag IS NULL) then
	  tax_info_rec.amount_includes_tax_flag := 'N';
	END IF;

      /* ++ nipatel check usage of this flag  */
          tax_gbl_rec.get_adhoc := FALSE;

	  IF ( tax_info_rec.tax_code in ( 'STATE', 'COUNTY', 'CITY')) THEN
            tax_info_rec.qualifier := tax_info_rec.tax_code;
	  ELSE
            tax_info_rec.qualifier := 'ALL';
	  END IF;

    -- The following check for credit memos should be done only if calling application is AR

       IF tax_info_rec.credit_memo_flag  and
          p_appl_short_name = 'AR'
       THEN

           arp_standard.find_previous_trx_line_id(
                             tax_info_rec.customer_trx_line_id,
                             tax_info_rec.tax_line_number,
                             tax_info_rec.vat_tax_id,
                             prev_ctid, prev_ctlid);
        END IF;


        --  Bug fix 650480:   If tax amount is specified by user for adhoc tax,
        --  then do not calculate tax amount using original line, and credit line
        --  amount.   Just skip following if statement.

     -- The following proration for credit memos should be done only if calling application is AR
        IF prev_ctid is not null and
           p_appl_short_name = 'AR' and
           pg_cm_type = 'Applied' and
           tax_info_rec.tax_rate is null and
           tax_info_rec.tax_amount is null THEN

          --  Bug fix 637110.   To get cm tax amount, use quantity if original
          --  line amount is zero.   If quantity is also, then copy negative
          --  amount of original tax amount.

          declare
            orig_line_amount number;
            cm_line_amount number;
            orig_tax_amount number;

            orig_line_qty   number;
            cm_line_qty     number;
            orig_cm_ratio   number;
          begin

            IF (g_level_statement >= g_current_runtime_level) THEN
            	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Calculate cm tax amount.');
            END IF;
            select  cm.extended_amount, cm.quantity_credited
            into    cm_line_amount, cm_line_qty
            from    ra_customer_trx_lines_all cm
            where   cm.customer_trx_line_id = tax_info_rec.customer_trx_line_id;

            select  line.extended_amount,
                    tax.extended_amount,
                    line.quantity_invoiced
            into    orig_line_amount,
                    orig_tax_amount,
                    orig_line_qty
            from    ra_customer_trx_lines_all line,
                    ra_customer_trx_lines_all tax
            where   tax.customer_trx_line_id = prev_ctlid
            and     tax.link_to_cust_trx_line_id = line.customer_trx_line_id;


            --   Check to see whether original line amount is zero.
            --   If it's so, then use quantity.   If quantity is also zero,
            --   then copy the original tax amount to Credit Memo with negative sign.
            --
            IF (nvl(orig_line_amount, 0) = 0) AND (nvl(orig_line_qty, 0) = 0) THEN
              IF (g_level_statement >= g_current_runtime_level) THEN
              	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Both line and quantity is zero. ');
              END IF;
              tax_info_rec.tax_amount := -1 * orig_tax_amount;
            ELSE
              IF nvl(orig_line_amount, 0) <> 0 THEN
                IF (g_level_statement >= g_current_runtime_level) THEN
                	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Use line amount. ');
                END IF;
                orig_cm_ratio := cm_line_amount / orig_line_amount;
              ELSE
                IF (g_level_statement >= g_current_runtime_level) THEN
                	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Use quantity. ');
                END IF;
                orig_cm_ratio := cm_line_qty / orig_line_qty;
              END IF;

              tax_info_rec.tax_amount :=
              tax_curr_round(
                                orig_tax_amount * orig_cm_ratio,
                                tax_info_rec.trx_currency_code,
                                tax_info_rec.precision,
                                tax_info_rec.minimum_accountable_unit,
                                tax_info_rec.tax_rounding_rule,
                                'Y');
            END IF;
          end;
        END IF; -- prev_ct_id is null

        -- Now make sure that the tax amount for the applied credit memo does
        -- not exceed the balance due

     /* Bug 4867678 commented out this check as the same chech is now being done
        in TDS tail end processing.

     -- The following check for credit memos should be done only if calling application is AR
        IF pg_cm_type = 'Applied' and
           p_appl_short_name = 'AR' and
           prev_ctid is not null and
           prev_ctlid is not null THEN
          DECLARE
            tax_balance Number;
            l_extended_amount NUMBER;
            --BugFix 2499050 Modified the expression in the following DECODE statement.
            cursor l_extended_amount_csr is
              select decode(nvl(prev_line.extended_amount,0), 0, 0,
                (line.extended_amount *  nvl(prev_tax.taxable_amount,1))/ prev_line.extended_amount)
              from   ra_customer_trx_lines_all line,
                     ra_customer_trx_lines_all prev_line,
                     ra_customer_trx_lines_all prev_tax
              where  prev_tax.customer_trx_line_id = prev_ctlid and
                     nvl(prev_tax.tax_vendor_return_code,tax_no_vendor) =
                                                         tax_no_vendor
              and    prev_tax.link_to_cust_trx_line_id = prev_line.customer_trx_line_id
              and    line.customer_trx_line_id = tax_info_rec.customer_trx_line_id
              and    line.previous_customer_trx_line_id = prev_line.customer_trx_line_id;

              dummy varchar2(10);

          BEGIN
            select net_amount into tax_balance
            from ar_net_revenue_amount
            where customer_trx_line_id = prev_ctlid
            and   customer_trx_id = prev_ctid;

            -- 821505
            if l_complete_flag <> 'Y' then
              IF (abs(tax_info_rec.tax_amount) > abs(tax_balance)) THEN
                tax_info_rec.tax_amount := tax_balance;
              END IF;
            end if;

            open l_extended_amount_csr;
            fetch l_extended_amount_csr into l_extended_amount;
            --
            if (l_extended_amount_csr%found) then
              tax_info_rec.extended_amount := l_extended_amount;
            end if;
            --
            close l_extended_amount_csr;

           --BugFix:1837433 commented out  the following IF condition
           -- if (tax_info_rec.amount_includes_tax_flag = 'Y') then
           --   tax_info_rec.amount_includes_tax_flag := 'P';
           -- end if;
           --
          END;
        END IF;

         End  Bug 4867678  */

        -- Bug821505: Check to see if this transaction is an applied credit memo
        -- If so, use Original Invoice's Transaction date for tax calculation
        --

     -- The following check for credit memos should be done only if calling application is AR
        IF (pg_cm_type = 'Applied') and
           p_appl_short_name = 'AR'
        THEN

          BEGIN

            IF tax_info_rec.customer_trx_line_id is null THEN

              select  inv_trx.trx_date
              into    l_inv_trx_date
              from    ra_customer_trx_all inv_trx,
                      ra_cust_trx_types_all trx_type,
                      ra_customer_trx_all trx
              where   trx.cust_trx_type_id = trx_type.cust_trx_type_id
              and     trx_type.type = 'CM'
              and     trx_type.org_id = trx.org_id
              and     trx.previous_customer_trx_id = inv_trx.customer_trx_id
              and     trx.customer_trx_id = tax_info_rec.customer_trx_id;

            ELSE

              select  inv_trx.trx_date
              into    l_inv_trx_date
              from    ra_customer_trx_all inv_trx,
                      ra_cust_trx_types_all trx_type,
                      ra_customer_trx_all trx,
                      ra_customer_trx_lines_all line
              where   trx.cust_trx_type_id = trx_type.cust_trx_type_id
              and     trx_type.type = 'CM'
              and     trx_type.org_id = trx.org_id
              and     trx.previous_customer_trx_id = inv_trx.customer_trx_id
              and     trx.customer_trx_id = line.customer_trx_id
              and     line.customer_trx_line_id = tax_info_rec.customer_trx_line_id;

            END IF;

            l_cm_trx_date := tax_info_rec.trx_date;
            tax_info_rec.trx_date := l_inv_trx_date;
            arp_util.debug('Changing date from '||to_char(l_cm_trx_date,'DD-MON-YYYY')||' to '||
                            to_char(l_inv_trx_date,'DD-MON-YYYY')||' for CM Tax Calculation.');

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              null;
          END;

        END IF; -- (pg_cm_type = 'Applied')

        /*********************************************************************
         | Calculate tax based on all data supplied through these views      |
         | If the views calculate a tax amount, and this is supported by     |
         | a vat tax id then use the amount returned from the views instead  |
         *********************************************************************/
        --
        -- Clear the table of record of type tax_info_rec_type
        --

        IF (g_level_statement >= g_current_runtime_level) THEN
             FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','deleting tx_rec_tbl, tax_info_rec_tbl......');
        END IF;

        tax_rec_tbl.delete;
        --
        -- Clear the table of record of type ra_customer_trx_lines%rowtype
        --
        tax_info_rec_tbl.delete;

        --
        -- create_tax_info_rec_tbl
        --

       BEGIN
       -- comment out the call to ARP_TAX_GROUP and copy the LTE specific logic
       -- in this procedure here
       -- ARP_TAX_GROUP.create_tax_info_rec_tbl;

               IF (g_level_statement >= g_current_runtime_level) THEN
               	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','create_tax_info_rec_tbl(+)');
               END IF;
               --
               --Tax Code is null. Go get it.
               --
               if (tax_info_rec.tax_code is null) then
                   IF (g_level_statement >= g_current_runtime_level) THEN
                   	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',' Tax Code is null. Go get it. ');
                   END IF;
                   ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification(
                     p_ship_to_site_use_id   => tax_info_rec.ship_to_site_use_id,
                     p_bill_to_site_use_id   => tax_info_rec.bill_to_site_use_id,
                     p_inventory_item_id     => tax_info_rec.inventory_item_id,
                     p_organization_id       => profinfo.so_organization_id,
                  -- p_warehouse_id          => tax_info_rec.ship_from_warehouse_id,
                     p_set_of_books_id       => sysinfo.sysparam.set_of_books_id,
                     p_trx_date              => tax_info_rec.trx_date,
                     p_trx_type_id           => tax_info_rec.trx_type_id,
                  -- p_vat_tax_id            => l_vat_tax_id,
                     p_tax_classification_code => tax_info_rec.tax_code,
                  -- p_amt_incl_tax_flag     => tax_info_rec.amount_includes_tax_flag,
                  -- p_amt_incl_tax_override => l_amt_incl_tax_override,
                     p_cust_trx_id           => tax_info_rec.customer_trx_id,
                     p_cust_trx_line_id      => tax_info_rec.customer_trx_line_id,
                     p_customer_id           => nvl(tax_info_rec.ship_to_cust_id,
                                                    tax_info_rec.bill_to_cust_id),
                     p_memo_line_id          => tax_info_rec.memo_line_id,
                     appl_short_name         => sysinfo.appl_short_name,
                     func_short_name         => sysinfo.func_short_name,
                     p_party_flag            => 'N',
                     p_party_location_id     => NULL,
                     p_entity_code           => tax_info_rec.entity_code,
                     p_event_class_code      => tax_info_rec.event_class_code,
                     p_application_id        => 222,
                     p_internal_organization_id =>  sysinfo.sysparam.org_id);

                 --
                 -- bug#6824850- populate other tax info based on the
                 -- tax code returned
                 --
                 IF tax_info_rec.tax_code IS NOT NULL THEN

                   BEGIN
                     SELECT TAXABLE_BASIS,
                          TAX_CALCULATION_PLSQL_BLOCK,
                          TAX_TYPE,
                          decode(tax_type,'TAX_GROUP',vat_tax_id,null),
                          decode(tax_type,'TAX_GROUP',NULL,
                                 decode (length(translate(global_attribute1,
                                           '0123456789 ', '0123456789')),
                                  length(translate(global_attribute1, '0123456789
                                  ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-,:.',
                          '0123456789')), global_attribute1, -99))
                    INTO   tax_info_rec.taxable_basis, --l_taxable_basis,
                           tax_info_rec.tax_calculation_plsql_block, --l_tax_calculation_plsql_block,
                           tax_info_rec.userf7, --l_tax_type,
                           tax_info_rec.usern2, --l_vat_tax_id,
                           tax_info_rec.usern1 --l_tax_category_id
                    FROM   ar_vat_tax_all_b
                    WHERE  set_of_books_id = sysinfo.sysparam.SET_OF_BOOKS_ID
                    AND    tax_code = tax_info_rec.tax_code
                    AND    tax_info_rec.trx_date BETWEEN start_date
                    AND    NVL(end_date, TO_DATE( '31122199', 'DDMMYYYY'))
                    AND    NVL(enabled_flag,'Y') = 'Y'
                    AND    NVL(tax_class,'O') = 'O'
                    AND    ORG_ID = sysinfo.sysparam.org_id;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         fnd_message.set_name('AR', 'GENERIC_MESSAGE');
                         fnd_message.set_token('GENERIC_TEXT',
                             'EXCEPTION(NO_DATA_FOUND) : Tax Code');
                         app_exception.raise_exception;
                    WHEN OTHERS THEN
                         fnd_message.set_name('AR', 'GENERIC_MESSAGE');
                         fnd_message.set_token('GENERIC_TEXT',
                             'EXCEPTION(OTHERS) : Tax Code : ' || sqlerrm);
                         app_exception.raise_exception;
                  END;

  --tax_info_rec.amount_includes_tax_flag := 'N';
                 END IF;

               end if;

               --
               if (sysinfo.sysparam.tax_method = MTHD_LATIN) then

                 BEGIN
                  IF (g_level_statement >= g_current_runtime_level) THEN
                       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Calling JL_ZZ_TAX_INTEGRATION_PKG.expand_group_tax_code');
                  END IF;
                  JL_ZZ_TAX_INTEGRATION_PKG.expand_group_tax_code(sysinfo.sysparam.org_id);
                 Exception
                   when others then
                   IF (g_level_statement >= g_current_runtime_level) THEN
                   	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Exception while expanding Latin Tax Group');
                   END IF;
                   app_exception.raise_exception;
                 End;

               end if;

       EXCEPTION
       WHEN OTHERS THEN
        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','IN WHEN OTHERS OF CREATE_TAX_INFO_REC_TBL');
        END IF;
          app_exception.raise_exception;
       END;

        --
        --
        -- tax_info_rec_tbl is populated. Iterate over tax_info_rec_tbl
        -- to process each line
        --
        l_numOfRows := nvl(tax_info_rec_tbl.last, 0);
        l_tax_info_out_rec_tbl_count := nvl(tax_info_out_rec_tbl.last,0);
        --
        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','before the loop for tax_info_rec_tbl. numOfRows: '||
                                                              to_char(l_numOfRows));
        END IF;
        for x in 1..l_numOfRows LOOP

          tax_info_rec := tax_info_rec_tbl(x);

          if tax_info_rec.amount_includes_tax_flag = 'P' then
            tax_info_rec.amount_includes_tax_flag := 'N';
          end if;


	  --Get Payment Discount
          --This will update extended_amount if payment discount exists
          --
          --BugFix 2127646 added the following If condition inorder to restrict a call to the
          --get_payment_term_discount incase of credit memos.

         /* Execute this part only for AR because payment term id is specifice to Receivables
         --++ nipatel commented out for LTE testing
          if p_appl_short_name = 'AR' and
             (NOT tax_info_rec.credit_memo_flag ) then
                ARP_PROCESS_TAX.get_payment_term_discount;
          end if;
         */

         /* Bugfix 2174086: If amount_includes_tax_flag is 'Y', then set tax_amount as NULL
         so that the procedure arp_tax_calculate() is called to calculate Tax. */

          IF (g_level_statement >= g_current_runtime_level) THEN
          	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','tax_amount='||to_char(tax_info_rec.tax_amount));
          END IF;


          IF tax_info_rec.tax_amount is NULL OR
	     tax_info_rec.vat_tax_id is NULL OR
             tax_info_rec.amount_includes_tax_flag = 'Y' THEN -- BugFix 3242435

            arp_tax_calculate;

          ELSE
	    -- If the database views have performed the tax calculation, then
	    -- pass this tax amount along any installed tax vendor. This will
 	    -- normally happen during a delete of a tax line, since deleted
            -- tax records must be reversded from any audit.

            dump_tax_info_rec('I');

             -- The call to arp_tax_vendor.calculate is not required as this call is
             -- only for inserting audit entries in vendor tables.

            --
            -- Populate Taxable Amount in case only taxable amount is null.
            --
            IF ( tax_info_rec.taxable_amount IS NULL) and
               ( tax_info_rec.tax_amount IS NOT NULL) THEN

              IF (nvl(tax_info_rec.taxable_basis, 'BEFORE_EPD') = 'QUANTITY') then

                tax_info_rec.taxable_amount :=
                                tax_info_rec.extended_amount;

              ELSIF ( nvl(tax_info_rec.amount_includes_tax_flag, 'Y') = 'Y') THEN

                tax_info_rec.taxable_amount :=
                          tax_info_rec.extended_amount - tax_info_rec.tax_amount;

              ELSIF ( nvl(tax_info_rec.amount_includes_tax_flag, 'N') in ('N','P') ) THEN

                tax_info_rec.taxable_amount :=
                               tax_info_rec.extended_amount;

              END IF;
            END IF;

            if tax_info_rec.tax_vendor_return_code in (TAX_RC_OERR,TAX_RC_NO_RATE,
                                                                TAX_RC_SYSERR) then
              dump_tax_info_rec('E');
              app_exception.raise_exception;

            end if;
            dump_tax_info_rec('O');

	    -- get the effective tax rates
	    if (tax_info_rec.extended_amount = 0) then
	      tax_info_rec.effective_tax_rate := 0;
	    else
	      tax_info_rec.effective_tax_rate :=
	      tax_info_rec.tax_amount/tax_info_rec.extended_amount;
	    end if;
          END IF; -- tax_amount is null or vat_tax_id is null

          IF tax_info_rec.customer_trx_id <> pg_old_customer_trx_id THEN
	    	pg_old_customer_trx_id := tax_info_rec.customer_trx_id;
	  END IF;

          /* 821505
           * Put CM transaction date back to tax_info_rec.trx_date.
           */
          IF (l_cm_trx_date is not null) THEN
            tax_info_rec.trx_date := l_cm_trx_date;
          END IF;

       	  /*********************************************************************
           | VAT : Document structure and Rounding                             |
           |       Apply Tax rounding rules.                                   |
           *********************************************************************/
           -- Perform line level rounding

            IF (g_level_statement >= g_current_runtime_level) THEN
            	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '-- Rounding Tax per Line');
            END IF;

	    -- For applied CMs, Do not re-derive the tax amount from the
	    -- tax rate, as the Tax amount can change without a change in the
	    -- tax rate.

            -- Bugfix 584866 - use tax amount passed
            -- Use of effective tax rate introduces obscure rounding errors.
            l_tax_amount := tax_info_rec.tax_amount;

   	    tax_info_rec.tax_amount :=
		               tax_curr_round( l_tax_amount,
		    	                           tax_info_rec.trx_currency_code,
		    	                           tax_info_rec.precision,
		    	                           tax_info_rec.minimum_accountable_unit,
		    	                           tax_info_rec.tax_rounding_rule,
                                                   'Y');
          -- End Line Level Rounding

          /********************************************************************************
           | For each line calculated, store that line in the ra_customer_trx_lines table |
           ********************************************************************************/

          IF (g_level_statement >= g_current_runtime_level) THEN
          	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','store values into tax_rec_tbl( '||to_char(x)||' ) +');
          END IF;

          tax_info_rec.trx_line_type := 'TAX';

        /*
          -- tax_info_out_rec_tbl(x).set_of_books_id := sysinfo.sysparam.set_of_books_id;
          tax_info_out_rec_tbl(x).link_to_cust_trx_line_id := tax_info_rec.customer_trx_line_id;
          tax_info_out_rec_tbl(x).customer_trx_id := tax_info_rec.customer_trx_id;
          tax_info_out_rec_tbl(x).tax_line_number := tax_info_rec.tax_line_number;
          tax_info_out_rec_tbl(x).trx_line_type := 'TAX';
          tax_info_out_rec_tbl(x).sales_tax_id := tax_info_rec.sales_tax_id;
          tax_info_out_rec_tbl(x).location_segment_id := tax_info_rec.location_segment_id;
          tax_info_out_rec_tbl(x).vat_tax_id := tax_info_rec.vat_tax_id;
          tax_info_out_rec_tbl(x).tax_rate := tax_info_rec.tax_rate;
          tax_info_out_rec_tbl(x).item_exception_rate_id := tax_info_rec.item_exception_rate_id;
          tax_info_out_rec_tbl(x).tax_exemption_id := tax_info_rec.tax_exemption_id;
          tax_info_out_rec_tbl(x).tax_control := tax_info_rec.tax_control;
          tax_info_out_rec_tbl(x).default_ussgl_transaction_code := tax_info_rec.default_ussgl_transaction_code;
          tax_info_out_rec_tbl(x).default_ussgl_trx_code_context := tax_info_rec.default_ussgl_trx_code_context;
          if (tax_info_rec.tax_precedence = 0) then
            tax_info_out_rec_tbl(x).tax_precedence := NULL;
          else
            tax_info_out_rec_tbl(x).tax_precedence := tax_info_rec.tax_precedence;
          end if;
          tax_info_out_rec_tbl(x).taxed_quantity := tax_info_rec.taxed_quantity;
          tax_info_out_rec_tbl(x).xmpt_cert_no := tax_info_rec.xmpt_cert_no;
          tax_info_out_rec_tbl(x).xmpt_reason := tax_info_rec.xmpt_reason;
          tax_info_out_rec_tbl(x).tax_vendor_return_code := tax_info_rec.tax_vendor_return_code;
          tax_info_out_rec_tbl(x).previous_customer_trx_id := prev_ctid;
          tax_info_out_rec_tbl(x).previous_customer_trx_line_id := prev_ctlid;

          --
          --should take from tax_rec_tbl(x)
          --
          if tax_info_rec_tbl(x).amount_includes_tax_flag = 'P' then
              tax_info_out_rec_tbl(x).amount_includes_tax_flag := 'Y';
              tax_info_rec.amount_includes_tax_flag := 'Y';
              tax_info_rec_tbl(x).amount_includes_tax_flag := 'Y';
          else
              tax_info_out_rec_tbl(x).amount_includes_tax_flag := tax_info_rec.amount_includes_tax_flag;
          end if;
          --
          tax_info_out_rec_tbl(x).extended_amount := tax_info_rec.tax_amount;
    --    tax_info_out_rec_tbl(x).request_id := fnd_global.request_id; -- Bugfix 588262
	  tax_info_out_rec_tbl(x).global_attribute1 := tax_info_rec.global_attribute1;
	  tax_info_out_rec_tbl(x).global_attribute2 := tax_info_rec.global_attribute2;
	  tax_info_out_rec_tbl(x).global_attribute3 := tax_info_rec.global_attribute3;
	  tax_info_out_rec_tbl(x).global_attribute4 := tax_info_rec.global_attribute4;
	  tax_info_out_rec_tbl(x).global_attribute5 := tax_info_rec.global_attribute5;
	  tax_info_out_rec_tbl(x).global_attribute6 := tax_info_rec.global_attribute6;
	  tax_info_out_rec_tbl(x).global_attribute7 := tax_info_rec.global_attribute7;
	  tax_info_out_rec_tbl(x).global_attribute8 := tax_info_rec.global_attribute8;
	  tax_info_out_rec_tbl(x).global_attribute9 := tax_info_rec.global_attribute9;
	  tax_info_out_rec_tbl(x).global_attribute10 := tax_info_rec.global_attribute10;
	  tax_info_out_rec_tbl(x).LEGAL_JUSTIFICATION_TEXT1 := tax_info_rec.global_attribute8;
	  tax_info_out_rec_tbl(x).LEGAL_JUSTIFICATION_TEXT1 := tax_info_rec.global_attribute9;
	  tax_info_out_rec_tbl(x).LEGAL_JUSTIFICATION_TEXT1 := tax_info_rec.global_attribute10;
	  tax_info_out_rec_tbl(x).global_attribute11 := tax_info_rec.global_attribute11;
	  tax_info_out_rec_tbl(x).global_attribute12 := tax_info_rec.global_attribute12;
	  tax_info_out_rec_tbl(x).global_attribute13 := tax_info_rec.global_attribute13;
	  tax_info_out_rec_tbl(x).global_attribute14 := tax_info_rec.global_attribute14;
	  tax_info_out_rec_tbl(x).global_attribute15 := tax_info_rec.global_attribute15;
	  tax_info_out_rec_tbl(x).global_attribute16 := tax_info_rec.global_attribute16;
	  tax_info_out_rec_tbl(x).global_attribute17 := tax_info_rec.global_attribute17;
	  tax_info_out_rec_tbl(x).global_attribute18 := tax_info_rec.global_attribute18;
	  tax_info_out_rec_tbl(x).global_attribute19 := tax_info_rec.global_attribute19;
	  tax_info_out_rec_tbl(x).global_attribute20 := tax_info_rec.global_attribute20;
	  tax_info_out_rec_tbl(x).global_attribute_category := tax_info_rec.global_attribute_category;
          -- tax_info_out_rec_tbl(x).autotax := 'Y'; -- AUTOTAX is always Y when created from the engine
          tax_info_out_rec_tbl(x).taxable_amount := tax_info_rec.taxable_amount;

         */

          --
	  -- For tax lines of credit memos, populate the foreign keys :
          -- previous_customer_trx_line_id and previous_customer_trx_id so that the autoaccounting
          -- function can duplicate the accounting distributions of the original invoice line
          --
         /* For credit memo, tax line should be linked to original invoice's tax line. */

          IF tax_info_rec.credit_memo_flag  and
             p_appl_short_name = 'AR'
          THEN
                 arp_standard.find_previous_trx_line_id(
                                    tax_info_rec.customer_trx_line_id,
                                    tax_info_rec.tax_line_number,
	                            tax_info_rec.vat_tax_id,
				    tax_info_rec.previous_customer_trx_id,
				    tax_info_rec.previous_customer_trx_line_id );
          END IF;

          tax_info_out_rec_tbl(x + l_tax_info_out_rec_tbl_count) := tax_info_rec;

	  if (nvl(tax_info_rec.amount_includes_tax_flag, 'N')='Y') then
          --BugFix 2180174 Added nvl command in the following statement.
	    l_tax_incl_amount_this_line := tax_info_rec.extended_amount +
                                           nvl(l_tax_incl_amount_this_line,0);
	  end if;

        end Loop;
        --
        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','after the loop for tax_info_rec_tbl');
        END IF;
        --
        -- tax_rec_tbl is populated by now
        -- call ARP_TAX_GROUP.adjust_compounding_inclusive only
        -- if TRX has group tax. That is tax_rec_tbl.last > 1
        --
        if (nvl(tax_rec_tbl.last, 0) > 1) then
          --
          l_tax_incl_amount_this_line := adjust_compound_inclusive;
          --
        end if;
        --
        -- Go over tax_rec_tbl to create tax lines and
        -- tax distribution lines
        --
        l_numOfRows := nvl(tax_rec_tbl.last, 0);
        --
   /*
        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','before the loop for tax_rec_tbl. numOfRows: '||to_char(l_numOfRows));
        END IF;
        --
        for x in 1..l_numOfRows LOOP

          -- bugfix 2160224: update inclusive adjusted amounts in tax_info_out_rec_tbl
	  IF  sysinfo.appl_short_name <> 'AR' then
               tax_info_out_rec_tbl(x).taxable_amount := tax_info_out_rec_tbl(x).taxable_amount;
               tax_info_out_rec_tbl(x).tax_amount := tax_info_out_rec_tbl(x).extended_amount;
          END IF;
        end loop;

        --
        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','after the loop for tax_rec_tbl');
        END IF;
        --
   */
     IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.process_tax_rec_f_sql.END',
                  'ZX_PRODUCT_INTEGRATION_PKG.process_tax_rec_f_sql(-)');
     END IF;


 EXCEPTION
	WHEN OTHERS THEN
	  IF (g_level_statement >= g_current_runtime_level) THEN
	  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','EXCEPTION(process_tax_rec_f_sql in loop)');
          	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','SQLCODE '||SQLCODE||'Error Message '||SQLERRM);
          END IF;

	  IF (tax_gbl_rec.one_err_msg_flag = 'N') THEN

	    pg_bad_lines := pg_bad_lines + 1;

	    IF (g_level_statement >= g_current_runtime_level) THEN
	    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','-- Stack error');
	    END IF;
	    -- arp_tax.insert_error(nvl(tax_info_rec.customer_trx_line_id, 0));
	  ELSE
	    IF (g_level_statement >= g_current_runtime_level) THEN
	    	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','-- Raise error');
	    END IF;
	    RAISE;
	  END IF;
      END;

    -- p_new_tax_amount := l_ctl_tax_amt;


  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.process_tax_rec_f_sql.END',
                  'ZX_PRODUCT_INTEGRATION_PKG.process_tax_rec_f_sql(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.process_tax_rec_f_sql',
                  sqlcode || ': ' || SUBSTR(SQLERRM, 1, 512));
    END IF;
    RAISE;

END process_tax_rec_f_sql_lte;


/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    arp_tax_calculate                                                               |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This routine, is called to calculate a tax rate and amount for the      |
 |    transaction line that is recorded in the global data structure:         |
 |    arp_tax.tax_info_rec. The logic here is copied from arp_tax.calculate   |
 |    procedure for Latin Tax Engine                                          |
 |									      |
 | PARAMETERS                                                                 |
 |    tax_info_rec                                                            |
 |                                                                            |
 | RETURNS                                                                    |
 |    tax_info_rec updated with tax rate, amount, vendor and other info.      |
 |    exceptions                                                              |
 |      app_exception.raise_exception when an exception is found along with   |
 |                                         the error message.                 |
 |                                                                            |
 | CALLED FROM                                                                |
 |    process_tax_rec_f_sql_lte                                               |
 |                                                                            |
 | HISTORY                                                                    |
 |    28-DEC-2004 Nilesh Patel    Created.                                    |
 |                                                                            |
 *----------------------------------------------------------------------------*/
PROCEDURE arp_tax_calculate IS
  l_tax_vendor_return_code	ra_customer_trx_lines.tax_vendor_return_code%TYPE;
  l_use_tax_rate_passed         BOOLEAN := FALSE;       -- Bugfix 370068, 370265
  l_use_tax_vendor              BOOLEAN;
  l_batch_tax_rate_rule         ra_batch_sources.invalid_tax_rate_rule%type;
  l_tax_amount                  ra_customer_trx_lines.extended_amount%TYPE;
  l_precision                   fnd_currencies.precision%TYPE;
  l_min_acct_unit               fnd_currencies.minimum_accountable_unit%TYPE;

  CURSOR get_vat_tax_id(c_sob_id  NUMBER,
		   	c_tax_code VARCHAR2,
			c_trx_date DATE,
                        c_trx_end_date DATE,
                        c_org_id number ) IS
	 SELECT vat_tax_id,
                decode(tax_type,
                          'LOCATION', TAX_TYPE_LOCATION,
                          'SALES_TAX', TAX_TYPE_SALES,
                          TAX_TYPE_VAT ) tax_type
	   FROM ar_vat_tax_all_b
	  WHERE set_of_books_id = c_sob_id
	    AND tax_code = c_tax_code
	    AND c_trx_date between start_date and nvl(end_date, c_trx_end_date)
            AND nvl(enabled_flag,'Y') = 'Y'
            AND nvl(TAX_CLASS,'O') = 'O'
            AND org_id = c_org_id;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate.BEGIN',
                  'ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate(+)');
  END IF;

 IF ( tax_info_rec.tax_code IS NOT NULL ) THEN



        BEGIN

          -- Bugfix 358523: Vat_tax_id is now passed for applied CMs, use the
          -- vat_tax_id passed, this avoids the error in creating applied CMs
          -- for Invoices with an inactive tax code.
          -- For On-Account Credit Memos we need to get the vat_tax_id, Just
          -- like in an Invoice.
          IF ( NOT (tax_info_rec.credit_memo_flag AND
                    tax_info_rec.previous_customer_trx_id IS NOT NULL) ) THEN
             get_vat_tax_rate;
          ELSE
            OPEN get_vat_tax_id(sysinfo.sysparam.set_of_books_id,
                                tax_info_rec.tax_code,
                                tax_info_rec.trx_date,
                                tax_info_rec.trx_date,
                                sysinfo.sysparam.org_id);
            FETCH get_vat_tax_id INTO tax_info_rec.vat_tax_id, tax_info_rec.tax_type;
            CLOSE get_vat_tax_id;
          END IF;

         /*
           IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate',
                  'Populating Vat_tax_id:');
              FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate',
                  'set_if_books_id: '||sysinfo.sysparam.set_of_books_id);
              FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate',
                  'org_id: '||sysinfo.sysparam.org_id);
              FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate',
                  'tax_info_rec.tax_code: '||tax_info_rec.tax_code);
              FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate',
                  'tax_info_rec.Vat_tax_id: '||tax_info_rec.vat_tax_id);
              FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate',
                  'tax_info_rec.Tax_info_rec.tax_type: '||tax_info_rec.tax_type);
           END IF;
        */

        EXCEPTION
          when others then
            IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate',
                  'Exception in ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate'||SQLCODE||':'||SQLERRM);
            END IF;


        END;
 END IF;




  --
  -- Dump tax info when run in debug.
  --
  dump_tax_info_rec('I');

  --
  -- Check that the amount field has a value for lines other than Adjustments
  --
  IF ( tax_info_rec.extended_amount IS NULL AND
	nvl(tax_info_rec.trx_line_type, 'LINE') <> 'ADJ' ) THEN
		fnd_message.set_name('AR', 'AR_TAX_NO_AMOUNT');
		app_exception.raise_exception;
  END IF;

  --
  -- Check that the precision field has a value
  --
  IF ( tax_info_rec.precision IS NULL ) THEN
    fnd_message.set_name('AR', 'AR_TAX_NO_PRECISION');
    app_exception.raise_exception;
  END IF;

  -- Copy the tax rate passed
  pg_tax_rate_passed := tax_info_rec.tax_rate;


  /*--------------------------------------------------------------------------*
   | If a tax code is not passed go find the default tax code. Apply item     |
   | exceptions defined for item and apply any exemptions that might exist.   |
   *--------------------------------------------------------------------------*/

  IF ( tax_info_rec.tax_code IS NULL ) THEN

	--
	-- Get default tax code
	--
	DECLARE
  		l_ship_to_site_use_id 	NUMBER;
  		l_bill_to_site_use_id 	NUMBER;
  		l_inventory_item_id   	NUMBER;
  		l_organization_id     	NUMBER;
  		l_memo_line_id     	NUMBER;
  		l_customer_id     	NUMBER;
  		l_warehouse_id	  	NUMBER;
  		l_set_of_books_id     	NUMBER;
  		l_trx_date		DATE;
  		l_trx_type_id		NUMBER;
  		l_cust_trx_id		NUMBER;
  		l_cust_trx_line_id	NUMBER;
  		l_appl_short_name	VARCHAR2(10);
  		l_func_short_name	VARCHAR2(30);
  		l_vat_tax_id		NUMBER;
  		l_amt_incl_tax_flag	  VARCHAR2(1);
  		l_amt_incl_tax_override	  VARCHAR2(1);
                l_party_flag              VARCHAR2(1);
                l_party_location_id       VARCHAR2(30);
	BEGIN
		--
		-- Initialize
		--
		l_ship_to_site_use_id 	:= tax_info_rec.ship_to_site_use_id;
		l_bill_to_site_use_id 	:= tax_info_rec.bill_to_site_use_id;
		l_inventory_item_id 	:= tax_info_rec.inventory_item_id;
		l_organization_id 	:= profinfo.so_organization_id;
		l_memo_line_id 		:= tax_info_rec.memo_line_id;
		l_customer_id 		:= nvl(tax_info_rec.ship_to_cust_id,
					        tax_info_rec.bill_to_cust_id);
		l_warehouse_id 		:= NULL;
		l_set_of_books_id 	:= sysinfo.sysparam.set_of_books_id;
		l_trx_date 		:= tax_info_rec.trx_date;
		l_trx_type_id 		:= tax_info_rec.trx_type_id;
		l_cust_trx_id 		:= tax_info_rec.customer_trx_id;
		l_cust_trx_line_id 	:= tax_info_rec.customer_trx_line_id;
		l_appl_short_name 	:= sysinfo.appl_short_name;
		l_func_short_name 	:= sysinfo.func_short_name;

        	ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification(
        	 p_ship_to_site_use_id   => l_ship_to_site_use_id,
                 p_bill_to_site_use_id   => l_bill_to_site_use_id,
                 p_inventory_item_id     => l_inventory_item_id,
                 p_organization_id       => l_organization_id,
            --   p_warehouse_id          => l_warehouse_id,
                 p_set_of_books_id       => l_set_of_books_id,
                 p_trx_date              => l_trx_date,
                 p_trx_type_id           => l_trx_type_id,
                 p_tax_classification_code => tax_info_rec.tax_code,
            --   p_amt_incl_tax_flag     => l_amt_incl_tax_flag,
            --   p_amt_incl_tax_override => l_amt_incl_tax_override,
                 p_cust_trx_id           => l_cust_trx_id,
                 p_cust_trx_line_id      => l_cust_trx_line_id,
                 p_customer_id           => l_customer_id,
                 p_memo_line_id          => l_memo_line_id,
                 appl_short_name         => l_appl_short_name,
                 func_short_name         => l_func_short_name ,
                 p_party_flag            => l_party_flag,
                 p_party_location_id     => l_party_location_id,
                 p_entity_code           => tax_info_rec.entity_code,
                 p_event_class_code      => tax_info_rec.event_class_code,
                 p_application_id        => 222,
                 p_internal_organization_id  => sysinfo.sysparam.org_id);




	EXCEPTION
	  WHEN NO_DATA_FOUND THEN NULL;
	END;

  END IF;		-- Tax code passed?

  --
  -- If tax method is VAT and if tax code or rate not found then display mesg
  -- and raise exception.
  --
  IF  tax_info_rec.tax_code IS NULL THEN
    fnd_message.set_name('AR', 'AR_TAX_NO_CODE');
    JL_ZZ_TAX_INTEGRATION_PKG.g_jl_exception_type := 'E';
    app_exception.raise_exception;
  END IF;

  /*------------------------------------------------------------------------*
   | Bugfix : 370265, 370068.                                               |
   | If a tax rate or amount is passed then validate if the tax rate can be |
   | used and use that tax rate.                                            |
   *------------------------------------------------------------------------*/
  IF ( pg_tax_rate_passed IS NOT NULL ) THEN
    -- Tax rate was passed, Validate the tax rate passed


             --check_tax_rate_passed(l_use_tax_rate_passed);
              DECLARE

                    CURSOR sel_batch_src_tax_rule(c_trx_id IN NUMBER ) IS
              			SELECT invalid_tax_rate_rule
              			FROM   ra_batch_sources_all bsrc, ra_customer_trx_all trx
              			WHERE  trx.batch_source_id = bsrc.batch_source_id
              			AND    trx.org_id = bsrc.org_id
              			AND    trx.customer_trx_id = c_trx_id;

              BEGIN

                IF (g_level_statement >= g_current_runtime_level) THEN
                	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'check_tax_rate_passed...' );

              	        If tax_info_rec.credit_memo_flag then
                        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '-- credit_memo_flag = Y');
                        else
                       		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '-- credit_memo_flag = N');
                       	end if;
                	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '-- pg_adhoc_tax_code = '||pg_adhoc_tax_code);
                END IF;


              /* Bug Number 1795536 .Incase Of order Management ,it should set p_use_tax_rate_passed to true */

                IF (g_level_statement >= g_current_runtime_level) THEN
                	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','--Calling Application is = ' || sysinfo.appl_short_name);
                END IF;

                IF ( tax_info_rec.credit_memo_flag OR sysinfo.appl_short_name='OE') THEN
                            if tax_info_rec.cm_type='On-Account' THEN /*Bugfix 2435438 */
                              L_USE_TAX_RATE_PASSED:=FALSE;
                             else

                  -- For Credit Memos, always use the tax rate passed.
                             l_use_tax_rate_passed := TRUE;
                            end if;
                            if sysinfo.appl_short_name='OE' then
                             l_use_tax_rate_passed := TRUE;
                            end if;


                ELSE		-- Other Transactions like INV, DM and Sales Orders

                  IF ( nvl(pg_adhoc_tax_code,'N') = 'N' ) THEN

              		OPEN sel_batch_src_tax_rule(tax_info_rec.customer_trx_id);
              		FETCH sel_batch_src_tax_rule INTO l_batch_tax_rate_rule;
              		CLOSE sel_batch_src_tax_rule;

                      -- Batch tax rate rule is NULL(Correct) for Invoice sources
                      -- other than AutoInvoice
              	IF ( nvl(l_batch_tax_rate_rule, 'Correct') = 'Correct' ) THEN

              	  -- Don't use the tax rate passed, use the tax rate for the tax code.
              	  l_use_tax_rate_passed := FALSE;
              	ELSE
              	  -- Raise error
              	  fnd_message.set_name('AR','AR_TAX_RATE_INVALID');
              	  fnd_message.set_token('TAX_CODE', tax_info_rec.tax_code);
              	  fnd_message.set_token('TRX_DATE', tax_info_rec.trx_date );
                  JL_ZZ_TAX_INTEGRATION_PKG.g_jl_exception_type := 'E';
              	  app_exception.raise_exception;
              	END IF;

                  ELSE 	-- Adhoc Tax Code
              	  l_use_tax_rate_passed := TRUE;	-- Use the tax rate passed.
                  END IF;

                END IF;

                  IF (g_level_statement >= g_current_runtime_level) THEN
              	        If l_use_tax_rate_passed then
                        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '-- Use tax rate passed = Y');
                        else
                       		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '-- Use tax rate passed = N');
                       	end if;
                  END IF;

              EXCEPTION
                WHEN OTHERS THEN
                	IF (g_level_statement >= g_current_runtime_level) THEN
                		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'EXCEPTION(OTHERS) : check_tax_rate_passed...' );
                	END IF;

              	IF ( sel_batch_src_tax_rule%ISOPEN ) THEN
              		CLOSE sel_batch_src_tax_rule;
              	END IF;
              	RAISE ;
              END;
  END IF;

  IF ( l_use_tax_rate_passed
	OR  tax_info_rec.tax_amount IS NOT NULL ) THEN

  	IF (g_level_statement >= g_current_runtime_level) THEN
  		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','-- Tax rate or amount passed');
  		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','-- Tax Rate = '||to_char(pg_tax_rate_passed));
  		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','-- Tax Amount = '||to_char(tax_info_rec.tax_amount));
  	END IF;

	/*-----------------------------------------------------------------+
	 | If a tax amount was passed, we need to preserve the tax amount. |
	 | The tax rate will be derived from the tax amount and if a NULL  |
	 | Tax rate was passed, We leave that unchanged.		   |
	 +-----------------------------------------------------------------*/
	IF ( tax_info_rec.tax_amount IS NULL ) THEN

	  tax_info_rec.tax_rate := pg_tax_rate_passed;

	  /* bug 636254: allow vendors to calculate the tax amount if this is not passed */
	  /*get_tax_amount;*/

	ELSE
	  -- Tax amount was passed, preserve the tax amount and calculate
	  -- the tax rate.
  	  IF (g_level_statement >= g_current_runtime_level) THEN
  	  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','-- Deriving tax rate from tax amount');
  	  END IF;
          -- BugFix 2218609 Commented the following IF condition so that the
          -- tax_info_rec.tax_rate will be populated when ever the
          -- tax_info_rec.tax_amount is NOT NULL.

	 -- IF ( tax_info_rec.tax_rate IS NOT NULL ) THEN

	    -- Get tax rate from tax amount
	    -- Note: The tax rate can be NULL, but not incorrect
	    if (nvl(tax_info_rec.amount_includes_tax_flag, 'N') in('N','P')) then
	      tax_info_rec.tax_rate := ((tax_info_rec.tax_amount * 100) /
						tax_info_rec.extended_amount);
            else
	      -- NOTE: the following equation does not work for side-by-side inclusive taxes..
	      tax_info_rec.tax_rate := ((tax_info_rec.tax_amount * 100) /
 					(tax_info_rec.extended_amount - tax_info_rec.tax_amount));
            end if;
	 -- END IF;

	END IF;			-- Tax amount NULL?

	/* Bugfix 550589: Divide by zero error */
	IF ( tax_info_rec.extended_amount = 0 ) THEN
           tax_info_rec.effective_tax_rate := 0;
	ELSE
	   tax_info_rec.effective_tax_rate :=
                                           tax_info_rec.tax_amount / tax_info_rec.extended_amount;
	END IF;


        /*-------------------------------------------------------------------+
         | Synchronize the Tax vendor with the passed Tax rate and Amount.   |
         | Here, we ignore the tax rate and amount passed by the tax vendor  |
         | as we need to use the tax rate or amount passed.                  |
         +-------------------------------------------------------------------*/

               -- Replace the call to arp_tax_vendor.calculate with direct call to LTE
               IF sysinfo.sysparam.tax_method = MTHD_LATIN  THEN

                  BEGIN

                   IF (g_level_statement >= g_current_runtime_level) THEN
                   	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'Tax method: '
                                     ||sysinfo.sysparam.tax_method);
                   END IF;

                   tax_info_rec.tax_vendor_return_code :=
                               jl_zz_tax.calculate(p_org_id => sysinfo.sysparam.org_id);

                   IF (g_level_statement >= g_current_runtime_level) THEN
                   	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'JL_ZZ_TAX.calculate()- : tax_vendor_return_code '
                   	                    ||tax_info_rec.tax_vendor_return_code);
                   END IF;

                   l_tax_vendor_return_code := tax_info_rec.tax_vendor_return_code;

                 EXCEPTION
               	WHEN OTHERS THEN
                 	    fnd_message.set_name('AR', 'GENERIC_MESSAGE');
                 	    fnd_message.set_token('GENERIC_TEXT', 'Latin Tax Engine raised error.'||
                 	                 SQLCODE||';'||SQLERRM);
                 	    IF (g_level_unexpected >= g_current_runtime_level) THEN
                 	        FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Latin Tax Engine raised error: '||SQLCODE||';'||SQLERRM);
                 	    END IF;
                 	    app_exception.raise_exception;
                 END;
              END IF;


 	IF l_tax_vendor_return_code in ( TAX_RC_OERR, TAX_RC_SYSERR,TAX_RC_NO_RATE ) THEN
        	/* There should be a message on the message stack already */
        	/* Raise a hard error */
        	app_exception.raise_exception;
     	END IF;

        /* Bug 636254: Once the vendor has had a chance to calculate the
           tax amount, if the tax amount is still NULL, then go and
           calculate the amount */
        if ( tax_info_rec.tax_amount IS NULL ) THEN

              -- get_tax_amount;
              IF ( tax_info_rec.tax_rate IS NOT NULL ) THEN
                  IF (nvl(tax_info_rec.taxable_basis, 'BEFORE_EPD') = 'QUANTITY') then
              	      l_tax_amount := tax_info_rec.taxed_quantity * tax_info_rec.tax_rate;
                      --
                      l_tax_amount := tax_curr_round(
              		    l_tax_amount,
              		    tax_info_rec.trx_currency_code,
              		    tax_info_rec.precision,
              		    tax_info_rec.minimum_accountable_unit,
              		    tax_info_rec.tax_rounding_rule,
                            'Y');
                      --
                      -- Set taxable_amount
                      --
                      tax_info_rec.taxable_amount := tax_info_rec.extended_amount;
                      --
                      -- Set tax_rate
                      --
                      IF tax_info_rec.taxable_amount = 0 then
                         NULL;
                      ELSE

                          tax_info_rec.tax_rate := l_tax_amount / tax_info_rec.taxable_amount * 100;
                      END IF;

                  ELSIF ( nvl(tax_info_rec.amount_includes_tax_flag, 'Y') = 'Y') THEN
                	l_tax_amount := tax_info_rec.extended_amount *
                                                          tax_info_rec.tax_rate / (100+tax_info_rec.tax_rate);
                      --
                      l_tax_amount := tax_curr_round(
              		    l_tax_amount,
              		    tax_info_rec.trx_currency_code,
              		    tax_info_rec.precision,
              		    tax_info_rec.minimum_accountable_unit,
              		    tax_info_rec.tax_rounding_rule,
                            'Y');
                      --
                      -- Set taxable_amount
                      --
                      tax_info_rec.taxable_amount := tax_info_rec.extended_amount - l_tax_amount;

                  ELSIF ( nvl(tax_info_rec.amount_includes_tax_flag, 'N') in ('N','P') ) THEN
                	l_tax_amount := tax_info_rec.extended_amount *
                                                          tax_info_rec.tax_rate / 100 ;
                      --
                      l_tax_amount := tax_curr_round(
              		    l_tax_amount,
              		    tax_info_rec.trx_currency_code,
              		    tax_info_rec.precision,
              		    tax_info_rec.minimum_accountable_unit,
              		    tax_info_rec.tax_rounding_rule,
                            'Y');
                      --
                      -- Set taxable_amount
                      --
                      tax_info_rec.taxable_amount := tax_info_rec.extended_amount;
                  END IF;

                END IF;

                --
                -- Round to correct currency precision
                --
                l_precision     := tax_info_rec.precision;
                l_min_acct_unit := tax_info_rec.minimum_accountable_unit;

                tax_info_rec.tax_amount := tax_curr_round( l_tax_amount,
                                                      tax_info_rec.trx_currency_code,
                                                      tax_info_rec.precision,
                                                      tax_info_rec.minimum_accountable_unit,
                                                      tax_info_rec.tax_rounding_rule,
                                                      'Y');

        end if;
  	--
  	-- Dump tax info.
  	--
  	dump_tax_info_rec('O');

  	IF (g_level_statement >= g_current_runtime_level) THEN
  		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','arp_tax_calculate()-');
  	END IF;
	RETURN;

  END IF;		-- End of Bugfix 370068, 370265

  --
  -- At this point we've found a tax code for VAT.
  --

  --
  -- If exemption is not passed, then look for exemptions
  --
  IF ( tax_info_rec.tax_exemption_id IS NULL ) THEN

	BEGIN

--crm
          IF (nvl(tax_info_rec.party_flag, 'N') = 'N') THEN
            --++ Nilesh: Need to check if exemptions are supported in LTE
	    -- get_exempt;
	     NULL;
          END IF;

	EXCEPTION
	  WHEN TAX_NO_RATE THEN
		--
		-- If Tax control is Exempt(and Exemption not found) then
		-- display message and raise exception.
		--
		IF ( tax_info_rec.tax_control = 'E' ) THEN

			fnd_message.set_name('AR','AR_TAX_NO_RATE');
      JL_ZZ_TAX_INTEGRATION_PKG.g_jl_exception_type := 'E';
			app_exception.raise_exception;

		END IF;		-- Tax control is Exempt?
	END;

  END IF;			-- Exemption info found?


       -- Replace the call to arp_tax_vendor.calculate with direct call to LTE
       IF sysinfo.sysparam.tax_method = MTHD_LATIN  THEN

          BEGIN

           IF (g_level_statement >= g_current_runtime_level) THEN
           	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'Tax method: '
                             ||sysinfo.sysparam.tax_method);
           END IF;

           l_tax_vendor_return_code :=  jl_zz_tax.calculate(p_org_id => sysinfo.sysparam.org_id);

           IF (g_level_statement >= g_current_runtime_level) THEN
           	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'JL_ZZ_TAX.calculate()- : tax_vendor_return_code '
           	                    ||l_tax_vendor_return_code);
           END IF;

         EXCEPTION
       	WHEN OTHERS THEN
         	    fnd_message.set_name('AR', 'GENERIC_MESSAGE');
         	    fnd_message.set_token('GENERIC_TEXT', 'Latin Tax Engine raised error.'||
         	                 SQLCODE||';'||SQLERRM);
         	    IF (g_level_unexpected >= g_current_runtime_level) THEN
         	       FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Latin Tax Engine raised error: '||SQLCODE||';'||SQLERRM);
                    END IF;
         	    app_exception.raise_exception;
         END;
      END IF;

  --
  -- If Tax Vendor is not installed then we need to get the Sales Tax Rate
  -- and apply exemptions if any. If a Tax vendor is installed then we use
  -- the tax rate and amount calculated by the tax vendor.
  --
  IF ( l_tax_vendor_return_code = TAX_NO_VENDOR ) THEN

	tax_info_rec.tax_vendor_return_code := l_tax_vendor_return_code;

	--
	-- If the Exemption is 100%, then we don't need to get sales tax rate,
	-- tax rate and tax amount is 0.
	IF ( NVL(tax_info_rec.xmpt_percent,0) = 100 ) THEN

		tax_info_rec.tax_rate := 0;
		tax_info_rec.tax_amount := 0;

	END IF;			-- 100% Exemption?


	--
	-- If exemption exists, calculate exempted tax rate
	--
	IF ( tax_info_rec.xmpt_percent IS NOT NULL ) THEN

		--++ Nilesh: Need to check if exemptions are supported in LTE
		-- calculate_exempt;
		NULL;

	END IF;			-- Exemption exists?

	--
	-- Calculate tax amount rounded to correct precision.
	--

              -- get_tax_amount;
              IF ( tax_info_rec.tax_rate IS NOT NULL ) THEN
                  IF (nvl(tax_info_rec.taxable_basis, 'BEFORE_EPD') = 'QUANTITY') then
              	      l_tax_amount := tax_info_rec.taxed_quantity * tax_info_rec.tax_rate;
                      --
                      l_tax_amount := tax_curr_round(
              		    l_tax_amount,
              		    tax_info_rec.trx_currency_code,
              		    tax_info_rec.precision,
              		    tax_info_rec.minimum_accountable_unit,
              		    tax_info_rec.tax_rounding_rule,
                            'Y');
                      --
                      -- Set taxable_amount
                      --
                      tax_info_rec.taxable_amount := tax_info_rec.extended_amount;
                      --
                      -- Set tax_rate
                      --
                      IF tax_info_rec.taxable_amount = 0 then
                         NULL;
                      ELSE

                          tax_info_rec.tax_rate := l_tax_amount / tax_info_rec.taxable_amount * 100;
                      END IF;

                  ELSIF ( nvl(tax_info_rec.amount_includes_tax_flag, 'Y') = 'Y') THEN
                	l_tax_amount := tax_info_rec.extended_amount *
                                                          tax_info_rec.tax_rate / (100+tax_info_rec.tax_rate);
                      --
                      l_tax_amount := tax_curr_round(
              		    l_tax_amount,
              		    tax_info_rec.trx_currency_code,
              		    tax_info_rec.precision,
              		    tax_info_rec.minimum_accountable_unit,
              		    tax_info_rec.tax_rounding_rule,
                            'Y');
                      --
                      -- Set taxable_amount
                      --
                      tax_info_rec.taxable_amount := tax_info_rec.extended_amount - l_tax_amount;

                  ELSIF ( nvl(tax_info_rec.amount_includes_tax_flag, 'N') in ('N','P') ) THEN
                	l_tax_amount := tax_info_rec.extended_amount *
                                                          tax_info_rec.tax_rate / 100 ;
                      --
                      l_tax_amount := tax_curr_round(
              		    l_tax_amount,
              		    tax_info_rec.trx_currency_code,
              		    tax_info_rec.precision,
              		    tax_info_rec.minimum_accountable_unit,
              		    tax_info_rec.tax_rounding_rule,
                            'Y');
                      --
                      -- Set taxable_amount
                      --
                      tax_info_rec.taxable_amount := tax_info_rec.extended_amount;
                  END IF;

                END IF;

                --
                -- Round to correct currency precision
                --
                l_precision     := tax_info_rec.precision;
                l_min_acct_unit := tax_info_rec.minimum_accountable_unit;

                tax_info_rec.tax_amount := tax_curr_round( l_tax_amount,
                                                      tax_info_rec.trx_currency_code,
                                                      tax_info_rec.precision,
                                                      tax_info_rec.minimum_accountable_unit,
                                                      tax_info_rec.tax_rounding_rule,
                                                      'Y');


  ELSE /* Tax Vendor is installed */


     tax_info_rec.tax_vendor_return_code := l_tax_vendor_return_code;


     IF l_tax_vendor_return_code in ( TAX_RC_OERR, TAX_RC_SYSERR, TAX_RC_NO_RATE ) THEN
	/* There should be a message on the message stack already */
	/* Raise a hard error */
	app_exception.raise_exception;
     END IF;


  END IF;		-- Vendor not installed?

  /* Bugfix 550589: Divide by zero error */
  IF ( tax_info_rec.extended_amount = 0 ) THEN
     tax_info_rec.effective_tax_rate := 0;
  ELSE
     tax_info_rec.effective_tax_rate := tax_info_rec.tax_amount / tax_info_rec.extended_amount;
  END IF;

  --
  -- Dump tax info.
  --
  dump_tax_info_rec('O');

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate.END',
                  'ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.arp_tax_calculate',
                  sqlcode || ': ' || SUBSTR(SQLERRM, 1, 512));
    END IF;

       /*---------------------------------------------+
        |  Display parameters and raise the exception |
        +---------------------------------------------*/
        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','****************************************');
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','*    EXCEPTION:  arp_tax_calculate()   *');
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','----------------------------------------');
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','*       Dumping Tax Info Record        *');
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','****************************************');
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','--');
        END IF;

	--
	-- Dump tax info.
	--
	dump_tax_info_rec('E');

        RAISE;

END arp_tax_calculate;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   prepare_tax_info_rec                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
+===========================================================================*/

PROCEDURE prepare_tax_info_rec(
  p_index   IN NUMBER
)IS

  l_cust_trx_type_id      ra_cust_trx_types.cust_trx_type_id%type;
  l_location_structure_id ar_system_parameters.location_structure_id%type;
  l_location_segment_num  number;
  l_set_of_books_id       ar_system_parameters.set_of_books_id%type;
  l_tax_rounding_allow_override
                          ar_system_parameters.tax_rounding_allow_override%type;
  l_tax_header_level_flag ar_system_parameters.tax_header_level_flag%type;
  l_tax_rounding_rule     ar_system_parameters.tax_rounding_rule%type;
  l_tax_rule_set          ar_system_parameters.global_attribute13%type;
  l_location_id           hr_locations_all.location_id%type;
  l_org_class             hr_locations_all.global_attribute1%type;
  l_taxable_basis         ar_vat_tax.taxable_basis%type;
  l_tax_calculation_plsql_block
                           ar_vat_tax.tax_calculation_plsql_block%type;
  l_tax_calculation_flag  ra_cust_trx_types.tax_calculation_flag%type;
  l_tax_type              ar_vat_tax.tax_type%type;
  l_vat_tax_id            ar_vat_tax.vat_tax_id%type;
  l_tax_category_id       ar_vat_tax.global_attribute1%type;
  l_global_attribute5     mtl_system_items.global_attribute1%type;
  l_global_attribute6     mtl_system_items.global_attribute2%type;
  l_tax_classification_code   ar_vat_tax_all_b.tax_code%type;

  -- Added by ssohal for Bug#8260273
  CURSOR get_org_class (c_org_id  HR_ORGANIZATION_UNITS.organization_id%TYPE) IS
    SELECT HRL.LOCATION_ID,
           HRL.GLOBAL_ATTRIBUTE1
    FROM   HR_LOCATIONS_ALL HRL ,
           HR_ORGANIZATION_UNITS ORG
    WHERE  ORG.LOCATION_ID = HRL.LOCATION_ID
    AND    ORG.ORGANIZATION_ID = c_org_id;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_tax_info_rec.BEGIN',
                  'ZX_PRODUCT_INTEGRATION_PKG.prepare_tax_info_rec(+)');
  END IF;

/*
 column not found in the dist_tbl
shipping_trading_partner_number(p_index);
shipping_trading_partner_name(p_index);
--  tax_info_rec.ship_to_customer_number      :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_trading_partner_number(p_index);
--  tax_info_rec.ship_to_customer_name        :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_trading_partner_name(p_index);
*/

  -- ? check the following four columns
  tax_info_rec.ship_to_cust_id      :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_third_pty_acct_id(p_index);
  tax_info_rec.bill_to_cust_id      :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_third_pty_acct_id(p_index);
  tax_info_rec.ship_to_site_use_id  :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID(p_index);
  tax_info_rec.bill_to_site_use_id  :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID(p_index);

  tax_info_rec.customer_trx_line_id :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Trx_line_id(p_index);
  tax_info_rec.customer_trx_id      :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Trx_id(p_index);
  tax_info_rec.trx_date             :=   NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_date(p_index),
                                                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_date(p_index));
  tax_info_rec.gl_date              :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_gl_date(p_index);
  tax_info_rec.tax_code             :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(p_index);

  IF (g_level_statement >= g_current_runtime_level) then
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Product_id = ('||to_char(p_index)||' )'||
                ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Product_id(p_index));
   FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Product_org_id = '||
                ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Product_org_id(p_index));
  END IF;

  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Product_id(p_index) is NOT NULL and
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Product_org_id(p_index) is NULL
  then
  -- this indicates that the line is a memo line
      tax_info_rec.memo_line_id         :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Product_id(p_index);  -- not need for latin tax
  ELSE
      tax_info_rec.inventory_item_id    :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Product_id(p_index);
  END IF;
  tax_info_rec.tax_control          :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.char1(p_index);   --exempt_flag
  tax_info_rec.xmpt_cert_no         :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.exempt_certificate_number(p_index);
  tax_info_rec.xmpt_reason          :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.exempt_reason(p_index);
  tax_info_rec.ship_to_location_id  :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_to_location_id(p_index);
  tax_info_rec.bill_to_location_id  :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_to_location_id(p_index);
  tax_info_rec.extended_amount      :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_index);
  -- in process_tax_rec_f_sql, entered_amount := extended_amount
  tax_info_rec.entered_amount      :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_index);

  tax_info_rec.trx_exchange_rate    :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.currency_conversion_rate(p_index);
  tax_info_rec.trx_currency_code    :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_currency_code(p_index);
  tax_info_rec.minimum_accountable_unit       :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.minimum_accountable_unit(p_index);
  tax_info_rec.precision                      :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.precision(p_index);
  tax_info_rec.fob_point                      :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.FOB_POINT(p_index);
  tax_info_rec.taxed_quantity                 :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_quantity(p_index);
  tax_info_rec.trx_number                     :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_number(p_index);
--  tax_info_rec.bill_to_customer_number        :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.billing_trading_partner_number(p_index);
--  tax_info_rec.bill_to_customer_name          :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.billing_trading_partner_name(p_index);
  tax_info_rec.previous_customer_trx_line_id  :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID(p_index);
  tax_info_rec.previous_customer_trx_id       :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id(p_index);
  tax_info_rec.previous_trx_number            :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Adjusted_doc_number(p_index);
  tax_info_rec.trx_line_type                  :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_type(p_index);

-- Bug#5338305
 tax_info_rec.adjusted_doc_application_id     := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_index);
 tax_info_rec.adjusted_doc_entity_code        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(p_index);
 tax_info_rec.adjusted_doc_event_class_code   := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(p_index);
 tax_info_rec.adjusted_doc_trx_id             := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id(p_index);
 tax_info_rec.adjusted_doc_line_id            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(p_index);
 tax_info_rec.adjusted_doc_number             := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_number(p_index);
 tax_info_rec.adjusted_doc_date               := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_date(p_index);

  tax_info_rec.adjusted_doc_trx_level_type    := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(p_index);

  -- bug#5350983- added related doc columns
  tax_info_rec.related_doc_application_id     := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_application_id(p_index);
  tax_info_rec.related_doc_entity_code        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_entity_code(p_index);
  tax_info_rec.related_doc_event_class_code   := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_event_class_code(p_index);
  tax_info_rec.related_doc_trx_id             := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_trx_id(p_index);
  --tax_info_rec.related_doc_trx_level_type     := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_trx_level_type(p_index);
  /* bug 5639478
  tax_info_rec.rel_doc_hdr_trx_user_key1      := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.rel_doc_hdr_trx_user_key1(p_index);
  tax_info_rec.rel_doc_hdr_trx_user_key2      := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.rel_doc_hdr_trx_user_key2(p_index);
  tax_info_rec.rel_doc_hdr_trx_user_key3      := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.rel_doc_hdr_trx_user_key3(p_index);
  tax_info_rec.rel_doc_hdr_trx_user_key4      := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.rel_doc_hdr_trx_user_key4(p_index);
  tax_info_rec.rel_doc_hdr_trx_user_key5      := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.rel_doc_hdr_trx_user_key5(p_index);
  tax_info_rec.rel_doc_hdr_trx_user_key6      := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.rel_doc_hdr_trx_user_key6(p_index);
  */
  tax_info_rec.related_doc_number             := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_number(p_index);
  tax_info_rec.related_doc_date               := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_date(p_index);

  tax_info_rec.trx_type_id                    :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.receivables_trx_type_id(p_index);
  tax_info_rec.ship_from_warehouse_id         :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Product_org_id(p_index);
  --tax_info_rec.poo_id                         :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POO_PARTY_ID(p_index);
  --tax_info_rec.poa_id                         :=   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.POA_PARTY_ID(p_index);

  tax_info_rec.amount_includes_tax_flag       := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt_includes_tax_flag(p_index);

  -- the following column assignment used to get char/numeric attributes
  -- retrieved from tax views, used in LTE. some can be defaulted through
  -- LTE validate and default program.


  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.receivables_trx_type_id(p_index) IS NULL THEN
     fnd_message.set_name('AR', 'GENERIC_MESSAGE');
     fnd_message.set_token('GENERIC_TEXT',
	       'Required Parameter Missing: Transaction Type Id');
     JL_ZZ_TAX_INTEGRATION_PKG.g_jl_exception_type := 'E';
     app_exception.raise_exception;
  END IF;

 -- Fetch Customer Trx_Type_Id and Tax Calculation Flag
  -- If Tax Calculation Flag is unchecked then return.
  l_cust_trx_type_id := NULL;
  BEGIN
      IF (g_level_statement >= g_current_runtime_level) THEN
          FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Receivables trx type id: '||
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.receivables_trx_type_id(p_index));
      END IF;
    SELECT INV_TYPE.CUST_TRX_TYPE_ID,
           INV_TYPE.TAX_CALCULATION_FLAG
    INTO   l_cust_trx_type_id,
           l_tax_calculation_flag
    FROM   RA_CUST_TRX_TYPES_ALL INV_TYPE
    WHERE  INV_TYPE.CUST_TRX_TYPE_ID = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.receivables_trx_type_id(p_index)
      AND  ORG_ID = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id(p_index);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         fnd_message.set_name('AR', 'GENERIC_MESSAGE');
         fnd_message.set_token('GENERIC_TEXT',
	         'EXCEPTION(NO_DATA_FOUND) : Customer Trx Type Id');
         app_exception.raise_exception;
    WHEN OTHERS THEN
         fnd_message.set_name('AR', 'GENERIC_MESSAGE');
         fnd_message.set_token('GENERIC_TEXT',
	         'EXCEPTION(OTHERS) : Customer Trx Type Id : ' || sqlerrm);
         app_exception.raise_exception;
  END;

  IF (NVL(l_tax_calculation_flag,'N') <> 'Y') THEN
     IF (g_level_statement >= g_current_runtime_level) THEN
     	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','populate_tax_struct_lte: ' || 'Tax Calculation Flag is not checked');
     END IF;

     IF (NVL(tax_info_rec.tax_control,'S') <> 'R') THEN
        IF (g_level_statement >= g_current_runtime_level) THEN
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','populate_tax_struct_lte: ' || 'Tax Exempt Flag is ' || tax_info_rec.tax_control);
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','populate_tax_struct_lte: ' || 'VALUES ARE NOT POPULATED');
        	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','populate_tax_struct_lte ()-');
        END IF;
        RETURN;
     END IF;
  END IF;
  tax_info_rec.trx_type_id := l_cust_trx_type_id;

  -- Fetch System Parameters
  l_location_structure_id       := sysinfo.sysparam.LOCATION_STRUCTURE_ID;
  l_location_segment_num        := TO_NUMBER(sysinfo.sysparam.GLOBAL_ATTRIBUTE10);
  l_set_of_books_id             := sysinfo.sysparam.SET_OF_BOOKS_ID;
  l_tax_rounding_allow_override := sysinfo.sysparam.TAX_ROUNDING_ALLOW_OVERRIDE;
  l_tax_header_level_flag       := sysinfo.sysparam.TAX_HEADER_LEVEL_FLAG;
  l_tax_rounding_rule           := sysinfo.sysparam.TAX_ROUNDING_RULE;
  l_tax_rule_set                := sysinfo.sysparam.GLOBAL_ATTRIBUTE13;

  tax_info_rec.usern9 := l_location_structure_id;
  tax_info_rec.usern10 := l_location_segment_num;
  tax_info_rec.userf1 := l_tax_rule_set;

  -- Fetch Location Id and Organization Class
  l_location_id := NULL;
  l_org_class := NULL;

/* -- Commented by ssohal for Bug#8260273
  BEGIN
    SELECT HRL.LOCATION_ID,
           NVL(HRL.GLOBAL_ATTRIBUTE1, 'DEFAULT')
    INTO   l_location_id,
           l_org_class
    FROM   HR_LOCATIONS_ALL HRL ,
           HR_ORGANIZATION_UNITS ORG
    WHERE  ORG.LOCATION_ID = HRL.LOCATION_ID
    --++ nipatel verify this join condition
    --++ Condition changed for Bug#7438620
    AND    ORG.ORGANIZATION_ID = NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_org_id(p_index),
                                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id(p_index));
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         IF (g_level_unexpected >= g_current_runtime_level) THEN
           FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Could not derive global_attribute1 from hr_locations for org_id: '||
                              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id(p_index));
         END IF;
         fnd_message.set_name('AR', 'GENERIC_MESSAGE');
         fnd_message.set_token('GENERIC_TEXT',
	         'EXCEPTION(NO_DATA_FOUND) : Organization Class');
         app_exception.raise_exception;
    WHEN OTHERS THEN
         fnd_message.set_name('AR', 'GENERIC_MESSAGE');
         fnd_message.set_token('GENERIC_TEXT',
	         'EXCEPTION(OTHERS) : Organization Class : ' || sqlcode||' , '||sqlerrm);
         app_exception.raise_exception;
  END;
*/
  -- Start : Code added for Bug#8260273 by ssohal
  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_org_id(p_index) IS NOT NULL THEN
     IF (g_level_statement >= g_current_runtime_level) THEN
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Getting global_Attribute1 from HR Locations for ORG: '||
               NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_org_id(p_index),0));
     END IF;

     OPEN get_org_class(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_org_id(p_index));
     FETCH get_org_class INTO l_location_id, l_org_class;
     CLOSE get_org_class;
  END IF;

  IF l_org_class IS NULL THEN
     IF (g_level_statement >= g_current_runtime_level) THEN
       FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Getting global_Attribute1 from HR Locations for ORG: '||
               NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id(p_index),0));
     END IF;

     OPEN get_org_class(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id(p_index));
     FETCH get_org_class INTO l_location_id, l_org_class;
     IF get_org_class%NOTFOUND THEN
        CLOSE get_org_class;
        IF (g_level_unexpected >= g_current_runtime_level) THEN
            FND_LOG.STRING(g_level_unexpected,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Could not derive global_attribute1 from hr_locations for org_id: '||
                           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id(p_index));
        END IF;
        fnd_message.set_name('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token('GENERIC_TEXT','EXCEPTION(NO_DATA_FOUND) : Organization Class');
        app_exception.raise_exception;
     ELSE
        CLOSE get_org_class;
     END IF;
  END IF;

  IF l_org_class IS NULL THEN
     l_org_class := 'DEFAULT';
  END IF;
  -- End : Code added for Bug#8260273 by ssohal

  tax_info_rec.usern4 := l_location_id;
  tax_info_rec.userf10 := l_org_class;

  -- Start : Added by ssohal for Bug#8611167
  -- In case of CM, Copy the Output TCC, PFC, PC and TBC from Adjusted Invoice
  -- if the Output Tax Classification Code is NULL
  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(p_index) IS NULL AND
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID(p_index) IS NOT NULL THEN
    BEGIN
        SELECT
               output_tax_classification_code,
               trx_business_category,
               product_fisc_classification,
               product_category,
               user_defined_fisc_class,
               default_taxation_country,
               document_sub_type,
               line_intended_use,
               assessable_value,
               product_type
          INTO
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(p_index),
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(p_index),
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(p_index),
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY(p_index),
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(p_index),
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(p_index),
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(p_index),
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_INTENDED_USE(p_index),
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSESSABLE_VALUE(p_index),
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE(p_index)
          FROM ZX_LINES_DET_FACTORS
         WHERE application_id   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_index)
           AND entity_code      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(p_index)
           AND event_class_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(p_index)
           AND trx_id           = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id(p_index)
           AND trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(p_index)
           AND trx_level_type   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(p_index);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             fnd_message.set_name('AR', 'GENERIC_MESSAGE');
             fnd_message.set_token('GENERIC_TEXT',
    	         'EXCEPTION(NO_DATA_FOUND) : No Record found for Adjusted Doc.');
             app_exception.raise_exception;
        WHEN OTHERS THEN
             fnd_message.set_name('AR', 'GENERIC_MESSAGE');
             fnd_message.set_token('GENERIC_TEXT',
    	         'EXCEPTION(OTHERS) : Record for Adjusted Doc : ' || sqlerrm);
             app_exception.raise_exception;
    END;
  END IF;
  -- End : Added by ssohal for Bug#8611167

  tax_info_rec.tax_code := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(p_index);

  IF (g_level_statement >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','Getting attributes from AR_VAT_TAX_ALL for tax_code: '||
                       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(p_index));
  END IF;

  -- Fetch AR_VAT_TAX details when tax_code is not NULL
  l_taxable_basis := NULL;
  l_tax_calculation_plsql_block := NULL;
  l_tax_type := NULL;
  l_vat_tax_id := NULL;
  l_tax_category_id := NULL;  -- bug 6824850

  IF (g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','l_set_of_books_id: '||l_set_of_books_id);
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','tax_code: '||ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(p_index));
    FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','trx_Date: '||tax_info_rec.trx_date);
  END IF;

  -- bug 6824850: select only if tax code is available
  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(p_index) IS NOT NULL THEN

      BEGIN
        SELECT TAXABLE_BASIS,
               TAX_CALCULATION_PLSQL_BLOCK,
               TAX_TYPE,
               decode(tax_type,'TAX_GROUP',vat_tax_id,null),
               decode(tax_type,'TAX_GROUP',NULL,
                  decode (length(translate(global_attribute1,
                   '0123456789 ', '0123456789')),
                   length(translate(global_attribute1, '0123456789
                   ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-,:.',
                   '0123456789')), global_attribute1, -99))
        INTO   l_taxable_basis,
               l_tax_calculation_plsql_block,
               l_tax_type,
               l_vat_tax_id,
               l_tax_category_id
        FROM   ar_vat_tax_all_b
        WHERE  set_of_books_id = l_set_of_books_id
        AND    tax_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(p_index)
        AND    tax_info_rec.trx_date BETWEEN start_date
                              AND NVL(end_date, TO_DATE( '31122199', 'DDMMYYYY'))
        AND    NVL(enabled_flag,'Y') = 'Y'
        AND    NVL(tax_class,'O') = 'O'
        AND    ORG_ID = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id(p_index) ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
             fnd_message.set_name('AR', 'GENERIC_MESSAGE');
             fnd_message.set_token('GENERIC_TEXT',
    	         'EXCEPTION(NO_DATA_FOUND) : Tax Code');
             app_exception.raise_exception;
        WHEN OTHERS THEN
             fnd_message.set_name('AR', 'GENERIC_MESSAGE');
             fnd_message.set_token('GENERIC_TEXT',
    	         'EXCEPTION(OTHERS) : Tax Code : ' || sqlerrm);
             app_exception.raise_exception;
      END;
  -- Bug 4028732 comment out  END IF;

  END IF;    -- bug 6824850

  tax_info_rec.taxable_basis := l_taxable_basis;
  tax_info_rec.tax_calculation_plsql_block :=
                                                l_tax_calculation_plsql_block;
  tax_info_rec.amount_includes_tax_flag := 'N';
  tax_info_rec.userf7 := l_tax_type;
  tax_info_rec.usern1 := l_tax_category_id;
  tax_info_rec.usern2 := l_vat_tax_id;
  tax_info_rec.usern5 := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_TRX_ID(p_index);

  -- Columns with Values from Parameters
  tax_info_rec.trx_exchange_rate := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(p_index);


  --++ verify that invoicing_rule_id, payment_term_id are not used in LTE
  -- tax_info_rec.invoicing_rule_id := p_invoicing_rule_id;
  -- tax_info_rec.payment_term_id := p_payment_term_id;

  l_global_attribute5 := nvl(
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(p_index),
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY(p_index));
  l_global_attribute6 := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(p_index);

  tax_info_rec.userf2 := l_global_attribute5;
  tax_info_rec.userf9 := l_global_attribute6;


  -- Columns with Default or NULL values
  /*
  tax_info_rec.customer_trx_charge_line_id := to_number(NULL);
  tax_info_rec.link_to_cust_trx_line_id := to_number(NULL);
  tax_info_rec.gl_date := NULL;
  tax_info_rec.tax_rate := to_number(NULL);
  tax_info_rec.tax_amount :=to_number(NULL);
  tax_info_rec.memo_line_id := NULL;
  tax_info_rec.default_ussgl_transaction_code := NULL;
  tax_info_rec.default_ussgl_trx_code_context := NULL;
  tax_info_rec.poo_code := NULL;
  tax_info_rec.poa_code := NULL;
  tax_info_rec.ship_from_code := NULL;
  tax_info_rec.ship_to_code := NULL;
  tax_info_rec.part_no := NULL;
  tax_info_rec.tax_line_number := to_number(null);
  tax_info_rec.tax_precedence := NULL;
  tax_info_rec.tax_exemption_id := NULL;
  tax_info_rec.item_exception_rate_id := NULL;
  tax_info_rec.vdrctrl_exempt := NULL;
  tax_info_rec.userf3 := NULL;
  tax_info_rec.userf4 := NULL; --userf4 can be derived from site_use id, for OM it is 'OE';
  tax_info_rec.userf5 := NULL;
  tax_info_rec.usern3 := NULL;
  tax_info_rec.usern5 := NULL;
  tax_info_rec.trx_number := to_number(NULL);
  tax_info_rec.previous_customer_trx_line_id := to_number(NULL);
  tax_info_rec.previous_customer_trx_id := to_number(NULL);
  tax_info_rec.previous_trx_number := to_number(NULL);
  tax_info_rec.trx_line_type := NULL;
  tax_info_rec.division_code := NULL;
  tax_info_rec.company_code := NULL;
  tax_info_rec.vat_tax_id := to_number(NULL);
  tax_info_rec.poo_id := to_number(NULL);
  tax_info_rec.poa_id := to_number(NULL);
  tax_info_rec.payment_terms_discount_percent := NULL;
  tax_info_rec.userf8 := NULL;
 */

  tax_info_rec.qualifier := 'ALL';
  tax_info_rec.calculate_tax := 'Y';
  tax_info_rec.audit_flag := 'N';
  tax_info_rec.usern6 := to_number(to_char(tax_info_rec.trx_date, 'YYYYMMDD'));
  tax_info_rec.usern7 := 2;

  -- bug 6824850
  IF (g_level_statement >= g_current_runtime_level) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_tax_info_rec',
                   'userf2 : '|| tax_info_rec.userf2);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_tax_info_rec',
                   'userf9 : '|| tax_info_rec.userf9);
  END IF;


  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_tax_info_rec.END',
                  'ZX_PRODUCT_INTEGRATION_PKG.prepare_tax_info_rec(-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_tax_info_rec',
                  sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END prepare_tax_info_rec;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    prepare_detail_tax_line                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Bulk insert of the tax_info_rec output lines into detail_tax_lines_gt. |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | CALLED FROM                                                               |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
+===========================================================================*/

PROCEDURE  prepare_detail_tax_line(
  p_event_class_rec  IN zx_api_pub.event_class_rec_type,
  p_id_dist_tbl      IN NUMBER,
  p_new_row_num      IN NUMBER,
  p_tax_out_rec      IN tax_info_rec_TYPE
) IS

l_user_id   	          NUMBER;
l_date      	          DATE;
l_return_status         VARCHAR2(30);
l_error_buffer          VARCHAR2(240);
l_tax_regime_rec	      ZX_GLOBAL_STRUCTURES_PKG.tax_regime_rec_type;
l_tax_rec  	            ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
l_tax_status_rec	      ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
l_tax_rate_rec          ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
l_tax_jurisdiction_rec  ZX_TDS_UTILITIES_PKG.zx_jur_info_cache_rec_type;
l_tax_rate_id           ZX_RATES_B.tax_rate_id%type;



BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line.BEGIN',
                 'ZX_PRODUCT_INTEGRATION_PKG: prepare_detail_tax_line (+)');
  END IF;

  l_user_id := fnd_global.user_id;
  l_date := sysdate;

  SELECT zx_lines_s.NEXTVAL
    INTO ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_line_id
    FROM dual;

  -- standard who columns
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).CREATED_BY       :=     l_user_id ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).CREATION_DATE    :=     l_date ; -- creation_date
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).LAST_UPDATED_BY  :=     l_user_id ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).LAST_UPDATE_DATE :=     l_date ; -- update_date

  -- below are read from tax_info_rec

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).adjusted_doc_tax_line_id := p_tax_out_rec.adjusted_doc_tax_line_id;


  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_line_date        :=  p_tax_out_rec.trx_date;
  --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).FOB_POINT            :=  p_tax_out_rec.fob_point;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ROUNDING_LEVEL_CODE  :=  p_tax_out_rec.ROUNDING_LEVEL_CODE; --tax_header_level_flag;  --++?where to set this value
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ROUNDING_RULE_CODE   :=  p_tax_out_rec.ROUNDING_RULE_CODE;  --tax_rounding_rule;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_line_number      :=  p_tax_out_rec.tax_line_number ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_AMT                := p_tax_out_rec.TAX_AMOUNT;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAXABLE_AMT            := p_tax_out_rec.TAXABLE_AMOUNT;  -- ? check if LTE set it or not.

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).UNROUNDED_TAXABLE_AMT  := p_tax_out_rec.UNROUNDED_TAXABLE_AMT;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).UNROUNDED_TAX_AMT      := p_tax_out_rec.UNROUNDED_TAX_AMT;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).CAL_TAX_AMT            := p_tax_out_rec.TAX_AMOUNT;

  -- columns added to tax_info_rec
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_DATE             :=  p_tax_out_rec.tax_date ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_DETERMINE_DATE   :=  p_tax_out_rec.tax_determine_date;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_POINT_DATE       :=  p_tax_out_rec.tax_point_date;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_REGIME_CODE   := p_tax_out_rec.TAX_REGIME_CODE  ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_REGIME_ID     := p_tax_out_rec.TAX_REGIME_ID    ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_STATUS_CODE   := p_tax_out_rec.TAX_STATUS_CODE  ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_STATUS_ID     := p_tax_out_rec.TAX_STATUS_ID    ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX               := p_tax_out_rec.TAX         ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_ID            := p_tax_out_rec.TAX_ID       ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_RATE_CODE     := p_tax_out_rec.TAX_RATE_CODE    ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_RATE_ID       := p_tax_out_rec.TAX_RATE_ID      ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_RATE          := p_tax_out_rec.TAX_RATE ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_type_code     := p_tax_out_rec.tax_type_code ;


  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_CURRENCY_CODE             := p_tax_out_rec.TAX_CURRENCY_CODE;
  --
  -- Bug#5439803- use tax determine date for tax currency conversion date
  -- if it is not credit memo
  --
  IF pg_cm_type = 'Applied'   THEN
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_CURRENCY_CONVERSION_DATE  := p_tax_out_rec.TAX_CURRENCY_CONVERSION_DATE;
  ELSE
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_CURRENCY_CONVERSION_DATE  := p_tax_out_rec.tax_determine_date;
  END IF;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_CURRENCY_CONVERSION_TYPE  := p_tax_out_rec.TAX_CURRENCY_CONVERSION_TYPE;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_CURRENCY_CONVERSION_RATE  := p_tax_out_rec.TAX_CURRENCY_CONVERSION_RATE;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_BASE_MODIFIER_RATE	    := p_tax_out_rec.TAX_BASE_MODIFIER_RATE; --global_attribute12;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).LEGAL_JUSTIFICATION_TEXT1	    := p_tax_out_rec.LEGAL_JUSTIFICATION_TEXT1; --Global_attribute8;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).LEGAL_JUSTIFICATION_TEXT2	    := p_tax_out_rec.LEGAL_JUSTIFICATION_TEXT2; --Global_attribute9;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).LEGAL_JUSTIFICATION_TEXT3	    := p_tax_out_rec.LEGAL_JUSTIFICATION_TEXT3; --Global_attribute10;


  -- Populate the global_attribute columns in detailed tax lines based on output tax record returned by LTE
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute1 := p_tax_out_rec.global_attribute1;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute2 := p_tax_out_rec.global_attribute2;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute3 := p_tax_out_rec.global_attribute3;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute4 := p_tax_out_rec.global_attribute4;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute5 := p_tax_out_rec.global_attribute5;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute6 := p_tax_out_rec.global_attribute6;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute7 := p_tax_out_rec.global_attribute7;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute8 := p_tax_out_rec.global_attribute8;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute9 := p_tax_out_rec.global_attribute9;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute10 := p_tax_out_rec.global_attribute10;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute11 := p_tax_out_rec.global_attribute11;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute12 := p_tax_out_rec.global_attribute12;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute13 := p_tax_out_rec.global_attribute13;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute14 := p_tax_out_rec.global_attribute14;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute15 := p_tax_out_rec.global_attribute15;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute16 := p_tax_out_rec.global_attribute16;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute17 := p_tax_out_rec.global_attribute17;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute18 := p_tax_out_rec.global_attribute18;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute19 := p_tax_out_rec.global_attribute19;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute20 := p_tax_out_rec.global_attribute20;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute_category := p_tax_out_rec.global_attribute_category;


  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ROUNDING_LVL_PARTY_TAX_PROF_ID := p_tax_out_rec.ROUNDING_LVL_PARTY_TAX_PROF_ID;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ROUNDING_LVL_PARTY_TYPE	    := p_tax_out_rec.ROUNDING_LVL_PARTY_TYPE;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).MRC_TAX_LINE_FLAG                :=  NVL(p_tax_out_rec.MRC_TAX_LINE_FLAG              ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).OFFSET_FLAG                      :=  NVL(p_tax_out_rec.OFFSET_FLAG                    ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).PROCESS_FOR_RECOVERY_FLAG        :=  NVL(p_tax_out_rec.PROCESS_FOR_RECOVERY_FLAG      ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).COMPOUNDING_TAX_FLAG             :=  NVL(p_tax_out_rec.COMPOUNDING_TAX_FLAG           ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_APPORTIONMENT_FLAG           :=  NVL(p_tax_out_rec.TAX_APPORTIONMENT_FLAG         ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).HISTORICAL_FLAG                  :=  NVL(p_tax_out_rec.HISTORICAL_FLAG                ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).CANCEL_FLAG                      :=  NVL(p_tax_out_rec.CANCEL_FLAG                    ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).PURGE_FLAG                       :=  NVL(p_tax_out_rec.PURGE_FLAG                     ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).DELETE_FLAG                      :=  NVL(p_tax_out_rec.DELETE_FLAG                    ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).SELF_ASSESSED_FLAG               :=  NVL(p_tax_out_rec.SELF_ASSESSED_FLAG             ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).OVERRIDDEN_FLAG                  :=  NVL(p_tax_out_rec.OVERRIDDEN_FLAG                ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).MANUALLY_ENTERED_FLAG            :=  NVL(p_tax_out_rec.MANUALLY_ENTERED_FLAG          ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).REPORTING_ONLY_FLAG              :=  NVL(p_tax_out_rec.REPORTING_ONLY_FLAG            ,'Y');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).FREEZE_UNTIL_OVERRIDDEN_FLAG     :=  NVL(p_tax_out_rec.FREEZE_UNTIL_OVERRIDDEN_FLAG   ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).COPIED_FROM_OTHER_DOC_FLAG       :=  NVL(p_tax_out_rec.COPIED_FROM_OTHER_DOC_FLAG     ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).RECALC_REQUIRED_FLAG             :=  NVL(p_tax_out_rec.RECALC_REQUIRED_FLAG           ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).SETTLEMENT_FLAG                  :=  NVL(p_tax_out_rec.SETTLEMENT_FLAG                ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ITEM_DIST_CHANGED_FLAG           :=  NVL(p_tax_out_rec.ITEM_DIST_CHANGED_FLAG         ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ASSOCIATED_CHILD_FROZEN_FLAG     :=  NVL(p_tax_out_rec.ASSOCIATED_CHILD_FROZEN_FLAG   ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_ONLY_LINE_FLAG               :=  NVL(p_tax_out_rec.TAX_ONLY_LINE_FLAG             ,'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ENFORCE_FROM_NATURAL_ACCT_FLAG   :=  NVL(p_tax_out_rec.ENFORCE_FROM_NATURAL_ACCT_FLAG ,'N');
  --ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_AMT_INCLUDED_FLAG            :=  NVL(p_tax_out_rec.amount_includes_tax_flag, 'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_AMT_INCLUDED_FLAG            :=  NVL(p_tax_out_rec.TAX_AMT_INCLUDED_FLAG, 'N');
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).compounding_dep_tax_flag         :=  NVL(p_tax_out_rec.compounding_dep_tax_flag, 'N');

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_APPORTIONMENT_LINE_NUMBER    :=  NVL(p_tax_out_rec.TAX_APPORTIONMENT_LINE_NUMBER  , 1 );
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).RECORD_TYPE_CODE                 :=  'ETAX_CREATED';

  -- exempt columns N/A for LTE
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).exempt_certificate_number := zx_global_structures_pkg.trx_line_dist_tbl.exempt_certificate_number(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).exempt_reason             := zx_global_structures_pkg.trx_line_dist_tbl.exempt_reason(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_EXEMPTION_ID          := p_tax_out_rec.tax_exemption_id           ;

  -- columns read from zx_global_structures_pkg.trx_line_dist_tbl
  -- Commneted the populated of Tax_Code column because of column width mismatch : Bug#8722088
  -- ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_CODE          := zx_global_structures_pkg.trx_line_dist_tbl.output_tax_classification_code(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ADJUSTED_DOC_LINE_ID :=  zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).adjusted_doc_trx_id  :=  zx_global_structures_pkg.trx_line_dist_tbl.adjusted_doc_trx_id(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).Adjusted_doc_number  :=  zx_global_structures_pkg.trx_line_dist_tbl.Adjusted_doc_number(p_id_dist_tbl);

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_ID             := zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_LINE_ID        := zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_LEVEL_TYPE     := zx_global_structures_pkg.trx_line_dist_tbl.TRX_LEVEL_TYPE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_DATE           := zx_global_structures_pkg.trx_line_dist_tbl.TRX_DATE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).CONTENT_OWNER_ID         := zx_global_structures_pkg.trx_line_dist_tbl.FIRST_PTY_ORG_ID(p_id_dist_tbl)  ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLICATION_ID           := zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).INTERNAL_ORGANIZATION_ID := zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).INTERNAL_ORG_LOCATION_ID := zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORG_LOCATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ENTITY_CODE              := zx_global_structures_pkg.trx_line_dist_tbl.ENTITY_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).EVENT_CLASS_CODE         := zx_global_structures_pkg.trx_line_dist_tbl.EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).EVENT_TYPE_CODE          := zx_global_structures_pkg.trx_line_dist_tbl.EVENT_TYPE_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).DOC_EVENT_STATUS         := zx_global_structures_pkg.trx_line_dist_tbl.DOC_EVENT_STATUS(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).LEGAL_ENTITY_ID          := zx_global_structures_pkg.trx_line_dist_tbl.LEGAL_ENTITY_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ESTABLISHMENT_ID         := zx_global_structures_pkg.trx_line_dist_tbl.ESTABLISHMENT_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_LEVEL_TYPE           := zx_global_structures_pkg.trx_line_dist_tbl.TRX_LEVEL_TYPE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).UNIT_PRICE               := zx_global_structures_pkg.trx_line_dist_tbl.UNIT_PRICE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).line_amt                 := zx_global_structures_pkg.trx_line_dist_tbl.line_amt(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_line_quantity        := zx_global_structures_pkg.trx_line_dist_tbl.trx_line_quantity(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_EVENT_CLASS_CODE     := zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_EVENT_TYPE_CODE      := zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_TYPE_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_LINE_NUMBER          := zx_global_structures_pkg.trx_line_dist_tbl.trx_line_number(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).LINE_ASSESSABLE_VALUE    := zx_global_structures_pkg.trx_line_dist_tbl.ASSESSABLE_VALUE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_ID_LEVEL2            := zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL2(p_id_dist_tbl)      ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_ID_LEVEL3            := zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL3(p_id_dist_tbl)      ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_ID_LEVEL4            := zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL4(p_id_dist_tbl)      ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_ID_LEVEL5            := zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL5(p_id_dist_tbl)      ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_ID_LEVEL6            := zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL6(p_id_dist_tbl)      ;

  /** not found in trx_line_dist_tbl
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_USER_KEY_LEVEL1      := zx_global_structures_pkg.trx_line_dist_tbl.TRX_USER_KEY_LEVEL1(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_USER_KEY_LEVEL2      := zx_global_structures_pkg.trx_line_dist_tbl.TRX_USER_KEY_LEVEL2(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_USER_KEY_LEVEL3      := zx_global_structures_pkg.trx_line_dist_tbl.TRX_USER_KEY_LEVEL3(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_USER_KEY_LEVEL4      := zx_global_structures_pkg.trx_line_dist_tbl.TRX_USER_KEY_LEVEL4(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_USER_KEY_LEVEL5      := zx_global_structures_pkg.trx_line_dist_tbl.TRX_USER_KEY_LEVEL5(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_USER_KEY_LEVEL6      := zx_global_structures_pkg.trx_line_dist_tbl.TRX_USER_KEY_LEVEL6(p_id_dist_tbl);
  */

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_CURRENCY_CODE             := zx_global_structures_pkg.trx_line_dist_tbl.TRX_CURRENCY_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).CURRENCY_CONVERSION_DATE      := zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).CURRENCY_CONVERSION_TYPE      := zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).CURRENCY_CONVERSION_RATE      := zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(p_id_dist_tbl);

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).LEDGER_ID                 := zx_global_structures_pkg.trx_line_dist_tbl.LEDGER_ID(p_id_dist_tbl) ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).minimum_accountable_unit  := zx_global_structures_pkg.trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).precision                 := zx_global_structures_pkg.trx_line_dist_tbl.PRECISION(p_id_dist_tbl) ;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_number                := zx_global_structures_pkg.trx_line_dist_tbl.TRX_NUMBER(p_id_dist_tbl) ;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).HQ_ESTB_PARTY_TAX_PROF_ID := zx_global_structures_pkg.trx_line_dist_tbl.HQ_ESTB_PARTY_TAX_PROF_ID(p_id_dist_tbl) ;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).REF_DOC_APPLICATION_ID     := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_APPLICATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).REF_DOC_ENTITY_CODE        := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_ENTITY_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).REF_DOC_EVENT_CLASS_CODE   := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).REF_DOC_TRX_ID             := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).REF_DOC_LINE_ID            := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).REF_DOC_TRX_LEVEL_TYPE     := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_LEVEL_TYPE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).REF_DOC_LINE_QUANTITY      := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_QUANTITY(p_id_dist_tbl);

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_FROM_APPLICATION_ID      := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_APPLICATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_FROM_EVENT_CLASS_CODE    := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_FROM_ENTITY_CODE         := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_ENTITY_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_FROM_TRX_ID              := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_FROM_LINE_ID             := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_LINE_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_FROM_TRX_LEVEL_TYPE      := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_LEVEL_TYPE(p_id_dist_tbl);

  /** not found in trx_line_dist_tbl ? check with TSRM team
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_FROM_TRX_NUMBER          := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_NUMBER(p_id_dist_tbl);
  */

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ADJUSTED_DOC_APPLICATION_ID      := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ADJUSTED_DOC_ENTITY_CODE         := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE	(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ADJUSTED_DOC_EVENT_CLASS_CODE    := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ADJUSTED_DOC_TRX_ID	            := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ADJUSTED_DOC_LINE_ID             := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ADJUSTED_DOC_TRX_LEVEL_TYPE      := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ADJUSTED_DOC_NUMBER	            := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_NUMBER(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ADJUSTED_DOC_DATE	              := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_DATE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_TO_APPLICATION_ID	      := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_APPLICATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_TO_EVENT_CLASS_CODE      := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_TO_ENTITY_CODE           := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_ENTITY_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_TO_TRX_ID	              := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_TO_LINE_ID	              := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LINE_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLIED_TO_TRX_LEVEL_TYPE        := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LEVEL_TYPE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_LINE_DATE                    := zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DATE(p_id_dist_tbl);
  -- LTE view should populate the following columns
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).RELATED_DOC_APPLICATION_ID       := zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_APPLICATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).RELATED_DOC_ENTITY_CODE          := zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_ENTITY_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).RELATED_DOC_EVENT_CLASS_CODE     := zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).RELATED_DOC_TRX_ID               := zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_TRX_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).RELATED_DOC_NUMBER               := zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_NUMBER(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).RELATED_DOC_DATE                 := zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_DATE(p_id_dist_tbl);


  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                 'Calling ZX_TDS_UTILITIES_PKG.get_tax_cache_info to populate tax_cache...');
  END IF;

  -- populate tax_regime_cache_info
  --
  -- Bug#5395227- get tax_regime_id if it is null
  --
  IF p_tax_out_rec.tax_regime_id IS NULL THEN
    ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
                        p_tax_out_rec.tax_regime_code,
			p_tax_out_rec.TRX_DATE,
			l_tax_regime_rec,
			l_return_status,
			l_error_buffer);

    IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                p_new_row_num).tax_regime_id := l_tax_regime_rec.tax_regime_id;

    ELSE
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_UTILITIES_PKG.get_regime_cache_info()');
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                      'RETURN_STATUS = ' || l_return_status);
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line.END',
                      'ZX_PRODUCT_INTEGRATION_PKG.' ||
                      'prepare_detail_tax_line(-)');
      END IF;
      RETURN;
    END IF;
  ELSE
    -- Bug#5395227
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                p_new_row_num).tax_regime_id := p_tax_out_rec.tax_regime_id;
  END IF;

  -- populate tax_cache in Tax Determination Services for tail end processing
  -- Bug#5395227- call cache structure to get place of supply
  -- type code
  --
  ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
  	p_tax_regime_code     =>  p_tax_out_rec.TAX_REGIME_CODE,
  	p_tax                 =>  p_tax_out_rec.TAX,
  	p_tax_determine_date  =>  p_tax_out_rec.TRX_DATE,
  	x_tax_rec             =>  l_tax_rec,
  	p_return_status       =>  l_return_status,
  	p_error_buffer        =>  l_error_buffer);

  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_id := l_tax_Rec.TAX_id;

    IF l_tax_rec.Def_Place_Of_Supply_Type_Code = 'SHIP_TO_BILL_TO' then
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).PLACE_OF_SUPPLY_TYPE_CODE  := 'SHIP_TO';
    ELSE
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).PLACE_OF_SUPPLY_TYPE_CODE  := l_tax_rec.Def_Place_Of_Supply_Type_Code;
    END IF;
    --
    -- Bug#5439803- not Credit memo, tax currency conversion type is
    -- from exchange rate type of tax record
    --
    IF (pg_cm_type <> 'Applied' OR pg_cm_type IS NULL)  THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_currency_conversion_type := l_tax_rec.exchange_rate_type;
    END IF;

  ELSE
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_tax_cache_info()');
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                    'RETURN_STATUS = ' || l_return_status);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line.END',
                    'ZX_PRODUCT_INTEGRATION_PKG.' ||
                    'prepare_detail_tax_line(-)');
    END IF;
    RETURN;
  END IF;

  IF p_tax_out_rec.TAX_JURISDICTION_CODE IS NOT NULL THEN

       ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info(
  	p_tax_regime_code     =>  p_tax_out_rec.TAX_REGIME_CODE,
  	p_tax                 =>  p_tax_out_rec.TAX,
        p_tax_jurisdiction_code => p_tax_out_rec.TAX_JURISDICTION_CODE,
  	p_tax_determine_date  =>  p_tax_out_rec.TRX_DATE,
  	x_jurisdiction_rec    =>  l_tax_jurisdiction_rec,
  	p_return_status       =>  l_return_status,
  	p_error_buffer        =>  l_error_buffer);

      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_jurisdiction_id
        := l_tax_jurisdiction_rec.tax_jurisdiction_id;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                          'Incorrect return_status after calling ' ||
                          'ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info()');
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                          'RETURN_STATUS = ' || l_return_status);
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line.END',
                          'ZX_PRODUCT_INTEGRATION_PKG.' ||
                          'prepare_detail_tax_line(-)');
          END IF;
          RETURN;
      END IF;

    END IF;  --p_tax_out_rec.TAX_JURISDICTION_CODE IS NOT NULL

  -- populate tax_status_cahce_info
  --
  -- Bug#5395227- get tax_status_id only if it is null
  --
  IF p_tax_out_rec.tax_status_id IS NULL THEN
    ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
			p_tax_out_rec.tax,
			p_tax_out_rec.tax_regime_code,
			p_tax_out_rec.tax_status_code,
			p_tax_out_rec.TRX_DATE,
			l_tax_status_rec,
			l_return_status,
			l_error_buffer);

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
                p_new_row_num).tax_status_id := l_tax_status_rec.tax_status_id;
    ELSE
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info()');
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                       'RETURN_STATUS = ' || l_return_status);
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line.END',
                       'ZX_PRODUCT_INTEGRATION_PKG.' ||
                       'prepare_detail_tax_line(-)');
       END IF;
       RETURN;
     END IF;
   ELSE
     -- bug#5395227
     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_status_id := p_tax_out_rec.tax_status_id;
   END IF;

  ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
    p_tax_regime_code       =>  p_tax_out_rec.TAX_REGIME_CODE,
    p_tax                   =>  p_tax_out_rec.TAX,
    p_tax_jurisdiction_code =>  NULL,
    p_tax_status_code       =>  p_tax_out_rec.TAX_STATUS_CODE,
    p_tax_rate_code         =>  p_tax_out_rec.TAX_RATE_CODE,
    p_tax_determine_date    =>  p_tax_out_rec.TRX_DATE,
    p_tax_class             =>  'OUTPUT',
    p_tax_rate_rec          =>  l_tax_rate_rec,
    p_return_status         =>  l_return_status,
    p_error_buffer          =>  l_error_buffer);

  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAXABLE_BASIS_FORMULA
                  := NVL(l_tax_rate_rec.taxable_basis_formula_code, l_tax_rec.def_taxable_basis_formula);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_CALCULATION_FORMULA
                  := l_tax_rec.def_tax_calc_formula;
  ELSE
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_tax_rate_info()');
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                    'RETURN_STATUS = ' || l_return_status);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line.END',
                    'ZX_PRODUCT_INTEGRATION_PKG.' ||
                    'prepare_detail_tax_line(-)');
    END IF;
    RETURN;
  END IF;

  -- bug#5395227
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_rate_id := p_tax_out_rec.tax_rate_id;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                  'Populating tax_regime_id, tax_id, tax_status_id and tax_rate_id...');
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                  'tax_regime_id := ' ||
                  TO_CHAR(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_regime_id));
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                  'tax_id := ' ||
                  TO_CHAR(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_id));
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                  'tax_jurisdiction_id := ' ||
                  TO_CHAR(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_jurisdiction_id));
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                  'tax_status_id := ' ||
                  TO_CHAR(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_status_id));
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                  'tax_rate_id := ' ||
                  TO_CHAR(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_rate_id));
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                 'Tax_line_id: '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_line_id);
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                 'Application_id: '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).APPLICATION_ID);
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                 'Entity_code: '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).Entity_code);
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                 'Event Class Code: '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).EVENT_CLASS_CODE);
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                 'Trx_id: '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).Trx_ID);
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                 'Trx_level_type: '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_LEVEL_TYPE);
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                 'Trx_line_id: '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TRX_LINE_ID);
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                 'Tax Regime Code: '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX_REGIME_CODE);
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                 'Tax : '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).TAX);
  END IF;

/* -- followin columns need to be added in
REPORTING_PERIOD_ID	NUMBER 	Y
TAX_EXCEPTION_ID	N.A. for LTE
TAX_RATE_BEFORE_EXCEPTION	N.A. for LTE
TAX_RATE_NAME _BEFORE_EXCEPTION	N.A. for LTE
TAX_EXEMPTION_ID	N.A. for LTE
TAX_RATE_BEFORE_EXEMPTION	N.A. for LTE
TAX_RATE_NAME_BEFORE_EXEMPTION	N.A. for LTE
EXEMPT_RATE_MODIFIER	N.A. for LTE
EXEMPT_CERTIFICATE_NUMBER	N/A For LTE	Copied from tsrm global structure
EXEMPT_REASON	N/A For LTE	Copied from tsrm global structure
EXEMPT_REASON_CODE	N/A For LTE	Copied from tsrm global structure
EXCEPTION_RATE	N.A. for LTE

CAL_TAX_AMT	N.A. (used for thresholds)	LTE
CAL_TAX_AMT_TAX_CURR	 rounding package will populate this.
CAL_TAX_AMT_FUNCL_CURR	 rounding package will populate this.

SUMMARY_TAX_LINE_ID	TRR	TRR
TAX_AMT_TAX_CURR	NULL	TRR (Tail end service)
TAX_AMT_FUNCL_CURR	NULL	TRR (Tail end service)
TAXABLE_AMT_TAX_CURR	Output	TRR (Tail end service)
TAXABLE_AMT_FUNCL_CURR	Output	TRR (Tail end service)
REPORTING_CURRENCY_CODE	Tail End service	TRR
MRC_TAX_LINE_FLAG	Tail End service	TRR
TRX_LINE_INDEX  TRR

============================
TAX_CODE	Input (tax classification code)	Copied from tsrm global structure

ROUNDING_LVL_PARTY_TAX_PROF_ID		LTE
ROUNDING_LVL_PARTY_TYPE	        Hard Coded	LTE
ROUNDING_LEVEL_CODE	LINE	LTE
ROUNDING_RULE_CODE	Output	LTE

CTRL_TOTAL_LINE_TX_AMT	 N.A  LTE
COMPOUNDING_MISS_FLAG    N.A LTE  LTE raise error in this case
==============================
*/

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line.END',
                 'ZX_PRODUCT_INTEGRATION_PKG: prepare_detail_tax_lines (-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.prepare_detail_tax_line',
                  sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    RAISE;
END prepare_detail_tax_line;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   create_detail_tax_line                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   Modified as a fix for Bug#7530930                                       |
+============================================================================*/
 PROCEDURE create_detail_tax_line (
  p_event_class_rec IN zx_api_pub.event_class_rec_type,
  p_tax_line_rec    IN tax_line_rec_type,
  p_id_dist_tbl     IN NUMBER,
  p_new_row_num     IN NUMBER,
  x_return_status   OUT NOCOPY VARCHAR2) IS

 l_tax_regime_rec	ZX_GLOBAL_STRUCTURES_PKG.tax_regime_rec_type;
 l_tax_rec		    ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
 l_tax_status_rec	ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
 l_tax_jurisdiction_rec ZX_TDS_UTILITIES_PKG.zx_jur_info_cache_rec_type;

 l_tax_date             DATE;
 l_tax_determine_date   DATE;
 l_tax_point_date       DATE;
 l_error_buffer         VARCHAR2(240);
 l_return_status        VARCHAR2(1);

 -- Start : Added for Bug#8669930
 l_adjusted_doc_tax_line_id  ZX_LINES.adjusted_doc_tax_line_id%TYPE;

 CURSOR get_adjusted_doc_tax_line_id
            (c_tax_regime_code            zx_regimes_b.tax_regime_code%TYPE,
             c_tax                        zx_taxes_b.tax%TYPE,
             c_apportionment_line_number  zx_lines.tax_apportionment_line_number%type) IS
    SELECT tax_line_id FROM zx_lines
     WHERE application_id =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_id_dist_tbl)
       AND entity_code =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(p_id_dist_tbl)
       AND event_class_code  =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(p_id_dist_tbl)
       AND trx_id =
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id( p_id_dist_tbl)
       AND trx_line_id =
            NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(p_id_dist_tbl), trx_line_id)
       AND trx_level_type =
            NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(p_id_dist_tbl), trx_level_type)
       AND (tax_provider_id IS NULL
            OR ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_id_dist_tbl) = 'ALLOCATE_TAX_ONLY_ADJUSTMENT')
       AND Cancel_Flag <> 'Y'
       AND offset_link_to_tax_line_id IS NULL
       AND mrc_tax_line_flag = 'N'
       AND tax = c_tax
       AND tax_regime_code = c_tax_regime_code
       AND tax_apportionment_line_number = c_apportionment_line_number;
 -- End : Added for Bug#8669930

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line.BEGIN',
               'ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line(+)');

    FND_LOG.STRING(g_level_event,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
               'new tax line created (tax := '|| p_tax_line_rec.tax || ')');
    FND_LOG.STRING(g_level_event,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
               'tax_regime_code := '|| p_tax_line_rec.tax_regime_code);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  get tax date
  ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date(
                                p_id_dist_tbl,
                                l_tax_date,
                                l_tax_determine_date,
                                l_tax_point_date,
                                x_return_status);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
             'Incorrect return_status after calling ' ||
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date()');
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line.END',
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line(-)');
    END IF;
    RETURN;
  END IF;

  -- populate tax_regime_cache_info
  ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
			p_tax_line_rec.tax_regime_code,
			l_tax_determine_date,
			l_tax_regime_rec,
			x_return_status,
			l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_regime_cache_info()');
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                    'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line.END',
                    'ZX_PRODUCT_INTEGRATION_PKG.' ||
                    'create_detail_tax_line(-)');
    END IF;
    RETURN;
  END IF;

  -- populate tax cache, if it does not exist there.
  ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
           p_tax_line_rec.tax_regime_code,
           p_tax_line_rec.tax,
           l_tax_determine_date,
           l_tax_rec,
           x_return_status,
           l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_tax_cache_info()');
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                    'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line.END',
                    'ZX_PRODUCT_INTEGRATION_PKG.' ||
                    'create_detail_tax_line(-)');
    END IF;
    RETURN;
  END IF;

  IF p_tax_line_rec.TAX_JURISDICTION_CODE IS NOT NULL THEN
    ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info(
  	p_tax_regime_code     =>  p_tax_line_rec.TAX_REGIME_CODE,
  	p_tax                 =>  p_tax_line_rec.TAX,
  	p_tax_jurisdiction_code => p_tax_line_rec.TAX_JURISDICTION_CODE,
  	p_tax_determine_date  =>  l_tax_determine_date,
  	x_jurisdiction_rec    =>  l_tax_jurisdiction_rec,
  	p_return_status       =>  l_return_status,
  	p_error_buffer        =>  l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                      'Incorrect return_status after calling ' ||
                      'ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info()');
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                      'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line.END',
                      'ZX_PRODUCT_INTEGRATION_PKG.' ||
                      'create_detail_tax_line(-)');
      END IF;
      RETURN;
    END IF;
  END IF;

  -- populate tax_status_cahce_info
  ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
			p_tax_line_rec.tax,
			p_tax_line_rec.tax_regime_code,
			p_tax_line_rec.tax_status_code,
			l_tax_determine_date,
			l_tax_status_rec,
			x_return_status,
			l_error_buffer);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info()');
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                    'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line.END',
                    'ZX_PRODUCT_INTEGRATION_PKG.' ||
                    'create_detail_tax_line(-)');
    END IF;
    RETURN;
  END IF;

  -- populate tax_regime_id, tax_id, tax_status_id, tax_rate_id
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_regime_id       := l_tax_regime_rec.tax_regime_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_id              := l_tax_rec.tax_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_status_id       := l_tax_status_rec.tax_status_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_jurisdiction_id := l_tax_jurisdiction_rec.tax_jurisdiction_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_rate_id         := p_tax_line_rec.tax_rate_id;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                  'Populating tax_regime_id, tax_id, tax_status_id and tax_rate_id...');
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                  'tax_regime_id := ' || ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_regime_id||
                  ' tax_id := '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_id||
                  ' tax_status_id := '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_status_id||
                  ' tax_jurisdiction_id := '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_jurisdiction_id||
                  ' tax_rate_id := '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_rate_id);

  END IF;

  -- populate data from summary tax line
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_regime_code       := p_tax_line_rec.tax_regime_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax                   := p_tax_line_rec.tax;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_status_code       := p_tax_line_rec.tax_status_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_rate_code         := p_tax_line_rec.tax_rate_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_rate              := p_tax_line_rec.tax_rate;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_jurisdiction_code := p_tax_line_rec.tax_jurisdiction_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_amt_included_flag := p_tax_line_rec.tax_amt_included_flag;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_exception_id      := p_tax_line_rec.tax_exception_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_exemption_id      := p_tax_line_rec.tax_exemption_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).exempt_reason_code    := p_tax_line_rec.exempt_reason_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).exempt_certificate_number := p_tax_line_rec.exempt_certificate_number;

  -- populate rounding_lvl_party_tax_prof_id and rounding_level_code
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).rounding_lvl_party_tax_prof_id := ZX_TDS_CALC_SERVICES_PUB_PKG.g_rnd_lvl_party_tax_prof_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).rounding_lvl_party_type        := ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_lvl_party_type;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).rounding_level_code            := ZX_TDS_CALC_SERVICES_PUB_PKG.g_rounding_level;

  -- populate tax dates
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_date           := l_tax_date;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_determine_date := l_tax_determine_date;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_point_date     := l_tax_point_date;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).taxable_basis_formula    := l_tax_rec.def_taxable_basis_formula;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_calculation_formula  := l_tax_rec.def_tax_calc_formula;

  -- bug 3282018: set manually_entered_flag='Y', last_manual_entry='TAX_AMOUNT'
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).manually_entered_flag := 'Y';
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).last_manual_entry     := 'TAX_AMOUNT';

  -- set self_assesses_flag = 'N' for all detail tax lines created from summary tax lines
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).self_assessed_flag := 'N';

  -- set proration_code
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).proration_code := 'REGULAR_IMPORT';

  -- populate mandatory columns
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).internal_organization_id := p_tax_line_rec.internal_organization_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).application_id           := p_event_class_rec.application_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).entity_code              := p_event_class_rec.entity_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).event_class_code         := p_event_class_rec.event_class_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).event_type_code          := p_event_class_rec.event_type_code;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_id                   := p_event_class_rec.trx_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).content_owner_id         := p_event_class_rec.first_pty_org_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_line_id              := p_tax_line_rec.trx_line_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_level_type           := p_tax_line_rec.trx_level_type;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).line_amt                 := p_tax_line_rec.line_amt;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_date                 := p_tax_line_rec.trx_date;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).minimum_accountable_unit := p_tax_line_rec.minimum_accountable_unit;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).precision                := p_tax_line_rec.precision;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_line_date            := p_tax_line_rec.trx_line_date;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_currency_code        := zx_global_structures_pkg.trx_line_dist_tbl.TRX_CURRENCY_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).currency_conversion_date := zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).currency_conversion_type := zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).currency_conversion_rate := zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ledger_id                := zx_global_structures_pkg.trx_line_dist_tbl.LEDGER_ID(p_id_dist_tbl) ;

  IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
     ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).legal_reporting_status :=  l_tax_rec.legal_reporting_status_def_val;
  END IF;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).interface_tax_line_id := p_tax_line_rec.interface_tax_line_id;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).interface_entity_code := p_tax_line_rec.interface_entity_code;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).internal_org_location_id := zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORG_LOCATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).doc_event_status         := zx_global_structures_pkg.trx_line_dist_tbl.DOC_EVENT_STATUS(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).legal_entity_id          := zx_global_structures_pkg.trx_line_dist_tbl.LEGAL_ENTITY_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).establishment_id         := zx_global_structures_pkg.trx_line_dist_tbl.ESTABLISHMENT_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).unit_price               := zx_global_structures_pkg.trx_line_dist_tbl.UNIT_PRICE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_line_quantity        := zx_global_structures_pkg.trx_line_dist_tbl.trx_line_quantity(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_event_class_code     := zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_event_type_code      := zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_TYPE_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_line_number          := zx_global_structures_pkg.trx_line_dist_tbl.trx_line_number(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).line_assessable_value    := zx_global_structures_pkg.trx_line_dist_tbl.ASSESSABLE_VALUE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_id_level2            := zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL2(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_id_level3            := zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL3(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_id_level4            := zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL4(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_id_level5            := zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL5(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_id_level6            := zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL6(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).trx_number               := zx_global_structures_pkg.trx_line_dist_tbl.TRX_NUMBER(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).hq_estb_party_tax_prof_id:= zx_global_structures_pkg.trx_line_dist_tbl.HQ_ESTB_PARTY_TAX_PROF_ID(p_id_dist_tbl);

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ref_doc_application_id        := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_APPLICATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ref_doc_entity_code           := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_ENTITY_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ref_doc_event_class_code      := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ref_doc_trx_id	               := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ref_doc_line_id	             := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ref_doc_trx_level_type        := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_LEVEL_TYPE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).ref_doc_line_quantity         := zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_QUANTITY(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).applied_from_application_id   := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_APPLICATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).applied_from_event_class_code := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).applied_from_entity_code      := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_ENTITY_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).applied_from_trx_id	         := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).applied_from_line_id	         := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_LINE_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).applied_from_trx_level_type   := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_LEVEL_TYPE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).adjusted_doc_application_id   := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).adjusted_doc_entity_code	     := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE	(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).adjusted_doc_event_class_code := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).adjusted_doc_trx_id	         := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).adjusted_doc_line_id	         := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).adjusted_doc_trx_level_type   := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).adjusted_doc_number	         := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_NUMBER(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).adjusted_doc_date	           := zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_DATE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).applied_to_application_id	   := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_APPLICATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).applied_to_event_class_code   := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).applied_to_entity_code	       := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_ENTITY_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).applied_to_trx_id	           := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).applied_to_line_id	           := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LINE_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).applied_to_trx_level_type     := zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LEVEL_TYPE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).related_doc_application_id    := zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_APPLICATION_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).related_doc_entity_code       := zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_ENTITY_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).related_doc_event_class_code  := zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_EVENT_CLASS_CODE(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).related_doc_trx_id            := zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_TRX_ID(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).related_doc_number            := zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_NUMBER(p_id_dist_tbl);
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).related_doc_date              := zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_DATE(p_id_dist_tbl);

  -- Populating column GDF11 with line amount
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute11        := p_tax_line_rec.line_amt;
  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).global_attribute_category := zx_global_structures_pkg.trx_line_dist_tbl.global_attribute_category(p_id_dist_tbl);

  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_id_dist_tbl) IS NOT NULL THEN
    OPEN get_adjusted_doc_tax_line_id(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_regime_code,
                                      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax,
                                      NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).tax_apportionment_line_number, 1));

    FETCH get_adjusted_doc_tax_line_id INTO l_adjusted_doc_tax_line_id;

    IF get_adjusted_doc_tax_line_id%FOUND THEN
       ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(p_new_row_num).adjusted_doc_tax_line_id := l_adjusted_doc_tax_line_id;
       IF (g_level_event >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_event,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                'l_adjusted_doc_tax_line_id: ' || l_adjusted_doc_tax_line_id);
       END IF;
    END IF;
    CLOSE get_adjusted_doc_tax_line_id;
  END IF;

  IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                  'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_event,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line.END',
                  'ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line.END',
                    'ZX_PRODUCT_INTEGRATION_PKG.create_detail_tax_line(-)');
    END IF;

END create_detail_tax_line;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   get_tax_rate_id                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
+===========================================================================*/

PROCEDURE  get_tax_rate_id (
  p_tax_regime_code	    IN		 VARCHAR2,
  p_tax                     IN	         VARCHAR2,
  p_tax_status_code         IN           VARCHAR2,
  p_tax_rate_code           IN           VARCHAR2,
  p_tax_determine_date      IN		 DATE,
  p_tax_jurisdiction_code   IN           VARCHAR2,
  x_tax_rate_id 	    OUT NOCOPY	 NUMBER,
  x_return_status           OUT NOCOPY   VARCHAR2,
  x_error_buffer            OUT NOCOPY   VARCHAR2) IS

/* Bug#5395227 -- use cache structure

  CURSOR fetch_tax_rate_id IS
  SELECT tax_rate_id
    FROM ZX_SCO_RATES
   WHERE tax_regime_code = p_tax_regime_code
     AND tax = p_tax
     AND tax_status_code = p_tax_status_code
     AND tax_rate_code = p_tax_rate_code
     AND active_flag   = 'Y'
     AND ( p_tax_determine_date >= effective_from AND
          (p_tax_determine_date <= effective_to OR effective_to IS NULL));

*/
  -- Bug#5395227
  l_tax_rate_rec       ZX_TDS_UTILITIES_PKG.ZX_RATE_INFO_REC_TYPE;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id.BEGIN',
                  'ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id(+)');
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id',
                  'tax_regime_code = ' || p_tax_regime_code);
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id',
                  'tax_ = ' || p_tax);
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id',
                  'tax_status_code = ' || p_tax_status_code);
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id',
                  'tax_rate_code = ' || p_tax_rate_code);
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id',
                  'p_tax_determine_date = ' || p_tax_determine_date);
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id',
                  'p_tax_jurisdiction_code = ' || p_tax_jurisdiction_code);

  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Bug#5395227- use cache structure
  OPEN  fetch_tax_rate_id;
  FETCH fetch_tax_rate_id INTO  x_tax_rate_id;
  CLOSE fetch_tax_rate_id;
  */

  /* 5395227- this procedure get_tax_rate_id is
     currently not used
  ZX_TDS_UTILITIES_PKG.get_tax_rate_info (
                 p_tax_regime_code,
                 p_tax,
                 p_tax_jurisdiction_code,
                 p_tax_status_code,
                 p_tax_rate_code,
                 p_tax_determine_date,
                 l_tax_rate_rec,
                 x_return_status,
                 x_error_buffer);

  */

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    x_tax_rate_id := l_tax_rate_rec.tax_rate_id;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id',
                  'tax_rate_id = ' || x_tax_rate_id);
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id',
                  'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id.END',
                  'ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id.END',
                    'ZX_PRODUCT_INTEGRATION_PKG.get_tax_rate_id(-)');
    END IF;

END get_tax_rate_id;

/*----------------------------------------------------------------------------*
 |Public Procedure                                                            |
 |  initialize_tax_info_rec                                                   |
 |                                                                            |
 |Description                                                                 |
 |  This procedure initialize all the attributes of tax_info_rec to NULL      |
 |                                                                            |
 |Called From                                                                 |
 |  ARP_PROCESS_TAX.calculate_tax_f_sql                                       |
 |                                                                            |
 |History                                                                     |
 |  01-SEP-98      TKOSHIO    CREATED                                         |
 *----------------------------------------------------------------------------*/
PROCEDURE INITIALIZE_TAX_INFO_REC is
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.initialize_tax_info_rec.BEGIN',
               'ZX_PRODUCT_INTEGRATION_PKG.initialize_tax_info_rec(+)');
  END IF;

  tax_info_rec.bill_to_cust_id:=NULL;
  tax_info_rec.ship_to_cust_id:=NULL;
  tax_info_rec.customer_trx_id:=NULL;
  tax_info_rec.trx_number:=NULL;
  tax_info_rec.bill_to_customer_number:=NULL;
  tax_info_rec.ship_to_customer_number:=NULL;
  tax_info_rec.bill_to_customer_name:=NULL;
  tax_info_rec.ship_to_customer_name:=NULL;
  tax_info_rec.previous_customer_trx_id:=NULL;
  tax_info_rec.previous_trx_number:=NULL;
  tax_info_rec.trx_date:=NULL;
  tax_info_rec.gl_date:=NULL;
  tax_info_rec.ship_to_site_use_id:=NULL;
  tax_info_rec.bill_to_site_use_id:=NULL;
  tax_info_rec.ship_to_postal_code:=NULL;
  tax_info_rec.bill_to_postal_code:=NULL;
  tax_info_rec.ship_to_location_id:=NULL;
  tax_info_rec.bill_to_location_id:=NULL;
  tax_info_rec.invoicing_rule_id:=NULL;
  tax_info_rec.fob_point:=NULL;
  tax_info_rec.trx_currency_code:=NULL;
  tax_info_rec.trx_exchange_rate:=NULL;
  tax_info_rec.minimum_accountable_unit:=NULL;
  tax_info_rec.precision:=NULL;
  tax_info_rec.tax_header_level_flag:=NULL;
  tax_info_rec.tax_rounding_rule:=NULL;
  /*-----------------------------------------------------------------------*/
  /*       Release 11 Transaction header data                              */
  /*-----------------------------------------------------------------------*/
  tax_info_rec.trx_type_id:=NULL;
  tax_info_rec.ship_from_warehouse_id:=NULL;
  tax_info_rec.payment_term_id:=NULL;
  /*-----------------------------------------------------------------------*/
  /*       Transaction Line Data                                           */
  /*-----------------------------------------------------------------------*/
  tax_info_rec.customer_trx_line_id:=NULL;
  tax_info_rec.previous_customer_trx_line_id:=NULL;
  tax_info_rec.link_to_cust_trx_line_id:=NULL;
  tax_info_rec.memo_line_id:=NULL;
  tax_info_rec.taxed_quantity:=NULL;
  tax_info_rec.inventory_item_id:=NULL;
  tax_info_rec.extended_amount:=NULL;
  tax_info_rec.entered_amount:=NULL;
  tax_info_rec.tax_code:=NULL;
  tax_info_rec.vat_tax_id:=NULL;
  tax_info_rec.tax_exemption_id:=NULL;
  tax_info_rec.item_exception_rate_id:=NULL;
  tax_info_rec.tax_rate:=NULL;
  tax_info_rec.default_ussgl_transaction_code:=NULL;
  tax_info_rec.default_ussgl_trx_code_context:=NULL;
  /*-----------------------------------------------------------------------*/
  /*       Release 11 Transaction Line data                                */
  /*-----------------------------------------------------------------------*/
  tax_info_rec.amount_includes_tax_flag:=NULL;
  tax_info_rec.taxable_basis:=NULL;
  tax_info_rec.tax_calculation_plsql_block:=NULL;
  tax_info_rec.payment_terms_discount_percent:=NULL;
  /*-----------------------------------------------------------------------*/
  /*       Tax Extension Parameters, these are defined specifically to     */
  /*                       support AVP(tm) and Vertex(tm)                  */
  /*-----------------------------------------------------------------------*/
  tax_info_rec.audit_flag:=NULL;
  tax_info_rec.qualifier:=NULL;
  tax_info_rec.ship_from_code:=NULL;
  tax_info_rec.ship_to_code:=NULL;
  tax_info_rec.poo_code:=NULL;
  tax_info_rec.poa_code:=NULL;
  tax_info_rec.vdrctrl_exempt:=NULL;
  tax_info_rec.tax_control:=NULL;
  tax_info_rec.xmpt_cert_no:=NULL;
  tax_info_rec.xmpt_reason:=NULL;
  tax_info_rec.xmpt_percent:=NULL;
  tax_info_rec.trx_line_type:=NULL;
  tax_info_rec.part_no:=NULL;
  tax_info_rec.division_code:=NULL;
  tax_info_rec.company_code:=NULL;
  /*-----------------------------------------------------------------------*/
  /*       Release 11 has 5 more character and numeric attributes.         */
  /*-----------------------------------------------------------------------*/
  tax_info_rec.userf1:=NULL;
  tax_info_rec.userf2:=NULL;
  tax_info_rec.userf3:=NULL;
  tax_info_rec.userf4:=NULL;
  tax_info_rec.userf5:=NULL;
  tax_info_rec.userf6:=NULL;
  tax_info_rec.userf7:=NULL;
  tax_info_rec.userf8:=NULL;
  tax_info_rec.userf9:=NULL;
  tax_info_rec.userf10:=NULL;
  tax_info_rec.usern1:=NULL;
  tax_info_rec.usern2:=NULL;
  tax_info_rec.usern3:=NULL;
  tax_info_rec.usern4:=NULL;
  tax_info_rec.usern5:=NULL;
  tax_info_rec.usern6:=NULL;
  tax_info_rec.usern7:=NULL;
  tax_info_rec.usern8:=NULL;
  tax_info_rec.usern9:=NULL;
  tax_info_rec.usern10:=NULL;
  tax_info_rec.calculate_tax:=NULL;
  /*-----------------------------------------------------------------------*/
  /*       Tax Line Data                                                   */
  /*-----------------------------------------------------------------------*/
  tax_info_rec.status:=NULL;
  tax_info_rec.credit_memo_flag:=NULL;
  tax_info_rec.tax_type:=NULL;
  tax_info_rec.sales_tax_id:=NULL;
  tax_info_rec.location_segment_id:=NULL;
  tax_info_rec.tax_line_number:=NULL;
  tax_info_rec.tax_amount:=NULL;
  tax_info_rec.tax_vendor_return_code:=NULL;
  tax_info_rec.tax_precedence:=NULL;
  tax_info_rec.compound_amount:=NULL;
  tax_info_rec.effective_tax_rate:=NULL;
  /*-----------------------------------------------------------------------*/
  /*       Global Descriptive Flexfields                                   */
  /*-----------------------------------------------------------------------*/
  tax_info_rec.global_attribute1:=NULL;
  tax_info_rec.global_attribute2:=NULL;
  tax_info_rec.global_attribute3:=NULL;
  tax_info_rec.global_attribute4:=NULL;
  tax_info_rec.global_attribute5:=NULL;
  tax_info_rec.global_attribute6:=NULL;
  tax_info_rec.global_attribute7:=NULL;
  tax_info_rec.global_attribute8:=NULL;
  tax_info_rec.global_attribute9:=NULL;
  tax_info_rec.global_attribute10:=NULL;
  tax_info_rec.global_attribute11:=NULL;
  tax_info_rec.global_attribute12:=NULL;
  tax_info_rec.global_attribute13:=NULL;
  tax_info_rec.global_attribute14:=NULL;
  tax_info_rec.global_attribute15:=NULL;
  tax_info_rec.global_attribute16:=NULL;
  tax_info_rec.global_attribute17:=NULL;
  tax_info_rec.global_attribute18:=NULL;
  tax_info_rec.global_attribute10:=NULL;
  tax_info_rec.global_attribute20:=NULL;
  tax_info_rec.global_attribute_category:=NULL;
  tax_info_rec.poo_id := NULL;
  tax_info_rec.poa_id := NULL;
  tax_info_rec.customer_trx_charge_line_id := NULL;
  tax_info_rec.taxable_amount := NULL;
  tax_info_rec.override_tax_rate := NULL;
--crm
  tax_info_rec.party_flag := NULL;


  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','initialize_tax_info_rec(-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.initialize_tax_info_rec',
                  sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.initialize_tax_info_rec.END',
                 'ZX_PRODUCT_INTEGRATION_PKG.initialize_tax_info_rec(-)');
    END IF;
    RAISE;
END INITIALIZE_TAX_INFO_REC;


/*----------------------------------------------------------------------------*
 | PUBLIC  PROCEDURE                                                          |
 |    dump_tax_info_rec ( p_IO_flag IN VARCHAR2 default 'O' )		      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure will dump members of tax_info_rec when debug is enabled. |
 |    The parameter p_IO_flag can have values 'I', 'O' or 'E'. The parameter  |
 |    p_IO_flag will be prefixed to the member names on output and is for     |
 |    informational purposes only. The default value for p_IO_flag is 'O'.    |
 |									      |
 | PARAMETERS                                                                 |
 |   THRU GLOBALS:                                                            |
 |      tax_info_rec               in tax_info_rec_type     		      |
 |                                                                            |
 | CALLED FROM                                                                |
 |    Calculate()                                                             |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |    14-NOV-95  Mahesh Sabapathy  Created.                                   |
 |    16-NOV-95  Mahesh Sabapathy  Added: parameter p_IO_flag and procedure   |
 |                                        made public.     		      |
 *----------------------------------------------------------------------------*/

PROCEDURE  dump_tax_info_rec(p_IO_flag  IN  VARCHAR2 ) IS
  l_IO_flag		CHAR(1);
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.dump_tax_info_rec.BEGIN',
                 'ZX_PRODUCT_INTEGRATION_PKG.dump_tax_info_rec(+)');
  END IF;

  IF ( p_IO_flag NOT IN ( 'I', 'E', 'O' ) ) THEN
	l_IO_flag := 'O';
  ELSE
   	l_IO_flag := p_IO_flag;
  END IF;

  --
  -- Dump tax_info_rec
  --
  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '************************' );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '**  Tax Info Record   **' );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '************************' );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Bill_to_cust_id = '
			||tax_info_rec.Bill_to_cust_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Ship_to_cust_id = '
			||tax_info_rec.Ship_to_cust_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Customer_trx_id = '
			||tax_info_rec.Customer_trx_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Trx_date = '||tax_info_rec.Trx_date );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': GL_date = '||tax_info_rec.gl_date );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Ship_to_site_use_id = '
			||tax_info_rec.Ship_to_site_use_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Bill_to_site_use_id = '
			||tax_info_rec.Bill_to_site_use_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Ship_to_postal_code = '
			||tax_info_rec.Ship_to_postal_code );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Bill_to_postal_code = '
			||tax_info_rec.Bill_to_postal_code );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Ship_to_location_id = '
			||tax_info_rec.Ship_to_location_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Bill_to_location_id = '
			||tax_info_rec.Bill_to_location_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Invoicing_rule_id = '
			||tax_info_rec.Invoicing_rule_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': FOB_point = '||tax_info_rec.FOB_point );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Trx_currency_code = '
			||tax_info_rec.Trx_currency_code );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Trx_exchange_rate = '
			||tax_info_rec.Trx_exchange_rate );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Minimum_accountable_unit = '
			||tax_info_rec.Minimum_accountable_unit );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Precision = '||tax_info_rec.Precision );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Customer_trx_line_id = '
			||tax_info_rec.Customer_trx_line_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': link_to_cust_trx_line_id = '
			||tax_info_rec.link_to_cust_trx_line_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Memo_line_id = '||tax_info_rec.Memo_line_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Taxed_quantity = '||tax_info_rec.Taxed_quantity );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Inventory_item_id = '||tax_info_rec.Inventory_item_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Extended_amount = '||tax_info_rec.Extended_amount );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Tax_code = '||tax_info_rec.Tax_code );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Vat_tax_id = '||tax_info_rec.Vat_tax_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Tax_exemption_id = '||tax_info_rec.Tax_exemption_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Item_exception_rate_id = '
			||tax_info_rec.Item_exception_rate_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Tax_rate = '||tax_info_rec.Tax_rate );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Default_ussgl_transaction_code = '
			||tax_info_rec.Default_ussgl_transaction_code );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Default_ussgl_trx_code_context = '
			||tax_info_rec.Default_ussgl_trx_code_context );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Tax_control = '||tax_info_rec.Tax_control );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Qualifier = '||tax_info_rec.Qualifier );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Ship_from_code = '||tax_info_rec.Ship_from_code );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Ship_to_code = '||tax_info_rec.Ship_to_code );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Poo_code = '||tax_info_rec.Poo_code );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Poa_code = '||tax_info_rec.Poa_code );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Vdrctrl_exempt = '||tax_info_rec.Vdrctrl_exempt );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Xmpt_cert_no = '||tax_info_rec.Xmpt_cert_no );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Xmpt_reason = '||tax_info_rec.Xmpt_reason );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Xmpt_percent = '||tax_info_rec.Xmpt_percent );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Part_no = '||tax_info_rec.Part_no );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Userf1 = '||tax_info_rec.Userf1 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Userf2 = '||tax_info_rec.Userf2 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Userf3 = '||tax_info_rec.Userf3 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Userf4 = '||tax_info_rec.Userf4 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Userf5 = '||tax_info_rec.Userf5 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Userf6 = '||tax_info_rec.Userf6 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Userf7 = '||tax_info_rec.Userf7 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Userf8 = '||tax_info_rec.Userf8 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Userf9 = '||tax_info_rec.Userf9 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Userf10 = '||tax_info_rec.Userf10 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Usern1 = '||tax_info_rec.Usern1 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Usern2 = '||tax_info_rec.Usern2 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Usern3 = '||tax_info_rec.Usern3 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Usern4 = '||tax_info_rec.Usern4 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Usern5 = '||tax_info_rec.Usern5 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Usern6 = '||tax_info_rec.Usern6 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Usern7 = '||tax_info_rec.Usern7 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Usern8 = '||tax_info_rec.Usern8 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Usern9 = '||tax_info_rec.Usern9 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Usern10 = '||tax_info_rec.Usern10 );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': trx_number = '||tax_info_rec.trx_number );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': previous_customer_trx_line_id = '||tax_info_rec.previous_customer_trx_line_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': previous_customer_trx_id = '||tax_info_rec.previous_customer_trx_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': previous_trx_number = '||tax_info_rec.previous_trx_number );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': bill_to_customer_number = '||tax_info_rec.bill_to_customer_number);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': ship_to_customer_number = '||tax_info_rec.ship_to_customer_number);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': bill_to_customer_name = '||tax_info_rec.bill_to_customer_name);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': ship_to_customer_name = '||tax_info_rec.ship_to_customer_name);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Audit_Flag = ' || tax_info_rec.audit_flag );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Trx_Line_Type = ' || tax_info_rec.trx_line_type );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Division Code = ' || tax_info_rec.division_code );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Company Code = '|| tax_info_rec.company_code );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Calculate_tax = '||tax_info_rec.Calculate_tax );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Status = '||tax_info_rec.Status );
  END IF;
  IF ( tax_info_rec.tax_type = 0 ) THEN
	dummy := 'TAX_TYPE_INACTIVE';
  ELSIF ( tax_info_rec.tax_type = 1 ) THEN
	dummy := 'TAX_TYPE_LOCATION';
  ELSIF ( tax_info_rec.tax_type = 2 ) THEN
	dummy := 'TAX_TYPE_SALES';
  ELSIF ( tax_info_rec.tax_type = 3 ) THEN
	dummy := 'TAX_TYPE_VAT';
  ELSE
	dummy := null;
  END IF;
  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Tax_type = '||dummy );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Sales_tax_id = '||tax_info_rec.Sales_tax_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Location_segment_id = '
			||tax_info_rec.Location_segment_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Tax_line_number = '
			||tax_info_rec.Tax_line_number );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Tax_amount = '||tax_info_rec.Tax_amount );
  END IF;
  IF ( tax_info_rec.tax_vendor_return_code = TAX_NO_VENDOR ) THEN
	dummy := 'TAX_NO_VENDOR';
  ELSE
	dummy := null;
  END IF;
  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Tax_vendor_return_code = '||dummy );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Tax_precedence = '
			||tax_info_rec.Tax_precedence );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Compound_amount = '
			||tax_info_rec.Compound_amount );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Tax_header_level_flag = '
			||tax_info_rec.Tax_header_level_flag );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Tax_rounding_rule = '
			||tax_info_rec.Tax_rounding_rule );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Trx_type_id = '
			||tax_info_rec.Trx_type_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Ship_From_Warehouse_id = '
			||tax_info_rec.Ship_From_Warehouse_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Amount_includes_tax_flag = '
			||tax_info_rec.Amount_includes_tax_flag );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Customer_trx_charge_line_id = '
			||tax_info_rec.customer_trx_charge_line_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Poo_id = '
			||tax_info_rec.poo_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Poa_id = '
			||tax_info_rec.poa_id );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Taxable_amount = '
			||tax_info_rec.taxable_amount );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Taxable_basis = '
			||tax_info_rec.taxable_basis );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Override Tax Rate = '
			||tax_info_rec.override_tax_rate );
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', '... '||l_IO_flag||': Party Flag = '
                        ||tax_info_rec.party_flag );
  END IF;


  --
  -- Finished dumping
  --
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.dump_tax_info_rec.END',
                 'ZX_PRODUCT_INTEGRATION_PKG.dump_tax_info_rec(-)');
  END IF;

END dump_tax_info_rec;


/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    Tax_Curr_Round ( p_amount           in                         	      |
 |                     p_trx_currency     in,                                 |
 |		       p_precision        in,                		      |
 |		       p_min_acct_unit    in,              		      |
 |                     p_rounding_rule    in                                  |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Given the parameters listed above, the function will return the amount  |
 |    rounded to the correct precision.                                       |
 |									      |
 | RETURNS                                                                    |
 |    Rounded amount.                                                         |
 |                                                                            |
 | HISTORY                                                                    |
 |    12/27/04  Nilesh Patel       Copied from arp_tax_compound               |
 |                                                                            |
 *----------------------------------------------------------------------------*/

FUNCTION tax_curr_round( p_amount  	     IN NUMBER,
			 p_trx_currency_code IN VARCHAR2,
			 p_precision 	     IN NUMBER,
			 p_min_acct_unit     IN NUMBER,
			 p_rounding_rule     IN VARCHAR2,
			 p_autotax_flag      IN VARCHAR2 )

/* p_autotax_flag is ignored in bugfix 378224 as all tax transactions must be rounded */
/* this includes manually imported tax amounts                                        */
                 RETURN NUMBER IS

  l_rounded_amount	NUMBER;
  l_precision           NUMBER;
  l_rounding_rule       VARCHAR2(30);
  l_min_acct_unit       NUMBER;
  l_round_adj		NUMBER;
  l_autotax_flag        VARCHAR2(1);

   PG_DEBUG varchar2(1);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.tax_curr_round.BEGIN',
                 'ZX_PRODUCT_INTEGRATION_PKG.tax_curr_round(+)');
  END IF;

  PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'ZX_PRODUCT_INTEGRATION_PKG.tax_curr_round( ' || p_amount || ' )+' );
  END IF;

  if p_rounding_rule not in ('UP','DOWN','NEAREST') then
     l_rounding_rule := 'NEAREST';
  else
     l_rounding_rule := p_rounding_rule;
  end if;

  if p_autotax_flag not in ('Y','N','U') then
     l_autotax_flag := 'Y';
  else
     l_autotax_flag := p_autotax_flag;
  end if;


  if p_trx_currency_code = ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.tax_currency_code and l_autotax_flag in ( 'Y','U')
  THEN

     l_precision := least( p_precision, nvl(ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.tax_precision, p_precision) );
     l_min_acct_unit := greatest( nvl(p_min_acct_unit, ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.tax_minimum_accountable_unit),
				  nvl(ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.tax_minimum_accountable_unit, p_min_acct_unit));

  ELSE

     l_precision := p_precision;
     l_min_acct_unit := p_min_acct_unit;

  END IF;

IF (g_level_statement >= g_current_runtime_level) THEN
	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',' trx currency  = :'||p_trx_currency_code||':');
	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',' sys currency  = :'||ZX_PRODUCT_INTEGRATION_PKG.sysinfo.sysparam.tax_currency_code||':');
	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',' autotax       = :'||p_autotax_flag||':');
	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',' rounding rule = :'||l_rounding_rule||':');
	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',' precision     = :'||to_char(l_precision)||':');
	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',' mau           = :'||to_char(l_min_acct_unit)||':');
END IF;

  IF ( nvl(l_min_acct_unit,0) <> 0 )
  THEN

     IF nvl(l_rounding_rule, 'NEAREST' ) = 'UP'
     THEN
	 --
	 -- Round the amount Up to next Min Accountable Unit
	 --
         l_rounded_amount := sign(p_amount)* (CEIL(abs(p_amount) / l_min_acct_unit) * l_min_acct_unit);

     ELSIF nvl(l_rounding_rule, 'NEAREST' ) = 'DOWN'
     THEN

	 --
	 -- Round the amount Down to the prior Min Accountable Unit
	 --
         l_rounded_amount := TRUNC(p_amount/l_min_acct_unit) * l_min_acct_unit;

     ELSE /* ROUND NEAREST BY DEFAULT */

	 --
	 -- Round the amount to the nearest Min Accountable Unit
	 --
         l_rounded_amount := ROUND(p_amount / l_min_acct_unit) * l_min_acct_unit;

     END IF;


  ELSE

     --
     -- Minimum Accountable Unit is not specified, use
     -- the precision to control the rounding
     --
     IF nvl(l_rounding_rule, 'NEAREST' ) = 'UP'
     THEN
	 --
	 -- Round the amount Up at the given precision
	 -- Amounts that are already at this precision
	 -- are not changed.
	 --
	 IF p_amount <> trunc(p_amount, l_precision)
	 THEN
             l_rounded_amount := ROUND( p_amount + (sign( p_amount)*(power( 10, (l_precision*-1))/2)), l_precision );
	 ELSE
	     l_rounded_amount := p_amount;
	 END IF;
     ELSIF nvl(l_rounding_rule, 'NEAREST' ) = 'DOWN'
	 THEN
	 --
	 -- Round the amount Down to the prior precision
	 --
         l_rounded_amount:= TRUNC( p_amount, l_precision );

     ELSE /* Default Nearest */
	 --
	 -- Round the amount to the nearest precision
	 --
         l_rounded_amount := ROUND( p_amount, l_precision );

     END IF;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.tax_curr_round',
                 'rounded_amount: '||to_char( l_rounded_amount) );
    FND_LOG.STRING(g_level_procedure,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.tax_curr_round.END',
                 'ZX_PRODUCT_INTEGRATION_PKG.tax_curr_round(-)');
  END IF;

  RETURN (l_rounded_amount);

EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.tax_curr_round',
                  sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    RAISE;
END tax_curr_round;


/*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |    get_vat_tax_rate                   			              |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure will get the vat_tax_id, tax type and the tax rate for   |
 |    the given tax code using tax code, set of books and trx date. If a      |
 |    tax code is not found then the exception TAX_NO_CODE is raised, If the  |
 |    tax code is found, but inactive, the exception TAX_CODE_INACTIVE is     |
 |    raised. Moreover, if an inactive tax code is found the tax type for the |
 |    global record will be set to TYPE_INACTIVE. If a tax code is not passed |
 |    exception TAX_NO_RATE is raised.                                        |
 |									      |
 | PARAMETERS                                                                 |
 |   THRU GLOBALS:                                                            |
 |      tax_info_rec.tax_code                        in varchar2              |
 |      sysinfo.sysparam.set_of_books_id  	     in number                |
 |      tax_info_rec.trx_date             	     in number                |
 |									      |
 |                                                                            |
 | RETURNS                                                                    |
 |   THRU GLOBALS:                                                            |
 |      if an active tax code exits                                           |
 |         tax_info_rec.vat_tax_id                                            |
 |         tax_info_rec.tax_rate                                              |
 |         tax_info_rec.tax_type                                              |
 |      exception TAX_NO_CODE when tax code not found                         |
 |      exception TAX_NO_RATE when tax code is not passed                     |
 |      exception TAX_CODE_INACTIVE when tax code inactive.                   |
 |                                                                            |
 | CALLED FROM                                                                |
 |    Calculate()                                                             |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 *----------------------------------------------------------------------------*/

PROCEDURE  get_vat_tax_rate IS
  l_tax_code_count	NUMBER;

  -- If the Tax code passed is ADHOC and a tax rate is passed, use the tax rate
  -- else assign standard tax rate for tax code.
  --
  CURSOR sel_vat_tax_rate IS
	SELECT vat_tax_id, tax_rate,
		TAX_TYPE_VAT,
		nvl(validate_flag, 'N')
	  FROM ar_vat_tax
	 WHERE tax_code = tax_info_rec.tax_code
	   AND set_of_books_id = sysinfo.sysparam.set_of_books_id
	   AND trunc(tax_info_rec.trx_date) between start_date and
				nvl(end_date, trunc(tax_info_rec.trx_date))
	   AND nvl(enabled_flag, 'Y') = 'Y'
           AND nvl(tax_class, 'O') = 'O';


  CURSOR sel_vat_tax_code_count IS
	SELECT 1
	  FROM DUAL
	 WHERE EXISTS ( SELECT tax_code
	    	  		  FROM ar_vat_tax
	     	 		 WHERE tax_code = tax_info_rec.tax_code
	     	   		   AND set_of_books_id = sysinfo.sysparam.set_of_books_id
                           	   AND nvl(enabled_flag, 'Y') = 'Y'
                                   AND nvl(tax_class, 'O') = 'O');

BEGIN

  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'zx_product_integration_pkg.get_vat_tax_rate()+' );
  END IF;

  --
  -- If tax code passed, get tax rate info
  --
  IF ( tax_info_rec.tax_code IS NOT NULL ) THEN

	--
	-- Fetch vat tax rate
	--
	OPEN sel_vat_tax_rate;
	FETCH sel_vat_tax_rate INTO
	    	tax_info_rec.vat_tax_id, tax_info_rec.tax_rate,
		tax_info_rec.tax_type, pg_adhoc_tax_code;

	--
  	-- Verify if an active tax code is found!
	--
	IF ( sel_vat_tax_rate%NOTFOUND ) THEN
	  --
	  -- Verify if tax code exists, if it exists, then its inactive
	  --
	  OPEN sel_vat_tax_code_count;
	  FETCH sel_vat_tax_code_count INTO l_tax_code_count;

	  IF ( sel_vat_tax_code_count%NOTFOUND ) THEN
		--
		-- Undefined tax code
		--
		raise TAX_NO_CODE;
	  ELSE
		--
		-- Tax code passed is inactive for the trx date
		--
		tax_info_rec.tax_type := TAX_TYPE_INACTIVE;
		raise TAX_CODE_INACTIVE;
	  END IF;

	  CLOSE sel_vat_tax_code_count;

        ELSE
          if pg_adhoc_tax_code = 'Y' then
            -- retrieve_adhoc;
            -- LTE tax codes are not adhoc
               NULL;
          end if;
	END IF;		-- Active tax code exists?

	CLOSE sel_vat_tax_rate;

  ELSE			-- Tax code not passed

	raise TAX_NO_RATE;

  END IF;		-- Tax code passed?

  --
  tax_info_rec.tax_rate := nvl(tax_info_rec.override_tax_rate,
                               tax_info_rec.tax_rate);

  --
  -- Debug Info
  --
  IF (g_level_statement >= g_current_runtime_level) THEN
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','>>> O : Vat_tax_id = '||tax_info_rec.Vat_tax_id);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','>>> O : Tax_rate = '||tax_info_rec.tax_rate);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG','>>> O : Tax_type = '||tax_info_rec.tax_type);
  	FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'arp_tax.get_vat_tax_rate()-' );
  END IF;

EXCEPTION
  WHEN TAX_NO_RATE THEN
  	IF (g_level_statement >= g_current_runtime_level) THEN
  		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'EXCEPTION(TAX_NO_RATE) : arp_tax.get_vat_tax_rate()-');
  	END IF;
  	IF ( sel_vat_tax_rate%ISOPEN ) THEN
  		CLOSE sel_vat_tax_rate;
	END IF;
  	IF ( sel_vat_tax_code_count%ISOPEN ) THEN
  		CLOSE sel_vat_tax_code_count;
	END IF;
	RAISE ;

  WHEN TAX_NO_CODE THEN
  	IF (g_level_statement >= g_current_runtime_level) THEN
  		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'EXCEPTION(TAX_NO_CODE) : arp_tax.get_vat_tax_rate()-');
  	END IF;
  	IF ( sel_vat_tax_rate%ISOPEN ) THEN
  		CLOSE sel_vat_tax_rate;
	END IF;
  	IF ( sel_vat_tax_code_count%ISOPEN ) THEN
  		CLOSE sel_vat_tax_code_count;
	END IF;
	RAISE ;

  WHEN TAX_CODE_INACTIVE THEN
  	IF (g_level_statement >= g_current_runtime_level) THEN
  		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'EXCEPTION(TAX_CODE_INACTIVE) : arp_tax.get_vat_tax_rate()-');
  	END IF;
  	IF ( sel_vat_tax_rate%ISOPEN ) THEN
  		CLOSE sel_vat_tax_rate;
	END IF;
  	IF ( sel_vat_tax_code_count%ISOPEN ) THEN
  		CLOSE sel_vat_tax_code_count;
	END IF;
	RAISE ;

  WHEN OTHERS THEN
  	IF (g_level_statement >= g_current_runtime_level) THEN
  		FND_LOG.STRING(g_level_statement,'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG', 'EXCEPTION(OTHERS) : arp_tax.get_vat_tax_rate()-');
  	END IF;
  	IF ( sel_vat_tax_rate%ISOPEN ) THEN
  		CLOSE sel_vat_tax_rate;
	END IF;
  	IF ( sel_vat_tax_code_count%ISOPEN ) THEN
  		CLOSE sel_vat_tax_code_count;
	END IF;
	RAISE ;

END get_vat_tax_rate;




/*===========================================================================+
 | PROCEDURE                                                                 |
 |   copy_lte_gdfs                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   This procedure copies the global attribute columns from                 |
 |   ra_customer_Trx_lines into named columns trx_busoness_category,         |
 |   product_category and product_fiscal_class for Latin Tax Engine          |
 |                                                                           |
 |   This procedure should be called by Receivables at the time of           |
 |   populating eBTax Global Temporary tables zx_trx_headers_gt and          |
 |   zx_transaction_lines_gt during autoinvoice                              |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   19-Jan-2005  Nilesh Patel         Created                               |
 |                                                                           |
+===========================================================================*/
PROCEDURE copy_lte_gdfs(
  x_return_status       OUT NOCOPY VARCHAR2)
IS
  l_delimiter zx_fc_types_b.delimiter%type;

  CURSOR c_delimiter IS
  SELECT delimiter
  FROM   zx_fc_types_b
  WHERE  classification_type_code ='TRX_BUSINESS_CATEGORY';

BEGIN

   OPEN c_delimiter;
   FETCH c_delimiter INTO l_delimiter;
   CLOSE c_delimiter;

   -- bug#6834705 - use tax_event_class_code from
   -- zx_evnt_cls_mappings, not from zx_trx_headers_gt
   --

   MERGE INTO  ZX_TRANSACTION_LINES_GT     lines_gt
   USING (SELECT
             ratrxlines.global_attribute_category,
             ratrxlines.global_attribute1,
             ratrxlines.global_attribute2  product_category,
             ratrxlines.global_attribute3  trx_business_category,
             Event.tax_event_class_code    tax_event_class_code,
             Lines.trx_line_id             trx_line_id
        FROM
             zx_transaction_lines_gt Lines,
             --zx_trx_headers_gt Headers,
             zx_evnt_cls_mappings    event,
             ra_customer_trx_lines_all ratrxlines
        WHERE
             lines.application_id   = 222
        AND  lines.application_id   = event.application_id
        AND  lines.entity_code      = event.entity_code
        AND  lines.event_class_code = event.event_class_code
        AND  Lines.trx_id           = ratrxlines.customer_Trx_id
        AND  Lines.trx_line_id      = ratrxlines.customer_Trx_line_id
        AND  ratrxlines.line_type   = 'LINE'
        AND  ratrxlines.memo_line_id  is NOT NULL
          ) Temp
   ON        ( Lines_gt.trx_line_id = Temp.trx_line_id)
   WHEN MATCHED THEN
         UPDATE SET
         trx_business_category = nvl(Lines_gt.trx_business_category,
                                     DECODE(Temp.trx_business_category,NULL,Temp.trx_business_category,
                                            Temp.tax_event_class_code||l_delimiter||Temp.trx_business_category)),
         product_category = nvl(Lines_gt.product_category, Temp.product_category),
         global_attribute1 = Temp.global_attribute1,
         global_attribute_category = Temp.global_attribute_category
   WHEN NOT MATCHED THEN
                      INSERT  (LINE_AMT) VALUES(NULL);


   MERGE INTO  ZX_TRANSACTION_LINES_GT lines_gt
   USING (SELECT
             ratrxlines.global_attribute_category,
             ratrxlines.global_attribute1,
             ratrxlines.global_attribute2  product_fiscal_class,
             ratrxlines.global_attribute3  trx_business_category,
             Event.tax_event_class_code    tax_event_class_code,
             Lines.trx_line_id             trx_line_id
        FROM
             zx_transaction_lines_gt Lines,
             --zx_trx_headers_gt Headers,
             zx_evnt_cls_mappings    event,
             ra_customer_trx_lines_all ratrxlines
        WHERE
             lines.application_id   = 222
        AND  lines.application_id   = event.application_id
        AND  lines.entity_code      = event.entity_code
        AND  lines.event_class_code = event.event_class_code
        --AND  lines.trx_id = headers.trx_id
        AND  Lines.trx_id           = ratrxlines.customer_Trx_id
        AND  Lines.trx_line_id      = ratrxlines.customer_Trx_line_id
        AND  ratrxlines.line_type    = 'LINE'
        AND  ratrxlines.inventory_item_id  is NOT NULL
          ) Temp
   ON        ( Lines_gt.trx_line_id = Temp.trx_line_id)
   WHEN MATCHED THEN
         UPDATE SET
         trx_business_category = nvl(Lines_gt.trx_business_category,
                                     DECODE(Temp.trx_business_category,NULL,Temp.trx_business_category,
                                            Temp.tax_event_class_code||l_delimiter||Temp.trx_business_category)),
         product_fisc_classification = nvl(Lines_gt.product_fisc_classification, Temp.product_fiscal_class),
         global_attribute1 = Temp.global_attribute1,
         global_attribute_category = Temp.global_attribute_category
   WHEN NOT MATCHED THEN
                      INSERT  (LINE_AMT) VALUES(NULL);


EXCEPTION
   WHEN OTHERS THEN
     NULL;

END copy_lte_gdfs;


/*===========================================================================+
 | FUNCTION                                                                  |
 |   adjust_compound_inclusive                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   go through tax_rec_tbl to adjust for Compounding and Inclusive          |
 |   for group tax.                                                          |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   20-Sep-05 Nilesh Patel Created                                          |
 |                                                                           |
 +===========================================================================*/
function adjust_compound_inclusive return number is

  l_inclusive_amount NUMBER := 0;
  l_sum_of_incl_tax	        NUMBER       := 0;
  l_max_counter                 NUMBER       := 0;

begin

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',
                     'ZX_PRODUCT_INTEGRATION_PKG.adjust_compound_inclusive(+)');
  END IF;

  --
  -- Check the group tax contains inclusive tax or not.
  --

  if (sysinfo.sysparam.tax_method = MTHD_LATIN) then

     begin

         l_max_counter := 0;
         l_sum_of_incl_tax := 0;

         l_max_counter := nvl(tax_rec_tbl.last,0);
         --
         IF (g_level_procedure >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',
         	     '-- Number of tax lines for this transaction line '||
                     to_char(l_max_counter));
         END IF;

         --
         for i in 1..l_max_counter
         LOOP
           --
           IF NVL(tax_rec_tbl(i).amount_includes_tax_flag,'N') = 'Y' THEN
              l_sum_of_incl_tax := l_sum_of_incl_tax +
                                    tax_rec_tbl(i).extended_amount;
           END IF;
           --
         end loop;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',
         	     '-- Total inclusive tax amount for this transaction line '
                     || to_char(l_sum_of_incl_tax));
        END IF;

        l_inclusive_amount := l_sum_of_incl_tax;

       --
       IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG',
                       'ZX_PRODUCT_INTEGRATION_PKG.adjust_compound_inclusive(-)');
       END IF;

       return l_inclusive_amount;
    end;
   end if; -- MTHD_LATIN

  return l_inclusive_amount;

end;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   fetch_manual_tax_lines                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   This procedure fetch detail tax lines from zx_lines                     |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   18-Mar-2009  Simranjeet Singh   Created                                 |
 |                                                                           |
 +===========================================================================*/

PROCEDURE fetch_manual_tax_lines (
  p_event_class_rec      IN  ZX_API_PUB.event_class_rec_type,
  p_index                IN  BINARY_INTEGER,
  x_return_status        OUT NOCOPY  VARCHAR2)
IS
   CURSOR get_manual_tax_lines IS
    SELECT * FROM zx_lines
     WHERE trx_id = p_event_class_rec.trx_id
       AND application_id   = p_event_class_rec.application_id
       AND event_class_code = p_event_class_rec.event_class_code
       AND entity_code      = p_event_class_rec.entity_code
       AND trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_index)
       AND trx_level_type   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_index)
       AND manually_entered_flag = 'Y'
       AND cancel_flag <> 'Y'
       AND mrc_tax_line_flag = 'N'
       AND tax_provider_id IS NULL;

   l_row_num NUMBER;
   l_tax_regime_rec	       ZX_GLOBAL_STRUCTURES_PKG.tax_regime_rec_type;
   l_tax_rec		           ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
   l_tax_status_rec	       ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
   l_tax_rate_rec          ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
   l_current_line_amt      ZX_LINES.line_amt%TYPE;
   l_tax_class             VARCHAR2(30);
   l_tax_date              DATE;
   l_tax_determine_date    DATE;
   l_tax_point_date        DATE;
   l_error_buffer          VARCHAR2(240);
   l_return_status         VARCHAR2(1);
   l_begin_index           NUMBER;
   l_end_index             NUMBER;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines.BEGIN',
               'ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  l_row_num := NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST,0);

  --  get tax date
  ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date(
                                p_index,
                                l_tax_date,
                                l_tax_determine_date,
                                l_tax_point_date,
                                x_return_status);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
             'Incorrect return_status after calling ' ||
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date()');
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines.END',
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines(-)');
    END IF;
    RETURN;
  END IF;

  FOR tax_line_rec IN get_manual_tax_lines LOOP
      l_row_num := l_row_num + 1;
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_row_num) := tax_line_rec;

      IF tax_line_rec.other_doc_source = 'REFERENCE' AND
         tax_line_rec.unrounded_tax_amt = 0 AND
         tax_line_rec.unrounded_taxable_amt = 0 AND
         tax_line_rec.manually_entered_flag = 'Y' AND
         tax_line_rec.freeze_until_overridden_flag ='Y'
      THEN
         NULL;

      ELSE
        -- validate and populate tax_regime_id
        ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
                          tax_line_rec.tax_regime_code,
                          l_tax_determine_date,
                          l_tax_regime_rec,
                          x_return_status,
                          l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_regime_cache_info');
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
                          'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines.END',
                          'ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_row_num).tax_regime_id := l_tax_regime_rec.tax_regime_id;

        -- validate and populate tax_id
        ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                          tax_line_rec.tax_regime_code,
                          tax_line_rec.tax,
                          l_tax_determine_date,
                          l_tax_rec,
                          x_return_status,
                          l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_tax_cache_info');
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
                          'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines.END',
                          'ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_row_num).tax_id := l_tax_rec.tax_id;

        -- validate and populate tax_status_id
        ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                          tax_line_rec.tax,
                          tax_line_rec.tax_regime_code,
                          tax_line_rec.tax_status_code,
                          l_tax_determine_date,
                          l_tax_status_rec,
                          x_return_status,
                          l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info');
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
                          'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines.END',
                          'ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_row_num).tax_status_id := l_tax_status_rec.tax_status_id;

        -- validate and populate tax_rate_id
        ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
                          tax_line_rec.tax_regime_code,
                          tax_line_rec.tax,
                          tax_line_rec.tax_jurisdiction_code,
                          tax_line_rec.tax_status_code,
                          tax_line_rec.tax_rate_code,
                          l_tax_determine_date,
                          l_tax_class,
                          l_tax_rate_rec,
                          x_return_status,
                          l_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
                    'Incorrect return_status after calling ' ||
                    'ZX_TDS_UTILITIES_PKG.get_tax_rate_info');
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
                          'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines.END',
                          'ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_row_num).tax_rate_id := l_tax_rate_rec.tax_rate_id;


        -- when Recalculate Manual Tax Lines flag is 'Y',
        -- prorate tax amount and taxable amount
        IF p_event_class_rec.allow_manual_lin_recalc_flag ='Y' THEN
          l_current_line_amt := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_index);

          IF tax_line_rec.line_amt <> 0 THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_row_num).unrounded_tax_amt :=
                 tax_line_rec.unrounded_tax_amt *
                                        l_current_line_amt/tax_line_rec.line_amt;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
               l_row_num).unrounded_taxable_amt :=
                 tax_line_rec.unrounded_taxable_amt *
                                        l_current_line_amt/tax_line_rec.line_amt;
          END IF;

          ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(
             l_row_num).tax_amt := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_row_num).unrounded_tax_amt;

          IF (l_begin_index is null) THEN
            l_begin_index := l_row_num;
          END IF;
        END IF;
      END IF;
    END LOOP;

    IF (l_begin_index IS NOT NULL) THEN
      l_end_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST;
    END IF;

    ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines (p_index,
                                                       l_begin_index,
                                                       l_end_index,
                                                       x_return_status,
                                                       l_error_buffer );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
                 'Incorrect RETURN_STATUS after calling '||
                 'ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines');
           FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
                 'RETURN_STATUS = ' || x_return_status);
           FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines.END',
                 'ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines(-)');
        END IF;
        RETURN;
    END IF;

  IF (g_level_event >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_event,
               'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines.END',
               'ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines(-)');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines',
                       sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines.END',
                      'ZX_PRODUCT_INTEGRATION_PKG.fetch_manual_tax_lines(-)');
      END IF;
END fetch_manual_tax_lines;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   get_manual_tax_lines_for_cm                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   This procedure populates the global structure for tax lines             |
 |   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl() for               |
 |   the Credit Memo with the details of the manual tax line of              |
 |   the adjusted doc                                                        |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   09-Sep-2009  Simranjeet Singh   Created                                 |
 |                                                                           |
 +===========================================================================*/
PROCEDURE get_manual_tax_lines_for_cm (
  p_event_class_rec     IN  ZX_API_PUB.event_class_rec_type,
  p_index               IN  BINARY_INTEGER,
  x_return_status       OUT NOCOPY  VARCHAR2)
IS
 -- Cursor --
 CURSOR get_manual_tax_lines IS
   SELECT * FROM zx_lines
    WHERE application_id = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_index)
      AND entity_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(p_index)
      AND event_class_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(p_index)
      AND trx_id = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id( p_index)
      AND trx_line_id = NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(p_index), trx_line_id)
      AND trx_level_type = NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(p_index), trx_level_type)
      AND NVL(manually_entered_flag,'N') = 'Y'
      AND NVL(cancel_flag,'N') <> 'Y'
      AND NVL(mrc_tax_line_flag,'N') = 'N';

 -- Variables --
 l_tax_date               DATE;
 l_tax_determine_date     DATE;
 l_tax_point_date         DATE;
 l_new_row_num            BINARY_INTEGER;
 l_begin_index            BINARY_INTEGER;
 l_end_index              BINARY_INTEGER;
 l_error_buffer           VARCHAR2(200);

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm.BEGIN',
       'ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_new_row_num := NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST, 0);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
       'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm',
       'Detail_Tax_Line_Tbl Index#'||TO_CHAR(l_new_row_num + 1));
  END IF;

  --  get tax date
  ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date(
                                p_index,
                                l_tax_date,
                                l_tax_determine_date,
                                l_tax_point_date,
                                x_return_status);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm',
             'Incorrect return_status after calling ' ||
             'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date()');
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm',
             'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm.END',
             'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm(-)');
    END IF;
    RETURN;
  END IF;

  FOR tax_line_rec IN get_manual_tax_lines LOOP

    -- populate tax cache ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl with this tax_id,
    ZX_TDS_UTILITIES_PKG.populate_tax_cache (
                p_tax_id         => tax_line_rec.TAX_ID,
                p_return_status  => x_return_status,
                p_error_buffer   => l_error_buffer);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
           'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm',
           'Incorrect return_status after calling ' ||
           'ZX_TDS_UTILITIES_PKG.populate_tax_cache()');
        FND_LOG.STRING(g_level_unexpected,
           'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm',
           'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
           'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm.END',
           'ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm(-)');
      END IF;
      RETURN;
    END IF;

    --increment l_new_row_num
    l_new_row_num := l_new_row_num +1;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_REGIME_CODE          := tax_line_rec.TAX_REGIME_CODE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_REGIME_ID            := tax_line_rec.TAX_REGIME_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_STATUS_CODE          := tax_line_rec.TAX_STATUS_CODE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_STATUS_ID            := tax_line_rec.TAX_STATUS_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX                      := tax_line_rec.TAX;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_ID                   := tax_line_rec.TAX_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_RATE_CODE            := tax_line_rec.TAX_RATE_CODE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_RATE_ID              := tax_line_rec.TAX_RATE_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_RATE                 := tax_line_rec.TAX_RATE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_TYPE_CODE            := tax_line_rec.TAX_TYPE_CODE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_RATE_TYPE            := tax_line_rec.TAX_RATE_TYPE;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_DATE                 := l_tax_date;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_DETERMINE_DATE       := l_tax_determine_date;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_POINT_DATE           := l_tax_point_date;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_APPORTIONMENT_LINE_NUMBER  :=  NVL(tax_line_rec.TAX_APPORTIONMENT_LINE_NUMBER, 1 );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm',
                     'Tax Regime: '      ||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_regime_code||
                     ', Tax: '           ||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax            ||
                     ', Tax Status: '    ||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_status_code||
                     ', Tax Rate Code: ' ||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_rate_code  ||
                     ', Tax Rate: '      ||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_rate       ||
                     ', Tax Apportionment Line Number: '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_apportionment_line_number);
    END IF;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).MULTIPLE_JURISDICTIONS_FLAG    := tax_line_rec.MULTIPLE_JURISDICTIONS_FLAG;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).ACCOUNT_SOURCE_TAX_RATE_ID     := tax_line_rec.ACCOUNT_SOURCE_TAX_RATE_ID;

    IF p_event_class_rec.tax_reporting_flag = 'Y' THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).LEGAL_REPORTING_STATUS := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(
                                                tax_line_rec.tax_id).LEGAL_REPORTING_STATUS_DEF_VAL;
    END IF;

    -- populate taxable_basis_formula and tax_calculation_formula
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAXABLE_BASIS_FORMULA          := tax_line_rec.TAXABLE_BASIS_FORMULA;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_CALCULATION_FORMULA        := tax_line_rec.TAX_CALCULATION_FORMULA;

    -- Populate other doc line amt, taxable amt and tax amt
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).OTHER_DOC_LINE_AMT             := tax_line_rec.LINE_AMT;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).OTHER_DOC_LINE_TAXABLE_AMT     := tax_line_rec.UNROUNDED_TAXABLE_AMT;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).OTHER_DOC_LINE_TAX_AMT         := tax_line_rec.UNROUNDED_TAX_AMT;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).COPIED_FROM_OTHER_DOC_FLAG     := 'Y';
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).OTHER_DOC_SOURCE               := 'ADJUSTED';

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).ADJUSTED_DOC_TAX_LINE_ID       := tax_line_rec.TAX_LINE_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TRX_DATE                       := tax_line_rec.TRX_DATE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_LINE_NUMBER                := tax_line_rec.TAX_LINE_NUMBER;

    -- Rounding related columns
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).ROUNDING_LEVEL_CODE            := tax_line_rec.ROUNDING_LEVEL_CODE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).ROUNDING_RULE_CODE             := tax_line_rec.ROUNDING_RULE_CODE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).PRECISION                      := tax_line_rec.PRECISION;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).MINIMUM_ACCOUNTABLE_UNIT       := tax_line_rec.MINIMUM_ACCOUNTABLE_UNIT;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TRX_CURRENCY_CODE              := tax_line_rec.TRX_CURRENCY_CODE;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).ROUNDING_LVL_PARTY_TAX_PROF_ID := tax_line_rec.ROUNDING_LVL_PARTY_TAX_PROF_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).ROUNDING_LVL_PARTY_TYPE	      := tax_line_rec.ROUNDING_LVL_PARTY_TYPE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).OFFSET_FLAG                    := tax_line_rec.OFFSET_FLAG;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).OFFSET_TAX_RATE_CODE           := tax_line_rec.OFFSET_TAX_RATE_CODE;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).PLACE_OF_SUPPLY                := tax_line_rec.PLACE_OF_SUPPLY;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).PLACE_OF_SUPPLY_TYPE_CODE      := tax_line_rec.PLACE_OF_SUPPLY_TYPE_CODE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).PLACE_OF_SUPPLY_RESULT_ID      := tax_line_rec.PLACE_OF_SUPPLY_RESULT_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).REGISTRATION_PARTY_TYPE        := tax_line_rec.REGISTRATION_PARTY_TYPE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_JURISDICTION_CODE          := tax_line_rec.TAX_JURISDICTION_CODE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_JURISDICTION_ID            := tax_line_rec.TAX_JURISDICTION_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_REGISTRATION_NUMBER        := tax_line_rec.TAX_REGISTRATION_NUMBER;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_APPLICABILITY_RESULT_ID    := tax_line_rec.TAX_APPLICABILITY_RESULT_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).DIRECT_RATE_RESULT_ID          := tax_line_rec.DIRECT_RATE_RESULT_ID;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_CURRENCY_CODE              := tax_line_rec.TAX_CURRENCY_CODE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_CURRENCY_CONVERSION_DATE   := tax_line_rec.TAX_CURRENCY_CONVERSION_DATE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_CURRENCY_CONVERSION_TYPE   := tax_line_rec.TAX_CURRENCY_CONVERSION_TYPE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_CURRENCY_CONVERSION_RATE   := tax_line_rec.TAX_CURRENCY_CONVERSION_RATE;

    -- Tax Line Flags
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).MRC_TAX_LINE_FLAG              := NVL(tax_line_rec.MRC_TAX_LINE_FLAG,'N');
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_APPORTIONMENT_FLAG         := tax_line_rec.TAX_APPORTIONMENT_FLAG;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).MANUALLY_ENTERED_FLAG          := tax_line_rec.MANUALLY_ENTERED_FLAG;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).LAST_MANUAL_ENTRY              := tax_line_rec.LAST_MANUAL_ENTRY;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).ASSOCIATED_CHILD_FROZEN_FLAG   := tax_line_rec.ASSOCIATED_CHILD_FROZEN_FLAG;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_ONLY_LINE_FLAG             := tax_line_rec.TAX_ONLY_LINE_FLAG;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).REPORTING_ONLY_FLAG            := tax_line_rec.REPORTING_ONLY_FLAG;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).SELF_ASSESSED_FLAG             := tax_line_rec.SELF_ASSESSED_FLAG;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_BASE_MODIFIER_RATE         := tax_line_rec.TAX_BASE_MODIFIER_RATE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).LEGAL_JUSTIFICATION_TEXT1      := tax_line_rec.LEGAL_JUSTIFICATION_TEXT1;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).LEGAL_JUSTIFICATION_TEXT2      := tax_line_rec.LEGAL_JUSTIFICATION_TEXT2;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).LEGAL_JUSTIFICATION_TEXT3      := tax_line_rec.LEGAL_JUSTIFICATION_TEXT3;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).BASIS_RESULT_ID                := tax_line_rec.BASIS_RESULT_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).CALC_RESULT_ID                 := tax_line_rec.CALC_RESULT_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).COMPOUNDING_DEP_TAX_FLAG       := tax_line_rec.COMPOUNDING_DEP_TAX_FLAG;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).COMPOUNDING_TAX_MISS_FLAG      := tax_line_rec.COMPOUNDING_TAX_MISS_FLAG;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).COMPOUNDING_TAX_FLAG           := tax_line_rec.COMPOUNDING_TAX_FLAG;

    --populate the Legal Message columns also
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).LEGAL_MESSAGE_APPL_2           := tax_line_rec.LEGAL_MESSAGE_APPL_2;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).LEGAL_MESSAGE_STATUS           := tax_line_rec.LEGAL_MESSAGE_STATUS;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).LEGAL_MESSAGE_RATE             := tax_line_rec.LEGAL_MESSAGE_RATE;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).LEGAL_MESSAGE_BASIS            := tax_line_rec.LEGAL_MESSAGE_BASIS;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).LEGAL_MESSAGE_CALC             := tax_line_rec.LEGAL_MESSAGE_CALC;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).LEGAL_MESSAGE_POS              := tax_line_rec.LEGAL_MESSAGE_POS;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).LEGAL_MESSAGE_TRN              := tax_line_rec.LEGAL_MESSAGE_TRN;

    -- Populate the global_attribute columns in detailed tax lines based on output tax record returned by LTE
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE_CATEGORY      := tax_line_rec.GLOBAL_ATTRIBUTE_CATEGORY;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE1              := tax_line_rec.GLOBAL_ATTRIBUTE1;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE2              := tax_line_rec.GLOBAL_ATTRIBUTE2;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE3              := tax_line_rec.GLOBAL_ATTRIBUTE3;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE4              := tax_line_rec.GLOBAL_ATTRIBUTE4;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE5              := tax_line_rec.GLOBAL_ATTRIBUTE5;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE6              := tax_line_rec.GLOBAL_ATTRIBUTE6;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE7              := tax_line_rec.GLOBAL_ATTRIBUTE7;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE8              := tax_line_rec.GLOBAL_ATTRIBUTE8;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE9              := tax_line_rec.GLOBAL_ATTRIBUTE9;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE10             := tax_line_rec.GLOBAL_ATTRIBUTE10;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE11             := tax_line_rec.GLOBAL_ATTRIBUTE11;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE12             := tax_line_rec.GLOBAL_ATTRIBUTE12;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE13             := tax_line_rec.GLOBAL_ATTRIBUTE13;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE14             := tax_line_rec.GLOBAL_ATTRIBUTE14;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE15             := tax_line_rec.GLOBAL_ATTRIBUTE15;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE16             := tax_line_rec.GLOBAL_ATTRIBUTE16;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE17             := tax_line_rec.GLOBAL_ATTRIBUTE17;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE18             := tax_line_rec.GLOBAL_ATTRIBUTE18;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE19             := tax_line_rec.GLOBAL_ATTRIBUTE19;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).GLOBAL_ATTRIBUTE20             := tax_line_rec.GLOBAL_ATTRIBUTE20;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_REG_NUM_DET_RESULT_ID      := tax_line_rec.TAX_REG_NUM_DET_RESULT_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).HQ_ESTB_REG_NUMBER             := tax_line_rec.HQ_ESTB_REG_NUMBER;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).HQ_ESTB_PARTY_TAX_PROF_ID      := tax_line_rec.HQ_ESTB_PARTY_TAX_PROF_ID;

    --   If line_amt_include_tax_flag on trx line is A, then set to 'Y'
    --   for other cases, set to the one from adjusted doc.
    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt_includes_tax_flag(p_index) = 'A' THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_AMT_INCLUDED_FLAG := 'Y';
    ELSE
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_AMT_INCLUDED_FLAG := tax_line_rec.TAX_AMT_INCLUDED_FLAG;
    END IF;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_EXEMPTION_ID               := tax_line_rec.TAX_EXEMPTION_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_RATE_BEFORE_EXEMPTION      := tax_line_rec.TAX_RATE_BEFORE_EXEMPTION;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_RATE_NAME_BEFORE_EXEMPTION := tax_line_rec.TAX_RATE_NAME_BEFORE_EXEMPTION;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).EXEMPT_RATE_MODIFIER           := tax_line_rec.EXEMPT_RATE_MODIFIER;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).EXEMPT_CERTIFICATE_NUMBER      := tax_line_rec.EXEMPT_CERTIFICATE_NUMBER;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).EXEMPT_REASON                  := tax_line_rec.EXEMPT_REASON;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).EXEMPT_REASON_CODE             := tax_line_rec.EXEMPT_REASON_CODE;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_EXCEPTION_ID               := tax_line_rec.TAX_EXCEPTION_ID;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_RATE_BEFORE_EXCEPTION      := tax_line_rec.TAX_RATE_BEFORE_EXCEPTION;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_RATE_NAME_BEFORE_EXCEPTION := tax_line_rec.TAX_RATE_NAME_BEFORE_EXCEPTION;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).EXCEPTION_RATE                 := tax_line_rec.EXCEPTION_RATE;

    -- Prorate Amounts --
    IF NVL(tax_line_rec.historical_flag, 'N') = 'Y' THEN
      IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_index) = 'ALLOCATE_TAX_ONLY_ADJUSTMENT' THEN
        -- for tax only adjustment set the unrounded tax amount to the
        -- unrounded tax amount of the original doc.
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt := NVL(tax_line_rec.unrounded_taxable_amt,tax_line_rec.taxable_amt);
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt := NVL(tax_line_rec.unrounded_tax_amt,tax_line_rec.tax_amt);
      ELSE
        -- current trx is a regular adjustment or CM
        -- prorate the line amt to get the unrounded taxable/tax amount
        IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_amt_included_flag ='Y' AND tax_line_rec.tax_amt_included_flag = 'N' THEN
          -- If current trx is a tax inclusive trx, while the original trx is
          -- tax exclusive trx.
          IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_total_hdr_tx_amt(p_index) IS NOT NULL AND
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_hdr_tx_appl_flag(p_index) = 'Y' THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt := tax_line_rec.unrounded_taxable_amt;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt :=  tax_line_rec.unrounded_tax_amt;
          ELSE
            IF ( tax_line_rec.line_amt + tax_line_rec.tax_amt) <> 0 THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_index) *
                   ( NVL(tax_line_rec.unrounded_taxable_amt,tax_line_rec.taxable_amt) /
                     ( tax_line_rec.line_amt + tax_line_rec.tax_amt) );

              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_index) *
                   ( NVL(tax_line_rec.unrounded_tax_amt,tax_line_rec.tax_amt) /
                     ( tax_line_rec.line_amt + tax_line_rec.tax_amt) );
            ELSE
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                := NVL(tax_line_rec.unrounded_taxable_amt,tax_line_rec.taxable_amt);
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                := NVL(tax_line_rec.unrounded_tax_amt,tax_line_rec.tax_amt);
            END IF;
          END IF;
        ELSE -- both current tax line and original tax line are inclusive and exclusive
          IF tax_line_rec.line_amt <> 0 THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
              := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_index) *
                 (NVL(tax_line_rec.unrounded_taxable_amt,tax_line_rec.taxable_amt) / tax_line_rec.line_amt);

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
              := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_index) *
                 (NVL(tax_line_rec.unrounded_tax_amt,tax_line_rec.tax_amt) / tax_line_rec.line_amt );
          ELSE -- equal to that the original trx is a tax only trx
            IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_index) = 'CREDIT_MEMO' THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                := -1 * NVL(tax_line_rec.unrounded_taxable_amt,tax_line_rec.taxable_amt);
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                := -1 * NVL(tax_line_rec.unrounded_tax_amt,tax_line_rec.tax_amt);
            ELSE
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                := NVL(tax_line_rec.unrounded_taxable_amt,tax_line_rec.taxable_amt);
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                := NVL(tax_line_rec.unrounded_tax_amt,tax_line_rec.tax_amt);
            END IF;
          END IF;
        END IF; -- tax_line_rec.tax_amt_included_flag = 'N'
      END IF; -- 'ALLOCATE_TAX_ONLY_ADJUSTMENT' trx and else
    ELSE  -- Historical Flag is 'N'
      IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_index) = 'ALLOCATE_TAX_ONLY_ADJUSTMENT' THEN
        -- for tax only adjustment set the unrounded tax amount to the
        -- unrounded tax amount of the original doc.
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt := tax_line_rec.unrounded_taxable_amt;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt := tax_line_rec.unrounded_tax_amt;
      ELSE
        -- current trx is a regular adjustment or CM
        -- prorate the line amt to get the unrounded taxable/tax amount
        IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_amt_included_flag ='Y' AND tax_line_rec.tax_amt_included_flag = 'N' THEN
          -- If current trx is a tax inclusive trx, while the original trx is
          -- tax exclusive trx.
          IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_total_hdr_tx_amt(p_index) IS NOT NULL AND
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_hdr_tx_appl_flag(p_index) = 'Y' THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt := tax_line_rec.unrounded_taxable_amt;
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt := tax_line_rec.unrounded_tax_amt;
          ELSE
            IF ( tax_line_rec.line_amt + tax_line_rec.tax_amt) <> 0 THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_index) *
                   ( tax_line_rec.unrounded_taxable_amt /
                     ( tax_line_rec.line_amt + tax_line_rec.tax_amt) );
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_index) *
                   ( tax_line_rec.unrounded_tax_amt /
                     ( tax_line_rec.line_amt + tax_line_rec.tax_amt) );
            ELSE
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt := tax_line_rec.unrounded_taxable_amt;
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt := tax_line_rec.unrounded_tax_amt;
            END IF;
          END IF;
        ELSE -- both current tax line and original tax line are inclusive and exclusive
          IF tax_line_rec.line_amt <> 0 THEN
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
              := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_index) *
                 ( tax_line_rec.unrounded_taxable_amt / tax_line_rec.line_amt);

            ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
              := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(p_index) *
                 ( tax_line_rec.unrounded_tax_amt / tax_line_rec.line_amt );
          ELSE -- equal to that the original trx is a tax only trx
            IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_index) = 'CREDIT_MEMO' THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt
                := -1 * tax_line_rec.unrounded_taxable_amt;
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt
                := -1 * tax_line_rec.unrounded_tax_amt;
            ELSE
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_taxable_amt := tax_line_rec.unrounded_taxable_amt;
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).unrounded_tax_amt := tax_line_rec.unrounded_tax_amt;
            END IF;
          END IF;
        END IF; -- tax_line_rec.tax_amt_included_flag = 'N'
      END IF; -- 'ALLOCATE_TAX_ONLY_ADJUSTMENT' trx and else
    END IF; -- Historical Flag check

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm',
         'Tax Line#'                    ||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).TAX_LINE_NUMBER      ||
         ': Unrounded Taxable Amount = '||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).UNROUNDED_TAXABLE_AMT||
         ', Unrounded Tax Amount = '    ||ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).UNROUNDED_TAX_AMT);
    END IF;

    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).tax_amt_included_flag = 'Y' THEN
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_amt_included_flag(p_index) := 'Y';
    END IF;

    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(l_new_row_num).compounding_dep_tax_flag = 'Y' THEN
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.compounding_tax_flag(p_index) := 'Y';
    END IF;

    IF (l_begin_index IS NULL) THEN
      l_begin_index := l_new_row_num;
    END IF;
  END LOOP;

  IF (l_begin_index IS NOT NULL) THEN
    l_end_index := ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl.LAST;
  END IF;

  -- copy transaction info to new tax lines for new tax_lines created here
  ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines(
                                p_trx_line_index => p_index ,
                                p_begin_index    => l_begin_index,
                                p_end_index      => l_end_index,
                                p_return_status  => x_return_status ,
                                p_error_buffer   => l_error_buffer );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm',
         'Incorrect return_status after calling ' ||
         'ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines');
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm',
         'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm.END',
         'ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm(-)');
    END IF;
    RETURN;
  END IF;

  ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line(
                                p_begin_index   => l_begin_index,
                                p_end_index     => l_end_index,
                                p_return_status => x_return_status ,
                                p_error_buffer  => l_error_buffer );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm',
         'Incorrect return_status after calling ' ||
         'ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line');
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm',
         'RETURN_STATUS = ' || x_return_status);
      FND_LOG.STRING(g_level_statement,
         'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm.END',
         'ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm(-)');
    END IF;
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
       'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm.END',
       'ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm',
                      SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm.END',
                     'ZX_PRODUCT_INTEGRATION_PKG.get_manual_tax_lines_for_cm(-)');
    END IF;

END get_manual_tax_lines_for_cm;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   package constructor                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
+===========================================================================*/

-- package constructor
BEGIN
  --Initialize the debug variable pg_debug
  pg_debug := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_PRODUCT_INTEGRATION_PKG.constructor',
                     'ZX_PRODUCT_INTEGRATION_PKG: constructor');
  END IF;
END ZX_PRODUCT_INTEGRATION_PKG;


/
