--------------------------------------------------------
--  DDL for Package Body ZX_REGIMES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_REGIMES_PKG" as
/* $Header: zxcregimesb.pls 120.7 2005/03/29 11:27:15 scsharma ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TAX_REGIME_ID in NUMBER,
  X_PARENT_REGIME_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_Has_Sub_Regime_Flag in VARCHAR2,
  X_Country_Or_Group_Code in VARCHAR2,
  X_COUNTRY_CODE in VARCHAR2,
  X_GEOGRAPHY_TYPE in VARCHAR2,
  X_GEOGRAPHY_ID in NUMBER,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_EXCHANGE_RATE_TYPE in VARCHAR2,
  X_TAX_CURRENCY_CODE in VARCHAR2,
  X_Thrshld_Grouping_Lvl_Code in VARCHAR2,
  X_Thrshld_Chk_Tmplt_Code in VARCHAR2,
  X_PERIOD_SET_NAME in VARCHAR2,
  X_REP_TAX_AUTHORITY_ID in NUMBER,
  X_COLL_TAX_AUTHORITY_ID in NUMBER,
  X_Rounding_Rule_Code in VARCHAR2,
  X_TAX_PRECISION in NUMBER,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_Tax_Status_Rule_Flag in VARCHAR2,
  X_Def_Place_Of_Supply_Type_Cod in VARCHAR2,
  X_Applicability_Rule_Flag in VARCHAR2,
  X_Place_Of_Supply_Rule_Flag in VARCHAR2,
  X_Tax_Calc_Rule_Flag in VARCHAR2,
  X_Taxable_Basis_Thrshld_Flag in VARCHAR2,
  X_Tax_Rate_Thrshld_Flag in VARCHAR2,
  X_Tax_Amt_Thrshld_Flag in VARCHAR2,
  X_Tax_Rate_Rule_Flag in VARCHAR2,
  X_Taxable_Basis_Rule_Flag in VARCHAR2,
  X_Def_Inclusive_Tax_Flag in VARCHAR2,
  X_Has_Other_Jurisdictions_Flag in VARCHAR2,
  X_Allow_Rounding_Override_Flag in VARCHAR2,
  X_Allow_Exemptions_Flag in VARCHAR2,
  X_Allow_Exceptions_Flag in VARCHAR2,
  X_Allow_Recoverability_Flag in VARCHAR2,
  X_Auto_Prvn_Flag in VARCHAR2,
  X_Has_Tax_Det_Date_Rule_Flag in VARCHAR2,
  X_Has_Exch_Rate_Date_Rule_Flag in VARCHAR2,
  X_Has_Tax_Point_Date_Rule_Flag in VARCHAR2,
  X_Use_Legal_Msg_Flag in VARCHAR2,
  X_Regn_Num_Same_As_Le_Flag in VARCHAR2,
  X_Def_Rec_Settlement_Option_Co in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_Def_Registr_Party_Type_Code in VARCHAR2,
  X_Registration_Type_Rule_Flag in VARCHAR2,
  X_Tax_Inclusive_Override_Flag in VARCHAR2,
  X_REGIME_PRECEDENCE in NUMBER,
  X_Cross_Regime_Compounding_Fla in VARCHAR2,
  X_TAX_REGIME_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_TAX_ACCOUNT_PRECEDENCE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is

  cursor C is select ROWID from ZX_REGIMES_B
    where TAX_REGIME_ID = X_TAX_REGIME_ID  ;

  err_stat VARCHAR2(30);

begin

   err_stat := FND_API.G_RET_STS_SUCCESS;

   insert into ZX_REGIMES_B (
    PARENT_REGIME_CODE,
    TAX_REGIME_ID,
    TAX_REGIME_CODE,
    Has_Sub_Regime_Flag,
    Country_Or_Group_Code,
    COUNTRY_CODE,
    GEOGRAPHY_TYPE,
    GEOGRAPHY_ID,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    EXCHANGE_RATE_TYPE,
    TAX_CURRENCY_CODE,
    Thrshld_Grouping_Lvl_Code,
    Thrshld_Chk_Tmplt_Code,
    PERIOD_SET_NAME,
    REP_TAX_AUTHORITY_ID,
    COLL_TAX_AUTHORITY_ID,
    Rounding_Rule_Code,
    TAX_PRECISION,
    MINIMUM_ACCOUNTABLE_UNIT,
    Tax_Status_Rule_Flag,
    Def_Place_Of_Supply_Type_Code,
    Applicability_Rule_Flag,
    Place_Of_Supply_Rule_Flag,
    Tax_Calc_Rule_Flag,
    Taxable_Basis_Thrshld_Flag,
    Tax_Rate_Thrshld_Flag,
    Tax_Amt_Thrshld_Flag,
    Tax_Rate_Rule_Flag,
    Taxable_Basis_Rule_Flag,
    Def_Inclusive_Tax_Flag,
    Has_Other_Jurisdictions_Flag,
    Allow_Rounding_Override_Flag,
    Allow_Exemptions_Flag,
    Allow_Exceptions_Flag,
    Allow_Recoverability_Flag,
    Auto_Prvn_Flag,
    Has_Tax_Det_Date_Rule_Flag,
    Has_Exch_Rate_Date_Rule_Flag,
    Has_Tax_Point_Date_Rule_Flag,
    Use_Legal_Msg_Flag,
    Regn_Num_Same_As_Le_Flag,
    Def_Rec_Settlement_Option_Code,
    Record_Type_Code,
    PROGRAM_APPLICATION_ID ,
    PROGRAM_ID ,
    Program_Login_Id,
    REQUEST_ID,
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
    ATTRIBUTE_CATEGORY,
    Def_Registr_Party_Type_Code,
    Registration_Type_Rule_Flag,
    Tax_Inclusive_Override_Flag,
    REGIME_PRECEDENCE,
    Cross_Regime_Compounding_Flag,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    TAX_ACCOUNT_PRECEDENCE_CODE,
    OBJECT_VERSION_NUMBER
  ) values (
    X_PARENT_REGIME_CODE,
    X_TAX_REGIME_ID,
    X_TAX_REGIME_CODE,
    X_Has_Sub_Regime_Flag,
    X_Country_Or_Group_Code,
    X_COUNTRY_CODE,
    X_GEOGRAPHY_TYPE,
    X_GEOGRAPHY_ID,
    X_EFFECTIVE_FROM,
    X_EFFECTIVE_TO,
    X_EXCHANGE_RATE_TYPE,
    X_TAX_CURRENCY_CODE,
    X_Thrshld_Grouping_Lvl_Code,
    X_Thrshld_Chk_Tmplt_Code,
    X_PERIOD_SET_NAME,
    X_REP_TAX_AUTHORITY_ID,
    X_COLL_TAX_AUTHORITY_ID,
    X_Rounding_Rule_Code,
    X_TAX_PRECISION,
    X_MINIMUM_ACCOUNTABLE_UNIT,
    X_Tax_Status_Rule_Flag,
    X_Def_Place_Of_Supply_Type_Cod,
    X_Applicability_Rule_Flag,
    X_Place_Of_Supply_Rule_Flag,
    X_Tax_Calc_Rule_Flag,
    X_Taxable_Basis_Thrshld_Flag,
    X_Tax_Rate_Thrshld_Flag,
    X_Tax_Amt_Thrshld_Flag,
    X_Tax_Rate_Rule_Flag,
    X_Taxable_Basis_Rule_Flag,
    X_Def_Inclusive_Tax_Flag,
    X_Has_Other_Jurisdictions_Flag,
    X_Allow_Rounding_Override_Flag,
    X_Allow_Exemptions_Flag,
    X_Allow_Exceptions_Flag,
    X_Allow_Recoverability_Flag,
    X_Auto_Prvn_Flag,
    X_Has_Tax_Det_Date_Rule_Flag,
    X_Has_Exch_Rate_Date_Rule_Flag,
    X_Has_Tax_Point_Date_Rule_Flag,
    X_Use_Legal_Msg_Flag,
    X_Regn_Num_Same_As_Le_Flag ,
    X_Def_Rec_Settlement_Option_Co ,
    X_Record_Type_Code,
    X_PROGRAM_APPLICATION_ID ,
    X_PROGRAM_ID ,
    X_Program_Login_Id,
    X_REQUEST_ID,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE_CATEGORY,
    X_Def_Registr_Party_Type_Code,
    X_Registration_Type_Rule_Flag,
    X_Tax_Inclusive_Override_Flag,
    X_REGIME_PRECEDENCE,
    X_Cross_Regime_Compounding_Fla,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_TAX_ACCOUNT_PRECEDENCE_CODE,
    X_OBJECT_VERSION_NUMBER
  );
  insert into ZX_REGIMES_TL (
    TAX_REGIME_ID,
    TAX_REGIME_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TAX_REGIME_ID,
    X_TAX_REGIME_NAME,
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
    from ZX_REGIMES_TL T
    where T.TAX_REGIME_ID = X_TAX_REGIME_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  -- Insert into zx_regime_relations table
     if (X_PARENT_REGIME_CODE IS NOT NULL) then
	    zx_reg_rel_pub.insert_rel(err_stat,X_TAX_REGIME_CODE,X_PARENT_REGIME_CODE,
		X_CREATED_BY, X_CREATION_DATE, X_LAST_UPDATED_BY, X_LAST_UPDATE_DATE,
		X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_ID,
		X_PROGRAM_LOGIN_ID, X_PROGRAM_APPLICATION_ID);
     end if;
     if(err_stat <> FND_API.G_RET_STS_SUCCESS) then
      raise no_data_found;
     end if;
end INSERT_ROW;

procedure LOCK_ROW (
  X_TAX_REGIME_ID in NUMBER,
  X_PARENT_REGIME_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_Has_Sub_Regime_Flag in VARCHAR2,
  X_Country_Or_Group_Code in VARCHAR2,
  X_COUNTRY_CODE in VARCHAR2,
  X_GEOGRAPHY_TYPE in VARCHAR2,
  X_GEOGRAPHY_ID in NUMBER,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_EXCHANGE_RATE_TYPE in VARCHAR2,
  X_TAX_CURRENCY_CODE in VARCHAR2,
  X_Thrshld_Grouping_Lvl_Code in VARCHAR2,
  X_Thrshld_Chk_Tmplt_Code in VARCHAR2,
  X_PERIOD_SET_NAME in VARCHAR2,
  X_REP_TAX_AUTHORITY_ID in NUMBER,
  X_COLL_TAX_AUTHORITY_ID in NUMBER,
  X_Rounding_Rule_Code in VARCHAR2,
  X_TAX_PRECISION in NUMBER,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_Tax_Status_Rule_Flag in VARCHAR2,
  X_Def_Place_Of_Supply_Type_Cod in VARCHAR2,
  X_Applicability_Rule_Flag in VARCHAR2,
  X_Place_Of_Supply_Rule_Flag in VARCHAR2,
  X_Tax_Calc_Rule_Flag in VARCHAR2,
  X_Taxable_Basis_Thrshld_Flag in VARCHAR2,
  X_Tax_Rate_Thrshld_Flag in VARCHAR2,
  X_Tax_Amt_Thrshld_Flag in VARCHAR2,
  X_Tax_Rate_Rule_Flag in VARCHAR2,
  X_Taxable_Basis_Rule_Flag in VARCHAR2,
  X_Def_Inclusive_Tax_Flag in VARCHAR2,
  X_Has_Other_Jurisdictions_Flag in VARCHAR2,
  X_Allow_Rounding_Override_Flag in VARCHAR2,
  X_Allow_Exemptions_Flag in VARCHAR2,
  X_Allow_Exceptions_Flag in VARCHAR2,
  X_Allow_Recoverability_Flag in VARCHAR2,
  X_Auto_Prvn_Flag in VARCHAR2,
  X_Has_Tax_Det_Date_Rule_Flag in VARCHAR2,
  X_Has_Exch_Rate_Date_Rule_Flag in VARCHAR2,
  X_Has_Tax_Point_Date_Rule_Flag in VARCHAR2,
  X_Use_Legal_Msg_Flag in VARCHAR2,
  X_Regn_Num_Same_As_Le_Flag in VARCHAR2,
  X_Def_Rec_Settlement_Option_Co in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_Def_Registr_Party_Type_Code in VARCHAR2,
  X_Registration_Type_Rule_Flag in VARCHAR2,
  X_Tax_Inclusive_Override_Flag in VARCHAR2,
  X_REGIME_PRECEDENCE in NUMBER,
  X_Cross_Regime_Compounding_Fla in VARCHAR2,
  X_TAX_REGIME_NAME in VARCHAR2 ,
  X_TAX_ACCOUNT_PRECEDENCE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      PARENT_REGIME_CODE,
      TAX_REGIME_CODE,
      Has_Sub_Regime_Flag,
      Country_Or_Group_Code,
      COUNTRY_CODE,
      GEOGRAPHY_TYPE,
      GEOGRAPHY_ID,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      EXCHANGE_RATE_TYPE,
      TAX_CURRENCY_CODE,
      Thrshld_Grouping_Lvl_Code,
      Thrshld_Chk_Tmplt_Code,
      PERIOD_SET_NAME,
      REP_TAX_AUTHORITY_ID,
      COLL_TAX_AUTHORITY_ID,
      Rounding_Rule_Code,
      TAX_PRECISION,
      MINIMUM_ACCOUNTABLE_UNIT,
      Tax_Status_Rule_Flag,
      Def_Place_Of_Supply_Type_Code,
      Applicability_Rule_Flag,
      Place_Of_Supply_Rule_Flag,
      Tax_Calc_Rule_Flag,
      Taxable_Basis_Thrshld_Flag,
      Tax_Rate_Thrshld_Flag,
      Tax_Amt_Thrshld_Flag,
      Tax_Rate_Rule_Flag,
      Taxable_Basis_Rule_Flag,
      Def_Inclusive_Tax_Flag,
      Has_Other_Jurisdictions_Flag,
      Allow_Rounding_Override_Flag,
      Allow_Exemptions_Flag,
      Allow_Exceptions_Flag,
      Allow_Recoverability_Flag,
      Auto_Prvn_Flag,
      Has_Tax_Det_Date_Rule_Flag,
      Has_Exch_Rate_Date_Rule_Flag,
      Has_Tax_Point_Date_Rule_Flag,
      Use_Legal_Msg_Flag,
      Regn_Num_Same_As_Le_Flag ,
      Def_Rec_Settlement_Option_Code ,
      Record_Type_Code,
      PROGRAM_APPLICATION_ID ,
      PROGRAM_ID ,
      Program_Login_Id,
      REQUEST_ID,
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
      ATTRIBUTE_CATEGORY,
      Def_Registr_Party_Type_Code,
      Registration_Type_Rule_Flag,
      Tax_Inclusive_Override_Flag,
      REGIME_PRECEDENCE,
      Cross_Regime_Compounding_Flag,
      TAX_ACCOUNT_PRECEDENCE_CODE,
      OBJECT_VERSION_NUMBER
    from ZX_REGIMES_B
    where TAX_REGIME_ID = X_TAX_REGIME_ID
    for update of TAX_REGIME_ID nowait;
  recinfo c%rowtype;
  cursor c1 is select
      TAX_REGIME_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ZX_REGIMES_TL
    where TAX_REGIME_ID = X_TAX_REGIME_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TAX_REGIME_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.PARENT_REGIME_CODE = X_PARENT_REGIME_CODE)
           OR ((recinfo.PARENT_REGIME_CODE is null) AND (X_PARENT_REGIME_CODE is null)))
      AND (recinfo.TAX_REGIME_CODE = X_TAX_REGIME_CODE)
      AND ((recinfo.Has_Sub_Regime_Flag = X_Has_Sub_Regime_Flag)
           OR ((recinfo.Has_Sub_Regime_Flag is null) AND (X_Has_Sub_Regime_Flag is null)))
      AND ((recinfo.Country_Or_Group_Code = X_Country_Or_Group_Code)
           OR ((recinfo.Country_Or_Group_Code is null) AND (X_Country_Or_Group_Code is null)))
      AND ((recinfo.COUNTRY_CODE = X_COUNTRY_CODE)
           OR ((recinfo.COUNTRY_CODE is null) AND (X_COUNTRY_CODE is null)))
      AND ((recinfo.GEOGRAPHY_TYPE = X_GEOGRAPHY_TYPE)
           OR ((recinfo.GEOGRAPHY_TYPE is null) AND (X_GEOGRAPHY_TYPE is null)))
      AND ((recinfo.GEOGRAPHY_ID = X_GEOGRAPHY_ID)
           OR ((recinfo.GEOGRAPHY_ID is null) AND (X_GEOGRAPHY_ID is null)))
      AND ((recinfo.EFFECTIVE_FROM = X_EFFECTIVE_FROM)
           OR ((recinfo.EFFECTIVE_FROM is null) AND (X_EFFECTIVE_FROM is null)))
      AND ((recinfo.EFFECTIVE_TO = X_EFFECTIVE_TO)
           OR ((recinfo.EFFECTIVE_TO is null) AND (X_EFFECTIVE_TO is null)))
      AND ((recinfo.EXCHANGE_RATE_TYPE = X_EXCHANGE_RATE_TYPE)
           OR ((recinfo.EXCHANGE_RATE_TYPE is null) AND (X_EXCHANGE_RATE_TYPE is null)))
      AND ((recinfo.TAX_CURRENCY_CODE = X_TAX_CURRENCY_CODE)
           OR ((recinfo.TAX_CURRENCY_CODE is null) AND (X_TAX_CURRENCY_CODE is null)))
      AND ((recinfo.Thrshld_Grouping_Lvl_Code = X_Thrshld_Grouping_Lvl_Code)
           OR ((recinfo.Thrshld_Grouping_Lvl_Code is null) AND (X_Thrshld_Grouping_Lvl_Code is null)))
      AND ((recinfo.Thrshld_Chk_Tmplt_Code = X_Thrshld_Chk_Tmplt_Code)
           OR ((recinfo.Thrshld_Chk_Tmplt_Code is null) AND (X_Thrshld_Chk_Tmplt_Code is null)))
      AND ((recinfo.PERIOD_SET_NAME = X_PERIOD_SET_NAME)
           OR ((recinfo.PERIOD_SET_NAME is null) AND (X_PERIOD_SET_NAME is null)))
      AND ((recinfo.REP_TAX_AUTHORITY_ID = X_REP_TAX_AUTHORITY_ID)
           OR ((recinfo.REP_TAX_AUTHORITY_ID is null) AND (X_REP_TAX_AUTHORITY_ID is null)))
      AND ((recinfo.COLL_TAX_AUTHORITY_ID = X_COLL_TAX_AUTHORITY_ID)
           OR ((recinfo.COLL_TAX_AUTHORITY_ID is null) AND (X_COLL_TAX_AUTHORITY_ID is null)))
      AND ((recinfo.Rounding_Rule_Code = X_Rounding_Rule_Code)
           OR ((recinfo.Rounding_Rule_Code is null) AND (X_Rounding_Rule_Code is null)))
      AND ((recinfo.TAX_PRECISION = X_TAX_PRECISION)
           OR ((recinfo.TAX_PRECISION is null) AND (X_TAX_PRECISION is null)))
      AND ((recinfo.MINIMUM_ACCOUNTABLE_UNIT = X_MINIMUM_ACCOUNTABLE_UNIT)
           OR ((recinfo.MINIMUM_ACCOUNTABLE_UNIT is null) AND (X_MINIMUM_ACCOUNTABLE_UNIT is null)))
      AND ((recinfo.Tax_Status_Rule_Flag = X_Tax_Status_Rule_Flag)
           OR ((recinfo.Tax_Status_Rule_Flag is null) AND (X_Tax_Status_Rule_Flag is null)))
      AND ((recinfo.Def_Place_Of_Supply_Type_Code = X_Def_Place_Of_Supply_Type_Cod)
           OR ((recinfo.Def_Place_Of_Supply_Type_Code is null) AND (X_Def_Place_Of_Supply_Type_Cod is null)))
      AND ((recinfo.Applicability_Rule_Flag = X_Applicability_Rule_Flag)
           OR ((recinfo.Applicability_Rule_Flag is null) AND (X_Applicability_Rule_Flag is null)))
      AND ((recinfo.Place_Of_Supply_Rule_Flag = X_Place_Of_Supply_Rule_Flag)
           OR ((recinfo.Place_Of_Supply_Rule_Flag is null) AND (X_Place_Of_Supply_Rule_Flag is null)))
      AND ((recinfo.Tax_Calc_Rule_Flag = X_Tax_Calc_Rule_Flag)
           OR ((recinfo.Tax_Calc_Rule_Flag is null) AND (X_Tax_Calc_Rule_Flag is null)))
      AND ((recinfo.Taxable_Basis_Thrshld_Flag = X_Taxable_Basis_Thrshld_Flag)
           OR ((recinfo.Taxable_Basis_Thrshld_Flag is null) AND (X_Taxable_Basis_Thrshld_Flag is null)))
      AND ((recinfo.Tax_Rate_Thrshld_Flag = X_Tax_Rate_Thrshld_Flag)
           OR ((recinfo.Tax_Rate_Thrshld_Flag is null) AND (X_Tax_Rate_Thrshld_Flag is null)))
      AND ((recinfo.Tax_Amt_Thrshld_Flag = X_Tax_Amt_Thrshld_Flag)
           OR ((recinfo.Tax_Amt_Thrshld_Flag is null) AND (X_Tax_Amt_Thrshld_Flag is null)))
      AND ((recinfo.Tax_Rate_Rule_Flag = X_Tax_Rate_Rule_Flag)
           OR ((recinfo.Tax_Rate_Rule_Flag is null) AND (X_Tax_Rate_Rule_Flag is null)))
      AND ((recinfo.Taxable_Basis_Rule_Flag = X_Taxable_Basis_Rule_Flag)
           OR ((recinfo.Taxable_Basis_Rule_Flag is null) AND (X_Taxable_Basis_Rule_Flag is null)))
      AND ((recinfo.Def_Inclusive_Tax_Flag = X_Def_Inclusive_Tax_Flag)
           OR ((recinfo.Def_Inclusive_Tax_Flag is null) AND (X_Def_Inclusive_Tax_Flag is null)))
      AND ((recinfo.Has_Other_Jurisdictions_Flag = X_Has_Other_Jurisdictions_Flag)
           OR ((recinfo.Has_Other_Jurisdictions_Flag is null) AND (X_Has_Other_Jurisdictions_Flag is null)))
      AND ((recinfo.Allow_Rounding_Override_Flag = X_Allow_Rounding_Override_Flag)
           OR ((recinfo.Allow_Rounding_Override_Flag is null) AND (X_Allow_Rounding_Override_Flag is null)))
      AND ((recinfo.Allow_Exemptions_Flag = X_Allow_Exemptions_Flag)
           OR ((recinfo.Allow_Exemptions_Flag is null) AND (X_Allow_Exemptions_Flag is null)))
      AND ((recinfo.Allow_Exceptions_Flag = X_Allow_Exceptions_Flag)
           OR ((recinfo.Allow_Exceptions_Flag is null) AND (X_Allow_Exceptions_Flag is null)))
      AND ((recinfo.Allow_Recoverability_Flag = X_Allow_Recoverability_Flag)
           OR ((recinfo.Allow_Recoverability_Flag is null) AND (X_Allow_Recoverability_Flag is null)))
      AND ((recinfo.Auto_Prvn_Flag = X_Auto_Prvn_Flag)
           OR ((recinfo.Auto_Prvn_Flag is null) AND (X_Auto_Prvn_Flag is null)))
      AND ((recinfo.Has_Tax_Det_Date_Rule_Flag = X_Has_Tax_Det_Date_Rule_Flag)
           OR ((recinfo.Has_Tax_Det_Date_Rule_Flag is null) AND (X_Has_Tax_Det_Date_Rule_Flag is null)))
      AND ((recinfo.Has_Exch_Rate_Date_Rule_Flag = X_Has_Exch_Rate_Date_Rule_Flag)
           OR ((recinfo.Has_Exch_Rate_Date_Rule_Flag is null) AND (X_Has_Exch_Rate_Date_Rule_Flag is null)))
      AND ((recinfo.Has_Tax_Point_Date_Rule_Flag = X_Has_Tax_Point_Date_Rule_Flag)
           OR ((recinfo.Has_Tax_Point_Date_Rule_Flag is null) AND (X_Has_Tax_Point_Date_Rule_Flag is null)))
      AND ((recinfo.Use_Legal_Msg_Flag = X_Use_Legal_Msg_Flag)
           OR ((recinfo.Use_Legal_Msg_Flag is null) AND (X_Use_Legal_Msg_Flag is null)))
      AND ((recinfo.Def_Rec_Settlement_Option_Code = X_Def_Rec_Settlement_Option_Co)
           OR ((recinfo.Def_Rec_Settlement_Option_Code is null) AND (X_Def_Rec_Settlement_Option_Co is null)))
      AND ((recinfo.Regn_Num_Same_As_Le_Flag = X_Regn_Num_Same_As_Le_Flag)
           OR ((recinfo.Regn_Num_Same_As_Le_Flag is null) AND (X_Regn_Num_Same_As_Le_Flag is null)))
      AND ((recinfo.Record_Type_Code = X_Record_Type_Code)
           OR ((recinfo.Record_Type_Code is null) AND (X_Record_Type_Code is null)))
      AND ((recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
           OR ((recinfo.PROGRAM_APPLICATION_ID is null) AND (X_PROGRAM_APPLICATION_ID is null)))
      AND ((recinfo.PROGRAM_ID = X_PROGRAM_ID)
           OR ((recinfo.PROGRAM_ID is null) AND (X_PROGRAM_ID is null)))
      AND ((recinfo.Program_Login_Id = X_Program_Login_Id)
           OR ((recinfo.Program_Login_Id is null) AND (X_Program_Login_Id is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
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
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.Def_Registr_Party_Type_Code = X_Def_Registr_Party_Type_Code)
           OR ((recinfo.Def_Registr_Party_Type_Code is null) AND (X_Def_Registr_Party_Type_Code is null)))
      AND ((recinfo.Registration_Type_Rule_Flag = X_Registration_Type_Rule_Flag)
           OR ((recinfo.Registration_Type_Rule_Flag is null) AND (X_Registration_Type_Rule_Flag is null)))
      AND ((recinfo.Tax_Inclusive_Override_Flag = X_Tax_Inclusive_Override_Flag)
           OR ((recinfo.Tax_Inclusive_Override_Flag is null) AND (X_Tax_Inclusive_Override_Flag is null)))
      AND ((recinfo.REGIME_PRECEDENCE = X_REGIME_PRECEDENCE)
           OR ((recinfo.REGIME_PRECEDENCE is null) AND (X_REGIME_PRECEDENCE is null)))
      AND ((recinfo.Cross_Regime_Compounding_Flag = X_Cross_Regime_Compounding_Fla)
           OR ((recinfo.Cross_Regime_Compounding_Flag is null) AND (X_Cross_Regime_Compounding_Fla is null)))
      AND ((recinfo.TAX_ACCOUNT_PRECEDENCE_CODE = X_TAX_ACCOUNT_PRECEDENCE_CODE)
           OR ((recinfo.TAX_ACCOUNT_PRECEDENCE_CODE is null) AND (X_TAX_ACCOUNT_PRECEDENCE_CODE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.TAX_REGIME_NAME = X_TAX_REGIME_NAME)
               OR ((tlinfo.TAX_REGIME_NAME is null) AND (X_TAX_REGIME_NAME is null)))
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
  X_TAX_REGIME_ID in NUMBER,
  X_PARENT_REGIME_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_Has_Sub_Regime_Flag in VARCHAR2,
  X_Country_Or_Group_Code in VARCHAR2,
  X_COUNTRY_CODE in VARCHAR2,
  X_GEOGRAPHY_TYPE in VARCHAR2,
  X_GEOGRAPHY_ID in NUMBER,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_EXCHANGE_RATE_TYPE in VARCHAR2,
  X_TAX_CURRENCY_CODE in VARCHAR2,
  X_Thrshld_Grouping_Lvl_Code in VARCHAR2,
  X_Thrshld_Chk_Tmplt_Code in VARCHAR2,
  X_PERIOD_SET_NAME in VARCHAR2,
  X_REP_TAX_AUTHORITY_ID in NUMBER,
  X_COLL_TAX_AUTHORITY_ID in NUMBER,
  X_Rounding_Rule_Code in VARCHAR2,
  X_TAX_PRECISION in NUMBER,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_Tax_Status_Rule_Flag in VARCHAR2,
  X_Def_Place_Of_Supply_Type_Cod in VARCHAR2,
  X_Applicability_Rule_Flag in VARCHAR2,
  X_Place_Of_Supply_Rule_Flag in VARCHAR2,
  X_Tax_Calc_Rule_Flag in VARCHAR2,
  X_Taxable_Basis_Thrshld_Flag in VARCHAR2,
  X_Tax_Rate_Thrshld_Flag in VARCHAR2,
  X_Tax_Amt_Thrshld_Flag in VARCHAR2,
  X_Tax_Rate_Rule_Flag in VARCHAR2,
  X_Taxable_Basis_Rule_Flag in VARCHAR2,
  X_Def_Inclusive_Tax_Flag in VARCHAR2,
  X_Has_Other_Jurisdictions_Flag in VARCHAR2,
  X_Allow_Rounding_Override_Flag in VARCHAR2,
  X_Allow_Exemptions_Flag in VARCHAR2,
  X_Allow_Exceptions_Flag in VARCHAR2,
  X_Allow_Recoverability_Flag in VARCHAR2,
  X_Auto_Prvn_Flag in VARCHAR2,
  X_Has_Tax_Det_Date_Rule_Flag in VARCHAR2,
  X_Has_Exch_Rate_Date_Rule_Flag in VARCHAR2,
  X_Has_Tax_Point_Date_Rule_Flag in VARCHAR2,
  X_Use_Legal_Msg_Flag in VARCHAR2,
  X_Regn_Num_Same_As_Le_Flag in VARCHAR2,
  X_Def_Rec_Settlement_Option_Co in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_Def_Registr_Party_Type_Code in VARCHAR2,
  X_Registration_Type_Rule_Flag in VARCHAR2,
  X_Tax_Inclusive_Override_Flag in VARCHAR2,
  X_REGIME_PRECEDENCE in NUMBER,
  X_Cross_Regime_Compounding_Fla in VARCHAR2,
  X_TAX_REGIME_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_TAX_ACCOUNT_PRECEDENCE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is

CURSOR C1 is
       SELECT
       REP_TAX_AUTHORITY_ID,
       COLL_TAX_AUTHORITY_ID
       FROM ZX_REGIMES_VL
       WHERE TAX_REGIME_CODE = X_TAX_REGIME_CODE;
R1     C1%rowtype;

update_flg  BOOLEAN;
err_stat    VARCHAR2(30);

begin

   update_flg := FALSE;
   err_stat   := FND_API.G_RET_STS_SUCCESS;

   OPEN C1;
    FETCH C1 INTO R1;
   CLOSE C1;
  update ZX_REGIMES_B set
    PARENT_REGIME_CODE = X_PARENT_REGIME_CODE,
    TAX_REGIME_CODE = X_TAX_REGIME_CODE,
    Has_Sub_Regime_Flag = X_Has_Sub_Regime_Flag,
    Country_Or_Group_Code = X_Country_Or_Group_Code,
    COUNTRY_CODE = X_COUNTRY_CODE,
    GEOGRAPHY_TYPE = X_GEOGRAPHY_TYPE,
    GEOGRAPHY_ID = X_GEOGRAPHY_ID,
    EFFECTIVE_FROM = X_EFFECTIVE_FROM,
    EFFECTIVE_TO = X_EFFECTIVE_TO,
    EXCHANGE_RATE_TYPE = X_EXCHANGE_RATE_TYPE,
    TAX_CURRENCY_CODE = X_TAX_CURRENCY_CODE,
    Thrshld_Grouping_Lvl_Code = X_Thrshld_Grouping_Lvl_Code,
    Thrshld_Chk_Tmplt_Code = X_Thrshld_Chk_Tmplt_Code,
    PERIOD_SET_NAME = X_PERIOD_SET_NAME,
    REP_TAX_AUTHORITY_ID = X_REP_TAX_AUTHORITY_ID,
    COLL_TAX_AUTHORITY_ID = X_COLL_TAX_AUTHORITY_ID,
    Rounding_Rule_Code = X_Rounding_Rule_Code,
    TAX_PRECISION = X_TAX_PRECISION,
    MINIMUM_ACCOUNTABLE_UNIT = X_MINIMUM_ACCOUNTABLE_UNIT,
    Tax_Status_Rule_Flag = X_Tax_Status_Rule_Flag,
    Def_Place_Of_Supply_Type_Code = X_Def_Place_Of_Supply_Type_Cod,
    Applicability_Rule_Flag = X_Applicability_Rule_Flag,
    Place_Of_Supply_Rule_Flag = X_Place_Of_Supply_Rule_Flag,
    Tax_Calc_Rule_Flag = X_Tax_Calc_Rule_Flag,
    Taxable_Basis_Thrshld_Flag = X_Taxable_Basis_Thrshld_Flag,
    Tax_Rate_Thrshld_Flag = X_Tax_Rate_Thrshld_Flag,
    Tax_Amt_Thrshld_Flag = X_Tax_Amt_Thrshld_Flag,
    Tax_Rate_Rule_Flag = X_Tax_Rate_Rule_Flag,
    Taxable_Basis_Rule_Flag = X_Taxable_Basis_Rule_Flag,
    Def_Inclusive_Tax_Flag = X_Def_Inclusive_Tax_Flag,
    Has_Other_Jurisdictions_Flag = X_Has_Other_Jurisdictions_Flag,
    Allow_Rounding_Override_Flag = X_Allow_Rounding_Override_Flag,
    Allow_Exemptions_Flag = X_Allow_Exemptions_Flag,
    Allow_Exceptions_Flag = X_Allow_Exceptions_Flag,
    Allow_Recoverability_Flag = X_Allow_Recoverability_Flag,
    Auto_Prvn_Flag = X_Auto_Prvn_Flag,
    Has_Tax_Det_Date_Rule_Flag = X_Has_Tax_Det_Date_Rule_Flag,
    Has_Exch_Rate_Date_Rule_Flag = X_Has_Exch_Rate_Date_Rule_Flag,
    Has_Tax_Point_Date_Rule_Flag = X_Has_Tax_Point_Date_Rule_Flag,
    Use_Legal_Msg_Flag = X_Use_Legal_Msg_Flag,
    Regn_Num_Same_As_Le_Flag =  X_Regn_Num_Same_As_Le_Flag,
    Def_Rec_Settlement_Option_Code  = X_Def_Rec_Settlement_Option_Co,
    Record_Type_Code = X_Record_Type_Code,
    PROGRAM_APPLICATION_ID  = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    Program_Login_Id = X_Program_Login_Id,
    REQUEST_ID = X_REQUEST_ID,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    Def_Registr_Party_Type_Code = X_Def_Registr_Party_Type_Code,
    Registration_Type_Rule_Flag = X_Registration_Type_Rule_Flag,
    Tax_Inclusive_Override_Flag = X_Tax_Inclusive_Override_Flag,
    REGIME_PRECEDENCE = X_REGIME_PRECEDENCE,
    Cross_Regime_Compounding_Flag = X_Cross_Regime_Compounding_Fla,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    TAX_ACCOUNT_PRECEDENCE_CODE = X_TAX_ACCOUNT_PRECEDENCE_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
  where TAX_REGIME_ID = X_TAX_REGIME_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  update ZX_REGIMES_TL set
    TAX_REGIME_NAME = X_TAX_REGIME_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TAX_REGIME_ID = X_TAX_REGIME_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    raise no_data_found;
  end if;
     -- Update zx_regime_relations table
        zx_reg_rel_pub.update_rel(err_stat,X_TAX_REGIME_CODE,X_PARENT_REGIME_CODE,
	X_LAST_UPDATED_BY, X_LAST_UPDATE_DATE,
	X_LAST_UPDATE_LOGIN, X_REQUEST_ID, X_PROGRAM_ID,
	X_PROGRAM_LOGIN_ID, X_PROGRAM_APPLICATION_ID);

      if(err_stat <> FND_API.G_RET_STS_SUCCESS) then
          raise no_data_found;
      end if;
      --Update zx_taxes_vl table if the rep_tax_auth_id or coll_tax_auth_id has been updated
      -- Check if update of reporting tax authority id or collecting tax authority has occurred..
		if(nvl(X_REP_TAX_AUTHORITY_ID,-9999) <> nvl(R1.REP_TAX_AUTHORITY_ID,-9999)) OR
                  (nvl(X_COLL_TAX_AUTHORITY_ID,-9999) <> nvl(R1.COLL_TAX_AUTHORITY_ID,-9999)) THEN
                        zx_reg_rel_pub.update_taxes(err_stat,X_TAX_REGIME_CODE,R1.REP_TAX_AUTHORITY_ID,
                              R1.COLL_TAX_AUTHORITY_ID,X_REP_TAX_AUTHORITY_ID,X_COLL_TAX_AUTHORITY_ID);
		END IF;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TAX_REGIME_ID in NUMBER
) is
begin
  delete from ZX_REGIMES_TL
  where TAX_REGIME_ID = X_TAX_REGIME_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  delete from ZX_REGIMES_B
  where TAX_REGIME_ID = X_TAX_REGIME_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ZX_REGIMES_TL T
  where not exists
    (select NULL
    from ZX_REGIMES_B B
    where B.TAX_REGIME_ID = T.TAX_REGIME_ID
    );
  update ZX_REGIMES_TL T set (
      TAX_REGIME_NAME
    ) = (select
      B.TAX_REGIME_NAME
    from ZX_REGIMES_TL B
    where B.TAX_REGIME_ID = T.TAX_REGIME_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAX_REGIME_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TAX_REGIME_ID,
      SUBT.LANGUAGE
    from ZX_REGIMES_TL SUBB, ZX_REGIMES_TL SUBT
    where SUBB.TAX_REGIME_ID = SUBT.TAX_REGIME_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TAX_REGIME_NAME <> SUBT.TAX_REGIME_NAME
      or (SUBB.TAX_REGIME_NAME is null and SUBT.TAX_REGIME_NAME is not null)
      or (SUBB.TAX_REGIME_NAME is not null and SUBT.TAX_REGIME_NAME is null)
  ));
  insert into ZX_REGIMES_TL (
    TAX_REGIME_ID,
    TAX_REGIME_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TAX_REGIME_ID,
    B.TAX_REGIME_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ZX_REGIMES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ZX_REGIMES_TL T
    where T.TAX_REGIME_ID = B.TAX_REGIME_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ZX_REGIMES_PKG;

/
