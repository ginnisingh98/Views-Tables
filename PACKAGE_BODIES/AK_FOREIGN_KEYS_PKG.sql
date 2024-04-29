--------------------------------------------------------
--  DDL for Package Body AK_FOREIGN_KEYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_FOREIGN_KEYS_PKG" as
/* $Header: AKDOBFKB.pls 120.3 2006/01/25 15:57:40 tshort ship $ */
--*****************************************************************************
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FOREIGN_KEY_NAME in VARCHAR2,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_UNIQUE_KEY_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FROM_TO_NAME in VARCHAR2,
  X_FROM_TO_DESCRIPTION in VARCHAR2,
  X_TO_FROM_NAME in VARCHAR2,
  X_TO_FROM_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
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
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor C is select ROWID from AK_FOREIGN_KEYS
    where FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME;
begin
  insert into AK_FOREIGN_KEYS (
    FOREIGN_KEY_NAME,
    DATABASE_OBJECT_NAME,
    UNIQUE_KEY_NAME,
    APPLICATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
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
    ATTRIBUTE15
  ) values (
    X_FOREIGN_KEY_NAME,
    X_DATABASE_OBJECT_NAME,
    X_UNIQUE_KEY_NAME,
    X_APPLICATION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
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
    X_ATTRIBUTE15
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  insert into AK_FOREIGN_KEYS_TL (
    FOREIGN_KEY_NAME,
    LANGUAGE,
    FROM_TO_NAME,
    FROM_TO_DESCRIPTION,
    TO_FROM_NAME,
    TO_FROM_DESCRIPTION,
    SOURCE_LANG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) select
    X_FOREIGN_KEY_NAME,
    L.LANGUAGE_CODE,
    X_FROM_TO_NAME,
    X_FROM_TO_DESCRIPTION,
    X_TO_FROM_NAME,
    X_TO_FROM_DESCRIPTION,
    userenv('LANG'),
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AK_FOREIGN_KEYS_TL T
    where T.FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end INSERT_ROW;
--*****************************************************************************
procedure INSERT_AFKC_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FOREIGN_KEY_NAME in VARCHAR2,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_FOREIGN_KEY_SEQUENCE in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
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
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor C is select ROWID from AK_FOREIGN_KEY_COLUMNS
    where FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME;
begin
  insert into AK_FOREIGN_KEY_COLUMNS (
    FOREIGN_KEY_NAME,
    ATTRIBUTE_APPLICATION_ID,
    ATTRIBUTE_CODE,
    FOREIGN_KEY_SEQUENCE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
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
    ATTRIBUTE15
  ) values (
    X_FOREIGN_KEY_NAME,
    X_ATTRIBUTE_APPLICATION_ID,
    X_ATTRIBUTE_CODE,
    X_FOREIGN_KEY_SEQUENCE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
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
    X_ATTRIBUTE15
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_AFKC_ROW;
--*****************************************************************************
procedure LOCK_ROW (
  X_FOREIGN_KEY_NAME in VARCHAR2,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_UNIQUE_KEY_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FROM_TO_NAME in VARCHAR2,
  X_FROM_TO_DESCRIPTION in VARCHAR2,
  X_TO_FROM_NAME in VARCHAR2,
  X_TO_FROM_DESCRIPTION in VARCHAR2,
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
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor c is select
      DATABASE_OBJECT_NAME,
      UNIQUE_KEY_NAME,
      APPLICATION_ID,
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
      ATTRIBUTE15
    from AK_FOREIGN_KEYS
    where FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME
    for update of FOREIGN_KEY_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      FROM_TO_NAME,
      FROM_TO_DESCRIPTION,
      TO_FROM_NAME,
      TO_FROM_DESCRIPTION
    from AK_FOREIGN_KEYS_TL
    where FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME
    and LANGUAGE = userenv('LANG')
    for update of FOREIGN_KEY_NAME nowait;
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
      if ( ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null)
               AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null)
               AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null)
               AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null)
               AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null)
               AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null)
               AND (X_ATTRIBUTE15 is null)))
      AND (recinfo.DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME)
      AND (recinfo.UNIQUE_KEY_NAME = X_UNIQUE_KEY_NAME)
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null)
               AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null)
               AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null)
               AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null)
               AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null)
               AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null)
               AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null)
               AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null)
               AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null)
               AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null)
               AND (X_ATTRIBUTE9 is null)))
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

      if ( ((tlinfo.FROM_TO_NAME = X_FROM_TO_NAME)
           OR ((tlinfo.FROM_TO_NAME is null)
               AND (X_FROM_TO_NAME is null)))
      AND ((tlinfo.FROM_TO_DESCRIPTION = X_FROM_TO_DESCRIPTION)
           OR ((tlinfo.FROM_TO_DESCRIPTION is null)
               AND (X_FROM_TO_DESCRIPTION is null)))
      AND ((tlinfo.TO_FROM_NAME = X_TO_FROM_NAME)
           OR ((tlinfo.TO_FROM_NAME is null)
               AND (X_TO_FROM_NAME is null)))
      AND ((tlinfo.TO_FROM_DESCRIPTION = X_TO_FROM_DESCRIPTION)
           OR ((tlinfo.TO_FROM_DESCRIPTION is null)
               AND (X_TO_FROM_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
--*****************************************************************************
procedure LOCK_AFKC_ROW (
  X_FOREIGN_KEY_NAME in VARCHAR2,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_FOREIGN_KEY_SEQUENCE in NUMBER,
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
  X_ATTRIBUTE15 in VARCHAR2
) is
  cursor c is select
      FOREIGN_KEY_NAME,
      ATTRIBUTE_APPLICATION_ID,
      ATTRIBUTE_CODE,
      FOREIGN_KEY_SEQUENCE,
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
      ATTRIBUTE15
    from AK_FOREIGN_KEY_COLUMNS
    where FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME
      and FOREIGN_KEY_SEQUENCE = X_FOREIGN_KEY_SEQUENCE
    for update of FOREIGN_KEY_NAME nowait;
  recinfo c%rowtype;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
      if ((recinfo.ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID)
      AND (recinfo.ATTRIBUTE_CODE = X_ATTRIBUTE_CODE)
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null)
               AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null)
               AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null)
               AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null)
               AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null)
               AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null)
               AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null)
               AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null)
               AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null)
               AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null)
               AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null)
               AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null)
               AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null)
               AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null)
               AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null)
               AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null)
               AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
end LOCK_AFKC_ROW;
--*****************************************************************************
procedure UPDATE_ROW (
  X_FOREIGN_KEY_NAME in VARCHAR2,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_UNIQUE_KEY_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_FROM_TO_NAME in VARCHAR2,
  X_FROM_TO_DESCRIPTION in VARCHAR2,
  X_TO_FROM_NAME in VARCHAR2,
  X_TO_FROM_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
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
  X_ATTRIBUTE15 in VARCHAR2
) is
begin
    update AK_FOREIGN_KEYS set
      FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME,
      DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME,
      UNIQUE_KEY_NAME = X_UNIQUE_KEY_NAME,
      APPLICATION_ID = X_APPLICATION_ID,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
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
      ATTRIBUTE15 = X_ATTRIBUTE15
    where FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AK_FOREIGN_KEYS_TL set
    FROM_TO_NAME = X_FROM_TO_NAME,
    FROM_TO_DESCRIPTION = X_FROM_TO_DESCRIPTION,
    TO_FROM_NAME = X_TO_FROM_NAME,
    TO_FROM_DESCRIPTION = X_TO_FROM_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
--*****************************************************************************
procedure UPDATE_AFKC_ROW (
  X_FOREIGN_KEY_NAME in VARCHAR2,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_FOREIGN_KEY_SEQUENCE in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
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
  X_ATTRIBUTE15 in VARCHAR2
) is
begin
    update AK_FOREIGN_KEY_COLUMNS set
      ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID,
      ATTRIBUTE_CODE = X_ATTRIBUTE_CODE,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
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
      ATTRIBUTE15 = X_ATTRIBUTE15
    where FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME
      and FOREIGN_KEY_SEQUENCE = X_FOREIGN_KEY_SEQUENCE;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_AFKC_ROW;
--*****************************************************************************
procedure DELETE_ROW (
  X_FOREIGN_KEY_NAME in VARCHAR2
) is
begin
  delete from AK_FOREIGN_KEYS
  where FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AK_FOREIGN_KEYS_TL
  where FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
--*****************************************************************************
procedure DELETE_AFKC_ROW (
  X_FOREIGN_KEY_NAME in VARCHAR2,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_FOREIGN_KEY_SEQUENCE in NUMBER
) is
begin
  if X_FOREIGN_KEY_SEQUENCE is null then
    delete from AK_FOREIGN_KEY_COLUMNS
      where FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME
        and ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
        and ATTRIBUTE_CODE = X_ATTRIBUTE_CODE;
  else
    delete from AK_FOREIGN_KEY_COLUMNS
      where FOREIGN_KEY_NAME = X_FOREIGN_KEY_NAME
        and FOREIGN_KEY_SEQUENCE = X_FOREIGN_KEY_SEQUENCE;
  end if;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_AFKC_ROW;
--*****************************************************************************
procedure ADD_LANGUAGE
is
begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

  delete from AK_FOREIGN_KEYS_TL T
  where not exists
    (select NULL
    from AK_FOREIGN_KEYS B
    where B.FOREIGN_KEY_NAME = T.FOREIGN_KEY_NAME
    );

  update AK_FOREIGN_KEYS_TL T set (
      FROM_TO_NAME,
      FROM_TO_DESCRIPTION,
      TO_FROM_NAME,
      TO_FROM_DESCRIPTION
    ) = (select
      B.FROM_TO_NAME,
      B.FROM_TO_DESCRIPTION,
      B.TO_FROM_NAME,
      B.TO_FROM_DESCRIPTION
    from AK_FOREIGN_KEYS_TL B
    where B.FOREIGN_KEY_NAME = T.FOREIGN_KEY_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FOREIGN_KEY_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.FOREIGN_KEY_NAME,
      SUBT.LANGUAGE
    from AK_FOREIGN_KEYS_TL SUBB, AK_FOREIGN_KEYS_TL SUBT
    where SUBB.FOREIGN_KEY_NAME = SUBT.FOREIGN_KEY_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.FROM_TO_NAME <> SUBT.FROM_TO_NAME
      or (SUBB.FROM_TO_NAME is null and SUBT.FROM_TO_NAME is not null)
      or (SUBB.FROM_TO_NAME is not null and SUBT.FROM_TO_NAME is null)
      or SUBB.FROM_TO_DESCRIPTION <> SUBT.FROM_TO_DESCRIPTION
      or (SUBB.FROM_TO_DESCRIPTION is null and SUBT.FROM_TO_DESCRIPTION is not null)
      or (SUBB.FROM_TO_DESCRIPTION is not null and SUBT.FROM_TO_DESCRIPTION is null)
      or SUBB.TO_FROM_NAME <> SUBT.TO_FROM_NAME
      or (SUBB.TO_FROM_NAME is null and SUBT.TO_FROM_NAME is not null)
      or (SUBB.TO_FROM_NAME is not null and SUBT.TO_FROM_NAME is null)
      or SUBB.TO_FROM_DESCRIPTION <> SUBT.TO_FROM_DESCRIPTION
      or (SUBB.TO_FROM_DESCRIPTION is null and SUBT.TO_FROM_DESCRIPTION is not null)
      or (SUBB.TO_FROM_DESCRIPTION is not null and SUBT.TO_FROM_DESCRIPTION is null)
  ));

*/

  insert /*+ append parallel(tt) */ into AK_FOREIGN_KEYS_TL tt (
    FOREIGN_KEY_NAME,
    FROM_TO_NAME,
    FROM_TO_DESCRIPTION,
    TO_FROM_NAME,
    TO_FROM_DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ parallel(v) parallel(t) use_nl(t)  */ v.* from
(select /*+ no_merge ordered parallel(b) */
    B.FOREIGN_KEY_NAME,
    B.FROM_TO_NAME,
    B.FROM_TO_DESCRIPTION,
    B.TO_FROM_NAME,
    B.TO_FROM_DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AK_FOREIGN_KEYS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
) v, AK_FOREIGN_KEYS_TL T
    where T.FOREIGN_KEY_NAME(+) = v.FOREIGN_KEY_NAME
    and T.LANGUAGE(+) = v.LANGUAGE_CODE
and T.FOREIGN_KEY_NAME is NULL;

end ADD_LANGUAGE;
--*****************************************************************************
end AK_FOREIGN_KEYS_PKG;

/
