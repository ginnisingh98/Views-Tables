--------------------------------------------------------
--  DDL for Package Body AP_VENDOR_SITES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_VENDOR_SITES_PKG" as
/* $Header: apvndsib.pls 120.19.12010000.8 2010/04/21 22:11:42 wjharris ship $ */
--
--
function format_address(	country_code varchar2,
				seg1 varchar2,
			 	seg2 varchar2,
				seg3 varchar2,
				seg4 varchar2,
			        seg5 varchar2,
				seg6 varchar2,
				seg7 varchar2,
				seg8 varchar2,
				seg9 varchar2,
				seg10 varchar2 ) return varchar2 is

address varchar2(1000);
begin
	if (seg1 is not NULL ) then
		address := address||seg1;
	end if;

	if (seg2 is not NULL ) then
		address := address||', '||seg2;
	end if;

	if (seg3 is not NULL ) then
		address :=address||', '||seg3;
	end if;

	if (seg4 is not NULL ) then
		address :=address||', '||seg4;
	end if;

	if (seg5 is not NULL ) then
		address :=address||', '||seg5;
	end if;

	if (seg6 is not NULL ) then
		address :=address||', '||seg6;
	end if;

	if (seg7 is not NULL ) then
		address :=address||', '||seg7;
	end if;

	if (seg8 is not NULL ) then
		address :=address||', '||seg8;
	end if;

	if (seg9 is not NULL ) then
		address :=address||', '||seg9;
	end if;

	if (seg10 is not NULL ) then
		address :=address||', '||seg10;
	end if;

        return(address);

end format_address;


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Vendor_Site_Id          IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Code        IN OUT NOCOPY VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Purchasing_Site_Flag           VARCHAR2,
                       X_Rfq_Only_Site_Flag             VARCHAR2,
                       X_Pay_Site_Flag                  VARCHAR2,
                       X_Attention_Ar_Flag              VARCHAR2,
                       X_Address_Line1                  VARCHAR2,
                       X_Address_Line2                  VARCHAR2,
                       X_Address_Line3                  VARCHAR2,
                       X_City                           VARCHAR2,
                       X_State                          VARCHAR2,
                       X_Zip                            VARCHAR2,
                       X_Province                       VARCHAR2,
                       X_Country                        VARCHAR2,
                       X_Area_Code                      VARCHAR2,
                       X_Phone                          VARCHAR2,
                       X_Customer_Num                   VARCHAR2,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Bill_To_Location_Id            NUMBER,
                       X_Ship_Via_Lookup_Code           VARCHAR2,
                       X_Freight_Terms_Lookup_Code      VARCHAR2,
                       X_Fob_Lookup_Code                VARCHAR2,
                       X_Inactive_Date                  DATE,
                       X_Fax                            VARCHAR2,
                       X_Fax_Area_Code                  VARCHAR2,
                       X_Telex                          VARCHAR2,
                       --4552701 X_Payment_Method_Lookup_Code     VARCHAR2,
                       X_Bank_Account_Name              VARCHAR2,
                       X_Bank_Account_Num               VARCHAR2,
                       X_Bank_Num                       VARCHAR2,
                       X_Bank_Account_Type              VARCHAR2,
                       X_Terms_Date_Basis               VARCHAR2,
                       X_Current_Catalog_Num            VARCHAR2,
                       -- eTax Uptake X_Vat_Code        VARCHAR2,
                       X_Distribution_Set_Id            NUMBER,
                       X_Accts_Pay_CCID		        NUMBER,
                       X_Future_Dated_Payment_CCID	NUMBER,
                       X_Prepay_Code_Combination_Id     NUMBER,
                       X_Pay_Group_Lookup_Code          VARCHAR2,
                       X_Payment_Priority               NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Invoice_Amount_Limit           NUMBER,
                       X_Pay_Date_Basis_Lookup_Code     VARCHAR2,
                       X_Always_Take_Disc_Flag          VARCHAR2,
                       X_Invoice_Currency_Code          VARCHAR2,
                       X_Payment_Currency_Code          VARCHAR2,
                       X_Hold_All_Payments_Flag         VARCHAR2,
                       X_Hold_Future_Payments_Flag      VARCHAR2,
                       X_Hold_Reason                    VARCHAR2,
                       X_Hold_Unmatched_Invoices_Flag   VARCHAR2,
                       X_Match_Option			VARCHAR2,
		       X_Create_Debit_Memo_Flag		VARCHAR2,
                       --4552701 X_Exclusive_Payment_Flag         VARCHAR2,
                       X_Tax_Reporting_Site_Flag        VARCHAR2,
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
                       X_Validation_Number              NUMBER,
                       X_Exclude_Freight_From_Disc      VARCHAR2,
                       X_Vat_Registration_Num           VARCHAR2,
                       -- eTax Uptake X_Offset_Tax_Flag VARCHAR2,
                       X_Check_Digits                   VARCHAR2,
                       X_Bank_Number                    VARCHAR2,
                       X_Address_Line4                  VARCHAR2,
                       X_County                         VARCHAR2,
                       X_Address_Style                  VARCHAR2,
                       X_Language                       VARCHAR2,
                       X_Allow_Awt_Flag                 VARCHAR2,
                       X_Awt_Group_Id                   NUMBER,
                       X_Pay_Awt_Group_Id                   NUMBER,--bug6664407
		       X_pay_on_code			VARCHAR2,
		       X_default_pay_site_id		NUMBER,
		       X_pay_on_receipt_summary_code	VARCHAR2,
		       X_Bank_Branch_Type		VARCHAR2,
		       X_EDI_ID_Number                  VARCHAR2, --Bug 7437549
		       /* 4552701
                       X_EDI_ID_Number			VARCHAR2,
		       X_EDI_Payment_Method		VARCHAR2,
		       X_EDI_Payment_Format		VARCHAR2,
		       X_EDI_Remittance_Method		VARCHAR2,
		       X_EDI_Remittance_Instruction	VARCHAR2,
		       X_EDI_transaction_handling	VARCHAR2,
                       eTax Uptake
		       X_Auto_Tax_Calc_Flag		VARCHAR2,
		       X_Auto_Tax_Calc_Override		VARCHAR2,
		       X_Amount_Includes_Tax_Flag	VARCHAR2,
		       X_AP_Tax_Rounding_Rule		VARCHAR2, */
		       X_Vendor_Site_Code_Alt		VARCHAR2,
		       X_Address_Lines_Alt		VARCHAR2,
                       X_global_attribute_category      VARCHAR2 DEFAULT NULL,
                       X_global_attribute1              VARCHAR2 DEFAULT NULL,
                       X_global_attribute2              VARCHAR2 DEFAULT NULL,
                       X_global_attribute3              VARCHAR2 DEFAULT NULL,
                       X_global_attribute4              VARCHAR2 DEFAULT NULL,
                       X_global_attribute5              VARCHAR2 DEFAULT NULL,
                       X_global_attribute6              VARCHAR2 DEFAULT NULL,
                       X_global_attribute7              VARCHAR2 DEFAULT NULL,
                       X_global_attribute8              VARCHAR2 DEFAULT NULL,
                       X_global_attribute9              VARCHAR2 DEFAULT NULL,
                       X_global_attribute10             VARCHAR2 DEFAULT NULL,
                       X_global_attribute11             VARCHAR2 DEFAULT NULL,
                       X_global_attribute12             VARCHAR2 DEFAULT NULL,
                       X_global_attribute13             VARCHAR2 DEFAULT NULL,
                       X_global_attribute14             VARCHAR2 DEFAULT NULL,
                       X_global_attribute15             VARCHAR2 DEFAULT NULL,
                       X_global_attribute16             VARCHAR2 DEFAULT NULL,
                       X_global_attribute17             VARCHAR2 DEFAULT NULL,
                       X_global_attribute18             VARCHAR2 DEFAULT NULL,
                       X_global_attribute19             VARCHAR2 DEFAULT NULL,
                       X_global_attribute20             VARCHAR2 DEFAULT NULL,
		       X_Bank_Charge_Bearer	  	VARCHAR2 DEFAULT NULL,
                       X_Ece_Tp_Location_Code           VARCHAR2 DEFAULT NULL,
		       X_Pcard_Site_Flag		VARCHAR2,
		       X_Country_of_Origin_Code		VARCHAR2,
		       X_calling_sequence	IN	VARCHAR2,
		       X_Shipping_Location_id	IN	NUMBER,
		       X_Supplier_Notif_Method          VARCHAR2, -- New Column
                       X_Email_Address                  VARCHAR2, -- New Column
                       --4552701 X_Remittance_email               VARCHAR2 DEFAULT NULL,
                       X_Primary_pay_site_flag          VARCHAR2 DEFAULT NULL,
		       --MO Access Control
		       X_Org_ID				NUMBER  DEFAULT mo_global.get_current_org_id
  		       ) IS

    CURSOR C IS	 SELECT rowid
		 FROM po_vendor_sites
                 WHERE  vendor_site_id  = X_vendor_site_id;
    current_calling_sequence             varchar2(2000);
    debug_info                           varchar2(100);


   BEGIN
--      Update the calling sequence
--
        current_calling_sequence := 'AP_VENDOR_SITES_PKG.INSERT_ROW<-' ||
                                     X_calling_sequence;

	Check_duplicate_vendor_site 	(x_vendor_id, x_vendor_site_code,
					 x_org_id,   --MO Access Control
					 x_rowid,
					 X_calling_sequence => current_calling_sequence);

	if (x_tax_reporting_site_flag = 'Y') then
		check_multiple_tax_sites 	(x_vendor_id, x_vendor_site_id,
						 x_org_id, --MO Access Control
					X_calling_sequence => current_calling_sequence);
	end if;


--      Global Supplier Sites: We need to check if there exists a site for
--      this vendor (same vendor_id) with the exact same vendor_site_code in
--	any other org (it will be in other orgs only because we do not allow
--	duplicate vendor_site_codes in the same org) . If yes, then we
--      use the same vendor_site_id while creating this new site. If no,
--      then we hit the sequence to get a new vendor_site_id. If there are
--      multiple sites for this vendor with the same site_code, we take the
--      max() vendor_site_id.
/*Following piece of code commented out NOCOPY to back out NOCOPY the changes
  made earlier (Bug 702458)
	debug_info := 'Select vendor site id for any other site with same site_code';
	Select  max(vendor_site_id)
	into    x_vendor_site_id
	from	po_vendor_sites_all
	where   vendor_id = x_vendor_id
	and     vendor_site_code = x_vendor_site_code;   */

--(Bug 702458)  if (x_vendor_site_id IS NULL) then
		debug_info := 'Select next vendor_site_id from PO_VENDOR_SITES_S sequence';
		Select  PO_VENDOR_SITES_S.NEXTVAL
		into	x_vendor_site_id
		from 	sys.dual;
--      end if;

       debug_info := 'Insert values into PO_VENDOR_SITES';
       INSERT INTO ap_supplier_sites_all(
              vendor_site_id,
              last_update_date,
              last_updated_by,
              vendor_id,
              vendor_site_code,
              last_update_login,
              creation_date,
              created_by,
              purchasing_site_flag,
              rfq_only_site_flag,
              pay_site_flag,
              attention_ar_flag,
              address_line1,
              address_line2,
              address_line3,
              city,
              state,
              zip,
              province,
              country,
              area_code,
              phone,
              customer_num,
              ship_to_location_id,
              bill_to_location_id,
              ship_via_lookup_code,
              freight_terms_lookup_code,
              fob_lookup_code,
              inactive_date,
              fax,
              fax_area_code,
              telex,
              bank_account_name,
              bank_account_num,
              bank_num,
              bank_account_type,
              terms_date_basis,
              current_catalog_num,
              distribution_set_id,
              accts_pay_code_combination_id,
              future_dated_payment_ccid,
              prepay_code_combination_id,
              pay_group_lookup_code,
              payment_priority,
              terms_id,
              invoice_amount_limit,
              pay_date_basis_lookup_code,
              always_take_disc_flag,
              invoice_currency_code,
              payment_currency_code,
              hold_all_payments_flag,
              hold_future_payments_flag,
              hold_reason,
              hold_unmatched_invoices_flag,
              match_option,
              create_debit_memo_flag,
              tax_reporting_site_flag,
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
              validation_number,
              exclude_freight_from_discount,
              vat_registration_num,
              check_digits,
              bank_number,
              address_line4,
              county,
              address_style,
              language,
              allow_awt_flag,
              awt_group_id,
              pay_awt_group_id,--bug6664407
	      pay_on_code,
	      default_pay_site_id,
	      pay_on_receipt_summary_code,
	      Bank_Branch_Type,
	      vendor_site_code_alt,
	      address_lines_alt,
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
              Bank_charge_bearer,
              Ece_Tp_Location_Code,
              Country_of_Origin_Code,
	      Pcard_Site_Flag,
	      Supplier_Notif_Method, -- New Column
	      Email_Address, -- New Column
              Primary_pay_site_flag  ,
	      org_id,                    /* MO Access Control */
	      edi_id_number              -- Bug 7437549
              )
	VALUES (
              X_Vendor_Site_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Vendor_Id,
              X_Vendor_Site_Code,
              X_Last_Update_Login,
              X_Creation_Date,
              X_Created_By,
              X_Purchasing_Site_Flag,
              X_Rfq_Only_Site_Flag,
              X_Pay_Site_Flag,
              X_Attention_Ar_Flag,
              X_Address_Line1,
              X_Address_Line2,
              X_Address_Line3,
              X_City,
              X_State,
              X_Zip,
              X_Province,
              X_Country,
              X_Area_Code,
              X_Phone,
              X_Customer_Num,
              X_Ship_To_Location_Id,
              X_Bill_To_Location_Id,
              X_Ship_Via_Lookup_Code,
              X_Freight_Terms_Lookup_Code,
              X_Fob_Lookup_Code,
              X_Inactive_Date,
              X_Fax,
              X_Fax_Area_Code,
              X_Telex,
              X_Bank_Account_Name,
              X_Bank_Account_Num,
              X_Bank_Num,
              X_Bank_Account_Type,
              X_Terms_Date_Basis,
              X_Current_Catalog_Num,
              X_Distribution_Set_Id,
              X_Accts_Pay_CCID,
              X_Future_Dated_Payment_CCID,
              X_Prepay_Code_Combination_Id,
              X_Pay_Group_Lookup_Code,
              X_Payment_Priority,
              X_Terms_Id,
              X_Invoice_Amount_Limit,
              X_Pay_Date_Basis_Lookup_Code,
              X_Always_Take_Disc_Flag,
              X_Invoice_Currency_Code,
              X_Payment_Currency_Code,
              X_Hold_All_Payments_Flag,
              X_Hold_Future_Payments_Flag,
              X_Hold_Reason,
              X_Hold_Unmatched_Invoices_Flag,
              X_Match_Option,
              X_Create_Debit_Memo_Flag,
              X_Tax_Reporting_Site_Flag,
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
              X_Validation_Number,
              X_Exclude_Freight_From_Disc,
              X_Vat_Registration_Num,
              X_Check_Digits,
              X_Bank_Number,
              X_Address_Line4,
              X_County,
              X_Address_Style,
              X_Language,
              X_Allow_Awt_Flag,
              X_Awt_Group_Id,
              X_Pay_Awt_Group_Id,--bug6664407
	      X_pay_on_code,
	      X_default_pay_site_id,
	      X_pay_on_receipt_summary_code,
	      X_Bank_Branch_Type,
	      X_Vendor_Site_Code_Alt,
	      X_Address_Lines_Alt,
              X_global_attribute_category,
              X_global_attribute1,
              X_global_attribute2,
              X_global_attribute3,
              X_global_attribute4,
              X_global_attribute5,
              X_global_attribute6,
              X_global_attribute7,
              X_global_attribute8,
              X_global_attribute9,
              X_global_attribute10,
              X_global_attribute11,
              X_global_attribute12,
              X_global_attribute13,
              X_global_attribute14,
              X_global_attribute15,
              X_global_attribute16,
              X_global_attribute17,
              X_global_attribute18,
              X_global_attribute19,
              X_global_attribute20,
              X_Bank_Charge_Bearer,
	      X_Ece_Tp_Location_Code,
	      X_Country_of_Origin_Code,
	      X_Pcard_Site_Flag,
	      X_Supplier_Notif_Method, -- New Column
	      X_Email_Address, -- New Column
              X_Primary_pay_site_flag ,
	      X_org_id,				/* MO Access Control */
	      X_EDI_ID_Number                   -- Bug 7437549
             );

    if (X_Shipping_Location_id is not null) then

        debug_info := 'Insert values into PO_LOCATION_ASSOCIATIONS';

	ap_po_locn_association_pkg.insert_row(	p_location_id 		=> X_Shipping_Location_id,
					      	p_vendor_id 		=> X_Vendor_Id,
						p_vendor_site_id	=> X_Vendor_Site_Id,
						p_last_update_date	=> X_Last_Update_Date,
						p_last_updated_by	=> X_Last_Updated_By,
						p_last_update_login	=> X_Last_Update_Login,
						p_creation_date		=> X_Creation_Date,
						p_created_by		=> X_Created_By,
						p_org_id		=> X_Org_ID);	--MO Access Control
    end if;

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','VENDOR_SITE_ID = ' ||
              					  X_Vendor_Site_Id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

  PROCEDURE Insert_Row(
        p_vendor_site_rec IN AP_VENDOR_PUB_PKG.r_vendor_site_rec_type,
        p_last_update_date IN DATE,
        p_last_updated_by IN NUMBER,
        p_last_update_login IN NUMBER,
        p_creation_date IN DATE,
        p_created_by IN NUMBER,
        p_request_id IN NUMBER,
        p_program_application_id IN NUMBER,
        p_program_id IN NUMBER,
        p_program_update_date IN DATE,
        p_AP_Tax_Rounding_Rule		IN VARCHAR2 DEFAULT NULL, /* 9530837 */
        p_Amount_Includes_Tax_Flag	IN VARCHAR2 DEFAULT NULL, /* 9530837 */
        x_rowid OUT NOCOPY VARCHAR2,
        x_vendor_site_id OUT NOCOPY NUMBER
        ) IS

    CURSOR C IS	 SELECT rowid
		 FROM po_vendor_sites
                 WHERE  vendor_site_id  = X_vendor_site_id;

    current_calling_sequence             varchar2(2000);
    debug_info				 varchar2(2000);

  BEGIN

		debug_info := 'Select next vendor_site_id from PO_VENDOR_SITES_S sequence';
		Select  PO_VENDOR_SITES_S.NEXTVAL
		into	x_vendor_site_id
		from 	sys.dual;
--      end if;

       debug_info := 'Insert values into PO_VENDOR_SITES';
       INSERT INTO ap_supplier_sites_all(
              vendor_site_id,
              last_update_date,
              last_updated_by,
              vendor_id,
              vendor_site_code,
              last_update_login,
              creation_date,
              created_by,
              purchasing_site_flag,
              rfq_only_site_flag,
              pay_site_flag,
              attention_ar_flag,
              area_code,
              phone,
              customer_num,
              ship_to_location_id,
              bill_to_location_id,
              ship_via_lookup_code,
              freight_terms_lookup_code,
              fob_lookup_code,
              inactive_date,
              fax,
              fax_area_code,
              telex,
              terms_date_basis,
              distribution_set_id,
              accts_pay_code_combination_id,
              future_dated_payment_ccid,
              prepay_code_combination_id,
              pay_group_lookup_code,
              payment_priority,
              terms_id,
              invoice_amount_limit,
              pay_date_basis_lookup_code,
              always_take_disc_flag,
              invoice_currency_code,
              payment_currency_code,
              hold_all_payments_flag,
              hold_future_payments_flag,
              hold_reason,
              hold_unmatched_invoices_flag,
              match_option,
              create_debit_memo_flag,
              tax_reporting_site_flag,
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
              validation_number,
              exclude_freight_from_discount,
              check_digits,
              allow_awt_flag,
              awt_group_id,
              pay_awt_group_id,--bug6664407
	      pay_on_code,
	      default_pay_site_id,
	      pay_on_receipt_summary_code,
	      vendor_site_code_alt,
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
              Bank_charge_bearer,
              Ece_Tp_Location_Code,
              Country_of_Origin_Code,
	      Pcard_Site_Flag,
	      Supplier_Notif_Method,
	      Email_Address,
              Primary_pay_site_flag  ,
	      org_id	,
	      location_id,
	      party_site_id,
	      tolerance_id,
	      retainage_rate,
              shipping_control,
              services_tolerance_id,
              gapless_inv_num_flag,
              selling_company_identifier,
              duns_number,    --bug6388041
              vat_code,        -- Bug 6645014
              -- Bug 7300553 Start
              address_line1,
              address_line2,
              address_line3,
              address_line4,
              city,
              state,
              zip,
              province,
              country,
              county,
              address_style,
              language,
              address_lines_alt,
              -- Bug 7300553 End
	      edi_id_number,   -- Bug 7437549
              OFFSET_TAX_FLAG,  -- Bug#7506443
	      AUTO_TAX_CALC_FLAG, -- Bug#7506443
        -- starting the Changes for CLM reference data management bug#9499174
	      CAGE_CODE,
              LEGAL_BUSINESS_NAME,
              DOING_BUS_AS_NAME,
              DIVISION_NAME,
              SMALL_BUSINESS_CODE,
              CCR_COMMENTS,
              DEBARMENT_START_DATE,
              DEBARMENT_END_DATE
        -- Ending the Changes for CLM reference data management bug#9499174
	      ,AP_Tax_Rounding_Rule		/* 9530837 */
	      ,Amount_Includes_Tax_Flag		/* 9530837 */
	      )
	VALUES (
              x_Vendor_Site_Id,
              p_Last_Update_Date,
              p_Last_Updated_By,
              p_vendor_site_rec.Vendor_Id,
              p_vendor_site_rec.Vendor_Site_Code,
              p_Last_Update_Login,
              p_Creation_Date,
              p_Created_By,
              p_vendor_site_rec.Purchasing_Site_Flag,
              p_vendor_site_rec.Rfq_Only_Site_Flag,
              p_vendor_site_rec.Pay_Site_Flag,
              p_vendor_site_rec.Attention_Ar_Flag,
              p_vendor_site_rec.Area_Code,
              p_vendor_site_rec.Phone,
              p_vendor_site_rec.Customer_Num,
              p_vendor_site_rec.Ship_To_Location_Id,
              p_vendor_site_rec.Bill_To_Location_Id,
              p_vendor_site_rec.Ship_Via_Lookup_Code,
              p_vendor_site_rec.Freight_Terms_Lookup_Code,
              p_vendor_site_rec.Fob_Lookup_Code,
              p_vendor_site_rec.Inactive_Date,
              p_vendor_site_rec.Fax,
              p_vendor_site_rec.Fax_area_code,
              p_vendor_site_rec.Telex,
              p_vendor_site_rec.Terms_Date_Basis,
              p_vendor_site_rec.Distribution_Set_Id,
              p_vendor_site_rec.Accts_Pay_Code_Combination_ID,
              p_vendor_site_rec.Future_Dated_Payment_CCID,
              p_vendor_site_rec.Prepay_Code_Combination_Id,
              p_vendor_site_rec.Pay_Group_Lookup_Code,
              p_vendor_site_rec.Payment_Priority,
              p_vendor_site_rec.Terms_Id,
              p_vendor_site_rec.Invoice_Amount_Limit,
              p_vendor_site_rec.Pay_Date_Basis_Lookup_Code,
              p_vendor_site_rec.Always_Take_Disc_Flag,
              p_vendor_site_rec.Invoice_Currency_Code,
              p_vendor_site_rec.Payment_Currency_Code,
              p_vendor_site_rec.Hold_All_Payments_Flag,
              p_vendor_site_rec.Hold_Future_Payments_Flag,
              p_vendor_site_rec.Hold_Reason,
              p_vendor_site_rec.Hold_Unmatched_Invoices_Flag,
              p_vendor_site_rec.Match_Option,
              p_vendor_site_rec.Create_Debit_Memo_Flag,
              p_vendor_site_rec.Tax_Reporting_Site_Flag,
              p_vendor_site_rec.Attribute_Category,
              p_vendor_site_rec.Attribute1,
              p_vendor_site_rec.Attribute2,
              p_vendor_site_rec.Attribute3,
              p_vendor_site_rec.Attribute4,
              p_vendor_site_rec.Attribute5,
              p_vendor_site_rec.Attribute6,
              p_vendor_site_rec.Attribute7,
              p_vendor_site_rec.Attribute8,
              p_vendor_site_rec.Attribute9,
              p_vendor_site_rec.Attribute10,
              p_vendor_site_rec.Attribute11,
              p_vendor_site_rec.Attribute12,
              p_vendor_site_rec.Attribute13,
              p_vendor_site_rec.Attribute14,
              p_vendor_site_rec.Attribute15,
              p_vendor_site_rec.Validation_Number,
              p_vendor_site_rec.Exclude_Freight_From_Discount,
              p_vendor_site_rec.Check_Digits,
              p_vendor_site_rec.Allow_Awt_Flag,
              p_vendor_site_rec.Awt_Group_Id,
              p_vendor_site_rec.Pay_Awt_Group_Id,--bug6664407
	      p_vendor_site_rec.pay_on_code,
	      p_vendor_site_rec.default_pay_site_id,
	      p_vendor_site_rec.pay_on_receipt_summary_code,
	      p_vendor_site_rec.Vendor_Site_Code_Alt,
              p_vendor_site_rec.global_attribute_category,
              p_vendor_site_rec.global_attribute1,
              p_vendor_site_rec.global_attribute2,
              p_vendor_site_rec.global_attribute3,
              p_vendor_site_rec.global_attribute4,
              p_vendor_site_rec.global_attribute5,
              p_vendor_site_rec.global_attribute6,
              p_vendor_site_rec.global_attribute7,
              p_vendor_site_rec.global_attribute8,
              p_vendor_site_rec.global_attribute9,
              p_vendor_site_rec.global_attribute10,
              p_vendor_site_rec.global_attribute11,
              p_vendor_site_rec.global_attribute12,
              p_vendor_site_rec.global_attribute13,
              p_vendor_site_rec.global_attribute14,
              p_vendor_site_rec.global_attribute15,
              p_vendor_site_rec.global_attribute16,
              p_vendor_site_rec.global_attribute17,
              p_vendor_site_rec.global_attribute18,
              p_vendor_site_rec.global_attribute19,
              p_vendor_site_rec.global_attribute20,
              p_vendor_site_rec.Bank_Charge_Bearer,
	      p_vendor_site_rec.Ece_Tp_Location_Code,
	      p_vendor_site_rec.Country_of_Origin_Code,
	      p_vendor_site_rec.Pcard_Site_Flag,
	      p_vendor_site_rec.Supplier_Notif_Method,
	      p_vendor_site_rec.Email_Address,
              p_vendor_site_rec.Primary_pay_site_flag ,
	      p_vendor_site_rec.org_id,
	      p_vendor_site_rec.location_id,
  	      p_vendor_site_rec.party_site_id,
  	      p_vendor_site_rec.tolerance_id,
	      p_vendor_site_rec.retainage_rate,
              p_vendor_site_rec.shipping_control,
              p_vendor_site_rec.services_tolerance_id,
              p_vendor_site_rec.gapless_inv_num_flag,
              p_vendor_site_rec.selling_company_identifier,
              p_vendor_site_rec.duns_number,    --bug6388041
              p_vendor_site_rec.vat_code, -- bug 6645014
              -- Bug 7300553 Start
              p_vendor_site_rec.address_line1,
              p_vendor_site_rec.address_line2,
              p_vendor_site_rec.address_line3,
              p_vendor_site_rec.address_line4,
              p_vendor_site_rec.city,
              p_vendor_site_rec.state,
              p_vendor_site_rec.zip,
              p_vendor_site_rec.province,
              p_vendor_site_rec.country,
              p_vendor_site_rec.county,
              p_vendor_site_rec.address_style,
              p_vendor_site_rec.language,
              p_vendor_site_rec.address_lines_alt,
              -- Bug 7300553 End
	      p_vendor_site_rec.edi_id_number,   -- Bug 7437549
              p_vendor_site_rec.offset_tax_flag, -- Bug#7506443
	      p_vendor_site_rec.auto_tax_calc_flag, -- Bug#7506443
        -- starting the Changes for CLM reference data management bug#9499174
              p_vendor_site_rec.cage_code,
              p_vendor_site_rec.legal_business_name,
              p_vendor_site_rec.doing_bus_as_name,
              p_vendor_site_rec.division_name,
              p_vendor_site_rec.small_business_code,
              p_vendor_site_rec.ccr_comments,
              p_vendor_site_rec.debarment_start_date,
              p_vendor_site_rec.debarment_end_date
       -- Ending the Changes for CLM reference data management bug#9499174
              ,p_AP_Tax_Rounding_Rule		/* 9530837 */
              ,p_Amount_Includes_Tax_Flag	/* 9530837 */
		);

    if (p_vendor_site_rec.Shipping_Location_id is not null) then

        debug_info := 'Insert values into PO_LOCATION_ASSOCIATIONS';

	ap_po_locn_association_pkg.insert_row(
		p_location_id 		=> p_vendor_site_rec.Ship_to_Location_id,
	      	p_vendor_id 		=> p_vendor_site_rec.Vendor_Id,
		p_vendor_site_id	=> x_Vendor_Site_Id,
		p_last_update_date	=> p_Last_Update_Date,
		p_last_updated_by	=> p_Last_Updated_By,
		p_last_update_login	=> p_Last_Update_Login,
		p_creation_date		=> p_Creation_Date,
		p_created_by		=> p_Created_By,
		p_org_id		=> p_vendor_site_rec.Org_ID);	--MO Access Control
    end if;

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO x_Rowid;
    if (C%NOTFOUND) then
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    debug_info := 'Close cursor C';
    CLOSE C;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','VENDOR_SITE_ID = ' ||
              					  x_Vendor_Site_Id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Insert_Row;

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Vendor_Site_Id                   NUMBER,
                     X_Vendor_Id                        NUMBER,
                     X_Vendor_Site_Code                 VARCHAR2,
                     X_Purchasing_Site_Flag             VARCHAR2,
                     X_Rfq_Only_Site_Flag               VARCHAR2,
                     X_Pay_Site_Flag                    VARCHAR2,
                     X_Attention_Ar_Flag                VARCHAR2,
                     X_Address_Line1                    VARCHAR2,
                     X_Address_Line2                    VARCHAR2,
                     X_Address_Line3                    VARCHAR2,
                     X_City                             VARCHAR2,
                     X_State                            VARCHAR2,
                     X_Zip                              VARCHAR2,
                     X_Province                         VARCHAR2,
                     X_Country                          VARCHAR2,
                     X_Area_Code                        VARCHAR2,
                     X_Phone                            VARCHAR2,
                     X_Customer_Num                     VARCHAR2,
                     X_Ship_To_Location_Id              NUMBER,
                     X_Bill_To_Location_Id              NUMBER,
                     X_Ship_Via_Lookup_Code             VARCHAR2,
                     X_Freight_Terms_Lookup_Code        VARCHAR2,
                     X_Fob_Lookup_Code                  VARCHAR2,
                     X_Inactive_Date                    DATE,
                     X_Fax                              VARCHAR2,
                     X_Fax_Area_Code                    VARCHAR2,
                     X_Telex                            VARCHAR2,
                     --4552701 X_Payment_Method_Lookup_Code       VARCHAR2,
                     X_Bank_Account_Name                VARCHAR2,
                     X_Bank_Account_Num                 VARCHAR2,
                     X_Bank_Num                         VARCHAR2,
                     X_Bank_Account_Type                VARCHAR2,
                     X_Terms_Date_Basis                 VARCHAR2,
                     X_Current_Catalog_Num              VARCHAR2,
                     -- eTax Uptake X_Vat_Code          VARCHAR2,
                     X_Distribution_Set_Id              NUMBER,
                     X_Accts_Pay_CCID		        NUMBER,
                     X_Future_Dated_Payment_CCID	NUMBER,
                     X_Prepay_Code_Combination_Id       NUMBER,
                     X_Pay_Group_Lookup_Code            VARCHAR2,
                     X_Payment_Priority                 NUMBER,
                     X_Terms_Id                         NUMBER,
                     X_Invoice_Amount_Limit             NUMBER,
                     X_Pay_Date_Basis_Lookup_Code       VARCHAR2,
                     X_Always_Take_Disc_Flag            VARCHAR2,
                     X_Invoice_Currency_Code            VARCHAR2,
                     X_Payment_Currency_Code            VARCHAR2,
                     X_Hold_All_Payments_Flag           VARCHAR2,
                     X_Hold_Future_Payments_Flag        VARCHAR2,
                     X_Hold_Reason                      VARCHAR2,
                     X_Hold_Unmatched_Invoices_Flag     VARCHAR2,
                     X_Match_Option			VARCHAR2,
		     X_Create_Debit_Memo_Flag		VARCHAR2,
                     --4552701 X_Exclusive_Payment_Flag           VARCHAR2,
                     X_Tax_Reporting_Site_Flag          VARCHAR2,
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
                     X_Validation_Number                NUMBER,
                     X_Exclude_Freight_From_Disc        VARCHAR2,
                     X_Vat_Registration_Num             VARCHAR2,
                     -- eTax Uptake X_Offset_Tax_Flag   VARCHAR2,
                     X_Check_Digits                     VARCHAR2,
                     X_Bank_Number                      VARCHAR2,
                     X_Address_Line4                    VARCHAR2,
                     X_County                           VARCHAR2,
                     X_Address_Style                    VARCHAR2,
                     X_Language                         VARCHAR2,
                     X_Allow_Awt_Flag                   VARCHAR2,
                     X_Awt_Group_Id                     NUMBER,
                     X_Pay_Awt_Group_Id                     NUMBER,--bug6664407
		     X_pay_on_code			VARCHAR2,
		     X_default_pay_site_id		NUMBER,
		     X_pay_on_receipt_summary_code	VARCHAR2,
		     X_Bank_Branch_Type			VARCHAR2,
		     X_EDI_ID_Number                    VARCHAR2, --Bug 7437549
		     /* 4552701
                     X_EDI_ID_Number			VARCHAR2,
		     X_EDI_Payment_Method		VARCHAR2,
		     X_EDI_Payment_Format		VARCHAR2,
		     X_EDI_Remittance_Method		VARCHAR2,
		     X_EDI_Remittance_Instruction	VARCHAR2,
		     X_EDI_transaction_handling		VARCHAR2,
                     eTax Uptake
		     X_Auto_Tax_Calc_Flag		VARCHAR2,
		     X_Auto_Tax_Calc_Override		VARCHAR2,
		     X_Amount_Includes_Tax_Flag		VARCHAR2,
		     X_AP_Tax_Rounding_Rule		VARCHAR2, */
		     X_Vendor_Site_Code_Alt		VARCHAR2,
		     X_Address_Lines_Alt		VARCHAR2,
                     X_global_attribute_category        VARCHAR2 DEFAULT NULL,
                     X_global_attribute1                VARCHAR2 DEFAULT NULL,
                     X_global_attribute2                VARCHAR2 DEFAULT NULL,
                     X_global_attribute3                VARCHAR2 DEFAULT NULL,
                     X_global_attribute4                VARCHAR2 DEFAULT NULL,
                     X_global_attribute5                VARCHAR2 DEFAULT NULL,
                     X_global_attribute6                VARCHAR2 DEFAULT NULL,
                     X_global_attribute7                VARCHAR2 DEFAULT NULL,
                     X_global_attribute8                VARCHAR2 DEFAULT NULL,
                     X_global_attribute9                VARCHAR2 DEFAULT NULL,
                     X_global_attribute10               VARCHAR2 DEFAULT NULL,
                     X_global_attribute11               VARCHAR2 DEFAULT NULL,
                     X_global_attribute12               VARCHAR2 DEFAULT NULL,
                     X_global_attribute13               VARCHAR2 DEFAULT NULL,
                     X_global_attribute14               VARCHAR2 DEFAULT NULL,
                     X_global_attribute15               VARCHAR2 DEFAULT NULL,
                     X_global_attribute16               VARCHAR2 DEFAULT NULL,
                     X_global_attribute17               VARCHAR2 DEFAULT NULL,
                     X_global_attribute18               VARCHAR2 DEFAULT NULL,
                     X_global_attribute19               VARCHAR2 DEFAULT NULL,
                     X_global_attribute20               VARCHAR2 DEFAULT NULL,
		     X_Bank_Charge_Bearer	  	VARCHAR2 DEFAULT NULL,
                     X_Ece_Tp_Location_Code             VARCHAR2 DEFAULT NULL,
		     X_Pcard_Site_Flag    		VARCHAR2,
		     X_Country_of_Origin_Code		VARCHAR2,
		     X_calling_sequence		IN	VARCHAR2,
		     X_Shipping_Location_id	IN	NUMBER,
	             X_Supplier_Notif_Method          VARCHAR2, -- New Column
                     X_Email_Address                  VARCHAR2, -- New Column
                     --4552701 X_remittance_email               VARCHAR2 DEFAULT NULL,
                     X_Primary_pay_site_flag          VARCHAR2 DEFAULT NULL,
		     --MO Access Control
		     X_org_id			      NUMBER DEFAULT mo_global.get_current_org_id
		     ) IS
    CURSOR C IS
        SELECT *
        FROM   ap_supplier_sites
        WHERE  rowid = X_Rowid
        FOR UPDATE of vendor_site_id NOWAIT;
    Recinfo C%ROWTYPE;

    current_calling_sequence             varchar2(2000);
    debug_info                           varchar2(100);
    l_shipping_location_id		 NUMBER := NULL;

  BEGIN
--  Update the calling sequence
--
    current_calling_sequence := 'AP_VENDOR_SITES_PKG.LOCK_ROW<-' ||
                                 X_calling_sequence;
    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;
    	if (C%NOTFOUND) then
		debug_info := 'Close cursor C - NOTFOUND';
      		CLOSE C;
      		FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      		APP_EXCEPTION.Raise_Exception;
    	end if;
    debug_info := 'Close cursor C';
    CLOSE C;

--  Bug # 689472

    debug_info := 'Getting address style from fnd_territory';

    begin
       select address_style
       into   recinfo.address_style
       from   fnd_territories
       where  territory_code =   x_country;
    exception
       when no_data_found then
          recinfo.address_style := '';
    end;

    if (       (Recinfo.vendor_site_id =  X_Vendor_Site_Id)
           AND (Recinfo.vendor_id =  X_Vendor_Id)
           AND (Recinfo.vendor_site_code =  X_Vendor_Site_Code)
           AND (   (Recinfo.purchasing_site_flag =  X_Purchasing_Site_Flag)
                OR (    (Recinfo.purchasing_site_flag IS NULL)
                    AND (X_Purchasing_Site_Flag IS NULL)))
           AND (   (Recinfo.rfq_only_site_flag =  X_Rfq_Only_Site_Flag)
                OR (    (Recinfo.rfq_only_site_flag IS NULL)
                    AND (X_Rfq_Only_Site_Flag IS NULL)))
           AND (   (Recinfo.pay_site_flag =  X_Pay_Site_Flag)
                OR (    (Recinfo.pay_site_flag IS NULL)
                    AND (X_Pay_Site_Flag IS NULL)))
           AND (   (Recinfo.attention_ar_flag =  X_Attention_Ar_Flag)
                OR (    (Recinfo.attention_ar_flag IS NULL)
                    AND (X_Attention_Ar_Flag IS NULL)))
           AND (   (Recinfo.address_line1 =  X_Address_Line1)
                OR (    (Recinfo.address_line1 IS NULL)
                    AND (X_Address_Line1 IS NULL)))
           AND (   (Recinfo.address_line2 =  X_Address_Line2)
                OR (    (Recinfo.address_line2 IS NULL)
                    AND (X_Address_Line2 IS NULL)))
           AND (   (Recinfo.address_line3 =  X_Address_Line3)
                OR (    (Recinfo.address_line3 IS NULL)
                    AND (X_Address_Line3 IS NULL)))
           AND (   (Recinfo.city =  X_City)
                OR (    (Recinfo.city IS NULL)
                    AND (X_City IS NULL)))
           AND (   (Recinfo.state =  X_State)
                OR (    (Recinfo.state IS NULL)
                    AND (X_State IS NULL)))
           AND (   (Recinfo.zip =  X_Zip)
                OR (    (Recinfo.zip IS NULL)
                    AND (X_Zip IS NULL)))
           AND (   (Recinfo.province =  X_Province)
                OR (    (Recinfo.province IS NULL)
                    AND (X_Province IS NULL)))
           AND (   (Recinfo.country =  X_Country)
                OR (    (Recinfo.country IS NULL)
                    AND (X_Country IS NULL)))
           AND (   (Recinfo.area_code =  X_Area_Code)
                OR (    (Recinfo.area_code IS NULL)
                    AND (X_Area_Code IS NULL)))
           AND (   (Recinfo.phone =  X_Phone)
                OR (    (Recinfo.phone IS NULL)
                    AND (X_Phone IS NULL)))
           AND (   (Recinfo.customer_num =  X_Customer_Num)
                OR (    (Recinfo.customer_num IS NULL)
                    AND (X_Customer_Num IS NULL)))
           AND (   (Recinfo.ship_to_location_id =  X_Ship_To_Location_Id)
                OR (    (Recinfo.ship_to_location_id IS NULL)
                    AND (X_Ship_To_Location_Id IS NULL)))
           AND (   (Recinfo.bill_to_location_id =  X_Bill_To_Location_Id)
                OR (    (Recinfo.bill_to_location_id IS NULL)
                    AND (X_Bill_To_Location_Id IS NULL)))
           AND (   (Recinfo.ship_via_lookup_code =  X_Ship_Via_Lookup_Code)
                OR (    (Recinfo.ship_via_lookup_code IS NULL)
                    AND (X_Ship_Via_Lookup_Code IS NULL)))
           AND (   (Recinfo.freight_terms_lookup_code =  X_Freight_Terms_Lookup_Code)
                OR (    (Recinfo.freight_terms_lookup_code IS NULL)
                    AND (X_Freight_Terms_Lookup_Code IS NULL)))
           AND (   (Recinfo.fob_lookup_code =  X_Fob_Lookup_Code)
                OR (    (Recinfo.fob_lookup_code IS NULL)
                    AND (X_Fob_Lookup_Code IS NULL)))
           AND (   (Recinfo.inactive_date =  X_Inactive_Date)
                OR (    (Recinfo.inactive_date IS NULL)
                    AND (X_Inactive_Date IS NULL)))
           AND (   (Recinfo.fax =  X_Fax)
                OR (    (Recinfo.fax IS NULL)
                    AND (X_Fax IS NULL)))
           AND (   (Recinfo.fax_area_code =  X_Fax_Area_Code)
                OR (    (Recinfo.fax_area_code IS NULL)
                    AND (X_Fax_Area_Code IS NULL)))
           AND (   (Recinfo.telex =  X_Telex)
                OR (    (Recinfo.telex IS NULL)
                    AND (X_Telex IS NULL)))
           AND (   (Recinfo.bank_account_name =  X_Bank_Account_Name)
                OR (    (Recinfo.bank_account_name IS NULL)
                    AND (X_Bank_Account_Name IS NULL)))
           AND (   (Recinfo.bank_account_num =  X_Bank_Account_Num)
                OR (    (Recinfo.bank_account_num IS NULL)
                    AND (X_Bank_Account_Num IS NULL)))
           AND (   (Recinfo.bank_num =  X_Bank_Num)
                OR (    (Recinfo.bank_num IS NULL)
                    AND (X_Bank_Num IS NULL)))
           AND (   (Recinfo.bank_account_type =  X_Bank_Account_Type)
                OR (    (Recinfo.bank_account_type IS NULL)
                    AND (X_Bank_Account_Type IS NULL)))
           AND (   (Recinfo.terms_date_basis =  X_Terms_Date_Basis)
                OR (    (Recinfo.terms_date_basis IS NULL)
                    AND (X_Terms_Date_Basis IS NULL)))
           AND (   (Recinfo.current_catalog_num =  X_Current_Catalog_Num)
                OR (    (Recinfo.current_catalog_num IS NULL)
                    AND (X_Current_Catalog_Num IS NULL)))
           AND (   (Recinfo.distribution_set_id =  X_Distribution_Set_Id)
                OR (    (Recinfo.distribution_set_id IS NULL)
                    AND (X_Distribution_Set_Id IS NULL)))
           AND (   (Recinfo.accts_pay_code_combination_id =  X_Accts_Pay_CCID)
                OR (    (Recinfo.accts_pay_code_combination_id IS NULL)
                    AND (X_Accts_Pay_CCID IS NULL)))
           AND (   (Recinfo.future_dated_payment_ccid =  X_Future_Dated_Payment_CCID)
                OR (    (Recinfo.future_dated_payment_ccid IS NULL)
                    AND (X_Future_Dated_Payment_CCID IS NULL)))
           AND (   (Recinfo.prepay_code_combination_id =  X_Prepay_Code_Combination_Id)
                OR (    (Recinfo.prepay_code_combination_id IS NULL)
                    AND (X_Prepay_Code_Combination_Id IS NULL)))
           AND (   (Recinfo.pay_group_lookup_code =  X_Pay_Group_Lookup_Code)
                OR (    (Recinfo.pay_group_lookup_code IS NULL)
                    AND (X_Pay_Group_Lookup_Code IS NULL)))
           AND (   (Recinfo.payment_priority =  X_Payment_Priority)
                OR (    (Recinfo.payment_priority IS NULL)
                    AND (X_Payment_Priority IS NULL)))
           AND (   (Recinfo.terms_id =  X_Terms_Id)
                OR (    (Recinfo.terms_id IS NULL)
                    AND (X_Terms_Id IS NULL)))
           AND (   (Recinfo.invoice_amount_limit =  X_Invoice_Amount_Limit)
                OR (    (Recinfo.invoice_amount_limit IS NULL)
                    AND (X_Invoice_Amount_Limit IS NULL)))
           AND (   (Recinfo.pay_date_basis_lookup_code =  X_Pay_Date_Basis_Lookup_Code)
                OR (    (Recinfo.pay_date_basis_lookup_code IS NULL)
                    AND (X_Pay_Date_Basis_Lookup_Code IS NULL)))
           AND (   (Recinfo.always_take_disc_flag =  X_Always_Take_Disc_Flag)
                OR (    (Recinfo.always_take_disc_flag IS NULL)
                    AND (X_Always_Take_Disc_Flag IS NULL)))
           AND (   (Recinfo.invoice_currency_code =  X_Invoice_Currency_Code)
                OR (    (Recinfo.invoice_currency_code IS NULL)
                    AND (X_Invoice_Currency_Code IS NULL)))
           AND (   (Recinfo.bank_charge_bearer =  X_Bank_Charge_Bearer)
                OR (    (Recinfo.bank_charge_bearer IS NULL)
                    AND (X_Bank_Charge_Bearer IS NULL)))
           AND (   (Recinfo.Ece_Tp_Location_Code =  X_Ece_Tp_Location_Code)
                OR (    (Recinfo.Ece_Tp_Location_Code IS NULL)
                    AND (X_Ece_Tp_Location_Code IS NULL)))
          -- New Column
          AND (   (Recinfo.supplier_notif_method =  X_Supplier_Notif_Method)
                OR (    (Recinfo.supplier_notif_method IS NULL)
                    AND (X_Supplier_Notif_Method IS NULL)))
           AND (   (Recinfo.email_address =  X_Email_Address)
                OR (    (Recinfo.email_address IS NULL)
                    AND (X_Email_Address IS NULL)))
           AND (   (Recinfo.primary_pay_site_flag = X_Primary_pay_site_flag)
                OR (    (Recinfo.Primary_pay_site_flag IS NULL)
                    AND (X_primary_pay_site_flag IS NULL)))
	   /* MO Access Control */
           AND (   (Recinfo.org_id = X_org_id)
	        OR (    (Recinfo.org_id IS NULL)
	            AND (X_org_id IS NULL)))
            -- Bug 7437549
           AND (   (Recinfo.edi_id_number = X_EDI_ID_Number)
                OR (    (Recinfo.edi_id_number IS NULL)
                    AND (X_EDI_ID_Number IS NULL)))
           )

		then
			null;
		else
			FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
			APP_EXCEPTION.Raise_Exception;
		end if;
--
	if (

           (   (Recinfo.payment_currency_code =  X_Payment_Currency_Code)
                OR (    (Recinfo.payment_currency_code IS NULL)
                    AND (X_Payment_Currency_Code IS NULL)))
           AND (   (Recinfo.hold_all_payments_flag =  X_Hold_All_Payments_Flag)
                OR (    (Recinfo.hold_all_payments_flag IS NULL)
                    AND (X_Hold_All_Payments_Flag IS NULL)))
           AND (   (Recinfo.hold_future_payments_flag =  X_Hold_Future_Payments_Flag)
                OR (    (Recinfo.hold_future_payments_flag IS NULL)
                    AND (X_Hold_Future_Payments_Flag IS NULL)))
           AND (   (Recinfo.hold_reason =  X_Hold_Reason)
                OR (    (Recinfo.hold_reason IS NULL)
                    AND (X_Hold_Reason IS NULL)))
           AND (   (Recinfo.hold_unmatched_invoices_flag =  X_Hold_Unmatched_Invoices_Flag)
                OR (    (Recinfo.hold_unmatched_invoices_flag IS NULL)
                    AND (X_Hold_Unmatched_Invoices_Flag IS NULL)))
           AND (   (Recinfo.match_option =  X_match_option)
                OR (    (Recinfo.match_option IS NULL)
                    AND (X_match_option IS NULL)))
           AND (   (Recinfo.create_debit_memo_flag =  X_create_debit_memo_flag)
                OR (    (Recinfo.create_debit_memo_flag IS NULL)
                    AND (X_create_debit_memo_flag IS NULL)))
           AND (   (Recinfo.tax_reporting_site_flag =  X_Tax_Reporting_Site_Flag)
                OR (    (Recinfo.tax_reporting_site_flag IS NULL)
                    AND (X_Tax_Reporting_Site_Flag IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.validation_number =  X_Validation_Number)
                OR (    (Recinfo.validation_number IS NULL)
                    AND (X_Validation_Number IS NULL)))
           AND (   (Recinfo.exclude_freight_from_discount =  X_Exclude_Freight_From_Disc)
                OR (    (Recinfo.exclude_freight_from_discount IS NULL)
                    AND (X_Exclude_Freight_From_Disc IS NULL)))
           AND (   (Recinfo.vat_registration_num =  X_Vat_Registration_Num)
                OR (    (Recinfo.vat_registration_num IS NULL)
                    AND (X_Vat_Registration_Num IS NULL)))
           AND (   (Recinfo.check_digits =  X_Check_Digits)
                OR (    (Recinfo.check_digits IS NULL)
                    AND (X_Check_Digits IS NULL)))
           AND (   (Recinfo.bank_number =  X_Bank_Number)
                OR (    (Recinfo.bank_number IS NULL)
                    AND (X_Bank_Number IS NULL)))
           AND (   (Recinfo.address_line4 =  X_Address_Line4)
                OR (    (Recinfo.address_line4 IS NULL)
                    AND (X_Address_Line4 IS NULL)))
           AND (   (Recinfo.county =  X_County)
                OR (    (Recinfo.county IS NULL)
                    AND (X_County IS NULL)))
           AND (   (Recinfo.address_style =  X_Address_Style)
                OR (    (Recinfo.address_style IS NULL)
                    AND (X_Address_Style IS NULL)))
           AND (   (Recinfo.language =  X_Language)
                OR (    (Recinfo.language IS NULL)
                    AND (X_Language IS NULL)))
           AND (   (Recinfo.allow_awt_flag =  X_Allow_Awt_Flag)
                OR (    (Recinfo.allow_awt_flag IS NULL)
                    AND (X_Allow_Awt_Flag IS NULL)))
           AND (   (Recinfo.awt_group_id =  X_Awt_Group_Id)
                OR (    (Recinfo.awt_group_id IS NULL)
                    AND (X_Awt_Group_Id IS NULL)))
            AND (   (Recinfo.pay_awt_group_id =  X_Pay_Awt_Group_Id)
                OR (    (Recinfo.Pay_awt_group_id IS NULL)
                    AND (X_Pay_Awt_Group_Id IS NULL)))     --bug6664407
           AND (   (Recinfo.pay_on_code =  X_pay_on_code)
                OR (    (Recinfo.pay_on_code IS NULL)
                    AND (X_pay_on_code IS NULL)))
           AND (   (Recinfo.default_pay_site_id =  X_default_pay_site_id)
                OR (    (Recinfo.default_pay_site_id IS NULL)
                    AND (X_default_pay_site_id IS NULL)))
           AND (   (Recinfo.pay_on_receipt_summary_code =  X_pay_on_receipt_summary_code)
                OR (    (Recinfo.pay_on_receipt_summary_code IS NULL)
                    AND (X_pay_on_receipt_summary_code IS NULL)))
           AND (   (Recinfo.Bank_Branch_Type =  X_Bank_Branch_Type)
                OR (    (Recinfo.Bank_Branch_Type IS NULL)
                    AND (X_Bank_Branch_Type IS NULL)))
           AND (   (Recinfo.vendor_site_code_alt =  X_Vendor_Site_Code_Alt)
                OR (    (Recinfo.vendor_site_code_alt IS NULL)
                    AND (X_Vendor_Site_Code_Alt IS NULL)))
           AND (   (Recinfo.address_lines_alt =  X_Address_Lines_Alt)
                OR (    (Recinfo.address_lines_alt IS NULL)
                    AND (X_Address_Lines_Alt IS NULL)))
		)
		then
			null;
		else
			FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
			APP_EXCEPTION.Raise_Exception;
		end if;
--
	if (
               (   (Recinfo.global_attribute_category =  X_global_attribute_category)
                OR (    (Recinfo.global_attribute_category IS NULL)
                    AND (X_global_attribute_category IS NULL)))
           AND (   (Recinfo.global_attribute1 =  X_global_attribute1)
                OR (    (Recinfo.global_attribute1 IS NULL)
                    AND (X_global_attribute1 IS NULL)))
           AND (   (Recinfo.global_attribute2 =  X_global_attribute2)
                OR (    (Recinfo.global_attribute2 IS NULL)
                    AND (X_global_attribute2 IS NULL)))
           AND (   (Recinfo.global_attribute3 =  X_global_attribute3)
                OR (    (Recinfo.global_attribute3 IS NULL)
                    AND (X_global_attribute3 IS NULL)))
           AND (   (Recinfo.global_attribute4 =  X_global_attribute4)
                OR (    (Recinfo.global_attribute4 IS NULL)
                    AND (X_global_attribute4 IS NULL)))
           AND (   (Recinfo.global_attribute5 =  X_global_attribute5)
                OR (    (Recinfo.global_attribute5 IS NULL)
                    AND (X_global_attribute5 IS NULL)))
           AND (   (Recinfo.global_attribute6 =  X_global_attribute6)
                OR (    (Recinfo.global_attribute6 IS NULL)
                    AND (X_global_attribute6 IS NULL)))
           AND (   (Recinfo.global_attribute7 =  X_global_attribute7)
                OR (    (Recinfo.global_attribute7 IS NULL)
                    AND (X_global_attribute7 IS NULL)))
           AND (   (Recinfo.global_attribute8 =  X_global_attribute8)
                OR (    (Recinfo.global_attribute8 IS NULL)
                    AND (X_global_attribute8 IS NULL)))
           AND (   (Recinfo.global_attribute9 =  X_global_attribute9)
                OR (    (Recinfo.global_attribute9 IS NULL)
                    AND (X_global_attribute9 IS NULL)))
           AND (   (Recinfo.global_attribute10 =  X_global_attribute10)
                OR (    (Recinfo.global_attribute10 IS NULL)
                    AND (X_global_attribute10 IS NULL)))
           AND (   (Recinfo.global_attribute11 =  X_global_attribute11)
                OR (    (Recinfo.global_attribute11 IS NULL)
                    AND (X_global_attribute11 IS NULL)))
           AND (   (Recinfo.global_attribute12 =  X_global_attribute12)
                OR (    (Recinfo.global_attribute12 IS NULL)
                    AND (X_global_attribute12 IS NULL)))
           AND (   (Recinfo.global_attribute13 =  X_global_attribute13)
                OR (    (Recinfo.global_attribute13 IS NULL)
                    AND (X_global_attribute13 IS NULL)))
           AND (   (Recinfo.global_attribute14 =  X_global_attribute14)
                OR (    (Recinfo.global_attribute14 IS NULL)
                    AND (X_global_attribute14 IS NULL)))
           AND (   (Recinfo.global_attribute15 =  X_global_attribute15)
                OR (    (Recinfo.global_attribute15 IS NULL)
                    AND (X_global_attribute15 IS NULL)))
           AND (   (Recinfo.global_attribute16 =  X_global_attribute16)
                OR (    (Recinfo.global_attribute16 IS NULL)
                    AND (X_global_attribute16 IS NULL)))
           AND (   (Recinfo.global_attribute17 =  X_global_attribute17)
                OR (    (Recinfo.global_attribute17 IS NULL)
                    AND (X_global_attribute17 IS NULL)))
           AND (   (Recinfo.global_attribute18 =  X_global_attribute18)
                OR (    (Recinfo.global_attribute18 IS NULL)
                    AND (X_global_attribute18 IS NULL)))
           AND (   (Recinfo.global_attribute19 =  X_global_attribute19)
                OR (    (Recinfo.global_attribute19 IS NULL)
                    AND (X_global_attribute19 IS NULL)))
           AND (   (Recinfo.global_attribute20 =  X_global_attribute20)
                OR (    (Recinfo.global_attribute20 IS NULL)
                    AND (X_global_attribute20 IS NULL)))
           AND (   (Recinfo.Pcard_Site_Flag =  X_Pcard_Site_Flag)
                OR (    (Recinfo.Pcard_Site_Flag IS NULL)
                    AND (X_Pcard_Site_Flag IS NULL)))
           AND (   (Recinfo.Country_of_Origin_Code =  X_Country_of_Origin_Code)
                OR (    (Recinfo.Country_of_Origin_Code IS NULL)
                    AND (X_Country_of_Origin_Code IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    begin
	select location_id
	  into l_shipping_location_id
	  from po_location_associations
	 where vendor_site_id = X_Vendor_Site_Id;
    exception
	when no_data_found then
	   l_shipping_location_id := NULL;
    end;

    if (  ( X_Shipping_Location_id = l_shipping_location_id )
       OR ( X_Shipping_Location_id is null and l_shipping_location_id is null)  ) then
       null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    EXCEPTION

       WHEN OTHERS THEN
         IF (SQLCODE <> -20001) THEN
           IF (SQLCODE = -54) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
           ELSE
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS','VENDOR_SITE_ID = ' ||
             					 X_Vendor_Site_Id ||
						', ROWID = ' || X_Rowid );
             FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
	 END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;

  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Code               VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Purchasing_Site_Flag           VARCHAR2,
                       X_Rfq_Only_Site_Flag             VARCHAR2,
                       X_Pay_Site_Flag                  VARCHAR2,
                       X_Attention_Ar_Flag              VARCHAR2,
                       X_Address_Line1                  VARCHAR2,
                       X_Address_Line2                  VARCHAR2,
                       X_Address_Line3                  VARCHAR2,
                       X_City                           VARCHAR2,
                       X_State                          VARCHAR2,
                       X_Zip                            VARCHAR2,
                       X_Province                       VARCHAR2,
                       X_Country                        VARCHAR2,
                       X_Area_Code                      VARCHAR2,
                       X_Phone                          VARCHAR2,
                       X_Customer_Num                   VARCHAR2,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Bill_To_Location_Id            NUMBER,
                       X_Ship_Via_Lookup_Code           VARCHAR2,
                       X_Freight_Terms_Lookup_Code      VARCHAR2,
                       X_Fob_Lookup_Code                VARCHAR2,
                       X_Inactive_Date                  DATE,
                       X_Fax                            VARCHAR2,
                       X_Fax_Area_Code                  VARCHAR2,
                       X_Telex                          VARCHAR2,
                       --4552701 X_Payment_Method_Lookup_Code     VARCHAR2,
                       X_Bank_Account_Name              VARCHAR2,
                       X_Bank_Account_Num               VARCHAR2,
                       X_Bank_Num                       VARCHAR2,
                       X_Bank_Account_Type              VARCHAR2,
                       X_Terms_Date_Basis               VARCHAR2,
                       X_Current_Catalog_Num            VARCHAR2,
                       -- eTax Uptake X_Vat_Code        VARCHAR2,
                       X_Distribution_Set_Id            NUMBER,
                       X_Accts_Pay_CCID	 		NUMBER,
                       X_Future_Dated_Payment_CCID	NUMBER,
                       X_Prepay_Code_Combination_Id     NUMBER,
                       X_Pay_Group_Lookup_Code          VARCHAR2,
                       X_Payment_Priority               NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Invoice_Amount_Limit           NUMBER,
                       X_Pay_Date_Basis_Lookup_Code     VARCHAR2,
                       X_Always_Take_Disc_Flag          VARCHAR2,
                       X_Invoice_Currency_Code          VARCHAR2,
                       X_Payment_Currency_Code          VARCHAR2,
                       X_Hold_All_Payments_Flag         VARCHAR2,
                       X_Hold_Future_Payments_Flag      VARCHAR2,
                       X_Hold_Reason                    VARCHAR2,
                       X_Hold_Unmatched_Invoices_Flag   VARCHAR2,
                       X_Match_Option			VARCHAR2,
		       X_Create_Debit_Memo_Flag		VARCHAR2,
                       --4552701 X_Exclusive_Payment_Flag         VARCHAR2,
                       X_Tax_Reporting_Site_Flag        VARCHAR2,
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
                       X_Validation_Number              NUMBER,
                       X_Exclude_Freight_From_Disc      VARCHAR2,
                       X_Vat_Registration_Num           VARCHAR2,
                       -- eTax Uptake X_Offset_Tax_Flag VARCHAR2,
                       X_Check_Digits                   VARCHAR2,
                       X_Bank_Number                    VARCHAR2,
                       X_Address_Line4                  VARCHAR2,
                       X_County                         VARCHAR2,
                       X_Address_Style                  VARCHAR2,
                       X_Language                       VARCHAR2,
                       X_Allow_Awt_Flag                 VARCHAR2,
                       X_Awt_Group_Id                   NUMBER,
                       X_Pay_Awt_Group_Id               NUMBER,--bug6664407
		       X_pay_on_code			VARCHAR2,
		       X_default_pay_site_id		NUMBER,
		       X_pay_on_receipt_summary_code	VARCHAR2,
		       X_Bank_Branch_Type		VARCHAR2,
		       X_EDI_ID_Number                  VARCHAR2, --Bug 7437549
		       /* 4552701
                       X_EDI_ID_Number			VARCHAR2,
		       X_EDI_Payment_Method		VARCHAR2,
		       X_EDI_Payment_Format		VARCHAR2,
		       X_EDI_Remittance_Method		VARCHAR2,
		       X_EDI_Remittance_Instruction	VARCHAR2,
		       X_EDI_transaction_handling	VARCHAR2,
                       eTax Uptake
		       X_Auto_Tax_Calc_Flag		VARCHAR2,
		       X_Auto_Tax_Calc_Override		VARCHAR2,
		       X_Amount_Includes_Tax_Flag	VARCHAR2,
		       X_AP_Tax_Rounding_Rule		VARCHAR2, */
		       X_Vendor_Site_Code_Alt		VARCHAR2,
		       X_Address_Lines_Alt		VARCHAR2,
                       X_global_attribute_category      VARCHAR2 DEFAULT NULL,
                       X_global_attribute1              VARCHAR2 DEFAULT NULL,
                       X_global_attribute2              VARCHAR2 DEFAULT NULL,
                       X_global_attribute3              VARCHAR2 DEFAULT NULL,
                       X_global_attribute4              VARCHAR2 DEFAULT NULL,
                       X_global_attribute5              VARCHAR2 DEFAULT NULL,
                       X_global_attribute6              VARCHAR2 DEFAULT NULL,
                       X_global_attribute7              VARCHAR2 DEFAULT NULL,
                       X_global_attribute8              VARCHAR2 DEFAULT NULL,
                       X_global_attribute9              VARCHAR2 DEFAULT NULL,
                       X_global_attribute10             VARCHAR2 DEFAULT NULL,
                       X_global_attribute11             VARCHAR2 DEFAULT NULL,
                       X_global_attribute12             VARCHAR2 DEFAULT NULL,
                       X_global_attribute13             VARCHAR2 DEFAULT NULL,
                       X_global_attribute14             VARCHAR2 DEFAULT NULL,
                       X_global_attribute15             VARCHAR2 DEFAULT NULL,
                       X_global_attribute16             VARCHAR2 DEFAULT NULL,
                       X_global_attribute17             VARCHAR2 DEFAULT NULL,
                       X_global_attribute18             VARCHAR2 DEFAULT NULL,
                       X_global_attribute19             VARCHAR2 DEFAULT NULL,
                       X_global_attribute20             VARCHAR2 DEFAULT NULL,
		       X_Bank_Charge_Bearer		VARCHAR2 DEFAULT NULL,
                       X_Ece_Tp_Location_Code           VARCHAR2 DEFAULT NULL,
		       X_Pcard_Site_Flag		VARCHAR2,
		       X_Country_of_Origin_Code		VARCHAR2,
		       X_calling_sequence	IN	VARCHAR2,
		       X_Shipping_Location_id	IN	NUMBER,
		       X_Supplier_Notif_Method          VARCHAR2, -- New Column
                       X_Email_Address                  VARCHAR2, -- New Column
                       --4552701 X_Remittance_email               VARCHAR2 DEFAULT NULL,
                       X_Primary_pay_site_flag          VARCHAR2 DEFAULT NULL,
		       --MO Access Control
		       X_Org_ID				NUMBER DEFAULT mo_global.get_current_org_id
  		       ) IS

  current_calling_sequence      varchar2(2000);
  debug_info                    varchar2(100);
  vendor_site_old 	 	po_vendor_sites.vendor_site_code%TYPE;
  total_sites                   number;

  BEGIN
--      Update the calling sequence
--
        current_calling_sequence := 'AP_VENDOR_SITES_PKG.UPDATE_ROW<-' ||
                                     X_calling_sequence;

-- Bug # 636963 Vendor site code can not be changed if same code exits in
-- a different org.
-- (This fix is now backed out, Bug 702458)
-- Get old site name.

/*    select vendor_site_code
    into   vendor_site_old
    from   po_vendor_sites
    where  rowid = X_rowid;

    select count(*)
    into   total_sites
    from   po_vendor_sites_all
    where  vendor_site_id =  X_vendor_site_id;

    if ( total_sites > 1 and ( vendor_site_old <> X_vendor_site_code))  then
       fnd_message.set_name('SQLAP','AP_SHARED_SITE');
       app_exception.raise_exception;
    end if; */

	Check_duplicate_vendor_site (x_vendor_id, x_vendor_site_code,
				    x_org_id,  --MO Access Control
				    x_rowid,
				    X_calling_sequence => current_calling_sequence);

	if (x_tax_reporting_site_flag = 'Y') then
		check_multiple_tax_sites (x_vendor_id, x_vendor_site_id,
				    x_org_id, --MO Access Control
				    X_calling_sequence => current_calling_sequence);
	end if;

    debug_info := 'Update PO_VENDOR_SITES';
    UPDATE ap_supplier_sites
    SET
       vendor_site_id                  =     X_Vendor_Site_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       vendor_id                       =     X_Vendor_Id,
       vendor_site_code                =     X_Vendor_Site_Code,
       last_update_login               =     X_Last_Update_Login,
       purchasing_site_flag            =     X_Purchasing_Site_Flag,
       rfq_only_site_flag              =     X_Rfq_Only_Site_Flag,
       pay_site_flag                   =     X_Pay_Site_Flag,
       attention_ar_flag               =     X_Attention_Ar_Flag,
       address_line1                   =     X_Address_Line1,
       address_line2                   =     X_Address_Line2,
       address_line3                   =     X_Address_Line3,
       city                            =     X_City,
       state                           =     X_State,
       zip                             =     X_Zip,
       province                        =     X_Province,
       country                         =     X_Country,
       area_code                       =     X_Area_Code,
       phone                           =     X_Phone,
       customer_num                    =     X_Customer_Num,
       ship_to_location_id             =     X_Ship_To_Location_Id,
       bill_to_location_id             =     X_Bill_To_Location_Id,
       ship_via_lookup_code            =     X_Ship_Via_Lookup_Code,
       freight_terms_lookup_code       =     X_Freight_Terms_Lookup_Code,
       fob_lookup_code                 =     X_Fob_Lookup_Code,
       inactive_date                   =     X_Inactive_Date,
       fax                             =     X_Fax,
       fax_area_code                   =     X_Fax_Area_Code,
       telex                           =     X_Telex,
       bank_account_name               =     X_Bank_Account_Name,
       bank_account_num                =     X_Bank_Account_Num,
       bank_num                        =     X_Bank_Num,
       bank_account_type               =     X_Bank_Account_Type,
       terms_date_basis                =     X_Terms_Date_Basis,
       current_catalog_num             =     X_Current_Catalog_Num,
       distribution_set_id             =     X_Distribution_Set_Id,
       accts_pay_code_combination_id   =     X_Accts_Pay_CCID,
       future_dated_payment_ccid       =     X_Future_Dated_Payment_CCID,
       prepay_code_combination_id      =     X_Prepay_Code_Combination_Id,
       pay_group_lookup_code           =     X_Pay_Group_Lookup_Code,
       payment_priority                =     X_Payment_Priority,
       terms_id                        =     X_Terms_Id,
       invoice_amount_limit            =     X_Invoice_Amount_Limit,
       pay_date_basis_lookup_code      =     X_Pay_Date_Basis_Lookup_Code,
       always_take_disc_flag           =     X_Always_Take_Disc_Flag,
       invoice_currency_code           =     X_Invoice_Currency_Code,
       payment_currency_code           =     X_Payment_Currency_Code,
       hold_all_payments_flag          =     X_Hold_All_Payments_Flag,
       hold_future_payments_flag       =     X_Hold_Future_Payments_Flag,
       hold_reason                     =     X_Hold_Reason,
       hold_unmatched_invoices_flag    =     X_Hold_Unmatched_Invoices_Flag,
       match_option		       =     X_Match_Option,
       create_debit_memo_flag	       =     X_Create_Debit_Memo_Flag,
       tax_reporting_site_flag         =     X_Tax_Reporting_Site_Flag,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       validation_number               =     X_Validation_Number,
       exclude_freight_from_discount   =     X_Exclude_Freight_From_Disc,
       vat_registration_num            =     X_Vat_Registration_Num,
       check_digits                    =     X_Check_Digits,
       bank_number                     =     X_Bank_Number,
       address_line4                   =     X_Address_Line4,
       county                          =     X_County,
       address_style                   =     X_Address_Style,
       language                        =     X_Language,
       allow_awt_flag                  =     X_Allow_Awt_Flag,
       awt_group_id                    =     X_Awt_Group_Id,
       pay_awt_group_id                =     X_Pay_Awt_Group_Id,--bug6664407
       pay_on_code		       =     X_pay_on_code,
       default_pay_site_id	       =     X_default_pay_site_id,
       pay_on_receipt_summary_code     =     X_pay_on_receipt_summary_code,
       Bank_Branch_Type	      	       =     X_Bank_Branch_Type,
       vendor_site_code_alt	       =     X_Vendor_Site_Code_Alt,
       address_lines_alt	       =     X_Address_Lines_Alt,
       global_attribute_category       =     X_global_attribute_category,
       global_attribute1               =     X_global_attribute1,
       global_attribute2               =     X_global_attribute2,
       global_attribute3               =     X_global_attribute3,
       global_attribute4               =     X_global_attribute4,
       global_attribute5               =     X_global_attribute5,
       global_attribute6               =     X_global_attribute6,
       global_attribute7               =     X_global_attribute7,
       global_attribute8               =     X_global_attribute8,
       global_attribute9               =     X_global_attribute9,
       global_attribute10              =     X_global_attribute10,
       global_attribute11              =     X_global_attribute11,
       global_attribute12              =     X_global_attribute12,
       global_attribute13              =     X_global_attribute13,
       global_attribute14              =     X_global_attribute14,
       global_attribute15              =     X_global_attribute15,
       global_attribute16              =     X_global_attribute16,
       global_attribute17              =     X_global_attribute17,
       global_attribute18              =     X_global_attribute18,
       global_attribute19              =     X_global_attribute19,
       global_attribute20              =     X_global_attribute20,
       Bank_Charge_Bearer              =     X_Bank_Charge_Bearer,
       Ece_Tp_Location_Code            =     X_Ece_Tp_Location_Code,
       Country_of_Origin_Code          =     X_Country_of_Origin_Code,
       Pcard_Site_Flag		       =     X_Pcard_Site_Flag,
       Supplier_Notif_Method	       =     X_Supplier_Notif_Method, -- New Column
       Email_Address		       =     X_Email_Address, -- New Column
       Primary_pay_site_flag           =     X_Primary_pay_site_flag,
       Edi_id_number                   =     X_EDI_ID_Number -- bug 7437549
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    debug_info := 'Update values in PO_LOCATION_ASSOCIATIONS';
    --Bug 2697177: Added the IF condition
    if (X_Shipping_Location_id is not null) then

       ap_po_locn_association_pkg.update_row(p_location_id           => X_Shipping_Location_id,
                                          p_vendor_id             => X_Vendor_Id,
                                          p_vendor_site_id        => X_Vendor_Site_Id,
                                          p_last_update_date      => X_Last_Update_Date,
                                          p_last_updated_by       => X_Last_Updated_By,
                                          p_last_update_login     => X_Last_Update_Login,
                                          p_creation_date         => X_Creation_Date,
                                          p_created_by            => X_Created_By,
					  p_org_id		  => X_Org_ID);	  --MO Access Control
  end if;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','VENDOR_SITE_ID = ' ||
              					  X_Vendor_Site_Id ||
						 ', ROWID = ' || X_Rowid);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

  PROCEDURE update_row(
         p_vendor_site_rec IN AP_VENDOR_PUB_PKG.r_vendor_site_rec_type,
         p_last_update_date IN DATE,
         p_last_updated_by IN NUMBER,
         p_last_update_login IN NUMBER,
         p_request_id IN NUMBER,
         p_program_application_id IN NUMBER,
         p_program_id IN NUMBER,
         p_program_update_date IN DATE,
         p_vendor_site_id IN NUMBER
        ) IS

  current_calling_sequence      varchar2(2000);
  debug_info                    varchar2(100);

  BEGIN

    debug_info := 'Update PO_VENDOR_SITES';

    --Bug 6216082 Begins. Added the following call to IGI package
     --Bug 7577497 Added another parameter to the function call p_pay_tax_grp_id
     IF (p_vendor_site_rec.Awt_Group_Id IS NOT NULL OR
	 p_vendor_site_rec.Pay_Awt_Group_Id  IS NOT NULL) THEN
     		IGI_CIS2007_UTIL_PKG.SUPPLIER_SITE_UPDATE(
     			p_vendor_id => p_vendor_site_rec.Vendor_Id,
     			p_vendor_site_id => p_vendor_site_id,
     			p_tax_grp_id => p_vendor_site_rec.Awt_Group_Id,
			p_pay_tax_grp_id => p_vendor_site_rec.Pay_Awt_Group_Id
     			);
     END IF;
   --Bug 6216082 Ends.

  UPDATE ap_supplier_sites_all
    SET
       last_update_date                =     p_Last_Update_Date,
       last_updated_by                 =     p_Last_Updated_By,
       vendor_id                       =     p_vendor_site_rec.Vendor_Id,
       vendor_site_code                =     p_vendor_site_rec.Vendor_Site_Code,
       last_update_login               =     p_Last_Update_Login,
       purchasing_site_flag            =     p_vendor_site_rec.Purchasing_Site_Flag,
       rfq_only_site_flag              =     p_vendor_site_rec.Rfq_Only_Site_Flag,
       pay_site_flag                   =     p_vendor_site_rec.Pay_Site_Flag,
       attention_ar_flag               =     p_vendor_site_rec.Attention_Ar_Flag,
       area_code                       =     p_vendor_site_rec.Area_Code,
       phone                           =     p_vendor_site_rec.Phone,
       customer_num                    =     p_vendor_site_rec.Customer_Num,
       ship_to_location_id             =     p_vendor_site_rec.Ship_To_Location_Id,
       bill_to_location_id             =     p_vendor_site_rec.Bill_To_Location_Id,
       ship_via_lookup_code            =     p_vendor_site_rec.Ship_Via_Lookup_Code,
       freight_terms_lookup_code       =     p_vendor_site_rec.Freight_Terms_Lookup_Code,
       fob_lookup_code                 =     p_vendor_site_rec.Fob_Lookup_Code,
       inactive_date                   =     p_vendor_site_rec.Inactive_Date,
       fax                             =     p_vendor_site_rec.Fax,
       fax_area_code                   =     p_vendor_site_rec.Fax_Area_Code,
       telex                           =     p_vendor_site_rec.Telex,
       terms_date_basis                =     p_vendor_site_rec.Terms_Date_Basis,
       distribution_set_id             =     p_vendor_site_rec.Distribution_Set_Id,
       accts_pay_code_combination_id   =     p_vendor_site_rec.Accts_Pay_Code_Combination_ID,
       future_dated_payment_ccid       =     p_vendor_site_rec.Future_Dated_Payment_CCID,
       prepay_code_combination_id      =     p_vendor_site_rec.Prepay_Code_Combination_Id,
       pay_group_lookup_code           =     p_vendor_site_rec.Pay_Group_Lookup_Code,
       payment_priority                =     p_vendor_site_rec.Payment_Priority,
       terms_id                        =     p_vendor_site_rec.Terms_Id,
       invoice_amount_limit            =     p_vendor_site_rec.Invoice_Amount_Limit,
       pay_date_basis_lookup_code      =     p_vendor_site_rec.Pay_Date_Basis_Lookup_Code,
       always_take_disc_flag           =     p_vendor_site_rec.Always_Take_Disc_Flag,
       invoice_currency_code           =     p_vendor_site_rec.Invoice_Currency_Code,
       payment_currency_code           =     p_vendor_site_rec.Payment_Currency_Code,
       hold_all_payments_flag          =     p_vendor_site_rec.Hold_All_Payments_Flag,
       hold_future_payments_flag       =     p_vendor_site_rec.Hold_Future_Payments_Flag,
       hold_reason                     =     p_vendor_site_rec.Hold_Reason,
       hold_unmatched_invoices_flag    =     p_vendor_site_rec.Hold_Unmatched_Invoices_Flag,
       match_option		       =     p_vendor_site_rec.Match_Option,
       create_debit_memo_flag	       =     p_vendor_site_rec.Create_Debit_Memo_Flag,
       tax_reporting_site_flag         =     p_vendor_site_rec.Tax_Reporting_Site_Flag,
       attribute_category              =     p_vendor_site_rec.Attribute_Category,
       attribute1                      =     p_vendor_site_rec.Attribute1,
       attribute2                      =     p_vendor_site_rec.Attribute2,
       attribute3                      =     p_vendor_site_rec.Attribute3,
       attribute4                      =     p_vendor_site_rec.Attribute4,
       attribute5                      =     p_vendor_site_rec.Attribute5,
       attribute6                      =     p_vendor_site_rec.Attribute6,
       attribute7                      =     p_vendor_site_rec.Attribute7,
       attribute8                      =     p_vendor_site_rec.Attribute8,
       attribute9                      =     p_vendor_site_rec.Attribute9,
       attribute10                     =     p_vendor_site_rec.Attribute10,
       attribute11                     =     p_vendor_site_rec.Attribute11,
       attribute12                     =     p_vendor_site_rec.Attribute12,
       attribute13                     =     p_vendor_site_rec.Attribute13,
       attribute14                     =     p_vendor_site_rec.Attribute14,
       attribute15                     =     p_vendor_site_rec.Attribute15,
       validation_number               =     p_vendor_site_rec.Validation_Number,
       exclude_freight_from_discount   =     p_vendor_site_rec.Exclude_Freight_From_Discount,
       check_digits                    =     p_vendor_site_rec.Check_Digits,
       allow_awt_flag                  =     p_vendor_site_rec.Allow_Awt_Flag,
       awt_group_id                    =     p_vendor_site_rec.Awt_Group_Id,
       pay_awt_group_id                =     p_vendor_site_rec.Pay_Awt_Group_Id,--bug6664407
       pay_on_code		       =     p_vendor_site_rec.pay_on_code,
       default_pay_site_id	       =     p_vendor_site_rec.default_pay_site_id,
       pay_on_receipt_summary_code     =     p_vendor_site_rec.pay_on_receipt_summary_code,
       vendor_site_code_alt	       =     p_vendor_site_rec.Vendor_Site_Code_Alt,
       global_attribute_category       =     p_vendor_site_rec.global_attribute_category,
       global_attribute1               =     p_vendor_site_rec.global_attribute1,
       global_attribute2               =     p_vendor_site_rec.global_attribute2,
       global_attribute3               =     p_vendor_site_rec.global_attribute3,
       global_attribute4               =     p_vendor_site_rec.global_attribute4,
       global_attribute5               =     p_vendor_site_rec.global_attribute5,
       global_attribute6               =     p_vendor_site_rec.global_attribute6,
       global_attribute7               =     p_vendor_site_rec.global_attribute7,
       global_attribute8               =     p_vendor_site_rec.global_attribute8,
       global_attribute9               =     p_vendor_site_rec.global_attribute9,
       global_attribute10              =     p_vendor_site_rec.global_attribute10,
       global_attribute11              =     p_vendor_site_rec.global_attribute11,
       global_attribute12              =     p_vendor_site_rec.global_attribute12,
       global_attribute13              =     p_vendor_site_rec.global_attribute13,
       global_attribute14              =     p_vendor_site_rec.global_attribute14,
       global_attribute15              =     p_vendor_site_rec.global_attribute15,
       global_attribute16              =     p_vendor_site_rec.global_attribute16,
       global_attribute17              =     p_vendor_site_rec.global_attribute17,
       global_attribute18              =     p_vendor_site_rec.global_attribute18,
       global_attribute19              =     p_vendor_site_rec.global_attribute19,
       global_attribute20              =     p_vendor_site_rec.global_attribute20,
       Bank_Charge_Bearer              =     p_vendor_site_rec.Bank_Charge_Bearer,
       Ece_Tp_Location_Code            =     p_vendor_site_rec.Ece_Tp_Location_Code,
       Country_of_Origin_Code          =     p_vendor_site_rec.Country_of_Origin_Code,
       Pcard_Site_Flag		       =     p_vendor_site_rec.Pcard_Site_Flag,
       Supplier_Notif_Method	       =     p_vendor_site_rec.Supplier_Notif_Method,
       Email_Address		       =     p_vendor_site_rec.Email_Address,
       Primary_pay_site_flag           =     p_vendor_site_rec.Primary_pay_site_flag,
       Location_Id		       =     p_vendor_site_rec.location_id,
       Party_Site_ID		       =     p_vendor_site_rec.party_site_id,
       Tolerance_Id		       =     p_vendor_site_rec.tolerance_id,
       Retainage_Rate		       =     p_vendor_site_rec.retainage_rate,
       Shipping_Control                =     p_vendor_site_rec.shipping_control,
       services_tolerance_id           =     p_vendor_site_rec.services_tolerance_id,
       gapless_inv_num_flag            =     p_vendor_site_rec.gapless_inv_num_flag,
       selling_company_identifier      =     p_vendor_site_rec.selling_company_identifier,
       duns_number                     =     p_vendor_site_rec.duns_number,     --bug6388041
       -- Bug 7300553 Start
       address_line1                   =     p_vendor_site_rec.address_line1,
       address_line2                   =     p_vendor_site_rec.address_line2,
       address_line3                   =     p_vendor_site_rec.address_line3,
       address_line4                   =     p_vendor_site_rec.address_line4,
       city                            =     p_vendor_site_rec.city,
       state                           =     p_vendor_site_rec.state,
       zip                             =     p_vendor_site_rec.zip,
       province                        =     p_vendor_site_rec.province,
       country                         =     p_vendor_site_rec.country,
       county                          =     p_vendor_site_rec.county,
       address_style                   =     p_vendor_site_rec.address_style,
       language                        =     p_vendor_site_rec.language,
       address_lines_alt               =     p_vendor_site_rec.address_lines_alt,
       -- Bug 7300553 End
       edi_id_number                   =     p_vendor_site_rec.edi_id_number, -- bug 7421397
        -- starting the Changes for CLM reference data management bug#9499174
        Cage_code                      =     p_vendor_site_rec.Cage_code,
        LEGAL_BUSINESS_NAME            =     p_vendor_site_rec.LEGAL_BUSINESS_NAME,
        DOING_BUS_AS_NAME              =     p_vendor_site_rec.DOING_BUS_AS_NAME,
        division_name                  =     p_vendor_site_rec.division_name,
        small_business_code            =     p_vendor_site_rec.small_business_code,
        ccr_comments                   =     p_vendor_site_rec.ccr_comments,
        debarment_start_date           =     p_vendor_site_rec.debarment_start_date,
        debarment_end_date             =     p_vendor_site_rec.debarment_end_date
          -- Ending the Changes for CLM reference data management bug#9499174
    WHERE vendor_site_id = p_vendor_site_id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    debug_info := 'Update values in PO_LOCATION_ASSOCIATIONS';
    if (p_vendor_site_rec.Shipping_Location_id is not null) then

       ap_po_locn_association_pkg.update_row(
	        	p_location_id           => p_vendor_site_rec.Shipping_Location_id,
				/* 5945837: Shipping_Location_id is stored in po_location_associations*/
                p_vendor_id             => p_vendor_site_rec.Vendor_Id,
                p_vendor_site_id        => P_Vendor_Site_Id,
                p_last_update_date      => p_Last_Update_Date,
                p_last_updated_by       => p_Last_Updated_By,
                p_last_update_login     => p_Last_Update_Login,
                p_creation_date         => sysdate,
                p_created_by            => -1,
	  	p_org_id		  => p_vendor_site_rec.Org_ID);
   end if;

    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','VENDOR_SITE_ID = ' ||
              					  p_Vendor_Site_Id );
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

  END Update_Row;

--
--
procedure Check_vendor_offsets ( x_vendor_id		in number,
				 x_calling_sequence     in varchar2) is
        l_offset_count 			     number;
        current_calling_sequence             varchar2(2000);
        debug_info                           varchar2(100);
   begin
--         Update the calling sequence
--
           current_calling_sequence := 'AP_VENDOR_SITES_PKG.CHECK_VENDOR_OFFSETS
<-' ||
                                        X_calling_sequence;

           debug_info := 'Count sites with offset';
           SELECT  count(1)
           INTO    l_offset_count
           FROM    ap_supplier_sites
           WHERE   vendor_id = x_vendor_id
           AND     nvl(offset_tax_flag, 'N') <> 'N';
--
           if (l_offset_count > 0 ) then
                fnd_message.set_name('SQLAP','AP_CLEAR_SITE_OFFSET');
                app_exception.raise_exception;
           end if;
    EXCEPTION
        WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence)
;
              FND_MESSAGE.SET_TOKEN('PARAMETERS','VENDOR_ID = ' ||
                                                  X_Vendor_Id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

END CHECK_VENDOR_OFFSETS;

--
--
procedure Check_duplicate_vendor_site (	x_vendor_id		in number,
					x_vendor_site_code	in varchar2,
					--MO Access Control
					x_org_id		in number
                                          DEFAULT mo_global.get_current_org_id ,
					x_rowid			in varchar2,
					X_calling_sequence	in varchar2) is
	L_Duplicate_count	number;
        current_calling_sequence             varchar2(2000);
        debug_info                           varchar2(100);
begin
--      Update the calling sequence
--
        current_calling_sequence := 'AP_VENDOR_SITES_PKG.CHECK_DUPLICATE_VENDOR_SITE<-' ||
                                     X_calling_sequence;

	debug_info := 'Count duplicates for vendor_id and site_code';
	SELECT count(1)
	INTO   L_Duplicate_count
	FROM   po_vendor_sites
	WHERE  (rowid <> x_rowid or x_rowid IS NULL)
	AND    vendor_id = x_vendor_id
	AND    UPPER(vendor_site_code) = UPPER(x_vendor_site_code)
	AND    nvl(org_id,-99) = nvl(x_org_id,-99);        --MO Access Control

	   if (L_duplicate_count > 0 ) then
		fnd_message.set_name('SQLAP','AP_VEN_DUPLICATE_VEN_SITE');
		app_exception.raise_exception;
	   end if;
        EXCEPTION
         WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','VENDOR_ID = ' || x_vendor_id ||
					', VENDOR_SITE_CODE = ' || x_vendor_site_code ||
					', ROWID = ' || x_rowid);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

end Check_duplicate_vendor_site;
--
--
procedure Check_Multiple_Tax_Sites(	x_vendor_id		in number,
					x_vendor_site_id	in number,
					--MO Access Control
					x_org_id		in number
                                          DEFAULT mo_global.get_current_org_id,
					X_calling_sequence	in varchar2 ) is
	L_Multiple_count number;
        current_calling_sequence             varchar2(2000);
        debug_info                           varchar2(100);
begin
--      Update the calling sequence
--
        current_calling_sequence := 'AP_VENDOR_SITES_PKG.CHECK_MULTIPLE_TAX_SITES<-' ||
                                     X_calling_sequence;
	debug_info := 'Count tax reporting sites (vendor_id = ' || x_vendor_id || ')';
	SELECT count(1)
	INTO   L_Multiple_count
	FROM   ap_supplier_sites
	WHERE  vendor_id = x_vendor_id
	AND    tax_reporting_site_flag = 'Y'
	AND    vendor_site_id <> nvl(x_vendor_site_id,-999)
	AND    nvl(org_id,-99) = nvl(x_org_id,-99);		--MO Access Control

	   if (L_multiple_count > 0 ) then
		fnd_message.set_name('SQLAP','AP_VEN_ERROR_TAX_SITE');
		app_exception.raise_exception;
	   end if;
        EXCEPTION
         WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','VENDOR_SITE_ID = ' ||
              					  X_Vendor_Site_Id ||
						 ', VENDOR_ID = ' || x_vendor_id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

end Check_Multiple_Tax_sites;
--
--
Procedure Check_Site_Currencies(	x_vendor_id		in number,
					x_base_Currency_Code	in varchar2,
					X_calling_sequence	in varchar2) is
	L_overlap_count	number;
        current_calling_sequence             varchar2(2000);
        debug_info                           varchar2(100);
   begin
--         Update the calling sequence
--
           current_calling_sequence := 'AP_VENDOR_SITES_PKG.CHECK_SITE_CURRENCIES<-' ||
                                        X_calling_sequence;

	   debug_info := 'Count sites not in base currency for vendor_id';
	   SELECT  count(1)
	   INTO	   L_overlap_count
	   FROM	   po_vendor_sites
	   WHERE   vendor_id = x_vendor_id
	   AND     (invoice_currency_code <> x_Base_Currency_Code
	   OR	   invoice_currency_code IS NULL);

	   if (L_overlap_count > 0 ) then
		fnd_message.set_name('SQLAP','AP_AWT_SITES_NOT_BASE');
		app_exception.raise_exception;
	   end if;
        EXCEPTION
         WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','VENDOR_ID = ' ||  X_Vendor_Id ||
					         ', BASE_CURRENCY_CODE = ' ||
						    x_base_currency_code);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

end Check_Site_Currencies;
--
--
procedure Get_Tax_Site(			x_vendor_id		in number,
					x_vendor_site_code	in out NOCOPY varchar2,
					--MO Access Control
					x_org_id	        in number
                                          Default mo_global.get_current_org_id ,
					x_calling_sequence	in varchar2 ) is

        current_calling_sequence        varchar2(2000);
        debug_info                      varchar2(100);
begin
--         Update the calling sequence
--
           current_calling_sequence := 'AP_VENDOR_SITES_PKG.GET_TAX_SITE<-' ||
                                        X_calling_sequence;

	   debug_info := 'Return Vendor Site ID for tax reporting site';
        -- use table since policy context can be set in
        -- the suppliers form to an OU different from the one we want to
        -- select the tax site

	SELECT 	vendor_site_code
	INTO	x_vendor_site_code
	FROM	po_vendor_sites_all
	WHERE	vendor_id = x_vendor_id
	AND     nvl(org_id,-99) = nvl(x_org_id,-99)
	AND	Tax_Reporting_Site_Flag = 'Y';

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			x_vendor_site_code := '';
         	WHEN OTHERS THEN
           	    IF (SQLCODE <> -20001) THEN
              		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              		FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              		FND_MESSAGE.SET_TOKEN('PARAMETERS','VENDOR_ID = ' || x_vendor_id);
              		FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           	    END IF;
           	APP_EXCEPTION.RAISE_EXCEPTION;

end get_tax_Site;


Procedure Check_State_Codes(		x_vendor_id		in number,
					x_calling_sequence	in varchar2) is

        current_calling_sequence        varchar2(2000);
        debug_info                      varchar2(100);
	L_Return_Count			number;
begin
--         Update the calling sequence
--
           current_calling_sequence := 'AP_VENDOR_SITES_PKG.CHECK_STATE_CODES<-' ||
                                        X_calling_sequence;

	   	debug_info := 'Check that all Site State Codes are valid for US sites';

		SELECT	count(1)
		INTO	L_Return_Count
		FROM   	po_vendor_sites
		WHERE  	vendor_id = x_vendor_id
		AND    	country = 'US'
		AND    	nvl(state,'99') not in (SELECT region_short_name
                		                   FROM AP_income_tax_regions);
 		if (L_Return_count > 0 ) then
			fnd_message.set_name('SQLAP','AP_VEN_WARN_INV_STATE');
			app_exception.raise_exception;
	   	end if;

        EXCEPTION
         WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','VENDOR_ID = ' ||X_Vendor_Id);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

end Check_State_Codes;
--
--
procedure Check_duplicate_ece_code ( x_vendor_id             in number,
                                     x_ece_tp_location_code  in varchar2,
                                     x_rowid                 in varchar2,
				     --MO Access Control
				     x_org_id		     in varchar2
                                       Default mo_global.get_current_org_id ,
                                     X_calling_sequence      in varchar2) is
        L_Duplicate_count       number;
        current_calling_sequence             varchar2(2000);
        debug_info                           varchar2(100);
begin
--      Update the calling sequence
--
        current_calling_sequence := 'AP_VENDOR_SITES_PKG.CHECK_DUPLICATE_ECE_CODE<-' ||
                                     X_calling_sequence;

        debug_info := 'Count duplicates for vendor_id and site_code';
        SELECT count(1)
        INTO   L_Duplicate_count
        FROM   po_vendor_sites
        WHERE  (rowid <> x_rowid or x_rowid IS NULL)
        AND    vendor_id = x_vendor_id
        AND    UPPER(ece_tp_location_code) = UPPER(x_ece_tp_location_code)
	--MO Access Control
	AND    nvl(org_id,-99) = nvl(x_org_id,-99);

           if (L_duplicate_count > 0 ) then
                fnd_message.set_name('SQLAP','AP_VEN_DUPLICATE_ECE_CODE');
                app_exception.raise_exception;
           end if;
        EXCEPTION
         WHEN OTHERS THEN
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              FND_MESSAGE.SET_TOKEN('PARAMETERS','VENDOR_ID = ' || x_vendor_id ||
                                        ', ECE_TP_LOCATION_CODE = ' || x_ece_tp_location_code ||
                                        ', ROWID = ' || x_rowid);
              FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           END IF;
           APP_EXCEPTION.RAISE_EXCEPTION;

end Check_duplicate_ece_code;



END AP_VENDOR_SITES_PKG;

/
