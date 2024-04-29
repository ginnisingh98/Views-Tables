--------------------------------------------------------
--  DDL for Package EDW_ITEMCUSTOM_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_ITEMCUSTOM_M_C" AUTHID CURRENT_USER AS
/*$Header: ENIITCSS.pls 115.0 2002/05/08 12:15:51 pkm ship    $*/
   VERSION                 CONSTANT CHAR(80) :=
      '$Header: ENIITCSS.pls 115.0 2002/05/08 12:15:51 pkm ship    $';

Function Get_Product_Category_Set_FK(p_inventory_item_id   IN  Number,
		     p_organization_id     IN  Number,
		     p_instance_code	   IN  Varchar2)
return Varchar2;
End EDW_ITEMCUSTOM_M_C;

 

/
