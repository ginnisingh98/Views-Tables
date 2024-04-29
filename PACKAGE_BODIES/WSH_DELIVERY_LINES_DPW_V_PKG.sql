--------------------------------------------------------
--  DDL for Package Body WSH_DELIVERY_LINES_DPW_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DELIVERY_LINES_DPW_V_PKG" as
/* $Header: WSHDLNHB.pls 115.0 99/07/16 08:18:48 porting ship $ */

  -- This package is required to lock and update the delivery lines' info for
  -- the Departure Planning Workbench.
  -- Because the delivery lines consist of rows from SO_LINE_DETAILS and
  -- SO_PICKING_LINE_DETAILS, there are two Lock and Update row procedures.
  -- The "LD" procedures update the SO_LINE_DETAILS table and the "PLD"
  -- procedures update the SO_PICKING_LINE_DETAILS table.

  PROCEDURE Lock_LD_Row(X_Rowid                          VARCHAR2,
                        X_Line_Detail_Id                 NUMBER,
                        X_Released_Flag			 VARCHAR2,
                        X_Delivery_Id                    NUMBER,
                        X_Departure_Id                   NUMBER,
                        X_Load_Seq_Number                NUMBER,
                        X_Master_Container_Item_Id       NUMBER,
                        X_Detail_Container_Item_Id       NUMBER,
                        X_DPW_Assigned_Flag              VARCHAR2,
                        X_Last_Update_Date               DATE,
                        X_Last_Updated_By		 NUMBER,
                        X_Last_Update_Login		 NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   so_line_details
        WHERE  rowid = X_Rowid
        FOR UPDATE of Line_Detail_Id NOWAIT;
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
               (Recinfo.line_detail_id =  X_Line_Detail_Id)
           AND (   (Recinfo.released_flag =  X_Released_Flag)
                OR (    (Recinfo.released_flag IS NULL)
                    AND (X_Released_Flag IS NULL)))
           AND (   (Recinfo.delivery_id =  X_Delivery_Id)
                OR (    (Recinfo.delivery_id IS NULL)
                    AND (X_Delivery_Id IS NULL)))
           AND (   (Recinfo.departure_id =  X_Departure_Id)
                OR (    (Recinfo.departure_id IS NULL)
                    AND (X_Departure_Id IS NULL)))
           AND (   (Recinfo.load_seq_number =  X_Load_Seq_Number)
                OR (    (Recinfo.load_seq_number IS NULL)
                    AND (X_Load_Seq_Number IS NULL)))
           AND (   (Recinfo.master_container_item_id =  X_Master_Container_Item_Id)
                OR (    (Recinfo.master_container_item_id IS NULL)
                    AND (X_Master_Container_Item_Id IS NULL)))
           AND (   (Recinfo.detail_container_item_id =  X_Detail_Container_Item_Id)
                OR (    (Recinfo.detail_container_item_id IS NULL)
                    AND (X_Detail_Container_Item_Id IS NULL)))
           AND (   (Recinfo.dpw_assigned_flag =  X_DPW_Assigned_Flag)
                OR (    (Recinfo.dpw_assigned_flag IS NULL)
                    AND (X_DPW_Assigned_Flag IS NULL)))
           AND (   (Recinfo.last_update_date =  X_Last_Update_Date)
                OR (    (Recinfo.last_update_date IS NULL)
                    AND (X_Last_Update_Date IS NULL)))
           AND (   (Recinfo.last_updated_by =  X_Last_Updated_By)
                OR (    (Recinfo.last_updated_by IS NULL)
                    AND (X_Last_Updated_By IS NULL)))
           AND (   (Recinfo.last_update_login =  X_Last_Update_Login)
                OR (    (Recinfo.last_update_login IS NULL)
                    AND (X_Last_Update_Login IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_LD_Row;

  PROCEDURE Update_LD_Row(X_Rowid                          VARCHAR2,
                          X_Delivery_Id                    NUMBER,
                          X_Departure_Id                   NUMBER,
                          X_Load_Seq_Number                NUMBER,
                          X_Master_Container_Item_Id       NUMBER,
                          X_Detail_Container_Item_Id       NUMBER,
                          X_DPW_Assigned_Flag              VARCHAR2,
                          X_Last_Update_Date               DATE,
                          X_Last_Updated_By                NUMBER,
                          X_Last_Update_Login              NUMBER
  ) IS
  BEGIN
    UPDATE so_line_details
    SET
       delivery_id                     =     X_Delivery_Id,
       departure_id                    =     X_Departure_Id,
       load_seq_number                 =     X_Load_Seq_Number,
       master_container_item_id        =     X_Master_Container_Item_Id,
       detail_container_item_id        =     X_Detail_Container_Item_Id,
       dpw_assigned_flag               =     X_DPW_Assigned_Flag,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_LD_Row;


  PROCEDURE Lock_PLD_Row(X_Rowid                          VARCHAR2,
                         X_Picking_Line_Detail_Id         NUMBER,
                         X_Released_Flag		  VARCHAR2,
                         X_Delivery_Id                    NUMBER,
                         X_Departure_Id                   NUMBER,
                         X_Load_Seq_Number                NUMBER,
                         X_Master_Container_Item_Id       NUMBER,
                         X_Detail_Container_Item_Id       NUMBER,
                         X_DPW_Assigned_Flag              VARCHAR2,
                         X_Last_Update_Date               DATE,
                         X_Last_Updated_By		  NUMBER,
                         X_Last_Update_Login		  NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   so_picking_line_details
        WHERE  rowid = X_Rowid
        FOR UPDATE of Picking_Line_Detail_Id NOWAIT;
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
               (Recinfo.picking_line_detail_id =  X_Picking_Line_Detail_Id)
           AND (   (Recinfo.released_flag =  X_Released_Flag)
                OR (    (Recinfo.released_flag IS NULL)
                    AND (X_Released_Flag IS NULL)))
           AND (   (Recinfo.delivery_id =  X_Delivery_Id)
                OR (    (Recinfo.delivery_id IS NULL)
                    AND (X_Delivery_Id IS NULL)))
           AND (   (Recinfo.departure_id =  X_Departure_Id)
                OR (    (Recinfo.departure_id IS NULL)
                    AND (X_Departure_Id IS NULL)))
           AND (   (Recinfo.load_seq_number =  X_Load_Seq_Number)
                OR (    (Recinfo.load_seq_number IS NULL)
                    AND (X_Load_Seq_Number IS NULL)))
           AND (   (Recinfo.master_container_item_id =  X_Master_Container_Item_Id)
                OR (    (Recinfo.master_container_item_id IS NULL)
                    AND (X_Master_Container_Item_Id IS NULL)))
           AND (   (Recinfo.detail_container_item_id =  X_Detail_Container_Item_Id)
                OR (    (Recinfo.detail_container_item_id IS NULL)
                    AND (X_Detail_Container_Item_Id IS NULL)))
           AND (   (Recinfo.dpw_assigned_flag =  X_DPW_Assigned_Flag)
                OR (    (Recinfo.dpw_assigned_flag IS NULL)
                    AND (X_DPW_Assigned_Flag IS NULL)))
           AND (   (Recinfo.last_update_date =  X_Last_Update_Date)
                OR (    (Recinfo.last_update_date IS NULL)
                    AND (X_Last_Update_Date IS NULL)))
           AND (   (Recinfo.last_updated_by =  X_Last_Updated_By)
                OR (    (Recinfo.last_updated_by IS NULL)
                    AND (X_Last_Updated_By IS NULL)))
           AND (   (Recinfo.last_update_login =  X_Last_Update_Login)
                OR (    (Recinfo.last_update_login IS NULL)
                    AND (X_Last_Update_Login IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_PLD_Row;

  PROCEDURE Update_PLD_Row(X_Rowid                          VARCHAR2,
                           X_Delivery_Id                    NUMBER,
                           X_Departure_Id                   NUMBER,
                           X_Load_Seq_Number                NUMBER,
                           X_Master_Container_Item_Id       NUMBER,
                           X_Detail_Container_Item_Id       NUMBER,
                           X_DPW_Assigned_Flag              VARCHAR2,
                           X_Last_Update_Date               DATE,
                           X_Last_Updated_By                NUMBER,
                           X_Last_Update_Login              NUMBER
  ) IS
  BEGIN
    UPDATE so_picking_line_details
    SET
       delivery_id                     =     X_Delivery_Id,
       departure_id                    =     X_Departure_Id,
       load_seq_number                 =     X_Load_Seq_Number,
       master_container_item_id        =     X_Master_Container_Item_Id,
       detail_container_item_id        =     X_Detail_Container_Item_Id,
       dpw_assigned_flag               =     X_DPW_Assigned_Flag,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_PLD_Row;


END WSH_DELIVERY_LINES_DPW_V_PKG;

/
