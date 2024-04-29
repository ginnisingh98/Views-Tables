--------------------------------------------------------
--  DDL for Package Body OE_LINE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_DETAILS_PKG" AS
/* $Header: oexdetb.pls 115.2 99/07/16 08:28:53 porting shi $ */
    PROCEDURE Raise_Exception
	(
		Routine    IN VARCHAR2,
		Operation  IN VARCHAR2,
		Message    IN VARCHAR2
	) IS

	x	BOOLEAN;

     BEGIN
	x :=OE_MSG.Set_Buffer_Message('OE_EXC_INTERNAL_EXCEPTION',
				'ROUTINE', Routine);
	x :=OE_MSG.Set_Buffer_Message('OE_EXC_INTERNAL_EXCEPTION',
				'OPERATION', Operation);
	x :=OE_MSG.Set_Buffer_Message('OE_EXC_INTERNAL_EXCEPTION',
				'MESSAGE',Message|| ' sqlcode:'||SQLCODE);

    END Raise_Exception;


    PROCEDURE Manually_Insert_Detail
         (      P_Line_Detail_Id			NUMBER,
		P_Creation_Date			IN OUT  DATE,
                P_Created_By				NUMBER,
		P_Last_Update_Date		IN OUT  DATE,
                P_Last_Updated_By			NUMBER,
                P_Last_Update_Login			NUMBER,
                P_Line_Id				NUMBER,
                P_Inventory_Item_Id			NUMBER,
                P_Component_Sequence_Id			NUMBER,
                P_Component_Code			VARCHAR2,
                P_Quantity				NUMBER,
                P_Schedule_Date				DATE,
                P_Lot_Number				VARCHAR2,
                P_Subinventory				VARCHAR2,
                P_Warehouse_Id				NUMBER,
                P_Revision				VARCHAR2,
                P_Customer_Requested_Lot_Flag		VARCHAR2,
                P_Schedule_Status_Code			VARCHAR2,
                P_Context				VARCHAR2,
                P_Attribute1				VARCHAR2,
                P_Attribute2				VARCHAR2,
                P_Attribute3				VARCHAR2,
                P_Attribute4				VARCHAR2,
                P_Attribute5				VARCHAR2,
                P_Attribute6				VARCHAR2,
                P_Attribute7				VARCHAR2,
                P_Attribute8				VARCHAR2,
                P_Attribute9				VARCHAR2,
                P_Attribute10				VARCHAR2,
                P_Attribute11				VARCHAR2,
                P_Attribute12				VARCHAR2,
                P_Attribute13				VARCHAR2,
                P_Attribute14				VARCHAR2,
                P_Attribute15				VARCHAR2,
                P_Included_Item_Flag			VARCHAR2,
                P_Component_Ratio			NUMBER,
                P_Shippable_Flag			VARCHAR2,
                P_Transactable_Flag			VARCHAR2,
                P_Reservable_Flag			VARCHAR2,
                P_Released_Flag				VARCHAR2,
                P_Demand_Class_Code			VARCHAR2,
                P_Unit_Code				VARCHAR2,
                P_Required_For_Revenue_Flag  IN OUT	VARCHAR2,
                P_Quantity_Svrid			NUMBER,
                P_Warehouse_Svrid			NUMBER,
                P_Demand_Class_Svrid			NUMBER,
                P_Date_Svrid				NUMBER,
                P_Customer_Requested_Svrid		NUMBER,
                P_Df_Svrid				NUMBER,
                P_Delivery				NUMBER,
                P_Update_Flag				VARCHAR2,
                P_Configuration_Item_Flag		VARCHAR2,
		P_Result			IN OUT  VARCHAR2,
		P_Dpw_Assigned_Flag			VARCHAR2 DEFAULT 'N'
		) IS
   temp_sysdate DATE;
   is_option VARCHAR2(1);
   Cursor chk_for_option is
    SELECT 'Y'
    FROM SO_LINES L, SO_LINE_DETAILS D
    WHERE L.LINE_ID = D.LINE_ID
    AND D.LINE_DETAIL_ID = P_Line_Detail_Id
    AND L.OPTION_FLAG = 'Y';
BEGIN

        SELECT SYSDATE
        INTO   temp_sysdate
        FROM   DUAL;

	   P_Creation_Date    := temp_sysdate;
        P_Last_Update_Date := temp_sysdate;

      OPEN chk_for_option;
	 FETCH chk_for_option into is_option;
	 if is_option = 'Y' OR
	   P_Included_Item_Flag  = 'Y' THEN
	      SELECT DECODE( REQUIRED_FOR_REVENUE, 1, 'Y', 'N' )
	      INTO  P_Required_For_Revenue_Flag
	      FROM   BOM_INVENTORY_COMPONENTS
	      WHERE  COMPONENT_SEQUENCE_ID = P_Component_Sequence_Id;
     else
         P_Required_For_Revenue_Flag := 'Y';
     end if;



	INSERT INTO SO_LINE_DETAILS
         (      LINE_DETAIL_ID,
		CREATION_DATE,
                CREATED_BY,
		LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN,
                LINE_ID,
                INVENTORY_ITEM_ID,
                COMPONENT_SEQUENCE_ID,
                COMPONENT_CODE,
                QUANTITY,
                SCHEDULE_DATE,
                LOT_NUMBER,
                SUBINVENTORY,
                WAREHOUSE_ID,
                REVISION,
                CUSTOMER_REQUESTED_LOT_FLAG,
                SCHEDULE_STATUS_CODE,
                CONTEXT,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
                INCLUDED_ITEM_FLAG,
                COMPONENT_RATIO,
                SHIPPABLE_FLAG,
                TRANSACTABLE_FLAG,
                RESERVABLE_FLAG,
                RELEASED_FLAG,
                DEMAND_CLASS_CODE,
                UNIT_CODE,
                REQUIRED_FOR_REVENUE_FLAG,
                QUANTITY_SVRID,
                WAREHOUSE_SVRID,
                DEMAND_CLASS_SVRID,
                DATE_SVRID,
                CUSTOMER_REQUESTED_SVRID,
                DF_SVRID,
                DELIVERY,
                UPDATE_FLAG,
                CONFIGURATION_ITEM_FLAG,
		DPW_ASSIGNED_FLAG)
	VALUES
         (      P_Line_Detail_Id,
		P_Creation_Date,
                P_Created_By,
		P_Last_Update_Date,
                P_Last_Updated_By,
                P_Last_Update_Login,
                P_Line_Id,
                P_Inventory_Item_Id,
                P_Component_Sequence_Id,
                P_Component_Code,
                P_Quantity,
                P_Schedule_Date,
                P_Lot_Number,
                P_Subinventory,
                P_Warehouse_Id,
                P_Revision,
                P_Customer_Requested_Lot_Flag,
                P_Schedule_Status_Code,
                P_Context,
                P_Attribute1,
                P_Attribute2,
                P_Attribute3,
                P_Attribute4,
                P_Attribute5,
                P_Attribute6,
                P_Attribute7,
                P_Attribute8,
                P_Attribute9,
                P_Attribute10,
                P_Attribute11,
                P_Attribute12,
                P_Attribute13,
                P_Attribute14,
                P_Attribute15,
                P_Included_Item_Flag,
                P_Component_Ratio,
                P_Shippable_Flag,
                P_Transactable_Flag,
                P_Reservable_Flag,
                P_Released_Flag,
                P_Demand_Class_Code,
                P_Unit_Code,
                P_Required_For_Revenue_Flag,
                P_Quantity_Svrid,
                P_Warehouse_Svrid,
                P_Demand_Class_Svrid,
                P_Date_Svrid,
                P_Customer_Requested_Svrid,
                P_Df_Svrid,
                P_Delivery,
                P_Update_Flag,
                P_Configuration_Item_Flag,
		P_Dpw_Assigned_Flag);

	P_Result := 'Y';

EXCEPTION
	WHEN OTHERS THEN
		P_Result := 'N';

		Raise_Exception ('OE_LINE_DETAILS_PKG.Insert_Manual_Detail',
				 '',
				 SQLERRM);

END Manually_Insert_Detail;


/*
----------------------------------------------------------------------
  This procedure validates the scheduling attributes for a line
  detail.

  Here are the rules for this function:

  * You cannot specify lot or revision unless placing a reservation.

  * For placing reservations or reserved lines,  the following rules
    must be obeyed:

	* If Revision Control is turned ON,  then if a revision is
          specified,  then the Lot and Subinventory must also be
          specified.

	* If Lot Control is turned ON, then if a Lot Number is
          specified,  then so must be a Subinventory.



  * You cannot undemand, unreserve or unschedule while changing the
    warehouse, schedule date or demand class.

  * You cannot undemand, unreserve, unschedule or ATP inquiry while
    changing the quantity, subinventory, lot or revision.


----------------------------------------------------------------------
*/

  PROCEDURE Validate_Scheduling_Attributes
	(
		P_DB_RECORD_FLAG		VARCHAR2,
		P_DB_QUANTITY			NUMBER,
		P_DB_WAREHOUSE_ID		NUMBER,
		P_DB_SCHEDULE_DATE		DATE,
		P_DB_SUBINVENTORY		VARCHAR2,
		P_DB_REVISION			VARCHAR2,
		P_DB_LOT_NUMBER			VARCHAR2,
		P_DB_DEMAND_CLASS_CODE		VARCHAR2,
		P_QUANTITY			NUMBER,
		P_WAREHOUSE_ID			NUMBER,
		P_SCHEDULE_DATE			DATE,
		P_SUBINVENTORY			VARCHAR2,
		P_REVISION			VARCHAR2,
		P_LOT_NUMBER			VARCHAR2,
		P_DEMAND_CLASS_CODE		VARCHAR2,
		P_REVISION_CONTROL_FLAG		VARCHAR2,
		P_LOT_CONTROL_FLAG		VARCHAR2,
		P_SCHEDULE_ACTION_CODE		VARCHAR2,
		P_SCHEDULE_STATUS_CODE		VARCHAR2,
		P_RESULT		IN OUT	VARCHAR2
	) IS


  Success_Flag	BOOLEAN := TRUE;

/*
----------------------------------------------------------------------

This local function returns TRUE if both lot and revision are null
Otherwise, it sets the message 'OE_SCH_LOT_REV_EXIST' and returns
FALSE

----------------------------------------------------------------------
*/
  FUNCTION Check_Rev_Lot_Null RETURN BOOLEAN IS
  BEGIN


    IF (P_Lot_Number IS NULL) and (P_Revision IS NULL) THEN

      Return (TRUE);

    END IF;

    OE_MSG.Set_Buffer_Message('OE_SCH_LOT_REV_EXIST');
    Return (FALSE);

  END Check_Rev_Lot_Null;

/*
----------------------------------------------------------------------

This local function checks for revision control.  If revision control
flag is turned on, then if a revision is specified, so must be a lot,
and a subinventory.

----------------------------------------------------------------------
*/
  FUNCTION Check_Revision_Control RETURN BOOLEAN IS
  BEGIN

    IF (P_Revision_Control_Flag = 'Y') THEN

      IF (P_Revision IS NULL) AND
         ((P_Lot_Number IS NOT NULL) OR (P_Subinventory IS NOT NULL)) THEN

        OE_MSG.Set_Buffer_Message('OE_SCH_ENTER_REVISION');
        Return (FALSE);

      END IF;

    END IF;

    RETURN (TRUE);

  END Check_Revision_Control;



/*
----------------------------------------------------------------------
This function checks for Lot Control.  If a lot is specified while
the lot control is turned on,  then a subinventory must also be
specified.
----------------------------------------------------------------------
*/
  FUNCTION Check_Lot_Control RETURN BOOLEAN IS
  BEGIN

    IF (P_Lot_Control_Flag = 'Y') THEN

      IF (P_Lot_Number IS NULL) AND
         (P_Subinventory IS NOT NULL) THEN

        OE_MSG.Set_Buffer_Message('OE_SCH_ENTER_LOT');
        Return(FALSE);

      END IF;

    END IF;

    Return (TRUE);

  END Check_Lot_Control;


/*
----------------------------------------------------------------------
This function makes sure that Revision and Lot controls are not
violated.
----------------------------------------------------------------------
*/
  FUNCTION Check_Controls RETURN BOOLEAN IS
  BEGIN


    Return (Check_Revision_Control) AND
           (Check_Lot_Control);


  END Check_Controls;



/*
----------------------------------------------------------------------
Logic for if schedule action is NULL.
----------------------------------------------------------------------
*/
  FUNCTION Check_Null_Action RETURN BOOLEAN IS
  BEGIN


/*
  If the line is already demanded, then make sure that you have not
  specified any lot or revision.
*/
    IF (P_Schedule_Status_Code IS NULL) OR
       (P_Schedule_Status_Code = 'DEMANDED') THEN

	Return (Check_Rev_Lot_Null);


/*
  If the line is reserved, make sure that revision and lot control are
  not violated.
*/
    ELSIF (P_Schedule_Status_Code = 'RESERVED') THEN

        Return (Check_Controls);

    END IF;

    Return (TRUE);

  END Check_Null_Action;



/*
----------------------------------------------------------------------
  This function makes sure that revision and lot do not conflict with
  the schedule action or the existing schedule status.
----------------------------------------------------------------------
*/
  FUNCTION Check_Revision_Lot RETURN BOOLEAN IS

    Rev_Lot_Passed_Flag  BOOLEAN := TRUE;

  BEGIN

    IF (P_Schedule_Action_Code) IN ('DEMAND', 'ATP CHECK') THEN

      Rev_Lot_Passed_Flag := Check_Rev_Lot_Null;

    ELSIF (P_Schedule_Action_Code = 'RESERVE') THEN

      Rev_Lot_Passed_Flag := Check_Controls;

    ELSIF (P_Schedule_Action_Code IS NULL) THEN

      Rev_Lot_Passed_Flag := Check_Null_Action;

    END IF;


    RETURN Rev_Lot_Passed_Flag;


  END Check_Revision_Lot;


  FUNCTION Warehouse_Not_Changed RETURN BOOLEAN IS
  BEGIN

    IF (P_Warehouse_ID  <> P_DB_Warehouse_ID) THEN

      OE_MSG.Set_Buffer_Message('OE_SCH_WH_CHG_NOT_ALLOWED');
      Return (FALSE);

    END IF;

    Return (TRUE);

  END Warehouse_Not_Changed;


  FUNCTION Schedule_Date_Not_Changed RETURN BOOLEAN IS
  BEGIN

    IF (P_Schedule_Date  <> P_DB_Schedule_Date) THEN

      OE_MSG.Set_Buffer_Message('OE_SCH_DATE_CHG_NOT_ALLOWED');
      Return (FALSE);

    END IF;

    Return (TRUE);

  END Schedule_Date_Not_Changed;

  FUNCTION Demand_Class_Not_Changed RETURN BOOLEAN IS
  BEGIN

    IF (P_Demand_Class_Code  <> P_DB_Demand_Class_Code) THEN

      OE_MSG.Set_Buffer_Message('OE_SCH_DEM_CL_CHG_NOT_ALLOWED');
      Return (FALSE);

    END IF;

    Return (TRUE);

  END Demand_Class_Not_Changed;


  FUNCTION Quantity_Not_Changed RETURN BOOLEAN IS
  BEGIN

    IF (P_Quantity  <> P_DB_Quantity) THEN

      OE_MSG.Set_Buffer_Message('OE_SCH_RES_QTY_CHG_NOT_ALLOWED');
      Return (FALSE);

    END IF;

    Return (TRUE);

  END Quantity_Not_Changed;



  FUNCTION Subinventory_Not_Changed RETURN BOOLEAN IS
  BEGIN

    IF (P_Subinventory  <> P_DB_Subinventory) THEN

      OE_MSG.Set_Buffer_Message('OE_SCH_SUBINV_CHG_NOT_ALLOWED');
      Return (FALSE);

    END IF;

    Return (TRUE);

  END Subinventory_Not_Changed;


  FUNCTION Lot_Not_Changed RETURN BOOLEAN IS
  BEGIN

    IF (P_Lot_Number  <> P_DB_Lot_Number) THEN

      OE_MSG.Set_Buffer_Message('OE_SCH_LOT_CHG_NOT_ALLOWED');
      Return (FALSE);

    END IF;

    Return (TRUE);

  END Lot_Not_Changed;


  FUNCTION Revision_Not_Changed RETURN BOOLEAN IS
  BEGIN

    IF (P_Revision  <> P_DB_Revision) THEN

      OE_MSG.Set_Buffer_Message('OE_SCH_REV_CHG_NOT_ALLOWED');
      Return (FALSE);

    END IF;

    Return (TRUE);

  END Revision_Not_Changed;


/*
  Beginning of validate_scheduling_attributes
*/

  BEGIN

    Success_Flag := Check_Revision_Lot;

    IF (Success_Flag) THEN

      IF (P_Schedule_Action_Code IS NOT NULL) AND
         (P_DB_Record_Flag  =  'Y') THEN

        IF (P_Schedule_Action_Code IN
                  ('UNDEMAND', 'UNRESERVE', 'UNSCHEDULE', 'ATP CHECK')) THEN

/*
   The following statement is interesting.  The order of the clauses is
   very important.  If user is undemanding or unreserving, it cannot
   be combined with a change of warehouse, schedule_date, or demand_class.
*/

          IF (P_Schedule_Action_Code <> 'ATP CHECK') THEN

            Success_Flag := (Warehouse_Not_Changed) AND
		            (Schedule_Date_Not_Changed) AND
		            (Demand_Class_Not_Changed);

          END IF;

/*
   Similar to above, the order of the and clauses is important.
   If the action is undo something, or ATP inquiry, then users
   cannot modify quantity, subinventory, lot or revision either!
*/

	  IF (Success_Flag) THEN

            Success_Flag := (Quantity_Not_Changed) AND
                            (Subinventory_Not_Changed) AND
                            (Lot_Not_Changed) AND
                            (Revision_Not_Changed);

          END IF;

        END IF;  -- UN Actions or ATP Check

      END IF; -- DB_Record_Flag

    END IF; -- IF Success_Flag


    IF (Success_Flag) THEN
      P_Result := 'Y';
    ELSE
      P_Result := 'N';
    END IF;

    RETURN;

  END Validate_Scheduling_Attributes;


END OE_LINE_DETAILS_PKG;

/
