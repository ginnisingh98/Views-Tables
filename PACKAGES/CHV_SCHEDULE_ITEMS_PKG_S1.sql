--------------------------------------------------------
--  DDL for Package CHV_SCHEDULE_ITEMS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CHV_SCHEDULE_ITEMS_PKG_S1" AUTHID CURRENT_USER as
/* $Header: CHVSITMS.pls 115.0 99/07/17 01:31:41 porting ship $ */

/*===========================================================================
  PROCEDURE NAME:	Lock_row()

  DESCRIPTION:		Table Handler to Lock the CHV_SCHEDULE_ITEMS table.

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
                     X_Schedule_Item_Id               NUMBER,
                     X_Organization_Id                NUMBER,
                     X_Item_Id                        NUMBER,
                     X_Item_Planning_Method           VARCHAR2,
                     X_PO_Header_Id                   NUMBER,
                     X_PO_Line_Id                     NUMBER,
                     X_Rebuild_Flag                   VARCHAR2,
                     X_Item_Confirm_Status            VARCHAR2,
                     X_Starting_Cum_Quantity          NUMBER,
                     X_Starting_Auth_Quantity         NUMBER,
                     X_Starting_Cum_Qty_Primary       NUMBER,
                     X_Starting_Auth_Qty_Primary      NUMBER,
                     X_Last_Receipt_Transaction_Id    NUMBER,
                     X_Purchasing_Unit_Of_Measure     VARCHAR2,
                     X_Primary_Unit_Of_Measure        VARCHAR2,
                     X_Attribute_CaTegory             VARCHAR2,
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
                        CHV_SCHEDULE_ITEMS table.

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
                      );

/*==========================================================================
  PROCEDURE NAME:	Delete_Row1()

  DESCRIPTION:		Contains the Table handler for Supplier Scheduling
                        to delete CHV_SCHEDULE_ITEMS table.

  PARAMETERS:           See Below

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SRUMALLA     01/29/96      Created

===========================================================================*/
PROCEDURE delete_row1(X_RowId              VARCHAR2,
                      X_Schedule_Item_Id   NUMBER,
                      X_Schedule_Id        NUMBER
                     );

/*==========================================================================
  PROCEDURE NAME:	Delete_Row2()

  DESCRIPTION:		Contains the Table handler for Supplier Scheduling
                        to delete CHV_SCHEDULE_ITEMS table.

  PARAMETERS:           See Below

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SRUMALLA     01/29/96      Created

===========================================================================*/

PROCEDURE delete_row2(X_Schedule_Id NUMBER
                     );
END CHV_SCHEDULE_ITEMS_PKG_S1;

 

/
