--------------------------------------------------------
--  DDL for Package Body XDO_DS_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_DS_DEFINITIONS_PKG" as
/* $Header: XDODSDFB.pls 120.1 2005/07/02 05:05:29 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_DATA_SOURCE_CODE in VARCHAR2,
  X_DATA_SOURCE_STATUS in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_DATA_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XDO_DS_DEFINITIONS_B
    where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
    and DATA_SOURCE_CODE = X_DATA_SOURCE_CODE
    ;
begin
  insert into XDO_DS_DEFINITIONS_B (
    APPLICATION_SHORT_NAME,
    DATA_SOURCE_CODE,
    DATA_SOURCE_STATUS,
    START_DATE,
    END_DATE,
    OBJECT_VERSION_NUMBER,
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
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_SHORT_NAME,
    X_DATA_SOURCE_CODE,
    X_DATA_SOURCE_STATUS,
    X_START_DATE,
    X_END_DATE,
    X_OBJECT_VERSION_NUMBER,
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
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XDO_DS_DEFINITIONS_TL (
    APPLICATION_SHORT_NAME,
    DATA_SOURCE_CODE,
    DATA_SOURCE_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_SHORT_NAME,
    X_DATA_SOURCE_CODE,
    X_DATA_SOURCE_NAME,
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
    from XDO_DS_DEFINITIONS_TL T
    where T.APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
    and T.DATA_SOURCE_CODE = X_DATA_SOURCE_CODE
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
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_DATA_SOURCE_CODE in VARCHAR2,
  X_DATA_SOURCE_STATUS in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_DATA_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      DATA_SOURCE_STATUS,
      START_DATE,
      END_DATE,
      OBJECT_VERSION_NUMBER,
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
    from XDO_DS_DEFINITIONS_B
    where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
    and DATA_SOURCE_CODE = X_DATA_SOURCE_CODE
    for update of APPLICATION_SHORT_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DATA_SOURCE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XDO_DS_DEFINITIONS_TL
    where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
    and DATA_SOURCE_CODE = X_DATA_SOURCE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPLICATION_SHORT_NAME nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.DATA_SOURCE_STATUS = X_DATA_SOURCE_STATUS)
      AND (recinfo.START_DATE = X_START_DATE)
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
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
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DATA_SOURCE_NAME = X_DATA_SOURCE_NAME)
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
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_DATA_SOURCE_CODE in VARCHAR2,
  X_DATA_SOURCE_STATUS in VARCHAR2,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
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
  X_DATA_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDO_DS_DEFINITIONS_B set
    DATA_SOURCE_STATUS = X_DATA_SOURCE_STATUS,
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
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
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
  and DATA_SOURCE_CODE = X_DATA_SOURCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XDO_DS_DEFINITIONS_TL set
    DATA_SOURCE_NAME = X_DATA_SOURCE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
  and DATA_SOURCE_CODE = X_DATA_SOURCE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_DATA_SOURCE_CODE in VARCHAR2
) is
begin
  delete from XDO_DS_DEFINITIONS_TL
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
  and DATA_SOURCE_CODE = X_DATA_SOURCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XDO_DS_DEFINITIONS_B
  where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
  and DATA_SOURCE_CODE = X_DATA_SOURCE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XDO_DS_DEFINITIONS_TL T
  where not exists
    (select NULL
    from XDO_DS_DEFINITIONS_B B
    where B.APPLICATION_SHORT_NAME = T.APPLICATION_SHORT_NAME
    and B.DATA_SOURCE_CODE = T.DATA_SOURCE_CODE
    );

  update XDO_DS_DEFINITIONS_TL T set (
      DATA_SOURCE_NAME,
      DESCRIPTION
    ) = (select
      B.DATA_SOURCE_NAME,
      B.DESCRIPTION
    from XDO_DS_DEFINITIONS_TL B
    where B.APPLICATION_SHORT_NAME = T.APPLICATION_SHORT_NAME
    and B.DATA_SOURCE_CODE = T.DATA_SOURCE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_SHORT_NAME,
      T.DATA_SOURCE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_SHORT_NAME,
      SUBT.DATA_SOURCE_CODE,
      SUBT.LANGUAGE
    from XDO_DS_DEFINITIONS_TL SUBB, XDO_DS_DEFINITIONS_TL SUBT
    where SUBB.APPLICATION_SHORT_NAME = SUBT.APPLICATION_SHORT_NAME
    and SUBB.DATA_SOURCE_CODE = SUBT.DATA_SOURCE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DATA_SOURCE_NAME <> SUBT.DATA_SOURCE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
  insert into XDO_DS_DEFINITIONS_TL (
    APPLICATION_SHORT_NAME,
    DATA_SOURCE_CODE,
    DATA_SOURCE_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.APPLICATION_SHORT_NAME,
    B.DATA_SOURCE_CODE,
    B.DATA_SOURCE_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDO_DS_DEFINITIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDO_DS_DEFINITIONS_TL T
    where T.APPLICATION_SHORT_NAME = B.APPLICATION_SHORT_NAME
    and T.DATA_SOURCE_CODE = B.DATA_SOURCE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_DATA_SOURCE_CODE in VARCHAR2,
  X_DATA_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
) is
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
begin

   -- Translate owner to file_last_updated_by
   f_luby := fnd_load_util.OWNER_ID(x_owner);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);


  begin
     select LAST_UPDATED_BY, LAST_UPDATE_DATE
     into db_luby, db_ludate
     from XDO_DS_DEFINITIONS_TL
     where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
     and DATA_SOURCE_CODE = X_DATA_SOURCE_CODE
     and LANGUAGE = userenv('LANG');

     -- Update record, honoring customization mode.
     -- Record should be updated only if:
     -- a. CUSTOM_MODE = FORCE, or
     -- b. file owner is USER, db owner is SEED
     -- c. owners are the same, and file_date > db_date
     if (fnd_load_util.UPLOAD_TEST(
                p_file_id     => f_luby,
                p_file_lud    => f_ludate,
                p_db_id       => db_luby,
                p_db_lud      => db_ludate,
                p_custom_mode => x_custom_mode))
     then
       update XDO_DS_DEFINITIONS_TL set
         DATA_SOURCE_NAME =
           nvl(x_data_source_name, data_source_name),
         DESCRIPTION         = nvl(x_description, DESCRIPTION),
         SOURCE_LANG         = userenv('LANG'),
         LAST_UPDATE_DATE      = f_ludate,
         LAST_UPDATED_BY       = f_luby,
         LAST_UPDATE_LOGIN     = 0
       where APPLICATION_SHORT_NAME = X_APPLICATION_SHORT_NAME
       and   DATA_SOURCE_CODE = X_DATA_SOURCE_CODE
       and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
      end if;
  exception
    when no_data_found then
      null;
   end;

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_DATA_SOURCE_CODE       in VARCHAR2,
  X_DATA_SOURCE_STATUS     in VARCHAR2,
  X_START_DATE             in VARCHAR2,
  X_END_DATE               in VARCHAR2,
  X_OBJECT_VERSION_NUMBER  in NUMBER,
  X_DATA_SOURCE_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2,
  X_OWNER                  in VARCHAR2,
  X_LAST_UPDATE_DATE       in VARCHAR2,
  X_CUSTOM_MODE            in VARCHAR2,
  X_ATTRIBUTE_CATEGORY     in VARCHAR2,
  X_ATTRIBUTE1             in VARCHAR2,
  X_ATTRIBUTE2             in VARCHAR2,
  X_ATTRIBUTE3             in VARCHAR2,
  X_ATTRIBUTE4             in VARCHAR2,
  X_ATTRIBUTE5             in VARCHAR2,
  X_ATTRIBUTE6             in VARCHAR2,
  X_ATTRIBUTE7             in VARCHAR2,
  X_ATTRIBUTE8             in VARCHAR2,
  X_ATTRIBUTE9             in VARCHAR2,
  X_ATTRIBUTE10            in VARCHAR2,
  X_ATTRIBUTE11            in VARCHAR2,
  X_ATTRIBUTE12            in VARCHAR2,
  X_ATTRIBUTE13            in VARCHAR2,
  X_ATTRIBUTE14            in VARCHAR2,
  X_ATTRIBUTE15            in VARCHAR2
) is

  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  row_id  varchar2(64);

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select  LAST_UPDATED_BY, LAST_UPDATE_DATE
    into  db_luby, db_ludate
    from xdo_ds_definitions_b
    where data_source_code=x_data_source_code
    and application_short_name = X_APPLICATION_SHORT_NAME;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if (fnd_load_util.UPLOAD_TEST(
                p_file_id     => f_luby,
                p_file_lud     => f_ludate,
                p_db_id        => db_luby,
                p_db_lud       => db_ludate,
                p_custom_mode  => x_custom_mode))
    then
      XDO_DS_DEFINITIONS_PKG.UPDATE_ROW(
      X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
      X_DATA_SOURCE_CODE      => X_DATA_SOURCE_CODE,
      X_DATA_SOURCE_STATUS    => X_DATA_SOURCE_STATUS,
      X_START_DATE            => to_date(X_START_DATE, 'YYYY/MM/DD'),
      X_END_DATE              => to_date(X_END_DATE, 'YYYY/MM/DD'),
      X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
      X_ATTRIBUTE_CATEGORY    => X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1            => X_ATTRIBUTE1,
      X_ATTRIBUTE2            => X_ATTRIBUTE2,
      X_ATTRIBUTE3            => X_ATTRIBUTE3,
      X_ATTRIBUTE4            => X_ATTRIBUTE4,
      X_ATTRIBUTE5            => X_ATTRIBUTE5,
      X_ATTRIBUTE6            => X_ATTRIBUTE6,
      X_ATTRIBUTE7            => X_ATTRIBUTE7,
      X_ATTRIBUTE8            => X_ATTRIBUTE8,
      X_ATTRIBUTE9            => X_ATTRIBUTE9,
      X_ATTRIBUTE10           => X_ATTRIBUTE10,
      X_ATTRIBUTE11           => X_ATTRIBUTE11,
      X_ATTRIBUTE12           => X_ATTRIBUTE12,
      X_ATTRIBUTE13           => X_ATTRIBUTE13,
      X_ATTRIBUTE14           => X_ATTRIBUTE14,
      X_ATTRIBUTE15           => X_ATTRIBUTE15,
      X_DATA_SOURCE_NAME      => X_DATA_SOURCE_NAME,
      X_DESCRIPTION           => X_DESCRIPTION,
      X_LAST_UPDATE_DATE      => f_ludate,
      X_LAST_UPDATED_BY       => f_luby,
      X_LAST_UPDATE_LOGIN     => 0
);
    end if;

  exception when no_data_found then

    XDO_DS_DEFINITIONS_PKG.INSERT_ROW(
      X_ROWID                 => row_id,
      X_APPLICATION_SHORT_NAME => X_APPLICATION_SHORT_NAME,
      X_DATA_SOURCE_CODE      => X_DATA_SOURCE_CODE,
      X_DATA_SOURCE_STATUS    => X_DATA_SOURCE_STATUS,
      X_START_DATE            => to_date(X_START_DATE, 'YYYY/MM/DD'),
      X_END_DATE              => to_date(X_END_DATE, 'YYYY/MM/DD'),
      X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
      X_ATTRIBUTE_CATEGORY    => X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1            => X_ATTRIBUTE1,
      X_ATTRIBUTE2            => X_ATTRIBUTE2,
      X_ATTRIBUTE3            => X_ATTRIBUTE3,
      X_ATTRIBUTE4            => X_ATTRIBUTE4,
      X_ATTRIBUTE5            => X_ATTRIBUTE5,
      X_ATTRIBUTE6            => X_ATTRIBUTE6,
      X_ATTRIBUTE7            => X_ATTRIBUTE7,
      X_ATTRIBUTE8            => X_ATTRIBUTE8,
      X_ATTRIBUTE9            => X_ATTRIBUTE9,
      X_ATTRIBUTE10           => X_ATTRIBUTE10,
      X_ATTRIBUTE11           => X_ATTRIBUTE11,
      X_ATTRIBUTE12           => X_ATTRIBUTE12,
      X_ATTRIBUTE13           => X_ATTRIBUTE13,
      X_ATTRIBUTE14           => X_ATTRIBUTE14,
      X_ATTRIBUTE15           => X_ATTRIBUTE15,
      X_DATA_SOURCE_NAME      => X_DATA_SOURCE_NAME,
      X_DESCRIPTION           => X_DESCRIPTION,
      X_CREATION_DATE         => f_ludate,
      X_CREATED_BY            => f_luby,
      X_LAST_UPDATE_DATE      => f_ludate,
      X_LAST_UPDATED_BY       => f_luby,
      X_LAST_UPDATE_LOGIN     => 0
    );
  end;

end LOAD_ROW;

end XDO_DS_DEFINITIONS_PKG;

/
