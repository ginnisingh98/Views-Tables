--------------------------------------------------------
--  DDL for Package PA_PROJ_ACCUM_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_ACCUM_MAIN" AUTHID CURRENT_USER AS
/* $Header: PARESMNS.pls 120.3.12010000.2 2008/08/13 22:34:10 jngeorge ship $ */

   -- Standard who
   x_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_date        NUMBER(15) := FND_GLOBAL.USER_ID;
   x_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   x_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   x_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   x_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   x_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;

   -- Public variables for this package

   -- exception corresponding to ORA-000054
   RECORD_ALREADY_LOCKED     EXCEPTION;
   PRAGMA EXCEPTION_INIT(RECORD_ALREADY_LOCKED, -54);

   x_proj_header_locked      BOOLEAN;
   x_recs_processed          NUMBER;
   x_summ_process            VARCHAR2(2);

   -- These variables hold good for one installation of PA

   x_impl_option               pa_implementations.accumulation_period_type%TYPE;

   x_current_pa_period         pa_periods_v.period_name%TYPE;
   x_current_gl_period         pa_periods_v.gl_period_name%TYPE;
   x_current_pa_start_date     DATE;
   x_current_pa_end_date       DATE;
   x_current_gl_start_date     DATE;
   x_current_gl_end_date       DATE;
   x_current_year              NUMBER;
   x_period_yr_start_date      DATE;
   x_period_yr_end_date        DATE;

   -- Variable to store the current period before the process ends
   -- So that we can compare them from the corresponding column
   -- when the process was started

   x_new_current_pa_period     pa_periods_v.period_name%TYPE;
   x_new_current_gl_period     pa_periods_v.gl_period_name%TYPE;
   x_new_current_pa_start_date DATE;
   x_new_current_pa_end_date   DATE;
   x_new_current_gl_start_date DATE;
   x_new_current_gl_end_date   DATE;
   x_new_current_year          NUMBER;

   x_reporting_period_status   VARCHAR2(1);

   -- These variables hold good for each project

   x_Prev_Accum_period1        Varchar2(30); -- Added for bug 3653978
   x_Prev_Accum_period         Varchar2(30);
   x_Current_period            Varchar2(30);
   x_Prev_period               Varchar2(30);
   x_Prev_pa_period            Varchar2(30);
   x_prev_gl_period            Varchar2(30);

   x_proj_level_accum_id       Number;
   x_prev_year                 Number;
   x_prev_pa_year              Number;
   x_prev_gl_year              Number;
   x_prev_accum_year           Number;

   x_current_start_date        Date;
   x_current_end_date          Date;
   x_prev_start_date           Date;
   x_prev_end_date             Date;
   x_prev_pa_start_date        Date;
   x_prev_pa_end_date          Date;
   x_prev_gl_start_date        Date;
   x_prev_gl_end_date          Date;
   x_prev_accum_start_date     Date;
   x_prev_accum_end_date       Date;
   x_prev_prev_accum_period    Varchar2(30);


   -- Variables for getting the start pa_date and end pa_date
   -- when processing start pa_period and end pa_period

   x_start_pa_date Date := to_date('01-01-1950','DD-MM-YYYY'); -- very low date
   x_end_pa_date   Date := to_date('31-12-4712','DD-MM-YYYY'); -- very high date

   -- Variables for debugging the procedures

   x_err_stage                 VARCHAR2(120);
   x_err_code                  NUMBER;
   x_err_stack                 VARCHAR2(1630);
   x_old_stack                 VARCHAR2(1630);
   x_commit_size               NUMBER;
   rel_lock                    NUMBER;

   -- Grants Management Integrated Commitment Processing  ---------------------
   -- added 30-MAY-2003, jwhite

   G_GMS_Enabled               VARCHAR2(1) := 'N';

   -- -------------------------------------------------------------------------

   -- Patchset 'L' Reburdening Enhancement Processing  ---------------------
   -- added 05-AUG-2003, jwhite

   G_PA_Enhanced_Burdening	VARCHAR2(1) := 'N';

   -- -------------------------------------------------------------------------


   TYPE actions_in_rec_type IS RECORD
       (action_flag VARCHAR2(2));

   TYPE action_tbl_type IS TABLE OF actions_in_rec_type
	INDEX BY BINARY_INTEGER;

   PROCEDURE initialize;
   PROCEDURE initialize_project (x_project_id  IN  NUMBER,
                                 x_accum_period_type_changed OUT NOCOPY BOOLEAN); --File.Sql.39 bug 4440895

   PROCEDURE proj_accum
           (errbuf                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
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
	    x_grouping_id	      IN  NUMBER,
	    x_summ_context	      IN  VARCHAR2,
	    x_delete_temp_table	      IN  VARCHAR2,
	    x_project_type            IN  VARCHAR2
	   );

  PROCEDURE proj_refresh
          ( errbuf                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            retcode                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_project_num_from        IN  VARCHAR2,
            x_project_num_to          IN  VARCHAR2,
            x_end_date_through        IN  DATE,
            x_project_type            IN  VARCHAR2
           );

   PROCEDURE ref_rl_accum
           (errbuf                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	    retcode                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	    x_project_num_from        IN  VARCHAR2,
	    x_project_num_to          IN  VARCHAR2,
	    x_resource_list_id        IN  NUMBER
	   );

   PROCEDURE build_txn_accum
          (errbuf                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	   retcode                IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	   x_project_num_from        IN  VARCHAR2,
	   x_project_num_to          IN  VARCHAR2,
	   x_start_pa_period         IN  VARCHAR2,
	   x_end_pa_period           IN  VARCHAR2,
	   x_system_linkage_function IN  VARCHAR2
	  );

   PROCEDURE lock_proj_level_header_record
                       (x_project_id          IN NUMBER);

   FUNCTION action_exists
	   (x_action_flag  IN VARCHAR2,
	    x_actions_in   IN action_tbl_type,
	    x_actions_cnt  IN BINARY_INTEGER)
	    RETURN VARCHAR2 ;

   FUNCTION check_period_flags
	    (x_project_id  IN NUMBER,
	     x_impl_option IN VARCHAR2,
	     x_current_end_date IN DATE,
	     x_action_flag IN VARCHAR2,
	     x_closed_date IN DATE,
	     x_current_start_date IN DATE)
	     RETURN VARCHAR2 ;
--   PRAGMA RESTRICT_REFERENCES( check_period_flags, WNDS );

   FUNCTION Get_curr_end_date
     	    RETURN Date;
   PRAGMA RESTRICT_REFERENCES(Get_curr_end_date, WNDS, WNPS );

 /*
 Commented for Bug#6408874
   PROCEDURE populate_cmt_tmp_table
			( p_project_id_tbl            IN   pa_plsql_datatypes.idTabTyp,
			  p_system_linkage_function   IN   VARCHAR2 );
 */

PROCEDURE populate_cmt_tmp_table
                  (p_project_num_from          IN   VARCHAR2,
                   p_project_num_to            IN   VARCHAR2,
                   p_system_linkage_function   IN   VARCHAR2, -- Proc added for bug#6408874
                   p_refresh_flag              IN   VARCHAR2, -- Added for Bug# 7175975
                   p_project_type              IN   VARCHAR2); -- Added for Bug# 7175975

END PA_PROJ_ACCUM_MAIN;

/
