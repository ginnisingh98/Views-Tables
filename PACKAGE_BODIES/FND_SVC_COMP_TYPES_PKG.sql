--------------------------------------------------------
--  DDL for Package Body FND_SVC_COMP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SVC_COMP_TYPES_PKG" as
/* $Header: AFSVCTTB.pls 115.3 2002/12/27 20:30:10 ankung noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_COMPONENT_CLASS_NAME in VARCHAR2,
  X_CONFIG_UI_REGION in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_SVC_COMP_TYPES_B
    where COMPONENT_TYPE = X_COMPONENT_TYPE
    ;
begin
  insert into FND_SVC_COMP_TYPES_B (
    COMPONENT_TYPE,
    COMPONENT_CLASS_NAME,
    CONFIG_UI_REGION,
    CUSTOMIZATION_LEVEL,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_COMPONENT_TYPE,
    X_COMPONENT_CLASS_NAME,
    X_CONFIG_UI_REGION,
    X_CUSTOMIZATION_LEVEL,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_SVC_COMP_TYPES_TL (
    COMPONENT_TYPE,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_COMPONENT_TYPE,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.CODE,
    userenv('LANG')
  from WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and not exists
    (select NULL
    from FND_SVC_COMP_TYPES_TL T
    where T.COMPONENT_TYPE = X_COMPONENT_TYPE
    and T.LANGUAGE = L.CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

exception
  when others then
    wf_core.context('FND_SVC_COMP_TYPES_PKG', 'Insert_Row', X_COMPONENT_TYPE, X_COMPONENT_CLASS_NAME);
    raise;
end INSERT_ROW;

procedure LOCK_ROW (
  X_COMPONENT_TYPE in VARCHAR2,
  X_COMPONENT_CLASS_NAME in VARCHAR2,
  X_CONFIG_UI_REGION in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      COMPONENT_CLASS_NAME,
      CONFIG_UI_REGION,
      CUSTOMIZATION_LEVEL,
      OBJECT_VERSION_NUMBER
    from FND_SVC_COMP_TYPES_B
    where COMPONENT_TYPE = X_COMPONENT_TYPE
    for update of COMPONENT_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_SVC_COMP_TYPES_TL
    where COMPONENT_TYPE = X_COMPONENT_TYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of COMPONENT_TYPE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    wf_core.raise('WF_RECORD_DELETED');
  end if;
  close c;
  if (    (recinfo.COMPONENT_CLASS_NAME = X_COMPONENT_CLASS_NAME)
      AND (recinfo.CONFIG_UI_REGION = X_CONFIG_UI_REGION)
      AND (recinfo.CUSTOMIZATION_LEVEL = X_CUSTOMIZATION_LEVEL)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    wf_core.raise('WF_RECORD_CHANGED');
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        wf_core.raise('WF_RECORD_CHANGED');
      end if;
    end if;
  end loop;
  return;

exception
  when others then
    wf_core.context('FND_SVC_COMP_TYPES_PKG', 'Lock_Row', X_COMPONENT_TYPE, X_COMPONENT_CLASS_NAME);
    raise;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_COMPONENT_TYPE in VARCHAR2,
  X_COMPONENT_CLASS_NAME in VARCHAR2,
  X_CONFIG_UI_REGION in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

  l_object_version_number NUMBER;
begin

  --
  -- Perform OVN checks
  --
  if X_OBJECT_VERSION_NUMBER = -1 then

    --
    -- Allow update.  Increment the database's OVN by 1
    --
    select OBJECT_VERSION_NUMBER
    into l_object_version_number
    from FND_SVC_COMP_TYPES_B
    where COMPONENT_TYPE = X_COMPONENT_TYPE;

    l_object_version_number := l_object_version_number + 1;

  else

    --
    -- Lock the row.  Allow update only if the database's OVN equals the one
    -- passed in.
    --
    -- If update is allowed, increment the database's OVN by 1.
    -- Otherwise, raise an error.
    --

    select OBJECT_VERSION_NUMBER
    into l_object_version_number
    from FND_SVC_COMP_TYPES_B
    where COMPONENT_TYPE = X_COMPONENT_TYPE
    for update;

    if (l_object_version_number = X_OBJECT_VERSION_NUMBER) then

        l_object_version_number := l_object_version_number + 1;
    else

      raise_application_error(-20002,
        wf_core.translate('SVC_RECORD_ALREADY_UPDATED'));

    end if;

  end if;

  update FND_SVC_COMP_TYPES_B set
    COMPONENT_CLASS_NAME = X_COMPONENT_CLASS_NAME,
    CONFIG_UI_REGION = X_CONFIG_UI_REGION,
    CUSTOMIZATION_LEVEL = X_CUSTOMIZATION_LEVEL,
    OBJECT_VERSION_NUMBER = l_object_version_number,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where COMPONENT_TYPE = X_COMPONENT_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_SVC_COMP_TYPES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where COMPONENT_TYPE = X_COMPONENT_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('FND_SVC_COMP_TYPES_PKG', 'Update_Row', X_COMPONENT_TYPE, X_COMPONENT_CLASS_NAME);
    raise;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_COMPONENT_TYPE in VARCHAR2
) is
begin
  delete from FND_SVC_COMP_TYPES_TL
  where COMPONENT_TYPE = X_COMPONENT_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_SVC_COMP_TYPES_B
  where COMPONENT_TYPE = X_COMPONENT_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

exception
  when others then
    wf_core.context('FND_SVC_COMP_TYPES_PKG', 'Delete_Row', X_COMPONENT_TYPE, ' ');
    raise;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from FND_SVC_COMP_TYPES_TL T
  where not exists
    (select NULL
    from FND_SVC_COMP_TYPES_B B
    where B.COMPONENT_TYPE = T.COMPONENT_TYPE
    );

  update FND_SVC_COMP_TYPES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from FND_SVC_COMP_TYPES_TL B
    where B.COMPONENT_TYPE = T.COMPONENT_TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.COMPONENT_TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.COMPONENT_TYPE,
      SUBT.LANGUAGE
    from FND_SVC_COMP_TYPES_TL SUBB, FND_SVC_COMP_TYPES_TL SUBT
    where SUBB.COMPONENT_TYPE = SUBT.COMPONENT_TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FND_SVC_COMP_TYPES_TL (
    COMPONENT_TYPE,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.COMPONENT_TYPE,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.CODE,
    B.SOURCE_LANG
  from FND_SVC_COMP_TYPES_TL B, WF_LANGUAGES L
  where L.INSTALLED_FLAG = 'Y'
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_SVC_COMP_TYPES_TL T
    where T.COMPONENT_TYPE = B.COMPONENT_TYPE
    and T.LANGUAGE = L.CODE);
end ADD_LANGUAGE;


procedure LOAD_ROW (
  X_COMPONENT_TYPE in VARCHAR2,
  X_COMPONENT_CLASS_NAME in VARCHAR2,
  X_CONFIG_UI_REGION in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
) IS

begin

    declare
        user_id            number := 0;
        row_id             varchar2(64);

    begin

        if (X_OWNER = 'ORACLE') then
        user_id := 1;
        end if;

        FND_SVC_COMP_TYPES_PKG.UPDATE_ROW (
        X_COMPONENT_TYPE => X_COMPONENT_TYPE,
        X_COMPONENT_CLASS_NAME => X_COMPONENT_CLASS_NAME,
        X_CONFIG_UI_REGION=> X_CONFIG_UI_REGION,
        X_CUSTOMIZATION_LEVEL => X_CUSTOMIZATION_LEVEL,
        X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
        X_DISPLAY_NAME => X_DISPLAY_NAME,
        X_DESCRIPTION => X_DESCRIPTION,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => user_id,
        X_LAST_UPDATE_LOGIN => 0);

    exception
        when NO_DATA_FOUND then

            FND_SVC_COMP_TYPES_PKG.INSERT_ROW (
                      X_ROWID => row_id,
            X_COMPONENT_TYPE => X_COMPONENT_TYPE,
            X_COMPONENT_CLASS_NAME => X_COMPONENT_CLASS_NAME,
              X_CONFIG_UI_REGION=> X_CONFIG_UI_REGION,
            X_CUSTOMIZATION_LEVEL => X_CUSTOMIZATION_LEVEL,
            X_DISPLAY_NAME => X_DISPLAY_NAME,
            X_DESCRIPTION => X_DESCRIPTION,
            X_CREATION_DATE => sysdate,
                      X_CREATED_BY => user_id,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY => user_id,
            X_LAST_UPDATE_LOGIN => 0);
    end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_COMPONENT_TYPE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) IS
BEGIN

    --
    -- Only update rows that have not been altered by user
    --
    UPDATE FND_SVC_COMP_TYPES_TL
    SET display_name = X_DISPLAY_NAME,
        description = X_DESCRIPTION,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
        last_updated_by = decode(X_OWNER, 'ORACLE', 1, 0),
        last_update_login = 0
    WHERE component_type = X_COMPONENT_TYPE
      AND userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;



end FND_SVC_COMP_TYPES_PKG;

/
