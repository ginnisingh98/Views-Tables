--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_SV11
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_SV11" as
/* $Header: POXPOH6B.pls 120.4 2007/12/18 14:43:53 ggandhi ship $ */

PROCEDURE insert_po(
                       X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Po_Header_Id            IN OUT NOCOPY NUMBER,
                       X_Agent_Id                       NUMBER,
                       X_Type_Lookup_Code               VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Segment1                IN OUT NOCOPY VARCHAR2,
                       X_Summary_Flag                   VARCHAR2,
                       X_Enabled_Flag                   VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Vendor_Contact_Id              NUMBER,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Bill_To_Location_Id            NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Ship_Via_Lookup_Code           VARCHAR2,
                       X_Fob_Lookup_Code                VARCHAR2,
                       X_Pay_On_Code                    VARCHAR2,
                       X_Freight_Terms_Lookup_Code      VARCHAR2,
                       X_Status_Lookup_Code             VARCHAR2,
                       X_Currency_Code                  VARCHAR2,
                       X_Rate_Type                      VARCHAR2,
                       X_Rate_Date                      DATE,
                       X_Rate                           NUMBER,
                       X_From_Header_Id                 NUMBER,
                       X_From_Type_Lookup_Code          VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Blanket_Total_Amount           NUMBER,
                       X_Authorization_Status           VARCHAR2,
                       X_Revision_Num                   NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                     X_Revised_Date                   VARCHAR2,
                       X_Revised_Date                   DATE,
                       X_Approved_Flag                  VARCHAR2,
                       X_Approved_Date                  DATE,
                       X_Amount_Limit                   NUMBER,
                       X_Min_Release_Amount             NUMBER,
                       X_Note_To_Authorizer             VARCHAR2,
                       X_Note_To_Vendor                 VARCHAR2,
                       X_Note_To_Receiver               VARCHAR2,
                       X_Print_Count                    NUMBER,
                       X_Printed_Date                   DATE,
                       X_Vendor_Order_Num               VARCHAR2,
                       X_Confirming_Order_Flag          VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Reply_Date                     DATE,
                       X_Reply_Method_Lookup_Code       VARCHAR2,
                       X_Rfq_Close_Date                 DATE,
                       X_Quote_Type_Lookup_Code         VARCHAR2,
                       X_Quotation_Class_Code           VARCHAR2,
                       X_Quote_Warning_Delay_Unit       VARCHAR2,
                       X_Quote_Warning_Delay            NUMBER,
                       X_Quote_Vendor_Quote_Number      VARCHAR2,
                       X_Acceptance_Required_Flag       VARCHAR2,
                       X_Acceptance_Due_Date            DATE,
                       X_Closed_Date                    DATE,
                       X_User_Hold_Flag                 VARCHAR2,
                       X_Approval_Required_Flag         VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Firm_Status_Lookup_Code        VARCHAR2,
                       X_Firm_Date                      DATE,
                       X_Frozen_Flag			VARCHAR2,
                       X_Supply_Agreement_Flag		VARCHAR2,
                       X_Global_Agreement_Flag		VARCHAR2,
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
                       X_Closed_Code                    VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Global_Attribute_Category	VARCHAR2,
                       X_Global_Attribute1		VARCHAR2,
                       X_Global_Attribute2		VARCHAR2,
                       X_Global_Attribute3		VARCHAR2,
                       X_Global_Attribute4		VARCHAR2,
                       X_Global_Attribute5		VARCHAR2,
                       X_Global_Attribute6		VARCHAR2,
                       X_Global_Attribute7		VARCHAR2,
                       X_Global_Attribute8		VARCHAR2,
                       X_Global_Attribute9		VARCHAR2,
                       X_Global_Attribute10		VARCHAR2,
                       X_Global_Attribute11		VARCHAR2,
                       X_Global_Attribute12		VARCHAR2,
                       X_Global_Attribute13    	VARCHAR2,
                       X_Global_Attribute14		VARCHAR2,
                       X_Global_Attribute15		VARCHAR2,
                       X_Global_Attribute16		VARCHAR2,
                       X_Global_Attribute17		VARCHAR2,
                       X_Global_Attribute18		VARCHAR2,
                       X_Global_Attribute19		VARCHAR2,
                       X_Global_Attribute20		VARCHAR2,
                       X_Manual                         BOOLEAN,
                       X_Price_Update_Tolerance         NUMBER,
                       p_shipping_control    IN         VARCHAR2,    -- <INBOUND LOGISTICS FPJ>
                       p_encumbrance_required_flag IN VARCHAR2 DEFAULT NULL,  --<ENCUMBRANCE FPJ>
                       p_org_id                     IN     NUMBER DEFAULT NULL,      -- <R12 MOAC>
                       p_enable_all_sites  IN VARCHAR2  --<R12GCPA>
) IS

   X_progress       		VARCHAR2(3) := '';

BEGIN

  /* Call the Insert Row Table handler */
   x_progress := '010';

   po_headers_pkg_s0.insert_row(X_Rowid                          ,
                                X_Po_Header_Id                   ,
                                X_Agent_Id                       ,
                                X_Type_Lookup_Code               ,
                                X_Last_Update_Date               ,
                                X_Last_Updated_By                ,
                                X_Segment1                       ,
                                X_Summary_Flag                   ,
                                X_Enabled_Flag                   ,
                                X_Segment2                       ,
                                X_Segment3                       ,
                                X_Segment4                       ,
                                X_Segment5                       ,
                                X_Start_Date_Active              ,
                                X_End_Date_Active                ,
                                X_Last_Update_Login              ,
                                X_Creation_Date                  ,
                                X_Created_By                     ,
                                X_Vendor_Id                      ,
                                X_Vendor_Site_Id                 ,
                                X_Vendor_Contact_Id              ,
                                X_Ship_To_Location_Id            ,
                                X_Bill_To_Location_Id            ,
                                X_Terms_Id                       ,
                                X_Ship_Via_Lookup_Code           ,
                                X_Fob_Lookup_Code                ,
                                X_Pay_On_Code                    ,
                                X_Freight_Terms_Lookup_Code      ,
                                X_Status_Lookup_Code             ,
                                X_Currency_Code                  ,
                                X_Rate_Type                      ,
                                X_Rate_Date                      ,
                                X_Rate                           ,
                                X_From_Header_Id                 ,
                                X_From_Type_Lookup_Code          ,
                                X_Start_Date                     ,
                                X_End_Date                       ,
                                X_Blanket_Total_Amount           ,
                                X_Authorization_Status           ,
                                X_Revision_Num                   ,
                                X_Revised_Date                   ,
                                X_Approved_Flag                  ,
                                X_Approved_Date                  ,
                                X_Amount_Limit                   ,
                                X_Min_Release_Amount             ,
                                X_Note_To_Authorizer             ,
                                X_Note_To_Vendor                 ,
                                X_Note_To_Receiver               ,
                                X_Print_Count                    ,
                                X_Printed_Date                   ,
                                X_Vendor_Order_Num               ,
                                X_Confirming_Order_Flag          ,
                                X_Comments                       ,
                                X_Reply_Date                     ,
                                X_Reply_Method_Lookup_Code       ,
                                X_Rfq_Close_Date                 ,
                                X_Quote_Type_Lookup_Code         ,
                                X_Quotation_Class_Code           ,
                                X_Quote_Warning_Delay_Unit       ,
                                X_Quote_Warning_Delay            ,
                                X_Quote_Vendor_Quote_Number      ,
                                X_Acceptance_Required_Flag       ,
                                X_Acceptance_Due_Date            ,
                                X_Closed_Date                    ,
                                X_User_Hold_Flag                 ,
                                X_Approval_Required_Flag         ,
                                X_Cancel_Flag                    ,
                                X_Firm_Status_Lookup_Code        ,
                                X_Firm_Date                      ,
                                X_Frozen_Flag                    ,
                                X_Global_Agreement_Flag          ,
                                X_Attribute_Category             ,
                                X_Attribute1                     ,
                                X_Attribute2                     ,
                                X_Attribute3                     ,
                                X_Attribute4                     ,
                                X_Attribute5                     ,
                                X_Attribute6                     ,
                                X_Attribute7                     ,
                                X_Attribute8                     ,
                                X_Attribute9                     ,
                                X_Attribute10                    ,
                                X_Attribute11                    ,
                                X_Attribute12                    ,
                                X_Attribute13                    ,
                                X_Attribute14                    ,
                                X_Attribute15                    ,
                                X_Closed_Code                    ,
                                NULL,  --<R12 SLA>
                                X_Government_Context             ,
                                X_Supply_Agreement_Flag          ,
                                X_Manual                         ,
                                X_Price_Update_Tolerance         ,
                                X_Global_Attribute_Category             ,
                                X_Global_Attribute1                     ,
                                X_Global_Attribute2                     ,
                                X_Global_Attribute3                     ,
                                X_Global_Attribute4                     ,
                                X_Global_Attribute5                     ,
                                X_Global_Attribute6                     ,
                                X_Global_Attribute7                     ,
                                X_Global_Attribute8                     ,
                                X_Global_Attribute9                     ,
                                X_Global_Attribute10                    ,
                                X_Global_Attribute11                    ,
                                X_Global_Attribute12                    ,
                                X_Global_Attribute13                    ,
                                X_Global_Attribute14                    ,
                                X_Global_Attribute15                    ,
                                X_Global_Attribute16                    ,
                                X_Global_Attribute17                    ,
                                X_Global_Attribute18                    ,
                                X_Global_Attribute19                    ,
                                X_Global_Attribute20                    ,
                                p_shipping_control,    -- <INBOUND LOGISTICS FPJ>
                                p_encumbrance_required_flag,  --<ENCUMBRANCE FPJ>
                                p_org_id    ,                 -- <R12 MOAC>
                                p_enable_all_sites       --<R12GCPA>
);


     x_progress := '020';

 /*  bug# 465696 8/5/97. The previous fix to this performance problem introduced
   a problem with the notifications (the bogus value used temporarily as the
   document number was being inserted into the fnd_notifications table, since
   the call below was made before we called the procedure to get the real
   document number (segment1) in the POST-FORMS-COMMIT trigger.
   Therefore, remove the call below from here and moving it to procedure
   PO_HEADERS_PKG_S0.get_real_segment1().
*/
   IF X_Manual THEN

     if (x_type_lookup_code not in ('RFQ', 'QUOTATION')) then

  /*hvadlamu : commenting out since this will be handled by workflow */

              /*po_notifications_sv1.send_po_notif (x_type_lookup_code,
	     				          x_po_header_id,
				                  null,
				                  null,
				                  null,
				                  null,
				                  null,
				                  null);*/
          null;
        elsif (x_type_lookup_code = 'RFQ') then
              /*po_notifications_sv1.send_po_notif (x_type_lookup_code,
	     				          x_po_header_id,
				                  null,
				                  X_reply_date,
				                  X_rfq_close_date,
				                  null,
				                  null,
				                  null); */
               null;
        elsif (x_type_lookup_code = 'QUOTATION') then
             /* po_notifications_sv1.send_po_notif (x_type_lookup_code,
	     				          x_po_header_id,
				                  null,
				                  (X_end_date - X_quote_warning_delay),
				                  X_end_date,
				                  null,
				                  null,
				                  null); */
               null;

     end if;

  END IF;

   exception
            when others then
            po_message_s.sql_error('insert_po', x_progress, sqlcode);
            raise;

END insert_po;

END PO_HEADERS_SV11;

/
