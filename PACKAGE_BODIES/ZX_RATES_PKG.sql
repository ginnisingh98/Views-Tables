--------------------------------------------------------
--  DDL for Package Body ZX_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_RATES_PKG" as
/* $Header: zxcratesb.pls 120.20.12010000.6 2010/03/12 12:00:42 ssohal ship $ */

-- start bug#6992215
----------------------------------------------------------------------------------------------------------
-- Start of comments

-- Procedure Name  : UPDATE_LOOKUP_VALUES
-- Description     : Updating the table: FND_LOOKUP_VALUES for columns: Description  and Meaning
-- Business Rules  :
-- Parameters      : LOOKUP_TYPE,TAX_RATE_CODE,DESCRIPTION, MEANING and one OUT parameter RETURN_STATUS
-- Version         :
-- End of comments
-----------------------------------------------------------------------------------------------------------



PROCEDURE UPDATE_LOOKUP_VALUES (
       P_LOOKUP_TYPE in VARCHAR2,
       P_TAX_RATE_CODE in VARCHAR2,
       P_DESCRIPTION IN VARCHAR2,
       P_MEANING IN VARCHAR2,
       P_EFFECTIVE_FROM IN DATE,
       P_EFFECTIVE_TO IN DATE,
	     X_RETURN_STATUS OUT NOCOPY VARCHAR2
    ) IS

   BEGIN
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

	-- updating the description field in fnd_lookup values
	UPDATE  FND_LOOKUP_VALUES
    SET  description  = P_TAX_RATE_CODE,
         meaning      = P_TAX_RATE_CODE,
         end_date_active   = P_EFFECTIVE_TO,
         last_update_date  = SYSDATE,
         last_updated_by   = FND_GLOBAL.user_id,
         last_update_login = FND_GLOBAL.login_id

    WHERE
       LOOKUP_TYPE = P_LOOKUP_TYPE and
       LOOKUP_CODE = NVL(TAG,P_TAX_RATE_CODE)and
       LANGUAGE =USERENV('LANG');

    IF SQL%ROWCOUNT = 0 THEN
      INSERT_LOOKUP_VALUES(
          P_LOOKUP_TYPE,
          P_TAX_RATE_CODE,
          P_EFFECTIVE_FROM,
          P_EFFECTIVE_TO,
          P_TAX_RATE_CODE,
          P_TAX_RATE_CODE);
    END IF;

   EXCEPTION
    WHEN OTHERS
    THEN
	   X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;

   END UPDATE_LOOKUP_VALUES;

-- end bug#6992215


procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TAX_RATE_ID in NUMBER,
  X_TAX_RATE_CODE in VARCHAR2,
  X_CONTENT_OWNER_ID in NUMBER,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_TAX_STATUS_CODE in VARCHAR2,
  X_Schedule_Based_Rate_Flag in VARCHAR2,
  X_Rate_Type_Code in VARCHAR2,
  X_PERCENTAGE_RATE in NUMBER,
  X_QUANTITY_RATE in NUMBER,
  X_UOM_CODE in VARCHAR2,
  X_TAX_JURISDICTION_CODE in VARCHAR2,
  X_RECOVERY_TYPE_CODE in VARCHAR2,
  X_Active_Flag in VARCHAR2,
  X_Default_Rate_Flag in VARCHAR2,
  X_DEFAULT_FLG_EFFECTIVE_FROM in DATE,
  X_DEFAULT_FLG_EFFECTIVE_TO in DATE,
  X_DEFAULT_REC_TYPE_CODE in VARCHAR2,
  X_DEFAULT_REC_RATE_CODE in VARCHAR2,
  X_OFFSET_TAX in VARCHAR2,
  X_OFFSET_STATUS_CODE in VARCHAR2,
  X_OFFSET_TAX_RATE_CODE in VARCHAR2,
  X_RECOVERY_RULE_CODE in VARCHAR2,
  X_Def_Rec_Settlement_Option_Co in VARCHAR2,
  X_Vat_Transaction_Type_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
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
  X_TAX_RATE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in  NUMBER,
  X_ALLOW_ADHOC_TAX_RATE_FLAG in VARCHAR2,
  X_ADJ_FOR_ADHOC_AMT_CODE in VARCHAR2,
  X_INCLUSIVE_TAX_FLAG in VARCHAR2,
  X_TAX_INCLUSIVE_OVERRIDE_FLAG VARCHAR2,
  X_TAX_CLASS VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ALLOW_EXEMPTIONS_FLAG in VARCHAR2,
  X_ALLOW_EXCEPTIONS_FLAG in VARCHAR2,
  X_SOURCE_ID in NUMBER,
  X_DESCRIPTION IN VARCHAR2,
  X_TAXABLE_BASIS_FORMULA_CODE in VARCHAR2

) is
  X_ORG_ID NUMBER;
  X_TAX_TYPE VARCHAR2(30);
  cursor C is select ROWID from ZX_RATES_B
    where TAX_RATE_ID = X_TAX_RATE_ID    ;
begin
  insert into ZX_RATES_B (
    TAX_RATE_ID,
    TAX_RATE_CODE,
    CONTENT_OWNER_ID,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    TAX_REGIME_CODE,
    TAX,
    TAX_STATUS_CODE,
    Schedule_Based_Rate_Flag,
    Rate_Type_Code,
    PERCENTAGE_RATE,
    QUANTITY_RATE,
    UOM_CODE,
    TAX_JURISDICTION_CODE,
    RECOVERY_TYPE_CODE,
    Active_Flag,
    Default_Rate_Flag,
    DEFAULT_FLG_EFFECTIVE_FROM,
    DEFAULT_FLG_EFFECTIVE_TO,
    DEFAULT_REC_TYPE_CODE,
    DEFAULT_REC_RATE_CODE,
    OFFSET_TAX,
    OFFSET_STATUS_CODE,
    OFFSET_TAX_RATE_CODE,
    RECOVERY_RULE_CODE,
    Def_Rec_Settlement_Option_Code,
    Vat_Transaction_Type_Code,
    Record_Type_Code,
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
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    Program_Login_Id,
    ALLOW_ADHOC_TAX_RATE_FLAG,
    ADJ_FOR_ADHOC_AMT_CODE,
    INCLUSIVE_TAX_FLAG,
    TAX_INCLUSIVE_OVERRIDE_FLAG,
    TAX_CLASS,
    OBJECT_VERSION_NUMBER,
    ALLOW_EXEMPTIONS_FLAG,
    ALLOW_EXCEPTIONS_FLAG,
    SOURCE_ID,
    -- DESCRIPTION, commented as part of fix for bug#	6820043
    TAXABLE_BASIS_FORMULA_CODE
  ) values (
    X_TAX_RATE_ID,
    X_TAX_RATE_CODE,
    X_CONTENT_OWNER_ID,
    X_EFFECTIVE_FROM,
    X_EFFECTIVE_TO,
    X_TAX_REGIME_CODE,
    X_TAX,
    X_TAX_STATUS_CODE,
    X_Schedule_Based_Rate_Flag,
    X_Rate_Type_Code,
    X_PERCENTAGE_RATE,
    X_QUANTITY_RATE,
    X_UOM_CODE,
    X_TAX_JURISDICTION_CODE,
    X_RECOVERY_TYPE_CODE,
    X_Active_Flag,
    X_Default_Rate_Flag,
    X_DEFAULT_FLG_EFFECTIVE_FROM,
    X_DEFAULT_FLG_EFFECTIVE_TO,
    X_DEFAULT_REC_TYPE_CODE,
    X_DEFAULT_REC_RATE_CODE,
    X_OFFSET_TAX,
    X_OFFSET_STATUS_CODE,
    X_OFFSET_TAX_RATE_CODE,
    X_RECOVERY_RULE_CODE,
    X_Def_Rec_Settlement_Option_Co,
    X_Vat_Transaction_Type_Code,
    X_Record_Type_Code,
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
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_Program_Login_Id,
    X_ALLOW_ADHOC_TAX_RATE_FLAG,
    X_ADJ_FOR_ADHOC_AMT_CODE,
    X_INCLUSIVE_TAX_FLAG,
    X_TAX_INCLUSIVE_OVERRIDE_FLAG,
    X_TAX_CLASS,
    X_OBJECT_VERSION_NUMBER,
    X_ALLOW_EXEMPTIONS_FLAG,
    X_ALLOW_EXCEPTIONS_FLAG,
    X_SOURCE_ID,
    -- X_DESCRIPTION, commented as part of fix for bug#	6820043
    X_TAXABLE_BASIS_FORMULA_CODE
  );
  insert into ZX_RATES_TL (
    TAX_RATE_ID,
    TAX_RATE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
	description -- added as part of fix for bug#	6820043
  ) select
    X_TAX_RATE_ID,
    X_TAX_RATE_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG'),
	x_description -- added as part of fix for bug#	6820043
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ZX_RATES_TL T
    where T.TAX_RATE_ID = X_TAX_RATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  --************Added to create lookup types,as per bug 4313618*************
 /*The INSERT_ROW procedure was creating Lookups even when Tax Recovery Rate Code
 * was being created. We did not want this to happen. Lookups should be created
 * only for Tax Rates, not for Tax Recovery Rates. Hence this caondition ws
 * added as fix for Bug 5052500
 */
if (X_RATE_TYPE_CODE <> 'RECOVERY') then
  INSERT_LOOKUP_VALUES(
    'ZX_INPUT_CLASSIFICATIONS' ,
    X_TAX_RATE_CODE ,
    X_EFFECTIVE_FROM,
    X_EFFECTIVE_TO,
   -- start  bug#6992215
    X_TAX_RATE_CODE,
    X_TAX_RATE_CODE
   --end bug#6992215
  );

  INSERT_LOOKUP_VALUES(
    'ZX_OUTPUT_CLASSIFICATIONS' ,
    X_TAX_RATE_CODE ,
    X_EFFECTIVE_FROM,
    X_EFFECTIVE_TO,
    -- start  bug#6992215
    X_TAX_RATE_CODE,
    X_TAX_RATE_CODE
    -- end  bug#6992215
  );
end if;

/*Getting the value of X_ORG_ID on the basis of X_CONTENT_OWNER_ID
* and tax_type_code to be passed
*
*/

SELECT decode(c.party_type_code,'OU',c.party_id,-99) into X_ORG_ID
FROM
	zx_party_tax_profile c
WHERE
c.party_tax_profile_id = X_CONTENT_OWNER_ID;


BEGIN
	SELECT TAX_TYPE_CODE INTO X_TAX_TYPE
	FROM
		ZX_TAXES_B A
	WHERE
		A.TAX = X_TAX
		AND A.TAX_REGIME_CODE = X_TAX_REGIME_CODE
		AND A.CONTENT_OWNER_ID = X_CONTENT_OWNER_ID;


EXCEPTION
	WHEN NO_DATA_FOUND THEN

	SELECT TAX_TYPE_CODE INTO X_TAX_TYPE
	FROM
		ZX_TAXES_B A
	WHERE
		A.TAX = X_TAX
		AND A.TAX_REGIME_CODE = X_TAX_REGIME_CODE
		AND A.CONTENT_OWNER_ID = -99;
END;


/* Calling procedure POPULATE_ID_TCC_MAPPING_ALL to populate the ZX_ID_TCC_MAPPING_ALL table. */

POPULATE_ID_TCC_MAPPING_ALL (
  X_TAX_RATE_ID,
  X_TAX_RATE_CODE,
  X_ORG_ID,
  X_EFFECTIVE_FROM,
  X_EFFECTIVE_TO,
  X_TAX_TYPE,
  X_TAX_CLASS,
  X_Active_Flag,
  NULL,
  NULL
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_TAX_RATE_ID in NUMBER,
  X_TAX_RATE_CODE in VARCHAR2,
  X_CONTENT_OWNER_ID in NUMBER,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_TAX_STATUS_CODE in VARCHAR2,
  X_Schedule_Based_Rate_Flag in VARCHAR2,
  X_Rate_Type_Code in VARCHAR2,
  X_PERCENTAGE_RATE in NUMBER,
  X_QUANTITY_RATE in NUMBER,
  X_UOM_CODE in VARCHAR2,
  X_TAX_JURISDICTION_CODE in VARCHAR2,
  X_RECOVERY_TYPE_CODE in VARCHAR2,
  X_Active_Flag in VARCHAR2,
  X_Default_Rate_Flag in VARCHAR2,
  X_DEFAULT_FLG_EFFECTIVE_FROM in DATE,
  X_DEFAULT_FLG_EFFECTIVE_TO in DATE,
  X_DEFAULT_REC_TYPE_CODE in VARCHAR2,
  X_DEFAULT_REC_RATE_CODE in VARCHAR2,
  X_OFFSET_TAX in VARCHAR2,
  X_OFFSET_STATUS_CODE in VARCHAR2,
  X_OFFSET_TAX_RATE_CODE in VARCHAR2,
  X_RECOVERY_RULE_CODE in VARCHAR2,
  X_Def_Rec_Settlement_Option_Co in VARCHAR2,
  X_Vat_Transaction_Type_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
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
  X_TAX_RATE_NAME in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in  NUMBER,
  X_ALLOW_ADHOC_TAX_RATE_FLAG in VARCHAR2,
  X_ADJ_FOR_ADHOC_AMT_CODE in VARCHAR2,
  X_INCLUSIVE_TAX_FLAG in VARCHAR2,
  X_TAX_INCLUSIVE_OVERRIDE_FLAG VARCHAR2,
  X_TAX_CLASS VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ALLOW_EXEMPTIONS_FLAG in VARCHAR2,
  X_ALLOW_EXCEPTIONS_FLAG in VARCHAR2,
  X_SOURCE_ID in NUMBER,
  X_DESCRIPTION VARCHAR2,
  X_TAXABLE_BASIS_FORMULA_CODE in VARCHAR2

) is
  cursor c is select
      TAX_RATE_CODE,
      CONTENT_OWNER_ID,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      TAX_REGIME_CODE,
      TAX,
      TAX_STATUS_CODE,
      Schedule_Based_Rate_Flag,
      Rate_Type_Code,
      PERCENTAGE_RATE,
      QUANTITY_RATE,
      UOM_CODE,
      TAX_JURISDICTION_CODE,
      RECOVERY_TYPE_CODE,
      Active_Flag,
      Default_Rate_Flag,
      DEFAULT_FLG_EFFECTIVE_FROM,
      DEFAULT_FLG_EFFECTIVE_TO,
      DEFAULT_REC_TYPE_CODE,
      DEFAULT_REC_RATE_CODE,
      OFFSET_TAX,
      OFFSET_STATUS_CODE,
      OFFSET_TAX_RATE_CODE,
      RECOVERY_RULE_CODE,
      Def_Rec_Settlement_Option_Code,
      Vat_Transaction_Type_Code,
      Record_Type_Code,
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
      ALLOW_ADHOC_TAX_RATE_FLAG,
      ADJ_FOR_ADHOC_AMT_CODE,
      INCLUSIVE_TAX_FLAG,
      TAX_INCLUSIVE_OVERRIDE_FLAG,
      TAX_CLASS,
      OBJECT_VERSION_NUMBER,
      ALLOW_EXEMPTIONS_FLAG,
      ALLOW_EXCEPTIONS_FLAG,
      SOURCE_ID,
      -- DESCRIPTION, commented as part of fix for bug#	6820043
      TAXABLE_BASIS_FORMULA_CODE
    from ZX_RATES_B
    where TAX_RATE_ID = X_TAX_RATE_ID
    for update of TAX_RATE_ID nowait;
  recinfo c%rowtype;
  cursor c1 is select
      TAX_RATE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ZX_RATES_TL
    where TAX_RATE_ID = X_TAX_RATE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TAX_RATE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.TAX_RATE_CODE = X_TAX_RATE_CODE)
      AND ((recinfo.CONTENT_OWNER_ID = X_CONTENT_OWNER_ID)
           OR ((recinfo.CONTENT_OWNER_ID is null) AND (X_CONTENT_OWNER_ID is null)))
      AND ((recinfo.EFFECTIVE_FROM = X_EFFECTIVE_FROM)
           OR ((recinfo.EFFECTIVE_FROM is null) AND (X_EFFECTIVE_FROM is null)))
      AND ((recinfo.EFFECTIVE_TO = X_EFFECTIVE_TO)
           OR ((recinfo.EFFECTIVE_TO is null) AND (X_EFFECTIVE_TO is null)))
      AND (recinfo.TAX_REGIME_CODE = X_TAX_REGIME_CODE)
      AND (recinfo.TAX = X_TAX)
      AND ((recinfo.TAX_STATUS_CODE = X_TAX_STATUS_CODE)
           OR ((recinfo.TAX_STATUS_CODE is null) AND (X_TAX_STATUS_CODE is null)))
      AND ((recinfo.Schedule_Based_Rate_Flag = X_Schedule_Based_Rate_Flag)
           OR ((recinfo.Schedule_Based_Rate_Flag is null) AND (X_Schedule_Based_Rate_Flag is null)))
      AND ((recinfo.Rate_Type_Code = X_Rate_Type_Code)
           OR ((recinfo.Rate_Type_Code is null) AND (X_Rate_Type_Code is null)))
      AND ((recinfo.PERCENTAGE_RATE = X_PERCENTAGE_RATE)
           OR ((recinfo.PERCENTAGE_RATE is null) AND (X_PERCENTAGE_RATE is null)))
      AND ((recinfo.QUANTITY_RATE = X_QUANTITY_RATE)
           OR ((recinfo.QUANTITY_RATE is null) AND (X_QUANTITY_RATE is null)))
      AND ((recinfo.UOM_CODE = X_UOM_CODE)
           OR ((recinfo.UOM_CODE is null) AND (X_UOM_CODE is null)))
      AND ((recinfo.TAX_JURISDICTION_CODE = X_TAX_JURISDICTION_CODE)
           OR ((recinfo.TAX_JURISDICTION_CODE is null) AND (X_TAX_JURISDICTION_CODE is null)))
      AND ((recinfo.RECOVERY_TYPE_CODE = X_RECOVERY_TYPE_CODE)
           OR ((recinfo.RECOVERY_TYPE_CODE is null) AND (X_RECOVERY_TYPE_CODE is null)))
      AND ((recinfo.Active_Flag = X_Active_Flag)
           OR ((recinfo.Active_Flag is null) AND (X_Active_Flag is null)))
      AND ((recinfo.Default_Rate_Flag = X_Default_Rate_Flag)
           OR ((recinfo.Default_Rate_Flag is null) AND (X_Default_Rate_Flag is null)))
      AND ((recinfo.DEFAULT_FLG_EFFECTIVE_FROM = X_DEFAULT_FLG_EFFECTIVE_FROM)
           OR ((recinfo.DEFAULT_FLG_EFFECTIVE_FROM is null) AND (X_DEFAULT_FLG_EFFECTIVE_FROM is null)))
      AND ((recinfo.DEFAULT_FLG_EFFECTIVE_TO = X_DEFAULT_FLG_EFFECTIVE_TO)
           OR ((recinfo.DEFAULT_FLG_EFFECTIVE_TO is null) AND (X_DEFAULT_FLG_EFFECTIVE_TO is null)))
      AND ((recinfo.DEFAULT_REC_TYPE_CODE = X_DEFAULT_REC_TYPE_CODE)
           OR ((recinfo.DEFAULT_REC_TYPE_CODE is null) AND (X_DEFAULT_REC_TYPE_CODE is null)))
      AND ((recinfo.DEFAULT_REC_RATE_CODE = X_DEFAULT_REC_RATE_CODE)
           OR ((recinfo.DEFAULT_REC_RATE_CODE is null) AND (X_DEFAULT_REC_RATE_CODE is null)))
      AND ((recinfo.OFFSET_TAX = X_OFFSET_TAX)
           OR ((recinfo.OFFSET_TAX is null) AND (X_OFFSET_TAX is null)))
      AND ((recinfo.OFFSET_STATUS_CODE = X_OFFSET_STATUS_CODE)
           OR ((recinfo.OFFSET_STATUS_CODE is null) AND (X_OFFSET_STATUS_CODE is null)))
      AND ((recinfo.OFFSET_TAX_RATE_CODE = X_OFFSET_TAX_RATE_CODE)
           OR ((recinfo.OFFSET_TAX_RATE_CODE is null) AND (X_OFFSET_TAX_RATE_CODE is null)))
      AND ((recinfo.RECOVERY_RULE_CODE = X_RECOVERY_RULE_CODE)
           OR ((recinfo.RECOVERY_RULE_CODE is null) AND (X_RECOVERY_RULE_CODE is null)))
      AND ((recinfo.Def_Rec_Settlement_Option_Code = X_Def_Rec_Settlement_Option_Co)
           OR ((recinfo.Def_Rec_Settlement_Option_Code is null) AND (X_Def_Rec_Settlement_Option_Co is null)))
      AND ((recinfo.Vat_Transaction_Type_Code = X_Vat_Transaction_Type_Code)
           OR ((recinfo.Vat_Transaction_Type_Code is null) AND (X_Vat_Transaction_Type_Code is null)))
      AND ((recinfo.Record_Type_Code = X_Record_Type_Code)
           OR ((recinfo.Record_Type_Code is null) AND (X_Record_Type_Code is null)))
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
      AND ((recinfo.ALLOW_ADHOC_TAX_RATE_FLAG = X_ALLOW_ADHOC_TAX_RATE_FLAG)
           OR ((recinfo.ALLOW_ADHOC_TAX_RATE_FLAG is null) AND (X_ALLOW_ADHOC_TAX_RATE_FLAG is null)))
      AND ((recinfo.ADJ_FOR_ADHOC_AMT_CODE = X_ADJ_FOR_ADHOC_AMT_CODE)
           OR ((recinfo.ADJ_FOR_ADHOC_AMT_CODE is null) AND (X_ADJ_FOR_ADHOC_AMT_CODE is null)))
      AND ((recinfo.INCLUSIVE_TAX_FLAG = X_INCLUSIVE_TAX_FLAG)
           OR ((recinfo.INCLUSIVE_TAX_FLAG is null) AND (X_INCLUSIVE_TAX_FLAG is null)))
      AND ((recinfo.TAX_INCLUSIVE_OVERRIDE_FLAG = X_TAX_INCLUSIVE_OVERRIDE_FLAG)
           OR ((recinfo.TAX_INCLUSIVE_OVERRIDE_FLAG is null) AND (X_TAX_INCLUSIVE_OVERRIDE_FLAG is null)))
      AND ((recinfo.TAX_CLASS= X_TAX_CLASS)
           OR ((recinfo.TAX_CLASS is null) AND (X_TAX_CLASS is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.ALLOW_EXEMPTIONS_FLAG = X_ALLOW_EXEMPTIONS_FLAG)
           OR ((recinfo.ALLOW_EXEMPTIONS_FLAG is null) AND (X_ALLOW_EXEMPTIONS_FLAG is null)))
      AND ((recinfo.ALLOW_EXCEPTIONS_FLAG = X_ALLOW_EXCEPTIONS_FLAG)
           OR ((recinfo.ALLOW_EXCEPTIONS_FLAG is null) AND (X_ALLOW_EXCEPTIONS_FLAG is null)))
      AND ((recinfo.SOURCE_ID = X_SOURCE_ID)
           OR ((recinfo.SOURCE_ID is null) AND (X_SOURCE_ID is null)))
    /* AND ((recinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((recinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null))) */ /* commented as part of fix for bug#	6820043 */
      AND ((recinfo.TAXABLE_BASIS_FORMULA_CODE = X_TAXABLE_BASIS_FORMULA_CODE)
           OR ((recinfo.TAXABLE_BASIS_FORMULA_CODE is null) AND (X_TAXABLE_BASIS_FORMULA_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.TAX_RATE_NAME = X_TAX_RATE_NAME)
               OR ((tlinfo.TAX_RATE_NAME is null) AND (X_TAX_RATE_NAME is null)))
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
  X_TAX_RATE_ID in NUMBER,
  X_TAX_RATE_CODE in VARCHAR2,
  X_CONTENT_OWNER_ID in NUMBER,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_TAX_STATUS_CODE in VARCHAR2,
  X_Schedule_Based_Rate_Flag in VARCHAR2,
  X_Rate_Type_Code in VARCHAR2,
  X_PERCENTAGE_RATE in NUMBER,
  X_QUANTITY_RATE in NUMBER,
  X_UOM_CODE in VARCHAR2,
  X_TAX_JURISDICTION_CODE in VARCHAR2,
  X_RECOVERY_TYPE_CODE in VARCHAR2,
  X_Active_Flag in VARCHAR2,
  X_Default_Rate_Flag in VARCHAR2,
  X_DEFAULT_FLG_EFFECTIVE_FROM in DATE,
  X_DEFAULT_FLG_EFFECTIVE_TO in DATE,
  X_DEFAULT_REC_TYPE_CODE in VARCHAR2,
  X_DEFAULT_REC_RATE_CODE in VARCHAR2,
  X_OFFSET_TAX in VARCHAR2,
  X_OFFSET_STATUS_CODE in VARCHAR2,
  X_OFFSET_TAX_RATE_CODE in VARCHAR2,
  X_RECOVERY_RULE_CODE in VARCHAR2,
  X_Def_Rec_Settlement_Option_Co in VARCHAR2,
  X_Vat_Transaction_Type_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
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
  X_TAX_RATE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_ALLOW_ADHOC_TAX_RATE_FLAG in VARCHAR2,
  X_ADJ_FOR_ADHOC_AMT_CODE in VARCHAR2,
  X_INCLUSIVE_TAX_FLAG in VARCHAR2,
  X_TAX_INCLUSIVE_OVERRIDE_FLAG VARCHAR2,
  X_TAX_CLASS VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ALLOW_EXEMPTIONS_FLAG in VARCHAR2,
  X_ALLOW_EXCEPTIONS_FLAG in VARCHAR2,
  X_SOURCE_ID in NUMBER,
  X_DESCRIPTION IN VARCHAR2,
  X_TAXABLE_BASIS_FORMULA_CODE in VARCHAR2
) is
  X_ORG_ID NUMBER;
  X_TAX_TYPE VARCHAR2(30);
  X_RETURN_STATUS VARCHAR2(1) ; --bug#6992215

begin
  update ZX_RATES_B set
    TAX_RATE_CODE = X_TAX_RATE_CODE,
    CONTENT_OWNER_ID = X_CONTENT_OWNER_ID,
    EFFECTIVE_FROM = X_EFFECTIVE_FROM,
    EFFECTIVE_TO = X_EFFECTIVE_TO,
    TAX_REGIME_CODE = X_TAX_REGIME_CODE,
    TAX = X_TAX,
    TAX_STATUS_CODE = X_TAX_STATUS_CODE,
    Schedule_Based_Rate_Flag = X_Schedule_Based_Rate_Flag,
    Rate_Type_Code = X_Rate_Type_Code,
    PERCENTAGE_RATE = X_PERCENTAGE_RATE,
    QUANTITY_RATE = X_QUANTITY_RATE,
    UOM_CODE = X_UOM_CODE,
    TAX_JURISDICTION_CODE = X_TAX_JURISDICTION_CODE,
    RECOVERY_TYPE_CODE = X_RECOVERY_TYPE_CODE,
    Active_Flag = X_Active_Flag,
    Default_Rate_Flag = X_Default_Rate_Flag,
    DEFAULT_FLG_EFFECTIVE_FROM = X_DEFAULT_FLG_EFFECTIVE_FROM,
    DEFAULT_FLG_EFFECTIVE_TO = X_DEFAULT_FLG_EFFECTIVE_TO,
    DEFAULT_REC_TYPE_CODE = X_DEFAULT_REC_TYPE_CODE,
    DEFAULT_REC_RATE_CODE = X_DEFAULT_REC_RATE_CODE,
    OFFSET_TAX = X_OFFSET_TAX,
    OFFSET_STATUS_CODE = X_OFFSET_STATUS_CODE,
    OFFSET_TAX_RATE_CODE = X_OFFSET_TAX_RATE_CODE,
    RECOVERY_RULE_CODE = X_RECOVERY_RULE_CODE,
    Def_Rec_Settlement_Option_Code = X_Def_Rec_Settlement_Option_Co,
    Vat_Transaction_Type_Code = X_Vat_Transaction_Type_Code,
    Record_Type_Code = X_Record_Type_Code,
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
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID  =  X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID  = X_PROGRAM_ID,
    Program_Login_Id = X_Program_Login_Id,
    ALLOW_ADHOC_TAX_RATE_FLAG = X_ALLOW_ADHOC_TAX_RATE_FLAG,
    ADJ_FOR_ADHOC_AMT_CODE = X_ADJ_FOR_ADHOC_AMT_CODE,
    INCLUSIVE_TAX_FLAG = X_INCLUSIVE_TAX_FLAG,
    TAX_INCLUSIVE_OVERRIDE_FLAG = X_TAX_INCLUSIVE_OVERRIDE_FLAG,
    TAX_CLASS = X_TAX_CLASS,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ALLOW_EXEMPTIONS_FLAG = X_ALLOW_EXEMPTIONS_FLAG,
    ALLOW_EXCEPTIONS_FLAG = X_ALLOW_EXCEPTIONS_FLAG,
    SOURCE_ID = X_SOURCE_ID,
   -- DESCRIPTION = X_DESCRIPTION,/* commented as part of fix for bug#	6820043 */
    TAXABLE_BASIS_FORMULA_CODE = X_TAXABLE_BASIS_FORMULA_CODE
  where TAX_RATE_ID = X_TAX_RATE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  update ZX_RATES_TL set
    TAX_RATE_NAME = X_TAX_RATE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	DESCRIPTION = X_DESCRIPTION, /* added as part of fix for bug#	6820043 */
    SOURCE_LANG = userenv('LANG')
  where TAX_RATE_ID = X_TAX_RATE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    raise no_data_found;
  end if;


--START bug#6992215
/*
Updating the description column in the fnd_lookup_values. For rate code of type:RECOVERY, it will not update.
*/
  IF (X_RATE_TYPE_CODE <> 'RECOVERY') then
     UPDATE_LOOKUP_VALUES(
        'ZX_INPUT_CLASSIFICATIONS' ,
        X_TAX_RATE_CODE ,
        X_TAX_RATE_CODE,
        X_TAX_RATE_CODE,
        X_EFFECTIVE_FROM,
        X_EFFECTIVE_TO,
	      X_RETURN_STATUS
     );

     UPDATE_LOOKUP_VALUES(
        'ZX_OUTPUT_CLASSIFICATIONS' ,
        X_TAX_RATE_CODE ,
        X_TAX_RATE_CODE,
        X_TAX_RATE_CODE,
        X_EFFECTIVE_FROM,
        X_EFFECTIVE_TO,
	      X_RETURN_STATUS
     );


     UPDATE_LOOKUP_VALUES(
        'ZX_WEB_EXP_TAX_CLASSIFICATIONS' ,
        X_TAX_RATE_CODE ,
        X_TAX_RATE_CODE,
        X_TAX_RATE_CODE,
        X_EFFECTIVE_FROM,
        X_EFFECTIVE_TO,
	      X_RETURN_STATUS
     );

  END IF;
--END bug#6992215

/*Getting the value of X_ORG_ID on the basis of X_CONTENT_OWNER_ID
* and tax_type_code to be passed
*
*/



SELECT decode(c.party_type_code,'OU',c.party_id,-99) into X_ORG_ID
FROM
	zx_party_tax_profile c
WHERE
c.party_tax_profile_id = X_CONTENT_OWNER_ID;



BEGIN
	SELECT TAX_TYPE_CODE INTO X_TAX_TYPE
	FROM
		ZX_TAXES_B A
	WHERE
		A.TAX = X_TAX
		AND A.TAX_REGIME_CODE = X_TAX_REGIME_CODE
		AND A.CONTENT_OWNER_ID = X_CONTENT_OWNER_ID;



EXCEPTION
	WHEN NO_DATA_FOUND THEN

	SELECT TAX_TYPE_CODE INTO X_TAX_TYPE
	FROM
		ZX_TAXES_B A
	WHERE
		A.TAX = X_TAX
		AND A.TAX_REGIME_CODE = X_TAX_REGIME_CODE
		AND A.CONTENT_OWNER_ID = -99;
END;

/* Calling procedure POPULATE_ID_TCC_MAPPING_ALL to populate the ZX_ID_TCC_MAPPING_ALL table. */

POPULATE_ID_TCC_MAPPING_ALL (
  X_TAX_RATE_ID,
  X_TAX_RATE_CODE,
  X_ORG_ID,
  X_EFFECTIVE_FROM,
  X_EFFECTIVE_TO,
  X_TAX_TYPE,
  X_TAX_CLASS,
  X_Active_Flag,
  NULL,
  NULL
  );

end UPDATE_ROW;

procedure DELETE_ROW (
  X_TAX_RATE_ID in NUMBER
) is
begin
  delete from ZX_RATES_TL
  where TAX_RATE_ID = X_TAX_RATE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  delete from ZX_RATES_B
  where TAX_RATE_ID = X_TAX_RATE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ZX_RATES_TL T
  where not exists
    (select NULL
    from ZX_RATES_B B
    where B.TAX_RATE_ID = T.TAX_RATE_ID
    );
  update ZX_RATES_TL T set (
      TAX_RATE_NAME
    ) = (select
      B.TAX_RATE_NAME
    from ZX_RATES_TL B
    where B.TAX_RATE_ID = T.TAX_RATE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAX_RATE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TAX_RATE_ID,
      SUBT.LANGUAGE
    from ZX_RATES_TL SUBB, ZX_RATES_TL SUBT
    where SUBB.TAX_RATE_ID = SUBT.TAX_RATE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TAX_RATE_NAME <> SUBT.TAX_RATE_NAME
      or (SUBB.TAX_RATE_NAME is null and SUBT.TAX_RATE_NAME is not null)
      or (SUBB.TAX_RATE_NAME is not null and SUBT.TAX_RATE_NAME is null)
  ));
  insert into ZX_RATES_TL (
    TAX_RATE_ID,
    TAX_RATE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
	description,/* added as part of fix for bug#	6820043 */
    SOURCE_LANG
  ) select
    B.TAX_RATE_ID,
    B.TAX_RATE_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
	B.DESCRIPTION,/* added as part of fix for bug#	6820043 */
    B.SOURCE_LANG
  from ZX_RATES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ZX_RATES_TL T
    where T.TAX_RATE_ID = B.TAX_RATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

Procedure INSERT_LOOKUP_VALUES (
  X_LOOKUP_TYPE in VARCHAR2,
  X_TAX_RATE_CODE in VARCHAR2,
  X_EFFECTIVE_FROM  in DATE,
  X_EFFECTIVE_TO   in DATE,
  --start bug#6992215
  X_DESCRIPTION in VARCHAR2 DEFAULT NULL ,  --bug#7274382 added default
  X_TAX_RATE_NAME IN VARCHAR2 DEFAULT NULL  --bug#7274382 added default
  -- end bug#6992215
) is

begin



MERGE INTO FND_LOOKUP_VALUES
   USING (SELECT INSTALLED_FLAG,LANGUAGE_CODE FROM FND_LANGUAGES where INSTALLED_FLAG in ('I', 'B')) L
   ON ( LOOKUP_TYPE = X_LOOKUP_TYPE and
      LOOKUP_CODE = NVL(TAG,X_TAX_RATE_CODE)and
      VIEW_APPLICATION_ID='0' and
      SECURITY_GROUP_ID='0'   and
      LANGUAGE = L.LANGUAGE_CODE
      )
   WHEN MATCHED THEN UPDATE SET END_DATE_ACTIVE = NULL



   WHEN NOT MATCHED THEN INSERT
    (
     LOOKUP_TYPE         ,
     LANGUAGE          ,
     LOOKUP_CODE            ,
     MEANING                ,
     DESCRIPTION            ,
     ENABLED_FLAG           ,
     TAG,
     START_DATE_ACTIVE      ,
     END_DATE_ACTIVE        ,
     SOURCE_LANG            ,
     SECURITY_GROUP_ID      ,
     VIEW_APPLICATION_ID    ,
     CREATION_DATE          ,
     CREATED_BY             ,
     LAST_UPDATE_DATE       ,
     LAST_UPDATED_BY        ,
     LAST_UPDATE_LOGIN
    )
  VALUES(
         X_LOOKUP_TYPE,
         LANGUAGE_CODE,
         (SELECT CASE WHEN LENGTHB(X_TAX_RATE_CODE) > 30
                    THEN SUBSTRB(X_TAX_RATE_CODE, 1, 24) ||ZX_MIGRATE_UTIL.GET_NEXT_SEQID('ZX_TAXES_B_S')
                    ELSE X_TAX_RATE_CODE
                    END  LOOKUP_CODE
                  FROM DUAL) ,
         -- start  bug#6992215
         X_TAX_RATE_CODE,  -- Meaning
         X_TAX_RATE_CODE,  -- Description
         -- end  bug#6992215
         'Y',
         (SELECT CASE WHEN LENGTHB(X_TAX_RATE_CODE) > 30
                    THEN X_TAX_RATE_CODE
                    ELSE
                        NULL
                    END  TAG
                 FROM DUAL) ,
          X_EFFECTIVE_FROM,
          X_EFFECTIVE_TO,
          'US',
          '0',
          '0',
          SYSDATE,
          fnd_global.user_id,
          SYSDATE,
          fnd_global.user_id,
          FND_GLOBAL.CONC_LOGIN_ID);


    end INSERT_LOOKUP_VALUES;






Procedure POPULATE_ID_TCC_MAPPING_ALL (
  X_TAX_RATE_ID in NUMBER,
  X_TAX_RATE_CODE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX_TYPE in VARCHAR2,
  X_TAX_CLASS in varchar2,
  X_Active_Flag in VARCHAR2,
  X_LEDGER_ID in NUMBER,
  X_SOURCE in VARCHAR2
) is

L_EFFECTIVE_FROM  DATE;
L_EFFECTIVE_TO    DATE;

begin
	/* Insert into ZX_ID_TCC_MAPPING_ALL table when ever the new rate is being created;
	* And if the record is already present then it will update the existing record.
	* If content owner is OU, add a record in zx_id_tcc_mapping_all table for each new tax rate
	* code created (tax_class = NULL and source =  NULL).
	* Also note that we can create records in this table from the Conditions
	* flow too. In that case we stamp the TaxRateCodeId as the negative of
	* ConditionGroupId: Bug 5249603
	*/

	--Copy the values to local variable.
	L_EFFECTIVE_FROM  := X_EFFECTIVE_FROM;
	L_EFFECTIVE_TO    := X_EFFECTIVE_TO;

	-- Bug # 5559151. If this procedure is called from Tax Rules/Condition Set UI then we are not passing the
	-- Effective From and To date. So get the Max(Start Date) and Min(End Date) from fnd_lookups
	IF L_EFFECTIVE_FROM IS NULL THEN

		SELECT MAX(START_DATE_ACTIVE) INTO L_EFFECTIVE_FROM
		FROM   FND_LOOKUPS
		WHERE  LOOKUP_TYPE IN('ZX_INPUT_CLASSIFICATIONS', 'ZX_WEB_EXP_TAX_CLASSIFICATIONS' , 'ZX_OUTPUT_CLASSIFICATIONS')
		  AND  ENABLED_FLAG = 'Y'
		  AND  SYSDATE BETWEEN START_DATE_ACTIVE
		  AND  NVL(END_DATE_ACTIVE,SYSDATE)
		  AND  LOOKUP_CODE = X_TAX_RATE_CODE;

		BEGIN

			SELECT END_DATE_ACTIVE INTO L_EFFECTIVE_TO
			FROM   FND_LOOKUPS
			WHERE  LOOKUP_TYPE IN('ZX_INPUT_CLASSIFICATIONS', 'ZX_WEB_EXP_TAX_CLASSIFICATIONS' , 'ZX_OUTPUT_CLASSIFICATIONS')
			  AND  ENABLED_FLAG = 'Y'
			  AND  SYSDATE BETWEEN START_DATE_ACTIVE
			  AND  NVL(END_DATE_ACTIVE,SYSDATE)
			  AND  LOOKUP_CODE = X_TAX_RATE_CODE
			  AND  END_DATE_ACTIVE IS NULL
			  AND  ROWNUM = 1;

		EXCEPTION

  		    WHEN NO_DATA_FOUND THEN
				SELECT MAX(END_DATE_ACTIVE)  INTO L_EFFECTIVE_TO
				FROM   FND_LOOKUPS
				WHERE  LOOKUP_TYPE IN('ZX_INPUT_CLASSIFICATIONS', 'ZX_WEB_EXP_TAX_CLASSIFICATIONS' , 'ZX_OUTPUT_CLASSIFICATIONS')
				  AND  ENABLED_FLAG = 'Y'
				  AND  SYSDATE BETWEEN START_DATE_ACTIVE
				  AND  NVL(END_DATE_ACTIVE,SYSDATE)
				  AND  LOOKUP_CODE = X_TAX_RATE_CODE;
  		    WHEN OTHERS THEN
			  NULL;
		END;

	END IF;

	UPDATE ZX_ID_TCC_MAPPING_ALL
	SET
		EFFECTIVE_TO = L_EFFECTIVE_TO,			--effective_to
		ACTIVE_FLAG = X_Active_Flag,			-- Active_flag
		LAST_UPDATED_BY = fnd_global.user_id,		--last_updated_by
		LAST_UPDATE_DATE = SYSDATE,			--last_update_date
		LAST_UPDATE_LOGIN = fnd_global.user_id		--last_update_login
	WHERE TAX_CLASSIFICATION_CODE = X_TAX_RATE_CODE
		AND ORG_ID = X_ORG_ID
		AND ((TAX_RATE_CODE_ID =  X_TAX_RATE_ID) OR
		    (X_TAX_RATE_ID < 0));


	IF (SQL%NOTFOUND)
	then
		INSERT INTO ZX_ID_TCC_MAPPING_ALL
		(
		  TCC_MAPPING_ID                 ,
		  ORG_ID                         ,
		  TAX_CLASS                      ,
		  TAX_RATE_CODE_ID               ,
		  TAX_CLASSIFICATION_CODE        ,
		  TAX_TYPE			 ,
		  EFFECTIVE_FROM		 ,
		  EFFECTIVE_TO			 ,
		  SOURCE                         ,
		  CREATED_BY                     ,
		  CREATION_DATE                  ,
		  LAST_UPDATED_BY                ,
		  LAST_UPDATE_DATE               ,
		  LAST_UPDATE_LOGIN              ,
		  REQUEST_ID                     ,
		  PROGRAM_APPLICATION_ID         ,
		  PROGRAM_ID                     ,
		  PROGRAM_LOGIN_ID               ,
		  LEDGER_ID		         ,
		  ACTIVE_FLAG
		)
		select
		  ZX_ID_TCC_MAPPING_ALL_S.nextval   , --tcc_mapping_id
		  X_ORG_ID			 , --org_id
		  X_TAX_CLASS	                 , --tax_class
		  X_TAX_RATE_ID                  , --tax_rate_code_id
		  X_TAX_RATE_CODE                , --tax_classification_code
		  X_TAX_TYPE			 , --tax_type
		  L_EFFECTIVE_FROM		 , --effective_from
		  L_EFFECTIVE_TO		 , --effective_to
		  X_SOURCE                       , --source
		  fnd_global.user_id             , --created_by
		  SYSDATE                        , --creation_date
		  fnd_global.user_id             , --last_updated_by
		  SYSDATE                        , --last_update_date
		  fnd_global.user_id             , --last_update_login
		  fnd_global.conc_request_id     , --request_id
		  fnd_global.prog_appl_id        , --program_application_id
		  fnd_global.conc_program_id     , --program_id
		  fnd_global.conc_login_id       , --program_login_id
		  X_LEDGER_ID		         , --ledger_id
		  X_Active_Flag			   -- Active_flag )
		FROM
		       dual
		WHERE
			NOT EXISTS
			  (SELECT NULL FROM ZX_ID_TCC_MAPPING_ALL
			   WHERE TAX_CLASSIFICATION_CODE  =  X_TAX_RATE_CODE
			   AND ORG_ID = X_ORG_ID
			   AND TAX_RATE_CODE_ID =  X_TAX_RATE_ID
			  );
	END IF;
end POPULATE_ID_TCC_MAPPING_ALL;

end ZX_RATES_PKG;

/
