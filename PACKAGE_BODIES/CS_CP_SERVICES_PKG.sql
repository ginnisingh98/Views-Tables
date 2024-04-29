--------------------------------------------------------
--  DDL for Package Body CS_CP_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CP_SERVICES_PKG" as
/* $Header: csxsicsb.pls 115.1 99/07/16 09:08:48 porting s $ */

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Cp_Service_Id                    NUMBER,
                     X_Customer_Product_Id              NUMBER,
                     X_Service_Inventory_Item_Id        NUMBER,
                     X_Service_Manufacturing_Org_Id     NUMBER,
                     X_Start_Date_Active                DATE,
                     X_End_Date_Active                  DATE,
                     X_Original_Start_Date              DATE,
                     X_Original_End_Date                DATE,
				 X_Service_Date_Change              VARCHAR2,
                     X_Status_Code                      VARCHAR2,
                     X_Last_Cp_Service_Txn_Id           NUMBER,
                     X_Invoice_Flag                     VARCHAR2,
                     X_Coverage_Schedule_Id             NUMBER,
                     X_Prorate_Flag                     VARCHAR2,
                     X_Duration_Quantity                NUMBER,
                     X_Unit_Of_Measure_Code             VARCHAR2,
                     X_Starting_Delay                   NUMBER,
                     X_Bill_To_Site_Use_Id              NUMBER,
                     X_Bill_To_Contact_Id               NUMBER,
                     X_Service_Txn_Avail_Code           VARCHAR2,
                     X_Next_Pm_Visit_Date               DATE,
                     X_Pm_Visits_Completed              NUMBER,
                     X_Last_Pm_Visit_Date               DATE,
                     X_Pm_Schedule_Id                   NUMBER,
                     X_Pm_Schedule_Flag                 VARCHAR2,
                     X_Current_Max_Schedule_Date        DATE,
                     X_Price_List_Id                    NUMBER,
                     X_Pricing_Attribute1               VARCHAR2,
                     X_Pricing_Attribute2               VARCHAR2,
                     X_Pricing_Attribute3               VARCHAR2,
                     X_Pricing_Attribute4               VARCHAR2,
                     X_Pricing_Attribute5               VARCHAR2,
                     X_Pricing_Attribute6               VARCHAR2,
                     X_Pricing_Attribute7               VARCHAR2,
                     X_Pricing_Attribute8               VARCHAR2,
                     X_Pricing_Attribute9               VARCHAR2,
                     X_Pricing_Attribute10              VARCHAR2,
                     X_Pricing_Attribute11              VARCHAR2,
                     X_Pricing_Attribute12              VARCHAR2,
                     X_Pricing_Attribute13              VARCHAR2,
                     X_Pricing_Attribute14              VARCHAR2,
                     X_Pricing_Attribute15              VARCHAR2,
                     X_Pricing_Context                  VARCHAR2,
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
                     X_Context                          VARCHAR2,
                     X_Service_Order_Type               VARCHAR2,
                     X_Invoice_Count                    NUMBER,
                     X_Currency_Code                    VARCHAR2,
                     X_Conversion_Type                  VARCHAR2,
                     X_Conversion_Rate                  NUMBER,
                     X_Conversion_Date                  DATE,
                     X_Original_Service_Line_Id         NUMBER

  ) IS
    CURSOR C IS
        SELECT *
        FROM   cs_cp_services
        WHERE  rowid = X_Rowid
        FOR UPDATE of Cp_Service_Id NOWAIT;
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

               (Recinfo.cp_service_id = X_Cp_Service_Id)
           AND (Recinfo.customer_product_id = X_Customer_Product_Id)
           AND (Recinfo.service_inventory_item_id = X_Service_Inventory_Item_Id)
           AND (Recinfo.service_manufacturing_org_id = X_Service_Manufacturing_Org_Id)
           AND (   (trunc(Recinfo.start_date_active) =
			trunc(X_Start_Date_Active))
                OR (    (Recinfo.start_date_active IS NULL)
                    AND (X_Start_Date_Active IS NULL)))
           AND (   (trunc(Recinfo.end_date_active) = trunc(X_End_Date_Active))
                OR (    (Recinfo.end_date_active IS NULL)
                    AND (X_End_Date_Active IS NULL)))
           AND (   (Recinfo.Original_Start_Date = X_Original_Start_Date)
                OR (    (Recinfo.Original_Start_Date IS NULL)
                    AND (X_Original_Start_Date IS NULL)))
           AND (   (Recinfo.Original_End_Date = X_Original_End_Date)
                OR (    (Recinfo.Original_End_Date IS NULL)
                    AND (X_Original_End_Date IS NULL)))
           AND (   (Recinfo.service_date_change = X_Service_Date_Change)
			 OR (     (Recinfo.service_date_change IS NULL)
				AND  (X_Service_Date_Change IS NULL)))
           AND (   (Recinfo.status_code = X_Status_Code)
                OR (    (Recinfo.status_code IS NULL)
                    AND (X_Status_Code IS NULL)))
           AND (Recinfo.last_cp_service_transaction_id = X_Last_Cp_Service_Txn_Id)
           AND (   (Recinfo.invoice_flag = X_Invoice_Flag)
                OR (    (Recinfo.invoice_flag IS NULL)
                    AND (X_Invoice_Flag IS NULL)))
           AND (   (Recinfo.coverage_schedule_id = X_Coverage_Schedule_Id)
                OR (    (Recinfo.coverage_schedule_id IS NULL)
                    AND (X_Coverage_Schedule_Id IS NULL)))
           AND (   (Recinfo.prorate_flag = X_Prorate_Flag)
                OR (    (Recinfo.prorate_flag IS NULL)
                    AND (X_Prorate_Flag IS NULL)))
           AND (   (Recinfo.duration_quantity = X_Duration_Quantity)
                OR (    (Recinfo.duration_quantity IS NULL)
                    AND (X_Duration_Quantity IS NULL)))
           AND (   (Recinfo.unit_of_measure_code = X_Unit_Of_Measure_Code)
                OR (    (Recinfo.unit_of_measure_code IS NULL)
                    AND (X_Unit_Of_Measure_Code IS NULL)))
           AND (   (Recinfo.starting_delay = X_Starting_Delay)
                OR (    (Recinfo.starting_delay IS NULL)
                    AND (X_Starting_Delay IS NULL)))
           AND (   (Recinfo.bill_to_site_use_id = X_Bill_To_Site_Use_Id)
                OR (    (Recinfo.bill_to_site_use_id IS NULL)
                    AND (X_Bill_To_Site_Use_Id IS NULL)))
           AND (   (Recinfo.bill_to_contact_id = X_Bill_To_Contact_Id)
                OR (    (Recinfo.bill_to_contact_id IS NULL)
                    AND (X_Bill_To_Contact_Id IS NULL)))
           AND (   (Recinfo.service_txn_availability_code = X_Service_Txn_Avail_Code)
                OR (    (Recinfo.service_txn_availability_code IS NULL)
                    AND (X_Service_Txn_Avail_Code IS NULL)))
           AND (   (Recinfo.next_pm_visit_date = X_Next_Pm_Visit_Date)
                OR (    (Recinfo.next_pm_visit_date IS NULL)
                    AND (X_Next_Pm_Visit_Date IS NULL)))
           AND (   (Recinfo.pm_visits_completed = X_Pm_Visits_Completed)
                OR (    (Recinfo.pm_visits_completed IS NULL)
                    AND (X_Pm_Visits_Completed IS NULL)))
           AND (   (Recinfo.last_pm_visit_date = X_Last_Pm_Visit_Date)
                OR (    (Recinfo.last_pm_visit_date IS NULL)
                    AND (X_Last_Pm_Visit_Date IS NULL)))
           AND (   (Recinfo.pm_schedule_id = X_Pm_Schedule_Id)
                OR (    (Recinfo.pm_schedule_id IS NULL)
                    AND (X_Pm_Schedule_Id IS NULL)))
           AND (   (Recinfo.pm_schedule_flag = X_Pm_Schedule_Flag)
                OR (    (Recinfo.pm_schedule_flag IS NULL)
                    AND (X_Pm_Schedule_Flag IS NULL)))
           AND (   (Recinfo.current_max_schedule_date = X_Current_Max_Schedule_Date)
                OR (    (Recinfo.current_max_schedule_date IS NULL)
                    AND (X_Current_Max_Schedule_Date IS NULL)))
           AND (   (Recinfo.price_list_id = X_Price_List_Id)
                OR (    (Recinfo.price_list_id IS NULL)
                    AND (X_Price_List_Id IS NULL)))  ) then
	null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

     if (
               (   (Recinfo.pricing_attribute1 = X_Pricing_Attribute1)
                OR (    (Recinfo.pricing_attribute1 IS NULL)
                    AND (X_Pricing_Attribute1 IS NULL)))
           AND (   (Recinfo.pricing_attribute2 = X_Pricing_Attribute2)
                OR (    (Recinfo.pricing_attribute2 IS NULL)
                    AND (X_Pricing_Attribute2 IS NULL)))
           AND (   (Recinfo.pricing_attribute3 = X_Pricing_Attribute3)
                OR (    (Recinfo.pricing_attribute3 IS NULL)
                    AND (X_Pricing_Attribute3 IS NULL)))
           AND (   (Recinfo.pricing_attribute4 = X_Pricing_Attribute4)
                OR (    (Recinfo.pricing_attribute4 IS NULL)
                    AND (X_Pricing_Attribute4 IS NULL)))
           AND (   (Recinfo.pricing_attribute5 = X_Pricing_Attribute5)
                OR (    (Recinfo.pricing_attribute5 IS NULL)
                    AND (X_Pricing_Attribute5 IS NULL)))
           AND (   (Recinfo.pricing_attribute6 = X_Pricing_Attribute6)
                OR (    (Recinfo.pricing_attribute6 IS NULL)
                    AND (X_Pricing_Attribute6 IS NULL)))
           AND (   (Recinfo.pricing_attribute7 = X_Pricing_Attribute7)
                OR (    (Recinfo.pricing_attribute7 IS NULL)
                    AND (X_Pricing_Attribute7 IS NULL)))
           AND (   (Recinfo.pricing_attribute8 = X_Pricing_Attribute8)
                OR (    (Recinfo.pricing_attribute8 IS NULL)
                    AND (X_Pricing_Attribute8 IS NULL)))
           AND (   (Recinfo.pricing_attribute9 = X_Pricing_Attribute9)
                OR (    (Recinfo.pricing_attribute9 IS NULL)
                    AND (X_Pricing_Attribute9 IS NULL)))
           AND (   (Recinfo.pricing_attribute10 = X_Pricing_Attribute10)
                OR (    (Recinfo.pricing_attribute10 IS NULL)
                    AND (X_Pricing_Attribute10 IS NULL)))
           AND (   (Recinfo.pricing_attribute11 = X_Pricing_Attribute11)
                OR (    (Recinfo.pricing_attribute11 IS NULL)
                    AND (X_Pricing_Attribute11 IS NULL)))
           AND (   (Recinfo.pricing_attribute12 = X_Pricing_Attribute12)
                OR (    (Recinfo.pricing_attribute12 IS NULL)
                    AND (X_Pricing_Attribute12 IS NULL)))
           AND (   (Recinfo.pricing_attribute13 = X_Pricing_Attribute13)
                OR (    (Recinfo.pricing_attribute13 IS NULL)
                    AND (X_Pricing_Attribute13 IS NULL)))
           AND (   (Recinfo.pricing_attribute14 = X_Pricing_Attribute14)
                OR (    (Recinfo.pricing_attribute14 IS NULL)
                    AND (X_Pricing_Attribute14 IS NULL)))
           AND (   (Recinfo.pricing_attribute15 = X_Pricing_Attribute15)
                OR (    (Recinfo.pricing_attribute15 IS NULL)
                    AND (X_Pricing_Attribute15 IS NULL)))
           AND (   (Recinfo.pricing_context = X_Pricing_Context)
                OR (    (Recinfo.pricing_context IS NULL)
                    AND (X_Pricing_Context IS NULL)))
           AND (   (Recinfo.attribute1 = X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 = X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 = X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 = X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 = X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 = X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 = X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 = X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 = X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 = X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 = X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 = X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 = X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 = X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 = X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.context = X_Context)
                OR (    (Recinfo.context IS NULL)
                    AND (X_Context IS NULL))) ) then
	null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;


    if (
	       (   (Recinfo.service_order_type = X_Service_Order_Type)
                OR (    (Recinfo.service_order_type IS NULL)
                    AND (X_Service_Order_Type IS NULL)))
           AND (   (Recinfo.invoice_count = X_Invoice_Count)
                OR (    (Recinfo.invoice_count IS NULL)
                    AND (X_Invoice_Count IS NULL)))
           AND (   (Recinfo.currency_code = X_Currency_Code)
                OR (    (Recinfo.currency_code IS NULL)
                    AND (X_Currency_Code IS NULL)))
           AND (   (Recinfo.conversion_type = X_Conversion_Type)
                OR (    (Recinfo.conversion_type IS NULL)
                    AND (X_Conversion_Type IS NULL)))
           AND (   (Recinfo.conversion_rate = X_Conversion_Rate)
                OR (    (Recinfo.conversion_rate IS NULL)
                    AND (X_Conversion_Rate IS NULL)))
           AND (   (Recinfo.conversion_date = X_Conversion_Date)
                OR (    (Recinfo.conversion_date IS NULL)
                    AND (X_Conversion_Date IS NULL)))
           AND (   (Recinfo.original_service_line_id = X_Original_Service_Line_Id)
                OR (    (Recinfo.original_service_line_id IS NULL)
                    AND (X_Original_Service_Line_Id IS NULL)))

            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Cp_Service_Id                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Customer_Product_Id            NUMBER,
                       X_Service_Inventory_Item_Id      NUMBER,
                       X_Service_Manufacturing_Org_Id   NUMBER,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Original_Start_Date            DATE,
                       X_Original_End_Date              DATE,
				   X_Service_Date_Change            VARCHAR2,
                       X_Status_Code                    VARCHAR2,
                       X_Last_Cp_Service_Txn_Id         NUMBER,
                       X_Invoice_Flag                   VARCHAR2,
                       X_Coverage_Schedule_Id           NUMBER,
                       X_Prorate_Flag                   VARCHAR2,
                       X_Duration_Quantity              NUMBER,
                       X_Unit_Of_Measure_Code           VARCHAR2,
                       X_Starting_Delay                 NUMBER,
                       X_Bill_To_Site_Use_Id            NUMBER,
                       X_Bill_To_Contact_Id             NUMBER,
                       X_Service_Txn_Avail_Code         VARCHAR2,
                       X_Next_Pm_Visit_Date             DATE,
                       X_Pm_Visits_Completed            NUMBER,
                       X_Last_Pm_Visit_Date             DATE,
                       X_Pm_Schedule_Id                 NUMBER,
                       X_Pm_Schedule_Flag               VARCHAR2,
                       X_Current_Max_Schedule_Date      DATE,
                       X_Price_List_Id                  NUMBER,
                       X_Pricing_Attribute1             VARCHAR2,
                       X_Pricing_Attribute2             VARCHAR2,
                       X_Pricing_Attribute3             VARCHAR2,
                       X_Pricing_Attribute4             VARCHAR2,
                       X_Pricing_Attribute5             VARCHAR2,
                       X_Pricing_Attribute6             VARCHAR2,
                       X_Pricing_Attribute7             VARCHAR2,
                       X_Pricing_Attribute8             VARCHAR2,
                       X_Pricing_Attribute9             VARCHAR2,
                       X_Pricing_Attribute10            VARCHAR2,
                       X_Pricing_Attribute11            VARCHAR2,
                       X_Pricing_Attribute12            VARCHAR2,
                       X_Pricing_Attribute13            VARCHAR2,
                       X_Pricing_Attribute14            VARCHAR2,
                       X_Pricing_Attribute15            VARCHAR2,
                       X_Pricing_Context                VARCHAR2,
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
                       X_Context                        VARCHAR2,
                       X_Service_Order_Type             VARCHAR2,
                       X_Invoice_Count                  NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Conversion_Type                VARCHAR2,
                       X_Conversion_Rate                NUMBER,
                       X_Conversion_Date                DATE,
                       X_Original_Service_Line_Id       NUMBER

 ) IS
 BEGIN
   UPDATE cs_cp_services
   SET
     cp_service_id                     =     X_Cp_Service_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     customer_product_id               =     X_Customer_Product_Id,
     service_inventory_item_id         =     X_Service_Inventory_Item_Id,
     service_manufacturing_org_id      =     X_Service_Manufacturing_Org_Id,
     start_date_active                 =     X_Start_Date_Active,
     end_date_active                   =     X_End_Date_Active,
     original_start_date               =     X_Original_Start_Date,
     original_end_date                 =     X_Original_End_Date,
	service_date_change               =     X_Service_Date_Change,
     status_code                       =     X_Status_Code,
     last_cp_service_transaction_id    =     X_Last_Cp_Service_Txn_Id,
     invoice_flag                      =     X_Invoice_Flag,
     coverage_schedule_id              =     X_Coverage_Schedule_Id,
     prorate_flag                      =     X_Prorate_Flag,
     duration_quantity                 =     X_Duration_Quantity,
     unit_of_measure_code              =     X_Unit_Of_Measure_Code,
     starting_delay                    =     X_Starting_Delay,
     bill_to_site_use_id               =     X_Bill_To_Site_Use_Id,
     bill_to_contact_id                =     X_Bill_To_Contact_Id,
     service_txn_availability_code     =     X_Service_Txn_Avail_Code,
     next_pm_visit_date                =     X_Next_Pm_Visit_Date,
     pm_visits_completed               =     X_Pm_Visits_Completed,
     last_pm_visit_date                =     X_Last_Pm_Visit_Date,
     pm_schedule_id                    =     X_Pm_Schedule_Id,
     pm_schedule_flag                  =     X_Pm_Schedule_Flag,
     current_max_schedule_date         =     X_Current_Max_Schedule_Date,
     price_list_id                     =     X_Price_List_Id,
     pricing_attribute1                =     X_Pricing_Attribute1,
     pricing_attribute2                =     X_Pricing_Attribute2,
     pricing_attribute3                =     X_Pricing_Attribute3,
     pricing_attribute4                =     X_Pricing_Attribute4,
     pricing_attribute5                =     X_Pricing_Attribute5,
     pricing_attribute6                =     X_Pricing_Attribute6,
     pricing_attribute7                =     X_Pricing_Attribute7,
     pricing_attribute8                =     X_Pricing_Attribute8,
     pricing_attribute9                =     X_Pricing_Attribute9,
     pricing_attribute10               =     X_Pricing_Attribute10,
     pricing_attribute11               =     X_Pricing_Attribute11,
     pricing_attribute12               =     X_Pricing_Attribute12,
     pricing_attribute13               =     X_Pricing_Attribute13,
     pricing_attribute14               =     X_Pricing_Attribute14,
     pricing_attribute15               =     X_Pricing_Attribute15,
     pricing_context                   =     X_Pricing_Context,
     attribute1                        =     X_Attribute1,
     attribute2                        =     X_Attribute2,
     attribute3                        =     X_Attribute3,
     attribute4                        =     X_Attribute4,
     attribute5                        =     X_Attribute5,
     attribute6                        =     X_Attribute6,
     attribute7                        =     X_Attribute7,
     attribute8                        =     X_Attribute8,
     attribute9                        =     X_Attribute9,
     attribute10                       =     X_Attribute10,
     attribute11                       =     X_Attribute11,
     attribute12                       =     X_Attribute12,
     attribute13                       =     X_Attribute13,
     attribute14                       =     X_Attribute14,
     attribute15                       =     X_Attribute15,
     context                           =     X_Context,
     service_order_type                =     X_Service_Order_Type,
     invoice_count                     =     X_Invoice_Count,
     currency_code                     =     X_Currency_Code,
     conversion_type                   =     X_Conversion_Type,
     conversion_rate                   =     X_Conversion_Rate,
     conversion_date                   =     X_Conversion_Date,
     original_service_line_id          =     X_Original_Service_Line_Id
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;


END CS_CP_SERVICES_PKG;

/
