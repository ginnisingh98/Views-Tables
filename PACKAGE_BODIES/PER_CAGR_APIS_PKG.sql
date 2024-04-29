--------------------------------------------------------
--  DDL for Package Body PER_CAGR_APIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAGR_APIS_PKG" as
/* $Header: peapilct.pkb 120.1 2006/06/20 09:24:40 bshukla noship $ */

procedure KEY_TO_IDS (
  X_API_NAME  in VARCHAR2,
  X_CAGR_API_ID out nocopy NUMBER

) is

  cursor CSR_CAGR_API_NAME (
    X_API_NAME VARCHAR2
    ) is
    select API.CAGR_API_ID
    from PER_CAGR_APIS API
    where API.API_NAME = X_API_NAME;

  cursor CSR_SEQUENCE is
    select PER_CAGR_APIS_S.nextval
    from   dual;

begin

  open CSR_CAGR_API_NAME (    X_API_NAME );
  fetch CSR_CAGR_API_NAME into X_CAGR_API_ID;
  if (CSR_CAGR_API_NAME%notfound) then
    open CSR_SEQUENCE;
    fetch CSR_SEQUENCE into X_CAGR_API_ID;
    close CSR_SEQUENCE;
  end if;
  close CSR_CAGR_API_NAME;
end KEY_TO_IDS;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_CAGR_API_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_API_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PER_CAGR_APIS
    where CAGR_API_ID = X_CAGR_API_ID
    ;
begin
  insert into PER_CAGR_APIS (
    OBJECT_VERSION_NUMBER,
    CATEGORY_NAME,
    API_NAME,
    CAGR_API_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_VERSION_NUMBER,
    X_CATEGORY_NAME,
    X_API_NAME,
    X_CAGR_API_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PER_CAGR_APIS_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CAGR_API_ID,
    API_NAME,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CAGR_API_ID,
    X_API_NAME,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PER_CAGR_APIS_TL T
    where T.CAGR_API_ID = X_CAGR_API_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure TRANSLATE_ROW (
  X_API_NAME1                 in VARCHAR2 default null,
  X_API_NAME                  in VARCHAR2,
  X_OWNER                     in VARCHAR2
   ) is
X_CAGR_API_ID NUMBER;

begin

 KEY_TO_IDS (
    X_API_NAME1,
    X_CAGR_API_ID
  );


  update per_cagr_apis_tl set
    api_name           = X_API_NAME,
    last_update_date  = sysdate,
    last_updated_by   = decode(X_OWNER, 'SEED', 1, 0),
    last_update_login = 0,
    source_lang       = userenv('LANG')
  where cagr_api_id   = X_CAGR_API_ID
  and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;


procedure LOAD_ROW (
  X_API_NAME                  in VARCHAR2,
  X_CATEGORY_NAME 	      in VARCHAR2,
  X_OWNER                     in VARCHAR2,
  X_OBJECT_VERSION_NUMBER     in NUMBER) is

  X_ROW_ID ROWID;
  user_id number := 0;
  X_CAGR_API_ID NUMBER;

begin

 KEY_TO_IDS (
    X_API_NAME,
    X_CAGR_API_ID
  );

if (X_OWNER = 'SEED') then
    user_id := 1;
  else
    user_id := 0;
  end if;

PER_CAGR_APIS_PKG.UPDATE_ROW (
  X_CAGR_API_ID => X_CAGR_API_ID,
  X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
  X_CATEGORY_NAME => X_CATEGORY_NAME,
  X_API_NAME => X_API_NAME,
  X_LAST_UPDATE_DATE => SYSDATE,
  X_LAST_UPDATED_BY => USER_ID,
  X_LAST_UPDATE_LOGIN => 0);

exception
  when NO_DATA_FOUND then


PER_CAGR_APIS_PKG.INSERT_ROW(
  X_ROWID => X_ROW_ID,
  X_CAGR_API_ID => X_CAGR_API_ID,
  X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
  X_CATEGORY_NAME => X_CATEGORY_NAME,
  X_API_NAME => X_API_NAME,
  X_CREATION_DATE => SYSDATE,
  X_CREATED_BY => USER_ID,
  X_LAST_UPDATE_DATE => SYSDATE,
  X_LAST_UPDATED_BY => USER_ID,
  X_LAST_UPDATE_LOGIN => 0);

end LOAD_ROW;


procedure LOCK_ROW (
  X_CAGR_API_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_API_NAME in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      CATEGORY_NAME
    from PER_CAGR_APIS
    where CAGR_API_ID = X_CAGR_API_ID
    for update of CAGR_API_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      API_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PER_CAGR_APIS_TL
    where CAGR_API_ID = X_CAGR_API_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CAGR_API_ID nowait;
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
      AND (recinfo.CATEGORY_NAME = X_CATEGORY_NAME)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.API_NAME = X_API_NAME)
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
  X_CAGR_API_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_API_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PER_CAGR_APIS set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    CATEGORY_NAME = X_CATEGORY_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CAGR_API_ID = X_CAGR_API_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PER_CAGR_APIS_TL set
    API_NAME = X_API_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CAGR_API_ID = X_CAGR_API_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CAGR_API_ID in NUMBER
) is
begin
  delete from PER_CAGR_APIS_TL
  where CAGR_API_ID = X_CAGR_API_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PER_CAGR_APIS
  where CAGR_API_ID = X_CAGR_API_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PER_CAGR_APIS_TL T
  where not exists
    (select NULL
    from PER_CAGR_APIS B
    where B.CAGR_API_ID = T.CAGR_API_ID
    );

  update PER_CAGR_APIS_TL T set (
      API_NAME
    ) = (select
      B.API_NAME
    from PER_CAGR_APIS_TL B
    where B.CAGR_API_ID = T.CAGR_API_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CAGR_API_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CAGR_API_ID,
      SUBT.LANGUAGE
    from PER_CAGR_APIS_TL SUBB, PER_CAGR_APIS_TL SUBT
    where SUBB.CAGR_API_ID = SUBT.CAGR_API_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.API_NAME <> SUBT.API_NAME
  ));

  insert into PER_CAGR_APIS_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CAGR_API_ID,
    API_NAME,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CAGR_API_ID,
    B.API_NAME,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_CAGR_APIS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_CAGR_APIS_TL T
    where T.CAGR_API_ID = B.CAGR_API_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


end PER_CAGR_APIS_PKG;

/
