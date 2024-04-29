--------------------------------------------------------
--  DDL for Package Body ZX_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_CONDITIONS_PKG" as
/* $Header: zxdconditionsb.pls 120.3 2003/12/19 20:28:52 ssekuri ship $ */

procedure bulk_insert_conditions (
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
  X_VALUE_HIGH                   IN t_value_high) is

begin
  If x_determining_factor_code.count <> 0 then
     forall i in x_determining_factor_code.first..x_determining_factor_code.last
       INSERT INTO ZX_CONDITIONS (CONDITION_ID,
                                  DETERMINING_FACTOR_CODE,
                                  CONDITION_GROUP_CODE,
                                  TAX_PARAMETER_CODE,
                                  DATA_TYPE_CODE,
                                  DETERMINING_FACTOR_CLASS_CODE,
                                  DETERMINING_FACTOR_CQ_CODE,
                                  OPERATOR_CODE,
                                  RECORD_TYPE_CODE,
                                  IGNORE_FLAG,
                                  NUMERIC_VALUE,
                                  DATE_VALUE,
                                  ALPHANUMERIC_VALUE,
                                  VALUE_LOW,
                                  VALUE_HIGH,
                                  CREATED_BY             ,
                                  CREATION_DATE          ,
                                  LAST_UPDATED_BY        ,
                                  LAST_UPDATE_DATE       ,
                                  LAST_UPDATE_LOGIN      ,
                                  REQUEST_ID             ,
                                  PROGRAM_APPLICATION_ID ,
                                  PROGRAM_ID             ,
                                  PROGRAM_LOGIN_ID)
                          VALUES (zx_conditions_s.nextval,
                                  X_DETERMINING_FACTOR_CODE(i),
                                  X_CONDITION_GROUP_CODE(i),
                                  X_TAX_PARAMETER_CODE(i),
                                  X_DATA_TYPE_CODE(i),
                                  X_DETERMINING_FACTOR_CLASS_COD(i),
                                  X_DETERMINING_FACTOR_CQ_CODE(i),
                                  X_OPERATOR_CODE(i),
                                  X_RECORD_TYPE_CODE(i),
                                  X_IGNORE_FLAG(i),
                                  X_NUMERIC_VALUE(i),
                                  X_DATE_VALUE(i),
                                  X_ALPHANUMERIC_VALUE(i),
                                  X_VALUE_LOW(i),
                                  X_VALUE_HIGH(i),
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

end bulk_insert_conditions;

end ZX_CONDITIONS_PKG;

/
