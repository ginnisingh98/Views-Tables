--------------------------------------------------------
--  DDL for Package Body ZX_PROCESS_RESULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_PROCESS_RESULTS_PKG" as
/* $Header: zxdprocessrsltsb.pls 120.3 2003/12/19 03:51:40 ssekuri ship $ */

procedure bulk_insert_process_results (
  X_CONTENT_OWNER_ID          IN t_content_owner_id,
  X_CONDITION_GROUP_ID        IN t_condition_group_id,
  X_CONDITION_GROUP_CODE      IN t_condition_group_code,
  X_TAX_RULE_ID               IN t_tax_rule_id,
  X_PRIORITY                  IN t_priority,
  X_Result_Type_Code               IN t_result_type,
  X_TAX_STATUS_CODE           IN t_tax_status_code,
  X_NUMERIC_RESULT            IN t_numeric_result,
  X_ALPHANUMERIC_RESULT       IN t_alphanumeric_result,
  X_RESULT_API                IN t_result_api,
  X_STATUS_RESULT             IN t_status_result,
  X_RATE_RESULT               IN t_rate_result,
  X_LEGAL_MESSAGE_CODE        IN t_legal_message_code,
  X_MIN_TAX_AMT               IN t_min_tax_amt,
  X_MAX_TAX_AMT               IN t_max_tax_amt,
  X_MIN_TAXABLE_BASIS         IN t_min_taxable_basis,
  X_MAX_TAXABLE_BASIS         IN t_max_taxable_basis,
  X_MIN_TAX_RATE              IN t_min_tax_rate,
  X_MAX_TAX_RATE              IN t_max_tax_rate,
  X_Enabled_Flag               IN t_enabled_flg,
  X_Allow_Exemptions_Flag          IN t_allow_exemptions,
  X_Allow_Exceptions_Flag          IN t_allow_exceptions,
  X_Record_Type_Code               IN t_record_type) is

begin
  If x_tax_rule_id.count <> 0 then
     forall i in x_tax_rule_id.first..x_tax_rule_id.last
       INSERT INTO ZX_PROCESS_RESULTS (RESULT_ID,
                                       CONTENT_OWNER_ID,
                                       CONDITION_GROUP_ID,
                                       CONDITION_GROUP_CODE,
                                       TAX_RULE_ID,
                                       PRIORITY,
                                       Result_Type_Code,
                                       TAX_STATUS_CODE,
                                       NUMERIC_RESULT,
                                       ALPHANUMERIC_RESULT,
                                       RESULT_API,
                                       STATUS_RESULT,
                                       RATE_RESULT,
                                       LEGAL_MESSAGE_CODE,
                                       MIN_TAX_AMT,
                                       MAX_TAX_AMT,
                                       MIN_TAXABLE_BASIS,
                                       MAX_TAXABLE_BASIS,
                                       MIN_TAX_RATE,
                                       MAX_TAX_RATE,
                                       Enabled_Flag,
                                       Allow_Exemptions_Flag,
                                       Allow_Exceptions_Flag,
                                       Record_Type_Code,
                                       CREATED_BY             ,
                                       CREATION_DATE          ,
                                       LAST_UPDATED_BY        ,
                                       LAST_UPDATE_DATE       ,
                                       LAST_UPDATE_LOGIN      ,
                                       REQUEST_ID             ,
                                       PROGRAM_APPLICATION_ID ,
                                       PROGRAM_ID             ,
                                       PROGRAM_LOGIN_ID)
                               values (zx_process_results_s.nextval,
                                       X_CONTENT_OWNER_ID(i),
                                       X_CONDITION_GROUP_ID(i),
                                       X_CONDITION_GROUP_CODE(i),
                                       X_TAX_RULE_ID(i),
                                       X_PRIORITY(i),
                                       X_Result_Type_Code(i),
                                       X_TAX_STATUS_CODE(i),
                                       X_NUMERIC_RESULT(i),
                                       X_ALPHANUMERIC_RESULT(i),
                                       X_RESULT_API(i),
                                       X_STATUS_RESULT(i),
                                       X_RATE_RESULT(i),
                                       X_LEGAL_MESSAGE_CODE(i),
                                       X_MIN_TAX_AMT(i),
                                       X_MAX_TAX_AMT(i),
                                       X_MIN_TAXABLE_BASIS(i),
                                       X_MAX_TAXABLE_BASIS(i),
                                       X_MIN_TAX_RATE(i),
                                       X_MAX_TAX_RATE(i),
                                       X_Enabled_Flag(i),
                                       X_Allow_Exemptions_Flag(i),
                                       X_Allow_Exceptions_Flag(i),
                                       X_Record_Type_Code(i),
                                       fnd_global.user_id         ,
                                       sysdate                    ,
                                       fnd_global.user_id         ,
                                       sysdate                    ,
                                       fnd_global.conc_login_id   ,
                                       fnd_global.conc_request_id ,
                                       fnd_global.prog_appl_id    ,
                                       fnd_global.conc_program_id ,
                                       fnd_global.conc_login_id
                                       );

  end if;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end bulk_insert_process_results;

end ZX_PROCESS_RESULTS_PKG;

/
