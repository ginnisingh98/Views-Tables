--------------------------------------------------------
--  DDL for Package CHV_ORG_OPTIONS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_ORG_OPTIONS_PKG_S1" AUTHID CURRENT_USER as
/* $Header: CHVSEO1S.pls 115.1 2002/11/23 04:09:58 sbull ship $ */

/*===========================================================================
  PROCEDURE NAME:	Insert_Row()

  DESCRIPTION:		Table Handler to Insert the row

  PARAMETERS:	        See Below

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SRUMALLA	01/29/96     Created

===========================================================================*/

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
                      );

END CHV_ORG_OPTIONS_PKG_S1;

 

/
