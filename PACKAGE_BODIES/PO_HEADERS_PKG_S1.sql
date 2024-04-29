--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_PKG_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_PKG_S1" as
/* $Header: POXP2PHB.pls 120.2.12010000.3 2012/08/31 08:40:53 hliao ship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.PO_HEADERS_PKG_S1.';

/*===========================================================================

  PROCEDURE NAME:	Lock_Row()

===========================================================================*/

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Po_Header_Id                     NUMBER,
                     X_Agent_Id                         NUMBER,
                     X_Type_Lookup_Code                 VARCHAR2,
                     X_Segment1                         VARCHAR2,
                     X_Summary_Flag                     VARCHAR2,
                     X_Enabled_Flag                     VARCHAR2,
                     X_Segment2                         VARCHAR2,
                     X_Segment3                         VARCHAR2,
                     X_Segment4                         VARCHAR2,
                     X_Segment5                         VARCHAR2,
                     X_Start_Date_Active                DATE,
                     X_End_Date_Active                  DATE,
                     X_Vendor_Id                        NUMBER,
                     X_Vendor_Site_Id                   NUMBER,
                     X_Vendor_Contact_Id                NUMBER,
                     X_Ship_To_Location_Id              NUMBER,
                     X_Bill_To_Location_Id              NUMBER,
                     X_Terms_Id                         NUMBER,
                     X_Ship_Via_Lookup_Code             VARCHAR2,
                     X_Fob_Lookup_Code                  VARCHAR2,
                     X_Pay_On_Code                      VARCHAR2,
                     X_Freight_Terms_Lookup_Code        VARCHAR2,
                     X_Status_Lookup_Code               VARCHAR2,
                     X_Currency_Code                    VARCHAR2,
                     X_Rate_Type                        VARCHAR2,
                     X_Rate_Date                        DATE,
                     X_Rate                             NUMBER,
                     X_From_Header_Id                   NUMBER,
                     X_From_Type_Lookup_Code            VARCHAR2,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
                     X_Blanket_Total_Amount             NUMBER,
                     X_Authorization_Status             VARCHAR2,
                     X_Revision_Num                     NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                   X_Revised_Date                     VARCHAR2,
                     X_Revised_Date                     DATE,
                     X_Approved_Flag                    VARCHAR2,
                     X_Approved_Date                    DATE,
                     X_Amount_Limit                     NUMBER,
                     X_Min_Release_Amount               NUMBER,
                     X_Note_To_Authorizer               VARCHAR2,
                     X_Note_To_Vendor                   VARCHAR2,
                     X_Note_To_Receiver                 VARCHAR2,
                     X_Print_Count                      NUMBER,
                     X_Printed_Date                     DATE,
                     X_Vendor_Order_Num                 VARCHAR2,
                     X_Confirming_Order_Flag            VARCHAR2,
                     X_Comments                         VARCHAR2,
                     X_Reply_Date                       DATE,
                     X_Reply_Method_Lookup_Code         VARCHAR2,
                     X_Rfq_Close_Date                   DATE,
                     X_Quote_Type_Lookup_Code           VARCHAR2,
                     X_Quotation_Class_Code             VARCHAR2,
                     X_Quote_Warning_Delay_Unit         VARCHAR2,
                     X_Quote_Warning_Delay              NUMBER,
                     X_Quote_Vendor_Quote_Number        VARCHAR2,
                     X_Acceptance_Required_Flag         VARCHAR2,
                     X_Acceptance_Due_Date              DATE,
                     X_Closed_Date                      DATE,
                     X_User_Hold_Flag                   VARCHAR2,
                     X_Approval_Required_Flag           VARCHAR2,
                     X_Cancel_Flag                      VARCHAR2,
                     X_Firm_Status_Lookup_Code          VARCHAR2,
                     X_Firm_Date                        DATE,
                     X_Frozen_Flag                      VARCHAR2,
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
                     X_Closed_Code                      VARCHAR2,
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Government_Context               VARCHAR2,
                     X_Supply_Agreement_flag            VARCHAR2,
                     X_Global_Agreement_Flag            VARCHAR2,
                     X_Price_Update_Tolerance           NUMBER,
                     X_Global_Attribute_Category        VARCHAR2,
                     X_Global_Attribute1                VARCHAR2,
                     X_Global_Attribute2                VARCHAR2,
                     X_Global_Attribute3                VARCHAR2,
                     X_Global_Attribute4                VARCHAR2,
                     X_Global_Attribute5                VARCHAR2,
                     X_Global_Attribute6                VARCHAR2,
                     X_Global_Attribute7                VARCHAR2,
                     X_Global_Attribute8                VARCHAR2,
                     X_Global_Attribute9                VARCHAR2,
                     X_Global_Attribute10               VARCHAR2,
                     X_Global_Attribute11               VARCHAR2,
                     X_Global_Attribute12               VARCHAR2,
                     X_Global_Attribute13               VARCHAR2,
                     X_Global_Attribute14               VARCHAR2,
                     X_Global_Attribute15               VARCHAR2,
                     X_Global_Attribute16               VARCHAR2,
                     X_Global_Attribute17               VARCHAR2,
                     X_Global_Attribute18               VARCHAR2,
                     X_Global_Attribute19               VARCHAR2,
                     X_Global_Attribute20               VARCHAR2,
                     x_new_print_count       OUT NOCOPY NUMBER,
                     x_new_printed_date      OUT NOCOPY DATE,
                     p_shipping_control      IN         VARCHAR2    -- <INBOUND LOGISTICS FPJ>
                    ,p_conterms_exist_flag   IN         VARCHAR2    -- <CONTERMS FPJ>
                    ,p_encumbrance_required_flag IN VARCHAR2 --<ENCUMBRANCE FPJ>
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PO_HEADERS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Po_Header_Id NOWAIT;
    Recinfo C%ROWTYPE;
	l_api_name CONSTANT VARCHAR2(30) := 'Lock_Row';
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      IF (g_fnd_debug = 'Y') THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
            FND_LOG.string(FND_LOG.level_error, g_module_prefix || 'lock_row.000',
                         'Cursor failed with rowid = ' || nvl(x_rowid,'null'));
          END IF;
      END IF;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
/* Bug 2032728. Modified the lock row procedures for headers to compare truncated
                dates so that the time stamp is not compared as the time stamp
                was causing the problem.
*/
    if (

               (Recinfo.po_header_id = X_Po_Header_Id)
           AND (Recinfo.agent_id = X_Agent_Id)
           AND (TRIM(Recinfo.type_lookup_code) = TRIM(X_Type_Lookup_Code))
           AND (TRIM(Recinfo.segment1) = TRIM(X_Segment1))
           AND (TRIM(Recinfo.summary_flag) = TRIM(X_Summary_Flag))
           AND (TRIM(Recinfo.enabled_flag) = TRIM(X_Enabled_Flag))
           AND (   (TRIM(Recinfo.segment2) = TRIM(X_Segment2))
                OR ((TRIM(Recinfo.segment2) IS NULL)
                    AND (TRIM(X_Segment2) IS NULL)))
           AND (   (TRIM(Recinfo.segment3) =TRIM( X_Segment3))
                OR (    (TRIM(Recinfo.segment3) IS NULL)
                    AND (TRIM(X_Segment3) IS NULL)))
           AND (   (TRIM(Recinfo.segment4) = TRIM(X_Segment4))
                OR (    (TRIM(Recinfo.segment4) IS NULL)
                    AND (TRIM(X_Segment4) IS NULL)))
           AND (   (TRIM(Recinfo.segment5) = TRIM(X_Segment5))
                OR (    (TRIM(Recinfo.segment5) IS NULL)
                    AND (TRIM(X_Segment5) IS NULL)))
           AND (   (trunc(Recinfo.start_date_active) = trunc(X_Start_Date_Active))
                OR (    (Recinfo.start_date_active IS NULL)
                    AND (X_Start_Date_Active IS NULL)))
           AND (   (trunc(Recinfo.end_date_active) = trunc(X_End_Date_Active))
                OR (    (Recinfo.end_date_active IS NULL)
                    AND (X_End_Date_Active IS NULL)))
           AND (   (Recinfo.vendor_id = X_Vendor_Id)
                OR (    (Recinfo.vendor_id IS NULL)
                    AND (X_Vendor_Id IS NULL)))
           AND (   (Recinfo.vendor_site_id = X_Vendor_Site_Id)
                OR (    (Recinfo.vendor_site_id IS NULL)
                    AND (X_Vendor_Site_Id IS NULL)))
           AND (   (Recinfo.vendor_contact_id = X_Vendor_Contact_Id)
                OR (    (Recinfo.vendor_contact_id IS NULL)
                    AND (X_Vendor_Contact_Id IS NULL)))
           AND (   (Recinfo.ship_to_location_id = X_Ship_To_Location_Id)
                OR (    (Recinfo.ship_to_location_id IS NULL)
                    AND (X_Ship_To_Location_Id IS NULL)))
           AND (   (Recinfo.bill_to_location_id = X_Bill_To_Location_Id)
                OR (    (Recinfo.bill_to_location_id IS NULL)
                    AND (X_Bill_To_Location_Id IS NULL)))
           AND (   (Recinfo.terms_id = X_Terms_Id)
                OR (    (Recinfo.terms_id IS NULL)
                    AND (X_Terms_Id IS NULL)))
           AND (   (TRIM(Recinfo.ship_via_lookup_code) = TRIM(X_Ship_Via_Lookup_Code))
                OR (    (TRIM(Recinfo.ship_via_lookup_code) IS NULL)
                    AND (TRIM(X_Ship_Via_Lookup_Code) IS NULL)))
           AND (   (TRIM(Recinfo.fob_lookup_code) = TRIM(X_Fob_Lookup_Code))
                OR (    (TRIM(Recinfo.fob_lookup_code) IS NULL)
                    AND (TRIM(X_Fob_Lookup_Code) IS NULL)))
           AND (   (TRIM(Recinfo.pay_on_code) = TRIM(X_Pay_On_Code))
                OR (    (TRIM(Recinfo.pay_on_code) IS NULL)
                    AND (TRIM(X_Pay_On_Code) IS NULL)))
           AND (   (TRIM(Recinfo.freight_terms_lookup_code) = TRIM(X_Freight_Terms_Lookup_Code))
                OR (    (TRIM(Recinfo.freight_terms_lookup_code) IS NULL)
                    AND (TRIM(X_Freight_Terms_Lookup_Code) IS NULL)))
           AND (   (TRIM(Recinfo.status_lookup_code) = TRIM(X_Status_Lookup_Code))
                OR (    (TRIM(Recinfo.status_lookup_code) IS NULL)
                    AND (TRIM(X_Status_Lookup_Code) IS NULL)))
           AND (   (TRIM(Recinfo.currency_code) = TRIM(X_Currency_Code))
                OR (    (TRIM(Recinfo.currency_code) IS NULL)
                    AND (TRIM(X_Currency_Code) IS NULL)))
           AND (   (TRIM(Recinfo.rate_type) = TRIM(X_Rate_Type))
                OR (    (TRIM(Recinfo.rate_type) IS NULL)
                    AND (TRIM(X_Rate_Type) IS NULL)))
           AND (   (trunc(Recinfo.rate_date) = trunc(X_Rate_Date))
                OR (    (Recinfo.rate_date IS NULL)
                    AND (X_Rate_Date IS NULL)))
           AND (   (Recinfo.rate = X_Rate)
                OR (    (Recinfo.rate IS NULL)
                    AND (X_Rate IS NULL)))
           AND (   (Recinfo.from_header_id = X_From_Header_Id)
                OR (    (Recinfo.from_header_id IS NULL)
                    AND (X_From_Header_Id IS NULL)))
           AND (   (TRIM(Recinfo.from_type_lookup_code) = TRIM(X_From_Type_Lookup_Code))
                OR (    (TRIM(Recinfo.from_type_lookup_code) IS NULL)
                    AND (TRIM(X_From_Type_Lookup_Code) IS NULL)))
           AND (   (trunc(Recinfo.start_date) = trunc(X_Start_Date))
                OR (    (Recinfo.start_date IS NULL)
                    AND (X_Start_Date IS NULL)))
           AND (   (trunc(Recinfo.end_date) = trunc(X_End_Date))
                OR (    (Recinfo.end_date IS NULL)
                    AND (X_End_Date IS NULL)))
           AND (   (Recinfo.blanket_total_amount = X_Blanket_Total_Amount)
                OR (    (Recinfo.blanket_total_amount IS NULL)
                    AND (X_Blanket_Total_Amount IS NULL)))
           AND (   (TRIM(Recinfo.authorization_status) = TRIM(X_Authorization_Status))
                OR (    (TRIM(Recinfo.authorization_status) IS NULL)
                    AND (TRIM(X_Authorization_Status) IS NULL)))
           AND (   (Recinfo.revision_num = X_Revision_Num)
                OR (    (Recinfo.revision_num IS NULL)
                    AND (X_Revision_Num IS NULL)))
           AND (   (trunc(Recinfo.revised_date) = trunc(X_Revised_Date))
                OR (    (Recinfo.revised_date IS NULL)
                    AND (X_Revised_Date IS NULL)))
           AND (   (TRIM(Recinfo.approved_flag) = TRIM(X_Approved_Flag))
                OR (    (TRIM(Recinfo.approved_flag) IS NULL)
                    AND (TRIM(X_Approved_Flag) IS NULL)))
           AND (   (trunc(Recinfo.approved_date) = trunc(X_Approved_Date))
                OR (    (Recinfo.approved_date IS NULL)
                    AND (X_Approved_Date IS NULL)))
           AND (   (Recinfo.amount_limit = X_Amount_Limit)
                OR (    (Recinfo.amount_limit IS NULL)
                    AND (X_Amount_Limit IS NULL)))
           AND (   (Recinfo.min_release_amount = X_Min_Release_Amount)
                OR (    (Recinfo.min_release_amount IS NULL)
                    AND (X_Min_Release_Amount IS NULL)))
           AND (   (TRIM(Recinfo.note_to_authorizer) = TRIM(X_Note_To_Authorizer))
                OR (    (TRIM(Recinfo.note_to_authorizer) IS NULL)
                    AND (TRIM(X_Note_To_Authorizer) IS NULL)))
           AND (   (TRIM(Recinfo.note_to_vendor) = TRIM(X_Note_To_Vendor))
                OR (    (TRIM(Recinfo.note_to_vendor) IS NULL)
                    AND (TRIM(X_Note_To_Vendor) IS NULL)))
           AND (   (TRIM(Recinfo.note_to_receiver) = TRIM(X_Note_To_Receiver))
                OR (    (TRIM(Recinfo.note_to_receiver) IS NULL)
                    AND (TRIM(X_Note_To_Receiver) IS NULL)))
           AND (   (TRIM(Recinfo.vendor_order_num) = TRIM(X_Vendor_Order_Num))
                OR (    (TRIM(Recinfo.vendor_order_num) IS NULL)
                    AND (TRIM(X_Vendor_Order_Num) IS NULL)))
           AND (   (TRIM(Recinfo.confirming_order_flag) = TRIM(X_Confirming_Order_Flag))
                OR (    (TRIM(Recinfo.confirming_order_flag) IS NULL)
                    AND (TRIM(X_Confirming_Order_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.comments) = TRIM(X_Comments))  -- Bug 3308189
                OR (    (TRIM(Recinfo.comments) IS NULL)
                    AND (TRIM(X_Comments) IS NULL)))
           AND (   (trunc(Recinfo.reply_date) = trunc(X_Reply_Date))
                OR (    (Recinfo.reply_date IS NULL)
                    AND (X_Reply_Date IS NULL)))
           AND (   (TRIM(Recinfo.reply_method_lookup_code) = TRIM(X_Reply_Method_Lookup_Code))
                OR (    (TRIM(Recinfo.reply_method_lookup_code) IS NULL)
                    AND (TRIM(X_Reply_Method_Lookup_Code) IS NULL)))
           AND (   (TRIM(Recinfo.shipping_control) = TRIM(p_shipping_control))
                OR (    (TRIM(Recinfo.shipping_control) IS NULL)
                    AND (TRIM(p_shipping_control) IS NULL)))    -- <INBOUND LOGISTICS FPJ>
	   --<CONTERMS FPJ START>
           AND (   (TRIM(Recinfo.conterms_exist_flag) = TRIM(p_conterms_exist_flag))
                OR (    (TRIM(Recinfo.conterms_exist_flag) IS NULL)
                    AND (TRIM(p_conterms_exist_flag) IS NULL)))
	   -- <CONTERMS FPJ END>
           --<ENCUMBRANCE FPJ START>
           AND (   (TRIM(Recinfo.encumbrance_required_flag) = TRIM(p_encumbrance_required_flag))
                OR (    (TRIM(Recinfo.encumbrance_required_flag) IS NULL)
                    AND (TRIM(p_encumbrance_required_flag) IS NULL)))
           -- <ENCUMBRANCE FPJ END>
         )  then

            if (
               (   (trunc(Recinfo.rfq_close_date) = trunc(X_Rfq_Close_Date))
                OR (    (Recinfo.rfq_close_date IS NULL)
                    AND (X_Rfq_Close_Date IS NULL)))
           AND (   (TRIM(Recinfo.quote_type_lookup_code) = TRIM(X_Quote_Type_Lookup_Code))
                OR (    (TRIM(Recinfo.quote_type_lookup_code) IS NULL)
                    AND (TRIM(X_Quote_Type_Lookup_Code) IS NULL)))
           AND (   (TRIM(Recinfo.quotation_class_code) = TRIM(X_Quotation_Class_Code))
                OR (    (TRIM(Recinfo.quotation_class_code) IS NULL)
                    AND (TRIM(X_Quotation_Class_Code) IS NULL)))
           AND (   (TRIM(Recinfo.quote_warning_delay_unit) = TRIM(X_Quote_Warning_Delay_Unit))
                OR (    (TRIM(Recinfo.quote_warning_delay_unit) IS NULL)
                    AND (TRIM(X_Quote_Warning_Delay_Unit) IS NULL)))
           AND (   (Recinfo.quote_warning_delay = X_Quote_Warning_Delay)
                OR (    (Recinfo.quote_warning_delay IS NULL)
                    AND (X_Quote_Warning_Delay IS NULL)))
           AND (   (TRIM(Recinfo.quote_vendor_quote_number) = TRIM(X_Quote_Vendor_Quote_Number))
                OR (    (TRIM(Recinfo.quote_vendor_quote_number) IS NULL)
                    AND (TRIM(X_Quote_Vendor_Quote_Number) IS NULL)))
           AND (   (TRIM(Recinfo.acceptance_required_flag) = TRIM(X_Acceptance_Required_Flag))
                OR (    (TRIM(Recinfo.acceptance_required_flag) IS NULL)
                    AND (TRIM(X_Acceptance_Required_Flag) IS NULL)))
           AND (   (trunc(Recinfo.acceptance_due_date) = trunc(X_Acceptance_Due_Date))
                OR (    (Recinfo.acceptance_due_date IS NULL)
                    AND (X_Acceptance_Due_Date IS NULL)))
           AND (   (trunc(Recinfo.closed_date) = trunc(X_Closed_Date))
                OR (    (Recinfo.closed_date IS NULL)
                    AND (X_Closed_Date IS NULL)))
           AND (   (TRIM(Recinfo.user_hold_flag) = TRIM(X_User_Hold_Flag))
                OR (    (TRIM(Recinfo.user_hold_flag) IS NULL)
                    AND (TRIM(X_User_Hold_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.approval_required_flag) = TRIM(X_Approval_Required_Flag))
                OR (    (TRIM(Recinfo.approval_required_flag) IS NULL)
                    AND (TRIM(X_Approval_Required_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.cancel_flag) = TRIM(X_Cancel_Flag))
                OR (    (TRIM(Recinfo.cancel_flag) IS NULL)
                    AND (TRIM(X_Cancel_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.firm_status_lookup_code) = TRIM(X_Firm_Status_Lookup_Code))
                OR (    (TRIM(Recinfo.firm_status_lookup_code) IS NULL)
                    AND (TRIM(X_Firm_Status_Lookup_Code) IS NULL)))
           AND (   (trunc(Recinfo.firm_date) = trunc(X_Firm_Date))
                OR (    (Recinfo.firm_date IS NULL)
                    AND (X_Firm_Date IS NULL)))
           AND (   (TRIM(Recinfo.frozen_flag) = TRIM(X_Frozen_Flag))
                OR (    (TRIM(Recinfo.frozen_flag) IS NULL)
                    AND (TRIM(X_Frozen_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.attribute_category) = TRIM(X_Attribute_Category))
                OR (    (TRIM(Recinfo.attribute_category) IS NULL)
                    AND (TRIM(X_Attribute_Category) IS NULL)))
           AND (   (TRIM(Recinfo.attribute1) = TRIM(X_Attribute1))
                OR (    (TRIM(Recinfo.attribute1) IS NULL)
                    AND (TRIM(X_Attribute1) IS NULL)))
           AND (   (TRIM(Recinfo.attribute2) = TRIM(X_Attribute2))
                OR (    (TRIM(Recinfo.attribute2) IS NULL)
                    AND (TRIM(X_Attribute2) IS NULL)))
           AND (   (TRIM(Recinfo.attribute3) = TRIM(X_Attribute3))
                OR (    (TRIM(Recinfo.attribute3) IS NULL)
                    AND (TRIM(X_Attribute3) IS NULL)))
           AND (   (TRIM(Recinfo.attribute4) = TRIM(X_Attribute4))
                OR (    (TRIM(Recinfo.attribute4) IS NULL)
                    AND (TRIM(X_Attribute4) IS NULL)))
           AND (   (TRIM(Recinfo.attribute5) = TRIM(X_Attribute5))
                OR (    (TRIM(Recinfo.attribute5) IS NULL)
                    AND (TRIM(X_Attribute5) IS NULL)))
           AND (   (TRIM(Recinfo.attribute6) = TRIM(X_Attribute6))
                OR (    (TRIM(Recinfo.attribute6) IS NULL)
                    AND (TRIM(X_Attribute6) IS NULL)))
           AND (   (TRIM(Recinfo.attribute7) = TRIM(X_Attribute7))
                OR (    (TRIM(Recinfo.attribute7) IS NULL)
                    AND (TRIM(X_Attribute7) IS NULL)))
           AND (   (TRIM(Recinfo.attribute8) = TRIM(X_Attribute8))
                OR (    (TRIM(Recinfo.attribute8) IS NULL)
                    AND (TRIM(X_Attribute8) IS NULL)))
           AND (   (TRIM(Recinfo.attribute9) = TRIM(X_Attribute9))
                OR (    (TRIM(Recinfo.attribute9) IS NULL)
                    AND (TRIM(X_Attribute9) IS NULL)))
           AND (   (TRIM(Recinfo.attribute10) = TRIM(X_Attribute10))
                OR (    (TRIM(Recinfo.attribute10) IS NULL)
                    AND (TRIM(X_Attribute10) IS NULL)))
           AND (   (TRIM(Recinfo.attribute11) = TRIM(X_Attribute11))
                OR (    (TRIM(Recinfo.attribute11) IS NULL)
                    AND (TRIM(X_Attribute11) IS NULL)))
           AND (   (TRIM(Recinfo.attribute12) = TRIM(X_Attribute12))
                OR (    (TRIM(Recinfo.attribute12) IS NULL)
                    AND (TRIM(X_Attribute12) IS NULL)))
           AND (   (TRIM(Recinfo.attribute13) = TRIM(X_Attribute13))
                OR (    (TRIM(Recinfo.attribute13) IS NULL)
                    AND (TRIM(X_Attribute13) IS NULL)))
           AND (   (TRIM(Recinfo.attribute14) = TRIM(X_Attribute14))
                OR (    (TRIM(Recinfo.attribute14) IS NULL)
                    AND (TRIM(X_Attribute14) IS NULL)))
           AND (   (TRIM(Recinfo.attribute15) = TRIM(X_Attribute15))
                OR (    (TRIM(Recinfo.attribute15) IS NULL)
                    AND (TRIM(X_Attribute15) IS NULL)))
           AND (   (TRIM(Recinfo.closed_code) = TRIM(X_Closed_Code))
                OR (    (TRIM(Recinfo.closed_code) IS NULL)
                    AND (TRIM(X_Closed_Code) IS NULL)))
           AND (   (TRIM(Recinfo.government_context) = TRIM(X_Government_Context))
                OR (    (TRIM(Recinfo.government_context) IS NULL)
                    AND (TRIM(X_Government_Context) IS NULL)))
           AND (   (TRIM(Recinfo.Supply_Agreement_Flag) = TRIM(X_Supply_Agreement_Flag))
                OR (    (TRIM(Recinfo.Supply_Agreement_Flag) IS NULL)
                    AND (TRIM(X_Supply_Agreement_Flag) IS NULL)))
           AND (   (Recinfo.Price_Update_Tolerance = X_Price_Update_Tolerance)
                OR (    (Recinfo.Price_Update_Tolerance IS NULL)
                    AND (X_Price_Update_Tolerance IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute_category) = TRIM(X_Global_Attribute_Category))
                OR (    (TRIM(Recinfo.global_attribute_category) IS NULL)
                    AND (TRIM(X_Global_Attribute_Category) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute1) = TRIM(X_Global_Attribute1))
                OR (    (TRIM(Recinfo.global_attribute1) IS NULL)
                    AND (TRIM(X_Global_Attribute1) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute2) = TRIM(X_Global_Attribute2))
                OR (    (TRIM(Recinfo.global_attribute2) IS NULL)
                    AND (TRIM(X_Global_Attribute2) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute3) = TRIM(X_Global_Attribute3))
                OR (    (TRIM(Recinfo.global_attribute3) IS NULL)
                    AND (TRIM(X_Global_Attribute3) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute4) = TRIM(X_Global_Attribute4))
                OR (    (TRIM(Recinfo.global_attribute4) IS NULL)
                    AND (TRIM(X_Global_Attribute4) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute5) = TRIM(X_Global_Attribute5))
                OR (    (TRIM(Recinfo.global_attribute5) IS NULL)
                    AND (TRIM(X_Global_Attribute5) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute6) = TRIM(X_Global_Attribute6))
                OR (    (TRIM(Recinfo.global_attribute6) IS NULL)
                    AND (TRIM(X_Global_Attribute6) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute7) = TRIM(X_Global_Attribute7))
                OR (    (TRIM(Recinfo.global_attribute7) IS NULL)
                    AND (TRIM(X_Global_Attribute7) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute8) = TRIM(X_Global_Attribute8))
                OR (    (TRIM(Recinfo.global_attribute8) IS NULL)
                    AND (TRIM(X_Global_Attribute8) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute9) = TRIM(X_Global_Attribute9))
                OR (    (TRIM(Recinfo.global_attribute9) IS NULL)
                    AND (TRIM(X_Global_Attribute9) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute10) = TRIM(X_Global_Attribute10))
                OR (    (TRIM(Recinfo.global_attribute10) IS NULL)
                    AND (TRIM(X_Global_Attribute10) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute11) = TRIM(X_Global_Attribute11))
                OR (    (TRIM(Recinfo.global_attribute11) IS NULL)
                    AND (TRIM(X_Global_Attribute11) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute12) = TRIM(X_Global_Attribute12))
                OR (    (TRIM(Recinfo.global_attribute12) IS NULL)
                    AND (TRIM(X_Global_Attribute12) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute13) = TRIM(X_Global_Attribute13))
                OR (    (TRIM(Recinfo.global_attribute13) IS NULL)
                    AND (TRIM(X_Global_Attribute13) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute14) = TRIM(X_Global_Attribute14))
                OR (    (TRIM(Recinfo.global_attribute14) IS NULL)
                    AND (TRIM(X_Global_Attribute14) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute15) = TRIM(X_Global_Attribute15))
                OR (    (TRIM(Recinfo.global_attribute15) IS NULL)
                    AND (TRIM(X_Global_Attribute15) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute16)= TRIM(X_Global_Attribute16))
                OR (    (TRIM(Recinfo.global_attribute16) IS NULL)
                    AND (TRIM(X_Global_Attribute16) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute17) = TRIM(X_Global_Attribute17))
                OR (    (TRIM(Recinfo.global_attribute17) IS NULL)
                    AND (TRIM(X_Global_Attribute17) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute18) = TRIM(X_Global_Attribute18))
                OR (    (TRIM(Recinfo.global_attribute18) IS NULL)
                    AND (TRIM(X_Global_Attribute18) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute19) = TRIM(X_Global_Attribute19))
                OR (    (TRIM(Recinfo.global_attribute19) IS NULL)
                    AND (TRIM(X_Global_Attribute19) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute20) = TRIM(X_Global_Attribute20))
                OR (    (TRIM(Recinfo.global_attribute20) IS NULL)
                    AND (TRIM(X_Global_Attribute20) IS NULL)))
            ) then

        -- Bug 2701425. If print_count and printed_date are different, then
        -- update the new parameters with the values from the database.
        IF (nvl(recinfo.print_count,-99) <> nvl(x_print_count,-99)) THEN
            x_new_print_count := recinfo.print_count;
        END IF;

        IF ((TRUNC(recinfo.printed_date) <> TRUNC(x_printed_date)) OR
            (recinfo.printed_date IS NULL AND x_printed_date IS NOT NULL) OR
            (recinfo.printed_date IS NOT NULL AND x_printed_date IS NULL))
        THEN
            x_new_printed_date := recinfo.printed_date;
        END IF;

        return;
    else
		IF (g_fnd_debug = 'Y') THEN
        IF (NVL(X_Po_Header_Id,-999) <> NVL(Recinfo.po_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form po_header_id'||X_Po_Header_Id ||' Database  po_header_id '|| Recinfo.po_header_id);
        END IF;
        IF (NVL(X_Agent_Id,-999) <> NVL(Recinfo.agent_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form agent_id'||X_Agent_Id ||' Database  agent_id '|| Recinfo.agent_id);
        END IF;
        IF (NVL(TRIM(X_Type_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.type_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form type_lookup_code '||X_Type_Lookup_Code ||' Database  type_lookup_code '||Recinfo.type_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Segment1),'-999') <> NVL( TRIM(Recinfo.segment1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form segment1 '||X_Segment1 ||' Database  segment1 '||Recinfo.segment1);
        END IF;
        IF (NVL(TRIM(X_Summary_Flag),'-999') <> NVL( TRIM(Recinfo.summary_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form summary_flag '||X_Summary_Flag ||' Database  summary_flag '||Recinfo.summary_flag);
        END IF;
        IF (NVL(TRIM(X_Enabled_Flag),'-999') <> NVL( TRIM(Recinfo.enabled_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form enabled_flag '||X_Enabled_Flag ||' Database  enabled_flag '||Recinfo.enabled_flag);
        END IF;
        IF (NVL(TRIM(X_Segment2),'-999') <> NVL( TRIM(Recinfo.segment2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form segment2 '||X_Segment2 ||' Database  segment2 '||Recinfo.segment2);
        END IF;
        IF (NVL(TRIM(X_Segment3),'-999') <> NVL( TRIM(Recinfo.segment3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form segment3 '||X_Segment3 ||' Database  segment3 '||Recinfo.segment3);
        END IF;
        IF (NVL(TRIM(X_Segment4),'-999') <> NVL( TRIM(Recinfo.segment4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form segment4 '||X_Segment4 ||' Database  segment4 '||Recinfo.segment4);
        END IF;
        IF (NVL(TRIM(X_Segment5),'-999') <> NVL( TRIM(Recinfo.segment5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form segment5 '||X_Segment5 ||' Database  segment5 '||Recinfo.segment5);
        END IF;
        IF (X_Start_Date_Active <> Recinfo.start_date_active ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form start_date_active '||X_Start_Date_Active ||' Database  start_date_active '||Recinfo.start_date_active);
        END IF;
        IF (X_End_Date_Active <> Recinfo.end_date_active ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form end_date_active '||X_End_Date_Active ||' Database  end_date_active '||Recinfo.end_date_active);
        END IF;
        IF (NVL(X_Vendor_Id,-999) <> NVL(Recinfo.vendor_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form vendor_id'||X_Vendor_Id ||' Database  vendor_id '|| Recinfo.vendor_id);
        END IF;
        IF (NVL(X_Vendor_Site_Id,-999) <> NVL(Recinfo.vendor_site_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form vendor_site_id'||X_Vendor_Site_Id ||' Database  vendor_site_id '|| Recinfo.vendor_site_id);
        END IF;
        IF (NVL(X_Vendor_Contact_Id,-999) <> NVL(Recinfo.vendor_contact_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form vendor_contact_id'||X_Vendor_Contact_Id ||' Database  vendor_contact_id '|| Recinfo.vendor_contact_id);
        END IF;
        IF (NVL(X_Ship_To_Location_Id,-999) <> NVL(Recinfo.ship_to_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form ship_to_location_id'||X_Ship_To_Location_Id ||' Database  ship_to_location_id '|| Recinfo.ship_to_location_id);
        END IF;
        IF (NVL(X_Bill_To_Location_Id,-999) <> NVL(Recinfo.bill_to_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form bill_to_location_id'||X_Bill_To_Location_Id ||' Database  bill_to_location_id '|| Recinfo.bill_to_location_id);
        END IF;
        IF (NVL(X_Terms_Id,-999) <> NVL(Recinfo.terms_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form terms_id'||X_Terms_Id ||' Database  terms_id '|| Recinfo.terms_id);
        END IF;
        IF (NVL(TRIM(X_Ship_Via_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.ship_via_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form ship_via_lookup_code '||X_Ship_Via_Lookup_Code ||' Database  ship_via_lookup_code '||Recinfo.ship_via_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Fob_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.fob_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form fob_lookup_code '||X_Fob_Lookup_Code ||' Database  fob_lookup_code '||Recinfo.fob_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Pay_On_Code),'-999') <> NVL( TRIM(Recinfo.pay_on_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form pay_on_code '||X_Pay_On_Code ||' Database  pay_on_code '||Recinfo.pay_on_code);
        END IF;
        IF (NVL(TRIM(X_Freight_Terms_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.freight_terms_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form freight_terms_lookup_code '||X_Freight_Terms_Lookup_Code ||' Database  freight_terms_lookup_code '||Recinfo.freight_terms_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Status_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.status_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form status_lookup_code '||X_Status_Lookup_Code ||' Database  status_lookup_code '||Recinfo.status_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Currency_Code),'-999') <> NVL( TRIM(Recinfo.currency_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form currency_code '||X_Currency_Code ||' Database  currency_code '||Recinfo.currency_code);
        END IF;
        IF (NVL(TRIM(X_Rate_Type),'-999') <> NVL( TRIM(Recinfo.rate_type),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form rate_type '||X_Rate_Type ||' Database  rate_type '||Recinfo.rate_type);
        END IF;
        IF (X_Rate_Date <> Recinfo.rate_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form rate_date '||X_Rate_Date ||' Database  rate_date '||Recinfo.rate_date);
        END IF;
        IF (NVL(X_Rate,-999) <> NVL(Recinfo.rate,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form rate'||X_Rate ||' Database  rate '|| Recinfo.rate);
        END IF;
        IF (NVL(X_From_Header_Id,-999) <> NVL(Recinfo.from_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form from_header_id'||X_From_Header_Id ||' Database  from_header_id '|| Recinfo.from_header_id);
        END IF;
        IF (NVL(TRIM(X_From_Type_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.from_type_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form from_type_lookup_code '||X_From_Type_Lookup_Code ||' Database  from_type_lookup_code '||Recinfo.from_type_lookup_code);
        END IF;
        IF (X_Start_Date <> Recinfo.start_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form start_date '||X_Start_Date ||' Database  start_date '||Recinfo.start_date);
        END IF;
        IF (X_End_Date <> Recinfo.end_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form end_date '||X_End_Date ||' Database  end_date '||Recinfo.end_date);
        END IF;
        IF (NVL(X_Blanket_Total_Amount,-999) <> NVL(Recinfo.blanket_total_amount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form blanket_total_amount'||X_Blanket_Total_Amount ||' Database  blanket_total_amount '|| Recinfo.blanket_total_amount);
        END IF;
        IF (NVL(TRIM(X_Authorization_Status),'-999') <> NVL( TRIM(Recinfo.authorization_status),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form authorization_status '||X_Authorization_Status ||' Database  authorization_status '||Recinfo.authorization_status);
        END IF;
        IF (NVL(X_Revision_Num,-999) <> NVL(Recinfo.revision_num,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form revision_num'||X_Revision_Num ||' Database  revision_num '|| Recinfo.revision_num);
        END IF;
        IF (X_Revised_Date <> Recinfo.revised_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form revised_date '||X_Revised_Date ||' Database  revised_date '||Recinfo.revised_date);
        END IF;
        IF (NVL(TRIM(X_Approved_Flag),'-999') <> NVL( TRIM(Recinfo.approved_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form approved_flag '||X_Approved_Flag ||' Database  approved_flag '||Recinfo.approved_flag);
        END IF;
        IF (X_Approved_Date <> Recinfo.approved_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form approved_date '||X_Approved_Date ||' Database  approved_date '||Recinfo.approved_date);
        END IF;
        IF (NVL(X_Amount_Limit,-999) <> NVL(Recinfo.amount_limit,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form amount_limit'||X_Amount_Limit ||' Database  amount_limit '|| Recinfo.amount_limit);
        END IF;
        IF (NVL(X_Min_Release_Amount,-999) <> NVL(Recinfo.min_release_amount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form min_release_amount'||X_Min_Release_Amount ||' Database  min_release_amount '|| Recinfo.min_release_amount);
        END IF;
        IF (NVL(TRIM(X_Note_To_Authorizer),'-999') <> NVL( TRIM(Recinfo.note_to_authorizer),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form note_to_authorizer '||X_Note_To_Authorizer ||' Database  note_to_authorizer '||Recinfo.note_to_authorizer);
        END IF;
        IF (NVL(TRIM(X_Note_To_Vendor),'-999') <> NVL( TRIM(Recinfo.note_to_vendor),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form note_to_vendor '||X_Note_To_Vendor ||' Database  note_to_vendor '||Recinfo.note_to_vendor);
        END IF;
        IF (NVL(TRIM(X_Note_To_Receiver),'-999') <> NVL( TRIM(Recinfo.note_to_receiver),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form note_to_receiver '||X_Note_To_Receiver ||' Database  note_to_receiver '||Recinfo.note_to_receiver);
        END IF;
        IF (NVL(TRIM(X_Vendor_Order_Num),'-999') <> NVL( TRIM(Recinfo.vendor_order_num),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form vendor_order_num '||X_Vendor_Order_Num ||' Database  vendor_order_num '||Recinfo.vendor_order_num);
        END IF;
        IF (NVL(TRIM(X_Confirming_Order_Flag),'-999') <> NVL( TRIM(Recinfo.confirming_order_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form confirming_order_flag '||X_Confirming_Order_Flag ||' Database  confirming_order_flag '||Recinfo.confirming_order_flag);
        END IF;
        IF (NVL(TRIM(X_Comments),'-999') <> NVL( TRIM(Recinfo.comments),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form comments '||X_Comments ||' Database  comments '||Recinfo.comments);
        END IF;
        IF (X_Reply_Date <> Recinfo.reply_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form reply_date '||X_Reply_Date ||' Database  reply_date '||Recinfo.reply_date);
        END IF;
        IF (NVL(TRIM(X_Reply_Method_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.reply_method_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form reply_method_lookup_code '||X_Reply_Method_Lookup_Code ||' Database  reply_method_lookup_code '||Recinfo.reply_method_lookup_code);
        END IF;
        IF (X_Rfq_Close_Date <> Recinfo.rfq_close_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form rfq_close_date '||X_Rfq_Close_Date ||' Database  rfq_close_date '||Recinfo.rfq_close_date);
        END IF;
        IF (NVL(TRIM(X_Quote_Type_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.quote_type_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form quote_type_lookup_code '||X_Quote_Type_Lookup_Code ||' Database  quote_type_lookup_code '||Recinfo.quote_type_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Quotation_Class_Code),'-999') <> NVL( TRIM(Recinfo.quotation_class_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form quotation_class_code '||X_Quotation_Class_Code ||' Database  quotation_class_code '||Recinfo.quotation_class_code);
        END IF;
        IF (NVL(TRIM(X_Quote_Warning_Delay_Unit),'-999') <> NVL( TRIM(Recinfo.quote_warning_delay_unit),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form quote_warning_delay_unit '||X_Quote_Warning_Delay_Unit ||' Database  quote_warning_delay_unit '||Recinfo.quote_warning_delay_unit);
        END IF;
        IF (NVL(X_Quote_Warning_Delay,-999) <> NVL(Recinfo.quote_warning_delay,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form quote_warning_delay'||X_Quote_Warning_Delay ||' Database  quote_warning_delay '|| Recinfo.quote_warning_delay);
        END IF;
        IF (NVL(TRIM(X_Quote_Vendor_Quote_Number),'-999') <> NVL( TRIM(Recinfo.quote_vendor_quote_number),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form quote_vendor_quote_number '||X_Quote_Vendor_Quote_Number ||' Database  quote_vendor_quote_number '||Recinfo.quote_vendor_quote_number);
        END IF;
        IF (NVL(TRIM(X_Acceptance_Required_Flag),'-999') <> NVL( TRIM(Recinfo.acceptance_required_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form acceptance_required_flag '||X_Acceptance_Required_Flag ||' Database  acceptance_required_flag '||Recinfo.acceptance_required_flag);
        END IF;
        IF (X_Acceptance_Due_Date <> Recinfo.acceptance_due_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form acceptance_due_date '||X_Acceptance_Due_Date ||' Database  acceptance_due_date '||Recinfo.acceptance_due_date);
        END IF;
        IF (X_Closed_Date <> Recinfo.closed_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form closed_date '||X_Closed_Date ||' Database  closed_date '||Recinfo.closed_date);
        END IF;
        IF (NVL(TRIM(X_User_Hold_Flag),'-999') <> NVL( TRIM(Recinfo.user_hold_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form user_hold_flag '||X_User_Hold_Flag ||' Database  user_hold_flag '||Recinfo.user_hold_flag);
        END IF;
        IF (NVL(TRIM(X_Approval_Required_Flag),'-999') <> NVL( TRIM(Recinfo.approval_required_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form approval_required_flag '||X_Approval_Required_Flag ||' Database  approval_required_flag '||Recinfo.approval_required_flag);
        END IF;
        IF (NVL(TRIM(X_Cancel_Flag),'-999') <> NVL( TRIM(Recinfo.cancel_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form cancel_flag '||X_Cancel_Flag ||' Database  cancel_flag '||Recinfo.cancel_flag);
        END IF;
        IF (NVL(TRIM(X_Firm_Status_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.firm_status_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form firm_status_lookup_code '||X_Firm_Status_Lookup_Code ||' Database  firm_status_lookup_code '||Recinfo.firm_status_lookup_code);
        END IF;
        IF (X_Firm_Date <> Recinfo.firm_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form firm_date '||X_Firm_Date ||' Database  firm_date '||Recinfo.firm_date);
        END IF;
        IF (NVL(TRIM(X_Frozen_Flag),'-999') <> NVL( TRIM(Recinfo.frozen_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form frozen_flag '||X_Frozen_Flag ||' Database  frozen_flag '||Recinfo.frozen_flag);
        END IF;
        IF (NVL(TRIM(X_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute_category '||X_Attribute_Category ||' Database  attribute_category '||Recinfo.attribute_category);
        END IF;
        IF (NVL(TRIM(X_Attribute1),'-999') <> NVL( TRIM(Recinfo.attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute1 '||X_Attribute1 ||' Database  attribute1 '||Recinfo.attribute1);
        END IF;
        IF (NVL(TRIM(X_Attribute2),'-999') <> NVL( TRIM(Recinfo.attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute2 '||X_Attribute2 ||' Database  attribute2 '||Recinfo.attribute2);
        END IF;
        IF (NVL(TRIM(X_Attribute3),'-999') <> NVL( TRIM(Recinfo.attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute3 '||X_Attribute3 ||' Database  attribute3 '||Recinfo.attribute3);
        END IF;
        IF (NVL(TRIM(X_Attribute4),'-999') <> NVL( TRIM(Recinfo.attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute4 '||X_Attribute4 ||' Database  attribute4 '||Recinfo.attribute4);
        END IF;
        IF (NVL(TRIM(X_Attribute5),'-999') <> NVL( TRIM(Recinfo.attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute5 '||X_Attribute5 ||' Database  attribute5 '||Recinfo.attribute5);
        END IF;
        IF (NVL(TRIM(X_Attribute6),'-999') <> NVL( TRIM(Recinfo.attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute6 '||X_Attribute6 ||' Database  attribute6 '||Recinfo.attribute6);
        END IF;
        IF (NVL(TRIM(X_Attribute7),'-999') <> NVL( TRIM(Recinfo.attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute7 '||X_Attribute7 ||' Database  attribute7 '||Recinfo.attribute7);
        END IF;
        IF (NVL(TRIM(X_Attribute8),'-999') <> NVL( TRIM(Recinfo.attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute8 '||X_Attribute8 ||' Database  attribute8 '||Recinfo.attribute8);
        END IF;
        IF (NVL(TRIM(X_Attribute9),'-999') <> NVL( TRIM(Recinfo.attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute9 '||X_Attribute9 ||' Database  attribute9 '||Recinfo.attribute9);
        END IF;
        IF (NVL(TRIM(X_Attribute10),'-999') <> NVL( TRIM(Recinfo.attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute10 '||X_Attribute10 ||' Database  attribute10 '||Recinfo.attribute10);
        END IF;
        IF (NVL(TRIM(X_Attribute11),'-999') <> NVL( TRIM(Recinfo.attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute11 '||X_Attribute11 ||' Database  attribute11 '||Recinfo.attribute11);
        END IF;
        IF (NVL(TRIM(X_Attribute12),'-999') <> NVL( TRIM(Recinfo.attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute12 '||X_Attribute12 ||' Database  attribute12 '||Recinfo.attribute12);
        END IF;
        IF (NVL(TRIM(X_Attribute13),'-999') <> NVL( TRIM(Recinfo.attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute13 '||X_Attribute13 ||' Database  attribute13 '||Recinfo.attribute13);
        END IF;
        IF (NVL(TRIM(X_Attribute14),'-999') <> NVL( TRIM(Recinfo.attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute14 '||X_Attribute14 ||' Database  attribute14 '||Recinfo.attribute14);
        END IF;
        IF (NVL(TRIM(X_Attribute15),'-999') <> NVL( TRIM(Recinfo.attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute15 '||X_Attribute15 ||' Database  attribute15 '||Recinfo.attribute15);
        END IF;
        IF (NVL(TRIM(X_Closed_Code),'-999') <> NVL( TRIM(Recinfo.closed_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form closed_code '||X_Closed_Code ||' Database  closed_code '||Recinfo.closed_code);
        END IF;
        IF (NVL(TRIM(X_Government_Context),'-999') <> NVL( TRIM(Recinfo.government_context),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form government_context '||X_Government_Context ||' Database  government_context '||Recinfo.government_context);
        END IF;
        IF (NVL(TRIM(X_Supply_Agreement_flag),'-999') <> NVL( TRIM(Recinfo.supply_agreement_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form supply_agreement_flag '||X_Supply_Agreement_flag ||' Database  supply_agreement_flag '||Recinfo.supply_agreement_flag);
        END IF;
        IF (NVL(X_Price_Update_Tolerance,-999) <> NVL(Recinfo.price_update_tolerance,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form price_update_tolerance'||X_Price_Update_Tolerance ||' Database  price_update_tolerance '|| Recinfo.price_update_tolerance);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.global_attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute_category '||X_Global_Attribute_Category ||' Database  global_attribute_category '||Recinfo.global_attribute_category);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute1),'-999') <> NVL( TRIM(Recinfo.global_attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute1 '||X_Global_Attribute1 ||' Database  global_attribute1 '||Recinfo.global_attribute1);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute2),'-999') <> NVL( TRIM(Recinfo.global_attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute2 '||X_Global_Attribute2 ||' Database  global_attribute2 '||Recinfo.global_attribute2);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute3),'-999') <> NVL( TRIM(Recinfo.global_attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute3 '||X_Global_Attribute3 ||' Database  global_attribute3 '||Recinfo.global_attribute3);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute4),'-999') <> NVL( TRIM(Recinfo.global_attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute4 '||X_Global_Attribute4 ||' Database  global_attribute4 '||Recinfo.global_attribute4);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute5),'-999') <> NVL( TRIM(Recinfo.global_attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute5 '||X_Global_Attribute5 ||' Database  global_attribute5 '||Recinfo.global_attribute5);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute6),'-999') <> NVL( TRIM(Recinfo.global_attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute6 '||X_Global_Attribute6 ||' Database  global_attribute6 '||Recinfo.global_attribute6);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute7),'-999') <> NVL( TRIM(Recinfo.global_attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute7 '||X_Global_Attribute7 ||' Database  global_attribute7 '||Recinfo.global_attribute7);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute8),'-999') <> NVL( TRIM(Recinfo.global_attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute8 '||X_Global_Attribute8 ||' Database  global_attribute8 '||Recinfo.global_attribute8);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute9),'-999') <> NVL( TRIM(Recinfo.global_attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute9 '||X_Global_Attribute9 ||' Database  global_attribute9 '||Recinfo.global_attribute9);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute10),'-999') <> NVL( TRIM(Recinfo.global_attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute10 '||X_Global_Attribute10 ||' Database  global_attribute10 '||Recinfo.global_attribute10);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute11),'-999') <> NVL( TRIM(Recinfo.global_attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute11 '||X_Global_Attribute11 ||' Database  global_attribute11 '||Recinfo.global_attribute11);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute12),'-999') <> NVL( TRIM(Recinfo.global_attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute12 '||X_Global_Attribute12 ||' Database  global_attribute12 '||Recinfo.global_attribute12);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute13),'-999') <> NVL( TRIM(Recinfo.global_attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute13 '||X_Global_Attribute13 ||' Database  global_attribute13 '||Recinfo.global_attribute13);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute14),'-999') <> NVL( TRIM(Recinfo.global_attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute14 '||X_Global_Attribute14 ||' Database  global_attribute14 '||Recinfo.global_attribute14);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute15),'-999') <> NVL( TRIM(Recinfo.global_attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute15 '||X_Global_Attribute15 ||' Database  global_attribute15 '||Recinfo.global_attribute15);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute16),'-999') <> NVL( TRIM(Recinfo.global_attribute16),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute16 '||X_Global_Attribute16 ||' Database  global_attribute16 '||Recinfo.global_attribute16);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute17),'-999') <> NVL( TRIM(Recinfo.global_attribute17),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute17 '||X_Global_Attribute17 ||' Database  global_attribute17 '||Recinfo.global_attribute17);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute18),'-999') <> NVL( TRIM(Recinfo.global_attribute18),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute18 '||X_Global_Attribute18 ||' Database  global_attribute18 '||Recinfo.global_attribute18);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute19),'-999') <> NVL( TRIM(Recinfo.global_attribute19),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute19 '||X_Global_Attribute19 ||' Database  global_attribute19 '||Recinfo.global_attribute19);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute20),'-999') <> NVL( TRIM(Recinfo.global_attribute20),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute20 '||X_Global_Attribute20 ||' Database  global_attribute20 '||Recinfo.global_attribute20);
        END IF;
        IF (NVL(TRIM(p_shipping_control),'-999') <> NVL( TRIM(Recinfo.shipping_control),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form shipping_control '||p_shipping_control ||' Database  shipping_control '||Recinfo.shipping_control);
        END IF;
        IF (NVL(TRIM(p_conterms_exist_flag),'-999') <> NVL( TRIM(Recinfo.conterms_exist_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form conterms_exist_flag '||p_conterms_exist_flag ||' Database  conterms_exist_flag '||Recinfo.conterms_exist_flag);
        END IF;
        IF (NVL(TRIM(p_encumbrance_required_flag),'-999') <> NVL( TRIM(Recinfo.encumbrance_required_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form encumbrance_required_flag '||p_encumbrance_required_flag ||' Database  encumbrance_required_flag '||Recinfo.encumbrance_required_flag);
        END IF;
    END IF;

      IF (g_fnd_debug = 'Y') THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
            FND_LOG.string(FND_LOG.level_error, g_module_prefix || 'lock_row.010',
                         'Failed second if statement when comparing fields');
          END IF;
      END IF;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  else
		IF (g_fnd_debug = 'Y') THEN
        IF (NVL(X_Po_Header_Id,-999) <> NVL(Recinfo.po_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form po_header_id'||X_Po_Header_Id ||' Database  po_header_id '|| Recinfo.po_header_id);
        END IF;
        IF (NVL(X_Agent_Id,-999) <> NVL(Recinfo.agent_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form agent_id'||X_Agent_Id ||' Database  agent_id '|| Recinfo.agent_id);
        END IF;
        IF (NVL(TRIM(X_Type_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.type_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form type_lookup_code '||X_Type_Lookup_Code ||' Database  type_lookup_code '||Recinfo.type_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Segment1),'-999') <> NVL( TRIM(Recinfo.segment1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form segment1 '||X_Segment1 ||' Database  segment1 '||Recinfo.segment1);
        END IF;
        IF (NVL(TRIM(X_Summary_Flag),'-999') <> NVL( TRIM(Recinfo.summary_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form summary_flag '||X_Summary_Flag ||' Database  summary_flag '||Recinfo.summary_flag);
        END IF;
        IF (NVL(TRIM(X_Enabled_Flag),'-999') <> NVL( TRIM(Recinfo.enabled_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form enabled_flag '||X_Enabled_Flag ||' Database  enabled_flag '||Recinfo.enabled_flag);
        END IF;
        IF (NVL(TRIM(X_Segment2),'-999') <> NVL( TRIM(Recinfo.segment2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form segment2 '||X_Segment2 ||' Database  segment2 '||Recinfo.segment2);
        END IF;
        IF (NVL(TRIM(X_Segment3),'-999') <> NVL( TRIM(Recinfo.segment3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form segment3 '||X_Segment3 ||' Database  segment3 '||Recinfo.segment3);
        END IF;
        IF (NVL(TRIM(X_Segment4),'-999') <> NVL( TRIM(Recinfo.segment4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form segment4 '||X_Segment4 ||' Database  segment4 '||Recinfo.segment4);
        END IF;
        IF (NVL(TRIM(X_Segment5),'-999') <> NVL( TRIM(Recinfo.segment5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form segment5 '||X_Segment5 ||' Database  segment5 '||Recinfo.segment5);
        END IF;
        IF (X_Start_Date_Active <> Recinfo.start_date_active ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form start_date_active '||X_Start_Date_Active ||' Database  start_date_active '||Recinfo.start_date_active);
        END IF;
        IF (X_End_Date_Active <> Recinfo.end_date_active ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form end_date_active '||X_End_Date_Active ||' Database  end_date_active '||Recinfo.end_date_active);
        END IF;
        IF (NVL(X_Vendor_Id,-999) <> NVL(Recinfo.vendor_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form vendor_id'||X_Vendor_Id ||' Database  vendor_id '|| Recinfo.vendor_id);
        END IF;
        IF (NVL(X_Vendor_Site_Id,-999) <> NVL(Recinfo.vendor_site_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form vendor_site_id'||X_Vendor_Site_Id ||' Database  vendor_site_id '|| Recinfo.vendor_site_id);
        END IF;
        IF (NVL(X_Vendor_Contact_Id,-999) <> NVL(Recinfo.vendor_contact_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form vendor_contact_id'||X_Vendor_Contact_Id ||' Database  vendor_contact_id '|| Recinfo.vendor_contact_id);
        END IF;
        IF (NVL(X_Ship_To_Location_Id,-999) <> NVL(Recinfo.ship_to_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form ship_to_location_id'||X_Ship_To_Location_Id ||' Database  ship_to_location_id '|| Recinfo.ship_to_location_id);
        END IF;
        IF (NVL(X_Bill_To_Location_Id,-999) <> NVL(Recinfo.bill_to_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form bill_to_location_id'||X_Bill_To_Location_Id ||' Database  bill_to_location_id '|| Recinfo.bill_to_location_id);
        END IF;
        IF (NVL(X_Terms_Id,-999) <> NVL(Recinfo.terms_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form terms_id'||X_Terms_Id ||' Database  terms_id '|| Recinfo.terms_id);
        END IF;
        IF (NVL(TRIM(X_Ship_Via_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.ship_via_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form ship_via_lookup_code '||X_Ship_Via_Lookup_Code ||' Database  ship_via_lookup_code '||Recinfo.ship_via_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Fob_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.fob_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form fob_lookup_code '||X_Fob_Lookup_Code ||' Database  fob_lookup_code '||Recinfo.fob_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Pay_On_Code),'-999') <> NVL( TRIM(Recinfo.pay_on_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form pay_on_code '||X_Pay_On_Code ||' Database  pay_on_code '||Recinfo.pay_on_code);
        END IF;
        IF (NVL(TRIM(X_Freight_Terms_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.freight_terms_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form freight_terms_lookup_code '||X_Freight_Terms_Lookup_Code ||' Database  freight_terms_lookup_code '||Recinfo.freight_terms_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Status_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.status_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form status_lookup_code '||X_Status_Lookup_Code ||' Database  status_lookup_code '||Recinfo.status_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Currency_Code),'-999') <> NVL( TRIM(Recinfo.currency_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form currency_code '||X_Currency_Code ||' Database  currency_code '||Recinfo.currency_code);
        END IF;
        IF (NVL(TRIM(X_Rate_Type),'-999') <> NVL( TRIM(Recinfo.rate_type),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form rate_type '||X_Rate_Type ||' Database  rate_type '||Recinfo.rate_type);
        END IF;
        IF (X_Rate_Date <> Recinfo.rate_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form rate_date '||X_Rate_Date ||' Database  rate_date '||Recinfo.rate_date);
        END IF;
        IF (NVL(X_Rate,-999) <> NVL(Recinfo.rate,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form rate'||X_Rate ||' Database  rate '|| Recinfo.rate);
        END IF;
        IF (NVL(X_From_Header_Id,-999) <> NVL(Recinfo.from_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form from_header_id'||X_From_Header_Id ||' Database  from_header_id '|| Recinfo.from_header_id);
        END IF;
        IF (NVL(TRIM(X_From_Type_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.from_type_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form from_type_lookup_code '||X_From_Type_Lookup_Code ||' Database  from_type_lookup_code '||Recinfo.from_type_lookup_code);
        END IF;
        IF (X_Start_Date <> Recinfo.start_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form start_date '||X_Start_Date ||' Database  start_date '||Recinfo.start_date);
        END IF;
        IF (X_End_Date <> Recinfo.end_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form end_date '||X_End_Date ||' Database  end_date '||Recinfo.end_date);
        END IF;
        IF (NVL(X_Blanket_Total_Amount,-999) <> NVL(Recinfo.blanket_total_amount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form blanket_total_amount'||X_Blanket_Total_Amount ||' Database  blanket_total_amount '|| Recinfo.blanket_total_amount);
        END IF;
        IF (NVL(TRIM(X_Authorization_Status),'-999') <> NVL( TRIM(Recinfo.authorization_status),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form authorization_status '||X_Authorization_Status ||' Database  authorization_status '||Recinfo.authorization_status);
        END IF;
        IF (NVL(X_Revision_Num,-999) <> NVL(Recinfo.revision_num,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form revision_num'||X_Revision_Num ||' Database  revision_num '|| Recinfo.revision_num);
        END IF;
        IF (X_Revised_Date <> Recinfo.revised_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form revised_date '||X_Revised_Date ||' Database  revised_date '||Recinfo.revised_date);
        END IF;
        IF (NVL(TRIM(X_Approved_Flag),'-999') <> NVL( TRIM(Recinfo.approved_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form approved_flag '||X_Approved_Flag ||' Database  approved_flag '||Recinfo.approved_flag);
        END IF;
        IF (X_Approved_Date <> Recinfo.approved_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form approved_date '||X_Approved_Date ||' Database  approved_date '||Recinfo.approved_date);
        END IF;
        IF (NVL(X_Amount_Limit,-999) <> NVL(Recinfo.amount_limit,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form amount_limit'||X_Amount_Limit ||' Database  amount_limit '|| Recinfo.amount_limit);
        END IF;
        IF (NVL(X_Min_Release_Amount,-999) <> NVL(Recinfo.min_release_amount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form min_release_amount'||X_Min_Release_Amount ||' Database  min_release_amount '|| Recinfo.min_release_amount);
        END IF;
        IF (NVL(TRIM(X_Note_To_Authorizer),'-999') <> NVL( TRIM(Recinfo.note_to_authorizer),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form note_to_authorizer '||X_Note_To_Authorizer ||' Database  note_to_authorizer '||Recinfo.note_to_authorizer);
        END IF;
        IF (NVL(TRIM(X_Note_To_Vendor),'-999') <> NVL( TRIM(Recinfo.note_to_vendor),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form note_to_vendor '||X_Note_To_Vendor ||' Database  note_to_vendor '||Recinfo.note_to_vendor);
        END IF;
        IF (NVL(TRIM(X_Note_To_Receiver),'-999') <> NVL( TRIM(Recinfo.note_to_receiver),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form note_to_receiver '||X_Note_To_Receiver ||' Database  note_to_receiver '||Recinfo.note_to_receiver);
        END IF;
        IF (NVL(TRIM(X_Vendor_Order_Num),'-999') <> NVL( TRIM(Recinfo.vendor_order_num),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form vendor_order_num '||X_Vendor_Order_Num ||' Database  vendor_order_num '||Recinfo.vendor_order_num);
        END IF;
        IF (NVL(TRIM(X_Confirming_Order_Flag),'-999') <> NVL( TRIM(Recinfo.confirming_order_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form confirming_order_flag '||X_Confirming_Order_Flag ||' Database  confirming_order_flag '||Recinfo.confirming_order_flag);
        END IF;
        IF (NVL(TRIM(X_Comments),'-999') <> NVL( TRIM(Recinfo.comments),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form comments '||X_Comments ||' Database  comments '||Recinfo.comments);
        END IF;
        IF (X_Reply_Date <> Recinfo.reply_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form reply_date '||X_Reply_Date ||' Database  reply_date '||Recinfo.reply_date);
        END IF;
        IF (NVL(TRIM(X_Reply_Method_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.reply_method_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form reply_method_lookup_code '||X_Reply_Method_Lookup_Code ||' Database  reply_method_lookup_code '||Recinfo.reply_method_lookup_code);
        END IF;
        IF (X_Rfq_Close_Date <> Recinfo.rfq_close_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form rfq_close_date '||X_Rfq_Close_Date ||' Database  rfq_close_date '||Recinfo.rfq_close_date);
        END IF;
        IF (NVL(TRIM(X_Quote_Type_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.quote_type_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form quote_type_lookup_code '||X_Quote_Type_Lookup_Code ||' Database  quote_type_lookup_code '||Recinfo.quote_type_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Quotation_Class_Code),'-999') <> NVL( TRIM(Recinfo.quotation_class_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form quotation_class_code '||X_Quotation_Class_Code ||' Database  quotation_class_code '||Recinfo.quotation_class_code);
        END IF;
        IF (NVL(TRIM(X_Quote_Warning_Delay_Unit),'-999') <> NVL( TRIM(Recinfo.quote_warning_delay_unit),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form quote_warning_delay_unit '||X_Quote_Warning_Delay_Unit ||' Database  quote_warning_delay_unit '||Recinfo.quote_warning_delay_unit);
        END IF;
        IF (NVL(X_Quote_Warning_Delay,-999) <> NVL(Recinfo.quote_warning_delay,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form quote_warning_delay'||X_Quote_Warning_Delay ||' Database  quote_warning_delay '|| Recinfo.quote_warning_delay);
        END IF;
        IF (NVL(TRIM(X_Quote_Vendor_Quote_Number),'-999') <> NVL( TRIM(Recinfo.quote_vendor_quote_number),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form quote_vendor_quote_number '||X_Quote_Vendor_Quote_Number ||' Database  quote_vendor_quote_number '||Recinfo.quote_vendor_quote_number);
        END IF;
        IF (NVL(TRIM(X_Acceptance_Required_Flag),'-999') <> NVL( TRIM(Recinfo.acceptance_required_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form acceptance_required_flag '||X_Acceptance_Required_Flag ||' Database  acceptance_required_flag '||Recinfo.acceptance_required_flag);
        END IF;
        IF (X_Acceptance_Due_Date <> Recinfo.acceptance_due_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form acceptance_due_date '||X_Acceptance_Due_Date ||' Database  acceptance_due_date '||Recinfo.acceptance_due_date);
        END IF;
        IF (X_Closed_Date <> Recinfo.closed_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form closed_date '||X_Closed_Date ||' Database  closed_date '||Recinfo.closed_date);
        END IF;
        IF (NVL(TRIM(X_User_Hold_Flag),'-999') <> NVL( TRIM(Recinfo.user_hold_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form user_hold_flag '||X_User_Hold_Flag ||' Database  user_hold_flag '||Recinfo.user_hold_flag);
        END IF;
        IF (NVL(TRIM(X_Approval_Required_Flag),'-999') <> NVL( TRIM(Recinfo.approval_required_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form approval_required_flag '||X_Approval_Required_Flag ||' Database  approval_required_flag '||Recinfo.approval_required_flag);
        END IF;
        IF (NVL(TRIM(X_Cancel_Flag),'-999') <> NVL( TRIM(Recinfo.cancel_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form cancel_flag '||X_Cancel_Flag ||' Database  cancel_flag '||Recinfo.cancel_flag);
        END IF;
        IF (NVL(TRIM(X_Firm_Status_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.firm_status_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form firm_status_lookup_code '||X_Firm_Status_Lookup_Code ||' Database  firm_status_lookup_code '||Recinfo.firm_status_lookup_code);
        END IF;
        IF (X_Firm_Date <> Recinfo.firm_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form firm_date '||X_Firm_Date ||' Database  firm_date '||Recinfo.firm_date);
        END IF;
        IF (NVL(TRIM(X_Frozen_Flag),'-999') <> NVL( TRIM(Recinfo.frozen_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form frozen_flag '||X_Frozen_Flag ||' Database  frozen_flag '||Recinfo.frozen_flag);
        END IF;
        IF (NVL(TRIM(X_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute_category '||X_Attribute_Category ||' Database  attribute_category '||Recinfo.attribute_category);
        END IF;
        IF (NVL(TRIM(X_Attribute1),'-999') <> NVL( TRIM(Recinfo.attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute1 '||X_Attribute1 ||' Database  attribute1 '||Recinfo.attribute1);
        END IF;
        IF (NVL(TRIM(X_Attribute2),'-999') <> NVL( TRIM(Recinfo.attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute2 '||X_Attribute2 ||' Database  attribute2 '||Recinfo.attribute2);
        END IF;
        IF (NVL(TRIM(X_Attribute3),'-999') <> NVL( TRIM(Recinfo.attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute3 '||X_Attribute3 ||' Database  attribute3 '||Recinfo.attribute3);
        END IF;
        IF (NVL(TRIM(X_Attribute4),'-999') <> NVL( TRIM(Recinfo.attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute4 '||X_Attribute4 ||' Database  attribute4 '||Recinfo.attribute4);
        END IF;
        IF (NVL(TRIM(X_Attribute5),'-999') <> NVL( TRIM(Recinfo.attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute5 '||X_Attribute5 ||' Database  attribute5 '||Recinfo.attribute5);
        END IF;
        IF (NVL(TRIM(X_Attribute6),'-999') <> NVL( TRIM(Recinfo.attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute6 '||X_Attribute6 ||' Database  attribute6 '||Recinfo.attribute6);
        END IF;
        IF (NVL(TRIM(X_Attribute7),'-999') <> NVL( TRIM(Recinfo.attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute7 '||X_Attribute7 ||' Database  attribute7 '||Recinfo.attribute7);
        END IF;
        IF (NVL(TRIM(X_Attribute8),'-999') <> NVL( TRIM(Recinfo.attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute8 '||X_Attribute8 ||' Database  attribute8 '||Recinfo.attribute8);
        END IF;
        IF (NVL(TRIM(X_Attribute9),'-999') <> NVL( TRIM(Recinfo.attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute9 '||X_Attribute9 ||' Database  attribute9 '||Recinfo.attribute9);
        END IF;
        IF (NVL(TRIM(X_Attribute10),'-999') <> NVL( TRIM(Recinfo.attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute10 '||X_Attribute10 ||' Database  attribute10 '||Recinfo.attribute10);
        END IF;
        IF (NVL(TRIM(X_Attribute11),'-999') <> NVL( TRIM(Recinfo.attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute11 '||X_Attribute11 ||' Database  attribute11 '||Recinfo.attribute11);
        END IF;
        IF (NVL(TRIM(X_Attribute12),'-999') <> NVL( TRIM(Recinfo.attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute12 '||X_Attribute12 ||' Database  attribute12 '||Recinfo.attribute12);
        END IF;
        IF (NVL(TRIM(X_Attribute13),'-999') <> NVL( TRIM(Recinfo.attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute13 '||X_Attribute13 ||' Database  attribute13 '||Recinfo.attribute13);
        END IF;
        IF (NVL(TRIM(X_Attribute14),'-999') <> NVL( TRIM(Recinfo.attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute14 '||X_Attribute14 ||' Database  attribute14 '||Recinfo.attribute14);
        END IF;
        IF (NVL(TRIM(X_Attribute15),'-999') <> NVL( TRIM(Recinfo.attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form attribute15 '||X_Attribute15 ||' Database  attribute15 '||Recinfo.attribute15);
        END IF;
        IF (NVL(TRIM(X_Closed_Code),'-999') <> NVL( TRIM(Recinfo.closed_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form closed_code '||X_Closed_Code ||' Database  closed_code '||Recinfo.closed_code);
        END IF;
        IF (NVL(TRIM(X_Government_Context),'-999') <> NVL( TRIM(Recinfo.government_context),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form government_context '||X_Government_Context ||' Database  government_context '||Recinfo.government_context);
        END IF;
        IF (NVL(TRIM(X_Supply_Agreement_flag),'-999') <> NVL( TRIM(Recinfo.supply_agreement_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form supply_agreement_flag '||X_Supply_Agreement_flag ||' Database  supply_agreement_flag '||Recinfo.supply_agreement_flag);
        END IF;
        IF (NVL(X_Price_Update_Tolerance,-999) <> NVL(Recinfo.price_update_tolerance,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form price_update_tolerance'||X_Price_Update_Tolerance ||' Database  price_update_tolerance '|| Recinfo.price_update_tolerance);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.global_attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute_category '||X_Global_Attribute_Category ||' Database  global_attribute_category '||Recinfo.global_attribute_category);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute1),'-999') <> NVL( TRIM(Recinfo.global_attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute1 '||X_Global_Attribute1 ||' Database  global_attribute1 '||Recinfo.global_attribute1);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute2),'-999') <> NVL( TRIM(Recinfo.global_attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute2 '||X_Global_Attribute2 ||' Database  global_attribute2 '||Recinfo.global_attribute2);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute3),'-999') <> NVL( TRIM(Recinfo.global_attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute3 '||X_Global_Attribute3 ||' Database  global_attribute3 '||Recinfo.global_attribute3);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute4),'-999') <> NVL( TRIM(Recinfo.global_attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute4 '||X_Global_Attribute4 ||' Database  global_attribute4 '||Recinfo.global_attribute4);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute5),'-999') <> NVL( TRIM(Recinfo.global_attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute5 '||X_Global_Attribute5 ||' Database  global_attribute5 '||Recinfo.global_attribute5);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute6),'-999') <> NVL( TRIM(Recinfo.global_attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute6 '||X_Global_Attribute6 ||' Database  global_attribute6 '||Recinfo.global_attribute6);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute7),'-999') <> NVL( TRIM(Recinfo.global_attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute7 '||X_Global_Attribute7 ||' Database  global_attribute7 '||Recinfo.global_attribute7);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute8),'-999') <> NVL( TRIM(Recinfo.global_attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute8 '||X_Global_Attribute8 ||' Database  global_attribute8 '||Recinfo.global_attribute8);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute9),'-999') <> NVL( TRIM(Recinfo.global_attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute9 '||X_Global_Attribute9 ||' Database  global_attribute9 '||Recinfo.global_attribute9);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute10),'-999') <> NVL( TRIM(Recinfo.global_attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute10 '||X_Global_Attribute10 ||' Database  global_attribute10 '||Recinfo.global_attribute10);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute11),'-999') <> NVL( TRIM(Recinfo.global_attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute11 '||X_Global_Attribute11 ||' Database  global_attribute11 '||Recinfo.global_attribute11);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute12),'-999') <> NVL( TRIM(Recinfo.global_attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute12 '||X_Global_Attribute12 ||' Database  global_attribute12 '||Recinfo.global_attribute12);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute13),'-999') <> NVL( TRIM(Recinfo.global_attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute13 '||X_Global_Attribute13 ||' Database  global_attribute13 '||Recinfo.global_attribute13);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute14),'-999') <> NVL( TRIM(Recinfo.global_attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute14 '||X_Global_Attribute14 ||' Database  global_attribute14 '||Recinfo.global_attribute14);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute15),'-999') <> NVL( TRIM(Recinfo.global_attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute15 '||X_Global_Attribute15 ||' Database  global_attribute15 '||Recinfo.global_attribute15);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute16),'-999') <> NVL( TRIM(Recinfo.global_attribute16),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute16 '||X_Global_Attribute16 ||' Database  global_attribute16 '||Recinfo.global_attribute16);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute17),'-999') <> NVL( TRIM(Recinfo.global_attribute17),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute17 '||X_Global_Attribute17 ||' Database  global_attribute17 '||Recinfo.global_attribute17);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute18),'-999') <> NVL( TRIM(Recinfo.global_attribute18),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute18 '||X_Global_Attribute18 ||' Database  global_attribute18 '||Recinfo.global_attribute18);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute19),'-999') <> NVL( TRIM(Recinfo.global_attribute19),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute19 '||X_Global_Attribute19 ||' Database  global_attribute19 '||Recinfo.global_attribute19);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute20),'-999') <> NVL( TRIM(Recinfo.global_attribute20),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form global_attribute20 '||X_Global_Attribute20 ||' Database  global_attribute20 '||Recinfo.global_attribute20);
        END IF;
        IF (NVL(TRIM(p_shipping_control),'-999') <> NVL( TRIM(Recinfo.shipping_control),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form shipping_control '||p_shipping_control ||' Database  shipping_control '||Recinfo.shipping_control);
        END IF;
        IF (NVL(TRIM(p_conterms_exist_flag),'-999') <> NVL( TRIM(Recinfo.conterms_exist_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form conterms_exist_flag '||p_conterms_exist_flag ||' Database  conterms_exist_flag '||Recinfo.conterms_exist_flag);
        END IF;
        IF (NVL(TRIM(p_encumbrance_required_flag),'-999') <> NVL( TRIM(Recinfo.encumbrance_required_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,g_module_prefix || l_api_name,' Form encumbrance_required_flag '||p_encumbrance_required_flag ||' Database  encumbrance_required_flag '||Recinfo.encumbrance_required_flag);
        END IF;
		END IF;

      IF (g_fnd_debug = 'Y') THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
            FND_LOG.string(FND_LOG.level_error, g_module_prefix || 'lock_row.020',
                         'Failed first if statement when comparing fields');
          END IF;
      END IF;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;

  end if;

 EXCEPTION   --Bug 12373682
      WHEN app_exception.record_lock_exception THEN
          po_message_s.app_error ('PO_ALL_CANNOT_RESERVE_RECORD');

  END Lock_Row;

END PO_HEADERS_PKG_S1;

/
