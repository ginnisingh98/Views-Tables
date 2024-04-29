--------------------------------------------------------
--  DDL for Package Body ZX_FC_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_FC_TYPES_PKG" as
/* $Header: zxcfctypesb.pls 120.11 2006/05/05 17:53:21 vramamur ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CLASSIFICATION_TYPE_ID in NUMBER,
  X_CLASSIFICATION_TYPE_CODE in VARCHAR2,
  X_Classification_Type_Categ_Co in VARCHAR2,
  X_CLASSIFICATION_TYPE_GROUP_CO in VARCHAR2,
  X_DELIMITER in VARCHAR2,
  X_Owner_Table_Code in VARCHAR2,
  X_OWNER_ID_NUM in NUMBER,
  X_OWNER_ID_CHAR in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_START_POSITION in NUMBER,
  X_NUM_CHARACTERS in NUMBER,
  X_CLASSIFICATION_TYPE_LEVEL_CO in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_Record_Type_Code in VARCHAR2,
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
  X_CLASSIFICATION_TYPE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor C is select ROWID from ZX_FC_TYPES_B
    where CLASSIFICATION_TYPE_ID = X_CLASSIFICATION_TYPE_ID
    ;
  l_row_id VARCHAR2(80);
  l_seq_val NUMBER;
  l_count   NUMBER;
begin

  insert into ZX_FC_TYPES_B (
    CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_CODE,
    Classification_Type_Categ_Code,
    CLASSIFICATION_TYPE_GROUP_CODE,
    DELIMITER,
    Owner_Table_Code,
    OWNER_ID_NUM,
    OWNER_ID_CHAR,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    START_POSITION,
    NUM_CHARACTERS,
    Classification_Type_Level_Code,
    REQUEST_ID,
    Record_Type_Code,
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
    PROGRAM_ID ,
    Program_Login_Id,
    OBJECT_VERSION_NUMBER
  ) values (
    X_CLASSIFICATION_TYPE_ID,
    X_CLASSIFICATION_TYPE_CODE,
    X_Classification_Type_Categ_Co,
    X_CLASSIFICATION_TYPE_GROUP_CO,
    X_DELIMITER,
    X_Owner_Table_Code,
    X_OWNER_ID_NUM,
    X_OWNER_ID_CHAR,
    X_EFFECTIVE_FROM,
    X_EFFECTIVE_TO,
    X_START_POSITION,
    X_NUM_CHARACTERS,
    X_CLASSIFICATION_TYPE_LEVEL_CO,
    X_REQUEST_ID,
    X_Record_Type_Code,
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
    X_OBJECT_VERSION_NUMBER
  );
  insert into ZX_FC_TYPES_TL (
    CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CLASSIFICATION_TYPE_ID,
    X_CLASSIFICATION_TYPE_NAME,
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
    from ZX_FC_TYPES_TL T
    where T.CLASSIFICATION_TYPE_ID = X_CLASSIFICATION_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  SELECT Zx_Determining_Factors_B_S.nextval into l_seq_val FROM DUAL;

  ZX_DETERMINING_FACTORS_PKG.INSERT_ROW(
  	X_ROWID,
        l_seq_val,			--X_DETERMINING_FACTOR_ID,
        x_classification_type_code,	--X_DETERMINING_FACTOR_CODE,
        X_Classification_Type_Categ_Co,	--X_DETERMINING_FACTOR_CLASS_COD,
        NULL,				--X_VALUE_SET,
        NULL,				--X_TAX_PARAMETER_CODE,
        'ALPHANUMERIC',			--X_DATA_TYPE_CODE,
        NULL,				--X_TAX_FUNCTION_CODE,
        X_Record_Type_Code,		--X_RECORD_TYPE_CODE,
        'N',				--X_TAX_REGIME_DET_FLAG,
        'Y',				--X_TAX_SUMMARIZATION_FLAG,
        'Y',				--X_TAX_RULES_FLAG,
        'N',				--X_TAXABLE_BASIS_FLAG,
        'N',				--X_TAX_CALCULATION_FLAG,
        'Y',				--X_INTERNAL_FLAG,
        'N',				--X_RECORD_ONLY_FLAG,
        X_REQUEST_ID,			--X_REQUEST_ID,
        X_CLASSIFICATION_TYPE_NAME,	--X_DETERMINING_FACTOR_NAME,
        NULL,				--X_DETERMINING_FACTOR_DESC,
        X_CREATION_DATE,		--X_CREATION_DATE,
        X_CREATED_BY,			--X_CREATED_BY,
        X_LAST_UPDATE_DATE,		--X_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY,		--X_LAST_UPDATED_BY,
      	X_LAST_UPDATE_LOGIN,		--X_LAST_UPDATE_LOGIN
  	X_OBJECT_VERSION_NUMBER);

  -- If FC Group Code is not null then insert into determining factors. Bug # 5111304
  IF X_CLASSIFICATION_TYPE_GROUP_CO IS NOT NULL and
     X_CLASSIFICATION_TYPE_CATEG_CO = 'PRODUCT_FISCAL_CLASS' THEN

        select count(*) into l_count from ZX_DETERMINING_FACTORS_B where
               DETERMINING_FACTOR_CLASS_CODE = X_CLASSIFICATION_TYPE_CATEG_CO and
               DETERMINING_FACTOR_CODE = X_CLASSIFICATION_TYPE_GROUP_CO;

        -- If FC Group code not exists then insert into determining factors
        IF l_count = 0 THEN

            SELECT Zx_Determining_Factors_B_S.nextval into l_seq_val FROM DUAL;

            ZX_DETERMINING_FACTORS_PKG.INSERT_ROW(
                  X_ROWID,
                  l_seq_val,			--X_DETERMINING_FACTOR_ID,
                  X_CLASSIFICATION_TYPE_GROUP_CO,--X_DETERMINING_FACTOR_CODE,
                  X_CLASSIFICATION_TYPE_CATEG_CO,--X_DETERMINING_FACTOR_CLASS_COD,
                  NULL,				--X_VALUE_SET,
                  NULL,				--X_TAX_PARAMETER_CODE,
                  'ALPHANUMERIC',		--X_DATA_TYPE_CODE,
                  NULL,				--X_TAX_FUNCTION_CODE,
                  X_Record_Type_Code,		--X_RECORD_TYPE_CODE,
                  'N',				--X_TAX_REGIME_DET_FLAG,
                  'Y',				--X_TAX_SUMMARIZATION_FLAG,
                  'Y',				--X_TAX_RULES_FLAG,
                  'N',				--X_TAXABLE_BASIS_FLAG,
                  'N',				--X_TAX_CALCULATION_FLAG,
                  'Y',				--X_INTERNAL_FLAG,
                  'N',				--X_RECORD_ONLY_FLAG,
                  X_REQUEST_ID,			--X_REQUEST_ID,
                  X_CLASSIFICATION_TYPE_GROUP_CO,--X_DETERMINING_FACTOR_NAME,
                  NULL,				--X_DETERMINING_FACTOR_DESC,
                  X_CREATION_DATE,		--X_CREATION_DATE,
                  X_CREATED_BY,			--X_CREATED_BY,
                  X_LAST_UPDATE_DATE,		--X_LAST_UPDATE_DATE,
                  X_LAST_UPDATED_BY,		--X_LAST_UPDATED_BY,
                  X_LAST_UPDATE_LOGIN,		--X_LAST_UPDATE_LOGIN
                  X_OBJECT_VERSION_NUMBER);
        END IF;

  END IF;

end INSERT_ROW;

procedure LOCK_ROW (
  X_CLASSIFICATION_TYPE_ID in NUMBER,
  X_CLASSIFICATION_TYPE_CODE in VARCHAR2,
  X_Classification_Type_Categ_Co in VARCHAR2,
  X_CLASSIFICATION_TYPE_GROUP_CO in VARCHAR2,
  X_DELIMITER in VARCHAR2,
  X_Owner_Table_Code in VARCHAR2,
  X_OWNER_ID_NUM in NUMBER,
  X_OWNER_ID_CHAR in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_START_POSITION in NUMBER,
  X_NUM_CHARACTERS in NUMBER,
  X_CLASSIFICATION_TYPE_LEVEL_CO in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_Record_Type_Code in VARCHAR2,
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
  X_CLASSIFICATION_TYPE_NAME in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      CLASSIFICATION_TYPE_CODE,
      Classification_Type_Categ_Code,
      CLASSIFICATION_TYPE_GROUP_CODE,
      DELIMITER,
      Owner_Table_Code,
      OWNER_ID_NUM,
      OWNER_ID_CHAR,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      START_POSITION,
      NUM_CHARACTERS,
      Classification_Type_Level_Code,
      REQUEST_ID,
      Record_Type_Code,
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
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      Program_Login_Id,
      OBJECT_VERSION_NUMBER
    from ZX_FC_TYPES_B
    where CLASSIFICATION_TYPE_ID = X_CLASSIFICATION_TYPE_ID
    for update of CLASSIFICATION_TYPE_ID nowait;
  recinfo c%rowtype;
  cursor c1 is select
      CLASSIFICATION_TYPE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ZX_FC_TYPES_TL
    where CLASSIFICATION_TYPE_ID = X_CLASSIFICATION_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CLASSIFICATION_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.CLASSIFICATION_TYPE_CODE = X_CLASSIFICATION_TYPE_CODE)
           OR ((recinfo.CLASSIFICATION_TYPE_CODE is null) AND (X_CLASSIFICATION_TYPE_CODE is null)))
      AND (recinfo.Classification_Type_Categ_Code = X_Classification_Type_Categ_Co)
      AND ((recinfo.CLASSIFICATION_TYPE_GROUP_CODE = X_CLASSIFICATION_TYPE_GROUP_CO)
           OR ((recinfo.CLASSIFICATION_TYPE_GROUP_CODE is null) AND (X_CLASSIFICATION_TYPE_GROUP_CO is null)))
      AND ((recinfo.DELIMITER = X_DELIMITER)
           OR ((recinfo.DELIMITER is null) AND (X_DELIMITER is null)))
      AND ((recinfo.Owner_Table_Code = X_Owner_Table_Code)
           OR ((recinfo.Owner_Table_Code is null) AND (X_Owner_Table_Code is null)))
      AND ((recinfo.OWNER_ID_NUM = X_OWNER_ID_NUM)
           OR ((recinfo.OWNER_ID_NUM is null) AND (X_OWNER_ID_NUM is null)))
      AND ((recinfo.OWNER_ID_CHAR = X_OWNER_ID_CHAR)
           OR ((recinfo.OWNER_ID_CHAR is null) AND (X_OWNER_ID_CHAR is null)))
      AND ((recinfo.EFFECTIVE_FROM = X_EFFECTIVE_FROM)
           OR ((recinfo.EFFECTIVE_FROM is null) AND (X_EFFECTIVE_FROM is null)))
      AND ((recinfo.EFFECTIVE_TO = X_EFFECTIVE_TO)
           OR ((recinfo.EFFECTIVE_TO is null) AND (X_EFFECTIVE_TO is null)))
      AND ((recinfo.START_POSITION = X_START_POSITION)
           OR ((recinfo.START_POSITION is null) AND (X_START_POSITION is null)))
      AND ((recinfo.NUM_CHARACTERS = X_NUM_CHARACTERS)
           OR ((recinfo.NUM_CHARACTERS is null) AND (X_NUM_CHARACTERS is null)))
      AND ((recinfo.Classification_Type_Level_Code = X_CLASSIFICATION_TYPE_LEVEL_CO)
           OR ((recinfo.Classification_Type_Level_Code is null) AND (X_CLASSIFICATION_TYPE_LEVEL_CO is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.Record_Type_Code = X_Record_Type_Code)
           OR ((recinfo.Record_Type_Code is null) AND (X_Record_Type_Code is null)))
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
      AND ((recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
           OR ((recinfo.PROGRAM_APPLICATION_ID is null) AND (X_PROGRAM_APPLICATION_ID is null)))
      AND ((recinfo.PROGRAM_ID = X_PROGRAM_ID)
           OR ((recinfo.PROGRAM_ID is null) AND (X_PROGRAM_ID is null)))
      AND ((recinfo.Program_Login_Id = X_Program_Login_Id)
           OR ((recinfo.Program_Login_Id is null) AND (X_Program_Login_Id is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.CLASSIFICATION_TYPE_NAME = X_CLASSIFICATION_TYPE_NAME)
               OR ((tlinfo.CLASSIFICATION_TYPE_NAME is null) AND (X_CLASSIFICATION_TYPE_NAME is null)))
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
  X_CLASSIFICATION_TYPE_ID in NUMBER,
  X_CLASSIFICATION_TYPE_CODE in VARCHAR2,
  X_Classification_Type_Categ_Co in VARCHAR2,
  X_CLASSIFICATION_TYPE_GROUP_CO in VARCHAR2,
  X_DELIMITER in VARCHAR2,
  X_Owner_Table_Code in VARCHAR2,
  X_OWNER_ID_NUM in NUMBER,
  X_OWNER_ID_CHAR in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_START_POSITION in NUMBER,
  X_NUM_CHARACTERS in NUMBER,
  X_CLASSIFICATION_TYPE_LEVEL_CO in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_Record_Type_Code in VARCHAR2,
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
  X_CLASSIFICATION_TYPE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_Program_Login_Id in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
l_det_factor_id NUMBER;
begin

  update ZX_FC_TYPES_B set
    CLASSIFICATION_TYPE_CODE = X_CLASSIFICATION_TYPE_CODE,
    Classification_Type_Categ_Code = X_Classification_Type_Categ_Co,
    CLASSIFICATION_TYPE_GROUP_CODE = X_CLASSIFICATION_TYPE_GROUP_CO,
    DELIMITER = X_DELIMITER,
    Owner_Table_Code = X_Owner_Table_Code,
    OWNER_ID_NUM = X_OWNER_ID_NUM,
    OWNER_ID_CHAR = X_OWNER_ID_CHAR,
    EFFECTIVE_FROM = X_EFFECTIVE_FROM,
    EFFECTIVE_TO = X_EFFECTIVE_TO,
    START_POSITION = X_START_POSITION,
    NUM_CHARACTERS = X_NUM_CHARACTERS,
    Classification_Type_Level_Code = X_CLASSIFICATION_TYPE_LEVEL_CO,
    REQUEST_ID = X_REQUEST_ID,
    Record_Type_Code = X_Record_Type_Code,
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
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    Program_Login_Id = X_Program_Login_Id,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
  where CLASSIFICATION_TYPE_ID = X_CLASSIFICATION_TYPE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  update ZX_FC_TYPES_TL set
    CLASSIFICATION_TYPE_NAME = X_CLASSIFICATION_TYPE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CLASSIFICATION_TYPE_ID = X_CLASSIFICATION_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    raise no_data_found;
  end if;

  /* No need to update the  determing factor name for seeded data and FC Group Code.
  Since Classification Type Name and FC Group Code is non updatable field in the UI.*/

  if( X_Record_Type_Code <> 'SEEDED' ) then

        SELECT DETERMINING_FACTOR_ID INTO l_det_factor_id FROM ZX_DETERMINING_FACTORS_B
            WHERE DETERMINING_FACTOR_CODE = X_CLASSIFICATION_TYPE_CODE AND Tax_Rules_Flag = 'Y';

    ZX_DETERMINING_FACTORS_PKG.UPDATE_ROW
       (l_det_factor_id,		--X_DETERMINING_FACTOR_ID
        x_classification_type_code,	--X_DETERMINING_FACTOR_CODE
        x_classification_type_categ_co,	--X_DETERMINING_FACTOR_CLASS_COD,
        NULL,				--X_VALUE_SET
        NULL,				--X_TAX_PARAMETER_CODE
        'ALPHANUMERIC',			--X_DATA_TYPE_CODE
        NULL,				--X_TAX_FUNCTION_CODE
        x_record_type_code,		--X_RECORD_TYPE_CODE
        'N',				--X_TAX_REGIME_DET_FLAG,
	'Y',				--X_TAX_SUMMARIZATION_FLAG,
	'Y',				--X_TAX_RULES_FLAG,
	'N',				--X_TAXABLE_BASIS_FLAG,
	'N',				--X_TAX_CALCULATION_FLAG,
	'Y',				--X_INTERNAL_FLAG,
        'N',				--X_RECORD_ONLY_FLAG,
        X_REQUEST_ID,			--X_REQUEST_ID
        X_CLASSIFICATION_TYPE_NAME,	--X_DETERMINING_FACTOR_NAME
        NULL,				--X_DETERMINING_FACTOR_DESC
        X_LAST_UPDATE_DATE,		--X_LAST_UPDATE_DATE
        X_LAST_UPDATED_BY,		--X_LAST_UPDATED_BY
        X_LAST_UPDATE_LOGIN,		--X_LAST_UPDATE_LOGIN
        X_OBJECT_VERSION_NUMBER);

  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_CLASSIFICATION_TYPE_ID in NUMBER
) is
begin
  delete from ZX_FC_TYPES_TL
  where CLASSIFICATION_TYPE_ID = X_CLASSIFICATION_TYPE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  delete from ZX_FC_TYPES_B
  where CLASSIFICATION_TYPE_ID = X_CLASSIFICATION_TYPE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ZX_FC_TYPES_TL T
  where not exists
    (select NULL
    from ZX_FC_TYPES_B B
    where B.CLASSIFICATION_TYPE_ID = T.CLASSIFICATION_TYPE_ID
    );
  update ZX_FC_TYPES_TL T set (
      CLASSIFICATION_TYPE_NAME
    ) = (select
      B.CLASSIFICATION_TYPE_NAME
    from ZX_FC_TYPES_TL B
    where B.CLASSIFICATION_TYPE_ID = T.CLASSIFICATION_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CLASSIFICATION_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CLASSIFICATION_TYPE_ID,
      SUBT.LANGUAGE
    from ZX_FC_TYPES_TL SUBB, ZX_FC_TYPES_TL SUBT
    where SUBB.CLASSIFICATION_TYPE_ID = SUBT.CLASSIFICATION_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CLASSIFICATION_TYPE_NAME <> SUBT.CLASSIFICATION_TYPE_NAME
      or (SUBB.CLASSIFICATION_TYPE_NAME is null and SUBT.CLASSIFICATION_TYPE_NAME is not null)
      or (SUBB.CLASSIFICATION_TYPE_NAME is not null and SUBT.CLASSIFICATION_TYPE_NAME is null)
  ));
  insert into ZX_FC_TYPES_TL (
    CLASSIFICATION_TYPE_ID,
    CLASSIFICATION_TYPE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CLASSIFICATION_TYPE_ID,
    B.CLASSIFICATION_TYPE_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ZX_FC_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ZX_FC_TYPES_TL T
    where T.CLASSIFICATION_TYPE_ID = B.CLASSIFICATION_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ZX_FC_TYPES_PKG;

/
