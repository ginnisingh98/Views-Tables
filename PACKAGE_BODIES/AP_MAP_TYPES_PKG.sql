--------------------------------------------------------
--  DDL for Package Body AP_MAP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_MAP_TYPES_PKG" as
/* $Header: apmaptpb.pls 115.3 2004/03/30 23:14:20 kmizuta noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MAP_TYPE_CODE in VARCHAR2,
  X_FROM_APPLICATION_ID in NUMBER,
  X_FROM_LOOKUP_TYPE in VARCHAR2,
  X_TO_APPLICATION_ID in NUMBER,
  X_TO_LOOKUP_TYPE in VARCHAR2,
  X_DEFAULT_LOOKUP_CODE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AP_MAP_TYPES_B
    where MAP_TYPE_CODE = X_MAP_TYPE_CODE
    ;
begin
  insert into AP_MAP_TYPES_B (
    MAP_TYPE_CODE,
    FROM_APPLICATION_ID,
    FROM_LOOKUP_TYPE,
    TO_APPLICATION_ID,
    TO_LOOKUP_TYPE,
    DEFAULT_LOOKUP_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MAP_TYPE_CODE,
    X_FROM_APPLICATION_ID,
    X_FROM_LOOKUP_TYPE,
    X_TO_APPLICATION_ID,
    X_TO_LOOKUP_TYPE,
    X_DEFAULT_LOOKUP_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AP_MAP_TYPES_TL (
    MAP_TYPE_CODE,
    MEANING,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_MAP_TYPE_CODE,
    X_MEANING,
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
    from AP_MAP_TYPES_TL T
    where T.MAP_TYPE_CODE = X_MAP_TYPE_CODE
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
  X_MAP_TYPE_CODE in VARCHAR2,
  X_FROM_APPLICATION_ID in NUMBER,
  X_FROM_LOOKUP_TYPE in VARCHAR2,
  X_TO_APPLICATION_ID in NUMBER,
  X_TO_LOOKUP_TYPE in VARCHAR2,
  X_DEFAULT_LOOKUP_CODE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      FROM_APPLICATION_ID,
      FROM_LOOKUP_TYPE,
      TO_APPLICATION_ID,
      TO_LOOKUP_TYPE,
      DEFAULT_LOOKUP_CODE
    from AP_MAP_TYPES_B
    where MAP_TYPE_CODE = X_MAP_TYPE_CODE
    for update of MAP_TYPE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MEANING,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AP_MAP_TYPES_TL
    where MAP_TYPE_CODE = X_MAP_TYPE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of MAP_TYPE_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.FROM_APPLICATION_ID = X_FROM_APPLICATION_ID)
           OR ((recinfo.FROM_APPLICATION_ID is null) AND (X_FROM_APPLICATION_ID is null)))
      AND ((recinfo.FROM_LOOKUP_TYPE = X_FROM_LOOKUP_TYPE)
           OR ((recinfo.FROM_LOOKUP_TYPE is null) AND (X_FROM_LOOKUP_TYPE is null)))
      AND ((recinfo.TO_APPLICATION_ID = X_TO_APPLICATION_ID)
           OR ((recinfo.TO_APPLICATION_ID is null) AND (X_TO_APPLICATION_ID is null)))
      AND ((recinfo.TO_LOOKUP_TYPE = X_TO_LOOKUP_TYPE)
           OR ((recinfo.TO_LOOKUP_TYPE is null) AND (X_TO_LOOKUP_TYPE is null)))
      AND ((recinfo.DEFAULT_LOOKUP_CODE = X_DEFAULT_LOOKUP_CODE)
           OR ((recinfo.DEFAULT_LOOKUP_CODE is null) AND (X_DEFAULT_LOOKUP_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.MEANING = X_MEANING)
               OR ((tlinfo.MEANING is null) AND (X_MEANING is null)))
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
  X_MAP_TYPE_CODE in VARCHAR2,
  X_FROM_APPLICATION_ID in NUMBER,
  X_FROM_LOOKUP_TYPE in VARCHAR2,
  X_TO_APPLICATION_ID in NUMBER,
  X_TO_LOOKUP_TYPE in VARCHAR2,
  X_DEFAULT_LOOKUP_CODE in VARCHAR2,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AP_MAP_TYPES_B set
    FROM_APPLICATION_ID = X_FROM_APPLICATION_ID,
    FROM_LOOKUP_TYPE = X_FROM_LOOKUP_TYPE,
    TO_APPLICATION_ID = X_TO_APPLICATION_ID,
    TO_LOOKUP_TYPE = X_TO_LOOKUP_TYPE,
    DEFAULT_LOOKUP_CODE = X_DEFAULT_LOOKUP_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where MAP_TYPE_CODE = X_MAP_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AP_MAP_TYPES_TL set
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where MAP_TYPE_CODE = X_MAP_TYPE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_MAP_TYPE_CODE in VARCHAR2
) is
begin
  delete from AP_MAP_CODES
  where MAP_TYPE_CODE = X_MAP_TYPE_CODE;

  delete from AP_MAP_TYPES_TL
  where MAP_TYPE_CODE = X_MAP_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AP_MAP_TYPES_B
  where MAP_TYPE_CODE = X_MAP_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AP_MAP_TYPES_TL T
  where not exists
    (select NULL
    from AP_MAP_TYPES_B B
    where B.MAP_TYPE_CODE = T.MAP_TYPE_CODE
    );

  update AP_MAP_TYPES_TL T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from AP_MAP_TYPES_TL B
    where B.MAP_TYPE_CODE = T.MAP_TYPE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MAP_TYPE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.MAP_TYPE_CODE,
      SUBT.LANGUAGE
    from AP_MAP_TYPES_TL SUBB, AP_MAP_TYPES_TL SUBT
    where SUBB.MAP_TYPE_CODE = SUBT.MAP_TYPE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or (SUBB.MEANING is null and SUBT.MEANING is not null)
      or (SUBB.MEANING is not null and SUBT.MEANING is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AP_MAP_TYPES_TL (
    MAP_TYPE_CODE,
    MEANING,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.MAP_TYPE_CODE,
    B.MEANING,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AP_MAP_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AP_MAP_TYPES_TL T
    where T.MAP_TYPE_CODE = B.MAP_TYPE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--
-- Function to return the destination lookup code
-- for a given source lookup code.
-- If no mapping is found, then the default is returned.
function GET_MAP_TO_CODE(x_map_type_code IN VARCHAR2, x_map_from_code IN VARCHAR2)
    return VARCHAR2 IS
  l_map_to_code VARCHAR2(30);
begin
  SELECT to_lookup_code
  INTO l_map_to_code
  FROM ap_map_codes
  WHERE map_type_code = x_map_type_code
  AND from_lookup_code = x_map_from_code;

  return l_map_to_code;
exception
  when no_data_found then
    SELECT default_lookup_code
    INTO l_map_to_code
    FROM ap_map_types_b
    WHERE map_type_code = x_map_type_code;

    return l_map_to_code;
end GET_MAP_TO_CODE;


FUNCTION IS_LOOKUP_UNUSABLE(x_lookup_app_id in number,
                            x_lookup_type in varchar2,
                            x_lookup_code in varchar2)
return boolean is
  l_end_date date;
  l_enabled varchar2(1);
begin
  if x_lookup_code is null then
    return false;
  end if;

  select end_date_active, enabled_flag
  into l_end_date, l_enabled
  from fnd_lookup_values
  WHERE LANGUAGE = userenv('LANG')
  AND SECURITY_GROUP_ID = fnd_global.lookup_security_group(LOOKUP_TYPE, VIEW_APPLICATION_ID)
  AND view_application_id = x_lookup_app_id
  AND lookup_type = x_lookup_type
  AND lookup_code = x_lookup_code;

  if (l_end_date < sysdate or l_enabled <> 'Y') then
    return true;
  else
    return false;
  end if;
end IS_LOOKUP_UNUSABLE;

PROCEDURE CLEAR_DISABLED_CODES(x_map_type_code IN VARCHAR2) IS
   PRAGMA autonomous_transaction;
  l_to_app number;
  l_to_type varchar2(30);
  l_default_code varchar2(30);

  l_from_app number;
  l_from_type varchar2(30);

  cursor crules is select from_lookup_code, to_lookup_code
        from ap_map_codes
        where map_type_code = x_map_type_code;
BEGIN
   select from_application_id, from_lookup_type, to_application_id, to_lookup_type, default_lookup_code
   into l_from_app, l_from_type, l_to_app, l_to_type, l_default_code
   from ap_map_types_b
   where map_type_code = x_map_type_code;

   if is_lookup_unusable(l_to_app, l_to_type, l_default_code) then
     update ap_map_types_b set default_lookup_code = null
     where map_type_code = x_map_type_code;
   end if;

   for crec in crules loop
     if is_lookup_unusable(l_to_app, l_to_type, crec.to_lookup_code) or
        is_lookup_unusable(l_from_app, l_from_type, crec.from_lookup_code) then
       delete from ap_map_codes
       where map_type_code = x_map_type_code
       and from_lookup_code = crec.from_lookup_code;
     end if;
   end loop;

   COMMIT;
END clear_disabled_codes;

end AP_MAP_TYPES_PKG;

/
