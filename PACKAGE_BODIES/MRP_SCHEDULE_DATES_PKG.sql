--------------------------------------------------------
--  DDL for Package Body MRP_SCHEDULE_DATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SCHEDULE_DATES_PKG" AS
/* $Header: MRSDATEB.pls 115.0 99/07/16 12:44:32 porting ship $ */

PROCEDURE Insert_Row(
                  X_Rowid                         IN OUT VARCHAR2,
                  X_MPS_Transaction_Id                   NUMBER,
                  X_Schedule_Level                       NUMBER,
                  X_Supply_Demand_Type                   NUMBER,
                  X_Last_Update_Date                     DATE,
                  X_Last_Updated_By                      NUMBER,
                  X_Creation_Date                        DATE,
                  X_Created_By                           NUMBER,
                  X_Last_Update_Login                    NUMBER DEFAULT NULL,
                  X_Inventory_Item_Id                    NUMBER,
                  X_Organization_Id                      NUMBER,
                  X_Schedule_Designator                  VARCHAR2,
                  X_Schedule_Date                        DATE,
                  X_Schedule_Workdate                    DATE,
                  X_Rate_End_Date	                 DATE DEFAULT NULL,
                  X_Schedule_Quantity                    NUMBER DEFAULT NULL,
                  X_Original_Schedule_Quantity           NUMBER DEFAULT NULL,
                  X_Repetitive_Daily_Rate                NUMBER DEFAULT NULL,
                  X_Schedule_Origination_Type            NUMBER,
                  X_Source_Forecast_Designator           VARCHAR2 DEFAULT NULL,
                  X_Reference_Schedule_Id                NUMBER DEFAULT NULL,
                  X_Schedule_Comments                    VARCHAR2 DEFAULT NULL,
                  X_Source_Organization_Id               NUMBER DEFAULT NULL,
                  X_Source_Schedule_Designator           VARCHAR2 DEFAULT NULL,
                  X_Source_Sales_Order_Id                NUMBER DEFAULT NULL,
                  X_Source_Code			         VARCHAR2 DEFAULT NULL,
                  X_Source_Line_Id       	         NUMBER DEFAULT NULL,
                  X_Reservation_Id	                 NUMBER DEFAULT NULL,
                  X_Forecast_Id		                 NUMBER DEFAULT NULL,
                  X_Request_Id                  	 NUMBER DEFAULT NULL,
                  X_Program_Application_Id               NUMBER DEFAULT NULL,
                  X_Program_Id                           NUMBER DEFAULT NULL,
                  X_Program_Update_Date                  DATE DEFAULT NULL,
                  X_DDF_Context                   	 VARCHAR2 DEFAULT NULL,
                  X_Attribute_Category                   VARCHAR2 DEFAULT NULL,
                  X_Attribute1                           VARCHAR2 DEFAULT NULL,
                  X_Attribute2                           VARCHAR2 DEFAULT NULL,
                  X_Attribute3                           VARCHAR2 DEFAULT NULL,
                  X_Attribute4                           VARCHAR2 DEFAULT NULL,
                  X_Attribute5                           VARCHAR2 DEFAULT NULL,
                  X_Attribute6                           VARCHAR2 DEFAULT NULL,
                  X_Attribute7                           VARCHAR2 DEFAULT NULL,
                  X_Attribute8                           VARCHAR2 DEFAULT NULL,
                  X_Attribute9                           VARCHAR2 DEFAULT NULL,
                  X_Attribute10                          VARCHAR2 DEFAULT NULL,
                  X_Attribute11                          VARCHAR2 DEFAULT NULL,
                  X_Attribute12                          VARCHAR2 DEFAULT NULL,
                  X_Attribute13                          VARCHAR2 DEFAULT NULL,
                  X_Attribute14                          VARCHAR2 DEFAULT NULL,
                  X_Attribute15                          VARCHAR2 DEFAULT NULL
) IS

   CURSOR C IS SELECT rowid
                FROM MRP_SCHEDULE_DATES
                WHERE mps_transaction_id = X_MPS_Transaction_Id
		  AND schedule_level = X_Schedule_Level
                  AND supply_demand_type = X_Supply_Demand_Type;

BEGIN

  INSERT INTO MRP_SCHEDULE_dates(
                  mps_transaction_id,
                  schedule_level,
                  supply_demand_type,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  last_update_login,
                  inventory_item_id,
                  organization_id,
                  schedule_designator,
                  schedule_date,
                  schedule_workdate,
                  rate_end_date,
                  schedule_quantity,
                  original_schedule_quantity,
                  repetitive_daily_rate,
                  schedule_origination_type,
                  source_forecast_designator,
                  reference_schedule_id,
                  schedule_comments,
                  source_organization_id,
                  source_schedule_designator,
                  source_sales_order_id,
                  source_code,
                  source_line_id,
                  reservation_id,
                  forecast_id,
                  request_id,
                  program_application_id,
                  program_id,
                  program_update_date,
                  ddf_context,
                  attribute_category,
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
                  attribute15
         ) VALUES (
                  X_MPS_Transaction_Id,
                  X_Schedule_Level,
                  X_Supply_Demand_Type,
                  X_Last_Update_Date,
                  X_Last_Updated_By,
                  X_Creation_Date,
                  X_Created_By,
                  X_Last_Update_Login,
                  X_Inventory_Item_Id,
                  X_Organization_Id,
                  X_Schedule_Designator,
                  X_Schedule_Date,
                  X_Schedule_Workdate,
                  X_Rate_End_Date,
                  X_Schedule_Quantity,
                  X_Original_Schedule_Quantity,
                  X_Repetitive_Daily_Rate,
                  X_Schedule_Origination_Type,
                  X_Source_Forecast_Designator,
                  X_Reference_Schedule_Id,
                  X_Schedule_Comments,
                  X_Source_Organization_Id,
                  X_Source_Schedule_Designator,
                  X_Source_Sales_Order_Id,
                  X_Source_Code,
                  X_Source_Line_Id,
                  X_Reservation_Id,
                  X_Forecast_Id,
                  X_Request_Id,
                  X_Program_Application_Id,
                  X_Program_Id,
                  X_Program_Update_Date,
                  X_DDF_Context,
                  X_Attribute_Category,
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
                  X_Attribute15
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

END Insert_Row;


PROCEDURE Lock_Row(
                  X_Rowid                                VARCHAR2,
                  X_MPS_Transaction_Id                   NUMBER,
                  X_Schedule_Level                       NUMBER,
                  X_Supply_Demand_Type                   NUMBER,
                  X_Last_Update_Date                     DATE,
                  X_Last_Updated_By                      NUMBER,
                  X_Creation_Date                        DATE,
                  X_Created_By                           NUMBER,
                  X_Last_Update_Login                    NUMBER DEFAULT NULL,
                  X_Inventory_Item_Id                    NUMBER,
                  X_Organization_Id                      NUMBER,
                  X_Schedule_Designator                  VARCHAR2,
                  X_Schedule_Date                        DATE,
                  X_Schedule_Workdate                    DATE,
                  X_Rate_End_Date	                 DATE DEFAULT NULL,
                  X_Schedule_Quantity                    NUMBER DEFAULT NULL,
                  X_Original_Schedule_Quantity           NUMBER DEFAULT NULL,
                  X_Repetitive_Daily_Rate                NUMBER DEFAULT NULL,
                  X_Schedule_Origination_Type            NUMBER,
                  X_Source_Forecast_Designator           VARCHAR2 DEFAULT NULL,
                  X_Reference_Schedule_Id                NUMBER DEFAULT NULL,
                  X_Schedule_Comments                    VARCHAR2 DEFAULT NULL,
                  X_Source_Organization_Id               NUMBER DEFAULT NULL,
                  X_Source_Schedule_Designator           VARCHAR2 DEFAULT NULL,
                  X_Source_Sales_Order_Id                NUMBER DEFAULT NULL,
                  X_Source_Code			         VARCHAR2 DEFAULT NULL,
                  X_Source_Line_Id       	         NUMBER DEFAULT NULL,
                  X_Reservation_Id	                 NUMBER DEFAULT NULL,
                  X_Forecast_Id		                 NUMBER DEFAULT NULL,
                  X_Request_Id                  	 NUMBER DEFAULT NULL,
                  X_Program_Application_Id               NUMBER DEFAULT NULL,
                  X_Program_Id                           NUMBER DEFAULT NULL,
                  X_Program_Update_Date                  DATE DEFAULT NULL,
                  X_DDF_Context                   	 VARCHAR2 DEFAULT NULL,
                  X_Attribute_Category                   VARCHAR2 DEFAULT NULL,
                  X_Attribute1                           VARCHAR2 DEFAULT NULL,
                  X_Attribute2                           VARCHAR2 DEFAULT NULL,
                  X_Attribute3                           VARCHAR2 DEFAULT NULL,
                  X_Attribute4                           VARCHAR2 DEFAULT NULL,
                  X_Attribute5                           VARCHAR2 DEFAULT NULL,
                  X_Attribute6                           VARCHAR2 DEFAULT NULL,
                  X_Attribute7                           VARCHAR2 DEFAULT NULL,
                  X_Attribute8                           VARCHAR2 DEFAULT NULL,
                  X_Attribute9                           VARCHAR2 DEFAULT NULL,
                  X_Attribute10                          VARCHAR2 DEFAULT NULL,
                  X_Attribute11                          VARCHAR2 DEFAULT NULL,
                  X_Attribute12                          VARCHAR2 DEFAULT NULL,
                  X_Attribute13                          VARCHAR2 DEFAULT NULL,
                  X_Attribute14                          VARCHAR2 DEFAULT NULL,
                  X_Attribute15                          VARCHAR2 DEFAULT NULL
) IS

  CURSOR C IS
      SELECT *
      FROM   MRP_SCHEDULE_DATES
      WHERE  rowid = X_Rowid
      FOR UPDATE OF mps_transaction_id NOWAIT;

  Recinfo C%ROWTYPE;

BEGIN

  OPEN C;
  FETCH C INTO Recinfo;

  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;

  CLOSE C;

  if (
           (Recinfo.mps_transaction_id = X_MPS_Transaction_Id)
      AND  (Recinfo.schedule_level = X_Schedule_Level)
      AND  (Recinfo.supply_demand_type = X_Supply_Demand_Type)
      AND  (Recinfo.inventory_item_id = X_Inventory_Item_Id)
      AND  (Recinfo.organization_id = X_Organization_Id)
      AND  (Recinfo.schedule_designator = X_Schedule_Designator)
      AND  (Recinfo.schedule_date = X_Schedule_Date)
      AND  (Recinfo.schedule_workdate = X_Schedule_Workdate)
      AND (   (Recinfo.rate_end_date = X_Rate_End_Date)
           OR (    (Recinfo.rate_end_date IS NULL)
               AND (X_Rate_End_Date IS NULL)))
      AND (   (Recinfo.schedule_quantity = X_Schedule_Quantity)
           OR (    (Recinfo.schedule_quantity IS NULL)
               AND (X_Schedule_Quantity IS NULL)))
      AND (   (Recinfo.original_schedule_quantity = X_Original_Schedule_Quantity)
           OR (    (Recinfo.original_schedule_quantity IS NULL)
               AND (X_Original_Schedule_Quantity IS NULL)))
      AND (   (Recinfo.repetitive_daily_rate = X_Repetitive_Daily_Rate)
           OR (    (Recinfo.repetitive_daily_rate IS NULL)
               AND (X_Repetitive_Daily_Rate IS NULL)))
      AND  (Recinfo.schedule_origination_type = X_Schedule_Origination_Type)
      AND (   (Recinfo.source_forecast_designator = X_Source_Forecast_Designator)
           OR (    (Recinfo.source_forecast_designator IS NULL)
               AND (X_Source_Forecast_Designator IS NULL)))
      AND (   (Recinfo.reference_schedule_id = X_Reference_Schedule_Id)
           OR (    (Recinfo.reference_schedule_id IS NULL)
               AND (X_Reference_Schedule_Id IS NULL)))
      AND (   (Recinfo.schedule_comments = X_Schedule_Comments)
           OR (    (Recinfo.schedule_comments IS NULL)
               AND (X_Schedule_Comments IS NULL)))
      AND (   (Recinfo.source_organization_id = X_Source_Organization_Id)
           OR (    (Recinfo.source_organization_id IS NULL)
               AND (X_Source_Organization_Id IS NULL)))
      AND (   (Recinfo.source_schedule_designator = X_Source_Schedule_Designator)
           OR (    (Recinfo.source_schedule_designator IS NULL)
               AND (X_Source_Schedule_Designator IS NULL)))
      AND (   (Recinfo.source_sales_order_id = X_Source_Sales_Order_Id)
           OR (    (Recinfo.source_sales_order_id IS NULL)
               AND (X_Source_Sales_Order_Id IS NULL)))
      AND (   (Recinfo.source_code = X_Source_Code)
           OR (    (Recinfo.source_code IS NULL)
               AND (X_Source_Code IS NULL)))
      AND (   (Recinfo.source_line_id = X_Source_Line_Id)
           OR (    (Recinfo.source_line_id IS NULL)
               AND (X_Source_Line_Id IS NULL)))
      AND (   (Recinfo.reservation_id = X_Reservation_Id)
           OR (    (Recinfo.reservation_id IS NULL)
               AND (X_Reservation_Id IS NULL)))
      AND (   (Recinfo.forecast_id = X_Forecast_Id)
           OR (    (Recinfo.forecast_id IS NULL)
               AND (X_Forecast_Id IS NULL)))
      AND (   (Recinfo.ddf_context = X_DDF_Context)
           OR (    (Recinfo.ddf_context IS NULL)
               AND (X_DDF_Context IS NULL)))
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
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
      ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;


PROCEDURE Update_Row(
                  X_Rowid                                VARCHAR2,
                  X_MPS_Transaction_Id                   NUMBER,
                  X_Schedule_Level                       NUMBER,
                  X_Supply_Demand_Type                   NUMBER,
                  X_Last_Update_Date                     DATE,
                  X_Last_Updated_By                      NUMBER,
                  X_Creation_Date                        DATE,
                  X_Created_By                           NUMBER,
                  X_Last_Update_Login                    NUMBER DEFAULT NULL,
                  X_Inventory_Item_Id                    NUMBER,
                  X_Organization_Id                      NUMBER,
                  X_Schedule_Designator                  VARCHAR2,
                  X_Schedule_Date                        DATE,
                  X_Schedule_Workdate                    DATE,
                  X_Rate_End_Date	                 DATE DEFAULT NULL,
                  X_Schedule_Quantity                    NUMBER DEFAULT NULL,
                  X_Original_Schedule_Quantity           NUMBER DEFAULT NULL,
                  X_Repetitive_Daily_Rate                NUMBER DEFAULT NULL,
                  X_Schedule_Origination_Type            NUMBER,
                  X_Source_Forecast_Designator           VARCHAR2 DEFAULT NULL,
                  X_Reference_Schedule_Id                NUMBER DEFAULT NULL,
                  X_Schedule_Comments                    VARCHAR2 DEFAULT NULL,
                  X_Source_Organization_Id               NUMBER DEFAULT NULL,
                  X_Source_Schedule_Designator           VARCHAR2 DEFAULT NULL,
                  X_Source_Sales_Order_Id                NUMBER DEFAULT NULL,
                  X_Source_Code			         VARCHAR2 DEFAULT NULL,
                  X_Source_Line_Id       	         NUMBER DEFAULT NULL,
                  X_Reservation_Id	                 NUMBER DEFAULT NULL,
                  X_Forecast_Id		                 NUMBER DEFAULT NULL,
                  X_Request_Id                  	 NUMBER DEFAULT NULL,
                  X_Program_Application_Id               NUMBER DEFAULT NULL,
                  X_Program_Id                           NUMBER DEFAULT NULL,
                  X_Program_Update_Date                  DATE DEFAULT NULL,
                  X_DDF_Context                   	 VARCHAR2 DEFAULT NULL,
                  X_Attribute_Category                   VARCHAR2 DEFAULT NULL,
                  X_Attribute1                           VARCHAR2 DEFAULT NULL,
                  X_Attribute2                           VARCHAR2 DEFAULT NULL,
                  X_Attribute3                           VARCHAR2 DEFAULT NULL,
                  X_Attribute4                           VARCHAR2 DEFAULT NULL,
                  X_Attribute5                           VARCHAR2 DEFAULT NULL,
                  X_Attribute6                           VARCHAR2 DEFAULT NULL,
                  X_Attribute7                           VARCHAR2 DEFAULT NULL,
                  X_Attribute8                           VARCHAR2 DEFAULT NULL,
                  X_Attribute9                           VARCHAR2 DEFAULT NULL,
                  X_Attribute10                          VARCHAR2 DEFAULT NULL,
                  X_Attribute11                          VARCHAR2 DEFAULT NULL,
                  X_Attribute12                          VARCHAR2 DEFAULT NULL,
                  X_Attribute13                          VARCHAR2 DEFAULT NULL,
                  X_Attribute14                          VARCHAR2 DEFAULT NULL,
                  X_Attribute15                          VARCHAR2 DEFAULT NULL
) IS

BEGIN

  UPDATE MRP_SCHEDULE_DATES
  SET
    mps_transaction_id			      =    X_MPS_Transaction_Id,
    schedule_level			      =    X_Schedule_Level,
    supply_demand_type                        =    X_Supply_Demand_Type,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    creation_date 			      =    X_Creation_Date,
    created_by                                =    X_Created_By,
    last_update_login                         =    X_Last_Update_Login,
    inventory_item_id			      =    X_Inventory_Item_Id,
    organization_id                           =    X_Organization_Id,
    schedule_designator                       =    X_Schedule_Designator,
    schedule_date			      =	   X_Schedule_Date,
    schedule_workdate			      =    X_Schedule_Workdate,
    rate_end_date			      =    X_Rate_End_Date,
    schedule_quantity			      =    X_Schedule_Quantity,
    original_schedule_quantity		      =    X_Original_Schedule_Quantity,
    repetitive_daily_rate		      =    X_Repetitive_Daily_Rate,
    schedule_origination_type		      =    X_Schedule_Origination_Type,
    source_forecast_designator		      =    X_Source_Forecast_Designator,
    reference_schedule_id		      =    X_Reference_Schedule_Id,
    schedule_comments			      =    X_Schedule_Comments,
    source_organization_id		      =    X_Source_Organization_Id,
    source_schedule_designator		      =    X_Source_Schedule_Designator,
    source_sales_order_id		      =    X_Source_Sales_Order_Id,
    source_code				      =    X_Source_Code,
    source_line_id			      =    X_Source_Line_Id,
    reservation_id		   	      =    X_Reservation_Id,
    forecast_id				      =    X_Forecast_Id,
    request_id				      =    X_Request_Id,
    program_application_id		      =    X_Program_Application_Id,
    program_id				      =    X_Program_Id,
    program_update_date			      =    X_Program_Update_Date,
    ddf_context				      =    X_DDF_Context,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;


PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS

BEGIN
  DELETE FROM MRP_SCHEDULE_DATES
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;


PROCEDURE Get_Unique_Id(X_Unique_Id      IN OUT  NUMBER) IS

   CURSOR C IS
	SELECT mrp_schedule_dates_s.nextval
	  FROM DUAL;

BEGIN

  OPEN C;

  FETCH C INTO X_Unique_Id;

  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;

  CLOSE C;

END Get_Unique_Id;


END MRP_SCHEDULE_DATES_PKG;

/
