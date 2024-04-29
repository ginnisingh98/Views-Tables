--------------------------------------------------------
--  DDL for Package Body FND_CURRENCIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CURRENCIES_PKG" as
/* $Header: AFNLDCXB.pls 120.6.12010000.2 2009/07/24 16:03:02 jvalenti ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CURRENCY_CODE in VARCHAR2,
  X_DERIVE_EFFECTIVE in DATE,
  X_DERIVE_TYPE in VARCHAR2,
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
  X_DERIVE_FACTOR in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_CURRENCY_FLAG in VARCHAR2,
  X_ISSUING_TERRITORY_CODE in VARCHAR2,
  X_PRECISION in NUMBER,
  X_EXTENDED_PRECISION in NUMBER,
  X_SYMBOL in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_CONTEXT in VARCHAR2,
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
  X_ISO_FLAG in VARCHAR2,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE6 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_CURRENCIES
    where CURRENCY_CODE = X_CURRENCY_CODE
    ;
begin
  insert into FND_CURRENCIES (
    DERIVE_EFFECTIVE,
    DERIVE_TYPE,
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
    DERIVE_FACTOR,
    CURRENCY_CODE,
    ENABLED_FLAG,
    CURRENCY_FLAG,
    ISSUING_TERRITORY_CODE,
    PRECISION,
    EXTENDED_PRECISION,
    SYMBOL,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    MINIMUM_ACCOUNTABLE_UNIT,
    CONTEXT,
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
    ISO_FLAG,
    GLOBAL_ATTRIBUTE_CATEGORY,
    GLOBAL_ATTRIBUTE1,
    GLOBAL_ATTRIBUTE2,
    GLOBAL_ATTRIBUTE3,
    GLOBAL_ATTRIBUTE4,
    GLOBAL_ATTRIBUTE5,
    GLOBAL_ATTRIBUTE6,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_DERIVE_EFFECTIVE,
    X_DERIVE_TYPE,
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
    X_DERIVE_FACTOR,
    X_CURRENCY_CODE,
    X_ENABLED_FLAG,
    X_CURRENCY_FLAG,
    X_ISSUING_TERRITORY_CODE,
    NVL(X_PRECISION,0),
    X_EXTENDED_PRECISION,
    X_SYMBOL,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_MINIMUM_ACCOUNTABLE_UNIT,
    X_CONTEXT,
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
    X_ISO_FLAG,
    X_GLOBAL_ATTRIBUTE_CATEGORY,
    X_GLOBAL_ATTRIBUTE1,
    X_GLOBAL_ATTRIBUTE2,
    X_GLOBAL_ATTRIBUTE3,
    X_GLOBAL_ATTRIBUTE4,
    X_GLOBAL_ATTRIBUTE5,
    X_GLOBAL_ATTRIBUTE6,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_CURRENCIES_TL (
    CURRENCY_CODE,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CURRENCY_CODE,
    X_NAME,
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
    from FND_CURRENCIES_TL T
    where T.CURRENCY_CODE = X_CURRENCY_CODE
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
  X_CURRENCY_CODE in VARCHAR2,
  X_DERIVE_EFFECTIVE in DATE,
  X_DERIVE_TYPE in VARCHAR2,
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
  X_DERIVE_FACTOR in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_CURRENCY_FLAG in VARCHAR2,
  X_ISSUING_TERRITORY_CODE in VARCHAR2,
  X_PRECISION in NUMBER,
  X_EXTENDED_PRECISION in NUMBER,
  X_SYMBOL in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_CONTEXT in VARCHAR2,
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
  X_ISO_FLAG in VARCHAR2,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE6 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      DERIVE_EFFECTIVE,
      DERIVE_TYPE,
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
      DERIVE_FACTOR,
      ENABLED_FLAG,
      CURRENCY_FLAG,
      ISSUING_TERRITORY_CODE,
      PRECISION,
      EXTENDED_PRECISION,
      SYMBOL,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      MINIMUM_ACCOUNTABLE_UNIT,
      CONTEXT,
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
      ISO_FLAG,
      GLOBAL_ATTRIBUTE_CATEGORY,
      GLOBAL_ATTRIBUTE1,
      GLOBAL_ATTRIBUTE2,
      GLOBAL_ATTRIBUTE3,
      GLOBAL_ATTRIBUTE4,
      GLOBAL_ATTRIBUTE5,
      GLOBAL_ATTRIBUTE6
    from FND_CURRENCIES
    where CURRENCY_CODE = X_CURRENCY_CODE
    for update of CURRENCY_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION
    from FND_CURRENCIES_TL
    where CURRENCY_CODE = X_CURRENCY_CODE
    and LANGUAGE = userenv('LANG')
    for update of CURRENCY_CODE nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.DERIVE_EFFECTIVE = X_DERIVE_EFFECTIVE)
           OR ((recinfo.DERIVE_EFFECTIVE is null) AND (X_DERIVE_EFFECTIVE is null)))
      AND ((recinfo.DERIVE_TYPE = X_DERIVE_TYPE)
           OR ((recinfo.DERIVE_TYPE is null) AND (X_DERIVE_TYPE is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE7 = X_GLOBAL_ATTRIBUTE7)
           OR ((recinfo.GLOBAL_ATTRIBUTE7 is null) AND (X_GLOBAL_ATTRIBUTE7 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE8 = X_GLOBAL_ATTRIBUTE8)
           OR ((recinfo.GLOBAL_ATTRIBUTE8 is null) AND (X_GLOBAL_ATTRIBUTE8 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE9 = X_GLOBAL_ATTRIBUTE9)
           OR ((recinfo.GLOBAL_ATTRIBUTE9 is null) AND (X_GLOBAL_ATTRIBUTE9 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE10 = X_GLOBAL_ATTRIBUTE10)
           OR ((recinfo.GLOBAL_ATTRIBUTE10 is null) AND (X_GLOBAL_ATTRIBUTE10 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE11 = X_GLOBAL_ATTRIBUTE11)
           OR ((recinfo.GLOBAL_ATTRIBUTE11 is null) AND (X_GLOBAL_ATTRIBUTE11 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE12 = X_GLOBAL_ATTRIBUTE12)
           OR ((recinfo.GLOBAL_ATTRIBUTE12 is null) AND (X_GLOBAL_ATTRIBUTE12 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE13 = X_GLOBAL_ATTRIBUTE13)
           OR ((recinfo.GLOBAL_ATTRIBUTE13 is null) AND (X_GLOBAL_ATTRIBUTE13 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE14 = X_GLOBAL_ATTRIBUTE14)
           OR ((recinfo.GLOBAL_ATTRIBUTE14 is null) AND (X_GLOBAL_ATTRIBUTE14 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE15 = X_GLOBAL_ATTRIBUTE15)
           OR ((recinfo.GLOBAL_ATTRIBUTE15 is null) AND (X_GLOBAL_ATTRIBUTE15 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE16 = X_GLOBAL_ATTRIBUTE16)
           OR ((recinfo.GLOBAL_ATTRIBUTE16 is null) AND (X_GLOBAL_ATTRIBUTE16 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE17 = X_GLOBAL_ATTRIBUTE17)
           OR ((recinfo.GLOBAL_ATTRIBUTE17 is null) AND (X_GLOBAL_ATTRIBUTE17 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE18 = X_GLOBAL_ATTRIBUTE18)
           OR ((recinfo.GLOBAL_ATTRIBUTE18 is null) AND (X_GLOBAL_ATTRIBUTE18 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE19 = X_GLOBAL_ATTRIBUTE19)
           OR ((recinfo.GLOBAL_ATTRIBUTE19 is null) AND (X_GLOBAL_ATTRIBUTE19 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE20 = X_GLOBAL_ATTRIBUTE20)
           OR ((recinfo.GLOBAL_ATTRIBUTE20 is null) AND (X_GLOBAL_ATTRIBUTE20 is null)))
      AND ((recinfo.DERIVE_FACTOR = X_DERIVE_FACTOR)
           OR ((recinfo.DERIVE_FACTOR is null) AND (X_DERIVE_FACTOR is null)))
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.CURRENCY_FLAG = X_CURRENCY_FLAG)
      AND ((recinfo.ISSUING_TERRITORY_CODE = X_ISSUING_TERRITORY_CODE)
           OR ((recinfo.ISSUING_TERRITORY_CODE is null) AND (X_ISSUING_TERRITORY_CODE is null)))
      AND ((recinfo.PRECISION = X_PRECISION)
           OR ((recinfo.PRECISION is null) AND (X_PRECISION is null)))
      AND ((recinfo.EXTENDED_PRECISION = X_EXTENDED_PRECISION)
           OR ((recinfo.EXTENDED_PRECISION is null) AND (X_EXTENDED_PRECISION is null)))
      AND ((recinfo.SYMBOL = X_SYMBOL)
           OR ((recinfo.SYMBOL is null) AND (X_SYMBOL is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      AND ((recinfo.MINIMUM_ACCOUNTABLE_UNIT = X_MINIMUM_ACCOUNTABLE_UNIT)
           OR ((recinfo.MINIMUM_ACCOUNTABLE_UNIT is null) AND (X_MINIMUM_ACCOUNTABLE_UNIT is null)))
      AND ((recinfo.CONTEXT = X_CONTEXT)
           OR ((recinfo.CONTEXT is null) AND (X_CONTEXT is null)))
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
      AND (recinfo.ISO_FLAG = X_ISO_FLAG)
      AND ((recinfo.GLOBAL_ATTRIBUTE_CATEGORY = X_GLOBAL_ATTRIBUTE_CATEGORY)
           OR ((recinfo.GLOBAL_ATTRIBUTE_CATEGORY is null) AND (X_GLOBAL_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE1 = X_GLOBAL_ATTRIBUTE1)
           OR ((recinfo.GLOBAL_ATTRIBUTE1 is null) AND (X_GLOBAL_ATTRIBUTE1 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE2 = X_GLOBAL_ATTRIBUTE2)
           OR ((recinfo.GLOBAL_ATTRIBUTE2 is null) AND (X_GLOBAL_ATTRIBUTE2 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE3 = X_GLOBAL_ATTRIBUTE3)
           OR ((recinfo.GLOBAL_ATTRIBUTE3 is null) AND (X_GLOBAL_ATTRIBUTE3 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE4 = X_GLOBAL_ATTRIBUTE4)
           OR ((recinfo.GLOBAL_ATTRIBUTE4 is null) AND (X_GLOBAL_ATTRIBUTE4 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE5 = X_GLOBAL_ATTRIBUTE5)
           OR ((recinfo.GLOBAL_ATTRIBUTE5 is null) AND (X_GLOBAL_ATTRIBUTE5 is null)))
      AND ((recinfo.GLOBAL_ATTRIBUTE6 = X_GLOBAL_ATTRIBUTE6)
           OR ((recinfo.GLOBAL_ATTRIBUTE6 is null) AND (X_GLOBAL_ATTRIBUTE6 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.NAME = X_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_CURRENCY_CODE in VARCHAR2,
  X_DERIVE_EFFECTIVE in DATE,
  X_DERIVE_TYPE in VARCHAR2,
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
  X_DERIVE_FACTOR in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_CURRENCY_FLAG in VARCHAR2,
  X_ISSUING_TERRITORY_CODE in VARCHAR2,
  X_PRECISION in NUMBER,
  X_EXTENDED_PRECISION in NUMBER,
  X_SYMBOL in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_CONTEXT in VARCHAR2,
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
  X_ISO_FLAG in VARCHAR2,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2,
  X_GLOBAL_ATTRIBUTE6 in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin

  update FND_CURRENCIES set
    DERIVE_EFFECTIVE = X_DERIVE_EFFECTIVE,
    DERIVE_TYPE = X_DERIVE_TYPE,
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
    DERIVE_FACTOR = X_DERIVE_FACTOR,
    ENABLED_FLAG = X_ENABLED_FLAG,
    CURRENCY_FLAG = X_CURRENCY_FLAG,
    ISSUING_TERRITORY_CODE = X_ISSUING_TERRITORY_CODE,
    PRECISION = NVL(X_PRECISION,0),
    EXTENDED_PRECISION = X_EXTENDED_PRECISION,
    SYMBOL = X_SYMBOL,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    MINIMUM_ACCOUNTABLE_UNIT = X_MINIMUM_ACCOUNTABLE_UNIT,
    CONTEXT = X_CONTEXT,
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
    ISO_FLAG = X_ISO_FLAG,
    GLOBAL_ATTRIBUTE_CATEGORY = X_GLOBAL_ATTRIBUTE_CATEGORY,
    GLOBAL_ATTRIBUTE1 = X_GLOBAL_ATTRIBUTE1,
    GLOBAL_ATTRIBUTE2 = X_GLOBAL_ATTRIBUTE2,
    GLOBAL_ATTRIBUTE3 = X_GLOBAL_ATTRIBUTE3,
    GLOBAL_ATTRIBUTE4 = X_GLOBAL_ATTRIBUTE4,
    GLOBAL_ATTRIBUTE5 = X_GLOBAL_ATTRIBUTE5,
    GLOBAL_ATTRIBUTE6 = X_GLOBAL_ATTRIBUTE6,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CURRENCY_CODE = X_CURRENCY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_CURRENCIES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CURRENCY_CODE = X_CURRENCY_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CURRENCY_CODE in VARCHAR2
) is
begin
  delete from FND_CURRENCIES
  where CURRENCY_CODE = X_CURRENCY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_CURRENCIES_TL
  where CURRENCY_CODE = X_CURRENCY_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin

/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from FND_CURRENCIES_TL T
  where not exists
    (select NULL
    from FND_CURRENCIES B
    where B.CURRENCY_CODE = T.CURRENCY_CODE
    );

  update FND_CURRENCIES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from FND_CURRENCIES_TL B
    where B.CURRENCY_CODE = T.CURRENCY_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CURRENCY_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.CURRENCY_CODE,
      SUBT.LANGUAGE
    from FND_CURRENCIES_TL SUBB, FND_CURRENCIES_TL SUBT
    where SUBB.CURRENCY_CODE = SUBT.CURRENCY_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert into FND_CURRENCIES_TL (
    CURRENCY_CODE,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CURRENCY_CODE,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_CURRENCIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_CURRENCIES_TL T
    where T.CURRENCY_CODE = B.CURRENCY_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW(
  X_CURRENCY_CODE in varchar2,
  X_NAME in varchar2,
  X_DESCRIPTION in varchar2,
  X_OWNER in varchar2) is
begin
  TRANSLATE_ROW (
    X_CURRENCY_CODE => X_CURRENCY_CODE ,
    X_NAME => X_NAME ,
    X_DESCRIPTION         => X_DESCRIPTION,
    X_OWNER               => X_OWNER,
    X_LAST_UPDATE_DATE    => null,
    X_CUSTOM_MODE         => null);
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_CURRENCY_CODE in VARCHAR2,
  X_DERIVE_EFFECTIVE in DATE,
  X_DERIVE_TYPE in VARCHAR2,
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
  X_DERIVE_FACTOR in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_CURRENCY_FLAG in VARCHAR2,
  X_ISSUING_TERRITORY_CODE in VARCHAR2,
  X_PRECISION in NUMBER,
  X_EXTENDED_PRECISION in NUMBER,
  X_SYMBOL in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_CONTEXT in VARCHAR2,
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
  X_ISO_FLAG in VARCHAR2,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2)
is
begin
  LOAD_ROW (
    X_CURRENCY_CODE => 		X_CURRENCY_CODE ,
    X_DERIVE_EFFECTIVE => 	X_DERIVE_EFFECTIVE ,
    X_DERIVE_TYPE => 		X_DERIVE_TYPE ,
    X_GLOBAL_ATTRIBUTE1 => 	X_GLOBAL_ATTRIBUTE1 ,
    X_GLOBAL_ATTRIBUTE2 => 	X_GLOBAL_ATTRIBUTE2 ,
    X_GLOBAL_ATTRIBUTE3 => 	X_GLOBAL_ATTRIBUTE3 ,
    X_GLOBAL_ATTRIBUTE4 => 	X_GLOBAL_ATTRIBUTE4,
    X_GLOBAL_ATTRIBUTE5 =>    X_GLOBAL_ATTRIBUTE5,
    X_GLOBAL_ATTRIBUTE6 =>	X_GLOBAL_ATTRIBUTE6,
    X_GLOBAL_ATTRIBUTE7 =>	X_GLOBAL_ATTRIBUTE7,
    X_GLOBAL_ATTRIBUTE8 =>    X_GLOBAL_ATTRIBUTE8,
    X_GLOBAL_ATTRIBUTE9 =>	X_GLOBAL_ATTRIBUTE9,
    X_GLOBAL_ATTRIBUTE10 =>   X_GLOBAL_ATTRIBUTE10,
    X_GLOBAL_ATTRIBUTE11 =>	X_GLOBAL_ATTRIBUTE11,
    X_GLOBAL_ATTRIBUTE12 =>   X_GLOBAL_ATTRIBUTE12,
    X_GLOBAL_ATTRIBUTE13 =>   X_GLOBAL_ATTRIBUTE13,
    X_GLOBAL_ATTRIBUTE14=>    X_GLOBAL_ATTRIBUTE14,
    X_GLOBAL_ATTRIBUTE15 =>   X_GLOBAL_ATTRIBUTE15,
    X_GLOBAL_ATTRIBUTE16 =>   X_GLOBAL_ATTRIBUTE16,
    X_GLOBAL_ATTRIBUTE17 =>	X_GLOBAL_ATTRIBUTE17,
    X_GLOBAL_ATTRIBUTE18 =>   X_GLOBAL_ATTRIBUTE18,
    X_GLOBAL_ATTRIBUTE19 =>	X_GLOBAL_ATTRIBUTE19,
    X_GLOBAL_ATTRIBUTE20 =>	X_GLOBAL_ATTRIBUTE20,
    X_DERIVE_FACTOR =>    	X_DERIVE_FACTOR,
    X_ENABLED_FLAG =>    	X_ENABLED_FLAG,
    X_CURRENCY_FLAG =>          X_CURRENCY_FLAG,
    X_ISSUING_TERRITORY_CODE =>	X_ISSUING_TERRITORY_CODE ,
    X_PRECISION =>		X_PRECISION,
    X_EXTENDED_PRECISION =>	X_EXTENDED_PRECISION,
    X_SYMBOL =>    		X_SYMBOL,
    X_START_DATE_ACTIVE =>    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE =>	X_END_DATE_ACTIVE,
    X_MINIMUM_ACCOUNTABLE_UNIT =>	X_MINIMUM_ACCOUNTABLE_UNIT,
    X_CONTEXT =>    		X_CONTEXT,
    X_ATTRIBUTE1 =>    		X_ATTRIBUTE1,
    X_ATTRIBUTE2 =>    		X_ATTRIBUTE2,
    X_ATTRIBUTE3 =>    		X_ATTRIBUTE3,
    X_ATTRIBUTE4 =>		X_ATTRIBUTE4,
    X_ATTRIBUTE5 =>    		X_ATTRIBUTE5,
    X_ATTRIBUTE6 =>		X_ATTRIBUTE6,
    X_ATTRIBUTE7 =>		X_ATTRIBUTE7,
    X_ATTRIBUTE8 =>		X_ATTRIBUTE8,
    X_ATTRIBUTE9 =>		X_ATTRIBUTE9,
    X_ATTRIBUTE10 =>		X_ATTRIBUTE10,
    X_ATTRIBUTE11 =>    	X_ATTRIBUTE11,
    X_ATTRIBUTE12 =>		X_ATTRIBUTE12,
    X_ATTRIBUTE13 =>    	X_ATTRIBUTE13,
    X_ATTRIBUTE14 =>		X_ATTRIBUTE14,
    X_ATTRIBUTE15 =>		X_ATTRIBUTE15,
    X_ISO_FLAG =>    		X_ISO_FLAG,
    X_GLOBAL_ATTRIBUTE_CATEGORY =>	X_GLOBAL_ATTRIBUTE_CATEGORY,
    X_NAME =>    			X_NAME,
    X_DESCRIPTION         => 	X_DESCRIPTION,
    X_OWNER               => 	X_OWNER,
    X_LAST_UPDATE_DATE    => 	null,
    X_CUSTOM_MODE         => 	null);

end LOAD_ROW;


procedure TRANSLATE_ROW(
  X_CURRENCY_CODE in varchar2,
  X_NAME in varchar2,
  X_DESCRIPTION in varchar2,
  X_OWNER in varchar2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

begin
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

  select last_updated_by, last_update_date
  into db_luby, db_ludate
  from FND_CURRENCIES_TL
  where CURRENCY_CODE = X_CURRENCY_CODE
  and language            = userenv('LANG');

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then
  update fnd_currencies_tl set
    NAME= X_NAME,
    DESCRIPTION= X_DESCRIPTION,
    LAST_UPDATE_DATE = f_ludate,
    LAST_UPDATED_BY = f_luby,
    LAST_UPDATE_LOGIN = 0,
    SOURCE_LANG = userenv('LANG')
  where CURRENCY_CODE = X_CURRENCY_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
 end if;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_CURRENCY_CODE in VARCHAR2,
  X_DERIVE_EFFECTIVE in DATE,
  X_DERIVE_TYPE in VARCHAR2,
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
  X_DERIVE_FACTOR in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_CURRENCY_FLAG in VARCHAR2,
  X_ISSUING_TERRITORY_CODE in VARCHAR2,
  X_PRECISION in NUMBER,
  X_EXTENDED_PRECISION in  NUMBER,
  X_SYMBOL in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_MINIMUM_ACCOUNTABLE_UNIT in NUMBER,
  X_CONTEXT in VARCHAR2,
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
  X_ISO_FLAG in VARCHAR2,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
)
is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  X_ROWID VARCHAR2(64);
  user_id NUMBER;

  -- Bug4493112 - Moved this variables from update_row to load_row.

  L_DERIVE_EFFECTIVE DATE;
  L_DERIVE_TYPE VARCHAR2(8);
  L_GLOBAL_ATTRIBUTE7 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE8 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE9 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE10 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE11 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE12 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE13 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE14 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE15 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE16 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE17 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE18 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE19 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE20 VARCHAR2(150);
  L_DERIVE_FACTOR NUMBER;
  L_ISSUING_TERRITORY_CODE VARCHAR2(2);
  L_PRECISION NUMBER;
  L_EXTENDED_PRECISION NUMBER;
  L_SYMBOL VARCHAR2(12);
  L_START_DATE_ACTIVE DATE;
  L_END_DATE_ACTIVE DATE;
  L_MINIMUM_ACCOUNTABLE_UNIT NUMBER;
  L_CONTEXT VARCHAR2(80);
  L_ATTRIBUTE1 VARCHAR2(150);
  L_ATTRIBUTE2 VARCHAR2(150);
  L_ATTRIBUTE3 VARCHAR2(150);
  L_ATTRIBUTE4 VARCHAR2(150);
  L_ATTRIBUTE5 VARCHAR2(150);
  L_ATTRIBUTE6 VARCHAR2(150);
  L_ATTRIBUTE7 VARCHAR2(150);
  L_ATTRIBUTE8 VARCHAR2(150);
  L_ATTRIBUTE9 VARCHAR2(150);
  L_ATTRIBUTE10 VARCHAR2(150);
  L_ATTRIBUTE11 VARCHAR2(150);
  L_ATTRIBUTE12 VARCHAR2(150);
  L_ATTRIBUTE13 VARCHAR2(150);
  L_ATTRIBUTE14 VARCHAR2(150);
  L_ATTRIBUTE15 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE_CATEGORY VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE1 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE2 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE3 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE4 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE5 VARCHAR2(150);
  L_GLOBAL_ATTRIBUTE6 VARCHAR2(150);


begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);

 begin

 select last_updated_by, last_update_date
  into db_luby, db_ludate
  from FND_CURRENCIES
  where CURRENCY_CODE = X_CURRENCY_CODE;


  -- Bug4493112 Moved decode select statement from update_row to load_row.
  -- Bug4648984 Moved code inside of exception block so no data found is
  --            handled.

  select
          decode(x_issuing_territory_code, fnd_currencies_pkg.null_char, null,
                  null, u.issuing_territory_code,
                  x_issuing_territory_code),
          decode(x_precision, fnd_currencies_pkg.null_number, null,
                  null, u.precision,
                  x_precision),
          decode(x_extended_precision, fnd_currencies_pkg.null_number, null,
                  null, u.extended_precision,
                  x_extended_precision),
          decode(x_symbol, fnd_currencies_pkg.null_char, null,
                  null, u.symbol,
                  x_symbol),
          decode(x_start_date_active, fnd_currencies_pkg.null_date, null,
                null, u.start_date_active,
                x_start_date_active),
          decode(x_end_date_active, fnd_currencies_pkg.null_date, null,
                null, u.end_date_active,
                x_end_date_active),
          decode(x_minimum_accountable_unit, fnd_currencies_pkg.null_number,
                 null,
                  null, u.minimum_accountable_unit,
                  x_minimum_accountable_unit),
          decode(x_context, fnd_currencies_pkg.null_char, null,
                  null, u.context,
                  x_context),
          decode(x_attribute1, fnd_currencies_pkg.null_char, null,
                  null, u.attribute1,
                  x_attribute1),
          decode(x_attribute2, fnd_currencies_pkg.null_char, null,
                  null, u.attribute2,
                  x_attribute2),
          decode(x_attribute3, fnd_currencies_pkg.null_char, null,
                  null, u.attribute3,
                  x_attribute3),
          decode(x_attribute4, fnd_currencies_pkg.null_char, null,
                  null, u.attribute4,
                  x_attribute4),
          decode(x_attribute5, fnd_currencies_pkg.null_char, null,
                  null, u.attribute5,
                  x_attribute5),
          decode(x_attribute6, fnd_currencies_pkg.null_char, null,
                  null, u.attribute6,
                  x_attribute6),
          decode(x_attribute7, fnd_currencies_pkg.null_char, null,
                  null, u.attribute7,
                  x_attribute7),
          decode(x_attribute8, fnd_currencies_pkg.null_char, null,
                  null, u.attribute8,
                  x_attribute8),
          decode(x_attribute9, fnd_currencies_pkg.null_char, null,
                  null, u.attribute9,
                  x_attribute9),
          decode(x_attribute10, fnd_currencies_pkg.null_char, null,
                  null, u.attribute10,
                  x_attribute10),
          decode(x_attribute11, fnd_currencies_pkg.null_char, null,
                  null, u.attribute11,
                  x_attribute11),
          decode(x_attribute12, fnd_currencies_pkg.null_char, null,
                  null, u.attribute12,
                  x_attribute12),
          decode(x_attribute13, fnd_currencies_pkg.null_char, null,
                  null, u.attribute13,
                  x_attribute13),
          decode(x_attribute14, fnd_currencies_pkg.null_char, null,
                  null, u.attribute14,
                  x_attribute14),
          decode(x_attribute15, fnd_currencies_pkg.null_char, null,
                  null, u.attribute15,
                  x_attribute15),
          decode(x_global_attribute_category, fnd_currencies_pkg.null_char,
                  null,
                  null, u.global_attribute_category,
                  x_global_attribute_category),
          decode(x_global_attribute1, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute1,
                  x_global_attribute1),
          decode(x_global_attribute2, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute2,
                  x_global_attribute2),
          decode(x_global_attribute3, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute3,
                  x_global_attribute3),
          decode(x_global_attribute4, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute4,
                  x_global_attribute4),
          decode(x_global_attribute5, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute5,
                  x_global_attribute5),
          decode(x_global_attribute6, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute6,
                  x_global_attribute6),
          decode(x_global_attribute7, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute7,
                  x_global_attribute7),
          decode(x_global_attribute8, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute8,
                  x_global_attribute8),
          decode(x_global_attribute9, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute9,
                  x_global_attribute9),
          decode(x_global_attribute10, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute10,
                  x_global_attribute10),
          decode(x_global_attribute11, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute11,
                  x_global_attribute11),
          decode(x_global_attribute12, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute12,
                  x_global_attribute12),
          decode(x_global_attribute13, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute13,
                  x_global_attribute13),
          decode(x_global_attribute14, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute14,
                  x_global_attribute14),
          decode(x_global_attribute15, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute15,
                  x_global_attribute15),
          decode(x_global_attribute16, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute16,
                  x_global_attribute16),
          decode(x_global_attribute17, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute17,
                  x_global_attribute17),
          decode(x_global_attribute18, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute18,
                  x_global_attribute18),
          decode(x_global_attribute19, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute19,
                  x_global_attribute19),
          decode(x_global_attribute20, fnd_currencies_pkg.null_char, null,
                  null, u.global_attribute20,
                  x_global_attribute20),
          decode(X_DERIVE_EFFECTIVE, fnd_currencies_pkg.null_date, null,
                null, u.DERIVE_EFFECTIVE,
                X_DERIVE_EFFECTIVE),
          decode(x_derive_type, fnd_currencies_pkg.null_char, null,
                  null, u.derive_type,
                  x_derive_type),
          decode(x_derive_factor, fnd_currencies_pkg.null_number, null,
                  null, u.derive_factor,
                  x_derive_factor)
     into L_ISSUING_TERRITORY_CODE, L_PRECISION, L_EXTENDED_PRECISION,
          L_SYMBOL, L_START_DATE_ACTIVE, L_END_DATE_ACTIVE,
          L_MINIMUM_ACCOUNTABLE_UNIT, L_CONTEXT,
          L_ATTRIBUTE1, L_ATTRIBUTE2, L_ATTRIBUTE3, L_ATTRIBUTE4,
          L_ATTRIBUTE5, L_ATTRIBUTE6, L_ATTRIBUTE7, L_ATTRIBUTE8,
          L_ATTRIBUTE9,L_ATTRIBUTE10, L_ATTRIBUTE11, L_ATTRIBUTE12,
          L_ATTRIBUTE13,L_ATTRIBUTE14, L_ATTRIBUTE15,
          L_GLOBAL_ATTRIBUTE_CATEGORY,
          L_GLOBAL_ATTRIBUTE1, L_GLOBAL_ATTRIBUTE2, L_GLOBAL_ATTRIBUTE3,
          L_GLOBAL_ATTRIBUTE4, L_GLOBAL_ATTRIBUTE5, L_GLOBAL_ATTRIBUTE6,
          L_GLOBAL_ATTRIBUTE7,L_GLOBAL_ATTRIBUTE8, L_GLOBAL_ATTRIBUTE9,
          L_GLOBAL_ATTRIBUTE10,L_GLOBAL_ATTRIBUTE11, L_GLOBAL_ATTRIBUTE12,
          L_GLOBAL_ATTRIBUTE13,L_GLOBAL_ATTRIBUTE14, L_GLOBAL_ATTRIBUTE15,
          L_GLOBAL_ATTRIBUTE16,L_GLOBAL_ATTRIBUTE17, L_GLOBAL_ATTRIBUTE18,
          L_GLOBAL_ATTRIBUTE19,L_GLOBAL_ATTRIBUTE20,
          L_DERIVE_EFFECTIVE, L_DERIVE_TYPE, L_DERIVE_FACTOR
     from FND_CURRENCIES U
          where CURRENCY_CODE = X_CURRENCY_CODE;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then

  -- Bug4493112 Modified calls to UPDATE_ROW AND INSERT_ROW to use local
  --            variables.

  FND_CURRENCIES_PKG.UPDATE_ROW(
    X_CURRENCY_CODE,
    L_DERIVE_EFFECTIVE,
    L_DERIVE_TYPE,
    L_GLOBAL_ATTRIBUTE7,
    L_GLOBAL_ATTRIBUTE8,
    L_GLOBAL_ATTRIBUTE9,
    L_GLOBAL_ATTRIBUTE10,
    L_GLOBAL_ATTRIBUTE11,
    L_GLOBAL_ATTRIBUTE12,
    L_GLOBAL_ATTRIBUTE13,
    L_GLOBAL_ATTRIBUTE14,
    L_GLOBAL_ATTRIBUTE15,
    L_GLOBAL_ATTRIBUTE16,
    L_GLOBAL_ATTRIBUTE17,
    L_GLOBAL_ATTRIBUTE18,
    L_GLOBAL_ATTRIBUTE19,
    L_GLOBAL_ATTRIBUTE20,
    L_DERIVE_FACTOR,
    X_ENABLED_FLAG,
    X_CURRENCY_FLAG,
    L_ISSUING_TERRITORY_CODE,
    L_PRECISION,
    L_EXTENDED_PRECISION,
    L_SYMBOL,
    L_START_DATE_ACTIVE,
    L_END_DATE_ACTIVE,
    L_MINIMUM_ACCOUNTABLE_UNIT,
    L_CONTEXT,
    L_ATTRIBUTE1,
    L_ATTRIBUTE2,
    L_ATTRIBUTE3,
    L_ATTRIBUTE4,
    L_ATTRIBUTE5,
    L_ATTRIBUTE6,
    L_ATTRIBUTE7,
    L_ATTRIBUTE8,
    L_ATTRIBUTE9,
    L_ATTRIBUTE10,
    L_ATTRIBUTE11,
    L_ATTRIBUTE12,
    L_ATTRIBUTE13,
    L_ATTRIBUTE14,
    L_ATTRIBUTE15,
    X_ISO_FLAG,
    L_GLOBAL_ATTRIBUTE_CATEGORY,
    L_GLOBAL_ATTRIBUTE1,
    L_GLOBAL_ATTRIBUTE2,
    L_GLOBAL_ATTRIBUTE3,
    L_GLOBAL_ATTRIBUTE4,
    L_GLOBAL_ATTRIBUTE5,
    L_GLOBAL_ATTRIBUTE6,
    X_NAME,
    X_DESCRIPTION,
    f_ludate,
    f_luby,
    0);
   end if;

  EXCEPTION
    WHEN no_data_found then

  -- bug7292241 - Need to correctly translate the provided NULL value
  --              for inserting a new record.

 select decode(x_issuing_territory_code, fnd_currencies_pkg.null_char, null,
                  null, null, x_issuing_territory_code),
          decode(x_precision, fnd_currencies_pkg.null_number, null,
                  null, null,x_precision),
          decode(x_extended_precision, fnd_currencies_pkg.null_number, null,
                  null, null, x_extended_precision),
          decode(x_symbol, fnd_currencies_pkg.null_char, null,
                  null, null, x_symbol),
          decode(x_start_date_active, fnd_currencies_pkg.null_date, null,
                null, null, x_start_date_active),
          decode(x_end_date_active, fnd_currencies_pkg.null_date, null,
                null, null, x_end_date_active),
          decode(x_minimum_accountable_unit, fnd_currencies_pkg.null_number,
                 null, null,x_minimum_accountable_unit),
          decode(x_context, fnd_currencies_pkg.null_char, null,
                  null, null, x_context),
          decode(x_attribute1, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute1),
          decode(x_attribute2, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute2),
          decode(x_attribute3, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute3),
          decode(x_attribute4, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute4),
          decode(x_attribute5, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute5),
          decode(x_attribute6, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute6),
          decode(x_attribute7, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute7),
          decode(x_attribute8, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute8),
          decode(x_attribute9, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute9),
          decode(x_attribute10, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute10),
          decode(x_attribute11, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute11),
          decode(x_attribute12, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute12),
          decode(x_attribute13, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute13),
          decode(x_attribute14, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute14),
          decode(x_attribute15, fnd_currencies_pkg.null_char, null,
                  null, null, x_attribute15),
          decode(x_global_attribute_category, fnd_currencies_pkg.null_char,
                  null,
                  null, x_global_attribute_category),
          decode(x_global_attribute1, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute1),
          decode(x_global_attribute2, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute2),
          decode(x_global_attribute3, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute3),
          decode(x_global_attribute4, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute4),
          decode(x_global_attribute5, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute5),
          decode(x_global_attribute6, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute6),
          decode(x_global_attribute7, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute7),
          decode(x_global_attribute8, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute8),
          decode(x_global_attribute9, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute9),
          decode(x_global_attribute10, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute10),
          decode(x_global_attribute11, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute11),
          decode(x_global_attribute12, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute12),
          decode(x_global_attribute13, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute13),
          decode(x_global_attribute14, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute14),
          decode(x_global_attribute15, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute15),
          decode(x_global_attribute16, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute16),
          decode(x_global_attribute17, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute17),
          decode(x_global_attribute18, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute18),
          decode(x_global_attribute19, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute19),
          decode(x_global_attribute20, fnd_currencies_pkg.null_char, null,
                  null, null, x_global_attribute20),
          decode(X_DERIVE_EFFECTIVE, fnd_currencies_pkg.null_date, null,
                null, null, x_DERIVE_EFFECTIVE),
          decode(x_derive_type, fnd_currencies_pkg.null_char, null,
                  null, null, x_derive_type),
          decode(x_derive_factor, fnd_currencies_pkg.null_number, null,
                  null, null, x_derive_factor)
     into L_ISSUING_TERRITORY_CODE, L_PRECISION, L_EXTENDED_PRECISION,
          L_SYMBOL, L_START_DATE_ACTIVE, L_END_DATE_ACTIVE,
          L_MINIMUM_ACCOUNTABLE_UNIT, L_CONTEXT,
          L_ATTRIBUTE1, L_ATTRIBUTE2, L_ATTRIBUTE3, L_ATTRIBUTE4,
          L_ATTRIBUTE5, L_ATTRIBUTE6, L_ATTRIBUTE7, L_ATTRIBUTE8,
          L_ATTRIBUTE9,L_ATTRIBUTE10, L_ATTRIBUTE11, L_ATTRIBUTE12,
          L_ATTRIBUTE13,L_ATTRIBUTE14, L_ATTRIBUTE15,
          L_GLOBAL_ATTRIBUTE_CATEGORY,
          L_GLOBAL_ATTRIBUTE1, L_GLOBAL_ATTRIBUTE2, L_GLOBAL_ATTRIBUTE3,
          L_GLOBAL_ATTRIBUTE4, L_GLOBAL_ATTRIBUTE5, L_GLOBAL_ATTRIBUTE6,
          L_GLOBAL_ATTRIBUTE7,L_GLOBAL_ATTRIBUTE8, L_GLOBAL_ATTRIBUTE9,
          L_GLOBAL_ATTRIBUTE10,L_GLOBAL_ATTRIBUTE11, L_GLOBAL_ATTRIBUTE12,
          L_GLOBAL_ATTRIBUTE13,L_GLOBAL_ATTRIBUTE14, L_GLOBAL_ATTRIBUTE15,
          L_GLOBAL_ATTRIBUTE16,L_GLOBAL_ATTRIBUTE17, L_GLOBAL_ATTRIBUTE18,
          L_GLOBAL_ATTRIBUTE19,L_GLOBAL_ATTRIBUTE20,
          L_DERIVE_EFFECTIVE, L_DERIVE_TYPE, L_DERIVE_FACTOR
     from DUAL;

    FND_CURRENCIES_PKG.INSERT_ROW(
    X_ROWID,
    X_CURRENCY_CODE,
    L_DERIVE_EFFECTIVE,		--bug6317914 removed to_date
    L_DERIVE_TYPE,
    L_GLOBAL_ATTRIBUTE7,
    L_GLOBAL_ATTRIBUTE8,
    L_GLOBAL_ATTRIBUTE9,
    L_GLOBAL_ATTRIBUTE10,
    L_GLOBAL_ATTRIBUTE11,
    L_GLOBAL_ATTRIBUTE12,
    L_GLOBAL_ATTRIBUTE13,
    L_GLOBAL_ATTRIBUTE14,
    L_GLOBAL_ATTRIBUTE15,
    L_GLOBAL_ATTRIBUTE16,
    L_GLOBAL_ATTRIBUTE17,
    L_GLOBAL_ATTRIBUTE18,
    L_GLOBAL_ATTRIBUTE19,
    L_GLOBAL_ATTRIBUTE20,
    L_DERIVE_FACTOR,
    X_ENABLED_FLAG,
    X_CURRENCY_FLAG,
    L_ISSUING_TERRITORY_CODE,
    L_PRECISION,
    L_EXTENDED_PRECISION,
    L_SYMBOL,
    L_START_DATE_ACTIVE,	--bug6317914 removed to_date
    L_END_DATE_ACTIVE,		--bug6317914 removed to_date
    L_MINIMUM_ACCOUNTABLE_UNIT,
    L_CONTEXT,
    L_ATTRIBUTE1,
    L_ATTRIBUTE2,
    L_ATTRIBUTE3,
    L_ATTRIBUTE4,
    L_ATTRIBUTE5,
    L_ATTRIBUTE6,
    L_ATTRIBUTE7,
    L_ATTRIBUTE8,
    L_ATTRIBUTE9,
    L_ATTRIBUTE10,
    L_ATTRIBUTE11,
    L_ATTRIBUTE12,
    L_ATTRIBUTE13,
    L_ATTRIBUTE14,
    L_ATTRIBUTE15,
    X_ISO_FLAG,
    L_GLOBAL_ATTRIBUTE_CATEGORY,
    L_GLOBAL_ATTRIBUTE1,
    L_GLOBAL_ATTRIBUTE2,
    L_GLOBAL_ATTRIBUTE3,
    L_GLOBAL_ATTRIBUTE4,
    L_GLOBAL_ATTRIBUTE5,
    L_GLOBAL_ATTRIBUTE6,
    X_NAME,
    X_DESCRIPTION,
    f_ludate,
    f_luby,
    f_ludate,
    f_luby,
    0);
 end;
end LOAD_ROW;

end FND_CURRENCIES_PKG;

/
