--------------------------------------------------------
--  DDL for Package CTO_CUSTOM_CATEGORY_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CUSTOM_CATEGORY_PK" AUTHID CURRENT_USER as
/* $Header: CTOCUCTS.pls 115.0 2002/10/09 23:45:38 sbhaskar noship $ */


/*---------------------------------------------------------------------------+
    This function is used to determine if a particular category set needs
    to be copied to the configuration item or not.
    If the function returns
       0, it means that the category set SHOULD NOT be copied to the config item.
       1, it means that the category set SHOULD be copied to the config item.

+----------------------------------------------------------------------------*/

-- Seeded Category Sets --

INVENTORY   		CONSTANT NUMBER := 1;
PURCHASING   		CONSTANT NUMBER := 2;
PRODUCT_FAMILY		CONSTANT NUMBER := 3;
SALES_AND_MARKETING   	CONSTANT NUMBER := 5;
CONTAINED_ITEM        	CONSTANT NUMBER := 11;
CONTAINER_ITEM        	CONSTANT NUMBER := 12;
ENTERPRISE_ASSET_MGMT   CONSTANT NUMBER := 1000000014;
CONTRACTS        	CONSTANT NUMBER := 1000000015;



function Copy_Category(
	pCategory_Set_Id    in      Number,
        pOrganization_id    in      Number)
Return Number;

end CTO_CUSTOM_CATEGORY_PK;

 

/
