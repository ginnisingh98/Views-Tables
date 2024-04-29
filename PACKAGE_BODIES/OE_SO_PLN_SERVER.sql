--------------------------------------------------------
--  DDL for Package Body OE_SO_PLN_SERVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SO_PLN_SERVER" AS
/* $Header: OESOPLNB.pls 115.2 99/07/16 08:11:06 porting shi $ */

PROCEDURE When_Validate_Record
        (
                    X_Row_Id                    IN      VARCHAR2,
                    P_Picking_Line_Id		IN      NUMBER,
                    P_Db_Schedule_Date		IN OUT  DATE,
                    P_Db_Demand_Class_Code	IN OUT  VARCHAR2,
                    P_Db_Ship_To_Site_Use_Id	IN OUT  NUMBER,
                    P_Db_Warehouse_Id		IN OUT  NUMBER,
                    P_Db_Ship_To_Contact_Id	IN OUT  NUMBER,
                    P_Db_Shipment_Priority_Code	IN OUT  VARCHAR2,
                    P_Db_Ship_Method_Code	IN OUT  VARCHAR2,
                    P_Db_Reserved_Quantity	IN OUT  NUMBER,
                    P_Schedule_Action_Code	IN      VARCHAR2,
                    P_Schedule_Date             IN      DATE,
                    P_Demand_Class_Code		IN      VARCHAR2,
                    P_Ship_To_Site_Use_Id	IN      NUMBER,
                    P_Warehouse_Id		IN      NUMBER,
                    P_Ship_To_Contact_Id	IN      NUMBER,
                    P_Shipment_Priority_Code	IN      VARCHAR2,
                    P_Ship_Method_Code		IN      VARCHAR2,
                    P_Reserved_Quantity		IN      NUMBER,
                    P_Result                    OUT     VARCHAR2
        )
is
        Result VARCHAR2(1) := 'Y';
begin
        P_Result := 'Y';
        OE_SO_PLN_SERVER.Get_Schedule_DB_Values
                (
                    X_Row_Id,
		    P_Picking_Line_Id,
		    P_Db_Schedule_Date,
		    P_Db_Demand_Class_Code,
		    P_Db_Ship_To_Site_Use_Id,
		    P_Db_Warehouse_Id,
		    P_Db_Ship_To_Contact_Id,
		    P_Db_Shipment_Priority_Code,
		    P_Db_Ship_Method_Code,
                    P_Db_Reserved_Quantity,
                    Result
                );
        if (Result = 'N') then
                P_Result := 'N';
                Return;
        end if;
        if P_Schedule_Action_Code in ('RESERVE') then
                if P_Reserved_Quantity <> P_Db_Reserved_Quantity then
                  OE_MSG.Set_Buffer_Message('OE_SCH_RES_QTY_CHG_NOT_ALLOWED');
                end if;
	elsif P_Schedule_Action_Code in ('UNRESERVE','UNDEMAND','UNSCHEDULE') then
                if P_Warehouse_Id <> P_Db_Warehouse_Id then
                  OE_MSG.Set_Buffer_Message('OE_SCH_WH_CHG_NOT_ALLOWED');
                else
                  if P_Schedule_Date <> P_Db_Schedule_Date then
                    OE_MSG.Set_Buffer_Message('OE_SCH_DATE_CHG_NOT_ALLOWED');
                  else
                    if P_Demand_Class_Code <> P_Db_Demand_Class_Code then
                      OE_MSG.Set_Buffer_Message('OE_SCH_DEM_CL_CHG_NOT_ALLOWED');
                    end if;
                  end if;
                end if;
	elsif P_Schedule_Action_Code = 'DEMAND' then
                if P_Reserved_Quantity <> P_Db_Reserved_Quantity then
                  OE_MSG.Set_Buffer_Message('OE_SCH_RES_QTY_CHG_NOT_ALLOWED');
                else
                  if P_Warehouse_Id <> P_Db_Warehouse_Id then
                    OE_MSG.Set_Buffer_Message('OE_SCH_WH_CHG_NOT_ALLOWED');
                  else
                    if P_Schedule_Date <> P_Db_Schedule_Date then
                      OE_MSG.Set_Buffer_Message('OE_SCH_DATE_CHG_NOT_ALLOWED');
                    else
                      if P_Demand_Class_Code <> P_Db_Demand_Class_Code then
                        OE_MSG.Set_Buffer_Message('OE_SCH_DEM_CL_CHG_NOT_ALLOWED');
                      end if;
                    end if;
                  end if;
                end if;
	elsif P_Schedule_Action_Code = 'ATP CHECK' then
		if P_Ship_To_Site_Use_Id <> P_Db_Ship_To_Site_Use_Id then
		  OE_MSG.Set_Buffer_Message('OE_SCH_SHIP_TO_CHG_NOT_ALLOWED');
		else
		  if P_Reserved_Quantity <> P_Db_Reserved_Quantity then
		    OE_MSG.Set_Buffer_Message('OE_SCH_RES_QTY_CHG_NOT_ALLOWED');
		  else
		    if P_Warehouse_Id <> P_Db_Warehouse_Id then
    		      OE_MSG.Set_Buffer_Message('OE_SCH_WH_CHG_NOT_ALLOWED');
		    else
		      if P_Schedule_Date <> P_Db_Schedule_Date then
			OE_MSG.Set_Buffer_Message('OE_SCH_DATE_CHG_NOT_ALLOWED');
		      else
			if P_Demand_Class_Code <> P_Db_Demand_Class_Code then
			  OE_MSG.Set_Buffer_Message('OE_SCH_DEM_CL_CHG_NOT_ALLOWED');
			end if;
		      end if;
   		    end if;
		  end if;
		end if;
	  else
		null;
        end if;
        Return;

exception
  when OTHERS then
    OE_MSG.Internal_Exception
        ('OE_SO_PLN_SERVER.When_Validate_Record',
        'When-Validate-Record', 'PICKING_LINE');
    Result := 'N';
end When_Validate_Record;


FUNCTION DB_Reserved_Quantity (X_Picking_Line_Id IN NUMBER) return NUMBER is
  DB_Res_Qty NUMBER := 0;
begin

  SELECT  NVL(SUM ( NVL ( REQUESTED_QUANTITY , 0 ) ), 0)
  INTO    DB_Res_Qty
  FROM    SO_PICKING_LINE_DETAILS
  WHERE   SCHEDULE_STATUS_CODE = 'RESERVED'
  AND     PICKING_LINE_ID = X_Picking_Line_Id;

  Return (DB_Res_Qty);

exception

  when NO_DATA_FOUND then return(DB_Res_Qty);
  when OTHERS then RAISE;

end DB_Reserved_Quantity;

PROCEDURE Get_Schedule_DB_Values(
                    X_Row_Id                      IN  VARCHAR2
                ,   X_Picking_Line_Id                     IN  NUMBER
                ,   P_Db_Schedule_Date            OUT DATE
                ,   P_Db_Demand_Class_Code        OUT VARCHAR2
                ,   P_Db_Ship_To_Site_Use_Id      OUT NUMBER
                ,   P_Db_Warehouse_Id             OUT NUMBER
                ,   P_Db_Ship_To_Contact_Id       OUT NUMBER
                ,   P_Db_Shipment_Priority_Code   OUT VARCHAR2
                ,   P_Db_Ship_Method_Code         OUT VARCHAR2
                ,   P_Db_Reserved_Quantity        OUT NUMBER
                ,   Result                        OUT VARCHAR2
                ) is
begin

        Result := 'Y';

        SELECT      schedule_date
                ,   demand_class_code
                ,   ship_to_site_use_id
                ,   warehouse_id
                ,   ship_to_contact_id
                ,   shipment_priority_code
                ,   ship_method_code
        INTO        P_Db_Schedule_Date
                ,   P_Db_Demand_Class_Code
                ,   P_Db_Ship_To_Site_Use_Id
                ,   P_Db_Warehouse_Id
                ,   P_Db_Ship_To_Contact_Id
                ,   P_Db_Shipment_Priority_Code
                ,   P_Db_Ship_Method_Code
        FROM    SO_PICKING_LINES
        WHERE   rowid = X_Row_Id;

        P_Db_Reserved_Quantity :=
                OE_SO_PLN_SERVER.DB_Reserved_Quantity(X_Picking_Line_Id);

exception
  when OTHERS then
    OE_MSG.Internal_Exception('OE_SO_PLN_SERVER.Get_Schedule_DB_Values',
                                'Get_DB_Values', 'P_LINE');
    Result := 'N';
end Get_Schedule_DB_Values;


PROCEDURE Lock_Row(X_Rowid VARCHAR2,
    X_ATTRIBUTE1    VARCHAR2,
    X_ATTRIBUTE10    VARCHAR2,
    X_ATTRIBUTE11    VARCHAR2,
    X_ATTRIBUTE12    VARCHAR2,
    X_ATTRIBUTE13    VARCHAR2,
    X_ATTRIBUTE14    VARCHAR2,
    X_ATTRIBUTE15    VARCHAR2,
    X_ATTRIBUTE2    VARCHAR2,
    X_ATTRIBUTE3    VARCHAR2,
    X_ATTRIBUTE4    VARCHAR2,
    X_ATTRIBUTE5    VARCHAR2,
    X_ATTRIBUTE6    VARCHAR2,
    X_ATTRIBUTE7    VARCHAR2,
    X_ATTRIBUTE8    VARCHAR2,
    X_ATTRIBUTE9    VARCHAR2,
    X_CANCELLED_QUANTITY    NUMBER,
    X_COMPONENT_CODE    VARCHAR2,
    X_COMPONENT_RATIO    NUMBER,
    X_COMPONENT_SEQUENCE_ID    NUMBER,
    X_CONFIGURATION_ITEM_FLAG    VARCHAR2,
    X_CONTEXT    VARCHAR2,
    X_CREATED_BY    NUMBER,
    X_CREATION_DATE    DATE,
    X_DATE_CONFIRMED    DATE,
    X_DATE_REQUESTED    DATE,
    X_DEMAND_CLASS_CODE    VARCHAR2,
    X_INCLUDED_ITEM_FLAG    VARCHAR2,
    X_INVENTORY_ITEM_ID    NUMBER,
    X_INVENTORY_STATUS    VARCHAR2,
    X_INVOICED_QUANTITY    NUMBER,
    X_LAST_UPDATED_BY    NUMBER,
    X_LAST_UPDATE_DATE    DATE,
    X_LAST_UPDATE_LOGIN    NUMBER,
    X_LATEST_ACCEPTABLE_DATE    DATE,
    X_LINE_DETAIL_ID    NUMBER,
    X_ORDER_LINE_ID    NUMBER,
    X_ORGANIZATION_ID    NUMBER,
    X_ORIGINAL_REQUESTED_QUANTITY    NUMBER,
    X_PICKING_HEADER_ID    NUMBER,
    X_PICKING_LINE_ID    NUMBER,
    X_PROGRAM_APPLICATION_ID    NUMBER,
    X_PROGRAM_ID    NUMBER,
    X_PROGRAM_UPDATE_DATE    DATE,
    X_RA_INTERFACE_STATUS    VARCHAR2,
    X_REQUESTED_QUANTITY    NUMBER,
    X_REQUEST_ID    NUMBER,
    X_SCHEDULE_DATE    DATE,
    X_SEQUENCE_NUMBER    NUMBER,
    X_SHIPMENT_PRIORITY_CODE    VARCHAR2,
    X_SHIPPED_QUANTITY    NUMBER,
    X_SHIP_METHOD_CODE    VARCHAR2,
    X_SHIP_TO_CONTACT_ID    NUMBER,
    X_SHIP_TO_SITE_USE_ID    NUMBER,
    X_UNIT_CODE    VARCHAR2,
    X_WAREHOUSE_ID    NUMBER,
    Result OUT VARCHAR2)IS

CURSOR C IS SELECT * FROM so_picking_lines
WHERE rowid = X_rowid
FOR UPDATE NOWAIT;

Recinfo C%ROWTYPE;
record_changed exception;
resource_busy  exception;
record_deleted exception;

PRAGMA EXCEPTION_INIT (resource_busy, -54);

BEGIN
    OPEN C;

    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
        CLOSE C;
		raise record_deleted;
        -- APP_EXCEPTION.Raise_Exception;
    end if;

    CLOSE C;

    if (
        ((Recinfo.ATTRIBUTE1 <> X_ATTRIBUTE1)
          AND NOT (Recinfo.ATTRIBUTE1 is NULL AND X_ATTRIBUTE1 is NULL)) AND
        ((Recinfo.ATTRIBUTE10 <> X_ATTRIBUTE10)
          AND NOT (Recinfo.ATTRIBUTE10 is NULL AND X_ATTRIBUTE10 is NULL)) AND
        ((Recinfo.ATTRIBUTE11 <> X_ATTRIBUTE11)
          AND NOT (Recinfo.ATTRIBUTE11 is NULL AND X_ATTRIBUTE11 is NULL)) AND
        ((Recinfo.ATTRIBUTE12 <> X_ATTRIBUTE12)
          AND NOT (Recinfo.ATTRIBUTE12 is NULL AND X_ATTRIBUTE12 is NULL)) AND
        ((Recinfo.ATTRIBUTE13 <> X_ATTRIBUTE13)
          AND NOT (Recinfo.ATTRIBUTE13 is NULL AND X_ATTRIBUTE13 is NULL)) AND
        ((Recinfo.ATTRIBUTE14 <> X_ATTRIBUTE14)
          AND NOT (Recinfo.ATTRIBUTE14 is NULL AND X_ATTRIBUTE14 is NULL)) AND
        ((Recinfo.ATTRIBUTE15 <> X_ATTRIBUTE15)
          AND NOT (Recinfo.ATTRIBUTE15 is NULL AND X_ATTRIBUTE15 is NULL)) AND
        ((Recinfo.ATTRIBUTE2 <> X_ATTRIBUTE2)
          AND NOT (Recinfo.ATTRIBUTE2 is NULL AND X_ATTRIBUTE2 is NULL)) AND
        ((Recinfo.ATTRIBUTE3 <> X_ATTRIBUTE3)
          AND NOT (Recinfo.ATTRIBUTE3 is NULL AND X_ATTRIBUTE3 is NULL)) AND
        ((Recinfo.ATTRIBUTE4 <> X_ATTRIBUTE4)
          AND NOT (Recinfo.ATTRIBUTE4 is NULL AND X_ATTRIBUTE4 is NULL)) AND
        ((Recinfo.ATTRIBUTE5 <> X_ATTRIBUTE5)
          AND NOT (Recinfo.ATTRIBUTE5 is NULL AND X_ATTRIBUTE5 is NULL)) AND
        ((Recinfo.ATTRIBUTE6 <> X_ATTRIBUTE6)
          AND NOT (Recinfo.ATTRIBUTE6 is NULL AND X_ATTRIBUTE6 is NULL)) AND
        ((Recinfo.ATTRIBUTE7 <> X_ATTRIBUTE7)
          AND NOT (Recinfo.ATTRIBUTE7 is NULL AND X_ATTRIBUTE7 is NULL)) AND
        ((Recinfo.ATTRIBUTE8 <> X_ATTRIBUTE8)
          AND NOT (Recinfo.ATTRIBUTE8 is NULL AND X_ATTRIBUTE8 is NULL)) AND
        ((Recinfo.ATTRIBUTE9 <> X_ATTRIBUTE9)
          AND NOT (Recinfo.ATTRIBUTE9 is NULL AND X_ATTRIBUTE9 is NULL)) AND
        ((Recinfo.CANCELLED_QUANTITY <> X_CANCELLED_QUANTITY)
          AND NOT (Recinfo.CANCELLED_QUANTITY is NULL AND X_CANCELLED_QUANTITY is NULL)) AND
        ((Recinfo.COMPONENT_CODE <> X_COMPONENT_CODE)
          AND NOT (Recinfo.COMPONENT_CODE is NULL AND X_COMPONENT_CODE is NULL)) AND
        ((Recinfo.COMPONENT_RATIO <> X_COMPONENT_RATIO)
          AND NOT (Recinfo.COMPONENT_RATIO is NULL AND X_COMPONENT_RATIO is NULL)) AND
        ((Recinfo.COMPONENT_SEQUENCE_ID <> X_COMPONENT_SEQUENCE_ID)
          AND NOT (Recinfo.COMPONENT_SEQUENCE_ID is NULL AND X_COMPONENT_SEQUENCE_ID is NULL)) AND
        ((Recinfo.CONFIGURATION_ITEM_FLAG <> X_CONFIGURATION_ITEM_FLAG)
          AND NOT (Recinfo.CONFIGURATION_ITEM_FLAG is NULL AND X_CONFIGURATION_ITEM_FLAG is NULL))
    ) then
        raise record_changed;
    end if;

    if (
        ((Recinfo.CONTEXT <> X_CONTEXT)
          AND NOT (Recinfo.CONTEXT is NULL AND X_CONTEXT is NULL)) AND
        ((Recinfo.CREATED_BY <> X_CREATED_BY)
          AND NOT (Recinfo.CREATED_BY is NULL AND X_CREATED_BY is NULL)) AND
        ((Recinfo.CREATION_DATE <> X_CREATION_DATE)
          AND NOT (Recinfo.CREATION_DATE is NULL AND X_CREATION_DATE is NULL)) AND
        ((Recinfo.DATE_CONFIRMED <> X_DATE_CONFIRMED)
          AND NOT (Recinfo.DATE_CONFIRMED is NULL AND X_DATE_CONFIRMED is NULL)) AND
        ((Recinfo.DATE_REQUESTED <> X_DATE_REQUESTED)
          AND NOT (Recinfo.DATE_REQUESTED is NULL AND X_DATE_REQUESTED is NULL)) AND
        ((Recinfo.DEMAND_CLASS_CODE <> X_DEMAND_CLASS_CODE)
          AND NOT (Recinfo.DEMAND_CLASS_CODE is NULL AND X_DEMAND_CLASS_CODE is NULL)) AND
        ((Recinfo.INCLUDED_ITEM_FLAG <> X_INCLUDED_ITEM_FLAG)
          AND NOT (Recinfo.INCLUDED_ITEM_FLAG is NULL AND X_INCLUDED_ITEM_FLAG is NULL)) AND
        ((Recinfo.INVENTORY_ITEM_ID <> X_INVENTORY_ITEM_ID)
          AND NOT (Recinfo.INVENTORY_ITEM_ID is NULL AND X_INVENTORY_ITEM_ID is NULL)) AND
        ((Recinfo.INVENTORY_STATUS <> X_INVENTORY_STATUS)
          AND NOT (Recinfo.INVENTORY_STATUS is NULL AND X_INVENTORY_STATUS is NULL)) AND
        ((Recinfo.INVOICED_QUANTITY <> X_INVOICED_QUANTITY)
          AND NOT (Recinfo.INVOICED_QUANTITY is NULL AND X_INVOICED_QUANTITY is NULL)) AND
        ((Recinfo.LAST_UPDATED_BY <> X_LAST_UPDATED_BY)
          AND NOT (Recinfo.LAST_UPDATED_BY is NULL AND X_LAST_UPDATED_BY is NULL)) AND
        ((Recinfo.LAST_UPDATE_DATE <> X_LAST_UPDATE_DATE)
          AND NOT (Recinfo.LAST_UPDATE_DATE is NULL AND X_LAST_UPDATE_DATE is NULL)) AND
        ((Recinfo.LAST_UPDATE_LOGIN <> X_LAST_UPDATE_LOGIN)
          AND NOT (Recinfo.LAST_UPDATE_LOGIN is NULL AND X_LAST_UPDATE_LOGIN is NULL)) AND
        ((Recinfo.LATEST_ACCEPTABLE_DATE <> X_LATEST_ACCEPTABLE_DATE)
          AND NOT (Recinfo.LATEST_ACCEPTABLE_DATE is NULL AND X_LATEST_ACCEPTABLE_DATE is NULL)) AND
        ((Recinfo.LINE_DETAIL_ID <> X_LINE_DETAIL_ID)
          AND NOT (Recinfo.LINE_DETAIL_ID is NULL AND X_LINE_DETAIL_ID is NULL)) AND
        ((Recinfo.ORDER_LINE_ID <> X_ORDER_LINE_ID)
          AND NOT (Recinfo.ORDER_LINE_ID is NULL AND X_ORDER_LINE_ID is NULL)) AND
--        ((Recinfo.ORGANIZATION_ID <> X_ORGANIZATION_ID)
--          AND NOT (Recinfo.ORGANIZATION_ID is NULL AND X_ORGANIZATION_ID is NULL)) AND
        ((Recinfo.ORIGINAL_REQUESTED_QUANTITY <> X_ORIGINAL_REQUESTED_QUANTITY)
          AND NOT (Recinfo.ORIGINAL_REQUESTED_QUANTITY is NULL AND X_ORIGINAL_REQUESTED_QUANTITY is NULL))
    ) then
        raise record_changed;
    end if;

    if (
        ((Recinfo.PICKING_HEADER_ID <> X_PICKING_HEADER_ID)
          AND NOT (Recinfo.PICKING_HEADER_ID is NULL AND X_PICKING_HEADER_ID is NULL)) AND
        ((Recinfo.PICKING_LINE_ID <> X_PICKING_LINE_ID)
          AND NOT (Recinfo.PICKING_LINE_ID is NULL AND X_PICKING_LINE_ID is NULL)) AND
        ((Recinfo.PROGRAM_APPLICATION_ID <> X_PROGRAM_APPLICATION_ID)
          AND NOT (Recinfo.PROGRAM_APPLICATION_ID is NULL AND X_PROGRAM_APPLICATION_ID is NULL)) AND
        ((Recinfo.PROGRAM_ID <> X_PROGRAM_ID)
          AND NOT (Recinfo.PROGRAM_ID is NULL AND X_PROGRAM_ID is NULL)) AND
        ((Recinfo.PROGRAM_UPDATE_DATE <> X_PROGRAM_UPDATE_DATE)
          AND NOT (Recinfo.PROGRAM_UPDATE_DATE is NULL AND X_PROGRAM_UPDATE_DATE is NULL)) AND
        ((Recinfo.RA_INTERFACE_STATUS <> X_RA_INTERFACE_STATUS)
          AND NOT (Recinfo.RA_INTERFACE_STATUS is NULL AND X_RA_INTERFACE_STATUS is NULL)) AND
        ((Recinfo.REQUESTED_QUANTITY <> X_REQUESTED_QUANTITY)
          AND NOT (Recinfo.REQUESTED_QUANTITY is NULL AND X_REQUESTED_QUANTITY is NULL)) AND
        ((Recinfo.REQUEST_ID <> X_REQUEST_ID)
          AND NOT (Recinfo.REQUEST_ID is NULL AND X_REQUEST_ID is NULL)) AND
        ((Recinfo.SCHEDULE_DATE <> X_SCHEDULE_DATE)
          AND NOT (Recinfo.SCHEDULE_DATE is NULL AND X_SCHEDULE_DATE is NULL)) AND
        ((Recinfo.SEQUENCE_NUMBER <> X_SEQUENCE_NUMBER)
          AND NOT (Recinfo.SEQUENCE_NUMBER is NULL AND X_SEQUENCE_NUMBER is NULL)) AND
        ((Recinfo.SHIPMENT_PRIORITY_CODE <> X_SHIPMENT_PRIORITY_CODE)
          AND NOT (Recinfo.SHIPMENT_PRIORITY_CODE is NULL AND X_SHIPMENT_PRIORITY_CODE is NULL)) AND
        ((Recinfo.SHIPPED_QUANTITY <> X_SHIPPED_QUANTITY)
          AND NOT (Recinfo.SHIPPED_QUANTITY is NULL AND X_SHIPPED_QUANTITY is NULL)) AND
        ((Recinfo.SHIP_METHOD_CODE <> X_SHIP_METHOD_CODE)
          AND NOT (Recinfo.SHIP_METHOD_CODE is NULL AND X_SHIP_METHOD_CODE is NULL))
    ) then
        raise record_changed;
    end if;

    if (
        ((Recinfo.SHIP_TO_CONTACT_ID <> X_SHIP_TO_CONTACT_ID)
          AND NOT (Recinfo.SHIP_TO_CONTACT_ID is NULL AND X_SHIP_TO_CONTACT_ID is NULL)) AND
        ((Recinfo.SHIP_TO_SITE_USE_ID <> X_SHIP_TO_SITE_USE_ID)
          AND NOT (Recinfo.SHIP_TO_SITE_USE_ID is NULL AND X_SHIP_TO_SITE_USE_ID is NULL)) AND
        ((Recinfo.UNIT_CODE <> X_UNIT_CODE)
          AND NOT (Recinfo.UNIT_CODE is NULL AND X_UNIT_CODE is NULL)) AND
        ((Recinfo.WAREHOUSE_ID <> X_WAREHOUSE_ID)
          AND NOT (Recinfo.WAREHOUSE_ID is NULL AND X_WAREHOUSE_ID is NULL))
    ) then
        raise record_changed;
    end if;

    Result := 'SUCCESS';
exception
    when record_changed then
        Result := 'RECORD_CHANGED';
	when resource_busy then
		Result := 'RESOURCE_BUSY';
    when record_deleted then
		Result := 'RECORD_DELETED';
END Lock_Row;

PROCEDURE Update_Row(X_Rowid VARCHAR2,
    X_ATTRIBUTE1    VARCHAR2,
    X_ATTRIBUTE10    VARCHAR2,
    X_ATTRIBUTE11    VARCHAR2,
    X_ATTRIBUTE12    VARCHAR2,
    X_ATTRIBUTE13    VARCHAR2,
    X_ATTRIBUTE14    VARCHAR2,
    X_ATTRIBUTE15    VARCHAR2,
    X_ATTRIBUTE2    VARCHAR2,
    X_ATTRIBUTE3    VARCHAR2,
    X_ATTRIBUTE4    VARCHAR2,
    X_ATTRIBUTE5    VARCHAR2,
    X_ATTRIBUTE6    VARCHAR2,
    X_ATTRIBUTE7    VARCHAR2,
    X_ATTRIBUTE8    VARCHAR2,
    X_ATTRIBUTE9    VARCHAR2,
    X_CANCELLED_QUANTITY    NUMBER,
    X_COMPONENT_CODE    VARCHAR2,
    X_COMPONENT_RATIO    NUMBER,
    X_COMPONENT_SEQUENCE_ID    NUMBER,
    X_CONFIGURATION_ITEM_FLAG    VARCHAR2,
    X_CONTEXT    VARCHAR2,
    X_CREATED_BY    NUMBER,
    X_CREATION_DATE    DATE,
    X_DATE_CONFIRMED    DATE,
    X_DATE_REQUESTED    DATE,
    X_DEMAND_CLASS_CODE    VARCHAR2,
    X_INCLUDED_ITEM_FLAG    VARCHAR2,
    X_INVENTORY_ITEM_ID    NUMBER,
    X_INVENTORY_STATUS    VARCHAR2,
    X_INVOICED_QUANTITY    NUMBER,
    X_LAST_UPDATED_BY    NUMBER,
    X_LAST_UPDATE_DATE    DATE,
    X_LAST_UPDATE_LOGIN    NUMBER,
    X_LATEST_ACCEPTABLE_DATE    DATE,
    X_LINE_DETAIL_ID    NUMBER,
    X_ORDER_LINE_ID    NUMBER,
    X_ORGANIZATION_ID    NUMBER,
    X_ORIGINAL_REQUESTED_QUANTITY    NUMBER,
    X_PICKING_HEADER_ID    NUMBER,
    X_PICKING_LINE_ID    NUMBER,
    X_PROGRAM_APPLICATION_ID    NUMBER,
    X_PROGRAM_ID    NUMBER,
    X_PROGRAM_UPDATE_DATE    DATE,
    X_RA_INTERFACE_STATUS    VARCHAR2,
    X_REQUESTED_QUANTITY    NUMBER,
    X_REQUEST_ID    NUMBER,
    X_SCHEDULE_DATE    DATE,
    X_SEQUENCE_NUMBER    NUMBER,
    X_SHIPMENT_PRIORITY_CODE    VARCHAR2,
    X_SHIPPED_QUANTITY    NUMBER,
    X_SHIP_METHOD_CODE    VARCHAR2,
    X_SHIP_TO_CONTACT_ID    NUMBER,
    X_SHIP_TO_SITE_USE_ID    NUMBER,
    X_UNIT_CODE    VARCHAR2,
    X_WAREHOUSE_ID    NUMBER
)IS

BEGIN
    UPDATE so_picking_lines
    SET
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    CANCELLED_QUANTITY = X_CANCELLED_QUANTITY,
    COMPONENT_CODE = X_COMPONENT_CODE,
    COMPONENT_RATIO = X_COMPONENT_RATIO,
    COMPONENT_SEQUENCE_ID = X_COMPONENT_SEQUENCE_ID,
    CONFIGURATION_ITEM_FLAG = X_CONFIGURATION_ITEM_FLAG,
    CONTEXT = X_CONTEXT,
    CREATED_BY = X_CREATED_BY,
    CREATION_DATE = X_CREATION_DATE,
    DATE_CONFIRMED = X_DATE_CONFIRMED,
    DATE_REQUESTED = X_DATE_REQUESTED,
    DEMAND_CLASS_CODE = X_DEMAND_CLASS_CODE,
    INCLUDED_ITEM_FLAG = X_INCLUDED_ITEM_FLAG,
    INVENTORY_ITEM_ID = X_INVENTORY_ITEM_ID,
    INVENTORY_STATUS = X_INVENTORY_STATUS,
    INVOICED_QUANTITY = X_INVOICED_QUANTITY,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    LATEST_ACCEPTABLE_DATE = X_LATEST_ACCEPTABLE_DATE,
    LINE_DETAIL_ID = X_LINE_DETAIL_ID,
    ORDER_LINE_ID = X_ORDER_LINE_ID,
--    ORGANIZATION_ID = X_ORGANIZATION_ID,
    ORIGINAL_REQUESTED_QUANTITY = X_ORIGINAL_REQUESTED_QUANTITY,
    PICKING_HEADER_ID = X_PICKING_HEADER_ID,
    PICKING_LINE_ID = X_PICKING_LINE_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    RA_INTERFACE_STATUS = X_RA_INTERFACE_STATUS,
    REQUESTED_QUANTITY = X_REQUESTED_QUANTITY,
    REQUEST_ID = X_REQUEST_ID,
    SCHEDULE_DATE = X_SCHEDULE_DATE,
    SEQUENCE_NUMBER = X_SEQUENCE_NUMBER,
    SHIPMENT_PRIORITY_CODE = X_SHIPMENT_PRIORITY_CODE,
    SHIPPED_QUANTITY = X_SHIPPED_QUANTITY,
    SHIP_METHOD_CODE = X_SHIP_METHOD_CODE,
    SHIP_TO_CONTACT_ID = X_SHIP_TO_CONTACT_ID,
    SHIP_TO_SITE_USE_ID = X_SHIP_TO_SITE_USE_ID,
    UNIT_CODE = X_UNIT_CODE,
    WAREHOUSE_ID = X_WAREHOUSE_ID
    WHERE ROWID = X_Rowid;

    IF (SQL%NOTFOUND) then
        Raise NO_DATA_FOUND;
    end if;

exception
    when OTHERS then
      OE_MSG.Internal_Exception('OE_SO_PLN_SERVER.Update_Row',NULL,NULL);

END Update_Row;

FUNCTION complex_details (x_picking_line_id IN NUMBER) RETURN BOOLEAN IS
  complexDetails NUMBER := 0;
BEGIN

  SELECT min(1)
  INTO   complexDetails
  FROM   so_picking_line_details
  WHERE  picking_line_id = x_picking_line_id
  AND    NVL( released_flag, 'N') = 'N'
  HAVING   COUNT( DISTINCT warehouse_id)      >  1
  OR       COUNT( DISTINCT schedule_date)     >  1
  OR       COUNT( DISTINCT revision)          >  1
  OR       COUNT( DISTINCT lot_number)        >  1
  OR       COUNT( DISTINCT subinventory)      >  1
  OR       COUNT( DISTINCT demand_class_code) >  1
  OR       ( COUNT( subinventory)             >  0
      AND    COUNT( subinventory)             <> COUNT(1))
  OR       ( COUNT( warehouse_id)             >  0
      AND    COUNT( warehouse_id)             <> COUNT(1))
  OR       ( COUNT( schedule_date)            >  0
      AND    COUNT( schedule_date)            <> COUNT(1))
  OR       ( COUNT( lot_number)               >  0
      AND    COUNT( lot_number)               <> COUNT(1))
  OR       ( COUNT( revision)                 >  0
      AND    COUNT( revision)                 <> COUNT(1))
  OR       ( COUNT( demand_class_code)        >  0
      AND    COUNT( demand_class_code)        <> COUNT(1));

IF complexDetails = 1 THEN
  RETURN TRUE;
ELSE
  RETURN FALSE;
END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN RETURN FALSE;
  WHEN OTHERS THEN RETURN FALSE;

END complex_details;


PROCEDURE Validate_Reserved_Qty (
                P_Picking_Line_Id 	 IN  NUMBER,
		P_Reserved_Qty    	 IN  NUMBER,
		P_Original_Requested_Qty IN  NUMBER,
		P_Cancelled_Qty   	 IN  NUMBER,
		P_Released_Qty    	 IN  NUMBER,
		P_Result	  	 OUT VARCHAR2
		) is
begin

  P_Result := 'Y';

  if (NVL(P_Reserved_Qty, 0) = OE_SO_PLN_SERVER.DB_Reserved_Quantity(P_Picking_Line_Id)) then
    Return;
  end if;

  if (P_Reserved_Qty > (NVL(P_Original_Requested_Qty, 0)
		      - NVL(P_Cancelled_Qty, 0) )) then
    OE_MSG.Set_Buffer_Message('OE_SCH_RES_MORE_ORD_QTY');
    P_Result := 'N';
    Return;
  elsif (P_Reserved_Qty < NVL(P_Released_Qty,  0) ) then
    OE_MSG.Set_Buffer_Message('OE_SCH_RES_LESS_REL_QTY','RELEASED_QUANTITY',to_char(P_Released_Qty));
    P_Result := 'N';
    Return;
  else
    if (OE_SO_PLN_SERVER.Complex_Details(P_Picking_Line_Id)) then
      OE_MSG.Set_Buffer_Message('OE_SCH_COMPLEX_DETAILS');
      P_Result := 'N';
      Return;
    end if;
  end if;

  Return;

end Validate_Reserved_Qty;

END OE_SO_PLN_SERVER;

/
