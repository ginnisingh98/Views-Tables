--------------------------------------------------------
--  DDL for Package Body OE_SO_PLD_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SO_PLD_PACKAGE" AS
/* $Header: oexspldb.pls 115.1 99/07/16 08:30:17 porting shi $ */

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
				) is
begin

	Result := 'Y';

	SELECT      requested_quantity
	        ,   warehouse_id
		,   schedule_date
		,   subinventory
		,   lot_number
		,   revision
	        ,   demand_class_code
	INTO
		    P_Db_Requested_Quantity
	        ,   P_Db_Warehouse_Id
	        ,   P_Db_Schedule_Date
		,   P_Db_Subinventory
		,   P_Db_Lot_Number
		,   P_Db_Revision
	        ,   P_Db_Demand_Class_Code
	FROM    SO_PICKING_LINE_DETAILS
	WHERE   rowid = X_Row_Id;

exception
  when NO_DATA_FOUND then
    Return;
  when OTHERS then
    OE_MSG.Internal_Exception
	('OE_SO_PLD_PACKAGE.Get_Schedule_DB_Values',
	'Get_DB_Values', 'PICKING_LINE_DETAIL');
    Result := 'N';
end Get_Schedule_DB_Values;



--
-- The When_Validate_Record function does the validation logic
-- Here are the rules for the validation.
--
--  * You cannot specify lot or revision unless placing a reservation.
--
--  * For placing reservations or reserved lines,  the following rules
--    must be obeyed:
--
--	* If Revision Control is turned ON,  then if a revision is
--          specified,  then the Lot and Subinventory must also be
--          specified.
--
--	* If Lot Control is turned ON, then if a Lot Number is
--          specified,  then so must be a Subinventory.
--
--
--
--  * You cannot undemand, unreserve or unschedule while changing the
--    warehouse, schedule date or demand class.
--
--  * You cannot undemand, unreserve, unschedule or ATP inquiry while
--    changing the quantity, subinventory, lot or revision.
--

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
	)
is
	Result VARCHAR2(1) := 'Y';

begin

	P_Result := 'Y';

	OE_SO_PLD_PACKAGE.Get_Schedule_DB_Values
		(
		    X_Row_Id,
		    P_Db_Requested_Quantity,
		    P_Db_Warehouse_Id,
		    P_Db_Schedule_Date,
		    P_Db_Subinventory,
		    P_Db_Lot_Number,
		    P_Db_Revision,
	            P_Db_Demand_Class_Code,
		    Result
		);

	if (Result = 'N') then
		P_Result := 'N';
		Return;
	end if;


	OE_LINE_DETAILS_PKG.Validate_Scheduling_Attributes
		(
		  P_Db_Record_Flag,
		  P_Db_Requested_Quantity,
		  P_Db_Warehouse_Id,
		  P_Db_Schedule_Date,
		  P_Db_Subinventory,
		  P_Db_Revision,
		  P_Db_Lot_Number,
		  P_Db_Demand_Class_Code,
		  P_Requested_Quantity,
		  P_Warehouse_Id,
		  P_Schedule_Date,
		  P_Subinventory,
		  P_Revision,
		  P_Lot_Number,
		  P_Demand_Class_Code,
		  P_Revision_Control_Flag,
		  P_Lot_Control_Flag,
		  P_Schedule_Action_Code,
		  P_Schedule_Status_Code,
		  Result
		);

	if (Result = 'N') then
		P_Result := 'N';
	end if;

	Return;

exception
  when OTHERS then
    OE_MSG.Internal_Exception
	('OE_SO_PLD_PACKAGE.When_Validate_Record',
	'When-Validate-Record', 'PICKING_LINE_DETAIL');
    Result := 'N';

end When_Validate_Record;

END OE_SO_PLD_PACKAGE;

/
