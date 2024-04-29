--------------------------------------------------------
--  DDL for Package MTL_ITEM_REVISIONS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_ITEM_REVISIONS_UTIL" AUTHID CURRENT_USER AS
/* $Header: INVIRVUS.pls 115.1 2002/12/16 06:06:31 mantyaku noship $ */

PROCEDURE INSERT_ROW(P_Item_Revision_Rec IN  MTL_ITEM_REVISIONS_B%ROWTYPE,
                     X_ROWID             OUT NOCOPY VARCHAR2);

procedure LOCK_ROW  (P_Item_Revision_Rec IN  MTL_ITEM_REVISIONS_B%ROWTYPE);

procedure UPDATE_ROW(P_Item_Revision_Rec IN  MTL_ITEM_REVISIONS_B%ROWTYPE);

procedure ADD_LANGUAGE;

END MTL_ITEM_REVISIONS_UTIL;

 

/
