--------------------------------------------------------
--  DDL for Package Body WSH_PACKED_CONTAINERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PACKED_CONTAINERS_PKG" as
/* $Header: WSHPCKHB.pls 115.1 99/07/16 08:19:23 porting s $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Container_Id                   IN OUT NUMBER,
                       X_Delivery_Id                    NUMBER,
                       X_Container_Inventory_Item_Id    NUMBER,
                       X_Master_Container_Id            NUMBER,
                       X_Parent_Container_Id            NUMBER,
                       X_Quantity                       NUMBER,
                       X_Sequence_Number                NUMBER,
                       X_Parent_Sequence_Number         NUMBER,
                       X_Gross_Weight                   NUMBER,
                       X_Weight_Uom_Code                VARCHAR2,
                       X_Volume_Uom_Code                VARCHAR2,
                       X_Volume                         NUMBER,
                       X_Fill_Percent                   NUMBER,
                       X_Net_Weight                     NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Subinventory                   VARCHAR2,
                       X_Inventory_Location_Id          NUMBER,
                       X_Revision                       VARCHAR2,
                       X_Lot_Number                     VARCHAR2,
                       X_Serial_Number                  VARCHAR2,
                       X_Master_Serial_Number           VARCHAR2,
                       X_Inventory_Status               VARCHAR2,
                       X_Ra_Interface_Status            VARCHAR2,
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
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM wsh_packed_containers
                 WHERE container_id = X_Container_Id;
      CURSOR C2 IS SELECT wsh_packed_containers_s.nextval FROM sys.dual;
   BEGIN
      IF (X_Container_Id IS NULL) THEN
        OPEN C2;
        FETCH C2 INTO X_Container_Id;
        CLOSE C2;
      END IF;

       INSERT INTO wsh_packed_containers(

              container_id,
              delivery_id,
              container_inventory_item_id,
              master_container_id,
              parent_container_id,
              quantity,
              sequence_number,
              parent_sequence_number,
              gross_weight,
              weight_uom_code,
              volume_uom_code,
              volume,
              fill_percent,
              net_weight,
              organization_id,
              subinventory,
              inventory_location_id,
              revision,
              lot_number,
              serial_number,
              master_serial_number,
              inventory_status,
              ra_interface_status,
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
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login
             ) VALUES (
              X_Container_Id,
              X_Delivery_Id,
              X_Container_Inventory_Item_Id,
              X_Master_Container_Id,
              X_Parent_Container_Id,
              X_Quantity,
              X_Sequence_Number,
              X_Parent_Sequence_Number,
              X_Gross_Weight,
              X_Weight_Uom_Code,
              X_Volume_Uom_Code,
              X_Volume,
              X_Fill_Percent,
              X_Net_Weight,
              X_Organization_Id,
              X_Subinventory,
              X_Inventory_Location_Id,
              X_Revision,
              X_Lot_Number,
              X_Serial_Number,
              X_Master_Serial_Number,
              X_Inventory_Status,
              X_Ra_Interface_Status,
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
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Container_Id                     NUMBER,
                     X_Delivery_Id                      NUMBER,
                     X_Container_Inventory_Item_Id      NUMBER,
                     X_Master_Container_Id              NUMBER,
                     X_Parent_Container_Id              NUMBER,
                     X_Quantity                         NUMBER,
                     X_Sequence_Number                  NUMBER,
                     X_Parent_Sequence_Number           NUMBER,
                     X_Gross_Weight                     NUMBER,
                     X_Weight_Uom_Code                  VARCHAR2,
                     X_Volume_Uom_Code                  VARCHAR2,
                     X_Volume                           NUMBER,
                     X_Fill_Percent                     NUMBER,
                     X_Net_Weight                       NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Subinventory                     VARCHAR2,
                     X_Inventory_Location_Id            NUMBER,
                     X_Revision                         VARCHAR2,
                     X_Lot_Number                       VARCHAR2,
                     X_Serial_Number                    VARCHAR2,
                     X_Master_Serial_Number             VARCHAR2,
                     X_Inventory_Status                 VARCHAR2,
                     X_Ra_Interface_Status              VARCHAR2,
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
        FROM   wsh_packed_containers
        WHERE  rowid = X_Rowid
        FOR UPDATE of Container_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;
    IF (

               (Recinfo.container_id =  X_Container_Id)
           AND (Recinfo.delivery_id =  X_Delivery_Id)
           AND (Recinfo.container_inventory_item_id = X_Container_Inventory_Item_Id)
           AND (Recinfo.quantity =  X_Quantity)
           AND (   (Recinfo.sequence_number =  X_Sequence_Number)
                OR (    (Recinfo.sequence_number IS NULL)
                    AND (X_Sequence_Number IS NULL)))
           AND (   (Recinfo.parent_sequence_number =  X_Parent_Sequence_Number)
                OR (    (Recinfo.parent_sequence_number IS NULL)
                    AND (X_Parent_Sequence_Number IS NULL)))
           AND (   (Recinfo.gross_weight =  X_Gross_Weight)
                OR (    (Recinfo.gross_weight IS NULL)
                    AND (X_Gross_Weight IS NULL)))
           AND (   (Recinfo.volume =  X_Volume)
                OR (    (Recinfo.volume IS NULL)
                    AND (X_Volume IS NULL)))
           AND (   (Recinfo.fill_percent =  X_Fill_Percent)
                OR (    (Recinfo.fill_percent IS NULL)
                    AND (X_Fill_Percent IS NULL)))
           AND (   (Recinfo.net_weight =  X_Net_Weight)
                OR (    (Recinfo.net_weight IS NULL)
                    AND (X_Net_Weight IS NULL)))
           AND (   (Recinfo.weight_uom_code =  X_Weight_Uom_Code)
                OR (    (Recinfo.weight_uom_code IS NULL)
                    AND (X_Weight_Uom_Code IS NULL)))
           AND (   (Recinfo.volume_uom_code =  X_Volume_Uom_Code)
                OR (    (Recinfo.volume_uom_code IS NULL)
                    AND (X_Volume_Uom_Code IS NULL)))
           AND (   (Recinfo.organization_id =  X_Organization_Id)
                OR (    (Recinfo.organization_id IS NULL)
                    AND (X_Organization_Id IS NULL)))
           AND (   (Recinfo.subinventory =  X_Subinventory)
                OR (    (Recinfo.subinventory IS NULL)
                    AND (X_Subinventory IS NULL)))
           AND (   (Recinfo.inventory_location_id =  X_Inventory_Location_Id)
                OR (    (Recinfo.inventory_location_id IS NULL)
                    AND (X_Inventory_Location_Id IS NULL)))
           AND (   (Recinfo.revision =  X_Revision)
                OR (    (Recinfo.revision IS NULL)
                    AND (X_Revision IS NULL)))
           AND (   (Recinfo.lot_number =  X_Lot_Number)
                OR (    (Recinfo.lot_number IS NULL)
                    AND (X_Lot_Number IS NULL)))
           AND (   (Recinfo.serial_number =  X_Serial_Number)
                OR (    (Recinfo.serial_number IS NULL)
                    AND (X_Serial_Number IS NULL)))
           AND (   (Recinfo.master_serial_number =  X_Master_Serial_Number)
                OR (    (Recinfo.master_serial_number IS NULL)
                    AND (X_Master_Serial_Number IS NULL)))
           AND (   (Recinfo.inventory_status =  X_Inventory_Status)
                OR (    (Recinfo.inventory_status IS NULL)
                    AND (X_Inventory_Status IS NULL)))
           AND (   (Recinfo.ra_interface_status =  X_Ra_Interface_Status)
                OR (    (Recinfo.ra_interface_status IS NULL)
                    AND (X_Ra_Interface_Status IS NULL)))
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
           AND (   (Recinfo.master_container_id =  X_Master_Container_Id)
                OR (    (Recinfo.master_container_id IS NULL)
                    AND (X_Master_Container_Id IS NULL)))
           AND (   (Recinfo.parent_container_id =  X_Parent_Container_Id)
                OR (    (Recinfo.parent_container_id IS NULL)
                    AND (X_Parent_Container_Id IS NULL)))
      ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Container_Id                   NUMBER,
                       X_Delivery_Id                    NUMBER,
                       X_Container_Inventory_Item_Id    NUMBER,
                       X_Master_Container_Id            NUMBER,
                       X_Parent_Container_Id            NUMBER,
                       X_Quantity                       NUMBER,
                       X_Sequence_Number                NUMBER,
                       X_Parent_Sequence_Number         NUMBER,
                       X_Gross_Weight                   NUMBER,
                       X_Weight_Uom_Code                VARCHAR2,
                       X_Volume_Uom_Code                VARCHAR2,
                       X_Volume                         NUMBER,
                       X_Fill_Percent                   NUMBER,
                       X_Net_Weight                     NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Subinventory                   VARCHAR2,
                       X_Inventory_Location_Id          NUMBER,
                       X_Revision                       VARCHAR2,
                       X_Lot_Number                     VARCHAR2,
                       X_Serial_Number                  VARCHAR2,
                       X_Master_Serial_Number           VARCHAR2,
                       X_Inventory_Status               VARCHAR2,
                       X_Ra_Interface_Status            VARCHAR2,
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
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
  BEGIN
    UPDATE wsh_packed_containers
    SET
       container_id                    =     X_Container_Id,
       delivery_id                     =     X_Delivery_Id,
       container_inventory_item_id     =     X_Container_Inventory_Item_Id,
       master_container_id             =     X_Master_Container_Id,
       parent_container_id             =     X_Parent_Container_Id,
       quantity                        =     X_Quantity,
       sequence_number                 =     X_Sequence_Number,
       parent_sequence_number          =     X_Parent_Sequence_Number,
       gross_weight                    =     X_Gross_Weight,
       weight_uom_code                 =     X_Weight_Uom_Code,
       volume_uom_code                 =     X_Volume_Uom_Code,
       volume                          =     X_Volume,
       fill_percent                    =     X_Fill_Percent,
       net_weight                      =     X_Net_Weight,
       organization_id                 =     X_Organization_Id,
       subinventory                    =     X_Subinventory,
       inventory_location_id           =     X_Inventory_Location_Id,
       revision                        =     X_Revision,
       lot_number                      =     X_Lot_Number,
       serial_number                   =     X_Serial_Number,
       master_serial_number            =     X_Master_Serial_Number,
       inventory_status                =     X_Inventory_Status,
       ra_interface_status             =     X_Ra_Interface_Status,
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
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM wsh_packed_containers
    WHERE rowid = X_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END Delete_Row;


END WSH_PACKED_CONTAINERS_PKG;

/
