--------------------------------------------------------
--  DDL for Package Body SO_ITEM_GROUP_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SO_ITEM_GROUP_LINES_PKG" as
/* $Header: OEXPREPB.pls 115.1 99/08/13 13:13:56 porting s $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Group_Line_Id                  IN OUT NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Group_Id                       NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_Unit_Code                      VARCHAR2,
                       X_Method_Code                    VARCHAR2,
                       X_Pricing_Rule_Id                NUMBER,
                       X_List_Price                     NUMBER,
                       X_Currency_Code                  VARCHAR2,
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
                       X_Pricing_Attribute15            VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM so_item_group_lines
                 WHERE group_line_id = X_Group_Line_Id;
      CURSOR C2 IS SELECT so_item_group_lines_s.nextval FROM sys.dual;
   BEGIN
      if (X_Group_Line_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Group_Line_Id;
        CLOSE C2;
      end if;

       INSERT INTO so_item_group_lines(
              group_line_id,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              group_id,
              inventory_item_id,
              unit_code,
              method_code,
              pricing_rule_id,
              list_price,
              currency_code,
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
              pricing_attribute15
             ) VALUES (
              X_Group_Line_Id,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Group_Id,
              X_Inventory_Item_Id,
              X_Unit_Code,
              X_Method_Code,
              X_Pricing_Rule_Id,
              X_List_Price,
              X_Currency_Code,
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
              X_Pricing_Attribute15
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
                     X_Group_Line_Id                    NUMBER,
                     X_Group_Id                         NUMBER,
                     X_Inventory_Item_Id                NUMBER,
                     X_Unit_Code                        VARCHAR2,
                     X_Method_Code                      VARCHAR2,
                     X_Pricing_Rule_Id                  NUMBER,
                     X_List_Price                       NUMBER,
                     X_Currency_Code                    VARCHAR2,
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
                     X_Pricing_Attribute15              VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   so_item_group_lines
        WHERE  rowid = X_Rowid
        FOR UPDATE of Group_Line_Id NOWAIT;
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
               (Recinfo.group_line_id =  X_Group_Line_Id)
           AND (Recinfo.group_id =  X_Group_Id)
           AND (Recinfo.inventory_item_id =  X_Inventory_Item_Id)
           AND (   (Recinfo.unit_code =  X_Unit_Code)
                OR (    (Recinfo.unit_code IS NULL)
                    AND (X_Unit_Code IS NULL)))
           AND (Recinfo.method_code =  X_Method_Code)
           AND (   (Recinfo.pricing_rule_id =  X_Pricing_Rule_Id)
                OR (    (Recinfo.pricing_rule_id IS NULL)
                    AND (X_Pricing_Rule_Id IS NULL)))
           AND (   (Recinfo.list_price =  X_List_Price)
                OR (    (Recinfo.list_price IS NULL)
                    AND (X_List_Price IS NULL)))
           AND (   (Recinfo.currency_code =  X_Currency_Code)
                OR (    (Recinfo.currency_code IS NULL)
                    AND (X_Currency_Code IS NULL)))
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
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Group_Line_Id                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Group_Id                       NUMBER,
                       X_Inventory_Item_Id              NUMBER,
                       X_Unit_Code                      VARCHAR2,
                       X_Method_Code                    VARCHAR2,
                       X_Pricing_Rule_Id                NUMBER,
                       X_List_Price                     NUMBER,
                       X_Currency_Code                  VARCHAR2,
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
                       X_Pricing_Attribute15            VARCHAR2
  ) IS
  BEGIN
    UPDATE so_item_group_lines
    SET
       group_line_id                   =     X_Group_Line_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       group_id                        =     X_Group_Id,
       inventory_item_id               =     X_Inventory_Item_Id,
       unit_code                       =     X_Unit_Code,
       method_code                     =     X_Method_Code,
       pricing_rule_id                 =     X_Pricing_Rule_Id,
       list_price                      =     X_List_Price,
       currency_code                   =     X_Currency_Code,
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
       pricing_attribute15             =     X_Pricing_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM so_item_group_lines
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END SO_ITEM_GROUP_LINES_PKG;

/
