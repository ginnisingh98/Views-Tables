--------------------------------------------------------
--  DDL for Package Body ORG_FREIGHT_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ORG_FREIGHT_TL_PKG" as
/* $Header: INVORFCB.pls 120.1 2005/06/17 17:10:47 appldev  $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FREIGHT_CODE in VARCHAR2,
  X_FREIGHT_CODE_TL in VARCHAR2,
  X_ORGANIZATION_ID in NUMBER,
  X_DISABLE_DATE in DATE,
  X_DISTRIBUTION_ACCOUNT in NUMBER,
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
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE6 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE7 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE8 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE9 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE10 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE11 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE12 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE13 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE14 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE15 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE16 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE17 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE18 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE19 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE20 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ORG_FREIGHT_TL
    where FREIGHT_CODE = X_FREIGHT_CODE
    and ORGANIZATION_ID = X_ORGANIZATION_ID
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into ORG_FREIGHT_TL (
    FREIGHT_CODE,
    FREIGHT_CODE_TL,
    ORGANIZATION_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    DISABLE_DATE,
    DISTRIBUTION_ACCOUNT,
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
    GLOBAL_ATTRIBUTE1,
    GLOBAL_ATTRIBUTE2,
    GLOBAL_ATTRIBUTE3,
    GLOBAL_ATTRIBUTE4,
    GLOBAL_ATTRIBUTE5,
    GLOBAL_ATTRIBUTE6,
    GLOBAL_ATTRIBUTE7,
    GLOBAL_ATTRIBUTE8,
    GLOBAL_ATTRIBUTE9,
    GLOBAL_ATTRIBUTE10,
    GLOBAL_ATTRIBUTE11,
    GLOBAL_ATTRIBUTE12,
    GLOBAL_ATTRIBUTE13,
    GLOBAL_ATTRIBUTE14,
    GLOBAL_ATTRIBUTE15,
    GLOBAL_ATTRIBUTE16,
    GLOBAL_ATTRIBUTE17,
    GLOBAL_ATTRIBUTE18,
    GLOBAL_ATTRIBUTE19,
    GLOBAL_ATTRIBUTE20,
    GLOBAL_ATTRIBUTE_CATEGORY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_FREIGHT_CODE,
    X_FREIGHT_CODE_TL,
    X_ORGANIZATION_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    X_DISABLE_DATE,
    X_DISTRIBUTION_ACCOUNT,
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
    X_GLOBAL_ATTRIBUTE1,
    X_GLOBAL_ATTRIBUTE2,
    X_GLOBAL_ATTRIBUTE3,
    X_GLOBAL_ATTRIBUTE4,
    X_GLOBAL_ATTRIBUTE5,
    X_GLOBAL_ATTRIBUTE6,
    X_GLOBAL_ATTRIBUTE7,
    X_GLOBAL_ATTRIBUTE8,
    X_GLOBAL_ATTRIBUTE9,
    X_GLOBAL_ATTRIBUTE10,
    X_GLOBAL_ATTRIBUTE11,
    X_GLOBAL_ATTRIBUTE12,
    X_GLOBAL_ATTRIBUTE13,
    X_GLOBAL_ATTRIBUTE14,
    X_GLOBAL_ATTRIBUTE15,
    X_GLOBAL_ATTRIBUTE16,
    X_GLOBAL_ATTRIBUTE17,
    X_GLOBAL_ATTRIBUTE18,
    X_GLOBAL_ATTRIBUTE19,
    X_GLOBAL_ATTRIBUTE20,
    X_GLOBAL_ATTRIBUTE_CATEGORY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ORG_FREIGHT_TL T
    where T.FREIGHT_CODE = X_FREIGHT_CODE
    and T.ORGANIZATION_ID = X_ORGANIZATION_ID
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
  X_FREIGHT_CODE in VARCHAR2,
  X_FREIGHT_CODE_TL in VARCHAR2,
  X_ORGANIZATION_ID in NUMBER,
  X_DISABLE_DATE in DATE,
  X_DISTRIBUTION_ACCOUNT in NUMBER,
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
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE6 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE7 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE8 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE9 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE10 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE11 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE12 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE13 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE14 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE15 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE16 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE17 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE18 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE19 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE20 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) AS
  cursor c1 is select
      DISABLE_DATE,
      DISTRIBUTION_ACCOUNT,
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
      GLOBAL_ATTRIBUTE1,
      GLOBAL_ATTRIBUTE2,
      GLOBAL_ATTRIBUTE3,
      GLOBAL_ATTRIBUTE4,
      GLOBAL_ATTRIBUTE5,
      GLOBAL_ATTRIBUTE6,
      GLOBAL_ATTRIBUTE7,
      GLOBAL_ATTRIBUTE8,
      GLOBAL_ATTRIBUTE9,
      GLOBAL_ATTRIBUTE10,
      GLOBAL_ATTRIBUTE11,
      GLOBAL_ATTRIBUTE12,
      GLOBAL_ATTRIBUTE13,
      GLOBAL_ATTRIBUTE14,
      GLOBAL_ATTRIBUTE15,
      GLOBAL_ATTRIBUTE16,
      GLOBAL_ATTRIBUTE17,
      GLOBAL_ATTRIBUTE18,
      GLOBAL_ATTRIBUTE19,
      GLOBAL_ATTRIBUTE20,
      GLOBAL_ATTRIBUTE_CATEGORY,
      DESCRIPTION,
      FREIGHT_CODE,
      FREIGHT_CODE_TL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ORG_FREIGHT_TL
    where FREIGHT_CODE = X_FREIGHT_CODE
    and ORGANIZATION_ID = X_ORGANIZATION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FREIGHT_CODE nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if ( ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((tlinfo.FREIGHT_CODE_TL = X_FREIGHT_CODE_TL)
               OR ((tlinfo.FREIGHT_CODE_TL is null) AND (X_FREIGHT_CODE_TL is null)))
          AND ((tlinfo.DISABLE_DATE = X_DISABLE_DATE)
               OR ((tlinfo.DISABLE_DATE is null) AND (X_DISABLE_DATE is null)))
          AND ((tlinfo.DISTRIBUTION_ACCOUNT = X_DISTRIBUTION_ACCOUNT)
               OR ((tlinfo.DISTRIBUTION_ACCOUNT is null) AND (X_DISTRIBUTION_ACCOUNT is null)))
          AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
               OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
          AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
               OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
          AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
               OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
          AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
               OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
          AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
               OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
          AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
               OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
          AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
               OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
          AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
               OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
          AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
               OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
          AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
               OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
          AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
               OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
          AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
               OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
          AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
               OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
          AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
               OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
          AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
               OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
          AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
               OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE1 = X_GLOBAL_ATTRIBUTE1)
               OR ((tlinfo.GLOBAL_ATTRIBUTE1 is null) AND (X_GLOBAL_ATTRIBUTE1 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE2 = X_GLOBAL_ATTRIBUTE2)
               OR ((tlinfo.GLOBAL_ATTRIBUTE2 is null) AND (X_GLOBAL_ATTRIBUTE2 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE3 = X_GLOBAL_ATTRIBUTE3)
               OR ((tlinfo.GLOBAL_ATTRIBUTE3 is null) AND (X_GLOBAL_ATTRIBUTE3 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE4 = X_GLOBAL_ATTRIBUTE4)
               OR ((tlinfo.GLOBAL_ATTRIBUTE4 is null) AND (X_GLOBAL_ATTRIBUTE4 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE5 = X_GLOBAL_ATTRIBUTE5)
               OR ((tlinfo.GLOBAL_ATTRIBUTE5 is null) AND (X_GLOBAL_ATTRIBUTE5 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE6 = X_GLOBAL_ATTRIBUTE6)
               OR ((tlinfo.GLOBAL_ATTRIBUTE6 is null) AND (X_GLOBAL_ATTRIBUTE6 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE7 = X_GLOBAL_ATTRIBUTE7)
               OR ((tlinfo.GLOBAL_ATTRIBUTE7 is null) AND (X_GLOBAL_ATTRIBUTE7 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE8 = X_GLOBAL_ATTRIBUTE8)
               OR ((tlinfo.GLOBAL_ATTRIBUTE8 is null) AND (X_GLOBAL_ATTRIBUTE8 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE9 = X_GLOBAL_ATTRIBUTE9)
               OR ((tlinfo.GLOBAL_ATTRIBUTE9 is null) AND (X_GLOBAL_ATTRIBUTE9 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE10 = X_GLOBAL_ATTRIBUTE10)
               OR ((tlinfo.GLOBAL_ATTRIBUTE10 is null) AND (X_GLOBAL_ATTRIBUTE10 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE11 = X_GLOBAL_ATTRIBUTE11)
               OR ((tlinfo.GLOBAL_ATTRIBUTE11 is null) AND (X_GLOBAL_ATTRIBUTE11 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE12 = X_GLOBAL_ATTRIBUTE12)
               OR ((tlinfo.GLOBAL_ATTRIBUTE12 is null) AND (X_GLOBAL_ATTRIBUTE12 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE13 = X_GLOBAL_ATTRIBUTE13)
               OR ((tlinfo.GLOBAL_ATTRIBUTE13 is null) AND (X_GLOBAL_ATTRIBUTE13 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE14 = X_GLOBAL_ATTRIBUTE14)
               OR ((tlinfo.GLOBAL_ATTRIBUTE14 is null) AND (X_GLOBAL_ATTRIBUTE14 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE15 = X_GLOBAL_ATTRIBUTE15)
               OR ((tlinfo.GLOBAL_ATTRIBUTE15 is null) AND (X_GLOBAL_ATTRIBUTE15 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE16 = X_GLOBAL_ATTRIBUTE16)
               OR ((tlinfo.GLOBAL_ATTRIBUTE16 is null) AND (X_GLOBAL_ATTRIBUTE16 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE17 = X_GLOBAL_ATTRIBUTE17)
               OR ((tlinfo.GLOBAL_ATTRIBUTE17 is null) AND (X_GLOBAL_ATTRIBUTE17 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE18 = X_GLOBAL_ATTRIBUTE18)
               OR ((tlinfo.GLOBAL_ATTRIBUTE18 is null) AND (X_GLOBAL_ATTRIBUTE18 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE19 = X_GLOBAL_ATTRIBUTE19)
               OR ((tlinfo.GLOBAL_ATTRIBUTE19 is null) AND (X_GLOBAL_ATTRIBUTE19 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE20 = X_GLOBAL_ATTRIBUTE20)
               OR ((tlinfo.GLOBAL_ATTRIBUTE20 is null) AND (X_GLOBAL_ATTRIBUTE20 is null)))
          AND ((tlinfo.GLOBAL_ATTRIBUTE_CATEGORY = X_GLOBAL_ATTRIBUTE_CATEGORY)
               OR ((tlinfo.GLOBAL_ATTRIBUTE_CATEGORY is null) AND (X_GLOBAL_ATTRIBUTE_CATEGORY is null)))
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
  X_FREIGHT_CODE in VARCHAR2,
  X_FREIGHT_CODE_TL in VARCHAR2,
  X_ORGANIZATION_ID in NUMBER,
  X_DISABLE_DATE in DATE,
  X_DISTRIBUTION_ACCOUNT in NUMBER,
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
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE6 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE7 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE8 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE9 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE10 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE11 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE12 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE13 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE14 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE15 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE16 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE17 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE18 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE19 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE20 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) as
begin
  update ORG_FREIGHT_TL set
    DISABLE_DATE = X_DISABLE_DATE,
    DISTRIBUTION_ACCOUNT = X_DISTRIBUTION_ACCOUNT,
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
    GLOBAL_ATTRIBUTE1 = X_GLOBAL_ATTRIBUTE1,
    GLOBAL_ATTRIBUTE2 = X_GLOBAL_ATTRIBUTE2,
    GLOBAL_ATTRIBUTE3 = X_GLOBAL_ATTRIBUTE3,
    GLOBAL_ATTRIBUTE4 = X_GLOBAL_ATTRIBUTE4,
    GLOBAL_ATTRIBUTE5 = X_GLOBAL_ATTRIBUTE5,
    GLOBAL_ATTRIBUTE6 = X_GLOBAL_ATTRIBUTE6,
    GLOBAL_ATTRIBUTE7 = X_GLOBAL_ATTRIBUTE7,
    GLOBAL_ATTRIBUTE8 = X_GLOBAL_ATTRIBUTE8,
    GLOBAL_ATTRIBUTE9 = X_GLOBAL_ATTRIBUTE9,
    GLOBAL_ATTRIBUTE10 = X_GLOBAL_ATTRIBUTE10,
    GLOBAL_ATTRIBUTE11 = X_GLOBAL_ATTRIBUTE11,
    GLOBAL_ATTRIBUTE12 = X_GLOBAL_ATTRIBUTE12,
    GLOBAL_ATTRIBUTE13 = X_GLOBAL_ATTRIBUTE13,
    GLOBAL_ATTRIBUTE14 = X_GLOBAL_ATTRIBUTE14,
    GLOBAL_ATTRIBUTE15 = X_GLOBAL_ATTRIBUTE15,
    GLOBAL_ATTRIBUTE16 = X_GLOBAL_ATTRIBUTE16,
    GLOBAL_ATTRIBUTE17 = X_GLOBAL_ATTRIBUTE17,
    GLOBAL_ATTRIBUTE18 = X_GLOBAL_ATTRIBUTE18,
    GLOBAL_ATTRIBUTE19 = X_GLOBAL_ATTRIBUTE19,
    GLOBAL_ATTRIBUTE20 = X_GLOBAL_ATTRIBUTE20,
    GLOBAL_ATTRIBUTE_CATEGORY = X_GLOBAL_ATTRIBUTE_CATEGORY,
    DESCRIPTION = X_DESCRIPTION,
    FREIGHT_CODE_TL = X_FREIGHT_CODE_TL,
    FREIGHT_CODE = X_FREIGHT_CODE_TL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FREIGHT_CODE = X_FREIGHT_CODE
  and ORGANIZATION_ID = X_ORGANIZATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

-- Bug 1909262  . To  ensure that when updating freight_code_tl,freight_code
-- should also have the same value . Setting Freight_code = x_freight_code_tl .
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FREIGHT_CODE in VARCHAR2,
  X_ORGANIZATION_ID in NUMBER
) as
begin
  delete from ORG_FREIGHT_TL
  where FREIGHT_CODE = X_FREIGHT_CODE
  and ORGANIZATION_ID = X_ORGANIZATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
as
begin
  update ORG_FREIGHT_TL T set (
      DESCRIPTION,
      FREIGHT_CODE_TL
    ) = (select
      B.DESCRIPTION,
      B.FREIGHT_CODE
    from ORG_FREIGHT_TL B
    where B.FREIGHT_CODE = T.FREIGHT_CODE
    and B.ORGANIZATION_ID = T.ORGANIZATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FREIGHT_CODE_TL,
      T.FREIGHT_CODE,
      T.ORGANIZATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FREIGHT_CODE_TL,
      SUBT.FREIGHT_CODE,
      SUBT.ORGANIZATION_ID,
      SUBT.LANGUAGE
    from ORG_FREIGHT_TL SUBB, ORG_FREIGHT_TL SUBT
    where SUBB.FREIGHT_CODE = SUBT.FREIGHT_CODE
    and SUBB.ORGANIZATION_ID = SUBT.ORGANIZATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.FREIGHT_CODE <> SUBT.FREIGHT_CODE
  ));

  insert into ORG_FREIGHT_TL (
    FREIGHT_CODE_TL,
    FREIGHT_CODE,
    ORGANIZATION_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    DISABLE_DATE,
    DISTRIBUTION_ACCOUNT,
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
    GLOBAL_ATTRIBUTE1,
    GLOBAL_ATTRIBUTE2,
    GLOBAL_ATTRIBUTE3,
    GLOBAL_ATTRIBUTE4,
    GLOBAL_ATTRIBUTE5,
    GLOBAL_ATTRIBUTE6,
    GLOBAL_ATTRIBUTE7,
    GLOBAL_ATTRIBUTE8,
    GLOBAL_ATTRIBUTE9,
    GLOBAL_ATTRIBUTE10,
    GLOBAL_ATTRIBUTE11,
    GLOBAL_ATTRIBUTE12,
    GLOBAL_ATTRIBUTE13,
    GLOBAL_ATTRIBUTE14,
    GLOBAL_ATTRIBUTE15,
    GLOBAL_ATTRIBUTE16,
    GLOBAL_ATTRIBUTE17,
    GLOBAL_ATTRIBUTE18,
    GLOBAL_ATTRIBUTE19,
    GLOBAL_ATTRIBUTE20,
    GLOBAL_ATTRIBUTE_CATEGORY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.FREIGHT_CODE_TL,
    B.FREIGHT_CODE,
    B.ORGANIZATION_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    B.DISABLE_DATE,
    B.DISTRIBUTION_ACCOUNT,
    B.ATTRIBUTE_CATEGORY,
    B.ATTRIBUTE1,
    B.ATTRIBUTE2,
    B.ATTRIBUTE3,
    B.ATTRIBUTE4,
    B.ATTRIBUTE5,
    B.ATTRIBUTE6,
    B.ATTRIBUTE7,
    B.ATTRIBUTE8,
    B.ATTRIBUTE9,
    B.ATTRIBUTE10,
    B.ATTRIBUTE11,
    B.ATTRIBUTE12,
    B.ATTRIBUTE13,
    B.ATTRIBUTE14,
    B.ATTRIBUTE15,
    B.GLOBAL_ATTRIBUTE1,
    B.GLOBAL_ATTRIBUTE2,
    B.GLOBAL_ATTRIBUTE3,
    B.GLOBAL_ATTRIBUTE4,
    B.GLOBAL_ATTRIBUTE5,
    B.GLOBAL_ATTRIBUTE6,
    B.GLOBAL_ATTRIBUTE7,
    B.GLOBAL_ATTRIBUTE8,
    B.GLOBAL_ATTRIBUTE9,
    B.GLOBAL_ATTRIBUTE10,
    B.GLOBAL_ATTRIBUTE11,
    B.GLOBAL_ATTRIBUTE12,
    B.GLOBAL_ATTRIBUTE13,
    B.GLOBAL_ATTRIBUTE14,
    B.GLOBAL_ATTRIBUTE15,
    B.GLOBAL_ATTRIBUTE16,
    B.GLOBAL_ATTRIBUTE17,
    B.GLOBAL_ATTRIBUTE18,
    B.GLOBAL_ATTRIBUTE19,
    B.GLOBAL_ATTRIBUTE20,
    B.GLOBAL_ATTRIBUTE_CATEGORY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ORG_FREIGHT_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ORG_FREIGHT_TL T
    where T.FREIGHT_CODE = B.FREIGHT_CODE
    and T.ORGANIZATION_ID = B.ORGANIZATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW(
  X_FREIGHT_CODE in VARCHAR2,
  X_ORGANIZATION_CODE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_FREIGHT_CODE_TL in VARCHAR2,
  X_DISABLE_DATE in DATE,
  X_DISTRIBUTION_ACCOUNT in NUMBER,
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
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2,
  x_GLOBAL_ATTRIBUTE6 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE7 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE8 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE9 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE10 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE11 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE12 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE13 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE14 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE15 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE16 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE17 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE18 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE19 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE20 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER)
as
   row_id varchar2(64);
   user_id NUMBER;
   org_id NUMBER;
begin
   if( X_OWNER = 'SEED') then
	user_id := 1;
   end if;

	-- fix bug 1858065 for performance issue
   -- Use mtl_parameters instead of mtl_organizations
   select organization_id
   into org_id
   from mtl_parameters
   where organization_code = X_ORGANIZATION_CODE;

   org_freight_tl_pkg.Update_row(
  	X_FREIGHT_CODE => X_FREIGHT_CODE,
  	X_FREIGHT_CODE_TL => X_FREIGHT_CODE_TL,
  	X_ORGANIZATION_ID => org_id,
  	X_DISABLE_DATE => X_DISABLE_DATE,
  	X_DISTRIBUTION_ACCOUNT => X_DISTRIBUTION_ACCOUNT,
  	X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
  	X_ATTRIBUTE1 => X_ATTRIBUTE1,
  	X_ATTRIBUTE2 => X_ATTRIBUTE2,
  	X_ATTRIBUTE3 => X_ATTRIBUTE3,
  	X_ATTRIBUTE4 => X_ATTRIBUTE4,
  	X_ATTRIBUTE5 => X_ATTRIBUTE5,
  	X_ATTRIBUTE6 => X_ATTRIBUTE6,
  	X_ATTRIBUTE7 => X_ATTRIBUTE7,
  	X_ATTRIBUTE8 => X_ATTRIBUTE8,
  	X_ATTRIBUTE9 => X_ATTRIBUTE9,
  	X_ATTRIBUTE10 => X_ATTRIBUTE10,
  	X_ATTRIBUTE11 => X_ATTRIBUTE11,
  	X_ATTRIBUTE12 => X_ATTRIBUTE12,
  	X_ATTRIBUTE13 => X_ATTRIBUTE13,
  	X_ATTRIBUTE14 => X_ATTRIBUTE14,
  	X_ATTRIBUTE15 => X_ATTRIBUTE15,
  	X_GLOBAL_ATTRIBUTE1 => X_GLOBAL_ATTRIBUTE1,
  	X_GLOBAL_ATTRIBUTE2 => X_GLOBAL_ATTRIBUTE2,
  	X_GLOBAL_ATTRIBUTE3 => X_GLOBAL_ATTRIBUTE3,
  	X_GLOBAL_ATTRIBUTE4 => X_GLOBAL_ATTRIBUTE4,
  	X_GLOBAL_ATTRIBUTE5 => X_GLOBAL_ATTRIBUTE5,
  	X_GLOBAL_ATTRIBUTE6 => X_GLOBAL_ATTRIBUTE6,
  	X_GLOBAL_ATTRIBUTE7 => X_GLOBAL_ATTRIBUTE7,
  	X_GLOBAL_ATTRIBUTE8 => X_GLOBAL_ATTRIBUTE8,
  	X_GLOBAL_ATTRIBUTE9 => X_GLOBAL_ATTRIBUTE9,
  	X_GLOBAL_ATTRIBUTE10 => X_GLOBAL_ATTRIBUTE10,
  	X_GLOBAL_ATTRIBUTE11 => X_GLOBAL_ATTRIBUTE11,
  	X_GLOBAL_ATTRIBUTE12 => X_GLOBAL_ATTRIBUTE12,
  	X_GLOBAL_ATTRIBUTE13 => X_GLOBAL_ATTRIBUTE13,
  	X_GLOBAL_ATTRIBUTE14 => X_GLOBAL_ATTRIBUTE14,
  	X_GLOBAL_ATTRIBUTE15 => X_GLOBAL_ATTRIBUTE15,
  	X_GLOBAL_ATTRIBUTE16 => X_GLOBAL_ATTRIBUTE16,
  	X_GLOBAL_ATTRIBUTE17 => X_GLOBAL_ATTRIBUTE17,
  	X_GLOBAL_ATTRIBUTE18 => X_GLOBAL_ATTRIBUTE18,
  	X_GLOBAL_ATTRIBUTE19 => X_GLOBAL_ATTRIBUTE19,
  	X_GLOBAL_ATTRIBUTE20 => X_GLOBAL_ATTRIBUTE20,
  	X_GLOBAL_ATTRIBUTE_CATEGORY => X_GLOBAL_ATTRIBUTE_CATEGORY,
  	X_DESCRIPTION => X_DESCRIPTION,
  	X_LAST_UPDATE_DATE => sysdate,
  	X_LAST_UPDATED_BY => user_id,
  	X_LAST_UPDATE_LOGIN => 0);
   exception
      when no_data_found then
	org_freight_tl_pkg.insert_row(
           X_ROWID => row_id,
           X_FREIGHT_CODE => X_FREIGHT_CODE,
  	   X_FREIGHT_CODE_TL=> X_FREIGHT_CODE_TL,
  	   X_ORGANIZATION_ID => org_id,
  	   X_DISABLE_DATE => X_DISABLE_DATE,
  	   X_DISTRIBUTION_ACCOUNT => X_DISTRIBUTION_ACCOUNT,
  	   X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
  	   X_ATTRIBUTE1 => X_ATTRIBUTE1,
  	   X_ATTRIBUTE2 => X_ATTRIBUTE2,
  	   X_ATTRIBUTE3 => X_ATTRIBUTE3,
  	   X_ATTRIBUTE4 => X_ATTRIBUTE4,
  	   X_ATTRIBUTE5 => X_ATTRIBUTE5,
  	   X_ATTRIBUTE6 => X_ATTRIBUTE6,
  	   X_ATTRIBUTE7 => X_ATTRIBUTE7,
  	   X_ATTRIBUTE8 => X_ATTRIBUTE8,
  	   X_ATTRIBUTE9 => X_ATTRIBUTE9,
  	   X_ATTRIBUTE10 => X_ATTRIBUTE10,
  	   X_ATTRIBUTE11 => X_ATTRIBUTE11,
  	   X_ATTRIBUTE12 => X_ATTRIBUTE12,
  	   X_ATTRIBUTE13 => X_ATTRIBUTE13,
  	   X_ATTRIBUTE14 => X_ATTRIBUTE14,
  	   X_ATTRIBUTE15 => X_ATTRIBUTE15,
  	   X_GLOBAL_ATTRIBUTE1 => X_GLOBAL_ATTRIBUTE1,
  	   X_GLOBAL_ATTRIBUTE2 => X_GLOBAL_ATTRIBUTE2,
  	   X_GLOBAL_ATTRIBUTE3 => X_GLOBAL_ATTRIBUTE3,
  	   X_GLOBAL_ATTRIBUTE4 => X_GLOBAL_ATTRIBUTE4,
  	   X_GLOBAL_ATTRIBUTE5 => X_GLOBAL_ATTRIBUTE5,
  	   X_GLOBAL_ATTRIBUTE6 => X_GLOBAL_ATTRIBUTE6,
  	   X_GLOBAL_ATTRIBUTE7 => X_GLOBAL_ATTRIBUTE7,
  	   X_GLOBAL_ATTRIBUTE8 => X_GLOBAL_ATTRIBUTE8,
  	   X_GLOBAL_ATTRIBUTE9 => X_GLOBAL_ATTRIBUTE9,
  	   X_GLOBAL_ATTRIBUTE10 => X_GLOBAL_ATTRIBUTE10,
  	   X_GLOBAL_ATTRIBUTE11 => X_GLOBAL_ATTRIBUTE11,
  	   X_GLOBAL_ATTRIBUTE12 => X_GLOBAL_ATTRIBUTE12,
  	   X_GLOBAL_ATTRIBUTE13 => X_GLOBAL_ATTRIBUTE13,
  	   X_GLOBAL_ATTRIBUTE14 => X_GLOBAL_ATTRIBUTE14,
  	   X_GLOBAL_ATTRIBUTE15 => X_GLOBAL_ATTRIBUTE15,
  	   X_GLOBAL_ATTRIBUTE16 => X_GLOBAL_ATTRIBUTE16,
  	   X_GLOBAL_ATTRIBUTE17 => X_GLOBAL_ATTRIBUTE17,
  	   X_GLOBAL_ATTRIBUTE18 => X_GLOBAL_ATTRIBUTE18,
  	   X_GLOBAL_ATTRIBUTE19 => X_GLOBAL_ATTRIBUTE19,
  	   X_GLOBAL_ATTRIBUTE20 => X_GLOBAL_ATTRIBUTE20,
  	   X_GLOBAL_ATTRIBUTE_CATEGORY => X_GLOBAL_ATTRIBUTE_CATEGORY,
  	   X_DESCRIPTION => X_DESCRIPTION,
  	   X_CREATION_DATE => sysdate,
  	   X_CREATED_BY => user_id,
  	   X_LAST_UPDATE_DATE => sysdate,
  	   X_LAST_UPDATED_BY => user_id,
  	   X_LAST_UPDATE_LOGIN => 0);
end LOAD_ROW;



procedure TRANSLATE_ROW(
  X_FREIGHT_CODE in VARCHAR2,
  X_ORGANIZATION_ID in NUMBER,
  X_FREIGHT_CODE_TL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2)
as
Begin

   update ORG_FREIGHT_TL set
      FREIGHT_CODE_TL = X_FREIGHT_CODE_TL,
      DESCRIPTION = X_DESCRIPTION,
      LAST_UPDATE_DATE = sysdate,
      LAST_UPDATED_BY = decode(X_OWNER, 'SEED', 1, 0),
      LAST_UPDATE_LOGIN = 0,
      SOURCE_LANG = userenv('LANG')
   where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
   and FREIGHT_CODE = X_FREIGHT_CODE
   and ORGANIZATION_ID = X_ORGANIZATION_ID;

end TRANSLATE_ROW;

end ORG_FREIGHT_TL_PKG;

/