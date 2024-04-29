--------------------------------------------------------
--  DDL for Package Body ZX_SIM_CONDITIONS1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_SIM_CONDITIONS1_PKG" AS
/* $Header: zxrisimcondspkgb.pls 120.0 2004/06/16 17:44:33 opedrega ship $ */

  g_current_runtime_level NUMBER;
  g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

  PROCEDURE Insert_Row
       (p_sim_condition_id                         NUMBER,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_tax_line_number                          NUMBER,
        p_det_factor_class_code                    VARCHAR2, --p_determining_factor_class_code
        p_determining_factor_code                  VARCHAR2,
        p_data_type_code                           VARCHAR2,
        p_operator_code                            VARCHAR2,
        p_tax_parameter_code                       VARCHAR2,
        p_determining_factor_cq_code               VARCHAR2,
        p_numeric_value                            NUMBER,
        p_date_value                               DATE,
        p_alphanumeric_value                       VARCHAR2,
        p_value_low                                VARCHAR2,
        p_value_high                               VARCHAR2,
        p_applicability_flag                       VARCHAR2,
        p_status_determine_flag                    VARCHAR2,
        p_default_status_code                      VARCHAR2,
        p_rate_determine_flag                      VARCHAR2,
        p_direct_rate_determine_flag               VARCHAR2,
        p_taxable_basis_determine_flag             VARCHAR2,
        p_calculate_tax_determine_flag             VARCHAR2,
        p_place_of_supply_det_flag                 VARCHAR2, --p_place_of_supply_determine_flag
        p_registration_determine_flag              VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER) IS

    l_return_status VARCHAR2(1000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(1000);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_RULES_PKG.Insert_Row.BEGIN',
                     'ZX_SIM_RULES_PKG: Insert_Row (+)');
    END IF;

    INSERT INTO ZX_SIM_CONDITIONS (sim_condition_id,
                                   trx_id,
                                   trx_line_id,
                                   tax_line_number,
                                   determining_factor_class_code,
                                   determining_factor_code,
                                   data_type_code,
                                   operator_code,
                                   tax_parameter_code,
                                   determining_factor_cq_code,
                                   numeric_value,
                                   date_value,
                                   alphanumeric_value,
                                   value_low,
                                   value_high,
                                   applicability_flag,
                                   status_determine_flag,
                                   default_status_code,
                                   rate_determine_flag,
                                   direct_rate_determine_flag,
                                   taxable_basis_determine_flag,
                                   calculate_tax_determine_flag,
                                   place_of_supply_determine_flag,
                                   registration_determine_flag,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login)
                           VALUES (p_sim_condition_id,
                                   p_trx_id,
                                   p_trx_line_id,
                                   p_tax_line_number,
                                   p_det_factor_class_code,
                                   p_determining_factor_code,
                                   p_data_type_code,
                                   p_operator_code,
                                   p_tax_parameter_code,
                                   p_determining_factor_cq_code,
                                   p_numeric_value,
                                   p_date_value,
                                   p_alphanumeric_value,
                                   p_value_low,
                                   p_value_high,
                                   p_applicability_flag,
                                   p_status_determine_flag,
                                   p_default_status_code,
                                   p_rate_determine_flag,
                                   p_direct_rate_determine_flag,
                                   p_taxable_basis_determine_flag,
                                   p_calculate_tax_determine_flag,
                                   p_place_of_supply_det_flag,
                                   p_registration_determine_flag,
                                   p_created_by,
                                   p_creation_date,
                                   p_last_updated_by,
                                   p_last_update_date,
                                   p_last_update_login);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_RULES_PKG.Insert_Row.BEGIN',
                     'ZX_SIM_RULES_PKG: Insert_Row (-)');
    END IF;
  END Insert_Row;

  PROCEDURE Update_Row
       (p_sim_condition_id                         NUMBER,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_tax_line_number                          NUMBER,
        p_det_factor_class_code                    VARCHAR2, --p_determining_factor_class_code
        p_determining_factor_code                  VARCHAR2,
        p_data_type_code                           VARCHAR2,
        p_operator_code                            VARCHAR2,
        p_tax_parameter_code                       VARCHAR2,
        p_determining_factor_cq_code               VARCHAR2,
        p_numeric_value                            NUMBER,
        p_date_value                               DATE,
        p_alphanumeric_value                       VARCHAR2,
        p_value_low                                VARCHAR2,
        p_value_high                               VARCHAR2,
        p_applicability_flag                       VARCHAR2,
        p_status_determine_flag                    VARCHAR2,
        p_default_status_code                      VARCHAR2,
        p_rate_determine_flag                      VARCHAR2,
        p_direct_rate_determine_flag               VARCHAR2,
        p_taxable_basis_determine_flag             VARCHAR2,
        p_calculate_tax_determine_flag             VARCHAR2,
        p_place_of_supply_det_flag                 VARCHAR2, --p_place_of_supply_determine_flag
        p_registration_determine_flag              VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER) IS

    l_return_status VARCHAR2(1000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(1000);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_RULES_PKG.Update_Row.BEGIN',
                     'ZX_SIM_RULES_PKG: Update_Row (+)');
    END IF;

    UPDATE ZX_SIM_CONDITIONS
      SET sim_condition_id               = p_sim_condition_id,
          trx_id                         = p_trx_id,
          trx_line_id                    = p_trx_line_id,
          tax_line_number                = p_tax_line_number,
          determining_factor_class_code  = p_det_factor_class_code,
          determining_factor_code        = p_determining_factor_code,
          data_type_code                 = p_data_type_code,
          operator_code                  = p_operator_code,
          tax_parameter_code             = p_tax_parameter_code,
          determining_factor_cq_code     = p_determining_factor_cq_code,
          numeric_value                  = p_numeric_value,
          date_value                     = p_date_value,
          alphanumeric_value             = p_alphanumeric_value,
          value_low                      = p_value_low,
          value_high                     = p_value_high,
          applicability_flag             = p_applicability_flag,
          status_determine_flag          = p_status_determine_flag,
          default_status_code            = p_default_status_code,
          rate_determine_flag            = p_rate_determine_flag,
          direct_rate_determine_flag     = p_direct_rate_determine_flag,
          taxable_basis_determine_flag   = p_taxable_basis_determine_flag,
          calculate_tax_determine_flag   = p_calculate_tax_determine_flag,
          place_of_supply_determine_flag = p_place_of_supply_det_flag,
          registration_determine_flag    = p_registration_determine_flag,
          created_by                     = p_created_by,
          creation_date                  = p_creation_date,
          last_updated_by                = p_last_updated_by,
          last_update_date               = p_last_update_date,
          last_update_login              = p_last_update_login
      WHERE SIM_CONDITION_ID = p_sim_condition_id
      AND TRX_ID = p_trx_id
      AND TRX_LINE_ID = p_trx_line_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_RULES_PKG.Update_Row.BEGIN',
                     'ZX_SIM_RULES_PKG: Update_Row (-)');
    END IF;
  END Update_Row;

  PROCEDURE Delete_Row
       (p_sim_condition_id                         NUMBER,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_tax_line_number                          NUMBER,
        p_det_factor_class_code                    VARCHAR2, --p_determining_factor_class_code
        p_determining_factor_code                  VARCHAR2,
        p_data_type_code                           VARCHAR2,
        p_operator_code                            VARCHAR2,
        p_tax_parameter_code                       VARCHAR2,
        p_determining_factor_cq_code               VARCHAR2,
        p_numeric_value                            NUMBER,
        p_date_value                               DATE,
        p_alphanumeric_value                       VARCHAR2,
        p_value_low                                VARCHAR2,
        p_value_high                               VARCHAR2,
        p_applicability_flag                       VARCHAR2,
        p_status_determine_flag                    VARCHAR2,
        p_default_status_code                      VARCHAR2,
        p_rate_determine_flag                      VARCHAR2,
        p_direct_rate_determine_flag               VARCHAR2,
        p_taxable_basis_determine_flag             VARCHAR2,
        p_calculate_tax_determine_flag             VARCHAR2,
        p_place_of_supply_det_flag                 VARCHAR2, --p_place_of_supply_determine_flag
        p_registration_determine_flag              VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER) IS

    l_return_status VARCHAR2(1000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(1000);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_RULES_PKG.Insert_Row.BEGIN',
                     'ZX_SIM_RULES_PKG: Delete_Row (+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_RULES_PKG.Insert_Row.BEGIN',
                     'ZX_SIM_RULES_PKG: Delete_Row (-)');
    END IF;
  END Delete_Row;

  PROCEDURE Lock_Row
       (p_sim_condition_id                         NUMBER,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_tax_line_number                          NUMBER,
        p_det_factor_class_code                    VARCHAR2, --p_determining_factor_class_code
        p_determining_factor_code                  VARCHAR2,
        p_data_type_code                           VARCHAR2,
        p_operator_code                            VARCHAR2,
        p_tax_parameter_code                       VARCHAR2,
        p_determining_factor_cq_code               VARCHAR2,
        p_numeric_value                            NUMBER,
        p_date_value                               DATE,
        p_alphanumeric_value                       VARCHAR2,
        p_value_low                                VARCHAR2,
        p_value_high                               VARCHAR2,
        p_applicability_flag                       VARCHAR2,
        p_status_determine_flag                    VARCHAR2,
        p_default_status_code                      VARCHAR2,
        p_rate_determine_flag                      VARCHAR2,
        p_direct_rate_determine_flag               VARCHAR2,
        p_taxable_basis_determine_flag             VARCHAR2,
        p_calculate_tax_determine_flag             VARCHAR2,
        p_place_of_supply_det_flag                 VARCHAR2, --p_place_of_supply_determine_flag
        p_registration_determine_flag              VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER) IS

    l_return_status VARCHAR2(1000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(1000);

    CURSOR sim_conditions_csr IS
      SELECT SIM_CONDITION_ID,
             TRX_ID,
             TRX_LINE_ID,
             TAX_LINE_NUMBER,
             DETERMINING_FACTOR_CLASS_CODE,
             DETERMINING_FACTOR_CODE,
             DATA_TYPE_CODE,
             OPERATOR_CODE,
             TAX_PARAMETER_CODE,
             DETERMINING_FACTOR_CQ_CODE,
             NUMERIC_VALUE,
             DATE_VALUE,
             ALPHANUMERIC_VALUE,
             VALUE_LOW,
             VALUE_HIGH,
             APPLICABILITY_FLAG,
             STATUS_DETERMINE_FLAG,
             DEFAULT_STATUS_CODE,
             RATE_DETERMINE_FLAG,
             DIRECT_RATE_DETERMINE_FLAG,
             TAXABLE_BASIS_DETERMINE_FLAG,
             CALCULATE_TAX_DETERMINE_FLAG,
             PLACE_OF_SUPPLY_DETERMINE_FLAG,
             REGISTRATION_DETERMINE_FLAG,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
        FROM ZX_SIM_CONDITIONS
        WHERE SIM_CONDITION_ID = p_sim_condition_id
        AND TRX_ID = p_trx_id
        AND TRX_LINE_ID = p_trx_line_id;

    Recinfo sim_conditions_csr%ROWTYPE;

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_RULES_PKG.Insert_Row.BEGIN',
                     'ZX_SIM_RULES_PKG: Lock_Row (+)');
    END IF;

    OPEN sim_conditions_csr;
    FETCH sim_conditions_csr INTO Recinfo;

    IF (sim_conditions_csr%NOTFOUND) THEN
      CLOSE sim_conditions_csr;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE sim_conditions_csr;

    IF ((Recinfo.SIM_CONDITION_ID = p_SIM_CONDITION_ID) AND
        (Recinfo.TRX_ID = p_TRX_ID) AND
        (Recinfo.TRX_LINE_ID = p_TRX_LINE_ID) AND
        (Recinfo.TAX_LINE_NUMBER = p_TAX_LINE_NUMBER) AND
        (Recinfo.DETERMINING_FACTOR_CLASS_CODE = p_DET_FACTOR_CLASS_CODE) AND
        (Recinfo.DETERMINING_FACTOR_CODE = p_DETERMINING_FACTOR_CODE) AND
        (Recinfo.DATA_TYPE_CODE = p_DATA_TYPE_CODE) AND
        (Recinfo.OPERATOR_CODE = p_OPERATOR_CODE) AND
        ((Recinfo.TAX_PARAMETER_CODE = p_TAX_PARAMETER_CODE) OR
         ((Recinfo.TAX_PARAMETER_CODE IS NULL) AND
          (p_TAX_PARAMETER_CODE IS NULL))) AND
        ((Recinfo.DETERMINING_FACTOR_CQ_CODE = p_DETERMINING_FACTOR_CQ_CODE) OR
         ((Recinfo.DETERMINING_FACTOR_CQ_CODE IS NULL) AND
          (p_DETERMINING_FACTOR_CQ_CODE IS NULL))) AND
        ((Recinfo.NUMERIC_VALUE = p_NUMERIC_VALUE) OR
         ((Recinfo.NUMERIC_VALUE IS NULL) AND
          (p_NUMERIC_VALUE IS NULL))) AND
        ((Recinfo.DATE_VALUE = p_DATE_VALUE) OR
         ((Recinfo.DATE_VALUE IS NULL) AND
          (p_DATE_VALUE IS NULL))) AND
        ((Recinfo.ALPHANUMERIC_VALUE = p_ALPHANUMERIC_VALUE) OR
         ((Recinfo.ALPHANUMERIC_VALUE IS NULL) AND
          (p_ALPHANUMERIC_VALUE IS NULL))) AND
        ((Recinfo.VALUE_LOW = p_VALUE_LOW) OR
         ((Recinfo.VALUE_LOW IS NULL) AND
          (p_VALUE_LOW IS NULL))) AND
        ((Recinfo.VALUE_HIGH = p_VALUE_HIGH) OR
         ((Recinfo.VALUE_HIGH IS NULL) AND
          (p_VALUE_HIGH IS NULL))) AND
        ((Recinfo.APPLICABILITY_FLAG = p_APPLICABILITY_FLAG) OR
         ((Recinfo.APPLICABILITY_FLAG IS NULL) AND
          (p_APPLICABILITY_FLAG IS NULL))) AND
        ((Recinfo.STATUS_DETERMINE_FLAG = p_STATUS_DETERMINE_FLAG) OR
         ((Recinfo.STATUS_DETERMINE_FLAG IS NULL) AND
          (p_STATUS_DETERMINE_FLAG IS NULL))) AND
        ((Recinfo.DEFAULT_STATUS_CODE = p_DEFAULT_STATUS_CODE) OR
         ((Recinfo.DEFAULT_STATUS_CODE IS NULL) AND
          (p_DEFAULT_STATUS_CODE IS NULL))) AND
        ((Recinfo.RATE_DETERMINE_FLAG = p_RATE_DETERMINE_FLAG) OR
         ((Recinfo.RATE_DETERMINE_FLAG IS NULL) AND
          (p_RATE_DETERMINE_FLAG IS NULL))) AND
        ((Recinfo.DIRECT_RATE_DETERMINE_FLAG = p_DIRECT_RATE_DETERMINE_FLAG) OR
         ((Recinfo.DIRECT_RATE_DETERMINE_FLAG IS NULL) AND
          (p_DIRECT_RATE_DETERMINE_FLAG IS NULL)))AND
        ((Recinfo.TAXABLE_BASIS_DETERMINE_FLAG = p_TAXABLE_BASIS_DETERMINE_FLAG) OR
         ((Recinfo.TAXABLE_BASIS_DETERMINE_FLAG IS NULL) AND
          (p_TAXABLE_BASIS_DETERMINE_FLAG IS NULL)))AND
        ((Recinfo.CALCULATE_TAX_DETERMINE_FLAG = p_CALCULATE_TAX_DETERMINE_FLAG) OR
         ((Recinfo.CALCULATE_TAX_DETERMINE_FLAG IS NULL) AND
          (p_CALCULATE_TAX_DETERMINE_FLAG IS NULL)))AND
        ((Recinfo.PLACE_OF_SUPPLY_DETERMINE_FLAG = p_place_of_supply_det_flag) OR
         ((Recinfo.PLACE_OF_SUPPLY_DETERMINE_FLAG IS NULL) AND
          (p_place_of_supply_det_flag IS NULL)))AND
        ((Recinfo.REGISTRATION_DETERMINE_FLAG = p_REGISTRATION_DETERMINE_FLAG) OR
         ((Recinfo.REGISTRATION_DETERMINE_FLAG IS NULL) AND
          (p_REGISTRATION_DETERMINE_FLAG IS NULL)))AND
        (Recinfo.CREATED_BY = p_CREATED_BY) AND
        (Recinfo.CREATION_DATE = p_CREATION_DATE) AND
        (Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY) AND
        (Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE) AND
        ((Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN) OR
         ((Recinfo.LAST_UPDATE_LOGIN IS NULL) AND
          (p_LAST_UPDATE_LOGIN IS NULL))) ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_RULES_PKG.Insert_Row.BEGIN',
                     'ZX_SIM_RULES_PKG: Lock_Row (-)');
    END IF;
  END Lock_Row;

END ZX_SIM_CONDITIONS1_PKG;

/
