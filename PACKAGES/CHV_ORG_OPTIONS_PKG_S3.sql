--------------------------------------------------------
--  DDL for Package CHV_ORG_OPTIONS_PKG_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_ORG_OPTIONS_PKG_S3" AUTHID CURRENT_USER as
/* $Header: CHVSEO3S.pls 115.0 99/07/17 01:31:01 porting ship $ */

/*===========================================================================
  PROCEDURE NAME:	Update_row()

  DESCRIPTION:		Table Handler to update the Supplier Scheduling
                        Organization Options.

  PARAMETERS:	        See Below

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SRUMALLA     01/29/96      Created

===========================================================================*/

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
                      );

END CHV_ORG_OPTIONS_PKG_S3;

 

/
