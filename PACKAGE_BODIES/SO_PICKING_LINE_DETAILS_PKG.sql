--------------------------------------------------------
--  DDL for Package Body SO_PICKING_LINE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SO_PICKING_LINE_DETAILS_PKG" as
/* $Header: WSHPLDHB.pls 115.0 99/07/16 08:19:35 porting ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Picking_Line_Detail_Id         IN OUT NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Picking_Line_Id                NUMBER,
                       X_Warehouse_Id                   NUMBER,
                       X_Requested_Quantity             NUMBER,
                       X_Shipped_Quantity               NUMBER,
                       X_Serial_Number                  VARCHAR2,
                       X_Lot_Number                     VARCHAR2,
                       X_Customer_Requested_Lot_Flag    VARCHAR2,
                       X_Revision                       VARCHAR2,
                       X_Subinventory                   VARCHAR2,
                       X_Inventory_Location_Id          NUMBER,
                       X_Inventory_Location_Segments    VARCHAR2,
                       X_Detail_Type_Code               VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Released_Flag                  VARCHAR2,
                       X_Schedule_Date                  DATE,
                       X_Schedule_Level                 NUMBER,
                       X_Schedule_Status_Code           VARCHAR2,
                       X_Demand_Id                      NUMBER,
                       X_Autoscheduled_Flag             VARCHAR2,
                       X_Delivery                       NUMBER,
                       X_Wip_Reserved_Quantity          NUMBER,
                       X_Wip_Completed_Quantity         NUMBER,
                       X_Supply_Source_Type             NUMBER,
                       X_Supply_Source_Header_Id        NUMBER,
                       X_Update_Flag                    VARCHAR2,
                       X_Demand_Class_Code              VARCHAR2,
                       X_Reservable_Flag                VARCHAR2,
                       X_Transactable_Flag              VARCHAR2,
                       X_Latest_Acceptable_Date         DATE,
                       X_Delivery_Id                    NUMBER,
                       X_Departure_Id                   NUMBER,
                       X_Master_Container_Item_Id       NUMBER,
                       X_Detail_Container_Item_Id       NUMBER,
                       X_Dpw_Assigned_Flag              VARCHAR2,
                       X_Load_Seq_Number                NUMBER,
                       X_Transaction_Temp_Id            NUMBER,
                       X_Container_id                   NUMBER,
		       X_Movement_id			NUMBER
  ) IS
      CURSOR C IS SELECT rowid FROM so_picking_line_details
                 WHERE picking_line_detail_id = X_Picking_Line_Detail_Id;
      CURSOR C2 IS SELECT so_picking_line_details_s.nextval FROM sys.dual;
   BEGIN
      if (X_Picking_Line_Detail_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Picking_Line_Detail_Id;
        CLOSE C2;
      end if;

       INSERT INTO so_picking_line_details(
              picking_line_detail_id,
              last_update_date,
              last_updated_by,
              created_by,
              creation_date,
              last_update_login,
              picking_line_id,
              warehouse_id,
              requested_quantity,
              shipped_quantity,
              serial_number,
              lot_number,
              customer_requested_lot_flag,
              revision,
              subinventory,
              inventory_location_id,
              segment1,
              segment2,
              segment3,
              segment4,
              segment5,
              segment6,
              segment7,
              segment8,
              segment9,
              segment10,
              segment11,
              segment12,
              segment13,
              segment14,
              segment15,
              segment16,
              segment17,
              segment18,
              segment19,
              segment20,
              inventory_location_segments,
              detail_type_code,
              context,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              released_flag,
              schedule_date,
              schedule_level,
              schedule_status_code,
              demand_id,
              autoscheduled_flag,
              delivery,
              wip_reserved_quantity,
              wip_completed_quantity,
              supply_source_type,
              supply_source_header_id,
              update_flag,
              demand_class_code,
              reservable_flag,
              transactable_flag,
              latest_acceptable_date,
              delivery_id,
              departure_id,
              master_container_item_id,
              detail_container_item_id,
              dpw_assigned_flag,
              load_seq_number,
              transaction_temp_id,
              container_id,
              movement_id
             ) VALUES (
              X_Picking_Line_Detail_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Created_By,
              X_Creation_Date,
              X_Last_Update_Login,
              X_Picking_Line_Id,
              X_Warehouse_Id,
              X_Requested_Quantity,
              X_Shipped_Quantity,
              X_Serial_Number,
              X_Lot_Number,
              X_Customer_Requested_Lot_Flag,
              X_Revision,
              X_Subinventory,
              X_Inventory_Location_Id,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
	      NULL,
              X_Inventory_Location_Segments,
              X_Detail_Type_Code,
              X_Context,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15,
              X_Released_Flag,
              X_Schedule_Date,
              X_Schedule_Level,
              X_Schedule_Status_Code,
              X_Demand_Id,
              X_Autoscheduled_Flag,
              X_Delivery,
              X_Wip_Reserved_Quantity,
              X_Wip_Completed_Quantity,
              X_Supply_Source_Type,
              X_Supply_Source_Header_Id,
              X_Update_Flag,
              X_Demand_Class_Code,
              X_Reservable_Flag,
              X_Transactable_Flag,
              X_Latest_Acceptable_Date,
              X_Delivery_Id,
              X_Departure_Id,
              X_Master_Container_Item_Id,
              X_Detail_Container_Item_Id,
              X_Dpw_Assigned_Flag,
              X_Load_Seq_Number,
              X_Transaction_Temp_Id,
              X_Container_Id,
	      X_Movement_id
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Picking_Line_Detail_Id           NUMBER,
                     X_Picking_Line_Id                  NUMBER,
                     X_Warehouse_Id                     NUMBER,
                     X_Requested_Quantity               NUMBER,
                     X_Shipped_Quantity                 NUMBER,
                     X_Serial_Number                    VARCHAR2,
                     X_Lot_Number                       VARCHAR2,
                     X_Customer_Requested_Lot_Flag      VARCHAR2,
                     X_Revision                         VARCHAR2,
                     X_Subinventory                     VARCHAR2,
                     X_Inventory_Location_Id            NUMBER,
                     X_Inventory_Location_Segments      VARCHAR2,
                     X_Detail_Type_Code                 VARCHAR2,
                     X_Context                          VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Released_Flag                    VARCHAR2,
                     X_Schedule_Date                    DATE,
                     X_Schedule_Level                   NUMBER,
                     X_Schedule_Status_Code             VARCHAR2,
                     X_Demand_Id                        NUMBER,
                     X_Autoscheduled_Flag               VARCHAR2,
                     X_Delivery                         NUMBER,
                     X_Wip_Reserved_Quantity            NUMBER,
                     X_Wip_Completed_Quantity           NUMBER,
                     X_Supply_Source_Type               NUMBER,
                     X_Supply_Source_Header_Id          NUMBER,
                     X_Update_Flag                      VARCHAR2,
                     X_Demand_Class_Code                VARCHAR2,
                     X_Reservable_Flag                  VARCHAR2,
                     X_Transactable_Flag                VARCHAR2,
                     X_Latest_Acceptable_Date           DATE,
                     X_Delivery_Id                      NUMBER,
                     X_Departure_Id                     NUMBER,
                     X_Master_Container_Item_Id         NUMBER,
                     X_Detail_Container_Item_Id         NUMBER,
                     X_Dpw_Assigned_Flag                VARCHAR2,
                     X_Load_Seq_Number                  NUMBER,
                     X_Transaction_Temp_Id              NUMBER,
                     X_Container_id                     NUMBER,
		     X_Movement_id			NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   so_picking_line_details
        WHERE  rowid = X_Rowid
        FOR UPDATE of Picking_Line_Detail_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.picking_line_detail_id =  X_Picking_Line_Detail_Id)
           AND (Recinfo.picking_line_id =  X_Picking_Line_Id)
           AND (Recinfo.warehouse_id =  X_Warehouse_Id)
           AND (Recinfo.requested_quantity =  X_Requested_Quantity)
           AND (   (Recinfo.shipped_quantity =  X_Shipped_Quantity)
                OR (    (Recinfo.shipped_quantity IS NULL)
                    AND (X_Shipped_Quantity IS NULL)))
           AND (   (Recinfo.serial_number =  X_Serial_Number)
                OR (    (Recinfo.serial_number IS NULL)
                    AND (X_Serial_Number IS NULL)))
           AND (   (Recinfo.lot_number =  X_Lot_Number)
                OR (    (Recinfo.lot_number IS NULL)
                    AND (X_Lot_Number IS NULL)))
           AND (   (Recinfo.customer_requested_lot_flag =  X_Customer_Requested_Lot_Flag)
                OR (    (Recinfo.customer_requested_lot_flag IS NULL)
                    AND (X_Customer_Requested_Lot_Flag IS NULL)))
           AND (   (Recinfo.revision =  X_Revision)
                OR (    (Recinfo.revision IS NULL)
                    AND (X_Revision IS NULL)))
           AND (   (Recinfo.subinventory =  X_Subinventory)
                OR (    (Recinfo.subinventory IS NULL)
                    AND (X_Subinventory IS NULL)))
           AND (   (Recinfo.inventory_location_id =  X_Inventory_Location_Id)
                OR (    (Recinfo.inventory_location_id IS NULL)
                    AND (X_Inventory_Location_Id IS NULL)))
           AND (   (Recinfo.inventory_location_segments =  X_Inventory_Location_Segments)
                OR (    (Recinfo.inventory_location_segments IS NULL)
                    AND (X_Inventory_Location_Segments IS NULL)))
           AND (   (Recinfo.detail_type_code =  X_Detail_Type_Code)
                OR (    (Recinfo.detail_type_code IS NULL)
                    AND (X_Detail_Type_Code IS NULL)))
           AND (   (Recinfo.context =  X_Context)
                OR (    (Recinfo.context IS NULL)
                    AND (X_Context IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.released_flag =  X_Released_Flag)
                OR (    (Recinfo.released_flag IS NULL)
                    AND (X_Released_Flag IS NULL)))
           AND (   (Recinfo.schedule_date =  X_Schedule_Date)
                OR (    (Recinfo.schedule_date IS NULL)
                    AND (X_Schedule_Date IS NULL)))
           AND (   (Recinfo.schedule_level =  X_Schedule_Level)
                OR (    (Recinfo.schedule_level IS NULL)
                    AND (X_Schedule_Level IS NULL)))
           AND (   (Recinfo.schedule_status_code =  X_Schedule_Status_Code)
                OR (    (Recinfo.schedule_status_code IS NULL)
                    AND (X_Schedule_Status_Code IS NULL)))
           AND (   (Recinfo.demand_id =  X_Demand_Id)
                OR (    (Recinfo.demand_id IS NULL)
                    AND (X_Demand_Id IS NULL)))
           AND (   (Recinfo.autoscheduled_flag =  X_Autoscheduled_Flag)
                OR (    (Recinfo.autoscheduled_flag IS NULL)
                    AND (X_Autoscheduled_Flag IS NULL)))
           AND (   (Recinfo.delivery =  X_Delivery)
                OR (    (Recinfo.delivery IS NULL)
                    AND (X_Delivery IS NULL)))
           AND (   (Recinfo.wip_reserved_quantity =  X_Wip_Reserved_Quantity)
                OR (    (Recinfo.wip_reserved_quantity IS NULL)
                    AND (X_Wip_Reserved_Quantity IS NULL)))
           AND (   (Recinfo.wip_completed_quantity =  X_Wip_Completed_Quantity)
                OR (    (Recinfo.wip_completed_quantity IS NULL)
                    AND (X_Wip_Completed_Quantity IS NULL)))
           AND (   (Recinfo.supply_source_type =  X_Supply_Source_Type)
                OR (    (Recinfo.supply_source_type IS NULL)
                    AND (X_Supply_Source_Type IS NULL)))
           AND (   (Recinfo.supply_source_header_id =  X_Supply_Source_Header_Id)
                OR (    (Recinfo.supply_source_header_id IS NULL)
                    AND (X_Supply_Source_Header_Id IS NULL)))
           AND (   (Recinfo.update_flag =  X_Update_Flag)
                OR (    (Recinfo.update_flag IS NULL)
                    AND (X_Update_Flag IS NULL)))
           AND (   (Recinfo.demand_class_code =  X_Demand_Class_Code)
                OR (    (Recinfo.demand_class_code IS NULL)
                    AND (X_Demand_Class_Code IS NULL)))
           AND (   (Recinfo.reservable_flag =  X_Reservable_Flag)
                OR (    (Recinfo.reservable_flag IS NULL)
                    AND (X_Reservable_Flag IS NULL)))
           AND (   (Recinfo.transactable_flag =  X_Transactable_Flag)
                OR (    (Recinfo.transactable_flag IS NULL)
                    AND (X_Transactable_Flag IS NULL)))
           AND (   (Recinfo.latest_acceptable_date =  X_Latest_Acceptable_Date)
                OR (    (Recinfo.latest_acceptable_date IS NULL)
                    AND (X_Latest_Acceptable_Date IS NULL)))
           AND (   (Recinfo.delivery_id =  X_Delivery_Id)
                OR (    (Recinfo.delivery_id IS NULL)
                    AND (X_Delivery_Id IS NULL)))
           AND (   (Recinfo.departure_id =  X_Departure_Id)
                OR (    (Recinfo.departure_id IS NULL)
                    AND (X_Departure_Id IS NULL)))
           AND (   (Recinfo.master_container_item_id =  X_Master_Container_Item_Id)
                OR (    (Recinfo.master_container_item_id IS NULL)
                    AND (X_Master_Container_Item_Id IS NULL)))
           AND (   (Recinfo.detail_container_item_id =  X_Detail_Container_Item_Id)
                OR (    (Recinfo.detail_container_item_id IS NULL)
                    AND (X_Detail_Container_Item_Id IS NULL)))
           AND (   (Recinfo.dpw_assigned_flag =  X_Dpw_Assigned_Flag)
                OR (    (Recinfo.dpw_assigned_flag IS NULL)
                    AND (X_Dpw_Assigned_Flag IS NULL)))
           AND (   (Recinfo.load_seq_number =  X_Load_Seq_Number)
                OR (    (Recinfo.load_seq_number IS NULL)
                    AND (X_Load_Seq_Number IS NULL)))
           AND (   (Recinfo.transaction_temp_id =  X_Transaction_Temp_Id)
                OR (    (Recinfo.transaction_temp_id IS NULL)
                    AND (X_Transaction_Temp_Id IS NULL)))
           AND (   (Recinfo.movement_id =  X_Movement_Id)
                OR (    (Recinfo.movement_id IS NULL)
                    AND (X_Movement_id IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;




END SO_PICKING_LINE_DETAILS_PKG;

/
