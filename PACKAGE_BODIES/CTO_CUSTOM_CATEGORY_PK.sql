--------------------------------------------------------
--  DDL for Package Body CTO_CUSTOM_CATEGORY_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_CUSTOM_CATEGORY_PK" as
/* $Header: CTOCUCTB.pls 115.0 2002/10/09 23:46:11 sbhaskar noship $ */

/*---------------------------------------------------------------------------+
    This function is used to determine if a particular category set needs
    to be copied to the configuration item or not.
    If the function returns
       0, it means that the category set SHOULD NOT be copied to the config item.
       1, it means that the category set SHOULD be copied to the config item.

+----------------------------------------------------------------------------*/

function Copy_Category(
        pCategory_Set_Id    in      Number,
        pOrganization_id    in      Number)
Return Number IS

begin
	/*----------------------------------------------------------------+
	   This function can be replaced by custom code that will return
           either 1 or 0 if a particular category set needs to be copied
	   or not.
           1 means you WANT the category set to be copied.
           0 means you DO NOT WANT the category set to be copied.

	   By default : Category Set "Sales and Marketing" will NOT be copied.

	   If a value other than 1 is returned (incl null), the category set
	   will not be copied.


	   -- Seeded Category Sets --

	   INVENTORY   			CONSTANT NUMBER := 1;
	   PURCHASING   		CONSTANT NUMBER := 2;
	   PRODUCT_FAMILY		CONSTANT NUMBER := 3;
	   SALES_AND_MARKETING   	CONSTANT NUMBER := 5;
	   CONTAINED_ITEM        	CONSTANT NUMBER := 11;
	   CONTAINER_ITEM        	CONSTANT NUMBER := 12;
	   ENTERPRISE_ASSET_MGMT   	CONSTANT NUMBER := 1000000014;
	   CONTRACTS        		CONSTANT NUMBER := 1000000015;

        +-----------------------------------------------------------------*/

	if pCategory_Set_Id = CTO_CUSTOM_CATEGORY_PK.SALES_AND_MARKETING then
	   return 0;
	else
	   return 1;
	end if;

end Copy_Category;

end CTO_CUSTOM_CATEGORY_PK;

/
