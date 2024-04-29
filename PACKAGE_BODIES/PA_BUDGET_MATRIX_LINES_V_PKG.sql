--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_MATRIX_LINES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_MATRIX_LINES_V_PKG" as
--  $Header: PAXBUMLB.pls 120.1 2005/09/30 10:10:04 rnamburi noship $

-- Bug Fix: 4569365. Removed MRC code.
-- g_mrc_exception EXCEPTION; /* FPB2: MRC */

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Resource_Assignment_Id         NUMBER,
                       X_Budget_Version_Id              NUMBER,
                       X_Project_Id                     NUMBER,
                       X_Task_Id                        NUMBER,
                       X_Resource_List_Member_Id        NUMBER,
                       X_Resource_Id                    NUMBER,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Period_Name                    VARCHAR2,
                       X_Quantity                       NUMBER,
                       X_Unit_Of_Measure                VARCHAR2,
                       X_Track_As_Labor_Flag            VARCHAR2,
                       X_Raw_Cost                       NUMBER,
                       X_Burdened_Cost                  NUMBER,
                       X_Revenue                        NUMBER,
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
                       X_Calling_Process                VARCHAR2 DEFAULT 'PR',
                       X_amt_type                       VARCHAR2,
                       X_raw_cost_source                VARCHAR2 DEFAULT 'M',
		       X_burdened_cost_source           VARCHAR2 DEFAULT 'M',
		       X_quantity_source                VARCHAR2 DEFAULT 'M',
		       X_revenue_source                 VARCHAR2 DEFAULT 'M'
		       -- Bug Fix: 4569365. Removed MRC code.
			   -- ,X_mrc_flag                       VARCHAR2 /* FPB2: MRC */

  ) IS
     created_by number;
     last_updated_by number;
     last_update_login number;
     res_assignment_id number;
     new_rowid varchar2(18);


     /* FPB2: MRC */
     l_budget_line_id PA_BUDGET_LINES.BUDGET_LINE_ID%type;
     l_return_status  VARCHAR2(1);
     l_msg_data       VARCHAR2(2000);
     l_msg_count      NUMBER;

  BEGIN

    created_by := fnd_global.user_id;
    last_updated_by := fnd_global.user_id;
    last_update_login := fnd_global.login_id;

     -- Bug Fix: 4569365. Removed MRC code.
     /* FPB2: MRC */
     /*
     IF x_mrc_flag IS NULL THEN
       l_msg_data := 'x_mrc_flag cannot be null to table handler';
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     */

       UPDATE pa_budget_lines
       SET
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
	  raw_cost_source                 =     decode(x_amt_type,'RC',X_raw_cost_source,raw_cost_source),
	  burdened_cost_source            =     decode(x_amt_type,'BC',X_burdened_cost_source,burdened_cost_source),
	  quantity_source                 =     decode(x_amt_type,'QU',X_quantity_source,quantity_source),
	  revenue_source                  =     decode(x_amt_type,'RE',X_revenue_source,revenue_source)
       WHERE rowid = X_Rowid
       returning budget_line_id into l_budget_line_id;

       if (SQL%NOTFOUND) then
	 Raise NO_DATA_FOUND;
       end if;


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
            RAISE g_mrc_exception;
          END IF;

       END IF;
       */

       l_budget_line_id := Null; /* Since even if delete doesnt delete any rows, the value in
                                    l_budget_line_id will be retained. */

       DELETE FROM pa_budget_lines
       WHERE rowid = X_Rowid
       and  ((quantity is null) and (raw_cost is null) and (burdened_cost is null) and (revenue is null))
       returning budget_line_id into l_budget_line_id;

       -- Bug Fix: 4569365. Removed MRC code.
       /* MRC */ /* Delete the mc_budget_line if the above delete was successful */
       /*
       IF l_budget_line_id IS NOT NULL AND x_mrc_flag = 'Y' THEN
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

       -- clean up pa_resource_assignments if necessary
       delete pa_resource_assignments
       where  resource_assignment_id = x_resource_assignment_id
       and    not exists
		  (select 1
		   from   pa_budget_lines
		   where  resource_assignment_id = x_resource_assignment_id);


  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                       X_Calling_Process VARCHAR2 DEFAULT 'PR',
                       X_amt_type VARCHAR2
					   -- Bug Fix: 4569365. Removed MRC code.
					   --,X_mrc_flag VARCHAR2 /* FPB2: MRC */
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

     /* FPB2: MRC */
     l_budget_line_id PA_BUDGET_LINES.BUDGET_LINE_ID%type;
     l_budget_version_id PA_BUDGET_LINES.BUDGET_VERSION_ID%type;
     l_return_status  VARCHAR2(1);
     l_msg_data       VARCHAR2(2000);
     l_msg_count      NUMBER;

  BEGIN

    x_last_updated_by := fnd_global.user_id;
    x_last_update_login := fnd_global.login_id;
    -- Bug Fix: 4569365. Removed MRC code.
     /* FPB2: MRC */
     /*
     IF x_mrc_flag IS NULL THEN
       l_msg_data := 'x_mrc_flag cannot be null to table handler';
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     */

       UPDATE pa_budget_lines
       SET
          last_update_date                =     sysdate,
          last_updated_by                 =     X_Last_Updated_By,
          last_update_login               =     X_Last_Update_Login,
          quantity                        =     decode(x_amt_type,'QU',null,quantity),
          raw_cost                        =     pa_currency.round_currency_amt(decode(x_amt_type,'RC',null,raw_cost)),
          burdened_cost                   =     pa_currency.round_currency_amt(decode(x_amt_type,'BC',null,burdened_cost)),
          revenue                         =     pa_currency.round_currency_amt(decode(x_amt_type,'RE',null,revenue))
       WHERE rowid = X_Rowid
       RETURNING budget_line_id, budget_version_id into l_budget_line_id,l_budget_version_id;

	    if (SQL%NOTFOUND) then
	      Raise NO_DATA_FOUND;
	    end if;
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
                           p_budget_version_id => l_budget_version_id,
                           p_action         => PA_MRC_FINPLAN.G_ACTION_UPDATE,
                           x_return_status  => l_return_status,
                           x_msg_count      => l_msg_count,
                           x_msg_data       => l_msg_data);
          END IF;

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE g_mrc_exception;
           END IF;

       END IF;
       */

    select resource_assignment_id
    into   x_resource_assignment_id
    from   pa_budget_lines
    WHERE rowid = X_Rowid;

    DELETE FROM pa_budget_lines
    WHERE rowid = X_Rowid
    and  ((quantity is null) and (raw_cost is null) and (burdened_cost is null) and (revenue is null))
    returning budget_line_id into l_budget_line_id;

    -- Bug Fix: 4569365. Removed MRC code.
       /* FPB2: MRC */ /* Delete the mc_budget_line if the above delete was successful */
       /*
       IF l_budget_line_id IS NOT NULL AND x_mrc_flag = 'Y' THEN
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
                           p_budget_version_id => l_budget_version_id,
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

    -- clean up pa_resource_assignments if necessary
    delete pa_resource_assignments
    where  resource_assignment_id = x_resource_assignment_id
    and    not exists
	       (select 1
	        from   pa_budget_lines
	        where  resource_assignment_id = x_resource_assignment_id);
Exception
When no_data_found then
null;
END Delete_Row;

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
                     X_Attribute15                      VARCHAR2)
   IS
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
           AND (   (Recinfo.quantity =  X_Quantity)
                OR (    (Recinfo.quantity IS NULL)
                    AND (X_Quantity IS NULL))
                )
           AND (   (Recinfo.raw_cost =  X_Raw_Cost)
                OR (    (Recinfo.raw_cost IS NULL)
                    AND (X_Raw_Cost IS NULL))
                )
           AND (   (Recinfo.burdened_cost =  X_Burdened_Cost)
                OR (    (Recinfo.burdened_cost IS NULL)
                   AND (X_Burdened_Cost IS NULL))
                )
            AND (   (Recinfo.revenue =  X_Revenue)
                OR (    (Recinfo.revenue IS NULL)
                    AND (X_Revenue IS NULL))
                )
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

END PA_BUDGET_MATRIX_LINES_V_PKG;

/
