--------------------------------------------------------
--  DDL for Package ZX_TDS_RULE_BASE_DETM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_RULE_BASE_DETM_PVT" AUTHID CURRENT_USER as
/* $Header: zxdirulenginpvts.pls 120.19 2006/02/21 02:23:11 nipatel ship $ */
  TYPE det_factor_templ_code_tbl IS TABLE OF
    ZX_DET_FACTOR_TEMPL_B.det_factor_templ_code%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE condition_group_code_tbl IS TABLE OF
    ZX_CONDITION_GROUPS_B.condition_group_code%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE condition_group_id_tbl IS TABLE OF
    ZX_CONDITION_GROUPS_B.condition_group_id%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE more_than10_tbl IS TABLE OF
    ZX_CONDITION_GROUPS_B.More_Than_Max_Cond_Flag%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE chart_of_accounts_id_tbl IS TABLE OF
    ZX_CONDITION_GROUPS_B.CHART_OF_ACCOUNTS_ID%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE ledger_id_tbl IS TABLE OF
    ZX_CONDITION_GROUPS_B.LEDGER_ID%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE determining_factor_class_tbl IS TABLE OF
    ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Class_Code%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE determining_factor_cq_tbl IS TABLE OF
    ZX_DET_FACTOR_TEMPL_DTL.Determining_Factor_Cq_Code%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE tax_parameter_code_tbl IS TABLE OF
    ZX_PARAMETERS_B.tax_parameter_code%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE data_type_tbl IS TABLE OF
    ZX_CONDITIONS.Data_Type_Code%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE determining_factor_code_tbl IS TABLE OF
    ZX_DETERMINING_FACTORS_B.determining_factor_code%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE operator_tbl IS TABLE OF
    ZX_CONDITIONS.Operator_Code%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE numeric_value_tbl IS TABLE OF
    ZX_CONDITIONS.numeric_value%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE alphanumeric_value_tbl IS TABLE OF
    ZX_CONDITIONS.alphanumeric_value%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE value_low_tbl IS TABLE OF
    ZX_CONDITIONS.value_low%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE value_high_tbl IS TABLE OF
    ZX_CONDITIONS.value_high%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE date_value_tbl IS TABLE OF
    ZX_CONDITIONS.date_value%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE tax_tbl IS TABLE OF
    ZX_TAXES_B.tax%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE tax_regime_code_tbl IS TABLE OF
    ZX_REGIMES_B.tax_regime_code%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE tax_rule_id_tbl IS TABLE OF
    ZX_RULES_B.tax_rule_id%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE result_id_tbl IS TABLE OF
    ZX_PROCESS_RESULTS.result_id%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE constraint_id_tbl IS TABLE OF
    ZX_CONDITION_GROUPS_B.constraint_id%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE rule_det_factor_cq_tbl IS TABLE OF
  	ZX_RULES_B.determining_factor_cq_code%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE rule_geography_type_tbl IS TABLE OF
  	ZX_RULES_B.geography_type%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE rule_geography_id_tbl IS TABLE OF
  	ZX_RULES_B.geography_id%TYPE
  INDEX BY BINARY_INTEGER;

  g_determining_factor_class_tbl determining_factor_class_tbl;
  g_determining_factor_cq_tbl    determining_factor_cq_tbl;
  g_data_type_tbl                data_type_tbl;
  g_determining_factor_code_tbl  determining_factor_code_tbl;
  g_tax_parameter_code_tbl       tax_parameter_code_tbl;
  g_operator_tbl                 operator_tbl;
  g_numeric_value_tbl            numeric_value_tbl;
  g_date_value_tbl               date_value_tbl;
  g_alphanum_value_tbl           alphanumeric_value_tbl;
  g_value_low_tbl                value_low_tbl;
  g_value_high_tbl               value_high_tbl;

  -- Parameters required for evaluating Constraint, Condition Set and Exception Set.
  g_cec_ship_to_party_site_id     NUMBER;
  g_cec_bill_to_party_site_id     NUMBER;
  g_cec_ship_to_party_id          NUMBER;
  g_cec_bill_to_party_id          NUMBER;
  g_cec_ship_to_site_use_id       NUMBER;
  g_cec_bill_to_site_use_id       NUMBER;
  g_cec_poo_location_id           NUMBER;
  g_cec_poa_location_id           NUMBER;
  g_cec_trx_id                    NUMBER;
  g_cec_trx_line_id               NUMBER;
  g_cec_ledger_id                 NUMBER;
  g_cec_internal_organization_id  NUMBER;
  g_cec_so_organization_id        NUMBER;
  g_cec_product_org_id            NUMBER;
  g_cec_product_id                NUMBER;
  g_cec_trx_type_id               NUMBER;
  g_cec_trx_line_date             DATE;
  g_cec_fob_point                 VARCHAR2(30);

  g_segment_array                FND_FLEX_EXT.SegmentArray;

   c_lines_per_commit CONSTANT NUMBER := ZX_TDS_CALC_SERVICES_PUB_PKG.G_LINES_PER_COMMIT;

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
            p_error_buffer            OUT NOCOPY VARCHAR2);

PROCEDURE get_tsrm_num_value(
            p_structure_name      IN  VARCHAR2,
            p_structure_index     IN  BINARY_INTEGER,
            p_parameter_code      IN  ZX_PARAMETERS_B.TAX_PARAMETER_CODE%TYPE,
            p_trx_numeric_value      OUT NOCOPY ZX_CONDITIONS.NUMERIC_VALUE%TYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE get_tsrm_alphanum_value(
            p_structure_name      IN  VARCHAR2,
            p_structure_index     IN  BINARY_INTEGER,
            p_parameter_code      IN  ZX_PARAMETERS_B.TAX_PARAMETER_CODE%TYPE,
            p_trx_alphanumeric_value    OUT NOCOPY ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE,
            p_return_status             OUT NOCOPY VARCHAR2,
            p_error_buffer              OUT NOCOPY VARCHAR2);

FUNCTION get_trx_value_index(
            p_Det_Factor_Class_Code     IN         ZX_CONDITIONS.Determining_Factor_Class_Code%TYPE,
            p_determining_factor_code      IN         ZX_CONDITIONS.determining_factor_code%TYPE,
            p_Determining_Factor_Cq_Code        IN         ZX_CONDITIONS.Determining_Factor_Cq_Code%TYPE,
            p_condition_value   IN   ZX_CONDITIONS.ALPHANUMERIC_VALUE%TYPE )
RETURN BINARY_INTEGER;

-- Made the following public for bug 4959835
PROCEDURE init_cec_params(
			p_structure_name  IN     VARCHAR2,
            p_structure_index IN     BINARY_INTEGER,
            p_return_status   IN OUT NOCOPY VARCHAR2,
            p_error_buffer    IN OUT NOCOPY VARCHAR2);

-----------------------------------------------------------------------
--  PUBLIC FUNCTION
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
RETURN BOOLEAN;


end ZX_TDS_RULE_BASE_DETM_PVT;

 

/
