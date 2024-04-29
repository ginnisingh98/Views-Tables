--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_SV5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_SV5" as
/* $Header: POXPOH5B.pls 120.3 2007/12/18 11:44:47 ggandhi ship $*/


/*===========================================================================

  PROCEDURE NAME:	update_header()

===========================================================================*/

PROCEDURE update_header(X_Rowid                          VARCHAR2,
                        X_Po_Header_Id                   NUMBER,
                        X_Agent_Id                       NUMBER,
                        X_Type_Lookup_Code               VARCHAR2,
                        X_Last_Update_Date               DATE,
                        X_Last_Updated_By                NUMBER,
                        X_Segment1                       VARCHAR2,
                        X_Summary_Flag                   VARCHAR2,
                        X_Enabled_Flag                   VARCHAR2,
                        X_Segment2                       VARCHAR2,
                        X_Segment3                       VARCHAR2,
                        X_Segment4                       VARCHAR2,
                        X_Segment5                       VARCHAR2,
                        X_Start_Date_Active              DATE,
                        X_End_Date_Active                DATE,
                        X_Last_Update_Login              NUMBER,
                        X_Vendor_Id                      NUMBER,
                        X_Vendor_Site_Id                 NUMBER,
                        X_Vendor_Contact_Id              NUMBER,
			X_PCard_Id			 NUMBER, -- Supplier Pcard FPH
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
                        X_Authorization_Status  IN OUT NOCOPY   VARCHAR2,
                        X_Revision_Num                   NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                      X_Revised_Date                   VARCHAR2,
                        X_Revised_Date                   DATE,
                        X_Approved_Flag        IN OUT NOCOPY    VARCHAR2,
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
                        X_Supply_Agreement_Flag          VARCHAR2,
                        X_unapprove_doc           IN OUT NOCOPY BOOLEAN,
                        X_Price_Update_Tolerance         NUMBER,
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
	  	       X_Global_Attribute13    		VARCHAR2,
	  	       X_Global_Attribute14		VARCHAR2,
	  	       X_Global_Attribute15		VARCHAR2,
	  	       X_Global_Attribute16		VARCHAR2,
	  	       X_Global_Attribute17		VARCHAR2,
	  	       X_Global_Attribute18		VARCHAR2,
	  	       X_Global_Attribute19		VARCHAR2,
	  	       X_Global_Attribute20		VARCHAR2,
                       p_shipping_control         IN    VARCHAR2,    -- <INBOUND LOGISTICS FPJ>
                       p_encumbrance_required_flag IN VARCHAR2 DEFAULT NULL --<ENCUMBRANCE FPJ>
                      ,p_kterms_art_upd_date      IN   DATE   --<CONTERMS FPJ>
                      ,p_kterms_deliv_upd_date    IN   DATE  --<CONTERMS FPJ>
                      ,p_enable_all_sites IN varchar2  --<R12GCPA>
) IS

         X_progress VARCHAR2(3) := NULL;
         X_allow_delete boolean;
         x_item_type varchar2(8);
         x_item_key  varchar2(240);
         l_doc_header_id number;
         l_doc_subtype varchar2(25);

   CURSOR unapproved_releases IS
           SELECT PORH.PO_release_ID,
                  POH.Type_Lookup_Code
            FROM  PO_RELEASES PORH, PO_HEADERS POH
            WHERE NVL(PORH.authorization_status,'INCOMPLETE') IN
                     ('INCOMPLETE','REJECTED','REQUIRES REAPPROVAL')
              AND NVL(PORH.cancel_flag,'N') = 'N'
              AND NVL(PORH.closed_code,'OPEN') <> 'FINALLY CLOSED'
              AND POH.PO_HEADER_ID = PORH.PO_HEADER_ID
              AND PORH.PO_HEADER_ID = X_Po_Header_Id;

   /* FPJ CONTERMS START */
   l_contracts_document_type VARCHAR2(150);
   l_conterms_exist_flag po_headers_all.conterms_exist_flag%TYPE;
   l_vendor_id po_headers_all.vendor_id%TYPE;
   l_vendor_site_id po_headers_all.vendor_site_id%TYPE;
   l_vendor_information_updated boolean := FND_API.To_boolean(FND_API.G_FALSE);

   l_msg_data VARCHAR2(2000);
   l_msg_count NUMBER;
   l_return_status VARCHAR2(1);
   /* FPJ CONTERMS END */


BEGIN

  /* Check if the document has to be unapproved. If the header is
     already unapproved or never approved don't have to
     unapprove it  - this applies to POs and PAs */

    if ((X_type_lookup_code = 'STANDARD') or
           (X_type_lookup_code = 'PLANNED') or
           (X_type_lookup_code = 'BLANKET') or
           (X_type_lookup_code = 'CONTRACT') ) then

--       dbms_output.put_line('Checking if the doc has to be unapproved');

       X_progress := '010';

-- Bug 1287970 Amitabh

       if (X_Approved_Flag = 'Y') OR
       ( X_Authorization_Status = 'PRE-APPROVED')  THEN

            X_unapprove_doc := po_headers_sv2.val_approval_status(
                               X_po_header_id             ,
		                         X_agent_id                 ,
                               X_vendor_site_id           ,
                               X_vendor_contact_id        ,
                               X_confirming_order_flag    ,
                               X_ship_to_location_id      ,
                               X_bill_to_location_id      ,
                               X_terms_id                 ,
                               X_ship_via_lookup_code     ,
                               X_fob_lookup_code          ,
                               X_freight_terms_lookup_code ,
                               X_note_to_vendor            ,
                               X_acceptance_required_flag  ,
                               X_acceptance_due_date       ,
                               X_blanket_total_amount      ,
                               X_start_date                ,
                               X_end_date                  ,
                               X_amount_limit
                              ,p_kterms_art_upd_date --<CONTERMS FPJ>
                              ,p_kterms_deliv_upd_date --<CONTERMS FPJ>
                              , p_shipping_control  -- <INBOUND LOGISTICS FPJ>
			       );


   /* If the document has to be unapproved, set the approved_flag to be 'R' */
	/* If returning true then the document needs to be unapproved. */
   /*  Amitabh: Bug 1287970
    ** Change the status to IN PROCESS if it is PRE-APPROVED.
    */

           -- Bug 3663073: Changed IF statement logic so that if document
           -- has to be unapproved, and doc is PRE-APPROVED, then
           -- doc goes to 'IN PROCESS'.
           -- [fix for bug 1287970 does not seem to have correct logic]

           if X_unapprove_doc then

             IF (X_Authorization_Status = 'PRE-APPROVED')
             THEN
                X_Approved_Flag := 'N';
                X_Authorization_Status := 'IN PROCESS';
             ELSE
                X_Approved_Flag := 'R';
                X_Authorization_Status := 'REQUIRES REAPPROVAL';
             END IF;

           end if;

       end if;


     end if; /* End of PO/PA specific check */

      /* FPJ CONTERMS START*/
      -- call this before the update occurs
      -- SQL WHAT: select vendor information and conterms flag
      -- SQL WHY : to check if vendor info was updated on a po with terms
      -- SQL JOIN: rowid

      SELECT vendor_id, vendor_site_id, conterms_exist_flag
      INTO   l_vendor_id, l_vendor_site_id, l_conterms_exist_flag
      FROM   po_headers_all
      WHERE  rowid = X_Rowid;
      /* FPJ CONTERMS END*/

--      dbms_output.put_line('Before the Table Handler Update');
      X_progress := '020';

      po_headers_pkg_s2.update_row(
                       X_Rowid                ,
                       X_Po_Header_Id                  ,
                       X_Agent_Id                      ,
                       X_Type_Lookup_Code              ,
                       X_Last_Update_Date              ,
                       X_Last_Updated_By               ,
                       X_Segment1                      ,
                       X_Summary_Flag                  ,
                       X_Enabled_Flag                  ,
                       X_Segment2                       ,
                       X_Segment3                       ,
                       X_Segment4                       ,
                       X_Segment5                       ,
                       X_Start_Date_Active              ,
                       X_End_Date_Active                ,
                       X_Last_Update_Login              ,
                       X_Vendor_Id                      ,
                       X_Vendor_Site_Id                 ,
                       X_Vendor_Contact_Id              ,
		       X_Pcard_Id			, -- Supplier Pcard FPH
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
                       p_encumbrance_required_flag  --<ENCUMBRANCE FPJ>
                      ,p_kterms_art_upd_date --<CONTERMS FPJ>
                      ,p_kterms_deliv_upd_date --<CONTERMS FPJ>
                      ,p_enable_all_sites  --<R12GCPA>
);

      /* FPJ CONTERMS START*/

      X_progress := '025';
      IF (l_vendor_id = X_Vendor_Id) THEN
        IF (l_vendor_site_id <> X_vendor_Site_Id) THEN
         l_vendor_information_updated := FND_API.To_boolean(FND_API.G_TRUE);
        END IF;
      ELSE
        l_vendor_information_updated := FND_API.To_boolean(FND_API.G_TRUE);
      END IF;


      IF ((l_vendor_information_updated) AND
         (NVL(l_conterms_exist_flag, 'N')='Y')) THEN
          IF (X_Type_Lookup_Code IN ('BLANKET', 'CONTRACT')) THEN
           l_contracts_document_type := 'PA_'||X_Type_Lookup_Code;
          ELSIF (X_Type_Lookup_Code = 'STANDARD') THEN
           l_contracts_document_type := 'PO_'||X_Type_Lookup_Code;
          END IF;

         -- call contracts API to update the supplier information on terms
         OKC_MANAGE_DELIVERABLES_GRP.updateExtPartyOnDeliverables (
            p_api_version               => 1.0,
            p_bus_doc_id                => X_po_header_id,
            p_bus_doc_type              => l_contracts_document_type,
            p_external_party_id         => X_Vendor_Id,
            p_external_party_site_id    => X_Vendor_Site_Id,
            x_msg_data                  => l_msg_data,
            x_msg_count                 => l_msg_count,
            x_return_status             => l_return_status);

      END IF;


        /* Call routine to send notifications/update notifications */
        x_progress := '025';
        if (x_type_lookup_code not in ('RFQ', 'QUOTATION')) then
           if ((x_type_lookup_code = 'BLANKET') or (x_type_lookup_code = 'PLANNED')) then

           OPEN unapproved_releases ;
	      LOOP
                FETCH unapproved_releases
                       into l_doc_header_id,
                            l_doc_subtype;
               EXIT WHEN Unapproved_releases%NOTFOUND;

               if(l_doc_subtype = 'PLANNED') then
                  l_doc_subtype := 'SCHEDULED';
               end if;

                select wf_item_type,wf_item_key
                into   x_item_type,x_item_key
                from  po_releases
                where po_release_id = l_doc_header_id;

                  if (x_item_type is null and x_item_key is null ) then
         	      po_approval_reminder_sv.cancel_notif(l_doc_subtype,l_doc_header_id,'Y');
         	  else
	             po_approval_reminder_sv.cancel_notif(l_doc_subtype,l_doc_header_id,'Y');
        	     po_approval_reminder_sv.stop_process(x_item_type,x_item_key);
      		  end if;


              END LOOP;

           CLOSE unapproved_releases;
          else /*not blanket PO */
               /* no need to do anything in the case of a standard PO */
                null;
          end if;

             /* po_notifications_sv1.send_po_notif (x_type_lookup_code,
	     				          x_po_header_id,
				                  null,
				                  null,
				                  null,
				                  null,
				                  null,
				                  null); */
              /*hvadlamu : commenting out the send notifications call. will now be handled by workflow*/
        elsif (x_type_lookup_code = 'RFQ') then
              if (x_status_lookup_code = 'C') then

                  /* Validate if the Document can be deleted */

                  X_allow_delete := po_headers_sv1.val_delete (X_po_header_id, X_type_lookup_code);

                  /* If the doc can be deleted, */

                  if (X_allow_delete) then

                  /*  Call routine to delete PO notifications */
                     /*hvadlamu commenting out and adding the WF_engine call*/

                     /*  po_notifications_sv1.delete_po_notif (x_type_lookup_code,
			  		        x_po_header_id); */
                        null;
                  end if;
	      else

                /*  po_notifications_sv1.send_po_notif (x_type_lookup_code,
	     				          x_po_header_id,
				                  null,
				                  X_reply_date,
				                  X_rfq_close_date,
				                  null,
				                  null,
				                  null); */
                   null;
              /*hvadlamu : commenting out the send notifications call. will now be handled by workflow*/
	      end if;

        elsif (x_type_lookup_code = 'QUOTATION') then

              /*po_notifications_sv1.send_po_notif (x_type_lookup_code,
	     				          x_po_header_id,
				                  null,
				                  (X_end_date - X_quote_warning_delay),
				                  X_end_date,
				                  null,
				                  null,
				                  null); */
                 null;
              /*hvadlamu : commenting out the send notifications call. will now be handled by workflow*/

       end if;


   EXCEPTION
        when others then
             po_message_s.sql_error('update_header', X_progress, sqlcode);
             raise;

END update_header;


END PO_HEADERS_SV5;

/
