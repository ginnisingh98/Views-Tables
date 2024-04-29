--------------------------------------------------------
--  DDL for Package Body PA_PROJ_ACCUM_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_ACCUM_MAIN" AS
/* $Header: PARESMNB.pls 120.7.12010000.5 2010/03/17 08:48:20 jsundara ship $ */

   x_run_id  NUMBER;
   x_status  NUMBER;
   x_stage  NUMBER;

   -- Local function. Checks that the project number specified by
   -- the user is of valid project type if one specified.
   --

FUNCTION check_valid_project(p_proj_num  VARCHAR2, p_project_type VARCHAR2) RETURN NUMBER IS
     x_return   VARCHAR2(1);

   BEGIN

     SELECT 'X'
       INTO  x_return
       FROM  pa_projects proj
      WHERE  proj.project_type = p_project_type
        AND  proj.segment1     = p_proj_num;

     IF x_return IS NULL THEN
        RETURN 0;
     ELSE
        RETURN 1;
     END IF;

   /* Added for Bug 2628197 */
   EXCEPTION
     WHEN OTHERS THEN
       RETURN 0;

   END check_valid_project;

   --
   -- Local procedure.  Use the MIN and MAX values of the project number
   -- if the user did not specify the range when submitting the report
   --
/* Modified for bug 2543021.
   PROCEDURE Get_Project_Num_Range (
                 p_proj_num_from        IN      VARCHAR2,
                 p_proj_num_to          IN      VARCHAR2,
                 p_proj_num_from_out    OUT     VARCHAR2,
                 p_proj_num_to_out      OUT     VARCHAR2 ) IS

  BEGIN

    IF (p_proj_num_from IS NULL) OR
       (p_proj_num_to IS NULL) THEN

     SELECT min(segment1), max(segment1)
       INTO p_proj_num_from_out,
            p_proj_num_to_out
       FROM pa_projects;

    END IF;

    IF (p_proj_num_from IS NOT NULL) THEN
      p_proj_num_from_out := p_proj_num_from;
    END IF;

    IF (p_proj_num_to IS NOT NULL) THEN
      p_proj_num_to_out := p_proj_num_to;
    END IF;

  END Get_Project_Num_Range;
*/

   PROCEDURE Get_Project_Num_Range (
                 p_proj_num_from        IN      VARCHAR2,
                 p_proj_num_to          IN      VARCHAR2,
                 p_proj_num_from_out    OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 p_proj_num_to_out      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	         p_proj_type            IN      VARCHAR2 ) IS

  p_proj_num_from_temp pa_projects.segment1%TYPE;

  BEGIN

    IF (p_proj_num_from IS NULL) OR
       (p_proj_num_to IS NULL) THEN

     SELECT MIN(segment1), MAX(segment1)
       INTO p_proj_num_from_out,
            p_proj_num_to_out
       FROM pa_projects
      WHERE project_type = NVL(p_proj_type, project_type);

    END IF;

   IF p_proj_type IS NULL THEN -- project_type is not specified

    IF (p_proj_num_from IS NOT NULL) THEN
      p_proj_num_from_out := p_proj_num_from;
    END IF;

    IF (p_proj_num_to IS NOT NULL) THEN
      p_proj_num_to_out := p_proj_num_to;
    END IF;

   ELSE -- project_type is specified

    IF (p_proj_num_from IS NOT NULL AND p_proj_num_to IS NULL) THEN

     -- Check if the from project number is of the project_type specified
				 IF check_valid_project(p_proj_num_from,p_proj_type) = 1 THEN
        p_proj_num_from_out := p_proj_num_from;
					ELSE
  					SELECT  MIN(segment1)
							  INTO  p_proj_num_from_temp
         FROM  pa_projects
       	WHERE  project_type  = p_proj_type
       			AND  segment1 BETWEEN p_proj_num_from AND p_proj_num_to_out;
					END IF;
    END IF;

    IF (p_proj_num_to IS NOT NULL AND p_proj_num_from IS NULL) THEN

     -- Check if the To project number is of the project_type specified
				 IF check_valid_project(p_proj_num_to,p_proj_type) = 1 THEN
        p_proj_num_to_out := p_proj_num_to;
					ELSE
  					SELECT  MAX(segment1)
							  INTO  p_proj_num_to_out
         FROM  pa_projects
       	WHERE  project_type  = p_proj_type
       			AND  segment1 BETWEEN p_proj_num_from_out AND p_proj_num_to;
					END IF;
				END IF;

    IF (p_proj_num_to IS NOT NULL AND p_proj_num_from IS NOT NULL) THEN

     -- Check if the from project number is of the project_type specified
				 IF check_valid_project(p_proj_num_from,p_proj_type) = 1 THEN
        p_proj_num_from_out := p_proj_num_from;
					ELSE
  					SELECT  MIN(segment1)
							  INTO  p_proj_num_from_out
         FROM  pa_projects
       	WHERE  project_type  = p_proj_type;
					END IF;

     -- Check if the To project number is of the project_type specified
				 IF check_valid_project(p_proj_num_to,p_proj_type) = 1 THEN
        p_proj_num_to_out := p_proj_num_to;
					ELSE
  					SELECT  MAX(segment1)
							  INTO  p_proj_num_to_out
         FROM  pa_projects
       	WHERE  project_type  = p_proj_type;
					END IF;

    END IF;

				IF p_proj_num_from_temp IS NOT NULL THEN
				   p_proj_num_from_out := p_proj_num_from_temp;
				END IF;
		END IF;

  END Get_Project_Num_Range;


   -- Initialize PROCEDURE
   -- This procedure initializes global variables for all projects
   -- Added following 3 new variables for Burden Cost Accounting
   --
   -- History
   --
   --    31-JUL-03   jwhite       For patchset 'L' Reburdening Enhancement, added this
   --                             IN-parm to the accum_cdls procedure:
   --                               x_cdl_line_type VARCHAR2
   --                             Also, added FND_PROFILE.value call to Initialization
   --                             procedure for conditional processing:
   --                             Pa_Proj_Accum_Main.G_PA_Enhanced_Burdening
   --
   --   01-JUL-04   sacgupta      Added call to new procedure get_pa_period_info1
   --                             This procedure initilaize global variables whose
   --                             values are same for all the projects
   --

   PROCEDURE initialize

   IS
   P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

   BEGIN

     x_old_stack := x_err_stack;
     x_err_stack := x_err_stack ||'->pa_proj_accum_main.initialize';
     x_err_code  := 0;
     x_err_stage := 'Summary Accumulation Initialization Procedure';

     -- This procedure initialize the variables for all projects
     -- get the implementation option and accumulation period information

     -- Get the Accumulation type from PA_IMPLEMENTATIONS
     -- whether Accumulate by PA_PERIOD or GL_PERIOD
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     Pa_Debug.debug(x_err_stack);
     END IF;

     --- Getting the commit size--------------
     IF Fnd_Profile.value('PA_NUM_EXP_ITEMS_PER_SET') IS NOT NULL THEN
         Pa_Proj_Accum_Main.x_commit_size := Fnd_Profile.value('PA_NUM_EXP_ITEMS_PER_SET');
     ELSE
         Pa_Proj_Accum_Main.x_commit_size := 500;
     END IF;

     Pa_Accum_Utils.get_impl_option
                             (x_impl_option,
                              x_err_stack,
                              x_err_stage,
                              x_err_code);
     -- Setting the package variables and global variables so that
     -- the values can be cached - Performance Phase II changes 594289

     Pa_Utils.Set_business_group_id ;
     Pa_Currency.Set_currency_info ;


     -- Get the information pertaining to the Current PA PERIOD

     Pa_Accum_Utils.get_current_period_info
                      (x_current_pa_period,
                       x_current_gl_period,
                       x_current_pa_start_date,
                       x_current_pa_end_date,
                       x_current_gl_start_date,
                       x_current_gl_end_date,
                       x_current_year,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);
     -- Caching  pa_period and gl_period names,
     -- to be used in the view pa_commitment_txns_v

     Pa_Accum_Utils.g_current_pa_period := x_current_pa_period ;
     Pa_Accum_Utils.g_current_gl_period := x_current_gl_period ;

     -- Getting current period year's start and end dates

     Pa_Accum_Utils.Get_period_year_Info
                (x_current_gl_period,
                 x_period_yr_start_date,
                 x_err_stack,
                 x_err_stage,
                 x_err_code );

     IF x_impl_option = 'PA' THEN
        x_period_yr_end_date := x_current_pa_end_date;
     END IF;

     IF x_impl_option = 'GL' THEN
        x_period_yr_end_date := x_current_gl_end_date;
     END IF;

-- Start for performance bug 3653978

     Pa_Accum_Utils.get_pa_period_info1
                          (x_impl_option,
                           x_current_pa_start_date,
                           x_current_gl_start_date,
                           x_prev_pa_period,
                           x_prev_gl_period,
                           x_prev_pa_year,
                           x_prev_gl_year,
                           x_prev_pa_start_date,
                           x_prev_pa_end_date,
                           x_prev_gl_start_date,
                           x_prev_gl_end_date,
                           x_err_stack,
                           x_err_stage,
                           x_err_code);

     -- Set the current period info based on implementation option

     IF x_impl_option = 'PA' THEN
           x_Current_period          := x_current_pa_period;
           x_Prev_period             := x_prev_pa_period;
           x_current_start_date      := x_current_pa_start_date;
           x_current_end_date        := x_current_pa_end_date;
           x_prev_start_date         := x_prev_pa_start_date;
           x_prev_end_date           := x_prev_pa_end_date;
           x_prev_year               := x_prev_pa_year;
     ELSIF x_impl_option = 'GL' THEN
           x_Current_period          := x_current_gl_period;
           x_Prev_period             := x_prev_gl_period;
           x_current_start_date      := x_current_gl_start_date;
           x_current_end_date        := x_current_gl_end_date;
           x_prev_start_date         := x_prev_gl_start_date;
           x_prev_end_date           := x_prev_gl_end_date;
           x_prev_year               := x_prev_gl_year;
     END IF;

-- End  for performance bug 3653978

     -- 05-AUG-2003, jwhite: For patchset 'L' Reburdening Enhancement
     -- This profile value is initialized to 'N' in the package spec.
     -- This profile is used to conditionally execute the accum_clds procedure
     -- for incremental burden rows.


     --Pa_Proj_Accum_Main.G_PA_Enhanced_Burdening := NVL(FND_PROFILE.value('PA_ENHANCED_BURDENING'), 'N');
     Pa_Proj_Accum_Main.G_PA_Enhanced_Burdening := pa_utils2.IsEnhancedBurdeningEnabled;  /*4278940 */

    IF ( P_DEBUG_MODE = 'Y' )
       THEN
         Pa_Debug.debug('proj_accum, Initialize: G_PA_Enhanced_Burdening - '|| Pa_Proj_Accum_Main.G_PA_Enhanced_Burdening );
    END IF;


     -- --------------------------------------------------------------------------


     -- # of records processed

     x_recs_processed := 0;

     x_err_stack := x_old_stack;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END initialize;

   -- This procedure initialize the variables for each project

   PROCEDURE initialize_project (x_project_id  IN  NUMBER,
                                 x_accum_period_type_changed OUT NOCOPY BOOLEAN) --File.Sql.39 bug 4440895
   IS
     P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
     l_accum_period_type_changed BOOLEAN;


   BEGIN

     x_old_stack := x_err_stack;
     x_err_stack := x_err_stack ||'->pa_proj_accum_main.initialize_project';
     x_err_code  := 0;
     x_err_stage :=
     'Summary Accumulation Initialization Procedure for Project_id= ' || x_project_id;

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        Pa_Debug.debug('initialize_project: ' || x_err_stack);
     END IF;

/* Commented for performance bug 3653978
     -- Initialize the global variables before use for each project

     x_prev_accum_period      := NULL;
     x_current_period         := NULL;
     x_prev_period            := NULL;
     x_prev_pa_period         := NULL;
     x_prev_gl_period         := NULL;

     x_proj_level_accum_id    := 0;
     x_prev_year              := 0;
     x_prev_pa_year           := 0;
     x_prev_gl_year           := 0;
     x_prev_accum_year        := 0;

     x_current_start_date     := NULL;
     x_current_end_date       := NULL;
     x_prev_start_date        := NULL;
     x_prev_end_date          := NULL;
     x_prev_pa_start_date     := NULL;
     x_prev_pa_end_date       := NULL;
     x_prev_gl_start_date     := NULL;
     x_prev_gl_end_date       := NULL;
     x_prev_accum_start_date  := NULL;
     x_prev_accum_end_date    := NULL;
     x_prev_prev_accum_period := NULL;

*/
     --  Added for performance bug 3653978
     -- Initialize the global variables before use for each project
     x_prev_accum_period      := NULL;

     x_proj_level_accum_id    := 0;

     -- Create/Get the Project level header record for this project

     Pa_Accum_Utils.proj_level_record
                          (x_project_id,
                           x_current_pa_period,
                           x_current_gl_period,
                           x_impl_option,
                           x_proj_level_accum_id,
                           x_prev_accum_period,
                           x_err_stack,
                           x_err_stage,
                           x_err_code);

     -- Get the other details from PA_PERIOD
     -- (PREVIOUS period,previously accumulated period etc )

/* Commented out as part of performance fix 3653978
     Pa_Accum_Utils.get_pa_period_info
                          (x_impl_option,
                           x_prev_accum_period,
                           x_current_pa_period,
                           x_current_gl_period ,
                           x_current_pa_start_date,
                           x_current_pa_end_date,
                           x_current_gl_start_date,
                           x_current_gl_end_date,
                           x_prev_pa_period,
                           x_prev_gl_period,
                           x_prev_pa_year,
                           x_prev_gl_year,
                           x_prev_accum_year,
                           x_prev_pa_start_date,
                           x_prev_pa_end_date,
                           x_prev_gl_start_date,
                           x_prev_gl_end_date,
                           x_prev_accum_start_date,
                           x_prev_accum_end_date,
                           x_prev_prev_accum_period,
                           l_accum_period_type_changed,
                           x_err_stack,
                           x_err_stage,
                           x_err_code);

     x_accum_period_type_changed := l_accum_period_type_changed;

     -- Set the current period info based on implementation option

     IF x_impl_option = 'PA' THEN
           x_Current_period          := x_current_pa_period;
           x_Prev_period             := x_prev_pa_period;
           x_current_start_date      := x_current_pa_start_date;
           x_current_end_date        := x_current_pa_end_date;
           x_prev_start_date         := x_prev_pa_start_date;
           x_prev_end_date           := x_prev_pa_end_date;
           x_prev_year               := x_prev_pa_year;
     ELSIF x_impl_option = 'GL' THEN
           x_Current_period          := x_current_gl_period;
           x_Prev_period             := x_prev_gl_period;
           x_current_start_date      := x_current_gl_start_date;
           x_current_end_date        := x_current_gl_end_date;
           x_prev_start_date         := x_prev_gl_start_date;
           x_prev_end_date           := x_prev_gl_end_date;
           x_prev_year               := x_prev_gl_year;
     END IF;
*/

    -- Added for performance bug 3653978.
    -- If the project had been previously accumulated, then get the details
    -- pertaining to the previously accumulated period

    If x_prev_accum_period is not Null Then
      If PA_PROJ_ACCUM_MAIN.x_prev_accum_period1 is null or
         PA_PROJ_ACCUM_MAIN.x_prev_accum_period1 <> x_prev_accum_period Then

         PA_PROJ_ACCUM_MAIN.x_prev_accum_period1 := x_prev_accum_period;

      -- Initialize the global variables before use for each project
      x_prev_accum_year        := 0;

      x_prev_accum_start_date  := NULL;
      x_prev_accum_end_date    := NULL;
      x_prev_prev_accum_period := NULL;

      Pa_Accum_Utils.get_pa_period_info2
                           (x_impl_option,
                            x_prev_accum_period,
                            x_prev_accum_year,
                            x_prev_accum_start_date,
                            x_prev_accum_end_date,
                            x_prev_prev_accum_period,
                            l_accum_period_type_changed,
                            x_err_stack,
                            x_err_stage,
                            x_err_code);

       x_accum_period_type_changed := l_accum_period_type_changed;
    End If;
  End If;

--  End of changes for performance bug 3653978

     x_err_stack := x_old_stack;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END initialize_project;

   PROCEDURE check_reporting_period
             (status        IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              x_err_stack   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              x_err_stage   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
              x_err_code    IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
   IS
   P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */

   BEGIN

     x_old_stack := x_err_stack;
     x_err_stack := x_err_stack ||'->pa_proj_accum_main.check_reporting_period';
     x_err_code  := 0;
     x_err_stage := 'Checking If Reporting Period Moved Backwards in Time';

     -- This procedure checks if the reporting period was moved
     -- backwards in time during the process run

     -- if the period did moved backward, then we will abort the process
     -- If the period was moved forward, it is OK

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        Pa_Debug.debug('check_reporting_period: ' || x_err_stack);
     END IF;

     -- Get the information pertaining to the Current PA PERIOD

     Pa_Accum_Utils.get_current_period_info
                      (x_new_current_pa_period,
                       x_new_current_gl_period,
                       x_new_current_pa_start_date,
                       x_new_current_pa_end_date,
                       x_new_current_gl_start_date,
                       x_new_current_gl_end_date,
                       x_new_current_year,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);

     IF x_impl_option = 'PA' THEN
       IF (x_new_current_pa_end_date < x_current_pa_end_date) THEN
        -- Yes, Reporting period was moved backwards
         status := 'Y';
       ELSE
         status := 'N';
       END IF;
     ELSIF x_impl_option = 'GL' THEN
       IF (x_new_current_gl_end_date < x_current_gl_end_date) THEN
        -- Yes, Reporting period was moved backwards
         status := 'Y';
       ELSE
         status := 'N';
       END IF;
     END IF;

     x_err_stack := x_old_stack;

   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RAISE;
   END check_reporting_period;

  --   project_num_from  : start project # : mandatory
  --   project_num_to    : end   project # : mandatory
  --   actual_cost_flag  : 'Y' or 'N'      : mandatory
  --   revenue_flag      : 'Y' or 'N'      : mandatory
  --   system_linkage_function  : system_linkage_function : optional
  --   budgets_flag      : 'Y' or 'N'      : mandatory
  --   budget_type_code  : Budget Type Code: optional
  --   commitments_flag  : 'Y' or 'N'      : mandatory
  --   mode              : 'I' for incremental : mandatory

  FUNCTION action_exists
        (x_action_flag  IN VARCHAR2,
         x_actions_in   IN action_tbl_type,
         x_actions_cnt  IN BINARY_INTEGER)
  RETURN        VARCHAR2
  IS
        valid_flag      VARCHAR2(1) := 'N' ;
  BEGIN

        FOR cnt_action IN 1 .. x_actions_cnt LOOP

            IF x_actions_in(cnt_action).action_flag = x_action_flag THEN
               valid_flag := 'Y' ;
            END IF ;

        END LOOP ;

        RETURN  valid_flag ;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        valid_flag := 'N' ;
        RETURN valid_flag ;
     WHEN OTHERS THEN
        x_err_code := SQLCODE;
        RAISE;
  END action_exists ;

  FUNCTION check_period_flags
         (x_project_id  IN NUMBER,
          x_impl_option IN VARCHAR2,
          x_current_end_date IN DATE,
          x_action_flag IN VARCHAR2,
          x_closed_date IN DATE,
          x_current_start_date IN DATE)
  RETURN          VARCHAR2
  IS

        x_ret_flag VARCHAR2(1) := 'N' ;
        l_prev_accum_period     VARCHAR2(20) ;
        l_prev_accum_end_date   DATE ;
        l_prev_year             NUMBER ;

  BEGIN

        SELECT  DISTINCT accum_period
        INTO    l_prev_accum_period
        FROM    pa_project_accum_headers
        WHERE   project_id = x_project_id
        AND     Task_id    = 0
        AND     Resource_List_member_id = 0 ;

        IF l_prev_accum_period IS NOT NULL THEN
        -- project previously not accumulated

        BEGIN

                IF x_action_flag = 'BK' OR x_action_flag = 'PR' THEN

                -- Check for Period Moved Backwards (BK) or Forwards (PR)

                   IF x_impl_option = 'PA' THEN

                        BEGIN
                                SELECT  end_date
                                INTO    l_prev_accum_end_date
                                FROM    pa_periods
                                WHERE   period_name = l_prev_accum_period ;
                        EXCEPTION
                                WHEN OTHERS THEN
                                   x_ret_flag := 'N' ;
                                   RETURN x_ret_flag ;
                        END ;

                   ELSIF x_impl_option = 'GL' THEN

                        BEGIN
                          SELECT  DISTINCT gl_end_date
                          INTO    l_prev_accum_end_date
                          FROM    pa_periods_v
                          WHERE   gl_period_name = l_prev_accum_period ;
                        EXCEPTION
                          WHEN OTHERS THEN
                               x_ret_flag := 'N' ;
                               RETURN x_ret_flag ;
                        END ;

                   END IF ;

                   IF x_action_flag = 'BK' THEN

                      IF( TRUNC(l_prev_accum_end_date) >
                          TRUNC(x_current_end_date) ) THEN
                          x_ret_flag := 'Y' ;
                      END IF ;

                   END IF;

                   IF x_action_flag = 'PR' THEN

                      IF( TRUNC(l_prev_accum_end_date) <
                          TRUNC(x_current_end_date) ) THEN
                          x_ret_flag := 'Y';
                      END IF;

                   END IF ;

                END IF ;

                IF x_action_flag = 'PT' THEN
                --  Check for Period Type Change (PT)

                   IF x_impl_option = 'PA' THEN

                        BEGIN
                                SELECT  'N'
                                INTO    x_ret_flag
                                FROM    dual
                                WHERE   EXISTS (SELECT  'x'
                                                FROM    pa_periods
                                                WHERE   period_name =
                                                l_prev_accum_period) ;
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                   x_ret_flag := 'Y' ;
                                   RETURN x_ret_flag ;
                                WHEN OTHERS THEN
                                   x_ret_flag := 'N' ;
                                   RETURN x_ret_flag ;
                        END ;

                   ELSIF x_impl_option = 'GL' THEN

                        BEGIN
                                SELECT  'N'
                                INTO    x_ret_flag
                                FROM    dual
                                WHERE   EXISTS (SELECT  'x'
                                                FROM    pa_periods_v
                                                WHERE   gl_period_name =
                                                l_prev_accum_period) ;
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                   x_ret_flag := 'Y' ;
                                   RETURN x_ret_flag ;
                                WHEN OTHERS THEN
                                   x_ret_flag := 'N' ;
                                   RETURN x_ret_flag ;
                        END ;

                   END IF ;

                END IF ;

                IF x_action_flag = 'CL' THEN
                -- Check for Closed Projects (CL)

                         IF (x_closed_date IS NOT NULL)
                            AND ( Pa_Proj_Accum_Main.x_period_yr_start_date IS NOT NULL)
                            AND ( TRUNC(x_closed_date) <
                            TRUNC(Pa_Proj_Accum_Main.x_period_yr_start_date)) THEN
                            x_ret_flag := 'Y' ;

                         END IF ;

                END IF ;
        END ;

        END IF ;

        RETURN x_ret_flag ;

  EXCEPTION
        WHEN NO_DATA_FOUND THEN
             x_ret_flag := 'N' ;
             RETURN x_ret_flag ;
        WHEN OTHERS THEN
             x_ret_flag := 'N' ;
             RETURN x_ret_flag ;

  END check_period_flags ;

  PROCEDURE proj_accum
                        ( errbuf                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          retcode                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_project_num_from        IN  VARCHAR2,
                          x_project_num_to          IN  VARCHAR2,
                          x_end_date_through        IN  DATE,
                          x_mode                    IN  VARCHAR2,
                          x_actual_cost_flag        IN  VARCHAR2,
                          x_system_linkage_function IN  VARCHAR2,
                          x_revenue_flag            IN  VARCHAR2,
                          x_budgets_flag            IN  VARCHAR2,
                          x_budget_type_code        IN  VARCHAR2,
                          x_commitments_flag        IN  VARCHAR2,
                          x_grouping_id             IN  NUMBER,
                          x_summ_context            IN  VARCHAR2,
                          x_delete_temp_table       IN  VARCHAR2,
                          x_project_type            IN  VARCHAR2 -- for bug 2543021
                        )
  IS

   /* Added Debug Profile Option  variable initialization for bug#2674619 */
    P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');



    x_log_summ_mode      VARCHAR2(1) := 'N';

    x_CdlStart           DATE := NULL; /* Start time for accum_cdls          */
    x_CdlEnd             DATE := NULL; /* End   time for accum_cdls          */
    x_RdlStart           DATE := NULL; /* Start time for accum_revenue       */
    x_RdlEnd             DATE := NULL; /* End   time for accum_revenue       */
    x_CmtcrStart         DATE := NULL; /* Start time for create_commitments  */
    x_CmtcrEnd           DATE := NULL; /* End   time for create_commitments  */
    x_CmtaccStart        DATE := NULL; /* Start time for accum_commitments   */
    x_CmtaccEnd          DATE := NULL; /* End   time for accum_commitments   */
    x_InitStart          DATE := NULL; /* Start time for Initialize  */
    x_InitEnd            DATE := NULL; /* End   time for Initialize  */
    x_BudStart           DATE := NULL; /* Start time for process_budget_txns */
    x_BudEnd             DATE := NULL; /* End   time for process_budget_txns */

    x_MapTxnStart        DATE := NULL; /* Start time for Map Txns          */
    x_MapTxnEnd          DATE := NULL; /* End time for Map Txns            */
    x_PrcCmtStart        DATE := NULL; /* Start time process_txn_accum_cmt */
    x_PrcCmtEnd          DATE := NULL; /* End time process_txn_accum_cmt   */
    x_PrcTxnStart        DATE := NULL; /* Start time for process_txn_accum */
    x_PrcTxnEnd          DATE := NULL; /* End time for process_txn_accum   */
    x_PrjSumStart        DATE := NULL; /* Start time for Project Summary   */
    x_PrjSumEnd          DATE := NULL; /* End   time for Project Summary   */

    x_InsertStart        DATE := NULL; /* Start time for Insert onto       */
                                       /* pa_projects_for_accum table      */
    x_InsertEnd          DATE := NULL; /* End time for Insert onto         */
                                       /* pa_projects_for_accum table      */

    l_accum_period_type_changed BOOLEAN;
    l_project_num_from          VARCHAR2(25);
    l_project_num_to            VARCHAR2(25);
    l_current_start_date        DATE ;
    l_current_end_date          DATE ;
    l_project_id                NUMBER ;
    l_segment1                  VARCHAR2(25);
    l_sum_exception_code        pa_project_accum_headers.sum_exception_code%TYPE := NULL;
    l_invalid_proj_cnt          NUMBER := 0;
    tmp_bud_type_code           VARCHAR2(30);
    x_actions_in                action_tbl_type ;
    x_actions_cnt               BINARY_INTEGER ;
    table_index                 BINARY_INTEGER;
    accumlation_period_changed  BOOLEAN;

    -- Declare cursor for Projects

    -- CS is for existance of unaccumulated cdls for that project
    -- RV is for existance of unaccumulated rdls for the project
    -- CM is for existance of unaccumulated commitments
    -- BD is for existance of unaccumulated budgets
    -- RL is in case, the resource list associated with the
    --                project has changed
    -- TR is in case tasks have been restructured for that project
    -- CL is for closed projects which have not been accumulated before
    -- BK is when the current reporting period is moved backwards
    -- PT is when the accumulation period type has changed,
    --       since the previous accumulation
    -- PR is when the current reporting period is moved forward.
    -- TX is when unaccumulated transactions (cdls and rdls)
    --                exist in pa_txn_accum
    -- TM is when unaccumulated commitments exist in pa_txn_accum

    CURSOR      all_projs IS
    SELECT      DISTINCT pfa.project_id, pfa.segment1
    FROM        pa_projects_for_accum pfa
    WHERE       pfa.request_id = x_request_id
    AND         pfa.segment1
    BETWEEN     l_project_num_from AND l_project_num_to
    AND         pfa.action_flag IN ('CS', 'RV', 'RL', 'CM', 'BD', 'PR', 'TX', 'TM')
    AND         NOT EXISTS (SELECT      pf.project_id
                            FROM        pa_projects_for_accum pf
                            WHERE       pf.request_id = pfa.request_id
                            AND         pf.segment1 = pfa.segment1    -- Bug3653978. replaced pfa.project_id with pfa.segment1
                            AND         pf.action_flag IN
                                        ('PT', 'CL', 'BK', 'TR'));
/* Commenting out for performance bug 3653978.
    AND         EXISTS     (SELECT      pa.project_id          -- for bug 2543021
                            FROM        pa_projects pa
                            WHERE       pa.project_id = pfa.project_id
                            AND         pa.project_type  = NVL(x_project_type,project_type));
*/
/*Added for bug 5635857*/
    CURSOR      all_cm_projs IS
    SELECT      DISTINCT pfa.project_id
    FROM        pa_projects_for_accum pfa
    WHERE       pfa.request_id = x_request_id
    AND         pfa.segment1
    BETWEEN     l_project_num_from AND l_project_num_to
    AND         pfa.action_flag = 'CM'
    AND         NOT EXISTS (SELECT      pf.project_id
                            FROM        pa_projects_for_accum pf
                            WHERE       pf.request_id = pfa.request_id
                            AND         pf.segment1 = pfa.segment1    -- Bug3783746. replaced pf.project_id with pfa.segment1
                            AND         pf.action_flag IN
                                        ('PT', 'CL', 'BK', 'TR'));

    CURSOR      action_found IS
    SELECT      pfa.action_flag
    FROM        pa_projects_for_accum pfa
    WHERE       pfa.segment1 = l_segment1
    AND         pfa.request_id = x_request_id ;

    CURSOR      not_valid_proj IS
    SELECT      pfa.project_id, pfa.segment1, pfa.action_flag
    FROM        pa_projects_for_accum pfa
    WHERE       pfa.request_id  = x_request_id
    AND         pfa.action_flag IN ('PT', 'CL', 'BK', 'TR')
    ORDER       BY pfa.segment1, pfa.action_flag ;

    CURSOR      Get_all_Budget_Types_cur(l_project_id NUMBER) IS
    SELECT      DISTINCT use_code Budget_Type_Code
    FROM        pa_resource_list_uses_v
    WHERE       project_id =  l_project_id
    AND         budget_type_yn = 'Y'
    AND         use_code = NVL(Tmp_Bud_Type_Code,use_code);

    CURSOR      new_resource_list (l_project_id NUMBER) IS
    SELECT      DISTINCT resource_list_id
    FROM        pa_resource_list_assignments
    WHERE       project_id = l_project_id
    AND         NVL(resource_list_accumulated_flag,'N') = 'N';

/* Added for bug 1751445 Cause Performance */
/*Commented for perf bug #3672175 and redefined below */
   /* CURSOR      all_valid_proj IS
    SELECT      DISTINCT proj.project_id, proj.segment1
    FROM        pa_projects_for_accum_v proj
    WHERE       proj.segment1 BETWEEN l_project_num_from AND l_project_num_to
    AND         proj.project_type = NVL(x_project_type, project_type)  --for bug 2543021
    AND         NOT EXISTS (SELECT 1
                            FROM   pa_projects_for_accum proj_invalid
                            WHERE  proj_invalid.project_id = proj.project_id
                            AND    proj_invalid.action_flag IN ('PT','CL','BK','TR')
                            AND    proj_invalid.request_id+0 = x_request_id);*/
    CURSOR      all_valid_proj IS
SELECT
  proj.project_id ,
  proj.segment1 ,proj.project_type
FROM   pa_projects proj
WHERE  proj.segment1 BETWEEN pa_accum_utils.Get_project_info('F')
  AND  pa_accum_utils.Get_project_info('T')
  AND  pa_accum_utils.Get_context_info = 'REGULAR'
  AND  NVL(proj.template_flag,'N') <> 'Y'
  AND  proj.segment1 BETWEEN l_project_num_from AND l_project_num_to
  AND  proj.project_type = NVL(x_project_type, project_type)
  AND  NOT EXISTS (SELECT 1
                            FROM   pa_projects_for_accum proj_invalid
                            WHERE  proj_invalid.project_id = proj.project_id
                            AND    proj_invalid.action_flag IN ('PT','CL','BK','TR')
                            AND    proj_invalid.request_id = x_request_id)
UNION
  SELECT  proj.project_id , proj.segment1 ,proj.project_type
  FROM    pa_projects proj
  WHERE   proj.segment1 BETWEEN l_project_num_from AND l_project_num_to
  AND     EXISTS ( select 1 from pa_alloc_txn_details alloc
                        where  alloc.project_id = proj.project_id
                       AND  alloc.run_id = pa_accum_utils.Get_grouping_id)
 AND   pa_accum_utils.Get_context_info = 'AUTO_ALLOCATION'
 AND   proj.project_type = NVL(x_project_type, project_type)
 AND   NOT EXISTS (SELECT 1
                            FROM   pa_projects_for_accum proj_invalid
                            WHERE  proj_invalid.project_id = proj.project_id
                            AND    proj_invalid.action_flag IN ('PT','CL','BK','TR')
                            AND    proj_invalid.request_id = x_request_id); /*Code redefined for bug#3672175 ends here*/
    filter_proj         not_valid_proj%ROWTYPE ;
    valid_proj          all_projs%ROWTYPE ;
    valid_action        action_found%ROWTYPE ;

    budget_type_rec       Get_all_Budget_Types_cur%ROWTYPE;
    new_resource_list_rec new_resource_list%ROWTYPE;
    x_date_through        DATE;

    l_project_id_tbl      pa_plsql_datatypes.idTabTyp; /*Added for bug 5635857*/

  BEGIN

     x_old_stack := x_err_stack;
     x_err_stack := x_err_stack ||'->pa_proj_accum_main.Proj_Accum';
     x_err_code  := 0;

     x_summ_process := 'UP';
     x_err_stage := 'Project Accumulation Process';
     x_log_summ_mode := Fnd_Profile.value('PA_LOG_SUMM_MODE');

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        Pa_Debug.debug('proj_accum: ' || x_err_stack);
     END IF;

     -- Grants Management Integrated Commitment Processing  ---------------------
     -- added 30-MAY-2003, jwhite

     G_GMS_Enabled :=  GMS_PA_API3.grants_enabled;

     IF ( P_DEBUG_MODE = 'Y' )
       THEN
         Pa_Debug.debug('proj_accum: G_GMS_Enabled = ' || G_GMS_Enabled);
     END IF;


    -- -------------------------------------------------------------------------



     -- Validate Parameters
     Get_Project_Num_Range( x_project_num_from,
                            x_project_num_to,
                            l_project_num_from,
                            l_project_num_to,
																												x_project_type );

     IF NVL(x_actual_cost_flag, 'N') = 'N'
         AND NVL(x_revenue_flag, 'N') = 'N'
         AND NVL(x_budgets_flag, 'N') = 'N'
         AND NVL(x_commitments_flag, 'N') = 'N' THEN

         IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
            Pa_Debug.debug('proj_accum: ' || 'Nothing selected for accumulation');
         END IF;
         errbuf  := 'Nothing selected for accumulation ';
         retcode := 2;
         RETURN;
     END IF;
     IF (x_mode <> 'I' ) THEN

         errbuf  := 'Please Select Accumulation mode as (I)ncremental';
         retcode := 3;
         RETURN;
     END IF;

     -- assume the process does not return an error

     retcode :=0;

     -- all the parameters are validated now

     -- Call the Initialization procedure

     Pa_Proj_Accum_Main.initialize;

     IF x_impl_option = 'PA' THEN
        l_current_start_date    := x_current_pa_start_date ;
        l_current_end_date      := x_current_pa_end_date ;
     ELSIF x_impl_option = 'GL' THEN
        l_current_start_date    := x_current_gl_start_date ;
        l_current_end_date      := x_current_gl_end_date ;
     END IF ;

     -- Value for Global variables G_start_proj, G_end_proj, G_context
     -- and G_grouping_id being set
     Pa_Accum_Utils.G_start_proj        := l_project_num_from;
     Pa_Accum_Utils.G_end_proj          := l_project_num_to;
     Pa_Accum_Utils.G_context           := x_summ_context;
     Pa_Accum_Utils.G_grouping_id       := x_grouping_id;

     -- inserts records onto pa_projects_for_accum

     BEGIN

        DELETE  FROM pa_projects_for_accum pfa
        WHERE   pfa.request_id = x_request_id
        AND     pfa.segment1
        BETWEEN l_project_num_from AND l_project_num_to ;

/* Bug1751445 Replaced union with union all. Also commented out call to pa_check_commitments */

        INSERT  INTO pa_projects_for_accum
                (project_id, request_id, action_flag, segment1, exception_flag)
        SELECT  proj.project_id, x_request_id request_id,
                'CS' action_flag, proj.segment1, 'N'
        FROM    pa_projects_for_accum_v proj
        WHERE   proj.segment1
        BETWEEN l_project_num_from AND l_project_num_to
        AND     proj.project_type = NVL(x_project_type, project_type)  --for bug 2543021
        AND     x_actual_cost_flag = 'Y'
        AND     EXISTS (SELECT  'x'
                        FROM    pa_cost_distribution_lines_all cdl
                        WHERE   cdl.project_id = proj.project_id
                                AND (cdl.line_type = 'R' OR
                                     ( cdl.line_type = 'I' and Pa_Proj_Accum_Main.G_PA_Enhanced_Burdening = 'Y')
                                     )  /*4278940 */
                                AND cdl.resource_accumulated_flag='N')
        UNION ALL
        SELECT  proj.project_id, x_request_id request_id,
                'RV' action_flag, proj.segment1, 'N'
        FROM    pa_projects_for_accum_v proj
        WHERE   proj.segment1
        BETWEEN l_project_num_from AND l_project_num_to
        AND     proj.project_type = NVL(x_project_type, project_type)  --for bug 2543021
        AND     x_revenue_flag = 'Y'
        AND     EXISTS (SELECT  'x'
                        FROM    pa_draft_revenues dr
                        WHERE   dr.project_id = proj.project_id
                        AND     NVL(dr.resource_accumulated_flag,'S') =
                                DECODE(x_mode,'I', 'S', 'F',
                                NVL(dr.resource_accumulated_flag,'S'),'S')
                        AND     dr.released_date IS NOT NULL)
        UNION ALL
        SELECT  proj.project_id, x_request_id request_id,
                'RL' action_flag, proj.segment1, 'N'
        FROM    pa_projects_for_accum_v proj
        WHERE   proj.segment1
        BETWEEN l_project_num_from AND l_project_num_to
        AND     proj.project_type = NVL(x_project_type, project_type)  --for bug 2543021
        AND     EXISTS (SELECT  'x'
                        FROM    pa_resource_list_assignments rla
                        WHERE   rla.project_id = proj.project_id
                        AND     NVL(rla.resource_list_accumulated_flag,
                                'N') = 'N')
/*      UNION ALL
        SELECT  proj.project_id, x_request_id request_id,
                'CM' action_flag, proj.segment1, 'N'
        FROM    pa_projects_for_accum_v proj
        WHERE   proj.segment1 BETWEEN l_project_num_from AND l_project_num_to
        AND     x_commitments_flag = 'Y'
        AND     PA_CHECK_COMMITMENTS.commitments_changed(proj.project_id) = 'Y' */
        UNION ALL
        SELECT  proj.project_id, x_request_id request_id,
                'BD' action_flag, proj.segment1, 'N'
        FROM    pa_projects_for_accum_v proj
        WHERE   proj.segment1
        BETWEEN l_project_num_from AND l_project_num_to
        AND     proj.project_type = NVL(x_project_type, project_type)  --for bug 2543021
        AND     x_budgets_flag = 'Y'
        AND     EXISTS (SELECT  'x'
                        FROM    pa_budget_versions bud
                        WHERE   bud.project_id = proj.project_id
                        AND     bud.current_flag = 'Y'
                        AND     bud.resource_accumulated_flag = 'N')
        UNION ALL
        SELECT  proj.project_id, x_request_id request_id,
                'TR' action_flag, proj.segment1, 'Y'
        FROM    pa_projects_for_accum_v proj
        WHERE   proj.segment1
        BETWEEN l_project_num_from AND l_project_num_to
        AND     proj.project_type = NVL(x_project_type, project_type)  --for bug 2543021
        AND     EXISTS (SELECT  'x'
                        FROM    pa_project_accum_headers pah
                        WHERE   pah.project_id = proj.project_id
                        AND   NVL(pah.tasks_restructured_flag, 'N') = 'Y')
        UNION ALL
        SELECT  proj.project_id, x_request_id request_id,
                'PR' action_flag, proj.segment1, 'N'
        FROM    pa_projects_for_accum_v proj
        WHERE   proj.segment1
                BETWEEN l_project_num_from AND l_project_num_to
        AND     proj.project_type = NVL(x_project_type, project_type)  --for bug 2543021
        AND     Pa_Proj_Accum_Main.check_period_flags
                (proj.project_id, x_impl_option, l_current_end_date, 'PR',
                 proj.closed_date, l_current_start_date) = 'Y'
        UNION ALL
        SELECT  proj.project_id, x_request_id request_id,
                'BK' action_flag, proj.segment1, 'Y'
        FROM    pa_projects_for_accum_v proj
        WHERE   proj.segment1
        BETWEEN l_project_num_from AND l_project_num_to
        AND     proj.project_type = NVL(x_project_type, project_type)  --for bug 2543021
        AND     Pa_Proj_Accum_Main.check_period_flags
                (proj.project_id, x_impl_option, l_current_end_date, 'BK',
                 proj.closed_date, l_current_start_date) = 'Y'
        UNION ALL
        SELECT  proj.project_id, x_request_id request_id,
                'CL' action_flag, proj.segment1, 'N'
        FROM    pa_projects_for_accum_v proj
        WHERE   proj.segment1
        BETWEEN l_project_num_from AND l_project_num_to
        AND     proj.project_type = NVL(x_project_type, project_type)  --for bug 2543021
        AND     Pa_Proj_Accum_Main.check_period_flags
                (proj.project_id, x_impl_option, l_current_end_date, 'CL',
                 proj.closed_date, l_current_start_date) = 'Y'
        UNION ALL
        SELECT  proj.project_id, x_request_id request_id,
                'PT' action_flag, proj.segment1, 'Y'
        FROM    pa_projects_for_accum_v proj
        WHERE   proj.segment1
        BETWEEN l_project_num_from AND l_project_num_to
        AND     proj.project_type = NVL(x_project_type, project_type)  --for bug 2543021
        AND     Pa_Proj_Accum_Main.check_period_flags
                (proj.project_id, x_impl_option, l_current_end_date, 'PT',
                 proj.closed_date, l_current_start_date) = 'Y'
        UNION ALL
        SELECT  proj.project_id, x_request_id request_id, 'TX' action_flag,
                proj.segment1, 'N'
        FROM    pa_projects_for_accum_v proj
        WHERE   proj.segment1 BETWEEN l_project_num_from AND l_project_num_to
        AND     proj.project_type = NVL(x_project_type, project_type)  --for bug 2543021
        AND     (x_actual_cost_flag = 'Y' OR x_revenue_flag = 'Y')
        AND     EXISTS (SELECT  'x'
                        FROM    pa_txn_accum txn
                        WHERE   txn.actual_cost_rollup_flag = 'Y'
                        AND     txn.project_id = proj.project_id
                        AND     x_actual_cost_flag = 'Y'
                        UNION ALL
                        SELECT  'x'
                        FROM    pa_txn_accum txn_r
                        WHERE   txn_r.revenue_rollup_flag = 'Y'
                        AND     txn_r.project_id = proj.project_id
                        AND     x_revenue_flag = 'Y')
        UNION ALL
        SELECT  proj.project_id, x_request_id request_id, 'TM' action_flag,
                proj.segment1, 'N'
        FROM    pa_projects_for_accum_v proj
        WHERE   proj.segment1 BETWEEN l_project_num_from AND l_project_num_to
        AND     proj.project_type = NVL(x_project_type, project_type)  --for bug 2543021
        AND     x_commitments_flag = 'Y'
        AND     EXISTS (SELECT  'x'
                        FROM    pa_txn_accum txn_m
                        WHERE   txn_m.cmt_rollup_flag = 'Y'
                        AND     txn_m.project_id = proj.project_id
                        AND     x_commitments_flag = 'Y')
                 ;

/* Added for Bug 1751445 */

        /* Added for bug 5353471 */

     IF x_commitments_flag = 'Y' THEN

        FOR recs IN all_valid_proj LOOP

        INSERT  INTO pa_projects_for_accum
                (project_id, request_id, action_flag, segment1, exception_flag)
        SELECT recs.project_id, x_request_id, 'CM', recs.segment1, 'N'
        FROM   dual
        WHERE  Pa_Check_Commitments.commitments_changed(recs.project_id) = 'Y';

        END LOOP;

     END IF;

        COMMIT WORK ;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   Pa_Debug.debug('proj_accum: ' || 'No Records to be Summarized');
                END IF;
                NULL ;
           WHEN OTHERS THEN
                x_err_code := SQLCODE;
                RAISE;
        END ;
        -- end of insert pa_projects_for_accum

        x_date_through := x_end_date_through;
        IF x_end_date_through >= x_current_pa_end_date OR x_end_date_through IS NULL THEN
              x_date_through := x_end_pa_date;
        END IF;

        -- select only required projects and not all

        BEGIN

        FOR filter_proj IN not_valid_proj LOOP

             Pa_Proj_Accum_Main.lock_proj_level_header_record
                                (filter_proj.project_id);

                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   Pa_Debug.debug('proj_accum: ' || '**** PLEASE REFRESH THE PROJECT '
                                || filter_proj.segment1 || ' ****',
                                Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                END IF;

                IF filter_proj.action_flag = 'PT' THEN
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           Pa_Debug.debug('proj_accum: ' || '***** THE ACCUMULATION PERIOD ' ||
                                 'TYPE HAS CHANGED SINCE THE LAST TIME '||
                                 'THE PROJECT WAS ACCUMULATED *****',
                                  Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                        END IF;
                        errbuf := 'Accumulation Period Type has changed' ;
                        l_sum_exception_code := 'PA_SUM_ACCUM_PERIOD_CHANGED';

                ELSIF filter_proj.action_flag = 'TR' THEN
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           Pa_Debug.debug('proj_accum: ' || '************* TASKS ARE ' ||
                             'RESTRUCTURED FOR THE PROJECT *************',
                              Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                        END IF;
                        errbuf := 'Tasks have been Restructured' ;
                        l_sum_exception_code := 'PA_SUM_TASKS_RESTRUCTURED';

                ELSIF filter_proj.action_flag = 'BK' THEN
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           Pa_Debug.debug('proj_accum: ' || '********** REPORTING PERIOD ' ||
                                 'WAS MOVED BACKWARDS IN TIME **********',
                                  Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                        END IF;
                        errbuf := 'Reporting Period has moved backwards' ;
                        l_sum_exception_code := 'PA_SUM_RPT_PERIOD_BACKWARD';

                ELSIF filter_proj.action_flag = 'CL' THEN
                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           Pa_Debug.debug('proj_accum: ' || '****** PROJECT IS CLOSED AND ' ||
                                 'NOT ELIGIBLE FOR ACCUMULATION *******',
                                  Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                        END IF;
                        errbuf := 'Project is closed' ;
                        l_sum_exception_code := 'PA_SUM_PROJECT_CLOSED';

                END IF ;
               IF (x_proj_header_locked = TRUE) THEN
                   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                      Pa_Debug.debug('proj_accum: ' || 'Cannot update summarization exception for project'||
                                 filter_proj.segment1,Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                   END IF;
               ELSE
                   UPDATE pa_project_accum_headers
                   SET sum_exception_code = l_sum_exception_code
                   WHERE project_id = filter_proj.project_id
                     AND task_id = 0
                     AND resource_list_member_id = 0;

                   l_invalid_proj_cnt := l_invalid_proj_cnt + 1;
               END IF;

        END LOOP ;

        IF (l_invalid_proj_cnt > 0) THEN
              COMMIT WORK;
        END IF;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                NULL ;
           WHEN OTHERS THEN
                x_err_code := SQLCODE;
                DELETE  FROM pa_projects_for_accum
                WHERE   request_id = x_request_id ;
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   Pa_Debug.debug('proj_accum: ' || 'Exception Generated By Oracle Error: ' ||
                         errbuf,Pa_Debug.DEBUG_LEVEL_EXCEPTION );
                   Pa_Debug.debug('proj_accum: ' || 'Skipping the accumulation for project ' ||
                         filter_proj.segment1,
                         Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                END IF;
                RAISE;

        END ;

        -- end of select valid projects
	--Bug 5635857. Select the pending commitments for eligible projects and insert them
        --into the temoporary table pa_commitment_txns_tmp so that they can be used later
        -- in the code
        --Note that if the below condition is changed then the code for updating the commitments
        --should also be changed in the FOR loop

    /* Modified for Bug#6408874 - START */

        IF x_commitments_flag = 'Y' THEN


        populate_cmt_tmp_table( p_project_num_from        => l_project_num_from,
                                p_project_num_to          => l_project_num_to,
                                p_system_linkage_function => x_system_linkage_function,
                                p_refresh_flag            => 'N', -- for Bug# 7175975
                                p_project_type            => NULL); -- for Bug# 7175975

        END IF;
    /* Modified for Bug#6408874 - END */

        FOR valid_proj IN all_projs LOOP

                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   Pa_Debug.debug('proj_accum: ' || 'Processing Project Id = ' ||
                         TO_CHAR(valid_proj.project_id));
                END IF;
                tmp_bud_type_code := x_budget_type_code;
      ------------Acquire lock on the project-----------
      IF Pa_Debug.acquire_user_lock('PA_SUMM:'||TO_CHAR(valid_proj.project_id)) <> 0 THEN
           IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
              Pa_Debug.debug('proj_accum: ' || 'Could not acquire lock on the Project. Skipping ...');
           END IF;
               GOTO skip_project;
      ELSE
           IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
              Pa_Debug.debug('proj_accum: ' || 'Locking the project for summarization ...');
           END IF;
      END IF;
      -------------------------------------------------

                l_project_id    := valid_proj.project_id ;
                l_segment1      := valid_proj.segment1 ;
                x_actions_cnt   := 0 ;
                x_actions_in.DELETE ;   -- Initializing the PL/SQL table

                --  Assign values onto the PL/SQL table for this project

                FOR valid_action IN action_found LOOP
                        x_actions_cnt := x_actions_cnt + 1 ;
                        x_actions_in(x_actions_cnt).action_flag :=
                                        valid_action.action_flag ;
                END LOOP ;

                Initialize_Project(l_project_id,
                                   l_accum_period_type_changed) ;

                --Bug 5060439. Null out the sum_exception_code. It might have got populated in the
                --previous run
                UPDATE  pa_project_accum_headers
                SET     sum_exception_code=NULL
                WHERE   project_accum_id=x_proj_level_accum_id;


                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   Pa_Debug.debug('proj_accum: ' || 'Refreshing new resource lists assigned '||
                         'to the project, If any');
                END IF;

                IF Pa_Proj_Accum_Main.action_exists
                   (x_action_flag       => 'RL',
                    x_actions_in        => x_actions_in,
                    x_actions_cnt       => x_actions_cnt) = 'Y' THEN

                   FOR new_resource_list_rec IN
                       new_resource_list(l_project_id) LOOP
                     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                        Pa_Debug.debug('proj_accum: ' || 'Refreshing resource list id = ' ||
                     TO_CHAR(new_resource_list_rec.resource_list_id) );
                     END IF;

                     IF ( x_prev_accum_period IS NOT NULL ) THEN

                        -- Create resource Map
                        Pa_Res_Accums.map_txns
                                (l_project_id,
                                new_resource_list_rec.resource_list_id,
                                'F',                   -- x_mode = FULL
                                x_err_stage,
                                x_err_code);

                        -- refresh the resource list upto
                        -- last accumulation period
                        x_summ_process := 'RL';
                        Pa_Maint_Project_Accums.process_txn_accum
                                        (l_project_id,
                                         x_impl_option,
                                         x_proj_level_accum_id,
                                         x_prev_accum_period,
                                         x_prev_prev_accum_period,
                                         x_prev_year,
                                         x_prev_accum_period,
                                         x_prev_accum_start_date,
                                         x_prev_accum_end_date,
                                         'Y',
                                         'Y',
                                         'Y',
                                         new_resource_list_rec.resource_list_id,
                                         x_err_stack,
                                         x_err_stage,
                                         x_err_code) ;
                        x_summ_process := 'UP';

--                      pa_refresh_res_lists.process_res_lists
--                                      (l_project_id,
--                                       new_resource_list_rec.resource_list_id,
--                                       x_prev_accum_period,
--                                       x_prev_prev_accum_period,
--                                       x_prev_year,
--                                       x_prev_accum_start_date,
--                                       x_prev_accum_end_date,
--                                       x_err_stack,
--                                       x_err_stage,
--                                       x_err_code);
                     END IF;

                   END LOOP;

                END IF ;

                x_summ_process := 'UP';
                Pa_Txn_Accums.get_accum_configurations
                                    (l_project_id,
                                     x_err_stage,
                                     x_err_code);

                -- Get the summary number from database tables to
                -- PL/SQL table

                table_index := Pa_Accum_Srw.number_of_projects + 1 ;
                Pa_Accum_Srw.get_project_summary_numbers
                        (x_proj_level_accum_id,
                        'PRE',
                        table_index,
                        x_err_stack,
                        x_err_stage,
                        x_err_code) ;
                -- Get project Budgets
                Pa_Accum_Srw.get_project_budget_numbers
                        (x_proj_level_accum_id,
                        'PRE',
                        x_err_stack,
                        x_err_stage,
                        x_err_code) ;

                IF (x_actual_cost_flag = 'Y' AND
                   (Pa_Proj_Accum_Main.action_exists
                        (x_action_flag  => 'CS',
                         x_actions_in   => x_actions_in,
                         x_actions_cnt  => x_actions_cnt) = 'Y')) THEN

                   -- incrementally accumulate actuals txns to PA_TXN_ACCUM
                   IF x_log_summ_mode = 'Y' THEN
                      x_CdlStart := SYSDATE;    /* Start time for CDLs */
                   END IF;

                   Pa_Txn_Accums.accum_cdls
                        (l_project_id,    -- start_project_id
                         l_project_id,    -- end_project_id
                         x_start_pa_date,       -- start_pa_period
                         x_date_through,         -- end_pa_period
                         x_system_linkage_function,
                         x_mode,
                         'R',
                         x_err_stage,
                         x_err_code) ;

                   -- 05-AUG-2003, jwhite: For patchset 'L' Reburdening Enhancement
                   IF (Pa_Proj_Accum_Main.G_PA_Enhanced_Burdening = 'Y')
                     THEN

                      IF ( P_DEBUG_MODE = 'Y' )
                         THEN
                           Pa_Debug.debug('proj_accum: Call Accum_Cdls with x_cdl_line_type = I' );
                      END IF;


                      Pa_Txn_Accums.accum_cdls
                        (l_project_id,    -- start_project_id
                         l_project_id,    -- end_project_id
                         x_start_pa_date,       -- start_pa_period
                         x_date_through,         -- end_pa_period
                         x_system_linkage_function,
                         x_mode,
                         'I',
                         x_err_stage,
                         x_err_code) ;
                   END IF;
                   -- --------------------------------------------------------------

                   IF x_log_summ_mode = 'Y' THEN
                      x_CdlEnd := SYSDATE;      /* End time for CDLs */
                   END IF;

                 END IF ;

                 IF (x_revenue_flag = 'Y' AND
                    (Pa_Proj_Accum_Main.action_exists
                        (x_action_flag  => 'RV',
                         x_actions_in   => x_actions_in,
                         x_actions_cnt  => x_actions_cnt) = 'Y')) THEN

                    IF x_log_summ_mode = 'Y' THEN
                       x_RdlStart := SYSDATE;   /* Start time for RDLs */
                    END IF;
                    Pa_Txn_Accums.accum_revenue
                         (l_project_id,    -- start_project_id
                          l_project_id,    -- end_project_id
                          x_start_pa_date,       -- start_pa_period
                          x_date_through,         -- end_pa_period
                          x_mode,
                          x_err_stage,
                          x_err_code) ;
                    IF x_log_summ_mode = 'Y' THEN
                       x_RdlEnd := SYSDATE;     /* End time for RDLs */
                    END IF;

                  END IF ;

                  IF (x_commitments_flag = 'Y' AND
                     (Pa_Proj_Accum_Main.action_exists
                        (x_action_flag  => 'CM',
                         x_actions_in   => x_actions_in,
                         x_actions_cnt  => x_actions_cnt) = 'Y')) THEN

                     Pa_Delete_Accum_Recs.delete_project_commitments
                        (l_project_id,
                         x_err_stack,
                         x_err_stage,
                         x_err_code) ;
                     -- Initialize the commitment figures in
                     -- pa_txn_accum to Zero for commitments

                     Pa_Txn_Accums.refresh_txn_accum
                        (l_project_id,    -- start_project_id
                         l_project_id,    -- end_project_id
                         x_start_pa_date,       -- start_pa_period
                         x_end_pa_date,         -- end_pa_period
                         'M',                   -- Txn_type for Commitments
                         x_system_linkage_function,
                         x_err_stage,
                         x_err_code) ;

                     -- Create new commitments in the pa_commitment_txns
                     IF x_log_summ_mode = 'Y' THEN
                        x_CmtcrStart := SYSDATE;  --Start time for CMT creation
                     END IF;
                     Pa_Txn_Accums.create_cmt_txns
                        (l_project_id,    -- start_project_id
                         l_project_id,    -- end_project_id
                         x_system_linkage_function,
                         x_err_stage,
                         x_err_code,
                         'Y' ) ;   --x_use_tmp_table bug 5635857
                     IF x_log_summ_mode = 'Y' THEN
                        x_CmtcrEnd := SYSDATE;  --End time for CMT creation
                     END IF;

                     -- Create summarized burden commitment transactions
                     Pa_Burden_Costing.create_burden_cmt_transaction
                                (x_project_id=>l_project_id,  /* added for bug 2734747 */
				 status=>x_status,
                                 stage=>x_stage ,
                                 x_run_id=>x_run_id);

                     -- accumulate the commitments from
                     -- pa_commitment_txns to pa_txn_accum
                     IF x_log_summ_mode = 'Y' THEN
                        x_CmtaccStart := SYSDATE; /* Start time for CMT accum */
                     END IF;
                     Pa_Txn_Accums.accum_commitments
                        (l_project_id,    -- start_project_id
                         l_project_id,    -- end_project_id
                         x_system_linkage_function,
                         x_err_stage,
                         x_err_code) ;
                     IF x_log_summ_mode = 'Y' THEN
                        x_CmtaccEnd := SYSDATE;    /* End time for CMT accum */
                     END IF;

                  END IF;

                  IF Pa_Proj_Accum_Main.action_exists
                        (x_action_flag  => 'PR',
                         x_actions_in   => x_actions_in,
                         x_actions_cnt  => x_actions_cnt) = 'Y' THEN

                        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                           Pa_Debug.debug('proj_accum: ' || 'Accumulation Period has changed'||
                                 ', since last accumulation');
                        END IF;

                        -- Initialize summary level numbers
                        accumlation_period_changed := TRUE ;

                        IF x_log_summ_mode = 'Y' THEN
                           x_InitStart := SYSDATE; --Initialize actuals
                        END IF;
                        Pa_Maint_Project_Accums.initialize_actuals
                                (l_project_id,
                                 x_proj_level_accum_id,
                                 x_impl_option,
                                 x_current_period,
                                 x_prev_period,
                                 x_prev_accum_period,
                                 x_current_year,
                                 x_prev_year,
                                 x_prev_accum_year,
                                 x_current_start_date,
                                 x_current_end_date,
                                 x_prev_start_date,
                                 x_prev_end_date,
                                 x_prev_accum_start_date,
                                 x_prev_accum_end_date,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code) ;
                         IF x_log_summ_mode = 'Y' THEN
                           x_InitEnd := SYSDATE; /* Initialize actuals, CMTs */
                         END IF;

-- Commitments will be initialized only if  :
--      Commitments have not been asked to be processed by the user
--      Or Commitments have been asked to be processed and there are
--         no new commitments to be processed

--                      IF (x_commitments_flag <> 'Y')
--                      OR (x_commitments_flag = 'Y' AND
--                           (pa_proj_accum_main.action_exists
--                              (x_action_flag  => 'CM',
--                               x_actions_in   => x_actions_in,
--                               x_actions_cnt  => x_actions_cnt) <> 'Y' AND
--                            pa_proj_accum_main.action_exists
--                              (x_action_flag  => 'TM',
--                               x_actions_in   => x_actions_in,
--                               x_actions_cnt  => x_actions_cnt) <> 'Y')) THEN

--                         -- initialize commitment figures
--                         pa_maint_project_accums.initialize_commitments
--                                      (l_project_id,
--                                       x_proj_level_accum_id,
--                                       x_impl_option,
--                                       x_current_period,
--                                       x_prev_period,
--                                       x_prev_accum_period,
--                                       x_current_year,
--                                       x_prev_year,
--                                       x_prev_accum_year,
--                                       x_current_start_date,
--                                       x_current_end_date,
--                                       x_prev_start_date,
--                                       x_prev_end_date,
--                                       x_prev_accum_start_date,
--                                       x_prev_accum_end_date,
--                                       x_err_stack,
--                                       x_err_stage,
--                                       x_err_code) ;
--                       IF x_log_summ_mode = 'Y' THEN
--                         x_InitEnd := SYSDATE; /* Initialize actuals */
--                       END IF;

--                      END IF ;


                        -- we will ignore the input budget type code
                        -- in this case
                        tmp_bud_type_code := NULL ;

                END IF ;

                IF Pa_Proj_Accum_Main.action_exists
                        (x_action_flag  => 'PR',
                         x_actions_in   => x_actions_in,
                         x_actions_cnt  => x_actions_cnt) = 'Y'
                OR (x_budgets_flag = 'Y' AND
                    Pa_Proj_Accum_Main.action_exists
                        (x_action_flag  => 'BD',
                         x_actions_in   => x_actions_in,
                         x_actions_cnt  => x_actions_cnt) = 'Y') THEN

                        -- Mark all budgets to be accumulated
                        -- When the accumulation period is changed

                        UPDATE  Pa_Budget_Versions
                        SET     Resource_Accumulated_Flag ='N'
                        WHERE   Project_id = l_project_id
                        AND (Current_Flag = 'Y' OR current_original_flag = 'Y');

                        Pa_Delete_Accum_Recs.delete_project_budgets
                                (l_project_id,
                                 tmp_bud_type_code,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code) ;


                        -- Process the transactions by reading
                        -- PA_BUDGET_BY_PA_PERIOD_V

                        IF x_log_summ_mode = 'Y' THEN
                           -- Start time for Process Budget Txns
                           x_BudStart := SYSDATE;
                        END IF;

                        Pa_Maint_Project_Budgets.process_budget_txns
                                (l_project_id,
                                 x_impl_option,
                                 x_proj_level_accum_id,
                                 tmp_bud_type_code,
                                 x_current_period,
                                 x_prev_period,
                                 x_current_year,
                                 x_prev_accum_period,
                                 x_current_start_date,
                                 x_current_end_date,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code) ;

                        IF x_log_summ_mode = 'Y' THEN
                           -- End time for Process Budget Txns
                           x_BudEnd := SYSDATE;
                        END IF;

                END IF ;

                Pa_Accum_Utils.update_proj_accum_header
                                 (x_proj_level_accum_id,
                                  x_current_period,
                                  x_err_stack,
                                  x_err_stage,
                                  x_err_code);

                IF  Pa_Proj_Accum_Main.action_exists
                        (x_action_flag  => 'CS',
                         x_actions_in   => x_actions_in,
                         x_actions_cnt  => x_actions_cnt) = 'Y'
                OR  Pa_Proj_Accum_Main.action_exists
                        (x_action_flag  => 'RV',
                         x_actions_in   => x_actions_in,
                         x_actions_cnt  => x_actions_cnt) = 'Y'
                OR  Pa_Proj_Accum_Main.action_exists
                        (x_action_flag  => 'CM',
                         x_actions_in   => x_actions_in,
                         x_actions_cnt  => x_actions_cnt) = 'Y'
                OR  Pa_Proj_Accum_Main.action_exists
                        (x_action_flag  => 'TM',
                         x_actions_in   => x_actions_in,
                         x_actions_cnt  => x_actions_cnt) = 'Y'
                OR  Pa_Proj_Accum_Main.action_exists
                        (x_action_flag  => 'TX',
                         x_actions_in   => x_actions_in,
                         x_actions_cnt  => x_actions_cnt) = 'Y' THEN

                     IF x_log_summ_mode = 'Y' THEN
                        x_MapTxnStart := SYSDATE;  --Start time for Map Txns
                     END IF;
                     Pa_Res_Accums.map_txns
                                (l_project_id,
                                 NULL,  -- resource_list_id
                                 x_mode,
                                 x_err_stage,
                                 x_err_code) ;
                    IF x_log_summ_mode = 'Y' THEN
                       x_MapTxnEnd := SYSDATE;  --End time for Map Txns
                    END IF;

--                   IF (pa_proj_accum_main.action_exists
--                              (x_action_flag  => 'CM',
--                               x_actions_in   => x_actions_in,
--                               x_actions_cnt  => x_actions_cnt) = 'Y'
--                               AND x_commitments_flag = 'Y')
--                   OR  pa_proj_accum_main.action_exists
--                              (x_action_flag  => 'PR',
--                               x_actions_in   => x_actions_in,
--                               x_actions_cnt  => x_actions_cnt) = 'Y'
--                   OR  (pa_proj_accum_main.action_exists
--                              (x_action_flag  => 'TM',
--                               x_actions_in   => x_actions_in,
--                               x_actions_cnt  => x_actions_cnt) = 'Y'
--                               AND x_commitments_flag = 'Y')
--                   THEN
--
--                       -- rollup the commitments from pa_txn_accum to
--                       -- pa_project_accum_commitments
--                       IF x_log_summ_mode = 'Y' THEN
--                          --  Start time for Process txn accum cmt
--                          x_PrcCmtStart := SYSDATE;
--                       END IF;
--                       pa_maint_project_commitments.process_txn_accum_cmt
--                                      (l_project_id,
--                                       x_impl_option,
--                                       x_proj_level_accum_id,
--                                       x_current_period,
--                                       x_prev_period,
--                                       x_current_year,
--                                       x_prev_accum_period,
--                                       x_current_start_date,
--                                       x_current_end_date,
--                                       x_err_stack,
--                                       x_err_stage,
--                                       x_err_code) ;
--                      IF x_log_summ_mode = 'Y' THEN
--                         -- End time for Process txn accum cmt
--                         x_PrcCmtEnd := SYSDATE;
--                      END IF;
--
--                   END IF ;

                     IF (Pa_Proj_Accum_Main.action_exists
                                (x_action_flag  => 'CS',
                                 x_actions_in   => x_actions_in,
                                 x_actions_cnt  => x_actions_cnt) = 'Y'
                                 AND x_actual_cost_flag = 'Y')
                     OR (Pa_Proj_Accum_Main.action_exists
                                (x_action_flag  => 'RV',
                                 x_actions_in   => x_actions_in,
                                 x_actions_cnt  => x_actions_cnt) = 'Y'
                                 AND x_revenue_flag = 'Y')
                     OR  Pa_Proj_Accum_Main.action_exists
                                (x_action_flag  => 'TX',
                                 x_actions_in   => x_actions_in,
                                 x_actions_cnt  => x_actions_cnt) = 'Y'
                     OR (Pa_Proj_Accum_Main.action_exists
                                (x_action_flag  => 'CM',
                                 x_actions_in   => x_actions_in,
                                 x_actions_cnt  => x_actions_cnt) = 'Y'
                                 AND x_commitments_flag = 'Y')
                     OR (Pa_Proj_Accum_Main.action_exists
                                (x_action_flag  => 'TM',
                                 x_actions_in   => x_actions_in,
                                 x_actions_cnt  => x_actions_cnt) = 'Y'
                                 AND x_commitments_flag = 'Y') THEN

                        -- rollup the actuals from pa_txn_accum to
                        -- pa_project_accum_actuals
                        -- Process the transactions by reading PA_TXN_ACCUM
                        IF x_log_summ_mode = 'Y' THEN
                           -- Start time for Process Txn Accum
                           x_PrcTxnStart := SYSDATE;
                           x_PrcCmtStart := SYSDATE;
                        END IF;
                        Pa_Maint_Project_Accums.process_txn_accum
                                        (l_project_id,
                                         x_impl_option,
                                         x_proj_level_accum_id,
                                         x_current_period,
                                         x_prev_period,
                                         x_current_year,
                                         x_prev_accum_period,
                                         x_current_start_date,
                                         x_current_end_date,
                                         x_actual_cost_flag,
                                         x_revenue_flag,
                                         x_commitments_flag,
                                         NULL,
                                         x_err_stack,
                                         x_err_stage,
                                         x_err_code) ;
                        IF x_log_summ_mode = 'Y' THEN
                           -- End time for Process Txn Accum
                           x_PrcTxnEnd := SYSDATE;
                           x_PrcCmtEnd := SYSDATE;
                        END IF;

                     END IF ;

                END IF ;

                -- Delete any extraneous project records in the
                -- Project_accum_headers without Actuals,
                -- commitments and Budgets

                Pa_Delete_Accum_Recs.delete_project_accum_headers
                              (l_project_id,
                               x_err_stack,
                               x_err_stage,
                               x_err_code) ;

                -- Get the summary number from database tables
                -- to PL/SQL table

                IF x_log_summ_mode = 'Y' THEN
                   x_PrjSumStart := SYSDATE;    /* Start time for Summary */
                END IF;
                Pa_Accum_Srw.get_project_summary_numbers
                      (x_proj_level_accum_id,
                       'POST',
                       table_index,
                       x_err_stack,
                       x_err_stage,
                       x_err_code) ;

                Pa_Accum_Srw.number_of_projects := table_index ;

                Pa_Accum_Srw.get_project_budget_numbers
                       (x_proj_level_accum_id,
                        'POST',
                        x_err_stack,
                        x_err_stage,
                        x_err_code) ;

                IF x_log_summ_mode = 'Y' THEN
                   x_PrjSumEnd := SYSDATE;      /* End time for Summary */

                   -- Inserting into the temporary table pa_accum_txn_time
                   -- the various start and end time values

                   INSERT INTO pa_accum_txn_time
                           (Project_id,
                            Project_num,
                            Request_id,
                            Attribute1,
                            Attribute2,
                            Attribute3,
                            Attribute4,
                            Attribute5,
                            Attribute6,
                            Attribute7,
                            Attribute8,
                            Attribute9,
                            Attribute10,
                            Attribute11,
                            Attribute12,
                            Attribute13,
                            Attribute14,
                            Attribute15,
                            Attribute16,
                            Attribute17,
                            Attribute18,
                            Attribute19,
                            Attribute20
                            )
                   VALUES
                            (l_project_id,
                             l_segment1,
                             x_request_id,
                             x_CdlStart,
                             x_CdlEnd,
                             x_RdlStart,
                             x_RdlEnd,
                             x_CmtCrStart,
                             x_CmtCrEnd,
                             x_CmtAccStart,
                             x_CmtAccEnd,
                             x_InitStart,
                             x_InitEnd,
                             x_BudStart,
                             x_BudEnd,
                             x_MapTxnStart,
                             x_MapTxnEnd,
                             x_PrcCmtStart,
                             x_PrcCmtEnd,
                             x_PrcTxnStart,
                             x_PrcTxnEnd,
                             x_PrjSumStart,
                             x_PrjSumEnd
                             );
                END IF;

         COMMIT WORK;  -- we are done with this project now

        IF Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(valid_proj.project_id)) = 0 THEN
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               Pa_Debug.debug('proj_accum: ' || 'Releasing the lock on project ...');
            END IF;
        END IF;

         -- Re-Initializing start and end variables

        IF x_log_summ_mode = 'Y' THEN
          x_CdlStart    := NULL; /* Start time for accum_cdls          */
          x_CdlEnd      := NULL; /* End   time for accum_cdls          */
          x_RdlStart    := NULL; /* Start time for accum_revenue       */
          x_RdlEnd      := NULL; /* End   time for accum_revenue       */
          x_CmtcrStart  := NULL; /* Start time for create_commitments  */
          x_CmtcrEnd    := NULL; /* End   time for create_commitments  */
          x_CmtaccStart := NULL; /* Start time for accum_commitments   */
          x_CmtaccEnd   := NULL; /* End   time for accum_commitments   */
          x_InitStart   := NULL; -- Start time for Initialize Actuals and CMTs
          x_InitEnd     := NULL; -- End   time for Initialize Actuals and CMTs
          x_BudStart    := NULL; /* Start time for process_budget_txns */
          x_BudEnd      := NULL; /* End   time for process_budget_txns */

          x_MapTxnStart := NULL;        /* Start time for Map Txns */
          x_MapTxnEnd   := NULL;        /* End time for Map Txns */
          x_PrcCmtStart := NULL;        /* Start time process_txn_accum_cmt */
          x_PrcCmtEnd   := NULL;        /* End time process_txn_accum_cmt */
          x_PrcTxnStart := NULL;        /* Start time for process_txn_accum */
          x_PrcTxnEnd   := NULL;        /* End time for process_txn_accum */
          x_PrjSumStart := NULL; /* Start time for Project Summary */
          x_PrjSumEnd   := NULL; /* End   time for Project Summary */
        END IF;

        <<skip_project>>
                NULL ;

   END LOOP ;

   IF x_delete_temp_table = 'Y' THEN
        DELETE FROM pa_projects_for_accum WHERE  request_id = x_request_id
        AND    exception_flag = 'N';
   ELSE
        DELETE FROM pa_projects_for_accum WHERE  request_id = x_request_id;
   END IF;

   COMMIT WORK ;

  EXCEPTION

       WHEN OTHERS THEN
          rel_lock := Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(l_project_id));
          x_err_code := SQLCODE;
          retcode := x_err_code;
          errbuf  := SUBSTR(SQLERRM(SQLCODE),1,512);
          ROLLBACK WORK;
          DELETE  FROM pa_projects_for_accum
          WHERE   request_id = x_request_id ;
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             Pa_Debug.debug('proj_accum: ' || 'Exception Generated By Oracle Error: ' ||
                   errbuf ,Pa_Debug.DEBUG_LEVEL_EXCEPTION);
          END IF;
          COMMIT WORK;
          --raise;
          RETURN;
  END proj_accum;

  --   Procedure for project refresh

  --   project_num_from  : start project # : mandatory
  --   project_num_to    : end   project # : mandatory

  PROCEDURE proj_refresh
                        ( errbuf                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          retcode                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_project_num_from        IN  VARCHAR2,
                          x_project_num_to          IN  VARCHAR2,
                          x_end_date_through        IN  DATE,
                          x_project_type            IN  VARCHAR2 -- for bug 2543021
                        )
  IS

    /* Added Debug Profile Option  variable initialization for bug#2674619 */

    P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');



    l_accum_period_type_changed BOOLEAN;

    x_log_summ_mode      VARCHAR2(1) := 'N';

    x_CdlStart           DATE := NULL; /* Start time for accum_cdls          */
    x_CdlEnd             DATE := NULL; /* End   time for accum_cdls          */
    x_RdlStart           DATE := NULL; /* Start time for accum_revenue       */
    x_RdlEnd             DATE := NULL; /* End   time for accum_revenue       */
    x_CmtcrStart         DATE := NULL; /* Start time for create_commitments  */
    x_CmtcrEnd           DATE := NULL; /* End   time for create_commitments  */
    x_CmtaccStart        DATE := NULL; /* Start time for accum_commitments   */
    x_CmtaccEnd          DATE := NULL; /* End   time for accum_commitments   */

    x_MapTxnStart        DATE := NULL;  /* Start time for Map Txns */
    x_MapTxnEnd          DATE := NULL;  /* End time for Map Txns */
    x_PrcTxnStart        DATE := NULL;  /* Start time for process_txn_accum */
    x_PrcTxnEnd          DATE := NULL;  /* End time for process_txn_accum */
    x_PrcCmtStart        DATE := NULL;  /* Start time process_txn_accum_cmt */
    x_PrcCmtEnd          DATE := NULL;  /* End time process_txn_accum_cmt */

    x_BudStart           DATE := NULL; /* Start time for process_budget_txns */
    x_BudEnd             DATE := NULL; /* End   time for process_budget_txns */
    x_DelAccStart        DATE := NULL; /* Start time - Delete ProjAccHeaders */
    x_DelAccEnd          DATE := NULL; /* End   time - Delete ProjAccHeaders */
    x_PrjSumStart        DATE := NULL; /* Start time for Project Summary */
    x_PrjSumEnd          DATE := NULL; /* End   time for Project Summary */

    l_project_num_from VARCHAR2(25);
    l_project_num_to   VARCHAR2(25);
    l_project_id       NUMBER;
    tmp_budget_type_code        VARCHAR2(30) ;

    -- Declare cursor for Projects

    CURSOR selprjs IS
    SELECT
         ppr.project_id,
         ppr.segment1,
         ppr.closed_date
    FROM
         pa_projects ppr
    WHERE
         NVL(ppr.template_flag,'N') <> 'Y'
    AND  ppr.segment1 BETWEEN l_project_num_from AND l_project_num_to
    AND  ppr.project_type = NVL(x_project_type, project_type)       -- for bug 2543021
    AND  Pa_Utils2.IsProjectInPurgeStatus(ppr.project_status_code) = 'N';

    -- cursor for getting the budget_type_code for the given project_id

    CURSOR Get_all_Budget_Types_cur(x_project_id NUMBER) IS
      SELECT DISTINCT use_code Budget_Type_Code
    FROM
      pa_resource_list_uses_v
    WHERE project_id =  x_project_id
    AND budget_type_yn = 'Y';

    projrec         selprjs%ROWTYPE;
    budget_type_rec Get_all_Budget_Types_cur%ROWTYPE;
    table_index     BINARY_INTEGER; -- index for the table for reporting
    x_date_through        DATE;

  BEGIN

    x_old_stack := x_err_stack;
    x_err_stack := x_err_stack ||'->pa_proj_accum_main.proj_refresh';
    x_err_code  := 0;

    x_summ_process := 'RF';
    x_err_stage := 'Project refresh Process';
    x_log_summ_mode := Fnd_Profile.value('PA_LOG_SUMM_MODE');

     IF (x_end_date_through IS NULL OR x_end_date_through >= x_current_pa_end_date) THEN
            x_date_through := x_end_pa_date;
     ELSE
            x_date_through := x_end_date_through;
     END IF;

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        Pa_Debug.debug('proj_refresh: ' || x_err_stack);
     END IF;


    -- Grants Management Integrated Commitment Processing  ---------------------
    -- added 30-MAY-2003, jwhite

     G_GMS_Enabled :=  GMS_PA_API3.grants_enabled;

     IF ( P_DEBUG_MODE = 'Y' )
       THEN
         Pa_Debug.debug('proj_accum: G_GMS_Enabled = ' || G_GMS_Enabled);
     END IF;


    -- -------------------------------------------------------------------------



     -- Validate Parameters
     Get_Project_Num_Range( x_project_num_from,
                            x_project_num_to,
                            l_project_num_from,
                            l_project_num_to,
																												x_project_type );    -- for bug 2543021

     -- assume the process does not return an error
     retcode :=0;

     -- Call the Initialization procedure

     Pa_Proj_Accum_Main.initialize;
     -- Added below for Bug# 7175975
     populate_cmt_tmp_table(p_project_num_from        => l_project_num_from,
                           p_project_num_to          => l_project_num_to,  -- Bug 9354283
                           p_system_linkage_function => NULL,
                           p_refresh_flag            => 'Y',
                           p_project_type            => x_project_type);
     -- End for Bug# 7175975

     FOR projrec IN selprjs LOOP

      BEGIN

         -- This PL/SQL block corresponds to processing for each project

         l_project_id := projrec.project_id;
         IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
            Pa_Debug.debug('proj_refresh: ' || 'Refreshing accumulation for Project Id = '
                         || TO_CHAR(projrec.project_id));
         END IF;

         -- Initialize the Global variable in the loop for each project
         -- No need to check if the accumulation period type has been changed
         -- because the project is being refreshed
         Pa_Proj_Accum_Main.initialize_project(projrec.project_id,
                                               l_accum_period_type_changed);

    -- Try to Lock the project level record
      IF Pa_Debug.acquire_user_lock('PA_SUMM:'||TO_CHAR(projrec.project_id)) <> 0 THEN
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               Pa_Debug.debug('proj_refresh: ' || 'Could not acquire lock on the Project. Skipping ...');
            END IF;
            GOTO next_project;
      ELSE
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               Pa_Debug.debug('proj_refresh: ' || 'Locking the project for summarization ...');
            END IF;
      END IF;
   -------------------------------------------------

         -- Get the accum configuration

         Pa_Txn_Accums.get_accum_configurations
                            (projrec.project_id,
                             x_err_stage,
                             x_err_code);

         -- Get the summary number from database tables to PL/SQL table

         table_index := Pa_Accum_Srw.number_of_projects + 1;

         Pa_Accum_Srw.get_project_summary_numbers
                      (x_proj_level_accum_id,
                       'PRE',
                       table_index,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);

         -- Get project Budgets
         Pa_Accum_Srw.get_project_budget_numbers
                      (x_proj_level_accum_id,
                       'PRE',
                       x_err_stack,
                       x_err_stage,
                       x_err_code);

         -- refresh the resource maps for the resource list assignments
         -- for the entire project

         Pa_Res_Accums.delete_res_maps_on_prj_id
                         (projrec.project_id,
                          NULL,            -- x_resource_list_id
                          x_err_stage,
                          x_err_code);
         Pa_Res_Accums.delete_resource_accum_details
                         (NULL,            -- x_resource_list_assignment_id
                          NULL,            -- x_resource_list_id
                          projrec.project_id,
                          x_err_stage,
                          x_err_code);

         -- refresh summary transaction accum

         Pa_Delete_Accum_Recs.delete_project_actuals
                          (projrec.project_id,
                           x_err_stack,
                           x_err_stage,
                           x_err_code);

         Pa_Delete_Accum_Recs.delete_project_commitments
                           (projrec.project_id,
                            x_err_stack,
                            x_err_stage,
                            x_err_code);

         ------- updating resource_accumulated_flag if through_date is null
         IF x_end_date_through IS NOT NULL THEN
                  Pa_Txn_Accums.update_resource_flag
                                      (projrec.project_id,
                                       projrec.project_id,
                                       x_start_pa_date,
                                       x_end_pa_date,
                                       x_err_stage,
                                       x_err_code);
         END IF;
         -- refresh the actuals txns to PA_TXN_ACCUM

         Pa_Txn_Accums.refresh_txn_accum
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_start_pa_date,       -- start_pa_period
                             x_end_pa_date,         -- end_pa_period
                             'C',                   -- Tyansaction_type for CDLs
                             NULL,
                             x_err_stage,
                             x_err_code);

         Pa_Txn_Accums.refresh_txn_accum
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_start_pa_date,       -- start_pa_period
                             x_end_pa_date,         -- end_pa_period
                             'R',                   -- Transaction_type for Rev.
                             NULL,                  -- system_linakge_funtion
                                                    -- cannot be specified for Rev.
                             x_err_stage,
                             x_err_code);

         -- Now reaccumulate the actuals

         IF x_log_summ_mode = 'Y' THEN
            x_CdlStart := SYSDATE;              /* Start time for CDLs */
         END IF;

         Pa_Txn_Accums.accum_cdls
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_start_pa_date,       -- start_pa_period
                             x_date_through,         -- end_pa_period
                             NULL,
                             'F',
                             'R',
                             x_err_stage,
                             x_err_code);

         -- 05-AUG-2003, jwhite: For patchset 'L' Reburdening Enhancement
         IF (Pa_Proj_Accum_Main.G_PA_Enhanced_Burdening = 'Y')
           THEN

            IF ( P_DEBUG_MODE = 'Y' )
               THEN
                  Pa_Debug.debug('proj_accum: Call Accum_Cdls with x_cdl_line_type = I' );
            END IF;

            Pa_Txn_Accums.accum_cdls
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_start_pa_date,       -- start_pa_period
                             x_date_through,         -- end_pa_period
                             NULL,
                             'F',
                             'I',
                             x_err_stage,
                             x_err_code);

          END IF;
          -- --------------------------------------------------------------



         IF x_log_summ_mode = 'Y' THEN
            x_CdlEnd := SYSDATE;                /* End time for CDLs */

            x_RdlStart := SYSDATE;              /* Start time for RDLs */
         END IF;

         Pa_Txn_Accums.accum_revenue
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_start_pa_date,       -- start_pa_period
                             x_date_through,         -- end_pa_period
                             'F',
                             x_err_stage,
                             x_err_code);
         IF x_log_summ_mode = 'Y' THEN
            x_RdlEnd := SYSDATE;                /* End time for RDLs */
         END IF;

         -- now refresh the commitments
         -- please note that the commitments are always refreshed

         Pa_Txn_Accums.refresh_txn_accum
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_start_pa_date,       -- start_pa_period
                             x_end_pa_date,         -- end_pa_period
                             'M',                   -- Transaction_type for Commitments
                             NULL,
                             x_err_stage,
                             x_err_code);

         IF x_log_summ_mode = 'Y' THEN
            x_CmtCrStart := SYSDATE;     /* Start time for CMTs creation */
         END IF;

         Pa_Txn_Accums.create_cmt_txns
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             NULL,
                             x_err_stage,
                             x_err_code,
			     'Y');  --x_use_tmp_table bug 5635857, changed to Y for Bug# 7175975
         IF x_log_summ_mode = 'Y' THEN
            x_CmtCrEnd := SYSDATE;      /* End time for CMT creation */

            x_CmtAccStart := SYSDATE;   /* Start time for CMT accumulation */
         END IF;

           -- Create summarized burden commitment transactions
              Pa_Burden_Costing.create_burden_cmt_transaction
                     (x_project_id=>projrec.project_id,  /* added for bug 2734747 */
		      status=>x_status,
                      stage=>x_stage ,
                      x_run_id=>x_run_id);

         Pa_Txn_Accums.accum_commitments
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             NULL,
                             x_err_stage,
                             x_err_code);
         IF x_log_summ_mode = 'Y' THEN
            x_CmtAccEnd := SYSDATE;     /* End time for CMT accumulation */

         -- Create resource Map

            x_MapTxnStart := SYSDATE;   /* Start time for Map Txns */
         END IF;

         Pa_Res_Accums.map_txns
                (projrec.project_id,
                 NULL,                  -- resource_list_id
                 'F',
                 x_err_stage,
                 x_err_code);
         IF x_log_summ_mode = 'Y' THEN
            x_MapTxnEnd := SYSDATE;     /* End time for Map Txns */
            x_PrcTxnStart := SYSDATE;   /* Start time for process_txn_accum */
            x_PrcCmtStart := SYSDATE;   /* Start time process_txn_accum_cmt */
         END IF;

         -- refresh actuals
         -- Process the transactions by reading PA_TXN_ACCUM
         Pa_Maint_Project_Accums.process_txn_accum
                                ( projrec.project_id,
                                  x_impl_option,
                                  x_proj_level_accum_id,
                                  x_current_period,
                                  x_prev_period,
                                  x_current_year,
                                  x_prev_accum_period,
                                  x_current_start_date,
                                  x_current_end_date,
                                  'Y',
                                  'Y',
                                  'Y',
                                  NULL,
                                  x_err_stack,
                                  x_err_stage,
                                  x_err_code);
         IF x_log_summ_mode = 'Y' THEN
            x_PrcTxnEnd := SYSDATE;     /* Start time for process_txn_accum */
            x_PrcCmtEnd := SYSDATE;     /* End time process_txn_accum_cmt */
         END IF;

         -- refresh commitment
--         pa_maint_project_commitments.process_txn_accum_cmt
--                                  (projrec.project_id,
--                                   x_impl_option,
--                                   x_proj_level_accum_id,
--                                   x_current_period,
--                                   x_prev_period,
--                                   x_current_year,
--                                   x_prev_accum_period,
--                                   x_current_start_date,
--                                   x_current_end_date,
--                                   x_err_stack,
--                                   x_err_stage,
--                                   x_err_code);
         IF x_log_summ_mode = 'Y' THEN
            x_PrcCmtEnd := SYSDATE;     /* End time process_txn_accum_cmt */
         END IF;

         Pa_Accum_Utils.update_proj_accum_header
                                 (x_proj_level_accum_id,
                                  x_current_period,
                                  x_err_stack,
                                  x_err_stage,
                                  x_err_code);

         -- Update the tasks_restructured_flag to 'N'

         Pa_Accum_Utils.update_tasks_restructured_flag (x_proj_level_accum_id,
                                                      'N',
                                                      x_err_stack,
                                                      x_err_stage,
                                                      x_err_code);

  -- Check if the reporting period was moved backwards
  check_reporting_period
       (x_reporting_period_status, x_err_stack, x_err_stage, x_err_code);

  IF(x_reporting_period_status = 'Y') THEN

       -- Stop processing and exit the procedure return from the procedure
       -- after a  rollback;
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          Pa_Debug.debug('proj_refresh: ' || '*********************************************************************************',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
          Pa_Debug.debug('proj_refresh: ' || '******Reporting Period Moved Backward In Time During Process Run',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
          Pa_Debug.debug('proj_refresh: ' || '******The Accumulation for the project '|| projrec.segment1 || ' Rolled Back',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
          Pa_Debug.debug('proj_refresh: ' || '*********************************************************************************',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
       END IF;
         IF Pa_Debug.release_user_lock( 'PA_SUMM:'||TO_CHAR(projrec.project_id)) = 0 THEN
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 Pa_Debug.debug('proj_refresh: ' || 'Released lock on project ...');
              END IF;
         END IF;
       errbuf  := 'Reporting Period Moved Backward In Time During Process Run';
       retcode := 2;
       ROLLBACK WORK;
       RETURN;
  END IF; -- IF(x_reporting_period_status = 'Y')


  UPDATE Pa_Budget_Versions
  SET Resource_Accumulated_Flag ='N'
  WHERE Project_id = projrec.project_id AND
   (Current_Flag = 'Y' OR current_original_flag = 'Y');

  Pa_Delete_Accum_Recs.delete_project_budgets
                                (projrec.project_id,
                                 NULL,
                                 x_err_stack,
                                 x_err_stage,
                                 x_err_code);

  -- Process the transactions by reading PA_BUDGET_BY_PA_PERIOD_V
  IF x_log_summ_mode = 'Y' THEN
     x_BudStart := SYSDATE; /* Start time for Process_budget_txns */
  END IF;
  Pa_Maint_Project_Budgets.process_budget_txns
                      (projrec.project_id,
                       x_impl_option,
                       x_proj_level_accum_id,
                       NULL,
                       x_current_period,
                       x_prev_period,
                       x_current_year,
                       x_prev_accum_period,
                       x_current_start_date,
                       x_current_end_date,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);
  IF x_log_summ_mode = 'Y' THEN
     x_BudEnd := SYSDATE; /* End time for Process_budget_txns */
  END IF;

  -- Delete any extraneous project records in the Project_accum_headers
  -- without Actuals,commitments and Budgets

  IF x_log_summ_mode = 'Y' THEN
     x_DelAccStart := SYSDATE; /* Start time for Delete Project_accum_headers */
  END IF;
  Pa_Delete_Accum_Recs.delete_project_accum_headers
                              (projrec.project_id ,
                               x_err_stack,
                               x_err_stage,
                               x_err_code);
  IF x_log_summ_mode = 'Y' THEN
     x_DelAccEnd := SYSDATE; /* End time for Delete Project_accum_headers */

     x_PrjSumStart := SYSDATE; /* Start time for Summary */
  END IF;

  -- Get the summary number from database tables to PL/SQL table

  Pa_Accum_Srw.get_project_summary_numbers
                      (x_proj_level_accum_id,
                       'POST',
                       table_index,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);
  IF x_log_summ_mode = 'Y' THEN
     x_PrjSumEnd := SYSDATE;  /* End time for Summary */
  END IF;

  Pa_Accum_Srw.number_of_projects := table_index;

  Pa_Accum_Srw.get_project_budget_numbers
                      (x_proj_level_accum_id,
                       'POST',
                       x_err_stack,
                       x_err_stage,
                       x_err_code);


       <<next_project>>

         -- Check if the reporting period was moved backwards
         check_reporting_period
             (x_reporting_period_status, x_err_stack, x_err_stage, x_err_code);

         IF(x_reporting_period_status = 'Y') THEN
                -- Stop processing and exit the procedure return from the procedure
                -- after a  rollback;
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   Pa_Debug.debug('proj_refresh: ' || '*********************************************************************************',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                   Pa_Debug.debug('proj_refresh: ' || '******Reporting Period Moved Backward In Time During Process Run',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                   Pa_Debug.debug('proj_refresh: ' || '******The Accumulation for the project '|| projrec.segment1 || ' Rolled Back',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                   Pa_Debug.debug('proj_refresh: ' || '*********************************************************************************',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                END IF;
         IF Pa_Debug.release_user_lock( 'PA_SUMM:'||TO_CHAR(projrec.project_id)) = 0 THEN
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 Pa_Debug.debug('proj_refresh: ' || 'Released lock on project ...');
              END IF;
         END IF;
                errbuf  := 'Reporting Period Moved Backward In Time During Process Run';
                retcode := 2;
IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   Pa_Debug.debug('proj_refresh: ' || 'Here');
END IF;
                ROLLBACK WORK;
                RETURN;
         END IF; -- IF(x_reporting_period_status = 'Y')

         -- Inserting into the temporary table pa_accum_txn_time
         -- the various start and end time values

        IF x_log_summ_mode = 'Y' THEN
           INSERT INTO pa_accum_txn_time
                 (Project_id,
                  Project_num,
                  Request_id,
                  Attribute1,
                  Attribute2,
                  Attribute3,
                  Attribute4,
                  Attribute5,
                  Attribute6,
                  Attribute7,
                  Attribute8,
                  Attribute9,
                  Attribute10,
                  Attribute11,
                  Attribute12,
                  Attribute13,
                  Attribute14,
                  Attribute15,
                  Attribute16,
                  Attribute17,
                  Attribute18,
                  Attribute19,
                  Attribute20
                  )
         VALUES
                  (projrec.project_id,
                   projrec.segment1,
                   x_request_id,
                   x_CdlStart,
                   x_CdlEnd,
                   x_RdlStart,
                   x_RdlEnd,
                   x_CmtCrStart,
                   x_CmtCrEnd,
                   x_CmtAccStart,
                   x_CmtAccEnd,
                   x_MapTxnStart,
                   x_MapTxnEnd,
                   x_PrcTxnStart,
                   x_PrcTxnEnd,
                   x_PrcCmtStart,
                   x_PrcCmtEnd,
                   x_BudStart,
                   x_BudEnd,
                   x_DelAccStart,
                   x_DelAccEnd,
                   x_PrjSumStart,
                   x_PrjSumEnd
                   );
         END IF;

         COMMIT WORK;  -- we are done with this project now
         IF Pa_Debug.release_user_lock( 'PA_SUMM:'||TO_CHAR(projrec.project_id)) = 0 THEN
              IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                 Pa_Debug.debug('proj_refresh: ' || 'Released lock on project ...');
              END IF;
         END IF;

         -- Re-initializing start and end variables

         IF x_log_summ_mode = 'Y' THEN

            x_CdlStart   := NULL; /* Start time for accum_cdls          */
            x_CdlEnd     := NULL; /* End   time for accum_cdls          */
            x_RdlStart   := NULL; /* Start time for accum_revenue       */
            x_RdlEnd     := NULL; /* End   time for accum_revenue       */
            x_CmtcrStart := NULL; /* Start time for create_commitments  */
            x_CmtcrEnd   := NULL; /* End   time for create_commitments  */
            x_CmtaccStart:= NULL; /* Start time for accum_commitments   */
            x_CmtaccEnd  := NULL; /* End   time for accum_commitments   */

            x_MapTxnStart:= NULL;       /* Start time for Map Txns */
            x_MapTxnEnd  := NULL;       /* End time for Map Txns */
            x_PrcTxnStart:= NULL;       /* Start time for process_txn_accum */
            x_PrcTxnEnd  := NULL;       /* End time for process_txn_accum */
            x_PrcCmtStart:= NULL;       /* Start time process_txn_accum_cmt */
            x_PrcCmtEnd  := NULL;       /* End time process_txn_accum_cmt */

            x_BudStart   := NULL; /* Start time for process_budget_txns */
            x_BudEnd     := NULL; /* End   time for process_budget_txns */
            x_DelAccStart:= NULL; /* Start time for Delete ProjAccHead */
            x_DelAccEnd  := NULL; /* End   time for Delete ProjAccHead */
            x_PrjSumStart:= NULL; /* Start time for Project Summary */
            x_PrjSumEnd  := NULL; /* End   time for Project Summary */

        END IF;

      EXCEPTION

       WHEN OTHERS THEN
          rel_lock := Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(l_project_id));
          x_err_code := SQLCODE;
          retcode := x_err_code;
          errbuf  := SUBSTR(SQLERRM(SQLCODE),1,512);
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             Pa_Debug.debug('proj_refresh: ' || 'Exception Generated By Oracle Error: ' || errbuf,Pa_Debug.DEBUG_LEVEL_EXCEPTION );
             Pa_Debug.debug('proj_refresh: ' || 'Skipping the accumulation for project ' || projrec.segment1 ,Pa_Debug.DEBUG_LEVEL_EXCEPTION);
          END IF;

          -- Exception handling for database errors (other than 1400 and 1489)
          IF x_err_code*-1 BETWEEN 1400 AND 1489 THEN
             ROLLBACK WORK;
          ELSE
             RAISE;
          END IF;

     END; -- end of PL/SQL block for each project

  END LOOP;

  x_err_stack := x_Old_Stack;
  RETURN;

  EXCEPTION

   WHEN OTHERS THEN
     rel_lock := Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(l_project_id));
     x_err_code := SQLCODE;
     retcode := x_err_code;
     errbuf  := SUBSTR(SQLERRM(SQLCODE),1,512);
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        Pa_Debug.debug('proj_refresh: ' || 'Exception Generated By Oracle Error: ' || errbuf ,Pa_Debug.DEBUG_LEVEL_EXCEPTION);
     END IF;
     ROLLBACK WORK;
     RETURN;
  END proj_refresh;

  --   project_num_from  : start project # : mandatory
  --   project_num_to    : end   project # : mandatory
  --   Resource_list_id  : resource_list_id : optional

  PROCEDURE ref_rl_accum
                        ( errbuf                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          retcode                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_project_num_from        IN  VARCHAR2,
                          x_project_num_to          IN  VARCHAR2,
                          x_resource_list_id        IN  NUMBER
                        )
  IS
    P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
    l_accum_period_type_changed BOOLEAN;
    l_sum_exception_code        pa_project_accum_headers.sum_exception_code%TYPE := NULL;
    l_current_start_date        DATE := NULL;
    l_current_end_date          DATE := NULL;

    -- Declare cursor for Projects

    l_project_num_from VARCHAR2(25);
    l_project_num_to   VARCHAR2(25);
    l_project_id       NUMBER;

    CURSOR selprjs IS
    SELECT
         ppr.project_id,
         ppr.segment1,
         ppr.closed_date
    FROM
         pa_projects ppr
    WHERE
         NVL(ppr.template_flag,'N') <> 'Y'
    AND  ppr.segment1 BETWEEN l_project_num_from AND l_project_num_to
    AND  Pa_Utils2.IsProjectInPurgeStatus(ppr.project_status_code)= 'N';

    projrec        selprjs%ROWTYPE;
    x_tasks_restructured_flag VARCHAR2(1);

  BEGIN

     x_err_code  := 0;
     x_old_stack := x_err_stack;

     x_summ_process := 'RL';
     x_err_stack := x_err_stack || '->pa_proj_accum_main.ref_rl_accum';
     x_err_stage := 'Refresh Resource List accumulation Process';

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        Pa_Debug.debug('ref_rl_accum: ' || x_err_stack);
     END IF;

     -- Validate Parameters
     Get_Project_Num_Range( x_project_num_from,
                            x_project_num_to,
                            l_project_num_from,
                            l_project_num_to,
																												NULL );  --for bug 2543021

     -- assume the process does not return an error
     retcode :=0;

     -- Call the Initialization procedure

     Pa_Proj_Accum_Main.initialize;

     FOR projrec IN selprjs LOOP

      BEGIN
         l_sum_exception_code := NULL;
         l_project_id := projrec.project_id;
         -- This PL/SQL block corresponds to processing for each project

         ------------Acquire lock on the project-----------
         IF Pa_Debug.acquire_user_lock('PA_SUMM:'||TO_CHAR(projrec.project_id)) <> 0 THEN
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               Pa_Debug.debug('ref_rl_accum: ' || 'Could not acquire lock on the Project. Skipping ...');
            END IF;
               GOTO next_project;
         ELSE
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               Pa_Debug.debug('ref_rl_accum: ' || 'Locking the project for summarization ...');
            END IF;
         END IF;
         -------------------------------------------------

         IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
            Pa_Debug.debug('ref_rl_accum: ' || 'Refreshing resource list id = ' ||
                    NVL(TO_CHAR(x_resource_list_id),'ALL') || ' For Project Id = '
                    || TO_CHAR(projrec.project_id));
         END IF;

         -- Initialize the Global variable in the loop for each project
         Pa_Proj_Accum_Main.initialize_project(projrec.project_id,
                                               l_accum_period_type_changed);
        IF x_impl_option = 'PA' THEN
                l_current_start_date := x_current_pa_start_date;
                l_current_end_date := x_current_pa_end_date;
        ELSIF x_impl_option = 'GL' THEN
                l_current_start_date := x_current_gl_start_date;
                l_current_end_date := x_current_gl_end_date;
        END IF;

         --
         -- Check to see if the accumulation period type has changed.  If so, the
         -- project must be refreshed.  Bug #572031
         --
        IF (Pa_Proj_Accum_Main.check_period_flags(projrec.project_id,x_impl_option,l_current_end_date,
                                             'PT',projrec.closed_date,l_current_start_date)='Y') THEN
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             Pa_Debug.debug('ref_rl_accum: ' || '*********************************************************************************',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
             Pa_Debug.debug('ref_rl_accum: ' || '*****THE ACCUMULATION PERIOD TYPE HAS CHANGED SINCE THE LAST TIME PROJECT ' || projrec.segment1 || ' WAS ACCUMULATED '|| '******',
                         Pa_Debug.DEBUG_LEVEL_EXCEPTION);
             Pa_Debug.debug('ref_rl_accum: ' || '*****PLEASE REFRESH THE PROJECT ******', Pa_Debug.DEBUG_LEVEL_EXCEPTION);
             Pa_Debug.debug('ref_rl_accum: ' || '*********************************************************************************',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
          END IF;
          -- Stop processing and exit the procedure return from the procedure
          -- after a  rollback;
          errbuf  := 'The Project ' || projrec.segment1 || 'Must Be Refreshed, Because the accumulation period type has changed since the last time the project was summarized';
    --      retcode := 6;
           l_sum_exception_code := 'PA_SUM_ACCUM_PERIOD_CHANGED';
    --      ROLLBACK WORK;
    --      return;
        END IF;


         -- If the tasks restructured flag = 'Y', then put to debug message into the logfile
         BEGIN
         x_tasks_restructured_flag := 'N';

         SELECT 'Y'
         INTO x_tasks_restructured_flag
         FROM sys.dual
         WHERE EXISTS (SELECT 'x'
                         FROM pa_project_accum_headers pah
                        WHERE pah.project_id = projrec.project_id
                          AND NVL(pah.tasks_restructured_flag,'N') = 'Y');

         IF ( x_tasks_restructured_flag = 'Y') THEN
           -- Add a message into the Log file
           IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
              Pa_Debug.debug('ref_rl_accum: ' || '*********************************************************************************',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
              Pa_Debug.debug('ref_rl_accum: ' || '*****THE PROJECT ' || projrec.segment1 || ' TASKS ARE RESTRUCTURED, PLEASE REFRESH THE PROJECT ******',
                                 Pa_Debug.DEBUG_LEVEL_EXCEPTION);
              Pa_Debug.debug('ref_rl_accum: ' || '*********************************************************************************',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
           END IF;
           -- Stop processing and exit the procedure return from the procedure
           -- after a  rollback;
           errbuf  := 'The Project ' || projrec.segment1 || 'Must Be Refreshed, Because the Tasks for this Project were Restructured';
           l_sum_exception_code := 'PA_SUM_TASKS_RESTRUCTURED';
         --  retcode := 6;
         --  ROLLBACK WORK;
         --  return;
         END IF;
         EXCEPTION WHEN NO_DATA_FOUND THEN
               NULL;
         END;
         IF (l_sum_exception_code IS NOT NULL) THEN
              IF (x_proj_header_locked = TRUE) THEN
                   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                      Pa_Debug.debug('ref_rl_accum: ' || 'Cannot update summarization exception for project'||projrec.segment1,Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                   END IF;
              ELSE
                   UPDATE pa_project_accum_headers
                      SET sum_exception_code = l_sum_exception_code
                    WHERE project_id = projrec.project_id
                      AND task_id = 0
                      AND resource_list_member_id = 0;
                   COMMIT WORK;
              END IF;
       IF Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(projrec.project_id)) = 0 THEN
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             Pa_Debug.debug('ref_rl_accum: ' || 'Releasing the lock on project ...');
          END IF;
       END IF;
               GOTO next_project;
          END IF;
         -- refresh the resource maps for the resource list assignments
         Pa_Res_Accums.delete_res_maps_on_prj_id
                         (projrec.project_id,
                          x_resource_list_id,
                          x_err_stage,
                          x_err_code);

         Pa_Res_Accums.delete_resource_accum_details
                         (NULL,
                          x_resource_list_id,
                          projrec.project_id,
                          x_err_stage,
                          x_err_code);

         Pa_Delete_Accum_Recs.delete_res_list_actuals
                         (projrec.project_id,
                          x_resource_list_id,
                          x_err_stack,
                          x_err_stage,
                          x_err_code);

         Pa_Delete_Accum_Recs.delete_res_list_commitments
                         (projrec.project_id,
                          x_resource_list_id,
                          x_err_stack,
                          x_err_stage,
                          x_err_code);

         -- Create resource Map
         Pa_Res_Accums.map_txns
                (projrec.project_id,
                 x_resource_list_id,    -- resource_list_id
                 'F',                   -- x_mode = FULL
                 x_err_stage,
                 x_err_code);

         IF ( x_prev_accum_period IS NULL ) THEN
            -- refresh the resource list upto current period
         Pa_Maint_Project_Accums.process_txn_accum
                                ( projrec.project_id,
                                  x_impl_option,
                                  x_proj_level_accum_id,
                                  x_current_period,
                                  x_prev_period,
                                  x_current_year,
                                  x_prev_accum_period,
                                  x_current_start_date,
                                  x_current_end_date,
                                  'Y',
                                  'Y',
                                  'Y',
                                  x_resource_list_id,
                                  x_err_stack,
                                  x_err_stage,
                                  x_err_code);

--            pa_refresh_res_lists.process_res_lists
--                               (projrec.project_id,
--                                x_resource_list_id,
--                                x_current_period,
--                                x_prev_period,
--                                x_current_year,
--                                x_current_start_date,
--                                x_current_end_date,
--                                x_err_stack,
--                                x_err_stage,
--                                x_err_code);
         ELSE
            -- refresh the resource list upto last accumulation period
                        Pa_Maint_Project_Accums.process_txn_accum
                                        (projrec.project_id,
                                         x_impl_option,
                                         x_proj_level_accum_id,
                                         x_prev_accum_period,
                                         x_prev_prev_accum_period,
                                         x_prev_year,
                                         x_prev_accum_period,
                                         x_prev_accum_start_date,
                                         x_prev_accum_end_date,
                                         'Y',
                                         'Y',
                                         'Y',
                                         x_resource_list_id,
                                         x_err_stack,
                                         x_err_stage,
                                         x_err_code) ;

--            pa_refresh_res_lists.process_res_lists
--                               (projrec.project_id,
--                                x_resource_list_id,
--                                x_prev_accum_period,
--                                x_prev_prev_accum_period,
--                                x_prev_year,
--                                x_prev_accum_start_date,
--                                x_prev_accum_end_date,
--                                x_err_stack,
--                                x_err_stage,
--                                x_err_code);
         END IF;

       <<next_project>>

          -- Check if the reporting period was moved backwards
          check_reporting_period
             (x_reporting_period_status, x_err_stack, x_err_stage, x_err_code);

          IF(x_reporting_period_status = 'Y') THEN

                -- Stop processing and exit the procedure return from the procedure
                -- after a  rollback;
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   Pa_Debug.debug('ref_rl_accum: ' || '*********************************************************************************',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                   Pa_Debug.debug('ref_rl_accum: ' || '******Reporting Period Moved Backward In Time During Process Run',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                   Pa_Debug.debug('ref_rl_accum: ' || '******The Accumulation for the project '|| projrec.segment1 || ' Rolled Back',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                   Pa_Debug.debug('ref_rl_accum: ' || '*********************************************************************************',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                END IF;
       IF Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(projrec.project_id)) = 0 THEN
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             Pa_Debug.debug('ref_rl_accum: ' || 'Releasing the lock on project ...');
          END IF;
       END IF;
                errbuf  := 'Reporting Period Moved Backward In Time During Process Run';
                retcode := 2;
                ROLLBACK WORK;
                RETURN;
          END IF; -- IF(x_reporting_period_status = 'Y')

          COMMIT WORK;  -- we are done with this project now
       IF Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(projrec.project_id)) = 0 THEN
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             Pa_Debug.debug('ref_rl_accum: ' || 'Releasing the lock on project ...');
          END IF;
       END IF;


      EXCEPTION

       WHEN OTHERS THEN
          rel_lock := Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(l_project_id));
          x_err_code := SQLCODE;
          retcode := x_err_code;
          errbuf  := SUBSTR(SQLERRM(SQLCODE),1,512);
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             Pa_Debug.debug('ref_rl_accum: ' || 'Exception Generated By Oracle Error: ' || errbuf ,Pa_Debug.DEBUG_LEVEL_EXCEPTION);
             Pa_Debug.debug('ref_rl_accum: ' || 'Skipping the accumulation for project ' || projrec.segment1 ,Pa_Debug.DEBUG_LEVEL_EXCEPTION);
          END IF;

          -- Exception handling for database errors (other than 1400 and 1489)
          IF x_err_code*-1 BETWEEN 1400 AND 1489 THEN
             ROLLBACK WORK;
          ELSE
             RAISE;
          END IF;

      END; -- end of PL/SQL block for each project

     END LOOP;

     x_err_stack := x_old_stack;
     RETURN;

  EXCEPTION

   WHEN OTHERS THEN
     rel_lock := Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(l_project_id));
     x_err_code := SQLCODE;
     retcode := x_err_code;
     errbuf  := SUBSTR(SQLERRM(SQLCODE),1,512);
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        Pa_Debug.debug('ref_rl_accum: ' || 'Exception Generated By Oracle Error: ' || errbuf ,Pa_Debug.DEBUG_LEVEL_EXCEPTION);
     END IF;
     ROLLBACK WORK;
     RETURN;
  END ref_rl_accum;



  --   project_num_from  : start project # : mandatory
  --   project_num_to    : end   project # : mandatory
  --   start_pa_period   : start_pa_period : optional
  --   end_pa_period     : end_pa_period   : optional
  --   system_linkage_function:            : optional

  PROCEDURE build_txn_accum
                        ( errbuf                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          retcode                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_project_num_from        IN  VARCHAR2,
                          x_project_num_to          IN  VARCHAR2,
                          x_start_pa_period         IN  VARCHAR2,
                          x_end_pa_period           IN  VARCHAR2,
                          x_system_linkage_function IN  VARCHAR2
                        )
  IS
    P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
    l_accum_period_type_changed BOOLEAN;
    -- Declare cursor for Projects

    l_project_num_from VARCHAR2(25);
    l_project_num_to   VARCHAR2(25);
    l_project_id       NUMBER;

    CURSOR selprjs IS
    SELECT
         ppr.project_id,
         ppr.segment1,
         ppr.closed_date
    FROM
         pa_projects ppr
    WHERE
         NVL(ppr.template_flag,'N') <> 'Y'
    AND  ppr.segment1 BETWEEN l_project_num_from AND l_project_num_to
    AND  Pa_Utils2.IsProjectInPurgeStatus(ppr.project_status_code)= 'N';

  projrec        selprjs%ROWTYPE;
  x_mode         VARCHAR2(1);
  table_index     BINARY_INTEGER; -- index for the table for reporting


  BEGIN

     x_err_code  := 0;
     x_err_stage := 'Build Transaction accumulation Process';

     x_summ_process := 'RT';
     x_old_stack := x_err_stack;
     x_err_stack := x_err_stack || '->pa_proj_accum_main.build_txn_accum';

     x_mode      := 'F';

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        Pa_Debug.debug('build_txn_accum: ' || x_err_stack);
     END IF;

     -- Validate Parameters
     Get_Project_Num_Range( x_project_num_from,
                            x_project_num_to,
                            l_project_num_from,
                            l_project_num_to,
																												NULL );  --for bug 2543021

     IF (x_start_pa_period IS NOT NULL AND x_end_pa_period IS NULL ) THEN

         errbuf  := 'End PA period must be specified when start PA period is given ';
         retcode := 2;
         RETURN;
     END IF;

     -- assume the process does not return an error
     retcode :=0;

     -- all the parameters are validated now

     -- Call the Initialization procedure

     Pa_Proj_Accum_Main.initialize;

     -- Get the start pa_date and end pa_date for processing

     IF ( x_start_pa_period IS NOT NULL ) THEN
        BEGIN
          SELECT start_date INTO x_start_pa_date
          FROM  pa_periods
          WHERE period_name = x_start_pa_period;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN OTHERS THEN
            errbuf  := 'Error Occured while getting the start_date for the start pa_period';
            retcode := 3;
            RETURN;
        END;
        BEGIN
          SELECT end_date INTO x_end_pa_date
          FROM  pa_periods
          WHERE period_name = x_end_pa_period;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN OTHERS THEN
            errbuf  := 'Error Occured while getting the end_date for the end pa_period';
            retcode := 4;
            RETURN;
        END;

     END IF; -- IF ( x_start_pa_period IS NOT NULL )

     FOR projrec IN selprjs LOOP

      BEGIN

         -- This PL/SQL block corresponds to processing for each project
         ------------Acquire lock on the project-----------
         IF Pa_Debug.acquire_user_lock('PA_SUMM:'||TO_CHAR(projrec.project_id)) <> 0 THEN
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               Pa_Debug.debug('build_txn_accum: ' || 'Could not acquire lock on the Project. Skipping ...');
            END IF;
               GOTO next_project;
         ELSE
            IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
               Pa_Debug.debug('build_txn_accum: ' || 'Locking the project for summarization ...');
            END IF;
         END IF;
         -------------------------------------------------
         l_project_id := projrec.project_id;
         IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
            Pa_Debug.debug('build_txn_accum: ' || 'Refreshing Transaction Accumulation for the Project Id = '
                        || TO_CHAR(projrec.project_id));
         END IF;

         -- Initialize the Global variable in the loop for each project
         -- No need to check if the accumulation period type has changed because
         -- the project is being refreshed
         Pa_Proj_Accum_Main.initialize_project(projrec.project_id, l_accum_period_type_changed);

         -- Get the accum configuration

         Pa_Txn_Accums.get_accum_configurations
                           ( projrec.project_id,
                             x_err_stage,
                             x_err_code);

         -- Get the summary number from database tables to PL/SQL table

         table_index := Pa_Accum_Srw.number_of_projects + 1;

         Pa_Accum_Srw.get_project_txn_numbers
                      (projrec.project_id,   --- project Id
                       'PRE',
                       table_index,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);

         -- refresh the resource maps for the resource list assignments
         -- for the entire project

         Pa_Res_Accums.delete_res_maps_on_prj_id
                         (projrec.project_id,
                          NULL,
                          x_err_stage,
                          x_err_code);

         Pa_Res_Accums.delete_resource_accum_details
                         (NULL,
                          NULL,
                          projrec.project_id,
                          x_err_stage,
                          x_err_code);

         -- refresh summary transaction accum

         Pa_Delete_Accum_Recs.delete_project_actuals
                          (projrec.project_id,
                           x_err_stack,
                           x_err_stage,
                           x_err_code);

         Pa_Delete_Accum_Recs.delete_project_commitments
                           (projrec.project_id,
                            x_err_stack,
                            x_err_stage,
                            x_err_code);

         -- refresh and accumulate the actuals txns to PA_TXN_ACCUM
         -- First call the refresh APIs

         Pa_Txn_Accums.refresh_txn_accum
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_start_pa_date,     -- start_pa_period
                             x_end_pa_date,       -- end_pa_period
                             'C',                   -- Tyansaction_type for CDLs
                             x_system_linkage_function,
                             x_err_stage,
                             x_err_code);

         Pa_Txn_Accums.refresh_txn_accum
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_start_pa_date,     -- start_pa_period
                             x_end_pa_date,       -- end_pa_period
                             'R',                   -- Transaction_type for Rev.
                             NULL,                  -- system_linakge_funtion
                                                    -- cannot be specified for Rev.
                             x_err_stage,
                             x_err_code);

         Pa_Txn_Accums.accum_cdls
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_start_pa_date,     -- start_pa_period
                             x_end_pa_date,       -- end_pa_period
                             x_system_linkage_function,
                             x_mode,
                             'R',
                             x_err_stage,
                             x_err_code);


         -- 05-AUG-2003, jwhite: For patchset 'L' Reburdening Enhancement
         IF (Pa_Proj_Accum_Main.G_PA_Enhanced_Burdening = 'Y')
            THEN


            IF ( P_DEBUG_MODE = 'Y' )
               THEN
                 Pa_Debug.debug('build_txn_accum: Call Accum_Cdls with x_cdl_line_type = I' );
            END IF;

            Pa_Txn_Accums.accum_cdls
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_start_pa_date,     -- start_pa_period
                             x_end_pa_date,       -- end_pa_period
                             x_system_linkage_function,
                             x_mode,
                             'I',
                             x_err_stage,
                             x_err_code);

          END IF;
          -- --------------------------------------------------------------


         Pa_Txn_Accums.accum_revenue
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_start_pa_date,     -- start_pa_period
                             x_end_pa_date,       -- end_pa_period
                             x_mode,
                             x_err_stage,
                             x_err_code);

         -- Move the tot_ figures into i_ figures for other transactions
         -- which are not refreshed currently

         Pa_Txn_Accums.update_act_txn_accum
                        ( projrec.project_id,
                          projrec.project_id,
                          x_err_stage,
                          x_err_code);

         -- please note that the budgets and commitments are always refreshed

         -- introduce the budgets API here
         -- first refresh the commitments

         Pa_Txn_Accums.refresh_txn_accum
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_start_pa_date,     -- start_pa_period
                             x_end_pa_date,       -- end_pa_period
                             'M',                   -- Transaction_type for Commitments
                             x_system_linkage_function,
                             x_err_stage,
                             x_err_code);

         Pa_Txn_Accums.create_cmt_txns
                            (projrec.project_id,    -- start_project_id
			     projrec.project_id,    -- end_project_id
                             x_system_linkage_function,
                             x_err_stage,
                             x_err_code,
                             'N');   --x_use_tmp_table bug 5635857

          -- Create summarized burden commitment transactions
              Pa_Burden_Costing.create_burden_cmt_transaction
                     (x_project_id=>projrec.project_id,  /* added for bug 2734747 */
		      status=>x_status,
                      stage=>x_stage ,
                      x_run_id=>x_run_id);

         Pa_Txn_Accums.accum_commitments
                            (projrec.project_id,    -- start_project_id
                             projrec.project_id,    -- end_project_id
                             x_system_linkage_function,
                             x_err_stage,
                             x_err_code);

         Pa_Accum_Utils.update_proj_accum_header
                                 (x_proj_level_accum_id,
                                  x_current_period,
                                  x_err_stack,
                                  x_err_stage,
                                  x_err_code);

         -- get the summary number post processing
         Pa_Accum_Srw.get_project_txn_numbers
                      (projrec.project_id,   --- project Id
                       'POST',
                       table_index,
                       x_err_stack,
                       x_err_stage,
                       x_err_code);

         Pa_Accum_Srw.number_of_projects := table_index;

       <<next_project>>

          -- Check if the reporting period was moved backwards
          check_reporting_period
             (x_reporting_period_status, x_err_stack, x_err_stage, x_err_code);

          IF(x_reporting_period_status = 'Y') THEN

                -- Stop processing and exit the procedure return from the procedure
                -- after a  rollback;
                IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
                   Pa_Debug.debug('build_txn_accum: ' || '*********************************************************************************',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                   Pa_Debug.debug('build_txn_accum: ' || '******Reporting Period Moved Backward In Time During Process Run',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                   Pa_Debug.debug('build_txn_accum: ' || '******The Accumulation for the project '|| projrec.segment1 || ' Rolled Back',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                   Pa_Debug.debug('build_txn_accum: ' || '*********************************************************************************',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
                END IF;
     IF Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(projrec.project_id)) = 0 THEN
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           Pa_Debug.debug('build_txn_accum: ' || 'Releasing the lock on project ...');
        END IF;
     END IF;
                errbuf  := 'Reporting Period Moved Backward In Time During Process Run';
                retcode := 5;
                ROLLBACK WORK;
                RETURN;
          END IF; -- IF(x_reporting_period_status = 'Y')

          COMMIT WORK;  -- we are done with this project now
     IF Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(projrec.project_id)) = 0 THEN
        IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
           Pa_Debug.debug('build_txn_accum: ' || 'Releasing the lock on project ...');
        END IF;
     END IF;

      EXCEPTION

       WHEN OTHERS THEN
          rel_lock := Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(l_project_id));
          x_err_code := SQLCODE;
          retcode := x_err_code;
          errbuf  := SUBSTR(SQLERRM(SQLCODE),1,512);
          IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
             Pa_Debug.debug('build_txn_accum: ' || 'Exception Generated By Oracle Error: ' || errbuf ,Pa_Debug.DEBUG_LEVEL_EXCEPTION);
             Pa_Debug.debug('build_txn_accum: ' || 'Skipping the accumulation for project ' || projrec.segment1 ,Pa_Debug.DEBUG_LEVEL_EXCEPTION);
          END IF;

          -- Exception handling for database errors (other than 1400 and 1489)
          IF x_err_code*-1 BETWEEN 1400 AND 1489 THEN
             ROLLBACK WORK;
          ELSE
             RAISE;
          END IF;

      END; -- end of PL/SQL block for each project

     END LOOP;

     x_err_stack := x_old_stack;
     RETURN;

  EXCEPTION

   WHEN OTHERS THEN
     rel_lock := Pa_Debug.release_user_lock('PA_SUMM:'||TO_CHAR(l_project_id));
     x_err_code := SQLCODE;
     retcode := x_err_code;
     errbuf  := SUBSTR(SQLERRM(SQLCODE),1,512);
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        Pa_Debug.debug('build_txn_accum: ' || 'Exception Generated By Oracle Error: ' || errbuf ,Pa_Debug.DEBUG_LEVEL_EXCEPTION);
     END IF;
     ROLLBACK WORK;
     RETURN;
  END build_txn_accum;

  PROCEDURE lock_proj_level_header_record
                       (x_project_id          IN NUMBER)
  IS
     P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
     dummy_project_id  NUMBER;
  BEGIN
     x_old_stack := x_err_stack;
     x_err_stack :=
       x_err_stack ||'->pa_proj_accum_main.lock_proj_level_header_record';
     x_err_code  := 0;
     x_err_stage :=
       'locking the project level header record for project_id= '||x_project_id;

     -- Try to Lock the project level header record with NOWAIT. If some
     -- other process is locking the record then raise an exception.

     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        Pa_Debug.debug('lock_proj_level_header_record: ' || x_err_stack);
     END IF;

     x_proj_header_locked := FALSE;  -- Assume project header is not locked

     SELECT
         pah.project_id
     INTO
         dummy_project_id
     FROM
         pa_project_accum_headers pah
     WHERE
         pah.project_id = x_project_id
     AND pah.task_id  = 0
     AND pah.resource_list_id = 0
     AND pah.resource_list_member_id = 0
     AND pah.resource_id = 0
     FOR UPDATE OF project_id NOWAIT;

     x_err_stack := x_old_stack;

  EXCEPTION
     -- It may be possible that the project level header record is locked
     -- by some other process.

     WHEN RECORD_ALREADY_LOCKED THEN
       x_proj_header_locked := TRUE;
       x_err_stack := x_old_stack;

       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          Pa_Debug.debug('lock_proj_level_header_record: ' || '******************************************************************************************************',
                       Pa_Debug.DEBUG_LEVEL_EXCEPTION);
          Pa_Debug.debug('lock_proj_level_header_record: ' || '****Unable to lock the Project Level Header Record for the Project_id '|| TO_CHAR(x_project_id) ||
                      ' Skipping this Project for processing ****',Pa_Debug.DEBUG_LEVEL_EXCEPTION);
          Pa_Debug.debug('lock_proj_level_header_record: ' || '******************************************************************************************************',
                       Pa_Debug.DEBUG_LEVEL_EXCEPTION);
       END IF;

     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
  END lock_proj_level_header_record;

  -- Function to get the end date of the current period --
  FUNCTION Get_curr_end_date
     RETURN DATE
  IS
  BEGIN
       RETURN Pa_Proj_Accum_Main.x_current_end_date;
  EXCEPTION
      WHEN OTHERS THEN
           RAISE;
  END Get_curr_end_date;

/*
 --Bug 5635857. This procedure will populate pa_commitment_txns_tmp table from
  --pa_commitment_txns_v. This table will later be used in processing
  --Dynamic Insert statement is used since otherwise its not possible to get and insert
  --the data from pa_commitment_txns_v for all the projects in one go.
  PROCEDURE populate_cmt_tmp_table
  (p_project_id_tbl            IN   pa_plsql_datatypes.idTabTyp,
   p_system_linkage_function   IN   VARCHAR2)
  IS

  x_last_updated_by         NUMBER(15);
  x_last_update_date        NUMBER(15);
  x_created_by              NUMBER(15);
  x_last_update_login       NUMBER(15);
  x_request_id              NUMBER(15);
  x_program_application_id  NUMBER(15);
  x_program_id              NUMBER(15);
  l_sql                     VARCHAR2(32700);
  l_proj_id_condition       VARCHAR2(32700);
  l_current_pa_period_flag  Varchar2(1);

  BEGIN

    DELETE FROM pa_commitment_txns_tmp;

    x_last_updated_by          := NVL(FND_GLOBAL.USER_ID,-1);
    x_last_update_date         := NVL(FND_GLOBAL.USER_ID,-1);
    x_created_by               := NVL(FND_GLOBAL.USER_ID,-1);
    x_last_update_login        := NVL(FND_GLOBAL.LOGIN_ID,-1);
    x_request_id               := NVL(FND_GLOBAL.CONC_REQUEST_ID,-1);
    x_program_application_id   := NVL(FND_GLOBAL.PROG_APPL_ID,-1);
    x_program_id               := NVL(FND_GLOBAL.CONC_PROGRAM_ID,-1);

    l_sql := NULL;
    l_proj_id_condition := NULL;

    FOR i IN 1..p_project_id_tbl.COUNT LOOP

        IF l_sql IS NULL THEN

            l_sql:='INSERT INTO pa_commitment_txns_tmp ' ||
                   '( PROJECT_ID, '||
                     'TASK_ID, '||
                     'TRANSACTION_SOURCE, '||
                     'LINE_TYPE, '||
                     'CMT_NUMBER, '||
                     'CMT_DISTRIBUTION_ID, '||
                     'CMT_HEADER_ID, '||
                     'DESCRIPTION, '||
                     'EXPENDITURE_ITEM_DATE, '||
                     'PA_PERIOD, '||
                     'GL_PERIOD, '||
                     'CMT_LINE_NUMBER, '||
                     'CMT_CREATION_DATE, '||
                     'CMT_APPROVED_DATE, '||
                     'CMT_REQUESTOR_NAME, '||
                     'CMT_BUYER_NAME, '||
                     'CMT_APPROVED_FLAG, '||
                     'CMT_PROMISED_DATE, '||
                     'CMT_NEED_BY_DATE, '||
                     'ORGANIZATION_ID, '||
                     'VENDOR_ID, '||
                     'VENDOR_NAME, '||
                     'EXPENDITURE_TYPE, '||
                     'EXPENDITURE_CATEGORY, '||
                     'REVENUE_CATEGORY, '||
                     'SYSTEM_LINKAGE_FUNCTION, '||
                     'UNIT_OF_MEASURE, '||
                     'UNIT_PRICE, '||
                     'CMT_IND_COMPILED_SET_ID, '||
                     'TOT_CMT_QUANTITY, '||
                     'QUANTITY_ORDERED, '||
                     'AMOUNT_ORDERED, '||
                     'ORIGINAL_QUANTITY_ORDERED, '||
                     'ORIGINAL_AMOUNT_ORDERED, '||
                     'QUANTITY_CANCELLED, '||
                     'AMOUNT_CANCELLED, '||
                     'QUANTITY_DELIVERED, '||
                     'QUANTITY_INVOICED, '||
                     'AMOUNT_INVOICED, '||
                     'QUANTITY_OUTSTANDING_DELIVERY, '||
                     'AMOUNT_OUTSTANDING_DELIVERY, '||
                     'QUANTITY_OUTSTANDING_INVOICE, '||
                     'AMOUNT_OUTSTANDING_INVOICE, '||
                     'QUANTITY_OVERBILLED, '||
                     'AMOUNT_OVERBILLED, '||
                     'ORIGINAL_TXN_REFERENCE1, '||
                     'ORIGINAL_TXN_REFERENCE2, '||
                     'ORIGINAL_TXN_REFERENCE3, '||
                     'LAST_UPDATE_DATE, '||
                     'LAST_UPDATED_BY, '||
                     'CREATION_DATE, '||
                     'CREATED_BY, '||
                     'LAST_UPDATE_LOGIN, '||
                     'REQUEST_ID, '||
                     'PROGRAM_APPLICATION_ID, '||
                     'PROGRAM_ID, '||
                     'PROGRAM_UPDATE_DATE, '||
                     'acct_raw_cost, '||
                     'acct_burdened_cost, '||
                     'denom_currency_code, '||
                     'denom_raw_cost, '||
                     'denom_burdened_cost, '||
                     'acct_currency_code, '||
                     'acct_rate_date, '||
                     'acct_rate_type, '||
                     'acct_exchange_rate, '||
                     'receipt_currency_code, '||
                     'receipt_currency_amount, '||
                     'receipt_exchange_rate, '||
                     'INVENTORY_ITEM_ID, '||
                     'UOM_CODE, '||
                     'wip_resource_id, '||
                     'resource_class '||
                 ') '||
                 'SELECT '||
                     'pctv.project_id, '||
                     'pctv.task_id, '||
                     'pctv.transaction_source, '||
                     'decode(pctv.line_type,''P'',''P'',''R'',''R'',''I'',''I'',''O''), '||
                     'pctv.cmt_number, '||
                     'pctv.cmt_distribution_id, '||
                     'pctv.cmt_header_id, '||
                     'pctv.description, '||
                     'pctv.expenditure_item_date, '||
                     'pctv.pa_period, '||
                     'pctv.gl_period, '||
                     'pctv.cmt_line_number, '||
                     'pctv.cmt_creation_date, '||
                     'pctv.cmt_approved_date, '||
                     'pctv.cmt_requestor_name, '||
                     'pctv.cmt_buyer_name, '||
                     'pctv.cmt_approved_flag, '||
                     'pctv.cmt_promised_date, '||
                     'pctv.cmt_need_by_date, '||
                     'pctv.organization_id, '||
                     'pctv.vendor_id, '||
                     'pctv.vendor_name, '||
                     'pctv.expenditure_type, '||
                     'pctv.expenditure_category, '||
                     'pctv.revenue_category, '||
                     'pctv.system_linkage_function, '||
                     'pctv.unit_of_measure, '||
                     'pctv.unit_price, '||
                     'pctv.cmt_ind_compiled_set_id, '||
                     'pctv.tot_cmt_quantity, '||
                     'pctv.quantity_ordered, '||
                     'pctv.amount_ordered, '||
                     'pctv.original_quantity_ordered, '||
                     'pctv.original_amount_ordered, '||
                     'pctv.quantity_cancelled, '||
                     'pctv.amount_cancelled, '||
                     'pctv.quantity_delivered, '||
                     'pctv.quantity_invoiced, '||
                     'pctv.amount_invoiced, '||
                     'pctv.quantity_outstanding_delivery, '||
                     'pctv.amount_outstanding_delivery, '||
                     'pctv.quantity_outstanding_invoice, '||
                     'pctv.amount_outstanding_invoice, '||
                     'pctv.quantity_overbilled, '||
                     'pctv.amount_overbilled, '||
                     'pctv.original_txn_reference1, '||
                     'pctv.original_txn_reference2, '||
                     'pctv.original_txn_reference3, '||
                     'SYSDATE, '||
                      x_last_updated_by||', '||
                     'SYSDATE, '||
                      x_created_by||', '||
                      x_last_update_login||', '||
                      x_request_id||', '||
                      x_program_application_id||', '||
                      x_program_id||', '||
                     'NULL, '||
                     'pctv.acct_raw_cost, '||
                     'pctv.acct_burdened_cost, '||
                     'pctv.denom_currency_code, '||
                     'pctv.denom_raw_cost, '||
                     'pctv.denom_burdened_cost, '||
                     'pctv.acct_currency_code, '||
                     'pctv.acct_rate_date, '||
                     'pctv.acct_rate_type, '||
                     'pctv.acct_exchange_rate, '||
                     'pctv.receipt_currency_code, '||
                     'pctv.receipt_currency_amount, '||
                     'pctv.receipt_exchange_rate, '||
                     'pctv.INVENTORY_ITEM_ID, '||
                     'pctv.UOM_CODE, '||
                     'pctv.wip_resource_id, '||
                     'pctv.resource_class '||
                  'FROM  '||
                     'pa_commitment_txns_v pctv '||
                  'WHERE ' ;
                  IF p_system_linkage_function IS NOT NULL THEN

                    l_sql := l_sql || 'NVL(pctv.system_linkage_function,''X'') = '''||
                                      p_system_linkage_function ||''' AND ';
                  END IF;
                  l_sql := l_sql || ' pctv.project_id IN (';

        END IF;

        IF l_proj_id_condition IS NULL THEN

            l_proj_id_condition := p_project_id_tbl(i);

        ELSE

            l_proj_id_condition := l_proj_id_condition  ||', '|| p_project_id_tbl(i);

        END IF;

        IF LENGTH (l_sql || l_proj_id_condition) >32000 THEN

            l_sql := l_sql || l_proj_id_condition ||' )';

            EXECUTE IMMEDIATE l_sql;

            l_sql := NULL;
            l_proj_id_condition := NULL;

        END IF;

    END LOOP;


    IF NVL(LENGTH(l_sql||l_proj_id_condition),0)>0 THEN

        l_sql := l_sql || l_proj_id_condition ||' )';

        EXECUTE IMMEDIATE l_sql;

        l_sql := NULL;
        l_proj_id_condition := NULL;

    END IF;

  END populate_cmt_tmp_table; */

/* Procedure added for bug#6408874 */
  PROCEDURE populate_cmt_tmp_table
           (p_project_num_from          IN   VARCHAR2,
            p_project_num_to            IN   VARCHAR2,
            p_system_linkage_function   IN   VARCHAR2,
            p_refresh_flag              IN   VARCHAR2, -- Added for Bug# 7175975
            p_project_type              IN   VARCHAR2) -- Added for Bug# 7175975
           IS

           x_last_updated_by         NUMBER(15);
           x_last_update_date        NUMBER(15);
           x_created_by              NUMBER(15);
           x_last_update_login       NUMBER(15);
           x_request_id              NUMBER(15);
           x_program_application_id  NUMBER(15);
           x_program_id              NUMBER(15);
           l_sql                     VARCHAR2(32700);
           l_proj_id_condition       VARCHAR2(32700);

           L_CNT                     NUMBER;
           TmpProjectTab  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); --bug 6408874
   BEGIN

             DELETE FROM pa_commitment_txns_tmp;
             DELETE FROM pa_pjm_po_commitments_tmp;  /* Bug 6408874 */
             DELETE FROM pa_pjm_req_commitments_tmp; /* Bug 6408874 */
          --   DELETE FROM pa_fp_ra_map_tmp;

             x_last_updated_by          := NVL(FND_GLOBAL.USER_ID,-1);
             x_last_update_date         := NVL(FND_GLOBAL.USER_ID,-1);
             x_created_by               := NVL(FND_GLOBAL.USER_ID,-1);
             x_last_update_login        := NVL(FND_GLOBAL.LOGIN_ID,-1);
             x_request_id               := NVL(FND_GLOBAL.CONC_REQUEST_ID,-1);
             x_program_application_id   := NVL(FND_GLOBAL.PROG_APPL_ID,-1);
             x_program_id               := NVL(FND_GLOBAL.CONC_PROGRAM_ID,-1);

             l_sql := NULL;
             l_proj_id_condition := NULL;

             IF (p_refresh_flag = 'N') THEN  --Condition via bug 7175975
               -- bug 6408874. Introduced BULK Processing
               SELECT DISTINCT pfa.project_id project_id
                 bulk collect into TmpProjectTab
               FROM pa_projects_for_accum pfa
               WHERE pfa.request_id = x_request_id
               AND pfa.segment1 BETWEEN p_project_num_from AND p_project_num_to
               AND pfa.action_flag = 'CM'
               AND NOT EXISTS (SELECT pf.project_id
                               FROM pa_projects_for_accum pf
                               WHERE pf.request_id = pfa.request_id
                               AND pf.segment1 = pfa.segment1
                               AND pf.action_flag IN ('PT', 'CL', 'BK', 'TR'));
             -- Added below for Bug# 7175975
             ELSIF (p_refresh_flag = 'Y') THEN
	       SELECT ppr.project_id
               BULK COLLECT INTO TmpProjectTab
               FROM pa_projects ppr
               WHERE NVL(ppr.template_flag,'N') <> 'Y'
               AND  ppr.segment1 BETWEEN p_project_num_from AND p_project_num_to
               AND  ppr.project_type = NVL(p_project_type, project_type)
               AND  Pa_Utils2.IsProjectInPurgeStatus(ppr.project_status_code) = 'N';
	     END IF;
             -- End for Bug# 7175975

/* Bug 6408874 */
         forall i in 1..TmpProjectTab.count  --commented for bug 6408874, put back for bug 7491714
         insert into pa_pjm_req_commitments_tmp
                      (  project_id
                        ,task_id
                        ,req_number
                        ,req_distribution_id
                        ,requisition_header_id
                        ,item_description
                        ,expenditure_item_date
                        ,req_line
                        ,creation_date
                        ,requestor_name
                        ,approved_flag
                        ,need_by_date
                        ,expenditure_organization_id
                        ,vendor_id
                        ,vendor_name
                        ,expenditure_type
                        ,expenditure_category
                        ,revenue_category
                        ,unit_of_measure
                        ,unit_price
                        ,amount
                        ,quantity
                        ,denom_currency_code
                        ,denom_amount
                        ,acct_currency_code
                        ,acct_rate_date
                        ,acct_rate_type
                        ,acct_exchange_rate
                        ,inventory_item_id
                        ,inventory_item_name
                        ,uom_code
                        ,wip_resource_id
                        ,wip_resource_name
                     )
            select
                         pmprd.project_id
                        ,pmprd.task_id
                        ,pmprd.req_number
                        ,pmprd.req_distribution_id
                        ,pmprd.requisition_header_id
                        ,pmprd.item_description
                        ,pmprd.expenditure_item_date
                        ,pmprd.req_line
                        ,pmprd.creation_date
                        ,pmprd.requestor_name
                        ,pmprd.approved_flag
                        ,pmprd.need_by_date
                        ,pmprd.expenditure_organization_id
                        ,pmprd.vendor_id
                        ,pmprd.vendor_name
                        ,pmprd.expenditure_type
                        ,pmprd.expenditure_category
                        ,pmprd.revenue_category
                        ,pmprd.unit_of_measure
                        ,pmprd.unit_price
                        ,pmprd.amount
                        ,pmprd.quantity
                        ,pmprd.denom_currency_code
                        ,pmprd.denom_amount
                        ,pmprd.acct_currency_code
                        ,pmprd.acct_rate_date
                        ,pmprd.acct_rate_type
                        ,pmprd.acct_exchange_rate
                        ,pmprd.inventory_item_id
                        ,pmprd.inventory_item_name
                        ,pmprd.uom_code
                        ,pmprd.wip_resource_id
                        ,pmprd.wip_resource_name
                   from  pjm_req_commitments_v pmprd -- bug 7491714
                   where  pmprd.project_id = TmpProjectTab(i);
                   -- commented for bug 6408874
                  -- where  pmprd.project_id = TmpProjectTab(i);


          forall i in 1..TmpProjectTab.count   -- commented for bug 6408874, back for bug 7491714
         insert into pa_pjm_po_commitments_tmp
                    (project_id
                    ,task_id
                    ,po_number
                    ,po_distribution_id
                    ,po_header_id
                    ,item_description
                    ,expenditure_item_date
                    ,po_line
                    ,creation_date
                    ,approved_date
                    ,requestor_name
                    ,buyer_name
                    ,approved_flag
                    ,expenditure_organization_id
                    ,vendor_id
                    ,vendor_name
                    ,expenditure_type
                    ,expenditure_category
                    ,revenue_category
                    ,unit_of_measure
                    ,unit_price
                    ,amount_outstanding_delivery
                    ,quantity_outstanding_delivery
                    ,quantity_ordered
                    ,amount_ordered
                    ,original_quantity_ordered
                    ,original_amount_ordered
                    ,quantity_cancelled
                    ,amount_cancelled
                    ,quantity_delivered
                    ,quantity_invoiced
                    ,amount_invoiced
                    ,quantity_outstanding_invoice
                    ,amount_outstanding_invoice
                    ,quantity_overbilled
                    ,amount_overbilled
                    ,denom_currency_code
                    ,denom_amt_outstanding_delivery
                    ,acct_currency_code
                    ,acct_rate_date
                    ,acct_rate_type
                    ,acct_exchange_rate
                    ,inventory_item_id
                    ,inventory_item_name
                    ,uom_code
                    ,wip_resource_id
                    ,wip_resource_name
                     )
           select
                  pmppd.project_id,
                  pmppd.task_id,
                  pmppd.po_number,
                  pmppd.po_distribution_id,
                  pmppd.po_header_id,
                  pmppd.item_description,
                  pmppd.expenditure_item_date,
                  pmppd.po_line,
                  pmppd.creation_date,
                  pmppd.approved_date,
                  pmppd.requestor_name,
                  pmppd.buyer_name,
                  pmppd.approved_flag,
                  pmppd.expenditure_organization_id,
                  pmppd.vendor_id,
                  pmppd.vendor_name,
                  pmppd.expenditure_type,
                  pmppd.expenditure_category,
                  pmppd.revenue_category,
                  pmppd.unit_of_measure,
                  pmppd.unit_price,
                  pmppd.amount_outstanding_delivery,
                  pmppd.quantity_outstanding_delivery,
                  pmppd.quantity_ordered,
                  pmppd.amount_ordered,
                  pmppd.original_quantity_ordered,
                  pmppd.original_amount_ordered,
                  pmppd.quantity_cancelled,
                  pmppd.amount_cancelled,
                  pmppd.quantity_delivered,
                  pmppd.quantity_invoiced,
                  pmppd.amount_invoiced,
                  pmppd.quantity_outstanding_invoice,
                  pmppd.amount_outstanding_invoice,
                  pmppd.quantity_overbilled,
                  pmppd.amount_overbilled,
                  pmppd.denom_currency_code,
                  pmppd.denom_amt_outstanding_delivery,
                  pmppd.acct_currency_code,
                  pmppd.acct_rate_date,
                  pmppd.acct_rate_type,
                  pmppd.acct_exchange_rate,
                  pmppd.inventory_item_id,
                  pmppd.inventory_item_name,
                  pmppd.uom_code,
                  pmppd.wip_resource_id,
                  pmppd.wip_resource_name
             from pjm_po_commitments_v pmppd
             where pmppd.project_id = TmpProjectTab(i); -- bug 7491714
             -- commented for bug 6408874
            -- where pmppd.project_id = TmpProjectTab(i);

/* Bug 6408874 */

             forall i in 1..TmpProjectTab.count
               INSERT INTO pa_commitment_txns_tmp
                          (PROJECT_ID,
                           TASK_ID,
                           TRANSACTION_SOURCE,
                           LINE_TYPE,
                           CMT_NUMBER,
                           CMT_DISTRIBUTION_ID,
                           CMT_HEADER_ID,
                           DESCRIPTION,
                           EXPENDITURE_ITEM_DATE,
                           PA_PERIOD,
                           GL_PERIOD,
                           CMT_LINE_NUMBER,
                           CMT_CREATION_DATE,
                           CMT_APPROVED_DATE,
                           CMT_REQUESTOR_NAME,
                           CMT_BUYER_NAME,
                           CMT_APPROVED_FLAG,
                           CMT_PROMISED_DATE,
                           CMT_NEED_BY_DATE,
                           ORGANIZATION_ID,
                           VENDOR_ID,
                           VENDOR_NAME,
                           EXPENDITURE_TYPE,
                           EXPENDITURE_CATEGORY,
                           REVENUE_CATEGORY,
                           SYSTEM_LINKAGE_FUNCTION,
                           UNIT_OF_MEASURE,
                           UNIT_PRICE,
                           CMT_IND_COMPILED_SET_ID,
                           TOT_CMT_QUANTITY,
                           QUANTITY_ORDERED,
                           AMOUNT_ORDERED,
                           ORIGINAL_QUANTITY_ORDERED,
                           ORIGINAL_AMOUNT_ORDERED,
                           QUANTITY_CANCELLED,
                           AMOUNT_CANCELLED,
                           QUANTITY_DELIVERED,
                           QUANTITY_INVOICED,
                           AMOUNT_INVOICED,
                           QUANTITY_OUTSTANDING_DELIVERY,
                           AMOUNT_OUTSTANDING_DELIVERY,
                           QUANTITY_OUTSTANDING_INVOICE,
                           AMOUNT_OUTSTANDING_INVOICE,
                           QUANTITY_OVERBILLED,
                           AMOUNT_OVERBILLED,
                           ORIGINAL_TXN_REFERENCE1,
                           ORIGINAL_TXN_REFERENCE2,
                           ORIGINAL_TXN_REFERENCE3,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           CREATION_DATE,
                           CREATED_BY,
                           LAST_UPDATE_LOGIN,
                           REQUEST_ID,
                           PROGRAM_APPLICATION_ID,
                           PROGRAM_ID,
                           PROGRAM_UPDATE_DATE,
                           acct_raw_cost,
                           acct_burdened_cost,
                           denom_currency_code,
                           denom_raw_cost,
                           denom_burdened_cost,
                           acct_currency_code,
                           acct_rate_date,
                           acct_rate_type,
                           acct_exchange_rate,
                           receipt_currency_code,
                           receipt_currency_amount,
                           receipt_exchange_rate,
                           inventory_item_id,
                           uom_code,
                           wip_resource_id,
                           resource_class
                           )
                 SELECT
                        pctv.project_id,
                        pctv.task_id,
                        pctv.transaction_source,
                        pctv.line_type,
                        pctv.cmt_number,
                        pctv.cmt_distribution_id,
                        pctv.cmt_header_id,
                        pctv.description,
                        pctv.expenditure_item_date,
                        pctv.pa_period,
                        pctv.gl_period,
                        pctv.cmt_line_number,
                        pctv.cmt_creation_date,
                        pctv.cmt_approved_date,
                        pctv.cmt_requestor_name,
                        pctv.cmt_buyer_name,
                        pctv.cmt_approved_flag,
                        pctv.cmt_promised_date,
                        pctv.cmt_need_by_date,
                        pctv.organization_id,
                        pctv.vendor_id,
                        pctv.vendor_name,
                        pctv.expenditure_type,
                        pctv.expenditure_category,
                        pctv.revenue_category,
                        pctv.system_linkage_function,
                        pctv.unit_of_measure,
                        pctv.unit_price,
                        pctv.cmt_ind_compiled_set_id,
                        pctv.tot_cmt_quantity,
                        pctv.quantity_ordered,
                        pctv.amount_ordered,
                        pctv.original_quantity_ordered,
                        pctv.original_amount_ordered,
                        pctv.quantity_cancelled,
                        pctv.amount_cancelled,
                        pctv.quantity_delivered,
                        pctv.quantity_invoiced,
                        pctv.amount_invoiced,
                        pctv.quantity_outstanding_delivery,
                        pctv.amount_outstanding_delivery,
                        pctv.quantity_outstanding_invoice,
                        pctv.amount_outstanding_invoice,
                        pctv.quantity_overbilled,
                        pctv.amount_overbilled,
                        pctv.original_txn_reference1,
                        pctv.original_txn_reference2,
                        pctv.original_txn_reference3,
                        SYSDATE,
                        x_last_updated_by,
                        SYSDATE,
                        x_created_by,
                        x_last_update_login,
                        x_request_id,
                        x_program_application_id,
                        x_program_id,
                        NULL,
                        pctv.acct_raw_cost,
                        pctv.acct_burdened_cost,
                        pctv.denom_currency_code,
                        pctv.denom_raw_cost,
                        pctv.denom_burdened_cost,
                        pctv.acct_currency_code,
                        pctv.acct_rate_date,
                        pctv.acct_rate_type,
                        pctv.acct_exchange_rate,
                        pctv.receipt_currency_code,
                        pctv.receipt_currency_amount,
                        pctv.receipt_exchange_rate,
                        pctv.inventory_item_id,
                        pctv.uom_code,
                        pctv.wip_resource_id,
                        pctv.resource_class
                 FROM   pa_commitments_v pctv
                 WHERE  pctv.project_id = TmpProjectTab(i) --tmp.project_id
                 AND    NVL(pctv.system_linkage_function,'X') = NVL(p_system_linkage_function,NVL(pctv.system_linkage_function,'X'));

  END populate_cmt_tmp_table;

/* Procedure added for bug#6408874 */

END Pa_Proj_Accum_Main;

/
