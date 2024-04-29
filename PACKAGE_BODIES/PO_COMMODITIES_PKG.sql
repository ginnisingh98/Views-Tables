--------------------------------------------------------
--  DDL for Package Body PO_COMMODITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COMMODITIES_PKG" as
/* $Header: POXCOBJB.pls 115.0 2003/06/05 22:29:10 jazhang noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COMMODITY_ID in NUMBER,
  X_COMMODITY_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PO_COMMODITIES_B
    where COMMODITY_ID = X_COMMODITY_ID
    ;
begin
  insert into PO_COMMODITIES_B (
    COMMODITY_ID,
    COMMODITY_CODE,
    ACTIVE_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_COMMODITY_ID,
    X_COMMODITY_CODE,
    X_ACTIVE_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PO_COMMODITIES_TL (
    COMMODITY_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_COMMODITY_ID,
    X_NAME,
    X_DESCRIPTION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PO_COMMODITIES_TL T
    where T.COMMODITY_ID = X_COMMODITY_ID
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
  X_COMMODITY_ID in NUMBER,
  X_COMMODITY_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      COMMODITY_CODE,
      ACTIVE_FLAG
    from PO_COMMODITIES_B
    where COMMODITY_ID = X_COMMODITY_ID
    for update of COMMODITY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PO_COMMODITIES_TL
    where COMMODITY_ID = X_COMMODITY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of COMMODITY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.COMMODITY_CODE = X_COMMODITY_CODE)
      AND (recinfo.ACTIVE_FLAG = X_ACTIVE_FLAG)
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
  X_COMMODITY_ID in NUMBER,
  X_COMMODITY_CODE in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PO_COMMODITIES_B set
    COMMODITY_CODE = X_COMMODITY_CODE,
    ACTIVE_FLAG = X_ACTIVE_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where COMMODITY_ID = X_COMMODITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PO_COMMODITIES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where COMMODITY_ID = X_COMMODITY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_COMMODITY_ID in NUMBER
) is
begin
  delete from PO_COMMODITIES_TL
  where COMMODITY_ID = X_COMMODITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PO_COMMODITIES_B
  where COMMODITY_ID = X_COMMODITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PO_COMMODITIES_TL T
  where not exists
    (select NULL
    from PO_COMMODITIES_B B
    where B.COMMODITY_ID = T.COMMODITY_ID
    );

  update PO_COMMODITIES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from PO_COMMODITIES_TL B
    where B.COMMODITY_ID = T.COMMODITY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.COMMODITY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.COMMODITY_ID,
      SUBT.LANGUAGE
    from PO_COMMODITIES_TL SUBB, PO_COMMODITIES_TL SUBT
    where SUBB.COMMODITY_ID = SUBT.COMMODITY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PO_COMMODITIES_TL (
    COMMODITY_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.COMMODITY_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PO_COMMODITIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PO_COMMODITIES_TL T
    where T.COMMODITY_ID = B.COMMODITY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end PO_COMMODITIES_PKG;

/
