--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_PKG_S0
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_PKG_S0" as
/* $Header: POXP1PHB.pls 120.9.12010000.2 2010/09/06 07:05:42 smvinod ship $ */

/*===========================================================================

  PROCEDURE NAME: Insert_row()

===========================================================================*/



  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Po_Header_Id                   IN OUT NOCOPY NUMBER,
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
                       X_Frozen_Flag                    VARCHAR2,
           X_Global_Agreement_Flag    VARCHAR2,
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
                       X_Supply_Agreement_flag          VARCHAR2,
                       X_Manual                         BOOLEAN,
                       X_Price_Update_Tolerance         NUMBER,
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
                       p_encumbrance_required_flag      IN  VARCHAR2 DEFAULT NULL,  --<ENCUMBRANCE FPJ>
                       p_org_id                         IN     NUMBER DEFAULT NULL ,  -- <R12 MOAC>
                       p_enable_all_sites  IN Varchar2, --<R12GCPA>
		       p_style_id                       IN  VARCHAR2 DEFAULT NULL    --  bug 10017321
   ) IS
     CURSOR C IS SELECT rowid FROM PO_HEADERS
                 WHERE po_header_id = X_Po_Header_Id;

     CURSOR C2 IS SELECT po_headers_s.nextval FROM sys.dual;

   /* Ben: bug#465696 Locking the po_unique_identifier_control table at this
           point of the form commit cycle is causing the performance problem.
           It may take 5 to 10 seconds to commit a PO with many lines, shipments
           and distributions.
           The solution is to insert a bogus value into the SEGMENT1 column
           of po_requisition_headers ( the negative of po_requisition_header)
           then at the end of the commit cycle, i.e. the POST_FORMS-COMMIT
           trigger on the form, update the po_requisition_headers table with
           the real SEGMENT1 value from the po_unique_identifier_control table.
           The advantage of this approach is that the
           po_unique_identifier_control will be locked for only a short period
           of time.
           THEREFORE, taking the C3 cursor out of the logic here.

     CURSOR C3 IS SELECT to_char(current_max_unique_identifier + 1)
                  FROM   po_unique_identifier_control
                  WHERE  table_name =
                            decode(x_type_lookup_code,
                                  'RFQ',      'PO_HEADERS_RFQ',
                                  'QUOTATION','PO_HEADERS_QUOTE',
                                  'PO_HEADERS')
                  FOR UPDATE OF current_max_unique_identifier;
     */

    x_progress VARCHAR2(3) := NULL;

    l_document_creation_method po_headers_all.document_creation_method%type := NULL ; --<DBI FPJ>

    l_style_id                PO_DOC_STYLE_HEADERS.style_id%type; --<R12 STYLES PHASE II>

    BEGIN
     x_progress := '005';

      if (X_Po_Header_Id is NULL) then
        -- dbms_output.put_line('insert row c2');
        OPEN C2;
        FETCH C2 INTO X_Po_Header_Id;
        CLOSE C2;
      end if;

     x_progress := '010';

    /* Ben: bug#465696 Commenting this out. see explanation above
      if (X_segment1 is NULL) and not (X_manual) then
         -- dbms_output.put_line('insert row c3');
         OPEN C3;
         FETCH C3 into X_segment1;
         UPDATE po_unique_identifier_control
         SET    current_max_unique_identifier =
                current_max_unique_identifier + 1
         WHERE  CURRENT of C3;
         CLOSE C3;
      end if;
    */
      /* Ben:bug465696 Added the following IF statement.See explanation above */
      IF ((X_segment1 is NULL) and not(X_manual)) then

         X_segment1 := '-' || to_char(X_Po_Header_Id);

      END IF;

     x_progress := '015';

 -- DBI FPJ for the document types Standard,Blanket,Contract and Planned PO will have the document creation method cloumn as 'ENTER_PO'
     -- Bug 3648268. Document Creation Method values was hardcoded earlier. Now
     --              using lookup codes
     IF  X_Type_Lookup_Code in ('STANDARD','CONTRACT','BLANKET','PLANNED') THEN
       l_document_creation_method:='ENTER_PO';
     END IF;

   /* bug : 10017321 : Added p_style_id as parameter to insert_row withd default NULL value.
       Need to check if p_style_id is NULL then stamp it with standard style else use existing value.
    */
    if(p_style_id is NULL) then
        l_style_id := PO_DOC_STYLE_GRP.GET_STANDARD_DOC_STYLE; --<R12 STYLES PHASE II >
    else
        l_style_id := p_style_id;
    end if;

     -- dbms_output.put_line('insert sql');
       INSERT INTO PO_HEADERS  (
               po_header_id,
               agent_id,
               type_lookup_code,
               last_update_date,
               last_updated_by,
               segment1,
               summary_flag,
               enabled_flag,
               segment2,
               segment3,
               segment4,
               segment5,
               start_date_active,
               end_date_active,
               last_update_login,
               creation_date,
               created_by,
               vendor_id,
               vendor_site_id,
               vendor_contact_id,
               ship_to_location_id,
               bill_to_location_id,
               terms_id,
               ship_via_lookup_code,
               fob_lookup_code,
               pay_on_code,
               freight_terms_lookup_code,
               status_lookup_code,
               currency_code,
               rate_type,
               rate_date,
               rate,
               from_header_id,
               from_type_lookup_code,
               start_date,
               end_date,
               blanket_total_amount,
               authorization_status,
               revision_num,
               revised_date,
               approved_flag,
               approved_date,
               amount_limit,
               min_release_amount,
               note_to_authorizer,
               note_to_vendor,
               note_to_receiver,
               print_count,
               printed_date,
               vendor_order_num,
               confirming_order_flag,
               comments,
               reply_date,
               reply_method_lookup_code,
               rfq_close_date,
               quote_type_lookup_code,
               quotation_class_code,
               quote_warning_delay_unit,
               quote_warning_delay,
               quote_vendor_quote_number,
               acceptance_required_flag,
               acceptance_due_date,
               closed_date,
               user_hold_flag,
               approval_required_flag,
               cancel_flag,
               firm_status_lookup_code,
               firm_date,
               frozen_flag,
               global_agreement_flag,
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
               closed_code,
               government_context,
               supply_agreement_flag,
               price_update_tolerance,
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
                encumbrance_required_flag,   --<ENCUMBRANCE FPJ>
    document_creation_method, -- <DBI FPJ>
                Org_Id                   -- <R12 MOAC>
        ,style_id                 --<R12 STYLES PHASE II>
        ,created_language --<Unified Catalog R12>
        ,tax_attribute_update_code --<eTax Integration R12>
        ,enable_all_sites   --<R12GCPA>
               )
       VALUES (
               X_Po_Header_Id,
               X_Agent_Id,
               X_Type_Lookup_Code,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Segment1,
               X_Summary_Flag,
               X_Enabled_Flag,
               X_Segment2,
               X_Segment3,
               X_Segment4,
               X_Segment5,
               X_Start_Date_Active,
               X_End_Date_Active,
               X_Last_Update_Login,
               X_Creation_Date,
               X_Created_By,
               X_Vendor_Id,
               X_Vendor_Site_Id,
               X_Vendor_Contact_Id,
               X_Ship_To_Location_Id,
               X_Bill_To_Location_Id,
               X_Terms_Id,
               X_Ship_Via_Lookup_Code,
               X_Fob_Lookup_Code,
               X_Pay_On_Code,
               X_Freight_Terms_Lookup_Code,
               X_Status_Lookup_Code,
               X_Currency_Code,
               X_Rate_Type,
               X_Rate_Date,
               X_Rate,
               X_From_Header_Id,
               X_From_Type_Lookup_Code,
               X_Start_Date,
               X_End_Date,
               X_Blanket_Total_Amount,
               X_Authorization_Status,
               X_Revision_Num,
               X_Revised_Date,
               X_Approved_Flag,
               X_Approved_Date,
               X_Amount_Limit,
               X_Min_Release_Amount,
               X_Note_To_Authorizer,
               X_Note_To_Vendor,
               X_Note_To_Receiver,
               X_Print_Count,
               X_Printed_Date,
               X_Vendor_Order_Num,
               X_Confirming_Order_Flag,
               X_Comments,
               X_Reply_Date,
               X_Reply_Method_Lookup_Code,
               X_Rfq_Close_Date,
               X_Quote_Type_Lookup_Code,
               X_Quotation_Class_Code,
               X_Quote_Warning_Delay_Unit,
               X_Quote_Warning_Delay,
               X_Quote_Vendor_Quote_Number,
               X_Acceptance_Required_Flag,
               X_Acceptance_Due_Date,
               X_Closed_Date,
               X_User_Hold_Flag,
               X_Approval_Required_Flag,
               X_Cancel_Flag,
               X_Firm_Status_Lookup_Code,
               X_Firm_Date,
               X_Frozen_Flag,
               decode(X_Global_Agreement_Flag,'Y','Y',null) , -- FPI GA
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
               X_Closed_Code,
               X_Government_Context,
               X_Supply_Agreement_Flag,
               X_Price_Update_Tolerance,
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
               p_encumbrance_required_flag, -- <ENCUMBRANCE FPJ>
         l_document_creation_method, --<DBI FPJ>
               p_org_id                    -- <R12 MOAC>
              ,l_style_id                   --<R12 STYLES PHASE II>
              ,userenv('LANG') -- created_language <Unified Catalog R12>
              , decode(X_Type_Lookup_Code, 'STANDARD', 'CREATE',
                                          'PLANNED',  'CREATE', null) --<eTax Integration R12>
              ,p_enable_all_sites   --<R12 GCPA>
             );

-- dbms_output.put_line('insert sql');

    /* Bug #465696 Setting the segment1 back to NULL if using AUTOMATIC
       numbering. Otherwise, the bogus value of segment1 (see above explanation)
       will flash on the screen in front of the user.
    */
    IF NOT (X_manual) then

         X_segment1 := NULL;

    END IF;

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;


  EXCEPTION
    WHEN OTHERS then
      po_message_s.sql_error('INSERT_ROW',x_progress,sqlcode);
      raise;

 END Insert_Row;

/***************************************************************************/

PROCEDURE get_real_segment1(x_po_header_id NUMBER,
                            x_type_lookup_code VARCHAR2,
                            x_date1            DATE,
                            x_date2            DATE,
                            x_quote_warning_delay NUMBER,
                            x_segment1       IN OUT NOCOPY VARCHAR2) is


x_progress varchar2(3);

/* Ben: bug#465696 Locking the po_unique_identifier_control table at the
          beginning of the form commit cycle is causing the performance problem.
           It may take 5 to 10 seconds to commit a PO with many lines, shipments
           and distributions.
           The solution is to insert a bogus value into the SEGMENT1 column
           of po_requisition_headers ( the negative of po_header_id)
           during the ON-INSERT trigger on the PO_HEADERS,
           then at the end of the commit cycle, i.e. the POST_FORMS-COMMIT
           trigger on the form, update the po_headers table with
           the real SEGMENT1 value from the po_unique_identifier_control table.
           The advantage of this approach is that the
           po_unique_identifier_control will be locked for only a short period
           of time.

           This procedure gets called from the  POST_FORMS-COMMIT trigger
 */

X_reply_date  DATE;
X_rfq_close_date  DATE;
X_end_date        DATE;

-- bug5176308
l_unique_id_tbl_name PO_UNIQUE_IDENTIFIER_CONT_ALL.table_name%TYPE;
BEGIN


  -- bug5176308 START
  -- Call API to get the po number

  IF (x_type_lookup_code = 'RFQ') THEN
    l_unique_id_tbl_name := 'PO_HEADERS_RFQ';
  ELSIF (x_type_lookup_code = 'QUOTATION') THEN
    l_unique_id_tbl_name := 'PO_HEADERS_QUOTE';
  ELSE
    l_unique_id_tbl_name := 'PO_HEADERS';
  END IF;

  x_segment1 :=
    PO_CORE_SV1.default_po_unique_identifier
    ( x_table_name => l_unique_id_tbl_name
    );

  -- bug5176308 END

         UPDATE po_headers set segment1=x_segment1
         where po_header_id=x_po_header_id;

 /*  bug# 465696 8/5/97. The previous fix to this performance problem introduced
   a problem with the notifications (the bogus value used temporarily as the
   document number was being inserted into the fnd_notifications table, since
   the call below was made before we called the procedure to get the real
   document number (segment1) .
   Therefore, removed the call below from po_headers_sv1.insert_row and moved
   it to here.
 */

     if (x_type_lookup_code not in ('RFQ', 'QUOTATION')) then

              /*po_notifications_sv1.send_po_notif (x_type_lookup_code,
                                                  x_po_header_id,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null); */
                        null;
        elsif (x_type_lookup_code = 'RFQ') then

              X_reply_date := x_date1;
              X_rfq_close_date := x_date2;
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

              X_end_date := x_date1;
             /* po_notifications_sv1.send_po_notif (x_type_lookup_code,
                                                  x_po_header_id,
                                                  null,
                                             (X_end_date - X_quote_warning_delay
),
                                                  X_end_date,
                                                  null,
                                                  null,
                                                  null); */
            null;

     end if;

EXCEPTION
    WHEN OTHERS then
      po_message_s.sql_error('get_real_segment1',x_progress,sqlcode);
      raise;

END get_real_segment1;


END PO_HEADERS_PKG_S0;

/
