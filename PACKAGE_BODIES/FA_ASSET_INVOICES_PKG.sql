--------------------------------------------------------
--  DDL for Package Body FA_ASSET_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ASSET_INVOICES_PKG" as
/* $Header: faxiaib.pls 120.7.12010000.2 2009/07/19 13:27:42 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Po_Vendor_Id                   NUMBER DEFAULT NULL,
                       X_Asset_Invoice_Id        IN OUT NOCOPY NUMBER,
                       X_Fixed_Assets_Cost              NUMBER DEFAULT NULL,
                       X_Date_Effective                 DATE,
                       X_Date_Ineffective               DATE DEFAULT NULL,
                       X_Invoice_Transaction_Id_In      NUMBER DEFAULT NULL,
                       X_Invoice_Transaction_Id_Out     NUMBER DEFAULT NULL,
                       X_Deleted_Flag                   VARCHAR2,
                       X_Po_Number                      VARCHAR2 DEFAULT NULL,
                       X_Invoice_Number                 VARCHAR2 DEFAULT NULL,
                       X_Payables_Batch_Name            VARCHAR2 DEFAULT NULL,
                       X_Payables_Code_Combination_Id   NUMBER DEFAULT NULL,
                       X_Feeder_System_Name             VARCHAR2 DEFAULT NULL,
                       X_Create_Batch_Date              DATE DEFAULT NULL,
                       X_Create_Batch_Id                NUMBER DEFAULT NULL,
                       X_Invoice_Date                   DATE DEFAULT NULL,
                       X_Payables_Cost                  NUMBER DEFAULT NULL,
                       X_Post_Batch_Id                  NUMBER DEFAULT NULL,
                       X_Invoice_Id                     NUMBER DEFAULT NULL,
                       X_Ap_Distribution_Line_Number    NUMBER DEFAULT NULL,
                       X_Payables_Units                 NUMBER DEFAULT NULL,
                       X_Split_Merged_Code              VARCHAR2 DEFAULT NULL,
                       X_Description                    VARCHAR2 DEFAULT NULL,
                       X_Parent_Mass_Addition_Id        VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category_Code        VARCHAR2 DEFAULT NULL,
                       X_Unrevalued_Cost                NUMBER DEFAULT NULL,
                       X_Merged_Code                    VARCHAR2 DEFAULT NULL,
                       X_Split_Code                     VARCHAR2 DEFAULT NULL,
                       X_Merge_Parent_Mass_Add_Id       NUMBER DEFAULT NULL,
                       X_Split_Parent_Mass_Add_Id       NUMBER DEFAULT NULL,
                       X_Project_Asset_Line_Id          NUMBER DEFAULT NULL,
                       X_Project_Id                     NUMBER DEFAULT NULL,
                       X_Task_Id                        NUMBER DEFAULT NULL,
                       X_Material_Indicator_Flag        VARCHAR2 DEFAULT NULL,
                       X_source_line_id          IN OUT NOCOPY NUMBER,
                       X_prior_source_line_id           NUMBER DEFAULT NULL,
                       X_depreciate_in_group_flag       VARCHAR2 DEFAULT NULL,
                       X_invoice_distribution_id        NUMBER DEFAULT NULL,
                       X_invoice_line_number            NUMBER DEFAULT NULL,
                       X_po_distribution_id             NUMBER DEFAULT NULL,
                       X_exchange_rate                  NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER,
                       X_Calling_Fn                     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C_ai IS SELECT rowid FROM fa_asset_invoices
                 WHERE source_line_id = X_source_line_id;

    CURSOR C_ai_mc IS SELECT rowid FROM fa_mc_asset_invoices
                 WHERE source_line_id = X_source_line_id
                   AND set_of_books_id = X_set_of_books_id;

    CURSOR C2 IS SELECT fa_mass_additions_s.nextval FROM sys.dual;

    CURSOR C3 is select FA_ASSET_INVOICES_S.NEXTVAL from sys.dual;

   BEGIN

      if (X_mrc_sob_type_code = 'R') then

         INSERT INTO fa_mc_asset_invoices(
              set_of_books_id,
              asset_id,
              po_vendor_id,
              asset_invoice_id,
              fixed_assets_cost,
              date_effective,
              date_ineffective,
              invoice_transaction_id_in,
              invoice_transaction_id_out,
              deleted_flag,
              po_number,
              invoice_number,
              payables_batch_name,
              payables_code_combination_id,
              feeder_system_name,
              create_batch_date,
              create_batch_id,
              invoice_date,
              payables_cost,
              post_batch_id,
              invoice_id,
              ap_distribution_line_number,
              payables_units,
              split_merged_code,
              description,
              parent_mass_addition_id,
              last_update_date,
              last_updated_by,
              created_by,
              creation_date,
              last_update_login,
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
              unrevalued_cost,
              merged_code,
              split_code,
              merge_parent_mass_additions_id,
              split_parent_mass_additions_id,
              project_asset_line_id,
              project_id,
              task_id,
              source_line_id,
              prior_source_line_id,
              depreciate_in_group_flag,
              material_indicator_flag,
              invoice_distribution_id,
              invoice_line_number,
              po_distribution_id,
              exchange_rate
             ) VALUES (
              X_set_of_books_id,
              X_Asset_Id,
              X_Po_Vendor_Id,
              X_Asset_Invoice_Id,
              X_Fixed_Assets_Cost,
              X_Date_Effective,
              X_Date_Ineffective,
              X_Invoice_Transaction_Id_In,
              X_Invoice_Transaction_Id_Out,
              X_Deleted_Flag,
              X_Po_Number,
              X_Invoice_Number,
              X_Payables_Batch_Name,
              X_Payables_Code_Combination_Id,
              X_Feeder_System_Name,
              X_Create_Batch_Date,
              X_Create_Batch_Id,
              X_Invoice_Date,
              X_Payables_Cost,
              X_Post_Batch_Id,
              X_Invoice_Id,
              X_Ap_Distribution_Line_Number,
              X_Payables_Units,
              X_Split_Merged_Code,
              X_Description,
              X_Parent_Mass_Addition_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Created_By,
              X_Creation_Date,
              X_Last_Update_Login,
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
              X_Attribute_Category_Code,
              X_Unrevalued_Cost,
              X_Merged_Code,
              X_Split_Code,
              X_Merge_Parent_Mass_Add_Id,
              X_Split_Parent_Mass_Add_Id,
              X_Project_Asset_Line_Id,
              X_Project_Id,
              X_Task_Id,
              X_source_line_id,
              X_prior_source_line_id,
              X_depreciate_in_group_flag,
              X_material_indicator_flag,
              X_invoice_distribution_id,
              X_invoice_line_number,
              X_po_distribution_id,
              X_exchange_rate
             );

          OPEN C_ai_mc;
          FETCH C_ai_mc INTO X_Rowid;
          if (C_ai_mc%NOTFOUND) then
             CLOSE C_ai_mc;
             Raise NO_DATA_FOUND;
          end if;
          CLOSE C_ai_mc;


      else

         if (X_Asset_Invoice_Id is NULL) then
           OPEN C2;
           FETCH C2 INTO X_Asset_Invoice_Id;
           CLOSE C2;
         end if;

         if (X_Source_Line_Id is NULL) then
            OPEN C3;
            FETCH C3 INTO X_Source_Line_Id;
            CLOSE C3;
         end if;


         INSERT INTO fa_asset_invoices(
              asset_id,
              po_vendor_id,
              asset_invoice_id,
              fixed_assets_cost,
              date_effective,
              date_ineffective,
              invoice_transaction_id_in,
              invoice_transaction_id_out,
              deleted_flag,
              po_number,
              invoice_number,
              payables_batch_name,
              payables_code_combination_id,
              feeder_system_name,
              create_batch_date,
              create_batch_id,
              invoice_date,
              payables_cost,
              post_batch_id,
              invoice_id,
              ap_distribution_line_number,
              payables_units,
              split_merged_code,
              description,
              parent_mass_addition_id,
              last_update_date,
              last_updated_by,
              created_by,
              creation_date,
              last_update_login,
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
              unrevalued_cost,
              merged_code,
              split_code,
              merge_parent_mass_additions_id,
              split_parent_mass_additions_id,
              project_asset_line_id,
              project_id,
              task_id,
              source_line_id,
              prior_source_line_id,
              depreciate_in_group_flag,
              material_indicator_flag,
              invoice_distribution_id,
              invoice_line_number,
              po_distribution_id
             ) VALUES (
              X_Asset_Id,
              X_Po_Vendor_Id,
              X_Asset_Invoice_Id,
              X_Fixed_Assets_Cost,
              X_Date_Effective,
              X_Date_Ineffective,
              X_Invoice_Transaction_Id_In,
              X_Invoice_Transaction_Id_Out,
              X_Deleted_Flag,
              X_Po_Number,
              X_Invoice_Number,
              X_Payables_Batch_Name,
              X_Payables_Code_Combination_Id,
              X_Feeder_System_Name,
              X_Create_Batch_Date,
              X_Create_Batch_Id,
              X_Invoice_Date,
              X_Payables_Cost,
              X_Post_Batch_Id,
              X_Invoice_Id,
              X_Ap_Distribution_Line_Number,
              X_Payables_Units,
              X_Split_Merged_Code,
              X_Description,
              X_Parent_Mass_Addition_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Created_By,
              X_Creation_Date,
              X_Last_Update_Login,
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
              X_Attribute_Category_Code,
              X_Unrevalued_Cost,
              X_Merged_Code,
              X_Split_Code,
              X_Merge_Parent_Mass_Add_Id,
              X_Split_Parent_Mass_Add_Id,
              X_Project_Asset_Line_Id,
              X_Project_Id,
              X_Task_Id,
              X_source_line_id,
              X_prior_source_line_id,
              X_depreciate_in_group_flag,
              X_material_indicator_flag,
              X_invoice_distribution_id,
              X_invoice_line_number,
              X_po_distribution_id
             );

          OPEN C_ai;
          FETCH C_ai INTO X_Rowid;
          if (C_ai%NOTFOUND) then
             CLOSE C_ai;
             Raise NO_DATA_FOUND;
          end if;
          CLOSE C_ai;

      end if;

  exception
    when others then
         FA_SRVR_MSG.Add_SQL_Error(Calling_fn =>
                         'fa_asset_invoices_pkg.insert_row', p_log_level_rec => p_log_level_rec);
         raise;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Asset_Id                         NUMBER,
                     X_Po_Vendor_Id                     NUMBER DEFAULT NULL,
                     X_Asset_Invoice_Id                 NUMBER DEFAULT NULL,
                     X_Fixed_Assets_Cost                NUMBER DEFAULT NULL,
                     X_Date_Effective                   DATE,
                     X_Date_Ineffective                 DATE DEFAULT NULL,
                     X_Invoice_Transaction_Id_In        NUMBER DEFAULT NULL,
                     X_Invoice_Transaction_Id_Out       NUMBER DEFAULT NULL,
                     X_Deleted_Flag                     VARCHAR2,
                     X_Po_Number                        VARCHAR2 DEFAULT NULL,
                     X_Invoice_Number                   VARCHAR2 DEFAULT NULL,
                     X_Payables_Batch_Name              VARCHAR2 DEFAULT NULL,
                     X_Payables_Code_Combination_Id     NUMBER DEFAULT NULL,
                     X_Feeder_System_Name               VARCHAR2 DEFAULT NULL,
                     X_Create_Batch_Date                DATE DEFAULT NULL,
                     X_Create_Batch_Id                  NUMBER DEFAULT NULL,
                     X_Invoice_Date                     DATE DEFAULT NULL,
                     X_Payables_Cost                    NUMBER DEFAULT NULL,
                     X_Post_Batch_Id                    NUMBER DEFAULT NULL,
                     X_Invoice_Id                       NUMBER DEFAULT NULL,
                     X_Ap_Distribution_Line_Number      NUMBER DEFAULT NULL,
                     X_Payables_Units                   NUMBER DEFAULT NULL,
                     X_Split_Merged_Code                VARCHAR2 DEFAULT NULL,
                     X_Description                      VARCHAR2 DEFAULT NULL,
                     X_Parent_Mass_Addition_Id          VARCHAR2 DEFAULT NULL,
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
                     X_Unrevalued_Cost                  NUMBER DEFAULT NULL,
                     X_Merged_Code                      VARCHAR2 DEFAULT NULL,
                     X_Split_Code                       VARCHAR2 DEFAULT NULL,
                     X_Merge_Parent_Mass_Add_Id         NUMBER DEFAULT NULL,
                     X_Split_Parent_Mass_Add_Id         NUMBER DEFAULT NULL,
                     X_Project_Asset_Line_Id            NUMBER DEFAULT NULL,
                     X_Project_Id                       NUMBER DEFAULT NULL,
                     X_Task_Id                          NUMBER DEFAULT NULL,
                     X_Calling_Fn                       VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT     asset_id,
          po_vendor_id,
          asset_invoice_id,
          fixed_assets_cost,
          date_effective,
          date_ineffective,
          invoice_transaction_id_in,
          invoice_transaction_id_out,
          deleted_flag,
          po_number,
          invoice_number,
          payables_batch_name,
          payables_code_combination_id,
          feeder_system_name,
          create_batch_date,
          create_batch_id,
          invoice_date,
          payables_cost,
          post_batch_id,
          invoice_id,
          ap_distribution_line_number,
          payables_units,
          split_merged_code,
          description,
          parent_mass_addition_id,
          last_update_date,
          last_updated_by,
          created_by,
          creation_date,
          last_update_login,
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
          unrevalued_cost,
          merged_code,
          split_code,
          merge_parent_mass_additions_id,
          split_parent_mass_additions_id,
          project_asset_line_id,
          project_id,
          task_id
        FROM   fa_asset_invoices
        WHERE  rowid = X_Rowid
        FOR UPDATE of Asset_Invoice_Id NOWAIT;
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
    if (

               (Recinfo.asset_id =  X_Asset_Id)
           AND (   (Recinfo.po_vendor_id =  X_Po_Vendor_Id)
                OR (    (Recinfo.po_vendor_id IS NULL)
                    AND (X_Po_Vendor_Id IS NULL)))
           AND (   (Recinfo.asset_invoice_id =  X_Asset_Invoice_Id)
                OR (    (Recinfo.asset_invoice_id IS NULL)
                    AND (X_Asset_Invoice_Id IS NULL)))
           AND (   (Recinfo.fixed_assets_cost =  X_Fixed_Assets_Cost)
                OR (    (Recinfo.fixed_assets_cost IS NULL)
                    AND (X_Fixed_Assets_Cost IS NULL)))
           AND (Recinfo.date_effective =  X_Date_Effective)
           AND (   (Recinfo.date_ineffective =  X_Date_Ineffective)
                OR (    (Recinfo.date_ineffective IS NULL)
                    AND (X_Date_Ineffective IS NULL)))
           AND (   (Recinfo.invoice_transaction_id_in =
                         X_Invoice_Transaction_Id_In)
                OR (    (Recinfo.invoice_transaction_id_in IS NULL)
                    AND (X_Invoice_Transaction_Id_In IS NULL)))
           AND (   (Recinfo.invoice_transaction_id_out =
                              X_Invoice_Transaction_Id_Out)
                OR (    (Recinfo.invoice_transaction_id_out IS NULL)
                    AND (X_Invoice_Transaction_Id_Out IS NULL)))
           AND (Recinfo.deleted_flag =  X_Deleted_Flag)
           AND (   (Recinfo.po_number =  X_Po_Number)
                OR (    (Recinfo.po_number IS NULL)
                    AND (X_Po_Number IS NULL)))
           AND (   (Recinfo.invoice_number =  X_Invoice_Number)
                OR (    (Recinfo.invoice_number IS NULL)
                    AND (X_Invoice_Number IS NULL)))
           AND (   (Recinfo.payables_batch_name =  X_Payables_Batch_Name)
                OR (    (Recinfo.payables_batch_name IS NULL)
                    AND (X_Payables_Batch_Name IS NULL)))
           AND (   (Recinfo.payables_code_combination_id =
                         X_Payables_Code_Combination_Id)
                OR (    (Recinfo.payables_code_combination_id IS NULL)
                    AND (X_Payables_Code_Combination_Id IS NULL)))
           AND (   (Recinfo.feeder_system_name =  X_Feeder_System_Name)
                OR (    (Recinfo.feeder_system_name IS NULL)
                    AND (X_Feeder_System_Name IS NULL)))
           AND (   (Recinfo.create_batch_date =  X_Create_Batch_Date)
                OR (    (Recinfo.create_batch_date IS NULL)
                    AND (X_Create_Batch_Date IS NULL)))
           AND (   (Recinfo.create_batch_id =  X_Create_Batch_Id)
                OR (    (Recinfo.create_batch_id IS NULL)
                    AND (X_Create_Batch_Id IS NULL)))
           AND (   (Recinfo.invoice_date =  X_Invoice_Date)
                OR (    (Recinfo.invoice_date IS NULL)
                    AND (X_Invoice_Date IS NULL)))
           AND (   (Recinfo.payables_cost =  X_Payables_Cost)
                OR (    (Recinfo.payables_cost IS NULL)
                    AND (X_Payables_Cost IS NULL)))
           AND (   (Recinfo.post_batch_id =  X_Post_Batch_Id)
                OR (    (Recinfo.post_batch_id IS NULL)
                    AND (X_Post_Batch_Id IS NULL)))
           AND (   (Recinfo.invoice_id =  X_Invoice_Id)
                OR (    (Recinfo.invoice_id IS NULL)
                    AND (X_Invoice_Id IS NULL)))
           AND (   (Recinfo.ap_distribution_line_number =
                              X_Ap_Distribution_Line_Number)
                OR (    (Recinfo.ap_distribution_line_number IS NULL)
                    AND (X_Ap_Distribution_Line_Number IS NULL)))
           AND (   (Recinfo.payables_units =  X_Payables_Units)
                OR (    (Recinfo.payables_units IS NULL)
                    AND (X_Payables_Units IS NULL)))
           AND (   (Recinfo.split_merged_code =  X_Split_Merged_Code)
                OR (    (Recinfo.split_merged_code IS NULL)
                    AND (X_Split_Merged_Code IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.parent_mass_addition_id =
                         X_Parent_Mass_Addition_Id)
                OR (    (Recinfo.parent_mass_addition_id IS NULL)
                    AND (X_Parent_Mass_Addition_Id IS NULL)))
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
           AND (   (Recinfo.attribute_category_code =
                         X_Attribute_Category_Code)
                OR (    (Recinfo.attribute_category_code IS NULL)
                    AND (X_Attribute_Category_Code IS NULL)))
           AND (   (Recinfo.unrevalued_cost =  X_Unrevalued_Cost)
                OR (    (Recinfo.unrevalued_cost IS NULL)
                    AND (X_Unrevalued_Cost IS NULL)))
           AND (   (Recinfo.merged_code =  X_Merged_Code)
                OR (    (Recinfo.merged_code IS NULL)
                    AND (X_Merged_Code IS NULL)))
           AND (   (Recinfo.split_code =  X_Split_Code)
                OR (    (Recinfo.split_code IS NULL)
                    AND (X_Split_Code IS NULL)))
           AND (   (Recinfo.merge_parent_mass_additions_id =
                    X_Merge_Parent_Mass_Add_Id)
                OR (    (Recinfo.merge_parent_mass_additions_id IS NULL)
                    AND (X_Merge_Parent_Mass_Add_Id IS NULL)))
           AND (   (Recinfo.split_parent_mass_additions_id =
                         X_Split_Parent_Mass_Add_Id)
                OR (    (Recinfo.split_parent_mass_additions_id IS NULL)
                    AND (X_Split_Parent_Mass_Add_Id IS NULL)))
           AND (   (Recinfo.project_asset_line_id =
                                        X_Project_Asset_Line_Id)
                OR (    (Recinfo.project_asset_line_id IS NULL)
                    AND (X_Project_Asset_Line_Id IS NULL)))
           AND (   (Recinfo.project_id =
                                        X_Project_Id)
                OR (    (Recinfo.project_id IS NULL)
                    AND (X_Project_Id IS NULL)))
           AND (   (Recinfo.Task_Id =
                                        X_Task_Id)
                OR (    (Recinfo.Task_Id IS NULL)
                    AND (X_Task_Id IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2 DEFAULT NULL,
                       X_Source_Line_Id                 NUMBER   DEFAULT NULL,
                       X_Asset_Id                       NUMBER   DEFAULT NULL,
                       X_Po_Vendor_Id                   NUMBER   DEFAULT NULL,
                       X_Asset_Invoice_Id               NUMBER   DEFAULT NULL,
                       X_Fixed_Assets_Cost              NUMBER   DEFAULT NULL,
                       X_Date_Effective                 DATE     DEFAULT NULL,
                       X_Date_Ineffective               DATE     DEFAULT NULL,
                       X_Invoice_Transaction_Id_In      NUMBER   DEFAULT NULL,
                       X_Invoice_Transaction_Id_Out     NUMBER   DEFAULT NULL,
                       X_Deleted_Flag                   VARCHAR2 DEFAULT NULL,
                       X_Po_Number                      VARCHAR2 DEFAULT NULL,
                       X_Invoice_Number                 VARCHAR2 DEFAULT NULL,
                       X_Payables_Batch_Name            VARCHAR2 DEFAULT NULL,
                       X_Payables_Code_Combination_Id   NUMBER   DEFAULT NULL,
                       X_Feeder_System_Name             VARCHAR2 DEFAULT NULL,
                       X_Create_Batch_Date              DATE     DEFAULT NULL,
                       X_Create_Batch_Id                NUMBER   DEFAULT NULL,
                       X_Invoice_Date                   DATE     DEFAULT NULL,
                       X_Payables_Cost                  NUMBER   DEFAULT NULL,
                       X_Post_Batch_Id                  NUMBER   DEFAULT NULL,
                       X_Invoice_Id                     NUMBER   DEFAULT NULL,
                       X_Ap_Distribution_Line_Number    NUMBER   DEFAULT NULL,
                       X_Payables_Units                 NUMBER   DEFAULT NULL,
                       X_Split_Merged_Code              VARCHAR2 DEFAULT NULL,
                       X_Description                    VARCHAR2 DEFAULT NULL,
                       X_Parent_Mass_Addition_Id        VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Date               DATE     DEFAULT NULL,
                       X_Last_Updated_By                NUMBER   DEFAULT NULL,
                       X_Last_Update_Login              NUMBER   DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category_Code        VARCHAR2 DEFAULT NULL,
                       X_Unrevalued_Cost                NUMBER   DEFAULT NULL,
                       X_Merged_Code                    VARCHAR2 DEFAULT NULL,
                       X_Split_Code                     VARCHAR2 DEFAULT NULL,
                       X_Merge_Parent_Mass_Add_Id       NUMBER   DEFAULT NULL,
                       X_Split_Parent_Mass_Add_Id       NUMBER   DEFAULT NULL,
                       X_Project_Asset_Line_Id          NUMBER   DEFAULT NULL,
                       X_Project_Id                     NUMBER   DEFAULT NULL,
                       X_Task_Id                        NUMBER   DEFAULT NULL,
                       X_Material_Indicator_Flag        VARCHAR2 DEFAULT NULL,
                       X_depreciate_in_group_flag       VARCHAR2 DEFAULT NULL,
                       X_invoice_distribution_id        NUMBER   DEFAULT NULL,
                       X_invoice_line_number            NUMBER   DEFAULT NULL,
                       X_po_distribution_id             NUMBER   DEFAULT NULL,
                       X_exchange_rate                  NUMBER   DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER   ,
                       X_Calling_Fn                     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

      l_rowid         ROWID;

   BEGIN

      if (X_mrc_sob_type_code = 'R') then

         if (X_Rowid is NULL) then
            select rowid
            into   l_rowid
            from   fa_mc_asset_invoices
            where  source_line_id = X_Source_Line_Id
            and    set_of_books_id = X_set_of_books_id;
         else
            l_rowid := X_Rowid;
         end if;

         UPDATE fa_mc_asset_invoices
         SET
            asset_id                 = decode(X_Asset_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       asset_id,
                                              X_asset_id),
            po_vendor_id             = decode(X_Po_Vendor_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       po_vendor_id,
                                              X_po_vendor_id),
            asset_invoice_id         = decode(X_Asset_Invoice_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       asset_invoice_id,
                                              X_asset_invoice_id),
            fixed_assets_cost        = decode(X_Fixed_Assets_Cost,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       fixed_assets_cost,
                                              X_fixed_assets_cost),
            date_effective           = decode(X_Date_Effective,
                                              NULL,       date_effective,
                                              X_date_effective),
            date_ineffective         = decode(X_Date_Ineffective,
                                              NULL,       date_ineffective,
                                              X_date_ineffective),
            invoice_transaction_id_in
                                     = decode(X_Invoice_Transaction_Id_In,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL, invoice_transaction_id_in,
                                              X_invoice_transaction_id_in),
            invoice_transaction_id_out
                                     = decode(X_Invoice_Transaction_Id_Out,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL, invoice_transaction_id_out,
                                              X_invoice_transaction_id_out),
            deleted_flag             = decode(X_Deleted_Flag,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       deleted_flag,
                                              X_deleted_flag),
            po_number                = decode(X_Po_Number,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       po_number,
                                              X_po_number),
            invoice_number           = decode(X_Invoice_Number,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       invoice_number,
                                                        X_invoice_number),
            payables_batch_name      = decode(X_Payables_Batch_Name,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       payables_batch_name,
                                              X_payables_batch_name),
            payables_code_combination_id
                                     = decode(X_Payables_Code_Combination_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,
                                                 payables_code_combination_id,
                                              X_payables_code_combination_id),
            feeder_system_name       = decode(X_Feeder_System_Name,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       feeder_system_name,
                                              X_feeder_system_name),
            create_batch_date        = decode(X_Create_Batch_Date,
                                              NULL,       create_batch_date,
                                              X_create_batch_date),
            create_batch_id          = decode(X_Create_Batch_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       create_batch_id,
                                              X_create_batch_id),
            invoice_date             = decode(X_Invoice_Date,
                                              NULL,       invoice_date,
                                              X_invoice_date),
            payables_cost            = decode(X_Payables_Cost,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       payables_cost,
                                              X_payables_cost),
            post_batch_id            = decode(X_Post_Batch_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       post_batch_id,
                                              X_post_batch_id),
            invoice_id               = decode(X_Invoice_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       invoice_id,
                                                        X_invoice_id),
            ap_distribution_line_number
                                     = decode(X_Ap_Distribution_Line_Number,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL, ap_distribution_line_number,
                                              X_ap_distribution_line_number),
            payables_units           = decode(X_Payables_Units,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       payables_units,
                                              X_payables_units),
            split_merged_code        = decode(X_Split_Merged_Code,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       split_merged_code,
                                              X_split_merged_code),
            description              = decode(X_Description,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       description,
                                              X_description),
            parent_mass_addition_id  = decode(X_Parent_Mass_Addition_Id,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL, parent_mass_addition_id,
                                              X_parent_mass_addition_id),
            last_update_date         = decode(X_Last_Update_Date,
                                              NULL,       last_update_date,
                                              X_last_update_date),
            last_updated_by          = decode(X_Last_Updated_By,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       last_updated_by,
                                              X_last_updated_by),
            last_update_login        = decode(X_Last_Update_Login,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       last_update_login,
                                              X_last_update_login),
            attribute1               = decode(X_Attribute1,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute1,
                                              X_attribute1),
            attribute2               = decode(X_Attribute2,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute2,
                                              X_attribute2),
            attribute3               = decode(X_Attribute3,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute3,
                                              X_attribute3),
            attribute4               = decode(X_Attribute4,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute4,
                                              X_attribute4),
            attribute5               = decode(X_Attribute5,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute5,
                                              X_attribute5),
            attribute6               = decode(X_Attribute6,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute6,
                                              X_attribute6),
            attribute7               = decode(X_Attribute7,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute7,
                                              X_attribute7),
            attribute8               = decode(X_Attribute8,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute8,
                                              X_attribute8),
            attribute9               = decode(X_Attribute9,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute9,
                                              X_attribute9),
            attribute10              = decode(X_Attribute10,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute10,
                                              X_attribute10),
            attribute11              = decode(X_Attribute11,
                                             FND_API.G_MISS_CHAR, NULL,
                                             NULL,       attribute11,
                                             X_attribute11),
            attribute12              = decode(X_Attribute12,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute12,
                                              X_attribute12),
            attribute13              = decode(X_Attribute13,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute13,
                                              X_attribute13),
            attribute14              = decode(X_Attribute14,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute14,
                                              X_attribute14),
            attribute15              = decode(X_attribute15,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL, attribute15,
                                              X_attribute15),
            attribute_category_code  = decode(X_Attribute_Category_Code,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL, attribute_category_code,
                                              X_attribute_category_code),
            unrevalued_cost          = decode(X_Unrevalued_Cost,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       unrevalued_cost,
                                              X_unrevalued_cost),
            merged_code              = decode(X_Merged_Code,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       merged_code,
                                              X_merged_code),
            split_code               = decode(X_Split_Code,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       split_code,
                                              X_split_code),
            merge_parent_mass_additions_id
                                     = decode(X_Merge_Parent_Mass_Add_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,
                                                 merge_parent_mass_additions_id,
                                              X_merge_parent_mass_add_id),
            split_parent_mass_additions_id
                                     = decode(X_Split_Parent_Mass_Add_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,
                                                 split_parent_mass_additions_id,
                                              X_split_parent_mass_add_id),
            project_asset_line_id    = decode(X_Project_Asset_Line_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL, project_asset_line_id,
                                              X_project_asset_line_id),
            project_id               = decode(X_Project_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       project_id,
                                              X_project_id),
            task_id                  = decode(X_Task_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       task_id,
                                              X_task_id),
            exchange_rate            = decode(X_Exchange_Rate,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       exchange_rate,
                                              X_exchange_rate),
            depreciate_in_group_flag = decode(X_depreciate_in_group_flag,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       depreciate_in_group_flag,
                                              X_depreciate_in_group_flag),
            material_indicator_flag  = decode(X_material_indicator_flag,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       material_indicator_flag,
                                              X_material_indicator_flag),
            invoice_distribution_id  = decode(X_invoice_distribution_id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL, invoice_distribution_id,
                                              X_invoice_distribution_id),
            invoice_line_number      = decode(X_invoice_line_number,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       invoice_line_number,
                                              X_invoice_line_number),
            po_distribution_id       = decode(X_po_distribution_id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       po_distribution_id,
                                              X_po_distribution_id)
         WHERE rowid = l_rowid;

       if (SQL%NOTFOUND) then
         Raise NO_DATA_FOUND;
       end if;

    else

       if (X_Rowid is NULL) then
          select rowid
            into   l_rowid
            from   fa_asset_invoices
           where  source_line_id = X_Source_Line_Id;
       else
          l_rowid := X_Rowid;
       end if;

       UPDATE fa_asset_invoices
       SET  asset_id                 = decode(X_Asset_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       asset_id,
                                              X_asset_id),
            po_vendor_id             = decode(X_Po_Vendor_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       po_vendor_id,
                                              X_po_vendor_id),
            asset_invoice_id         = decode(X_Asset_Invoice_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       asset_invoice_id,
                                              X_asset_invoice_id),
            fixed_assets_cost        = decode(X_Fixed_Assets_Cost,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       fixed_assets_cost,
                                              X_fixed_assets_cost),
            date_effective           = decode(X_Date_Effective,
                                              NULL,       date_effective,
                                              X_date_effective),
            date_ineffective         = decode(X_Date_Ineffective,
                                              NULL,       date_ineffective,
                                              X_date_ineffective),
            invoice_transaction_id_in
                                     = decode(X_Invoice_Transaction_Id_In,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL, invoice_transaction_id_in,
                                              X_invoice_transaction_id_in),
            invoice_transaction_id_out
                                     = decode(X_Invoice_Transaction_Id_Out,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL, invoice_transaction_id_out,
                                              X_invoice_transaction_id_out),
            deleted_flag             = decode(X_Deleted_Flag,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       deleted_flag,
                                              X_deleted_flag),
            po_number                = decode(X_Po_Number,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       po_number,
                                              X_po_number),
            invoice_number           = decode(X_Invoice_Number,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       invoice_number,
                                              X_invoice_number),
            payables_batch_name      = decode(X_Payables_Batch_Name,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       payables_batch_name,
                                              X_payables_batch_name),
            payables_code_combination_id
                                     = decode(X_Payables_Code_Combination_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,
                                                 payables_code_combination_id,
                                              X_payables_code_combination_id),
            feeder_system_name       = decode(X_Feeder_System_Name,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL, feeder_system_name,
                                              X_feeder_system_name),
            create_batch_date        = decode(X_Create_Batch_Date,
                                              NULL,       create_batch_date,
                                              X_create_batch_date),
            create_batch_id          = decode(X_Create_Batch_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       create_batch_id,
                                              X_create_batch_id),
            invoice_date             = decode(X_Invoice_Date,
                                              NULL,       invoice_date,
                                              X_invoice_date),
            payables_cost            = decode(X_Payables_Cost,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       payables_cost,
                                              X_payables_cost),
            post_batch_id            = decode(X_Post_Batch_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       post_batch_id,
                                              X_post_batch_id),
            invoice_id               = decode(X_Invoice_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       invoice_id,
                                              X_invoice_id),
            ap_distribution_line_number
                                     = decode(X_Ap_Distribution_Line_Number,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL, ap_distribution_line_number,
                                              X_ap_distribution_line_number),
            payables_units           = decode(X_Payables_Units,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL, payables_units,
                                              X_payables_units),
            split_merged_code        = decode(X_Split_Merged_Code,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       split_merged_code,
                                              X_split_merged_code),
            description              = decode(X_Description,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       description,
                                              X_description),
            parent_mass_addition_id  = decode(X_Parent_Mass_Addition_Id,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL, parent_mass_addition_id,
                                              X_parent_mass_addition_id),
            last_update_date         = decode(X_Last_Update_Date,
                                              NULL,       last_update_date,
                                              X_last_update_date),
            last_updated_by          = decode(X_Last_Updated_By,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       last_updated_by,
                                              X_last_updated_by),
            last_update_login        = decode(X_Last_Update_Login,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       last_update_login,
                                              X_last_update_login),
            attribute1               = decode(X_Attribute1,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute1,
                                              X_attribute1),
            attribute2               = decode(X_Attribute2,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute2,
                                              X_attribute2),
            attribute3               = decode(X_Attribute3,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute3,
                                              X_attribute3),
            attribute4               = decode(X_Attribute4,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute4,
                                              X_attribute4),
            attribute5               = decode(X_Attribute5,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute5,
                                              X_attribute5),
            attribute6               = decode(X_Attribute6,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute6,
                                              X_attribute6),
            attribute7               = decode(X_Attribute7,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute7,
                                              X_attribute7),
            attribute8               = decode(X_Attribute8,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute8,
                                              X_attribute8),
            attribute9               = decode(X_Attribute9,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute9,
                                              X_attribute9),
            attribute10              = decode(X_Attribute10,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute10,
                                              X_attribute10),
            attribute11              = decode(X_Attribute11,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute11,
                                              X_attribute11),
            attribute12              = decode(X_Attribute12,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute12,
                                              X_attribute12),
            attribute13              = decode(X_Attribute13,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute13,
                                              X_attribute13),
            attribute14              = decode(X_Attribute14,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       attribute14,
                                              X_attribute14),
            attribute15              = decode(X_attribute15,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL, attribute15,
                                              X_attribute15),
            attribute_category_code  = decode(X_Attribute_Category_Code,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL, attribute_category_code,
                                              X_attribute_category_code),
            unrevalued_cost          = decode(X_Unrevalued_Cost,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       unrevalued_cost,
                                              X_unrevalued_cost),
            merged_code              = decode(X_Merged_Code,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       merged_code,
                                              X_merged_code),
            split_code               = decode(X_Split_Code,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       split_code,
                                              X_split_code),
            merge_parent_mass_additions_id
                                     = decode(X_Merge_Parent_Mass_Add_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,
                                                 merge_parent_mass_additions_id,
                                              X_merge_parent_mass_add_id),
            split_parent_mass_additions_id
                                     = decode(X_Split_Parent_Mass_Add_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,
                                                 split_parent_mass_additions_id,
                                              X_split_parent_mass_add_id),
            project_asset_line_id    = decode(X_Project_Asset_Line_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       project_asset_line_id,
                                              X_project_asset_line_id),
            project_id               = decode(X_Project_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       project_id,
                                              X_project_id),
            task_id                  = decode(X_Task_Id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       task_id,
                                              X_task_id),
            depreciate_in_group_flag = decode(X_depreciate_in_group_flag,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       depreciate_in_group_flag,
                                              X_depreciate_in_group_flag),
            material_indicator_flag  = decode(X_material_indicator_flag,
                                              FND_API.G_MISS_CHAR, NULL,
                                              NULL,       material_indicator_flag,
                                              X_material_indicator_flag),
            invoice_distribution_id  = decode(X_invoice_distribution_id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL, invoice_distribution_id,
                                              X_invoice_distribution_id),
            invoice_line_number      = decode(X_invoice_line_number,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       invoice_line_number,
                                              X_invoice_line_number),
            po_distribution_id       = decode(X_po_distribution_id,
                                              FND_API.G_MISS_NUM, NULL,
                                              NULL,       po_distribution_id,
                                              X_po_distribution_id)
         WHERE rowid = l_rowid;

     if (SQL%NOTFOUND) then
       Raise NO_DATA_FOUND;
     end if;
  end if;


  exception
    when others then
         FA_SRVR_MSG.Add_SQL_Error(Calling_fn =>
                         'fa_asset_invoices_pkg.update_row', p_log_level_rec => p_log_level_rec);
         raise;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid              VARCHAR2 DEFAULT NULL,
                       X_Asset_Id           NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code  VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id    NUMBER ,
                       X_Calling_Fn         VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

   BEGIN

      if (X_mrc_sob_type_code = 'R') then
         if X_Rowid is not null then
            DELETE FROM fa_mc_asset_invoices
            WHERE rowid = X_Rowid;
         elsif X_Asset_Id is not null then
            DELETE FROM fa_mc_asset_invoices
            WHERE asset_id = X_Asset_Id
            AND set_of_books_id = X_set_of_books_id;
         else
            -- error message here
            null;
         end if;
      else
         if X_Rowid is not null then
            DELETE FROM fa_asset_invoices
            WHERE rowid = X_Rowid;
         elsif X_Asset_Id is not null then
            DELETE FROM fa_asset_invoices
            WHERE asset_id = X_Asset_Id;
         else
            -- error message here
            null;
         end if;
      end if;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  exception
    when no_data_found then
         null;
    when others then
         fa_srvr_msg.add_sql_error(
                  CALLING_FN => 'fa_asset_invoices_pkg.delete_row', p_log_level_rec => p_log_level_rec);
         raise;
  END Delete_Row;

END FA_ASSET_INVOICES_PKG;

/
