--------------------------------------------------------
--  DDL for Package Body ECX_XREF_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_XREF_HDR_PKG" as
/* $Header: ECXXRFHB.pls 120.2 2005/06/30 11:19:14 appldev ship $ */

procedure TRANSLATE_ROW (
  X_XREF_CATEGORY_CODE          IN      VARCHAR2,
  X_DESCRIPTION                 IN      VARCHAR2,
  X_OWNER        		IN      VARCHAR2,
  X_CUSTOM_MODE  		IN      VARCHAR2
)
is
  l_luby      number;  -- entity owner in file
  l_ludate    date;    -- entity update date in file
  l_db_luby   number;  -- entity owner in db
  l_db_ludate date;    -- entity update date in db
  l_hdr_id    number;
begin

  -- Translate owner to file_last_updated_by
  if (x_owner = 'SEED') then
    l_luby := 1;
  else
    l_luby := 0;
  end if;

  l_ludate := sysdate;

  begin
    select xref_category_id
      into l_hdr_id
      from ecx_xref_hdr
     where XREF_CATEGORY_CODE = x_xref_category_code;

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into l_db_luby, l_db_ludate
    from ECX_XREF_HDR_TL
    where XREF_CATEGORY_ID = l_hdr_id
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
      update ECX_XREF_HDR_TL set
        DESCRIPTION              = nvl(x_description, DESCRIPTION),
        SOURCE_LANG              = userenv('LANG'),
        LAST_UPDATE_DATE         = l_ludate,
        LAST_UPDATED_BY          = l_luby,
        LAST_UPDATE_LOGIN        = 0
      where XREF_CATEGORY_ID = l_hdr_id
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      null;
  end;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_XREF_CATEGORY_CODE  IN      VARCHAR2,
  X_DESCRIPTION         IN      VARCHAR2,
  X_OWNER        	IN      VARCHAR2,
  X_CUSTOM_MODE  	IN      VARCHAR2
)
is
  profo_id      number := 0;
  user_id       number := 0;
  row_id        varchar2(64);
  l_luby        number;  -- entity owner in file
  l_ludate      date;    -- entity update date in file
  l_db_luby     number;  -- entity owner in db
  l_db_ludate   date;    -- entity update date in db
  l_ret_code    pls_integer :=0;
  l_errmsg      varchar2(2000) := null;
  l_hdr_id      number := 0;
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
    select XREF_CATEGORY_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE
    into  l_hdr_id, l_db_luby, l_db_ludate
    from ECX_XREF_HDR_B
    where XREF_CATEGORY_CODE = x_xref_category_code;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if ((x_custom_mode = 'FORCE') or
        ((l_luby = 0) and (l_db_luby = 1)) or
        ((l_luby = l_db_luby) and (l_ludate > l_db_ludate)))
    then
        ecx_xref_api.update_code_category(
          x_return_status      => l_ret_code,
          x_msg                => l_errmsg,
          p_xref_category_id   => l_hdr_id,
          p_xref_category_code => x_xref_category_code,
          p_description        => x_description,
          p_owner              => x_owner);
        if NOT(l_ret_code = ECX_UTIL_API.G_NO_ERROR) then
         raise_application_error(-20000, l_errmsg);
        end if;

    end if;
  exception
     when no_data_found then
        ecx_xref_api.create_code_category(
          x_return_status      => l_ret_code,
          x_msg                => l_errmsg,
          x_xref_hdr_id        => l_hdr_id,
          p_xref_category_code => x_xref_category_code,
          p_description        => x_description,
          p_owner              => x_owner);
        if NOT(l_ret_code = ECX_UTIL_API.G_NO_ERROR) then
          raise_application_error(-20000, l_errmsg);
        end if;
     when others then
       raise;
  end;
end LOAD_ROW;


procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_XREF_CATEGORY_ID in NUMBER,
  X_XREF_CATEGORY_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ECX_XREF_HDR_B
    where XREF_CATEGORY_ID = X_XREF_CATEGORY_ID
    ;
begin
  insert into ECX_XREF_HDR_B (
    XREF_CATEGORY_ID,
    XREF_CATEGORY_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_XREF_CATEGORY_ID,
    X_XREF_CATEGORY_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into ECX_XREF_HDR_TL (
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    XREF_CATEGORY_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_XREF_CATEGORY_ID,
    L.CODE,
    userenv('LANG')
  from WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and not exists
    (select NULL
    from ECX_XREF_HDR_TL T
    where T.XREF_CATEGORY_ID = X_XREF_CATEGORY_ID
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
  X_XREF_CATEGORY_ID in NUMBER,
  X_XREF_CATEGORY_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      XREF_CATEGORY_CODE
    from ECX_XREF_HDR_B
    where XREF_CATEGORY_ID = X_XREF_CATEGORY_ID
    for update of XREF_CATEGORY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ECX_XREF_HDR_TL
    where XREF_CATEGORY_ID = X_XREF_CATEGORY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of XREF_CATEGORY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.XREF_CATEGORY_CODE = X_XREF_CATEGORY_CODE)
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
  X_XREF_CATEGORY_ID in NUMBER,
  X_XREF_CATEGORY_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ECX_XREF_HDR_B set
    XREF_CATEGORY_CODE = X_XREF_CATEGORY_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where XREF_CATEGORY_ID = X_XREF_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ECX_XREF_HDR_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where XREF_CATEGORY_ID = X_XREF_CATEGORY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_XREF_CATEGORY_ID in NUMBER
) is
begin
  delete from ECX_XREF_HDR_TL
  where XREF_CATEGORY_ID = X_XREF_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ECX_XREF_HDR_B
  where XREF_CATEGORY_ID = X_XREF_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ECX_XREF_HDR_TL T
  where not exists
    (select NULL
    from ECX_XREF_HDR_B B
    where B.XREF_CATEGORY_ID = T.XREF_CATEGORY_ID
    );

  update ECX_XREF_HDR_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from ECX_XREF_HDR_TL B
    where B.XREF_CATEGORY_ID = T.XREF_CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.XREF_CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.XREF_CATEGORY_ID,
      SUBT.LANGUAGE
    from ECX_XREF_HDR_TL SUBB, ECX_XREF_HDR_TL SUBT
    where SUBB.XREF_CATEGORY_ID = SUBT.XREF_CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into ECX_XREF_HDR_TL (
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    XREF_CATEGORY_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.XREF_CATEGORY_ID,
    L.CODE,
    B.SOURCE_LANG
  from ECX_XREF_HDR_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ECX_XREF_HDR_TL T
    where T.XREF_CATEGORY_ID = B.XREF_CATEGORY_ID
    and T.LANGUAGE = L.CODE);
end ADD_LANGUAGE;

end ECX_XREF_HDR_PKG;

/
