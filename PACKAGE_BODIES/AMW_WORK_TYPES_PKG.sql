--------------------------------------------------------
--  DDL for Package Body AMW_WORK_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_WORK_TYPES_PKG" as
/* $Header: amwtwtpb.pls 120.0 2005/10/26 07:06:48 appldev noship $ */


procedure ADD_LANGUAGE
is
begin
  delete from AMW_WORK_TYPES_TL T
  where not exists
    (select NULL
    from AMW_WORK_TYPES_B B
    where B.WORK_TYPE_ID = T.WORK_TYPE_ID
    );

  update AMW_WORK_TYPES_TL T set (
      WORK_TYPE_NAME,
      TAB_TEXT,
      DESCRIPTION
    ) = (select
      B.WORK_TYPE_NAME,
      B.TAB_TEXT,
      B.DESCRIPTION
    from AMW_WORK_TYPES_TL B
    where B.WORK_TYPE_ID = T.WORK_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.WORK_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.WORK_TYPE_ID,
      SUBT.LANGUAGE
    from AMW_WORK_TYPES_TL SUBB, AMW_WORK_TYPES_TL SUBT
    where SUBB.WORK_TYPE_ID = SUBT.WORK_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.WORK_TYPE_NAME <> SUBT.WORK_TYPE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or SUBB.TAB_TEXT <> SUBT.TAB_TEXT
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or (SUBB.TAB_TEXT is null and SUBT.TAB_TEXT is not null)
      or (SUBB.TAB_TEXT is not null and SUBT.TAB_TEXT is null)
  ));

  insert into AMW_WORK_TYPES_TL (
    OBJECT_VERSION_NUMBER,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    DESCRIPTION,
    SOURCE_LANG,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    WORK_TYPE_ID,
    WORK_TYPE_NAME,
    TAB_TEXT,
    LANGUAGE
 ) select /*+ ORDERED */
    B.OBJECT_VERSION_NUMBER,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.DESCRIPTION,
    B.SOURCE_LANG,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.WORK_TYPE_ID,
    B.WORK_TYPE_NAME,
    B.TAB_TEXT,
    L.LANGUAGE_CODE
  from AMW_WORK_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_WORK_TYPES_TL T
    where T.WORK_TYPE_ID = B.WORK_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


end AMW_WORK_TYPES_PKG;

/
