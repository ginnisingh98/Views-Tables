--------------------------------------------------------
--  DDL for Package GRP_DISCOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GRP_DISCOUNTS" AUTHID CURRENT_USER AS
/* $Header: OEXGRPPS.pls 115.1 99/08/05 15:05:18 porting ship  $ */
Function Check_item_category(Inv_Item_Id IN NUMBER ,Ent_Val in VARCHAR2,
                               OrgId In Number)
         Return VARCHAR2;
 pragma restrict_references( CHECK_ITEM_CATEGORY, WNDS,WNPS);
END GRP_DISCOUNTS;


 

/
