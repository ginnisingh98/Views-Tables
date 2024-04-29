--------------------------------------------------------
--  DDL for Package Body ZX_TDS_RULE_BASE_DETM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_RULE_BASE_DETM_PVT" as
/* $Header: zxdirulenginpvtb.pls 120.124.12010000.24 2010/08/10 17:10:08 prigovin ship $ */


PROCEDURE get_tsrm_parameter_value(
            p_structure_name         IN  VARCHAR2,
            p_structure_index        IN  BINARY_INTEGER,
            p_condition_index        IN  BINARY_INTEGER,
            p_numeric_value          OUT NOCOPY ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_alphanum_value         OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_date_value             OUT NOCOPY ZX_CONDITIONS.DATE_VALUE%TYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE get_fsc_code(
            p_found                   IN OUT NOCOPY BOOLEAN,
            p_tax_regime_code         IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_classification_category IN
                 ZX_FC_TYPES_B.Classification_Type_Categ_Code%TYPE,
            p_classification_type     IN
                 ZX_FC_TYPES_B.CLASSIFICATION_TYPE_CODE%TYPE,
            p_tax_determine_date IN
                 ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_classified_entity_id    IN
                 ZX_FC_CODES_B.CLASSIFICATION_ID%TYPE,
            p_item_org_id             IN     NUMBER,
            p_application_id          IN     NUMBER,
            p_event_class_code        IN     VARCHAR2,
            p_trx_alphanumeric_value  OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE);

PROCEDURE get_fc(
      p_structure_name          IN  VARCHAR2,
      p_structure_index         IN  BINARY_INTEGER,
      p_condition_index         IN  BINARY_INTEGER,
      p_tax_determine_date      IN  ZX_LINES.TAX_DETERMINE_DATE%TYPE,
      p_tax_regime_code         IN  ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
      p_event_class_rec         IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE,
      p_trx_alphanumeric_value  OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
      p_Determining_Factor_Cq_Code   IN  ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
      p_return_status           OUT NOCOPY VARCHAR2,
      p_error_buffer            OUT NOCOPY VARCHAR2);

PROCEDURE get_registration_status(
            p_structure_name         IN  VARCHAR2,
            p_structure_index        IN  BINARY_INTEGER,
            p_event_class_rec        IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_determine_date     IN  ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_tax                    IN  ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code        IN  ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_trx_alphanumeric_value OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_Determining_Factor_Cq_Code   IN ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2);

PROCEDURE process_segment_string(
            p_account_string         IN     VARCHAR2,
            p_chart_of_accounts_id   IN
                ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2);

PROCEDURE get_account_flexfield_info(
            p_structure_name         IN  VARCHAR2,
            p_structure_index        IN  BINARY_INTEGER,
            p_condition_index        IN     BINARY_INTEGER,
            p_trx_alphanumeric_value OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_chart_of_accounts_id   IN
                ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
            p_sob_id                 IN
                ZX_CONDITION_GROUPS_B.LEDGER_ID%TYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE get_geography_info(
            p_structure_name         IN  VARCHAR2,
            p_structure_index        IN  BINARY_INTEGER,
            p_condition_index        IN  BINARY_INTEGER,
            p_zone_tbl               OUT NOCOPY HZ_GEO_GET_PUB.zone_tbl_type,
            p_Determining_Factor_Cq_Code  IN  ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_tax_determine_date     IN  ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

-- Bug#4591207
PROCEDURE get_master_geography_info(
            p_structure_name        IN  VARCHAR2,
            p_structure_index       IN  BINARY_INTEGER,
            p_condition_index       IN  BINARY_INTEGER,
            p_trx_numeric_value  OUT NOCOPY ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_Determining_Factor_Cq_Code IN ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_return_status            OUT NOCOPY VARCHAR2,
            p_error_buffer             OUT NOCOPY VARCHAR2);

/* Bugfix 3673395 - Since the list of Determining factors related
to PRODUCT :  ITEM_TAXABILITY_OVERRIDE and TAX_CLASSIFICATION
and PARTY : ESTB_TAX_CLASSIFICATION
are replaced by defaulting APIs, we no longer require the following procedures
- get_tax_info_from_item
- get_product_tax_info
- get get_party_tax_info

PROCEDURE get_tax_info_from_item(
            p_product_id              IN  MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE,
            p_item_org_id             IN  MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE,
            p_determining_factor_code IN  ZX_CONDITIONS.DETERMINING_FACTOR_CODE%TYPE,
            p_trx_alphanumeric_value  OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2);

PROCEDURE get_product_tax_info(
            p_structure_name          IN  VARCHAR2,
            p_structure_index         IN  BINARY_INTEGER,
            p_determining_factor_code IN  ZX_CONDITIONS.DETERMINING_FACTOR_CODE%TYPE,
            p_trx_alphanumeric_value  OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2);

PROCEDURE get_party_tax_info(
            p_structure_name          IN  VARCHAR2,
            p_structure_index         IN  BINARY_INTEGER,
            p_Determining_Factor_Cq_Code   IN  ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_determining_factor_code IN  ZX_CONDITIONS.DETERMINING_FACTOR_CODE%TYPE,
            p_trx_alphanumeric_value  OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2);
*/
PROCEDURE get_trx_value(
            p_structure_name         IN  VARCHAR2,
            p_structure_index        IN  BINARY_INTEGER,
            p_event_class_rec        IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_condition_index        IN  BINARY_INTEGER,
            p_tax_determine_date     IN  ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_tax                    IN  ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code        IN  ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_Determining_Factor_Cq_Code  IN     ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_numeric_value          OUT NOCOPY ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_alphanum_value         OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_date_value             OUT NOCOPY ZX_CONDITIONS.DATE_VALUE%TYPE,
            p_chart_of_accounts_id   IN
                ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
            p_sob_id                 IN
                ZX_CONDITION_GROUPS_B.LEDGER_ID%TYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);


PROCEDURE evaluate_trx_value_tbl(
            p_structure_name         IN     VARCHAR2,
            p_structure_index        IN     BINARY_INTEGER,
            p_condition_index        IN     BINARY_INTEGER,
            p_tax_determine_date     IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_Determining_Factor_Cq_Code  IN     ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_chart_of_accounts_id   IN     ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
            p_result                 IN OUT NOCOPY BOOLEAN,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2);

PROCEDURE get_user_item_type_value(
            p_structure_name     IN  VARCHAR2,
            p_structure_index    IN  BINARY_INTEGER,
            p_condition_index    IN  BINARY_INTEGER,
            p_event_class_rec    IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_numeric_value      OUT NOCOPY ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_alphanum_value     OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status      OUT NOCOPY VARCHAR2,
            p_error_buffer       OUT NOCOPY VARCHAR2);

PROCEDURE get_user_item_alphanum_value(
            p_structure_name         IN  VARCHAR2,
            p_structure_index        IN  BINARY_INTEGER,
            p_parameter_code         IN  ZX_PARAMETERS_B.TAX_PARAMETER_CODE%TYPE,
            p_event_class_rec        IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_trx_alphanumeric_value    OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2);

FUNCTION evaluate_date_condition(
           p_Operator_Code    IN      ZX_CONDITIONS.Operator_Code%TYPE,
           p_condition_value  IN      ZX_CONDITIONS.DATE_VALUE%TYPE,
           p_trx_value        IN      ZX_CONDITIONS.DATE_VALUE%TYPE)
RETURN BOOLEAN;

FUNCTION evaluate_numeric_condition(
           p_Operator_Code           IN  ZX_CONDITIONS.Operator_Code%TYPE,
           p_condition_value    IN  ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
           p_trx_value          IN  ZX_CONDITIONS.NUMERIC_VALUE%TYPE)
RETURN BOOLEAN;

FUNCTION evaluate_alphanum_condition(
           p_Operator_Code         IN    ZX_CONDITIONS.Operator_Code%TYPE,
           p_condition_value       IN    ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
           p_trx_value             IN    ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
           p_value_low             IN    ZX_CONDITIONS.VALUE_LOW%TYPE,
           p_value_high            IN    ZX_CONDITIONS.VALUE_HIGH%TYPE,
           p_det_factor_templ_code IN    ZX_DET_FACTOR_TEMPL_B.DET_FACTOR_TEMPL_CODE%TYPE,
           p_chart_of_accounts_id  IN    ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE)
RETURN BOOLEAN;

PROCEDURE evaluate_condition(
            p_condition_index        IN     BINARY_INTEGER,
            p_trx_alphanumeric_value IN     ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_trx_numeric_value      IN     ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_trx_date_value         IN     ZX_CONDITIONS.DATE_VALUE%TYPE,
            p_chart_of_accounts_id   IN     ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
            p_result                 OUT NOCOPY BOOLEAN,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE check_condition_group_result(
      p_det_factor_templ_code   IN     ZX_DET_FACTOR_TEMPL_B.DET_FACTOR_TEMPL_CODE%TYPE,
      p_condition_group_code    IN     ZX_CONDITION_GROUPS_B.CONDITION_GROUP_CODE%TYPE,
      p_trx_line_index          IN     BINARY_INTEGER,
      p_event_class_rec         IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
      p_template_evaluated      OUT NOCOPY BOOLEAN,
      p_result                  OUT NOCOPY BOOLEAN);

PROCEDURE insert_condition_group_result(
            p_det_factor_templ_code IN ZX_DET_FACTOR_TEMPL_B.DET_FACTOR_TEMPL_CODE%TYPE,
            p_condition_group_code  IN ZX_CONDITION_GROUPS_B.CONDITION_GROUP_CODE%TYPE,
            p_result                IN BOOLEAN,
            p_trx_line_index        IN BINARY_INTEGER,
            p_event_class_rec       IN ZX_API_PUB.EVENT_CLASS_REC_TYPE);

PROCEDURE get_result(
           p_result_id           IN  ZX_PROCESS_RESULTS.RESULT_ID%TYPE,
           p_structure_name      IN  VARCHAR2,
           p_structure_index     IN  BINARY_INTEGER,
           p_tax_regime_code     IN  ZX_RATES_B.tax_regime_Code%TYPE,
           p_tax                 IN  ZX_RATES_B.tax%TYPE,
           p_tax_determine_date  IN  DATE,
           p_found               OUT NOCOPY BOOLEAN,
           p_zx_result_rec       OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
           p_return_status       OUT NOCOPY VARCHAR2,
           p_error_buffer        OUT NOCOPY VARCHAR2);

PROCEDURE init_set_condition;

PROCEDURE get_set_info (
      p_index                    IN BINARY_INTEGER,
      p_Det_Factor_Class_Code IN ZX_CONDITIONS.Determining_Factor_Class_Code%TYPE,
      p_Determining_Factor_Cq_Code    IN ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
      p_tax_parameter_code       IN ZX_CONDITIONS.TAX_PARAMETER_CODE%TYPE,
      p_Data_Type_Code                IN ZX_CONDITIONS.Data_Type_Code%TYPE,
      p_determining_factor_code  IN ZX_CONDITIONS.DETERMINING_FACTOR_CODE%TYPE,
      p_Operator_Code                 IN ZX_CONDITIONS.Operator_Code%TYPE,
      p_numeric_value            IN ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
      p_date_value               IN ZX_CONDITIONS.DATE_VALUE%TYPE,
      p_alphanum_value           IN ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
      p_value_low                IN ZX_CONDITIONS.VALUE_LOW%TYPE,
      p_value_high               IN ZX_CONDITIONS.VALUE_HIGH%TYPE);

PROCEDURE process_set_condition (
        p_structure_name         IN VARCHAR2,
        p_structure_index        IN BINARY_INTEGER,
        p_event_class_rec        IN ZX_API_PUB.EVENT_CLASS_REC_TYPE,
        p_tax_determine_date     IN ZX_LINES.TAX_DETERMINE_DATE%TYPE,
        p_tax                    IN ZX_TAXES_B.TAX%TYPE,
        p_tax_regime_code        IN ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
        p_result                 IN OUT NOCOPY BOOLEAN,
        p_chart_of_accounts_id  IN
                ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
        p_sob_id                 IN
                ZX_CONDITION_GROUPS_B.LEDGER_ID%TYPE,
        p_return_status             OUT NOCOPY VARCHAR2,
        p_error_buffer              OUT NOCOPY VARCHAR2);


PROCEDURE get_and_process_condition(
         p_structure_name        IN VARCHAR2,
         p_structure_index       IN BINARY_INTEGER,
         p_condition_group_code  IN ZX_CONDITION_GROUPS_B.CONDITION_GROUP_CODE%TYPE,
         p_event_class_rec       IN ZX_API_PUB.EVENT_CLASS_REC_TYPE,
         p_tax                   IN ZX_TAXES_B.TAX%TYPE,
         p_tax_regime_code       IN ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
         p_tax_determine_date    IN ZX_LINES.TAX_DETERMINE_DATE%TYPE,
         p_result                IN OUT NOCOPY BOOLEAN,
         p_chart_of_accounts_id  IN
                ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
         p_sob_id                IN
                ZX_CONDITION_GROUPS_B.LEDGER_ID%TYPE,
         p_return_status            OUT NOCOPY VARCHAR2,
         p_error_buffer             OUT NOCOPY VARCHAR2);


PROCEDURE proc_condition_group_per_templ(
            p_structure_name        IN     VARCHAR2,
            p_structure_index       IN     BINARY_INTEGER,
            p_det_factor_templ_code IN
                  ZX_DET_FACTOR_TEMPL_B.DET_FACTOR_TEMPL_CODE%TYPE,
            p_event_class_rec       IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax                   IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code       IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax_determine_date    IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_service_type_code     IN     ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
            p_tax_rule_id           IN     ZX_RULES_B.TAX_RULE_ID%TYPE,
            p_tax_status_code       IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_result                IN OUT NOCOPY BOOLEAN,
            p_result_id             IN OUT NOCOPY NUMBER,
            p_found              OUT NOCOPY BOOLEAN ,
            p_zx_result_rec          OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
            p_return_status            OUT NOCOPY VARCHAR2,
            p_error_buffer             OUT NOCOPY VARCHAR2);

PROCEDURE proc_det_factor_templ(
            p_structure_name          IN     VARCHAR2,
            p_structure_index         IN     BINARY_INTEGER,
            p_det_factor_templ_cd_tbl IN     DET_FACTOR_TEMPL_CODE_TBL,
            p_tax_status_code         IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_event_class_rec         IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_tbl                 IN     TAX_TBL,
            p_tax_determine_date      IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_recovery_type_code      IN     ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE,
            p_found                   IN OUT NOCOPY BOOLEAN,
            p_tax_regime_code_tbl     IN     TAX_REGIME_CODE_TBL,
            p_service_type_code       IN     ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
            p_tax_rule_id_tbl         IN     TAX_RULE_ID_TBL,
            p_rule_det_factor_cq_tbl  IN     RULE_DET_FACTOR_CQ_TBL,
            p_rule_geography_type_tbl IN     RULE_GEOGRAPHY_TYPE_TBL,
            p_rule_geography_id_tbl   IN     RULE_GEOGRAPHY_ID_TBL,
            p_zx_result_rec           OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2);

PROCEDURE process_rule_code(
            p_service_type_code    IN     ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
            p_structure_name       IN     VARCHAR2,
            p_structure_index      IN     BINARY_INTEGER,
            p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax                  IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code      IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax_determine_date   IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_tax_status_code      IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_tax_rule_code        IN     ZX_RULES_B.TAX_RULE_CODE%TYPE,
            p_recovery_type_code   IN     ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE,
            p_found                IN OUT NOCOPY BOOLEAN,
            p_zx_result_rec           OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2);


-- Bugfix 3673395 Added new procedure for evaluating Rules
-- Bugfix 4017396 Removed unwanted parameters
PROCEDURE fetch_proc_det_factor_templ(
            p_structure_name          IN     VARCHAR2,
            p_structure_index         IN     BINARY_INTEGER,
            p_tax_status_code         IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_event_class_rec         IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_determine_date      IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_recovery_type_code      IN     ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE,
            p_found                   IN OUT NOCOPY BOOLEAN,
            p_service_type_code       IN     ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
            p_zx_result_rec           OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
            p_tax                     IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code         IN      ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2);

PROCEDURE get_rule_from_regime_hier(
            p_service_type_code    IN     ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
            p_structure_name       IN     VARCHAR2,
            p_structure_index      IN     BINARY_INTEGER,
            p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_status_code      IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_tax_determine_date   IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_recovery_type_code   IN     ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE,
            p_zx_result_rec           OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
            p_found                IN OUT NOCOPY BOOLEAN,
            p_parent_regime_cd_tbl IN     TAX_REGIME_CODE_TBL,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2);

-- Bug 4166241 : Added new private procedure to process only those templates
-- whose determining factors are supported by the product
PROCEDURE check_templ_tax_parameter(
            p_det_factor_templ_code IN ZX_DET_FACTOR_TEMPL_B.det_factor_templ_code%TYPE,
            p_event_class_rec       IN ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_valid                  OUT NOCOPY BOOLEAN,
            p_return_status         OUT NOCOPY VARCHAR2,
            p_error_buffer          OUT NOCOPY VARCHAR2);

PROCEDURE check_rule_geography(
          p_structure_name      IN VARCHAR2,
          p_structure_index     IN BINARY_INTEGER,
          p_rule_det_factor_cq  IN ZX_RULES_B.determining_factor_cq_code%TYPE,
          p_rule_geography_type IN ZX_RULES_B.geography_type%TYPE,
          p_rule_geography_id   IN ZX_RULES_B.geography_id%TYPE,
          p_event_class_rec     IN ZX_API_PUB.EVENT_CLASS_REC_TYPE,
          p_valid               OUT NOCOPY BOOLEAN,
          p_return_status       OUT NOCOPY VARCHAR2,
          p_error_buffer        OUT NOCOPY VARCHAR2);

g_current_runtime_level      NUMBER;

g_level_statement        CONSTANT    NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure        CONSTANT    NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_event            CONSTANT    NUMBER   := FND_LOG.LEVEL_EVENT;
g_level_unexpected       CONSTANT    NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
g_level_error            CONSTANT    NUMBER   := FND_LOG.LEVEL_ERROR;

G_FSC_TBL_INSERT_POINTER    NUMBER := 0;
G_FSC_TBL_MAX_SIZE          CONSTANT  NUMBER := 2048;

----------------------------------------------------------------------
--  PRIVATE FUNCTION
--                     OPTIMAL_FSC_TBL_LOCATION
--
--  DESCRIPTION
--    This function returns where data need to be inserted in FSC_TBL
--    The table size is limited by G_FSC_TBL_MAX_SIZE and we circularly
--    insert data into this PL/SQL table
--
--  History
--
--    Sridhar R         28-DEC-2009  Created
--
----------------------------------------------------------------------
FUNCTION OPTIMAL_FSC_TBL_LOCATION RETURN NUMBER IS
  l_count  NUMBER;
BEGIN
  IF G_FSC_TBL_INSERT_POINTER = 0 THEN
    l_count := ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl.count;
    IF l_count < G_FSC_TBL_MAX_SIZE THEN
      RETURN l_count + 1;
    ELSE
      G_FSC_TBL_INSERT_POINTER := 1;
    END IF;
  ELSE
    G_FSC_TBL_INSERT_POINTER := MOD(G_FSC_TBL_INSERT_POINTER,G_FSC_TBL_MAX_SIZE)+1;
  END IF;
  RETURN G_FSC_TBL_INSERT_POINTER;
END OPTIMAL_FSC_TBL_LOCATION;


----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  init_cec_params
--
--  DESCRIPTION
--    This is called for Migrated Records only.
--    This procedure initializes parameters required for evaluating
--    Constraint, Condition Set and Exception Set
--  History
--
--    Sudhir Sekuri                  01-MAR-04  Created
--
PROCEDURE init_cec_params(p_structure_name  IN     VARCHAR2,
                          p_structure_index IN     BINARY_INTEGER,
                          p_return_status   IN OUT NOCOPY VARCHAR2,
                          p_error_buffer    IN OUT NOCOPY VARCHAR2) is

begin

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.init_cec_params.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: init_cec_params (+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Fetch Ship To Party Site Id
  -- (equivalent of arp_tax.tax_info_rec.ship_to_site_use_id)
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'SHIP_TO_PARTY_SITE_ID',
                     g_cec_ship_to_party_site_id,
                     p_return_status,
                     p_error_buffer);
  -- Fetch Bill To Party Site Id
  -- (equivalent of arp_tax.tax_info_rec.bill_to_site_use_id)
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'BILL_TO_PARTY_SITE_ID',
                     g_cec_bill_to_party_site_id,
                     p_return_status,
                     p_error_buffer);

  -- Fetch Ship To Party Id
  -- (equivalent of arp_tax.tax_info_rec.ship_to_cust_id)
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'SHIP_TO_PARTY_TAX_PROF_ID',
                     g_cec_ship_to_party_id,
                     p_return_status,
                     p_error_buffer);

  -- Fetch Bill To Party Id
  -- (equivalent of arp_tax.tax_info_rec.bill_to_cust_id)
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'BILL_TO_PARTY_TAX_PROF_ID',
                     g_cec_bill_to_party_id,
                     p_return_status,
                     p_error_buffer);

  -- Fetch POO Location Id
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'POO_LOCATION_ID',
                     g_cec_poo_location_id,
                     p_return_status,
                     p_error_buffer);

  -- Fetch POA Location Id
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'POA_LOCATION_ID',
                     g_cec_poa_location_id,
                     p_return_status,
                     p_error_buffer);

  -- Fetch Trx Id
  -- (equivalent of arp_tax.tax_info_rec.customer_trx_id)
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'TRX_ID',
                     g_cec_trx_id,
                     p_return_status,
                     p_error_buffer);

  -- Fetch Trx Line Id
  -- (equivalent of arp_tax.tax_info_rec.customer_trx_line_id)
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'TRX_LINE_ID',
                     g_cec_trx_line_id,
                     p_return_status,
                     p_error_buffer);

  -- Fetch Ledger Id
  -- (equivalent of arp_tax.sysinfo.sysparam.set_of_books_id)
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'LEDGER_ID',
                     g_cec_ledger_id,
                     p_return_status,
                     p_error_buffer);

  -- Fetch Internal Organization Id
  -- (equivalent of arp_tax.sysinfo.sysparam.org_id)
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'INTERNAL_ORGANIZATION_ID',
                     g_cec_internal_organization_id,
                     p_return_status,
                     p_error_buffer);

  -- set the MO policy context with the internal org id
  /* This call is not required because the code in ZX_TDS_PROCESS_CEC_PVT.evaluate_cec
     accesses the base tables (_ALL) for all multi-org tables
  IF MO_GLOBAL.get_current_org_id <> g_cec_internal_organization_id then
      MO_GLOBAL.Set_Policy_Context('S', g_cec_internal_organization_id);
  END IF;
  */

  -- Fetch SO Organization Id
  -- (equivalent of arp_tax.profinfo.so_organization_id)
  g_cec_so_organization_id := oe_profile.value_specific('SO_ORGANIZATION_ID');

  -- Fetch Product Organization Id
  -- (equivalent of arp_tax.tax_info_rec.ship_from_warehouse_id)
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'PRODUCT_ORG_ID',
                     g_cec_product_org_id,
                     p_return_status,
                     p_error_buffer);

  -- Fetch Product Id
  -- (equivalent of arp_tax.tax_info_rec.inventory_item_id)
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'PRODUCT_ID',
                     g_cec_product_id,
                     p_return_status,
                     p_error_buffer);

  -- Fetch Trx Line Date
  -- (equivalent of arp_tax.tax_info_rec.trx_date)
  ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value (p_structure_name,
                                                p_structure_index,
                                                'TRX_LINE_DATE',
                                                g_cec_trx_line_date,
                                                p_return_status);

  -- Fetch Transaction Type Id
  -- (equivalent of arp_tax.tax_info_rec.trx_type_id)
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     'RECEIVABLES_TRX_TYPE_ID',
                     g_cec_trx_type_id,
                     p_return_status,
                     p_error_buffer);

  -- Fetch FOB Point
  -- (equivalent of arp_tax.tax_info_rec.fob_point)
  get_tsrm_alphanum_value(p_structure_name,
                          p_structure_index,
                          'FOB_POINT',
                          g_cec_fob_point,
                          p_return_status,
                          p_error_buffer);

   -- Fetch Ship To Site Used Id
   -- Bug 3719109
    ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value (p_structure_name,
                                                p_structure_index,
                                   'SHIP_TO_CUST_ACCT_SITE_USE_ID',
                                                g_cec_ship_to_site_use_id,
                                                p_return_status);

   -- Fetch Bill To Site Used Id
   -- Bug 3719109
    ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value (p_structure_name,
                                                p_structure_index,
                                   'BILL_TO_CUST_ACCT_SITE_USE_ID',
                                                g_cec_bill_to_site_use_id,
                                                p_return_status);
    IF g_cec_ship_to_site_use_id IS NULL THEN
      IF g_cec_bill_to_site_use_id IS NOT NULL THEN
        g_cec_ship_to_party_site_id := g_cec_bill_to_party_site_id;
        g_cec_ship_to_party_id := g_cec_bill_to_party_id;
        g_cec_ship_to_site_use_id := g_cec_bill_to_site_use_id;
      END IF;
    END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.init_cec_params.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: init_cec_params (-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.init_cec_params.END',
                    p_error_buffer);
    END IF;

END init_cec_params;


----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  rule_base_process
--
--  DESCRIPTION
--
--  This procedure is the entry point to Rule based engine, it goes
--  through all the rules for a given tax determination proccess.
--  It evaluates all condition groups of all determining factor templates defined
--  in a rule to determine a result of a given process.
--
--

PROCEDURE rule_base_process(
            p_service_type_code    IN     ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
            p_structure_name       IN     VARCHAR2,
            p_structure_index      IN     BINARY_INTEGER,
            p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_id               IN     ZX_TAXES_B.TAX_ID%TYPE,
            p_tax_status_code      IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_tax_determine_date   IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_tax_rule_code        IN     ZX_RULES_B.TAX_RULE_CODE%TYPE,
            p_recovery_type_code   IN     ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE,
            p_zx_result_rec           OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2)

IS

  l_det_factor_templ_cd_tbl             DET_FACTOR_TEMPL_CODE_TBL;
  l_found                               BOOLEAN;
  l_tax                                 ZX_TAXES_B.TAX%TYPE;
  l_tax_regime_code                     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE;
  l_tax_tbl                             TAX_TBL;
  l_tax_regime_code_tbl                 TAX_REGIME_CODE_TBL;
  l_parent_regime_code_tbl              TAX_REGIME_CODE_TBL;
  l_tax_rule_id_tbl                     TAX_RULE_ID_TBL;
  l_eval_ctr                            NUMBER;
  --CR#4255160. Added new variables to store the Rule level Determining Factor CQ,
  -- Geography type and Geography Id
  l_rule_det_factor_cq_tbl               RULE_DET_FACTOR_CQ_TBL;
  l_rule_geography_type_tbl             RULE_GEOGRAPHY_TYPE_TBL;
  l_rule_geography_id_tbl                RULE_GEOGRAPHY_ID_TBL;

  l_source_event_class_code  ZX_EVNT_CLS_MAPPINGS.EVENT_CLASS_CODE%TYPE;


  --
  -- cursor for getting determining factor templates from rules
  -- for DET_TAX_RATE process
  --
  CURSOR  get_det_factor_templ_csr_a
    (c_service_type_code        ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
     c_tax                      ZX_TAXES_B.TAX%TYPE,
     c_tax_regime_code          ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_determine_date       ZX_LINES.TAX_DETERMINE_DATE%TYPE,
     c_tax_status_code          ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
     c_reference_application_id ZX_RULES_B.APPLICATION_ID%TYPE,
     c_event_class_mapping_id   ZX_RULES_B.EVENT_CLASS_MAPPING_ID%TYPE,
     c_tax_event_class_code     ZX_RULES_B.TAX_EVENT_CLASS_CODE%TYPE
     )
  IS
    SELECT     TAX_RULE_ID,
               TAX,
               TAX_REGIME_CODE,
               DET_FACTOR_TEMPL_CODE,
               DETERMINING_FACTOR_CQ_CODE,
               GEOGRAPHY_TYPE,
               GEOGRAPHY_ID
      FROM     ZX_SCO_RULES_B_V  r
      WHERE    SERVICE_TYPE_CODE = c_service_type_code
        AND    TAX = c_tax     -- In phase 1, tax and regime should not be NULL
        AND    TAX_REGIME_CODE = c_tax_regime_code
        AND    c_tax_determine_date >= EFFECTIVE_FROM
        AND    (c_tax_determine_date <= EFFECTIVE_TO OR
                EFFECTIVE_TO IS NULL)
        AND    System_Default_Flag <> 'Y'
        AND    (APPLICATION_ID = c_reference_application_id OR
                APPLICATION_ID IS NULL)
        AND    (EVENT_CLASS_MAPPING_ID = c_event_class_mapping_id OR
                EVENT_CLASS_MAPPING_ID IS NULL)
        AND    (TAX_EVENT_CLASS_CODE = c_tax_event_class_code OR
                TAX_EVENT_CLASS_CODE IS NULL)
        AND    Enabled_Flag  = 'Y'
        AND    EXISTS (SELECT  result_id
                         FROM  ZX_PROCESS_RESULTS pr
                         WHERE pr.TAX_RULE_ID = r.TAX_RULE_ID
                           AND TAX_STATUS_CODE = c_tax_status_code
                           AND pr.Enabled_Flag = 'Y')
    ORDER BY TAX, PRIORITY;

  --
  -- cursor for getting determining factor templates from rules
  -- for DET_RECOVERY_RATE process
  --
  CURSOR  get_det_factor_templ_csr_b
    (c_service_type_code        ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
     c_tax                      ZX_TAXES_B.TAX%TYPE,
     c_tax_regime_code          ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_determine_date       ZX_LINES.TAX_DETERMINE_DATE%TYPE,
     c_recovery_type_code       ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE,
     c_reference_application_id ZX_RULES_B.APPLICATION_ID%TYPE,
     c_event_class_mapping_id   ZX_RULES_B.EVENT_CLASS_MAPPING_ID%TYPE,
     c_tax_event_class_code     ZX_RULES_B.TAX_EVENT_CLASS_CODE%TYPE)
  IS
    SELECT     TAX_RULE_ID,
               TAX,
               TAX_REGIME_CODE,
               DET_FACTOR_TEMPL_CODE ,
               DETERMINING_FACTOR_CQ_CODE,
               GEOGRAPHY_TYPE,
               GEOGRAPHY_ID
      FROM     ZX_SCO_RULES_B_V  r
      WHERE    SERVICE_TYPE_CODE = c_service_type_code
        AND    TAX = c_tax     -- In phase 1, tax and regime should not be NULL
        AND    TAX_REGIME_CODE = c_tax_regime_code
        AND    c_tax_determine_date >= EFFECTIVE_FROM
        AND    (c_tax_determine_date <= EFFECTIVE_TO OR
                EFFECTIVE_TO IS NULL)
        AND    System_Default_Flag <> 'Y'
        AND    RECOVERY_TYPE_CODE = c_recovery_type_code
        AND    (APPLICATION_ID = c_reference_application_id OR
                APPLICATION_ID IS NULL)
        AND    (EVENT_CLASS_MAPPING_ID = c_event_class_mapping_id OR
                EVENT_CLASS_MAPPING_ID IS NULL)
        AND    (TAX_EVENT_CLASS_CODE = c_tax_event_class_code OR
                TAX_EVENT_CLASS_CODE IS NULL)
        AND    EXISTS (SELECT  result_id
                         FROM  ZX_PROCESS_RESULTS pr
                         WHERE pr.TAX_RULE_ID = r.TAX_RULE_ID
                           AND pr.Enabled_Flag = 'Y')
        AND    Enabled_Flag  = 'Y'
    ORDER BY TAX, PRIORITY;

  --
  -- cursor for getting determining factor templates from rules
  -- for processes other than DET_RECOVERY_RATE and DET_TAX_RATE
  --
  /* Replaced the cursor for bug 3673395 : please see the following cursors in fetch_proc_det_factor_templ:
  new get_det_factor_templ_csr_c,
  new get_det_factor_templ_csr_d
  new get_det_factor_templ_csr_e
  */

  /* CURSOR  get_det_factor_templ_csr_c
    (c_service_type_code        ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
     c_tax                      ZX_TAXES_B.TAX%TYPE,
     c_tax_regime_code          ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_determine_date       ZX_LINES.TAX_DETERMINE_DATE%TYPE,
     c_reference_application_id ZX_RULES_B.APPLICATION_ID%TYPE)
  IS
    SELECT     TAX_RULE_ID,
               TAX,
               TAX_REGIME_CODE,
               DET_FACTOR_TEMPL_CODE,
               DETERMINING_FACTOR_CQ_CODE,
               GEOGRAPHY_TYPE,
               GEOGRAPHY_ID
      FROM     ZX_SCO_RULES_B_V  r
      WHERE    SERVICE_TYPE_CODE = c_service_type_code
        AND    TAX = c_tax      -- In phase 1, tax and regime should not be NULL
        AND    TAX_REGIME_CODE = c_tax_regime_code
        AND    c_tax_determine_date >= EFFECTIVE_FROM
        AND    (c_tax_determine_date <= EFFECTIVE_TO OR
                EFFECTIVE_TO IS NULL)
        AND    System_Default_Flag <> 'Y'
        AND    (APPLICATION_ID = c_reference_application_id OR
                APPLICATION_ID IS NULL)
        AND    Enabled_Flag  = 'Y'
        AND    EXISTS (SELECT  result_id
                         FROM  ZX_PROCESS_RESULTS pr
                         WHERE pr.TAX_RULE_ID = r.TAX_RULE_ID
                           AND pr.Enabled_Flag = 'Y')
    ORDER BY TAX, PRIORITY;

  */



  --
  -- cursor to get a parent regime code for a given tax regime
  --
  CURSOR  get_regime_code_csr
    (c_tax_regime_code       ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_determine_date    ZX_LINES.TAX_DETERMINE_DATE%TYPE)
  IS
  SELECT     PARENT_REGIME_CODE
    FROM     ZX_REGIME_RELATIONS
    WHERE    REGIME_CODE = c_tax_regime_code
--    AND    c_tax_determine_date >= EFFECTIVE_FROM    -- This effective period
--    AND    (c_tax_determine_date <= EFFECTIVE_TO OR  -- should be the same as
--            EFFECTIVE_TO IS NULL)                    -- the one in zx_regimes_b
    ORDER BY PARENT_REG_LEVEL;

BEGIN


  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process.BEGIN',
                  'ZX_TDS_RULE_BASE_DETM_PVT: rule_base_process(+)');
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
                  'p_service_type_code: ' || p_service_type_code ||
                  ', p_tax_id: ' || to_char(p_tax_id)||
                  ', p_tax_status_code: ' || p_tax_status_code ||
                  ', p_recovery_type_code: ' || p_recovery_type_code ||
                  ', p_tax_rule_code:' || p_tax_rule_code );

  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;
  l_found         := FALSE;

  --
  -- check if tax_status_code is null for Tax rate determination
  -- return error if it is null
  --
  IF (p_service_type_code = 'DET_TAX_RATE' AND
      p_tax_status_code IS NULL) THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'Tax status code can not be null for Rate Determination';

    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
                     'p_return_status = ' || p_return_status ||
                     ', p_error_buffer  = ' || p_error_buffer);
    END IF;

    RETURN;
  END IF;

  IF (p_service_type_code = 'DET_RECOVERY_RATE'  AND
      p_recovery_type_code IS NULL) THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'Recovery type can not be null for DET_RECOVERY_RATE';

    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
                     'p_return_status = ' || p_return_status ||
                     ', p_error_buffer  = ' || p_error_buffer);
    END IF;

    RETURN;
  END IF;

  --
  -- get tax and tax regime code from cache structure
  --
  -- Bug#5006424- check if tax info is in cache
  --
  IF NOT ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl.EXISTS(p_tax_id) THEN
    ZX_TDS_UTILITIES_PKG.populate_tax_cache(
                       p_tax_id,
                       p_return_status,
                       p_error_buffer);

    IF p_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
                       'p_return_status = ' || p_return_status ||
                       ', p_error_buffer  = ' || p_error_buffer);
      END IF;
      RETURN;
    END IF;
  END IF;

  l_tax := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(p_tax_id).tax;
  l_tax_regime_code :=
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(p_tax_id).tax_regime_code;

  --
  -- check if rule code is passed, it is from migration
  -- for recovery rate determination
  -- if rule code is passed, it needs to be evaluated first
  --
  IF (p_tax_rule_code IS NOT NULL )  THEN
    process_rule_code(p_service_type_code,
                      p_structure_name,
                      p_structure_index,
                      p_event_class_rec,
                      l_tax,
                      l_tax_regime_code,
                      p_tax_determine_date,
                      p_tax_status_code,
                      p_tax_rule_code,
                      p_recovery_type_code,
                      l_found,
                      p_zx_result_rec,
                      p_return_status,
                      p_error_buffer);

    IF (p_return_status <> FND_API.G_RET_STS_SUCCESS OR l_found)THEN
      -- return to caller if error occurs or success with a result
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
          'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
          'Incorrect return_status after call process_rule_code() OR l_found is true.'||
          ', return_status: '|| p_return_status);
      END IF;

      RETURN;
    END IF;
  END IF;

  IF p_event_class_rec.source_event_class_mapping_id IS NOT NULL THEN

    get_tsrm_alphanum_value(
      p_structure_name,
      p_structure_index,
      'SOURCE_EVENT_CLASS_CODE',
      l_source_event_class_code,
      p_return_status,
      p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
          'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
          'Incorrect return_status after call get_tsrm_alphanum_value().'||
          ', Return_status: '|| p_return_status);
      END IF;
      RETURN;
    END IF;

    IF l_source_event_class_code = 'INTERCOMPANY_TRX' THEN
      l_source_event_class_code := 'INTERCOMPANY_TRANSCATION';
    ELSE
      l_source_event_class_code := NULL;
    END IF;
  END IF;

  IF p_service_type_code = 'DET_TAX_RATE' THEN
    --
    -- get templates from ZX_RULES_B table.
    --
    OPEN get_det_factor_templ_csr_a(p_service_type_code,
                                  l_tax,
                                  l_tax_regime_code,
                                  p_tax_determine_date,
                                  p_tax_status_code,
                                  p_event_class_rec.application_id,
                                  p_event_class_rec.event_class_mapping_id,
                                  NVL(l_source_event_class_code, p_event_class_rec.tax_event_class_code));
    LOOP
      FETCH get_det_factor_templ_csr_a bulk collect into
        l_tax_rule_id_tbl,
        l_tax_tbl,
        l_tax_regime_code_tbl,
        l_det_factor_templ_cd_tbl,
        l_rule_det_factor_cq_tbl,
        l_rule_geography_type_tbl,
        l_rule_geography_id_tbl
      LIMIT C_LINES_PER_COMMIT;

      --CR#4255160 Added new parameters to proc_det_factor_templ procedure, for Geography Context.
      proc_det_factor_templ(
             p_structure_name,
             p_structure_index,
             l_det_factor_templ_cd_tbl,
             p_tax_status_code,
             p_event_class_rec,
             l_tax_tbl,
             p_tax_determine_date,
             p_recovery_type_code,
             l_found,
             l_tax_regime_code_tbl,
             p_service_type_code,
             l_tax_rule_id_tbl,
             l_rule_det_factor_cq_tbl,
             l_rule_geography_type_tbl,
             l_rule_geography_id_tbl,
             p_zx_result_rec,
             p_return_status,
             p_error_buffer);
      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        CLOSE get_det_factor_templ_csr_a;

        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
            'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
             'Incorrect return_status after call proc_det_factor_templ().' ||
             ', return_status: '|| p_return_status);
        END IF;

        EXIT;
      END IF;

      IF (get_det_factor_templ_csr_a%notfound  OR l_found) THEN

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
                         'get_det_factor_templ_csr row count '
                          ||to_char(get_det_factor_templ_csr_a%rowcount));
        END IF;
        CLOSE get_det_factor_templ_csr_a;
        EXIT;
      END IF;
    END LOOP; -- bulk fetch template.

    IF get_det_factor_templ_csr_a%ISOPEN THEN
      CLOSE get_det_factor_templ_csr_a;
    END IF;

  ELSIF p_service_type_code = 'DET_RECOVERY_RATE' THEN
    --
    -- get templates from ZX_RULES_B table.
    --
    OPEN get_det_factor_templ_csr_b(p_service_type_code,
                                  l_tax,
                                  l_tax_regime_code,
                                  p_tax_determine_date,
                                  p_recovery_type_code,
                                  p_event_class_rec.application_id,
                                  p_event_class_rec.event_class_mapping_id,
                                  NVL(l_source_event_class_code, p_event_class_rec.tax_event_class_code));
    LOOP
      FETCH get_det_factor_templ_csr_b bulk collect into
        l_tax_rule_id_tbl,
        l_tax_tbl,
        l_tax_regime_code_tbl,
        l_det_factor_templ_cd_tbl,
        l_rule_det_factor_cq_tbl,
        l_rule_geography_type_tbl,
        l_rule_geography_id_tbl
      LIMIT C_LINES_PER_COMMIT;

      --CR#4255160 Added new parameters to proc_det_factor_templ procedure, for Geography Context.
      proc_det_factor_templ(
             p_structure_name,
             p_structure_index,
             l_det_factor_templ_cd_tbl,
             p_tax_status_code,
             p_event_class_rec,
             l_tax_tbl,
             p_tax_determine_date,
             p_recovery_type_code,
             l_found,
             l_tax_regime_code_tbl,
             p_service_type_code,
             l_tax_rule_id_tbl,
             l_rule_det_factor_cq_tbl,
             l_rule_geography_type_tbl,
             l_rule_geography_id_tbl,
             p_zx_result_rec,
             p_return_status,
             p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        CLOSE get_det_factor_templ_csr_b;
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
            'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
            'Incorrect return_status after call proc_det_factor_templ().' ||
            ', return_status: '|| p_return_status);
        END IF;

        EXIT;
      END IF;

      IF (get_det_factor_templ_csr_b%notfound  OR l_found) THEN

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
                         'get_det_factor_templ_csr row count '
                          ||to_char(get_det_factor_templ_csr_b%rowcount));
        END IF;
        CLOSE get_det_factor_templ_csr_b;
        EXIT;
      END IF;
    END LOOP; -- bulk fetch template.

    IF get_det_factor_templ_csr_b%ISOPEN THEN
      CLOSE get_det_factor_templ_csr_b;
    END IF;

  ELSE  -- p_service_type_code other than 'DET_TAX_RATE' and 'DET_RECOVERY_RATE'

    -- Bugfix 3673395

    fetch_proc_det_factor_templ(
              p_structure_name,
              p_structure_index,
              p_tax_status_code,
              p_event_class_rec,
              p_tax_determine_date,
              p_recovery_type_code,
              l_found,
              p_service_type_code,
              p_zx_result_rec,
              l_tax,
              l_tax_regime_code,
              p_return_status,
              p_error_buffer) ;

    /* Bug 4017396 - included the check for p_return_status*/
    IF ( p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
                       'p_return_status = ' || p_return_status ||
                       ', p_error_buffer  = ' || p_error_buffer);

      END IF;
    END IF;

  END IF;   -- p_service_type_code = 'DET_TAX_RATE'/'DET_RECOVERY_RATE' OR ELSE

/* comment this out as in Phase 1 only rules at tax level are supported.
  IF (NOT l_found AND p_return_status = FND_API.G_RET_STS_SUCCESS) THEN

    --
    -- traverse the regime hierarchy to get rules
    --
    OPEN get_regime_code_csr(l_tax_regime_code,
                             p_tax_determine_date);

    LOOP
      FETCH get_regime_code_csr  bulk collect into l_parent_regime_code_tbl
      LIMIT C_LINES_PER_COMMIT;

        get_rule_from_regime_hier(
             p_service_type_code,
             p_structure_name,
             p_structure_index,
             p_event_class_rec,
             p_tax_status_code,
             p_tax_determine_date,
             p_recovery_type_code,
             p_zx_result_rec,
             l_found,
             l_parent_regime_code_tbl,
             p_return_status,
             p_error_buffer);
        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          CLOSE get_regime_code_csr;

          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
              'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
              'Incorrect return_status after call get_rule_from_regime_hier().'||
              ', return_status: '|| p_return_status);
          END IF;

          EXIT;
        END IF;
      IF (get_regime_code_csr%notfound  OR l_found) THEN

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
                         'get_regime_code_csr row count '||
                          to_char(get_regime_code_csr%rowcount));
        END IF;
        CLOSE get_regime_code_csr;
        EXIT;
      END IF;

    END LOOP;

    IF get_regime_code_csr%ISOPEN THEN
      CLOSE get_regime_code_csr;
    END IF;

 END IF;

*/

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
                   'alphanumeric_result: ' || p_zx_result_rec.alphanumeric_result);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: rule_base_process(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF get_det_factor_templ_csr_a%ISOPEN THEN
        CLOSE get_det_factor_templ_csr_a;
      ELSIF get_det_factor_templ_csr_b%ISOPEN THEN
        CLOSE get_det_factor_templ_csr_b;
      ELSIF get_regime_code_csr%ISOPEN THEN
        CLOSE get_regime_code_csr;
      END IF;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
                        p_error_buffer);
      END IF;

END rule_base_process;

------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  process_rule_code
--
--  DESCRIPTION
--  This procedure processes rule code  for recovery rate determination
--  from migration
--
PROCEDURE process_rule_code(
            p_service_type_code    IN     ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
            p_structure_name       IN     VARCHAR2,
            p_structure_index      IN     BINARY_INTEGER,
            p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax                  IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code      IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax_determine_date   IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_tax_status_code      IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_tax_rule_code        IN     ZX_RULES_B.TAX_RULE_CODE%TYPE,
            p_recovery_type_code   IN     ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE,
            p_found                IN OUT NOCOPY BOOLEAN,
            p_zx_result_rec           OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2)
IS
  l_det_factor_templ_cd         ZX_RULES_B.DET_FACTOR_TEMPL_CODE%TYPE;
  l_condition_group_code        ZX_CONDITION_GROUPS_B.CONDITION_GROUP_CODE%TYPE;
  l_result                      BOOLEAN;
  l_result_id                   ZX_PROCESS_RESULTS.RESULT_ID%TYPE;
  l_tax_rule_id                 ZX_RULES_B.TAX_RULE_ID%TYPE;

  l_valid                       BOOLEAN;

  --
  -- cursor for getting recovery templates from rules
  --
  CURSOR  get_recovery_templ_csr
    (c_service_type_code        ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
     c_tax                      ZX_TAXES_B.TAX%TYPE,
     c_tax_regime_code          ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_determine_date       ZX_LINES.TAX_DETERMINE_DATE%TYPE,
     c_recovery_type_code       ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE,
     c_tax_rule_code            ZX_RULES_B.TAX_RULE_CODE%TYPE,
     c_reference_application_id ZX_RULES_B.APPLICATION_ID%TYPE,
     c_event_class_mapping_id   ZX_RULES_B.EVENT_CLASS_MAPPING_ID%TYPE,
     c_tax_event_class_code     ZX_RULES_B.TAX_EVENT_CLASS_CODE%TYPE)
  IS
    SELECT     TAX_RULE_ID,
               DET_FACTOR_TEMPL_CODE
      FROM     ZX_SCO_RULES_B_V  r
      WHERE    SERVICE_TYPE_CODE = c_service_type_code
        AND    TAX = c_tax
        AND    TAX_REGIME_CODE = c_tax_regime_code
        AND    c_tax_determine_date >= EFFECTIVE_FROM
        AND    (c_tax_determine_date <= EFFECTIVE_TO OR
                EFFECTIVE_TO IS NULL)
        AND    TAX_RULE_CODE = c_tax_rule_code
        AND    RECOVERY_TYPE_CODE = c_recovery_type_code
        AND    NVL(System_Default_Flag, 'N')  = 'Y'
        AND    (APPLICATION_ID = c_reference_application_id
                OR APPLICATION_ID IS NULL)
        AND    (EVENT_CLASS_MAPPING_ID = c_event_class_mapping_id OR
                EVENT_CLASS_MAPPING_ID IS NULL)
        AND    (TAX_EVENT_CLASS_CODE = c_tax_event_class_code OR
                TAX_EVENT_CLASS_CODE IS NULL)
        AND    Enabled_Flag  = 'Y'
    ORDER BY TAX, PRIORITY;

  --
  -- cursor for getting offset templates from rules
  --
/*********************
  CURSOR  get_offset_templ_csr
    (c_service_type_code        ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
     c_tax                      ZX_TAXES_B.TAX%TYPE,
     c_tax_regime_code          ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_determine_date       ZX_LINES.TAX_DETERMINE_DATE%TYPE,
     c_tax_rule_code            ZX_RULES_B.TAX_RULE_CODE%TYPE,
     c_reference_application_id ZX_RULES_B.APPLICATION_ID%TYPE)
  IS
    SELECT     TAX_RULE_ID,
               det_factor_templ_code
      FROM     ZX_SCO_RULES_B_V
      WHERE    SERVICE_TYPE_CODE = c_service_type_code
        AND    TAX = c_tax
        AND    TAX_REGIME_CODE = c_tax_regime_code
        AND    c_tax_determine_date >= EFFECTIVE_FROM
        AND    (c_tax_determine_date <= EFFECTIVE_TO OR
                EFFECTIVE_TO IS NULL)
        AND    TAX_RULE_CODE = c_tax_rule_code
        AND    RECOVERY_TYPE_CODE IS NULL
        AND    System_Default_Flag = 'Y'
        AND    APPLICATION_ID = c_reference_application_id
        AND    Enabled_Flag  = 'Y'
    ORDER BY TAX, PRIORITY;
*************************/

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_rule_code.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: process_rule_code(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- determine which cursor to open
  --
  IF p_service_type_code = 'DET_RECOVERY_RATE' THEN
    --
    -- get recovery templates from ZX_RULES_B table.
    --
    OPEN get_recovery_templ_csr(p_service_type_code,
                                p_tax,
                                p_tax_regime_code,
                                p_tax_determine_date,
                                p_recovery_type_code,
                                p_tax_rule_code,
                                p_event_class_rec.application_id,
                                p_event_class_rec.event_class_mapping_id,
                                p_event_class_rec.tax_event_class_code);
    FETCH get_recovery_templ_csr  into l_tax_rule_id, l_det_factor_templ_cd;
    IF get_recovery_templ_csr%NOTFOUND THEN
      CLOSE get_recovery_templ_csr;
      RETURN;
    END IF;
    CLOSE get_recovery_templ_csr;
/************************
  ELSIF p_service_type_code = 'DET_OFFSET_TAX' THEN
    --
    -- get offset templates from ZX_RULES_B table.
    --
    OPEN get_offset_templ_csr(p_service_type_code,
                              p_tax,
                              p_tax_regime_code,
                              p_tax_determine_date,
                              p_tax_rule_code,
                              p_event_class_rec.application_id);
    FETCH get_offset_templ_csr into l_tax_rule_id, l_det_factor_templ_cd;
    IF get_offset_templ_csr%NOTFOUND THEN
      CLOSE get_offset_templ_csr;
      RETURN;
    END IF;
    CLOSE get_offset_templ_csr;
**********************/
  ELSE
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'Invalid service type code for the tax rule code';
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_rule_code',
                     'p_return_status = ' || p_return_status ||
                     ', p_error_buffer  = ' || p_error_buffer);
    END IF;
    RETURN;
  END IF;

    -- Bug 4166241: for the template, check if the parameters associated with the determining factors
    -- are supported for the given Application

    check_templ_tax_parameter(
      l_det_factor_templ_cd,
      p_event_class_rec,
      l_valid,
      p_return_status,
      p_error_buffer);

    -- process the template only if its parameters are valid for the given application
    IF (l_valid AND p_return_status = FND_API.G_RET_STS_SUCCESS) THEN

      -- get all the condition groups and conditions
      proc_condition_group_per_templ(
                       p_structure_name,
                       p_structure_index,
                       l_det_factor_templ_cd,
                       p_event_class_rec,
                       p_tax,
                       p_tax_regime_code,
                       p_tax_determine_date,
                       p_service_type_code,
                       l_tax_rule_id,
                       p_tax_status_code,
                       l_result,
                       l_result_id,
                       p_found,
                       p_zx_result_rec,
                       p_return_status,
                       p_error_buffer);

      -- if the whole condition is satisfied, put result to p_zx_result_rec
/*  getting called from within proc_condition_group_per_templ
      IF (l_result) THEN
         get_result(
                    l_result_id,
                    p_structure_name,
                    p_structure_index,
                    p_tax_regime_code,
                    p_tax,
                    p_tax_determine_date,
                    p_found,
                    p_zx_result_rec,
                    p_return_status,
                    p_error_buffer);
      END IF;
   */
--  EXIT WHEN (p_found OR p_return_status <> FND_API.G_RET_STS_SUCCESS);
  END IF;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_rule_code',
                   'alphanumeric_result: ' || p_zx_result_rec.alphanumeric_result);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_rule_code.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: process_rule_code(-)');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF get_recovery_templ_csr%ISOPEN THEN
        CLOSE get_recovery_templ_csr;
      END IF;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_rule_code',
                        p_error_buffer);
      END IF;

END process_rule_code;

------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  fetch_proc_det_factor_templ
--
--  DESCRIPTION
--  This procedure is to evaluate the Rules, based on
--  source event and other attributes first, source tax event attributes
--  second, current event class and other attributes third,current tax event
--  class and other attributes 4th,
--  null event class, null tax event class and not null tax and not null
--  regimes as the last search level.
--

PROCEDURE fetch_proc_det_factor_templ(
            p_structure_name          IN     VARCHAR2,
            p_structure_index         IN     BINARY_INTEGER,
            p_tax_status_code         IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_event_class_rec         IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_determine_date      IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_recovery_type_code      IN     ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE,
            p_found                   IN OUT NOCOPY BOOLEAN,
            p_service_type_code       IN     ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
            p_zx_result_rec           OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
            p_tax                     IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code         IN      ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2)
IS

  /* Bugfix3673395 */
  --
  -- cursors for getting determining factor templates from rules
  -- for processes other than DET_RECOVERY_RATE and DET_TAX_RATE
  --

  CURSOR  get_det_factor_templ_csr_c
    (c_service_type_code        ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
     c_tax                      ZX_TAXES_B.TAX%TYPE,
     c_tax_regime_code          ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_determine_date       ZX_LINES.TAX_DETERMINE_DATE%TYPE,
     c_event_class_mapping_id   ZX_RULES_B.EVENT_CLASS_MAPPING_ID%TYPE)
  IS
    SELECT     TAX_RULE_ID,
               TAX,
               TAX_REGIME_CODE,
               DET_FACTOR_TEMPL_CODE,
               DETERMINING_FACTOR_CQ_CODE,
               GEOGRAPHY_TYPE,
               GEOGRAPHY_ID
      FROM     ZX_SCO_RULES_B_V  r
      WHERE    SERVICE_TYPE_CODE = c_service_type_code
        AND    TAX = c_tax      -- In phase 1, tax and regime should not be NULL
        AND    TAX_REGIME_CODE = c_tax_regime_code
        AND    c_tax_determine_date >= EFFECTIVE_FROM
        AND    (c_tax_determine_date <= EFFECTIVE_TO OR
               EFFECTIVE_TO IS NULL)
        AND    System_Default_Flag <> 'Y'
        AND    EVENT_CLASS_MAPPING_ID = c_event_class_mapping_id
        AND    Enabled_Flag  = 'Y'
        AND    EXISTS (SELECT  result_id
                         FROM  ZX_PROCESS_RESULTS pr
                         WHERE pr.TAX_RULE_ID = r.TAX_RULE_ID
             AND pr.enabled_flag = 'Y')
  ORDER BY PRIORITY;

  CURSOR  get_det_factor_templ_csr_d
    (c_service_type_code        ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
     c_tax                      ZX_TAXES_B.TAX%TYPE,
     c_tax_regime_code          ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_determine_date       ZX_LINES.TAX_DETERMINE_DATE%TYPE,
     c_tax_event_class_code     ZX_RULES_B.TAX_EVENT_CLASS_CODE%TYPE)
  IS
    SELECT     TAX_RULE_ID,
               TAX,
               TAX_REGIME_CODE,
               DET_FACTOR_TEMPL_CODE,
               DETERMINING_FACTOR_CQ_CODE,
               GEOGRAPHY_TYPE,
               GEOGRAPHY_ID
      FROM     ZX_SCO_RULES_B_V  r
      WHERE    SERVICE_TYPE_CODE = c_service_type_code
        AND    TAX = c_tax      -- In phase 1, tax and regime should not be NULL
        AND    TAX_REGIME_CODE = c_tax_regime_code
        AND    c_tax_determine_date >= EFFECTIVE_FROM
        AND    (c_tax_determine_date <= EFFECTIVE_TO OR
                EFFECTIVE_TO IS NULL)
        AND    System_Default_Flag <> 'Y'
        AND    TAX_EVENT_CLASS_CODE = c_tax_event_class_code
        AND    Enabled_Flag  = 'Y'
        AND    EXISTS (SELECT  result_id
                         FROM  ZX_PROCESS_RESULTS pr
                         WHERE pr.TAX_RULE_ID = r.TAX_RULE_ID
                           AND pr.Enabled_Flag = 'Y')
    ORDER BY PRIORITY;

  CURSOR  get_det_factor_templ_csr_e
    (c_service_type_code        ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
     c_tax                      ZX_TAXES_B.TAX%TYPE,
     c_tax_regime_code          ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_determine_date       ZX_LINES.TAX_DETERMINE_DATE%TYPE,
     c_event_class_mapping_id   ZX_RULES_B.EVENT_CLASS_MAPPING_ID%TYPE,
     c_tax_event_class_code     ZX_RULES_B.TAX_EVENT_CLASS_CODE%TYPE
     )
  IS
    SELECT     TAX_RULE_ID,
               TAX,
               TAX_REGIME_CODE,
               DET_FACTOR_TEMPL_CODE,
               DETERMINING_FACTOR_CQ_CODE,
         GEOGRAPHY_TYPE,
               GEOGRAPHY_ID
      FROM     ZX_SCO_RULES_B_V  r
      WHERE    SERVICE_TYPE_CODE = c_service_type_code
        AND    TAX = c_tax
        AND    TAX_REGIME_CODE = c_tax_regime_code
        AND    c_tax_determine_date >= EFFECTIVE_FROM
        AND    (c_tax_determine_date <= EFFECTIVE_TO OR
                EFFECTIVE_TO IS NULL)
        AND    System_Default_Flag <> 'Y'
        AND    (TAX_EVENT_CLASS_CODE IS NULL OR
                TAX_EVENT_CLASS_CODE = c_tax_event_class_code)
        AND    (EVENT_CLASS_MAPPING_ID IS NULL OR
                EVENT_CLASS_MAPPING_ID = c_event_class_mapping_id)
        AND    Enabled_Flag  = 'Y'
        AND    EXISTS (SELECT  result_id
                         FROM  ZX_PROCESS_RESULTS pr
                         WHERE pr.TAX_RULE_ID = r.TAX_RULE_ID
                           AND pr.Enabled_Flag = 'Y')
    ORDER BY EVENT_CLASS_MAPPING_ID NULLS LAST,
             TAX_EVENT_CLASS_CODE NULLS LAST,
             PRIORITY;


  l_det_factor_templ_cd_tbl             DET_FACTOR_TEMPL_CODE_TBL;
  l_tax_tbl                             TAX_TBL;
  l_tax_regime_code_tbl                 TAX_REGIME_CODE_TBL;
  l_tax_rule_id_tbl                     TAX_RULE_ID_TBL;

  --Bug 4670938 - Changed the type since EVENT_CLASS_CODE is removed from zx_rules_b
  l_source_event_class_code  ZX_EVNT_CLS_MAPPINGS.EVENT_CLASS_CODE%TYPE;

  --CR#4255160. Added new variables to store the Rule level Determining Factor CQ,
  -- Geography type and Geography Id
  l_rule_det_factor_cq_tbl              RULE_DET_FACTOR_CQ_TBL;
  l_rule_geography_type_tbl           RULE_GEOGRAPHY_TYPE_TBL;
  l_rule_geography_id_tbl    RULE_GEOGRAPHY_ID_TBL;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  /*Bug fix 4017396*/
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: fetch_proc_det_factor_templ(+)');
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
                   'source_event_class_mapping_id : ' ||
                   TO_CHAR(p_event_class_rec.source_event_class_mapping_id) ||
                   ', source_tax_event_class_code: ' ||
                   p_event_class_rec.source_tax_event_class_code ||
                   ', event_class_mapping_id : ' ||
                   TO_CHAR(p_event_class_rec.event_class_mapping_id) ||
                   ', tax_event_class_code: ' ||
                   p_event_class_rec.tax_event_class_code);

  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS; --Included as part of Bug fix 4017396

  IF p_event_class_rec.source_event_class_mapping_id IS NOT NULL THEN

    get_tsrm_alphanum_value(
      p_structure_name,
      p_structure_index,
      'SOURCE_EVENT_CLASS_CODE',
      l_source_event_class_code,
      p_return_status,
      p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
          'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
          'Incorrect return_status after call get_tsrm_alphanum_value().'||
          ', Return_status: '|| p_return_status);
      END IF;
      RETURN;
    END IF;
    --
    -- Bug#4653492- do nothing if this is intercompany trx
    --
    IF l_source_event_class_code = 'INTERCOMPANY_TRX' THEN

       IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
    'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
    'for intercompany trx, skip rules for the source event class and source tax event class');
       END IF;
    ELSE

      -- Firstly, pick rules for source event mapping, tax regime, tax

      -- Bug 4670938 - Fetch the source_event_class_mapping_id from event_class_rec
      -- and pass it to the cursor since we no longer store the Application Event class code
      -- on Rules, but store only the event_class_mapping_id

      OPEN get_det_factor_templ_csr_c
           (p_service_type_code,
         p_tax,
      p_tax_regime_code,
      p_tax_determine_date,
            p_event_class_rec.source_event_class_mapping_id);
      LOOP
        FETCH get_det_factor_templ_csr_c BULK COLLECT INTO
                l_tax_rule_id_tbl,
                l_tax_tbl,
                l_tax_regime_code_tbl,
                l_det_factor_templ_cd_tbl,
                l_rule_det_factor_cq_tbl,
                l_rule_geography_type_tbl,
                l_rule_geography_id_tbl
               LIMIT C_LINES_PER_COMMIT;

             --CR#4255160 - Added new parameters for Detfactor CQ, Geo type and Geo Id
          proc_det_factor_templ(
            p_structure_name,
            p_structure_index,
            l_det_factor_templ_cd_tbl,
            p_tax_status_code,
            p_event_class_rec,
            l_tax_tbl,
            p_tax_determine_date,
            p_recovery_type_code,
            p_found,
            l_tax_regime_code_tbl,
            p_service_type_code,
            l_tax_rule_id_tbl,
            l_rule_det_factor_cq_tbl,
            l_rule_geography_type_tbl,
            l_rule_geography_id_tbl,
            p_zx_result_rec,
            p_return_status,
            p_error_buffer);

          IF (p_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            CLOSE get_det_factor_templ_csr_c;

            IF (g_level_error >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_error,
                'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
                'Incorrect return_status after call proc_det_factor_templ().'||
                ', Return_status: '|| p_return_status);
            END IF;

            RETURN;    --EXIT;
          END IF;

          IF (get_det_factor_templ_csr_c%NOTFOUND OR p_found) THEN
            IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
                       'get_det_factor_templ_csr_c row count ' ||
                             TO_CHAR(get_det_factor_templ_csr_c%rowcount));
            END IF;
            CLOSE get_det_factor_templ_csr_c;
            EXIT;
          END IF;
      END LOOP; -- bulk fetch template get_det_factor_templ_csr_c

      IF get_det_factor_templ_csr_c%ISOPEN THEN
        CLOSE get_det_factor_templ_csr_c;
      END IF;

      IF NOT p_found THEN
       -- Secondly, pick rules for source tax event class, tax regime, tax
       IF (p_event_class_rec.source_tax_event_class_code <>
           p_event_class_rec.tax_event_class_code) THEN
         OPEN get_det_factor_templ_csr_d(
                                   p_service_type_code,
                             p_tax,
                             p_tax_regime_code,
                             p_tax_determine_date,
           p_event_class_rec.source_tax_event_class_code);
         LOOP
           FETCH get_det_factor_templ_csr_d BULK COLLECT INTO
              l_tax_rule_id_tbl,
              l_tax_tbl,
              l_tax_regime_code_tbl,
              l_det_factor_templ_cd_tbl,
              l_rule_det_factor_cq_tbl,
                l_rule_geography_type_tbl,
              l_rule_geography_id_tbl
             LIMIT C_LINES_PER_COMMIT;

            --CR#4255160 - Added new parameters for Det factor CQ, Geo type and Geo Id
            proc_det_factor_templ(
                  p_structure_name,
                  p_structure_index,
                  l_det_factor_templ_cd_tbl,
                  p_tax_status_code,
                  p_event_class_rec,
                  l_tax_tbl,
                  p_tax_determine_date,
                  p_recovery_type_code,
                  p_found,
                  l_tax_regime_code_tbl,
                  p_service_type_code,
                  l_tax_rule_id_tbl,
                  l_rule_det_factor_cq_tbl,
                  l_rule_geography_type_tbl,
                  l_rule_geography_id_tbl,
                  p_zx_result_rec,
                  p_return_status,
                  p_error_buffer);

            IF (p_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            CLOSE get_det_factor_templ_csr_d;

                IF (g_level_error >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_error,
                    'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
                    'Incorrect return_status after call proc_det_factor_templ().'||
                    ', Return_status: '|| p_return_status);
                END IF;

            RETURN;     --EXIT;
            END IF;

            IF (get_det_factor_templ_csr_d%NOTFOUND OR p_found) THEN
              IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
                   'get_det_factor_templ_csr_d row count ' ||
                                TO_CHAR(get_det_factor_templ_csr_d%rowcount));
              END IF;
              CLOSE get_det_factor_templ_csr_d;
              EXIT;
            END IF;
           END LOOP;     -- bulk fetch template get_det_factor_templ_csr_d

           IF get_det_factor_templ_csr_d%ISOPEN THEN
             CLOSE get_det_factor_templ_csr_d;
           END IF;

        END IF;           -- p_event_class_rec.source_tax_event_class_code <> p_event_class_rec.tax_event_class_code
      END IF;        -- p_found
    END IF;        -- l_source_event_class_code = 'INTERCOMPANY_TRX'
  END IF; -- End check for source_event_class_mapping_id

  IF l_source_event_class_code = 'INTERCOMPANY_TRX' THEN
    l_source_event_class_code := 'INTERCOMPANY_TRANSACTION';
  ELSE
    l_source_event_class_code := NULL;
  END IF;

  IF NOT p_found THEN

    -- thirdly, pick rules for current event mapping, application, tax regime, tax
    -- then, pick rules for current tax event class, tax regime, tax
    -- then, pick rules for null event mapping, null tax event class, and tax regime and tax

    --Bug 4670938 - Replaced event_class_code by event_class_mapping_id
    OPEN get_det_factor_templ_csr_e(p_service_type_code,
                            p_tax,
                            p_tax_regime_code,
                            p_tax_determine_date,
          p_event_class_rec.event_class_mapping_id,
          NVL(l_source_event_class_code, p_event_class_rec.tax_event_class_code));
    LOOP
      FETCH get_det_factor_templ_csr_e BULK COLLECT INTO
            l_tax_rule_id_tbl,
            l_tax_tbl,
            l_tax_regime_code_tbl,
            l_det_factor_templ_cd_tbl,
            l_rule_det_factor_cq_tbl,
      l_rule_geography_type_tbl,
            l_rule_geography_id_tbl
          LIMIT C_LINES_PER_COMMIT;

      --CR#4255160 - Added new parameters for Det factor CQ, Geo type and Geo Id
      proc_det_factor_templ(
                     p_structure_name,
                     p_structure_index,
                     l_det_factor_templ_cd_tbl,
                     p_tax_status_code,
                     p_event_class_rec,
                     l_tax_tbl,
                     p_tax_determine_date,
                     p_recovery_type_code,
                     p_found,
                     l_tax_regime_code_tbl,
                     p_service_type_code,
                     l_tax_rule_id_tbl,
                     l_rule_det_factor_cq_tbl,
                     l_rule_geography_type_tbl,
                     l_rule_geography_id_tbl,
                     p_zx_result_rec,
                     p_return_status,
                     p_error_buffer);

        IF (p_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          CLOSE get_det_factor_templ_csr_e;

          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
              'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
              'Incorrect return_status after call proc_det_factor_templ().'||
              ', Return_status: '|| p_return_status);
          END IF;

          RETURN;     --EXIT;
        END IF;

        IF (get_det_factor_templ_csr_e%NOTFOUND OR p_found) THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
         'get_det_factor_templ_csr_e row count ' ||
                            TO_CHAR(get_det_factor_templ_csr_e%rowcount));
          END IF;
          CLOSE get_det_factor_templ_csr_e;
          EXIT;
        END IF;

    END LOOP; -- bulk fetch template get_det_factor_templ_csr_e

    IF get_det_factor_templ_csr_e%ISOPEN THEN
      CLOSE get_det_factor_templ_csr_e;
    END IF;

  END IF;     -- process of current event mapping and tax event class code

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ.END',
                    'ZX_TDS_RULE_BASE_DETM_PVT: fetch_proc_det_factor_templ(-)' ||
                    ', p_return_status = ' || p_return_status ||
                    ', p_error_buffer = ' || p_error_buffer);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF get_det_factor_templ_csr_c%ISOPEN THEN
        CLOSE get_det_factor_templ_csr_c;
      ELSIF get_det_factor_templ_csr_d%ISOPEN THEN
        CLOSE get_det_factor_templ_csr_d;
      ELSIF get_det_factor_templ_csr_e%ISOPEN THEN
        CLOSE get_det_factor_templ_csr_e;
      END IF;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                         'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
                          p_error_buffer);
      END IF;

END FETCH_PROC_DET_FACTOR_TEMPL;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_rule_from_regime_hier
--
--  DESCRIPTION
--  This procedure gets determining factor templates defined for rules
--  at parent regime levels
--
--  History
--
--    Phong La                    03-JUN-02  Created


PROCEDURE get_rule_from_regime_hier(
            p_service_type_code    IN     ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
            p_structure_name       IN     VARCHAR2,
            p_structure_index      IN     BINARY_INTEGER,
            p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_status_code      IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_tax_determine_date   IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_recovery_type_code   IN     ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE,
            p_zx_result_rec           OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
            p_found                IN OUT NOCOPY BOOLEAN,
            p_parent_regime_cd_tbl IN     TAX_REGIME_CODE_TBL,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2)

IS

  l_det_factor_templ_cd_tbl     DET_FACTOR_TEMPL_CODE_TBL;
  l_tax_tbl                     TAX_TBL;
  l_tax_regime_code_tbl         TAX_REGIME_CODE_TBL;
  l_tax_rule_id_tbl             TAX_RULE_ID_TBL;
  l_count                       NUMBER;

  --CR#4255160. Added new variables to store the Rule level Determining Factor CQ,
  -- Geography type and Geography Id
  l_rule_det_factor_cq_tbl              RULE_DET_FACTOR_CQ_TBL;
  l_rule_geography_type_tbl             RULE_GEOGRAPHY_TYPE_TBL;
  l_rule_geography_id_tbl                RULE_GEOGRAPHY_ID_TBL;


  CURSOR  get_templ_from_regime_hier_csr
    (c_service_type_code        ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
     c_tax_regime_code          ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_determine_date       ZX_LINES.TAX_DETERMINE_DATE%TYPE,
     c_recovery_type_code       ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE,
     c_tax_status_code          ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
     c_reference_application_id ZX_RULES_B.APPLICATION_ID%TYPE)
  IS
  SELECT     TAX_RULE_ID, TAX,  TAX_REGIME_CODE, DET_FACTOR_TEMPL_CODE,
             DETERMINING_FACTOR_CQ_CODE,
             GEOGRAPHY_TYPE,
             GEOGRAPHY_ID
    FROM     ZX_SCO_RULES_B_V r
    WHERE    SERVICE_TYPE_CODE = c_service_type_code
      AND    TAX IS NULL
      AND    TAX_REGIME_CODE = c_tax_regime_code
      AND    c_tax_determine_date >= EFFECTIVE_FROM
      AND    (c_tax_determine_date <= EFFECTIVE_TO OR
              EFFECTIVE_TO IS NULL)
      AND    (RECOVERY_TYPE_CODE   = c_recovery_type_code OR
              RECOVERY_TYPE_CODE IS NULL)
      AND    NVL(System_Default_Flag, 'N')  <> 'Y'
      AND    (APPLICATION_ID = c_reference_application_id OR
              APPLICATION_ID IS NULL)
      AND    Enabled_Flag  = 'Y'
      AND    EXISTS (SELECT result_id
                       FROM ZX_PROCESS_RESULTS pr
                       WHERE pr.TAX_RULE_ID = r.TAX_RULE_ID)
    ORDER BY PRIORITY;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_rule_from_regime_hier.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_rule_from_regime_hier(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  l_count := p_parent_regime_cd_tbl.count;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_rule_from_regime_hier',
                   'parent regime count: ' || to_char(l_count));
  END IF;

  FOR  i IN 1.. l_count LOOP

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_rule_from_regime_hier',
                     'parent regime: ' || p_parent_regime_cd_tbl(i));
    END IF;

    --
    -- get templates from ZX_RULES_B table.
    --

    OPEN get_templ_from_regime_hier_csr(p_service_type_code,
                                        p_parent_regime_cd_tbl(i),
                                        p_tax_determine_date,
                                        p_recovery_type_code,
                                        p_tax_status_code,
                                        p_event_class_rec.application_id);

    LOOP
      FETCH get_templ_from_regime_hier_csr bulk collect into
          l_tax_rule_id_tbl,
          l_tax_tbl,
          l_tax_regime_code_tbl,
          l_det_factor_templ_cd_tbl,
          l_rule_det_factor_cq_tbl ,
          l_rule_geography_type_tbl,
          l_rule_geography_id_tbl
      LIMIT C_LINES_PER_COMMIT;

      --CR#4255160 - Added new parameters for Det factor CQ, Geo type and Geo Id
      proc_det_factor_templ(
           p_structure_name,
           p_structure_index,
           l_det_factor_templ_cd_tbl,
           p_tax_status_code,
           p_event_class_rec,
           l_tax_tbl,
           p_tax_determine_date,
           p_recovery_type_code,
           p_found,
           l_tax_regime_code_tbl,
           p_service_type_code,
           l_tax_rule_id_tbl,
           l_rule_det_factor_cq_tbl ,
     l_rule_geography_type_tbl,
           l_rule_geography_id_tbl,
           p_zx_result_rec,
           p_return_status,
           p_error_buffer);
      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        CLOSE get_templ_from_regime_hier_csr;

        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
            'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
            'Incorrect return_status after call proc_det_factor_templ().'||
            ', Return_status: '|| p_return_status);
        END IF;

        EXIT;
      END IF;

      IF (get_templ_from_regime_hier_csr%notfound  OR p_found) THEN
        CLOSE get_templ_from_regime_hier_csr;

        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
            'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.fetch_proc_det_factor_templ',
            'Incorrect return_status after call proc_det_factor_templ().' ||
            ', Return_status: '|| p_return_status);
        END IF;

        EXIT;
      END IF;

    END LOOP; -- bulk fetch template.

    IF get_templ_from_regime_hier_csr%ISOPEN THEN
      CLOSE get_templ_from_regime_hier_csr;
    END IF;

    EXIT WHEN (p_found OR p_return_status = FND_API.G_RET_STS_ERROR);
  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_rule_from_regime_hier.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_rule_from_regime_hier(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF get_templ_from_regime_hier_csr%ISOPEN THEN
        CLOSE get_templ_from_regime_hier_csr;
      END IF;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_rule_from_regime_hier',
                        p_error_buffer);
      END IF;

END get_rule_from_regime_hier;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  proc_det_factor_templ
--
--  DESCRIPTION
--    This procedure processes all condition groups for each determining
--    factor template
--
PROCEDURE proc_det_factor_templ(
            p_structure_name          IN     VARCHAR2,
            p_structure_index         IN     BINARY_INTEGER,
            p_det_factor_templ_cd_tbl IN     det_factor_templ_code_tbl,
            p_tax_status_code         IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_event_class_rec         IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_tbl                 IN     TAX_TBL,
            p_tax_determine_date      IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_recovery_type_code      IN     ZX_RULES_B.RECOVERY_TYPE_CODE%TYPE,
            p_found                   IN OUT NOCOPY BOOLEAN,
            p_tax_regime_code_tbl     IN     TAX_REGIME_CODE_TBL,
            p_service_type_code       IN     ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
            p_tax_rule_id_tbl         IN     TAX_RULE_ID_TBL,
            p_rule_det_factor_cq_tbl  IN     RULE_DET_FACTOR_CQ_TBL,
            p_rule_geography_type_tbl IN     RULE_GEOGRAPHY_TYPE_TBL,
            p_rule_geography_id_tbl   IN     RULE_GEOGRAPHY_ID_TBL,
            p_zx_result_rec              OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
            p_return_status              OUT NOCOPY VARCHAR2,
            p_error_buffer               OUT NOCOPY VARCHAR2)
IS
  l_count                  NUMBER;
  l_det_factor_templ_code  ZX_DET_FACTOR_TEMPL_B.det_factor_templ_code%TYPE;
  l_result                 BOOLEAN;
  l_result_id              ZX_PROCESS_RESULTS.RESULT_ID%TYPE;
  l_valid                  BOOLEAN;

  --CR#4255160 - Added new variables to store the Geography context related information
  l_rule_det_factor_cq      ZX_RULES_B.DETERMINING_FACTOR_CQ_CODE%TYPE;
  l_rule_geography_type      ZX_RULES_B.GEOGRAPHY_TYPE%TYPE;
  l_rule_geography_id        ZX_RULES_B.GEOGRAPHY_ID%TYPE;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_det_factor_templ.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: proc_det_factor_templ(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;
  l_valid         := TRUE;

  l_count := p_det_factor_templ_cd_tbl.count;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_det_factor_templ',
                   'determining factor template count: ' || to_char(l_count));
  END IF;


  FOR i IN 1.. l_count LOOP

    l_valid := TRUE;

    --CR#4255160 - Process only those Rules which have been definied specifically for the Geography
    --on the Document or a Generic Rule, not defined specific to any Geography.
    l_rule_det_factor_cq  := p_rule_det_factor_cq_tbl(i);
    l_rule_geography_type := p_rule_geography_type_tbl(i);
    l_rule_geography_id   := p_rule_geography_id_tbl(i);

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
        'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_det_factor_templ',
        'l_rule_det_factor_cq: '||l_rule_det_factor_cq ||
        ', l_rule_geography_type: '||l_rule_geography_type ||
        ', l_rule_geography_id:'||l_rule_geography_id);
    END IF;

    IF (l_rule_det_factor_cq  IS NOT NULL AND
        l_rule_geography_type IS NOT NULL AND
        l_rule_geography_id   IS NOT NULL) THEN
      check_rule_geography(
        p_structure_name,
        p_structure_index,
        l_rule_det_factor_cq,
        l_rule_geography_type,
        l_rule_geography_id,
        p_event_class_rec,
        l_valid,
        p_return_status,
        p_error_buffer);
    END IF;

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF g_level_error >= g_current_runtime_level THEN
        FND_LOG.STRING(g_level_error,
        'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_det_factor_templ',
        ' check_rule_geography returned Error');
      END IF;
      RETURN;
    END IF;


    --Continue processing the Rule only if the Rule's geography
    --matched with the one cached in the gloabl location structure

    IF(l_valid AND p_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      --
      -- process 1 template at a time
      --

      l_det_factor_templ_code := p_det_factor_templ_cd_tbl(i);

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
        'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_det_factor_templ',
        'l_det_factor_templ_code: '||l_det_factor_templ_code);
      END IF;


      -- Bug 4166241 : for the template, check if the parameters associated with the determining factors
      -- are supported for the given Application

      check_templ_tax_parameter(
        l_det_factor_templ_code,
        p_event_class_rec,
        l_valid,
        p_return_status,
        p_error_buffer);

      -- process the template only if it is valid for the given application
      IF (l_valid AND p_return_status = FND_API.G_RET_STS_SUCCESS) THEN

        -- get all the condition groups and conditions
        proc_condition_group_per_templ(
          p_structure_name,
          p_structure_index,
          l_det_factor_templ_code,
          p_event_class_rec,
          p_tax_tbl(i),
          p_tax_regime_code_tbl(i),
          p_tax_determine_date,
          p_service_type_code,
          p_tax_rule_id_tbl(i),
          p_tax_status_code,
          l_result,
          l_result_id,
                                  p_found,
                                  p_zx_result_rec,
          p_return_status,
          p_error_buffer);

        -- if the whole condition is satisfied, put result to p_zx_result_rec
                               /* moved get_result call inside
 * proc_condition_group_per_templ
        IF (l_result) THEN
          get_result(
            l_result_id,
            p_structure_name,
            p_structure_index,
            p_tax_regime_code_tbl(i),
            p_tax_tbl(i),
            p_tax_determine_date,
            p_found,
            p_zx_result_rec,
            p_return_status,
            p_error_buffer);
        END IF; --l_result
                                */
        EXIT WHEN (p_found OR p_return_status <> FND_API.G_RET_STS_SUCCESS);
      END IF; --l_valid
    END IF; --l_valid for check_rule_geography
  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_det_factor_templ.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: proc_det_factor_templ(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_det_factor_templ',
                      p_error_buffer);
    END IF;

END proc_det_factor_templ;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  proc_condition_group_per_templ
--
--  DESCRIPTION
--    This procedure processes all condition groups of a template
--

PROCEDURE proc_condition_group_per_templ(
            p_structure_name      IN     VARCHAR2,
            p_structure_index     IN     BINARY_INTEGER,
            p_det_factor_templ_code       IN
                  ZX_DET_FACTOR_TEMPL_B.DET_FACTOR_TEMPL_CODE%TYPE,
            p_event_class_rec     IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax                 IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code     IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax_determine_date  IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_service_type_code   IN     ZX_RULES_B.SERVICE_TYPE_CODE%TYPE,
            p_tax_rule_id         IN     ZX_RULES_B.TAX_RULE_ID%TYPE,
            p_tax_status_code     IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_result              IN OUT NOCOPY BOOLEAN,
            p_result_id           IN OUT NOCOPY NUMBER,
            p_found              OUT NOCOPY BOOLEAN ,
            p_zx_result_rec          OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)

IS

  --bug#8551677
  --commenting the following local variables as they are no longer needed
  --
  --l_condition_group_code_tbl              condition_group_code_tbl;
  --l_condition_group_id_tbl                condition_group_id_tbl;
  --l_more_than10_tbl                       more_than10_tbl;
  --l_chart_of_accounts_id_tbl              chart_of_accounts_id_tbl;
  --l_sob_id_tbl                            ledger_id_tbl;
  --l_det_factor_class1_tbl                 determining_factor_class_tbl;
  --l_determining_factor_cq1_tbl            determining_factor_cq_tbl;
  --l_tax_parameter_code1_tbl               tax_parameter_code_tbl;
  --l_data_type1_tbl                        data_type_tbl;
  --l_det_factor_code1_tbl                  determining_factor_code_tbl;
  --l_operator1_tbl                         operator_tbl;
  --l_numeric_value1_tbl                    numeric_value_tbl;
  --l_date_value1_tbl                       date_value_tbl;
  --l_alphanum_value1_tbl                   alphanumeric_value_tbl;
  --l_value_low1_tbl                        value_low_tbl;
  --l_value_high1_tbl                       value_high_tbl;
  --l_det_factor_class2_tbl                 determining_factor_class_tbl;
  --l_determining_factor_cq2_tbl            determining_factor_cq_tbl;
  --l_tax_parameter_code2_tbl               tax_parameter_code_tbl;
  --l_data_type2_tbl                        data_type_tbl;
  --l_det_factor_code2_tbl                  determining_factor_code_tbl;
  --l_operator2_tbl                         operator_tbl;
  --l_numeric_value2_tbl                    numeric_value_tbl;
  --l_date_value2_tbl                       date_value_tbl;
  --l_alphanum_value2_tbl                   alphanumeric_value_tbl;
  --l_value_low2_tbl                        value_low_tbl;
  --l_value_high2_tbl                       value_high_tbl;
  --l_det_factor_class3_tbl                 determining_factor_class_tbl;
  --l_determining_factor_cq3_tbl            determining_factor_cq_tbl;
  --l_tax_parameter_code3_tbl               tax_parameter_code_tbl;
  --l_data_type3_tbl                        data_type_tbl;
  --l_det_factor_code3_tbl                  determining_factor_code_tbl;
  --l_operator3_tbl                         operator_tbl;
  --l_numeric_value3_tbl                    numeric_value_tbl;
  --l_date_value3_tbl                       date_value_tbl;
  --l_alphanum_value3_tbl                   alphanumeric_value_tbl;
  --l_value_low3_tbl                        value_low_tbl;
  --l_value_high3_tbl                       value_high_tbl;
  --l_det_factor_class4_tbl                 determining_factor_class_tbl;
  --l_determining_factor_cq4_tbl            determining_factor_cq_tbl;
  --l_tax_parameter_code4_tbl               tax_parameter_code_tbl;
  --l_data_type4_tbl                        data_type_tbl;
  --l_det_factor_code4_tbl                  determining_factor_code_tbl;
  --l_operator4_tbl                         operator_tbl;
  --l_numeric_value4_tbl                    numeric_value_tbl;
  --l_date_value4_tbl                       date_value_tbl;
  --l_alphanum_value4_tbl                   alphanumeric_value_tbl;
  --l_value_low4_tbl                        value_low_tbl;
  --l_value_high4_tbl                       value_high_tbl;
  --l_det_factor_class5_tbl                 determining_factor_class_tbl;
  --l_determining_factor_cq5_tbl            determining_factor_cq_tbl;
  --l_tax_parameter_code5_tbl               tax_parameter_code_tbl;
  --l_data_type5_tbl                        data_type_tbl;
  --l_det_factor_code5_tbl                  determining_factor_code_tbl;
  --l_operator5_tbl                         operator_tbl;
  --l_numeric_value5_tbl                    numeric_value_tbl;
  --l_date_value5_tbl                       date_value_tbl;
  --l_alphanum_value5_tbl                   alphanumeric_value_tbl;
  --l_value_low5_tbl                        value_low_tbl;
  --l_value_high5_tbl                       value_high_tbl;
  --l_det_factor_class6_tbl                 determining_factor_class_tbl;
  --l_determining_factor_cq6_tbl            determining_factor_cq_tbl;
  --l_tax_parameter_code6_tbl               tax_parameter_code_tbl;
  --l_data_type6_tbl                        data_type_tbl;
  --l_det_factor_code6_tbl                  determining_factor_code_tbl;
  --l_operator6_tbl                         operator_tbl;
  --l_numeric_value6_tbl                    numeric_value_tbl;
  --l_date_value6_tbl                       date_value_tbl;
  --l_alphanum_value6_tbl                   alphanumeric_value_tbl;
  --l_value_low6_tbl                        value_low_tbl;
  --l_value_high6_tbl                       value_high_tbl;
  --l_det_factor_class7_tbl                 determining_factor_class_tbl;
  --l_determining_factor_cq7_tbl            determining_factor_cq_tbl;
  --l_tax_parameter_code7_tbl               tax_parameter_code_tbl;
  --l_data_type7_tbl                        data_type_tbl;
  --l_det_factor_code7_tbl                  determining_factor_code_tbl;
  --l_operator7_tbl                         operator_tbl;
  --l_numeric_value7_tbl                    numeric_value_tbl;
  --l_date_value7_tbl                       date_value_tbl;
  --l_alphanum_value7_tbl                   alphanumeric_value_tbl;
  --l_value_low7_tbl                        value_low_tbl;
  --l_value_high7_tbl                       value_high_tbl;
  --l_det_factor_class8_tbl                 determining_factor_class_tbl;
  --l_determining_factor_cq8_tbl            determining_factor_cq_tbl;
  --l_tax_parameter_code8_tbl               tax_parameter_code_tbl;
  --l_data_type8_tbl                        data_type_tbl;
  --l_det_factor_code8_tbl                  determining_factor_code_tbl;
  --l_operator8_tbl                         operator_tbl;
  --l_numeric_value8_tbl                    numeric_value_tbl;
  --l_date_value8_tbl                       date_value_tbl;
  --l_alphanum_value8_tbl                   alphanumeric_value_tbl;
  --l_value_low8_tbl                        value_low_tbl;
  --l_value_high8_tbl                       value_high_tbl;
  --l_det_factor_class9_tbl                 determining_factor_class_tbl;
  --l_determining_factor_cq9_tbl            determining_factor_cq_tbl;
  --l_tax_parameter_code9_tbl               tax_parameter_code_tbl;
  --l_data_type9_tbl                        data_type_tbl;
  --l_det_factor_code9_tbl                  determining_factor_code_tbl;
  --l_operator9_tbl                         operator_tbl;
  --l_numeric_value9_tbl                    numeric_value_tbl;
  --l_date_value9_tbl                       date_value_tbl;
  --l_alphanum_value9_tbl                   alphanumeric_value_tbl;
  --l_value_low9_tbl                        value_low_tbl;
  --l_value_high9_tbl                       value_high_tbl;
  --l_det_factor_class10_tbl                determining_factor_class_tbl;
  --l_determining_factor_cq10_tbl           determining_factor_cq_tbl;
  --l_tax_parameter_code10_tbl              tax_parameter_code_tbl;
  --l_data_type10_tbl                       data_type_tbl;
  --l_det_factor_code10_tbl                 determining_factor_code_tbl;
  --l_operator10_tbl                        operator_tbl;
  --l_numeric_value10_tbl                   numeric_value_tbl;
  --l_date_value10_tbl                      date_value_tbl;
  --l_alphanum_value10_tbl                  alphanumeric_value_tbl;
  --l_value_low10_tbl                       value_low_tbl;
  --l_value_high10_tbl                      value_high_tbl;
  --l_result_id_tbl                         result_id_tbl;
  --l_constraint_id_tbl                     constraint_id_tbl;

  l_constraint_result                     BOOLEAN;
  l_condition_group_evaluated             BOOLEAN;

  l_counter                               NUMBER;
  i                                       NUMBER;
  --
  -- cursor for condition groups
  --

  CURSOR  get_condition_group_codes_csr
    (c_det_factor_templ_code  ZX_DET_FACTOR_TEMPL_B.det_factor_templ_code%TYPE,
     c_tax_rule_id            ZX_RULES_B.TAX_RULE_ID%TYPE,
     c_tax_status_code        ZX_STATUS_B.TAX_STATUS_CODE%TYPE)
  IS
    SELECT  /*+ leading(P) use_nl_with_index(s ZX_CONDITION_GROUPS_B_U1) */
            s.CONDITION_GROUP_ID, s.CONDITION_GROUP_CODE, More_Than_Max_Cond_Flag,
            Determining_Factor_Class1_Code, Determining_Factor_Cq1_Code,
            Data_Type1_Code, DETERMINING_FACTOR_CODE1,
            Operator1_Code, NUMERIC_VALUE1, DATE_VALUE1, ALPHANUMERIC_VALUE1,
            VALUE_LOW1, VALUE_HIGH1, TAX_PARAMETER_CODE1,
            Determining_Factor_Class2_Code, Determining_Factor_Cq2_Code,
            Data_Type2_Code, DETERMINING_FACTOR_CODE2,
            Operator2_Code, NUMERIC_VALUE2, DATE_VALUE2, ALPHANUMERIC_VALUE2,
            VALUE_LOW2, VALUE_HIGH2, TAX_PARAMETER_CODE2,
            Determining_Factor_Class3_Code, Determining_Factor_Cq3_Code,
            Data_Type3_Code, DETERMINING_FACTOR_CODE3,
            Operator3_Code, NUMERIC_VALUE3, DATE_VALUE3, ALPHANUMERIC_VALUE3,
            VALUE_LOW3, VALUE_HIGH3, TAX_PARAMETER_CODE3,
            Determining_Factor_Class4_Code, Determining_Factor_Cq4_Code,
            Data_Type4_Code, DETERMINING_FACTOR_CODE4,
            Operator4_Code, NUMERIC_VALUE4, DATE_VALUE4, ALPHANUMERIC_VALUE4,
            VALUE_LOW4, VALUE_HIGH4, TAX_PARAMETER_CODE4,
            Determining_Factor_Class5_Code, Determining_Factor_Cq5_Code,
            Data_Type5_Code, DETERMINING_FACTOR_CODE5,
            Operator5_Code, NUMERIC_VALUE5, DATE_VALUE5, ALPHANUMERIC_VALUE5,
            VALUE_LOW5, VALUE_HIGH5, TAX_PARAMETER_CODE5,
            Determining_Factor_Class6_Code, Determining_Factor_Cq6_Code,
            Data_Type6_Code, DETERMINING_FACTOR_CODE6,
            Operator6_Code, NUMERIC_VALUE6, DATE_VALUE6, ALPHANUMERIC_VALUE6,
            VALUE_LOW6, VALUE_HIGH6, TAX_PARAMETER_CODE6,
            Determining_Factor_Class7_Code, Determining_Factor_Cq7_Code,
            Data_Type7_Code, DETERMINING_FACTOR_CODE7,
            Operator7_Code, NUMERIC_VALUE7, DATE_VALUE7, ALPHANUMERIC_VALUE7,
            VALUE_LOW7, VALUE_HIGH7, TAX_PARAMETER_CODE7,
            Determining_Factor_Class8_Code, Determining_Factor_Cq8_Code,
            Data_Type8_Code, DETERMINING_FACTOR_CODE8,
            Operator8_Code, NUMERIC_VALUE8, DATE_VALUE8, ALPHANUMERIC_VALUE8,
            VALUE_LOW8, VALUE_HIGH8, TAX_PARAMETER_CODE8,
            Determining_Factor_Class9_Code, Determining_Factor_Cq9_Code,
            Data_Type9_Code, DETERMINING_FACTOR_CODE9,
            Operator9_Code, NUMERIC_VALUE9, DATE_VALUE9, ALPHANUMERIC_VALUE9,
            VALUE_LOW9, VALUE_HIGH9, TAX_PARAMETER_CODE9,
            Determining_Factor_Clas10_Code, Determining_Factor_Cq10_Code, Data_Type10_Code,
            DETERMINING_FACTOR_CODE10, Operator10_Code, NUMERIC_VALUE10, DATE_VALUE10,
            ALPHANUMERIC_VALUE10, VALUE_LOW10, VALUE_HIGH10,
            TAX_PARAMETER_CODE10, CHART_OF_ACCOUNTS_ID, LEDGER_ID,
            p.RESULT_ID,
            s.constraint_id
        FROM    ZX_CONDITION_GROUPS_B s,
                ZX_PROCESS_RESULTS p
        WHERE   --s.det_factor_templ_code = c_det_factor_templ_code        AND
                s.enabled_flag          = 'Y'                    AND
                --s.condition_group_code = p.condition_group_code      AND
                s.condition_group_id = p.condition_group_id     AND
                p.tax_rule_id          = c_tax_rule_id          AND
                p.enabled_flag         = 'Y'                    AND
                (p.tax_status_code     = c_tax_status_code OR
                 p.tax_status_code IS NULL )
        ORDER BY p.priority;

       l_action_rec_tbl     ZX_TDS_PROCESS_CEC_PVT.action_rec_tbl_type;
       hash_val             VARCHAR2(100);

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_condition_group_per_templ.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: proc_condition_group_per_templ(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;
  l_constraint_result             := FALSE;
  l_condition_group_evaluated     := FALSE;

   -- reset the left hand side trx value for a new unevaluated template.
   --   g_trx_numeric_value_tbl.delete;
   --  g_trx_date_value_tbl.delete;
   -- g_trx_alphanumeric_value_tbl.delete;

   --
   -- init get transaction values flag, need to get transaction
   -- values only once
   --

   -- caching fix done for bug#8551677
   hash_val := to_char(p_tax_rule_id) || '|' || NVL(p_det_factor_templ_code, FND_API.G_MISS_CHAR) || '|' || NVL(p_tax_status_code, FND_API.G_MISS_CHAR);

   IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl.EXISTS(hash_val) AND
      ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).tax_rule_id = p_tax_rule_id AND
      NVL(ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).det_factor_templ_code, FND_API.G_MISS_CHAR) = NVL(p_det_factor_templ_code, FND_API.G_MISS_CHAR) AND
      NVL(ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).tax_status_code, FND_API.G_MISS_CHAR) = NVL(p_tax_status_code, FND_API.G_MISS_CHAR) THEN
     IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_condition_group_per_templ',
                   'Condition Information found in cache...' || hash_val);
     END IF;
     l_counter := ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl.count;
   ELSE
     IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_condition_group_per_templ',
                   'Condition Information not found in cache...' || hash_val);
     END IF;
     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).tax_rule_id := p_tax_rule_id;
     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).det_factor_templ_code := NVL(p_det_factor_templ_code, FND_API.G_MISS_CHAR);
     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).tax_status_code := NVL(p_tax_status_code, FND_API.G_MISS_CHAR);
       OPEN get_condition_group_codes_csr(p_det_factor_templ_code,
                                          p_tax_rule_id,
                                          p_tax_status_code);
       --LOOP
       FETCH get_condition_group_codes_csr bulk collect into
           ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl;
       --bug#8551677
       --FETCH get_condition_group_codes_csr bulk collect into
           --               l_condition_group_id_tbl,
           --               l_condition_group_code_tbl,
           --               l_more_than10_tbl,
           --               l_det_factor_class1_tbl,
           --               l_determining_factor_cq1_tbl,
           --               l_data_type1_tbl,
           --               l_det_factor_code1_tbl,
           --               l_operator1_tbl,
           --               l_numeric_value1_tbl,
           --               l_date_value1_tbl,
           --               l_alphanum_value1_tbl,
           --               l_value_low1_tbl,
           --               l_value_high1_tbl,
           --               l_tax_parameter_code1_tbl,
           --               l_det_factor_class2_tbl,
           --               l_determining_factor_cq2_tbl,
           --               l_data_type2_tbl,
           --               l_det_factor_code2_tbl,
           --               l_operator2_tbl,
           --               l_numeric_value2_tbl,
           --               l_date_value2_tbl,
           --               l_alphanum_value2_tbl,
           --               l_value_low2_tbl,
           --               l_value_high2_tbl,
           --               l_tax_parameter_code2_tbl,
           --               l_det_factor_class3_tbl,
           --               l_determining_factor_cq3_tbl,
           --               l_data_type3_tbl,
           --               l_det_factor_code3_tbl,
           --               l_operator3_tbl,
           --               l_numeric_value3_tbl,
           --               l_date_value3_tbl,
           --               l_alphanum_value3_tbl,
           --               l_value_low3_tbl,
           --               l_value_high3_tbl,
           --               l_tax_parameter_code3_tbl,
           --               l_det_factor_class4_tbl,
           --               l_determining_factor_cq4_tbl,
           --               l_data_type4_tbl,
           --               l_det_factor_code4_tbl,
           --               l_operator4_tbl,
           --               l_numeric_value4_tbl,
           --               l_date_value4_tbl,
           --               l_alphanum_value4_tbl,
           --               l_value_low4_tbl,
           --               l_value_high4_tbl,
           --               l_tax_parameter_code4_tbl,
           --               l_det_factor_class5_tbl,
           --               l_determining_factor_cq5_tbl,
           --               l_data_type5_tbl,
           --               l_det_factor_code5_tbl,
           --               l_operator5_tbl,
           --               l_numeric_value5_tbl,
           --               l_date_value5_tbl,
           --               l_alphanum_value5_tbl,
           --               l_value_low5_tbl,
           --               l_value_high5_tbl,
           --               l_tax_parameter_code5_tbl,
           --               l_det_factor_class6_tbl,
           --               l_determining_factor_cq6_tbl,
           --               l_data_type6_tbl,
           --               l_det_factor_code6_tbl,
           --               l_operator6_tbl,
           --               l_numeric_value6_tbl,
           --               l_date_value6_tbl,
           --               l_alphanum_value6_tbl,
           --               l_value_low6_tbl,
           --               l_value_high6_tbl,
           --               l_tax_parameter_code6_tbl,
           --               l_det_factor_class7_tbl,
           --               l_determining_factor_cq7_tbl,
           --               l_data_type7_tbl,
           --               l_det_factor_code7_tbl,
           --               l_operator7_tbl,
           --               l_numeric_value7_tbl,
           --               l_date_value7_tbl,
           --               l_alphanum_value7_tbl,
           --               l_value_low7_tbl,
           --               l_value_high7_tbl,
           --               l_tax_parameter_code7_tbl,
           --               l_det_factor_class8_tbl,
           --               l_determining_factor_cq8_tbl,
           --               l_data_type8_tbl,
           --               l_det_factor_code8_tbl,
           --               l_operator8_tbl,
           --               l_numeric_value8_tbl,
           --               l_date_value8_tbl,
           --               l_alphanum_value8_tbl,
           --               l_value_low8_tbl,
           --               l_value_high8_tbl,
           --               l_tax_parameter_code8_tbl,
           --               l_det_factor_class9_tbl,
           --               l_determining_factor_cq9_tbl,
           --               l_data_type9_tbl,
           --               l_det_factor_code9_tbl,
           --               l_operator9_tbl,
           --               l_numeric_value9_tbl,
           --               l_date_value9_tbl,
           --               l_alphanum_value9_tbl,
           --               l_value_low9_tbl,
           --               l_value_high9_tbl,
           --               l_tax_parameter_code9_tbl,
           --               l_det_factor_class10_tbl,
           --               l_determining_factor_cq10_tbl,
           --               l_data_type10_tbl,
           --               l_det_factor_code10_tbl,
           --               l_operator10_tbl,
           --               l_numeric_value10_tbl,
           --               l_date_value10_tbl,
           --               l_alphanum_value10_tbl,
           --               l_value_low10_tbl,
           --               l_value_high10_tbl,
           --               l_tax_parameter_code10_tbl,
           --               l_chart_of_accounts_id_tbl,
           --               l_sob_id_tbl,
           --               l_result_id_tbl,
           --               l_constraint_id_tbl
           --           limit C_LINES_PER_COMMIT;

     --l_counter := l_condition_group_code_tbl.count;
     l_counter := ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl.count;

     IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_condition_group_per_templ',
                      'condition group count: ' || to_char(l_counter));
     END IF;
   END IF; --bug#8551677 cache check

   FOR j IN 1..l_counter LOOP

     /* -- comment out for bug 5211699, Nilesh will check the cache issue
        -- together with performance fix.
     -- check if the template has been evaluated.
     check_condition_group_result(
                             p_det_factor_templ_code,
                             l_condition_group_code_tbl(j),
                             p_structure_index,
                             p_event_class_rec,
                             l_condition_group_evaluated,
                             p_result);
     */

     IF (NOT l_condition_group_evaluated) THEN
      -- Initialize l_constraint_result to TRUE so that the evaluation of Condition Group
      -- is processed irrespective of Constraint association with Condition Group.
      l_constraint_result := TRUE;

      -- Check if the Condition Group has associated Constraint which would
      -- exist for Migrated Records only.
      --  If constraint exists and the action for the condition group evaluates
      --     to use it, only then evaluate conditions of the Condition Group.
      --     Otherwise, store FALSE as result outcome for the Condition Group.
      IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).constraint_id IS NOT NULL THEN
         init_cec_params (p_structure_name  => p_structure_name,
                          p_structure_index => p_structure_index,
                          p_return_status   => p_return_status,
                          p_error_buffer    => p_error_buffer);

         ZX_TDS_PROCESS_CEC_PVT.evaluate_cec(
                          p_constraint_id                => ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).constraint_id,
                          p_cec_ship_to_party_site_id    => g_cec_ship_to_party_site_id,
                          p_cec_bill_to_party_site_id    => g_cec_bill_to_party_site_id,
                          p_cec_ship_to_party_id         => g_cec_ship_to_party_id,
                          p_cec_bill_to_party_id         => g_cec_bill_to_party_id,
                          p_cec_poo_location_id          => g_cec_poo_location_id,
                          p_cec_poa_location_id          => g_cec_poa_location_id,
                          p_cec_trx_id                   => g_cec_trx_id,
                          p_cec_trx_line_id              => g_cec_trx_line_id,
                          p_cec_ledger_id                => g_cec_ledger_id,
                          p_cec_internal_organization_id => g_cec_internal_organization_id,
                          p_cec_so_organization_id       => g_cec_so_organization_id,
                          p_cec_product_org_id           => g_cec_product_org_id,
                          p_cec_product_id               => g_cec_product_id,
                          p_cec_trx_line_date            => g_cec_trx_line_date,
                          p_cec_trx_type_id              => g_cec_trx_type_id,
                          p_cec_fob_point                => g_cec_fob_point,
                          p_cec_ship_to_site_use_id      => g_cec_ship_to_site_use_id,
                          p_cec_bill_to_site_use_id      => g_cec_bill_to_site_use_id,
                          p_cec_result                   => l_constraint_result,
                          p_action_rec_tbl               => l_action_rec_tbl,
                          p_return_status                => p_return_status,
                          p_error_buffer                 => p_error_buffer);
         p_result := l_constraint_result;
      END IF;

      -- bug 3976490
      IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).constraint_id is not NULL then

         -- every constraint must evaluate to either TRUE or FALSE. Based on this, the
         -- values in the p_action_rec_tbl will be action for True condition or Falese condition.

         for i in 1.. nvl(l_action_rec_tbl.last,0) loop

           if upper(l_action_rec_tbl(i).action_code) in ('ERROR_MESSAGE','SYSTEM_ERROR') then
              p_return_status := FND_API.G_RET_STS_ERROR;

              -- Bug 8568734
              FND_MESSAGE.SET_NAME('ZX','ZX_CONSTRAINT_EVALUATION_ERROR');
              FND_MESSAGE.SET_TOKEN('CONDITION_GROUP',ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).condition_group_code);
              FND_MESSAGE.SET_TOKEN('ACTION_CODE', l_action_rec_tbl(i).action_code );
              ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

              IF (g_level_error >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_error,
                               'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_condition_group_per_templ',
                               'Action_code is ERROR_MESSAGE or SYSTEM_ERROR');
              END IF;
              app_exception.raise_exception;
           elsif upper(l_action_rec_tbl(i).action_code) = 'DO_NOT_USE_THIS_TAX_GROUP' then
              l_constraint_result := FALSE;
           elsif  upper(l_action_rec_tbl(i).action_code) = 'USE_THIS_TAX_GROUP' then
               l_constraint_result := TRUE;
           elsif upper(l_action_rec_tbl(i).action_code) = 'DEFAULT_TAX_CODE' then
               NULL;
               --++ How do we default a Tax Code at Tax Group level if there are
               --   multiple tax codes associated with that tax group? Even if we default,
               --   should we evaluate the conditions and exceptions and if there is an action
               --   DEFAULT_TAX_CODE should we honour that one ? Revisit later
           end if;
        end loop;
      END IF;

      IF l_constraint_result THEN
       --
       -- process 1 condition group at a time
       -- if this condition group evaluates to true,
       -- exit all loops and no need to search any more
       --

       -- init  conditions for this condition group
       init_set_condition;

       -- check if there are too many conditions.
       IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_condition_group_per_templ',
                        'more_than10 ? ' ||ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).more_than10);
       END IF;

       IF (ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).more_than10 = 'Y') THEN
         --
         -- if the condition group has more than 10 conditions
         -- get all  conditions from zx_condtions
         --

         get_and_process_condition(
                           p_structure_name,
                           p_structure_index,
                           ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).condition_group_code,
                           p_event_class_rec,
                           p_tax,
                           p_tax_regime_code,
                           p_tax_determine_date,
                           p_result,
                           ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).chart_of_accounts_id,
                           ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).sob_id,
                           p_return_status,
                           p_error_buffer);

       ELSE
         IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class1 IS NOT NULL THEN
           get_set_info(1,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class1,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).determining_factor_cq1,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).tax_parameter_code1,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).data_type1,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_code1,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).operator1,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).numeric_value1,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).date_value1,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).alphanum_value1,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_low1,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_high1 );
           IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class2 IS NOT NULL THEN
             get_set_info(2,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class2,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).determining_factor_cq2,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).tax_parameter_code2,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).data_type2,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_code2,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).operator2,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).numeric_value2,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).date_value2,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).alphanum_value2,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_low2,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_high2 );

             IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class3 IS NOT NULL THEN
               get_set_info(3,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class3,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).determining_factor_cq3,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).tax_parameter_code3,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).data_type3,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_code3,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).operator3,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).numeric_value3,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).date_value3,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).alphanum_value3,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_low3,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_high3 );

               IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class4 IS NOT NULL THEN
                 get_set_info(4,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class4,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).determining_factor_cq4,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).tax_parameter_code4,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).data_type4,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_code4,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).operator4,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).numeric_value4,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).date_value4,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).alphanum_value4,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_low4,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_high4 );
                 IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class5 IS NOT NULL THEN
                   get_set_info(5,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class5,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).determining_factor_cq5,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).tax_parameter_code5,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).data_type5,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_code5,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).operator5,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).numeric_value5,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).date_value5,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).alphanum_value5,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_low5,
                     ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_high5 );
                   IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class6 IS NOT NULL THEN
                     get_set_info(6,
                       ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class6,
                       ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).determining_factor_cq6,
                       ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).tax_parameter_code6,
                       ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).data_type6,
                       ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_code6,
                       ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).operator6,
                       ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).numeric_value6,
                       ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).date_value6,
                       ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).alphanum_value6,
                       ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_low6,
                       ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_high6 );
                     IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class7 IS NOT NULL THEN
                       get_set_info(7,
                          ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class7,
                          ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).determining_factor_cq7,
                          ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).tax_parameter_code7,
                          ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).data_type7,
                          ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_code7,
                          ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).operator7,
                          ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).numeric_value7,
                          ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).date_value7,
                          ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).alphanum_value7,
                          ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_low7,
                          ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_high7 );
                       IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class8 IS NOT NULL THEN
                         get_set_info(8,
                            ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class8,
                            ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).determining_factor_cq8,
                            ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).tax_parameter_code8,
                            ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).data_type8,
                            ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_code8,
                            ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).operator8,
                            ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).numeric_value8,
                            ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).date_value8,
                            ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).alphanum_value8,
                            ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_low8,
                            ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_high8 );
                         IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class9 IS NOT NULL THEN
                           get_set_info(9,
                              ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class9,
                              ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).determining_factor_cq9,
                              ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).tax_parameter_code9,
                              ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).data_type9,
                              ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_code9,
                              ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).operator9,
                              ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).numeric_value9,
                              ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).date_value9,
                              ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).alphanum_value9,
                              ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_low9,
                              ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_high9 );
                           IF ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class10 IS NOT NULL THEN
                             get_set_info(10,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_class10,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).determining_factor_cq10,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).tax_parameter_code10,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).data_type10,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).det_factor_code10,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).operator10,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).numeric_value10,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).date_value10,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).alphanum_value10,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_low10,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).value_high10 );
                           END IF;
                         END IF;
                       END IF;
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;
          END IF;

          --
          -- process the  conditions for this condition group
          --
          process_set_condition(
                                p_structure_name,
                                p_structure_index,
                                p_event_class_rec,
                                p_tax_determine_date,
                                p_tax,
                                p_tax_regime_code,
                                p_result,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).chart_of_accounts_id,
                                ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).sob_id,
                                p_return_status,
                                p_error_buffer);

       END IF;
      END IF;     /* of l_constraint_result */
      --
      -- if p_return_status = ERROR from process_set_condition
      -- that means get_trx_value results in error while trying to get
      -- transaction values, return to calling process immediately
      --
      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        CLOSE get_condition_group_codes_csr;
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_condition_group_per_templ',
                         'Incorrect return_status after calling process_set_condition() ' ||
                         ', p_return_status = ' || p_return_status);
        END IF;

        RETURN;
      END IF;
      --
      -- update  condition group result table with the result of
      -- of the condition group just evaluated
      --
      insert_condition_group_result(p_det_factor_templ_code,
                               ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).condition_group_code,
                               p_result,
                               p_structure_index,
                               p_event_class_rec );

     END IF;    /* of NOT l_condition_group_evaluated */
     IF p_result THEN
        --
        -- 1 of the condition groups evaluates to TRUE for this template,
        -- no need to evaluate the rest of the condition groups
        --

        -- Assign the Result Id for the evaluated condition group.
        --p_result_id := l_result_id_tbl(j);
        p_result_id := ZX_GLOBAL_STRUCTURES_PKG.g_rule_info_tbl(hash_val).condition_info_rec_tbl(j).result_id;

         get_result(
                    p_result_id,
                    p_structure_name,
                    p_structure_index,
                    p_tax_regime_code,
                    p_tax,
                    p_tax_determine_date,
                    p_found,
                    p_zx_result_rec,
                    p_return_status,
                    p_error_buffer);
  EXIT WHEN (p_found OR p_return_status <> FND_API.G_RET_STS_SUCCESS);
     END IF;
    END LOOP;

   IF (l_counter = 0 OR p_result) THEN
      --CLOSE get_condition_group_codes_csr;
      IF get_condition_group_codes_csr%ISOPEN THEN
        CLOSE get_condition_group_codes_csr;
      END IF;
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_condition_group_per_templ',
                       'No condition group found for the determing factor template: ' ||
                       p_det_factor_templ_code ||
                       ', or condition group evaluated to be true.');
      END IF;
      --bug#8551677
      --EXIT;
    END IF;


  --bug#8551677
  --END LOOP;

  IF get_condition_group_codes_csr%ISOPEN THEN
    CLOSE get_condition_group_codes_csr;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_condition_group_per_templ.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: proc_condition_group_per_templ(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF get_condition_group_codes_csr%ISOPEN THEN
      CLOSE get_condition_group_codes_csr;
    END IF;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.proc_condition_group_per_templ',
                      p_error_buffer);
    END IF;

END proc_condition_group_per_templ;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_and_process_condition
--
--  DESCRIPTION
--    This procedure processes all conditions defined for a condition group
--    when the conditions for this condition group is more than 10
--

PROCEDURE get_and_process_condition(
            p_structure_name              IN  VARCHAR2,
            p_structure_index             IN  BINARY_INTEGER,
            p_condition_group_code        IN
                ZX_CONDITION_GROUPS_B.condition_group_CODE%TYPE,
             p_event_class_rec            IN
                 ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax                         IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code             IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax_determine_date          IN
                 ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_result                      IN OUT NOCOPY BOOLEAN,
            p_chart_of_accounts_id        IN
                ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
            p_sob_id                      IN
                ZX_CONDITION_GROUPS_B.LEDGER_ID%TYPE,
            p_return_status                  OUT NOCOPY VARCHAR2,
            p_error_buffer                   OUT NOCOPY VARCHAR2)
IS
  l_condition_result           BOOLEAN;

  CURSOR  get_condition_csr
    (c_condition_group_code  ZX_CONDITION_GROUPS_B.condition_group_CODE%TYPE)
IS

        SELECT  Determining_Factor_Class_Code,
                Determining_Factor_Cq_Code,
                Data_Type_Code,
                determining_factor_code,
                TAX_PARAMETER_CODE,
                Operator_Code,
               NUMERIC_VALUE,
                DATE_VALUE,
                ALPHANUMERIC_VALUE,
                VALUE_LOW,
                VALUE_HIGH
        FROM    ZX_CONDITIONS
        WHERE   CONDITION_GROUP_CODE = c_condition_group_code
         AND (Ignore_Flag <> 'Y' OR IGNORE_FLAG IS NULL);


BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_and_process_condition.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_and_process_condition(+)');

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_and_process_condition',
                   'p_condition_group_code: ' || p_condition_group_code);

  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  l_condition_result := TRUE;

  --
  -- process all conditions for this condition group
  --
  OPEN get_condition_csr(p_condition_group_code);
  LOOP
    FETCH get_condition_csr bulk collect into
            g_determining_factor_class_tbl,
            g_determining_factor_cq_tbl,
            g_data_type_tbl,
            g_determining_factor_code_tbl,
            g_tax_parameter_code_tbl,
            g_operator_tbl,
            g_numeric_value_tbl,
            g_date_value_tbl,
            g_alphanum_value_tbl,
            g_value_low_tbl,
            g_value_high_tbl
     LIMIT C_LINES_PER_COMMIT;

      process_set_condition(
                            p_structure_name,
                            p_structure_index,
                            p_event_class_rec,
                            p_tax_determine_date,
                            p_tax,
                            p_tax_regime_code,
                            p_result,
                            p_chart_of_accounts_id,
                            p_sob_id,
                            p_return_status,
                            p_error_buffer);


     IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       CLOSE get_condition_csr;
       IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
              'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_and_process_condition',
              'conditions count: ' ||
               to_char(get_condition_csr%ROWCOUNT));
       END IF;
       RETURN;
     END IF;
       --
       -- continue to evaluate the rest of the conditions for this
       -- condition group  only if previous conditions evaluate to true
       -- and there are more conditions to process
       --
       IF  (get_condition_csr%notfound OR NOT p_result)   THEN
         IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_and_process_condition',
                           'conditions count:' ||
                            to_char(get_condition_csr%ROWCOUNT));
         END IF;
         CLOSE get_condition_csr;
         EXIT;
       END IF;
  END LOOP;

  IF get_condition_csr%ISOPEN THEN
    CLOSE get_condition_csr;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_and_process_condition.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_and_process_condition(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF get_condition_csr%ISOPEN THEN
      CLOSE get_condition_csr;
    END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_and_process_condition',
                      p_error_buffer);
    END IF;

END get_and_process_condition;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_set_info
--
--  DESCRIPTION
--
--  This procedure gets all information of a condition defined
--  within a  condition group
--


PROCEDURE get_set_info (
      p_index                       IN BINARY_INTEGER,
      p_Det_Factor_Class_Code       IN ZX_CONDITIONS.Determining_Factor_Class_Code%TYPE,
      p_Determining_Factor_Cq_Code  IN ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
      p_tax_parameter_code          IN ZX_CONDITIONS.TAX_PARAMETER_CODE%TYPE,
      p_Data_Type_Code              IN ZX_CONDITIONS.Data_Type_Code%TYPE,
      p_determining_factor_code     IN ZX_CONDITIONS.determining_factor_code%TYPE,
      p_Operator_Code      IN ZX_CONDITIONS.Operator_Code%TYPE,
      p_numeric_value      IN ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
      p_date_value         IN ZX_CONDITIONS.DATE_VALUE%TYPE,
      p_alphanum_value     IN ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
      p_value_low          IN ZX_CONDITIONS.VALUE_LOW%TYPE,
      p_value_high         IN ZX_CONDITIONS.VALUE_HIGH%TYPE)
IS
  i             BINARY_INTEGER;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_set_info.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_set_info(+)');
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_set_info',
                   'p_index: ' || to_char(p_index) ||
                   ', p_Det_Factor_Class_Code: ' || p_Det_Factor_Class_Code ||
                   ', p_Determining_Factor_Cq_Code: ' || p_determining_factor_cq_code ||
                   ', p_tax_parameter_code: ' || p_tax_parameter_code ||
                   ', p_Data_Type_Code: ' || p_data_type_code ||
                   ', p_determining_factor_code: ' || p_determining_factor_code ||
                   ', p_Operator_Code: ' || p_operator_code ||
                   ', p_numeric_value: ' ||to_char(p_numeric_value) ||
                   ', p_date_value: ' || to_char(p_date_value,'DD-MON-YY') );
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_set_info',
                   'p_alphanum_value: ' || p_alphanum_value ||
                   ', p_value_low:' || to_char(p_value_low) ||
                   ', p_value_high:' || to_char(p_value_high));
  END IF;

  i := p_index;
  g_determining_factor_class_tbl(i) := p_Det_Factor_Class_Code;
  g_determining_factor_cq_tbl(i)    := p_Determining_Factor_Cq_Code;
  g_tax_parameter_code_tbl(i)       := p_tax_parameter_code;
  g_data_type_tbl(i)                := p_Data_Type_Code;
  g_determining_factor_code_tbl(i)  := p_determining_factor_code;
  g_operator_tbl(i)                 := p_Operator_Code;
  g_numeric_value_tbl(i)            := p_numeric_value;
  g_date_value_tbl(i)         := p_date_value;
  g_alphanum_value_tbl(i)     := p_alphanum_value;
  g_value_low_tbl(i)          := p_value_low;
  g_value_high_tbl(i)         := p_value_high;


  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_set_info.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_set_info(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_set_info',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END get_set_info;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  init_set_condition
--
--  DESCRIPTION
--    This procedure resets all tables containing condition info
--    of a  condition group
--  History
--
--    Phong La                    03-JUN-02  Created
--
PROCEDURE init_set_condition
IS
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.init_set_condition.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: init_set_condition(+)');
  END IF;

  g_determining_factor_class_tbl.DELETE;
  g_determining_factor_cq_tbl.DELETE;
  g_tax_parameter_code_tbl.DELETE;
  g_data_type_tbl.DELETE;
  g_determining_factor_code_tbl.DELETE;
  g_operator_tbl.DELETE;
  g_numeric_value_tbl.DELETE;
  g_date_value_tbl.DELETE;
  g_alphanum_value_tbl.DELETE;
  g_value_low_tbl.DELETE;
  g_value_high_tbl.DELETE;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.init_set_condition.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: init_set_condition(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.init_set_condition',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END init_set_condition;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  process_set_condition
--
--  DESCRIPTION
--
--  This procedure processes a condition which is part of a
--  of  a condition group
--

PROCEDURE process_set_condition (
            p_structure_name              IN     VARCHAR2,
            p_structure_index             IN     BINARY_INTEGER,
            p_event_class_rec             IN
                  ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_determine_date          IN
                  ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_tax                         IN    ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code             IN    ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_result                      IN OUT NOCOPY BOOLEAN,
            p_chart_of_accounts_id        IN
                ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
            p_sob_id                      IN
                ZX_CONDITION_GROUPS_B.LEDGER_ID%TYPE,
            p_return_status                  OUT NOCOPY VARCHAR2,
            p_error_buffer                   OUT NOCOPY VARCHAR2)

IS

--
-- This procedure processes 1 condition record
--
  l_count                  NUMBER;
  n                        BINARY_INTEGER;
  l_Determining_Factor_Cq_Code  ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE;
  l_trx_numeric_value      ZX_CONDITIONS.NUMERIC_VALUE%TYPE;
  l_trx_alphanum_value     ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE;
  l_trx_date_value         ZX_CONDITIONS.DATE_VALUE%TYPE;

  cursor get_acct_segment_num( n number) is
  select segment_num
  from fnd_id_flex_segments
  where application_id = 101
  and id_flex_code = 'GL#'
  and enabled_flag = 'Y'
  and id_flex_num = p_chart_of_accounts_id
  and application_column_name = 'SEGMENT' || n;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_set_condition.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: process_set_condition(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  l_count := g_determining_factor_code_tbl.count;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_set_condition',
                   'There are '||to_char(l_count)||' conditions');
  END IF;

  -- get the transaction value.

  FOR k IN 1..l_count LOOP

    l_Determining_Factor_Cq_Code := g_determining_factor_cq_tbl(k);

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_set_condition',
                     'Determining_Factor_Cq_Code: ' || l_Determining_Factor_Cq_Code);
    END IF;

    IF g_determining_factor_class_tbl(k) = 'USER_DEFINED_GEOGRAPHY' THEN
      --
      -- bug#4673686- handle a table of trx values
      --
      evaluate_trx_value_tbl(
         p_structure_name,
         p_structure_index,
         k,
         p_tax_determine_date,
         l_Determining_Factor_Cq_Code,
         p_chart_of_accounts_id,
         p_result,
         p_return_status,
         p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_set_condition',
                         'Incorrect return_status after calling evaluate_trx_value_tbl(),'||
                         ' did not get trx value');
        END IF;

        p_result        := FALSE;
        --
        -- this is a serious error, return to the calling
        -- process immediately
        --
        RETURN;
      END IF;
    ELSE
      --
      -- single trx value
      --
      get_trx_value(
         p_structure_name,
         p_structure_index,
         p_event_class_rec,
         k,
         p_tax_determine_date,
         p_tax,
         p_tax_regime_code,
         l_Determining_Factor_Cq_Code,
         l_trx_numeric_value,
         l_trx_alphanum_value,
         l_trx_date_value,
         p_chart_of_accounts_id,
         p_sob_id,
         p_return_status,
         p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_set_condition',
                         'Incorrect return_status after calling get_trx_value(),'||
                         ' did not get trx value');
        END IF;

        p_result        := FALSE;
        --
        -- this is a serious error, return to the calling
        -- process immediately
        --

        IF g_determining_factor_class_tbl(k) = 'ACCOUNTING_FLEXFIELD' THEN
          p_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

        RETURN;
      END IF;

      -- evaluate each condition for this condition group.
      --
      -- handle accounting flexfield case
      --
      IF (g_determining_factor_class_tbl(k) = 'ACCOUNTING_FLEXFIELD' AND
          g_determining_factor_cq_tbl(k) IS NOT NULL) THEN
  open get_acct_segment_num(TO_NUMBER(g_determining_factor_cq_tbl(k)));
  fetch get_acct_segment_num into n;
  close get_acct_segment_num;
        --n := TO_NUMBER(g_determining_factor_cq_tbl(k));
        --g_trx_alphanumeric_value_tbl(j) := g_segment_array(n);
        IF (g_segment_array.last is NOT NULL AND g_segment_array.last >= n) THEN
          l_trx_alphanum_value :=  g_segment_array(n);
        END IF;
      END IF;
      --
      -- handle =CQ and <>CQ case
      --
      IF (g_operator_tbl(k) = '=CQ' OR
          g_operator_tbl(k) = '<>CQ' ) THEN
        -- get trx value for this right hand side value

        l_Determining_Factor_Cq_Code := g_alphanum_value_tbl(k);

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_set_condition',
                         'calling get_trx_value for CQ case' ||
                         ', Determining_Factor_Cq_Code: ' || l_Determining_Factor_Cq_Code);
        END IF;

        get_trx_value(
           p_structure_name,
           p_structure_index,
           p_event_class_rec,
           k,
           p_tax_determine_date,
           p_tax,
           p_tax_regime_code,
           l_Determining_Factor_Cq_Code,
           g_numeric_value_tbl(k),
           g_alphanum_value_tbl(k),
           g_date_value_tbl(k),
           p_chart_of_accounts_id,
           p_sob_id,
           p_return_status,
           p_error_buffer);

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_set_condition',
                           'Incorrect return_status after calling get_trx_value(),' ||
                           ' did not get trx value for CQ case ');
          END IF;

          p_result        := FALSE;
          --
          -- this is a serious error, return to the calling
          -- process immediately
          --
          RETURN;
        END IF;
      END IF;   /* of CQ Operator_Code */

      --
      -- now evaluate right hand side value with left hand side value
      --
      evaluate_condition(k,
                         l_trx_alphanum_value,
                         l_trx_numeric_value,
                         l_trx_date_value,
                         p_chart_of_accounts_id,
                         p_result,
                         p_return_status,
                         p_error_buffer);
    END IF;

    IF ( g_determining_factor_class_tbl(k) = 'PRODUCT_FISCAL_CLASS' AND
                           g_determining_factor_code_tbl(k) = 'USER_ITEM_TYPE' AND
         l_trx_alphanum_value IS NULL ) THEN
      p_result := FALSE;
    END IF;

    IF ( g_determining_factor_class_tbl(k) = 'TRX_GENERIC_CLASSIFICATION' AND
              g_determining_factor_code_tbl(k) = 'TRX_TYPE' AND
        l_trx_numeric_value IS NULL)  THEN
      p_result := FALSE;
    END IF;

    -- If the result is false, the whole condition is false.
    IF ((NOT p_result) OR (p_result IS NULL))THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_set_condition',
                       'condition is false');
      END IF;
      EXIT; -- out of the condition loop
    END IF;

  END LOOP;  -- condition_counter k;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_set_condition.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: process_set_condition(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_set_condition',
                      p_error_buffer);
    END IF;

END process_set_condition;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_trx_value
--
--  DESCRIPTION
--
--  This procedure is to get transaction value which will be used in the
--  condition evaluation.

PROCEDURE get_trx_value(
            p_structure_name         IN     VARCHAR2,
            p_structure_index        IN     BINARY_INTEGER,
            p_event_class_rec        IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_condition_index        IN     BINARY_INTEGER,
            p_tax_determine_date     IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_tax                    IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code        IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_Determining_Factor_Cq_Code  IN     ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_numeric_value             OUT NOCOPY ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_alphanum_value             OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_date_value                OUT NOCOPY ZX_CONDITIONS.DATE_VALUE%TYPE,
            p_chart_of_accounts_id   IN
                ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
            p_sob_id                 IN
                ZX_CONDITION_GROUPS_B.LEDGER_ID%TYPE,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2)
IS
  i                       BINARY_INTEGER;
  j                       BINARY_INTEGER;
  l_found_in_cache        BOOLEAN;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_trx_value.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT.get_trx_value(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  i := p_condition_index;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_trx_value',
                   'p_condition_index: '|| to_char(p_condition_index) ||
                   ', g_determining_factor_class_tbl: ' || g_determining_factor_class_tbl(i));
  END IF;

  IF g_determining_factor_class_tbl(i) = 'TRX_INPUT_FACTOR' THEN
    IF g_determining_factor_code_tbl(i) = 'TAX_CLASSIFICATION_CODE' THEN
      --
      -- try OUTPUT_TAX_CLASSIFICATION_CODE first
      --
      g_tax_parameter_code_tbl(i) := 'OUTPUT_TAX_CLASSIFICATION_CODE';
      get_tsrm_parameter_value(
                             p_structure_name,
                             p_structure_index,
                             p_condition_index,
                             p_numeric_value,
                             p_alphanum_value,
                             p_date_value,
                             p_return_status,
                             p_error_buffer);
      IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF p_alphanum_value IS NULL THEN
          --
          -- OUTPUT_TAX_CLASSIFICATION_CODE is null,
          -- use INPUT_TAX_CLASSIFICATION_CODE
          --
          g_tax_parameter_code_tbl(i) := 'INPUT_TAX_CLASSIFICATION_CODE';
          get_tsrm_parameter_value(
                             p_structure_name,
                             p_structure_index,
                             p_condition_index,
                             p_numeric_value,
                             p_alphanum_value,
                             p_date_value,
                             p_return_status,
                             p_error_buffer);
        END IF;
      END IF;
    ELSE
      get_tsrm_parameter_value(
                             p_structure_name,
                             p_structure_index,
                             p_condition_index,
                             p_numeric_value,
                             p_alphanum_value,
                             p_date_value,
           p_return_status,
                             p_error_buffer);
    END IF;

  /* Bugfix 3673395 : Determining factor class 'EVENT' is obsolete
  ELSIF g_determining_factor_class_tbl(i) = 'EVENT' THEN
    IF g_determining_factor_code_tbl(i) = 'ENTITY_CODE' THEN
      p_alphanum_value := p_event_class_rec.entity_code;
    ELSIF g_determining_factor_code_tbl(i) = 'EVENT_CLASS_CODE' THEN
      p_numeric_value := p_event_class_rec.event_class_mapping_id;
    ELSIF g_determining_factor_code_tbl(i) = 'TAX_EVENT_CLASS_CODE' THEN
      p_alphanum_value := p_event_class_rec.tax_event_class_code;
    END IF;
  End Bugfix 3673395 */
  ELSE
    --
    -- check from trx value cache structure
    --
/* Bug 5003413 : We will look at the cache only for determination factor class
                 'GEOGRAPHY', 'ACCOUNTING_FLEXFIELD'.
   For Fiscal classifications, we already have caching available in
*/
    l_found_in_cache := FALSE;

    IF g_determining_factor_class_tbl(i) in ('GEOGRAPHY', 'ACCOUNTING_FLEXFIELD') THEN
       j := get_trx_value_index(
                   g_determining_factor_class_tbl(i),
                   g_determining_factor_code_tbl(i),
                   p_Determining_Factor_Cq_Code,
                   g_alphanum_value_tbl(i));

       IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_trx_value',
                     'cache index: ' || to_char(j));
       END IF;

       -- bug 6763074: comment out the code lines for caching because it seems
       --              ZX_TDS_CALC_SERVICES_PUB_PKG.g_trx_alphanum_value_tbl(j)
       --              does not have the value for the current trx line
       --
       --    IF (g_data_type_tbl(i) = 'ALPHANUMERIC' AND
       --        ZX_TDS_CALC_SERVICES_PUB_PKG.g_trx_alphanum_value_tbl.EXISTS(j)) THEN
       --     IF (ZX_TDS_CALC_SERVICES_PUB_PKG.g_trx_alphanum_value_tbl(j) = g_alphanum_value_tbl(i)) THEN
       --            p_alphanum_value := ZX_TDS_CALC_SERVICES_PUB_PKG.g_trx_alphanum_value_tbl(j);
       --            l_found_in_cache := TRUE;
       --          END IF;
       --    ELSIF (g_data_type_tbl(i) = 'NUMERIC' AND
       --        ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl.EXISTS(j)) THEN
       --          -- bug fix 6611984
       --     IF (ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl(j) = g_numeric_value_tbl(i)) THEN
       --            p_numeric_value := ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl(j);
       --            l_found_in_cache := TRUE;
       --     END IF;
       --    END IF;

    END IF;

/* Bug 5003413 */

    IF NOT l_found_in_cache THEN
      --
      -- trx value not exist in cache, need to get it
      --
/***** bug#4673686-  move to evaluate_trx_value_tbl
      IF g_determining_factor_class_tbl(i) = 'USER_DEFINED_GEOGRAPHY' THEN
        get_geography_info(p_structure_name,
                           p_structure_index,
                           p_condition_index,
                           p_alphanum_value,
                           p_Determining_Factor_Cq_Code,
                           p_tax_determine_date,
                           p_return_status,
                           p_error_buffer);
**********/

      -- Bug#4591207
      IF g_determining_factor_class_tbl(i) = 'GEOGRAPHY' THEN
         get_master_geography_info(
                           p_structure_name,
                           p_structure_index,
                           p_condition_index,
                           p_numeric_value,
                           p_Determining_Factor_Cq_Code,
                           p_return_status,
                           p_error_buffer);

      -- Bug#6124314
      ELSIF ( g_determining_factor_class_tbl(i) = 'PRODUCT_FISCAL_CLASS' AND
              g_determining_factor_code_tbl(i) = 'USER_ITEM_TYPE')  THEN
     get_user_item_type_value(
                     p_structure_name,
                           p_structure_index,
                           p_condition_index,
         p_event_class_rec,
         p_numeric_value,
         p_alphanum_value,
                           p_return_status,
                           p_error_buffer);

      -- Bug#6124462
      ELSIF ( g_determining_factor_class_tbl(i) = 'TRX_GENERIC_CLASSIFICATION' AND
              g_determining_factor_code_tbl(i) = 'TRX_TYPE' )  THEN
     get_tsrm_parameter_value(
                           p_structure_name,
                           p_structure_index,
                           p_condition_index,
                           p_numeric_value,
                           p_alphanum_value,
                           p_date_value,
                p_return_status,
                           p_error_buffer);

      ELSIF (g_determining_factor_class_tbl(i) = 'PRODUCT_FISCAL_CLASS'     OR
             g_determining_factor_class_tbl(i) = 'PARTY_FISCAL_CLASS'       OR
             g_determining_factor_class_tbl(i) = 'LEGAL_PARTY_FISCAL_CLASS' OR
             g_determining_factor_class_tbl(i) = 'TRX_FISCAL_CLASS'         OR
             g_determining_factor_class_tbl(i) = 'DOCUMENT'                 OR
             g_determining_factor_class_tbl(i) = 'PRODUCT_GENERIC_CLASSIFICATION'  OR
             g_determining_factor_class_tbl(i) = 'TRX_GENERIC_CLASSIFICATION' ) THEN
        get_fc( p_structure_name,
                p_structure_index,
                p_condition_index,
                p_tax_determine_date,
                p_tax_regime_code,
                p_event_class_rec,
                p_alphanum_value,
                p_Determining_Factor_Cq_Code,
                p_return_status,
                p_error_buffer);

      ELSIF g_determining_factor_class_tbl(i) = 'REGISTRATION' THEN
        get_registration_status(p_structure_name,
                                p_structure_index,
                                p_event_class_rec,
                                p_tax_determine_date,
                                p_tax,
                                p_tax_regime_code,
                                p_alphanum_value,
                                p_Determining_Factor_Cq_Code,
                                p_return_status,
                                p_error_buffer);

      ELSIF g_determining_factor_class_tbl(i) = 'ACCOUNTING_FLEXFIELD' THEN
        get_account_flexfield_info(p_structure_name,
                                   p_structure_index,
                                   p_condition_index,
                                   p_alphanum_value,
                                   p_chart_of_accounts_id,
                                   p_sob_id,
                                   p_return_status,
                                   p_error_buffer);

    /* Bugfix 3673395
       ELSIF g_determining_factor_class_tbl(i) = 'PRODUCT' THEN
         get_product_tax_info(p_structure_name,
                              p_structure_index,
                              g_determining_factor_code_tbl(i),
                              p_alphanum_value,
                              p_return_status,
                              p_error_buffer);

      ELSIF g_determining_factor_class_tbl(i) = 'PARTY' THEN
         get_party_tax_info(p_structure_name,
                            p_structure_index,
                            p_Determining_Factor_Cq_Code,
                            g_determining_factor_code_tbl(i),
                            p_alphanum_value,
                            p_return_status,
                            p_error_buffer);
    */
      END IF;
      IF p_return_status =  FND_API.G_RET_STS_SUCCESS THEN
        -- update trx value cache structure
/* Bug 5003413 */
         IF g_determining_factor_class_tbl(i) in ('GEOGRAPHY', 'ACCOUNTING_FLEXFIELD') THEN
            IF g_data_type_tbl(i) = 'ALPHANUMERIC' THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_trx_alphanum_value_tbl(j) := p_alphanum_value;
            ELSIF g_data_type_tbl(i) = 'NUMERIC' THEN
              ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl(j) := p_numeric_value;
            END IF;
         END IF;
/* Bug 5003413 */
      END IF;

    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_trx_value.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT.get_trx_value(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_trx_value',
                      p_error_buffer);
    END IF;

END get_trx_value;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  evaluate_trx_value_tbl
--
--  DESCRIPTION
--
--  This procedure is to get a table of transaction values
--  and evaluate each value in this table with the condition value
--  of a group until a match is found

-- Bug#4673686 : new procedure to handle multiple zones

PROCEDURE evaluate_trx_value_tbl(
            p_structure_name         IN     VARCHAR2,
            p_structure_index        IN     BINARY_INTEGER,
            p_condition_index        IN     BINARY_INTEGER,
            p_tax_determine_date     IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_Determining_Factor_Cq_Code  IN     ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_chart_of_accounts_id   IN     ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
            p_result                 IN OUT NOCOPY BOOLEAN,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2)
IS
  i                       BINARY_INTEGER;
  j                       BINARY_INTEGER;
  l_trx_alphanum_value    ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE;
  l_trx_date_value        ZX_CONDITIONS.DATE_VALUE%TYPE;

  l_count                 NUMBER;
  l_zone_tbl              HZ_GEO_GET_PUB.zone_tbl_type;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_trx_value_tbl.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT.evaluate_trx_value_tbl(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  i := p_condition_index;
  p_result := FALSE;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_trx_value_tbl',
                   'p_condition_index: '|| to_char(p_condition_index) ||
                   ', g_determining_factor_class_tbl: ' || g_determining_factor_class_tbl(i));
  END IF;

  IF g_determining_factor_class_tbl(i) = 'USER_DEFINED_GEOGRAPHY' THEN
        get_geography_info(p_structure_name,
                           p_structure_index,
                           p_condition_index,
                           l_zone_tbl,
                           p_Determining_Factor_Cq_Code,
                           p_tax_determine_date,
                           p_return_status,
                           p_error_buffer);

      IF (p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                         'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_trx_value_tbl',
                         'Incorrect return_status after calling get_geography_info()' ||
                         ', return_status: '|| p_return_status);
        END IF;
        RETURN;
      END IF;

      l_count := l_zone_tbl.COUNT;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_trx_value_tbl',
                       'Number of rows in Zone table : ' ||
                        TO_CHAR(l_count));
      END IF;

-- Bug fix 5003513
    IF l_count > 0 THEN
      FOR j IN 1.. l_count LOOP
        evaluate_condition(
                         i,
                         l_trx_alphanum_value,
                         l_zone_tbl(j).zone_id,
                         l_trx_date_value,
                         p_chart_of_accounts_id,
                         p_result,
                         p_return_status,
                         p_error_buffer);
         IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF (g_level_error >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_trx_value_tbl',
                           'Incorrect return_status after calling evaluate_condition()' ||
                           ', return_status  '|| p_return_status );
           END IF;

           EXIT;
         END IF;
         IF p_result  THEN
           --
           -- loop until a match is found
           --
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_trx_value_tbl',
                           'Found a matched condition.' );
          END IF;
           EXIT;
         END IF;

      END LOOP;
-- Not finding a zone for a location in the given zone type is a valid condition
-- For example, zones will not be returned for US location for EU zone types.
-- Hence, passing null value for the zone_id.
    ELSIF l_count = 0 THEN
        evaluate_condition(
                         i,
                         l_trx_alphanum_value,
                         NULL,
                         l_trx_date_value,
                         p_chart_of_accounts_id,
                         p_result,
                         p_return_status,
                         p_error_buffer);
         IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF (g_level_error >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_error,
                           'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_trx_value_tbl',
                           'Incorrect return_status after calling evaluate_condition()' ||
                           ', return_status  '|| p_return_status );
           END IF;
           RETURN;
         END IF;
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_trx_value_tbl.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT.evaluate_trx_value_tbl(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_trx_value_tbl',
                      p_error_buffer);
    END IF;

END evaluate_trx_value_tbl;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_tsrm_parameter_value
--
--  DESCRIPTION
--
--  This procedure is to get transaction value when
--  Determining_Factor_Class_Code = 'PARAMETER'.
--  It is called from procedure get_trx_value.  It calls appropriate TSRM
--  function to get trx value directly.
--

PROCEDURE get_tsrm_parameter_value(
            p_structure_name     IN  VARCHAR2,
            p_structure_index    IN  BINARY_INTEGER,
            p_condition_index    IN  BINARY_INTEGER,
            p_numeric_value      OUT NOCOPY ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_alphanum_value     OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_date_value         OUT NOCOPY ZX_CONDITIONS.DATE_VALUE%TYPE,
      p_return_status      OUT NOCOPY VARCHAR2,
            p_error_buffer       OUT NOCOPY VARCHAR2)
IS
   i        BINARY_INTEGER;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_parameter_value.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_tsrm_parameter_value(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  i :=  p_condition_index;

  IF g_data_type_tbl(i) = 'NUMERIC' THEN

    get_tsrm_num_value(
            p_structure_name,
            p_structure_index,
            g_tax_parameter_code_tbl(i),
            p_numeric_value,
            p_return_status,
            p_error_buffer);

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_parameter_value',
                     'parameter code: ' || g_tax_parameter_code_tbl(i) ||
                     ', p_numeric_value: ' || p_numeric_value );
    END IF;

  ELSIF g_data_type_tbl(i) = 'DATE' THEN

    ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
      p_structure_name,
      p_structure_index,
      g_tax_parameter_code_tbl(i),
      p_date_value,
      p_return_status
      );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_parameter_value',
                     'parameter code: ' || g_tax_parameter_code_tbl(i) ||
                     ', trx_date value: ' || to_char(p_date_value, 'DD-MON-YY'));
    END IF;

  ELSIF g_data_type_tbl(i) = 'ALPHANUMERIC' THEN

    get_tsrm_alphanum_value(
            p_structure_name,
            p_structure_index,
            g_tax_parameter_code_tbl(i),
            p_alphanum_value,
            p_return_status,
            p_error_buffer);

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_parameter_value',
                     'parameter code: ' || g_tax_parameter_code_tbl(i) ||
                     ', p_alphanum_value: ' || p_alphanum_value );
    END IF;
  ELSE

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'Invalid data type';
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_parameter_value',
                     'Invalid data type, data type must be ALPHANUMERIC, NUMERIC, DATE');
    END IF;

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_parameter_value.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_tsrm_parameter_value(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_parameter_value',
                      p_error_buffer);
    END IF;

END get_tsrm_parameter_value;

----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_tsrm_num_value
--
--  DESCRIPTION
--
--  This procedure gets tsrm parameter value from the cache if available
--  before it calls TSRM API to get the parameter value and then inserts
--  the value to the cache structure

PROCEDURE get_tsrm_num_value(
            p_structure_name         IN  VARCHAR2,
            p_structure_index        IN  BINARY_INTEGER,
            p_parameter_code         IN  ZX_PARAMETERS_B.TAX_PARAMETER_CODE%TYPE,
            p_trx_numeric_value      OUT NOCOPY ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)
IS
  --l_table_index                   NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_tsrm_num_value(+)');
    FND_LOG.STRING(g_level_statement ,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value',
                   'p_parameter_code: ' || p_parameter_code );
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

-- commenting caching as no value check is possible at this point.
-- for checking if the value in cache is matching the current transaction value
-- we need to call get_driver_value
-- therefore commenting the caching logic as calling get_driver_value inside cache is redundant

 /* l_table_index := dbms_utility.get_hash_value(
                        p_parameter_code,
                        1,
                        8192); */

  --IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl.EXISTS(l_table_index) THEN
  --  p_trx_numeric_value := ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl(l_table_index);
  --ELSE

    ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
        p_structure_name,
        p_structure_index,
        p_parameter_code,
        p_trx_numeric_value,
        p_return_status
        );

    --IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
    --  ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl(l_table_index) := p_trx_numeric_value;
    --END IF;
  --END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value',
                   'trx_num_value: ' || to_char(p_trx_numeric_value));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_tsrm_num_value(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_num_value',
                      p_error_buffer);
    END IF;

END get_tsrm_num_value;
----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_tsrm_alphanum_value
--
--  DESCRIPTION
--
--  This procedure gets tsrm parameter value from the cache if available
--  before it calls TSRM API to get the parameter value and then inserts
--  the value to the cache structure

PROCEDURE get_tsrm_alphanum_value(
            p_structure_name         IN  VARCHAR2,
            p_structure_index        IN  BINARY_INTEGER,
            p_parameter_code         IN  ZX_PARAMETERS_B.TAX_PARAMETER_CODE%TYPE,
            p_trx_alphanumeric_value    OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2)
IS
  --l_table_index                    NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_alphanum_value.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_tsrm_alphanum_value(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_alphanum_value',
                   'p_parameter_code: ' || p_parameter_code );
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

-- commenting caching as no value check is possible at this point.
-- for checking if the value in cache is matching the current transaction value
-- we need to call get_driver_value
-- therefore commenting the caching logic as calling get_driver_value inside cache is redundant

  /* l_table_index := dbms_utility.get_hash_value(
                        p_parameter_code,
                        1,
                        8192); */

  --IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl.EXISTS(l_table_index) THEN
  --  p_trx_alphanumeric_value := ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl(l_table_index);
  --ELSE

    ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
        p_structure_name,
        p_structure_index,
        p_parameter_code,
        p_trx_alphanumeric_value,
        p_return_status
        );
    --IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
    --  ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl(l_table_index) := p_trx_alphanumeric_value;
    --END IF;
  --END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_alphanum_value',
                   'trx_char_value: ' || p_trx_alphanumeric_value);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_alphanum_value.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_tsrm_alphanum_value(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tsrm_alphanum_value',
                      p_error_buffer);
    END IF;

END get_tsrm_alphanum_value;
----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_account_num_value
--
--  DESCRIPTION
--
--  This procedure gets account parameter value from the cache if available
--  before it calls TSRM API to get the parameter value and then inserts
--  the value to the cache structure

PROCEDURE get_account_num_value(
            p_structure_name         IN  VARCHAR2,
            p_structure_index        IN  BINARY_INTEGER,
            p_parameter_code         IN  ZX_PARAMETERS_B.TAX_PARAMETER_CODE%TYPE,
            p_trx_numeric_value      OUT NOCOPY ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)
IS
  l_table_index                   NUMBER;
  l_in_cache_flg                  BOOLEAN := FALSE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_num_value.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_account_num_value(+)');
    FND_LOG.STRING(g_level_statement ,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_num_value',
                   'p_parameter_code: ' || p_parameter_code );
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  l_table_index := dbms_utility.get_hash_value(
                        p_parameter_code,
                        1,
                        8192);

  IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl.EXISTS(l_table_index) THEN
   IF (ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl(l_table_index) =
              ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ACCOUNT_CCID(p_structure_index)) THEN
      p_trx_numeric_value := ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl(l_table_index);
      l_in_cache_flg := TRUE;
   END IF;
  END IF;

  IF NOT l_in_cache_flg THEN
    ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
        p_structure_name,
        p_structure_index,
        p_parameter_code,
        p_trx_numeric_value,
        p_return_status
        );

    IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_num_value_tbl(l_table_index) := p_trx_numeric_value;
    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_num_value',
                   'trx_num_value: ' || to_char(p_trx_numeric_value));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_num_value.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_account_num_value(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_num_value',
                      p_error_buffer);
    END IF;

END get_account_num_value;
----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_account_alphanum_value
--
--  DESCRIPTION
--
--  This procedure gets account parameter value from the cache if available
--  before it calls TSRM API to get the parameter value and then inserts
--  the value to the cache structure

PROCEDURE get_account_alphanum_value(
            p_structure_name         IN  VARCHAR2,
            p_structure_index        IN  BINARY_INTEGER,
            p_parameter_code         IN  ZX_PARAMETERS_B.TAX_PARAMETER_CODE%TYPE,
            p_trx_alphanumeric_value    OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2)
IS
  l_table_index                    NUMBER;
  l_in_cache_flg                   BOOLEAN := FALSE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_alphanum_value.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_account_alphanum_value(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_alphanum_value',
                   'p_parameter_code: ' || p_parameter_code );
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

    l_table_index := dbms_utility.get_hash_value(
                        p_parameter_code,
                        1,
                        8192);

  IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl.EXISTS(l_table_index) THEN
    IF (ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl(l_table_index) =
           ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ACCOUNT_STRING(p_structure_index)) THEN
      p_trx_alphanumeric_value := ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl(l_table_index);
      l_in_cache_flg := TRUE;
    END IF;
  END IF;

  IF NOT l_in_cache_flg THEN
    ZX_GET_TAX_PARAM_DRIVER_PKG.get_driver_value(
        p_structure_name,
        p_structure_index,
        p_parameter_code,
        p_trx_alphanumeric_value,
        p_return_status
        );
    IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl(l_table_index) := p_trx_alphanumeric_value;
    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_alphanum_value',
                   'trx_char_value: ' || p_trx_alphanumeric_value);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_alphanum_value.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_account_alphanum_value(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_alphanum_value',
                      p_error_buffer);
    END IF;

END get_account_alphanum_value;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_user_item_type_value
--
--  DESCRIPTION
--
--  This procedure is to get user item type value when
--  Determining_Factor_Class_Code = 'PRODUCT_FISCAL_CLASS'.
--  It is called from procedure get_trx_value.  It calls appropriate
--  function to get trx value directly.
--

PROCEDURE get_user_item_type_value(
            p_structure_name     IN  VARCHAR2,
            p_structure_index    IN  BINARY_INTEGER,
            p_condition_index    IN  BINARY_INTEGER,
      p_event_class_rec    IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE,
      p_numeric_value      OUT NOCOPY ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_alphanum_value     OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status      OUT NOCOPY VARCHAR2,
            p_error_buffer       OUT NOCOPY VARCHAR2)
IS
   i        BINARY_INTEGER;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_user_item_type_value.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_user_item_type_value(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  i :=  p_condition_index;

  IF g_data_type_tbl(i) = 'ALPHANUMERIC' THEN

    get_user_item_alphanum_value(
            p_structure_name,
            p_structure_index,
            g_determining_factor_code_tbl(i),
      p_event_class_rec,
            p_alphanum_value,
            p_return_status,
            p_error_buffer);

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_user_item_type_value',
                     'parameter code: ' || g_determining_factor_code_tbl(i) ||
                     ', p_alphanum_value: ' || p_alphanum_value );
    END IF;
  ELSE

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'Invalid data type';
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_user_item_type_value',
                     'Invalid data type, data type must be ALPHANUMERIC');
    END IF;

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_user_item_type_value.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_user_item_type_value(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_user_item_type_value',
                      p_error_buffer);
    END IF;

END get_user_item_type_value;
-----------------------------------------------------------------------

--  PRIVATE PROCEDURE
--  get_user_item_alphanum_value
--
--  DESCRIPTION
--
--  This procedure gets user item type value from the cache if available
--  before it calls TSRM API to get the user item type value and then inserts
--  the value to the cache structure

PROCEDURE get_user_item_alphanum_value(
            p_structure_name         IN  VARCHAR2,
            p_structure_index        IN  BINARY_INTEGER,
            p_parameter_code         IN  ZX_PARAMETERS_B.TAX_PARAMETER_CODE%TYPE,
      p_event_class_rec        IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_trx_alphanumeric_value    OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2)
IS
  l_table_index                    NUMBER;
  l_trx_alphanumeric_value         ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE;
  l_in_cache_flg                   BOOLEAN := FALSE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_user_item_alphanum_value.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_user_item_alphanum_value(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_user_item_alphanum_value',
                   'p_parameter_code: ' || p_parameter_code );
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

    l_table_index := dbms_utility.get_hash_value(
                        p_parameter_code,
                        1,
                        8192);
  BEGIN
      SELECT item_type
      INTO l_trx_alphanumeric_value
      FROM MTL_SYSTEM_ITEMS
      WHERE inventory_item_id =  ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PRODUCT_ID(p_structure_index)
      AND organization_id =  nvl(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.PRODUCT_ORG_ID(p_structure_index),
                                         p_event_class_rec.internal_organization_id);
  EXCEPTION
      WHEN NO_DATA_FOUND then
         p_trx_alphanumeric_value  := NULL;
      WHEN TOO_MANY_ROWS then
         p_trx_alphanumeric_value := NULL;
  END;

  IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl.EXISTS(l_table_index) THEN
    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl(l_table_index) = l_trx_alphanumeric_value THEN
      p_trx_alphanumeric_value := ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl(l_table_index);
      l_in_cache_flg := TRUE;
    END IF;
  END IF;

  IF NOT l_in_cache_flg THEN
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_tsrm_alphanum_value_tbl(l_table_index) := l_trx_alphanumeric_value;
    p_trx_alphanumeric_value := l_trx_alphanumeric_value;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_user_item_alphanum_value',
                   'trx_char_value: ' || p_trx_alphanumeric_value);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_user_item_alphanum_value.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_user_item_alphanum_value(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_user_item_alphanum_value',
                      p_error_buffer);
    END IF;

END get_user_item_alphanum_value;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_fc
--
--  DESCRIPTION
--    This procedure returns the fiscal classification code  obtained from
--    the cache structure if available, if not it calls TCM API to get it
--    and insert the value to the cache structure
--

PROCEDURE get_fc(
            p_structure_name          IN  VARCHAR2,
            p_structure_index         IN  BINARY_INTEGER,
            p_condition_index         IN  BINARY_INTEGER,
            p_tax_determine_date      IN  ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_tax_regime_code         IN  ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_event_class_rec         IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_trx_alphanumeric_value  OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_Determining_Factor_Cq_Code   IN ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2)

IS
  l_found                           BOOLEAN;
  l_first_party_flag                BOOLEAN;
  l_substr_cq_party                 VARCHAR2(15);
  l_hq_estb_flag                    VARCHAR2(1);
  l_le_flag                         VARCHAR2(1);
  l_third_party_flag                VARCHAR2(1);
  l_parameter_code                  ZX_PARAMETERS_B.TAX_PARAMETER_CODE%TYPE;
  l_classified_entity_id            NUMBER;
  l_item_org_id                     NUMBER;
  l_le_id                           NUMBER;
  l_length                          NUMBER;
  l_prod_trx_parm_value             ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE;
  l_fsc_rec                         ZX_TCM_CONTROL_PKG.ZX_FISCAL_CLASS_INFO_REC;
  l_fsc_cat_rec                     ZX_TCM_CONTROL_PKG.ZX_CATEGORY_CODE_INFO_REC;
  i                                 BINARY_INTEGER;
  j                                 BINARY_INTEGER;
  l_classification_category         ZX_FC_TYPES_B.Classification_Type_Categ_Code%TYPE;
  l_classification_type             ZX_FC_TYPES_B.CLASSIFICATION_TYPE_CODE%TYPE;
  l_condition_value                 ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE;

  l_fc_base_category_set_id         zx_fc_types_b.owner_id_num%TYPE;
  l_fc_level                        zx_fc_types_b.classification_type_level_code%TYPE;
  l_level_start_position            zx_fc_types_b.start_position%TYPE;
  l_level_num_characters            zx_fc_types_b.num_characters%TYPE;
  l_level_delimiter                 zx_fc_types_b.delimiter%TYPE;
  l_default_taxation_country        zx_lines_det_factors.default_taxation_country%TYPE;
  l_country_def_category_set_id     zx_fc_country_defaults.primary_inventory_category_set%TYPE;
  l_product_fisc_classification     zx_lines_det_factors.product_fisc_classification%TYPE;

  -- Added the variable l_product_org_id for Bug#9530065
  l_product_org_id                  NUMBER;

  -- Added following cursor for Bug Fix 5163401

  CURSOR c_get_le_ptp_id(c_le_id NUMBER) IS
  SELECT ptp.party_tax_profile_id
  FROM zx_party_tax_profile ptp,
       xle_entity_profiles le
  WHERE ptp.party_type_code = 'FIRST_PARTY'
  AND   ptp.party_id = le.party_id
  AND   le.legal_entity_id = c_le_id;

  CURSOR c_fc_base_category_set(c_classification_type_code VARCHAR2) IS
  SELECT owner_id_num,
         classification_type_level_code,
         start_position,
         num_characters,
         delimiter
    FROM zx_fc_types_b
   WHERE classification_type_code = c_classification_type_code;

  CURSOR c_country_def_category_set_id(c_country_code VARCHAR2) IS
  SELECT primary_inventory_category_set
    FROM zx_fc_country_defaults
   WHERE country_code = c_country_code;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_fc(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  i :=  p_condition_index;

  l_classification_category := g_determining_factor_class_tbl(i);
  l_classification_type     := g_determining_factor_code_tbl(i);
  l_condition_value         := g_alphanum_value_tbl(i);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                   'l_classification_category: ' || l_classification_category ||
                   ', l_classification_type: '|| l_classification_type ||
                   ', l_condition_value: ' || l_condition_value);
  END IF;

  IF l_classification_category IN ('PRODUCT_GENERIC_CLASSIFICATION',
                                   'TRX_GENERIC_CLASSIFICATION',
                                   'DOCUMENT') THEN

    IF l_classification_category = 'DOCUMENT' THEN
      -- bug#5014051-
      l_parameter_code := 'DOCUMENT_SUB_TYPE';
    ELSIF l_classification_category = 'PRODUCT_GENERIC_CLASSIFICATION' THEN
      l_parameter_code := 'PRODUCT_CATEGORY';
    ELSE
      l_parameter_code := 'TRX_BUSINESS_CATEGORY';
    END IF;
    --
    -- get transaction value from TSRM
    --
    get_tsrm_alphanum_value(
        p_structure_name,
        p_structure_index,
        l_parameter_code,
        l_prod_trx_parm_value,
        p_return_status,
        p_error_buffer );

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'Incorrect return_status after calling get_tsrm_alphanum_value()' ||
                     ', return_status: ' || p_return_status);
      END IF;

      RETURN;
    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'l_prod_trx_parm_value: ' || l_prod_trx_parm_value);
    END IF;

    --
    -- get driver_value from TCM API
    --
    l_fsc_cat_rec.classification_type     := l_classification_type;
    l_fsc_cat_rec.tax_determine_date      := p_tax_determine_date;
    l_fsc_cat_rec.classification_category := l_classification_category;
    l_fsc_cat_rec.parameter_value         := l_prod_trx_parm_value;
    l_fsc_cat_rec.condition_subclass      := p_Determining_Factor_Cq_Code;


    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'calling ZX_TCM_CONTROL_PKG.GET_PROD_TRX_CATE_VALUE');
    END IF;


    IF p_Determining_Factor_Cq_Code is NULL then
    -- CR 2944893 use the value passed from the transaction as the condition value
    -- when class qualifier is NULL

       p_trx_alphanumeric_value := l_prod_trx_parm_value;

    ELSE
       ZX_TCM_CONTROL_PKG.GET_PROD_TRX_CATE_VALUE(
                         l_fsc_cat_rec,
                         p_return_status);

       IF p_return_status  = FND_API.G_RET_STS_SUCCESS THEN
         p_trx_alphanumeric_value := l_fsc_cat_rec.condition_value;
       END IF;

    END  IF; -- Null Class Qualifier

  ELSIF l_classification_category = 'TRX_FISCAL_CLASS' THEN

    l_parameter_code := 'TRX_BUSINESS_CATEGORY';

    -- get transaction value from TSRM
    get_tsrm_alphanum_value(
        p_structure_name,
        p_structure_index,
        l_parameter_code,
        l_prod_trx_parm_value,
        p_return_status,
        p_error_buffer );

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'Incorrect return_status after calling get_tsrm_alphanum_value()' ||
                     ', return_status: ' || p_return_status);
      END IF;
      RETURN;
    END IF;

    l_fsc_rec.classification_type     := l_classification_type;
    l_fsc_rec.tax_regime_code         := p_tax_regime_code;
    l_fsc_rec.tax_determine_date      := p_tax_determine_date;
    l_fsc_rec.classification_category := l_classification_category;
    l_fsc_rec.classified_entity_id    := l_classified_entity_id;
    l_fsc_rec.application_id          := p_event_class_rec.application_id;
    l_fsc_rec.event_class_code        := l_prod_trx_parm_value;
    l_fsc_rec.condition_value         := l_condition_value;

    IF l_prod_trx_parm_value IS NOT NULL  THEN

      ZX_TCM_CONTROL_PKG.GET_FISCAL_CLASSIFICATION(
        l_fsc_rec,
        p_return_status);

      IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
         p_trx_alphanumeric_value := l_fsc_rec.fsc_code;
      ELSE
        -- Bugfix 4882676: ignore error even if fc not found
        p_return_status := FND_API.G_RET_STS_SUCCESS;
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'ignore error even if fc not found ' );
        END IF;
      END IF;
      IF p_trx_alphanumeric_value IS NULL OR p_trx_alphanumeric_value = FND_API.G_MISS_CHAR THEN
        p_trx_alphanumeric_value := FND_API.G_MISS_CHAR||FND_API.G_MISS_CHAR;
      END IF;
    END IF;  --Checking for NULL case for calling GET_FISCAL_CLASSIFICATION

  ELSIF l_classification_category = 'PRODUCT_FISCAL_CLASS' THEN

    -- get base category_set_id for the FC type
    OPEN c_fc_base_category_set(l_classification_type);
    FETCH c_fc_base_category_set
     INTO l_fc_base_category_set_id,
          l_fc_level,
          l_level_start_position,
          l_level_num_characters,
          l_level_delimiter;
    CLOSE c_fc_base_category_set;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                   'l_fc_base_category_set_id: '||l_fc_base_category_set_id ||
                   ', l_fc_level: '||l_fc_level ||
                   ', l_level_start_position: '||l_level_start_position ||
                   ', l_level_num_characters: '||l_level_num_characters ||
                   ', l_level_delimiter: '||l_level_delimiter );
    END IF;

    -- get category_set_id for the taxation_country
    l_parameter_code := 'DEFAULT_TAXATION_COUNTRY';

    -- get transaction value from TSRM
    get_tsrm_alphanum_value(
      p_structure_name,
      p_structure_index,
      l_parameter_code,
      l_default_taxation_country,
      p_return_status,
      p_error_buffer );

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'Called get_tsrm_alphanum_value to get DEFAULT_TAXATION_COUNTRY' ||
                     ', return_status: ' || p_return_status);
      END IF;

      RETURN;
    END IF;

    OPEN c_country_def_category_set_id(l_default_taxation_country);

    FETCH c_country_def_category_set_id into l_country_def_category_set_id;
    CLOSE c_country_def_category_set_id;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                   'l_country_def_category_set_id: '||l_country_def_category_set_id );
    END IF;

    l_parameter_code := 'PRODUCT_FISC_CLASSIFICATION';

    -- get transaction value from TSRM
    get_tsrm_alphanum_value(
      p_structure_name,
      p_structure_index,
      l_parameter_code,
      l_product_fisc_classification,
      p_return_status,
      p_error_buffer );

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'Called get_tsrm_alphanum_value to get PRODUCT_FISC_CLASSIFICATION' ||
                     ', return_status: ' || p_return_status);
      END IF;

      RETURN;
    END IF;

    IF l_fc_base_category_set_id = l_country_def_category_set_id
      AND l_product_fisc_classification IS NOT NULL
    THEN

      -- If the base inventory category set (id) for the FC Type of
      -- the rule matches the value of the country default (of the
      -- default taxation country), rule value will be compared with
      -- (substring) transaction line level value and if it does not match,
      -- then rule will not be considered as successful.

      -- If the transaction line level value is high than that of the condition value,
      -- need to get the substring of the same level of the condition value.
      -- Should not use LENGTHB() since the NUM_CHARACTERS counts in characters
      -- NOTE: LENGTH(l_condition_value) = l_level_num_characters

      p_trx_alphanumeric_value := l_product_fisc_classification;

      IF l_level_delimiter IS NULL THEN
        -- product fiscal class is sub string type

        IF LENGTH(p_trx_alphanumeric_value) > NVL(l_level_start_position, 1) + l_level_num_characters - 1 THEN
          p_trx_alphanumeric_value := SUBSTR(p_trx_alphanumeric_value,
                                             NVL(l_level_start_position, 1),
                                             l_level_num_characters);
        END IF;

      ELSE
        -- product fiscal class is delimiter type

        IF INSTR(p_trx_alphanumeric_value, l_level_delimiter, 1, l_fc_level) > 0 THEN
          p_trx_alphanumeric_value := SUBSTR(p_trx_alphanumeric_value,
                                             1,
                                             INSTR(p_trx_alphanumeric_value, l_level_delimiter, 1, l_fc_level) - 1 );
        END IF;

      END IF;

    ELSE
      -- If the base inventory category set (id) for the FC Type of the
      -- rule "Does Not" match the value of the country default (of the
      -- default taxation country), rule value will be compared value
      -- associated with item.

      l_parameter_code := 'PRODUCT_ID';

      -- get transaction value from TSRM
      get_tsrm_num_value(
        p_structure_name,
        p_structure_index,
        l_parameter_code,
        l_classified_entity_id,
        p_return_status,
        p_error_buffer );

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                       'Called get_tsrm_num_value to get PRODUCT_ID' ||
                       ', return_status: ' || p_return_status);
        END IF;

        RETURN;
      END IF;

      -- get organization id for item
      -- Bug 7250592
      IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
         l_parameter_code := 'SHIP_FROM_PARTY_ID';
      ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
         l_parameter_code := 'SHIP_TO_PARTY_ID';
      ELSE
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                       'Invalid prod_family_grp_code');
        END IF;
        RETURN;
      END IF;

      get_tsrm_num_value(
        p_structure_name,
        p_structure_index,
        l_parameter_code,
        l_item_org_id,
        p_return_status,
        p_error_buffer );

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                       'Called get_tsrm_num_value to get ' ||l_parameter_code|| ', return_status: ' || p_return_status);
        END IF;
        RETURN;
      END IF;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                       'item_org_id: ' || to_char(l_item_org_id));
      END IF;

      -- get product org id
      l_parameter_code := 'PRODUCT_ORG_ID';

      get_tsrm_num_value(
          p_structure_name,
          p_structure_index,
          l_parameter_code,
          l_product_org_id,
          p_return_status,
          p_error_buffer );

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'Called get_tsrm_num_value to get PRODUCT_ORG_ID' ||
                     ', return_status: ' || p_return_status);
        END IF;
        RETURN;
      END IF;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'product_org_id: ' || to_char(l_product_org_id));
      END IF;

      --
      -- check if can get fsc code from the cache
      --
      get_fsc_code(
             l_found,
             p_tax_regime_code,
             l_classification_category,
             l_classification_type,
             p_tax_determine_date,
             l_classified_entity_id,
             NVL(l_item_org_id,l_product_org_id),
             p_event_class_rec.application_id,
             p_event_class_rec.event_class_code,
             p_trx_alphanumeric_value);

      IF NOT l_found THEN
        l_fsc_rec.classification_type     := l_classification_type;
        l_fsc_rec.tax_regime_code         := p_tax_regime_code;
        l_fsc_rec.tax_determine_date      := p_tax_determine_date;
        l_fsc_rec.classification_category := l_classification_category;
        l_fsc_rec.classified_entity_id    := l_classified_entity_id;
        l_fsc_rec.item_org_id             := NVL(l_item_org_id,l_product_org_id);
        l_fsc_rec.application_id          := p_event_class_rec.application_id;
        l_fsc_rec.event_class_code        := p_event_class_rec.event_class_code;
        l_fsc_rec.condition_value         := l_condition_value;

        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                         'calling ZX_TCM_CONTROL_PKG.GET_FISCAL_CLASSIFICATION');
        END IF;

        --Bug Fix 4774215
        /*If there is no enough information to call the procedure while evaluating rule,need to
          go further and evaluate the next rule in the hierarchy.*/

        -- Bug fix 4941566
        /* Only product category need the item_org_id */

        IF (l_fsc_rec.classified_entity_id is NOT NULL AND
            l_fsc_rec.item_org_id is NOT NULL)
        THEN
          ZX_TCM_CONTROL_PKG.GET_FISCAL_CLASSIFICATION(
              l_fsc_rec,
              p_return_status);

          IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
            NULL;
          ELSE
            -- Bugfix 4882676: ignore error even if fc not found
            l_fsc_rec.fsc_code := NULL;
            p_return_status := FND_API.G_RET_STS_SUCCESS;

            -- Start : Added the code to fetch the PFC for Product Org Id
            --         if not found for Item Org Id for Bug#9530065
            IF l_item_org_id IS NOT NULL THEN
              IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_statement,
                               'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                               'PFC Not found for item org id. Fetching PFC for Product Org Id...' );
              END IF;

              -- check if can get fsc code from the cache
              get_fsc_code(
                      l_found,
                      p_tax_regime_code,
                      l_classification_category,
                      l_classification_type,
                      p_tax_determine_date,
                      l_classified_entity_id,
                      l_product_org_id,
                      p_event_class_rec.application_id,
                      p_event_class_rec.event_class_code,
                      p_trx_alphanumeric_value);

              IF NOT l_found THEN
                l_fsc_rec.classification_type     := l_classification_type;
                l_fsc_rec.tax_regime_code         := p_tax_regime_code;
                l_fsc_rec.tax_determine_date      := p_tax_determine_date;
                l_fsc_rec.classification_category := l_classification_category;
                l_fsc_rec.classified_entity_id    := l_classified_entity_id;
                l_fsc_rec.item_org_id             := l_product_org_id;
                l_fsc_rec.application_id          := p_event_class_rec.application_id;
                l_fsc_rec.event_class_code        := p_event_class_rec.event_class_code;
                l_fsc_rec.condition_value         := l_condition_value;

                IF (g_level_statement >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement,
                                 'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                                 'calling ZX_TCM_CONTROL_PKG.GET_FISCAL_CLASSIFICATION');
                END IF;

                IF (l_fsc_rec.classified_entity_id is NOT NULL AND
                    l_fsc_rec.item_org_id is NOT NULL)
                THEN
                  ZX_TCM_CONTROL_PKG.GET_FISCAL_CLASSIFICATION(
                      l_fsc_rec,
                      p_return_status);

                  IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
                    NULL;
                  ELSE
                    p_return_status := FND_API.G_RET_STS_SUCCESS;
                    IF (g_level_statement >= g_current_runtime_level ) THEN
                        FND_LOG.STRING(g_level_statement,
                                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                                       'PFC not found for Product Org Id. Ignore error...' );
                    END IF;
                  END IF;
                END IF;  -- IF l_fsc_rec.classified_entity_id is NOT NULL ..
              END IF;  -- Not found in cache

            ELSE
              IF (g_level_statement >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                                'PFC not found for Product Org Id. Ignore error...' );
              END IF;

            END IF;  -- If l_item_org_id is not null
            -- End : Code added for Bug#9530065

          END IF;
        p_trx_alphanumeric_value := NVL(l_fsc_rec.fsc_code, FND_API.G_MISS_CHAR||FND_API.G_MISS_CHAR);
        j := OPTIMAL_FSC_TBL_LOCATION();
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(j) := l_fsc_rec;

       END IF;  --Checking for NULL case for calling GET_FISCAL_CLASSIFICATION
      END IF; -- Not found in cache
    END IF; --  l_fc_base_category_set_id = l_country_def_category_set_id
    IF p_trx_alphanumeric_value IS NULL OR p_trx_alphanumeric_value = FND_API.G_MISS_CHAR THEN
      p_trx_alphanumeric_value := FND_API.G_MISS_CHAR||FND_API.G_MISS_CHAR;
    END IF;
  ELSE
    --
    -- party,  transaction, product fiscal classifications
    --
    IF l_classification_category  = 'PARTY_FISCAL_CLASS' THEN

-- Fix for Bug 4873457 - Site level classification for first parties implies the classification
-- of secondary establishments (i.e., not of type HQ establishments)
--                     - Party level classification for first parties implies the classification
-- of HQ establishments. Optionally, in the case of party level classifications, we can attempt
-- to derive the classifications at LE level. This makes sense as we currently allow the fiscal
-- classification of LEs in our UIs. [Note that this is **different** from Legal Classifications]

      IF l_classification_category  = 'PARTY_FISCAL_CLASS' THEN
        l_first_party_flag := evaluate_if_first_party(p_Determining_Factor_Cq_Code);
      END IF;

-- Fix for Bug 5163401 - Site level is removed from the rule conditions. Following is the logic:
--
-- For Third Parties: Look at site first and then at the party. For example, if 'Bill From'
-- represents a third party for the input event class, then look for Party FC associated with
-- 'Bill From Party Site' first. If no assignments are found for this, i.e. if TCM API returns
-- G_MISS_CHAR, then look for Party FC associated with 'Bill From Party'.
--
-- For First Parties: Look at the Secondary Estalishment first and if not found, then look at the
-- HQ Establishment and if it is also not found, look for the Legal Entity. For example, if
-- 'Bill From' represents a first party establishment for the input event class, then look for Party
-- FC associated with 'Bill From Party Site' first. If no assignments are found for this, then look for
-- Party FC associated with 'HQ Establishment'. If this is also not found, then look for the Party FC
-- associated with 'Legal Entity'.
--

      IF l_first_party_flag THEN
        l_parameter_code  := p_Determining_Factor_Cq_Code || '_' || 'TAX_PROF_ID';
        l_hq_estb_flag := 'N';
      ELSE
        l_parameter_code  := REPLACE(p_Determining_Factor_Cq_Code, 'PARTY', 'SITE') || '_' || 'TAX_PROF_ID';
        l_third_party_flag := 'N';
      END IF;

    ELSIF l_classification_category = 'LEGAL_PARTY_FISCAL_CLASS' THEN
      l_parameter_code := 'LEGAL_ENTITY_ID';
    END IF;

    --
    -- get transaction value from TSRM
    --
    get_tsrm_num_value(
      p_structure_name,
      p_structure_index,
      l_parameter_code,
      l_classified_entity_id,
      p_return_status,
      p_error_buffer );

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'Incorrect return_status after calling  get_tsrm_num_value' ||
                     ', return_status: ' || p_return_status);
      END IF;

      RETURN;
    END IF;

    IF l_classification_category  = 'PARTY_FISCAL_CLASS'
     AND l_classified_entity_id IS NULL THEN

      IF l_first_party_flag THEN
        l_parameter_code := 'HQ_ESTB_PARTY_TAX_PROF_ID';
        l_hq_estb_flag := 'Y';
      ELSE
        l_parameter_code  := p_Determining_Factor_Cq_Code || '_' || 'TAX_PROF_ID';
        l_third_party_flag := 'Y';
      END IF;

      --
      -- get transaction value from TSRM
      --
      get_tsrm_num_value(
        p_structure_name,
        p_structure_index,
        l_parameter_code,
        l_classified_entity_id,
        p_return_status,
        p_error_buffer );

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                       'Incorrect return_status after calling  get_tsrm_num_value' ||
                       ', return_status: ' || p_return_status);
        END IF;

        RETURN;
      END IF;

    END IF; -- End of check for classification category and classified entity id

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'classified_entity_id: ' || to_char(l_classified_entity_id));
    END IF;

    --
    -- check if can get fsc code from the cache
    --
    get_fsc_code(
           l_found,
           p_tax_regime_code,
           l_classification_category,
           l_classification_type,
           p_tax_determine_date,
           l_classified_entity_id,
           l_item_org_id,
           p_event_class_rec.application_id,
           p_event_class_rec.event_class_code,
           p_trx_alphanumeric_value);

    IF NOT l_found THEN
      l_fsc_rec.classification_type     := l_classification_type;
      l_fsc_rec.tax_regime_code         := p_tax_regime_code;
      l_fsc_rec.tax_determine_date      := p_tax_determine_date;
      l_fsc_rec.classification_category := l_classification_category;
      l_fsc_rec.classified_entity_id    := l_classified_entity_id;
      l_fsc_rec.item_org_id             := l_item_org_id;
      l_fsc_rec.application_id          := p_event_class_rec.application_id;
      l_fsc_rec.event_class_code        := p_event_class_rec.event_class_code;
      l_fsc_rec.condition_value         := l_condition_value;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                       'calling ZX_TCM_CONTROL_PKG.GET_FISCAL_CLASSIFICATION');
      END IF;

      --Bug Fix 4774215
     /*If there is no enough information to call the procedure while evaluating rule,need to
       go further and evaluate the next rule in the hierarchy.*/

     -- Bug fix 4941566
     /* Only product category need the item_org_id */

     IF l_fsc_rec.classified_entity_id is NOT NULL THEN

      ZX_TCM_CONTROL_PKG.GET_FISCAL_CLASSIFICATION(
        l_fsc_rec,
        p_return_status);

      IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
       NULL;
      ELSE
        -- Bugfix 4882676: ignore error even if fc not found
        l_fsc_rec.fsc_code := FND_API.G_MISS_CHAR||FND_API.G_MISS_CHAR;
        p_return_status := FND_API.G_RET_STS_SUCCESS;
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'ignore error even if fc not found ' );
        END IF;
      END IF;
      p_trx_alphanumeric_value := NVL(l_fsc_rec.fsc_code, FND_API.G_MISS_CHAR||FND_API.G_MISS_CHAR);
      j := OPTIMAL_FSC_TBL_LOCATION();
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(j) := l_fsc_rec;

     END IF;  --Checking for NULL case for calling GET_FISCAL_CLASSIFICATION
    END IF;
  END IF;

  IF l_classification_category  = 'PARTY_FISCAL_CLASS'
     AND l_fsc_rec.fsc_code = FND_API.G_MISS_CHAR THEN

    l_fsc_rec.fsc_code := FND_API.G_MISS_CHAR||FND_API.G_MISS_CHAR;

    IF l_third_party_flag = 'Y' THEN
      p_trx_alphanumeric_value := l_fsc_rec.fsc_code;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                       'fsc_code: ' || p_trx_alphanumeric_value);
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc.END',
                       'ZX_TDS_RULE_BASE_DETM_PVT: get_fc(-)' ||
                       ', p_return_status = ' || p_return_status ||
                       ', p_error_buffer  = ' || p_error_buffer);
      END IF;
      RETURN;
    END IF;

    IF l_first_party_flag THEN
      IF l_hq_estb_flag = 'Y' THEN
        l_parameter_code := 'LEGAL_ENTITY_ID';
        l_le_flag := 'Y';
      ELSE
        l_parameter_code := 'HQ_ESTB_PARTY_TAX_PROF_ID';
      END IF;
    ELSE
      l_parameter_code  := p_Determining_Factor_Cq_Code || '_' || 'TAX_PROF_ID';
    END IF;

    --
    -- get transaction value from TSRM
    --
    get_tsrm_num_value(
      p_structure_name,
      p_structure_index,
      l_parameter_code,
      l_classified_entity_id,
      p_return_status,
      p_error_buffer );

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'Incorrect return_status after calling  get_tsrm_num_value' ||
                     ', return_status: ' || p_return_status);
      END IF;

      RETURN;
    END IF;

    IF l_classified_entity_id IS NULL AND NOT l_first_party_flag THEN
      p_trx_alphanumeric_value := NULL;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                       'fsc_code: ' || p_trx_alphanumeric_value);
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc.END',
                       'ZX_TDS_RULE_BASE_DETM_PVT: get_fc(-)' ||
                       ', p_return_status = ' || p_return_status ||
                       ', p_error_buffer  = ' || p_error_buffer);
      END IF;
      RETURN;
    END IF;

    IF l_le_flag = 'Y' THEN

      l_le_id := l_classified_entity_id;

      OPEN c_get_le_ptp_id(l_le_id);
      FETCH c_get_le_ptp_id INTO l_classified_entity_id;

      IF c_get_le_ptp_id%NOTFOUND THEN
        CLOSE c_get_le_ptp_id;
        p_trx_alphanumeric_value := NULL;
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'Legal Entity PTP Not Found; l_le_id' ||
                      to_char(l_le_id));
        END IF;
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc.END',
                       'ZX_TDS_RULE_BASE_DETM_PVT: get_fc(-)');
        END IF;
        RETURN;
      ELSE
        CLOSE c_get_le_ptp_id;
      END IF;

    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'classified_entity_id: ' || to_char(l_classified_entity_id));
    END IF;

    --
    -- check if can get fsc code from the cache
    --
    get_fsc_code(
             l_found,
             p_tax_regime_code,
             l_classification_category,
             l_classification_type,
             p_tax_determine_date,
             l_classified_entity_id,
             l_item_org_id,
             p_event_class_rec.application_id,
             p_event_class_rec.event_class_code,
             p_trx_alphanumeric_value);

    IF NOT l_found THEN

      l_fsc_rec.classified_entity_id    := l_classified_entity_id;

      ZX_TCM_CONTROL_PKG.GET_FISCAL_CLASSIFICATION(
        l_fsc_rec,
        p_return_status);

      IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
        NULL;
      ELSE
        l_fsc_rec.fsc_code := NULL;
        p_return_status := FND_API.G_RET_STS_SUCCESS;
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                 'ignore error even if fc not found for LE' );
        END IF;
      END IF;
      p_trx_alphanumeric_value := l_fsc_rec.fsc_code;
      j := OPTIMAL_FSC_TBL_LOCATION();
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(j) := l_fsc_rec;

    END IF; -- End for l_found check

    -- Bugfix 4873457 - Fetch fc for LE if not found for HQ Estb when classification
    --                  type is 'PARTY_FISCAL_CLASS' and CQ level is PARTY
    IF (l_first_party_flag AND l_fsc_rec.fsc_code  = 'PARTY_FISCAL_CLASS' and l_le_flag = 'N') THEN -- Get LE FC

      l_parameter_code := 'LEGAL_ENTITY_ID';

      --
      -- get transaction value from TSRM
      --
      get_tsrm_num_value(
        p_structure_name,
        p_structure_index,
        l_parameter_code,
        l_classified_entity_id,
        p_return_status,
        p_error_buffer );

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                       'Incorrect return_status after calling  get_tsrm_num_value for LE' ||
                       ', return_status: ' || p_return_status);
        END IF;

        RETURN;
      END IF;

      l_le_id := l_classified_entity_id;

      OPEN c_get_le_ptp_id(l_le_id);
      FETCH c_get_le_ptp_id INTO l_classified_entity_id;

      IF c_get_le_ptp_id%NOTFOUND THEN
        CLOSE c_get_le_ptp_id;
        p_trx_alphanumeric_value := NULL;
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                     'Legal Entity PTP Not Found; l_le_id' ||
                      to_char(l_le_id));
        END IF;
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc.END',
                       'ZX_TDS_RULE_BASE_DETM_PVT: get_fc(-)');
        END IF;
        RETURN;
      ELSE
        CLOSE c_get_le_ptp_id;
      END IF;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                       'classified_entity_id ' || to_char(l_classified_entity_id));
      END IF;

      --
      -- check if can get LE fsc code from the cache
      --
      get_fsc_code(
             l_found,
             p_tax_regime_code,
             l_classification_category,
             l_classification_type,
             p_tax_determine_date,
             l_classified_entity_id,
             l_item_org_id,
             p_event_class_rec.application_id,
             p_event_class_rec.event_class_code,
             p_trx_alphanumeric_value);

      IF NOT l_found THEN

        l_fsc_rec.classified_entity_id    := l_classified_entity_id;

        ZX_TCM_CONTROL_PKG.GET_FISCAL_CLASSIFICATION(
          l_fsc_rec,
          p_return_status);

        IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
          NULL;
        ELSE
          l_fsc_rec.fsc_code := FND_API.G_MISS_CHAR||FND_API.G_MISS_CHAR;
          p_return_status := FND_API.G_RET_STS_SUCCESS;
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                   'ignore error even if fc not found for LE' );
          END IF;
        END IF;
        p_trx_alphanumeric_value := l_fsc_rec.fsc_code;
        j := OPTIMAL_FSC_TBL_LOCATION();
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(j) := l_fsc_rec;

      END IF; -- End for internal l_found check

    END IF; -- End for getting LE FC

    --IF l_fsc_rec.fsc_code = FND_API.G_MISS_CHAR THEN
    --  p_trx_alphanumeric_value := NULL;
    --END IF;
    IF p_trx_alphanumeric_value IS NULL OR p_trx_alphanumeric_value = FND_API.G_MISS_CHAR THEN
      p_trx_alphanumeric_value := FND_API.G_MISS_CHAR||FND_API.G_MISS_CHAR;
    END IF;


  END IF; -- End of check for party classification

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                   'fsc_code: ' || p_trx_alphanumeric_value);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_fc(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fc',
                      p_error_buffer);
    END IF;

END get_fc;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_geography_info
--
--  DESCRIPTION
--
--  The procedure is to get zone corresponding to a location by calling
--  TCM API
--
PROCEDURE get_geography_info(
            p_structure_name        IN  VARCHAR2,
            p_structure_index       IN  BINARY_INTEGER,
            p_condition_index       IN  BINARY_INTEGER,
            p_zone_tbl              OUT NOCOPY HZ_GEO_GET_PUB.zone_tbl_type,
            p_Determining_Factor_Cq_Code IN ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_tax_determine_date    IN ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_return_status            OUT NOCOPY VARCHAR2,
            p_error_buffer             OUT NOCOPY VARCHAR2)
IS
  l_location_id            NUMBER;
  --l_zone_id                NUMBER;
  --l_zone_name              VARCHAR2(360);
  l_msg_count              NUMBER;
  i                        BINARY_INTEGER;
  l_location_type          VARCHAR2(30);
  --l_zone_tbl               HZ_GEO_GET_PUB.zone_tbl_type;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_geography_info.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_geography_info(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  i := p_condition_index;

  -- Bug#4720542
  IF SUBSTR(p_Determining_Factor_Cq_Code, -5, 5) = 'PARTY' THEN
    l_location_type :=  replace(p_Determining_Factor_Cq_Code,
                                '_PARTY', NULL);
  ELSIF SUBSTR(p_Determining_Factor_Cq_Code, -4, 4) = 'SITE' THEN
    l_location_type :=  replace(p_Determining_Factor_Cq_Code,
                                '_SITE', NULL);
  ELSE  --Added else part as part of Bug # 5009256
    l_location_type :=  p_Determining_Factor_Cq_Code;
  END IF;

  -- Bug# 4722936- truncate p_Determining_Factor_Cq_Code before use
  get_tsrm_num_value(
            p_structure_name,
            p_structure_index,
            l_location_type || '_' || 'LOCATION_ID',
            l_location_id,
            p_return_status,
            p_error_buffer);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_geography_info',
                   'location_id: ' || to_char(l_location_id));
  END IF;

  IF p_return_status =  FND_API.G_RET_STS_SUCCESS THEN

    /*ZX_TCM_GEO_JUR_PKG.get_zone(
                l_location_id,
                p_Determining_Factor_Cq_Code,
                g_determining_factor_code_tbl(i),
                p_tax_determine_date,
                l_zone_id,
                p_trx_alphanumeric_value,
                l_zone_name,
                p_return_status); */
  IF l_location_id IS NOT NULL THEN

    ZX_TCM_GEO_JUR_PKG.get_zone
    ( l_location_id,
      -- p_Determining_Factor_Cq_Code,
      l_location_type,
      g_determining_factor_code_tbl(i),
     p_tax_determine_date,
     p_zone_tbl,
     p_return_status);
 --    p_trx_alphanumeric_value := l_zone_tbl(1).zone_code;
     IF p_zone_tbl.COUNT = 0 THEN
       --location infirmation is entered but no tax zone is derived for this.
       p_zone_tbl(1).zone_id := -99;
       p_zone_tbl(1).zone_type := null;
       p_zone_tbl(1).zone_code := null;
       p_zone_tbl(1).zone_name := null;
     END IF;
  END IF;
   END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    --  FND_LOG.STRING(g_level_procedure,
    --                'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_geography_info',
    --               'trx_alphanumeric_value: ' || p_trx_alphanumeric_value);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_geography_info.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_geography_info(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_geography_info',
                      p_error_buffer);
    END IF;

END get_geography_info;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_master_geography_info
--
--  DESCRIPTION
--
--  The procedure is to get master geography information  corresponding
--  to a location by calling TCM API
--
PROCEDURE get_master_geography_info(
            p_structure_name        IN  VARCHAR2,
            p_structure_index       IN  BINARY_INTEGER,
            p_condition_index       IN  BINARY_INTEGER,
            p_trx_numeric_value  OUT NOCOPY ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_Determining_Factor_Cq_Code IN ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_return_status            OUT NOCOPY VARCHAR2,
            p_error_buffer             OUT NOCOPY VARCHAR2)
IS
  l_location_id            NUMBER;
  l_geography_id           NUMBER;
  l_geography_code         VARCHAR2(30);
  l_geography_name         VARCHAR2(360);
  l_location_type          VARCHAR2(30);
  l_msg_count              NUMBER;
  i                        BINARY_INTEGER;
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_master_geography_info.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_master_geography_info(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  i := p_condition_index;

  -- Bug#4720542
  IF SUBSTR(p_Determining_Factor_Cq_Code, -5, 5) = 'PARTY' THEN
    l_location_type :=  replace(p_Determining_Factor_Cq_Code,
                                '_PARTY', NULL);
  ELSIF SUBSTR(p_Determining_Factor_Cq_Code, -4, 4) = 'SITE' THEN
    l_location_type :=  replace(p_Determining_Factor_Cq_Code,
                                '_SITE', NULL);
  ELSE  --Added else part as part of Bug # 5009256
    l_location_type :=  p_Determining_Factor_Cq_Code;
  END IF;

  -- Bug# 4722936- truncate p_Determining_Factor_Cq_Code before use
  get_tsrm_num_value(
            p_structure_name,
            p_structure_index,
            l_location_type || '_' || 'LOCATION_ID',
            l_location_id,
            p_return_status,
            p_error_buffer);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_master_geography_info',
                   'location_id: ' || to_char(l_location_id));
  END IF;

  IF p_return_status =  FND_API.G_RET_STS_SUCCESS THEN

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_master_geography_info',
                     'l_location_type: ' || l_location_type);
    END IF;

    -- Bugfix 4926074: call get_master_geography API only if the location_id is not null
    if l_location_id is not null then
         ZX_TCM_GEO_JUR_PKG.get_master_geography
            (l_location_id,
             l_location_type,
             g_determining_factor_code_tbl(i),
             l_geography_id,
             l_geography_code,
             l_geography_name,
             p_return_status);

        IF p_return_status  =  FND_API.G_RET_STS_SUCCESS THEN
          p_trx_numeric_value := l_geography_id;
        END IF;
    end if; -- l_location_id is not null
   END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_master_geography_info',
                   'trx_numeric_value: ' || TO_CHAR(p_trx_numeric_value));
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_master_geography_info.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_master_geography_info(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_master_geography_info',
                      p_error_buffer);
    END IF;

END get_master_geography_info;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_registration_status
--
--  DESCRIPTION
--
--  The procedure gets registration status by calling TCM API
--
PROCEDURE get_registration_status(
            p_structure_name         IN     VARCHAR2,
            p_structure_index        IN     BINARY_INTEGER,
            p_event_class_rec        IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_determine_date     IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_tax                    IN     ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code        IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_trx_alphanumeric_value    OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_Determining_Factor_Cq_Code  IN ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2)
IS
  l_registration_rec       zx_tcm_control_pkg.zx_registration_info_rec;
  l_first_party_flag       BOOLEAN;
  l_reg_party_prof_id      zx_party_tax_profile.party_tax_profile_id%TYPE;
  l_hq_estb_ptp_id         zx_lines.hq_estb_party_tax_prof_id%TYPE;
  l_ret_record_level       VARCHAR2(30);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_registration_status.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_registration_status(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info(
            p_structure_name      => p_structure_name,
            p_structure_index     => p_structure_index,
            p_event_class_rec     => p_event_class_rec,
            p_tax_regime_code     => p_tax_regime_code,
            p_tax                 => p_tax,
            p_tax_determine_date  => p_tax_determine_date,
            p_jurisdiction_code   => NULL,
            p_reg_party_type      => p_Determining_Factor_Cq_Code,
            x_registration_rec    => l_registration_rec,
            x_return_status       => p_return_status
  );

  IF p_return_status = FND_API.G_RET_STS_SUCCESS  THEN
      --Bug 9954561
      --p_trx_alphanumeric_value := NVL(l_registration_rec.registration_status_code, 'NOT REGISTERED');
      p_trx_alphanumeric_value := NVL(l_registration_rec.registration_status_code, FND_API.G_MISS_CHAR);
  ELSE
    IF (g_level_error >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_registration_status',
                     'Incorrect status returned after calling '||
                     'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_registration_info'||
                     ', p_return_status = ' || p_return_status);
      FND_LOG.STRING(g_level_error,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_registration_status.END',
                     'ZX_TDS_RULE_BASE_DETM_PVT: get_registration_status(-)');
    END IF;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_registration_status',
                   'registration status: ' || p_trx_alphanumeric_value);
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_registration_status.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_registration_status(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_registration_status',
                      p_error_buffer);
    END IF;

END get_registration_status;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_account_flexfield_info
--
--  DESCRIPTION
--
--  The procedure gets accounting  flexfield information either from  account
--  string or account CCID
--
PROCEDURE get_account_flexfield_info(
            p_structure_name         IN  VARCHAR2,
            p_structure_index        IN  BINARY_INTEGER,
            p_condition_index        IN     BINARY_INTEGER,
            p_trx_alphanumeric_value    OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_chart_of_accounts_id   IN
                ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
            p_sob_id                 IN
                ZX_CONDITION_GROUPS_B.LEDGER_ID%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2)
IS
  i                            BINARY_INTEGER;
  l_account_string             VARCHAR2(2000);
  l_ccid                       NUMBER;
  l_num_segments               NUMBER;
  l_tax_parameter_code         ZX_PARAMETERS_B.TAX_PARAMETER_CODE%TYPE;
  l_sob_id                     ZX_CONDITION_GROUPS_B.LEDGER_ID%TYPE;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_flexfield_info.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_account_flexfield_info(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_flexfield_info',
                   'sob id: ' || to_char(p_sob_id) ||
                   ', chart of acct id: ' || to_char(p_chart_of_accounts_id));
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- check if this is the correct set of books id
  -- get sob id from the transaction
  --
  l_tax_parameter_code := 'LEDGER_ID';
  get_tsrm_num_value(p_structure_name,
                     p_structure_index,
                     l_tax_parameter_code,
                     l_sob_id,
                     p_return_status,
                     p_error_buffer);

  --
  -- compare sob_id from the transaction with sob_id from the
  -- condition group, error if they don't match
  --
  IF l_sob_id <> p_sob_id THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    p_error_buffer := 'LEDGER ID does not match with one from condition group';

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_flexfield_info',
                     'p_return_status = ' || p_return_status ||
                     ', p_error_buffer  = ' || p_error_buffer);
    END IF;

    RETURN;
  END IF;

  i := p_condition_index;

  --
  -- check if need to obtain segment array for this account
  --
  IF ((g_determining_factor_code_tbl.EXISTS(i-1)  AND
       g_determining_factor_cq_tbl.EXISTS(i-1) )      AND
      (g_determining_factor_code_tbl(i) = g_determining_factor_code_tbl(i-1) AND
       g_determining_factor_cq_tbl(i) IS NOT NULL AND g_determining_factor_cq_tbl(i-1) IS NOT NULL)) THEN
    --
    -- segment array for this account has been obtained before
    --
    IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_flexfield_info',
                      'segment array has been obtained before');
    END IF;

    RETURN;
  END IF;
  --
  -- first get accounting info from account string
  --
  -- bug#5014051: replace g_determining_factor_code_tbl with
  -- g_tax_parameter_code_tbl
  --
  get_account_alphanum_value(p_structure_name,
                             p_structure_index,
                             g_tax_parameter_code_tbl(i) || '_' || 'STRING',
                             l_account_string,
                             p_return_status,
                             p_error_buffer );
  IF (p_return_status = FND_API.G_RET_STS_SUCCESS AND
      l_account_string IS NULL) THEN
    --
    -- account string is not available, get the info from account ccid
    --
    -- bug#5014051: replace g_determining_factor_code_tbl with
    -- g_tax_parameter_code_tbl
    --
    get_account_num_value(p_structure_name,
                          p_structure_index,
                          g_tax_parameter_code_tbl(i) || '_' || 'CCID',
                          l_ccid,
                          p_return_status,
                          p_error_buffer );
    IF (p_return_status = FND_API.G_RET_STS_SUCCESS AND
        l_ccid IS NOT NULL ) THEN
     IF l_ccid > 0 THEN
      IF zx_global_structures_pkg.g_ccid_acct_string_info_tbl.exists(l_ccid) then

            l_account_string :=
                zx_global_structures_pkg.g_ccid_acct_string_info_tbl(l_ccid).ACCOUNT_STRING;

            IF (g_level_statement >= g_current_runtime_level ) THEN
                     FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_flexfield_info',
                       'Acct string found in cache: ' || l_account_string);
            END IF;

      ELSE
            l_account_string := FND_FLEX_EXT.get_segs(
                                'SQLGL',
                                'GL#',
                                p_chart_of_accounts_id,
                                l_ccid);

            IF (g_level_statement >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_flexfield_info',
                       'acct string derived by calling flexfield API: ' || l_account_string);
            END IF;

            zx_global_structures_pkg.g_ccid_acct_string_info_tbl(l_ccid).CCID := l_ccid;
            zx_global_structures_pkg.g_ccid_acct_string_info_tbl(l_ccid).ACCOUNT_STRING := l_account_string;
            zx_global_structures_pkg.g_ccid_acct_string_info_tbl(l_ccid).CHART_OF_ACCOUNTS_ID := p_chart_of_accounts_id;


      END IF;

      IF l_account_string IS NULL THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_error_buffer := 'Error when derive Account String';
      END IF;
     END IF;
    ELSIF (p_return_status = FND_API.G_RET_STS_SUCCESS AND
           l_ccid IS NULL ) THEN
      --
      -- return success but put message in error buffer
      -- to see in log file
      --
      p_return_status := FND_API.G_RET_STS_SUCCESS;
      p_error_buffer  := 'Both Account String and CCID are NULL';
      RETURN;
    END IF;
  END IF;

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_flexfield_info',
                     'p_return_status = ' || p_return_status ||
                     ', p_error_buffer  = ' || p_error_buffer);
    END IF;

    RETURN;
  END IF;

  IF g_determining_factor_cq_tbl(i) IS NULL  THEN
    p_trx_alphanumeric_value := l_account_string;
    RETURN;
  ELSE
    -- get all segments for this account flexfield
    IF l_account_string IS NULL THEN
      p_trx_alphanumeric_value := NULL;
    ELSE
     process_segment_string(l_account_string,
                           p_chart_of_accounts_id,
                           p_return_status,
                           p_error_buffer);
    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_flexfield_info.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_account_flexfield_info(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_account_flexfield_info',
                      p_error_buffer);
    END IF;

END get_account_flexfield_info;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  process_segment_string
--
--  DESCRIPTION
--
--  The procedure gets all segments of an account flexfield
--
PROCEDURE process_segment_string(
            p_account_string         IN     VARCHAR2,
            p_chart_of_accounts_id   IN
                ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2)
IS
  l_delimiter            VARCHAR2(1);
  l_num_of_segments      NUMBER;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_segment_string.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: process_segment_string(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- init accounting segment array
  --
  g_segment_array.DELETE;

  l_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                             'SQLGL',
                             'GL#',
                             p_chart_of_accounts_id);

  l_num_of_segments := FND_FLEX_EXT.breakup_segments(
                           p_account_string,
                           l_delimiter,
                           g_segment_array);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_segment_string',
                   'l_delimiter: ' || l_delimiter ||
                   ', l_num_of_segments: ' || to_char(l_num_of_segments));

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_segment_string.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: process_segment_string(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.process_segment_string',
                      p_error_buffer);
    END IF;

END process_segment_string;


/* Bugfix 3673395 - This procedure is no longer requird
-----------------------------------------------------------------------

--  PRIVATE PROCEDURE
--  get_product_tax_info
--
--  DESCRIPTION
--    This procedure returns the tax info for a specific item
--

PROCEDURE get_product_tax_info(
            p_structure_name          IN  VARCHAR2,
            p_structure_index         IN  BINARY_INTEGER,
            p_determining_factor_code IN  ZX_CONDITIONS.DETERMINING_FACTOR_CODE%TYPE,
            p_trx_alphanumeric_value  OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2)

IS
  l_parameter_code                  ZX_PARAMETERS_B.TAX_PARAMETER_CODE%TYPE;
  l_product_id                      NUMBER;
  l_item_org_id                     NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_product_tax_info.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_product_tax_info (+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- get product id from tsrm
  --
  l_parameter_code := 'PRODUCT_ID';
  get_tsrm_num_value(
      p_structure_name,
      p_structure_index,
      l_parameter_code,
      l_product_id,
      p_return_status,
      p_error_buffer );

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_product_tax_info',
                   'product id: ' || to_char(l_product_id));
  END IF;

  IF p_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- get product org id from tsrm
  --
  l_parameter_code := 'PRODUCT_ORG_ID';
    get_tsrm_num_value(
      p_structure_name,
      p_structure_index,
      l_parameter_code,
      l_item_org_id,
      p_return_status,
      p_error_buffer );

  IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_product_tax_info',
                     'item_org_id: ' || to_char(l_item_org_id));
  END IF;

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- get taxable_flag or tax_code from mtl_system_items
  --
  get_tax_info_from_item(l_product_id,
                         l_item_org_id,
                         p_determining_factor_code,
                         p_trx_alphanumeric_value,
                         p_return_status,
                         p_error_buffer );


  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_product_tax_info.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_product_tax_info (-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_product_tax_info',
                      p_error_buffer);
    END IF;

END get_product_tax_info;
*/

/* Bugfix 3673395 - This procedure is no longer required
-----------------------------------------------------------------------

--  PRIVATE PROCEDURE
--  get_tax_info_from_item
--
--  DESCRIPTION
--    This procedure returns taxable_flag or tax_code   obtained from
--    mtl_system_items table depending on the determining factor code passed in
--

PROCEDURE get_tax_info_from_item(
            p_product_id              IN  MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE,
            p_item_org_id             IN  MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE,
            p_determining_factor_code IN  ZX_CONDITIONS.DETERMINING_FACTOR_CODE%TYPE,
            p_trx_alphanumeric_value  OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2)

IS
  CURSOR get_tax_code_csr
    (c_product_id           MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE,
     c_item_org_id          MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE)
  IS
    SELECT  TAX_CODE
      FROM  MTL_SYSTEM_ITEMS
      WHERE INVENTORY_ITEM_ID = c_product_id    AND
            ORGANIZATION_ID   = c_item_org_id;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tax_info_from_item.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_tax_info_from_item(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_determining_factor_code = 'TAX_CLASSIFICATION_CODE' THEN
    OPEN get_tax_code_csr(p_product_id,
                          p_item_org_id);
    FETCH get_tax_code_csr INTO p_trx_alphanumeric_value;
    CLOSE get_tax_code_csr;
  ELSE
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'Invalid Determining Factor code for Product class';
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tax_info_from_item',
                   'trx value:' || p_trx_alphanumeric_value);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tax_info_from_item.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_tax_info_from_item(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_tax_info_from_item',
                        p_error_buffer);
      END IF;

END get_tax_info_from_item;
*/

/* Bugfix 3673395 - This procedure is no longer required
-----------------------------------------------------------------------

--  PRIVATE PROCEDURE
--  get_party_tax_info
--
--  DESCRIPTION
--    This procedure returns the tax classification code  obtained from
--    zx_party_tax_profile

PROCEDURE get_party_tax_info(
            p_structure_name          IN  VARCHAR2,
            p_structure_index         IN  BINARY_INTEGER,
            p_Determining_Factor_Cq_Code   IN ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_determining_factor_code IN  ZX_CONDITIONS.DETERMINING_FACTOR_CODE%TYPE,
            p_trx_alphanumeric_value  OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2)

IS
  l_tax_profile_id             ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE;

  CURSOR get_tax_classification_csr
    (c_party_tax_profile_id      ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE)
  IS
    SELECT Tax_Classification_Code
      FROM ZX_PARTY_TAX_PROFILE
      WHERE PARTY_TAX_PROFILE_ID = c_party_tax_profile_id;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_party_tax_info.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_party_tax_info(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  get_tsrm_num_value(
            p_structure_name,
            p_structure_index,
            p_Determining_Factor_Cq_Code || '_' || 'TAX_PROF_ID',
            l_tax_profile_id,
            p_return_status,
            p_error_buffer);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_party_tax_info',
                   'l_tax_profile_id: ' || to_char(l_tax_profile_id));
  END IF;

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  IF p_determining_factor_code = 'ESTB_TAX_CLASSIFICATION'  THEN
    OPEN  get_tax_classification_csr(l_tax_profile_id);
    FETCH get_tax_classification_csr INTO p_trx_alphanumeric_value;
    CLOSE get_tax_classification_csr;
  ELSE
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'Invalid Determining Factor code for Party class';
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_party_tax_info',
                   'tax classification: ' || p_trx_alphanumeric_value);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_party_tax_info.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_party_tax_info(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  :=sqlcode || ': ' ||  SUBSTR(SQLERRM, 1, 80);

      CLOSE get_tax_classification_csr;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.',
                        p_error_buffer);
      END IF;
END get_party_tax_info;
*/

---------------------------------------------------------------------------

--  PRIVATE FUNCTION
--  evaluate_condition
--
--  DESCRIPTION
--
--  The procedure is to evaluate each condition
--

PROCEDURE evaluate_condition(
            p_condition_index        IN     BINARY_INTEGER,
            p_trx_alphanumeric_value IN     ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_trx_numeric_value      IN     ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_trx_date_value         IN     ZX_CONDITIONS.DATE_VALUE%TYPE,
            p_chart_of_accounts_id   IN     ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE,
            p_result                    OUT NOCOPY BOOLEAN,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2)
IS
  i                      BINARY_INTEGER;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_condition.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: evaluate_condition(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  i    := p_condition_index;

  IF g_data_type_tbl(i) = 'ALPHANUMERIC' THEN
    p_result := evaluate_alphanum_condition(
                     g_operator_tbl(i),
                     g_alphanum_value_tbl(i),
                     p_trx_alphanumeric_value,
                     g_value_low_tbl(i),
                     g_value_high_tbl(i),
                     g_determining_factor_class_tbl(i),
                     p_chart_of_accounts_id);

  ELSIF g_data_type_tbl(i) = 'NUMERIC' THEN
     p_result := evaluate_numeric_condition(
                     g_operator_tbl(i),
                     g_numeric_value_tbl(i),
                     p_trx_numeric_value);

  ELSIF g_data_type_tbl(i) = 'DATE' THEN
    p_result := evaluate_date_condition(
                     g_operator_tbl(i),
                     g_date_value_tbl(i),
                     p_trx_date_value);

  ELSE
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'Invalid data type';
    p_result        := FALSE;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_condition',
                   'Invalid data type');
    END IF;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_condition.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: evaluate_condition(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_condition',
                      p_error_buffer);
    END IF;

END evaluate_condition;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_result
--
--  DESCRIPTION
--
--  The procedure gets the result from ZX_PROCESS_RESULTS table.
--  p_found being true will indicate if a result is found.
--

PROCEDURE get_result(
           p_result_id           IN     ZX_PROCESS_RESULTS.RESULT_ID%TYPE,
           p_structure_name      IN     VARCHAR2,
           p_structure_index     IN     BINARY_INTEGER,
           p_tax_regime_code     IN     ZX_RATES_B.tax_regime_Code%TYPE,
           p_tax                 IN     ZX_RATES_B.tax%TYPE,
           p_tax_determine_date  IN     DATE,
           p_found              OUT NOCOPY BOOLEAN,
           p_zx_result_rec          OUT NOCOPY ZX_PROCESS_RESULTS%ROWTYPE,
           p_return_status          OUT NOCOPY VARCHAR2,
           p_error_buffer           OUT NOCOPY VARCHAR2)

IS
  --
  -- cursor for get result at tax regime level for tax rate determination
  --
  CURSOR  get_tax_result_csr
  IS
   SELECT  RESULT_ID,
           CONDITION_GROUP_CODE,
           TAX_STATUS_CODE,
           LEGAL_MESSAGE_CODE,
           MIN_TAX_AMT,
           MAX_TAX_AMT,
           MIN_TAXABLE_BASIS,
           MAX_TAXABLE_BASIS,
           MIN_TAX_RATE,
           MAX_TAX_RATE,
           Allow_Exemptions_Flag,
           Allow_Exceptions_Flag,
           Result_Type_Code,
           NUMERIC_RESULT,
           ALPHANUMERIC_RESULT,
           STATUS_RESULT,
           RATE_RESULT,
           RESULT_API,
           CONDITION_GROUP_ID,
           CONDITION_SET_ID,
           EXCEPTION_SET_ID,
           TAX_RULE_ID
   FROM    ZX_PROCESS_RESULTS
   WHERE   RESULT_ID = p_result_id;

   CURSOR  select_tax_status_rate_code
   (c_tax_regime_code VARCHAR2,
    c_tax             VARCHAR2,
    c_tax_Rate_Code   VARCHAR2,
    c_tax_date        VARCHAR2)
   is
   SELECT  TAX_STATUS_CODE,
           TAX_RATE_CODE
   FROM    ZX_SCO_RATES_B_V
   WHERE   TAX_REGIME_CODE = c_tax_Regime_Code
   AND     TAX = c_tax
   AND     TAX_RATE_CODE = c_tax_rate_code
   AND     (TAX_CLASS = 'OUTPUT' OR TAX_CLASS IS NULL)
   --AND  default_flg_effective_from <= c_tax_date
   AND     effective_from <= c_tax_date
   AND (default_flg_effective_to >= c_tax_date
           OR default_flg_effective_to IS NULL)
   --AND NVL(Default_Rate_Flag, 'N') = 'Y'
   AND NVL(Active_Flag, 'N') = 'Y'
   ORDER BY tax_class NULLS LAST, subscription_level_code;   -- Bug#5395227


   l_condition_set_result BOOLEAN;
   l_exception_set_result BOOLEAN;
   l_zx_result_rec_null ZX_PROCESS_RESULTS%ROWTYPE;
   l_action_rec_tbl     ZX_TDS_PROCESS_CEC_PVT.action_rec_tbl_type;
   l_tax_status_Code    ZX_RATES_B.tax_status_code%type;
   l_tax_rate_Code      ZX_RATES_B.tax_rate_Code%type;
   l_override_tax_rate_Code ZX_RATES_B.tax_rate_code%TYPE;
   l_service_type_code ZX_RULES_B.service_type_code%TYPE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_result.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_result(+)');
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_result',
                   'result_id: ' || p_result_id);
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  l_condition_set_result := FALSE;
  l_exception_set_result := FALSE;

  --
  --  result for tax
  --
  OPEN get_tax_result_csr;

  FETCH get_tax_result_csr INTO
          p_zx_result_rec.result_id,
          p_zx_result_rec.condition_group_code,
          p_zx_result_rec.tax_status_code,
          p_zx_result_rec.legal_message_code,
          p_zx_result_rec.min_tax_amt,
          p_zx_result_rec.max_tax_amt,
          p_zx_result_rec.min_taxable_basis,
          p_zx_result_rec.max_taxable_basis,
          p_zx_result_rec.min_tax_rate,
          p_zx_result_rec.max_tax_rate,
          p_zx_result_rec.Allow_Exemptions_Flag,
          p_zx_result_rec.Allow_Exceptions_Flag,
          p_zx_result_rec.Result_Type_Code,
          p_zx_result_rec.numeric_result,
          p_zx_result_rec.alphanumeric_result,
          p_zx_result_rec.status_result,
          p_zx_result_rec.rate_result,
          p_zx_result_rec.result_api,
          p_zx_result_rec.condition_group_id,
          p_zx_result_rec.condition_set_id,
          p_zx_result_rec.exception_set_id,
          p_zx_result_rec.tax_rule_id;
  IF get_tax_result_csr%FOUND THEN
     p_found := true;
  END IF;

    select service_type_code into l_service_type_code
    FROM zx_rules_b
    where tax_rule_id = p_zx_result_rec.tax_rule_id;


  -- For Migrated Records, Check if Condition Set and Exception Set is populated
  -- and evaluate the result for them
  IF (p_found) AND (p_zx_result_rec.condition_set_id IS NOT NULL OR
                    p_zx_result_rec.exception_set_id IS NOT NULL) THEN

   init_cec_params (p_structure_name               => p_structure_name,
                    p_structure_index              => p_structure_index,
                    p_return_status                => p_return_status,
                    p_error_buffer                 => p_error_buffer);

   IF p_zx_result_rec.condition_set_id IS NOT NULL THEN
      ZX_TDS_PROCESS_CEC_PVT.evaluate_cec(
                    p_condition_set_id             => p_zx_result_rec.condition_set_id,
                    p_cec_ship_to_party_site_id    => g_cec_ship_to_party_site_id,
                    p_cec_bill_to_party_site_id    => g_cec_bill_to_party_site_id,
                    p_cec_ship_to_party_id         => g_cec_ship_to_party_id,
                    p_cec_bill_to_party_id         => g_cec_bill_to_party_id,
                    p_cec_poo_location_id          => g_cec_poo_location_id,
                    p_cec_poa_location_id          => g_cec_poa_location_id,
                    p_cec_trx_id                   => g_cec_trx_id,
                    p_cec_trx_line_id              => g_cec_trx_line_id,
                    p_cec_ledger_id                => g_cec_ledger_id,
                    p_cec_internal_organization_id => g_cec_internal_organization_id,
                    p_cec_so_organization_id       => g_cec_so_organization_id,
                    p_cec_product_org_id           => g_cec_product_org_id,
                    p_cec_product_id               => g_cec_product_id,
                    p_cec_trx_line_date            => g_cec_trx_line_date,
                    p_cec_trx_type_id              => g_cec_trx_type_id,
                    p_cec_fob_point                => g_cec_fob_point,
                    p_cec_ship_to_site_use_id      => g_cec_ship_to_site_use_id,
                    p_cec_bill_to_site_use_id      => g_cec_bill_to_site_use_id,
                    p_cec_result                   => l_condition_set_result,
                    p_action_rec_tbl               => l_action_rec_tbl,
                    p_return_status                => p_return_status,
                    p_error_buffer                 => p_error_buffer);
      p_found := l_condition_set_result;

      -- Bug 3976490
      -- every condition set must evaluate to either TRUE or FALSE. Based on this, the
      -- values in the p_action_rec_tbl will be action for True condition or False action.
      -- If condition set result evaluates to False, we still need to execute the
      -- actions setup under False Actions

         for i in 1.. nvl(l_action_rec_tbl.last,0) loop

           if upper(l_action_rec_tbl(i).action_code) in ('ERROR_MESSAGE','SYSTEM_ERROR') then
              p_return_status := FND_API.G_RET_STS_ERROR;

              -- Bug 8568734
              FND_MESSAGE.SET_NAME('ZX','ZX_CONSTRAINT_EVALUATION_ERROR');
              FND_MESSAGE.SET_TOKEN('CONDITION_GROUP',p_zx_result_rec.condition_group_code);
              FND_MESSAGE.SET_TOKEN('ACTION_CODE', l_action_rec_tbl(i).action_code );
              ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

              IF (g_level_error >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_error,
                               'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_result',
                               'Action_code is ERROR_MESSAGE,SYSTEM_ERROR');
              END IF;

              app_exception.raise_exception;
           elsif upper(l_action_rec_tbl(i).action_code) = 'DO_NOT_USE_THIS_TAX_CODE' then
              l_condition_set_result := FALSE;
              p_found := l_condition_set_result;
           elsif  upper(l_action_rec_tbl(i).action_code) in ('DEFAULT_TAX_CODE') then
           if (l_service_type_code <> 'DET_TAXABLE_BASIS' ) THEN
        /*     if upper(l_action_rec_tbl(i).action_code)= 'USE_THIS_TAX_CODE' then
---                 get_tsrm_num_value(p_structure_name,
--- Modified for bug # 6777632
               get_tsrm_alphanum_value(p_structure_name,
                     p_structure_index,
                     'OUTPUT_TAX_CLASSIFICATION_CODE',
                     l_override_tax_rate_code,
                     p_return_status,
                     p_error_buffer);
             IF upper(l_action_rec_tbl(i).action_code)= 'DEFAULT_TAX_CODE' then
         */
                  l_override_tax_rate_code := l_action_rec_tbl(i).action_value;
             --end if;

             -- Get the Tax regime, Tax, Status, Rate Code based on override_tax_rate_code
             -- and set it on the result_rec.

                 Open select_tax_status_rate_code (p_tax_regime_code, p_tax, l_override_tax_rate_code,
                                                   p_tax_determine_date);
                 fetch select_tax_status_rate_code into l_tax_status_code, l_tax_rate_code;

                 If select_tax_status_rate_code%NOTFOUND then
                    --A record does not exist with that tax rate code for the given tax.
                    --Raise error;

                    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                    p_error_buffer  := SUBSTR(SQLERRM, 1, 80);
                    IF (g_level_error >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_error,
                                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_result',
                                      'Cannot set the tax rate code to '||l_override_tax_rate_code ||
                                      ', ERROR: '|| p_error_buffer);
                    END IF;

                    IF select_tax_status_rate_code%isopen then
                         Close select_tax_status_rate_code;
                    END IF;
                    app_exception.raise_exception;
                 ELSE
                    p_zx_result_rec.rate_result := l_tax_rate_code;
                    p_zx_result_rec.status_result :=  l_tax_status_code;
                 End if;

                 Close select_tax_status_rate_code;
           end if; -- service type code
           end if;
      end loop;

   END IF;
   IF l_condition_set_result AND p_zx_result_rec.exception_set_id IS NOT NULL THEN

      l_action_rec_tbl.delete;

      ZX_TDS_PROCESS_CEC_PVT.evaluate_cec(
                    p_exception_set_id             => p_zx_result_rec.exception_set_id,
                    p_cec_ship_to_party_site_id    => g_cec_ship_to_party_site_id,
                    p_cec_bill_to_party_site_id    => g_cec_bill_to_party_site_id,
                    p_cec_ship_to_party_id         => g_cec_ship_to_party_id,
                    p_cec_bill_to_party_id         => g_cec_bill_to_party_id,
                    p_cec_poo_location_id          => g_cec_poo_location_id,
                    p_cec_poa_location_id          => g_cec_poa_location_id,
                    p_cec_trx_id                   => g_cec_trx_id,
                    p_cec_trx_line_id              => g_cec_trx_line_id,
                    p_cec_ledger_id                => g_cec_ledger_id,
                    p_cec_internal_organization_id => g_cec_internal_organization_id,
                    p_cec_so_organization_id       => g_cec_so_organization_id,
                    p_cec_product_org_id           => g_cec_product_org_id,
                    p_cec_product_id               => g_cec_product_id,
                    p_cec_trx_line_date            => g_cec_trx_line_date,
                    p_cec_trx_type_id              => g_cec_trx_type_id,
                    p_cec_fob_point                => g_cec_fob_point,
                    p_cec_ship_to_site_use_id      => g_cec_ship_to_site_use_id,
                    p_cec_bill_to_site_use_id      => g_cec_bill_to_site_use_id,
                    p_cec_result                   => l_exception_set_result,
                    p_action_rec_tbl               => l_action_rec_tbl,
                    p_return_status                => p_return_status,
                    p_error_buffer                 => p_error_buffer);

      p_found := l_exception_set_result;

      -- Bug 3976490
      -- every exception set must evaluate to either TRUE or FALSE. Based on this, the
      -- values in the p_action_rec_tbl will be action for True condition or False action.
      -- If condition set result evaluates to False, we still need to execute the
      -- actions setup under False Actions

         for i in 1.. nvl(l_action_rec_tbl.last,0) loop

           if upper(l_action_rec_tbl(i).action_code) in ('ERROR_MESSAGE','SYSTEM_ERROR') then
              p_return_status := FND_API.G_RET_STS_ERROR;

              -- Bug 8568734
              FND_MESSAGE.SET_NAME('ZX','ZX_CONSTRAINT_EVALUATION_ERROR');
              FND_MESSAGE.SET_TOKEN('CONDITION_GROUP',p_zx_result_rec.condition_group_code);
              FND_MESSAGE.SET_TOKEN('ACTION_CODE', l_action_rec_tbl(i).action_code );
              ZX_API_PUB.add_msg(ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);

              IF (g_level_error >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_error,
                               'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_result',
                               'Action_code is ERROR_MESSAGE,SYSTEM_ERROR');
              END IF;

              app_exception.raise_exception;
           elsif upper(l_action_rec_tbl(i).action_code) in  ('DO_NOT_USE_THIS_TAX_CODE',
                                                            'DO_NOT_USE_THIS_TAX_GROUP') then
              l_exception_set_result := FALSE;
              p_found := l_exception_set_result;

           elsif  upper(l_action_rec_tbl(i).action_code) in ('USE_TAX_CODE',
                                                              'DEFAULT_TAX_CODE') then
           if (l_service_type_code <> 'DET_TAXABLE_BASIS' ) THEN
           /*  if upper(l_action_rec_tbl(i).action_code)= 'USE_THIS_TAX_CODE' then
---                 get_tsrm_num_value(p_structure_name,
--- Modified for bug # 6777632
             get_tsrm_alphanum_value(p_structure_name,
                     p_structure_index,
                     'OUTPUT_TAX_CLASSIFICATION_CODE',
                     l_override_tax_rate_code,
                     p_return_status,
                     p_error_buffer);
            */
             --if upper(l_action_rec_tbl(i).action_code)in ('DEFAULT_TAX_CODE','USE_TAX_CODE') then
                  l_override_tax_rate_code := l_action_rec_tbl(i).action_value;

             -- Get the Tax regime, Tax, Status, Rate Code based on override_tax_rate_code
             -- and set it on the result_rec.

                 Open select_tax_status_rate_code (p_tax_regime_code, p_tax, l_override_tax_rate_code,
                                                   p_tax_determine_date);
                 fetch select_tax_status_rate_code into l_tax_status_code, l_tax_rate_code;

                 If select_tax_status_rate_code%NOTFOUND then
                    --A record does not exist with that tax rate code for the given tax.
                    --Raise error;

                    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                    p_error_buffer  := SUBSTR(SQLERRM, 1, 80);
                    IF (g_level_error >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_error,
                                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_result',
                                      'Cannot set the tax rate code to '||l_override_tax_rate_code ||
                                      ', ERROR: '||p_error_buffer);
                    END IF;
                    IF select_tax_status_rate_code%isopen then
                         Close select_tax_status_rate_code;
                    END IF;
                    app_exception.raise_exception;
                 ELSE
                    p_zx_result_rec.rate_result := l_tax_rate_code;
                    p_zx_result_rec.status_result :=  l_tax_status_code;
                 End if;

                 Close select_tax_status_rate_code;
           --end if;
         end if;

           elsif upper(l_action_rec_tbl(i).action_code)= 'DO_NOT_APPLY_EXCEPTION' then
             -- bug 6840036- set p_found to TRUE for all
             -- service type codes except DET_TAX_RATE
                 --NULL;
             IF (l_service_type_code <> 'DET_TAX_RATE' ) THEN
               p_found := TRUE;
             END IF;

           elsif upper(l_action_rec_tbl(i).action_code) = 'APPLY_EXCEPTION' then
                -- populate the numeric result column of the result rec.
                -- This rate will be used during Tax Rate Determination process
                -- The Rate determination process will check if the rate is ad-hoc and
                -- accordingly honour this rate or raise exception.

               Begin
                p_zx_result_rec.numeric_result := l_action_rec_tbl(i).action_value;
               exception
                when others then
                    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
                    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','The action value for APPLY_EXCEPTION action code'||
                        'does not contain number');
                    FND_MSG_PUB.Add;
                    IF (g_level_error >= g_current_runtime_level ) THEN
                      FND_LOG.STRING(g_level_error,
                                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_result',
                                     'The action value for APPLY_EXCEPTION action code '||
                                     'does not contain number');
                    END IF;
                    app_exception.raise_exception;
               end;
        end if;
      end loop;
   END IF;
   -- If Condition Set or Exception Set evaluates to FALSE, then
   -- remove record in Process Result Structure.
   IF not p_found THEN
      p_zx_result_rec := l_zx_result_rec_null;
   END IF;
  END IF;     /* of Migrated Records check for Condition Set and Evaluation Set */

  CLOSE get_tax_result_csr;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_result.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_result(-)' ||
                   ', p_return_status = ' || p_return_status ||
                   ', p_error_buffer  = ' || p_error_buffer);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := SUBSTR(SQLERRM, 1, 80);
      CLOSE get_tax_result_csr;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_result',
                        p_error_buffer);
      END IF;

END get_result;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_fsc_code
--
--  DESCRIPTION
--    This procedure loops through a fiscal classification cache structure
--    to return a fiscal classification code if found
--
--  History
--
--    Phong La                    21-MAY-02  Created
--
PROCEDURE get_fsc_code(
            p_found                   IN OUT NOCOPY BOOLEAN,
            p_tax_regime_code         IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_classification_category IN
                 ZX_FC_TYPES_B.Classification_Type_Categ_Code%TYPE,
            p_classification_type     IN
                 ZX_FC_TYPES_B.CLASSIFICATION_TYPE_CODE%TYPE,
            p_tax_determine_date      IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_classified_entity_id    IN
                 ZX_FC_CODES_B.CLASSIFICATION_ID%TYPE,
            p_item_org_id             IN     NUMBER,
            p_application_id          IN     NUMBER,
            p_event_class_code        IN     VARCHAR2,
            p_trx_alphanumeric_value     OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE)

IS
  l_count                 NUMBER;
  l_search_pointer        NUMBER;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fsc_code.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_fsc_code(+)');
  END IF;

  p_found := FALSE;

  IF G_FSC_TBL_INSERT_POINTER = 0 THEN
    l_count := ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl.count;
    FOR i IN  REVERSE 1 .. l_count LOOP
      IF (    ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(i).classification_type
                  = p_classification_type
          AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(i).tax_regime_code
                  = p_tax_regime_code
          AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(i).classification_category
                  = p_classification_category
          AND NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(i).classified_entity_id,0)
                  = NVL(p_classified_entity_id,0)
          AND p_tax_determine_date
                  >= ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(i).effective_from
          AND p_tax_determine_date
                  <= NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(i).effective_to,
                        p_tax_determine_date)
          AND NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(i).item_org_id, 0)
                  = NVL(p_item_org_id, 0)
          AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(i).application_id
                  = p_application_id
          AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(i).event_class_code
                  = p_event_class_code
         ) THEN
        p_trx_alphanumeric_value := ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(i).fsc_code;
        p_found := TRUE;
        EXIT;
      END IF;
    END LOOP;
  ELSE
    FOR i IN REVERSE 1 .. G_FSC_TBL_MAX_SIZE LOOP
      l_search_pointer := MOD((i + G_FSC_TBL_INSERT_POINTER),G_FSC_TBL_MAX_SIZE);
      IF ( l_search_pointer = 0 ) THEN
        l_search_pointer := G_FSC_TBL_MAX_SIZE;
      END IF;
      IF (    ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(l_search_pointer).classification_type
                  = p_classification_type
          AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(l_search_pointer).tax_regime_code
                  = p_tax_regime_code
          AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(l_search_pointer).classification_category
                  = p_classification_category
          AND NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(l_search_pointer).classified_entity_id,0)
                  = NVL(p_classified_entity_id,0)
          AND p_tax_determine_date
                  >= ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(l_search_pointer).effective_from
          AND p_tax_determine_date
                  <= NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(l_search_pointer).effective_to,
                        p_tax_determine_date)
          AND NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(l_search_pointer).item_org_id, 0)
                  = NVL(p_item_org_id, 0)
          AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(l_search_pointer).application_id
                  = p_application_id
          AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(l_search_pointer).event_class_code
                  = p_event_class_code
         ) THEN
        p_trx_alphanumeric_value := ZX_TDS_CALC_SERVICES_PUB_PKG.g_fsc_tbl(l_search_pointer).fsc_code;
        p_found := TRUE;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fsc_code',
                   'trx_alpha_value: ' || p_trx_alphanumeric_value);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fsc_code.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_fsc_code(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_fsc_code',
                       sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END get_fsc_code;
----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  check_condition_group_result
--
--  DESCRIPTION
--    This procedure checks the condition group result structure to determine
--    if a given condition group of a template has been evaluated before
--  History
--
--  Helen Si                    5-OCT-01  Created
--
PROCEDURE check_condition_group_result(
       p_det_factor_templ_code IN
                       ZX_DET_FACTOR_TEMPL_B.DET_FACTOR_TEMPL_CODE%TYPE,
       p_condition_group_code  IN
                       ZX_CONDITION_GROUPS_B.CONDITION_GROUP_CODE%TYPE,
       p_trx_line_index        IN     BINARY_INTEGER,
       p_event_class_rec       IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
       p_template_evaluated    OUT NOCOPY BOOLEAN,
       p_result           OUT NOCOPY BOOLEAN)
IS
  l_count                 NUMBER;
  l_check_condition_group_tbl  ZX_TDS_CALC_SERVICES_PUB_PKG.trx_line_cond_grp_eval_tbl;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_condition_group_result.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: check_condition_group_result(+)');
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_condition_group_result',
                   'det_factor_templ_code: ' || p_det_factor_templ_code ||
                   ', condition group code: ' || p_condition_group_code ||
                   ', trx_line_index: ' || p_trx_line_index ||
                   ', application_Id: ' || to_char(p_event_class_rec.application_Id) ||
                   ', tax_event_class_code: ' || p_event_class_rec.tax_event_class_code);
  END IF;

  l_check_condition_group_tbl := ZX_TDS_CALC_SERVICES_PUB_PKG.g_check_cond_grp_tbl;
  l_count                := l_check_condition_group_tbl.count;
  p_template_evaluated   := FALSE;
  p_result               := FALSE;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_condition_group_result',
                   'Results in condition_group  tbl: ' || to_char(l_count));
  END IF;


  FOR j in 1..l_count LOOP

    IF (l_check_condition_group_tbl(j).det_factor_templ_code =
                           p_det_factor_templ_code                 AND
        l_check_condition_group_tbl(j).condition_group_code =
                           p_condition_group_code                  AND
        l_check_condition_group_tbl(j).trx_line_index  = p_trx_line_index  AND
        l_check_condition_group_tbl(j).application_Id  =
                          p_event_class_rec.application_Id         AND
         l_check_condition_group_tbl(j).tax_event_class_code =
                          p_event_class_rec.tax_event_class_code) THEN

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_condition_group_result',
                       l_check_condition_group_tbl(j).condition_group_code ||
                       ' was evaluated before');
      END IF;

      p_template_evaluated := TRUE;
      p_result := l_check_condition_group_tbl(j).result;
      EXIT;
      /*
       * do not need to search for which driver set is true since
       * driver set now is passed in
       * IF l_check_condition_group_tbl(j).result THEN
       *  p_result          := TRUE;
       *  EXIT;
       *  END IF;
       */
    END IF;

  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_condition_group_result.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: check_condition_group_result(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_condition_group_result',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END check_condition_group_result;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  insert_condition_group_result
--
--  DESCRIPTION
--    This procedure inserts the result of true/false (success/fail) to
--    the condition group result structure after a template has been evaluated
--
--  History
--
--  Helen / Rajeev       1-OCT-01  Created
--
--
PROCEDURE insert_condition_group_result(
            p_det_factor_templ_code IN ZX_DET_FACTOR_TEMPL_B.det_factor_templ_code%TYPE,
            p_condition_group_code  IN ZX_CONDITION_GROUPS_B.condition_group_CODE%TYPE,
            p_result                IN     BOOLEAN,
            p_trx_line_index        IN     BINARY_INTEGER,
            p_event_class_rec       IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE
             )
IS
 i                     BINARY_INTEGER;
 l_check_condition_group_rec      ZX_TDS_CALC_SERVICES_PUB_PKG.trx_line_cond_grp_eval_rec;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.insert_condition_group_result.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: insert_condition_group_result(+)');
  END IF;

  i := ZX_TDS_CALC_SERVICES_PUB_PKG.g_check_cond_grp_tbl.count + 1;

  l_check_condition_group_rec.det_factor_templ_code   := p_det_factor_templ_code;
  l_check_condition_group_rec.condition_group_code := p_condition_group_code;
  l_check_condition_group_rec.trx_line_index  := p_trx_line_index;
  l_check_condition_group_rec.application_id  := p_event_class_rec.application_id;
  l_check_condition_group_rec.tax_event_class_code :=
                              p_event_class_rec.tax_event_class_code;
  l_check_condition_group_rec.result          := p_result;

  ZX_TDS_CALC_SERVICES_PUB_PKG.g_check_cond_grp_tbl(i) := l_check_condition_group_rec;


  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.insert_condition_group_result.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: insert_condition_group_result(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.insert_condition_group_result',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END insert_condition_group_result;


-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  check_templ_tax_parameter
--
--  DESCRIPTION
--  This procedure validates the tax parameter codes stored for each
--  determining factor at the the template details level; this template
--  is further processed only when the tax parameter is supported for the
--  application.
--
--  History
--
--  Ramya              04-FEB-2005                  CREATED
--                                                  Ref Bug #4166241
--
--

PROCEDURE check_templ_tax_parameter(
            p_det_factor_templ_code IN ZX_DET_FACTOR_TEMPL_B.det_factor_templ_code%TYPE,
            p_event_class_rec       IN ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_valid                  OUT NOCOPY BOOLEAN,
            p_return_status         OUT NOCOPY VARCHAR2,
            p_error_buffer          OUT NOCOPY VARCHAR2)

IS

  l_evnt_cls_parameter_code       ZX_PARAMETERS_B.TAX_PARAMETER_CODE%TYPE;
  l_tbl_index                         BINARY_INTEGER;
  --
  -- Earlier, we were having two cursors - one to fetch the template details
  -- and another to get the parameter code value. But with Bug 4896265, merged
  -- the two cursors to have just one , as below.
  --
  -- Bug5710822: Event if one DF is not supported by the current event class,
  --             rule engine needs to check the value of ignore flag of this
  --             determining factor in any condition sets defined under this DF
  --             template. If it is 'Y', this DF template needs to be processed.
  --
  CURSOR chk_taxevnt_parameter_code_csr
        (c_det_factor_templ_cd       ZX_DET_FACTOR_TEMPL_B.det_factor_templ_code%TYPE,
         c_event_class_mapping_id    ZX_EVNT_CLS_MAPPINGS.event_class_mapping_id%TYPE)
       IS
         SELECT param.tax_parameter_code
         FROM   zx_det_factor_templ_dtl dtl,
                zx_det_factor_templ_b templ,
                zx_event_class_params param
         WHERE  templ.det_factor_templ_code = c_det_factor_templ_cd
         AND    dtl.det_factor_templ_id     = templ.det_factor_templ_id
         AND    param.event_class_mapping_id = c_event_class_mapping_id
         AND    param.tax_parameter_code   = dtl.tax_parameter_code
         AND    NOT EXISTS
                (SELECT 1
                   FROM zx_condition_groups_b zcg,
                        zx_conditions zc
                  WHERE zcg.det_factor_templ_code = c_det_factor_templ_cd
                    AND zcg.enabled_flag = 'Y'
                    AND zc.condition_group_code = zcg.condition_group_code
                    AND zc.determining_factor_code = dtl.determining_factor_code
                    AND zc.determining_factor_class_code = dtl.determining_factor_class_code
                    AND NVL(zc.determining_factor_cq_code, 'x') = NVL(dtl.determining_factor_cq_code, 'x')
                    AND zc.ignore_flag = 'Y'

                );

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --Initialize the return status , p_valid as TRUE
  p_valid := TRUE;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_templ_tax_parameter.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: check_templ_tax_parameter(+)');
  END IF;

  l_tbl_index := dbms_utility.get_hash_value(p_det_factor_templ_code||to_char(p_event_class_rec.event_class_mapping_id), 1, 8192);

  IF ZX_GLOBAL_STRUCTURES_PKG.g_template_valid_info_tbl.exists(l_tbl_index) AND
     ZX_GLOBAL_STRUCTURES_PKG.g_template_valid_info_tbl(l_tbl_index).DET_FACTOR_TEMPL_CODE = p_det_factor_templ_code AND
     ZX_GLOBAL_STRUCTURES_PKG.g_template_valid_info_tbl(l_tbl_index).EVENT_CLASS_MAPPING_ID = p_event_class_rec.event_class_mapping_id
  THEN

      p_valid := ZX_GLOBAL_STRUCTURES_PKG.g_template_valid_info_tbl(l_tbl_index).VALID;

  ELSE
       -- get tax parameter codes for all determining factors from ZX_DET_FACTOR_TEMPL_DTL table.

       OPEN chk_taxevnt_parameter_code_csr(p_det_factor_templ_code,
                                           p_event_class_rec.event_class_mapping_id);

       FETCH chk_taxevnt_parameter_code_csr INTO l_evnt_cls_parameter_code;

       --
       --If a parameter exists in the ZX_TAXEVNT_CLS_PARAMS table, then this
       --parameter is not supported by the application; hence return FALSE
       --
       IF (chk_taxevnt_parameter_code_csr%found) THEN
         IF (g_level_statement >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_statement,
                          'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_templ_tax_parameter',
                          'chk_taxevnt_parameter_code_csr row count '
                           ||to_char(chk_taxevnt_parameter_code_csr%rowcount) ||
                          ', Parameter ' || l_evnt_cls_parameter_code || ' FOUND for Template '
                           ||p_det_factor_templ_code);
         END IF;
         p_valid := FALSE;

         ZX_GLOBAL_STRUCTURES_PKG.g_template_valid_info_tbl(l_tbl_index).DET_FACTOR_TEMPL_CODE   :=
                                                                  p_det_factor_templ_code;
         ZX_GLOBAL_STRUCTURES_PKG.g_template_valid_info_tbl(l_tbl_index).EVENT_CLASS_MAPPING_ID   :=
                                                                  p_event_class_rec.event_class_mapping_id;
         ZX_GLOBAL_STRUCTURES_PKG.g_template_valid_info_tbl(l_tbl_index).VALID   := FALSE;

       ELSE

         ZX_GLOBAL_STRUCTURES_PKG.g_template_valid_info_tbl(l_tbl_index).DET_FACTOR_TEMPL_CODE   :=
                                                                 p_det_factor_templ_code;
         ZX_GLOBAL_STRUCTURES_PKG.g_template_valid_info_tbl(l_tbl_index).EVENT_CLASS_MAPPING_ID   :=
                                                                 p_event_class_rec.event_class_mapping_id;
         ZX_GLOBAL_STRUCTURES_PKG.g_template_valid_info_tbl(l_tbl_index).VALID   := TRUE;

       END IF;

       CLOSE chk_taxevnt_parameter_code_csr;
   END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_templ_tax_parameter.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: check_templ_tax_parameter(-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_templ_tax_parameter',
                      p_error_buffer);
    END IF;

END check_templ_tax_parameter;



-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  check_rule_geography
--
--  DESCRIPTION
--  This procedure is to check if the Geography Context for the given Rule matches with the
--  one stored in the Location information cached in the Global structure. Only such Rules need
--  to be processed.
--
--  History
--
--  Ramya              12-APR-2005                  CREATED
--                                                  Ref Bug #4255160
--
--

PROCEDURE check_rule_geography(
    p_structure_name      IN VARCHAR2,
    p_structure_index     IN BINARY_INTEGER,
    p_rule_det_factor_cq  IN ZX_RULES_B.determining_factor_cq_code%TYPE,
    p_rule_geography_type IN ZX_RULES_B.geography_type%TYPE,
    p_rule_geography_id   IN ZX_RULES_B.geography_id%TYPE,
    p_event_class_rec     IN ZX_API_PUB.EVENT_CLASS_REC_TYPE,
    p_valid               OUT NOCOPY BOOLEAN,
    p_return_status       OUT NOCOPY VARCHAR2,
    p_error_buffer        OUT NOCOPY VARCHAR2)

IS
  l_cache_evt_cls_map_id  NUMBER;
  l_cache_trx_id           NUMBER;
  l_cache_trx_line_id     NUMBER;
  l_cache_loc_type         VARCHAR2(30);
  l_cache_geo_type         VARCHAR2(30);
  l_cache_geo_id           NUMBER;
  l_valid                 BOOLEAN;
      --l_count                 NUMBER;
        l_location_id       NUMBER;
        l_geography_id      NUMBER;
        l_geography_code         VARCHAR2(30);
        l_geography_name         VARCHAR2(360);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --Initialize the return status , p_valid as FALSE
  p_valid := FALSE;
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  --l_count := ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.COUNT;


  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_rule_geography.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: check_rule_geography(+)');
  END IF;


      get_tsrm_num_value(
            p_structure_name,
            p_structure_index,
            p_rule_det_factor_cq || '_' || 'LOCATION_ID',
            l_location_id,
            p_return_status,
            p_error_buffer);

      IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_rule_geography',
                   p_rule_det_factor_cq || '_' || 'LOCATION_ID = '||to_char(l_location_id));
      END IF;

         ZX_TCM_GEO_JUR_PKG.get_master_geography
            (l_location_id,
             p_rule_det_factor_cq, --l_location_type
             p_rule_geography_type, -- geography_type
             l_geography_id,
             l_geography_code,
             l_geography_name,
             p_return_status);

        IF p_return_status  =  FND_API.G_RET_STS_SUCCESS THEN
          IF l_geography_id = p_rule_geography_id then
                p_valid:=TRUE;

                       IF (g_level_statement >= g_current_runtime_level ) THEN
                          FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_rule_geography',
                            'p_valid = TRUE ');
                 END IF;

          END IF;
        END IF;


        IF (g_level_statement >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_rule_geography',
                    'p_rule_geography_id=' || to_char(p_rule_geography_id)||
                    ', l_geography_id=' || to_char(l_geography_id) ||
                    ', l_geography_code=' || l_geography_code ||
                    ', l_geography_name=' || l_geography_name  );
  END IF; --g_level_statement if

      /*
  FOR i IN 1..ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.event_class_mapping_id.LAST LOOP

    --l_cache_evt_cls_map_id := ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.event_class_mapping_id(i);
    --l_cache_trx_id         := ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.trx_id(i);
    l_cache_loc_type       := ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.location_type(i);
    l_cache_geo_type       := ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.geography_type(i);
    l_cache_geo_id         := ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.geography_id(i);

    IF (g_level_statement >= g_current_runtime_level ) THEN
                  FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_rule_geography',
                    'l_cache_evt_cls_map_id=' || to_char(l_cache_evt_cls_map_id) ||
                    ', l_cache_trx_id=' || to_char(l_cache_trx_id) ||
                    ', l_cache_trx_line_id=' || to_char(l_cache_trx_line_id) ||
                    ', l_cache_loc_type=' || l_cache_loc_type ||
                    ', l_cache_geo_type=' || l_cache_geo_type ||
                    ', l_cache_geo_id=' || to_char(l_cache_geo_id));
    END IF; --g_level_statement if

    IF(l_cache_loc_type = p_rule_det_factor_cq AND
        l_cache_geo_type = p_rule_geography_type AND
        l_cache_geo_id = p_rule_geography_id ) THEN
      p_valid:=TRUE;
      EXIT;
    END IF;
  END LOOP;
  */

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_rule_geography.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: check_rule_geography(-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.check_rule_geography',
                      p_error_buffer);
    END IF;

END check_rule_geography;


-----------------------------------------------------------------------
--  PUBLIC FUNCTION
--  get_trx_value_index
--
--  DESCRIPTION
--
--  This function returns the hash table index from global trx
--  value cache structure
--

FUNCTION get_trx_value_index(
   p_Det_Factor_Class_Code       IN ZX_CONDITIONS.Determining_Factor_Class_Code%TYPE,
   p_determining_factor_code     IN ZX_CONDITIONS.determining_factor_code%TYPE,
   p_Determining_Factor_Cq_Code  IN ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
   p_condition_value             IN ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE )
RETURN BINARY_INTEGER IS
  l_count          NUMBER;
  l_tbl_index      BINARY_INTEGER;
  cache_delim      CONSTANT VARCHAR2(03) := '|$|';
/* Bug 5003413 : Added a delimiter to avoid concatenation of two strings
                 resulting into same output string */
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_trx_value_index.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_trx_value_index(+)');
  END IF;

  l_count     := ZX_TDS_CALC_SERVICES_PUB_PKG.g_trx_alphanum_value_tbl.COUNT;


  l_tbl_index := dbms_utility.get_hash_value(
                p_Det_Factor_Class_Code || cache_delim ||
                p_determining_factor_code  || cache_delim ||
                p_Determining_Factor_Cq_Code || cache_delim ||
                p_condition_value,
                1,
                8192);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_trx_value_index.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: get_trx_value_index(-)');
  END IF;

  RETURN l_tbl_index;

EXCEPTION
  WHEN OTHERS THEN

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.get_trx_value_index',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END get_trx_value_index;
-----------------------------------------------------------------------

--  PRIVATE FUNCTION
--  evaluate_alphanum_condition
--
--  DESCRIPTION
--
--  The procedure is to evaluate condition value of alphanumeric data type
--

FUNCTION evaluate_alphanum_condition(
           p_Operator_Code         IN    ZX_CONDITIONS.Operator_Code%TYPE,
           p_condition_value       IN    ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
           p_trx_value             IN    ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
           p_value_low             IN    ZX_CONDITIONS.VALUE_LOW%TYPE,
           p_value_high            IN    ZX_CONDITIONS.VALUE_HIGH%TYPE,
           p_det_factor_templ_code IN    ZX_DET_FACTOR_TEMPL_B.DET_FACTOR_TEMPL_CODE%TYPE,
           p_chart_of_accounts_id  IN    ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE)
RETURN BOOLEAN IS
  l_str                           ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE;

  l_segments_trx                  FND_FLEX_EXT.SEGMENTARRAY;
  l_segments_low                  FND_FLEX_EXT.SEGMENTARRAY;
  l_segments_high                 FND_FLEX_EXT.SEGMENTARRAY;
  l_num_segments_trx              NUMBER;
  l_num_segments_low              NUMBER;
  l_num_segments_high             NUMBER;
  l_segment_num                   NUMBER;
  l_valid_num                     NUMBER;
  l_delimiter                     VARCHAR2(1);
  l_result                        BOOLEAN;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_alphanum_condition.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: evaluate_alphanum_condition(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_alphanum_condition',
                   'p_Operator_Code: ' || p_operator_code ||
                   ', p_condition_value:' || p_condition_value ||
                   ', p_trx_value: ' || p_trx_value ||
                   ', p_value_low: ' || p_value_low ||
                   ', p_value_high: ' || p_value_high||
                   ', p_det_factor_templ_code: '||p_det_factor_templ_code||
                   ', p_chart_of_accounts_id: '||p_chart_of_accounts_id);
  END IF;

  -- bug fix: 4874898
  IF p_Operator_Code = '='  THEN
    -- this is added for the tax_classification_code is null rule.
    IF p_condition_value = 'NULL' THEN
      RETURN (p_trx_value IS NULL);
    ELSE
      IF p_trx_value is NULL THEN
        RETURN FALSE;
      ELSE
        RETURN  (p_trx_value = p_condition_value);
      END IF;
    END IF;
  ELSIF  p_Operator_Code = '=CQ'  THEN
    RETURN  (p_trx_value = p_condition_value);

  ELSIF p_Operator_Code = '>' THEN
    RETURN  (p_trx_value > p_condition_value);

  ELSIF p_Operator_Code = '<' THEN
    RETURN  (p_trx_value < p_condition_value);

  ELSIF p_Operator_Code = '<=' THEN
    RETURN  (p_trx_value <= p_condition_value);

  ELSIF p_Operator_Code  = '>=' THEN
     RETURN  (p_trx_value >= p_condition_value);

  ELSIF (p_Operator_Code = '<>' OR
         p_Operator_Code = '<>CQ' )  THEN
     --Bug 8301114
    IF p_condition_value is NULL THEN
      RETURN (p_trx_value IS NOT NULL);
    ELSE
      IF p_trx_value is NULL THEN
        RETURN FALSE;
      ELSE
        RETURN  (p_trx_value <> p_condition_value);
      END IF;
    END IF;
  ELSIF p_Operator_Code = 'BETWEEN' THEN
    -- Code added for Bug#7412888
    IF p_det_factor_templ_code = 'ACCOUNTING_FLEXFIELD' THEN
      IF p_trx_value is NULL THEN
        RETURN FALSE;
      ELSE
        l_delimiter   := FND_FLEX_EXT.GET_DELIMITER('SQLGL','GL#',p_chart_of_accounts_id);

        l_num_segments_trx := FND_FLEX_EXT.breakup_segments(p_trx_value,
                                     l_delimiter,
                                     l_segments_trx); --OUT

        l_num_segments_low := FND_FLEX_EXT.breakup_segments(p_value_low,
                                     l_delimiter,
                                     l_segments_low); --OUT

        l_num_segments_high := FND_FLEX_EXT.breakup_segments(p_value_high,
                                     l_delimiter,
                                     l_segments_high); --OUT

        FOR i IN REVERSE 1 .. l_num_segments_trx LOOP
           l_result := TRUE;
           IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_alphanum_condition.BEGIN',
                            'TRX-ACC-SEG-' ||i||' = '|| l_segments_trx(i)||', '||
                            'ACC-LOW-SEG-' ||i||' = '|| l_segments_low(i)||', '||
                            'ACC-HIGH-SEG-'||i||' = '|| l_segments_high(i));
           END IF;

           IF ( NVL(l_segments_trx(i), '!') NOT BETWEEN NVL(l_segments_low(i), '!')
                AND NVL(l_segments_high(i), '~') ) THEN
             l_result := FALSE;
             EXIT;
           END IF;

        END LOOP;
        RETURN l_result;
      END IF;
    ELSE
      RETURN (p_trx_value <= p_value_high AND
              p_trx_value >= p_value_low);
    END IF;

  ELSIF p_Operator_Code = 'IN' THEN
    IF p_trx_value is NULL THEN
      RETURN FALSE;
    ELSE
      l_str := ';' || p_trx_value || ';';
      RETURN (INSTR(p_condition_value, l_str )  > 0 );
    END IF;
  -- Bug 9552043
  ELSIF p_operator_code = 'NULL' THEN
    IF p_trx_value IS NULL THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSIF p_operator_code = 'NOT_NULL' THEN
    IF p_trx_value IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  ELSE
    --
    -- invalid Operator_Code
    --

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_alphanum_condition',
                     'Invalid Operator_Code for alphanumeric data type');
    END IF;

    RETURN FALSE;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_alphanum_condition.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: evaluate_alphanum_condition(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_alphanum_condition',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END evaluate_alphanum_condition;
-----------------------------------------------------------------------

--  PRIVATE FUNCTION
--  evaluate_numeric_condition
--
--  DESCRIPTION
--
--  The procedure is to evaluate condition value of numeric data type
--

FUNCTION evaluate_numeric_condition(
           p_Operator_Code         IN    ZX_CONDITIONS.Operator_Code%TYPE,
           p_condition_value  IN    ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
           p_trx_value        IN    ZX_CONDITIONS.NUMERIC_VALUE%TYPE)
RETURN BOOLEAN IS
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_numeric_condition.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: evaluate_numeric_condition(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_numeric_condition',
                   'p_Operator_Code: ' || p_operator_code ||
                   ', p_condition_value: ' || to_char(p_condition_value) ||
                   ', p_trx_value: ' || to_char(p_trx_value));
  END IF;

  IF p_Operator_Code = '=' THEN
   -- Bug#5009256- below line gives ORA-06502 : numeric or value error
   --    IF p_condition_value = 'NULL' THEN

    IF p_condition_value IS NULL THEN
      RETURN (p_trx_value is NULL);
    ELSE
      IF p_trx_value is NULL THEN
        RETURN FALSE;
      ELSE
        RETURN  (p_trx_value = p_condition_value);
      END IF;
    END IF;

  ELSIF  p_Operator_Code = '=CQ'  THEN
    RETURN  (p_trx_value = p_condition_value);

  ELSIF p_Operator_Code = '>' THEN
    RETURN  (p_trx_value > p_condition_value);

  ELSIF p_Operator_Code = '<' THEN
    RETURN  (p_trx_value < p_condition_value);

  ELSIF p_Operator_Code = '<=' THEN
    RETURN  (p_trx_value <= p_condition_value);

  ELSIF p_Operator_Code = '>=' THEN
     RETURN  (p_trx_value >= p_condition_value);

  ELSIF (p_Operator_Code = '<>' OR
         p_Operator_Code = '<>CQ' )  THEN
     --Bug 8301114
    IF p_condition_value is NULL THEN
      RETURN (p_trx_value IS NOT NULL);
    ELSE
      IF p_trx_value is NULL THEN
        RETURN FALSE;
      ELSE
        RETURN  (p_trx_value <> p_condition_value);
      END IF;
    END IF;
  -- Bug 9552043
  ELSIF p_operator_code = 'NULL' THEN
    IF p_trx_value IS NULL THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSIF p_operator_code = 'NOT_NULL' THEN
    IF p_trx_value IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  ELSE
    --
    -- invalid Operator_Code
    --

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_numeric_condition',
                     'Invalid Operator_Code for numeric data type');
    END IF;

    RETURN FALSE;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_numeric_condition.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: evaluate_numeric_condition(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_numeric_condition',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END evaluate_numeric_condition;
-----------------------------------------------------------------------

--  PRIVATE FUNCTION
--  evaluate_date_condition
--
--  DESCRIPTION
--
--  The procedure is to evaluate condition value of date data type
--

FUNCTION evaluate_date_condition(
           p_Operator_Code    IN      ZX_CONDITIONS.Operator_Code%TYPE,
           p_condition_value  IN      ZX_CONDITIONS.DATE_VALUE%TYPE,
           p_trx_value        IN      ZX_CONDITIONS.DATE_VALUE%TYPE)
RETURN BOOLEAN IS
  l_condition_value      ZX_CONDITIONS.DATE_VALUE%TYPE;
  l_trx_value            ZX_CONDITIONS.DATE_VALUE%TYPE;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_date_condition.BEGIN',
                   'ZX_TDS_RULE_BASE_DETM_PVT: evaluate_date_condition(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_date_condition',
                   'p_Operator_Code: ' || p_operator_code ||
                   ', p_condition_value: ' || to_char(p_condition_value, 'DD-MON-YY') ||
                   ', p_trx_value: ' || to_char(p_trx_value,  'DD-MON-YY'));
  END IF;

  l_trx_value       := TRUNC(p_trx_value);
  l_condition_value := TRUNC(p_condition_value);

  IF p_Operator_Code = '=' THEN
    -- Bug#5009256- below line gives ORA-06502 numeric or value error
    -- IF l_condition_value = 'NULL' THEN

    IF l_condition_value IS NULL THEN
      RETURN (l_trx_value is NULL);
    ELSE
      IF l_trx_value is NULL THEN
        RETURN FALSE;
      ELSE
        RETURN  (l_trx_value = l_condition_value);
      END IF;
    END IF;

  ELSIF  p_Operator_Code = '=CQ'  THEN
    RETURN  (p_trx_value = p_condition_value);

  ELSIF p_Operator_Code = '>' THEN
    RETURN  (l_trx_value > l_condition_value);

  ELSIF p_Operator_Code = '<' THEN
    RETURN  (l_trx_value < l_condition_value);

  ELSIF p_Operator_Code = '<=' THEN
    RETURN  (l_trx_value <= l_condition_value);

  ELSIF p_Operator_Code  = '>=' THEN
     RETURN  (l_trx_value >= l_condition_value);

  ELSIF (p_Operator_Code = '<>' OR
         p_Operator_Code = '<>CQ' )  THEN
     --Bug 8301114
    IF l_condition_value is NULL THEN
      RETURN (l_trx_value IS NOT NULL);
    ELSE
      IF l_trx_value is NULL THEN
        RETURN FALSE;
      ELSE
        RETURN  (l_trx_value <> l_condition_value);
      END IF;
    END IF;
  -- Bug 9552043
  ELSIF p_operator_code = 'NULL' THEN
    IF p_trx_value IS NULL THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  ELSIF p_operator_code = 'NOT_NULL' THEN
    IF p_trx_value IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  ELSE
    --
    -- invalid Operator_Code
    --
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_date_condition',
                     'Invalid Operator_Code for date data type');
    END IF;

    RETURN FALSE;
  END IF;


  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_date_condition.END',
                   'ZX_TDS_RULE_BASE_DETM_PVT: evaluate_date_condition(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.evaluate_date_condition',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END evaluate_date_condition;

-----------------------------------------------------------------------
--  PRIVATE FUNCTION
--  evaluate_if_first_party
--
--  DESCRIPTION
--
-- This function evaluates if the determining factor class qualifier (for
-- registrations and party fiscal classifications) represents a first party
-- or not for the input event class
--

FUNCTION evaluate_if_first_party(
         p_det_fact_cq_code   IN  ZX_CONDITIONS.DETERMINING_FACTOR_CQ_CODE%TYPE)
RETURN BOOLEAN IS

BEGIN

  IF p_det_fact_cq_code IS NULL THEN
  Return(FALSE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 7) = 'BILL_TO' and
      zx_valid_init_params_pkg.source_rec.bill_to_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 9) = 'BILL_FROM' and
      zx_valid_init_params_pkg.source_rec.bill_from_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 7) = 'SHIP_TO' and
      zx_valid_init_params_pkg.source_rec.ship_to_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 9) = 'SHIP_FROM' and
      zx_valid_init_params_pkg.source_rec.ship_from_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 3) = 'POO' and
      zx_valid_init_params_pkg.source_rec.poo_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 3) = 'POA' and
      zx_valid_init_params_pkg.source_rec.poa_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 6) = 'PAYING' and
      zx_valid_init_params_pkg.source_rec.paying_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 6) = 'OWN_HQ' and
      zx_valid_init_params_pkg.source_rec.own_hq_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 7) = 'TRAD_HQ' and
      zx_valid_init_params_pkg.source_rec.trad_hq_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 3) = 'POI' and
      zx_valid_init_params_pkg.source_rec.poi_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 3) = 'POD' and
      zx_valid_init_params_pkg.source_rec.pod_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 8) = 'TTL_TRNS' and
      zx_valid_init_params_pkg.source_rec.ttl_trns_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  IF (SUBSTR(p_det_fact_cq_code, 1, 8) = 'MERCHANT' and
      zx_valid_init_params_pkg.source_rec.merchant_party_type = 'LEGAL_ESTABLISHMENT')
  THEN
     Return(TRUE);
  END IF;

  Return(FALSE);

END evaluate_if_first_party;

END  ZX_TDS_RULE_BASE_DETM_PVT;


/
