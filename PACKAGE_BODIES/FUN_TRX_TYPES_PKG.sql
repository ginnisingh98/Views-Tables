--------------------------------------------------------
--  DDL for Package Body FUN_TRX_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_TRX_TYPES_PKG" as
/* $Header: funtrxtypetbhb.pls 120.2 2003/06/10 19:53:48 yingli noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TRX_TYPE_ID in NUMBER,
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
  X_TRX_TYPE_CODE in NUMBER,
  X_MANUAL_APPROVE_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ALLOW_INVOICING_FLAG in VARCHAR2,
  X_VAT_TAXABLE_FLAG in VARCHAR2,
  X_ALLOW_INTEREST_ACCRUAL_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_TRX_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FUN_TRX_TYPES_B
    where TRX_TYPE_ID = X_TRX_TYPE_ID
    ;
begin
  insert into FUN_TRX_TYPES_B (
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
    TRX_TYPE_ID,
    TRX_TYPE_CODE,
    MANUAL_APPROVE_FLAG,
    ENABLED_FLAG,
    ALLOW_INVOICING_FLAG,
    VAT_TAXABLE_FLAG,
    ALLOW_INTEREST_ACCRUAL_FLAG,
    ATTRIBUTE1,
    ATTRIBUTE2,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
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
    X_TRX_TYPE_ID,
    X_TRX_TYPE_CODE,
    X_MANUAL_APPROVE_FLAG,
    X_ENABLED_FLAG,
    X_ALLOW_INVOICING_FLAG,
    X_VAT_TAXABLE_FLAG,
    X_ALLOW_INTEREST_ACCRUAL_FLAG,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FUN_TRX_TYPES_TL (
    TRX_TYPE_ID,
    TRX_TYPE_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TRX_TYPE_ID,
    X_TRX_TYPE_NAME,
    X_DESCRIPTION,
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
    from FUN_TRX_TYPES_TL T
    where T.TRX_TYPE_ID = X_TRX_TYPE_ID
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
  X_TRX_TYPE_ID in NUMBER,
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
  X_TRX_TYPE_CODE in NUMBER,
  X_MANUAL_APPROVE_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ALLOW_INVOICING_FLAG in VARCHAR2,
  X_VAT_TAXABLE_FLAG in VARCHAR2,
  X_ALLOW_INTEREST_ACCRUAL_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_TRX_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
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
      TRX_TYPE_CODE,
      MANUAL_APPROVE_FLAG,
      ENABLED_FLAG,
      ALLOW_INVOICING_FLAG,
      VAT_TAXABLE_FLAG,
      ALLOW_INTEREST_ACCRUAL_FLAG,
      ATTRIBUTE1,
      ATTRIBUTE2
    from FUN_TRX_TYPES_B
    where TRX_TYPE_ID = X_TRX_TYPE_ID
    for update of TRX_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TRX_TYPE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FUN_TRX_TYPES_TL
    where TRX_TYPE_ID = X_TRX_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TRX_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
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
      AND (recinfo.TRX_TYPE_CODE = X_TRX_TYPE_CODE)
      AND ((recinfo.MANUAL_APPROVE_FLAG = X_MANUAL_APPROVE_FLAG)
           OR ((recinfo.MANUAL_APPROVE_FLAG is null) AND (X_MANUAL_APPROVE_FLAG is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND ((recinfo.ALLOW_INVOICING_FLAG = X_ALLOW_INVOICING_FLAG)
           OR ((recinfo.ALLOW_INVOICING_FLAG is null) AND (X_ALLOW_INVOICING_FLAG is null)))
      AND ((recinfo.VAT_TAXABLE_FLAG = X_VAT_TAXABLE_FLAG)
           OR ((recinfo.VAT_TAXABLE_FLAG is null) AND (X_VAT_TAXABLE_FLAG is null)))
      AND ((recinfo.ALLOW_INTEREST_ACCRUAL_FLAG = X_ALLOW_INTEREST_ACCRUAL_FLAG)
           OR ((recinfo.ALLOW_INTEREST_ACCRUAL_FLAG is null) AND (X_ALLOW_INTEREST_ACCRUAL_FLAG is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.TRX_TYPE_NAME = X_TRX_TYPE_NAME)
               OR ((tlinfo.TRX_TYPE_NAME is null) AND (X_TRX_TYPE_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_TRX_TYPE_ID in NUMBER,
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
  X_TRX_TYPE_CODE in NUMBER,
  X_MANUAL_APPROVE_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ALLOW_INVOICING_FLAG in VARCHAR2,
  X_VAT_TAXABLE_FLAG in VARCHAR2,
  X_ALLOW_INTEREST_ACCRUAL_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_TRX_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FUN_TRX_TYPES_B set
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
    TRX_TYPE_CODE = X_TRX_TYPE_CODE,
    MANUAL_APPROVE_FLAG = X_MANUAL_APPROVE_FLAG,
    ENABLED_FLAG = X_ENABLED_FLAG,
    ALLOW_INVOICING_FLAG = X_ALLOW_INVOICING_FLAG,
    VAT_TAXABLE_FLAG = X_VAT_TAXABLE_FLAG,
    ALLOW_INTEREST_ACCRUAL_FLAG = X_ALLOW_INTEREST_ACCRUAL_FLAG,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TRX_TYPE_ID = X_TRX_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FUN_TRX_TYPES_TL set
    TRX_TYPE_NAME = X_TRX_TYPE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TRX_TYPE_ID = X_TRX_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TRX_TYPE_ID in NUMBER
) is
begin
  delete from FUN_TRX_TYPES_TL
  where TRX_TYPE_ID = X_TRX_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FUN_TRX_TYPES_B
  where TRX_TYPE_ID = X_TRX_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FUN_TRX_TYPES_TL T
  where not exists
    (select NULL
    from FUN_TRX_TYPES_B B
    where B.TRX_TYPE_ID = T.TRX_TYPE_ID
    );

  update FUN_TRX_TYPES_TL T set (
      TRX_TYPE_NAME,
      DESCRIPTION
    ) = (select
      B.TRX_TYPE_NAME,
      B.DESCRIPTION
    from FUN_TRX_TYPES_TL B
    where B.TRX_TYPE_ID = T.TRX_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TRX_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TRX_TYPE_ID,
      SUBT.LANGUAGE
    from FUN_TRX_TYPES_TL SUBB, FUN_TRX_TYPES_TL SUBT
    where SUBB.TRX_TYPE_ID = SUBT.TRX_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TRX_TYPE_NAME <> SUBT.TRX_TYPE_NAME
      or (SUBB.TRX_TYPE_NAME is null and SUBT.TRX_TYPE_NAME is not null)
      or (SUBB.TRX_TYPE_NAME is not null and SUBT.TRX_TYPE_NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FUN_TRX_TYPES_TL (
    TRX_TYPE_ID,
    TRX_TYPE_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TRX_TYPE_ID,
    B.TRX_TYPE_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FUN_TRX_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FUN_TRX_TYPES_TL T
    where T.TRX_TYPE_ID = B.TRX_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FUN_TRX_TYPES_PKG;

/