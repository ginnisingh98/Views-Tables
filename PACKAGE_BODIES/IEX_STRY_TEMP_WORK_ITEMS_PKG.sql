--------------------------------------------------------
--  DDL for Package Body IEX_STRY_TEMP_WORK_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRY_TEMP_WORK_ITEMS_PKG" as
/* $Header: iextstwb.pls 120.0 2004/01/24 03:23:04 appldev noship $ */
PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

procedure ADD_LANGUAGE
is
begin
  delete from IEX_STRY_TEMP_WORK_ITEMS_TL T
  where not exists
    (select NULL
     from IEX_STRY_TEMP_WORK_ITEMS_B B
     where B.WORK_ITEM_TEMP_ID = T.WORK_ITEM_TEMP_ID
    );

  update IEX_STRY_TEMP_WORK_ITEMS_TL T
        set (NAME) =
             (select B.NAME
              from IEX_STRY_TEMP_WORK_ITEMS_TL B
              where B.WORK_ITEM_TEMP_ID = T.WORK_ITEM_TEMP_ID
              and B.LANGUAGE = T.SOURCE_LANG)
        where (
              T.WORK_ITEM_TEMP_ID,T.LANGUAGE
               ) in (select
                       SUBT.WORK_ITEM_TEMP_ID,
                       SUBT.LANGUAGE
                     from IEX_STRY_TEMP_WORK_ITEMS_TL SUBB,
                          IEX_STRY_TEMP_WORK_ITEMS_TL SUBT
                     where SUBB.WORK_ITEM_TEMP_ID = SUBT.WORK_ITEM_TEMP_ID
                     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
                     and SUBB.NAME<> SUBT.NAME
                     OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
                     OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
                );

  insert into IEX_STRY_TEMP_WORK_ITEMS_TL (
    WORK_ITEM_TEMP_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.WORK_ITEM_TEMP_ID,
    B.NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEX_STRY_TEMP_WORK_ITEMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
     from IEX_STRY_TEMP_WORK_ITEMS_TL T
     where T.WORK_ITEM_TEMP_ID = B.WORK_ITEM_TEMP_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


procedure TRANSLATE_ROW (
  X_WORK_ITEM_TEMP_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
) IS

begin
	UPDATE IEX_STRY_TEMP_WORK_ITEMS_TL SET
		NAME=X_NAME,
		last_update_date = sysdate,
		last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
		last_update_login = 0,
		source_lang = userenv('LANG')
	WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
		 WORK_ITEM_TEMP_ID = X_WORK_ITEM_TEMP_ID;
end TRANSLATE_ROW;

end IEX_STRY_TEMP_WORK_ITEMS_PKG;

/
