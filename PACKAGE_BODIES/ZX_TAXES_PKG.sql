--------------------------------------------------------
--  DDL for Package Body ZX_TAXES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAXES_PKG" as
/* $Header: zxctaxesb.pls 120.26 2006/07/28 12:44:18 shmangal ship $ */
/***Private Function - to return the RECOVERY_NAME from FndLookups**/
function get_lookup_meaning(
  p_lookup_type  VARCHAR2,
  p_lookup_code VARCHAR2
)
RETURN VARCHAR2
IS
CURSOR c_get_meaning is
  SELECT MEANING
  FROM   FND_LOOKUPS
  WHERE  LOOKUP_TYPE = p_lookup_type
  AND    LOOKUP_CODE = p_lookup_code;
l_lookup_meaning VARCHAR2(80);
begin
  OPEN c_get_meaning;
  FETCH c_get_meaning into l_lookup_meaning;
  CLOSE c_get_meaning;
  RETURN l_lookup_meaning;
end get_lookup_meaning;
procedure insert_recovery(
  p_tax IN VARCHAR2,
  p_tax_regime_code IN VARCHAR2,
  p_recovery_type_code IN VARCHAR2,
  p_effective_from IN DATE
)
IS
l_recovery_name VARCHAR2(80);
l_seq_val NUMBER;
l_row_id VARCHAR2(80);
begin
  SELECT Zx_Recovery_Types_B_S.nextval into l_seq_val
  FROM DUAL;
  l_recovery_name := get_lookup_meaning('ZX_RECOVERY_TYPES',
  					p_recovery_type_code
  				       );
  ZX_RECOVERY_TYPES_PKG.INSERT_ROW(l_row_id,
  				   l_seq_val,
  				   p_recovery_type_code,
  				   p_tax_regime_code,
  				   p_tax,
  				   'Y',
  				   p_effective_from,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   null,
  				   l_recovery_name,
  				   null,
  				   sysdate,
  				   FND_GLOBAL.USER_ID,
  				   SYSDATE,
  				   FND_GLOBAL.USER_ID,
  				   FND_GLOBAL.LOGIN_ID
  				   );
end insert_recovery;
/*delete recovery - to remove recovery types from zx_recovery_types_vl*/
procedure delete_recovery(
  p_tax IN VARCHAR2,
  p_tax_regime_code IN VARCHAR2,
  p_recovery_type_code IN VARCHAR2
)
is
CURSOR c_get_recovery_id is
SELECT  RECOVERY_TYPE_ID
FROM 	ZX_RECOVERY_TYPES_VL
WHERE	TAX = p_tax
AND	TAX_REGIME_CODE = p_tax_regime_code
AND	RECOVERY_TYPE_CODE = p_recovery_type_code;
l_recovery_type_id NUMBER;
begin
  OPEN c_get_recovery_id;
  FETCH c_get_recovery_id into l_recovery_type_id;
  CLOSE c_get_recovery_id;
  ZX_RECOVERY_TYPES_PKG.DELETE_ROW(l_recovery_type_id);
end delete_recovery;
procedure update_jurisdiction(
  p_tax VARCHAR2,
  p_old_rep_tax_authority_id NUMBER,
  p_old_coll_tax_authority_id NUMBER,
  p_new_rep_tax_authority_id NUMBER,
  p_new_coll_tax_authority_id NUMBER
)
is
CURSOR c_get_rep_coll_ids is
SELECT	REP_TAX_AUTHORITY_ID,
	COLL_TAX_AUTHORITY_ID,
	TAX_JURISDICTION_CODE
FROM	ZX_JURISDICTIONS_VL
WHERE	TAX = p_tax;
l_rep_coll_ids c_get_rep_coll_ids%ROWTYPE;
l_rep_tax_authority_id NUMBER := null;
l_coll_tax_authority_id NUMBER := null;
l_update_required BOOLEAN := FALSE;
BEGIN
  open c_get_rep_coll_ids;
  fetch c_get_rep_coll_ids into l_rep_coll_ids;
  loop
    exit when c_get_rep_coll_ids%NOTFOUND;
    l_update_required := FALSE;
     IF (NVL(l_rep_coll_ids.REP_TAX_AUTHORITY_ID,-99) = NVL(p_old_rep_tax_authority_id,-99)) THEN
        l_rep_tax_authority_id:=NVL(p_new_rep_tax_authority_id,null);
        l_update_required := TRUE;
     ELSE
        l_rep_tax_authority_id := l_rep_coll_ids.REP_TAX_AUTHORITY_ID;
     END IF;
    IF (NVL(l_rep_coll_ids.COLL_TAX_AUTHORITY_ID,-99) = NVL(p_old_coll_tax_authority_id,-99)) THEN
       l_coll_tax_authority_id:= NVL(p_new_coll_tax_authority_id,null);
       l_update_required := TRUE;
    ELSE
       l_coll_tax_authority_id:=l_rep_coll_ids.COLL_TAX_AUTHORITY_ID;
    END IF;
    IF l_update_required THEN
          UPDATE	ZX_JURISDICTIONS_B
          SET 	        REP_TAX_AUTHORITY_ID  = l_rep_tax_authority_id,
		        COLL_TAX_AUTHORITY_ID = l_coll_tax_authority_id
           WHERE	TAX = p_tax
           AND
        		TAX_JURISDICTION_CODE = l_rep_coll_ids.TAX_JURISDICTION_CODE;
    End if;
    fetch c_get_rep_coll_ids into l_rep_coll_ids;
end loop;
END update_jurisdiction;
procedure update_registration(
  p_tax_regime_code VARCHAR2,
  p_tax VARCHAR2,
  p_old_rep_tax_authority_id NUMBER,
  p_old_coll_tax_authority_id NUMBER,
  p_new_rep_tax_authority_id NUMBER,
  p_new_coll_tax_authority_id NUMBER
)
is
CURSOR c_get_reg_rep_coll_ids is
SELECT  REP_TAX_AUTHORITY_ID,
        COLL_TAX_AUTHORITY_ID,
	REGISTRATION_ID
FROM    ZX_REGISTRATIONS
WHERE   TAX_REGIME_CODE = p_tax_regime_code
AND	TAX = p_tax
AND     TAX_JURISDICTION_CODE IS NULL;
l_rep_coll_ids c_get_reg_rep_coll_ids%ROWTYPE;
l_rep_tax_authority_id NUMBER := null;
l_coll_tax_authority_id NUMBER := null;
l_update_required BOOLEAN := FALSE;
BEGIN
  open c_get_reg_rep_coll_ids;
  fetch c_get_reg_rep_coll_ids into l_rep_coll_ids;
  loop
    exit when c_get_reg_rep_coll_ids%NOTFOUND;
    l_update_required := FALSE;
     IF (NVL(l_rep_coll_ids.REP_TAX_AUTHORITY_ID,-99) = NVL(p_old_rep_tax_authority_id,-99)) THEN
        l_rep_tax_authority_id:=NVL(p_new_rep_tax_authority_id,null);
        l_update_required := TRUE;
     ELSE
        l_rep_tax_authority_id := l_rep_coll_ids.REP_TAX_AUTHORITY_ID;
     END IF;
    IF (NVL(l_rep_coll_ids.COLL_TAX_AUTHORITY_ID,-99) = NVL(p_old_coll_tax_authority_id,-99)) THEN
       l_coll_tax_authority_id:= NVL(p_new_coll_tax_authority_id,null);
       l_update_required := TRUE;
    ELSE
       l_coll_tax_authority_id:=l_rep_coll_ids.COLL_TAX_AUTHORITY_ID;
    END IF;
    IF l_update_required THEN
          UPDATE        ZX_REGISTRATIONS
          SET           REP_TAX_AUTHORITY_ID  = l_rep_tax_authority_id,
                        COLL_TAX_AUTHORITY_ID = l_coll_tax_authority_id
          WHERE         REGISTRATION_ID = l_rep_coll_ids.REGISTRATION_ID;
    End if;
    fetch c_get_reg_rep_coll_ids into l_rep_coll_ids;
end loop;
END update_registration;
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_Recovery_Rate_Override_Flag VARCHAR2,
  X_TAX_ID in NUMBER,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_Has_Tax_Point_Date_Rule_Flag in VARCHAR2,
  X_Print_On_Invoice_Flag in VARCHAR2,
  X_Use_Legal_Msg_Flag in VARCHAR2,
  X_Calc_Only_Flag in VARCHAR2,
  X_PRIMARY_RECOVERY_TYPE_CODE in VARCHAR2,
  X_Primary_Rec_Type_Rule_Flag in VARCHAR2,
  X_SECONDARY_RECOVERY_TYPE_CODE in VARCHAR2,
  X_Secondary_Rec_Type_Rule_Flag in VARCHAR2,
  X_PRIMARY_REC_RATE_DET_RULE_FL in VARCHAR2,
  X_Sec_Rec_Rate_Det_Rule_Flag in VARCHAR2,
  X_Offset_Tax_Flag in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_Record_Type_Code in VARCHAR2,
  X_Allow_Rounding_Override_Flag in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_Has_Exch_Rate_Date_Rule_Flag in VARCHAR2,
  X_TAX in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX_TYPE_CODE in VARCHAR2,
  X_Allow_Manual_Entry_Flag in VARCHAR2,
  X_Allow_Tax_Override_Flag in VARCHAR2,
  X_MIN_TXBL_BSIS_THRSHLD in NUMBER,
  X_MAX_TXBL_BSIS_THRSHLD in NUMBER,
  X_MIN_TAX_RATE_THRSHLD in NUMBER,
  X_MAX_TAX_RATE_THRSHLD in NUMBER,
  X_MIN_TAX_AMT_THRSHLD in NUMBER,
  X_MAX_TAX_AMT_THRSHLD in NUMBER,
  X_COMPOUNDING_PRECEDENCE in NUMBER,
  X_PERIOD_SET_NAME in VARCHAR2,
  X_EXCHANGE_RATE_TYPE in VARCHAR2,
  X_TAX_CURRENCY_CODE in VARCHAR2,
  X_REP_TAX_AUTHORITY_ID in NUMBER,
  X_COLL_TAX_AUTHORITY_ID in NUMBER,
  X_TAX_PRECISION in NUMBER,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_Rounding_Rule_Code in VARCHAR2,
  X_Tax_Status_Rule_Flag in VARCHAR2,
  X_Tax_Rate_Rule_Flag in VARCHAR2,
  X_Def_Place_Of_Supply_Type_Cod in VARCHAR2,
  X_Place_Of_Supply_Rule_Flag in VARCHAR2,
  X_Applicability_Rule_Flag in VARCHAR2,
  X_Tax_Calc_Rule_Flag in VARCHAR2,
  X_Txbl_Bsis_Thrshld_Flag in VARCHAR2,
  X_Tax_Rate_Thrshld_Flag in VARCHAR2,
  X_Tax_Amt_Thrshld_Flag in VARCHAR2,
  X_Taxable_Basis_Rule_Flag in VARCHAR2,
  X_Def_Inclusive_Tax_Flag in VARCHAR2,
  X_Thrshld_Grouping_Lvl_Code in VARCHAR2,
  X_Thrshld_Chk_Tmplt_Code in VARCHAR2,
  X_Has_Other_Jurisdictions_Flag in VARCHAR2,
  X_Allow_Exemptions_Flag in VARCHAR2,
  X_Allow_Exceptions_Flag in VARCHAR2,
  X_Allow_Recoverability_Flag in VARCHAR2,
  X_DEF_TAX_CALC_FORMULA in VARCHAR2,
  X_Tax_Inclusive_Override_Flag in VARCHAR2,
  X_DEF_TAXABLE_BASIS_FORMULA in VARCHAR2,
  X_Def_Registr_Party_Type_Code in VARCHAR2,
  X_Registration_Type_Rule_Flag in VARCHAR2,
  X_Reporting_Only_Flag in VARCHAR2,
  X_Auto_Prvn_Flag in VARCHAR2,
  X_Live_For_Processing_Flag in VARCHAR2,
  X_Has_Detail_Tb_Thrshld_Flag in VARCHAR2,
  X_Has_Tax_Det_Date_Rule_Flag in VARCHAR2,
  X_TAX_FULL_NAME in VARCHAR2,
  X_ZONE_GEOGRAPHY_TYPE in VARCHAR2,
  X_Def_Rec_Settlement_Option_Co in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_Regn_Num_Same_As_Le_Flag in VARCHAR2  ,
  X_Direct_Rate_Rule_Flag   in VARCHAR2,
  X_CONTENT_OWNER_ID in NUMBER,
  X_APPLIED_AMT_HANDLING_FLAG in VARCHAR2,
  X_PARENT_GEOGRAPHY_TYPE in VARCHAR2,
  X_PARENT_GEOGRAPHY_ID in NUMBER,
  X_ALLOW_MASS_CREATE_FLAG in VARCHAR2,
  X_SOURCE_TAX_FLAG in VARCHAR2,
  X_SPECIAL_INCLUSIVE_TAX_FLAG in VARCHAR2,
  X_DEF_PRIMARY_REC_RATE_CODE in VARCHAR2,
  X_DEF_SECONDARY_REC_RATE_CODE in VARCHAR2,
  X_ALLOW_DUP_REGN_NUM_FLAG in VARCHAR2,
  X_TAX_ACCOUNT_SOURCE_TAX in VARCHAR2,
  X_TAX_ACCOUNT_CREATE_METHOD_CO in VARCHAR2,
  X_OVERRIDE_GEOGRAPHY_TYPE in VARCHAR2,
  X_TAX_EXMPT_SOURCE_TAX in VARCHAR2,
  X_TAX_EXMPT_CR_METHOD_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LIVE_FOR_APPLICABILITY_FLAG in VARCHAR2,
  X_APPLICABLE_BY_DEFAULT_FLAG in VARCHAR2,
  X_LEGAL_REPORTING_STATUS_DEF_V in VARCHAR2
) is
  cursor C is select ROWID from ZX_TAXES_B
    where TAX_ID = X_TAX_ID
    ;
begin
  insert into ZX_TAXES_B (
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    Has_Tax_Point_Date_Rule_Flag,
    Print_On_Invoice_Flag,
    Use_Legal_Msg_Flag,
    Calc_Only_Flag,
    PRIMARY_RECOVERY_TYPE_CODE,
    Primary_Rec_Type_Rule_Flag,
    SECONDARY_RECOVERY_TYPE_CODE,
    Secondary_Rec_Type_Rule_Flag,
    Primary_Rec_Rate_Det_Rule_Flag,
    Sec_Rec_Rate_Det_Rule_Flag,
    Offset_Tax_Flag,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    Program_Login_Id,
    Record_Type_Code,
    Allow_Rounding_Override_Flag,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    Has_Exch_Rate_Date_Rule_Flag,
    Recovery_Rate_Override_Flag,
    TAX_ID,
    TAX,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    TAX_REGIME_CODE,
    TAX_TYPE_CODE,
    Allow_Manual_Entry_Flag,
    Allow_Tax_Override_Flag,
    MIN_TXBL_BSIS_THRSHLD,
    MAX_TXBL_BSIS_THRSHLD,
    MIN_TAX_RATE_THRSHLD,
    MAX_TAX_RATE_THRSHLD,
    MIN_TAX_AMT_THRSHLD,
    MAX_TAX_AMT_THRSHLD,
    COMPOUNDING_PRECEDENCE,
    PERIOD_SET_NAME,
    EXCHANGE_RATE_TYPE,
    TAX_CURRENCY_CODE,
    REP_TAX_AUTHORITY_ID,
    COLL_TAX_AUTHORITY_ID,
    TAX_PRECISION,
    MINIMUM_ACCOUNTABLE_UNIT,
    Rounding_Rule_Code,
    Tax_Status_Rule_Flag,
    Tax_Rate_Rule_Flag,
    Def_Place_Of_Supply_Type_Code,
    Place_Of_Supply_Rule_Flag,
    Applicability_Rule_Flag,
    Tax_Calc_Rule_Flag,
    Txbl_Bsis_Thrshld_Flag,
    Tax_Rate_Thrshld_Flag,
    Tax_Amt_Thrshld_Flag,
    Taxable_Basis_Rule_Flag,
    Def_Inclusive_Tax_Flag,
    Thrshld_Grouping_Lvl_Code,
    Thrshld_Chk_Tmplt_Code,
    Has_Other_Jurisdictions_Flag,
    Allow_Exemptions_Flag,
    Allow_Exceptions_Flag,
    Allow_Recoverability_Flag,
    DEF_TAX_CALC_FORMULA,
    Tax_Inclusive_Override_Flag,
    DEF_TAXABLE_BASIS_FORMULA,
    Def_Registr_Party_Type_Code,
    Registration_Type_Rule_Flag,
    Reporting_Only_Flag,
    Auto_Prvn_Flag,
    Live_For_Processing_Flag,
    Has_Detail_Tb_Thrshld_Flag,
    Has_Tax_Det_Date_Rule_Flag,
    Regn_Num_Same_As_Le_Flag,
    ZONE_GEOGRAPHY_TYPE,
    Def_Rec_Settlement_Option_Code,
    Direct_Rate_Rule_Flag   ,
    CONTENT_OWNER_ID ,
    APPLIED_AMT_HANDLING_FLAG,
    PARENT_GEOGRAPHY_TYPE,
    PARENT_GEOGRAPHY_ID,
    ALLOW_MASS_CREATE_FLAG,
    SOURCE_TAX_FLAG,
    SPECIAL_INCLUSIVE_TAX_FLAG,
    DEF_PRIMARY_REC_RATE_CODE,
    DEF_SECONDARY_REC_RATE_CODE,
    ALLOW_DUP_REGN_NUM_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    TAX_ACCOUNT_SOURCE_TAX,
    TAX_ACCOUNT_CREATE_METHOD_CODE,
    OVERRIDE_GEOGRAPHY_TYPE ,
    TAX_EXMPT_SOURCE_TAX,
    TAX_EXMPT_CR_METHOD_CODE,
    OBJECT_VERSION_NUMBER,
    LIVE_FOR_APPLICABILITY_FLAG,
    APPLICABLE_BY_DEFAULT_FLAG,
    LEGAL_REPORTING_STATUS_DEF_VAL
  ) values (
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_Has_Tax_Point_Date_Rule_Flag,
    X_Print_On_Invoice_Flag,
    X_Use_Legal_Msg_Flag,
    X_Calc_Only_Flag,
    X_PRIMARY_RECOVERY_TYPE_CODE,
    X_Primary_Rec_Type_Rule_Flag,
    X_SECONDARY_RECOVERY_TYPE_CODE,
    X_Secondary_Rec_Type_Rule_Flag,
    X_PRIMARY_REC_RATE_DET_RULE_FL,
    X_Sec_Rec_Rate_Det_Rule_Flag,
    X_Offset_Tax_Flag,
    X_REQUEST_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_Program_Login_Id,
    X_Record_Type_Code,
    X_Allow_Rounding_Override_Flag,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_Has_Exch_Rate_Date_Rule_Flag,
    X_Recovery_Rate_Override_Flag,
    X_TAX_ID,
    X_TAX,
    X_EFFECTIVE_FROM,
    X_EFFECTIVE_TO,
    X_TAX_REGIME_CODE,
    X_TAX_TYPE_CODE,
    X_Allow_Manual_Entry_Flag,
    X_Allow_Tax_Override_Flag,
    X_MIN_TXBL_BSIS_THRSHLD,
    X_MAX_TXBL_BSIS_THRSHLD,
    X_MIN_TAX_RATE_THRSHLD,
    X_MAX_TAX_RATE_THRSHLD,
    X_MIN_TAX_AMT_THRSHLD,
    X_MAX_TAX_AMT_THRSHLD,
    X_COMPOUNDING_PRECEDENCE,
    X_PERIOD_SET_NAME,
    X_EXCHANGE_RATE_TYPE,
    X_TAX_CURRENCY_CODE,
    X_REP_TAX_AUTHORITY_ID,
    X_COLL_TAX_AUTHORITY_ID,
    X_TAX_PRECISION,
    X_MINIMUM_ACCOUNTABLE_UNIT,
    X_Rounding_Rule_Code,
    X_Tax_Status_Rule_Flag,
    X_Tax_Rate_Rule_Flag,
    X_Def_Place_Of_Supply_Type_Cod,
    X_Place_Of_Supply_Rule_Flag,
    X_Applicability_Rule_Flag,
    X_Tax_Calc_Rule_Flag,
    X_Txbl_Bsis_Thrshld_Flag,
    X_Tax_Rate_Thrshld_Flag,
    X_Tax_Amt_Thrshld_Flag,
    X_Taxable_Basis_Rule_Flag,
    X_Def_Inclusive_Tax_Flag,
    X_Thrshld_Grouping_Lvl_Code,
    X_Thrshld_Chk_Tmplt_Code,
    X_Has_Other_Jurisdictions_Flag,
    X_Allow_Exemptions_Flag,
    X_Allow_Exceptions_Flag,
    X_Allow_Recoverability_Flag,
    X_DEF_TAX_CALC_FORMULA,
    X_Tax_Inclusive_Override_Flag,
    X_DEF_TAXABLE_BASIS_FORMULA,
    X_Def_Registr_Party_Type_Code,
    X_Registration_Type_Rule_Flag,
    X_Reporting_Only_Flag,
    X_Auto_Prvn_Flag,
    X_Live_For_Processing_Flag,
    X_Has_Detail_Tb_Thrshld_Flag,
    X_Has_Tax_Det_Date_Rule_Flag,
    X_Regn_Num_Same_As_Le_Flag,
    X_ZONE_GEOGRAPHY_TYPE,
    X_Def_Rec_Settlement_Option_Co,
    X_Direct_Rate_Rule_Flag   ,
    X_CONTENT_OWNER_ID,
    X_APPLIED_AMT_HANDLING_FLAG,
    X_PARENT_GEOGRAPHY_TYPE,
    X_PARENT_GEOGRAPHY_ID,
    X_ALLOW_MASS_CREATE_FLAG,
    X_SOURCE_TAX_FLAG,
    X_SPECIAL_INCLUSIVE_TAX_FLAG,
    X_DEF_PRIMARY_REC_RATE_CODE,
    X_DEF_SECONDARY_REC_RATE_CODE,
    X_ALLOW_DUP_REGN_NUM_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_TAX_ACCOUNT_SOURCE_TAX ,
    X_TAX_ACCOUNT_CREATE_METHOD_CO,
    X_OVERRIDE_GEOGRAPHY_TYPE,
    X_TAX_EXMPT_SOURCE_TAX,
    X_TAX_EXMPT_CR_METHOD_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_LIVE_FOR_APPLICABILITY_FLAG,
    X_APPLICABLE_BY_DEFAULT_FLAG,
    X_LEGAL_REPORTING_STATUS_DEF_V
  );
  insert into ZX_TAXES_TL (
    TAX_ID,
    TAX_FULL_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TAX_ID,
    X_TAX_FULL_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ZX_TAXES_TL T
    where T.TAX_ID = X_TAX_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
/*  if(X_PRIMARY_RECOVERY_TYPE_CODE is not null) then
    insert_recovery(
    		  X_TAX,
    		  X_TAX_REGIME_CODE,
    		  X_PRIMARY_RECOVERY_TYPE_CODE ,
		  X_EFFECTIVE_FROM
    		);
end if;
if(X_SECONDARY_RECOVERY_TYPE_CODE is not null) then
    insert_recovery(
    		  X_TAX,
    		  X_TAX_REGIME_CODE,
    		  X_SECONDARY_RECOVERY_TYPE_CODE ,
		  X_EFFECTIVE_FROM
    		  );
  end if;        */
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;
procedure LOCK_ROW (
  X_TAX_ID in NUMBER,
  X_Recovery_Rate_Override_Flag in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_Has_Tax_Point_Date_Rule_Flag in VARCHAR2,
  X_Print_On_Invoice_Flag in VARCHAR2,
  X_Use_Legal_Msg_Flag in VARCHAR2,
  X_Calc_Only_Flag in VARCHAR2,
  X_PRIMARY_RECOVERY_TYPE_CODE in VARCHAR2,
  X_Primary_Rec_Type_Rule_Flag in VARCHAR2,
  X_SECONDARY_RECOVERY_TYPE_CODE in VARCHAR2,
  X_Secondary_Rec_Type_Rule_Flag in VARCHAR2,
  X_PRIMARY_REC_RATE_DET_RULE_FL in VARCHAR2,
  X_Sec_Rec_Rate_Det_Rule_Flag in VARCHAR2,
  X_Offset_Tax_Flag in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_Record_Type_Code in VARCHAR2,
  X_Allow_Rounding_Override_Flag in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_Has_Exch_Rate_Date_Rule_Flag in VARCHAR2,
  X_TAX in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX_TYPE_CODE in VARCHAR2,
  X_Allow_Manual_Entry_Flag in VARCHAR2,
  X_Allow_Tax_Override_Flag in VARCHAR2,
  X_MIN_TXBL_BSIS_THRSHLD in NUMBER,
  X_MAX_TXBL_BSIS_THRSHLD in NUMBER,
  X_MIN_TAX_RATE_THRSHLD in NUMBER,
  X_MAX_TAX_RATE_THRSHLD in NUMBER,
  X_MIN_TAX_AMT_THRSHLD in NUMBER,
  X_MAX_TAX_AMT_THRSHLD in NUMBER,
  X_COMPOUNDING_PRECEDENCE in NUMBER,
  X_PERIOD_SET_NAME in VARCHAR2,
  X_EXCHANGE_RATE_TYPE in VARCHAR2,
  X_TAX_CURRENCY_CODE in VARCHAR2,
  X_REP_TAX_AUTHORITY_ID in NUMBER,
  X_COLL_TAX_AUTHORITY_ID in NUMBER,
  X_TAX_PRECISION in NUMBER,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_Rounding_Rule_Code in VARCHAR2,
  X_Tax_Status_Rule_Flag in VARCHAR2,
  X_Tax_Rate_Rule_Flag in VARCHAR2,
  X_Def_Place_Of_Supply_Type_Cod in VARCHAR2,
  X_Place_Of_Supply_Rule_Flag in VARCHAR2,
  X_Applicability_Rule_Flag in VARCHAR2,
  X_Tax_Calc_Rule_Flag in VARCHAR2,
  X_Txbl_Bsis_Thrshld_Flag in VARCHAR2,
  X_Tax_Rate_Thrshld_Flag in VARCHAR2,
  X_Tax_Amt_Thrshld_Flag in VARCHAR2,
  X_Taxable_Basis_Rule_Flag in VARCHAR2,
  X_Def_Inclusive_Tax_Flag in VARCHAR2,
  X_Thrshld_Grouping_Lvl_Code in VARCHAR2,
  X_Thrshld_Chk_Tmplt_Code in VARCHAR2,
  X_Has_Other_Jurisdictions_Flag in VARCHAR2,
  X_Allow_Exemptions_Flag in VARCHAR2,
  X_Allow_Exceptions_Flag in VARCHAR2,
  X_Allow_Recoverability_Flag in VARCHAR2,
  X_DEF_TAX_CALC_FORMULA in VARCHAR2,
  X_Tax_Inclusive_Override_Flag in VARCHAR2,
  X_DEF_TAXABLE_BASIS_FORMULA in VARCHAR2,
  X_Def_Registr_Party_Type_Code in VARCHAR2,
  X_Registration_Type_Rule_Flag in VARCHAR2,
  X_Reporting_Only_Flag in VARCHAR2,
  X_Auto_Prvn_Flag in VARCHAR2,
  X_Live_For_Processing_Flag in VARCHAR2,
  X_Has_Detail_Tb_Thrshld_Flag in VARCHAR2,
  X_Has_Tax_Det_Date_Rule_Flag in VARCHAR2,
  X_TAX_FULL_NAME in VARCHAR2,
  X_ZONE_GEOGRAPHY_TYPE in VARCHAR2,
  X_Def_Rec_Settlement_Option_Co in VARCHAR2,
  X_Regn_Num_Same_As_Le_Flag in VARCHAR2   ,
  X_Direct_Rate_Rule_Flag   in VARCHAR2,
  X_CONTENT_OWNER_ID in NUMBER,
  X_APPLIED_AMT_HANDLING_FLAG in VARCHAR2,
  X_PARENT_GEOGRAPHY_TYPE in VARCHAR2,
  X_PARENT_GEOGRAPHY_ID in NUMBER,
  X_ALLOW_MASS_CREATE_FLAG in VARCHAR2,
  X_SOURCE_TAX_FLAG in VARCHAR2,
  X_SPECIAL_INCLUSIVE_TAX_FLAG in VARCHAR2,
  X_DEF_PRIMARY_REC_RATE_CODE in VARCHAR2,
  X_DEF_SECONDARY_REC_RATE_CODE in VARCHAR2,
  X_ALLOW_DUP_REGN_NUM_FLAG in VARCHAR2,
  X_TAX_ACCOUNT_SOURCE_TAX in VARCHAR2,
  X_TAX_ACCOUNT_CREATE_METHOD_CO in VARCHAR2,
  X_OVERRIDE_GEOGRAPHY_TYPE in VARCHAR2,
  X_TAX_EXMPT_SOURCE_TAX in VARCHAR2,
  X_TAX_EXMPT_CR_METHOD_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LIVE_FOR_APPLICABILITY_FLAG in VARCHAR2,
  X_APPLICABLE_BY_DEFAULT_FLAG in VARCHAR2,
  X_LEGAL_REPORTING_STATUS_DEF_V in VARCHAR2
) is
  cursor c is select
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      Has_Tax_Point_Date_Rule_Flag,
      Print_On_Invoice_Flag,
      Use_Legal_Msg_Flag,
      Calc_Only_Flag,
      PRIMARY_RECOVERY_TYPE_CODE,
      Primary_Rec_Type_Rule_Flag,
      SECONDARY_RECOVERY_TYPE_CODE,
      Secondary_Rec_Type_Rule_Flag,
      Primary_Rec_Rate_Det_Rule_Flag,
      Sec_Rec_Rate_Det_Rule_Flag,
      Offset_Tax_Flag,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      Program_Login_Id,
      Record_Type_Code,
      Allow_Rounding_Override_Flag,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      Has_Exch_Rate_Date_Rule_Flag,
      Recovery_Rate_Override_Flag,
      TAX,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      TAX_REGIME_CODE,
      TAX_TYPE_CODE,
      Allow_Manual_Entry_Flag,
      Allow_Tax_Override_Flag,
      MIN_TXBL_BSIS_THRSHLD,
      MAX_TXBL_BSIS_THRSHLD,
      MIN_TAX_RATE_THRSHLD,
      MAX_TAX_RATE_THRSHLD,
      MIN_TAX_AMT_THRSHLD,
      MAX_TAX_AMT_THRSHLD,
      COMPOUNDING_PRECEDENCE,
      PERIOD_SET_NAME,
      EXCHANGE_RATE_TYPE,
      TAX_CURRENCY_CODE,
      REP_TAX_AUTHORITY_ID,
      COLL_TAX_AUTHORITY_ID,
      TAX_PRECISION,
      MINIMUM_ACCOUNTABLE_UNIT,
      Rounding_Rule_Code,
      Tax_Status_Rule_Flag,
      Tax_Rate_Rule_Flag,
      Def_Place_Of_Supply_Type_Code,
      Place_Of_Supply_Rule_Flag,
      Applicability_Rule_Flag,
      Tax_Calc_Rule_Flag,
      Txbl_Bsis_Thrshld_Flag,
      Tax_Rate_Thrshld_Flag,
      Tax_Amt_Thrshld_Flag,
      Taxable_Basis_Rule_Flag,
      Def_Inclusive_Tax_Flag,
      Thrshld_Grouping_Lvl_Code,
      Thrshld_Chk_Tmplt_Code,
      Has_Other_Jurisdictions_Flag,
      Allow_Exemptions_Flag,
      Allow_Exceptions_Flag,
      Allow_Recoverability_Flag,
      DEF_TAX_CALC_FORMULA,
      Tax_Inclusive_Override_Flag,
      DEF_TAXABLE_BASIS_FORMULA,
      Def_Registr_Party_Type_Code,
      Registration_Type_Rule_Flag,
      Reporting_Only_Flag,
      Auto_Prvn_Flag,
      Live_For_Processing_Flag,
      Has_Detail_Tb_Thrshld_Flag,
      Has_Tax_Det_Date_Rule_Flag,
      Regn_Num_Same_As_Le_Flag,
      ZONE_GEOGRAPHY_TYPE,
      Def_Rec_Settlement_Option_Code    ,
      Direct_Rate_Rule_Flag   ,
      CONTENT_OWNER_ID ,
      APPLIED_AMT_HANDLING_FLAG,
      PARENT_GEOGRAPHY_TYPE,
      PARENT_GEOGRAPHY_ID,
      ALLOW_MASS_CREATE_FLAG,
      SOURCE_TAX_FLAG,
      SPECIAL_INCLUSIVE_TAX_FLAG,
      DEF_PRIMARY_REC_RATE_CODE,
      DEF_SECONDARY_REC_RATE_CODE,
      ALLOW_DUP_REGN_NUM_FLAG,
      TAX_ACCOUNT_SOURCE_TAX,
      TAX_ACCOUNT_CREATE_METHOD_CODE,
      OVERRIDE_GEOGRAPHY_TYPE,
      TAX_EXMPT_SOURCE_TAX,
      TAX_EXMPT_CR_METHOD_CODE,
      OBJECT_VERSION_NUMBER,
      LIVE_FOR_APPLICABILITY_FLAG,
      APPLICABLE_BY_DEFAULT_FLAG,
      LEGAL_REPORTING_STATUS_DEF_VAL
    from ZX_TAXES_B
    where TAX_ID = X_TAX_ID
    for update of TAX_ID nowait;
  recinfo c%rowtype;
  cursor c1 is select
      TAX_FULL_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ZX_TAXES_TL
    where TAX_ID = X_TAX_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TAX_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.Has_Tax_Point_Date_Rule_Flag = X_Has_Tax_Point_Date_Rule_Flag)
           OR ((recinfo.Has_Tax_Point_Date_Rule_Flag is null) AND (X_Has_Tax_Point_Date_Rule_Flag is null)))
      AND ((recinfo.Print_On_Invoice_Flag = X_Print_On_Invoice_Flag)
           OR ((recinfo.Print_On_Invoice_Flag is null) AND (X_Print_On_Invoice_Flag is null)))
      AND ((recinfo.Use_Legal_Msg_Flag = X_Use_Legal_Msg_Flag)
           OR ((recinfo.Use_Legal_Msg_Flag is null) AND (X_Use_Legal_Msg_Flag is null)))
      AND ((recinfo.Calc_Only_Flag = X_Calc_Only_Flag)
           OR ((recinfo.Calc_Only_Flag is null) AND (X_Calc_Only_Flag is null)))
      AND ((recinfo.PRIMARY_RECOVERY_TYPE_CODE = X_PRIMARY_RECOVERY_TYPE_CODE)
       OR ((recinfo.PRIMARY_RECOVERY_TYPE_CODE is null) AND (X_PRIMARY_RECOVERY_TYPE_CODE is null)))
      AND ((recinfo.Primary_Rec_Type_Rule_Flag = X_Primary_Rec_Type_Rule_Flag)
           OR ((recinfo.Primary_Rec_Type_Rule_Flag is null) AND (X_Primary_Rec_Type_Rule_Flag is null)
))
      AND ((recinfo.SECONDARY_RECOVERY_TYPE_CODE = X_SECONDARY_RECOVERY_TYPE_CODE)
           OR ((recinfo.SECONDARY_RECOVERY_TYPE_CODE is null) AND (X_SECONDARY_RECOVERY_TYPE_CODE is
 null)))
      AND ((recinfo.Secondary_Rec_Type_Rule_Flag = X_Secondary_Rec_Type_Rule_Flag)
     OR ((recinfo.Secondary_Rec_Type_Rule_Flag is null) AND (X_Secondary_Rec_Type_Rule_Flag is null)))
      AND ((recinfo.Primary_Rec_Rate_Det_Rule_Flag = X_PRIMARY_REC_RATE_DET_RULE_FL)
           OR ((recinfo.Primary_Rec_Rate_Det_Rule_Flag is null) AND (X_PRIMARY_REC_RATE_DET_RULE_FL is null)))
      AND ((recinfo.Sec_Rec_Rate_Det_Rule_Flag = X_Sec_Rec_Rate_Det_Rule_Flag)
           OR ((recinfo.Sec_Rec_Rate_Det_Rule_Flag is null) AND (X_Sec_Rec_Rate_Det_Rule_Flag is null)
))
      AND ((recinfo.Offset_Tax_Flag = X_Offset_Tax_Flag)
           OR ((recinfo.Offset_Tax_Flag is null) AND (X_Offset_Tax_Flag is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
           OR ((recinfo.PROGRAM_APPLICATION_ID is null) AND (X_PROGRAM_APPLICATION_ID is null)))
      AND ((recinfo.PROGRAM_ID  = X_PROGRAM_ID )
           OR ((recinfo.PROGRAM_ID is null) AND (X_PROGRAM_ID is null)))
      AND ((recinfo.Program_Login_Id = X_Program_Login_Id)
           OR ((recinfo.Program_Login_Id is null) AND (X_Program_Login_Id is null)))
      AND ((recinfo.Record_Type_Code = X_Record_Type_Code)
          OR ((recinfo.Record_Type_Code is null) AND (X_Record_Type_Code is null)))
      AND ((recinfo.Allow_Rounding_Override_Flag = X_Allow_Rounding_Override_Flag)
           OR ((recinfo.Allow_Rounding_Override_Flag is null) AND (X_Allow_Rounding_Override_Flag is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.Has_Exch_Rate_Date_Rule_Flag = X_Has_Exch_Rate_Date_Rule_Flag)
     OR ((recinfo.Has_Exch_Rate_Date_Rule_Flag is null) AND (X_Has_Exch_Rate_Date_Rule_Flag is null)))
      AND ((recinfo.Recovery_Rate_Override_Flag = X_Recovery_Rate_Override_Flag)
    OR ((recinfo.Recovery_Rate_Override_Flag is null) AND (X_Recovery_Rate_Override_Flag is null)))
      AND (recinfo.TAX = X_TAX)
      AND ((recinfo.EFFECTIVE_FROM = X_EFFECTIVE_FROM)
           OR ((recinfo.EFFECTIVE_FROM is null) AND (X_EFFECTIVE_FROM is null)))
      AND ((recinfo.EFFECTIVE_TO = X_EFFECTIVE_TO)
           OR ((recinfo.EFFECTIVE_TO is null) AND (X_EFFECTIVE_TO is null)))
      AND (recinfo.TAX_REGIME_CODE = X_TAX_REGIME_CODE)
      AND ((recinfo.TAX_TYPE_CODE = X_TAX_TYPE_CODE)
           OR ((recinfo.TAX_TYPE_CODE is null) AND (X_TAX_TYPE_CODE is null)))
      AND ((recinfo.Allow_Manual_Entry_Flag = X_Allow_Manual_Entry_Flag)
           OR ((recinfo.Allow_Manual_Entry_Flag is null) AND (X_Allow_Manual_Entry_Flag is null)))
      AND ((recinfo.Allow_Tax_Override_Flag = X_Allow_Tax_Override_Flag)
           OR ((recinfo.Allow_Tax_Override_Flag is null) AND (X_Allow_Tax_Override_Flag is null)))
      AND ((recinfo.MIN_TXBL_BSIS_THRSHLD = X_MIN_TXBL_BSIS_THRSHLD)
           OR ((recinfo.MIN_TXBL_BSIS_THRSHLD is null) AND (X_MIN_TXBL_BSIS_THRSHLD is null)))
      AND ((recinfo.MAX_TXBL_BSIS_THRSHLD = X_MAX_TXBL_BSIS_THRSHLD)
           OR ((recinfo.MAX_TXBL_BSIS_THRSHLD is null) AND (X_MAX_TXBL_BSIS_THRSHLD is null)))
      AND ((recinfo.MIN_TAX_RATE_THRSHLD = X_MIN_TAX_RATE_THRSHLD)
           OR ((recinfo.MIN_TAX_RATE_THRSHLD is null) AND (X_MIN_TAX_RATE_THRSHLD is null)))
      AND ((recinfo.MAX_TAX_RATE_THRSHLD = X_MAX_TAX_RATE_THRSHLD)
           OR ((recinfo.MAX_TAX_RATE_THRSHLD is null) AND (X_MAX_TAX_RATE_THRSHLD is null)))
      AND ((recinfo.MIN_TAX_AMT_THRSHLD = X_MIN_TAX_AMT_THRSHLD)
           OR ((recinfo.MIN_TAX_AMT_THRSHLD is null) AND (X_MIN_TAX_AMT_THRSHLD is null)))
      AND ((recinfo.MAX_TAX_AMT_THRSHLD = X_MAX_TAX_AMT_THRSHLD)
           OR ((recinfo.MAX_TAX_AMT_THRSHLD is null) AND (X_MAX_TAX_AMT_THRSHLD is null)))
      AND ((recinfo.COMPOUNDING_PRECEDENCE = X_COMPOUNDING_PRECEDENCE)
           OR ((recinfo.COMPOUNDING_PRECEDENCE is null) AND (X_COMPOUNDING_PRECEDENCE is null)))
      AND ((recinfo.PERIOD_SET_NAME = X_PERIOD_SET_NAME)
           OR ((recinfo.PERIOD_SET_NAME is null) AND (X_PERIOD_SET_NAME is null)))
      AND ((recinfo.EXCHANGE_RATE_TYPE = X_EXCHANGE_RATE_TYPE)
           OR ((recinfo.EXCHANGE_RATE_TYPE is null) AND (X_EXCHANGE_RATE_TYPE is null)))
      AND ((recinfo.TAX_CURRENCY_CODE = X_TAX_CURRENCY_CODE)
           OR ((recinfo.TAX_CURRENCY_CODE is null) AND (X_TAX_CURRENCY_CODE is null)))
      AND ((recinfo.REP_TAX_AUTHORITY_ID = X_REP_TAX_AUTHORITY_ID)
           OR ((recinfo.REP_TAX_AUTHORITY_ID is null) AND (X_REP_TAX_AUTHORITY_ID is null)))
      AND ((recinfo.COLL_TAX_AUTHORITY_ID = X_COLL_TAX_AUTHORITY_ID)
           OR ((recinfo.COLL_TAX_AUTHORITY_ID is null) AND (X_COLL_TAX_AUTHORITY_ID is null)))
      AND ((recinfo.TAX_PRECISION = X_TAX_PRECISION)
           OR ((recinfo.TAX_PRECISION is null) AND (X_TAX_PRECISION is null)))
      AND ((recinfo.MINIMUM_ACCOUNTABLE_UNIT = X_MINIMUM_ACCOUNTABLE_UNIT)
           OR ((recinfo.MINIMUM_ACCOUNTABLE_UNIT is null) AND (X_MINIMUM_ACCOUNTABLE_UNIT is null)))
      AND ((recinfo.Rounding_Rule_Code = X_Rounding_Rule_Code)
           OR ((recinfo.Rounding_Rule_Code is null) AND (X_Rounding_Rule_Code is null)))
      AND ((recinfo.Tax_Status_Rule_Flag = X_Tax_Status_Rule_Flag)
           OR ((recinfo.Tax_Status_Rule_Flag is null) AND (X_Tax_Status_Rule_Flag is null)))
      AND ((recinfo.Tax_Rate_Rule_Flag = X_Tax_Rate_Rule_Flag)
           OR ((recinfo.Tax_Rate_Rule_Flag is null) AND (X_Tax_Rate_Rule_Flag is null)))
      AND ((recinfo.Def_Place_Of_Supply_Type_Code = X_Def_Place_Of_Supply_Type_Cod)
           OR ((recinfo.Def_Place_Of_Supply_Type_Code is null) AND (X_Def_Place_Of_Supply_Type_Cod is null)))
      AND ((recinfo.Place_Of_Supply_Rule_Flag = X_Place_Of_Supply_Rule_Flag)
           OR ((recinfo.Place_Of_Supply_Rule_Flag is null) AND (X_Place_Of_Supply_Rule_Flag is null)))
      AND ((recinfo.Applicability_Rule_Flag = X_Applicability_Rule_Flag)
           OR ((recinfo.Applicability_Rule_Flag is null) AND (X_Applicability_Rule_Flag is null)))
      AND ((recinfo.Tax_Calc_Rule_Flag = X_Tax_Calc_Rule_Flag)
           OR ((recinfo.Tax_Calc_Rule_Flag is null) AND (X_Tax_Calc_Rule_Flag is null)))
      AND ((recinfo.Txbl_Bsis_Thrshld_Flag = X_Txbl_Bsis_Thrshld_Flag)
           OR ((recinfo.Txbl_Bsis_Thrshld_Flag is null) AND (X_Txbl_Bsis_Thrshld_Flag is null)))
      AND ((recinfo.Tax_Rate_Thrshld_Flag = X_Tax_Rate_Thrshld_Flag)
           OR ((recinfo.Tax_Rate_Thrshld_Flag is null) AND (X_Tax_Rate_Thrshld_Flag is null)))
      AND ((recinfo.Tax_Amt_Thrshld_Flag = X_Tax_Amt_Thrshld_Flag)
           OR ((recinfo.Tax_Amt_Thrshld_Flag is null) AND (X_Tax_Amt_Thrshld_Flag is null)))
      AND ((recinfo.Taxable_Basis_Rule_Flag = X_Taxable_Basis_Rule_Flag)
           OR ((recinfo.Taxable_Basis_Rule_Flag is null) AND (X_Taxable_Basis_Rule_Flag is null)))
      AND ((recinfo.Def_Inclusive_Tax_Flag = X_Def_Inclusive_Tax_Flag)
           OR ((recinfo.Def_Inclusive_Tax_Flag is null) AND (X_Def_Inclusive_Tax_Flag is null)))
      AND ((recinfo.Thrshld_Grouping_Lvl_Code = X_Thrshld_Grouping_Lvl_Code)
           OR ((recinfo.Thrshld_Grouping_Lvl_Code is null) AND (X_Thrshld_Grouping_Lvl_Code is null)))
      AND ((recinfo.Thrshld_Chk_Tmplt_Code = X_Thrshld_Chk_Tmplt_Code)
           OR ((recinfo.Thrshld_Chk_Tmplt_Code is null) AND (X_Thrshld_Chk_Tmplt_Code is null)))
      AND ((recinfo.Has_Other_Jurisdictions_Flag = X_Has_Other_Jurisdictions_Flag)
       OR ((recinfo.Has_Other_Jurisdictions_Flag is null) AND (X_Has_Other_Jurisdictions_Flag is null)
))
      AND ((recinfo.Allow_Exemptions_Flag = X_Allow_Exemptions_Flag)
           OR ((recinfo.Allow_Exemptions_Flag is null) AND (X_Allow_Exemptions_Flag is null)))
      AND ((recinfo.Allow_Exceptions_Flag = X_Allow_Exceptions_Flag)
           OR ((recinfo.Allow_Exceptions_Flag is null) AND (X_Allow_Exceptions_Flag is null)))
      AND ((recinfo.Allow_Recoverability_Flag = X_Allow_Recoverability_Flag)
           OR ((recinfo.Allow_Recoverability_Flag is null) AND (X_Allow_Recoverability_Flag is null)))
      AND ((recinfo.DEF_TAX_CALC_FORMULA = X_DEF_TAX_CALC_FORMULA)
           OR ((recinfo.DEF_TAX_CALC_FORMULA is null) AND (X_DEF_TAX_CALC_FORMULA is null)))
     AND ((recinfo.Tax_Inclusive_Override_Flag = X_Tax_Inclusive_Override_Flag)
    OR ((recinfo.Tax_Inclusive_Override_Flag is null) AND (X_Tax_Inclusive_Override_Flag is null)))
      AND ((recinfo.DEF_TAXABLE_BASIS_FORMULA = X_DEF_TAXABLE_BASIS_FORMULA)
      OR ((recinfo.DEF_TAXABLE_BASIS_FORMULA is null) AND (X_DEF_TAXABLE_BASIS_FORMULA is null)))
      AND ((recinfo.Def_Registr_Party_Type_Code = X_Def_Registr_Party_Type_Code)
      OR ((recinfo.Def_Registr_Party_Type_Code is null) AND (X_Def_Registr_Party_Type_Code is null))
)
      AND ((recinfo.Registration_Type_Rule_Flag = X_Registration_Type_Rule_Flag)
      OR ((recinfo.Registration_Type_Rule_Flag is null) AND (X_Registration_Type_Rule_Flag is null)))
      AND ((recinfo.Reporting_Only_Flag = X_Reporting_Only_Flag)
           OR ((recinfo.Reporting_Only_Flag is null) AND (X_Reporting_Only_Flag is null)))
      AND ((recinfo.Auto_Prvn_Flag = X_Auto_Prvn_Flag)
           OR ((recinfo.Auto_Prvn_Flag is null) AND (X_Auto_Prvn_Flag is null)))
      AND ((recinfo.Live_For_Processing_Flag = X_Live_For_Processing_Flag)
           OR ((recinfo.Live_For_Processing_Flag is null) AND (X_Live_For_Processing_Flag is null)))
      AND ((recinfo.Has_Detail_Tb_Thrshld_Flag = X_Has_Detail_Tb_Thrshld_Flag)
     OR ((recinfo.Has_Detail_Tb_Thrshld_Flag is null) AND (X_Has_Detail_Tb_Thrshld_Flag is null)))
      AND ((recinfo.Has_Tax_Det_Date_Rule_Flag = X_Has_Tax_Det_Date_Rule_Flag)
     OR ((recinfo.Has_Tax_Det_Date_Rule_Flag is null) AND (X_Has_Tax_Det_Date_Rule_Flag is null)))
      AND ((recinfo.Regn_Num_Same_As_Le_Flag = X_Regn_Num_Same_As_Le_Flag)
           OR ((recinfo.Regn_Num_Same_As_Le_Flag is null) AND (X_Regn_Num_Same_As_Le_Flag is null)))
      AND ((recinfo.ZONE_GEOGRAPHY_TYPE = X_ZONE_GEOGRAPHY_TYPE)
           OR ((recinfo.ZONE_GEOGRAPHY_TYPE is null) AND (X_ZONE_GEOGRAPHY_TYPE is null)))
      AND ((recinfo.Def_Rec_Settlement_Option_Code = X_Def_Rec_Settlement_Option_Co)
      OR ((recinfo.Def_Rec_Settlement_Option_Code is null) AND (X_Def_Rec_Settlement_Option_Co is null)))
      AND ((recinfo.Direct_Rate_Rule_Flag = X_Direct_Rate_Rule_Flag)
           OR ((recinfo.Direct_Rate_Rule_Flag is null) AND (X_Direct_Rate_Rule_Flag is null)))
      AND ((recinfo.CONTENT_OWNER_ID = X_CONTENT_OWNER_ID)
           OR ((recinfo.CONTENT_OWNER_ID is null) AND (X_CONTENT_OWNER_ID is null)))
      AND ((recinfo.APPLIED_AMT_HANDLING_FLAG = X_APPLIED_AMT_HANDLING_FLAG)
           OR ((recinfo.APPLIED_AMT_HANDLING_FLAG is null) AND (X_APPLIED_AMT_HANDLING_FLAG is null)))
      AND ((recinfo.PARENT_GEOGRAPHY_TYPE = X_PARENT_GEOGRAPHY_TYPE)
           OR ((recinfo.PARENT_GEOGRAPHY_TYPE is null) AND (X_PARENT_GEOGRAPHY_TYPE is null)))
      AND ((recinfo.PARENT_GEOGRAPHY_ID = X_PARENT_GEOGRAPHY_ID)
           OR ((recinfo.PARENT_GEOGRAPHY_ID is null) AND (X_PARENT_GEOGRAPHY_ID is null)))
      AND ((recinfo.ALLOW_MASS_CREATE_FLAG = X_ALLOW_MASS_CREATE_FLAG)
           OR ((recinfo.ALLOW_MASS_CREATE_FLAG is null) AND (X_ALLOW_MASS_CREATE_FLAG is null)))
      AND ((recinfo.SOURCE_TAX_FLAG= X_SOURCE_TAX_FLAG)
           OR ((recinfo.SOURCE_TAX_FLAG is null) AND (X_SOURCE_TAX_FLAG is null)))
      AND ((recinfo.DEF_PRIMARY_REC_RATE_CODE = X_DEF_PRIMARY_REC_RATE_CODE )
           OR ((recinfo.DEF_PRIMARY_REC_RATE_CODE  is null) AND (X_DEF_PRIMARY_REC_RATE_CODE is null)))
      AND ((recinfo.DEF_SECONDARY_REC_RATE_CODE= X_DEF_SECONDARY_REC_RATE_CODE)
           OR ((recinfo.DEF_SECONDARY_REC_RATE_CODE is null) AND (X_DEF_SECONDARY_REC_RATE_CODE is null)))
      AND ((recinfo.ALLOW_DUP_REGN_NUM_FLAG= X_ALLOW_DUP_REGN_NUM_FLAG)
           OR ((recinfo.ALLOW_DUP_REGN_NUM_FLAG is null) AND (X_ALLOW_DUP_REGN_NUM_FLAG is null)))
      AND ((recinfo.TAX_ACCOUNT_SOURCE_TAX= X_TAX_ACCOUNT_SOURCE_TAX)
           OR ((recinfo.TAX_ACCOUNT_SOURCE_TAX is null) AND (X_TAX_ACCOUNT_SOURCE_TAX is null)))
      AND ((recinfo.TAX_ACCOUNT_CREATE_METHOD_CODE= X_TAX_ACCOUNT_CREATE_METHOD_CO)
           OR ((recinfo.TAX_ACCOUNT_CREATE_METHOD_CODE is null) AND (X_TAX_ACCOUNT_CREATE_METHOD_CO is null)))
      AND ((recinfo.OVERRIDE_GEOGRAPHY_TYPE= X_OVERRIDE_GEOGRAPHY_TYPE)
           OR ((recinfo.OVERRIDE_GEOGRAPHY_TYPE is null) AND (X_OVERRIDE_GEOGRAPHY_TYPE is null)))
      AND ((recinfo.TAX_EXMPT_SOURCE_TAX= X_TAX_EXMPT_SOURCE_TAX)
           OR ((recinfo.TAX_EXMPT_SOURCE_TAX is null) AND (X_TAX_EXMPT_SOURCE_TAX is null)))
      AND ((recinfo.TAX_EXMPT_CR_METHOD_CODE = X_TAX_EXMPT_CR_METHOD_CODE)
           OR ((recinfo.TAX_EXMPT_CR_METHOD_CODE is null) AND (X_TAX_EXMPT_CR_METHOD_CODE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.LIVE_FOR_APPLICABILITY_FLAG = X_LIVE_FOR_APPLICABILITY_FLAG)
           OR ((recinfo.LIVE_FOR_APPLICABILITY_FLAG is null) AND (X_LIVE_FOR_APPLICABILITY_FLAG is null)))
      AND ((recinfo.APPLICABLE_BY_DEFAULT_FLAG = X_APPLICABLE_BY_DEFAULT_FLAG)
           OR ((recinfo.APPLICABLE_BY_DEFAULT_FLAG is null) AND (X_APPLICABLE_BY_DEFAULT_FLAG is null)))
      AND ((recinfo.LEGAL_REPORTING_STATUS_DEF_VAL = X_LEGAL_REPORTING_STATUS_DEF_V)
           OR ((recinfo.LEGAL_REPORTING_STATUS_DEF_VAL is null) AND (X_LEGAL_REPORTING_STATUS_DEF_V is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.TAX_FULL_NAME = X_TAX_FULL_NAME)
               OR ((tlinfo.TAX_FULL_NAME is null) AND (X_TAX_FULL_NAME is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;
procedure UPDATE_ROW (
  X_TAX_ID in NUMBER,
  X_Recovery_Rate_Override_Flag in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_Has_Tax_Point_Date_Rule_Flag in VARCHAR2,
  X_Print_On_Invoice_Flag in VARCHAR2,
  X_Use_Legal_Msg_Flag in VARCHAR2,
  X_Calc_Only_Flag in VARCHAR2,
  X_PRIMARY_RECOVERY_TYPE_CODE in VARCHAR2,
  X_Primary_Rec_Type_Rule_Flag in VARCHAR2,
  X_SECONDARY_RECOVERY_TYPE_CODE in VARCHAR2,
  X_Secondary_Rec_Type_Rule_Flag in VARCHAR2,
  X_PRIMARY_REC_RATE_DET_RULE_FL in VARCHAR2,
  X_Sec_Rec_Rate_Det_Rule_Flag in VARCHAR2,
  X_Offset_Tax_Flag in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_Record_Type_Code in VARCHAR2,
  X_Allow_Rounding_Override_Flag in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_Has_Exch_Rate_Date_Rule_Flag in VARCHAR2,
  X_TAX in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX_TYPE_CODE in VARCHAR2,
  X_Allow_Manual_Entry_Flag in VARCHAR2,
  X_Allow_Tax_Override_Flag in VARCHAR2,
  X_MIN_TXBL_BSIS_THRSHLD in NUMBER,
  X_MAX_TXBL_BSIS_THRSHLD in NUMBER,
  X_MIN_TAX_RATE_THRSHLD in NUMBER,
  X_MAX_TAX_RATE_THRSHLD in NUMBER,
  X_MIN_TAX_AMT_THRSHLD in NUMBER,
  X_MAX_TAX_AMT_THRSHLD in NUMBER,
  X_COMPOUNDING_PRECEDENCE in NUMBER,
  X_PERIOD_SET_NAME in VARCHAR2,
  X_EXCHANGE_RATE_TYPE in VARCHAR2,
  X_TAX_CURRENCY_CODE in VARCHAR2,
  X_REP_TAX_AUTHORITY_ID in NUMBER,
  X_COLL_TAX_AUTHORITY_ID in NUMBER,
  X_TAX_PRECISION in NUMBER,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_Rounding_Rule_Code in VARCHAR2,
  X_Tax_Status_Rule_Flag in VARCHAR2,
  X_Tax_Rate_Rule_Flag in VARCHAR2,
  X_Def_Place_Of_Supply_Type_Cod in VARCHAR2,
  X_Place_Of_Supply_Rule_Flag in VARCHAR2,
  X_Applicability_Rule_Flag in VARCHAR2,
  X_Tax_Calc_Rule_Flag in VARCHAR2,
  X_Txbl_Bsis_Thrshld_Flag in VARCHAR2,
  X_Tax_Rate_Thrshld_Flag in VARCHAR2,
  X_Tax_Amt_Thrshld_Flag in VARCHAR2,
  X_Taxable_Basis_Rule_Flag in VARCHAR2,
  X_Def_Inclusive_Tax_Flag in VARCHAR2,
  X_Thrshld_Grouping_Lvl_Code in VARCHAR2,
  X_Thrshld_Chk_Tmplt_Code in VARCHAR2,
  X_Has_Other_Jurisdictions_Flag in VARCHAR2,
  X_Allow_Exemptions_Flag in VARCHAR2,
  X_Allow_Exceptions_Flag in VARCHAR2,
  X_Allow_Recoverability_Flag in VARCHAR2,
  X_DEF_TAX_CALC_FORMULA in VARCHAR2,
  X_Tax_Inclusive_Override_Flag in VARCHAR2,
  X_DEF_TAXABLE_BASIS_FORMULA in VARCHAR2,
  X_Def_Registr_Party_Type_Code in VARCHAR2,
  X_Registration_Type_Rule_Flag in VARCHAR2,
  X_Reporting_Only_Flag in VARCHAR2,
  X_Auto_Prvn_Flag in VARCHAR2,
  X_Live_For_Processing_Flag in VARCHAR2,
  X_Has_Detail_Tb_Thrshld_Flag in VARCHAR2,
  X_Has_Tax_Det_Date_Rule_Flag in VARCHAR2,
  X_TAX_FULL_NAME in VARCHAR2,
  X_ZONE_GEOGRAPHY_TYPE in VARCHAR2,
  X_Def_Rec_Settlement_Option_Co in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_Regn_Num_Same_As_Le_Flag in VARCHAR2    ,
  X_Direct_Rate_Rule_Flag in VARCHAR2,
  X_CONTENT_OWNER_ID in NUMBER,
  X_APPLIED_AMT_HANDLING_FLAG in VARCHAR2,
  X_PARENT_GEOGRAPHY_TYPE in VARCHAR2,
  X_PARENT_GEOGRAPHY_ID in NUMBER,
  X_ALLOW_MASS_CREATE_FLAG in VARCHAR2,
  X_SOURCE_TAX_FLAG in VARCHAR2,
  X_SPECIAL_INCLUSIVE_TAX_FLAG in VARCHAR2,
  X_DEF_PRIMARY_REC_RATE_CODE in VARCHAR2,
  X_DEF_SECONDARY_REC_RATE_CODE in VARCHAR2,
  X_ALLOW_DUP_REGN_NUM_FLAG in VARCHAR2,
  X_TAX_ACCOUNT_SOURCE_TAX in VARCHAR2,
  X_TAX_ACCOUNT_CREATE_METHOD_CO in VARCHAR2,
  X_OVERRIDE_GEOGRAPHY_TYPE in VARCHAR2,
  X_TAX_EXMPT_SOURCE_TAX in VARCHAR2,
  X_TAX_EXMPT_CR_METHOD_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LIVE_FOR_APPLICABILITY_FLAG in VARCHAR2,
  X_APPLICABLE_BY_DEFAULT_FLAG in VARCHAR2,
  X_LEGAL_REPORTING_STATUS_DEF_V in VARCHAR2
) is
/* This cursor is for inserting rows into recovery types table and to update Jurisdictions*/
CURSOR c_old_ref_values IS
SELECT REP_TAX_AUTHORITY_ID,
       COLL_TAX_AUTHORITY_ID,
       PRIMARY_RECOVERY_TYPE_CODE,
       SECONDARY_RECOVERY_TYPE_CODE
FROM   ZX_TAXES_B
WHERE  TAX_ID = X_TAX_ID;
l_old_references c_old_ref_values%ROWTYPE;
l_old_zone_geo_type ZX_TAXES_B.ZONE_GEOGRAPHY_TYPE%TYPE;
l_old_parent_geo_type ZX_TAXES_B.PARENT_GEOGRAPHY_TYPE%TYPE;
l_old_parent_geo_id ZX_TAXES_B.PARENT_GEOGRAPHY_ID%TYPE;
begin
/*Logic to update ZX_JURISDICTIONS/ZX_REGISTRATIONS table if the Reporting and/or Collecting Tax Authorities have bee
n changed*/
  open c_old_ref_values;
  fetch c_old_ref_values into l_old_references;
  if((NVL(l_old_references.REP_TAX_AUTHORITY_ID,-99)<> NVL(X_REP_TAX_AUTHORITY_ID,-99) OR
     (NVL(l_old_references.COLL_TAX_AUTHORITY_ID,-99)<> NVL(X_COLL_TAX_AUTHORITY_ID,-99)))) then
       update_jurisdiction(X_TAX,
       			   l_old_references.REP_TAX_AUTHORITY_ID,
         		   l_old_references.COLL_TAX_AUTHORITY_ID,
         		   X_REP_TAX_AUTHORITY_ID,
         		   X_COLL_TAX_AUTHORITY_ID
         		   );
       update_registration(X_TAX_REGIME_CODE,
                     	   X_TAX,
       		           l_old_references.REP_TAX_AUTHORITY_ID,
         		   l_old_references.COLL_TAX_AUTHORITY_ID,
         		   X_REP_TAX_AUTHORITY_ID,
         		   X_COLL_TAX_AUTHORITY_ID
         		   );
  end if;	/*Update on Jurisdictions/Registrations ends*/
/*Logic to insert/update records in ZX_RECOVERY_TYPES_VL table - all calls to insert into ZX_RECOVERY_TYPES has been
commented as fix for bug 2909723*/
/*if(X_Live_For_Processing_Flag  is null or X_LIVE_FOR_PROCESSING_Flag = 'N') THEN
  if(l_old_references.PRIMARY_RECOVERY_TYPE_CODE IS NULL AND X_PRIMARY_RECOVERY_TYPE_CODE IS NOT NULL) THEN
    insert_recovery(X_TAX,
            	    X_TAX_REGIME_CODE,
            	    X_PRIMARY_RECOVERY_TYPE_CODE ,
        	    X_EFFECTIVE_FROM
    		   );
  end if;
  if(l_old_references.SECONDARY_RECOVERY_TYPE_CODE IS NULL AND X_SECONDARY_RECOVERY_TYPE_CODE IS NOT NULL) THEN
    insert_recovery(X_TAX,
            	  X_TAX_REGIME_CODE,
            	  X_SECONDARY_RECOVERY_TYPE_CODE,
        	  X_EFFECTIVE_FROM
    		 );
  end if;
  if(l_old_references.PRIMARY_RECOVERY_TYPE_CODE IS NOT NULL AND X_PRIMARY_RECOVERY_TYPE_CODE IS NULL) THEN
    delete_recovery(X_TAX,
            	  X_TAX_REGIME_CODE,
            	  l_old_references.PRIMARY_RECOVERY_TYPE_CODE
    		 );
  end if;
  if(l_old_references.SECONDARY_RECOVERY_TYPE_CODE IS NOT NULL AND X_SECONDARY_RECOVERY_TYPE_CODE IS NULL) THEN
    delete_recovery(X_TAX,
               	    X_TAX_REGIME_CODE,
              	    l_old_references.SECONDARY_RECOVERY_TYPE_CODE
    		   );
  end if;
  if(l_old_references.PRIMARY_RECOVERY_TYPE_CODE IS NOT NULL AND X_PRIMARY_RECOVERY_TYPE_CODE IS NOT NULL) THEN
    if(l_old_references.PRIMARY_RECOVERY_TYPE_CODE <> X_PRIMARY_RECOVERY_TYPE_CODE) THEN
      delete_recovery(X_TAX,
      		      X_TAX_REGIME_CODE,
      		      l_old_references.PRIMARY_RECOVERY_TYPE_CODE);
      insert_recovery(X_TAX,
          	      X_TAX_REGIME_CODE,
          	      X_PRIMARY_RECOVERY_TYPE_CODE ,
      		      X_EFFECTIVE_FROM
    		     );
    end if;
  end if;
  if(l_old_references.SECONDARY_RECOVERY_TYPE_CODE IS NOT NULL AND X_SECONDARY_RECOVERY_TYPE_CODE IS NOT NULL) THEN
      if(l_old_references.SECONDARY_RECOVERY_TYPE_CODE <> X_SECONDARY_RECOVERY_TYPE_CODE) THEN
          delete_recovery(X_TAX,
          		  X_TAX_REGIME_CODE,
          		  l_old_references.SECONDARY_RECOVERY_TYPE_CODE
          		  );
          insert_recovery(X_TAX,
              	          X_TAX_REGIME_CODE,
              	          X_SECONDARY_RECOVERY_TYPE_CODE ,
          		  X_EFFECTIVE_FROM
        		 );
    end if;
  end if;
close c_old_ref_values;
end if;  */
if(X_RECORD_TYPE_CODE = 'MIGRATED' AND X_SOURCE_TAX_FLAG = 'Y') then
  begin
    SELECT ZONE_GEOGRAPHY_TYPE, PARENT_GEOGRAPHY_TYPE, PARENT_GEOGRAPHY_ID  INTO
    l_old_zone_geo_type, l_old_parent_geo_type, l_old_parent_geo_id
    FROM ZX_TAXES_B WHERE TAX_ID = X_TAX_ID;
    if(nvl(l_old_zone_geo_type, '-1') <> nvl(X_ZONE_GEOGRAPHY_TYPE, '-1') OR
       nvl(l_old_parent_geo_type, '-1') <> nvl(X_PARENT_GEOGRAPHY_TYPE, '-1') OR
       nvl(l_old_parent_geo_id, -1) <> nvl(X_PARENT_GEOGRAPHY_ID, -1)) then
      UPDATE ZX_TAXES_B SET ZONE_GEOGRAPHY_TYPE = X_ZONE_GEOGRAPHY_TYPE,
      PARENT_GEOGRAPHY_TYPE = X_PARENT_GEOGRAPHY_TYPE,
      PARENT_GEOGRAPHY_ID = X_PARENT_GEOGRAPHY_ID
      WHERE TAX = X_TAX AND
            TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    SOURCE_TAX_FLAG  = 'N';
    end if;
  exception when no_data_found then
    raise no_data_found;
  end;
end if;
	/*Insert/Update of ZX_RECOVERY_TYPES_VL ends here*/
  update ZX_TAXES_B set
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    Has_Tax_Point_Date_Rule_Flag = X_Has_Tax_Point_Date_Rule_Flag,
    Print_On_Invoice_Flag = X_Print_On_Invoice_Flag,
    Use_Legal_Msg_Flag = X_Use_Legal_Msg_Flag,
    Calc_Only_Flag = X_Calc_Only_Flag,
    PRIMARY_RECOVERY_TYPE_CODE = X_PRIMARY_RECOVERY_TYPE_CODE,
    Primary_Rec_Type_Rule_Flag = X_Primary_Rec_Type_Rule_Flag,
    SECONDARY_RECOVERY_TYPE_CODE = X_SECONDARY_RECOVERY_TYPE_CODE,
    Secondary_Rec_Type_Rule_Flag = X_Secondary_Rec_Type_Rule_Flag,
    Primary_Rec_Rate_Det_Rule_Flag = X_PRIMARY_REC_RATE_DET_RULE_FL,
    Sec_Rec_Rate_Det_Rule_Flag = X_Sec_Rec_Rate_Det_Rule_Flag,
    Offset_Tax_Flag = X_Offset_Tax_Flag,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    Program_Login_Id = X_Program_Login_Id,
    Record_Type_Code = X_Record_Type_Code,
    Allow_Rounding_Override_Flag = X_Allow_Rounding_Override_Flag,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    Has_Exch_Rate_Date_Rule_Flag = X_Has_Exch_Rate_Date_Rule_Flag,
    TAX = X_TAX,
    Recovery_Rate_Override_Flag = X_Recovery_Rate_Override_Flag,
    EFFECTIVE_FROM = X_EFFECTIVE_FROM,
    EFFECTIVE_TO = X_EFFECTIVE_TO,
    TAX_REGIME_CODE = X_TAX_REGIME_CODE,
    TAX_TYPE_CODE = X_TAX_TYPE_CODE,
    Allow_Manual_Entry_Flag = X_Allow_Manual_Entry_Flag,
    Allow_Tax_Override_Flag = X_Allow_Tax_Override_Flag,
    MIN_TXBL_BSIS_THRSHLD = X_MIN_TXBL_BSIS_THRSHLD,
    MAX_TXBL_BSIS_THRSHLD = X_MAX_TXBL_BSIS_THRSHLD,
    MIN_TAX_RATE_THRSHLD = X_MIN_TAX_RATE_THRSHLD,
    MAX_TAX_RATE_THRSHLD = X_MAX_TAX_RATE_THRSHLD,
    MIN_TAX_AMT_THRSHLD = X_MIN_TAX_AMT_THRSHLD,
    MAX_TAX_AMT_THRSHLD = X_MAX_TAX_AMT_THRSHLD,
    COMPOUNDING_PRECEDENCE = X_COMPOUNDING_PRECEDENCE,
    PERIOD_SET_NAME = X_PERIOD_SET_NAME,
    EXCHANGE_RATE_TYPE = X_EXCHANGE_RATE_TYPE,
    TAX_CURRENCY_CODE = X_TAX_CURRENCY_CODE,
    REP_TAX_AUTHORITY_ID = X_REP_TAX_AUTHORITY_ID,
    COLL_TAX_AUTHORITY_ID = X_COLL_TAX_AUTHORITY_ID,
    TAX_PRECISION = X_TAX_PRECISION,
    MINIMUM_ACCOUNTABLE_UNIT = X_MINIMUM_ACCOUNTABLE_UNIT,
    Rounding_Rule_Code = X_Rounding_Rule_Code,
    Tax_Status_Rule_Flag = X_Tax_Status_Rule_Flag,
    Tax_Rate_Rule_Flag = X_Tax_Rate_Rule_Flag,
    Def_Place_Of_Supply_Type_Code = X_Def_Place_Of_Supply_Type_Cod,
    Place_Of_Supply_Rule_Flag = X_Place_Of_Supply_Rule_Flag,
    Applicability_Rule_Flag = X_Applicability_Rule_Flag,
    Tax_Calc_Rule_Flag = X_Tax_Calc_Rule_Flag,
    Txbl_Bsis_Thrshld_Flag = X_Txbl_Bsis_Thrshld_Flag,
    Tax_Rate_Thrshld_Flag = X_Tax_Rate_Thrshld_Flag,
    Tax_Amt_Thrshld_Flag = X_Tax_Amt_Thrshld_Flag,
    Taxable_Basis_Rule_Flag = X_Taxable_Basis_Rule_Flag,
    Def_Inclusive_Tax_Flag = X_Def_Inclusive_Tax_Flag,
    Thrshld_Grouping_Lvl_Code = X_Thrshld_Grouping_Lvl_Code,
    Thrshld_Chk_Tmplt_Code = X_Thrshld_Chk_Tmplt_Code,
    Has_Other_Jurisdictions_Flag = X_Has_Other_Jurisdictions_Flag,
    Allow_Exemptions_Flag = X_Allow_Exemptions_Flag,
    Allow_Exceptions_Flag = X_Allow_Exceptions_Flag,
    Allow_Recoverability_Flag = X_Allow_Recoverability_Flag,
    DEF_TAX_CALC_FORMULA = X_DEF_TAX_CALC_FORMULA,
    Tax_Inclusive_Override_Flag = X_Tax_Inclusive_Override_Flag,
    DEF_TAXABLE_BASIS_FORMULA = X_DEF_TAXABLE_BASIS_FORMULA,
    Def_Registr_Party_Type_Code = X_Def_Registr_Party_Type_Code,
    Registration_Type_Rule_Flag = X_Registration_Type_Rule_Flag,
    Reporting_Only_Flag = X_Reporting_Only_Flag,
    Auto_Prvn_Flag = X_Auto_Prvn_Flag,
    Live_For_Processing_Flag = X_Live_For_Processing_Flag,
    Has_Detail_Tb_Thrshld_Flag = X_Has_Detail_Tb_Thrshld_Flag,
    Has_Tax_Det_Date_Rule_Flag = X_Has_Tax_Det_Date_Rule_Flag,
    Def_Rec_Settlement_Option_Code = X_Def_Rec_Settlement_Option_Co,
    Regn_Num_Same_As_Le_Flag = X_Regn_Num_Same_As_Le_Flag,
    Direct_Rate_Rule_Flag = X_Direct_Rate_Rule_Flag,
    CONTENT_OWNER_ID = X_CONTENT_OWNER_ID,
    APPLIED_AMT_HANDLING_FLAG = X_APPLIED_AMT_HANDLING_FLAG,
    PARENT_GEOGRAPHY_TYPE = X_PARENT_GEOGRAPHY_TYPE,
    PARENT_GEOGRAPHY_ID = X_PARENT_GEOGRAPHY_ID,
    ALLOW_MASS_CREATE_FLAG = X_ALLOW_MASS_CREATE_FLAG,
    ZONE_GEOGRAPHY_TYPE = X_ZONE_GEOGRAPHY_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_TAX_FLAG = X_SOURCE_TAX_FLAG,
    SPECIAL_INCLUSIVE_TAX_FLAG = X_SPECIAL_INCLUSIVE_TAX_FLAG,
    DEF_PRIMARY_REC_RATE_CODE = X_DEF_PRIMARY_REC_RATE_CODE,
    DEF_SECONDARY_REC_RATE_CODE = X_DEF_SECONDARY_REC_RATE_CODE,
    ALLOW_DUP_REGN_NUM_FLAG = X_ALLOW_DUP_REGN_NUM_FLAG,
    TAX_ACCOUNT_SOURCE_TAX  =  X_TAX_ACCOUNT_SOURCE_TAX,
    TAX_ACCOUNT_CREATE_METHOD_CODE = X_TAX_ACCOUNT_CREATE_METHOD_CO,
    OVERRIDE_GEOGRAPHY_TYPE =  X_OVERRIDE_GEOGRAPHY_TYPE,
    TAX_EXMPT_SOURCE_TAX = X_TAX_EXMPT_SOURCE_TAX,
    TAX_EXMPT_CR_METHOD_CODE = X_TAX_EXMPT_CR_METHOD_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LIVE_FOR_APPLICABILITY_FLAG = X_LIVE_FOR_APPLICABILITY_FLAG,
    APPLICABLE_BY_DEFAULT_FLAG = X_APPLICABLE_BY_DEFAULT_FLAG,
    LEGAL_REPORTING_STATUS_DEF_VAL = X_LEGAL_REPORTING_STATUS_DEF_V
  where TAX_ID = X_TAX_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  update ZX_TAXES_TL set
    TAX_FULL_NAME = X_TAX_FULL_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TAX_ID = X_TAX_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
procedure DELETE_ROW (
  X_TAX_ID in NUMBER
) is
begin
  delete from ZX_TAXES_TL
  where TAX_ID = X_TAX_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  delete from ZX_TAXES_B
  where TAX_ID = X_TAX_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
procedure ADD_LANGUAGE
is
begin
  delete from ZX_TAXES_TL T
  where not exists
    (select NULL
    from ZX_TAXES_B B
    where B.TAX_ID = T.TAX_ID
    );
  update ZX_TAXES_TL T set (
      TAX_FULL_NAME
    ) = (select
      B.TAX_FULL_NAME
    from ZX_TAXES_TL B
    where B.TAX_ID = T.TAX_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAX_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TAX_ID,
      SUBT.LANGUAGE
    from ZX_TAXES_TL SUBB, ZX_TAXES_TL SUBT
    where SUBB.TAX_ID = SUBT.TAX_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TAX_FULL_NAME <> SUBT.TAX_FULL_NAME
      or (SUBB.TAX_FULL_NAME is null and SUBT.TAX_FULL_NAME is not null)
      or (SUBB.TAX_FULL_NAME is not null and SUBT.TAX_FULL_NAME is null)));
  insert into ZX_TAXES_TL (
    TAX_ID,
    TAX_FULL_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TAX_ID,
    B.TAX_FULL_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ZX_TAXES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ZX_TAXES_TL T
    where T.TAX_ID = B.TAX_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
end ZX_TAXES_PKG;

/
