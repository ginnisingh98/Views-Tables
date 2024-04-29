--------------------------------------------------------
--  DDL for Package Body PA_ACCUM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACCUM_UTILS" AS
/* $Header: PAACUTIB.pls 120.1 2005/08/19 16:15:02 mwasowic noship $ */

-- Proj_level_record -  This verifies for the existence of the Project level
--                      record (Task id = 0 and Resource list member id = 0)
--                      If available, returns the Project_Accum_id else
--                      creates a record in PA_PROJECT_ACCUM_HEADERS and
--                      returns the Project_Accum_Id





Procedure   Proj_level_record (x_project_id In Number,
                               x_current_pa_period In Varchar2,
                               x_current_gl_period In Varchar2,
                               x_impl_Option  In Varchar2,
                               x_accum_id Out NOCOPY Number, --File.Sql.39 bug 4440895
                               x_prev_accum_period Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                               x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                               x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                               x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


V_accum_id            Number := 0;
V_prev_accum_period   Varchar2(30);
v_current_period      Varchar2(30);
V_Old_Stack       Varchar2(630);
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
Begin
   V_Old_Stack := x_err_stack;
   x_err_stack :=
   x_err_stack||'->PA_ACCUM_UTILS.Proj_level_record';

   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      pa_debug.debug('Proj_level_record: ' || x_err_stack);
   END IF;

   --   Check whether Implementation option is PA or GL , based on which the
   --   current period is set
      If x_impl_option = 'PA' then
         v_current_period := X_current_pa_period;
      Else
         v_current_period := X_current_gl_period;
      End If;

   --   Select the Project level record. The project level record has
   --   Task id, resource list id ,resource id and resource list member id = 0
      SELECT Project_Accum_Id,
             Accum_Period
      INTO
             V_Accum_id,
             V_prev_accum_period
      FROM
      PA_PROJECT_ACCUM_HEADERS
      WHERE Project_id = X_project_id
      AND Task_id    = 0
      AND Resource_List_id = 0
      AND Resource_List_member_id = 0
      AND Resource_id = 0 ;

      X_accum_id := V_Accum_id;
      X_Prev_Accum_period := v_prev_accum_period;

      -- Restore the old x_err_stack;

      x_err_stack := V_Old_Stack;

 EXCEPTION
-- If there is no Project level record, then create the same.

    WHEN NO_DATA_FOUND THEN

         IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
            pa_debug.debug('Proj_level_record: ' || 'Creating Project Level Header Record');
         END IF;

         SELECT PA_PROJECT_ACCUM_HEADERS_S.Nextval
         INTO V_accum_id
         FROM Dual;
         INSERT INTO PA_PROJECT_ACCUM_HEADERS
                     (PROJECT_ACCUM_ID,
                      PROJECT_ID,
                      TASK_ID,
                      ACCUM_PERIOD,
                      RESOURCE_ID,
                      RESOURCE_LIST_ID,
                      RESOURCE_LIST_MEMBER_ID,
                      RESOURCE_LIST_ASSIGNMENT_ID,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      REQUEST_ID,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_LOGIN )
         VALUES   (V_Accum_id,
                   X_project_id,
                   0,
                   v_current_period,
                   0,
                   0,
                   0,
                   0,
                   trunc(sysdate),
                   pa_proj_accum_main.x_last_updated_by,
                   pa_proj_accum_main.x_request_id,
                   trunc(sysdate),
                   pa_proj_accum_main.x_created_by,
                   pa_proj_accum_main.x_last_update_login );
-- Create Actuals record for the Project level record

       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          pa_debug.debug('Proj_level_record: ' || 'Creating Project Level Header record for Actuals');
       END IF;

       INSERT INTO PA_PROJECT_ACCUM_ACTUALS (
       PROJECT_ACCUM_ID,RAW_COST_ITD,RAW_COST_YTD,RAW_COST_PP,RAW_COST_PTD,
       BILLABLE_RAW_COST_ITD,BILLABLE_RAW_COST_YTD,BILLABLE_RAW_COST_PP,
       BILLABLE_RAW_COST_PTD,BURDENED_COST_ITD,BURDENED_COST_YTD,
       BURDENED_COST_PP,BURDENED_COST_PTD,BILLABLE_BURDENED_COST_ITD,
       BILLABLE_BURDENED_COST_YTD,BILLABLE_BURDENED_COST_PP,
       BILLABLE_BURDENED_COST_PTD,QUANTITY_ITD,QUANTITY_YTD,QUANTITY_PP,
       QUANTITY_PTD,LABOR_HOURS_ITD,LABOR_HOURS_YTD,LABOR_HOURS_PP,
       LABOR_HOURS_PTD,BILLABLE_QUANTITY_ITD,BILLABLE_QUANTITY_YTD,
       BILLABLE_QUANTITY_PP,BILLABLE_QUANTITY_PTD,
       BILLABLE_LABOR_HOURS_ITD,BILLABLE_LABOR_HOURS_YTD,
       BILLABLE_LABOR_HOURS_PP,BILLABLE_LABOR_HOURS_PTD,REVENUE_ITD,
       REVENUE_YTD,REVENUE_PP,REVENUE_PTD,TXN_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) VALUES
       (V_Accum_id,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,Null,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);

-- Create commitments record for the Project level record

       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          pa_debug.debug('Proj_level_record: ' || 'Creating Project Level Header record for Commitments');
       END IF;

       INSERT INTO PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN ) VALUES
       (V_Accum_Id,0,0,0,0,0,0,0,0,0,0,0,0,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(Sysdate),
        Trunc(Sysdate), pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
       x_Accum_id := V_Accum_id;
       x_prev_accum_period := Null;
--      Restore the old x_err_stack;
              x_err_stack := V_Old_Stack;
  When Others Then
       x_err_code := SQLCODE;
       RAISE ;
 End proj_level_record;

-- Get_Impl_Option   -  This returns the Accumulation option as specified
--                      in PA_IMPLEMENTATIONS table . Returns whether
--                      accumulation is maintained by PA_PERIOD or GL_PERIOD

Procedure Get_Impl_Option (x_impl_option Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                           x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                           x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                           x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


V_Old_Stack       Varchar2(630);
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
Begin
    V_Old_Stack := x_err_stack;
    x_err_stack :=
    x_err_stack||'->PA_ACCUM_UTILS.Get_Impl_Option';

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('Get_Impl_Option: ' || x_err_stack);
    END IF;

    SELECT accumulation_period_type
    INTO x_impl_option
    FROM pa_implementations;

    -- Restore the old x_err_stack;
    x_err_stack := V_Old_Stack;

Exception
  When Others then
      x_err_code := SQLCODE;
      RAISE ;
End get_impl_option;

-- Get_Current_period_Info - This returns all relevant details pertaining
--                           to the current pa period

Procedure Get_Current_period_Info   (x_Current_Pa_Period  Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_Current_gl_period Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_current_pa_start_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                                     x_current_pa_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                                     x_current_gl_start_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                                     x_current_gl_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                                     x_current_year      Out NOCOPY Number, --File.Sql.39 bug 4440895
                                     x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

V_Old_Stack       Varchar2(630);
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
Begin
   V_Old_Stack := x_err_stack;
   x_err_stack :=
   x_err_stack||'->PA_ACCUM_UTILS.Get_Current_period_Info';

   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      pa_debug.debug('Get_Current_period_Info: ' || x_err_stack);
   END IF;
/* Commented out for the bug#2634995
   SELECT
    period_name,
    gl_period_name,
    pa_start_date,
    pa_end_date,
    gl_start_date,
    gl_end_date,
    period_year
  INTO
    x_current_pa_period,
    x_current_gl_period,
    x_current_pa_start_date,
    x_current_pa_end_date,
    x_current_gl_start_date,
    x_current_gl_end_date,
    x_current_year
  FROM pa_periods_v
  WHERE
    current_pa_period_flag = 'Y';
 */

  /* Replaced the query from pa_periods_v with the view definition Bug #2634995*/
   SELECT pap.period_name,
              pap.gl_period_name,
              pap.start_date,
              pap.end_date,
              glp.start_date,
              glp.end_date,
              glp.period_year
   INTO
              x_current_pa_period,
              x_current_gl_period,
              x_current_pa_start_date,
              x_current_pa_end_date,
              x_current_gl_start_date,
              x_current_gl_end_date,
              x_current_year
  FROM PA_PERIODS PAP, GL_PERIOD_STATUSES GLP,
       PA_IMPLEMENTATIONS PAIMP, PA_LOOKUPS PAL
 WHERE PAP.GL_PERIOD_NAME = GLP.PERIOD_NAME
   AND GLP.SET_OF_BOOKS_ID = PAIMP.SET_OF_BOOKS_ID
   AND GLP.APPLICATION_ID = Pa_Period_Process_Pkg.Application_id
   AND GLP.ADJUSTMENT_PERIOD_FLAG = 'N'
   AND PAL.LOOKUP_TYPE = 'CLOSING STATUS'
   AND PAL.LOOKUP_CODE =  PAP.STATUS
   AND PAP.current_pa_period_flag = 'Y';

  -- Restore the old x_err_stack;
  x_err_stack := V_Old_Stack;

Exception
    WHEN NO_DATA_FOUND THEN
         IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
            pa_debug.debug('Get_Current_period_Info: ' || '****REPORTING PERIOD NOT SET*****',pa_debug.DEBUG_LEVEL_EXCEPTION);
            pa_debug.debug('Get_Current_period_Info: ' || '****SET REPORTING PERIOD AND RE-RUN PROCESS *****',pa_debug.DEBUG_LEVEL_EXCEPTION);
         END IF;
         x_err_code := SQLCODE;
         RAISE;
    WHEN OTHERS THEN
         x_err_code := SQLCODE;
         RAISE;
End Get_Current_period_Info;

-- Get_pa_period_info      - This returns all details pertaining to the
--                           following
--                           Current Pa period,Previous pa period, current
--                           gl period , previous gl period, year pertaining
--                           to the previously accumulated period

Procedure Get_pa_period_Info (x_impl_opt  In Varchar2,
                              x_prev_accum_period in Varchar2,
                              x_current_Pa_Period In Varchar2,
                              x_current_gl_period In Varchar2,
                              x_current_pa_start_date In Date,
                              x_current_pa_end_date In Date,
                              x_current_gl_start_date In Date,
                              x_current_gl_end_date In Date,
                              x_prev_pa_period    Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_prev_gl_period    Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_prev_pa_year      Out NOCOPY Number, --File.Sql.39 bug 4440895
                              x_prev_gl_year      Out NOCOPY Number, --File.Sql.39 bug 4440895
                              x_prev_accum_year   Out NOCOPY number, --File.Sql.39 bug 4440895
                              x_prev_pa_start_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                              x_prev_pa_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                              x_prev_gl_start_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                              x_prev_gl_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                              x_prev_accum_start_date In Out NOCOPY Date, --File.Sql.39 bug 4440895
                              x_prev_accum_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                              x_prev_prev_accum_period Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_accum_period_type_changed IN OUT NOCOPY BOOLEAN, --File.Sql.39 bug 4440895
                              x_err_stack          In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage          In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code           In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

V_Old_Stack       Varchar2(630);
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
BEGIN
   V_Old_Stack := x_err_stack;
   x_err_stack :=
   x_err_stack||'->PA_ACCUM_UTILS.Get_pa_period_Info';
   x_accum_period_type_changed := FALSE;

   -- Select the details pertaining to the previous pa period.

   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      pa_debug.debug('Get_pa_period_Info: ' || x_err_stack);
   END IF;

   <<prev_pa_period>>
   BEGIN
     SELECT
        PERIOD_NAME,
        PERIOD_YEAR,
        PA_START_DATE,
        PA_END_DATE
     INTO
        x_prev_pa_period,
        x_prev_pa_year,
        x_prev_pa_start_date,
        x_prev_pa_end_date
     FROM
        PA_PERIODS_V
     WHERE pa_start_date =
        (SELECT max(start_date)
         FROM
         pa_periods
         WHERE start_date < x_current_pa_start_date);

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         -- The current pa_period is the first period defined
         x_prev_pa_period := NULL;
         x_prev_pa_year := NULL;
         x_prev_pa_start_date := NULL;
         x_prev_pa_end_date := NULL;

       WHEN OTHERS THEN
         x_err_code := SQLCODE;
         RAISE;
    END prev_pa_period;

    -- Select the details pertaining to the previous gl period.

    <<prev_gl_period>>
    BEGIN

      SELECT
         DISTINCT gl_period_name,
         period_year,
         gl_start_date,
         gl_end_date
      INTO
         x_prev_gl_period,
         x_prev_gl_year,
         x_prev_gl_start_date,
         x_prev_gl_end_date
      FROM
         pa_periods_v
      WHERE
         gl_start_date =
           (SELECT max(gl_start_date)
            FROM pa_periods_v
            WHERE
            gl_start_date < x_current_gl_start_date);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           -- current gl_period is the first period defined
           x_prev_gl_period := NULL;
           x_prev_gl_year := NULL;
           x_prev_gl_start_date := NULL;
           x_prev_gl_end_date := NULL;
        WHEN OTHERS THEN
           x_err_code := SQLCODE;
           RAISE;
    END prev_gl_period;

    -- If the project had been previously accumulated, then get the details
    -- pertaining to the previously accumulated period

    If x_prev_accum_period is not Null Then
         BEGIN

            If x_impl_opt = 'PA' Then
               Select PERIOD_YEAR,PA_START_DATE,PA_END_DATE
               into x_prev_accum_year,x_prev_accum_start_date,
                    x_prev_accum_end_date from
               PA_PERIODS_V WHERE Period_name = x_prev_accum_period;
            Elsif
               x_impl_opt = 'GL' Then
               Select Distinct PERIOD_YEAR,GL_START_DATE,GL_END_DATE
               into x_prev_accum_year,x_prev_accum_start_date,
                    x_prev_accum_end_date  from
               PA_PERIODS_V WHERE Gl_Period_name = x_prev_accum_period;
            End If;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
              -- Accumulation period type must have changed
              -- Bug #572031
              x_accum_period_type_changed := TRUE;
         END;

         IF (x_accum_period_type_changed = FALSE) THEN

            -- Now get x_prev_prev_accum_period
            <<prev_prev_accum_period>>
            BEGIN
              SELECT DISTINCT
                DECODE(x_impl_opt,'PA',PERIOD_NAME,'GL',GL_PERIOD_NAME,PERIOD_NAME)
              INTO x_prev_prev_accum_period
              FROM
                pa_periods_v
              WHERE
                DECODE(x_impl_opt,
                'PA',pa_start_date,'GL',gl_start_date,pa_start_date) =
                     (SELECT max(DECODE(
                               x_impl_opt,'PA',pa_start_date,
                                        'GL',gl_start_date,pa_start_date))
                      FROM pa_periods_v
                      WHERE
                      DECODE(x_impl_opt,
                      'PA',pa_start_date,'GL',gl_start_date,pa_start_date)
                          < x_prev_accum_start_date);

             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    x_prev_prev_accum_period := NULL;
               WHEN OTHERS THEN
                    x_err_code := SQLCODE;
                    RAISE;
             END prev_prev_accum_period;
        END IF;  -- (x_accum_period_type_changed = FALSE)
    End If;
    -- Restore the old x_err_stack;
    x_err_stack := V_Old_Stack;
Exception
    When Others Then
         x_err_code := SQLCODE;
         RAISE ;
End Get_pa_period_Info;

-- Get_period_year_info      - This returns the start date
--                             of the current period year

Procedure Get_period_year_info (x_current_gl_period      In Varchar2,
                                x_period_yr_start_date   Out NOCOPY Date, --File.Sql.39 bug 4440895
                                x_err_stack              In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                x_err_stage              In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                x_err_code               In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

V_Old_Stack       Varchar2(630);
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
BEGIN
   V_Old_Stack := x_err_stack;
   x_err_stack :=
   x_err_stack||'->PA_ACCUM_UTILS.Get_period_year_Info';

   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      pa_debug.debug('Get_period_year_info: ' || x_err_stack);
   END IF;

   -- Get the period year start date

     SELECT
        DISTINCT YEAR_START_DATE
     INTO
        x_period_yr_start_date
     FROM
        GL_PERIOD_STATUSES gps, pa_implementations imp
     WHERE  gps.application_id = pa_period_process_pkg.application_id
        and gps.set_of_books_id = imp.set_of_books_id
        and gps.period_name = x_current_gl_period;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_period_yr_start_date := NULL;

       WHEN OTHERS THEN
         x_err_code := SQLCODE;
         RAISE;
End Get_period_year_info;

Procedure Check_Actuals_Details    ( x_project_id In Number,
                                     x_task_id    In Number,
                                     x_resource_list_member_id In Number,
                                     x_recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                     x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Check_Actuals_Details   - For the given Project,Task and Resource
--                           combination in the PA_PROJECT_ACCUM_HEADERS table,
--                           checks for detail records in
--                           PA_PROJECT_ACCUM_ACTUALS table. It is possible
--                           that the Headers table might have a record
--                           but no corresponding detail record. This procedure
--                           creates the detail records for all the tasks in
--                           the hierarchy

V_Accum_id Number := 0;
V_recs_processed Number := 0;
V_Task_Array  task_id_tabtype;
V_Task_id   Number := 0;
V_Noof_Tasks Number := 0;
V_err_code Number := 0;
V_Old_Stack       Varchar2(630);

-- This cursor gets the Accum_id for the given Project,Task and Resource
-- combination which has a record in PA_PROJECT_ACCUM_HEADERS but no
-- corresponding record in PA_PROJECT_ACCUM_ACTUALS.

CURSOR Get_Accum_Id_Cur is
Select Project_accum_id
FROM
PA_PROJECT_ACCUM_HEADERS PAH
WHERE Project_id = x_project_id
and TASK_ID = V_task_id
and RESOURCE_LIST_MEMBER_ID = x_resource_list_member_id
and not exists
(Select Project_accum_id
from
PA_PROJECT_ACCUM_ACTUALS paa
where paa.project_accum_id = pah.project_accum_id);

Begin
     V_Old_Stack := x_err_stack;
     x_err_stack :=
     x_err_stack||'->PA_ACCUM_UTILS.Check_Actuals_Details';
     V_task_id  := X_Task_id;
     Open Get_Accum_Id_Cur;
     Fetch Get_Accum_Id_Cur Into V_Accum_id;
-- If we get such a record in Headers, then we insert one record in
-- the Actuals Detail table

     If Get_Accum_Id_Cur%FOUND Then
       Insert into PA_PROJECT_ACCUM_ACTUALS (
       PROJECT_ACCUM_ID,RAW_COST_ITD,RAW_COST_YTD,RAW_COST_PP,RAW_COST_PTD,
       BILLABLE_RAW_COST_ITD,BILLABLE_RAW_COST_YTD,BILLABLE_RAW_COST_PP,
       BILLABLE_RAW_COST_PTD,BURDENED_COST_ITD,BURDENED_COST_YTD,
       BURDENED_COST_PP,BURDENED_COST_PTD,BILLABLE_BURDENED_COST_ITD,
       BILLABLE_BURDENED_COST_YTD,BILLABLE_BURDENED_COST_PP,
       BILLABLE_BURDENED_COST_PTD,QUANTITY_ITD,QUANTITY_YTD,QUANTITY_PP,
       QUANTITY_PTD,LABOR_HOURS_ITD,LABOR_HOURS_YTD,LABOR_HOURS_PP,
       LABOR_HOURS_PTD,BILLABLE_QUANTITY_ITD,BILLABLE_QUANTITY_YTD,
       BILLABLE_QUANTITY_PP,BILLABLE_QUANTITY_PTD,
       BILLABLE_LABOR_HOURS_ITD,BILLABLE_LABOR_HOURS_YTD,
       BILLABLE_LABOR_HOURS_PP,BILLABLE_LABOR_HOURS_PTD,REVENUE_ITD,
       REVENUE_YTD,REVENUE_PP,REVENUE_PTD,TXN_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,0,0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,
        0,0,0,0,
        0,Null,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        V_recs_processed := 1;
     End If;
     Close Get_Accum_Id_Cur;
     V_noof_Tasks := 0;

     --Now get all the higher task ids for the current task
     --(if the task id <> 0,
     --since we may be passing the task id as 0 for the Project-resource
     --level records)

     If ( x_Task_id <> 0 ) Then
        Get_existing_higher_tasks (x_project_id,
                                   X_task_id,
                                   X_resource_list_member_id,
                                   V_task_array,
                                   V_noof_tasks,
                                   x_err_stack,
                                   x_err_stage,
                                   x_err_code);

      -- Insert the appropriate records in the Actuals table for all higher
      -- tasks, if they have not been created.

       IF v_noof_tasks > 0 then
          FOR i in 1..v_noof_tasks LOOP
          Insert into PA_PROJECT_ACCUM_ACTUALS (
          PROJECT_ACCUM_ID,RAW_COST_ITD,RAW_COST_YTD,RAW_COST_PP,RAW_COST_PTD,
          BILLABLE_RAW_COST_ITD,BILLABLE_RAW_COST_YTD,BILLABLE_RAW_COST_PP,
          BILLABLE_RAW_COST_PTD,BURDENED_COST_ITD,BURDENED_COST_YTD,
          BURDENED_COST_PP,BURDENED_COST_PTD,BILLABLE_BURDENED_COST_ITD,
          BILLABLE_BURDENED_COST_YTD,BILLABLE_BURDENED_COST_PP,
          BILLABLE_BURDENED_COST_PTD,QUANTITY_ITD,QUANTITY_YTD,QUANTITY_PP,
          QUANTITY_PTD,LABOR_HOURS_ITD,LABOR_HOURS_YTD,LABOR_HOURS_PP,
          LABOR_HOURS_PTD,BILLABLE_QUANTITY_ITD,BILLABLE_QUANTITY_YTD,
          BILLABLE_QUANTITY_PP,BILLABLE_QUANTITY_PTD,
          BILLABLE_LABOR_HOURS_ITD,BILLABLE_LABOR_HOURS_YTD,
          BILLABLE_LABOR_HOURS_PP,BILLABLE_LABOR_HOURS_PTD,REVENUE_ITD,
          REVENUE_YTD,REVENUE_PP,REVENUE_PTD,TXN_UNIT_OF_MEASURE,
          REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
          LAST_UPDATE_LOGIN)
          Select PAH.PROJECT_ACCUM_ID,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,Null,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
          Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login
          from
          PA_PROJECT_ACCUM_HEADERS PAH
          Where Project_Id = x_project_id
          and Task_id = v_task_array(i)
          and Resource_list_member_id = x_Resource_list_member_id
          and Not Exists
          (Select 'x'
          from
          PA_PROJECT_ACCUM_ACTUALS PAA
          Where
          PAH.PROJECT_ACCUM_ID = PAA.PROJECT_ACCUM_ID);
          v_recs_processed := V_recs_processed + 1;
       END LOOP; -- (i in 1..v_noof_tasks LOOP )
      End If; -- (v_noof_tasks > 0)
     End If;  -- (v_recs_processed = 1 and x_Task_id <> 0)
     x_recs_processed := v_recs_processed;

--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
   When Others Then
         x_err_code := SQLCODE;
         RAISE ;
End Check_Actuals_Details;

Procedure Check_Cmt_Details        ( x_project_id In Number,
                                     x_task_id    In Number,
                                     x_resource_list_member_id In Number,
                                     x_recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                     x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895


-- Check_Cmt_Details       - For the given Project,Task and Resource
--                           combination in the PA_PROJECT_ACCUM_HEADERS table,
--                           checks for detail records in
--                           PA_PROJECT_ACCUM_COMMITMENTS table. It is possible
--                           that the Headers table might have a record
--                           but no corresponding detail record. This procedure
--                           creates the detail records for all the tasks in
--                           the hierarchy

V_Accum_id Number := 0;
V_recs_processed Number := 0;
V_Task_Array  task_id_tabtype;
V_Task_id   Number := 0;
V_Noof_Tasks Number := 0;
V_err_code Number := 0;
V_Old_Stack       Varchar2(630);

-- This cursor gets the Accum_id for the given Project,Task and Resource
-- combination which has a record in PA_PROJECT_ACCUM_HEADERS but no
-- corresponding record in PA_PROJECT_ACCUM_COMMITMENTS

CURSOR Get_Accum_Id_Cur is
Select Project_accum_id
from
PA_PROJECT_ACCUM_HEADERS PAH
Where Project_id = x_project_id
and TASK_ID = V_task_id
and RESOURCE_LIST_MEMBER_ID = x_resource_list_member_id
and not exists
       (Select Project_accum_id
        from
        PA_PROJECT_ACCUM_COMMITMENTS pac
        where pac.project_accum_id = pah.project_accum_id);

Begin
     V_Old_Stack := x_err_stack;
     x_err_stack :=
     x_err_stack||'->PA_ACCUM_UTILS.Check_Cmt_Details';
     V_task_id  := X_Task_id;

     Open Get_Accum_Id_Cur;
     Fetch Get_Accum_Id_Cur Into V_Accum_id;

-- If we get such a record in Headers, then we insert one record in
-- the Commitments Detail table

     If Get_Accum_Id_Cur%FOUND Then
      Insert into PA_PROJECT_ACCUM_COMMITMENTS (
       PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
       CMT_RAW_COST_PTD,
       CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
       CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
       CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,
       CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
       CMT_UNIT_OF_MEASURE,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (v_Accum_id,0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        Null,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        v_recs_processed := 1;
     End If;
     Close Get_Accum_Id_Cur;
     V_noof_Tasks := 0;

     --Now get all the higher task ids for the current task
     --(if the task id <> 0,
     --since we may be passing the task id as 0 for the Project-resource
     --level records)

     If ( x_Task_id <> 0 ) Then
        Get_existing_higher_tasks (x_project_id,
                                   X_task_id,
                                   X_resource_list_member_id,
                                   V_task_array,
                                   V_noof_tasks,
                                   x_err_stack,
                                   x_err_stage,
                                   x_err_code);


      -- Insert the appropriate records in the Commitments table for all higher
      -- tasks, if they have not been created.

       If v_noof_tasks > 0 then
          FOR i in 1..v_noof_tasks LOOP
          Insert into PA_PROJECT_ACCUM_COMMITMENTS (
           PROJECT_ACCUM_ID,CMT_RAW_COST_ITD,CMT_RAW_COST_YTD,CMT_RAW_COST_PP,
           CMT_RAW_COST_PTD,
           CMT_BURDENED_COST_ITD,CMT_BURDENED_COST_YTD,
           CMT_BURDENED_COST_PP,CMT_BURDENED_COST_PTD,
           CMT_QUANTITY_ITD,CMT_QUANTITY_YTD,
           CMT_QUANTITY_PP,CMT_QUANTITY_PTD,
           CMT_UNIT_OF_MEASURE,
           REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
           LAST_UPDATE_LOGIN)
           Select PROJECT_ACCUM_ID,0,0,0,0,0,0,0,0,0,0,0,0,
           Null,pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(sysdate),
           Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login
           from PA_PROJECT_ACCUM_HEADERS PAH
           Where Project_Id = x_project_id and Task_id = v_task_array(i) and
           Resource_list_member_id = x_Resource_list_member_id  and
           Not Exists (Select 'x' from PA_PROJECT_ACCUM_COMMITMENTS PAC Where
           PAH.PROJECT_ACCUM_ID = PAC.PROJECT_ACCUM_ID);
           v_recs_processed := V_recs_processed + 1;
        END LOOP;
       End If;
     End If;
     x_recs_processed := v_recs_processed;

--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
   When Others Then
         x_err_code := SQLCODE;
         RAISE ;
End Check_Cmt_Details;

Procedure Check_Budget_Details    (  x_project_id In Number,
                                     x_task_id    In Number,
                                     x_resource_list_member_id In Number,
                                     x_Budget_type_code        In Varchar2,
                                     x_recs_processed Out NOCOPY Number, --File.Sql.39 bug 4440895
                                     x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                     x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- Check_Budget_Details    - For the given Project,Task and Resource
--                           combination in the PA_PROJECT_ACCUM_HEADERS table,
--                           checks for detail records in
--                           PA_PROJECT_ACCUM_COMMITMENTS table. It is possible
--                           that the Headers table might have a record
--                           but no corresponding detail record. This procedure
--                           creates the detail records for all the tasks in
--                           the hierarchy

V_Accum_id Number := 0;
V_recs_processed Number := 0;
V_Task_Array  task_id_tabtype;
V_Task_id   Number := 0;
V_Noof_Tasks Number := 0;
V_err_code Number := 0;
V_Old_Stack       Varchar2(630);

-- This cursor gets the Accum_id for the given Project,Task and Resource
-- combination which has a record in PA_PROJECT_ACCUM_HEADERS but no
-- corresponding record in PA_PROJECT_ACCUM_BUDGETS

CURSOR Get_Accum_Id_Cur IS
SELECT
Project_accum_id
FROM
PA_PROJECT_ACCUM_HEADERS PAH
WHERE Project_id = x_project_id
and TASK_ID = v_task_id
and RESOURCE_LIST_MEMBER_ID = x_resource_list_member_id
and not exists
       (Select Project_accum_id
        from
        PA_PROJECT_ACCUM_BUDGETS pab
        where pab.project_accum_id = pah.project_accum_id
        and pab.Budget_Type_Code = x_Budget_Type_Code);

Begin
     V_Old_Stack := x_err_stack;
     x_err_stack :=
     x_err_stack||'->PA_ACCUM_UTILS.Check_Budget_Details';
     V_task_id  := X_Task_id;
     Open Get_Accum_Id_Cur;
     Fetch Get_Accum_Id_Cur Into V_Accum_id;

     -- If we get such a record in Headers, then we insert one record in
     -- the Budgets Detail table

     If Get_Accum_Id_Cur%FOUND Then
       Insert into PA_PROJECT_ACCUM_BUDGETS (
       PROJECT_ACCUM_ID,BUDGET_TYPE_CODE,BASE_RAW_COST_ITD,BASE_RAW_COST_YTD,
       BASE_RAW_COST_PP, BASE_RAW_COST_PTD,
       BASE_BURDENED_COST_ITD,BASE_BURDENED_COST_YTD,
       BASE_BURDENED_COST_PP,BASE_BURDENED_COST_PTD,
       ORIG_RAW_COST_ITD,ORIG_RAW_COST_YTD,
       ORIG_RAW_COST_PP, ORIG_RAW_COST_PTD,
       ORIG_BURDENED_COST_ITD,ORIG_BURDENED_COST_YTD,
       ORIG_BURDENED_COST_PP,ORIG_BURDENED_COST_PTD,
       BASE_QUANTITY_ITD,BASE_QUANTITY_YTD,BASE_QUANTITY_PP,
       BASE_QUANTITY_PTD,
       ORIG_QUANTITY_ITD,ORIG_QUANTITY_YTD,ORIG_QUANTITY_PP,
       ORIG_QUANTITY_PTD,
       BASE_LABOR_HOURS_ITD,BASE_LABOR_HOURS_YTD,BASE_LABOR_HOURS_PP,
       BASE_LABOR_HOURS_PTD,
       ORIG_LABOR_HOURS_ITD,ORIG_LABOR_HOURS_YTD,ORIG_LABOR_HOURS_PP,
       ORIG_LABOR_HOURS_PTD,
       BASE_REVENUE_ITD,BASE_REVENUE_YTD,BASE_REVENUE_PP,BASE_REVENUE_PTD,
       ORIG_REVENUE_ITD,ORIG_REVENUE_YTD,ORIG_REVENUE_PP,ORIG_REVENUE_PTD,
       BASE_UNIT_OF_MEASURE,ORIG_UNIT_OF_MEASURE,
       BASE_RAW_COST_TOT,BASE_BURDENED_COST_TOT,ORIG_RAW_COST_TOT,
       ORIG_BURDENED_COST_TOT,BASE_REVENUE_TOT,ORIG_REVENUE_TOT,
       BASE_LABOR_HOURS_TOT,ORIG_LABOR_HOURS_TOT,BASE_QUANTITY_TOT,
       ORIG_QUANTITY_TOT,
       REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
       LAST_UPDATE_LOGIN) Values
       (V_Accum_id,x_budget_type_code,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,NULL,0,0,0,0,0,0,0,0,0,0,
        pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(Sysdate),Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login);
        v_recs_processed := 1;
    End If;
    Close Get_Accum_Id_Cur;
    V_noof_Tasks := 0;

     --Now get all the higher task ids for the current task
     --(if the task id <> 0,
     --since we may be passing the task id as 0 for the Project-resource
     --level records)

     If ( x_Task_id <> 0 ) Then
        Get_existing_higher_tasks (x_project_id,
                                   X_task_id,
                                   X_resource_list_member_id,
                                   V_task_array,
                                   V_noof_tasks,
                                   x_err_stack,
                                   x_err_stage,
                                   x_err_code);


      -- Insert the appropriate records in the Budgets table for all higher
      -- tasks, if they have not been created.

      If v_noof_tasks > 0 then
        FOR i in 1..v_noof_tasks LOOP
         Insert into PA_PROJECT_ACCUM_BUDGETS (
          PROJECT_ACCUM_ID,BUDGET_TYPE_CODE,BASE_RAW_COST_ITD,BASE_RAW_COST_YTD,
          BASE_RAW_COST_PP, BASE_RAW_COST_PTD,
          BASE_BURDENED_COST_ITD,BASE_BURDENED_COST_YTD,
          BASE_BURDENED_COST_PP,BASE_BURDENED_COST_PTD,
          ORIG_RAW_COST_ITD,ORIG_RAW_COST_YTD,
          ORIG_RAW_COST_PP, ORIG_RAW_COST_PTD,
          ORIG_BURDENED_COST_ITD,ORIG_BURDENED_COST_YTD,
          ORIG_BURDENED_COST_PP,ORIG_BURDENED_COST_PTD,
          BASE_QUANTITY_ITD,BASE_QUANTITY_YTD,BASE_QUANTITY_PP,
          BASE_QUANTITY_PTD,
          ORIG_QUANTITY_ITD,ORIG_QUANTITY_YTD,ORIG_QUANTITY_PP,
          ORIG_QUANTITY_PTD,
          BASE_LABOR_HOURS_ITD,BASE_LABOR_HOURS_YTD,BASE_LABOR_HOURS_PP,
          BASE_LABOR_HOURS_PTD,
          ORIG_LABOR_HOURS_ITD,ORIG_LABOR_HOURS_YTD,ORIG_LABOR_HOURS_PP,
          ORIG_LABOR_HOURS_PTD,
          BASE_REVENUE_ITD,BASE_REVENUE_YTD,BASE_REVENUE_PP,BASE_REVENUE_PTD,
          ORIG_REVENUE_ITD,ORIG_REVENUE_YTD,ORIG_REVENUE_PP,ORIG_REVENUE_PTD,
          BASE_UNIT_OF_MEASURE,ORIG_UNIT_OF_MEASURE,
          BASE_RAW_COST_TOT,BASE_BURDENED_COST_TOT,ORIG_RAW_COST_TOT,
          ORIG_BURDENED_COST_TOT,BASE_REVENUE_TOT,ORIG_REVENUE_TOT,
          BASE_LABOR_HOURS_TOT,ORIG_LABOR_HOURS_TOT,BASE_QUANTITY_TOT,
          ORIG_QUANTITY_TOT,
          REQUEST_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,CREATION_DATE,CREATED_BY,
          LAST_UPDATE_LOGIN)
          Select PROJECT_ACCUM_ID,x_budget_type_code,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,NULL,NULL,0,0,0,0,0,0,0,0,0,0,
          pa_proj_accum_main.x_request_id,pa_proj_accum_main.x_last_updated_by,Trunc(Sysdate),Trunc(Sysdate),pa_proj_accum_main.x_created_by,pa_proj_accum_main.x_last_update_login
          from PA_PROJECT_ACCUM_HEADERS PAH
          Where Project_Id = x_project_id and Task_id = v_task_array(i) and
          Resource_list_member_id = x_Resource_list_member_id  and
          Not Exists (Select 'x' from PA_PROJECT_ACCUM_BUDGETS PAB Where
          PAH.PROJECT_ACCUM_ID = PAB.PROJECT_ACCUM_ID
          AND PAB.budget_type_code = x_budget_type_code);
          v_recs_processed := V_recs_processed + 1;
       END LOOP; -- i in 1..v_noof_tasks LOOP
      End If;    --  v_noof_tasks > 0
    End If;      -- (v_recs_processed = 1 and x_Task_id <> 0 )
     x_recs_processed := v_recs_processed;

--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
   When Others Then
         x_err_code := SQLCODE;
         RAISE ;

End Check_Budget_Details;

Procedure Get_Config_Option (X_project_id In Number,
                             x_Accum_category_code In Varchar2,
                             x_Accum_column_code In Varchar2,
                             x_Accum_Flag        Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                             x_err_code In Out NOCOPY Number, --File.Sql.39 bug 4440895
                             x_err_stage In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                             x_err_stack In Out NOCOPY Varchar2 ) Is --File.Sql.39 bug 4440895


-- Get_Config_Option      -  For the given Accumulation Category
--                           checks whether the given column is configured
--                           for Accumulation. The Accum_flag 'Y' or 'N'
--                           determines whether the said column is to be
--                           accumulated or not

v_project_type Varchar2(30);
v_project_type_class_code  Varchar2(30);

-- This Cursor fetches the Project_Type_Class_Code from PA_PROJECT_TYPES
-- based on the given Project's project_type

CURSOR Get_Project_type_class_cur is
Select Pt.project_type_class_code
from
pa_project_types Pt , pa_projects P
where P.project_id = x_project_id
and P.project_type = Pt.project_type ;

-- This Cursor fetches the Accum flag for the given Accum category,column
-- and Project Type class code

CURSOR Get_Accum_Flag_cur is
Select Accum_Flag
from
pa_accum_columns
where Project_Type_Class_code =  v_project_type_class_code
and Accum_Category_Code       =  x_Accum_category_code
and Accum_Column_Code         =  x_Accum_column_code ;

V_old_stack Varchar2(630);
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
Begin
    x_err_code := 0;
    x_Accum_flag := NULL;
    v_old_stack := x_err_stack;
    x_err_stack := x_err_stack || '->PA_ACCUM_UTILS.Get_config_Option ';
    x_err_stage := ' Select Project_Type_class_code ';

    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       pa_debug.debug('Get_Config_Option: ' || x_err_stack);
    END IF;

    Open Get_Project_type_class_cur;
    Fetch Get_Project_type_class_cur into v_project_type_class_code;

 -- If we get NO_DATA_FOUND then raise Exception

    If Get_Project_type_class_cur%NOTFOUND Then
       Close Get_Project_type_class_cur;
       RAISE NO_DATA_FOUND;
    End If;

    Close Get_Project_type_class_cur;
    x_err_stage := ' Select Accum_Flag ';
    Open Get_Accum_Flag_cur;
    Fetch Get_Accum_Flag_cur into x_accum_flag;

 -- If we get NO_DATA_FOUND then return the flag as 'N';
 -- It is possible that some columns may not be found in PA_ACCUM_COLUMNS
 -- if Project Costing is installed

    If Get_Accum_Flag_cur%NOTFOUND Then
       x_accum_flag := 'N';
    End If;
    Close Get_Accum_Flag_cur;
    x_err_code := 0;
    x_err_stack := v_old_stack;

Exception
  When NO_DATA_FOUND Then
       x_err_code := SQLCODE;
       RAISE;

  When Others Then
       x_err_code := SQLCODE;
       RAISE;
End Get_Config_Option;

Procedure   Get_existing_higher_tasks (x_project_id in Number,
                                       X_task_id in Number,
                                       X_resource_list_member_id In Number,
                                       x_task_array  Out NOCOPY task_id_tabtype, --File.Sql.39 bug 4440895
                                       x_noof_tasks Out NOCOPY number, --File.Sql.39 bug 4440895
                                       x_err_stack     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       x_err_stage     In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       x_err_code      In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

-- Get_existing_higher_tasks - For the given task, returns all the higher level
--                             tasks which are available in
--                             PA_PROJECT_ACCUM_HEADERS .

Cursor  Tasks_Cur is
Select task_id
from
pa_tasks pt
where project_id = x_project_id
and task_id <> x_task_id
and exists
(select 'x'
 from
 pa_project_accum_headers pah
 where pah.project_id = x_project_id
 and pah.task_id = pt.task_id
 and pah.resource_list_member_id = x_resource_list_member_id)
 start with task_id = x_task_id
 connect by prior parent_task_id = task_id;

v_noof_tasks         Number := 0;

Task_Rec Tasks_Cur%ROWTYPE;

V_Old_Stack       Varchar2(630);
Begin
      V_Old_Stack := x_err_stack;
      x_err_stack :=
      x_err_stack||'->PA_ACCUM_UTILS.Get_existing_higher_tasks';
      For Task_Rec IN Tasks_Cur LOOP
          v_noof_tasks := v_noof_tasks + 1;
          x_task_array(v_noof_tasks) := Task_Rec.Task_id;
      END LOOP;
      x_noof_tasks := v_noof_tasks;

--      Restore the old x_err_stack;

              x_err_stack := V_Old_Stack;
Exception
   When Others Then
     x_err_code := SQLCODE;
     RAISE ;
end Get_existing_higher_tasks;

-- update_proj_accum_header :
-- This procedure updates the accum period, once the accumulation is successful
Procedure   update_proj_accum_header (x_project_accum_id  IN  Number,
                                      x_accum_period      IN  Varchar2,
                                      x_err_stack         IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_stage         IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      x_err_code          IN OUT NOCOPY Number ) IS --File.Sql.39 bug 4440895

V_old_stack       Varchar2(630);
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

Begin
      V_Old_Stack := x_err_stack;
      x_err_code  := 0;
      x_err_stack :=
      x_err_stack||'->PA_ACCUM_UTILS.update_proj_accum_header';

      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         pa_debug.debug('update_proj_accum_header: ' || x_err_stack);
      END IF;

      -- update the accum_period to current period

      UPDATE pa_project_accum_headers
      SET
         accum_period = x_accum_period,
         request_id = pa_proj_accum_main.x_request_id,
         last_updated_by = pa_proj_accum_main.x_last_updated_by,
         last_update_date = TRUNC(SYSDATE),
         last_update_login = pa_proj_accum_main.x_last_update_login
      WHERE project_accum_id = x_project_accum_id;

      -- Restore the old x_err_stack;

      x_err_stack := v_old_stack;

 EXCEPTION
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE ;
 End update_proj_accum_header;

-- update_proj_accum_header :
-- This procedure updates the tasks_restructured_flag
Procedure   update_tasks_restructured_flag (x_project_accum_id  IN  Number,
                                           x_tasks_restructured_flag IN  Varchar2,
                                           x_err_stack         IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_stage         IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_code          IN OUT NOCOPY Number ) IS --File.Sql.39 bug 4440895

V_old_stack       Varchar2(630);
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
Begin
      V_Old_Stack := x_err_stack;
      x_err_code  := 0;
      x_err_stack :=
      x_err_stack||'->PA_ACCUM_UTILS.update_tasks_restructured_flag';

      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         pa_debug.debug('update_tasks_restructured_flag: ' || x_err_stack);
      END IF;

      -- update the accum_period to current period

      UPDATE pa_project_accum_headers
      SET
         tasks_restructured_flag = x_tasks_restructured_flag,
         request_id = pa_proj_accum_main.x_request_id,
         last_updated_by = pa_proj_accum_main.x_last_updated_by,
         last_update_date = TRUNC(SYSDATE),
         last_update_login = pa_proj_accum_main.x_last_update_login
      WHERE project_accum_id = x_project_accum_id;

      -- Restore the old x_err_stack;

      x_err_stack := v_old_stack;

 EXCEPTION
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE ;
 End update_tasks_restructured_flag;

-- Check proj accum header :
-- This procedure updates the tasks_restructured_flag
Procedure   check_tasks_restructured_flag (x_project_accum_id  IN  Number,
                                           x_tasks_restructured_flag IN OUT  NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_stack         IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_stage         IN OUT NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                           x_err_code          IN OUT NOCOPY Number ) IS --File.Sql.39 bug 4440895

V_old_stack       Varchar2(630);
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
Begin
      V_Old_Stack := x_err_stack;
      x_err_code  := 0;
      x_err_stack :=
      x_err_stack||'->PA_ACCUM_UTILS.check_tasks_restructured_flag';

      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         pa_debug.debug('check_tasks_restructured_flag: ' || x_err_stack);
      END IF;

      -- Select the accum_period to current period
      SELECT
            NVL(tasks_restructured_flag,'N')
      INTO
            x_tasks_restructured_flag
      FROM
            pa_project_accum_headers
      WHERE project_accum_id = x_project_accum_id;

      -- Restore the old x_err_stack;

      x_err_stack := v_old_stack;

 EXCEPTION
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE ;
 End check_tasks_restructured_flag;

--Name:               Get_First_Accum_Period
--Type:               Procedure
--Description:        This procedure fetches attributes
--                    for the first pa_txn_accum period
--                    for a project and resource list.
--
--Called subprograms: none
--
--History:
--    01-FEB-01         jwhite          Bug 1614284: Performance Fix for
--                                      CURSOR selresaccums:
--                                      1) Added the following join
--                                         AND PRAD.PROJECT_ID = PTA.PROJECT_ID
--                                      2) decomposed pa_periods_v; removed pa_lookup
--                                         join.
--    24-JUL-02         rravipat        Bug 2331201: Extended the procedure to use it for
--                                      Financial Planning.Included fnctionality forthe case
--                                      x_amount_type = 'A' which corresponds to a finplan
--                                      having cost and rev togther.
--    13-MAY-03		gjain		Bug 2922974: Split the cursor selresaccums into
--					two cursors selresaccums_g and selresaccums_p
--					Also revamped the entire code logic within this procedure

 PROCEDURE get_first_accum_period
                 (x_project_id                IN         NUMBER,
                  x_resource_list_id          IN         NUMBER   DEFAULT NULL,
                  x_amount_type               IN         VARCHAR2 DEFAULT 'C',
                  x_period_type               IN         VARCHAR2 DEFAULT 'P',
                  x_period_name            IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_period_start_date      IN OUT        NOCOPY DATE, --File.Sql.39 bug 4440895
                  x_err_code               IN OUT        NOCOPY NUMBER, --File.Sql.39 bug 4440895
                  x_err_stage              IN OUT        NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                  x_err_stack              IN OUT        NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

  IS
    /* Commented for bug 2922974
    CURSOR selresaccums IS
    SELECT DISTINCT
    PTA.PA_PERIOD   pa_period
    ,PAP.START_DATE pa_start_date
    ,PAP.END_DATE   pa_end_date
    ,PTA.GL_PERIOD  gl_period
    ,GLP.START_DATE gl_start_date
    ,GLP.END_DATE   gl_end_date
    ,PTA.TOT_RAW_COST tot_raw_cost
    ,PTA.TOT_QUANTITY tot_quantity
    ,PTA.TOT_REVENUE  tot_revenue
    FROM PA_TXN_ACCUM PTA
    , PA_RESOURCE_ACCUM_DETAILS PRAD
    , PA_PERIODS PAP
    , GL_PERIOD_STATUSES GLP
    , PA_IMPLEMENTATIONS PAIMP
    WHERE PRAD.PROJECT_ID = x_project_id
    AND PRAD.RESOURCE_LIST_ID = x_resource_list_id
    AND PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
    AND PRAD.PROJECT_ID = PTA.PROJECT_ID
    AND PTA.PA_PERIOD = PAP.PERIOD_NAME
    AND PAP.GL_PERIOD_NAME = GLP.PERIOD_NAME
    AND GLP.SET_OF_BOOKS_ID = PAIMP.SET_OF_BOOKS_ID
    AND GLP.APPLICATION_ID = pa_period_process_pkg.application_id
    AND GLP.ADJUSTMENT_PERIOD_FLAG = 'N'
    ORDER BY DECODE(x_period_type,'P',PAP.START_DATE,'G',GLP.START_DATE,PAP.START_DATE);
    */

    /* Addition for bug 2922974 starts */
    CURSOR selresaccums_g IS
    SELECT DISTINCT
     PTA.GL_PERIOD  gl_period
    ,GLP.START_DATE gl_start_date
    ,GLP.END_DATE   gl_end_date
    ,PTA.TOT_RAW_COST tot_raw_cost
    ,PTA.TOT_QUANTITY tot_quantity
    ,PTA.TOT_REVENUE  tot_revenue
    FROM PA_TXN_ACCUM PTA
    , PA_RESOURCE_ACCUM_DETAILS PRAD
    , GL_PERIOD_STATUSES GLP
    , PA_IMPLEMENTATIONS PAIMP
    WHERE PRAD.PROJECT_ID = x_project_id
    AND PRAD.RESOURCE_LIST_ID = x_resource_list_id
    AND PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
    AND PRAD.PROJECT_ID = PTA.PROJECT_ID
    AND PTA.GL_PERIOD = GLP.PERIOD_NAME
    AND GLP.SET_OF_BOOKS_ID = PAIMP.SET_OF_BOOKS_ID
    AND GLP.APPLICATION_ID = pa_period_process_pkg.application_id
    AND GLP.ADJUSTMENT_PERIOD_FLAG = 'N'
    ORDER BY GLP.START_DATE;

    CURSOR selresaccums_p IS
    SELECT DISTINCT
     PTA.PA_PERIOD    pa_period
    ,PAP.START_DATE   pa_start_date
    ,PAP.END_DATE     pa_end_date
    ,PTA.TOT_RAW_COST tot_raw_cost
    ,PTA.TOT_QUANTITY tot_quantity
    ,PTA.TOT_REVENUE  tot_revenue
    FROM PA_TXN_ACCUM PTA
    , PA_RESOURCE_ACCUM_DETAILS PRAD
    , PA_PERIODS PAP
    , GL_PERIOD_STATUSES GLP
    , PA_IMPLEMENTATIONS PAIMP
    WHERE PRAD.PROJECT_ID = x_project_id
    AND PRAD.RESOURCE_LIST_ID = x_resource_list_id
    AND PRAD.TXN_ACCUM_ID = PTA.TXN_ACCUM_ID
    AND PRAD.PROJECT_ID = PTA.PROJECT_ID
    AND PTA.PA_PERIOD = PAP.PERIOD_NAME
    AND PAP.GL_PERIOD_NAME = GLP.PERIOD_NAME
    AND GLP.SET_OF_BOOKS_ID = PAIMP.SET_OF_BOOKS_ID
    AND GLP.APPLICATION_ID = pa_period_process_pkg.application_id
    AND GLP.ADJUSTMENT_PERIOD_FLAG = 'N'
    ORDER BY PAP.START_DATE;

    gresaccumrec       selresaccums_g%ROWTYPE;
    presaccumrec       selresaccums_p%ROWTYPE;
 /* Addition for bug 2922974 ends */

/* resaccumrec       selresaccums%ROWTYPE; commented for bug 2922974 */

  BEGIN
     x_err_code               := 0;
     x_err_stage              := 'Getting the Project First Accumlation Period';

     x_period_name := NULL;
     x_period_start_date := NULL;

/*  commented for bug 2922974
     FOR resaccumrec IN selresaccums LOOP

       IF (x_amount_type = 'C') THEN
         IF (resaccumrec.tot_raw_cost <> 0 OR resaccumrec.tot_quantity <> 0) THEN
            IF (x_period_type = 'P') THEN
               x_period_name := resaccumrec.pa_period;
               x_period_start_date := resaccumrec.pa_start_date;
            ELSIF (x_period_type = 'G') THEN
               x_period_name := resaccumrec.gl_period;
               x_period_start_date := resaccumrec.gl_start_date;
            END IF;
            EXIT; -- Exit the loop immediately, since the cursor has a sort order
         END IF;
       ELSIF (x_amount_type = 'R') THEN
         IF (resaccumrec.tot_revenue <> 0 ) THEN
            IF (x_period_type = 'P') THEN
               x_period_name := resaccumrec.pa_period;
               x_period_start_date := resaccumrec.pa_start_date;
            ELSIF (x_period_type = 'G') THEN
               x_period_name := resaccumrec.gl_period;
               x_period_start_date := resaccumrec.gl_start_date;
            END IF;
            EXIT; -- Exit the loop immediately, since the cursor has a sort order
         END IF;
     --Start of changes Bug: 2331201 For Financial Planning
          --This enahancement is being done to include the case where financial plan
          --is cost and revenue together in financial planning
       ELSIF (x_amount_type = 'A') THEN

         IF (resaccumrec.tot_raw_cost <> 0 OR resaccumrec.tot_quantity <> 0
              OR resaccumrec.tot_revenue <> 0) THEN
            IF (x_period_type = 'P') THEN
               x_period_name := resaccumrec.pa_period;
               x_period_start_date := resaccumrec.pa_start_date;
            ELSIF (x_period_type = 'G') THEN
               x_period_name := resaccumrec.gl_period;
               x_period_start_date := resaccumrec.gl_start_date;
            END IF;
            EXIT; -- Exit the loop immediately, since the cursor has a sort order
        END IF;
    --End of changes Bug: 2331201 For Financial Planning
       END IF; -- IF (x_amount_type = 'C') THEN
     END LOOP; -- FOR resaccumrec IN selresaccums LOOP
*/

 /* addition for bug 2922974 starts */
     If x_period_type = 'P' then
	FOR presaccumrec IN selresaccums_p
	LOOP
            IF (x_amount_type = 'C') THEN
		IF (presaccumrec.tot_raw_cost <> 0 OR presaccumrec.tot_quantity <> 0) THEN
		       x_period_name := presaccumrec.pa_period;
		       x_period_start_date := presaccumrec.pa_start_date;
		       EXIT; -- Exit the loop immediately, since the cursor has a sort order
		END IF;
	    ELSIF (x_amount_type = 'R') THEN
                  IF (presaccumrec.tot_revenue <> 0 ) THEN
		       x_period_name := presaccumrec.pa_period;
		       x_period_start_date := presaccumrec.pa_start_date;
		       EXIT; -- Exit the loop immediately, since the cursor has a sort order
		  END IF;
	    ELSIF (x_amount_type = 'A') THEN
	         IF (presaccumrec.tot_raw_cost <> 0 OR presaccumrec.tot_quantity <> 0
		     OR presaccumrec.tot_revenue <> 0) THEN
		       x_period_name := presaccumrec.pa_period;
		       x_period_start_date := presaccumrec.pa_start_date;
		       EXIT; -- Exit the loop immediately, since the cursor has a sort order
		  END IF;
	    END IF;
	END LOOP;
     elsif x_period_type = 'G' then
	FOR gresaccumrec IN selresaccums_g
	LOOP
            IF (x_amount_type = 'C') THEN
		IF (gresaccumrec.tot_raw_cost <> 0 OR gresaccumrec.tot_quantity <> 0) THEN
		       x_period_name := gresaccumrec.gl_period;
		       x_period_start_date := gresaccumrec.gl_start_date;
		       EXIT; -- Exit the loop immediately, since the cursor has a sort order
		END IF;
	    ELSIF (x_amount_type = 'R') THEN
                  IF (gresaccumrec.tot_revenue <> 0 ) THEN
		       x_period_name := gresaccumrec.gl_period;
		       x_period_start_date := gresaccumrec.gl_start_date;
		       EXIT; -- Exit the loop immediately, since the cursor has a sort order
		  END IF;
	    ELSIF (x_amount_type = 'A') THEN
	          IF (gresaccumrec.tot_raw_cost <> 0 OR gresaccumrec.tot_quantity <> 0
		     OR gresaccumrec.tot_revenue <> 0) THEN
		       x_period_name := gresaccumrec.gl_period;
		       x_period_start_date := gresaccumrec.gl_start_date;
		       EXIT; -- Exit the loop immediately, since the cursor has a sort order
		  END IF;
	    END IF;
	END LOOP;
     end if;
 /* addition for bug 2922974 ends */

     EXCEPTION
       WHEN OTHERS THEN
         x_err_code := SQLCODE;
         RAISE;
  END get_first_accum_period;

PROCEDURE   set_check_reporting_end_date
                ( x_period_name                 IN      VARCHAR2)
IS
lcl_end_date            date;
BEGIN
-- Return the end date of the passed period and set the global variable
                select decode( pai.accumulation_period_type, 'PA', pav.pa_end_date,
                        'GL', pav.gl_end_date )
                  into lcl_end_date
                  from PA_PERIODS_V pav, pa_implementations pai
                 where period_name = x_period_name;

        pa_accum_utils.g_check_reporting_end_date := lcl_end_date;

END set_check_reporting_end_date;

FUNCTION   get_check_reporting_end_date
                return date
IS
lcl_end_date            date;
BEGIN

-- Check the global variable for a reporting period. If none is set,
-- return the current reporting period
        IF pa_accum_utils.g_check_reporting_end_date is null
        THEN
/* Bug 2634995 begins */
--Replaced the pa_periods_v with the view definition
--              select decode( pai.accumulation_period_type, 'PA', pav.pa_end_date,
--                      'GL', pav.gl_end_date )
--                into lcl_end_date
--                from PA_PERIODS_V pav, pa_implementations pai
--               where current_pa_period_flag = 'Y';
                 select decode(paimp.accumulation_period_type, 'PA', pap.end_date,
                               'GL', glp.end_date)
                  into lcl_end_date
                  FROM PA_PERIODS PAP, GL_PERIOD_STATUSES GLP,
                       PA_IMPLEMENTATIONS PAIMP, PA_LOOKUPS PAL
                  WHERE PAP.GL_PERIOD_NAME = GLP.PERIOD_NAME
                    AND GLP.SET_OF_BOOKS_ID = PAIMP.SET_OF_BOOKS_ID
                    AND GLP.APPLICATION_ID = Pa_Period_Process_Pkg.Application_id
                    AND GLP.ADJUSTMENT_PERIOD_FLAG = 'N'
                    AND PAL.LOOKUP_TYPE = 'CLOSING STATUS'
                    AND PAL.LOOKUP_CODE =  PAP.STATUS
                    AND PAP.current_pa_period_flag = 'Y' ;
/* Bug 2634995 ends */

                 return lcl_end_date;
        ELSE
                return pa_accum_utils.g_check_reporting_end_date;
        END IF;

        return pa_accum_utils.g_check_reporting_end_date;
END get_check_reporting_end_date;


Procedure Set_current_period_Info IS
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
Begin
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   pa_debug.debug('pa_accum_utils.set_current_period_info');
   END IF;

   SELECT
    period_name,
    gl_period_name
   INTO
    g_current_pa_period,
    g_current_gl_period
   FROM pa_periods
   WHERE
    current_pa_period_flag = 'Y';

Exception
    WHEN NO_DATA_FOUND THEN
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         pa_debug.debug('Data not found to set g_current_pa_period and g_current
	 _gl_period',PA_DEBUG.DEBUG_LEVEL_EXCEPTION);
	 END IF;
         RAISE;
    WHEN OTHERS THEN
         RAISE;
End Set_current_period_info;

FUNCTION   Get_current_pa_period
                return varchar2
IS
l_current_pa_period  varchar2(20);
BEGIN


-- Return the value in global variable g_current_pa_period,if it is set.
-- If g_current_pa_period is not set,fetch the current pa period from
-- the database

        IF pa_accum_utils.g_current_pa_period is null
        THEN
          SELECT
           period_name
          INTO
           l_current_pa_period
          FROM pa_periods
          WHERE
           current_pa_period_flag = 'Y';
        ELSE
           l_current_pa_period := pa_accum_utils.g_current_pa_period;
        END IF;

        return l_current_pa_period;

Exception
    WHEN OTHERS THEN
         RAISE;

END  Get_current_pa_period;

FUNCTION   Get_current_gl_period
                return varchar2
IS
l_current_gl_period  varchar2(15);
BEGIN

-- Return the value in global variable g_current_gl_period,if it is set.
-- If g_current_gl_period is not set,fetch the current gl period from
-- the database

        IF pa_accum_utils.g_current_gl_period is null
        THEN
          SELECT
           gl_period_name
          INTO
           l_current_gl_period
          FROM pa_periods
          WHERE
           current_pa_period_flag = 'Y';
        ELSE
           l_current_gl_period := pa_accum_utils.g_current_gl_period;
        END IF;

        return l_current_gl_period;

Exception
    WHEN OTHERS THEN
         RAISE;

END Get_current_gl_period;

-- Function Get_spread_amount_val
-- Budget amount will have to be spread across the various time periods,
-- i.e., current period (for PTD), previous period for (PP) and
-- current year (for YTD)
-- This function returns the spread_amount value (tmp_amt_returned) of
-- the amount passed to it (x_amt_to_be_spread) as a parameter.
-- i.e., x_amt_to_be_spread can be either raw_cost or burdened_cost or
-- revenue or quantity or labor_quantity.
-- x_which_date_flag parameter can either be 'C' or 'P' or 'Y' or 'I'.
-- These stand for Current period, Prior period, current Year,
-- Inception to date.

FUNCTION Get_spread_amount_val
                (x_from_date            IN DATE,
                 x_to_date              IN DATE,
                 x_amt_to_be_spread     IN NUMBER,
                 x_which_date_flag      IN VARCHAR2)

         RETURN NUMBER
IS
tmp_amt_returned NUMBER := 0;

BEGIN

  IF x_which_date_flag = 'C' THEN

--   PTD
--   Budget End Date >= Period Start date and Budget Start Date
--   <= Period End Date

     IF x_to_date   >= PA_PROJ_ACCUM_MAIN.x_current_start_date AND
        x_from_date <= PA_PROJ_ACCUM_MAIN.x_current_end_date   THEN

      tmp_amt_returned := PA_MISC.spread_amount('L', x_from_date, x_to_date,
         PA_PROJ_ACCUM_MAIN.x_current_start_date,
         PA_PROJ_ACCUM_MAIN.x_current_end_date, x_amt_to_be_spread);

     END IF;

  ELSIF x_which_date_flag = 'P' THEN

--   PP
--   Budget End Date >= Period Start date and Budget Start Date
--   <= Period End Date

     IF x_to_date   >= PA_PROJ_ACCUM_MAIN.x_prev_start_date AND
        x_from_date <= PA_PROJ_ACCUM_MAIN.x_prev_end_date   THEN

      tmp_amt_returned := PA_MISC.spread_amount('L', x_from_date, x_to_date,
        PA_PROJ_ACCUM_MAIN.x_prev_start_date,
        PA_PROJ_ACCUM_MAIN.x_prev_end_date, x_amt_to_be_spread);

     END IF;

  ELSIF x_which_date_flag = 'Y' THEN

--  YTD
--  NOT (Budget End Date < Year Start Date OR Budget Start Date > Year End Date)

    IF NOT (x_to_date < PA_PROJ_ACCUM_MAIN.x_period_yr_start_date  OR
        x_from_date > PA_PROJ_ACCUM_MAIN.x_period_yr_end_date) THEN

      tmp_amt_returned := PA_MISC.spread_amount('L', x_from_date, x_to_date,
        PA_PROJ_ACCUM_MAIN.x_period_yr_start_date,
        PA_PROJ_ACCUM_MAIN.x_period_yr_end_date, x_amt_to_be_spread);

    END IF;

  ELSIF x_which_date_flag = 'I' THEN

--  ITD
--  NOT (Budget Start Date > Period End Date AND Budget End Date >
--  Period Start Date)

    IF NOT (x_from_date > PA_PROJ_ACCUM_MAIN.x_current_end_date) THEN

      tmp_amt_returned := PA_MISC.spread_amount('L', x_from_date, x_to_date,
        x_from_date, PA_PROJ_ACCUM_MAIN.x_current_end_date, x_amt_to_be_spread);

    END IF;

  END IF;

  RETURN tmp_amt_returned ;

Exception
    WHEN OTHERS THEN
         RAISE;

END Get_spread_amount_val;

-- /*--------------------------------------------------------*/
-- Three new functions added as a part of Project Allocation
-- Summarization Enhancement changes
-- /*--------------------------------------------------------*/

Function Get_Grouping_Id
Return Number
Is
        Group_id Number := NULL;

Begin
        If pa_accum_utils.G_grouping_id Is Not Null Then
           Group_id := pa_accum_utils.G_grouping_id;
        End If;

        Return Group_id;

Exception
        When No_Data_Found Then
          Return Group_id;
        When Others Then
          Raise;

End Get_Grouping_Id;


Function Get_Context_Info
Return Varchar2
Is
        Summ_context Varchar2(25) := NULL;

Begin
        If pa_accum_utils.G_context Is Not Null Then
           Summ_context := pa_accum_utils.G_context;
        End If;

        Return Summ_context;

Exception
        When No_Data_Found Then
          Return Summ_context;
        When Others Then
          Raise;

End Get_Context_Info;


Function Get_Project_Info
        (x_From_Or_To IN VARCHAR2)
Return Varchar2
Is
        Proj_num Varchar2(25) := NULL;
Begin

        If x_From_Or_To = 'F' Then      -- From which project
           If pa_accum_utils.G_start_proj Is Not Null Then
              Proj_num := pa_accum_utils.G_start_proj;
           End If;
        Else                    -- Till which project
           If pa_accum_utils.G_end_proj Is Not Null Then
              Proj_num := pa_accum_utils.G_end_proj;
           End If;
        End If;

        Return Proj_num;

Exception
        When No_Data_Found Then
          Return Proj_num;
        When Others Then
          Raise;

End Get_Project_Info;

-- /*--------------------------------------------------------*/
-- End of Project Allocation Summarization Enhancement changes
-- /*--------------------------------------------------------*/

-- /*--------------------------------------------------------*/
--  Start of code added for performance issue 3653978
-- /*--------------------------------------------------------*/

Procedure Get_pa_period_Info1 (x_impl_opt  In Varchar2,
                              x_current_pa_start_date In Date,
                              x_current_gl_start_date In Date,
                              x_prev_pa_period    Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_prev_gl_period    Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_prev_pa_year      Out NOCOPY Number, --File.Sql.39 bug 4440895
                              x_prev_gl_year      Out NOCOPY Number, --File.Sql.39 bug 4440895
                              x_prev_pa_start_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                              x_prev_pa_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                              x_prev_gl_start_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                              x_prev_gl_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                              x_err_stack          In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage          In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code           In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

V_Old_Stack       Varchar2(630);
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN
   V_Old_Stack := x_err_stack;
   x_err_stack :=
   x_err_stack||'->PA_ACCUM_UTILS.Get_pa_period_Info1';

   -- Select the details pertaining to the previous pa period.

   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.debug('Get_pa_period_Info1: ' || x_err_stack);
   END IF;

   <<prev_pa_period>>
   BEGIN
     SELECT
        PERIOD_NAME,
        PERIOD_YEAR,
        PA_START_DATE,
        PA_END_DATE
     INTO
        x_prev_pa_period,
        x_prev_pa_year,
        x_prev_pa_start_date,
        x_prev_pa_end_date
     FROM
        PA_PERIODS_V
     WHERE pa_start_date =
        (SELECT max(start_date)
         FROM
         pa_periods
         WHERE start_date < x_current_pa_start_date);

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         -- The current pa_period is the first period defined
         x_prev_pa_period := NULL;
         x_prev_pa_year := NULL;
         x_prev_pa_start_date := NULL;
         x_prev_pa_end_date := NULL;

       WHEN OTHERS THEN
         x_err_code := SQLCODE;
         RAISE;
    END prev_pa_period;

    -- Select the details pertaining to the previous gl period.

    <<prev_gl_period>>
    BEGIN

      SELECT
         DISTINCT gl_period_name,
         period_year,
         gl_start_date,
         gl_end_date
      INTO
         x_prev_gl_period,
         x_prev_gl_year,
         x_prev_gl_start_date,
         x_prev_gl_end_date
      FROM
         pa_periods_v
      WHERE
         gl_start_date =
           (SELECT max(gl_start_date)
            FROM pa_periods_v
            WHERE
            gl_start_date < x_current_gl_start_date);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           -- current gl_period is the first period defined
           x_prev_gl_period := NULL;
           x_prev_gl_year := NULL;
           x_prev_gl_start_date := NULL;
           x_prev_gl_end_date := NULL;
        WHEN OTHERS THEN
           x_err_code := SQLCODE;
           RAISE;
    END prev_gl_period;

    -- Restore the old x_err_stack;
    x_err_stack := V_Old_Stack;
Exception
    When Others Then
         x_err_code := SQLCODE;
         RAISE ;
End Get_pa_period_Info1;


Procedure Get_pa_period_Info2 (x_impl_opt  In Varchar2,
                              x_prev_accum_period in Varchar2,
                              x_prev_accum_year   Out NOCOPY number, --File.Sql.39 bug 4440895
                              x_prev_accum_start_date In Out NOCOPY Date, --File.Sql.39 bug 4440895
                              x_prev_accum_end_date Out NOCOPY Date, --File.Sql.39 bug 4440895
                              x_prev_prev_accum_period Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_accum_period_type_changed IN OUT NOCOPY BOOLEAN, --File.Sql.39 bug 4440895
                              x_err_stack          In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_stage          In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                              x_err_code           In Out NOCOPY Number ) IS --File.Sql.39 bug 4440895

V_Old_Stack       Varchar2(630);
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN
   V_Old_Stack := x_err_stack;
   x_err_stack :=
   x_err_stack||'->PA_ACCUM_UTILS.Get_pa_period_Info2';
   x_accum_period_type_changed := FALSE;

   IF P_DEBUG_MODE = 'Y' THEN
      pa_debug.debug('Get_pa_period_Info2: ' || x_err_stack);
   END IF;

         BEGIN

            If x_impl_opt = 'PA' Then
               Select PERIOD_YEAR,PA_START_DATE,PA_END_DATE
               into x_prev_accum_year,x_prev_accum_start_date,
                    x_prev_accum_end_date from
               PA_PERIODS_V WHERE Period_name = x_prev_accum_period;
            Elsif
               x_impl_opt = 'GL' Then
               Select Distinct PERIOD_YEAR,GL_START_DATE,GL_END_DATE
               into x_prev_accum_year,x_prev_accum_start_date,
                    x_prev_accum_end_date  from
               PA_PERIODS_V WHERE Gl_Period_name = x_prev_accum_period;
            End If;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
              -- Accumulation period type must have changed
              -- Bug #572031
              x_accum_period_type_changed := TRUE;
         END;

         IF (x_accum_period_type_changed = FALSE) THEN

            -- Now get x_prev_prev_accum_period
            <<prev_prev_accum_period>>
            BEGIN
            If x_impl_opt = 'PA' Then
              SELECT DISTINCT  PERIOD_NAME
              INTO x_prev_prev_accum_period
              FROM
                pa_periods_v
              WHERE
                pa_start_date =
                     (SELECT max(pa_start_date)
                      FROM pa_periods_v
                      WHERE pa_start_date < x_prev_accum_start_date);
            Elsif
               x_impl_opt = 'GL' Then
              SELECT DISTINCT GL_PERIOD_NAME
              INTO x_prev_prev_accum_period
              FROM
                pa_periods_v
              WHERE gl_start_date =
                     (SELECT max(gl_start_date)
                      FROM pa_periods_v
                      WHERE gl_start_date < x_prev_accum_start_date);
            End If;

             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    x_prev_prev_accum_period := NULL;
               WHEN OTHERS THEN
                    x_err_code := SQLCODE;
                    RAISE;
             END prev_prev_accum_period;
        END IF;  -- (x_accum_period_type_changed = FALSE)

    -- Restore the old x_err_stack;
    x_err_stack := V_Old_Stack;
Exception
    When Others Then
         x_err_code := SQLCODE;
         RAISE ;
End Get_pa_period_Info2;


-- /*--------------------------------------------------------*/
--  End of code added for performance issue 3653978
-- /*--------------------------------------------------------*/

END pa_accum_utils;

/
