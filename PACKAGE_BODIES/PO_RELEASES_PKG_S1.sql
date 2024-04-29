--------------------------------------------------------
--  DDL for Package Body PO_RELEASES_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RELEASES_PKG_S1" as
/* $Header: POXP2PLB.pls 120.1.12010000.2 2011/07/14 08:18:13 inagdeo ship $ */

/*===========================================================================

   PROCEDURE NAME:  lock_row()

=============================================================================*/
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
                     p_shipping_control             IN    VARCHAR2    -- <INBOUND LOGISTICS FPJ>
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PO_RELEASES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Po_Release_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
/* Bug 2032728. Modified the lock row procedures for headers to compare truncated
                dates so that the time stamp is not compared as the time stamp
                was causing the problem.
*/
    if (

               (Recinfo.po_release_id = X_Po_Release_Id)
           AND (Recinfo.po_header_id = X_Po_Header_Id)
           AND (Recinfo.release_num = X_Release_Num)
           AND (Recinfo.agent_id = X_Agent_Id)
           AND (trunc(Recinfo.release_date) = trunc(X_Release_Date))
           AND (   (Recinfo.revision_num = X_Revision_Num)
                OR (    (Recinfo.revision_num IS NULL)
                    AND (X_Revision_Num IS NULL)))
           AND (   (trunc(Recinfo.revised_date) = trunc(X_Revised_Date))
                OR (    (Recinfo.revised_date IS NULL)
                    AND (X_Revised_Date IS NULL)))
           AND (   (Recinfo.approved_flag = X_Approved_Flag)
                OR (    (Recinfo.approved_flag IS NULL)
                    AND (X_Approved_Flag IS NULL)))
           AND (   (trunc(Recinfo.approved_date) = trunc(X_Approved_Date))
                OR (    (Recinfo.approved_date IS NULL)
                    AND (X_Approved_Date IS NULL)))
           AND (   (Recinfo.print_count = X_Print_Count)
                OR (    (Recinfo.print_count IS NULL)
                    AND (X_Print_Count IS NULL)))
           AND (   (trunc(Recinfo.printed_date) = trunc(X_Printed_Date))
                OR (    (Recinfo.printed_date IS NULL)
                    AND (X_Printed_Date IS NULL)))
           AND (   (Recinfo.acceptance_required_flag
                           = X_Acceptance_Required_Flag)
                OR (    (Recinfo.acceptance_required_flag IS NULL)
                    AND (X_Acceptance_Required_Flag IS NULL)))
           AND (   (trunc(Recinfo.acceptance_due_date) = trunc(X_Acceptance_Due_Date))
                OR (    (Recinfo.acceptance_due_date IS NULL)
                    AND (X_Acceptance_Due_Date IS NULL)))
           AND (   (Recinfo.hold_by = X_Hold_By)
                OR (    (Recinfo.hold_by IS NULL)
                    AND (X_Hold_By IS NULL)))
           AND (   (trunc(Recinfo.hold_date) = trunc(X_Hold_Date))
                OR (    (Recinfo.hold_date IS NULL)
                    AND (X_Hold_Date IS NULL)))
           AND (   (Recinfo.hold_reason = X_Hold_Reason)
                OR (    (Recinfo.hold_reason IS NULL)
                    AND (X_Hold_Reason IS NULL)))
           AND (   (Recinfo.hold_flag = X_Hold_Flag)
                OR (    (Recinfo.hold_flag IS NULL)
                    AND (X_Hold_Flag IS NULL)))
           AND (   (Recinfo.cancel_flag = X_Cancel_Flag)
                OR (    (Recinfo.cancel_flag IS NULL)
                    AND (X_Cancel_Flag IS NULL)))
           AND (   (Recinfo.cancelled_by = X_Cancelled_By)
                OR (    (Recinfo.cancelled_by IS NULL)
                    AND (X_Cancelled_By IS NULL)))
           AND (   (trunc(Recinfo.cancel_date) = trunc(X_Cancel_Date))
                OR (    (Recinfo.cancel_date IS NULL)
                    AND (X_Cancel_Date IS NULL)))
           AND (   (Recinfo.cancel_reason = X_Cancel_Reason)
                OR (    (Recinfo.cancel_reason IS NULL)
                    AND (X_Cancel_Reason IS NULL)))
           AND (   (Recinfo.firm_status_lookup_code
                                         = X_Firm_Status_Lookup_Code)
                OR (    (Recinfo.firm_status_lookup_code IS NULL)
                    AND (X_Firm_Status_Lookup_Code IS NULL)))
           AND (   (Recinfo.pay_on_code = X_Pay_On_Code)
                OR (    (Recinfo.pay_on_code IS NULL)
                    AND (X_Pay_On_Code IS NULL)))
           AND (   (Recinfo.attribute_category = X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 = X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 = X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 = X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 = X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 = X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 = X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 = X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 = X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 = X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 = X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 = X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 = X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 = X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 = X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 = X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.authorization_status = X_Authorization_Status)
                OR (    (Recinfo.authorization_status IS NULL)
                    AND (X_Authorization_Status IS NULL)))
           AND (   (Recinfo.government_context = X_Government_Context)
                OR (    (Recinfo.government_context IS NULL)
                    AND (X_Government_Context IS NULL)))
           AND (   (Recinfo.closed_code = X_Closed_Code)
                OR (    (Recinfo.closed_code IS NULL)
                    AND (X_Closed_Code IS NULL)))
           AND (   (Recinfo.frozen_flag = X_Frozen_Flag)
                OR (    (Recinfo.frozen_flag IS NULL)
                    AND (X_Frozen_Flag IS NULL)))
           AND (   (Recinfo.release_type = X_Release_Type)
                OR (    (Recinfo.release_type IS NULL)
                    AND (X_Release_Type IS NULL)))
           AND (   (Recinfo.global_attribute_category = X_Global_Attribute_Category)
                OR (    (Recinfo.global_attribute_category IS NULL)
                    AND (X_Global_Attribute_Category IS NULL)))
           AND (   (Recinfo.global_attribute1 = X_Global_Attribute1)
                OR (    (Recinfo.global_attribute1 IS NULL)
                    AND (X_Global_Attribute1 IS NULL)))
           AND (   (Recinfo.global_attribute2 = X_Global_Attribute2)
                OR (    (Recinfo.global_attribute2 IS NULL)
                    AND (X_Global_Attribute2 IS NULL)))
           AND (   (Recinfo.global_attribute3 = X_Global_Attribute3)
                OR (    (Recinfo.global_attribute3 IS NULL)
                    AND (X_Global_Attribute3 IS NULL)))
           AND (   (Recinfo.global_attribute4 = X_Global_Attribute4)
                OR (    (Recinfo.global_attribute4 IS NULL)
                    AND (X_Global_Attribute4 IS NULL)))
           AND (   (Recinfo.global_attribute5 = X_Global_Attribute5)
                OR (    (Recinfo.global_attribute5 IS NULL)
                    AND (X_Global_Attribute5 IS NULL)))
           AND (   (Recinfo.global_attribute6 = X_Global_Attribute6)
                OR (    (Recinfo.global_attribute6 IS NULL)
                    AND (X_Global_Attribute6 IS NULL)))
           AND (   (Recinfo.global_attribute7 = X_Global_Attribute7)
                OR (    (Recinfo.global_attribute7 IS NULL)
                    AND (X_Global_Attribute7 IS NULL)))
           AND (   (Recinfo.global_attribute8 = X_Global_Attribute8)
                OR (    (Recinfo.global_attribute8 IS NULL)
                    AND (X_Global_Attribute8 IS NULL)))
           AND (   (Recinfo.global_attribute9 = X_Global_Attribute9)
                OR (    (Recinfo.global_attribute9 IS NULL)
                    AND (X_Global_Attribute9 IS NULL)))
           AND (   (Recinfo.global_attribute10 = X_Global_Attribute10)
                OR (    (Recinfo.global_attribute10 IS NULL)
                    AND (X_Global_Attribute10 IS NULL)))
           AND (   (Recinfo.global_attribute11 = X_Global_Attribute11)
                OR (    (Recinfo.global_attribute11 IS NULL)
                    AND (X_Global_Attribute11 IS NULL)))
           AND (   (Recinfo.global_attribute12 = X_Global_Attribute12)
                OR (    (Recinfo.global_attribute12 IS NULL)
                    AND (X_Global_Attribute12 IS NULL)))
           AND (   (Recinfo.global_attribute13 = X_Global_Attribute13)
                OR (    (Recinfo.global_attribute13 IS NULL)
                    AND (X_Global_Attribute13 IS NULL)))
           AND (   (Recinfo.global_attribute14 = X_Global_Attribute14)
                OR (    (Recinfo.global_attribute14 IS NULL)
                    AND (X_Global_Attribute14 IS NULL)))
           AND (   (Recinfo.global_attribute15 = X_Global_Attribute15)
                OR (    (Recinfo.global_attribute15 IS NULL)
                    AND (X_Global_Attribute15 IS NULL)))
           AND (   (Recinfo.global_attribute16 = X_Global_Attribute16)
                OR (    (Recinfo.global_attribute16 IS NULL)
                    AND (X_Global_Attribute16 IS NULL)))
           AND (   (Recinfo.global_attribute17 = X_Global_Attribute17)
                OR (    (Recinfo.global_attribute17 IS NULL)
                    AND (X_Global_Attribute17 IS NULL)))
           AND (   (Recinfo.global_attribute18 = X_Global_Attribute18)
                OR (    (Recinfo.global_attribute18 IS NULL)
                    AND (X_Global_Attribute18 IS NULL)))
           AND (   (Recinfo.global_attribute19 = X_Global_Attribute19)
                OR (    (Recinfo.global_attribute19 IS NULL)
                    AND (X_Global_Attribute19 IS NULL)))
           AND (   (Recinfo.global_attribute20 = X_Global_Attribute20)
                OR (    (Recinfo.global_attribute20 IS NULL)
                    AND (X_Global_Attribute20 IS NULL)))
           AND (   (Recinfo.shipping_control = p_shipping_control)
                OR (    (Recinfo.shipping_control IS NULL)
                    AND (p_shipping_control IS NULL)))    -- <INBOUND LOGISTICS FPJ>
            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;

 EXCEPTION   --Bug 12373682
      WHEN app_exception.record_lock_exception THEN
          po_message_s.app_error ('PO_ALL_CANNOT_RESERVE_RECORD');
  END Lock_Row;

END PO_RELEASES_PKG_S1;

/
