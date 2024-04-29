--------------------------------------------------------
--  DDL for Package Body OKC_RISK_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RISK_EVENTS_PKG" as
/* $Header: OKCRISKEVTB.pls 120.1 2005/10/03 18:56:22 amakalin noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RISK_EVENT_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from OKC_RISK_EVENTS_B
    where RISK_EVENT_ID = X_RISK_EVENT_ID
    ;
begin
  insert into OKC_RISK_EVENTS_B (
    RISK_EVENT_ID,
    START_DATE,
    END_DATE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RISK_EVENT_ID,
    X_START_DATE,
    X_END_DATE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into OKC_RISK_EVENTS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    RISK_EVENT_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_RISK_EVENT_ID,
    X_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from OKC_RISK_EVENTS_TL T
    where T.RISK_EVENT_ID = X_RISK_EVENT_ID
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
  X_RISK_EVENT_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      START_DATE,
      END_DATE,
      OBJECT_VERSION_NUMBER
    from OKC_RISK_EVENTS_B
    where RISK_EVENT_ID = X_RISK_EVENT_ID
    for update of RISK_EVENT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from OKC_RISK_EVENTS_TL
    where RISK_EVENT_ID = X_RISK_EVENT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RISK_EVENT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.START_DATE = X_START_DATE)
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
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
  X_RISK_EVENT_ID in NUMBER,
  X_START_DATE in DATE,
  X_END_DATE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update OKC_RISK_EVENTS_B set
    START_DATE = X_START_DATE,
    END_DATE = X_END_DATE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RISK_EVENT_ID = X_RISK_EVENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update OKC_RISK_EVENTS_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RISK_EVENT_ID = X_RISK_EVENT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RISK_EVENT_ID in NUMBER
) is
begin
  delete from OKC_RISK_EVENTS_TL
  where RISK_EVENT_ID = X_RISK_EVENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from OKC_RISK_EVENTS_B
  where RISK_EVENT_ID = X_RISK_EVENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from OKC_RISK_EVENTS_TL T
  where not exists
    (select NULL
    from OKC_RISK_EVENTS_B B
    where B.RISK_EVENT_ID = T.RISK_EVENT_ID
    );

  update OKC_RISK_EVENTS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from OKC_RISK_EVENTS_TL B
    where B.RISK_EVENT_ID = T.RISK_EVENT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RISK_EVENT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RISK_EVENT_ID,
      SUBT.LANGUAGE
    from OKC_RISK_EVENTS_TL SUBB, OKC_RISK_EVENTS_TL SUBT
    where SUBB.RISK_EVENT_ID = SUBT.RISK_EVENT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into OKC_RISK_EVENTS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    RISK_EVENT_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.RISK_EVENT_ID,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OKC_RISK_EVENTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OKC_RISK_EVENTS_TL T
    where T.RISK_EVENT_ID = B.RISK_EVENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end OKC_RISK_EVENTS_PKG;

/
