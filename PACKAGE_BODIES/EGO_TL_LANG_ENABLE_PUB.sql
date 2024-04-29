--------------------------------------------------------
--  DDL for Package Body EGO_TL_LANG_ENABLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_TL_LANG_ENABLE_PUB" AS
/* $Header: EGOCSLEB.pls 115.1 2003/08/14 18:25:46 sjenq noship $ */



PROCEDURE handle_catset_language_rows (
  X_CATEGORY_SET_ID in NUMBER
) is
begin

  --insert new row in all installed languages in the TL table
  --IF no rows in those installed languages already exist
  insert into MTL_CATEGORY_SETS_TL (
    CATEGORY_SET_ID,
    LANGUAGE,
    SOURCE_LANG,
    CATEGORY_SET_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    X_CATEGORY_SET_ID,
    L.LANGUAGE_CODE,
    TL.SOURCE_LANG,
    TL.CATEGORY_SET_NAME,
    TL.DESCRIPTION,
    TL.LAST_UPDATE_DATE,
    TL.LAST_UPDATED_BY,
    TL.CREATION_DATE,
    TL.CREATED_BY,
    TL.LAST_UPDATE_LOGIN
  from  FND_LANGUAGES  L, MTL_CATEGORY_SETS_TL TL
  where  L.INSTALLED_FLAG in ('I', 'B')
    and  TL.CATEGORY_SET_ID = X_CATEGORY_SET_ID
    and  not exists
         ( select NULL
           from  MTL_CATEGORY_SETS_TL T
           where  T.CATEGORY_SET_ID = X_CATEGORY_SET_ID
             and  T.LANGUAGE = L.LANGUAGE_CODE );

end handle_catset_language_rows;


PROCEDURE handle_category_language_rows (
  X_CATEGORY_ID in NUMBER
) is
begin

  --insert new row in all installed languages in the TL table
  --IF no rows in those installed languages already exist
  insert into MTL_CATEGORIES_TL (
    CATEGORY_ID,
    LANGUAGE,
    SOURCE_LANG,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    X_CATEGORY_ID,
    L.LANGUAGE_CODE,
    TL.SOURCE_LANG,
    TL.DESCRIPTION,
    TL.LAST_UPDATE_DATE,
    TL.LAST_UPDATED_BY,
    TL.CREATION_DATE,
    TL.CREATED_BY,
    TL.LAST_UPDATE_LOGIN
  from  FND_LANGUAGES  L, MTL_CATEGORIES_TL TL
  where  L.INSTALLED_FLAG in ('I', 'B')
    and TL.CATEGORY_ID = X_CATEGORY_ID
    and  not exists
         ( select NULL
           from  MTL_CATEGORIES_TL  T
           where  T.CATEGORY_ID = X_CATEGORY_ID
             and  T.LANGUAGE = L.LANGUAGE_CODE );

end handle_category_language_rows;


PROCEDURE handle_catgroup_language_rows (
  X_ITEM_CATALOG_GROUP_ID in NUMBER
) is
begin

  --insert new row in all installed languages in the TL table
  --IF no rows in those installed languages already exist
  insert into MTL_ITEM_CATALOG_GROUPS_TL (
    ITEM_CATALOG_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    X_ITEM_CATALOG_GROUP_ID,
    L.LANGUAGE_CODE,
    TL.SOURCE_LANG,
    TL.DESCRIPTION,
    TL.LAST_UPDATE_DATE,
    TL.LAST_UPDATED_BY,
    TL.CREATION_DATE,
    TL.CREATED_BY,
    TL.LAST_UPDATE_LOGIN
  from  FND_LANGUAGES  L, MTL_ITEM_CATALOG_GROUPS_TL TL
  where  L.INSTALLED_FLAG in ('I', 'B')
    and TL.ITEM_CATALOG_GROUP_ID = X_ITEM_CATALOG_GROUP_ID
    and  not exists
         ( select NULL
           from  MTL_ITEM_CATALOG_GROUPS_TL  T
           where  T.ITEM_CATALOG_GROUP_ID = X_ITEM_CATALOG_GROUP_ID
             and  T.LANGUAGE = L.LANGUAGE_CODE );

end handle_catgroup_language_rows;


end EGO_TL_LANG_ENABLE_PUB;

/
