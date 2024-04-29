--------------------------------------------------------
--  DDL for Package ZX_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: zxdruless.pls 120.7 2005/10/21 22:07:20 rsanthan ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TAX_RULE_ID in NUMBER,
  X_TAX_RULE_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_SERVICE_TYPE_CODE in VARCHAR2,
  X_RECOVERY_TYPE_CODE in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_System_Default_Flag in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_Record_Type_Code in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_TAX_RULE_NAME in VARCHAR2,
  X_TAX_RULE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_Enabled_Flag in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_OWNER_ID in NUMBER,
  X_DET_FACTOR_TEMPL_CODE in VARCHAR2,
  X_EVENT_CLASS_MAPPING_ID in NUMBER,
  X_TAX_EVENT_CLASS_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DETERMINING_FACTOR_CQ_CODE               IN VARCHAR2,
  X_GEOGRAPHY_TYPE                           IN VARCHAR2,
  X_GEOGRAPHY_ID                             IN NUMBER,
  X_TAX_LAW_REF_CODE                         IN VARCHAR2,
  X_TAX_LAW_REF_DESC                         IN VARCHAR2,
  X_LAST_UPDATE_MODE_FLAG                    IN VARCHAR2,
  X_NEVER_BEEN_ENABLED_FLAG                  IN VARCHAR2);

procedure LOCK_ROW (
  X_TAX_RULE_ID in NUMBER,
  X_TAX_RULE_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_SERVICE_TYPE_CODE in VARCHAR2,
  X_RECOVERY_TYPE_CODE in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_System_Default_Flag in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_Record_Type_Code in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_TAX_RULE_NAME in VARCHAR2,
  X_TAX_RULE_DESC in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_Enabled_Flag in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_OWNER_ID in NUMBER,
  X_DET_FACTOR_TEMPL_CODE in VARCHAR2,
  X_EVENT_CLASS_MAPPING_ID in NUMBER,
  X_TAX_EVENT_CLASS_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
    X_DETERMINING_FACTOR_CQ_CODE               IN VARCHAR2,
  X_GEOGRAPHY_TYPE                           IN VARCHAR2,
  X_GEOGRAPHY_ID                             IN NUMBER,
  X_TAX_LAW_REF_CODE                         IN VARCHAR2,
  X_TAX_LAW_REF_DESC                         IN VARCHAR2,
  X_LAST_UPDATE_MODE_FLAG                    IN VARCHAR2,
  X_NEVER_BEEN_ENABLED_FLAG                  IN VARCHAR2);

procedure UPDATE_ROW (
  X_TAX_RULE_ID in NUMBER,
  X_TAX_RULE_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_SERVICE_TYPE_CODE in VARCHAR2,
  X_RECOVERY_TYPE_CODE in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_System_Default_Flag in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_Record_Type_Code in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_TAX_RULE_NAME in VARCHAR2,
  X_TAX_RULE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_Enabled_Flag in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_OWNER_ID in NUMBER,
  X_DET_FACTOR_TEMPL_CODE in VARCHAR2,
  X_EVENT_CLASS_MAPPING_ID in NUMBER,
  X_TAX_EVENT_CLASS_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
    X_DETERMINING_FACTOR_CQ_CODE               IN VARCHAR2,
  X_GEOGRAPHY_TYPE                           IN VARCHAR2,
  X_GEOGRAPHY_ID                             IN NUMBER,
  X_TAX_LAW_REF_CODE                         IN VARCHAR2,
  X_TAX_LAW_REF_DESC                         IN VARCHAR2,
  X_LAST_UPDATE_MODE_FLAG                    IN VARCHAR2,
  X_NEVER_BEEN_ENABLED_FLAG                  IN VARCHAR2);
procedure DELETE_ROW (
  X_TAX_RULE_ID in NUMBER);

procedure ADD_LANGUAGE;
TYPE T_TAX_RULE_ID is TABLE of zx_rules_b.tax_rule_id%type
                      index by binary_integer;
TYPE T_TAX_RULE_CODE is TABLE of zx_rules_b.tax_rule_code%type
                        index by binary_integer;
TYPE T_TAX is TABLE of zx_rules_b.tax%type
              index by binary_integer;
TYPE T_TAX_REGIME_CODE is TABLE of zx_rules_b.tax_regime_code%type
                          index by binary_integer;
TYPE T_SERVICE_TYPE_CODE is TABLE of zx_rules_b.service_type_code%type
                            index by binary_integer;
TYPE T_RECOVERY_TYPE_CODE is TABLE of zx_rules_b.recovery_type_code%type
                             index by binary_integer;
TYPE T_PRIORITY is TABLE of zx_rules_b.priority%type
                   index by binary_integer;
TYPE T_SYSTEM_DEFAULT_FLG is TABLE of zx_rules_b.System_Default_Flag%type
                             index by binary_integer;
TYPE T_EFFECTIVE_FROM is TABLE of zx_rules_b.effective_from%type
                         index by binary_integer;
TYPE T_EFFECTIVE_TO is TABLE of zx_rules_b.effective_to%type
                       index by binary_integer;
TYPE T_RECORD_TYPE is TABLE of zx_rules_b.Record_Type_Code%type
                      index by binary_integer;
TYPE T_TAX_RULE_NAME is TABLE of zx_rules_tl.tax_rule_name%type
                        index by binary_integer;
TYPE T_TAX_RULE_DESC is TABLE of zx_rules_tl.tax_rule_desc%type
                        index by binary_integer;
TYPE T_ENABLED_FLG is TABLE of zx_rules_b.Enabled_Flag%type
                      index by binary_integer;
TYPE T_APPLICATION_ID is TABLE of zx_rules_b.application_id%type
                         index by binary_integer;
TYPE T_CONTENT_OWNER_ID is TABLE of zx_rules_b.content_owner_id%type
                           index by binary_integer;
TYPE T_DET_FACTOR_TEMPL_CODE is TABLE of zx_rules_b.det_factor_templ_code%type
                                index by binary_integer;

PROCEDURE bulk_insert_rules (
  X_TAX_RULE_ID            IN t_tax_rule_id,
  X_TAX_RULE_CODE          IN t_tax_rule_code,
  X_TAX                    IN t_tax,
  X_TAX_REGIME_CODE        IN t_tax_regime_code,
  X_SERVICE_TYPE_CODE      IN t_service_type_code,
  X_RECOVERY_TYPE_CODE     IN t_recovery_type_code,
  X_PRIORITY               IN t_priority,
  X_System_Default_Flag     IN t_system_default_flg,
  X_EFFECTIVE_FROM         IN t_effective_from,
  X_EFFECTIVE_TO           IN t_effective_to,
  X_Record_Type_Code            IN t_record_type,
  X_TAX_RULE_NAME          IN t_tax_rule_name,
  X_TAX_RULE_DESC          IN t_tax_rule_desc,
  X_Enabled_Flag            IN t_enabled_flg,
  X_APPLICATION_ID         IN t_application_id,
  X_CONTENT_OWNER_ID       IN t_content_owner_id,
  X_DET_FACTOR_TEMPL_CODE  IN t_det_factor_templ_code);

end ZX_RULES_PKG;

 

/
