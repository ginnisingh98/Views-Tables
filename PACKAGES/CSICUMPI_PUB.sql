--------------------------------------------------------
--  DDL for Package CSICUMPI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSICUMPI_PUB" AUTHID CURRENT_USER AS
/* $Header: CSICUMPS.pls 120.1 2005/07/01 06:42:43 bnarayan noship $ */
TYPE Config_Rec_Type IS RECORD
 (Config_CP_Id NUMBER DEFAULT FND_API.G_MISS_NUM,
  Config_Parent_CP_Id NUMBER DEFAULT FND_API.G_MISS_NUM,
  Config_Type VARCHAR2(30) DEFAULT FND_API.G_MISS_Char,
  CUSTOMER_ID  NUMBER DEFAULT FND_API.G_MISS_NUM,
  Inventory_Item_Id NUMBER DEFAULT FND_API.G_MISS_NUM,
  Serial_Number VARCHAR2(30) DEFAULT FND_API.G_MISS_Char,
  Lot_Number VARCHAR2(80) DEFAULT  FND_API.G_MISS_Char);
TYPE Config_Tbl_Type IS TABLE OF Config_Rec_Type
 INDEX BY BINARY_INTEGER;

FUNCTION get_non_primary_party_list(p_account_number  VARCHAR2,
                                    p_org_id          NUMBER) RETURN VARCHAR2;


FUNCTION get_part_information(p_customer_product_id NUMBER) RETURN VARCHAR2;
FUNCTION get_root_information(p_customer_product_id NUMBER) RETURN VARCHAR2;
FUNCTION get_root_ID(p_customer_product_id NUMBER) RETURN NUMBER;

FUNCTION get_children_flag(p_customer_product_id NUMBER) RETURN VARCHAR2;
/*PROCEDURE Get_Configuration(
	p_cp_id				IN	NUMBER,
	p_config_type			IN	VARCHAR2	DEFAULT NULL,
	p_as_of_date			IN	DATE	DEFAULT SYSDATE,
	x_config_tbl		 OUT NOCOPY Config_Tbl_Type,
	x_config_tbl_count	 OUT NOCOPY NUMBER);
*/
END CSICUMPI_PUB;

 

/
