--------------------------------------------------------
--  DDL for Package PO_RELEASES_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RELEASES_PKG_S1" AUTHID CURRENT_USER as
/* $Header: POXP2PLS.pls 115.4 2003/07/06 19:03:39 dxie ship $ */

/*===========================================================================
  PROCEDURE NAME:	Lock_row()

  DESCRIPTION:		Table Handler to Lock the Release Header

  PARAMETERS:

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		4/20	Created
                        SIYER           6/6     Changed

===========================================================================*/
  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Po_Release_Id                    NUMBER,
                     X_Po_Header_Id                     NUMBER,
                     X_Release_Num                      NUMBER,
                     X_Agent_Id                         NUMBER,
                     X_Release_Date                     DATE,
                     X_Revision_Num                     NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                   X_Revised_Date                     VARCHAR2,
                     X_Revised_Date                     DATE,
                     X_Approved_Flag                    VARCHAR2,
                     X_Approved_Date                    DATE,
                     X_Print_Count                      NUMBER,
                     X_Printed_Date                     DATE,
                     X_Acceptance_Required_Flag         VARCHAR2,
                     X_Acceptance_Due_Date              DATE,
                     X_Hold_By                          NUMBER,
                     X_Hold_Date                        DATE,
                     X_Hold_Reason                      VARCHAR2,
                     X_Hold_Flag                        VARCHAR2,
                     X_Cancel_Flag                      VARCHAR2,
                     X_Cancelled_By                     NUMBER,
                     X_Cancel_Date                      DATE,
                     X_Cancel_Reason                    VARCHAR2,
                     X_Firm_Status_Lookup_Code          VARCHAR2,
                     X_Pay_On_Code                      VARCHAR2,
                     --X_Firm_Date                        DATE,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Authorization_Status             VARCHAR2,
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Government_Context               VARCHAR2,
                     X_Closed_Code                      VARCHAR2,
                     X_Frozen_Flag                      VARCHAR2,
                     X_Release_Type                     VARCHAR2,
                     --X_Note_To_Vendor                   VARCHAR2
	               X_Global_Attribute_Category          VARCHAR2,
                       X_Global_Attribute1                  VARCHAR2,
                       X_Global_Attribute2                  VARCHAR2,
                       X_Global_Attribute3                  VARCHAR2,
                       X_Global_Attribute4                  VARCHAR2,
                       X_Global_Attribute5                  VARCHAR2,
                       X_Global_Attribute6                  VARCHAR2,
                       X_Global_Attribute7                  VARCHAR2,
                       X_Global_Attribute8                  VARCHAR2,
                       X_Global_Attribute9                  VARCHAR2,
                       X_Global_Attribute10                 VARCHAR2,
                       X_Global_Attribute11                 VARCHAR2,
                       X_Global_Attribute12                 VARCHAR2,
                       X_Global_Attribute13                 VARCHAR2,
                       X_Global_Attribute14                 VARCHAR2,
                       X_Global_Attribute15                 VARCHAR2,
                       X_Global_Attribute16                 VARCHAR2,
                       X_Global_Attribute17                 VARCHAR2,
                       X_Global_Attribute18                 VARCHAR2,
                       X_Global_Attribute19                 VARCHAR2,
                       X_Global_Attribute20                 VARCHAR2,
                       p_shipping_control             IN    VARCHAR2 DEFAULT NULL    -- <INBOUND LOGISTICS FPJ>
                       );


END PO_RELEASES_PKG_S1;

 

/
