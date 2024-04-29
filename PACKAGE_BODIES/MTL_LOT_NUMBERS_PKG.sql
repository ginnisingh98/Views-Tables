--------------------------------------------------------
--  DDL for Package Body MTL_LOT_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_LOT_NUMBERS_PKG" as
/* $Header: INVTDILB.pls 120.1.12010000.3 2008/11/04 08:48:49 ksivasa ship $ */


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Inventory_Item_Id                NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Lot_Number                       VARCHAR2,
                     X_Expiration_Date                  DATE,
                     X_Disable_Flag                     NUMBER,
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
	             X_Status_ID			NUMBER,
	             X_Description			VARCHAR2,
	             X_Vendor_Id			NUMBER,
	             X_Grade_Code			VARCHAR2,
	             X_Origination_Date			DATE,
	             X_Date_Code			VARCHAR2,
	             X_Change_Date			DATE,
	             X_Age				NUMBER,
	             X_Retest_Date			DATE,
	             X_Maturity_Date			DATE,
	             X_Lot_Attribute_Category		VARCHAR2,
		     X_Item_Size			NUMBER,
		     X_Color				VARCHAR2,
		     X_Volume				NUMBER,
		     X_Volume_UOM			VARCHAR2,
		     X_Place_of_Origin			VARCHAR2,
		     X_Best_by_Date                     DATE,
		     X_Length				NUMBER,
		     X_Length_UOM			VARCHAR2,
		     X_Recycled_Content			NUMBER,
		     X_Thickness			NUMBER,
		     X_Thickness_UOM			VARCHAR2,
		     X_Width				NUMBER,
		     X_Width_UOM			VARCHAR2,
		     X_Curl_Wrinkle_Fold		VARCHAR2,
		     X_C_Attribute1                     VARCHAR2,
                     X_C_Attribute2                     VARCHAR2,
                     X_C_Attribute3                     VARCHAR2,
                     X_C_Attribute4                     VARCHAR2,
                     X_C_Attribute5                     VARCHAR2,
                     X_C_Attribute6                     VARCHAR2,
                     X_C_Attribute7                     VARCHAR2,
                     X_C_Attribute8                     VARCHAR2,
                     X_C_Attribute9                     VARCHAR2,
                     X_C_Attribute10                    VARCHAR2,
                     X_C_Attribute11                    VARCHAR2,
                     X_C_Attribute12                    VARCHAR2,
                     X_C_Attribute13                    VARCHAR2,
                     X_C_Attribute14                    VARCHAR2,
                     X_C_Attribute15                    VARCHAR2,
                     X_C_Attribute16                    VARCHAR2,
                     X_C_Attribute17                    VARCHAR2,
                     X_C_Attribute18                    VARCHAR2,
                     X_C_Attribute19                    VARCHAR2,
                     X_C_Attribute20                    VARCHAR2,
                     X_D_Attribute1                     DATE,
                     X_D_Attribute2                     DATE,
                     X_D_Attribute3                     DATE,
                     X_D_Attribute4                     DATE,
                     X_D_Attribute5                     DATE,
                     X_D_Attribute6                     DATE,
                     X_D_Attribute7                     DATE,
                     X_D_Attribute8                     DATE,
                     X_D_Attribute9                     DATE,
                     X_D_Attribute10                    DATE,
                     X_N_Attribute1                     NUMBER,
                     X_N_Attribute2                     NUMBER,
                     X_N_Attribute3                     NUMBER,
                     X_N_Attribute4                     NUMBER,
                     X_N_Attribute5                     NUMBER,
                     X_N_Attribute6                     NUMBER,
                     X_N_Attribute7                     NUMBER,
                     X_N_Attribute8                     NUMBER,
                     X_N_Attribute10                    NUMBER,
                     X_Supplier_Lot_Number		VARCHAR2,
                     X_N_Attribute9                     NUMBER,
                     X_Territory_Code			VARCHAR2,
                     X_Parent_Lot_Number                VARCHAR2,
                     X_Origination_Type                 NUMBER,
                     X_Expiration_Action_Date           DATE,
                     X_Expiration_Action_Code           VARCHAR2,
                     X_Hold_Date                        DATE

  ) IS
    CURSOR C IS
        SELECT *
        FROM   mtl_lot_numbers
        WHERE  rowid = X_Rowid
        FOR UPDATE of Organization_Id NOWAIT;
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

               (Recinfo.inventory_item_id =  X_Inventory_Item_Id)
           AND (Recinfo.organization_id =  X_Organization_Id)
           AND (Recinfo.lot_number =  X_Lot_Number)
           AND (   (Recinfo.expiration_date =  X_Expiration_Date)
                OR (    (Recinfo.expiration_date IS NULL)
                    AND (X_Expiration_Date IS NULL)))
           AND (   (Recinfo.disable_flag =  X_Disable_Flag)
                OR (    (Recinfo.disable_flag IS NULL)
                    AND (X_Disable_Flag IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
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
           AND (   (Recinfo.status_id =  X_status_id)
                OR (    (Recinfo.status_id IS NULL)
                    AND (X_status_id IS NULL)))
           AND (   (Recinfo.Description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.Vendor_Id =  X_Vendor_id)
                OR (    (Recinfo.vendor_id IS NULL)
                    AND (X_vendor_id IS NULL)))
           AND (   (Recinfo.Grade_Code =  X_Grade_Code)
                OR (    (Recinfo.Grade_Code IS NULL)
                    AND (X_Grade_Code IS NULL)))
           AND (   (Recinfo.Origination_date =  X_Origination_date)
                OR (    (Recinfo.Origination_date IS NULL)
                    AND (X_Origination_date IS NULL)))
           AND (   (Recinfo.Date_Code =  X_Date_Code)
                OR (    (Recinfo.Date_Code IS NULL)
                    AND (X_Date_Code IS NULL)))
           AND (   (Recinfo.Change_Date =  X_Change_Date)
                OR (    (Recinfo.Change_Date IS NULL)
                    AND (X_Change_Date IS NULL)))
           AND (   (Recinfo.Age =  X_Age)
                OR (    (Recinfo.Age IS NULL)
                    AND (X_Age IS NULL)))
           AND (   (Recinfo.Retest_Date =  X_Retest_Date)
                OR (    (Recinfo.Retest_Date IS NULL)
                    AND (X_Retest_Date IS NULL)))
           AND (   (Recinfo.Maturity_Date =  X_Maturity_Date)
                OR (    (Recinfo.Maturity_Date IS NULL)
                    AND (X_Maturity_Date IS NULL)))
           AND (   (Recinfo.item_size =  X_item_size)
                OR (    (Recinfo.item_size IS NULL)
                    AND (X_item_size IS NULL)))
           AND (   (Recinfo.Color =  X_Color)
                OR (    (Recinfo.Color IS NULL)
                    AND (X_Color IS NULL)))
           AND (   (Recinfo.Volume =  X_Volume)
                OR (    (Recinfo.Volume IS NULL)
                    AND (X_Volume IS NULL)))
           AND (   (Recinfo.Volume_UOM =  X_Volume_UOM)
                OR (    (Recinfo.Volume_UOM IS NULL)
                    AND (X_Volume_UOM IS NULL)))
           AND (   (Recinfo.Place_of_origin =  X_Place_of_origin)
                OR (    (Recinfo.Place_of_origin IS NULL)
                    AND (X_Place_of_origin IS NULL)))
           AND (   (Recinfo.Best_by_Date =  X_Best_by_Date)
                OR (    (Recinfo.Best_by_Date IS NULL)
                    AND (X_Best_by_Date IS NULL)))
           AND (   (Recinfo.Length =  X_Length)
                OR (    (Recinfo.Length IS NULL)
                    AND (X_Length IS NULL)))
           AND (   (Recinfo.Length_UOM =  X_Length_UOM)
                OR (    (Recinfo.Length_UOM IS NULL)
                    AND (X_Length_UOM IS NULL)))
           AND (   (Recinfo.Recycled_content =  X_Recycled_content)
                OR (    (Recinfo.Recycled_content IS NULL)
                    AND (X_Recycled_content IS NULL)))
           AND (   (Recinfo.Thickness =  X_Thickness)
                OR (    (Recinfo.Thickness IS NULL)
                    AND (X_Thickness IS NULL)))
           AND (   (Recinfo.Thickness_UOM =  X_Thickness_UOM)
                OR (    (Recinfo.Thickness_UOM IS NULL)
                    AND (X_Thickness_UOM IS NULL)))
           AND (   (Recinfo.Width =  X_Width)
                OR (    (Recinfo.Width IS NULL)
                    AND (X_Width IS NULL)))
           AND (   (Recinfo.Width_UOM =  X_Width_UOM)
                OR (    (Recinfo.Width_UOM IS NULL)
                    AND (X_Width_UOM IS NULL)))
           AND (   (Recinfo.Curl_Wrinkle_Fold =  X_Curl_Wrinkle_Fold)
                OR (    (Recinfo.Curl_Wrinkle_Fold IS NULL)
                    AND (X_Curl_Wrinkle_Fold IS NULL)))
	   AND (   (Recinfo.lot_attribute_category =  X_lot_Attribute_Category)
                OR (    (Recinfo.lot_attribute_category IS NULL)
                    AND (X_lot_Attribute_Category IS NULL)))
           AND (   (Recinfo.c_attribute1 =  X_C_Attribute1)
                OR (    (Recinfo.c_attribute1 IS NULL)
                    AND (X_C_Attribute1 IS NULL)))
           AND (   (Recinfo.c_attribute2 =  X_C_Attribute2)
                OR (    (Recinfo.c_attribute2 IS NULL)
                    AND (X_C_Attribute2 IS NULL)))
           AND (   (Recinfo.c_attribute3 =  X_C_Attribute3)
                OR (    (Recinfo.c_attribute3 IS NULL)
                    AND (X_C_Attribute3 IS NULL)))
           AND (   (Recinfo.c_attribute4 =  X_C_Attribute4)
                OR (    (Recinfo.c_attribute4 IS NULL)
                    AND (X_C_Attribute4 IS NULL)))
           AND (   (Recinfo.c_attribute5 =  X_C_Attribute5)
                OR (    (Recinfo.c_attribute5 IS NULL)
                    AND (X_C_Attribute5 IS NULL)))
           AND (   (Recinfo.c_attribute6 =  X_C_Attribute6)
                OR (    (Recinfo.c_attribute6 IS NULL)
                    AND (X_C_Attribute6 IS NULL)))
           AND (   (Recinfo.c_attribute7 =  X_C_Attribute7)
                OR (    (Recinfo.c_attribute7 IS NULL)
                    AND (X_C_Attribute7 IS NULL)))
           AND (   (Recinfo.c_attribute8 =  X_C_Attribute8)
                OR (    (Recinfo.c_attribute8 IS NULL)
                    AND (X_C_Attribute8 IS NULL)))
           AND (   (Recinfo.c_attribute9 =  X_C_Attribute9)
                OR (    (Recinfo.c_attribute9 IS NULL)
                    AND (X_C_Attribute9 IS NULL)))
           AND (   (Recinfo.c_attribute10 =  X_C_Attribute10)
                OR (    (Recinfo.c_attribute10 IS NULL)
                    AND (X_C_Attribute10 IS NULL)))
           AND (   (Recinfo.c_attribute11 =  X_C_Attribute11)
                OR (    (Recinfo.c_attribute11 IS NULL)
                    AND (X_C_Attribute11 IS NULL)))
           AND (   (Recinfo.c_attribute12 =  X_C_Attribute12)
                OR (    (Recinfo.c_attribute12 IS NULL)
                    AND (X_C_Attribute12 IS NULL)))
           AND (   (Recinfo.c_attribute13 =  X_C_Attribute13)
                OR (    (Recinfo.c_attribute13 IS NULL)
                    AND (X_C_Attribute13 IS NULL)))
           AND (   (Recinfo.c_attribute14 =  X_C_Attribute14)
                OR (    (Recinfo.c_attribute14 IS NULL)
                    AND (X_C_Attribute14 IS NULL)))
           AND (   (Recinfo.c_attribute15 =  X_C_Attribute15)
                OR (    (Recinfo.c_attribute15 IS NULL)
                    AND (X_C_Attribute15 IS NULL)))
           AND (   (Recinfo.c_attribute16 =  X_C_Attribute16)
                OR (    (Recinfo.c_attribute16 IS NULL)
                    AND (X_C_Attribute16 IS NULL)))
           AND (   (Recinfo.c_attribute17 =  X_C_Attribute17)
                OR (    (Recinfo.c_attribute17 IS NULL)
                    AND (X_C_Attribute17 IS NULL)))
           AND (   (Recinfo.c_attribute18 =  X_C_Attribute18)
                OR (    (Recinfo.c_attribute18 IS NULL)
                    AND (X_C_Attribute18 IS NULL)))
           AND (   (Recinfo.c_attribute19 =  X_C_Attribute19)
                OR (    (Recinfo.c_attribute19 IS NULL)
                    AND (X_C_Attribute19 IS NULL)))
           AND (   (Recinfo.c_attribute20 =  X_C_Attribute20)
                OR (    (Recinfo.c_attribute20 IS NULL)
                    AND (X_C_Attribute20 IS NULL)))
           AND (   (Recinfo.d_attribute1 =  X_D_Attribute1)
                OR (    (Recinfo.d_attribute1 IS NULL)
                    AND (X_D_Attribute1 IS NULL)))
           AND (   (Recinfo.d_attribute2 =  X_D_Attribute2)
                OR (    (Recinfo.d_attribute2 IS NULL)
                    AND (X_D_Attribute2 IS NULL)))
           AND (   (Recinfo.d_attribute3 =  X_D_Attribute3)
                OR (    (Recinfo.d_attribute3 IS NULL)
                    AND (X_D_Attribute3 IS NULL)))
           AND (   (Recinfo.d_attribute4 =  X_D_Attribute4)
                OR (    (Recinfo.d_attribute4 IS NULL)
                    AND (X_D_Attribute4 IS NULL)))
           AND (   (Recinfo.d_attribute5 =  X_D_Attribute5)
                OR (    (Recinfo.d_attribute5 IS NULL)
                    AND (X_D_Attribute5 IS NULL)))
           AND (   (Recinfo.d_attribute6 =  X_D_Attribute6)
                OR (    (Recinfo.d_attribute6 IS NULL)
                    AND (X_D_Attribute6 IS NULL)))
           AND (   (Recinfo.d_attribute7 =  X_D_Attribute7)
                OR (    (Recinfo.d_attribute7 IS NULL)
                    AND (X_D_Attribute7 IS NULL)))
           AND (   (Recinfo.d_attribute8 =  X_D_Attribute8)
                OR (    (Recinfo.d_attribute8 IS NULL)
                    AND (X_D_Attribute8 IS NULL)))
           AND (   (Recinfo.d_attribute9 =  X_D_Attribute9)
                OR (    (Recinfo.d_attribute9 IS NULL)
                    AND (X_D_Attribute9 IS NULL)))
           AND (   (Recinfo.d_attribute10 =  X_D_Attribute10)
                OR (    (Recinfo.d_attribute10 IS NULL)
                    AND (X_D_Attribute10 IS NULL)))                                        AND (   (Recinfo.n_attribute1 =  X_N_Attribute1)
                OR (    (Recinfo.n_attribute1 IS NULL)
                    AND (X_N_Attribute1 IS NULL)))
           AND (   (Recinfo.n_attribute2 =  X_N_Attribute2)
                OR (    (Recinfo.n_attribute2 IS NULL)
                    AND (X_N_Attribute2 IS NULL)))
           AND (   (Recinfo.n_attribute3 =  X_N_Attribute3)
                OR (    (Recinfo.n_attribute3 IS NULL)
                    AND (X_N_Attribute3 IS NULL)))
           AND (   (Recinfo.n_attribute4 =  X_N_Attribute4)
                OR (    (Recinfo.n_attribute4 IS NULL)
                    AND (X_N_Attribute4 IS NULL)))
           AND (   (Recinfo.n_attribute5 =  X_N_Attribute5)
                OR (    (Recinfo.n_attribute5 IS NULL)
                    AND (X_N_Attribute5 IS NULL)))
           AND (   (Recinfo.n_attribute6 =  X_N_Attribute6)
                OR (    (Recinfo.n_attribute6 IS NULL)
                    AND (X_N_Attribute6 IS NULL)))
           AND (   (Recinfo.n_attribute7 =  X_N_Attribute7)
                OR (    (Recinfo.n_attribute7 IS NULL)
                    AND (X_N_Attribute7 IS NULL)))
           AND (   (Recinfo.n_attribute8 =  X_N_Attribute8)
                OR (    (Recinfo.n_attribute8 IS NULL)
                    AND (X_N_Attribute8 IS NULL)))
           AND (   (Recinfo.n_attribute9 =  X_N_Attribute9)
                OR (    (Recinfo.n_attribute9 IS NULL)
                    AND (X_N_Attribute9 IS NULL)))
           AND (   (Recinfo.n_attribute10 =  X_N_Attribute10)
                OR (    (Recinfo.n_attribute10 IS NULL)
                    AND (X_N_Attribute10 IS NULL)))
           AND (   (Recinfo.parent_lot_number =  X_Parent_Lot_Number)
                OR (    (Recinfo.parent_lot_number IS NULL)
                    AND (X_Parent_Lot_Number IS NULL)))
           AND (   (Recinfo.origination_type =  X_Origination_Type)
                OR (    (Recinfo.origination_type IS NULL)
                    AND (X_Origination_Type IS NULL)))
           AND (   (Recinfo.expiration_action_date =  X_Expiration_Action_Date)
                OR (    (Recinfo.expiration_action_date IS NULL)
                    AND (X_Expiration_Action_Date IS NULL)))
           AND (   (Recinfo.expiration_action_code =  X_Expiration_Action_Code)
                OR (    (Recinfo.expiration_action_code IS NULL)
                    AND (X_Expiration_Action_Code IS NULL)))
           AND (   (Recinfo.hold_date =  X_Hold_Date)
                OR (    (Recinfo.hold_date IS NULL)
                    AND (X_Hold_Date IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  /*========================================
     SFeinstein    Convergence
     Added Sampling_Event_ID to MTL_LOT_NUMBERS table
    ========================================*/
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Inventory_Item_Id              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Lot_Number                     VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Expiration_Date                DATE,
                       X_Disable_Flag                   NUMBER,
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
		       X_Status_ID			NUMBER,
		       X_Description			VARCHAR2,
		       X_Vendor_Id			NUMBER,
		       X_Grade_Code			VARCHAR2,
		       X_Origination_Date		DATE,
  		       X_Date_Code			VARCHAR2,
		       X_Change_Date			DATE,
		       X_Age				NUMBER,
		       X_Retest_Date			DATE,
		       X_Maturity_Date			DATE,
		       X_Lot_Attribute_Category		VARCHAR2,
		       X_Item_Size			NUMBER,
		       X_Color				VARCHAR2,
		       X_Volume				NUMBER,
		       X_Volume_UOM			VARCHAR2,
		       X_Place_of_Origin		VARCHAR2,
		       X_Best_by_Date                   DATE,
		       X_Length				NUMBER,
		       X_Length_UOM			VARCHAR2,
		       X_Recycled_Content		NUMBER,
		       X_Thickness			NUMBER,
		       X_Thickness_UOM			VARCHAR2,
		       X_Width				NUMBER,
		       X_Width_UOM			VARCHAR2,
		       X_Curl_Wrinkle_Fold		VARCHAR2,
		       X_C_Attribute1                   VARCHAR2,
                       X_C_Attribute2                   VARCHAR2,
                       X_C_Attribute3                   VARCHAR2,
                       X_C_Attribute4                   VARCHAR2,
                       X_C_Attribute5                   VARCHAR2,
                       X_C_Attribute6                   VARCHAR2,
                       X_C_Attribute7                   VARCHAR2,
                       X_C_Attribute8                   VARCHAR2,
                       X_C_Attribute9                   VARCHAR2,
                       X_C_Attribute10                  VARCHAR2,
                       X_C_Attribute11                  VARCHAR2,
                       X_C_Attribute12                  VARCHAR2,
                       X_C_Attribute13                  VARCHAR2,
                       X_C_Attribute14                  VARCHAR2,
                       X_C_Attribute15                  VARCHAR2,
                       X_C_Attribute16                  VARCHAR2,
                       X_C_Attribute17                  VARCHAR2,
                       X_C_Attribute18                  VARCHAR2,
                       X_C_Attribute19                  VARCHAR2,
                       X_C_Attribute20                  VARCHAR2,
		       X_D_Attribute1                   DATE,
                       X_D_Attribute2                   DATE,
                       X_D_Attribute3                   DATE,
                       X_D_Attribute4                   DATE,
                       X_D_Attribute5                   DATE,
                       X_D_Attribute6                   DATE,
                       X_D_Attribute7                   DATE,
                       X_D_Attribute8                   DATE,
                       X_D_Attribute9                   DATE,
                       X_D_Attribute10                  DATE,
		       X_N_Attribute1                   NUMBER,
                       X_N_Attribute2                   NUMBER,
                       X_N_Attribute3                   NUMBER,
                       X_N_Attribute4                   NUMBER,
                       X_N_Attribute5                   NUMBER,
                       X_N_Attribute6                   NUMBER,
                       X_N_Attribute7                   NUMBER,
                       X_N_Attribute8                   NUMBER,
                       X_N_Attribute10                  NUMBER,
                       X_Supplier_Lot_Number		VARCHAR2,
                       X_N_Attribute9                   NUMBER,
		       X_Territory_Code			VARCHAR2,
                       X_Parent_Lot_Number              VARCHAR2,
                       X_Origination_Type               NUMBER,
                       X_Expiration_Action_Date         DATE,
                       X_Expiration_Action_Code         VARCHAR2,
                       X_Hold_Date                      DATE,
		       X_Sampling_Event_ID		NUMBER DEFAULT NULL

  ) IS
  l_status_id	NUMBER;
  /*========================================
     Joe DiIorio - Convergence
     Added l_grade_code and variables
     to support call to update grade history.
    ========================================*/
  l_grade_code         MTL_LOT_NUMBERS.GRADE_CODE%TYPE;
  l_status             VARCHAR2(2);
  l_message            VARCHAR2(2000);
  /* Jalaj Srivastava Bug 4998256
     added varaibles below for call to quantity tree */

  l_qoh   number;
  l_rqoh  number;
  l_qr    number;
  l_qs    number;
  l_att   number;
  l_atr   number;
  l_sqoh  number;
  l_srqoh number;
  l_sqr   number;
  l_sqs   number;
  l_satt  number;
  l_satr  number;
  l_return_status varchar2(1);
  l_msg_count     pls_integer;
  l_msg_data      varchar2(4000);


  BEGIN

    /* WMS  Material Status Enhancements
       To maintain the Material Status History obtain the Status ID before
       the record get updated with modified values. */

   SELECT  status_id, grade_code
   INTO    l_status_id, l_grade_code
   FROM    mtl_lot_numbers
   WHERE   rowid = X_Rowid;

  /*===================================
     Joe DiIorio - Convergence
     Get existing grade code to compare
     later if it has changed.
    ===================================
     S Feinstein - removed new select code
     and incorporated it in select above
    ===================================
   SELECT  grade_code
   INTO    l_grade_code
   FROM    mtl_lot_numbers
   WHERE   rowid = X_Rowid;
    ===================================*/


  /*========================================
     SFeinstein    Convergence
     Added Sampling_Event_ID to columns updated
    ========================================*/
    UPDATE mtl_lot_numbers
    SET
       inventory_item_id               =     X_Inventory_Item_Id,
       organization_id                 =     X_Organization_Id,
       lot_number                      =     X_Lot_Number,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       expiration_date                 =     X_Expiration_Date,
       disable_flag                    =     X_Disable_Flag,
       attribute_category              =     X_Attribute_Category,
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
       status_id		       =     X_Status_ID,
       description                     =     X_Description,
       vendor_id                       =     X_Vendor_Id,
       grade_code                      =     X_Grade_Code,
       origination_date                =     X_Origination_Date,
       date_code                       =     X_Date_Code,
       change_date		       =     X_Change_date,
       age			       =     X_Age,
       retest_date		       =     X_Retest_Date,
       maturity_date		       =     X_Maturity_Date,
       lot_attribute_category	       =     X_Lot_Attribute_Category,
       item_size		       =     X_Item_Size,
       color	 		       =     X_Color,
       volume			       =     X_volume,
       volume_uom		       =     X_Volume_UOM,
       place_of_origin		       =     X_Place_Of_Origin,
       best_by_date		       =     X_Best_BY_Date,
       length			       =     X_Length,
       length_uom		       =     X_Length_UOM,
       recycled_content		       =     X_Recycled_Content,
       thickness		       =     X_Thickness,
       thickness_uom		       =     X_Thickness_UOM,
       width			       =     X_Width,
       width_uom		       =     X_Width_UOM,
       curl_wrinkle_fold	       =     X_Curl_Wrinkle_Fold,
       c_attribute1                    =     X_C_Attribute1,
       c_attribute2                    =     X_C_Attribute2,
       c_attribute3                    =     X_C_Attribute3,
       c_attribute4                    =     X_C_Attribute4,
       c_attribute5                    =     X_C_Attribute5,
       c_attribute6                    =     X_C_Attribute6,
       c_attribute7                    =     X_C_Attribute7,
       c_attribute8                    =     X_C_Attribute8,
       c_attribute9                    =     X_C_Attribute9,
       c_attribute10                   =     X_C_Attribute10,
       c_attribute11                   =     X_C_Attribute11,
       c_attribute12                   =     X_C_Attribute12,
       c_attribute13                   =     X_C_Attribute13,
       c_attribute14                   =     X_C_Attribute14,
       c_attribute15                   =     X_C_Attribute15,
       c_attribute16                   =     X_C_Attribute16,
       c_attribute17                   =     X_C_Attribute17,
       c_attribute18                   =     X_C_Attribute18,
       c_attribute19                   =     X_C_Attribute19,
       c_attribute20                   =     X_C_Attribute20,
       d_attribute1                    =     X_D_Attribute1,
       d_attribute2                    =     X_D_Attribute2,
       d_attribute3                    =     X_D_Attribute3,
       d_attribute4                    =     X_D_Attribute4,
       d_attribute5                    =     X_D_Attribute5,
       d_attribute6                    =     X_D_Attribute6,
       d_attribute7                    =     X_D_Attribute7,
       d_attribute8                    =     X_D_Attribute8,
       d_attribute9                    =     X_D_Attribute9,
       d_attribute10                   =     X_D_Attribute10,
       n_attribute1                    =     X_N_Attribute1,
       n_attribute2                    =     X_N_Attribute2,
       n_attribute3                    =     X_N_Attribute3,
       n_attribute4                    =     X_N_Attribute4,
       n_attribute5                    =     X_N_Attribute5,
       n_attribute6                    =     X_N_Attribute6,
       n_attribute7                    =     X_N_Attribute7,
       n_attribute8                    =     X_N_Attribute8,
       n_attribute10                   =     X_N_Attribute10,
       supplier_lot_number	       =     X_Supplier_Lot_Number,
       n_attribute9                    =     X_N_Attribute9,
       territory_code		       =     X_Territory_code,
       parent_lot_number               =     X_Parent_Lot_Number,
       origination_type                =     X_Origination_Type,
       expiration_action_date          =     X_Expiration_Action_Date,
       expiration_action_code          =     X_Expiration_Action_Code,
       hold_date                       =     X_Hold_Date,
       Sampling_Event_ID               =     X_Sampling_Event_ID
    WHERE rowid = X_Rowid;

    /* WMS Enhancements
       This Procedure Caters to the insertion of records in the
       table MTL_MATERIAL_STATUS_HISTORY. */

        --BUG 7258237 For updating status wms install is not required
        IF --(INV_INSTALL.ADV_INV_INSTALLED(P_Organization_ID => NULL)) AND
           (X_Status_ID IS NOT NULL) AND
           (X_Status_ID <> l_status_id) THEN
                MTL_SECONDARY_INVENTORIES_PKG.Status_History
			      ( X_Organization_ID,
                                X_Inventory_Item_ID,
                                X_Lot_Number,
                                NULL,
                                2,
                                X_Status_ID,
                                NULL,
                                NULL,
                                X_Last_Update_Date,
                                X_Last_Updated_By,
                                X_Last_Updated_By,
                                X_Last_Update_Date,
                                X_Last_Update_Login);
        END IF;


  /*===================================
     Joe DiIorio - Convergence
     Added l_grade_code
    ===================================*/
   IF (INV_INSTALL.ADV_INV_INSTALLED(P_Organization_ID => NULL)) AND
           (X_Grade_Code IS NOT NULL) AND
           (X_Grade_Code <> l_grade_code) THEN
               /* Jalaj Srivastava Bug 4998256
                  Get primary and seconday onhand */

                inv_quantity_tree_pub.query_quantities
                (p_api_version_number              => 1.0
                ,x_return_status                   => l_return_status
                ,x_msg_count                       => l_msg_count
                ,x_msg_data                        => l_msg_data
                ,p_organization_id                 => X_organization_id
                ,p_inventory_item_id               => X_inventory_item_id
                ,p_tree_mode                       => inv_quantity_tree_pub.g_transaction_mode
                ,p_is_revision_control             => false
                ,p_is_lot_control                  => true
                ,p_is_serial_control               => false
                ,p_grade_code                      => null
                ,p_revision                        => null
                ,p_lot_number                      => X_lot_number
                ,p_subinventory_code               => null
                ,p_locator_id                      => null
                ,x_qoh                             => l_qoh
                ,x_rqoh                            => l_rqoh
                ,x_qr                              => l_qr
                ,x_qs                              => l_qs
                ,x_att                             => l_att
                ,x_atr                             => l_atr
                ,x_sqoh                            => l_sqoh
                ,x_srqoh                           => l_srqoh
                ,x_sqr                             => l_sqr
                ,x_sqs                             => l_sqs
                ,x_satt                            => l_satt
                ,x_satr                            => l_satr
               );


       /*========================
          Upgrade Grade History
         ========================*/
       INSERT INTO MTL_LOT_GRADE_HISTORY
        (
         GRADE_UPDATE_ID,
         INVENTORY_ITEM_ID,
         ORGANIZATION_ID,
         LOT_NUMBER,
         UPDATE_METHOD,
         NEW_GRADE_CODE,
         OLD_GRADE_CODE,
         PRIMARY_QUANTITY,
         SECONDARY_QUANTITY,
         UPDATE_REASON_ID,
         INITIAL_GRADE_FLAG,
         FROM_MOBILE_APPS_FLAG,
         GRADE_UPDATE_DATE,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         ATTRIBUTE_CATEGORY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN
        )
       VALUES
        (
         MTL_LOT_GRADE_HISTORY_S.NEXTVAL,
         X_INVENTORY_ITEM_ID,
         X_ORGANIZATION_ID,
         X_LOT_NUMBER,
         INV_MATERIAL_STATUS_PUB.g_update_method_manual,/* Jalaj Srivastava Bug 4998256 pass update_method as manual instead of null */
         X_GRADE_CODE,
         l_grade_code,
         l_qoh, /* Jalaj Srivastava Bug 4998256 pass primary onhand */
         l_sqoh, /* Jalaj Srivastava Bug 4998256 pass secondary onhand */
         NULL,
         'N',
         'N',
         SYSDATE,
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
         SYSDATE,
         FND_GLOBAL.USER_ID,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.LOGIN_ID
        );
   END IF;


  END Update_Row;







  PROCEDURE Insert_Row(X_Inventory_Item_Id              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Lot_Number                     VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Request_Id                    NUMBER,
                       X_Program_Application_Id        NUMBER,
                       X_Program_Id                    NUMBER,
                       X_Program_Update_Date           DATE,
                       X_Expiration_Date                DATE,
                       X_Disable_Flag                   NUMBER,
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
		       X_Status_ID			NUMBER,
		       X_Description			VARCHAR2,
		       X_Vendor_Id			NUMBER,
		       X_Grade_Code			VARCHAR2,
		       X_Origination_Date		DATE,
		       X_Date_Code			VARCHAR2,
		       X_Change_Date			DATE,
		       X_Age				NUMBER,
		       X_Retest_Date			DATE,
		       X_Maturity_Date			DATE,
		       X_Lot_Attribute_Category		VARCHAR2,
		       X_Item_Size			NUMBER,
		       X_Color				VARCHAR2,
		       X_Volume				NUMBER,
		       X_Volume_UOM			VARCHAR2,
		       X_Place_of_Origin		VARCHAR2,
		       X_Best_by_Date                   DATE,
		       X_Length				NUMBER,
		       X_Length_UOM			VARCHAR2,
		       X_Recycled_Content		NUMBER,
		       X_Thickness			NUMBER,
		       X_Thickness_UOM			VARCHAR2,
		       X_Width				NUMBER,
		       X_Width_UOM			VARCHAR2,
		       X_Curl_Wrinkle_Fold		VARCHAR2,
		       X_C_Attribute1                   VARCHAR2,
                       X_C_Attribute2                   VARCHAR2,
                       X_C_Attribute3                   VARCHAR2,
                       X_C_Attribute4                   VARCHAR2,
                       X_C_Attribute5                   VARCHAR2,
                       X_C_Attribute6                   VARCHAR2,
                       X_C_Attribute7                   VARCHAR2,
                       X_C_Attribute8                   VARCHAR2,
                       X_C_Attribute9                   VARCHAR2,
                       X_C_Attribute10                  VARCHAR2,
                       X_C_Attribute11                  VARCHAR2,
                       X_C_Attribute12                  VARCHAR2,
                       X_C_Attribute13                  VARCHAR2,
                       X_C_Attribute14                  VARCHAR2,
                       X_C_Attribute15                  VARCHAR2,
                       X_C_Attribute16                  VARCHAR2,
                       X_C_Attribute17                  VARCHAR2,
                       X_C_Attribute18                  VARCHAR2,
                       X_C_Attribute19                  VARCHAR2,
                       X_C_Attribute20                  VARCHAR2,
		       X_D_Attribute1                   DATE,
                       X_D_Attribute2                   DATE,
                       X_D_Attribute3                   DATE,
                       X_D_Attribute4                   DATE,
                       X_D_Attribute5                   DATE,
                       X_D_Attribute6                   DATE,
                       X_D_Attribute7                   DATE,
                       X_D_Attribute8                   DATE,
                       X_D_Attribute9                   DATE,
                       X_D_Attribute10                  DATE,
		       X_N_Attribute1                   NUMBER,
                       X_N_Attribute2                   NUMBER,
                       X_N_Attribute3                   NUMBER,
                       X_N_Attribute4                   NUMBER,
                       X_N_Attribute5                   NUMBER,
                       X_N_Attribute6                   NUMBER,
                       X_N_Attribute7                   NUMBER,
                       X_N_Attribute8                   NUMBER,
                       X_N_Attribute9                   NUMBER,
                       X_N_Attribute10                  NUMBER,
                       X_Supplier_Lot_Number		VARCHAR2,
		       X_Territory_Code			VARCHAR2,
                       X_Parent_Lot_Number                VARCHAR2,
                       X_Origination_Type                 NUMBER,
                       X_Expiration_Action_Date           DATE,
                       X_Expiration_Action_Code           VARCHAR2,
                       X_Hold_Date                        DATE ,
                       X_SAMPLING_EVENT_ID                NUMBER  DEFAULT NULL
                      )
IS

BEGIN

INSERT INTO MTL_LOT_NUMBERS (
  Inventory_Item_Id,
  Organization_Id,
  Lot_Number,
  Creation_Date,
  Created_By,
  Last_Update_Date,
  Last_Updated_By,
  Last_Update_Login,
  Request_Id,
  Program_Application_Id,
  Program_Id,
  Program_Update_Date,
  Expiration_Date,
  Disable_Flag,
  Attribute_Category,
  Attribute1, Attribute2, Attribute3, Attribute4,
  Attribute5, Attribute6, Attribute7, Attribute8,
  Attribute9, Attribute10, Attribute11, Attribute12,
  Attribute13, Attribute14, Attribute15,
  Status_ID,
  Description,
  Vendor_Id,
  Grade_Code,
  Origination_Date,
  Date_Code,
  Change_Date,
  Age,
  Retest_Date,
  Maturity_Date,
  Lot_Attribute_Category,
  Item_Size,
  Color,
  Volume,
  Volume_UOM,
  Place_of_Origin,
  Best_by_Date,
  Length,
  Length_UOM,
  Recycled_Content,
  Thickness,
  Thickness_UOM,
  Width,
  Width_UOM,
  Curl_Wrinkle_Fold,
  C_Attribute1, C_Attribute2, C_Attribute3, C_Attribute4,
  C_Attribute5, C_Attribute6, C_Attribute7, C_Attribute8,
  C_Attribute9, C_Attribute10, C_Attribute11, C_Attribute12,
  C_Attribute13, C_Attribute14, C_Attribute15, C_Attribute16,
  C_Attribute17, C_Attribute18, C_Attribute19, C_Attribute20,
  D_Attribute1, D_Attribute2, D_Attribute3, D_Attribute4,
  D_Attribute5, D_Attribute6, D_Attribute7, D_Attribute8,
  D_Attribute9, D_Attribute10,
  N_Attribute1, N_Attribute2, N_Attribute3, N_Attribute4,
  N_Attribute5, N_Attribute6, N_Attribute7, N_Attribute8,
  N_Attribute9, N_Attribute10,
  Supplier_Lot_Number,
  Territory_Code,
  Parent_Lot_Number,
  Origination_Type,
  Expiration_Action_Date,
  Expiration_Action_Code,
  Hold_Date
  ,gen_object_id          -- NSRIVAST, INVCONV
  ,sampling_event_id      -- Bug 4115021 OPM Inventory Convergence
)
VALUES
  (X_Inventory_Item_Id,
   X_Organization_Id,
   X_Lot_Number,
   X_Creation_Date,
   X_Created_By,
   X_Last_Update_Date,
   X_Last_Updated_By,
   X_Last_Update_Login,
   X_Request_Id,
   X_Program_Application_Id,
   X_Program_Id,
   X_Program_Update_Date,
   X_Expiration_Date,
   X_Disable_Flag,
   X_Attribute_Category,
   X_Attribute1, X_Attribute2, X_Attribute3, X_Attribute4,
   X_Attribute5, X_Attribute6, X_Attribute7, X_Attribute8,
   X_Attribute9, X_Attribute10, X_Attribute11, X_Attribute12,
   X_Attribute13, X_Attribute14, X_Attribute15,
   X_Status_ID,
   X_Description,
   X_Vendor_Id,
   X_Grade_Code,
   X_Origination_Date,
   X_Date_Code,
   X_Change_Date,
   X_Age,
   X_Retest_Date,
   X_Maturity_Date,
   X_Lot_Attribute_Category,
   X_Item_Size,
   X_Color,
   X_Volume,
   X_Volume_UOM,
   X_Place_of_Origin,
   X_Best_by_Date,
   X_Length,
   X_Length_UOM,
   X_Recycled_Content,
   X_Thickness,
   X_Thickness_UOM,
   X_Width,
   X_Width_UOM,
   X_Curl_Wrinkle_Fold,
   X_C_Attribute1, X_C_Attribute2, X_C_Attribute3, X_C_Attribute4,
   X_C_Attribute5, X_C_Attribute6, X_C_Attribute7, X_C_Attribute8,
   X_C_Attribute9, X_C_Attribute10, X_C_Attribute11, X_C_Attribute12,
   X_C_Attribute13, X_C_Attribute14, X_C_Attribute15, X_C_Attribute16,
   X_C_Attribute17, X_C_Attribute18, X_C_Attribute19, X_C_Attribute20,
   X_D_Attribute1, X_D_Attribute2, X_D_Attribute3, X_D_Attribute4,
   X_D_Attribute5, X_D_Attribute6, X_D_Attribute7, X_D_Attribute8,
   X_D_Attribute9, X_D_Attribute10,
   X_N_Attribute1, X_N_Attribute2, X_N_Attribute3, X_N_Attribute4,
   X_N_Attribute5, X_N_Attribute6, X_N_Attribute7, X_N_Attribute8,
   X_N_Attribute9, X_N_Attribute10,
   X_Supplier_Lot_Number,
   X_Territory_Code,
   X_Parent_Lot_Number,
   X_Origination_Type,
   X_Expiration_Action_Date,
   X_Expiration_Action_Code,
   X_Hold_Date
   ,mtl_gen_object_id_s.NEXTVAL    -- NSRIVAST, INVCONV
   ,x_sampling_event_id
);


    /* WMS Enhancements
       This Procedure Caters to the insertion of records in the
       table MTL_MATERIAL_STATUS_HISTORY. */
      --  Bug 7502482 WMS installation is not required For Inserting Lot History.
        IF --(INV_INSTALL.ADV_INV_INSTALLED(P_Organization_ID => NULL)) AND
           (X_Status_ID IS NOT NULL) THEN

       /*=================================================
         BUG#4222397 = Changed to pass Y for value of
         initial_status_flag and named the parameters.
         =================================================*/
                MTL_SECONDARY_INVENTORIES_PKG.Status_History
    (x_organization_id => X_Organization_ID
  , x_inventory_item_id => X_Inventory_Item_ID
  , x_lot_number  => X_Lot_Number
  , x_serial_number => NULL
  , x_update_method => 2
  , x_status_id => X_Status_ID
  , x_zone_code => NULL
  , x_locator_id => NULL
  , x_creation_date => X_Last_Update_Date
  , x_created_by => X_Last_Updated_By
  , x_last_updated_by => X_Last_Updated_By
  , x_last_update_date => X_Last_Update_Date
  , x_last_update_login => X_Last_Update_Login
  , x_initial_status_flag => 'Y');
        END IF;



END Insert_Row;

END MTL_LOT_NUMBERS_PKG;

/
