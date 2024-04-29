--------------------------------------------------------
--  DDL for Package EDW_ITEMS_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_ITEMS_M_C" AUTHID CURRENT_USER AS
/*$Header: ENICITMS.pls 115.3 2004/01/30 22:01:06 sbag noship $*/
   VERSION                 CONSTANT CHAR(80) :=
      '$Header: ENICITMS.pls 115.3 2004/01/30 22:01:06 sbag noship $';

-- Global Variables

-- The ID of the category set from which the item category value based hierarchy
-- will be loaded

G_VBH_CATSET_ID  		CONSTANT NUMBER:=1000000006;

Procedure Push(   Errbuf            OUT NOCOPY Varchar2,
                  Retcode           OUT NOCOPY Varchar2,
                  p_from_date       IN  Varchar2,
                  p_to_date         IN  Varchar2);
Procedure Push_EDW_ITEM_ITEMREV(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
Procedure Push_EDW_ITEM_PRDFAM(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
Procedure Push_EDW_ITEM_ITEMORG(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
Procedure Push_EDW_ITEM_ITEM(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
Procedure Push_EDW_ITEM_ITEMORG_CAT(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
Procedure Push_EDW_ITEM_ITEM_CAT(
                  p_from_date   IN  Date,
                  p_to_date     IN  Date);
Procedure Push_EDW_ITEM_PROD_LINE(
				  p_from_date   IN Date,
				  p_to_date     IN Date);
Procedure Push_EDW_ITEM_PROD_CATG(
				  p_from_date   IN Date,
				  p_to_date     IN Date);
Procedure Push_EDW_ITEM_PROD_GRP(
                  p_from_date   IN Date,
				  p_to_date     IN Date);
End EDW_ITEMS_M_C;

 

/
