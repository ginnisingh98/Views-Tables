--------------------------------------------------------
--  DDL for Package Body XDO_CURRENCY_FORMAT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_CURRENCY_FORMAT_SETS_PKG" as
/* $Header: XDOCURFB.pls 120.1 2005/12/27 12:08:57 bgkim noship $ */

procedure INSERT_ROW (
          P_FORMAT_SET_CODE in VARCHAR2,
          P_FORMAT_SET_NAME in VARCHAR2,
          P_CREATION_DATE in DATE,
          P_CREATED_BY in NUMBER,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into XDO_CURRENCY_FORMAT_SETS_B (
          FORMAT_SET_CODE,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN
  ) values (
          P_FORMAT_SET_CODE,
          P_CREATION_DATE,
          P_CREATED_BY,
          P_LAST_UPDATE_DATE,
          P_LAST_UPDATED_BY,
          P_LAST_UPDATE_LOGIN
  );

  insert into XDO_CURRENCY_FORMAT_SETS_TL (
    FORMAT_SET_CODE,
    FORMAT_SET_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select P_FORMAT_SET_CODE,
           P_FORMAT_SET_NAME,
           P_CREATION_DATE,
           P_CREATED_BY,
           P_LAST_UPDATE_DATE,
           P_LAST_UPDATED_BY,
           P_LAST_UPDATE_LOGIN,
           L.LANGUAGE_CODE,
           userenv('LANG')
     from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
      and not exists
          (select NULL
             from XDO_CURRENCY_FORMAT_SETS_TL T
            where T.FORMAT_SET_CODE = P_FORMAT_SET_CODE
              and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;


procedure UPDATE_ROW (
          P_FORMAT_SET_CODE in VARCHAR2,
          P_FORMAT_SET_NAME in VARCHAR2,
          P_LAST_UPDATE_DATE in DATE,
          P_LAST_UPDATED_BY in NUMBER,
          P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDO_CURRENCY_FORMAT_SETS_B
     set LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
         LAST_UPDATED_BY = P_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where FORMAT_SET_CODE = P_FORMAT_SET_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XDO_CURRENCY_FORMAT_SETS_TL set
    FORMAT_SET_NAME = P_FORMAT_SET_NAME,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FORMAT_SET_CODE = P_FORMAT_SET_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure ADD_LANGUAGE is
begin
  insert into XDO_CURRENCY_FORMAT_SETS_TL (
    FORMAT_SET_CODE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.FORMAT_SET_CODE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDO_CURRENCY_FORMAT_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDO_CURRENCY_FORMAT_SETS_TL T
    where T.FORMAT_SET_CODE = B.FORMAT_SET_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end XDO_CURRENCY_FORMAT_SETS_PKG;

/
