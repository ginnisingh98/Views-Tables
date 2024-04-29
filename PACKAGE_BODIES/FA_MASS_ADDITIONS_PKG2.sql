--------------------------------------------------------
--  DDL for Package Body FA_MASS_ADDITIONS_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASS_ADDITIONS_PKG2" as
/* $Header: faxima2b.pls 120.6.12010000.2 2009/07/19 10:40:43 glchen ship $ */
----
  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Mass_Addition_Id                 NUMBER   DEFAULT NULL,
                     X_Asset_Number                     VARCHAR2 DEFAULT NULL,
                     X_Tag_Number                       VARCHAR2 DEFAULT NULL,
                     X_Description                      VARCHAR2 DEFAULT NULL,
                     X_Asset_Category_Id                NUMBER   DEFAULT NULL,
                     X_Manufacturer_Name                VARCHAR2 DEFAULT NULL,
                     X_Serial_Number                    VARCHAR2 DEFAULT NULL,
                     X_Model_Number                     VARCHAR2 DEFAULT NULL,
                     X_Book_Type_Code                   VARCHAR2 DEFAULT NULL,
                     X_Date_Placed_In_Service           DATE     DEFAULT NULL,
                     X_Fixed_Assets_Cost                NUMBER   DEFAULT NULL,
                     X_Payables_Units                   NUMBER   DEFAULT NULL,
                     X_Fixed_Assets_Units               NUMBER   DEFAULT NULL,
                     X_Payables_Code_Combination_Id     NUMBER   DEFAULT NULL,
                     X_Expense_Code_Combination_Id      NUMBER   DEFAULT NULL,
                     X_Location_Id                      NUMBER   DEFAULT NULL,
                     X_Assigned_To                      NUMBER   DEFAULT NULL,
                     X_Feeder_System_Name               VARCHAR2 DEFAULT NULL,
                     X_Create_Batch_Date                DATE     DEFAULT NULL,
                     X_Create_Batch_Id                  NUMBER   DEFAULT NULL,
                     X_Reviewer_Comments                VARCHAR2 DEFAULT NULL,
                     X_Invoice_Number                   VARCHAR2 DEFAULT NULL,
                     X_Vendor_Number                    VARCHAR2 DEFAULT NULL,
                     X_Po_Vendor_Id                     NUMBER   DEFAULT NULL,
                     X_Po_Number                        VARCHAR2 DEFAULT NULL,
                     X_Posting_Status                   VARCHAR2 DEFAULT NULL,
                     X_Queue_Name                       VARCHAR2 DEFAULT NULL,
                     X_Invoice_Date                     DATE     DEFAULT NULL,
                     X_Invoice_Created_By               NUMBER   DEFAULT NULL,
                     X_Invoice_Updated_By               NUMBER   DEFAULT NULL,
                     X_Payables_Cost                    NUMBER   DEFAULT NULL,
                     X_Invoice_Id                       NUMBER   DEFAULT NULL,
                     X_Payables_Batch_Name              VARCHAR2 DEFAULT NULL,
                     X_Depreciate_Flag                  VARCHAR2 DEFAULT NULL,
                     X_Parent_Mass_Addition_Id          NUMBER   DEFAULT NULL,
                     X_Parent_Asset_Id                  NUMBER   DEFAULT NULL,
                     X_Split_Merged_Code                VARCHAR2 DEFAULT NULL,
                     X_Ap_Distribution_Line_Number      NUMBER   DEFAULT NULL,
                     X_Post_Batch_Id                    NUMBER   DEFAULT NULL,
                     X_Add_To_Asset_Id                  NUMBER   DEFAULT NULL,
                     X_Amortize_Flag                    VARCHAR2 DEFAULT NULL,
                     X_New_Master_Flag                  VARCHAR2 DEFAULT NULL,
                     X_Asset_Key_Ccid                   NUMBER   DEFAULT NULL,
                     X_Asset_Type                       VARCHAR2 DEFAULT NULL,
                     X_Deprn_Reserve                    NUMBER   DEFAULT NULL,
                     X_Ytd_Deprn                        NUMBER   DEFAULT NULL,
                     X_Beginning_Nbv                    NUMBER   DEFAULT NULL,
                     X_Salvage_Value                    NUMBER   DEFAULT NULL,
                     X_Accounting_Date                  DATE     DEFAULT NULL,
                     X_Attribute1                       VARCHAR2 DEFAULT NULL,
                     X_Attribute2                       VARCHAR2 DEFAULT NULL,
                     X_Attribute3                       VARCHAR2 DEFAULT NULL,
                     X_Attribute4                       VARCHAR2 DEFAULT NULL,
                     X_Attribute5                       VARCHAR2 DEFAULT NULL,
                     X_Attribute6                       VARCHAR2 DEFAULT NULL,
                     X_Attribute7                       VARCHAR2 DEFAULT NULL,
                     X_Attribute8                       VARCHAR2 DEFAULT NULL,
                     X_Attribute9                       VARCHAR2 DEFAULT NULL,
                     X_Attribute10                      VARCHAR2 DEFAULT NULL,
                     X_Attribute11                      VARCHAR2 DEFAULT NULL,
                     X_Attribute12                      VARCHAR2 DEFAULT NULL,
                     X_Attribute13                      VARCHAR2 DEFAULT NULL,
                     X_Attribute14                      VARCHAR2 DEFAULT NULL,
                     X_Attribute15                      VARCHAR2 DEFAULT NULL,
                     X_Attribute_Category_Code          VARCHAR2 DEFAULT NULL,
                     X_Fully_Rsvd_Revals_Counter        NUMBER   DEFAULT NULL,
                     X_Merge_Invoice_Number             VARCHAR2 DEFAULT NULL,
                     X_Merge_Vendor_Number              VARCHAR2 DEFAULT NULL,
                     X_Production_Capacity              NUMBER   DEFAULT NULL,
                     X_Reval_Amortization_Basis         NUMBER   DEFAULT NULL,
                     X_Reval_Reserve                    NUMBER   DEFAULT NULL,
                     X_Unit_Of_Measure                  VARCHAR2 DEFAULT NULL,
                     X_Unrevalued_Cost                  NUMBER   DEFAULT NULL,
                     X_Ytd_Reval_Deprn_Expense          NUMBER   DEFAULT NULL,
                     X_Attribute16                      VARCHAR2 DEFAULT NULL,
                     X_Attribute17                      VARCHAR2 DEFAULT NULL,
                     X_Attribute18                      VARCHAR2 DEFAULT NULL,
                     X_Attribute19                      VARCHAR2 DEFAULT NULL,
                     X_Attribute20                      VARCHAR2 DEFAULT NULL,
                     X_Attribute21                      VARCHAR2 DEFAULT NULL,
                     X_Attribute22                      VARCHAR2 DEFAULT NULL,
                     X_Attribute23                      VARCHAR2 DEFAULT NULL,
                     X_Attribute24                      VARCHAR2 DEFAULT NULL,
                     X_Attribute25                      VARCHAR2 DEFAULT NULL,
                     X_Attribute26                      VARCHAR2 DEFAULT NULL,
                     X_Attribute27                      VARCHAR2 DEFAULT NULL,
                     X_Attribute28                      VARCHAR2 DEFAULT NULL,
                     X_Attribute29                      VARCHAR2 DEFAULT NULL,
                     X_Attribute30                      VARCHAR2 DEFAULT NULL,
                     X_Merged_Code                      VARCHAR2 DEFAULT NULL,
                     X_Split_Code                       VARCHAR2 DEFAULT NULL,
                     X_Merge_Parent_Mass_Add_Id   	     NUMBER   DEFAULT NULL,
                     X_Split_Parent_Mass_Add_Id   	     NUMBER   DEFAULT NULL,
		               X_Sum_Units			                 VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE1                VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE10               VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE11               VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE12               VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE13               VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE14               VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE15               VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE16               VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE17               VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE18               VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE19               VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE2                VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE20               VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE3                VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE4                VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE5                VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE6                VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE7                VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE8                VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE9                VARCHAR2 DEFAULT NULL,
                     X_GLOBAL_ATTRIBUTE_CATEGORY        VARCHAR2 DEFAULT NULL,
                     X_INVENTORIAL                      VARCHAR2 DEFAULT NULL,
                     X_Transaction_type_code            VARCHAR2 DEFAULT NULL,
                     X_transaction_date                 DATE     DEFAULT NULL,
                     X_warranty_id                      NUMBER   DEFAULT NULL,
                     X_lease_id                         NUMBER   DEFAULT NULL,
                     X_lessor_id                        NUMBER   DEFAULT NULL,
                     X_property_type_code               VARCHAR2 DEFAULT NULL,
                     X_property_1245_1250_code          VARCHAR2 DEFAULT NULL,
                     X_in_use_flag                      VARCHAR2 DEFAULT NULL,
                     X_owned_leased                     VARCHAR2 DEFAULT NULL,
                     X_new_used                         VARCHAR2 DEFAULT NULL,
                     X_asset_id                         NUMBER   DEFAULT NULL,
                     X_invoice_distribution_id          NUMBER   DEFAULT NULL,
                     X_invoice_line_number              NUMBER   DEFAULT NULL,
                     X_po_distribution_id               NUMBER   DEFAULT NULL,
                     X_warranty_number                  VARCHAR2 DEFAULT NULL ,
                     p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
      SELECT	mass_addition_id,
		asset_number,
		tag_number,
		description,
		asset_category_id,
		manufacturer_name,
		serial_number,
		model_number,
		book_type_code,
		date_placed_in_service,
		fixed_assets_cost,
		payables_units,
		fixed_assets_units,
		payables_code_combination_id,
		expense_code_combination_id,
		location_id,
		assigned_to,
		feeder_system_name,
		create_batch_date,
		create_batch_id,
		last_update_date,
		last_updated_by,
		reviewer_comments,
		invoice_number,
		vendor_number,
		po_vendor_id,
		po_number,
		posting_status,
		queue_name,
		invoice_date,
		invoice_created_by,
		invoice_updated_by,
		payables_cost,
		invoice_id,
		payables_batch_name,
		depreciate_flag,
		parent_mass_addition_id,
		parent_asset_id,
		split_merged_code,
		ap_distribution_line_number,
		post_batch_id,
		add_to_asset_id,
		amortize_flag,
		new_master_flag,
		asset_key_ccid,
		asset_type,
		deprn_reserve,
		ytd_deprn,
		beginning_nbv,
		created_by,
		creation_date,
		last_update_login,
		salvage_value,
		accounting_date,
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
		attribute_category_code,
		fully_rsvd_revals_counter,
		merge_invoice_number,
		merge_vendor_number,
		production_capacity,
		reval_amortization_basis,
		reval_reserve,
		unit_of_measure,
		unrevalued_cost,
		ytd_reval_deprn_expense,
		attribute16,
		attribute17,
		attribute18,
		attribute19,
		attribute20,
		attribute21,
		attribute22,
		attribute23,
		attribute24,
		attribute25,
		attribute26,
		attribute27,
		attribute28,
		attribute29,
		attribute30,
		merged_code,
		split_code,
		merge_parent_mass_additions_id,
		split_parent_mass_additions_id,
		project_asset_line_id,
		project_id,
		task_id,
		sum_units,
		dist_name,
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
		global_attribute_category,
		context,
		inventorial,
		short_fiscal_year_flag,
		conversion_date,
		original_deprn_start_date,
      transaction_type_code,
      transaction_date,
      warranty_id,
      lease_id,
      lessor_id,
      property_type_code,
      property_1245_1250_code,
      in_use_flag,
      owned_leased,
      new_used,
      asset_id,
      invoice_distribution_id,
      invoice_line_number,
      po_distribution_id,
      warranty_number
        FROM   fa_mass_additions
        WHERE  rowid = X_Rowid
        FOR UPDATE of Mass_Addition_Id NOWAIT;
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
    if (      (   (Recinfo.mass_addition_id =  X_Mass_Addition_Id)
                OR (    (Recinfo.mass_addition_id IS NULL)
                    AND (X_Mass_Addition_Id IS NULL)))
           AND (   (Recinfo.asset_number =  X_Asset_Number)
                OR (    (Recinfo.asset_number IS NULL)
                    AND (X_Asset_Number IS NULL)))
 	   AND (   (Recinfo.tag_number =  X_Tag_Number)
                OR (    (Recinfo.tag_number IS NULL)
                    AND (X_Tag_Number IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.asset_category_id =  X_Asset_Category_Id)
                OR (    (Recinfo.asset_category_id IS NULL)
                    AND (X_Asset_Category_Id IS NULL)))
           AND (   (Recinfo.manufacturer_name =  X_Manufacturer_Name)
                OR (    (Recinfo.manufacturer_name IS NULL)
                    AND (X_Manufacturer_Name IS NULL)))
           AND (   (Recinfo.serial_number =  X_Serial_Number)
                OR (    (Recinfo.serial_number IS NULL)
                    AND (X_Serial_Number IS NULL)))
           AND (   (Recinfo.model_number =  X_Model_Number)
                OR (    (Recinfo.model_number IS NULL)
                    AND (X_Model_Number IS NULL)))
           AND (   (Recinfo.book_type_code =  X_Book_Type_Code)
                OR (    (Recinfo.book_type_code IS NULL)
                    AND (X_Book_Type_Code IS NULL)))
 	   AND (   (Recinfo.date_placed_in_service =  X_Date_Placed_In_Service)
                OR (    (Recinfo.date_placed_in_service IS NULL) ))
/* fixing for bug #586288.. mass_addition_3.s_date_placed_in_service
   modifies the date if it is null... so we would get FORM_RECORD_CHANGED
   error... only generate error if it is original is NOT null
                    AND (X_Date_Placed_In_Service IS NULL)))
*/
           AND (   (Recinfo.fixed_assets_cost =  X_Fixed_Assets_Cost)
                OR (    (Recinfo.fixed_assets_cost IS NULL)
                    AND (X_Fixed_Assets_Cost IS NULL)))
           AND (   (Recinfo.payables_units =  X_Payables_Units)
                OR (    (Recinfo.payables_units IS NULL)
                    AND (X_Payables_Units IS NULL)))
           AND (   (Recinfo.fixed_assets_units =  X_Fixed_Assets_Units)
                OR (    (Recinfo.fixed_assets_units IS NULL)
                    AND (X_Fixed_Assets_Units IS NULL)))
/*
           AND (   (Recinfo.payables_code_combination_id =  X_Payables_Code_Combination_Id)
                OR (    (Recinfo.payables_code_combination_id IS NULL)
                    AND (X_Payables_Code_Combination_Id IS NULL)))
           AND (   (Recinfo.expense_code_combination_id =  X_Expense_Code_Combination_Id)
                OR (  (Recinfo.expense_code_combination_id IS NULL)
                    AND (X_Expense_Code_Combination_Id IS NULL)
 		    )
		)
           AND (   (Recinfo.location_id =  X_Location_Id)
                OR (    (Recinfo.location_id IS NULL)
                    AND (X_Location_Id IS NULL)))
           AND (   (Recinfo.assigned_to =  X_Assigned_To)
                OR (    (Recinfo.assigned_to IS NULL)
                    AND (X_Assigned_To IS NULL)))
           AND (   (Recinfo.feeder_system_name =  X_Feeder_System_Name)
                OR (    (Recinfo.feeder_system_name IS NULL)
                    AND (X_Feeder_System_Name IS NULL)))

           AND (   (Recinfo.create_batch_date =  X_Create_Batch_Date)
                OR (    (Recinfo.create_batch_date IS NULL)
                    AND (X_Create_Batch_Date IS NULL)))
*/
           AND (   (Recinfo.create_batch_id =  X_Create_Batch_Id)
                OR (    (Recinfo.create_batch_id IS NULL)
                    AND (X_Create_Batch_Id IS NULL)))
           AND (   (Recinfo.reviewer_comments =  X_Reviewer_Comments)
                OR (    (Recinfo.reviewer_comments IS NULL)
                    AND (X_Reviewer_Comments IS NULL)))
           AND (   (Recinfo.invoice_number =  X_Invoice_Number)
                OR (    (Recinfo.invoice_number IS NULL)
                    AND (X_Invoice_Number IS NULL)))
/*
           AND (   (Recinfo.vendor_number =  X_Vendor_Number)
                OR (    (Recinfo.vendor_number IS NULL)
                    AND (X_Vendor_Number IS NULL)))
*/
           AND (   (Recinfo.po_vendor_id =  X_Po_Vendor_Id)
                OR (    (Recinfo.po_vendor_id IS NULL)
                    AND (X_Po_Vendor_Id IS NULL)))
           AND (   (Recinfo.po_number =  X_Po_Number)
                OR (    (Recinfo.po_number IS NULL)
                    AND (X_Po_Number IS NULL)))
           AND (   (Recinfo.posting_status =  X_Posting_Status)
                OR (    (Recinfo.posting_status IS NULL)
                    AND (X_Posting_Status IS NULL)))
           AND (   (Recinfo.queue_name =  X_Queue_Name)
                OR (    (Recinfo.queue_name IS NULL)
                    AND (X_Queue_Name IS NULL)))
           AND (   (Recinfo.invoice_date =  X_Invoice_Date)
                OR (    (Recinfo.invoice_date IS NULL)
                    AND (X_Invoice_Date IS NULL)))
           AND (   (Recinfo.invoice_created_by =  X_Invoice_Created_By)
                OR (    (Recinfo.invoice_created_by IS NULL)
                    AND (X_Invoice_Created_By IS NULL)))
           AND (   (Recinfo.invoice_updated_by =  X_Invoice_Updated_By)
                OR (    (Recinfo.invoice_updated_by IS NULL)
                    AND (X_Invoice_Updated_By IS NULL)))	) then
      	   null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    if  (   ((Recinfo.payables_cost =  X_Payables_Cost)
                OR (    (Recinfo.payables_cost IS NULL)
                    AND (X_Payables_Cost IS NULL)))
           AND (   (Recinfo.invoice_id =  X_Invoice_Id)
                OR (    (Recinfo.invoice_id IS NULL)
                    AND (X_Invoice_Id IS NULL)))
           AND (   (Recinfo.payables_batch_name =  X_Payables_Batch_Name)
                OR (    (Recinfo.payables_batch_name IS NULL)
                    AND (X_Payables_Batch_Name IS NULL)))
           AND (   (Recinfo.depreciate_flag =  X_Depreciate_Flag)
                OR (    (Recinfo.depreciate_flag IS NULL)
                    AND (X_Depreciate_Flag IS NULL)))
           AND (   (Recinfo.parent_mass_addition_id =  X_Parent_Mass_Addition_Id)
                OR (    (Recinfo.parent_mass_addition_id IS NULL)
                    AND (X_Parent_Mass_Addition_Id IS NULL)))
           AND (   (Recinfo.parent_asset_id =  X_Parent_Asset_Id)
                OR (    (Recinfo.parent_asset_id IS NULL)
                    AND (X_Parent_Asset_Id IS NULL)))
           AND (   (Recinfo.split_merged_code =  X_Split_Merged_Code)
                OR (    (Recinfo.split_merged_code IS NULL)
                    AND (X_Split_Merged_Code IS NULL)))
           AND (   (Recinfo.ap_distribution_line_number =  X_Ap_Distribution_Line_Number)
                OR (    (Recinfo.ap_distribution_line_number IS NULL)
                    AND (X_Ap_Distribution_Line_Number IS NULL)))
           AND (   (Recinfo.post_batch_id =  X_Post_Batch_Id)
                OR (    (Recinfo.post_batch_id IS NULL)
                    AND (X_Post_Batch_Id IS NULL)))
           AND (   (Recinfo.add_to_asset_id =  X_Add_To_Asset_Id)
                OR (    (Recinfo.add_to_asset_id IS NULL)
                    AND (X_Add_To_Asset_Id IS NULL)))
           AND (   (Recinfo.amortize_flag =  X_Amortize_Flag)
                OR (    (Recinfo.amortize_flag IS NULL)
                    AND (X_Amortize_Flag IS NULL)))
           AND (   (Recinfo.new_master_flag =  X_New_Master_Flag)
                OR (    (Recinfo.new_master_flag IS NULL)
                    AND (X_New_Master_Flag IS NULL)))
           AND (   (Recinfo.asset_key_ccid =  X_Asset_Key_Ccid)
                OR (    (Recinfo.asset_key_ccid IS NULL)
                    AND (X_Asset_Key_Ccid IS NULL)))
           AND (   (Recinfo.asset_type =  X_Asset_Type)
                OR (    (Recinfo.asset_type IS NULL)
                    AND (X_Asset_Type IS NULL)))
           AND (   (Recinfo.deprn_reserve =  X_Deprn_Reserve)
                OR (    (Recinfo.deprn_reserve IS NULL)
                    AND (X_Deprn_Reserve IS NULL)))
           AND (   (Recinfo.ytd_deprn =  X_Ytd_Deprn)
                OR (    (Recinfo.ytd_deprn IS NULL)
                    AND (X_Ytd_Deprn IS NULL)))
           AND (   (Recinfo.beginning_nbv =  X_Beginning_Nbv)
                OR (    (Recinfo.beginning_nbv IS NULL)
                    AND (X_Beginning_Nbv IS NULL)))
   --- The following line has been commented By Satish Byreddy as part of BUG#7142744
   ----as the field salvage_value is non-database item in the form and the form is raising error  frm-40654
        /*   AND (   (Recinfo.salvage_value =  X_Salvage_Value)
                OR (    (Recinfo.salvage_value IS NULL)
                    AND (X_Salvage_Value IS NULL)))*/
  ----- End of the Comment
           AND (   (Recinfo.accounting_date =  X_Accounting_Date)
                OR (    (Recinfo.accounting_date IS NULL)
                    AND (X_Accounting_Date IS NULL)))
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
           AND (   (Recinfo.invoice_distribution_id = X_Invoice_Distribution_id)
                OR (    (Recinfo.invoice_distribution_id IS NULL)
                    AND (X_invoice_distribution_id IS NULL)))
           AND (   (Recinfo.invoice_line_number =  X_invoice_Line_Number)
                OR (    (Recinfo.invoice_line_number IS NULL)
                    AND (X_invoice_Line_Number IS NULL)))
           AND (   (Recinfo.po_distribution_id =  X_po_Distribution_id)
                OR (    (Recinfo.po_distribution_id IS NULL)
                    AND (X_po_distribution_id IS NULL)))
           AND (   (Recinfo.warranty_number =  X_warranty_number )
                OR (    (Recinfo.warranty_number IS NULL)
                    AND (X_warranty_number IS NULL)))) then
      null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

    if  (   ((Recinfo.attribute12 =  X_Attribute12)
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
           AND (   (Recinfo.attribute_category_code =  X_Attribute_Category_Code)
                OR (    (Recinfo.attribute_category_code IS NULL)
                    AND (X_Attribute_Category_Code IS NULL)))
           AND (   (Recinfo.fully_rsvd_revals_counter =  X_Fully_Rsvd_Revals_Counter)
                OR (    (Recinfo.fully_rsvd_revals_counter IS NULL)
                    AND (X_Fully_Rsvd_Revals_Counter IS NULL)))
           AND (   (Recinfo.merge_invoice_number =  X_Merge_Invoice_Number)
                OR (    (Recinfo.merge_invoice_number IS NULL)
                    AND (X_Merge_Invoice_Number IS NULL)))
           AND (   (Recinfo.merge_vendor_number =  X_Merge_Vendor_Number)
                OR (    (Recinfo.merge_vendor_number IS NULL)
                    AND (X_Merge_Vendor_Number IS NULL)))
           AND (   (Recinfo.production_capacity =  X_Production_Capacity)
                OR (    (Recinfo.production_capacity IS NULL)
                    AND (X_Production_Capacity IS NULL)))
           AND (   (Recinfo.reval_amortization_basis =  X_Reval_Amortization_Basis)
                OR (    (Recinfo.reval_amortization_basis IS NULL)
                    AND (X_Reval_Amortization_Basis IS NULL)))
           AND (   (Recinfo.reval_reserve =  X_Reval_Reserve)
                OR (    (Recinfo.reval_reserve IS NULL)
                    AND (X_Reval_Reserve IS NULL)))
           AND (   (Recinfo.unit_of_measure =  X_Unit_Of_Measure)
                OR (    (Recinfo.unit_of_measure IS NULL)
                    AND (X_Unit_Of_Measure IS NULL)))
           AND (   (Recinfo.unrevalued_cost =  X_Unrevalued_Cost)
                OR (    (Recinfo.unrevalued_cost IS NULL)
                    AND (X_Unrevalued_Cost IS NULL)))
           AND (   (Recinfo.ytd_reval_deprn_expense =  X_Ytd_Reval_Deprn_Expense)
                OR (    (Recinfo.ytd_reval_deprn_expense IS NULL)
                    AND (X_Ytd_Reval_Deprn_Expense IS NULL)))
           AND (   (Recinfo.attribute16 =  X_Attribute16)
                OR (    (Recinfo.attribute16 IS NULL)
                    AND (X_Attribute16 IS NULL)))
           AND (   (Recinfo.attribute17 =  X_Attribute17)
                OR (    (Recinfo.attribute17 IS NULL)
                    AND (X_Attribute17 IS NULL)))
           AND (   (Recinfo.attribute18 =  X_Attribute18)
                OR (    (Recinfo.attribute18 IS NULL)
                    AND (X_Attribute18 IS NULL)))
           AND (   (Recinfo.attribute19 =  X_Attribute19)
                OR (    (Recinfo.attribute19 IS NULL)
                    AND (X_Attribute19 IS NULL)))
           AND (   (Recinfo.attribute20 =  X_Attribute20)
                OR (    (Recinfo.attribute20 IS NULL)
                    AND (X_Attribute20 IS NULL)))
           AND (   (Recinfo.attribute21 =  X_Attribute21)
                OR (    (Recinfo.attribute21 IS NULL)
                    AND (X_Attribute21 IS NULL)))
           AND (   (Recinfo.attribute22 =  X_Attribute22)
                OR (    (Recinfo.attribute22 IS NULL)
                    AND (X_Attribute22 IS NULL)))
           AND (   (Recinfo.attribute23 =  X_Attribute23)
                OR (    (Recinfo.attribute23 IS NULL)
                    AND (X_Attribute23 IS NULL)))
           AND (   (Recinfo.attribute24 =  X_Attribute24)
                OR (    (Recinfo.attribute24 IS NULL)
                    AND (X_Attribute24 IS NULL)))
           AND (   (Recinfo.attribute25 =  X_Attribute25)
                OR (    (Recinfo.attribute25 IS NULL)
                    AND (X_Attribute25 IS NULL)))
           AND (   (Recinfo.attribute26 =  X_Attribute26)
                OR (    (Recinfo.attribute26 IS NULL)
                    AND (X_Attribute26 IS NULL)))
           AND (   (Recinfo.attribute27 =  X_Attribute27)
                OR (    (Recinfo.attribute27 IS NULL)
                    AND (X_Attribute27 IS NULL)))
           AND (   (Recinfo.attribute28 =  X_Attribute28)
                OR (    (Recinfo.attribute28 IS NULL)
                    AND (X_Attribute28 IS NULL)))
           AND (   (Recinfo.attribute29 =  X_Attribute29)
                OR (    (Recinfo.attribute29 IS NULL)
                    AND (X_Attribute29 IS NULL)))
           AND (   (Recinfo.attribute30 =  X_Attribute30)
                OR (    (Recinfo.attribute30 IS NULL)
                    AND (X_Attribute30 IS NULL)))
           AND (   (Recinfo.merged_code =  X_Merged_Code)
                OR (    (Recinfo.merged_code IS NULL)
                    AND (X_Merged_Code IS NULL)))
           AND (   (Recinfo.split_code =  X_Split_Code)
                OR (    (Recinfo.split_code IS NULL)
                    AND (X_Split_Code IS NULL)))
           AND (   (Recinfo.merge_parent_mass_additions_id =  X_Merge_Parent_Mass_Add_Id)
                OR (    (Recinfo.merge_parent_mass_additions_id IS NULL)
                    AND (X_Merge_Parent_Mass_Add_Id IS NULL)))
           AND (   (Recinfo.split_parent_mass_additions_id =  X_Split_Parent_Mass_Add_Id)
                OR (    (Recinfo.split_parent_mass_additions_id IS NULL)
                    AND (X_Split_Parent_Mass_Add_Id IS NULL)))
	   AND (   (Recinfo.sum_units = X_Sum_Units)
		OR (    (Recinfo.sum_units IS NULL)
		    AND (X_Sum_Units IS NULL))) ) then
      null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

--

/*
    if  ( (   (Recinfo.inventorial =  X_inventorial)
                OR (    (Recinfo.inventorial IS NULL)
                    AND (X_inventorial IS NULL))) ) then
      null;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
*/

--
    if  ( (   (Recinfo.global_attribute1 =  X_global_Attribute1)
                OR (    (Recinfo.global_attribute1 IS NULL)
                    AND (X_global_Attribute1 IS NULL)))
           AND (   (Recinfo.global_attribute2 =  X_global_Attribute2)
                OR (    (Recinfo.global_attribute2 IS NULL)
                    AND (X_global_Attribute2 IS NULL)))
           AND (   (Recinfo.global_attribute3 =  X_global_Attribute3)
                OR (    (Recinfo.global_attribute3 IS NULL)
                    AND (X_global_Attribute3 IS NULL)))
           AND (   (Recinfo.global_attribute4 =  X_global_Attribute4)
                OR (    (Recinfo.global_attribute4 IS NULL)
                    AND (X_global_Attribute4 IS NULL)))
           AND (   (Recinfo.global_attribute5 =  X_global_Attribute5)
                OR (    (Recinfo.global_attribute5 IS NULL)
                    AND (X_global_Attribute5 IS NULL)))
           AND (   (Recinfo.global_attribute6 =  X_global_Attribute6)
                OR (    (Recinfo.global_attribute6 IS NULL)
                    AND (X_global_Attribute6 IS NULL)))
           AND (   (Recinfo.global_attribute7 =  X_global_Attribute7)
                OR (    (Recinfo.global_attribute7 IS NULL)
                    AND (X_global_Attribute7 IS NULL)))
           AND (   (Recinfo.global_attribute8 =  X_global_Attribute8)
                OR (    (Recinfo.global_attribute8 IS NULL)
                    AND (X_global_Attribute8 IS NULL)))
           AND (   (Recinfo.global_attribute9 =  X_global_Attribute9)
                OR (    (Recinfo.global_attribute9 IS NULL)
                    AND (X_global_Attribute9 IS NULL)))
           AND (   (Recinfo.global_attribute10 =  X_global_Attribute10)
                OR (    (Recinfo.global_attribute10 IS NULL)
                    AND (X_global_Attribute10 IS NULL)))
           AND (   (Recinfo.global_attribute11 =  X_global_Attribute11)
                OR (    (Recinfo.global_attribute11 IS NULL)
                    AND (X_global_Attribute11 IS NULL)))
           AND (   (Recinfo.global_attribute12 =  X_global_Attribute12)
                OR (    (Recinfo.global_attribute12 IS NULL)
                    AND (X_global_Attribute12 IS NULL)))
           AND (   (Recinfo.global_attribute13 =  X_global_Attribute13)
                OR (    (Recinfo.global_attribute13 IS NULL)
                    AND (X_global_Attribute13 IS NULL)))
           AND (   (Recinfo.global_attribute14 =  X_global_Attribute14)
                OR (    (Recinfo.global_attribute14 IS NULL)
                    AND (X_global_Attribute14 IS NULL)))
           AND (   (Recinfo.global_attribute15 =  X_global_Attribute15)
                OR (    (Recinfo.global_attribute15 IS NULL)
                    AND (X_global_Attribute15 IS NULL)))
           AND (   (Recinfo.global_attribute16 =  X_global_Attribute16)
                OR (    (Recinfo.global_attribute16 IS NULL)
                    AND (X_global_Attribute16 IS NULL)))
           AND (   (Recinfo.global_attribute17 =  X_global_Attribute17)
                OR (    (Recinfo.global_attribute17 IS NULL)
                    AND (X_global_Attribute17 IS NULL)))
           AND (   (Recinfo.global_attribute18 =  X_global_Attribute18)
                OR (    (Recinfo.global_attribute18 IS NULL)
                    AND (X_global_Attribute18 IS NULL)))
           AND (   (Recinfo.global_attribute19 =  X_global_Attribute19)
                OR (    (Recinfo.global_attribute19 IS NULL)
                    AND (X_global_Attribute19 IS NULL)))
           AND (   (Recinfo.global_attribute20 =  X_global_Attribute20)
                OR (    (Recinfo.global_attribute20 IS NULL)
                    AND (X_global_Attribute20 IS NULL)))) then

      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
--
 /* added the following code for FT enhancement RefBug: 1399562 */
/****
       if  (   (   (Recinfo.transaction_type_code = X_transaction_type_code )
                OR (    (Recinfo.transaction_type_code IS NULL )
                    AND (X_transaction_type_code IS NULL )))
           AND (   (Recinfo.transaction_date = X_transaction_date )
                OR (    (Recinfo.transaction_date IS NULL)
                    AND (X_transaction_date IS NULL )))
           AND (   (Recinfo.warranty_id = X_warranty_id )
                OR (    (Recinfo.warranty_id IS NULL)
                    AND (X_warranty_id IS NULL )))
           AND (   (Recinfo.lease_id = X_lease_id )
                OR (    (Recinfo.lease_id IS NULL)
                    AND (X_lease_id IS NULL )))
           AND (   (Recinfo.lessor_id = X_lessor_id )
                OR (    (Recinfo.lessor_id IS NULL)
                    AND (X_lessor_id IS NULL )))
           AND (   (Recinfo.property_type_code = X_property_type_code )
                OR (    (Recinfo.property_type_code IS NULL)
                    AND (X_property_type_code IS NULL )))
           AND (   (Recinfo.property_1245_1250_code = X_property_1245_1250_code )
                OR (    (Recinfo.property_1245_1250_code IS NULL)
                    AND (X_property_1245_1250_code IS NULL )))
           AND (   (Recinfo.in_use_flag = X_in_use_flag )
                OR (    (Recinfo.in_use_flag IS NULL)
                    AND (X_in_use_flag IS NULL)))
           AND (   (Recinfo.owned_leased = X_owned_leased )
                OR (    (Recinfo.owned_leased IS NULL)
                    AND (X_owned_leased IS NULL )))
           AND (   (Recinfo.new_used = X_new_used )
                OR (    (Recinfo.new_used IS NULL)
                    AND (X_new_used IS NULL )))
           AND (   (Recinfo.asset_id = X_asset_id )
                OR (    (Recinfo.asset_id IS NULL)
                    AND (X_asset_id IS NULL )))   ) then
             null;
     else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

 ****/
  END Lock_Row;

---

  PROCEDURE Delete_Row(X_Rowid VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    DELETE FROM fa_mass_additions
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

---
  PROCEDURE Select_Summary(X_MAss_Addition_ID IN  NUMBER,
			        X_TOTAL_COST            IN OUT NOCOPY NUMBER,
			   	X_TOTAL_COST_RTOT_DB    IN OUT NOCOPY NUMBER,
			   	X_TOTAL_UNITS            IN OUT NOCOPY NUMBER,
			   	X_TOTAL_UNITS_RTOT_DB    IN OUT NOCOPY NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  Begin
	Select NVL(Sum(Fixed_Assets_Cost), 0), NVL(Sum(Fixed_Assets_Cost), 0),
	       NVL(Sum(Fixed_Assets_Units), 0), NVL(Sum(Fixed_Assets_Units), 0)
		Into X_Total_Cost, X_TOTAL_Cost_RTOT_DB,
	             X_Total_Units, X_Total_Units_RTOT_DB
	From Fa_MAss_Additions
	Where Merge_PArent_MAss_Additions_ID = X_Mass_Addition_ID;

  End Select_Summary;

END FA_MASS_ADDITIONS_PKG2;

/
