--------------------------------------------------------
--  DDL for Package Body MTL_MFG_PART_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_MFG_PART_NUMBERS_PKG" as
/* $Header: INVIDMPB.pls 120.2.12010000.3 2009/06/17 08:02:59 xiaozhou ship $ */

  PROCEDURE Insert_Row(X_Rowid            IN OUT NOCOPY VARCHAR2,

                       X_Manufacturer_Id                NUMBER,
                       X_Mfg_Part_Num                   VARCHAR2,
                       X_Inventory_Item_Id              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Description                    VARCHAR2,
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
                       X_Attribute15                    VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM mtl_mfg_part_numbers
                 WHERE manufacturer_id = X_Manufacturer_Id
                 AND   mfg_part_num = X_Mfg_Part_Num
                 AND   inventory_item_id = X_Inventory_Item_Id;

   BEGIN


       INSERT INTO mtl_mfg_part_numbers(

              manufacturer_id,
              mfg_part_num,
              inventory_item_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              organization_id,
              description,
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

              X_Manufacturer_Id,
              X_Mfg_Part_Num,
              X_Inventory_Item_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Organization_Id,
              X_Description,
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
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

   /* R12: Business Event Enhancement:
   Raise Event if AML got Created successfully */
   BEGIN
      INV_ITEM_EVENTS_PVT.Raise_Events(
           p_event_name        => 'EGO_WF_WRAPPER_PVT.G_AML_CHANGE_EVENT'
          ,p_dml_type          => 'CREATE'
          ,p_inventory_item_id => X_Inventory_Item_Id
          ,p_organization_id   => X_Organization_Id
          ,p_mfg_part_num      => X_Mfg_Part_Num
          ,p_manufacturer_id   => X_Manufacturer_ID);
      EXCEPTION
          WHEN OTHERS THEN
             NULL;
   END;
/* Code Added for bug-6525662 starts here */
 BEGIN
 INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
           p_entity_type       => 'ITEM'
          ,p_dml_type          => 'UPDATE'
          ,p_inventory_item_id => X_Inventory_Item_Id
          ,p_item_description  => NULL
          ,p_organization_id   => X_Organization_Id
          ,p_master_org_flag   => NULL );

 EXCEPTION
 WHEN OTHERS THEN
 NULL;
 END;

/* Code Added for bug-6525662 Ends here */

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Manufacturer_Id                  NUMBER,
                     X_Mfg_Part_Num                     VARCHAR2,
                     X_Inventory_Item_Id                NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Description                      VARCHAR2,
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
        FROM   mtl_mfg_part_numbers
        WHERE  rowid = X_Rowid
        FOR UPDATE of Manufacturer_Id NOWAIT;
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
    if ( (Recinfo.manufacturer_id =  X_Manufacturer_Id)
           AND (Recinfo.mfg_part_num =  X_Mfg_Part_Num)
           AND (Recinfo.inventory_item_id =  X_Inventory_Item_Id)
           AND (   (Recinfo.organization_id =  X_Organization_Id)
                OR (    (Recinfo.organization_id IS NULL)
                    AND (X_Organization_Id IS NULL)))
       --     AND (   (Recinfo.mrp_planning_code =  X_Mrp_Planning_Code)
       --       OR (    (Recinfo.mrp_planning_code IS NULL)
       --           AND (X_Mrp_Planning_Code IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
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
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Manufacturer_Id                NUMBER,
                       X_Mfg_Part_Num                   VARCHAR2,
                       X_Inventory_Item_Id              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Description                    VARCHAR2,
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
                       X_Attribute15                    VARCHAR2

  ) IS
  BEGIN
    UPDATE mtl_mfg_part_numbers
    SET
       manufacturer_id                 =     X_Manufacturer_Id,
       mfg_part_num                    =     X_Mfg_Part_Num,
       inventory_item_id               =     X_Inventory_Item_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       organization_id                 =     X_Organization_Id,
       description                     =     X_Description,
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
       attribute15                     =     X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
   /* R12: Business Event Enhancement:
   Raise Event if AML got Updated successfully */
   BEGIN
      INV_ITEM_EVENTS_PVT.Raise_Events(
           p_event_name        => 'EGO_WF_WRAPPER_PVT.G_AML_CHANGE_EVENT'
          ,p_dml_type          => 'UPDATE'
          ,p_inventory_item_id => X_Inventory_Item_Id
          ,p_organization_id   => X_Organization_Id
          ,p_mfg_part_num      => X_Mfg_Part_Num
          ,p_manufacturer_id   => X_Manufacturer_ID);
      EXCEPTION
          WHEN OTHERS THEN
             NULL;
   END;

  /* Code Added for bug-6525662 starts here */
 BEGIN
 INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
           p_entity_type       => 'ITEM'
          ,p_dml_type          => 'UPDATE'
          ,p_inventory_item_id => X_Inventory_Item_Id
          ,p_item_description  => NULL
          ,p_organization_id   => X_Organization_Id
          ,p_master_org_flag   => NULL );

 EXCEPTION
 WHEN OTHERS THEN
 NULL;
 END;

/* Code Added for bug-6525662 Ends here */


  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  --R12 Business Events
  l_Inventory_Item_Id  mtl_mfg_part_numbers.INVENTORY_ITEM_ID%TYPE;
  l_Organization_Id    mtl_mfg_part_numbers.ORGANIZATION_ID%TYPE;
  l_Mfg_Part_Num       mtl_mfg_part_numbers.MFG_PART_NUM%TYPE;
  l_Manufacturer_ID    mtl_mfg_part_numbers.MANUFACTURER_ID%TYPE;

  BEGIN
  --R12 Fetch the parameter values to be passed to the event
    SELECT INVENTORY_ITEM_ID,
           ORGANIZATION_ID,
           MFG_PART_NUM,
           MANUFACTURER_ID
    INTO
           l_Inventory_Item_Id,
           l_Organization_Id,
           l_Mfg_Part_Num,
           l_Manufacturer_ID
    FROM   mtl_mfg_part_numbers
    WHERE  rowid = X_Rowid;


    DELETE FROM mtl_mfg_part_numbers
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

   /* R12: Business Event Enhancement:
   Raise Event if AML got deleted successfully */
   BEGIN
      INV_ITEM_EVENTS_PVT.Raise_Events(
           p_event_name        => 'EGO_WF_WRAPPER_PVT.G_AML_CHANGE_EVENT'
          ,p_dml_type          => 'DELETE'
          ,p_inventory_item_id => l_Inventory_Item_Id
          ,p_organization_id   => l_Organization_Id
          ,p_mfg_part_num      => l_Mfg_Part_Num
          ,p_manufacturer_id   => l_Manufacturer_ID);
      EXCEPTION
          WHEN OTHERS THEN
             NULL;
   END;

/* Code Added for bug-6525662 starts here */
 BEGIN

 INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
           p_entity_type       => 'ITEM'
          ,p_dml_type          => 'UPDATE'
          ,p_inventory_item_id => l_Inventory_Item_Id
          ,p_item_description  => NULL
          ,p_organization_id   => l_Organization_Id
          ,p_master_org_flag   => NULL );

 EXCEPTION
 WHEN OTHERS THEN

 NULL;

 END;

/* Code Added for bug-6525662 Ends here */


  END Delete_Row;

PROCEDURE  Call_Sync_Index  IS
  l_dynamic_sql VARCHAR2(200);

  BEGIN
        l_dynamic_sql :=
        ' BEGIN                                                       '||
        '   EGO_ITEM_TEXT_UTIL.Sync_Index();                     '||
        ' END;';
            EXECUTE IMMEDIATE l_dynamic_sql;
  EXCEPTION
    WHEN OTHERS THEN
     NULL;
 END Call_Sync_Index;

END MTL_MFG_PART_NUMBERS_PKG;

/
