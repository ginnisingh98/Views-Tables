--------------------------------------------------------
--  DDL for Package EGO_TL_LANG_ENABLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_TL_LANG_ENABLE_PUB" AUTHID CURRENT_USER as
/* $Header: EGOCSLES.pls 115.1 2003/08/14 18:25:59 sjenq noship $ */

PROCEDURE handle_catset_language_rows (
  X_CATEGORY_SET_ID in NUMBER
);

PROCEDURE handle_category_language_rows (
  X_CATEGORY_ID in NUMBER
);

PROCEDURE handle_catgroup_language_rows (
  X_ITEM_CATALOG_GROUP_ID in NUMBER
);

end EGO_TL_LANG_ENABLE_PUB;

 

/
