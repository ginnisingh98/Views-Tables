--------------------------------------------------------
--  DDL for Package Body PO_LINES_PKG_RFQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_PKG_RFQ" as
/* $Header: POXPIL3B.pls 120.1 2005/07/18 00:48:28 sjadhav noship $ */

  PROCEDURE Lock_Row_RFQ(X_Rowid                            VARCHAR2,
                     X_Po_Line_Id                       NUMBER,
                     X_Po_Header_Id                     NUMBER,
                     X_Line_Type_Id                     NUMBER,
                     X_Line_Num                         NUMBER,
                     X_Item_Id                          NUMBER,
                     X_Item_Revision                    VARCHAR2,
                     X_Category_Id                      NUMBER,
                     X_Item_Description                 VARCHAR2,
                     X_Unit_Meas_Lookup_Code            VARCHAR2,
                     X_Unit_Price                       NUMBER,
                     X_Quantity                         NUMBER,
                     X_Un_Number_Id                     NUMBER,
                     X_Hazard_Class_Id                  NUMBER,
                     X_Note_To_Vendor                   VARCHAR2,
                     X_From_Header_Id                   NUMBER,
                     X_From_Line_Id                     NUMBER,
                     X_Min_Order_Quantity               NUMBER,
                     X_Max_Order_Quantity               NUMBER,
                     X_Vendor_Product_Num               VARCHAR2,
                     X_Taxable_Flag                     VARCHAR2,
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
                     X_Attribute15                      VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PO_LINES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Po_Line_Id  NOWAIT;
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
               (Recinfo.po_line_id = X_Po_Line_Id)
           AND (Recinfo.po_header_id = X_Po_Header_Id)
           AND (Recinfo.line_type_id = X_Line_Type_Id)
           AND (Recinfo.line_num = X_Line_Num)
           AND (   (Recinfo.item_id = X_Item_Id)
                OR (    (Recinfo.item_id IS NULL)
                    AND (X_Item_Id IS NULL)))
           AND (   (Recinfo.item_revision = X_Item_Revision)
                OR (    (Recinfo.item_revision IS NULL)
                    AND (X_Item_Revision IS NULL)))
           AND (   (Recinfo.category_id = X_Category_Id)
                OR (    (Recinfo.category_id IS NULL)
                    AND (X_Category_Id IS NULL)))
           AND (   (Recinfo.item_description = X_Item_Description)
                OR (    (Recinfo.item_description IS NULL)
                    AND (X_Item_Description IS NULL)))
           AND (   (Recinfo.unit_meas_lookup_code = X_Unit_Meas_Lookup_Code)
                OR (    (Recinfo.unit_meas_lookup_code IS NULL)
                    AND (X_Unit_Meas_Lookup_Code IS NULL)))
           AND (   (Recinfo.unit_price = X_Unit_Price)
                OR (    (Recinfo.unit_price IS NULL)
                    AND (X_Unit_Price IS NULL)))
           AND (   (Recinfo.quantity = X_Quantity)
                OR (    (Recinfo.quantity IS NULL)
                    AND (X_Quantity IS NULL)))
           AND (   (Recinfo.un_number_id = X_Un_Number_Id)
                OR (    (Recinfo.un_number_id IS NULL)
                    AND (X_Un_Number_Id IS NULL)))
           AND (   (Recinfo.hazard_class_id = X_Hazard_Class_Id)
                OR (    (Recinfo.hazard_class_id IS NULL)
                    AND (X_Hazard_Class_Id IS NULL)))
           AND (   (Recinfo.note_to_vendor = X_Note_To_Vendor)
                OR (    (Recinfo.note_to_vendor IS NULL)
                    AND (X_Note_To_Vendor IS NULL)))
           AND (   (Recinfo.from_header_id = X_From_Header_Id)
                OR (    (Recinfo.from_header_id IS NULL)
                    AND (X_From_Header_Id IS NULL)))
           AND (   (Recinfo.from_line_id = X_From_Line_Id)
                OR (    (Recinfo.from_line_id IS NULL)
                    AND (X_From_Line_Id IS NULL)))
           AND (   (Recinfo.min_order_quantity = X_Min_Order_Quantity)
                OR (    (Recinfo.min_order_quantity IS NULL)
                    AND (X_Min_Order_Quantity IS NULL)))
           AND (   (Recinfo.max_order_quantity = X_Max_Order_Quantity)
                OR (    (Recinfo.max_order_quantity IS NULL)
                    AND (X_Max_Order_Quantity IS NULL)))
           AND (   (Recinfo.vendor_product_num = X_Vendor_Product_Num)
                OR (    (Recinfo.vendor_product_num IS NULL)
                    AND (X_Vendor_Product_Num IS NULL)))
        )  then

	   if  (
               (   (Recinfo.attribute_category = X_Attribute_Category)
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
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

  END Lock_Row_RFQ;

END PO_LINES_PKG_RFQ;

/
