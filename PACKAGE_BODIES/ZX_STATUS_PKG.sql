--------------------------------------------------------
--  DDL for Package Body ZX_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_STATUS_PKG" as
/* $Header: zxcstatusb.pls 120.5 2005/03/17 12:18:32 shmangal ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TAX_STATUS_ID in NUMBER,
  X_TAX_STATUS_CODE in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_Rule_Based_Rate_Flag in VARCHAR2,
  X_Allow_Rate_Override_Flag in VARCHAR2,
  X_Allow_Exemptions_Flag in VARCHAR2,
  X_Allow_Exceptions_Flag in VARCHAR2,
  X_Default_Status_Flag in VARCHAR2,
  X_DEFAULT_FLG_EFFECTIVE_FROM in DATE,
  X_DEFAULT_FLG_EFFECTIVE_TO in DATE,
  X_Def_Rec_Settlement_Option_Co in VARCHAR2,
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
  X_TAX_STATUS_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID   in  NUMBER,
  X_PROGRAM_ID               in  NUMBER,
  X_PROGRAM_LOGIN_ID         in  NUMBER,
  X_CONTENT_OWNER_ID         in  NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor C is select ROWID from ZX_STATUS_B
    where TAX_STATUS_ID = X_TAX_STATUS_ID
    ;
begin
  insert into ZX_STATUS_B (
    TAX_STATUS_ID,
    TAX_STATUS_CODE,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    TAX,
    TAX_REGIME_CODE,
    Rule_Based_Rate_Flag,
    Allow_Rate_Override_Flag,
    Allow_Exemptions_Flag,
    Allow_Exceptions_Flag,
    Default_Status_Flag,
    DEFAULT_FLG_EFFECTIVE_FROM,
    DEFAULT_FLG_EFFECTIVE_TO,
    Def_Rec_Settlement_Option_Code,
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
    PROGRAM_LOGIN_ID,
    CONTENT_OWNER_ID,
    OBJECT_VERSION_NUMBER
  ) values (
    X_TAX_STATUS_ID,
    X_TAX_STATUS_CODE,
    X_EFFECTIVE_FROM,
    X_EFFECTIVE_TO,
    X_TAX,
    X_TAX_REGIME_CODE,
    X_Rule_Based_Rate_Flag,
    X_Allow_Rate_Override_Flag,
    X_Allow_Exemptions_Flag,
    X_Allow_Exceptions_Flag,
    X_Default_Status_Flag,
    X_DEFAULT_FLG_EFFECTIVE_FROM,
    X_DEFAULT_FLG_EFFECTIVE_TO,
    X_Def_Rec_Settlement_Option_Co,
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
    X_PROGRAM_LOGIN_ID,
    X_CONTENT_OWNER_ID,
    X_OBJECT_VERSION_NUMBER
  );
  insert into ZX_STATUS_TL (
    TAX_STATUS_ID,
    TAX_STATUS_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TAX_STATUS_ID,
    X_TAX_STATUS_NAME,
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
    from ZX_STATUS_TL T
    where T.TAX_STATUS_ID = X_TAX_STATUS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;

procedure LOCK_ROW (
  X_TAX_STATUS_ID in NUMBER,
  X_TAX_STATUS_CODE in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_Rule_Based_Rate_Flag in VARCHAR2,
  X_Allow_Rate_Override_Flag in VARCHAR2,
  X_Allow_Exemptions_Flag in VARCHAR2,
  X_Allow_Exceptions_Flag in VARCHAR2,
  X_Default_Status_Flag in VARCHAR2,
  X_DEFAULT_FLG_EFFECTIVE_FROM in DATE,
  X_DEFAULT_FLG_EFFECTIVE_TO in DATE,
  X_Def_Rec_Settlement_Option_Co in VARCHAR2,
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
  X_TAX_STATUS_NAME in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_CONTENT_OWNER_ID in  NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      TAX_STATUS_CODE,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      TAX,
      TAX_REGIME_CODE,
      Rule_Based_Rate_Flag,
      Allow_Rate_Override_Flag,
      Allow_Exemptions_Flag,
      Allow_Exceptions_Flag,
      Default_Status_Flag,
      DEFAULT_FLG_EFFECTIVE_FROM,
      DEFAULT_FLG_EFFECTIVE_TO,
      Def_Rec_Settlement_Option_Code,
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
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_LOGIN_ID,
      CONTENT_OWNER_ID,
      OBJECT_VERSION_NUMBER
    from ZX_STATUS_B
    where TAX_STATUS_ID = X_TAX_STATUS_ID
    for update of TAX_STATUS_ID nowait;
  recinfo c%rowtype;
  cursor c1 is select
      TAX_STATUS_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ZX_STATUS_TL
    where TAX_STATUS_ID = X_TAX_STATUS_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TAX_STATUS_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.TAX_STATUS_CODE = X_TAX_STATUS_CODE)
      AND ((recinfo.EFFECTIVE_FROM = X_EFFECTIVE_FROM)
           OR ((recinfo.EFFECTIVE_FROM is null) AND (X_EFFECTIVE_FROM is null)))
      AND ((recinfo.EFFECTIVE_TO = X_EFFECTIVE_TO)
           OR ((recinfo.EFFECTIVE_TO is null) AND (X_EFFECTIVE_TO is null)))
      AND (recinfo.TAX = X_TAX)
      AND (recinfo.TAX_REGIME_CODE = X_TAX_REGIME_CODE)
      AND ((recinfo.Rule_Based_Rate_Flag = X_Rule_Based_Rate_Flag)
           OR ((recinfo.Rule_Based_Rate_Flag is null) AND (X_Rule_Based_Rate_Flag is null)))
      AND ((recinfo.Allow_Rate_Override_Flag = X_Allow_Rate_Override_Flag)
           OR ((recinfo.Allow_Rate_Override_Flag is null) AND (X_Allow_Rate_Override_Flag is null)))
      AND ((recinfo.Allow_Exemptions_Flag = X_Allow_Exemptions_Flag)
           OR ((recinfo.Allow_Exemptions_Flag is null) AND (X_Allow_Exemptions_Flag is null)))
      AND ((recinfo.Allow_Exceptions_Flag = X_Allow_Exceptions_Flag)
           OR ((recinfo.Allow_Exceptions_Flag is null) AND (X_Allow_Exceptions_Flag is null)))
      AND ((recinfo.Default_Status_Flag = X_Default_Status_Flag)
           OR ((recinfo.Default_Status_Flag is null) AND (X_Default_Status_Flag is null)))
      AND ((recinfo.DEFAULT_FLG_EFFECTIVE_FROM = X_DEFAULT_FLG_EFFECTIVE_FROM)
      OR ((recinfo.DEFAULT_FLG_EFFECTIVE_FROM is null) AND (X_DEFAULT_FLG_EFFECTIVE_FROM is null)))
      AND ((recinfo.DEFAULT_FLG_EFFECTIVE_TO = X_DEFAULT_FLG_EFFECTIVE_TO)
           OR ((recinfo.DEFAULT_FLG_EFFECTIVE_TO is null) AND (X_DEFAULT_FLG_EFFECTIVE_TO is null)))
      AND ((recinfo.Def_Rec_Settlement_Option_Code = X_Def_Rec_Settlement_Option_Co)
           OR ((recinfo.Def_Rec_Settlement_Option_Code is null) AND (X_Def_Rec_Settlement_Option_Co is null)
))
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
      AND ((recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
           OR ((recinfo.PROGRAM_APPLICATION_ID is null) AND (X_PROGRAM_APPLICATION_ID is null)))
      AND ((recinfo.PROGRAM_ID  = X_PROGRAM_ID )
           OR ((recinfo.PROGRAM_ID is null) AND (X_PROGRAM_ID is null)))
      AND ((recinfo.Program_Login_Id = X_Program_Login_Id)
           OR ((recinfo.Program_Login_Id is null) AND (X_Program_Login_Id is null)))
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
      if (    ((tlinfo.TAX_STATUS_NAME = X_TAX_STATUS_NAME)
               OR ((tlinfo.TAX_STATUS_NAME is null) AND (X_TAX_STATUS_NAME is null)))
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
  X_TAX_STATUS_ID in NUMBER,
  X_TAX_STATUS_CODE in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_TAX in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_Rule_Based_Rate_Flag in VARCHAR2,
  X_Allow_Rate_Override_Flag in VARCHAR2,
  X_Allow_Exemptions_Flag in VARCHAR2,
  X_Allow_Exceptions_Flag in VARCHAR2,
  X_Default_Status_Flag in VARCHAR2,
  X_DEFAULT_FLG_EFFECTIVE_FROM in DATE,
  X_DEFAULT_FLG_EFFECTIVE_TO in DATE,
  X_Def_Rec_Settlement_Option_Co in VARCHAR2,
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
  X_TAX_STATUS_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER ,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_CONTENT_OWNER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
begin
  update ZX_STATUS_B set
    TAX_STATUS_CODE = X_TAX_STATUS_CODE,
    EFFECTIVE_FROM = X_EFFECTIVE_FROM,
    EFFECTIVE_TO = X_EFFECTIVE_TO,
    TAX = X_TAX,
    TAX_REGIME_CODE = X_TAX_REGIME_CODE,
    Rule_Based_Rate_Flag = X_Rule_Based_Rate_Flag,
    Allow_Rate_Override_Flag = X_Allow_Rate_Override_Flag,
    Allow_Exemptions_Flag = X_Allow_Exemptions_Flag,
    Allow_Exceptions_Flag = X_Allow_Exceptions_Flag,
    Default_Status_Flag = X_Default_Status_Flag,
    DEFAULT_FLG_EFFECTIVE_FROM = X_DEFAULT_FLG_EFFECTIVE_FROM,
    DEFAULT_FLG_EFFECTIVE_TO = X_DEFAULT_FLG_EFFECTIVE_TO,
    Def_Rec_Settlement_Option_Code = X_Def_Rec_Settlement_Option_Co,
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
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID,
    CONTENT_OWNER_ID=X_CONTENT_OWNER_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
  where TAX_STATUS_ID = X_TAX_STATUS_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  update ZX_STATUS_TL set
    TAX_STATUS_NAME = X_TAX_STATUS_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TAX_STATUS_ID = X_TAX_STATUS_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TAX_STATUS_ID in NUMBER
) is
begin
  delete from ZX_STATUS_TL
  where TAX_STATUS_ID = X_TAX_STATUS_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  delete from ZX_STATUS_B
  where TAX_STATUS_ID = X_TAX_STATUS_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ZX_STATUS_TL T
  where not exists
    (select NULL
    from ZX_STATUS_B B
    where B.TAX_STATUS_ID = T.TAX_STATUS_ID
    );
  update ZX_STATUS_TL T set (
      TAX_STATUS_NAME
    ) = (select
      B.TAX_STATUS_NAME
    from ZX_STATUS_TL B
    where B.TAX_STATUS_ID = T.TAX_STATUS_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TAX_STATUS_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TAX_STATUS_ID,
      SUBT.LANGUAGE
    from ZX_STATUS_TL SUBB, ZX_STATUS_TL SUBT
    where SUBB.TAX_STATUS_ID = SUBT.TAX_STATUS_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TAX_STATUS_NAME <> SUBT.TAX_STATUS_NAME
      or (SUBB.TAX_STATUS_NAME is null and SUBT.TAX_STATUS_NAME is not null)
      or (SUBB.TAX_STATUS_NAME is not null and SUBT.TAX_STATUS_NAME is null)
  ));
  insert into ZX_STATUS_TL (
    TAX_STATUS_ID,
    TAX_STATUS_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TAX_STATUS_ID,
    B.TAX_STATUS_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ZX_STATUS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ZX_STATUS_TL T
    where T.TAX_STATUS_ID = B.TAX_STATUS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ZX_STATUS_PKG;

/
