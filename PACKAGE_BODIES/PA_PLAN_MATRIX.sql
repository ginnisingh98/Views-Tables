--------------------------------------------------------
--  DDL for Package Body PA_PLAN_MATRIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLAN_MATRIX" AS
/* $Header: PARPLMXB.pls 120.2 2005/09/27 12:41:29 rnamburi noship $ */

-- Bug Fix: 4569365. Removed MRC code.
-- g_mrc_exception EXCEPTION; /* FPB2 */

-- NEW SEPARATE API FOR CALCULATION OF PERIOD NAME, START DATE
-- AND END DATE FOR PRECEDING AND SUCCEEDING PERIODS
-- This API needs to be separate because it may be called by
-- other APIs or WEB ADI

P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE Get_Period_Info(
                        p_bucketing_period_code         IN VARCHAR2,
                        p_st_dt_4_st_pd                 IN DATE,
                        p_st_dt_4_end_pd                IN DATE,
                        p_plan_period_type              IN VARCHAR2,
                        p_project_id                    IN NUMBER,
                        p_budget_version_id             IN NUMBER,
                        p_resource_assignment_id        IN NUMBER,
                        p_transaction_currency_code     IN VARCHAR2,
                        x_start_date                    OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                        x_end_date                      OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                        x_period_name                   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_return_status                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                       )
IS
-- Local Variable Declaration
       l_max_pa_bdgt_st_dt              DATE;
       l_min_pa_bdgt_st_dt              DATE;
       l_plan_period_type               VARCHAR2(30);
       l_budget_version_id              NUMBER;
       l_resource_assignment_id         NUMBER;
       l_project_id                     NUMBER;
       l_st_dt_4_st_pd                  DATE;
       l_st_dt_4_end_pd                 DATE;
       l_bucketing_period_code          VARCHAR2(30);
       l_transaction_currency_code      VARCHAR2(30);
       l_debug_mode                     VARCHAR2(30);

BEGIN
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');
       PA_DEBUG.Set_Curr_Function( p_function   => 'Get_Period_Info',
                                p_debug_mode => l_debug_mode );
       IF P_PA_DEBUG_MODE = 'Y' THEN
               PA_DEBUG.g_err_stage := 'Entering Get_Period_Info and selecting ' ||
               'min dates from budget lines';
               PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
--Assigning values to variables
       l_max_pa_bdgt_st_dt := NULL;
       l_min_pa_bdgt_st_dt := NULL;
       l_plan_period_type := p_plan_period_type;
       l_budget_version_id := p_budget_version_id;
       l_resource_assignment_id := p_resource_assignment_id;
       l_project_id := p_project_id;
       l_st_dt_4_st_pd := p_st_dt_4_st_pd;
       l_st_dt_4_end_pd := p_st_dt_4_end_pd;
       l_bucketing_period_code := p_bucketing_period_code;
       l_transaction_currency_code := p_transaction_currency_code;

       x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Get the minimum of start date and maximum of end date for this
        -- resource assignment id from the budget line table:

        SELECT  min(pa_bdgt.start_date),
                max(pa_bdgt.start_date)
        INTO    l_min_pa_bdgt_st_dt,
                l_max_pa_bdgt_st_dt
        FROM pa_budget_lines pa_bdgt
        WHERE pa_bdgt.resource_assignment_id = l_resource_assignment_id
        AND pa_bdgt.TXN_CURRENCY_CODE = l_transaction_currency_code
        AND pa_bdgt.bucketing_period_code IS NULL;

 -- Getting the Preceding period start date, end date and period name
IF (l_bucketing_period_code = 'PD') THEN
  IF ( l_plan_period_type = 'GL') THEN
        BEGIN
        SELECT  inr1.period_name,
                inr1.start_date,
                inr1.end_date
        INTO    x_period_name,
                x_start_date,
                x_end_date
        FROM
        (
         SELECT G.period_name,
                G.start_date,
                G.end_date
         FROM
              Gl_Periods G,
              pa_implementations_all imp ,
              pa_projects_all p,
              gl_sets_of_books sob
          WHERE
             G.start_date      < LEAST (NVL(l_min_pa_bdgt_st_dt, l_st_dt_4_st_pd), l_st_dt_4_st_pd )  AND
             p.project_id = l_project_id AND
             nvl(p.org_id,-99) = nvl(imp.org_id,-99) AND
             imp.set_of_books_id = sob.set_of_books_id AND
             G.period_set_name = imp.period_set_name AND
             G.period_type     = sob.accounted_period_type AND
             ADJUSTMENT_PERIOD_FLAG = 'N'
             ORDER BY G.Start_Date desc
         ) inr1
         WHERE  Rownum < 2;
         PA_DEBUG.Reset_Curr_Function;
         RETURN;
         EXCEPTION
          WHEN NO_DATA_FOUND THEN
            FND_MSG_PUB.add_exc_msg
                            ( p_pkg_name       => 'PA_PLAN_MATRIX.Get_Period_Info'
                            ,p_procedure_name => PA_DEBUG.G_Err_Stack);
            IF P_PA_DEBUG_MODE = 'Y' THEN
                    PA_DEBUG.g_err_stage := 'No data found while trying to retrieve ' ||
                    'start date, end date and period name from GL_periods for PD-GL';
                    PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_data      := 'PA_FP_INVALID_PROJECT_ID';
            PA_DEBUG.Reset_Curr_Function;
            RAISE;
        END;
  ELSIF ( l_plan_period_type = 'PA') THEN
        BEGIN
        SELECT  inr1.period_name,
                inr1.start_date,
                inr1.end_date
        INTO    x_period_name,
                x_start_date,
                x_end_date
        FROM
        (
         SELECT G.period_name,
                G.start_date,
                G.end_date
          FROM
               Gl_Periods G,
               pa_implementations_all imp ,
               pa_projects_all p
           WHERE
             G.start_date      < LEAST (NVL(l_min_pa_bdgt_st_dt, l_st_dt_4_st_pd), l_st_dt_4_st_pd )  AND
             p.project_id = l_project_id AND
             nvl(p.org_id,-99) = nvl(imp.org_id,-99) AND
             G.period_set_name = imp.period_set_name AND
             G.period_type     = imp.pa_period_type AND
             ADJUSTMENT_PERIOD_FLAG = 'N'
             ORDER BY G.Start_Date desc
         ) inr1
         WHERE  Rownum < 2;
         PA_DEBUG.Reset_Curr_Function;
            RETURN;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 FND_MSG_PUB.add_exc_msg
                           ( p_pkg_name       => 'PA_PLAN_MATRIX.Get_Period_Info'
                            ,p_procedure_name => PA_DEBUG.G_Err_Stack);
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                         PA_DEBUG.g_err_stage := 'No data found while trying to retrieve ' ||
                         'start date, end date and period name from GL_periods for PD-PA';
                         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                 END IF;
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 x_msg_data      := 'PA_FP_INVALID_PROJECT_ID';
                 PA_DEBUG.Reset_Curr_Function;
                 RAISE;
        END;
  END IF;
ELSIF (l_bucketing_period_code = 'SD') THEN
  IF ( l_plan_period_type = 'GL') THEN
        BEGIN
         SELECT G.period_name,
                G.start_date,
                G.end_date
         INTO   x_period_name,
                x_start_date,
                x_end_date
         FROM
               Gl_Periods G,
               pa_implementations_all imp ,
               pa_projects_all p ,
               gl_sets_of_books sob
           WHERE
              G.start_date      >  GREATEST (NVL(l_max_pa_bdgt_st_dt, l_st_dt_4_end_pd) , l_st_dt_4_end_pd ) AND
              p.project_id = l_project_id AND
              nvl(p.org_id,-99) = nvl(imp.org_id,-99) AND
              imp.set_of_books_id = sob.set_of_books_id AND
              G.period_set_name = imp.period_set_name AND
              G.period_type     = sob.accounted_period_type AND
              ADJUSTMENT_PERIOD_FLAG = 'N' AND
              Rownum < 2
              ORDER BY G.Start_Date;
              PA_DEBUG.Reset_Curr_Function;
              RETURN;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 FND_MSG_PUB.add_exc_msg
                            ( p_pkg_name       => 'PA_PLAN_MATRIX.Get_Period_Info'
                            ,p_procedure_name => PA_DEBUG.G_Err_Stack);
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                         PA_DEBUG.g_err_stage := 'No data found while trying to retrieve ' ||
                         'start date, end date and period name from GL_periods for SD-GL';
                         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                 END IF;
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 x_msg_data      := 'PA_FP_INVALID_PROJECT_ID';
                 PA_DEBUG.Reset_Curr_Function;
                 RAISE;
        END;
  ELSIF ( l_plan_period_type = 'PA') THEN
        BEGIN
         SELECT G.period_name,
                G.start_date,
                G.end_date
         INTO   x_period_name,
                x_start_date,
                x_end_date
         FROM
               Gl_Periods G,
               pa_implementations_all imp ,
               pa_projects_all p
           WHERE
              G.start_date      >  GREATEST (NVL(l_max_pa_bdgt_st_dt, l_st_dt_4_end_pd) , l_st_dt_4_end_pd ) AND
              p.project_id = l_project_id AND
              nvl(p.org_id,-99) = nvl(imp.org_id,-99) AND
              G.period_set_name = imp.period_set_name AND
              G.period_type     = imp.pa_period_type AND
              ADJUSTMENT_PERIOD_FLAG = 'N' AND
              Rownum < 2
              ORDER BY G.Start_Date;
              PA_DEBUG.Reset_Curr_Function;
              RETURN;
              EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 FND_MSG_PUB.add_exc_msg
                            ( p_pkg_name       => 'PA_PLAN_MATRIX.Get_Period_Info'
                            ,p_procedure_name => PA_DEBUG.G_Err_Stack);
                 IF P_PA_DEBUG_MODE = 'Y' THEN
                         PA_DEBUG.g_err_stage := 'No data found while trying to retrieve ' ||
                         'start date, end date and period name from GL_periods for SD-PA';
                         PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                 END IF;
                         x_return_status := FND_API.G_RET_STS_ERROR;
                         x_msg_data      := 'PA_FP_INVALID_PROJECT_ID';
                 PA_DEBUG.Reset_Curr_Function;
                 RAISE;
        END;
  END IF;
END IF;
EXCEPTION
        WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_PLAN_MATRIX.Get_Period_Info'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack);
        IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Unexpected error in Get_Period_Info ';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        PA_DEBUG.Reset_Curr_Function;
        RAISE;
END Get_Period_Info;


-- NEW API FOR population of Budget Lines - Added by Vijay S Gautam
  PROCEDURE Populate_Budget_Lines
                       (
                        p_bucketing_period_code         IN VARCHAR2,
                        p_st_dt_4_st_pd                 IN DATE,
                        p_st_dt_4_end_pd                IN DATE,
                        p_plan_period_type              IN VARCHAR2,
                        p_project_id                    IN NUMBER,
                        p_budget_version_id             IN NUMBER,
                        p_project_currency_code         IN VARCHAR2,
                        p_projfunc_currency_code        IN VARCHAR2,
                        x_return_status                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                       )
  IS
  --Local Variable Declarations
        --Added By Vijay Gautam
       l_last_updated_by   NUMBER := FND_GLOBAL.USER_ID;
       l_created_by        NUMBER := FND_GLOBAL.USER_ID;
       l_creation_date     DATE := SYSDATE;
       l_last_update_date  DATE := l_creation_date;
       l_last_update_login      NUMBER := FND_GLOBAL.LOGIN_ID;

       l_plan_period_type VARCHAR2(30);
       l_project_id NUMBER;
       l_resource_assignment_id         NUMBER;
       l_transaction_currency_code      VARCHAR2(30);
       l_budget_version_id              NUMBER;
       l_bdgt_prec_per_name             VARCHAR2(30);
       l_bdgt_prec_per_st_dt            DATE;
       l_bdgt_prec_per_end_dt           DATE;
       l_bdgt_succ_per_name             VARCHAR2(30);
       l_bdgt_succ_per_st_dt            DATE;
       l_bdgt_succ_per_end_dt           DATE;
       l_st_dt_4_st_pd                  DATE;
       l_st_dt_4_end_pd                 DATE;
       l_bucketing_period_code          VARCHAR2(30);
       l_prec_func_raw_cost             NUMBER;
       l_prec_func_burdened_cost        NUMBER;
       l_prec_func_revenue              NUMBER;
       l_prec_func_curr_code            VARCHAR2(30);
       l_prec_txn_quantity              NUMBER;
       l_prec_txn_raw_cost              NUMBER;
       l_prec_txn_burdened_cost         NUMBER;
       l_prec_txn_revenue               NUMBER;
       l_prec_txn_curr_code             VARCHAR2(30);
       l_prec_proj_raw_cost             NUMBER;
       l_prec_proj_burdened_cost        NUMBER;
       l_prec_proj_revenue              NUMBER;
       l_prec_proj_curr_code            VARCHAR2(30);
       l_succ_func_raw_cost             NUMBER;
       l_succ_func_burdened_cost        NUMBER;
       l_succ_func_revenue              NUMBER;
       l_succ_func_curr_code            VARCHAR2(30);
       l_succ_txn_quantity              NUMBER;
       l_succ_txn_raw_cost              NUMBER;
       l_succ_txn_burdened_cost         NUMBER;
       l_succ_txn_revenue               NUMBER;
       l_succ_txn_curr_code             VARCHAR2(30);
       l_succ_proj_raw_cost             NUMBER;
       l_succ_proj_burdened_cost        NUMBER;
       l_succ_proj_revenue              NUMBER;
       l_succ_proj_curr_code            VARCHAR2(30);
       l_debug_mode                     VARCHAR2(30);

       l_budget_line_id                 PA_BUDGET_LINES.BUDGET_LINE_ID%type; /* FPB2: MRC */
       l_version_type    pa_budget_versions.version_type%TYPE;
       l_raw_cost_source pa_budget_lines.RAW_COST_SOURCE%TYPE;
       l_bd_cost_source  pa_budget_lines.RAW_COST_SOURCE%TYPE;
       l_rev_source  pa_budget_lines.RAW_COST_SOURCE%TYPE;
       l_qty_source  pa_budget_lines.RAW_COST_SOURCE%TYPE;
  CURSOR Main_Tmp_Cur IS
    SELECT DISTINCT Resource_Assignment_Id,
                    Source_Txn_Currency_Code
    FROM Pa_Fin_Plan_Lines_Tmp;
BEGIN
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');
       PA_DEBUG.Set_Curr_Function( p_function   => 'Populate_Budget_Lines',
                                p_debug_mode => l_debug_mode );

       IF P_PA_DEBUG_MODE = 'Y' THEN
               PA_DEBUG.g_err_stage := 'Entering Populate_Budget_Lines and selecting ' ||
               'cost/revenue values from budget lines';
               PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
       END IF;
       --Local Variable Initialization
       l_plan_period_type := p_plan_period_type;
       l_project_id := p_project_id;
       l_budget_version_id := p_budget_version_id;
       l_resource_assignment_id := NULL;
       l_transaction_currency_code := NULL;
       l_bdgt_prec_per_name := NULL;
       l_bdgt_prec_per_st_dt := NULL;
       l_bdgt_prec_per_end_dt := NULL;
       l_bdgt_succ_per_name := NULL;
       l_bdgt_succ_per_st_dt := NULL;
       l_bdgt_succ_per_end_dt := NULL;
       l_st_dt_4_st_pd := p_st_dt_4_st_pd;
       l_st_dt_4_end_pd := p_st_dt_4_end_pd;
       l_bucketing_period_code := p_bucketing_period_code;
       l_prec_func_raw_cost := NULL;
       l_prec_func_burdened_cost := NULL;
       l_prec_func_revenue := NULL;
       l_prec_func_curr_code := NULL;
       l_prec_txn_quantity := NULL;
       l_prec_txn_raw_cost := NULL;
       l_prec_txn_burdened_cost := NULL;
       l_prec_txn_revenue := NULL;
       l_prec_txn_curr_code := NULL;
       l_prec_proj_raw_cost := NULL;
       l_prec_proj_burdened_cost := NULL;
       l_prec_proj_revenue := NULL;
       l_prec_proj_curr_code := NULL;
       l_succ_func_raw_cost := NULL;
       l_succ_func_burdened_cost := NULL;
       l_succ_func_revenue := NULL;
       l_succ_func_curr_code := NULL;
       l_succ_txn_quantity := NULL;
       l_succ_txn_raw_cost := NULL;
       l_succ_txn_burdened_cost := NULL;
       l_succ_txn_revenue := NULL;
       l_succ_txn_curr_code := NULL;
       l_succ_proj_raw_cost := NULL;
       l_succ_proj_burdened_cost := NULL;
       l_succ_proj_revenue := NULL;
       l_succ_proj_curr_code := NULL;

       x_return_status := FND_API.G_RET_STS_SUCCESS;

       SELECT NVL(version_type,'ALL') INTO
       l_version_type FROM pa_budget_versions
       where budget_version_id = p_budget_version_id;
       l_qty_source  := 'M';
       l_raw_cost_source := NULL;
       l_bd_cost_source  := NULL;
       l_rev_source  := NULL;

       IF l_version_type = 'ALL' THEN
          l_raw_cost_source := 'M';
          l_bd_cost_source  := 'M';
          l_rev_source  := 'M';
       ELSIF l_version_type = 'COST' THEN
          l_raw_cost_source := 'M';
          l_bd_cost_source  := 'M';
       ELSIF l_version_type = 'REVENUE' THEN
          l_rev_source  := 'M';
       END IF;
FOR main_cur_rec IN MAIN_TMP_CUR
LOOP
       -- Get the minimum of start date and maximum of end date for this
       -- period profile id from the period profile table:

       -- We already have it in the API as the parameter assigned to
       -- these local variables

       -- Start Date - l_st_dt_4_st_pd
       -- End Date - l_st_dt_4_end_pd

       -- Get The Period Name, Start Date and End Date from the GL_periods
       -- Table for the minimum of start date and end date derived from the
       -- pa_budget_lines table and Pa_Proj_Period_Profiles table.

    -- Assigning values from cursor to the local variable
    l_resource_assignment_id :=  main_cur_rec.resource_assignment_id;
    l_transaction_currency_code := main_cur_rec.source_txn_currency_code;
    IF (l_bucketing_period_code = 'PD') THEN

    -- PE values need to be set to null to make sure that
    -- new updates for PE values in budget_lines table go
    -- smoothly depending on the new data in the temporary table

          /* FPB2: MRC No changes done as no amount columns are being updated.
                   DO NOT ADD ANY AMOUNT COLUMNS TO THIS UPDATE. ELSE MAKE CALL TO MRC !!!!
          */
          UPDATE Pa_Budget_Lines
          SET Bucketing_Period_Code = NULL
          WHERE  Pa_Budget_Lines.resource_assignment_id = main_cur_rec.resource_assignment_id
          AND Pa_Budget_Lines.TXN_CURRENCY_CODE = main_cur_rec.source_txn_currency_code
          AND ( Pa_Budget_Lines.Bucketing_period_code = 'PE'       -- Bug 2810094. update the SE records where
                OR                                                 -- start_date < period profile start period start date
                (Pa_Budget_Lines.Bucketing_period_code = 'SE' AND  -- with bucketing period code as null
                 Pa_Budget_Lines.start_date < p_st_dt_4_st_pd
                )
              );
       -- Getting the Preceding period start date, end date and period name

       Get_Period_Info
        (
                p_bucketing_period_code => l_bucketing_period_code,
                p_st_dt_4_st_pd => l_st_dt_4_st_pd,
                p_st_dt_4_end_pd => l_st_dt_4_end_pd,
                p_plan_period_type => l_plan_period_type,
                p_project_id => l_project_id,
                p_budget_version_id => l_budget_version_id,
                p_resource_assignment_id => l_resource_assignment_id,
                p_transaction_currency_code => l_transaction_currency_code,
                x_start_date => l_bdgt_prec_per_st_dt,
                x_end_date => l_bdgt_prec_per_end_dt,
                x_period_name => l_bdgt_prec_per_name,
                x_return_status =>x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                --DBMS_OUTPUT.PUT_LINE('Error in call to Get Period Info');
                RETURN;
        END IF;
       -- Selecting the revenue and cost values from the temporary
       -- table for preceding period

       -- Selecting for Transaction Currency
       BEGIN
            SELECT      raw_cost,
                        burdened_cost,
                        revenue,
                        currency_code,
                        quantity
            INTO        l_prec_txn_raw_cost,
                        l_prec_txn_burdened_cost,
                        l_prec_txn_revenue,
                        l_prec_txn_curr_code,
                        l_prec_txn_quantity
            FROM PA_FIN_PLAN_LINES_TMP
            WHERE bucketing_period_code = l_bucketing_period_code
            AND resource_assignment_id = main_cur_rec.resource_assignment_id
            AND currency_type = 'TRANSACTION'
            AND source_txn_currency_code = main_cur_rec.source_txn_currency_code;
       EXCEPTION
              WHEN NO_DATA_FOUND THEN
                l_prec_txn_raw_cost := NULL;
                l_prec_txn_burdened_cost := NULL;
                l_prec_txn_revenue := NULL;
                l_prec_txn_curr_code := main_cur_rec.source_txn_currency_code;
                l_prec_txn_quantity := NULL;
        END;

       -- Selecting for Project Currency
       BEGIN
            SELECT      raw_cost,
                        burdened_cost,
                        revenue,
                        currency_code
            INTO        l_prec_proj_raw_cost,
                        l_prec_proj_burdened_cost,
                        l_prec_proj_revenue,
                        l_prec_proj_curr_code
            FROM PA_FIN_PLAN_LINES_TMP
            WHERE bucketing_period_code = l_bucketing_period_code
            AND resource_assignment_id = main_cur_rec.resource_assignment_id
            AND currency_type = 'PROJECT'
            AND source_txn_currency_code = main_cur_rec.source_txn_currency_code ;
            EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_prec_proj_raw_cost := NULL;
                    l_prec_proj_burdened_cost := NULL;
                    l_prec_proj_revenue := NULL;
                    l_prec_proj_curr_code := p_project_currency_code;
         END;

       -- Selecting for Project Functional Currency
       BEGIN
            SELECT      raw_cost,
                        burdened_cost,
                        revenue,
                        currency_code
            INTO        l_prec_func_raw_cost,
                        l_prec_func_burdened_cost,
                        l_prec_func_revenue,
                        l_prec_func_curr_code
            FROM PA_FIN_PLAN_LINES_TMP
            WHERE bucketing_period_code = l_bucketing_period_code
            AND resource_assignment_id = main_cur_rec.resource_assignment_id
            AND currency_type = 'PROJ_FUNCTIONAL'
            AND source_txn_currency_code = main_cur_rec.source_txn_currency_code;
       EXCEPTION
             WHEN NO_DATA_FOUND THEN
               l_prec_func_raw_cost := NULL;
               l_prec_func_burdened_cost := NULL;
               l_prec_func_revenue := NULL;
               l_prec_func_curr_code := p_projfunc_currency_code;
        END;
      -- Updating the budget line table to store the values of preceding buckets
            BEGIN

                 l_budget_line_id := Null; /* FPB2 */
                 -- updation of amount has been commented for bug#2817407
                 UPDATE Pa_Budget_Lines
                 SET
                 Period_Name            = l_bdgt_prec_per_name,
                 Start_Date             = l_bdgt_prec_per_st_dt,
                 End_Date               = l_bdgt_prec_per_end_dt,
             --  Quantity               = l_prec_txn_quantity,
             --  Raw_cost               = l_prec_func_raw_cost,
             --  Burdened_cost          = l_prec_func_burdened_cost,
             --  Revenue                = l_prec_func_revenue,
             --  Txn_Raw_cost           = l_prec_txn_raw_cost,
             --  Txn_Burdened_cost      = l_prec_txn_burdened_cost,
             --  Txn_Revenue            = l_prec_txn_revenue,
             --  Project_Raw_cost       = l_prec_proj_raw_cost,
             --  Project_Burdened_cost  = l_prec_proj_burdened_cost,
             --  Project_Revenue        = l_prec_proj_revenue,
                 LAST_UPDATE_LOGIN      = l_last_update_login,
                 LAST_UPDATED_BY        = l_last_updated_by,
                 LAST_UPDATE_DATE       = l_last_update_date
                 WHERE  resource_assignment_id = main_cur_rec.resource_assignment_id
                 AND Pa_Budget_Lines.TXN_CURRENCY_CODE = main_cur_rec.source_txn_currency_code
                 AND Pa_Budget_Lines.bucketing_period_code = l_bucketing_period_code
                 AND budget_version_id = l_budget_version_id
                 returning budget_line_id into l_budget_line_id; /* FPB2: MRC */

                 IF SQL%ROWCOUNT = 0 THEN

                 select pa_budget_lines_s.nextval
                 into   l_budget_line_id
                 from   dual;

                 INSERT INTO PA_BUDGET_LINES
                                (budget_line_id, /* FPB2 */
                                 budget_version_id, /* FPB2 */
                                 Resource_Assignment_Id,
                                 Start_Date,
                                 End_Date,
                                 Period_Name,
                                 Quantity,
                                 Raw_cost,
                                 Burdened_cost ,
                                 Revenue,
                                 projfunc_currency_code,
                                 Txn_Raw_cost,
                                 Txn_Burdened_cost,
                                 Txn_Revenue,
                                 txn_currency_code,
                                 Project_Raw_cost,
                                 Project_Burdened_cost,
                                 Project_Revenue,
                                 project_currency_code,
                                 bucketing_period_code,
                                 CREATION_DATE ,
                                 CREATED_BY ,
                                 LAST_UPDATE_LOGIN ,
                                 LAST_UPDATED_BY ,
                                 LAST_UPDATE_DATE,
                                 RAW_COST_SOURCE,
                                 BURDENED_COST_SOURCE,
                                 QUANTITY_SOURCE,
                                 REVENUE_SOURCE)
                 VALUES         (l_budget_line_id,       /* FPB2 */
                                 l_budget_version_id,    /* FPB2 */
                                 main_cur_rec.resource_assignment_id,
                                 l_bdgt_prec_per_st_dt,
                                 l_bdgt_prec_per_end_dt,
                                 l_bdgt_prec_per_name,
                                 l_prec_txn_quantity,
                                 l_prec_func_raw_cost ,
                                 l_prec_func_burdened_cost ,
                                 l_prec_func_revenue,
                                 l_prec_func_curr_code,
                                 l_prec_txn_raw_cost,
                                 l_prec_txn_burdened_cost ,
                                 l_prec_txn_revenue ,
                                 l_prec_txn_curr_code,
                                 l_prec_proj_raw_cost ,
                                 l_prec_proj_burdened_cost,
                                 l_prec_proj_revenue ,
                                 l_prec_proj_curr_code,
                                 l_bucketing_period_code,
                                 l_creation_date ,
                                 l_created_by ,
                                 l_last_update_login ,
                                 l_last_updated_by ,
                                 l_last_update_date,
                                 l_raw_cost_source,
                                 l_bd_cost_source,
                                 l_qty_source,
                                 l_rev_source );

                  -- Bug Fix: 4569365. Removed MRC code.
                 /* FPB2: MRC */
                 /*
                  IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
                       PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                                 (x_return_status      => x_return_status,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data);
                  END IF;

                  IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
                     PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
                     PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
                                         (p_budget_line_id => l_budget_line_id,
                                          p_budget_version_id => l_budget_version_id,
                                          p_action         => PA_MRC_FINPLAN.G_ACTION_INSERT,
                                          x_return_status  => x_return_status,
                                          x_msg_count      => x_msg_count,
                                          x_msg_data       => x_msg_data);
                  END IF;

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE g_mrc_exception;
                  END IF;
                  */

                 END IF;
          EXCEPTION
                WHEN OTHERS THEN
                  FND_MSG_PUB.add_exc_msg
                       ( p_pkg_name       => 'PA_PLAN_MATRIX.Populate_Budget_Lines'
                        ,p_procedure_name => PA_DEBUG.G_Err_Stack);
                  IF P_PA_DEBUG_MODE = 'Y' THEN
                          PA_DEBUG.g_err_stage := 'EXCEPTION while trying to insert ' ||
                          'PD data in budget lines table';
                          PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                  END IF;
                  PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_FP_UNEX_ERR_INS_BDGT_LNS');
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  x_msg_data      := 'PA_FP_UNEX_ERR_INS_BDGT_LNS';
                  PA_DEBUG.Reset_Curr_Function;
                  RAISE;
          END;
        -- Updating the Budget Line Tables to store the Values for
        -- Preceding Entered l_st_dt_4_st_pd  is the start date of
        -- the start period from the period profile table

        /* FPB2 : MRC DO NOT ADD AMOUNT COLUMNS TO THE UPDATE OR CONSIDER MRC IMPACT !!! */

                   UPDATE Pa_Budget_Lines
                   SET Bucketing_Period_Code = 'PE'
                   WHERE Pa_Budget_Lines.START_DATE < l_st_dt_4_st_pd
                   AND  Pa_Budget_Lines.resource_assignment_id = main_cur_rec.resource_assignment_id
                   AND Pa_Budget_Lines.TXN_CURRENCY_CODE = main_cur_rec.source_txn_currency_code
                   AND Pa_Budget_Lines.Bucketing_period_code IS NULL;

    END IF;     -- End of if for bucketing period code PD

    IF (l_bucketing_period_code = 'SD') THEN

    -- SE values need to be set to null to make sure that
    -- new updates for SE values in budget_lines table go
    -- smoothly depending on the new data in the temporary table

   /* FPB2 : Please note that if the following update is modified to udpate
      amount columns MRC api call needs to be made appropirately */

          UPDATE Pa_Budget_Lines
          SET Bucketing_Period_Code = NULL
          WHERE  Pa_Budget_Lines.resource_assignment_id = main_cur_rec.resource_assignment_id
          AND Pa_Budget_Lines.TXN_CURRENCY_CODE = main_cur_rec.source_txn_currency_code
          AND ( Pa_Budget_Lines.Bucketing_period_code = 'SE'          -- Bug 2810094. update the PE records where
                OR                                                    -- start_date > period profile end period start date
                (                                                     -- with bucketing period code as null
                    Pa_Budget_Lines.Bucketing_period_code = 'PE'
                    AND Pa_Budget_Lines.Start_Date > l_st_dt_4_end_pd
                )
               );
      -- Getting the Succeeding period start date, end date and period name

       Get_Period_Info
        (
                p_bucketing_period_code => l_bucketing_period_code,
                p_st_dt_4_st_pd => l_st_dt_4_st_pd,
                p_st_dt_4_end_pd => l_st_dt_4_end_pd,
                p_plan_period_type => l_plan_period_type,
                p_project_id => l_project_id,
                p_budget_version_id => l_budget_version_id,
                p_resource_assignment_id => l_resource_assignment_id,
                p_transaction_currency_code => l_transaction_currency_code,
                x_start_date => l_bdgt_succ_per_st_dt,
                x_end_date => l_bdgt_succ_per_end_dt,
                x_period_name => l_bdgt_succ_per_name,
                x_return_status =>x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        --DBMS_OUTPUT.PUT_LINE('Error in call to Get Period Info');
                        PA_DEBUG.Reset_Curr_Function;
                        RETURN;
        END IF;
      -- Selecting the revenue and cost values from the temporary
      -- table for succeeding period

      -- Selecting for Transaction Currency
      BEGIN
            SELECT      raw_cost,
                        burdened_cost,
                        revenue,
                        currency_code,
                        quantity
            INTO        l_succ_txn_raw_cost,
                        l_succ_txn_burdened_cost,
                        l_succ_txn_revenue,
                        l_succ_txn_curr_code,
                        l_succ_txn_quantity
            FROM PA_FIN_PLAN_LINES_TMP
            WHERE bucketing_period_code = l_bucketing_period_code
            AND resource_assignment_id = main_cur_rec.resource_assignment_id
            AND currency_type = 'TRANSACTION'
            AND source_txn_currency_code = main_cur_rec.source_txn_currency_code;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
                l_succ_txn_raw_cost := NULL;
                l_succ_txn_burdened_cost := NULL;
                l_succ_txn_revenue := NULL;
                l_succ_txn_curr_code := main_cur_rec.source_txn_currency_code;
                l_succ_txn_quantity := NULL;
         END;

      -- Selecting for Project Currency
      BEGIN
            SELECT      raw_cost,
                        burdened_cost,
                        revenue,
                        currency_code
            INTO        l_succ_proj_raw_cost,
                        l_succ_proj_burdened_cost,
                        l_succ_proj_revenue,
                        l_succ_proj_curr_code
            FROM PA_FIN_PLAN_LINES_TMP
            WHERE bucketing_period_code = l_bucketing_period_code
            AND resource_assignment_id = main_cur_rec.resource_assignment_id
            AND currency_type = 'PROJECT'
            AND source_txn_currency_code = main_cur_rec.source_txn_currency_code;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
                l_succ_proj_raw_cost := NULL;
                l_succ_proj_burdened_cost := NULL;
                l_succ_proj_revenue := NULL;
                l_succ_proj_curr_code := p_project_currency_code;
       END;

      -- Selecting for Project Functional Currency
      BEGIN
            SELECT      raw_cost,
                        burdened_cost,
                        revenue,
                        currency_code
            INTO        l_succ_func_raw_cost,
                        l_succ_func_burdened_cost,
                        l_succ_func_revenue,
                        l_succ_func_curr_code
            FROM PA_FIN_PLAN_LINES_TMP
            WHERE bucketing_period_code = l_bucketing_period_code
            AND resource_assignment_id = main_cur_rec.resource_assignment_id
            AND currency_type = 'PROJ_FUNCTIONAL'
            AND source_txn_currency_code = main_cur_rec.source_txn_currency_code;
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
                l_succ_func_raw_cost := NULL;
                l_succ_func_burdened_cost := NULL;
                l_succ_func_revenue := NULL;
                l_succ_func_curr_code := p_projfunc_currency_code;
      END;
      -- Updating the budget line table to store the values of succeeding buckets
      BEGIN

           l_budget_line_id := Null; /* FPB2 */
                 -- updation of amount has been commented for bug#2817407
           UPDATE Pa_Budget_Lines
           SET
           Period_Name                  = l_bdgt_succ_per_name,
           Start_Date                   = l_bdgt_succ_per_st_dt,
           End_Date                     = l_bdgt_succ_per_end_dt,
       --  Quantity                     = l_succ_txn_quantity,
       --  Raw_cost                     = l_succ_func_raw_cost,
       --  Burdened_cost                = l_succ_func_burdened_cost,
       --  Revenue                      = l_succ_func_revenue,
       --  Txn_Raw_cost                 = l_succ_txn_raw_cost,
       --  Txn_Burdened_cost            = l_succ_txn_burdened_cost,
       --  Txn_Revenue                  = l_succ_txn_revenue,
       --  Project_Raw_cost             = l_succ_proj_raw_cost,
       --  Project_Burdened_cost        = l_succ_proj_burdened_cost,
       --  Project_Revenue              = l_succ_proj_revenue,
           LAST_UPDATE_LOGIN            = l_last_update_login,
           LAST_UPDATED_BY              = l_last_updated_by,
           LAST_UPDATE_DATE             = l_last_update_date
           WHERE resource_assignment_id = main_cur_rec.resource_assignment_id
           AND Pa_Budget_Lines.TXN_CURRENCY_CODE = main_cur_rec.source_txn_currency_code
           AND Pa_Budget_Lines.bucketing_period_code = l_bucketing_period_code
           AND budget_version_id = l_budget_version_id
           returning budget_line_id into l_budget_line_id;

        -- Bug Fix: 4569365. Removed MRC code.
          /* FPB2: MRC */
        IF SQL%ROWCOUNT <> 0 THEN
          NULL;
          /*
          IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
               PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                         (x_return_status      => x_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data);
          END IF;

          IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
             PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
             PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
                                 (p_budget_line_id => l_budget_line_id,
                                  p_budget_version_id => l_budget_version_id,
                                  p_action         => PA_MRC_FINPLAN.G_ACTION_UPDATE,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data);
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE g_mrc_exception;
          END IF;
          */
      ELSE
        /*IF SQL%ROWCOUNT = 0 THEN*/
          select pa_budget_lines_s.nextval
          into   l_budget_line_id
          from   dual;

      INSERT INTO PA_BUDGET_LINES
                        (Budget_Line_id,    /* FPB2 */
                         Budget_Version_id, /* FPB2 */
                         Resource_Assignment_Id,
                         Start_Date,
                         End_Date,
                         Period_Name,
                         Quantity,
                         Raw_cost,
                         Burdened_cost ,
                         Revenue,
                         projfunc_currency_code,
                         Txn_Raw_cost,
                         Txn_Burdened_cost,
                         Txn_Revenue,
                         txn_currency_code,
                         Project_Raw_cost,
                         Project_Burdened_cost,
                         Project_Revenue,
                         project_currency_code,
                         bucketing_period_code,
                         CREATION_DATE ,
                         CREATED_BY ,
                         LAST_UPDATE_LOGIN ,
                         LAST_UPDATED_BY ,
                         LAST_UPDATE_DATE,
                         RAW_COST_SOURCE,
                         BURDENED_COST_SOURCE,
                         QUANTITY_SOURCE,
                         REVENUE_SOURCE)
      VALUES            (l_budget_line_id,                 /* FPB2 */
                         l_budget_version_id,              /* FPB2 */
                         main_cur_rec.resource_assignment_id,
                         l_bdgt_succ_per_st_dt,
                         l_bdgt_succ_per_end_dt,
                         l_bdgt_succ_per_name,
                         l_succ_txn_quantity,
                         l_succ_func_raw_cost ,
                         l_succ_func_burdened_cost ,
                         l_succ_func_revenue,
                         l_succ_func_curr_code,
                         l_succ_txn_raw_cost,
                         l_succ_txn_burdened_cost ,
                         l_succ_txn_revenue ,
                         l_succ_txn_curr_code,
                         l_succ_proj_raw_cost ,
                         l_succ_proj_burdened_cost,
                         l_succ_proj_revenue ,
                         l_succ_proj_curr_code,
                         l_bucketing_period_code,
                         l_creation_date ,
                         l_created_by ,
                         l_last_update_login ,
                         l_last_updated_by ,
                         l_last_update_date,
                         l_raw_cost_source,
                         l_bd_cost_source,
                         l_qty_source,
                         l_rev_source );

                 -- Bug Fix: 4569365. Removed MRC code.
                 /* FPB2: MRC */
                 /*
                  IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS IS NULL THEN
                       PA_MRC_FINPLAN.CHECK_MRC_INSTALL
                                 (x_return_status      => x_return_status,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data);
                  END IF;

                  IF PA_MRC_FINPLAN.G_MRC_ENABLED_FOR_BUDGETS AND
                     PA_MRC_FINPLAN.G_FINPLAN_MRC_OPTION_CODE = 'A' THEN
                     PA_MRC_FINPLAN.MAINTAIN_ONE_MC_BUDGET_LINE
                                         (p_budget_line_id => l_budget_line_id,
                                          p_budget_version_id => l_budget_version_id,
                                          p_action         => PA_MRC_FINPLAN.G_ACTION_INSERT,
                                          x_return_status  => x_return_status,
                                          x_msg_count      => x_msg_count,
                                          x_msg_data       => x_msg_data);
                  END IF;

                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE g_mrc_exception;
                  END IF;
                  */

      END IF;
      EXCEPTION
        WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name       => 'PA_PLAN_MATRIX.Populate_Budget_Lines'
                  ,p_procedure_name => PA_DEBUG.G_Err_Stack);
          IF P_PA_DEBUG_MODE = 'Y' THEN
                  PA_DEBUG.g_err_stage := 'Exception while trying to insert ' ||
                  'SD data in budget lines table';
                  PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
          END IF;
          PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                p_msg_name       => 'PA_FP_UNEX_ERR_INS_BDGT_LNS');
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_data      := 'PA_FP_UNEX_ERR_INS_BDGT_LNS';
          PA_DEBUG.Reset_Curr_Function;
          RAISE;
      END;

 -- Updating the Budget Line Tables to store the Values for
 -- Succeeding Entered l_st_dt_4_end_pd  is the start date of
 -- the end period from the period profile table

          UPDATE Pa_Budget_Lines
          SET Bucketing_Period_Code = 'SE'
          WHERE Pa_Budget_Lines.START_DATE > l_st_dt_4_end_pd
          AND Pa_Budget_Lines.resource_assignment_id = main_cur_rec.resource_assignment_id
          AND Pa_Budget_Lines.TXN_CURRENCY_CODE = main_cur_rec.source_txn_currency_code
          AND Pa_Budget_Lines.Bucketing_period_code IS NULL;
  END IF;       -- End of if for bucketing period code SD
  END LOOP;
  EXCEPTION
        WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg
               ( p_pkg_name       => 'PA_PLAN_MATRIX.Populate_Budget_Lines'
                ,p_procedure_name => PA_DEBUG.G_Err_Stack);
        IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Unexpected error in Populate_Budget_Lines ';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        PA_DEBUG.Reset_Curr_Function;
        RAISE;
  END Populate_Budget_Lines;

  PROCEDURE Maintain_Plan_Matrix(
                       p_amount_type_tab   IN  pa_plan_matrix.amount_type_tabtyp,
                       p_period_profile_id IN  NUMBER,
                       p_prior_period_flag IN  VARCHAR2,
                       p_commit_flag       IN  VARCHAR2,
                       x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                       x_msg_data          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                       p_budget_version_id IN NUMBER,
                       p_project_id        IN NUMBER,
                       p_debug_mode        IN VARCHAR2,
                       p_add_msg_in_stack  IN VARCHAR2,
                       p_calling_module    IN VARCHAR2)  IS

  l_start_period_name PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_st_dt_4_st_pd     DATE;
  l_end_period_name   PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_st_dt_4_end_pd    DATE;
  l_period_name1      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name2      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name3      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name4      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name5      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name6      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name7      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name8      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name9      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name10      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name11      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name12      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name13      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name14      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name15      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name16      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name17      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name18      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name19      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name20      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name21      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name22      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name23      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name24      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name25      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name26      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name27      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name28      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name29      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name30      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name31      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name32      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name33      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name34      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name35      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name36      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name37      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name38      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name39      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name40      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name41      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name42      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name43      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name44      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name45      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name46      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name47      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name48      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name49      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name50      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name51      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period_name52      PA_BUDGET_LINES.PERIOD_NAME%TYPE;
  l_period1_start_date   DATE;
  l_period2_start_date   DATE;
  l_period3_start_date   DATE;
  l_period4_start_date   DATE;
  l_period5_start_date   DATE;
  l_period6_start_date   DATE;
  l_period7_start_date   DATE;
  l_period8_start_date   DATE;
  l_period9_start_date   DATE;
  l_period10_start_date   DATE;
  l_period11_start_date   DATE;
  l_period12_start_date   DATE;
  l_period13_start_date   DATE;
  l_period14_start_date   DATE;
  l_period15_start_date   DATE;
  l_period16_start_date   DATE;
  l_period17_start_date   DATE;
  l_period18_start_date   DATE;
  l_period19_start_date   DATE;
  l_period20_start_date   DATE;
  l_period21_start_date   DATE;
  l_period22_start_date   DATE;
  l_period23_start_date   DATE;
  l_period24_start_date   DATE;
  l_period25_start_date   DATE;
  l_period26_start_date   DATE;
  l_period27_start_date   DATE;
  l_period28_start_date   DATE;
  l_period29_start_date   DATE;
  l_period30_start_date   DATE;
  l_period31_start_date   DATE;
  l_period32_start_date   DATE;
  l_period33_start_date   DATE;
  l_period34_start_date   DATE;
  l_period35_start_date   DATE;
  l_period36_start_date   DATE;
  l_period37_start_date   DATE;
  l_period38_start_date   DATE;
  l_period39_start_date   DATE;
  l_period40_start_date   DATE;
  l_period41_start_date   DATE;
  l_period42_start_date   DATE;
  l_period43_start_date   DATE;
  l_period44_start_date   DATE;
  l_period45_start_date   DATE;
  l_period46_start_date   DATE;
  l_period47_start_date   DATE;
  l_period48_start_date   DATE;
  l_period49_start_date   DATE;
  l_period50_start_date   DATE;
  l_period51_start_date   DATE;
  l_period52_start_date   DATE;


  l_amount_tab1   PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab2   PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab3   PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab4   PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab5   PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab6   PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab7   PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab8   PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab9   PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab10  PA_PLSQL_DATATYPES.NumTabTyp;

  l_amount_tab11  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab12  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab13  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab14  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab15  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab16  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab17  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab18  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab19  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab20  PA_PLSQL_DATATYPES.NumTabTyp;


  l_amount_tab21  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab22  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab23  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab24  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab25  PA_PLSQL_DATATYPES.NumTabTyp;

  l_amount_tab26  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab27  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab28  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab29  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab30  PA_PLSQL_DATATYPES.NumTabTyp;

  l_amount_tab31  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab32  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab33  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab34  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab35  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab36  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab37  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab38  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab39  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab40  PA_PLSQL_DATATYPES.NumTabTyp;


  l_amount_tab41  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab42  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab43  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab44  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab45  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab46  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab47  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab48  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab49  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab50  PA_PLSQL_DATATYPES.NumTabTyp;

  l_amount_tab51  PA_PLSQL_DATATYPES.NumTabTyp;
  l_amount_tab52  PA_PLSQL_DATATYPES.NumTabTyp;

  l_pd_name_map_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
  l_st_date_map_tab    PA_PLSQL_DATATYPES.DateTabTyp;

  l_res_asg_id_tab     PA_PLSQL_DATATYPES.NumTabTyp;
  l_obj_id_tab         PA_PLSQL_DATATYPES.NumTabTyp;
  l_obj_type_code_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
  l_amt_type_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_amt_subtype_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
  l_amt_type_id_tab    PA_PLSQL_DATATYPES.NumTabTyp;
  l_amt_subtype_id_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_currency_code_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
  l_currency_type_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
  l_parent_assignment_id_tab  PA_PLSQL_DATATYPES.NumTabTyp;

  l_res_asg_id         NUMBER(15);
  l_obj_id             NUMBER(15);
  l_obj_type_code      VARCHAR2(30);
  l_amt_type_code      VARCHAR2(30);
  l_amt_subtype_code   VARCHAR2(30);
  l_amt_type_id        NUMBER(15);
  l_amt_subtype_id     NUMBER(15);
  l_currency_code      VARCHAR2(30);
  l_currency_type      VARCHAR2(30);
  l_prev_amt           NUMBER;
  l_next_amt           NUMBER;
  l_prior_amt          NUMBER;

  l_old_qty_fin_plan_tmp NUMBER;
  l_old_raw_cost_fin_plan_tmp NUMBER;
  l_old_brd_cost_fin_plan_tmp NUMBER;
  l_old_revenue_fin_plan_tmp NUMBER;

  l_pd_amt1 NUMBER;
  l_pd_amt2 NUMBER;
  l_pd_amt3 NUMBER;
  l_pd_amt4 NUMBER;
  l_pd_amt5 NUMBER;
  l_pd_amt6 NUMBER;
  l_pd_amt7 NUMBER;
  l_pd_amt8 NUMBER;
  l_pd_amt9 NUMBER;
  l_pd_amt10 NUMBER;
  l_pd_amt11 NUMBER;
  l_pd_amt12 NUMBER;
  l_pd_amt13 NUMBER;
  l_pd_amt14 NUMBER;
  l_pd_amt15 NUMBER;
  l_pd_amt16 NUMBER;
  l_pd_amt17 NUMBER;
  l_pd_amt18 NUMBER;
  l_pd_amt19 NUMBER;
  l_pd_amt20 NUMBER;
  l_pd_amt21 NUMBER;
  l_pd_amt22 NUMBER;
  l_pd_amt23 NUMBER;
  l_pd_amt24 NUMBER;
  l_pd_amt25 NUMBER;
  l_pd_amt26 NUMBER;
  l_pd_amt27 NUMBER;
  l_pd_amt28 NUMBER;
  l_pd_amt29 NUMBER;
  l_pd_amt30 NUMBER;
  l_pd_amt31 NUMBER;
  l_pd_amt32 NUMBER;
  l_pd_amt33 NUMBER;
  l_pd_amt34 NUMBER;
  l_pd_amt35 NUMBER;
  l_pd_amt36 NUMBER;
  l_pd_amt37 NUMBER;
  l_pd_amt38 NUMBER;
  l_pd_amt39 NUMBER;
  l_pd_amt40 NUMBER;
  l_pd_amt41 NUMBER;
  l_pd_amt42 NUMBER;
  l_pd_amt43 NUMBER;
  l_pd_amt44 NUMBER;
  l_pd_amt45 NUMBER;
  l_pd_amt46 NUMBER;
  l_pd_amt47 NUMBER;
  l_pd_amt48 NUMBER;
  l_pd_amt49 NUMBER;
  l_pd_amt50 NUMBER;
  l_pd_amt51 NUMBER;
  l_pd_amt52 NUMBER;

  --Added By Vijay Gautam
  l_parent_assignment_id NUMBER;        --to hold the value from denorm table
  l_parent_assign_id     NUMBER;        -- to hold the value from PL/SQL (fin_plan_lines_tmp) table
  l_count_for_pop_call   NUMBER;
  l_parent_assign_id_local NUMBER;
  l_quantity_filter_flag VARCHAR2(1); -- to filter and not insert/update anything for quantity and
                                      -- currency type project or proj_functional
  l_min_pa_fp_ln_tmp_st_dt     DATE;
  l_max_pa_fp_ln_tmp_st_dt     DATE;

  l_project_currency_code       VARCHAR2(30);
  l_projfunc_currency_code      VARCHAR2(30);
  --

  l_cnt        NUMBER(5);
  l_total_pds  NUMBER(5);

  l_prev_raw_cost  NUMBER;
  l_prev_burd_cost NUMBER;
  l_prev_revenue   NUMBER;
  l_prev_quantity  NUMBER;
  l_prev_borr_revenue NUMBER;
  l_prev_cc_rev_in NUMBER;
  l_prev_cc_rev_out NUMBER;
  l_prev_rev_adj   NUMBER;
  l_prev_lent_res_cost NUMBER;
  l_prev_cc_cost_in NUMBER;
  l_prev_cc_cost_out NUMBER;
  l_prev_cost_adj NUMBER;
  l_prev_unasg_time_cost NUMBER;
  l_prev_util_per NUMBER;
  l_prev_util_adj NUMBER;
  l_prev_util_hrs NUMBER;
  l_prev_capacity NUMBER;
  l_prev_head_count NUMBER;
  l_prev_head_count_adj NUMBER;
  l_prev_margin NUMBER;
  l_prev_margin_perc NUMBER;
  l_prev_txn_raw_cost NUMBER;
  l_prev_txn_burd_cost NUMBER;
  l_prev_txn_revenue NUMBER;
  l_prev_proj_raw_cost NUMBER;
  l_prev_proj_burd_cost NUMBER;
  l_prev_proj_revenue NUMBER;

  l_next_raw_cost  NUMBER;
  l_next_burd_cost NUMBER;
  l_next_revenue   NUMBER;
  l_next_quantity  NUMBER;
  l_next_borr_revenue NUMBER;
  l_next_cc_rev_in NUMBER;
  l_next_cc_rev_out NUMBER;
  l_next_rev_adj   NUMBER;
  l_next_lent_res_cost NUMBER;
  l_next_cc_cost_in NUMBER;
  l_next_cc_cost_out NUMBER;
  l_next_cost_adj NUMBER;
  l_next_unasg_time_cost NUMBER;
  l_next_util_per NUMBER;
  l_next_util_adj NUMBER;
  l_next_util_hrs NUMBER;
  l_next_capacity NUMBER;
  l_next_head_count NUMBER;
  l_next_head_count_adj NUMBER;
  l_next_margin NUMBER;
  l_next_margin_perc NUMBER;
  l_next_txn_raw_cost NUMBER;
  l_next_txn_burd_cost NUMBER;
  l_next_txn_revenue NUMBER;
  l_next_proj_raw_cost NUMBER;
  l_next_proj_burd_cost NUMBER;
  l_next_proj_revenue NUMBER;

  l_valid_amount_flag varchar2(1);
  l_start_date DATE;
  l_fcst_amt NUMBER;
  l_old_fcst_amt NUMBER;

  --Added By Vijay Gautam
    l_period_set_name VARCHAR2(30);
    l_period_type VARCHAR2(30);
    l_plan_period_type VARCHAR2(30);
    l_project_id NUMBER;
    l_period_profile_id NUMBER;
    l_budget_version_id NUMBER;

  --


  CURSOR Main_Cur IS
  SELECT DISTINCT Resource_Assignment_Id,
                  Object_Id,
                  Object_Type_Code,
                  Currency_Type,
                  Currency_Code,
                  Source_Txn_Currency_Code
         FROM
   Pa_Fin_Plan_Lines_Tmp;


  CURSOR Bl_Cur(c_resource_assignment_id NUMBER,
                c_object_id              NUMBER,
                c_object_type_code       VARCHAR2,
                c_currency_type          VARCHAR2,
                c_currency_code          VARCHAR2,
                c_source_txn_currency_code VARCHAR2,
                c_start_date             DATE,
                c_end_date               DATE) IS
    SELECT Period_Name,
           Start_Date,
           Quantity,
           Raw_Cost,
           Burdened_Cost,
           Revenue,
           Old_Quantity,
           Old_Raw_Cost,
           Old_Burdened_Cost,
           Old_Revenue,
           Borrowed_Revenue,
           Tp_Revenue_In,
           Tp_Revenue_Out,
           Revenue_Adj,
           Lent_Resource_Cost,
           Tp_Cost_In,
           Tp_Cost_Out,
           Cost_Adj,
           Unassigned_Time_Cost,
           Utilization_Percent,
           Utilization_Adj,
           Utilization_Hours,
           Capacity,
           Head_Count,
           Head_Count_Adj,
           Margin,
           Margin_Percentage,
           Bucketing_Period_Code,       -- added this column in the cursor
           Parent_Assignment_Id,        -- added this column in the cursor
           NVL(Delete_Flag,'N')         -- added this column in the cursor
    FROM  Pa_Fin_Plan_Lines_Tmp
    WHERE Resource_Assignment_Id = c_resource_assignment_id AND
          Object_Id              = c_object_id              AND
          Object_Type_Code       = c_object_type_code       AND
          Currency_Type          = c_currency_type          AND
          Currency_Code          = c_currency_code          AND
          Source_Txn_Currency_Code = c_source_txn_currency_code AND
          Start_Date             BETWEEN c_start_date       AND
                                         c_end_date         AND
          (Bucketing_Period_Code IS NULL  OR
               (p_calling_module = 'FINANCIAL_PLANNING' AND
                Bucketing_Period_Code IN ('PE','SE')));  -- Bug 2789114


  /* bug 2772683 bucketing period code NULL check added. */

  l_raw_cost_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_burd_cost_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_revenue_tab   PA_PLSQL_DATATYPES.NumTabTyp;
  l_qty_tab       PA_PLSQL_DATATYPES.NumTabTyp;
  l_old_raw_cost_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_old_burd_cost_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_old_revenue_tab   PA_PLSQL_DATATYPES.NumTabTyp;
  l_old_qty_tab       PA_PLSQL_DATATYPES.NumTabTyp;

  l_borr_rev_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_cc_rev_in_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_cc_rev_out_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_rev_adj_tab    PA_PLSQL_DATATYPES.NumTabTyp;
  l_lent_res_cost_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_cc_cost_in_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_cc_cost_out_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_cost_adj_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_unasg_time_cost_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_util_per_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_util_adj_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_util_hrs_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_capacity_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_head_count_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_head_count_adj_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_margin_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_margin_perc_tab PA_PLSQL_DATATYPES.NumTabTyp;

  l_prev_amt_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_next_amt_tab  PA_PLSQL_DATATYPES.NumTabTyp;
  l_prior_amt_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_period_name_tab PA_PLSQL_DATATYPES.Char30TabTyp;
  l_fcst_amount_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_fcst_old_amount_tab PA_PLSQL_DATATYPES.NumTabTyp;
  l_start_date_tab  PA_PLSQL_DATATYPES.DateTabTyp;

  l_temp NUMBER(5);
  l_matrix_counter NUMBER ;
  l_number_of_periods NUMBER;
  l_last_updated_by   NUMBER := FND_GLOBAL.USER_ID;
  l_created_by        NUMBER := FND_GLOBAL.USER_ID;
  l_creation_date     DATE := SYSDATE;
  l_last_update_date  DATE := l_creation_date;
  l_last_update_login      NUMBER := FND_GLOBAL.LOGIN_ID;
  l_program_application_id NUMBER := FND_GLOBAL.PROG_APPL_ID;
  l_request_id NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
  l_program_id NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;

  --Added By Vijay Gautam
    l_bucketing_period_code_tab         PA_PLSQL_DATATYPES.Char30TabTyp;        --added this table
    l_parent_assign_id_tab              PA_PLSQL_DATATYPES.NumTabTyp;           --added this Table
    l_delete_flag_tab                   PA_PLSQL_DATATYPES.Char30TabTyp;        --added this Table
  --

BEGIN
    PA_DEBUG.Set_Curr_Function( p_function   => 'Maintain_Plan_Matrix',
                                p_debug_mode => p_debug_mode );
    l_matrix_counter := 1;
    /* the following logic can be easily coded by using Dynamic SQL. But for checking 52 columns
       , it will be 52 DB hits. And also if this process is called multiple times from
         conc mgr process for a range of projects, there will be more DB hits.
         So the logic is coded as a single select and using multiple IFs  - SManivannan  */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF P_PA_DEBUG_MODE = 'Y' THEN
            PA_DEBUG.g_err_stage := 'Entering Main Plan Matrix and selecting prj profile';
            PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;
     --DBMS_OUTPUT.PUT_LINE('11');
    BEGIN
       SELECT
           number_of_periods,
           period_name1,
           period_name2,
           period_name3,
           period_name4,
           period_name5,
           period_name6,
           period_name7,
           period_name8,
           period_name9,
           period_name10,
           period_name11,
           period_name12,
           period_name13,
           period_name14,
           period_name15,
           period_name16,
           period_name17,
           period_name18,
           period_name19,
           period_name20,
           period_name21,
           period_name22,
           period_name23,
           period_name24,
           period_name25,
           period_name26,
           period_name27,
           period_name28,
           period_name29,
           period_name30,
           period_name31,
           period_name32,
           period_name33,
           period_name34,
           period_name35,
           period_name36,
           period_name37,
           period_name38,
           period_name39,
           period_name40,
           period_name41,
           period_name42,
           period_name43,
           period_name44,
           period_name45,
           period_name46,
           period_name47,
           period_name48,
           period_name49,
           period_name50,
           period_name51,
           period_name52,
           period1_start_date,
           period2_start_date,
           period3_start_date,
           period4_start_date,
           period5_start_date,
           period6_start_date,
           period7_start_date,
           period8_start_date,
           period9_start_date,
           period10_start_date,
           period11_start_date,
           period12_start_date,
           period13_start_date,
           period14_start_date,
           period15_start_date,
           period16_start_date,
           period17_start_date,
           period18_start_date,
           period19_start_date,
           period20_start_date,
           period21_start_date,
           period22_start_date,
           period23_start_date,
           period24_start_date,
           period25_start_date,
           period26_start_date,
           period27_start_date,
           period28_start_date,
           period29_start_date,
           period30_start_date,
           period31_start_date,
           period32_start_date,
           period33_start_date,
           period34_start_date,
           period35_start_date,
           period36_start_date,
           period37_start_date,
           period38_start_date,
           period39_start_date,
           period40_start_date,
           period41_start_date,
           period42_start_date,
           period43_start_date,
           period44_start_date,
           period45_start_date,
           period46_start_date,
           period47_start_date,
           period48_start_date,
           period49_start_date,
           period50_start_date,
           period51_start_date,
           period52_start_date     INTO
           l_number_of_periods,
           l_period_name1,
           l_period_name2,
           l_period_name3,
           l_period_name4,
           l_period_name5,
           l_period_name6,
           l_period_name7,
           l_period_name8,
           l_period_name9,
           l_period_name10,
           l_period_name11,
           l_period_name12,
           l_period_name13,
           l_period_name14,
           l_period_name15,
           l_period_name16,
           l_period_name17,
           l_period_name18,
           l_period_name19,
           l_period_name20,
           l_period_name21,
           l_period_name22,
           l_period_name23,
           l_period_name24,
           l_period_name25,
           l_period_name26,
           l_period_name27,
           l_period_name28,
           l_period_name29,
           l_period_name30,
           l_period_name31,
           l_period_name32,
           l_period_name33,
           l_period_name34,
           l_period_name35,
           l_period_name36,
           l_period_name37,
           l_period_name38,
           l_period_name39,
           l_period_name40,
           l_period_name41,
           l_period_name42,
           l_period_name43,
           l_period_name44,
           l_period_name45,
           l_period_name46,
           l_period_name47,
           l_period_name48,
           l_period_name49,
           l_period_name50,
           l_period_name51,
           l_period_name52,
           l_period1_start_date,
           l_period2_start_date,
           l_period3_start_date,
           l_period4_start_date,
           l_period5_start_date,
           l_period6_start_date,
           l_period7_start_date,
           l_period8_start_date,
           l_period9_start_date,
           l_period10_start_date,
           l_period11_start_date,
           l_period12_start_date,
           l_period13_start_date,
           l_period14_start_date,
           l_period15_start_date,
           l_period16_start_date,
           l_period17_start_date,
           l_period18_start_date,
           l_period19_start_date,
           l_period20_start_date,
           l_period21_start_date,
           l_period22_start_date,
           l_period23_start_date,
           l_period24_start_date,
           l_period25_start_date,
           l_period26_start_date,
           l_period27_start_date,
           l_period28_start_date,
           l_period29_start_date,
           l_period30_start_date,
           l_period31_start_date,
           l_period32_start_date,
           l_period33_start_date,
           l_period34_start_date,
           l_period35_start_date,
           l_period36_start_date,
           l_period37_start_date,
           l_period38_start_date,
           l_period39_start_date,
           l_period40_start_date,
           l_period41_start_date,
           l_period42_start_date,
           l_period43_start_date,
           l_period44_start_date,
           l_period45_start_date,
           l_period46_start_date,
           l_period47_start_date,
           l_period48_start_date,
           l_period49_start_date,
           l_period50_start_date,
           l_period51_start_date,
           l_period52_start_date
        from
       pa_proj_period_profiles where
       period_profile_id = p_period_profile_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
     IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'Prj profile not found returning';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF p_add_msg_in_stack = 'Y' THEN
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                              p_msg_name       => 'PA_FP_INVALID_PRJ_PROFILE');
     ELSE
        x_msg_data      := 'PA_FP_INVALID_PRJ_PROFILE';
     END IF;
     PA_DEBUG.Reset_Curr_Function;
   END;

    IF P_PA_DEBUG_MODE = 'Y' THEN
           PA_DEBUG.g_err_stage := 'After selecting prj profile';
           PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;


   l_start_period_name := l_period_name1;
   l_st_dt_4_st_pd     := l_period1_start_date;
   l_total_pds         := 1;

   -- bug 2858293, if the duration of period profile can beonly one period
   -- then end period is same as period1

   l_end_period_name := l_period_name1;
   l_st_dt_4_end_pd := l_period1_start_date;

   l_pd_name_map_tab.delete;
   l_st_date_map_tab.delete;

   l_pd_name_map_tab(1)   := l_period_name1;
   l_st_date_map_tab(1)   := l_period1_start_date;
   l_cnt               := 1;
   /*  incremented inside IFs for not null values  */


   IF l_period2_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name2;
      l_st_dt_4_end_pd := l_period2_start_date;
      l_total_pds := 2;
      l_pd_name_map_tab(l_cnt) := l_period_name2;
      l_st_date_map_tab(l_cnt) := l_period2_start_date;
   END IF;
   IF l_period3_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name3;
      l_st_dt_4_end_pd := l_period3_start_date;
      l_total_pds := 3;
      l_pd_name_map_tab(l_cnt) := l_period_name3;
      l_st_date_map_tab(l_cnt) := l_period3_start_date;
   END IF;
   IF l_period4_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name4;
      l_st_dt_4_end_pd := l_period4_start_date;
      l_total_pds := 4;
      l_pd_name_map_tab(l_cnt) := l_period_name4;
      l_st_date_map_tab(l_cnt) := l_period4_start_date;
   END IF;
   IF l_period5_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name5;
      l_st_dt_4_end_pd := l_period5_start_date;
      l_total_pds := 5;
      l_pd_name_map_tab(l_cnt) := l_period_name5;
      l_st_date_map_tab(l_cnt) := l_period5_start_date;
   END IF;
   IF l_period6_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name6;
      l_st_dt_4_end_pd := l_period6_start_date;
      l_total_pds := 6;
      l_pd_name_map_tab(l_cnt) := l_period_name6;
      l_st_date_map_tab(l_cnt) := l_period6_start_date;
   END IF;
   IF l_period7_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name7;
      l_st_dt_4_end_pd := l_period7_start_date;
      l_total_pds := 7;
      l_pd_name_map_tab(l_cnt) := l_period_name7;
      l_st_date_map_tab(l_cnt) := l_period7_start_date;
   END IF;
   IF l_period8_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name8;
      l_st_dt_4_end_pd := l_period8_start_date;
      l_total_pds := 8;
      l_pd_name_map_tab(l_cnt) := l_period_name8;
      l_st_date_map_tab(l_cnt) := l_period8_start_date;
   END IF;
   IF l_period9_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name9;
      l_st_dt_4_end_pd := l_period9_start_date;
      l_total_pds := 9;
      l_pd_name_map_tab(l_cnt) := l_period_name9;
      l_st_date_map_tab(l_cnt) := l_period9_start_date;
   END IF;
   IF l_period10_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name10;
      l_st_dt_4_end_pd := l_period10_start_date;
      l_total_pds := 10;
      l_pd_name_map_tab(l_cnt) := l_period_name10;
      l_st_date_map_tab(l_cnt) := l_period10_start_date;
   END IF;
   IF l_period11_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name11;
      l_st_dt_4_end_pd := l_period11_start_date;
      l_total_pds := 11;
      l_pd_name_map_tab(l_cnt) := l_period_name11;
      l_st_date_map_tab(l_cnt) := l_period11_start_date;
   END IF;
   IF l_period12_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name12;
      l_st_dt_4_end_pd := l_period12_start_date;
      l_total_pds := 12;
      l_pd_name_map_tab(l_cnt) := l_period_name12;
      l_st_date_map_tab(l_cnt) := l_period12_start_date;
   END IF;
   IF l_period13_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name13;
      l_st_dt_4_end_pd := l_period13_start_date;
      l_total_pds := 13;
      l_pd_name_map_tab(l_cnt) := l_period_name13;
      l_st_date_map_tab(l_cnt) := l_period13_start_date;
   END IF;
   IF l_period14_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name14;
      l_st_dt_4_end_pd := l_period14_start_date;
      l_total_pds := 14;
      l_pd_name_map_tab(l_cnt) := l_period_name14;
      l_st_date_map_tab(l_cnt) := l_period14_start_date;
   END IF;
   IF l_period15_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name15;
      l_st_dt_4_end_pd := l_period15_start_date;
      l_total_pds := 15;
      l_pd_name_map_tab(l_cnt) := l_period_name15;
      l_st_date_map_tab(l_cnt) := l_period15_start_date;
   END IF;
   IF l_period16_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name16;
      l_st_dt_4_end_pd := l_period16_start_date;
      l_total_pds := 16;
      l_pd_name_map_tab(l_cnt) := l_period_name16;
      l_st_date_map_tab(l_cnt) := l_period16_start_date;
   END IF;
   IF l_period17_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name17;
      l_st_dt_4_end_pd := l_period17_start_date;
      l_total_pds := 17;
      l_pd_name_map_tab(l_cnt) := l_period_name17;
      l_st_date_map_tab(l_cnt) := l_period17_start_date;
   END IF;
   IF l_period18_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name18;
      l_st_dt_4_end_pd := l_period18_start_date;
      l_total_pds := 18;
      l_pd_name_map_tab(l_cnt) := l_period_name18;
      l_st_date_map_tab(l_cnt) := l_period18_start_date;
   END IF;
   IF l_period19_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name19;
      l_st_dt_4_end_pd := l_period19_start_date;
      l_total_pds := 19;
      l_pd_name_map_tab(l_cnt) := l_period_name19;
      l_st_date_map_tab(l_cnt) := l_period19_start_date;
   END IF;
   IF l_period20_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name20;
      l_st_dt_4_end_pd := l_period20_start_date;
      l_total_pds := 20;
      l_pd_name_map_tab(l_cnt) := l_period_name20;
      l_st_date_map_tab(l_cnt) := l_period20_start_date;
   END IF;
   IF l_period21_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name21;
      l_st_dt_4_end_pd := l_period21_start_date;
      l_total_pds := 21;
      l_pd_name_map_tab(l_cnt) := l_period_name21;
      l_st_date_map_tab(l_cnt) := l_period21_start_date;
   END IF;
   IF l_period22_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name22;
      l_st_dt_4_end_pd := l_period22_start_date;
      l_total_pds := 22;
      l_pd_name_map_tab(l_cnt) := l_period_name22;
      l_st_date_map_tab(l_cnt) := l_period22_start_date;
   END IF;
   IF l_period23_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name23;
      l_st_dt_4_end_pd := l_period23_start_date;
      l_total_pds := 23;
      l_pd_name_map_tab(l_cnt) := l_period_name23;
      l_st_date_map_tab(l_cnt) := l_period23_start_date;
   END IF;
   IF l_period24_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name24;
      l_st_dt_4_end_pd := l_period24_start_date;
      l_total_pds := 24;
      l_pd_name_map_tab(l_cnt) := l_period_name24;
      l_st_date_map_tab(l_cnt) := l_period24_start_date;
   END IF;
   IF l_period25_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name25;
      l_st_dt_4_end_pd := l_period25_start_date;
      l_total_pds := 25;
      l_pd_name_map_tab(l_cnt) := l_period_name25;
      l_st_date_map_tab(l_cnt) := l_period25_start_date;
   END IF;
   IF l_period26_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name26;
      l_st_dt_4_end_pd := l_period26_start_date;
      l_total_pds := 26;
      l_pd_name_map_tab(l_cnt) := l_period_name26;
      l_st_date_map_tab(l_cnt) := l_period26_start_date;
   END IF;
   IF l_period27_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name27;
      l_st_dt_4_end_pd := l_period27_start_date;
      l_total_pds := 27;
      l_pd_name_map_tab(l_cnt) := l_period_name27;
      l_st_date_map_tab(l_cnt) := l_period27_start_date;
   END IF;
   IF l_period28_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name28;
      l_st_dt_4_end_pd := l_period28_start_date;
      l_total_pds := 28;
      l_pd_name_map_tab(l_cnt) := l_period_name28;
      l_st_date_map_tab(l_cnt) := l_period28_start_date;
   END IF;
   IF l_period29_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name29;
      l_st_dt_4_end_pd := l_period29_start_date;
      l_total_pds := 29;
      l_pd_name_map_tab(l_cnt) := l_period_name29;
      l_st_date_map_tab(l_cnt) := l_period29_start_date;
   END IF;
   IF l_period30_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name30;
      l_st_dt_4_end_pd := l_period30_start_date;
      l_total_pds := 30;
      l_pd_name_map_tab(l_cnt) := l_period_name30;
      l_st_date_map_tab(l_cnt) := l_period30_start_date;
   END IF;
   IF l_period31_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name31;
      l_st_dt_4_end_pd := l_period31_start_date;
      l_total_pds := 31;
      l_pd_name_map_tab(l_cnt) := l_period_name31;
      l_st_date_map_tab(l_cnt) := l_period31_start_date;
   END IF;
   IF l_period32_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name32;
      l_st_dt_4_end_pd := l_period32_start_date;
      l_total_pds := 32;
      l_pd_name_map_tab(l_cnt) := l_period_name32;
      l_st_date_map_tab(l_cnt) := l_period32_start_date;
   END IF;
   IF l_period33_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name33;
      l_st_dt_4_end_pd := l_period33_start_date;
      l_total_pds := 33;
      l_pd_name_map_tab(l_cnt) := l_period_name33;
      l_st_date_map_tab(l_cnt) := l_period33_start_date;
   END IF;
   IF l_period34_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name34;
      l_st_dt_4_end_pd := l_period34_start_date;
      l_total_pds := 34;
      l_pd_name_map_tab(l_cnt) := l_period_name34;
      l_st_date_map_tab(l_cnt) := l_period34_start_date;
   END IF;
   IF l_period35_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name35;
      l_st_dt_4_end_pd := l_period35_start_date;
      l_total_pds := 35;
      l_pd_name_map_tab(l_cnt) := l_period_name35;
      l_st_date_map_tab(l_cnt) := l_period35_start_date;
   END IF;
   IF l_period36_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name36;
      l_st_dt_4_end_pd := l_period36_start_date;
      l_total_pds := 36;
      l_pd_name_map_tab(l_cnt) := l_period_name36;
      l_st_date_map_tab(l_cnt) := l_period36_start_date;
   END IF;
   IF l_period37_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name37;
      l_st_dt_4_end_pd := l_period37_start_date;
      l_total_pds := 37;
      l_pd_name_map_tab(l_cnt) := l_period_name37;
      l_st_date_map_tab(l_cnt) := l_period37_start_date;
   END IF;
   IF l_period38_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name38;
      l_st_dt_4_end_pd := l_period38_start_date;
      l_total_pds := 38;
      l_pd_name_map_tab(l_cnt) := l_period_name38;
      l_st_date_map_tab(l_cnt) := l_period38_start_date;
   END IF;
   IF l_period39_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name39;
      l_st_dt_4_end_pd := l_period39_start_date;
      l_total_pds := 39;
      l_pd_name_map_tab(l_cnt) := l_period_name39;
      l_st_date_map_tab(l_cnt) := l_period39_start_date;
   END IF;
   IF l_period40_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name40;
      l_st_dt_4_end_pd := l_period40_start_date;
      l_total_pds := 40;
      l_pd_name_map_tab(l_cnt) := l_period_name40;
      l_st_date_map_tab(l_cnt) := l_period40_start_date;
   END IF;
   IF l_period41_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name41;
      l_st_dt_4_end_pd := l_period41_start_date;
      l_total_pds := 41;
      l_pd_name_map_tab(l_cnt) := l_period_name41;
      l_st_date_map_tab(l_cnt) := l_period41_start_date;
   END IF;
   IF l_period42_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name42;
      l_st_dt_4_end_pd := l_period42_start_date;
      l_total_pds := 42;
      l_pd_name_map_tab(l_cnt) := l_period_name42;
      l_st_date_map_tab(l_cnt) := l_period42_start_date;
   END IF;
   IF l_period43_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name43;
      l_st_dt_4_end_pd := l_period43_start_date;
      l_total_pds := 43;
      l_pd_name_map_tab(l_cnt) := l_period_name43;
      l_st_date_map_tab(l_cnt) := l_period43_start_date;
   END IF;
   IF l_period44_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name44;
      l_st_dt_4_end_pd := l_period44_start_date;
      l_total_pds := 44;
      l_pd_name_map_tab(l_cnt) := l_period_name44;
      l_st_date_map_tab(l_cnt) := l_period44_start_date;
   END IF;
   IF l_period45_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name45;
      l_st_dt_4_end_pd := l_period45_start_date;
      l_total_pds := 45;
      l_pd_name_map_tab(l_cnt) := l_period_name45;
      l_st_date_map_tab(l_cnt) := l_period45_start_date;
   END IF;
   IF l_period46_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name46;
      l_st_dt_4_end_pd := l_period46_start_date;
      l_total_pds := 46;
      l_pd_name_map_tab(l_cnt) := l_period_name46;
      l_st_date_map_tab(l_cnt) := l_period46_start_date;
   END IF;
   IF l_period47_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name47;
      l_st_dt_4_end_pd := l_period47_start_date;
      l_total_pds := 47;
      l_pd_name_map_tab(l_cnt) := l_period_name47;
      l_st_date_map_tab(l_cnt) := l_period47_start_date;
   END IF;
   IF l_period48_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name48;
      l_st_dt_4_end_pd := l_period48_start_date;
      l_total_pds := 48;
      l_pd_name_map_tab(l_cnt) := l_period_name48;
      l_st_date_map_tab(l_cnt) := l_period48_start_date;
   END IF;
   IF l_period49_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name49;
      l_st_dt_4_end_pd := l_period49_start_date;
      l_total_pds := 49;
      l_pd_name_map_tab(l_cnt) := l_period_name49;
      l_st_date_map_tab(l_cnt) := l_period49_start_date;
   END IF;
   IF l_period50_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name50;
      l_st_dt_4_end_pd := l_period50_start_date;
      l_total_pds := 50;
      l_pd_name_map_tab(l_cnt) := l_period_name50;
      l_st_date_map_tab(l_cnt) := l_period50_start_date;
   END IF;
   IF l_period51_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name51;
      l_st_dt_4_end_pd := l_period51_start_date;
      l_total_pds := 51;
      l_pd_name_map_tab(l_cnt) := l_period_name51;
      l_st_date_map_tab(l_cnt) := l_period51_start_date;
   END IF;
   IF l_period52_start_date IS NOT NULL THEN
      l_cnt := l_cnt + 1;
      l_end_period_name := l_period_name52;
      l_st_dt_4_end_pd := l_period52_start_date;
      l_total_pds := 52;
      l_pd_name_map_tab(l_cnt) := l_period_name52;
      l_st_date_map_tab(l_cnt) := l_period52_start_date;
   END IF;

   -- This step is only for financial planning module
 IF (p_calling_module = 'FINANCIAL_PLANNING') THEN

   -- Getting the period_set_name and gl_period_type from period profile table

          SELECT pa_prof.Plan_Period_Type
          INTO l_plan_period_type
          FROM Pa_Proj_Period_Profiles pa_prof
          WHERE pa_prof.period_profile_id = p_period_profile_id;

   -- Calling the API to populate the budget lines table
   l_project_id := p_project_id;
   l_budget_version_id := p_budget_version_id;
   l_count_for_pop_call := 0;

   /* Change for Bug 2641475 Starts */

      -- Get the minimum of start date and maximum of start date for this
      -- resource assignment id from the fin plan lines table table:

        SELECT  min(pfpltmp.start_date),
                max(pfpltmp.start_date)
        INTO    l_min_pa_fp_ln_tmp_st_dt,
                l_max_pa_fp_ln_tmp_st_dt
        FROM pa_fin_plan_lines_tmp pfpltmp;

      -- Get the projfunc and project currency code for this project id
           SELECT project_currency_code,
                  projfunc_currency_code
           INTO   l_project_currency_code,
                  l_projfunc_currency_code
           FROM pa_projects_all
           WHERE project_id = l_project_id;

   /*  Change for Bug 2641475 Ends */

   SELECT count(*) into l_count_for_pop_call FROM PA_FIN_PLAN_LINES_TMP
            WHERE bucketing_period_code = 'PD';
   IF (l_count_for_pop_call <> 0) THEN
           Populate_Budget_Lines
                        (
                        p_bucketing_period_code => 'PD',
                        p_st_dt_4_st_pd => l_st_dt_4_st_pd,
                        p_st_dt_4_end_pd => l_st_dt_4_end_pd,
                        p_plan_period_type => l_plan_period_type,
                        p_project_id => l_project_id,
                        p_budget_version_id => l_budget_version_id,
                        p_project_currency_code => l_project_currency_code,
                        p_projfunc_currency_code => l_projfunc_currency_code,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count ,
                        x_msg_data => x_msg_data
                        );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 --DBMS_OUTPUT.PUT_LINE('Error in call to Populate Budget Lines');
                 RETURN;
           END IF;
    ELSE
    /* Change for Bug 2641475 Starts */
    -- Will come here only in case of entire budget version refresh
    -- or upgrade or other cases (i.e., whenever no PD records are
    -- populated in fin plan lines tmp)

    -- Check the start dates in fin plan lines tmp and period profiles
    -- If there is a date in fin plan lines tmp that is lower than
    -- period profile date then call populate budget lines
        IF ( NVL(l_min_pa_fp_ln_tmp_st_dt,l_st_dt_4_st_pd) < l_st_dt_4_st_pd) THEN
                -- Call populate budget lines with bucketing period code PD
                Populate_Budget_Lines
                        (
                        p_bucketing_period_code => 'PD',
                        p_st_dt_4_st_pd => l_st_dt_4_st_pd,
                        p_st_dt_4_end_pd => l_st_dt_4_end_pd,
                        p_plan_period_type => l_plan_period_type,
                        p_project_id => l_project_id,
                        p_budget_version_id => l_budget_version_id,
                        p_project_currency_code => l_project_currency_code,
                        p_projfunc_currency_code => l_projfunc_currency_code,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count ,
                        x_msg_data => x_msg_data
                        );

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         --DBMS_OUTPUT.PUT_LINE('Error in call to Populate Budget Lines');
                         PA_DEBUG.Reset_Curr_Function;
                         RETURN;
                END IF;
         END IF;
         /* Change for Bug 2641475 ends */
    END IF;

    SELECT count(*) into l_count_for_pop_call FROM PA_FIN_PLAN_LINES_TMP
            WHERE bucketing_period_code = 'SD';
    IF (l_count_for_pop_call <> 0) THEN
           Populate_Budget_Lines
                        (
                        p_bucketing_period_code => 'SD',
                        p_st_dt_4_st_pd => l_st_dt_4_st_pd,
                        p_st_dt_4_end_pd => l_st_dt_4_end_pd,
                        p_plan_period_type => l_plan_period_type,
                        p_project_id => l_project_id,
                        p_budget_version_id => l_budget_version_id,
                        p_project_currency_code => l_project_currency_code,
                        p_projfunc_currency_code => l_projfunc_currency_code,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count ,
                        x_msg_data => x_msg_data
                        );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         --DBMS_OUTPUT.PUT_LINE('Error in call to Populate Budget Lines');
                         PA_DEBUG.Reset_Curr_Function;
                         RETURN;
           END IF;
    ELSE
        /* Change for Bug 2641475 Starts */
        -- Will come here only in case of entire budget version refresh
        -- or upgrade or other cases (i.e., whenever no SD records are
        -- populated in fin plan lines tmp)

        -- Check the start dates in fin plan lines tmp and period profiles
        -- If there is a date in fin plan lines tmp that is higher than
        -- period profile date then call populate budget lines
        IF ( NVL(l_max_pa_fp_ln_tmp_st_dt,l_st_dt_4_end_pd) > l_st_dt_4_end_pd) THEN
                -- Call populate budget lines with bucketing period code SD
                Populate_Budget_Lines
                        (
                        p_bucketing_period_code => 'SD',
                        p_st_dt_4_st_pd => l_st_dt_4_st_pd,
                        p_st_dt_4_end_pd => l_st_dt_4_end_pd,
                        p_plan_period_type => l_plan_period_type,
                        p_project_id => l_project_id,
                        p_budget_version_id => l_budget_version_id,
                        p_project_currency_code => l_project_currency_code,
                        p_projfunc_currency_code => l_projfunc_currency_code,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count ,
                        x_msg_data => x_msg_data
                        );

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         --DBMS_OUTPUT.PUT_LINE('Error in call to Populate Budget Lines');
                         PA_DEBUG.Reset_Curr_Function;
                         RETURN;
                END IF;
         END IF;
         /* Change for Bug 2641475 ends */
    END IF;

  END IF; --For call of financial planning

  FOR main_cur_rec IN MAIN_CUR LOOP
     l_temp  := 1;

     OPEN  BL_CUR(main_cur_rec.resource_assignment_id,
                  main_cur_rec.object_id,
                  main_cur_rec.object_type_code,
                  main_cur_rec.currency_type,
                  main_cur_rec.currency_code,
                  main_cur_rec.source_txn_currency_code,
                  l_st_dt_4_st_pd,
                  l_st_dt_4_end_pd );
     FETCH BL_CUR BULK COLLECT INTO
           l_period_name_tab,
           l_start_date_tab,
           l_qty_tab,
           l_raw_cost_tab,
           l_burd_cost_tab,
           l_revenue_tab,
           l_old_qty_tab,
           l_old_raw_cost_tab,
           l_old_burd_cost_tab,
           l_old_revenue_tab,
           l_borr_rev_tab,
           l_cc_rev_in_tab,
           l_cc_rev_out_tab,
           l_rev_adj_tab,
           l_lent_res_cost_tab,
           l_cc_cost_in_tab,
           l_cc_cost_out_tab,
           l_cost_adj_tab,
           l_unasg_time_cost_tab,
           l_util_per_tab,
           l_util_adj_tab,
           l_util_hrs_tab,
           l_capacity_tab,
           l_head_count_tab,
           l_head_count_adj_tab,
           l_margin_tab,
           l_margin_perc_tab,
           l_bucketing_period_code_tab,         --added this column
           l_parent_assign_id_tab,              --added this column
           l_delete_flag_tab;                   --added this column
     CLOSE BL_CUR;

     l_prev_raw_cost  := NULL;
     l_prev_burd_cost := NULL;
     l_prev_revenue   := NULL;
     l_prev_quantity  := NULL;
     l_prev_borr_revenue  := NULL;
     l_prev_cc_rev_in  := NULL;
     l_prev_cc_rev_out  := NULL;
     l_prev_rev_adj    := NULL;
     l_prev_lent_res_cost  := NULL;
     l_prev_cc_cost_in  := NULL;
     l_prev_cc_cost_out  := NULL;
     l_prev_cost_adj  := NULL;
     l_prev_unasg_time_cost  := NULL;
     l_prev_util_per  := NULL;
     l_prev_util_adj  := NULL;
     l_prev_util_hrs  := NULL;
     l_prev_capacity  := NULL;
     l_prev_head_count  := NULL;
     l_prev_head_count_adj  := NULL;
     l_prev_margin          := NULL;
     l_prev_margin_perc     := NULL;
     l_prev_txn_raw_cost := NULL;
     l_prev_txn_burd_cost := NULL;
     l_prev_txn_revenue := NULL;
     l_prev_proj_raw_cost := NULL;
     l_prev_proj_burd_cost := NULL;
     l_prev_proj_revenue := NULL;

     l_next_raw_cost  := NULL;
     l_next_burd_cost := NULL;
     l_next_revenue   := NULL;
     l_next_quantity  := NULL;
     l_next_borr_revenue  := NULL;
     l_next_cc_rev_in  := NULL;
     l_next_cc_rev_out  := NULL;
     l_next_rev_adj    := NULL;
     l_next_lent_res_cost  := NULL;
     l_next_cc_cost_in  := NULL;
     l_next_cc_cost_out  := NULL;
     l_next_cost_adj  := NULL;
     l_next_unasg_time_cost  := NULL;
     l_next_util_per  := NULL;
     l_next_util_adj  := NULL;
     l_next_util_hrs  := NULL;
     l_next_capacity  := NULL;
     l_next_head_count  := NULL;
     l_next_head_count_adj  := NULL;
     l_next_margin          := NULL;
     l_next_margin_perc     := NULL;
     l_next_txn_raw_cost := NULL;
     l_next_txn_burd_cost := NULL;
     l_next_txn_revenue := NULL;
     l_next_proj_raw_cost := NULL;
     l_next_proj_burd_cost := NULL;
     l_next_proj_revenue := NULL;

     SELECT SUM(NVL(bl.Raw_Cost,0)),
            SUM(NVL(bl.Burdened_Cost,0)),
            SUM(NVL(bl.Revenue,0)),
            SUM(NVL(bl.Quantity,0)),
            SUM(NVL(bl.Borrowed_Revenue,0)),
            SUM(NVL(bl.Tp_Revenue_In,0)),
            SUM(NVL(bl.Tp_Revenue_Out,0)),
            SUM(NVL(bl.Revenue_Adj,0)),
            SUM(NVL(bl.Lent_Resource_Cost,0)),
            SUM(NVL(bl.Tp_Cost_In,0)),
            SUM(NVL(bl.Tp_Cost_Out,0)),
            SUM(NVL(bl.Cost_Adj,0)),
            SUM(NVL(bl.Unassigned_Time_Cost,0)),
            SUM(NVL(bl.Utilization_Percent,0)),
            SUM(NVL(bl.Utilization_Adj,0)),
            SUM(NVL(bl.Utilization_Hours,0)),
            SUM(NVL(bl.Capacity,0)),
            SUM(NVL(bl.Head_Count,0)),
            SUM(NVL(bl.Head_Count_Adj,0)),
            SUM(NVL(bl.Margin,0)),
            SUM(NVL(bl.Margin_Percentage,0))  INTO
                l_prev_raw_cost,
                l_prev_burd_cost,
                l_prev_revenue,
                l_prev_quantity,
                l_prev_borr_revenue,
                l_prev_cc_rev_in,
                l_prev_cc_rev_out,
                l_prev_rev_adj,
                l_prev_lent_res_cost,
                l_prev_cc_cost_in,
                l_prev_cc_cost_out,
                l_prev_cost_adj,
                l_prev_unasg_time_cost,
                l_prev_util_per,
                l_prev_util_adj,
                l_prev_util_hrs,
                l_prev_capacity,
                l_prev_head_count,
                l_prev_head_count_adj,
                l_prev_margin,
                l_prev_margin_perc
         FROM
         Pa_Fin_Plan_Lines_Tmp bl WHERE
            bl.Resource_Assignment_Id = main_cur_rec.resource_assignment_id AND
            bl.Object_Type_Code       = main_cur_rec.object_type_code       AND
            bl.Object_Id              = main_cur_rec.object_id              AND
            bl.Currency_Type          = main_cur_rec.currency_type         AND
            bl.Currency_Code          = main_cur_rec.currency_code          AND
            bl.start_date < l_st_dt_4_st_pd;

         SELECT SUM(NVL(bl.Raw_Cost,0)),
            SUM(NVL(bl.Burdened_Cost,0)),
            SUM(NVL(bl.Revenue,0)),
            SUM(NVL(bl.Quantity,0)),
            SUM(NVL(bl.Borrowed_Revenue,0)),
            SUM(NVL(bl.Tp_Revenue_In,0)),
            SUM(NVL(bl.Tp_Revenue_Out,0)),
            SUM(NVL(bl.Revenue_Adj,0)),
            SUM(NVL(bl.Lent_Resource_Cost,0)),
            SUM(NVL(bl.Tp_Cost_In,0)),
            SUM(NVL(bl.Tp_Cost_Out,0)),
            SUM(NVL(bl.Cost_Adj,0)),
            SUM(NVL(bl.Unassigned_Time_Cost,0)),
            SUM(NVL(bl.Utilization_Percent,0)),
            SUM(NVL(bl.Utilization_Adj,0)),
            SUM(NVL(bl.Utilization_Hours,0)),
            SUM(NVL(bl.Capacity,0)),
            SUM(NVL(bl.Head_Count,0)),
            SUM(NVL(bl.Head_Count_Adj,0)),
            SUM(NVL(bl.Margin,0)),
            SUM(NVL(bl.Margin_Percentage,0))  INTO
                l_next_raw_cost,
                l_next_burd_cost,
                l_next_revenue,
                l_next_quantity,
                l_next_borr_revenue,
                l_next_cc_rev_in,
                l_next_cc_rev_out,
                l_next_rev_adj,
                l_next_lent_res_cost,
                l_next_cc_cost_in,
                l_next_cc_cost_out,
                l_next_cost_adj,
                l_next_unasg_time_cost,
                l_next_util_per,
                l_next_util_adj,
                l_next_util_hrs,
                l_next_capacity,
                l_next_head_count,
                l_next_head_count_adj,
                l_prev_margin,
                l_prev_margin_perc FROM
         Pa_Fin_Plan_Lines_Tmp bl WHERE
            bl.Resource_Assignment_Id = main_cur_rec.resource_assignment_id AND
            bl.Object_Type_Code       = main_cur_rec.object_type_code       AND
            bl.Object_Id              = main_cur_rec.object_id              AND
            bl.Currency_Type          = main_cur_rec.currency_type AND
            bl.Currency_Code          = main_cur_rec.currency_code AND
            bl.Start_Date > l_st_dt_4_end_pd;

   -- This step is only for financial planning module
   IF (p_calling_module = 'FINANCIAL_PLANNING') THEN
     -- Selecting for transaction currency

     SELECT      SUM(NVL(bl.Txn_Raw_Cost,0)),
                 SUM(NVL(bl.Txn_Burdened_Cost,0)),
                 SUM(NVL(bl.Txn_Revenue,0)),
                 SUM(NVL(bl.Quantity,0))
                 INTO
                     l_prev_txn_raw_cost,
                     l_prev_txn_burd_cost,
                     l_prev_txn_revenue,
                     l_prev_quantity
              FROM
              Pa_Budget_Lines bl WHERE
                 bl.Resource_Assignment_Id = main_cur_rec.resource_assignment_id AND
                 bl.Txn_Currency_Code  = main_cur_rec.source_txn_currency_code AND
                 bl.bucketing_period_code in ('PE','PD')
                 AND budget_version_id = p_budget_version_id;


      -- Selecting for project currency and proj functional currency

      SELECT     SUM(NVL(bl.Raw_Cost,0)),
                 SUM(NVL(bl.Burdened_Cost,0)),
                 SUM(NVL(bl.Revenue,0)),
                 SUM(NVL(bl.Project_Raw_Cost,0)),
                 SUM(NVL(bl.Project_Burdened_Cost,0)),
                 SUM(NVL(bl.Project_Revenue,0))
                 INTO
                   l_prev_raw_cost,
                   l_prev_burd_cost,
                   l_prev_revenue,
                   l_prev_proj_raw_cost,
                   l_prev_proj_burd_cost,
                   l_prev_proj_revenue
                    FROM
                    Pa_Budget_Lines bl WHERE
                       bl.Resource_Assignment_Id = main_cur_rec.resource_assignment_id AND
                       bl.bucketing_period_code in ('PE','PD')
                       AND budget_version_id = p_budget_version_id;

      -- Selecting for transaction currency

      SELECT     SUM(NVL(bl.Txn_Raw_Cost,0)),
                 SUM(NVL(bl.Txn_Burdened_Cost,0)),
                 SUM(NVL(bl.Txn_Revenue,0)),
                 SUM(NVL(bl.Quantity,0))
                 INTO
                     l_next_txn_raw_cost,
                     l_next_txn_burd_cost,
                     l_next_txn_revenue,
                     l_next_quantity
                 FROM
                 Pa_Budget_Lines bl WHERE
                 bl.Resource_Assignment_Id = main_cur_rec.resource_assignment_id AND
                 bl.Txn_Currency_Code  = main_cur_rec.source_txn_currency_code AND
                 bl.bucketing_period_code in ('SE','SD')
                 AND budget_version_id = p_budget_version_id;

       -- Selecting for project currency and proj functional currency

       SELECT     SUM(NVL(bl.Raw_Cost,0)),
                  SUM(NVL(bl.Burdened_Cost,0)),
                  SUM(NVL(bl.Revenue,0)),
                  SUM(NVL(bl.Project_Raw_Cost,0)),
                  SUM(NVL(bl.Project_Burdened_Cost,0)),
                  SUM(NVL(bl.Project_Revenue,0))
                INTO
                    l_next_raw_cost,
                    l_next_burd_cost,
                    l_next_revenue,
                    l_next_proj_raw_cost,
                    l_next_proj_burd_cost,
                    l_next_proj_revenue
                     FROM
                     Pa_Budget_Lines bl WHERE
                        bl.Resource_Assignment_Id = main_cur_rec.resource_assignment_id AND
                        bl.bucketing_period_code in ('SE','SD')
                        AND budget_version_id = p_budget_version_id;
   END IF; --For Financial Planning call

       FOR l_plsql_cnt IN 1 .. p_amount_type_tab.count
       LOOP

        -- PA_DEBUG.g_err_stage := 'Processing amt subtype code:'||
        --                        p_amount_type_tab(l_plsql_cnt).amount_subtype_code;
        -- PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        -- For Org Forecasting, Burdened Cost maps to Own Project Cost
        l_valid_amount_flag := 'Y';
        l_quantity_filter_flag := 'Y';
        IF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'RAW_COST' THEN
           IF    (main_cur_rec.currency_type = 'TRANSACTION') THEN
                   l_fcst_amount_tab := l_raw_cost_tab;
                   l_fcst_old_amount_tab := l_old_raw_cost_tab;
                   l_prev_amt := l_prev_txn_raw_cost;
                   l_next_amt := l_next_txn_raw_cost;
           ELSIF (main_cur_rec.currency_type = 'PROJ_FUNCTIONAL') THEN
                   l_fcst_amount_tab := l_raw_cost_tab;
                   l_fcst_old_amount_tab := l_old_raw_cost_tab;
                   l_prev_amt := l_prev_raw_cost;
                   l_next_amt := l_next_raw_cost;
           ELSIF (main_cur_rec.currency_type = 'PROJECT') THEN
                   l_fcst_amount_tab := l_raw_cost_tab;
                   l_fcst_old_amount_tab := l_old_raw_cost_tab;
                   l_prev_amt := l_prev_proj_raw_cost;
                   l_next_amt := l_next_proj_raw_cost;
           END IF;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'OWN_PROJECT_COST' THEN
           l_fcst_amount_tab := l_burd_cost_tab;
           l_prev_amt := l_prev_burd_cost;
           l_next_amt := l_next_burd_cost;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'BURDENED_COST' THEN
           IF    (main_cur_rec.currency_type = 'TRANSACTION') THEN
                   l_fcst_amount_tab := l_burd_cost_tab;
                   l_fcst_old_amount_tab := l_old_burd_cost_tab;
                   l_prev_amt := l_prev_txn_burd_cost;
                   l_next_amt := l_next_txn_burd_cost;
           ELSIF (main_cur_rec.currency_type = 'PROJ_FUNCTIONAL') THEN
                   l_fcst_amount_tab := l_burd_cost_tab;
                   l_fcst_old_amount_tab := l_old_burd_cost_tab;
                   l_prev_amt := l_prev_burd_cost;
                   l_next_amt := l_next_burd_cost;
           ELSIF (main_cur_rec.currency_type = 'PROJECT') THEN
                   l_fcst_amount_tab := l_burd_cost_tab;
                   l_fcst_old_amount_tab := l_old_burd_cost_tab;
                   l_prev_amt := l_prev_proj_burd_cost;
                   l_next_amt := l_next_proj_burd_cost;
           END IF;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'LENT_RESOURCE_COST' THEN
           l_fcst_amount_tab := l_lent_res_cost_tab;
           l_prev_amt := l_prev_lent_res_cost;
           l_next_amt := l_next_lent_res_cost;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'TP_COST_IN' THEN
           l_fcst_amount_tab := l_cc_cost_in_tab;
           l_prev_amt := l_prev_cc_cost_in;
           l_next_amt := l_next_cc_cost_in;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'TP_COST_OUT' THEN
           l_fcst_amount_tab := l_cc_cost_out_tab;
           l_prev_amt := l_prev_cc_cost_out;
           l_next_amt := l_next_cc_cost_out;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'COST_ADJUSTMENTS' THEN
           l_fcst_amount_tab := l_cost_adj_tab;
           l_prev_amt := l_prev_cost_adj;
           l_next_amt := l_next_cost_adj;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'UNASSIGNED_TIME_COST' THEN
           l_fcst_amount_tab := l_unasg_time_cost_tab;
           l_prev_amt := l_prev_unasg_time_cost;
           l_next_amt := l_next_unasg_time_cost;
        ELSIF (p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'OWN_REVENUE' OR
               p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'REVENUE') THEN
           IF    (main_cur_rec.currency_type = 'TRANSACTION') THEN
                   l_fcst_amount_tab := l_revenue_tab;
                   l_fcst_old_amount_tab := l_old_revenue_tab;
                   l_prev_amt := l_prev_txn_revenue;
                   l_next_amt := l_next_txn_revenue;
           ELSIF (main_cur_rec.currency_type = 'PROJ_FUNCTIONAL') THEN
                   l_fcst_amount_tab := l_revenue_tab;
                   l_fcst_old_amount_tab := l_old_revenue_tab;
                   l_prev_amt := l_prev_revenue;
                   l_next_amt := l_next_revenue;
           ELSIF (main_cur_rec.currency_type = 'PROJECT') THEN
                   l_fcst_amount_tab := l_revenue_tab;
                   l_fcst_old_amount_tab := l_old_revenue_tab;
                   l_prev_amt := l_prev_proj_revenue;
                   l_next_amt := l_next_proj_revenue;
           END IF;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'BORROWED_REVENUE' THEN
           l_fcst_amount_tab := l_borr_rev_tab;
           l_prev_amt := l_prev_borr_revenue;
           l_next_amt := l_next_borr_revenue;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'TP_REVENUE_IN' THEN
           l_fcst_amount_tab := l_cc_rev_in_tab;
           l_prev_amt := l_prev_cc_rev_in;
           l_next_amt := l_next_cc_rev_in;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'TP_REVENUE_OUT' THEN
           l_fcst_amount_tab := l_cc_rev_out_tab;
           l_prev_amt := l_prev_cc_rev_out;
           l_next_amt := l_next_cc_rev_out;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'REVENUE_ADJUSTMENTS' THEN
           l_fcst_amount_tab := l_rev_adj_tab;
           l_prev_amt := l_prev_rev_adj;
           l_next_amt := l_next_rev_adj;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'QUANTITY' THEN
           IF    (main_cur_rec.currency_type = 'TRANSACTION') THEN
                   l_fcst_amount_tab := l_qty_tab;
                   l_fcst_old_amount_tab := l_old_qty_tab;
                   l_prev_amt := l_prev_quantity;
                   l_next_amt := l_next_quantity;
           ELSIF (p_calling_module = 'ORG_FORECAST') THEN
                   l_fcst_amount_tab := l_qty_tab;
                   l_prev_amt := l_prev_quantity;
                   l_next_amt := l_next_quantity;
           ELSE
           l_quantity_filter_flag := 'N';
           END IF;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'UTILIZATION_PERCENT' THEN
           l_fcst_amount_tab := l_util_per_tab;
           l_prev_amt := l_prev_util_per;
           l_next_amt := l_next_util_per;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'UTILIZATION_ADJUSTMENTS' THEN
           l_fcst_amount_tab := l_util_adj_tab;
           l_prev_amt := l_prev_util_adj;
           l_next_amt := l_next_util_adj;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'UTILIZATION_HOURS' THEN
           l_fcst_amount_tab := l_util_hrs_tab;
           l_prev_amt := l_prev_util_hrs;
           l_next_amt := l_next_util_hrs;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'CAPACITY' THEN
           l_fcst_amount_tab := l_capacity_tab;
           l_prev_amt := l_prev_capacity;
           l_next_amt := l_next_capacity;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'BEGIN_HEADCOUNT' THEN
           l_fcst_amount_tab := l_head_count_tab;
           l_prev_amt := l_prev_head_count;
           l_next_amt := l_next_head_count;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'HEADCOUNT_ADJUSTMENTS' THEN
           l_fcst_amount_tab := l_head_count_adj_tab;
           l_prev_amt := l_prev_head_count_adj;
           l_next_amt := l_next_head_count_adj;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'MARGIN' THEN
           l_fcst_amount_tab := l_margin_tab;
           l_prev_amt := l_prev_margin;
           l_next_amt := l_next_margin;
        ELSIF p_amount_type_tab(l_plsql_cnt).amount_subtype_code = 'MARGIN_PERCENT' THEN
           l_fcst_amount_tab := l_margin_perc_tab;
           l_prev_amt := l_prev_margin_perc;
           l_next_amt := l_next_margin_perc;
        ELSE
           l_valid_amount_flag := 'N';
        END IF;
        l_amt_type_code := p_amount_type_tab(l_plsql_cnt).amount_type_code;
        l_amt_subtype_code := p_amount_type_tab(l_plsql_cnt).amount_subtype_code;
        l_amt_type_id   := p_amount_type_tab(l_plsql_cnt).amount_type_id;
        l_amt_subtype_id   := p_amount_type_tab(l_plsql_cnt).amount_subtype_id;
        IF l_valid_amount_flag = 'N' THEN
           IF P_PA_DEBUG_MODE = 'Y' THEN
                   PA_DEBUG.g_err_stage := 'Invalid Amt Type:'||l_amt_type_code;
                   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
                   PA_DEBUG.g_err_stage := 'Invalid Amt Sub Type:'||l_amt_subtype_code;
                   PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF p_add_msg_in_stack = 'Y' THEN
              PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_FP_INVALID_AMT_TYPE');
           ELSE
              x_msg_data      := 'PA_FP_INVALID_AMT_TYPE';
           END IF;
           PA_DEBUG.Reset_Curr_Function;
           RETURN;
        END IF;
        l_res_asg_id    := main_cur_rec.resource_assignment_id;
        l_obj_id        := main_cur_rec.object_id;
        l_obj_type_code := main_cur_rec.object_type_code;
        l_currency_type := main_cur_rec.currency_type;
        l_currency_code := main_cur_rec.currency_code;

IF l_valid_amount_flag = 'Y' THEN
           IF p_prior_period_flag = 'Y' THEN
              BEGIN
                 SELECT P.Prior_Period_Amount
                 INTO
                    l_prior_amt FROM
                    Pa_Fp_Prior_Periods_Tmp P
                 WHERE
                    Resource_Assignment_Id = main_cur_rec.resource_assignment_id AND
                    Object_Id              = main_cur_rec.object_id AND
                    Object_Type_Code       = main_cur_rec.object_type_code AND
                    Amount_Type_Code       = l_amt_type_code AND
                    Amount_Subtype_Code    = l_amt_subtype_code AND
                    Currency_Type          = l_currency_type    AND
                    Currency_Code          = l_currency_code;
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 l_prior_amt := NULL;
              END;
           END IF;
          /* these variables needs to be set for each amount type and
             currency type, otherwise it will lead to  element at
             index [X] does not exist */
 IF (l_quantity_filter_flag = 'Y') THEN
 -- POPULATION OF PA_PROJ_PERIODS_DENORM
 -- Storing current amount values from denorm table
 IF (main_cur_rec.currency_type = 'TRANSACTION' OR p_calling_module = 'ORG_FORECAST') THEN
  BEGIN
  SELECT Period_Amount1,
         Period_Amount2,
         Period_Amount3,
         Period_Amount4,
         Period_Amount5,
         Period_Amount6,
         Period_Amount7,
         Period_Amount8,
         Period_Amount9,
         Period_Amount10,
         Period_Amount11,
         Period_Amount12,
         Period_Amount13,
         Period_Amount14,
         Period_Amount15,
         Period_Amount16,
         Period_Amount17,
         Period_Amount18,
         Period_Amount19,
         Period_Amount20,
         Period_Amount21,
         Period_Amount22,
         Period_Amount23,
         Period_Amount24,
         Period_Amount25,
         Period_Amount26,
         Period_Amount27,
         Period_Amount28,
         Period_Amount29,
         Period_Amount30,
         Period_Amount31,
         Period_Amount32,
         Period_Amount33,
         Period_Amount34,
         Period_Amount35,
         Period_Amount36,
         Period_Amount37,
         Period_Amount38,
         Period_Amount39,
         Period_Amount40,
         Period_Amount41,
         Period_Amount42,
         Period_Amount43,
         Period_Amount44,
         Period_Amount45,
         Period_Amount46,
         Period_Amount47,
         Period_Amount48,
         Period_Amount49,
         Period_Amount50,
         Period_Amount51,
         Period_Amount52,
         Parent_Assignment_id
      INTO  l_pd_amt1 ,
            l_pd_amt2 ,
            l_pd_amt3 ,
            l_pd_amt4 ,
            l_pd_amt5 ,
            l_pd_amt6 ,
            l_pd_amt7 ,
            l_pd_amt8 ,
            l_pd_amt9 ,
            l_pd_amt10 ,
            l_pd_amt11 ,
            l_pd_amt12 ,
            l_pd_amt13 ,
            l_pd_amt14 ,
            l_pd_amt15 ,
            l_pd_amt16 ,
            l_pd_amt17 ,
            l_pd_amt18 ,
            l_pd_amt19 ,
            l_pd_amt20 ,
            l_pd_amt21 ,
            l_pd_amt22 ,
            l_pd_amt23 ,
            l_pd_amt24 ,
            l_pd_amt25 ,
            l_pd_amt26 ,
            l_pd_amt27 ,
            l_pd_amt28 ,
            l_pd_amt29 ,
            l_pd_amt30 ,
            l_pd_amt31 ,
            l_pd_amt32 ,
            l_pd_amt33 ,
            l_pd_amt34 ,
            l_pd_amt35 ,
            l_pd_amt36 ,
            l_pd_amt37 ,
            l_pd_amt38 ,
            l_pd_amt39 ,
            l_pd_amt40 ,
            l_pd_amt41 ,
            l_pd_amt42 ,
            l_pd_amt43 ,
            l_pd_amt44 ,
            l_pd_amt45 ,
            l_pd_amt46 ,
            l_pd_amt47 ,
            l_pd_amt48 ,
            l_pd_amt49 ,
            l_pd_amt50 ,
            l_pd_amt51 ,
            l_pd_amt52,
            l_parent_assignment_id
 FROM pa_proj_periods_denorm
        WHERE period_profile_id = p_period_profile_id AND
                Budget_Version_Id      = p_budget_version_id AND
                project_id = p_project_id AND
                Resource_Assignment_Id = l_res_asg_id AND
                Object_Id              = l_obj_id AND
                Object_Type_Code       = l_obj_type_code AND
                Amount_Type_Code       = l_amt_type_code AND
                Amount_Subtype_Code    = l_amt_subtype_code AND
                Currency_Type          = l_currency_type    AND
                Currency_Code          = l_currency_code;
 -- IF the SELECT FAILS with no data found exception
 -- Initializing the local variables for the amount types to NULL
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
           l_pd_amt1 := NULL;
           l_pd_amt2 := NULL;
           l_pd_amt3 := NULL;
           l_pd_amt4 := NULL;
           l_pd_amt5 := NULL;
           l_pd_amt6 := NULL;
           l_pd_amt7 := NULL;
           l_pd_amt8 := NULL;
           l_pd_amt9 := NULL;
           l_pd_amt10 := NULL;
           l_pd_amt11 := NULL;
           l_pd_amt12 := NULL;
           l_pd_amt13 := NULL;
           l_pd_amt14 := NULL;
           l_pd_amt15 := NULL;
           l_pd_amt16 := NULL;
           l_pd_amt17 := NULL;
           l_pd_amt18 := NULL;
           l_pd_amt19 := NULL;
           l_pd_amt20 := NULL;
           l_pd_amt21 := NULL;
           l_pd_amt22 := NULL;
           l_pd_amt23 := NULL;
           l_pd_amt24 := NULL;
           l_pd_amt25 := NULL;
           l_pd_amt26 := NULL;
           l_pd_amt27 := NULL;
           l_pd_amt28 := NULL;
           l_pd_amt29 := NULL;
           l_pd_amt30 := NULL;
           l_pd_amt31 := NULL;
           l_pd_amt32 := NULL;
           l_pd_amt33 := NULL;
           l_pd_amt34 := NULL;
           l_pd_amt35 := NULL;
           l_pd_amt36 := NULL;
           l_pd_amt37 := NULL;
           l_pd_amt38 := NULL;
           l_pd_amt39 := NULL;
           l_pd_amt40 := NULL;
           l_pd_amt41 := NULL;
           l_pd_amt42 := NULL;
           l_pd_amt43 := NULL;
           l_pd_amt44 := NULL;
           l_pd_amt45 := NULL;
           l_pd_amt46 := NULL;
           l_pd_amt47 := NULL;
           l_pd_amt48 := NULL;
           l_pd_amt49 := NULL;
           l_pd_amt50 := NULL;
           l_pd_amt51 := NULL;
           l_pd_amt52 := NULL;
           l_parent_assignment_id := NULL;
  END;
ELSE
BEGIN
  SELECT 0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         Parent_Assignment_id
      INTO  l_pd_amt1 ,
            l_pd_amt2 ,
            l_pd_amt3 ,
            l_pd_amt4 ,
            l_pd_amt5 ,
            l_pd_amt6 ,
            l_pd_amt7 ,
            l_pd_amt8 ,
            l_pd_amt9 ,
            l_pd_amt10 ,
            l_pd_amt11 ,
            l_pd_amt12 ,
            l_pd_amt13 ,
            l_pd_amt14 ,
            l_pd_amt15 ,
            l_pd_amt16 ,
            l_pd_amt17 ,
            l_pd_amt18 ,
            l_pd_amt19 ,
            l_pd_amt20 ,
            l_pd_amt21 ,
            l_pd_amt22 ,
            l_pd_amt23 ,
            l_pd_amt24 ,
            l_pd_amt25 ,
            l_pd_amt26 ,
            l_pd_amt27 ,
            l_pd_amt28 ,
            l_pd_amt29 ,
            l_pd_amt30 ,
            l_pd_amt31 ,
            l_pd_amt32 ,
            l_pd_amt33 ,
            l_pd_amt34 ,
            l_pd_amt35 ,
            l_pd_amt36 ,
            l_pd_amt37 ,
            l_pd_amt38 ,
            l_pd_amt39 ,
            l_pd_amt40 ,
            l_pd_amt41 ,
            l_pd_amt42 ,
            l_pd_amt43 ,
            l_pd_amt44 ,
            l_pd_amt45 ,
            l_pd_amt46 ,
            l_pd_amt47 ,
            l_pd_amt48 ,
            l_pd_amt49 ,
            l_pd_amt50 ,
            l_pd_amt51 ,
            l_pd_amt52,
            l_parent_assignment_id
 FROM pa_proj_periods_denorm
        WHERE period_profile_id = p_period_profile_id AND
                Budget_Version_Id      = p_budget_version_id AND
                project_id = p_project_id AND
                Resource_Assignment_Id = l_res_asg_id AND
                Object_Id              = l_obj_id AND
                Object_Type_Code       = l_obj_type_code AND
                Amount_Type_Code       = l_amt_type_code AND
                Amount_Subtype_Code    = l_amt_subtype_code AND
                Currency_Type          = l_currency_type    AND
                Currency_Code          = l_currency_code;
 -- IF the SELECT FAILS with no data found exception
 -- Initializing the local variables for the amount types to NULL
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
           l_pd_amt1 := NULL;
           l_pd_amt2 := NULL;
           l_pd_amt3 := NULL;
           l_pd_amt4 := NULL;
           l_pd_amt5 := NULL;
           l_pd_amt6 := NULL;
           l_pd_amt7 := NULL;
           l_pd_amt8 := NULL;
           l_pd_amt9 := NULL;
           l_pd_amt10 := NULL;
           l_pd_amt11 := NULL;
           l_pd_amt12 := NULL;
           l_pd_amt13 := NULL;
           l_pd_amt14 := NULL;
           l_pd_amt15 := NULL;
           l_pd_amt16 := NULL;
           l_pd_amt17 := NULL;
           l_pd_amt18 := NULL;
           l_pd_amt19 := NULL;
           l_pd_amt20 := NULL;
           l_pd_amt21 := NULL;
           l_pd_amt22 := NULL;
           l_pd_amt23 := NULL;
           l_pd_amt24 := NULL;
           l_pd_amt25 := NULL;
           l_pd_amt26 := NULL;
           l_pd_amt27 := NULL;
           l_pd_amt28 := NULL;
           l_pd_amt29 := NULL;
           l_pd_amt30 := NULL;
           l_pd_amt31 := NULL;
           l_pd_amt32 := NULL;
           l_pd_amt33 := NULL;
           l_pd_amt34 := NULL;
           l_pd_amt35 := NULL;
           l_pd_amt36 := NULL;
           l_pd_amt37 := NULL;
           l_pd_amt38 := NULL;
           l_pd_amt39 := NULL;
           l_pd_amt40 := NULL;
           l_pd_amt41 := NULL;
           l_pd_amt42 := NULL;
           l_pd_amt43 := NULL;
           l_pd_amt44 := NULL;
           l_pd_amt45 := NULL;
           l_pd_amt46 := NULL;
           l_pd_amt47 := NULL;
           l_pd_amt48 := NULL;
           l_pd_amt49 := NULL;
           l_pd_amt50 := NULL;
           l_pd_amt51 := NULL;
           l_pd_amt52 := NULL;
           l_parent_assignment_id := NULL;
  END;
END IF;
/* For select from proj_period_denorm based on currency type */

           /* Reason for checking Period Start Date to map Denorm table columns.
              Currently this denorm table is designed for Financial Planning and
              Organization Forecasting.

              This model will be eventually used for existing Budget model also and
              if the budget is not based on a period ( PA or GL ) then the Period Name
              will be NULL in Budget Lines Table. So checking with Period Start Date.
                  SManivannan           */

 --Added by Vijay S Gautam
           FOR l_dummy IN 1 .. l_period_name_tab.count
           LOOP
           IF (p_calling_module = 'FINANCIAL_PLANNING') THEN
              l_start_date := l_start_date_tab(l_dummy);
              l_old_fcst_amt := NVL(l_fcst_old_amount_tab(l_dummy),0);
              IF (main_cur_rec.currency_type <> 'TRANSACTION') THEN
                  IF (l_delete_flag_tab(l_dummy) = 'Y') THEN
                        l_fcst_amt   := NVL(-l_old_fcst_amt,0);
                  ELSE
                        l_fcst_amt   := NVL(l_fcst_amount_tab(l_dummy),0) - NVL(l_old_fcst_amt,0);
                  END IF;
              ELSE
                  IF (l_delete_flag_tab(l_dummy) = 'Y') THEN
                        l_fcst_amt   := NULL;
                  ELSE
                        l_fcst_amt   := l_fcst_amount_tab(l_dummy);
                  END IF;
              END IF;
              l_parent_assign_id := l_parent_assign_id_tab (1);         --assign value from PL/SQL table
            END IF;

            IF (p_calling_module = 'ORG_FORECAST') THEN
              l_start_date := l_start_date_tab(l_dummy);
              l_fcst_amt   := l_fcst_amount_tab(l_dummy);
              l_parent_assign_id := l_parent_assign_id_tab (1);         --assign value from PL/SQL table
            END IF;

              IF l_start_date  = l_period1_start_date THEN
                        l_pd_amt1 := l_fcst_amt;
              ELSIF l_start_date = l_period2_start_date THEN
                        l_pd_amt2 := l_fcst_amt;
              ELSIF l_start_date = l_period3_start_date THEN
                        l_pd_amt3 := l_fcst_amt;
              ELSIF l_start_date = l_period4_start_date THEN
                        l_pd_amt4 := l_fcst_amt;
              ELSIF l_start_date = l_period5_start_date THEN
                        l_pd_amt5 := l_fcst_amt;
              ELSIF l_start_date = l_period6_start_date THEN
                        l_pd_amt6 := l_fcst_amt;
              ELSIF l_start_date = l_period7_start_date THEN
                        l_pd_amt7 := l_fcst_amt;
              ELSIF l_start_date = l_period8_start_date THEN
                        l_pd_amt8 := l_fcst_amt;
              ELSIF l_start_date = l_period9_start_date THEN
                        l_pd_amt9 := l_fcst_amt;
              ELSIF l_start_date = l_period10_start_date THEN
                        l_pd_amt10 := l_fcst_amt;
              ELSIF l_start_date = l_period11_start_date THEN
                        l_pd_amt11 := l_fcst_amt;
              ELSIF l_start_date = l_period12_start_date THEN
                        l_pd_amt12 := l_fcst_amt;
              ELSIF l_start_date = l_period13_start_date THEN
                        l_pd_amt13 := l_fcst_amt;
              ELSIF l_start_date = l_period14_start_date THEN
                        l_pd_amt14 := l_fcst_amt;
              ELSIF l_start_date = l_period15_start_date THEN
                        l_pd_amt15 := l_fcst_amt;
              ELSIF l_start_date = l_period16_start_date THEN
                        l_pd_amt16 := l_fcst_amt;
              ELSIF l_start_date = l_period17_start_date THEN
                        l_pd_amt17 := l_fcst_amt;
              ELSIF l_start_date = l_period18_start_date THEN
                        l_pd_amt18 := l_fcst_amt;
              ELSIF l_start_date = l_period19_start_date THEN
                        l_pd_amt19 := l_fcst_amt;
              ELSIF l_start_date = l_period20_start_date THEN
                        l_pd_amt20 := l_fcst_amt;
              ELSIF l_start_date = l_period21_start_date THEN
                        l_pd_amt21 := l_fcst_amt;
              ELSIF l_start_date = l_period22_start_date THEN
                        l_pd_amt22 := l_fcst_amt;
              ELSIF l_start_date = l_period23_start_date THEN
                        l_pd_amt23 := l_fcst_amt;
              ELSIF l_start_date = l_period24_start_date THEN
                        l_pd_amt24 := l_fcst_amt;
              ELSIF l_start_date = l_period25_start_date THEN
                        l_pd_amt25 := l_fcst_amt;
              ELSIF l_start_date = l_period26_start_date THEN
                        l_pd_amt26 := l_fcst_amt;
              ELSIF l_start_date = l_period27_start_date THEN
                        l_pd_amt27 := l_fcst_amt;
              ELSIF l_start_date = l_period28_start_date THEN
                        l_pd_amt28 := l_fcst_amt;
              ELSIF l_start_date = l_period29_start_date THEN
                        l_pd_amt29 := l_fcst_amt;
              ELSIF l_start_date = l_period30_start_date THEN
                        l_pd_amt30 := l_fcst_amt;
              ELSIF l_start_date = l_period31_start_date THEN
                        l_pd_amt31 := l_fcst_amt;
              ELSIF l_start_date = l_period32_start_date THEN
                        l_pd_amt32 := l_fcst_amt;
              ELSIF l_start_date = l_period33_start_date THEN
                        l_pd_amt33 := l_fcst_amt;
              ELSIF l_start_date = l_period34_start_date THEN
                        l_pd_amt34 := l_fcst_amt;
              ELSIF l_start_date = l_period35_start_date THEN
                        l_pd_amt35 := l_fcst_amt;
              ELSIF l_start_date = l_period36_start_date THEN
                        l_pd_amt36 := l_fcst_amt;
              ELSIF l_start_date = l_period37_start_date THEN
                        l_pd_amt37 := l_fcst_amt;
              ELSIF l_start_date = l_period38_start_date THEN
                        l_pd_amt38 := l_fcst_amt;
              ELSIF l_start_date = l_period39_start_date THEN
                        l_pd_amt39 := l_fcst_amt;
              ELSIF l_start_date = l_period40_start_date THEN
                        l_pd_amt40 := l_fcst_amt;
              ELSIF l_start_date = l_period41_start_date THEN
                        l_pd_amt41 := l_fcst_amt;
              ELSIF l_start_date = l_period42_start_date THEN
                        l_pd_amt42 := l_fcst_amt;
              ELSIF l_start_date = l_period43_start_date THEN
                        l_pd_amt43 := l_fcst_amt;
              ELSIF l_start_date = l_period44_start_date THEN
                        l_pd_amt44 := l_fcst_amt;
              ELSIF l_start_date = l_period45_start_date THEN
                        l_pd_amt45 := l_fcst_amt;
              ELSIF l_start_date = l_period46_start_date THEN
                        l_pd_amt46 := l_fcst_amt;
              ELSIF l_start_date = l_period47_start_date THEN
                        l_pd_amt47 := l_fcst_amt;
              ELSIF l_start_date = l_period48_start_date THEN
                        l_pd_amt48 := l_fcst_amt;
              ELSIF l_start_date = l_period49_start_date THEN
                        l_pd_amt49 := l_fcst_amt;
              ELSIF l_start_date = l_period50_start_date THEN
                        l_pd_amt50 := l_fcst_amt;
              ELSIF l_start_date = l_period51_start_date THEN
                        l_pd_amt51 := l_fcst_amt;
              ELSIF l_start_date = l_period52_start_date THEN
                        l_pd_amt52 := l_fcst_amt;
              END IF;
           END LOOP;

           /*      for period name tab     */
      /* Earlier, it was planned that the matrix table will be deleted for the given
         budget version id and inserted again for all res asg ids. But later it has been
         decided that we have to update the matrix table, if res asg id exists, otherwise
         to insert the record. So to avoid using another 52 additional variables, the
         table is updated with the pl sql table entries. If the update count is successful,
         then all the recent pl sql table elements will be deleted.
         If this causes performancet problems, then this logic should be changed to
         include additional 52 local variables and pl sql table deletion could be
         avoided.   */

         -- Added by Vijay s Gautam

         IF (main_cur_rec.currency_type = 'TRANSACTION' OR p_calling_module = 'ORG_FORECAST') THEN
         --
           UPDATE Pa_Proj_Periods_Denorm SET
           preceding_periods_amount     = l_prev_amt,
           succeeding_periods_amount    = l_next_amt,
           prior_period_amount          = l_prior_amt,
           period_amount1  = l_pd_amt1,
           period_amount2  = l_pd_amt2,
           period_amount3  = l_pd_amt3,
           period_amount4  = l_pd_amt4,
           period_amount5  = l_pd_amt5,
           period_amount6  = l_pd_amt6,
           period_amount7  = l_pd_amt7,
           period_amount8  = l_pd_amt8,
           period_amount9  = l_pd_amt9,
           period_amount10  = l_pd_amt10,
           period_amount11  = l_pd_amt11,
           period_amount12  = l_pd_amt12,
           period_amount13  = l_pd_amt13,
           period_amount14  = l_pd_amt14,
           period_amount15  = l_pd_amt15,
           period_amount16  = l_pd_amt16,
           period_amount17  = l_pd_amt17,
           period_amount18  = l_pd_amt18,
           period_amount19  = l_pd_amt19,
           period_amount20  = l_pd_amt20,
           period_amount21  = l_pd_amt21,
           period_amount22  = l_pd_amt22,
           period_amount23  = l_pd_amt23,
           period_amount24  = l_pd_amt24,
           period_amount25  = l_pd_amt25,
           period_amount26  = l_pd_amt26,
           period_amount27  = l_pd_amt27,
           period_amount28  = l_pd_amt28,
           period_amount29  = l_pd_amt29,
           period_amount30  = l_pd_amt30,
           period_amount31  = l_pd_amt31,
           period_amount32  = l_pd_amt32,
           period_amount33  = l_pd_amt33,
           period_amount34  = l_pd_amt34,
           period_amount35  = l_pd_amt35,
           period_amount36  = l_pd_amt36,
           period_amount37  = l_pd_amt37,
           period_amount38  = l_pd_amt38,
           period_amount39  = l_pd_amt39,
           period_amount40  = l_pd_amt40,
           period_amount41  = l_pd_amt41,
           period_amount42  = l_pd_amt42,
           period_amount43  = l_pd_amt43,
           period_amount44  = l_pd_amt44,
           period_amount45  = l_pd_amt45,
           period_amount46  = l_pd_amt46,
           period_amount47  = l_pd_amt47,
           period_amount48  = l_pd_amt48,
           period_amount49  = l_pd_amt49,
           period_amount50  = l_pd_amt50,
           period_amount51  = l_pd_amt51,
           period_amount52  = l_pd_amt52,
           parent_assignment_id = DECODE(l_parent_assign_id, NULL, l_parent_assignment_id, l_parent_assign_id),
           LAST_UPDATE_LOGIN = l_last_update_login,
           LAST_UPDATED_BY   = l_last_updated_by,
           LAST_UPDATE_DATE  = l_last_update_date
           WHERE
           Budget_Version_Id      = p_budget_version_id AND
           project_id = p_project_id AND
           Resource_Assignment_Id = l_res_asg_id AND
           Object_Id              = l_obj_id AND
           Object_Type_Code       = l_obj_type_code AND
           Amount_Type_Code       = l_amt_type_code AND
           Amount_Subtype_Code    = l_amt_subtype_code AND
           Currency_Type          = l_currency_type    AND
           Currency_Code          = l_currency_code;
           IF SQL%ROWCOUNT = 0 THEN
           -- Get the value for parent assignment id through the decode function
           SELECT DECODE(l_parent_assign_id, NULL, l_parent_assignment_id, l_parent_assign_id)
           INTO l_parent_assign_id_local from DUAL;

              l_prev_amt_tab(l_matrix_counter) := l_prev_amt;
              l_next_amt_tab(l_matrix_counter) := l_next_amt;
              l_prior_amt_tab(l_matrix_counter):= l_prior_amt;
              l_res_asg_id_tab(l_matrix_counter) := l_res_asg_id;
              l_obj_id_tab(l_matrix_counter)     := l_obj_id;
              l_obj_type_code_tab(l_matrix_counter):= l_obj_type_code;
              l_amt_type_tab(l_matrix_counter)     := l_amt_type_code;
              l_amt_subtype_tab(l_matrix_counter)  := l_amt_subtype_code;
              l_amt_type_id_tab(l_matrix_counter)     := l_amt_type_id;
              l_amt_subtype_id_tab(l_matrix_counter)  := l_amt_subtype_id;
              l_currency_code_tab(l_matrix_counter):= l_currency_code;
              l_currency_type_tab(l_matrix_counter):= l_currency_type;
              l_amount_tab1(l_matrix_counter) := l_pd_amt1;
              l_amount_tab2(l_matrix_counter) := l_pd_amt2;
              l_amount_tab3(l_matrix_counter) := l_pd_amt3;
              l_amount_tab4(l_matrix_counter) := l_pd_amt4;
              l_amount_tab5(l_matrix_counter) := l_pd_amt5;
              l_amount_tab6(l_matrix_counter) := l_pd_amt6;
              l_amount_tab7(l_matrix_counter) := l_pd_amt7;
              l_amount_tab8(l_matrix_counter) := l_pd_amt8;
              l_amount_tab9(l_matrix_counter) := l_pd_amt9;
              l_amount_tab10(l_matrix_counter) := l_pd_amt10;
              l_amount_tab11(l_matrix_counter) := l_pd_amt11;
              l_amount_tab12(l_matrix_counter) := l_pd_amt12;
              l_amount_tab13(l_matrix_counter) := l_pd_amt13;
              l_amount_tab14(l_matrix_counter) := l_pd_amt14;
              l_amount_tab15(l_matrix_counter) := l_pd_amt15;
              l_amount_tab16(l_matrix_counter) := l_pd_amt16;
              l_amount_tab17(l_matrix_counter) := l_pd_amt17;
              l_amount_tab18(l_matrix_counter) := l_pd_amt18;
              l_amount_tab19(l_matrix_counter) := l_pd_amt19;
              l_amount_tab20(l_matrix_counter) := l_pd_amt20;
              l_amount_tab21(l_matrix_counter) := l_pd_amt21;
              l_amount_tab22(l_matrix_counter) := l_pd_amt22;
              l_amount_tab23(l_matrix_counter) := l_pd_amt23;
              l_amount_tab24(l_matrix_counter) := l_pd_amt24;
              l_amount_tab25(l_matrix_counter) := l_pd_amt25;
              l_amount_tab26(l_matrix_counter) := l_pd_amt26;
              l_amount_tab27(l_matrix_counter) := l_pd_amt27;
              l_amount_tab28(l_matrix_counter) := l_pd_amt28;
              l_amount_tab29(l_matrix_counter) := l_pd_amt29;
              l_amount_tab30(l_matrix_counter) := l_pd_amt30;
              l_amount_tab31(l_matrix_counter) := l_pd_amt31;
              l_amount_tab32(l_matrix_counter) := l_pd_amt32;
              l_amount_tab33(l_matrix_counter) := l_pd_amt33;
              l_amount_tab34(l_matrix_counter) := l_pd_amt34;
              l_amount_tab35(l_matrix_counter) := l_pd_amt35;
              l_amount_tab36(l_matrix_counter) := l_pd_amt36;
              l_amount_tab37(l_matrix_counter) := l_pd_amt37;
              l_amount_tab38(l_matrix_counter) := l_pd_amt38;
              l_amount_tab39(l_matrix_counter) := l_pd_amt39;
              l_amount_tab40(l_matrix_counter) := l_pd_amt40;
              l_amount_tab41(l_matrix_counter) := l_pd_amt41;
              l_amount_tab42(l_matrix_counter) := l_pd_amt42;
              l_amount_tab43(l_matrix_counter) := l_pd_amt43;
              l_amount_tab44(l_matrix_counter) := l_pd_amt44;
              l_amount_tab45(l_matrix_counter) := l_pd_amt45;
              l_amount_tab46(l_matrix_counter) := l_pd_amt46;
              l_amount_tab47(l_matrix_counter) := l_pd_amt47;
              l_amount_tab48(l_matrix_counter) := l_pd_amt48;
              l_amount_tab49(l_matrix_counter) := l_pd_amt49;
              l_amount_tab50(l_matrix_counter) := l_pd_amt50;
              l_amount_tab51(l_matrix_counter) := l_pd_amt51;
              l_amount_tab52(l_matrix_counter) := l_pd_amt52;
              l_parent_assignment_id_tab(l_matrix_counter):= l_parent_assign_id_local;
              l_matrix_counter := l_matrix_counter + 1;
           END IF;
           /* end if for the sql row count = 0 */

       ELSE
           /* for currency type other than transaction */
        BEGIN
                UPDATE Pa_Proj_Periods_Denorm SET
                   preceding_periods_amount     = l_prev_amt,
                   succeeding_periods_amount    = l_next_amt,
                   prior_period_amount          = l_prior_amt,
                   period_amount1  = NVL(period_amount1,0) + l_pd_amt1,
		      period_amount2  = NVL(period_amount2,0) + l_pd_amt2,
		      period_amount3  = NVL(period_amount3,0) + l_pd_amt3,
		      period_amount4  = NVL(period_amount4,0) + l_pd_amt4,
		      period_amount5  = NVL(period_amount5,0) + l_pd_amt5,
		      period_amount6  = NVL(period_amount6,0) + l_pd_amt6,
		      period_amount7  = NVL(period_amount7,0) + l_pd_amt7,
		      period_amount8  = NVL(period_amount8,0) + l_pd_amt8,
		      period_amount9  = NVL(period_amount9,0) + l_pd_amt9,
		      period_amount10  = NVL(period_amount10,0) + l_pd_amt10,
		      period_amount11  = NVL(period_amount11,0) + l_pd_amt11,
		      period_amount12  = NVL(period_amount12,0) + l_pd_amt12,
		      period_amount13  = NVL(period_amount13,0) + l_pd_amt13,
		      period_amount14  = NVL(period_amount14,0) + l_pd_amt14,
		      period_amount15  = NVL(period_amount15,0) + l_pd_amt15,
		      period_amount16  = NVL(period_amount16,0) + l_pd_amt16,
		      period_amount17  = NVL(period_amount17,0) + l_pd_amt17,
		      period_amount18  = NVL(period_amount18,0) + l_pd_amt18,
		      period_amount19  = NVL(period_amount19,0) + l_pd_amt19,
		      period_amount20  = NVL(period_amount20,0) + l_pd_amt20,
		      period_amount21  = NVL(period_amount21,0) + l_pd_amt21,
		      period_amount22  = NVL(period_amount22,0) + l_pd_amt22,
		      period_amount23  = NVL(period_amount23,0) + l_pd_amt23,
		      period_amount24  = NVL(period_amount24,0) + l_pd_amt24,
		      period_amount25  = NVL(period_amount25,0) + l_pd_amt25,
		      period_amount26  = NVL(period_amount26,0) + l_pd_amt26,
		      period_amount27  = NVL(period_amount27,0) + l_pd_amt27,
		      period_amount28  = NVL(period_amount28,0) + l_pd_amt28,
		      period_amount29  = NVL(period_amount29,0) + l_pd_amt29,
		      period_amount30  = NVL(period_amount30,0) + l_pd_amt30,
		      period_amount31  = NVL(period_amount31,0) + l_pd_amt31,
		      period_amount32  = NVL(period_amount32,0) + l_pd_amt32,
		      period_amount33  = NVL(period_amount33,0) + l_pd_amt33,
		      period_amount34  = NVL(period_amount34,0) + l_pd_amt34,
		      period_amount35  = NVL(period_amount35,0) + l_pd_amt35,
		      period_amount36  = NVL(period_amount36,0) + l_pd_amt36,
		      period_amount37  = NVL(period_amount37,0) + l_pd_amt37,
		      period_amount38  = NVL(period_amount38,0) + l_pd_amt38,
		      period_amount39  = NVL(period_amount39,0) + l_pd_amt39,
		      period_amount40  = NVL(period_amount40,0) + l_pd_amt40,
		      period_amount41  = NVL(period_amount41,0) + l_pd_amt41,
		      period_amount42  = NVL(period_amount42,0) + l_pd_amt42,
		      period_amount43  = NVL(period_amount43,0) + l_pd_amt43,
		      period_amount44  = NVL(period_amount44,0) + l_pd_amt44,
		      period_amount45  = NVL(period_amount45,0) + l_pd_amt45,
		      period_amount46  = NVL(period_amount46,0) + l_pd_amt46,
		      period_amount47  = NVL(period_amount47,0) + l_pd_amt47,
		      period_amount48  = NVL(period_amount48,0) + l_pd_amt48,
		      period_amount49  = NVL(period_amount49,0) + l_pd_amt49,
		      period_amount50  = NVL(period_amount50,0) + l_pd_amt50,
		      period_amount51  = NVL(period_amount51,0) + l_pd_amt51,
                   period_amount52  = NVL(period_amount52,0) + l_pd_amt52,
                   parent_assignment_id = DECODE(l_parent_assign_id, NULL, l_parent_assignment_id, l_parent_assign_id),
                   LAST_UPDATE_LOGIN = l_last_update_login,
                   LAST_UPDATED_BY   = l_last_updated_by,
                   LAST_UPDATE_DATE  = l_last_update_date
                   WHERE
                   Budget_Version_Id      = p_budget_version_id AND
                   project_id = p_project_id AND
                   Resource_Assignment_Id = l_res_asg_id AND
                   Object_Id              = l_obj_id AND
                   Object_Type_Code       = l_obj_type_code AND
                   Amount_Type_Code       = l_amt_type_code AND
                   Amount_Subtype_Code    = l_amt_subtype_code AND
                   Currency_Type          = l_currency_type    AND
                   Currency_Code          = l_currency_code;
           IF SQL%ROWCOUNT = 0 THEN
           INSERT INTO  Pa_Proj_Periods_Denorm
           (    CREATION_DATE ,
                CREATED_BY ,
                LAST_UPDATE_LOGIN ,
                LAST_UPDATED_BY ,
                LAST_UPDATE_DATE ,
                Project_Id,
                Budget_Version_Id,
                Resource_Assignment_Id,
                Period_Profile_Id,
                Object_Id,
                Object_Type_Code,
                Currency_Type,
                Currency_Code,
                Amount_Type_Code,
                Amount_Subtype_Code,
                Preceding_Periods_Amount ,
                Succeeding_Periods_Amount ,
                Prior_Period_Amount,
                Period_Amount1 ,
                Period_Amount2 ,
                Period_Amount3 ,
                Period_Amount4 ,
                Period_Amount5 ,
                Period_Amount6 ,
                Period_Amount7 ,
                Period_Amount8 ,
                Period_Amount9 ,
                Period_Amount10 ,
                Period_Amount11 ,
                Period_Amount12 ,
                Period_Amount13 ,
                Period_Amount14 ,
                Period_Amount15 ,
                Period_Amount16 ,
                Period_Amount17 ,
                Period_Amount18 ,
                Period_Amount19 ,
                Period_Amount20 ,
                Period_Amount21 ,
                Period_Amount22 ,
                Period_Amount23 ,
                Period_Amount24 ,
                Period_Amount25 ,
                Period_Amount26 ,
                Period_Amount27 ,
                Period_Amount28 ,
                Period_Amount29 ,
                Period_Amount30 ,
                Period_Amount31 ,
                Period_Amount32 ,
                Period_Amount33 ,
                Period_Amount34 ,
                Period_Amount35 ,
                Period_Amount36 ,
                Period_Amount37 ,
                Period_Amount38 ,
                Period_Amount39 ,
                Period_Amount40 ,
                Period_Amount41 ,
                Period_Amount42 ,
                Period_Amount43 ,
                Period_Amount44 ,
                Period_Amount45 ,
                Period_Amount46 ,
                Period_Amount47 ,
                Period_Amount48 ,
                Period_Amount49 ,
                Period_Amount50 ,
                Period_Amount51 ,
                Period_Amount52 ,
                parent_assignment_id,
                Amount_Type_Id,
                Amount_SubType_Id )
        VALUES(
                l_creation_date ,
                l_created_by ,
                l_last_update_login ,
                l_last_updated_by ,
                l_last_update_date ,
                p_project_id,
                p_budget_version_id,
                l_res_asg_id,
                p_period_profile_id,
                l_obj_id,
                l_obj_type_code,
                l_currency_type,
                l_currency_code,
                l_amt_type_code,
                l_amt_subtype_code,
                l_prev_amt,
                l_next_amt,
                l_prior_amt,
                 l_pd_amt1,
                 l_pd_amt2,
                 l_pd_amt3,
                 l_pd_amt4,
                 l_pd_amt5,
                 l_pd_amt6,
                 l_pd_amt7,
                 l_pd_amt8,
                 l_pd_amt9,
                 l_pd_amt10,
                 l_pd_amt11,
                 l_pd_amt12,
                 l_pd_amt13,
                 l_pd_amt14,
                 l_pd_amt15,
                 l_pd_amt16,
                 l_pd_amt17,
                 l_pd_amt18,
                 l_pd_amt19,
                 l_pd_amt20,
                 l_pd_amt21,
                 l_pd_amt22,
                 l_pd_amt23,
                 l_pd_amt24,
                 l_pd_amt25,
                 l_pd_amt26,
                 l_pd_amt27,
                 l_pd_amt28,
                 l_pd_amt29,
                 l_pd_amt30,
                 l_pd_amt31,
                 l_pd_amt32,
                 l_pd_amt33,
                 l_pd_amt34,
                 l_pd_amt35,
                 l_pd_amt36,
                 l_pd_amt37,
                 l_pd_amt38,
                 l_pd_amt39,
                 l_pd_amt40,
                 l_pd_amt41,
                 l_pd_amt42,
                 l_pd_amt43,
                 l_pd_amt44,
                 l_pd_amt45,
                 l_pd_amt46,
                 l_pd_amt47,
                 l_pd_amt48,
                 l_pd_amt49,
                 l_pd_amt50,
                 l_pd_amt51,
                 l_pd_amt52,
                 DECODE(l_parent_assign_id, NULL, l_parent_assignment_id, l_parent_assign_id),
                 l_amt_type_id,
                 l_amt_subtype_id
                );
             END IF;
             /* End if for the IF in zero row counts in update */
      EXCEPTION
        WHEN OTHERS THEN
          FND_MSG_PUB.add_exc_msg
               ( p_pkg_name       => 'PA_PLAN_MATRIX.maintain_plan_matrix'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack);
          IF P_PA_DEBUG_MODE = 'Y' THEN
                  PA_DEBUG.g_err_stage := 'Exception while trying to insert ' ||
                  'data in proj denorm table';
                  PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
          END IF;
          IF p_add_msg_in_stack = 'Y' THEN
                        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                          p_msg_name       => 'PA_FP_UNEX_ERR_DENORM_IN');
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_data      := 'PA_FP_UNEX_ERR_DENORM_IN';
          PA_DEBUG.Reset_Curr_Function;
          RAISE;
      END;
        END IF;
      /* end if for the currency_type differentiator */
      END IF;
     /* End if for the quantity filter flag */
   END IF;
       /*  end if for valid amount flag   */
       /* PA_DEBUG.g_err_stage := 'moving to next amount type';
       PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);   */
END LOOP;
    /*  end loop for amount type loop    */
END LOOP;
  /* end loop for main cursor  */

    IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'bef bulk insert into pds denorm';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

     FORALL l_ins_temp IN 1  .. l_amount_tab50.count
     INSERT INTO  Pa_Proj_Periods_Denorm(
     CREATION_DATE ,
     CREATED_BY ,
     LAST_UPDATE_LOGIN ,
     LAST_UPDATED_BY ,
     LAST_UPDATE_DATE ,
     Project_Id,
     Budget_Version_Id,
     Resource_Assignment_Id,
     Period_Profile_Id,
     Object_Id,
     Object_Type_Code,
     Currency_Type,
     Currency_Code,
     Amount_Type_Code,
     Amount_Subtype_Code,
     Preceding_Periods_Amount ,
     Succeeding_Periods_Amount ,
     Prior_Period_Amount,
     Period_Amount1 ,
     Period_Amount2 ,
     Period_Amount3 ,
     Period_Amount4 ,
     Period_Amount5 ,
     Period_Amount6 ,
     Period_Amount7 ,
     Period_Amount8 ,
     Period_Amount9 ,
     Period_Amount10 ,
     Period_Amount11 ,
     Period_Amount12 ,
     Period_Amount13 ,
     Period_Amount14 ,
     Period_Amount15 ,
     Period_Amount16 ,
     Period_Amount17 ,
     Period_Amount18 ,
     Period_Amount19 ,
     Period_Amount20 ,
     Period_Amount21 ,
     Period_Amount22 ,
     Period_Amount23 ,
     Period_Amount24 ,
     Period_Amount25 ,
     Period_Amount26 ,
     Period_Amount27 ,
     Period_Amount28 ,
     Period_Amount29 ,
     Period_Amount30 ,
     Period_Amount31 ,
     Period_Amount32 ,
     Period_Amount33 ,
     Period_Amount34 ,
     Period_Amount35 ,
     Period_Amount36 ,
     Period_Amount37 ,
     Period_Amount38 ,
     Period_Amount39 ,
     Period_Amount40 ,
     Period_Amount41 ,
     Period_Amount42 ,
     Period_Amount43 ,
     Period_Amount44 ,
     Period_Amount45 ,
     Period_Amount46 ,
     Period_Amount47 ,
     Period_Amount48 ,
     Period_Amount49 ,
     Period_Amount50 ,
     Period_Amount51 ,
     Period_Amount52 ,
     Parent_Assignment_Id,
     Amount_Type_Id,
     Amount_SubType_Id )
     VALUES(
     l_creation_date ,
     l_created_by ,
     l_last_update_login ,
     l_last_updated_by ,
     l_last_update_date ,
     p_project_id,
     p_budget_version_id,
     l_res_asg_id_tab(l_ins_temp),
     p_period_profile_id,
     l_obj_id_tab(l_ins_temp),
     l_obj_type_code_tab(l_ins_temp),
     l_currency_type_tab(l_ins_temp),
     l_currency_code_tab(l_ins_temp),
     l_amt_type_tab(l_ins_temp),
     l_amt_subtype_tab(l_ins_temp),
     l_prev_amt_tab(l_ins_temp),
     l_next_amt_tab(l_ins_temp),
     l_prior_amt_tab(l_ins_temp),
     l_amount_tab1(l_ins_temp),
     l_amount_tab2(l_ins_temp),
     l_amount_tab3(l_ins_temp),
     l_amount_tab4(l_ins_temp),
     l_amount_tab5(l_ins_temp),
     l_amount_tab6(l_ins_temp),
     l_amount_tab7(l_ins_temp),
     l_amount_tab8(l_ins_temp),
     l_amount_tab9(l_ins_temp),
     l_amount_tab10(l_ins_temp),
     l_amount_tab11(l_ins_temp),
     l_amount_tab12(l_ins_temp),
     l_amount_tab13(l_ins_temp),
     l_amount_tab14(l_ins_temp),
     l_amount_tab15(l_ins_temp),
     l_amount_tab16(l_ins_temp),
     l_amount_tab17(l_ins_temp),
     l_amount_tab18(l_ins_temp),
     l_amount_tab19(l_ins_temp),
     l_amount_tab20(l_ins_temp),
     l_amount_tab21(l_ins_temp),
     l_amount_tab22(l_ins_temp),
     l_amount_tab23(l_ins_temp),
     l_amount_tab24(l_ins_temp),
     l_amount_tab25(l_ins_temp),
     l_amount_tab26(l_ins_temp),
     l_amount_tab27(l_ins_temp),
     l_amount_tab28(l_ins_temp),
     l_amount_tab29(l_ins_temp),
     l_amount_tab30(l_ins_temp),
     l_amount_tab31(l_ins_temp),
     l_amount_tab32(l_ins_temp),
     l_amount_tab33(l_ins_temp),
     l_amount_tab34(l_ins_temp),
     l_amount_tab35(l_ins_temp),
     l_amount_tab36(l_ins_temp),
     l_amount_tab37(l_ins_temp),
     l_amount_tab38(l_ins_temp),
     l_amount_tab39(l_ins_temp),
     l_amount_tab40(l_ins_temp),
     l_amount_tab41(l_ins_temp),
     l_amount_tab42(l_ins_temp),
     l_amount_tab43(l_ins_temp),
     l_amount_tab44(l_ins_temp),
     l_amount_tab45(l_ins_temp),
     l_amount_tab46(l_ins_temp),
     l_amount_tab47(l_ins_temp),
     l_amount_tab48(l_ins_temp),
     l_amount_tab49(l_ins_temp),
     l_amount_tab50(l_ins_temp),
     l_amount_tab51(l_ins_temp),
     l_amount_tab52(l_ins_temp),
     l_parent_assignment_id_tab(l_ins_temp),
     l_amt_type_id_tab(l_ins_temp),
     l_amt_subtype_id_tab(l_ins_temp)
     );

    IF P_PA_DEBUG_MODE = 'Y' THEN
             PA_DEBUG.g_err_stage := 'after bulk insert into pds denorm and returning';
             PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
    END IF;

  /* Commit interval is not decided yet.  So, commiting at the end */
  IF NVL(P_COMMIT_FLAG,'N') = 'Y' THEN
     COMMIT;
  END IF;
  PA_DEBUG.Reset_Curr_Function;
  RETURN;
  EXCEPTION
        WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_PLAN_MATRIX.maintain_plan_matrix'
              ,p_procedure_name => PA_DEBUG.G_Err_Stack);
        IF P_PA_DEBUG_MODE = 'Y' THEN
                PA_DEBUG.g_err_stage := 'Unexpected error in maintain plan matrix ' ||
                'PD-Txn data from budget lines table';
                PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);
        END IF;
        IF p_add_msg_in_stack = 'Y' THEN
                PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                p_msg_name       => 'PA_FP_UNEX_ERR_DENORM_IN');
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data      := 'PA_FP_UNEX_ERR_DENORM_IN';
        PA_DEBUG.Reset_Curr_Function;
        RAISE;
END Maintain_Plan_Matrix;

END PA_PLAN_MATRIX;

/
