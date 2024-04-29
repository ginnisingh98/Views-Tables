--------------------------------------------------------
--  DDL for Package ZX_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_CONDITIONS_PKG" AUTHID CURRENT_USER as
/* $Header: zxdconditionss.pls 120.3 2003/12/19 20:28:46 ssekuri ship $ */

TYPE T_DETERMINING_FACTOR_CODE
                   is TABLE of zx_conditions.determining_factor_code%type
                      index by binary_integer;
TYPE T_CONDITION_GROUP_CODE is TABLE of zx_conditions.condition_group_code%type
                               index by binary_integer;
TYPE T_TAX_PARAMETER_CODE is TABLE of zx_conditions.tax_parameter_code%type
                               index by binary_integer;
TYPE T_DATA_TYPE is TABLE of zx_conditions.DATA_TYPE_CODE%type
                               index by binary_integer;
TYPE T_DETERMINING_FACTOR_CLASS
                   is TABLE of zx_conditions.Determining_Factor_Class_Code%type
                      index by binary_integer;
TYPE T_DETERMINING_FACTOR_CQ
                   is TABLE of zx_conditions.DETERMINING_FACTOR_CQ_CODE%type
                      index by binary_integer;
TYPE T_OPERATOR is TABLE of zx_conditions.OPERATOR_CODE%type
                               index by binary_integer;
TYPE T_RECORD_TYPE is TABLE of zx_conditions.Record_Type_Code%type
                               index by binary_integer;
TYPE T_IGNORE_FLG is TABLE of zx_conditions.Ignore_Flag%type
                               index by binary_integer;
TYPE T_NUMERIC_VALUE is TABLE of zx_conditions.numeric_value%type
                               index by binary_integer;
TYPE T_DATE_VALUE is TABLE of zx_conditions.date_value%type
                               index by binary_integer;
TYPE T_ALPHANUMERIC_VALUE is TABLE of zx_conditions.alphanumeric_value%type
                               index by binary_integer;
TYPE T_VALUE_LOW is TABLE of zx_conditions.value_low%type
                               index by binary_integer;
TYPE T_VALUE_HIGH is TABLE of zx_conditions.value_high%type
                               index by binary_integer;

PROCEDURE bulk_insert_conditions (
  X_DETERMINING_FACTOR_CODE      IN t_determining_factor_code,
  X_CONDITION_GROUP_CODE         IN t_condition_group_code,
  X_TAX_PARAMETER_CODE           IN t_tax_parameter_code,
  X_DATA_TYPE_CODE               IN t_data_type,
  X_DETERMINING_FACTOR_CLASS_COD IN t_determining_factor_class,
  X_DETERMINING_FACTOR_CQ_CODE   IN t_determining_factor_cq,
  X_OPERATOR_CODE                IN t_operator,
  X_RECORD_TYPE_CODE             IN t_record_type,
  X_IGNORE_FLAG                  IN t_ignore_flg,
  X_NUMERIC_VALUE                IN t_numeric_value,
  X_DATE_VALUE                   IN t_date_value,
  X_ALPHANUMERIC_VALUE           IN t_alphanumeric_value,
  X_VALUE_LOW                    IN t_value_low,
  X_VALUE_HIGH                   IN t_value_high);

end ZX_CONDITIONS_PKG;

 

/
