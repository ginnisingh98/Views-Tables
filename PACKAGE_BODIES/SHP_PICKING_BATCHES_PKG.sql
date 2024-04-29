--------------------------------------------------------
--  DDL for Package Body SHP_PICKING_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SHP_PICKING_BATCHES_PKG" as
/* $Header: WSHFPKBB.pls 115.0 99/07/16 08:19:05 porting ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Batch_Id                IN OUT NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Name                    IN OUT VARCHAR2,
                       X_Backorders_Only_Flag           VARCHAR2,
                       X_Print_Flag                     VARCHAR2,
                       X_Existing_Rsvs_Only_Flag        VARCHAR2,
                       X_Shipment_Priority_Code         VARCHAR2,
                       X_Ship_Method_Code               VARCHAR2,
                       X_Customer_Id                    NUMBER,
                       X_Group_Id                       NUMBER,
                       X_Header_Count                   NUMBER,
                       X_Header_Id                      NUMBER,
                       X_Ship_Set_Number                NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_Order_Type_Id                  NUMBER,
                       X_Date_Requested_From            DATE,
                       X_Date_Requested_To              DATE,
                       X_Scheduled_Shipment_Date_From   DATE,
                       X_Scheduled_Shipment_Date_To     DATE,
                       X_Site_Use_Id                    NUMBER,
                       X_Warehouse_Id                   NUMBER,
                       X_Subinventory                   VARCHAR2,
                       X_Date_Completed                 DATE,
                       X_Date_Confirmed                 DATE,
                       X_Date_Last_Printed              DATE,
                       X_Date_Released                  DATE,
                       X_Date_Unreleased                DATE,
		       X_Departure_Id			NUMBER,
		       X_Delivery_Id			NUMBER,
		       X_Include_Planned_Lines		VARCHAR2,
		       X_Partial_Allowed_Flag		VARCHAR2,
		       X_Pick_Slip_Rule_Id		NUMBER,
		       X_Release_Seq_Rule_Id		NUMBER,
		       X_Autocreate_Delivery_Flag		VARCHAR2,
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
                       X_Error_Report_Flag              VARCHAR2,
                       X_Org_Id				NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM SO_PICKING_BATCHES_ALL
                 WHERE batch_id = X_Batch_Id;
    CURSOR NEXTID IS SELECT so_picking_batches_s.nextval FROM sys.dual;
    CURSOR Batch (batch_name VARCHAR2) IS
                 Select count(*) From SO_PICKING_BATCHES_ALL
                 Where NAME = batch_name;
    userid  NUMBER;
    loginid NUMBER;
    temp    NUMBER;
   BEGIN

       userid  := FND_GLOBAL.USER_ID;
       loginid := FND_GLOBAL.LOGIN_ID;

       IF (X_Batch_Id is NULL) THEN
         OPEN NEXTID;
         FETCH NEXTID INTO X_Batch_Id;
         CLOSE NEXTID;
       END IF;

       -- Default Batch Name
       If (X_Name is NULL) Then
         X_Name := TO_CHAR(X_Batch_Id);
         OPEN NEXTID;

         Loop
           OPEN  Batch( X_Name);
           FETCH Batch INTO temp;
           IF (temp = 0) Then
             CLOSE Batch;
             EXIT;
           End if;

           FETCH NEXTID INTO X_Batch_Id;
           X_Name := TO_CHAR(X_Batch_Id);
           CLOSE Batch;
         End Loop;

         CLOSE NEXTID;
       End If;

       INSERT INTO SO_PICKING_BATCHES_ALL(
              batch_id,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              name,
              backorders_only_flag,
              print_flag,
              existing_rsvs_only_flag,
              shipment_priority_code,
              ship_method_code,
              customer_id,
              group_id,
              header_count,
              header_id,
              ship_set_number,
              inventory_item_id,
              order_type_id,
              date_requested_from,
              date_requested_to,
              scheduled_shipment_date_from,
              scheduled_shipment_date_to,
              site_use_id,
              warehouse_id,
              subinventory,
              date_completed,
              date_confirmed,
              date_last_printed,
              date_released,
              date_unreleased,
	      departure_id,
	      delivery_id,
	      include_planned_lines,
	      partial_allowed_flag,
	      pick_slip_rule_id,
	      release_seq_rule_id,
	      autocreate_delivery_flag,
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
              error_report_flag,
	      org_id
             ) VALUES (

              X_Batch_Id,
              SYSDATE,
              userid,
              SYSDATE,
              userid,
              loginid,
              X_Name,
              X_Backorders_Only_Flag,
              X_Print_Flag,
              X_Existing_Rsvs_Only_Flag,
              X_Shipment_Priority_Code,
              X_Ship_Method_Code,
              X_Customer_Id,
              X_Group_Id,
              X_Header_Count,
              X_Header_Id,
              X_Ship_Set_Number,
              X_Inventory_Item_Id,
              X_Order_Type_Id,
              X_Date_Requested_From,
              X_Date_Requested_To,
              X_Scheduled_Shipment_Date_From,
              X_Scheduled_Shipment_Date_To,
              X_Site_Use_Id,
              X_Warehouse_Id,
              X_Subinventory,
              X_Date_Completed,
              X_Date_Confirmed,
              X_Date_Last_Printed,
              X_Date_Released,
              X_Date_Unreleased,
	      X_Departure_Id,
	      X_Delivery_Id,
	      X_Include_Planned_Lines,
	      X_Partial_Allowed_Flag,
	      X_Pick_Slip_Rule_Id,
	      X_Release_Seq_Rule_Id,
	      X_Autocreate_Delivery_Flag,
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
              X_Error_Report_Flag,
	      X_Org_Id
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
                     X_Batch_Id                         NUMBER,
                     X_Name                             VARCHAR2,
                     X_Backorders_Only_Flag             VARCHAR2,
                     X_Print_Flag                       VARCHAR2,
                     X_Existing_Rsvs_Only_Flag          VARCHAR2,
                     X_Shipment_Priority_Code           VARCHAR2,
                     X_Ship_Method_Code                 VARCHAR2,
                     X_Customer_Id                      NUMBER,
                     X_Group_Id                         NUMBER,
                     X_Header_Count                     NUMBER,
                     X_Header_Id                        NUMBER,
                     X_Ship_Set_Number                  NUMBER,
                     X_Inventory_Item_Id                NUMBER,
                     X_Order_Type_Id                    NUMBER,
                     X_Date_Requested_From              DATE,
                     X_Date_Requested_To                DATE,
                     X_Scheduled_Shipment_Date_From     DATE,
                     X_Scheduled_Shipment_Date_To       DATE,
                     X_Site_Use_Id                      NUMBER,
                     X_Warehouse_Id                     NUMBER,
                     X_Subinventory                     VARCHAR2,
                     X_Date_Completed                   DATE,
                     X_Date_Confirmed                   DATE,
                     X_Date_Last_Printed                DATE,
                     X_Date_Released                    DATE,
                     X_Date_Unreleased                  DATE,
          	     X_Departure_Id         		NUMBER,
          	     X_Delivery_Id	     		NUMBER,
          	     X_Include_Planned_Lines 		VARCHAR2,
          	     X_Partial_Allowed_Flag 		VARCHAR2,
          	     X_Pick_Slip_Rule_Id    		NUMBER,
          	     X_Release_Seq_Rule_Id  		NUMBER,
		     X_Autocreate_Delivery_Flag		VARCHAR2,
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
                     X_Error_Report_Flag                VARCHAR2,
                     X_Org_Id				NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   SO_PICKING_BATCHES_ALL
        WHERE  rowid = X_Rowid
        FOR UPDATE of Batch_Id NOWAIT;
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

               (Recinfo.batch_id =  X_Batch_Id)
           AND (Recinfo.name =  X_Name)
           AND (Recinfo.backorders_only_flag =  X_Backorders_Only_Flag)
           AND (   (Recinfo.print_flag =  X_Print_Flag)
                OR (    (Recinfo.print_flag IS NULL)
                    AND (X_Print_Flag IS NULL)))
           AND (   (Recinfo.existing_rsvs_only_flag =  X_Existing_Rsvs_Only_Flag)
                OR (    (Recinfo.existing_rsvs_only_flag IS NULL)
                    AND (X_Existing_Rsvs_Only_Flag IS NULL)))
           AND (   (Recinfo.shipment_priority_code =  X_Shipment_Priority_Code)
                OR (    (Recinfo.shipment_priority_code IS NULL)
                    AND (X_Shipment_Priority_Code IS NULL)))
           AND (   (Recinfo.ship_method_code =  X_Ship_Method_Code)
                OR (    (Recinfo.ship_method_code IS NULL)
                    AND (X_Ship_Method_Code IS NULL)))
           AND (   (Recinfo.customer_id =  X_Customer_Id)
                OR (    (Recinfo.customer_id IS NULL)
                    AND (X_Customer_Id IS NULL)))
           AND (   (Recinfo.group_id =  X_Group_Id)
                OR (    (Recinfo.group_id IS NULL)
                    AND (X_Group_Id IS NULL)))
           AND (   (Recinfo.header_count =  X_Header_Count)
                OR (    (Recinfo.header_count IS NULL)
                    AND (X_Header_Count IS NULL)))
           AND (   (Recinfo.header_id =  X_Header_Id)
                OR (    (Recinfo.header_id IS NULL)
                    AND (X_Header_Id IS NULL)))
           AND (   (Recinfo.ship_set_number =  X_Ship_Set_Number)
                OR (    (Recinfo.ship_set_number IS NULL)
                    AND (X_Ship_Set_Number IS NULL)))
           AND (   (Recinfo.inventory_item_id =  X_Inventory_Item_Id)
                OR (    (Recinfo.inventory_item_id IS NULL)
                    AND (X_Inventory_Item_Id IS NULL)))
           AND (   (Recinfo.order_type_id =  X_Order_Type_Id)
                OR (    (Recinfo.order_type_id IS NULL)
                    AND (X_Order_Type_Id IS NULL)))
           AND (   (Recinfo.date_requested_from =  X_Date_Requested_From)
                OR (    (Recinfo.date_requested_from IS NULL)
                    AND (X_Date_Requested_From IS NULL)))
           AND (   (Recinfo.date_requested_to =  X_Date_Requested_To)
                OR (    (Recinfo.date_requested_to IS NULL)
                    AND (X_Date_Requested_To IS NULL)))
           AND (   (Recinfo.scheduled_shipment_date_from =  X_Scheduled_Shipment_Date_From)
                OR (    (Recinfo.scheduled_shipment_date_from IS NULL)
                    AND (X_Scheduled_Shipment_Date_From IS NULL)))
           AND (   (Recinfo.scheduled_shipment_date_to =  X_Scheduled_Shipment_Date_To)
                OR (    (Recinfo.scheduled_shipment_date_to IS NULL)
                    AND (X_Scheduled_Shipment_Date_To IS NULL)))
           AND (   (Recinfo.site_use_id =  X_Site_Use_Id)
                OR (    (Recinfo.site_use_id IS NULL)
                    AND (X_Site_Use_Id IS NULL)))
           AND (   (Recinfo.warehouse_id =  X_Warehouse_Id)
                OR (    (Recinfo.warehouse_id IS NULL)
                    AND (X_Warehouse_Id IS NULL)))
           AND (   (Recinfo.subinventory =  X_Subinventory)
                OR (    (Recinfo.subinventory IS NULL)
                    AND (X_Subinventory IS NULL)))
           AND (   (Recinfo.date_completed =  X_Date_Completed)
                OR (    (Recinfo.date_completed IS NULL)
                    AND (X_Date_Completed IS NULL)))
           AND (   (Recinfo.date_confirmed =  X_Date_Confirmed)
                OR (    (Recinfo.date_confirmed IS NULL)
                    AND (X_Date_Confirmed IS NULL)))
           AND (   (Recinfo.date_last_printed =  X_Date_Last_Printed)
                OR (    (Recinfo.date_last_printed IS NULL)
                    AND (X_Date_Last_Printed IS NULL)))
           AND (   (Recinfo.date_released =  X_Date_Released)
                OR (    (Recinfo.date_released IS NULL)
                    AND (X_Date_Released IS NULL)))
           AND (   (Recinfo.date_unreleased =  X_Date_Unreleased)
                OR (    (Recinfo.date_unreleased IS NULL)
                    AND (X_Date_Unreleased IS NULL)))
           AND (   (Recinfo.departure_id =  X_Departure_Id)
                OR (    (Recinfo.departure_id IS NULL)
                    AND (X_Departure_Id IS NULL)))
           AND (   (Recinfo.delivery_id =  X_Delivery_Id)
                OR (    (Recinfo.delivery_id IS NULL)
                    AND (X_Delivery_Id IS NULL)))
           AND (   (Recinfo.include_planned_lines =  X_Include_Planned_Lines)
                OR (    (Recinfo.include_planned_lines IS NULL)
                    AND (X_Include_Planned_Lines IS NULL)))
           AND (   (Recinfo.partial_allowed_flag =  X_Partial_Allowed_Flag)
                OR (    (Recinfo.partial_allowed_flag IS NULL)
                    AND (X_Partial_Allowed_Flag IS NULL)))
           AND (   (Recinfo.pick_slip_rule_id =  X_Pick_Slip_Rule_Id)
                OR (    (Recinfo.pick_slip_rule_id IS NULL)
                    AND (X_Pick_Slip_Rule_Id IS NULL)))
           AND (   (Recinfo.release_seq_rule_id =  X_Release_Seq_Rule_Id)
                OR (    (Recinfo.release_seq_rule_id IS NULL)
                    AND (X_Release_Seq_Rule_Id IS NULL)))
           AND (   (Recinfo.release_seq_rule_id =  X_Autocreate_Delivery_Flag)
                OR (    (Recinfo.autocreate_delivery_flag IS NULL)
                    AND (X_Autocreate_Delivery_Flag IS NULL)))
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
           AND (   (Recinfo.error_report_flag =  X_Error_Report_Flag)
                OR (    (Recinfo.error_report_flag IS NULL)
                    AND (X_Error_Report_Flag IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Batch_Id                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Name                           VARCHAR2,
                       X_Backorders_Only_Flag           VARCHAR2,
                       X_Print_Flag                     VARCHAR2,
                       X_Existing_Rsvs_Only_Flag        VARCHAR2,
                       X_Shipment_Priority_Code         VARCHAR2,
                       X_Ship_Method_Code               VARCHAR2,
                       X_Customer_Id                    NUMBER,
                       X_Group_Id                       NUMBER,
                       X_Header_Count                   NUMBER,
                       X_Header_Id                      NUMBER,
                       X_Ship_Set_Number                NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_Order_Type_Id                  NUMBER,
                       X_Date_Requested_From            DATE,
                       X_Date_Requested_To              DATE,
                       X_Scheduled_Shipment_Date_From   DATE,
                       X_Scheduled_Shipment_Date_To     DATE,
                       X_Site_Use_Id                    NUMBER,
                       X_Warehouse_Id                   NUMBER,
                       X_Subinventory                   VARCHAR2,
                       X_Date_Completed                 DATE,
                       X_Date_Confirmed                 DATE,
                       X_Date_Last_Printed              DATE,
                       X_Date_Released                  DATE,
                       X_Date_Unreleased                DATE,
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
                       X_Error_Report_Flag              VARCHAR2,
                       X_Org_Id				NUMBER

  ) IS
    userid  NUMBER;
    loginid NUMBER;
  BEGIN

    userid  := FND_GLOBAL.USER_ID;
    loginid := FND_GLOBAL.LOGIN_ID;
    UPDATE SO_PICKING_BATCHES
    SET
       batch_id                        =     X_Batch_Id,
       last_update_date                =     SYSDATE,
       last_updated_by                 =     userid,
       last_update_login               =     loginid,
       name                            =     X_Name,
       backorders_only_flag            =     X_Backorders_Only_Flag,
       print_flag                      =     X_Print_Flag,
       existing_rsvs_only_flag         =     X_Existing_Rsvs_Only_Flag,
       shipment_priority_code          =     X_Shipment_Priority_Code,
       ship_method_code                =     X_Ship_Method_Code,
       customer_id                     =     X_Customer_Id,
       group_id                        =     X_Group_Id,
       header_count                    =     X_Header_Count,
       header_id                       =     X_Header_Id,
       ship_set_number                 =     X_Ship_Set_Number,
       inventory_item_id               =     X_Inventory_Item_Id,
       order_type_id                   =     X_Order_Type_Id,
       date_requested_from             =     X_Date_Requested_From,
       date_requested_to               =     X_Date_Requested_To,
       scheduled_shipment_date_from    =     X_Scheduled_Shipment_Date_From,
       scheduled_shipment_date_to      =     X_Scheduled_Shipment_Date_To,
       site_use_id                     =     X_Site_Use_Id,
       warehouse_id                    =     X_Warehouse_Id,
       subinventory                    =     X_Subinventory,
       date_completed                  =     X_Date_Completed,
       date_confirmed                  =     X_Date_Confirmed,
       date_last_printed               =     X_Date_Last_Printed,
       date_released                   =     X_Date_Released,
       date_unreleased                 =     X_Date_Unreleased,
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
       error_report_flag               =     X_Error_Report_Flag
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM SO_PICKING_BATCHES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

  FUNCTION Submit_Release_Request(Batch_Id NUMBER) RETURN NUMBER IS
    request_id NUMBER;
  BEGIN

    request_id := FND_REQUEST.Submit_Request('OE', 'WSHREL','','',FALSE,
                  to_char(Batch_Id),'Y');

    if (request_id > 0) then
      COMMIT WORK;
    end if;
    return request_id;
  END Submit_Release_Request;

  PROCEDURE Delete_And_Commit(X_Rowid VARCHAR2) IS
  BEGIN
    Delete_Row(X_Rowid);
    COMMIT WORK;
  END Delete_And_Commit;

  PROCEDURE Commit_Work IS
  BEGIN
    COMMIT WORK;
  END Commit_Work;


  PROCEDURE Get_Printer ( report IN VARCHAR2,
                          report_printer OUT VARCHAR2,
                          default_report IN VARCHAR2 default 'OEXSHPIK' ) IS
    level_type_id NUMBER;
    app_id        NUMBER;
    respid        NUMBER;
    userid        NUMBER;
    printer       varchar2(32);
  BEGIN
    -- get the applications, responsibility, and user ID
    app_id := FND_GLOBAL.RESP_APPL_ID;
    respid := FND_GLOBAL.RESP_ID;
    userid := FND_GLOBAL.USER_ID;

    -- get pick slip printer
    SELECT MAX(P.LEVEL_TYPE_ID)
    INTO level_type_id
    FROM SO_REPORT_PRINTERS P,
         SO_REPORTS R
    WHERE P.REPORT_ID = R.REPORT_ID
    AND   R.NAME =
            NVL(report, default_report)
    AND P.LEVEL_VALUE_ID = DECODE(P.LEVEL_TYPE_ID,
                                   10001,0,
                                   10002,app_id,
                                   10003,respid,
                                   10004,userid)
    AND ENABLE_FLAG = 'Y';

    SELECT P.PRINTER_NAME
    INTO printer
    FROM SO_REPORT_PRINTERS P,
         SO_REPORTS R
    WHERE P.REPORT_ID = R.REPORT_ID
    AND   R.NAME =
            NVL(report, default_report)
    AND P.LEVEL_TYPE_ID = level_type_id
    AND P.LEVEL_VALUE_ID = DECODE(level_type_id,
                                   10001,0,
                                   10002,app_id,
                                   10003,respid,
                                   10004,userid);

    report_printer := printer;
    EXCEPTION
    WHEN OTHERS THEN report_printer := NULL;
  END get_printer;


  FUNCTION Open_Batch( X_batch_id IN NUMBER)
  RETURN VARCHAR2 IS
	x_num_open 	NUMBER;
  BEGIN
	x_num_open := 0;

	SELECT count(*)
	INTO x_num_open
	FROM so_picking_headers_all
	WHERE status_code||'' not in ('PENDING','CLOSED','IN PROGRESS')
	AND batch_id = X_batch_id;

	IF (x_num_open > 0) THEN
		RETURN ('Y');
	ELSE
		RETURN ('N');
	END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RETURN ('N');
  END Open_Batch;

END SHP_PICKING_BATCHES_PKG;

/
