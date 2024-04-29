--------------------------------------------------------
--  DDL for Package CS_INVENTORY_TXNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INVENTORY_TXNS" AUTHID CURRENT_USER as
/* $Header: csdrtxns.pls 115.3 99/07/16 08:57:15 porting ship $ */
PROCEDURE Get_Default_Values (p_mfg_org_Id			OUT	NUMBER,
						p_Error_Flag			OUT	VARCHAR2,
						p_error_profile		OUT	VARCHAR2,
						p_transaction_Type		OUT	NUMBER,
						p_service_item_flex_code	OUT	VARCHAR2,
						P_Subinventory_Code		IN OUT	VARCHAR2,
						P_Source_Id              IN OUT  NUMBER);

PROCEDURE	Insert_Mtl_Interface_Records(
				P_Detail_Txn_Id		IN	NUMBER,
				P_Estimate_Id			IN 	NUMBER,
				P_Estimate_Detail_Id	IN	NUMBER,
				P_Organization_Id   	IN 	NUMBER,
				P_Inventory_Item_Id		IN	NUMBER,
				P_Uom_Code			IN	VARCHAR2,
				P_Quantity			IN	NUMBER,
				P_Revision			IN	VARCHAR2,
				p_serial_number		IN	VARCHAR2,
				p_lot_number			IN	NUMBER,
				P_Subinventory_Code		IN	VARCHAR2,
				P_Locator_Id			IN	NUMBER,
				p_transaction_type_id	IN	NUMBER) ;
end cs_inventory_txns ;

 

/
