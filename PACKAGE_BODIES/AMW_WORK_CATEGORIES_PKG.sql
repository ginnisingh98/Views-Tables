--------------------------------------------------------
--  DDL for Package Body AMW_WORK_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_WORK_CATEGORIES_PKG" as
/* $Header: amwtwctb.pls 120.0 2005/10/26 07:07:11 appldev noship $ */


procedure ADD_LANGUAGE
is
begin
  delete from AMW_WORK_CATEGORIES_TL T
  where not exists
    (select NULL
    from AMW_WORK_CATEGORIES_B B
    where B.CATEGORY_ID = T.CATEGORY_ID
    );

  update AMW_WORK_CATEGORIES_TL T set (
      CATEGORY_NAME,
      PLURAL_NAME,
      DESCRIPTION
    ) = (select
      B.CATEGORY_NAME,
      B.PLURAL_NAME,
      B.DESCRIPTION
    from AMW_WORK_CATEGORIES_TL B
    where B.CATEGORY_ID = T.CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CATEGORY_ID,
      SUBT.LANGUAGE
    from AMW_WORK_CATEGORIES_TL SUBB, AMW_WORK_CATEGORIES_TL SUBT
    where SUBB.CATEGORY_ID = SUBT.CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CATEGORY_NAME <> SUBT.CATEGORY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or SUBB.PLURAL_NAME <> SUBT.PLURAL_NAME
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or (SUBB.PLURAL_NAME is null and SUBT.PLURAL_NAME is not null)
      or (SUBB.PLURAL_NAME is not null and SUBT.PLURAL_NAME is null)
  ));

  insert into AMW_WORK_CATEGORIES_TL (
    OBJECT_VERSION_NUMBER,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    DESCRIPTION,
    SOURCE_LANG,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    CATEGORY_ID,
    CATEGORY_NAME,
    PLURAL_NAME,
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
    B.CATEGORY_ID,
    B.CATEGORY_NAME,
    B.PLURAL_NAME,
    L.LANGUAGE_CODE
  from AMW_WORK_CATEGORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_WORK_CATEGORIES_TL T
    where T.CATEGORY_ID = B.CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


end AMW_WORK_CATEGORIES_PKG;

/
