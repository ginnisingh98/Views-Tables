--------------------------------------------------------
--  DDL for Package Body SO_PRICE_LIST_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SO_PRICE_LIST_LINES_PKG" as
/* $Header: OEXPRDPB.pls 115.2 99/08/13 13:13:51 porting s $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Price_List_Line_Id             IN OUT NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Price_List_Id                  NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_Unit_Code                      VARCHAR2,
                       X_Method_Code                    VARCHAR2,
                       X_List_Price                     NUMBER,
                       X_Pricing_Rule_Id                NUMBER,
                       X_Reprice_Flag                   VARCHAR2,
                       X_Pricing_Context                VARCHAR2,
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
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
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
                       X_Attribute15                    VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM so_price_list_lines
                 WHERE price_list_line_id = X_Price_List_Line_Id;
      CURSOR C2 IS SELECT so_price_list_lines_s.nextval FROM sys.dual;
   BEGIN
      if (X_Price_List_Line_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Price_List_Line_Id;
        CLOSE C2;
      end if;

       INSERT INTO so_price_list_lines(
              price_list_line_id,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              price_list_id,
              inventory_item_id,
              unit_code,
              method_code,
              list_price,
              pricing_rule_id,
              reprice_flag,
              pricing_context,
              pricing_attribute1,
              pricing_attribute2,
              pricing_attribute3,
              pricing_attribute4,
              pricing_attribute5,
              pricing_attribute6,
              pricing_attribute7,
              pricing_attribute8,
              pricing_attribute9,
              pricing_attribute10,
              pricing_attribute11,
              pricing_attribute12,
              pricing_attribute13,
              pricing_attribute14,
              pricing_attribute15,
              start_date_active,
              end_date_active,
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
              attribute15
             ) VALUES (
              X_Price_List_Line_Id,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Price_List_Id,
              X_Inventory_Item_Id,
              X_Unit_Code,
              X_Method_Code,
              X_List_Price,
              X_Pricing_Rule_Id,
              X_Reprice_Flag,
              X_Pricing_Context,
              X_Pricing_Attribute1,
              X_Pricing_Attribute2,
              X_Pricing_Attribute3,
              X_Pricing_Attribute4,
              X_Pricing_Attribute5,
              X_Pricing_Attribute6,
              X_Pricing_Attribute7,
              X_Pricing_Attribute8,
              X_Pricing_Attribute9,
              X_Pricing_Attribute10,
              X_Pricing_Attribute11,
              X_Pricing_Attribute12,
              X_Pricing_Attribute13,
              X_Pricing_Attribute14,
              X_Pricing_Attribute15,
              X_Start_Date_Active,
              X_End_Date_Active,
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
              X_Attribute15
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
                     X_Price_List_Line_Id               NUMBER,
                     X_Price_List_Id                    NUMBER,
                     X_Inventory_Item_Id                NUMBER,
                     X_Unit_Code                        VARCHAR2,
                     X_Method_Code                      VARCHAR2,
                     X_List_Price                       NUMBER,
                     X_Pricing_Rule_Id                  NUMBER,
                     X_Reprice_Flag                     VARCHAR2,
                     X_Pricing_Context                  VARCHAR2,
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
                     X_Start_Date_Active                DATE,
                     X_End_Date_Active                  DATE,
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
                     X_Attribute15                      VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   so_price_list_lines
        WHERE  rowid = X_Rowid
        FOR UPDATE of Price_List_Line_Id NOWAIT;
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
               (Recinfo.price_list_line_id =  X_Price_List_Line_Id)
           AND (Recinfo.price_list_id =  X_Price_List_Id)
           AND (Recinfo.inventory_item_id =  X_Inventory_Item_Id)
           AND (   (Recinfo.unit_code =  X_Unit_Code)
                OR (    (Recinfo.unit_code IS NULL)
                    AND (X_Unit_Code IS NULL)))
           AND (Recinfo.method_code =  X_Method_Code)
           AND (   (Recinfo.list_price =  X_List_Price)
                OR (    (Recinfo.list_price IS NULL)
                    AND (X_List_Price IS NULL)))
           AND (   (Recinfo.pricing_rule_id =  X_Pricing_Rule_Id)
                OR (    (Recinfo.pricing_rule_id IS NULL)
                    AND (X_Pricing_Rule_Id IS NULL)))
           AND (   (Recinfo.reprice_flag =  X_Reprice_Flag)
                OR (    (Recinfo.reprice_flag IS NULL)
                    AND (X_Reprice_Flag IS NULL)))
           AND (   (Recinfo.pricing_context =  X_Pricing_Context)
                OR (    (Recinfo.pricing_context IS NULL)
                    AND (X_Pricing_Context IS NULL)))
           AND (   (Recinfo.pricing_attribute1 =  X_Pricing_Attribute1)
                OR (    (Recinfo.pricing_attribute1 IS NULL)
                    AND (X_Pricing_Attribute1 IS NULL)))
           AND (   (Recinfo.pricing_attribute2 =  X_Pricing_Attribute2)
                OR (    (Recinfo.pricing_attribute2 IS NULL)
                    AND (X_Pricing_Attribute2 IS NULL)))
           AND (   (Recinfo.pricing_attribute3 =  X_Pricing_Attribute3)
                OR (    (Recinfo.pricing_attribute3 IS NULL)
                    AND (X_Pricing_Attribute3 IS NULL)))
           AND (   (Recinfo.pricing_attribute4 =  X_Pricing_Attribute4)
                OR (    (Recinfo.pricing_attribute4 IS NULL)
                    AND (X_Pricing_Attribute4 IS NULL)))
           AND (   (Recinfo.pricing_attribute5 =  X_Pricing_Attribute5)
                OR (    (Recinfo.pricing_attribute5 IS NULL)
                    AND (X_Pricing_Attribute5 IS NULL)))
           AND (   (Recinfo.pricing_attribute6 =  X_Pricing_Attribute6)
                OR (    (Recinfo.pricing_attribute6 IS NULL)
                    AND (X_Pricing_Attribute6 IS NULL)))
           AND (   (Recinfo.pricing_attribute7 =  X_Pricing_Attribute7)
                OR (    (Recinfo.pricing_attribute7 IS NULL)
                    AND (X_Pricing_Attribute7 IS NULL)))
           AND (   (Recinfo.pricing_attribute8 =  X_Pricing_Attribute8)
                OR (    (Recinfo.pricing_attribute8 IS NULL)
                    AND (X_Pricing_Attribute8 IS NULL)))
           AND (   (Recinfo.pricing_attribute9 =  X_Pricing_Attribute9)
                OR (    (Recinfo.pricing_attribute9 IS NULL)
                    AND (X_Pricing_Attribute9 IS NULL)))
           AND (   (Recinfo.pricing_attribute10 =  X_Pricing_Attribute10)
                OR (    (Recinfo.pricing_attribute10 IS NULL)
                    AND (X_Pricing_Attribute10 IS NULL)))
           AND (   (Recinfo.pricing_attribute11 =  X_Pricing_Attribute11)
                OR (    (Recinfo.pricing_attribute11 IS NULL)
                    AND (X_Pricing_Attribute11 IS NULL)))
           AND (   (Recinfo.pricing_attribute12 =  X_Pricing_Attribute12)
                OR (    (Recinfo.pricing_attribute12 IS NULL)
                    AND (X_Pricing_Attribute12 IS NULL)))
           AND (   (Recinfo.pricing_attribute13 =  X_Pricing_Attribute13)
                OR (    (Recinfo.pricing_attribute13 IS NULL)
                    AND (X_Pricing_Attribute13 IS NULL)))
           AND (   (Recinfo.pricing_attribute14 =  X_Pricing_Attribute14)
                OR (    (Recinfo.pricing_attribute14 IS NULL)
                    AND (X_Pricing_Attribute14 IS NULL)))
           AND (   (Recinfo.pricing_attribute15 =  X_Pricing_Attribute15)
                OR (    (Recinfo.pricing_attribute15 IS NULL)
                    AND (X_Pricing_Attribute15 IS NULL)))
           AND (   (Recinfo.start_date_active =  X_Start_Date_Active)
                OR (    (Recinfo.start_date_active IS NULL)
                    AND (X_Start_Date_Active IS NULL)))
           AND (   (Recinfo.end_date_active =  X_End_Date_Active)
                OR (    (Recinfo.end_date_active IS NULL)
                    AND (X_End_Date_Active IS NULL)))
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
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Price_List_Line_Id             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Price_List_Id                  NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_Unit_Code                      VARCHAR2,
                       X_Method_Code                    VARCHAR2,
                       X_List_Price                     NUMBER,
                       X_Pricing_Rule_Id                NUMBER,
                       X_Reprice_Flag                   VARCHAR2,
                       X_Pricing_Context                VARCHAR2,
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
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
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
                       X_Attribute15                    VARCHAR2
  ) IS
  BEGIN
    UPDATE so_price_list_lines
    SET
       price_list_line_id              =     X_Price_List_Line_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       price_list_id                   =     X_Price_List_Id,
       inventory_item_id               =     X_Inventory_Item_Id,
       unit_code                       =     X_Unit_Code,
       method_code                     =     X_Method_Code,
       list_price                      =     X_List_Price,
       pricing_rule_id                 =     X_Pricing_Rule_Id,
       reprice_flag                    =     X_Reprice_Flag,
       pricing_context                 =     X_Pricing_Context,
       pricing_attribute1              =     X_Pricing_Attribute1,
       pricing_attribute2              =     X_Pricing_Attribute2,
       pricing_attribute3              =     X_Pricing_Attribute3,
       pricing_attribute4              =     X_Pricing_Attribute4,
       pricing_attribute5              =     X_Pricing_Attribute5,
       pricing_attribute6              =     X_Pricing_Attribute6,
       pricing_attribute7              =     X_Pricing_Attribute7,
       pricing_attribute8              =     X_Pricing_Attribute8,
       pricing_attribute9              =     X_Pricing_Attribute9,
       pricing_attribute10             =     X_Pricing_Attribute10,
       pricing_attribute11             =     X_Pricing_Attribute11,
       pricing_attribute12             =     X_Pricing_Attribute12,
       pricing_attribute13             =     X_Pricing_Attribute13,
       pricing_attribute14             =     X_Pricing_Attribute14,
       pricing_attribute15             =     X_Pricing_Attribute15,
       start_date_active               =     X_Start_Date_Active,
       end_date_active                 =     X_End_Date_Active,
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
       attribute15                     =     X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM so_price_list_lines
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE Validate_Price_Line(
				   X_Inventory_Item_Id	NUMBER,
				   X_Unit_Code			VARCHAR2,
				   X_Price_List_Id		NUMBER,
				   X_Method_Code		VARCHAR2,
				   X_Pricing_Attribute1	VARCHAR2,
				   X_Pricing_Attribute2	VARCHAR2,
				   X_Pricing_Attribute3	VARCHAR2,
				   X_Pricing_Attribute4	VARCHAR2,
				   X_Pricing_Attribute5	VARCHAR2,
				   X_Pricing_Attribute6	VARCHAR2,
				   X_Pricing_Attribute7	VARCHAR2,
				   X_Pricing_Attribute8	VARCHAR2,
				   X_Pricing_Attribute9	VARCHAR2,
				   X_Pricing_Attribute10	VARCHAR2,
				   X_Pricing_Attribute11	VARCHAR2,
				   X_Pricing_Attribute12	VARCHAR2,
				   X_Pricing_Attribute13	VARCHAR2,
				   X_Pricing_Attribute14	VARCHAR2,
				   X_Pricing_Attribute15	VARCHAR2,
				   X_Message_Name	OUT	VARCHAR2) IS

  CURSOR C IS
    SELECT  'Y'
    FROM 	  so_headers sh, so_lines sl
    WHERE   sh.price_list_Id = X_Price_List_Id
    AND	  sh.header_id = sl.header_id
    AND     sl.inventory_Item_Id = X_Inventory_Item_Id
    AND 	  sl.unit_code = X_Unit_Code
    AND	  sl.pricing_method_code = X_Method_Code
    AND	  NVL(sl.s6, '-99') <> 10
    AND     NVL(sl.pricing_attribute1, ' ') = NVL(X_Pricing_Attribute1, ' ')
    AND     NVL(sl.pricing_attribute2, ' ') = NVL(X_Pricing_Attribute2, ' ')
    AND     NVL(sl.pricing_attribute3, ' ') = NVL(X_Pricing_Attribute3, ' ')
    AND     NVL(sl.pricing_attribute4, ' ') = NVL(X_Pricing_Attribute4, ' ')
    AND     NVL(sl.pricing_attribute5, ' ') = NVL(X_Pricing_Attribute5, ' ')
    AND     NVL(sl.pricing_attribute6, ' ') = NVL(X_Pricing_Attribute6, ' ')
    AND     NVL(sl.pricing_attribute7, ' ') = NVL(X_Pricing_Attribute7, ' ')
    AND     NVL(sl.pricing_attribute8, ' ') = NVL(X_Pricing_Attribute8, ' ')
    AND     NVL(sl.pricing_attribute9, ' ') = NVL(X_Pricing_Attribute9, ' ')
    AND     NVL(sl.pricing_attribute10, ' ') = NVL(X_Pricing_Attribute10, ' ')
    AND     NVL(sl.pricing_attribute11, ' ') = NVL(X_Pricing_Attribute11, ' ')
    AND     NVL(sl.pricing_attribute12, ' ') = NVL(X_Pricing_Attribute12, ' ')
    AND     NVL(sl.pricing_attribute13, ' ') = NVL(X_Pricing_Attribute13, ' ')
    AND     NVL(sl.pricing_attribute14, ' ') = NVL(X_Pricing_Attribute14, ' ')
    AND     NVL(sl.pricing_attribute15, ' ') = NVL(X_Pricing_Attribute15, ' ');


  l_exists	VARCHAR2(1);

  BEGIN

    X_Message_Name := NULL;
    OPEN C;
    FETCH C INTO l_exists;
    IF (C%FOUND) THEN
	 CLOSE C;
	 X_Message_Name := 'OE_CANNOT_DELETE_PRICE_LINE';
    ELSE
	 CLOSE C;
    END IF;

  END Validate_Price_Line;

END  SO_PRICE_LIST_LINES_PKG;

/
