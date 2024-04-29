--------------------------------------------------------
--  DDL for Package ZX_PROCESS_RESULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_PROCESS_RESULTS_PKG" AUTHID CURRENT_USER as
/* $Header: zxdprocessrsltss.pls 120.3 2003/12/19 03:51:43 ssekuri ship $ */

TYPE T_CONTENT_OWNER_ID is TABLE of zx_process_results.content_owner_id%type
                           index by binary_integer;
TYPE T_CONDITION_GROUP_ID is TABLE of zx_process_results.condition_group_id%type
                    index by binary_integer;
TYPE T_CONDITION_GROUP_CODE
                 is TABLE of zx_process_results.condition_group_code%type
                    index by binary_integer;
TYPE T_TAX_RULE_ID is TABLE of zx_process_results.tax_rule_id%type
                    index by binary_integer;
TYPE T_PRIORITY is TABLE of zx_process_results.priority%type
                    index by binary_integer;
TYPE T_RESULT_TYPE is TABLE of zx_process_results.Result_Type_Code%type
                    index by binary_integer;
TYPE T_TAX_STATUS_CODE is TABLE of zx_process_results.tax_status_code%type
                    index by binary_integer;
TYPE T_NUMERIC_RESULT is TABLE of zx_process_results.numeric_result%type
                    index by binary_integer;
TYPE T_ALPHANUMERIC_RESULT
                 is TABLE of zx_process_results.alphanumeric_result%type
                    index by binary_integer;
TYPE T_RESULT_API is TABLE of zx_process_results.result_api%type
                    index by binary_integer;
TYPE T_STATUS_RESULT is TABLE of zx_process_results.status_result%type
                    index by binary_integer;
TYPE T_RATE_RESULT is TABLE of zx_process_results.rate_result%type
                    index by binary_integer;
TYPE T_LEGAL_MESSAGE_CODE is TABLE of zx_process_results.legal_message_code%type
                    index by binary_integer;
TYPE T_MIN_TAX_AMT is TABLE of zx_process_results.min_tax_amt%type
                    index by binary_integer;
TYPE T_MAX_TAX_AMT is TABLE of zx_process_results.max_tax_amt%type
                    index by binary_integer;
TYPE T_MIN_TAXABLE_BASIS is TABLE of zx_process_results.min_taxable_basis%type
                    index by binary_integer;
TYPE T_MAX_TAXABLE_BASIS is TABLE of zx_process_results.max_taxable_basis%type
                    index by binary_integer;
TYPE T_MIN_TAX_RATE is TABLE of zx_process_results.min_tax_rate%type
                    index by binary_integer;
TYPE T_MAX_TAX_RATE is TABLE of zx_process_results.max_tax_rate%type
                    index by binary_integer;
TYPE T_ENABLED_FLG is TABLE of zx_process_results.Enabled_Flag%type
                    index by binary_integer;
TYPE T_ALLOW_EXEMPTIONS is TABLE of zx_process_results.Allow_Exemptions_Flag%type
                    index by binary_integer;
TYPE T_ALLOW_EXCEPTIONS is TABLE of zx_process_results.Allow_Exceptions_Flag%type
                    index by binary_integer;
TYPE T_RECORD_TYPE is TABLE of zx_process_results.Record_Type_Code%type
                    index by binary_integer;

PROCEDURE bulk_insert_process_results (
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
  X_Record_Type_Code               IN t_record_type) ;

end ZX_PROCESS_RESULTS_PKG;

 

/
