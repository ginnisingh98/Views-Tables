--------------------------------------------------------
--  DDL for Package MTL_ITEM_CATALOG_GROUPS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_ITEM_CATALOG_GROUPS_UTIL" AUTHID CURRENT_USER AS
/* $Header: INVICGUS.pls 115.2 2002/12/16 06:00:38 mantyaku noship $ */

PROCEDURE INSERT_ROW (P_Catalog_Group_Rec IN  MTL_ITEM_CATALOG_GROUPS%ROWTYPE,
                      X_ROWID             OUT NOCOPY ROWID);

procedure LOCK_ROW   (P_Catalog_Group_Rec IN  MTL_ITEM_CATALOG_GROUPS%ROWTYPE);

procedure UPDATE_ROW (P_Catalog_Group_Rec IN  MTL_ITEM_CATALOG_GROUPS%ROWTYPE);

procedure DELETE_ROW (X_ITEM_CATALOG_GROUP_ID IN MTL_ITEM_CATALOG_GROUPS.ITEM_CATALOG_GROUP_ID%TYPE);

procedure ADD_LANGUAGE;

end MTL_ITEM_CATALOG_GROUPS_UTIL;

 

/
