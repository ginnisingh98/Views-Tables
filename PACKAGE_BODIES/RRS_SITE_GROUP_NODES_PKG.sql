--------------------------------------------------------
--  DDL for Package Body RRS_SITE_GROUP_NODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_SITE_GROUP_NODES_PKG" as
/* $Header: RRSSGNPB.pls 120.1 2005/09/30 00:42 swbhatna noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_SITE_GROUP_NODE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

  L_SITE_GROUP_NODE_ID NUMBER;

  cursor C is select ROWID from RRS_SITE_GROUP_NODES_B
    where SITE_GROUP_NODE_ID = L_SITE_GROUP_NODE_ID;

  begin

  select nvl(X_SITE_GROUP_NODE_ID ,RRS_SITES_S.nextval)
  into   L_SITE_GROUP_NODE_ID
  from   dual;

  insert into RRS_SITE_GROUP_NODES_B (
    SITE_GROUP_NODE_ID,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    L_SITE_GROUP_NODE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into RRS_SITE_GROUP_NODES_TL (
    SITE_GROUP_NODE_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    L_SITE_GROUP_NODE_ID,
    X_NAME,
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
    from RRS_SITE_GROUP_NODES_TL T
    where T.SITE_GROUP_NODE_ID = L_SITE_GROUP_NODE_ID
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
  X_SITE_GROUP_NODE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from RRS_SITE_GROUP_NODES_B
    where SITE_GROUP_NODE_ID = X_SITE_GROUP_NODE_ID
    for update of SITE_GROUP_NODE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from RRS_SITE_GROUP_NODES_TL
    where SITE_GROUP_NODE_ID = X_SITE_GROUP_NODE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SITE_GROUP_NODE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
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
  X_SITE_GROUP_NODE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update RRS_SITE_GROUP_NODES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SITE_GROUP_NODE_ID = X_SITE_GROUP_NODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update RRS_SITE_GROUP_NODES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SITE_GROUP_NODE_ID = X_SITE_GROUP_NODE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SITE_GROUP_NODE_ID in NUMBER
) is
begin
  delete from RRS_SITE_GROUP_NODES_TL
  where SITE_GROUP_NODE_ID = X_SITE_GROUP_NODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from RRS_SITE_GROUP_NODES_B
  where SITE_GROUP_NODE_ID = X_SITE_GROUP_NODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from RRS_SITE_GROUP_NODES_TL T
  where not exists
    (select NULL
    from RRS_SITE_GROUP_NODES_B B
    where B.SITE_GROUP_NODE_ID = T.SITE_GROUP_NODE_ID
    );

  update RRS_SITE_GROUP_NODES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from RRS_SITE_GROUP_NODES_TL B
    where B.SITE_GROUP_NODE_ID = T.SITE_GROUP_NODE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SITE_GROUP_NODE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SITE_GROUP_NODE_ID,
      SUBT.LANGUAGE
    from RRS_SITE_GROUP_NODES_TL SUBB, RRS_SITE_GROUP_NODES_TL SUBT
    where SUBB.SITE_GROUP_NODE_ID = SUBT.SITE_GROUP_NODE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into RRS_SITE_GROUP_NODES_TL (
    SITE_GROUP_NODE_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.SITE_GROUP_NODE_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from RRS_SITE_GROUP_NODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from RRS_SITE_GROUP_NODES_TL T
    where T.SITE_GROUP_NODE_ID = B.SITE_GROUP_NODE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end RRS_SITE_GROUP_NODES_PKG;

/
