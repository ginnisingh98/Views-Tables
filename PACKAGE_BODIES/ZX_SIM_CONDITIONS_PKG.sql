--------------------------------------------------------
--  DDL for Package Body ZX_SIM_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_SIM_CONDITIONS_PKG" AS
/* $Header: zxrisimrulespvtb.pls 120.8 2005/06/29 17:53:54 lxzhang ship $ */

  Cursor c_sim_cond (c_trxline_id NUMBER,
                     c_taxline_number NUMBER) Is
  select count(*)
    from zx_sim_conditions
   where trx_line_id = c_trxline_id
     and tax_line_number = c_taxline_number;

  Cursor c_trxhdr Is
  select *
    from zx_trx_headers_gt;

  Cursor c_trxlines(c_trx_id IN NUMBER) Is
  select *
    from zx_transaction_lines_gt
   where trx_id = c_trx_id
     and trx_level_type <> 'TAX';

  TYPE tab_num_type  IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
  TYPE tab_var_type  IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
  TYPE tab_var1_type IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  TYPE tab_date_type IS TABLE OF DATE           INDEX BY BINARY_INTEGER;

  l_cond_cnt     NUMBER;
  l_taxlines_cnt NUMBER;
  l_trxlines_cnt NUMBER;

  g_current_runtime_level   NUMBER;
  g_level_statement         NUMBER;
  g_level_unexpected        NUMBER;

PROCEDURE create_from_existing_rules (p_tax_regime_code  IN         VARCHAR2,
                                      p_tax              IN         VARCHAR2,
                                      p_content_owner_id IN         NUMBER,
                                      p_application_id   IN         NUMBER,
                                      p_return_status    OUT NOCOPY VARCHAR2,
                                      p_error_buffer     OUT NOCOPY VARCHAR2) AS
BEGIN
  g_level_statement     := FND_LOG.LEVEL_STATEMENT;
  g_level_unexpected    := FND_LOG.LEVEL_UNEXPECTED;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_from_existing_rules.BEGIN',
                     'ZX_SIM_CONDITIONS_PKG: create_from_existing_rules(+)');

      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_from_existing_rules',
                     'Simulate Rules');
   END IF;

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   INSERT INTO zx_sim_rules_b (
               sim_tax_rule_id,
               content_owner_id,
               tax_rule_code,
               tax,
               tax_regime_code,
               service_type_code,
               priority,
               det_factor_templ_code,
               effective_from,
               simulated_flag,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               effective_to,
               application_id,
               recovery_type_code)
        SELECT tax_rule_id,
               content_owner_id,
               tax_rule_code,
               tax,
               tax_regime_code,
               service_type_code,
               priority,
               det_factor_templ_code,
               effective_from,
               'N' simulated_flag,
               fnd_global.user_id created_by,
               sysdate creation_date,
               fnd_global.user_id last_updated_by,
               sysdate last_update_date,
               last_update_login,
               effective_to,
               application_id,
               recovery_type_code
          FROM zx_rules_b
         WHERE tax_regime_code = p_tax_regime_code
           and tax = p_tax
           and content_owner_id = p_content_owner_id
           and NVL(application_id, p_application_id) = p_application_id
           -- The service type code restriction should be removed when
           -- simulate rules is supported for other processes.
           and service_type_code IN ('DET_APPLICABLE_TAXES',
                                     'DET_TAX_STATUS',
                                     'DET_TAX_RATE');

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_from_existing_rules',
                     'Simulate Translation of Rules');
   END IF;

   INSERT INTO zx_sim_rules_tl (
               sim_tax_rule_id,
               language,
               source_lang,
               tax_rule_name,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login)
        SELECT tax_rule_id,
               language,
               source_lang,
               tax_rule_name,
               fnd_global.user_id created_by,
               sysdate creation_date,
               fnd_global.user_id last_updated_by,
               sysdate last_update_date,
               last_update_login
          FROM zx_rules_tl
         WHERE tax_rule_id IN (select sim_tax_rule_id
                                 from zx_sim_rules_b);

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_from_existing_rules',
                     'Simulate Process Results');
   END IF;

   INSERT INTO zx_sim_process_results (
               sim_result_id,
               sim_tax_rule_id,
               condition_group_code,
               priority,
               simulated_flag,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               result_type_code,
               tax_status_code,
               numeric_result,
               alphanumeric_result)
        SELECT result_id,
               tax_rule_id,
               condition_group_code,
               priority,
               'N' simulated_flag,
               fnd_global.user_id created_by,
               sysdate creation_date,
               fnd_global.user_id last_updated_by,
               sysdate last_update_date,
               last_update_login,
               result_type_code,
               tax_status_code,
               numeric_result,
               alphanumeric_result
          FROM zx_process_results
         WHERE tax_rule_id IN (select sim_tax_rule_id
                                 from zx_sim_rules_b);

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_from_existing_rules',
                     'Simulate Conditions');
   END IF;

   INSERT INTO zx_sim_rule_conditions (
               simrule_condition_id,
               condition_group_code,
               determining_factor_class_code,
               determining_factor_code,
               data_type_code,
               operator_code,
               ignore_flag,
               simulated_flag,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               tax_parameter_code,
               determining_factor_cq_code,
               numeric_value,
               date_value,
               alphanumeric_value,
               value_low,
               value_high)
        SELECT condition_id,
               condition_group_code,
               determining_factor_class_code,
               determining_factor_code,
               data_type_code,
               operator_code,
               ignore_flag,
               'N' simulated_flag,
               fnd_global.user_id created_by,
               sysdate creation_date,
               fnd_global.user_id last_updated_by,
               sysdate last_update_date,
               last_update_login,
               tax_parameter_code,
               determining_factor_cq_code,
               numeric_value,
               date_value,
               alphanumeric_value,
               value_low,
               value_high
          FROM zx_conditions
         WHERE condition_group_code IN (select condition_group_code
                                          from zx_sim_process_results
                                         group by condition_group_code);

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_from_existing_rules.END',
                     'ZX_SIM_CONDITIONS_PKG: create_from_existing_rules(-)');
   END IF;


  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_from_existing_rules',
                        p_error_buffer);
      END IF;

END create_from_existing_rules;

-- This procedure creates Simulated Conditions based on ALL determining factors that are
-- enabled for Rules creation.
PROCEDURE create_sim_conditions (p_return_status     OUT NOCOPY varchar2,
                                 p_error_buffer      OUT NOCOPY varchar2) AS

  Cursor c_taxlines Is
  select *
    from zx_import_tax_lines_gt;

  Cursor c_detfactors Is
  select determining_factor_class_code,
         NULL determining_factor_cq_code,
         determining_factor_code,
         tax_parameter_code,
         '=' operator,
         data_type_code,
         NULL numeric_value,
         NULL alphanum_value,
         NULL date_value,
         NULL value_low,
         NULL value_high
  from   zx_determining_factors_b
  where  tax_rules_flag = 'Y'
   and  determining_factor_class_code in ('TRX_INPUT_FACTOR');

  pr_detfactor_class_tab  tab_var_type;
  pr_detfactor_cq_tab     tab_var_type;
  pr_detfactor_code_tab   tab_var_type;
  pr_parameter_code_tab   tab_var_type;
  pr_operator_tab         tab_var_type;
  pr_datatype_tab         tab_var_type;
  pr_numeric_value_tab    tab_num_type;
  pr_alpha_value_tab      tab_var1_type;
  pr_value_low_tab        tab_var1_type;
  pr_value_high_tab       tab_var1_type;
  pr_date_value_tab       tab_date_type;

  l_chart_of_accounts_id  number;
  l_fsc_cat_rec           ZX_TCM_CONTROL_PKG.ZX_CATEGORY_CODE_INFO_REC;
  l_fsc_rec               ZX_TCM_CONTROL_PKG.ZX_FISCAL_CLASS_INFO_REC;
  l_tax_profile_id        ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE;
  l_zx_registration_rec   ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC;
  l_jurisdiction_code     ZX_JURISDICTIONS_B.TAX_JURISDICTION_CODE%TYPE;
  l_ret_record_level      VARCHAR2(30);
  l_location_id           number;
  l_zone_id               NUMBER;
  l_zone_name             VARCHAR2(360);
  l_msg_count             NUMBER;
  j                       NUMBER;

BEGIN
  g_level_statement     := FND_LOG.LEVEL_STATEMENT;
  g_level_unexpected    := FND_LOG.LEVEL_UNEXPECTED;
   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_conditions.BEGIN',
                     'ZX_SIM_CONDITIONS_PKG: create_sim_conditions(+)');
   END IF;

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR l_trxhdr_rec IN c_trxhdr
   Loop
     FOR l_trxlines_rec IN c_trxlines(l_trxhdr_rec.trx_id)
     Loop
       FOR l_taxlines_rec IN c_taxlines
       Loop
         -- If the conditions are already simulated (or customized using UI), exit
         open c_sim_cond (l_trxlines_rec.trx_line_id,
                          l_taxlines_rec.summary_tax_line_number);
         fetch c_sim_cond into l_cond_cnt;
         close c_sim_cond;
         If nvl(l_cond_cnt,0) > 0 then
            IF (g_level_statement >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_conditions',
                             'Conditions are already simulated');
            END IF;

            exit;
         End If;

         -- Fetch All Determining Factors which are enabled to be defined in Rules
         -- and insert them into simulate conditions.
         open c_detfactors;
         fetch c_detfactors bulk collect into
               pr_detfactor_class_tab,
               pr_detfactor_cq_tab,
               pr_detfactor_code_tab,
               pr_parameter_code_tab,
               pr_operator_tab,
               pr_datatype_tab,
               pr_numeric_value_tab,
               pr_alpha_value_tab,
               pr_date_value_tab,
               pr_value_low_tab,
               pr_value_high_tab;

         FOR i in 1..nvl(pr_detfactor_class_tab.last,0)
         Loop
           -- Assign value derived to following structure based on data type:
           -- Number - pr_numeric_value_tab, Alphanumeric - pr_alpha_value_tab
           -- Date - pr_date_value_tab, Low Value - pr_value_low_tab
           -- High Value - pr_value_high_tab

           If pr_detfactor_class_tab(i) = 'TRX_INPUT_FACTOR' Then

              IF (g_level_statement >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_statement,
                                'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_conditions',
                                'Fetching and Assigning Values for Transaction Input Factors');
              END IF;

              If pr_detfactor_code_tab(i) = 'INTENDED_USE' Then
                 pr_alpha_value_tab(i) := l_trxlines_rec.line_intended_use;
              ElsIf pr_detfactor_code_tab(i) = 'PRODUCT_FISCAL_CLASSIFICATION' Then
                 pr_alpha_value_tab(i) := l_trxlines_rec.product_fisc_classification;
              ElsIf pr_detfactor_code_tab(i) = 'USER_DEFINED_FISC_CLASS' Then
                 pr_alpha_value_tab(i) := l_trxlines_rec.user_defined_fisc_class;
              ElsIf pr_detfactor_code_tab(i) = 'INPUT_TAX_CLASSIFICATION_CODE' Then
                 pr_alpha_value_tab(i) := l_trxlines_rec.input_tax_classification_code;
              ElsIf pr_detfactor_code_tab(i) = 'OUTPUT_TAX_CLASSIFICATION_CODE' Then
                 pr_alpha_value_tab(i) := l_trxlines_rec.output_tax_classification_code;
              ElsIf pr_detfactor_code_tab(i) = 'REF_DOC_EVENT_CLASS_CODE' Then
                 pr_alpha_value_tab(i) := l_trxlines_rec.ref_doc_event_class_code;
              End If;

              If pr_alpha_value_tab(i) IS NULL AND
                 pr_numeric_value_tab(i) IS NULL AND
                 pr_date_value_tab(i) IS NULL AND
                 pr_value_low_tab(i) IS NULL THEN
                 pr_detfactor_class_tab(i) := NULL;
              End If;
           End If;
         End Loop;

         IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                           'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_conditions',
                           'Insert All Simulated Conditions containing derived values');
         END IF;

         FORALL j IN pr_detfactor_class_tab.first..pr_detfactor_class_tab.last
                INSERT ALL
                       WHEN pr_detfactor_class_tab(j) IS NOT NULL Then
                       INTO zx_sim_conditions (
                            sim_condition_id,
                            determining_factor_class_code,
                            determining_factor_cq_code,
                            determining_factor_code,
                            tax_parameter_code,
                            operator_code,
                            data_type_code,
                            numeric_value,
                            alphanumeric_value,
                            date_value,
                            value_low,
                            value_high,
                            trx_line_id,
                            trx_id,
                            tax_line_number,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date)
                    VALUES (zx_sim_conditions_s.nextval,
                            determining_factor_class_code,
                            determining_factor_cq_code,
                            determining_factor_code,
                            tax_parameter_code,
                            operator_code,
                            data_type_code,
                            numeric_value,
                            alphanumeric_value,
                            date_value,
                            value_low,
                            value_high,
                            trx_line_id,
                            trx_id,
                            tax_line_number,
                            fnd_global.user_id,
                            sysdate,
                            fnd_global.user_id,
                            sysdate)
                    Select pr_detfactor_class_tab(j) determining_factor_class_code,
                           pr_detfactor_cq_tab(j) determining_factor_cq_code,
                           pr_detfactor_code_tab(j) determining_factor_code,
                           pr_parameter_code_tab(j) tax_parameter_code,
                           pr_operator_tab(j) operator_code,
                           pr_datatype_tab(j) data_type_code,
                           pr_numeric_value_tab(j) numeric_value,
                           pr_alpha_value_tab(j) alphanumeric_value,
                           pr_date_value_tab(j) date_value,
                           pr_value_low_tab(j) value_low,
                           pr_value_high_tab(j) value_high,
                           l_trxlines_rec.trx_line_id trx_line_id,
                           l_trxlines_rec.trx_id trx_id,
                           l_taxlines_rec.summary_tax_line_number tax_line_number
                      From dual;

         If c_detfactors%isopen Then
            close c_detfactors;
         End If;
      End Loop; -- Loop for Tax Lines
    End Loop; -- Loop for Trx Lines
   End Loop; -- Loop for Trx Header

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_conditions.END',
                     'ZX_SIM_CONDITIONS_PKG: create_sim_conditions(-)');
   END IF;

   commit;

  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_conditions',
                        p_error_buffer);
      END IF;

END create_sim_conditions;

-- This procedure creates simulated Rules based on Simulated Conditions.
PROCEDURE create_sim_rules (p_trx_id             IN         number,
                            p_trxline_id         IN         number,
                            p_taxline_number     IN         number,
                            p_content_owner_id   IN         number,
                            p_application_id     IN         number,
                            p_tax_regime_code    IN         varchar2,
                            p_tax                IN         varchar2,
                            p_tax_status_code    IN         varchar2,
                            p_rate_code          IN         varchar2,
                            p_return_status      OUT NOCOPY varchar2,
                            p_error_buffer       OUT NOCOPY varchar2) AS

  l_rule_id   NUMBER;
  l_cg_id     NUMBER;

BEGIN
  g_level_statement     := FND_LOG.LEVEL_STATEMENT;
  g_level_unexpected    := FND_LOG.LEVEL_UNEXPECTED;
   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules.BEGIN',
                     'ZX_SIM_CONDITIONS_PKG: create_sim_rules(+)');
   END IF;

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Delete any existing Simulated Rules, Process Results and Conditions');
   END IF;
   DELETE zx_sim_rules_b;
   DELETE zx_sim_rules_tl;
   DELETE zx_sim_process_results;
   DELETE zx_sim_rule_conditions;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Simulate Rules, Process Results and Conditions from existing Setup');
   END IF;
   create_from_existing_rules (p_tax_regime_code,
                               p_tax,
                               p_content_owner_id,
                               p_application_id,
                               p_return_status,
                               p_error_buffer);

   IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                        'Unable to Create Simulated Rules from Existing Setup');
         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer  := 'Unable to Create Simulated Rules from Existing Setup';
      END IF;

      return;
   END IF;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Simulate Rules and Process Results for Applicability');
   END IF;

   Select zx_rules_b_s.nextval,
          zx_condition_groups_b_s.nextval
     Into l_rule_id,
          l_cg_id
     From Dual;
   INSERT ALL
          WHEN (1=1) Then
          INTO zx_sim_rules_b (
               sim_tax_rule_id,
               content_owner_id,
               tax_rule_code,
               tax,
               tax_regime_code,
               service_type_code,
               priority,
               det_factor_templ_code,
               effective_from,
               simulated_flag,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               application_id)
       VALUES (sim_tax_rule_id,
               p_content_owner_id,
               'R_SIMAP_' || to_char(l_rule_id),
               p_tax,
               p_tax_regime_code,
               'DET_APPLICABLE_TAXES',
               l_rule_id,
               'T_SIMAP_' || to_char(zx_det_factor_templ_b_s.nextval),
               sysdate,
               'Y',
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               p_application_id)
          WHEN (1=1) Then
          INTO zx_sim_process_results (
               sim_result_id,
               sim_tax_rule_id,
               condition_group_code,
               priority,
               result_type_code,
               alphanumeric_result,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
       VALUES (zx_process_results_s.nextval,
               sim_tax_rule_id,
               'G_SIMAP_' || to_char(l_cg_id),
               1,
               'CODE',
               'APPLICABLE',
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
        SELECT l_rule_id sim_tax_rule_id,
               fnd_global.user_id created_by,
               sysdate creation_date,
               fnd_global.user_id last_updated_by,
               sysdate last_update_date
          FROM dual
         WHERE exists (Select 1
                         from zx_sim_conditions
                        where applicability_flag='Y');

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Simulate Rule Conditions for Applicability');
   END IF;

   INSERT INTO zx_sim_rule_conditions (
               simrule_condition_id,
               condition_group_code,
               determining_factor_class_code,
               determining_factor_cq_code,
               determining_factor_code,
               tax_parameter_code,
               operator_code,
               data_type_code,
               numeric_value,
               alphanumeric_value,
               date_value,
               value_low,
               value_high,
               ignore_flag,
               simulated_flag,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
        SELECT zx_conditions_s.nextval,
               'G_SIMAP_' || to_char(l_cg_id) condition_group_code,
               determining_factor_class_code,
               determining_factor_cq_code,
               determining_factor_code,
               tax_parameter_code,
               operator_code,
               data_type_code,
               numeric_value,
               alphanumeric_value,
               date_value,
               value_low,
               value_high,
               'N' ignore_flag,
               'Y' simulated_flag,
               fnd_global.user_id created_by,
               sysdate creation_date,
               fnd_global.user_id last_updated_by,
               sysdate last_update_date
          FROM zx_sim_conditions
         WHERE trx_id = p_trx_id
           and trx_line_id = p_trxline_id
           and tax_line_number = p_taxline_number
           and NVL(applicability_flag,'N') = 'Y';

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Simulate Rules and Process Results for Status Determination');
   END IF;
   Select zx_rules_b_s.nextval,
          zx_condition_groups_b_s.nextval
     Into l_rule_id,
          l_cg_id
     From Dual;

   INSERT ALL
          WHEN (1=1) Then
          INTO zx_sim_rules_b (
               sim_tax_rule_id,
               content_owner_id,
               tax_rule_code,
               tax,
               tax_regime_code,
               service_type_code,
               priority,
               det_factor_templ_code,
               effective_from,
               simulated_flag,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               application_id)
       VALUES (sim_tax_rule_id,
               p_content_owner_id,
               'R_SIMST_' || to_char(l_rule_id),
               p_tax,
               p_tax_regime_code,
               'DET_TAX_STATUS',
               l_rule_id,
               'T_SIMST_' || to_char(zx_det_factor_templ_b_s.nextval),
               sysdate,
               'Y',
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               p_application_id)
          WHEN (1=1) Then
          INTO zx_sim_process_results (
               sim_result_id,
               sim_tax_rule_id,
               condition_group_code,
               priority,
               result_type_code,
               alphanumeric_result,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
       VALUES (zx_process_results_s.nextval,
               sim_tax_rule_id,
               'G_SIMST_' || to_char(l_cg_id),
               1,
               'CODE',
               p_tax_status_code,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
        SELECT l_rule_id sim_tax_rule_id,
               fnd_global.user_id created_by,
               sysdate creation_date,
               fnd_global.user_id last_updated_by,
               sysdate last_update_date
          FROM dual
         WHERE exists (Select 1
                         from zx_sim_conditions
                        where status_determine_flag='Y');

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Simulate Rule Conditions for Status Determination');
   END IF;

   INSERT INTO zx_sim_rule_conditions (
               simrule_condition_id,
               condition_group_code,
               determining_factor_class_code,
               determining_factor_cq_code,
               determining_factor_code,
               tax_parameter_code,
               operator_code,
               data_type_code,
               numeric_value,
               alphanumeric_value,
               date_value,
               value_low,
               value_high,
               ignore_flag,
               simulated_flag)
        SELECT zx_conditions_s.nextval,
               'G_SIMST_' || to_char(l_cg_id) condition_group_code,
               determining_factor_class_code,
               determining_factor_cq_code,
               determining_factor_code,
               tax_parameter_code,
               operator_code,
               data_type_code,
               numeric_value,
               alphanumeric_value,
               date_value,
               value_low,
               value_high,
               'N' ignore_flag,
               'Y' simulated_flag
          FROM zx_sim_conditions
         WHERE trx_id = p_trx_id
           and trx_line_id = p_trxline_id
           and tax_line_number = p_taxline_number
           and NVL(status_determine_flag,'N') = 'Y';

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Simulate Rules and Process Results for Rate Determination');
   END IF;

   Select zx_rules_b_s.nextval,
          zx_condition_groups_b_s.nextval
     Into l_rule_id,
          l_cg_id
     From Dual;
   INSERT ALL
          WHEN (1=1) Then
          INTO zx_sim_rules_b (
               sim_tax_rule_id,
               content_owner_id,
               tax_rule_code,
               tax,
               tax_regime_code,
               service_type_code,
               priority,
               det_factor_templ_code,
               effective_from,
               simulated_flag,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               application_id)
       VALUES (sim_tax_rule_id,
               p_content_owner_id,
               'R_SIMRT_' || to_char(l_rule_id),
               p_tax,
               p_tax_regime_code,
               'DET_TAX_RATE',
               l_rule_id,
               'T_SIMRT_' || to_char(zx_det_factor_templ_b_s.nextval),
               sysdate,
               'Y',
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               p_application_id)
          WHEN (1=1) Then
          INTO zx_sim_process_results (
               sim_result_id,
               sim_tax_rule_id,
               condition_group_code,
               priority,
               tax_status_code,
               result_type_code,
               alphanumeric_result,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
       VALUES (zx_process_results_s.nextval,
               sim_tax_rule_id,
               'G_SIMRT_' || to_char(l_cg_id),
               1,
               p_tax_status_code,
               'CODE',
               p_rate_code,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
        SELECT l_rule_id sim_tax_rule_id,
               fnd_global.user_id created_by,
               sysdate creation_date,
               fnd_global.user_id last_updated_by,
               sysdate last_update_date
          FROM dual
         WHERE exists (Select 1
                         from zx_sim_conditions
                        where rate_determine_flag='Y');

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Simulate Rule Conditions for Rate Determination');
   END IF;

   INSERT INTO zx_sim_rule_conditions (
               simrule_condition_id,
               condition_group_code,
               determining_factor_class_code,
               determining_factor_cq_code,
               determining_factor_code,
               tax_parameter_code,
               operator_code,
               data_type_code,
               numeric_value,
               alphanumeric_value,
               date_value,
               value_low,
               value_high,
               ignore_flag,
               simulated_flag)
        SELECT zx_conditions_s.nextval,
               'G_SIMRT_' || to_char(l_cg_id) condition_group_code,
               determining_factor_class_code,
               determining_factor_cq_code,
               determining_factor_code,
               tax_parameter_code,
               operator_code,
               data_type_code,
               numeric_value,
               alphanumeric_value,
               date_value,
               value_low,
               value_high,
               'N' ignore_flag,
               'Y' simulated_flag
          FROM zx_sim_conditions
         WHERE trx_id = p_trx_id
           and trx_line_id = p_trxline_id
           and tax_line_number = p_taxline_number
           and NVL(rate_determine_flag,'N') = 'Y';

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Simulate Translation of Rules');
   END IF;

   INSERT INTO zx_sim_rules_tl (
               language,
               source_lang,
               tax_rule_name,
               sim_tax_rule_id,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by)
        select l.language_code,
               userenv('LANG'),
               b.tax_rule_code,
               b.sim_tax_rule_id,
               sysdate creation_date,
               fnd_global.user_id created_by,
               sysdate last_update_date,
               fnd_global.user_id last_updated_by
          from fnd_languages l,
               zx_sim_rules_b b
         where l.installed_flag in ('I', 'B')
           and  not exists
                (select NULL
                   from zx_sim_rules_tl t
                  where t.sim_tax_rule_id =  b.sim_tax_rule_id
                    and t.language = l.language_code);

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules.END',
                     'ZX_SIM_CONDITIONS_PKG: create_sim_rules(-)');
   END IF;

   commit;

  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                        p_error_buffer);
      END IF;

END create_sim_rules;

PROCEDURE create_rules (p_return_status OUT NOCOPY VARCHAR2,
                        p_error_buffer  OUT NOCOPY VARCHAR2) AS

  CURSOR c_condgroups IS
  SELECT condition_group_code
    FROM zx_sim_rule_conditions
   WHERE simulated_flag = 'Y'
   GROUP BY condition_group_code
   HAVING count(*) <= 10;

  CURSOR c_conditions(c_group_code varchar2) IS
  SELECT determining_factor_class_code,
         determining_factor_cq_code,
         determining_factor_code,
         data_type_code,
         operator_code,
         tax_parameter_code,
         numeric_value,
         date_value,
         alphanumeric_value,
         value_low,
         value_high
    FROM zx_sim_rule_conditions
   WHERE condition_group_code = c_group_code
     AND ignore_flag='N';

  l_cond_cnt  NUMBER;

BEGIN
  g_level_statement     := FND_LOG.LEVEL_STATEMENT;
  g_level_unexpected    := FND_LOG.LEVEL_UNEXPECTED;
   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_rules.BEGIN',
                     'ZX_SIM_CONDITIONS_PKG: create_rules(+)');
   END IF;

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Create Template Header Setup');
   END IF;

   INSERT ALL WHEN (1=1) Then
          INTO zx_det_factor_templ_b (
               det_factor_templ_id,
               det_factor_templ_code,
               template_usage_code,
               record_type_code,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
        VALUES (to_number(substr(det_factor_templ_code,9)),
               det_factor_templ_code,
               'TAX_RULES',
               'USER_DEFINED',
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               sysdate)
        SELECT det_factor_templ_code
          FROM zx_sim_rules_b
         WHERE simulated_flag = 'Y'
         GROUP BY det_factor_templ_code;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Create Translation for Template Header Setup');
   END IF;

   INSERT INTO zx_det_factor_templ_tl (
               language,
               source_lang,
               det_factor_templ_name,
               det_factor_templ_id,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by)
        select l.language_code,
               userenv('LANG'),
               b.det_factor_templ_code,
               b.det_factor_templ_id,
               sysdate creation_date,
               fnd_global.user_id created_by,
               sysdate last_update_date,
               fnd_global.user_id last_updated_by
          from fnd_languages l,
               zx_det_factor_templ_b b
         where l.installed_flag in ('I', 'B')
           and exists (Select NULL
                         From zx_sim_rules_b s
                        Where s.det_factor_templ_code = b.det_factor_templ_code
                          And s.simulated_flag = 'Y')
           and  not exists (Select NULL
                              From zx_det_factor_templ_tl t
                             Where t.det_factor_templ_id =  b.det_factor_templ_id
                               And t.language = l.language_code);

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Create Template Details Setup');
   END IF;

   INSERT ALL WHEN (1=1) Then
          INTO zx_det_factor_templ_dtl (
               det_factor_templ_dtl_id,
               det_factor_templ_id,
               determining_factor_class_code,
               determining_factor_cq_code,
               determining_factor_code,
               required_flag,
               record_type_code,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
        VALUES (zx_det_factor_templ_dtl_s.nextval,
               det_factor_templ_id,
               determining_factor_class_code,
               determining_factor_cq_code,
               determining_factor_code,
               required_flag,
               'USER_DEFINED',
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               sysdate)
        SELECT to_number(substr(rule.det_factor_templ_code,9)) det_factor_templ_id,
               determining_factor_class_code,
               determining_factor_cq_code,
               determining_factor_code,
               decode(ignore_flag,'N','Y','N') required_flag
          FROM zx_sim_rule_conditions cond,
               (select det_factor_templ_code,
                       condition_group_code
                  from zx_sim_process_results p,
                       zx_sim_rules_b r
                 where p.sim_tax_rule_id = r.sim_tax_rule_id
                 group by condition_group_code, det_factor_templ_code) rule
         WHERE cond.condition_group_code = rule.condition_group_code
           AND simulated_flag = 'Y';

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Create Condition Groups Setup without Conditions');
   END IF;

   INSERT ALL WHEN (1=1) Then
          INTO zx_condition_groups_b (
               condition_group_id,
               condition_group_code,
               det_factor_templ_code,
               record_type_code,
               more_than_max_cond_flag,
               enabled_flag,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
        VALUES (to_number(substr(condition_group_code,9)),
               condition_group_code,
               det_factor_templ_code,
               'USER_DEFINED',
               'Y',
               'Y',
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               sysdate)
        SELECT condition_group_code,
               det_factor_templ_code
          FROM zx_sim_rules_b rule,
               zx_sim_process_results result
         WHERE result.sim_tax_rule_id = rule.sim_tax_rule_id
           AND result.simulated_flag = 'Y'
         GROUP BY condition_group_code, det_factor_templ_code;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Create Translation for Condition Groups Setup');
   END IF;

   INSERT INTO zx_condition_groups_tl (
               language,
               source_lang,
               condition_group_name,
               condition_group_id,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by)
        select l.language_code,
               userenv('LANG'),
               b.condition_group_code,
               b.condition_group_id,
               sysdate creation_date,
               fnd_global.user_id created_by,
               sysdate last_update_date,
               fnd_global.user_id last_updated_by
          from fnd_languages l,
               zx_condition_groups_b b
         where l.installed_flag in ('I', 'B')
           and exists (Select NULL
                         From zx_sim_process_results s
                        Where s.condition_group_code = b.condition_group_code
                          And s.simulated_flag = 'Y')
           and  not exists (Select NULL
                              From zx_condition_groups_tl t
                             Where t.condition_group_id =  b.condition_group_id
                               And t.language = l.language_code);

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Update Condition Groups Setup with conditions having 10 or fewer Conditions');
   END IF;

   FOR i IN c_condgroups
   LOOP
       l_cond_cnt := 1;
       FOR j IN c_conditions (i.condition_group_code)
       LOOP
           IF l_cond_cnt = 1 THEN
              UPDATE zx_condition_groups_b
                 SET more_than_max_cond_flag = 'N',
                     determining_factor_class1_code = j.determining_factor_class_code,
                     determining_factor_cq1_code    = j.determining_factor_cq_code,
                     determining_factor_code1       = j.determining_factor_code,
                     tax_parameter_code1            = j.tax_parameter_code,
                     data_type1_code                = j.data_type_code,
                     operator1_code                 = j.operator_code,
                     numeric_value1                 = j.numeric_value,
                     date_value1                    = j.date_value,
                     alphanumeric_value1            = j.alphanumeric_value,
                     value_low1                     = j.value_low,
                     value_high1                    = j.value_high
               WHERE condition_group_code = i.condition_group_code;
               l_cond_cnt := l_cond_cnt + 1;
           ELSIF l_cond_cnt = 2 THEN
              UPDATE zx_condition_groups_b
                 SET determining_factor_class2_code = j.determining_factor_class_code,
                     determining_factor_cq2_code    = j.determining_factor_cq_code,
                     determining_factor_code2       = j.determining_factor_code,
                     tax_parameter_code2            = j.tax_parameter_code,
                     data_type2_code                = j.data_type_code,
                     operator2_code                 = j.operator_code,
                     numeric_value2                 = j.numeric_value,
                     date_value2                    = j.date_value,
                     alphanumeric_value2            = j.alphanumeric_value,
                     value_low2                     = j.value_low,
                     value_high2                    = j.value_high
               WHERE condition_group_code = i.condition_group_code;
               l_cond_cnt := l_cond_cnt + 1;
           ELSIF l_cond_cnt = 3 THEN
              UPDATE zx_condition_groups_b
                 SET determining_factor_class3_code = j.determining_factor_class_code,
                     determining_factor_cq3_code    = j.determining_factor_cq_code,
                     determining_factor_code3       = j.determining_factor_code,
                     tax_parameter_code3            = j.tax_parameter_code,
                     data_type3_code                = j.data_type_code,
                     operator3_code                 = j.operator_code,
                     numeric_value3                 = j.numeric_value,
                     date_value3                    = j.date_value,
                     alphanumeric_value3            = j.alphanumeric_value,
                     value_low3                     = j.value_low,
                     value_high3                    = j.value_high
               WHERE condition_group_code = i.condition_group_code;
               l_cond_cnt := l_cond_cnt + 1;
           ELSIF l_cond_cnt = 4 THEN
              UPDATE zx_condition_groups_b
                 SET determining_factor_class4_code = j.determining_factor_class_code,
                     determining_factor_cq4_code    = j.determining_factor_cq_code,
                     determining_factor_code4       = j.determining_factor_code,
                     tax_parameter_code4            = j.tax_parameter_code,
                     data_type4_code                = j.data_type_code,
                     operator4_code                 = j.operator_code,
                     numeric_value4                 = j.numeric_value,
                     date_value4                    = j.date_value,
                     alphanumeric_value4            = j.alphanumeric_value,
                     value_low4                     = j.value_low,
                     value_high4                    = j.value_high
               WHERE condition_group_code = i.condition_group_code;
               l_cond_cnt := l_cond_cnt + 1;
           ELSIF l_cond_cnt = 5 THEN
              UPDATE zx_condition_groups_b
                 SET determining_factor_class5_code = j.determining_factor_class_code,
                     determining_factor_cq5_code    = j.determining_factor_cq_code,
                     determining_factor_code5       = j.determining_factor_code,
                     tax_parameter_code5            = j.tax_parameter_code,
                     data_type5_code                = j.data_type_code,
                     operator5_code                 = j.operator_code,
                     numeric_value5                 = j.numeric_value,
                     date_value5                    = j.date_value,
                     alphanumeric_value5            = j.alphanumeric_value,
                     value_low5                     = j.value_low,
                     value_high5                    = j.value_high
               WHERE condition_group_code = i.condition_group_code;
               l_cond_cnt := l_cond_cnt + 1;
           ELSIF l_cond_cnt = 6 THEN
              UPDATE zx_condition_groups_b
                 SET determining_factor_class6_code = j.determining_factor_class_code,
                     determining_factor_cq6_code    = j.determining_factor_cq_code,
                     determining_factor_code6       = j.determining_factor_code,
                     tax_parameter_code6            = j.tax_parameter_code,
                     data_type6_code                = j.data_type_code,
                     operator6_code                 = j.operator_code,
                     numeric_value6                 = j.numeric_value,
                     date_value6                    = j.date_value,
                     alphanumeric_value6            = j.alphanumeric_value,
                     value_low6                     = j.value_low,
                     value_high6                    = j.value_high
               WHERE condition_group_code = i.condition_group_code;
               l_cond_cnt := l_cond_cnt + 1;
           ELSIF l_cond_cnt = 7 THEN
              UPDATE zx_condition_groups_b
                 SET determining_factor_class7_code = j.determining_factor_class_code,
                     determining_factor_cq7_code    = j.determining_factor_cq_code,
                     determining_factor_code7       = j.determining_factor_code,
                     tax_parameter_code7            = j.tax_parameter_code,
                     data_type7_code                = j.data_type_code,
                     operator7_code                 = j.operator_code,
                     numeric_value7                 = j.numeric_value,
                     date_value7                    = j.date_value,
                     alphanumeric_value7            = j.alphanumeric_value,
                     value_low7                     = j.value_low,
                     value_high7                    = j.value_high
               WHERE condition_group_code = i.condition_group_code;
               l_cond_cnt := l_cond_cnt + 1;
           ELSIF l_cond_cnt = 8 THEN
              UPDATE zx_condition_groups_b
                 SET determining_factor_class8_code = j.determining_factor_class_code,
                     determining_factor_cq8_code    = j.determining_factor_cq_code,
                     determining_factor_code8       = j.determining_factor_code,
                     tax_parameter_code8            = j.tax_parameter_code,
                     data_type8_code                = j.data_type_code,
                     operator8_code                 = j.operator_code,
                     numeric_value8                 = j.numeric_value,
                     date_value8                    = j.date_value,
                     alphanumeric_value8            = j.alphanumeric_value,
                     value_low8                     = j.value_low,
                     value_high8                    = j.value_high
               WHERE condition_group_code = i.condition_group_code;
               l_cond_cnt := l_cond_cnt + 1;
           ELSIF l_cond_cnt = 9 THEN
              UPDATE zx_condition_groups_b
                 SET determining_factor_class9_code = j.determining_factor_class_code,
                     determining_factor_cq9_code    = j.determining_factor_cq_code,
                     determining_factor_code9       = j.determining_factor_code,
                     tax_parameter_code9            = j.tax_parameter_code,
                     data_type9_code                = j.data_type_code,
                     operator9_code                 = j.operator_code,
                     numeric_value9                 = j.numeric_value,
                     date_value9                    = j.date_value,
                     alphanumeric_value9            = j.alphanumeric_value,
                     value_low9                     = j.value_low,
                     value_high9                    = j.value_high
               WHERE condition_group_code = i.condition_group_code;
               l_cond_cnt := l_cond_cnt + 1;
           ELSIF l_cond_cnt = 10 THEN
              UPDATE zx_condition_groups_b
                 SET determining_factor_clas10_code  = j.determining_factor_class_code,
                     determining_factor_cq10_code    = j.determining_factor_cq_code,
                     determining_factor_code10       = j.determining_factor_code,
                     tax_parameter_code10            = j.tax_parameter_code,
                     data_type10_code                = j.data_type_code,
                     operator10_code                 = j.operator_code,
                     numeric_value10                 = j.numeric_value,
                     date_value10                    = j.date_value,
                     alphanumeric_value10            = j.alphanumeric_value,
                     value_low10                     = j.value_low,
                     value_high10                    = j.value_high
               WHERE condition_group_code = i.condition_group_code;
               l_cond_cnt := l_cond_cnt + 1;
           END IF;
       END LOOP;
   END LOOP;

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Create Conditions Setup');
   END IF;

   INSERT INTO zx_conditions (
               condition_id,
               condition_group_code,
               determining_factor_class_code,
               determining_factor_code,
               data_type_code,
               operator_code,
               ignore_flag,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               tax_parameter_code,
               determining_factor_cq_code,
               record_type_code,
               numeric_value,
               date_value,
               alphanumeric_value,
               value_low,
               value_high)
        SELECT simrule_condition_id,
               condition_group_code,
               determining_factor_class_code,
               determining_factor_code,
               data_type_code,
               operator_code,
               ignore_flag,
               fnd_global.user_id created_by,
               sysdate creation_date,
               fnd_global.user_id last_updated_by,
               sysdate last_update_date,
               tax_parameter_code,
               determining_factor_cq_code,
               'USER_DEFINED',
               numeric_value,
               date_value,
               alphanumeric_value,
               value_low,
               value_high
          FROM zx_sim_rule_conditions
         WHERE simulated_flag = 'Y';

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Create Rules Setup');
   END IF;

   INSERT INTO zx_rules_b (
               tax_rule_id,
               content_owner_id,
               tax_rule_code,
               tax,
               tax_regime_code,
               service_type_code,
               application_id,
               priority,
               det_factor_templ_code,
               effective_from,
               enabled_flag,
               record_type_code,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
        SELECT sim_tax_rule_id,
               content_owner_id,
               tax_rule_code,
               tax,
               tax_regime_code,
               service_type_code,
               application_id,
               priority,
               det_factor_templ_code,
               effective_from,
               'Y',
               'USER_DEFINED',
               fnd_global.user_id created_by,
               sysdate creation_date,
               fnd_global.user_id last_updated_by,
               sysdate last_update_date
          FROM zx_sim_rules_b
         WHERE simulated_flag = 'Y';

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Create Translation for Rules Setup');
   END IF;

   INSERT INTO zx_rules_tl (
               language,
               source_lang,
               tax_rule_name,
               tax_rule_id,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by)
        select l.language_code,
               userenv('LANG'),
               b.tax_rule_code,
               b.tax_rule_id,
               sysdate creation_date,
               fnd_global.user_id created_by,
               sysdate last_update_date,
               fnd_global.user_id last_updated_by
          from fnd_languages l,
               zx_rules_b b
         where l.installed_flag in ('I', 'B')
           and exists (Select NULL
                         From zx_sim_rules_b s
                        Where s.sim_tax_rule_id = b.tax_rule_id
                          And s.simulated_flag = 'Y')
           and  not exists (Select NULL
                              From zx_rules_tl t
                             Where t.tax_rule_id =  b.tax_rule_id
                               And t.language = l.language_code);

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Update Rules Setup for which Priority has been changed in Simulator');
   END IF;

   UPDATE zx_rules_b
          SET priority = (Select sim.priority
                            From zx_sim_rules_b sim
                           Where sim.sim_tax_rule_id = zx_rules_b.tax_rule_id)
    WHERE tax_rule_id IN (Select sim_tax_rule_id
                           From zx_sim_rules_b sim
                          Where sim.priority <> zx_rules_b.priority
                            And sim.simulated_flag <> 'Y');

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Create Process Results Setup');
   END IF;

   INSERT INTO zx_process_results (
               result_id,
               content_owner_id,
               condition_group_id,
               condition_group_code,
               tax_rule_id,
               priority,
               result_type_code,
               tax_status_code,
               numeric_result,
               alphanumeric_result,
               enabled_flag,
               record_type_code,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date)
        SElECT result.sim_result_id,
               rule.content_owner_id,
               to_number(substr(result.condition_group_code,9)),
               result.condition_group_code,
               result.sim_tax_rule_id,
               result.priority,
               result.result_type_code,
               result.tax_status_code,
               result.numeric_result,
               result.alphanumeric_result,
               'Y',
               'USER_DEFINED',
               fnd_global.user_id created_by,
               sysdate creation_date,
               fnd_global.user_id last_updated_by,
               sysdate last_update_date
          FROM zx_sim_rules_b rule,
               zx_sim_process_results result
         WHERE result.sim_tax_rule_id = rule.sim_tax_rule_id
           AND result.simulated_flag = 'Y';

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_sim_rules',
                     'Update Process Results for which Priority has been changed in Simulator');
   END IF;

   UPDATE zx_process_results
          SET priority = (Select sim.priority
                            From zx_sim_process_results sim
                           Where sim.sim_result_id = zx_process_results.result_id)
    WHERE result_id IN (Select sim_result_id
                           From zx_sim_process_results sim
                          Where sim.priority <> zx_process_results.priority
                            And sim.simulated_flag <> 'Y');

   IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_rules.END',
                     'ZX_SIM_CONDITIONS_PKG: create_rules(-)');
   END IF;

   commit;


  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_SIM_CONDITIONS_PKG.create_rules',
                        p_error_buffer);
      END IF;

END create_rules;

END ZX_SIM_CONDITIONS_PKG;

/
