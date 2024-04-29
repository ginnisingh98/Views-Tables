--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_OBJECTS_PKG" as
/* $Header: ENGUCHOB.pls 120.2 2006/06/29 08:59:13 pdutta noship $ */

procedure ADD_LANGUAGE
is
begin
  delete from ENG_CHANGE_OBJECTS_TL T
  where not exists
    (select NULL
    from ENG_CHANGE_OBJECTS B
    where B.entity_name = T.entity_name
    );

  update ENG_CHANGE_OBJECTS_TL T set (
      QUERY_COLUMN1_DISPLAY_NAME,
      QUERY_COLUMN2_DISPLAY_NAME
    ) = (select
      B.QUERY_COLUMN1_DISPLAY_NAME,
      B.QUERY_COLUMN2_DISPLAY_NAME
    from ENG_CHANGE_OBJECTS_TL B
    where B.entity_name = T.entity_name
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.entity_name,
      T.LANGUAGE
  ) in (select
      SUBT.entity_name,
      SUBT.LANGUAGE
    from ENG_CHANGE_OBJECTS_TL SUBB, ENG_CHANGE_OBJECTS_TL SUBT
    where SUBB.entity_name = SUBT.entity_name
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.QUERY_COLUMN1_DISPLAY_NAME <> SUBT.QUERY_COLUMN1_DISPLAY_NAME
      or (SUBB.QUERY_COLUMN1_DISPLAY_NAME is null and SUBT.QUERY_COLUMN1_DISPLAY_NAME is not null)
      or (SUBB.QUERY_COLUMN1_DISPLAY_NAME is not null and SUBT.QUERY_COLUMN1_DISPLAY_NAME is null)
      or SUBB.QUERY_COLUMN2_DISPLAY_NAME <> SUBT.QUERY_COLUMN2_DISPLAY_NAME
      or (SUBB.QUERY_COLUMN2_DISPLAY_NAME is null and SUBT.QUERY_COLUMN2_DISPLAY_NAME is not null)
      or (SUBB.QUERY_COLUMN2_DISPLAY_NAME is not null and SUBT.QUERY_COLUMN2_DISPLAY_NAME is null)
  ));

  insert into ENG_CHANGE_OBJECTS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    QUERY_COLUMN1_DISPLAY_NAME,
    QUERY_COLUMN2_DISPLAY_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    entity_name,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.QUERY_COLUMN1_DISPLAY_NAME,
    B.QUERY_COLUMN2_DISPLAY_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.entity_name,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_CHANGE_OBJECTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_CHANGE_OBJECTS_TL T
    where T.entity_name = B.entity_name
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
end ENG_CHANGE_OBJECTS_PKG;

/
