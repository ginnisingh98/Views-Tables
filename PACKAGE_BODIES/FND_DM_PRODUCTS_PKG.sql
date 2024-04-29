--------------------------------------------------------
--  DDL for Package Body FND_DM_PRODUCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DM_PRODUCTS_PKG" AS
/* $Header: FNDDMPDB.pls 115.0 2004/04/23 23:34:01 shvanga noship $ */


procedure ADD_LANGUAGE
is
begin

  insert into FND_DM_PRODUCTS_TL (
    PRODUCT_ID,
    DISPLAY_NAME,
    PRODUCT_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    M.PRODUCT_ID,
    M.DISPLAY_NAME,
    M.PRODUCT_DESCRIPTION,
    L.LANGUAGE_CODE,
    M.SOURCE_LANG
  from FND_DM_PRODUCTS_TL M, FND_LANGUAGES B, FND_LANGUAGES L
  where B.INSTALLED_FLAG = 'B'
  and L.INSTALLED_FLAG in ('I', 'B')
  and M.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_DM_PRODUCTS_TL T
    where T.PRODUCT_ID = M.PRODUCT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end FND_DM_PRODUCTS_PKG;

/
