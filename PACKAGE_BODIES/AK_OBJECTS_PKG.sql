--------------------------------------------------------
--  DDL for Package Body AK_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_OBJECTS_PKG" as
/* $Header: AKDOBJTB.pls 120.3 2006/01/25 15:58:21 tshort ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PRIMARY_KEY_NAME IN VARCHAR2,
  X_DEFAULTING_API_PKG IN VARCHAR2,
  X_DEFAULTING_API_PROC IN VARCHAR2,
  X_VALIDATION_API_PKG IN VARCHAR2,
  X_VALIDATION_API_PROC IN VARCHAR2,
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
  cursor C is select ROWID from AK_OBJECTS
    where DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME;
begin
  insert into AK_OBJECTS (
    DATABASE_OBJECT_NAME,
    APPLICATION_ID,
    PRIMARY_KEY_NAME,
    DEFAULTING_API_PKG,
    DEFAULTING_API_PROC,
    VALIDATION_API_PKG,
    VALIDATION_API_PROC,
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
    X_DATABASE_OBJECT_NAME,
    X_APPLICATION_ID,
    X_PRIMARY_KEY_NAME,
    X_DEFAULTING_API_PKG,
    X_DEFAULTING_API_PROC,
    X_VALIDATION_API_PKG,
    X_VALIDATION_API_PROC,
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

  insert into AK_OBJECTS_TL (
    DATABASE_OBJECT_NAME,
    LANGUAGE,
    NAME,
    DESCRIPTION,
    SOURCE_LANG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) select
    X_DATABASE_OBJECT_NAME,
    L.LANGUAGE_CODE,
    X_NAME,
    X_DESCRIPTION,
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
    from AK_OBJECTS_TL T
    where T.DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end INSERT_ROW;

procedure LOCK_ROW (
  X_DATABASE_OBJECT_NAME in VARCHAR2,
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
  X_APPLICATION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PRIMARY_KEY_NAME IN VARCHAR2,
  X_DEFAULTING_API_PKG IN VARCHAR2,
  X_DEFAULTING_API_PROC IN VARCHAR2,
  X_VALIDATION_API_PKG IN VARCHAR2,
  X_VALIDATION_API_PROC IN VARCHAR2
) is
  cursor c is select
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
      APPLICATION_ID,
      PRIMARY_KEY_NAME,
      DEFAULTING_API_PKG,
      DEFAULTING_API_PROC,
      VALIDATION_API_PKG,
      VALIDATION_API_PROC
    from AK_OBJECTS
    where DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME
    for update of DATABASE_OBJECT_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION
    from AK_OBJECTS_TL
    where DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME
    and LANGUAGE = userenv('LANG')
    for update of DATABASE_OBJECT_NAME nowait;
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
      if ( ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
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
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND ((recinfo.PRIMARY_KEY_NAME = X_PRIMARY_KEY_NAME)
           OR ((recinfo.PRIMARY_KEY_NAME is null)
               AND (X_PRIMARY_KEY_NAME is null)))
      AND ((recinfo.DEFAULTING_API_PKG = X_DEFAULTING_API_PKG)
           OR ((recinfo.DEFAULTING_API_PKG is null)
	       AND (X_DEFAULTING_API_PKG is null)))
      AND ((recinfo.DEFAULTING_API_PROC = X_DEFAULTING_API_PROC)
           OR ((recinfo.DEFAULTING_API_PROC is null)
	       AND (X_DEFAULTING_API_PROC is null)))
      AND ((recinfo.VALIDATION_API_PKG = X_VALIDATION_API_PKG)
           OR ((recinfo.VALIDATION_API_PKG is null)
	       AND (X_VALIDATION_API_PKG is null)))
      AND ((recinfo.VALIDATION_API_PROC = X_VALIDATION_API_PROC)
           OR ((recinfo.VALIDATION_API_PROC is null)
	       AND (X_VALIDATION_API_PROC is null)))
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

  if ( (tlinfo.NAME = X_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PRIMARY_KEY_NAME IN VARCHAR2,
  X_DEFAULTING_API_PKG IN VARCHAR2,
  X_DEFAULTING_API_PROC IN VARCHAR2,
  X_VALIDATION_API_PKG IN VARCHAR2,
  X_VALIDATION_API_PROC IN VARCHAR2,
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
  update AK_OBJECTS set
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
    APPLICATION_ID = X_APPLICATION_ID,
    PRIMARY_KEY_NAME = X_PRIMARY_KEY_NAME,
    DEFAULTING_API_PKG = X_DEFAULTING_API_PKG,
    DEFAULTING_API_PROC = X_DEFAULTING_API_PROC,
    VALIDATION_API_PKG = X_VALIDATION_API_PKG,
    VALIDATION_API_PROC = X_VALIDATION_API_PROC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AK_OBJECTS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DATABASE_OBJECT_NAME in VARCHAR2
) is
begin
  delete from AK_OBJECTS
  where DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AK_OBJECTS_TL
  where DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME;
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
  delete from AK_OBJECTS_TL T
  where not exists
    (select NULL
    from AK_OBJECTS B
    where B.DATABASE_OBJECT_NAME = T.DATABASE_OBJECT_NAME
    );

  update AK_OBJECTS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AK_OBJECTS_TL B
    where B.DATABASE_OBJECT_NAME = T.DATABASE_OBJECT_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DATABASE_OBJECT_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.DATABASE_OBJECT_NAME,
      SUBT.LANGUAGE
    from AK_OBJECTS_TL SUBB, AK_OBJECTS_TL SUBT
    where SUBB.DATABASE_OBJECT_NAME = SUBT.DATABASE_OBJECT_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
*/

  insert /*+ append parallel(tt) */ into AK_OBJECTS_TL tt (
    DATABASE_OBJECT_NAME,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ parallel(v) parallel(t) use_nl(t)  */ v.* from
(select /*+ no_merge ordered parallel(b) */
    B.DATABASE_OBJECT_NAME,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AK_OBJECTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
) v, AK_OBJECTS_TL T
    where T.DATABASE_OBJECT_NAME(+) = v.DATABASE_OBJECT_NAME
    and T.LANGUAGE(+) = v.LANGUAGE_CODE
and T.DATABASE_OBJECT_NAME is NULL;

end ADD_LANGUAGE;

end AK_OBJECTS_PKG;

/
