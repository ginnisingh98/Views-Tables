--------------------------------------------------------
--  DDL for Package ZX_DET_FACTOR_TEMPL_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_DET_FACTOR_TEMPL_DTL_PKG" AUTHID CURRENT_USER as
/* $Header: zxddetfactordtls.pls 120.3 2003/12/19 20:59:34 ssekuri ship $ */

TYPE T_DET_FACTOR_TEMPL_ID
               is TABLE of zx_det_factor_templ_dtl.det_factor_templ_id%type
                  index by binary_integer;
TYPE T_DETERMINING_FACTOR_CLASS
               is TABLE of zx_det_factor_templ_dtl.Determining_Factor_Class_Code%type
                  index by binary_integer;
TYPE T_DETERMINING_FACTOR_CQ
               is TABLE of zx_det_factor_templ_dtl.Determining_Factor_Cq_Code%type
                  index by binary_integer;
TYPE T_DETERMINING_FACTOR_CODE
               is TABLE of zx_det_factor_templ_dtl.determining_factor_code%type
                  index by binary_integer;
TYPE T_REQUIRED_FLG is TABLE of zx_det_factor_templ_dtl.Required_Flag%type
                     index by binary_integer;
TYPE T_RECORD_TYPE is TABLE of zx_det_factor_templ_dtl.Record_Type_Code%type
                     index by binary_integer;

procedure bulk_insert_df_templ_dtl (
  X_DET_FACTOR_TEMPL_ID         IN t_det_factor_templ_id,
  X_Determining_Factor_Class_Co IN t_determining_factor_class,
  X_Determining_Factor_Cq_Code  IN t_determining_factor_cq,
  X_DETERMINING_FACTOR_CODE     IN t_determining_factor_code,
  X_Required_Flag               IN t_required_flg,
  X_Record_Type_Code            IN t_record_type) ;

end ZX_DET_FACTOR_TEMPL_DTL_PKG;

 

/
