--------------------------------------------------------
--  DDL for Package Body RCV_SHIPMENT_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_SHIPMENT_HEADERS_PKG" as
/* $Header: RCVTISHB.pls 120.2 2006/03/15 03:46:29 atiwari noship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Shipment_Header_Id             IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Receipt_Source_Code            VARCHAR2,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Organization_Id                NUMBER,
		       X_ship_to_org_id			NUMBER,
                       X_Shipment_Num                   VARCHAR2,
                       X_Receipt_Num                    IN OUT NOCOPY VARCHAR2,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Bill_Of_Lading                 VARCHAR2,
                       X_Packing_Slip                   VARCHAR2,
                       X_Shipped_Date                   DATE,
                       X_Freight_Carrier_Code           VARCHAR2,
                       X_Expected_Receipt_Date          DATE,
                       X_Employee_Id                    NUMBER,
                       X_Num_Of_Containers              NUMBER,
                       X_Waybill_Airbill_Num            VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
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
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
		       X_Request_Id			NUMBER,
		       X_Program_Application_Id		NUMBER,
		       X_Program_Id			NUMBER,
		       X_Program_Update_Date		DATE,
		       X_customer_id		        NUMBER,
		       X_customer_site_id		NUMBER

   ) IS
     CURSOR C IS SELECT rowid FROM RCV_SHIPMENT_HEADERS
                 WHERE shipment_header_id = X_Shipment_Header_Id;

      CURSOR C2 IS SELECT rcv_shipment_headers_s.nextval FROM sys.dual;

      X_RECEIPT_CODE  VARCHAR2(25);
      X_TEMP_RECEIPT_NUM VARCHAR(30);
      X_RECEIPT_EXISTS NUMBER := 0;

    BEGIN
      if (X_Shipment_Header_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Shipment_Header_Id;
        CLOSE C2;
      end if;


     select user_defined_receipt_num_code
     into   x_receipt_code
     from   rcv_parameters
     where  organization_id = x_ship_to_org_id;


    /*  hvadlamu : to make the receipt numbers unique across orgs
      SELECT USER_DEFINED_RECEIPT_NUM_CODE
      INTO   X_RECEIPT_CODE
      FROM   PO_SYSTEM_PARAMETERS; */

      IF (NVL(X_RECEIPT_CODE, 'MANUAL') = 'AUTOMATIC') THEN

            /*
            ** Bug#4913999 - START
            ** Changed the code to get the next unique receipt number
            ** when the receipt number in receiving options form is not unique as in
            ** the case of ROI rather than displaying message to the user
            */

            select to_char(next_receipt_num + 1)
            into X_temp_receipt_num
            from rcv_parameters
            where organization_id = x_ship_to_org_id
            FOR UPDATE OF next_receipt_num;

            LOOP
                SELECT COUNT(*)
                INTO X_receipt_exists
                FROM   rcv_shipment_headers rsh
                WHERE  receipt_num = X_temp_receipt_num
                AND    ship_to_org_id = x_ship_to_org_id;

                IF X_receipt_exists = 0 THEN

                    update rcv_parameters
                    set next_receipt_num = X_temp_receipt_num
                    where organization_id = x_ship_to_org_id;

                    EXIT;
                ELSE
                    X_temp_receipt_num := TO_CHAR(TO_NUMBER(X_temp_receipt_num) + 1);
                END IF;
            END LOOP;
            /* Bug#4913999 - END */

             X_receipt_num :=  X_temp_receipt_num;

       ELSE

             X_temp_receipt_num := X_receipt_num;

       END IF;

       INSERT INTO RCV_SHIPMENT_HEADERS(
               shipment_header_id,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               receipt_source_code,
               vendor_id,
               vendor_site_id,
               organization_id,
	       ship_to_org_id,
               shipment_num,
               receipt_num,
               ship_to_location_id,
               bill_of_lading,
               packing_slip,
               shipped_date,
               freight_carrier_code,
               expected_receipt_date,
               employee_id,
               num_of_containers,
               waybill_airbill_num,
               comments,
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
               attribute15,
               ussgl_transaction_code,
               government_context,
	       request_id,
	       program_application_id,
               program_id,
	       program_update_date,
	       customer_id,
	       customer_site_id
             ) VALUES (
               X_Shipment_Header_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
               X_Receipt_Source_Code,
               X_Vendor_Id,
               X_Vendor_Site_Id,
               X_Organization_Id,
	       X_Ship_to_org_id,
               X_Shipment_Num,
               X_Temp_Receipt_Num,
               X_Ship_To_Location_Id,
               X_Bill_Of_Lading,
               X_Packing_Slip,
               X_Shipped_Date,
               X_Freight_Carrier_Code,
               X_Expected_Receipt_Date,
               X_Employee_Id,
               X_Num_Of_Containers,
               X_Waybill_Airbill_Num,
               X_Comments,
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
               X_Attribute15,
               X_Ussgl_Transaction_Code,
               X_Government_Context,
	       X_Request_Id,
	       X_Program_Application_Id,
	       X_Program_Id,
   	       X_Program_Update_Date,
	       X_customer_id,
	       X_customer_site_id
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

    EXCEPTION
	WHEN OTHERS THEN
	RAISE;

  END Insert_Row;



  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Shipment_Header_Id               NUMBER,
                     X_Receipt_Source_Code              VARCHAR2,
                     X_Vendor_Id                        NUMBER,
                     X_Vendor_Site_Id                   NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Shipment_Num                     VARCHAR2,
                     X_Receipt_Num                      VARCHAR2,
                     X_Ship_To_Location_Id              NUMBER,
                     X_Bill_Of_Lading                   VARCHAR2,
                     X_Packing_Slip                     VARCHAR2,
                     X_Shipped_Date                     DATE,
                     X_Freight_Carrier_Code             VARCHAR2,
                     X_Expected_Receipt_Date            DATE,
                     X_Employee_Id                      NUMBER,
                     X_Num_Of_Containers                NUMBER,
                     X_Waybill_Airbill_Num              VARCHAR2,
                     X_Comments                         VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
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
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Government_Context               VARCHAR2,
		     X_Request_Id			NUMBER,
		     X_Program_Application_Id		NUMBER,
		     X_Program_Id			NUMBER,
		     X_Program_Update_Date		DATE,
		     X_customer_id		        NUMBER,
		     X_customer_site_id			NUMBER

  ) IS
    CURSOR C IS
        SELECT *
        FROM   RCV_SHIPMENT_HEADERS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Shipment_Header_Id NOWAIT;
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

               (Recinfo.shipment_header_id = X_Shipment_Header_Id)
           AND (Recinfo.receipt_source_code = X_Receipt_Source_Code)
           AND (   (Recinfo.vendor_id = X_Vendor_Id)
                OR (    (Recinfo.vendor_id IS NULL)
                    AND (X_Vendor_Id IS NULL)))
           AND (   (Recinfo.vendor_site_id = X_Vendor_Site_Id)
                OR (    (Recinfo.vendor_site_id IS NULL)
                    AND (X_Vendor_Site_Id IS NULL)))
           AND (   (Recinfo.organization_id = X_Organization_Id)
                OR (    (Recinfo.organization_id IS NULL)
                    AND (X_Organization_Id IS NULL)))
           AND (   (Recinfo.shipment_num = X_Shipment_Num)
                OR (    (Recinfo.shipment_num IS NULL)
                    AND (X_Shipment_Num IS NULL)))
           AND (   (Recinfo.receipt_num = X_Receipt_Num)
                OR (    (Recinfo.receipt_num IS NULL)
                    AND (X_Receipt_Num IS NULL)))
           AND (   (Recinfo.ship_to_location_id = X_Ship_To_Location_Id)
                OR (    (Recinfo.ship_to_location_id IS NULL)
                    AND (X_Ship_To_Location_Id IS NULL)))
           AND (   (Recinfo.bill_of_lading = X_Bill_Of_Lading)
                OR (    (Recinfo.bill_of_lading IS NULL)
                    AND (X_Bill_Of_Lading IS NULL)))
           AND (   (Recinfo.packing_slip = X_Packing_Slip)
                OR (    (Recinfo.packing_slip IS NULL)
                    AND (X_Packing_Slip IS NULL)))
           AND (   (Recinfo.shipped_date = X_Shipped_Date)
                OR (    (Recinfo.shipped_date IS NULL)
                    AND (X_Shipped_Date IS NULL)))
           AND (   (Recinfo.freight_carrier_code = X_Freight_Carrier_Code)
                OR (    (Recinfo.freight_carrier_code IS NULL)
                    AND (X_Freight_Carrier_Code IS NULL)))
           AND (   (Recinfo.expected_receipt_date = X_Expected_Receipt_Date)
                OR (    (Recinfo.expected_receipt_date IS NULL)
                    AND (X_Expected_Receipt_Date IS NULL)))
           AND (   (Recinfo.employee_id = X_Employee_Id)
                OR (    (Recinfo.employee_id IS NULL)
                    AND (X_Employee_Id IS NULL)))
           AND (   (Recinfo.num_of_containers = X_Num_Of_Containers)
                OR (    (Recinfo.num_of_containers IS NULL)
                    AND (X_Num_Of_Containers IS NULL)))
           AND (   (Recinfo.waybill_airbill_num = X_Waybill_Airbill_Num)
                OR (    (Recinfo.waybill_airbill_num IS NULL)
                    AND (X_Waybill_Airbill_Num IS NULL)))
           AND (   (Recinfo.comments = X_Comments)
                OR (    (Recinfo.comments IS NULL)
                    AND (X_Comments IS NULL)))
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
           AND (   (Recinfo.ussgl_transaction_code = X_Ussgl_Transaction_Code)
                OR (    (Recinfo.ussgl_transaction_code IS NULL)
                    AND (X_Ussgl_Transaction_Code IS NULL)))
           AND (   (Recinfo.government_context = X_Government_Context)
                OR (    (Recinfo.government_context IS NULL)
                    AND (X_Government_Context IS NULL)))
           AND (   (Recinfo.request_id = X_Request_Id)
                OR (    (Recinfo.request_id IS NULL)
                    AND (X_Request_Id IS NULL)))
           AND (   (Recinfo.program_application_id = X_Program_Application_Id)
                OR (    (Recinfo.program_application_id IS NULL)
                    AND (X_Program_Application_Id IS NULL)))
           AND (   (Recinfo.program_id = X_Program_Id)
                OR (    (Recinfo.program_id IS NULL)
                    AND (X_Program_Id IS NULL)))
           AND (   (Recinfo.program_update_date = X_Program_Update_Date)
                OR (    (Recinfo.program_update_date IS NULL)
                    AND (X_Program_Update_Date IS NULL)))
           AND (   (Recinfo.customer_id = X_Customer_Id)
                OR (    (Recinfo.customer_id IS NULL)
                    AND (X_Customer_Id IS NULL)))
           AND (   (Recinfo.customer_site_id = X_Customer_Site_Id)
                OR (    (Recinfo.customer_site_id IS NULL)
                    AND (X_Customer_Site_Id IS NULL)))
            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

    EXCEPTION
	WHEN OTHERS THEN
	RAISE;

  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Shipment_Header_Id             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Receipt_Source_Code            VARCHAR2,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Organization_Id                NUMBER,
		       X_ship_to_org_id			NUMBER,
                       X_Shipment_Num                   VARCHAR2,
                       X_Receipt_Num                    VARCHAR2,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Bill_Of_Lading                 VARCHAR2,
                       X_Packing_Slip                   VARCHAR2,
                       X_Shipped_Date                   DATE,
                       X_Freight_Carrier_Code           VARCHAR2,
                       X_Expected_Receipt_Date          DATE,
                       X_Employee_Id                    NUMBER,
                       X_Num_Of_Containers              NUMBER,
                       X_Waybill_Airbill_Num            VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
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
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
		       X_Request_Id			NUMBER,
		       X_Program_Application_Id		NUMBER,
		       X_Program_Id			NUMBER,
		       X_Program_Update_Date		DATE,
		       X_customer_id		        NUMBER,
		       X_customer_site_id		NUMBER

 ) IS

 BEGIN
   UPDATE RCV_SHIPMENT_HEADERS
   SET
     shipment_header_id                =     X_Shipment_Header_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     receipt_source_code               =     X_Receipt_Source_Code,
     vendor_id                         =     X_Vendor_Id,
     vendor_site_id                    =     X_Vendor_Site_Id,
     organization_id                   =     X_Organization_Id,
     ship_to_org_id		       =     X_Ship_to_org_id,
     shipment_num                      =     X_Shipment_Num,
     receipt_num                       =     X_Receipt_Num,
     ship_to_location_id               =     X_Ship_To_Location_Id,
     bill_of_lading                    =     X_Bill_Of_Lading,
     packing_slip                      =     X_Packing_Slip,
     shipped_date                      =     X_Shipped_Date,
     freight_carrier_code              =     X_Freight_Carrier_Code,
     expected_receipt_date             =     X_Expected_Receipt_Date,
     employee_id                       =     X_Employee_Id,
     num_of_containers                 =     X_Num_Of_Containers,
     waybill_airbill_num               =     X_Waybill_Airbill_Num,
     comments                          =     X_Comments,
     attribute_category                =     X_Attribute_Category,
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
     ussgl_transaction_code            =     X_Ussgl_Transaction_Code,
     government_context                =     X_Government_Context,
     request_id			       =     X_Request_Id,
     program_application_id            =     X_Program_Application_Id,
     program_id			       =     X_Program_Id,
     program_update_date               =     X_Program_Update_Date,
     customer_id                       =     X_Customer_Id,
     customer_site_id                  =     X_Customer_Site_Id
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    EXCEPTION
	WHEN OTHERS THEN
	RAISE;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS

  BEGIN

    DELETE FROM RCV_SHIPMENT_HEADERS
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  EXCEPTION
	WHEN OTHERS THEN
	RAISE;

  END Delete_Row;

END RCV_SHIPMENT_HEADERS_PKG;

/
