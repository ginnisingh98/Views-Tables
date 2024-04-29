--------------------------------------------------------
--  DDL for Package Body OKE_FUNDINGALLOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_FUNDINGALLOCATION_PVT" as
/* $Header: OKEVKFAB.pls 115.15 2002/11/27 20:26:56 syho ship $ */


PROCEDURE Insert_Row(X_Rowid              IN OUT NOCOPY VARCHAR2,
     		     X_Fund_Allocation_Id		NUMBER,
 		     X_Funding_Source_Id		NUMBER,
		     X_Object_Id			NUMBER,
		     X_K_Line_Id			NUMBER,
		     X_Project_Id			NUMBER,
		     X_Task_Id			        NUMBER,
		     X_Amount				NUMBER,
		     X_Previous_Amount			NUMBER,
		     X_Hard_Limit			NUMBER,
		     X_Revenue_Hard_Limit		NUMBER,
		     X_Fund_Type			VARCHAR2,
		     X_Funding_Status			VARCHAR2,
		     X_Fiscal_Year			VARCHAR2,
		     X_Reference1			VARCHAR2,
		     X_Reference2			VARCHAR2,
		     X_Reference3			VARCHAR2,
		     X_PA_Conversion_Type		VARCHAR2,
		     X_PA_Conversion_Date		DATE,
		     X_PA_Conversion_Rate		NUMBER,
		     X_Insert_Update_Flag		VARCHAR2,
                     X_Start_Date_Active		DATE,
                     X_End_Date_Active		        DATE,
                     X_Funding_Category			VARCHAR2,
                     X_Last_Update_Date                 DATE,
                     X_Last_Updated_By                  NUMBER,
                     X_Creation_Date                    DATE,
                     X_Created_By                       NUMBER,
                     X_Last_Update_Login                NUMBER,
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
                     X_PA_Attribute_Category            VARCHAR2,
                     X_PA_Attribute1                    VARCHAR2,
                     X_PA_Attribute2                    VARCHAR2,
                     X_PA_Attribute3                    VARCHAR2,
                     X_PA_Attribute4                    VARCHAR2,
                     X_PA_Attribute5                    VARCHAR2,
                     X_PA_Attribute6                    VARCHAR2,
                     X_PA_Attribute7                    VARCHAR2,
                     X_PA_Attribute8                    VARCHAR2,
                     X_PA_Attribute9                    VARCHAR2,
                     X_PA_Attribute10                   VARCHAR2
  ) is

    cursor C is
       select rowid
       from   OKE_K_FUND_ALLOCATIONS
       where  fund_allocation_id = X_fund_allocation_id;

    cursor c1 is
       select major_version + 1
       from   okc_k_vers_numbers
       where  chr_id = x_object_id
    for update of chr_id nowait;

    l_version	number;

begin

       open c1;
       fetch c1 into l_version;
       if (c1%notfound) then
    	   close c1;
    	   raise no_data_found;
       end if;
       close c1;

       insert into OKE_K_FUND_ALLOCATIONS(
              fund_allocation_id,
              funding_source_id,
              object_id,
              k_line_id,
              project_id,
              task_id,
              amount,
              previous_amount,
              hard_limit,
              revenue_hard_limit,
              fund_type,
              funding_status,
              fiscal_year,
              reference1,
              reference2,
              reference3,
              pa_conversion_type,
              pa_conversion_date,
              pa_conversion_rate,
              insert_update_flag,
              start_date_active,
              end_date_active,
              funding_category,
              created_in_version,
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
              pa_attribute_category,
              pa_attribute1,
              pa_attribute2,
              pa_attribute3,
              pa_attribute4,
              pa_attribute5,
              pa_attribute6,
              pa_attribute7,
              pa_attribute8,
              pa_attribute9,
              pa_attribute10
             ) VALUES (
              X_Fund_Allocation_Id,
 	      X_Funding_Source_Id,
	      X_Object_Id,
	      X_K_Line_Id,
	      X_Project_Id,
	      X_Task_Id,
              X_Amount,
              X_Previous_Amount,
              X_Hard_Limit,
              X_Revenue_Hard_Limit,
	      X_Fund_Type,
	      X_Funding_Status,
	      X_Fiscal_Year,
	      X_Reference1,
	      X_Reference2,
	      X_Reference3,
	      X_PA_Conversion_Type,
	      X_PA_Conversion_Date,
	      X_PA_Conversion_Rate,
	      X_Insert_Update_Flag,
              X_Start_Date_Active,
              X_End_Date_Active,
              X_Funding_Category,
              l_version,
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
              X_PA_Attribute_Category,
              X_PA_Attribute1,
              X_PA_Attribute2,
              X_PA_Attribute3,
              X_PA_Attribute4,
              X_PA_Attribute5,
              X_PA_Attribute6,
              X_PA_Attribute7,
              X_PA_Attribute8,
              X_PA_Attribute9,
              X_PA_Attribute10
             );

  	open c;
 	fetch c into X_Rowid;
    	if (c%notfound) then
   	   close c;
    	   raise no_data_found;
        end if;
        close c;

end Insert_Row;


PROCEDURE Lock_Row(X_Fund_Allocation_Id			NUMBER,
 		   X_Funding_Source_Id			NUMBER,
		   X_Object_Id			        NUMBER,
		   X_K_Line_Id				NUMBER,
		   X_Project_Id				NUMBER,
		   X_Task_Id				NUMBER,
		   X_Amount				NUMBER,
		   X_Previous_Amount			NUMBER,
		   X_Hard_Limit				NUMBER,
		   X_Revenue_Hard_Limit			NUMBER,
		   X_Fund_Type				VARCHAR2,
		   X_Funding_Status			VARCHAR2,
		   X_Fiscal_Year			VARCHAR2,
		   X_Reference1				VARCHAR2,
		   X_Reference2				VARCHAR2,
		   X_Reference3				VARCHAR2,
		   X_PA_Conversion_Type			VARCHAR2,
		   X_PA_Conversion_Date			DATE,
		   X_PA_Conversion_Rate			NUMBER,
                   X_Start_Date_Active			DATE,
                   X_End_Date_Active			DATE,
                   X_Funding_Category			VARCHAR2,
                   X_Attribute_Category                 VARCHAR2,
                   X_Attribute1                         VARCHAR2,
                   X_Attribute2                         VARCHAR2,
                   X_Attribute3                         VARCHAR2,
                   X_Attribute4                         VARCHAR2,
                   X_Attribute5                         VARCHAR2,
                   X_Attribute6                         VARCHAR2,
                   X_Attribute7                         VARCHAR2,
                   X_Attribute8                         VARCHAR2,
                   X_Attribute9                         VARCHAR2,
                   X_Attribute10                        VARCHAR2,
                   X_Attribute11                        VARCHAR2,
                   X_Attribute12                        VARCHAR2,
                   X_Attribute13                        VARCHAR2,
                   X_Attribute14                        VARCHAR2,
                   X_Attribute15                        VARCHAR2,
                   X_PA_Attribute_Category              VARCHAR2,
                   X_PA_Attribute1                      VARCHAR2,
                   X_PA_Attribute2                      VARCHAR2,
                   X_PA_Attribute3                      VARCHAR2,
                   X_PA_Attribute4                      VARCHAR2,
                   X_PA_Attribute5                      VARCHAR2,
                   X_PA_Attribute6                      VARCHAR2,
                   X_PA_Attribute7                      VARCHAR2,
                   X_PA_Attribute8                      VARCHAR2,
                   X_PA_Attribute9                      VARCHAR2,
                   X_PA_Attribute10                     VARCHAR2
  ) is

    cursor c is
    select fund_allocation_id,
           funding_source_id,
           object_id,
           k_line_id,
           project_id,
           task_id,
           amount,
           previous_amount,
           hard_limit,
           revenue_hard_limit,
           fund_type,
           funding_status,
           fiscal_year,
           reference1,
           reference2,
           reference3,
           pa_conversion_type,
           pa_conversion_date,
           pa_conversion_rate,
           start_date_active,
           end_date_active,
           funding_category,
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
           pa_attribute_category,
           pa_attribute1,
           pa_attribute2,
           pa_attribute3,
           pa_attribute4,
           pa_attribute5,
           pa_attribute6,
           pa_attribute7,
           pa_attribute8,
           pa_attribute9,
           pa_attribute10
    from   OKE_K_FUND_ALLOCATIONS
    where  fund_allocation_id = X_Fund_Allocation_Id
    for update of fund_allocation_id nowait;

    recinfo c%rowtype;

begin

    open c;
    fetch c into recinfo;
    if (c%notfound) then
       close c;
       fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
       app_exception.raise_exception;
    end if;
    close c;

    if (   ((recinfo.object_id = X_Object_Id)
           OR ((recinfo.object_id is null) AND (X_Object_Id is null)))
       AND ((recinfo.start_date_active = X_Start_Date_Active)
           OR ((recinfo.start_date_active is null) AND (X_Start_Date_Active is null)))
       AND ((recinfo.end_date_active = X_End_Date_Active)
           OR ((recinfo.end_date_active is null) AND (X_End_Date_Active is null)))
       AND ((recinfo.k_line_id = X_K_Line_Id)
           OR ((recinfo.k_line_id is null) AND (X_K_Line_Id is null)))
       AND ((recinfo.hard_limit = X_Hard_Limit)
           OR ((recinfo.hard_limit is null) AND (X_Hard_Limit is null)))
       AND ((recinfo.revenue_hard_limit = X_Revenue_Hard_Limit)
           OR ((recinfo.revenue_hard_limit is null) AND (X_Revenue_Hard_Limit is null)))
       AND ((recinfo.project_id = X_Project_Id)
           OR ((recinfo.project_id is null) AND (X_Project_Id is null)))
       AND ((recinfo.task_id = X_Task_Id)
           OR ((recinfo.task_id is null) AND (X_Task_Id is null)))
       AND ((rtrim(recinfo.funding_status) = rtrim(X_Funding_Status))
           OR ((recinfo.funding_status is null) AND (X_Funding_Status is null)))
       AND ((rtrim(recinfo.funding_category) = rtrim(X_Funding_Category))
           OR ((recinfo.funding_category is null) AND (X_Funding_Category is null)))
       AND ((rtrim(recinfo.fiscal_year) = rtrim(X_Fiscal_Year))
           OR ((recinfo.fiscal_year is null) AND (X_Fiscal_Year is null)))
       AND ((rtrim(recinfo.fund_type) = rtrim(X_Fund_Type))
           OR ((recinfo.fund_type is null) AND (X_Fund_Type is null)))
       AND ((rtrim(recinfo.reference1) = rtrim(X_Reference1))
           OR ((recinfo.reference1 is null) AND (X_Reference1 is null)))
       AND ((rtrim(recinfo.reference2) = rtrim(X_Reference2))
           OR ((recinfo.reference2 is null) AND (X_Reference2 is null)))
       AND ((rtrim(recinfo.reference3) = rtrim(X_Reference3))
           OR ((recinfo.reference3 is null) AND (X_Reference3 is null)))
       AND ((rtrim(recinfo.pa_conversion_type) = rtrim(X_pa_conversion_type))
           OR ((recinfo.pa_conversion_type is null) AND (X_pa_conversion_type is null)))
       AND ((recinfo.pa_conversion_date = X_pa_conversion_date)
           OR ((recinfo.pa_conversion_date is null) AND (X_pa_conversion_date is null)))
       AND ((recinfo.pa_conversion_rate = X_pa_conversion_rate)
           OR ((recinfo.pa_conversion_rate is null) AND (X_pa_conversion_rate is null)))
       AND (recinfo.amount = X_Amount)
       AND (recinfo.previous_amount = X_Previous_Amount)
       AND (recinfo.fund_allocation_id = X_Fund_Allocation_Id)
       AND (recinfo.funding_source_id = X_Funding_Source_Id)
       AND ((rtrim(recinfo.attribute_category) = rtrim(X_Attribute_Category))
           OR ((recinfo.attribute_category is null) AND (X_Attribute_Category is null)))
       AND ((rtrim(recinfo.attribute1) = rtrim(X_Attribute1))
           OR ((recinfo.attribute1 is null) AND (X_Attribute1 is null)))
       AND ((rtrim(recinfo.attribute2) = rtrim(X_Attribute2))
           OR ((recinfo.attribute2 is null) AND (X_Attribute2 is null)))
       AND ((rtrim(recinfo.attribute3) = rtrim(X_Attribute3))
           OR ((recinfo.attribute3 is null) AND (X_Attribute3 is null)))
       AND ((rtrim(recinfo.attribute4) = rtrim(X_Attribute4))
           OR ((recinfo.attribute4 is null) AND (X_Attribute4 is null)))
       AND ((rtrim(recinfo.attribute5) = rtrim(X_Attribute5))
           OR ((recinfo.attribute5 is null) AND (X_Attribute5 is null)))
       AND ((rtrim(recinfo.attribute6) = rtrim(X_Attribute6))
           OR ((recinfo.attribute6 is null) AND (X_Attribute6 is null)))
       AND ((rtrim(recinfo.attribute7) = rtrim(X_Attribute7))
           OR ((recinfo.attribute7 is null) AND (X_Attribute7 is null)))
       AND ((rtrim(recinfo.attribute8) = rtrim(X_Attribute8))
           OR ((recinfo.attribute8 is null) AND (X_Attribute8 is null)))
       AND ((rtrim(recinfo.attribute9) = rtrim(X_Attribute9))
           OR ((recinfo.attribute9 is null) AND (X_Attribute9 is null)))
       AND ((rtrim(recinfo.attribute10) = rtrim(X_Attribute10))
           OR ((recinfo.attribute10 is null) AND (X_Attribute10 is null)))
       AND ((rtrim(recinfo.attribute11) = rtrim(X_Attribute11))
           OR ((recinfo.attribute11 is null) AND (X_Attribute11 is null)))
       AND ((rtrim(recinfo.attribute12) = rtrim(X_Attribute12))
           OR ((recinfo.attribute12 is null) AND (X_Attribute12 is null)))
       AND ((rtrim(recinfo.attribute13) = rtrim(X_Attribute13))
           OR ((recinfo.attribute13 is null) AND (X_Attribute13 is null)))
       AND ((rtrim(recinfo.attribute14) = rtrim(X_Attribute14))
           OR ((recinfo.attribute14 is null) AND (X_Attribute14 is null)))
       AND ((rtrim(recinfo.attribute15) = rtrim(X_Attribute15))
           OR ((recinfo.attribute15 is null) AND (X_Attribute15 is null)))
       AND ((rtrim(recinfo.pa_attribute_category) = rtrim(X_PA_Attribute_Category))
           OR ((recinfo.pa_attribute_category is null) AND (X_PA_Attribute_Category is null)))
       AND ((rtrim(recinfo.pa_attribute1) = rtrim(X_PA_Attribute1))
           OR ((recinfo.pa_attribute1 is null) AND (X_PA_Attribute1 is null)))
       AND ((rtrim(recinfo.pa_attribute2) = rtrim(X_PA_Attribute2))
           OR ((recinfo.pa_attribute2 is null) AND (X_PA_Attribute2 is null)))
       AND ((rtrim(recinfo.pa_attribute3) = rtrim(X_PA_Attribute3))
           OR ((recinfo.pa_attribute3 is null) AND (X_PA_Attribute3 is null)))
       AND ((rtrim(recinfo.pa_attribute4) = rtrim(X_PA_Attribute4))
           OR ((recinfo.pa_attribute4 is null) AND (X_PA_Attribute4 is null)))
       AND ((rtrim(recinfo.pa_attribute5) = rtrim(X_PA_Attribute5))
           OR ((recinfo.pa_attribute5 is null) AND (X_PA_Attribute5 is null)))
       AND ((rtrim(recinfo.pa_attribute6) = rtrim(X_PA_Attribute6))
           OR ((recinfo.pa_attribute6 is null) AND (X_PA_Attribute6 is null)))
       AND ((rtrim(recinfo.pa_attribute7) = rtrim(X_PA_Attribute7))
           OR ((recinfo.pa_attribute7 is null) AND (X_PA_Attribute7 is null)))
       AND ((rtrim(recinfo.pa_attribute8) = rtrim(X_PA_Attribute8))
           OR ((recinfo.pa_attribute8 is null) AND (X_PA_Attribute8 is null)))
       AND ((rtrim(recinfo.pa_attribute9) = rtrim(X_PA_Attribute9))
           OR ((recinfo.pa_attribute9 is null) AND (X_PA_Attribute9 is null)))
       AND ((rtrim(recinfo.pa_attribute10) = rtrim(X_PA_Attribute10))
           OR ((recinfo.pa_attribute10 is null) AND (X_PA_Attribute10 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end Lock_Row;


PROCEDURE Update_Row(X_Fund_Allocation_Id		NUMBER,
		     X_Amount				NUMBER,
		     X_Previous_Amount			NUMBER,
		     X_Object_Id			NUMBER,
		     X_K_Line_Id			NUMBER,
		     X_Project_Id			NUMBER,
		     X_Task_Id				NUMBER,
		     X_Hard_Limit			NUMBER,
		     X_Revenue_Hard_Limit		NUMBER,
		     X_Fund_Type			VARCHAR2,
		     X_Funding_Status			VARCHAR2,
		     X_Fiscal_Year			VARCHAR2,
		     X_Reference1			VARCHAR2,
		     X_Reference2			VARCHAR2,
		     X_Reference3			VARCHAR2,
		     X_PA_Conversion_Type		VARCHAR2,
		     X_PA_Conversion_Date		DATE,
		     X_PA_Conversion_Rate		NUMBER,
                     X_Start_Date_Active		DATE,
                     X_End_Date_Active		        DATE,
                     X_Insert_Update_Flag		VARCHAR2,
                     X_Funding_Category			VARCHAR2,
                     X_Last_Update_Date                 DATE,
                     X_Last_Updated_By                  NUMBER,
                     X_Last_Update_Login                NUMBER,
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
                     X_PA_Attribute_Category            VARCHAR2,
                     X_PA_Attribute1                    VARCHAR2,
                     X_PA_Attribute2                    VARCHAR2,
                     X_PA_Attribute3                    VARCHAR2,
                     X_PA_Attribute4                    VARCHAR2,
                     X_PA_Attribute5                    VARCHAR2,
                     X_PA_Attribute6                    VARCHAR2,
                     X_PA_Attribute7                    VARCHAR2,
                     X_PA_Attribute8                    VARCHAR2,
                     X_PA_Attribute9                    VARCHAR2,
                     X_PA_Attribute10                   VARCHAR2
  ) is

    cursor c1 is
       select major_version + 1
       from   okc_k_vers_numbers
       where  chr_id = x_object_id
    for update of chr_id nowait;

    l_version	number;

begin

    open c1;
    fetch c1 into l_version;
    if (c1%notfound) then
       close c1;
       raise no_data_found;
    end if;
    close c1;

    update OKE_K_FUND_ALLOCATIONS
    set
       amount		     	       =     X_Amount,
       previous_amount		       =     X_Previous_Amount,
       k_line_id		       =     X_K_Line_Id,
       project_id		       =     X_Project_Id,
       task_id			       =     X_Task_Id,
       hard_limit		       =     X_Hard_Limit,
       revenue_hard_limit	       =     X_Revenue_Hard_Limit,
       fund_type	  	       =     X_Fund_Type,
       funding_status		       =     X_Funding_Status,
       fiscal_year		       =     X_Fiscal_Year,
       reference1		       =     X_Reference1,
       reference2		       =     X_Reference2,
       reference3		       =     X_Reference3,
       pa_conversion_type	       =     X_PA_Conversion_Type,
       pa_conversion_date	       =     X_PA_Conversion_Date,
       pa_conversion_rate	       =     X_PA_Conversion_Rate,
       insert_update_flag 	       =     X_Insert_Update_Flag,
       start_date_active	       =     X_Start_Date_Active,
       end_date_active		       =     X_End_Date_Active,
       funding_category		       =     X_Funding_Category,
       updated_in_version	       =     l_version,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       attribute_Category              =     X_Attribute_Category,
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
       pa_attribute_Category           =     X_PA_Attribute_Category,
       pa_attribute1                   =     X_PA_Attribute1,
       pa_attribute2                   =     X_PA_Attribute2,
       pa_attribute3                   =     X_PA_Attribute3,
       pa_attribute4                   =     X_PA_Attribute4,
       pa_attribute5                   =     X_PA_Attribute5,
       pa_attribute6                   =     X_PA_Attribute6,
       pa_attribute7                   =     X_PA_Attribute7,
       pa_attribute8                   =     X_PA_Attribute8,
       pa_attribute9                   =     X_PA_Attribute9,
       pa_attribute10                  =     X_PA_Attribute10
    where fund_allocation_id = X_Fund_Allocation_Id;

    if (sql%notfound) then
        raise no_data_found;
    end if;

end Update_Row;

PROCEDURE Delete_Row(X_Rowid		 VARCHAR2
  		      ) is

begin

   DELETE FROM OKE_K_FUND_ALLOCATIONS
   WHERE rowid = X_Rowid;

   if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
   end if;

end delete_row;

end OKE_FundingAllocation_PVT;

/
