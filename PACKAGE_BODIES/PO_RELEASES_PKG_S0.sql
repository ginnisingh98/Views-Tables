--------------------------------------------------------
--  DDL for Package Body PO_RELEASES_PKG_S0
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RELEASES_PKG_S0" as
/* $Header: POXP1PLB.pls 120.4 2005/08/29 00:29:01 vsanjay noship $ */

/*===========================================================================

   PROCEDURE NAME:  insert_row()

=============================================================================*/


  PROCEDURE Insert_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Po_Release_Id                  IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Release_Num                    NUMBER,
                       X_Agent_Id                       NUMBER,
                       X_Release_Date                   DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
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
                       p_shipping_control             IN    VARCHAR2,    -- <INBOUND LOGISTICS FPJ>
		       p_org_id                       IN    NUMBER DEFAULT NULL   -- <R12 MOAC>
   ) IS
     CURSOR C IS SELECT rowid FROM PO_RELEASES
                 WHERE po_release_id = X_Po_Release_Id;





      CURSOR C2 IS SELECT po_releases_s.nextval FROM sys.dual;

     x_progress VARCHAR2(3) := NULL;
    BEGIN
       x_progress := '005';

      if (X_Po_Release_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Po_Release_Id;
        CLOSE C2;
      end if;

        x_progress := '010';

       INSERT INTO PO_RELEASES (
               po_release_id,
               last_update_date,
               last_updated_by,
               po_header_id,
               release_num,
               agent_id,
               release_date,
               last_update_login,
               creation_date,
               created_by,
               revision_num,
               revised_date,
               approved_flag,
               approved_date,
               print_count,
               printed_date,
               acceptance_required_flag,
               acceptance_due_date,
               hold_by,
               hold_date,
               hold_reason,
               hold_flag,
               cancel_flag,
               cancelled_by,
               cancel_date,
               cancel_reason,
               firm_status_lookup_code,
               pay_on_code,
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
               authorization_status,
               government_context,
               closed_code,
               frozen_flag,
               release_type,
		global_attribute_category,
		global_attribute1,
		global_attribute2,
		global_attribute3,
		global_attribute4,
		global_attribute5,
		global_attribute6,
		global_attribute7,
		global_attribute8,
		global_attribute9,
		global_attribute10,
		global_attribute11,
		global_attribute12,
		global_attribute13,
		global_attribute14,
		global_attribute15,
		global_attribute16,
		global_attribute17,
		global_attribute18,
		global_attribute19,
		global_attribute20,
                shipping_control,    -- <INBOUND LOGISTICS FPJ>
				document_creation_method,	-- <DBI FPJ>
               Org_Id,              -- <R12 MOAC>
               tax_attribute_update_code --<eTax Integration R12>
             ) VALUES (
               X_Po_Release_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Po_Header_Id,
               X_Release_Num,
               X_Agent_Id,
               X_Release_Date,
               X_Last_Update_Login,
               X_Creation_Date,
               X_Created_By,
               X_Revision_Num,
               X_Revised_Date,
               X_Approved_Flag,
               X_Approved_Date,
               X_Print_Count,
               X_Printed_Date,
               X_Acceptance_Required_Flag,
               X_Acceptance_Due_Date,
               X_Hold_By,
               X_Hold_Date,
               X_Hold_Reason,
               X_Hold_Flag,
               X_Cancel_Flag,
               X_Cancelled_By,
               X_Cancel_Date,
               X_Cancel_Reason,
               X_Firm_Status_Lookup_Code,
               X_Pay_On_Code,
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
               X_Authorization_Status,
               X_Government_Context,
               X_Closed_Code,
               X_Frozen_Flag,
               X_Release_Type,
               X_Global_Attribute_Category,
               X_Global_Attribute1,
               X_Global_Attribute2,
               X_Global_Attribute3,
               X_Global_Attribute4,
               X_Global_Attribute5,
               X_Global_Attribute6,
               X_Global_Attribute7,
               X_Global_Attribute8,
               X_Global_Attribute9,
               X_Global_Attribute10,
               X_Global_Attribute11,
               X_Global_Attribute12,
               X_Global_Attribute13,
               X_Global_Attribute14,
               X_Global_Attribute15,
               X_Global_Attribute16,
               X_Global_Attribute17,
               X_Global_Attribute18,
               X_Global_Attribute19,
               X_Global_Attribute20,
               p_shipping_control,    -- <INBOUND LOGISTICS FPJ>
               -- Bug 3648268. Using lookup code instead of hardcoded value
	       'ENTER_RELEASE' ,       -- <DBI FPJ>
               p_org_id ,             -- <R12 MOAC>
               'CREATE'              --<eTax Integration R12>
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

    /*
    ** Call the routine to insert the notification.
    */
   /*hvadlamu : commenting out. */
    /*po_notifications_sv1.send_po_notif (
                                       'RELEASE',
				       X_Po_Release_Id,
				       null,
				       null,
				       null,
				       null,
				       null,
				       null);  */
/* Bug# 2238744: Added the Exception part */
 EXCEPTION
    WHEN OTHERS then
      po_message_s.sql_error('INSERT_ROW',x_progress,sqlcode);
      raise;

  END Insert_Row;

END PO_RELEASES_PKG_S0;

/
