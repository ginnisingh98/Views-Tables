--------------------------------------------------------
--  DDL for Package Body PO_RELEASES_PKG_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RELEASES_PKG_S2" as
/* $Header: POXP3PLB.pls 120.5 2005/09/30 08:50:33 nipagarw noship $ */

/*===========================================================================

   PROCEDURE NAME:  update_row()

=============================================================================*/

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Po_Release_Id                  NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Release_Num                    NUMBER,
                       X_Agent_Id                       NUMBER,
                       X_Release_Date                   DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Revision_Num                   NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                     X_Revised_Date                   VARCHAR2,
                       X_Revised_Date                   DATE,
                       X_Approved_Flag                  VARCHAR2,
                       X_Approved_Date                  DATE,
                       X_Print_Count                    NUMBER,
                       X_Printed_Date                   DATE,
                       X_Acceptance_Required_Flag       VARCHAR2,
                       X_Acceptance_Due_Date            DATE,
                       X_Hold_By                        NUMBER,
                       X_Hold_Date                      DATE,
                       X_Hold_Reason                    VARCHAR2,
                       X_Hold_Flag                      VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Cancelled_By                   NUMBER,
                       X_Cancel_Date                    DATE,
                       X_Cancel_Reason                  VARCHAR2,
                       X_Firm_Status_Lookup_Code        VARCHAR2,
                       X_Pay_On_Code                    VARCHAR2,
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
                       X_Authorization_Status           VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Closed_Code                    VARCHAR2,
                       X_Frozen_Flag                    VARCHAR2,
                       X_Release_Type                   VARCHAR2,
                       X_Need_To_Approve IN OUT NOCOPY  NUMBER,
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
                       p_shipping_control             IN    VARCHAR2    -- <INBOUND LOGISTICS FPJ>
) IS
 BEGIN
/* Bug 1181957
   ** Change the Authorization status to REQUIRES REAPPROVAL, only
   ** if it is APPROVEd.
   ** POXPOERL.fmb(Release) PO_RELEASES.ON-UPDATE trigger updates
   ** the authorization_status if X_Need_To_Approve > 0.
   ** X_Need_To_Approve is initialized and IF statement is added.
   */

    X_Need_To_Approve := 0;

 IF X_Approved_Flag = 'Y' THEN

  IF po_releases_sv4.val_approval_status(
		       X_po_release_id,
		       X_release_num,
		       X_agent_id,
		       X_release_date,
	 	       X_acceptance_required_flag,
		       X_acceptance_due_date,
                       p_shipping_control)  -- <INBOUND LOGISTICS FPJ>
      THEN
	    X_Need_To_Approve := 0;
         ELSE
            X_Need_To_Approve := 2;
         END IF;
 END IF;

   UPDATE PO_RELEASES
   SET
     po_release_id                     =     X_Po_Release_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     po_header_id                      =     X_Po_Header_Id,
     release_num                       =     X_Release_Num,
     agent_id                          =     X_Agent_Id,
     release_date                      =     X_Release_Date,
     last_update_login                 =     X_Last_Update_Login,
     revision_num                      =     X_Revision_Num,
     revised_date                      =     X_Revised_Date,
     approved_flag                     =     X_Approved_Flag,
     approved_date                     =     X_Approved_Date,
     print_count                       =     X_Print_Count,
     printed_date                      =     X_Printed_Date,
     acceptance_required_flag          =     X_Acceptance_Required_Flag,
     acceptance_due_date               =     X_Acceptance_Due_Date,
     hold_by                           =     X_Hold_By,
     hold_date                         =     X_Hold_Date,
     hold_reason                       =     X_Hold_Reason,
     hold_flag                         =     X_Hold_Flag,
     cancel_flag                       =     X_Cancel_Flag,
     cancelled_by                      =     X_Cancelled_By,
     cancel_date                       =     X_Cancel_Date,
     cancel_reason                     =     X_Cancel_Reason,
     firm_status_lookup_code           =     X_Firm_Status_Lookup_Code,
     pay_on_code                       =     X_Pay_On_Code,
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
     authorization_status              =     X_Authorization_Status,
     government_context                =     X_Government_Context,
     closed_code                       =     X_Closed_Code,
     frozen_flag                       =     X_Frozen_Flag,
     release_type                      =     X_Release_Type,
     global_attribute_category         =     X_Global_Attribute_Category,
     global_attribute1                 =     X_Global_Attribute1,
     global_attribute2                 =     X_Global_Attribute2,
     global_attribute3                 =     X_Global_Attribute3,
     global_attribute4                 =     X_Global_Attribute4,
     global_attribute5                 =     X_Global_Attribute5,
     global_attribute6                 =     X_Global_Attribute6,
     global_attribute7                 =     X_Global_Attribute7,
     global_attribute8                 =     X_Global_Attribute8,
     global_attribute9                 =     X_Global_Attribute9,
     global_attribute10                =     X_Global_Attribute10,
     global_attribute11                =     X_Global_Attribute11,
     global_attribute12                =     X_Global_Attribute12,
     global_attribute13                =     X_Global_Attribute13,
     global_attribute14                =     X_Global_Attribute14,
     global_attribute15                =     X_Global_Attribute15,
     global_attribute16                =     X_Global_Attribute16,
     global_attribute17                =     X_Global_Attribute17,
     global_attribute18                =     X_Global_Attribute18,
     global_attribute19                =     X_Global_Attribute19,
     global_attribute20                =     X_Global_Attribute20,
     shipping_control                  =     p_shipping_control    -- <INBOUND LOGISTICS FPJ>
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

/*===========================================================================

   PROCEDURE NAME:  delete_row()

=============================================================================*/


  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PO_RELEASES
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END PO_RELEASES_PKG_S2;

/
