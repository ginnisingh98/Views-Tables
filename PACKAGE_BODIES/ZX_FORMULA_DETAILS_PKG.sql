--------------------------------------------------------
--  DDL for Package Body ZX_FORMULA_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_FORMULA_DETAILS_PKG" as
/* $Header: zxdformuladtlb.pls 120.2 2003/12/19 03:51:25 ssekuri ship $ */

procedure bulk_insert_formula_details (
  X_FORMULA_ID                     IN t_formula_id,
  X_COMPOUNDING_TAX                IN t_compounding_tax,
  X_COMPOUNDING_TAX_REGIME_CODE    IN t_compounding_tax_regime_code,
  X_Compounding_Type_Code               IN t_compounding_type,
  X_Record_Type_Code                    IN t_record_type,
  X_ATTRIBUTE_CATEGORY             IN t_attribute_category,
  X_ATTRIBUTE1                     IN t_attribute1,
  X_ATTRIBUTE2                     IN t_attribute2,
  X_ATTRIBUTE3                     IN t_attribute3,
  X_ATTRIBUTE4                     IN t_attribute4,
  X_ATTRIBUTE5                     IN t_attribute5,
  X_ATTRIBUTE6                     IN t_attribute6,
  X_ATTRIBUTE7                     IN t_attribute7,
  X_ATTRIBUTE8                     IN t_attribute8,
  X_ATTRIBUTE9                     IN t_attribute9,
  X_ATTRIBUTE10                    IN t_attribute10,
  X_ATTRIBUTE11                    IN t_attribute11,
  X_ATTRIBUTE12                    IN t_attribute12,
  X_ATTRIBUTE13                    IN t_attribute13,
  X_ATTRIBUTE14                    IN t_attribute14,
  X_ATTRIBUTE15                    IN t_attribute15,
  X_ATTRIBUTE16                    IN t_attribute16,
  X_ATTRIBUTE17                    IN t_attribute17,
  X_ATTRIBUTE18                    IN t_attribute18,
  X_ATTRIBUTE19                    IN t_attribute19,
  X_ATTRIBUTE20                    IN t_attribute20) is

begin

  if x_formula_id.count <> 0 then
     forall i in x_formula_id.first..x_formula_id.last
       INSERT INTO ZX_FORMULA_DETAILS (FORMULA_DETAIL_ID,
                                       FORMULA_ID,
                                       COMPOUNDING_TAX,
                                       COMPOUNDING_TAX_REGIME_CODE,
                                       Compounding_Type_Code,
                                       Record_Type_Code,
                                       ATTRIBUTE_CATEGORY,
                                       ATTRIBUTE1,
                                       ATTRIBUTE2,
                                       ATTRIBUTE3,
                                       ATTRIBUTE4,
                                       ATTRIBUTE5,
                                       ATTRIBUTE6,
                                       ATTRIBUTE7,
                                       ATTRIBUTE8,
                                       ATTRIBUTE9,
                                       ATTRIBUTE10,
                                       ATTRIBUTE11,
                                       ATTRIBUTE12,
                                       ATTRIBUTE13,
                                       ATTRIBUTE14,
                                       ATTRIBUTE15,
                                       ATTRIBUTE16,
                                       ATTRIBUTE17,
                                       ATTRIBUTE18,
                                       ATTRIBUTE19,
                                       ATTRIBUTE20,
                                       CREATED_BY             ,
                                       CREATION_DATE          ,
                                       LAST_UPDATED_BY        ,
                                       LAST_UPDATE_DATE       ,
                                       LAST_UPDATE_LOGIN      ,
                                       REQUEST_ID             ,
                                       PROGRAM_APPLICATION_ID ,
                                       PROGRAM_ID             ,
                                       PROGRAM_LOGIN_ID)
                               values (zx_formula_details_s.nextval,
                                       X_FORMULA_ID(i),
                                       X_COMPOUNDING_TAX(i),
                                       X_COMPOUNDING_TAX_REGIME_CODE(i),
                                       X_Compounding_Type_Code(i),
                                       X_Record_Type_Code(i),
                                       X_ATTRIBUTE_CATEGORY(i),
                                       X_ATTRIBUTE1(i),
                                       X_ATTRIBUTE2(i),
                                       X_ATTRIBUTE3(i),
                                       X_ATTRIBUTE4(i),
                                       X_ATTRIBUTE5(i),
                                       X_ATTRIBUTE6(i),
                                       X_ATTRIBUTE7(i),
                                       X_ATTRIBUTE8(i),
                                       X_ATTRIBUTE9(i),
                                       X_ATTRIBUTE10(i),
                                       X_ATTRIBUTE11(i),
                                       X_ATTRIBUTE12(i),
                                       X_ATTRIBUTE13(i),
                                       X_ATTRIBUTE14(i),
                                       X_ATTRIBUTE15(i),
                                       X_ATTRIBUTE16(i),
                                       X_ATTRIBUTE17(i),
                                       X_ATTRIBUTE18(i),
                                       X_ATTRIBUTE19(i),
                                       X_ATTRIBUTE20(i),
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

end bulk_insert_formula_details;

end ZX_FORMULA_DETAILS_PKG;

/
