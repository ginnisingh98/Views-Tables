--------------------------------------------------------
--  DDL for Package Body CHV_SCHEDULE_ITEMS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_SCHEDULE_ITEMS_PKG_S1" as
/* $Header: CHVSITMB.pls 115.0 99/07/17 01:31:37 porting ship $ */

/*=============================================================================

   PROCEDURE NAME:  lock_row()

=============================================================================*/
  PROCEDURE Lock_Row(X_Rowid                          VARCHAR2,
                     X_Schedule_Id                    NUMBER,
                     X_Schedule_Item_Id               NUMBER,
                     X_Organization_Id                NUMBER,
                     X_Item_Id                        NUMBER,
                     X_Item_Planning_Method           VARCHAR2,
                     X_Po_Header_Id                   NUMBER,
                     X_Po_Line_Id                     NUMBER,
                     X_Rebuild_Flag                   VARCHAR2,
                     X_Item_Confirm_Status            VARCHAR2,
                     X_Starting_Cum_Quantity          NUMBER,
                     X_Starting_Auth_Quantity         NUMBER,
                     X_Starting_Cum_Qty_Primary       NUMBER,
                     X_Starting_Auth_Qty_Primary      NUMBER,
                     X_Last_Receipt_Transaction_Id    NUMBER,
                     X_Purchasing_Unit_OF_Measure     VARCHAR2,
                     X_Primary_Unit_Of_Measure        VARCHAR2,
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
    CURSOR C IS
        SELECT *
        FROM   CHV_SCHEDULE_ITEMS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Schedule_Id NOWAIT;
    Itemrec C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Itemrec;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Itemrec.schedule_id = X_Schedule_Id)
           AND (Itemrec.schedule_item_id = X_schedule_item_id)
           AND (Itemrec.organization_id = X_organization_id)
           AND (Itemrec.item_id = X_item_id)
           AND (Itemrec.item_planning_method = X_item_planning_method)
           AND (   (Itemrec.po_header_id = X_po_header_id)
                OR (    (Itemrec.po_header_id IS NULL)
                    AND (X_po_header_id IS NULL)))
           AND (   (Itemrec.po_line_id = X_po_line_id)
                OR (    (Itemrec.po_line_id IS NULL)
                    AND (X_po_line_id IS NULL)))
           AND (   (Itemrec.rebuild_flag = X_rebuild_flag)
                OR (    (Itemrec.rebuild_flag IS NULL)
                    AND (X_rebuild_flag IS NULL)))
           AND (   (Itemrec.item_confirm_status =
                             X_item_confirm_status)
                OR (    (Itemrec.item_confirm_status IS NULL)
                    AND (X_item_confirm_status IS NULL)))
           AND (   (Itemrec.starting_cum_quantity =
                             X_starting_cum_quantity)
                OR (    (Itemrec.starting_cum_quantity IS NULL)
                    AND (X_starting_cum_quantity IS NULL)))
           AND (   (Itemrec.starting_auth_quantity =
                             X_starting_auth_quantity)
                OR (    (Itemrec.starting_auth_quantity IS NULL)
                    AND (X_starting_auth_quantity IS NULL)))
           AND (   (Itemrec.starting_cum_qty_primary =
                                       X_starting_cum_qty_primary)
                OR (    (Itemrec.starting_cum_qty_primary IS NULL)
                    AND (X_starting_cum_qty_primary IS NULL)))
           AND (   (Itemrec.starting_auth_qty_primary =
                                       X_starting_auth_qty_primary)
                OR (    (Itemrec.starting_auth_qty_primary IS NULL)
                    AND (X_starting_auth_qty_primary IS NULL)))
           AND (   (Itemrec.last_receipt_transaction_id =
                             X_last_receipt_transaction_id)
                OR (    (Itemrec.last_receipt_transaction_id IS NULL)
                    AND (X_last_receipt_transaction_id IS NULL)))
           AND (   (Itemrec.purchasing_unit_of_measure =
                             X_purchasing_unit_of_measure)
                OR (    (Itemrec.purchasing_unit_of_measure IS NULL)
                    AND (X_purchasing_unit_of_measure IS NULL)))
           AND (   (Itemrec.primary_unit_of_measure =
                             X_primary_unit_of_measure)
                OR (    (Itemrec.primary_unit_of_measure IS NULL)
                    AND (X_primary_unit_of_measure IS NULL)))
           AND (   (Itemrec.attribute_category = X_Attribute_Category)
                OR (    (Itemrec.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Itemrec.attribute1 = X_Attribute1)
                OR (    (Itemrec.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Itemrec.attribute2 = X_Attribute2)
                OR (    (Itemrec.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Itemrec.attribute3 = X_Attribute3)
                OR (    (Itemrec.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Itemrec.attribute4 = X_Attribute4)
                OR (    (Itemrec.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Itemrec.attribute5 = X_Attribute5)
                OR (    (Itemrec.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Itemrec.attribute6 = X_Attribute6)
                OR (    (Itemrec.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Itemrec.attribute7 = X_Attribute7)
                OR (    (Itemrec.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Itemrec.attribute8 = X_Attribute8)
                OR (    (Itemrec.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Itemrec.attribute9 = X_Attribute9)
                OR (    (Itemrec.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Itemrec.attribute10 = X_Attribute10)
                OR (    (Itemrec.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Itemrec.attribute11 = X_Attribute11)
                OR (    (Itemrec.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Itemrec.attribute12 = X_Attribute12)
                OR (    (Itemrec.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Itemrec.attribute13 = X_Attribute13)
                OR (    (Itemrec.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Itemrec.attribute14 = X_Attribute14)
                OR (    (Itemrec.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Itemrec.attribute15 = X_Attribute15)
                OR (    (Itemrec.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;

/*===========================================================================

   PROCEDURE NAME:  update_row()

=============================================================================*/
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Item_Confirm_Status            VARCHAR2,
                       X_Rebuild_Flag                   VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
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

   UPDATE CHV_SCHEDULE_ITEMS
   SET
     item_confirm_status               =     X_Item_Confirm_Status,
     rebuild_flag                      =     X_Rebuild_Flag,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
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
     attribute15                       =     X_Attribute15
   WHERE rowid = X_rowid ;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

/*===========================================================================

   PROCEDURE NAME:  delete_row1()

=============================================================================*/
PROCEDURE delete_row1(X_RowId                   VARCHAR2,
                      X_Schedule_Item_Id        NUMBER,
                      X_Schedule_Id             NUMBER
                     ) IS

BEGIN


  CHV_ITEM_ORDERS_PKG_S1.delete_row(X_Schedule_Id,
				    X_Schedule_Item_Id) ;

  CHV_HORIZ_SCHEDULES_PKG_S1.delete_row(X_Schedule_Id,
	                 	        X_Schedule_Item_Id) ;

  CHV_AUTHORIZATIONS_PKG_S1.delete_row(X_Schedule_Item_Id) ;

  /* After the data is deleted from the child tables
  ** delete from the items table.
  */

  DELETE FROM chv_schedule_items
   WHERE rowid            =  X_Rowid ;

  if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND ;
  end if ;

END delete_row1 ;

/*===========================================================================

   PROCEDURE NAME:  delete_row2()

=============================================================================*/
PROCEDURE delete_row2(X_Schedule_Id       NUMBER
                     ) IS

Cursor C1 is SELECT rowid, schedule_item_id
              FROM  CHV_SCHEDULE_ITEMS
              WHERE schedule_id = X_Schedule_Id ;

BEGIN

  for Itemrec in C1 loop

   /*  Execute procedure to actually delete the records */

   CHV_SCHEDULE_ITEMS_PKG_S1.delete_row1(Itemrec.rowid,
				         Itemrec.Schedule_Item_Id,
                                         X_Schedule_Id
					) ;
  end loop ;

END delete_row2 ;

END CHV_SCHEDULE_ITEMS_PKG_S1;

/
