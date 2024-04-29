--------------------------------------------------------
--  DDL for Package Body CHV_ORG_OPTIONS_PKG_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_ORG_OPTIONS_PKG_S3" as
/* $Header: CHVSEO3B.pls 115.0 99/07/17 01:30:57 porting ship $ */

/*===========================================================================

   PROCEDURE NAME:  update_row()

=============================================================================*/

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Enable_Cum_Flag                VARCHAR2,
                       X_Rtv_Update_Cum_Flag            VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
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
                       X_Attribute15                    VARCHAR2,
                       X_Last_Update_Login              NUMBER
 ) IS
 BEGIN
   UPDATE CHV_ORG_OPTIONS
   SET

     organization_id                   =     X_Organization_Id,
     enable_cum_flag                   =     X_Enable_Cum_Flag,
     rtv_update_cum_flag               =     X_Rtv_Update_Cum_Flag,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     plan_bucket_pattern_Id            =     X_Plan_Bucket_Pattern_Id,
     ship_bucket_pattern_Id            =     X_Ship_Bucket_Pattern_Id,
     plan_schedule_type                =     X_Plan_Schedule_Type,
     ship_schedule_type                =     X_Ship_Schedule_Type,
     mrp_compile_designator            =     X_Mrp_Compile_Designator,
     mps_schedule_designator           =     X_Mps_Schedule_Designator,
     drp_compile_designator            =     X_Drp_Compile_Designator,
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
     attribute15                       =     X_Attribute15,
     last_update_login                 =     X_Last_Update_Login
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;


END CHV_ORG_OPTIONS_PKG_S3;

/
