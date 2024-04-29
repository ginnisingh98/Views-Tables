--------------------------------------------------------
--  DDL for Package MTL_ITEM_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_ITEM_TEMPLATES_PKG" AUTHID CURRENT_USER AS
/* $Header: INVVTEMS.pls 120.2 2005/07/13 03:58:48 lparihar noship $ */

PROCEDURE INSERT_ROW(P_Item_Templates_Rec IN  MTL_ITEM_TEMPLATES_B%ROWTYPE,
                     X_ROWID             OUT  NOCOPY ROWID);

PROCEDURE LOCK_ROW (P_Item_Templates_Rec IN  MTL_ITEM_TEMPLATES_B%ROWTYPE);

PROCEDURE UPDATE_ROW (P_Item_Templates_Rec IN  MTL_ITEM_Templates_B%ROWTYPE);

PROCEDURE DELETE_ROW(P_Template_Id IN NUMBER);

PROCEDURE ADD_LANGUAGE ;

end MTL_ITEM_TEMPLATES_PKG;

 

/
