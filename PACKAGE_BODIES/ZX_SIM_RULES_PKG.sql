--------------------------------------------------------
--  DDL for Package Body ZX_SIM_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_SIM_RULES_PKG" AS
/* $Header: zxrisimrulespkgb.pls 120.1 2005/10/27 18:50:58 pla ship $ */

  g_current_runtime_level NUMBER;
  g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

  PROCEDURE Insert_Row
       (p_sim_tax_rule_id                          NUMBER,
        p_content_owner_id                         NUMBER,
        p_tax_rule_code                            VARCHAR2,
        p_tax                                      VARCHAR2,
        p_tax_regime_code                          VARCHAR2,
        p_service_type_code                        VARCHAR2,
        p_priority                                 NUMBER,
        p_det_factor_templ_code                    VARCHAR2,
        p_effective_from                           DATE,
        p_simulated_flag                           VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER,
        p_effective_to                             DATE,
        p_application_id                           NUMBER,
        p_recovery_type_code                       VARCHAR2,
        p_request_id                               NUMBER,
        p_program_application_id                   NUMBER,
        p_program_id                               NUMBER,
        p_program_login_id                         NUMBER) IS

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

    INSERT INTO ZX_SIM_RULES_B (sim_tax_rule_id,
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
                                recovery_type_code,
                                request_id,
                                program_application_id,
                                program_id,
                                program_login_id)
                        VALUES (p_sim_tax_rule_id,
                                p_content_owner_id,
                                p_tax_rule_code,
                                p_tax,
                                p_tax_regime_code,
                                p_service_type_code,
                                p_priority,
                                p_det_factor_templ_code,
                                p_effective_from,
                                p_simulated_flag,
                                p_created_by,
                                p_creation_date,
                                p_last_updated_by,
                                p_last_update_date,
                                p_last_update_login,
                                p_effective_to,
                                p_application_id,
                                p_recovery_type_code,
                                p_request_id,
                                p_program_application_id,
                                p_program_id,
                                p_program_login_id);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_RULES_PKG.Insert_Row.BEGIN',
                     'ZX_SIM_RULES_PKG: Insert_Row (-)');
    END IF;
  END Insert_Row;

  PROCEDURE Update_Row
       (p_sim_tax_rule_id                          NUMBER,
        p_content_owner_id                         NUMBER,
        p_tax_rule_code                            VARCHAR2,
        p_tax                                      VARCHAR2,
        p_tax_regime_code                          VARCHAR2,
        p_service_type_code                        VARCHAR2,
        p_priority                                 NUMBER,
        p_det_factor_templ_code                    VARCHAR2,
        p_effective_from                           DATE,
        p_simulated_flag                           VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER,
        p_effective_to                             DATE,
        p_application_id                           NUMBER,
        p_recovery_type_code                       VARCHAR2,
        p_request_id                               NUMBER,
        p_program_application_id                   NUMBER,
        p_program_id                               NUMBER,
        p_program_login_id                         NUMBER) IS

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

    UPDATE ZX_SIM_RULES_B
      SET sim_tax_rule_id        = p_sim_tax_rule_id,
          content_owner_id       = p_content_owner_id,
          tax_rule_code          = p_tax_rule_code,
          tax                    = p_tax,
          tax_regime_code        = p_tax_regime_code,
          service_type_code      = p_service_type_code,
          priority               = p_priority,
          det_factor_templ_code  = p_det_factor_templ_code,
          effective_from         = p_effective_from,
          simulated_flag         = p_simulated_flag,
          created_by             = p_created_by,
          creation_date          = p_creation_date,
          last_updated_by        = p_last_updated_by,
          last_update_date       = p_last_update_date,
          last_update_login      = p_last_update_login,
          effective_to           = p_effective_to,
          application_id         = p_application_id,
          recovery_type_code     = p_recovery_type_code,
          request_id             = p_request_id,
          program_application_id = p_program_application_id,
          program_id             = p_program_id,
          program_login_id       = p_program_login_id
      WHERE sim_tax_rule_id = p_sim_tax_rule_id
      AND content_owner_id = p_content_owner_id
      AND application_id = p_application_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_RULES_PKG.Update_Row.BEGIN',
                     'ZX_SIM_RULES_PKG: Update_Row (-)');
    END IF;
  END Update_Row;

  PROCEDURE Delete_Row
       (p_sim_tax_rule_id                          NUMBER,
        p_content_owner_id                         NUMBER,
        p_tax_rule_code                            VARCHAR2,
        p_tax                                      VARCHAR2,
        p_tax_regime_code                          VARCHAR2,
        p_service_type_code                        VARCHAR2,
        p_priority                                 NUMBER,
        p_det_factor_templ_code                    VARCHAR2,
        p_effective_from                           DATE,
        p_simulated_flag                           VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER,
        p_effective_to                             DATE,
        p_application_id                           NUMBER,
        p_recovery_type_code                       VARCHAR2,
        p_request_id                               NUMBER,
        p_program_application_id                   NUMBER,
        p_program_id                               NUMBER,
        p_program_login_id                         NUMBER) IS

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
       (p_sim_tax_rule_id                          NUMBER,
        p_content_owner_id                         NUMBER,
        p_tax_rule_code                            VARCHAR2,
        p_tax                                      VARCHAR2,
        p_tax_regime_code                          VARCHAR2,
        p_service_type_code                        VARCHAR2,
        p_priority                                 NUMBER,
        p_det_factor_templ_code                    VARCHAR2,
        p_effective_from                           DATE,
        p_simulated_flag                           VARCHAR2,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER,
        p_effective_to                             DATE,
        p_application_id                           NUMBER,
        p_recovery_type_code                       VARCHAR2,
        p_request_id                               NUMBER,
        p_program_application_id                   NUMBER,
        p_program_id                               NUMBER,
        p_program_login_id                         NUMBER) IS

    l_return_status VARCHAR2(1000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(1000);

    CURSOR sim_rules_csr IS
      SELECT sim_tax_rule_id,
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
             recovery_type_code,
             request_id,
             program_application_id,
             program_id,
             program_login_id
        FROM ZX_SIM_RULES_B
        WHERE SIM_TAX_RULE_ID = p_sim_tax_rule_id
        AND CONTENT_OWNER_ID = p_content_owner_id
        AND APPLICATION_ID = p_application_id;

    Recinfo sim_rules_csr%ROWTYPE;

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_RULES_PKG.Insert_Row.BEGIN',
                     'ZX_SIM_RULES_PKG: Lock_Row (+)');
    END IF;

    OPEN sim_rules_csr;
    FETCH sim_rules_csr INTO Recinfo;

    IF (sim_rules_csr%NOTFOUND) THEN
      CLOSE sim_rules_csr;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE sim_rules_csr;

    IF ((Recinfo.SIM_TAX_RULE_ID = p_SIM_TAX_RULE_ID) AND
        (Recinfo.CONTENT_OWNER_ID = p_CONTENT_OWNER_ID) AND
        (Recinfo.TAX_RULE_CODE = p_TAX_RULE_CODE) AND
        (Recinfo.TAX = p_TAX) AND
        (Recinfo.TAX_REGIME_CODE = p_TAX_REGIME_CODE) AND
        (Recinfo.SERVICE_TYPE_CODE = p_SERVICE_TYPE_CODE) AND
        (Recinfo.PRIORITY = p_PRIORITY) AND
        (Recinfo.DET_FACTOR_TEMPL_CODE = p_DET_FACTOR_TEMPL_CODE) AND
        (Recinfo.EFFECTIVE_FROM = p_EFFECTIVE_FROM) AND
        (Recinfo.SIMULATED_FLAG = p_SIMULATED_FLAG) AND
        (Recinfo.CREATED_BY = p_CREATED_BY) AND
        (Recinfo.CREATION_DATE = p_CREATION_DATE) AND
        (Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY) AND
        (Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE) AND
        ((Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN) OR
         ((Recinfo.LAST_UPDATE_LOGIN IS NULL) AND
          (p_LAST_UPDATE_LOGIN IS NULL))) AND
        ((Recinfo.EFFECTIVE_TO = p_EFFECTIVE_TO) OR
         ((Recinfo.EFFECTIVE_TO IS NULL) AND
          (p_EFFECTIVE_TO IS NULL))) AND
        ((Recinfo.APPLICATION_ID = p_APPLICATION_ID) OR
         ((Recinfo.APPLICATION_ID IS NULL) AND
          (p_APPLICATION_ID IS NULL))) AND
        ((Recinfo.RECOVERY_TYPE_CODE = p_RECOVERY_TYPE_CODE) OR
         ((Recinfo.RECOVERY_TYPE_CODE IS NULL) AND
          (p_RECOVERY_TYPE_CODE IS NULL))) AND
        ((Recinfo.REQUEST_ID = p_REQUEST_ID) OR
         ((Recinfo.REQUEST_ID IS NULL) AND
          (p_REQUEST_ID IS NULL))) AND
        ((Recinfo.PROGRAM_APPLICATION_ID = p_PROGRAM_APPLICATION_ID) OR
         ((Recinfo.PROGRAM_APPLICATION_ID IS NULL) AND
          (p_PROGRAM_APPLICATION_ID IS NULL))) AND
        ((Recinfo.PROGRAM_ID = p_PROGRAM_ID) OR
         ((Recinfo.PROGRAM_ID IS NULL) AND
          (p_PROGRAM_ID IS NULL))) AND
        ((Recinfo.PROGRAM_LOGIN_ID = p_PROGRAM_LOGIN_ID) OR
         ((Recinfo.PROGRAM_LOGIN_ID IS NULL) AND
          (p_PROGRAM_LOGIN_ID IS NULL)))  ) THEN
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

procedure ADD_LANGUAGE
is
begin

  delete from ZX_SIM_RULES_TL T
  where not exists
    (select NULL
    from ZX_SIM_RULES_B B
    where B.SIM_TAX_RULE_ID = T.SIM_TAX_RULE_ID);
  update ZX_SIM_RULES_TL T set (
      TAX_RULE_NAME
      ) = (select B.TAX_RULE_NAME
             from ZX_SIM_RULES_TL B
            where B.SIM_TAX_RULE_ID = T.SIM_TAX_RULE_ID
              and B.LANGUAGE = T.SOURCE_LANG)
  where (T.SIM_TAX_RULE_ID, T.LANGUAGE) in
  (select SUBT.SIM_TAX_RULE_ID,
          SUBT.LANGUAGE
    from ZX_SIM_RULES_TL SUBB, ZX_SIM_RULES_TL SUBT
    where SUBB.SIM_TAX_RULE_ID = SUBT.SIM_TAX_RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TAX_RULE_NAME <> SUBT.TAX_RULE_NAME
        ));

  insert into ZX_SIM_RULES_TL (
    SIM_TAX_RULE_ID,
    TAX_RULE_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  select
    B.SIM_TAX_RULE_ID,
    B.TAX_RULE_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ZX_SIM_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ZX_SIM_RULES_TL T
    where T.SIM_TAX_RULE_ID = B.SIM_TAX_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end ADD_LANGUAGE;

END ZX_SIM_RULES_PKG;

/
