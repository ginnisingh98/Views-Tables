--------------------------------------------------------
--  DDL for Package OE_SO_PLD_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SO_PLD_PACKAGE" AUTHID CURRENT_USER AS
/* $Header: oexsplds.pls 115.1 99/07/16 08:30:20 porting shi $ */

PROCEDURE Get_Schedule_DB_Values(
		    X_Row_Id			  IN  VARCHAR2
		,   P_Db_Requested_Quantity	  OUT NUMBER
	        ,   P_Db_Warehouse_Id		  OUT NUMBER
		,   P_Db_Schedule_Date		  OUT DATE
		,   P_Db_Subinventory		  OUT VARCHAR2
		,   P_Db_Lot_Number		  OUT VARCHAR2
		,   P_Db_Revision		  OUT VARCHAR2
	        ,   P_Db_Demand_Class_Code	  OUT VARCHAR2
		,   Result			  OUT VARCHAR2
				);
PROCEDURE When_Validate_Record
	(
		    X_Row_Id			IN	VARCHAR2,
		    P_Db_Record_Flag		IN	VARCHAR2,
		    P_Db_Requested_Quantity	IN OUT 	NUMBER,
		    P_Db_Warehouse_Id		IN OUT 	NUMBER,
		    P_Db_Schedule_Date		IN OUT 	DATE,
		    P_Db_Subinventory		IN OUT 	VARCHAR2,
		    P_Db_Lot_Number		IN OUT 	VARCHAR2,
		    P_Db_Revision		IN OUT 	VARCHAR2,
	            P_Db_Demand_Class_Code	IN OUT 	VARCHAR2,
		    P_Requested_Quantity	IN	NUMBER,
		    P_Warehouse_Id		IN	NUMBER,
		    P_Schedule_Date		IN	DATE,
		    P_Subinventory		IN	VARCHAR2,
		    P_Revision			IN	VARCHAR2,
		    P_Lot_Number		IN	VARCHAR2,
		    P_Demand_Class_Code		IN	VARCHAR2,
		    P_Revision_Control_Flag	IN	VARCHAR2,
		    P_Lot_Control_Flag		IN	VARCHAR2,
		    P_Schedule_Action_Code	IN	VARCHAR2,
		    P_Schedule_Status_Code	IN	VARCHAR2,
		    P_Result			OUT 	VARCHAR2
);

END OE_SO_PLD_PACKAGE;

 

/
