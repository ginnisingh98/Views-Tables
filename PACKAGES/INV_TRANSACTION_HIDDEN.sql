--------------------------------------------------------
--  DDL for Package INV_TRANSACTION_HIDDEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TRANSACTION_HIDDEN" AUTHID CURRENT_USER AS
/* $Header: INVMWAHS.pls 120.0 2005/05/27 09:56:29 appldev noship $ */

--
--This package procedure is created in order to use the transaction manager.
--after each mobile UI transaction has been performed to keep the inventory
--updated.




	FUNCTION IS_SERIAL_HIDDEN(p_Serial_Number_Control_Code IN NUMBER)
				  RETURN VARCHAR2;

	FUNCTION IS_SER_TRIG_ISSUE(p_Transaction_Action_Id IN NUMBER,
				   p_Serial_Number_Control_Code IN NUMBER)
				   RETURN VARCHAR2;

	FUNCTION IS_ACCT_HIDDEN(p_Transaction_Source_Type_Id IN NUMBER,
				p_Transaction_Action_Id IN NUMBER)
				RETURN VARCHAR2;

	FUNCTION IS_ACCT_ALIAS_HIDDEN(p_Transaction_Source_Type_Id IN NUMBER,
				      p_Transaction_Action_Id IN NUMBER)
					RETURN VARCHAR2;

	--only for serial triggered issues/sub xfers
	FUNCTION IS_SUB_HIDDEN(p_Transaction_Action_Id IN NUMBER,
			       p_Serial_Number_Control_Code IN NUMBER)
			       RETURN VARCHAR2;

	FUNCTION IS_LOCATOR_HIDDEN(p_Location_Control_Code IN NUMBER,
				   p_Organization_Id IN NUMBER,
				   p_Subinventory_Code IN VARCHAR2)
				   RETURN VARCHAR2;

	FUNCTION IS_FROM_LOCATOR_HIDDEN(p_Transaction_Action_Id IN NUMBER,
				   p_Serial_Number_Control_Code IN NUMBER,
				   p_Location_Control_Code IN NUMBER,
				   p_Organization_Id IN NUMBER,
				   p_Subinventory_Code IN VARCHAR2)
				   RETURN VARCHAR2;

	FUNCTION IS_REVISION_HIDDEN(p_Transaction_Action_Id IN NUMBER,
				    p_Serial_Number_Control_Code IN NUMBER,
			       	    p_Revision_Qty_Control_Code IN NUMBER)
			           RETURN VARCHAR2;

	FUNCTION IS_LOT_HIDDEN(	p_Transaction_Action_Id IN NUMBER,
				p_Serial_Number_Control_Code IN NUMBER,
				p_Lot_Control_Code IN NUMBER)
			      RETURN VARCHAR2;



	FUNCTION IS_TO_ORG_HIDDEN(p_Transaction_Action_Id IN NUMBER)
				  RETURN VARCHAR2;

	FUNCTION IS_TO_LOC_HIDDEN(p_Location_Control_Code IN NUMBER,
				  p_Organization_Id IN NUMBER,
				  p_Subinventory_Code IN VARCHAR2,
				  p_Transaction_Action_Id IN NUMBER,
				  p_To_Organization_Id IN NUMBER,
				  p_Inventory_Item_Id IN NUMBER)
				  RETURN VARCHAR2;

	FUNCTION IS_TO_SUB_HIDDEN(p_Transaction_Action_Id IN NUMBER,
				  p_done IN VARCHAR2)
				  RETURN VARCHAR2;


	FUNCTION IS_PROCESS_HIDDEN(p_Process_Flag IN VARCHAR2)
				  RETURN VARCHAR2;


END INV_TRANSACTION_HIDDEN;

 

/
