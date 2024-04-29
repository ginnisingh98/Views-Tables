--------------------------------------------------------
--  DDL for Package Body ZX_GL_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_GL_EXTRACT_PKG" AS
/* $Header: zxrigextractpvtb.pls 120.26.12010000.7 2010/01/29 05:20:28 msakalab ship $ */

-----------------------------------------
--Private Variable Declarations
-----------------------------------------
--PG_DEBUG VARCHAR2(1) := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
PG_DEBUG   VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
L_MSG      VARCHAR2(500);

C_LINES_PER_INSERT                 CONSTANT NUMBER :=  1000;

TYPE pr_tax_rec_type is RECORD(
  edr number,
  ecr number,
  eam number,
  adr number,
  acr number,
  aam number,
  tax_group_id number,
  ETAXABLEAM number
);

/*
function prorated_tax(
  p_trx_id in                   number,
  p_ledger_id in          number,
  p_doc_seq_id in               number,
  p_tax_code_id in              number,
  p_code_comb_id in             number,
  p_tax_doc_date in             date,
  p_tax_class in                varchar2,
  p_tax_doc_identifier in       varchar2,
  p_tax_cust_name in            varchar2,
  p_tax_cust_reference in       varchar2,
  p_tax_reg_number in           varchar2,
  p_seq_name in                 varchar2,
  p_column_name in              varchar2);
*/
pr_tax_rec pr_tax_rec_type := NULL;

-----------------------------------------
-- Public Variable Declarations
-----------------------------------------
-- New variables Declaration
GT_APPLICATION_ID             ZX_EXTRACT_PKG.APPLICATION_ID_TBL;
GT_TRX_CLASS_MNG                 ZX_EXTRACT_PKG.TRX_CLASS_MNG_TBL;
GT_TRX_CLASS                  ZX_EXTRACT_PKG.TRX_LINE_CLASS_TBL;
gt_detail_tax_line_id                ZX_EXTRACT_PKG.detail_tax_line_id_tbl;
gt_ledger_id                       zx_extract_pkg.ledger_id_tbl;
gt_trx_id                          zx_extract_pkg.trx_id_tbl;
gt_doc_seq_id                      zx_extract_pkg.doc_seq_id_tbl;
gt_doc_seq_value                   zx_extract_pkg.doc_seq_value_tbl;
gt_doc_seq_name                    zx_extract_pkg.doc_seq_name_tbl;
gt_tax_rate_id                     zx_extract_pkg.tax_rate_id_tbl;
gt_tax_line_id                     zx_extract_pkg.tax_line_id_tbl;
gt_tax_amt                         zx_extract_pkg.tax_amt_tbl;
gt_tax_amt_funcl_curr              zx_extract_pkg.tax_amt_funcl_curr_tbl;
gt_tax_line_number                 zx_extract_pkg.tax_line_number_tbl;
gt_taxable_amt                     zx_extract_pkg.taxable_amt_tbl;
gt_taxable_amt_funcl_curr          zx_extract_pkg.taxable_amt_funcl_curr_tbl;
--gt_checkwithkripa                  zx_extract_pkg.checkwithkripa_tbl;
--gt_xla_code_combination_id         zx_extract_pkg.xla_code_combination_id_tbl;
gt_trx_line_quantity               zx_extract_pkg.trx_line_quantity_tbl;
--gt_xla_period_name                 zx_extract_pkg.xla_period_name_tbl;
gt_trx_number                      zx_extract_pkg.trx_number_tbl;
gt_trx_description                 zx_extract_pkg.trx_description_tbl;
gt_trx_currency_code               zx_extract_pkg.trx_currency_code_tbl;
gt_trx_date                        zx_extract_pkg.trx_date_tbl;
gt_trx_communicated_date           zx_extract_pkg.trx_communicated_date_tbl;
gt_currency_conversion_type        zx_extract_pkg.currency_conversion_type_tbl;
gt_currency_conversion_date        zx_extract_pkg.currency_conversion_date_tbl;
gt_currency_conversion_rate        zx_extract_pkg.currency_conversion_rate_tbl;
gt_tax_line_user_category          zx_extract_pkg.tax_line_user_category_tbl;
gt_tax_line_user_attribute1        zx_extract_pkg.tax_line_user_attribute1_tbl;
gt_tax_line_user_attribute2        zx_extract_pkg.tax_line_user_attribute2_tbl;
gt_tax_line_user_attribute3        zx_extract_pkg.tax_line_user_attribute3_tbl;
gt_tax_line_user_attribute4        zx_extract_pkg.tax_line_user_attribute4_tbl;
gt_tax_line_user_attribute5        zx_extract_pkg.tax_line_user_attribute5_tbl;
gt_tax_line_user_attribute6        zx_extract_pkg.tax_line_user_attribute6_tbl;
gt_tax_line_user_attribute7        zx_extract_pkg.tax_line_user_attribute7_tbl;
gt_tax_line_user_attribute8        zx_extract_pkg.tax_line_user_attribute8_tbl;
gt_tax_line_user_attribute9        zx_extract_pkg.tax_line_user_attribute9_tbl;
gt_tax_line_user_attribute10       zx_extract_pkg.tax_line_user_attribute10_tbl;
gt_tax_line_user_attribute11       zx_extract_pkg.tax_line_user_attribute11_tbl;
gt_tax_line_user_attribute12       zx_extract_pkg.tax_line_user_attribute12_tbl;
gt_tax_line_user_attribute13       zx_extract_pkg.tax_line_user_attribute13_tbl;
gt_tax_line_user_attribute14       zx_extract_pkg.tax_line_user_attribute14_tbl;
gt_tax_line_user_attribute15       zx_extract_pkg.tax_line_user_attribute15_tbl;
gt_billing_tp_name                 zx_extract_pkg.billing_tp_name_tbl;
gt_billing_tp_number  zx_extract_pkg.billing_tp_number_tbl;
gt_billing_tp_tax_reg_num          zx_extract_pkg.billing_tp_tax_reg_num_tbl;
gt_posted_flag                     zx_extract_pkg.posted_flag_tbl;
gt_tax_rate_code                   zx_extract_pkg.tax_rate_code_tbl;
gt_tax_rate_code_description       zx_extract_pkg.tax_rate_code_description_tbl;
gt_tax_rate                        zx_extract_pkg.tax_rate_tbl;
gt_tax_rate_vat_trx_type_code      zx_extract_pkg.tax_rate_vat_trx_type_code_tbl;
gt_tax_type_code         zx_extract_pkg.tax_type_code_tbl;
gt_tax_rate_code_name              zx_extract_pkg.tax_rate_code_name_tbl;
gt_tax_rate_reg_type_code     zx_extract_pkg.tax_rate_reg_type_code_tbl;
gt_tax_regime_code                 zx_extract_pkg.tax_regime_code_tbl;
gt_tax                             zx_extract_pkg.tax_tbl;
gt_tax_jurisdiction_code           zx_extract_pkg.tax_jurisdiction_code_tbl;
gt_tax_status_code                 zx_extract_pkg.tax_status_code_tbl;
gt_tax_currency_code               zx_extract_pkg.tax_currency_code_tbl;
gt_tax_amt_tax_curr                zx_extract_pkg.tax_amt_tax_curr_tbl;
gt_taxable_amt_tax_curr            zx_extract_pkg.taxable_amt_tax_curr_tbl;
gt_orig_taxable_amt                zx_extract_pkg.orig_taxable_amt_tbl;
gt_orig_taxable_amt_tax_curr       zx_extract_pkg.orig_taxable_amt_tax_curr_tbl;
gt_orig_tax_amt                    zx_extract_pkg.orig_tax_amt_tbl;
gt_orig_tax_amt_tax_curr           zx_extract_pkg.orig_tax_amt_tax_curr_tbl;
gt_precision                       zx_extract_pkg.precision_tbl;
gt_minimum_accountable_unit        zx_extract_pkg.minimum_accountable_unit_tbl;
gt_functional_currency_code        zx_extract_pkg.functional_currency_code_tbl;
gt_trx_line_id                     zx_extract_pkg.trx_line_id_tbl;
gt_trx_line_number                 zx_extract_pkg.trx_line_number_tbl;
gt_trx_line_description            zx_extract_pkg.trx_line_description_tbl;
gt_trx_line_type                   zx_extract_pkg.trx_line_type_tbl;
gt_establishment_id                zx_extract_pkg.establishment_id_tbl;
gt_internal_organization_id        zx_extract_pkg.internal_organization_id_tbl;
gt_ledger_name                     zx_extract_pkg.ledger_name_tbl;
gt_extract_source_ledger           zx_extract_pkg.extract_source_ledger_tbl;
gt_doc_event_status                zx_extract_pkg.doc_event_status_tbl;
gt_sub_ledger_inv_identifier    zx_extract_pkg.sub_ledger_inv_identifier_tbl;
GT_TAX_RATE_VAT_TRX_TYPE_DESC    ZX_EXTRACT_PKG.TAX_RATE_VAT_TRX_TYPE_DESC_TBL;
GT_TAX_RATE_VAT_TRX_TYPE_MNG  ZX_EXTRACT_PKG.TAX_RATE_VAT_TRX_TYPE_MNG_TBL;
GT_TAX_TYPE_MNG               ZX_EXTRACT_PKG.TAX_TYPE_MNG_TBL;
GT_TAX_REG_NUM                     ZX_EXTRACT_PKG.HQ_ESTB_REG_NUMBER_TBL;
gt_trx_arap_balancing_segment    zx_extract_pkg.trx_arap_balancing_seg_tbl;
gt_trx_arap_natural_account      zx_extract_pkg.trx_arap_natural_account_tbl;
gt_trx_taxable_bal_seg           zx_extract_pkg.trx_taxable_balancing_seg_tbl;
gt_trx_taxable_natural_account   zx_extract_pkg.trx_taxable_natural_acct_tbl;
gt_trx_tax_balancing_segment     zx_extract_pkg.trx_tax_balancing_seg_tbl;
gt_trx_tax_natural_account       zx_extract_pkg.trx_tax_natural_account_tbl;
gt_period_name                   zx_extract_pkg.period_name_tbl;
gt_actg_line_ccid                zx_extract_pkg.actg_line_ccid_tbl;
gt_account_flexfield             zx_extract_pkg.account_flexfield_tbl;
gt_account_description           zx_extract_pkg.account_description_tbl;
gt_actg_ext_line_id                 zx_extract_pkg.actg_ext_line_id_tbl;
gt_accounting_date          zx_extract_pkg.accounting_date_tbl;

TYPE TRX_TAXABLE_ACCOUNT_DESC_tbl  IS TABLE OF
     ZX_REP_ACTG_EXT_T.TRX_TAXABLE_ACCOUNT_DESC%TYPE INDEX BY BINARY_INTEGER;

TYPE TRX_TAXABLE_BALSEG_DESC_tbl  IS TABLE OF
     ZX_REP_ACTG_EXT_T.TRX_TAXABLE_BALSEG_DESC%TYPE INDEX BY BINARY_INTEGER;

TYPE TRX_TAXABLE_NATACCT_DESC_tbl  IS TABLE OF
     ZX_REP_ACTG_EXT_T.TRX_TAXABLE_NATACCT_SEG_DESC%TYPE INDEX BY BINARY_INTEGER;

    GT_TRX_TAXABLE_ACCOUNT_DESC		TRX_TAXABLE_ACCOUNT_DESC_tbl ; --Bug 5650415
    GT_TRX_TAXABLE_BALSEG_DESC		TRX_TAXABLE_BALSEG_DESC_TBL ;
    GT_TRX_TAXABLE_NATACCT_DESC		TRX_TAXABLE_NATACCT_DESC_tbl ;


    g_created_by                        number(15);
    g_creation_date                     date;
    g_last_updated_by                   number(15);
    g_last_update_date                  date;
    g_last_update_login                 number(15);
    g_program_application_id            number;
    g_program_id                        number;
    g_program_login_id                  number;


G_TAX_CLASS                         VARCHAR2(30);
G_SUMMARY_LEVEL                     VARCHAR2(30);
G_GL_DATE_LOW                       DATE;
G_GL_DATE_HIGH                      DATE;
G_TRX_DATE_LOW                      DATE;
G_TRX_DATE_HIGH                     DATE;
G_TAX_CODE_LOW                      VARCHAR2(30);
G_TAX_CODE_HIGH                     VARCHAR2(30);
G_CURRENCY_CODE_LOW                 VARCHAR2(15);
G_CURRENCY_CODE_HIGH                VARCHAR2(15);
G_POSTING_STATUS                    VARCHAR2(30); -- 5336803
G_TRX_NUMBER                        VARCHAR2(30);
G_TRX_CLASS                         VARCHAR2(30);
G_GBL_TAX_DATE_LOW                  DATE;
G_GBL_TAX_DATE_HIGH                 DATE;
G_TAX_CODE_VAT_TRX_TYPE_LOW         VARCHAR2(60);
G_TAX_CODE_VAT_TRX_TYPE_HIGH        VARCHAR2(60);
G_TAX_CODE_TYPE_LOW                 VARCHAR2(60);
G_TAX_CODE_TYPE_HIGH                VARCHAR2(60);
G_TRADING_PARTNER_TAX_REG_NUM       VARCHAR2(60);
G_TRADING_PARTNER_TAXPAYER_ID       VARCHAR2(30);
G_BALANCING_SEGMENT_LOW             VARCHAR2(30); --5336803
G_BALANCING_SEGMENT_HIGH            VARCHAR2(30); --5336803
G_REQUEST_ID                        NUMBER;
g_legal_entity_id                   NUMBER;
G_GDF_GL_JE_LINES_CATEGORY          VARCHAR2(150);
G_GDF_GL_JE_LINES_ATT3              VARCHAR2(150);
G_GDF_GL_JE_LINES_ATT3_IS_NULL      VARCHAR2(30); --5336803
G_INCLUDE_GL_MANUAL_LINES           VARCHAR2(30);--5336803
G_CHART_OF_ACCOUNTS_ID              NUMBER(15);
G_REP_CONTEXT_ID           NUMBER;
G_LEDGER_ID                  NUMBER;
g_ledger_name                     varchar2(30);
g_tax_register_type_mng           VARCHAR2(80);
g_fun_currency_code                varchar2(15);
G_EXTRACT_LINE_NUM                 NUMBER := 1;
g_tax_jurisdiction_code             VARCHAR2(30);
--g_first_party_tax_reg_num           VARCHAR2(30);
G_TAX_REGIME_CODE                VARCHAR2(30);
G_TAX                            VARCHAR2(30);
G_TAX_STATUS_CODE                VARCHAR2(30);
G_TAX_RATE_CODE_LOW                 VARCHAR2(30);
G_TAX_RATE_CODE_HIGH                        VARCHAR2(30);
G_TAX_TYPE_CODE_LOW                 VARCHAR2(30);
G_TAX_TYPE_CODE_HIGH                VARCHAR2(30);
G_TAX_INVOICE_DATE_LOW           VARCHAR2(30);
G_TAX_INVOICE_DATE_HIGH          VARCHAR2(30);
G_VAT_TRANSACTION_TYPE_CODE            varchar2(30);
G_GL_RETCODE  NUMBER :=0;
G_TRX_NUMBER_LOW                 VARCHAR2(30);
G_TRX_NUMBER_HIGH                VARCHAR2(30);
L_COLUMN_LIST_GL                VARCHAR2(8000);
L_TABLE_LIST_GL                 VARCHAR2(4000);
L_WHERE_CLAUSE_GL               VARCHAR2(4000);

 C_LINES_PER_COMMIT CONSTANT NUMBER := 5000;

  g_current_runtime_level           NUMBER;
  g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
  g_error_buffer                  VARCHAR2(100);

  G_INCLUDE_ACCOUNTING_SEGMENTS   VARCHAR2(1);
  G_GL_OR_TRX_DATE_FILTER         VARCHAR2(1);--BugFix5347188

-----------------------------------------
--Private Methods Declarations
-----------------------------------------
PROCEDURE INSERT_GL_SUB_ITF;
PROCEDURE FETCH_GL_TRX_INFO;
PROCEDURE ASSIGN_GL_GLOBAL_VARIABLES (
    P_TRL_GLOBAL_VARIABLES_REC  IN ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
);

PROCEDURE BUILD_SQL;

PROCEDURE INIT_GL_GT_TABLES;

PROCEDURE populate_tax_reg_num(
          P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
          P_TAX                       IN zx_rates_vl.tax%TYPE,
          P_TAX_REGIME_CODE                IN zx_rates_vl.tax_regime_code%TYPE,
          P_TAX_JURISDICTION_CODE          IN zx_rates_vl.tax_jurisdiction_code%TYPE,
          i IN BINARY_INTEGER);

PROCEDURE GET_ACCOUNTING_SEGMENTS (
    P_TRX_ID                            IN NUMBER,
    P_TAX_CODE_ID                       IN NUMBER,
    P_BALANCING_SEGMENT                 IN VARCHAR2,
    P_ACCOUNTING_SEGMENT                IN VARCHAR2,
    P_CHART_OF_ACCOUNTS_ID		IN NUMBER,
    P_TRX_ARAP_BALANCING_SEGMENT        OUT NOCOPY VARCHAR2,
    P_TRX_ARAP_NATURAL_ACCOUNT          OUT NOCOPY VARCHAR2,
    P_TRX_TAXABLE_BAL_SEG               OUT NOCOPY VARCHAR2,
    P_TRX_TAXABLE_NATURAL_ACCOUNT       OUT NOCOPY VARCHAR2,
    P_TRX_TAX_BALANCING_SEGMENT         OUT NOCOPY VARCHAR2,
    P_TRX_TAX_NATURAL_ACCOUNT           OUT NOCOPY VARCHAR2,
    P_TRX_TAXABLE_BALSEG_DESC		OUT NOCOPY VARCHAR2,
    P_TRX_TAXABLE_NATACCT_DESC		OUT NOCOPY varchar2
);

/*===========================================================================+
 | FUNCTION                                                                  |
 |   ASSIGN_GLOBAL_VARIABLES_GL                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Assign the global variable to the the output parameters.               |
 |    This procedure is used by AR procedures to get the global              |
 |    variable  values from Main package.                                    |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE ASSIGN_GL_GLOBAL_VARIABLES (
  P_TRL_GLOBAL_VARIABLES_REC  IN ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
) IS

BEGIN

   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.ASSIGN_GL_GLOBAL_VARIABLES.BEGIN',
                                      'ZX_GL_EXTRACT_PKG: ASSIGN_GL_GLOBAL_VARIABLES(+)');
    END IF;
  g_legal_entity_id              :=  P_TRL_GLOBAL_VARIABLES_REC.LEGAL_ENTITY_ID;
  G_REQUEST_ID                   :=  P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;
--  G_CHART_OF_ACCOUNTS_ID         :=  P_TRL_GLOBAL_VARIABLES_REC.CHART_OF_ACCOUNTS_ID;
--  G_REP_CONTEXT_ID      :=  P_TRL_GLOBAL_VARIABLES_REC.REP_CONTEXT_ID;
 -- G_TAX_CLASS                    :=  P_TRL_GLOBAL_VARIABLES_REC.TAX_CLASS;
  G_SUMMARY_LEVEL                :=  P_TRL_GLOBAL_VARIABLES_REC.SUMMARY_LEVEL;
  G_GL_DATE_LOW                  :=  P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_LOW;
  G_GL_DATE_HIGH                 :=  P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH;
  G_TRX_DATE_LOW                 :=  P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_LOW;
  G_TRX_DATE_HIGH                :=  P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_HIGH;
  G_CURRENCY_CODE_LOW            :=  P_TRL_GLOBAL_VARIABLES_REC.CURRENCY_CODE_LOW;
  G_CURRENCY_CODE_HIGH           :=  P_TRL_GLOBAL_VARIABLES_REC.CURRENCY_CODE_HIGH;
  G_POSTING_STATUS               :=  P_TRL_GLOBAL_VARIABLES_REC.POSTING_STATUS;
--  G_TRX_NUMBER                   :=  P_TRL_GLOBAL_VARIABLES_REC.TRX_NUMBER;
  --G_TRX_CLASS                    :=  P_TRL_GLOBAL_VARIABLES_REC.TRX_CLASS;
 -- G_GBL_TAX_DATE_LOW             :=  P_TRL_GLOBAL_VARIABLES_REC.GBL_TAX_DATE_LOW;
 -- G_GBL_TAX_DATE_HIGH            :=  P_TRL_GLOBAL_VARIABLES_REC.GBL_TAX_DATE_HIGH;
  G_VAT_TRANSACTION_TYPE_CODE   :=  P_TRL_GLOBAL_VARIABLES_REC.VAT_TRANSACTION_TYPE_CODE;
--  G_TAX_CODE_VAT_TRX_TYPE_HIGH   :=  P_TRL_GLOBAL_VARIABLES_REC.TAX_CODE_VAT_TRX_TYPE_HIGH;
 -- G_TAX_CODE_TYPE_LOW            :=  P_TRL_GLOBAL_VARIABLES_REC.TAX_CODE_TYPE_LOW;
 -- G_TAX_CODE_TYPE_HIGH           :=  P_TRL_GLOBAL_VARIABLES_REC.TAX_CODE_TYPE_HIGH;
 -- G_TRADING_PARTNER_TAX_REG_NUM  :=  P_TRL_GLOBAL_VARIABLES_REC.TRADING_PARTNER_TAX_REG_NUM;
 -- G_TRADING_PARTNER_TAXPAYER_ID  :=  P_TRL_GLOBAL_VARIABLES_REC.TRADING_PARTNER_TAXPAYER_ID;
  G_BALANCING_SEGMENT_LOW        :=  P_TRL_GLOBAL_VARIABLES_REC.BALANCING_SEGMENT_LOW;
  G_BALANCING_SEGMENT_HIGH       :=  P_TRL_GLOBAL_VARIABLES_REC.BALANCING_SEGMENT_HIGH;
  G_LEDGER_ID              :=  P_TRL_GLOBAL_VARIABLES_REC.LEDGER_ID;
  G_INCLUDE_GL_MANUAL_LINES      :=  P_TRL_GLOBAL_VARIABLES_REC.INCLUDE_GL_MANUAL_LINES;
  G_GDF_GL_JE_LINES_CATEGORY     :=  P_TRL_GLOBAL_VARIABLES_REC.GDF_GL_JE_LINES_CATEGORY;
  G_GDF_GL_JE_LINES_ATT3         :=  P_TRL_GLOBAL_VARIABLES_REC.GDF_GL_JE_LINES_ATT3;
  G_GDF_GL_JE_LINES_ATT3_IS_NULL :=  P_TRL_GLOBAL_VARIABLES_REC.GDF_GL_JE_LINES_ATT3_IS_NULL;
 -- G_EXTRACT_LINE_NUM             :=  P_TRL_GLOBAL_VARIABLES_REC.EXTRACT_LINE_NUM;
g_tax_jurisdiction_code         :=      p_trl_global_variables_rec.tax_jurisdiction_code;
--g_first_party_tax_reg_num       :=      p_trl_global_variables_rec.first_party_tax_reg_num;
 G_TAX_REGIME_CODE               :=      P_TRL_GLOBAL_VARIABLES_REC.TAX_REGIME_CODE;
G_TAX                           :=      P_TRL_GLOBAL_VARIABLES_REC.TAX;
G_TAX_STATUS_CODE               :=      P_TRL_GLOBAL_VARIABLES_REC.TAX_STATUS_CODE;
G_TAX_RATE_CODE_LOW             :=      p_trl_global_variables_rec.tax_rate_code_low;
G_TAX_RATE_CODE_HIGH            :=      p_trl_global_variables_rec.tax_rate_code_high;
G_TAX_TYPE_CODE_LOW             :=      p_trl_global_variables_rec.tax_type_code_low;
G_TAX_TYPE_CODE_HIGH            :=      p_trl_global_variables_rec.tax_type_code_high;
--G_TAX_RATE_CODE                 :=      P_TRL_GLOBAL_VARIABLES_REC.TAX_RATE_CODE;
--G_TAX_TYPE_CODE                 :=      P_TRL_GLOBAL_VARIABLES_REC.TAX_TYPE_CODE;
G_TAX_INVOICE_DATE_LOW          :=      P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_LOW;
G_TAX_INVOICE_DATE_HIGH         :=      P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_HIGH;
G_TRX_NUMBER_LOW                :=      P_TRL_GLOBAL_VARIABLES_REC.TRX_NUMBER_LOW;
G_TRX_NUMBER_HIGH               :=      P_TRL_GLOBAL_VARIABLES_REC.TRX_NUMBER_HIGH;
G_LEDGER_NAME                   :=      P_TRL_GLOBAL_VARIABLES_REC.LEDGER_NAME;
G_FUN_CURRENCY_CODE             :=      P_TRL_GLOBAL_VARIABLES_REC.FUNC_CURRENCY_CODE;
g_tax_register_type_mng         :=      'Tax Register';
g_include_accounting_segments   := p_trl_global_variables_rec.include_accounting_segments;
G_GL_OR_TRX_DATE_FILTER         := P_TRL_GLOBAL_VARIABLES_REC.GL_OR_TRX_DATE_FILTER;--BugFix:5347188


   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.ASSIGN_GL_GLOBAL_VARIABLES.END',
                                      'ZX_GL_EXTRACT_PKG: ASSIGN_GL_GLOBAL_VARIABLES(-)');
    END IF;

END ASSIGN_GL_GLOBAL_VARIABLES;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   INSERT_TAX_DATA                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure takes the input parameters from ZX_EXTRACT_PKG         |
 |    and builds  dynamic SQL statement clauses based on the parameters,     |
 |    supplies them as output parameters.                                    |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   18-Aug-99  Nilesh Patel, created                                        |
 |                                                                           |
 +===========================================================================*/

PROCEDURE INSERT_TAX_DATA (
  P_TRL_GLOBAL_VARIABLES_REC IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
) IS
BEGIN

     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.INSERT_TAX_DATA.BEGIN',
                                      'ZX_GL_EXTRACT_PKG: INSERT_TAX_DATA(+)');
    END IF;

  ASSIGN_GL_GLOBAL_VARIABLES(
    P_TRL_GLOBAL_VARIABLES_REC => P_TRL_GLOBAL_VARIABLES_REC
  );

--  IF G_GL_RETCODE <> 2 THEN
    BUILD_SQL;
--  END IF;
--  IF G_GL_RETCODE <> 2 THEN
    FETCH_GL_TRX_INFO;
--  END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.INSERT_TAX_DATA.END',
                                      'ZX_GL_EXTRACT_PKG: INSERT_TAX_DATA(+)');
    END IF;

  -- assign the output global variable
--  P_TRL_GLOBAL_VARIABLES_REC.EXTRACT_LINE_NUM := G_EXTRACT_LINE_NUM;
--    P_TRL_GLOBAL_VARIABLES_REC.RETCODE := 2;

END INSERT_TAX_DATA;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   build_sql                                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure takes the input parameters from ZX_EXTRACT_PKG         |
 |    and builds  dynamic SQL statement clauses based on the parameters,     |
 |    supplies them as output parameters.                                    |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   18-Aug-99  Nilesh Patel, created                                        |
 |                                                                           |
 +===========================================================================*/


PROCEDURE BUILD_SQL
IS

L_WHERE_GBL_TAX_DATE            varchar2(200);
L_WHERE_GL_DATE                 varchar2(200);
L_WHERE_TRX_DATE                varchar2(200);
L_WHERE_GL_OR_TRX_DATE          varchar2(200);--BugFix5347188
L_WHERE_TAX_CODE                varchar2(200);
--L_WHERE_CURRENCY_CODE           varchar2(200);
L_WHERE_POSTING_STATUS          varchar2(200);
L_WHERE_TAX_CODE_TYPE           varchar2(200);
L_WHERE_CHART_OF_ACCOUNTS_ID    varchar2(200);
L_WHERE_LEDGER_ID         VARCHAR2(200);
L_CHART_OF_ACCOUNTS_ID          number(15);
L_WHERE_TRX_CLASS_GL            varchar2(200);
L_WHERE_TAX_CODE_VAT_TRX_TYPE   varchar2(200);
L_WHERE_TP_TAX_REG_NUM          varchar2(200);
L_WHERE_TP_TAXPAYER_ID          varchar2(200);
L_WHERE_GL_FLEX                 varchar2(2000);
L_WHERE_TAX_CLASS               VARCHAR2(240);
L_WHERE_TRX_NUMBER_GL           VARCHAR2(240);
L_WHERE_GL_LINES_ATT3_IS_NULL  VARCHAR2(500);
L_WHERE_TAX_JURISDICTION_CODE     varchar2(1000);
--L_WHERE_FIRST_PTY_TAX_REG_NUM      varchar2(1000);
L_WHERE_TAX_REGIME_CODE        varchar2(500);
L_WHERE_TAX        varchar2(500);
L_WHERE_TAX_STATUS_CODE        varchar2(500);
L_WHERE_TAX_RATE_CODE        varchar2(500);
L_WHERE_TAX_TYPE_CODE        varchar2(500);
L_WHERE_CURRENCY_CODE        varchar2(500);
L_WHERE_TAX_INVOICE_DATE        varchar2(500);
L_WHERE_GL_FLEX_LE             VARCHAR2(2000);
l_bal_value      boolean;
l_bsv_flag       varchar2(1);
l_bsv_list     gl_mc_info.le_bsv_tbl_type;
l_bsv_in       varchar2(300);
l_bsv          varchar2(100);
l_count        number;
BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.BUILD_SQL.BEGIN',
                                      'ZX_GL_EXTRACT_PKG: BUILD_SQL(+)');
    END IF;

-- New Where Clause Predicates :


    --BugFix:5347188
    IF G_GL_DATE_LOW IS NOT NULL AND G_GL_DATE_HIGH IS NOT NULL THEN
            L_WHERE_GL_DATE :=
                     ' GJH.DEFAULT_EFFECTIVE_DATE BETWEEN :G_GL_DATE_LOW AND :G_GL_DATE_HIGH ';
    ELSIF G_GL_DATE_LOW IS NULL AND G_GL_DATE_HIGH IS NULL THEN
            L_WHERE_GL_DATE :=  ' DECODE(:G_GL_DATE_LOW,NULL,NULL) IS NULL AND decode(:G_GL_DATE_HIGH,NULL,NULL) IS NULL ';
    ELSIF G_GL_DATE_LOW IS NULL AND G_GL_DATE_HIGH IS NOT NULL THEN
            L_WHERE_GL_DATE :=  ' DECODE(:G_GL_DATE_LOW, NULL,NULL) IS NULL  AND GJH.DEFAULT_EFFECTIVE_DATE  <= :G_GL_DATE_HIGH ';
    ELSE
            L_WHERE_GL_DATE :=  ' GJH.DEFAULT_EFFECTIVE_DATE >= :G_GL_DATE_LOW AND DECODE(:G_GL_DATE_HIGH, NULL,NULL) IS NULL ';
    END IF;


    --BugFix:5347188
    IF G_TRX_DATE_LOW IS NOT NULL AND G_TRX_DATE_HIGH IS NOT NULL THEN
            L_WHERE_TRX_DATE   :=
                             ' GJL1.TAX_DOCUMENT_DATE BETWEEN :G_TRX_DATE_LOW AND :G_TRX_DATE_HIGH ';

    ELSIF G_TRX_DATE_LOW IS NULL AND G_TRX_DATE_HIGH IS NULL THEN
            L_WHERE_TRX_DATE   := ' DECODE(:G_TRX_DATE_LOW,NULL,NULL) IS NULL AND DECODE(:G_TRX_DATE_HIGH,NULL,NULL) IS NULL ';
    ELSIF G_TRX_DATE_LOW IS NULL AND G_TRX_DATE_HIGH IS NOT NULL THEN
            L_WHERE_TRX_DATE   := ' DECODE(:G_TRX_DATE_LOW,NULL,NULL) IS NULL AND GJL1.TAX_DOCUMENT_DATE  <= :G_TRX_DATE_HIGH ';
    ELSE
            L_WHERE_TRX_DATE   := ' GJL1.TAX_DOCUMENT_DATE >= :G_TRX_DATE_LOW AND DECODE(:G_TRX_DATE_HIGH,NULL,NULL) IS NULL ';
    END IF;

    --BugFix:5347188
    IF G_GL_OR_TRX_DATE_FILTER = 'Y' THEN
      L_WHERE_GL_OR_TRX_DATE := ' AND ( ( '||L_WHERE_GL_DATE||' ) OR ('||L_WHERE_TRX_DATE||')) ';
      L_WHERE_GL_DATE        := ' ';
      L_WHERE_TRX_DATE       := ' ';
    ELSE
      L_WHERE_GL_DATE        := ' AND '||L_WHERE_GL_DATE;
      L_WHERE_TRX_DATE       := ' AND '||L_WHERE_TRX_DATE;
      L_WHERE_GL_OR_TRX_DATE := ' ';
    END IF;


-- New Parameters
--    IF g_first_party_tax_reg_num IS NOT NULL THEN
 --      L_WHERE_FIRST_PTY_TAX_REG_NUM := ' AND ptp.rep_registration_number = :g_first_party_tax_reg_num ';
  --  ELSE
   --    L_WHERE_FIRST_PTY_TAX_REG_NUM :=  ' AND DECODE(:g_first_party_tax_reg_num,NULL,NULL) IS NULL ';
--    END IF;

    IF g_tax_jurisdiction_code IS NOT NULL THEN
       L_WHERE_TAX_JURISDICTION_CODE := ' AND ZX_RATE.TAX_JURISDICTION_CODE = :g_tax_jurisdiction_code ';
    ELSE
       L_WHERE_TAX_JURISDICTION_CODE := ' AND DECODE(:g_tax_jurisdiction_code,NULL,NULL) IS NULL ';
    END IF;

  IF G_TAX_REGIME_CODE IS NOT NULL THEN
      L_WHERE_TAX_REGIME_CODE := ' AND ZX_RATE.TAX_REGIME_CODE = :G_TAX_REGIME_CODE ';
   ELSE
      L_WHERE_TAX_REGIME_CODE := ' AND DECODE(:G_TAX_REGIME_CODE,NULL,NULL) IS NULL ';
   END IF;

   IF G_TAX IS NOT NULL THEN
      L_WHERE_TAX := ' AND ZX_RATE.TAX = :G_TAX ';
   ELSE
      L_WHERE_TAX := ' AND DECODE(:G_TAX,NULL,NULL) IS NULL ';
   END IF;

  IF G_TAX_STATUS_CODE IS NOT NULL THEN
      L_WHERE_TAX_STATUS_CODE := ' AND ZX_RATE.TAX_STATUS_CODE = :G_TAX_STATUS_CODE ';
   ELSE
      L_WHERE_TAX_STATUS_CODE := ' AND DECODE(:G_TAX_STATUS_CODE,NULL,NULL) IS NULL ';
   END IF;

    IF g_tax_rate_code_low IS NOT NULL AND g_tax_rate_code_high IS NOT NULL THEN
       L_WHERE_TAX_RATE_CODE := ' AND ZX_RATE.TAX_RATE_CODE BETWEEN :G_TAX_RATE_CODE_LOW AND :G_TAX_RATE_CODE_HIGH ';
    ELSE
       L_WHERE_TAX_RATE_CODE := ' AND DECODE(:G_TAX_RATE_CODE_LOW,NULL,NULL) IS NULL '||
                                ' AND DECODE(:G_TAX_RATE_CODE_HIGH,NULL,NULL) IS NULL ';
    END IF;

    IF g_tax_type_code_low IS NOT NULL AND g_tax_type_code_high IS NOT NULL THEN
       --L_WHERE_TAX_TYPE_CODE := ' AND ZX_RATE.TAX_TYPE_CODE BETWEEN :G_TAX_TYPE_CODE_LOW AND :G_TAX_TYPE_CODE_HIGH ';
         L_WHERE_TAX_TYPE_CODE := ' AND ZX_TAX.TAX_TYPE_CODE BETWEEN :G_TAX_TYPE_CODE_LOW AND :G_TAX_TYPE_CODE_HIGH ';  -- bug#7230760
    ELSE
       L_WHERE_TAX_TYPE_CODE := ' AND DECODE(:G_TAX_TYPE_CODE_LOW,NULL,NULL) IS NULL '||
                                  ' AND DECODE(:G_TAX_TYPE_CODE_HIGH,NULL,NULL) IS NULL ';
    END IF;

/*   IF G_TAX_RATE_CODE IS NOT NULL THEN
      L_WHERE_TAX_RATE_CODE := ' AND ZX_RATE.TAX_RATE_CODE = :G_TAX_RATE_CODE ';
   ELSE
      L_WHERE_TAX_RATE_CODE := ' AND DECODE(:G_TAX_RATE_CODE,NULL,NULL) IS NULL ';
   END IF;

   IF G_TAX_TYPE_CODE IS NOT NULL THEN
      L_WHERE_TAX_TYPE_CODE := ' AND ZX_RATE.TAX_TYPE_CODE = :G_TAX_TYPE_CODE ';
   ELSE
      L_WHERE_TAX_TYPE_CODE := ' AND DECODE(:G_TAX_TYPE_CODE,NULL,NULL) IS NULL ';
   END IF;
*/

--  L_WHERE_CURRENCY_CODE

    IF    G_CURRENCY_CODE_LOW IS NOT NULL
      AND G_CURRENCY_CODE_HIGH IS NOT NULL
    THEN
           L_WHERE_CURRENCY_CODE := ' AND GJH.CURRENCY_CODE BETWEEN :G_CURRENCY_CODE_LOW AND :G_CURRENCY_CODE_HIGH ';
    ELSE
           L_WHERE_CURRENCY_CODE := ' AND DECODE(:G_CURRENCY_CODE_LOW,NULL,NULL) IS NULL AND DECODE(:G_CURRENCY_CODE_HIGH,NULL,NULL) IS NULL ';
    END IF;

--  L_WHERE_POSTING_STATUS
    IF  G_POSTING_STATUS = 'POSTED' THEN
          L_WHERE_POSTING_STATUS := ' AND GJH.POSTED_DATE IS NOT NULL ';
    ELSIF G_POSTING_STATUS = 'UNPOSTED' THEN
          L_WHERE_POSTING_STATUS := ' AND GJH.POSTED_DATE IS NULL ';
    ELSE
          L_WHERE_POSTING_STATUS := ' AND 1 = 1 ';
    END IF;


  IF G_VAT_TRANSACTION_TYPE_CODE IS NOT NULL
  THEN
    L_WHERE_TAX_CODE_VAT_TRX_TYPE   :=
    ' AND ZX_RATE.VAT_TRANSACTION_TYPE_CODE  = :G_VAT_TRANSACTION_TYPE_CODE ';
  ELSE
    L_WHERE_TAX_CODE_VAT_TRX_TYPE  := ' AND DECODE(:G_VAT_TRANSACTION_TYPE_CODE,NULL,NULL) IS NULL ';
  END IF;


-- New paraneter code
      IF G_TRX_NUMBER_LOW IS NOT NULL AND G_TRX_NUMBER_HIGH IS NOT NULL THEN
         L_WHERE_TRX_NUMBER_GL :=
           'AND GJL1.TAX_DOCUMENT_IDENTIFIER BETWEEN :G_TRX_NUMBER_LOW AND :G_TRX_NUMBER_HIGH ';
      ELSE
        L_WHERE_TRX_NUMBER_GL :=
          ' AND DECODE(:G_TRX_NUMBER_LOW,NULL,NULL) IS NULL AND DECODE(:G_TRX_NUMBER_HIGH,NULL,NULL) IS NULL ';
     END IF;

--  L_WHERE_TRADING_PARTNER_TAX_REG_NUM

    IF  G_TRADING_PARTNER_TAX_REG_NUM IS NOT NULL
    THEN
        L_WHERE_TP_TAX_REG_NUM :=
                ' AND GJL1.TAX_REGISTRATION_NUMBER  =  :G_TRADING_PARTNER_TAX_REG_NUM';
    ELSE
               L_WHERE_TP_TAX_REG_NUM := ' AND DECODE(:G_TRADING_PARTNER_TAX_REG_NUM,NULL,NULL) IS NULL';
    END IF;
    IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('L_WHERE_TP_TAX_REG_NUM = '||
                          L_WHERE_TP_TAX_REG_NUM );
    END IF;

 --   L_WHERE_TRADING_PARTNER_TAXPAYER_ID

     IF G_TRADING_PARTNER_TAXPAYER_ID IS NOT NULL THEN
         L_WHERE_TP_TAXPAYER_ID :=
                  ' AND GJL1.TAX_CUSTOMER_REFERENCE  =  :G_TRADING_PARTNER_TAXPAYER_ID';
     else
        L_WHERE_TP_TAXPAYER_ID := ' AND DECODE(:G_TRADING_PARTNER_TAXPAYER_ID,NULL,NULL) IS NULL ';
     END IF;

   /*Bug Fix 5119565 */
    IF G_TAX_INVOICE_DATE_LOW IS NOT NULL AND G_TAX_INVOICE_DATE_HIGH IS NOT NULL THEN
        L_WHERE_TAX_INVOICE_DATE := ' AND gjl1.TAX_DOCUMENT_DATE BETWEEN :G_TAX_INVOICE_DATE_LOW AND :G_TAX_INVOICE_DATE_HIGH ';
      ELSIF G_TAX_INVOICE_DATE_LOW IS NULL AND G_TAX_INVOICE_DATE_HIGH IS NULL THEN
	 L_WHERE_TAX_INVOICE_DATE := ' AND :G_TAX_INVOICE_DATE_LOW IS NULL AND :G_TAX_INVOICE_DATE_HIGH IS NULL ';
        ELSIF G_TAX_INVOICE_DATE_LOW IS NOT NULL AND G_TAX_INVOICE_DATE_HIGH IS NULL THEN
	   L_WHERE_TAX_INVOICE_DATE := ' AND gjl1.TAX_DOCUMENT_DATE >=  :G_TAX_INVOICE_DATE_LOW AND :G_TAX_INVOICE_DATE_HIGH IS NULL ';
          ELSE
             L_WHERE_TAX_INVOICE_DATE := ' AND :G_TAX_INVOICE_DATE_LOW IS NULL AND gjl1.TAX_DOCUMENT_DATE  <= :G_TAX_INVOICE_DATE_HIGH ';
            END IF;
       IF G_INCLUDE_GL_MANUAL_LINES IS NOT NULL THEN
		IF G_INCLUDE_GL_MANUAL_LINES = 'N' THEN
		   L_WHERE_TRX_CLASS_GL := ' AND GJH.JE_SOURCE <> ''Manual'' ';
		ELSE
		   L_WHERE_TRX_CLASS_GL := ' AND 1 = 1 ';
		END IF;
	ELSE
		L_WHERE_TRX_CLASS_GL := 'AND  1 = 1 ';
       END IF;
--      L_WHERE_GL_FLEX
--      Get the SEGMENT_NUMBER of the Balancing Segment of the
--      Chart_of_accounts_id  associated with the user's set of books.
--      Get the chart of accounts id

--     IF G_BALANCING_SEGMENT_LOW IS NOT NULL AND
--        G_BALANCING_SEGMENT_HIGH IS NOT NULL THEN
                SELECT CHART_OF_ACCOUNTS_ID
                INTO   L_CHART_OF_ACCOUNTS_ID
                FROM   GL_SETS_OF_BOOKS
                WHERE  SET_OF_BOOKS_ID = FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');

--      Build the where clause for restricting the data to the
--      balancing segments specified.
--      L_WHERE_GL_FLEX'

             L_WHERE_GL_FLEX :=
                  FA_RX_FLEX_PKG.FLEX_SQL(
                  P_APPLICATION_ID => 101,
                  P_ID_FLEX_CODE => 'GL#',
                  P_ID_FLEX_NUM => L_CHART_OF_ACCOUNTS_ID,
                  P_TABLE_ALIAS => 'GCC2',
                  P_MODE => 'WHERE',
                  P_QUALIFIER =>'GL_BALANCING',
                  P_FUNCTION => 'BETWEEN',
                  P_OPERAND1 => G_BALANCING_SEGMENT_LOW,
                  P_OPERAND2 => G_BALANCING_SEGMENT_HIGH );

             L_WHERE_GL_FLEX := ' AND '||L_WHERE_GL_FLEX||' ';
          IF PG_DEBUG = 'Y' THEN
                arp_util_tax.debug('L_WHERE_GL_FLEX = '||L_WHERE_GL_FLEX);
          END IF;
 --      END IF;
--AND GCC2.SEGMENT1 BETWEEN '' AND ''

    l_count := 0;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.BUILD_SQL',
                                      'L_WHERE_GL_FLEX = '||L_WHERE_GL_FLEX);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.BUILD_SQL',
                                      'L_WHERE_GL_FLEX : Call to gl_mc_info.get_bal_seg_values');
    END IF;

    -- For Legal Entity Level build predicate for blancing segments criteria

   IF g_legal_entity_id IS NOT NULL THEN
      l_bsv_list := gl_mc_info.le_bsv_tbl_type();
      l_bal_value :=gl_mc_info.get_bal_seg_values(NULL,g_legal_entity_id,NULL,l_bsv_flag, l_bsv_list);
      l_count := l_bsv_list.count;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.BUILD_SQL',
             'L_WHERE_GL_FLEX : After Call to gl_mc_info.get_bal_seg_values'||to_char(l_count)||l_bsv_flag);
      END IF;

      IF l_count > 0 THEN
         L_WHERE_GL_FLEX_LE := substr(L_WHERE_GL_FLEX,1,18);
         L_WHERE_GL_FLEX := L_WHERE_GL_FLEX_LE;
         L_WHERE_GL_FLEX := L_WHERE_GL_FLEX||' IN '||'('||'''';
      END If;

      FOR i IN 1..l_count LOOP
          L_WHERE_GL_FLEX := L_WHERE_GL_FLEX||l_bsv_list(i).bal_seg_value||'''';
          if i < l_count then
             L_WHERE_GL_FLEX := L_WHERE_GL_FLEX||',''';
          end if;
     --  l_bsv_in := l_bsv_in||'''||l_bsv||''
          IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.BUILD_SQL',
                                      'L_WHERE_GL_FLEX :'||L_WHERE_GL_FLEX);
          END IF;

      END LOOP;

       L_WHERE_GL_FLEX := L_WHERE_GL_FLEX||' )';
       IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.BUILD_SQL',
                                      'L_WHERE_GL_FLEX : After Call to gl_mc_info.get_bal_seg_values');
       END IF;

      IF l_bal_value then
         IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.BUILD_SQL',
                                      'L_WHERE_GL_FLEX : bal value ');
         END IF;
      END IF;
   END IF; -- g_legal_entity_id ---

/*   IF l_count > 0 THEN
       l_bsv := l_bsv_list(1).bal_seg_value;
       L_WHERE_GL_FLEX_LE := substr(L_WHERE_GL_FLEX,1,18);
       L_WHERE_GL_FLEX_LE := L_WHERE_GL_FLEX_LE ||'IN'||l_bsv_in||')';
       L_WHERE_GL_FLEX := L_WHERE_GL_FLEX_LE ||l_bsv;
   END If;  */

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.BUILD_SQL',
                                      'L_WHERE_GL_FLEX : '||L_WHERE_GL_FLEX);
    END IF;

--  Bugfix 3027941

 IF G_GDF_GL_JE_LINES_ATT3_IS_NULL = 'Y' THEN
       L_WHERE_GL_LINES_ATT3_IS_NULL :=
                                 ' AND decode(:G_GDF_GL_JE_LINES_CATEGORY,NULL,NULL) is null and decode (:G_GDF_GL_JE_LINES_ATT3,NULL,NULL) is null and GJL1.GLOBAL_ATTRIBUTE3 IS NULL';
 ELSIF G_GDF_GL_JE_LINES_ATT3_IS_NULL = 'N' THEN
       L_WHERE_GL_LINES_ATT3_IS_NULL := ' AND GJL1.GLOBAL_ATTRIBUTE_CATEGORY = :G_GDF_GL_JE_LINES_CATEGORY AND  GJL1.GLOBAL_ATTRIBUTE3 = :G_GDF_GL_JE_LINES_ATT3 ';

 ELSE
       L_WHERE_GL_LINES_ATT3_IS_NULL := ' AND decode(:G_GDF_GL_JE_LINES_CATEGORY,NULL,NULL) is null and decode (:G_GDF_GL_JE_LINES_ATT3,NULL,NULL) is null ';
 END IF;

 IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('L_WHERE_GL_LINES_ATT3_IS_NULL = ' || L_WHERE_GL_LINES_ATT3_IS_NULL );
 END IF;



  IF G_SUMMARY_LEVEL = 'TRANSACTION' THEN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.BUILD_SQL',
                                      'ZX_GL_EXTRACT_PKG: SQL-1');
    END IF;

--New Dyanamic SQL
  l_column_list_gl :=
  ' SELECT
          gjh.ledger_id,
          gjh.je_header_id,
          gjh.doc_sequence_id,
          gjh.doc_sequence_value,
          seq.name,
          gjl1.tax_code_id,
          to_number(NULL),   --tax line id
          decode(gjl1.tax_type_code,''I'',-1,1) *
          ZX_GL_EXTRACT_PKG.prorated_tax(
                          gjh.je_header_id,
                          gjh.ledger_id,
                          gjh.doc_sequence_id,
                          gjl1.tax_code_id,
                          gjl2.code_combination_id,
                          gjl1.tax_document_date,
                          gjl1.tax_type_code,--zx_rate.tax_class, --Bug 5338150
                          gjl1.tax_document_identifier,
                          gjl1.tax_customer_name,
                          gjl1.tax_customer_reference,
                          gjl1.tax_registration_number,
                          seq.name,
                          ''EAM''),
          decode(gjl1.tax_type_code,''I'',-1,1) *
          ZX_GL_EXTRACT_PKG.prorated_tax(
                          gjh.je_header_id,
                          gjh.ledger_id,
                          gjh.doc_sequence_id,
                          gjl1.tax_code_id,
                          gjl2.code_combination_id,
                          gjl1.tax_document_date,
                          gjl1.tax_type_code,--zx_rate.tax_class,--Bug 5338150
                          gjl1.tax_document_identifier,
                          gjl1.tax_customer_name,
                          gjl1.tax_customer_reference,
                          gjl1.tax_registration_number,
                          seq.name,
                          ''AAM''),  -- tax accounted amount
          to_number(NULL), --tax line number
          (sum(nvl(gjl1.entered_cr,0) - nvl(gjl1.entered_dr,0)))*
          decode(gjl1.tax_type_code,''I'',-1,1),    --taxable entered amount
          (sum(nvl(gjl1.accounted_cr,0) - nvl(gjl1.accounted_dr,0)))*
          decode(gjl1.tax_type_code,''I'',-1,1),  --taxable accounted amount
         -- min(gjl1.je_line_num),     --acctg_dist_id
         -- gjl2.code_combination_id,
          sum(gjl1.stat_amount),'||     --taxable_line_qty
        --  gjh.period_name,'||
         'TO_DATE(NULL),'||  --gjl1.tax_document_identifier,
         'gjh.description,
         gjh.currency_code,
         TO_DATE(NULL), --gjl1.tax_document_date,
         TO_DATE(NULL), --gjl1.tax_document_date,
         gjh.currency_conversion_type,
         gjh.currency_conversion_date,
         gjh.currency_conversion_rate,
         TO_CHAR(NULL), --gjl1.context,
         TO_CHAR(NULL), --gjl1.attribute1,
         TO_CHAR(NULL), --gjl1.attribute2,
         TO_CHAR(NULL), --gjl1.attribute3,
         TO_CHAR(NULL), --gjl1.attribute4,
         TO_CHAR(NULL), --gjl1.attribute5,
         TO_CHAR(NULL), --gjl1.attribute6,
         TO_CHAR(NULL), --gjl1.attribute7,
         TO_CHAR(NULL), --gjl1.attribute8,
         TO_CHAR(NULL), --gjl1.attribute9,
         TO_CHAR(NULL), --gjl1.attribute10,
         TO_CHAR(NULL), --gjl1.attribute11,
         TO_CHAR(NULL), --gjl1.attribute12,
         TO_CHAR(NULL), --gjl1.attribute13,
         TO_CHAR(NULL), --gjl1.attribute14,
         TO_CHAR(NULL), --gjl1.attribute15,
         TO_CHAR(NULL), --gjl1.tax_customer_name,
         TO_CHAR(NULL), --gjl1.tax_customer_reference,
         TO_CHAR(NULL), --gjl1.tax_registration_number,
         decode(gjh.posted_date,NULL,''N'',''Y''),
         zx_rate.tax_rate_code,
         zx_rate.description,
         zx_rate.PERCENTAGE_RATE,
         zx_rate.vat_transaction_type_code,
         gjl1.tax_type_code,    --zx_tax.tax_type_code,
         zx_rate.tax_rate_name,
         --zx_rate.tax_rate_register_type_code,
         zx_rate.tax_regime_code,
         zx_rate.tax,
         zx_rate.tax_jurisdiction_code,
         zx_rate.tax_status_code,
         TO_CHAR(NULL),  --tax_currency_code
         TO_NUMBER(NULL),  --tax_amt_tax_curr
         TO_NUMBER(NULL),  --taxable_amt_tax_curr
         TO_NUMBER(NULL),  --orig_taxable_amt
         TO_NUMBER(NULL),  --orig_taxable_amt_tax_curr
         TO_NUMBER(NULL),  --orig_tax_amt
         TO_NUMBER(NULL),  --orig_tax_amt_tax_curr
         TO_NUMBER(NULL),  --precision
         TO_NUMBER(NULL),  --minimum_accountable_unit
        -- TO_CHAR(NULL),  --functional_currency_code
         TO_NUMBER(NULL),  --gjl1.je_line_num,
         TO_NUMBER(NULL),  --gjl1.je_line_num,
         TO_CHAR(NULL),    --gjl1.description,
         TO_CHAR(NULL),    --gjl1.line_type_code,
         TO_NUMBER(NULL),   --establishment id
         TO_NUMBER(NULL),  --internal organization id
         --NULL,
         ''GL'',
         NULL,
         TO_CHAR(NULL),   -- gjl1.invoice_identifier,
         gjl2.code_combination_id,
         gjh.period_name ,
         TO_DATE(NULL)';  --gjl1.effective_date

  l_table_list_gl  :=
  ' FROM
          fnd_document_sequences seq,
 --         gl_tax_options gto,
          gl_code_combinations gcc2,
          gl_je_lines gjl2,
 --         ar_ap_tax_codes_v tax,
          zx_rates_vl  zx_rate,
          zx_taxes_vl  zx_tax,
          gl_code_combinations gcc1,
          gl_je_lines gjl1,
          gl_je_batches gjb,
          gl_je_headers gjh,
          gl_period_statuses gps ';

  l_where_clause_gl :=
  ' WHERE gps.ledger_id =  '||to_char(g_ledger_id)||
  '  AND gps.application_id = 101 '||
  ' AND gps.closing_status <> ''N'' '||
  ' AND gjh.period_name = gps.period_name  '||
  ' AND gjh.tax_status_code = ''T'' '||
  ' AND gjh.ledger_id = '||to_char(g_ledger_id)||
  ' AND gjh.actual_flag = ''A'' '||
  ' AND gjb.je_batch_id(+) = gjh.je_batch_id '||
  ' AND gjb.default_period_name = gjh.period_name '||
  ' AND gjb.actual_flag = ''A'' '||
--  ' AND gjb.ledger_id = '||to_char(g_ledger_id)||
  ' AND gjl1.je_header_id = gjh.je_header_id '||
  ' AND gjl1.tax_code_id = NVL(ZX_RATE.SOURCE_ID,ZX_RATE.TAX_RATE_ID) '||
  ' AND  zx_tax.tax = zx_rate.tax
    and zx_tax.TAX_REGIME_CODE = zx_rate.TAX_REGIME_CODE
    and zx_tax.CONTENT_OWNER_ID = zx_rate.CONTENT_OWNER_ID '||
  ' AND gjl1.tax_code_id is not NULL '||
  ' AND gcc1.code_combination_id = gjl1.code_combination_id '||
  ' AND gjl2.je_header_id = gjl1.je_header_id '||
  ' AND gjl2.tax_group_id = gjl1.tax_group_id  '||
  ' AND gjl2.tax_code_id is NULL '||
  ' AND gcc2.code_combination_id = gjl2.code_combination_id '||
--  ' AND gto.ledger_id = '||to_char(g_ledger_id)||
--  ' AND gto.org_id = gjb.org_id '||
  ' AND seq.doc_sequence_id (+) = gjh.doc_sequence_id '
     || L_WHERE_GL_OR_TRX_DATE
     || L_WHERE_GL_DATE
     || L_WHERE_TRX_DATE
     || L_WHERE_TAX_JURISDICTION_CODE
--     || L_WHERE_FIRST_PTY_TAX_REG_NUM
     || L_WHERE_TAX_REGIME_CODE
     || L_WHERE_TAX
     || L_WHERE_TAX_STATUS_CODE
     || L_WHERE_TAX_RATE_CODE
     || L_WHERE_TAX_TYPE_CODE
     || L_WHERE_CURRENCY_CODE
     || L_WHERE_POSTING_STATUS
     || L_WHERE_TAX_CODE_VAT_TRX_TYPE
     || L_WHERE_TRX_NUMBER_GL
     || L_WHERE_TAX_INVOICE_DATE
     || L_WHERE_TRX_CLASS_GL
  --   || L_WHERE_GL_FLEX
     || L_WHERE_GL_LINES_ATT3_IS_NULL
  ||' GROUP BY
          gjh.ledger_id,
          gjh.je_header_id,
          gjh.doc_sequence_id,
          gjh.doc_sequence_value,
          seq.name,
          gjl1.tax_code_id,
          gjl1.tax_type_code,
          gjl2.code_combination_id,
         -- gjl1.tax_document_date,
         -- zx_rate.tax_class,
         -- gjl1.tax_document_identifier,
         -- gjl1.tax_customer_name,
         -- gjl1.tax_customer_reference,
         -- gjl1.tax_registration_number,
         -- gjl1.je_line_num,     --acctg_dist_id
          gjh.period_name,
         gjh.description,
         gjh.currency_code,
         gjh.currency_conversion_type,
         gjh.currency_conversion_date,
         gjh.currency_conversion_rate,
        -- gjl1.line_type_code,
        -- gjl1.description,
        -- gjl1.context,
        -- gjl1.attribute1,
        -- gjl1.attribute2,
        -- gjl1.attribute3,
        -- gjl1.attribute4,
        -- gjl1.attribute5,
        -- gjl1.attribute6,
        -- gjl1.attribute7,
        -- gjl1.attribute8,
        -- gjl1.attribute9,
        -- gjl1.attribute10,
        -- gjl1.attribute11,
        -- gjl1.attribute12,
        -- gjl1.attribute13,
        -- gjl1.attribute14,
        -- gjl1.attribute15,
         gjh.posted_date,
         zx_rate.tax_rate_code,
         zx_rate.description,
         zx_rate.PERCENTAGE_RATE,
         zx_rate.vat_transaction_type_code,
         --zx_tax.tax_type_code,
         zx_rate.tax_rate_name,
         zx_rate.tax_regime_code,
         zx_rate.tax,
         zx_rate.tax_status_code,
         zx_rate.tax_jurisdiction_code,
         gjl1.tax_document_date,
         gjl1.tax_type_code,
         gjl1.tax_document_identifier,
         gjl1.tax_customer_name,
         gjl1.tax_customer_reference,
         gjl1.tax_registration_number ';
        -- gjl1.invoice_identifier,
        -- gjl1.effective_date ';



  ELSIF g_summary_level IN ('TRANSACTION_LINE',
                         'TRANSACTION_DISTRIBUTION') THEN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.BUILD_SQL',
                                      'ZX_GL_EXTRACT_PKG: SQL-2');
    END IF;

  l_column_list_gl :=
  ' SELECT
          gjh.ledger_id,
          gjh.je_header_id,
          gjh.doc_sequence_id,
          gjh.doc_sequence_value,
          seq.name,
          gjl1.tax_code_id,
          gjl2.je_line_num,
          (sum(nvl(gjl2.entered_cr,0) - nvl(gjl2.entered_dr,0)))*
          decode(gjl1.tax_type_code,''I'',-1,1),
          (sum(nvl(gjl2.accounted_cr,0) - nvl(gjl2.accounted_dr,0)))*
          decode(gjl1.tax_type_code,''I'',-1,1),
          gjl2.je_line_num,
          (sum(nvl(gjl1.entered_cr,0) - nvl(gjl1.entered_dr,0)))*
          decode(gjl1.tax_type_code,''I'',-1,1),
          (sum(nvl(gjl1.accounted_cr,0) - nvl(gjl1.accounted_dr,0)))*
          decode(gjl1.tax_type_code,''I'',-1,1),
         -- min(gjl1.je_line_num),
         -- gjl2.code_combination_id,
          sum(gjl1.stat_amount),'||
         -- gjh.period_name, '||
         'gjl1.tax_document_identifier,
         gjh.description,
         gjh.currency_code,
         gjl1.tax_document_date,
         gjl1.tax_document_date,
         gjh.currency_conversion_type,
         gjh.currency_conversion_date,
         gjh.currency_conversion_rate,
         gjl1.context,
         gjl1.attribute1,
         gjl1.attribute2,
         gjl1.attribute3,
         gjl1.attribute4,
         gjl1.attribute5,
         gjl1.attribute6,
         gjl1.attribute7,
         gjl1.attribute8,
         gjl1.attribute9,
         gjl1.attribute10,
         gjl1.attribute11,
         gjl1.attribute12,
         gjl1.attribute13,
         gjl1.attribute14,
         gjl1.attribute15,
         gjl1.tax_customer_name,
         gjl1.tax_customer_reference,
         gjl1.tax_registration_number,
         decode(gjh.posted_date,NULL,''N'',''Y''),
         zx_rate.tax_rate_code,
         zx_rate.description,
         zx_rate.PERCENTAGE_RATE,
         zx_rate.vat_transaction_type_code,
         gjl1.tax_type_code,     --zx_tax.tax_type_code,
         zx_rate.tax_rate_name,
         --zx_rate.tax_rate_register_type_code,    --Check this
         zx_rate.tax_regime_code,
         zx_rate.tax,
         zx_rate.tax_jurisdiction_code,
         zx_rate.tax_status_code,
         NULL,  --tax_currency_code
         NULL,  --tax_amt_tax_curr
         NULL,  --taxable_amt_tax_curr
         NULL,  --orig_taxable_amt
         NULL,  --orig_taxable_amt_tax_curr
         NULL,  --orig_tax_amt
         NULL,  --orig_tax_amt_tax_curr
         NULL,  --precision
         NULL,  --minimum_accountable_unit
       --  NULL,  --functional_currency_code
         gjl1.je_line_num,
         gjl1.je_line_num,
         gjl1.description,
         gjl1.line_type_code,
         NULL,   --establishment id
         NULL,  --internal organization id
       --  NULL,
         ''GL'',
         NULL,
         gjl1.invoice_identifier,
         gjl2.code_combination_id,
         gjh.period_name ,
         gjl1.effective_date ';

  l_table_list_gl  :=
  ' from
          fnd_document_sequences seq,
  --        gl_tax_options gto,
          gl_code_combinations gcc2,
          gl_je_lines gjl2,
          --ar_ap_tax_codes_v tax,
          zx_rates_vl  zx_rate,
          zx_taxes_vl  zx_tax,
          gl_code_combinations gcc1,
          gl_je_lines gjl1,
          gl_je_batches gjb,
          gl_je_headers gjh,
          gl_period_statuses gps ';

  l_where_clause_gl :=
  ' WHERE gps.ledger_id =  '||to_char(g_ledger_id)||
  ' AND gps.application_id = 101 '||
  ' AND gps.closing_status <> ''N'' '||
  ' AND gjh.period_name = gps.period_name  '||
  ' AND gjh.tax_status_code = ''T'' '||
  ' AND gjh.ledger_id = '||to_char(g_ledger_id)||
  ' AND gjh.actual_flag = ''A'' '||
  ' AND gjb.je_batch_id(+) = gjh.je_batch_id '||
  ' AND gjb.default_period_name = gjh.period_name '||
  ' AND gjb.actual_flag = ''A'' '||
--  ' AND gjb.ledger_id = '||to_char(g_ledger_id)||
  ' AND gjl1.je_header_id = gjh.je_header_id '||
  ' AND gjl1.tax_code_id is not NULL '||
  ' AND gjl1.tax_code_id = NVL(ZX_RATE.SOURCE_ID,ZX_RATE.TAX_RATE_ID) '||
  ' AND  zx_tax.tax = zx_rate.tax
    and zx_tax.TAX_REGIME_CODE = zx_rate.TAX_REGIME_CODE
    and zx_tax.CONTENT_OWNER_ID = zx_rate.CONTENT_OWNER_ID '||
  ' AND gcc1.code_combination_id = gjl1.code_combination_id '||
  ' AND gjl2.je_header_id = gjl1.je_header_id '||
  ' AND gjl2.tax_group_id = gjl1.tax_group_id  '||
  ' AND gjl2.tax_code_id is NULL '||
  ' AND gcc2.code_combination_id = gjl2.code_combination_id '||
--  ' AND gto.ledger_id = '||to_char(g_ledger_id)||
--  ' AND gto.org_id = gjb.org_id '||
  ' AND seq.doc_sequence_id (+) = gjh.doc_sequence_id '
     || L_WHERE_GL_OR_TRX_DATE
     || L_WHERE_GL_DATE
     || L_WHERE_TRX_DATE
     || L_WHERE_TAX_JURISDICTION_CODE
--     || L_WHERE_FIRST_PTY_TAX_REG_NUM
     || L_WHERE_TAX_REGIME_CODE
     || L_WHERE_TAX
     || L_WHERE_TAX_STATUS_CODE
     || L_WHERE_TAX_RATE_CODE
     || L_WHERE_TAX_TYPE_CODE
     || L_WHERE_CURRENCY_CODE
     || L_WHERE_POSTING_STATUS
     || L_WHERE_TAX_CODE_VAT_TRX_TYPE
     || L_WHERE_TRX_NUMBER_GL
     || L_WHERE_TAX_INVOICE_DATE
     || L_WHERE_TRX_CLASS_GL
 --    || L_WHERE_GL_FLEX
     || L_WHERE_GL_LINES_ATT3_IS_NULL
  ||' GROUP BY
          gjh.ledger_id,
          gjh.je_header_id,
          gjh.doc_sequence_id,
          gjh.doc_sequence_value,
          seq.name,
          gjl1.tax_code_id,
          gjl1.tax_type_code,
          gjl2.code_combination_id,
          gjl1.tax_document_date,
        --  zx_rate.tax_class,
          gjl1.tax_document_identifier,
          gjl1.tax_customer_name,
          gjl1.tax_customer_reference,
          gjl1.tax_registration_number,
          gjl1.je_line_num,     --acctg_dist_id
          gjl2.je_line_num,     --acctg_dist_id
          gjh.period_name,
         gjh.description,
         gjh.currency_code,
         gjh.currency_conversion_type,
         gjh.currency_conversion_date,
         gjh.currency_conversion_rate,
         gjl1.line_type_code,
         gjl1.description,
         gjl1.context,
         gjl1.attribute1,
         gjl1.attribute2,
         gjl1.attribute3,
         gjl1.attribute4,
         gjl1.attribute5,
         gjl1.attribute6,
         gjl1.attribute7,
         gjl1.attribute8,
         gjl1.attribute9,
         gjl1.attribute10,
         gjl1.attribute11,
         gjl1.attribute12,
         gjl1.attribute13,
         gjl1.attribute14,
         gjl1.attribute15,
         gjh.posted_date,
         zx_rate.tax_rate_code,
         zx_rate.description,
         zx_rate.PERCENTAGE_RATE,
         zx_rate.vat_transaction_type_code,
         --zx_tax.tax_type_code,
         zx_rate.tax_rate_name,
         zx_rate.tax_regime_code,
         zx_rate.tax,
         zx_rate.tax_status_code,
         zx_rate.tax_jurisdiction_code,
        gjl1.invoice_identifier ,
         gjl1.effective_date ';



  END IF;


   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.BUILD_SQL.END',
                                      'ZX_GL_EXTRACT_PKG: BUILD_SQL(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_GL_EXTRACT_PKG.BUILD_SQL',
                      g_error_buffer);
    END IF;

        G_GL_RETCODE := 2;

END BUILD_SQL;

/*===========================================================================+
 | FUNCTION                                                                  |
 |   prorated_tax                                                            |
 | DESCRIPTION                                                               |
 |                                                                           |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/

function prorated_tax(
  p_trx_id in                   number,
  p_ledger_id in          number,
  p_doc_seq_id in               number,
  p_tax_code_id in              number,
  p_code_comb_id in             number,
  p_tax_doc_date in             date,
  p_tax_class in                varchar2,
  p_tax_doc_identifier in       varchar2,
  p_tax_cust_name in            varchar2,
  p_tax_cust_reference in       varchar2,
  p_tax_reg_number in           varchar2,
  p_seq_name in                 varchar2,
  p_column_name in              varchar2) return number is

  cursor l_denominator_csr(p_tax_group_id in number) is
    select sum((nvl(GJL.ENTERED_CR,0)-nvl(GJL.ENTERED_DR,0)))
    from   GL_JE_LINES GJL
    where  gjl.je_header_id = p_trx_id and
           gjl.tax_group_id = p_tax_group_id and
           gjl.tax_code_id is not null;

/* Code added by SSWAYAMP for bug 1742970 */

  cursor l_denominator_csr1(p_tax_group_id in number) is
    select SUM(nvl(GJL.ENTERED_CR,0))
    from   GL_JE_LINES GJL
    where  gjl.je_header_id = p_trx_id and
           gjl.tax_group_id = p_tax_group_id and
           gjl.tax_code_id is not null;

/* End of Bug 1742970 */

  cursor l_tax_csr is
    select GJL2.ENTERED_DR EDR,
           GJL2.ENTERED_CR ECR,
           (nvl(GJL2.ENTERED_CR,0)-nvl(GJL2.ENTERED_DR,0)) EAM,
           GJL2.ACCOUNTED_DR ADR,
           GJL2.ACCOUNTED_CR ACR,
           (nvl(GJL2.ACCOUNTED_CR,0)-nvl(GJL2.ACCOUNTED_DR,0)) AAM,
           GJL1.TAX_GROUP_ID TAX_GROUP_ID,
           (nvl(GJL1.ENTERED_CR,0)-nvl(GJL1.ENTERED_DR,0)) ETAXABLEAM
    from   FND_DOCUMENT_SEQUENCES SEQ,
           GL_JE_LINES GJL2,
         --  AR_AP_TAX_CODES_V TAX,
           ZX_RATES_VL ZX_RATE,
           GL_JE_LINES GJL1,
           GL_JE_HEADERS GJH
    where  gjh.je_header_id = p_trx_id and
           gjh.je_header_id = gjl1.je_header_id and
           gjl1.tax_code_id =  NVL(ZX_RATE.SOURCE_ID,ZX_RATE.TAX_RATE_ID)
       AND ((zx_rate.tax_class in ('OUTPUT','INPUT')) or
            (zx_rate.tax_class is null))
       AND gjh.je_header_id = gjl2.je_header_id and
           gjl2.tax_group_id = gjl1.tax_group_id and
           gjl2.tax_code_id is null and
           gjh.doc_sequence_id = seq.doc_sequence_id(+) and
           ((gjh.ledger_id = p_ledger_id) or
            (gjh.ledger_id is null and p_ledger_id is null)) and
           ((gjh.doc_sequence_id = p_doc_seq_id) or
            (gjh.doc_sequence_id is null and p_doc_seq_id is null)) and
           ((seq.name = p_seq_name ) or
            (seq.name is null and p_seq_name is null)) and
           ((gjl1.tax_code_id = p_tax_code_id) or
            (gjl1.tax_code_id is null and p_tax_code_id is null)) and
           ((gjl1.tax_type_code = p_tax_class) or
            (gjl1.tax_type_code is null and p_tax_class is null)) and
           ((gjl1.tax_document_identifier = p_tax_doc_identifier) or
            (gjl1.tax_document_identifier is null and p_tax_doc_identifier is null)) and
           ((gjl1.tax_document_date = p_tax_doc_date) or
            (gjl1.tax_document_date is null and p_tax_doc_date is null)) and
           ((gjl1.tax_customer_name = p_tax_cust_name) or
            (gjl1.tax_customer_name is null and p_tax_cust_name is null)) and
           ((gjl1.tax_customer_reference = p_tax_cust_reference) or
            (gjl1.tax_customer_reference is null and p_tax_cust_reference is null)) and
           ((gjl1.tax_registration_number = p_tax_reg_number) or
            (gjl1.tax_registration_number is null and p_tax_reg_number is null)) and
           ((gjl2.code_combination_id = p_code_comb_id) or
            (gjl2.code_combination_id is null and p_code_comb_id is null));

  l_tax_rec_temp pr_tax_rec_type;
  l_amount number;
  l_denominator number;
  i NUMBER := 0;

begin

     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF ( g_level_procedure>= g_current_runtime_level ) THEN
  FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG','ZX_GL_EXTRACT_PKG.prorated_tax(+)');
  END IF;

--Bug 5338150
pr_tax_rec.edr:= null;
pr_tax_rec.ecr := null;
pr_tax_rec.eam := null;
pr_tax_rec.adr := null;
pr_tax_rec.acr := null;
pr_tax_rec.aam := null;

IF ( g_level_statement>= g_current_runtime_level ) THEN
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','In the Beginning : Displaying the parameters for the function prorated_tax ');
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','p_trx_id : '||p_trx_id);
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','p_ledger_id : '||p_ledger_id);
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','p_doc_seq_id : '||p_doc_seq_id);
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','p_tax_code_id : '||p_tax_code_id);
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','p_code_comb_id :' ||p_code_comb_id );
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','p_tax_class : '||p_tax_class );
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','p_tax_doc_identifier :'||p_tax_doc_identifier );
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','p_tax_cust_name : '||p_tax_cust_name );
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','p_tax_cust_reference : '||p_tax_cust_reference );
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','p_tax_reg_number : '||p_tax_reg_number );
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','p_seq_name :' ||p_seq_name );
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','p_column_name : '||p_column_name );
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','Initial Values in pr_tax_rec record');
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','pr_tax_rec.edr : '||pr_tax_rec.edr);
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','pr_tax_rec.ecr : '||pr_tax_rec.ecr);
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','pr_tax_rec.eam : '|| pr_tax_rec.eam);
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','pr_tax_rec.adr : '|| pr_tax_rec.adr);
  FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','pr_tax_rec.aam : '|| pr_tax_rec.aam);
END IF ;

  if (pr_tax_rec.edr is null and
      pr_tax_rec.ecr is null and
      pr_tax_rec.eam is null and
      pr_tax_rec.adr is null and
      pr_tax_rec.acr is null and
      pr_tax_rec.aam is null) then
    --
    for l_tax_rec_temp in l_tax_csr LOOP
      --
      i := i + 1;

IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG',' Values for i : '||i);
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG',' l_tax_rec_temp.tax_group_id : '||l_tax_rec_temp.tax_group_id);
END IF ;

      open l_denominator_csr(l_tax_rec_temp.tax_group_id);
      fetch l_denominator_csr into l_denominator;
      close l_denominator_csr;
      --
IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','l_denominator1 : '||l_denominator);
END IF ;
/* Code added by SSWAYAMP for bug 1742970 */

      if l_denominator = 0 then
         open l_denominator_csr1(l_tax_rec_temp.tax_group_id);
         fetch l_denominator_csr1 into l_denominator;
         if  sign(l_tax_rec_temp.etaxableam) = -1 then
            l_denominator := l_denominator * (-1);
         end if;
         close l_denominator_csr1;
       end if;

IF ( g_level_statement>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','l_denominator 2: '||l_denominator);
END IF ;
/* End of Bug 1742970 */

--bug2242602
     if l_denominator =0 and l_tax_rec_temp.etaxableam = 0  then
        l_denominator:= 1;
     end if;

      IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('etaxableam :'||to_char(l_tax_rec_temp.etaxableam));
        arp_util_tax.debug('l_denominator :'||to_char(l_denominator));
      END IF;

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','l_tax_rec_temp.etaxableam : '|| l_tax_rec_temp.etaxableam);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','Values fetched from l_tax_csr : for  pr_tax_rec record');
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','l_tax_rec_temp.ecr : '|| l_tax_rec_temp.ecr);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','l_tax_rec_temp.eam : '|| l_tax_rec_temp.eam);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','l_tax_rec_temp.adr : '|| l_tax_rec_temp.adr);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','l_tax_rec_temp.acr : '|| l_tax_rec_temp.acr);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','l_tax_rec_temp.aam : '|| l_tax_rec_temp.aam);
	END IF ;
      --
      pr_tax_rec.edr := nvl(pr_tax_rec.edr,0) +
                        (l_tax_rec_temp.edr*l_tax_rec_temp.etaxableam/l_denominator);
      pr_tax_rec.ecr := nvl(pr_tax_rec.ecr,0) +
                        (l_tax_rec_temp.ecr*l_tax_rec_temp.etaxableam/l_denominator);
      pr_tax_rec.eam := nvl(pr_tax_rec.eam,0) +
                        (l_tax_rec_temp.eam*l_tax_rec_temp.etaxableam/l_denominator);
      pr_tax_rec.adr := nvl(pr_tax_rec.adr,0) +
                        (l_tax_rec_temp.adr*l_tax_rec_temp.etaxableam/l_denominator);
      pr_tax_rec.acr := nvl(pr_tax_rec.acr,0) +
                        (l_tax_rec_temp.acr*l_tax_rec_temp.etaxableam/l_denominator);
      pr_tax_rec.aam := nvl(pr_tax_rec.aam,0) +
                        (l_tax_rec_temp.aam*l_tax_rec_temp.etaxableam/l_denominator);
    --

	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','pr_tax_rec.edr : '||pr_tax_rec.edr);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','pr_tax_rec.ecr : '||pr_tax_rec.ecr);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','pr_tax_rec.eam : '|| pr_tax_rec.eam);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','pr_tax_rec.adr : '|| pr_tax_rec.adr);
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','pr_tax_rec.acr :'||to_char(pr_tax_rec.acr));
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG','pr_tax_rec.aam : '|| pr_tax_rec.aam);
	END IF ;

    end loop;
    --
  /*  IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('pr_tax_rec.edr :'||to_char(pr_tax_rec.edr));
        arp_util_tax.debug('pr_tax_rec.ecr :'||to_char(pr_tax_rec.ecr));
        arp_util_tax.debug('pr_tax_rec.eam :'||to_char(pr_tax_rec.eam));
        arp_util_tax.debug('pr_tax_rec.adr :'||to_char(pr_tax_rec.adr));
        arp_util_tax.debug('pr_tax_rec.acr :'||to_char(pr_tax_rec.acr));
        arp_util_tax.debug('pr_tax_rec.aam :'||to_char(pr_tax_rec.aam));
    END IF; */

  --
  end if;
  --
  if p_column_name = 'EDR' then
    l_amount := pr_tax_rec.edr;
    pr_tax_rec.edr := NULL;
  elsif p_column_name = 'ECR' then
    l_amount := pr_tax_rec.ecr;
    pr_tax_rec.ecr := NULL;
  elsif p_column_name = 'EAM' then
    l_amount := pr_tax_rec.eam;
    pr_tax_rec.eam := NULL;
  elsif p_column_name = 'ADR' then
    l_amount := pr_tax_rec.adr;
    pr_tax_rec.adr := NULL;
  elsif p_column_name = 'ACR' then
    l_amount := pr_tax_rec.acr;
    pr_tax_rec.acr := NULL;
  elsif p_column_name = 'AAM' then
    l_amount := pr_tax_rec.aam;
    pr_tax_rec.aam := NULL;
  else
    l_amount := 0;
  end if;
  --
	IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG',
		' p_column_name : '||p_column_name||' l_amount : '||l_amount);
	END IF ;

  IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('ZX_GL_EXTRACT_PKG.prorated_tax(-)');
  END IF;
  return l_amount;
end prorated_tax;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   INSERT_GL_SUB_ITF                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts GL data into AR_TAX_EXTRACT_SUB_ITF table       |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE INSERT_GL_SUB_ITF
IS
m NUMBER;
BEGIN


    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.INSERT_GL_SUB_ITF',
                                      'INSERT_GL_SUB_ITF(+)');
    END IF;
   for m in 1..nvl(gt_ledger_id.COUNT,0) loop

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG.INSERT_GL_SUB_ITF',
                                      'Taxable Amt '||to_char(GT_TAXABLE_AMT_FUNCL_CURR(m)));
        FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_GL_EXTRACT_PKG.INSERT_GL_SUB_ITF',
                                      'Tax Amt '||to_char(GT_TAX_AMT(m)));
    END IF;


   end loop;

  FORALL i IN 1 .. nvl(gt_ledger_id.COUNT, 0)

--  New insert code

  INSERT into zx_rep_trx_detail_t
     (application_id,
     detail_tax_line_id,
     ledger_id,
     trx_id,
     doc_seq_id,
     doc_seq_value,
     doc_seq_name,
     tax_rate_id,
     tax_line_id,
     tax_amt,
     tax_amt_funcl_curr,
     tax_line_number,
     taxable_amt,
     taxable_amt_funcl_curr,
   --  xla_code_combination_id,
     trx_line_quantity,
   --  xla_period_name,
     trx_number,
     trx_line_class,
     trx_description,
     trx_currency_code,
     trx_date,
     trx_communicated_date,
     tax_invoice_date,
     currency_conversion_type,
     currency_conversion_date,
     currency_conversion_rate,
     tax_line_user_category,
     tax_line_user_attribute1,
     tax_line_user_attribute2,
     tax_line_user_attribute3,
     tax_line_user_attribute4,
     tax_line_user_attribute5,
     tax_line_user_attribute6,
     tax_line_user_attribute7,
     tax_line_user_attribute8,
     tax_line_user_attribute9,
     tax_line_user_attribute10,
     tax_line_user_attribute11,
     tax_line_user_attribute12,
     tax_line_user_attribute13,
     tax_line_user_attribute14,
     tax_line_user_attribute15,
     billing_tp_name,
     billing_tp_number,
     billing_tp_tax_reg_num,
     posted_flag,
     tax_rate_code,
     tax_rate_code_description,
     tax_rate,
     tax_rate_vat_trx_type_code,
     tax_type_code,
     tax_rate_code_name,
     tax_rate_register_type_code,
     tax_rate_code_reg_type_mng,
     tax_regime_code,
     tax,
     tax_jurisdiction_code,
     tax_status_code,
     tax_currency_code,
     tax_amt_tax_curr,
     taxable_amt_tax_curr,
     orig_taxable_amt,
     orig_taxable_amt_tax_curr,
     orig_tax_amt,
     orig_tax_amt_tax_curr,
     precision,
     minimum_accountable_unit,
    -- functional_currency_code,
     trx_line_id,
     trx_line_number,
     trx_line_description,
     trx_line_type,
     establishment_id,
     internal_organization_id,
     --ledger_name,
     extract_source_ledger,
     doc_event_status,
     sub_ledger_invoice_identifier,
             CREATED_BY ,
        CREATION_DATE ,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        request_id,
        entity_code,
        event_class_code,
        rep_context_id,
        functional_currency_code,
        ledger_name)
VALUES (
     101,
     gt_detail_tax_line_id(i),
     gt_ledger_id(i),
     gt_trx_id(i),
     gt_doc_seq_id(i),
     gt_doc_seq_value(i),
     gt_doc_seq_name(i),
     gt_tax_rate_id(i),
     gt_tax_line_id (i),
     gt_tax_amt(i),
     gt_tax_amt_funcl_curr(i),
     gt_tax_line_number(i),
     gt_taxable_amt(i),
     gt_taxable_amt_funcl_curr(i),
   --  gt_xla_code_combination_id(i),
     gt_trx_line_quantity(i),
   --  gt_xla_period_name(i),
     gt_trx_number(i),
     'GLMJE',
     gt_trx_description(i),
     gt_trx_currency_code(i),
     gt_trx_date(i),
     gt_trx_communicated_date(i),
     gt_trx_communicated_date(i),
     gt_currency_conversion_type(i),
     gt_currency_conversion_date(i),
     gt_currency_conversion_rate(i),
     gt_tax_line_user_category(i),
     gt_tax_line_user_attribute1(i),
     gt_tax_line_user_attribute2(i),
     gt_tax_line_user_attribute3(i),
     gt_tax_line_user_attribute4(i),
     gt_tax_line_user_attribute5(i),
     gt_tax_line_user_attribute6(i),
     gt_tax_line_user_attribute7(i),
     gt_tax_line_user_attribute8(i),
     gt_tax_line_user_attribute9(i),
     gt_tax_line_user_attribute10(i),
     gt_tax_line_user_attribute11(i),
     gt_tax_line_user_attribute12(i),
     gt_tax_line_user_attribute13(i),
     gt_tax_line_user_attribute14(i),
     gt_tax_line_user_attribute15(i),
     gt_billing_tp_name(i),
     gt_billing_tp_number(i),
     gt_billing_tp_tax_reg_num(i),
     gt_posted_flag(i),
     gt_tax_rate_code(i),
     gt_tax_rate_code_description(i),
     gt_tax_rate(i),
     gt_tax_rate_vat_trx_type_code(i),
     gt_tax_type_code(i),
     gt_tax_rate_code_name(i),
  --   gt_tax_rate_reg_type_code(i),
     'TAX',
      g_tax_register_type_mng,
     gt_tax_regime_code(i),
     gt_tax(i),
     gt_tax_jurisdiction_code(i),
     gt_tax_status_code(i),
     gt_tax_currency_code(i),
     gt_tax_amt_tax_curr(i),
     gt_taxable_amt_tax_curr(i),
     gt_orig_taxable_amt(i),
     gt_orig_taxable_amt_tax_curr(i),
     gt_orig_tax_amt(i),
     gt_orig_tax_amt_tax_curr(i),
     gt_precision(i),
     gt_minimum_accountable_unit(i),
    -- gt_functional_currency_code(i),
     gt_trx_line_id(i),
     gt_trx_line_number(i),
     gt_trx_line_description(i),
     gt_trx_line_type(i),
     gt_establishment_id(i),
     gt_internal_organization_id(i),
     --gt_ledger_name(i),
     gt_extract_source_ledger(i),
     gt_doc_event_status(i),
     gt_sub_ledger_inv_identifier(i),
        g_created_by ,
        g_creation_date ,
        g_last_updated_by,
        g_last_update_date,
        g_last_update_login,
        g_request_id,
        'GL_JE_LINES',
        'MANUAL_JOURNALS',
        g_rep_context_id,
      g_fun_currency_code,
      g_ledger_name );

  IF g_include_accounting_segments='Y' THEN
    FORALL i IN 1 .. nvl(gt_ledger_id.COUNT, 0)
      INSERT INTO ZX_REP_ACTG_EXT_T(
	actg_ext_line_id,
	detail_tax_line_id,
	actg_line_ccid,
	 period_name,
        accounting_date,
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login,
	program_application_id,
	program_id,
	program_login_id,
	request_id)
      VALUES (
	zx_rep_actg_ext_t_s.nextval,
	gt_detail_tax_line_id(i),
	gt_actg_line_ccid(i),
	gt_period_name(i),
        gt_accounting_date(i),
	g_created_by,
	g_creation_date,
	g_last_updated_by,
	g_last_update_date,
	g_last_update_login,
	g_program_application_id,
	g_program_id,
	g_program_login_id,
	g_request_id);
  END IF;
/*
    INSERT INTO AR_TAX_EXTRACT_SUB_ITF
    (
              EXTRACT_LINE_ID,
              CREATED_BY ,
              CREATION_DATE ,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN,
              REQUEST_ID,
              CHART_OF_ACCOUNTS_ID,
              REP_CONTEXT_ID,
              EXTRACT_REPORT_LINE_NUMBER,
              ledger_id,
              EXTRACT_SOURCE_LEDGER,
              TRX_ID,
              TRX_DOC_SEQUENCE_ID,
              TRX_DOC_SEQUENCE_NAME,
              TRX_CLASS_CODE,
              TAX_CODE_ID,
              TAX_CODE_REGISTER_TYPE_CODE,
              TAX_LINE_ID,
              TAX_ENTERED_DR,
              TAX_ENTERED_CR,
              TAX_ENTERED_AMOUNT,
              TAX_ACCOUNTED_DR,
              TAX_ACCOUNTED_CR,
              TAX_ACCOUNTED_AMOUNT,
              TAX_LINE_NUMBER,
              TAXABLE_ENTERED_DR,
              TAXABLE_ENTERED_CR,
              TAXABLE_AMOUNT,
              TAXABLE_ACCOUNTED_DR,
              TAXABLE_ACCOUNTED_CR,
              TAXABLE_ACCOUNTED_AMOUNT,
              ACCTG_DIST_ID,
              AL_ACCOUNT_CCID,
              TAXABLE_LINE_QUANTITY,
              RECONCILIATION_FLAG,
              AH_PERIOD_NAME
    )
    VALUES
    (
              AR_TAX_EXTRACT_SUB_ITF_S.nextval,
              1,
              SYSDATE,
              1,
              SYSDATE,
              1,
              G_REQUEST_ID,
              G_CHART_OF_ACCOUNTS_ID,
              G_REP_CONTEXT_ID, --BUG 2610643
              PG_EXTRACT_REPORT_LINE_NUM_TAB(i),
              PG_ledger_id(i),
              'GL',
              PG_TRX_ID_TAB(i),
              PG_TRX_DOC_SEQUENCE_ID_TAB(i),
              PG_TRX_DOC_SEQUENCE_NAME_TAB(i),
              'GLMJE',
              PG_TAX_CODE_ID_TAB(i),
              'TAX',
              PG_TAX_LINE_ID_TAB(i),
              PG_TAX_ENTERED_DR_TAB(i),
              PG_TAX_ENTERED_CR_TAB(i),
              PG_TAX_ENTERED_AMOUNT_TAB(i),
              PG_TAX_ACCOUNTED_DR_TAB(i),
              PG_TAX_ACCOUNTED_CR_TAB(i),
              PG_TAX_ACCOUNTED_AMOUNT_TAB(i),
              PG_TAX_LINE_NUMBER_TAB(i),
              PG_TAXABLE_ENTERED_DR_TAB(i),
              PG_TAXABLE_ENTERED_CR_TAB(i),
              PG_TAXABLE_AMOUNT_TAB(i),
              PG_TAXABLE_ACCOUNTED_DR_TAB(i),
              PG_TAXABLE_ACCOUNTED_CR_TAB(i),
              PG_TAXABLE_ACCOUNTED_AMT_TAB(i),
              PG_ACCTG_DIST_ID_TAB(i),
              PG_AL_ACCOUNT_CCID_TAB(i),
              PG_TAXABLE_LINE_QUANTITY_TAB(i),
              'N',
              PG_PERIOD_NAME_TAB(i)
    );
 */


  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug('Number of GL rows successfully inserted = ' ||
                        TO_CHAR(nvl(gt_ledger_id.COUNT, 0)));
  END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.INSERT_GL_SUB_ITF',
                                      'Number of GL rows successfully inserted ='||TO_CHAR(nvl(gt_ledger_id.COUNT, 0)));
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.INSERT_GL_SUB_ITF.END',
                                      'INSERT_GL_SUB_ITF(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_GL_EXTRACT_PKG.INSERT_GL_SUB_ITF',
                      g_error_buffer);
    END IF;

        G_GL_RETCODE := 2;

END INSERT_GL_SUB_ITF;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   FETCH_GL_TRX_INFO                                                       |
 | DESCRIPTION                                                               |
 |    This proceure executes GL sql statements from build_sql in GL          |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE FETCH_GL_TRX_INFO
IS
  TYPE ZX_REP_DETAIL_CURTYPE IS REF CURSOR;

  zx_rep_detail_csr       ZX_REP_DETAIL_CURTYPE;
  i                             BINARY_INTEGER;
  L_SQL_STATEMENT_GL    VARCHAR2(16000);
 l_sql1              varchar2(3500);
 l_sql2              varchar2(3500);
 l_sql3              varchar2(3500);
 l_sql4              varchar2(3500);
 l_sql5              varchar2(3500);
 l_sql6              varchar2(3500);
 l_sql7              varchar2(3500);
 l_sql8              varchar2(3500);
 l_sql9              varchar2(3500);
BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_GL_TRX_INFO.BEGIN',
                                      'ZX_GL_EXTRACT_PKG: FETCH_GL_TRX_INFO(+)');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_GL_TRX_INFO',
                                      'FETCH_GL_TRX_INFO : Open zx_rep_detail_csr ');
    END IF;

  L_SQL_STATEMENT_GL := L_COLUMN_LIST_GL   ||
                        L_TABLE_LIST_GL  ||
                        L_WHERE_CLAUSE_GL;


  IF (g_level_procedure >= g_current_runtime_level ) THEN
      l_sql1 := substr(L_SQL_STATEMENT_GL,1,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_GL_TRX_INFO SQL', 'L_SQL_STATEMENT_GL  : '||l_sql1);
      l_sql2 := substr(L_SQL_STATEMENT_GL,3001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_GL_TRX_INFO SQL', 'L_SQL_STATEMENT_GL  : '||l_sql2);
      l_sql3 := substr(L_SQL_STATEMENT_GL,6001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_GL_TRX_INFO SQL', 'L_SQL_STATEMENT_GL  : '||l_sql3);
      l_sql4 := substr(L_SQL_STATEMENT_GL,9001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_GL_TRX_INFO SQL', 'L_SQL_STATEMENT_GL  : '||l_sql4);
      l_sql5 := substr(L_SQL_STATEMENT_GL,12001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_GL_TRX_INFO SQL', 'L_SQL_STATEMENT_GL  : '||l_sql5);
      l_sql6 := substr(L_SQL_STATEMENT_GL,15001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_GL_TRX_INFO SQL', 'L_SQL_STATEMENT_GL  : '||l_sql6);
      l_sql7 := substr(L_SQL_STATEMENT_GL,18001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_GL_TRX_INFO SQL', 'L_SQL_STATEMENT_GL  : '||l_sql7);
      l_sql8 := substr(L_SQL_STATEMENT_GL,21001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_GL_TRX_INFO SQL', 'L_SQL_STATEMENT_GL  : '||l_sql8);
  END IF;

  OPEN zx_rep_detail_csr FOR L_SQL_STATEMENT_GL USING
                               G_GL_DATE_LOW,
                               G_GL_DATE_HIGH,
                               G_TRX_DATE_LOW,
                               G_TRX_DATE_HIGH,
                               G_TAX_JURISDICTION_CODE,
                             --  G_FIRST_PARTY_TAX_REG_NUM,
                               G_TAX_REGIME_CODE,
                               G_TAX,
                               G_TAX_STATUS_CODE,
                               G_TAX_RATE_CODE_LOW,
                               G_TAX_RATE_CODE_HIGH,
                               G_TAX_TYPE_CODE_LOW,
                               G_TAX_TYPE_CODE_HIGH,
                               G_CURRENCY_CODE_LOW,
                               G_CURRENCY_CODE_HIGH,
                               G_VAT_TRANSACTION_TYPE_CODE,
                               G_TRX_NUMBER_LOW,
                               G_TRX_NUMBER_HIGH,
                               G_TAX_INVOICE_DATE_LOW,
                               G_TAX_INVOICE_DATE_HIGH,
                               G_GDF_GL_JE_LINES_CATEGORY,
                               G_GDF_GL_JE_LINES_ATT3;
                              -- G_DOCUMENT_SUB_TYPE,
                              -- G_TRX_BUSINESS_CATEGORY,
                             --  G_AR_EXEMPTION_STATUS,
                             --  G_VAT_TAX,
                             --  G_VAT_ADDITIONAL_TAX,
                             --  G_VAT_NON_TAXABLE_TAX,
                             --  G_VAT_NOT_TAX,
                             --  G_VAT_PERCEPTION_TAX,
                             --  G_EXCISE_TAX;


    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_GL_TRX_INFO',
                                      'FETCH_GL_TRX_INFO : After Open zx_rep_detail_csr ');
    END IF;

  --
  -- init counter and global GL tables
  --
  i := 1;
  INIT_GL_GT_TABLES;
    g_created_by        := fnd_global.user_id;
    g_creation_date     := sysdate;
    g_last_updated_by   := fnd_global.user_id;
    g_last_update_login := fnd_global.login_id;
    g_last_update_date  := sysdate;


  IF PG_DEBUG = 'Y' THEN
    arp_util_tax.debug('fetch GL rows ');
  END IF;

G_REP_CONTEXT_ID := ZX_EXTRACT_PKG.GET_REP_CONTEXT_ID(g_legal_entity_id,
                                                                    g_request_id);

  --
  -- insert when fetch up to 1000 rows
  --
LOOP
FETCH zx_rep_detail_csr INTO
     gt_ledger_id(i),
     gt_trx_id(i),
     gt_doc_seq_id(i),
     gt_doc_seq_value(i),
     gt_doc_seq_name(i),
     gt_tax_rate_id(i),
     gt_tax_line_id(i),
     gt_tax_amt(i),
     gt_tax_amt_funcl_curr(i),
     gt_tax_line_number(i),
     gt_taxable_amt(i),
     gt_taxable_amt_funcl_curr(i),
     --gt_xla_code_combination_id(i),
     gt_trx_line_quantity(i),
    -- gt_xla_period_name(i),
     gt_trx_number(i),
     gt_trx_description(i),
     gt_trx_currency_code(i),
     gt_trx_date(i),
     gt_trx_communicated_date(i),
     gt_currency_conversion_type(i),
     gt_currency_conversion_date(i),
     gt_currency_conversion_rate(i),
     gt_tax_line_user_category(i),
     gt_tax_line_user_attribute1(i),
     gt_tax_line_user_attribute2(i),
     gt_tax_line_user_attribute3(i),
     gt_tax_line_user_attribute4(i),
     gt_tax_line_user_attribute5(i),
     gt_tax_line_user_attribute6(i),
     gt_tax_line_user_attribute7(i),
     gt_tax_line_user_attribute8(i),
     gt_tax_line_user_attribute9(i),
     gt_tax_line_user_attribute10(i),
     gt_tax_line_user_attribute11(i),
     gt_tax_line_user_attribute12(i),
     gt_tax_line_user_attribute13(i),
     gt_tax_line_user_attribute14(i),
     gt_tax_line_user_attribute15(i),
     gt_billing_tp_name(i),
     gt_billing_tp_number(i),
     gt_billing_tp_tax_reg_num(i),
     gt_posted_flag(i),
     gt_tax_rate_code(i),
     gt_tax_rate_code_description(i),
     gt_tax_rate(i),
     gt_tax_rate_vat_trx_type_code(i),
     gt_tax_type_code(i),
     gt_tax_rate_code_name(i),
--     gt_tax_rate_reg_type_code(i),
     gt_tax_regime_code(i),
     gt_tax(i),
     gt_tax_jurisdiction_code(i),
     gt_tax_status_code(i),
     gt_tax_currency_code(i),
     gt_tax_amt_tax_curr(i),
     gt_taxable_amt_tax_curr(i),
     gt_orig_taxable_amt(i),
     gt_orig_taxable_amt_tax_curr(i),
     gt_orig_tax_amt(i),
     gt_orig_tax_amt_tax_curr(i),
     gt_precision(i),
     gt_minimum_accountable_unit(i),
   --  gt_functional_currency_code(i),
     gt_trx_line_id(i),
     gt_trx_line_number(i),
     gt_trx_line_description(i),
     gt_trx_line_type(i),
     gt_establishment_id(i),
     gt_internal_organization_id(i),
    -- gt_ledger_name(i),
     gt_extract_source_ledger(i),
     gt_doc_event_status(i),
     gt_sub_ledger_inv_identifier(i),
     gt_actg_line_ccid(i),
     gt_period_name(i),
     gt_accounting_date(i);


        IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.fetch_tax_info',
                                      'Before insert GL Tax lines :' ||to_char(GT_TRX_ID.count));
        END IF;

    IF  zx_rep_detail_csr%FOUND THEN

      SELECT zx_rep_trx_detail_t_s.nextval
      INTO   gt_detail_tax_line_id(i)
      FROM   DUAL;

      --
      -- populate EXTRACT_REPORT_LINE_NUMBER
      --
    --  PG_EXTRACT_REPORT_LINE_NUM_TAB(i) := G_EXTRACT_LINE_NUM;
     -- G_EXTRACT_LINE_NUM := G_EXTRACT_LINE_NUM + 1;

      IF (i >= C_LINES_PER_INSERT) THEN
        INSERT_GL_SUB_ITF;
        --
        -- reset counter and init gt tables
        --
        i := 1;
        INIT_GL_GT_TABLES;
      ELSE
        i := i + 1;
      END IF;

    ELSE
      --
      -- total rows fetched less than 1000
      -- insert the rest of rows
      --
      INSERT_GL_SUB_ITF;
      CLOSE zx_rep_detail_csr;
      EXIT;
    END IF;
  END LOOP;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_GL_TRX_INFO.END',
                                      'ZX_GL_EXTRACT_PKG: FETCH_GL_TRX_INFO(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_GL_EXTRACT_PKG.FETCH_TAX_INFO',
                      g_error_buffer);
    END IF;

        G_GL_RETCODE := 2;

END FETCH_GL_TRX_INFO;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   INIT_GL_GT_TABLES                                                       |
 | DESCRIPTION                                                               |
 |    This proceure initialize the global table od columns.                  |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/


PROCEDURE INIT_GL_GT_TABLES IS
BEGIN

     gt_ledger_id.DELETE;
     gt_sub_ledger_inv_identifier.DELETE;
     gt_actg_line_ccid.DELETE;
     gt_period_name.DELETE;
     gt_detail_tax_line_id.DELETE;
 /*     PG_TRX_ID_TAB.DELETE;
      PG_TRX_DOC_SEQUENCE_ID_TAB.DELETE;
      PG_TRX_DOC_SEQUENCE_NAME_TAB.DELETE;
      PG_TAX_CODE_ID_TAB.DELETE;
      PG_TAX_LINE_ID_TAB.DELETE;
      PG_TAX_ENTERED_DR_TAB.DELETE;
      PG_TAX_ENTERED_CR_TAB.DELETE;
      PG_TAX_ENTERED_AMOUNT_TAB.DELETE;
      PG_TAX_ACCOUNTED_DR_TAB.DELETE;
      PG_TAX_ACCOUNTED_CR_TAB.DELETE;
      PG_TAX_ACCOUNTED_AMOUNT_TAB.DELETE;
      PG_TAX_LINE_NUMBER_TAB.DELETE;
      PG_TAXABLE_ENTERED_DR_TAB.DELETE;
      PG_TAXABLE_ENTERED_CR_TAB.DELETE;
      PG_TAXABLE_AMOUNT_TAB.DELETE;
      PG_TAXABLE_ACCOUNTED_DR_TAB.DELETE;
      PG_TAXABLE_ACCOUNTED_CR_TAB.DELETE;
      PG_TAXABLE_ACCOUNTED_AMT_TAB.DELETE;
      PG_ACCTG_DIST_ID_TAB.DELETE;
      PG_AL_ACCOUNT_CCID_TAB.DELETE;
      PG_TAXABLE_LINE_QUANTITY_TAB.DELETE;
      PG_PERIOD_NAME_TAB.DELETE;
      PG_EXTRACT_REPORT_LINE_NUM_TAB.DELETE;
*/
END INIT_GL_GT_TABLES;

PROCEDURE UPDATE_ADDITIONAL_INFO(
          P_TRL_GLOBAL_VARIABLES_REC      IN OUT  NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE)
IS


CURSOR detail_t_cur(c_request_id IN NUMBER) IS
SELECT  DET.DETAIL_TAX_LINE_ID,
        DET.LEDGER_ID,
        DET.INTERNAL_ORGANIZATION_ID,
        DET.TRX_ID ,
      --  TRX_TYPE_ID ,
        DET.TRX_LINE_CLASS,
        DET.TAX_RATE_VAT_TRX_TYPE_CODE,
--        TAX_RATE_REGISTER_TYPE_CODE,
        DET.TAX_LINE_ID ,
        DET.TRX_LINE_ID ,
       -- RECONCILIATION_FLAG ,
        DET.TAX_REGIME_CODE,
        DET.TAX,
        DET.TAX_JURISDICTION_CODE,
        DET.TAX_RATE,
        DET.TAX_RATE_ID,
        DET.TAX_RATE_CODE,
        DET.TAX_TYPE_CODE,
        DET.TRX_DATE,
        DET.TRX_CURRENCY_CODE,
        DET.CURRENCY_CONVERSION_RATE,
        DET.APPLICATION_ID,
        DET.TAX_AMT,
        DET.TAX_AMT_FUNCL_CURR,
        det.taxable_amt,
        det.taxable_amt_funcl_curr,
        ACT.ACTG_LINE_CCID,
        ACT.ACTG_EXT_LINE_ID
   FROM zx_rep_trx_detail_t det,
        zx_rep_actg_ext_t  act
  WHERE det.extract_source_ledger = 'GL'
    AND det.request_id = c_request_id
    AND act.detail_tax_line_id(+) = det.detail_tax_line_id;

 CURSOR account_type_cur(c_ccid number) IS
  SELECT account_type
    FROM gl_code_combinations
   WHERE code_combination_id = c_ccid;

l_balancing_segment VARCHAR2(25);
l_accounting_segment VARCHAR2(25);
l_count number;
l_meaning      VARCHAR2(80);
l_description  VARCHAR2(80);
l_tax_amt      NUMBER;
l_tax_amt_funcl_curr NUMBER;
l_taxable_amt  number;
l_taxable_amt_funcl_curr number;
l_account_type VARCHAR2(1);
BEGIN

     g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     g_request_id := P_TRL_GLOBAL_VARIABLES_REC.request_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.UPDATE_ADDITIONAL_INFO.BEGIN',
                                      'ZX_GL_EXTRACT_PKG:UPDATE_ADDITIONAL_INFO(+)');
    END IF;

    l_balancing_segment := fa_rx_flex_pkg.flex_sql(
                                  p_application_id =>101,
                                  p_id_flex_code => 'GL#',
                                  p_id_flex_num => P_TRL_GLOBAL_VARIABLES_REC.chart_of_accounts_id,
                                  p_table_alias => '',
                                  p_mode => 'SELECT',
                                  p_qualifier => 'GL_BALANCING');

    l_accounting_segment := fa_rx_flex_pkg.flex_sql(
                                   p_application_id =>101,
                                   p_id_flex_code => 'GL#',
                                   p_id_flex_num => P_TRL_GLOBAL_VARIABLES_REC.chart_of_accounts_id,
                                   p_table_alias => '',
                                   p_mode => 'SELECT',
                                   p_qualifier => 'GL_ACCOUNT');

    --     The above function will return balancing segment in the form CC.SEGMENT1
    --     we need to drop CC. to get the actual balancing segment.

    l_balancing_segment := substrb(l_balancing_segment,
                     instrb(l_balancing_segment,'.')+1);

   OPEN detail_t_cur(P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID);
   LOOP
      FETCH detail_t_cur BULK COLLECT INTO
      GT_DETAIL_TAX_LINE_ID,
      GT_LEDGER_ID,
      GT_INTERNAL_ORGANIZATION_ID,
      GT_TRX_ID,
      --GT_TRX_TYPE_ID,
      GT_TRX_CLASS,
      GT_TAX_RATE_VAT_TRX_TYPE_CODE,
     -- GT_TAX_RATE_REG_TYPE_CODE,
      GT_TAX_LINE_ID,
      GT_TRX_LINE_ID,
   --   GT_RECONCILIATION_FLAG,
      GT_TAX_REGIME_CODE,
      GT_TAX,
      GT_TAX_JURISDICTION_CODE,
      GT_TAX_RATE,
      GT_TAX_RATE_ID,
      GT_TAX_RATE_CODE,
      GT_TAX_TYPE_CODE,
      GT_TRX_DATE,
      GT_TRX_CURRENCY_CODE,
      GT_CURRENCY_CONVERSION_RATE,
      GT_APPLICATION_ID,
      GT_TAX_AMT,
      GT_TAX_AMT_FUNCL_CURR,
     gt_taxable_amt,
     gt_taxable_amt_funcl_curr,
      GT_ACTG_LINE_CCID,
      GT_ACTG_EXT_LINE_ID
      LIMIT C_LINES_PER_COMMIT;

    l_count := nvl(GT_DETAIL_TAX_LINE_ID.COUNT,0);

     FOR i IN 1..l_count
     LOOP

          l_tax_amt := GT_TAX_AMT(i);
          l_tax_amt_funcl_curr := GT_TAX_AMT_FUNCL_CURR(i);
          l_taxable_amt := gt_taxable_amt(i);
          l_taxable_amt_funcl_curr := gt_taxable_amt_funcl_curr(i);
  --
  -- This code is added to populate tax_type_code (I or O) for new tax codes--
  --
     IF GT_TAX_TYPE_CODE(i) = 'T' THEN
        OPEN account_type_cur(GT_ACTG_LINE_CCID(i));
        FETCH account_type_cur into l_account_type;
          IF l_account_type IN ('A','E') THEN
         -- IF sign(GT_TAX_AMT(i)) = -1 THEN
             GT_TAX_TYPE_CODE(i) := 'I';
             GT_TAX_AMT(i) := l_tax_amt * -1;
             GT_TAX_AMT_FUNCL_CURR(i) := l_tax_amt_funcl_curr * -1;
             gt_taxable_amt(i) := l_taxable_amt * -1;
             gt_taxable_amt_funcl_curr(i) := l_taxable_amt_funcl_curr * -1;
          ELSE
             GT_TAX_TYPE_CODE(i) := 'O';
          END IF;
        CLOSE account_type_cur;
     END IF;

        GT_TAX_RATE_VAT_TRX_TYPE_DESC(i) := NULL;
        GT_TRX_CLASS_MNG(i) := NULL;
        GT_TAX_RATE_VAT_TRX_TYPE_MNG(i) := NULL;
        GT_TAX_TYPE_MNG(i) := NULL;
         GT_TAX_REG_NUM(i) := NULL;

     IF  GT_TAX_RATE_VAT_TRX_TYPE_CODE(i) IS NOT NULL THEN
         ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_JEBE_VAT_TRANS_TYPE',
                              GT_TAX_RATE_VAT_TRX_TYPE_CODE(i),
                             l_meaning,
                             l_description);
         GT_TAX_RATE_VAT_TRX_TYPE_DESC(i) := l_description;
         GT_TAX_RATE_VAT_TRX_TYPE_MNG(i) := l_meaning;
     END IF;
     IF GT_TRX_CLASS(i) IS NOT NULL THEN
        ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_TRL_TAXABLE_TRX_TYPE',
                             GT_TRX_CLASS(i),
                             l_meaning,
                             l_description);
        GT_TRX_CLASS_MNG(i) := l_meaning;
     END IF;
     IF GT_TAX_TYPE_CODE(i) IS NOT NULL THEN
        ZX_AP_POPULATE_PKG.lookup_desc_meaning('ZX_TAX_TYPE_CATEGORY',
                             GT_TAX_TYPE_CODE(i),
                             l_meaning,
                             l_description);
        GT_TAX_TYPE_MNG(i) := l_meaning;
     END IF;




     populate_tax_reg_num(
          P_TRL_GLOBAL_VARIABLES_REC,
          GT_TAX(i),
          GT_TAX_REGIME_CODE(i),
          GT_TAX_JURISDICTION_CODE(i),
          i );

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_GL_POPULATE_PKG.populate_tax_reg_num.BEGIN',
                      'tax '||GT_TAX(i)||' tax regime code '||GT_TAX_REGIME_CODE(i)||' Jurisdiction '||GT_TAX_JURISDICTION_CODE(i));
      END IF;

     IF g_include_accounting_segments='Y' THEN

       GET_ACCOUNTING_SEGMENTS (
          GT_TRX_ID(i),
          GT_TAX_RATE_ID(i),
          L_BALANCING_SEGMENT,
          L_ACCOUNTING_SEGMENT,
	  P_TRL_GLOBAL_VARIABLES_REC.CHART_OF_ACCOUNTS_ID,
          GT_TRX_ARAP_BALANCING_SEGMENT(i),
          GT_TRX_ARAP_NATURAL_ACCOUNT(i),
          GT_TRX_TAXABLE_BAL_SEG(i),
          GT_TRX_TAXABLE_NATURAL_ACCOUNT(i),
          GT_TRX_TAX_BALANCING_SEGMENT(i),
          GT_TRX_TAX_NATURAL_ACCOUNT(i),
	  GT_TRX_TAXABLE_BALSEG_DESC(i),
	  GT_TRX_TAXABLE_NATACCT_DESC(i)
       );

       IF GT_ACTG_LINE_CCID(i) IS NOT NULL THEN

          GT_ACCOUNT_FLEXFIELD(i) := FA_RX_FLEX_PKG.GET_VALUE(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => P_TRL_GLOBAL_VARIABLES_REC.chart_of_accounts_id,
                            P_QUALIFIER => 'ALL',
                            P_CCID => GT_ACTG_LINE_CCID(i));

          IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.UPDATE_ADDITIONAL_INFO',
                                      'Account Flexfield = '||GT_ACCOUNT_FLEXFIELD(i));
          END IF;

          GT_ACCOUNT_DESCRIPTION(i) := FA_RX_FLEX_PKG.GET_DESCRIPTION(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => P_TRL_GLOBAL_VARIABLES_REC.chart_of_accounts_id,
                            P_QUALIFIER => 'ALL',
                            P_DATA => GT_ACCOUNT_FLEXFIELD(i));

          IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.UPDATE_ADDITIONAL_INFO',
                                      'Account Description = '||GT_ACCOUNT_DESCRIPTION(i));
          END IF;

       END IF;
     END IF;
     END LOOP;

      FORALL i in 1..l_count
       UPDATE ZX_REP_TRX_DETAIL_T SET
            TAX_RATE_VAT_TRX_TYPE_DESC     =      GT_TAX_RATE_VAT_TRX_TYPE_DESC(i),
            TRX_CLASS_MNG                  =      GT_TRX_CLASS_MNG(i),
            TAX_RATE_CODE_VAT_TRX_TYPE_MNG =      GT_TAX_RATE_VAT_TRX_TYPE_MNG(i),
            TAX_TYPE_MNG                   =      GT_TAX_TYPE_MNG(i),
            HQ_ESTB_REG_NUMBER            =      GT_TAX_REG_NUM(i),
            TAX_TYPE_CODE =  GT_TAX_TYPE_CODE(i),
            TAX_AMT   =  GT_TAX_AMT(i),
            TAX_AMT_FUNCL_CURR   =  GT_TAX_AMT_FUNCL_CURR(i),
            TAXABLE_AMT = GT_TAXABLE_AMT(i),
            TAXABLE_AMT_FUNCL_CURR = GT_TAXABLE_AMT_FUNCL_CURR(i)
       WHERE DETAIL_TAX_LINE_ID = GT_DETAIL_TAX_LINE_ID(i);

     IF g_include_accounting_segments='Y' THEN
       FORALL i IN 1 .. l_count
         UPDATE ZX_REP_ACTG_EXT_T
         SET trx_arap_balancing_segment    = gt_trx_arap_balancing_segment(i),
	     trx_arap_natural_account      = gt_trx_arap_natural_account(i),
	     trx_taxable_balancing_segment = gt_trx_taxable_bal_seg(i),
	     trx_taxable_natural_account   = gt_trx_taxable_natural_account(i),
	     trx_tax_balancing_segment     = gt_trx_tax_balancing_segment(i),
	     trx_tax_natural_account       = gt_trx_tax_natural_account(i),
	     account_flexfield             = gt_account_flexfield(i),
	     account_description           = gt_account_description(i)
         WHERE actg_ext_line_id = gt_actg_ext_line_id(i);
     END IF;

        EXIT WHEN detail_t_cur%NOTFOUND
              OR detail_t_cur%NOTFOUND IS NULL;

END LOOP;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.UPDATE_ADDITIONAL_INFO.END',
                                      'ZX_GL_EXTRACT_PKG:UPDATE_ADDITIONAL_INFO(-)');
    END IF;
END UPDATE_ADDITIONAL_INFO;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   get_accounting_segments                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure of gets the Balancing and Natural Account segments      |
 |    For Taxable, Tax and Control Accounts  for all manual tax journals     |
 |                                                                           |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   23-May-06 Vinit Doshi Created                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE GET_ACCOUNTING_SEGMENTS (
    P_TRX_ID                            IN NUMBER,
    P_TAX_CODE_ID                       IN NUMBER,
    P_BALANCING_SEGMENT                 IN VARCHAR2,
    P_ACCOUNTING_SEGMENT                IN VARCHAR2,
    P_CHART_OF_ACCOUNTS_ID		IN NUMBER,
    P_TRX_ARAP_BALANCING_SEGMENT        OUT NOCOPY VARCHAR2,
    P_TRX_ARAP_NATURAL_ACCOUNT          OUT NOCOPY VARCHAR2,
    P_TRX_TAXABLE_BAL_SEG               OUT NOCOPY VARCHAR2,
    P_TRX_TAXABLE_NATURAL_ACCOUNT       OUT NOCOPY VARCHAR2,
    P_TRX_TAX_BALANCING_SEGMENT         OUT NOCOPY VARCHAR2,
    P_TRX_TAX_NATURAL_ACCOUNT           OUT NOCOPY VARCHAR2,
    P_TRX_TAXABLE_BALSEG_DESC		OUT NOCOPY VARCHAR2,
    P_TRX_TAXABLE_NATACCT_DESC		OUT NOCOPY varchar2
) IS

L_BAL_SEG_VAL                   VARCHAR2(25);
L_ACCT_SEG_VAL                  VARCHAR2(25);

  L_BAL_SEG_DESC VARCHAR2(240);
  L_ACCT_SEG_DESC VARCHAR2(240);

L_SQL_STATEMENT1                VARCHAR2(200);
L_SQL_STATEMENT2                VARCHAR2(200);
L_CCID                          NUMBER;
L_TAX_GROUP_ID                  NUMBER;
L_TRX_ARAP_BALANCING_SEGMENT    VARCHAR2(2000);
L_TRX_ARAP_NATURAL_ACCOUNT      VARCHAR2(2000);
L_TRX_TAXABLE_BAL_SEG           VARCHAR2(2000);
L_TRX_TAXABLE_NATURAL_ACCOUNT   VARCHAR2(2000);
L_TRX_TAX_BALANCING_SEGMENT     VARCHAR2(2000);
L_TRX_TAX_NATURAL_ACCOUNT       VARCHAR2(2000);

L_TRX_TAXABLE_BALSEG_DESC	VARCHAR2(2000);
L_TRX_TAXABLE_NATACCT_DESC	VARCHAR2(2000);

   CURSOR TAXABLE_ACCT_CURSOR(C_TRX_ID IN NUMBER,
                              C_TAX_CODE_ID IN NUMBER) IS
     SELECT CODE_COMBINATION_ID, TAX_GROUP_ID
       FROM GL_JE_LINES
      WHERE JE_HEADER_ID = C_TRX_ID
        AND TAX_CODE_ID  = C_TAX_CODE_ID;

   CURSOR TAX_ACCT_CURSOR(C_TRX_ID IN NUMBER,
                          C_TAX_GROUP_ID IN NUMBER) IS
     SELECT CODE_COMBINATION_ID
       FROM GL_JE_LINES
      WHERE JE_HEADER_ID = C_TRX_ID
        AND TAX_GROUP_ID  = C_TAX_GROUP_ID
        AND TAX_CODE_ID IS NULL ;

   CURSOR CONTROL_ACCT_CURSOR(C_TRX_ID IN NUMBER ) IS
      SELECT CODE_COMBINATION_ID
      FROM   GL_JE_LINES
      WHERE  JE_HEADER_ID = C_TRX_ID
      AND    TAX_GROUP_ID IS NULL;

BEGIN

   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.GET_ACCOUNTING_SEGMENTS.BEGIN',
                                      'ZX_GL_EXTRACT_PKG: GET_ACCOUNTING_SEGMENTS(+)');
   END IF;

  L_TRX_ARAP_BALANCING_SEGMENT    := NULL;
  L_TRX_ARAP_NATURAL_ACCOUNT      := NULL;
  L_TRX_TAXABLE_BAL_SEG           := NULL;
  L_TRX_TAXABLE_NATURAL_ACCOUNT   := NULL;
  L_TRX_TAX_BALANCING_SEGMENT     := NULL;
  L_TRX_TAX_NATURAL_ACCOUNT       := NULL;

  L_TRX_TAXABLE_BALSEG_DESC	:= NULL ;
  L_TRX_TAXABLE_NATACCT_DESC	:= NULL ;

  L_BAL_SEG_VAL := '';
  L_ACCT_SEG_VAL := '';

  L_SQL_STATEMENT1 := ' SELECT '||P_BALANCING_SEGMENT ||
                      ' FROM GL_CODE_COMBINATIONS '||
                      ' WHERE CODE_COMBINATION_ID = :L_CCID ';

  L_SQL_STATEMENT2 := ' SELECT '||P_ACCOUNTING_SEGMENT ||
                      ' FROM GL_CODE_COMBINATIONS '||
                      ' WHERE CODE_COMBINATION_ID = :L_CCID ';


  OPEN TAXABLE_ACCT_CURSOR(P_TRX_ID, P_TAX_CODE_ID);
  LOOP
     FETCH  TAXABLE_ACCT_CURSOR INTO L_CCID, L_TAX_GROUP_ID ;
     EXIT WHEN TAXABLE_ACCT_CURSOR%NOTFOUND;

     EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO  L_BAL_SEG_VAL
                                       USING L_CCID;

     EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                       USING L_CCID;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.GET_ACCOUNTING_SEGMENTS',
             'trx_id - tax_code_id - ccid - L_ACCT_SEG_VAL '||to_char(P_TRX_ID)||'-'||to_char(P_TAX_CODE_ID)
             ||'-'||to_char(L_CCID)||L_ACCT_SEG_VAL);
   END IF;

--Bug 5650415
        IF L_BAL_SEG_VAL IS NOT NULL THEN
           L_BAL_SEG_DESC :=  FA_RX_FLEX_PKG.GET_DESCRIPTION(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => P_CHART_OF_ACCOUNTS_ID,
                            P_QUALIFIER => 'GL_BALANCING',
                            P_DATA => L_BAL_SEG_VAL);
        END IF;

        IF L_ACCT_SEG_VAL IS NOT NULL THEN
           L_ACCT_SEG_DESC :=  FA_RX_FLEX_PKG.GET_DESCRIPTION(
                            P_APPLICATION_ID => 101,
                            P_ID_FLEX_CODE => 'GL#',
                            P_ID_FLEX_NUM => P_CHART_OF_ACCOUNTS_ID,
                            P_QUALIFIER => 'GL_ACCOUNT',
                            P_DATA => L_ACCT_SEG_VAL);
        END IF;


    IF L_TRX_ARAP_BALANCING_SEGMENT IS NULL then
        L_TRX_ARAP_BALANCING_SEGMENT := L_BAL_SEG_VAL;
	L_TRX_TAXABLE_BALSEG_DESC := L_BAL_SEG_DESC;
    ELSE
        IF INSTRB(L_TRX_ARAP_BALANCING_SEGMENT,L_BAL_SEG_VAL) > 0 THEN
            NULL;
        ELSE
            L_TRX_ARAP_BALANCING_SEGMENT  := L_TRX_ARAP_BALANCING_SEGMENT
                                         ||','||L_BAL_SEG_VAL;
	    L_TRX_TAXABLE_BALSEG_DESC := L_TRX_TAXABLE_BALSEG_DESC||','||L_BAL_SEG_DESC;
        END IF;
    END IF;

    L_TRX_TAXABLE_BAL_SEG := L_TRX_ARAP_BALANCING_SEGMENT;

    IF L_TRX_ARAP_NATURAL_ACCOUNT IS NULL then
        L_TRX_ARAP_NATURAL_ACCOUNT  := L_ACCT_SEG_VAL ;
	 L_TRX_TAXABLE_NATACCT_DESC := L_ACCT_SEG_DESC;
    ELSE
        IF INSTRB(L_TRX_ARAP_NATURAL_ACCOUNT,L_ACCT_SEG_VAL) > 0 THEN
            NULL;
        ELSE
            L_TRX_ARAP_NATURAL_ACCOUNT  := L_TRX_ARAP_NATURAL_ACCOUNT
                                   ||','||L_ACCT_SEG_VAL;
       	    L_TRX_TAXABLE_NATACCT_DESC := L_TRX_TAXABLE_NATACCT_DESC||','||L_ACCT_SEG_DESC;
        END IF;
    END IF;
          L_TRX_TAXABLE_NATURAL_ACCOUNT  := L_TRX_ARAP_NATURAL_ACCOUNT;
  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.GET_ACCOUNTING_SEGMENTS',
                                      'Trx Balancing Segment = '||L_TRX_ARAP_BALANCING_SEGMENT);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.GET_ACCOUNTING_SEGMENTS',
                                      'Trx Natural A/c Segment = '||L_TRX_ARAP_NATURAL_ACCOUNT);
  END IF;

     IF TAXABLE_ACCT_CURSOR%ISOPEN THEN
             CLOSE TAXABLE_ACCT_CURSOR;
     END IF;

   L_BAL_SEG_VAL := '';
   L_ACCT_SEG_VAL := '';


   OPEN TAX_ACCT_CURSOR(P_TRX_ID, L_TAX_GROUP_ID);

   LOOP
     FETCH TAX_ACCT_CURSOR INTO L_CCID;
     EXIT WHEN TAX_ACCT_CURSOR%NOTFOUND;

     EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO L_BAL_SEG_VAL
                                       USING L_CCID;

     EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                       USING L_CCID;

     IF L_TRX_TAX_BALANCING_SEGMENT IS NULL then
         L_TRX_TAX_BALANCING_SEGMENT := L_BAL_SEG_VAL;
     ELSE
         IF INSTRB(L_TRX_TAX_BALANCING_SEGMENT,L_BAL_SEG_VAL) > 0 THEN
            NULL;
         ELSE
            L_TRX_TAX_BALANCING_SEGMENT  := L_TRX_TAX_BALANCING_SEGMENT
                                      ||','||L_BAL_SEG_VAL;
         END IF;
     END IF;
     IF L_TRX_TAX_NATURAL_ACCOUNT IS NULL then
         L_TRX_TAX_NATURAL_ACCOUNT  := L_ACCT_SEG_VAL ;
     ELSE
         IF INSTRB(L_TRX_TAX_NATURAL_ACCOUNT,L_ACCT_SEG_VAL) > 0 THEN
             NULL;
         ELSE
             L_TRX_TAX_NATURAL_ACCOUNT  :=
                                L_TRX_TAX_NATURAL_ACCOUNT ||','
                                ||L_ACCT_SEG_VAL;
         END IF;
     END IF;

   END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.GET_ACCOUNTING_SEGMENTS',
                                      'Taxable Balancing Segment = '||L_TRX_TAXABLE_BAL_SEG);
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.GET_ACCOUNTING_SEGMENTS',
                                      'Taxable Natural A/c Segment = '||L_TRX_TAXABLE_NATURAL_ACCOUNT);
  END IF;

   IF TAX_ACCT_CURSOR%ISOPEN THEN
             CLOSE TAX_ACCT_CURSOR;
   END IF;

  L_BAL_SEG_VAL := '';
  L_ACCT_SEG_VAL := '';
/*
  OPEN  CONTROL_ACCT_CURSOR(P_TRX_ID);

  LOOP
     FETCH CONTROL_ACCT_CURSOR INTO L_CCID;
     EXIT WHEN CONTROL_ACCT_CURSOR%NOTFOUND;

     EXECUTE IMMEDIATE L_SQL_STATEMENT1 INTO L_BAL_SEG_VAL
                                       USING L_CCID;

     EXECUTE IMMEDIATE L_SQL_STATEMENT2 INTO L_ACCT_SEG_VAL
                                       USING L_CCID;

     IF L_TRX_TAX_BALANCING_SEGMENT IS NULL then
         L_TRX_TAX_BALANCING_SEGMENT := L_BAL_SEG_VAL;
     ELSE
         IF INSTRB(L_TRX_TAX_BALANCING_SEGMENT,L_BAL_SEG_VAL) > 0 THEN
             NULL;
         ELSE
             L_TRX_TAX_BALANCING_SEGMENT  := L_TRX_TAX_BALANCING_SEGMENT
                                          ||','||L_BAL_SEG_VAL;
         END IF;
     END IF;

     IF L_TRX_TAX_NATURAL_ACCOUNT IS NULL then
         L_TRX_TAX_NATURAL_ACCOUNT  := L_ACCT_SEG_VAL ;
     ELSE
         IF INSTRB(L_TRX_TAX_NATURAL_ACCOUNT,L_ACCT_SEG_VAL) > 0 THEN
             NULL;
         ELSE
             L_TRX_TAX_NATURAL_ACCOUNT  := L_TRX_TAX_NATURAL_ACCOUNT ||','
                                           ||L_ACCT_SEG_VAL;
         END If;
     END IF;

   END LOOP;
*/
   IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.GET_ACCOUNTING_SEGMENTS',
                                       'Tax Balancing Segment = '||L_TRX_TAX_BALANCING_SEGMENT);
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.GET_ACCOUNTING_SEGMENTS',
                                       'Tax Natural A/c Segment = '||L_TRX_TAX_NATURAL_ACCOUNT);
   END IF;

 /*  IF CONTROL_ACCT_CURSOR%ISOPEN THEN
             CLOSE CONTROL_ACCT_CURSOR;
   END IF;
*/
    P_TRX_ARAP_BALANCING_SEGMENT :=  L_TRX_ARAP_BALANCING_SEGMENT;
    P_TRX_ARAP_NATURAL_ACCOUNT   :=  L_TRX_ARAP_NATURAL_ACCOUNT;
    P_TRX_TAXABLE_BAL_SEG        :=  L_TRX_TAXABLE_BAL_SEG;
    P_TRX_TAXABLE_NATURAL_ACCOUNT := L_TRX_TAXABLE_NATURAL_ACCOUNT ;
    P_TRX_TAX_BALANCING_SEGMENT  :=  L_TRX_TAX_BALANCING_SEGMENT ;
    P_TRX_TAX_NATURAL_ACCOUNT    :=  L_TRX_TAX_NATURAL_ACCOUNT ;

    P_TRX_TAXABLE_BALSEG_DESC := L_TRX_TAXABLE_BALSEG_DESC;
    P_TRX_TAXABLE_NATACCT_DESC := L_TRX_TAXABLE_NATACCT_DESC;

   IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_GL_EXTRACT_PKG.GET_ACCOUNTING_SEGMENTS.END',
                                      'ZX_GL_EXTRACT_PKG: GET_ACCOUNTING_SEGMENTS(-)');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','get_accounting_segments- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_GL_EXTRACT_PKG.GET_ACCOUNTING_SEGMENTS',
                      g_error_buffer);
    END IF;

       IF TAXABLE_ACCT_CURSOR%ISOPEN THEN
               CLOSE TAXABLE_ACCT_CURSOR;
       END IF;

       IF TAX_ACCT_CURSOR%ISOPEN THEN
               CLOSE TAX_ACCT_CURSOR;
       END IF;

       IF CONTROL_ACCT_CURSOR%ISOPEN THEN
               CLOSE CONTROL_ACCT_CURSOR;
       END IF;

       G_GL_RETCODE := 2;

END GET_ACCOUNTING_SEGMENTS ;


PROCEDURE populate_tax_reg_num(
          P_TRL_GLOBAL_VARIABLES_REC  IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
          P_TAX                       IN zx_rates_vl.tax%TYPE,
          P_TAX_REGIME_CODE                IN zx_rates_vl.tax_regime_code%TYPE,
          P_TAX_JURISDICTION_CODE          IN zx_rates_vl.tax_jurisdiction_code%TYPE,
          i IN BINARY_INTEGER) IS

       l_ptp_id number;
       l_return_status varchar2(30);
BEGIN

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_GL_POPULATE_PKG.populate_tax_reg_num.BEGIN',
                      'populate_tax_reg_num(+) ');
    END IF;

    IF P_TRL_GLOBAL_VARIABLES_REC.legal_entity_id is NULL THEN

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_GL_POPULATE_PKG.populate_tax_reg_num.BEGIN',
                      'Null LE ID Found');
           FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_GL_POPULATE_PKG.populate_tax_reg_num.END',
                      'populate_tax_reg_num(-) ');
      END IF;
      GT_TAX_REG_NUM(i) := NULL;
      return;
    END IF;

       ZX_TCM_PTP_PKG.GET_PTP_HQ( P_TRL_GLOBAL_VARIABLES_REC.legal_entity_id,
                              l_ptp_id,
                              l_return_status);
   Begin
    SELECT registration_number
      INTO GT_TAX_REG_NUM(i)
      FROM zx_registrations  reg
     WHERE reg.party_tax_profile_id = l_ptp_id
       AND nvl(reg.tax_regime_code,1)  = nvl(p_tax_regime_code,1)
       AND nvl(reg.tax,nvl(p_tax,1)) = nvl(p_tax,1)
       AND nvl(reg.tax_jurisdiction_code,nvl(p_tax_jurisdiction_code,1)) = nvl(p_tax_jurisdiction_code,1)
       AND  sysdate >= reg.effective_from
       AND (sysdate <= reg.effective_to OR reg.effective_to IS NULL);


    EXCEPTION
     WHEN TOO_MANY_ROWS THEN
          GT_TAX_REG_NUM(i) := NULL;
     WHEN NO_DATA_FOUND THEN
          GT_TAX_REG_NUM(i) := NULL;
    END;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.ZX_GL_POPULATE_PKG.populate_tax_reg_num.END',
                      'populate_tax_reg_num(-) ');
    END IF;
END populate_tax_reg_num;

END ZX_GL_EXTRACT_PKG;

/
