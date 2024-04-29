--------------------------------------------------------
--  DDL for Package Body CHV_SCH_HEADERS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_SCH_HEADERS_PKG_S1" as
/* $Header: CHVSHDRB.pls 115.0 99/07/17 01:31:05 porting ship $ */

/*=============================================================================

   PROCEDURE NAME:  lock_row()

=============================================================================*/
  PROCEDURE Lock_Row(X_Rowid                          VARCHAR2,
                     X_Schedule_Id                    NUMBER,
		     X_Vendor_Id                      NUMBER,
                     X_Vendor_Site_Id                 NUMBER,
                     X_Schedule_Type                  VARCHAR2,
                     X_Schedule_Subtype               VARCHAR2,
                     X_Schedule_Num                   VARCHAR2,
                     X_Schedule_Revision              NUMBER,
                     X_Schedule_Horizon_Start         DATE,
                     X_Schedule_Horizon_End           DATE,
                     X_Bucket_Pattern_Id              NUMBER,
                     X_Schedule_Owner_Id              NUMBER,
                     X_Organization_Id                NUMBER,
                     X_MPS_Schedule_Designator        VARCHAR2,
                     X_MRP_Compile_Designator         VARCHAR2,
                     X_DRP_Compile_Designator         VARCHAR2,
                     X_Schedule_Status                VARCHAR2,
                     X_Inquiry_Flag                   VARCHAR2,
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
        FROM   CHV_SCHEDULE_HEADERS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Schedule_Id NOWAIT;
    Hdrrec C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Hdrrec;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Hdrrec.schedule_id = X_Schedule_Id)
           AND (Hdrrec.vendor_id = X_Vendor_Id)
           AND (Hdrrec.vendor_site_id = X_Vendor_site_Id)
           AND (Hdrrec.schedule_type = X_schedule_type)
           AND (Hdrrec.schedule_subtype = X_schedule_subtype)
           AND (Hdrrec.schedule_horizon_start = X_schedule_horizon_start)
           AND (Hdrrec.schedule_horizon_end = X_schedule_horizon_end)
           AND (Hdrrec.bucket_pattern_id = X_bucket_pattern_id)
           AND (Hdrrec.schedule_owner_id = X_Schedule_owner_id)
           AND (   (Hdrrec.schedule_num = X_schedule_num)
                OR (    (Hdrrec.schedule_num IS NULL)
                    AND (X_schedule_num IS NULL)))
           AND (   (Hdrrec.schedule_revision = X_schedule_revision)
                OR (    (Hdrrec.schedule_revision IS NULL)
                    AND (X_schedule_revision IS NULL)))
           AND (   (Hdrrec.organization_id = X_organization_id)
                OR (    (Hdrrec.organization_id IS NULL)
                    AND (X_organization_id IS NULL)))
           AND (   (Hdrrec.mrp_compile_designator =
                             X_Mrp_Compile_Designator)
                OR (    (Hdrrec.mrp_compile_designator IS NULL)
                    AND (X_Mrp_Compile_Designator IS NULL)))
           AND (   (Hdrrec.mps_schedule_designator =
                             X_Mps_Schedule_Designator)
                OR (    (Hdrrec.mps_Schedule_designator IS NULL)
                    AND (X_Mps_Schedule_Designator IS NULL)))
           AND (   (Hdrrec.drp_compile_designator =
                             X_Drp_Compile_Designator)
                OR (    (Hdrrec.drp_compile_designator IS NULL)
                    AND (X_Drp_Compile_Designator IS NULL)))
           AND (   (Hdrrec.schedule_status = X_schedule_status)
                OR (    (Hdrrec.schedule_status IS NULL)
                    AND (X_schedule_status IS NULL)))
           AND (   (Hdrrec.inquiry_flag = X_inquiry_flag)
                OR (    (Hdrrec.inquiry_flag IS NULL)
                    AND (X_inquiry_flag IS NULL)))
           AND (   (Hdrrec.attribute_category = X_Attribute_Category)
                OR (    (Hdrrec.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Hdrrec.attribute1 = X_Attribute1)
                OR (    (Hdrrec.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Hdrrec.attribute2 = X_Attribute2)
                OR (    (Hdrrec.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Hdrrec.attribute3 = X_Attribute3)
                OR (    (Hdrrec.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Hdrrec.attribute4 = X_Attribute4)
                OR (    (Hdrrec.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Hdrrec.attribute5 = X_Attribute5)
                OR (    (Hdrrec.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Hdrrec.attribute6 = X_Attribute6)
                OR (    (Hdrrec.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Hdrrec.attribute7 = X_Attribute7)
                OR (    (Hdrrec.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Hdrrec.attribute8 = X_Attribute8)
                OR (    (Hdrrec.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Hdrrec.attribute9 = X_Attribute9)
                OR (    (Hdrrec.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Hdrrec.attribute10 = X_Attribute10)
                OR (    (Hdrrec.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Hdrrec.attribute11 = X_Attribute11)
                OR (    (Hdrrec.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Hdrrec.attribute12 = X_Attribute12)
                OR (    (Hdrrec.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Hdrrec.attribute13 = X_Attribute13)
                OR (    (Hdrrec.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Hdrrec.attribute14 = X_Attribute14)
                OR (    (Hdrrec.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Hdrrec.attribute15 = X_Attribute15)
                OR (    (Hdrrec.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;

/*=============================================================================

   PROCEDURE NAME:  update_row()

=============================================================================*/

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Schedule_Num                   VARCHAR2,
                       X_Schedule_Status                VARCHAR2,
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

   UPDATE CHV_SCHEDULE_HEADERS
   SET
     schedule_num                      =     X_Schedule_num,
     schedule_status                   =     X_Schedule_status,
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

   PROCEDURE NAME:  delete_row()

=============================================================================*/
PROCEDURE delete_row(X_RowId                    VARCHAR2,
                     X_Schedule_Id              NUMBER
                    ) IS

BEGIN

   /* Execute Procedure to delete items associated with this
   ** schedule header.
   */

   CHV_SCHEDULE_ITEMS_PKG_S1.delete_row2(X_Schedule_Id) ;

   /* Delete the schedule headers table based on the
   ** Row_Id
   */

   DELETE FROM chv_schedule_headers
   WHERE rowid = X_Rowid ;


   if (SQL%NOTFOUND) then
     Raise NO_DATA_FOUND ;
   end if ;

END delete_row ;

END CHV_SCH_HEADERS_PKG_S1;

/
