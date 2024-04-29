--------------------------------------------------------
--  DDL for Package Body ICX_CAT_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_CATEGORIES_PKG" AS
/* $Header: ICXCATIB.pls 120.1 2005/06/30 04:45:49 srmani noship $ */

procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_RT_CATEGORY_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_UPPER_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TYPE in NUMBER,
  X_KEY in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_ITEM_COUNT in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) is
  cursor C is select ROWID from ICX_CAT_CATEGORIES_TL
    where RT_CATEGORY_ID = X_RT_CATEGORY_ID
    and LANGUAGE = userenv('LANG');
begin
  insert into ICX_CAT_CATEGORIES_TL (
    RT_CATEGORY_ID,
    CATEGORY_NAME,
    UPPER_CATEGORY_NAME,
    DESCRIPTION,
    TYPE,
    KEY,
    UPPER_KEY,
    TITLE,
    ITEM_COUNT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_RT_CATEGORY_ID,
    X_CATEGORY_NAME,
    upper(X_CATEGORY_NAME),
    X_DESCRIPTION,
    X_TYPE,
    X_KEY,
    upper(X_KEY),
    X_TITLE,
    X_ITEM_COUNT,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_PROGRAM_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ICX_CAT_CATEGORIES_TL T
    where T.RT_CATEGORY_ID = X_RT_CATEGORY_ID
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
  X_RT_CATEGORY_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_UPPER_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TYPE in NUMBER,
  X_KEY in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_ITEM_COUNT in NUMBER
) is
  cursor c1 is select
      RT_CATEGORY_ID,
      CATEGORY_NAME,
      UPPER_CATEGORY_NAME,
      DESCRIPTION,
      TYPE,
      KEY,
      TITLE,
      ITEM_COUNT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ICX_CAT_CATEGORIES_TL
    where RT_CATEGORY_ID = X_RT_CATEGORY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RT_CATEGORY_ID nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CATEGORY_NAME = X_CATEGORY_NAME)
          AND (tlinfo.UPPER_CATEGORY_NAME = X_UPPER_CATEGORY_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND (tlinfo.TYPE = X_TYPE)
          AND (tlinfo.KEY = X_KEY)
          AND ((tlinfo.TITLE = X_TITLE)
               OR ((tlinfo.TITLE is null) AND (X_TITLE is null)))
          AND ((tlinfo.ITEM_COUNT = X_ITEM_COUNT)
               OR ((tlinfo.ITEM_COUNT is null) AND (X_ITEM_COUNT is null)))
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
  X_RT_CATEGORY_ID in NUMBER,
  X_CATEGORY_NAME in VARCHAR2,
  X_UPPER_CATEGORY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TYPE in NUMBER,
  X_KEY in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_ITEM_COUNT in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) is
begin
  update ICX_CAT_CATEGORIES_TL set
    CATEGORY_NAME = X_CATEGORY_NAME,
    UPPER_CATEGORY_NAME = upper(X_CATEGORY_NAME),
    DESCRIPTION = X_DESCRIPTION,
    TYPE = X_TYPE,
    KEY = X_KEY,
    UPPER_KEY = upper(X_KEY),
    TITLE = X_TITLE,
    ITEM_COUNT = X_ITEM_COUNT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    SOURCE_LANG = userenv('LANG')
  where RT_CATEGORY_ID = X_RT_CATEGORY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RT_CATEGORY_ID in NUMBER
) is
begin
  delete from ICX_CAT_CATEGORIES_TL
  where RT_CATEGORY_ID = X_RT_CATEGORY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


procedure TRANSLATE_ROW(
      X_RT_CATEGORY_ID      in  VARCHAR2,
      X_OWNER		    in  VARCHAR2,
      X_CATEGORY_NAME       in  VARCHAR2,
      X_UPPER_CATEGORY_NAME in  VARCHAR2,
      X_DESCRIPTION         in  VARCHAR2 ) IS
begin

   update ICX_CAT_CATEGORIES_tl set
     category_name       = X_CATEGORY_NAME,
     upper_category_name = upper(X_CATEGORY_NAME),
     description         = X_DESCRIPTION,
     last_update_date    = sysdate,
     last_updated_by     = decode(X_OWNER, 'SEED', -1, 0),
     last_update_login   = 0,
     source_lang         = userenv('LANG')
   where RT_CATEGORY_ID  = to_number(X_RT_CATEGORY_ID)
     and userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;


procedure LOAD_ROW(
      X_RT_CATEGORY_ID      in  VARCHAR2,
      X_OWNER		    in  VARCHAR2,
      X_CATEGORY_NAME       in  VARCHAR2,
      X_UPPER_CATEGORY_NAME in  VARCHAR2,
      X_DESCRIPTION         in  VARCHAR2,
      X_TYPE                in  VARCHAR2,
      X_KEY                 in  VARCHAR2,
      X_TITLE               in  VARCHAR2,
      X_ITEM_COUNT          in  VARCHAR2 ) IS
begin

  declare
     user_id    number := 0;
     row_id     varchar2(64);

  begin

     if (X_OWNER = 'SEED') then
       user_id := 1;
     end if;

     ICX_CAT_CATEGORIES_PKG.UPDATE_ROW (
	X_RT_CATEGORY_ID =>		to_number(X_RT_CATEGORY_ID),
	X_CATEGORY_NAME =>		X_CATEGORY_NAME,
	X_UPPER_CATEGORY_NAME =>	X_UPPER_CATEGORY_NAME,
	X_DESCRIPTION =>		X_DESCRIPTION,
	X_TYPE =>			to_number(X_TYPE),
	X_KEY =>			X_KEY,
	X_TITLE =>			X_TITLE,
	X_ITEM_COUNT =>			to_number(X_ITEM_COUNT),
        X_LAST_UPDATE_DATE =>		sysdate,
	X_LAST_UPDATED_BY =>		user_id,
	X_LAST_UPDATE_LOGIN =>		0,
	X_REQUEST_ID =>			null,
	X_PROGRAM_APPLICATION_ID => 	null,
	X_PROGRAM_ID =>			null,
	X_PROGRAM_UPDATE_DATE =>	null);

  exception
     when NO_DATA_FOUND then

       ICX_CAT_CATEGORIES_PKG.INSERT_ROW (
          X_ROWID =>                    row_id,
	  X_RT_CATEGORY_ID =>		to_number(X_RT_CATEGORY_ID),
	  X_CATEGORY_NAME =>		X_CATEGORY_NAME,
	  X_UPPER_CATEGORY_NAME =>	X_UPPER_CATEGORY_NAME,
	  X_DESCRIPTION =>		X_DESCRIPTION,
	  X_TYPE =>			to_number(X_TYPE),
	  X_KEY =>			X_KEY,
	  X_TITLE =>			X_TITLE,
	  X_ITEM_COUNT =>		to_number(X_ITEM_COUNT),
	  X_CREATION_DATE =>		sysdate,
	  X_CREATED_BY =>		user_id,
	  X_LAST_UPDATE_DATE =>		sysdate,
	  X_LAST_UPDATED_BY =>		user_id,
	  X_LAST_UPDATE_LOGIN =>	0,
	  X_REQUEST_ID =>		null,
	  X_PROGRAM_APPLICATION_ID =>   null,
	  X_PROGRAM_ID =>		null,
	  X_PROGRAM_UPDATE_DATE =>      null);
   end;
end LOAD_ROW;


procedure ADD_LANGUAGE
is
begin
  /* comment out for bug 2085107
  update ICX_CAT_CATEGORIES_TL T set (
      CATEGORY_NAME,
      UPPER_CATEGORY_NAME,
      DESCRIPTION
    ) = (select
      B.CATEGORY_NAME,
      upper(B.CATEGORY_NAME),
      B.DESCRIPTION
    from ICX_CAT_CATEGORIES_TL B
    where B.RT_CATEGORY_ID = T.RT_CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RT_CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RT_CATEGORY_ID,
      SUBT.LANGUAGE
    from ICX_CAT_CATEGORIES_TL SUBB, ICX_CAT_CATEGORIES_TL SUBT
    where SUBB.RT_CATEGORY_ID = SUBT.RT_CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CATEGORY_NAME <> SUBT.CATEGORY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
  */

  insert into ICX_CAT_CATEGORIES_TL (
    RT_CATEGORY_ID,
    CATEGORY_NAME,
    UPPER_CATEGORY_NAME,
    DESCRIPTION,
    TYPE,
    KEY,
    UPPER_KEY,
    TITLE,
    ITEM_COUNT,
    SECTION_MAP,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.RT_CATEGORY_ID,
    B.CATEGORY_NAME,
    upper(B.CATEGORY_NAME),
    B.DESCRIPTION,
    B.TYPE,
    B.KEY,
    upper(B.KEY),
    B.TITLE,
    B.ITEM_COUNT,
    B.SECTION_MAP,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.REQUEST_ID,
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_ID,
    B.PROGRAM_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ICX_CAT_CATEGORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ICX_CAT_CATEGORIES_TL T
    where T.RT_CATEGORY_ID = B.RT_CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


end ICX_CAT_CATEGORIES_PKG;

/
