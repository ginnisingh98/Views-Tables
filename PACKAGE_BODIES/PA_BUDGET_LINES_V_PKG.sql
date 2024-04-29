--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_LINES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_LINES_V_PKG" as
--  $Header: PAXBUBLB.pls 120.3 2005/09/23 12:17:59 rnamburi noship $


--Name:                 Insert_Row
--Type:                 Procedure
--Description:
--
--Called Subprograms:   none.
--
--Notes
--        !!! This procedure can only be used with r11.5.7 Budgets. !!!
--
--        For similar functionality for FP plan types, FP specific procedures
--        must be called.
--
--        PA_BUDGET_UTILS.Get_Project_Currency_Info uses package
--        globals to optimize peformance. It also uses x_project_id
--        to determine when the globals should be refreshed.
--
--History
--      xx-xxx-xxxx     who?            - Created
--
--      16-AUG-02       jwhite          As per the FP model conversion effort, did the following:
--
--                                      1) Modidified the pa_resource_assignments insert to populte
--                                         resource_assignment_type as 'USER_ENTERED'.
--
--                                      2) Added a call to PA_BUDGET_UTILS.Get_Project_Currency_Info
--                                         to populate the following new currency columns:
--                                         - projfunc_currency_code
--                                         - project_currency_code
--                                         - txn_currency_code
--
--

  -- Bug Fix: 4569365. Removed MRC code.
  -- g_mrc_exception EXCEPTION;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       X_Resource_Assignment_Id  IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Budget_Version_Id              NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Resource_List_Member_Id        NUMBER,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Period_Name                    VARCHAR2,
                       X_Quantity                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Track_As_Labor_Flag            VARCHAR2,
                       X_Raw_Cost                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Burdened_Cost           IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Revenue                 IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Change_Reason_Code             VARCHAR2,
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
                       -- Bug Fix: 4569365. Removed MRC code.
                       -- x_mrc_flag                       VARCHAR2, /* FPB2: Added for MRC 20-Sep */
                       X_Calling_Process                VARCHAR2 DEFAULT 'PR',
                       X_Pm_Product_Code                VARCHAR2 DEFAULT NULL,
                       X_Pm_Budget_Line_Reference       VARCHAR2 DEFAULT NULL,
                       X_raw_cost_source                VARCHAR2 DEFAULT 'M',
                       X_burdened_cost_source           VARCHAR2 DEFAULT 'M',
                       X_quantity_source                VARCHAR2 DEFAULT 'M',
                       X_revenue_source                 VARCHAR2 DEFAULT 'M',
/*New parameters added on 16-mar-2001*/
                   x_standard_bill_rate          NUMBER  DEFAULT NULL,
                   x_average_bill_rate           NUMBER  DEFAULT NULL,
                   x_average_cost_rate           NUMBER  DEFAULT NULL,
                   x_project_assignment_id       NUMBER  DEFAULT -1,
                   x_plan_error_code             VARCHAR2  DEFAULT NULL,
                   x_total_plan_revenue          NUMBER  DEFAULT NULL,
                   x_total_plan_raw_cost         NUMBER  DEFAULT NULL,
                   x_total_plan_burdened_cost    NUMBER  DEFAULT NULL,
                   x_total_plan_quantity         NUMBER  DEFAULT NULL,
                   x_average_discount_percentage NUMBER  DEFAULT NULL,
                   x_cost_rejection_code         VARCHAR2  DEFAULT NULL,
                   x_burden_rejection_code       VARCHAR2  DEFAULT NULL,
                   x_revenue_rejection_code      VARCHAR2  DEFAULT NULL,
                   x_other_rejection_code        VARCHAR2  DEFAULT NULL,
                   X_Code_Combination_Id         NUMBER     DEFAULT NULL,
                   X_CCID_Gen_Status_Code        VARCHAR2   DEFAULT NULL,
                   X_CCID_Gen_Rej_Message        VARCHAR2   DEFAULT NULL
                 )

    IS

    CURSOR C IS SELECT rowid FROM pa_budget_lines
                 WHERE resource_assignment_id = X_Resource_Assignment_Id
                 AND   start_date = X_Start_Date;

    cursor get_budget_type_code is
    select budget_type_code
    from pa_budget_versions
    where budget_version_id = x_budget_version_id;

    same_uom number;
    p_quantity number;
    v_budget_type_code varchar2(30);
    v_budget_amount_code PA_BUDGET_TYPES.BUDGET_AMOUNT_CODE%TYPE;

    l_rows_inserted     NUMBER := 0;


    l_projfunc_currency_code   pa_budget_lines.projfunc_currency_code%TYPE := NULL;
    l_project_currency_code    pa_budget_lines.project_currency_code%TYPE  := NULL;
    l_txn_currency_code        pa_budget_lines.txn_currency_code%TYPE      := NULL;

    l_Return_Status            VARCHAR2(1)    :=NULL;
    l_Msg_Data                 VARCHAR2(2000) :=NULL;
    l_Msg_Count                NUMBER         := 0;

    l_budget_line_id           pa_budget_lines.budget_line_id%TYPE;

    nc_Rowid                     VARCHAR2(30);
    nc_Resource_Assignment_Id    NUMBER;
    nc_Quantity                  NUMBER;
    nc_Raw_Cost                  NUMBER;
    nc_Burdened_Cost             NUMBER;
    nc_Revenue                   NUMBER;

   BEGIN

     nc_Rowid := X_Rowid;
     nc_Resource_Assignment_Id := X_Resource_Assignment_Id;
     nc_Quantity := X_Quantity;
     nc_Raw_Cost := X_Raw_Cost;
     nc_Burdened_Cost := X_Burdened_Cost;
     nc_Revenue := X_Revenue;

      -- Bug Fix: 4569365. Removed MRC code.
     /* MRC */
     /*
     IF x_mrc_flag IS NULL THEN
       l_msg_data := 'x_mrc_flag cannot be null to table handler';
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     */

     open get_budget_type_code;
     fetch get_budget_type_code into v_budget_type_code;
     close get_budget_type_code;

-- 23-APR-98, jwhite ------------------------------------------------------
-- Added Begin/End block to capture duplicate rows for
-- pa_resource_assignments (removed previous
--  where-NOT-Exists code)
--
/* The following code is modified as first check for the resource_Assignment_id,
   If not exists then insert the record, by having the code like this the sequence
   pa_resource_assignments_s will not get incremented unnecessarily   23-MAR-2001 */

       BEGIN

        select resource_assignment_id
               into   x_resource_assignment_id
               from   pa_resource_assignments a
               where  a.budget_version_id = x_budget_version_id
               and    a.project_id = x_project_id
               and    nvl(a.task_id,0) = nvl(x_task_id,0)
               and    a.resource_list_member_id = x_resource_list_member_id
               and    a.project_assignment_id = x_project_assignment_id;

        l_rows_inserted :=  0;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN

         SELECT pa_resource_assignments_s.nextval
         INTO X_Resource_Assignment_Id
         FROM sys.dual;

          -- insert into pa_resource_assignments if necessary
       insert into pa_resource_assignments(
              resource_assignment_id,
              budget_version_id,
              project_id,
              task_id,
              resource_list_member_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              unit_of_measure,
              track_as_labor_flag,
/*Added 16-mar-2001 by N Gupta*/
              standard_bill_rate,
              average_bill_rate,
              average_cost_rate,
              project_assignment_id,
              plan_error_code,
              total_plan_revenue,
              total_plan_raw_cost,
              total_plan_burdened_cost,
              total_plan_quantity,
              average_discount_percentage,
              RESOURCE_ASSIGNMENT_TYPE
              )  VALUES (
                  X_Resource_Assignment_Id ,
                  x_budget_version_id,
                  x_project_id,
                  x_task_id,
                  x_resource_list_member_id,
                  SYSDATE,
                  x_last_updated_by,
                  SYSDATE,
                  x_created_by,
                  x_last_update_login,
                  x_unit_of_measure,
                  x_track_as_labor_flag,
/*Added 16-mar-2001 by N Gupta*/
                  x_standard_bill_rate,
                  x_average_bill_rate,
                  x_average_cost_rate,
                  x_project_assignment_id,
                  x_plan_error_code,
                  x_total_plan_revenue,
                  x_total_plan_raw_cost,
                  x_total_plan_burdened_cost,
                  x_total_plan_quantity,
                  x_average_discount_percentage,
                  'USER_ENTERED'
             );
       END;

       -- Get the resource assignment id IF PREVIOUS INSERT was
       -- NOT performed.
/*       IF (l_rows_inserted = 0)
        THEN
        select resource_assignment_id
               into   x_resource_assignment_id
               from   pa_resource_assignments a
               where  a.budget_version_id = x_budget_version_id
               and    a.project_id = x_project_id
               and    nvl(a.task_id,0) = nvl(x_task_id,0)
               and    a.resource_list_member_id = x_resource_list_member_id
               and    a.project_assignment_id = x_project_assignment_id;
       END IF;    */
-- -------------------------------------------------------------




       -- insert into budget lines

    -- Fix for Bugs # 475852 and 503183
    -- Copy raw cost into burdened cost if budrened cost is null.
    -- If the resource UOM is currency and raw cost is null then
    -- copy value of quantity amt into raw cost and also set quantity
    -- amt to null.

     /* Code modified for budget_amount_code for Forecasting changes  03/23/2001 */
     v_budget_amount_code := pa_budget_utils.get_budget_amount_code(v_budget_type_code);
     if v_budget_amount_code = 'C' then
        -- Cost Budget
       if pa_budget_utils.check_currency_uom(x_unit_of_measure) = 'Y' then
         if x_raw_cost is null then
           x_raw_cost := x_quantity;
          end if;
          x_quantity := null;
       end if;

       if  x_burdened_cost is null then
          x_burdened_cost := x_raw_cost;
       end if;

     elsif v_budget_amount_code = 'R'      then -- Revenue Budget
       if pa_budget_utils.check_currency_uom(x_unit_of_measure) = 'Y' then
         if x_revenue is null then
           x_revenue := x_quantity;
          end if;
          x_quantity := null;
       end if;
     end if;



        -- Get Project Currency Information for INSERT
        -- Note: This procedure uses package globals to effect one fecth per x_project_id.

        PA_BUDGET_UTILS.Get_Project_Currency_Info
             (
              p_project_id                      => x_project_id
              , x_projfunc_currency_code        => l_projfunc_currency_code
              , x_project_currency_code         => l_project_currency_code
              , x_txn_currency_code             => l_txn_currency_code
              , x_msg_count                     => l_msg_count
              , x_msg_data                      => l_msg_data
              , x_return_status                 => l_return_status
             );

        -- This table handler can't really handle public API error handling, but I will put it
        -- in any way with minimal exception coding and a RAISE.

        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
           THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          ELSIF (l_return_status = FND_API.G_RET_STS_ERROR)
            THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

       SELECT pa_budget_lines_s.nextval
         INTO l_budget_line_id
         FROM DUAL;

       INSERT INTO pa_budget_lines(
              budget_line_id,                   /* FPB2 */
              budget_version_id,                /* FPB2 */
              resource_assignment_id,
              start_date,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              end_date,
              period_name,
              quantity,
              raw_cost,
              burdened_cost,
              revenue,
              change_reason_code,
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
              pm_product_code,
              pm_budget_line_reference,
              raw_cost_source,
              burdened_cost_source,
              quantity_source,
              revenue_source,
/*Added 16-mar-2001 By N gupta*/
              COST_REJECTION_CODE,
              BURDEN_REJECTION_CODE,
              REVENUE_REJECTION_CODE,
              OTHER_REJECTION_CODE,
              Code_Combination_Id,
              CCID_Gen_Status_Code,
              CCID_Gen_Rej_Message,
              projfunc_currency_code,
              project_currency_code,
              txn_currency_code
             ) VALUES (
              l_budget_line_id,             /* FPB2 */
              x_budget_version_id,          /* FPB2 */
              X_Resource_Assignment_Id,
              X_Start_Date,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_End_Date,
              X_Period_Name,
              (X_Quantity),
              pa_currency.round_currency_amt(X_Raw_Cost),
              pa_currency.round_currency_amt(X_Burdened_Cost),
              pa_currency.round_currency_amt(X_Revenue),
              X_Change_Reason_Code,
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
              X_Pm_Product_Code,
              X_Pm_Budget_Line_Reference,
              X_raw_cost_source,
              X_burdened_cost_source,
              X_quantity_source ,
              X_revenue_source ,
/*Added 16-mar-2001 By N gupta*/
                x_cost_rejection_code,
                x_burden_rejection_code,
                x_revenue_rejection_code,
                x_other_rejection_code,
              X_Code_Combination_Id,
              X_CCID_Gen_Status_Code,
              X_CCID_Gen_Rej_Message,
              l_projfunc_currency_code,
              l_project_currency_code,
              l_txn_currency_code
             );


         -- Bug Fix: 4569365. Removed MRC code.
        /* FPB2: MRC */
        /*
             IF x_mrc_flag = 'Y' THEN

                IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
                       PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                                 (x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data);
                END IF;

                IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
                   PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
                   PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
                                         (p_budget_line_id => l_budget_line_id,
                                          p_budget_version_id => x_budget_version_id,
                                          p_action         => PA_MRC_FINPLAN.G_ACTION_INSERT,
                                          x_return_status  => l_return_status,
                                          x_msg_count      => l_msg_count,
                                          x_msg_data       => l_msg_data);
                END IF;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE g_mrc_exception;
                END IF;

             END IF;
          */

       -- update pa_budget_versions
       -- Update pa_budget_versions only if the denormalized totals are
       -- not being maintained in the form. Example the Copy Actual
       -- process.

     if X_Calling_Process = 'PR' then
       update pa_budget_versions
       set    raw_cost = pa_currency.round_currency_amt(nvl(raw_cost,0) + nvl(x_raw_cost,0)),
              burdened_cost = pa_currency.round_currency_amt(nvl(burdened_cost,0) + nvl(x_burdened_cost,0) ),
              revenue = pa_currency.round_currency_amt(nvl(revenue,0) + nvl(x_revenue,0) ),
              labor_quantity =
                (to_number(decode(x_track_as_labor_flag,
                                 'Y', nvl(labor_quantity,0) + nvl(x_quantity,0),
                                 nvl(labor_quantity,0)))),
              labor_unit_of_measure =
                decode(x_track_as_labor_flag, 'Y', x_unit_of_measure,
                       labor_unit_of_measure),
              last_update_date = x_last_update_date,
              last_update_login = x_last_update_login,
              last_updated_by = x_last_updated_by
       where  budget_version_id = x_budget_version_id;
    end if;

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;


   -- This EXCEPTION is coded here for the PA_BUDGET_UTILS.Get_Project_Currency_Info call.
   -- Since the table handler was not designed for this kind of thing, the public API
   -- error-handling OUT-parameters are not populated.

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg
                        (  p_pkg_name           => 'PA_BUDGET_LINES_V_PKG'
                        ,  p_procedure_name     => 'INSERT_ROW'
                        ,  p_error_text         =>  l_msg_data || ' ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                                            );
        IF c%ISOPEN THEN /* Bug# 2628072 */
          CLOSE C;
        END IF;
        RAISE;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg
                        (  p_pkg_name           => 'PA_BUDGET_LINES_V_PKG'
                        ,  p_procedure_name     => 'INSERT_ROW'
                        ,  p_error_text         => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                        );
        IF c%ISOPEN THEN /* Bug# 2628072 */
          CLOSE C;
        END IF;
        RAISE;
	 WHEN OTHERS
	  THEN
	    nc_Rowid := X_Rowid;
	    nc_Resource_Assignment_Id := X_Resource_Assignment_Id;
	    nc_Quantity := X_Quantity;
	    nc_Raw_Cost := X_Raw_Cost;
	    nc_Burdened_Cost := X_Burdened_Cost;
	    nc_Revenue := X_Revenue;
        RAISE;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Resource_Assignment_Id           NUMBER,
                     X_Budget_Version_Id                NUMBER,
                     X_Project_Id                       NUMBER,
                     X_Task_Id                          NUMBER,
                     X_Resource_List_Member_Id          NUMBER,
                     X_Description                      VARCHAR2,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
                     X_Period_Name                      VARCHAR2,
                     X_Quantity                         NUMBER,
                     X_Unit_Of_Measure                  VARCHAR2,
                     X_Track_As_Labor_Flag              VARCHAR2,
                     X_Raw_Cost                         NUMBER,
                     X_Burdened_Cost                    NUMBER,
                     X_Revenue                          NUMBER,
                     X_Change_Reason_Code               VARCHAR2,
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
                     X_Attribute15                      VARCHAR2
  ) IS
    CURSOR C IS
        SELECT l.resource_assignment_id,
               l.start_date,
               l.end_date,
               l.period_name,
               l.quantity,
               l.raw_cost,
               l.burdened_cost,
               l.revenue,
               l.change_reason_code,
               l.description,
               l.attribute_category,
               l.attribute1,
               l.attribute2,
               l.attribute3,
               l.attribute4,
               l.attribute5,
               l.attribute6,
               l.attribute7,
               l.attribute8,
               l.attribute9,
               l.attribute10,
               l.attribute11,
               l.attribute12,
               l.attribute13,
               l.attribute14,
               l.attribute15,
               a.budget_version_id,
               a.project_id,
               a.task_id,
               a.resource_list_member_id,
               a.unit_of_measure,
               a.track_as_labor_flag
        FROM   pa_resource_assignments a,
               pa_budget_lines l
        WHERE  l.rowid = X_Rowid
        AND    l.resource_assignment_id = a.resource_assignment_id
        FOR UPDATE NOWAIT;
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
               (Recinfo.resource_assignment_id =  X_Resource_Assignment_Id)
           AND (Recinfo.budget_version_id =  X_Budget_Version_Id)
           AND (Recinfo.project_id =  X_Project_Id)
           AND (   (Recinfo.task_id =  X_task_Id)
                OR (    (Recinfo.task_id IS NULL)
                    AND (X_Task_Id IS NULL)))
           AND (Recinfo.resource_list_member_id =  X_Resource_List_Member_Id)
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (Recinfo.start_date =  X_Start_Date)
           AND (Recinfo.end_date =  X_End_Date)
           AND (   (Recinfo.period_name =  X_Period_Name)
                OR (    (Recinfo.period_name IS NULL)
                    AND (X_Period_Name IS NULL)))
           AND (   (Recinfo.quantity =  X_Quantity)
                OR (    (Recinfo.quantity IS NULL)
                    AND (X_Quantity IS NULL)))
           AND (   (Recinfo.unit_of_measure =  X_Unit_Of_Measure)
                OR (    (Recinfo.unit_of_measure IS NULL)
                    AND (X_Unit_Of_Measure IS NULL)))
           AND (   (Recinfo.track_as_labor_flag =  X_track_as_labor_flag)
                OR (    (Recinfo.track_as_labor_flag IS NULL)
                    AND (X_track_as_labor_flag IS NULL)))
           AND (   (Recinfo.raw_cost =  X_Raw_Cost)
                OR (    (Recinfo.raw_cost IS NULL)
                    AND (X_Raw_Cost IS NULL)))
           AND (   (Recinfo.burdened_cost =  X_Burdened_Cost)
                OR (    (Recinfo.burdened_cost IS NULL)
                    AND (X_Burdened_Cost IS NULL)))
           AND (   (Recinfo.revenue =  X_Revenue)
                OR (    (Recinfo.revenue IS NULL)
                    AND (X_Revenue IS NULL)))
           AND (   (Recinfo.change_reason_code =  X_Change_Reason_Code)
                OR (    (Recinfo.change_reason_code IS NULL)
                    AND (X_Change_Reason_Code IS NULL)))
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
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

--Name:                 Update_Row
--Type:                 Procedure
--Description:
--
--Called Subprograms:   none.
--
--Notes
--        !!! This procedure can only be used with r11.5.7 Budgets. !!!
--
--        For similar functionality for FP plan types, FP specific procedures
--        must be called.
--
--        PA_BUDGET_UTILS.Get_Project_Currency_Info uses package
--        globals to optimize peformance. It also uses x_project_id
--        to determine when the globals should be refreshed.
--
--History
--      xx-xxx-xxxx     who?            - Created
--
--      16-AUG-02       jwhite          As per the FP model conversion effort, did the following:
--
--                                      1) Added a call to PA_BUDGET_UTILS.Get_Project_Currency_Info
--                                         to populate the following new currency columns:
--                                         - projfunc_currency_code
--                                         - project_currency_code
--                                         - txn_currency_code
--
--      17-SEP-02       jwhite          Removed unnecessary update of currency info. Of course, when
--                                      a budget line is deleted and then re-inserted, the Insert procedure
--                                      will populate the currency code columns.
--
--

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Resource_Assignment_Id         NUMBER,
                       X_Budget_Version_Id              NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Resource_List_Member_Id        NUMBER,
                       X_Resource_Id                    NUMBER,
                       X_Resource_Id_Old                NUMBER,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Period_Name                    VARCHAR2,
                       X_Quantity               IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Quantity_Old           IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Track_As_Labor_Flag            VARCHAR2,
                       X_Raw_Cost               IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Raw_Cost_Old           IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Burdened_Cost          IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Burdened_Cost_Old      IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Revenue                IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Revenue_Old            IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       X_Change_Reason_Code             VARCHAR2,
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
                       -- Bug Fix: 4569365. Removed MRC code.
                       -- X_MRC_Flag                       VARCHAR2, /* FPB2: Added for MRC */
                       X_Calling_Process                VARCHAR2 DEFAULT 'PR',
                       X_raw_cost_source                VARCHAR2 DEFAULT 'M',
                       X_burdened_cost_source           VARCHAR2 DEFAULT 'M',
                       X_quantity_source                VARCHAR2 DEFAULT 'M',
                       X_revenue_source                 VARCHAR2 DEFAULT 'M',
/*Added following 13 columns on 16-mar-2001*/
                   x_standard_bill_rate          NUMBER  DEFAULT NULL,
                   x_average_bill_rate           NUMBER  DEFAULT NULL,
                   x_average_cost_rate           NUMBER  DEFAULT NULL,
                   x_project_assignment_id       NUMBER  DEFAULT NULL,
                   x_plan_error_code             VARCHAR2  DEFAULT NULL,
                   x_total_plan_revenue          NUMBER  DEFAULT NULL,
                   x_total_plan_raw_cost         NUMBER  DEFAULT NULL,
                   x_total_plan_burdened_cost    NUMBER  DEFAULT NULL,
                   x_total_plan_quantity         NUMBER  DEFAULT NULL,
                   x_average_discount_percentage NUMBER  DEFAULT NULL,
                   x_cost_rejection_code         VARCHAR2  DEFAULT NULL,
                   x_burden_rejection_code       VARCHAR2  DEFAULT NULL,
                   x_revenue_rejection_code      VARCHAR2  DEFAULT NULL,
                   x_other_rejection_code        VARCHAR2  DEFAULT NULL,
                   X_Code_Combination_Id         NUMBER     DEFAULT NULL,
                   X_CCID_Gen_Status_Code        VARCHAR2   DEFAULT NULL,
                   X_CCID_Gen_Rej_Message        VARCHAR2   DEFAULT NULL
  ) IS
     created_by number;
     last_updated_by number;
     last_update_login number;
     res_assignment_id number;
     new_rowid varchar2(18);
     v_budget_type_code varchar2(30);

    cursor get_budget_type_code is
    select budget_type_code
    from pa_budget_versions
    where budget_version_id = x_budget_version_id;


    l_Return_Status            VARCHAR2(1)    :=NULL;
    l_Msg_Data                 VARCHAR2(2000) :=NULL;
    l_Msg_Count                NUMBER         := 0;

    l_budget_line_id           PA_BUDGET_LINES.BUDGET_LINE_ID%TYPE;     /* FPB2 */

  BEGIN
    -- Bug Fix: 4569365. Removed MRC code.
    /* FPB2: MRC */
    /*
    IF x_mrc_flag IS NULL THEN
      l_msg_data := 'x_mrc_flag cannot be null to table handler';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    */

    open get_budget_type_code;
    fetch get_budget_type_code into v_budget_type_code;
    close get_budget_type_code;

    created_by := fnd_global.user_id;
    last_updated_by := fnd_global.user_id;
    last_update_login := fnd_global.login_id;

    if (x_resource_id <> x_resource_id_old) then
       -- delete the orignial one, and insert a new one
       pa_budget_lines_v_pkg.delete_row(x_rowid           => x_rowid,
                                        x_calling_process => x_calling_process
										--,
										-- Bug Fix: 4569365. Removed MRC code.
                                        -- x_mrc_flag        => x_mrc_flag     /* FPB2: for MRC */
                                        );

       pa_budget_lines_v_pkg.insert_row(
                       X_Rowid => new_rowid,
                       X_Resource_Assignment_Id => res_assignment_id,
                       X_Budget_Version_Id => X_Budget_Version_Id,
                       X_Project_Id => X_Project_Id,
                       X_Task_Id => X_Task_Id,
                       X_Resource_List_Member_Id => X_Resource_List_Member_Id,
                       X_Description => X_Description,
                       X_Start_Date => X_Start_Date,
                       X_End_Date => X_End_Date,
                       X_Period_Name => X_Period_Name,
                       X_Quantity => X_Quantity,
                       X_Unit_Of_Measure => X_Unit_Of_Measure,
                       X_Track_As_Labor_Flag => X_Track_As_Labor_Flag,
                       X_Raw_Cost => X_Raw_Cost,
                       X_Burdened_Cost => X_Burdened_Cost,
                       X_Revenue => X_Revenue,
                       X_Change_Reason_Code => X_Change_Reason_Code,
                       x_last_update_date => SYSDATE,
                       X_Last_Updated_by => Last_Updated_By,
                       x_creation_date => SYSDATE,
                       X_Created_By => Created_By,
                       X_Last_Update_Login => Last_Update_Login,
                       X_Attribute_Category => X_Attribute_Category,
                       X_Attribute1 => X_Attribute1,
                       X_Attribute2 => X_Attribute2,
                       X_Attribute3 => X_Attribute3,
                       X_Attribute4 => X_Attribute4,
                       X_Attribute5 => X_Attribute5,
                       X_Attribute6 => X_Attribute6,
                       X_Attribute7 => X_Attribute7,
                       X_Attribute8 => X_Attribute8,
                       X_Attribute9 => X_Attribute9,
                       X_Attribute10 => X_Attribute10,
                       X_Attribute11 => X_Attribute11,
                       X_Attribute12 => X_Attribute12,
                       X_Attribute13 => X_Attribute13,
                       X_Attribute14 => X_Attribute14,
                       X_Attribute15 => X_Attribute15,
                       X_Calling_Process => X_Calling_Process,
                       X_raw_cost_source => X_raw_cost_source,
                       X_burdened_cost_source => X_burdened_cost_source,
                       X_quantity_source => X_quantity_source ,
                       X_revenue_source => X_revenue_source,
                       X_Code_Combination_Id   => X_Code_Combination_Id,
                       X_CCID_Gen_Status_Code  => X_CCID_Gen_Status_Code,
                       X_CCID_Gen_Rej_Message  => X_CCID_Gen_Rej_Message
					   --,
					   -- Bug Fix: 4569365. Removed MRC code.
                       -- X_mrc_flag              => X_mrc_flag /* FPB2: Added x_mrc_flag for MRC changes. Pass same as input */
                       );

    else
       -- resource is not changed

    -- Fix for Bugs # 475852 and 503183
    -- Copy raw cost into burdened cost if budrened cost is null.
    -- If the resource UOM is currency and raw cost is null then
    -- copy value of quantity amt into raw cost and also set quantity
    -- amt to null.

     if pa_budget_utils.get_budget_amount_code(v_budget_type_code) = 'C' then
        -- Cost Budget

       if pa_budget_utils.check_currency_uom(x_unit_of_measure) = 'Y' then
         if x_raw_cost is null then
           x_raw_cost := x_quantity;
          end if;
          x_quantity := null;
       end if;

       if  x_burdened_cost is null then
          x_burdened_cost := x_raw_cost;
       end if;

     else -- Revenue Budget
       if pa_budget_utils.check_currency_uom(x_unit_of_measure) = 'Y' then
         if x_revenue is null then
           x_revenue := x_quantity;
          end if;
          x_quantity := null;
       end if;
     end if;



       UPDATE pa_budget_lines
       SET
          resource_assignment_id          =     X_Resource_Assignment_Id,
          start_date                      =     X_Start_Date,
          last_update_date                =     X_Last_Update_Date,
          last_updated_by                 =     X_Last_Updated_By,
          last_update_login               =     X_Last_Update_Login,
          end_date                        =     X_End_Date,
          period_name                     =     X_Period_Name,
          quantity                        =     (X_Quantity),
          raw_cost                        =     pa_currency.round_currency_amt(X_Raw_Cost),
          burdened_cost                   =     pa_currency.round_currency_amt(X_Burdened_Cost),
          revenue                         =     pa_currency.round_currency_amt(X_Revenue),
          change_reason_code              =     X_Change_Reason_Code,
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
          raw_cost_source                 =     X_raw_cost_source,
          burdened_cost_source            =     X_burdened_cost_source,
          quantity_source                 =     X_quantity_source,
          revenue_source                  =     X_revenue_source,
/*added 16-mar-2001 by N Gupta*/
          COST_REJECTION_CODE   = DECODE(X_COST_REJECTION_CODE, NULL, COST_REJECTION_CODE, X_COST_REJECTION_CODE),
          BURDEN_REJECTION_CODE= DECODE(X_BURDEN_REJECTION_CODE, NULL, BURDEN_REJECTION_CODE, X_BURDEN_REJECTION_CODE),
          REVENUE_REJECTION_CODE=DECODE(X_REVENUE_REJECTION_CODE, NULL, REVENUE_REJECTION_CODE, X_REVENUE_REJECTION_CODE),
          OTHER_REJECTION_CODE=DECODE(X_OTHER_REJECTION_CODE, NULL, OTHER_REJECTION_CODE, X_OTHER_REJECTION_CODE),
          Code_Combination_Id             =     X_Code_Combination_Id,
          CCID_Gen_Status_Code            =     X_CCID_Gen_Status_Code,
          CCID_Gen_Rej_Message            =     X_CCID_Gen_Rej_Message
       WHERE rowid = X_Rowid
       RETURNING budget_line_id INTO l_budget_line_id;

       -- update the project budget

        -- Bug Fix: 4569365. Removed MRC code.
       /* FPB2: MRC */
       /*
       IF x_mrc_flag = 'Y' THEN
          IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
                 PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                           (x_return_status      => l_return_status,
                            x_msg_count          => l_msg_count,
                            x_msg_data           => l_msg_data);
          END IF;

          IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
             PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
               PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
                          (p_budget_line_id => l_budget_line_id,
                           p_budget_version_id => x_budget_version_id,
                           p_action         => PA_MRC_FINPLAN.G_ACTION_UPDATE,
                           x_return_status  => l_return_status,
                           x_msg_count      => l_msg_count,
                           x_msg_data       => l_msg_data);
          END IF;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE  g_mrc_exception;
          END IF;

       END IF;
       */

       if (   (nvl(x_quantity,0) <> nvl(x_quantity_old,0))
           or (nvl(x_raw_cost,0) <> nvl(x_raw_cost_old,0))
           or (nvl(x_burdened_cost,0) <> nvl(x_burdened_cost_old,0))
           or (nvl(x_revenue,0) <> nvl(x_revenue_old,0))) then

       -- Update pa_budget_versions only if the denormalized totals are
       -- not being maintained in the form. Example the Copy Actual
       -- process.

         if X_Calling_Process = 'PR' then
           update pa_budget_versions
           set    labor_quantity = (to_number(
                                decode(x_track_as_labor_flag,
                                   'Y', nvl(labor_quantity,0)
                                        - nvl(x_quantity_old,0)
                                        + nvl(x_quantity,0),
                                   nvl(labor_quantity,0))) ),
                  raw_cost = pa_currency.round_currency_amt(nvl(raw_cost,0) - nvl(x_raw_cost_old,0)
                                      + nvl(x_raw_cost,0) ),
                  burdened_cost = pa_currency.round_currency_amt(nvl(burdened_cost,0)
                                      - nvl(x_burdened_cost_old,0)
                                      + nvl(x_burdened_cost,0) ),
                  revenue = pa_currency.round_currency_amt(nvl(revenue,0) - nvl(x_revenue_old,0)
                                    + nvl(x_revenue,0) )
           where  budget_version_id = x_budget_version_id;

            if (SQL%NOTFOUND) then
              Raise NO_DATA_FOUND;
            end if;
         end if;

       end if;

    end if;

   -- This EXCEPTION is coded here for the Insert Procedure call.
   -- Since the table handler was not designed for this kind of thing, the public API
   -- error-handling OUT-parameters are not populated.

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg
                        (  p_pkg_name           => 'PA_BUDGET_LINES_V_PKG'
                        ,  p_procedure_name     => 'UPDATE_ROW'
                        ,  p_error_text         => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                                            );
        RAISE;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg
                        (  p_pkg_name           => 'PA_BUDGET_LINES_V_PKG'
                        ,  p_procedure_name     => 'UPDATE_ROW'
                        ,  p_error_text         => 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                                            );
        RAISE;


  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                       -- Bug Fix: 4569365. Removed MRC code.
                       -- X_mrc_flag        VARCHAR2  ,
                       X_Calling_Process VARCHAR2 DEFAULT 'PR'
) IS

     x_raw_cost number;
     x_burdened_cost number;
     x_revenue number;
     x_quantity number;
     x_resource_assignment_id number;
     x_track_as_labor_flag varchar2(2);
     x_budget_version_id number;
     x_last_updated_by number;
     x_last_update_login number;

    l_Return_Status            VARCHAR2(1)    :=NULL;
    l_Msg_Data                 VARCHAR2(2000) :=NULL;
    l_Msg_Count                NUMBER         := 0;
    -- Bug Fix: 4569365. Removed MRC code.
    -- l_budget_line_id           PA_BUDGET_LINES.BUDGET_LINE_ID%TYPE;     /* MRC */


  BEGIN
     -- Bug Fix: 4569365. Removed MRC code.
     /* FPB2: MRC */
     /*
    IF x_mrc_flag IS NULL THEN
       l_msg_data := 'x_mrc_flag cannot be null to table handler';
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    */
    select l.raw_cost,
           l.burdened_cost,
           l.revenue,
           l.quantity,
           l.resource_assignment_id,
           a.track_as_labor_flag
    into   x_raw_cost,
           x_burdened_cost,
           x_revenue,
           x_quantity,
           x_resource_assignment_id,
           x_track_as_labor_flag
    from   pa_resource_assignments a,
           pa_budget_lines l
    where  l.rowid = X_Rowid
    and    l.resource_assignment_id = a.resource_assignment_id;

    DELETE FROM pa_budget_lines
    WHERE rowid = X_Rowid;
    -- Bug Fix: 4569365. Removed MRC code.
    -- RETURNING budget_line_id INTO l_budget_line_id ;    /* FPB2 */

    x_last_updated_by := fnd_global.user_id;
    x_last_update_login := fnd_global.login_id;

    select budget_version_id
    into   x_budget_version_id
    from   pa_resource_assignments
    where  resource_assignment_id = x_resource_assignment_id;

    -- clean up pa_resource_assignments if necessary
    delete pa_resource_assignments
    where  resource_assignment_id = x_resource_assignment_id
    and    not exists
               (select 1
                from   pa_budget_lines
                where  resource_assignment_id = x_resource_assignment_id);

       -- Update pa_budget_versions only if the denormalized totals are
       -- not being maintained in the form. Example the Copy Actual
       -- process.

   if X_Calling_Process = 'PR' then
     update pa_budget_versions
     set    raw_cost = pa_currency.round_currency_amt(nvl(raw_cost,0) - nvl(x_raw_cost,0) ),
           burdened_cost = pa_currency.round_currency_amt(nvl(burdened_cost,0) - nvl(x_burdened_cost,0) ),
           revenue = pa_currency.round_currency_amt(nvl(revenue,0) - nvl(x_revenue,0) ),
           labor_quantity = (to_number(
                              decode(x_track_as_labor_flag,
                                 'Y', nvl(labor_quantity,0) - nvl(x_quantity,0),
                                  nvl(labor_quantity,0))) ),
           last_update_date = SYSDATE,
           last_update_login = x_last_update_login,
           last_updated_by = x_last_updated_by
     where  budget_version_id = x_budget_version_id;

            if (SQL%NOTFOUND) then
              Raise NO_DATA_FOUND;
            end if;
   end if;

-- Bug Fix: 4569365. Removed MRC code.
   /* MRC */
   /*
   IF x_mrc_flag = 'Y' THEN
      IF PA_MRC_FINPLAN. G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
             PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                       (x_return_status      => l_return_status,
                        x_msg_count          => l_msg_count,
                        x_msg_data           => l_msg_data);
      END IF;

      IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
         PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
           PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
                      (p_budget_line_id => l_budget_line_id,
                       p_budget_version_id => x_budget_version_id,
                       p_action         => PA_MRC_FINPLAN.G_ACTION_DELETE,
                       x_return_status  => l_return_status,
                       x_msg_count      => l_msg_count,
                       x_msg_data       => l_msg_data);
      END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE g_mrc_exception;
      END IF;

   END IF;
   */

  END Delete_Row;



Procedure check_overlapping_dates ( X_Budget_Version_Id          NUMBER,
                                       x_resource_name    IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_err_code         IN OUT NOCOPY NUMBER) is --File.Sql.39 bug 4440895

  v_temp       varchar2(1);
  v_res_assignment_id  PA_RESOURCE_ASSIGNMENTS.resource_assignment_id%TYPE;   -- Added for bug 3777706
  cursor c is
 /*   commented for bug 3777706 and included modified query.
      Modified the query to be based on pa_budget_lines table to
      instead of pa_budget_lines_v, as pa_budget_lines_v is based
      on pa_budget_lines as well as lookup tables, leading to unnecessary
      access of lookup tables which is not required in this case
 select a.resource_name
  from pa_budget_lines_v a, pa_budget_lines_v b
  where a.budget_version_id = x_budget_version_id
  and   b.budget_version_id = x_budget_version_id
  and   a.task_id||null     = b.task_id||null
  and   a.resource_list_member_id = b.resource_list_member_id
  and   a.row_id <> b.row_id
  and ((a.start_date
        between b.start_date
        and nvl(b.end_date,a.start_date +1))
  or   (a.end_date
        between b.start_date
        and nvl(b.end_date,b.end_date+1))
  or   (b.start_date
        between a.start_date
        and nvl(a.end_date,b.start_date+1))
      ); */
-- start of modified query  bug 3777706
select  I1.resource_assignment_id
  from
  PA_BUDGET_LINES I1,
  PA_BUDGET_LINES I2
  where
       I1.budget_version_id = x_budget_version_id
  and  I2.budget_version_id = x_budget_version_id
  and  I1.resource_assignment_id = I2.resource_assignment_id
  and  I1.txn_currency_code = I2.txn_currency_code
  and  I1.rowid <> I2.rowid
  and ((I1.start_date
        between I2.start_date and I2.end_date)
  or  (I1.end_date
        between I2.start_date and I2.end_date)
  or  (I2.start_date
        between I1.start_date and I1.end_date))
  and (I1.txn_currency_code = I2.txn_currency_code or I1.txn_currency_code is null and I2.txn_currency_code is null);
-- end of modified query bug 3777706
BEGIN
  open c;
  fetch c into v_res_assignment_id;  -- changed x_resource_name to v_res_assignment_id
  if c%found then
    -- start of bug 3777706
    select SUBSTRB(pa_resources_pkg.get_resource_name(M1.RESOURCE_ID, M1.RESOURCE_TYPE_ID),1,30) resource_name
    into x_resource_name
    from PA_RESOURCE_LIST_MEMBERS M1,
         PA_RESOURCE_ASSIGNMENTS ra
    where
        ra.resource_assignment_id = v_res_assignment_id and
        ra.resource_list_member_id = M1.resource_list_member_id;
    -- end of bug 3777706
    x_err_code :=1;
  else
    x_err_code :=0;
  end if;
  close c;
EXCEPTION
  when others then
    x_err_code :=sqlcode;
END check_overlapping_dates;

END PA_BUDGET_LINES_V_PKG;

/
