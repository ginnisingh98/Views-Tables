--------------------------------------------------------
--  DDL for Package Body ZX_DET_FACTOR_TEMPL_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_DET_FACTOR_TEMPL_DTL_PKG" as
/* $Header: zxddetfactordtlb.pls 120.3 2003/12/19 20:59:38 ssekuri ship $ */

procedure bulk_insert_df_templ_dtl (
  X_DET_FACTOR_TEMPL_ID         IN t_det_factor_templ_id,
  X_Determining_Factor_Class_Co IN t_determining_factor_class,
  X_Determining_Factor_Cq_Code  IN t_determining_factor_cq,
  X_DETERMINING_FACTOR_CODE     IN t_determining_factor_code,
  X_Required_Flag               IN t_required_flg,
  X_Record_Type_Code                IN t_record_type) is

begin

  if x_det_factor_templ_id.count <> 0 then
     forall i in x_det_factor_templ_id.first..x_det_factor_templ_id.last
       insert into ZX_DET_FACTOR_TEMPL_DTL (DET_FACTOR_TEMPL_DTL_ID,
                                            DET_FACTOR_TEMPL_ID,
                                            Determining_Factor_Class_Code,
                                            Determining_Factor_Cq_Code,
                                            DETERMINING_FACTOR_CODE,
                                            Required_Flag,
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
                                    values (zx_det_factor_templ_dtl_s.nextval,
                                            X_DET_FACTOR_TEMPL_ID(i),
                                            X_Determining_Factor_Class_Co(i),
                                            X_Determining_Factor_Cq_Code(i),
                                            X_DETERMINING_FACTOR_CODE(i),
                                            X_Required_Flag(i),
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

end bulk_insert_df_templ_dtl;

end ZX_DET_FACTOR_TEMPL_DTL_PKG;

/
