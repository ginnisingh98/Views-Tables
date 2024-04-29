--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_ASSETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_ASSETS_PKG" as
/* $Header: PAXASSTB.pls 120.2 2005/08/10 14:16:47 dlanka noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Project_Asset_Id               IN OUT NOCOPY NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Asset_Number                   VARCHAR2,
                       X_Asset_Name                     VARCHAR2,
                       X_Asset_Description              VARCHAR2,
                       X_Location_Id                    NUMBER,
                       X_Assigned_To_Person_Id          NUMBER,
                       X_Date_Placed_In_Service         DATE,
                       X_Asset_Category_Id              NUMBER,
		       X_Asset_key_ccid	            NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Units                    NUMBER,
                       X_Depreciate_Flag                VARCHAR2,
                       X_Amortize_Flag                 VARCHAR2,
                       X_Cost_Adjustment_Flag          VARCHAR2,
			X_Reverse_Flag			VARCHAR2,
                       X_Depreciation_Expense_Ccid      NUMBER,
                       X_Capitalized_Flag               VARCHAR2,
                       X_Estimated_In_Service_Date      DATE,
                       X_Capitalized_Cost               NUMBER,
                       X_Grouped_Cip_Cost               NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
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
                       --PA.L
                       X_Project_Asset_Type             VARCHAR2,
                       X_Estimated_Units                NUMBER,
                       X_Parent_Asset_Id                NUMBER,
                       X_Estimated_Cost                 NUMBER,
                       X_Manufacturer_Name              VARCHAR2,
                       X_Model_Number                   VARCHAR2,
                       X_Serial_Number                  VARCHAR2,
                       X_Tag_Number                     VARCHAR2,
                       X_Capital_Hold_Flag              VARCHAR2,
                       X_Ret_Target_Asset_Id            NUMBER,
		       X_Org_Id                         NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM pa_project_assets
                 WHERE project_asset_id = X_Project_Asset_Id;
      CURSOR C2 IS SELECT pa_project_assets_s.nextval FROM sys.dual;
   BEGIN
      if (X_Project_Asset_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Project_Asset_Id;
        CLOSE C2;
      end if;

       INSERT INTO pa_project_assets(
              project_asset_id,
              project_id,
              asset_number,
              asset_name,
              asset_description,
              location_id,
              assigned_to_person_id,
              date_placed_in_service,
              asset_category_id,
	      asset_key_ccid,
              book_type_code,
              asset_units,
              depreciate_flag,
		amortize_flag,
		cost_adjustment_flag,
		reverse_flag,
              depreciation_expense_ccid,
              capitalized_flag,
              estimated_in_service_date,
              capitalized_cost,
              grouped_cip_cost,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
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
	      new_master_flag,
              Project_Asset_Type,
              Estimated_asset_Units ,
              Parent_Asset_Id,
              Estimated_Cost,
              Manufacturer_Name,
              Model_Number,
              Serial_Number,
              Tag_Number,
              Capital_Hold_Flag,
              Ret_Target_Asset_Id,
	      Org_Id
             ) VALUES (

              X_Project_Asset_Id,
              X_Project_Id,
              X_Asset_Number,
              X_Asset_Name,
              X_Asset_Description,
              X_Location_Id,
              X_Assigned_To_Person_Id,
              X_Date_Placed_In_Service,
              X_Asset_Category_Id,
	      X_Asset_key_ccid,
              X_Book_Type_Code,
              X_Asset_Units,
              X_Depreciate_Flag,
		X_Amortize_Flag,
		X_Cost_Adjustment_Flag,
		 X_Reverse_Flag,
              X_Depreciation_Expense_Ccid,
              X_Capitalized_Flag,
              X_Estimated_In_Service_Date,
              X_Capitalized_Cost,
              X_Grouped_Cip_Cost,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
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
	      'N',
              X_Project_Asset_Type,
              X_Estimated_Units,
              X_Parent_Asset_Id,
              X_Estimated_Cost,
              X_Manufacturer_Name,
              X_Model_Number,
              X_Serial_Number,
              X_Tag_Number,
              X_Capital_Hold_Flag,
              X_Ret_Target_Asset_Id,
	      X_Org_Id
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Project_Asset_Id                 NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Asset_Number                     VARCHAR2,
                     X_Asset_Name                       VARCHAR2,
                     X_Asset_Description                VARCHAR2,
                     X_Location_Id                      NUMBER,
                     X_Assigned_To_Person_Id            NUMBER,
                     X_Date_Placed_In_Service           DATE,
                     X_Asset_Category_Id                NUMBER,
		     X_Asset_key_ccid	    	NUMBER,
                     X_Book_Type_Code                   VARCHAR2,
                     X_Asset_Units                      NUMBER,
                     X_Depreciate_Flag                  VARCHAR2,
                        X_Amortize_Flag                 VARCHAR2,
                        X_Cost_Adjustment_Flag          VARCHAR2,
			X_Reverse_Flag			VARCHAR2,
			X_Reversal_Date			DATE,
                     X_Depreciation_Expense_Ccid        NUMBER,
                     X_Capitalized_Flag                 VARCHAR2,
                     X_Estimated_In_Service_Date        DATE,
                     X_Capitalized_Cost                 NUMBER,
                     X_Grouped_Cip_Cost                 NUMBER,
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
                       --PA.L
                     X_Project_Asset_Type             VARCHAR2,
                     X_Estimated_Units                NUMBER,
                     X_Parent_Asset_Id                NUMBER,
                     X_Estimated_Cost                 NUMBER,
                     X_Manufacturer_Name              VARCHAR2,
                     X_Model_Number                   VARCHAR2,
                     X_Serial_Number                  VARCHAR2,
                     X_Tag_Number                     VARCHAR2,
                     X_Capital_Event_ID               NUMBER,
                       X_Capital_Hold_Flag              VARCHAR2,
                       X_Ret_Target_Asset_Id            NUMBER
  ) IS
	CURSOR C IS
	SELECT *
	FROM  pa_project_assets
        WHERE  pa_project_assets.rowid = X_Rowid
        FOR UPDATE of Project_Asset_Id NOWAIT;
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
               (Recinfo.project_asset_id =  X_Project_Asset_Id)
           AND (Recinfo.project_id =  X_Project_Id)
           AND (   (Recinfo.asset_number =  X_Asset_Number)
                OR (    (Recinfo.asset_number IS NULL)
                    AND (X_Asset_Number IS NULL)))
           AND (Recinfo.asset_name =  X_Asset_Name)
           AND (Recinfo.asset_description =  X_Asset_Description)
           AND (   (Recinfo.location_id =  X_Location_Id)
                OR (    (Recinfo.location_id IS NULL)
                    AND (X_Location_Id IS NULL)))
           AND (   (Recinfo.assigned_to_person_id =  X_Assigned_To_Person_Id)
                OR (    (Recinfo.assigned_to_person_id IS NULL)
                    AND (X_Assigned_To_Person_Id IS NULL)))
           AND (  (Recinfo.date_placed_in_service =  X_Date_Placed_In_Service)
                OR (    (Recinfo.date_placed_in_service IS NULL)
                    AND (X_Date_Placed_In_Service IS NULL)))
           AND (   (Recinfo.asset_category_id =  X_Asset_Category_Id)
                OR (    (Recinfo.asset_category_id IS NULL)
                    AND (X_Asset_Category_Id IS NULL)))
           AND (   (Recinfo.asset_key_ccid =  X_Asset_key_ccId)
                OR (    (Recinfo.asset_key_ccid IS NULL)
                    AND (X_Asset_key_ccId IS NULL)))
          AND (   (Recinfo.book_type_code =  X_Book_Type_Code)
                OR (    (Recinfo.book_type_code IS NULL)
                    AND (X_Book_Type_Code IS NULL)))
           AND (   (Recinfo.asset_units =  X_Asset_Units)
                OR (    (Recinfo.asset_units IS NULL)
                    AND (X_Asset_Units IS NULL)))
           AND (   (Recinfo.depreciate_flag =  X_Depreciate_Flag)
                OR (    (Recinfo.depreciate_flag IS NULL)
                    AND (X_Depreciate_Flag IS NULL)))
           AND (   (Recinfo.amortize_flag =  X_Amortize_Flag)
                OR (    (Recinfo.amortize_flag IS NULL)
                    AND (X_Amortize_Flag IS NULL)))
           AND (   (Recinfo.cost_adjustment_flag =  X_Cost_Adjustment_Flag)
                OR (    (Recinfo.cost_adjustment_flag IS NULL)
                    AND (X_Cost_Adjustment_Flag IS NULL)))
	  AND (Recinfo.reverse_flag =  X_Reverse_Flag)
	   AND  (   (Recinfo.reversal_date =  X_Reversal_Date)
                OR (    (Recinfo.reversal_date IS NULL)
                    AND (X_Reversal_Date IS NULL)))
           AND (   (Recinfo.depreciation_expense_ccid =
			X_Depreciation_Expense_Ccid)
                OR (    (Recinfo.depreciation_expense_ccid IS NULL)
                    AND (X_Depreciation_Expense_Ccid IS NULL)))
           AND (Recinfo.capitalized_flag =  X_Capitalized_Flag)
           AND (   (Recinfo.estimated_in_service_date =
			X_Estimated_In_Service_Date)
                OR (    (Recinfo.estimated_in_service_date IS NULL)
                    AND (X_Estimated_In_Service_Date IS NULL)))
           AND (   (Recinfo.capitalized_cost =  X_Capitalized_Cost)
                OR (    (Recinfo.capitalized_cost IS NULL)
                    AND (X_Capitalized_Cost IS NULL)))
           AND (   (Recinfo.grouped_cip_cost =  X_Grouped_Cip_Cost)
                OR (    (Recinfo.grouped_cip_cost IS NULL)
                    AND (X_Grouped_Cip_Cost IS NULL)))
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
           AND (Recinfo.project_asset_type =  X_project_asset_type)
           AND (   (Recinfo.estimated_asset_units =  X_Estimated_Units)
                OR (    (Recinfo.estimated_asset_units IS NULL)
                    AND (X_Estimated_Units IS NULL)))
           AND (   (Recinfo.parent_asset_id =  X_Parent_Asset_Id)
                OR (    (Recinfo.parent_asset_id IS NULL)
                    AND (X_Parent_Asset_Id IS NULL)))
           AND (   (Recinfo.estimated_cost =  X_Estimated_Cost)
                OR (    (Recinfo.estimated_cost IS NULL)
                    AND (X_Estimated_Cost IS NULL)))
           AND (   (Recinfo.manufacturer_name =  X_Manufacturer_Name)
                OR (    (Recinfo.manufacturer_name IS NULL)
                    AND (X_Manufacturer_Name IS NULL)))
           AND (   (Recinfo.model_number =  X_Model_Number)
                OR (    (Recinfo.model_number IS NULL)
                    AND (X_Model_Number IS NULL)))
           AND (   (Recinfo.serial_number =  X_serial_number)
                OR (    (Recinfo.serial_number IS NULL)
                    AND (X_serial_number IS NULL)))
           AND (   (Recinfo.tag_number =  X_tag_number)
                OR (    (Recinfo.tag_number IS NULL)
                    AND (X_tag_number IS NULL)))
           AND (   (Recinfo.Capital_Event_ID =  X_Capital_Event_ID)
               OR (    (Recinfo.Capital_Event_ID IS NULL)
                    AND (X_Capital_Event_ID IS NULL)))
           AND (Recinfo.capital_hold_flag =  X_capital_hold_flag)
           AND (   (Recinfo.ret_target_asset_id =  X_ret_target_asset_id)
                OR (    (Recinfo.ret_target_asset_id IS NULL)
                    AND (X_ret_target_asset_id IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Project_Asset_Id               NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Asset_Number                   VARCHAR2,
                       X_Asset_Name                     VARCHAR2,
                       X_Asset_Description              VARCHAR2,
                       X_Location_Id                    NUMBER,
                       X_Assigned_To_Person_Id          NUMBER,
                       X_Date_Placed_In_Service         DATE,
                       X_Asset_Category_Id              NUMBER,
		       X_Asset_key_ccid		NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Units                    NUMBER,
                       X_Depreciate_Flag                VARCHAR2,
                       X_Amortize_Flag                 VARCHAR2,
                       X_Cost_Adjustment_Flag          VARCHAR2,
			X_Reverse_Flag			VARCHAR2,
                       X_Depreciation_Expense_Ccid      NUMBER,
                       X_Capitalized_Flag               VARCHAR2,
                       X_Estimated_In_Service_Date      DATE,
                       X_Capitalized_Cost               NUMBER,
                       X_Grouped_Cip_Cost               NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
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
                       --PA.L
                       X_Project_Asset_Type             VARCHAR2,
                       X_Estimated_Units                NUMBER,
                       X_Parent_Asset_Id                NUMBER,
                       X_Estimated_Cost                 NUMBER,
                       X_Manufacturer_Name              VARCHAR2,
                       X_Model_Number                   VARCHAR2,
                       X_Serial_Number                  VARCHAR2,
                       X_Tag_Number                     VARCHAR2,
                       X_Capital_Event_Id               NUMBER,
                       X_Capital_Hold_Flag              VARCHAR2,
                       X_Ret_Target_Asset_Id            NUMBER
  ) IS
  BEGIN
    UPDATE pa_project_assets
    SET
       project_asset_id                =     X_Project_Asset_Id,
       project_id                      =     X_Project_Id,
       asset_number                    =     X_Asset_Number,
       asset_name                      =     X_Asset_Name,
       asset_description               =     X_Asset_Description,
       location_id                     =     X_Location_Id,
       assigned_to_person_id           =     X_Assigned_To_Person_Id,
       date_placed_in_service          =     X_Date_Placed_In_Service,
       asset_category_id               =     X_Asset_Category_Id,
       asset_key_ccid		       =     X_Asset_key_ccid,
       book_type_code                  =     X_Book_Type_Code,
       asset_units                     =     X_Asset_Units,
       depreciate_flag                 =     X_Depreciate_Flag,
	amortize_flag			=	X_Amortize_Flag,
	cost_adjustment_flag		=	X_Cost_Adjustment_Flag,
	reverse_flag			=       X_Reverse_Flag,
       depreciation_expense_ccid       =     X_Depreciation_Expense_Ccid,
       capitalized_flag                =     X_Capitalized_Flag,
       estimated_in_service_date       =     X_Estimated_In_Service_Date,
       capitalized_cost                =     X_Capitalized_Cost,
       grouped_cip_cost                =     X_Grouped_Cip_Cost,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
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
       project_asset_type              =     X_Project_Asset_Type,
       estimated_asset_units           =     X_Estimated_Units,
       parent_asset_id                 =     X_Parent_Asset_Id,
       estimated_cost                  =     X_Estimated_Cost,
       manufacturer_name               =     X_Manufacturer_Name,
       model_number                    =     X_Model_Number,
       serial_number                   =     X_Serial_Number,
       tag_number                      =     X_Tag_Number    ,
       capital_event_id                =     X_Capital_Event_Id,
       capital_hold_flag               =     X_Capital_Hold_Flag,
       ret_target_asset_id             =     X_Ret_Target_Asset_Id
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
			X_project_asset_id NUMBER) IS
  BEGIN
    DELETE FROM pa_project_asset_assignments
    WHERE project_asset_id = X_project_asset_id;

    DELETE FROM pa_project_assets
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END PA_PROJECT_ASSETS_PKG;

/
