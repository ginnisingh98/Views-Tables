--------------------------------------------------------
--  DDL for Package Body HZ_STYLE_FORMATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_STYLE_FORMATS_PKG" as
/* $Header: ARHPSTFB.pls 115.9 2004/02/25 23:17:48 geliu noship $ */

L_USER_ID_FOR_SEED NUMBER := NULL;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_STYLE_CODE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_STYLE_FORMAT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OBJECT_VERSION_NUMBER  IN NUMBER
) is
  cursor C is select ROWID from HZ_STYLE_FORMATS_B
    where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE
    ;
begin
  insert into HZ_STYLE_FORMATS_B (
    STYLE_FORMAT_CODE,
    STYLE_CODE,
    DEFAULT_FLAG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER
  ) values (
    DECODE( X_STYLE_FORMAT_CODE, FND_API.G_MISS_CHAR, NULL, X_STYLE_FORMAT_CODE ),
    DECODE( X_STYLE_CODE, FND_API.G_MISS_CHAR, NULL, X_STYLE_CODE ),
    DECODE( X_DEFAULT_FLAG, FND_API.G_MISS_CHAR, NULL, X_DEFAULT_FLAG ),
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.CREATED_BY),
    HZ_UTILITY_V2PUB.CREATION_DATE,
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN),
    HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATED_BY),
    DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER )
  );

  insert into HZ_STYLE_FORMATS_TL (
    STYLE_FORMAT_CODE,
    STYLE_FORMAT_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    DECODE( X_STYLE_FORMAT_CODE, FND_API.G_MISS_CHAR, NULL, X_STYLE_FORMAT_CODE ),
    DECODE( X_STYLE_FORMAT_NAME, FND_API.G_MISS_CHAR, NULL, X_STYLE_FORMAT_NAME ),
    DECODE( X_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, X_DESCRIPTION ),
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.CREATED_BY),
    HZ_UTILITY_V2PUB.CREATION_DATE,
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN),
    HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
    NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATED_BY),
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HZ_STYLE_FORMATS_TL T
    where T.STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE
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
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_STYLE_CODE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_STYLE_FORMAT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      STYLE_CODE,
      DEFAULT_FLAG
    from HZ_STYLE_FORMATS_B
    where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE
    for update of STYLE_FORMAT_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      STYLE_FORMAT_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HZ_STYLE_FORMATS_TL
    where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STYLE_FORMAT_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.STYLE_CODE = X_STYLE_CODE)
      AND (recinfo.DEFAULT_FLAG = X_DEFAULT_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.STYLE_FORMAT_NAME = X_STYLE_FORMAT_NAME)
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
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_STYLE_CODE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_STYLE_FORMAT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN NUMBER
) is
begin
  update HZ_STYLE_FORMATS_B set
    STYLE_CODE = DECODE( X_STYLE_CODE, NULL, STYLE_CODE, FND_API.G_MISS_CHAR, NULL, X_STYLE_CODE ),
    DEFAULT_FLAG = DECODE( X_DEFAULT_FLAG, NULL, DEFAULT_FLAG, FND_API.G_MISS_CHAR, NULL, X_DEFAULT_FLAG ),
    LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
    LAST_UPDATED_BY = NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN),
    OBJECT_VERSION_NUMBER = DECODE(X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER,
                                  FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER)
  where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update HZ_STYLE_FORMATS_TL set
    STYLE_FORMAT_NAME =  DECODE( X_STYLE_FORMAT_NAME, NULL, STYLE_FORMAT_NAME, FND_API.G_MISS_CHAR, NULL, X_STYLE_FORMAT_NAME ),
    DESCRIPTION = DECODE( X_DESCRIPTION, NULL, DESCRIPTION, FND_API.G_MISS_CHAR, NULL, X_DESCRIPTION ),
    LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
    LAST_UPDATED_BY = NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = NVL(L_USER_ID_FOR_SEED,HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN),
    SOURCE_LANG = userenv('LANG')
  where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

PROCEDURE SELECT_ROW (
  X_STYLE_FORMAT_CODE		IN OUT NOCOPY VARCHAR2,
  X_STYLE_CODE			OUT    NOCOPY VARCHAR2,
  X_DEFAULT_FLAG		OUT    NOCOPY VARCHAR2,
  X_STYLE_FORMAT_NAME		OUT    NOCOPY VARCHAR2,
  X_DESCRIPTION			OUT    NOCOPY VARCHAR2
) IS
BEGIN

    SELECT
        NVL( B.STYLE_FORMAT_CODE, FND_API.G_MISS_CHAR ),
        NVL( B.STYLE_CODE, FND_API.G_MISS_CHAR ),
        NVL( B.DEFAULT_FLAG, FND_API.G_MISS_CHAR ),
        NVL( T.STYLE_FORMAT_NAME, FND_API.G_MISS_CHAR ),
        NVL( T.DESCRIPTION, FND_API.G_MISS_CHAR )
    INTO X_STYLE_FORMAT_CODE,
         X_STYLE_CODE,
	 X_DEFAULT_FLAG,
	 X_STYLE_FORMAT_NAME,
	 X_DESCRIPTION
    FROM HZ_STYLE_FORMATS_B B, HZ_STYLE_FORMATS_TL T
    WHERE B.STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE
    AND   T.STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE
    AND   T.LANGUAGE = userenv('LANG');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'style_format_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', 'STYLE_FORMAT_CODE' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
END SELECT_ROW;


procedure DELETE_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2
) is
begin
  delete from HZ_STYLE_FORMATS_TL
  where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HZ_STYLE_FORMATS_B
  where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from HZ_STYLE_FORMATS_TL T
  where not exists
    (select NULL
    from HZ_STYLE_FORMATS_B B
    where B.STYLE_FORMAT_CODE = T.STYLE_FORMAT_CODE
    );

  update HZ_STYLE_FORMATS_TL T set (
      STYLE_FORMAT_NAME,
      DESCRIPTION
    ) = (select
      B.STYLE_FORMAT_NAME,
      B.DESCRIPTION
    from HZ_STYLE_FORMATS_TL B
    where B.STYLE_FORMAT_CODE = T.STYLE_FORMAT_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STYLE_FORMAT_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.STYLE_FORMAT_CODE,
      SUBT.LANGUAGE
    from HZ_STYLE_FORMATS_TL SUBB, HZ_STYLE_FORMATS_TL SUBT
    where SUBB.STYLE_FORMAT_CODE = SUBT.STYLE_FORMAT_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.STYLE_FORMAT_NAME <> SUBT.STYLE_FORMAT_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into HZ_STYLE_FORMATS_TL (
    STYLE_FORMAT_CODE,
    STYLE_FORMAT_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.STYLE_FORMAT_CODE,
    B.STYLE_FORMAT_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HZ_STYLE_FORMATS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HZ_STYLE_FORMATS_TL T
    where T.STYLE_FORMAT_CODE = B.STYLE_FORMAT_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_STYLE_CODE in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_STYLE_FORMAT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,  -- "SEED" or "CUSTOM"
  X_LAST_UPDATE_DATE in DATE,
  X_CUSTOM_MODE in VARCHAR2
) is
  l_f_luby    number;  -- entity owner in file
  l_f_ludate  date;    -- entity update date in file
  l_db_luby   number;  -- entity owner in db
  l_db_ludate date;    -- entity update date in db
  l_rowid     varchar2(64);
  l_object_version_number number;
begin

  -- Translate owner to file_last_updated_by
  if (x_owner = 'SEED') then
    l_f_luby := 1;
    L_USER_ID_FOR_SEED := 1;
  else
    l_f_luby := 0;
  end if;

  -- Get last update date of ldt entity
  l_f_ludate := nvl(x_last_update_date, sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE, OBJECT_VERSION_NUMBER
         into l_db_luby, l_db_ludate, l_object_version_number
         from HZ_STYLE_FORMATS_B
         where STYLE_FORMAT_CODE = x_style_format_code;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date

    if ((x_custom_mode = 'FORCE') or
       ((l_f_luby = 0) and (l_db_luby = 1)) or
       ((l_f_luby = l_db_luby) and (l_f_ludate > l_db_ludate)))
    then
      hz_style_formats_pkg.update_row (
        X_STYLE_FORMAT_CODE    => X_STYLE_FORMAT_CODE,
        X_STYLE_CODE           => X_STYLE_CODE,
        X_DEFAULT_FLAG         => X_DEFAULT_FLAG,
        X_STYLE_FORMAT_NAME    => X_STYLE_FORMAT_NAME,
        X_DESCRIPTION          => X_DESCRIPTION,
        X_OBJECT_VERSION_NUMBER => l_object_version_number
      );
    end if;

  exception
    when no_data_found then
      -- record not found, insert in all cases
      hz_style_formats_pkg.insert_row(
          x_rowid                => l_rowid,
          x_style_format_code    => X_STYLE_FORMAT_CODE,
          x_style_code           => X_STYLE_CODE,
          x_default_flag         => X_DEFAULT_FLAG,
          x_style_format_name    => X_STYLE_FORMAT_NAME,
          x_description          => X_DESCRIPTION,
	  x_object_version_number => 1
      );
  end;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_STYLE_FORMAT_CODE in VARCHAR2,
  X_STYLE_FORMAT_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,  -- "SEED" or "CUSTOM"
  X_LAST_UPDATE_DATE in DATE,
  X_CUSTOM_MODE in VARCHAR2
) is
  l_f_luby    number;  -- entity owner in file
  l_f_ludate  date;    -- entity update date in file
  l_db_luby   number;  -- entity owner in db
  l_db_ludate date;    -- entity update date in db
begin
  -- Translate owner to file_last_updated_by
  if (x_owner = 'SEED') then
    l_f_luby := 1;
  else
    l_f_luby := 0;
  end if;

  -- Get last update date of ldt entity
  l_f_ludate := nvl(x_last_update_date, sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
         into l_db_luby, l_db_ludate
         from HZ_STYLE_FORMATS_TL
         where STYLE_FORMAT_CODE = x_style_format_code
           and LANGUAGE = userenv('LANG');

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date

    if ((x_custom_mode = 'FORCE') or
       ((l_f_luby = 0) and (l_db_luby = 1)) or
       ((l_f_luby = l_db_luby) and (l_f_ludate > l_db_ludate)))
    then
      update HZ_STYLE_FORMATS_TL
         set STYLE_FORMAT_NAME = nvl(X_STYLE_FORMAT_NAME,STYLE_FORMAT_NAME),
             DESCRIPTION       = nvl(X_DESCRIPTION,DESCRIPTION),
             LAST_UPDATE_DATE  = l_f_ludate,
             LAST_UPDATED_BY   = l_f_luby,
             LAST_UPDATE_LOGIN = 0,
             SOURCE_LANG       = userenv('LANG')
       where STYLE_FORMAT_CODE = X_STYLE_FORMAT_CODE
         and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      null;  -- no translation found.  standards say do nothing.
  end;

end TRANSLATE_ROW;


end HZ_STYLE_FORMATS_PKG;

/
