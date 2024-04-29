--------------------------------------------------------
--  DDL for Package Body FND_FLEX_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_VALUES_PKG" as
/* $Header: AFFFVLSB.pls 120.1.12010000.5 2010/08/20 09:29:51 tebarnes ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FLEX_VALUE_ID in NUMBER,
  X_ATTRIBUTE_SORT_ORDER in NUMBER,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_FLEX_VALUE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SUMMARY_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PARENT_FLEX_VALUE_LOW in VARCHAR2,
  X_PARENT_FLEX_VALUE_HIGH in VARCHAR2,
  X_STRUCTURED_HIERARCHY_LEVEL in NUMBER,
  X_HIERARCHY_LEVEL in VARCHAR2,
  X_COMPILED_VALUE_ATTRIBUTES in VARCHAR2,
  X_VALUE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_ATTRIBUTE31 in VARCHAR2,
  X_ATTRIBUTE32 in VARCHAR2,
  X_ATTRIBUTE33 in VARCHAR2,
  X_ATTRIBUTE34 in VARCHAR2,
  X_ATTRIBUTE35 in VARCHAR2,
  X_ATTRIBUTE36 in VARCHAR2,
  X_ATTRIBUTE37 in VARCHAR2,
  X_ATTRIBUTE38 in VARCHAR2,
  X_ATTRIBUTE39 in VARCHAR2,
  X_ATTRIBUTE40 in VARCHAR2,
  X_ATTRIBUTE41 in VARCHAR2,
  X_ATTRIBUTE42 in VARCHAR2,
  X_ATTRIBUTE43 in VARCHAR2,
  X_ATTRIBUTE44 in VARCHAR2,
  X_ATTRIBUTE45 in VARCHAR2,
  X_ATTRIBUTE46 in VARCHAR2,
  X_ATTRIBUTE47 in VARCHAR2,
  X_ATTRIBUTE48 in VARCHAR2,
  X_ATTRIBUTE49 in VARCHAR2,
  X_ATTRIBUTE50 in VARCHAR2,
  X_FLEX_VALUE_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_FLEX_VALUES
    where FLEX_VALUE_ID = X_FLEX_VALUE_ID
    ;
begin
  insert into FND_FLEX_VALUES (
    ATTRIBUTE_SORT_ORDER,
    FLEX_VALUE_SET_ID,
    FLEX_VALUE_ID,
    FLEX_VALUE,
    ENABLED_FLAG,
    SUMMARY_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    PARENT_FLEX_VALUE_LOW,
    PARENT_FLEX_VALUE_HIGH,
    STRUCTURED_HIERARCHY_LEVEL,
    HIERARCHY_LEVEL,
    COMPILED_VALUE_ATTRIBUTES,
    VALUE_CATEGORY,
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
    ATTRIBUTE21,
    ATTRIBUTE22,
    ATTRIBUTE23,
    ATTRIBUTE24,
    ATTRIBUTE25,
    ATTRIBUTE26,
    ATTRIBUTE27,
    ATTRIBUTE28,
    ATTRIBUTE29,
    ATTRIBUTE30,
    ATTRIBUTE31,
    ATTRIBUTE32,
    ATTRIBUTE33,
    ATTRIBUTE34,
    ATTRIBUTE35,
    ATTRIBUTE36,
    ATTRIBUTE37,
    ATTRIBUTE38,
    ATTRIBUTE39,
    ATTRIBUTE40,
    ATTRIBUTE41,
    ATTRIBUTE42,
    ATTRIBUTE43,
    ATTRIBUTE44,
    ATTRIBUTE45,
    ATTRIBUTE46,
    ATTRIBUTE47,
    ATTRIBUTE48,
    ATTRIBUTE49,
    ATTRIBUTE50,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTRIBUTE_SORT_ORDER,
    X_FLEX_VALUE_SET_ID,
    X_FLEX_VALUE_ID,
    X_FLEX_VALUE,
    X_ENABLED_FLAG,
    X_SUMMARY_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_PARENT_FLEX_VALUE_LOW,
    X_PARENT_FLEX_VALUE_HIGH,
    X_STRUCTURED_HIERARCHY_LEVEL,
    X_HIERARCHY_LEVEL,
    X_COMPILED_VALUE_ATTRIBUTES,
    X_VALUE_CATEGORY,
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
    X_ATTRIBUTE21,
    X_ATTRIBUTE22,
    X_ATTRIBUTE23,
    X_ATTRIBUTE24,
    X_ATTRIBUTE25,
    X_ATTRIBUTE26,
    X_ATTRIBUTE27,
    X_ATTRIBUTE28,
    X_ATTRIBUTE29,
    X_ATTRIBUTE30,
    X_ATTRIBUTE31,
    X_ATTRIBUTE32,
    X_ATTRIBUTE33,
    X_ATTRIBUTE34,
    X_ATTRIBUTE35,
    X_ATTRIBUTE36,
    X_ATTRIBUTE37,
    X_ATTRIBUTE38,
    X_ATTRIBUTE39,
    X_ATTRIBUTE40,
    X_ATTRIBUTE41,
    X_ATTRIBUTE42,
    X_ATTRIBUTE43,
    X_ATTRIBUTE44,
    X_ATTRIBUTE45,
    X_ATTRIBUTE46,
    X_ATTRIBUTE47,
    X_ATTRIBUTE48,
    X_ATTRIBUTE49,
    X_ATTRIBUTE50,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_FLEX_VALUES_TL (
    FLEX_VALUE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    FLEX_VALUE_MEANING,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_FLEX_VALUE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    X_FLEX_VALUE_MEANING,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_FLEX_VALUES_TL T
    where T.FLEX_VALUE_ID = X_FLEX_VALUE_ID
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
  X_FLEX_VALUE_ID in NUMBER,
  X_ATTRIBUTE_SORT_ORDER in NUMBER,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_FLEX_VALUE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SUMMARY_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PARENT_FLEX_VALUE_LOW in VARCHAR2,
  X_PARENT_FLEX_VALUE_HIGH in VARCHAR2,
  X_STRUCTURED_HIERARCHY_LEVEL in NUMBER,
  X_HIERARCHY_LEVEL in VARCHAR2,
  X_COMPILED_VALUE_ATTRIBUTES in VARCHAR2,
  X_VALUE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_ATTRIBUTE31 in VARCHAR2,
  X_ATTRIBUTE32 in VARCHAR2,
  X_ATTRIBUTE33 in VARCHAR2,
  X_ATTRIBUTE34 in VARCHAR2,
  X_ATTRIBUTE35 in VARCHAR2,
  X_ATTRIBUTE36 in VARCHAR2,
  X_ATTRIBUTE37 in VARCHAR2,
  X_ATTRIBUTE38 in VARCHAR2,
  X_ATTRIBUTE39 in VARCHAR2,
  X_ATTRIBUTE40 in VARCHAR2,
  X_ATTRIBUTE41 in VARCHAR2,
  X_ATTRIBUTE42 in VARCHAR2,
  X_ATTRIBUTE43 in VARCHAR2,
  X_ATTRIBUTE44 in VARCHAR2,
  X_ATTRIBUTE45 in VARCHAR2,
  X_ATTRIBUTE46 in VARCHAR2,
  X_ATTRIBUTE47 in VARCHAR2,
  X_ATTRIBUTE48 in VARCHAR2,
  X_ATTRIBUTE49 in VARCHAR2,
  X_ATTRIBUTE50 in VARCHAR2,
  X_FLEX_VALUE_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ATTRIBUTE_SORT_ORDER,
      FLEX_VALUE_SET_ID,
      FLEX_VALUE,
      ENABLED_FLAG,
      SUMMARY_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      PARENT_FLEX_VALUE_LOW,
      PARENT_FLEX_VALUE_HIGH,
      STRUCTURED_HIERARCHY_LEVEL,
      HIERARCHY_LEVEL,
      COMPILED_VALUE_ATTRIBUTES,
      VALUE_CATEGORY,
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
      ATTRIBUTE21,
      ATTRIBUTE22,
      ATTRIBUTE23,
      ATTRIBUTE24,
      ATTRIBUTE25,
      ATTRIBUTE26,
      ATTRIBUTE27,
      ATTRIBUTE28,
      ATTRIBUTE29,
      ATTRIBUTE30,
      ATTRIBUTE31,
      ATTRIBUTE32,
      ATTRIBUTE33,
      ATTRIBUTE34,
      ATTRIBUTE35,
      ATTRIBUTE36,
      ATTRIBUTE37,
      ATTRIBUTE38,
      ATTRIBUTE39,
      ATTRIBUTE40,
      ATTRIBUTE41,
      ATTRIBUTE42,
      ATTRIBUTE43,
      ATTRIBUTE44,
      ATTRIBUTE45,
      ATTRIBUTE46,
      ATTRIBUTE47,
      ATTRIBUTE48,
      ATTRIBUTE49,
      ATTRIBUTE50
    from FND_FLEX_VALUES
    where FLEX_VALUE_ID = X_FLEX_VALUE_ID
    for update of FLEX_VALUE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      FLEX_VALUE_MEANING,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_FLEX_VALUES_TL
    where FLEX_VALUE_ID = X_FLEX_VALUE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FLEX_VALUE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE_SORT_ORDER = X_ATTRIBUTE_SORT_ORDER)
           OR ((recinfo.ATTRIBUTE_SORT_ORDER is null) AND (X_ATTRIBUTE_SORT_ORDER is null)))
      AND (recinfo.FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID)
      AND (recinfo.FLEX_VALUE = X_FLEX_VALUE)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.SUMMARY_FLAG = X_SUMMARY_FLAG)
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
      AND ((recinfo.PARENT_FLEX_VALUE_LOW = X_PARENT_FLEX_VALUE_LOW)
           OR ((recinfo.PARENT_FLEX_VALUE_LOW is null) AND (X_PARENT_FLEX_VALUE_LOW is null)))
      AND ((recinfo.PARENT_FLEX_VALUE_HIGH = X_PARENT_FLEX_VALUE_HIGH)
           OR ((recinfo.PARENT_FLEX_VALUE_HIGH is null) AND (X_PARENT_FLEX_VALUE_HIGH is null)))
      AND ((recinfo.STRUCTURED_HIERARCHY_LEVEL = X_STRUCTURED_HIERARCHY_LEVEL)
           OR ((recinfo.STRUCTURED_HIERARCHY_LEVEL is null) AND (X_STRUCTURED_HIERARCHY_LEVEL is null)))
      AND ((recinfo.HIERARCHY_LEVEL = X_HIERARCHY_LEVEL)
           OR ((recinfo.HIERARCHY_LEVEL is null) AND (X_HIERARCHY_LEVEL is null)))
      AND ((recinfo.COMPILED_VALUE_ATTRIBUTES = X_COMPILED_VALUE_ATTRIBUTES)
           OR ((recinfo.COMPILED_VALUE_ATTRIBUTES is null) AND (X_COMPILED_VALUE_ATTRIBUTES is null)))
      AND ((recinfo.VALUE_CATEGORY = X_VALUE_CATEGORY)
           OR ((recinfo.VALUE_CATEGORY is null) AND (X_VALUE_CATEGORY is null)))
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
      AND ((recinfo.ATTRIBUTE21 = X_ATTRIBUTE21)
           OR ((recinfo.ATTRIBUTE21 is null) AND (X_ATTRIBUTE21 is null)))
      AND ((recinfo.ATTRIBUTE22 = X_ATTRIBUTE22)
           OR ((recinfo.ATTRIBUTE22 is null) AND (X_ATTRIBUTE22 is null)))
      AND ((recinfo.ATTRIBUTE23 = X_ATTRIBUTE23)
           OR ((recinfo.ATTRIBUTE23 is null) AND (X_ATTRIBUTE23 is null)))
      AND ((recinfo.ATTRIBUTE24 = X_ATTRIBUTE24)
           OR ((recinfo.ATTRIBUTE24 is null) AND (X_ATTRIBUTE24 is null)))
      AND ((recinfo.ATTRIBUTE25 = X_ATTRIBUTE25)
           OR ((recinfo.ATTRIBUTE25 is null) AND (X_ATTRIBUTE25 is null)))
      AND ((recinfo.ATTRIBUTE26 = X_ATTRIBUTE26)
           OR ((recinfo.ATTRIBUTE26 is null) AND (X_ATTRIBUTE26 is null)))
      AND ((recinfo.ATTRIBUTE27 = X_ATTRIBUTE27)
           OR ((recinfo.ATTRIBUTE27 is null) AND (X_ATTRIBUTE27 is null)))
      AND ((recinfo.ATTRIBUTE28 = X_ATTRIBUTE28)
           OR ((recinfo.ATTRIBUTE28 is null) AND (X_ATTRIBUTE28 is null)))
      AND ((recinfo.ATTRIBUTE29 = X_ATTRIBUTE29)
           OR ((recinfo.ATTRIBUTE29 is null) AND (X_ATTRIBUTE29 is null)))
      AND ((recinfo.ATTRIBUTE30 = X_ATTRIBUTE30)
           OR ((recinfo.ATTRIBUTE30 is null) AND (X_ATTRIBUTE30 is null)))
      AND ((recinfo.ATTRIBUTE31 = X_ATTRIBUTE31)
           OR ((recinfo.ATTRIBUTE31 is null) AND (X_ATTRIBUTE31 is null)))
      AND ((recinfo.ATTRIBUTE32 = X_ATTRIBUTE32)
           OR ((recinfo.ATTRIBUTE32 is null) AND (X_ATTRIBUTE32 is null)))
      AND ((recinfo.ATTRIBUTE33 = X_ATTRIBUTE33)
           OR ((recinfo.ATTRIBUTE33 is null) AND (X_ATTRIBUTE33 is null)))
      AND ((recinfo.ATTRIBUTE34 = X_ATTRIBUTE34)
           OR ((recinfo.ATTRIBUTE34 is null) AND (X_ATTRIBUTE34 is null)))
      AND ((recinfo.ATTRIBUTE35 = X_ATTRIBUTE35)
           OR ((recinfo.ATTRIBUTE35 is null) AND (X_ATTRIBUTE35 is null)))
      AND ((recinfo.ATTRIBUTE36 = X_ATTRIBUTE36)
           OR ((recinfo.ATTRIBUTE36 is null) AND (X_ATTRIBUTE36 is null)))
      AND ((recinfo.ATTRIBUTE37 = X_ATTRIBUTE37)
           OR ((recinfo.ATTRIBUTE37 is null) AND (X_ATTRIBUTE37 is null)))
      AND ((recinfo.ATTRIBUTE38 = X_ATTRIBUTE38)
           OR ((recinfo.ATTRIBUTE38 is null) AND (X_ATTRIBUTE38 is null)))
      AND ((recinfo.ATTRIBUTE39 = X_ATTRIBUTE39)
           OR ((recinfo.ATTRIBUTE39 is null) AND (X_ATTRIBUTE39 is null)))
      AND ((recinfo.ATTRIBUTE40 = X_ATTRIBUTE40)
           OR ((recinfo.ATTRIBUTE40 is null) AND (X_ATTRIBUTE40 is null)))
      AND ((recinfo.ATTRIBUTE41 = X_ATTRIBUTE41)
           OR ((recinfo.ATTRIBUTE41 is null) AND (X_ATTRIBUTE41 is null)))
      AND ((recinfo.ATTRIBUTE42 = X_ATTRIBUTE42)
           OR ((recinfo.ATTRIBUTE42 is null) AND (X_ATTRIBUTE42 is null)))
      AND ((recinfo.ATTRIBUTE43 = X_ATTRIBUTE43)
           OR ((recinfo.ATTRIBUTE43 is null) AND (X_ATTRIBUTE43 is null)))
      AND ((recinfo.ATTRIBUTE44 = X_ATTRIBUTE44)
           OR ((recinfo.ATTRIBUTE44 is null) AND (X_ATTRIBUTE44 is null)))
      AND ((recinfo.ATTRIBUTE45 = X_ATTRIBUTE45)
           OR ((recinfo.ATTRIBUTE45 is null) AND (X_ATTRIBUTE45 is null)))
      AND ((recinfo.ATTRIBUTE46 = X_ATTRIBUTE46)
           OR ((recinfo.ATTRIBUTE46 is null) AND (X_ATTRIBUTE46 is null)))
      AND ((recinfo.ATTRIBUTE47 = X_ATTRIBUTE47)
           OR ((recinfo.ATTRIBUTE47 is null) AND (X_ATTRIBUTE47 is null)))
      AND ((recinfo.ATTRIBUTE48 = X_ATTRIBUTE48)
           OR ((recinfo.ATTRIBUTE48 is null) AND (X_ATTRIBUTE48 is null)))
      AND ((recinfo.ATTRIBUTE49 = X_ATTRIBUTE49)
           OR ((recinfo.ATTRIBUTE49 is null) AND (X_ATTRIBUTE49 is null)))
      AND ((recinfo.ATTRIBUTE50 = X_ATTRIBUTE50)
           OR ((recinfo.ATTRIBUTE50 is null) AND (X_ATTRIBUTE50 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.FLEX_VALUE_MEANING = X_FLEX_VALUE_MEANING)
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
  X_FLEX_VALUE_ID in NUMBER,
  X_ATTRIBUTE_SORT_ORDER in NUMBER,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_FLEX_VALUE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SUMMARY_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_PARENT_FLEX_VALUE_LOW in VARCHAR2,
  X_PARENT_FLEX_VALUE_HIGH in VARCHAR2,
  X_STRUCTURED_HIERARCHY_LEVEL in NUMBER,
  X_HIERARCHY_LEVEL in VARCHAR2,
  X_COMPILED_VALUE_ATTRIBUTES in VARCHAR2,
  X_VALUE_CATEGORY in VARCHAR2,
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
  X_ATTRIBUTE21 in VARCHAR2,
  X_ATTRIBUTE22 in VARCHAR2,
  X_ATTRIBUTE23 in VARCHAR2,
  X_ATTRIBUTE24 in VARCHAR2,
  X_ATTRIBUTE25 in VARCHAR2,
  X_ATTRIBUTE26 in VARCHAR2,
  X_ATTRIBUTE27 in VARCHAR2,
  X_ATTRIBUTE28 in VARCHAR2,
  X_ATTRIBUTE29 in VARCHAR2,
  X_ATTRIBUTE30 in VARCHAR2,
  X_ATTRIBUTE31 in VARCHAR2,
  X_ATTRIBUTE32 in VARCHAR2,
  X_ATTRIBUTE33 in VARCHAR2,
  X_ATTRIBUTE34 in VARCHAR2,
  X_ATTRIBUTE35 in VARCHAR2,
  X_ATTRIBUTE36 in VARCHAR2,
  X_ATTRIBUTE37 in VARCHAR2,
  X_ATTRIBUTE38 in VARCHAR2,
  X_ATTRIBUTE39 in VARCHAR2,
  X_ATTRIBUTE40 in VARCHAR2,
  X_ATTRIBUTE41 in VARCHAR2,
  X_ATTRIBUTE42 in VARCHAR2,
  X_ATTRIBUTE43 in VARCHAR2,
  X_ATTRIBUTE44 in VARCHAR2,
  X_ATTRIBUTE45 in VARCHAR2,
  X_ATTRIBUTE46 in VARCHAR2,
  X_ATTRIBUTE47 in VARCHAR2,
  X_ATTRIBUTE48 in VARCHAR2,
  X_ATTRIBUTE49 in VARCHAR2,
  X_ATTRIBUTE50 in VARCHAR2,
  X_FLEX_VALUE_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_FLEX_VALUES set
    ATTRIBUTE_SORT_ORDER = X_ATTRIBUTE_SORT_ORDER,
    FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID,
    FLEX_VALUE = X_FLEX_VALUE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    SUMMARY_FLAG = X_SUMMARY_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    PARENT_FLEX_VALUE_LOW = X_PARENT_FLEX_VALUE_LOW,
    PARENT_FLEX_VALUE_HIGH = X_PARENT_FLEX_VALUE_HIGH,
    STRUCTURED_HIERARCHY_LEVEL = X_STRUCTURED_HIERARCHY_LEVEL,
    HIERARCHY_LEVEL = X_HIERARCHY_LEVEL,
    COMPILED_VALUE_ATTRIBUTES = X_COMPILED_VALUE_ATTRIBUTES,
    VALUE_CATEGORY = X_VALUE_CATEGORY,
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
    ATTRIBUTE21 = X_ATTRIBUTE21,
    ATTRIBUTE22 = X_ATTRIBUTE22,
    ATTRIBUTE23 = X_ATTRIBUTE23,
    ATTRIBUTE24 = X_ATTRIBUTE24,
    ATTRIBUTE25 = X_ATTRIBUTE25,
    ATTRIBUTE26 = X_ATTRIBUTE26,
    ATTRIBUTE27 = X_ATTRIBUTE27,
    ATTRIBUTE28 = X_ATTRIBUTE28,
    ATTRIBUTE29 = X_ATTRIBUTE29,
    ATTRIBUTE30 = X_ATTRIBUTE30,
    ATTRIBUTE31 = X_ATTRIBUTE31,
    ATTRIBUTE32 = X_ATTRIBUTE32,
    ATTRIBUTE33 = X_ATTRIBUTE33,
    ATTRIBUTE34 = X_ATTRIBUTE34,
    ATTRIBUTE35 = X_ATTRIBUTE35,
    ATTRIBUTE36 = X_ATTRIBUTE36,
    ATTRIBUTE37 = X_ATTRIBUTE37,
    ATTRIBUTE38 = X_ATTRIBUTE38,
    ATTRIBUTE39 = X_ATTRIBUTE39,
    ATTRIBUTE40 = X_ATTRIBUTE40,
    ATTRIBUTE41 = X_ATTRIBUTE41,
    ATTRIBUTE42 = X_ATTRIBUTE42,
    ATTRIBUTE43 = X_ATTRIBUTE43,
    ATTRIBUTE44 = X_ATTRIBUTE44,
    ATTRIBUTE45 = X_ATTRIBUTE45,
    ATTRIBUTE46 = X_ATTRIBUTE46,
    ATTRIBUTE47 = X_ATTRIBUTE47,
    ATTRIBUTE48 = X_ATTRIBUTE48,
    ATTRIBUTE49 = X_ATTRIBUTE49,
    ATTRIBUTE50 = X_ATTRIBUTE50,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FLEX_VALUE_ID = X_FLEX_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  else
    update FND_FLEX_VALUES_TL set
      FLEX_VALUE_MEANING = X_FLEX_VALUE_MEANING,
      DESCRIPTION = X_DESCRIPTION,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      SOURCE_LANG = userenv('LANG')
    where FLEX_VALUE_ID = X_FLEX_VALUE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (sql%notfound) then
       insert into FND_FLEX_VALUES_TL (
         FLEX_VALUE_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         DESCRIPTION,
         FLEX_VALUE_MEANING,
         LANGUAGE,
         SOURCE_LANG
       ) select
         X_FLEX_VALUE_ID,
         X_LAST_UPDATE_DATE,
         X_LAST_UPDATED_BY,
         SYSDATE,
         X_LAST_UPDATE_LOGIN,
         X_LAST_UPDATE_LOGIN,
         X_DESCRIPTION,
         X_FLEX_VALUE_MEANING,
         L.LANGUAGE_CODE,
         userenv('LANG')
       from FND_LANGUAGES L
       where L.INSTALLED_FLAG in ('I', 'B')
       and not exists
         (select NULL
         from FND_FLEX_VALUES_TL T
         where T.FLEX_VALUE_ID = X_FLEX_VALUE_ID
         and T.LANGUAGE = L.LANGUAGE_CODE);
--      raise no_data_found;
    end if;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FLEX_VALUE_ID in NUMBER
) is
begin
  delete from FND_FLEX_VALUES_TL
  where FLEX_VALUE_ID = X_FLEX_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_FLEX_VALUES
  where FLEX_VALUE_ID = X_FLEX_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_BASE_LANGUAGE
 is
BEGIN
/*For fnd_flex_values records with no rows in the fnd_flex_values_tl table,
add the base language row so the ADD_LANGUAGE  code will add the additional
installed language rows */


INSERT INTO FND_FLEX_VALUES_TL
(FLEX_VALUE_ID,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_LOGIN,
FLEX_VALUE_MEANING,
LANGUAGE,
SOURCE_LANG
)
SELECT FLEX_VALUE_ID,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_LOGIN,
FLEX_VALUE,
(select language_code
from fnd_languages
where installed_flag='B'),
(select language_code
from fnd_languages
where installed_flag='B')
FROM FND_FLEX_VALUES
WHERE FLEX_VALUE_ID NOT IN
(SELECT FLEX_VALUE_ID
FROM FND_FLEX_VALUES_TL
WHERE FLEX_VALUE_ID IN
(SELECT FLEX_VALUE_ID
FROM FND_FLEX_VALUES));

end ADD_BASE_LANGUAGE;

procedure ADD_LANGUAGE
 is
 begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

   delete from FND_FLEX_VALUES_TL T
   where not exists
     (select NULL
     from FND_FLEX_VALUES B
     where B.FLEX_VALUE_ID = T.FLEX_VALUE_ID
     );

   update FND_FLEX_VALUES_TL T set (
       FLEX_VALUE_MEANING,
       DESCRIPTION
     ) = (select
       B.FLEX_VALUE_MEANING,
       B.DESCRIPTION
     from FND_FLEX_VALUES_TL B
     where B.FLEX_VALUE_ID = T.FLEX_VALUE_ID
     and B.LANGUAGE = T.SOURCE_LANG)
   where (
       T.FLEX_VALUE_ID,
       T.LANGUAGE
   ) in (select
       SUBT.FLEX_VALUE_ID,
       SUBT.LANGUAGE
     from FND_FLEX_VALUES_TL SUBB, FND_FLEX_VALUES_TL SUBT
     where SUBB.FLEX_VALUE_ID = SUBT.FLEX_VALUE_ID
     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
     and (SUBB.FLEX_VALUE_MEANING <> SUBT.FLEX_VALUE_MEANING
       or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
       or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
       or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
   ));
*/

/* Call ADD_BASE_LANGUAGE to insure all values in fnd_flex_values table
have an associated row in the fnd_flex_values_tl table for the base language
before doing the add_language code to insert missing installed language
rows in the fnd_flex_values_tl table */

   add_base_language;

   insert /*+ append */ into FND_FLEX_VALUES_TL (
     FLEX_VALUE_ID,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     DESCRIPTION,
     FLEX_VALUE_MEANING,
     LANGUAGE,
     SOURCE_LANG
   )
     select /*+ ordered swap_join_inputs(t) parallel(v) parallel(t) */ v.* from
     (select /*+ no_merge parallel(b) */
     B.FLEX_VALUE_ID,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATED_BY,
     B.CREATION_DATE,
     B.CREATED_BY,
     B.LAST_UPDATE_LOGIN,
     B.DESCRIPTION,
     B.FLEX_VALUE_MEANING,
     L.LANGUAGE_CODE,
     B.SOURCE_LANG
   from FND_LANGUAGES L, FND_FLEX_VALUES_TL B
   where DECODE(L.INSTALLED_FLAG, 'I', 1, 'B', 1, 0) = 1
   and B.LANGUAGE = userenv('LANG')
   ) v, FND_FLEX_VALUES_TL t
   where t.flex_value_id(+) = v.flex_value_id
   and t.language(+) = v.language_code
   and t.flex_value_id is NULL;

end ADD_LANGUAGE;

PROCEDURE load_row
  (x_flex_value_set_name          IN VARCHAR2,
   x_parent_flex_value_low        IN VARCHAR2,
   x_flex_value                   IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_enabled_flag                 IN VARCHAR2,
   x_summary_flag                 IN VARCHAR2,
   x_start_date_active            IN DATE,
   x_end_date_active              IN DATE,
   x_parent_flex_value_high       IN VARCHAR2,
   x_structured_hierarchy_level   IN NUMBER,
   x_hierarchy_level              IN VARCHAR2,
   x_compiled_value_attributes    IN VARCHAR2,
   x_value_category               IN VARCHAR2,
   x_attribute1                   IN VARCHAR2,
   x_attribute2                   IN VARCHAR2,
   x_attribute3                   IN VARCHAR2,
   x_attribute4                   IN VARCHAR2,
   x_attribute5                   IN VARCHAR2,
   x_attribute6                   IN VARCHAR2,
   x_attribute7                   IN VARCHAR2,
   x_attribute8                   IN VARCHAR2,
   x_attribute9                   IN VARCHAR2,
   x_attribute10                  IN VARCHAR2,
   x_attribute11                  IN VARCHAR2,
   x_attribute12                  IN VARCHAR2,
   x_attribute13                  IN VARCHAR2,
   x_attribute14                  IN VARCHAR2,
   x_attribute15                  IN VARCHAR2,
   x_attribute16                  IN VARCHAR2,
   x_attribute17                  IN VARCHAR2,
   x_attribute18                  IN VARCHAR2,
   x_attribute19                  IN VARCHAR2,
   x_attribute20                  IN VARCHAR2,
   x_attribute21                  IN VARCHAR2,
   x_attribute22                  IN VARCHAR2,
   x_attribute23                  IN VARCHAR2,
   x_attribute24                  IN VARCHAR2,
   x_attribute25                  IN VARCHAR2,
   x_attribute26                  IN VARCHAR2,
   x_attribute27                  IN VARCHAR2,
   x_attribute28                  IN VARCHAR2,
   x_attribute29                  IN VARCHAR2,
   x_attribute30                  IN VARCHAR2,
   x_attribute31                  IN VARCHAR2,
   x_attribute32                  IN VARCHAR2,
   x_attribute33                  IN VARCHAR2,
   x_attribute34                  IN VARCHAR2,
   x_attribute35                  IN VARCHAR2,
   x_attribute36                  IN VARCHAR2,
   x_attribute37                  IN VARCHAR2,
   x_attribute38                  IN VARCHAR2,
   x_attribute39                  IN VARCHAR2,
   x_attribute40                  IN VARCHAR2,
   x_attribute41                  IN VARCHAR2,
   x_attribute42                  IN VARCHAR2,
   x_attribute43                  IN VARCHAR2,
   x_attribute44                  IN VARCHAR2,
   x_attribute45                  IN VARCHAR2,
   x_attribute46                  IN VARCHAR2,
   x_attribute47                  IN VARCHAR2,
   x_attribute48                  IN VARCHAR2,
   x_attribute49                  IN VARCHAR2,
   x_attribute50                  IN VARCHAR2,
   x_attribute_sort_order         IN VARCHAR2,
   x_flex_value_meaning           IN VARCHAR2,
   x_description                  IN VARCHAR2)
  IS
     l_flex_value_set_id NUMBER := NULL;
     l_flex_value_id     NUMBER;
     l_validation_type   VARCHAR2(1);
     l_rowid             VARCHAR2(64);
BEGIN
   SELECT flex_value_set_id, validation_type
     INTO l_flex_value_set_id, l_validation_type
     FROM fnd_flex_value_sets
     WHERE flex_value_set_name = x_flex_value_set_name;

   BEGIN
      IF (l_validation_type in ('D', 'Y')) THEN
	 SELECT flex_value_id
	   INTO l_flex_value_id
	   FROM fnd_flex_values
	   WHERE flex_value_set_id = l_flex_value_set_id
	   AND flex_value = x_flex_value
	   AND (parent_flex_value_low = x_parent_flex_value_low OR
		(parent_flex_value_low IS NULL AND
		 x_parent_flex_value_low IS NULL));
       ELSE
	 SELECT flex_value_id
	   INTO l_flex_value_id
	   FROM fnd_flex_values
	   WHERE flex_value_set_id = l_flex_value_set_id
	   AND flex_value = x_flex_value;
      END IF;

      fnd_flex_values_pkg.update_row
	(X_FLEX_VALUE_ID                => l_flex_value_id,
         X_ATTRIBUTE_SORT_ORDER         => x_attribute_sort_order,
	 X_FLEX_VALUE_SET_ID            => l_flex_value_set_id,
	 X_FLEX_VALUE                   => x_flex_value,
	 X_ENABLED_FLAG                 => x_enabled_flag,
	 X_SUMMARY_FLAG                 => x_summary_flag,
	 X_START_DATE_ACTIVE            => x_start_date_active,
	 X_END_DATE_ACTIVE              => x_end_date_active,
	 X_PARENT_FLEX_VALUE_LOW        => x_parent_flex_value_low,
	 X_PARENT_FLEX_VALUE_HIGH       => x_parent_flex_value_high,
	 X_STRUCTURED_HIERARCHY_LEVEL   => x_structured_hierarchy_level,
	 X_HIERARCHY_LEVEL              => x_hierarchy_level,
	 X_COMPILED_VALUE_ATTRIBUTES    => x_compiled_value_attributes,
	 X_VALUE_CATEGORY               => x_value_category,
	 X_ATTRIBUTE1                   => x_attribute1,
	 X_ATTRIBUTE2                   => x_attribute2,
	 X_ATTRIBUTE3                   => x_attribute3,
	 X_ATTRIBUTE4                   => x_attribute4,
	 X_ATTRIBUTE5                   => x_attribute5,
	 X_ATTRIBUTE6                   => x_attribute6,
	 X_ATTRIBUTE7                   => x_attribute7,
	 X_ATTRIBUTE8                   => x_attribute8,
	 X_ATTRIBUTE9                   => x_attribute9,
	 X_ATTRIBUTE10                  => x_attribute10,
	 X_ATTRIBUTE11                  => x_attribute11,
	 X_ATTRIBUTE12                  => x_attribute12,
	 X_ATTRIBUTE13                  => x_attribute13,
	 X_ATTRIBUTE14                  => x_attribute14,
	 X_ATTRIBUTE15                  => x_attribute15,
	 X_ATTRIBUTE16                  => x_attribute16,
	 X_ATTRIBUTE17                  => x_attribute17,
	 X_ATTRIBUTE18                  => x_attribute18,
	 X_ATTRIBUTE19                  => x_attribute19,
	 X_ATTRIBUTE20                  => x_attribute20,
	 X_ATTRIBUTE21                  => x_attribute21,
	 X_ATTRIBUTE22                  => x_attribute22,
	 X_ATTRIBUTE23                  => x_attribute23,
	 X_ATTRIBUTE24                  => x_attribute24,
	 X_ATTRIBUTE25                  => x_attribute25,
	 X_ATTRIBUTE26                  => x_attribute26,
	 X_ATTRIBUTE27                  => x_attribute27,
	 X_ATTRIBUTE28                  => x_attribute28,
	 X_ATTRIBUTE29                  => x_attribute29,
	 X_ATTRIBUTE30                  => x_attribute30,
	 X_ATTRIBUTE31                  => x_attribute31,
	 X_ATTRIBUTE32                  => x_attribute32,
	 X_ATTRIBUTE33                  => x_attribute33,
	 X_ATTRIBUTE34                  => x_attribute34,
	 X_ATTRIBUTE35                  => x_attribute35,
	 X_ATTRIBUTE36                  => x_attribute36,
	 X_ATTRIBUTE37                  => x_attribute37,
	 X_ATTRIBUTE38                  => x_attribute38,
	 X_ATTRIBUTE39                  => x_attribute39,
	 X_ATTRIBUTE40                  => x_attribute40,
	 X_ATTRIBUTE41                  => x_attribute41,
	 X_ATTRIBUTE42                  => x_attribute42,
	 X_ATTRIBUTE43                  => x_attribute43,
	 X_ATTRIBUTE44                  => x_attribute44,
	 X_ATTRIBUTE45                  => x_attribute45,
	 X_ATTRIBUTE46                  => x_attribute46,
	 X_ATTRIBUTE47                  => x_attribute47,
	 X_ATTRIBUTE48                  => x_attribute48,
	 X_ATTRIBUTE49                  => x_attribute49,
	 X_ATTRIBUTE50                  => x_attribute50,
	 X_FLEX_VALUE_MEANING           => x_flex_value_meaning,
	 X_DESCRIPTION                  => x_description,
	 X_LAST_UPDATE_DATE             => x_who.last_update_date,
	 X_LAST_UPDATED_BY              => x_who.last_updated_by,
	 X_LAST_UPDATE_LOGIN            => x_who.last_update_login);
   EXCEPTION
      WHEN no_data_found THEN
	 SELECT fnd_flex_values_s.NEXTVAL
	   INTO l_flex_value_id
	   FROM dual;

	 fnd_flex_values_pkg.insert_row
	   (X_ROWID                        => l_rowid,
	    X_FLEX_VALUE_ID                => l_flex_value_id,
            X_ATTRIBUTE_SORT_ORDER         => x_attribute_sort_order,
	    X_FLEX_VALUE_SET_ID            => l_flex_value_set_id,
	    X_FLEX_VALUE                   => x_flex_value,
	    X_ENABLED_FLAG                 => x_enabled_flag,
	    X_SUMMARY_FLAG                 => x_summary_flag,
	    X_START_DATE_ACTIVE            => x_start_date_active,
	    X_END_DATE_ACTIVE              => x_end_date_active,
	    X_PARENT_FLEX_VALUE_LOW        => x_parent_flex_value_low,
	    X_PARENT_FLEX_VALUE_HIGH       => x_parent_flex_value_high,
	    X_STRUCTURED_HIERARCHY_LEVEL   => x_structured_hierarchy_level,
	    X_HIERARCHY_LEVEL              => x_hierarchy_level,
	    X_COMPILED_VALUE_ATTRIBUTES    => x_compiled_value_attributes,
	    X_VALUE_CATEGORY               => x_value_category,
	    X_ATTRIBUTE1                   => x_attribute1,
	    X_ATTRIBUTE2                   => x_attribute2,
	    X_ATTRIBUTE3                   => x_attribute3,
	    X_ATTRIBUTE4                   => x_attribute4,
	    X_ATTRIBUTE5                   => x_attribute5,
	    X_ATTRIBUTE6                   => x_attribute6,
	    X_ATTRIBUTE7                   => x_attribute7,
	    X_ATTRIBUTE8                   => x_attribute8,
	    X_ATTRIBUTE9                   => x_attribute9,
	    X_ATTRIBUTE10                  => x_attribute10,
	    X_ATTRIBUTE11                  => x_attribute11,
	    X_ATTRIBUTE12                  => x_attribute12,
	    X_ATTRIBUTE13                  => x_attribute13,
	    X_ATTRIBUTE14                  => x_attribute14,
	    X_ATTRIBUTE15                  => x_attribute15,
	    X_ATTRIBUTE16                  => x_attribute16,
	    X_ATTRIBUTE17                  => x_attribute17,
	    X_ATTRIBUTE18                  => x_attribute18,
	    X_ATTRIBUTE19                  => x_attribute19,
	    X_ATTRIBUTE20                  => x_attribute20,
	    X_ATTRIBUTE21                  => x_attribute21,
	    X_ATTRIBUTE22                  => x_attribute22,
	    X_ATTRIBUTE23                  => x_attribute23,
	    X_ATTRIBUTE24                  => x_attribute24,
	    X_ATTRIBUTE25                  => x_attribute25,
	    X_ATTRIBUTE26                  => x_attribute26,
	    X_ATTRIBUTE27                  => x_attribute27,
	    X_ATTRIBUTE28                  => x_attribute28,
	    X_ATTRIBUTE29                  => x_attribute29,
	    X_ATTRIBUTE30                  => x_attribute30,
	    X_ATTRIBUTE31                  => x_attribute31,
	    X_ATTRIBUTE32                  => x_attribute32,
	    X_ATTRIBUTE33                  => x_attribute33,
	    X_ATTRIBUTE34                  => x_attribute34,
	    X_ATTRIBUTE35                  => x_attribute35,
	    X_ATTRIBUTE36                  => x_attribute36,
	    X_ATTRIBUTE37                  => x_attribute37,
	    X_ATTRIBUTE38                  => x_attribute38,
	    X_ATTRIBUTE39                  => x_attribute39,
	    X_ATTRIBUTE40                  => x_attribute40,
	    X_ATTRIBUTE41                  => x_attribute41,
	    X_ATTRIBUTE42                  => x_attribute42,
	    X_ATTRIBUTE43                  => x_attribute43,
	    X_ATTRIBUTE44                  => x_attribute44,
	    X_ATTRIBUTE45                  => x_attribute45,
	    X_ATTRIBUTE46                  => x_attribute46,
	    X_ATTRIBUTE47                  => x_attribute47,
	    X_ATTRIBUTE48                  => x_attribute48,
	    X_ATTRIBUTE49                  => x_attribute49,
	    X_ATTRIBUTE50                  => x_attribute50,
  	    X_FLEX_VALUE_MEANING           => x_flex_value_meaning,
	    X_DESCRIPTION                  => x_description,
	    X_CREATION_DATE                => x_who.creation_date,
  	    X_CREATED_BY                   => x_who.created_by,
	    X_LAST_UPDATE_DATE             => x_who.last_update_date,
	    X_LAST_UPDATED_BY              => x_who.last_updated_by,
	    X_LAST_UPDATE_LOGIN            => x_who.last_update_login);
   END;
END load_row;

PROCEDURE translate_row
  (x_flex_value_set_name          IN VARCHAR2,
   x_parent_flex_value_low        IN VARCHAR2,
   x_flex_value                   IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_flex_value_meaning           IN VARCHAR2,
   x_description                  IN VARCHAR2)
  IS
     l_flex_value_set_id   NUMBER;
     l_validation_type     VARCHAR2(1);
BEGIN
   SELECT flex_value_set_id, validation_type
     INTO l_flex_value_set_id, l_validation_type
     FROM fnd_flex_value_sets
     WHERE flex_value_set_name = x_flex_value_set_name;

   UPDATE fnd_flex_values_tl SET
     flex_value_meaning = Decode(l_validation_type,
				 'X', Nvl(x_flex_value_meaning, flex_value_meaning),
				 'Y', Nvl(x_flex_value_meaning, flex_value_meaning),
				 flex_value_meaning),
     description        = Nvl(x_description, description),
     last_update_date   = x_who.last_update_date,
     last_updated_by    = x_who.last_updated_by,
     last_update_login  = x_who.last_update_login,
     source_lang        = userenv('LANG')
     WHERE (flex_value_id =
	    (SELECT flex_value_id
	     FROM fnd_flex_values
	     WHERE flex_value_set_id = l_flex_value_set_id
	     AND flex_value = x_flex_value
	     AND ((l_validation_type NOT IN ('D', 'Y')) OR
		  (l_validation_type IN ('D', 'Y') AND
		   ((parent_flex_value_low = x_parent_flex_value_low) OR
		    (parent_flex_value_low IS NULL AND
		     x_parent_flex_value_low IS NULL))))))
     AND userenv('LANG') in (language, source_lang);
END translate_row;

end FND_FLEX_VALUES_PKG;

/
