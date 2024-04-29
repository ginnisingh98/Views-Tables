--------------------------------------------------------
--  DDL for Package Body AP_VENDORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_VENDORS_PKG" as
/* $Header: apvndhrb.pls 120.15.12010000.3 2008/12/29 07:57:16 mayyalas ship $ */
--
--
	FUNCTION Update_Product_Setup Return Number;

  PROCEDURE Insert_Row (
		x_Rowid		IN OUT NOCOPY		VARCHAR2,
		x_Vendor_Id	IN OUT NOCOPY		NUMBER,
		x_Last_Update_Date			DATE,
		x_Last_Updated_By			NUMBER,
		x_Vendor_Name				VARCHAR2,
		x_Segment1	IN OUT NOCOPY		VARCHAR2,
		x_Summary_Flag				VARCHAR2,
		x_Enabled_Flag				VARCHAR2,
		x_Last_Update_Login			NUMBER,
		x_Creation_Date				DATE,
		x_Created_By				NUMBER,
		x_Employee_Id				NUMBER,
		x_Validation_Number			NUMBER,
		x_Vendor_Type_Lookup_Code		VARCHAR2,
		x_Customer_Num				VARCHAR2,
		x_One_Time_Flag				VARCHAR2,
		x_Parent_Vendor_Id			NUMBER,
		x_Min_Order_Amount			NUMBER,
		--Bug :2809214 MOAC - Supplier Attribute Change Project
		/* x_Ship_To_Location_ID		NUMBER,
		x_Bill_To_Location_Id			NUMBER,
		x_Ship_Via_Lookup_Code			VARCHAR2,
		x_Freight_Terms_Lookup_Code		VARCHAR2,
		x_Fob_Lookup_Code			VARCHAR2, */
		x_Terms_Id				NUMBER,
		x_Set_Of_Books_Id			NUMBER,
		x_Always_Take_Disc_Flag			VARCHAR2,
		x_Pay_Date_Basis_Lookup_Code		VARCHAR2,
		x_Pay_Group_Lookup_Code			VARCHAR2,
		x_Payment_Priority			NUMBER,
		x_Invoice_Currency_Code			VARCHAR2,
		x_Payment_Currency_Code			VARCHAR2,
		x_Invoice_Amount_Limit			NUMBER,
		x_Hold_All_Payments_Flag		VARCHAR2,
		x_Hold_Future_Payments_Flag		VARCHAR2,
		x_Hold_Reason				VARCHAR2,
		--Bug :2809214 MOAC - Supplier Attribute Change Project
		/* x_Distribution_Set_Id		NUMBER,
		x_Accts_Pay_CCID			NUMBER,
		x_Future_Dated_Payment_CCID		NUMBER,
		x_Prepay_CCID				NUMBER, */
		x_Num_1099				VARCHAR2,
		x_Type_1099				VARCHAR2,
		x_withholding_stat_Lookup_Code		VARCHAR2,
		x_Withholding_Start_Date		DATE,
		x_Org_Type_Lookup_Code			VARCHAR2,
		-- eTax Uptake x_Vat_Code		VARCHAR2,
		x_Start_Date_Active			DATE,
		x_End_Date_Active			DATE,
		x_Qty_Rcv_Tolerance			NUMBER,
		x_Minority_Group_Lookup_Code		VARCHAR2,
		--4552701 x_Payment_Method_Lookup_Code		VARCHAR2,
		x_Bank_Account_Name			VARCHAR2,
		x_Bank_Account_Num			VARCHAR2,
		x_Bank_Num				VARCHAR2,
		x_Bank_Account_Type			VARCHAR2,
		x_Women_Owned_Flag			VARCHAR2,
		x_Small_Business_Flag			VARCHAR2,
		x_Standard_Industry_Class		VARCHAR2,
		x_Attribute_Category			VARCHAR2,
		x_Attribute1				VARCHAR2,
		x_Attribute2				VARCHAR2,
		x_Attribute3				VARCHAR2,
		x_Attribute4				VARCHAR2,
		x_Attribute5				VARCHAR2,
		x_Hold_Flag				VARCHAR2,
		x_Purchasing_Hold_Reason		VARCHAR2,
		x_Hold_By				NUMBER,
		x_Hold_Date				DATE,
		x_Terms_Date_Basis			VARCHAR2,
		x_Price_Tolerance			NUMBER,
		x_Attribute10				VARCHAR2,
		x_Attribute11				VARCHAR2,
		x_Attribute12				VARCHAR2,
		x_Attribute13				VARCHAR2,
		x_Attribute14				VARCHAR2,
		x_Attribute15				VARCHAR2,
		x_Attribute6				VARCHAR2,
		x_Attribute7				VARCHAR2,
		x_Attribute8				VARCHAR2,
		x_Attribute9				VARCHAR2,
		x_Days_Early_Receipt_Allowed		NUMBER,
		x_Days_Late_Receipt_Allowed		NUMBER,
		x_Enforce_Ship_To_Loc_Code		VARCHAR2,
		--4552701 x_Exclusive_Payment_Flag		VARCHAR2,
		x_Federal_Reportable_Flag		VARCHAR2,
		x_Hold_Unmatched_Invoices_Flag		VARCHAR2,
		x_match_option				VARCHAR2,
		x_create_debit_memo_flag		VARCHAR2,
		x_Inspection_Required_Flag		VARCHAR2,
		x_Receipt_Required_Flag			VARCHAR2,
		x_Receiving_Routing_Id			NUMBER,
		x_State_Reportable_Flag			VARCHAR2,
		x_Tax_Verification_Date			DATE,
		x_Auto_Calculate_Interest_Flag		VARCHAR2,
		x_Name_Control				VARCHAR2,
		x_Allow_Subst_Receipts_Flag		VARCHAR2,
		x_Allow_Unord_Receipts_Flag		VARCHAR2,
		x_Receipt_Days_Exception_Code		VARCHAR2,
		x_Qty_Rcv_Exception_Code		VARCHAR2,
		-- eTax Uptake x_Offset_Tax_Flag	VARCHAR2,
		x_Exclude_Freight_From_Disc		VARCHAR2,
		x_Vat_Registration_Num			VARCHAR2,
		x_Tax_Reporting_Name			VARCHAR2,
		x_Awt_Group_Id				NUMBER,
                x_Pay_Awt_Group_Id                      NUMBER,--bug6664407
		x_Check_Digits				VARCHAR2,
		x_Bank_Number				VARCHAR2,
		x_Allow_Awt_Flag			VARCHAR2,
		x_Bank_Branch_Type			VARCHAR2,
		/* 4552701
                x_EDI_Payment_Method			VARCHAR2,
		x_EDI_Payment_Format			VARCHAR2,
		x_EDI_Remittance_Method			VARCHAR2,
		x_EDI_Remittance_Instruction		VARCHAR2,
		x_EDI_transaction_handling		VARCHAR2,
		eTax Uptake
		x_Auto_Tax_Calc_Flag			VARCHAR2,
		x_Auto_Tax_Calc_Override		VARCHAR2,
		x_Amount_Includes_Tax_Flag		VARCHAR2,
		x_AP_Tax_Rounding_Rule			VARCHAR2,*/
		x_Vendor_Name_Alt			VARCHAR2,
                X_global_attribute_category             VARCHAR2 DEFAULT NULL,
                X_global_attribute1                     VARCHAR2 DEFAULT NULL,
                X_global_attribute2                     VARCHAR2 DEFAULT NULL,
                X_global_attribute3                     VARCHAR2 DEFAULT NULL,
                X_global_attribute4                     VARCHAR2 DEFAULT NULL,
                X_global_attribute5                     VARCHAR2 DEFAULT NULL,
                X_global_attribute6                     VARCHAR2 DEFAULT NULL,
                X_global_attribute7                     VARCHAR2 DEFAULT NULL,
                X_global_attribute8                     VARCHAR2 DEFAULT NULL,
                X_global_attribute9                     VARCHAR2 DEFAULT NULL,
                X_global_attribute10                    VARCHAR2 DEFAULT NULL,
                X_global_attribute11                    VARCHAR2 DEFAULT NULL,
                X_global_attribute12                    VARCHAR2 DEFAULT NULL,
                X_global_attribute13                    VARCHAR2 DEFAULT NULL,
                X_global_attribute14                    VARCHAR2 DEFAULT NULL,
                X_global_attribute15                    VARCHAR2 DEFAULT NULL,
                X_global_attribute16                    VARCHAR2 DEFAULT NULL,
                X_global_attribute17                    VARCHAR2 DEFAULT NULL,
                X_global_attribute18                    VARCHAR2 DEFAULT NULL,
                X_global_attribute19                    VARCHAR2 DEFAULT NULL,
                X_global_attribute20                    VARCHAR2 DEFAULT NULL,
                X_Bank_Charge_Bearer			VARCHAR2 DEFAULT NULL,
		X_NI_Number				VARCHAR2 DEFAULT NULL,
		X_calling_sequence		IN	VARCHAR2 ) IS

		CURSOR C IS
		SELECT 		rowid
		FROM		po_vendors
		WHERE		vendor_id = x_Vendor_Id;

    		current_calling_sequence    VARCHAR2(2000);
    		debug_info                  VARCHAR2(100);
                l_supplier_numbering_method VARCHAR2(25);

	BEGIN
	--     Update the calling sequence
	--
        current_calling_sequence := 'AP_VENDORS_PKG.INSERT_ROW<-' ||
                                    X_calling_sequence;

	--
	-- error out NOCOPY if Vendor name has been assigned by another session
	--
	ap_vendors_pkg.check_unique_vendor_name( p_vendor_id   =>   x_vendor_id,
						 p_vendor_name =>   x_vendor_name,
						 X_calling_sequence => current_calling_sequence );
	--
	-- error out NOCOPY if employee has been assigned by another session
	--
	ap_vendors_pkg.Check_Duplicate_Employee(p_rowid		=>	x_rowid,
				    		p_employee_id	=>	x_employee_id,
						X_calling_sequence => current_calling_sequence);
	--
	-- assign automatic Vendor number if needed
	--
	--Bug :2809214 MOAC - Supplier Attribute Change Project
        /* select user_defined_vendor_num_code
        into   l_ven_num_code
        from   financials_system_parameters; */

        select supplier_numbering_method
	into l_supplier_numbering_method
	from ap_product_setup;

	if (nvl(l_supplier_numbering_method,'AUTOMATIC') = 'AUTOMATIC') then

		debug_info := 'assign automatic Vendor number';

		--Bug :2809214 MOAC - Supplier Attribute Change Project
		--Replaced the 2 SQLs with the below 2 SQLs.
	        /* UPDATE PO_UNIQUE_IDENTIFIER_CONTROL
		SET current_max_unique_identifier = current_max_unique_identifier + 1
        	WHERE  table_name = 'PO_VENDORS';

     		--
		--
		debug_info := 'Select current_max_unique_identifier';
     	   	SELECT 	current_max_unique_identifier
     	    	INTO   	x_segment1
     	    	FROM   	po_unique_identifier_control
     	    	WHERE  	table_name = 'PO_VENDORS'; */

		-- Bug 6830122. Replacing following two statements with
    -- autonomus transactions
    /*SELECT next_auto_supplier_num
		INTO x_segment1
		FROM ap_product_setup ;

		UPDATE ap_product_setup
		SET next_auto_supplier_num = next_auto_supplier_num + 1;*/
		x_segment1 := Update_Product_Setup;

	end if;
	--
	--
	ap_vendors_pkg.check_unique_vendor_number( p_vendor_id     => x_vendor_id,
						   p_vendor_number => x_segment1,
						   X_calling_sequence => current_calling_sequence );
	--
	--
		debug_info := 'Select next sequence value from PO_VENDORS_S';
		Select  PO_VENDORS_S.NEXTVAL
		into	x_vendor_id
		from 	sys.dual;
	--
	--
		debug_info := 'Insert into PO_VENDORS';
		INSERT INTO	ap_suppliers (
		vendor_id,
		last_update_date,
		last_updated_by,
		vendor_name,
		segment1,
		summary_flag,
		enabled_flag,
		last_update_login,
		creation_date,
		created_by,
		employee_id,
		validation_number,
		vendor_type_lookup_code,
		customer_num,
		one_time_flag,
		parent_vendor_id,
		min_order_amount,
		--Bug :2809214 MOAC - Supplier Attribute Change Project
		/* ship_to_location_id,
		bill_to_location_id,
		ship_via_lookup_code,
		freight_terms_lookup_code,
		fob_lookup_code, */
		terms_id,
		set_of_books_id,
		always_take_disc_flag,
		pay_date_basis_lookup_code,
		pay_group_lookup_code,
		payment_priority,
		invoice_currency_code,
		payment_currency_code,
		invoice_amount_limit,
		hold_all_payments_flag,
		hold_future_payments_flag,
		hold_reason,
		--Bug :2809214 MOAC - Supplier Attribute Change Project
		/* distribution_set_id,
		accts_pay_code_combination_id,
		future_dated_payment_ccid,
		prepay_code_combination_id, */
		num_1099,
		type_1099,
		withholding_status_lookup_code,
		withholding_start_date,
		organization_type_lookup_code,
		start_date_active,
		end_date_active,
		qty_rcv_tolerance,
		minority_group_lookup_code,
		bank_account_name,
		bank_account_num,
		bank_num,
		bank_account_type,
		women_owned_flag,
		small_business_flag,
		standard_industry_class,
		attribute_category,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		hold_flag,
		purchasing_hold_reason,
		hold_by,
		hold_date,
		terms_date_basis,
		price_tolerance,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		days_early_receipt_allowed,
		days_late_receipt_allowed,
		enforce_ship_to_location_code,
		federal_reportable_flag,
		hold_unmatched_invoices_flag,
		match_option,
		create_debit_memo_flag,
		inspection_required_flag,
		receipt_required_flag,
		receiving_routing_id,
		state_reportable_flag,
		tax_verification_date,
		auto_calculate_interest_flag,
		name_control,
		allow_substitute_receipts_flag,
		allow_unordered_receipts_flag,
		receipt_days_exception_code,
		qty_rcv_exception_code,
		exclude_freight_from_discount,
		vat_registration_num,
		tax_reporting_name,
		awt_group_id,
                pay_awt_group_id,--bug6664407
		check_digits,
		bank_number,
		allow_awt_flag,
		bank_branch_type,
		vendor_name_alt,
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
                bank_charge_bearer,
		--Bug :2809214 MOAC - Supplier Attribute Change Project
		NI_Number)

	VALUES (
		x_Vendor_Id,
		x_Last_Update_Date,
		x_Last_Updated_By,
		x_Vendor_Name,
		x_Segment1,
		'N',
		'Y',
		x_Last_Update_Login,
		x_Creation_Date,
		x_Created_By,
		x_Employee_Id,
		x_Validation_Number,
		x_Vendor_Type_Lookup_Code,
		x_Customer_Num,
		x_One_Time_Flag,
		x_Parent_Vendor_Id,
		x_Min_Order_Amount,
		--Bug :2809214 MOAC - Supplier Attribute Change Project
		/* x_Ship_To_Location_Id,
		x_Bill_To_Location_Id,
		x_Ship_Via_Lookup_Code,
		x_Freight_Terms_Lookup_Code,
		x_Fob_Lookup_Code, */
		x_Terms_Id,
		x_Set_Of_Books_Id,
		x_Always_Take_Disc_Flag,
		x_Pay_Date_Basis_Lookup_Code,
		x_Pay_Group_Lookup_Code,
		x_Payment_Priority,
		x_Invoice_Currency_Code,
		x_Payment_Currency_Code,
		x_Invoice_Amount_Limit,
		x_Hold_All_Payments_Flag,
		x_Hold_Future_Payments_Flag,
		x_Hold_Reason,
		--Bug :2809214 MOAC - Supplier Attribute Change Project
		/* x_Distribution_Set_Id,
		x_Accts_Pay_CCID,
		x_Future_Dated_Payment_CCID,
		x_Prepay_CCID, */
		x_Num_1099,
		x_Type_1099,
		x_withholding_stat_Lookup_Code,
		x_Withholding_Start_Date,
		x_Org_Type_Lookup_Code,
		x_Start_Date_Active,
		x_End_Date_Active,
		x_Qty_Rcv_Tolerance,
		x_Minority_Group_Lookup_Code,
		x_Bank_Account_Name,
		x_Bank_Account_Num,
		x_Bank_Num,
		x_Bank_Account_Type,
		x_Women_Owned_Flag,
		x_Small_Business_Flag,
		x_Standard_Industry_Class,
		x_Attribute_Category,
		x_Attribute1,
		x_Attribute2,
		x_Attribute3,
		x_Attribute4,
		x_Attribute5,
		x_Hold_Flag,
		x_Purchasing_Hold_Reason,
		x_Hold_By,
		x_Hold_Date,
		x_Terms_Date_Basis,
		x_Price_Tolerance,
		x_Attribute10,
		x_Attribute11,
		x_Attribute12,
		x_Attribute13,
		x_Attribute14,
		x_Attribute15,
		x_Attribute6,
		x_Attribute7,
		x_Attribute8,
		x_Attribute9,
		x_Days_Early_Receipt_Allowed,
		x_Days_Late_Receipt_Allowed,
		x_Enforce_Ship_To_Loc_Code,
		x_Federal_Reportable_Flag,
		x_Hold_Unmatched_Invoices_Flag,
		x_match_option,
		x_create_debit_memo_flag,
		x_Inspection_Required_Flag,
		x_Receipt_Required_Flag,
		x_Receiving_Routing_Id,
		x_State_Reportable_Flag,
		x_Tax_Verification_Date,
		x_Auto_Calculate_Interest_Flag,
		x_Name_Control,
		x_Allow_Subst_Receipts_Flag,
		x_Allow_Unord_Receipts_Flag,
		x_Receipt_Days_Exception_Code,
		x_Qty_Rcv_Exception_Code,
		x_Exclude_Freight_From_Disc,
		x_Vat_Registration_Num,
		x_Tax_Reporting_Name,
		x_Awt_Group_Id,
                x_Pay_Awt_Group_Id,--bug6664407
		x_Check_Digits,
		x_Bank_Number,
		x_Allow_Awt_Flag,
		x_bank_branch_type,
		x_Vendor_Name_Alt,
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
		--Bug :2809214 MOAC - Supplier Attribute Change Project
		X_NI_Number);
--
		debug_info := 'Open cursor C';
		OPEN 	C;
		debug_info := 'Fetch cursor C';
		FETCH 	C INTO x_Rowid;
			if (C%NOTFOUND) then
				debug_info := 'Close cursor C  - NOTFOUND';
				CLOSE C;
				Raise NO_DATA_FOUND;
			end if;
		debug_info := 'Close cursor C';
		CLOSE	C;

    		EXCEPTION
        	  WHEN OTHERS THEN
           	    IF (SQLCODE <> -20001) THEN
              		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              		FND_MSG_PUB.ADD;
              		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              		FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              		FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
							', VENDOR_ID = ' || x_Vendor_Id);
              		FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           	    END IF;
                    APP_EXCEPTION.RAISE_EXCEPTION;

	END Insert_Row;

	PROCEDURE Insert_Row(
                p_vendor_rec IN AP_VENDOR_PUB_PKG.r_vendor_rec_type,
                p_last_update_date IN DATE,
                p_last_updated_by  IN NUMBER,
                p_last_update_login  IN NUMBER,
                p_creation_date  IN DATE,
                p_created_by  IN NUMBER,
                p_request_id  IN NUMBER,
                p_program_application_id  IN NUMBER,
                p_program_id  IN NUMBER,
                p_program_update_date  IN DATE,
                x_rowid OUT NOCOPY VARCHAR2,
                x_vendor_id OUT NOCOPY NUMBER) IS

		CURSOR C IS
		SELECT 		rowid
		FROM		po_vendors
		WHERE		vendor_id = x_Vendor_Id;

    		current_calling_sequence    VARCHAR2(2000);
    		debug_info                  VARCHAR2(100);
                l_supplier_numbering_method VARCHAR2(25);
		l_segment1		    VARCHAR2(30);
	BEGIN

        select supplier_numbering_method
	into l_supplier_numbering_method
	from ap_product_setup;

	if (nvl(l_supplier_numbering_method,'AUTOMATIC') = 'AUTOMATIC') then

		debug_info := 'assign automatic Vendor number';

		-- Bug 6830122. Replacing following two statements with
    -- autonomus transactions

		/*SELECT next_auto_supplier_num
		INTO l_segment1
		FROM ap_product_setup ;

		UPDATE ap_product_setup
		SET next_auto_supplier_num = next_auto_supplier_num + 1;*/
		l_segment1 := Update_Product_Setup;

	end if;

	-- Bug 6940256 udhenuko check for duplicate vendor_numbers
	check_unique_vendor_number( p_vendor_id     => x_vendor_id,
						   p_vendor_number => l_segment1,
						   X_calling_sequence => current_calling_sequence );
	-- Bug 6940256 End
	--
	--
		debug_info := 'Select next sequence value from PO_VENDORS_S';
		Select  PO_VENDORS_S.NEXTVAL
		into	x_vendor_id
		from 	sys.dual;
	--
	--

		debug_info := 'Insert into ap_suppliers';
		INSERT INTO	ap_suppliers (
		vendor_id,
		last_update_date,
		last_updated_by,
		segment1,
		summary_flag,
		enabled_flag,
		last_update_login,
		creation_date,
		created_by,
		employee_id,
		validation_number,
		vendor_type_lookup_code,
		customer_num,
                standard_industry_class, -- Bug 5066199
		one_time_flag,
		parent_vendor_id,
		min_order_amount,
		terms_id,
		set_of_books_id,
		always_take_disc_flag,
		pay_date_basis_lookup_code,
		pay_group_lookup_code,
		payment_priority,
		invoice_currency_code,
		payment_currency_code,
		invoice_amount_limit,
		hold_all_payments_flag,
		hold_future_payments_flag,
		hold_reason,
                individual_1099,--bug6050423
		type_1099,
		withholding_status_lookup_code,
		withholding_start_date,
		organization_type_lookup_code,
		start_date_active,
		end_date_active,
		qty_rcv_tolerance,
		minority_group_lookup_code,
		women_owned_flag,
		small_business_flag,
		attribute_category,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		hold_flag,
		purchasing_hold_reason,
		hold_by,
		hold_date,
		terms_date_basis,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		days_early_receipt_allowed,
		days_late_receipt_allowed,
		enforce_ship_to_location_code,
		federal_reportable_flag,
		hold_unmatched_invoices_flag,
		match_option,
		create_debit_memo_flag,
		inspection_required_flag,
		receipt_required_flag,
		receiving_routing_id,
		state_reportable_flag,
		tax_verification_date,
		auto_calculate_interest_flag,
		name_control,
		allow_substitute_receipts_flag,
		allow_unordered_receipts_flag,
		receipt_days_exception_code,
		qty_rcv_exception_code,
		exclude_freight_from_discount,
		tax_reporting_name,
		awt_group_id,
                pay_awt_group_id,--bug6664407
		check_digits,
		allow_awt_flag,
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
                bank_charge_bearer,
		party_id,
		parent_party_id,
		ni_number)
	VALUES (
		x_Vendor_Id,
		p_Last_Update_Date,
		p_Last_Updated_By,
		decode(l_supplier_numbering_method, 'AUTOMATIC', l_segment1,
					p_vendor_rec.segment1),
		nvl(p_vendor_rec.summary_flag, 'N'),
		nvl(p_vendor_rec.enabled_flag, 'Y'),
		p_Last_Update_Login,
		p_Creation_Date,
		p_Created_By,
		p_vendor_rec.Employee_Id,
		p_vendor_rec.Validation_Number,
		p_vendor_rec.Vendor_Type_Lookup_Code,
		p_vendor_rec.Customer_Num,
                p_vendor_rec.sic_code, -- Bug 5066199
		p_vendor_rec.One_Time_Flag,
		p_vendor_rec.Parent_Vendor_Id,
		p_vendor_rec.Min_Order_Amount,
		p_vendor_rec.Terms_Id,
		p_vendor_rec.Set_Of_Books_Id,
		p_vendor_rec.Always_Take_Disc_Flag,
		p_vendor_rec.Pay_Date_Basis_Lookup_Code,
		p_vendor_rec.Pay_Group_Lookup_Code,
		p_vendor_rec.Payment_Priority,
		p_vendor_rec.Invoice_Currency_Code,
		p_vendor_rec.Payment_Currency_Code,
		p_vendor_rec.Invoice_Amount_Limit,
		p_vendor_rec.Hold_All_Payments_Flag,
		p_vendor_rec.Hold_Future_Payments_Flag,
		p_vendor_rec.Hold_Reason,
		--bug6050423 starts.System inserts the taxpayer of
		--non-employee individuals to the individual_1099 field.
		--we donot insert any value to num_1099,becas we update
		--it using the ap_tca_sync_pkg.sync_supplier
                --bug6691916.commented the below decode statement and added
		--the one below that.As per analysis,only organization type lookup
	        --code of individual or foreign individual are considered
	        --as individual suppliers
                /*decode(UPPER(p_vendor_rec.Vendor_Type_Lookup_Code),'CONTRACTOR',
			decode(UPPER(p_vendor_rec.Organization_Type_Lookup_Code),
				'INDIVIDUAL',p_vendor_rec.jgzz_fiscal_code,
				'FOREIGN INDIVIDUAL',p_vendor_rec.jgzz_fiscal_code,
				'PARTNERSHIP',p_vendor_rec.jgzz_fiscal_code,
				'INDIVIDUAL PARTNERSHIP',p_vendor_rec.jgzz_fiscal_code,
				NULL),
			NULL),*/
                decode(UPPER(p_vendor_rec.Organization_Type_Lookup_Code),
                                'INDIVIDUAL',p_vendor_rec.jgzz_fiscal_code,
				 'FOREIGN INDIVIDUAL',p_vendor_rec.jgzz_fiscal_code,
				NULL),
		--bug6050423 ends
		p_vendor_rec.Type_1099,
		p_vendor_rec.withholding_status_Lookup_Code,
		p_vendor_rec.Withholding_Start_Date,
		p_vendor_rec.Organization_Type_Lookup_Code,
		p_vendor_rec.Start_Date_Active,
		p_vendor_rec.End_Date_Active,
		p_vendor_rec.Qty_Rcv_Tolerance,
		p_vendor_rec.Minority_Group_Lookup_Code,
		p_vendor_rec.Women_Owned_Flag,
		p_vendor_rec.Small_Business_Flag,
		p_vendor_rec.Attribute_Category,
		p_vendor_rec.Attribute1,
		p_vendor_rec.Attribute2,
		p_vendor_rec.Attribute3,
		p_vendor_rec.Attribute4,
		p_vendor_rec.Attribute5,
		p_vendor_rec.Hold_Flag,
		p_vendor_rec.Purchasing_Hold_Reason,
		p_vendor_rec.Hold_By,
		p_vendor_rec.Hold_Date,
		p_vendor_rec.Terms_Date_Basis,
		p_vendor_rec.Attribute10,
		p_vendor_rec.Attribute11,
		p_vendor_rec.Attribute12,
		p_vendor_rec.Attribute13,
		p_vendor_rec.Attribute14,
		p_vendor_rec.Attribute15,
		p_vendor_rec.Attribute6,
		p_vendor_rec.Attribute7,
		p_vendor_rec.Attribute8,
		p_vendor_rec.Attribute9,
		p_vendor_rec.Days_Early_Receipt_Allowed,
		p_vendor_rec.Days_Late_Receipt_Allowed,
		p_vendor_rec.Enforce_Ship_To_Location_Code,
		p_vendor_rec.Federal_Reportable_Flag,
		p_vendor_rec.Hold_Unmatched_Invoices_Flag,
		p_vendor_rec.match_option,
		p_vendor_rec.create_debit_memo_flag,
		p_vendor_rec.Inspection_Required_Flag,
		p_vendor_rec.Receipt_Required_Flag,
		p_vendor_rec.Receiving_Routing_Id,
		p_vendor_rec.State_Reportable_Flag,
		p_vendor_rec.Tax_Verification_Date,
		p_vendor_rec.Auto_Calculate_Interest_Flag,
		p_vendor_rec.Name_Control,
		p_vendor_rec.allow_substitute_receipts_flag,
		p_vendor_rec.allow_unordered_receipts_flag,
		p_vendor_rec.Receipt_Days_Exception_Code,
		p_vendor_rec.Qty_Rcv_Exception_Code,
		p_vendor_rec.Exclude_Freight_From_Discount,
		p_vendor_rec.Tax_Reporting_Name,
		p_vendor_rec.Awt_Group_Id,
                p_vendor_rec.Pay_Awt_Group_Id,--bug6664407
		p_vendor_rec.Check_Digits,
		p_vendor_rec.Allow_Awt_Flag,
                p_vendor_rec.global_attribute_category,
                p_vendor_rec.global_attribute1,
                p_vendor_rec.global_attribute2,
                p_vendor_rec.global_attribute3,
                p_vendor_rec.global_attribute4,
                p_vendor_rec.global_attribute5,
                p_vendor_rec.global_attribute6,
                p_vendor_rec.global_attribute7,
                p_vendor_rec.global_attribute8,
                p_vendor_rec.global_attribute9,
                p_vendor_rec.global_attribute10,
                p_vendor_rec.global_attribute11,
                p_vendor_rec.global_attribute12,
                p_vendor_rec.global_attribute13,
                p_vendor_rec.global_attribute14,
                p_vendor_rec.global_attribute15,
                p_vendor_rec.global_attribute16,
                p_vendor_rec.global_attribute17,
                p_vendor_rec.global_attribute18,
                p_vendor_rec.global_attribute19,
                p_vendor_rec.global_attribute20,
                p_vendor_rec.Bank_Charge_Bearer,
		p_vendor_rec.party_id,
		p_vendor_rec.parent_party_id,
		p_vendor_rec.NI_Number);
--
		debug_info := 'Open cursor C';
		OPEN 	C;
		debug_info := 'Fetch cursor C';
		FETCH 	C INTO x_Rowid;
			if (C%NOTFOUND) then
				debug_info := 'Close cursor C  - NOTFOUND';
				CLOSE C;
				Raise NO_DATA_FOUND;
			end if;
		debug_info := 'Close cursor C';
		CLOSE	C;

    		EXCEPTION
        	  WHEN OTHERS THEN
           	    IF (SQLCODE <> -20001) THEN
              		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              		FND_MSG_PUB.ADD;
              		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              		FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              		FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || x_Rowid ||
							', VENDOR_ID = ' || x_vendor_Id);
              		FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           	    END IF;
                    APP_EXCEPTION.RAISE_EXCEPTION;

	END Insert_Row;
--
--
	PROCEDURE Update_Row (
		x_Rowid					VARCHAR2,
		x_Vendor_Id				NUMBER,
		x_Last_Update_Date			DATE,
		x_Last_Updated_By			NUMBER,
		x_Vendor_Name				VARCHAR2,
		x_Segment1				VARCHAR2,
		x_Summary_Flag				VARCHAR2,
		x_Enabled_Flag				VARCHAR2,
		x_Last_Update_Login			NUMBER,
		x_Employee_Id				NUMBER,
		x_Validation_Number			NUMBER,
		x_Vendor_Type_Lookup_Code		VARCHAR2,
		x_Customer_Num				VARCHAR2,
		x_One_Time_Flag				VARCHAR2,
		x_Parent_Vendor_Id			NUMBER,
		x_Min_Order_Amount			NUMBER,
		/* x_Ship_To_Location_Id		NUMBER,
		x_Bill_To_Location_Id			NUMBER,
		x_Ship_Via_Lookup_Code			VARCHAR2,
		x_Freight_Terms_Lookup_Code		VARCHAR2,
		x_Fob_Lookup_Code			VARCHAR2, */
		x_Terms_Id				NUMBER,
		x_Set_Of_Books_Id			NUMBER,
		x_Always_Take_Disc_Flag			VARCHAR2,
		x_Pay_Date_Basis_Lookup_Code		VARCHAR2,
		x_Pay_Group_Lookup_Code			VARCHAR2,
		x_Payment_Priority			NUMBER,
		x_Invoice_Currency_Code			VARCHAR2,
		x_Payment_Currency_Code			VARCHAR2,
		x_Invoice_Amount_Limit			NUMBER,
		x_Hold_All_Payments_Flag		VARCHAR2,
		x_Hold_Future_Payments_Flag		VARCHAR2,
		x_Hold_Reason				VARCHAR2,
		/* x_Distribution_Set_Id		NUMBER,
		x_Accts_Pay_CCID			NUMBER,
		x_Future_Dated_Payment_CCID		NUMBER,
		x_Prepay_CCID				NUMBER, */
		x_Num_1099				VARCHAR2,
		x_Type_1099				VARCHAR2,
		x_withholding_stat_Lookup_Code		VARCHAR2,
		x_Withholding_Start_Date		DATE,
		x_Org_Type_Lookup_Code			VARCHAR2,
		-- eTax Uptake x_Vat_Code		VARCHAR2,
		x_Start_Date_Active			DATE,
		x_End_Date_Active			DATE,
		x_Qty_Rcv_Tolerance			NUMBER,
		x_Minority_Group_Lookup_Code		VARCHAR2,
		x_Bank_Account_Name			VARCHAR2,
		x_Bank_Account_Num			VARCHAR2,
		x_Bank_Num				VARCHAR2,
		x_Bank_Account_Type			VARCHAR2,
		x_Women_Owned_Flag			VARCHAR2,
		x_Small_Business_Flag			VARCHAR2,
		x_Standard_Industry_Class		VARCHAR2,
		x_Attribute_Category			VARCHAR2,
		x_Attribute1				VARCHAR2,
		x_Attribute2				VARCHAR2,
		x_Attribute3				VARCHAR2,
		x_Attribute4				VARCHAR2,
		x_Attribute5				VARCHAR2,
		x_Hold_Flag				VARCHAR2,
		x_Purchasing_Hold_Reason		VARCHAR2,
		x_Hold_By				NUMBER,
		x_Hold_Date				DATE,
		x_Terms_Date_Basis			VARCHAR2,
		x_Price_Tolerance			NUMBER,
		x_Attribute10				VARCHAR2,
		x_Attribute11				VARCHAR2,
		x_Attribute12				VARCHAR2,
		x_Attribute13				VARCHAR2,
		x_Attribute14				VARCHAR2,
		x_Attribute15				VARCHAR2,
		x_Attribute6				VARCHAR2,
		x_Attribute7				VARCHAR2,
		x_Attribute8				VARCHAR2,
		x_Attribute9				VARCHAR2,
		x_Days_Early_Receipt_Allowed		NUMBER,
		x_Days_Late_Receipt_Allowed		NUMBER,
		x_Enforce_Ship_To_Loc_Code		VARCHAR2,
		x_Federal_Reportable_Flag		VARCHAR2,
		x_Hold_Unmatched_Invoices_Flag		VARCHAR2,
		x_match_option				VARCHAR2,
		x_create_debit_memo_flag		VARCHAR2,
		x_Inspection_Required_Flag		VARCHAR2,
		x_Receipt_Required_Flag			VARCHAR2,
		x_Receiving_Routing_Id			NUMBER,
		x_State_Reportable_Flag			VARCHAR2,
		x_Tax_Verification_Date			DATE,
		x_Auto_Calculate_Interest_Flag		VARCHAR2,
		x_Name_Control				VARCHAR2,
		x_Allow_Subst_Receipts_Flag		VARCHAR2,
		x_Allow_Unord_Receipts_Flag		VARCHAR2,
		x_Receipt_Days_Exception_Code		VARCHAR2,
		x_Qty_Rcv_Exception_Code		VARCHAR2,
		-- eTax Uptake x_Offset_Tax_Flag	VARCHAR2,
		x_Exclude_Freight_From_Disc		VARCHAR2,
		x_Vat_Registration_Num			VARCHAR2,
		x_Tax_Reporting_Name			VARCHAR2,
		x_Awt_Group_Id				NUMBER,
                x_Pay_Awt_Group_Id                          NUMBER,--bug6664407
		x_Check_Digits				VARCHAR2,
		x_Bank_Number				VARCHAR2,
		x_Allow_Awt_Flag			VARCHAR2,
		x_Bank_Branch_Type			VARCHAR2,
		/* eTax Uptake
		x_Auto_Tax_Calc_Flag			VARCHAR2,
		x_Auto_Tax_Calc_Override		VARCHAR2,
		x_Amount_Includes_Tax_Flag		VARCHAR2,
		x_AP_Tax_Rounding_Rule			VARCHAR2, */
                x_Vendor_Name_Alt			VARCHAR2,
                X_global_attribute_category             VARCHAR2 DEFAULT NULL,
                X_global_attribute1                     VARCHAR2 DEFAULT NULL,
                X_global_attribute2                     VARCHAR2 DEFAULT NULL,
                X_global_attribute3                     VARCHAR2 DEFAULT NULL,
                X_global_attribute4                     VARCHAR2 DEFAULT NULL,
                X_global_attribute5                     VARCHAR2 DEFAULT NULL,
                X_global_attribute6                     VARCHAR2 DEFAULT NULL,
                X_global_attribute7                     VARCHAR2 DEFAULT NULL,
                X_global_attribute8                     VARCHAR2 DEFAULT NULL,
                X_global_attribute9                     VARCHAR2 DEFAULT NULL,
                X_global_attribute10                    VARCHAR2 DEFAULT NULL,
                X_global_attribute11                    VARCHAR2 DEFAULT NULL,
                X_global_attribute12                    VARCHAR2 DEFAULT NULL,
                X_global_attribute13                    VARCHAR2 DEFAULT NULL,
                X_global_attribute14                    VARCHAR2 DEFAULT NULL,
                X_global_attribute15                    VARCHAR2 DEFAULT NULL,
                X_global_attribute16                    VARCHAR2 DEFAULT NULL,
                X_global_attribute17                    VARCHAR2 DEFAULT NULL,
                X_global_attribute18                    VARCHAR2 DEFAULT NULL,
                X_global_attribute19                    VARCHAR2 DEFAULT NULL,
                X_global_attribute20                    VARCHAR2 DEFAULT NULL,
                X_Bank_Charge_Bearer                    VARCHAR2 DEFAULT NULL,
		X_NI_Number				VARCHAR2 DEFAULT NULL,
		X_calling_sequence		IN	VARCHAR2 ) IS

    		current_calling_sequence    VARCHAR2(2000);
    		debug_info                  VARCHAR2(100);
	BEGIN
	--     Update the calling sequence
	--
        current_calling_sequence := 'AP_VENDORS_PKG.UPDATE_ROW<-' ||
                                    X_calling_sequence;
	--
	-- error out NOCOPY if Vendor name has been assigned by another session
	--
	ap_vendors_pkg.check_unique_vendor_name( p_vendor_id   =>   x_vendor_id,
						 p_vendor_name =>   x_vendor_name,
						X_calling_sequence => current_calling_sequence);
	--
	-- check for duplicate vendor_numbers
	--
	ap_vendors_pkg.check_unique_vendor_number( p_vendor_id     => x_vendor_id,
						   p_vendor_number => x_segment1,
						X_calling_sequence => current_calling_sequence);
	--
	-- error out NOCOPY if employee has been assigned by another session
	--
	ap_vendors_pkg.Check_Duplicate_Employee(p_rowid		=>	x_rowid,
				    		p_employee_id	=>	x_employee_id,
						X_calling_sequence => current_calling_sequence);

		debug_info := 'Update PO_VENDORS';
		UPDATE ap_suppliers
		SET
		vendor_id			=	x_Vendor_Id,
		last_update_date		=	x_Last_Update_Date,
		last_updated_by			=	x_Last_Updated_By,
		vendor_name			=	x_Vendor_Name,
		segment1			=	x_Segment1,
		summary_flag			=	x_Summary_Flag,
		enabled_flag			=	x_Enabled_Flag,
		last_update_login		=	x_Last_Update_Login,
		employee_id			=	x_Employee_Id,
		validation_number		=	x_Validation_Number,
		vendor_type_lookup_code		=	x_Vendor_Type_Lookup_Code,
		customer_num			=	x_Customer_Num,
		one_time_flag			=	x_One_Time_Flag,
		parent_vendor_id		= 	x_Parent_Vendor_Id,
		min_order_amount		=	x_Min_Order_Amount,
		--Bug :2809214 MOAC - Supplier Attribute Change Project
		/* ship_to_location_id		=	x_Ship_To_Location_Id,
		bill_to_location_id		=	x_Bill_To_Location_Id,
		ship_via_lookup_code		=	x_Ship_Via_Lookup_Code,
		freight_terms_lookup_code	=	x_Freight_Terms_Lookup_Code,
		fob_lookup_code			=	x_Fob_Lookup_Code, */
		terms_id			=	x_Terms_Id,
		set_of_books_id			=	x_Set_Of_Books_Id,
		always_take_disc_flag		=	x_Always_Take_Disc_Flag,
		pay_date_basis_lookup_code	=	x_Pay_Date_Basis_Lookup_Code,
		pay_group_lookup_code		=	x_Pay_Group_Lookup_Code,
		payment_priority		=	x_Payment_Priority,
		invoice_currency_code		=	x_Invoice_Currency_Code,
		payment_currency_code		=	x_Payment_Currency_Code,
		invoice_amount_limit		=	x_Invoice_Amount_Limit,
		hold_all_payments_flag		=	x_Hold_All_Payments_Flag,
		hold_future_payments_flag	=	x_Hold_Future_Payments_Flag,
		hold_reason			=	x_Hold_Reason,
		--Bug :2809214 MOAC - Supplier Attribute Change Project
		/* distribution_set_id		=	x_Distribution_Set_Id,
		accts_pay_code_combination_id	=	x_Accts_Pay_CCID,
		future_dated_payment_ccid	=	x_Future_Dated_Payment_CCID,
		prepay_code_combination_id	=	x_Prepay_CCID, */
		num_1099			=	x_Num_1099,
		type_1099			=	x_Type_1099,
		withholding_status_lookup_code	=	x_withholding_stat_Lookup_Code,
		withholding_start_date		=	x_Withholding_Start_Date,
		organization_type_lookup_code	=	x_Org_Type_Lookup_Code,
		start_date_active		=	x_Start_Date_Active,
		end_date_active			=	x_End_Date_Active,
		qty_rcv_tolerance		=	x_Qty_Rcv_Tolerance,
		minority_group_lookup_code	=	x_Minority_Group_Lookup_Code,
		bank_account_name		=	x_Bank_Account_Name,
		bank_account_num		=	x_Bank_Account_Num,
		bank_num			=	x_Bank_Num,
		bank_account_type		=	x_Bank_Account_Type,
		women_owned_flag		=	x_Women_Owned_Flag,
		small_business_flag		=	x_Small_Business_Flag,
		standard_industry_class		=	x_Standard_Industry_Class,
		attribute_category		=	x_Attribute_Category,
		attribute1			=	x_Attribute1,
		attribute2			=	x_Attribute2,
		attribute3			=	x_Attribute3,
		attribute4			=	x_Attribute4,
		attribute5			=	x_Attribute5,
		hold_flag			=	x_Hold_Flag,
		purchasing_hold_reason		=	x_Purchasing_Hold_Reason,
		hold_by				=	x_Hold_By,
		hold_date			=	x_Hold_Date,
		terms_date_basis		=	x_Terms_Date_Basis,
		price_tolerance			=	x_Price_Tolerance,
		attribute10			=	x_Attribute10,
		attribute11			=	x_Attribute11,
		attribute12			=	x_Attribute12,
		attribute13			=	x_Attribute13,
		attribute14			=	x_Attribute14,
		attribute15			=	x_Attribute15,
		attribute6			=	x_Attribute6,
		attribute7			=	x_Attribute7,
		attribute8			=	x_Attribute8,
		attribute9			=	x_Attribute9,
		days_early_receipt_allowed	=	x_Days_Early_Receipt_Allowed,
		days_late_receipt_allowed	=	x_Days_Late_Receipt_Allowed,
		enforce_ship_to_location_code	=	x_Enforce_Ship_To_Loc_Code,
		federal_reportable_flag		=	x_Federal_Reportable_Flag,
		hold_unmatched_invoices_flag	=	x_Hold_Unmatched_Invoices_Flag,
		match_option			=	x_match_option,
		create_debit_memo_flag		=	x_create_debit_memo_flag,
		inspection_required_flag	=	x_Inspection_Required_Flag,
		receipt_required_flag		=	x_Receipt_Required_Flag,
		receiving_routing_id		=	x_Receiving_Routing_Id,
		state_reportable_flag		=	x_State_Reportable_Flag,
		tax_verification_date		=	x_Tax_Verification_Date,
		auto_calculate_interest_flag	=	x_Auto_Calculate_Interest_Flag,
		name_control			=	x_Name_Control,
		allow_substitute_receipts_flag	=	x_Allow_Subst_Receipts_Flag,
		allow_unordered_receipts_flag	=	x_Allow_Unord_Receipts_Flag,
		receipt_days_exception_code	=	x_Receipt_Days_Exception_Code,
		qty_rcv_exception_code		=	x_Qty_Rcv_Exception_Code,
		exclude_freight_from_discount	=	x_Exclude_Freight_From_Disc,
		vat_registration_num		=	x_Vat_Registration_Num,
		tax_reporting_name		=	x_Tax_Reporting_Name,
		awt_group_id			=	x_Awt_Group_Id,
                pay_awt_group_id                =       x_Pay_Awt_Group_Id,--bug6664407
		check_digits			=	x_Check_Digits,
		bank_number			=	x_Bank_Number,
		allow_awt_flag			=	x_Allow_Awt_Flag,
		bank_branch_type		=	x_bank_branch_type,
		vendor_name_alt			=	x_Vendor_Name_Alt,
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
                bank_charge_bearer              =     X_Bank_Charge_Bearer,
		--Bug :2809214 MOAC - Supplier Attribute Change Project
		NI_Number                       =     X_NI_Number
		WHERE	 rowid = x_Rowid;
		if (SQL%NOTFOUND) then
			Raise NO_DATA_FOUND;
		end if;

    		EXCEPTION
        	  WHEN OTHERS THEN
           	    IF (SQLCODE <> -20001) THEN
              		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              		FND_MSG_PUB.ADD;
              		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              		FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              		FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
							', VENDOR_ID = ' || x_Vendor_Id);
              		FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           	    END IF;
                    APP_EXCEPTION.RAISE_EXCEPTION;

	END Update_Row;

	PROCEDURE Update_Row(
		p_vendor_rec  IN AP_VENDOR_PUB_PKG.r_vendor_rec_type,
                p_last_update_date IN DATE,
                p_last_updated_by  IN NUMBER,
                p_last_update_login  IN NUMBER,
                p_request_id  IN NUMBER,
                p_program_application_id IN NUMBER,
                p_program_id  IN NUMBER,
                p_program_update_date IN DATE,
		p_rowid IN VARCHAR2,
                p_vendor_id IN NUMBER) IS

    		current_calling_sequence    VARCHAR2(2000);
    		debug_info                  VARCHAR2(100);
	BEGIN

    		-- Bug 6216082 Begins. Added the call to IGI package.
    		-- Bug 7577497 Added another parameter to the function call p_pay_tax_grp_id
    		IF (p_vendor_rec.Awt_Group_Id IS NOT NULL OR
		    p_vendor_rec.Pay_Awt_Group_Id  IS NOT NULL) THEN
    			IGI_CIS2007_UTIL_PKG.SUPPLIER_UPDATE(
    				p_vendor_id => p_vendor_id,
    				p_tax_grp_id => p_vendor_rec.Awt_Group_Id,
				p_pay_tax_grp_id => p_vendor_rec.Pay_Awt_Group_Id
    				);
    		END IF;
		-- Bug 6216082 Ends.

		UPDATE ap_suppliers
		SET
		last_update_date		=	p_Last_Update_Date,
		last_updated_by			=	p_Last_Updated_By,
		segment1			=	p_vendor_rec.Segment1,
		summary_flag			=	p_vendor_rec.Summary_Flag,
		enabled_flag			=	p_vendor_rec.Enabled_Flag,
		last_update_login		=	p_Last_Update_Login,
		employee_id			=	p_vendor_rec.Employee_Id,
		validation_number		=	p_vendor_rec.Validation_Number,
		vendor_type_lookup_code		=	p_vendor_rec.Vendor_Type_Lookup_Code,
		customer_num			=	p_vendor_rec.Customer_Num,
		one_time_flag			=	p_vendor_rec.One_Time_Flag,
		parent_vendor_id		= 	p_vendor_rec.Parent_Vendor_Id,
		min_order_amount		=	p_vendor_rec.Min_Order_Amount,
		terms_id			=	p_vendor_rec.Terms_Id,
		set_of_books_id			=	p_vendor_rec.Set_Of_Books_Id,
		always_take_disc_flag		=	p_vendor_rec.Always_Take_Disc_Flag,
		pay_date_basis_lookup_code	=	p_vendor_rec.Pay_Date_Basis_Lookup_Code,
		pay_group_lookup_code		=	p_vendor_rec.Pay_Group_Lookup_Code,
		payment_priority		=	p_vendor_rec.Payment_Priority,
		invoice_currency_code		=	p_vendor_rec.Invoice_Currency_Code,
		payment_currency_code		=	p_vendor_rec.Payment_Currency_Code,
		invoice_amount_limit		=	p_vendor_rec.Invoice_Amount_Limit,
		hold_all_payments_flag		=	p_vendor_rec.Hold_All_Payments_Flag,
		hold_future_payments_flag	=	p_vendor_rec.Hold_Future_Payments_Flag,
		hold_reason			=	p_vendor_rec.Hold_Reason,
		--bug6050423 starts
	        --bug6691916.commented the below assignment statement and added
                --the one below that.As per analysis,only organization type lookup
                --code of individual or foreign individual are considered
                --as individual suppliers
 		/*individual_1099			=	decode(UPPER(p_vendor_rec.Vendor_Type_Lookup_Code),'CONTRACTOR',
					                        decode(UPPER(p_vendor_rec.Organization_Type_Lookup_Code),
					                                'INDIVIDUAL',p_vendor_rec.jgzz_fiscal_code,
					                                'FOREIGN INDIVIDUAL',p_vendor_rec.jgzz_fiscal_code,
					                                'PARTNERSHIP',p_vendor_rec.jgzz_fiscal_code,
						                        'INDIVIDUAL PARTNERSHIP',p_vendor_rec.jgzz_fiscal_code,
					                                NULL),
				                        NULL),*/
		individual_1099                       =  decode(UPPER(p_vendor_rec.Organization_Type_Lookup_Code),
                                                                        'INDIVIDUAL',p_vendor_rec.jgzz_fiscal_code,
                                                                        'FOREIGN INDIVIDUAL',p_vendor_rec.jgzz_fiscal_code,
								NULL),
		--bug6050423 ends
		type_1099			=	p_vendor_rec.Type_1099,
		withholding_status_lookup_code	=	p_vendor_rec.withholding_status_Lookup_Code,
		withholding_start_date		=	p_vendor_rec.Withholding_Start_Date,
		organization_type_lookup_code	=	p_vendor_rec.Organization_Type_Lookup_Code,
		start_date_active		=	p_vendor_rec.Start_Date_Active,
		end_date_active			=	p_vendor_rec.End_Date_Active,
		qty_rcv_tolerance		=	p_vendor_rec.Qty_Rcv_Tolerance,
		minority_group_lookup_code	=	p_vendor_rec.Minority_Group_Lookup_Code,
		women_owned_flag		=	p_vendor_rec.Women_Owned_Flag,
		small_business_flag		=	p_vendor_rec.Small_Business_Flag,
		attribute_category		=	p_vendor_rec.Attribute_Category,
		attribute1			=	p_vendor_rec.Attribute1,
		attribute2			=	p_vendor_rec.Attribute2,
		attribute3			=	p_vendor_rec.Attribute3,
		attribute4			=	p_vendor_rec.Attribute4,
		attribute5			=	p_vendor_rec.Attribute5,
		hold_flag			=	p_vendor_rec.Hold_Flag,
		purchasing_hold_reason		=	p_vendor_rec.Purchasing_Hold_Reason,
		hold_by				=	p_vendor_rec.Hold_By,
		hold_date			=	p_vendor_rec.Hold_Date,
		terms_date_basis		=	p_vendor_rec.Terms_Date_Basis,
		attribute10			=	p_vendor_rec.Attribute10,
		attribute11			=	p_vendor_rec.Attribute11,
		attribute12			=	p_vendor_rec.Attribute12,
		attribute13			=	p_vendor_rec.Attribute13,
		attribute14			=	p_vendor_rec.Attribute14,
		attribute15			=	p_vendor_rec.Attribute15,
		attribute6			=	p_vendor_rec.Attribute6,
		attribute7			=	p_vendor_rec.Attribute7,
		attribute8			=	p_vendor_rec.Attribute8,
		attribute9			=	p_vendor_rec.Attribute9,
		days_early_receipt_allowed	=	p_vendor_rec.Days_Early_Receipt_Allowed,
		days_late_receipt_allowed	=	p_vendor_rec.Days_Late_Receipt_Allowed,
		enforce_ship_to_location_code	=	p_vendor_rec.Enforce_Ship_To_Location_Code,
		federal_reportable_flag		=	p_vendor_rec.Federal_Reportable_Flag,
		hold_unmatched_invoices_flag	=	p_vendor_rec.Hold_Unmatched_Invoices_Flag,
		match_option			=	p_vendor_rec.match_option,
		create_debit_memo_flag		=	p_vendor_rec.create_debit_memo_flag,
		inspection_required_flag	=	p_vendor_rec.Inspection_Required_Flag,
		receipt_required_flag		=	p_vendor_rec.Receipt_Required_Flag,
		receiving_routing_id		=	p_vendor_rec.Receiving_Routing_Id,
		state_reportable_flag		=	p_vendor_rec.State_Reportable_Flag,
		tax_verification_date		=	p_vendor_rec.Tax_Verification_Date,
		auto_calculate_interest_flag	=	p_vendor_rec.Auto_Calculate_Interest_Flag,
		name_control			=	p_vendor_rec.Name_Control,
		allow_substitute_receipts_flag	=	p_vendor_rec.Allow_Substitute_Receipts_Flag,
		allow_unordered_receipts_flag	=	p_vendor_rec.Allow_Unordered_Receipts_Flag,
		receipt_days_exception_code	=	p_vendor_rec.Receipt_Days_Exception_Code,
		qty_rcv_exception_code		=	p_vendor_rec.Qty_Rcv_Exception_Code,
		exclude_freight_from_discount	=	p_vendor_rec.Exclude_Freight_From_Discount,
		tax_reporting_name		=	p_vendor_rec.Tax_Reporting_Name,
		awt_group_id			=	p_vendor_rec.Awt_Group_Id,
                pay_awt_group_id                =       p_vendor_rec.Pay_Awt_Group_Id,--bug6664407
		check_digits			=	p_vendor_rec.Check_Digits,
		allow_awt_flag			=	p_vendor_rec.Allow_Awt_Flag,
                global_attribute_category       =     p_vendor_rec.global_attribute_category,
                global_attribute1               =     p_vendor_rec.global_attribute1,
                global_attribute2               =     p_vendor_rec.global_attribute2,
                global_attribute3               =     p_vendor_rec.global_attribute3,
                global_attribute4               =     p_vendor_rec.global_attribute4,
                global_attribute5               =     p_vendor_rec.global_attribute5,
                global_attribute6               =     p_vendor_rec.global_attribute6,
                global_attribute7               =     p_vendor_rec.global_attribute7,
                global_attribute8               =     p_vendor_rec.global_attribute8,
                global_attribute9               =     p_vendor_rec.global_attribute9,
                global_attribute10              =     p_vendor_rec.global_attribute10,
                global_attribute11              =     p_vendor_rec.global_attribute11,
                global_attribute12              =     p_vendor_rec.global_attribute12,
                global_attribute13              =     p_vendor_rec.global_attribute13,
                global_attribute14              =     p_vendor_rec.global_attribute14,
                global_attribute15              =     p_vendor_rec.global_attribute15,
                global_attribute16              =     p_vendor_rec.global_attribute16,
                global_attribute17              =     p_vendor_rec.global_attribute17,
                global_attribute18              =     p_vendor_rec.global_attribute18,
                global_attribute19              =     p_vendor_rec.global_attribute19,
                global_attribute20              =     p_vendor_rec.global_attribute20,
                bank_charge_bearer              =     p_vendor_rec.Bank_Charge_Bearer,
		NI_Number                       =     p_vendor_rec.NI_Number,
                standard_industry_class         =     p_vendor_rec.sic_code -- 5066199
		WHERE	 vendor_id = p_vendor_id;
		if (SQL%NOTFOUND) then
			Raise NO_DATA_FOUND;
		end if;

                /* Bug 5412440 */
                IF  (p_vendor_rec.allow_awt_flag = 'N') THEN
                  UPDATE Ap_Supplier_Sites_ALL
                  SET    allow_awt_flag = 'N',
                         awt_group_id   = NULL
                  WHERE  vendor_id = p_vendor_rec.vendor_id;
                END IF;


    		EXCEPTION
        	  WHEN OTHERS THEN
           	    IF (SQLCODE <> -20001) THEN
              		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              		FND_MSG_PUB.ADD;
              		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              		FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              		FND_MESSAGE.SET_TOKEN('PARAMETERS', 'VENDOR_ID = ' || p_Vendor_Id);
              		FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           	    END IF;
                    APP_EXCEPTION.RAISE_EXCEPTION;


	END Update_Row;

--
--
	PROCEDURE Lock_Row (
		x_Rowid					VARCHAR2,
		x_Vendor_Id				NUMBER,
		x_Vendor_Name				VARCHAR2,
		x_Segment1				VARCHAR2,
		x_Summary_Flag				VARCHAR2,
		x_Enabled_Flag				VARCHAR2,
		x_Employee_Id				NUMBER,
		x_Validation_Number			NUMBER,
		x_Vendor_Type_Lookup_Code		VARCHAR2,
		x_Customer_Num				VARCHAR2,
		x_One_Time_Flag				VARCHAR2,
		x_Parent_Vendor_Id			NUMBER,
		x_Min_Order_Amount			NUMBER,
		/* x_Ship_To_Location_Id		NUMBER,
		x_Bill_To_Location_Id			NUMBER,
		x_Ship_Via_Lookup_Code			VARCHAR2,
		x_Freight_Terms_Lookup_Code		VARCHAR2,
		x_Fob_Lookup_Code			VARCHAR2, */
		x_Terms_Id				NUMBER,
		x_Set_Of_Books_Id			NUMBER,
		x_Always_Take_Disc_Flag			VARCHAR2,
		x_Pay_Date_Basis_Lookup_Code		VARCHAR2,
		x_Pay_Group_Lookup_Code			VARCHAR2,
		x_Payment_Priority			NUMBER,
		x_Invoice_Currency_Code			VARCHAR2,
		x_Payment_Currency_Code			VARCHAR2,
		x_Invoice_Amount_Limit			NUMBER,
		x_Hold_All_Payments_Flag		VARCHAR2,
		x_Hold_Future_Payments_Flag		VARCHAR2,
		x_Hold_Reason				VARCHAR2,
		/* x_Distribution_Set_Id		NUMBER,
		x_Accts_Pay_CCID			NUMBER,
		x_Future_Dated_Payment_CCID		NUMBER,
		x_Prepay_CCID				NUMBER, */
		x_Num_1099				VARCHAR2,
		x_Type_1099				VARCHAR2,
		x_withholding_stat_Lookup_Code		VARCHAR2,
		x_Withholding_Start_Date		DATE,
		x_Org_Type_Lookup_Code			VARCHAR2,
		-- eTax Uptake x_Vat_Code		VARCHAR2,
		x_Start_Date_Active			DATE,
		x_End_Date_Active			DATE,
		x_Qty_Rcv_Tolerance			NUMBER,
		x_Minority_Group_Lookup_Code		VARCHAR2,
		x_Bank_Account_Name			VARCHAR2,
		x_Bank_Account_Num			VARCHAR2,
		x_Bank_Num				VARCHAR2,
		x_Bank_Account_Type			VARCHAR2,
		x_Women_Owned_Flag			VARCHAR2,
		x_Small_Business_Flag			VARCHAR2,
		x_Standard_Industry_Class		VARCHAR2,
		x_Attribute_Category			VARCHAR2,
		x_Attribute1				VARCHAR2,
		x_Attribute2				VARCHAR2,
		x_Attribute3				VARCHAR2,
		x_Attribute4				VARCHAR2,
		x_Attribute5				VARCHAR2,
		x_Hold_Flag				VARCHAR2,
		x_Purchasing_Hold_Reason		VARCHAR2,
		x_Hold_By				NUMBER,
		x_Hold_Date				DATE,
		x_Terms_Date_Basis			VARCHAR2,
		x_Price_Tolerance			NUMBER,
		x_Attribute10				VARCHAR2,
		x_Attribute11				VARCHAR2,
		x_Attribute12				VARCHAR2,
		x_Attribute13				VARCHAR2,
		x_Attribute14				VARCHAR2,
		x_Attribute15				VARCHAR2,
		x_Attribute6				VARCHAR2,
		x_Attribute7				VARCHAR2,
		x_Attribute8				VARCHAR2,
		x_Attribute9				VARCHAR2,
		x_Days_Early_Receipt_Allowed		NUMBER,
		x_Days_Late_Receipt_Allowed		NUMBER,
		x_Enforce_Ship_To_Loc_Code		VARCHAR2,
		x_Federal_Reportable_Flag		VARCHAR2,
		x_Hold_Unmatched_Invoices_Flag		VARCHAR2,
		x_match_option				VARCHAR2,
		x_create_debit_memo_flag		VARCHAR2,
		x_Inspection_Required_Flag		VARCHAR2,
		x_Receipt_Required_Flag			VARCHAR2,
		x_Receiving_Routing_Id			NUMBER,
		x_State_Reportable_Flag			VARCHAR2,
		x_Tax_Verification_Date			DATE,
		x_Auto_Calculate_Interest_Flag		VARCHAR2,
		x_Name_Control				VARCHAR2,
		x_Allow_Subst_Receipts_Flag		VARCHAR2,
		x_Allow_Unord_Receipts_Flag		VARCHAR2,
		x_Receipt_Days_Exception_Code		VARCHAR2,
		x_Qty_Rcv_Exception_Code		VARCHAR2,
		-- eTax Uptake x_Offset_Tax_Flag  	VARCHAR2,
		x_Exclude_Freight_From_Disc		VARCHAR2,
		x_Vat_Registration_Num			VARCHAR2,
		x_Tax_Reporting_Name			VARCHAR2,
		x_Awt_Group_Id				NUMBER,
                x_Pay_Awt_Group_Id                      NUMBER,--bug6664407
		x_Check_Digits				VARCHAR2,
		x_Bank_Number				VARCHAR2,
		x_Allow_Awt_Flag			VARCHAR2,
		x_Bank_Branch_Type			VARCHAR2,
		/* eTax Uptake
		x_Auto_Tax_Calc_Flag			VARCHAR2,
		x_Auto_Tax_Calc_Override		VARCHAR2,
		x_Amount_Includes_Tax_Flag		VARCHAR2,
		x_AP_Tax_Rounding_Rule			VARCHAR2, */
		x_Vendor_Name_Alt			VARCHAR2,
                X_global_attribute_category             VARCHAR2 DEFAULT NULL,
                X_global_attribute1                     VARCHAR2 DEFAULT NULL,
                X_global_attribute2                     VARCHAR2 DEFAULT NULL,
                X_global_attribute3                     VARCHAR2 DEFAULT NULL,
                X_global_attribute4                     VARCHAR2 DEFAULT NULL,
                X_global_attribute5                     VARCHAR2 DEFAULT NULL,
                X_global_attribute6                     VARCHAR2 DEFAULT NULL,
                X_global_attribute7                     VARCHAR2 DEFAULT NULL,
                X_global_attribute8                     VARCHAR2 DEFAULT NULL,
                X_global_attribute9                     VARCHAR2 DEFAULT NULL,
                X_global_attribute10                    VARCHAR2 DEFAULT NULL,
                X_global_attribute11                    VARCHAR2 DEFAULT NULL,
                X_global_attribute12                    VARCHAR2 DEFAULT NULL,
                X_global_attribute13                    VARCHAR2 DEFAULT NULL,
                X_global_attribute14                    VARCHAR2 DEFAULT NULL,
                X_global_attribute15                    VARCHAR2 DEFAULT NULL,
                X_global_attribute16                    VARCHAR2 DEFAULT NULL,
                X_global_attribute17                    VARCHAR2 DEFAULT NULL,
                X_global_attribute18                    VARCHAR2 DEFAULT NULL,
                X_global_attribute19                    VARCHAR2 DEFAULT NULL,
                X_global_attribute20                    VARCHAR2 DEFAULT NULL,
                X_Bank_Charge_Bearer                    VARCHAR2 DEFAULT NULL,
		X_NI_Number				VARCHAR2 DEFAULT NULL,
		X_calling_sequence		IN	VARCHAR2 ) IS

		CURSOR C IS
		SELECT 	*
		FROM ap_suppliers
		WHERE	rowid = x_Rowid
		FOR UPDATE of Vendor_Id NOWAIT;
		Recinfo		C%ROWTYPE;

    		current_calling_sequence    VARCHAR2(2000);
    		debug_info                  VARCHAR2(100);
--
	BEGIN
		--     Update the calling sequence
		--
        	current_calling_sequence := 'AP_VENDORS_PKG.LOCK_ROW<-' ||
                                    	     X_calling_sequence;

		debug_info := 'Open cursor C';
		OPEN 	C;
		debug_info := 'Fetch cursor C';
		FETCH	C INTO Recinfo;
			if (C%NOTFOUND) then
				debug_info := 'Close cursor C- DATA NOTFOUND';
				CLOSE C;
				FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
				FND_MSG_PUB.ADD;
				APP_EXCEPTION.Raise_Exception;
			end if;
		debug_info := 'Close cursor C';
		CLOSE	C;
		if (
			    (Recinfo.vendor_id = x_Vendor_Id)
			AND (Recinfo.vendor_name = x_Vendor_Name)
			AND (Recinfo.segment1 = x_Segment1)
			AND (Recinfo.summary_flag = x_Summary_Flag)
			AND (Recinfo.enabled_flag = x_Enabled_Flag)
			AND ((Recinfo.employee_id = x_Employee_Id)
				OR ((Recinfo.employee_id IS NULL)
				AND (x_Employee_Id IS NULL)))
			AND ((Recinfo.validation_number = x_Validation_Number)
				OR ((Recinfo.validation_number IS NULL)
				AND (x_Validation_Number IS NULL)))
			AND ((Recinfo.vendor_type_lookup_code = x_Vendor_Type_Lookup_Code)
				OR ((Recinfo.vendor_type_lookup_code IS NULL)
				AND (x_Vendor_Type_Lookup_Code IS NULL)))
			AND ((Recinfo.customer_num = x_Customer_Num)
				OR ((Recinfo.customer_num IS NULL)
				AND (x_Customer_Num IS NULL)))
			AND ((Recinfo.one_time_flag = x_One_Time_Flag)
				OR ((Recinfo.one_time_flag IS NULL)
				AND (x_One_Time_Flag IS NULL)))
			AND ((Recinfo.parent_vendor_id = x_Parent_Vendor_Id)
				OR ((Recinfo.parent_vendor_id IS NULL)
				AND (x_Parent_Vendor_Id IS NULL)))
			AND ((Recinfo.min_order_amount = x_Min_Order_Amount)
				OR ((Recinfo.min_order_amount IS NULL)
				AND (x_Min_Order_Amount IS NULL)))
                        --Bug :2809214 MOAC - Supplier Attribute Change Project
			/* AND ((Recinfo.ship_to_location_id = x_Ship_To_Location_Id)
				OR ((Recinfo.ship_to_location_id IS NULL)
				AND (x_Ship_To_Location_Id IS NULL)))
			AND ((Recinfo.bill_to_location_id = x_Bill_To_Location_Id)
				OR ((Recinfo.bill_to_location_id IS NULL)
				AND (x_Bill_To_Location_Id IS NULL)))
			AND ((Recinfo.ship_via_lookup_code = x_Ship_Via_Lookup_Code)
				OR ((Recinfo.ship_via_lookup_code IS NULL)
				AND (x_Ship_Via_Lookup_Code IS NULL)))
			AND ((Recinfo.freight_terms_lookup_code = x_Freight_Terms_Lookup_Code)
				OR ((Recinfo.freight_terms_lookup_code IS NULL)
				AND (x_Freight_Terms_Lookup_Code IS NULL)))
			AND  ((Recinfo.fob_lookup_code = x_Fob_Lookup_Code)
				OR  ((Recinfo.fob_lookup_code IS NULL)
				AND  (x_Fob_Lookup_Code IS NULL))) */
			AND  ((Recinfo.terms_id = x_Terms_Id)
				OR  ( (Recinfo.terms_id IS NULL)
				AND  (x_Terms_Id IS NULL)))
			AND  ((Recinfo.set_of_books_id = x_Set_Of_Books_Id)
				OR  ((Recinfo.set_of_books_id IS NULL)
				AND  (x_Set_Of_Books_Id IS NULL)))
			AND  ((Recinfo.always_take_disc_flag = x_Always_Take_Disc_Flag)
				OR  ((Recinfo.always_take_disc_flag IS NULL)
				AND  (x_Always_Take_Disc_Flag IS NULL)))
			AND ((Recinfo.pay_date_basis_lookup_code = x_Pay_Date_Basis_Lookup_Code)
				OR ((Recinfo.pay_date_basis_lookup_code IS NULL)
				AND  (x_Pay_Date_Basis_Lookup_Code IS NULL)))
			AND  ((Recinfo.pay_group_lookup_code = x_Pay_Group_Lookup_Code)
				OR  ((Recinfo.pay_group_lookup_code IS NULL)
				AND  (x_Pay_Group_Lookup_Code IS NULL)))
			AND  ((Recinfo.payment_priority = x_Payment_Priority)
				OR  ((Recinfo.payment_priority IS NULL)
				AND  (x_Payment_Priority IS NULL)))
			AND  ((Recinfo.invoice_currency_code = x_Invoice_Currency_Code)
				OR  ((Recinfo.invoice_currency_code IS NULL)
				AND  (x_Invoice_Currency_Code IS NULL)))
			AND  ((Recinfo.payment_currency_code = x_Payment_Currency_Code)
				OR  ((Recinfo.payment_currency_code IS NULL)
				AND (x_Payment_Currency_Code IS NULL)))
			AND  ((Recinfo.invoice_amount_limit = x_Invoice_Amount_Limit)
				OR  ((Recinfo.invoice_amount_limit IS NULL)
				AND  (x_Invoice_Amount_Limit IS NULL)))
			AND  ((Recinfo.hold_all_payments_flag = x_Hold_All_Payments_Flag)
				OR  ((Recinfo.hold_all_payments_flag IS NULL)
				AND  (x_Hold_All_Payments_Flag IS NULL)))
			AND  ((Recinfo.hold_future_payments_flag = x_Hold_Future_Payments_Flag)
				OR  ((Recinfo.hold_future_payments_flag IS NULL)
				AND  (x_Hold_Future_Payments_Flag IS NULL)))
			AND  ((Recinfo.hold_reason = x_Hold_Reason)
				OR  ((Recinfo.hold_reason IS NULL)
				AND  (x_Hold_Reason IS NULL)))
			--Bug :2809214 MOAC - Supplier Attribute Change Project
			/* AND  ((Recinfo.distribution_set_id = x_Distribution_Set_Id)
				OR  ((Recinfo.distribution_set_id IS NULL)
				AND  (x_Distribution_Set_Id IS NULL)))
			AND ((Recinfo.accts_pay_code_combination_id = x_Accts_Pay_CCID)
				OR  ((Recinfo.accts_pay_code_combination_id IS NULL)
				AND (x_Accts_Pay_CCID IS NULL)))
			AND ((Recinfo.future_dated_payment_ccid = x_Future_Dated_Payment_CCID)
				OR  ((Recinfo.future_dated_payment_ccid IS NULL)
				AND (x_Future_Dated_Payment_CCID IS NULL)))
			AND  ((Recinfo.prepay_code_combination_id = x_Prepay_CCID)
				OR  ((Recinfo.prepay_code_combination_id IS NULL)
				AND  (x_Prepay_CCID IS NULL))) */
			AND  ((Recinfo.num_1099 = x_Num_1099)
				OR  ((Recinfo.num_1099 IS NULL)
				AND  (x_Num_1099 IS NULL)))
			AND  ((Recinfo.type_1099 = x_Type_1099)
				OR ((Recinfo.type_1099 IS NULL)
				AND  (x_Type_1099 IS NULL)))
			AND  ((Recinfo.withholding_status_lookup_code = x_withholding_stat_Lookup_Code)
				OR  ((Recinfo.withholding_status_lookup_code IS NULL)
				AND  (x_withholding_stat_Lookup_Code IS NULL)))
			AND  ((Recinfo.withholding_start_date = x_Withholding_Start_Date)
				OR  ((Recinfo.withholding_start_date IS NULL)
		 		AND  (x_Withholding_Start_Date IS NULL)))
			AND  ((Recinfo.organization_type_lookup_code = x_Org_Type_Lookup_Code)
				OR  ((Recinfo.organization_type_lookup_code IS NULL)
				AND  (x_Org_Type_Lookup_Code IS NULL)))
			AND  ((Recinfo.start_date_active = x_Start_Date_Active)
				OR  ((Recinfo.start_date_active IS NULL)
				AND  (x_Start_Date_Active IS NULL)))
			AND  ((Recinfo.end_date_active = x_End_Date_Active)
				OR  ((Recinfo.end_date_active IS NULL)
				AND  (x_End_Date_Active IS NULL)))
			AND  ((Recinfo.qty_rcv_tolerance = x_Qty_Rcv_Tolerance)
				OR  ((Recinfo.qty_rcv_tolerance IS NULL)
				AND  (x_Qty_Rcv_Tolerance IS NULL )))
			AND  ((Recinfo.minority_group_lookup_code = x_Minority_Group_Lookup_Code)
				OR  ((Recinfo.minority_group_lookup_code IS NULL)
				AND  (x_Minority_Group_Lookup_Code IS NULL)))
			AND  ((Recinfo.bank_account_name = x_Bank_Account_Name)
				OR  ((Recinfo.bank_account_name IS NULL)
				AND  (x_Bank_Account_Name IS NULL)))
			AND  ((Recinfo.bank_account_num = x_Bank_Account_Num)
				OR  ((Recinfo.bank_account_num IS NULL)
				AND  (x_Bank_Account_Num IS NULL)))
			AND  ((Recinfo.bank_num = x_Bank_Num)
				OR  ((Recinfo.bank_num IS NULL)
				AND  (x_Bank_Num IS NULL)))
			AND  ((Recinfo.bank_account_type = x_Bank_Account_Type)
				OR  ((Recinfo.bank_account_type IS NULL)
				AND  (x_Bank_Account_Type IS NULL)))
			AND  ((Recinfo.women_owned_flag = x_Women_Owned_Flag)
				OR  ((Recinfo.women_owned_flag IS NULL)
				AND  (x_Women_Owned_Flag IS	 NULL)))
			AND ((Recinfo.small_business_flag = x_Small_Business_Flag)
				OR  ((Recinfo.small_business_flag IS NULL)
				AND  (x_Small_Business_Flag IS NULL)))
			AND  ((Recinfo.standard_industry_class = x_Standard_Industry_Class)
				OR  ((Recinfo.standard_industry_class IS NULL)
				AND  (x_Standard_Industry_Class IS NULL)))
			AND  (NVL(Recinfo.Bank_Charge_Bearer,'I') = x_Bank_Charge_Bearer)
			--Bug :2809214 MOAC - Supplier Attribute Change Project
			AND  ((Recinfo.NI_Number = x_NI_Number)
               			OR  ((Recinfo.NI_Number IS NULL)
				AND  (x_NI_Number IS NULL)))

		)
		then
			null;
		else
			FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
			FND_MSG_PUB.ADD;
			APP_EXCEPTION.Raise_Exception;
		end if;
--
		if (
			   ((Recinfo.attribute_category = x_Attribute_Category)
				OR  ((Recinfo.attribute_category IS NULL)
				AND  (x_Attribute_Category IS NULL)))
			AND  ((Recinfo.attribute1 = x_Attribute1)
				OR  ((Recinfo.attribute1 IS NULL)
				AND  (x_Attribute1 IS NULL)))
			AND  ((Recinfo.attribute2 = x_Attribute2)
				OR  ((Recinfo.attribute2 IS NULL)
				AND  (x_Attribute2 IS NULL)))
			AND  ((Recinfo.attribute3 = x_Attribute3)
				OR  ((Recinfo.attribute3 IS NULL)
				AND  (x_Attribute3 IS NULL)))
			AND  ((Recinfo.attribute4 = x_Attribute4)
				OR  ((Recinfo.attribute4 IS NULL)
				AND  (x_Attribute4 IS NULL)))
			AND  ((Recinfo.attribute5 = x_Attribute5)
				OR  ((Recinfo.attribute5 IS NULL)
				AND  (x_Attribute5 IS NULL)))
			AND  ((Recinfo.hold_flag = x_Hold_Flag)
				OR  ((Recinfo.hold_flag IS NULL)
				AND  (x_Hold_Flag IS NULL)))
			AND  ((Recinfo.purchasing_hold_reason = x_Purchasing_Hold_Reason)
				OR  ((Recinfo.purchasing_hold_reason IS NULL)
				AND  (x_Purchasing_Hold_Reason IS NULL)))
			AND  ((Recinfo.hold_by = x_Hold_By)
				OR  ((Recinfo.hold_by IS NULL)
				AND  (x_Hold_By IS NULL)))
			AND  ((Recinfo.hold_date = x_Hold_Date)
				OR  ((Recinfo.hold_date IS NULL)
				AND  (x_Hold_Date IS NULL)))
			AND  ((Recinfo.terms_date_basis = x_Terms_Date_Basis)
				OR  ((Recinfo.terms_date_basis IS NULL)
				AND  (x_Terms_Date_Basis IS NULL)))
			AND  ((Recinfo.price_tolerance = x_Price_Tolerance)
				OR  ((Recinfo.price_tolerance IS NULL)
				AND  (x_Price_Tolerance IS NULL)))
			AND  ((Recinfo.attribute10 = x_Attribute10)
				OR  ((Recinfo.attribute10 IS NULL)
				AND  (x_Attribute10 IS NULL)))
			AND  ((Recinfo.attribute11 = x_Attribute11)
				OR  ((Recinfo.attribute11 IS NULL)
				AND  (x_Attribute11 IS NULL)))
			AND  ((Recinfo.attribute12 = x_Attribute12)
				OR  ((Recinfo.attribute12 IS NULL)
				AND  (x_Attribute12 IS NULL)))
			AND  ((Recinfo.attribute13 = x_Attribute13)
				OR  ((Recinfo.attribute13 IS NULL)
				AND  (x_Attribute13 IS NULL)))
			AND  ((Recinfo.attribute14 = x_Attribute14)
				OR  ((Recinfo.attribute14 IS NULL)
				AND  (x_Attribute14 IS NULL)))
			AND  ((Recinfo.attribute15 = x_Attribute15)
				OR  ((Recinfo.attribute15 IS NULL)
				AND  (x_Attribute15 IS NULL)))
			AND  ((Recinfo.attribute6 = x_Attribute6)
				OR  ((Recinfo.attribute6 IS NULL)
				AND  (x_Attribute6 IS NULL)))
			AND  ((Recinfo.attribute7 = x_Attribute7)
				OR  ((Recinfo.attribute7 IS NULL)
				AND  (x_Attribute7 IS NULL)))
			AND  ((Recinfo.attribute8 = x_Attribute8)
				OR  ((Recinfo.attribute8 IS NULL)
				AND  (x_Attribute8 IS NULL)))
			AND  ((Recinfo.attribute9 = x_Attribute9)
				OR  ((Recinfo.attribute9 IS NULL)
				AND  (x_Attribute9 IS NULL)))
			AND  ((Recinfo.days_early_receipt_allowed = x_Days_Early_Receipt_Allowed)
				OR  ((Recinfo.days_early_receipt_allowed IS NULL)
				AND  (x_Days_Early_Receipt_Allowed IS NULL)))
			AND  ( (Recinfo.days_late_receipt_allowed = x_Days_Late_Receipt_Allowed)
				OR  ((Recinfo.days_late_receipt_allowed IS NULL)
				AND  (x_Days_Late_Receipt_Allowed IS NULL)))
			AND  ((Recinfo.enforce_ship_to_location_code = x_Enforce_Ship_To_Loc_Code)
				OR  ((Recinfo.enforce_ship_to_location_code IS NULL)
				AND  (x_Enforce_Ship_To_Loc_Code IS NULL)))
			AND  ((Recinfo.federal_reportable_flag = x_Federal_Reportable_Flag)
				OR  ((Recinfo.federal_reportable_flag IS NULL)
				AND  (x_Federal_Reportable_Flag IS NULL)))
			AND  ((Recinfo.hold_unmatched_invoices_flag = x_Hold_Unmatched_Invoices_Flag)
				OR  ((Recinfo.hold_unmatched_invoices_flag IS NULL)
				AND  (x_Hold_Unmatched_Invoices_Flag IS NULL)))
                        AND  ((Recinfo.match_option = x_match_option)
                                OR  ((Recinfo.match_option IS NULL)
                                AND  (x_match_option IS NULL)))
                        AND  ((Recinfo.create_debit_memo_flag = x_create_debit_memo_flag)
                                OR  ((Recinfo.create_debit_memo_flag IS NULL)
                                AND  (x_create_debit_memo_flag IS NULL)))
			AND  ((Recinfo.inspection_required_flag = x_inspection_required_flag)
				OR  ((Recinfo.inspection_required_flag IS NULL)
				AND  (x_Inspection_Required_Flag IS NULL)))
			AND  ((Recinfo.receipt_required_flag = x_Receipt_Required_Flag)
				OR  ((Recinfo.receipt_required_flag IS NULL)
				AND  (x_Receipt_Required_Flag IS NULL)))
			AND  ((Recinfo.receiving_routing_id = x_Receiving_Routing_Id)
				OR  ((Recinfo.receiving_routing_id IS NULL)
				AND  (x_Receiving_Routing_Id IS NULL)))
			AND  ((Recinfo.state_reportable_flag = x_State_Reportable_Flag)
				OR  ((Recinfo.state_reportable_flag IS NULL)
				AND  (x_State_Reportable_Flag IS NULL)))
			AND  ((Recinfo.tax_verification_date = x_Tax_Verification_Date)
				OR  ((Recinfo.tax_verification_date IS NULL)
				AND  (x_Tax_Verification_Date IS NULL)))
			AND  ((Recinfo.auto_calculate_interest_flag = x_Auto_Calculate_Interest_Flag)
				OR  ((Recinfo.auto_calculate_interest_flag IS NULL)
				AND  (x_Auto_Calculate_Interest_Flag IS NULL)))
			AND  ((RTRIM(Recinfo.name_control) = x_Name_Control)
				OR  ((RTRIM(Recinfo.name_control) IS NULL)
				AND  (x_Name_Control IS NULL)))
			AND  ((Recinfo.allow_substitute_receipts_flag = x_Allow_Subst_Receipts_Flag)
				OR  ((Recinfo.allow_substitute_receipts_flag IS NULL)
				AND  (x_Allow_Subst_Receipts_Flag IS NULL)))
			AND  ((Recinfo.allow_unordered_receipts_flag = x_Allow_Unord_Receipts_Flag)
				OR  ((Recinfo.allow_unordered_receipts_flag IS NULL)
				AND  (x_Allow_Unord_Receipts_Flag IS NULL)))
			AND  ((Recinfo.receipt_days_exception_code = x_Receipt_Days_Exception_Code)
				OR  ((Recinfo.receipt_days_exception_code IS NULL)
				AND  (x_Receipt_Days_Exception_Code IS NULL)))
			AND  ((Recinfo.qty_rcv_exception_code = x_Qty_Rcv_Exception_Code)
				OR  ((Recinfo.qty_rcv_exception_code IS NULL)
				AND  (x_Qty_Rcv_Exception_Code IS NULL)))
			AND  ((Recinfo.exclude_freight_from_discount = x_Exclude_Freight_From_Disc)
				OR  ((Recinfo.exclude_freight_from_discount IS NULL)
				AND  (x_Exclude_Freight_From_Disc IS NULL)))
			AND  ((Recinfo.vat_registration_num = x_Vat_Registration_Num)
				OR  ((Recinfo.vat_registration_num IS NULL)
				AND  (x_Vat_Registration_Num IS NULL)))
			AND  ((Recinfo.tax_reporting_name = x_Tax_Reporting_Name)
				OR  ((Recinfo.tax_reporting_name IS NULL)
				AND  (x_Tax_Reporting_Name IS NULL)))
			AND  ((Recinfo.awt_group_id = x_Awt_Group_Id)
				OR  ((Recinfo.awt_group_id IS NULL)
				AND  (x_Awt_Group_Id IS NULL)))
                        AND  ((Recinfo.pay_awt_group_id = x_Pay_Awt_Group_Id)
                                OR  ((Recinfo.pay_awt_group_id IS NULL)
                                AND  (x_Pay_Awt_Group_Id IS NULL)))        --bug6664407
			AND  ((Recinfo.check_digits = x_Check_Digits)
				OR  ((Recinfo.check_digits IS NULL)
				AND  (x_Check_Digits IS NULL)))
			AND  ((Recinfo.bank_number = x_Bank_Number)
				OR  ((Recinfo.bank_number IS NULL)
				AND  (x_Bank_Number IS NULL)))
			AND  ((Recinfo.allow_awt_flag = x_Allow_Awt_Flag)
				OR  ((Recinfo.allow_awt_flag IS NULL)
				AND  (x_Allow_Awt_Flag IS NULL)))
			AND  ((Recinfo.bank_branch_type = x_bank_branch_type)
				OR  ((Recinfo.bank_branch_type IS NULL)
				AND  (x_bank_branch_type IS NULL)))
			AND  ((Recinfo.vendor_name_alt = x_Vendor_Name_Alt)
				OR  ((Recinfo.vendor_name_alt IS NULL)
				AND  (x_Vendor_Name_Alt IS NULL)))
		)
		then
			null;
		else
			FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
			FND_MSG_PUB.ADD;
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
		)
		then
			return;
		else
			FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
			FND_MSG_PUB.ADD;
			APP_EXCEPTION.Raise_Exception;
		end if;

    		EXCEPTION
        	  WHEN OTHERS THEN
           	    IF (SQLCODE <> -20001) THEN
                      IF (SQLCODE = -54) THEN
                        FND_MESSAGE.SET_NAME('SQLAP','AP_RESOURCE_BUSY');
                        FND_MSG_PUB.ADD;
                      ELSE
              		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              		FND_MSG_PUB.ADD;
              		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              		FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              		FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || X_Rowid ||
							', VENDOR_ID = ' || x_Vendor_Id);
              		FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
                      END IF;
           	    END IF;
                    APP_EXCEPTION.RAISE_EXCEPTION;

	END Lock_Row;
--
--
--
   PROCEDURE check_unique_vendor_name	( p_vendor_id		in number,
				 	  p_vendor_name		in varchar2,
					  X_calling_sequence	in varchar2) is
   L_overlap_count number;

   current_calling_sequence    VARCHAR2(2000);
   debug_info                  VARCHAR2(100);
   --
   BEGIN
	   --     Update the calling sequence
	   --
           current_calling_sequence := 'AP_VENDORS_PKG.CHECK_UNIQUE_VENDOR_NAME<-' ||
                                        X_calling_sequence;

	   debug_info := 'Count vendors with same name';
	   SELECT  count(1)
	   INTO	   L_overlap_count
	   FROM	   po_vendors
	   WHERE   (p_vendor_id is null OR vendor_id <> p_vendor_id)
	   AND     (vendor_name like UPPER(SUBSTR(p_vendor_name,1,2))||'%'
	   OR      vendor_name like LOWER(SUBSTR(p_vendor_name,1,2))||'%'
	   OR      vendor_name like INITCAP(SUBSTR(p_vendor_name,1,2))||'%'
	   OR      vendor_name like LOWER(SUBSTR(p_vendor_name,1,1))||
				    UPPER(SUBSTR(p_vendor_name,2,1))||'%')
	   AND    UPPER(vendor_name) = UPPER(p_vendor_name);

	   if (L_overlap_count >= 1 ) then
		fnd_message.set_name('SQLAP','AP_VEN_DUPLICATE_NAME');
		FND_MSG_PUB.ADD;
		app_exception.raise_exception;
	   end if;
	   --
	   --
    	   EXCEPTION
        	WHEN OTHERS THEN
           	    IF (SQLCODE <> -20001) THEN
              		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              		FND_MSG_PUB.ADD;
              		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              		FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              		FND_MESSAGE.SET_TOKEN('PARAMETERS', 'VENDOR_ID = ' || p_vendor_id ||
				 	  ', VENDOR_NAME = ' || p_vendor_name);
              		FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           	    END IF;
                    APP_EXCEPTION.RAISE_EXCEPTION;

   END check_unique_vendor_name;
   --
   --
   procedure check_denormalized_vendor_name ( 	p_vendor_id		in number,
						p_warning_flag  	in out NOCOPY varchar2,
						X_calling_sequence	in varchar2) is
   --
   -- If invoices for this vendor have been selected, warn user, old name
   -- will appear on check - denormalised into AP_SELECTED_INVOICES
   -- join to sites so that index AP_SELECTED_INVOICES_N2 can be used
   -- there is no index on vendor_id in AP_SELECTED_INVOICES
   --
   l_overlap_count number;
   current_calling_sequence    VARCHAR2(2000);
   debug_info                  VARCHAR2(100);
   --
   begin
	   --     Update the calling sequence
	   --
           current_calling_sequence := 'AP_VENDORS_PKG.CHECK_DENORMALIZED_VENDOR_NAME<-' ||
                                        X_calling_sequence;

	   debug_info := 'Count overlap count for the vendor_id and site_id';
	   SELECT  count(1)
	   INTO	   L_overlap_count
	   FROM	   po_vendor_sites s,
		   ap_selected_invoices i
	   WHERE   s.vendor_id 		= p_vendor_id
	   AND	   i.vendor_site_id 	= s.vendor_site_id;
	   --
	   --
	   if (L_overlap_count >= 1 ) then
		fnd_message.set_name('SQLAP','AP_VENDOR_INV_SELECTED');
		FND_MSG_PUB.ADD;
                p_warning_flag := 'W';
	   end if;
           --
           EXCEPTION
              WHEN OTHERS THEN
           	    IF (SQLCODE <> -20001) THEN
              		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              		FND_MSG_PUB.ADD;
              		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              		FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              		FND_MESSAGE.SET_TOKEN('PARAMETERS', 'VENDOR_ID = ' || p_vendor_id ||
						', WARNING_FLAG = ' || p_warning_flag);
              		FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           	    END IF;
                    APP_EXCEPTION.RAISE_EXCEPTION;

   end check_denormalized_vendor_name;
   --
   --
   PROCEDURE check_unique_vendor_number ( p_vendor_id		in number,
					  p_vendor_number	in varchar2,
					  X_calling_sequence	in varchar2 ) is
   --
   l_overlap_count number;
   current_calling_sequence    VARCHAR2(2000);
   debug_info                  VARCHAR2(100);
   --
   BEGIN
	--     Update the calling sequence
	--
        current_calling_sequence := 'AP_VENDORS_PKG.CHECK_UNIQUE_VENDOR_NUMBER<-' ||
                                    X_calling_sequence;
	--
	--
	debug_info := 'Count overlap for vendor number';
	select 	count(1)
	into 	l_overlap_count
	from	po_vendors
	where 	segment1 = p_vendor_number
	and 	( p_vendor_id IS NULL  or vendor_id <> p_vendor_id );
	--
	--
	if (l_overlap_count = 0) then
		--
		--
		debug_info := 'Count overlap from po_history_vendors';
		select 	count(1)
		into 	l_overlap_count
		from 	po_history_vendors
		where 	segment1 = p_vendor_number;
		--
		--
	end if;
	--
	--
	if (L_overlap_count >= 1 ) then
		fnd_message.set_name('SQLAP','AP_VEN_DUPLICATE_VEN_NUM');
		-- Bug 6940256 udhenuko Message set needs to be added to the stack.
		FND_MSG_PUB.ADD;
		-- Bug 6940256 udhenuko End
		app_exception.raise_exception;
	end if;
	--
	--
    	EXCEPTION
       	  WHEN OTHERS THEN
           	    IF (SQLCODE <> -20001) THEN
              		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              		FND_MSG_PUB.ADD;
              		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              		FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              		FND_MESSAGE.SET_TOKEN('PARAMETERS', 'VENDOR_ID = ' || p_vendor_id ||
					  ', VENDOR_NUMBER = ' || p_vendor_number);
              		FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           	    END IF;
                    APP_EXCEPTION.RAISE_EXCEPTION;
	--
	--
  END check_unique_vendor_number;
--
--
  PROCEDURE CHECK_SELECTED_INVOICES (x_return_count	in out NOCOPY number,
				     x_vendor_id	in number,
				     X_calling_sequence in varchar2)	IS
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(100);
  BEGIN
	--     Update the calling sequence
	--
        current_calling_sequence := 'AP_VENDORS_PKG.CHECK_SELECTED_INVOICES<-' ||
                                    X_calling_sequence;

	debug_info := 'Count from AP_selected_invoices';
	select count(1)
	into x_return_count
	from AP_selected_invoices
	where vendor_id = x_vendor_id;

	EXCEPTION
       	  WHEN OTHERS THEN
           	    IF (SQLCODE <> -20001) THEN
              		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              		FND_MSG_PUB.ADD;
              		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              		FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              		FND_MESSAGE.SET_TOKEN('PARAMETERS','RETURN_COUNT = ' ||
  						x_return_count ||
				     		', VENDOR_ID = ' || x_vendor_id);
              		FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           	    END IF;
                    APP_EXCEPTION.RAISE_EXCEPTION;


  END CHECK_SELECTED_INVOICES;

procedure Check_Duplicate_Employee (p_rowid		in varchar2,
				    p_employee_id	in number,
				    X_calling_sequence	in varchar2) is
	L_Duplicate_count number;
    	current_calling_sequence    VARCHAR2(2000);
    	debug_info                  VARCHAR2(100);
begin
	--     Update the calling sequence
	--
        current_calling_sequence := 'AP_VENDORS_PKG.CHECK_DUPLICATE_EMPLOYEE<-' ||
                                    X_calling_sequence;

	debug_info := 'Count for same employee_id';
	SELECT 	count(1)
	INTO	L_Duplicate_Count
	FROM 	PO_VENDORS
	WHERE 	(p_rowid IS NULL OR rowid <> p_rowid)
	AND 	employee_id = p_employee_id;

	if (L_Duplicate_count > 0 ) then
		fnd_message.set_name('SQLAP','AP_EMPLOYEE_ASSIGNED');
		FND_MSG_PUB.ADD;
		app_exception.raise_exception;
	end if;

	EXCEPTION
       	  WHEN OTHERS THEN
           	    IF (SQLCODE <> -20001) THEN
              		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              		FND_MSG_PUB.ADD;
              		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              		FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              		FND_MESSAGE.SET_TOKEN('PARAMETERS','ROWID = ' || p_rowid ||
				    	', EMPLOYEE_ID = ' || p_employee_id);
              		FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           	    END IF;
                    APP_EXCEPTION.RAISE_EXCEPTION;

end Check_Duplicate_Employee;
--
--
procedure Resolve_employee(	x_employee_id		in number,
				x_employee_name 	in out NOCOPY varchar2,
				x_employee_number	in out NOCOPY varchar2,
				X_calling_sequence 	in varchar2)	IS

  current_calling_sequence    	VARCHAR2(2000);
  debug_info                 	VARCHAR2(100);
  begin

	--     Update the calling sequence
	--
        current_calling_sequence := 'AP_VENDORS_PKG.RESOLVE_EMPLOYEE<-' ||
                                    X_calling_sequence;

        -- For bug 2437569. Changed the view from hr_employees to
	-- hr_employees_current_v. This is to retrive the record details
	-- of only active employees .

	-- For bug2900352. Backing out the changes done for bug 2437569 .


	debug_info := 'Get employee name and number from HR_Employees using ID';
	select 	full_name,
		employee_num
	into	x_Employee_name,
		x_Employee_number
	from 	hr_employees          --bug: 2900352
	where   employee_id = x_employee_id;

	EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		x_employee_name := '';
		x_employee_number := '';
	     WHEN OTHERS THEN
           	IF (SQLCODE <> -20001) THEN
              		FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
              		FND_MSG_PUB.ADD;
              		FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
              		FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
              		FND_MESSAGE.SET_TOKEN('PARAMETERS',', EMPLOYEE_ID = ' || x_employee_id);
              		FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
           	 END IF;
                    APP_EXCEPTION.RAISE_EXCEPTION;

end Resolve_employee;


procedure get_message_text (			x_application		in varchar2,
						x_message_name		in varchar2,
						x_message_text		in out NOCOPY varchar2) is

begin
	x_message_text := fnd_message.get_string( x_application,
						  x_message_name);
	if x_message_text is null then
		x_message_text := x_message_name;
	end if;

end Get_Message_text;

/* bug6830122. Creating Autonomus transaction for
   automatic supplier numbering for avoiding locikng
   contention for product setup table */

  FUNCTION Update_Product_Setup return number is
  PRAGMA AUTONOMOUS_TRANSACTION;

    CURSOR ap_product_setup_c is
    SELECT next_auto_supplier_num
    FROM ap_product_setup
    FOR UPDATE OF next_auto_supplier_num;

    l_segment1 ap_product_setup.next_auto_supplier_num%type;

  BEGIN

    Open ap_product_setup_c;
    Fetch ap_product_setup_c into l_segment1;

    If(ap_product_setup_c%notfound) Then
      RAISE NO_DATA_FOUND;
    End if;
    Close ap_product_setup_c;

    UPDATE ap_product_setup
    SET next_auto_supplier_num = next_auto_supplier_num + 1;
    commit;

    return l_segment1;

  END Update_Product_Setup;

END AP_VENDORS_PKG;

/
