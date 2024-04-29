--------------------------------------------------------
--  DDL for Package Body ECX_STANDARDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_STANDARDS_PKG" as
/* $Header: ECXSTDSB.pls 120.2 2005/06/30 11:18:01 appldev ship $ */

procedure TRANSLATE_ROW
        (
        X_STANDARD_TYPE IN      VARCHAR2,
        X_STANDARD_CODE IN      VARCHAR2,
        X_STANDARD_DESC IN      VARCHAR2,
        X_OWNER         IN      VARCHAR2,
        X_CUSTOM_MODE   IN      VARCHAR2
        )
is
  l_luby         number;  -- entity owner in file
  l_ludate       date;    -- entity update date in file
  l_db_luby      number;  -- entity owner in db
  l_db_ludate    date;    -- entity update date in db
  l_standard_id  number;
begin
  -- Translate owner to file_last_updated_by
  if (x_owner = 'SEED') then
    l_luby := 1;
  else
    l_luby := 0;
  end if;
  -- Translate char last_update_date to date
  l_ludate := sysdate;

  begin
    select standard_id
      into l_standard_id
      from ecx_standards
     where STANDARD_CODE = X_STANDARD_CODE
       and STANDARD_TYPE = X_STANDARD_TYPE;

    select LAST_UPDATED_BY,
           LAST_UPDATE_DATE
      into l_db_luby,
           l_db_ludate
      from ECX_STANDARDS_TL
     where STANDARD_ID = l_standard_id
       and LANGUAGE = userenv('LANG');

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if ((x_custom_mode = 'FORCE') or
       ((l_luby = 0) and (l_db_luby = 1)) or
       ((l_luby = l_db_luby) and (l_ludate > l_db_ludate)))
    then
	update ECX_STANDARDS_TL set
	  STANDARD_DESC 	   = nvl(X_STANDARD_DESC, STANDARD_DESC),
          SOURCE_LANG              = userenv('LANG'),
          LAST_UPDATE_DATE         = l_ludate,
          LAST_UPDATED_BY          = l_luby,
          LAST_UPDATE_LOGIN        = 0
	where STANDARD_ID = l_standard_id
          and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      null;
  end;
end TRANSLATE_ROW;


procedure LOAD_ROW (
        X_STANDARD_TYPE IN      VARCHAR2,
        X_STANDARD_CODE IN      VARCHAR2,
        X_STANDARD_DESC IN      VARCHAR2,
        X_DATA_SEEDED   IN      VARCHAR2,
        X_OWNER         IN      VARCHAR2,
        X_CUSTOM_MODE   IN      VARCHAR2
)
is

  l_row_id           varchar2(64);
  l_standard_id      number;
  l_ret_code pls_integer;
  l_errmsg varchar2(2000);

  l_luby             number;  -- entity owner in file
  l_ludate           date;    -- entity update date in file
  l_db_luby          number;  -- entity owner in db
  l_db_ludate        date;    -- entity update date in db
  l_data_seeded      varchar2(1);
begin
  -- Translate owner to file_last_updated_by
  if (x_owner = 'SEED') then
    l_luby := 1;
    l_data_seeded := nvl(X_DATA_SEEDED,'Y');
  else
    l_luby := 0;
    l_data_seeded := nvl(X_DATA_SEEDED,'N');
  end if;
  -- Translate char last_update_date to date
  l_ludate := sysdate;

  begin
    select STANDARD_ID,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE
      into l_standard_id,
           l_db_luby,
           l_db_ludate
      from ECX_STANDARDS_B
     where STANDARD_CODE = X_STANDARD_CODE
       and STANDARD_TYPE = X_STANDARD_TYPE;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if ((x_custom_mode = 'FORCE') or
       ((l_luby = 0) and (l_db_luby = 1)) or
       ((l_luby = l_db_luby) and (l_ludate > l_db_ludate)))
    then
        ecx_document_standards_api.update_standard
        (
        x_return_status         => l_ret_code,
        x_msg                   => l_errmsg,
        p_standard_id           => l_standard_id,
        p_standard_desc         => X_STANDARD_DESC,
        p_data_seeded           => l_data_seeded,
        p_owner                 => X_OWNER
        );
       if (l_ret_code <> ECX_UTIL_API.G_NO_ERROR) then
         raise_application_error(-20000, l_errmsg);
       end if;
   end if;
   exception
     when no_data_found then
        ecx_document_standards_api.create_standard
        (
        x_return_status         => l_ret_code,
        x_msg                   => l_errmsg,
        x_standard_id           => l_standard_id,
        p_standard_code         => X_STANDARD_CODE,
        p_standard_type         => X_STANDARD_TYPE,
        p_standard_desc         => X_STANDARD_DESC,
        p_data_seeded           => l_data_seeded,
        p_owner                 => X_OWNER
        );

       if (l_ret_code <> ECX_UTIL_API.G_NO_ERROR) then
         raise_application_error(-20000, l_errmsg);
       end if;
   end;

end LOAD_ROW;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_STANDARD_ID in NUMBER,
  X_STANDARD_CODE in VARCHAR2,
  X_STANDARD_TYPE in VARCHAR2,
  X_DATA_SEEDED in VARCHAR2,
  X_STANDARD_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ECX_STANDARDS_B
    where STANDARD_ID = X_STANDARD_ID
    ;
begin
  insert into ECX_STANDARDS_B (
    STANDARD_ID,
    STANDARD_CODE,
    STANDARD_TYPE,
    DATA_SEEDED,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_STANDARD_ID,
    X_STANDARD_CODE,
    X_STANDARD_TYPE,
    X_DATA_SEEDED,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into ECX_STANDARDS_TL (
    STANDARD_DESC,
    CREATED_BY,
    LAST_UPDATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    STANDARD_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_STANDARD_DESC,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_STANDARD_ID,
    L.CODE,
    userenv('LANG')
  from WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and not exists
    (select NULL
    from ECX_STANDARDS_TL T
    where T.STANDARD_ID = X_STANDARD_ID
    and T.LANGUAGE = L.CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_STANDARD_ID in NUMBER,
  X_STANDARD_CODE in VARCHAR2,
  X_STANDARD_TYPE in VARCHAR2,
  X_DATA_SEEDED in VARCHAR2,
  X_STANDARD_DESC in VARCHAR2
) is
  cursor c is select
      STANDARD_CODE,
      STANDARD_TYPE,
      DATA_SEEDED
    from ECX_STANDARDS_B
    where STANDARD_ID = X_STANDARD_ID
    for update of STANDARD_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      STANDARD_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ECX_STANDARDS_TL
    where STANDARD_ID = X_STANDARD_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STANDARD_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.STANDARD_CODE = X_STANDARD_CODE)
      AND ((recinfo.STANDARD_TYPE = X_STANDARD_TYPE)
           OR ((recinfo.STANDARD_TYPE is null) AND (X_STANDARD_TYPE is null)))
      AND ((recinfo.DATA_SEEDED = X_DATA_SEEDED)
           OR ((recinfo.DATA_SEEDED is null) AND (X_DATA_SEEDED is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.STANDARD_DESC = X_STANDARD_DESC)
               OR ((tlinfo.STANDARD_DESC is null) AND (X_STANDARD_DESC is null)))
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
  X_STANDARD_ID in NUMBER,
  X_STANDARD_CODE in VARCHAR2,
  X_STANDARD_TYPE in VARCHAR2,
  X_DATA_SEEDED in VARCHAR2,
  X_STANDARD_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ECX_STANDARDS_B set
    STANDARD_CODE = X_STANDARD_CODE,
    STANDARD_TYPE = X_STANDARD_TYPE,
    DATA_SEEDED = X_DATA_SEEDED,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where STANDARD_ID = X_STANDARD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ECX_STANDARDS_TL set
    STANDARD_DESC = X_STANDARD_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STANDARD_ID = X_STANDARD_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STANDARD_ID in NUMBER
) is
begin
  delete from ECX_STANDARDS_TL
  where STANDARD_ID = X_STANDARD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ECX_STANDARDS_B
  where STANDARD_ID = X_STANDARD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ECX_STANDARDS_TL T
  where not exists
    (select NULL
    from ECX_STANDARDS_B B
    where B.STANDARD_ID = T.STANDARD_ID
    );

  update ECX_STANDARDS_TL T set (
      STANDARD_DESC
    ) = (select
      B.STANDARD_DESC
    from ECX_STANDARDS_TL B
    where B.STANDARD_ID = T.STANDARD_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STANDARD_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STANDARD_ID,
      SUBT.LANGUAGE
    from ECX_STANDARDS_TL SUBB, ECX_STANDARDS_TL SUBT
    where SUBB.STANDARD_ID = SUBT.STANDARD_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.STANDARD_DESC <> SUBT.STANDARD_DESC
      or (SUBB.STANDARD_DESC is null and SUBT.STANDARD_DESC is not null)
      or (SUBB.STANDARD_DESC is not null and SUBT.STANDARD_DESC is null)
  ));

  insert into ECX_STANDARDS_TL (
    STANDARD_DESC,
    CREATED_BY,
    LAST_UPDATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    STANDARD_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.STANDARD_DESC,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.STANDARD_ID,
    L.CODE,
    B.SOURCE_LANG
  from ECX_STANDARDS_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ECX_STANDARDS_TL T
    where T.STANDARD_ID = B.STANDARD_ID
    and T.LANGUAGE = L.CODE);
end ADD_LANGUAGE;

end ECX_STANDARDS_PKG;

/
