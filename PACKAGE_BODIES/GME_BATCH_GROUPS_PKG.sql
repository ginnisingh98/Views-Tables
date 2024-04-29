--------------------------------------------------------
--  DDL for Package Body GME_BATCH_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_BATCH_GROUPS_PKG" as
/* $Header: GMEVGBGB.pls 120.0 2007/12/10 20:25:30 adeshmuk noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_GROUP_NAME in VARCHAR2,
  X_ORGANIZATION_ID in NUMBER,
  X_GROUP_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GME_BATCH_GROUPS_B
    where GROUP_ID = X_GROUP_ID
    ;
begin
  insert into GME_BATCH_GROUPS_B (
    GROUP_ID,
    GROUP_NAME,
    ORGANIZATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_GROUP_ID,
    X_GROUP_NAME,
    X_ORGANIZATION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GME_BATCH_GROUPS_TL (
    LAST_UPDATE_LOGIN,
    GROUP_ID,
    GROUP_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_GROUP_ID,
    X_GROUP_DESC,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GME_BATCH_GROUPS_TL T
    where T.GROUP_ID = X_GROUP_ID
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
  X_GROUP_ID in NUMBER,
  X_GROUP_NAME in VARCHAR2,
  X_ORGANIZATION_ID in NUMBER,
  X_GROUP_DESC in VARCHAR2
) is
  cursor c is select
      GROUP_NAME,
      ORGANIZATION_ID
    from GME_BATCH_GROUPS_B
    where GROUP_ID = X_GROUP_ID
    for update of GROUP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      GROUP_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GME_BATCH_GROUPS_TL
    where GROUP_ID = X_GROUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of GROUP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.GROUP_NAME = X_GROUP_NAME)
      AND ((recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
           OR ((recinfo.ORGANIZATION_ID is null) AND (X_ORGANIZATION_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.GROUP_DESC = X_GROUP_DESC)
               OR ((tlinfo.GROUP_DESC is null) AND (X_GROUP_DESC is null)))
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
  X_GROUP_ID in NUMBER,
  X_GROUP_NAME in VARCHAR2,
  X_ORGANIZATION_ID in NUMBER,
  X_GROUP_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GME_BATCH_GROUPS_B set
    GROUP_NAME = X_GROUP_NAME,
    ORGANIZATION_ID = X_ORGANIZATION_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where GROUP_ID = X_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GME_BATCH_GROUPS_TL set
    GROUP_DESC = X_GROUP_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where GROUP_ID = X_GROUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_GROUP_ID in NUMBER
) is
begin
  delete from GME_BATCH_GROUPS_TL
  where GROUP_ID = X_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GME_BATCH_GROUPS_B
  where GROUP_ID = X_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GME_BATCH_GROUPS_TL T
  where not exists
    (select NULL
    from GME_BATCH_GROUPS_B B
    where B.GROUP_ID = T.GROUP_ID
    );

  update GME_BATCH_GROUPS_TL T set (
      GROUP_DESC
    ) = (select
      B.GROUP_DESC
    from GME_BATCH_GROUPS_TL B
    where B.GROUP_ID = T.GROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.GROUP_ID,
      SUBT.LANGUAGE
    from GME_BATCH_GROUPS_TL SUBB, GME_BATCH_GROUPS_TL SUBT
    where SUBB.GROUP_ID = SUBT.GROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.GROUP_DESC <> SUBT.GROUP_DESC
      or (SUBB.GROUP_DESC is null and SUBT.GROUP_DESC is not null)
      or (SUBB.GROUP_DESC is not null and SUBT.GROUP_DESC is null)
  ));

  insert into GME_BATCH_GROUPS_TL (
    LAST_UPDATE_LOGIN,
    GROUP_ID,
    GROUP_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATE_LOGIN,
    B.GROUP_ID,
    B.GROUP_DESC,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GME_BATCH_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GME_BATCH_GROUPS_TL T
    where T.GROUP_ID = B.GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end GME_BATCH_GROUPS_PKG;

/
