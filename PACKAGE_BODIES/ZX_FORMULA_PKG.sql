--------------------------------------------------------
--  DDL for Package Body ZX_FORMULA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_FORMULA_PKG" as
/* $Header: zxdformulab.pls 120.9 2005/10/21 22:06:41 rsanthan ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FORMULA_ID in NUMBER,
  X_Formula_Type_Code in VARCHAR2,
  X_FORMULA_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_Taxable_Basis_Type_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_BASE_RATE_MODIFIER in NUMBER,
  X_Cash_Discount_Appl_Flag in VARCHAR2,
  X_Volume_Discount_Appl_Flag in VARCHAR2,
  X_Trading_Discount_Appl_Flag in VARCHAR2,
  X_Transfer_Charge_Appl_Flag in VARCHAR2,
  X_TRANSPORT_CHARGE_APPL_FLAG in VARCHAR2,
  X_Insurance_Charge_Appl_Flag in VARCHAR2,
  X_Other_Charge_Appl_Flag in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_FORMULA_NAME in VARCHAR2,
  X_FORMULA_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_Enabled_Flag in VARCHAR2,
  X_CONTENT_OWNER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER) is

  cursor C is select ROWID from ZX_FORMULA_B
    where FORMULA_ID = X_FORMULA_ID ;
begin
  insert into ZX_FORMULA_B (
    FORMULA_ID,
    Formula_Type_Code,
    FORMULA_CODE,
    TAX_REGIME_CODE,
    TAX,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    Taxable_Basis_Type_Code,
    Record_Type_Code,
    BASE_RATE_MODIFIER,
    Cash_Discount_Appl_Flag,
    Volume_Discount_Appl_Flag,
    Trading_Discount_Appl_Flag,
    Transfer_Charge_Appl_Flag,
    Transport_Charge_Appl_Flag,
    Insurance_Charge_Appl_Flag,
    Other_Charge_Appl_Flag,
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
    REQUEST_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    Enabled_Flag,
    CONTENT_OWNER_ID,
    OBJECT_VERSION_NUMBER)
values (
    X_FORMULA_ID,
    X_Formula_Type_Code,
    X_FORMULA_CODE,
    X_TAX_REGIME_CODE,
    X_TAX,
    X_EFFECTIVE_FROM,
    X_EFFECTIVE_TO,
    X_Taxable_Basis_Type_Code,
    X_Record_Type_Code,
    X_BASE_RATE_MODIFIER,
    NVL(X_Cash_Discount_Appl_Flag,'N'),
    NVL(X_Volume_Discount_Appl_Flag,'N'),
    NVL(X_Trading_Discount_Appl_Flag,'N'),
    NVL(X_Transfer_Charge_Appl_Flag,'N'),
    NVL(X_TRANSPORT_CHARGE_APPL_FLAG,'N'),
    NVL(X_Insurance_Charge_Appl_Flag,'N'),
    NVL(X_Other_Charge_Appl_Flag,'N'),
    X_ATTRIBUTE_CATEGORY,
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
    X_ATTRIBUTE16,
    X_ATTRIBUTE17,
    X_ATTRIBUTE18,
    X_ATTRIBUTE19,
    X_ATTRIBUTE20,
    X_REQUEST_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_PROGRAM_LOGIN_ID,
    NVL(X_ENABLED_FLAG,'N'),
    X_CONTENT_OWNER_ID,
    X_OBJECT_VERSION_NUMBER);

  insert into ZX_FORMULA_TL (
    FORMULA_ID,
    FORMULA_NAME,
    FORMULA_DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  select
    X_FORMULA_ID,
    X_FORMULA_NAME,
    X_FORMULA_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ZX_FORMULA_TL T
    where T.FORMULA_ID = X_FORMULA_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end INSERT_ROW;

procedure LOCK_ROW (
  X_FORMULA_ID in NUMBER,
  X_Formula_Type_Code in VARCHAR2,
  X_FORMULA_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_Taxable_Basis_Type_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_BASE_RATE_MODIFIER in NUMBER,
  X_Cash_Discount_Appl_Flag in VARCHAR2,
  X_Volume_Discount_Appl_Flag in VARCHAR2,
  X_Trading_Discount_Appl_Flag in VARCHAR2,
  X_Transfer_Charge_Appl_Flag in VARCHAR2,
  X_TRANSPORT_CHARGE_APPL_FLAG in VARCHAR2,
  X_Insurance_Charge_Appl_Flag in VARCHAR2,
  X_Other_Charge_Appl_Flag in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_FORMULA_NAME in VARCHAR2,
  X_FORMULA_DESCRIPTION in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_Enabled_Flag in VARCHAR2,
  X_CONTENT_OWNER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER) is

  cursor c is select
      Formula_Type_Code,
      FORMULA_CODE,
      TAX_REGIME_CODE,
      TAX,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      Taxable_Basis_Type_Code,
      Record_Type_Code,
      BASE_RATE_MODIFIER,
      Cash_Discount_Appl_Flag,
      Volume_Discount_Appl_Flag,
      Trading_Discount_Appl_Flag,
      Transfer_Charge_Appl_Flag,
      Transport_Charge_Appl_Flag,
      Insurance_Charge_Appl_Flag,
      Other_Charge_Appl_Flag,
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
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_LOGIN_ID,
      Enabled_Flag,
      CONTENT_OWNER_ID,
      OBJECT_VERSION_NUMBER
    from ZX_FORMULA_B
    where FORMULA_ID = X_FORMULA_ID
    for update of FORMULA_ID nowait;

  recinfo c%rowtype;

  cursor c1 is select FORMULA_NAME,
                      FORMULA_DESCRIPTION,
                      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
                 from ZX_FORMULA_TL
                where FORMULA_ID = X_FORMULA_ID
                  and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
                  for update of FORMULA_ID nowait;
begin

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (    (recinfo.Formula_Type_Code = X_Formula_Type_Code)
      AND (recinfo.FORMULA_CODE = X_FORMULA_CODE)
      AND ((recinfo.TAX_REGIME_CODE = X_TAX_REGIME_CODE)
           OR ((recinfo.TAX_REGIME_CODE is null) AND (X_TAX_REGIME_CODE is null)))
      AND ((recinfo.TAX = X_TAX)
           OR ((recinfo.TAX is null) AND (X_TAX is null)))
      AND (recinfo.EFFECTIVE_FROM = X_EFFECTIVE_FROM)
      AND ((recinfo.EFFECTIVE_TO = X_EFFECTIVE_TO)
           OR ((recinfo.EFFECTIVE_TO is null) AND (X_EFFECTIVE_TO is null)))
      AND ((recinfo.Taxable_Basis_Type_Code = X_Taxable_Basis_Type_Code)
           OR ((recinfo.Taxable_Basis_Type_Code is null) AND (X_Taxable_Basis_Type_Code is null)))
      AND (recinfo.Record_Type_Code = X_Record_Type_Code)
      AND ((recinfo.BASE_RATE_MODIFIER = X_BASE_RATE_MODIFIER)
           OR ((recinfo.BASE_RATE_MODIFIER is null) AND (X_BASE_RATE_MODIFIER is null)))
      AND ((recinfo.Cash_Discount_Appl_Flag = X_Cash_Discount_Appl_Flag)
           OR ((recinfo.Cash_Discount_Appl_Flag is null) AND (X_Cash_Discount_Appl_Flag is null)))
      AND ((recinfo.Volume_Discount_Appl_Flag = X_Volume_Discount_Appl_Flag)
           OR ((recinfo.Volume_Discount_Appl_Flag is null) AND (X_Volume_Discount_Appl_Flag is null)))
      AND ((recinfo.Trading_Discount_Appl_Flag = X_Trading_Discount_Appl_Flag)
           OR ((recinfo.Trading_Discount_Appl_Flag is null) AND (X_Trading_Discount_Appl_Flag is null)
))
      AND ((recinfo.Transfer_Charge_Appl_Flag = X_Transfer_Charge_Appl_Flag)
           OR ((recinfo.Transfer_Charge_Appl_Flag is null) AND (X_Transfer_Charge_Appl_Flag is null)))
      AND ((recinfo.Transport_Charge_Appl_Flag = X_TRANSPORT_CHARGE_APPL_FLAG)
           OR ((recinfo.Transport_Charge_Appl_Flag is null) AND (X_TRANSPORT_CHARGE_APPL_FLAG
is null)))
      AND ((recinfo.Insurance_Charge_Appl_Flag = X_Insurance_Charge_Appl_Flag)
           OR ((recinfo.Insurance_Charge_Appl_Flag is null) AND (X_Insurance_Charge_Appl_Flag is null)
))
      AND ((recinfo.Other_Charge_Appl_Flag = X_Other_Charge_Appl_Flag)
           OR ((recinfo.Other_Charge_Appl_Flag is null) AND (X_Other_Charge_Appl_Flag is null)))
      AND ((recinfo.Enabled_Flag = X_Enabled_Flag)
           OR ((recinfo.Enabled_Flag is null) AND (X_Enabled_Flag is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
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
      AND ((recinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR ((recinfo.ATTRIBUTE16 is null) AND (X_ATTRIBUTE16 is null)))
      AND ((recinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
           OR ((recinfo.ATTRIBUTE17 is null) AND (X_ATTRIBUTE17 is null)))
      AND ((recinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
           OR ((recinfo.ATTRIBUTE18 is null) AND (X_ATTRIBUTE18 is null)))
      AND ((recinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
           OR ((recinfo.ATTRIBUTE19 is null) AND (X_ATTRIBUTE19 is null)))
      AND ((recinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
           OR ((recinfo.ATTRIBUTE20 is null) AND (X_ATTRIBUTE20 is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
           OR ((recinfo.PROGRAM_APPLICATION_ID is null) AND (X_PROGRAM_APPLICATION_ID is null)))
      AND ((recinfo. PROGRAM_ID = X_PROGRAM_ID)
           OR ((recinfo.PROGRAM_ID is null) AND (X_PROGRAM_ID is null)))
      AND ((recinfo.PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID)
           OR ((recinfo.PROGRAM_LOGIN_ID is null) AND (X_PROGRAM_LOGIN_ID is null)))
      AND ((recinfo.CONTENT_OWNER_ID = X_CONTENT_OWNER_ID)
           OR ((recinfo.CONTENT_OWNER_ID is null) AND (X_CONTENT_OWNER_ID is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.FORMULA_NAME = X_FORMULA_NAME)
          AND ((tlinfo.FORMULA_DESCRIPTION = X_FORMULA_DESCRIPTION)
               OR ((tlinfo.FORMULA_DESCRIPTION is null) AND (X_FORMULA_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_FORMULA_ID in NUMBER,
  X_Formula_Type_Code in VARCHAR2,
  X_FORMULA_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_Taxable_Basis_Type_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_BASE_RATE_MODIFIER in NUMBER,
  X_Cash_Discount_Appl_Flag in VARCHAR2,
  X_Volume_Discount_Appl_Flag in VARCHAR2,
  X_Trading_Discount_Appl_Flag in VARCHAR2,
  X_Transfer_Charge_Appl_Flag in VARCHAR2,
  X_TRANSPORT_CHARGE_APPL_FLAG in VARCHAR2,
  X_Insurance_Charge_Appl_Flag in VARCHAR2,
  X_Other_Charge_Appl_Flag in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_FORMULA_NAME in VARCHAR2,
  X_FORMULA_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_Enabled_Flag in VARCHAR2,
  X_CONTENT_OWNER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER) is

CURSOR C1 is select Enabled_Flag
               from ZX_FORMULA_VL
              WHERE FORMULA_ID = X_FORMULA_ID;

CURSOR C_PROC_RES is SELECT TAX_RULE_ID,
                            RESULT_ID
                       FROM ZX_PROCESS_RESULTS
                      WHERE Result_Type_Code =  'FORMULA'
                        AND Enabled_Flag = 'Y'
                        AND NUMERIC_RESULT = X_FORMULA_ID;

CURSOR C_RES_RULE_ID(p_cur_rule_id NUMBER, p_cur_result_id NUMBER) is
       SELECT TAX_RULE_ID
         FROM ZX_PROCESS_RESULTS
        WHERE TAX_RULE_ID = p_cur_rule_id
          and Enabled_Flag = 'Y'
          and RESULT_ID <> p_cur_result_id;

CURSOR C_RULE_REC (p_cur_rule_id1 NUMBER) is
       SELECT *
         FROM ZX_RULES_VL
        WHERE TAX_RULE_ID =  p_cur_rule_id1;

p_rule_rec ZX_RULES_VL%ROWTYPE;
p_rule_id1 NUMBER;
p_Enabled_Flag VARCHAR2(1);
p_rule_id NUMBER;
p_result_id NUMBER;
ctr NUMBER;

begin

   -- Logic to update ZX_PROCESS_RESULTS and ZX_RULES tables,
   -- to disable the associated results  and rules of this formula*/
   OPEN C1;
   FETCH C1 INTO p_Enabled_Flag;
   CLOSE C1;
   if p_Enabled_Flag = 'Y' and X_Enabled_Flag = 'N'then
      OPEN C_PROC_RES;
      LOOP
        FETCH C_PROC_RES into p_rule_id,p_result_id;
        EXIT WHEN C_PROC_RES%NOTFOUND;
        OPEN C_RES_RULE_ID(p_rule_id,p_result_id);
        FETCH C_RES_RULE_ID into p_rule_id1;

        if nvl(p_rule_id1,0) = 0 THEN
           OPEN C_RULE_REC(p_rule_id);
           LOOP
                FETCH C_RULE_REC INTO p_rule_rec;
                EXIT WHEN C_RULE_REC%NOTFOUND;
                ZX_RULES_PKG.UPDATE_ROW(
                             p_rule_id,
                             p_rule_rec.TAX_RULE_CODE ,
                             p_rule_rec.TAX,
                             p_rule_rec.TAX_REGIME_CODE ,
                             p_rule_rec.SERVICE_TYPE_CODE ,
                             p_rule_rec.RECOVERY_TYPE_CODE ,
                             p_rule_rec.PRIORITY  ,
                             p_rule_rec.System_Default_Flag ,
                             p_rule_rec.EFFECTIVE_FROM ,
                             p_rule_rec.EFFECTIVE_TO ,
                             p_rule_rec.Record_Type_Code ,
                             p_rule_rec.REQUEST_ID ,
                             p_rule_rec.TAX_RULE_NAME ,
                             p_rule_rec.TAX_RULE_DESC ,
                             p_rule_rec.LAST_UPDATE_DATE ,
                             p_rule_rec.LAST_UPDATED_BY ,
                             p_rule_rec.LAST_UPDATE_LOGIN ,
                             p_rule_rec.PROGRAM_APPLICATION_ID ,
                             p_rule_rec.PROGRAM_ID ,
                             p_rule_rec.PROGRAM_LOGIN_ID ,
                             'N',
                             p_rule_rec.APPLICATION_ID ,
                             p_rule_rec.CONTENT_OWNER_ID ,
                             p_rule_rec.DET_FACTOR_TEMPL_CODE,
                             p_rule_rec.EVENT_CLASS_MAPPING_ID,
                             p_rule_rec.TAX_EVENT_CLASS_CODE,
                             p_rule_rec.OBJECT_VERSION_NUMBER,
                    p_rule_rec.DETERMINING_FACTOR_CQ_CODE,
                    p_rule_rec.GEOGRAPHY_TYPE            ,
                    p_rule_rec.GEOGRAPHY_ID              ,
                    p_rule_rec.TAX_LAW_REF_CODE          ,
                    p_rule_rec.TAX_LAW_REF_DESC          ,
                    p_rule_rec.LAST_UPDATE_MODE_FLAG     ,
                    p_rule_rec.NEVER_BEEN_ENABLED_FLAG  );
           end loop;
           CLOSE C_RULE_REC;
        END IF;
        CLOSE C_RES_RULE_ID;
      END LOOP;
      CLOSE C_PROC_RES;

      UPDATE ZX_PROCESS_RESULTS
         SET Enabled_Flag = 'N'
       WHERE Result_Type_Code = 'FORMULA'
         AND Enabled_Flag = 'Y'
         AND NUMERIC_RESULT = X_FORMULA_ID;
   end if;

   update ZX_FORMULA_B
      set Formula_Type_Code = X_Formula_Type_Code,
          FORMULA_CODE = X_FORMULA_CODE,
          TAX_REGIME_CODE = X_TAX_REGIME_CODE,
          TAX = X_TAX,
          EFFECTIVE_FROM = X_EFFECTIVE_FROM,
          EFFECTIVE_TO = X_EFFECTIVE_TO,
          Taxable_Basis_Type_Code = X_Taxable_Basis_Type_Code,
          Record_Type_Code = X_Record_Type_Code,
          BASE_RATE_MODIFIER = X_BASE_RATE_MODIFIER,
          Cash_Discount_Appl_Flag = NVL(X_Cash_Discount_Appl_Flag,'N'),
          Volume_Discount_Appl_Flag = NVL(X_Volume_Discount_Appl_Flag,'N'),
          Trading_Discount_Appl_Flag = NVL(X_Trading_Discount_Appl_Flag,'N'),
          Transfer_Charge_Appl_Flag = NVL(X_Transfer_Charge_Appl_Flag,'N'),
          Transport_Charge_Appl_Flag = NVL(X_TRANSPORT_CHARGE_APPL_FLAG,'N'),
          Insurance_Charge_Appl_Flag = NVL(X_Insurance_Charge_Appl_Flag,'N'),
          Other_Charge_Appl_Flag = NVL(X_Other_Charge_Appl_Flag,'N'),
          ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
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
          ATTRIBUTE16 = X_ATTRIBUTE16,
          ATTRIBUTE17 = X_ATTRIBUTE17,
          ATTRIBUTE18 = X_ATTRIBUTE18,
          ATTRIBUTE19 = X_ATTRIBUTE19,
          ATTRIBUTE20 = X_ATTRIBUTE20,
          REQUEST_ID = X_REQUEST_ID,
          LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
          PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
          PROGRAM_ID = X_PROGRAM_ID,
          PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID,
          Enabled_Flag = NVL(X_ENABLED_FLAG,'N'),
          CONTENT_OWNER_ID = X_CONTENT_OWNER_ID,
          OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    where FORMULA_ID = X_FORMULA_ID;

   if (sql%notfound) then
     raise no_data_found;
   end if;

   update ZX_FORMULA_TL
      set FORMULA_NAME = X_FORMULA_NAME,
          FORMULA_DESCRIPTION = X_FORMULA_DESCRIPTION,
          LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
          SOURCE_LANG = userenv('LANG')
    where FORMULA_ID = X_FORMULA_ID
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (sql%notfound) then
       raise no_data_found;
     end if;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_FORMULA_ID in NUMBER) is

begin

  delete from ZX_FORMULA_TL
  where FORMULA_ID = X_FORMULA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ZX_FORMULA_B
  where FORMULA_ID = X_FORMULA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ZX_FORMULA_TL T
  where not exists (select NULL
                      from ZX_FORMULA_B B
                     where B.FORMULA_ID = T.FORMULA_ID);

  update ZX_FORMULA_TL T
     set (FORMULA_NAME, FORMULA_DESCRIPTION) =
              (select B.FORMULA_NAME,
                      B.FORMULA_DESCRIPTION
                 from ZX_FORMULA_TL B
                where B.FORMULA_ID = T.FORMULA_ID
                  and B.LANGUAGE = T.SOURCE_LANG)
   where (T.FORMULA_ID,T.LANGUAGE) in
              (select SUBT.FORMULA_ID,
                      SUBT.LANGUAGE
                 from ZX_FORMULA_TL SUBB, ZX_FORMULA_TL SUBT
                where SUBB.FORMULA_ID = SUBT.FORMULA_ID
                  and SUBB.LANGUAGE = SUBT.SOURCE_LANG
                  and (SUBB.FORMULA_NAME <> SUBT.FORMULA_NAME
                      or SUBB.FORMULA_DESCRIPTION <> SUBT.FORMULA_DESCRIPTION
                      or (SUBB.FORMULA_DESCRIPTION is null
                          and SUBT.FORMULA_DESCRIPTION is not null)
                      or (SUBB.FORMULA_DESCRIPTION is not null
                          and SUBT.FORMULA_DESCRIPTION is null)));

  insert into ZX_FORMULA_TL (FORMULA_ID,
                             FORMULA_NAME,
                             FORMULA_DESCRIPTION,
                             CREATION_DATE,
                             CREATED_BY,
                             LAST_UPDATE_DATE,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_LOGIN,
                             LANGUAGE,
                             SOURCE_LANG)
                      select B.FORMULA_ID,
                             B.FORMULA_NAME,
                             B.FORMULA_DESCRIPTION,
                             B.CREATION_DATE,
                             B.CREATED_BY,
                             B.LAST_UPDATE_DATE,
                             B.LAST_UPDATED_BY,
                             B.LAST_UPDATE_LOGIN,
                             L.LANGUAGE_CODE,
                             B.SOURCE_LANG
                        from ZX_FORMULA_TL B, FND_LANGUAGES L
                       where L.INSTALLED_FLAG in ('I', 'B')
                         and B.LANGUAGE = userenv('LANG')
                         and not exists (select NULL
                                           from ZX_FORMULA_TL T
                                          where T.FORMULA_ID = B.FORMULA_ID
                                            and T.LANGUAGE = L.LANGUAGE_CODE);

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end ADD_LANGUAGE;


procedure bulk_insert_formula (
  X_FORMULA_ID                     IN t_formula_id,
  X_Formula_Type_Code                   IN t_formula_type,
  X_FORMULA_CODE                   IN t_formula_code,
  X_TAX_REGIME_CODE                IN t_tax_regime_code,
  X_TAX                            IN t_tax,
  X_EFFECTIVE_FROM                 IN t_effective_from,
  X_EFFECTIVE_TO                   IN t_effective_to,
  X_Taxable_Basis_Type_Code             IN t_taxable_basis_type,
  X_Record_Type_Code                    IN t_record_type,
  X_BASE_RATE_MODIFIER             IN t_base_rate_modifier,
  X_Cash_Discount_Appl_Flag         IN t_cash_discount_appl_flg,
  X_Volume_Discount_Appl_Flag       IN t_volume_discount_appl_flg,
  X_Trading_Discount_Appl_Flag      IN t_trading_discount_appl_flg,
  X_Transfer_Charge_Appl_Flag       IN t_transfer_charge_appl_flg,
  X_TRANSPORT_CHARGE_APPL_FLG      IN t_transport_charge_appl_flg,
  X_Insurance_Charge_Appl_Flag      IN t_insurance_charge_appl_flg,
  X_Other_Charge_Appl_Flag          IN t_other_charge_appl_flg,
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
  X_ATTRIBUTE20                    IN t_attribute20,
  X_FORMULA_NAME                   IN t_formula_name,
  X_FORMULA_DESCRIPTION            IN t_formula_description,
  X_Enabled_Flag                    IN t_enabled_flg,
  X_CONTENT_OWNER_ID               IN t_content_owner_id) is

begin

  if x_formula_id.count <> 0 then
     forall i in x_formula_id.first..x_formula_id.last
       INSERT INTO ZX_FORMULA_B (FORMULA_ID,
                                 Formula_Type_Code,
                                 FORMULA_CODE,
                                 TAX_REGIME_CODE,
                                 TAX,
                                 EFFECTIVE_FROM,
                                 EFFECTIVE_TO,
                                 Taxable_Basis_Type_Code,
                                 Record_Type_Code,
                                 BASE_RATE_MODIFIER,
                                 Cash_Discount_Appl_Flag,
                                 Volume_Discount_Appl_Flag,
                                 Trading_Discount_Appl_Flag,
                                 Transfer_Charge_Appl_Flag,
                                 Transport_Charge_Appl_Flag,
                                 Insurance_Charge_Appl_Flag,
                                 Other_Charge_Appl_Flag,
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
                                 Enabled_Flag,
                                 CONTENT_OWNER_ID,
                                 CREATED_BY             ,
                                 CREATION_DATE          ,
                                 LAST_UPDATED_BY        ,
                                 LAST_UPDATE_DATE       ,
                                 LAST_UPDATE_LOGIN      ,
                                 REQUEST_ID             ,
                                 PROGRAM_APPLICATION_ID ,
                                 PROGRAM_ID             ,
                                 PROGRAM_LOGIN_ID)
                        values ( X_FORMULA_ID(i),
                                 X_Formula_Type_Code(i),
                                 X_FORMULA_CODE(i),
                                 X_TAX_REGIME_CODE(i),
                                 X_TAX(i),
                                 X_EFFECTIVE_FROM(i),
                                 X_EFFECTIVE_TO(i),
                                 X_Taxable_Basis_Type_Code(i),
                                 X_Record_Type_Code(i),
                                 X_BASE_RATE_MODIFIER(i),
                                 NVL(X_Cash_Discount_Appl_Flag(i),'N'),
                                 NVL(X_Volume_Discount_Appl_Flag(i),'N'),
                                 NVL(X_Trading_Discount_Appl_Flag(i),'N'),
                                 NVL(X_Transfer_Charge_Appl_Flag(i),'N'),
                                 NVL(X_TRANSPORT_CHARGE_APPL_FLG(i),'N'),
                                 NVL(X_Insurance_Charge_Appl_Flag(i),'N'),
                                 NVL(X_Other_Charge_Appl_Flag(i),'N'),
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
                                 NVL(X_Enabled_Flag(i),'N'),
                                 X_CONTENT_OWNER_ID(i),
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

     forall i in x_formula_id.first..x_formula_id.last
       insert into ZX_FORMULA_TL (FORMULA_ID,
                                  FORMULA_NAME,
                                  FORMULA_DESCRIPTION,
                                  LANGUAGE,
                                  SOURCE_LANG,
                                  CREATED_BY             ,
                                  CREATION_DATE          ,
                                  LAST_UPDATED_BY        ,
                                  LAST_UPDATE_DATE       ,
                                  LAST_UPDATE_LOGIN)
                           select X_FORMULA_ID(i),
                                  X_FORMULA_NAME(i),
                                  X_FORMULA_DESCRIPTION(i),
                                  L.LANGUAGE_CODE,
                                  userenv('LANG'),
                                  fnd_global.user_id         ,
                                  sysdate                    ,
                                  fnd_global.user_id         ,
                                  sysdate                    ,
                                  fnd_global.conc_login_id
                             from FND_LANGUAGES L
                            where L.INSTALLED_FLAG in ('I', 'B')
                              and not exists
                                  (select NULL
                                     from ZX_FORMULA_TL T
                                    where T.FORMULA_ID = X_FORMULA_ID(i)
                                      and T.LANGUAGE = L.LANGUAGE_CODE);
  end if;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end bulk_insert_formula;

end ZX_FORMULA_PKG;

/
