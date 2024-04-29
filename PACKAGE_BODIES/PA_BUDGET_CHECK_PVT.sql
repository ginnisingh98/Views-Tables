--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_CHECK_PVT" as
/*$Header: PAPMBCVB.pls 120.9.12010000.2 2010/01/15 08:04:12 sugupta ship $*/

--package global to be used during updates
G_USER_ID      CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID     CONSTANT NUMBER := FND_GLOBAL.login_id;
g_module_name   VARCHAR2(100)  := 'pa.plsql.PA_BUDGET_CHECK_PVT';

----------------------------------------------------------------------------------------
--Name:               get_valid_period_dates_Pvt
--Type:               Procedure
--Description:        This procedure can be used to get the valid begin and end date
--            for a budget line
--
--
--Called subprograms:
--
--
--
--History:
--   10-OCT-1996    L. de Werker    Created
--   17-OCT-1996    L. de Werker    Parameter p_period_name_out added, to enable the translation
--                                  of begin and end date to a period name.
--   08-JAN-2003    bvarnasi        Added additional validations for Date Range case.
--   05-Nov-2204    dbora           Added additional parameters in - p_context with default value of null
---                                 out - x_error_code to be passed back the validation error code if
--                                  the context is 'WEBADI'.
--                                  FP.M changes: For budgets having amount in multiple periods, p_period_name_in
--                                  can be null. Validations removed for non-time phasing and date range budgets
--
--   27-SEP-2005    jwhite          - Bug 4588279
--                                  For the get_valid_period_dates_Pvt procedure, added budgetary control
--                                  validation for latest encumbrance year.
--
--

PROCEDURE get_valid_period_dates_Pvt
( p_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_project_id              IN  NUMBER
 ,p_task_id                 IN  NUMBER
 ,p_time_phased_type_code   IN  VARCHAR2
 ,p_entry_level_code        IN  VARCHAR2
 ,p_period_name_in          IN  VARCHAR2
 ,p_budget_start_date_in    IN  DATE
 ,p_budget_end_date_in      IN  DATE
 ,p_period_name_out         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_start_date_out   OUT NOCOPY DATE --File.Sql.39 bug 4440895
 ,p_budget_end_date_out     OUT NOCOPY DATE --File.Sql.39 bug 4440895

 -- Bug 3986129: FP.M Web ADI Dev changes, new parameters
 ,p_context                IN   VARCHAR2
 ,p_calling_model_context  IN   VARCHAR2
 ,x_error_code             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
IS

   CURSOR l_budget_periods_csr
      (p_period_name    VARCHAR2
      ,p_period_type_code   VARCHAR2    )
   IS
   SELECT period_start_date
          ,  period_end_date
          ,  PERIOD_YEAR        /* bug 4588279: added PERIOD_YEAR */
   FROM   pa_budget_periods_v
   WHERE  period_name = p_period_name
   AND    period_type_code = p_period_type_code;

   CURSOR l_period_name_csr
          (p_start_date     DATE
          ,p_end_date       DATE
          ,p_period_type_code   VARCHAR2 )
   IS
   SELECT period_name
          ,  PERIOD_YEAR        /* bug 4588279: added PERIOD_YEAR */
   FROM   pa_budget_periods_v
   WHERE  period_type_code = p_period_type_code
   AND    period_start_date = p_start_date
   AND    period_end_date = p_end_date;


   CURSOR l_project_dates_csr
      ( p_project_id NUMBER )
   IS
   SELECT trunc(start_date)  --Added trunc for Bug 3899746
   ,      trunc(completion_date)  --Added trunc for Bug 3899746
   FROM   pa_projects
   WHERE  project_id = p_project_id;

   CURSOR l_task_dates_csr
      ( p_task_id NUMBER )
   IS
   SELECT trunc(start_date)  --Added trunc for Bug 3899746
   ,      trunc(completion_date)  --Added trunc for Bug 3899746
   FROM   pa_tasks
   WHERE  task_id = p_task_id;


   l_api_name           CONSTANT    VARCHAR2(30)  := 'get_valid_period_dates';
   l_task_start_date                DATE;
   l_task_end_date              DATE;
   l_project_start_date             DATE;
   l_project_end_date               DATE;
   l_budget_start_date              DATE;
   l_budget_end_date                DATE;
   l_period_name                VARCHAR2(20);

   l_amg_segment1               VARCHAR2(25);
   l_amg_task_number            VARCHAR2(50);

   --needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   CURSOR   l_amg_task_csr
      (p_pa_task_id pa_tasks.task_id%type)
   IS
   SELECT   task_number
   FROM     pa_tasks p
   WHERE p.task_id = p_pa_task_id;

   --Declared these constants for bug 2833255. These variables will contain
   --the truncated values for p_budget_start_date_in and p_budget_end_date_in
   l_budget_start_date_in  pa_budget_lines.start_date%TYPE :=trunc(p_budget_start_date_in);
   l_budget_end_date_in    pa_budget_lines.end_date%TYPE :=trunc(p_budget_end_date_in);

   -- Bug 3986129: FP.M Web ADI Dev changes, new variables
   valid_gl_start_date     VARCHAR2(1) := 'N';
   valid_gl_end_date       VARCHAR2(1) := 'N';
   valid_pa_start_date     VARCHAR2(1) := 'N';
   valid_pa_end_date       VARCHAR2(1) := 'N';

   l_elem_ver_id                         pa_proj_element_versions.element_version_id%TYPE;
   l_parent_structure_version_id         pa_proj_element_versions.parent_structure_version_id%TYPE;
   l_elem_ver_id_tbl                     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
   l_start_date_tbl                      SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
   l_compl_date_tbl                      SYSTEM.pa_date_tbl_type := SYSTEM.pa_date_tbl_type();
   l_msg_count                           NUMBER;
   l_msg_data                            VARCHAR2(2000);
   l_data                                VARCHAR2(2000);
   l_msg_index_out                       NUMBER;

   l_period_year                gl_period_statuses.period_year%TYPE;   /* bug 4588279: added PERIOD_YEAR */



BEGIN

--  Standard begin of API savepoint

    SAVEPOINT get_valid_period_dates_pvt;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( p_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;
/*
   OPEN l_amg_task_csr( p_task_id );
   FETCH l_amg_task_csr INTO l_amg_task_number;
   CLOSE l_amg_task_csr;
*/
   IF p_task_id <> 0 THEN

       l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
        (p_task_number=> ''
        ,p_task_reference => ''
        ,p_task_id => p_task_id);
   ELSE
      l_amg_task_number := l_amg_segment1;
   END IF;

--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check business rules related to timephasing
    -- P = PA period, G = GL period, R = Date Range


        IF p_time_phased_type_code = 'P'
        OR p_time_phased_type_code = 'G'
        THEN
               IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                    --dbms_output.put_line('Time phased code: '||p_time_phased_type_code);
                    --dbms_output.put_line('Period name     : '||p_period_name_in);

                     IF p_period_name_in IS NULL
                     OR p_period_name_in = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                        THEN

                        IF l_budget_start_date_in IS NULL
                        OR l_budget_start_date_in = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                        OR l_budget_end_date_in IS NULL
                        OR l_budget_end_date_in = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                        THEN
                          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                  pa_interface_utils_pub.map_new_amg_msg
                                     ( p_old_message_code => 'PA_BUDGET_DATES_MISSING'
                                      ,p_msg_attribute    => 'CHANGE'
                                      ,p_resize_flag      => 'N'
                                      ,p_msg_context      => 'BUDG'
                                      ,p_attribute1       => l_amg_segment1
                                      ,p_attribute2       => l_amg_task_number
                                      ,p_attribute3       => ''
                                      ,p_attribute4       => ''
                                      ,p_attribute5       => '');
                              END IF;
                              RAISE FND_API.G_EXC_ERROR;
                        ELSE
                        --try to get the period name related to those dates

                            OPEN l_period_name_csr(  l_budget_start_date_in
                                        ,l_budget_end_date_in
                                        ,p_time_phased_type_code  );

                            FETCH l_period_name_csr INTO l_period_name, l_period_year; /* bug 4588279: added PERIOD_YEAR */

                            IF l_period_name_csr%NOTFOUND
                            THEN
                                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                      pa_interface_utils_pub.map_new_amg_msg
                                        ( p_old_message_code => 'PA_PERIOD_DATES_INVALID'
                                         ,p_msg_attribute    => 'CHANGE'
                                         ,p_resize_flag      => 'N'
                                         ,p_msg_context      => 'BUDG'
                                         ,p_attribute1       => l_amg_segment1
                                         ,p_attribute2       => l_amg_task_number
                                         ,p_attribute3       => ''
                                         ,p_attribute4       => ''
                                         ,p_attribute5       => '');
                                 END IF;

                                 CLOSE l_period_name_csr;
                                 RAISE FND_API.G_EXC_ERROR;
                            END IF;

                            CLOSE l_period_name_csr;

                            p_budget_start_date_out := l_budget_start_date_in;
                            p_budget_end_date_out := l_budget_end_date_in;
                            p_period_name_out := l_period_name;
                        END IF;

                     ELSE

                            --get the related start and end dates
                        OPEN l_budget_periods_csr
                                ( p_period_name_in
                                    , p_time_phased_type_code   );


                        FETCH l_budget_periods_csr
                        INTO l_budget_start_date, l_budget_end_date, l_period_year;   /* bug 4588279: added PERIOD_YEAR */

                        IF l_budget_periods_csr%NOTFOUND
                        THEN
                            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                pa_interface_utils_pub.map_new_amg_msg
                                   ( p_old_message_code => 'PA_BUDGET_PERIOD_IS_INVALID'
                                    ,p_msg_attribute    => 'CHANGE'
                                    ,p_resize_flag      => 'Y'
                                    ,p_msg_context      => 'BUDG'
                                    ,p_attribute1       => l_amg_segment1
                                    ,p_attribute2       => l_amg_task_number
                                    ,p_attribute3       => ''
                                    ,p_attribute4       => ''
                                    ,p_attribute5       => '');
                            END IF;

                            CLOSE l_budget_periods_csr;
                            RAISE FND_API.G_EXC_ERROR;
                        END IF;

                        CLOSE l_budget_periods_csr;

                        p_budget_start_date_out := l_budget_start_date;
                        p_budget_end_date_out := l_budget_end_date;
                        p_period_name_out := p_period_name_in;

                  END IF; --is period_name_in missing

                        /* Bug 3986129: FP.M Web ADI Dev changes -Commenting out the following codes
                         * as date ranage budgets are no longer valid in FP.M */




                  -- Bug 4588279, 27-SEP-05, jwhite --------------------------------------------
                  -- For Budgetary Control Enabled GL budgets, issue error if the period_year is
                  -- later than the latest encumbrance year for the project.

                  -- The G_Latest_Encumbrance_Year global is populated by the calling procedure.

                  IF ( p_time_phased_type_code = 'G' )
                   THEN

                     IF ( PA_BUDGET_PUB.G_Latest_Encumbrance_Year > -99)
                       THEN
                         -- Budgetary Control Enabled
                         IF ( l_period_year > PA_BUDGET_PUB.G_Latest_Encumbrance_Year )
                           THEN
                                 pa_utils.add_message
                                        ( p_app_short_name  => 'PA',
                                          p_msg_name        => 'PA_BC_ENC_YR_NO_CHG_FUTURE');
                                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                         END IF;
                     END IF;

                  END IF;  -- p_time_phased_type_code = 'G'

                  -- End Bug 4588279, 27-SEP-05, jwhite -----------------------------------------


                        -- Bug 4437277 Adding the check  for forms based Model.
             END IF;

        ELSIF   p_time_phased_type_code = 'R'
          THEN
                            --validation of incoming dates
                        IF  NVL(p_calling_model_context ,'-99') = 'BUDGETSMODEL' THEN

                                IF l_budget_start_date_in = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                OR l_budget_start_date_in IS NULL
                                THEN
                                    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                                    THEN
                                   pa_interface_utils_pub.map_new_amg_msg
                                   ( p_old_message_code => 'PA_START_DATE_IS_MISSING'
                                    ,p_msg_attribute    => 'CHANGE'
                                    ,p_resize_flag      => 'N'
                                    ,p_msg_context      => 'PROJ'
                                    ,p_attribute1       => l_amg_segment1
                                    ,p_attribute2       => ''
                                    ,p_attribute3       => ''
                                    ,p_attribute4       => ''
                                    ,p_attribute5       => '');
                                    END IF;

                                    RAISE FND_API.G_EXC_ERROR;
                                END IF;

                                IF l_budget_end_date_in = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
                                OR l_budget_end_date_in IS NULL
                                THEN
                                    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                                    THEN
                                   pa_interface_utils_pub.map_new_amg_msg
                                   ( p_old_message_code => 'PA_END_DATE_IS_MISSING'
                                    ,p_msg_attribute    => 'CHANGE'
                                    ,p_resize_flag      => 'N'
                                    ,p_msg_context      => 'PROJ'
                                    ,p_attribute1       => l_amg_segment1
                                    ,p_attribute2       => ''
                                    ,p_attribute3       => ''
                                    ,p_attribute4       => ''
                                    ,p_attribute5       => '');
                                    END IF;

                                    RAISE FND_API.G_EXC_ERROR;
                                END IF;
                            /*
                            The following code is added while doing webADI changes. The following
                            validations are added (which were not being done earlier):
                            1. If the start date > end date
                            2. If start date < project / task start date based on the planning level of Proejct / Task respectively
                            3. If end date > project / task end date based on the planning level of Proejct / Task respectively
                            IMPORTANT NOTE:
                            Please do not change the message codes or do not change the way the
                            map_new_amg_msg API is called for the new validations. These validations
                            are common to AMG and webADI contexts. In case of webADI only lookup codes
                            can be used to display the error to the user. So, care has been taken
                            to keep the error code same as the lookup code.
                            */
                            IF l_budget_start_date_in > l_budget_end_date_in THEN
                                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                                THEN
                               pa_interface_utils_pub.map_new_amg_msg
                               ( p_old_message_code => 'PA_SU_INVALID_DATES'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'Y'  -- Set to Y so that get_new_message_code API is called and same message gets returned !
                                ,p_msg_context      => 'PROJ'
                                ,p_attribute1       => l_amg_segment1
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                                END IF;

                                RAISE FND_API.G_EXC_ERROR;
                            END IF;

                            IF p_entry_level_code = 'P' THEN
                                OPEN  l_project_dates_csr(p_project_id);
                                FETCH l_project_dates_csr INTO l_project_start_date, l_project_end_date;
                                CLOSE l_project_dates_csr;

                                IF  l_budget_start_date_in < l_project_start_date OR
                                    l_budget_end_date_in   > l_project_end_date   THEN
                                     pa_interface_utils_pub.map_new_amg_msg
                                     ( p_old_message_code => 'PA_FP_NO_PROJ_TASK_DATE_RANGE'
                                    ,p_msg_attribute    => 'CHANGE'
                                    ,p_resize_flag      => 'Y'  -- Set to Y so that get_new_message_code API is called and same message gets returned !
                                    ,p_msg_context      => 'PROJ'
                                    ,p_attribute1       => l_amg_segment1
                                    ,p_attribute2       => ''
                                    ,p_attribute3       => ''
                                    ,p_attribute4       => ''
                                    ,p_attribute5       => '');

                                    RAISE FND_API.G_EXC_ERROR;
                                END IF;

                            ELSE /* planning level is 'Task' */
                                OPEN l_task_dates_csr(p_task_id);
                                    FETCH l_task_dates_csr INTO l_task_start_date, l_task_end_date;
                                    CLOSE l_task_dates_csr;

                                IF  l_budget_start_date_in < l_task_start_date OR
                                    l_budget_end_date_in   > l_task_end_date   THEN
                                     pa_interface_utils_pub.map_new_amg_msg
                                     ( p_old_message_code => 'PA_FP_NO_TASK_DATE_RANGE'
                                    ,p_msg_attribute    => 'CHANGE'
                                    ,p_resize_flag      => 'Y'  -- Set to Y so that get_new_message_code API is called and same message gets returned !
                                    ,p_msg_context      => 'PROJ'
                                    ,p_attribute1       => l_amg_segment1
                                    ,p_attribute2       => ''
                                    ,p_attribute3       => ''
                                    ,p_attribute4       => ''
                                    ,p_attribute5       => '');

                                    RAISE FND_API.G_EXC_ERROR;
                                END IF;

                            END IF; -- End If for entry level 'Project'
                            -- End of additional validations done as part of webADI changes

                    -- Fix: 22-JAN-97, jwhite -------------------------------------------------------------------------------
                    -- For entry methods specified as 'date range',  start and end dates were not being returned.
                    --
                            p_budget_start_date_out := l_budget_start_date_in;
                            p_budget_end_date_out   := l_budget_end_date_in;
                            p_period_name_out := p_period_name_in;
                   -- -------------------------------------------------------------------------------------------------------------*/
                        END IF; -- If budget Type code not null
--               END IF; -- p_context <> WEBADI



        ELSE   --time_phased_type_code = 'N'

              /* Bug 3986129: FP.M Web ADI Dev changes:
               * Changed the logic in the code to derive the budget line start date and end date
               * by calling PA_PLANNING_TRANSACTION_UTILS.get_defautl_planning_dates api when
               * both these dates are not passed. If both the dates are passed to this api,
               * then they are honoured and the validation done here to check if end date > start date
               * If any one of the date is not passed, an error is raised.
               * Now, instead of populating the error messages to the stack, the respective error
               * code is returned back to the calling api to process it further, if this api is
               * called with p_context = 'WEBADI'
               */


              --For  Bug 4437277

            IF p_entry_level_code = 'P' THEN
                IF NVL(p_calling_model_context ,'-99') = 'BUDGETSMODEL' THEN


                     OPEN l_project_dates_csr(p_project_id);
                     FETCH l_project_dates_csr INTO l_project_start_date, l_project_end_date;
                     CLOSE l_project_dates_csr;

                     IF (l_project_start_date IS NULL) THEN

                             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_PROJ_START_DATE_MISS1'
                                 ,p_msg_attribute    => 'CHANGE'
                                 ,p_resize_flag      => 'N'
                                 ,p_msg_context      => 'PROJ'
                                 ,p_attribute1       => l_amg_segment1
                                 ,p_attribute2       => ''
                                 ,p_attribute3       => ''
                                 ,p_attribute4       => ''
                                 ,p_attribute5       => '');
                             END IF;
                             RAISE FND_API.G_EXC_ERROR;

                     END IF;

                     IF (l_project_end_date IS NULL) THEN

                             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                     pa_interface_utils_pub.map_new_amg_msg
                                     ( p_old_message_code => 'PA_PROJ_END_DATE_MISS1'
                                      ,p_msg_attribute    => 'CHANGE'
                                      ,p_resize_flag      => 'N'
                                      ,p_msg_context      => 'PROJ'
                                      ,p_attribute1       => l_amg_segment1
                                      ,p_attribute2       => ''
                                      ,p_attribute3       => ''
                                      ,p_attribute4       => ''
                                      ,p_attribute5       => '');
                             END IF;
                             RAISE FND_API.G_EXC_ERROR;
                     END IF; -- project end date is not null

                     p_budget_start_date_out := l_project_start_date;
                     p_budget_end_date_out   := l_project_end_date;
                     p_period_name_out       := p_period_name_in;

                     l_budget_start_date_in := l_project_start_date;
                     l_budget_end_date_in := l_project_end_date;

                ELSE /* PROJECT LEVEL PLANNING AND FINPLAN MODEL */

                         l_parent_structure_version_id := PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(p_project_id => p_project_id );

                         l_elem_ver_id_tbl.EXTEND(1);
                         l_elem_ver_id_tbl(l_elem_ver_id_tbl.COUNT) := 0;

			 -- Bug 8854015
 	                        IF (l_budget_start_date_in IS NOT NULL AND
 	                            l_budget_start_date_in <> FND_API.G_MISS_DATE) AND
 	                           (l_budget_end_date_in IS NOT NULL AND
 	                            l_budget_end_date_in <> FND_API.G_MISS_DATE) THEN

 	                          IF (l_budget_start_date_in > l_budget_end_date_in)
 	                          THEN
 	                            p_return_status := FND_API.G_RET_STS_ERROR;
 	                            PA_UTILS.add_message
 	                            (p_app_short_name => 'PA',
 	                             p_msg_name       => 'PA_INVALID_END_DATE');
 	                          END IF;

 	                          p_budget_start_date_out := l_budget_start_date_in;
 	                          p_budget_end_date_out   := l_budget_end_date_in;
 	                          p_period_name_out       := p_period_name_in;

 	                        ELSE

                         PA_PLANNING_TRANSACTION_UTILS.get_default_planning_dates
                            ( p_project_id                      => p_project_id
                             ,p_element_version_id_tbl          => l_elem_ver_id_tbl
                             ,p_project_structure_version_id    => l_parent_structure_version_id
                             ,x_planning_start_date_tbl         => l_start_date_tbl
                             ,x_planning_end_date_tbl           => l_compl_date_tbl
                             ,x_msg_data                        => l_msg_data
                             ,x_msg_count                       => l_msg_count
                             ,x_return_status                   => p_return_status);

                            IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                 -- raising execption to show the error messages
                                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                            END IF;

                            IF l_start_date_tbl.COUNT > 0 AND
                               l_compl_date_tbl.COUNT > 0 THEN
                                     p_budget_start_date_out := trunc(l_start_date_tbl(l_start_date_tbl.FIRST));
                                     p_budget_end_date_out := trunc(l_compl_date_tbl(l_compl_date_tbl.FIRST));
                                     l_budget_start_date_in := p_budget_start_date_out;
                                     l_budget_end_date_in := p_budget_end_date_out;
                                     p_period_name_out       := p_period_name_in;
                            ELSE
                                   -- raising execption to show the error messages
                                   pa_utils.add_message
                                        ( p_app_short_name  => 'PA',
                                          p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                                          p_token1          => 'PROCEDURENAME',
                                          p_value1          => 'get_valid_periods_date_pvt');
                                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                            END IF;
                   END IF;  -- Bug 8854015
                END IF;

            ELSIF p_entry_level_code IN ('T','M','L') THEN

                IF NVL(p_calling_model_context ,'-99') = 'BUDGETSMODEL' THEN

                    OPEN l_task_dates_csr(p_task_id);
                    FETCH l_task_dates_csr INTO l_task_start_date, l_task_end_date;
                    CLOSE l_task_dates_csr;

                    IF l_task_start_date IS NULL OR l_task_end_date IS NULL  THEN
                        OPEN l_project_dates_csr(p_project_id);
                        FETCH l_project_dates_csr INTO l_project_start_date, l_project_end_date;
                        CLOSE l_project_dates_csr;

                        /* Added check for the bug #2734425. If the Project/Task Start Date
                           and End Date are null or they do not match with the input
                           parameters, then an error has to be raised. */

                        IF l_task_start_date IS NULL  --implies that task_end_date is null too!!
                        THEN
                            IF (l_project_start_date IS NULL) THEN
                                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                    pa_interface_utils_pub.map_new_amg_msg
                                    ( p_old_message_code => 'PA_PROJ_START_DATE_MISS2'
                                     ,p_msg_attribute    => 'CHANGE'
                                     ,p_resize_flag      => 'N'
                                     ,p_msg_context      => 'PROJ'
                                     ,p_attribute1       => l_amg_segment1
                                     ,p_attribute2       => ''
                                     ,p_attribute3       => ''
                                     ,p_attribute4       => ''
                                     ,p_attribute5       => '');
                                END IF;

                                RAISE FND_API.G_EXC_ERROR;
                            END IF;

                            IF (l_project_end_date IS NULL) THEN
                                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                    pa_interface_utils_pub.map_new_amg_msg
                                    ( p_old_message_code => 'PA_PROJ_END_DATE_MISS2'
                                     ,p_msg_attribute    => 'CHANGE'
                                     ,p_resize_flag      => 'N'
                                     ,p_msg_context      => 'PROJ'
                                     ,p_attribute1       => l_amg_segment1
                                     ,p_attribute2       => ''
                                     ,p_attribute3       => ''
                                     ,p_attribute4       => ''
                                     ,p_attribute5       => '');
                                END IF;

                                RAISE FND_API.G_EXC_ERROR;
                            END IF;
                        END IF;

                            p_budget_start_date_out := l_project_start_date;
                            p_budget_end_date_out := l_project_end_date;
                            p_period_name_out := p_period_name_in;

                            l_budget_start_date_in := l_project_start_date;
                            l_budget_end_date_in := l_project_end_date;

                    ELSIF l_task_start_date IS NOT NULL AND l_task_end_date IS NULL THEN

                        OPEN l_project_dates_csr(p_project_id);
                        FETCH l_project_dates_csr INTO l_project_start_date, l_project_end_date;
                        CLOSE l_project_dates_csr;

                        IF (l_project_end_date IS NULL) THEN  -- changed elsif to if for bug 3682546
                            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                 pa_interface_utils_pub.map_new_amg_msg
                                 ( p_old_message_code => 'PA_PROJ_END_DATE_MISS3'
                                  ,p_msg_attribute    => 'CHANGE'
                                  ,p_resize_flag      => 'N'
                                  ,p_msg_context      => 'PROJ'
                                  ,p_attribute1       => l_amg_segment1
                                  ,p_attribute2       => ''
                                  ,p_attribute3       => ''
                                  ,p_attribute4       => ''
                                  ,p_attribute5       => '');
                            END IF;
                            RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        p_budget_start_date_out := l_task_start_date;
                        p_budget_end_date_out := l_project_end_date;
                        p_period_name_out := p_period_name_in;
                    ELSE
                         p_budget_start_date_out  := l_task_start_date;
                         p_budget_end_date_out  := l_task_end_date;
                         p_period_name_out := p_period_name_in;

                    END IF;

                ELSIF NVL(p_calling_model_context , '-99') = 'FINPLANMODEL' THEN


                IF l_budget_start_date_in IS NOT NULL AND
                   l_budget_end_date_in IS NOT NULL THEN
                         -- validate if the end date passed is greater then the start date
                         IF l_budget_end_date_in < l_budget_start_date_in THEN
                                IF Nvl(p_context, '-99') <> 'WEBADI' THEN
                                     pa_interface_utils_pub.map_new_amg_msg
                                       ( p_old_message_code => 'PA_INVALID_START_DATE'
                                        ,p_msg_attribute    => 'CHANGE'
                                        ,p_resize_flag      => 'N'
                                        ,p_msg_context      => 'PROJ'
                                        ,p_attribute1       => l_amg_segment1
                                        ,p_attribute2       => ''
                                        ,p_attribute3       => ''
                                        ,p_attribute4       => ''
                                        ,p_attribute5       => '');

                                        RAISE FND_API.G_EXC_ERROR;
                                ELSIF p_context = 'WEBADI' THEN
                                     x_error_code := 'FP_WEBADI_PLAN_DATE_ERR';
                                     p_return_status := FND_API.G_RET_STS_ERROR;
                                     RETURN;
                                END IF;
                         END IF;  -- start date > end date
                         p_budget_start_date_out := l_budget_start_date_in;
                         p_budget_end_date_out   := l_budget_end_date_in;

                ELSIF l_budget_start_date_in IS NOT NULL AND
                      l_budget_end_date_in IS NULL THEN
                         -- raise error according to context
                         IF Nvl(p_context, '-99') <> 'WEBADI' THEN
                              pa_interface_utils_pub.map_new_amg_msg
                               ( p_old_message_code => 'PA_END_DATE_IS_MISSING'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'PROJ'
                                ,p_attribute1       => l_amg_segment1
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');

                                RAISE FND_API.G_EXC_ERROR;
                         ELSIF p_context = 'WEBADI' THEN
                              x_error_code := 'PA_FP_WA_PLAN_DATE_MIS';
                              p_return_status := FND_API.G_RET_STS_ERROR;
                              RETURN;
                         END IF;
                ELSIF l_budget_start_date_in IS NULL AND
                      l_budget_end_date_in IS NOT NULL THEN
                         -- raise error according to context
                         IF Nvl(p_context, '-99') <> 'WEBADI' THEN
                              pa_interface_utils_pub.map_new_amg_msg
                               ( p_old_message_code => 'PA_START_DATE_IS_MISSING'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'PROJ'
                                ,p_attribute1       => l_amg_segment1
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');

                                RAISE FND_API.G_EXC_ERROR;
                         ELSIF p_context = 'WEBADI' THEN
                              x_error_code := 'PA_FP_WA_PLAN_DATE_MIS';
                              p_return_status := FND_API.G_RET_STS_ERROR;
                              RETURN;
                         END IF;
                ELSIF l_budget_start_date_in IS NULL AND
                      l_budget_end_date_in IS NULL THEN

                         l_parent_structure_version_id := PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(p_project_id => p_project_id );
                         -- getting the element_version_id

                         IF p_task_id <> 0 THEN
                              BEGIN
                                    SELECT  pev.element_version_id
                                    INTO    l_elem_ver_id
                                    FROM    pa_proj_element_versions pev
                                    WHERE   pev.proj_element_id = p_task_id
                                    AND     pev.parent_structure_version_id = l_parent_structure_version_id;
                              EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                         RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                              END;

                              -- preparing the input tables
                              l_elem_ver_id_tbl.EXTEND(1);
                              l_elem_ver_id_tbl(l_elem_ver_id_tbl.COUNT) := l_elem_ver_id;

                         ELSE /* Project level planning */

                              l_elem_ver_id_tbl.EXTEND(1);
                              l_elem_ver_id_tbl(l_elem_ver_id_tbl.COUNT) := 0;

                         END IF;

                         PA_PLANNING_TRANSACTION_UTILS.get_default_planning_dates
                            ( p_project_id                      => p_project_id
                             ,p_element_version_id_tbl          => l_elem_ver_id_tbl
                             ,p_project_structure_version_id    => l_parent_structure_version_id
                             ,x_planning_start_date_tbl         => l_start_date_tbl
                             ,x_planning_end_date_tbl           => l_compl_date_tbl
                             ,x_msg_data                        => l_msg_data
                             ,x_msg_count                       => l_msg_count
                             ,x_return_status                   => p_return_status);

                            IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                 -- raising execption to show the error messages
                                 RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                            END IF;

                            IF l_start_date_tbl.COUNT > 0 AND
                               l_compl_date_tbl.COUNT > 0 THEN
                                     p_budget_start_date_out := trunc(l_start_date_tbl(l_start_date_tbl.FIRST));
                                     p_budget_end_date_out := trunc(l_compl_date_tbl(l_compl_date_tbl.FIRST));
                            ELSE
                                   -- raising execption to show the error messages
                                   pa_utils.add_message
                                        ( p_app_short_name  => 'PA',
                                          p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                                          p_token1          => 'PROCEDURENAME',
                                          p_value1          => 'get_valid_periods_date_pvt');
                                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                            END IF;
                END IF;  -- budget dates

                IF p_period_name_in IS NOT NULL THEN
                     p_period_name_out := p_period_name_in;
                END IF;

          END IF ; --Budget Type code is not null
       END IF; -- t/m/l


        END IF;  --time phased type code N


        IF p_context = 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
              IF p_period_name_in IS NULL THEN
                    IF l_budget_start_date_in IS NOT NULL AND
                       l_budget_end_date_in IS NOT NULL THEN

                             -- multiple periods may be present
                             IF p_time_phased_type_code = 'G' THEN
                                 BEGIN
                                     SELECT 'Y'
                                     INTO   valid_gl_start_date
                                     FROM   dual
                                     WHERE EXISTS (SELECT 'X'
                                                   FROM   pa_budget_periods_v
                                                   WHERE  period_type_code = 'G'
                                                   AND    period_start_date = l_budget_start_date_in);
                                 EXCEPTION
                                     WHEN NO_DATA_FOUND THEN
                                          valid_gl_start_date := 'N';
                                 END;

                                 BEGIN
                                     SELECT 'Y'
                                     INTO   valid_gl_end_date
                                     FROM   dual
                                     WHERE EXISTS (SELECT 'X'
                                                   FROM   pa_budget_periods_v
                                                   WHERE  period_type_code = 'G'
                                                   AND    period_end_date = l_budget_end_date_in);

                                EXCEPTION
                                     WHEN NO_DATA_FOUND THEN
                                          valid_gl_end_date := 'N';
                                END;

                                IF valid_gl_start_date <> 'Y' THEN
                                    x_error_code := 'PA_FP_WA_PLAN_ST_DATE_NOT_VLD';
                                    p_return_status := FND_API.G_RET_STS_ERROR;
                                    RETURN;
                                END IF;

                                IF valid_gl_end_date <> 'Y' THEN
                                    x_error_code := 'PA_FP_WA_PLAN_EN_DATE_NOT_VLD';
                                    RETURN;
                                END IF;

                                -- Bug 4588279, 27-SEP-05, jwhite --------------------------------
                                -- Whenever Financial Planning is enabled for Budgetary Control, then
                                -- there could be a need for latest encumbrance year validation.
                                -- End Bug 4588279, 27-SEP-05, jwhite ----------------------------


                             ELSIF p_time_phased_type_code = 'P' THEN
                                BEGIN
                                     SELECT 'Y'
                                     INTO   valid_pa_start_date
                                     FROM   dual
                                     WHERE EXISTS (SELECT 'X'
                                                   FROM   pa_budget_periods_v
                                                   WHERE  period_type_code = 'P'
                                                   AND    period_start_date = l_budget_start_date_in);
                                EXCEPTION
                                     WHEN NO_DATA_FOUND THEN
                                          valid_pa_start_date := 'N';
                                END;

                                BEGIN
                                     SELECT 'Y'
                                     INTO   valid_pa_end_date
                                     FROM   dual
                                     WHERE EXISTS (SELECT 'X'
                                                   FROM   pa_budget_periods_v
                                                   WHERE  period_type_code = 'P'
                                                   AND    period_end_date = l_budget_end_date_in);

                                EXCEPTION
                                     WHEN NO_DATA_FOUND THEN
                                          valid_pa_end_date := 'N';
                                END;

                                IF valid_gl_start_date <> 'Y' THEN
                                     x_error_code := 'PA_FP_WA_PLAN_ST_DATE_NOT_VLD';
                                     p_return_status := FND_API.G_RET_STS_ERROR;
                                     RETURN;
                                END IF;

                                IF valid_gl_end_date <> 'Y' THEN
                                     x_error_code := 'PA_FP_WA_PLAN_EN_DATE_NOT_VLD';
                                     p_return_status := FND_API.G_RET_STS_ERROR;
                                     RETURN;
                                END IF;
                             END IF;

                             IF l_budget_start_date > l_budget_end_date THEN
                                   x_error_code := 'PA_FP_WA_PLAN_DATE_ERR';
                                   p_return_status := FND_API.G_RET_STS_ERROR;
                                   RETURN;
                             END IF;
                             p_budget_start_date_out := l_budget_start_date_in;
                             p_budget_end_date_out := l_budget_end_date_in;

                    ELSIF l_budget_start_date_in IS NOT NULL AND
                          l_budget_end_date_in IS NULL THEN
                               -- throw error if one of the date is missing
                               x_error_code := 'PA_FP_WA_PLAN_DATE_MIS';
                               p_return_status := FND_API.G_RET_STS_ERROR;
                               RETURN;

                    ELSIF l_budget_start_date_in IS NULL AND
                          l_budget_end_date_in IS NOT NULL THEN
                               x_error_code := 'PA_FP_WA_PLAN_DATE_MIS';
                               p_return_status := FND_API.G_RET_STS_ERROR;
                               RETURN;
                    /*ELSIF l_budget_start_date_in IS NULL AND
                          l_budget_end_date_in IS NULL THEN
                           -- call an api to derive the default planning dates

                           -- preparing the input tables
                           l_elem_ver_id_tbl.EXTEND(1);
                           l_elem_ver_id_tbl(l_elem_ver_id_tbl.COUNT) := p_task_id;

                           PA_PLANNING_TRANSACTION_UTILS.get_default_planning_dates
                              ( p_project_id                      => p_project_id
                               ,p_element_version_id_tbl          => l_elem_ver_id_tbl
                               ,p_project_structure_version_id    => PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(p_project_id => p_project_id )
                               ,x_planning_start_date_tbl         => l_start_date_tbl
                               ,x_planning_end_date_tbl           => l_compl_date_tbl
                               ,x_msg_data                        => l_msg_data
                               ,x_msg_count                       => l_msg_count
                               ,x_return_status                   => p_return_status);

                              IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                   -- raising execption to show the error messages
                                   RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                              END IF;

                              IF l_start_date_tbl.COUNT > 0 AND
                                 l_compl_date_tbl.COUNT > 0 THEN
                                       p_budget_start_date_out := trunc(l_start_date_tbl(l_start_date_tbl.FIRST));
                                       p_budget_end_date_out := trunc(l_compl_date_tbl(l_compl_date_tbl.FIRST));
                              ELSE
                                     -- raising execption to show the error messages
                                     pa_utils.add_message
                                          ( p_app_short_name  => 'PA',
                                            p_msg_name        => 'PA_FP_INV_PARAM_PASSED',
                                            p_token1          => 'PROCEDURENAME',
                                            p_value1          => 'get_valid_periods_date_pvt');
                                     RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                              END IF;*/
                    END IF; -- planning dates not null
              END IF;  -- period name is null
        END IF;  -- p_context = WEBADI

EXCEPTION
    WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
           l_msg_count := FND_MSG_PUB.count_msg;
             IF l_msg_count = 1 THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);
             END IF;
           p_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_ERROR
    THEN

    ROLLBACK TO get_valid_period_dates_pvt;

    p_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN

    ROLLBACK TO get_valid_period_dates_pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

    ROLLBACK TO get_valid_period_dates_pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
        (  p_pkg_name       => G_PKG_NAME
        ,  p_procedure_name => l_api_name );

    END IF;

END get_valid_period_dates_Pvt;


----------------------------------------------------------------------------------------
--Name:               check_entry_method_flags_Pvt
--Type:               Procedure
--Description:        This procedure can be used to check whether it is allowed to pass
--            cost quantity, raw_cost, burdened_cost, revenue and revenue quantity.
--
--
--Called subprograms:
--
--
--
--History:
--    15-OCT-1996     L. de Werker    Created
--
--    09-FEB-2002     Srikanth        Modified as part of changes for finplan model.
--                                    budget amount code should be null when called from
--                                    fin plan model. It should have a valid value when
--                                    called from budget model.Similarly p_version_type
--                                    should be null in budget model and should have
--                                    valid value (COST,REVENUE,ALL) in finplan model
--    04-Nov-03       dbora           Bug 3986129: FP.M Web ADI Dev changes made
--                                    to be used for webadi context as well. New parameter
--                                    added p_context is defaulted to null and other valid
--                                    value is 'WEBADI'. The out variable x_webadi_error_code
--                                    would be populated only if the context is 'WEBADI'.

PROCEDURE check_entry_method_flags_Pvt
( p_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_amount_code        IN  VARCHAR2
 ,p_budget_entry_method_code  IN  VARCHAR2
 ,p_quantity                  IN  NUMBER
 ,p_raw_cost                  IN  NUMBER
 ,p_burdened_cost             IN  NUMBER
 ,p_revenue                   IN  NUMBER

 --Included for fin plan model
 ,p_version_type              IN  VARCHAR2
 ,p_allow_qty_flag            IN  VARCHAR2
 ,p_allow_raw_cost_flag       IN  VARCHAR2
 ,p_allow_burdened_cost_flag  IN  VARCHAR2
 ,p_allow_revenue_flag        IN  VARCHAR2

-- Bug 3986129: FP.M Web ADI Dev changes, new parameters
 ,p_context                   IN  VARCHAR2
 ,p_raw_cost_rate             IN  NUMBER
 ,p_burdened_cost_rate        IN  NUMBER
 ,p_bill_rate                 IN  NUMBER
 ,p_allow_raw_cost_rate_flag  IN  VARCHAR2
 ,p_allow_burd_cost_rate_flag IN  VARCHAR2
 ,p_allow_bill_rate_flag      IN  VARCHAR2
 ,x_webadi_error_code         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
IS

      -- needed to get the flags associated to a budget entry method

      CURSOR   l_budget_entry_method_csr
      (p_budget_entry_method_code pa_budget_entry_methods.budget_entry_method_code%type )
      IS
      SELECT cost_quantity_flag
      ,      raw_cost_flag
      ,      burdened_cost_flag
      ,      rev_quantity_flag
      ,      revenue_flag
      FROM   pa_budget_entry_methods
      WHERE  budget_entry_method_code = p_budget_entry_method_code
      AND    trunc(sysdate) BETWEEN trunc(start_date_active) and trunc(nvl(end_date_active,sysdate));

      l_api_name           CONSTANT    VARCHAR2(30)        := 'check_entry_method_flags';

      l_cost_quantity_flag             VARCHAR2(1);
      l_raw_cost_flag                  VARCHAR2(1);
      l_burdened_cost_flag             VARCHAR2(1);
      l_rev_quantity_flag              VARCHAR2(1);
      l_revenue_flag                   VARCHAR2(1);

      --Included these parameters as part of changes in finplan model
      l_msg_count                      NUMBER := 0;
      l_data                           VARCHAR2(2000);
      l_msg_data                       VARCHAR2(2000);
      l_msg_index_out                  NUMBER;
      l_debug_mode                     VARCHAR2(1);
      l_module_name                    VARCHAR2(80);
      l_debug_level2          CONSTANT NUMBER := 2;
      l_debug_level3          CONSTANT NUMBER := 3;
      l_debug_level4          CONSTANT NUMBER := 4;
      l_debug_level5          CONSTANT NUMBER := 5;

      -- Bug 3986129: FP.M Web ADI Dev changes
      l_raw_cost_rate_flag             VARCHAR2(1);
      l_burd_cost_rate_flag            VARCHAR2(1);
      l_bill_rate_flag                 VARCHAR2(1);

BEGIN

      --Standard begin of API savepoint

      SAVEPOINT check_entry_method_flags_pvt;

      --Set API return status to success

      p_return_status := FND_API.G_RET_STS_SUCCESS;
      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
      l_module_name := 'check_entry_method_flags_Pvt: ' || g_module_name;

	IF l_debug_mode = 'Y' THEN
	      pa_debug.set_curr_function( p_function   => 'check_entry_method_flags_Pvt',
                                  p_debug_mode => l_debug_mode );
	END IF;

      --Check for the context in which the API is called and initialise
      --the amount flags

      --Budget model. Get the flags from budet entry method code
      IF (p_budget_amount_code IS NOT NULL) AND (p_version_type IS NULL) THEN

            OPEN l_budget_entry_method_csr(p_budget_entry_method_code);
            FETCH l_budget_entry_method_csr INTO l_cost_quantity_flag
                          ,l_raw_cost_flag
                          ,l_burdened_cost_flag
                          ,l_rev_quantity_flag
                          ,l_revenue_flag;
            CLOSE l_budget_entry_method_csr;

      --FinPlan Model. Get the flags from the parameters convertion them to N if Null
      ELSIF (p_budget_amount_code IS NULL) AND (p_version_type IS NOT NULL) THEN

            l_cost_quantity_flag  :=  nvl(p_allow_qty_flag,'N');
            l_raw_cost_flag       :=  nvl(p_allow_raw_cost_flag,'N');
            l_burdened_cost_flag  :=  nvl(p_allow_burdened_cost_flag,'N');
            l_rev_quantity_flag   :=  nvl(p_allow_qty_flag,'N');
            l_revenue_flag        :=  nvl(p_allow_revenue_flag,'N');

            -- Bug 3986129: FP.M Web ADI Dev changes
            l_raw_cost_rate_flag   := Nvl(p_allow_raw_cost_rate_flag, 'N');
            l_burd_cost_rate_flag  := Nvl(p_allow_burd_cost_rate_flag, 'N');
            l_bill_rate_flag       := Nvl(p_allow_bill_rate_flag, 'N');

      ELSE

            IF l_debug_mode='Y' THEN
                  pa_debug.g_err_stage:= 'p_budget_amount_code passed is ' || p_budget_amount_code ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);

                  pa_debug.g_err_stage:= 'p_version_type passed is ' || p_version_type ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);

            END IF;

            PA_UTILS.ADD_MESSAGE
                  (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_FP_INV_PARAM_PASSED');

            p_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;

      END IF;--IF (p_budget_amount_code IS NOT NULL) AND (p_version_type IS NULL)

--checking on mandatory flags

      --COST BUDGET or COST FINPLAN VERSION
      IF ( p_budget_amount_code = 'C'
        OR p_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST)
      THEN
            IF l_cost_quantity_flag = 'N'
            AND (    p_quantity <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
              AND p_quantity IS NOT NULL )
            THEN
                  IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                             /* Bug 3132035, Token is removed
                              */
                             PA_UTILS.ADD_MESSAGE
                                 (p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_COST_QTY_NOT_ALLOWED');
                             p_return_status := FND_API.G_RET_STS_ERROR;
                         END IF;

                         --RAISE FND_API.G_EXC_ERROR;
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         IF l_debug_mode='Y' THEN
                              pa_debug.g_err_stage:= 'Cost Qty not allowed' ;
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                         END IF;

                  ELSIF p_context = 'WEBADI' THEN
                         IF l_debug_mode='Y' THEN
                              pa_debug.g_err_stage:= 'WEBADI: Cost Qty not allowed';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                              pa_debug.g_err_stage:= 'Populating Error Code';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                         END IF;

                         x_webadi_error_code := 'PA_FP_WA_COST_QTY_NOT_ALWD';
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         RETURN;
                  END IF;

            END IF;

            IF  l_raw_cost_flag = 'N'
            AND (    p_raw_cost <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
              AND p_raw_cost IS NOT NULL )
            THEN
                  IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                           /* Bug 3132035, Token is removed
                            */
                           PA_UTILS.ADD_MESSAGE
                                 (p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_RAW_COST_NOT_ALLOWED');
                           p_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;

                        --RAISE FND_API.G_EXC_ERROR;
                        p_return_status := FND_API.G_RET_STS_ERROR;
                        IF l_debug_mode='Y' THEN
                             pa_debug.g_err_stage:= 'Raw Cost not allowed' ;
                             pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                        END IF;

                  ELSIF p_context = 'WEBADI' THEN
                        IF l_debug_mode='Y' THEN
                              pa_debug.g_err_stage:= 'WEBADI: Raw Cost not allowed';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                              pa_debug.g_err_stage:= 'Populating Error Code';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                         END IF;

                         x_webadi_error_code := 'PA_FP_WA_RAW_COST_NOT_ALWD';
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         RETURN;
                  END IF; -- Bug 3986129: FP.M Web ADI Dev changes

            END IF;

            IF l_burdened_cost_flag = 'N'
            AND (    p_burdened_cost <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
              AND p_burdened_cost IS NOT NULL )
            THEN
                  IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            /* Bug 3132035, Token is removed
                             */
                            PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_BURD_COST_NOT_ALLOWED');

                            --RAISE FND_API.G_EXC_ERROR;
                            p_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                        IF l_debug_mode='Y' THEN
                            pa_debug.g_err_stage:= 'Burd Cost not allowed' ;
                            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                        END IF;
                  ELSIF p_context = 'WEBADI' THEN
                        IF l_debug_mode='Y' THEN
                              pa_debug.g_err_stage:= 'WEBADI: Burd Cost not allowed';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                              pa_debug.g_err_stage:= 'Populating Error Code';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                         END IF;

                         x_webadi_error_code := 'PA_FP_WA_BURD_COST_NOT_ALWD';
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         RETURN;
                  END IF; -- Bug 3986129: FP.M Web ADI Dev changes

            END IF;

            -- Revenue should be null for a COST version. AMG UT2
            IF p_revenue <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
               p_revenue IS NOT NULL
            THEN
                  IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                           /* Bug 3132035, Token is removed
                            */
                           PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_REVENUE_NOT_ALLOWED');
                           p_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;

                        IF l_debug_mode='Y' THEN
                           pa_debug.g_err_stage:= 'Rev Amt not allowed' ;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                        END IF;

                        --RAISE FND_API.G_EXC_ERROR;
                        p_return_status := FND_API.G_RET_STS_ERROR;
                  ELSIF p_context = 'WEBADI' THEN
                        IF l_debug_mode='Y' THEN
                              pa_debug.g_err_stage:= 'WEBADI: Revenue not allowed';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                              pa_debug.g_err_stage:= 'Populating Error Code';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                         END IF;

                         x_webadi_error_code := 'PA_FP_WA_REVENUE_NOT_ALWD';
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         RETURN;
                  END IF;  -- Bug 3986129: FP.M Web ADI Dev changes
            END IF;

      --REVENUE BUDGET OR REVENUE FINPLAN VERSION
      ELSIF( p_budget_amount_code = 'R'
          OR p_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE)
      THEN
            IF l_rev_quantity_flag = 'N'
            AND (    p_quantity <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
              AND p_quantity IS NOT NULL )
            THEN
                  IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                           /* Bug 3132035, Token is removed
                            */
                           PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_REV_QTY_NOT_ALLOWED');
                           p_return_status := FND_API.G_RET_STS_ERROR;
                       END IF;

                       --RAISE FND_API.G_EXC_ERROR;
                       p_return_status := FND_API.G_RET_STS_ERROR;
                       IF l_debug_mode='Y' THEN
                           pa_debug.g_err_stage:= 'Rev Qty not allowed' ;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                       END IF;

                  ELSIF p_context = 'WEBADI' THEN
                       IF l_debug_mode='Y' THEN
                              pa_debug.g_err_stage:= 'WEBADI: Revenue Qty not allowed';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                              pa_debug.g_err_stage:= 'Populating Error Code';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                         END IF;

                         x_webadi_error_code := 'PA_FP_WA_REV_QTY_NOT_ALWD';
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         RETURN;
                  END IF;  -- Bug 3986129: FP.M Web ADI Dev changes
            END IF;

            IF l_revenue_flag = 'N'
                 AND (    p_revenue <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                 AND p_revenue IS NOT NULL )
            THEN
                  IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                             /* Bug 3132035, Token is removed
                              */
                             PA_UTILS.ADD_MESSAGE
                                 (p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_REVENUE_NOT_ALLOWED');
                             p_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                        IF l_debug_mode='Y' THEN
                             pa_debug.g_err_stage:= 'Rev Amt not allowed' ;
                             pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                        END IF;

                        --RAISE FND_API.G_EXC_ERROR;
                        p_return_status := FND_API.G_RET_STS_ERROR;
                  ELSIF p_context = 'WEBADI' THEN
                        IF l_debug_mode='Y' THEN
                              pa_debug.g_err_stage:= 'WEBADI: Revenue not allowed';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                              pa_debug.g_err_stage:= 'Populating Error Code';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                         END IF;

                         x_webadi_error_code := 'PA_FP_WA_REVENUE_NOT_ALWD';
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         RETURN;
                  END IF; -- Bug 3986129: FP.M Web ADI Dev changes
            END IF;

            -- Raw cost and Burdened Cost amounts should be null for a revenue
            -- Version. AMG UT2.
            IF  p_raw_cost <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                p_raw_cost IS NOT NULL
            THEN
                  IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                     /* Bug 3132035, Token is removed
                     */
                      PA_UTILS.ADD_MESSAGE
                        (p_app_short_name => 'PA',
                         p_msg_name       => 'PA_RAW_COST_NOT_ALLOWED');
                      p_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;

                  --RAISE FND_API.G_EXC_ERROR;
                  p_return_status := FND_API.G_RET_STS_ERROR;
                  IF l_debug_mode='Y' THEN
                        pa_debug.g_err_stage:= 'Raw Cost not allowed' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);

                  END IF;
                  ELSIF  p_context = 'WEBADI' THEN
                        IF l_debug_mode='Y' THEN
                              pa_debug.g_err_stage:= 'WEBADI: Raw Cost not allowed';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                              pa_debug.g_err_stage:= 'Populating Error Code';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                         END IF;

                         x_webadi_error_code := 'PA_FP_WA_RAW_COST_NOT_ALWD';
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         RETURN;
                  END IF;  -- Bug 3986129: FP.M Web ADI Dev changes

            END IF;

            IF p_burdened_cost <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
               p_burdened_cost IS NOT NULL
            THEN
                  IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            /* Bug 3132035, Token is removed
                             */
                            PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_BURD_COST_NOT_ALLOWED');

                            --RAISE FND_API.G_EXC_ERROR;
                            p_return_status := FND_API.G_RET_STS_ERROR;
                       END IF;
                       IF l_debug_mode='Y' THEN
                            pa_debug.g_err_stage:= 'Burd Cost not allowed' ;
                            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                       END IF;
                  ELSIF p_context = 'WEBADI' THEN
                       IF l_debug_mode='Y' THEN
                              pa_debug.g_err_stage:= 'WEBADI: Burd Cost not allowed';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                              pa_debug.g_err_stage:= 'Populating Error Code';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                         END IF;

                         x_webadi_error_code := 'PA_FP_WA_BURD_COST_NOT_ALWD';
                         p_return_status := FND_API.G_RET_STS_ERROR;
                         RETURN;
                  END IF;  -- Bug 3986129: FP.M Web ADI Dev changes
            END IF;

      --FinPlan Model . Cost and Revenue Together Version
      ELSIF(p_version_type=PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL)THEN

            IF p_allow_qty_flag = 'N'
            AND (    p_quantity <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
              AND p_quantity IS NOT NULL )
            THEN
                  IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                           /* Bug 3132035, Token is removed
                            */
                           PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_REV_QTY_NOT_ALLOWED');
                           p_return_status := FND_API.G_RET_STS_ERROR;
                       END IF;

                       --RAISE FND_API.G_EXC_ERROR;
                       p_return_status := FND_API.G_RET_STS_ERROR;
                       IF l_debug_mode='Y' THEN
                            pa_debug.g_err_stage:= 'All Qty not allowed' ;
                            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                       END IF;
                  ELSIF p_context = 'WEBADI' THEN
                       IF l_debug_mode='Y' THEN
                            pa_debug.g_err_stage:= 'WEBADI: All quantity not allowed';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                            pa_debug.g_err_stage:= 'Populating Error Code';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                       END IF;

                       x_webadi_error_code := 'PA_FP_WA_REV_QTY_NOT_ALWD';
                       p_return_status := FND_API.G_RET_STS_ERROR;
                       RETURN;
                  END IF;  -- Bug 3986129: FP.M Web ADI Dev changes
            END IF;

            IF l_raw_cost_flag = 'N'
            AND (    p_raw_cost <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
              AND p_raw_cost IS NOT NULL )
            THEN
                  IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            /* Bug 3132035, Token is removed
                             */
                            PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_RAW_COST_NOT_ALLOWED');
                            p_return_status := FND_API.G_RET_STS_ERROR;
                       END IF;

                       --RAISE FND_API.G_EXC_ERROR;
                       p_return_status := FND_API.G_RET_STS_ERROR;
                       IF l_debug_mode='Y' THEN
                            pa_debug.g_err_stage:= 'All Raw Cost not allowed' ;
                            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                       END IF;
                  ELSIF p_context = 'WEBADI' THEN
                       IF l_debug_mode='Y' THEN
                            pa_debug.g_err_stage:= 'WEBADI: Raw Cost not allowed';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                            pa_debug.g_err_stage:= 'Populating Error Code';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                       END IF;

                       x_webadi_error_code := 'PA_FP_WA_RAW_COST_NOT_ALWD';
                       p_return_status := FND_API.G_RET_STS_ERROR;
                       RETURN;
                  END IF;  -- Bug 3986129: FP.M Web ADI Dev changes
            END IF;

            IF l_burdened_cost_flag = 'N'
            AND (    p_burdened_cost <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
              AND p_burdened_cost IS NOT NULL )
            THEN
                  IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                           /* Bug 3132035, Token is removed
                           */
                           PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_BURD_COST_NOT_ALLOWED');

                           --RAISE FND_API.G_EXC_ERROR;
                           p_return_status := FND_API.G_RET_STS_ERROR;
                       END IF;
                       IF l_debug_mode='Y' THEN
                           pa_debug.g_err_stage:= 'All Burd Cost not allowed' ;
                           pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                       END IF;
                  ELSIF p_context = 'WEBADI' THEN
                       IF l_debug_mode='Y' THEN
                            pa_debug.g_err_stage:= 'WEBADI: Burd Cost not allowed';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                            pa_debug.g_err_stage:= 'Populating Error Code';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                       END IF;

                       x_webadi_error_code := 'PA_FP_WA_BURD_COST_NOT_ALWD';
                       p_return_status := FND_API.G_RET_STS_ERROR;
                       RETURN;
                  END IF;  -- Bug 3986129: FP.M Web ADI Dev changes

            END IF;

            IF l_revenue_flag = 'N'
                 AND (    p_revenue <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                 AND p_revenue IS NOT NULL )
            THEN
                  IF Nvl(p_context, '-99') <> 'WEBADI' THEN  -- Bug 3986129: FP.M Web ADI Dev changes
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                     /* Bug 3132035, Token is removed
                     */
                      PA_UTILS.ADD_MESSAGE
                          (p_app_short_name => 'PA',
                           p_msg_name       => 'PA_REVENUE_NOT_ALLOWED');

                        --RAISE FND_API.G_EXC_ERROR;
                        p_return_status := FND_API.G_RET_STS_ERROR;

                  END IF;
                  IF l_debug_mode='Y' THEN
                        pa_debug.g_err_stage:= 'All Revenue not allowed' ;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);

                  END IF;

                  --RAISE FND_API.G_EXC_ERROR;
                  p_return_status := FND_API.G_RET_STS_ERROR;
                  ELSIF p_context = 'WEBADI' THEN
                        IF l_debug_mode='Y' THEN
                            pa_debug.g_err_stage:= 'WEBADI: Revenue not allowed';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                            pa_debug.g_err_stage:= 'Populating Error Code';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                        END IF;

                       x_webadi_error_code := 'PA_FP_WA_REVENUE_NOT_ALWD';
                       p_return_status := FND_API.G_RET_STS_ERROR;
                       RETURN;
                  END IF;  -- Bug 3986129: FP.M Web ADI Dev changes
            END IF;

      ELSE

            IF l_debug_mode='Y' THEN
                  pa_debug.g_err_stage:= 'p_budget_amount_code passed is ' || p_budget_amount_code ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level5);

                  pa_debug.g_err_stage:= 'p_version_type passed is ' || p_version_type ;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level5);

            END IF;

            PA_UTILS.ADD_MESSAGE
                  (p_app_short_name => 'PA',
                   p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
            p_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;


      END IF;--IF ( p_budget_amount_code = 'C'

      -- Bug 3986129: FP.M Web ADI Dev changes
      IF p_context = 'WEBADI' THEN
              IF p_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_COST THEN
                     IF l_raw_cost_rate_flag = 'N' THEN
                         IF p_raw_cost_rate <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                            p_raw_cost_rate IS NOT NULL THEN
                                IF l_debug_mode='Y' THEN
                                   pa_debug.g_err_stage:= 'WEBADI: Raw Cost Rate allowed';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                   pa_debug.g_err_stage:= 'Populating Error Code';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                 END IF;

                                 x_webadi_error_code := 'PA_FP_WA_RCR_CNG_NOT_ALWD';
                                 p_return_status := FND_API.G_RET_STS_ERROR;
                                 RETURN;
                         END IF;
                     END IF;
                     IF l_burd_cost_rate_flag = 'N' THEN
                         IF p_burdened_cost_rate <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                            p_burdened_cost_rate IS NOT NULL THEN
                                 IF l_debug_mode='Y' THEN
                                   pa_debug.g_err_stage:= 'WEBADI: Burd Cost Rate not allowed';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                   pa_debug.g_err_stage:= 'Populating Error Code';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                 END IF;

                                 x_webadi_error_code := 'PA_FP_WA_BCR_CNG_NOT_ALWD';
                                 p_return_status := FND_API.G_RET_STS_ERROR;
                                 RETURN;
                         END IF;
                     END IF;
                     -- bill rate should not be allowed to be edited
                     IF p_bill_rate <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                        p_bill_rate IS NOT NULL THEN
                                 IF l_debug_mode='Y' THEN
                                   pa_debug.g_err_stage:= 'WEBADI: Bill Rate not allowed';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                   pa_debug.g_err_stage:= 'Populating Error Code';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                 END IF;

                                 x_webadi_error_code := 'PA_FP_WA_BR_CNG_NOT_ALWD';
                                 p_return_status := FND_API.G_RET_STS_ERROR;
                                 RETURN;
                     END IF;


              ELSIF p_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_REVENUE THEN
                     IF l_bill_rate_flag = 'N' THEN
                         IF p_bill_rate <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                            p_bill_rate IS NOT NULL THEN
                                 IF l_debug_mode='Y' THEN
                                   pa_debug.g_err_stage:= 'WEBADI: Bill Rate not allowed';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                   pa_debug.g_err_stage:= 'Populating Error Code';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                 END IF;

                                 x_webadi_error_code := 'PA_FP_WA_BR_CNG_NOT_ALWD';
                                 p_return_status := FND_API.G_RET_STS_ERROR;
                                 RETURN;
                         END IF;
                     END IF;
                     -- cost rate should not be allowed to be edited
                     IF p_raw_cost_rate <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                        p_raw_cost_rate IS NOT NULL THEN
                                 IF l_debug_mode='Y' THEN
                                   pa_debug.g_err_stage:= 'WEBADI: Raw Cost Rate allowed';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                   pa_debug.g_err_stage:= 'Populating Error Code';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                 END IF;

                                 x_webadi_error_code := 'PA_FP_WA_RCR_CNG_NOT_ALWD';
                                 p_return_status := FND_API.G_RET_STS_ERROR;
                                 RETURN;
                     END IF;
                     IF p_burdened_cost_rate <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                        p_burdened_cost_rate IS NOT NULL THEN
                                 IF l_debug_mode='Y' THEN
                                   pa_debug.g_err_stage:= 'WEBADI: Burd Cost Rate not allowed';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                   pa_debug.g_err_stage:= 'Populating Error Code';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                 END IF;

                                 x_webadi_error_code := 'PA_FP_WA_BCR_CNG_NOT_ALWD';
                                 p_return_status := FND_API.G_RET_STS_ERROR;
                                 RETURN;
                     END IF;
              ELSIF p_version_type = PA_FP_CONSTANTS_PKG.G_ELEMENT_TYPE_ALL THEN
                     IF l_raw_cost_rate_flag = 'N' THEN
                         IF p_raw_cost_rate <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                            p_raw_cost_rate IS NOT NULL THEN
                                 IF l_debug_mode='Y' THEN
                                   pa_debug.g_err_stage:= 'WEBADI: Raw Cost Rate allowed';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                   pa_debug.g_err_stage:= 'Populating Error Code';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                 END IF;

                                 x_webadi_error_code := 'PA_FP_WA_RCR_CNG_NOT_ALWD';
                                 p_return_status := FND_API.G_RET_STS_ERROR;
                                 RETURN;
                         END IF;
                     END IF;
                     IF l_burd_cost_rate_flag = 'N' THEN
                         IF p_burdened_cost_rate <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                            p_burdened_cost_rate IS NOT NULL THEN
                                 IF l_debug_mode='Y' THEN
                                   pa_debug.g_err_stage:= 'WEBADI: Burd Cost Rate not allowed';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                   pa_debug.g_err_stage:= 'Populating Error Code';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                 END IF;

                                 x_webadi_error_code := 'PA_FP_WA_BCR_CNG_NOT_ALWD';
                                 p_return_status := FND_API.G_RET_STS_ERROR;
                                 RETURN;
                         END IF;
                     END IF;
                     IF l_bill_rate_flag = 'N' THEN
                         IF p_bill_rate <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
                            p_bill_rate IS NOT NULL THEN
                                 IF l_debug_mode='Y' THEN
                                   pa_debug.g_err_stage:= 'WEBADI: Bill Rate not allowed';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                   pa_debug.g_err_stage:= 'Populating Error Code';
                                   pa_debug.write(l_module_name,pa_debug.g_err_stage, l_debug_level3);
                                 END IF;

                                 x_webadi_error_code := 'PA_FP_WA_BR_CNG_NOT_ALWD';
                                 p_return_status := FND_API.G_RET_STS_ERROR;
                                 RETURN;
                         END IF;
                     END IF;
              END IF;
      END IF;

	IF l_debug_mode = 'Y' THEN
	      pa_debug.reset_curr_function;
	END IF;
EXCEPTION


      WHEN FND_API.G_EXC_ERROR
      THEN

            ROLLBACK TO check_entry_method_flags_pvt;

            p_return_status := FND_API.G_RET_STS_ERROR;
	IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
	END IF;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      THEN

            ROLLBACK TO check_entry_method_flags_pvt;

            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
	END IF;
      WHEN OTHERS THEN

            ROLLBACK TO check_entry_method_flags_pvt;

            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
              FND_MSG_PUB.add_exc_msg
              (  p_pkg_name       => G_PKG_NAME
              ,  p_procedure_name => l_api_name );

            END IF;
	IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
	END IF;
END check_entry_method_flags_Pvt;

-- Bug 3986129: FP.M Web ADI Dev changes, new api

/* This api would be called to validate the UOM passed for the resource alias for
 * WEBADI context to check, if the passed value corresponds to the UOM defined
 * for the resource list member and is called from pa_budget_pvt.validate_budget_lines.
 * if the validation succeeds, x_error_code would be returned as null
 */
PROCEDURE validate_uom_passed
( p_context                IN        VARCHAR2,
  p_res_list_mem_id        IN        pa_resource_list_members.resource_list_member_id%TYPE,
  p_uom_passed             IN        pa_resource_list_members.unit_of_measure%TYPE,
  x_error_code             OUT       NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_return_status          OUT       NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_data               OUT       NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT       NOCOPY NUMBER) --File.Sql.39 bug 4440895

  IS
      l_return_status                   VARCHAR2(1);
      l_msg_data                        VARCHAR2(2000);
      l_msg_count                       NUMBER;

      l_debug_mode                      VARCHAR2(1);
      l_module_name                     VARCHAR2(100) := 'PA_BUDGET_CHECK_PVT.validate_uom_passed';
      l_debug_level3                    CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3;
      l_debug_level5                    CONSTANT NUMBER := PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5;
      l_msg_index_out                   NUMBER;
      l_data                            VARCHAR2(2000);

      l_unit_of_measure                pa_resource_list_members.unit_of_measure%TYPE;

  BEGIN
        fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
        x_msg_count := 0;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF l_debug_mode = 'Y' THEN
            PA_DEBUG.Set_Curr_Function( p_function   => l_module_name,
                                        p_debug_mode => l_debug_mode );
        END IF;
        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Entering into PA_BUDGET_CHECK_PVT.validate_uom_passed';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            pa_debug.g_err_stage := 'validating input parameters';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;

        -- validating input parameters
        IF p_res_list_mem_id IS NULL THEN
              IF l_debug_mode = 'Y' THEN
                   pa_debug.g_err_stage := 'Required input param is null';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              END IF;
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
              RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END IF;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Checking the UOM passed';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;
        -- using the singular select here as no api exists only for this
        BEGIN
               SELECT unit_of_measure
               INTO   l_unit_of_measure
               FROM   pa_resource_list_members
               WHERE  resource_list_member_id = p_res_list_mem_id;
        EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    IF l_debug_mode = 'Y' THEN
                        pa_debug.g_err_stage := 'No values obtained from the select';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                    END IF;
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                         p_msg_name       => 'PA_FP_INV_PARAM_PASSED');
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        END;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'UOM fetched from DB: ' || l_unit_of_measure;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;
        IF Nvl(p_uom_passed, l_unit_of_measure) <> l_unit_of_measure THEN
                 x_error_code := 'FP_WEBADI_INVALID_UOM_PASSED';

                 IF l_debug_mode = 'Y' THEN
                     pa_debug.reset_curr_function;
                 END IF;
                 RETURN;
        END IF;

        IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage := 'Leaving PA_BUDGET_CHECK_PVT.validate_uom_passed';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        END IF;
        IF l_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
        END IF;

  EXCEPTION
        WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
          l_msg_count := FND_MSG_PUB.count_msg;

          IF l_msg_count = 1 and x_msg_data IS NULL THEN
               PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => l_msg_count
                      ,p_msg_data       => l_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
               x_msg_count := l_msg_count;
          ELSE
              x_msg_count := l_msg_count;
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;

          IF l_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
          END IF;
          RETURN;

     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;

          FND_MSG_PUB.add_exc_msg( p_pkg_name      => 'PA_BUDGET_CHECK_PVT'
                                  ,p_procedure_name  => 'validate_uom_passed');
          IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage:='Unexpected Error ' || SQLERRM;
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;

          IF l_debug_mode = 'Y' THEN
              pa_debug.reset_curr_function;
          END IF;
          RAISE;
  END validate_uom_passed;
--------------------------------------------------------------------------------
end PA_BUDGET_CHECK_PVT;

/
