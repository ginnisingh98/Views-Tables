--------------------------------------------------------
--  DDL for Package Body WSH_SC_PLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SC_PLD_PKG" as
/* $Header: WSHSCPDB.pls 115.5 99/07/16 08:20:47 porting shi $ */

--
-- Package
--      WSH_SC_PLD_PKG
--
-- Purpose
--     	This package is used by the confirm delivery form to update
--	serial number information (details) entered on a delivery line
--	and do the explosion of the serial numbers if necessary.
-- History
--	Version	1.0	03/01/97	RMANJUNA
--
  --
  -- Name
  -- 	Close_Details
  -- Purpose
  --    To update picking line details with information entered in the
  --    serial number window.
  --
  --
  -- Arguments
  --
  --
  --
  -- Notes

PROCEDURE Close_Details(X_Delivery_Id	IN NUMBER)
IS
  x_picking_line_id 		NUMBER;
  x_picking_line_detail_id	NUMBER;
  x_split_detail_id		NUMBER;
  x_trx_qty			NUMBER;
  x_req_qty			NUMBER;
  x_new_req_qty			NUMBER;
  x_new_trx_qty			NUMBER;
  x_explode_flag		NUMBER;
  x_serial_number		varchar2(30);
  --get the picking line details for this Delivery
  CURSOR picking_line_details_cursor IS
  	SELECT picking_line_detail_id, requested_quantity, shipped_quantity,
	       serial_number
  	FROM   so_picking_line_details
	WHERE  delivery_id  = X_Delivery_Id
	AND    transaction_temp_id IS NOT NULL;

  -- to check if the item is under serial number control
  CURSOR check_serial(X_Pk_Line_Detail_Id NUMBER) is
	SELECT	msi.serial_number_control_code
	FROM	mtl_system_items msi,
		so_picking_lines_all pl,
		so_picking_line_details pld
	WHERE	pl.inventory_item_id = msi.inventory_item_id
	AND	pl.warehouse_id = msi.organization_id
	AND	msi.serial_number_control_code in (2,5,6)
	AND     pl.picking_line_id = pld.picking_line_id
	AND   	pld.picking_line_detail_id = X_Pk_Line_Detail_Id;
BEGIN

--  X_Error := 0;

  OPEN picking_line_details_cursor;
  LOOP
    FETCH picking_line_details_cursor
    INTO x_picking_line_detail_id, x_req_qty,
	 x_trx_qty, x_serial_number ;
    EXIT WHEN picking_line_details_cursor%NOTFOUND;
    IF (x_serial_number is NULL) then
     IF x_trx_qty < x_req_qty THEN
      -- Create remainder detail
      Create_Remainders(x_picking_line_detail_id, (x_req_qty - x_trx_qty));
     END IF;

     x_explode_flag := -1; -- initialize

     OPEN check_serial(x_picking_line_detail_id);

     FETCH check_serial INTO x_explode_flag;

     IF x_explode_flag > 0 THEN -- basically if x_explode flag is 2, 5 or 6
      -- Serial Number Explosion
      Explode_Lines(x_picking_line_detail_id);
     END IF;

     CLOSE check_serial;
    end if;

  END LOOP;

  CLOSE picking_line_details_cursor;

  -- Now go ahead and Delete the records from MSNT
  Delete_From_Msnt(X_Delivery_Id);

/*  donno if we need to do this
  IF (X_Error = 0) THEN
    SHP_SC_SERIAL_VALIDATION_PKG.Check_Duplicate_Serial(X_Entity_Id, X_Error, X_Error_Lines);
  END IF;
*/

EXCEPTION
    WHEN OTHERS THEN
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','SHP_SC_PLD_PKG.Close_Details');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;

END Close_Details;

  --
  -- Name
  -- 	Update_Details
  -- Purpose
  --    To update picking line details with information entered into the
  --    transaction block.
  -- Arguments
  -- 		X_Trx_Src_Line_Id	IN	NUMBER
  -- 		X_Requested_Qty		IN	NUMBER
  -- 		X_Shipped_Qty		IN	NUMBER
  --		X_Serial		IN	VARCHAR2
  --
  --
  -- Notes
  --


PROCEDURE Update_Details(  X_Trx_Src_Line_Id	IN	NUMBER,
			   X_Requested_Qty	IN	NUMBER,
			   X_Shipped_Qty	IN	NUMBER,
			   X_Serial		IN	VARCHAR2) IS
BEGIN

	UPDATE SO_PICKING_LINE_DETAILS PLD
	SET
 	(LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	LAST_UPDATE_LOGIN,
	REQUESTED_QUANTITY,
 	SHIPPED_QUANTITY,
 	SERIAL_NUMBER	 ) =
	(SELECT
	  SYSDATE,
	  FND_GLOBAL.USER_ID,
	  FND_GLOBAL.USER_ID,
	  X_Requested_Qty,
	  X_Shipped_Qty,
	  X_Serial
	 FROM DUAL)
	WHERE PICKING_LINE_DETAIL_ID = X_Trx_Src_Line_Id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	-- Replace this with real error? How to reflect in form?
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_PLD_PKG.Update_Details');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
    WHEN OTHERS THEN
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_PLD_PKG.Update_Details');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;

END Update_Details;

--
-- Purpose
--  This the used for split delivery line function to create a new
--  picking line details
--
FUNCTION Insert_Splitted_Details( X_Parent_Detail_Id	IN	NUMBER,
			   	  X_Req_Qty		IN	NUMBER,
				  X_detail_type_code    IN 	VARCHAR2)
RETURN NUMBER IS
  X_new_detail_id	NUMBER;
BEGIN
  SELECT SO_PICKING_LINE_DETAILS_S.NEXTVAL
  INTO X_new_detail_id
  FROM DUAL;

  Insert_Details( x_new_detail_id,
		  X_Parent_Detail_Id,
		  NULL,
	  	  X_Req_Qty,
		  NULL,
                  'SPLIT',
		  X_detail_type_code);

  return X_new_detail_id;
END Insert_Splitted_Details;

  --
  -- Name
  -- 	Insert_Details
  -- Purpose
  --    To insert new picking line details for details split on transaction
  --    block or entered in the serial number window.
  -- Arguments
  -- 		X_New_Detail_Id		IN	NUMBER
  --		X_Parent_Detail_Id	IN	NUMBER
  --	        X_Trx_Qty		IN	NUMBER
  --	        X_Req_Qty		IN	NUMBER
  --		X_Serial		IN	VARCHAR2
  --		X_Mode			IN	VARCHAR2
  --
  --
  --
  -- Notes
  --

PROCEDURE Insert_Details(  X_New_Detail_Id	IN	NUMBER,
			   X_Parent_Detail_Id	IN	NUMBER,
			   X_Trx_Qty		IN	NUMBER,
			   X_Req_Qty		IN	NUMBER,
			   X_Serial		IN	VARCHAR2,
			   X_Mode  		IN	VARCHAR2,
			   X_detail_type_code  	IN	VARCHAR2 DEFAULT 'NA')
IS
	X_Created_Detail_Id	NUMBER;
BEGIN


	IF (X_New_Detail_Id is NULL) THEN
		SELECT SO_PICKING_LINE_DETAILS_S.NEXTVAL
		INTO X_Created_Detail_Id
		FROM DUAL;
	END IF;

	INSERT INTO SO_PICKING_LINE_DETAILS (
	 PICKING_LINE_DETAIL_ID
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATE_LOGIN
	,PROGRAM_APPLICATION_ID
	,PROGRAM_ID
	,PROGRAM_UPDATE_DATE
	,REQUEST_ID
	,PICKING_LINE_ID
	,WAREHOUSE_ID
	,REQUESTED_QUANTITY
	,SHIPPED_QUANTITY
	,SERIAL_NUMBER
	,LOT_NUMBER
	,CUSTOMER_REQUESTED_LOT_FLAG
	,REVISION
	,SUBINVENTORY
	,INVENTORY_LOCATION_ID
	,SEGMENT1
	,SEGMENT2
	,SEGMENT3
	,SEGMENT4
	,SEGMENT5
	,SEGMENT6
	,SEGMENT7
	,SEGMENT8
	,SEGMENT9
	,SEGMENT10
	,SEGMENT11
	,SEGMENT12
	,SEGMENT13
	,SEGMENT14
	,SEGMENT15
	,SEGMENT16
	,SEGMENT17
	,SEGMENT18
	,SEGMENT19
	,SEGMENT20
	,INVENTORY_LOCATION_SEGMENTS
	,DETAIL_TYPE_CODE
	,CONTEXT
	,ATTRIBUTE1
	,ATTRIBUTE2
	,ATTRIBUTE3
	,ATTRIBUTE4
	,ATTRIBUTE5
	,ATTRIBUTE6
	,ATTRIBUTE7
	,ATTRIBUTE8
	,ATTRIBUTE9
	,ATTRIBUTE10
	,ATTRIBUTE11
	,ATTRIBUTE12
	,ATTRIBUTE13
	,ATTRIBUTE14
	,ATTRIBUTE15
	,RELEASED_FLAG
	,SCHEDULE_DATE
	,SCHEDULE_LEVEL
	,SCHEDULE_STATUS_CODE
	,DEMAND_ID
	,AUTOSCHEDULED_FLAG
	,DELIVERY
	,WIP_RESERVED_QUANTITY
	,WIP_COMPLETED_QUANTITY
	,SUPPLY_SOURCE_TYPE
	,SUPPLY_SOURCE_HEADER_ID
	,UPDATE_FLAG
	,DEMAND_CLASS_CODE
	,RESERVABLE_FLAG
	,TRANSACTABLE_FLAG
	,LATEST_ACCEPTABLE_DATE
	,DPW_ASSIGNED_FLAG
	,DELIVERY_ID
	,DEPARTURE_ID
	,LOAD_SEQ_NUMBER
	,MASTER_CONTAINER_ITEM_ID
	,DETAIL_CONTAINER_ITEM_ID
	,TRANSACTION_TEMP_ID
	,PICK_SLIP_NUMBER
	,CONTAINER_ID
	,MVT_STAT_STATUS)

	SELECT
	Nvl(X_New_Detail_id, X_Created_Detail_id)
	,SYSDATE
	,FND_GLOBAL.USER_ID
	,FND_GLOBAL.USER_ID
	,SYSDATE
	,FND_GLOBAL.LOGIN_ID
	,PROGRAM_APPLICATION_ID
	,PROGRAM_ID
	,PROGRAM_UPDATE_DATE
	,REQUEST_ID
	,PICKING_LINE_ID
	,WAREHOUSE_ID
	,X_Req_Qty
	,X_Trx_Qty
	,X_Serial
	,LOT_NUMBER
	,CUSTOMER_REQUESTED_LOT_FLAG
	,REVISION
	,SUBINVENTORY
	,INVENTORY_LOCATION_ID
	,SEGMENT1
	,SEGMENT2
	,SEGMENT3
	,SEGMENT4
	,SEGMENT5
	,SEGMENT6
	,SEGMENT7
	,SEGMENT8
	,SEGMENT9
	,SEGMENT10
	,SEGMENT11
	,SEGMENT12
	,SEGMENT13
	,SEGMENT14
	,SEGMENT15
	,SEGMENT16
	,SEGMENT17
	,SEGMENT18
	,SEGMENT19
	,SEGMENT20
	,INVENTORY_LOCATION_SEGMENTS
	,Decode( X_detail_type_code, 'NA', DETAIL_TYPE_CODE,
					   X_detail_type_code)
	,CONTEXT
	,ATTRIBUTE1
	,ATTRIBUTE2
	,ATTRIBUTE3
	,ATTRIBUTE4
	,ATTRIBUTE5
	,ATTRIBUTE6
	,ATTRIBUTE7
	,ATTRIBUTE8
	,ATTRIBUTE9
	,ATTRIBUTE10
	,ATTRIBUTE11
	,ATTRIBUTE12
	,ATTRIBUTE13
	,ATTRIBUTE14
	,ATTRIBUTE15
	,RELEASED_FLAG
	,SCHEDULE_DATE
	,SCHEDULE_LEVEL
	,SCHEDULE_STATUS_CODE
	,DEMAND_ID
	,AUTOSCHEDULED_FLAG
	,DELIVERY
	,WIP_RESERVED_QUANTITY
	,WIP_COMPLETED_QUANTITY
	,SUPPLY_SOURCE_TYPE
	,SUPPLY_SOURCE_HEADER_ID
	,UPDATE_FLAG
	,DEMAND_CLASS_CODE
	,RESERVABLE_FLAG
	,TRANSACTABLE_FLAG
	,LATEST_ACCEPTABLE_DATE
	,DPW_ASSIGNED_FLAG
	,DELIVERY_ID
	,DEPARTURE_ID
	,LOAD_SEQ_NUMBER
	,MASTER_CONTAINER_ITEM_ID
	,DETAIL_CONTAINER_ITEM_ID
	,decode(X_Mode,'REMAINDER', NULL,TRANSACTION_TEMP_ID)
	,PICK_SLIP_NUMBER
	,decode(X_Mode,'REMAINDER', NULL,CONTAINER_ID)
	,MVT_STAT_STATUS
	FROM SO_PICKING_LINE_DETAILS WHERE
	PICKING_LINE_DETAIL_ID = X_Parent_Detail_Id ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	-- Replace this with real error? How to reflect in form?
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_PLD_PKG.Insert_Details');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
    WHEN OTHERS THEN
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_PLD_PKG.Insert_Details');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;

END;


  --
  -- Name
  -- 	Create_Remainders
  -- Purpose
  --   To create a new detail for the remaining quantity when a partial quantity
  --   has been shipped for a reserved picking line.
  --
  -- Arguments
  -- 		X_Pick_Line_Detail_Id		IN	NUMBER
  --	        X_New_Requested		     	IN	NUMBER
  --
  -- Notes
  --

PROCEDURE Create_Remainders(X_Picking_Line_Detail_Id	NUMBER,
			    X_New_Requested		NUMBER ) IS
BEGIN

  -- insert the remainder detail in so_picking_line_details
  -- shipped quantity will be 0 since this remainder detail
  -- is for the unshipped quantity
  Insert_Details( NULL,
		  X_Picking_Line_Detail_Id,
		  0,
  	          X_New_Requested,
		  NULL ,
 		  'REMAINDER') ;

  --now update the requested quantity on the original picking_line_detail
  UPDATE so_picking_line_details pld
  SET    pld.requested_quantity = pld.shipped_quantity
  WHERE  pld.picking_line_detail_id = X_Picking_Line_Detail_Id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RETURN;
    WHEN OTHERS THEN
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_PLD_PKG.Create_Remainders');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
END;


  --
  -- Name
  --   Explode_Lines
  -- Purpose
  --   Takes individual lines from MTL_SERIAL_NUMBERS_TEMP that
  --   are under serial number control and explodes them into multiple
  --   lines based on the serial numbers entered.
  -- Arguments
  --   X_Picking_Line_Detail_Id for which is under Serial number
  --   control and hence must do the explosion
  --
  -- Notes
  --   Assumptions: The package assumes that it will be called when
  --                there is one line in SO_PICKING_LINE_DETAILS
  --		    for every line in MTL_SERIAL_NUMBERS_TEMP.
  --


  PROCEDURE Explode_Lines( X_Picking_Line_Detail_Id	IN	NUMBER)
  IS
	-- Cursor to get the serial line detail information that can be
	-- extracted from MSNT to be stored in SOPLD

	CURSOR	get_picking_line_detail(pk_line_detail_id NUMBER) IS
	SELECT	msnt.transaction_temp_id,
	  	pld.picking_line_detail_id,
		msnt.vendor_serial_number,
		msnt.fm_serial_number,
		msnt.to_serial_number,
		msnt.serial_prefix
	FROM	mtl_serial_numbers_temp msnt,
		so_picking_line_details pld
	WHERE	pld.picking_line_detail_id = pk_line_detail_id
	AND	pld.transaction_temp_id = msnt.transaction_temp_id(+)
        ORDER BY msnt.transaction_temp_id;

	I				NUMBER;
	X_Serial_Control_Code		NUMBER;
        X_transaction_temp_id		NUMBER;
        X_transaction_temp_id_old	NUMBER;
	X_trx_source_line_id		NUMBER;
	X_serial_number			VARCHAR2(30);
	X_fm_serial_number		VARCHAR2(30);
	X_to_serial_number		VARCHAR2(30);
	X_serial_qty			VARCHAR2(30);
	X_Serial_Current		VARCHAR2(30);
	X_Serial_Prefix			VARCHAR2(30);
	X_Serial_Numeric_Temp		VARCHAR2(30);
	X_Serial_Numeric		NUMBER;
	X_Serial_Numeric_Len		NUMBER;
        X_can_update			NUMBER;
        X_loop_end			NUMBER;

  BEGIN
   X_Transaction_temp_id_old := -1;
   -- Retrieve line detail info from MSNT using picking line_detail
   OPEN get_picking_line_detail(X_Picking_Line_Detail_Id);
   LOOP
     FETCH	get_picking_line_detail INTO
		X_transaction_temp_id,
		X_trx_source_line_id,
		X_serial_number,
		X_fm_serial_number,
		X_to_serial_number,
		X_serial_qty;
     EXIT WHEN get_picking_line_detail%NOTFOUND;
     IF  (X_serial_number IS NULL) THEN
             IF (X_transaction_temp_id <> X_transaction_temp_id_old) THEN
                  X_can_update := 1;
                  X_transaction_temp_id_old := X_transaction_temp_id;
             END IF;

             -- Determine the serial number prefix
             X_Serial_Prefix := rtrim(X_fm_serial_number, '0123456789');
             -- Determine the base numeric portion
             X_Serial_Numeric := to_number(substr(X_fm_serial_number,
				nvl(length(X_Serial_Prefix),0) + 1));

             -- Determine length of numeric portion
             X_Serial_Numeric_Len := length(substr(X_fm_serial_number,
				nvl(length(X_Serial_Prefix),0) + 1));

             -- Generate serial numbers to be inserted
             -- Get the first serial number
             X_Serial_Current := X_fm_serial_number;
             X_Serial_Numeric := X_Serial_Numeric - 1;
	     -- Update first picking line detail
             X_loop_end := to_number(X_serial_qty);
             IF (X_can_update = 1) THEN
	        Update_Details(X_trx_source_line_id,
			 1,
			 1,
			 X_Serial_Current);
                X_loop_end := to_number(X_serial_qty) - 1;
                X_can_update := 0;
                X_Serial_Numeric := X_Serial_Numeric + 1;
             END IF;
 	     -- Insert the rest of the line details
	     FOR I IN 1..X_loop_end LOOP
	          -- Determine next serial number
                  X_Serial_Current := Next_Serial(X_Serial_Prefix,
				 	  X_Serial_Numeric_Len,
					  X_Serial_Numeric);
                  X_Serial_Numeric := X_Serial_Numeric + 1;

                  Insert_Details(NULL,
		         X_trx_source_line_id,
			 1,
			 1,
			 X_Serial_Current,
			 'NEW');

	     END LOOP;
          END IF;
        END LOOP;
        CLOSE get_picking_line_detail;

  EXCEPTION
    WHEN OTHERS THEN
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_PDB_PKG.Explode_lines');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	APP_EXCEPTION.Raise_Exception;

  END Explode_Lines;

  --
  -- Name
  --   Next_Serial
  -- Purpose
  --   Takes a serial prefix, the length of the numeric portion of a serial
  --   number and the current value of the numeric portion and returns the
  --   next serial number.
  -- Arguments
  --   s_prefix is the serial number prefix
  --   s_num_length is the size of the numeric portion of the serial number
  --   s_num_current is the current vlaue of the numeric portion
  --
  -- Notes
  --    Uses the following algorithm:
  -- 	X_Serial_Current := X_Serial_Prefix || lpad('000000000000000000000000000000',
  --						    X_Serial_Numeric_Len -
  --						    length(to_char(X_Serial_Numeric + I))) ||
  --					       to_char(X_Serial_Numeric + I)
  --
  --


  FUNCTION Next_Serial (s_prefix      IN  VARCHAR2,
			s_num_length  IN  NUMBER,
			s_num_current IN  NUMBER
                       )
  RETURN VARCHAR2 IS
       X_new_serial	VARCHAR2(30);
  BEGIN
     select s_prefix || lpad('000000000000000000000000000000',
			     s_num_length - length(to_char(s_num_current + 1)))
                     || to_char(s_num_current + 1)
     into X_new_serial
     from dual;

     return(X_new_serial);

  END Next_Serial;

  --
  -- Name
  -- 	Delete_From_Msnt
  -- Purpose
  --   To Delete the temporary records created in MSNT by the Serial Number Entry Form
  --
  -- Arguments
  -- 		X_Delivery_Id		IN	NUMBER
  --
  -- Notes
  --

PROCEDURE Delete_From_Msnt(X_Delivery_Id	NUMBER ) IS

BEGIN

  DELETE FROM mtl_serial_numbers_temp
  WHERE transaction_temp_id in
  (SELECT transaction_temp_id
   FROM   so_picking_line_details
   WHERE  delivery_id = X_Delivery_Id );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RETURN;
    WHEN OTHERS THEN
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_SC_PLD_PKG.Delete_From_Msnt');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	FND_MESSAGE.Set_Token('ORA_TEXT',SQLERRM);
	APP_EXCEPTION.Raise_Exception;
END;
END WSH_SC_PLD_PKG;

/
