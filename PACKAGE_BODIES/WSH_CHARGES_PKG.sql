--------------------------------------------------------
--  DDL for Package Body WSH_CHARGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CHARGES_PKG" as
/* $Header: WSHSCRGB.pls 115.0 99/07/16 08:20:53 porting ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Freight_Charge_Id       IN OUT NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Freight_Charge_Type_Id         NUMBER,
                       X_Picking_Header_Id              NUMBER,
                       X_Amount                         NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Conversion_Date                DATE,
                       X_Conversion_Rate                NUMBER,
                       X_Conversion_Type_Code           VARCHAR2,
                       X_Invoice_Status                 VARCHAR2,
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
		       X_Delivery_Id			NUMBER	 DEFAULT NULL,
		       X_Picking_Line_Detail_Id		NUMBER   DEFAULT NULL,
		       X_Container_Id			NUMBER   DEFAULT NULL,
		       X_AC_Attribute_Category		VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute1                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute2                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute3                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute4                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute5                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute6                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute7                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute8                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute9                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute10                 VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute11                 VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute12                 VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute13                 VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute14                 VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute15                 VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS SELECT rowid FROM SO_FREIGHT_CHARGES
                 WHERE freight_charge_id = X_Freight_Charge_Id;
    CURSOR NEXTID IS SELECT so_freight_charges_s.nextval FROM sys.dual;
   BEGIN

       IF (X_Freight_Charge_Id is NULL) THEN
         OPEN NEXTID;
         FETCH NEXTID INTO X_Freight_Charge_Id;
         CLOSE NEXTID;
       END IF;

       INSERT INTO SO_FREIGHT_CHARGES(

              freight_charge_id,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              freight_charge_type_id,
              picking_header_id,
              amount,
              currency_code,
              conversion_date,
              conversion_rate,
              conversion_type_code,
              invoice_status,
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
              delivery_id,
              picking_line_detail_id,
              container_id,
              ac_attribute_category,
              ac_attribute1,
              ac_attribute2,
              ac_attribute3,
              ac_attribute4,
              ac_attribute5,
              ac_attribute6,
              ac_attribute7,
              ac_attribute8,
              ac_attribute9,
              ac_attribute10,
              ac_attribute11,
              ac_attribute12,
              ac_attribute13,
              ac_attribute14,
              ac_attribute15
             ) VALUES (

              X_Freight_Charge_Id,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Freight_Charge_Type_Id,
              X_Picking_Header_Id,
              X_Amount,
              X_Currency_Code,
              X_Conversion_Date,
              X_Conversion_Rate,
              X_Conversion_Type_Code,
              X_Invoice_Status,
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
	      X_Delivery_Id,
	      X_Picking_Line_Detail_Id,
	      X_Container_Id,
	      X_AC_Attribute_Category,
              X_AC_Attribute1,
              X_AC_Attribute2,
              X_AC_Attribute3,
              X_AC_Attribute4,
              X_AC_Attribute5,
              X_AC_Attribute6,
              X_AC_Attribute7,
              X_AC_Attribute8,
              X_AC_Attribute9,
              X_AC_Attribute10,
              X_AC_Attribute11,
              X_AC_Attribute12,
              X_AC_Attribute13,
              X_AC_Attribute14,
              X_AC_Attribute15

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

                     X_Freight_Charge_Id                NUMBER,
                     X_Freight_Charge_Type_Id           NUMBER,
                     X_Picking_Header_Id                NUMBER,
                     X_Amount                           NUMBER,
                     X_Currency_Code                    VARCHAR2,
                     X_Conversion_Date                  DATE,
                     X_Conversion_Rate                  NUMBER,
                     X_Conversion_Type_Code             VARCHAR2,
                     X_Invoice_Status                   VARCHAR2,
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
		     X_Delivery_Id			NUMBER	 DEFAULT NULL,
		     X_Picking_Line_Detail_Id		NUMBER   DEFAULT NULL,
		     X_Container_Id			NUMBER   DEFAULT NULL,
		     X_AC_Attribute_Category		VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute1                    VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute2                    VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute3                    VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute4                    VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute5                    VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute6                    VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute7                    VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute8                    VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute9                    VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute10                   VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute11                   VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute12                   VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute13                   VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute14                   VARCHAR2 DEFAULT NULL,
                     X_AC_Attribute15                   VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS
        SELECT *
        FROM   SO_FREIGHT_CHARGES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Freight_Charge_Id NOWAIT;
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

               (Recinfo.freight_charge_id =  X_Freight_Charge_Id)
           AND (Recinfo.freight_charge_type_id =  X_Freight_Charge_Type_Id)
           AND (   (Recinfo.picking_header_id =  X_Picking_Header_Id)
                OR (    (Recinfo.picking_header_id IS NULL)
                    AND (X_Picking_Header_Id IS NULL)))
           AND (   (Recinfo.amount =  X_Amount)
                OR (    (Recinfo.amount IS NULL)
                    AND (X_Amount IS NULL)))
           AND (   (Recinfo.currency_code =  X_Currency_Code)
                OR (    (Recinfo.currency_code IS NULL)
                    AND (X_Currency_Code IS NULL)))
           AND (   (Recinfo.conversion_date =  X_Conversion_Date)
                OR (    (Recinfo.conversion_date IS NULL)
                    AND (X_Conversion_Date IS NULL)))
           AND (   (Recinfo.conversion_rate =  X_Conversion_Rate)
                OR (    (Recinfo.conversion_rate IS NULL)
                    AND (X_Conversion_Rate IS NULL)))
           AND (   (Recinfo.conversion_type_code =  X_Conversion_Type_Code)
                OR (    (Recinfo.conversion_type_code IS NULL)
                    AND (X_Conversion_Type_Code IS NULL)))
           AND (   (Recinfo.invoice_status =  X_Invoice_Status)
                OR (    (Recinfo.invoice_status IS NULL)
                    AND (X_Invoice_Status IS NULL)))
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
           AND (   (Recinfo.delivery_id =  X_Delivery_Id)
                OR (    (Recinfo.delivery_id IS NULL)
                    AND (X_Delivery_Id IS NULL)))
           AND (   (Recinfo.picking_line_detail_id =  X_Picking_Line_Detail_Id)
                OR (    (Recinfo.picking_line_detail_id IS NULL)
                    AND (X_Picking_Line_Detail_Id IS NULL)))
           AND (   (Recinfo.container_id =  X_Container_Id)
                OR (    (Recinfo.container_Id IS NULL)
                    AND (X_Container_Id IS NULL)))
           AND (   (Recinfo.ac_attribute_category =  X_AC_Attribute_Category)
                OR (    (Recinfo.ac_attribute_category IS NULL)
                    AND (X_AC_Attribute_Category IS NULL)))
           AND (   (Recinfo.ac_attribute1 =  X_AC_Attribute1)
                OR (    (Recinfo.ac_attribute1 IS NULL)
                    AND (X_AC_Attribute1 IS NULL)))
           AND (   (Recinfo.ac_attribute2 =  X_AC_Attribute2)
                OR (    (Recinfo.ac_attribute2 IS NULL)
                    AND (X_AC_Attribute2 IS NULL)))
           AND (   (Recinfo.ac_attribute3 =  X_AC_Attribute3)
                OR (    (Recinfo.ac_attribute3 IS NULL)
                    AND (X_AC_Attribute3 IS NULL)))
           AND (   (Recinfo.ac_attribute4 =  X_AC_Attribute4)
                OR (    (Recinfo.ac_attribute4 IS NULL)
                    AND (X_AC_Attribute4 IS NULL)))
           AND (   (Recinfo.ac_attribute5 =  X_AC_Attribute5)
                OR (    (Recinfo.ac_attribute5 IS NULL)
                    AND (X_AC_Attribute5 IS NULL)))
           AND (   (Recinfo.ac_attribute6 =  X_AC_Attribute6)
                OR (    (Recinfo.ac_attribute6 IS NULL)
                    AND (X_AC_Attribute6 IS NULL)))
           AND (   (Recinfo.ac_attribute7 =  X_AC_Attribute7)
                OR (    (Recinfo.ac_attribute7 IS NULL)
                    AND (X_AC_Attribute7 IS NULL)))
           AND (   (Recinfo.ac_attribute8 =  X_AC_Attribute8)
                OR (    (Recinfo.ac_attribute8 IS NULL)
                    AND (X_AC_Attribute8 IS NULL)))
           AND (   (Recinfo.ac_attribute9 =  X_AC_Attribute9)
                OR (    (Recinfo.ac_attribute9 IS NULL)
                    AND (X_AC_Attribute9 IS NULL)))
           AND (   (Recinfo.ac_attribute10 =  X_AC_Attribute10)
                OR (    (Recinfo.ac_attribute10 IS NULL)
                    AND (X_AC_Attribute10 IS NULL)))
           AND (   (Recinfo.ac_attribute11 =  X_AC_Attribute11)
                OR (    (Recinfo.ac_attribute11 IS NULL)
                    AND (X_AC_Attribute11 IS NULL)))
           AND (   (Recinfo.ac_attribute12 =  X_AC_Attribute12)
                OR (    (Recinfo.ac_attribute12 IS NULL)
                    AND (X_AC_Attribute12 IS NULL)))
           AND (   (Recinfo.ac_attribute13 =  X_AC_Attribute13)
                OR (    (Recinfo.ac_attribute13 IS NULL)
                    AND (X_AC_Attribute13 IS NULL)))
           AND (   (Recinfo.ac_attribute14 =  X_AC_Attribute14)
                OR (    (Recinfo.ac_attribute14 IS NULL)
                    AND (X_AC_Attribute14 IS NULL)))
           AND (   (Recinfo.ac_attribute15 =  X_AC_Attribute15)
                OR (    (Recinfo.ac_attribute15 IS NULL)
                    AND (X_AC_Attribute15 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Freight_Charge_Id              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Freight_Charge_Type_Id         NUMBER,
                       X_Picking_Header_Id              NUMBER,
                       X_Amount                         NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Conversion_Date                DATE,
                       X_Conversion_Rate                NUMBER,
                       X_Conversion_Type_Code           VARCHAR2,
                       X_Invoice_Status                 VARCHAR2,
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
		       X_Delivery_Id                 	NUMBER	 DEFAULT NULL,
		       X_Picking_Line_Detail_Id      	NUMBER   DEFAULT NULL,
		       X_Container_Id                	NUMBER   DEFAULT NULL,
		       X_AC_Attribute_Category       	VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute1                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute2                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute3                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute4                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute5                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute6                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute7                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute8                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute9                  VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute10                 VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute11                 VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute12                 VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute13                 VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute14                 VARCHAR2 DEFAULT NULL,
                       X_AC_Attribute15                 VARCHAR2 DEFAULT NULL

  ) IS
  BEGIN
    UPDATE SO_FREIGHT_CHARGES
    SET
       freight_charge_id               =     X_Freight_Charge_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       freight_charge_type_id          =     X_Freight_Charge_Type_Id,
       picking_header_id               =     X_Picking_Header_Id,
       amount                          =     X_Amount,
       currency_code                   =     X_Currency_Code,
       conversion_date                 =     X_Conversion_Date,
       conversion_rate                 =     X_Conversion_Rate,
       conversion_type_code            =     X_Conversion_Type_Code,
       invoice_status                  =     X_Invoice_Status,
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
       delivery_id                     =     X_Delivery_Id,
       picking_line_detail_id          =     X_Picking_Line_Detail_Id,
       container_id                    =     X_Container_Id,
       ac_attribute_category           =     X_AC_Attribute_Category,
       ac_attribute1                   =     X_AC_Attribute1,
       ac_attribute2                   =     X_AC_Attribute2,
       ac_attribute3                   =     X_AC_Attribute3,
       ac_attribute4                   =     X_AC_Attribute4,
       ac_attribute5                   =     X_AC_Attribute5,
       ac_attribute6                   =     X_AC_Attribute6,
       ac_attribute7                   =     X_AC_Attribute7,
       ac_attribute8                   =     X_AC_Attribute8,
       ac_attribute9                   =     X_AC_Attribute9,
       ac_attribute10                  =     X_AC_Attribute10,
       ac_attribute11                  =     X_AC_Attribute11,
       ac_attribute12                  =     X_AC_Attribute12,
       ac_attribute13                  =     X_AC_Attribute13,
       ac_attribute14                  =     X_AC_Attribute14,
       ac_attribute15                  =     X_AC_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM SO_FREIGHT_CHARGES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END WSH_CHARGES_PKG;

/
