--------------------------------------------------------
--  DDL for Package Body PA_ACCUM_PROJ_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ACCUM_PROJ_LIST" AS
--$Header: PAPRJACB.pls 120.2.12010000.2 2008/09/24 11:06:36 admarath ship $

--
-- Name:		Insert_Accum
-- Type:		PL/SQL Procedure
--
-- Description:	        For a given project, this procedure inserts one project-level row
--                      for each of the following summarization tables:
--                      1) pa_project_accum_headers
--                      2) pa_project_accum_actuals
--                      3) pa_project_accum_commitments
--
--                      For the pa_project_accum_budgets, one row each is inserted for
--                      budget_type_codes AC and AR (Approved Cost and Approved Revenue,
--                      respectively).
--
--                      Rows are only inserted if they do not already exist.
--                      Zeros are populated for all amount columns.
--
--                      This API does not peform any validation. Error messaging
--                      is limited to the first ORA error encountered. If ORA errors
--                      are not encountered, then x_return_status returns S(uccess).
--
-- Note:
--                      This API assumes that the appropriate
--                      dbms_application_info.set_client_info(org_id) and
--                      responsibility and userid FND_GLOBALS environment has
--                      set up prior to running this API.
--

--
-- Called Subprograms:  None.
--
-- History:
--    31-OCT-2001	jwhite      Created.
--
g_org_id NUMBER ;

PROCEDURE Insert_Accum
(p_project_id			IN	NUMBER
, x_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, x_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS


l_api_name		CONSTANT VARCHAR2(30)	:= 'Insert_Accum';
l_project_id                     NUMBER         := 0;
l_project_accum_id               pa_project_accum_headers.project_accum_id%TYPE := 0;
l_accum_period_type              pa_implementations_all.accumulation_period_type%TYPE := NULL;
l_period_name                    pa_periods_all.period_name%TYPE := NULL;

l_err_code			NUMBER			:= 0;
l_err_stage			VARCHAR2(2000)		:= NULL;
l_err_stack			VARCHAR2(2000)		:= NULL;


CURSOR  header_csr
IS
SELECT  project_accum_id
FROM    pa_project_accum_headers
WHERE   project_id = l_project_id
AND     task_id = 0
AND     resource_list_member_id = 0;

CURSOR  periodtype_csr
IS
SELECT  accumulation_period_type
FROM    pa_implementations_all
where   org_id = g_org_id; /*removed nvl() from nvl(org_id,-99) for bug 6327647*/

CURSOR  currperiod_csr
IS
SELECT  decode(l_accum_period_type, 'GL', GL_PERIOD_NAME, PERIOD_NAME)
FROM    pa_periods_all
WHERE   current_pa_period_flag = 'Y'
and     org_id = g_org_id; /*removed nvl() from nvl(org_id,-99) for bug 6327647*/



BEGIN

        SAVEPOINT Insert_Accum_Pvt;

     select NVL(org_id,-99) into g_org_id
     from pa_projects_all
     where project_id = p_project_id;   /*4704130 */

	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

        l_project_id := p_project_id;


        -- Create Header Project-Level Header Record, if NOT Already Exists --------------
        -- Most of the time, this API will be called from Copy_Project. So, the
        -- project-level header record will not already exist.

        -- First, Get Necessary Input Parameters for Record Creation.
        -- These queries should always return result sets, providing this API is run
        -- under the appropriate dbms_application_info.set_client_info(org_id) environment.

        OPEN periodtype_csr;
        FETCH periodtype_csr INTO l_accum_period_type;
        CLOSE periodtype_csr;

        OPEN currperiod_csr;
        FETCH currperiod_csr INTO l_period_name;
        CLOSE currperiod_csr;

        SELECT PA_PROJECT_ACCUM_HEADERS_S.Nextval
        INTO  l_project_accum_id
        FROM  dual;

         -- Insert Header Record

        Insert into PA_PROJECT_ACCUM_HEADERS
        (PROJECT_ACCUM_ID,PROJECT_ID,TASK_ID,ACCUM_PERIOD,RESOURCE_ID,
         RESOURCE_LIST_ID,RESOURCE_LIST_ASSIGNMENT_ID,
         RESOURCE_LIST_MEMBER_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,
         CREATION_DATE,REQUEST_ID,CREATED_BY,LAST_UPDATE_LOGIN )
         SELECT l_project_accum_id,l_project_id,0,
                 l_period_name,
                 0,0,0,0,G_last_updated_by,Trunc(sysdate),trunc(sysdate),
                 G_request_id,G_created_by,
                 G_last_update_login
         FROM dual
         WHERE NOT EXISTS (select 'X'
                          from    pa_project_accum_headers
                          where   project_id = l_project_id
                          AND     task_id = 0
                          AND     resource_list_member_id = 0
                          );

        IF (SQL%ROWCOUNT < 1)
            THEN
            -- A Header Row Was NOT Created Becuase the Header Already Exists.
            -- So, find the project_accum_id of the existing record and process the detail records.
            OPEN header_csr;
            FETCH header_csr INTO l_project_accum_id;
            CLOSE header_csr;
        END IF;



        -- As Necessary, Create Detail Records -------------------------

        -- Actuals Record, If NOT Already Exist

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
       LAST_UPDATE_LOGIN) SELECT
       l_project_accum_id,0,0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,
        0,0,0,
        0,0,0,0,
        0,NULL,G_request_id,G_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),G_created_by,G_last_update_login
        FROM dual
        WHERE NOT EXISTS (select 'X'
                          from pa_project_accum_actuals
                          where project_accum_id = l_project_accum_id
                          );


       -- Commitments Record, If NOT Already Exist

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
            SELECT l_project_accum_id,
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
                    NULL,G_request_id,G_last_updated_by,Trunc(sysdate),
                    Trunc(Sysdate),G_created_by,
                    G_last_update_login
             FROM  dual
             WHERE NOT EXISTS (select 'X'
                          from pa_project_accum_commitments
                          where project_accum_id = l_project_accum_id
                          );

       -- Approved Cost Budget Record, If NOT Already Exist

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
       SELECT l_project_accum_id,'AC',
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        NULL,NULL,
        0,0,0,0,0,0,0,0,0,0,
        G_request_id,G_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),G_created_by,G_last_update_login
        FROM dual
        WHERE NOT EXISTS (select 'X'
                          from pa_project_accum_budgets
                          where project_accum_id = l_project_accum_id
                          and budget_type_code = 'AC'
                          );


      -- Approved Revenue Budget Record, If NOT Already Exist

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
       SELECT l_project_accum_id,'AR',
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        NULL,NULL,
        0,0,0,0,0,0,0,0,0,0,
        G_request_id,G_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),G_created_by,G_last_update_login
        FROM dual
        WHERE NOT EXISTS (select 'X'
                          from pa_project_accum_budgets
                          where project_accum_id = l_project_accum_id
                          and budget_type_code = 'AR'
                          );





 EXCEPTION


        WHEN dup_val_on_index THEN
             null; -- OK if dup record exists.

        WHEN OTHERS THEN
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             ROLLBACK TO Insert_Accum_Pvt;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => G_PKG_NAME,
                    p_procedure_name   => l_api_name);



END Insert_Accum;


--
-- Name:		Upgrade_Accum
-- Type:		PL/SQL Procedure
--
-- Description:	        For a given project, this procedure inserts one project-level row
--                      for each of the following summarization tables:
--                      1) pa_project_accum_headers
--                      2) pa_project_accum_actuals
--                      3) pa_project_accum_commitments
--
--                      For the pa_project_accum_budgets, one row each is inserted for
--                      budget_type_codes AC and AR (Approved Cost and Approved Revenue,
--                      respectively).
--
--                      Rows are only inserted if they do not already exist.
--                      Zeros are populated for all amount columns.
--
--                      This API does not peform any validation. Error messaging
--                      is limited to the first ORA error encountered. If ORA errors
--                      are not encountered, then x_return_status returns S(uccess).
--
-- Note:
--                      This API assumes that the appropriate
--                      dbms_application_info.set_client_info(org_id) and
--                      responsibility and userid FND_GLOBALS environment has
--                      set up prior to running this API.
--

--
-- Called Subprograms:  None.
--
-- History:
--    31-OCT-2001	jwhite      Created.
--

PROCEDURE Upgrade_Accum
(p_project_id			IN	NUMBER
, x_return_status		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_msg_count			OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, x_msg_data			OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS


l_api_name		CONSTANT VARCHAR2(30)	:= 'Upgrade_Accum';
l_project_id                     NUMBER         := 0;
l_project_accum_id               pa_project_accum_headers.project_accum_id%TYPE := 0;
l_accum_period_type              pa_implementations_all.accumulation_period_type%TYPE := NULL;
l_period_name                    pa_periods_all.period_name%TYPE := NULL;

l_err_code			NUMBER			:= 0;
l_err_stage			VARCHAR2(2000)		:= NULL;
l_err_stack			VARCHAR2(2000)		:= NULL;


CURSOR  header_csr
IS
SELECT  project_accum_id
FROM    pa_project_accum_headers
WHERE   project_id = l_project_id
AND     task_id = 0
AND     resource_list_member_id = 0;

CURSOR  periodtype_csr
IS
SELECT  accumulation_period_type
FROM    pa_implementations_all
where   org_id = g_org_id; /*removed nvl() from nvl(org_id,-99) for bug 6327647*/



CURSOR  currperiod_csr
IS
SELECT  decode(l_accum_period_type, 'GL', GL_PERIOD_NAME, PERIOD_NAME)
FROM    pa_periods_all
WHERE   current_pa_period_flag = 'Y'
and     org_id = g_org_id; /*removed nvl() from nvl(org_id,-99) for bug 6327647*/



BEGIN

     select NVL(org_id,-99) into g_org_id
     from pa_projects_all
     where project_id = p_project_id;

        SAVEPOINT Upgrade_Accum_Pvt;

	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

        l_project_id := p_project_id;


-- Does the Project-Level Row Already Exist for the Input Project?
        -- If NOT, then create it. Otherwise, proceed with creation of
        -- detail records.

        OPEN header_csr;
        FETCH header_csr INTO l_project_accum_id;
        IF (header_csr%NOTFOUND)
           THEN

           -- Create Header Project-Level Header Record ------------------

           -- First, Get Necessary Input Parameters for Record Creation.
           -- These queries should always return result sets, providing this API is run
           -- under the appropriate dbms_application_info.set_client_info(org_id) environment.

           OPEN periodtype_csr;
           FETCH periodtype_csr INTO l_accum_period_type;
           CLOSE periodtype_csr;

           OPEN currperiod_csr;
           FETCH currperiod_csr INTO l_period_name;
           CLOSE currperiod_csr;

           SELECT PA_PROJECT_ACCUM_HEADERS_S.Nextval
           INTO  l_project_accum_id
           FROM  dual;
         -- Insert Header Record

      Insert into PA_PROJECT_ACCUM_HEADERS
        (PROJECT_ACCUM_ID,PROJECT_ID,TASK_ID,ACCUM_PERIOD,RESOURCE_ID,
         RESOURCE_LIST_ID,RESOURCE_LIST_ASSIGNMENT_ID,
         RESOURCE_LIST_MEMBER_ID,LAST_UPDATED_BY,LAST_UPDATE_DATE,
         CREATION_DATE,REQUEST_ID,CREATED_BY,LAST_UPDATE_LOGIN )
         Values (l_project_accum_id,l_project_id,0,
                 l_period_name,
                 0,0,0,0,G_last_updated_by,Trunc(sysdate),trunc(sysdate),
                 G_request_id,G_created_by,
                 G_last_update_login);


        END IF;  -- (header_csr%NOTFOUND)

        CLOSE header_csr;


        -- As Necessary, Create Detail Records -------------------------

        -- Actuals Record, If NOT Already Exist

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
       LAST_UPDATE_LOGIN) SELECT
       l_project_accum_id,0,0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,
        0,0,0,
        0,0,0,0,
        0,NULL,G_request_id,G_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),G_created_by,G_last_update_login
        FROM dual
        WHERE NOT EXISTS (select 'X'
                          from pa_project_accum_actuals
                          where project_accum_id = l_project_accum_id
                          );


       -- Commitments Record, If NOT Already Exist

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
            SELECT l_project_accum_id,
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
                    NULL,G_request_id,G_last_updated_by,Trunc(sysdate),
                    Trunc(Sysdate),G_created_by,
                    G_last_update_login
             FROM  dual
             WHERE NOT EXISTS (select 'X'
                          from pa_project_accum_commitments
                          where project_accum_id = l_project_accum_id
                          );

       -- Approved Cost Budget Record, If NOT Already Exist

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
       SELECT l_project_accum_id,'AC',
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        NULL,NULL,
        0,0,0,0,0,0,0,0,0,0,
        G_request_id,G_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),G_created_by,G_last_update_login
        FROM dual
        WHERE NOT EXISTS (select 'X'
                          from pa_project_accum_budgets
                          where project_accum_id = l_project_accum_id
                          and budget_type_code = 'AC'
                          );


      -- Approved Revenue Budget Record, If NOT Already Exist

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
       SELECT l_project_accum_id,'AR',
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,
        0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        0,0,0,0,
        NULL,NULL,
        0,0,0,0,0,0,0,0,0,0,
        G_request_id,G_last_updated_by,Trunc(sysdate),
        Trunc(Sysdate),G_created_by,G_last_update_login
        FROM dual
        WHERE NOT EXISTS (select 'X'
                          from pa_project_accum_budgets
                          where project_accum_id = l_project_accum_id
                          and budget_type_code = 'AR'
                          );


 EXCEPTION


        WHEN dup_val_on_index THEN
             null; -- Although should not get this, OK if dup record exists.


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             ROLLBACK TO Upgrade_Accum_Pvt;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => G_PKG_NAME,
                    p_procedure_name   => l_api_name);

        WHEN OTHERS THEN
             x_msg_count     := 1;
             x_msg_data      := SUBSTR(SQLERRM, 1, 240);
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             ROLLBACK TO Upgrade_Accum_Pvt;
             FND_MSG_PUB.add_Exc_msg(
                    p_pkg_name         => G_PKG_NAME,
                    p_procedure_name   => l_api_name);



END Upgrade_Accum;

END pa_accum_proj_list;

/
