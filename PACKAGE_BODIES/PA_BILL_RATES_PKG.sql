--------------------------------------------------------
--  DDL for Package Body PA_BILL_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILL_RATES_PKG" as
/* $Header: PASUDBRB.pls 120.3 2005/08/19 17:03:17 mwasowic noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Bill_Rate_Organization_Id             NUMBER,
                       X_Std_Bill_Rate_Schedule                VARCHAR2,
                       X_Last_Update_Date                      DATE,
                       X_Last_Updated_By                       NUMBER,
                       X_Creation_Date                         DATE,
                       X_Created_By                            NUMBER,
                       X_Last_Update_Login                     NUMBER,
                       X_Start_Date_Active                     DATE,
                       X_Person_Id                             NUMBER,
                       X_Job_Id                                NUMBER,
                       X_Expenditure_Type                      VARCHAR2,
                       X_Non_Labor_Resource                    VARCHAR2,
                       X_Rate                                  NUMBER,
                       X_Bill_Rate_Unit                        VARCHAR2,
                       X_Markup_Percentage                     NUMBER,
                       X_End_Date_Active                       DATE,
                       X_Bill_Rate_Sch_Id                      NUMBER,
                       X_job_group_id                          NUMBER,
		       x_Rate_Currency_Code                    VARCHAR2,
       		       X_Resource_Class_Code                   VARCHAR2,
		       X_Res_Class_Organization_Id	       NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM PA_BILL_RATES
                 WHERE

-- Bug 2078409
/*                     bill_rate_organization_id = X_Bill_Rate_Organization_Id
		 AND   std_bill_rate_schedule = X_Std_Bill_Rate_Schedule
*/
                       bill_rate_sch_id= X_Bill_Rate_Sch_id
		 AND   start_date_active = X_Start_Date_Active
		 AND   nvl(person_id, -1) = nvl(X_Person_Id, -1)
		 AND   nvl(job_id, -1) = nvl(X_Job_Id, -1)
		 AND   nvl(expenditure_type, '-1') =
			nvl(X_Expenditure_Type, '-1')
		 AND   nvl(non_labor_resource, '-1') =
			nvl(X_Non_Labor_Resource, '-1');


   l_org_id     NUMBER;


   l_rowid    varchar2(30);


   BEGIN

       /* ATG NOCOPY change */

         l_rowid := x_rowid;



        /* Shared service changes:  Get the Current org Id from context and insert org_id into
           the pa_bill_rates table, The context is already set it in the forms */


         l_org_id  :=  MO_GLOBAL.get_current_org_id ;


       INSERT INTO PA_BILL_RATES(
                Bill_Rate_Sch_Id,
		bill_rate_organization_id,
		std_bill_rate_schedule,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		start_date_active,
		person_id,
		job_id,
		expenditure_type,
		non_labor_resource,
		rate,
		bill_rate_unit,
		markup_percentage,
		end_date_active,
                job_group_id,
		Rate_Currency_Code,
		Resource_Class_Code,
		Res_Class_Organization_Id,
                Org_Id
             ) VALUES (
                X_Bill_Rate_Sch_Id,
		X_Bill_Rate_Organization_Id,
		X_Std_Bill_Rate_Schedule,
		X_Last_Update_Date,
		X_Last_Updated_By,
		X_Creation_Date,
		X_Created_By,
		X_Last_Update_Login,
		X_Start_Date_Active,
		X_Person_Id,
		X_Job_Id,
		X_Expenditure_Type,
		X_Non_Labor_Resource,
		X_Rate,
		X_Bill_Rate_Unit,
		X_Markup_Percentage,
		X_End_Date_Active,
                X_job_group_id,
		X_Rate_Currency_Code,
 	        X_Resource_Class_Code,
		X_Res_Class_Organization_Id,
                l_org_id
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;

      x_rowid := l_rowid;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(  X_Rowid                            VARCHAR2,
                       X_Bill_Rate_Organization_Id             NUMBER,
                       X_Std_Bill_Rate_Schedule                VARCHAR2,
                       X_Start_Date_Active                     DATE,
                       X_Person_Id                             NUMBER,
                       X_Job_Id                                NUMBER,
                       X_Expenditure_Type                      VARCHAR2,
                       X_Non_Labor_Resource                    VARCHAR2,
                       X_Rate                                  NUMBER,
                       X_Bill_Rate_Unit                        VARCHAR2,
                       X_Markup_Percentage                     NUMBER,
                       X_End_Date_Active                       DATE,
-- Bug 2078409
                       X_Bill_Rate_Sch_id                      NUMBER,
		       X_Rate_Currency_Code                    VARCHAR2,
       		       X_Resource_Class_Code                   VARCHAR2,
		       X_Res_Class_Organization_Id	       NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PA_BILL_RATES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Bill_Rate_Organization_Id NOWAIT;
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

-- Bug 2078409
/*             (Recinfo.bill_rate_organization_id = X_Bill_Rate_Organization_Id)
           AND (Recinfo.std_bill_rate_schedule =  X_Std_Bill_Rate_Schedule)   */

               (Recinfo.bill_rate_sch_id= X_Bill_Rate_Sch_id)
           AND (Recinfo.start_date_active =  X_Start_Date_Active)
           AND (   (Recinfo.person_id =  X_Person_Id)
                OR (    (Recinfo.person_id IS NULL)
                    AND (X_Person_Id IS NULL)))
           AND (   (Recinfo.job_id =  X_Job_Id)
                OR (    (Recinfo.job_id IS NULL)
                    AND (X_Job_Id IS NULL)))
           AND (   (Recinfo.expenditure_type =  X_Expenditure_Type)
                OR (    (Recinfo.expenditure_type IS NULL)
                    AND (X_Expenditure_Type IS NULL)))
           AND (   (Recinfo.non_labor_resource =  X_Non_Labor_Resource)
                OR (    (Recinfo.non_labor_resource IS NULL)
                    AND (X_Non_Labor_Resource IS NULL)))
           AND (   (Recinfo.rate =  X_Rate)
                OR (    (Recinfo.rate IS NULL)
                    AND (X_Rate IS NULL)))
           AND (   (Recinfo.bill_rate_unit =  X_Bill_Rate_Unit)
                OR (    (Recinfo.bill_rate_unit IS NULL)
                    AND (X_Bill_Rate_Unit IS NULL)))
           AND (   (Recinfo.markup_percentage =  X_Markup_Percentage)
                OR (    (Recinfo.markup_percentage IS NULL)
                    AND (X_Markup_Percentage IS NULL)))
           AND (   (Recinfo.end_date_active
                        =  X_End_Date_Active)
                OR (    (Recinfo.end_date_active IS NULL)
                    AND (X_End_Date_Active IS NULL)))
           AND (   (Recinfo.Rate_Currency_Code
		        =  X_Rate_Currency_Code)
		OR (    (Recinfo.Rate_Currency_Code IS NULL)
		    AND (X_Rate_Currency_Code IS NULL)))
	  AND (   (Recinfo.Resource_Class_Code
		        =  X_Resource_Class_Code)
		OR (    (Recinfo.Resource_Class_Code IS NULL)
		    AND (X_Resource_Class_Code IS NULL)))
           AND (   (Recinfo.Res_Class_Organization_Id
		        =  X_Res_Class_Organization_Id)
		OR (    (Recinfo.Res_Class_Organization_Id IS NULL)
		    AND (X_Res_Class_Organization_Id IS NULL)))

      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Bill_Rate_Organization_Id             NUMBER,
                       X_Std_Bill_Rate_Schedule                VARCHAR2,
                       X_Last_Update_Date                      DATE,
                       X_Last_Updated_By                       NUMBER,
                       X_Last_Update_Login                     NUMBER,
                       X_Start_Date_Active                     DATE,
                       X_Person_Id                             NUMBER,
                       X_Job_Id                                NUMBER,
                       X_Expenditure_Type                      VARCHAR2,
                       X_Non_Labor_Resource                    VARCHAR2,
                       X_Rate                                  NUMBER,
                       X_Bill_Rate_Unit                        VARCHAR2,
                       X_Markup_Percentage                     NUMBER,
                       X_End_Date_Active                       DATE,
                       X_job_group_id                          NUMBER,
		       X_Rate_Currency_Code                    VARCHAR2,
       		       X_Resource_Class_Code                   VARCHAR2,
		       X_Res_Class_Organization_Id	       NUMBER

  ) IS
  BEGIN
    UPDATE PA_BILL_RATES
    SET bill_rate_organization_id = X_Bill_Rate_Organization_Id,
	std_bill_rate_schedule = X_Std_Bill_Rate_Schedule,
	last_update_date = X_Last_Update_Date,
	last_updated_by = X_Last_Updated_By,
	last_update_login = X_Last_Update_Login,
	start_date_active = X_Start_Date_Active,
	person_id = X_Person_Id,
	job_id = X_Job_Id,
	expenditure_type = X_Expenditure_Type,
	non_labor_resource = X_Non_Labor_Resource,
	rate = X_Rate,
	bill_rate_unit = X_Bill_Rate_Unit,
	markup_percentage = X_Markup_Percentage,
	end_date_active = X_End_Date_Active,
        job_group_id  = X_job_group_id,
	Rate_Currency_Code = X_Rate_Currency_Code,
        Resource_Class_Code=X_Resource_Class_Code ,
	Res_Class_Organization_Id = X_Res_Class_Organization_Id
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PA_BILL_RATES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END PA_BILL_RATES_PKG;

/
