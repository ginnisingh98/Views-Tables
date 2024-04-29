--------------------------------------------------------
--  DDL for Package Body XDO_DGF_RULE_CATALOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_DGF_RULE_CATALOG_PKG" as
/* $Header: XDODGFRCB.pls 120.0 2008/04/03 17:49:13 bgkim noship $ */

procedure ADD_LANGUAGE is
begin
  insert into XDO_DGF_RULE_CATALOG_TL (
    RULE_CATALOG_ID,
    RULE_VALUES,
    RULE_DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.RULE_CATALOG_ID,
    B.RULE_VALUES,
    B.RULE_DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDO_DGF_RULE_CATALOG_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDO_DGF_RULE_CATALOG_TL T
    where T.RULE_CATALOG_ID = B.RULE_CATALOG_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end XDO_DGF_RULE_CATALOG_PKG;

/
