--------------------------------------------------------
--  DDL for Package Body ECX_XREF_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_XREF_DTL_PKG" as
/* $Header: ECXXRFDB.pls 115.5 2003/11/14 17:44:59 mtai ship $ */

procedure TRANSLATE_ROW (
  X_XREF_CATEGORY_ID IN NUMBER,
  X_STANDARD_ID IN NUMBER,
  X_TP_HEADER_ID IN NUMBER,
  X_XREF_EXT_VALUE IN VARCHAR2,
  X_XREF_INT_VALUE IN VARCHAR2,
  X_DIRECTION IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2,
  X_OWNER IN VARCHAR2,
  X_CUSTOM_MODE IN VARCHAR2)
is
  l_luby       number;  -- entity owner in file
  l_ludate     date;    -- entity update date in file
  l_db_luby    number;  -- entity owner in db
  l_db_ludate  date;    -- entity update date in db
  l_dtl_id     number;
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
    select xref_dtl_id
    into l_dtl_id
    from ECX_XREF_DTL_B
    where XREF_CATEGORY_ID = X_XREF_CATEGORY_ID
      and standard_id = X_STANDARD_ID
      and tp_header_id = X_TP_HEADER_ID
      and xref_int_value = X_XREF_INT_VALUE
      and xref_ext_value = X_XREF_EXT_VALUE
      and direction = X_DIRECTION;

    select LAST_UPDATED_BY, LAST_UPDATE_DATE
    into l_db_luby, l_db_ludate
    from ECX_XREF_DTL_TL
    where XREF_DTL_ID = l_dtl_id
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
      update ECX_XREF_DTL_TL set
        DESCRIPTION              = nvl(x_description, DESCRIPTION),
        SOURCE_LANG              = userenv('LANG'),
        LAST_UPDATE_DATE         = l_ludate,
        LAST_UPDATED_BY          = l_luby,
        LAST_UPDATE_LOGIN        = 0
      where XREF_DTL_ID = l_dtl_id
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      null;
  end;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_XREF_CATEGORY_CODE IN VARCHAR2,
  X_STANDARD_CODE IN VARCHAR2,
  X_TP_HEADER_ID IN NUMBER,
  X_XREF_EXT_VALUE IN VARCHAR2,
  X_XREF_INT_VALUE IN VARCHAR2,
  X_DIRECTION IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2,
  X_OWNER IN VARCHAR2,
  X_CUSTOM_MODE IN VARCHAR2,
  X_STANDARD_TYPE IN VARCHAR2)
is
  l_luby      number;  -- entity owner in file
  l_ludate    date;    -- entity update date in file
  l_db_luby   number;  -- entity owner in db
  l_db_ludate date;    -- entity update date in db
  l_ret_code  pls_integer :=0;
  l_errmsg    varchar2(2000) := null;
  l_dtl_id    number := 0;
  l_hdr_id    number :=0;
  l_standard_id number :=0;
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
    select XREF_CATEGORY_ID
      into l_hdr_id
      from ecx_xref_hdr_b
     where XREF_CATEGORY_CODE = X_XREF_CATEGORY_CODE;

    select STANDARD_ID
      into l_standard_id
      from ecx_standards_b
     where STANDARD_CODE = X_STANDARD_CODE
     and   STANDARD_TYPE = nvl(X_STANDARD_TYPE, 'XML');

    select XREF_DTL_ID
      into l_dtl_id
      from ECX_XREF_DTL_B
     where XREF_CATEGORY_ID = l_hdr_id
       and standard_id = l_standard_id
       and tp_header_id = X_TP_HEADER_ID
       and xref_int_value = X_XREF_INT_VALUE
       and xref_ext_value = X_XREF_EXT_VALUE
       and direction = X_DIRECTION;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date
    if ((x_custom_mode = 'FORCE') or
        ((l_luby = 0) and (l_db_luby = 1)) or
        ((l_luby = l_db_luby) and (l_ludate > l_db_ludate)))
    then
        ecx_xref_api.update_tp_code_values(
          x_return_status      => l_ret_code,
          x_msg                => l_errmsg,
          p_xref_dtl_id        => l_dtl_id,
          p_xref_ext_value     => X_XREF_EXT_VALUE,
          p_xref_int_value     => X_XREF_INT_VALUE,
          p_tp_header_id       => X_TP_HEADER_ID,
          p_description        => X_DESCRIPTION,
          p_direction          => X_DIRECTION
        );

        if NOT(l_ret_code = ECX_UTIL_API.G_NO_ERROR) then
         raise_application_error(-20000, l_errmsg);
        end if;

    end if;
  exception
     when no_data_found then
        ecx_xref_api.create_tp_code_values(
          x_return_status        => l_ret_code,
          x_msg                  => l_errmsg,
          x_xref_dtl_id          => l_dtl_id,
          x_xref_category_id     => l_hdr_id,
          p_xref_category_code   => X_XREF_CATEGORY_CODE,
          p_standard             => X_STANDARD_CODE,
          p_tp_header_id         => X_TP_HEADER_ID,
          p_xref_ext_value       => X_XREF_EXT_VALUE,
          p_xref_int_value       => X_XREF_INT_VALUE,
          p_description          => X_DESCRIPTION,
          p_direction            => X_DIRECTION,
          p_standard_type        => X_STANDARD_TYPE
        );
        if NOT(l_ret_code = ECX_UTIL_API.G_NO_ERROR) then
          raise_application_error(-20000, l_errmsg);
        end if;
     when others then
       raise;
  end;
end LOAD_ROW;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_XREF_DTL_ID in NUMBER,
  X_XREF_CATEGORY_ID in NUMBER,
  X_STANDARD_ID in NUMBER,
  X_XREF_STANDARD_CODE in VARCHAR2,
  X_TP_HEADER_ID in NUMBER,
  X_XREF_EXT_VALUE in VARCHAR2,
  X_XREF_INT_VALUE in VARCHAR2,
  X_DIRECTION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from ECX_XREF_DTL_B
    where XREF_DTL_ID = X_XREF_DTL_ID
    ;
begin
  insert into ECX_XREF_DTL_B (
    XREF_DTL_ID,
    XREF_CATEGORY_ID,
    STANDARD_ID,
    XREF_STANDARD_CODE,
    TP_HEADER_ID,
    XREF_EXT_VALUE,
    XREF_INT_VALUE,
    DIRECTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_XREF_DTL_ID,
    X_XREF_CATEGORY_ID,
    X_STANDARD_ID,
    X_XREF_STANDARD_CODE,
    X_TP_HEADER_ID,
    X_XREF_EXT_VALUE,
    X_XREF_INT_VALUE,
    X_DIRECTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into ECX_XREF_DTL_TL (
    XREF_DTL_ID,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_XREF_DTL_ID,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.CODE,
    userenv('LANG')
  from WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and not exists
    (select NULL
    from ECX_XREF_DTL_TL T
    where T.XREF_DTL_ID = X_XREF_DTL_ID
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
  X_XREF_DTL_ID in NUMBER,
  X_XREF_CATEGORY_ID in NUMBER,
  X_STANDARD_ID in NUMBER,
  X_XREF_STANDARD_CODE in VARCHAR2,
  X_TP_HEADER_ID in NUMBER,
  X_XREF_EXT_VALUE in VARCHAR2,
  X_XREF_INT_VALUE in VARCHAR2,
  X_DIRECTION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      XREF_CATEGORY_ID,
      STANDARD_ID,
      XREF_STANDARD_CODE,
      TP_HEADER_ID,
      XREF_EXT_VALUE,
      XREF_INT_VALUE,
      DIRECTION
    from ECX_XREF_DTL_B
    where XREF_DTL_ID = X_XREF_DTL_ID
    for update of XREF_DTL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ECX_XREF_DTL_TL
    where XREF_DTL_ID = X_XREF_DTL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of XREF_DTL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.XREF_CATEGORY_ID = X_XREF_CATEGORY_ID)
      AND (recinfo.STANDARD_ID = X_STANDARD_ID)
      AND ((recinfo.XREF_STANDARD_CODE = X_XREF_STANDARD_CODE)
           OR ((recinfo.XREF_STANDARD_CODE is null) AND (X_XREF_STANDARD_CODE is null)))
      AND (recinfo.TP_HEADER_ID = X_TP_HEADER_ID)
      AND (recinfo.XREF_EXT_VALUE = X_XREF_EXT_VALUE)
      AND (recinfo.XREF_INT_VALUE = X_XREF_INT_VALUE)
      AND (recinfo.DIRECTION = X_DIRECTION)
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
  X_XREF_DTL_ID in NUMBER,
  X_XREF_CATEGORY_ID in NUMBER,
  X_STANDARD_ID in NUMBER,
  X_XREF_STANDARD_CODE in VARCHAR2,
  X_TP_HEADER_ID in NUMBER,
  X_XREF_EXT_VALUE in VARCHAR2,
  X_XREF_INT_VALUE in VARCHAR2,
  X_DIRECTION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update ECX_XREF_DTL_B set
    XREF_CATEGORY_ID = X_XREF_CATEGORY_ID,
    STANDARD_ID = X_STANDARD_ID,
    XREF_STANDARD_CODE = X_XREF_STANDARD_CODE,
    TP_HEADER_ID = X_TP_HEADER_ID,
    XREF_EXT_VALUE = X_XREF_EXT_VALUE,
    XREF_INT_VALUE = X_XREF_INT_VALUE,
    DIRECTION = X_DIRECTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where XREF_DTL_ID = X_XREF_DTL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ECX_XREF_DTL_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where XREF_DTL_ID = X_XREF_DTL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_XREF_DTL_ID in NUMBER
) is
begin
  delete from ECX_XREF_DTL_TL
  where XREF_DTL_ID = X_XREF_DTL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ECX_XREF_DTL_B
  where XREF_DTL_ID = X_XREF_DTL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ECX_XREF_DTL_TL T
  where not exists
    (select NULL
    from ECX_XREF_DTL_B B
    where B.XREF_DTL_ID = T.XREF_DTL_ID
    );

  update ECX_XREF_DTL_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from ECX_XREF_DTL_TL B
    where B.XREF_DTL_ID = T.XREF_DTL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.XREF_DTL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.XREF_DTL_ID,
      SUBT.LANGUAGE
    from ECX_XREF_DTL_TL SUBB, ECX_XREF_DTL_TL SUBT
    where SUBB.XREF_DTL_ID = SUBT.XREF_DTL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into ECX_XREF_DTL_TL (
    XREF_DTL_ID,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.XREF_DTL_ID,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.CODE,
    B.SOURCE_LANG
  from ECX_XREF_DTL_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ECX_XREF_DTL_TL T
    where T.XREF_DTL_ID = B.XREF_DTL_ID
    and T.LANGUAGE = L.CODE);
end ADD_LANGUAGE;

end ECX_XREF_DTL_PKG;

/
