--------------------------------------------------------
--  DDL for Package Body BOM_COMPARISON_TEMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_COMPARISON_TEMP_PKG" as
/* $Header: bompbcpb.pls 115.1 99/07/16 05:47:16 porting ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/

PROCEDURE Get_Sequence_and_Commons ( X_Sequence_Id               IN OUT NUMBER,
                                     X_Common_Bill_Sequence_Id1  IN OUT NUMBER,
                                     X_Common_Bill_Sequence_Id2  IN OUT NUMBER,
                                     X_Organization_Id1 NUMBER,
                                     X_Organization_Id2 NUMBER,
                                     X_Assembly_Item_Id1 NUMBER,
                                     X_Assembly_Item_Id2 NUMBER,
                                     X_Alternate1 VARCHAR2,
                                     X_alternate2 VARCHAR2 ) IS
  cursor c1 is select bom1.common_bill_sequence_id
		 from BOM_BILL_OF_MATERIALS bom1
		where bom1.organization_id = X_Organization_Id1
	 	  and bom1.assembly_item_id = X_Assembly_Item_Id1
		  and nvl(bom1.alternate_bom_designator, 'NONE') =
		      nvl(X_Alternate1, 'NONE');
  cursor c2 is select bom2.common_bill_sequence_id
		 from BOM_BILL_OF_MATERIALS bom2
		where bom2.organization_id = X_Organization_Id2
	 	  and bom2.assembly_item_id = X_Assembly_Item_Id2
		  and nvl(bom2.alternate_bom_designator, 'NONE') =
		      nvl(X_Alternate2, 'NONE');
BEGIN
  select bom_comparison_temp_s.nextval
    into X_Sequence_Id
    from sys.dual;
  open c1;
  fetch c1 into X_Common_Bill_Sequence_Id1;
  close c1;
  open c2;
  fetch c2 into X_Common_Bill_Sequence_Id2;
  close c2;
END Get_Sequence_and_Commons;



FUNCTION Get_Bill_Type ( X_Organization_Id NUMBER,
			 X_Assembly_Item_Id NUMBER,
			 X_Alternate VARCHAR2 ) RETURN NUMBER IS
  cursor c1 is
	select assembly_type from bom_bill_of_materials bom
	 where bom.organization_id = X_Organization_Id
	   and bom.assembly_item_id = X_Assembly_Item_Id
	   and nvl(bom.alternate_bom_designator,'NONE') =
	       nvl(X_Alternate,'NONE');
  bill_type NUMBER;
BEGIN
  open c1;
  fetch c1 into bill_type;
  close c1;
  return(bill_type);
END Get_Bill_Type;

END BOM_COMPARISON_TEMP_PKG;

/
