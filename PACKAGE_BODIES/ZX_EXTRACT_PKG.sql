--------------------------------------------------------
--  DDL for Package Body ZX_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_EXTRACT_PKG" AS
/* $Header: zxriextractwpkgb.pls 120.43.12010000.13 2010/03/08 11:24:17 msakalab ship $ */

C_LINES_PER_INSERT                 CONSTANT NUMBER :=  1000;

-----------------------------------------
--Public Variable Declarations
-----------------------------------------
--
--  Define Global  Variables;

--pr_org_loc_rec			HR_LOCATIONS_V%ROWTYPE;
  pr_flexfield				FND_DFLEX.DFLEX_R;
  pr_flexinfo				FND_DFLEX.DFLEX_DR;
  pg_sql                                varchar2(32000) :=  null;
  pg_table_owner                        VARCHAR2(30);
  g_ledger_type			        VARCHAR2(1);
  g_ledger_id    			NUMBER(15);
  g_rep_ledger_id    			NUMBER(15);

  L_SQL_STATEMENT                       VARCHAR2(32600);
  L_VERSION_INFO                        VARCHAR2(80) :=  NULL;
  L_PARAMLIST                           VARCHAR2(4000);
  L_ERRBUF                              VARCHAR2(2000);
  L_LENGTH_ERRBUF                       NUMBER;
  L_RETCODE                             NUMBER := 0;
  L_AP_RETCODE                          NUMBER := 0;
  L_AR_RETCODE                          NUMBER := 0;
  L_GL_RETCODE                          NUMBER := 0;
  L_MSG                                 VARCHAR2(500);
  g_created_by				number(15);
  g_creation_date			date;
  g_last_updated_by			number(15);
  g_last_update_date                    date;
  g_last_update_login                   number(15);
  g_rep_context_city                    hr_locations_all.town_or_city%type;
  g_rep_context_region_1                hr_locations_all.region_3%type;
  g_rep_context_region_2                hr_locations_all.region_2%type;
  g_rep_context_region_3                hr_locations_all.region_1%type;
  g_rep_context_address1                hr_locations_all.address_line_1%type;
  g_rep_context_address2                hr_locations_all.address_line_2%type;
  g_rep_context_address3                hr_locations_all.address_line_3%type;
  g_rep_context_country                 hr_locations_all.country%type;
  g_rep_context_postal_code             hr_locations_all.postal_code%type;
  g_rep_context_phone_number            hr_locations_all.telephone_number_1%type;

  l_multi_org_flag                      fnd_product_groups.multi_org_flag%type;
  l_mrc_reporting_sob_id                NUMBER;
  g_balancing_segment                   VARCHAR2(25);
  g_currency_code                 	VARCHAR2(15);
  l_accounting_segment                  VARCHAR2(25);

  g_current_runtime_level           NUMBER ;
  g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
  g_error_buffer                        VARCHAR2(100);

  PG_DEBUG   VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


  CURSOR  multi_org_csr IS
          SELECT multi_org_flag
            FROM fnd_product_groups;


  TYPE l_sql_statement_tabtype is table of varchar2(32600)
                            index by binary_integer;
  l_sql_statement_tbl  l_sql_statement_tabtype;


-----------------------------------------
--Forward Private Methods Declarations
-----------------------------------------


PROCEDURE stack_error (
                  p_application VARCHAR2,
                  p_msgname 	VARCHAR2,
                  p_token1      VARCHAR2 DEFAULT NULL,
                  p_value1      VARCHAR2 DEFAULT NULL,
                  p_token2      VARCHAR2 DEFAULT NULL,
                  p_value2      VARCHAR2 DEFAULT NULL,
                  p_token3      VARCHAR2 DEFAULT NULL,
                  p_value3      VARCHAR2 DEFAULT NULL );

PROCEDURE EXTRACT_TAX_INFO (
             p_ledger_type              IN            VARCHAR2,
             P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE);

PROCEDURE extract_rep_context_info(
             P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE);

FUNCTION validate_parameters (
         P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
  ) return boolean;

PROCEDURE extract_additional_info (
             P_ledger_type              IN            VARCHAR2,
             P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE);

PROCEDURE derive_dependent_parameters (
             P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE);

PROCEDURE cleanup (
             P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE);

PROCEDURE delete_all(p_request_id in number );

/*PROCEDURE build_gbl_lookup_table; */

FUNCTION  location_value(p_column in varchar2) return varchar2;

FUNCTION  get_location_column(p_style          IN VARCHAR2,
                  	      p_classification IN VARCHAR2)
          return varchar2;

FUNCTION  convert_string(p_string IN VARCHAR2) return varchar2;

PROCEDURE insert_rep_context_itf(
             P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
             p_rep_entity_id            IN     NUMBER );

PROCEDURE initialize(
            P_TRL_GLOBAL_VARIABLES_REC    IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
            P_REPORTING_LEVEL	          IN	VARCHAR2,
            P_REPORTING_CONTEXT	          IN	VARCHAR2,
-- apai             P_LEGAL_ENTITY_LEVEL	  IN	VARCHAR2,
            P_LEGAL_ENTITY_ID	          IN	NUMBER	, -- apai COMPANY_NAME
            P_SUMMARY_LEVEL               IN      VARCHAR2,
            P_LEDGER_ID	                  IN	NUMBER	,
            P_REGISTER_TYPE	          IN	VARCHAR2,
            P_PRODUCT	                  IN	VARCHAR2,
            P_MATRIX_REPORT	          IN	VARCHAR2,
            P_DETAIL_LEVEL                IN      VARCHAR2,
            P_CURRENCY_CODE_LOW	          IN	VARCHAR2,
            P_CURRENCY_CODE_HIGH	  IN	VARCHAR2,
            P_INCLUDE_AP_STD_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AP_DM_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AP_CM_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AP_PREP_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AP_MIX_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AP_EXP_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AP_INT_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AR_INV_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AR_APPL_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AR_ADJ_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AR_MISC_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AR_BR_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_GL_MANUAL_LINES	  IN	VARCHAR2,
            P_THIRD_PARTY_REP_LEVEL       IN    VARCHAR2,
            P_FIRST_PARTY_TAX_REG_NUM     IN    VARCHAR2,
            P_TRX_NUMBER_LOW	          IN	VARCHAR2,
            P_TRX_NUMBER_HIGH	          IN	VARCHAR2,
            P_EXTRACT_REPORT_LINE_NUMBER  IN    NUMBER  ,
            P_AR_TRX_PRINTING_STATUS	  IN	VARCHAR2,
            P_AR_EXEMPTION_STATUS	  IN	VARCHAR2,
            P_GL_DATE_LOW	          IN	DATE	,
            P_GL_DATE_HIGH	          IN	DATE	,
            P_TRX_DATE_LOW	          IN	DATE	,
            P_TRX_DATE_HIGH	          IN	DATE	,
            P_GL_PERIOD_NAME_LOW	  IN	VARCHAR2,
            P_GL_PERIOD_NAME_HIGH	  IN	VARCHAR2,
            P_TRX_DATE_PERIOD_NAME_LOW	  IN	VARCHAR2,
            P_TRX_DATE_PERIOD_NAME_HIGH	  IN	VARCHAR2,
            P_TAX_JURISDICTION_CODE       IN    VARCHAR ,
            P_TAX_REGIME_CODE	          IN	VARCHAR2,
            P_TAX	                  IN	VARCHAR2,
            P_TAX_STATUS_CODE	          IN	VARCHAR2,
            P_TAX_RATE_CODE_LOW	          IN	VARCHAR2,
            P_TAX_RATE_CODE_HIGH	  IN	VARCHAR2,
            P_TAX_TYPE_CODE_LOW	          IN	VARCHAR2,
            P_TAX_TYPE_CODE_HIGH	  IN	VARCHAR2,
            P_DOCUMENT_SUB_TYPE	          IN	VARCHAR2,
            P_TRX_BUSINESS_CATEGORY	  IN	VARCHAR2,
            P_TAX_INVOICE_DATE_LOW	  IN	VARCHAR2,
            P_TAX_INVOICE_DATE_HIGH	  IN	VARCHAR2,
            P_POSTING_STATUS	          IN	VARCHAR2,
            P_EXTRACT_ACCTED_TAX_LINES	  IN	VARCHAR2,
            P_INCLUDE_ACCOUNTING_SEGMENTS IN	VARCHAR2,
            P_BALANCING_SEGMENT_LOW	  IN	VARCHAR2,
            P_BALANCING_SEGMENT_HIGH	  IN	VARCHAR2,
            P_INCLUDE_DISCOUNTS	          IN	VARCHAR2,
            P_EXTRACT_STARTING_LINE_NUM	  IN     	NUMBER	,
            P_REQUEST_ID	          IN     	NUMBER	,
            P_REPORT_NAME	          IN     	VARCHAR2,
            P_VAT_TRANSACTION_TYPE_CODE	  IN     	VARCHAR2,
            P_INCLUDE_FULLY_NR_TAX_FLAG	  IN     	VARCHAR2,
            P_MUNICIPAL_TAX_TYPE_CODE_LOW	IN     	VARCHAR2,
            P_MUNICIPAL_TAX_TYPE_CODE_HIGH	IN     	VARCHAR2,
            P_PROV_TAX_TYPE_CODE_LOW	  IN     	VARCHAR2,
            P_PROV_TAX_TYPE_CODE_HIGH	  IN     	VARCHAR2,
            P_EXCISE_TAX_TYPE_CODE_LOW	  IN     	VARCHAR2,
            P_EXCISE_TAX_TYPE_CODE_HIGH	  IN     	VARCHAR2,
            P_NON_TAXABLE_TAX_TYPE_CODE	  IN     	VARCHAR2,
            P_PER_TAX_TYPE_CODE_LOW	  IN     	VARCHAR2,
            P_PER_TAX_TYPE_CODE_HIGH	  IN     	VARCHAR2,
            P_FED_PER_TAX_TYPE_CODE_LOW	  IN     	VARCHAR2,
            P_FED_PER_TAX_TYPE_CODE_HIGH	IN     	VARCHAR2,
            P_VAT_TAX_TYPE_CODE	          IN     	VARCHAR2,
            P_EXCISE_TAX	          IN     	VARCHAR2,
            P_VAT_ADDITIONAL_TAX	  IN     	VARCHAR2,
            P_VAT_NON_TAXABLE_TAX	  IN     	VARCHAR2,
            P_VAT_NOT_TAX	          IN     	VARCHAR2,
            P_VAT_PERCEPTION_TAX	  IN     	VARCHAR2,
            P_VAT_TAX	                  IN     	VARCHAR2,
            P_INC_SELF_WD_TAX	          IN     	VARCHAR2,
            P_EXCLUDING_TRX_LETTER	  IN     	VARCHAR2,
            P_TRX_LETTER_LOW	          IN     	VARCHAR2,
            P_TRX_LETTER_HIGH	          IN     	VARCHAR2,
            P_INCLUDE_REFERENCED_SOURCE	  IN     	VARCHAR2,
            P_PARTY_NAME	          IN     	VARCHAR2,
            P_BATCH_NAME	          IN     	VARCHAR2,
            P_BATCH_DATE_LOW              IN      DATE    ,
            P_BATCH_DATE_HIGH             IN      DATE    ,
            P_BATCH_SOURCE_ID	          IN     	VARCHAR2,
            P_ADJUSTED_DOC_FROM	          IN     	VARCHAR2,
            P_ADJUSTED_DOC_TO	          IN     	VARCHAR2,
            P_STANDARD_VAT_TAX_RATE	  IN     	VARCHAR2,
            P_MUNICIPAL_TAX	          IN     	VARCHAR2,
            P_PROVINCIAL_TAX	          IN     	VARCHAR2,
            P_TAX_ACCOUNT_LOW	          IN     	VARCHAR2,
            P_TAX_ACCOUNT_HIGH	          IN     	VARCHAR2,
            P_EXP_CERT_DATE_FROM	  IN     	DATE	,
            P_EXP_CERT_DATE_TO	          IN     	DATE	,
            P_EXP_METHOD	          IN     	VARCHAR2,
            P_PRINT_COMPANY_INFO	  IN     	VARCHAR2,
            P_ORDER_BY                    IN      VARCHAR2,
            P_CHART_OF_ACCOUNTS_ID        IN      NUMBER  ,
            P_REPRINT                     IN      VARCHAR2,
            P_ERRBUF	                  IN OUT NOCOPY VARCHAR2,
            P_RETCODE	                  IN OUT NOCOPY VARCHAR2,
            P_ACCOUNTING_STATUS           IN     VARCHAR2,
            P_REPORTED_STATUS             IN     VARCHAR2,
            P_TAXABLE_ACCOUNT_LOW         IN     VARCHAR2,
            P_TAXABLE_ACCOUNT_HIGH        IN     VARCHAR2,
	          P_GL_OR_TRX_DATE_FILTER	  IN	 VARCHAR2, --Bug 5396444
	          --Bug 9031051
            P_ESL_DEFAULT_TAX_DATE IN VARCHAR2,
            P_ESL_OUT_OF_PERIOD_ADJ IN VARCHAR2,
            P_ESL_EU_TRX_TYPE IN VARCHAR2,
            P_ESL_EU_GOODS IN VARCHAR2,
            P_ESL_EU_SERVICES IN VARCHAR2,
            P_ESL_EU_ADDL_CODE1 IN VARCHAR2,
            P_ESL_EU_ADDL_CODE2 IN VARCHAR2,
            P_ESL_SITE_CODE IN VARCHAR2);
-----------------------------------------
--Public Methods Declarations
-----------------------------------------
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   populate_tax_data()                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure calls AP,AR,and GL extract and populate packages to     |
 |    populate Tax extract interface tables.                                 |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   12-FEB-2005      Srinivasa Rao Korrapati  Created                       |
 |                                                                           |
 +===========================================================================*/

PROCEDURE populate_tax_data (
          P_REPORTING_LEVEL	        IN	VARCHAR2	      DEFAULT NULL,
          P_REPORTING_CONTEXT	        IN	VARCHAR2	      DEFAULT NULL,
-- apai           P_LEGAL_ENTITY_LEVEL	        IN	VARCHAR2	      DEFAULT NULL,
          P_LEGAL_ENTITY_ID	        IN	NUMBER	              DEFAULT NULL, -- apai COMPANY_NAME
          P_SUMMARY_LEVEL               IN      VARCHAR2              DEFAULT NULL,
          P_LEDGER_ID	                IN	NUMBER	              DEFAULT NULL,
          P_REGISTER_TYPE	        IN	VARCHAR2	      DEFAULT NULL,
          P_PRODUCT	                IN	VARCHAR2	      DEFAULT NULL,
          P_MATRIX_REPORT	        IN	VARCHAR2	      DEFAULT NULL,
          P_DETAIL_LEVEL                IN      VARCHAR2              DEFAULT NULL,
          P_CURRENCY_CODE_LOW	        IN	VARCHAR2	      DEFAULT NULL,
          P_CURRENCY_CODE_HIGH	        IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_AP_STD_TRX_CLASS	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_AP_DM_TRX_CLASS	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_AP_CM_TRX_CLASS	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_AP_PREP_TRX_CLASS	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_AP_MIX_TRX_CLASS	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_AP_EXP_TRX_CLASS	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_AP_INT_TRX_CLASS	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_AR_INV_TRX_CLASS	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_AR_APPL_TRX_CLASS	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_AR_ADJ_TRX_CLASS	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_AR_MISC_TRX_CLASS	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_AR_BR_TRX_CLASS	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_GL_MANUAL_LINES	IN	VARCHAR2	      DEFAULT NULL,
          P_THIRD_PARTY_REP_LEVEL       IN      VARCHAR2              DEFAULT NULL,
          P_FIRST_PARTY_TAX_REG_NUM     IN    VARCHAR2                DEFAULT NULL,
          P_TRX_NUMBER_LOW	        IN	VARCHAR2	      DEFAULT NULL,
          P_TRX_NUMBER_HIGH	        IN	VARCHAR2	      DEFAULT NULL,
          P_EXTRACT_REPORT_LINE_NUMBER  IN      NUMBER                DEFAULT 1,
          P_AR_TRX_PRINTING_STATUS	IN	VARCHAR2	      DEFAULT NULL,
          P_AR_EXEMPTION_STATUS	        IN	VARCHAR2	      DEFAULT NULL,
          P_GL_DATE_LOW	                IN	DATE	              DEFAULT NULL,
          P_GL_DATE_HIGH	        IN	DATE	              DEFAULT NULL,
          P_TRX_DATE_LOW	        IN	DATE	              DEFAULT NULL,
          P_TRX_DATE_HIGH	        IN	DATE	              DEFAULT NULL,
          P_GL_PERIOD_NAME_LOW	        IN	VARCHAR2	      DEFAULT NULL,
          P_GL_PERIOD_NAME_HIGH	        IN	VARCHAR2	      DEFAULT NULL,
          P_TRX_DATE_PERIOD_NAME_LOW	IN	VARCHAR2	      DEFAULT NULL,
          P_TRX_DATE_PERIOD_NAME_HIGH	IN	VARCHAR2	      DEFAULT NULL,
          P_TAX_JURISDICTION_CODE       IN      VARCHAR               DEFAULT NULL,
          P_TAX_REGIME_CODE	        IN	VARCHAR2	      DEFAULT NULL,
          P_TAX	                        IN	VARCHAR2	      DEFAULT NULL,
          P_TAX_STATUS_CODE	        IN	VARCHAR2	      DEFAULT NULL,
          P_TAX_RATE_CODE_LOW	        IN	VARCHAR2	      DEFAULT NULL,
          P_TAX_RATE_CODE_HIGH	        IN	VARCHAR2	      DEFAULT NULL,
          P_TAX_TYPE_CODE_LOW	        IN	VARCHAR2	      DEFAULT NULL,
          P_TAX_TYPE_CODE_HIGH	        IN	VARCHAR2	      DEFAULT NULL,
          P_DOCUMENT_SUB_TYPE	        IN	VARCHAR2	      DEFAULT NULL,
          P_TRX_BUSINESS_CATEGORY	IN	VARCHAR2	      DEFAULT NULL,
          P_TAX_INVOICE_DATE_LOW	IN	VARCHAR2	      DEFAULT NULL,
          P_TAX_INVOICE_DATE_HIGH	IN	VARCHAR2	      DEFAULT NULL,
          P_POSTING_STATUS	        IN	VARCHAR2	      DEFAULT NULL,
          P_EXTRACT_ACCTED_TAX_LINES	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_ACCOUNTING_SEGMENTS	IN	VARCHAR2	      DEFAULT NULL,
          P_BALANCING_SEGMENT_LOW	IN	VARCHAR2	      DEFAULT NULL,
          P_BALANCING_SEGMENT_HIGH	IN	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_DISCOUNTS	        IN	VARCHAR2	      DEFAULT NULL,
          P_EXTRACT_STARTING_LINE_NUM	IN     	NUMBER	              DEFAULT NULL,
          P_REQUEST_ID	                IN     	NUMBER	              DEFAULT NULL,
          P_REPORT_NAME	                IN     	VARCHAR2	      DEFAULT NULL,
          P_VAT_TRANSACTION_TYPE_CODE	IN     	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_FULLY_NR_TAX_FLAG	IN     	VARCHAR2	      DEFAULT NULL,
          P_MUNICIPAL_TAX_TYPE_CODE_LOW	IN     	VARCHAR2	      DEFAULT NULL,
          P_MUNICIPAL_TAX_TYPE_CODE_HIGH	IN     	VARCHAR2	      DEFAULT NULL,
          P_PROV_TAX_TYPE_CODE_LOW	IN     	VARCHAR2	      DEFAULT NULL,
          P_PROV_TAX_TYPE_CODE_HIGH	IN     	VARCHAR2	      DEFAULT NULL,
          P_EXCISE_TAX_TYPE_CODE_LOW	IN     	VARCHAR2	      DEFAULT NULL,
          P_EXCISE_TAX_TYPE_CODE_HIGH	IN     	VARCHAR2	      DEFAULT NULL,
          P_NON_TAXABLE_TAX_TYPE_CODE	IN     	VARCHAR2	      DEFAULT NULL,
          P_PER_TAX_TYPE_CODE_LOW	IN     	VARCHAR2	      DEFAULT NULL,
          P_PER_TAX_TYPE_CODE_HIGH	IN     	VARCHAR2	      DEFAULT NULL,
          P_FED_PER_TAX_TYPE_CODE_LOW	IN     	VARCHAR2	      DEFAULT NULL,
          P_FED_PER_TAX_TYPE_CODE_HIGH	IN     	VARCHAR2	      DEFAULT NULL,
          P_VAT_TAX_TYPE_CODE	        IN     	VARCHAR2	      DEFAULT NULL,
          P_EXCISE_TAX	                IN     	VARCHAR2	      DEFAULT NULL,
          P_VAT_ADDITIONAL_TAX	        IN     	VARCHAR2	      DEFAULT NULL,
          P_VAT_NON_TAXABLE_TAX	        IN     	VARCHAR2	      DEFAULT NULL,
          P_VAT_NOT_TAX	                IN     	VARCHAR2	      DEFAULT NULL,
          P_VAT_PERCEPTION_TAX	        IN     	VARCHAR2	      DEFAULT NULL,
          P_VAT_TAX	                IN     	VARCHAR2	      DEFAULT NULL,
          P_INC_SELF_WD_TAX	        IN     	VARCHAR2	      DEFAULT NULL,
          P_EXCLUDING_TRX_LETTER	IN     	VARCHAR2	      DEFAULT NULL,
          P_TRX_LETTER_LOW	        IN     	VARCHAR2	      DEFAULT NULL,
          P_TRX_LETTER_HIGH	        IN     	VARCHAR2	      DEFAULT NULL,
          P_INCLUDE_REFERENCED_SOURCE	IN     	VARCHAR2	      DEFAULT NULL,
          P_PARTY_NAME	                IN     	VARCHAR2	      DEFAULT NULL,
          P_BATCH_NAME	                IN     	VARCHAR2	      DEFAULT NULL,
          P_BATCH_DATE_LOW              IN      DATE                  DEFAULT NULL,
          P_BATCH_DATE_HIGH             IN      DATE                  DEFAULT NULL,
          P_BATCH_SOURCE_ID	        IN     	VARCHAR2	      DEFAULT NULL,
          P_ADJUSTED_DOC_FROM	        IN     	VARCHAR2	      DEFAULT NULL,
          P_ADJUSTED_DOC_TO	        IN     	VARCHAR2	      DEFAULT NULL,
          P_STANDARD_VAT_TAX_RATE	IN     	VARCHAR2	      DEFAULT NULL,
          P_MUNICIPAL_TAX	        IN     	VARCHAR2	      DEFAULT NULL,
          P_PROVINCIAL_TAX	        IN     	VARCHAR2	      DEFAULT NULL,
          P_TAX_ACCOUNT_LOW	        IN     	VARCHAR2	      DEFAULT NULL,
          P_TAX_ACCOUNT_HIGH	        IN     	VARCHAR2	      DEFAULT NULL,
          P_EXP_CERT_DATE_FROM	        IN     	DATE	              DEFAULT NULL,
          P_EXP_CERT_DATE_TO	        IN     	DATE	              DEFAULT NULL,
          P_EXP_METHOD	                IN     	VARCHAR2	      DEFAULT NULL,
          P_PRINT_COMPANY_INFO	        IN     	VARCHAR2	      DEFAULT NULL,
          P_ORDER_BY                    IN      VARCHAR2              DEFAULT NULL,
          P_CHART_OF_ACCOUNTS_ID        IN      NUMBER                DEFAULT NULL,
          P_REPRINT                     IN      VARCHAR2              DEFAULT NULL,
          P_ERRBUF	                IN OUT NOCOPY VARCHAR2              ,
          P_RETCODE	                IN OUT NOCOPY VARCHAR2              ,
          P_ACCOUNTING_STATUS              IN   VARCHAR2  DEFAULT NULL,
          P_REPORTED_STATUS                   IN    VARCHAR2 DEFAULT NULL,
          P_TAXABLE_ACCOUNT_LOW    IN    VARCHAR2 DEFAULT NULL,
          P_TAXABLE_ACCOUNT_HIGH   IN    VARCHAR2 DEFAULT NULL,
	        P_GL_OR_TRX_DATE_FILTER   IN VARCHAR2 DEFAULT 'N', --Bug 5396444
	        --Bug 9031051
          P_ESL_DEFAULT_TAX_DATE        IN VARCHAR2 DEFAULT NULL,
          P_ESL_OUT_OF_PERIOD_ADJ       IN VARCHAR2 DEFAULT NULL,
          P_ESL_EU_TRX_TYPE             IN VARCHAR2 DEFAULT NULL,
          P_ESL_EU_GOODS                IN VARCHAR2 DEFAULT NULL,
          P_ESL_EU_SERVICES             IN VARCHAR2 DEFAULT NULL,
          P_ESL_EU_ADDL_CODE1           IN VARCHAR2 DEFAULT NULL,
          P_ESL_EU_ADDL_CODE2           IN VARCHAR2 DEFAULT NULL,
          P_ESL_SITE_CODE        IN VARCHAR2 DEFAULT NULL)
IS
    l_trl_global_variables_rec    TRL_GLOBAL_VARIABLES_REC_TYPE;
BEGIN
   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 -- g_current_runtime_level := 1;
-- g_level_procedure := 2;
   IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.populate_tax_data.BEGIN',
                                      'ZX_EXTRACT_PKG:populate_tax_data(+)');
   END IF;

--  Initialize the parameters:

 initialize(
           L_TRL_GLOBAL_VARIABLES_REC,
           P_REPORTING_LEVEL,
           P_REPORTING_CONTEXT,
-- apai            P_LEGAL_ENTITY_LEVEL,
           P_LEGAL_ENTITY_ID,
           P_SUMMARY_LEVEL,
           P_LEDGER_ID,
           P_REGISTER_TYPE,
           P_PRODUCT,
           P_MATRIX_REPORT,
           P_DETAIL_LEVEL,
           P_CURRENCY_CODE_LOW,
           P_CURRENCY_CODE_HIGH,
           P_INCLUDE_AP_STD_TRX_CLASS,
           P_INCLUDE_AP_DM_TRX_CLASS,
           P_INCLUDE_AP_CM_TRX_CLASS,
           P_INCLUDE_AP_PREP_TRX_CLASS,
           P_INCLUDE_AP_MIX_TRX_CLASS,
           P_INCLUDE_AP_EXP_TRX_CLASS,
           P_INCLUDE_AP_INT_TRX_CLASS,
           P_INCLUDE_AR_INV_TRX_CLASS,
           P_INCLUDE_AR_APPL_TRX_CLASS,
           P_INCLUDE_AR_ADJ_TRX_CLASS,
           P_INCLUDE_AR_MISC_TRX_CLASS,
           P_INCLUDE_AR_BR_TRX_CLASS,
           P_INCLUDE_GL_MANUAL_LINES,
           P_THIRD_PARTY_REP_LEVEL,
           P_FIRST_PARTY_TAX_REG_NUM,
           P_TRX_NUMBER_LOW,
           P_TRX_NUMBER_HIGH,
           P_EXTRACT_REPORT_LINE_NUMBER,
           P_AR_TRX_PRINTING_STATUS,
           P_AR_EXEMPTION_STATUS,
           P_GL_DATE_LOW,
           P_GL_DATE_HIGH,
           P_TRX_DATE_LOW,
           P_TRX_DATE_HIGH,
           P_GL_PERIOD_NAME_LOW,
           P_GL_PERIOD_NAME_HIGH,
           P_TRX_DATE_PERIOD_NAME_LOW,
           P_TRX_DATE_PERIOD_NAME_HIGH,
           P_TAX_JURISDICTION_CODE,
           P_TAX_REGIME_CODE,
           P_TAX,
           P_TAX_STATUS_CODE,
           P_TAX_RATE_CODE_LOW,
           P_TAX_RATE_CODE_HIGH,
           P_TAX_TYPE_CODE_LOW,
           P_TAX_TYPE_CODE_HIGH,
           P_DOCUMENT_SUB_TYPE,
           P_TRX_BUSINESS_CATEGORY,
           P_TAX_INVOICE_DATE_LOW,
           P_TAX_INVOICE_DATE_HIGH,
           P_POSTING_STATUS,
           P_EXTRACT_ACCTED_TAX_LINES,
           P_INCLUDE_ACCOUNTING_SEGMENTS,
           P_BALANCING_SEGMENT_LOW,
           P_BALANCING_SEGMENT_HIGH,
           P_INCLUDE_DISCOUNTS,
           P_EXTRACT_STARTING_LINE_NUM,
           P_REQUEST_ID,
           P_REPORT_NAME,
           P_VAT_TRANSACTION_TYPE_CODE,
           P_INCLUDE_FULLY_NR_TAX_FLAG,
           P_MUNICIPAL_TAX_TYPE_CODE_LOW,
           P_MUNICIPAL_TAX_TYPE_CODE_HIGH,
           P_PROV_TAX_TYPE_CODE_LOW,
           P_PROV_TAX_TYPE_CODE_HIGH,
           P_EXCISE_TAX_TYPE_CODE_LOW,
           P_EXCISE_TAX_TYPE_CODE_HIGH,
           P_NON_TAXABLE_TAX_TYPE_CODE,
           P_PER_TAX_TYPE_CODE_LOW,
           P_PER_TAX_TYPE_CODE_HIGH,
           P_FED_PER_TAX_TYPE_CODE_LOW,
           P_FED_PER_TAX_TYPE_CODE_HIGH,
           P_VAT_TAX_TYPE_CODE,
           P_EXCISE_TAX,
           P_VAT_ADDITIONAL_TAX,
           P_VAT_NON_TAXABLE_TAX,
           P_VAT_NOT_TAX,
           P_VAT_PERCEPTION_TAX,
           P_VAT_TAX,
           P_INC_SELF_WD_TAX,
           P_EXCLUDING_TRX_LETTER,
           P_TRX_LETTER_LOW,
           P_TRX_LETTER_HIGH,
           P_INCLUDE_REFERENCED_SOURCE,
           P_PARTY_NAME,
           P_BATCH_NAME,
           P_BATCH_DATE_LOW,
           P_BATCH_DATE_HIGH,
           P_BATCH_SOURCE_ID,
           P_ADJUSTED_DOC_FROM,
           P_ADJUSTED_DOC_TO,
           P_STANDARD_VAT_TAX_RATE,
           P_MUNICIPAL_TAX,
           P_PROVINCIAL_TAX,
           P_TAX_ACCOUNT_LOW,
           P_TAX_ACCOUNT_HIGH,
           P_EXP_CERT_DATE_FROM,
           P_EXP_CERT_DATE_TO,
           P_EXP_METHOD,
           P_PRINT_COMPANY_INFO,
           P_ORDER_BY,
           P_CHART_OF_ACCOUNTS_ID,
           P_REPRINT,
           P_ERRBUF,
           P_RETCODE,
           P_ACCOUNTING_STATUS,
           P_REPORTED_STATUS,
           P_TAXABLE_ACCOUNT_LOW,
           P_TAXABLE_ACCOUNT_HIGH,
	         P_GL_OR_TRX_DATE_FILTER, --Bug 5396444
	         --Bug 9031051
           P_ESL_DEFAULT_TAX_DATE,
           P_ESL_OUT_OF_PERIOD_ADJ,
           P_ESL_EU_TRX_TYPE,
           P_ESL_EU_GOODS,
           P_ESL_EU_SERVICES,
           P_ESL_EU_ADDL_CODE1,
           P_ESL_EU_ADDL_CODE2,
           P_ESL_SITE_CODE);

--  Check whether this is a Multi Org or Non Multi Org installation;

--  Derive the dependent parameters:

    derive_dependent_parameters(l_trl_global_variables_rec);

    IF g_ledger_type = 'R' THEN
       fnd_client_info.set_currency_context(p_ledger_id);
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.populate_tax_data',
                                  'Return Code Check '||to_char(l_trl_global_variables_rec.retcode));
    END IF;

    IF validate_parameters(l_trl_global_variables_rec) THEN
       IF l_trl_global_variables_rec.retcode <> 2 THEN
          extract_rep_context_info(l_trl_global_variables_rec);
       END IF;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.populate_tax_data',
                                  'ZX.TRL.ZX_EXTRACT_PKG.EXTRACT_TAX_INFO Call');
       END IF;

       IF l_trl_global_variables_rec.retcode <> 2 THEN
          extract_tax_info(g_ledger_type, l_trl_global_variables_rec);
       END IF;
         IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.populate_tax_data',
                                  'extract_additional_info call : '||to_char(l_trl_global_variables_rec.retcode));
       END IF;
     --  IF l_trl_global_variables_rec.retcode <> 2 THEN
          extract_additional_info(g_ledger_type, l_trl_global_variables_rec) ;
         cleanup(l_trl_global_variables_rec);
         --COMMIT; Bug 8262631

     -- END IF;

       IF l_trl_global_variables_rec.retcode <> 2 THEN
         cleanup(l_trl_global_variables_rec);
       ELSE
         delete_all(l_trl_global_variables_rec.request_id);
       END IF;
          --COMMIT; Bug 8262631

       l_errbuf := trim(substrb(L_ERRBUF,1,240))||
                     trim(substrb(L_PARAMLIST,1,1500));
       p_errbuf := substrb(L_ERRBUF,1,l_length_errbuf);
   --    p_retcode := l_retcode;


      IF p_retcode IS NULL THEN
         p_retcode := 0;
      END IF;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.Return Code ',
                               'ZX_EXTRACT_PKG:populate_tax_data' ||to_char(l_trl_global_variables_rec.retcode));
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.populate_tax_data.END',
                               'ZX_EXTRACT_PKG:populate_tax_data(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_EXTRACT_PKG.populate_tax_data',
                      g_error_buffer);
    END IF;

     P_RETCODE := l_trl_global_variables_rec.retcode;

END populate_tax_data;

------------------------------------------------------------------------------
--    PRIVATE METHODS
------------------------------------------------------------------------------


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   INITIALIZE                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure initializes the parameters for procedure                |
 |    ZX_EXTRACT_PKG.populate_tax_data, and writes the values of parameters  |
 |    passed in debug file and p_errbuf.                                      |
 |                                                                           |
 |    Called from ZX_EXTRACT_PKG.populate_tax_data                           |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   08-Feb-2005      Srinivasa Rao Korrapati  Created                       |
 |                                                                           |
 +===========================================================================*/

PROCEDURE initialize(
            P_TRL_GLOBAL_VARIABLES_REC    IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
            P_REPORTING_LEVEL	          IN	VARCHAR2,
            P_REPORTING_CONTEXT	          IN	VARCHAR2,
--            P_LEGAL_ENTITY_LEVEL	  IN	VARCHAR2,
            P_LEGAL_ENTITY_ID	          IN	NUMBER	, -- apai COMPANY_NAME
            P_SUMMARY_LEVEL               IN      VARCHAR2,
            P_LEDGER_ID	                  IN	NUMBER	,
            P_REGISTER_TYPE	          IN	VARCHAR2,
            P_PRODUCT	                  IN	VARCHAR2,
            P_MATRIX_REPORT	          IN	VARCHAR2,
            P_DETAIL_LEVEL                IN      VARCHAR2,
            P_CURRENCY_CODE_LOW	          IN	VARCHAR2,
            P_CURRENCY_CODE_HIGH	  IN	VARCHAR2,
            P_INCLUDE_AP_STD_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AP_DM_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AP_CM_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AP_PREP_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AP_MIX_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AP_EXP_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AP_INT_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AR_INV_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AR_APPL_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AR_ADJ_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AR_MISC_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_AR_BR_TRX_CLASS	  IN	VARCHAR2,
            P_INCLUDE_GL_MANUAL_LINES	  IN	VARCHAR2,
            P_THIRD_PARTY_REP_LEVEL       IN      VARCHAR2,
            P_FIRST_PARTY_TAX_REG_NUM     IN    VARCHAR2,
            P_TRX_NUMBER_LOW	          IN	VARCHAR2,
            P_TRX_NUMBER_HIGH	          IN	VARCHAR2,
            P_EXTRACT_REPORT_LINE_NUMBER    IN      NUMBER  ,
            P_AR_TRX_PRINTING_STATUS	  IN	VARCHAR2,
            P_AR_EXEMPTION_STATUS	  IN	VARCHAR2,
            P_GL_DATE_LOW	          IN	DATE	,
            P_GL_DATE_HIGH	          IN	DATE	,
            P_TRX_DATE_LOW	          IN	DATE	,
            P_TRX_DATE_HIGH	          IN	DATE	,
            P_GL_PERIOD_NAME_LOW	  IN	VARCHAR2,
            P_GL_PERIOD_NAME_HIGH	  IN	VARCHAR2,
            P_TRX_DATE_PERIOD_NAME_LOW	  IN	VARCHAR2,
            P_TRX_DATE_PERIOD_NAME_HIGH	  IN	VARCHAR2,
            P_TAX_JURISDICTION_CODE       IN      VARCHAR ,
            P_TAX_REGIME_CODE	          IN	VARCHAR2,
            P_TAX	                  IN	VARCHAR2,
            P_TAX_STATUS_CODE	          IN	VARCHAR2,
            P_TAX_RATE_CODE_LOW	          IN	VARCHAR2,
            P_TAX_RATE_CODE_HIGH	  IN	VARCHAR2,
            P_TAX_TYPE_CODE_LOW	          IN	VARCHAR2,
            P_TAX_TYPE_CODE_HIGH	  IN	VARCHAR2,
            P_DOCUMENT_SUB_TYPE	          IN	VARCHAR2,
            P_TRX_BUSINESS_CATEGORY	  IN	VARCHAR2,
            P_TAX_INVOICE_DATE_LOW	  IN	VARCHAR2,
            P_TAX_INVOICE_DATE_HIGH	  IN	VARCHAR2,
            P_POSTING_STATUS	          IN	VARCHAR2,
            P_EXTRACT_ACCTED_TAX_LINES	  IN	VARCHAR2,
            P_INCLUDE_ACCOUNTING_SEGMENTS IN	VARCHAR2,
            P_BALANCING_SEGMENT_LOW	  IN	VARCHAR2,
            P_BALANCING_SEGMENT_HIGH	  IN	VARCHAR2,
            P_INCLUDE_DISCOUNTS	          IN	VARCHAR2,
            P_EXTRACT_STARTING_LINE_NUM	  IN     	NUMBER	,
            P_REQUEST_ID	          IN     	NUMBER	,
            P_REPORT_NAME	          IN     	VARCHAR2,
            P_VAT_TRANSACTION_TYPE_CODE	  IN     	VARCHAR2,
            P_INCLUDE_FULLY_NR_TAX_FLAG	  IN     	VARCHAR2,
            P_MUNICIPAL_TAX_TYPE_CODE_LOW	IN     	VARCHAR2,
            P_MUNICIPAL_TAX_TYPE_CODE_HIGH	IN     	VARCHAR2,
            P_PROV_TAX_TYPE_CODE_LOW	  IN     	VARCHAR2,
            P_PROV_TAX_TYPE_CODE_HIGH	  IN     	VARCHAR2,
            P_EXCISE_TAX_TYPE_CODE_LOW	  IN     	VARCHAR2,
            P_EXCISE_TAX_TYPE_CODE_HIGH	  IN     	VARCHAR2,
            P_NON_TAXABLE_TAX_TYPE_CODE	  IN     	VARCHAR2,
            P_PER_TAX_TYPE_CODE_LOW	  IN     	VARCHAR2,
            P_PER_TAX_TYPE_CODE_HIGH	  IN     	VARCHAR2,
            P_FED_PER_TAX_TYPE_CODE_LOW	  IN     	VARCHAR2,
            P_FED_PER_TAX_TYPE_CODE_HIGH	IN     	VARCHAR2,
            P_VAT_TAX_TYPE_CODE	          IN     	VARCHAR2,
            P_EXCISE_TAX	          IN     	VARCHAR2,
            P_VAT_ADDITIONAL_TAX	  IN     	VARCHAR2,
            P_VAT_NON_TAXABLE_TAX	  IN     	VARCHAR2,
            P_VAT_NOT_TAX	          IN     	VARCHAR2,
            P_VAT_PERCEPTION_TAX	  IN     	VARCHAR2,
            P_VAT_TAX	                  IN     	VARCHAR2,
            P_INC_SELF_WD_TAX	          IN     	VARCHAR2,
            P_EXCLUDING_TRX_LETTER	  IN     	VARCHAR2,
            P_TRX_LETTER_LOW	          IN     	VARCHAR2,
            P_TRX_LETTER_HIGH	          IN     	VARCHAR2,
            P_INCLUDE_REFERENCED_SOURCE	  IN     	VARCHAR2,
            P_PARTY_NAME	          IN     	VARCHAR2,
            P_BATCH_NAME	          IN     	VARCHAR2,
            P_BATCH_DATE_LOW              IN      DATE    ,
            P_BATCH_DATE_HIGH             IN      DATE    ,
            P_BATCH_SOURCE_ID	          IN     	VARCHAR2,
            P_ADJUSTED_DOC_FROM	          IN     	VARCHAR2,
            P_ADJUSTED_DOC_TO	          IN     	VARCHAR2,
            P_STANDARD_VAT_TAX_RATE	  IN     	VARCHAR2,
            P_MUNICIPAL_TAX	          IN     	VARCHAR2,
            P_PROVINCIAL_TAX	          IN     	VARCHAR2,
            P_TAX_ACCOUNT_LOW	          IN     	VARCHAR2,
            P_TAX_ACCOUNT_HIGH	          IN     	VARCHAR2,
            P_EXP_CERT_DATE_FROM	  IN     	DATE	,
            P_EXP_CERT_DATE_TO	          IN     	DATE	,
            P_EXP_METHOD	          IN     	VARCHAR2,
            P_PRINT_COMPANY_INFO	  IN     	VARCHAR2,
            P_ORDER_BY                    IN      VARCHAR2,
            P_CHART_OF_ACCOUNTS_ID        IN      NUMBER  ,
            P_REPRINT                     IN      VARCHAR2,
            P_ERRBUF	                  IN OUT NOCOPY VARCHAR2,
            P_RETCODE	                  IN OUT NOCOPY VARCHAR2,
            P_ACCOUNTING_STATUS           IN     VARCHAR2,
            P_REPORTED_STATUS             IN     VARCHAR2,
            P_TAXABLE_ACCOUNT_LOW         IN     VARCHAR2,
            P_TAXABLE_ACCOUNT_HIGH        IN     VARCHAR2,
	          P_GL_OR_TRX_DATE_FILTER	  IN	 VARCHAR2,  --Bug 5396444
	          --Bug 9031051
            P_ESL_DEFAULT_TAX_DATE        IN VARCHAR2,
            P_ESL_OUT_OF_PERIOD_ADJ       IN VARCHAR2,
            P_ESL_EU_TRX_TYPE             IN VARCHAR2,
            P_ESL_EU_GOODS                IN VARCHAR2,
            P_ESL_EU_SERVICES             IN VARCHAR2,
            P_ESL_EU_ADDL_CODE1           IN VARCHAR2,
            P_ESL_EU_ADDL_CODE2           IN VARCHAR2,
            P_ESL_SITE_CODE        IN VARCHAR2 )
IS
BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE.BEGIN',
                                         'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE(+)');

        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                         'P_REPORTING_LEVEL  =   '||P_REPORTING_LEVEL);


        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                         'P_REPORTING_CONTEXT  =   '||P_REPORTING_CONTEXT);
/* apai
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                  'P_LEGAL_ENTITY_LEVEL  =   '||P_LEGAL_ENTITY_LEVEL);
*/
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                  'P_LEGAL_ENTITY_ID  =   '||P_LEGAL_ENTITY_ID);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                  'P_SUMMARY_LEVEL  =   '||P_SUMMARY_LEVEL);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                  'P_LEDGER_ID  =   '||P_LEDGER_ID);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                  'P_REGISTER_TYPE  =   '||P_REGISTER_TYPE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                    'P_PRODUCT  =   '||P_PRODUCT);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                    'P_MATRIX_REPORT  =   '||P_MATRIX_REPORT);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                     'P_CURRENCY_CODE_LOW  =   '||P_CURRENCY_CODE_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                     'P_CURRENCY_CODE_HIGH  =   '||P_CURRENCY_CODE_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                     'P_INCLUDE_AP_STD_TRX_CLASS  =   '||P_INCLUDE_AP_STD_TRX_CLASS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                   'P_INCLUDE_AP_DM_TRX_CLASS  =   '||P_INCLUDE_AP_DM_TRX_CLASS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                     'P_INCLUDE_AP_CM_TRX_CLASS  =   '||P_INCLUDE_AP_CM_TRX_CLASS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                     'P_INCLUDE_AP_PREP_TRX_CLASS  =   '||P_INCLUDE_AP_PREP_TRX_CLASS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                   'P_INCLUDE_AP_MIX_TRX_CLASS  =   '||P_INCLUDE_AP_MIX_TRX_CLASS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                     'P_INCLUDE_AP_EXP_TRX_CLASS  =   '||P_INCLUDE_AP_EXP_TRX_CLASS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                     'P_INCLUDE_AP_INT_TRX_CLASS  =   '||P_INCLUDE_AP_INT_TRX_CLASS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                   'P_INCLUDE_AR_INV_TRX_CLASS  =   '||P_INCLUDE_AR_INV_TRX_CLASS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_INCLUDE_AR_APPL_TRX_CLASS  =   '||P_INCLUDE_AR_APPL_TRX_CLASS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_INCLUDE_AR_ADJ_TRX_CLASS  =   '||P_INCLUDE_AR_ADJ_TRX_CLASS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_INCLUDE_AR_MISC_TRX_CLASS  =   '||P_INCLUDE_AR_MISC_TRX_CLASS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_INCLUDE_AR_BR_TRX_CLASS  =   '||P_INCLUDE_AR_BR_TRX_CLASS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_INCLUDE_GL_MANUAL_LINES  =   '||P_INCLUDE_GL_MANUAL_LINES);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_THIRD_PARTY_REP_LEVEL  =   '||P_THIRD_PARTY_REP_LEVEL);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_FIRST_PARTY_TAX_REG_NUM  =   '||P_FIRST_PARTY_TAX_REG_NUM);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TRX_NUMBER_LOW  =   '||P_TRX_NUMBER_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TRX_NUMBER_HIGH  =   '||P_TRX_NUMBER_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_AR_TRX_PRINTING_STATUS  =   '||P_AR_TRX_PRINTING_STATUS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_AR_EXEMPTION_STATUS  =   '||P_AR_EXEMPTION_STATUS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_GL_DATE_LOW  =   '||P_GL_DATE_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_GL_DATE_HIGH  =   '||P_GL_DATE_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_TRX_DATE_LOW  =   '||P_TRX_DATE_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TRX_DATE_HIGH  =   '||P_TRX_DATE_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_GL_PERIOD_NAME_LOW  =   '||P_GL_PERIOD_NAME_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_GL_PERIOD_NAME_HIGH  =   '||P_GL_PERIOD_NAME_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TRX_DATE_PERIOD_NAME_LOW  =   '||P_TRX_DATE_PERIOD_NAME_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TRX_DATE_PERIOD_NAME_HIGH  =   '||P_TRX_DATE_PERIOD_NAME_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TAX_JURISDICTION_CODE  =   '||P_TAX_JURISDICTION_CODE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TAX_REGIME_CODE  =   '||P_TAX_REGIME_CODE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TAX  =   '||P_TAX);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TAX_STATUS_CODE  =   '||P_TAX_STATUS_CODE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TAX_RATE_CODE_LOW  =   '||P_TAX_RATE_CODE_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TAX_RATE_CODE_HIGH  =   '||P_TAX_RATE_CODE_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TAX_TYPE_CODE_LOW  =   '||P_TAX_TYPE_CODE_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TAX_TYPE_CODE_HIGH  =   '||P_TAX_TYPE_CODE_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_DOCUMENT_SUB_TYPE  =   '||P_DOCUMENT_SUB_TYPE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TRX_BUSINESS_CATEGORY  =   '||P_TRX_BUSINESS_CATEGORY);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TAX_INVOICE_DATE_LOW  =   '||P_TAX_INVOICE_DATE_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_TAX_INVOICE_DATE_HIGH  =   '||P_TAX_INVOICE_DATE_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_POSTING_STATUS  =   '||P_POSTING_STATUS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ACCOUNTING_STATUS  =   '||P_ACCOUNTING_STATUS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_REPORTED_STATUS  =   '||P_REPORTED_STATUS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_EXTRACT_ACCTED_TAX_LINES  =   '||P_EXTRACT_ACCTED_TAX_LINES);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_INCLUDE_ACCOUNTING_SEGMENTS  =   '||P_INCLUDE_ACCOUNTING_SEGMENTS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_BALANCING_SEGMENT_LOW  =   '||P_BALANCING_SEGMENT_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_BALANCING_SEGMENT_HIGH  =   '||P_BALANCING_SEGMENT_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_INCLUDE_DISCOUNTS  =   '||P_INCLUDE_DISCOUNTS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_EXTRACT_STARTING_LINE_NUM  =   '||P_EXTRACT_STARTING_LINE_NUM);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_REQUEST_ID  =   '||P_REQUEST_ID);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_REPORT_NAME  =   '||P_REPORT_NAME);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_VAT_TRANSACTION_TYPE_CODE  =   '||P_VAT_TRANSACTION_TYPE_CODE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_INCLUDE_FULLY_NR_TAX_FLAG  =   '||P_INCLUDE_FULLY_NR_TAX_FLAG);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_MUNICIPAL_TAX_TYPE_CODE_LOW  =   '||P_MUNICIPAL_TAX_TYPE_CODE_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_MUNICIPAL_TAX_TYPE_CODE_HIGH  =   '||P_MUNICIPAL_TAX_TYPE_CODE_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_PROVINCIAL_TAX_TYPE_CODE_LOW  =   '||P_PROV_TAX_TYPE_CODE_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_PROVINCIAL_TAX_TYPE__CODE_HIGH  =   '||P_PROV_TAX_TYPE_CODE_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_EXCISE_TAX_TYPE_CODE_LOW  =   '||P_EXCISE_TAX_TYPE_CODE_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_EXCISE_TAX_TYPE_CODE_HIGH  =   '||P_EXCISE_TAX_TYPE_CODE_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_NON_TAXABLE_TAX_TYPE_CODE  =   '||P_NON_TAXABLE_TAX_TYPE_CODE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_PERCEPTION_TAX_TYPE_CODE_LOW  =   '||P_PER_TAX_TYPE_CODE_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_PERCEPTION_TAX_TYPE_CODE_HIGH  =   '||P_PER_TAX_TYPE_CODE_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_FED_PER_TAX_TYPE_CODE_LOW  =   '||P_FED_PER_TAX_TYPE_CODE_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_FED_PER_TAX_TYPE_CODE_HIGH  =   '||P_FED_PER_TAX_TYPE_CODE_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_VAT_TAX_TYPE_CODE  =   '||P_VAT_TAX_TYPE_CODE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_EXCISE_TAX  =   '||P_EXCISE_TAX);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_VAT_ADDITIONAL_TAX  =   '||P_VAT_ADDITIONAL_TAX);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_VAT_NON_TAXABLE_TAX  =   '||P_VAT_NON_TAXABLE_TAX);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_VAT_NOT_TAX  =   '||P_VAT_NOT_TAX);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_VAT_PERCEPTION_TAX  =   '||P_VAT_PERCEPTION_TAX);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_VAT_TAX  =   '||P_VAT_TAX);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_INC_SELF_WD_TAX  =   '||P_INC_SELF_WD_TAX);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_EXCLUDING_TRX_LETTER  =   '||P_EXCLUDING_TRX_LETTER);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_TRX_LETTER_LOW  =   '||P_TRX_LETTER_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_TRX_LETTER_HIGH  =   '||P_TRX_LETTER_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_INCLUDE_REFERENCED_SOURCE  =   '||P_INCLUDE_REFERENCED_SOURCE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_PARTY_NAME  =   '||P_PARTY_NAME);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_BATCH_NAME  =   '||P_BATCH_NAME);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_BATCH_SOURCE_ID  =   '||P_BATCH_SOURCE_ID);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ADJUSTED_DOC_FROM  =   '||P_ADJUSTED_DOC_FROM);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ADJUSTED_DOC_TO  =   '||P_ADJUSTED_DOC_TO);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_STANDARD_VAT_TAX_RATE  =   '||P_STANDARD_VAT_TAX_RATE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_MUNICIPAL_TAX  =   '||P_MUNICIPAL_TAX);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_PROVINCIAL_TAX  =   '||P_PROVINCIAL_TAX);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_TAX_ACCOUNT_LOW  =   '||P_TAX_ACCOUNT_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_TAX_ACCOUNT_HIGH  =   '||P_TAX_ACCOUNT_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_EXP_CERT_DATE_FROM  =   '||P_EXP_CERT_DATE_FROM);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_EXP_CERT_DATE_TO  =   '||P_EXP_CERT_DATE_TO);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_EXP_METHOD  =   '||P_EXP_METHOD);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_TRX_NUMBER_LOW  =   '||P_TRX_NUMBER_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                'P_TRX_NUMBER_HIGH  =   '||P_TRX_NUMBER_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_PRINT_COMPANY_INFO  =   '||P_PRINT_COMPANY_INFO);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ORDER_BY  =   '||P_ORDER_BY);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ERRBUF  =   '||P_ERRBUF);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_RETCODE  =   '||P_RETCODE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_TAXABLE_ACCOUNT_LOW  =   '||P_TAXABLE_ACCOUNT_LOW);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_TAXABLE_ACCOUNT_HIGH  =   '||P_TAXABLE_ACCOUNT_HIGH);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_GL_OR_TRX_DATE_FILTER  =   '||P_GL_OR_TRX_DATE_FILTER); --Bug 5396444
        --Bug 9031051
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ESL_DEFAULT_TAX_DATE  =   '||P_ESL_DEFAULT_TAX_DATE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ESL_OUT_OF_PERIOD_ADJ  =   '||P_ESL_OUT_OF_PERIOD_ADJ);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ESL_EU_TRX_TYPE  =   '||P_ESL_EU_TRX_TYPE);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ESL_EU_GOODS  =   '||P_ESL_EU_GOODS);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ESL_EU_SERVICES  =   '||P_ESL_EU_SERVICES);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ESL_EU_ADDL_CODE1  =   '||P_ESL_EU_ADDL_CODE1);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ESL_EU_ADDL_CODE2  =   '||P_ESL_EU_ADDL_CODE2);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                              'P_ESL_SITE_CODE  =   '||P_ESL_SITE_CODE);

    END IF;

        P_TRL_GLOBAL_VARIABLES_REC.REPORTING_LEVEL           :=   P_REPORTING_LEVEL;
        P_TRL_GLOBAL_VARIABLES_REC.REPORTING_CONTEXT         :=   P_REPORTING_CONTEXT;
-- apai        P_TRL_GLOBAL_VARIABLES_REC.LEGAL_ENTITY_LEVEL        :=   P_LEGAL_ENTITY_LEVEL;
        P_TRL_GLOBAL_VARIABLES_REC.LEGAL_ENTITY_ID           :=   P_LEGAL_ENTITY_ID;
        P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL             :=   P_SUMMARY_LEVEL;
        P_TRL_GLOBAL_VARIABLES_REC.LEDGER_ID                 :=   P_LEDGER_ID;
        P_TRL_GLOBAL_VARIABLES_REC.REGISTER_TYPE             :=   P_REGISTER_TYPE;
        P_TRL_GLOBAL_VARIABLES_REC.PRODUCT                   :=   P_PRODUCT;
        P_TRL_GLOBAL_VARIABLES_REC.MATRIX_REPORT             :=   P_MATRIX_REPORT;
        P_TRL_GLOBAL_VARIABLES_REC.CURRENCY_CODE_LOW         :=   P_CURRENCY_CODE_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.CURRENCY_CODE_HIGH        :=   P_CURRENCY_CODE_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AP_STD_TRX_CLASS  :=   P_INCLUDE_AP_STD_TRX_CLASS;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AP_DM_TRX_CLASS   :=   P_INCLUDE_AP_DM_TRX_CLASS;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AP_CM_TRX_CLASS   :=   P_INCLUDE_AP_CM_TRX_CLASS;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AP_PREP_TRX_CLASS :=   P_INCLUDE_AP_PREP_TRX_CLASS;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AP_MIX_TRX_CLASS  :=   P_INCLUDE_AP_MIX_TRX_CLASS;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AP_EXP_TRX_CLASS  :=   P_INCLUDE_AP_EXP_TRX_CLASS;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AP_INT_TRX_CLASS  :=   P_INCLUDE_AP_INT_TRX_CLASS;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AR_INV_TRX_CLASS  :=   P_INCLUDE_AR_INV_TRX_CLASS;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AR_APPL_TRX_CLASS :=   P_INCLUDE_AR_APPL_TRX_CLASS;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AR_ADJ_TRX_CLASS  :=   P_INCLUDE_AR_ADJ_TRX_CLASS;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AR_MISC_TRX_CLASS :=   P_INCLUDE_AR_MISC_TRX_CLASS;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_AR_BR_TRX_CLASS   :=   P_INCLUDE_AR_BR_TRX_CLASS;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_GL_MANUAL_LINES   :=   P_INCLUDE_GL_MANUAL_LINES;
        P_TRL_GLOBAL_VARIABLES_REC.THIRD_PARTY_REP_LEVEL     :=   P_THIRD_PARTY_REP_LEVEL;
        P_TRL_GLOBAL_VARIABLES_REC.FIRST_PARTY_TAX_REG_NUM   :=   P_FIRST_PARTY_TAX_REG_NUM;
        P_TRL_GLOBAL_VARIABLES_REC.TRX_NUMBER_LOW            :=   P_TRX_NUMBER_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.TRX_NUMBER_HIGH           :=   P_TRX_NUMBER_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.AR_TRX_PRINTING_STATUS    :=   P_AR_TRX_PRINTING_STATUS;
        P_TRL_GLOBAL_VARIABLES_REC.AR_EXEMPTION_STATUS       :=   P_AR_EXEMPTION_STATUS;
        P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_LOW               :=   P_GL_DATE_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH              :=   P_GL_DATE_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_LOW              :=   P_TRX_DATE_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_HIGH             :=   P_TRX_DATE_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.GL_PERIOD_NAME_LOW        :=   P_GL_PERIOD_NAME_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.GL_PERIOD_NAME_HIGH       :=   P_GL_PERIOD_NAME_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_PERIOD_NAME_LOW  :=   P_TRX_DATE_PERIOD_NAME_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_PERIOD_NAME_HIGH :=   P_TRX_DATE_PERIOD_NAME_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.TAX_JURISDICTION_CODE     :=   P_TAX_JURISDICTION_CODE;
        P_TRL_GLOBAL_VARIABLES_REC.TAX_REGIME_CODE           :=   P_TAX_REGIME_CODE;
        P_TRL_GLOBAL_VARIABLES_REC.TAX                       :=   P_TAX;
        P_TRL_GLOBAL_VARIABLES_REC.TAX_STATUS_CODE           :=   P_TAX_STATUS_CODE;
        P_TRL_GLOBAL_VARIABLES_REC.TAX_RATE_CODE_LOW         :=   P_TAX_RATE_CODE_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.TAX_RATE_CODE_HIGH        :=   P_TAX_RATE_CODE_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.TAX_TYPE_CODE_LOW         :=   P_TAX_TYPE_CODE_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.TAX_TYPE_CODE_HIGH        :=   P_TAX_TYPE_CODE_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.DOCUMENT_SUB_TYPE         :=   P_DOCUMENT_SUB_TYPE;
        P_TRL_GLOBAL_VARIABLES_REC.TRX_BUSINESS_CATEGORY     :=   P_TRX_BUSINESS_CATEGORY;
        P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_LOW      :=   P_TAX_INVOICE_DATE_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_HIGH     :=   P_TAX_INVOICE_DATE_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.POSTING_STATUS            :=   P_POSTING_STATUS;
        P_TRL_GLOBAL_VARIABLES_REC.EXTRACT_ACCTED_TAX_LINES  :=   P_EXTRACT_ACCTED_TAX_LINES;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_ACCOUNTING_SEGMENTS :=   P_INCLUDE_ACCOUNTING_SEGMENTS;
        P_TRL_GLOBAL_VARIABLES_REC.BALANCING_SEGMENT_LOW     :=   P_BALANCING_SEGMENT_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.BALANCING_SEGMENT_HIGH    :=   P_BALANCING_SEGMENT_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_DISCOUNTS         :=   P_INCLUDE_DISCOUNTS;
        P_TRL_GLOBAL_VARIABLES_REC.EXTRACT_STARTING_LINE_NUM :=   P_EXTRACT_STARTING_LINE_NUM;
        P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID                :=   P_REQUEST_ID;
        P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME               :=   P_REPORT_NAME;
        P_TRL_GLOBAL_VARIABLES_REC.VAT_TRANSACTION_TYPE_CODE :=   P_VAT_TRANSACTION_TYPE_CODE;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_FULLY_NR_TAX_FLAG :=   P_INCLUDE_FULLY_NR_TAX_FLAG;
        P_TRL_GLOBAL_VARIABLES_REC.MUNICIPAL_TAX_TYPE_CODE_LOW  :=   P_MUNICIPAL_TAX_TYPE_CODE_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.MUNICIPAL_TAX_TYPE_CODE_HIGH :=   P_MUNICIPAL_TAX_TYPE_CODE_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.PROV_TAX_TYPE_CODE_LOW    :=   P_PROV_TAX_TYPE_CODE_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.PROV_TAX_TYPE_CODE_HIGH   :=   P_PROV_TAX_TYPE_CODE_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.EXCISE_TAX_TYPE_CODE_LOW  :=   P_EXCISE_TAX_TYPE_CODE_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.EXCISE_TAX_TYPE_CODE_HIGH :=   P_EXCISE_TAX_TYPE_CODE_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.NON_TAXABLE_TAX_TYPE_CODE :=   P_NON_TAXABLE_TAX_TYPE_CODE;
        P_TRL_GLOBAL_VARIABLES_REC.PER_TAX_TYPE_CODE_LOW     :=   P_PER_TAX_TYPE_CODE_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.PER_TAX_TYPE_CODE_HIGH    :=   P_PER_TAX_TYPE_CODE_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.VAT_TAX_TYPE_CODE         :=   P_VAT_TAX_TYPE_CODE;
        P_TRL_GLOBAL_VARIABLES_REC.EXCISE_TAX                :=   P_EXCISE_TAX;
        P_TRL_GLOBAL_VARIABLES_REC.VAT_ADDITIONAL_TAX        :=   P_VAT_ADDITIONAL_TAX;
        P_TRL_GLOBAL_VARIABLES_REC.VAT_NON_TAXABLE_TAX       :=   P_VAT_NON_TAXABLE_TAX;
        P_TRL_GLOBAL_VARIABLES_REC.VAT_NOT_TAX               :=   P_VAT_NOT_TAX;
        P_TRL_GLOBAL_VARIABLES_REC.VAT_PERCEPTION_TAX        :=   P_VAT_PERCEPTION_TAX;
        P_TRL_GLOBAL_VARIABLES_REC.VAT_TAX                   :=   P_VAT_TAX;
        P_TRL_GLOBAL_VARIABLES_REC.INC_SELF_WD_TAX           :=   P_INC_SELF_WD_TAX;
        P_TRL_GLOBAL_VARIABLES_REC.EXCLUDING_TRX_LETTER      :=   P_EXCLUDING_TRX_LETTER;
        P_TRL_GLOBAL_VARIABLES_REC.TRX_LETTER_LOW            :=   P_TRX_LETTER_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.TRX_LETTER_HIGH           :=   P_TRX_LETTER_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_REFERENCED_SOURCE :=   P_INCLUDE_REFERENCED_SOURCE;
        P_TRL_GLOBAL_VARIABLES_REC.PARTY_NAME                :=   P_PARTY_NAME;
        P_TRL_GLOBAL_VARIABLES_REC.BATCH_NAME                :=   P_BATCH_NAME;
        P_TRL_GLOBAL_VARIABLES_REC.BATCH_SOURCE_ID           :=   P_BATCH_SOURCE_ID;
        P_TRL_GLOBAL_VARIABLES_REC.ADJUSTED_DOC_FROM         :=   P_ADJUSTED_DOC_FROM;
        P_TRL_GLOBAL_VARIABLES_REC.ADJUSTED_DOC_TO           :=   P_ADJUSTED_DOC_TO;
        P_TRL_GLOBAL_VARIABLES_REC.STANDARD_VAT_TAX_RATE     :=   P_STANDARD_VAT_TAX_RATE;
        P_TRL_GLOBAL_VARIABLES_REC.MUNICIPAL_TAX             :=   P_MUNICIPAL_TAX;
        P_TRL_GLOBAL_VARIABLES_REC.PROVINCIAL_TAX            :=   P_PROVINCIAL_TAX;
        P_TRL_GLOBAL_VARIABLES_REC.TAX_ACCOUNT_LOW           :=   P_TAX_ACCOUNT_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.TAX_ACCOUNT_HIGH          :=   P_TAX_ACCOUNT_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.EXP_CERT_DATE_FROM        :=   P_EXP_CERT_DATE_FROM;
        P_TRL_GLOBAL_VARIABLES_REC.EXP_CERT_DATE_TO          :=   P_EXP_CERT_DATE_TO;
        P_TRL_GLOBAL_VARIABLES_REC.EXP_METHOD                :=   P_EXP_METHOD;
        P_TRL_GLOBAL_VARIABLES_REC.TRX_NUMBER_LOW            :=   P_TRX_NUMBER_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.TRX_NUMBER_HIGH           :=   P_TRX_NUMBER_HIGH;
        P_TRL_GLOBAL_VARIABLES_REC.PRINT_COMPANY_INFO        :=   P_PRINT_COMPANY_INFO;
        P_TRL_GLOBAL_VARIABLES_REC.ERRBUF                    :=   P_ERRBUF;
        P_TRL_GLOBAL_VARIABLES_REC.RETCODE                   :=  NVL(P_RETCODE,0);
        P_TRL_GLOBAL_VARIABLES_REC.ACCOUNTING_STATUS        := P_ACCOUNTING_STATUS;
        P_TRL_GLOBAL_VARIABLES_REC.REPORTED_STATUS        := P_REPORTED_STATUS;
        P_TRL_GLOBAL_VARIABLES_REC.TAXABLE_ACCOUNT_LOW       :=   P_TAXABLE_ACCOUNT_LOW;
        P_TRL_GLOBAL_VARIABLES_REC.TAXABLE_ACCOUNT_HIGH      :=   P_TAXABLE_ACCOUNT_HIGH;
      	P_TRL_GLOBAL_VARIABLES_REC.GL_OR_TRX_DATE_FILTER     := P_GL_OR_TRX_DATE_FILTER; --Bug 5396444
        --Bug 9031051
        P_TRL_GLOBAL_VARIABLES_REC.ESL_DEFAULT_TAX_DATE      := P_ESL_DEFAULT_TAX_DATE;
        P_TRL_GLOBAL_VARIABLES_REC.ESL_OUT_OF_PERIOD_ADJ     := P_ESL_OUT_OF_PERIOD_ADJ;
        P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_TRX_TYPE           := P_ESL_EU_TRX_TYPE;
        P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_GOODS              := P_ESL_EU_GOODS;
        P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_SERVICES           := P_ESL_EU_SERVICES;
        P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_ADDL_CODE1         := P_ESL_EU_ADDL_CODE1;
        P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_ADDL_CODE2         := P_ESL_EU_ADDL_CODE2;
        P_TRL_GLOBAL_VARIABLES_REC.ESL_EU_SITE_REPORTED      := P_ESL_SITE_CODE;


--  Populate the WHO columns :

	g_created_by   := nvl(fnd_profile.value('USER_ID'),1);
	g_creation_date := sysdate;
	g_last_updated_by := nvl(fnd_profile.value('USER_ID'),1);
        g_last_update_date := sysdate;
        g_last_update_login := 1;

-- Get the max length of P_ERRBUF, rounded down to 50 characters
-- Since it is not possible to know the max length of the variable
-- which was passed to the TRL as IN OUT parameter P_ERRBUF, we need to
-- do this workaround. Otherwise we get Value error if the size
-- of the variable is not sufficient to hold value in L_ERRBUF.
    l_length_errbuf := 0;
    BEGIN
      FOR i IN 1..40 LOOP
        p_errbuf := p_errbuf ||
                '                                            ';
        l_length_errbuf := l_length_errbuf + 50;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    l_length_errbuf := least(l_length_errbuf,2000);
    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE',
                                  'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE(-)');
    END IF;
    P_ERRBUF := NULL;


    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.INITIALIZE.END',
                                  'Length of errbuf : '||to_char(l_length_errbuf));
    END IF;

   EXCEPTION
      WHEN OTHERS THEN
           g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
           FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','initialize- '|| g_error_buffer);
           FND_MSG_PUB.Add;
           IF (g_level_unexpected >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_unexpected,
                       'ZX.TRL.ZX_EXTRACT_PKG.initialize',
                               'initialize Check : ');
               FND_LOG.STRING(g_level_unexpected,
                      'ZX.TRL.ZX_EXTRACT_PKG.initialize', g_error_buffer);
           END IF;
           APPEND_ERRBUF(g_error_buffer);
           P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;

END initialize;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   derive_dependent_parameters                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure derives the dependent parameters                        |
 |    for procedure  ZX_EXTRACT_PKG.POPULATE                                |
 |                                                                           |
 |    Called from ZX_EXTRACT_PKG.POPULATE                                   |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE derive_dependent_parameters (
          P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE)
IS
    l_operating_unit_id NUMBER;
    l_ledger_name  GL_LEDGERS.Name%TYPE;
    l_primary_ledger_id NUMBER(15);
    l_legal_entity_id   NUMBER;
    l_ledger_category gl_ledgers.ledger_category_code%TYPE;


    CURSOR le_ledger_cur (c_legal_entity_id NUMBER) IS
    SELECT ledger_id
    FROM gl_ledger_le_v
    WHERE legal_entity_id = c_legal_entity_id
      AND ledger_category_code = 'PRIMARY';

    CURSOR chart_of_acc_id (c_ledger_id number) IS
         SELECT  chart_of_accounts_id, name, currency_code
         FROM    gl_sets_of_books
         WHERE   set_of_books_id = c_ledger_id;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters.BEGIN',
                                  'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters(+)');
    END IF;



    IF p_trl_global_variables_rec.reporting_level = '1000' THEN
       g_ledger_id := p_trl_global_variables_rec.reporting_context;
       l_legal_entity_id := p_trl_global_variables_rec.legal_entity_id;
       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters 1000',
                                  'g_ledger_id : ' || to_char(g_ledger_id) ||
                                  'l_legal_entity_id : ' || to_char(l_legal_entity_id));
       END IF;
    ELSIF p_trl_global_variables_rec.reporting_level = '2000' THEN
       l_legal_entity_id := p_trl_global_variables_rec.reporting_context;
        p_trl_global_variables_rec.legal_entity_id :=  l_legal_entity_id;
       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters 2000',
                                  'l_legal_entity_id : ' || to_char(l_legal_entity_id));
       END IF;

    ELSIF p_trl_global_variables_rec.reporting_level = '3000' THEN
          l_operating_unit_id := p_trl_global_variables_rec.reporting_context;
          l_legal_entity_id := XLE_UTILITIES_GRP.GET_DefaultLegalContext_OU(l_operating_unit_id);
          p_trl_global_variables_rec.legal_entity_id := l_legal_entity_id;

         IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters 3000',
                                  'l_operating_unit_id : ' || to_char(l_operating_unit_id) ||
                                  'l_legal_entity_id : ' || to_char(l_legal_entity_id));
         END IF;

         IF p_trl_global_variables_rec.ledger_id IS NOT NULL THEN
            g_ledger_id := p_trl_global_variables_rec.ledger_id;
         ELSE
              mo_utils.get_ledger_info(l_operating_unit_id,
                                   g_ledger_id  ,
                                   l_ledger_name );
         END IF;
         IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters 3000.2',
                                  'l_operating_unit_id : ' || to_char(l_operating_unit_id) ||
                                  'g_ledger_id : ' || to_char(g_ledger_id) ||
                                  'l_ledger_name : ' || to_char(l_ledger_name));
         END IF;

     END IF;

   IF P_TRL_GLOBAL_VARIABLES_REC.POSTING_STATUS = 'POSTED' THEN
          p_trl_global_variables_rec.accounting_status := 'ACCOUNTED';
   END IF;


    IF p_trl_global_variables_rec.reporting_level = '2000' THEN
   --    IF p_trl_global_variables_rec.legal_entity_id is not NULL THEN
          OPEN le_ledger_cur (l_legal_entity_id);
          FETCH le_ledger_cur INTO g_ledger_id;
          CLOSE le_ledger_cur;
    --   END IF;
    END IF;

     --Get the Ledger Type for a given Ledger ID.
     --Get the primary ledger ID if the ledger type is reprting.

     -- Reporting Ledger ----- Secondary Leders --
    IF nvl(p_trl_global_variables_rec.ledger_id,g_ledger_id) IS NOT NULL THEN
       l_ledger_category := gl_mc_info.get_ledger_category(nvl(p_trl_global_variables_rec.ledger_id,
                                                                   g_ledger_id));
       IF l_ledger_category <> 'PRIMARY' THEN
          gl_mc_info.get_sob_type(nvl(p_trl_global_variables_rec.ledger_id,g_ledger_id),
                                      g_ledger_type);
          IF NVL(g_ledger_type,'R') IN ('R','N') THEN
             p_trl_global_variables_rec.reporting_ledger_id := nvl(p_trl_global_variables_rec.ledger_id,g_ledger_id);
             p_trl_global_variables_rec.accounting_status := 'ACCOUNTED';
             IF (g_level_procedure >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters',
                               'g_ledger_type and Reporting Ledger = '||g_ledger_type||'-'
                               ||to_char(p_trl_global_variables_rec.reporting_ledger_id));
             END IF;
          END IF;
       END IF;
    END IF;



    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters',
             'Accounting_status = '||p_trl_global_variables_rec.accounting_status);
    END IF;


    IF nvl(g_ledger_type,'R') IN ('R','N') THEN
   --    g_ledger_type := 'P';
   -- ELSE
    --   p_trl_global_variables_rec.reporting_ledger_id := g_ledger_id;
       l_primary_ledger_id := gl_mc_info.get_primary_ledger_id(g_ledger_id);
       g_ledger_id := l_primary_ledger_id;
      IF p_trl_global_variables_rec.reporting_level = '1000' THEN
         p_trl_global_variables_rec.reporting_context := g_ledger_id;
      END IF;
    END IF;

         p_trl_global_variables_rec.ledger_id := g_ledger_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters',
                               'g_ledger_type = '||g_ledger_type||'-'||to_char(g_ledger_id));
    END IF;


     OPEN chart_of_acc_id (p_trl_global_variables_rec.ledger_id);
      FETCH chart_of_acc_id
       INTO
            P_TRL_GLOBAL_VARIABLES_REC.chart_of_accounts_id,
            P_TRL_GLOBAL_VARIABLES_REC.ledger_name ,
            P_TRL_GLOBAL_VARIABLES_REC.func_currency_code;
       CLOSE chart_of_acc_id;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters',
            'Chart of Accounts ID =' ||to_char(P_TRL_GLOBAL_VARIABLES_REC.chart_of_accounts_id));
    END IF;

     --derive P_GL_DATE_LOW/HIGH from  P_GL_PERIOD_NAME_LOW/HIGH

    BEGIN
         IF  P_TRL_GLOBAL_VARIABLES_REC.GL_PERIOD_NAME_LOW IS NOT NULL AND
             P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_LOW IS NULL THEN

             SELECT start_date
               INTO p_trl_global_variables_rec.gl_date_low
               FROM gl_period_statuses
              WHERE upper(period_name) = upper(p_trl_global_variables_rec.gl_period_name_low)
                AND set_of_books_id =  g_ledger_id
                AND application_id =  101;

          END IF;

	  IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters',
            ' p_trl_global_variables_rec.gl_period_name_low =' ||to_char(p_trl_global_variables_rec.gl_date_low));
          END IF;


          IF P_TRL_GLOBAL_VARIABLES_REC.GL_PERIOD_NAME_HIGH IS NOT NULL
          AND P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH IS NULL THEN

             SELECT end_date
               INTO p_trl_global_variables_rec.gl_date_high
               FROM gl_period_statuses
              WHERE upper(period_name) = upper(p_trl_global_variables_rec.gl_period_name_high)
                AND set_of_books_id = g_ledger_id
                AND application_id =  101;

          END IF;

	  IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters',
            ' p_trl_global_variables_rec.gl_period_name_high =' ||to_char(p_trl_global_variables_rec.gl_date_high));
          END IF;

          EXCEPTION
              WHEN OTHERS THEN
                g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
                FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
                FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
                FND_MSG_PUB.Add;
                IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                                 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters',
                                  'Period Name Low and High parameter has error :');
                  FND_LOG.STRING(g_level_unexpected,
                                 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters',
                                  g_error_buffer);
                END IF;
                APPEND_ERRBUF(g_error_buffer);
                P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;


    END;


--        derive P_TRX_DATE_LOW/HIGH from  P_TRX_DATE_PERIOD_NAME_LOW / HIGH

    BEGIN
          IF P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_PERIOD_NAME_LOW IS NOT NULL
          AND P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_LOW IS NULL THEN

             SELECT start_date
               INTO p_trl_global_variables_rec.trx_date_low
               FROM gl_period_statuses
              WHERE period_name = p_trl_global_variables_rec.trx_date_period_name_low
                AND set_of_books_id =  g_ledger_id
                AND application_id =  101;

          END IF;

          IF P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_PERIOD_NAME_HIGH IS NOT NULL
          AND P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_HIGH IS NULL THEN

             SELECT end_date
               INTO p_trl_global_variables_rec.trx_date_high
               FROM gl_period_statuses
              WHERE period_name = p_trl_global_variables_rec.trx_date_period_name_high
                AND set_of_books_id =  g_ledger_id
                AND application_id =  101;

          END IF;

          EXCEPTION
              WHEN OTHERS THEN
                g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
                FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
                FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
                FND_MSG_PUB.Add;
                IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                                 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters',
                                  'Transaction Date Low and High parameter has error :');
                  FND_LOG.STRING(g_level_unexpected,
                                 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters',
                                  g_error_buffer);
                END IF;
           APPEND_ERRBUF(g_error_buffer);
                P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;
    END;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters.END',
                                  'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters(-)');
    END IF;

          EXCEPTION
              WHEN OTHERS THEN
                g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
                FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
                FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','derive_dependent_parameters- '|| g_error_buffer);
                FND_MSG_PUB.Add;
                IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                                 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters',
                                  'Multi Org Utility :  mo_utils.get_ledger_info :');
                  FND_LOG.STRING(g_level_unexpected,
                                 'ZX.TRL.ZX_EXTRACT_PKG.derive_dependent_parameters',
                                  g_error_buffer);
                END IF;
           APPEND_ERRBUF(g_error_buffer);
              P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;
END derive_dependent_parameters;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   VALIDATE_PARAMETERS                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure validates the parameters supplied by the user  in the   |
 |    ZX_EXTRACT_PKG.POPULATE and gives error message if he parameter        |
 |    values passed are invalid.                                             |
 |                                                                           |
 |    Called from ZX_EXTRACT_PKG.POPULATE                                    |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   08-Feb-2005  Srinivasa Rao Korrapati   Created                          |
 |                                                                           |
 +===========================================================================*/

FUNCTION VALIDATE_PARAMETERS (
         P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE)
RETURN BOOLEAN IS

   C_ORDER_BY   VARCHAR2(30);
   l_count      NUMBER;

BEGIN
--       Validation of Parameters:

        SELECT count(*) INTO l_count
          FROM zx_rep_context_t
         WHERE  request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;

        IF l_count > 0 THEN
                IF (g_level_unexpected >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_unexpected,
                                 'ZX.TRL.ZX_EXTRACT_PKG.validate_parameters',
                                  'Duplicate request ID :');
                  FND_LOG.STRING(g_level_unexpected,
                                 'ZX.TRL.ZX_EXTRACT_PKG.validate_parameters',
                                  g_error_buffer);
                END IF;

        END IF;


 RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
         g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
         FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','derive_dependent_parameters- '|| g_error_buffer);
         FND_MSG_PUB.Add;
         IF (g_level_unexpected >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_unexpected,
                                 'ZX.TRL.ZX_EXTRACT_PKG.validate_parameters',
                                  'Request ID Duplicate check :');
             FND_LOG.STRING(g_level_unexpected,
                                 'ZX.TRL.ZX_EXTRACT_PKG.validate_parameters',
                                  g_error_buffer);
         END IF;
           APPEND_ERRBUF(g_error_buffer);
         P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;

END VALIDATE_PARAMETERS;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   extract_rep_context_info                                                |
 |                                                                           |
 | description                                                               |
 |    this PROCEDURE gets the reporting context for the header record        |
 |    called FROM the constructor of zx_extract_pkg                          |
 |                                                                           |
 | scope - private                                                           |
 |                                                                           |
 | notes                                                                     |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE extract_rep_context_info (
           p_trl_global_variables_rec IN OUT NOCOPY ZX_EXTRACT_PKG.trl_global_variables_rec_type)
IS
    l_operating_unit_id                NUMBER;
    l_reporting_context_org_id	       NUMBER(15);
    l_reporting_context_tax_reg_no     VARCHAR2(60);
    l_reporting_context_name	       VARCHAR2(100);
    l_reporting_sob_name	       VARCHAR2(100);
    l_functional_currency_code	       VARCHAR2(15);
    l_ledger_id                        NUMBER;
    l_legal_entity_id                  NUMBER;

/* apai
      CURSOR ledger_ou_cursor (c_ledger_id NUMBER ) IS
      SELECT organization_id
        FROM hr_operating_units
       WHERE mo_global.check_access(organization_id) = 'Y'
         AND SET_OF_BOOKS_ID = c_ledger_id ;
*/
BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_rep_context_info.BEGIN',
                                  'ZX.TRL.ZX_EXTRACT_PKG.extract_rep_context_info(+)');
    END IF;

  --  get the structure of address location dff

      fnd_dflex.get_flexfield(
               'PER',
               'Address Location',
                pr_flexfield,
                pr_flexinfo);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_rep_context_info.BEGIN',
                                  'pr_flexfield :');
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_rep_context_info',
                                  'p_trl_global_variables_rec.legal_entity_id : p_trl_global_variables_rec.legal_entity_id');

       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_rep_context_info',
                                  'Before call to insert_rep_context_itf');

    END IF;

    --IF p_trl_global_variables_rec.legal_entity_id IS NOT NULL THEN
       insert_rep_context_itf(
                 p_trl_global_variables_rec,
                 p_trl_global_variables_rec.legal_entity_id);
    --END IF;

/* apai
    ELSIF p_trl_global_variables_rec.reporting_level = '1000' THEN

          IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_rep_context_info.BEGIN',
                                  'ZX.TRL.ZX_EXTRACT_PKG.extract_rep_context_info : Call to insert_rep_context_itf');
          END IF;

      BEGIN
     --     IF g_ledger_type = 'R' THEN
      --       l_ledger_id := gl_mc_info.get_primary_ledger_id(g_ledger_id);
       --   ELSE
        --     l_ledger_id :=  p_trl_global_variables_rec.reporting_context;
         -- END IF;

        -- Above coditions are taken care in the derive dependent parameters API.
        -- This API always populates primary ledger ID in g_ledger_id which is a
        -- global variable.
       OPEN ledger_ou_cursor(g_ledger_id );
       BEGIN
         LOOP
           FETCH ledger_ou_cursor INTO l_operating_unit_id;

           IF ledger_ou_cursor%NOTFOUND THEN
              g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
--    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
 --   FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
  --  FND_MSG_PUB.Add;
           IF (g_level_unexpected >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_EXTRACT_PKG.extract_rep_context_info',
                      g_error_buffer);
           END IF;

              P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;
           END IF;
           EXIT when ledger_ou_cursor%NOTFOUND ;
              insert_rep_context_itf(p_trl_global_variables_rec,l_operating_unit_id);
        END LOOP;
        END;

        IF (ledger_ou_cursor%ISOPEN) THEN
            CLOSE ledger_ou_cursor;
        END IF;
       END;

    ELSIF p_trl_global_variables_rec.reporting_level = '3000' THEN
          l_operating_unit_id := p_trl_global_variables_rec.reporting_context;
          insert_rep_context_itf(
                   p_trl_global_variables_rec,
                   l_operating_unit_id);
    END IF;  -- reporting level
*/
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_rep_context_info.END',
                                  'ZX.TRL.ZX_EXTRACT_PKG.extract_rep_context_info(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_EXTRACT_PKG.extract_rep_context_info',
                      g_error_buffer);
    END IF;
           APPEND_ERRBUF(g_error_buffer);
   P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;


END extract_rep_context_info ;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   extract_tax_info                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Called from ZX_EXTRACT_PKG.populate_tax_data                           |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |        08-Feb-2005     Srinivasa Rao Korrapati  Created                   |
 +===========================================================================*/

PROCEDURE EXTRACT_TAX_INFO(
          p_ledger_type              IN            VARCHAR2,
          P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE)
IS

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.EXTRACT_TAX_INFO.BEGIN',
                                      'ZX_EXTRACT_PKG:EXTRACT_TAX_INFO(+)');
    END IF;
 -- Need to remove this code since the accounting and non accounting apis are merged
/*
    IF P_TRL_GLOBAL_VARIABLES_REC.EXTRACT_ACCTED_TAX_LINES = 'Y'  OR
       P_ledger_type = 'R' THEN

    IF P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'AR' OR
       P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'ALL' THEN

       ZX_AR_ACTG_EXTRACT_PKG.insert_tax_data (
                      P_MRC_SOB_TYPE             => P_ledger_type,
                      P_TRL_GLOBAL_VARIABLES_REC => P_TRL_GLOBAL_VARIABLES_REC
                      );

       l_ar_retcode := P_TRL_GLOBAL_VARIABLES_REC.RETCODE;

       ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines(
                      P_TRL_GLOBAL_VARIABLES_REC);
       ZX_JL_EXTRACT_PKG.FILTER_JL_AR_TAX_LINES(P_TRL_GLOBAL_VARIABLES_REC);
    END IF;

    IF P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'AP'  OR
       P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'ALL' THEN

       ZX_AP_ACTG_EXTRACT_PKG.insert_tax_data (
                      P_TRL_GLOBAL_VARIABLES_REC => P_TRL_GLOBAL_VARIABLES_REC
                      );
       l_ap_retcode := P_TRL_GLOBAL_VARIABLES_REC.RETCODE;
       ZX_JA_EXTRACT_PKG.filter_ja_ap_tax_lines(
                      P_TRL_GLOBAL_VARIABLES_REC);
    END IF;


    IF P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'GL' OR
       P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'ALL' THEN

       ZX_GL_EXTRACT_PKG.insert_tax_data(
                      P_TRL_GLOBAL_VARIABLES_REC => P_TRL_GLOBAL_VARIABLES_REC
                      );
       l_gl_retcode := P_TRL_GLOBAL_VARIABLES_REC.RETCODE;
    END IF;

   ELSE
*/ -- Need to remove this code since the accounting and non accounting apis are merged
    IF P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'AR' OR
       P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'ALL' THEN

       ZX_AR_EXTRACT_PKG.insert_tax_data (
                      P_MRC_SOB_TYPE             => P_ledger_type,
                      P_TRL_GLOBAL_VARIABLES_REC => P_TRL_GLOBAL_VARIABLES_REC
                      );
       l_ar_retcode := P_TRL_GLOBAL_VARIABLES_REC.RETCODE;
       IF l_ar_retcode <> 2 THEN
          ZX_JA_EXTRACT_PKG.filter_ja_ar_tax_lines(
                            P_TRL_GLOBAL_VARIABLES_REC);
       ZX_JL_EXTRACT_PKG.FILTER_JL_AR_TAX_LINES(P_TRL_GLOBAL_VARIABLES_REC);
       END IF;
    END IF;

    IF P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'AP'  OR
       P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'ALL' THEN

       ZX_AP_EXTRACT_PKG.insert_tax_data (
                      P_TRL_GLOBAL_VARIABLES_REC => P_TRL_GLOBAL_VARIABLES_REC
                      );
       l_ap_retcode := P_TRL_GLOBAL_VARIABLES_REC.RETCODE;
       IF l_ap_retcode <> 2 THEN
          ZX_JA_EXTRACT_PKG.filter_ja_ap_tax_lines(
                      P_TRL_GLOBAL_VARIABLES_REC);
       END IF;
    END IF;


    IF P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'GL' OR
       P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'ALL' THEN

       ZX_GL_EXTRACT_PKG.insert_tax_data(
                      P_TRL_GLOBAL_VARIABLES_REC => P_TRL_GLOBAL_VARIABLES_REC
                      );
       l_gl_retcode := P_TRL_GLOBAL_VARIABLES_REC.RETCODE;
    END IF;
--   END IF;



    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_tax_info.END',
                                      'ZX_EXTRACT_PKG:extract_tax_info(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_EXTRACT_PKG.extract_tax_info',
                      g_error_buffer);
    END IF;
           APPEND_ERRBUF(g_error_buffer);
   P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;

END EXTRACT_TAX_INFO;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   extract_additional_info                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure populates Additional information in                     |
 |    zx_rep_context_t                                                       |
 |                                                                           |
 |    Called from ZX_EXTRACT_PKG.POPULATE                                    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-Feb-2005   Srinivasa Rao Korrapati   Created                       |
 +===========================================================================*/

PROCEDURE extract_additional_info(
          p_ledger_type              IN            VARCHAR2,
          P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE)
IS


    /*CURSOR rep_context_cursor(
                    c_request_id      IN NUMBER,
                    c_set_of_books_id IN NUMBER)
    IS
        SELECT rep_context.rep_context_id , rep_context.rep_entity_id ,
               mo.operating_unit_id
          FROM zx_rep_context_t rep_context,
               fnd_mo_reporting_entities_v mo
         WHERE rep_context.rep_entity_id = mo.operating_unit_id
           AND mo.ledger_id = c_set_of_books_id
           AND rep_context.request_id = c_request_id
           AND mo.reporting_level =  '3000';
--P_TRL_GLOBAL_VARIABLES_REC.REPORTING_LEVEL;
-- '3000' ; */

   CURSOR rep_context_cursor(
                    c_request_id      IN NUMBER) IS
    SELECT rep_context.rep_context_id,
           rep_context.rep_entity_id ,
           rep_context.rep_entity_id
      FROM zx_rep_context_t rep_context
     WHERE rep_context.request_id = c_request_id;


    l_rep_context_id_rec  zx_extract_pkg.rep_context_id_rectype;
    i                             BINARY_INTEGER;
    l_org_id                      NUMBER;
    l_ledger_id                   NUMBER;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_additional_info.BEGIN',
                                      'ZX_EXTRACT_PKG:extract_additional_info(+)');
    END IF;

    BEGIN
--        IF p_ledger_type = 'R' THEN
 --          l_ledger_id := gl_mc_info.get_primary_ledger_id(
  --                                       g_ledger_id
   --                                      );
    --       open rep_context_cursor(
     --                P_TRL_GLOBAL_VARIABLES_REC.request_id,
      --               l_ledger_id
       --              );
      --  ELSE
         --  open rep_context_cursor(
          --           P_TRL_GLOBAL_VARIABLES_REC.request_id,
           --          g_ledger_id
            --         );
           open rep_context_cursor(
                     P_TRL_GLOBAL_VARIABLES_REC.request_id
                     );
       -- END IF;

        i := 1;
        rep_context_id_tab.delete;
        LOOP
           FETCH rep_context_cursor  INTO l_rep_context_id_rec;
           EXIT WHEN rep_context_cursor%NOTFOUND;
           rep_context_id_tab(i) := l_rep_context_id_rec;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_additional_info',
                                      'rep_context_id_tab(i)'||to_char(rep_context_id_tab(i).rep_context_id));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_additional_info',
                                      'l_rep_context_id_rec :'||to_char(l_rep_context_id_rec.rep_context_id));
    END IF;
           i := i + 1;

        END LOOP;

        IF  rep_context_cursor%isopen THEN
            CLOSE rep_context_cursor;
        END IF;

      EXCEPTION
         WHEN OTHERS THEN
           g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
           FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','extract_additional_info- '|| g_error_buffer);
           FND_MSG_PUB.Add;
           IF (g_level_unexpected >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_unexpected,
                            'ZX.TRL.ZX_EXTRACT_PKG.extract_additional_info',
                             g_error_buffer);
           END IF;

     END;

 -- Call to AR, AP Populate API calls to populate additional information



     IF P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'AR' OR
        P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'ALL'
     THEN
        IF L_AR_RETCODE <> 2 THEN
           ZX_AR_POPULATE_PKG.update_additional_info(
                              P_TRL_GLOBAL_VARIABLES_REC);
        END IF;
         L_AR_RETCODE := P_TRL_GLOBAL_VARIABLES_REC.RETCODE;
     END IF;

     IF  (P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'AP' OR
          P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'ALL') AND
          P_TRL_GLOBAL_VARIABLES_REC.REGISTER_TYPE IN ('TAX','NON-RECOVERABLE','ALL')
     THEN
 --       IF L_AP_RETCODE <> 2 THEN
          ZX_AP_POPULATE_PKG.UPDATE_ADDITIONAL_INFO(
                              P_TRL_GLOBAL_VARIABLES_REC );
  --      END IF;
         L_AP_RETCODE := P_TRL_GLOBAL_VARIABLES_REC.RETCODE;
     END IF;

     IF  (P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'GL' OR
          P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'ALL')
     THEN
 --       IF L_AP_RETCODE <> 2 THEN
             ZX_GL_EXTRACT_PKG.UPDATE_ADDITIONAL_INFO(
                              P_TRL_GLOBAL_VARIABLES_REC );
  --      END IF;
         L_AP_RETCODE := P_TRL_GLOBAL_VARIABLES_REC.RETCODE;
     END IF;

 --   Call to JX populate Plug-in APIs
   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_additional_info',
                                      'AR JX product Call: Return Code : '||to_char(L_AR_RETCODE));
    END IF;

--          ZX_JL_EXTRACT_PKG.populate_jl_ar(P_TRL_GLOBAL_VARIABLES_REC);
     IF P_TRL_GLOBAL_VARIABLES_REC.PRODUCT IN ( 'AR', 'GL') OR
        P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'ALL'
     THEN
     IF L_AR_RETCODE <> 2 THEN
        IF  SUBSTR(P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME,3,2) IN ('SG','TW','ZX')
        THEN
            ZX_JA_EXTRACT_PKG.populate_ja_ar(P_TRL_GLOBAL_VARIABLES_REC);
        ELSIF P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'JGVAT'
        THEN
      	    ZX_JE_EXTRACT_PKG.populate_je_ar(P_TRL_GLOBAL_VARIABLES_REC);
        ELSIF SUBSTR(P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME,3,2) IN ('AR','CL','CO','ZZ')
        THEN
            ZX_JL_EXTRACT_PKG.populate_jl_ar(P_TRL_GLOBAL_VARIABLES_REC);
        ELSIF SUBSTR(P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME,1,3) = 'ZXX'
        THEN
            ZX_CORE_REP_EXTRACT_PKG.populate_core_ar(P_TRL_GLOBAL_VARIABLES_REC);
        END IF;
      END IF;
    END IF;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_additional_info',
                                      'AP JX product Call: Return Code : '||to_char(L_AP_RETCODE));
    END IF;
     IF P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'AP' OR
        P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'ALL'
     THEN
 IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_additional_info',
                                      'AP JL product Call: Return Code : '||P_TRL_GLOBAL_VARIABLES_REC.PRODUCT);
    END IF;

        IF L_AP_RETCODE <> 2 THEN
   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_additional_info',
                                      'AP JL product Call: Return Code : '||to_char(L_AP_RETCODE));
    END IF;

           IF  SUBSTR(P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME,3,2) IN ('SG','TW','ZX')
           THEN
               ZX_JA_EXTRACT_PKG.populate_ja_ap(P_TRL_GLOBAL_VARIABLES_REC);
               --ZX_JA_EXTRACT_PKG.populate_ja_ar(P_TRL_GLOBAL_VARIABLES_REC);
           ELSIF P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'JGVAT'
           THEN

      	      ZX_JE_EXTRACT_PKG.populate_je_ap(P_TRL_GLOBAL_VARIABLES_REC);

              -- This is to update recovery rate and IPV amounts --

              ZX_CORE_REP_EXTRACT_PKG.populate_core_ap(P_TRL_GLOBAL_VARIABLES_REC);

           ELSIF SUBSTR(P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME,3,2) IN ('AR','CL','CO')
            THEN
   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.extract_additional_info',
                                      'AP JL product Call: Return Code : '||'populate_jl_ap');
    END IF;

              ZX_JL_EXTRACT_PKG.populate_jl_ap(P_TRL_GLOBAL_VARIABLES_REC);
           ELSIF SUBSTR(P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME,1,3) = 'ZXX'
            THEN
              ZX_CORE_REP_EXTRACT_PKG.populate_core_ap(P_TRL_GLOBAL_VARIABLES_REC);
           END IF;
        END IF;
      END IF;

     IF P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'GL' OR
        P_TRL_GLOBAL_VARIABLES_REC.PRODUCT = 'ALL'
     THEN
        IF L_GL_RETCODE <> 2 THEN
          IF P_TRL_GLOBAL_VARIABLES_REC.REPORT_NAME = 'JGVAT'
	             THEN
      	      ZX_JE_EXTRACT_PKG.populate_je_gl(P_TRL_GLOBAL_VARIABLES_REC);
          END IF;
        END IF;
     END IF;

        ZX_JG_EXTRACT_PKG.get_taxable(P_TRL_GLOBAL_VARIABLES_REC);


EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_EXTRACT_PKG.extract_additional_info',
                      g_error_buffer);
    END IF;
           APPEND_ERRBUF(g_error_buffer);
       P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;

END extract_additional_info;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   CLEANUP                                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the records from AR_TAX_EXTRACT_DCL_IF          |
 |    which do not have any child records in AR_TAX_EXTRACT_SUB_ITF          |
 |    for the given request_id                                               |
 |                                                                           |
 |    Called from ZX_EXTRACT_PKG.POPULATE                                    |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/

 PROCEDURE CLEANUP (
   P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
   ) IS

    j                         number := 0;
    l_declarer_id             number;
    l_count                   number;
BEGIN
/*
-- Performance bug#3264164
    type extract_line_id_t is table of
                              ar_tax_extract_sub_itf.extract_line_id%type
                              index by binary_integer;
    type trx_id_t is table of
                              ar_tax_extract_sub_itf.trx_id%type
                              index by binary_integer;
    type trx_class_code_t is table of
                              ar_tax_extract_sub_itf.trx_class_code%type
                              index by binary_integer;
    type tax_code_id_t is table of
                              ar_tax_extract_sub_itf.tax_code_id%type
                              index by binary_integer;
    type tax_code_register_type_code_t is table of
                              ar_tax_extract_sub_itf.tax_code_register_type_code%type
                              index by binary_integer;
    type extract_source_ledger_t is table of
                              ar_tax_extract_sub_itf.extract_source_ledger%type
                              index by binary_integer;
    type extract_report_line_number_t is table of
                              ar_tax_extract_sub_itf.extract_report_line_number%type
                              index by binary_integer;

    l_extract_line_id         extract_line_id_t;
    l_trx_id                  trx_id_t;
    l_trx_class_code          trx_class_code_t;
    l_tax_code_id             tax_code_id_t;
    l_tax_cd_register_type_cd tax_code_register_type_code_t;
    l_extract_source_ledger   extract_source_ledger_t;
    l_extract_report_line_num extract_report_line_number_t;

 BEGIN
    l_count := 0;

   BEGIN
   DELETE FROM AR_TAX_EXTRACT_SUB_ITF WHERE EXTRACT_LINE_ID IN
   (select extract_line_id
        from   ar_tax_extract_sub_itf
        where  request_id = P_TRL_GLOBAL_VARIABLES_REC.request_id
        and    (trx_id is null
             or trx_class_code is null
       --    or tax_code_id is null
             or tax_code_register_type_code is null
             or extract_source_ledger is null
             or extract_report_line_number is null))
        RETURNING
             extract_line_id,
             trx_id,
             trx_class_code,
             tax_code_id,
             tax_code_register_type_code,
             extract_source_ledger,
             extract_report_line_number
        BULK COLLECT INTO
             l_extract_line_id,
             l_trx_id,
             l_trx_class_code,
             l_tax_code_id,
             l_tax_cd_register_type_cd,
             l_extract_source_ledger,
             l_extract_report_line_num;

--      All the mandatory columns for the selected declarer_id

        IF PG_DEBUG = 'Y' THEN
           FOR j IN 1..l_extract_line_id.COUNT LOOP
              arp_util_tax.debug('Mandatory columns missing for Extract Line Id : '||
                          to_char(l_extract_line_id(j))||
                          '. Deleting this line from AR_TAX_EXTRACT_SUB_ITF.');
              arp_util_tax.debug('trx_id : ' || to_char(l_trx_id(j)) ||
                                 '   trx_class_code : ' ||  l_trx_class_code(j) ||
                                 '   tax_code_id : ' || to_char(l_tax_code_id(j)));
              arp_util_tax.debug('ax_code_register_type_code : ' ||
                                  l_tax_cd_register_type_cd(j) ||
                                 '   extract_source_ledger : ' || l_extract_source_ledger(j) ||
                                 '   extract_report_line_number : ' ||
                                     to_char(l_extract_report_line_num(j)));
           END LOOP;

           l_count := l_extract_line_id.COUNT;
           arp_util_tax.debug(to_char(nvl(l_count,0))||' records deleted because '
                      ||'mandatory columns are not populated . ');
           arp_util_tax.debug(' ');

        END IF;

    EXCEPTION
       WHEN OTHERS THEN
           STACK_ERROR('FND','SQL_PLSQL_ERROR','ERRNO',SQLCODE,'REASON',SQLERRM,
                     'ROUTINE','ZX_EXTRACT_PKG.CLEANUP');
           L_MSG := FND_MESSAGE.GET;

   END;

    declarer_id_lookup_table.delete;
    l_count := 0;

-- Performance bug#3264164
    DELETE FROM AR_TAX_EXTRACT_SUB_ITF
    WHERE TAX_EXTRACT_DECLARER_ID IS NULL
          AND REQUEST_ID = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;

    l_count := sql%rowcount; -- apai

  DELETE FROM zx_rep_trx_detail_t i
   WHERE request_id = P_TRL_GLOBAL_VARIABLES_REC.request_id
     AND rep_context_id is null;
*/
NULL;

 END CLEANUP;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |   DELETE_ALL                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the records from AR_TAX_EXTRACT_DCL_IF          |
 |    and  AR_TAX_EXTRACT_SUB_ITF for a given request_id. This procedure     |
 |    is called from the procedure populate if some fatal error condition    |
 |    occurs and error_code is set to 2                                      |
 |                                                                           |
 |    Called from ZX_EXTRACT_PKG.POPULATE                                   |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE DELETE_ALL(P_REQUEST_ID IN NUMBER ) IS
BEGIN
/*   IF PG_DEBUG = 'Y' THEN
   	arp_util_tax.debug('DELETE_ALL(+) ');
   END IF;
   delete from ar_tax_extract_sub_itf sub_itf
   where
      sub_itf.request_id = P_REQUEST_ID
   and  exists
   (select dcl_itf.tax_extract_declarer_id
    from   ar_tax_extract_dcl_itf dcl_itf
    where sub_itf.tax_extract_declarer_id=dcl_itf.tax_extract_declarer_id);
   commit;

-- check with Srinivas
   delete from ar_tax_extract_dcl_itf where request_id = P_REQUEST_ID;
   commit; */

   NULL;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   insert_rep_context_itf                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This PROCEDURE inserts Reporting Context information INTO              |
 |                         zx_rep_context_t                                  |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-Feb-2005   Srinivasa Rao Korrapati   Created                       |
 +===========================================================================*/

PROCEDURE insert_rep_context_itf(
          p_trl_global_variables_rec IN OUT NOCOPY zx_extract_pkg.trl_global_variables_rec_type,
          p_rep_entity_id  	     IN      NUMBER)
IS

    l_style                        HR_LOCATIONS_ALL.style%TYPE;
    l_extract_summary_code         VARCHAR2(80);
    l_rep_context_id               NUMBER;
    l_rep_context_org_id           NUMBER;
    l_request_id                   NUMBER;
    l_rep_entity_id                NUMBER;
    l_rep_context_tax_reg_no       HR_ORGANIZATION_INFORMATION.org_information2%TYPE;
    l_rep_context_loc_id           HR_LOCATIONS_ALL.location_id%TYPE;
    l_rep_context_name             HR_ORGANIZATION_UNITS.name%TYPE;
    l_rep_context_city             HR_LOCATIONS_ALL.town_or_city%TYPE;
    l_rep_context_county           HR_LOCATIONS_ALL.region_3%TYPE;
    l_rep_context_state            HR_LOCATIONS_ALL.region_2%TYPE;
    l_rep_context_province         HR_LOCATIONS_ALL.region_1%TYPE;
    l_rep_context_address1         HR_LOCATIONS_ALL.address_line_1%TYPE;
    l_rep_context_address2         HR_LOCATIONS_ALL.address_line_2%TYPE;
    l_rep_context_address3         HR_LOCATIONS_ALL.address_line_3%TYPE;
    l_rep_context_country          HR_LOCATIONS_ALL.country%TYPE;
    l_rep_context_postal_code      HR_LOCATIONS_ALL.postal_code%TYPE;
    l_rep_context_phone_number     HR_LOCATIONS_ALL.telephone_number_1%TYPE;
    l_rep_context_lvl_mng          VARCHAR2(80);
    l_rep_context_lvl_code         VARCHAR2(30);
    l_matrix_report_flag           VARCHAR2(30);
    l_rep_context_entity_region1   VARCHAR2(30);
    l_legal_contact_pre_name_adj   VARCHAR2(30);
    l_legal_contact_party_name     xle_legal_contacts_v.contact_name%TYPE;
    l_bank_id                      NUMBER;
    l_bank_branch_id               NUMBER;
    l_bank_account_num             NUMBER;
    l_taxpayer_id                  xle_firstparty_information_v.REGISTRATION_NUMBER%TYPE;
    l_legal_contact_title          xle_legal_contacts_v.title%TYPE;
    --l_legal_contact_job_title      xle_legal_contacts_v.job_title%TYPE;
    l_legal_contact_job_title      varchar2(13);--xle_legal_contacts_v.role%TYPE;
    l_activity_code                xle_firstparty_information_v.activity_code%TYPE;
    l_sub_activity_code            xle_firstparty_information_v.activity_code%TYPE;
    l_inception_date               DATE;
    l_legal_contact_party_num      xle_legal_contacts_v.contact_legal_id%TYPE;
    l_legal_auth_address_line2     xle_legalauth_v.address2%TYPE;
    l_legal_auth_address_line3     xle_legalauth_v.address3%TYPE;
    l_legal_auth_city              xle_legalauth_v.city%TYPE;
    l_legal_auth_name           xle_legalauth_v.authority_name%TYPE;
    l_org_information2             VARCHAR2(150);
    l_program_application_id       NUMBER;
    l_program_id                   NUMBER;
    l_program_login_id             NUMBER;
    l_rowcount                     NUMBER;
    l_hq_party_id		   NUMBER ;
    x_return_status		   varchar2(200);

/* apai
      CURSOR  c_loc_rec (c_rep_entity_id NUMBER) IS
       SELECT loc.country,
              loc.town_or_city,
              loc.region_1,
              loc.region_2,
              loc.region_3,
              loc.address_line_1,
              loc.address_line_2,
              loc.address_line_3,
              loc.postal_code,
              loc.telephone_number_1,
              loc.style,
              loc.location_id
        FROM  hr_locations loc,
              hr_organization_units org
        WHERE org.location_id = loc.location_id
          AND org.organization_id = c_rep_entity_id;
*/
         CURSOR c_legal_info (c_rep_entity_id number) IS
              SELECT
	           xle_firstpty.name ,
	           xle_firstpty.activity_code,
	           xle_firstpty.sub_activity_code,
	           xle_firstpty.registration_number,
	        --   xle_firstpty.effective_from
	           xle_firstpty.location_id,
	           xle_firstpty.address_line_1,
	           xle_firstpty.address_line_2,
	           xle_firstpty.address_line_3,
	           xle_firstpty.town_or_city,
	           xle_firstpty.region_1,
	           xle_firstpty.region_2,
	           xle_firstpty.region_3,
	           xle_firstpty.postal_code,
	         --  xle_firstpty.phone_number,
	           xle_firstpty.country,
                   xle_firstpty.address_style
	        --   xle_cont.contact_name,
	        --   xle_cont.contact_legal_id,
	         --  xle_cont.title,
	       --    xle_cont.job_title
	       --    xle_cont.role
	      FROM xle_firstparty_information_v xle_firstpty
	        --        xle_legal_contacts_v xle_cont
	      WHERE xle_firstpty.legal_entity_id = c_rep_entity_id;
               --  xle_firstpty.legal_entity_id = xle_cont.entity_id(+)

        CURSOR c_legal_auth_info (c_rep_entity_id number) IS
             SELECT xle_auth.address2,
                    xle_auth.address3,
                    xle_auth.city,
                    xle_auth.authority_name
               FROM xle_legalauth_v xle_auth,
                    xle_registrations xle_reg
              WHERE xle_reg.source_id = c_rep_entity_id
                AND xle_reg.source_table = 'XLE_ENTITY_PROFILES'
                AND xle_auth.legalauth_id = xle_reg.issuing_authority_id
                AND xle_reg.identifying_flag = 'Y';

       CURSOR c_legal_contact_info (c_rep_entity_id number) IS
       SELECT per.party_name,    -- contact_name,
              per.jgzz_fiscal_code, --contact_legal_id,
            --  rol.lookup_code,       --job Title
             XLE_CONTACT_GRP.concat_contact_roles
                          (rel.subject_id,
                           rel.object_id),
              hzpp.person_pre_name_adjunct  -- title
         FROM HZ_PARTIES per,
              xle_entity_profiles xep,
              HZ_RELATIONSHIPS rel,
              hz_person_profiles hzpp,
              HZ_ORG_CONTACTS  con
              --XLE_CONTACT_LEGAL_ROLES rol
        WHERE rel.relationship_code = 'CONTACT_OF'
          AND rel.object_id     = xep.party_id
          AND per.party_id    = hzpp.party_id
          AND rel.relationship_type = 'CONTACT'
          AND rel.directional_flag  = 'F'
          AND rel.subject_table_name = 'HZ_PARTIES'
          AND rel.subject_type       = 'PERSON'
          AND rel.subject_id         = per.party_id
         -- AND rel.subject_id         = rol.contact_party_id
         -- AND rel.object_id             = rol.le_etb_party_id
          AND rel.object_table_name  = 'HZ_PARTIES'
          AND Trunc(Nvl(rel.end_date, SYSDATE)) > TRUNC(SYSDATE)
          AND rel.relationship_id  = con.party_relationship_id
          AND xep.legal_entity_id = c_rep_entity_id
       UNION
       SELECT per.party_name,                  --contact_name,
              per.jgzz_fiscal_code,           --contact_legal_id,
             -- rol.lookup_code,                --job Title
             XLE_CONTACT_GRP.concat_contact_roles
                          (rel.subject_id,
                           rel.object_id),
              hzpp.person_pre_name_adjunct    --title,
         FROM HZ_PARTIES per,
              xle_etb_profiles etb,
              HZ_RELATIONSHIPS rel,
              hz_person_profiles hzpp,
              HZ_ORG_CONTACTS  con
          --    XLE_CONTACT_LEGAL_ROLES rol
        WHERE rel.relationship_code = 'CONTACT_OF'
          AND rel.object_id     = etb.party_id
          AND per.party_id    = hzpp.party_id
          AND rel.relationship_type = 'CONTACT'
          AND rel.directional_flag  = 'F'
          AND rel.subject_table_name = 'HZ_PARTIES'
          AND rel.subject_type       = 'PERSON'
          AND rel.subject_id         = per.party_id
          --AND  rel.subject_id         = rol.contact_party_id
          --AND  rel.object_id             = rol.le_etb_party_id
          AND rel.object_table_name  = 'HZ_PARTIES'
          AND Trunc(Nvl(rel.end_date, SYSDATE)) > TRUNC(SYSDATE)
          AND rel.relationship_id  = con.party_relationship_id
          AND etb.establishment_id = c_rep_entity_id ;


BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf.BEGIN',
                                  'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf(+)');
    END IF;

    IF p_trl_global_variables_rec.summary_level = 'TRANSACTION_DISTRIBUTION' THEN
       l_extract_summary_code := 'D';
    ELSIF p_trl_global_variables_rec.summary_level = 'TRANSACTION_LINE' THEN
       l_extract_summary_code  := 'L';
    ELSE
       l_extract_summary_code := 'H';
    END IF;


    IF p_trl_global_variables_rec.reporting_level = '1000' THEN
       l_rep_context_lvl_mng := 'Ledger';
    ELSIF p_trl_global_variables_rec.reporting_level = '2000' THEN
       l_rep_context_lvl_mng := 'Legal Entity';
    ELSIF p_trl_global_variables_rec.reporting_level = '3000' THEN
       l_rep_context_lvl_mng := 'Operating Unit';
    END IF;

--Bug 5438409
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_rep_context_lvl_mng : '||l_rep_context_lvl_mng);
    END IF;

/* apai
    IF p_trl_global_variables_rec.legal_entity_level IS NOT NULL THEN
*/
      OPEN c_legal_info (p_trl_global_variables_rec.legal_entity_id);
      FETCH c_legal_info INTO
            l_rep_context_name,
            l_activity_code,
            l_sub_activity_code,
            l_taxpayer_id,
         --   l_effective_from,
            l_rep_context_loc_id,
            g_rep_context_address1,
            g_rep_context_address2,
            g_rep_context_address3,
            g_rep_context_city,
            g_rep_context_region_1,
            g_rep_context_region_2,
            g_rep_context_region_3,
            g_rep_context_postal_code,
            g_rep_context_country,
        --    g_rep_context_phone_number,
            l_style;
          --  l_legal_contact_party_name,
          --  l_legal_contact_party_num,
           -- l_legal_contact_title,
           -- l_legal_contact_job_title;
      CLOSE c_legal_info;

       OPEN c_legal_contact_info(p_trl_global_variables_rec.legal_entity_id);
      FETCH c_legal_contact_info INTO
            l_legal_contact_party_name,
            l_legal_contact_party_num,
            l_legal_contact_title,
            l_legal_contact_job_title;
      CLOSE c_legal_contact_info;

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_rep_context_name  : '|| l_rep_context_name);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_activity_code : '|| l_activity_code);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_sub_activity_code : '|| l_sub_activity_code);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_taxpayer_id : '|| l_taxpayer_id);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_rep_context_loc_id : '|| l_rep_context_loc_id);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'g_rep_context_address1 : '|| g_rep_context_address1);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'g_rep_context_city : '|| g_rep_context_city);

        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_style : '|| l_style);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_legal_contact_party_name : '|| l_legal_contact_party_name);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_legal_contact_title : '|| l_legal_contact_title);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_legal_contact_party_num : '|| l_legal_contact_party_num);

    END IF;

      OPEN c_legal_auth_info (p_trl_global_variables_rec.legal_entity_id);
      FETCH c_legal_auth_info INTO
            l_legal_auth_address_line2,
            l_legal_auth_address_line3,
            l_legal_auth_city,
            l_legal_auth_name ;
      CLOSE c_legal_auth_info;

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_legal_auth_address_line2  : '|| l_legal_auth_address_line2);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_legal_auth_address_line3 : '|| l_legal_auth_address_line3);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_legal_auth_city : '|| l_legal_auth_city);
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_legal_auth_name : '|| l_legal_auth_name);

    END IF;

/* apai
    ELSE
      OPEN c_loc_rec(p_rep_entity_id);
      FETCH c_loc_rec INTO
            g_rep_context_country,
            g_rep_context_city,
            g_rep_context_region_1,
            g_rep_context_region_2,
            g_rep_context_region_3,
            g_rep_context_address1,
            g_rep_context_address2,
            g_rep_context_address3,
            g_rep_context_postal_code,
            g_rep_context_phone_number,
            l_style,
            l_rep_context_loc_id;
      CLOSE c_loc_rec;

     SELECT org_info.org_information2,
            org_unit.organization_id,
            org_unit.location_id,
            org_unit.name
      INTO  l_rep_context_tax_reg_no,
            l_rep_context_org_id,
            l_rep_context_loc_id,
            l_rep_context_name
      FROM  hr_organization_units org_unit,
            hr_organization_information org_info
     WHERE  org_unit.organization_id = org_info.organization_id
       AND  org_info.org_information1 = 'OPERATING_UNIT'
       AND  org_unit.organization_id = p_rep_entity_id;

    END IF;
*/

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf: After c_loc_rec cursor ');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'p_rep_entity_id :'||to_char(p_rep_entity_id));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'g_rep_context_city :'||g_rep_context_city);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'g_rep_context_address1 :'||g_rep_context_address1);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_rep_context_name :'||l_rep_context_name);
    END IF;

      --  populate the legal entity address fields :
      --  by calling function get_location_column with l_style

      l_rep_context_city := location_value(get_location_column(l_style,'CITY'));
      l_rep_context_county := location_value(get_location_column(l_style,'COUNTY'));
      l_rep_context_state := location_value(get_location_column(l_style,'STATE'));
      l_rep_context_province := location_value(get_location_column(l_style,'PROVINCE'));
      l_rep_context_country := location_value(get_location_column(l_style,'COUNTRY'));
      l_rep_context_address1 := location_value(get_location_column(l_style,'ADDRESS LINE 1'));
      l_rep_context_address2 := location_value(get_location_column(l_style,'ADDRESS LINE 2'));
      l_rep_context_address3 := location_value(get_location_column(l_style,'ADDRESS LINE 3'));
      l_rep_context_phone_number := location_value(get_location_column(l_style,'TELEPHONE'));
      l_rep_context_postal_code := location_value(get_location_column(l_style,'POSTAL CODE'));
      l_rep_entity_id := p_rep_entity_id;

--Bug 5439099 : Logic Implemented to populate the org_information2 with Main HQ EST REG NBR

     begin
	--get ptp id for HQ of the LE
	SELECT ptp.party_id
	INTO l_hq_party_id
	FROM zx_party_tax_profile ptp,
	xle_etb_profiles xlep
	WHERE ptp.party_id         = xlep.party_id
	AND ptp.party_type_code  = 'LEGAL_ESTABLISHMENT'
	AND xlep.legal_entity_id = p_trl_global_variables_rec.legal_entity_id
	AND xlep.main_establishment_flag = 'Y';

        l_org_information2 := ZX_TCM_EXT_SERVICES_PUB.Get_Default_Tax_Reg(
				l_hq_party_id ,
				'LEGAL_ESTABLISHMENT',
				SYSDATE,
				x_return_status);
     EXCEPTION WHEN
     OTHERS THEN
	l_org_information2 := null;
     END;


      BEGIN
         SELECT zx_rep_context_t_s.nextval
           INTO l_rep_context_id FROM dual;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf: Insert statement begins ');
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'p_rep_entity_id :'||to_char(p_rep_entity_id));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'rep_context_id :'||to_char(l_rep_context_id));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_rep_context_city :'||l_rep_context_city);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'l_rep_context_address1 :'||l_rep_context_address1);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                                  'HQ Tax Registration Nbr : l_org_information2 :'||l_org_information2);
      END IF;

      Begin
    	  INSERT INTO zx_rep_context_t(
                rep_context_id,
		request_id,
		rep_entity_id,
		rep_context_entity_location_id,
		rep_context_entity_name,
		rep_context_entity_city,
		rep_context_entity_county,
		rep_context_entity_state,
		rep_context_entity_province,
		rep_context_entity_address1,
		rep_context_entity_address2,
		rep_context_entity_address3,
		rep_context_entity_country,
		rep_context_entity_postal_code,
		rep_context_entity_tel_number,
		rep_context_lvl_mng,
		rep_context_lvl_code,
		extract_summary_code,
		matrix_report_flag,
		legal_contact_pre_name_adjunct,
		legal_contact_party_name,
		taxpayer_id,
		legal_contact_title,
		activity_code,
		sub_activity_code,
		inception_date,
		legal_contact_party_num,
		legal_auth_address_line2,
		legal_auth_address_line3,
		legal_auth_city,
  		legal_authority_name,
		org_information2,
		program_application_id,
		program_id,
		program_login_id,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
   		last_update_login)
      	    VALUES (
               l_rep_context_id,
	       p_trl_global_variables_rec.request_id,
	       l_rep_entity_id,
	       l_rep_context_loc_id,
	       l_rep_context_name,
	       l_rep_context_city,
	       l_rep_context_county,
	       l_rep_context_state,
	       l_rep_context_province,
	       l_rep_context_address1,
	       l_rep_context_address2,
	       l_rep_context_address3,
	       l_rep_context_country,
	       l_rep_context_postal_code,
	       l_rep_context_phone_number,
	       l_rep_context_lvl_mng,
	       --l_rep_context_lvl_code,
               p_trl_global_variables_rec.reporting_level,
	       l_extract_summary_code,
	       l_matrix_report_flag,
	       l_legal_contact_job_title,
	       l_legal_contact_party_name,
	       l_taxpayer_id,
	       l_legal_contact_title,
	       l_activity_code,
	       l_sub_activity_code,
	       l_inception_date,
	       l_legal_contact_party_num,
	       l_legal_auth_address_line2,
               l_legal_auth_address_line3,
               l_legal_auth_city,
               l_legal_auth_name,
               l_org_information2,
               l_program_application_id,
               l_program_id,
               l_program_login_id,
               g_created_by,
	       g_creation_date,
	       g_last_updated_by,
	       g_last_update_date,
   	       g_last_update_login);

         l_rowcount := SQL%ROWCOUNT;
   IF (g_level_unexpected >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_unexpected,
                            'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                             'Rows Inserted in Rep context table :'||to_char(l_rowcount));
           END IF;

        IF l_rowcount = 0 THEN
           P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;
           IF (g_level_unexpected >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_unexpected,
                            'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                             'P_TRL_GLOBAL_VARIABLES_REC.RETCODE'||to_char(P_TRL_GLOBAL_VARIABLES_REC.RETCODE));
           END IF;

        END IF;
      END;

     EXCEPTION
         WHEN OTHERS THEN
           g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
           FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','insert_rep_context_itf- '|| g_error_buffer);
           FND_MSG_PUB.Add;
           IF (g_level_unexpected >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_unexpected,
                            'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf',
                             g_error_buffer);
           END IF;
           APPEND_ERRBUF(g_error_buffer);
           P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;

       END;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf.END',
                                  'ZX.TRL.ZX_EXTRACT_PKG.insert_rep_context_itf(-)');
    END IF;

END insert_rep_context_itf ;


/*===========================================================================+
 | function                                                                  |
 |   location_value                                                          |
 |                                                                           |
 | description                                                               |
 |    this function RETURNs the value stored in a particular column  in      |
 |    the memory structure pr_org_loc_rec                                    |
 |                                                                           |
 | scope - private                                                           |
 +===========================================================================*/

FUNCTION location_value(
         p_column in VARCHAR2)
RETURN VARCHAR2 IS

    l_column_value VARCHAR2(240);
    l_column VARCHAR2(240);

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.location_value.BEGIN',
                                  'ZX.TRL.ZX_EXTRACT_PKG.location_value(+)');
    END IF;

    l_column := p_column;
    IF l_column = 'TOWN_OR_CITY' THEN
       l_column_value := g_rep_context_city;
    ELSIF l_column  = 'COUNTRY' THEN
       l_column_value := g_rep_context_country;
    ELSIF l_column  = 'REGION_1' THEN
       l_column_value := g_rep_context_region_1;
    ELSIF l_column  = 'REGION_2' THEN
        l_column_value := g_rep_context_region_2;
    ELSIF l_column = 'REGION_3' THEN
        l_column_value := g_rep_context_region_3;
    ELSIF l_column = 'ADDRESS_LINE_1' THEN
        l_column_value := g_rep_context_address1;
    ELSIF l_column = 'ADDRESS_LINE_2' THEN
        l_column_value := g_rep_context_address2;
    ELSIF l_column = 'ADDRESS_LINE_3' THEN
        l_column_value := g_rep_context_address3;
    ELSIF l_column = 'POSTAL_CODE' THEN
        l_column_value := g_rep_context_postal_code;
    ELSIF l_column = 'TELEPHONE_NUMBER_1' THEN
        l_column_value := g_rep_context_phone_number;
    ELSIF l_column = 'TELEPHONE_NUMBER_2' THEN
        l_column_value := g_rep_context_phone_number;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.location_value.END',
                                  'ZX.TRL.ZX_EXTRACT_PKG.location_value(-)'||l_column_value);
    END IF;

    RETURN l_column_value;

EXCEPTION
    WHEN OTHERS THEN
        g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
        FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','location_value- '|| g_error_buffer);
        FND_MSG_PUB.Add;
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected, 'ZX.TRL.ZX_EXTRACT_PKG.location_value',
                                          g_error_buffer);
        END IF;
           APPEND_ERRBUF(g_error_buffer);
           --P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;

END location_value;

/*===========================================================================+
 | FUNCTION                                                                  |
 |   GET_LOCATION_COLUMN                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This FUNCTION returns the column in table HR_LOCATIONS_V  which        |
 |    stores the address information for a particular address style          |
 |        								     |
 |    For example, if the location style is US then the column REGION1       |
 |    is used to store COUNTY information, but if the style is CN the        |
 |    same column may store PROVINCE information.                            |
 |                                                                           |
 |    Called from ZX_EXTRACT_PKG.POPULATE_TAX_DATA()                         |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/

FUNCTION  get_location_column(p_style IN VARCHAR2,
                              p_classification IN VARCHAR2)
          return VARCHAR2  is

 ----------------------------
 -- Private Variables
 ----------------------------
  pr_segments                             FND_DFLEX.SEGMENTS_DR;
  pr_contexts                             FND_DFLEX.CONTEXTS_DR;
    i         BINARY_INTEGER;
    l_style   HR_LOCATIONS_ALL.STYLE%type;
    l_context NUMBER;
    l_column  VARCHAR2(150);

 BEGIN

    l_style := p_style;

--  Get the context information from 'Address Location' Descriptive Flexfield
--  Select the context value which matches p_org_loc_rec.style
   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.get_location_column.BEGIN',
                                  'ZX.TRL.ZX_EXTRACT_PKG.get_location_column(+)');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.get_location_column',
                                  'P_CLASSIFICATION = '||p_classification);
    END IF;

      fnd_dflex.get_contexts(pr_flexfield, pr_contexts);
    l_context := NULL;

    FOR i IN 1 .. pr_contexts.ncontexts LOOP
       IF(pr_contexts.is_enabled(i)) THEN
         IF pr_contexts.context_code(i) = l_style then
            IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.get_location_column',
                      'pr_contexts.context_code= '||pr_contexts.context_code(i)||'-'||
                  pr_contexts.context_description(i));
            END IF;
               l_context := i;
         END IF;
       END IF;
    END LOOP;

    IF l_context is NULL then
      return NULL;
    END IF;

--  Select the segments which correspond to the selected context.
    fnd_dflex.get_segments(fnd_dflex.make_context(pr_flexfield,
                             pr_contexts.context_code(l_context)),
                          pr_segments,
                          TRUE);

--  Check if the segment name matches with the value of input parameter p_classification,
--  Otherwise write an error message and return null

    FOR i IN 1 .. pr_segments.nsegments LOOP
        IF  upper(pr_segments.segment_name(i)) = upper(p_classification) then
            l_column := pr_segments.application_column_name(i);
        END IF;
    END LOOP;

    IF l_column is NULL then
       IF (g_level_procedure >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.get_location_column',
                          'No column  which matches the value of p_classification: '||p_classification);
       END IF;
       return NULL;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.get_location_column.END',
                                  'ZX.TRL.ZX_EXTRACT_PKG.get_location_column(-)');
    END IF;

   RETURN l_column;

     EXCEPTION
         WHEN OTHERS THEN
           g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
           FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_location_column- '|| g_error_buffer);
           FND_MSG_PUB.Add;
           IF (g_level_unexpected >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_unexpected,
                            'ZX.TRL.ZX_EXTRACT_PKG.get_location_column',
                             g_error_buffer);
           END IF;
           APPEND_ERRBUF(g_error_buffer);
           --P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;
           RETURN NULL;


END get_location_column;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   STACK_ERROR                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure takes the token(s), Value(s) and puts on the message    |
 |    stack                                                                  |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   13-July-99 Nilesh Patel Created                                         |
 |                                                                           |
 +===========================================================================*/

PROCEDURE stack_error (
                  p_application VARCHAR2,
                  p_msgname 	VARCHAR2,
                  p_token1      VARCHAR2 DEFAULT NULL,
                  p_value1      VARCHAR2 DEFAULT NULL,
                  p_token2      VARCHAR2 DEFAULT NULL,
                  p_value2      VARCHAR2 DEFAULT NULL,
                  p_token3      VARCHAR2 DEFAULT NULL,
                  p_value3      VARCHAR2 DEFAULT NULL ) IS
BEGIN

  fnd_message.set_name(nvl(p_application,'AR'),nvl(p_msgname,'GENERIC_MESSAGE'));

  IF ( p_token1 IS NOT NULL ) THEN
          fnd_message.set_token(p_token1, p_value1);
  END IF;

  IF ( p_token2 IS NOT NULL ) THEN
          fnd_message.set_token(p_token2, p_value2);
  END IF;


  IF ( p_token3 IS NOT NULL ) THEN
          fnd_message.set_token(p_token3, p_value3);
  END IF;

END stack_error;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   SET_RETCODE                                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure sets the value of P_RETCODE                             |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   7-Oct-1999 Nilesh Patel Created                                         |
 |                                                                           |
 +===========================================================================*/

PROCEDURE set_retcode(p_retcode in number) is
BEGIN
   If p_retcode = 2 then
           L_RETCODE := p_retcode;
   elsif p_retcode = 1 then
           IF L_RETCODE = 2 then
               NULL;
           ELSE
               L_RETCODE := p_retcode;
           END IF;
   end if;
END set_retcode;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   APPEND_ERRBUF                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure appends the input parameter p_msg to the global         |
 |    variable L_ERRBUF which will be returned to the calling concurrent     |
 |    program.                                                               |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   7-Oct-1999 Nilesh Patel Created                                         |
 |                                                                           |
 +===========================================================================*/

PROCEDURE append_errbuf(p_msg in varchar2) is
BEGIN
  if  nvl(lengthb(L_ERRBUF),0) = 0 THEN
         L_ERRBUF := p_msg;
  elsif nvl(lengthb(L_ERRBUF),0) < 2000 - nvl(lengthb(p_msg),0) then
         L_ERRBUF := L_ERRBUF ||';'||p_msg;
  end if;

  L_ERRBUF := L_ERRBUF || fnd_global.newline;

END append_errbuf;

PROCEDURE PURGE(p_request_id in number,
                p_rows_deleted out NOCOPY number) is
BEGIN

  purge(p_request_id);
  p_rows_deleted:= purge(p_request_id);


END PURGE;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   PURGE                                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the records from AR_TAX_EXTRACT_DCL_ITF         |
 |    and AR_TAX_EXTRACT_SUB_ITF for a given request_id                      |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   14-Dec-1999 Nilesh Patel Created                                        |
 |                                                                           |
 +===========================================================================*/

PROCEDURE PURGE(p_request_id in number) is
num_rows_deleted number := 0;
BEGIN
     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.PURGE.BEGIN',
                                  'ZX.TRL.ZX_EXTRACT_PKG.BEGIN(+)');
     END IF;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
           select count(*) into num_rows_deleted
           from   zx_rep_trx_detail_t
           where  request_id = p_request_id;
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.get_location_column',
                                  'Num of Rows in zx_rep_trx_detail_t :'||num_rows_deleted);
            select count(*) into num_rows_deleted
           from   ZX_REP_ACTG_EXT_T
           where  request_id = p_request_id;
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.get_location_column',
                                  'Num of Rows in ZX_REP_ACTG_EXT_T :'||num_rows_deleted);
            select count(*) into num_rows_deleted
           from   ZX_REP_TRX_JX_EXT_T
           where  request_id = p_request_id;
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.get_location_column',
                                  'Num of Rows in ZX_REP_TRX_JX_EXT_T :'||num_rows_deleted);
            select count(*) into num_rows_deleted
           from   ZX_REP_CONTEXT_T
           where  request_id = p_request_id;
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.get_location_column',
                                  'Num of Rows in ZX_REP_CONTEXT_T :'||num_rows_deleted);
      END IF;

     IF PG_DEBUG = 'N' THEN
        delete from ZX_REP_ACTG_EXT_T where request_id = p_request_id;
        delete from ZX_REP_TRX_JX_EXT_T where request_id = p_request_id;
        delete from ZX_REP_TRX_DETAIL_T where request_id = p_request_id;
        delete from ZX_REP_CONTEXT_T where request_id = p_request_id;
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.PURGE.END',
                                  'In Delete when PG_DEBUG = N ');
        END IF;
     END IF;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.PURGE.END',
                                  'ZX.TRL.ZX_EXTRACT_PKG.PURGE(-)');
     END IF;

/*
     delete from ar_tax_extr_sub_com_ext com_ext where com_ext.extract_line_id
       in (select sub_itf.extract_line_id
           from ar_tax_Extract_sub_itf sub_itf
           where request_id = p_request_id);
     delete from ar_tax_extr_sub_ar_ext ar_ext where ar_ext.extract_line_id
       in (select sub_itf.extract_line_id
           from ar_tax_Extract_sub_itf sub_itf
           where request_id = p_request_id);
     delete from ar_tax_extr_sub_ap_ext ap_ext where ap_ext.extract_line_id
       in (select sub_itf.extract_line_id
           from ar_tax_Extract_sub_itf sub_itf
           where request_id = p_request_id);
     delete from ar_tax_extract_sub_itf where request_id = p_request_id;
     delete from ar_tax_Extract_dcl_itf where request_id = p_request_id;
*/


END PURGE;


/*===========================================================================+
 | FUNCTION                                                                  |
 |   PURGE                                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes the records from AR_TAX_EXTRACT_DCL_ITF,         |
 |    AR_TAX_EXTRACT_SUB_ITF for a given request_id                          |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   24-May-2000 Nilesh Patel Created                                        |
 |                                                                           |
 +===========================================================================*/

FUNCTION PURGE(p_request_id in number) return number is
 num_rows_deleted number := 0;
BEGIN

--pg_debug_flag:= nvl(FND_PROFILE.value('TAX_DEBUG_FLAG'),'N');


     select count(*) into num_rows_deleted
     from   zx_rep_trx_detail_t
     where  request_id = p_request_id;

     PURGE(p_request_id);

     return(num_rows_deleted);
END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |   CONVERT_STRING                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure takes the input string, replaces all inverted commas    |
 |    i.e. ' to two inverted commas i.e. '' and returns the converted        |
 |    string                                                                 |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   21-July-99 Nilesh Patel Created                                         |
 |                                                                           |
 +===========================================================================*/

function convert_string(p_string in varchar2)
 return varchar2 is

 l_string varchar2(255);
BEGIN
 If p_string is not null then
        l_string := replace(p_string,'''','''''');
 end if;
  return l_string;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   build_matrx_tbl                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This proceures takes a sql statement (varchar2) as input parameter,    |
 |    executes the sql statement, and builds a PLSQL table of records.       |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   7-Sept-99 Nilesh Patel Created                                          |
 |                                                                           |
 +===========================================================================*/

/*
procedure build_matrix_tbl( p_sql in varchar2) is
    type csr_type is ref cursor;
    csr  csr_type;
    l_index number := 0;
  begin
      pg_sql := p_sql;
      matrix_tbl.delete;
      open csr for pg_sql;
      loop
        fetch csr into matrix_rec;
        exit when csr%notfound;
        l_index := l_index + 1;
        matrix_tbl(l_index) := matrix_rec;
      end loop;
      close csr;
    end if;
  exception
    when others then
       matrix_tbl.delete;
       close csr;
     NULL;
  end;

*/

/*===========================================================================+
 | FUNCTION                                                                  |
 |   get_rep_context_id                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function returns the rep_context_id for a given organization_id   |
 |    AR/AP and GL APIs calls this function                                  |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/

/* apai this fuction is modified as per legal entity changes
function get_rep_context_id( p_org_id in number,
                             p_legal in varchar2,
                             p_legal_id in number,
                             p_request_id in number)
*/
function get_rep_context_id( p_legal_id in number,
                             p_request_id in number)
return number is
  l_rep_context_id number;


  CURSOR legal_rep_context_cur (
              c_request_id      IN NUMBER)
  IS
      SELECT rep_context.rep_context_id
         FROM zx_rep_context_t rep_context
      WHERE request_id = c_request_id;
         --AND rep_context.rep_entity_id = c_legal_entity_id;

BEGIN

        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.get_rep_context_id(+)',
                           'Legal Entity ID :'||to_char(p_legal_id));
        END IF;

        OPEN legal_rep_context_cur (p_request_id);
                                    --p_legal_id);
        FETCH legal_rep_context_cur into l_rep_context_id;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.get_rep_context_id(-)',
                          'l_rep_context_id :'||to_char(l_rep_context_id));
        END IF;

        IF legal_rep_context_cur%ISOPEN then
	    CLOSE legal_rep_context_cur;
	END IF;

   RETURN l_rep_context_id;

END get_rep_context_id;


/*===========================================================================+
 | FUNCTION                                                                  |
 |   use_matrix_flag                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This is a view functionwhich is called from concurrent program         |
 |    financial tax register to check whether matrix report flag is          |
 |    required or not                                                        |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   5-Jan-2000  Nilesh Patel  Created                                       |
 |                                                                           |
 +===========================================================================*/
function use_matrix_flag( p_report_id in varchar2,
                          p_attribute_set in varchar2,
                          p_product in varchar2 default NULL)
           return varchar2 is
l_use_matrix_rep varchar2(1);
begin
/*cursor use_matrix_flag_csr_ar
          (c_report_id in number,
           c_attribute_set in varchar2 ) is
select 'Y' from dual where exists
   (select '1'
    from FA_RX_REPORTS_V RV,
         FA_RX_ATTRSETS  ATT,
         FA_RX_REP_COLUMNS COL
    where RV.REPORT_ID = C_REPORT_ID
      AND ATT.REPORT_ID = RV.REPORT_ID
      AND ATT.ATTRIBUTE_SET = C_ATTRIBUTE_SET
      AND ATT.ATTRIBUTE_SET = COL.ATTRIBUTE_SET
      AND COL.DISPLAY_STATUS = 'YES'
      AND COL.COLUMN_NAME IN (
                             'TAX1_ACCOUNTED_AMOUNT',
                             'TAX1_ACCOUNTED_CR',
                             'TAX1_ACCOUNTED_DR',
                             'TAX1_CODE',
                             'TAX1_CODE_DESCRIPTION',
                             'TAX1_CODE_NAME',
                             'TAX1_CODE_RATE',
                             'TAX1_CODE_REG_TYPE_CODE',
                             'TAX1_CODE_REG_TYPE_MEANING',
                             'TAX1_CODE_TAX_CLASS_CODE',
                             'TAX1_CODE_TAX_CLASS_MEANING',
                             'TAX1_CODE_TYPE_CODE',
                             'TAX1_CODE_TYPE_MEANING',
                             'TAX1_CODE_VAT_TRX_TYPE_CODE',
                             'TAX1_CODE_VAT_TRX_TYPE_DESC',
                             'TAX1_CODE_VAT_TRX_TYPE_MEANING',
                             'TAX1_ENTERED_AMOUNT',
                             'TAX1_ENTERED_CR',
                             'TAX1_ENTERED_DR',
                             'TAX1_LINE_EFFECTIVE_TAX_RATE',
                             'TAX1_LINE_NUMBER',
                             'TAX1_RECOVERABLE_FLAG',
                             'TAXABLE1_ACCOUNTED_AMOUNT',
                             'TAXABLE1_ACCOUNTED_CR',
                             'TAXABLE1_ACCOUNTED_DR',
                             'TAXABLE1_ENTERED_AMOUNT',
                             'TAXABLE1_ENTERED_CR',
                             'TAXABLE1_ENTERED_DR',
                             'TAX2_ACCOUNTED_AMOUNT',
                             'TAX2_ACCOUNTED_CR',
                             'TAX2_ACCOUNTED_DR',
                             'TAX2_CODE',
                             'TAX2_CODE_DESCRIPTION',
                             'TAX2_CODE_NAME',
                             'TAX2_CODE_RATE',
                             'TAX2_CODE_REG_TYPE_CODE',
                             'TAX2_CODE_REG_TYPE_MEANING',
                             'TAX2_CODE_TAX_CLASS_CODE',
                             'TAX2_CODE_TAX_CLASS_MEANING',
                             'TAX2_CODE_TYPE_CODE',
                             'TAX2_CODE_TYPE_MEANING',
                             'TAX2_CODE_VAT_TRX_TYPE_CODE',
                             'TAX2_CODE_VAT_TRX_TYPE_DESC',
                             'TAX2_CODE_VAT_TRX_TYPE_MEANING',
                             'TAX2_ENTERED_AMOUNT',
                             'TAX2_ENTERED_CR',
                             'TAX2_ENTERED_DR',
                             'TAX2_LINE_EFFECTIVE_TAX_RATE',
                             'TAX2_LINE_NUMBER',
                             'TAX2_RECOVERABLE_FLAG',
                             'TAXABLE2_ACCOUNTED_AMOUNT',
                             'TAXABLE2_ACCOUNTED_CR',
                             'TAXABLE2_ACCOUNTED_DR',
                             'TAXABLE2_ENTERED_AMOUNT',
                             'TAXABLE2_ENTERED_CR',
                             'TAXABLE2_ENTERED_DR',
                             'TAX3_ACCOUNTED_AMOUNT',
                             'TAX3_ACCOUNTED_CR',
                             'TAX3_ACCOUNTED_DR',
                             'TAX3_CODE',
                             'TAX3_CODE_DESCRIPTION',
                             'TAX3_CODE_NAME',
                             'TAX3_CODE_RATE',
                             'TAX3_CODE_REG_TYPE_CODE',
                             'TAX3_CODE_REG_TYPE_MEANING',
                             'TAX3_CODE_TAX_CLASS_CODE',
                             'TAX3_CODE_TAX_CLASS_MEANING',
                             'TAX3_CODE_TYPE_CODE',
                             'TAX3_CODE_TYPE_MEANING',
                             'TAX3_CODE_VAT_TRX_TYPE_CODE',
                             'TAX3_CODE_VAT_TRX_TYPE_DESC',
                             'TAX3_CODE_VAT_TRX_TYPE_MEANING',
                             'TAX3_ENTERED_AMOUNT',
                             'TAX3_ENTERED_CR',
                             'TAX3_ENTERED_DR',
                             'TAX3_LINE_EFFECTIVE_TAX_RATE',
                             'TAX3_LINE_NUMBER',
                             'TAX3_RECOVERABLE_FLAG',
                             'TAXABLE3_ACCOUNTED_AMOUNT',
                             'TAXABLE3_ACCOUNTED_CR',
                             'TAXABLE3_ACCOUNTED_DR',
                             'TAXABLE3_ENTERED_AMOUNT',
                             'TAXABLE3_ENTERED_CR',
                             'TAXABLE3_ENTERED_DR',
                             'TAX4_ACCOUNTED_AMOUNT',
                             'TAX4_ACCOUNTED_CR',
                             'TAX4_ACCOUNTED_DR',
                             'TAX4_CODE',
                             'TAX4_CODE_DESCRIPTION',
                             'TAX4_CODE_NAME',
                             'TAX4_CODE_RATE',
                             'TAX4_CODE_REG_TYPE_CODE',
                             'TAX4_CODE_REG_TYPE_MEANING',
                             'TAX4_CODE_TAX_CLASS_CODE',
                             'TAX4_CODE_TAX_CLASS_MEANING',
                             'TAX4_CODE_TYPE_CODE',
                             'TAX4_CODE_TYPE_MEANING',
                             'TAX4_CODE_VAT_TRX_TYPE_CODE',
                             'TAX4_CODE_VAT_TRX_TYPE_DESC',
                             'TAX4_CODE_VAT_TRX_TYPE_MEANING',
                             'TAX4_ENTERED_AMOUNT',
                             'TAX4_ENTERED_CR',
                             'TAX4_ENTERED_DR',
                             'TAX4_LINE_EFFECTIVE_TAX_RATE',
                             'TAX4_LINE_NUMBER',
                             'TAX4_RECOVERABLE_FLAG',
                             'TAXABLE4_ACCOUNTED_AMOUNT',
                             'TAXABLE4_ACCOUNTED_CR',
                             'TAXABLE4_ACCOUNTED_DR',
                             'TAXABLE4_ENTERED_AMOUNT',
                             'TAXABLE4_ENTERED_CR',
                             'TAXABLE4_ENTERED_DR') );

cursor use_matrix_flag_csr_ap
          (c_report_id in number,
           c_attribute_set in varchar2 ) is
select 'Y' from dual where exists
   (select '1'
    from FA_RX_REPORTS_V RV,
         FA_RX_ATTRSETS  ATT,
         FA_RX_REP_COLUMNS COL
    where RV.REPORT_ID = C_REPORT_ID
      AND ATT.REPORT_ID = RV.REPORT_ID
      AND ATT.ATTRIBUTE_SET = C_ATTRIBUTE_SET
      AND ATT.ATTRIBUTE_SET = COL.ATTRIBUTE_SET
      AND COL.DISPLAY_STATUS = 'YES'
      AND COL.COLUMN_NAME IN (
                             'TAX3_ACCOUNTED_AMOUNT',
                             'TAX3_ACCOUNTED_CR',
                             'TAX3_ACCOUNTED_DR',
                             'TAX3_CODE',
                             'TAX3_CODE_DESCRIPTION',
                             'TAX3_CODE_NAME',
                             'TAX3_CODE_RATE',
                             'TAX3_CODE_REG_TYPE_CODE',
                             'TAX3_CODE_REG_TYPE_MEANING',
                             'TAX3_CODE_TAX_CLASS_CODE',
                             'TAX3_CODE_TAX_CLASS_MEANING',
                             'TAX3_CODE_TYPE_CODE',
                             'TAX3_CODE_TYPE_MEANING',
                             'TAX3_CODE_VAT_TRX_TYPE_CODE',
                             'TAX3_CODE_VAT_TRX_TYPE_DESC',
                             'TAX3_CODE_VAT_TRX_TYPE_MEANING',
                             'TAX3_ENTERED_AMOUNT',
                             'TAX3_ENTERED_CR',
                             'TAX3_ENTERED_DR',
                             'TAX3_LINE_EFFECTIVE_TAX_RATE',
                             'TAX3_LINE_NUMBER',
                             'TAX3_RECOVERABLE_FLAG',
                             'TAXABLE3_ACCOUNTED_AMOUNT',
                             'TAXABLE3_ACCOUNTED_CR',
                             'TAXABLE3_ACCOUNTED_DR',
                             'TAXABLE3_ENTERED_AMOUNT',
                             'TAXABLE3_ENTERED_CR',
                             'TAXABLE3_ENTERED_DR',
                             'TAX4_ACCOUNTED_AMOUNT',
                             'TAX4_ACCOUNTED_CR',
                             'TAX4_ACCOUNTED_DR',
                             'TAX4_CODE',
                             'TAX4_CODE_DESCRIPTION',
                             'TAX4_CODE_NAME',
                             'TAX4_CODE_RATE',
                             'TAX4_CODE_REG_TYPE_CODE',
                             'TAX4_CODE_REG_TYPE_MEANING',
                             'TAX4_CODE_TAX_CLASS_CODE',
                             'TAX4_CODE_TAX_CLASS_MEANING',
                             'TAX4_CODE_TYPE_CODE',
                             'TAX4_CODE_TYPE_MEANING',
                             'TAX4_CODE_VAT_TRX_TYPE_CODE',
                             'TAX4_CODE_VAT_TRX_TYPE_DESC',
                             'TAX4_CODE_VAT_TRX_TYPE_MEANING',
                             'TAX4_ENTERED_AMOUNT',
                             'TAX4_ENTERED_CR',
                             'TAX4_ENTERED_DR',
                             'TAX4_LINE_EFFECTIVE_TAX_RATE',
                             'TAX4_LINE_NUMBER',
                             'TAX4_RECOVERABLE_FLAG',
                             'TAXABLE4_ACCOUNTED_AMOUNT',
                             'TAXABLE4_ACCOUNTED_CR',
                             'TAXABLE4_ACCOUNTED_DR',
                             'TAXABLE4_ENTERED_AMOUNT',
                             'TAXABLE4_ENTERED_CR',
                             'TAXABLE4_ENTERED_DR') );

Begin
--   arp_util_tax.debug('ZX_EXTRACT_PKG.USE_MATRIX_REPORT: Product = '||
--                      P_PRODUCT );

   l_use_matrix_rep := 'N';

   if P_PRODUCT = 'AP' then
       open use_matrix_flag_csr_ap (p_report_id,p_attribute_set);
       fetch use_matrix_flag_csr_ap into l_use_matrix_rep;
       if use_matrix_flag_csr_ap%isopen then
         close use_matrix_flag_csr_ap;
       end if;
   else
       open use_matrix_flag_csr_ar (p_report_id,p_attribute_set);
       fetch use_matrix_flag_csr_ar into l_use_matrix_rep;
       if use_matrix_flag_csr_ar%isopen then
         close use_matrix_flag_csr_ar;
       end if;
   end if;
   return l_use_matrix_rep;
exception
   when no_data_found then
        IF PG_DEBUG = 'Y' THEN
        	arp_util_tax.debug('ZX_EXTRACT_PKG.UE_MATRIX_REP : NO_DATA_FOUND ');
        END IF;
        if use_matrix_flag_csr_ap%isopen then
            close use_matrix_flag_csr_ap;
        end if;
        if use_matrix_flag_csr_ar%isopen then
            close use_matrix_flag_csr_ar;
        end if;
        return ('N');
   when others then
        IF PG_DEBUG = 'Y' THEN
        	arp_util_tax.debug('ZX_EXTRACT_PKG.UE_MATRIX_REP: '||SQLCODE
                            ||' ; '||SQLERRM);
        END IF;
        if use_matrix_flag_csr_ap%isopen then
            close use_matrix_flag_csr_ap;
        end if;
        if use_matrix_flag_csr_ar%isopen then
            close use_matrix_flag_csr_ar;
        end if; */
        return('N');
end;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   zx_upd_legal_reporting_status()                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure is used to update the legal_reporting_status value      |
 |    on the zx_lines with the value passed as input to this procedure       |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   24-Mar-2006      Ashwin Gurram Created                                  |
 |                                                                           |
 +===========================================================================*/

PROCEDURE ZX_UPD_LEGAL_REPORTING_STATUS(
        p_api_version			IN NUMBER,
	p_init_msg_list			IN VARCHAR2,
	p_commit			IN VARCHAR2,
	p_validation_level		IN VARCHAR2,
        p_application_id_tbl		IN application_id_tbl,
	p_entity_code_tbl		IN entity_code_tbl,
	p_event_class_code_tbl		IN event_class_code_tbl,
	p_trx_id_tbl			IN trx_id_tbl,
	p_trx_line_id_tbl		IN trx_line_id_tbl,
	p_INTERNAL_ORGANIZATION_ID_tbl	IN INTERNAL_ORGANIZATION_ID_TBL,
	p_TAX_LINE_ID_tbl		IN TAX_LINE_ID_TBL,
	p_legal_reporting_status_val	IN zx_lines.LEGAL_REPORTING_STATUS%type,
	x_return_status			OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2
) IS

l_count NUMBER := 0;
l_counter_start NUMBER := 1 ;
l_counter_end NUMBER := 0 ;

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	IF (g_level_procedure >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.zx_upd_legal_reporting_status.BEGIN',
				      'ZX_EXTRACT_PKG:zx_upd_legal_reporting_status(+)');
	END IF;

        l_count := p_application_id_tbl.COUNT ;

	IF ( l_count > C_LINES_PER_INSERT ) THEN
	l_counter_end := C_LINES_PER_INSERT;
	ELSE
	l_counter_end := l_count ;
	END IF ;

	LOOP
		IF ( l_counter_end <= l_count AND l_counter_start <= l_count ) THEN

		     FORALL i IN l_counter_start .. l_counter_end
			UPDATE ZX_LINES
			  SET LEGAL_REPORTING_STATUS = p_legal_reporting_status_val,
			  LAST_UPDATED_BY = fnd_global.user_id ,
			  LAST_UPDATE_DATE = SYSDATE ,
			  LAST_UPDATE_LOGIN = fnd_global.conc_login_id ,
			  OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
			  WHERE application_id = p_application_id_tbl(i)
			    AND entity_code = p_entity_code_tbl(i)
			    AND event_class_code = p_event_class_code_tbl(i)
			    AND trx_id = p_trx_id_tbl(i)
			    AND trx_line_id = p_trx_line_id_tbl(i)
			    AND INTERNAL_ORGANIZATION_ID = p_INTERNAL_ORGANIZATION_ID_tbl(i)
			    AND TAX_LINE_ID = p_TAX_LINE_ID_tbl(i) ;

			l_counter_start := l_counter_end + 1;
			IF ( l_counter_end + C_LINES_PER_INSERT < l_count ) THEN
				l_counter_end := l_counter_end + C_LINES_PER_INSERT;
			ELSE
			   l_counter_end := l_count ;
			END IF ;
		ELSE
			EXIT ;
		END IF ;

	END LOOP ;

	   IF (g_level_procedure >= g_current_runtime_level ) THEN
	       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_EXTRACT_PKG.zx_upd_legal_reporting_status.END',
					      'ZX_EXTRACT_PKG:zx_upd_legal_reporting_status(-)');
	   END IF;

EXCEPTION
WHEN OTHERS THEN
	IF (g_level_unexpected >= g_current_runtime_level ) THEN
	  FND_LOG.STRING(g_level_unexpected,
		  'ZX.TRL.ZX_EXTRACT_PKG.zx_upd_legal_reporting_status',
		   sqlerrm);
	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	app_exception.raise_exception;
END ZX_UPD_LEGAL_REPORTING_STATUS;

/*===========================================================================+
 | FUNCTION                                                                  |
 |   get_legal_message                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function is used to retrieve the legal justification message      |
 |    for Sales transactions (Invoice CM and DM)                             |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | PARAMETERS                                                                |
 |    p_trx_id       IN  Transaction ID                                      |
 |    p_trx_line_id  IN  Transaction Line ID                                 |
 |    p_delimiter    IN  Delimiter for Header level call Default NULL        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   17-Nov-2009      Simranjeet Sohal     Created                           |
 |   02-Dec-2009      Taniya Sen           Modified                          |
 |                                                                           |
 +===========================================================================*/
FUNCTION get_legal_message
            (p_trx_id      IN zx_lines.trx_id%TYPE,
             p_trx_line_id IN zx_lines.trx_line_id%TYPE,
             p_delimiter   IN VARCHAR2 DEFAULT NULL)
 RETURN VARCHAR2 IS

   /*----------------------------------------+
    |  Cursor to retrieve legal message for  |
    |  a transaction at header level         |
    +----------------------------------------*/
   CURSOR get_lgl_msg_header IS
    SELECT DISTINCT v1.reporting_code_name
    FROM (
      SELECT v.reporting_code_name,
             ROW_NUMBER() OVER (PARTITION BY v.trx_line_id
                                ORDER BY v.tax_line_id, v.order_num) AS row_num
      FROM (
            SELECT DISTINCT rep_codes.reporting_code_name, zxl.trx_line_id, zxl.tax_line_id,1 order_num
            FROM zx_reporting_types_b  rep_types,
                 zx_reporting_codes_vl rep_codes,
                 zx_lines              zxl
            WHERE zxl.application_id = 222
            AND zxl.entity_code = 'TRANSACTIONS'
            AND zxl.event_class_code IN ('INVOICE','DEBIT_MEMO','CREDIT_MEMO')
            AND zxl.trx_id = p_trx_id
            AND zxl.legal_message_rate = rep_codes.reporting_code_id
            AND rep_codes.reporting_type_id = rep_types.reporting_type_id
            AND rep_types.legal_message_flag = 'Y'
            UNION
            SELECT DISTINCT rep_codes.reporting_code_name, zxl.trx_line_id,zxl.tax_line_id, 2 order_num
            FROM zx_report_codes_assoc rep_assoc,
                 zx_reporting_types_b  rep_types,
                 zx_reporting_codes_vl rep_codes,
                 zx_lines              zxl
            WHERE zxl.application_id = 222
            AND zxl.entity_code = 'TRANSACTIONS'
            AND zxl.event_class_code IN ('INVOICE','DEBIT_MEMO','CREDIT_MEMO')
            AND zxl.trx_id = p_trx_id
            AND rep_assoc.entity_id = zxl.tax_rate_id
            AND rep_assoc.entity_code = 'ZX_RATES'
            AND zxl.trx_date BETWEEN rep_assoc.effective_from AND
                 NVL(rep_assoc.effective_to, zxl.trx_date)
            AND rep_assoc.reporting_type_id = rep_types.reporting_type_id
            AND rep_assoc.reporting_code_id = rep_codes.reporting_code_id
            AND rep_codes.reporting_type_id = rep_types.reporting_type_id
            AND rep_types.legal_message_flag = 'Y'
            UNION
            SELECT DISTINCT rep_codes.reporting_code_name, zxl.trx_line_id,zxl.tax_line_id, 3 order_num
            FROM zx_reporting_types_b  rep_types,
                 zx_reporting_codes_vl rep_codes,
                 zx_lines              zxl
            WHERE zxl.application_id = 222
            AND zxl.entity_code = 'TRANSACTIONS'
            AND zxl.event_class_code IN ('INVOICE','DEBIT_MEMO','CREDIT_MEMO')
            AND zxl.trx_id = p_trx_id
            AND zxl.legal_message_status = rep_codes.reporting_code_id
            AND rep_codes.reporting_type_id = rep_types.reporting_type_id
            AND rep_types.legal_message_flag = 'Y'
           ) v
      ) v1
    WHERE v1.row_num = 1;

   /*----------------------------------------+
    |  Cursor to retrieve legal message for  |
    |  a transaction at Line level           |
    +----------------------------------------*/
   CURSOR get_lgl_msg_line IS
    SELECT DISTINCT v1.reporting_code_name
    FROM (
      SELECT v.reporting_code_name,
             v.order_num
      FROM (
            SELECT DISTINCT rep_codes.reporting_code_name, zxl.tax_line_id,1 order_num
            FROM zx_reporting_types_b  rep_types,
                 zx_reporting_codes_vl rep_codes,
                 zx_lines              zxl
            WHERE zxl.application_id = 222
            AND zxl.entity_code = 'TRANSACTIONS'
            AND zxl.event_class_code IN ('INVOICE','DEBIT_MEMO','CREDIT_MEMO')
            AND zxl.trx_id = p_trx_id
            AND zxl.trx_line_id = p_trx_line_id
            AND zxl.legal_message_rate = rep_codes.reporting_code_id
            AND rep_codes.reporting_type_id = rep_types.reporting_type_id
            AND rep_types.legal_message_flag = 'Y'
            UNION
            SELECT DISTINCT rep_codes.reporting_code_name, zxl.tax_line_id, 2 order_num
            FROM zx_report_codes_assoc rep_assoc,
                 zx_reporting_types_b  rep_types,
                 zx_reporting_codes_vl rep_codes,
                 zx_lines              zxl
            WHERE zxl.application_id = 222
            AND zxl.entity_code = 'TRANSACTIONS'
            AND zxl.event_class_code IN ('INVOICE','DEBIT_MEMO','CREDIT_MEMO')
            AND zxl.trx_id = p_trx_id
            AND zxl.trx_line_id = p_trx_line_id
            AND rep_assoc.entity_id = zxl.tax_rate_id
            AND rep_assoc.entity_code = 'ZX_RATES'
            AND zxl.trx_date BETWEEN rep_assoc.effective_from AND
                 NVL(rep_assoc.effective_to, zxl.trx_date)
            AND rep_assoc.reporting_type_id = rep_types.reporting_type_id
            AND rep_assoc.reporting_code_id = rep_codes.reporting_code_id
            AND rep_codes.reporting_type_id = rep_types.reporting_type_id
            AND rep_types.legal_message_flag = 'Y'
            UNION
            SELECT DISTINCT rep_codes.reporting_code_name, zxl.tax_line_id, 3 order_num
            FROM zx_reporting_types_b  rep_types,
                 zx_reporting_codes_vl rep_codes,
                 zx_lines              zxl
            WHERE zxl.application_id = 222
            AND zxl.entity_code = 'TRANSACTIONS'
            AND zxl.event_class_code IN ('INVOICE','DEBIT_MEMO','CREDIT_MEMO')
            AND zxl.trx_id = p_trx_id
            AND zxl.trx_line_id = p_trx_line_id
            AND zxl.legal_message_status = rep_codes.reporting_code_id
            AND rep_codes.reporting_type_id = rep_types.reporting_type_id
            AND rep_types.legal_message_flag = 'Y'
           ) v
      ORDER BY v.tax_line_id,v.order_num,v.reporting_code_name) v1
   WHERE rownum = 1;

   -- Variables --
   l_lgl_msg         VARCHAR2(240);
   l_legal_msg       VARCHAR2(2000);
   l_is_first_msg    VARCHAR2(1) := 'Y';

 BEGIN

   l_legal_msg := TO_CHAR(NULL);

   -- Check for header level.
   IF p_trx_line_id IS NULL THEN

     l_lgl_msg := TO_CHAR(NULL);
     OPEN get_lgl_msg_header;
     LOOP
       FETCH get_lgl_msg_header INTO l_lgl_msg;

     EXIT WHEN get_lgl_msg_header%NOTFOUND;

     IF l_lgl_msg IS NOT NULL THEN
       IF l_is_first_msg = 'Y' THEN
         l_legal_msg := l_legal_msg || l_lgl_msg;
       ELSE
         l_legal_msg := l_legal_msg || p_delimiter || l_lgl_msg;
       END IF;
     END IF;

     -- is this the first message being fetched.
     IF l_lgl_msg IS NOT NULL AND l_is_first_msg = 'Y' THEN
       l_is_first_msg := 'N';
     END IF;

     END LOOP;
     CLOSE get_lgl_msg_header;

   ELSE
     l_lgl_msg := TO_CHAR(NULL);

     OPEN get_lgl_msg_line;
     LOOP
       FETCH get_lgl_msg_line INTO l_lgl_msg;
     EXIT WHEN get_lgl_msg_line%NOTFOUND;
         l_legal_msg := l_legal_msg || l_lgl_msg;
     END LOOP;

     CLOSE get_lgl_msg_line;
   END IF;

   RETURN l_legal_msg;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN TO_CHAR(NULL);

 END get_legal_message;

 FUNCTION get_vat_transaction_code_name
            (p_tax_line_id       IN zx_lines.tax_line_id%TYPE,
             p_esl_eu_trx_type   IN VARCHAR2,
             p_esl_eu_goods      IN VARCHAR2,
             p_esl_eu_services   IN VARCHAR2,
             p_esl_eu_addl_code1 IN VARCHAR2,
             p_esl_eu_addl_code2 IN VARCHAR2,
             p_code_or_name      IN VARCHAR2 DEFAULT 'NAME'
             )
 RETURN VARCHAR2 IS

   /*----------------------------------------+
    |  Cursor to retrieve legal message for  |
    |  a given entity on a given date        |
    +----------------------------------------*/
   CURSOR get_lgl_msg IS
    SELECT v1.reporting_code_name, v1.reporting_code_char_value
    FROM
     (SELECT v.reporting_code_name, v.reporting_code_char_value
      FROM (
          SELECT rep_codes.reporting_code_name, rep_codes.reporting_code_char_value, 1 order_num
          FROM zx_report_codes_assoc rep_assoc,
               zx_reporting_types_b  rep_types,
               zx_reporting_codes_vl rep_codes,
               zx_lines              zxl
          WHERE zxl.tax_line_id = p_tax_line_id
          AND rep_types.reporting_type_id = p_esl_eu_trx_type
          AND rep_types.reporting_type_id = rep_assoc.reporting_type_id
          AND rep_assoc.entity_id = NVL(zxl.direct_rate_result_id, zxl.rate_result_id)
          AND rep_assoc.entity_code = 'ZX_PROCESS_RESULTS'
          AND zxl.trx_date BETWEEN rep_assoc.effective_from AND
               NVL(rep_assoc.effective_to, zxl.trx_date)
          AND rep_assoc.reporting_code_id = rep_codes.reporting_code_id
          AND ((p_esl_eu_goods IS NOT NULL
                AND rep_codes.reporting_code_id = p_esl_eu_goods) OR
               (p_esl_eu_services IS NOT NULL
                AND rep_codes.reporting_code_id = p_esl_eu_services) OR
               (p_esl_eu_addl_code1 IS NOT NULL
                AND rep_codes.reporting_code_id = p_esl_eu_addl_code1) OR
               (p_esl_eu_addl_code2 IS NOT NULL
                AND rep_codes.reporting_code_id = p_esl_eu_addl_code2) OR
               (coalesce(p_esl_eu_goods,p_esl_eu_services,
                         p_esl_eu_addl_code1,p_esl_eu_addl_code2,
                         FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR ))
          UNION
          SELECT rep_codes.reporting_code_name, rep_codes.reporting_code_char_value, 2 order_num
          FROM zx_report_codes_assoc rep_assoc,
               zx_reporting_types_b  rep_types,
               zx_reporting_codes_vl rep_codes,
               zx_lines              zxl
          WHERE zxl.tax_line_id = p_tax_line_id
          AND rep_types.reporting_type_id = p_esl_eu_trx_type
          AND rep_types.reporting_type_id = rep_assoc.reporting_type_id
          AND rep_assoc.entity_id = zxl.tax_rate_id
          AND rep_assoc.entity_code = 'ZX_RATES'
          AND zxl.trx_date BETWEEN rep_assoc.effective_from AND
               NVL(rep_assoc.effective_to, zxl.trx_date)
          AND rep_assoc.reporting_code_id = rep_codes.reporting_code_id
          AND ((p_esl_eu_goods IS NOT NULL
                AND rep_codes.reporting_code_id = p_esl_eu_goods) OR
               (p_esl_eu_services IS NOT NULL
                AND rep_codes.reporting_code_id = p_esl_eu_services) OR
               (p_esl_eu_addl_code1 IS NOT NULL
                AND rep_codes.reporting_code_id = p_esl_eu_addl_code1) OR
               (p_esl_eu_addl_code2 IS NOT NULL
                AND rep_codes.reporting_code_id = p_esl_eu_addl_code2) OR
               (coalesce(p_esl_eu_goods,p_esl_eu_services,
                         p_esl_eu_addl_code1,p_esl_eu_addl_code2,
                         FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR ))
          UNION
          SELECT rep_codes.reporting_code_name, rep_codes.reporting_code_char_value, 3 order_num
          FROM zx_report_codes_assoc rep_assoc,
               zx_reporting_types_b  rep_types,
               zx_reporting_codes_vl rep_codes,
               zx_lines              zxl
          WHERE zxl.tax_line_id = p_tax_line_id
          AND rep_types.reporting_type_id = p_esl_eu_trx_type
          AND rep_types.reporting_type_id = rep_assoc.reporting_type_id
          AND rep_assoc.entity_id = zxl.status_result_id
          AND rep_assoc.entity_code = 'ZX_PROCESS_RESULTS'
          AND zxl.trx_date BETWEEN rep_assoc.effective_from AND
               NVL(rep_assoc.effective_to, zxl.trx_date)
          AND rep_assoc.reporting_code_id = rep_codes.reporting_code_id
          AND ((p_esl_eu_goods IS NOT NULL
                AND rep_codes.reporting_code_id = p_esl_eu_goods) OR
               (p_esl_eu_services IS NOT NULL
                AND rep_codes.reporting_code_id = p_esl_eu_services) OR
               (p_esl_eu_addl_code1 IS NOT NULL
                AND rep_codes.reporting_code_id = p_esl_eu_addl_code1) OR
               (p_esl_eu_addl_code2 IS NOT NULL
                AND rep_codes.reporting_code_id = p_esl_eu_addl_code2) OR
               (coalesce(p_esl_eu_goods,p_esl_eu_services,
                         p_esl_eu_addl_code1,p_esl_eu_addl_code2,
                         FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR ))
         ) v
      WHERE v.reporting_code_name IS NOT NULL
      ORDER BY v.order_num,v.reporting_code_name) v1
    WHERE ROWNUM = 1;

   -- Variables --
   l_trx_date                DATE;
   l_tax_rate_id             NUMBER;
   l_direct_rate_result_id   NUMBER;
   l_rate_result_id          NUMBER;
   l_status_result_id        NUMBER;

   l_rep_code                zx_reporting_codes_b.reporting_code_char_value%type;
   l_rep_name                zx_reporting_codes_tl.reporting_code_name%type;

 BEGIN

   l_rep_name := TO_CHAR(NULL);
   l_rep_code := TO_CHAR(NULL);

   OPEN get_lgl_msg;
   FETCH get_lgl_msg INTO l_rep_name, l_rep_code;
   CLOSE get_lgl_msg;

   IF p_code_or_name = 'CODE' THEN
     RETURN l_rep_code;
   ELSIF p_code_or_name = 'NAME' THEN
     RETURN l_rep_name;
   ELSE
     RETURN l_rep_name;
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN TO_CHAR(NULL);

 END get_vat_transaction_code_name;
/*=========================================================================+
 | PACKAGE Constructor                                                     |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    The constructor initializes the global variables and displays the    |
 |    version of the package in the debug file                             |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |   14-July-99 Nilesh Patel Created                                       |
 |                                                                         |
 +=========================================================================*/

BEGIN
          g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

         IF (g_level_procedure >= g_current_runtime_level ) THEN

             select substr(text,5,70) into l_version_info from user_source
             where  name = 'ZX_EXTRACT_PKG'
             and    text like '%Header:%'
             and    type = 'PACKAGE BODY'
             and    line < 10;

             FND_LOG.STRING(g_level_procedure, 'ZX_EXTRACT_PKG version info :',
                                  l_version_info);
             FND_LOG.STRING(g_level_procedure, 'ZX_EXTRACT_PKG version info :',
                                  'g_current_runtime_level :'||to_char(g_current_runtime_level));
             FND_LOG.STRING(g_level_procedure, 'ZX_EXTRACT_PKG version info :',
                                  'g_level_procedure :'||to_char(g_level_procedure));
             FND_LOG.STRING(g_level_procedure, 'ZX_EXTRACT_PKG version info :',
                                  'g_level_statement :'||to_char(g_level_statement));

         END IF;

         l_version_info := NULL;

         IF (g_level_procedure >= g_current_runtime_level ) THEN

             select substr(text,5,70) into l_version_info from user_source
             where  name = 'ZX_AR_EXTRACT_PKG'
             and    text like '%Header:%'
             and    type = 'PACKAGE BODY'
             and    line < 10;

             FND_LOG.STRING(g_level_procedure, 'ZX_AR_EXTRACT_PKG version info :',
                                  l_version_info);
         END IF;

         l_version_info := NULL;


         IF (g_level_procedure >= g_current_runtime_level ) THEN


            select substr(text,5,70) into l_version_info from user_source
            where  name = 'ZX_AP_EXTRACT_PKG'
            and    text like '%Header:%'
            and    type = 'PACKAGE BODY'
            and    line < 10;

            FND_LOG.STRING(g_level_procedure, 'ZX_AP_EXTRACT_PKG version info :',
                                  l_version_info);
         END IF;

         l_version_info := NULL;

         IF (g_level_procedure >= g_current_runtime_level ) THEN

             select substr(text,5,70) into l_version_info from user_source
             where  name = 'ZX_AR_POPULATE_PKG'
             and    text like '%Header:%'
             and    type = 'PACKAGE BODY'
             and    line < 10;

             FND_LOG.STRING(g_level_procedure, 'ZX_AR_POPULATE_PKG version info :',
                                  l_version_info);
         END IF;

         l_version_info := NULL;

         IF (g_level_procedure >= g_current_runtime_level ) THEN

             select substr(text,5,70) into l_version_info from user_source
             where  name = 'ZX_AP_POPULATE_PKG'
             and    text like '%Header:%'
             and    type = 'PACKAGE BODY'
             and    line < 10;

             FND_LOG.STRING(g_level_procedure, 'ZX_AP_POPULATE_PKG version info :',
                                  l_version_info);
         END IF;

         l_version_info := NULL;

         IF (g_level_procedure >= g_current_runtime_level ) THEN

             select substr(text,5,70) into l_version_info from user_source
             where  name = 'ZX_GL_EXTRACT_PKG'
             and    text like '%Header:%'
             and    type = 'PACKAGE BODY'
             and    line < 10;

             FND_LOG.STRING(g_level_procedure, 'ZX_GL_EXTRACT_PKG version info :',
                                  l_version_info);
         END IF;

         l_version_info := NULL;

--   END;

END ZX_EXTRACT_PKG;

/
