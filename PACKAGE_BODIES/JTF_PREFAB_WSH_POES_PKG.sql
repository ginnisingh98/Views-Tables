--------------------------------------------------------
--  DDL for Package Body JTF_PREFAB_WSH_POES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PREFAB_WSH_POES_PKG" as
/* $Header: jtfprefabwshtb.pls 120.2 2005/10/28 00:25:02 emekala ship $ */
procedure INSERT_ROW (
  X_ROWID in out  NOCOPY  VARCHAR2,
  X_WSH_PO_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_HOSTNAME in VARCHAR2,
  X_WEIGHT in NUMBER,
  X_LOAD_PICK_UP_FLAG in VARCHAR2,
  X_CACHE_SIZE in NUMBER,
  X_WSH_TYPE in VARCHAR2,
  X_PREFAB_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_PREFAB_WSH_POES_B
    where WSH_PO_ID = X_WSH_PO_ID
    ;
begin
  insert into JTF_PREFAB_WSH_POES_B (
    WSH_PO_ID,
    OBJECT_VERSION_NUMBER,
    -- SECURITY_GROUP_ID,
    HOSTNAME,
    WEIGHT,
    LOAD_PICK_UP_FLAG,
    CACHE_SIZE,
    WSH_TYPE,
    PREFAB_ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_WSH_PO_ID,
    X_OBJECT_VERSION_NUMBER,
    -- X_SECURITY_GROUP_ID,
    X_HOSTNAME,
    X_WEIGHT,
    X_LOAD_PICK_UP_FLAG,
    X_CACHE_SIZE,
    X_WSH_TYPE,
    X_PREFAB_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_PREFAB_WSH_POES_TL (
    WSH_PO_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    -- SECURITY_GROUP_ID,
    PWPB_WSH_PO_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_WSH_PO_ID,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    -- X_SECURITY_GROUP_ID,
    X_WSH_PO_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_PREFAB_WSH_POES_TL T
    where T.WSH_PO_ID = X_WSH_PO_ID
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
  X_WSH_PO_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_HOSTNAME in VARCHAR2,
  X_WEIGHT in NUMBER,
  X_LOAD_PICK_UP_FLAG in VARCHAR2,
  X_CACHE_SIZE in NUMBER,
  X_WSH_TYPE in VARCHAR2,
  X_PREFAB_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      SECURITY_GROUP_ID,
      HOSTNAME,
      WEIGHT,
      LOAD_PICK_UP_FLAG,
      CACHE_SIZE,
      WSH_TYPE,
      PREFAB_ENABLED_FLAG
    from JTF_PREFAB_WSH_POES_B
    where WSH_PO_ID = X_WSH_PO_ID
    for update of WSH_PO_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_PREFAB_WSH_POES_TL
    where WSH_PO_ID = X_WSH_PO_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of WSH_PO_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      -- AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
      --     OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND (recinfo.HOSTNAME = X_HOSTNAME)
      AND (recinfo.WEIGHT = X_WEIGHT)
      AND (recinfo.LOAD_PICK_UP_FLAG = X_LOAD_PICK_UP_FLAG)
      AND (recinfo.CACHE_SIZE = X_CACHE_SIZE)
      AND (recinfo.WSH_TYPE = X_WSH_TYPE)
      AND (recinfo.PREFAB_ENABLED_FLAG = X_PREFAB_ENABLED_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_WSH_PO_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_HOSTNAME in VARCHAR2,
  X_WEIGHT in NUMBER,
  X_LOAD_PICK_UP_FLAG in VARCHAR2,
  X_CACHE_SIZE in NUMBER,
  X_WSH_TYPE in VARCHAR2,
  X_PREFAB_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_PREFAB_WSH_POES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    -- SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    HOSTNAME = X_HOSTNAME,
    WEIGHT = X_WEIGHT,
    LOAD_PICK_UP_FLAG = X_LOAD_PICK_UP_FLAG,
    CACHE_SIZE = X_CACHE_SIZE,
    WSH_TYPE = X_WSH_TYPE,
    PREFAB_ENABLED_FLAG = X_PREFAB_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where WSH_PO_ID = X_WSH_PO_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_PREFAB_WSH_POES_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where WSH_PO_ID = X_WSH_PO_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_WSH_PO_ID in NUMBER
) is
begin
  delete from JTF_PREFAB_WSH_POES_TL
  where WSH_PO_ID = X_WSH_PO_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_PREFAB_WSH_POES_B
  where WSH_PO_ID = X_WSH_PO_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_PREFAB_WSH_POES_TL T
  where not exists
    (select NULL
    from JTF_PREFAB_WSH_POES_B B
    where B.WSH_PO_ID = T.WSH_PO_ID
    );

  update JTF_PREFAB_WSH_POES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from JTF_PREFAB_WSH_POES_TL B
    where B.WSH_PO_ID = T.WSH_PO_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.WSH_PO_ID,
      T.LANGUAGE
  ) in (select
      SUBT.WSH_PO_ID,
      SUBT.LANGUAGE
    from JTF_PREFAB_WSH_POES_TL SUBB, JTF_PREFAB_WSH_POES_TL SUBT
    where SUBB.WSH_PO_ID = SUBT.WSH_PO_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into JTF_PREFAB_WSH_POES_TL (
    WSH_PO_ID,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    -- SECURITY_GROUP_ID,
    PWPB_WSH_PO_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.WSH_PO_ID,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    -- B.SECURITY_GROUP_ID,
    B.WSH_PO_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_PREFAB_WSH_POES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_PREFAB_WSH_POES_TL T
    where T.WSH_PO_ID = B.WSH_PO_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end JTF_PREFAB_WSH_POES_PKG;

/
