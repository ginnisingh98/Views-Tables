--------------------------------------------------------
--  DDL for Package CHV_SCH_HEADERS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_SCH_HEADERS_PKG_S1" AUTHID CURRENT_USER as
/* $Header: CHVSHDRS.pls 115.0 99/07/17 01:31:08 porting ship $ */

/*===========================================================================
  PROCEDURE NAME:	Lock_row()

  DESCRIPTION:		Table Handler to Lock the CHV_SCHEDULE_HEADERS table.

  PARAMETERS:	        See Below

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SRUMALLA      01/29/96		Created

===========================================================================*/

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
                    );

/*===========================================================================
  PROCEDURE NAME:	Update_row()

  DESCRIPTION:		Table Handler to update the Supplier Scheduling
                        CHV_SCHEDULE_HEADERS table.

  PARAMETERS:	        See Below

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SRUMALLA     01/29/96      Created

===========================================================================*/

  PROCEDURE Update_Row(
                       X_Rowid                          VARCHAR2,
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
                      );

/*==========================================================================
  PROCEDURE NAME:	Delete_Row()

  DESCRIPTION:		Contains the Table handler for Supplier Scheduling
                        to delete CHV_SCHEDULE_HEADERS table.

  PARAMETERS:           See Below

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SRUMALLA     01/29/96      Created

===========================================================================*/

PROCEDURE delete_row(X_RowId        VARCHAR2,
		     X_Schedule_Id  NUMBER
                    );
END CHV_SCH_HEADERS_PKG_S1;

 

/
