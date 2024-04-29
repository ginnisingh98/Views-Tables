--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_VERSIONS_PKG" as
/* $Header: PAXBUBVB.pls 120.1 2005/08/19 17:10:30 mwasowic noship $ */


--Name:              	Insert_Row
--Type:               	Procedure
--
--Description:
--
--Notes:
--                      For the FP dev effort, the decision was made to provide
--                      very limited FP support. Just enough to keep new FP
--                      queries from breaking.
--
--                      This procedure does NOT create FP plans!
--
--                      You must use a PA_FIN_PLAN_PUB api to insert plans.
--
--
--
--
--Called subprograms:   None.
--
--
--
--History:
--   	XX-XXX-XX	who?	- Created
--
--      19-AUG-02	jwhite	- Minor modifications for the new FP model:
--                                1) Added new FP columns, approved_cost/rev_plan_type_flags.
--
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Budget_Version_Id              IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Project_Id                     NUMBER,
                       X_Budget_Type_Code               VARCHAR2,
                       X_Version_Number                 NUMBER,
                       X_Budget_Status_Code             VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Current_Flag                   VARCHAR2,
                       X_Original_Flag                  VARCHAR2,
                       X_Current_Original_Flag          VARCHAR2,
                       X_Resource_Accumulated_Flag      VARCHAR2,
                       X_Resource_List_Id               NUMBER,
                       X_Version_Name                   VARCHAR2,
                       X_Budget_Entry_Method_Code       VARCHAR2,
                       X_Baselined_By_Person_Id         NUMBER,
                       X_Baselined_Date                 DATE,
                       X_Change_Reason_Code             VARCHAR2,
                       X_Labor_Quantity                 NUMBER,
                       X_Labor_Unit_Of_Measure          VARCHAR2,
                       X_Raw_Cost                       NUMBER,
                       X_Burdened_Cost                  NUMBER,
                       X_Revenue                        NUMBER,
                       X_Description                    VARCHAR2,
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
                       X_First_Budget_Period            VARCHAR2,
	         X_Pm_Product_Code                VARCHAR2 DEFAULT NULL,
	         X_Pm_Budget_Reference            VARCHAR2 DEFAULT NULL,
	         X_wf_status_code		VARCHAR2 DEFAULT NULL,
                        x_adw_notify_flag       VARCHAR2 DEFAULT NULL,
                        x_prc_generated_flag    VARCHAR2 DEFAULT NULL,
                        x_plan_run_date         DATE DEFAULT NULL,
                        x_plan_processing_code  VARCHAR2 DEFAULT NULL
  )

  IS


      CURSOR C IS SELECT rowid FROM pa_budget_versions
                 WHERE budget_version_id = X_Budget_Version_Id;

      CURSOR C2 IS SELECT pa_budget_versions_s.nextval FROM sys.dual;


   BEGIN
      if (X_Budget_Version_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Budget_Version_Id;
        CLOSE C2;
      end if;

       INSERT INTO pa_budget_versions(
              budget_version_id,
              project_id,
              budget_type_code,
              version_number,
              budget_status_code,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              current_flag,
              original_flag,
              current_original_flag,
              resource_accumulated_flag,
              resource_list_id,
              version_name,
              budget_entry_method_code,
              baselined_by_person_id,
              baselined_date,
              change_reason_code,
              labor_quantity,
              labor_unit_of_measure,
              raw_cost,
              burdened_cost,
              revenue,
              description,
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
              first_budget_period,
	      pm_product_code,
	      pm_budget_reference,
		wf_status_code,
		ADW_NOTIFY_FLAG,
		PRC_GENERATED_FLAG,
		PLAN_RUN_DATE,
		PLAN_PROCESSING_CODE,
              approved_cost_plan_type_flag,
              approved_rev_plan_type_flag
             ) VALUES (
              X_Budget_Version_Id,
              X_Project_Id,
              X_Budget_Type_Code,
              X_Version_Number,
              X_Budget_Status_Code,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Current_Flag,
              X_Original_Flag,
              X_Current_Original_Flag,
              X_Resource_Accumulated_Flag,
              X_Resource_List_Id,
              X_Version_Name,
              X_Budget_Entry_Method_Code,
              X_Baselined_By_Person_Id,
              X_Baselined_Date,
              X_Change_Reason_Code,
              (X_Labor_Quantity),
              X_Labor_Unit_Of_Measure,
              pa_currency.round_currency_amt(X_Raw_Cost),
              pa_currency.round_currency_amt(X_Burdened_Cost),
              pa_currency.round_currency_amt(X_Revenue),
              X_Description,
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
              X_First_Budget_Period,
	      X_Pm_Product_Code ,
	      X_Pm_Budget_Reference,
	        X_WF_Status_Code,
                X_ADW_NOTIFY_FLAG,
                X_PRC_GENERATED_FLAG,
                X_PLAN_RUN_DATE,
                X_PLAN_PROCESSING_CODE,
             decode(x_budget_type_code,'AC','Y','N'),
             decode(x_budget_type_code,'AR','Y','N')
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

                     X_Budget_Version_Id                NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Budget_Type_Code                 VARCHAR2,
                     X_Version_Number                   NUMBER,
                     X_Budget_Status_Code               VARCHAR2,
                     X_Current_Flag                     VARCHAR2,
                     X_Original_Flag                    VARCHAR2,
                     X_Current_Original_Flag            VARCHAR2,
                     X_Resource_Accumulated_Flag        VARCHAR2,
                     X_Resource_List_Id                 NUMBER,
                     X_Version_Name                     VARCHAR2,
                     X_Budget_Entry_Method_Code         VARCHAR2,
                     X_Baselined_By_Person_Id           NUMBER,
                     X_Baselined_Date                   DATE,
                     X_Change_Reason_Code               VARCHAR2,
                     X_Labor_Quantity                   NUMBER,
                     X_Labor_Unit_Of_Measure            VARCHAR2,
                     X_Raw_Cost                         NUMBER,
                     X_Burdened_Cost                    NUMBER,
                     X_Revenue                          NUMBER,
                     X_Description                      VARCHAR2,
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
                     X_First_Budget_Period               VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   pa_budget_versions
        WHERE  rowid = X_Rowid
        FOR UPDATE of Budget_Version_Id NOWAIT;
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

               (Recinfo.budget_version_id =  X_Budget_Version_Id)
           AND (Recinfo.project_id =  X_Project_Id)
           AND (Recinfo.budget_type_code =  X_Budget_Type_Code)
           AND (Recinfo.version_number =  X_Version_Number)
           AND (Recinfo.budget_status_code =  X_Budget_Status_Code)
           AND (Recinfo.current_flag =  X_Current_Flag)
           AND (Recinfo.original_flag =  X_Original_Flag)
           AND (Recinfo.current_original_flag =  X_Current_Original_Flag)
           AND (Recinfo.resource_accumulated_flag = X_Resource_Accumulated_Flag)
           AND (Recinfo.resource_list_id =  X_Resource_List_Id)
           AND (   (Recinfo.version_name =  X_Version_Name)
                OR (    (Recinfo.version_name IS NULL)
                    AND (X_Version_Name IS NULL)))
           AND (   (Recinfo.budget_entry_method_code =
			 X_Budget_Entry_Method_Code)
		OR (    (Recinfo.budget_entry_method_code IS NULL)
                    AND (X_Budget_Entry_Method_Code IS NULL)))
           AND (   (Recinfo.baselined_by_person_id =  X_Baselined_By_Person_Id)
                OR (    (Recinfo.baselined_by_person_id IS NULL)
                    AND (X_Baselined_By_Person_Id IS NULL)))
           AND (   (Recinfo.baselined_date =  X_Baselined_Date)
                OR (    (Recinfo.baselined_date IS NULL)
                    AND (X_Baselined_Date IS NULL)))
           AND (   (Recinfo.change_reason_code =  X_Change_Reason_Code)
                OR (    (Recinfo.change_reason_code IS NULL)
                    AND (X_Change_Reason_Code IS NULL)))
           AND (   (Recinfo.labor_quantity =  X_Labor_Quantity)
                OR (    (Recinfo.labor_quantity IS NULL)
                    AND (X_Labor_Quantity IS NULL)))
           AND (   (Recinfo.labor_unit_of_measure =  X_Labor_Unit_Of_Measure)
                OR (    (Recinfo.labor_unit_of_measure IS NULL)
                    AND (X_Labor_Unit_Of_Measure IS NULL)))
           AND (   (Recinfo.raw_cost =  X_Raw_Cost)
                OR (    (Recinfo.raw_cost IS NULL)
                    AND (X_Raw_Cost IS NULL)))
           AND (   (Recinfo.burdened_cost =  X_Burdened_Cost)
                OR (    (Recinfo.burdened_cost IS NULL)
                    AND (X_Burdened_Cost IS NULL)))
           AND (   (Recinfo.revenue =  X_Revenue)
                OR (    (Recinfo.revenue IS NULL)
                    AND (X_Revenue IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
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
           AND (   (Recinfo.First_Budget_period =  X_First_Budget_period)
                OR (    (Recinfo.First_Budget_period IS NULL)
                    AND (X_First_Budget_period IS NULL)))
	) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


--Name:              	Update_Row
--Type:               	Procedure
--
--Description:
--
--Notes:
--                      For the FP dev effort, the decision was made to provide
--                      very limited FP support. Just enough to keep new FP
--                      queries from breaking.
--
--                      This procedure does NOT update FP plans!
--
--                      You must use a PA_FIN_PLAN_PUB api to update plans.
--
--
--
--
--Called subprograms:   None.
--
--
--
--History:
--   	XX-XXX-XX	who?	- Created
--
--      19-AUG-02	jwhite	- Minor modifications for the new FP model:
--                                1) Added new FP columns, approved_cost/rev_plan_type_flags.
--

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Budget_Version_Id              NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Budget_Type_Code               VARCHAR2,
                       X_Version_Number                 NUMBER,
                       X_Budget_Status_Code             VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Current_Flag                   VARCHAR2,
                       X_Original_Flag                  VARCHAR2,
                       X_Current_Original_Flag          VARCHAR2,
                       X_Resource_Accumulated_Flag      VARCHAR2,
                       X_Resource_List_Id               NUMBER,
                       X_Version_Name                   VARCHAR2,
                       X_Budget_Entry_Method_Code       VARCHAR2,
                       X_Baselined_By_Person_Id         NUMBER,
                       X_Baselined_Date                 DATE,
                       X_Change_Reason_Code             VARCHAR2,
                       X_Labor_Quantity                 NUMBER,
                       X_Labor_Unit_Of_Measure          VARCHAR2,
                       X_Raw_Cost                       NUMBER,
                       X_Burdened_Cost                  NUMBER,
                       X_Revenue                        NUMBER,
                       X_Description                    VARCHAR2,
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
                       X_First_Budget_period             VARCHAR2,
	         X_WF_Status_Code		VARCHAR2,
                        x_adw_notify_flag       VARCHAR2 DEFAULT NULL,
                        x_prc_generated_flag    VARCHAR2 DEFAULT NULL,
                        x_plan_run_date         DATE DEFAULT NULL,
                        x_plan_processing_code  VARCHAR2 DEFAULT NULL
  ) IS
  BEGIN
    UPDATE pa_budget_versions
    SET
       budget_version_id               =     X_Budget_Version_Id,
       project_id                      =     X_Project_Id,
       budget_type_code                =     X_Budget_Type_Code,
       version_number                  =     X_Version_Number,
       budget_status_code              =     X_Budget_Status_Code,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       current_flag                    =     X_Current_Flag,
       original_flag                   =     X_Original_Flag,
       current_original_flag           =     X_Current_Original_Flag,
       resource_accumulated_flag       =     X_Resource_Accumulated_Flag,
       resource_list_id                =     X_Resource_List_Id,
       version_name                    =     X_Version_Name,
       budget_entry_method_code        =     X_Budget_Entry_Method_Code,
       baselined_by_person_id          =     X_Baselined_By_Person_Id,
       baselined_date                  =     X_Baselined_Date,
       change_reason_code              =     X_Change_Reason_Code,
       labor_quantity                  =     (X_Labor_Quantity),
       labor_unit_of_measure           =     X_Labor_Unit_Of_Measure,
       raw_cost                        =     pa_currency.round_currency_amt(X_Raw_Cost),
       burdened_cost                   =     pa_currency.round_currency_amt(X_Burdened_Cost),
       revenue                         =     pa_currency.round_currency_amt(X_Revenue),
       description                     =     X_Description,
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
       first_budget_period             =     X_First_Budget_Period,
       wf_status_code                  =     X_WF_Status_Code,
	ADW_NOTIFY_FLAG		       = DECODE(x_ADW_NOTIFY_FLAG, NULL, ADW_NOTIFY_FLAG, x_ADW_NOTIFY_FLAG),
	PRC_GENERATED_FLAG	       = DECODE(x_PRC_GENERATED_FLAG, NULL, PRC_GENERATED_FLAG, x_PRC_GENERATED_FLAG),
	PLAN_RUN_DATE		       = DECODE(x_PLAN_RUN_DATE, NULL, PLAN_RUN_DATE, x_PLAN_RUN_DATE),
	PLAN_PROCESSING_CODE	       = DECODE(x_PLAN_PROCESSING_CODE, NULL, PLAN_PROCESSING_CODE, x_PLAN_PROCESSING_CODE),
       approved_cost_plan_type_flag    =       decode(x_budget_type_code,'AC','Y','N'),
       approved_rev_plan_type_flag     =       decode(x_budget_type_code,'AR','Y','N')
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM pa_budget_versions
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END PA_BUDGET_VERSIONS_PKG;

/
