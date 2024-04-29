--------------------------------------------------------
--  DDL for Package Body FA_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CATEGORIES_PKG" as
/* $Header: faxicab.pls 120.5.12010000.2 2009/07/19 13:19:24 glchen ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_SUMMARY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OWNED_LEASED in VARCHAR2,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CAPITALIZE_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PROPERTY_TYPE_CODE in VARCHAR2,
  X_PROPERTY_1245_1250_CODE in VARCHAR2,
  X_DATE_INEFFECTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2 DEFAULT NULL,
  X_PRODUCTION_CAPACITY in NUMBER DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_INVENTORIAL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
  cursor C is select ROWID from FA_CATEGORIES_B
    where CATEGORY_ID = X_CATEGORY_ID
    ;
begin
  insert into FA_CATEGORIES_B (
    CATEGORY_ID,
    SUMMARY_FLAG,
    ENABLED_FLAG,
    OWNED_LEASED,
    CATEGORY_TYPE,
    CAPITALIZE_FLAG,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    PROPERTY_TYPE_CODE,
    PROPERTY_1245_1250_CODE,
    DATE_INEFFECTIVE,
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
    ATTRIBUTE_CATEGORY_CODE,
    PRODUCTION_CAPACITY,
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
    INVENTORIAL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CATEGORY_ID,
    X_SUMMARY_FLAG,
    X_ENABLED_FLAG,
    X_OWNED_LEASED,
    X_CATEGORY_TYPE,
    X_CAPITALIZE_FLAG,
    X_SEGMENT1,
    X_SEGMENT2,
    X_SEGMENT3,
    X_SEGMENT4,
    X_SEGMENT5,
    X_SEGMENT6,
    X_SEGMENT7,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_PROPERTY_TYPE_CODE,
    X_PROPERTY_1245_1250_CODE,
    X_DATE_INEFFECTIVE,
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
    X_ATTRIBUTE_CATEGORY_CODE,
    X_PRODUCTION_CAPACITY,
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
    X_INVENTORIAL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FA_CATEGORIES_TL (
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    CATEGORY_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_CATEGORY_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FA_CATEGORIES_TL T
    where T.CATEGORY_ID = X_CATEGORY_ID
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
  X_CATEGORY_ID in NUMBER,
  X_SUMMARY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OWNED_LEASED in VARCHAR2,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CAPITALIZE_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PROPERTY_TYPE_CODE in VARCHAR2,
  X_PROPERTY_1245_1250_CODE in VARCHAR2,
  X_DATE_INEFFECTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2 DEFAULT NULL,
  X_PRODUCTION_CAPACITY in NUMBER DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_INVENTORIAL in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
  cursor c is select
      SUMMARY_FLAG,
      ENABLED_FLAG,
      OWNED_LEASED,
      CATEGORY_TYPE,
      CAPITALIZE_FLAG,
      SEGMENT1,
      SEGMENT2,
      SEGMENT3,
      SEGMENT4,
      SEGMENT5,
      SEGMENT6,
      SEGMENT7,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      PROPERTY_TYPE_CODE,
      PROPERTY_1245_1250_CODE,
      DATE_INEFFECTIVE,
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
      ATTRIBUTE_CATEGORY_CODE,
      PRODUCTION_CAPACITY,
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
      INVENTORIAL
    from FA_CATEGORIES_B
    where CATEGORY_ID = X_CATEGORY_ID
    for update of CATEGORY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FA_CATEGORIES_TL
    where CATEGORY_ID = X_CATEGORY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CATEGORY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.SUMMARY_FLAG = X_SUMMARY_FLAG)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.OWNED_LEASED = X_OWNED_LEASED)
      AND (recinfo.CATEGORY_TYPE = X_CATEGORY_TYPE)
      AND (recinfo.CAPITALIZE_FLAG = X_CAPITALIZE_FLAG)
      AND ((recinfo.SEGMENT1 = X_SEGMENT1)
           OR ((recinfo.SEGMENT1 is null) AND (X_SEGMENT1 is null)))
      AND ((recinfo.SEGMENT2 = X_SEGMENT2)
           OR ((recinfo.SEGMENT2 is null) AND (X_SEGMENT2 is null)))
      AND ((recinfo.SEGMENT3 = X_SEGMENT3)
           OR ((recinfo.SEGMENT3 is null) AND (X_SEGMENT3 is null)))
      AND ((recinfo.SEGMENT4 = X_SEGMENT4)
           OR ((recinfo.SEGMENT4 is null) AND (X_SEGMENT4 is null)))
      AND ((recinfo.SEGMENT5 = X_SEGMENT5)
           OR ((recinfo.SEGMENT5 is null) AND (X_SEGMENT5 is null)))
      AND ((recinfo.SEGMENT6 = X_SEGMENT6)
           OR ((recinfo.SEGMENT6 is null) AND (X_SEGMENT6 is null)))
      AND ((recinfo.SEGMENT7 = X_SEGMENT7)
           OR ((recinfo.SEGMENT7 is null) AND (X_SEGMENT7 is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      AND ((recinfo.PROPERTY_TYPE_CODE = X_PROPERTY_TYPE_CODE)
           OR ((recinfo.PROPERTY_TYPE_CODE is null) AND (X_PROPERTY_TYPE_CODE is null)))
      AND ((recinfo.PROPERTY_1245_1250_CODE = X_PROPERTY_1245_1250_CODE)
           OR ((recinfo.PROPERTY_1245_1250_CODE is null) AND (X_PROPERTY_1245_1250_CODE is null)))
      AND ((recinfo.DATE_INEFFECTIVE = X_DATE_INEFFECTIVE)
           OR ((recinfo.DATE_INEFFECTIVE is null) AND (X_DATE_INEFFECTIVE is null)))
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
      AND ((recinfo.ATTRIBUTE_CATEGORY_CODE = X_ATTRIBUTE_CATEGORY_CODE)
           OR ((recinfo.ATTRIBUTE_CATEGORY_CODE is null) AND (X_ATTRIBUTE_CATEGORY_CODE is null)))
      AND ((recinfo.PRODUCTION_CAPACITY = X_PRODUCTION_CAPACITY)
           OR ((recinfo.PRODUCTION_CAPACITY is null) AND (X_PRODUCTION_CAPACITY is null)))
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
      AND ((recinfo.GLOBAL_ATTRIBUTE_CATEGORY = X_GLOBAL_ATTRIBUTE_CATEGORY)
           OR ((recinfo.GLOBAL_ATTRIBUTE_CATEGORY is null) AND (X_GLOBAL_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.INVENTORIAL = X_INVENTORIAL)
           OR ((recinfo.INVENTORIAL is null) AND (X_INVENTORIAL is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_CATEGORY_ID in NUMBER,
  X_SUMMARY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OWNED_LEASED in VARCHAR2,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CAPITALIZE_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PROPERTY_TYPE_CODE in VARCHAR2,
  X_PROPERTY_1245_1250_CODE in VARCHAR2,
  X_DATE_INEFFECTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2 DEFAULT NULL,
  X_PRODUCTION_CAPACITY in NUMBER DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_GLOBAL_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_INVENTORIAL in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
begin
  update FA_CATEGORIES_B set
    SUMMARY_FLAG = X_SUMMARY_FLAG,
    ENABLED_FLAG = X_ENABLED_FLAG,
    OWNED_LEASED = X_OWNED_LEASED,
    CATEGORY_TYPE = X_CATEGORY_TYPE,
    CAPITALIZE_FLAG = X_CAPITALIZE_FLAG,
    SEGMENT1 = X_SEGMENT1,
    SEGMENT2 = X_SEGMENT2,
    SEGMENT3 = X_SEGMENT3,
    SEGMENT4 = X_SEGMENT4,
    SEGMENT5 = X_SEGMENT5,
    SEGMENT6 = X_SEGMENT6,
    SEGMENT7 = X_SEGMENT7,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    PROPERTY_TYPE_CODE = X_PROPERTY_TYPE_CODE,
    PROPERTY_1245_1250_CODE = X_PROPERTY_1245_1250_CODE,
    DATE_INEFFECTIVE = X_DATE_INEFFECTIVE,
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
    ATTRIBUTE_CATEGORY_CODE = X_ATTRIBUTE_CATEGORY_CODE,
    PRODUCTION_CAPACITY = X_PRODUCTION_CAPACITY,
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
    INVENTORIAL = X_INVENTORIAL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CATEGORY_ID = X_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FA_CATEGORIES_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CATEGORY_ID = X_CATEGORY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CATEGORY_ID in NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
begin
  delete from FA_CATEGORIES_TL
  where CATEGORY_ID = X_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FA_CATEGORIES_B
  where CATEGORY_ID = X_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FA_CATEGORIES_TL T
  where not exists
    (select NULL
    from FA_CATEGORIES_B B
    where B.CATEGORY_ID = T.CATEGORY_ID
    );

  update FA_CATEGORIES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from FA_CATEGORIES_TL B
    where B.CATEGORY_ID = T.CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CATEGORY_ID,
      SUBT.LANGUAGE
    from FA_CATEGORIES_TL SUBB, FA_CATEGORIES_TL SUBT
    where SUBB.CATEGORY_ID = SUBT.CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FA_CATEGORIES_TL (
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    CATEGORY_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.CATEGORY_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FA_CATEGORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FA_CATEGORIES_TL T
    where T.CATEGORY_ID = B.CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_CATEGORY_ID in NUMBER,
  X_SUMMARY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OWNED_LEASED in VARCHAR2,
  X_PRODUCTION_CAPACITY in NUMBER DEFAULT NULL,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CAPITALIZE_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PROPERTY_TYPE_CODE in VARCHAR2,
  X_PROPERTY_1245_1250_CODE in VARCHAR2,
  X_DATE_INEFFECTIVE in DATE,
  X_INVENTORIAL in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

  h_record_exists number(15);

  user_id         number;
  row_id          varchar2(64);

begin

  -- No SEED data.  All custom.
  user_id := 0;

  select count(*)
  into   h_record_exists
  from   fa_categories_b
  where  category_id = X_Category_Id;

  if (h_record_exists > 0) then
     fa_categories_pkg.update_row (
	X_Category_ID			=> X_Category_Id,
	X_Summary_Flag			=> X_Summary_Flag,
	X_Enabled_Flag			=> X_Enabled_Flag,
	X_Owned_Leased			=> X_Owned_Leased,
	X_Category_Type			=> X_Category_Type,
	X_Capitalize_Flag		=> X_Capitalize_Flag,
	X_Description			=> X_Description,
	X_Segment1			=> X_Segment1,
	X_Segment2			=> X_Segment2,
	X_Segment3			=> X_Segment3,
	X_Segment4			=> X_Segment4,
	X_Segment5			=> X_Segment5,
	X_Segment6			=> X_Segment6,
	X_Segment7			=> X_Segment7,
	X_Start_Date_Active		=> X_Start_Date_Active,
	X_End_Date_Active		=> X_End_Date_Active,
	X_Property_Type_Code		=> X_Property_Type_Code,
	X_Property_1245_1250_Code	=> X_Property_1245_1250_Code,
	X_Date_Ineffective		=> X_Date_Ineffective,
	X_Attribute1			=> X_Attribute1,
	X_Attribute2			=> X_Attribute2,
	X_Attribute3			=> X_Attribute3,
	X_Attribute4			=> X_Attribute4,
	X_Attribute5			=> X_Attribute5,
	X_Attribute6			=> X_Attribute6,
	X_Attribute7			=> X_Attribute7,
	X_Attribute8			=> X_Attribute8,
	X_Attribute9			=> X_Attribute9,
	X_Attribute10			=> X_Attribute10,
	X_Attribute11			=> X_Attribute11,
	X_Attribute12			=> X_Attribute12,
	X_Attribute13			=> X_Attribute13,
	X_Attribute14			=> X_Attribute14,
	X_Attribute15			=> X_Attribute15,
	X_Attribute_Category_Code	=> X_Attribute_Category_Code,
	X_Production_Capacity		=> X_Production_Capacity,
	X_Global_Attribute1		=> X_gf_Attribute1,
	X_Global_Attribute2		=> X_gf_Attribute2,
	X_Global_Attribute3		=> X_gf_Attribute3,
	X_Global_Attribute4		=> X_gf_Attribute4,
	X_Global_Attribute5		=> X_gf_Attribute5,
	X_Global_Attribute6		=> X_gf_Attribute6,
	X_Global_Attribute7		=> X_gf_Attribute7,
	X_Global_Attribute8		=> X_gf_Attribute8,
	X_Global_Attribute9		=> X_gf_Attribute9,
	X_Global_Attribute10		=> X_gf_Attribute10,
	X_Global_Attribute11		=> X_gf_Attribute11,
	X_Global_Attribute12		=> X_gf_Attribute12,
	X_Global_Attribute13		=> X_gf_Attribute13,
	X_Global_Attribute14		=> X_gf_Attribute14,
	X_Global_Attribute15		=> X_gf_Attribute15,
	X_Global_Attribute16		=> X_gf_Attribute16,
	X_Global_Attribute17		=> X_gf_Attribute17,
	X_Global_Attribute18		=> X_gf_Attribute18,
	X_Global_Attribute19		=> X_gf_Attribute19,
	X_Global_Attribute20		=> X_gf_Attribute20,
	X_Inventorial			=> X_Inventorial,
	X_Last_Update_Date		=> sysdate,
	X_Last_Updated_By		=> user_id,
	X_Last_Update_Login		=> 0
     , p_log_level_rec => p_log_level_rec);
  else
     fa_categories_pkg.insert_row (
	X_Rowid				=> row_id,
	X_Category_Id			=> X_Category_Id,
	X_Summary_Flag			=> X_Summary_Flag,
	X_Enabled_Flag			=> X_Enabled_Flag,
	X_Owned_Leased			=> X_Owned_Leased,
	X_Category_Type			=> X_Category_Type,
	X_Capitalize_Flag		=> X_Capitalize_Flag,
	X_Description			=> X_Description,
	X_Segment1			=> X_Segment1,
	X_Segment2			=> X_Segment2,
	X_Segment3			=> X_Segment3,
	X_Segment4			=> X_Segment4,
	X_Segment5			=> X_Segment5,
	X_Segment6			=> X_Segment6,
	X_Segment7			=> X_Segment7,
	X_Start_Date_Active		=> X_Start_Date_Active,
	X_End_Date_Active		=> X_End_Date_Active,
	X_Property_Type_Code		=> X_Property_Type_Code,
	X_Property_1245_1250_Code	=> X_Property_1245_1250_Code,
	X_Date_Ineffective		=> X_Date_Ineffective,
	X_Attribute1			=> X_Attribute1,
	X_Attribute2			=> X_Attribute2,
	X_Attribute3			=> X_Attribute3,
	X_Attribute4			=> X_Attribute4,
	X_Attribute5			=> X_Attribute5,
	X_Attribute6			=> X_Attribute6,
	X_Attribute7			=> X_Attribute7,
	X_Attribute8			=> X_Attribute8,
	X_Attribute9			=> X_Attribute9,
	X_Attribute10			=> X_Attribute10,
	X_Attribute11			=> X_Attribute11,
	X_Attribute12			=> X_Attribute12,
	X_Attribute13			=> X_Attribute13,
	X_Attribute14			=> X_Attribute14,
	X_Attribute15			=> X_Attribute15,
	X_Production_Capacity		=> X_Production_Capacity,
	X_Global_Attribute1		=> X_gf_Attribute1,
	X_Global_Attribute2		=> X_gf_Attribute2,
	X_Global_Attribute3		=> X_gf_Attribute3,
	X_Global_Attribute4		=> X_gf_Attribute4,
	X_Global_Attribute5		=> X_gf_Attribute5,
	X_Global_Attribute6		=> X_gf_Attribute6,
	X_Global_Attribute7		=> X_gf_Attribute7,
	X_Global_Attribute8		=> X_gf_Attribute8,
	X_Global_Attribute9		=> X_gf_Attribute9,
	X_Global_Attribute10		=> X_gf_Attribute10,
	X_Global_Attribute11		=> X_gf_Attribute11,
	X_Global_Attribute12		=> X_gf_Attribute12,
	X_Global_Attribute13		=> X_gf_Attribute13,
	X_Global_Attribute14		=> X_gf_Attribute14,
	X_Global_Attribute15		=> X_gf_Attribute15,
	X_Global_Attribute16		=> X_gf_Attribute16,
	X_Global_Attribute17		=> X_gf_Attribute17,
	X_Global_Attribute18		=> X_gf_Attribute18,
	X_Global_Attribute19		=> X_gf_Attribute19,
	X_Global_Attribute20		=> X_gf_Attribute20,
	X_Inventorial			=> X_Inventorial,
	X_Creation_Date			=> sysdate,
	X_Created_By			=> user_id,
	X_Last_Update_Date		=> sysdate,
	X_Last_Updated_By		=> user_id,
	X_Last_Update_Login		=> 0
     , p_log_level_rec => p_log_level_rec);
  end if;

exception
  when others then
       FA_STANDARD_PKG.RAISE_ERROR(
                      CALLED_FN => 'fa_categories_pkg.load_row',
                      CALLING_FN => 'upload fa_additions', p_log_level_rec => p_log_level_rec);

end LOAD_ROW;

/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
  X_CUSTOM_MODE in VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_SUMMARY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_OWNED_LEASED in VARCHAR2,
  X_PRODUCTION_CAPACITY in NUMBER DEFAULT NULL,
  X_CATEGORY_TYPE in VARCHAR2,
  X_CAPITALIZE_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PROPERTY_TYPE_CODE in VARCHAR2,
  X_PROPERTY_1245_1250_CODE in VARCHAR2,
  X_DATE_INEFFECTIVE in DATE,
  X_INVENTORIAL in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  X_GF_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is

  h_record_exists number(15);

  user_id         number;
  row_id          varchar2(64);

  db_last_updated_by   number;
  db_last_update_date  date;

begin

  user_id := fnd_load_util.owner_id (X_Owner);

  select count(*)
  into   h_record_exists
  from   fa_categories_b
  where  category_id = X_Category_Id;

  if (h_record_exists > 0) then

     select last_updated_by, last_update_date
     into   db_last_updated_by, db_last_update_date
     from   fa_categories_b
     where  category_id = X_Category_Id;

     if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                   db_last_updated_by, db_last_update_date,
                                   X_CUSTOM_MODE)) then

        fa_categories_pkg.update_row (
           X_Category_ID		=> X_Category_Id,
           X_Summary_Flag		=> X_Summary_Flag,
           X_Enabled_Flag		=> X_Enabled_Flag,
           X_Owned_Leased		=> X_Owned_Leased,
           X_Category_Type		=> X_Category_Type,
           X_Capitalize_Flag		=> X_Capitalize_Flag,
           X_Description		=> X_Description,
           X_Segment1			=> X_Segment1,
           X_Segment2			=> X_Segment2,
           X_Segment3			=> X_Segment3,
           X_Segment4			=> X_Segment4,
           X_Segment5			=> X_Segment5,
           X_Segment6			=> X_Segment6,
           X_Segment7			=> X_Segment7,
           X_Start_Date_Active		=> X_Start_Date_Active,
           X_End_Date_Active		=> X_End_Date_Active,
           X_Property_Type_Code		=> X_Property_Type_Code,
           X_Property_1245_1250_Code	=> X_Property_1245_1250_Code,
           X_Date_Ineffective		=> X_Date_Ineffective,
           X_Attribute1			=> X_Attribute1,
           X_Attribute2			=> X_Attribute2,
           X_Attribute3			=> X_Attribute3,
           X_Attribute4			=> X_Attribute4,
           X_Attribute5			=> X_Attribute5,
           X_Attribute6			=> X_Attribute6,
           X_Attribute7			=> X_Attribute7,
           X_Attribute8			=> X_Attribute8,
           X_Attribute9			=> X_Attribute9,
           X_Attribute10		=> X_Attribute10,
           X_Attribute11		=> X_Attribute11,
           X_Attribute12		=> X_Attribute12,
           X_Attribute13		=> X_Attribute13,
           X_Attribute14		=> X_Attribute14,
           X_Attribute15		=> X_Attribute15,
           X_Attribute_Category_Code	=> X_Attribute_Category_Code,
           X_Production_Capacity	=> X_Production_Capacity,
           X_Global_Attribute1		=> X_gf_Attribute1,
           X_Global_Attribute2		=> X_gf_Attribute2,
           X_Global_Attribute3		=> X_gf_Attribute3,
           X_Global_Attribute4		=> X_gf_Attribute4,
           X_Global_Attribute5		=> X_gf_Attribute5,
           X_Global_Attribute6		=> X_gf_Attribute6,
           X_Global_Attribute7		=> X_gf_Attribute7,
           X_Global_Attribute8		=> X_gf_Attribute8,
           X_Global_Attribute9		=> X_gf_Attribute9,
           X_Global_Attribute10		=> X_gf_Attribute10,
           X_Global_Attribute11		=> X_gf_Attribute11,
           X_Global_Attribute12		=> X_gf_Attribute12,
           X_Global_Attribute13		=> X_gf_Attribute13,
           X_Global_Attribute14		=> X_gf_Attribute14,
           X_Global_Attribute15		=> X_gf_Attribute15,
           X_Global_Attribute16		=> X_gf_Attribute16,
           X_Global_Attribute17		=> X_gf_Attribute17,
           X_Global_Attribute18		=> X_gf_Attribute18,
           X_Global_Attribute19		=> X_gf_Attribute19,
           X_Global_Attribute20		=> X_gf_Attribute20,
           X_Inventorial		=> X_Inventorial,
           X_Last_Update_Date		=> sysdate,
           X_Last_Updated_By		=> user_id,
           X_Last_Update_Login		=> 0
           ,p_log_level_rec => p_log_level_rec);
     end if;
  else
     fa_categories_pkg.insert_row (
	X_Rowid				=> row_id,
	X_Category_Id			=> X_Category_Id,
	X_Summary_Flag			=> X_Summary_Flag,
	X_Enabled_Flag			=> X_Enabled_Flag,
	X_Owned_Leased			=> X_Owned_Leased,
	X_Category_Type			=> X_Category_Type,
	X_Capitalize_Flag		=> X_Capitalize_Flag,
	X_Description			=> X_Description,
	X_Segment1			=> X_Segment1,
	X_Segment2			=> X_Segment2,
	X_Segment3			=> X_Segment3,
	X_Segment4			=> X_Segment4,
	X_Segment5			=> X_Segment5,
	X_Segment6			=> X_Segment6,
	X_Segment7			=> X_Segment7,
	X_Start_Date_Active		=> X_Start_Date_Active,
	X_End_Date_Active		=> X_End_Date_Active,
	X_Property_Type_Code		=> X_Property_Type_Code,
	X_Property_1245_1250_Code	=> X_Property_1245_1250_Code,
	X_Date_Ineffective		=> X_Date_Ineffective,
	X_Attribute1			=> X_Attribute1,
	X_Attribute2			=> X_Attribute2,
	X_Attribute3			=> X_Attribute3,
	X_Attribute4			=> X_Attribute4,
	X_Attribute5			=> X_Attribute5,
	X_Attribute6			=> X_Attribute6,
	X_Attribute7			=> X_Attribute7,
	X_Attribute8			=> X_Attribute8,
	X_Attribute9			=> X_Attribute9,
	X_Attribute10			=> X_Attribute10,
	X_Attribute11			=> X_Attribute11,
	X_Attribute12			=> X_Attribute12,
	X_Attribute13			=> X_Attribute13,
	X_Attribute14			=> X_Attribute14,
	X_Attribute15			=> X_Attribute15,
	X_Production_Capacity		=> X_Production_Capacity,
	X_Global_Attribute1		=> X_gf_Attribute1,
	X_Global_Attribute2		=> X_gf_Attribute2,
	X_Global_Attribute3		=> X_gf_Attribute3,
	X_Global_Attribute4		=> X_gf_Attribute4,
	X_Global_Attribute5		=> X_gf_Attribute5,
	X_Global_Attribute6		=> X_gf_Attribute6,
	X_Global_Attribute7		=> X_gf_Attribute7,
	X_Global_Attribute8		=> X_gf_Attribute8,
	X_Global_Attribute9		=> X_gf_Attribute9,
	X_Global_Attribute10		=> X_gf_Attribute10,
	X_Global_Attribute11		=> X_gf_Attribute11,
	X_Global_Attribute12		=> X_gf_Attribute12,
	X_Global_Attribute13		=> X_gf_Attribute13,
	X_Global_Attribute14		=> X_gf_Attribute14,
	X_Global_Attribute15		=> X_gf_Attribute15,
	X_Global_Attribute16		=> X_gf_Attribute16,
	X_Global_Attribute17		=> X_gf_Attribute17,
	X_Global_Attribute18		=> X_gf_Attribute18,
	X_Global_Attribute19		=> X_gf_Attribute19,
	X_Global_Attribute20		=> X_gf_Attribute20,
	X_Inventorial			=> X_Inventorial,
	X_Creation_Date			=> sysdate,
	X_Created_By			=> user_id,
	X_Last_Update_Date		=> sysdate,
	X_Last_Updated_By		=> user_id,
	X_Last_Update_Login		=> 0
	,p_log_level_rec => p_log_level_rec);
  end if;

exception
  when others then
       FA_STANDARD_PKG.RAISE_ERROR(
                      CALLED_FN => 'fa_categories_pkg.load_row',
                      CALLING_FN => 'upload fa_additions'
                      ,p_log_level_rec => p_log_level_rec);

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_CATEGORY_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
begin

  update FA_CATEGORIES_TL set
     DESCRIPTION = nvl(X_Description, DESCRIPTION),
     LAST_UPDATE_DATE = sysdate,
     LAST_UPDATED_BY = 0,
     LAST_UPDATE_LOGIN = 0,
     SOURCE_LANG = userenv('LANG')
  where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  and   CATEGORY_ID = X_Category_ID;

exception
  when no_data_found then null;

  when others then
       FA_STANDARD_PKG.RAISE_ERROR(
                      CALLED_FN => 'fa_categories_pkg.translate_row',
                      CALLING_FN => 'upload fa_categories', p_log_level_rec => p_log_level_rec);

end TRANSLATE_ROW;
/*Bug 8355119 overloading function for release specific signatures*/
procedure TRANSLATE_ROW (
  X_CUSTOM_MODE in VARCHAR2,
  X_CATEGORY_ID in NUMBER,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_DESCRIPTION in VARCHAR2,
  p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is

  user_id              number;

  db_last_updated_by   number;
  db_last_update_date  date;

begin

   select last_updated_by, last_update_date
   into   db_last_updated_by, db_last_update_date
   from   fa_categories_tl
   where  category_id = X_Category_Id
   and    userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   user_id := fnd_load_util.owner_id (X_Owner);

   if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                 db_last_updated_by, db_last_update_date,
                                 X_CUSTOM_MODE)) then

      update FA_CATEGORIES_TL set
         DESCRIPTION = nvl(X_Description, DESCRIPTION),
         LAST_UPDATE_DATE = sysdate,
         LAST_UPDATED_BY = 0,
         LAST_UPDATE_LOGIN = 0,
         SOURCE_LANG = userenv('LANG')
      where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
      and   CATEGORY_ID = X_Category_ID;

   end if;

exception
  when no_data_found then null;

  when others then
       FA_STANDARD_PKG.RAISE_ERROR(
                      CALLED_FN => 'fa_categories_pkg.translate_row',
                      CALLING_FN => 'upload fa_categories'
                      ,p_log_level_rec => p_log_level_rec);

end TRANSLATE_ROW;

/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
             x_upload_mode              IN VARCHAR2,
             x_custom_mode              IN VARCHAR2,
             x_category_id              IN NUMBER,
             x_owner                    IN VARCHAR2,
             x_last_update_date         IN DATE,
             x_summary_flag             IN VARCHAR2,
             x_enabled_flag             IN VARCHAR2,
             x_owned_leased             IN VARCHAR2,
             x_production_capacity      IN NUMBER,
             x_category_type            IN VARCHAR2,
             x_capitalize_flag          IN VARCHAR2,
             x_description              IN VARCHAR2,
             x_segment1                 IN VARCHAR2,
             x_segment2                 IN VARCHAR2,
             x_segment3                 IN VARCHAR2,
             x_segment4                 IN VARCHAR2,
             x_segment5                 IN VARCHAR2,
             x_segment6                 IN VARCHAR2,
             x_segment7                 IN VARCHAR2,
             x_start_date_active        IN DATE,
             x_end_date_active          IN DATE,
             x_property_type_code       IN VARCHAR2,
             x_property_1245_1250_code  IN VARCHAR2,
             x_date_ineffective         IN DATE,
             x_inventorial              IN VARCHAR2,
             x_attribute1               IN VARCHAR2,
             x_attribute2               IN VARCHAR2,
             x_attribute3               IN VARCHAR2,
             x_attribute4               IN VARCHAR2,
             x_attribute5               IN VARCHAR2,
             x_attribute6               IN VARCHAR2,
             x_attribute7               IN VARCHAR2,
             x_attribute8               IN VARCHAR2,
             x_attribute9               IN VARCHAR2,
             x_attribute10              IN VARCHAR2,
             x_attribute11              IN VARCHAR2,
             x_attribute12              IN VARCHAR2,
             x_attribute13              IN VARCHAR2,
             x_attribute14              IN VARCHAR2,
             x_attribute15              IN VARCHAR2,
             x_attribute_category_code  IN VARCHAR2,
             x_gf_attribute1            IN VARCHAR2,
             x_gf_attribute2            IN VARCHAR2,
             x_gf_attribute3            IN VARCHAR2,
             x_gf_attribute4            IN VARCHAR2,
             x_gf_attribute5            IN VARCHAR2,
             x_gf_attribute6            IN VARCHAR2,
             x_gf_attribute7            IN VARCHAR2,
             x_gf_attribute8            IN VARCHAR2,
             x_gf_attribute9            IN VARCHAR2,
             x_gf_attribute10           IN VARCHAR2,
             x_gf_attribute11           IN VARCHAR2,
             x_gf_attribute12           IN VARCHAR2,
             x_gf_attribute13           IN VARCHAR2,
             x_gf_attribute14           IN VARCHAR2,
             x_gf_attribute15           IN VARCHAR2,
             x_gf_attribute16           IN VARCHAR2,
             x_gf_attribute17           IN VARCHAR2,
             x_gf_attribute18           IN VARCHAR2,
             x_gf_attribute19           IN VARCHAR2,
             x_gf_attribute20           IN VARCHAR2,
             x_gf_attribute_category    IN VARCHAR2) IS

BEGIN

        if (x_upload_mode = 'NLS') then
           fa_categories_pkg.TRANSLATE_ROW (
             x_custom_mode              => x_custom_mode,
             x_category_id              => x_category_id,
             x_owner                    => x_owner,
             x_last_update_date         => x_last_update_date,
             x_description              => x_description);
        else
           fa_categories_pkg.LOAD_ROW (
             x_custom_mode              => x_custom_mode,
             x_category_id              => x_category_id,
             x_owner                    => x_owner,
             x_last_update_date         => x_last_update_date,
             x_summary_flag             => x_summary_flag,
             x_enabled_flag             => x_enabled_flag,
             x_owned_leased             => x_owned_leased,
             x_production_capacity      => x_production_capacity,
             x_category_type            => x_category_type,
             x_capitalize_flag          => x_capitalize_flag,
             x_description              => x_description,
             x_segment1                 => x_segment1,
             x_segment2                 => x_segment2,
             x_segment3                 => x_segment3,
             x_segment4                 => x_segment4,
             x_segment5                 => x_segment5,
             x_segment6                 => x_segment6,
             x_segment7                 => x_segment7,
             x_start_date_active        => x_start_date_active,
             x_end_date_active          => x_end_date_active,
             x_property_type_code       => x_property_type_code,
             x_property_1245_1250_code  => x_property_1245_1250_code,
             x_date_ineffective         => x_date_ineffective,
             x_inventorial              => x_inventorial,
             x_attribute1               => x_attribute1,
             x_attribute2               => x_attribute2,
             x_attribute3               => x_attribute3,
             x_attribute4               => x_attribute4,
             x_attribute5               => x_attribute5,
             x_attribute6               => x_attribute6,
             x_attribute7               => x_attribute7,
             x_attribute8               => x_attribute8,
             x_attribute9               => x_attribute9,
             x_attribute10              => x_attribute10,
             x_attribute11              => x_attribute11,
             x_attribute12              => x_attribute12,
             x_attribute13              => x_attribute13,
             x_attribute14              => x_attribute14,
             x_attribute15              => x_attribute15,
             x_attribute_category_code  => x_attribute_category_code,
             x_gf_attribute1            => x_gf_attribute1,
             x_gf_attribute2            => x_gf_attribute2,
             x_gf_attribute3            => x_gf_attribute3,
             x_gf_attribute4            => x_gf_attribute4,
             x_gf_attribute5            => x_gf_attribute5,
             x_gf_attribute6            => x_gf_attribute6,
             x_gf_attribute7            => x_gf_attribute7,
             x_gf_attribute8            => x_gf_attribute8,
             x_gf_attribute9            => x_gf_attribute9,
             x_gf_attribute10           => x_gf_attribute10,
             x_gf_attribute11           => x_gf_attribute11,
             x_gf_attribute12           => x_gf_attribute12,
             x_gf_attribute13           => x_gf_attribute13,
             x_gf_attribute14           => x_gf_attribute14,
             x_gf_attribute15           => x_gf_attribute15,
             x_gf_attribute16           => x_gf_attribute16,
             x_gf_attribute17           => x_gf_attribute17,
             x_gf_attribute18           => x_gf_attribute18,
             x_gf_attribute19           => x_gf_attribute19,
             x_gf_attribute20           => x_gf_attribute20,
             x_gf_attribute_category    => x_gf_attribute_category);
        end if;

END LOAD_SEED_ROW;

end FA_CATEGORIES_PKG;

/
