--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_PKG_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_PKG_S2" as
/* $Header: POXP3PHB.pls 120.10.12010000.2 2011/04/08 17:23:57 lswamina ship $ */

/*===========================================================================

  PROCEDURE NAME:	Update_Row()

===========================================================================*/

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
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
		       X_Pcard_Id			NUMBER, -- Supplier Pcard FPH
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
                       p_shipping_control      IN           VARCHAR2,    -- <INBOUND LOGISTICS FPJ>
                       p_encumbrance_required_flag IN VARCHAR2 DEFAULT NULL  --<ENCUMBRANCE FPJ>
                      ,p_kterms_art_upd_date   IN            DATE    -- <CONTERMS  FPJ>
                      ,p_kterms_deliv_upd_date IN            DATE    -- <CONTERMS  FPJ >
                      ,p_enable_all_sites IN varchar2  --<R12GCPA>
 ) IS

  l_tax_attribute_update_code PO_HEADERS_ALL.tax_attribute_update_code%type; --< eTax Integration R12>

 BEGIN

     --< eTax Integration R12 Start>
    IF X_Type_Lookup_Code in ('STANDARD', 'PLANNED') AND
       PO_TAX_INTERFACE_PVT.any_tax_attributes_updated(
           p_doc_type =>'PO',
           p_doc_level => 'HEADER',
           p_doc_level_id =>X_Po_Header_Id,
           p_trx_currency => X_Currency_Code,
           p_rate_type    => X_Rate_Type,
           p_rate_date    => X_Rate_Date,
           p_rate   =>X_Rate,
           p_fob    => X_Fob_Lookup_Code,
           p_vendor_id =>X_Vendor_Id,
           p_vendor_site_id=>X_Vendor_Site_Id,
           p_bill_to_loc=>X_Bill_To_Location_Id --<ECO 5524555>
        ) THEN
        l_tax_attribute_update_code := 'UPDATE';
    END IF;
    --<eTax Integration R12 End>



   UPDATE PO_HEADERS
   SET
     po_header_id                      =     X_Po_Header_Id,
     agent_id                          =     X_Agent_Id,
     type_lookup_code                  =     X_Type_Lookup_Code,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     segment1                          =     X_Segment1,
     summary_flag                      =     X_Summary_Flag,
     enabled_flag                      =     X_Enabled_Flag,
     segment2                          =     X_Segment2,
     segment3                          =     X_Segment3,
     segment4                          =     X_Segment4,
     segment5                          =     X_Segment5,
     start_date_active                 =     X_Start_Date_Active,
     end_date_active                   =     X_End_Date_Active,
     last_update_login                 =     X_Last_Update_Login,
     vendor_id                         =     X_Vendor_Id,
     vendor_site_id                    =     X_Vendor_Site_Id,
     vendor_contact_id                 =     X_Vendor_Contact_Id,
     pcard_id			       =     X_Pcard_Id, -- Supplier Pcard FPH
     ship_to_location_id               =     X_Ship_To_Location_Id,
     bill_to_location_id               =     X_Bill_To_Location_Id,
     terms_id                          =     X_Terms_Id,
     ship_via_lookup_code              =     X_Ship_Via_Lookup_Code,
     fob_lookup_code                   =     X_Fob_Lookup_Code,
     pay_on_code                       =     X_Pay_On_Code,
     freight_terms_lookup_code         =     X_Freight_Terms_Lookup_Code,
     status_lookup_code                =     X_Status_Lookup_Code,
     currency_code                     =     X_Currency_Code,
     rate_type                         =     X_Rate_Type,
     rate_date                         =     X_Rate_Date,
     rate                              =     X_Rate,
     from_header_id                    =     X_From_Header_Id,
     from_type_lookup_code             =     X_From_Type_Lookup_Code,
     start_date                        =     X_Start_Date,
     end_date                          =     X_End_Date,
     blanket_total_amount              =     X_Blanket_Total_Amount,
     authorization_status              =     X_Authorization_Status,
     revision_num                      =     X_Revision_Num,
     revised_date                      =     X_Revised_Date,
     approved_flag                     =     X_Approved_Flag,
     approved_date                     =     X_Approved_Date,
     amount_limit                      =     X_Amount_Limit,
     min_release_amount                =     X_Min_Release_Amount,
     note_to_authorizer                =     X_Note_To_Authorizer,
     note_to_vendor                    =     X_Note_To_Vendor,
     note_to_receiver                  =     X_Note_To_Receiver,
     print_count                       =     X_Print_Count,
     printed_date                      =     X_Printed_Date,
     vendor_order_num                  =     X_Vendor_Order_Num,
     confirming_order_flag             =     X_Confirming_Order_Flag,
     comments                          =     X_Comments,
     reply_date                        =     X_Reply_Date,
     reply_method_lookup_code          =     X_Reply_Method_Lookup_Code,
     rfq_close_date                    =     X_Rfq_Close_Date,
     quote_type_lookup_code            =     X_Quote_Type_Lookup_Code,
     quotation_class_code              =     X_Quotation_Class_Code,
     quote_warning_delay_unit          =     X_Quote_Warning_Delay_Unit,
     quote_warning_delay               =     X_Quote_Warning_Delay,
     quote_vendor_quote_number         =     X_Quote_Vendor_Quote_Number,
     acceptance_required_flag          =     X_Acceptance_Required_Flag,
     acceptance_due_date               =     X_Acceptance_Due_Date,
     closed_date                       =     X_Closed_Date,
     user_hold_flag                    =     X_User_Hold_Flag,
     approval_required_flag            =     X_Approval_Required_Flag,
     cancel_flag                       =     X_Cancel_Flag,
     firm_status_lookup_code           =     X_Firm_Status_Lookup_Code,
     firm_date                         =     X_Firm_Date,
     frozen_flag                       =     X_Frozen_Flag,
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
     closed_code                       =     X_Closed_Code,
     government_context                =     X_Government_Context,
     supply_agreement_flag             =     X_Supply_Agreement_Flag,
     price_update_tolerance            =     X_Price_Update_Tolerance,
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
     shipping_control                  =     p_shipping_control,    -- <INBOUND LOGISTICS FPJ>
     encumbrance_required_flag         =     p_encumbrance_required_flag --<ENCUMBRANCE FPJ>
    ,conterms_articles_upd_date        =     p_kterms_art_upd_date -- <CONTERMS FPJ>
    ,conterms_deliv_upd_date           =     p_kterms_deliv_upd_date -- <CONTERMS FPJ>
    ,tax_attribute_update_code         =     NVL(tax_attribute_update_code, --<eTax Integration R12>
                                                 l_tax_attribute_update_code)
    ,enable_all_sites                =  p_enable_all_sites  --<R12GCPA>
    WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;



  END Update_Row;

/*===========================================================================

  PROCEDURE NAME:	Delete_Row()

===========================================================================*/

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS

  BEGIN
    DELETE FROM PO_HEADERS_ALL                /*Bug6632095: using base table instead of view */
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Delete_Row;

 /*===========================================================================

  PROCEDURE NAME:	Check_Unique()

===========================================================================*/

 /* Bug 12334421 Added the paramater X_bid_number */
  FUNCTION Check_Unique(X_Segment1 In VARCHAR2, X_rowid IN VARCHAR2,
			X_Type_lookup_code IN VARCHAR2, X_bid_number IN NUMBER default NULL)
           return boolean  is
           X_Unique   boolean;
           X_non_unique_seg1   Varchar2(20);

          X_progress   varchar2(3) := '000';
          X_dummy      varchar2(40);
	--<SOURCING TO PO START>
	  x_pon_install_status  varchar2(1);
	  x_status		varchar2(10);
	--<SOURCING TO PO END>
 BEGIN
/* 824106 - SVAIDYAN: Add the condn. X_rowid is null so that it doesn't do
                      a full table scan when rowid is null */

    IF X_Type_lookup_code NOT IN ('RFQ', 'QUOTATION') THEN

        X_progress := '010';

        SELECT 'no duplicates'
        into X_dummy
        from sys.dual
        where not exists
          (SELECT 'po number is not unique'
           FROM   po_headers ph
           WHERE  ph.segment1 = X_segment1
           AND    ph.type_lookup_code IN
                  ('STANDARD','CONTRACT','BLANKET','PLANNED')
           AND (X_rowid is null or ph.rowid  <> X_rowid) );

        X_Progress := '020';

        SELECT 'no duplicates'
        into X_dummy
        from sys.dual
        where not exists
           (SELECT 'po number is not unique'
           FROM   po_history_pos ph
           WHERE  ph.segment1 = X_segment1
           AND    ph.type_lookup_code IN
                ('STANDARD','CONTRACT','BLANKET','PLANNED'));

	--<SOURCING TO PO START>
        /* Start Bug 2421680 mbhargav
	   Calling the wrapper function get_sourcing_startup to get the
	   install status of PON. The wrapper calls the po_core_s function
	   (commented below) and also checks for a profile option.
	*/

	--x_pon_install_status := po_core_s.get_product_install_status('PON');
	po_setup_s1.get_sourcing_startup(x_pon_install_status);

	/* End bug 2421680 */

        if nvl(x_pon_install_status,'N') ='I' then
	   if X_Type_lookup_code in ('STANDARD','BLANKET') then
	    /*Bug12334421 changing the parameter list of PON API, as the signature is changed now*/
	      pon_auction_po_pkg.check_unique(po_moac_utils_pvt.get_current_org_id,X_segment1,X_bid_number,x_status);  --<R12 MOAC>
	      if x_status = 'SUCCESS' then
		 X_Unique :=TRUE;
              else
		 raise no_data_found;
              end if;
           end if;
        end if;
	--<SOURCING TO PO END>

        X_Unique:= TRUE;

        return(X_Unique);

    --< Bug 3649042 Start> Merge RFQ and Quotation logic
    ELSIF  (X_Type_lookup_code IN ('RFQ','QUOTATION')) THEN

        X_progress := '050';

        SELECT 'no duplicates'
        into X_dummy
        from sys.dual
        where not exists
          (SELECT 'rfq/quote number is not unique'
           FROM   po_headers ph
           WHERE  ph.segment1 = X_segment1
           AND    ph.type_lookup_code = x_type_lookup_code
           AND (X_rowid is null or ph.rowid  <> X_rowid) );

        X_Progress := '060';

        SELECT 'no duplicates'
        into X_dummy
        from sys.dual
        where not exists
           (SELECT 'rfq/quote number is not unique'
           FROM   po_history_pos ph
           WHERE  ph.segment1 = X_segment1
           AND    ph.type_lookup_code = x_type_lookup_code);

        X_Unique:= TRUE;

        return(X_Unique);

    END IF;
    --< Bug 3649042 End >

  EXCEPTION

        WHEN NO_DATA_FOUND then
 --            po_message_s.app_error('PO_ALL_ENTER_UNIQUE_VAL');
            fnd_message.set_name('PO', 'PO_ALL_ENTER_UNIQUE_VAL');
             X_Unique:= FALSE;
             raise;
             return(X_Unique);

END Check_Unique;

/*===========================================================================

  PROCEDURE NAME:	po_total()

===========================================================================*/

FUNCTION po_total(X_po_header_id IN NUMBER)
           return number  is
           X_po_total   number := 0;

          X_progress   varchar2(3) := '000';
          X_dummy      varchar2(40);
 BEGIN
        X_progress := '010';
        SELECT  sum(nvl(pol.quantity,0) * nvl(pol.unit_price,0))
        INTO    X_po_total
        FROM    po_lines pol
        WHERE   pol.po_header_id = X_po_header_id;

        return(X_po_total);
 EXCEPTION
         WHEN NO_DATA_FOUND then
            return(X_po_total);

         WHEN OTHERS then
              X_po_total := 0;
          --   po_message_s.sql_error('po_total',X_progress);

-- Commented out due to BUG 251954 244014

              return(X_po_total);
END po_total;

END PO_HEADERS_PKG_S2;

/
