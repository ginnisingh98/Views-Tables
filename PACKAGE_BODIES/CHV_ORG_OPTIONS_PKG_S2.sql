--------------------------------------------------------
--  DDL for Package Body CHV_ORG_OPTIONS_PKG_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_ORG_OPTIONS_PKG_S2" as
/* $Header: CHVSEO2B.pls 115.0 99/07/17 01:30:49 porting ship $ */

/*=============================================================================

   PROCEDURE NAME:  lock_row()

=============================================================================*/
  PROCEDURE Lock_Row(X_Rowid                          VARCHAR2,
                     X_Organization_Id                NUMBER,
                     X_Enable_Cum_Flag                VARCHAR2,
                     X_Rtv_Update_Cum_Flag            VARCHAR2,
                     X_Plan_Bucket_Pattern_Id         NUMBER,
                     X_Ship_Bucket_Pattern_Id         NUMBER,
                     X_Plan_Schedule_Type             VARCHAR2,
                     X_Ship_Schedule_Type             VARCHAR2,
                     X_Mrp_Compile_Designator         VARCHAR2,
                     X_Mps_Schedule_Designator        VARCHAR2,
                     X_Drp_Compile_Designator         VARCHAR2,
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
        FROM   CHV_ORG_OPTIONS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Organization_Id NOWAIT;
    Optioninfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Optioninfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (

               (Optioninfo.organization_id = X_Organization_Id)
           AND (Optioninfo.enable_cum_flag = X_Enable_Cum_Flag)
           AND (   (Optioninfo.rtv_update_cum_flag = X_Rtv_Update_Cum_Flag)
                OR (    (Optioninfo.rtv_update_cum_flag IS NULL)
                    AND (X_Rtv_Update_Cum_Flag IS NULL)))
           AND (   (Optioninfo.plan_bucket_pattern_id =
                             X_Plan_Bucket_Pattern_Id)
                OR (    (Optioninfo.plan_bucket_pattern_id IS NULL)
                    AND (X_Plan_Bucket_Pattern_Id IS NULL)))
           AND (   (Optioninfo.ship_bucket_pattern_id =
                                       X_ship_Bucket_Pattern_Id)
                OR (    (Optioninfo.ship_bucket_pattern_id IS NULL)
                    AND (X_ship_Bucket_Pattern_Id IS NULL)))
           AND (   (Optioninfo.plan_schedule_type = X_Plan_Schedule_Type)
                OR (    (Optioninfo.Plan_Schedule_Type IS NULL)
                    AND (X_Plan_Schedule_Type IS NULL)))
           AND (   (Optioninfo.ship_schedule_type = X_Ship_Schedule_Type)
                OR (    (Optioninfo.ship_schedule_type IS NULL)
                    AND (X_Ship_Schedule_Type IS NULL)))
           AND (   (Optioninfo.mrp_compile_designator =
                             X_Mrp_Compile_Designator)
                OR (    (Optioninfo.mrp_compile_designator IS NULL)
                    AND (X_Mrp_Compile_Designator IS NULL)))
           AND (   (Optioninfo.mps_schedule_designator =
                             X_Mps_Schedule_Designator)
                OR (    (Optioninfo.mps_Schedule_designator IS NULL)
                    AND (X_Mps_Schedule_Designator IS NULL)))
           AND (   (Optioninfo.drp_compile_designator =
                             X_Drp_Compile_Designator)
                OR (    (Optioninfo.drp_compile_designator IS NULL)
                    AND (X_Drp_Compile_Designator IS NULL)))
           AND (   (Optioninfo.attribute_category = X_Attribute_Category)
                OR (    (Optioninfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Optioninfo.attribute1 = X_Attribute1)
                OR (    (Optioninfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Optioninfo.attribute2 = X_Attribute2)
                OR (    (Optioninfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Optioninfo.attribute3 = X_Attribute3)
                OR (    (Optioninfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Optioninfo.attribute4 = X_Attribute4)
                OR (    (Optioninfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Optioninfo.attribute5 = X_Attribute5)
                OR (    (Optioninfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Optioninfo.attribute6 = X_Attribute6)
                OR (    (Optioninfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Optioninfo.attribute7 = X_Attribute7)
                OR (    (Optioninfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Optioninfo.attribute8 = X_Attribute8)
                OR (    (Optioninfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Optioninfo.attribute9 = X_Attribute9)
                OR (    (Optioninfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Optioninfo.attribute10 = X_Attribute10)
                OR (    (Optioninfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Optioninfo.attribute11 = X_Attribute11)
                OR (    (Optioninfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Optioninfo.attribute12 = X_Attribute12)
                OR (    (Optioninfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Optioninfo.attribute13 = X_Attribute13)
                OR (    (Optioninfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Optioninfo.attribute14 = X_Attribute14)
                OR (    (Optioninfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Optioninfo.attribute15 = X_Attribute15)
                OR (    (Optioninfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;

END CHV_ORG_OPTIONS_PKG_S2;

/
