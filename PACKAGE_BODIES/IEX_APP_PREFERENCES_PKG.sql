--------------------------------------------------------
--  DDL for Package Body IEX_APP_PREFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_APP_PREFERENCES_PKG" as
/* $Header: iextappb.pls 120.0 2004/01/24 03:21:04 appldev noship $ */

PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

procedure ADD_LANGUAGE
is
begin
  delete from IEX_APP_PREFERENCES_TL T
  where not exists
    (select NULL
     from IEX_APP_PREFERENCES_B B
     where B.PREFERENCE_ID = T.PREFERENCE_ID
    );

  update IEX_APP_PREFERENCES_TL T
        set (USER_NAME) =
             (select B.USER_NAME
              from IEX_APP_PREFERENCES_TL B
              where B.PREFERENCE_ID = T.PREFERENCE_ID
              and B.LANGUAGE = T.SOURCE_LANG)
        where (
              T.PREFERENCE_ID,T.LANGUAGE
               ) in (select
                       SUBT.PREFERENCE_ID,
                       SUBT.LANGUAGE
                     from IEX_APP_PREFERENCES_TL SUBB,
                          IEX_APP_PREFERENCES_TL SUBT
                     where SUBB.PREFERENCE_ID = SUBT.PREFERENCE_ID
                     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
                     and SUBB.USER_NAME<> SUBT.USER_NAME
                     OR (SUBB.USER_NAME IS NULL AND SUBT.USER_NAME IS NOT NULL)
                     OR (SUBB.USER_NAME IS NOT NULL AND SUBT.USER_NAME IS NULL)
                );

  insert into IEX_APP_PREFERENCES_TL (
    PREFERENCE_ID,
    USER_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PREFERENCE_ID,
    B.USER_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEX_APP_PREFERENCES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
     from IEX_APP_PREFERENCES_TL T
     where T.PREFERENCE_ID = B.PREFERENCE_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


procedure TRANSLATE_ROW (
  X_PREFERENCE_ID in NUMBER,
  X_USER_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
) IS

begin
	UPDATE IEX_APP_PREFERENCES_TL SET
		USER_NAME=X_USER_NAME,
		last_update_date = sysdate,
		last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
		last_update_login = 0,
		source_lang = userenv('LANG')
	WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG)
          AND PREFERENCE_ID = X_PREFERENCE_ID;
end TRANSLATE_ROW;

end IEX_APP_PREFERENCES_PKG;

/
