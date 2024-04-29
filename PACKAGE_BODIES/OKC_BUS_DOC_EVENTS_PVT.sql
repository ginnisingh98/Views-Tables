--------------------------------------------------------
--  DDL for Package Body OKC_BUS_DOC_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_BUS_DOC_EVENTS_PVT" as
/* $Header: OKCVBDEB.pls 120.0 2005/05/25 18:23:26 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_BUS_DOC_EVENT_ID in NUMBER,
  X_BUSINESS_EVENT_CODE in VARCHAR2,
  X_BUS_DOC_TYPE in VARCHAR2,
  X_BEFORE_AFTER in VARCHAR2,
  X_START_END_QUALIFIER in VARCHAR2,
  X_MEANING in VARCHAR2,
  --X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from OKC_BUS_DOC_EVENTS_B
    where BUS_DOC_EVENT_ID = X_BUS_DOC_EVENT_ID
    ;
begin
  insert into OKC_BUS_DOC_EVENTS_B (
    BUS_DOC_EVENT_ID,
    BUSINESS_EVENT_CODE,
    BUS_DOC_TYPE,
    BEFORE_AFTER,
    START_END_QUALIFIER,
    --OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_BUS_DOC_EVENT_ID,
    X_BUSINESS_EVENT_CODE,
    X_BUS_DOC_TYPE,
    X_BEFORE_AFTER,
    X_START_END_QUALIFIER,
    --X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into OKC_BUS_DOC_EVENTS_TL (
    LAST_UPDATE_LOGIN,
    BUS_DOC_EVENT_ID,
    SOURCE_LANG,
    MEANING,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LANGUAGE
  ) select
    X_LAST_UPDATE_LOGIN,
    X_BUS_DOC_EVENT_ID,
    userenv('LANG'),
    X_MEANING,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from OKC_BUS_DOC_EVENTS_TL T
    where T.BUS_DOC_EVENT_ID = X_BUS_DOC_EVENT_ID
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
  X_BUS_DOC_EVENT_ID in NUMBER,
  X_BUSINESS_EVENT_CODE in VARCHAR2,
  X_BUS_DOC_TYPE in VARCHAR2,
  X_BEFORE_AFTER in VARCHAR2,
  X_START_END_QUALIFIER in VARCHAR2,
  X_MEANING in VARCHAR2
  --X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      BUSINESS_EVENT_CODE,
      BUS_DOC_TYPE,
      BEFORE_AFTER,
      START_END_QUALIFIER
      --OBJECT_VERSION_NUMBER
    from OKC_BUS_DOC_EVENTS_B
    where BUS_DOC_EVENT_ID = X_BUS_DOC_EVENT_ID
    for update of BUS_DOC_EVENT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MEANING,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from OKC_BUS_DOC_EVENTS_TL
    where BUS_DOC_EVENT_ID = X_BUS_DOC_EVENT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of BUS_DOC_EVENT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
/*
  if  (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
   then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
*/

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.MEANING = X_MEANING)
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
  X_BUS_DOC_EVENT_ID in NUMBER,
  X_BUSINESS_EVENT_CODE in VARCHAR2,
  X_BUS_DOC_TYPE in VARCHAR2,
  X_BEFORE_AFTER in VARCHAR2,
  X_START_END_QUALIFIER in VARCHAR2,
  X_MEANING in VARCHAR2,
  --X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update OKC_BUS_DOC_EVENTS_B set
    BUS_DOC_EVENT_ID = X_BUS_DOC_EVENT_ID,
    BUSINESS_EVENT_CODE = X_BUSINESS_EVENT_CODE,
    BUS_DOC_TYPE = X_BUS_DOC_TYPE,
    BEFORE_AFTER = X_BEFORE_AFTER,
    START_END_QUALIFIER = X_START_END_QUALIFIER,
    --OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where BUS_DOC_EVENT_ID = X_BUS_DOC_EVENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update OKC_BUS_DOC_EVENTS_TL set
    MEANING = X_MEANING,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where BUS_DOC_EVENT_ID = X_BUS_DOC_EVENT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_BUS_DOC_EVENT_ID in NUMBER
) is
begin

  delete from OKC_BUS_DOC_EVENTS_TL
  where BUS_DOC_EVENT_ID = X_BUS_DOC_EVENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from OKC_BUS_DOC_EVENTS_B
  where BUS_DOC_EVENT_ID = X_BUS_DOC_EVENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from OKC_BUS_DOC_EVENTS_TL T
  where not exists
    (select NULL
    from OKC_BUS_DOC_EVENTS_B B
    where B.BUS_DOC_EVENT_ID = T.BUS_DOC_EVENT_ID
    );

  update OKC_BUS_DOC_EVENTS_TL T set (
      MEANING
    ) = (select
      B.MEANING
    from OKC_BUS_DOC_EVENTS_TL B
    where B.BUS_DOC_EVENT_ID = T.BUS_DOC_EVENT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.BUS_DOC_EVENT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.BUS_DOC_EVENT_ID,
      SUBT.LANGUAGE
    from OKC_BUS_DOC_EVENTS_TL SUBB, OKC_BUS_DOC_EVENTS_TL SUBT
    where SUBB.BUS_DOC_EVENT_ID = SUBT.BUS_DOC_EVENT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
  ));

  insert into OKC_BUS_DOC_EVENTS_TL (
    LAST_UPDATE_LOGIN,
    BUS_DOC_EVENT_ID,
    SOURCE_LANG,
    MEANING,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LANGUAGE
  ) select
    B.LAST_UPDATE_LOGIN,
    B.BUS_DOC_EVENT_ID,
    B.SOURCE_LANG,
    B.MEANING,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE
  from OKC_BUS_DOC_EVENTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OKC_BUS_DOC_EVENTS_TL T
    where T.BUS_DOC_EVENT_ID = B.BUS_DOC_EVENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



end OKC_BUS_DOC_EVENTS_PVT;

/
