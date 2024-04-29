--------------------------------------------------------
--  DDL for Package Body EDW_ITEMCUSTOM_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_ITEMCUSTOM_M_C" AS
/*$Header: ENIITCSB.pls 115.0 2002/05/08 12:15:49 pkm ship    $*/
   VERSION                 CONSTANT CHAR(80) :=
      '$Header: ENIITCSB.pls 115.0 2002/05/08 12:15:49 pkm ship    $';

Function Get_Product_Category_Set_FK(p_inventory_item_id   IN  Number,
		     p_organization_id     IN  Number,
		     p_instance_code	   IN  Varchar2)
return Varchar2 IS
	Prod_FK Varchar2(40) := 'NA_EDW';
Begin
	Return Prod_FK;
End Get_Product_Category_Set_FK;
End EDW_ITEMCUSTOM_M_C;

/
