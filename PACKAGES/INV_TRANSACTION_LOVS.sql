--------------------------------------------------------
--  DDL for Package INV_TRANSACTION_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TRANSACTION_LOVS" AUTHID CURRENT_USER AS
/* $Header: INVMWALS.pls 120.1 2005/06/17 09:58:20 appldev  $ */

	TYPE t_genref IS REF CURSOR;

	PROCEDURE GET_TXN_REASONS(x_txnreasonLOV OUT NOCOPY /* file.sql.39 change */ t_genref);

	PROCEDURE GET_TXN_TYPES(x_txntypeLOV OUT NOCOPY /* file.sql.39 change */ t_genref,
				p_Transaction_Action_Id IN NUMBER,
				p_Transaction_Source_Type_Id IN NUMBER,
				p_Transaction_Type_Name IN VARCHAR2);

	PROCEDURE GET_TXN_TYPES(x_motxntypeLOV OUT NOCOPY /* file.sql.39 change */ t_genref,
				p_Transaction_Source_Type_Id IN NUMBER);

	PROCEDURE GET_CARRIER(x_getcarrierLOV OUT NOCOPY /* file.sql.39 change */ t_genref,
			      p_FromOrganization_Id IN NUMBER,
			      p_ToOrganization_Id IN NUMBER,
			      p_carrier IN VARCHAR2);

	PROCEDURE GET_ACCOUNT_ALIAS(x_Accounts_Info OUT NOCOPY /* file.sql.39 change */ t_genref,
			       p_Organization_Id IN NUMBER,
			       p_Description     IN VARCHAR2);

	PROCEDURE GET_ACCOUNTS(x_Accounts OUT NOCOPY /* file.sql.39 change */ t_genref,
			       p_Organization_Id IN NUMBER,
			       p_Concatenated_Segments IN VARCHAR2);

	PROCEDURE GET_ITEMS(x_items OUT NOCOPY /* file.sql.39 change */ t_genref,
			    p_organization_id IN NUMBER,
			    p_concatenated_segments IN VARCHAR2);
	PROCEDURE GET_TRANSACTABLE_ITEMS(x_Items OUT NOCOPY /* file.sql.39 change */ t_genref,
					 p_Organization_Id IN NUMBER,
					 p_Concatenated_Segments IN VARCHAR2,
					 p_Transaction_Action_Id IN NUMBER,
					 p_To_Organization_Id IN NUMBER DEFAULT NULL);

	PROCEDURE GET_VALID_LOCATORS(x_Locators OUT NOCOPY /* file.sql.39 change */ t_genref,
				     p_Organization_Id IN NUMBER,
				     p_Subinventory_Code IN VARCHAR2,
				     p_Restrict_Locators_Code IN NUMBER,
				     p_Inventory_Item_Id IN NUMBER,
				     p_Concatenated_Segments IN VARCHAR2);


	PROCEDURE GET_VALID_TO_LOCS(x_Locators OUT NOCOPY /* file.sql.39 change */ t_genref,
				     p_Transaction_Action_Id IN NUMBER,
		           	     p_To_Organization_Id IN NUMBER,
				     p_Organization_Id IN NUMBER,
				     p_Subinventory_Code IN VARCHAR2,
				     p_Restrict_Locators_Code IN NUMBER,
				     p_Inventory_Item_Id IN NUMBER,
				     p_Concatenated_Segments IN VARCHAR2);

	PROCEDURE GET_VALID_SUBS(x_Zones OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_organization_id IN NUMBER,
				 p_subinventory_code IN VARCHAR2);

	PROCEDURE GET_FROM_SUBS(x_Zones OUT NOCOPY /* file.sql.39 change */ t_genref,
				p_organization_id IN NUMBER);

	PROCEDURE GET_FROM_SUBS(x_Zones OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Organization_Id IN NUMBER,
				 p_Inventory_Item_Id IN NUMBER,
				 p_Restrict_Subinventories_Code IN NUMBER,
				 p_Secondary_Inventory_Name IN VARCHAR2,
				 p_Transaction_Action_Id IN NUMBER);

	PROCEDURE GET_TO_SUB(x_to_sub OUT NOCOPY /* file.sql.39 change */ t_genref,
			     p_Organization_Id IN NUMBER,
			     p_Inventory_Item_Id IN NUMBER,
			     p_from_Secondary_Name IN VARCHAR2,
			     p_Restrict_Subinventories_Code IN NUMBER,
			     p_Secondary_Inventory_Name IN VARCHAR2,
			     p_From_Sub_Asset_Inventory IN VARCHAR2,
			     p_Transaction_Action_Id IN NUMBER,
			     p_To_Organization_Id IN NUMBER,
			     p_Serial_Number_Control_Code IN NUMBER);
			     --p_Serial IN VARCHAR2);

	PROCEDURE GET_TO_SUB(x_Zones OUT NOCOPY /* file.sql.39 change */ t_genref,
				p_organization_id IN NUMBER,
				p_secondary_inventory_name in VARCHAR2);

	procedure GET_ORG(x_org OUT NOCOPY /* file.sql.39 change */ t_genref,
			  p_responsibility_id IN NUMBER,
			  p_resp_application_id IN NUMBER);

	PROCEDURE GET_TO_ORG(x_Organizations OUT NOCOPY /* file.sql.39 change */ t_genref,
			     p_From_Organization_Id IN NUMBER);



	PROCEDURE GET_VALID_UOMS(x_UOMS OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Organization_Id IN NUMBER,
				 p_Inventory_Item_Id IN NUMBER,
				 p_UOM_Code IN VARCHAR2);

	PROCEDURE GET_VALID_LOTS(x_Lots OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Organization_Id IN NUMBER,
				 p_Inventory_Item_Id IN NUMBER,
				 p_Lot IN VARCHAR2);

	PROCEDURE GET_VALID_LOTS(x_Lots OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Organization_Id IN NUMBER,
				 p_Inventory_Item_Id IN NUMBER,
				 p_subcode IN VARCHAR2,
				 p_revision IN VARCHAR2,
				 p_locatorid IN NUMBER,
				 p_Lot IN VARCHAR2);

	PROCEDURE GET_VALID_REVS(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Organization_Id IN NUMBER,
				 p_Inventory_Item_Id IN NUMBER,
				 p_Revision IN VARCHAR2);


	PROCEDURE GET_VALID_SERIAL_REC_2(x_RSerials IN OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Current_Organization_Id IN NUMBER,
				 p_Inventory_Item_Id IN NUMBER,
				 p_Serial_Number IN VARCHAR2);

	PROCEDURE GET_VALID_SERIAL_REC_5(x_RSerials IN OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Current_Organization_Id IN NUMBER,
				 p_Inventory_Item_Id IN NUMBER,
				 p_Current_Subinventory_Code IN VARCHAR2,
				 p_Current_Locator_Id IN NUMBER,
				 p_Lot_Number IN VARCHAR2,
				 p_Serial_Number IN VARCHAR2);

	PROCEDURE GET_VALID_SERIAL_ISSUE(x_RSerials OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Current_Organization_Id IN NUMBER,
				 p_Current_Subinventory_Code IN VARCHAR2,
				 p_Current_Locator_Id IN NUMBER,
				 p_Current_Lot_Number IN VARCHAR2,
				 p_Inventory_Item_Id IN NUMBER,
				 p_Serial_Number IN VARCHAR2);



	PROCEDURE GET_VALID_SERIALS(x_RSerials OUT NOCOPY /* file.sql.39 change */ t_genref,
					p_Serial_Number_Control_Code IN NUMBER,
					p_Inventory_Item_Id IN NUMBER,
					p_Current_Organization_Id IN NUMBER,
				p_Current_Subinventory_Code IN VARCHAR2,
					p_Current_Locator_Id  IN NUMBER,
					p_Lot_Number IN VARCHAR2,
					p_Transaction_Action_Id IN NUMBER,
					p_Serial_Number IN VARCHAR2);

END INV_TRANSACTION_LOVS;

 

/
