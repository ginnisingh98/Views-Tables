--------------------------------------------------------
--  DDL for Package Body CS_SERVICE_AVAILABILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SERVICE_AVAILABILITY_PKG" as
/* $Header: csxsisab.pls 115.0 99/07/16 09:08:56 porting ship $ */


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Service_Inventory_Item_Id        NUMBER,
                     X_Service_Manufacturing_Org_Id     NUMBER,
                     X_Inventory_Item_Id                NUMBER DEFAULT NULL,
                     X_Item_Manufacturing_Org_Id        NUMBER DEFAULT NULL,
                     X_Serviceable_Item_Class_Id        NUMBER DEFAULT NULL,
                     X_Customer_Id                      NUMBER DEFAULT NULL,
                     X_Customer_Set_Code                VARCHAR2 DEFAULT NULL,
                     X_Serial_Number_Low                VARCHAR2 DEFAULT NULL,
                     X_Serial_Number_High               VARCHAR2 DEFAULT NULL,
                     X_Revision_Low                     VARCHAR2 DEFAULT NULL,
                     X_Revision_High                    VARCHAR2 DEFAULT NULL,
                     X_Start_Date_Active                DATE DEFAULT NULL,
                     X_End_Date_Active                  DATE DEFAULT NULL,
                     X_Attribute1                       VARCHAR2 DEFAULT NULL,
                     X_Attribute2                       VARCHAR2 DEFAULT NULL,
                     X_Attribute3                       VARCHAR2 DEFAULT NULL,
                     X_Attribute4                       VARCHAR2 DEFAULT NULL,
                     X_Attribute5                       VARCHAR2 DEFAULT NULL,
                     X_Attribute6                       VARCHAR2 DEFAULT NULL,
                     X_Attribute7                       VARCHAR2 DEFAULT NULL,
                     X_Attribute8                       VARCHAR2 DEFAULT NULL,
                     X_Attribute9                       VARCHAR2 DEFAULT NULL,
                     X_Attribute10                      VARCHAR2 DEFAULT NULL,
                     X_Attribute11                      VARCHAR2 DEFAULT NULL,
                     X_Attribute12                      VARCHAR2 DEFAULT NULL,
                     X_Attribute13                      VARCHAR2 DEFAULT NULL,
                     X_Attribute14                      VARCHAR2 DEFAULT NULL,
                     X_Attribute15                      VARCHAR2 DEFAULT NULL,
                     X_Context                          VARCHAR2 DEFAULT NULL,
                     X_Service_Available_Flag           VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS
        SELECT *
        FROM   cs_service_availability
        WHERE  rowid = X_Rowid
        FOR UPDATE  NOWAIT;
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
               (Recinfo.service_inventory_item_id = X_Service_Inventory_Item_Id)


           AND (Recinfo.service_manufacturing_org_id = X_Service_Manufacturing_Org_Id)
           AND (   (Recinfo.inventory_item_id = X_Inventory_Item_Id)
                OR (    (Recinfo.inventory_item_id IS NULL)
                    AND (X_Inventory_Item_Id IS NULL)))
           AND (   (Recinfo.item_manufacturing_org_id = X_Item_Manufacturing_Org_Id)
                OR (    (Recinfo.item_manufacturing_org_id IS NULL)
                    AND (X_Item_Manufacturing_Org_Id IS NULL)))
           AND (   (Recinfo.serviceable_item_class_id = X_Serviceable_Item_Class_Id)
                OR (    (Recinfo.serviceable_item_class_id IS NULL)
                    AND (X_Serviceable_Item_Class_Id IS NULL)))
           AND (   (Recinfo.customer_id = X_Customer_Id)
                OR (    (Recinfo.customer_id IS NULL)
                    AND (X_Customer_Id IS NULL)))
           AND (   (Recinfo.customer_set_code = X_Customer_Set_Code)
                OR (    (Recinfo.customer_set_code IS NULL)
                    AND (X_Customer_Set_Code IS NULL)))
           AND (   (Recinfo.serial_number_low = X_Serial_Number_Low)
                OR (    (Recinfo.serial_number_low IS NULL)
                    AND (X_Serial_Number_Low IS NULL)))
           AND (   (Recinfo.serial_number_high = X_Serial_Number_High)
                OR (    (Recinfo.serial_number_high IS NULL)
                    AND (X_Serial_Number_High IS NULL)))
           AND (   (Recinfo.revision_low = X_Revision_Low)
                OR (    (Recinfo.revision_low IS NULL)
                    AND (X_Revision_Low IS NULL)))
           AND (   (Recinfo.revision_high = X_Revision_High)
                OR (    (Recinfo.revision_high IS NULL)
                    AND (X_Revision_High IS NULL)))
           AND (   (Recinfo.start_date_active = X_Start_Date_Active)
                OR (    (Recinfo.start_date_active IS NULL)
                    AND (X_Start_Date_Active IS NULL)))
           AND (   (Recinfo.end_date_active = X_End_Date_Active)
                OR (    (Recinfo.end_date_active IS NULL)
                    AND (X_End_Date_Active IS NULL)))
           AND (   (Recinfo.attribute1 = X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 = X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (Recinfo.Service_Available_Flag = X_Service_Available_Flag ) )THEN
         null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
     if (
            (   (Recinfo.attribute3 = X_Attribute3)
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
                    AND (X_Context IS NULL)))
            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Service_Inventory_Item_Id      NUMBER,
                       X_Service_Manufacturing_Org_Id   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Inventory_Item_Id              NUMBER DEFAULT NULL,
                       X_Item_Manufacturing_Org_Id      NUMBER DEFAULT NULL,
                       X_Serviceable_Item_Class_Id      NUMBER DEFAULT NULL,
                       X_Customer_Id                    NUMBER DEFAULT NULL,
                       X_Customer_Set_Code              VARCHAR2 DEFAULT NULL,
                       X_Serial_Number_Low              VARCHAR2 DEFAULT NULL,
                       X_Serial_Number_High             VARCHAR2 DEFAULT NULL,
                       X_Revision_Low                   VARCHAR2 DEFAULT NULL,
                       X_Revision_High                  VARCHAR2 DEFAULT NULL,
                       X_Start_Date_Active              DATE DEFAULT NULL,
                       X_End_Date_Active                DATE DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Context                        VARCHAR2 DEFAULT NULL,
                       X_Service_Available_Flag         VARCHAR2 DEFAULT NULL
) IS
 BEGIN
   UPDATE cs_service_availability
   SET
     service_inventory_item_id         =     X_Service_Inventory_Item_Id,
     service_manufacturing_org_id      =     X_Service_Manufacturing_Org_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     inventory_item_id                 =     X_Inventory_Item_Id,
     item_manufacturing_org_id         =     X_Item_Manufacturing_Org_Id,
     serviceable_item_class_id         =     X_Serviceable_Item_Class_Id,
     customer_id                       =     X_Customer_Id,
     customer_set_code                 =     X_Customer_Set_Code,
     serial_number_low                 =     X_Serial_Number_Low,
     serial_number_high                =     X_Serial_Number_High,
     revision_low                      =     X_Revision_Low,
     revision_high                     =     X_Revision_High,
     start_date_active                 =     X_Start_Date_Active,
     end_date_active                   =     X_End_Date_Active,
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
	Service_Available_Flag            =     X_Service_Available_Flag
   WHERE rowid = X_rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM cs_service_availability
    WHERE  rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
END Delete_Row;

PROCEDURE Insert_Row(X_Rowid                          IN OUT VARCHAR2,
                     X_service_availability_id        IN OUT NUMBER,
                     X_Service_Inventory_Item_Id      NUMBER,
                     X_Service_Manufacturing_Org_Id   NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Creation_Date                  DATE,
                     X_Created_By                     NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_Inventory_Item_Id              NUMBER DEFAULT NULL,
                     X_Item_Manufacturing_Org_Id      NUMBER DEFAULT NULL,
                     X_Customer_Id                    NUMBER DEFAULT NULL,
                     X_Serial_Number_Low              VARCHAR2 DEFAULT NULL,
                     X_Serial_Number_High             VARCHAR2 DEFAULT NULL,
                     X_Revision_Low                   VARCHAR2 DEFAULT NULL,
                     X_Revision_High                  VARCHAR2 DEFAULT NULL,
                     X_Start_Date_Active              DATE DEFAULT NULL,
                     X_End_Date_Active                DATE DEFAULT NULL,
                     X_Attribute1                     VARCHAR2 DEFAULT NULL,
                     X_Attribute2                     VARCHAR2 DEFAULT NULL,
                     X_Attribute3                     VARCHAR2 DEFAULT NULL,
                     X_Attribute4                     VARCHAR2 DEFAULT NULL,
                     X_Attribute5                     VARCHAR2 DEFAULT NULL,
                     X_Attribute6                     VARCHAR2 DEFAULT NULL,
                     X_Attribute7                     VARCHAR2 DEFAULT NULL,
                     X_Attribute8                     VARCHAR2 DEFAULT NULL,
                     X_Attribute9                     VARCHAR2 DEFAULT NULL,
                     X_Attribute10                    VARCHAR2 DEFAULT NULL,
                     X_Attribute11                    VARCHAR2 DEFAULT NULL,
                     X_Attribute12                    VARCHAR2 DEFAULT NULL,
                     X_Attribute13                    VARCHAR2 DEFAULT NULL,
                     X_Attribute14                    VARCHAR2 DEFAULT NULL,
                     X_Attribute15                    VARCHAR2 DEFAULT NULL,
                     X_Context                        VARCHAR2 DEFAULT NULL,
                     X_Service_Available_Flag         VARCHAR2 DEFAULT NULL
) IS
 BEGIN
   INSERT INTO cs_service_availability
    ( Service_Availability_id,
      Service_Inventory_Item_Id,
      Service_Manufacturing_Org_Id,
      Last_Update_Date,
      Last_Updated_By,
      Creation_Date,
      Created_By,
      Last_Update_Login,
      Inventory_Item_Id,
      Item_Manufacturing_Org_Id,
      Serviceable_Item_Class_Id,
      Customer_Id,
      Customer_Set_Code,
      Serial_Number_Low,
      Serial_Number_High,
      Revision_Low,
      Revision_High,
      Start_Date_Active,
      End_Date_Active,
      Attribute1,
      Attribute2,
      Attribute3,
      Attribute4,
      Attribute5,
      Attribute6,
      Attribute7,
      Attribute8,
      Attribute9,
      Attribute10,
      Attribute11,
      Attribute12,
      Attribute13,
      Attribute14,
      Attribute15,
      Context,
      Service_Available_Flag )
  VALUES (
      X_service_availability_id,
      X_Service_Inventory_Item_Id,
      X_Service_Manufacturing_Org_Id,
      X_Last_Update_Date,
      X_Last_Updated_By,
      X_Creation_Date,
      X_Created_By,
      X_Last_Update_Login,
      X_Inventory_Item_Id,
      X_Item_Manufacturing_Org_Id,
      null,
      X_Customer_Id,
      null,
      X_Serial_Number_Low,
      X_Serial_Number_High,
      X_Revision_Low,
      X_Revision_High,
      X_Start_Date_Active,
      X_END_Date_Active,
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
      X_Context,
      X_Service_Available_Flag);

  IF (SQL%NOTFOUND) THEN
	Raise NO_DATA_FOUND;
  END IF;

  SELECT rowid
    INTO X_rowid
    FROM CS_SERVICE_AVAILABILITY
   WHERE service_availability_id = X_service_availability_id;

END Insert_Row;

END CS_SERVICE_AVAILABILITY_PKG;

/
