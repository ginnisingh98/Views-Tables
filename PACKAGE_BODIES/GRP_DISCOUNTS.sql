--------------------------------------------------------
--  DDL for Package Body GRP_DISCOUNTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GRP_DISCOUNTS" as
/* $Header: OEXGRPPB.pls 115.1 99/08/05 15:05:14 porting ship  $ */

Function Check_item_category (Inv_Item_Id  In Number,ENT_VAL in VARCHAR2, OrgId In Number)
         Return VARCHAR2 IS
         dummy   Varchar2(1) := 'X';
         CURSOR C_Check_item_category_1 IS
                 SELECT 'Y'
                 FROM  mtl_default_category_sets MTDCS
			  , mtl_category_set_valid_cats MCSV
			  , mtl_categories MC
			  ,MTL_ITEM_CATEGORIES MTC
                 WHERE  MTDCS.functional_area_id = 7
                 AND    MTC.category_set_id = MTDCS.category_set_id
                 AND    MTC.INVENTORY_ITEM_ID = TO_CHAR( Inv_Item_Id )
			  AND    MCSV.category_set_id = MTC.category_set_id
			  AND    MCSV.category_id = MTC.category_id
			  AND    MCSV.category_id = MC.category_id
			  AND    sysdate < nvl(MC.disable_date, sysdate+1)
                 AND    MTC.CATEGORY_ID = to_number(ENT_VAL);


         CURSOR C_Check_item_category_2 IS
                 SELECT 'Y'
                 FROM mtl_default_category_sets MTDCS
			  , mtl_category_set_valid_cats MCSV
			  , mtl_categories MC
                 	  , MTL_ITEM_CATEGORIES MTC
                 WHERE  MTDCS.functional_area_id = 7
                 AND    MTC.category_set_id = MTDCS.category_set_id
                 AND    MTC.INVENTORY_ITEM_ID = TO_CHAR( Inv_Item_Id )
			  AND    MCSV.category_set_id = MTC.category_set_id
			  AND    MCSV.category_id = MTC.category_id
			  AND    MCSV.category_id = MC.category_id
			  AND    sysdate < nvl(MC.disable_date, sysdate+1)
                 AND    MTC.ORGANIZATION_ID = OrgId
                 AND    MTC.CATEGORY_ID = to_number(ENT_VAL);



    Begin
	If OrgId Is Null Then
          Open C_Check_item_category_1;
          FETCH C_Check_item_category_1
               into dummy;
          close C_Check_item_category_1;
          if dummy = 'Y' then
                RETURN('Y');
          else
               RETURN('N');
          end if;
	Else
          Open C_Check_item_category_2;
          FETCH C_Check_item_category_2
               into dummy;
          close C_Check_item_category_2;
          if dummy = 'Y' then
                RETURN('Y');
          else
               RETURN('N');
          end if;
	End If;
  Exception
   When Others then return('N');
   End;

END GRP_DISCOUNTS;

/
