--------------------------------------------------------
--  DDL for Package Body SO_PICKING_LINE_DETAILS_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SO_PICKING_LINE_DETAILS_PKG1" as
/* $Header: WSHPLDXB.pls 115.0 99/07/16 08:19:41 porting ship $ */

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Picking_Line_Detail_Id         NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
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
                       X_Container_Id                   NUMBER,
		       X_movement_id			NUMBER

  ) IS
  BEGIN
    UPDATE so_picking_line_details
    SET
       picking_line_detail_id          =     X_Picking_Line_Detail_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       picking_line_id                 =     X_Picking_Line_Id,
       warehouse_id                    =     X_Warehouse_Id,
       requested_quantity              =     X_Requested_Quantity,
       shipped_quantity                =     X_Shipped_Quantity,
       serial_number                   =     X_Serial_Number,
       lot_number                      =     X_Lot_Number,
       customer_requested_lot_flag     =     X_Customer_Requested_Lot_Flag,
       revision                        =     X_Revision,
       subinventory                    =     X_Subinventory,
       inventory_location_id           =     X_Inventory_Location_Id,
       inventory_location_segments     =     X_Inventory_Location_Segments,
       detail_type_code                =     X_Detail_Type_Code,
       context                         =     X_Context,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       released_flag                   =     X_Released_Flag,
       schedule_date                   =     X_Schedule_Date,
       schedule_level                  =     X_Schedule_Level,
       schedule_status_code            =     X_Schedule_Status_Code,
       demand_id                       =     X_Demand_Id,
       autoscheduled_flag              =     X_Autoscheduled_Flag,
       delivery                        =     X_Delivery,
       wip_reserved_quantity           =     X_Wip_Reserved_Quantity,
       wip_completed_quantity          =     X_Wip_Completed_Quantity,
       supply_source_type              =     X_Supply_Source_Type,
       supply_source_header_id         =     X_Supply_Source_Header_Id,
       update_flag                     =     X_Update_Flag,
       demand_class_code               =     X_Demand_Class_Code,
       reservable_flag                 =     X_Reservable_Flag,
       transactable_flag               =     X_Transactable_Flag,
       latest_acceptable_date          =     X_Latest_Acceptable_Date,
       delivery_id                     =     X_Delivery_Id,
       departure_id                    =     X_Departure_Id,
       master_container_item_id        =     X_Master_Container_Item_Id,
       detail_container_item_id        =     X_Detail_Container_Item_Id,
       dpw_assigned_flag               =     X_Dpw_Assigned_Flag,
       load_seq_number                 =     X_Load_Seq_Number,
       transaction_temp_id             =     X_Transaction_Temp_Id,
       container_id                    =     X_Container_id,
       movement_id		       =     X_Movement_id
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM so_picking_line_details
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END SO_PICKING_LINE_DETAILS_PKG1;

/
