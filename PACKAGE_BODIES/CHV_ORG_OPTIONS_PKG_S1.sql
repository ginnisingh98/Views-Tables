--------------------------------------------------------
--  DDL for Package Body CHV_ORG_OPTIONS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_ORG_OPTIONS_PKG_S1" as
/* $Header: CHVSEO1B.pls 115.1 2002/11/23 04:10:10 sbull ship $ */

/*===========================================================================

   PROCEDURE NAME:  insert_row()

=============================================================================*/


  PROCEDURE Insert_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Enable_Cum_Flag                VARCHAR2,
                       X_Rtv_Update_Cum_Flag            VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
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
     CURSOR C IS SELECT rowid FROM CHV_ORG_OPTIONS
                 WHERE organization_id = X_Organization_Id ;


    BEGIN

       INSERT INTO CHV_ORG_OPTIONS (
              organization_id,
              enable_cum_flag,
              rtv_update_cum_flag,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              plan_bucket_pattern_id,
              ship_bucket_pattern_id,
              plan_schedule_type,
              ship_schedule_type,
              mrp_compile_designator,
              mps_schedule_designator,
              drp_compile_designator,
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
              last_update_login
            ) VALUES (
              X_organization_Id,
              X_Enable_Cum_Flag,
              X_Rtv_Update_Cum_Flag,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Plan_Bucket_Pattern_Id,
              X_Ship_Bucket_Pattern_Id,
              X_Plan_Schedule_Type,
              X_Ship_Schedule_Type,
              X_Mrp_Compile_Designator,
              X_Mps_Schedule_Designator,
              X_Drp_Compile_Designator,
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
              X_Last_Update_Login
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;

END CHV_ORG_OPTIONS_PKG_S1;

/
